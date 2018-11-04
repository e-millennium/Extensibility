unit millenium_mormaiimkt_pedido_venda;

interface

uses
  Windows, Classes, wtsServerObjs, SysUtils, ServerCfgs, millenium_variants,
  JsonSerialization,millenium_rest_client,UTF8,EcoUtils,Variants,millenium_uteis;

implementation

function RemoveAcentos(Str:string): string;
const
  ComAcento = '����������������������������';
  SemAcento = 'aaeouaoaeioucuAAEOUAOAEIOUCU';
var
  x : Integer;
begin
  for x := 1 to Length(Str) do
  begin
    if Pos(Str[x],ComAcento)<>0 then
      Str[x] := SemAcento[Pos(Str[x],ComAcento)];
  end;
  Result := Str;
end;

function TratarStrings(const AValue:string):string;
begin
  Result := RemoveAcentos(AValue);
  Result := UpperCase(Result);
end;

function ExtrairDDDNumeroTelefone(const AValue:string):string;
begin
  Result := Copy(AValue,1,2);
end;

function ExtrairNumeroTelefone(const AValue:string):string;
begin
  Result := Unformat(AValue);
  Result := Copy(Result,3,Length(Result));
end;

procedure Receber(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  PV,CL,C,L: IwtsCommand;
  PedidoVenda,Cliente,Gerador,Endereco,Produtos,Barras,ProdutosPV,PVIncluir,LancamentosPV,Response,Values:IwtsWriteData;
  ClientePV,EnderecoEntrega,Lancamentos: IwtsData;
  JsonResponse,CodCliente,Cli,Pedidov,CodigoPedidoVenda,LogMsg,Chave,Barra: string;
  CodEndereco: Integer;
  UpdCli,UpdEnd: Boolean;
  Transportadoras,TiposPagtos: IwtsWriteData;
  Filial,TipoPedidoVenda,Transportadora,TipoFrete,CodEnderecoEntrega,CondicaoPagamento: Variant;
  I,X: Integer;
const
  Servico: string = '/api/millenium_eco!mmormaii/pedido_venda/listar';
begin
  C := DataPool.Open('MILLENIUM');
  L := DataPool.Open('MILLENIUM');
  PV := DataPool.Open('MILLENIUM');
  CL := DataPool.Open('MILLENIUM');

  PedidoVenda := DataPool.CreateRecordset('MILLENIUM!MORMAIIMKT.PEDIDO_VENDA.PEDIDO_VENDA');
  Response := DataPool.CreateRecordset('MILLENIUM!MORMAIIMKT.PEDIDO_VENDA.VALUE');
  try
    Filial := GetConfigSrv.ReadParamInt('MMKT_FILIAL_PEDIDO_VENDA',0);
    TipoPedidoVenda := GetConfigSrv.ReadParamInt('MMKT_TIPO_PEDIDO',0);
    Transportadoras :=  GetConfigSrv.CreateRecordSet('MMKT_TRANSPORTADORAS');
    TiposPagtos :=  GetConfigSrv.CreateRecordSet('MMKT_TIPOS_PAGTOS');
    CondicaoPagamento := GetConfigSrv.ReadParamInt('MMKT_CONDICOES_PGTO',0);

    Chave := GetConfigSrv.ReadParamStr('MMKT_CHAVE','');
    if not ValidarChaveLicenca(Chave) then
      raise Exception.Create('Chave de licen�a inv�lida.');

    if Filial = 0 then
      raise Exception.Create('Filial n�o configurada');

    if CondicaoPagamento = 0 then
      raise Exception.Create('Condi��o de pagamento n�o configurada');

    if TipoPedidoVenda = 0 then
      raise Exception.Create('Tipo de pedido de venda n�o configurada');

    if Transportadoras = nil then
      raise Exception.Create('N�o h� transportadoras configuradas');

    try
      PostRESTService(Servico,'',True,JsonResponse);
    except on E: Exception do
      raise Exception.Create('Erro solicitando dados '+E.Message);
    end;

    //aqui passar x-http

    try
      FromJson(JsonResponse,Response);
    except on E: Exception do
      raise Exception.Create('Erro convertendo dados '+E.Message);
    end;

    Values := (Response.AsData['VALUE'] as IwtsWriteData);
    while not Values.EOF do
    begin
      PedidoVenda.New;
      for X := 0 to Values.FieldCount-1 do
      begin
        PedidoVenda.SetField(X,Values.GetField(X));
      end;
      PedidoVenda.Add;     
      Values.Next;
    end;
      

    PedidoVenda.First;
    while not PedidoVenda.EOF do                    
    begin
      try
        Cli := '';
        ClientePV := PedidoVenda.AsData['CLIENTES'];
        ProdutosPV := PedidoVenda.AsData['PRODUTOS'] as IwtsWriteData;
        Lancamentos := PedidoVenda.AsData['LANCAMENTOS'];
        EnderecoEntrega := PedidoVenda.AsData['ENDERECO_ENTREGA'];
        CodigoPedidoVenda := PedidoVenda.Value['COD_PEDIDOV'];

        C.Dim('COD_PEDIDOV',CodigoPedidoVenda);
        C.Execute('SELECT PEDIDOV, APROVADO FROM PEDIDO_VENDA WHERE COD_PEDIDOV=:COD_PEDIDOV');
        if not C.EOF then
        begin
          Pedidov := C.Value['PEDIDOV'];
          //Se encontrar pedido de venda e ele n�o estiver aprovado e a nova consulta estiver com pedido aprovado, s� aprovar
          if (not VarToBool(C.Value['APROVADO'])) and VarToBool(PedidoVenda.Value['APROVADO']) then
          begin
            C.Dim('PEDIDOV',Pedidov);
            C.Execute('#CALL MILLENIUM.PEDIDO_VENDA.APROVAR(PEDIDOV=:PEDIDOV);');

            L.Dim('MENSAGEM','Pedido de venda aprovado');
            L.Dim('JSON',JsonResponse);
            L.Dim('NUMERO',CodigoPedidoVenda);
            L.Execute('#CALL MILLENIUM!MORMAIIMKT.LOGS.INCLUIR(MENSAGEM=:MENSAGEM,JSON=:JSON,JSON=:JSON,TIPO=2,NUMERO=:NUMERO)');
          end;
          PedidoVenda.Next;
          Continue;
        end;
                                           
        //Vamos tratar cliente
        try
          C.Dim('CPF',ClientePV.Value['CPF']);
          C.Dim('CNPJ',ClientePV.Value['CNPJ']);
          C.Execute('SELECT CLIENTE FROM CLIENTES WHERE (CPF=:CPF) OR (CNPJ=:CNPJ);');
          if not C.EOF then
          begin
            Cli := C.GetFieldByName('CLIENTE');
            C.Dim('CLIENTE',C.GetFieldByName('CLIENTE'));
            C.Execute('#CALL MILLENIUM.CLIENTES.CONSULTA(CLIENTE=:CLIENTE);');
            Cliente := DataPool.CreateRecordset('MILLENIUM.CLIENTES.ALTERAR');
            Cliente.CopyFrom(C);                             
          end else
            Cliente := DataPool.CreateRecordset('MILLENIUM.CLIENTES.INCLUIR');

          Gerador := Cliente.GetFieldAsData('GERADORES') as IwtsWriteData;
          Endereco := Gerador.GetFieldAsData('ENDERECOS') as IwtsWriteData;
          while not Endereco.EOF do
          begin
            Endereco.SetFieldByName('ENDERECO',1);
            Endereco.SetFieldByName('ENDERECO_ENTREGA',False);
            Endereco.SetFieldByName('ENDERECO_NOTA',False);
            Endereco.SetFieldByName('ENDERECO_COBRANCA',False);
            Endereco.Update;
            Endereco.Next;
          end;

          UpdCli := VarToStr(Cli) <> '';
          UpdEnd := Endereco.Locate(['LOGRADOURO2'],[TratarStrings(EnderecoEntrega.AsString['LOGRADOURO'])]);

          if not UpdEnd then
          begin
            C.Execute('#CALL millenium.utils.default(NOME="COD_ENDERECO",TAM_REQUESTED=FALSE)');
            CodEndereco := C.GetField(0);
            Endereco.New;
            Endereco.SetFieldByName('COD_ENDERECO',CodEndereco);
          end;
          Endereco.SetFieldByName('ENDERECO',0);
          Endereco.SetFieldByName('LOGRADOURO2',TratarStrings(EnderecoEntrega.AsString['LOGRADOURO']));
          Endereco.SetFieldByName('BAIRRO',TratarStrings(EnderecoEntrega.AsString['BAIRRO']));
          Endereco.SetFieldByName('CIDADE2',TratarStrings(EnderecoEntrega.AsString['CIDADE']));
          Endereco.SetFieldByName('ESTADO2',TratarStrings(EnderecoEntrega.AsString['ESTADO']));
          Endereco.SetFieldByName('COMPLEMENTO',TratarStrings(EnderecoEntrega.AsString['COMPLEMENTO']));
          Endereco.SetFieldByName('NUMERO',EnderecoEntrega.AsString['NUMERO']);
          Endereco.SetFieldByName('CEP',EnderecoEntrega.AsString['CEP']);
          Endereco.SetFieldByName('DDD',ExtrairDDDNumeroTelefone(EnderecoEntrega.AsString['TELEFONE']));
          Endereco.SetFieldByName('FONE',ExtrairNumeroTelefone(EnderecoEntrega.AsString['TELEFONE']));
          Endereco.SetFieldByName('ENDERECO_ENTREGA',True);
          Endereco.SetFieldByName('ENDERECO_NOTA',True);
          Endereco.SetFieldByName('ENDERECO_COBRANCA',True);
          if not UpdEnd then
            Endereco.Add
          else
            Endereco.Update;

          CodEnderecoEntrega := Endereco.Value['COD_ENDERECO'];

          if not UpdCli then
            Gerador.New;
          Gerador.SetFieldByName('NOME',TratarStrings(ClientePV.AsString['NOME']));
          Gerador.SetFieldByName('FANTASIA',TratarStrings(ClientePV.AsString['NOME']));
          Gerador.SetFieldByName('PF_PJ',ClientePV.AsString['TIPO_PESSOA']);
          Gerador.SetFieldByName('CPF',ClientePV.AsString['CPF']);
          Gerador.SetFieldByName('CNPJ',ClientePV.AsString['CNPJ']);
          Gerador.SetFieldByName('CGC',ClientePV.AsString['CNPJ']);
          Gerador.SetFieldByName('IE',ClientePV.AsString['IE']);
          Gerador.SetFieldByName('NAOCONTRIBUINTE_ICMS',True);
         // Gerador.SetFieldByName('E_MAIL',);
          Gerador.SetFieldByName('ENDERECOS',Endereco);
          if not UpdCli then
          begin
            Gerador.Add;
            FillDataDefaults(Gerador,'MILLENIUM.GERADORES.GERADORES');
          end else
            Gerador.Update;

          CodCliente := Cliente.GetFieldAsString('COD_CLIENTE');
          if CodCliente='' then
          begin
            C.Execute('#CALL millenium.utils.default(NOME="COD_CLIENTE", TAMANHO=10, TAM_REQUESTED=TRUE)');
            CodCliente := C.GetField(0);
          end;

          if not UpdCli then
            Cliente.New;
          Cliente.SetFieldByName('COD_CLIENTE',CodCliente);
          Cliente.SetFieldByName('GERADORES',Gerador);
          if not UpdCli then
            Cliente.Add
          else
            Cliente.Update;

          if UpdCli then
            Call('MILLENIUM.CLIENTES.ALTERAR',Cliente,'',False)
          else
            Cli := Call('MILLENIUM.CLIENTES.INCLUIR',Cliente,'CLIENTE',True);
        except on E: Exception do
          raise Exception.Create('Erro tratando cliente: '+E.Message);
        end;

        try
          //Vamos sempre  consultar a barra com no m�ximo 12 digitos
          ProdutosPV.First;
          while not ProdutosPV.EOF do
          begin
            Barra := Trim(Copy(ProdutosPV.AsString['EAN'],1,12));

            ProdutosPV.SetFieldByName('EAN',Barra);
            ProdutosPV.Update;
            ProdutosPV.Next;
          end;

          ProdutosPV.First;
          C.DimAsData('PRODUTOS',ProdutosPV);
          C.Execute('SELECT * FROM CODIGO_BARRAS WHERE SUBSTR(BARRA,1,12) IN #MAKELIST(PRODUTOS,EAN)');
          Barras := c.CreateRecordset;

          Produtos := DataPool.CreateRecordset('MILLENIUM.PEDIDO_VENDA.PRODUTOS');
          ProdutosPV.First;
          while not ProdutosPV.EOF do
          begin
            if Barras.Locate(['BARRA'],[ProdutosPV.AsString['EAN']]) then
            begin
              Produtos.New;           
              Produtos.Value['ITEM'] := ProdutosPV.Value['ITEM'];
              Produtos.Value['PRODUTO'] := Barras.Value['PRODUTO'];
              Produtos.Value['COR'] := Barras.Value['COR'];
              Produtos.Value['ESTAMPA'] := Barras.Value['ESTAMPA'];
              Produtos.Value['TAMANHO'] := Barras.Value['TAMANHO'];
              Produtos.Value['QUANTIDADE'] := ProdutosPV.Value['QUANTIDADE'];
              Produtos.Value['PRECO'] := ProdutosPV.Value['VALOR'];
              Produtos.Add;
            end else
              raise Exception.Create('Barra '+ProdutosPV.AsString['EAN']+' n�o localizada');
            ProdutosPV.Next;
          end;
        except on E: Exception do
          raise Exception.Create(E.Message);
        end;

        if VarToStr(PedidoVenda.Value['TRANSPORTADORA_DESC']) = '' then
          raise Exception.Create('Transportadora n�o preenchida no pedido de venda da Mormaii');

        if VarToStr(PedidoVenda.Value['TIPO_FRETE_DESC']) = '' then
          raise Exception.Create('Tipo de frete n�o preenchido no pedido de venda da Mormaii');

        Transportadora := Unassigned;
        if Transportadoras.Locate(['DESC_TRANSPORTADORA'],[PedidoVenda.Value['TRANSPORTADORA_DESC']]) then
          Transportadora := Transportadoras.Value['TRANSPORTADORA']
        else
          raise Exception.Create('Transportadora n�o encontrada para '+VarToStr(PedidoVenda.Value['TRANSPORTADORA_DESC']));

        TipoFrete := Unassigned;
        if Transportadoras.Locate(['DESC_TIPO_FRETE'],[PedidoVenda.Value['TIPO_FRETE_DESC']]) then
          TipoFrete := Transportadoras.Value['TIPO_FRETE']
        else
          raise Exception.Create('Tipo de frete n�o encontrada para '+VarToStr(PedidoVenda.Value['TIPO_FRETE_DESC']));

        //  TRATRAR LANCAMENTO

        LancamentosPV := DataPool.CreateRecordset('MILLENIUM.EVENTOS.LANCAMENTOS');
        {LancamentosPV.New;
        LancamentosPV.Value['DOCUMENTO'] := PedidoVenda.Value['COD_PEDIDOV'];
        LancamentosPV.Value['DATA_VENCIMENTO'] := Date;
        LancamentosPV.Value['VALOR_INICIAL'] := PedidoVenda.Value['VALOR_TOTAL'];
        LancamentosPV.Value['TIPO_PGTO'] := 2;
        LancamentosPV.Value['ADIANTAMENTO'] := False;
        LancamentosPV.Value['PREVISAO'] := False;
        LancamentosPV.Value['CREDITO'] := 0;
        LancamentosPV.Value['LANCREDITO'] := False;
        LancamentosPV.Add;}

        //FORMA_PAGAMENTO
        //VALOR

        PVIncluir := DataPool.CreateRecordset('MILLENIUM.PEDIDO_VENDA.INCLUI');

        PVIncluir.New;
        PVIncluir.Value['FILIAL'] := Filial;
        PVIncluir.Value['TIPO_PEDIDO'] := TipoPedidoVenda;
        PVIncluir.Value['COD_PEDIDOV'] := PedidoVenda.Value['COD_PEDIDOV'];
        PVIncluir.Value['N_PEDIDO_CLIENTE'] := PedidoVenda.Value['N_PEDIDO_CLIENTE'];
        PVIncluir.Value['DATA_EMISSAO'] := PedidoVenda.Value['DATA_EMISSAO'];
        PVIncluir.Value['DATA_ENTREGA'] := PedidoVenda.Value['DATA_ENTREGA'];
        PVIncluir.Value['CLIENTE'] := Cli;
        PVIncluir.Value['COD_ENDERECO'] := CodEnderecoEntrega;
        PVIncluir.Value['TRANSPORTADORA'] := Transportadora;
        PVIncluir.Value['TIPO_FRETE'] := TipoFrete;
        PVIncluir.Value['MODALIDADE_FRETE'] := PedidoVenda.Value['MODALIDADE_FRETE'];
        PVIncluir.Value['V_FRETE'] := PedidoVenda.Value['VALOR_FRETE'];
        PVIncluir.Value['PRODUTOS'] := Produtos.Data;
        PVIncluir.Value['LANCAMENTOS'] := LancamentosPV.Data;
        PVIncluir.Value['TOTAL'] := PedidoVenda.Value['VALOR_TOTAL'];
        PVIncluir.Value['APROVADO'] := VarToBool(PedidoVenda.Value['APROVADO']);
        PVIncluir.Value['CONDICOES_PGTO'] := CondicaoPagamento;
        PVIncluir.Add;

        Pedidov := Call('MILLENIUM.PEDIDO_VENDA.INCLUI',PVIncluir,'PEDIDOV',True);

        LogMsg := 'Pedido de venda importado com sucesso';
        if not PVIncluir.Value['APROVADO'] then
          LogMsg := LogMsg+', mas n�o aprovado';

        L.Dim('MENSAGEM',LogMsg);
        L.Dim('JSON',JsonResponse);
        L.Dim('NUMERO',CodigoPedidoVenda);
        L.Execute('#CALL MILLENIUM!MORMAIIMKT.LOGS.INCLUIR(MENSAGEM=:MENSAGEM,JSON=:JSON,JSON=:JSON,TIPO=2,NUMERO=:NUMERO)');
      except on E: Exception do
        begin
          L.Dim('MENSAGEM',E.Message);
          L.Dim('JSON',JsonResponse);
          L.Dim('NUMERO',CodigoPedidoVenda);
          L.Execute('#CALL MILLENIUM!MORMAIIMKT.LOGS.INCLUIR(MENSAGEM=:MENSAGEM,JSON=:JSON,JSON=:JSON,TIPO=2,NUMERO=:NUMERO)');
        end;
      end;

      PedidoVenda.Next;
    end;
  except on E: Exception do
    begin
      L.Dim('MENSAGEM','Erro processamento pedido de venda '+E.Message);
      L.Dim('JSON',JsonResponse);
      L.Execute('#CALL MILLENIUM!MORMAIIMKT.LOGS.INCLUIR(MENSAGEM=:MENSAGEM,JSON=:JSON,TIPO=2)');
    end;
  end;
end;

initialization
   wtsRegisterProc('PEDIDO_VENDA.Receber',Receber);

end.

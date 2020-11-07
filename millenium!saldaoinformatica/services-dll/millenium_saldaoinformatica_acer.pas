unit millenium_saldaoinformatica_acer;

interface

uses
  Windows, Classes, wtsServerObjs, SysUtils, ServerCfgs, millenium_variants,
  XMLAcer,wtsIntf,EcoUtils,ComObj,ActiveX,Excel2000,millennium_uteis,checkcgc,
  logfiles, Variants, contnrs;

type
  TPecaFaturamento = (pfEquipamentos,ptPecasGarantia,ptPecasForaGarantia);
  TPecasFaturamento = set of TPecaFaturamento;

  TLote = class
    Numero: string;
    Quantidade: Integer;
  end;

  TLotes = class(TObjectList)
  private
    function GetItem(Index: Integer): TLote;
  public
    function Add(ANumero: string; AQuantidade: Integer): TLote;
    property Items[Index: Integer]: TLote read GetItem; default;
  end;

implementation

procedure AssignXMLACER(APath: string; AFiles: TStringList);
var
  F: TSearchRec;
  Ret: Integer;
  function TemAtributo(Attr, Val: Integer): Boolean;
  begin
    Result := Attr and Val = Val;
  end;
begin
  Ret := FindFirst(LowerCase(APath+'*.xml'), faAnyFile, F);
  try
    while Ret = 0 do
    begin
      if TemAtributo(F.Attr, faArchive) then
      begin
        if (F.Name <> '.') and (F.Name <> '..') then
          AFiles.Add(APath+F.Name);
      end;
      Ret := FindNext(F);
    end;                        
  finally
    FindClose(F);
  end;
end;

procedure ImportarArquivosXML(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C: IwtsCommand;
  AcerXML:TAcerXML;
  TicketEventHeader:TTicketEventHeader;
  TicketEventDetails:TTicketEventDetails;
  TicketEventDetail:TTicketEventDetail;
  I,X,J,EventHeader:Integer;
  Files,SL:TStringList;
  S:string;
begin
  C := DataPool.Open('MILLENIUM');

  Files := TStringList.Create;
  try
    AssignXMLACER(ExtractFilePath(ParamStr(0))+'css_files\',Files);
    for X := 0 to Files.Count-1 do
    begin
      try
        AcerXML := TAcerXML.Create;
        try
          AcerXML.LoadFromFile(Files[X]);
          for I := 0 to AcerXML.TicketEventHeaders.Count-1 do
          begin
            TicketEventHeader := AcerXML.TicketEventHeaders.Items[I];

            C.Dim('EVENTTYPE',TicketEventHeader.EventType);
            C.Dim('CUSTOMERNAME',TicketEventHeader.CustomerName);
            C.Dim('CUSTOMERADDRESS',TicketEventHeader.CustomerAddress);
            C.Dim('ADDRESS2',TicketEventHeader.Address2);
            C.Dim('DISTRICT',TicketEventHeader.District);
            C.Dim('CUSTOMERSTATE',TicketEventHeader.CustomerState);
            C.Dim('CITY',TicketEventHeader.City);
            C.Dim('ZIPCODE',TicketEventHeader.ZipCode);
            C.Dim('CUSTOMERTYPE',TicketEventHeader.CustomerType);
            C.Dim('CPFCNPJNUMBER',TicketEventHeader.CPFCNPJNumber);
            C.Dim('STATEREGNUMBER',TicketEventHeader.StateRegNumber);
            C.Dim('PHONENUMBER',TicketEventHeader.PhoneNumber);
            C.Dim('EMAIL',TicketEventHeader.Email);
            C.Dim('CSSTICKETNUMBER',TicketEventHeader.CSSTicketNumber);
            C.Dim('WARRANTYSTATUS',TicketEventHeader.WarrantyStatus);
            C.Dim('XMLFILENAME',AcerXML.TicketEventTrailer.XMLFileName);
            C.Dim('ACKSTATUS','0');
            C.Dim('ACKREMARKS',Unassigned);
            C.Execute('INSERT INTO ACER_TICKETEVENTHEADER(EVENTTYPE,CUSTOMERNAME,CUSTOMERADDRESS,ADDRESS2,DISTRICT,CUSTOMERSTATE,CITY,ZIPCODE,CUSTOMERTYPE, '+
                      '                                   CPFCNPJNUMBER,STATEREGNUMBER,PHONENUMBER,EMAIL,CSSTICKETNUMBER,WARRANTYSTATUS,XMLFILENAME,ACKSTATUS,ACKREMARKS,DATA) '+
                      '                            VALUES(:EVENTTYPE,:CUSTOMERNAME,:CUSTOMERADDRESS,:ADDRESS2,:DISTRICT,:CUSTOMERSTATE,:CITY,:ZIPCODE,:CUSTOMERTYPE, '+
                      '                                   :CPFCNPJNUMBER,:STATEREGNUMBER,:PHONENUMBER,:EMAIL,:CSSTICKETNUMBER, :WARRANTYSTATUS,:XMLFILENAME,:ACKSTATUS,:ACKREMARKS,#NOW()) '+
                      '                           #RETURN(EVENTHEADER); ');
            EventHeader := C.GetFieldByName('EVENTHEADER');
          
            TicketEventDetails := TicketEventHeader.TicketEventDetails;
            for J := 0 to TicketEventDetails.Count-1 do
            begin
              TicketEventDetail := TicketEventDetails.Items[J];

              C.Dim('EVENTHEADER',EventHeader);
              C.Dim('SEQUENCENO',TicketEventDetail.SequenceNo);
              C.Dim('FROMWAREHOUSE',TicketEventDetail.FromWarehouse);
              C.Dim('TOWAREHOUSE',TicketEventDetail.ToWareHouse);
              C.Dim('PRODUCTNUMBER',TicketEventDetail.ProductNumber);
              C.Dim('QUANTITY',TicketEventDetail.Quantity);
              C.Dim('SERIALNUMBER',TicketEventDetail.SerialNumber);
              C.Dim('UNITPRICE',TicketEventDetail.UnitPrice);
              C.Execute('INSERT INTO ACER_TICKETEVENTDETAIL(EVENTHEADER,SEQUENCENO,FROMWAREHOUSE,TOWAREHOUSE,PRODUCTNUMBER,QUANTITY,SERIALNUMBER,UNITPRICE) '+
                        '                           VALUES (:EVENTHEADER,:SEQUENCENO,:FROMWAREHOUSE,:TOWAREHOUSE,:PRODUCTNUMBER,:QUANTITY,:SERIALNUMBER,:UNITPRICE) '+
                        '                           #RETURN(EVENTDETAIL)');
            end;          
          end;
          MoveFile(PChar(Files[X]),PChar(ExtractFilePath(ParamStr(0))+'css_files\processed\'+FormatDateTime('YYYYMMDDHHNNSSZZZ',NOW)+ExtractFileName(Files[X])));
        finally
          AcerXML.Free;
        end;
      except on e: exception do
        begin
          S := ExtractFilePath(ParamStr(0))+'css_files\error\'+ExtractFileName(Files[X]); 
          MoveFile(PChar(Files[X]),PChar(S));
          SL := TStringList.Create;
          SL.Add(E.Message);
          SL.SaveToFile(S+'.log');
          SL.Free;
        end;
      end;  
    end;
  finally
    Files.Free;
  end;
  try
    C.Execute('#CALL MILLENIUM!ACER.WS.UPDATETICKETACKSTATUS();');
  except
  end;  
end;

function ConsultaProdutoPorBarra(const ABarra: string; var AProduto,ACor,Estampa,ATamanho: Variant): Boolean;
var
  C: IwtsCommand;
begin
  Result := False;
  AProduto := Unassigned;
  ACor := Unassigned;
  Estampa := Unassigned;
  ATamanho := Unassigned;
  C := CurrentDatapool.Open('MILLENIUM');
  C.Dim('BARRA',ABarra);
  C.Execute('SELECT PRODUTO, COR, ESTAMPA, TAMANHO FROM CODIGO_BARRAS WHERE BARRA=:BARRA');
  if not C.EOF then
  begin
    AProduto := C.GetFieldByName('PRODUTO');
    ACor := C.GetFieldByName('COR');
    Estampa := C.GetFieldByName('ESTAMPA');
    ATamanho := C.GetFieldByName('TAMANHO');
    Result := True;
  end;
end;

procedure ImportarOrdens(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C,T: IwtsCommand;
  Produtos, Equipamentos: IwtsWriteData;
  OS:Integer;
begin
  C := DataPool.Open('MILLENIUM');
  T := DataPool.Open('MILLENIUM');
  
  Produtos := DataPool.CreateRecordset('MILLENIUM!SALDAOINFORMATICA.ORDENS_SERVICO.PRODUTO');
  Equipamentos := DataPool.CreateRecordset('MILLENIUM!SALDAOINFORMATICA.ORDENS_SERVICO.PRODUTO');

  T.Execute('SELECT DISTINCT T.EVENTHEADER,T.CSSTICKETNUMBER,T.WARRANTYSTATUS,D.PRODUCTNUMBER,D.QUANTITY,D.SERIALNUMBER,D.UNITPRICE,T.MSG_ERROR FROM ACER_TICKETEVENTHEADER T '+
            'INNER JOIN ACER_TICKETEVENTDETAIL D ON (D.EVENTHEADER = T.EVENTHEADER) '+
            'WHERE UPPER(T.EVENTTYPE) = "INBOUND" AND ORDEM_SERVICO IS NULL ');
  while not T.EOF do
  begin
    Equipamentos.Clear;
    Equipamentos.New;
    Equipamentos.SetFieldByName('NUMERO_PRODUTO',T.GetFieldByName('PRODUCTNUMBER'));
    Equipamentos.SetFieldByName('QUANTIDADE',T.GetFieldByName('QUANTITY'));
    Equipamentos.SetFieldByName('NUMERO_SERIE',T.GetFieldByName('SERIALNUMBER'));
    Equipamentos.SetFieldByName('PRECO', T.GetFieldByName('UNITPRICE'));
    Equipamentos.SetFieldByName('PRODUTO',Unassigned);
    Equipamentos.SetFieldByName('COR',Unassigned);
    Equipamentos.SetFieldByName('ESTAMPA',Unassigned);
    Equipamentos.SetFieldByName('TAMANHO',Unassigned);
    Equipamentos.Add;

    C.Dim('COD_ORDEM_SERVICO',T.GetFieldAsString('CSSTICKETNUMBER'));
    C.Dim('DATA_ABERTURA',Date);
    C.Dim('CLIENTE',Unassigned);
    C.Dim('GARANTIA',SameText(T.GetFieldAsString('WARRANTYSTATUS'),'IN WARRANTY'));
    C.Dim('OBSERVACAO',Unassigned);
    C.Dim('STATUS',1);//AG. FATURAMENTO ENTRADA
    C.Dim('ORIGEM','ACER');
    C.Dim('MSG_ERROR',T.GetFieldAsString('MSG_ERROR'));
    C.DimAsData('EQUIPAMENTOS',Equipamentos);
    C.DimAsData('PRODUTOS',Produtos);
    C.Execute('#CALL MILLENIUM!SALDAOINFORMATICA.ORDENS_SERVICO.Incluir(COD_ORDEM_SERVICO=:COD_ORDEM_SERVICO,'+
              '    DATA_ABERTURA=:DATA_ABERTURA,CLIENTE=:CLIENTE,GARANTIA=:GARANTIA,OBSERVACAO=:OBSERVACAO,STATUS=:STATUS,ORIGEM=:ORIGEM, '+
              '    EQUIPAMENTOS=:EQUIPAMENTOS,PRODUTOS=:PRODUTOS,OBSERVACAO=:MSG_ERROR);');
    OS := C.GetFieldByName('ORDEM_SERVICO');

    C.Dim('ORDEM_SERVICO',OS);
    C.Dim('EVENTHEADER',T.GetFieldByName('EVENTHEADER'));
    C.Execute('UPDATE ACER_TICKETEVENTHEADER SET ORDEM_SERVICO=:ORDEM_SERVICO WHERE EVENTHEADER=:EVENTHEADER');

    C.Dim('ORDEM_SERVICO',OS);
    C.Execute('#CALL MILLENIUM!SALDAOINFORMATICA.ORDENS_SERVICO.ReavaliarRelacionamentos(ORDEM_SERVICO=:ORDEM_SERVICO);');

    T.Next;
  end;

end;

function TratarStrings(const AValue:string):string;
begin
  Result := RemoveAcentos(AValue);
  Result := UpperCase(Result);
end;

function RemoveChar(const AValue:string):string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(AValue) do
    if AValue[I] in ['0'..'9'] then
      Result := Result + AValue[I];
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

procedure SplitLogradouroNumero(const AEndereco: string; var ALogradouro: string; var ANumero: string);
var
  I: Integer;
begin
  ALogradouro := AEndereco;
  ANumero := '';
  I := LastDelimiter(',',AEndereco);
  if (I > 0) then
  begin
    ALogradouro := Copy(AEndereco, 1, I-1);
    ANumero := Copy(AEndereco, I+1, MaxInt);
  end;
end;

procedure ReavaliarRelacionamentos(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C,T,P: IwtsCommand;
  Cliente,Gerador,Endereco: IwtsWriteData;
  Cli:Variant;
  CodCliente:string;
  CodEndereco: Integer;
  UpdCli,UpdEnd: Boolean;
  Prod,Cor,Est,Tam,ClassCli:Variant;
  Problemas: TStringList;
  CPFCNPJFormartado: string;
  Logradouro, Numero: string;

  function FormatarCPFCNPJ(const AValue:string):string;
  var
    S: string;
  begin
    S := RemoveChar(AValue);
    if Length(S) = 11 then
      Result := Copy(S,1,3) + '.' + Copy(S,4,3) + '.' + Copy(S,7,3) + '-' + Copy(S,10,2)
    else
      Result := Copy(S,1,2) + '.' + Copy(S,3,3) + '.' + Copy(S,6,3) + '/' + Copy(S,9,4) + '-' + Copy(S,13,2)
  end;

begin
  C := DataPool.Open('MILLENIUM');
  p := DataPool.Open('MILLENIUM');
  T := DataPool.Open('MILLENIUM');
  Problemas := TStringList.Create;
  
  try
    T.Execute('SELECT * FROM ACER_TICKETEVENTHEADER T '+
              'INNER JOIN ACER_TICKETEVENTDETAIL D ON (D.EVENTHEADER = T.EVENTHEADER) '+
              'WHERE ORDEM_SERVICO=:ORDEM_SERVICO ');

   SplitLogradouroNumero(TratarStrings(T.GetFieldAsString('CUSTOMERADDRESS')),Logradouro, Numero);


    ClassCli := Unassigned;
    C.Dim('COD_CLSCLIENTE',T.GetFieldAsString('CUSTOMERTYPE'));
    C.Execute('SELECT CLSCLIENTE FROM CLASSIFICACAO_CLIENTE WHERE COD_CLSCLIENTE=:COD_CLSCLIENTE');
    if not C.EOF then
      ClassCli := C.GetFieldByName('CLSCLIENTE');


    //Tratando cliente
    C.Execute('SELECT CLIENTE FROM SI_ORDENS_SERVICO WHERE ORDEM_SERVICO=:ORDEM_SERVICO ');//AND CLIENTE IS NULL
    if not C.EOF then
    begin
      try
        Cli := C.GetFieldByName('CLIENTE');

        if VarIsValid(Cli) then
        begin
          C.Dim('CLIENTE',Cli);
          C.Execute('SELECT CLIENTE,PF_PJ,CPF,CNPJ FROM CLIENTES WHERE (CLIENTE=:CLIENTE);');
          if C.GetFieldAsString('PF_PJ') = 'PF' then
            CPFCNPJFormartado := C.GetFieldAsString('CPF')
          else
            CPFCNPJFormartado := Copy(C.GetFieldAsString('CNPJ'),2,MaxInt);
        end else
        begin
          CPFCNPJFormartado := FormatarCPFCNPJ(T.GetFieldAsString('CPFCNPJNUMBER'));

          if Length(CPFCNPJFormartado) = 14 then
          begin
            C.Dim('CPF_CNPJ',CPFCNPJFormartado);
            C.Execute('SELECT CLIENTE FROM CLIENTES WHERE (CPF=:CPF_CNPJ);');
          end else
          begin
            C.Dim('CPF_CNPJ',CPFCNPJFormartado);
            C.Execute('SELECT CLIENTE FROM CLIENTES WHERE (CNPJ=:CPF_CNPJ) OR (CGC=:CPF_CNPJ);');
          end;
        end;

        if (Length(CPFCNPJFormartado)<>14) and (Length(CPFCNPJFormartado)<>18) and (Length(CPFCNPJFormartado)<>19) then
          raise Exception.Create('CPF\CNPJ Inv�lido '+CPFCNPJFormartado);

        try
          ValidaCPFCNPJ(CPFCNPJFormartado);
        except on e: Exception do
          Problemas.Add(E.Message);
        end;

        if not C.EOF then
        begin
          Cli := C.GetFieldByName('CLIENTE');
          C.Dim('CLIENTE',Cli);
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
        UpdEnd := Endereco.Locate(['LOGRADOURO2'],[TratarStrings(Logradouro)]);

        if not UpdEnd then
        begin
          C.Execute('#CALL millenium.utils.default(NOME="COD_ENDERECO",TAM_REQUESTED=FALSE)');
          CodEndereco := C.GetField(0);
          Endereco.New;
          Endereco.SetFieldByName('COD_ENDERECO',CodEndereco);
        end;
        Endereco.SetFieldByName('ENDERECO',0);
        Endereco.SetFieldByName('LOGRADOURO2',Logradouro);
        Endereco.SetFieldByName('BAIRRO',TratarStrings(T.GetFieldAsString('DISTRICT')));
        Endereco.SetFieldByName('CIDADE',TratarStrings(T.GetFieldAsString('CITY')));
        Endereco.SetFieldByName('ESTADO',TratarStrings(T.GetFieldAsString('CUSTOMERSTATE')));
        Endereco.SetFieldByName('NUMERO',Numero);
        Endereco.SetFieldByName('COMPLEMENTO',TratarStrings(T.GetFieldAsString('ADDRESS2')));
        Endereco.SetFieldByName('CEP',RemoveChar(T.GetFieldAsString('ZIPCODE')));
        Endereco.SetFieldByName('DDD',ExtrairDDDNumeroTelefone(T.GetFieldAsString('PHONENUMBER')));
        Endereco.SetFieldByName('FONE',ExtrairNumeroTelefone(T.GetFieldAsString('PHONENUMBER')));
        Endereco.SetFieldByName('ENDERECO_ENTREGA',True);
        Endereco.SetFieldByName('ENDERECO_NOTA',True);
        Endereco.SetFieldByName('ENDERECO_COBRANCA',True);
        Endereco.SetFieldByName('PAIS',0);
        if not UpdEnd then
          Endereco.Add
        else
          Endereco.Update;

        if not UpdCli then
          Gerador.New;
        Gerador.SetFieldByName('NOME',TratarStrings(T.GetFieldAsString('CUSTOMERNAME')));
        Gerador.SetFieldByName('FANTASIA',TratarStrings(T.GetFieldAsString('CUSTOMERNAME')));
        if Length(CPFCNPJFormartado) = 14 then
        begin
          Gerador.SetFieldByName('PF_PJ','PF');
          Gerador.SetFieldByName('CPF',CPFCNPJFormartado);
        end else
        begin
          Gerador.SetFieldByName('PF_PJ','PJ');
          Gerador.SetFieldByName('CNPJ',CPFCNPJFormartado);
          Gerador.SetFieldByName('CGC',CPFCNPJFormartado);
          Gerador.SetFieldByName('IE',T.GetFieldAsString('STATEREGNUMBER'));
          if not UpdCli then
            Gerador.SetFieldByName('NAOCONTRIBUINTE_ICMS',T.GetFieldAsString('CUSTOMERTYPE')<>'T2S');//Ligar para todos, com exce��o aos clientes varejo
        end;
        Gerador.SetFieldByName('E_MAIL',T.GetFieldAsString('EMAIL'));
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
        Cliente.SetFieldByName('CLSCLIENTE',ClassCli);
        if not UpdCli then
          Cliente.Add
        else
          Cliente.Update;

        if UpdCli then
          Call('MILLENIUM.CLIENTES.ALTERAR',Cliente,'',False)
        else
          Cli := Call('MILLENIUM.CLIENTES.INCLUIR',Cliente,'CLIENTE',True);

      except on e: Exception do
        Problemas.Add('N�O FOI POSS�VEL CADASTRAR OU ATUALIZAR CLIENTE. MOTIVO: '+E.Message);
      end;
    end;

    //Encontrando equipamento
    P.Execute('SELECT * FROM SI_ORDENS_SERVICO_PRODUTOS WHERE ORDEM_SERVICO=:ORDEM_SERVICO AND PRODUTO IS NULL');
    while not P.EOF do
    begin
      if ConsultaProdutoPorBarra(P.GetFieldAsString('NUMERO_PRODUTO'),Prod,Cor,Est,Tam) then
      begin
        C.Dim('ORDENS_SERVICO_PRODUTO',P.GetFieldByName('ORDENS_SERVICO_PRODUTO'));
        C.Dim('PRODUTO',Prod);
        C.Dim('COR',Cor);
        C.Dim('ESTAMPA',Est);
        C.Dim('TAMANHO',Tam);
        C.Execute('UPDATE SI_ORDENS_SERVICO_PRODUTOS SET PRODUTO=:PRODUTO, COR=:COR, ESTAMPA=:ESTAMPA, TAMANHO=:TAMANHO WHERE ORDENS_SERVICO_PRODUTO=:ORDENS_SERVICO_PRODUTO');
      end else
        Problemas.Add('PRODUTO "'+P.GetFieldAsString('NUMERO_PRODUTO')+'" N�O ENCONTRADO');
      P.Next;
    end;    

    C.Dim('CLIENTE',Cli);
    C.Dim('ERRO',Problemas.Count>0);
    C.Dim('PROBLEMAS',Problemas.Text);
    C.Execute('UPDATE SI_ORDENS_SERVICO SET [CLIENTE=:CLIENTE,] ERRO=:ERRO,PROBLEMAS=:PROBLEMAS WHERE ORDEM_SERVICO=:ORDEM_SERVICO');
  finally
    Problemas.Free;
  end;
end;

procedure ImportarProdutos(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C,T: IwtsCommand;
begin
  C := DataPool.Open('MILLENIUM');
  T := DataPool.Open('MILLENIUM');

  //Por garantia do processo, s� vou importar as pe�as consumidas na manuten��o se a O.S estiver com status=2 (AG. REPARO ou EM REPARO)
  T.Execute('SELECT T.EVENTHEADER,T.EVENTTYPE,D.*,OS.ORDEM_SERVICO '+
            'FROM ACER_TICKETEVENTHEADER T '+
            'INNER JOIN ACER_TICKETEVENTDETAIL D ON (D.EVENTHEADER = T.EVENTHEADER) '+
            'INNER JOIN SI_ORDENS_SERVICO OS ON (OS.COD_ORDEM_SERVICO = T.CSSTICKETNUMBER) '+
            'WHERE (UPPER(T.EVENTTYPE) IN ("ISSUE","UNISSUE")) AND T.ORDEM_SERVICO IS NULL AND OS.STATUS IN (2,3)');
  while not T.EOF do
  begin
    C.Dim('ORDEM_SERVICO',T.GetFieldByName('ORDEM_SERVICO'));
    C.Dim('PRODUTO',Unassigned);
    C.Dim('COR',Unassigned);
    C.Dim('ESTAMPA',Unassigned);
    C.Dim('TAMANHO',Unassigned);
    C.Dim('NUMERO_PRODUTO',T.GetFieldAsString('PRODUCTNUMBER'));
    
    if SameText(T.GetFieldAsString('EVENTTYPE'),'UNISSUE') then
      C.Dim('QUANTIDADE',VarToIntDef(T.GetFieldAsString('QUANTITY'),1)*-1)
    else
      C.Dim('QUANTIDADE',VarToIntDef(T.GetFieldAsString('QUANTITY'),1));

    C.Dim('NUMERO_SERIE',T.GetFieldAsString('SERIALNUMBER'));
    C.Dim('PRECO', T.GetFieldByName('UNITPRICE'));

    //Pe�as que ser�o cobradas, os demais, s�o somente movimetna��o de estoque
    if SameText(T.GetFieldAsString('EVENTTYPE'),'ISSUE') or (SameText(T.GetFieldAsString('EVENTTYPE'),'UNISSUE') and
                                                              ((T.GetFieldAsString('TOWAREHOUSE')='301') or
                                                               (T.GetFieldAsString('TOWAREHOUSE') = '503'))) then
      C.Dim('EQUIPAMENTO','F')
    else
      C.Dim('EQUIPAMENTO','O');
    C.Dim('ESTOQUE_ORIGEM',T.GetFieldByName('FROMWAREHOUSE'));
    C.Dim('ESTOQUE_DESTINO',T.GetFieldByName('TOWAREHOUSE'));
    C.Execute('INSERT INTO SI_ORDENS_SERVICO_PRODUTOS (ORDEM_SERVICO,PRODUTO,COR,ESTAMPA,TAMANHO,NUMERO_PRODUTO,QUANTIDADE,NUMERO_SERIE,PRECO,EQUIPAMENTO,DATA,ESTOQUE_ORIGEM,ESTOQUE_DESTINO) '+
              '                                 VALUES(:ORDEM_SERVICO,:PRODUTO,:COR,:ESTAMPA,:TAMANHO,:NUMERO_PRODUTO,:QUANTIDADE,:NUMERO_SERIE,:PRECO,:EQUIPAMENTO,#NOW(),:ESTOQUE_ORIGEM,:ESTOQUE_DESTINO) '+
              '                                 #RETURN(ORDENS_SERVICO_PRODUTO)');

    //3=EM REPARO
    C.Dim('ORDEM_SERVICO',T.GetFieldByName('ORDEM_SERVICO'));
    C.Execute('UPDATE SI_ORDENS_SERVICO SET STATUS = 3 WHERE ORDEM_SERVICO=:ORDEM_SERVICO');

    C.Dim('EVENTHEADER',T.GetFieldByName('EVENTHEADER'));
    C.Dim('ORDEM_SERVICO',T.GetFieldByName('ORDEM_SERVICO'));
    C.Execute('UPDATE ACER_TICKETEVENTHEADER SET ORDEM_SERVICO=:ORDEM_SERVICO WHERE EVENTHEADER=:EVENTHEADER');

    C.Dim('ORDEM_SERVICO',T.GetFieldByName('ORDEM_SERVICO'));
    C.Execute('#CALL MILLENIUM!SALDAOINFORMATICA.ORDENS_SERVICO.ReavaliarRelacionamentos(ORDEM_SERVICO=:ORDEM_SERVICO);');

    T.Next;
  end;
end;

procedure ImportarFechamento(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  E,C,T: IwtsCommand;
  Gerador,Cliente,Endereco: IwtsWriteData;
  ExisteEndereco: Boolean;
  CodEndereco: Integer;
  Logradouro, Numero: string;
begin
  C := DataPool.Open('MILLENIUM');
  E := DataPool.Open('MILLENIUM');

  T := DataPool.Open('MILLENIUM');

  //Por garantia do processo, s� vou fechar a ordem de servi�o, se ela estiver com status=2,3 (AG. REPARO ou EM REPARO)
  //AG. REPARO. Porque podemos fechar sem o reparo.
  //Caso exista Issue e UnIssue ��o processado, n�o vamos importar os OutBound 
  T.Execute('SELECT T.EVENTHEADER,T.CUSTOMERADDRESS, T.DISTRICT,T.CITY,T.CUSTOMERSTATE,T.ADDRESS2,T.ZIPCODE,T.PHONENUMBER,OS.ORDEM_SERVICO, OS.CLIENTE '+
            'FROM ACER_TICKETEVENTHEADER T '+
            'INNER JOIN ACER_TICKETEVENTDETAIL D ON (D.EVENTHEADER = T.EVENTHEADER) '+
            'INNER JOIN SI_ORDENS_SERVICO OS ON (OS.COD_ORDEM_SERVICO = T.CSSTICKETNUMBER) '+
            'WHERE UPPER(T.EVENTTYPE) IN ("OUTBOUND") AND '+
            '      T.ORDEM_SERVICO IS NULL AND '+
            '      OS.STATUS IN (2,3) AND '+
            '      OS.ERRO = FALSE AND '+
            '      NOT EXISTS (SELECT 1 FROM ACER_TICKETEVENTHEADER I '+
            '                  WHERE I.CSSTICKETNUMBER = T.CSSTICKETNUMBER AND '+
            '                        UPPER(I.EVENTTYPE) IN ("ISSUE","UNISSUE") AND '+
            '                        I.ORDEM_SERVICO IS NULL)');
  T.First;
  while not T.EOF do
  begin
    try
      AddLog(0,'Processando fechamento ='+T.AsString['ORDEM_SERVICO'],'SI');

      SplitLogradouroNumero(TratarStrings(T.GetFieldAsString('CUSTOMERADDRESS')),Logradouro, Numero);
      AddLog(0,'Processando Logradouro ='+Logradouro,'SI');

      //Atualizar o endereco do cliente
      C.Dim('CLIENTE',T.GetFieldByName('CLIENTE'));
      C.Execute('#CALL MILLENIUM.CLIENTES.CONSULTA(CLIENTE=:CLIENTE);');
      Cliente := DataPool.CreateRecordset('MILLENIUM.CLIENTES.ALTERAR');
      Cliente.CopyFrom(C);

      Gerador := Cliente.GetFieldAsData('GERADORES') as IwtsWriteData;
      Endereco := Gerador.GetFieldAsData('ENDERECOS') as IwtsWriteData;


      ExisteEndereco := Endereco.Locate(['LOGRADOURO2'],[TratarStrings(Logradouro)]);

      AddLog(0,'Processando ExisteEndereco ='+VarToStr(ExisteEndereco),'SI');


      //Temos esse endereco no cliente?
      if not ExisteEndereco then
      begin
        AddLog(0,'Endere�o n�o existe','SI');

        Endereco.First;
        while not Endereco.EOF do
        begin
          Endereco.SetFieldByName('ENDERECO',1);
          Endereco.SetFieldByName('ENDERECO_ENTREGA',False);
          Endereco.SetFieldByName('ENDERECO_NOTA',False);
          Endereco.SetFieldByName('ENDERECO_COBRANCA',False);
          Endereco.Update;
          Endereco.Next;
        end;

        C.Execute('#CALL millenium.utils.default(NOME="COD_ENDERECO",TAM_REQUESTED=FALSE)');
        CodEndereco := C.GetField(0);
        Endereco.New;
        Endereco.SetFieldByName('COD_ENDERECO',CodEndereco);
        Endereco.SetFieldByName('ENDERECO',0);
        Endereco.SetFieldByName('LOGRADOURO2',Logradouro);
        Endereco.SetFieldByName('BAIRRO',TratarStrings(T.GetFieldAsString('DISTRICT')));
        Endereco.SetFieldByName('CIDADE',TratarStrings(T.GetFieldAsString('CITY')));
        Endereco.SetFieldByName('ESTADO',TratarStrings(T.GetFieldAsString('CUSTOMERSTATE')));
        Endereco.SetFieldByName('COMPLEMENTO',TratarStrings(T.GetFieldAsString('ADDRESS2')));
        Endereco.SetFieldByName('NUMERO',Numero);
        Endereco.SetFieldByName('CEP',RemoveChar(T.GetFieldAsString('ZIPCODE')));
        Endereco.SetFieldByName('DDD',ExtrairDDDNumeroTelefone(T.GetFieldAsString('PHONENUMBER')));
        Endereco.SetFieldByName('FONE',ExtrairNumeroTelefone(T.GetFieldAsString('PHONENUMBER')));
        Endereco.SetFieldByName('ENDERECO_ENTREGA',True);
        Endereco.SetFieldByName('ENDERECO_NOTA',True);
        Endereco.SetFieldByName('ENDERECO_COBRANCA',True);
        Endereco.SetFieldByName('PAIS',0);
        Endereco.Add;

        Gerador.SetFieldByName('ENDERECOS',Endereco);
        Cliente.SetFieldByName('GERADORES',Gerador);
        Cliente.Update;


        AddLog(0,'Alterar cliente','SI');
        Call('MILLENIUM.CLIENTES.ALTERAR',Cliente,'',False);
        AddLog(0,'Cliente alterado','SI');
        AddLog(0,'Processado fechamento ='+T.AsString['ORDEM_SERVICO'],'SI');
      end;
      C.Dim('ORDEM_SERVICO',T.GetFieldByName('ORDEM_SERVICO'));//4=AG. FATURAMENTO
      C.Execute('UPDATE SI_ORDENS_SERVICO SET STATUS = 4 WHERE ORDEM_SERVICO=:ORDEM_SERVICO');

      C.Dim('EVENTHEADER',T.GetFieldByName('EVENTHEADER'));
      C.Dim('ORDEM_SERVICO',T.GetFieldByName('ORDEM_SERVICO'));
      C.Execute('UPDATE ACER_TICKETEVENTHEADER SET ORDEM_SERVICO=:ORDEM_SERVICO WHERE EVENTHEADER=:EVENTHEADER');
    except on X: exception do
      begin
        AddLog(0,'Erro processando fechamento ='+T.AsString['ORDEM_SERVICO'] + ' '+X.message,'SI');

        E.Dim('ORDEM_SERVICO',T.GetFieldByName('ORDEM_SERVICO'));
        E.Dim('PROBLEMAS',X.Message);
        E.Execute('UPDATE SI_ORDENS_SERVICO SET ERRO=TRUE,PROBLEMAS=:PROBLEMAS WHERE ORDEM_SERVICO=:ORDEM_SERVICO');
      end;  
    end;
    T.Next;
  end;
end;

procedure DadosFaturamentoGenerico(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  Itens,C: IwtsCommand;
  OSBaixa, OS,Movimento, Produtos, EstoqueLote, PrioridadeLotes: IwtsWriteData;
  Cliente,Status,TabelaPreco,Filial,Evento,Fornecedor: Integer;
  Preco: Real;
  CFOP:Variant;
  EstadoFilial,EstadoCliente,Grupo,UltimaGrupoCFOP,S:string;
  EmGarantia,DentroDoEstado,ComErro,FaturamentoEntrada,IsEquipamento,ContribuinteICMS,
  Devolucao,AcessaLote,EventoPorClassCliente,ControlaLote, ControlaLoteGeral:Boolean;
  PecasFaturamento:TPecasFaturamento;
  AcessaFornecedor, Lancado: Boolean;
  Quantidade, I: Integer;
  Lotes: TLotes;

  function BoolToStr(const AValue:Boolean): string;
  begin
    Result := 'N';
    if AValue then
      Result := 'S';
  end;

  procedure ApplyFilter(AData:IwtsWriteData; AFieldName: PChar; AFieldValue: Variant; AOnlyWithValue: Boolean);
  begin
    AData.First;
    while not AData.EOF do
    begin
      if AOnlyWithValue then//Somente campos preenchidos com o mesmo valor
      begin
        if (AData.GetFieldAsString(AFieldName) <> VarToStr(AFieldValue)) then
          AData.Delete
        else
          AData.Next;
      end else
      begin
        if (AData.GetFieldAsString(AFieldName) <> '') and (AData.GetFieldAsString(AFieldName) <> VarToStr(AFieldValue)) then
          AData.Delete
        else
          AData.Next;
      end;
    end;
  end;

  function EncontraCFOP(AEvento:Integer;const AClassificaoProduto,ALote:string;AContribuinte,ADentroDoEstado,ADevolucao:Boolean; var CFOP: Variant): Boolean;
  var
    C: IwtsCommand;
    ListaCFOP: IwtsWriteData;
  begin
    C := DataPool.Open('MILLENIUM');

    C.Dim('EVENTO',AEvento);
    C.Execute('SELECT #IF(TIPO_CFOP="T",NULL,TIPO_CFOP) AS TIPO_PRODUTO, '+
              '    COALESCE(LOTE,"") AS LOTE, '+
              '    #IF(CONTRIBUINTE="V",NULL,CONTRIBUINTE) AS CONTRIBUINTE, '+
              '    CFOP_ESTAD, '+
              '    CFOP_INTER, '+
              '    CFOP_DEV AS CFOP_DEV_EST, '+
              '    CFOP_DEV_INTER '+
              'FROM EVENTOS_CFOP '+
              'WHERE EVENTO=:EVENTO');
    ListaCFOP := C.CreateRecordset;

    ApplyFilter(ListaCFOP,'TIPO_PRODUTO',AClassificaoProduto,False);
    ApplyFilter(ListaCFOP,'LOTE',ALote,False);
    ApplyFilter(ListaCFOP,'CONTRIBUINTE',BoolToStr(AContribuinte),False);

    ListaCFOP.First;
    if ListaCFOP.RecordCount = 1 then
    begin
      if ADentroDoEstado then
      begin
        if ADevolucao then
          CFOP := ListaCFOP.GetFieldByName('CFOP_DEV_EST')
        else
          CFOP := ListaCFOP.GetFieldByName('CFOP_ESTAD');
      end else
      begin
        if ADevolucao then
          CFOP := ListaCFOP.GetFieldByName('CFOP_DEV_INTER')
        else
          CFOP := ListaCFOP.GetFieldByName('CFOP_INTER');
      end;
    end;

    Result := VarIsValid(CFOP);
  end;

  function EncontraLote(const AProduto,ACor,AEstampa:Integer;ATamanho:string;AQuantidade: Integer; var ALotes: TLotes): Boolean;
  var
    C: IwtsCommand;
    Lote:TLote;
    Estoque, Quantidade, Saldo: Integer;
  begin
    Result := False;
    Saldo := AQuantidade;
    ALotes.Clear;;
    PrioridadeLotes.First;
    while not PrioridadeLotes.EOF do
    begin
        if EstoqueLote.Locate(['PRODUTO','COR','ESTAMPA','TAMANHO','LOTE'],[AProduto,ACor,AEstampa,ATamanho,PrioridadeLotes.GetFieldAsString('ITEM')]) then
        begin
          Estoque := EstoqueLote.Value['SALDO'];
          Quantidade := Saldo;
          if (Quantidade > Estoque) then
            Quantidade := Estoque;

          ALotes.Add(PrioridadeLotes.GetFieldAsString('ITEM'), Quantidade);

          Dec(Saldo,Quantidade);
          if Saldo = 0 then
            Break;
        end;
      PrioridadeLotes.Next;
    end;
    Result := (Saldo = 0);
  end;

  function MakeyKeyCFOP(const AClassificaoProduto,ALote:string;AContribuinte,ADentroDoEstado,ADevolucao:Boolean):string;
  begin
    Result := AClassificaoProduto+'|'+ALote+'|'+BoolToStr(AContribuinte)+'|'+BoolToStr(ADentroDoEstado)+'|'+BoolToStr(ADevolucao);
  end;

  function  JaLancado(AProdutos: IwtsWriteData; AProduto,ACor,AEstampa,ATamanho, ALote: string): Boolean;
  begin
    Result := False;
    AProdutos.First;
    while not AProdutos.EOF do
    begin
      if SameText(AProdutos.AsString['PRODUTO'],AProduto) and
         SameText(AProdutos.AsString['COR'],ACor) and
         SameText(AProdutos.AsString['ESTAMPA'],AEstampa) and
         SameText(AProdutos.AsString['TAMANHO'],ATamanho) and
         SameText(AProdutos.AsString['LOTE'],ALote) then
      begin
        Result := True;
        Break;
      end;
      AProdutos.Next;
    end;
  end;
begin
  C := DataPool.Open('MILLENIUM');
  Itens  := DataPool.Open('MILLENIUM');

  Evento := Input.GetParamByName('EVENTO');
  Movimento := DataPool.CreateRecordset('MILLENIUM.MOVIMENTACAO.EXECUTA');
  Produtos := DataPool.CreateRecordset('Millenium.EVENTOS.PRODUTOS');
  OSBaixa := DataPool.CreateRecordset('WTSSYSTEM.INTERNALTYPES.INTEGERARRAY');

  ControlaLoteGeral := GetConfigSrv.ReadParamBol('SI_CONTROLA_LOTE',False);

  //Dados do evento
  C.Dim('EVENTO',Evento);
  C.Execute('SELECT TIPO_EVENTO,ACESSA_LOTE,FORNECEDOR FROM EVENTOS WHERE EVENTO=:EVENTO');
  AcessaLote := VarToBool(C.GetFieldByName('ACESSA_LOTE'));
  FaturamentoEntrada := C.GetFieldAsString('TIPO_EVENTO')='E';
  AcessaFornecedor := C.GetFieldAsString('FORNECEDOR')='T';

  //Ordem de Servico ou Grupo de Ordem de Servi�o
  C.Dim('ID',Input.GetParamByName('ID'));
  C.Execute('SELECT * FROM SI_ORDENS_SERVICO WHERE ORDEM_SERVICO =:ID');
  OS := C.CreateRecordset;
  Cliente := OS.GetFieldByName('CLIENTE');
  Grupo := OS.GetFieldAsString('GRUPO');
  Fornecedor := 40130843;//40130841;

  EventoPorClassCliente := False;
  if FaturamentoEntrada then
  begin
    PecasFaturamento := [pfEquipamentos];
  end else
  begin
    //Descobrir se o evento que esta no processamento, se est� configurado na classifica�ao do cliente
    C.Dim('CLIENTE',Cliente);  
    C.Execute('SELECT CLS.EVENTO_EQUIPAMENTO, CLS.EVENTO_GARANTIA, CLS.EVENTO_FORA_GARANTIA,CLS.EVENTO_RETORNO_CONSIGNACAO FROM CLIENTES C '+
              'LEFT JOIN SI_CLASSIFICACAO_CLIENTE CLS ON (CLS.CLASSIFICACAO_CLIENTE = C.CLSCLIENTE) '+
              'WHERE C.CLIENTE=:CLIENTE');

    //Se tiver configurado por classifica��o do cliente, indica que cada evento s� ir� faturar um tipo de produto
    PecasFaturamento := [];
    if (Evento = VarToIntDef(C.GetFieldByName('EVENTO_EQUIPAMENTO'),-MaxInt)) then
      PecasFaturamento := [pfEquipamentos];

    if (Evento = VarToIntDef(C.GetFieldByName('EVENTO_GARANTIA'),-MaxInt)) then
      PecasFaturamento := [ptPecasGarantia];

    if (Evento = VarToIntDef(C.GetFieldByName('EVENTO_FORA_GARANTIA'),-MaxInt)) then
      PecasFaturamento := [ptPecasForaGarantia];

    if (Evento = VarToIntDef(C.GetFieldByName('EVENTO_RETORNO_CONSIGNACAO'),-MaxInt)) then
      PecasFaturamento := [ptPecasForaGarantia];

    //Nada configurado por classific�o do cliente, ent�o o mesmo evento faz tudo, paramentros gerais
    if PecasFaturamento = [] then
    begin
      if (Evento = GetConfigSrv.ReadParamInt('SI_EVENTO_SAIDA_GARANTIA',-MaxInt)) then
        PecasFaturamento := [pfEquipamentos,ptPecasGarantia];

      if (Evento = GetConfigSrv.ReadParamInt('SI_EVENTO_SAIDA_FORA_GARANTIA',-MaxInt)) then
        PecasFaturamento := [pfEquipamentos,ptPecasForaGarantia];

      if (Evento = GetConfigSrv.ReadParamInt('SI_EVENTO_RETORNO_CONSIGNACAO',-MaxInt)) then
        PecasFaturamento := [ptPecasForaGarantia];
    end else
      EventoPorClassCliente := True;
  end;              

  if Grupo <> '' then
  begin                      //Nas devolu��es de pe�as, n�o podemos considerar Com e Sem Garantia. Faturamos tudo junto
    if FaturamentoEntrada or (PecasFaturamento = [pfEquipamentos]) or not EventoPorClassCliente then
    begin
      C.Dim('GARANTIA',Unassigned)
    end else
    begin
      if ptPecasGarantia in PecasFaturamento then
        C.Dim('GARANTIA',True)
      else
        C.Dim('GARANTIA',False);
    end;
    C.Dim('GRUPO',Grupo);
    C.Execute('SELECT * FROM SI_ORDENS_SERVICO WHERE GRUPO =:GRUPO [AND GARANTIA=:GARANTIA]');
    OS := C.CreateRecordset;//Vamos carregar todas as OS do grupo
  end;

  OS.First;
  while not OS.EOF do
  begin
    OSBaixa.New;
    OSBaixa.SetFieldByName('ITEM',OS.GetFieldByName('ORDEM_SERVICO'));
    OSBaixa.Add;
    OS.Next;
  end;

  OS.First;
  Status := OS.GetFieldByName('STATUS');
  while not OS.EOF do
  begin
    if Status <> VarToIntDef(OS.GetFieldByName('STATUS'),-1) then
      raise Exception.Create('� necess�rio todas as ordens estejam no mesmo status.');
      
    if OS.GetFieldByName('STATUS') <> 5 then//Quando o faturamento � por grupo, acontece o faturamento de os por os, n�o devemos validar
      Status := OS.GetFieldByName('STATUS');

    OS.Next;
  end;
  
  //1-AG. FATURAMENTO ENTRADA
  //2-AG. FATURAMENTO
  //5-FINALIZADO
  if (Status <> 1) and (Status <> 4) and (Status <> 5) then
    raise Exception.Create('Status n�o permitido para o faturamento. Permitidos AG. FATURAMENTO ENTRADA ou AG. FATURAMENTO');

  OS.First;
  Cliente := OS.GetFieldByName('CLIENTE');
  while not OS.EOF do
  begin
    if Cliente <> VarToIntDef(OS.GetFieldByName('CLIENTE'),-1) then
      raise Exception.Create('Os ordens selecionadas, n�o s�o todas do mesmo cliente.');
    Cliente := OS.GetFieldByName('CLIENTE');
    OS.Next;
  end;

  if not FaturamentoEntrada and not (PecasFaturamento = [pfEquipamentos]) then
  begin
    OS.First;
    EmGarantia := VarToBool(OS.GetFieldByName('GARANTIA'));
    while not OS.EOF do
    begin
      if EmGarantia <> VarToBool(OS.GetFieldByName('GARANTIA')) then
        raise Exception.Create('N�o � permitido no mesmo faturamento produtos em garantia e produtos fora de garantia.');
      EmGarantia := VarToBool(OS.GetFieldByName('GARANTIA'));
      OS.Next;
    end;
  end;
  
  OS.First;
  ComErro := VarToBool(OS.GetFieldByName('ERRO'));
  while not OS.EOF do
  begin
    if ComErro <> VarToBool(OS.GetFieldByName('ERRO')) then
      raise Exception.Create('N�o � permitido faturamento de ordem de servi�o com erro.');
    ComErro := VarToBool(OS.GetFieldByName('ERRO'));
    OS.Next;
  end;

  //Dados da filial
  Filial := GetConfigSrv.ReadParamInt('SI_FILIAL',-1);
  C.Dim('FILIAL',Filial);
  C.Execute('SELECT F.NOME, EC.ESTADO FROM FILIAIS F '+
            'LEFT JOIN ENDERECOS_CADASTRO EC ON (EC.GERADOR = F.GERADOR) AND (EC.ENDERECO_NOTA = "T") '+
            'WHERE F.FILIAL=:FILIAL');
  EstadoFilial := C.GetFieldAsString('ESTADO');
  if EstadoFilial='' then
    raise Exception.Create('Filial '+C.GetFieldAsString('NOME')+' com endere�o sem estado para faturamento.');

  if AcessaFornecedor then
  begin
    //Dados do fornecedor
    C.Dim('FORNECEDOR',Fornecedor);
    C.Execute('SELECT F.NOME, F.CONTRIBUINTE_ICMS, EC.ESTADO FROM FORNECEDORES F '+
              'LEFT JOIN ENDERECOS_CADASTRO EC ON (EC.GERADOR = F.GERADOR) AND (EC.ENDERECO_NOTA = "T") '+
              'WHERE F.FORNECEDOR=:FORNECEDOR');
  end else
  begin
    //Dados do cliente
    C.Dim('CLIENTE',Cliente);
    C.Execute('SELECT C.NOME, C.CONTRIBUINTE_ICMS, EC.ESTADO FROM CLIENTES C '+
              'LEFT JOIN ENDERECOS_CADASTRO EC ON (EC.GERADOR = C.GERADOR) AND (EC.ENDERECO_NOTA = "T") '+
              'WHERE C.CLIENTE=:CLIENTE');
  end;

  EstadoCliente := C.GetFieldAsString('ESTADO');
  if EstadoCliente='' then
    raise Exception.Create('Cliente com endere�o sem estado para faturamento');

  ContribuinteICMS := VarToBool(C.GetFieldByName('CONTRIBUINTE_ICMS'));
  DentroDoEstado := SameText(EstadoFilial,EstadoCliente);

  if FaturamentoEntrada then
    TabelaPreco := GetConfigSrv.ReadParamInt('SI_TABELA_PRECO_ENTRADA',-1)
  else
    TabelaPreco := GetConfigSrv.ReadParamInt('SI_TABELA_PRECO_SAIDA',-1);

  //Verificando se existe alguma nota j� emitida para este evento
  OS.First;
  C.Dim('EVENTO',Evento);
  C.DimAsData('OSS',OS);
  C.Execute('SELECT NF.NOTA FROM SI_ORDENS_SERVICO_NFS OSNF '+
            'INNER JOIN MOVIMENTO M ON (M.TIPO_OPERACAO = OSNF.TIPO_OPERACAO) AND '+
            '                          (M.COD_OPERACAO = OSNF.COD_OPERACAO) '+
            'INNER JOIN NF ON (NF.TIPO_OPERACAO = M.TIPO_OPERACAO) AND '+
            '                 (NF.COD_OPERACAO = M.COD_OPERACAO) AND '+
            '                 (NF.CANCELADA = FALSE) '+
            'WHERE ORDEM_SERVICO IN #MAKELIST(OSS,ORDEM_SERVICO) AND (M.EVENTO=:EVENTO)');
   if not C.EOF then
     raise Exception.Create('Nota fiscal j� emitida para este evento. NF: '+C.GetFieldAsString('NOTA'));         

  UltimaGrupoCFOP := '';
  if FaturamentoEntrada then
  begin
    Itens.Dim('TIPO',0);
  end else
  begin
    if (pfEquipamentos in PecasFaturamento) and ((ptPecasGarantia in PecasFaturamento) or (ptPecasForaGarantia in PecasFaturamento)) then
      Itens.Dim('TIPO',2)//Equipamento e pe�as
    else
    if (not (pfEquipamentos in PecasFaturamento)) and ((ptPecasGarantia in PecasFaturamento) or (ptPecasForaGarantia in PecasFaturamento)) then
      Itens.Dim('TIPO',1)//Somente pe�as
    else
    if (pfEquipamentos in PecasFaturamento) and not ((ptPecasGarantia in PecasFaturamento) or (ptPecasForaGarantia in PecasFaturamento)) then
      Itens.Dim('TIPO',0);//Somente pe�as
  end;
  OS.First;
  Itens.DimAsData('OSS',OS);
  Itens.Execute('SELECT P.CLASS_PROD,'+
                '       OS.PRODUTO,'+
                '       OS.COR,'+
                '       OS.ESTAMPA,'+
                '       OS.TAMANHO,'+
                '       OS.NUMERO_PRODUTO,'+
                '       AVG(OS.PRECO) AS PRECO,'+
                '       OS.EQUIPAMENTO,'+
                '       SUM(OS.QUANTIDADE) AS QUANTIDADE,'+
                '       OS.NUMERO_SERIE, '+
                '       P.CONTROLA_LOTE '+
                'FROM SI_ORDENS_SERVICO_PRODUTOS OS '+
                'INNER JOIN PRODUTOS P ON (P.PRODUTO = OS.PRODUTO) '+
                'WHERE OS.ORDEM_SERVICO IN #MAKELIST(OSS,ORDEM_SERVICO) AND '+
                '      OS.EQUIPAMENTO #SELECT(TIPO,0:{="T"},1:{="F"},ELSE:{IN ("T","F")}) '+
                'GROUP BY P.CLASS_PROD,OS.PRODUTO,OS.COR,OS.ESTAMPA,OS.TAMANHO,OS.NUMERO_PRODUTO,OS.EQUIPAMENTO,OS.NUMERO_SERIE,P.CONTROLA_LOTE '+
                'HAVING SUM(QUANTIDADE) > 0');

  Itens.First;
  C.Dim('FILIAL',Filial);
  C.DimAsData('PRODUTOS',Itens);
  C.Execute('SELECT FILIAL,PRODUTO,COR,ESTAMPA,TAMANHO,LOTE,SUM(SALDO) AS SALDO '+
            'FROM ESTOQUES E '+
            'INNER JOIN PRODUTOS P ON (P.PRODUTO = E.PRODUTO) '+
            'WHERE P.CONTROLA_LOTE = TRUE AND '+
            '      E.FILIAL =:FILIAL AND '+
            '      E.PRODUTO IN #MAKELIST(PRODUTOS,PRODUTO) '+
            'GROUP BY FILIAL,PRODUTO,COR,ESTAMPA,TAMANHO,LOTE '+
            'HAVING SUM(SALDO) > 0 '+
            'ORDER BY FILIAL,PRODUTO,COR,ESTAMPA,TAMANHO,LOTE ');
  EstoqueLote := C.CreateRecordset;

  PrioridadeLotes := GetConfigSrv.CreateRecordSet('SI_ORDEM_LOTES');

  Lotes := TLotes.Create;
  try
    Itens.First;
    while not Itens.EOF do
    begin
      Preco := VarToFloat(Itens.GetFieldByName('PRECO'));
      IsEquipamento := SameText(Itens.GetFieldAsString('EQUIPAMENTO'),'T');
      Devolucao := (not FaturamentoEntrada) and IsEquipamento;
      ControlaLote := Itens.GetFieldAsString('CONTROLA_LOTE') = 'T';
      Quantidade := Itens.GetFieldByName('QUANTIDADE');

      //Vamos sempre iniciar com lote em branco
      Lotes.Clear;
      Lotes.Add('',Quantidade);

      if IsEquipamento then
      begin
        Lotes.Clear;
        Lotes.Add(Copy(Itens.GetFieldAsString('NUMERO_SERIE'),1,20), Quantidade)
      end else
      if ControlaLoteGeral and AcessaLote and ControlaLote then
      begin
        if not EncontraLOTE(Itens.GetFieldByName('PRODUTO'),Itens.GetFieldByName('COR'),Itens.GetFieldByName('ESTAMPA'),Itens.GetFieldAsString('TAMANHO'),Quantidade,Lotes) then
          raise Exception.Create('N�o h� estoque com lote dispon�vel para o produto '+Itens.GetFieldAsString('NUMERO_PRODUTO'));
      end;

      for I := 0 to Lotes.Count-1 do
      begin
        Quantidade := Lotes[I].Quantidade;

        S := MakeyKeyCFOP(Itens.GetFieldAsString('CLASS_PROD'),Lotes[I].Numero,ContribuinteICMS,DentroDoEstado,Devolucao);
        if S <> UltimaGrupoCFOP then
        begin
          UltimaGrupoCFOP := S;
          if not EncontraCFOP(Evento,Itens.GetFieldAsString('CLASS_PROD'),Lotes[I].Numero,ContribuinteICMS,DentroDoEstado,Devolucao,CFOP) then
            raise Exception.Create('CFOP n�o encontrada para o produto '+Itens.GetFieldAsString('NUMERO_PRODUTO'));
        end;

        if not IsEquipamento then
        begin
          C.Dim('TABELA',TabelaPreco);
          C.Dim('PRODUTO',Itens.GetFieldByName('PRODUTO'));
          C.Dim('COR',Itens.GetFieldByName('COR'));
          C.Dim('ESTAMPA',Itens.GetFieldByName('ESTAMPA'));
          C.Dim('TAMANHO',Itens.GetFieldByName('TAMANHO'));
          C.Execute('SELECT #NULL_TO_Z(V.PRECO) AS PRECO '+
                    'FROM PRECOS V '+
                    'WHERE V.TABELA=:TABELA AND '+
                    '      V.PRODUTO=:PRODUTO AND '+
                    '      V.COR=:COR AND '+
                    '      V.ESTAMPA=:ESTAMPA AND '+
                    '      V.TAMANHO=:TAMANHO');
          Preco := VarToFloat(C.GetFieldByName('PRECO'));
        end;

        if Preco = 0 then
          raise Exception.Create('Produto '+Itens.GetFieldAsString('NUMERO_PRODUTO')+' sem pre�o.');

        Lancado := JaLancado(Produtos,Itens.GetFieldByName('PRODUTO'),Itens.GetFieldByName('COR'),Itens.GetFieldByName('ESTAMPA'),Itens.GetFieldByName('TAMANHO'),Lotes[I].Numero);

        if Lancado then
          Quantidade := Lotes[I].Quantidade{Quantidade} + Produtos.GetFieldByName('QUANTIDADE')
        else
          Produtos.New;
        Produtos.SetFieldByName('PRODUTO',Itens.GetFieldByName('PRODUTO'));
        Produtos.SetFieldByName('COR',Itens.GetFieldByName('COR'));
        Produtos.SetFieldByName('ESTAMPA',Itens.GetFieldByName('ESTAMPA'));
        Produtos.SetFieldByName('TAMANHO',Itens.GetFieldByName('TAMANHO'));
        Produtos.SetFieldByName('QUANTIDADE',Quantidade);
        Produtos.SetFieldByName('PRECO',Preco);
        Produtos.SetFieldByName('CFOP',CFOP);
        Produtos.SetFieldByName('LOTE',Lotes[I].Numero);

        if Lancado then
          Produtos.Update
        else
          Produtos.Add;

      end;
      Itens.Next;
    end;
  finally
    Lotes.Free;
  end;
  
  Movimento.New;
  Movimento.SetFieldByName('TABELA',TabelaPreco);
  Movimento.SetFieldByName('FILIAL',Filial);
  if AcessaFornecedor then
    Movimento.SetFieldByName('FORNECEDOR',Fornecedor)
  else
    Movimento.SetFieldByName('CLIENTE',Cliente);
  Movimento.SetFieldByName('PRODUTOS',Produtos);
  Movimento.SetFieldByName('SI_ORDENS_SERVICO',OSBaixa);
  Movimento.Add;

  //devolver somente leitura ou nao

  Output.NewRecord;
  Output.SetFieldByName('MOVIMENTO',Movimento.Data);
end;

procedure GerarExcelConciliacao(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C: IwtsCommand;
  Data: IwtsWriteData;
  Filial,Tabela,X: Integer;
  Proximo: TDateTime;
  Excel: Variant;
begin
  Proximo := GetConfigSrv.ReadParamDateTime('SI_DATA_PROX_CONC_EST',0);
  if Now < Proximo then
    Exit;

  C := DataPool.Open('MILLENIUM');
  Filial := GetConfigSrv.ReadParamInt('SI_FILIAL',-1);
  Tabela := GetConfigSrv.ReadParamInt('SI_TABELA_PRECO_CUSTO',-1);

  C.Dim('FILIAL',Filial);
  C.Dim('TABELA',Tabela);
  C.Dim('DATA',FormatDateTime('YYYYMMDDHHNNSS',Proximo));
  C.Execute('#CALL MILLENIUM.CORES.LISTA()');
  //C.Execute('#CALL MILLENIUM!SALDAOINFORMATICA.ESTOQUES.CONCILIACAO(FILIAL=:FILIAL,TABELA=:TABELA,DATA=:DATA)');

  Data := C.CreateRecordset;
  CoInitialize(nil);
  try
      Excel:=CreateOleObject('Excel.Application');
      Excel.Visible:=False;
      Excel.DisplayAlerts:=False;
      Excel.Workbooks.Add(1);
      Excel.Workbooks[1].Sheets.Add;
      Excel.Workbooks[1].WorkSheets[1].Name:='Teste';
      Excel.Workbooks[1].WorkSheets[1].DisplayPageBreaks:=False;
      Excel.Columns.AutoFit;

    for X := 0 to Data.FieldCount-1 do
     excel.WorkBooks[1].Sheets[1].Cells[x,1] := Data.FieldName(X);

   { Data.First;
    for X := 0 to Data.RecordCount-1 do
    begin
      for Y := 0 to Data.FieldCount-1 do
        Excel.cells[X+2,Y] := VarToStr(Data.GetField(Y));
      Data.Next;
    end;       }
    Excel.Application.Workbooks[1].SaveAs('c:\test.xlsx', 51); // or xlOpenXMLWorkbook (51)
    Excel.Application.Quit;
  finally
    CoUninitialize;
  end;

  C.Dim('PARAM_VALUE',Proximo);
  C.Execute('UPDATE CONFIGURACOES SET PARAM_VALUE=:PARAM_VALUE WHERE PARAM_NAME="SI_DATA_PROX_CONC_EST"');

end;

procedure ListaEventosPorClassificaoCliente(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C,OS: IwtsCommand;
  G,Eventos: IwtsWriteData;
  EventosJaOcorrido:IwtsWriteData;
  EventoEntradaEquipamento,
  EventoSaidaDevolucao,
  EventoSaidaGarantia,
  EventoSaidaForaGarantia,
  EventoRetornoConsignacao: Variant;
  Status:Integer;
  EventoPorClassCliente,SomenteEventosNaoUsados:Boolean;
  Garantia,Grupo:string;
  QuantidadePecas: Integer;
begin
  C := DataPool.Open('MILLENIUM');
  OS := DataPool.Open('MILLENIUM');

  EventoPorClassCliente := False;
  Eventos := DataPool.CreateRecordset('WTSSYSTEM.INTERNALTYPES.INTEGERARRAY');

  EventoEntradaEquipamento := GetConfigSrv.ReadParamInt('SI_EVENTO_ENTRADA',-1);
  EventoSaidaDevolucao := GetConfigSrv.ReadParamInt('SI_EVENTO_SAIDA_DEVOLUCAO',-1);
  EventoSaidaGarantia := GetConfigSrv.ReadParamInt('SI_EVENTO_SAIDA_GARANTIA',-1);
  EventoSaidaForaGarantia := GetConfigSrv.ReadParamInt('SI_EVENTO_SAIDA_FORA_GARANTIA',-1);
  EventoRetornoConsignacao := GetConfigSrv.ReadParamInt('SI_EVENTO_RETORNO_CONSIGNACAO',-1);

  SomenteEventosNaoUsados := VarToBool(Input.GetParamByName('SOMENTE_NAO_USADO'));

  OS.Execute('SELECT O.GRUPO, '+
             '       O.STATUS, '+
             '       O.GARANTIA, '+
             '       CLS.EVENTO_EQUIPAMENTO, '+
             '       CLS.EVENTO_GARANTIA, '+
             '       CLS.EVENTO_FORA_GARANTIA, '+
             '       CLS.EVENTO_RETORNO_CONSIGNACAO, '+
             '       (SELECT SUM(P.QUANTIDADE) '+
             '        FROM SI_ORDENS_SERVICO_PRODUTOS P '+
             '        WHERE P.ORDEM_SERVICO = O.ORDEM_SERVICO AND P.EQUIPAMENTO = FALSE) AS QUANTIDADE_PECAS '+
             'FROM SI_ORDENS_SERVICO O '+
             'INNER JOIN CLIENTES C ON (C.CLIENTE = O.CLIENTE) '+
             'LEFT JOIN SI_CLASSIFICACAO_CLIENTE CLS ON (CLS.CLASSIFICACAO_CLIENTE = C.CLSCLIENTE) '+
             'WHERE O.ORDEM_SERVICO=:ORDEM_SERVICO ');

  if OS.GetFieldAsString('EVENTO_EQUIPAMENTO') <> '' then
    EventoSaidaDevolucao := OS.GetFieldAsString('EVENTO_EQUIPAMENTO');

  if OS.GetFieldAsString('EVENTO_GARANTIA') <> '' then
    EventoSaidaGarantia := OS.GetFieldAsString('EVENTO_GARANTIA');

  if OS.GetFieldAsString('EVENTO_FORA_GARANTIA') <> '' then
    EventoSaidaForaGarantia := OS.GetFieldAsString('EVENTO_FORA_GARANTIA');

  if OS.GetFieldAsString('EVENTO_RETORNO_CONSIGNACAO') <> '' then
    EventoRetornoConsignacao := OS.GetFieldAsString('EVENTO_RETORNO_CONSIGNACAO');

  QuantidadePecas := VarToIntDef(OS.GetFieldByName('QUANTIDADE_PECAS'),0);

  EventoPorClassCliente := (OS.GetFieldAsString('EVENTO_EQUIPAMENTO') <> '') or (OS.GetFieldAsString('EVENTO_GARANTIA') <> '') or (OS.GetFieldAsString('EVENTO_FORA_GARANTIA') <> '');

  Grupo := OS.GetFieldAsString('GRUPO');

  if Grupo <> '' then
  begin
    C.Dim('GRUPO',Grupo);
    C.Execute('SELECT OS.GARANTIA, '+
              '       OS.STATUS, '+
              '       SUM((SELECT SUM(COALESCE(P.QUANTIDADE,0)) '+
              '        FROM SI_ORDENS_SERVICO_PRODUTOS P '+
              '        WHERE P.ORDEM_SERVICO = OS.ORDEM_SERVICO AND P.EQUIPAMENTO = FALSE)) AS QUANTIDADE_PECAS '+
              'FROM SI_ORDENS_SERVICO OS '+
              'WHERE OS.GRUPO=:GRUPO  '+//AND '+'      OS.STATUS IN (1,4)
              'GROUP BY OS.GARANTIA,OS.STATUS');
    G := C.CreateRecordset;

    if not SomenteEventosNaoUsados then
    begin
      G.First;
      Status := G.GetFieldByName('STATUS');
      while not G.EOF do
      begin
        if Status <> VarToIntDef(G.GetFieldByName('STATUS'),-1) then
          raise Exception.Create('� necess�rio todas as ordens estejam no mesmo status.');
        Status := G.GetFieldByName('STATUS');
        G.Next;
      end;
    end;

    if not EventoPorClassCliente then
    begin
      G.First;
      Garantia := G.GetFieldByName('GARANTIA');
      while not G.EOF do
      begin
        if Garantia <> G.GetFieldAsString('GARANTIA') then
          raise Exception.Create('� necess�rio todas as ordens estejam no mesmo status(Garantia e Fora de Garantia).');
        Garantia := G.GetFieldByName('GARANTIA');
        G.Next;
      end;
    end;

    if not SomenteEventosNaoUsados then
      if (Status <> 1) and (Status <> 4)  then
        raise Exception.Create('Status n�o permitido para o faturamento. Permitidos AG. FATURAMENTO ENTRADA ou AG. FATURAMENTO');

    G.First;
    while not G.EOF do
    begin
      QuantidadePecas := VarToIntDef(G.GetFieldByName('QUANTIDADE_PECAS'),0);
      
      if G.GetFieldAsString('STATUS') = '1' then//AG. FATURAMENTO ENTRADA
      begin
        Eventos.New;
        Eventos.SetFieldByName('ITEM',EventoEntradaEquipamento);
        Eventos.Add;
      end else
      if G.GetFieldAsString('STATUS') = '4' then//AG. FATURAMENTO
      begin
        if EventoPorClassCliente then
        begin
          Eventos.New;
          Eventos.SetFieldByName('ITEM',EventoSaidaDevolucao);
          Eventos.Add;
        end;

        //S� temos saida quanto h� pe�as consumidas ou o n�o � eventos por cliente, pois a devolu��o sai na mesma nota
        if (QuantidadePecas > 0) or (not EventoPorClassCliente) then
        begin
          if VarToBool(G.GetFieldByName('GARANTIA')) then
          begin
            Eventos.New;
            Eventos.SetFieldByName('ITEM',EventoSaidaGarantia);
            Eventos.Add;
          end else
          begin
            Eventos.New;
            Eventos.SetFieldByName('ITEM',EventoSaidaForaGarantia);
            Eventos.Add;
            if QuantidadePecas > 0 then//S� existe faturamento de saida se tiver pe�as consumidas
            begin
              Eventos.New;
              Eventos.SetFieldByName('ITEM',EventoRetornoConsignacao);
              Eventos.Add;
            end;
          end;
        end;
      end;

      G.Next;
    end;
  end else //POR O.S.
  begin
    if OS.GetFieldAsString('STATUS') = '1' then//AG. FATURAMENTO ENTRADA
    begin
      Eventos.New;
      Eventos.SetFieldByName('ITEM',EventoEntradaEquipamento);
      Eventos.Add;
    end else
    if OS.GetFieldAsString('STATUS') = '4' then//AG. FATURAMENTO
    begin
      if EventoPorClassCliente then
      begin
        Eventos.New;
        Eventos.SetFieldByName('ITEM',EventoSaidaDevolucao);
        Eventos.Add;
      end;

      //S� temos saida quanto h� pe�as consumidas ou o n�o � eventos por cliente, pois a devolu��o sai na mesma nota
      if (QuantidadePecas > 0) or (not EventoPorClassCliente) then
      begin
        if VarToBool(OS.GetFieldByName('GARANTIA')) then
        begin
          Eventos.New;
          Eventos.SetFieldByName('ITEM',EventoSaidaGarantia);
          Eventos.Add;
        end else
        begin
          Eventos.New;
          Eventos.SetFieldByName('ITEM',EventoSaidaForaGarantia);
          Eventos.Add;

          if QuantidadePecas > 0 then//S� existe faturamento de saida se tiver pe�as consumidas
          begin
            Eventos.New;
            Eventos.SetFieldByName('ITEM',EventoRetornoConsignacao);
            Eventos.Add;
          end;
        end;
      end;
    end;
  end;

  //Vamos detectar todos os eventos que j� ocorreram, assim removemos da lista
  if SomenteEventosNaoUsados then
  begin
    if Grupo <> '' then
    begin
      C.Dim('GRUPO',Grupo);
      C.Dim('ORDEM_SERVICO',Unassigned);
    end else
    begin
      C.Dim('GRUPO',Unassigned);
      C.Dim('ORDEM_SERVICO',Input.GetParamByName('ORDEM_SERVICO'));
    end;
    C.Execute('SELECT DISTINCT M.EVENTO FROM SI_ORDENS_SERVICO OS '+
              'INNER JOIN SI_ORDENS_SERVICO_NFS OSNF ON OSNF.ORDEM_SERVICO = OS.ORDEM_SERVICO '+
              'INNER JOIN MOVIMENTO M ON (M.TIPO_OPERACAO = OSNF.TIPO_OPERACAO) AND '+
              '                          (M.COD_OPERACAO = OSNF.COD_OPERACAO) '+
              'INNER JOIN NF ON (NF.TIPO_OPERACAO = M.TIPO_OPERACAO) AND '+
              '                 (NF.COD_OPERACAO = M.COD_OPERACAO) AND '+
              '                 (NF.CANCELADA = FALSE) '+
              'WHERE [OS.ORDEM_SERVICO=:ORDEM_SERVICO] [OS.GRUPO=:GRUPO]');
    EventosJaOcorrido := C.CreateRecordset;
  end;

  Eventos.First;
  C.DimAsData('EVENTO',Eventos);
  C.Execute('SELECT EVENTO,CODIGO,DESCRICAO FROM EVENTOS WHERE EVENTO IN #MAKELIST(EVENTO,ITEM)');
  while not C.EOF do
  begin
    if (EventosJaOcorrido = nil) or not EventosJaOcorrido.Locate(['EVENTO'],[C.GetFieldByName('EVENTO')]) then
    begin
      Output.NewRecord;
      Output.SetFieldByName('EVENTO',C.GetFieldByName('EVENTO'));
      Output.SetFieldByName('CODIGO',C.GetFieldByName('CODIGO'));
      Output.SetFieldByName('DESCRICAO',C.GetFieldByName('DESCRICAO'));
    end;
    C.Next;
  end;
end;

procedure AlteraStatusOrdem(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C: IwtsCommand;
  QtdEventos,Status: Integer;
  PermitirAlterarStatus: Boolean;
  Fi:string;
begin
  C := DataPool.Open('MILLENIUM');
  PermitirAlterarStatus := True;

  C.Execute('SELECT GRUPO, STATUS FROM SI_ORDENS_SERVICO WHERE ORDEM_SERVICO=:ORDEM_SERVICO');
  Status := C.GetFieldByName('STATUS');
  if Status = 4 then //S� faz sentido esta verifica��o quando � AG. Faturamento de saida
  begin
     //ListaEventosPorClassificaoCliente s� retorna eventos que ainda n�o foram faturados
     C.Execute('#CALL MILLENIUM!SALDAOINFORMATICA.ORDENS_SERVICO.ListaEventosPorClassificaoCliente(ORDEM_SERVICO=:ORDEM_SERVICO,SOMENTE_NAO_USADO=TRUE)');
     PermitirAlterarStatus := C.EOF;
     C.Execute('UPDATE SI_ORDENS_SERVICO SET SUB_STATUS = #IF(STATUS=1,0,1) WHERE ORDEM_SERVICO=:ORDEM_SERVICO;');
     //SUB_STATUS 1: EM FATURAMENTO
  end;

  if PermitirAlterarStatus then
    C.Execute('UPDATE SI_ORDENS_SERVICO SET STATUS = #IF(STATUS=1,2,5), SUB_STATUS=0 WHERE ORDEM_SERVICO=:ORDEM_SERVICO;');
end;

procedure EntradaAutomatica(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C,L: IwtsCommand;
  OS: IwtsWriteData;
  Evento: Integer;
begin
  C := DataPool.Open('MILLENIUM');
  L := DataPool.Open('MILLENIUM');

  Evento := GetConfigSrv.ReadParamInt('SI_EVENTO_ENTRADA',-1);

  C.Execute('SELECT OS.ORDEM_SERVICO '+
            'FROM SI_ORDENS_SERVICO OS '+
            'INNER JOIN CLIENTES C ON (C.CLIENTE = OS.CLIENTE) '+
            'INNER JOIN SI_CLASSIFICACAO_CLIENTE CC ON (CC.CLASSIFICACAO_CLIENTE = C.CLSCLIENTE) '+
            'WHERE OS.STATUS = 1 AND '+
            '      OS.ERRO = FALSE AND '+
            '      CC.ENTRADA_AUTOMATICA = TRUE '+
            'ORDER BY OS.DATA_ABERTURA ');
  OS := C.CreateRecordset;
  OS.First;         
  while not OS.EOF do
  begin
    try
      C.Dim('EVENTO',Evento);
      C.Dim('DOC_GENERICO',OS.GetFieldByName('ORDEM_SERVICO'));
      C.Execute('#CALL MILLENIUM!FATURAMENTO_SRV.DOC_GENERICO.Faturar(EVENTO=:EVENTO,DOC_GENERICO=:DOC_GENERICO);')
    except on e: Exception do
      begin
        L.Dim('ORDEM_SERVICO',OS.GetFieldByName('ORDEM_SERVICO'));
        L.Dim('PROBLEMAS',e.Message);
        L.Execute('UPDATE SI_ORDENS_SERVICO SET ERRO=TRUE,PROBLEMAS=:PROBLEMAS WHERE ORDEM_SERVICO=:ORDEM_SERVICO');
      end;
    end;                         
    OS.Next;
  end;
end;

procedure EVMvimentacaoExecutaAntesNF(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C: IwtsCommand;
  ControlaFilialProduto: Boolean;
  SL: TStringList;
begin
  ControlaFilialProduto := GetConfigSrv.ReadParamBol('SI_CONTROLA_FILIAL_PRODUTO',False);

  if not ControlaFilialProduto then
    Exit;

  C := DataPool.Open('MILLENIUM');  

  C.Dim('TIPO_OPERACAO', Input.Value['TIPO_OPERACAO']);
  C.Dim('COD_OPERACAO', Input.Value['COD_OPERACAO']);
  C.Execute('SELECT P.COD_PRODUTO '+
            'FROM MOVIMENTO M '+
            'INNER JOIN PRODUTOS_EVENTOS PE ON (PE.COD_OPERACAO = M.COD_OPERACAO) AND '+
            '                                  (PE.TIPO_OPERACAO = M.TIPO_OPERACAO) '+
            'INNER JOIN PRODUTOS P ON (P.PRODUTO = PE.PRODUTO) '+
            'WHERE M.TIPO_OPERACAO =:TIPO_OPERACAO AND '+
            '      M.COD_OPERACAO =:COD_OPERACAO AND '+
            '      NOT EXISTS (SELECT 1 FROM FILIAIS_PROD FP '+
            '                  WHERE FP.FILIAL = M.FILIAL AND '+
            '                        FP.PRODUTO = P.PRODUTO) '+
            'GROUP BY P.COD_PRODUTO');
  SL := TStringList.Create;
  try
    while not C.EOF do
    begin
      SL.Add(C.AsString['COD_PRODUTO']);
      C.Next;
    end;

    if SL.Count > 0 then
      raise Exception.Create('Produto(s) '+SL.Text+' n�o pertecem a filial desse movimento'); 
  finally
    SL.Free;
  end;
end;

{ TLotes }

function TLotes.Add(ANumero: string; AQuantidade: Integer): TLote;
begin
  Result := TLote.Create;
  Result.Numero := ANumero;
  Result.Quantidade := AQuantidade;
  inherited Add(Result);
end;

function TLotes.GetItem(Index: Integer): TLote;
begin
  Result := TLote(inherited Items[Index])
end;

initialization
   wtsRegisterProc('ORDENS_SERVICO.ReavaliarRelacionamentos',ReavaliarRelacionamentos);
   wtsRegisterProc('ORDENS_SERVICO.ListaEventosPorClassificaoCliente',ListaEventosPorClassificaoCliente);
   wtsRegisterProc('ORDENS_SERVICO.EntradaAutomatica',EntradaAutomatica);

   wtsRegisterProc('ACER.ImportarArquivosXML',ImportarArquivosXML);
   wtsRegisterProc('ACER.ImportarOrdens',ImportarOrdens);
   wtsRegisterProc('ACER.ImportarProdutos',ImportarProdutos);
   wtsRegisterProc('ACER.ImportarFechamento',ImportarFechamento);

   wtsRegisterProc('MOVIMENTACAO.DadosFaturamentoGenerico', DadosFaturamentoGenerico);
   wtsRegisterProc('MOVIMENTACAO.AlteraStatusOrdem', AlteraStatusOrdem);
   wtsRegisterProc('MOVIMENTACAO.ev_movimentacao_executa_antes_nf', EVMvimentacaoExecutaAntesNF);

   wtsRegisterProc('ESTOQUES.GerarExcelConciliacao',GerarExcelConciliacao);
end.


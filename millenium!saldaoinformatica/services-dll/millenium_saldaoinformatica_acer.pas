unit millenium_saldaoinformatica_acer;

interface

uses
  Windows, Classes, wtsServerObjs, SysUtils, ServerCfgs, millenium_variants,
  XMLAcer,wtsIntf,EcoUtils;  

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

  T.Execute('SELECT DISTINCT T.EVENTHEADER,T.CSSTICKETNUMBER,T.WARRANTYSTATUS,D.SEQUENCENO,D.PRODUCTNUMBER,D.QUANTITY,D.SERIALNUMBER,D.UNITPRICE,T.MSG_ERROR FROM ACER_TICKETEVENTHEADER T '+
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

  function TratarStrings(const AValue:string):string;
  begin
    Result := RemoveAcentos(AValue);
    Result := UpperCase(Result);
  end;


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

    ClassCli := Unassigned;
    C.Dim('COD_CLSCLIENTE',T.GetFieldAsString('CUSTOMERTYPE'));
    C.Execute('SELECT CLSCLIENTE FROM CLASSIFICACAO_CLIENTE WHERE COD_CLSCLIENTE=:COD_CLSCLIENTE');
    if not C.EOF then
      ClassCli := C.GetFieldByName('CLSCLIENTE');


    //Tratando cliente
    C.Execute('SELECT CLIENTE FROM SI_ORDENS_SERVICO WHERE ORDEM_SERVICO=:ORDEM_SERVICO AND CLIENTE IS NULL');
    if not C.EOF then
    begin
      try
        CPFCNPJFormartado := FormatarCPFCNPJ(T.GetFieldAsString('CPFCNPJNUMBER'));

        if (Length(CPFCNPJFormartado)=14) and (Length(CPFCNPJFormartado)=18) then
          raise Exception.Create('CPF\CNPJ Inválido '+CPFCNPJFormartado);

        if Length(CPFCNPJFormartado) = 14 then
        begin
          C.Dim('CPF_CNPJ',CPFCNPJFormartado);
          C.Execute('SELECT CLIENTE FROM CLIENTES WHERE (CPF=:CPF_CNPJ);');
        end else
        begin
          C.Dim('CPF_CNPJ',CPFCNPJFormartado);
          C.Execute('SELECT CLIENTE FROM CLIENTES WHERE (CNPJ=:CPF_CNPJ) OR (CGC=:CPF_CNPJ);');
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
        UpdEnd := Endereco.Locate(['LOGRADOURO2'],[TratarStrings(T.GetFieldAsString('CUSTOMERADDRESS'))]);

        if not UpdEnd then
        begin
          C.Execute('#CALL millenium.utils.default(NOME="COD_ENDERECO",TAM_REQUESTED=FALSE)');
          CodEndereco := C.GetField(0);
          Endereco.New;
          Endereco.SetFieldByName('COD_ENDERECO',CodEndereco);
        end;
        Endereco.SetFieldByName('ENDERECO',0);
        Endereco.SetFieldByName('LOGRADOURO2',TratarStrings(T.GetFieldAsString('CUSTOMERADDRESS')));
        Endereco.SetFieldByName('BAIRRO',TratarStrings(T.GetFieldAsString('DISTRICT')));
        Endereco.SetFieldByName('CIDADE2',TratarStrings(T.GetFieldAsString('CITY')));
        Endereco.SetFieldByName('ESTADO2',TratarStrings(T.GetFieldAsString('CUSTOMERSTATE')));
        Endereco.SetFieldByName('COMPLEMENTO',TratarStrings(T.GetFieldAsString('ADDRESS2')));
        Endereco.SetFieldByName('CEP',T.GetFieldAsString('ZIPCODE'));
        Endereco.SetFieldByName('DDD',ExtrairDDDNumeroTelefone(T.GetFieldAsString('PHONENUMBER')));
        Endereco.SetFieldByName('FONE',ExtrairNumeroTelefone(T.GetFieldAsString('PHONENUMBER')));
        Endereco.SetFieldByName('ENDERECO_ENTREGA',True);
        Endereco.SetFieldByName('ENDERECO_NOTA',True);
        Endereco.SetFieldByName('ENDERECO_COBRANCA',True);
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
            Gerador.SetFieldByName('NAOCONTRIBUINTE_ICMS',T.GetFieldAsString('CUSTOMERTYPE')<>'T2S');//Ligar para todos, com exceção aos clientes varejo
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
        Problemas.Add('NÃO FOI POSSÍVEL CADASTRAR OU ATUALIZAR CLIENTE. MOTIVO: '+E.Message);
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
        Problemas.Add('PRODUTO "'+P.GetFieldAsString('NUMERO_PRODUTO')+'" NÃO ENCONTRADO');
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

  //Por garantia do processo, só vou importar as peças consumidas na manutenção se a O.S estiver com status=2 (AG. REPARO ou EM REPARO)
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

    //Peças que serão cobradas, os demais, são somente movimetnação de estoque
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
  C,T: IwtsCommand;
begin
  C := DataPool.Open('MILLENIUM');
  T := DataPool.Open('MILLENIUM');

  //Por garantia do processo, só vou fechar a ordem de serviço, se ela estiver com status=2,3 (AG. REPARO ou EM REPARO)
  //AG. REPARO. Porque podemos fechar sem o reparo.
  T.Execute('SELECT T.EVENTHEADER,OS.ORDEM_SERVICO '+
            'FROM ACER_TICKETEVENTHEADER T '+
            'INNER JOIN ACER_TICKETEVENTDETAIL D ON (D.EVENTHEADER = T.EVENTHEADER) '+
            'INNER JOIN SI_ORDENS_SERVICO OS ON (OS.COD_ORDEM_SERVICO = T.CSSTICKETNUMBER) '+
            'WHERE UPPER(T.EVENTTYPE) IN ("OUTBOUND") AND T.ORDEM_SERVICO IS NULL AND OS.STATUS IN (2,3) AND OS.ERRO = FALSE ');
  while not T.EOF do
  begin
    C.Dim('ORDEM_SERVICO',T.GetFieldByName('ORDEM_SERVICO'));//4=AG. FATURAMENTO
    C.Execute('UPDATE SI_ORDENS_SERVICO SET STATUS = 4 WHERE ORDEM_SERVICO=:ORDEM_SERVICO');

    C.Dim('EVENTHEADER',T.GetFieldByName('EVENTHEADER'));
    C.Dim('ORDEM_SERVICO',T.GetFieldByName('ORDEM_SERVICO'));
    C.Execute('UPDATE ACER_TICKETEVENTHEADER SET ORDEM_SERVICO=:ORDEM_SERVICO WHERE EVENTHEADER=:EVENTHEADER');

    T.Next;
  end;
end;

procedure DadosFaturamentoGenerico(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  IDs: IwtsData;
  Itens,C: IwtsCommand;
  OSBaixa, OS,Movimento, Produtos: IwtsWriteData;
  Cliente,Status,TabelaPreco,CFOP,CFOPDev,Filial: Integer;
  Preco: Real;
  OrdemServico:Variant;
  EstadoFilial,EstadoCliente,Grupo:string;
  EmGarantia,DentroDoEstado,ComErro,FaturamentoEntrada,IsEquipamento:Boolean;
begin
  C := DataPool.Open('MILLENIUM');
  Itens  := DataPool.Open('MILLENIUM');

  Movimento := DataPool.CreateRecordset('MILLENIUM.MOVIMENTACAO.EXECUTA');
  Produtos := DataPool.CreateRecordset('Millenium.EVENTOS.PRODUTOS');
  OSBaixa := DataPool.CreateRecordset('WTSSYSTEM.INTERNALTYPES.INTEGERARRAY');

  C.Dim('ID',Input.GetParamByName('ID'));
  C.Execute('SELECT * FROM SI_ORDENS_SERVICO WHERE ORDEM_SERVICO =:ID');
  Grupo := C.GetFieldAsString('GRUPO');
  if Grupo <> '' then
  begin
    C.Dim('GRUPO',Grupo);
    C.Execute('SELECT * FROM SI_ORDENS_SERVICO WHERE GRUPO =:GRUPO');
  end;
  OS := C.CreateRecordset;

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
      raise Exception.Create('É necessário todas as ordens estejam no mesmo status.');
    Status := OS.GetFieldByName('STATUS');
    OS.Next;
  end;

  //1-AG. FATURAMENTO ENTRADA
  //2-AG. FATURAMENTO
  if (Status <> 1) and (Status <> 4) then
    raise Exception.Create('Status não permitido para o faturamento. Permitidos AG. FATURAMENTO ENTRADA ou AG. FATURAMENTO');

  OS.First;
  Cliente := OS.GetFieldByName('CLIENTE');
  while not OS.EOF do
  begin
    if Cliente <> VarToIntDef(OS.GetFieldByName('CLIENTE'),-1) then
      raise Exception.Create('Os ordens selecionadas, não são todas do mesmo cliente.');
    Cliente := OS.GetFieldByName('CLIENTE');
    OS.Next;
  end;

  OS.First;
  EmGarantia := VarToBool(OS.GetFieldByName('GARANTIA'));
  while not OS.EOF do
  begin
    if EmGarantia <> VarToBool(OS.GetFieldByName('GARANTIA')) then
      raise Exception.Create('Não é permitido no mesmo faturamento produtos em garantia e produtos fora de garantia.');
    EmGarantia := VarToBool(OS.GetFieldByName('GARANTIA'));
    OS.Next;
  end;

  OS.First;
  ComErro := VarToBool(OS.GetFieldByName('ERRO'));
  while not OS.EOF do
  begin
    if ComErro <> VarToBool(OS.GetFieldByName('ERRO')) then
      raise Exception.Create('Não é permitido faturamento de ordem de serviço com erro.');
    ComErro := VarToBool(OS.GetFieldByName('ERRO'));
    OS.Next;
  end;

  Filial := GetConfigSrv.ReadParamInt('SI_FILIAL',-1);

  C.Dim('FILIAL',Filial);
  C.Execute('SELECT F.NOME, EC.ESTADO FROM FILIAIS F '+
            'LEFT JOIN ENDERECOS_CADASTRO EC ON (EC.GERADOR = F.GERADOR) AND (EC.ENDERECO_NOTA = "T") '+
            'WHERE F.FILIAL=:FILIAL');
  EstadoFilial := C.GetFieldAsString('ESTADO');
  if EstadoFilial='' then
    raise Exception.Create('Filial '+C.GetFieldAsString('NOME')+' com endereço sem estado para faturamento.');

  C.Dim('CLIENTE',Cliente);
  C.Execute('SELECT C.NOME, EC.ESTADO FROM CLIENTES C '+
            'LEFT JOIN ENDERECOS_CADASTRO EC ON (EC.GERADOR = C.GERADOR) AND (EC.ENDERECO_NOTA = "T") '+
            'WHERE C.CLIENTE=:CLIENTE');
  EstadoCliente := C.GetFieldAsString('ESTADO');
  if EstadoFilial='' then
    raise Exception.Create(' com endereço sem estado para faturamento');

  DentroDoEstado := SameText(EstadoFilial,EstadoCliente);

  //Faturamento de Entrada
  FaturamentoEntrada := Status=1;
  if FaturamentoEntrada then
  begin
    TabelaPreco := GetConfigSrv.ReadParamInt('SI_TABELA_PRECO_ENTRADA',-1);
    if DentroDoEstado and EmGarantia then
      CFOP := GetConfigSrv.ReadParamInt('SI_CFOP_ENT_DE_GAR',-1);

    if DentroDoEstado and not EmGarantia then
      CFOP := GetConfigSrv.ReadParamInt('SI_CFOP_ENT_DE_FOR_GAR',-1);

    if not DentroDoEstado and EmGarantia then
      CFOP := GetConfigSrv.ReadParamInt('SI_CFOP_ENT_FE_GAR',-1);

    if not DentroDoEstado and not EmGarantia then
      CFOP := GetConfigSrv.ReadParamInt('SI_CFOP_ENT_FE_FOR_GAR',-1);
  end else//Faturamento de Saida
  begin
    TabelaPreco := GetConfigSrv.ReadParamInt('SI_TABELA_PRECO_SAIDA',-1);
    if DentroDoEstado and EmGarantia then
      CFOP := GetConfigSrv.ReadParamInt('SI_CFOP_SAI_DE_GAR',-1);

    if DentroDoEstado and not EmGarantia then
      CFOP := GetConfigSrv.ReadParamInt('SI_CFOP_SAI_DE_FOR_GAR',-1);

    if not DentroDoEstado and EmGarantia then
      CFOP := GetConfigSrv.ReadParamInt('SI_CFOP_SAI_FE_GAR',-1);

    if not DentroDoEstado and not EmGarantia then
      CFOP := GetConfigSrv.ReadParamInt('SI_CFOP_SAI_FE_FOR_GAR',-1);

    if DentroDoEstado and EmGarantia then
      CFOPDev := GetConfigSrv.ReadParamInt('SI_CFOP_DEV_DE_GAR',-1);

    if DentroDoEstado and not EmGarantia then
      CFOPDev := GetConfigSrv.ReadParamInt('SI_CFOP_DEV_DE_FOR_GAR',-1);

    if not DentroDoEstado and EmGarantia then
      CFOPDev := GetConfigSrv.ReadParamInt('SI_CFOP_DEV_FE_GAR',-1);

    if not DentroDoEstado and not EmGarantia then
      CFOPDev := GetConfigSrv.ReadParamInt('SI_CFOP_DEV_FE_FOR_GAR',-1);
  end;

  //Verificando se existe alguma nota já emitida para este evento
  OS.First;
  C.Dim('EVENTO',Input.GetParamByName('EVENTO'));
  C.DimAsData('OSS',OS);
  C.Execute('SELECT NF.NOTA FROM SI_ORDENS_SERVICO_NFS OSNF '+
            'INNER JOIN MOVIMENTO M ON (M.TIPO_OPERACAO = OSNF.TIPO_OPERACAO) AND '+
            '                          (M.COD_OPERACAO = OSNF.COD_OPERACAO) '+
            'INNER JOIN NF ON (NF.TIPO_OPERACAO = M.TIPO_OPERACAO) AND '+
            '                 (NF.COD_OPERACAO = M.COD_OPERACAO) AND '+
            '                 (NF.CANCELADA = FALSE) '+
            'WHERE ORDEM_SERVICO IN #MAKELIST(OSS,ORDEM_SERVICO)');
   if not C.EOF then
     raise Exception.Create('Nota fiscal já emitida para este evento. NF: '+C.GetFieldAsString('NOTA'));         

  OS.First;
  Itens.DimAsData('OSS',OS);
  if FaturamentoEntrada then
    Itens.Execute('SELECT * FROM SI_ORDENS_SERVICO_PRODUTOS WHERE ORDEM_SERVICO IN #MAKELIST(OSS,ORDEM_SERVICO) AND EQUIPAMENTO="T" AND QUANTIDADE > 0')
  else
    Itens.Execute('SELECT PRODUTO,COR,ESTAMPA,TAMANHO,NUMERO_PRODUTO,AVG(PRECO) AS PRECO,EQUIPAMENTO,SUM(QUANTIDADE) AS QUANTIDADE,NUMERO_SERIE '+
                  'FROM SI_ORDENS_SERVICO_PRODUTOS '+
                  'WHERE ORDEM_SERVICO IN #MAKELIST(OSS,ORDEM_SERVICO) AND '+
                  '      EQUIPAMENTO IN ("T","F") '+
                  'GROUP BY PRODUTO,COR,ESTAMPA,TAMANHO,NUMERO_PRODUTO,EQUIPAMENTO,NUMERO_SERIE '+
                  'HAVING SUM(QUANTIDADE) > 0');
  OS.First;

  while not Itens.EOF do
  begin
    Preco := VarToFloat(Itens.GetFieldByName('PRECO'));
    IsEquipamento := SameText(Itens.GetFieldAsString('EQUIPAMENTO'),'T');
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
      raise Exception.Create('Produto '+Itens.GetFieldAsString('NUMERO_PRODUTO')+' sem preço.');

    Produtos.New;
    Produtos.SetFieldByName('PRODUTO',Itens.GetFieldByName('PRODUTO'));
    Produtos.SetFieldByName('COR',Itens.GetFieldByName('COR'));
    Produtos.SetFieldByName('ESTAMPA',Itens.GetFieldByName('ESTAMPA'));
    Produtos.SetFieldByName('TAMANHO',Itens.GetFieldByName('TAMANHO'));
    Produtos.SetFieldByName('QUANTIDADE',Itens.GetFieldByName('QUANTIDADE'));
    Produtos.SetFieldByName('PRECO',Preco);
    Produtos.SetFieldByName('CFOP',CFOP);
    
    if IsEquipamento and not FaturamentoEntrada then
      Produtos.SetFieldByName('CFOP',CFOPDev);

    if IsEquipamento then
      Produtos.SetFieldByName('LOTE',Copy(Itens.GetFieldAsString('NUMERO_SERIE'),1,20));
    Produtos.Add;

    Itens.Next;
  end;

  Movimento.New;
  Movimento.SetFieldByName('TABELA',TabelaPreco);
  Movimento.SetFieldByName('FILIAL',Filial);
  Movimento.SetFieldByName('CLIENTE',Cliente);
  Movimento.SetFieldByName('PRODUTOS',Produtos);
  Movimento.SetFieldByName('SI_ORDENS_SERVICO',OSBaixa);
  Movimento.Add;

  Output.NewRecord;
  Output.SetFieldByName('MOVIMENTO',Movimento.Data);
end;



initialization
   wtsRegisterProc('ORDENS_SERVICO.ReavaliarRelacionamentos',ReavaliarRelacionamentos);
   wtsRegisterProc('ACER.ImportarArquivosXML',ImportarArquivosXML);
   wtsRegisterProc('ACER.ImportarOrdens',ImportarOrdens);
   wtsRegisterProc('ACER.ImportarProdutos',ImportarProdutos);
   wtsRegisterProc('ACER.ImportarFechamento',ImportarFechamento);
   wtsRegisterProc('MOVIMENTACAO.DadosFaturamentoGenerico', DadosFaturamentoGenerico);
   
end.

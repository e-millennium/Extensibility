unit millenium_saldaoinformatica_acer;

interface

uses
  Windows, Classes, wtsServerObjs, SysUtils, ServerCfgs, millenium_variants,
  XMLAcer,wtsIntf,EcoUtils,ComObj,ActiveX,Excel2000,millennium_uteis,checkcgc;

type
  TPecaFaturamento = (pfEquipamentos,ptPecasGarantia,ptPecasForaGarantia);
  TPecasFaturamento = set of TPecaFaturamento;

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
          raise Exception.Create('CPF\CNPJ Inválido '+CPFCNPJFormartado);

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
  //Caso exista Issue e UnIssue ñão processado, não vamos importar os OutBound 
  T.Execute('SELECT T.EVENTHEADER,OS.ORDEM_SERVICO '+
            'FROM ACER_TICKETEVENTHEADER T '+
            'INNER JOIN ACER_TICKETEVENTDETAIL D ON (D.EVENTHEADER = T.EVENTHEADER) '+
            'INNER JOIN SI_ORDENS_SERVICO OS ON (OS.COD_ORDEM_SERVICO = T.CSSTICKETNUMBER) '+
            'WHERE UPPER(T.EVENTTYPE) IN ("OUTBOUND") AND '+
            '      T.ORDEM_SERVICO IS NULL AND '+
            '      OS.STATUS IN (2,3) AND '+
            '      OS.ERRO = FALSE AND '+
            '      NOT EXISTS (SELECT 1 #TOP(1) FROM ACER_TICKETEVENTHEADER I '+
            '                  WHERE I.CSSTICKETNUMBER = T.CSSTICKETNUMBER AND '+
            '                        UPPER(I.EVENTTYPE) IN ("ISSUE","UNISSUE") AND '+
            '                        I.ORDEM_SERVICO IS NULL)');
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
  Itens,C: IwtsCommand;
  OSBaixa, OS,Movimento, Produtos, EstoqueLote, PrioridadeLotes: IwtsWriteData;
  Cliente,Status,TabelaPreco,Filial,Evento: Integer;
  Preco: Real;
  CFOP:Variant;
  EstadoFilial,EstadoCliente,Grupo,Lote,UltimaGrupoCFOP,S:string;
  EmGarantia,DentroDoEstado,ComErro,FaturamentoEntrada,IsEquipamento,ContribuinteICMS,
  Devolucao,AcessaLote,EventoPorClassCliente,ControlaLote:Boolean;
  PecasFaturamento:TPecasFaturamento;

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

  function EncontraLote(const AProduto,ACor,AEstampa:Integer;ATamanho:string; var ALote:string): Boolean;
  var
    C: IwtsCommand;
    CMDFilter:string;
  begin
    Result := False;
    ALote := '';
    //CMDFilter := '(PRODUTO="'+IntToStr(AProduto)+'") AND (COR="'+IntToStr(ACor)+'") AND (ESTAMPA="'+IntToStr(AEstampa)+'") AND (TAMANHO="'+ATamanho+'")';
    //EstoqueLote.Filter := '';
    //EstoqueLote.Filter := CMDFilter;
    PrioridadeLotes.First;
    while not PrioridadeLotes.EOF do
    begin
      if EstoqueLote.Locate(['PRODUTO','COR','ESTAMPA','TAMANHO','LOTE'],[AProduto,ACor,AEstampa,ATamanho,PrioridadeLotes.GetFieldAsString('ITEM')]) then
      begin
        ALote := PrioridadeLotes.GetFieldAsString('ITEM');
        Break;
      end;
      PrioridadeLotes.Next;
    end;  
    Result := (ALote <> '');
  end;

  function MakeyKeyCFOP(const AClassificaoProduto,ALote:string;AContribuinte,ADentroDoEstado,ADevolucao:Boolean):string;
  begin
    Result := AClassificaoProduto+'|'+ALote+'|'+BoolToStr(AContribuinte)+'|'+BoolToStr(ADentroDoEstado)+'|'+BoolToStr(ADevolucao);
  end;

begin
  C := DataPool.Open('MILLENIUM');
  Itens  := DataPool.Open('MILLENIUM');

  Evento := Input.GetParamByName('EVENTO');
  Movimento := DataPool.CreateRecordset('MILLENIUM.MOVIMENTACAO.EXECUTA');
  Produtos := DataPool.CreateRecordset('Millenium.EVENTOS.PRODUTOS');
  OSBaixa := DataPool.CreateRecordset('WTSSYSTEM.INTERNALTYPES.INTEGERARRAY');

  //Dados do evento
  C.Dim('EVENTO',Evento);
  C.Execute('SELECT TIPO_EVENTO,ACESSA_LOTE FROM EVENTOS WHERE EVENTO=:EVENTO');
  AcessaLote := VarToBool(C.GetFieldByName('ACESSA_LOTE'));
  FaturamentoEntrada := C.GetFieldAsString('TIPO_EVENTO')='E';

  //Ordem de Servico ou Grupo de Ordem de Serviço
  C.Dim('ID',Input.GetParamByName('ID'));
  C.Execute('SELECT * FROM SI_ORDENS_SERVICO WHERE ORDEM_SERVICO =:ID');
  OS := C.CreateRecordset;
  Cliente := OS.GetFieldByName('CLIENTE');
  Grupo := OS.GetFieldAsString('GRUPO');

  EventoPorClassCliente := False;
  if FaturamentoEntrada then
  begin
    PecasFaturamento := [pfEquipamentos];
  end else
  begin
    //Descobrir se o evento que esta no processamento, se está configurado na classificaçao do cliente
    C.Dim('CLIENTE',Cliente);  
    C.Execute('SELECT CLS.EVENTO_EQUIPAMENTO, CLS.EVENTO_GARANTIA, CLS.EVENTO_FORA_GARANTIA,CLS.EVENTO_RETORNO_CONSIGNACAO FROM CLIENTES C '+
              'LEFT JOIN SI_CLASSIFICACAO_CLIENTE CLS ON (CLS.CLASSIFICACAO_CLIENTE = C.CLSCLIENTE) '+
              'WHERE C.CLIENTE=:CLIENTE');

    //Se tiver configurado por classificação do cliente, indica que cada evento só irá faturar um tipo de produto
    PecasFaturamento := [];
    if (Evento = VarToIntDef(C.GetFieldByName('EVENTO_EQUIPAMENTO'),-MaxInt)) then
      PecasFaturamento := [pfEquipamentos];

    if (Evento = VarToIntDef(C.GetFieldByName('EVENTO_GARANTIA'),-MaxInt)) then
      PecasFaturamento := [ptPecasGarantia];

    if (Evento = VarToIntDef(C.GetFieldByName('EVENTO_FORA_GARANTIA'),-MaxInt)) then
      PecasFaturamento := [ptPecasForaGarantia];

    if (Evento = VarToIntDef(C.GetFieldByName('EVENTO_RETORNO_CONSIGNACAO'),-MaxInt)) then
      PecasFaturamento := [ptPecasForaGarantia];

    //Nada configurado por classificão do cliente, então o mesmo evento faz tudo, paramentros gerais
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
  begin                      //Nas devoluções de peças, não podemos considerar Com e Sem Garantia. Faturamos tudo junto
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
      raise Exception.Create('É necessário todas as ordens estejam no mesmo status.');
      
    if OS.GetFieldByName('STATUS') <> 5 then//Quando o faturamento é por grupo, acontece o faturamento de os por os, não devemos validar
      Status := OS.GetFieldByName('STATUS');

    OS.Next;
  end;
  
  //1-AG. FATURAMENTO ENTRADA
  //2-AG. FATURAMENTO
  //5-FINALIZADO
  if (Status <> 1) and (Status <> 4) and (Status <> 5) then
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

  if not FaturamentoEntrada and not (PecasFaturamento = [pfEquipamentos]) then
  begin
    OS.First;
    EmGarantia := VarToBool(OS.GetFieldByName('GARANTIA'));
    while not OS.EOF do
    begin
      if EmGarantia <> VarToBool(OS.GetFieldByName('GARANTIA')) then
        raise Exception.Create('Não é permitido no mesmo faturamento produtos em garantia e produtos fora de garantia.');
      EmGarantia := VarToBool(OS.GetFieldByName('GARANTIA'));
      OS.Next;
    end;
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

  //Dados da filial
  Filial := GetConfigSrv.ReadParamInt('SI_FILIAL',-1);
  C.Dim('FILIAL',Filial);
  C.Execute('SELECT F.NOME, EC.ESTADO FROM FILIAIS F '+
            'LEFT JOIN ENDERECOS_CADASTRO EC ON (EC.GERADOR = F.GERADOR) AND (EC.ENDERECO_NOTA = "T") '+
            'WHERE F.FILIAL=:FILIAL');
  EstadoFilial := C.GetFieldAsString('ESTADO');
  if EstadoFilial='' then
    raise Exception.Create('Filial '+C.GetFieldAsString('NOME')+' com endereço sem estado para faturamento.');

  //Dados do cliente  
  C.Dim('CLIENTE',Cliente);
  C.Execute('SELECT C.NOME, C.CONTRIBUINTE_ICMS, EC.ESTADO FROM CLIENTES C '+
            'LEFT JOIN ENDERECOS_CADASTRO EC ON (EC.GERADOR = C.GERADOR) AND (EC.ENDERECO_NOTA = "T") '+
            'WHERE C.CLIENTE=:CLIENTE');

  EstadoCliente := C.GetFieldAsString('ESTADO');
  if EstadoCliente='' then
    raise Exception.Create('Cliente com endereço sem estado para faturamento');

  ContribuinteICMS := VarToBool(C.GetFieldByName('CONTRIBUINTE_ICMS'));
  DentroDoEstado := SameText(EstadoFilial,EstadoCliente);

  if FaturamentoEntrada then
    TabelaPreco := GetConfigSrv.ReadParamInt('SI_TABELA_PRECO_ENTRADA',-1)
  else
    TabelaPreco := GetConfigSrv.ReadParamInt('SI_TABELA_PRECO_SAIDA',-1);

  //Verificando se existe alguma nota já emitida para este evento
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
     raise Exception.Create('Nota fiscal já emitida para este evento. NF: '+C.GetFieldAsString('NOTA'));         

  UltimaGrupoCFOP := '';
  if FaturamentoEntrada then
  begin
    Itens.Dim('TIPO',0);
  end else
  begin
    if (pfEquipamentos in PecasFaturamento) and ((ptPecasGarantia in PecasFaturamento) or (ptPecasForaGarantia in PecasFaturamento)) then
      Itens.Dim('TIPO',2)//Equipamento e peças
    else
    if (not (pfEquipamentos in PecasFaturamento)) and ((ptPecasGarantia in PecasFaturamento) or (ptPecasForaGarantia in PecasFaturamento)) then
      Itens.Dim('TIPO',1)//Somente peças
    else
    if (pfEquipamentos in PecasFaturamento) and not ((ptPecasGarantia in PecasFaturamento) or (ptPecasForaGarantia in PecasFaturamento)) then
      Itens.Dim('TIPO',0);//Somente peças
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
            'ORDER BY FILIAL,PRODUTO,COR,ESTAMPA,TAMANHO,LOTE');
  EstoqueLote := C.CreateRecordset;

  PrioridadeLotes
   := GetConfigSrv.CreateRecordSet('SI_ORDEM_LOTES');

  Itens.First;
  while not Itens.EOF do
  begin
    Preco := VarToFloat(Itens.GetFieldByName('PRECO'));
    IsEquipamento := SameText(Itens.GetFieldAsString('EQUIPAMENTO'),'T');
    Devolucao := (not FaturamentoEntrada) and IsEquipamento;
    ControlaLote := Itens.GetFieldAsString('CONTROLA_LOTE') = 'T';

    Lote := '';
    if IsEquipamento then
      Lote := Copy(Itens.GetFieldAsString('NUMERO_SERIE'),1,20)
    else
    if AcessaLote and ControlaLote then
    begin
      if not EncontraLOTE(Itens.GetFieldByName('PRODUTO'),Itens.GetFieldByName('COR'),Itens.GetFieldByName('ESTAMPA'),Itens.GetFieldAsString('TAMANHO'),Lote) then
        raise Exception.Create('Não há estoque com lote disponível para o produto '+Itens.GetFieldAsString('NUMERO_PRODUTO'));
    end;

    S := MakeyKeyCFOP(Itens.GetFieldAsString('CLASS_PROD'),Lote,ContribuinteICMS,DentroDoEstado,Devolucao);
    if S <> UltimaGrupoCFOP then
    begin
      UltimaGrupoCFOP := S;
      if not EncontraCFOP(Evento,Itens.GetFieldAsString('CLASS_PROD'),Lote,ContribuinteICMS,DentroDoEstado,Devolucao,CFOP) then
        raise Exception.Create('CFOP não encontrada para o produto '+Itens.GetFieldAsString('NUMERO_PRODUTO'));
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
      raise Exception.Create('Produto '+Itens.GetFieldAsString('NUMERO_PRODUTO')+' sem preço.');

    Produtos.New;
    Produtos.SetFieldByName('PRODUTO',Itens.GetFieldByName('PRODUTO'));
    Produtos.SetFieldByName('COR',Itens.GetFieldByName('COR'));
    Produtos.SetFieldByName('ESTAMPA',Itens.GetFieldByName('ESTAMPA'));
    Produtos.SetFieldByName('TAMANHO',Itens.GetFieldByName('TAMANHO'));
    Produtos.SetFieldByName('QUANTIDADE',Itens.GetFieldByName('QUANTIDADE'));
    Produtos.SetFieldByName('PRECO',Preco);
    Produtos.SetFieldByName('CFOP',CFOP);
    Produtos.SetFieldByName('LOTE',Lote);
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
              '       (SELECT SUM(P.QUANTIDADE) '+
              '        FROM SI_ORDENS_SERVICO_PRODUTOS P '+
              '        WHERE P.ORDEM_SERVICO = OS.ORDEM_SERVICO AND P.EQUIPAMENTO = FALSE) AS QUANTIDADE_PECAS '+
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
          raise Exception.Create('É necessário todas as ordens estejam no mesmo status.');
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
          raise Exception.Create('É necessário todas as ordens estejam no mesmo status(Garantia e Fora de Garantia).');
        Garantia := G.GetFieldByName('GARANTIA');
        G.Next;
      end;
    end;

    if not SomenteEventosNaoUsados then
      if (Status <> 1) and (Status <> 4)  then
        raise Exception.Create('Status não permitido para o faturamento. Permitidos AG. FATURAMENTO ENTRADA ou AG. FATURAMENTO');

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

        if QuantidadePecas > 0 then//Só existe faturamento de saida se tiver peças consumidas
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

            Eventos.New;
            Eventos.SetFieldByName('ITEM',EventoRetornoConsignacao);
            Eventos.Add;
          end;
        end;
      end;

      G.Next;
    end;
  end else
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

      if QuantidadePecas > 0 then//Só existe faturamento de saida se tiver peças consumidas
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

          Eventos.New;
          Eventos.SetFieldByName('ITEM',EventoRetornoConsignacao);
          Eventos.Add;
        end;
      end;
    end;
  end;

  //Vamos detectar todos os eventos que já ocorreram, assim removemos da lista
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
  if Status = 4 then //Só faz sentido esta verificação quando é AG. Faturamento de saida
  begin
     //ListaEventosPorClassificaoCliente só retorna eventos que ainda não foram faturados
     C.Execute('#CALL MILLENIUM!SALDAOINFORMATICA.ORDENS_SERVICO.ListaEventosPorClassificaoCliente(ORDEM_SERVICO=:ORDEM_SERVICO,SOMENTE_NAO_USADO=TRUE)');
     PermitirAlterarStatus := C.EOF;
  end;

  if PermitirAlterarStatus then
    C.Execute('UPDATE SI_ORDENS_SERVICO SET STATUS = #IF(STATUS=1,2,5) WHERE ORDEM_SERVICO=:ORDEM_SERVICO;');
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

   wtsRegisterProc('ESTOQUES.GerarExcelConciliacao',GerarExcelConciliacao);
end.


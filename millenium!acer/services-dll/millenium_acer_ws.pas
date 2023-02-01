unit millenium_acer_ws;

interface

uses
  wtsServerObjs, SysUtils, Windows,Classes, ServerCfgs, XSBuiltIns, ActiveX,
  xmldom, XMLIntf, msxmldom, XMLDoc;


implementation

uses TicketEventWebService;

procedure AssignParams(var ACode, AWSUrl, AUsuario, ASenha, ARequest:string);
begin
  ACode := GetConfigSrv.ReadParamStr('SI_CODIGO_CER','');
  AWSUrl := LowerCase(GetConfigSrv.ReadParamStr('SI_URL_ACER',''));
  AUsuario := GetConfigSrv.ReadParamStr('SI_USUARIO_ACER','');
  ASenha := GetConfigSrv.ReadParamStr('SI_SENHA_ACER','');
  ARequest := GetConfigSrv.ReadParamStr('SI_REQUEST_ACER','');
end;

function RecursiveFindNode(ANode: IXMLNode; const SearchNodeName: string): String;
var
  I: Integer;
begin
  if CompareText(ANode.NodeName, SearchNodeName) = 0 then
    begin
      if Assigned(ANode) then result := ANode.Text;
    end
  else if not Assigned(ANode.ChildNodes) then Result := ''
  else begin
    for I := 0 to ANode.ChildNodes.Count - 1 do
    begin
      Result := RecursiveFindNode(ANode.ChildNodes[I], SearchNodeName);
      if Result  <> '' then Exit;
    end;
  end;
end;

procedure SaveFile(AXMLData:TXMLData;AType:string);
var
  XML: TStringList;
  XMLText,FileName: string;
  NodeTrailer,NodeFile:IXMLNode;
begin
  if (AXMLData=nil) or (AXMLData.XMLNode=nil) then
    Exit;

  XMLText := AXMLData.XMLNode.XML;
  if Pos('No Data Found',XMLText) > 0 then
    Exit;

  FileName := RecursiveFindNode(AXMLData.XMLNode,'FILE_NAME');
  if FileName='' then
    FileName := RecursiveFindNode(AXMLData.XMLNode.NextSibling,'FILE_NAME');

  if FileName<>'' then
    FileName := ChangeFileExt(FileName,'.pdt')
  else
    FileName := FormatDateTime('yyyymmddhhnnsszzz',Now)+'_'+AType;

  XML := TStringList.Create;
  try
    XMLText := StringReplace(XMLText,'encoding="UTF-8"','encoding="ISO-8859-1"',[]);
    XML.Add(XMLText);
    XML.SaveToFile(ExtractFilePath(ParamStr(0))+'\css_files\'+FileName);
  finally
    XML.Free;
  end;
end;

function CreateXMLBodySystemAcknowledgement(const ACode,AFileName:string):string;
var
  FN:string;
begin
  FN := ChangeFileExt(AFileName,'.xml');
  Result := '<ns:PipSystemAcknowledgement xmlns:ns="http://www.acer.com.tw/rod/xmlschema/PipSystemAcknowledgement">'+
            '   <ns:TransmissionDocumentCategory>ABBSACK</ns:TransmissionDocumentCategory>'+
            '   <ns:TransmissionDocumentDateTime>'+
            '      <ns:DateTimeStamp>'+FormatDateTime('yyyymmddhhnnss',Now)+'</ns:DateTimeStamp>'+
            '   </ns:TransmissionDocumentDateTime>'+
            '   <ns:TransmissionDocumentIdentifier>'+
            '      <ns:ProprietaryDocumentIdentifier />'+
            '   </ns:TransmissionDocumentIdentifier>'+
            '   <ns:StatusInformation>'+
            '      <ns:Status>'+ACode+'-Success</ns:Status>'+
            '      <ns:StatusDescription>'+
            '         <ns:StatusCode>'+ACode+'-Success</ns:StatusCode>'+
            '         <ns:TransactionRef>'+FN+'</ns:TransactionRef>'+
            '         <ns:Description>'+ACode+'-Success</ns:Description>'+
            '      </ns:StatusDescription>'+
            '   </ns:StatusInformation>'+
            '</ns:PipSystemAcknowledgement>';
end;

function CreateXMLBodySystemAcknowledgementTicket(const ACode,AFileName:string;ATickets:TStringList):string;
var
  I: Integer;
  Tcks:string;
begin
  Tcks := '';
  for I := 0 to ATickets.Count - 1 do
  begin
    Tcks := Tcks + '      <ns:StatusDescription>'+
                   '         <ns:StatusCode>'+ACode+'-Success</ns:StatusCode>'+
                   '         <ns:CSSTicketId>'+Trim(ATickets[I])+'</ns:CSSTicketId>'+
                   '         <ns:Description />'+
                   '      </ns:StatusDescription>';
  end;

  Result := '<ns:PipSystemAcknowledgement xmlns:ns="http://www.acer.com.tw/rod/xmlschema/PipSystemAcknowledgement">'+
            '   <ns:TransmissionDocumentCategory>ABBSACK</ns:TransmissionDocumentCategory>'+
            '   <ns:TransmissionDocumentDateTime>'+
            '      <ns:DateTimeStamp>'+FormatDateTime('yyyymmddhhnnss',Now)+'</ns:DateTimeStamp>'+
            '   </ns:TransmissionDocumentDateTime>'+
            '   <ns:TransmissionDocumentIdentifier>'+
            '      <ns:ProprietaryDocumentIdentifier>'+AFileName+'</ns:ProprietaryDocumentIdentifier>'+
            '   </ns:TransmissionDocumentIdentifier>'+
            '   <ns:StatusInformation>'+
            '      <ns:Status>'+ACode+'-Success</ns:Status>'+
                   Tcks+
            '   </ns:StatusInformation>'+
            '</ns:PipSystemAcknowledgement>';
end;

procedure AssignPDTACER(APath: string; AFiles: TStringList);
var
  F: TSearchRec;
  Ret: Integer;
  function TemAtributo(Attr, Val: Integer): Boolean;
  begin
    Result := Attr and Val = Val;
  end;
begin
  Ret := FindFirst(LowerCase(APath+'*.pdt'), faAnyFile, F);
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
    FindClose(F.FindHandle);
  end;
end;

procedure ScanPDTFile;
var
  TicketEventWebService: TicketEventWebServiceSoap;
  XMLData: TXMLData;
  XML: WideString;
  FileName,NewFileName:string;
  SL: TStringList;
  Files:TStringList;
  I: Integer;
  Code,URL,Usuario,Senha,Request:string;
begin
  AssignParams(Code,URL,Usuario,Senha,Request);
  TicketEventWebService := GetTicketEventWebServiceSoap(False,URL);
  Files := TStringList.Create;
  try
    AssignPDTACER(ExtractFilePath(ParamStr(0))+'css_files\',Files);
    for I  := 0 to Files.Count-1 do
    begin
      FileName := Files[I];
      XMLData := TXMLData.Create;
      try
        XML := CreateXMLBodySystemAcknowledgement('CNS',ExtractFileName(FileName));
        XMLData.LoadFomXML(XML);
        XML := TicketEventWebService.UpdateFileACKStatus(XMLData,Request,Usuario,Senha);
        if Pos('Successfully',XML) > 0 then
        begin
          NewFileName := ChangeFileExt(FileName,'.xml');
          RenameFile(FileName,NewFileName);
        end else
        begin
          SL := TStringList.Create;
          try
            SL.Add(XML);
            SL.SaveToFile(FileName+'.erro');
          finally
            SL.Free;
          end;
        end;
      finally
        XMLData.Free;
      end;
    end;
  finally
    Files.Free;
  end;
end;

procedure DonwloadXML(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  TicketEventWebService: TicketEventWebServiceSoap;
  XMLData:TXMLData;
  sl: TStringList;
  Code,URL,Usuario,Senha,Request:string;
begin
  CoInitialize(nil);
  AssignParams(Code,URL,Usuario,Senha,Request);
  TicketEventWebService := GetTicketEventWebServiceSoap(False,URL);
  try
    XMLData := TicketEventWebService.GetInBoundData(Code,Usuario,Senha);
    SaveFile(XMLData,'InBound');

    XMLData := TicketEventWebService.GetIssuedData(Code,Usuario,Senha);
    SaveFile(XMLData,'Issued');

    XMLData := TicketEventWebService.GetUnIssueData(Code,Usuario,Senha);
    SaveFile(XMLData,'UnIssue');

    XMLData := TicketEventWebService.GetOutBoundData(Code,Usuario,Senha);
    SaveFile(XMLData,'OutBound');

    {sl := TStringList.Create;
    sl.LoadFromFile('C:\wts\css_files\20171005180031962_InBound');
    XMLData := TXMLData.Create;
    XMLData.LoadFomXML(sl.Text);
    SaveFile(XMLData,'MOCK');
    XMLData.Free;}

    ScanPDTFile;
  finally
    CoUninitialize;
  end;
end;

procedure UpdateTicketACKStatus(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  XMLData: TXMLData;
  TicketEventWebService: TicketEventWebServiceSoap;
  C,X: IwtsCommand;
  SL: TStringList;
  XML:WideString;
  Tickets: TStringList;
  URL,Code,Usuario,Senha,Request:string;
  Sl1: TStringList;

begin
  C := DataPool.Open('MILLENIUM');
  X := DataPool.Open('MILLENIUM');

  AssignParams(Code,URL,Usuario,Senha,Request);
  TicketEventWebService := GetTicketEventWebServiceSoap(False,URL);

  Tickets := TStringList.Create;
  CoInitialize(nil);
  try
    C.Execute('SELECT XMLFILENAME,LIST(EVENTHEADER) AS EVENTHEADER, LIST(CSSTICKETNUMBER) AS CSSTICKETNUMBER '+
              'FROM ACER_TICKETEVENTHEADER '+
              'WHERE XMLFILENAME <> "" AND ACKSTATUS="0" '+
              'GROUP BY XMLFILENAME');
    while not C.EOF do
    begin
      XMLData := TXMLData.Create;
      try
        try
          Tickets.Clear;
          ExtractStrings([','],[],PChar(C.GetFieldAsString('CSSTICKETNUMBER')),Tickets);
          XML := CreateXMLBodySystemAcknowledgementTicket('CNS',C.GetFieldAsString('XMLFILENAME'),Tickets);
          XMLData.LoadFomXML(XML);

          Sl1 := TStringList.Create;
          Sl1.Add(XML);
          Sl1.SaveToFile('C:\wts\UPD-TICKET\REQ-'+FormatDateTime('DDNNYYYYHHNNZZ',Now));
          Sl1.Free;

          XML := TicketEventWebService.UpdateTicketACKStatus(XMLData,Request,Usuario,Senha);

          Sl1 := TStringList.Create;
          Sl1.Add(XML);
          Sl1.SaveToFile('C:\wts\UPD-TICKET\RES-'+FormatDateTime('DDNNYYYYHHNNZZ',Now));
          Sl1.Free;


          if Pos('Successfully',XML) > 0 then
          begin
            X.Dim('EVENTHEADER',C.GetFieldAsString('EVENTHEADER'));
            X.Execute('UPDATE ACER_TICKETEVENTHEADER SET ACKSTATUS="1" WHERE EVENTHEADER IN (#REPLACE(:EVENTHEADER))' )
          end else
            raise Exception.Create(XML);
        except on e: exception do
          begin
            X.Dim('EVENTHEADER',C.GetFieldAsString('EVENTHEADER'));
            X.Dim('MSG_ERROR',e.Message);
            X.Execute('UPDATE ACER_TICKETEVENTHEADER SET ACKSTATUS="2", MSG_ERROR=:MSG_ERROR WHERE EVENTHEADER IN (#REPLACE(:EVENTHEADER));');
          end;
        end;
      finally
        XMLData.Free;
      end;
      C.Next;
    end;
  finally
    CoUninitialize;
  end;
end;

initialization
   wtsRegisterProc('WS.DonwloadXML',DonwloadXML);
   wtsRegisterProc('WS.UpdateTicketACKStatus',UpdateTicketACKStatus);


end.

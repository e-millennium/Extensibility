unit millenium_ora_responsys_puher;

interface

uses
  wtsServerObjs,oracle_utils,JsonSerialization,Variants,Json,utf8;

implementation

function CreateJsonList(const AData: IwtsWriteData): string;
var
  I: Integer;
  FieldNames,FieldValues: string;
begin
  FieldNames := '';
  for I := 0 to AData.FieldCount - 1 do
    FieldNames := FieldNames + '"'+AData.FieldName(I)+'",';
  SetLength(FieldNames,Length(FieldNames)-1);

  AData.First;
  FieldValues := '';
  while not AData.EOF do
  begin
    FieldValues := FieldValues+'[';
    for I := 0 to AData.FieldCount - 1 do
      FieldValues := FieldValues + '"'+VarToStr(AData.AtIndex[I])+'",';
    SetLength(FieldValues,Length(FieldValues)-1);
    FieldValues := FieldValues+'],';
    AData.Next;
  end;
  SetLength(FieldValues,Length(FieldValues)-1);

  Result := '{'+
            ' "recordData":{'+
            '    "fieldNames":['+
                FieldNames +
            '    ],'+
            '    "records":[' +
                FieldValues +
            '    ],'+
            '    "mapTemplateName":null'+
            ' },'+
            ' "mergeRule":{'+
            '    "htmlValue":"H",'+
            '    "optinValue":"I",'+
            '    "textValue":"T",'+
            '    "insertOnNoMatch":true,'+
            '    "updateOnMatch":"REPLACE_ALL",'+
            '    "matchColumnName1":"CUSTOMER_ID_",'+
            '    "matchColumnName2":null,'+
            '    "matchOperator":"NONE",'+
            '    "optoutValue":"O",'+
            '    "rejectRecordIfChannelEmpty":null,'+
            '    "defaultPermissionStatus":"OPTIN"'+
            ' }'+
            '}';
end;

procedure Publisher(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C: IwtsCommand;
  I: Integer;
  JsonReq,JsonResp,ListName,Values,Msg,IDResponsys,IDMillennium: string;
  Pusher, RequestSQLData,SQLData: IwtsWriteData;
  JSONarray: TJSONarray;
  JsonRecords,JsonRecordItem: TJSONbase;
begin
  C := DataPool.Open('MILLENIUM');
  C.Execute('SELECT * FROM ORARES_PUSHER WHERE [ORARES_PUSHER=:ORARES_PUSHER] ORDER BY ORARES_PUSHER');
  Pusher := C.CreateRecordset;
  while not Pusher.EOF do
  begin
    ListName := Pusher.AsString['LIST_INFORMATION'];
    //Enviar dados da lista - Cria método
    if ListName<>'' then
    begin
      C.Dim('TRANS_ID',Pusher.Value['TRANS_ID']);
      C.Execute(PChar(Pusher.AsString['SQL']));
      SQLData := C.CreateRecordset;
      JsonReq := utf8.UTF8Encode(CreateJsonList(SQLData));
      JsonResp := RestClientCenter('post','/rest/api/v1.3/lists/'+ListName+'/members',JsonReq);

      JSONarray := ParseJSON(PChar(utf8.UTF8ToString(JsonResp)));
      JsonRecords := JSONarray.Field['recordData'].Field['records'];
      SQLData.First;
      for I := 0 to SQLData.RecordCount - 1 do
      begin
        JsonRecordItem := JsonRecords.Child[I].Child[0];
        IDMillennium := SQLData.AsString[PChar(Pusher.AsString['FIELDNAME_ID'])];
        IDResponsys := '-1';
        Msg := '';
        if Pos('MERGEFAILED',VarToStr(JsonRecordItem.Value)) > 0 then
          Msg := VarToStr(JsonRecordItem.Value)
        else
         IDResponsys := VarToStr(JsonRecordItem.Value);

       C.Dim('ORARES_PUSHER',Pusher.Value['ORARES_PUSHER']);
       C.Dim('ID_MILLENIUM',IDMillennium);
       C.Execute('DELETE FROM ORARES_PUSHER_LOGS WHERE ORARES_PUSHER=:ORARES_PUSHER AND ID_MILLENIUM=:ID_MILLENIUM');

       C.Dim('ORARES_PUSHER',Pusher.Value['ORARES_PUSHER']);
       C.Dim('ID_RESPONSYS',IDResponsys);
       C.Dim('ID_MILLENIUM',IDMillennium);
       C.Dim('MESSAGE',Msg);
       C.Execute('INSERT INTO ORARES_PUSHER_LOGS(ORARES_PUSHER,ID_RESPONSYS,ID_MILLENIUM,MESSAGE) VALUES (:ORARES_PUSHER,:ID_RESPONSYS,:ID_MILLENIUM,:MESSAGE) #RETURN(ORARES_PUSHER_LOG)');

       SQLData.Next;
      end;
    end;
    C.Dim('ORARES_PUSHER',Pusher.Value['ORARES_PUSHER']);
    C.Execute('UPDATE ORARES_PUSHER SET DATE_PUBLISHER=#NOW() WHERE ORARES_PUSHER=:ORARES_PUSHER');

    Pusher.Next;
  end;
end;

procedure LogList(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C: IwtsCommand;
  Pusher: IwtsWriteData;
begin
  C := DataPool.Open('MILLENIUM');
  C.Execute('SELECT SQL_LOG FROM ORARES_PUSHER WHERE ORARES_PUSHER=:ORARES_PUSHER');
  Pusher := C.CreateRecordset;
  C.Execute(Pusher.AsString['SQL_LOG']);
  Output.AssignData(C);
end;

initialization
   wtsRegisterProc('PUSHER.Publisher',Publisher);
   wtsRegisterProc('PUSHER.LogList',LogList);

end.

(*
C.Execute(PChar(Pusher.AsString['SQL']));
      SQLData := C.CreateRecordset;

      for I := 0 to SQLData.FieldCount - 1 do
      begin
        FieldNames.New;
        FieldNames.Value['ITEM'] := SQLData.FieldName(I);
        FieldNames.Add;
      end;

      SQLData.First;
      while not SQLData.EOF do
      begin
        Values := 0;
        for I := 0 to SQLData.RecordCount - 1 do
          Values := Values + '"'+VarToStr(SQLData.AtIndex[I])+'",';
        FieldNames.New;
        FieldNames.Value['ITEM'] := Values;
        FieldNames.Add;
        SQLData.Next;
      end;

      RecordData.New;
      RecordData.Value['fieldNames'] := FieldNames.Data;
      RecordData.Value['records'] := FieldValues.Data;
      RecordData.Value['mapTemplateName'] := Unassigned;
      RecordData.Add;

      Rules.New;
      Rules.Value['textValue'] := 'T';
      Rules.Value['optoutValue'] := 'O';
      Rules.Value['rejectRecordIfChannelEmpty'] := Unassigned;
      Rules.Value['defaultPermissionStatus'] := 'OPTIN';
      Rules.Value['htmlValue'] := 'H';
      Rules.Value['optinValue'] := 'I';
      Rules.Value['insertOnNoMatch'] := True;
      Rules.Value['updateOnMatch'] := 'REPLACE_ALL';
      Rules.Value['matchColumnName1'] := 'CUSTOMER_ID_';//Paramentri
      Rules.Value['matchColumnName'] := Unassigned;
      Rules.Value['matchOperator'] := 'NONE';
      Rules.Value['matchColumnName3'] := Unassigned;
      Rules.Add;

      Request.New;
      Request.Value['recordData'] := RecordData.Data;
      Request.Value['mapTemplateName'] := Unassigned;
      Request.Value['mergeRule'] := Rules.Data;
      Request.Add;
      JsonReq := ToJson(Request,[],True,);
      JsonResp := RestClientCenter('get','rest/api/v1.3/lists/'+ListName+'/members','');
    end;
*)

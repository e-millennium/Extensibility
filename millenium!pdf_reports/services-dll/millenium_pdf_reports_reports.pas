unit millenium_pdf_reports_reports;

interface

uses
  wtsServerObjs, Variants, MDORuntimeUIIntf, Classes, MDOCore;

implementation

procedure Process(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C: IwtsCommand;
  PromptInfo: TMDPromptInfo;
  SS: TStringStream;
  ParamsStr: string;
  Params,Param: TStringList;
  I: Integer;
begin
  C := DataPool.Open('MILLENIUM');
  ParamsStr := Input.AsString['PARAMETERS'];

  PromptInfo := TMDPromptInfo.Create;
  PromptInfo.universename := 'millenium.mdu';

  SS := TStringStream.Create('');
  try
    Params := TStringList.Create;
    Param :=  TStringList.Create;

    ExtractStrings(['='],[],PChar(ParamsStr),Params);
    for I := 0 to Params.Count - 1 do
    begin
      with PromptInfo.filters.Add do
      begin
        AttributeName := Params[0];
        FilterType := ftValue;
        ValueList.Add(Params[1]);
      end;
    end;

    PromptInfo.SaveToStream(SS);
    C.Dim('REPORT_SCHEMA',Unassigned);
    C.Dim('CATALOG_GUID',Input.AsString['CATALOG_GUID']);
    C.Dim('REPORT_TYPE','mda.report');
    C.Dim('REPORT_FORMAT','pdf');
    C.Dim('PARAMETERS',SS.DataString);
    C.Execute('#CALL WTSREPORTS.REPORTS.PROCESS(REPORT_SCHEMA=:REPORT_SCHEMA,CATALOG_GUID=:CATALOG_GUID,REPORT_TYPE=:REPORT_TYPE,REPORT_FORMAT=:REPORT_FORMAT,PARAMETERS=:PARAMETERS);');

    Output.NewRecord;
    Output.Values['DATA'] := C.Value['DATA'];
  finally
    PromptInfo.Free;
    SS.Free;
    Params.Free;
    Param.Free;
  end;
end;

initialization
  wtsRegisterProc('REPORTS.PROCESS',Process);
  
end.

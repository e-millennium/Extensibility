unit millenium_ora_responsys_api;

interface

uses
  wtsServerObjs,oracle_utils,JsonSerialization;

implementation

procedure APIList(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  JsonResp: string;
  Response: IwtsWriteData;
begin
  Response := DataPool.CreateRecordset('MILLENIUM!ORA_RESPONSYS.API.LIST',True);
  JsonResp := RestClientCenter('get','/rest/api/v1.3/lists','');
  FromJson(JsonResp,Response);
  Response.First;
  Output.AssignData(Response);
end;

initialization
   wtsRegisterProc('API.List',APIList);

end.

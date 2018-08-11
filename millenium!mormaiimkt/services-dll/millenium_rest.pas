unit millenium_rest;

interface

implementation

procedure PostRESTServiceNew(const AServiceURL, AResquet: string; var AResponse:string);
var
  RESTClient: TRESTClient;
  RequestUTF8: string;
  ServiceURL:string;
begin
  LoadSettings;
  ServiceURL := GURL+AServiceURL;
  
  AResponse := '';
  RequestUTF8 := UTF8Encode(AResquet);

  AddLog(0,'','Intelipost');
  AddLog(0,'POST URL: '+ServiceURL,'Intelipost');
  AddLog(0,'API_KEY: '+GKey,'Intelipost');
  AddLog(0,'Request: '+AResquet,'Intelipost');
  AddLog(0,'Request UTF8: '+RequestUTF8,'Intelipost');

  CoInitialize(nil);
  RESTClient := nil;
  try
    RESTClient := TRESTClient.Create('');
    try
      RESTClient.Headers := 'platform:Millennium'#13#10+
                            'plugin:1.0'#13#10+
                            'Accept:application/json'#13#10+
                            'Content-Type: application/json;charset=UTF-8'#13#10+
                            'api_key:'+GKey;

      AResponse := RESTClient.post(ServiceURL,RequestUTF8,'');
    except on e: Exception do
      AResponse := Copy(E.Message,Pos(':',E.Message)+1,Length(E.Message));
    end;
  finally
    RESTClient.Free;
    CoUninitialize;
  end;
  AddLog(0,'Response Sucess: '+AResponse,'Intelipost');
end;

end.

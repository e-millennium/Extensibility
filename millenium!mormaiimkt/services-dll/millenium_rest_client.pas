unit millenium_rest_client;

interface

uses
  wtsServerObjs, RESTClient,logfiles,Activex,SysUtils, JsonSerialization,ServerCfgs;

  
  procedure PostRESTService(const AService,ARequest:string;AReturnList:Boolean; var AResponse:string);
  function GetRESTService(const AService: string):string;
  function LoginService(const AUsuario,ASenha: string):string;
  function JsonIsValid(const AValue: string): Boolean;

implementation

var
  GDadosInicializados: Boolean;
  GServidor,
  GUsuario,
  GSenha: string;

function JsonIsValid(const AValue: string): Boolean;
begin
  Result := (AValue<>'{}');
end;

function TranslateMessageError(const AMessage: string): string;
var
  I: Integer;
begin
  Result := AMessage;
  I := Pos('EwtsMethodError',AMessage);
  if I > 0 then
    Result := Copy(AMessage,I+18,Length(AMessage)-I+21);
end;  

procedure CarregarDadosAcesso;
begin
  if not GDadosInicializados then
  begin
    GServidor := GetConfigSrv.ReadParamStr('MMKT_SERVER','');
    GUsuario := GetConfigSrv.ReadParamStr('MMKT_USUARIO','');
    GSenha := GetConfigSrv.ReadParamStr('MMKT_SENHA','');
    GDadosInicializados := True;
  end;
end;

function CriarSessao(const AUsuario,Senha: string): string;
var
  Json: string;
  Sessao: IwtsWriteData;
begin
  CarregarDadosAcesso;
  
  Sessao := CurrentDatapool.CreateRecordset('MILLENIUM!MORMAIIMKT.SESSAO.SESSAO');
  Json := LoginService(GUsuario,GSenha);
  FromJson(Json,Sessao);                  
  Result := Sessao.AsString['SESSION'];
end;

procedure PostRESTService(const AService,ARequest:string;AReturnList:Boolean; var AResponse:string);
var
  RESTClient: TRESTClient;
  RequestUTF8: string;
  ServiceURL:string;
  Session: string;
  XHttp: string;
begin
  Session := CriarSessao(GUsuario,GSenha);

  ServiceURL := GServidor+AService;
  
  AResponse := '';
  RequestUTF8 := UTF8Encode(ARequest);

  AddLog(0,'','mormaii_mkt');
  AddLog(0,'POST URL: '+ServiceURL,'mormaii_mkt');
  AddLog(0,'Request: '+ARequest,'mormaii_mkt');
  AddLog(0,'Request UTF8: '+RequestUTF8,'mormaii_mkt');

  XHttp := '';
  if AReturnList then
    XHttp := 'X-HTTP-Method: GET'#13#10;

  CoInitialize(nil);
  RESTClient := nil;
  try
    RESTClient := TRESTClient.Create('');
    try
      RESTClient.Headers := 'Accept:application/json'#13#10+
                            'Content-Type: application/json;charset=UTF-8'#13#10+
                            XHttp+
                            'WTS-Session:'+Session;

      AResponse := RESTClient.post(ServiceURL,RequestUTF8,'');
    except on e: Exception do
      raise Exception.Create(TranslateMessageError(e.Message));
    end;
  finally
    RESTClient.Free;
    CoUninitialize;
  end;
  AddLog(0,'Response Sucess: '+AResponse,'mormaii_mkt');
end;

function GetRESTService(const AService: string):string;
var
  RESTClient: TRESTClient;
  ServiceURL: string;
  Session: string;
begin
  Session := CriarSessao(GUsuario,GSenha);

  ServiceURL := GServidor+AService;

  Result := '';
  AddLog(0,'','mormaii_mkt');
  AddLog(0,'GET URL: '+ServiceURL,'mormaii_mkt');
  
  RESTClient := nil;
  try       
    CoInitialize(nil);
    RESTClient := TRESTClient.Create('');
    try
      RESTClient.Headers := 'Accept:application/json;charset=UTF-8'#13#10+
                            'WTS-Session:'+Session;;
      Result := RESTClient.Get(ServiceURL,True);
    except on e: Exception do
        Result := e.message;
    end;
  finally
    RESTClient.Free;
    CoUninitialize;
  end;
  AddLog(0,'Response Sucess: '+Result,'mormaii_mkt');
end;

function LoginService(const AUsuario,ASenha: string):string;
var
  RESTClient: TRESTClient;
  ServiceURL: string;
const
  Servico: string = '/api/login';
begin
  ServiceURL := GServidor+Servico;

  Result := '';
  AddLog(0,'','mormaii_mkt');
  AddLog(0,'GET URL: '+ServiceURL,'mormaii_mkt');
  
  RESTClient := nil;
  try       
    CoInitialize(nil);
    RESTClient := TRESTClient.Create('');
    try
      RESTClient.Headers := 'WTS-Authorization:'+AUsuario+'/'+ASenha;
      Result := RESTClient.Get(ServiceURL,True);
    except on e: Exception do
        Result := e.message;
    end;
  finally
    RESTClient.Free;
    CoUninitialize;
  end;
  AddLog(0,'Response Sucess: '+Result,'mormaii_mkt');
end;

initialization
  GDadosInicializados := False;


end.

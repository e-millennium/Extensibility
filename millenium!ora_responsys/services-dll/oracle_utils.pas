unit oracle_utils;


interface
uses SysUtils,RESTClient,logfiles,wtsintf,JSON,UTF8,Variants,wtsServerObjs;

function RestClientCenter(const AHttpAction,AURLService,AJsonRequest:string):String;

function IntfVal(const especializado,complemento:String):String;
Function ValorStr(const valor:String):String;
function CarregaAtributos(const aAtributos:IwtsWriteData):string;

implementation

var
  GToken: string;
const
  GUser: string = 'api_news';
  GPassword: string = 'Adin@2019_!';
  GURLBase: string = 'https://rest001.rsys8.net';
  GGrantType: string = 'auth_type=password&user_name=api_news&password=Adin@2019_!';

function RestClientCenter(const AHttpAction,AURLService,AJsonRequest:string):String;
var 
    RESTClient: TRESTClient;
    jarr:TJSONarray;
    sres,tokenType:string;
begin
  Result := '';
  RESTClient := TRESTClient.Create('');
  try
    if GToken='' then
    begin
      try
        //Authorization
        RESTClient.Headers := 'Content-Type: application/x-www-form-urlencoded';
        sres := RESTClient.Post(Pchar(GURLBase+'/rest/api/v1.3/auth/token'),GGrantType,'');
        jarr := ParseJSON(PChar(utf8.UTF8ToString(sres)));
        try
          GToken := VarToStr(jarr.Field['authToken'].Value);
        finally
          FreeAndNil(jarr);
        end;
      except
        on E:Exception do
            raise Exception.Create('Erro ao carregar token de acesso: '+e.message);
        end;
      end;

      try
        Result := '';
        RESTClient.Headers := 'Authorization: '+GToken+''#13+
                              'Content-Type: application/json';

        if SameText(AHttpAction,'GET') then
        begin
          Result := RESTClient.Get(GURLBase+AURLService);
        end else
        if SameText(AHttpAction,'PUT') then
          Result := RESTClient.Put(GURLBase+AURLService,AJsonRequest,'')
        else
        if SameText(AHttpAction,'POST') then
          Result := RESTClient.Post(GURLBase+AURLService,AJsonRequest,'')
        else
        if SameText(AHttpAction,'DELETE') then
          Result := RESTClient.Delete(GURLBase+AURLService,AJsonRequest,'');
          
      except
        on E:Exception do
        begin
          raise;
          (*begin
            jarr := ParseJSON(PChar(utf8.UTF8ToString(Result)));
            try
              if (jarr.Field['errorCode']<>nil) and (VarToStr(jarr.Field['errorCode'].Value)='60006000') and (x<5) then
              begin
                 accessToken := '';
              end
              else
              begin
                raise Exception.Create(e.message);
              end;
            finally
              FreeAndNil(jarr);
            end;
          end;
        end;  *)
      end;
    end;
  finally
    FreeAndNil(RESTClient);
  end;
end;

Function IntfVal(const especializado,complemento:String):String;
begin
  Result := '';
  try
    if Interfaces.IntfExists(PChar('MILLENIUM_ECO_ORC_'+especializado+complemento)) then
      result := 'MILLENIUM_ECO_ORC_'+especializado+complemento;
  except
  end;

  if result='' then
  begin
    if Interfaces.IntfExists(PChar('MILLENIUM_ECO_ORC_DEFAULT'+complemento)) then
      result := 'MILLENIUM_ECO_ORC_DEFAULT'+complemento;
  end;

  if result='' then
    raise Exception.Create('Interface '+complemento+' não encontrada');
end;

Function ValorStr(const valor:String):String;
begin
  Result := StringReplace(valor,',','.',[]);
end;

function carregaAtributos(const aAtributos:IwtsWriteData):string;
var valores:IwtsWriteData;
    jsonAtributos,jsonValores:string;
begin
  result:='';
  aAtributos.First;
  while not aAtributos.EOF do
  begin
    valores := aAtributos.GetFieldAsData('VALORES') as IwtsWriteData;
    if valores.RecordCount>0 then
    begin
      jsonValores := '';
      valores.First;
      while not valores.EOF do
      begin
        if valores.GetFieldAsString('VALOR')<>'' then
          jsonValores := jsonValores+valores.GetFieldAsString('VALOR')+', ';
        valores.Next;
      end;
      SetLength(jsonValores,length(jsonValores)-2);
      jsonAtributos := jsonAtributos+',"'+aAtributos.GetFieldAsString('DESCRICAO')+'":"'+jsonValores+'"';
    end;
    aAtributos.Next
  end;
  result := jsonAtributos;
end;

end.



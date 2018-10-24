unit millenium_mormaiimkt_estoques;

interface

uses
  Windows, Classes, wtsServerObjs, SysUtils, ServerCfgs, millenium_variants,
  JsonSerialization,millenium_rest_client,UTF8,Variants,millenium_uteis;


implementation

procedure Enviar(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C,L: IwtsCommand;
  E: IwtsWriteData;
  JsonRequest,JsonResponse: string;
  TransID: Integer;
  Filial,Colecoes,SubColecoes,Divisoes,Grupos,Tipos,Categorias,Departamentos,Marcas,Chave: Variant;
  function StrToVar(const AValue: string): Variant;
  begin
    Result := unassigned;
    if AValue <> '' then
      Result := AValue;
  end;
const
  Servico: string = '/api/millenium_eco_mmormaii/estoques/receber';
begin
  JsonRequest := '';
  C := DataPool.Open('MILLENIUM');
  L := DataPool.Open('MILLENIUM');
  try
    Chave := GetConfigSrv.ReadParamStr('MMKT_CHAVE','');
    if not ValidarChaveLicenca(Chave) then
      raise Exception.Create('Chave de licen�a inv�lida.');

    Filial := GetConfigSrv.ReadParamInt('MMKT_FILIAL_ESTOQUE',0);
    TransID := GetConfigSrv.ReadParamInt('MMKT_TRANS_ID_ESTOQUE',0);

    Colecoes := StrToVar(GetConfigSrv.ReadParamStr('MMKT_COLECAO',''));
    SubColecoes := StrToVar(GetConfigSrv.ReadParamStr('MMKT_SUBCOLECAO',''));
    Divisoes := StrToVar(GetConfigSrv.ReadParamStr('MMKT_DIVISAO',''));
    Grupos := StrToVar(GetConfigSrv.ReadParamStr('MMKT_GRUPO',''));
    Tipos := StrToVar(GetConfigSrv.ReadParamStr('MMKT_TIPO',''));
    Categorias := StrToVar(GetConfigSrv.ReadParamStr('MMKT_CATEGORIA',''));
    Departamentos := StrToVar(GetConfigSrv.ReadParamStr('MMKT_DEPARTAMENTO',''));
    Marcas := StrToVar(GetConfigSrv.ReadParamStr('MMKT_MARCA',''));

    //C.Dim('TRANS_ID,', TransID);
    C.Dim('FILIAL',Filial);
    C.Dim('COLECOES',Colecoes);
    C.Dim('SUBCOLECOES',SubColecoes);
    C.Dim('DIVISOES',Divisoes);
    C.Dim('GRUPOS',Grupos);
    C.Dim('TIPOS',Tipos);
    C.Dim('CATEGORIAS',Categorias);
    C.Dim('DEPARTAMENTOS',Departamentos);
    C.Dim('MARCAS',Marcas);
    C.Execute('SELECT NULL AS DUAL '+
              '       #ROWSET({SELECT:PRODUTOS '+
              '                       IIF(STRLEN(CB.BARRA)=12,CB.BARRA||EAN13CS(CB.BARRA),CB.BARRA) AS EAN,'+
              '                       SUM(E.SALDO) AS QUANTIDADE '+
              '                FROM ESTOQUES E '+
              '                INNER JOIN PRODUTOS P ON (P.PRODUTO = E.PRODUTO) '+
              '                INNER JOIN CODIGO_BARRAS CB ON (CB.PRODUTO = E.PRODUTO) AND '+
              '                                               (CB.COR = E.COR) AND '+
              '                                               (CB.ESTAMPA = E.ESTAMPA) AND '+
              '                                               (CB.TAMANHO = E.TAMANHO) '+
              '                WHERE '+//E.TRANS_ID > :TRANS_ID
              '                       E.GERADOR IS NULL AND '+
              '                       E.FILIAL =:FILIAL '+//AND CB.BARRA IN ("7898584021466","7898584022975")
              '                      [AND P.COLECAO IN #REPLACE(:COLECOES)] '+
              '                      [AND P.SUBCOLECAO IN #REPLACE(:SUBCOLECOES)] '+
              '                      [AND P.DIVISAO IN #REPLACE(:DIVISOES)] '+
              '                      [AND P.GRUPO IN #REPLACE(:GRUPOS)] '+
              '                      [AND P.TIPO IN #REPLACE(:TIPOS)] '+
              '                      [AND P.CATEGORIA IN #REPLACE(:CATEGORIAS)] '+
              '                      [AND P.DEPARTAMENTO IN #REPLACE(:DEPARTAMENTOS)] '+
              '                      [AND P.MARCA IN #REPLACE(:MARCAS)] '+
              '               GROUP BY CB.BARRA '+
              '               HAVING SUM(E.SALDO) >= 0})'+
              'FROM DUAL');
     E := C.CreateRecordset;
     if E.RecordCount > 0 then
     begin
       JsonRequest := ToJson(E,['PRODUTOS'],False);
       if JsonIsValid(JsonRequest) then
         PostRESTService(Servico,JsonRequest,False,JsonResponse);
     end;
     L.Dim('MENSAGEM','Estoque enviado com sucesso');
     L.Dim('JSON',JsonRequest);
     L.Execute('#CALL MILLENIUM!MORMAIIMKT.LOGS.INCLUIR(MENSAGEM=:MENSAGEM,JSON=:JSON,TIPO=1)');
   except on E: Exception do
     begin
       L.Dim('MENSAGEM',E.Message);
       L.Dim('JSON',JsonRequest);
       L.Execute('#CALL MILLENIUM!MORMAIIMKT.LOGS.INCLUIR(MENSAGEM=:MENSAGEM,JSON=:JSON,TIPO=1)');
     end;
   end;
end;

initialization
   wtsRegisterProc('ESTOQUE.Enviar',Enviar);

end.

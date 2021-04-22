unit jadlog_gateway_fretes_etq;

interface

uses
  wtsServerObjs, SysUtils;

implementation

procedure BeforeListaSigep(Input:IwtsInput; Output:IwtsOutput;DataPool:IwtsDataPool);
var
   C: IwtsCommand;
   Embarques,QueueRequest,Request: IwtsWriteData;
   Embarque,Transportadora: Variant;
begin
  C := DataPool.Open('MILLENIUM');

  C.Dim('SAIDA',Input.Value['SAIDA']);
  C.Execute('SELECT TRANSPORTADORA FROM SAIDAS WHERE SAIDA =:SAIDA;');
  Transportadora := C.AsString['TRANSPORTADORA'];

  if Transportadora <> '132' then
    Exit;

  //Vamos simular um embarque
  C.Dim('SAIDA',Input.Value['SAIDA']);
  C.Dim('TRANSPORTADORA',Transportadora);
  C.Execute('INSERT:MAIN INTO EMBARQUES(COD_EMBARQUE,DATA_EMBARQUE,TRANSPORTADORA) VALUES (:SAIDA,#NOW(),:TRANSPORTADORA) #RETURN(EMBARQUE); '+
            'INSERT INTO EMBARQUE_ITENS(EMBARQUE,ORIGEM,TIPO_ORIGEM) VALUES (:MAIN.EMBARQUE,:SAIDA,"S") #RETURN(EMBARQUE_ITENS);');

  C.Dim('SAIDA',Input.Value['SAIDA']);
  C.Execute('SELECT EMBARQUE FROM EMBARQUES WHERE COD_EMBARQUE=:SAIDA');
  Embarque := C.Value['EMBARQUE'];

  C.Dim('EMBARQUE',Embarque);
  C.Execute('#CALL MILLENIUM.GATEWAY_FRETES.EMBARQUE.LIBERARENVIO(EMBARQUE=:EMBARQUE);');

  C.Dim('EMBARQUE',Embarque);
  C.Execute('DELETE FROM EMBARQUES WHERE EMBARQUE=:EMBARQUE;'+
            'DELETE FROM EMBARQUE_ITENS WHERE EMBARQUE=:EMBARQUE; ');
end;

initialization
  wtsRegisterProc('EMBARQUES.BeforeLista_Sigep', BeforeListaSigep);

end.

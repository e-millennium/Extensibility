unit millenium_mormaiimkt_faturamento;

interface

uses
  Windows, Classes, wtsServerObjs, SysUtils, ServerCfgs, millenium_variants,
  JsonSerialization,millenium_rest_client,UTF8;

implementation

procedure Enviar(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
begin

end;

initialization
   wtsRegisterProc('FATURAMENTO.Enviar',Enviar);

end.


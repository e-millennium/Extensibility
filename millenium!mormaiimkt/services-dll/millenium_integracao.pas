unit millenium_integracao;

interface

uses
  Windows, Classes, SysUtils, wtsServerObjs,millenium_uteis;

implementation

procedure ListarSerial(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
begin
  Output.NewRecord;
  Output.SetFieldByName('SERIAL',SerialNum('C'));
end;

initialization
   wtsRegisterProc('INTEGRACAO.ListarSerial',ListarSerial);

end.

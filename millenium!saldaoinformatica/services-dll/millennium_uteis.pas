unit millennium_uteis;


interface

uses
  SysUtils,Checkcgc;

procedure ValidaCPFCNPJ(const Valor:String);

implementation

function RemoveChar(const AValue:string):string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(AValue) do
    if AValue[I] in ['0'..'9'] then
      Result := Result + AValue[I];
end;

procedure ValidaCPFCNPJ(const Valor:String);
var
  A,B:string;
begin
  if Length(Valor) > 0  then
  begin
    if Length(RemoveChar(Valor)) = 11 then
    begin
      RemoveCPFMask(Valor,A,B);
      if not VerificaCPF(A,B) then
        raise Exception.Create('CPF "'+Valor+'" Inválido');
    end else
    if Length(RemoveChar(Valor)) = 14 then
    begin
      RemoveCGCMask(Trim(Valor),A,B);
      if not VerificaCGC(A,B) then
        raise Exception.Create('CNPJ "'+Valor+'" Inválido');
    end else
    if Length(RemoveChar(Valor)) = 15 then
    begin
      RemoveCGCMask(Trim(Copy(Valor,2,MaxInt)),A,B);
      if not VerificaCGC(A,B) then
        raise Exception.Create('CNPJ "'+Valor+'" Inválido');
    end else
      raise Exception.Create('Número inválido para CPF ou CNPJ');
  end; 
end; 

end.

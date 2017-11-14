unit millennium_uteis;


interface

uses
  SysUtils;

procedure ValidaCPFCNPJ(const Valor:String);

implementation

procedure ValidaCPFCNPJ(const Valor:String);
  function cpf(num: string): boolean;
  var 
    n1,n2,n3,n4,n5,n6,n7,n8,n9: integer; 
    d1,d2: integer; 
    digitado, calculado: string; 
  begin 
    n1:=StrToInt(num[1]); 
    n2:=StrToInt(num[2]); 
    n3:=StrToInt(num[3]); 
    n4:=StrToInt(num[4]); 
    n5:=StrToInt(num[5]); 
    n6:=StrToInt(num[6]); 
    n7:=StrToInt(num[7]); 
    n8:=StrToInt(num[8]); 
    n9:=StrToInt(num[9]); 
    d1:=n9*9+n8*8+n7*7+n6*6+n5*5+n4*4+n3*3+n2*2+n1*1; 
    d1:=(d1 mod 11); 
    if d1>=10 then 
      d1:=0; 
    d2:=d1*9+n9*8+n8*7+n7*6+n6*5+n5*4+n4*3+n3*2+n2*1+n1*0; 
    d2:=(d2 mod 11); 
    if d2>=10 then 
      d2:=0; 
    calculado:=inttostr(d1)+inttostr(d2); 
    digitado:=num[10]+num[11]; 
    if calculado=digitado then 
      cpf:=true 
    else 
      cpf:=false; 
  end; 
  function CNPJ(num: string): boolean; 
  var 
    n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12: integer; 
    d1,d2: integer; 
    digitado, calculado: string; 
  begin 
    n1:=StrToInt(num[1]); 
    n2:=StrToInt(num[2]); 
    n3:=StrToInt(num[3]); 
    n4:=StrToInt(num[4]); 
    n5:=StrToInt(num[5]); 
    n6:=StrToInt(num[6]); 
    n7:=StrToInt(num[7]); 
    n8:=StrToInt(num[8]); 
    n9:=StrToInt(num[9]); 
    n10:=StrToInt(num[10]); 
    n11:=StrToInt(num[11]); 
    n12:=StrToInt(num[12]); 
    d1:=n12*6+n11*7+n10*8+n9*9+n8*2+n7*3+n6*4+n5*5+n4*6+n3*7+n2*8+n1*9; 
    d1:=11-(d1 mod 11); 
    if d1>=10 then 
      d1:=0; 
    d2:=d1*5+n12*6+n11*7+n10*8+n9*9+n8*2+n7*3+n6*4+n5*5+n4*6+n3*7+n2*8+n1*9; 
    d2:=11-(d2 mod 11); 
    if d2>=10 then 
      d2:=0; 
    calculado:=inttostr(d2)+inttostr(d1); 
    digitado:=num[13]+num[14]; 
    if calculado=digitado then 
      CNPJ:=true 
    else 
      CNPJ:=false; 
  end; 
begin 
  if Length(Valor) > 0  then 
  begin 
    if Length(Valor) = 11 then 
    begin 
      if not CPF(Valor) then
        raise Exception.Create('CPF "'+Valor+'" Inválido');
    end else
    if Length(Valor) = 14 then
    begin
      if not CNPJ(Valor) then
        raise Exception.Create('CNPJ "'+Valor+'" Inválido');
    end else
        raise Exception.Create('Número inválido para CPF ou CNPJ');
  end; 
end; 

end.

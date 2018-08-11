unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Cipher,DECUtil;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses millenium_uteis,UTF8;

{$R *.dfm}

function Criptografar(const pa: String): String;
var cy : TCipher_SAFER;
begin
  Result := '';
  if (pa='') then Exit;

  cy := TCipher_SAFER.Create(pa,nil);  // Aqui criar uma senha grande de preferencia
  try
    Result := cy.EncodeString(pa);   // Aqui criptografa
    Result := StrToFormat(PChar(Result),Length(Result),fmtHex);  // Aqui gera uma string no formato Hexa para n�o precisar usar um blob
  finally
    FreeAndNil(cy);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Serial: string;
begin
  Edit2.Text := Criptografar(Edit1.Text);
end;

end.

unit ListaProdutos;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids;

type
  TFListaProdutos = class(TForm)
    StringGrid1: TStringGrid;
    procedure StringGrid1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FListaProdutos: TFListaProdutos;

implementation

{$R *.DFM}

procedure TFListaProdutos.StringGrid1KeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key=#13 then
    Close;
end;

end.

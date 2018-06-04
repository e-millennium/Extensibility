program TerminalConsultaPreco;

uses
  Forms,
  Principal in 'Principal.pas' {FTerminal},
  Background in 'views-win32\Background.pas',
  ListaProdutos in 'ListaProdutos.pas' {FListaProdutos};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Terminal de Consulta de Produtos';
  Application.CreateForm(TFTerminal, FTerminal);
  Application.CreateForm(TFListaProdutos, FListaProdutos);
  Application.Run;
end.

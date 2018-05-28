unit Principal;

interface

uses
  GDIPAPI,GDIPOBJ,Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, wtsPainter, dmPanel, wtsClient, wtsStream, IniFiles, ExtCtrls,
  Buttons,TransparentPanel, OleCtrls, SHDocVw, PngImage, ProEffectImage,
  Grids;

type
  TCor = class
    Codigo: Integer;
    Desricao: string;
    Ativo: Boolean;
  end;

  TCores = class(TList)
  private
    function GetCor(Index: Integer): TCor;
  public
    function Add: TCor;
    property Items[Index: Integer]: TCor read GetCor;default;
  end;

  TEstoque = class
    Cor: string;
    Tamanho: string;
    Estoque: Real;
  end;

  TEstoques = class(TList)
  private
    function GetEstoque(Index: Integer): TEstoque;
  public
    function Add: TEstoque;
    function Estoque(const ACor,ATamanho: string): Real;
    property Items[Index: Integer]: TEstoque read GetEstoque;default;
  end;  

  TGradeView = class(TTransparentPanel)
  private
    FCores: TCores;
    FTamanhos: TStringList;
    FEstoques: TEstoques;
  protected
    procedure Paint;override;
  public
    procedure Clear;
    property Cores: TCores read FCores;
    property Tamanhos: TStringList read FTamanhos;
    property Estoques: TEstoques read FEstoques;
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
  end;
 
  TFTerminal = class(TForm)
    pnlBkd: TTransparentPanel;
    pnlDadosProd: TTransparentPanel;
    Timer1: TTimer;
    TransparentPanel1: TTransparentPanel;
    lblData: TLabel;
    lblRodape: TLabel;
    TransparentPanel2: TTransparentPanel;
    TransparentPanel3: TTransparentPanel;
    lblDescricaoProduto: TLabel;
    lblCodigoProduto: TLabel;
    lblCodigoDigitado: TLabel;
    TransparentPanel4: TTransparentPanel;
    lblPrecoProduto: TLabel;
    lblObs: TLabel;
    lblAlerta: TProEffectImage;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FCodigoProduto: string;
    FDescStatusAlerta: string;
    FFilial: Integer;
    FTabela: Integer;
    FMotraEstqoue: Boolean;
    FGrade: TGradeView;
    procedure ConsultarProduto(const ACodigoProduto: string);
    procedure MontarGrade(const ACores,ATamanhos,AEstoques: TwtsRecordset);
    function ConsultaNomeFilial(const AFilial: Integer): string;
    function ConsultaNomeTabela(const ATabela: Integer): string;
    procedure MostrarProduto(const AProduto: TwtsRecordset);

  public
    { Public declarations }
  end;

var
  FTerminal: TFTerminal;

implementation

uses ListaProdutos;

{$R *.DFM}

function VarToFloat(AValue: Variant): Real;
begin
  Result := 0;
  if VarToStr(AValue)='' then
    Exit;
  Result := AValue;
end;

function VarToBool(AValue: Variant): Boolean;
begin
  Result := False;
  if VarToStr(AValue) = '' then
    Exit;
  Result := AValue;
end;

{ TCores }
function TCores.Add: TCor;
begin
  Result := TCor.Create;
  inherited Add(Result);
end;

function TCores.GetCor(Index: Integer): TCor;
begin
  Result := TCor(inherited Items[Index]);
end;

{ TEstoques }

function TEstoques.Add: TEstoque;
begin
  Result := TEstoque.Create;
  inherited Add(Result);
end;

function TEstoques.Estoque(const ACor,ATamanho: string): Real;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count-1 do
  begin
    if (Items[I].Cor = ACor) and (Items[I].Tamanho = ATamanho) then
    begin
       Result := Items[I].Estoque;
       Break;
    end;
  end;
end;

function TEstoques.GetEstoque(Index: Integer): TEstoque;
begin
  Result := TEstoque(inherited Items[Index]);
end;

procedure TFTerminal.MontarGrade(const ACores, ATamanhos, AEstoques: TwtsRecordset);
var
  I: Integer;
begin
  FGrade.Cores.Clear;
  for I := 0 to ACores.RecordCount-1 do
  begin
    with FGrade.Cores.Add do
    begin
      Codigo := ACores.FieldValuesByName['COR'];
      Desricao := ACores.FieldValuesByName['DESCRICAO'];
      Ativo := VarToStr(ACores.FieldValuesByName['ATIVO'])='A';
    end;
    ACores.Next;
  end;

  FGrade.Tamanhos.Clear;
  for I := 0 to ATamanhos.RecordCount-1 do
  begin
    FGrade.Tamanhos.Add(ATamanhos.FieldValuesByName['TAMANHO']);
    ATamanhos.Next;
  end;

  FGrade.Estoques.Clear;
  for I := 0 to AEstoques.RecordCount-1 do
  begin
    with FGrade.Estoques.Add do
    begin
      Cor := AEstoques.FieldValuesByName['COR'];
      Tamanho := AEstoques.FieldValuesByName['TAMANHO'];
      Estoque := AEstoques.FieldValuesByName['ESTOQUE'];
    end;
    AEstoques.Next;
  end;

  FGrade.Invalidate;  
end;

function TFTerminal.ConsultaNomeFilial(const AFilial: Integer): string;
var
  R: TwtsRecordset;
begin
  Result := 'Filial '+IntToStr(AFilial)+' não encontrada';
  try
    wtsCallEx('MILLENIUM_SJ.TERMINAL.CONSULTAFILIAL',['FILIAL'],[AFilial],R);
    try
      if R.RecordCount > 0 then
        Result := VarToStr(R.FieldValuesByName['NOME']);
    finally
      R.Free;
    end;
  except
  end;
end;

function TFTerminal.ConsultaNomeTabela(const ATabela: Integer): string;
var
  R: TwtsRecordset;
begin
  Result := 'Tabela '+IntToStr(ATabela)+' não encontrada';
  try
    wtsCallEx('MILLENIUM_SJ.TERMINAL.CONSULTATABELA',['TABELA'],[ATabela],R);
    try
      if R.RecordCount > 0 then
        Result := VarToStr(R.FieldValuesByName['DESCRICAO']);
    finally
      R.Free;
    end;
  except
  end;
end;

procedure TFTerminal.MostrarProduto(const AProduto: TwtsRecordset);
begin

end;

procedure TFTerminal.ConsultarProduto(const ACodigoProduto: string);
var
  FListaProdutos: TFListaProdutos;
  Produto,
  Cores,
  Tamanhos,
  Estoques: TwtsRecordset;
begin
  wtsCallEx('MILLENIUM_SJ.TERMINAL.CONSULTA',['COD_PRODUTO','FILIAL','TABELA'],[ACodigoProduto,FFilial,FTabela],Produto);
  try
    if Produto.RecordCount > 1 then
    begin
      FListaProdutos := TFListaProdutos.Create(nil);
      FListaProdutos.StringGrid1.RowCount := Produto.RecordCount;
      Produto.First;
      while not Produto.Eof do
      begin
        FListaProdutos.StringGrid1.Cells[0,Produto.RecNo] := VarToStr(Produto.FieldValuesByName['DESC_PROD']); 
        Produto.Next;
      end;
      FListaProdutos.ShowModal;
      Produto.GotoRecord(FListaProdutos.StringGrid1.Row);
      FListaProdutos.Free;
    end;

    if Produto.RecordCount > 0 then
    begin
      lblCodigoProduto.Caption := VarToStr(Produto.FieldValuesByName['COD_PROD']);
      lblDescricaoProduto.Caption := VarToStr(Produto.FieldValuesByName['DESC_PROD']);
      lblPrecoProduto.Caption := FormatFloat('R$ 0.00, ',VarToFloat(Produto.FieldValuesByName['PRECO_MEDIO']));
      lblObs.Caption := VarToStr(Produto.FieldValuesByName['OBS_PROD']);
      lblAlerta.Visible := SameText(VarToStr(Produto.FieldValuesByName['STATUS_PROD']),FDescStatusAlerta);
      Cores := Produto.CreateFieldRecordset('CORES');
      Tamanhos := Produto.CreateFieldRecordset('TAMANHOS');
      Estoques := Produto.CreateFieldRecordset('ESTOQUES');
      MontarGrade(Cores,Tamanhos,Estoques);
    end else
    begin
      lblCodigoProduto.Caption := '';
      lblDescricaoProduto.Caption := '';
      lblPrecoProduto.Caption := '';
      lblObs.Caption := '';
      lblAlerta.Visible := False;
      FGrade.Clear;
    end;
  finally
    Produto.Free;
    Cores.Free;
    Tamanhos.Free;
    Estoques.Free;
  end;
end;

procedure TFTerminal.FormCreate(Sender: TObject);
var
  Ini: TIniFile;
begin
  lblCodigoProduto.Caption := '';
  lblDescricaoProduto.Caption := '';
  lblPrecoProduto.Caption := '';
  lblObs.Caption := '';
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0))+'Terminal.ini');
  try
    FFilial := Ini.ReadInteger('config','filial',MaxInt);
    FTabela := Ini.ReadInteger('config','tabela',MaxInt);
    FMotraEstqoue := Ini.ReadBool('config','mostrar_estoque',False);
    FDescStatusAlerta := Ini.ReadString('config','status_alerta','');
  finally
    Ini.Free;
  end;
  FGrade := TGradeView.Create(Self);
  FGrade.Parent := pnlBkd;
  FGrade.Align := alClient;
  
  lblRodape.Caption := ConsultaNomeFilial(FFilial)+' - '+ConsultaNomeTabela(FTabela);
end;

procedure TFTerminal.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    lblCodigoDigitado.Caption := 'Aguarde. Consultando...';
    lblCodigoDigitado.Refresh;
    ConsultarProduto(FCodigoProduto);
    FCodigoProduto := '';
    lblCodigoDigitado.Caption := 'Informe o código ou referência do produto';
  end else
  begin
    FCodigoProduto := FCodigoProduto+Key;
    lblCodigoDigitado.Caption := FCodigoProduto;
  end;  
end;

{ TGradeView }

procedure TGradeView.Clear;
begin
  FCores.Clear;
  FTamanhos.Clear;
  FEstoques.Clear;
  Invalidate;
end;

constructor TGradeView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCores := TCores.Create;
  FTamanhos := TStringList.Create;
  FEstoques := TEstoques.Create;
  Transparent := 0;
  Color := clWhite;
  Shadow := True;
end;

destructor TGradeView.Destroy;
begin
  inherited;
  FCores.Free;
  FTamanhos.Free;
  FEstoques.Free;
end;

procedure TFTerminal.FormDestroy(Sender: TObject);
begin
  FGrade.Free;
end;

procedure TFTerminal.FormResize(Sender: TObject);
const
  Margin: Integer=20;
begin
  pnlDadosProd.Align := alNone;
  pnlDadosProd.Top := Margin;
  pnlDadosProd.Left := Margin;
  pnlDadosProd.Width := Screen.Width-(Margin*2);
  pnlDadosProd.Height := 300;

  FGrade.Align := alNone;
  FGrade.Top := Margin+pnlDadosProd.Height+Margin;
  FGrade.Left := Margin;
  FGrade.Width := Screen.Width-(Margin*2);
  FGrade.Height := Screen.Height-(Margin*2)-pnlDadosProd.Height-Margin;
end;


procedure TFTerminal.Timer1Timer(Sender: TObject);
begin
   lblData.Caption := FormatDateTime('dd/mm/yyyy hh:nn:ss',now)
end;

procedure TGradeView.Paint;
var
  I,T,CW,X,Y: Integer;
  Qtd: Real;
  R: TRect;
  g: TGPGraphics;
  gb: TGPSolidBrush;
  pr: gdipapi.TRect;
  DCSaved: Integer;
const
  CHeigthLine: Integer = 35;
  CColumnWithDescription: Integer = 300;
begin
  inherited;
  if FTamanhos.Count = 0 then
    Exit;

  Canvas.Font.Name := 'Segoe UI';
  Canvas.Font.Size := 20;
  Canvas.Font.Style := [fsBold];
  Canvas.Brush.Style := bsClear;

  Canvas.Font.Color := clWhite;
  Canvas.TextOut(10,5,'CORES');
  Canvas.Pen.Color := clWhite;
  Canvas.MoveTo(Width,CHeigthLine+10);
  Canvas.LineTo(0,CHeigthLine+10);

  CW := 100;
  for I := 0 to FTamanhos.Count-1 do
  begin
    X := CColumnWithDescription+(CW*I);
    Y := 5;
    R := Rect(X,Y,X+CW,Y+CHeigthLine);
    DrawText(Canvas.Handle,PChar(FTamanhos[I]),Length(FTamanhos[I]),R,DT_CENTER);
  end;

  Canvas.Font.Color := clWhite;
  for I := 0 to FCores.Count-1 do
  begin
    X := 10;
    Y := CHeigthLine*(I+1)+10;

    if not FCores[I].Ativo then
    begin
      DCSaved := SaveDC(Canvas.Handle);
      R := Rect(1,Y,Width,CHeigthLine);
      g := TGPGraphics.Create(Canvas.Handle);
      gb := TGPSolidBrush.Create(MakeColor(80,clRed));
      pr := gdipapi.TRect(r);
      g.FillRectangle(gb, pr);
      gb.Free;
      RestoreDC(Canvas.Handle,DCSaved);
    end;

    R := Rect(10,Y,CColumnWithDescription,Y+CHeigthLine);
    DrawText(Canvas.Handle,PChar(FCores[I].Desricao),Length(FCores[I].Desricao),R,DT_LEFT or DT_VCENTER);

    Canvas.Pen.Color := clSilver;
    Canvas.MoveTo(Width,Y);
    Canvas.LineTo(0,Y);
    for T := 0 to FTamanhos.Count-1 do
    begin
      X := CColumnWithDescription+(CW*T);
      R := Rect(X,Y,X+CW,Y+CHeigthLine);
      Qtd := Estoques.Estoque(FCores[I].Desricao,FTamanhos[T]);
      DrawText(Canvas.Handle,PChar(FloatToStr(Qtd)),Length(FloatToStr(Qtd)),R,DT_CENTER or DT_SINGLELINE or DT_NOPREFIX);
    end;
  end;
end;




procedure TFTerminal.FormShow(Sender: TObject);
begin
  Self.SetFocus;
end;

end.

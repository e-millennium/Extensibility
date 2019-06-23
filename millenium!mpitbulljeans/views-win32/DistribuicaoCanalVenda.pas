unit DistribuicaoCanalVenda;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  LinkList,wtsClient,wtsStream, Grids, PalGrid, ComCtrls, ExtCtrls,
  GradeProd, Db, wtsMethodView, StdCtrls;

type
  TEstampa = class
    Codigo: string;
    Desricao: string;
  end;

  TEstampas = class(TList)
  private
    function GetEstampa(Index: Integer): TEstampa;
  public
    function Add: TEstampa;
    property Items[Index: Integer]: TEstampa read GetEstampa;default;
  end;

  TCor = class
    Codigo: string;
    Desricao: string;
  end;

  TCores = class(TList)
  private
    function GetCor(Index: Integer): TCor;
  public
    function Add: TCor;
    property Items[Index: Integer]: TCor read GetCor;default;
  end;

  TValor = class
    Estampa: string;
    Cor: string;
    Tamanho: string;
    Quantidade: Integer;
    Lotes: string;
    Quantidades: string;
    Situacoes: string;
  end;

  TValores = class(TList)
  private
    function GetValor(Index: Integer): TValor;
  public
    CanEdit: Boolean;
    Name: string;
    CanalVenda: Integer;
    function Total: Integer;
    function DisplayName: string;
    function Add: TValor;
    function GetValorByProduto(const AEstampa,ACor,ATamanho: string): TValor;
    property Items[Index: Integer]: TValor read GetValor;default;
    constructor Create(const AName: string; ACanalVenda: Integer);
  end;

  TMapa = class
    Estampa: TEstampa;
    Cor: TCor;
    Tamanho: String;
    Col: Integer;
    Row: Integer;
  end;

  TMapas = class(TList)
  private
    function GetMapa(Index: Integer): TMapa;
  public
    function Add: TMapa;
    function GetMapaByColRow(const ACol,ARow: Integer): TMapa;
    property Items[Index: Integer]: TMapa read GetMapa;default;
  end;

  TGrade = class
    Estampas: TEstampas;
    Cores: TCores;
    Tamanhos: TStringList;
    Producao: TValores;
  public  
    constructor Create;
    destructor Destroy;override;
  end;

  TFDistribuicaoCanalVenda = class(TForm)
    LinkList1: TLinkList;
    Panel1: TPanel;
    Panel2: TPanel;
    TreeView1: TTreeView;
    Panel3: TPanel;
    ListaCanalVenda: TwtsMethodView;
    PalGrid1: TPalGrid;
    Label2: TLabel;
    pnlCanalCurx: TPanel;
    lblSaldo: TLabel;
    lblCanalCur: TLabel;
    lblProduto: TLabel;
    procedure ListaCanalVendaRefreshDone(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PalGrid1GetDrawStyle(Sender: TObject; Col, Row: Integer;
      var Style: TDrawStyle);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure PalGrid1CanEditCell(Sender: TObject; Col, Row: Integer;
      var CanEdit: Boolean);
    procedure PalGrid1CellExit(Sender: TObject; Col, Row: Integer);
    procedure PalGrid1CellEnter(Sender: TObject; Col, Row: Integer);
    procedure PalGrid1ChangeDrawing(Sender: TObject; ACol, ARow: Integer;
      var ForeColor, BackColor: TColor);
    procedure LinkList1Links0Click(Sender: TObject);
    procedure LinkList1Links1Click(Sender: TObject);
  private
    function GetCells(AEstampa, ACor, ATamanho: string): Integer;
    procedure SetCells(AEstampa, ACor, ATamanho: string;
      const Value: Integer);
  private
    FProducao: Integer;
    FGrade: TGrade;
    FMapas: TMapas;
    FCurValores: TValores;
    FCurNode: TTreeNode;
    procedure ConsultaPacotesDone(Params:TwtsRecordset;Result:TwtsClientRecordset;var UserData:IUnknown);
    procedure CriarGrade(const AEstampas, ACores, ATamanhos, AProducoes: TwtsRecordset);
    procedure MontarGrade(AGrade: TGrade);
    procedure PreencherGrade(AGrade: TGrade; AValores: TValores);
    function CalcularSaldoProduto(ACol,ARow: Integer): Integer;
    property Cells[AEstampa,ACor,ATamanho: string]: Integer read GetCells write SetCells;
    procedure DistribuirLotes;
  public
    { Public declarations }
    constructor Create(const AProducao: Integer);
  end;

var
  FDistribuicaoCanalVenda: TFDistribuicaoCanalVenda;

implementation

{$R *.DFM}

{ TFDistribuicaoCanalVenda }

procedure TFDistribuicaoCanalVenda.CriarGrade(const AEstampas, ACores, ATamanhos, AProducoes: TwtsRecordset);
var
  I: Integer;
begin
  FGrade.Estampas.Clear;
  for I := 0 to AEstampas.RecordCount-1 do
  begin
    with FGrade.Estampas.Add do
    begin
      Codigo := AEstampas.FieldValuesByName['ESTAMPA'];
      Desricao := AEstampas.FieldValuesByName['DESCRICAO'];
    end;
    AEstampas.Next;
  end;

  FGrade.Cores.Clear;
  for I := 0 to ACores.RecordCount-1 do
  begin
    with FGrade.Cores.Add do
    begin
      Codigo := ACores.FieldValuesByName['COR'];
      Desricao := ACores.FieldValuesByName['DESCRICAO'];
    end;
    ACores.Next;
  end;

  FGrade.Tamanhos.Clear;
  for I := 0 to ATamanhos.RecordCount-1 do
  begin
    FGrade.Tamanhos.Add(ATamanhos.FieldValuesByName['TAMANHO']);
    ATamanhos.Next;
  end;

  FGrade.Producao.Clear;
  for I := 0 to AProducoes.RecordCount-1 do
  begin
    with FGrade.Producao.Add do
    begin
      Estampa := AProducoes.FieldValuesByName['ESTAMPA'];
      Cor := AProducoes.FieldValuesByName['COR'];
      Tamanho := AProducoes.FieldValuesByName['TAMANHO'];
      Quantidade := AProducoes.FieldValuesByName['QUANTIDADE'];
      Lotes := AProducoes.FieldValuesByName['LOTES'];
      Quantidades := AProducoes.FieldValuesByName['QUANTIDADES'];
      Situacoes := AProducoes.FieldValuesByName['SITUACOES'];
    end;
    AProducoes.Next;
  end;
end;

procedure TFDistribuicaoCanalVenda.MontarGrade(AGrade: TGrade);
var
  I,E,C,P,T,R: Integer;
const
  ColEstampa = 0;
  ColCor = 1;
begin
  FMapas.Clear;
  PalGrid1.ColCount := FGrade.Tamanhos.Count+2;
  PalGrid1.RowCount := (FGrade.Estampas.Count*FGrade.Cores.Count)+FGrade.Estampas.Count;
  PalGrid1.FixedCols := 2;

  //COL,ROW
  R := 0;
  PalGrid1.Cells[ColEstampa,R] := 'Estampas';
  PalGrid1.Cells[ColCor,R] := 'Cores';

  PalGrid1.ColWidths[ColEstampa] := 100;
  PalGrid1.ColWidths[ColCor] := 100;

  for T := 0 to FGrade.Tamanhos.Count-1 do
  begin
    PalGrid1.Cells[T+2,R] := FGrade.Tamanhos[T];
    PalGrid1.ColWidths[T+2] := 50;
  end;

  Inc(R);
  for E := 0 to FGrade.Estampas.Count-1 do
  begin
    PalGrid1.Cells[ColEstampa,R] := FGrade.Estampas[E].Desricao;
    for C := 0 to  FGrade.Cores.Count-1 do
    begin
      PalGrid1.Cells[ColCor,R] := FGrade.Cores[C].Desricao;

      //Criando mapa para todos os tamanhos
      for T := 0 to FGrade.Tamanhos.Count - 1 do
      begin
        with FMapas.Add do
        begin
          Estampa := FGrade.Estampas[E];
          Cor := FGrade.Cores[C];
          Tamanho := FGrade.Tamanhos[T];
          Col := T+2;
          Row := R;
        end;  
      end;  
      Inc(R);
    end;
  end;
  PalGrid1.Visible := True;
end;

procedure TFDistribuicaoCanalVenda.PreencherGrade(AGrade: TGrade; AValores: TValores);
var
  I: Integer;
begin
  for I := 0 to FMapas.Count -1 do
    PalGrid1.Cells[FMapas[I].Col,FMapas[I].Row] := '';

  for I := 0 to AValores.Count-1 do
    Cells[AValores[I].Estampa,AValores[I].Cor,AValores[I].Tamanho] := AValores[I].Quantidade;
end;

procedure TFDistribuicaoCanalVenda.ConsultaPacotesDone(Params: TwtsRecordset;
  Result: TwtsClientRecordset; var UserData: IUnknown);
var
  Estmapas,Cores,Tamanhos,Producoes: TwtsRecordset;
begin                   
  lblProduto.Caption := Result.FieldValuesByName['COD_PRODUTO'] + ' - ' + Result.FieldValuesByName['DESCRICAO1'];
  Estmapas := Result.CreateFieldRecordset('ESTAMPAS');
  Cores := Result.CreateFieldRecordset('CORES');
  Tamanhos := Result.CreateFieldRecordset('TAMANHOS');
  Producoes := Result.CreateFieldRecordset('PRODUCOES');
  try
    CriarGrade(Estmapas,Cores,Tamanhos,Producoes);
    MontarGrade(FGrade);
    PreencherGrade(FGrade,FGrade.Producao);
    ListaCanalVenda.Refresh;
  finally
    Estmapas.Free;
    Cores.Free;
    Tamanhos.Free;
    Producoes.Free;
  end;
end;

constructor TFDistribuicaoCanalVenda.Create(const AProducao: Integer);
begin
  inherited Create(nil);
  FProducao := AProducao;
  FGrade := TGrade.Create;
  FMapas := TMapas.Create;
  PalGrid1.Visible := False;

  ListaCanalVenda.CallMode := cmAsync;
end; 

procedure TFDistribuicaoCanalVenda.ListaCanalVendaRefreshDone(
  Sender: TObject);
var
  Node: TTreeNode;
  Valores: TValores;
begin
  FCurValores := nil;
  ListaCanalVenda.First;
  Node := TreeView1.Items.Add(nil,FGrade.Producao.DisplayName);
  Node.Data := FGrade.Producao;
  TreeView1.Selected := Node;
  while not ListaCanalVenda.Eof do
  begin
    Valores := TValores.Create(ListaCanalVenda.FieldByName('DESCRICAO').AsString,ListaCanalVenda.FieldByName('CANAL_VENDA').AsInteger);
    Node := TreeView1.Items.Add(nil,Valores.DisplayName);
    Node.Data := Valores;
    ListaCanalVenda.Next;
  end;
end;

procedure TFDistribuicaoCanalVenda.FormActivate(Sender: TObject);
begin
  wtsCallAsync('MILLENIUM!MPITBULLJEANS.PRODUCAO.LISTAPACOTES',['PRODUCAO'],[FProducao],nil,ConsultaPacotesDone);
  lblSaldo.Caption := ''
end;

function TFDistribuicaoCanalVenda.GetCells(AEstampa, ACor,
  ATamanho: string): Integer;
var
  I: Integer;
begin
  for I := 0 to FMapas.Count -1 do
  begin
    if (FMapas[I].Estampa.Codigo = AEstampa) and
       (FMapas[I].Cor.Codigo = ACor) and
       (FMapas[I].Tamanho = ATamanho) then
    begin
      Result := StrToIntDef(PalGrid1.Cells[FMapas[I].Col,FMapas[I].Row],0);
      Break;
    end;
  end;
end;

procedure TFDistribuicaoCanalVenda.SetCells(AEstampa, ACor,
  ATamanho: string; const Value: Integer);
var
  I: Integer;
begin
  for I := 0 to FMapas.Count -1 do
  begin
    if (FMapas[I].Estampa.Codigo = AEstampa) and
       (FMapas[I].Cor.Codigo = ACor) and
       (FMapas[I].Tamanho = ATamanho) then
    begin
      PalGrid1.Cells[FMapas[I].Col,FMapas[I].Row] := IntToStr(Value);
      Break;
    end;
  end;
end;

function TFDistribuicaoCanalVenda.CalcularSaldoProduto(ACol,ARow: Integer): Integer;
var
  I: Integer;
  C,E,T: string;
  M: TMapa;
  V: TValores;
  Valor: TValor;
begin
  Result := 0;
  M := FMapas.GetMapaByColRow(ACol,ARow);
  Valor := FGrade.Producao.GetValorByProduto(M.Estampa.Codigo,M.Cor.Codigo,M.Tamanho);
  if Valor <> nil then
    Result := Valor.Quantidade;
  for I := 1 to TreeView1.Items.Count-1 do
  begin
   V := TValores(TreeView1.Items[I].Data);
   Valor := V.GetValorByProduto(M.Estampa.Codigo,M.Cor.Codigo,M.Tamanho);
   if Valor <> nil then
     Result := Result - Valor.Quantidade;
  end;
end;

{ TEstampas }

function TEstampas.Add: TEstampa;
begin
  Result := TEstampa.Create;
  inherited Add(Result);
end;

function TEstampas.GetEstampa(Index: Integer): TEstampa;
begin
  Result := TEstampa(inherited Items[Index]);
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

{ TProducoes }

function TValores.Add: TValor;
begin
  Result := TValor.Create;
  inherited Add(Result);
end;

constructor TValores.Create(const AName: string; ACanalVenda: Integer);
begin
  inherited Create;
  CanEdit := True;
  Name := AName;
  CanalVenda := ACanalVenda;
end;

function TValores.DisplayName: string;
begin
  Result := Name + ' ('+IntToStr(Total)+')';
end;

function TValores.GetValorByProduto(const AEstampa, ACor,ATamanho: string): TValor;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count-1 do
  begin
    if (Items[I].Estampa = AEstampa) and (Items[I].Cor = ACor) and (Items[I].Tamanho = ATamanho) then
    begin
      Result := Items[I];
      Break;
    end;  
  end;
end;

function TValores.GetValor(Index: Integer): TValor;
begin
  Result := TValor(inherited Items[Index]);
end;

{ TMapas }

function TMapas.Add: TMapa;
begin
  Result := TMapa.Create;
  inherited Add(Result);
end;

function TMapas.GetMapa(Index: Integer): TMapa;
begin
  Result := TMapa(inherited Items[Index]);
end;

function TMapas.GetMapaByColRow(const ACol, ARow: Integer): TMapa;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count-1 do
  begin
    Result := Items[I];
    if (Result.Col = ACol) and (Result.Row = ARow) then
      Break;
  end;
end;

{ TGrade }

constructor TGrade.Create;
begin
  inherited;
  Estampas := TEstampas.Create;
  Cores := TCores.Create;
  Tamanhos := TStringList.Create;
  Producao := TValores.Create('PRODUÇÃO',-1);
  Producao.CanEdit := False;
end;

destructor TGrade.Destroy;
begin
  inherited;
  Estampas.Free;
  Cores.Free;
  Tamanhos.Free;
  Producao.Free;
end;

procedure TFDistribuicaoCanalVenda.FormDestroy(Sender: TObject);
begin
  FGrade.Free;
  FMapas.Free;
end;

procedure TFDistribuicaoCanalVenda.PalGrid1GetDrawStyle(Sender: TObject;
  Col, Row: Integer; var Style: TDrawStyle);
begin
  if Col >= 2 then
    Style := dsTextCenter;
end;

procedure TFDistribuicaoCanalVenda.TreeView1Change(Sender: TObject;
  Node: TTreeNode);
begin
  FCurValores := TValores(Node.Data);
  FCurNode := Node;
  lblCanalCur.Caption := 'Canal de Vendas: '+FCurValores.Name;
  PreencherGrade(FGrade, FCurValores);
end;

procedure TFDistribuicaoCanalVenda.PalGrid1CanEditCell(Sender: TObject;
  Col, Row: Integer; var CanEdit: Boolean);
var
  M: TMapa;
  Q: Integer;
  V: TValor;
begin
  Q := 0;
  CanEdit := False;
  M := FMapas.GetMapaByColRow(Col,Row);
  V := FGrade.Producao.GetValorByProduto(M.Estampa.Codigo,M.Cor.Codigo,M.Tamanho);
  if V <> nil then
    Q := V.Quantidade;
  if Q > 0 then
    CanEdit := FCurValores.CanEdit;
end;

function TValores.Total: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count-1 do
    Inc(Result,Items[I].Quantidade);
end;

procedure TFDistribuicaoCanalVenda.PalGrid1CellExit(Sender: TObject; Col,
  Row: Integer);
var
  X,I: Integer;
  Valor: TValor;
begin
  lblSaldo.Caption := '';
  if not FCurValores.CanEdit then
    Exit;
  Valor := nil;
  for I := 0 to FMapas.Count-1 do
  begin
    if (FMapas[I].Col = Col) and (FMapas[I].Row = Row) then
    begin
      for X := 0 to FCurValores.Count-1 do
      begin
        if (FCurValores[X].Estampa = FMapas[I].Estampa.Codigo) and (FCurValores[X].Cor = FMapas[I].Cor.Codigo) and (FCurValores[X].Tamanho = FMapas[I].Tamanho) then
        begin
          Valor := FCurValores[X];
          Break;
        end
      end;
      if Valor = nil then
      begin
        with FCurValores.Add do
        begin
          Estampa := FMapas[I].Estampa.Codigo;
          Cor := FMapas[I].Cor.Codigo;
          Tamanho := FMapas[I].Tamanho;
          Quantidade := StrToIntDef(PalGrid1.Cells[Col,Row],0);
        end;
      end else
        Valor.Quantidade := StrToIntDef(PalGrid1.Cells[Col,Row],0);
      Break;
    end;
  end;
  FCurNode.Text := FCurValores.DisplayName;
end;

procedure TFDistribuicaoCanalVenda.PalGrid1CellEnter(Sender: TObject; Col,
  Row: Integer);
var
  M: TMapa;
  I: Integer;
  S: string;
begin
  M := FMapas.GetMapaByColRow(Col,Row);
  I := CalcularSaldoProduto(Col,Row);
  if I > 0 then
    S := '( '+IntToStr(I)+' ) itens '
  else
    S := 'Não há ';

  lblSaldo.Caption := S + 'saldo para distribuição da Estampa: '+M.Estampa.Desricao+' Cor: '+M.Cor.Desricao+' Tamanho: '+M.Tamanho;
end;

procedure TFDistribuicaoCanalVenda.PalGrid1ChangeDrawing(Sender: TObject;
  ACol, ARow: Integer; var ForeColor, BackColor: TColor);
var
  M: TMapa;
  V: TValor;
  Q: Integer;
begin
  if (ACol > 1) and (ARow > 0) then
  begin
    Q := 0;
    M := FMapas.GetMapaByColRow(ACol,ARow);
    V := FGrade.Producao.GetValorByProduto(M.Estampa.Codigo,M.Cor.Codigo,M.Tamanho);
    if V <> nil then
      Q := V.Quantidade;
    if Q <= 0 then
      BackColor := PalGrid1.FixedColor;
  end;
end;

procedure TFDistribuicaoCanalVenda.DistribuirLotes;
var
  I,X: Integer;
  Distribuicoes,R: TwtsRecordset;
  Valores: TValores;
  ValorOriginal: TValor;
begin
  Distribuicoes := TwtsRecordset.CreateFromStreamEx(TMemoryStream.Create,rdInput);
  R := TwtsRecordset.CreateFromStreamEx(TMemoryStream.Create,rdInput);
  try
    Distribuicoes.Transaction := 'MILLENIUM!MPITBULLJEANS.PRODUCAO.DISTRIBUICAO';
    for I := 1 to TreeView1.Items.Count-1 do
    begin
      Valores := TValores(TreeView1.Items[I].Data);
      for X := 0 to Valores.Count-1 do
      begin
        ValorOriginal := FGrade.Producao.GetValorByProduto(Valores[X].Estampa,Valores[X].Cor,Valores[X].Tamanho);
        if Valores[X].Quantidade > 0 then
        begin
          Distribuicoes.New;
          Distribuicoes.FieldValuesByName['CANAL_VENDA'] := Valores.CanalVenda;
          Distribuicoes.FieldValuesByName['ESTAMPA'] := Valores[X].Estampa;
          Distribuicoes.FieldValuesByName['COR'] := Valores[X].Cor;
          Distribuicoes.FieldValuesByName['TAMANHO'] := Valores[X].Tamanho;
          Distribuicoes.FieldValuesByName['QUANTIDADE'] := Valores[X].Quantidade;
          Distribuicoes.FieldValuesByName['LOTES'] := ValorOriginal.Lotes;
          Distribuicoes.FieldValuesByName['QUANTIDADES'] := ValorOriginal.Quantidades;
          Distribuicoes.FieldValuesByName['SITUACOES'] := ValorOriginal.Situacoes;
          Distribuicoes.Add;
        end;
      end;
    end;
    wtsCallEx('MILLENIUM!MPITBULLJEANS.PRODUCAO.DISTIBRUIRLOTES',['PRODUCAO','DISTRIBUICOES'],[FProducao,Distribuicoes.Data],R);
  finally
    Distribuicoes.Free;
    R.Free;
  end;
end;

procedure TFDistribuicaoCanalVenda.LinkList1Links0Click(Sender: TObject);
begin
  DistribuirLotes;
  ModalResult := mrOk;
end;

procedure TFDistribuicaoCanalVenda.LinkList1Links1Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.

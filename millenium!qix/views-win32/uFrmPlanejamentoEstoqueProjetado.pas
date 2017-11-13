unit uFrmPlanejamentoEstoqueProjetado;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DMBase, StdCtrls, wtsPainter, dmPanel, LinkList, Grids, PalGrid, wtsStream,
  wtsClient, StatusPanel,Math,millenium_variants,ResUnit,ActiveX,Excel2000,
  ExtCtrls,contnrs, PngImage, ProEffectImage;

type
   TMapProdutoGrid = class
     ID: Integer;
     Row: Integer;
     Col: Integer;
   end;

  TFPlanejamentoEstoque = class(TDMBase)
    dmPanel1: TdmPanel;
    dmPanel2: TdmPanel;
    LinkList1: TLinkList;
    PalGrid1: TPalGrid;
    OpenDialog: TOpenDialog;
    pnlLOG: TPanel;
    MemoLog: TMemo;
    Panel2: TPanel;
    Memo2: TMemo;
    LinkList2: TLinkList;
    pnlAviso: TPanel;
    ProEffectImage1: TProEffectImage;
    lblAprovado: TLabel;
    procedure PalGrid1ChangeDrawing(Sender: TObject; ACol, ARow: Integer;
      var ForeColor, BackColor: TColor);
    procedure PalGrid1GetDrawStyle(Sender: TObject; Col, Row: Integer;
      var Style: TDrawStyle);
    procedure LinkList1Links1Click(Sender: TObject);
    procedure PalGrid1GetEditStyle(Sender: TObject; Col, Row: Integer;
      var Style: TEditStyle; var ReadOnly: Boolean);
    procedure PalGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure PalGrid1CellChanged(Sender: TObject; Col, Row: Integer);
    procedure LinkList1Links0Click(Sender: TObject);
    procedure LinkList1Links2Click(Sender: TObject);
    procedure LinkList1Links3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LinkList2Links0Click(Sender: TObject);
  private
    FStatusPanel: TStatusPanel;
    FID:Integer;
    FInicioColTamanho:Integer;
    FMapProdutosProd: TStringList;
    FMapProdutosVend: TStringList;
    procedure ListaPlanejamentoDone(Params: TwtsRecordset; Result: TwtsClientRecordset; var UserData: IUnknown);
    procedure CriarPlanejamentoDone(Params: TwtsRecordset; Result: TwtsClientRecordset; var UserData: IUnknown);
    procedure SalvarPlanejamentoDone(Params: TwtsRecordset; Result: TwtsClientRecordset; var UserData: IUnknown);
    procedure TotalizarLinhas;
    function RowIsVenda(ARow: Integer): Boolean;
    function IndexColTotal(ARow: Integer): Integer;
    procedure CalcularSaldo(ARow: Integer);
    function ExcelToRecord(const AFileName:string): TwtsRecordset;
    procedure PreencherDadosProduzidos(ADados: TwtsRecordset);
  public
    { Public declarations }
    function  DoCommand:Integer;override;
  end;

var
  FPlanejamentoEstoque: TFPlanejamentoEstoque;
  CID: Integer;
  CGradePadrao: Integer;
  CVendas: Integer;
  CEstoque: Integer;
  CProduzido: Integer;
  CSaldo: Integer;

implementation

{$R *.DFM}

{ TFPlanejamentoEstoque }
procedure TFPlanejamentoEstoque.CriarPlanejamentoDone(Params:TwtsRecordset;Result:TwtsClientRecordset;var UserData:IUnknown);
begin
  wtsCallAsync('MILLENIUM!QIX.PLANEJAMENTOS_ESTOQUES.ListarItensPlanejamento',['PLANEJAMENTO_ESTOQUE'],[FID],nil,ListaPlanejamentoDone);
end;

function TFPlanejamentoEstoque.IndexColTotal(ARow:Integer):Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to PalGrid1.ColCount-1 do
  begin
    if SameText(PalGrid1.Cells[I,ARow],'Total') then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TFPlanejamentoEstoque.TotalizarLinhas;
var
  R,C,ColTotal: Integer;
begin
  ColTotal := 0;
  for R := 0 to PalGrid1.RowCount-1 do
  begin
    if IndexColTotal(R) > -1 then
      ColTotal := IndexColTotal(R);
    for C := FInicioColTamanho to ColTotal-1 do
    begin
      try
        if PalGrid1.Cells[0,R] <> '0' then
          if StrToInt64Def(PalGrid1.Cells[C,R],0) <> 0 then
            PalGrid1.Cells[ColTotal,R] := IntToStr(StrToInt64Def(PalGrid1.Cells[ColTotal,R],0) + StrToInt64Def(PalGrid1.Cells[C,R],0));
      except
      end;
    end;
  end;  
end;

procedure TFPlanejamentoEstoque.CalcularSaldo(ARow: Integer);
var
  R,C,RowProd,RowSaldo,ColTotal,Vendas,Estoque,Produzido: Integer;
begin
  //Subir até alinha que representa o produto e descer calculando
  for RowProd := ARow Downto 1 do
  begin
    if PalGrid1.Cells[0,RowProd] = '0' then
      Break;
  end;

  for RowSaldo := RowProd to PalGrid1.RowCount-1 do
  begin
    if PalGrid1.Cells[0,RowSaldo] = IntToStr(CSaldo) then
      Break;
  end;

  if IndexColTotal(RowProd) > -1 then
    ColTotal := IndexColTotal(RowProd);

  for C := FInicioColTamanho to ColTotal do
  begin
    Vendas := 0;
    Estoque := 0;
    Produzido := 0;
    for R := RowProd to RowSaldo do
    begin
      //Linha da vendas selecionada
      if (Copy(PalGrid1.Cells[0,R],1,1) = IntToStr(CVendas)) and (PalGrid1.Cells[3,R] = '1') then
        Vendas := Vendas + StrToInt64Def(PalGrid1.Cells[C,R],0)
      else
      if PalGrid1.Cells[0,R] = IntToStr(CEstoque) then
        Estoque := StrToInt64Def(PalGrid1.Cells[C,R],0)
      else
      if PalGrid1.Cells[0,R] = IntToStr(CProduzido) then
        Produzido := StrToInt64Def(PalGrid1.Cells[C,R],0);
    end;                                                          
    PalGrid1.Cells[C,RowSaldo] := IntToStr(Estoque-Vendas+Produzido);
  end;
end;

procedure TFPlanejamentoEstoque.ListaPlanejamentoDone(Params:TwtsRecordset;Result:TwtsClientRecordset;var UserData:IUnknown);
var
  Periodos,Vendas: TwtsRecordset;
  Key,S,Tam: string;
  I,ColTamanho,RowProduto,Periodo: Integer;
  Value:Double;
  QtdPeriodo,QtdMaxCol: Integer;
  MapProdutoGrid: TMapProdutoGrid;
  procedure SetValue(ACol,ARow:Integer;AValue:Double);
  begin
    PalGrid1.Cells[ACol,ARow] := '';
    if AValue <> 0 then
      PalGrid1.Cells[ACol,ARow] := FloatToStr(AValue);
  end;
begin
  if Result.RecordCount = 0 then
  begin
    wtsCallAsync('MILLENIUM!QIX.PLANEJAMENTOS_ESTOQUES.CriarItensPlanejamento',['PLANEJAMENTO_ESTOQUE'],[FID],nil,CriarPlanejamentoDone);
    Exit;
  end;
                                                  
  Periodos := Result.CreateFieldRecordset('PERIODOS');
  QtdPeriodo := VarToIntDef(Periodos.RecordCount,1);
  
  CID := 1;
  CGradePadrao := CID+1;
  CVendas := CGradePadrao+1;
  CEstoque := CGradePadrao+QtdPeriodo+1;
  CProduzido := CEstoque+1;
  CSaldo := CProduzido+1;
  try
    QtdMaxCol := 0;
    RowProduto := 1;
    PalGrid1.ColCount := 20;
    PalGrid1.FixedCols := 3;
    PalGrid1.RowCount := 15000;
    while not Result.Eof do
    begin
      Key := VarToStr(Result.FieldValuesByName['COD_PRODUTO'])+'|'+VarToStr(Result.FieldValuesByName['COR'])+'|'+VarToStr(Result.FieldValuesByName['ESTAMPA']);

      PalGrid1.Cells[0,RowProduto] := '0';
      PalGrid1.Cells[1,RowProduto] := VarToStr(Result.FieldValuesByName['COD_PRODUTO'])+' '+VarToStr(Result.FieldValuesByName['DESC_COR']);

      PalGrid1.Cells[0,RowProduto+CID] := IntToStr(CID);
      PalGrid1.Cells[2,RowProduto+CID] := 'ID';

      PalGrid1.Cells[0,RowProduto+CGradePadrao] := IntToStr(CGradePadrao);
      PalGrid1.Cells[2,RowProduto+CGradePadrao] := 'Grade Padrão(%)';

      Periodos.First;
      while not Periodos.Eof do
      begin
        PalGrid1.Cells[0,RowProduto+CVendas+Periodos.RecNo] := IntToStr(CVendas)+':'+VarToStr(Periodos.FieldValuesByName['ITEM']);
        PalGrid1.Cells[2,RowProduto+CVendas+Periodos.RecNo] := 'Vendas até '+VarToStr(Periodos.FieldValuesByName['ITEM'])+' dias';
        PalGrid1.Cells[3,RowProduto+CVendas+Periodos.RecNo] := '';
        Periodos.Next;
      end;  

      PalGrid1.Cells[0,RowProduto+CEstoque] := IntToStr(CEstoque);
      PalGrid1.Cells[2,RowProduto+CEstoque] := 'Estoque';

      PalGrid1.Cells[0,RowProduto+CProduzido] := IntToStr(CProduzido);
      PalGrid1.Cells[2,RowProduto+CProduzido] := 'Produzido';

      PalGrid1.Cells[0,RowProduto+CSaldo] := IntToStr(CSaldo);
      PalGrid1.Cells[2,RowProduto+CSaldo] := 'Saldo';

      ColTamanho := FInicioColTamanho;//Coluna onde se inicia os tamanhos
      while not Result.Eof do//Todos os tamanhos
      begin
        Vendas.Free;
        Vendas := Result.CreateFieldRecordset('VENDAS');

        Tam := VarToStr(Result.FieldValuesByName['TAMANHO']);
        PalGrid1.Cells[ColTamanho,RowProduto] := Tam;

        PalGrid1.Cells[ColTamanho,RowProduto+CID] := VarToStr(Result.FieldValuesByName['PLAN_ESTOQUE_PRODUTO']);
        PalGrid1.Cells[ColTamanho,RowProduto+CGradePadrao] := VarToStr(Result.FieldValuesByName['QTD_PROP_GRADE']);

        //Vendas
        if VarToIntDef(Result.FieldValuesByName['QTD_PROP_GRADE'],0) > 0 then
        begin
          Periodos.First;
          while not Periodos.Eof do
          begin
            S := PalGrid1.Cells[0,RowProduto+CVendas+Periodos.RecNo];
            Periodo := StrToIntDef(Copy(S,Pos(':',S)+1,Length(S)),-1);
            if Vendas.Locate(['PERIODO'],[Periodo]) then
            begin
              PalGrid1.Cells[2,RowProduto+CVendas+Periodos.RecNo] := 'Vendas até '+VarToStr(Periodos.FieldValuesByName['ITEM'])+' dias '+VarToStr(VarToIntDef(Vendas.FieldValuesByName['QTD_VENDA'],0))+' Peça(s)';
              PalGrid1.Cells[3,RowProduto+CVendas+Periodos.RecNo] := VarToStrDef(Vendas.FieldValuesByName['APROVADO'],'0');

              Value := RoundFloat(VarToIntDef(Vendas.FieldValuesByName['QTD_VENDA'],0)*(Result.FieldValuesByName['QTD_PROP_GRADE']/100),True,0);
              SetValue(ColTamanho,RowProduto+CVendas+Periodos.RecNo,Value);

              MapProdutoGrid := TMapProdutoGrid.Create;
              MapProdutoGrid.ID := Result.FieldValuesByName['PLAN_ESTOQUE_PRODUTO'];
              MapProdutoGrid.Row := RowProduto+CVendas+Periodos.RecNo;
              MapProdutoGrid.Col := ColTamanho;
              FMapProdutosVend.AddObject(Key,MapProdutoGrid);
            end;
            Periodos.Next;
          end;
        end;

        SetValue(ColTamanho,RowProduto+CEstoque,VarToIntDef(Result.FieldValuesByName['QTD_ESTOQUE'],0));
        SetValue(ColTamanho,RowProduto+CProduzido,VarToIntDef(Result.FieldValuesByName['QTD_PRODUZIDO'],0));

        MapProdutoGrid := TMapProdutoGrid.Create;
        MapProdutoGrid.ID := Result.FieldValuesByName['PLAN_ESTOQUE_PRODUTO'];
        MapProdutoGrid.Row := RowProduto+CProduzido;
        MapProdutoGrid.Col := ColTamanho;
        FMapProdutosProd.AddObject(VarToStr(Result.FieldValuesByName['COD_PRODUTO'])+Tam,MapProdutoGrid);
        PalGrid1.RowHeights[RowProduto+CID] := 0;

        Inc(ColTamanho);
        QtdMaxCol := Max(QtdMaxCol,ColTamanho);

        Result.Next;
        if Key <> VarToStr(Result.FieldValuesByName['COD_PRODUTO'])+'|'+VarToStr(Result.FieldValuesByName['COR'])+'|'+VarToStr(Result.FieldValuesByName['ESTAMPA']) then
          Break;//Mudou de Grupo
      end;
      PalGrid1.Cells[ColTamanho,RowProduto] := 'Total';
      Inc(RowProduto,6+QtdPeriodo);
      CalcularSaldo(RowProduto);
    end;
  finally
    PalGrid1.RowCount := RowProduto;
    PalGrid1.ColCount := QtdMaxCol+1;
    PalGrid1.Visible := True;
    Vendas.Free;
    TotalizarLinhas;
    Periodos.Free;
    FStatusPanel.Free;
  end;
end;

function TFPlanejamentoEstoque.DoCommand: Integer;
var
   I: Integer;
   R: TwtsRecordset;
begin
  for I := 0 to CommandParser.Count - 1 do
  begin
    if CommandParser.Items[I].Tag = 'PLANEJAMENTO_ESTOQUE' then
      FID := StrToInt64Def(CommandParser.Items[I].CommandOf('PLANEJAMENTO_ESTOQUE'),-1);
  end;

  LinkList1.Links[0].Visible := True;
  LinkList1.Links[1].Visible := True;
  LinkList1.Links[2].Visible := True;
  LinkList1.Links[3].Visible := False;
  pnlAviso.Visible := False;
  wtsCallEx('MILLENIUM!QIX.PLANEJAMENTOS_ESTOQUES.ConsultaStatusAprovacao',['PLANEJAMENTO_ESTOQUE'],[FID],R);
  if VarToBool(R.FieldValuesByName['APROVADO']) then
  begin                                                
    lblAprovado.Caption := Format(lblAprovado.Caption,[VarToStr(R.FieldValuesByName['USUARIO_APROVACAO']),VarToStr(R.FieldValuesByName['DATA_APROVACAO'])]);
    LinkList1.Links[0].Visible := False;
    LinkList1.Links[1].Visible := False;
    LinkList1.Links[2].Visible := False;
    LinkList1.Links[3].Visible := True;
    pnlAviso.Visible := True;
  end;

  PalGrid1.Visible := False;

  PalGrid1.Cells[0,0] := 'Tipo';
  PalGrid1.ColWidths[0] := 0;

  PalGrid1.Cells[1,0] := 'Produto';
  PalGrid1.ColWidths[1] := 200;

  PalGrid1.Cells[2,0] := 'Medidas';
  PalGrid1.ColWidths[2] := 200;

  PalGrid1.Cells[3,0] := '';
  PalGrid1.ColWidths[3] := 30;

  FInicioColTamanho := 4;

  FStatusPanel := TStatusPanel.Create(dmPanel2,False,True,True,False);
  wtsCallAsync('MILLENIUM!QIX.PLANEJAMENTOS_ESTOQUES.ListarItensPlanejamento',['PLANEJAMENTO_ESTOQUE'],[FID],nil,ListaPlanejamentoDone);
end;

procedure TFPlanejamentoEstoque.PalGrid1ChangeDrawing(Sender: TObject;
  ACol, ARow: Integer; var ForeColor, BackColor: TColor);
begin
  //Grupo
  if (PalGrid1.Cells[0,ARow] = '0')  then
    BackColor := RGB(248,248,248);

  //Produto sem venda
  {if (ACol = 3)  then
  begin
    if RowIsVenda(ARow) and (PalGrid1.Cells[ACol,ARow]<>'')  then
      BackColor := RGB(255,255,255)
    else
      BackColor := RGB(248,248,248)
  end;}

  //Total do grupo  
  if (PalGrid1.Cells[0,ARow] = IntToStr(CSaldo)) and (ACol > 2)  then
    BackColor := RGB(248,248,248);

  if (PalGrid1.Cells[0,ARow] = IntToStr(CSaldo)) and (ACol >= FInicioColTamanho) then
    if StrToInt64Def(PalGrid1.Cells[ACol,ARow],0) < 0 then
      ForeColor := clRed;
end;

procedure TFPlanejamentoEstoque.PalGrid1GetDrawStyle(Sender: TObject; Col,
  Row: Integer; var Style: TDrawStyle);
begin
  if Col > 2 then
    Style := dsInteger;
end;

procedure TFPlanejamentoEstoque.LinkList1Links1Click(Sender: TObject);
begin
  FStatusPanel := TStatusPanel.Create(dmPanel2,False,True,True,False);
  if MessageBox(Handle, PChar('Todos os dados digitados serão perdidos, deseja continuar?'), 'Planejamento Estoque Projetado', MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2) = mrYes then
    wtsCallAsync('MILLENIUM!QIX.PLANEJAMENTOS_ESTOQUES.CriarItensPlanejamento',['PLANEJAMENTO_ESTOQUE'],[FID],nil,CriarPlanejamentoDone);
end;

function TFPlanejamentoEstoque.RowIsVenda(ARow: Integer): Boolean;
begin
  Result := Copy(PalGrid1.Cells[0,ARow],1,1) = IntToStr(CVendas);
end;

procedure TFPlanejamentoEstoque.PalGrid1GetEditStyle(Sender: TObject; Col,
  Row: Integer; var Style: TEditStyle; var ReadOnly: Boolean);
begin
  ReadOnly := True;
  if (Col = 3) and RowIsVenda(Row) and (PalGrid1.Cells[Col,Row]<>'')  then
  begin
    Style := esCheck;
    ReadOnly := False;
  end;  
end;

procedure TFPlanejamentoEstoque.PalGrid1SelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := (PalGrid1.Cells[0,ARow] <> '0') and
               //(ACol <> IndexColTotal(ARow)); //and
               (PalGrid1.Cells[0,ARow] <> IntToStr(CSaldo)){ and
               (ACol = 3) and RowIsVenda(ARow)};  
end;

procedure TFPlanejamentoEstoque.PalGrid1CellChanged(Sender: TObject; Col,
  Row: Integer);
begin
  CalcularSaldo(Row);
end;

procedure TFPlanejamentoEstoque.SalvarPlanejamentoDone(Params: TwtsRecordset; Result: TwtsClientRecordset; var UserData: IUnknown);
begin
  ShowMessage('Comando executado com sucesso');
  Window.Close;
end;

procedure TFPlanejamentoEstoque.LinkList1Links0Click(Sender: TObject);
var
  ItensProd,ItensVend: TwtsRecordset;
  I,Qtd,Sel,Periodo: Integer;
  MapProdutoGrid:TMapProdutoGrid;
  S:string;
begin
  FStatusPanel := TStatusPanel.Create(dmPanel2,False,True,True,False);
  if MessageBox(Handle, PChar('Deseja salvar planejamento?'), 'Planejamento Estoque Projetado', MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2) = mrYes then
  begin
    ItensProd := TwtsRecordset.CreateFromStreamEx(TMemoryStream.Create,rdInput);
    ItensProd.Transaction := 'MILLENIUM!QIX.PLANEJAMENTOS_ESTOQUES.ITENS';
    //Vamos coletar os itens produzidos
    for I := 0 to FMapProdutosProd.Count-1 do
    begin
      MapProdutoGrid := TMapProdutoGrid(FMapProdutosProd.Objects[I]);
      Qtd := StrToInt64Def(PalGrid1.Cells[MapProdutoGrid.Col,MapProdutoGrid.Row],0);
      if (MapProdutoGrid.ID > 0) and (Qtd>0) then
      begin
        ItensProd.New;
        ItensProd.FieldValuesByName['PLAN_ESTOQUE_PRODUTO'] := MapProdutoGrid.ID;
        ItensProd.FieldValuesByName['QTD_PRODUZIDO'] := Qtd;
        ItensProd.Add;
      end;
    end;

    ItensVend := TwtsRecordset.CreateFromStreamEx(TMemoryStream.Create,rdInput);
    ItensVend.Transaction := 'MILLENIUM!QIX.PLANEJAMENTOS_ESTOQUES.ITENS';
    //Vamos coletar as vendas selecionadas
    for I := 0 to FMapProdutosVend.Count-1 do
    begin
      MapProdutoGrid := TMapProdutoGrid(FMapProdutosVend.Objects[I]);
      Qtd := StrToInt64Def(PalGrid1.Cells[MapProdutoGrid.Col,MapProdutoGrid.Row],0);
      Sel := StrToInt64Def(PalGrid1.Cells[3,MapProdutoGrid.Row],0);
      S := PalGrid1.Cells[0,MapProdutoGrid.Row];
      Periodo := StrToIntDef(Copy(S,Pos(':',S)+1,Length(S)),-1);
      if (MapProdutoGrid.ID > 0) and (Sel<>0) then
      begin
        ItensVend.New;
        ItensVend.FieldValuesByName['PLAN_ESTOQUE_PRODUTO'] := MapProdutoGrid.ID;
        ItensVend.FieldValuesByName['QTD_VENDA'] := Qtd;
        ItensVend.FieldValuesByName['PERIODO'] := Periodo;
        ItensVend.Add;
      end;
    end;
    wtsCallAsync('MILLENIUM!QIX.PLANEJAMENTOS_ESTOQUES.SalvarPlanejamento',['PLANEJAMENTO_ESTOQUE','ITENS_PRODUZIDOS','ITENS_VENDAS'],[FID,ItensProd.Data,ItensVend.Data],nil,SalvarPlanejamentoDone);
  end;
end;

function TFPlanejamentoEstoque.ExcelToRecord(const AFileName:string): TwtsRecordset;
var
  Qtd,I,T,LCID: Integer;
  ExcelApplication1: TExcelApplication;
  ExcelWorksheet1: TExcelWorksheet;
  ExcelWorkbook1: TExcelWorkbook;
  Value:string;
  Tamanhos: array of string;
begin
  CoInitialize(nil);
  ExcelApplication1 := TExcelApplication.Create(nil);
  ExcelWorksheet1 := TExcelWorksheet.Create(nil);
  ExcelWorkbook1 := TExcelWorkbook.Create(nil);

  LCID := GetUserDefaultLCID;
  try
    try
      ExcelApplication1.Connect;
    except
      raise Exception.Create('Excel não instalado!');
    end;
    ExcelApplication1.Workbooks.Open(AFileName,EmptyParam,true,EmptyParam,EmptyParam,EmptyParam,True,EmptyParam,EmptyParam,False,EmptyParam,EmptyParam,EmptyParam,LCID);
    ExcelWorkbook1.ConnectTo(ExcelApplication1.ActiveWorkbook);
    ExcelWorksheet1.ConnectTo(ExcelWorkbook1.ActiveSheet as _Worksheet);

    Value := ExcelWorksheet1.Cells.Item[1,1].Value;
    if not SameText(Value,'Modelo') then
      raise Exception.Create('Arquivo não está no formato esperado!');

    Result := TwtsRecordset.CreateFromStreamEx(TMemoryStream.Create,rdInput);
    Result.Transaction := 'MILLENIUM!QIX.PLANEJAMENTOS_ESTOQUES.PRODUZIDO';

    SetLength(Tamanhos,0);
    for I := 2 to MaxInt do
    begin
      Value := ExcelWorksheet1.Cells.Item[1,I].Value;
      if Trim(Value)='' then
        Break;
      SetLength(Tamanhos,Length(Tamanhos)+1);
      Tamanhos[Length(Tamanhos)-1] := Value;
    end;

    for I := 2 to MaxInt do
    begin
      Value := ExcelWorksheet1.Cells.Item[I,1].Value;
      if Trim(Value)='' then
        Break;

      for T := Low(Tamanhos) to High(Tamanhos) do
      begin
        try
          Qtd := ExcelWorksheet1.Cells.Item[I,T+2].Value;
        except
          Qtd := 0;
        end;
        
        if Qtd > 0 then
        begin
          Result.New;
          Result.FieldValuesByName['PRODUTO'] := Value;
          Result.FieldValuesByName['TAMANHO'] := Tamanhos[T];
          Result.FieldValuesByName['QTD_PRODUZIDO'] := Qtd;
          Result.Add;
        end;
      end;
    end;
  finally
    FreeAndNil(ExcelApplication1);
    FreeAndNil(ExcelWorksheet1);
    FreeAndNil(ExcelWorkbook1);
    CoUninitialize;
  end;
end;

procedure TFPlanejamentoEstoque.PreencherDadosProduzidos(ADados: TwtsRecordset);
var
  Produtos: TwtsRecordset;
  MapProdutoGrid:TMapProdutoGrid;
  Qtd,I: Integer;
begin
  MemoLog.Lines.Clear;
  wtsCallEx('MILLENIUM!QIX.PLANEJAMENTOS_ESTOQUES.LISTARPRODUTOS',['PLANEJAMENTO_ESTOQUE'],[FID],Produtos);
  ADados.First;
  while not ADados.Eof do
  begin
    MapProdutoGrid := nil;
    if Produtos.Locate(['COD_PRODUTO'],[VarToStr(ADados.FieldValuesByName['PRODUTO'])]) then
    begin
      Qtd := Produtos.FieldValuesByName['QTD'];
      if Qtd = 1 then
      begin
        I := FMapProdutosProd.IndexOf(VarToStr(ADados.FieldValuesByName['PRODUTO'])+VarToStr(ADados.FieldValuesByName['TAMANHO']));
        if I >-1 then
        begin
          MapProdutoGrid := TMapProdutoGrid(FMapProdutosProd.Objects[I]);
          PalGrid1.Cells[MapProdutoGrid.Col,MapProdutoGrid.Row] := IntToStr(VarToIntDef(ADados.FieldValuesByName['QTD_PRODUZIDO'],0));
          CalcularSaldo(MapProdutoGrid.Row);
        end;
      end else
        MemoLog.Lines.Add('Produção do produto '+VarToStr(ADados.FieldValuesByName['PRODUTO'])+' não pôde ser importada, produto planejado com cores');
    end else
        MemoLog.Lines.Add('Produção do produto '+VarToStr(ADados.FieldValuesByName['PRODUTO'])+' não pôde ser importada, produto não encontrado no planejado');
    ADados.Next;
  end;
  pnlLOG.Visible := MemoLog.Lines.Count > 0; 
end;

procedure TFPlanejamentoEstoque.LinkList1Links2Click(Sender: TObject);
var
  FileName:string;
  DadosExcel: TwtsRecordset;
begin
  if OpenDialog.Execute then
    FileName := OpenDialog.FileName;

  if not FileExists(FileName) then
    Exit;

  FStatusPanel := TStatusPanel.Create(dmPanel2,False,True,True,False);
  try
    DadosExcel := ExcelToRecord(FileName);
    PreencherDadosProduzidos(DadosExcel);
  finally
    DadosExcel.Free;
    FStatusPanel.Free;
  end;
end;

procedure TFPlanejamentoEstoque.LinkList1Links3Click(Sender: TObject);
begin
  Window.Close;
end;

procedure TFPlanejamentoEstoque.FormCreate(Sender: TObject);
begin
  FMapProdutosProd := TStringList.Create;
  FMapProdutosVend := TStringList.Create;
end;

procedure TFPlanejamentoEstoque.FormDestroy(Sender: TObject);
begin
  FMapProdutosProd.Free;
  FMapProdutosVend.Free;
end;


procedure TFPlanejamentoEstoque.LinkList2Links0Click(Sender: TObject);
begin
  pnlLOG.Visible := False;
end;

initialization
  RegisterDocClass(TFPlanejamentoEstoque);

end.

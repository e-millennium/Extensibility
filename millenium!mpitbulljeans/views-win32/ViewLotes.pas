unit ViewLotes;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, DMBase,
  ComCtrls, StdCtrls, Db, wtsMethodView, DBCtrls, ExtCtrls, GeneralProd,
  LinkList, Menus, DOM, wtsClient, Grids, PalGrid, wtsMethodFrame, Buttons,
  wtsPainter, dmPanel, wtsStream, uRetornoPcte, ImpOficina, ClientConfigs, uSQAnda,
  MethodInput,Resunit,HBCrc;          

type
  TFLotes = class(TDMBase)
    pmLote: TPopupMenu;
    Andamento1: TMenuItem;
    N1: TMenuItem;
    Exclui1: TMenuItem;
    ExcluiLote1: TMenuItem;
    PopupMenu1: TPopupMenu;
    ExcluiOrdem1: TMenuItem;
    AlteraGrade1: TMenuItem;
    AlteraOficina1: TMenuItem;
    wtsLotes: TwtsMethodView;
    dsLotes: TDataSource;
    dmPanel1: TdmPanel;
    wtsMethodView1: TwtsMethodView;
    wtsFases: TwtsMethodView;
    Label3: TLabel;
    Label4: TLabel;
    dmPanel2: TdmPanel;
    CMFrame: TwtsMethodFrame;
    dmPanel3: TdmPanel;
    Panel5: TPanel;
    AnteriorTit: TSpeedButton;
    ProximoTit: TSpeedButton;
    InverteTodosTit: TSpeedButton;
    btdesmarca: TSpeedButton;
    btmarca: TSpeedButton;
    Panel1: TPanel;
    pgPacks: TPalGrid;
    Panel2: TPanel;
    Label1: TLabel;
    lblPecasSel: TLabel;
    Label5: TLabel;
    lblPecas: TLabel;
    Label7: TLabel;
    lblPerdas: TLabel;
    Label9: TLabel;
    lblDefeitos: TLabel;
    Label6: TLabel;
    LinkList1: TLinkList;
    procedure AtualizaLotes(Sender :TObject);
    procedure AndamentoLote(Sender :TObject);
    procedure LiberaEstoque(Sender :TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LinkList1Links4Click(Sender: TObject);
    procedure Exclui1Click(Sender: TObject);
    procedure ExcluiLote1Click(Sender: TObject);
    procedure ExcluiOrdem1Click(Sender: TObject);
    procedure AlteraGrade1Click(Sender: TObject);
    procedure txtOrdem222KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AlteraOficina1Click(Sender: TObject);
    procedure sditCell(Sender: TObject; Col, Row: Integer;
      var CanEdit: Boolean);
    procedure pgPacksGetDrawStyle(Sender: TObject; Col, Row: Integer;
      var Style: TDrawStyle);
    procedure LinkList1Links3Click(Sender: TObject);
    procedure pgPacksSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure pgPacksGetEditStyle(Sender: TObject; Col, Row: Integer;
      var Style: TEditStyle; var ReadOnly: Boolean);
    procedure AnteriorTitClick(Sender: TObject);
    procedure ProximoTitClick(Sender: TObject);
    procedure InverteTodosTitClick(Sender: TObject);
    procedure btdesmarcaClick(Sender: TObject);
    procedure btmarcaClick(Sender: TObject);
    procedure VerificaFaseFinal(Lista: TStringList); // Pendência 25353 09-mar-2010 Douglas Rissi
    procedure VerificaFase(li:TLoteInfo);
    procedure VerificaFases(Lista: TStringList);
    procedure CMFrameDataChanged(Sender: TObject; Field: TField);
    procedure CMFrameGetFieldInfo(Sender: TObject;
      var FieldInfo: TFieldInfo);
    procedure LinkList1Links5Click(Sender: TObject);
    procedure LinkList1Links6Click(Sender: TObject);
    procedure LinkList1Links7Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FProducao:Integer;     // Ordem de Produção Atual
    ListLotes:TListLotes; // Lista com os Lotes
    FastMove:Boolean;
    fInternalChanged:Boolean;
    Function GetSelCount:Integer;
    Function GetSelected:Integer;
    Function IsSelected(Index:Integer):Boolean;
    Function GetCount:Integer;

    Procedure SetLinks(Value:Boolean);
    Procedure GetQtdes(Line:Integer;out qt,df,pd:Integer);
    Procedure AtualizaColWidth;
    procedure CarregaDadosPedido;
    function PermiteAlterarData:Boolean;
    function HasAccess(Id, Value: String): Boolean;
    procedure AtualizaPecasSelecionadas;
  public
    { Public declarations }
  end;

var
  FLotes: TFLotes;

const
   l_selecionado = 0;
   l_ordem  = 1;
   l_grupo  = 2;
   l_pacote = 3;
   l_fase   = 4;
   l_data   = 5;
   l_celula = 6;
   l_produto = 7;
   l_descricao = 8;
   l_estampa = 9;
   l_cor = 10;
   l_tamanho = 11;

   //Se for colocar alguma coluna após esta deve-se verifica impactos
   l_quantidade  = 12;
   l_perdas      = 13;
   l_defeitos    = 14;
   l_canal_venda = 15;

implementation

uses Andamento, LQtde, DistribuicaoCanalVenda, AlterarCanalVenda;

{$R *.DFM}

{ TFLotes }

procedure TFLotes.AtualizaLotes(Sender: TObject);
var
   li:TLoteInfo;
   i:Integer;
   Pecas,Perdas,Defeitos: Double;
begin
     Pecas := 0;
     Perdas := 0;
     Defeitos := 0;

     if fInternalChanged then Exit;

     wtsLotes.Close;
     if (VarToStr(CMFrame.ParamsView.FieldValues['GRUPO_ORDEM'])<>'') or
        (VarToStr(CMFrame.ParamsView.FieldValues['PRODUCAO'])<>'') or
        (VarToStr(CMFrame.ParamsView.FieldValues['FASE'])<>'') or
        (VarToStr(CMFrame.ParamsView.FieldValues['COR'])<>'') or
        (VarToStr(CMFrame.ParamsView.FieldValues['CLIENTE'])<>'') or
        (VarToStr(CMFrame.ParamsView.FieldValues['PEDIDOV'])<>'')  then
     begin
         With wtsLotes Do
         Begin
              ParamsData.Reset;
              ParamsByName['GRUPO_ORDEM'] := CMFrame.ParamsView.FieldValues['GRUPO_ORDEM'];
              ParamsByName['PRODUCAO']    := CMFrame.ParamsView.FieldValues['PRODUCAO'];
              ParamsByName['FASE']        := CMFrame.ParamsView.FieldValues['FASE'];
              ParamsByName['COR']         := CMFrame.ParamsView.FieldValues['COR'];
              ParamsByName['CLIENTE']     := CMFrame.ParamsView.FieldValues['CLIENTE'];
              ParamsByName['PEDIDOV']     := CMFrame.ParamsView.FieldValues['PEDIDOV'];
              ParamsByName['TIPO_PROD']   := CMFrame.ParamsView.FieldValues['TIPO_PROD'];
              ParamsByName['CANAL_VENDA']   := CMFrame.ParamsView.FieldValues['CANAL_VENDA'];
              Open;
              First;
         End;
         FProducao := wtsLotes.FieldByName('producao').AsInteger;
     end else
     begin
          try
             fInternalChanged := True;
             CMFrame.ParamsView.FieldValues['DATA_ENTREGA'] := null;
             CMFrame.ParamsView.FieldValues['DATA_ENTREGA_FINAL'] := null;
          finally
            fInternalChanged := False;
          end;
     end;

     ListLotes.LimpaLista;
     ListLotes.Clear;
     If wtsLotes.Active Then
     Begin
         CarregaDadosPedido;
         While not wtsLotes.Eof do
         Begin
              With wtsLotes do
              Begin
                   li := TLoteInfo.Create;
                   li.Data       := FieldByName('DATA_INICIO').AsDateTime;
                   li.Situacao   := FieldByName('SITUACAO').AsInteger;
                   li.Quantidade := FieldByName('QUANTIDADE').AsFloat;
                   li.Perdas     := FieldByName('PERDAS').AsFloat;
                   li.Defeitos   := FieldByName('DEFEITOS').AsFloat;
                   li.Descricao  := FieldByName('DESC_PARTE').AsString;
                   li.comp       := FieldByName('COMPLEMENTO').AsInteger;
                   li.n_ordem    := FieldByName('N_ORDEM').AsString;
                   li.cc         := FieldByName('COD_CELULA').AsString;

                   li.Oficina         := FieldByName('COD_FORNECEDOR').AsString;
                   li.Ciclo           := FieldByName('CICLO').AsInteger;
                   li.Ficha_Tecnica   := FieldByName('FICHA_TECNICA').AsInteger;
                   li.Acessa_Oficina  := FieldByName('ACESSA_OFICINA').AsBoolean;
                   li.Perdas_Defeitos := FieldByName('PERDAS_DEFEITOS').AsBoolean;
                   li.Tipo_Defeito    := FieldByName('TIPO_DEFEITO').AsBoolean;
                   li.Tipo_Qualidade  := FieldByName('TIPO_QUALIDADE').AsBoolean;
                   li.Acessa_Caixa    := FieldByName('ACESSA_CAIXAS').AsBoolean;
                   li.DivLotes        := FieldByName('DIVIDE_LOTES').AsBoolean;
                   li.Bx_Estoque      := FieldByName('BAIXA_ESTOQUE').AsBoolean;

                   li.lote    := StrToIntDef(FieldByName('LOTE').AsString,0);
                   li.produto := FieldByName('PRODUTO').AsInteger;
                   li.estampa := FieldByName('ESTAMPA').AsInteger;
                   li.cor     := FieldByName('COR').AsInteger;
                   li.tamanho := FieldByName('TAMANHO').AsString;
                   li.es      := FieldByName('COD_EST').AsString;
                   li.cr      := FieldByName('COD_COR').AsString;
                   li.caixa   := FieldByName('CAIXA').AsString;
                   li.folhas  := FieldByName('FOLHAS').AsInteger;
                   li.Enfesto := FieldByName('LANCA_ENFESTO').AsBoolean;
                   li.Complemento := FieldByName('LANCA_COMPLEMENTO').AsBoolean;

                   li.cf      := FieldByName('COD_FASE').AsString;
                   li.cp      := FieldByName('COD_PRODUTO').AsString;
                   li.ds      := FieldByName('DESCRICAO1').AsString;
                   li.Etiqueta:= FieldByName('IMPRIME_ETIQUETA').AsBoolean;
                   // Inicio Pendência 6641
                   li.Ordem   := FieldByName('PRODUCAO').AsInteger;
                   li.Fase    := FieldByName('FASE').AsInteger;
                   li.parte   := FieldByName('PARTE').AsInteger;
                   li.grupo_ordem := FieldByName('GRUPO_ORDEM').AsString;
                   li.canal_venda := FieldByName('DESC_CANAL_VENDA').AsString;
                   li.iOficina := FieldByName('FORNECEDOR').AsInteger;
                   // Termino Pendência 6641

                   Pecas := Pecas + li.Quantidade;
                   Perdas := Perdas + li.Perdas;
                   Defeitos := Defeitos + li.Defeitos;
              End;
              ListLotes.AddLote(li);
              wtsLotes.Next;
         End;
     end;

     If ListLotes.Count=0 Then
     Begin
          pgPacks.RowCount := 2;
          For i:=0 To Pred(pgPacks.ColCount) do
              pgPacks.Cells[i,1] := '';
          pgPacks.Options := pgPacks.Options - [dgeEditing] + [dgeColSizing] ;
     End Else
     Begin
          pgPacks.RowCount := Succ(ListLotes.Count);
          For i:=0 To Pred(ListLotes.Count) do
          Begin
               li := TLoteInfo(ListLotes.Objects[i]);
               With pgPacks do
               Begin
                    Cells[ l_selecionado,Succ(i)] := '0';
                    Cells[ l_ordem,Succ(i)] := li.n_ordem;
                    Cells[ l_pacote,Succ(i)] := Format('%.6d', [li.lote]);
                    Cells[ l_fase,Succ(i)] := li.cf;
                    Cells[ l_data,Succ(i)] := DateToStr(li.Data);
                    Cells[ l_celula,Succ(i)] := li.cc;
                    Cells[ l_produto,Succ(i)] := li.cp;
                    Cells[ l_descricao,Succ(i)] := li.ds;
                    Cells[ l_estampa,Succ(i)] := li.es;
                    Cells[ l_cor,Succ(i)] := li.cr;
                    Cells[ l_tamanho,Succ(i)] := li.tamanho;
                    Cells[ l_quantidade,Succ(i)] := FloatToStr(li.Quantidade);
                    Cells[ l_perdas,Succ(i)] := FloatToStr(li.Perdas);
                    Cells[ l_defeitos,Succ(i)] := FloatToStr(li.Defeitos);
                    Cells[ l_grupo,Succ(i)] := li.grupo_ordem;
                    Cells[ l_canal_venda,Succ(i)] := li.canal_venda;

               End;
          End;
          pgPacks.Options := pgPacks.Options + [dgeEditing];
          pgPacks.Row := 1;
          pgPacks.Col := 12;
     End;
     SetLinks(True);
     AtualizaColWidth;
     lblPecasSel.Caption := '0';
     lblPecas.Caption := FormatFloat('0',Pecas);
     lblPerdas.Caption := FormatFloat('0',Perdas);
     lblDefeitos.Caption := FormatFloat('0',Defeitos);
end;

procedure TFLotes.AtualizaPecasSelecionadas;
var x:Integer;
    qtd: Extended;
    li: TLoteInfo;
begin
  qtd := 0;
  for x:=1 To Pred(pgPacks.RowCount) do
  begin
    if (pgPacks.Cells[l_selecionado,x]<>'0') and (pgPacks.Cells[l_ordem,x]<>'') Then
    begin
      li := TLoteInfo(ListLotes.Objects[x-1]);
      qtd := qtd + li.Quantidade;
    end;
  end;
  lblPecasSel.Caption := FormatFloat('0',qtd);
end;

procedure TFLotes.FormCreate(Sender: TObject);
begin
     ListLotes := TListLotes.Create;
     FastMove := False;

     With pgPacks do
     Begin
          Cells[ l_selecionado,0] := '';
          Cells[ l_ordem,0] := 'O.Corte';
          Cells[ l_pacote,0] := 'Pacote';
          Cells[ l_fase,0] := 'Fase';
          Cells[ l_data,0] := 'Data';
          Cells[ l_celula,0] := 'Célula';
          Cells[ l_produto,0] := 'Produto';
          Cells[ l_descricao,0] := 'Descrição';
          Cells[ l_estampa,0] := 'Estampa';
          Cells[ l_cor,0] := 'Cor';
          Cells[ l_tamanho,0] := 'Tam';
          Cells[ l_quantidade,0] := 'Peças';
          Cells[ l_perdas,0] := 'Perdas';
          Cells[ l_defeitos,0] := 'Defeitos';
          Cells[ l_grupo,0] := 'Grupo OC';
          Cells[ l_canal_venda,0] := 'Canal Venda';
     End;

     LinkList1.Links[0].Visible := Window.HasAccess('PROD_48')=atGrant;
     LinkList1.Links[1].Visible := Window.HasAccess('PROD_49')=atGrant;
     LinkList1.Links[2].Visible := Window.HasAccess('PROD_50')=atGrant;
     LinkList1.Links[3].Visible := Window.HasAccess('PROD_51')=atGrant;
end;

procedure TFLotes.FormDestroy(Sender: TObject);
begin
     ListLotes.Free;
end;

procedure TFLotes.AndamentoLote(Sender: TObject);
Var
   fAnd:TFrmAndamento;
   Lista:TStringList;
   i:Integer;
begin
     If (GetSelCount = 0) Then
          Raise Exception.Create('Selecione o Lote à ser Movimentado');

     fAnd := TfrmAndamento.Create(Self);
     try

          If (GetSelCount>1) or
            (TLoteInfo(ListLotes.Objects[GetSelected]).Count<>0) Then
          Begin
               Lista := TStringList.Create;
               For i:=0 To (GetCount-1) do
                   If IsSelected(i) Then
                      Lista.AddObject('',ListLotes.Objects[i]);

               if Lista.Count > 0 then
               begin
                  VerificaFases(Lista); // Pendência 25354 09-mar-2010 Douglas Rissi
                  if fAnd.IniciaAndamento(Lista) then
                     AtualizaLotes(Self);
               end;

               Lista.Free;
          End Else
          begin
              VerificaFase(TLoteInfo(ListLotes.Objects[GetSelected])); // Pendência 25354 09-mar-2010 Douglas Rissi
              If fAnd.IniciaAndamentoLote(TLoteInfo(ListLotes.Objects[GetSelected])) Then
                 AtualizaLotes(Self);
          end;

     finally
        fAnd.Free;                            
     end;
end;

procedure TFLotes.LiberaEstoque(Sender: TObject);
Var
   fAnd:TFrmAndamento;
   Lista:TStringList;
   i:Integer;
begin
     if GetCount=0  then
        Raise Exception.Create('Selecione a Ordem de Produção.');

     fAnd := TfrmAndamento.Create(Self);
     Lista := TStringList.Create;
     try
        For i:=0 To (GetCount-1) do
            If IsSelected(i) Then
               Lista.AddObject('',ListLotes.Objects[i]);

        if Lista.Count > 0 then
        begin
           VerificaFaseFinal(Lista);
           If fAnd.FinalizaProducao(FProducao,Lista) Then
           Begin
                Application.MessageBox('Comando executado com sucesso.',
                        Pchar(Application.Title),MB_IconInformation);
                AtualizaLotes(Self);
           End;
        end;
     finally
        Lista.Free;
        fAnd.Free;
     end;
end;

procedure TFLotes.LinkList1Links4Click(Sender: TObject);
var x,qt,df,pd:Integer;
    fAlt:TFAltera;
begin
     FAlt := TFAltera.Create(Self);
     Try
        For x:=0 To GetCount do
            If IsSelected(x) Then
            Begin
                 GetQtdes(x,qt,df,pd);
                 FAlt.Execute(TLoteInfo(ListLotes.Objects[x]),qt,df,pd);
            End;
        AtualizaLotes(Self);
     Finally
        fAlt.Free;
     End;
end;

procedure TFLotes.Exclui1Click(Sender: TObject);
var
   Falt:TFAltera;
begin
     if (GetSelected<>1)  then
          Raise Exception.Create('Selecione o Lote à Alterar');

     FAlt := TFAltera.Create(Self);
     Try
        If FAlt.Execute(TLoteInfo(ListLotes.Objects[GetSelected])) Then
           AtualizaLotes(Self);
     Finally
        FAlt.Free;
     End;
end;

procedure TFLotes.ExcluiLote1Click(Sender: TObject);
var
   v:variant;
   x:Integer;

   Procedure DeleteLote(li:TLoteInfo);
   var z:Integer;
   Begin
        If li.Count<2 Then
           wtsCall('millenium.producao.exclui_lote',
              ['situacao'],[li.Situacao],v)
        Else
        For z:=0 To Pred(li.Count) do
            DeleteLote(li.Lotes[z]);
   End;
begin
     If (GetSelCount<1) Then
          Raise Exception.Create('Selecione o Lote à ser Excluído');

     If Application.MessageBox('ATENÇÃO !!!'#13
        + 'Deseja Realmente Excluir Este Lote',
        PChar(Application.Title),MB_ICONEXCLAMATION
        + MB_YESNO + MB_DEFBUTTON2)=IDYES Then
     Begin
          For x:=0 To Pred(ListLotes.Count) do
              If IsSelected(x) Then
                 DeleteLote(TLoteInfo(ListLotes.Objects[x]));
          AtualizaLotes(Self);
          Application.MessageBox('Comando Executado com Sucesso',
                      PChar(Application.Title),mb_ok);
     End;
end;

procedure TFLotes.ExcluiOrdem1Click(Sender: TObject);
var v:Variant;
begin
     If VarToStr(CMFrame.ParamsView.FieldByName('PRODUCAO').AsString)='' Then Exit;


     If Application.MessageBox('Deseja excluir esta Ordem de Produção?',
        PChar(Application.title),MB_YESNO + MB_ICONWARNING + MB_DEFBUTTON2)=IDYES Then
     {If Application.MessageBox(pchar('Ao excluir esta Ordem de Produção, se houver produtos que '+
                               'já foram finalizados, os mesmos '+
                               'serão excluidos do estoque.'+#13#10+
                               'Deseja excluir mesmo assim?'),PChar(Application.title),
                               MB_YESNO + MB_ICONWARNING + MB_DEFBUTTON2)=IDYES Then}
     If Application.MessageBox('Você tem certeza que deseja excluir?',
        PChar(Application.title),MB_YESNO + MB_ICONWARNING + MB_DEFBUTTON2)=IDYES Then
     If Application.MessageBox('Deseja excluir esta Ordem de Produção?',
        PChar(Application.title),MB_YESNO + MB_ICONWARNING + MB_DEFBUTTON2)=IDYES Then
     Begin
          wtsCall('millenium.producao.exclui_ordem',['producao'],[CMFrame.ParamsView.FieldByName('PRODUCAO').Value],v);
          AtualizaLotes(Self);
          Application.MessageBox('Comando Executado com Sucesso',PChar(Application.Title),MB_OK);
     End;
end;

procedure TFLotes.AlteraGrade1Click(Sender: TObject);
var
   Falt:TFAltera;
   Lista:TStringList;
   i:Integer;
   tipoAlteraGrade: String;
   bloqueiaCor, bloqueiaEst: Boolean;
   rFase: TwtsRecordSet;
begin
     If (GetSelCount=0) Then
          Raise Exception.Create('Selecione o Lote à ser Movimentado');

     FAlt := TFAltera.Create(Self);
     Try
        bloqueiaCor := False;
        bloqueiaEst := False;

        Lista := TStringList.Create;
        For i:=0 To (GetCount-1) do
            If IsSelected(i) Then
            begin
              Lista.AddObject('',ListLotes.Objects[i]);

              tipoAlteraGrade := 'F';
              wtsCallEx('millenium.fases.consulta',['FASE'],[TLoteInfo(ListLotes.Objects[i]).Fase],rFase);
              try
                rFase.First;

                if not rFase.EOF then
                begin
                  tipoAlteraGrade := VarToStr(rFase.FieldValuesByName['ALTERA_GRADE']);

                  if tipoAlteraGrade = 'F' then
                    Raise Exception.Create('Não é permitido alterar a grade da fase ' +
                          VarToStr(rFase.FieldValuesByName['DESCRICAO']) +
                           '. Verifique as configurações no cadastro da fase.');

                  if not bloqueiaCor then
                    bloqueiaCor := (tipoAlteraGrade = 'E'); //Somente Estampa

                  if not bloqueiaEst then
                    bloqueiaEst := (tipoAlteraGrade = 'C'); //Somente Cor
                end;
              finally
                FreeAndNil(rFase);
              end;

            end;

        if bloqueiaCor and bloqueiaEst then
        begin
          Raise Exception.Create('Não é permitido alterar a grade, pois as fases selecionadas possuem ' +
                                 'configurações no campo "Altera Grade" divergentes.' +
                                 ' Verifique o cadastro das fases.');
        end
        else if bloqueiaCor then
          FAlt.TipoAlteraGrade := 'E'
        else if bloqueiaEst then
          FAlt.TipoAlteraGrade := 'C';

        If FAlt.ExGrade(Lista) Then
           AtualizaLotes(Self);
     Finally
        FAlt.Free;
     End;
end;

procedure TFLotes.txtOrdem222KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     If key=vk_delete Then
        TDBLookupComboBox(Sender).KeyValue := null;
     AtualizaLotes(Sender);
end;

procedure TFLotes.AlteraOficina1Click(Sender: TObject);
var
   Falt:TFAltera;
   Lista:TStringList;
   i:Integer;
begin
     If (GetSelCount = 0) Then
          Raise Exception.Create('Selecione o Lote à ser Movimentado');

     FAlt := TFAltera.Create(Self);
     Try

        Lista := TStringList.Create;
        For i:=0 To (GetCount-1) do
            If IsSelected(i) Then
               Lista.AddObject('',ListLotes.Objects[i]);

        If FAlt.ExOficina(Lista) Then
           AtualizaLotes(Self);
     Finally
        FAlt.Free;
     End;
end;

procedure TFLotes.sditCell(Sender: TObject; Col, Row: Integer;
  var CanEdit: Boolean);
begin
     CanEdit := (pgPacks.Cells[l_ordem,Row]<>'') and ((Col>l_tamanho) or ((Col=l_selecionado) and not FastMove));
     FastMove := not (Col=l_selecionado);
end;

procedure TFLotes.pgPacksGetDrawStyle(Sender: TObject; Col, Row: Integer;
  var Style: TDrawStyle);
begin
     If Col>l_tamanho THen
        Style := dsInteger;
     if Col=l_canal_venda then
        Style := dsNone;
end;

procedure TFLotes.LinkList1Links3Click(Sender: TObject);
begin
     GoBack;
end;

procedure TFLotes.pgPacksSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: String);
begin
     If ACol<>l_selecionado Then
     Begin
          SetLinks(False);
          pgPacks.Cells[l_selecionado,ARow] := '1';
          FastMove := True;
     End;
     AtualizaPecasSelecionadas;
end;

procedure TFLotes.pgPacksGetEditStyle(Sender: TObject; Col, Row: Integer;
  var Style: TEditStyle; var ReadOnly: Boolean);
begin
     If Col=l_selecionado Then Style := esCheck;
end;

function TFLotes.GetSelCount: Integer;
var x:Integer;
begin
     Result := 0;
     For x:=1 To Pred(pgPacks.RowCount) do
         If (pgPacks.Cells[l_selecionado,x]<>'0') and
            (pgPacks.Cells[l_ordem,x]<>'') Then
            Inc(Result);
end;

function TFLotes.GetSelected: Integer;
var x:Integer;
begin
     Result := 0;
     For x:=1 To Pred(pgPacks.RowCount) do
         If (pgPacks.Cells[l_selecionado,x]<>'0') and
            (pgPacks.Cells[l_ordem,x]<>'') Then
         Begin
              Result := Pred(x);
              Break;
         End;
end;

function TFLotes.GetCount: Integer;
begin
     If pgPacks.Cells[l_ordem,1]<>'' Then
        Result := Pred(pgPacks.RowCount)
     Else
         Result := 0;
end;

function TFLotes.IsSelected(Index: Integer): Boolean;
begin
     Result := (pgPacks.Cells[l_selecionado,Succ(Index)]<>'0') and
               (pgPacks.Cells[l_ordem,Succ(Index)]<>'');
end;

procedure TFLotes.SetLinks(Value: Boolean);
begin
     If LinkList1.Links[0].Visible<>Value Then
     Begin
          if Value then
          begin
               LinkList1.Links[0].Visible := Window.HasAccess('PROD_48')=atGrant;
               LinkList1.Links[1].Visible := Window.HasAccess('PROD_49')=atGrant;
               LinkList1.Links[2].Visible := Window.HasAccess('PROD_50')=atGrant;
               LinkList1.Links[3].Visible := Window.HasAccess('PROD_51')=atGrant;
               LinkList1.Links[4].Visible := not Value;
          end else
          begin
              LinkList1.Links[0].Visible := Value;
              LinkList1.Links[1].Visible := Value;
              LinkList1.Links[2].Visible := Value;
              LinkList1.Links[3].Visible := Value;
              LinkList1.Links[4].Visible := not Value;
          end;
     End;
end;

procedure TFLotes.GetQtdes(Line: Integer; out qt, df, pd: Integer);
begin
     qt := StrToIntDef(pgPacks.Cells[l_quantidade,Succ(Line)],0);
     pd := StrToIntDef(pgPacks.Cells[l_perdas,Succ(Line)],0);
     df := StrToIntDef(pgPacks.Cells[l_defeitos,Succ(Line)],0);
end;

procedure TFLotes.AnteriorTitClick(Sender: TObject);
begin
  If pgPacks.Row>1 Then
     pgPacks.Row := Pred(pgPacks.Row);
end;

procedure TFLotes.ProximoTitClick(Sender: TObject);
begin
  If pgPacks.Row<Pred(pgPacks.RowCount) Then
     pgPacks.Row := Succ(pgPacks.Row);
end;

procedure TFLotes.InverteTodosTitClick(Sender: TObject);
var x:Integer;
begin
     For x:=1 To Pred(pgPacks.RowCount) do
         If (pgPacks.Cells[l_selecionado,x]='0') Then
            pgPacks.Cells[l_selecionado,x] := '1'
         Else
            pgPacks.Cells[l_selecionado,x] := '0';
end;

procedure TFLotes.btdesmarcaClick(Sender: TObject);
var x:Integer;
begin
     For x:=1 To Pred(pgPacks.RowCount) do
         pgPacks.Cells[l_selecionado,x] := '0';
end;

procedure TFLotes.btmarcaClick(Sender: TObject);
var x:Integer;
begin
     For x:=1 To Pred(pgPacks.RowCount) do
         pgPacks.Cells[l_selecionado,x] := '1';
end;

procedure TFLotes.VerificaFase(li:TLoteInfo);
begin
    if not ( Window.HasAccess(PChar('123.'+IntToStr(li.Ciclo)+'.'+IntToStr(li.Fase))) = DOM.atGrant ) then
    begin
        ShowMessage('Sem Permissões para Andamento nesta fase');
        Abort;
    end;
end;

procedure TFLotes.VerificaFaseFinal(Lista: TStringList);
var
  x : Integer;

    procedure VerificaFinal(li:TLoteInfo);
    begin
        if not wtsFases.Active then
           wtsFases.Open; 
        wtsFases.First;
        while not wtsFases.Eof do
        begin
            if li.Fase = wtsFases.FieldByName('FASE').AsInteger then // fase
            begin
                if not wtsFases.FieldByName('FASE_FINAL').AsBoolean then // fase final
                begin
                    ShowMessage('Não existem Produtos na Fase Final para Liberação.');
                    Abort;
                end else Break;
            end;
            wtsFases.Next;
        end;
    end;


begin
    for x := 0 to Lista.Count - 1 do
       VerificaFinal(TLoteInfo(Lista.Objects[x]));
end;

procedure TFLotes.VerificaFases(Lista: TStringList);
var
  x : Integer;
begin
    for x := 0 to Lista.Count - 1 do
       VerificaFase(TLoteInfo(Lista.Objects[x]));
end;

procedure TFLotes.CMFrameDataChanged(Sender: TObject;
  Field: TField);
begin
     if Field<>nil then
        AtualizaLotes(nil);
end;

procedure TFLotes.AtualizaColWidth;
var
  c,r:integer;
begin
     for c:=0 to pgPacks.ColCount-1 do
     begin
          for r := 0 to pgPacks.RowCount-1 do
          begin
               if pgPacks.ColWidths[c]<Canvas.TextWidth(pgPacks.Cells[c,r])+20 then
                  pgPacks.ColWidths[c] := Canvas.TextWidth(pgPacks.Cells[c,r])+20;
          end;
     end;
end;

procedure TFLotes.CarregaDadosPedido;
var
  Prods:TStringList;
  idx:integer;
  rPedidos:TwtsRecordSet;
begin
     Prods := TStringList.Create;
     try
        Prods.Sorted := True;
        wtsLotes.First;
        while not wtsLotes.eof do
        begin
             if not Prods.Find(wtsLotes.FieldByName('N_ORDEM').AsString, idx) then
                Prods.Add(wtsLotes.FieldByName('N_ORDEM').AsString);
             wtsLotes.Next;
        end;
        wtsLotes.First;

        if Prods.Count=0 then Exit;

        wtsCallEx('millenium.producao.Lista_Pedidos',['N_ORDEMS'],['('+ListToStrVirgula(Prods)+')'], rPedidos);
        try
          fInternalChanged := True;
          if rPedidos.RecordCount=1 then
          begin
               if VarToStr(rPedidos.FieldValuesByName['DATA_ENTREGA'])<>'' then
                  CMFrame.ParamsView.FieldByName('DATA_ENTREGA').Value       := rPedidos.FieldValuesByName['DATA_ENTREGA']
               else
                   CMFrame.ParamsView.FieldByName('DATA_ENTREGA').Value := null;
               if VarToStr(rPedidos.FieldValuesByName['DATA_ENTREGA_FINAL'])<>'' then
                  CMFrame.ParamsView.FieldByName('DATA_ENTREGA_FINAL').Value := rPedidos.FieldValuesByName['DATA_ENTREGA_FINAL']
               else
                   CMFrame.ParamsView.FieldByName('DATA_ENTREGA_FINAL').Value := null;
          end;
        finally
              FreeAndNil(rPedidos);
              fInternalChanged := False;
        end;

     finally
         Prods.Free;
     end;
end;

procedure TFLotes.CMFrameGetFieldInfo(Sender: TObject;
  var FieldInfo: TFieldInfo);
begin
     if FieldInfo.Name = 'SOMENTE_PRODUCAO' then
     Begin
          try
             fInternalChanged := True;
             CMFrame.ParamsView.FieldByName('SOMENTE_PRODUCAO').Value := True;
          finally
               fInternalChanged := False;
          end;
     end;
end;

procedure TFLotes.LinkList1Links5Click(Sender: TObject);
var
  FDistribuicaoCanalVenda: TFDistribuicaoCanalVenda;
begin
  if (GetSelected<>0)  then
    Raise Exception.Create('Operação não suportada com lote selecionado');

  FDistribuicaoCanalVenda := TFDistribuicaoCanalVenda.Create(FProducao);
  try
    if FDistribuicaoCanalVenda.ShowModal = mrOk then
      AtualizaLotes(Sender)
  finally
    FDistribuicaoCanalVenda.Free;
  end;
end;

procedure TFLotes.LinkList1Links6Click(Sender: TObject);
var
  FAlterarCanalVenda: TFAlterarCanalVenda;

  I: Integer;
begin
  if GetCount=0  then
    Raise Exception.Create('Selecione a Ordem de Produção.');

  FAlterarCanalVenda := TFAlterarCanalVenda.Create(Self);
  try
    for I := 0 to (GetCount-1) do
      if IsSelected(i) Then
      begin
        if TLoteInfo(ListLotes.Objects[i]).canal_venda = '' then
          raise Exception.Create('Todos os itens selecionados devem estar com canal de venda preenchidos');
        FAlterarCanalVenda.Situacoes.Add(IntToStr(TLoteInfo(ListLotes.Objects[i]).Situacao));
      end;

    if FAlterarCanalVenda.Situacoes.Count > 0 then
    begin
      if FAlterarCanalVenda.ShowModal = mrOk then
        AtualizaLotes(Sender);
    end else
      Raise Exception.Create('Selecione pelo menos uma fase.');

  finally
    FAlterarCanalVenda.Free;
  end;
end;

procedure TFLotes.LinkList1Links7Click(Sender: TObject);
var
  l: TStringList;
  li: TLoteInfo;
  i: Integer;
  m : TwtsMethodView;
  r:TwtsRecordset;
  DoIt,CanQtde,ajusta: Boolean;
  vl: TStringList;
  fMInput : TfrmMethodInput;
  c,q: Extended;
  v  : Variant;
  iTipoPagto: Integer;
  custoZeroNoEnvio : Boolean;

  Function QtdRet(var GOk:Boolean):Extended;
  var x:Integer;
      lt:TLoteInfo;
  begin
    GOk := True;
    li := TLoteInfo(l.Objects[0]);
    Result := 0;
    For x:=0 To Pred(l.Count) do
    Begin
         lt := TLoteInfo(l.Objects[x]);
         If GOk Then
            GOk := (li.produto = lt.produto)
                and (li.estampa = lt.estampa)
                and (li.cor = lt.cor)
                and (li.tamanho = lt.tamanho);
         Result := Result + lt.Quantidade;
    End;
  End;

begin
  l := TStringList.Create;

  For i:=0 To (GetCount-1) do
    If IsSelected(i) Then
      l.AddObject('',ListLotes.Objects[i]);

  if l.Count=0  then
    Raise Exception.Create('Selecione a pacote.');

  m := TwtsMethodView.Create(nil);
  m.Transaction := 'millenium.producao.retornooficina';

  r := TwtsRecordset.CreateFromStream(TMemoryStream.Create);
  r.Transaction := 'millenium.producao.grade';

  iTipoPagto:= Config.ReadParamInt('TIPO_PAGTO_OFICINA',0);

  wtsCall('millenium.producao.Custo_oficina',['producao'],[TLoteInfo(l.Objects[0]).Ordem],v);
  If not VarIsNull(v[0]) and not VarIsEmpty(v[0]) Then
    c := v[0]
  Else
    c := 0;

  custoZeroNoEnvio := False;
  if VarIsValid(v[0]) then
  begin
    custoZeroNoEnvio := VarToFloat(v[0]) = 0;
  end;

  doIt := True;
  If SysParam('ANDAEMGRADE').AsBoolean Then
  Begin
    doIt := TFSQAnda.Execute(l, True);
    q := QtdRet(CanQtde);
    CanQtde := False;
  End Else
  begin
    q := QtdRet(CanQtde); { Verifica se os lotes são iguais }
    CanQtde := (l.Count=1); // Pendência 26033 25-ago-2010 Douglas Rissi
  end;

  If doIt Then
  Begin
    if VarIsNull(TLoteInfo(l.Objects[0]).iOficina) and VarIsEmpty(TLoteInfo(l.Objects[0]).iOficina) then //Pendência nº 7586
      Raise Exception.Create('Este pacote não está em oficina para ser retornado');

    vl:= TStringList.Create;
    vl.Add('N_ORDEM');
    If not CanQtde Then
      vl.Add('QUANTIDADE');

    fMInput := TfrmMethodInput.Create(nil);

    Try
      // fMInput.DataChanged:= mfDataChanged; {Não pode ser tirado se precisar criar um parametro}
      fMInput.NotVisList := vl;
      fMInput.Method     := m;

      fMInput.Param['N_ORDEM'].Value      := TLoteInfo(l.Objects[0]).n_ordem;// txtOrdem.KeyValue;
      fMInput.Param['OFICINA'].AsInteger  := TLoteInfo(l.Objects[0]).iOficina;
      fMInput.Param['CUSTO'].AsCurrency   := c;
      fMInput.Param['QUANTIDADE'].AsFloat := q;
      //CalcDataVen(fMInput.Param['DATA'].AsDateTime,Venc);
      //fMInput.Param['VENCTO'].AsDateTime  := Venc;
      fMInput.Param['TIPO_PGTO'].AsInteger:= iTipoPagto;
      fMInput.Param['PRODUCAO'].AsInteger := TLoteInfo(l.Objects[0]).Ordem;
      fMInput.Param['NALTERA_DATA'].AsBoolean := not PermiteAlterarData;

      if (VarToFloat(c) = 0) then
      begin
        fMinput.CMFrame.ParamsView.FieldValues['CUSTO'] := null;
      end;

      if custoZeroNoEnvio then
        fMinput.CMFrame.ParamsView.FieldValues['CUSTO'] := '0';

      // Invoca método de RetornoOficina ( "Producao.RetornoOficina" )
      if (fMInput.ShowModal=mrOk) then
      begin
        fMInput.Post;
        If CanQtde Then
          q := fMInput.Param['QUANTIDADE'].AsFloat;

          For i:=0 To Pred(l.Count) do
          Begin
            li:= TLoteInfo(l.Objects[i]);
            li.Custo:= fMInput.Param['CUSTO'].AsCurrency;
            If q > 0 Then
            Begin
              r.DirtyNew;
              ajusta := true;
              r.FieldValues[0] := li.Situacao;
              // >> O Código abaixo NÃO deve ser mexido
              // ele deve levar em consideração que só
              // pode ligar o ajusta se o usuario pode mexer
              // na quantidade e se mexeu para aumentá-la
              If CanQtde Then
              Begin
                If li.Quantidade>q Then
                //Pendência 5817 M3 - Início
                begin
                  li.Quantidade := q;
                  ajusta := false;
                end else
                If i=Pred(l.Count) Then
                  li.quantidade := q;
                //Pendência 5817 M3 - Fim
                q := q - li.Quantidade;
              End Else
                Ajusta := False;
              r.FieldValues[1] := li.Quantidade;
              r.FieldValues[2] := fMInput.Param['CUSTO'].AsCurrency;
              r.FieldValues[3] := ajusta;
              r.Add;
            End Else
             li.Quantidade := 0;
          End;

          m.ParamsByName['RETORNO'] := r.Data;
          try
            m.Refresh;
          except
            AtualizaLotes(Self);
            raise;
          end;

          TIOficina.Execute(fMInput.Param['OFICINA'].AsInteger, TLoteInfo(l.Objects[0]).Fase,
            TLoteInfo(l.Objects[0]).Parte, fMInput.Param['DATA'].AsDateTime, fMInput.Param['VENCTO'].AsDateTime, l, True);

          AndamentoLote(Self);
      end;

    Finally
      fMInput.Free;
      vl.Free;
      l.Free;
      r.Free;
      m.Free;
    End;
  End;
end;

function TFLotes.HasAccess(Id,Value: String): Boolean;
   function CalcCrc(const v:String):LongWord;
   var x:Integer;
   begin
        InitC32(Result);
        for x:=1 to Length(v) do
            Result := UpdC32(Byte(UpCase(v[x])),Result);
   end;
begin
     If Value<>'' Then
        Value := Id+'.'+IntToStr(CalcCrc('{'+Value+'}'))
     Else Value := Id;
     Result := Window.HasAccess(PChar(Value))=DOM.atGrant;
end;

function TFLotes.PermiteAlterarData: Boolean;
begin
     Result := HasAccess( 'PROD_52','')
end;

procedure TFLotes.FormShow(Sender: TObject);
begin
  AtualizaLotes(nil);
end;

initialization
 RegisterDocClass(TFLotes);

end.


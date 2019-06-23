unit AlterarCanalVenda;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  LinkList, wtsPainter, dmPanel, wtsMethodFrame, Db, wtsMethodView, wtsStream;

type
  TFAlterarCanalVenda = class(TForm)
    LinkList1: TLinkList;
    wtsMethodView1: TwtsMethodView;
    wtsMethodFrame1: TwtsMethodFrame;
    procedure FormActivate(Sender: TObject);
    procedure LinkList1Links0Click(Sender: TObject);
    procedure LinkList1Links1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FSituacoes: TStringList;
  public
    { Public declarations }
    property Situacoes: TStringList read FSituacoes;
  end;

var
  FAlterarCanalVenda: TFAlterarCanalVenda;

implementation

{$R *.DFM}

procedure TFAlterarCanalVenda.FormActivate(Sender: TObject);
var
  R: TwtsRecordset;
  I: Integer;
begin
  R := TwtsRecordset.CreateFromStreamEx(TMemoryStream.Create,rdInput);
  R.Transaction := 'WTSSYSTEM.INTERNALTYPES.INTEGERARRAY';
  for I := 0 to FSituacoes.Count-1 do
  begin
    R.New;
    R.FieldValuesByName['ITEM'] := FSituacoes[I];
    R.Add;
  end;

  wtsMethodFrame1.Active := True;
  wtsMethodFrame1.Edit;
  wtsMethodFrame1.ParamsView.FieldByName('ITEMS').AsString := R.Data;

end;

procedure TFAlterarCanalVenda.LinkList1Links0Click(Sender: TObject);
begin
  if Application.MessageBox('Confirma alteração do canal de vendas nos pacotes?', 'Aviso', MB_ICONWARNING or MB_YESNO or MB_DEFBUTTON2) = idYes then
  begin
    wtsMethodFrame1.Post;
    wtsMethodFrame1.Edit;
    wtsMethodView1.Refresh;
    ModalResult := mrOk;
    ShowMessage('Comando executado com sucesso');
  end else
    ModalResult := mrCancel;
end;

procedure TFAlterarCanalVenda.LinkList1Links1Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFAlterarCanalVenda.FormCreate(Sender: TObject);
begin
  FSituacoes := TStringList.Create;
end;

procedure TFAlterarCanalVenda.FormDestroy(Sender: TObject);
begin
  FSituacoes.Free;
end;

end.

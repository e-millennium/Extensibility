unit uFrmFaturamentos;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, DMBase,
  wtsPainter, dmPanel, LinkList, wtsStream, wtsClient, StatusPanel, Db,
  wtsMethodView;

type
  TFFaturamentoOS = class(TDMBase)
    dmPanel1: TdmPanel;
    dmPanel2: TdmPanel;
    LinkList: TLinkList;
    MVListaEventos: TwtsMethodView;
    procedure MVListaEventosRefreshDone(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    FFaturados: Integer;
    FOrdemServico: Integer;
    FStatusPanel: TStatusPanel;
    procedure OnLinkClick(Sender: TObject);
  protected
    function DoCommand:Integer;override;
    procedure Faturar(ABlank:Boolean;AEvento: Integer);
  end;

var
  FFaturamentoOS: TFFaturamentoOS;

implementation

{$R *.DFM}


procedure TFFaturamentoOS.Faturar(ABlank:Boolean;AEvento: Integer);
var
  S:string;
begin
  Inc(FFaturados);
  S := '';
  if ABlank then
    S := '_blank,';
  Navigate(S+'Eventos.TExecutaEvento&EVENT="'+IntToStr(AEvento)+'",ID_DOCFATGENERICO='+IntToStr(FOrdemServico));
  if (FFaturados = LinkList.Links.Count) then
    Window.Close;
end;

procedure TFFaturamentoOS.OnLinkClick(Sender: TObject);
begin
  Faturar(True,StrToInt(TLink(Sender).LinkID));
  TLink(Sender).Caption := TLink(Sender).Caption + '(OK)';
end;

function TFFaturamentoOS.DoCommand: Integer;
var
  X: Integer;
begin
  FFaturados := 0;
  FStatusPanel :=  TStatusPanel.Create(Self);
  try
    for X := 0 to CommandParser.Count - 1 do
    begin
      if CommandParser.Items[X].Tag = 'ID_DOCFATGENERICO' then
        FOrdemServico := StrToInt(CommandParser.Items[X].CommandOf('ID_DOCFATGENERICO'));
    end;
    Result := inherited DoCommand;
  except
    FStatusPanel.Free;
    Window.Close;
  end;
end;

procedure TFFaturamentoOS.MVListaEventosRefreshDone(Sender: TObject);
begin
  try
    if MVListaEventos.RecordCount > 0 then
    begin
      if MVListaEventos.RecordCount = 1 then
      begin
        Faturar(False,MVListaEventos.FieldValues['EVENTO'])
      end else
      begin
        while not MVListaEventos.Eof do
        begin
          with LinkList.Links.Add do
          begin
            Caption := '('+VarToStr(MVListaEventos.FieldValues['CODIGO'])+') '+ VarToStr(MVListaEventos.FieldValues['DESCRICAO']);
            LinkID := MVListaEventos.FieldValues['EVENTO'];
            OnClick := OnLinkClick;
          end;
          MVListaEventos.Next;
        end;
      end;
    end else
    begin
      try
        if MVListaEventos.HasLastError then
          raise Exception.Create(MVListaEventos.LastErrorMsg);
      finally
        Window.Close;
      end;  
    end;

  finally
    FStatusPanel.Free;
  end;
end;

procedure TFFaturamentoOS.FormActivate(Sender: TObject);
begin
  MVListaEventos.Close;
  MVListaEventos.CallMode := cmAsync;
  MVListaEventos.ShowErrors := True;
  MVListaEventos.ParamsByName['ORDEM_SERVICO'] := FOrdemServico;
  MVListaEventos.Refresh;
end;

initialization
  RegisterDocClass(TFFaturamentoOS);

end.

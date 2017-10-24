unit QRRelInspecaoQualidade;

interface

uses Windows, SysUtils, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Quickrpt, QRCtrls, Db, wtsMethodView, jpeg,
  QRBaseModule;

type
  TfrmQRFrequenciaInspecao = class(TfrmQRBaseModule)
    QRBand5: TQRBand;
    QRLabel1: TQRLabel;
    QRSysData5: TQRSysData;
    QRLabel4: TQRLabel;
    QRLabel5: TQRLabel;
    QRLabel6: TQRLabel;
    QRLabel7: TQRLabel;
    QRDBText7: TQRDBText;
    QRLabel10: TQRLabel;
    QRDBText8: TQRDBText;
    QRImage1: TQRImage;
    QRGroup1: TQRGroup;
    QRDBText1: TQRDBText;
    QRLabel2: TQRLabel;
    QRSubDetail1: TQRBand;
    QRShape15: TQRShape;
    QRShape14: TQRShape;
    QRShape13: TQRShape;
    QRShape12: TQRShape;
    QRShape10: TQRShape;
    QRDBText2: TQRDBText;
    QRDBText3: TQRDBText;
    QRDBText4: TQRDBText;
    QRDBText5: TQRDBText;
    QRDBText6: TQRDBText;
    QRShape1: TQRShape;
    QRShape2: TQRShape;
    QRShape3: TQRShape;
    QRShape4: TQRShape;
    QRShape5: TQRShape;
    QRShape6: TQRShape;
    QRShape7: TQRShape;
    QRShape8: TQRShape;
    QRShape9: TQRShape;
    QRBand3: TQRBand;
    QRShape11: TQRShape;
    QRShape16: TQRShape;
    QRShape17: TQRShape;
    QRShape18: TQRShape;
    QRShape19: TQRShape;
    QRShape20: TQRShape;
    QRShape21: TQRShape;
    QRShape22: TQRShape;
    QRShape23: TQRShape;
    QRShape24: TQRShape;
    QRShape25: TQRShape;
    QRShape26: TQRShape;
    QRShape27: TQRShape;
    QRShape28: TQRShape;
    QRShape29: TQRShape;
    QRShape30: TQRShape;
    QRShape31: TQRShape;
    QRShape32: TQRShape;
    QRLabel8: TQRLabel;
    QRLabel9: TQRLabel;
    wtsMethodView1: TwtsMethodView;
    wtsMethodView1SEQUENCIA: TIntegerField;
    wtsMethodView1FREQ_INSPECAO: TStringField;
    wtsMethodView1FREQ_ANOTACAO: TStringField;
    wtsMethodView1TECNICA_MEDICAO: TStringField;
    wtsMethodView1DIMENSAO: TStringField;
    wtsMethodView1ESPECIFICACAO: TStringField;
    wtsMethodView1COD_PRODUTO: TStringField;
    wtsMethodView1DESC_PRODUTO: TStringField;
    procedure QuickRepBeforePrint(Sender: TCustomQuickRep;
      var PrintReport: Boolean);
  private

  public
    Inicializou: Boolean;

  end;

var
  frmQRFrequenciaInspecao: TfrmQRFrequenciaInspecao;

implementation

{$R *.DFM}

procedure TfrmQRFrequenciaInspecao.QuickRepBeforePrint(Sender: TCustomQuickRep;
  var PrintReport: Boolean);
begin
  inherited;
    PageHeaderBand1.Enabled := False;
    PageHeaderBandChild1.Enabled := False;
    QRShapeAncestral2.Enabled := False;
     if Inicializou then Exit;
     Inicializou := True;

     If wtsInputMethod(wtsMethodView1) Then
     begin
         wtsMethodView1.Refresh;

     End;
end;

initialization
  RegisterReport(999,TfrmQRFrequenciaInspecao);

end.

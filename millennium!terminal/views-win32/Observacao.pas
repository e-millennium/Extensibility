unit Observacao;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, OleCtrls, SHDocVw,utf8,MSHTML,ComObj, ActiveX,
  PngImage, ProEffectImage;

type
  TFSaibaMais = class(TForm)
    WebBrowser1: TWebBrowser;
    Panel1: TPanel;
    lblURLAppImg: TProEffectImage;
    procedure FormShow(Sender: TObject);
    procedure lblURLAppImgClick(Sender: TObject);
    procedure WebBrowser1DocumentComplete(Sender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
  private
    FObs: string;
    procedure Navigate(ABody: string);
  public
    { Public declarations }
    property Obs: string read FObs write FObs;
  end;

var
  FSaibaMais: TFSaibaMais;

implementation

{$R *.DFM}

procedure TFSaibaMais.Navigate(ABody: string);
var
  ms: TMemoryStream;
  SL: TStringList;
begin
  WebBrowser1.Navigate('about:blank');
  if Assigned(WebBrowser1.Document) then
  begin
    SL := TStringList.Create;
    SL.Add('<html>');
    SL.Add('  <head>');
    SL.Add('    <title>Saiba mais</title>');
    SL.Add('    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">');
    SL.Add('  </head>');
    SL.Add('  <body>');
    SL.Add(UTF8Encode(ABody));
    SL.Add('  </body>');
    SL.Add('</html>');

    WebBrowser1.Document._AddRef;
    ms := TMemoryStream.Create;
    try
      SL.SaveToStream(ms);
      ms.Seek(0, 0);
      (WebBrowser1.Document as IPersistStreamInit).Load(TStreamAdapter.Create(ms)) ;
    finally
      ms.Free;
      SL.Free;
    end;
  end;
end;

procedure TFSaibaMais.FormShow(Sender: TObject);
begin
  Navigate(Obs);
end;

procedure TFSaibaMais.lblURLAppImgClick(Sender: TObject);
begin
  Close;
end;

procedure TFSaibaMais.WebBrowser1DocumentComplete(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
  Doc : IHTMLDocument2;
  Element : IHTMLElement;
begin
  Doc := IHTMLDocument2(TWebBrowser(Sender).Document);
  if Doc = nil then
    Exit;
  Element := Doc.body;
  if Element = nil then
    Exit;
  Element.style.borderStyle := 'none';
end;

end.

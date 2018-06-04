unit Background;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls;

  procedure DrawBackground(DC: HDC; const ARect: TRect);

implementation

var
  GBackground: TBitMap;

function ResizeBmp(bitmp: TBitmap; wid, hei: Integer): Boolean;
var
  TmpBmp: TBitmap;
  ARect: TRect;          
begin
  try
    TmpBmp := TBitmap.Create;
    try
      TmpBmp.Width  := wid;
      TmpBmp.Height := hei;
      ARect := Rect(0,0, wid, hei);
      TmpBmp.Canvas.StretchDraw(ARect, Bitmp);
      bitmp.Assign(TmpBmp);
    finally
      TmpBmp.Free;
    end;
    Result := True;
  except
    Result := False;
  end;
end;  

procedure DrawBackground(DC: HDC; const ARect: TRect);
var
  C:TCanvas;
  Bitmap: TBitmap;
begin
  C := TCanvas.Create;
  try
    C.Handle := DC;
    Bitmap := TBitmap.Create;
    Bitmap.Height := ARect.Bottom-ARect.Top;
    Bitmap.Width := ARect.Right-ARect.Left;
    try
      BitBlt(Bitmap.Canvas.Handle,0,0,ARect.Right,ARect.Bottom,GBackground.Canvas.Handle,ARect.Left,ARect.Top,SRCCOPY);
      C.Draw(0,0,Bitmap);
    finally
      Bitmap.Free;
    end;
  finally
    C.Handle := 0;
    C.Free;
  end;
end;

initialization
  GBackground := TBitmap.Create;
  GBackground.HandleType := bmDIB;
  GBackground.LoadFromFile('c:\millenium\bkg.bmp');
  ResizeBmp(GBackground,Screen.Width,Screen.Height)

end.

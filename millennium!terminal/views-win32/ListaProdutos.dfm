object FListaProdutos: TFListaProdutos
  Left = 282
  Top = 125
  BorderStyle = bsNone
  Caption = 'FListaProdutos'
  ClientHeight = 441
  ClientWidth = 401
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid1: TStringGrid
    Left = 0
    Top = 0
    Width = 401
    Height = 441
    Align = alClient
    BorderStyle = bsNone
    ColCount = 1
    DefaultColWidth = 400
    DefaultRowHeight = 35
    FixedCols = 0
    FixedRows = 0
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
    OnKeyPress = StringGrid1KeyPress
  end
end

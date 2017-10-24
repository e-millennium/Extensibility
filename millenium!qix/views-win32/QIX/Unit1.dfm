object Form1: TForm1
  Left = 192
  Top = 125
  Width = 942
  Height = 491
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 16
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object wtsMethodView1: TwtsMethodView
    ObjectView = False
    Transaction = 'MILLENIUM!QIX.PLANEJAMENTOS_ESTOQUES.LISTARTENSPLANEJAMENTO'
    Left = 72
    Top = 88
  end
end

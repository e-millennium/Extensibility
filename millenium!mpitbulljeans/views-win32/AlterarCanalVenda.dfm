object FAlterarCanalVenda: TFAlterarCanalVenda
  Left = 192
  Top = 125
  BorderStyle = bsDialog
  Caption = 'Alterar Canal de Vendas'
  ClientHeight = 132
  ClientWidth = 442
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object LinkList1: TLinkList
    Left = 0
    Top = 101
    Width = 442
    Height = 31
    ParentFont = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    Links = <
      item
        Down = False
        Caption = 'OK'
        ShortCut = 0
        OnClick = LinkList1Links0Click
      end
      item
        Down = False
        Caption = 'Cancelar'
        ShortCut = 0
        OnClick = LinkList1Links1Click
      end>
    LinksHeight = 24
    LinksSpacing = 3
    LinksMargin = 2
    ShortCutPos = scpLeft
    ShowtCutColor = clRed
    List = False
    ListSmall = False
    AutoSize = False
    Margin = 2
    TabOrder = 0
    Align = alBottom
  end
  object wtsMethodFrame1: TwtsMethodFrame
    Left = 0
    Top = 0
    Width = 442
    Height = 101
    Style = psTransparent
    Align = alClient
    Caption = 'wtsMethodFrame1'
    ShowCaption = False
    TabOrder = 1
    Compact = False
    TabStop = True
    MethodView = wtsMethodView1
    ViewType = vtParams
    Active = True
    RegKey = 'SOFTWARE\WINDOOR\METHODFRAME'
    CreateUserInterface = True
    Transparent = False
    LabelWidthLimit = 0
    NoCustomCFG = False
  end
  object wtsMethodView1: TwtsMethodView
    ObjectView = False
    Transaction = 'MILLENIUM!MPITBULLJEANS.PRODUCAO.ALTERARCANALVENDA'
    Left = 176
    Top = 32
  end
end

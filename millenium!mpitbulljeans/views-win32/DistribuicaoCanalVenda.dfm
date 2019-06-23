object FDistribuicaoCanalVenda: TFDistribuicaoCanalVenda
  Left = 310
  Top = 125
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSingle
  Caption = 'Distribuição '
  ClientHeight = 449
  ClientWidth = 829
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object LinkList1: TLinkList
    Left = 0
    Top = 418
    Width = 829
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 829
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 1
    object Label2: TLabel
      Left = 8
      Top = 2
      Width = 75
      Height = 26
      Caption = 'Produto'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblProduto: TLabel
      Left = 85
      Top = 3
      Width = 55
      Height = 25
      Caption = 'Label3'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 32
    Width = 202
    Height = 386
    Align = alLeft
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 2
    object TreeView1: TTreeView
      Left = 0
      Top = 0
      Width = 202
      Height = 386
      Align = alClient
      BorderStyle = bsNone
      Ctl3D = False
      Indent = 19
      ParentCtl3D = False
      TabOrder = 0
      OnChange = TreeView1Change
    end
  end
  object Panel3: TPanel
    Left = 202
    Top = 32
    Width = 627
    Height = 386
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Aguarde...'
    TabOrder = 3
    object PalGrid1: TPalGrid
      Left = 0
      Top = 31
      Width = 627
      Height = 355
      Align = alClient
      BorderStyle = bsNone
      DefaultDrawing = False
      FixedColor = 16250871
      Options = [dgeEditing, dgeHideSelection]
      ScrollBars = ssVertical
      TabOrder = 0
      KeyCol = -1
      OnGetDrawStyle = PalGrid1GetDrawStyle
      OnCanEditCell = PalGrid1CanEditCell
      OnCellExit = PalGrid1CellExit
      OnCellEnter = PalGrid1CellEnter
      OnChangeDrawing = PalGrid1ChangeDrawing
      ColWidths = (
        125
        125
        125
        125
        125)
      RowHeights = (
        22
        22
        22
        22
        22)
    end
    object pnlCanalCurx: TPanel
      Left = 0
      Top = 0
      Width = 627
      Height = 31
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      object lblSaldo: TLabel
        Left = 0
        Top = 13
        Width = 627
        Height = 13
        Align = alTop
        Caption = 'lblSaldo'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCanalCur: TLabel
        Left = 0
        Top = 0
        Width = 627
        Height = 13
        Align = alTop
        Caption = 'lblCanalCur'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
    end
  end
  object ListaCanalVenda: TwtsMethodView
    OnRefreshDone = ListaCanalVendaRefreshDone
    ObjectView = False
    Transaction = 'MILLENIUM!MPITBULLJEANS.CANAIS_VENDA.LISTAR'
    Left = 64
    Top = 209
  end
end

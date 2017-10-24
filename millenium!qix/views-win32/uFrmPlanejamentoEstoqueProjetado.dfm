object FPlanejamentoEstoque: TFPlanejamentoEstoque
  Left = 392
  Top = 131
  Width = 845
  Height = 482
  Caption = 'Planejamento Estoque Projetado'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object dmPanel1: TdmPanel
    Left = 0
    Top = 0
    Width = 829
    Height = 412
    Style = psBackground
    Align = alClient
    Caption = 'dmPanel1'
    ShowCaption = False
    TabOrder = 0
    object dmPanel2: TdmPanel
      Left = 0
      Top = 0
      Width = 829
      Height = 412
      Style = psHeader
      Align = alClient
      Caption = 'Planejamento Estoque Projetado'
      ShowCaption = True
      TabOrder = 0
      object PalGrid1: TPalGrid
        Left = 0
        Top = 20
        Width = 829
        Height = 392
        Align = alClient
        DefaultDrawing = False
        Options = [dgeEditing, dgeAlwaysShowEditor]
        TabOrder = 0
        OnSelectCell = PalGrid1SelectCell
        KeyCol = -1
        OnGetEditStyle = PalGrid1GetEditStyle
        OnGetDrawStyle = PalGrid1GetDrawStyle
        OnCellChanged = PalGrid1CellChanged
        OnChangeDrawing = PalGrid1ChangeDrawing
      end
    end
  end
  object LinkList1: TLinkList
    Left = 0
    Top = 412
    Width = 829
    Height = 31
    Links = <
      item
        Down = False
        Caption = '(Ctrl + Enter) Salvar'
        ShortCut = 0
        OnClick = LinkList1Links0Click
      end
      item
        Down = False
        Caption = 'Reprocessar'
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
    TabOrder = 1
    Align = alBottom
  end
end

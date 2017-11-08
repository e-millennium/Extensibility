object FPlanejamentoEstoque: TFPlanejamentoEstoque
  Left = 393
  Top = 132
  Width = 845
  Height = 482
  Caption = 'Planejamento Estoque Projetado'
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
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
        object pnlLOG: TPanel
          Left = 184
          Top = 88
          Width = 417
          Height = 209
          Anchors = []
          BevelOuter = bvNone
          Caption = 'pnlLOG'
          TabOrder = 0
          Visible = False
          object MemoLog: TMemo
            Left = 0
            Top = 25
            Width = 417
            Height = 153
            Align = alClient
            BorderStyle = bsNone
            TabOrder = 0
          end
          object Panel2: TPanel
            Left = 0
            Top = 0
            Width = 417
            Height = 25
            Align = alTop
            BevelOuter = bvNone
            Caption = 'LOG'
            Color = clSilver
            TabOrder = 1
            object Memo2: TMemo
              Left = 72
              Top = 24
              Width = 217
              Height = 121
              Lines.Strings = (
                'Memo1')
              TabOrder = 0
            end
          end
          object LinkList2: TLinkList
            Left = 0
            Top = 178
            Width = 417
            Height = 31
            Links = <
              item
                Down = False
                Caption = 'OK'
                ShortCut = 0
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
            TabOrder = 2
            Align = alBottom
          end
        end
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
      end
      item
        Down = False
        Caption = 'Produção(Importar Planilha)'
        ShortCut = 0
        OnClick = LinkList1Links2Click
      end
      item
        Down = False
        Caption = 'Fechar'
        ShortCut = 0
        OnClick = LinkList1Links3Click
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
  object OpenDialog: TOpenDialog
    Filter = 'Excel|*.xlsx'
    Title = 'Excel com dados de produção'
    Left = 137
    Top = 285
  end
end

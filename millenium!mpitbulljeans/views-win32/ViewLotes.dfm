object FLotes: TFLotes
  Left = 320
  Top = 179
  Width = 777
  Height = 448
  Caption = 'Consulta Pacotes'
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 3
    Top = 2
    Width = 64
    Height = 13
    Caption = 'Quantidade:'
  end
  object Label4: TLabel
    Left = 64
    Top = 2
    Width = 30
    Height = 13
    Caption = '00000'
  end
  object dmPanel1: TdmPanel
    Left = 0
    Top = 0
    Width = 761
    Height = 378
    Style = psBackground
    Align = alClient
    Caption = 'dmPanel1'
    ShowCaption = False
    TabOrder = 0
    object dmPanel2: TdmPanel
      Left = 10
      Top = 10
      Width = 741
      Height = 127
      Style = psHeader
      Align = alTop
      Caption = 'Consulta Pacotes'
      ShowCaption = True
      TabOrder = 0
      object CMFrame: TwtsMethodFrame
        Left = 3
        Top = 23
        Width = 735
        Height = 101
        Style = psTransparent
        Align = alClient
        Caption = 'CMFrame'
        ShowCaption = False
        TabOrder = 0
        Compact = True
        TabStop = True
        MethodView = wtsMethodView1
        ViewType = vtParams
        Active = False
        RegKey = 'SOFTWARE\WINDOOR\METHODFRAME'
        CreateUserInterface = True
        Transparent = False
        OnDataChanged = CMFrameDataChanged
        OnGetFieldInfo = CMFrameGetFieldInfo
        LabelWidthLimit = 0
        NoCustomCFG = False
      end
    end
    object dmPanel3: TdmPanel
      Left = 10
      Top = 137
      Width = 741
      Height = 231
      Style = psGridBackground
      Align = alClient
      Caption = 'dmPanel3'
      ShowCaption = False
      TabOrder = 1
      object Panel5: TPanel
        Left = 2
        Top = 2
        Width = 24
        Height = 227
        Align = alLeft
        BevelOuter = bvNone
        Color = 16316664
        TabOrder = 0
        object AnteriorTit: TSpeedButton
          Left = 2
          Top = 2
          Width = 20
          Height = 19
          Hint = 'Anterior'
          Flat = True
          Glyph.Data = {
            C6000000424DC60000000000000076000000280000000A0000000A0000000100
            0400000000005000000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDD00
            0000DDDDDDDDDD000000DDDDDDDDDD000000000000000D000000D0000000DD00
            0000DD00000DDD000000DDD000DDDD000000DDDD0DDDDD000000DDDDDDDDDD00
            0000DDDDDDDDDD000000}
          ParentShowHint = False
          ShowHint = True
          OnClick = AnteriorTitClick
        end
        object ProximoTit: TSpeedButton
          Left = 2
          Top = 22
          Width = 20
          Height = 19
          Hint = 'Próximo'
          Flat = True
          Glyph.Data = {
            C6000000424DC60000000000000076000000280000000A0000000A0000000100
            0400000000005000000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDD00
            0000DDDDDDDDDD000000DDDD0DDDDD000000DDD000DDDD000000DD00000DDD00
            0000D0000000DD000000000000000D000000DDDDDDDDDD000000DDDDDDDDDD00
            0000DDDDDDDDDD000000}
          ParentShowHint = False
          ShowHint = True
          OnClick = ProximoTitClick
        end
        object InverteTodosTit: TSpeedButton
          Left = 2
          Top = 43
          Width = 20
          Height = 19
          Hint = 'Inverte Seleção'
          Flat = True
          Glyph.Data = {
            F6000000424DF600000000000000760000002800000010000000100000000100
            0400000000008000000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
            DDDDDDDDDDD0DDDDDDDDDDDDDD00DDDDDDDDDDDDD00000DDDDDDDDDD00000000
            DDDDDFDDD000DD0000DDDFDDDD00DDD0000DDFFDDDD0DDDD000DDFFFDDDDFDDD
            D00DDFFFFDDDFFDDDD0DDDFFFFDDFFFDDD0DDDDDFFFFFFFFDDDDDDDDDDFFFFFD
            DDDDDDDDDDDDFFDDDDDDDDDDDDDDFDDDDDDDDDDDDDDDDDDDDDDD}
          ParentShowHint = False
          ShowHint = True
          OnClick = InverteTodosTitClick
        end
        object btdesmarca: TSpeedButton
          Tag = 1
          Left = 2
          Top = 63
          Width = 20
          Height = 19
          Hint = 'Desmarca todos os Títulos da Seleção.'
          Flat = True
          Glyph.Data = {
            F6000000424DF600000000000000760000002800000010000000100000000100
            04000000000080000000C40E0000C40E00001000000000000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
            DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD88888DDDDDDDDDDD8FFF8DDDDD
            DDDDDD8FFF8D8D8D8D8DDD8FFF8DD8D8D8DDDD88888DDDDDDDDDDDDDDDDDDDDD
            DDDDDD88888DDDDDDDDDDD8FFF8DD8D8D8DDDD8FFF8D8D8D8D8DDD8FFF8DDDDD
            DDDDDD88888DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
          ParentShowHint = False
          ShowHint = True
          OnClick = btdesmarcaClick
        end
        object btmarca: TSpeedButton
          Tag = 2
          Left = 2
          Top = 83
          Width = 20
          Height = 19
          Hint = 'Marca todos os Títulos da Seleção'
          Flat = True
          Glyph.Data = {
            F6000000424DF600000000000000760000002800000010000000100000000100
            04000000000080000000C40E0000C40E00001000000000000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
            DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD88888DDDDDDDDDDD80FF8DDDDD
            DDDDDD0F0F8D8D8D8D8DD08FF08DD8D8D8DDDD88880DDDDDDDDDDDDDDDD0DDDD
            DDDDDD88888DDDDDDDDDDD80FF8DD8D8D8DDDD0F0F8D8D8D8D8DD08FF08DDDDD
            DDDDDD88880DDDDDDDDDDDDDDDD0DDDDDDDDDDDDDDDDDDDDDDDD}
          ParentShowHint = False
          ShowHint = True
          OnClick = btmarcaClick
        end
      end
      object Panel1: TPanel
        Left = 26
        Top = 2
        Width = 713
        Height = 227
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel1'
        TabOrder = 1
        object pgPacks: TPalGrid
          Left = 0
          Top = 0
          Width = 713
          Height = 194
          Align = alClient
          BorderStyle = bsNone
          Color = clWhite
          ColCount = 16
          DefaultDrawing = False
          FixedColor = 11896661
          FixedCols = 0
          RowCount = 2
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clMaroon
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          Options = [dgeEditing]
          ParentFont = False
          PopupMenu = pmLote
          TabOrder = 0
          OnDblClick = AndamentoLote
          OnSetEditText = pgPacksSetEditText
          RowsEffect.Active = True
          RowsEffect.EvenColor = 14606046
          RowsEffect.OddColor = 13745302
          KeyCol = -1
          OnGetEditStyle = pgPacksGetEditStyle
          OnGetDrawStyle = pgPacksGetDrawStyle
          OnCanEditCell = sditCell
          ColWidths = (
            31
            45
            46
            38
            61
            41
            61
            153
            55
            38
            31
            46
            48
            17
            64
            64)
        end
        object Panel2: TPanel
          Left = 0
          Top = 194
          Width = 713
          Height = 33
          Align = alBottom
          BevelOuter = bvNone
          Color = 16316664
          TabOrder = 1
          object Label1: TLabel
            Left = 164
            Top = 18
            Width = 36
            Height = 13
            Caption = 'Peças:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblPecasSel: TLabel
            Left = 117
            Top = 18
            Width = 35
            Height = 13
            Alignment = taRightJustify
            Caption = '00000'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label5: TLabel
            Left = 3
            Top = 18
            Width = 113
            Height = 13
            Caption = 'Peças Selecionadas:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblPecas: TLabel
            Left = 200
            Top = 18
            Width = 35
            Height = 13
            Alignment = taRightJustify
            Caption = '00000'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label7: TLabel
            Left = 243
            Top = 18
            Width = 42
            Height = 13
            Caption = 'Perdas:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblPerdas: TLabel
            Left = 285
            Top = 18
            Width = 35
            Height = 13
            Alignment = taRightJustify
            Caption = '00000'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label9: TLabel
            Left = 328
            Top = 18
            Width = 50
            Height = 13
            Caption = 'Defeitos:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblDefeitos: TLabel
            Left = 380
            Top = 18
            Width = 35
            Height = 13
            Alignment = taRightJustify
            Caption = '00000'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label6: TLabel
            Left = 4
            Top = 0
            Width = 86
            Height = 16
            Caption = 'Quantidades:'
            Enabled = False
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
      end
    end
  end
  object LinkList1: TLinkList
    Left = 0
    Top = 378
    Width = 761
    Height = 31
    ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    Links = <
      item
        Down = False
        Caption = 'Atualizar'
        ShortCut = 0
        OnClick = AtualizaLotes
      end
      item
        Down = False
        Caption = 'Andamento'
        ShortCut = 0
        OnClick = AndamentoLote
      end
      item
        Down = False
        Caption = 'Liberar p/ Estoque'
        ShortCut = 0
        OnClick = LiberaEstoque
      end
      item
        Down = False
        Caption = 'Voltar'
        ShortCut = 0
        OnClick = LinkList1Links3Click
      end
      item
        Down = False
        Visible = False
        Caption = 'Efetivar'
        ShortCut = 123
        OnClick = LinkList1Links4Click
      end
      item
        Down = False
        Caption = 'Distribuir (Canal Venda)'
        ShortCut = 0
        OnClick = LinkList1Links5Click
      end
      item
        Down = False
        Caption = 'Alterar (Canal Venda)'
        ShortCut = 0
        OnClick = LinkList1Links6Click
      end
      item
        Down = False
        Caption = 'Retornar Oficina'
        ShortCut = 0
        OnClick = LinkList1Links7Click
      end>
    LinksHeight = 24
    LinksSpacing = 3
    LinksMargin = 2
    ShortCutPos = scpLeft
    ShowtCutColor = clRed
    ButtonStyle = bsLeftBullet
    List = False
    ListSmall = True
    ListSmallHorizontal = False
    Margin = 2
    TabStop = True
    TabOrder = 1
    Align = alBottom
    Color = clNavy
  end
  object pmLote: TPopupMenu
    Left = 384
    Top = 144
    object Andamento1: TMenuItem
      Caption = 'Andamento'
      OnClick = AndamentoLote
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Exclui1: TMenuItem
      Caption = 'Altera Qtdes'
      OnClick = Exclui1Click
    end
    object ExcluiLote1: TMenuItem
      Caption = 'Exclui Lote'
      OnClick = ExcluiLote1Click
    end
    object AlteraGrade1: TMenuItem
      Caption = 'Altera Grade'
      OnClick = AlteraGrade1Click
    end
    object AlteraOficina1: TMenuItem
      Caption = 'Altera Oficina'
      OnClick = AlteraOficina1Click
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 472
    Top = 176
    object ExcluiOrdem1: TMenuItem
      Caption = 'Exclui Ordem'
      OnClick = ExcluiOrdem1Click
    end
  end
  object wtsLotes: TwtsMethodView
    ObjectView = False
    Transaction = 'MILLENIUM!MPITBULLJEANS.PRODUCAO.CONSULTA_ORDEM_PRODUCAO'
    Left = 214
    Top = 117
  end
  object dsLotes: TDataSource
    DataSet = wtsLotes
    Left = 215
    Top = 181
  end
  object wtsMethodView1: TwtsMethodView
    ObjectView = False
    Transaction = 'MILLENIUM!MPITBULLJEANS.PRODUCAO.VIEWLOTES'
    Left = 132
    Top = 61
  end
  object wtsFases: TwtsMethodView
    ObjectView = False
    Transaction = 'MILLENIUM.FASES.LISTA'
    Left = 324
    Top = 107
  end
end

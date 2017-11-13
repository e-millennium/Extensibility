object FPlanejamentoEstoque: TFPlanejamentoEstoque
  Left = 436
  Top = 182
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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
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
        Top = 77
        Width = 829
        Height = 335
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
          Left = 97
          Top = 19
          Width = 633
          Height = 297
          Anchors = []
          BevelOuter = bvNone
          Caption = 'pnlLOG'
          TabOrder = 0
          Visible = False
          object MemoLog: TMemo
            Left = 0
            Top = 25
            Width = 633
            Height = 241
            Align = alClient
            BorderStyle = bsNone
            TabOrder = 0
          end
          object Panel2: TPanel
            Left = 0
            Top = 0
            Width = 633
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
            Top = 266
            Width = 633
            Height = 31
            Links = <
              item
                Down = False
                Caption = 'OK'
                ShortCut = 0
                OnClick = LinkList2Links0Click
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
      object pnlAviso: TPanel
        Left = 0
        Top = 20
        Width = 829
        Height = 57
        Align = alTop
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 1
        object ProEffectImage1: TProEffectImage
          Left = 8
          Top = 8
          Width = 48
          Height = 48
          AutoSize = True
          Center = True
          Picture.Data = {
            0A54504E474F626A65637489504E470D0A1A0A0000000D494844520000003000
            00003008060000005702F9870000000473424954080808087C08648800000009
            7048597300000B1300000B1301009A9C180000060E4944415478DAED9A6B5094
            5518C7FFEFCB5EB82C7758165CB96D1090089A34D938DA68998A93D358A8205F
            9A1C26C5BCD5D84C29D5344D938D8D9A28F6812642900F8E495246062A027131
            0D2A45EE4A222C2020B2BBEFADF3BE0A0B2AB0BBA2CE363CB3333CE7B067CFF3
            7BCF79CEF99F3D4BC1CE8D7AD2014C013CE9001E19C0A9B365C2647410131D35
            2981FA78B83F30D629802980C705F0DCE5789B3AE623389BDA31335AA700A600
            EC1AE0B7AB01D8737106281AD8B4F44F2C886CB32F8057F317A3DFA4907C7727
            138E6EFDC9BE005E39B60C268E967CA58C47C1F67CFB0278A3E025E8071DEF74
            EE6AC091774EDA17C09B850BD0D4E72AF9A1EA3E7CB3AEC8BE00369F998B8B9D
            DE921F13A4C7EEB5E7EC0B6047F91C94B469247F5EC4757CBCB2C2BE00769D8F
            4141D374C98F8F6DC1D6F80BF60590511389DC3A9DE4AF9E5B8F750BFFB22F80
            9CCB4FE1506D84E48BC18B10760570A229105F9E9F29F9E2F411A7915D019C69
            F3475AF9B3922F26B098C88F15A0A8A45CE00533435CDD0A50026B710017C812
            BA852CA5A2ED4E2E414C6097E5D10B149868F388F13C0FB597A77500A74B2B04
            96332BC9D8866428D86E8B6368E875C35BBFCE977C71131337338B8DA5C1C436
            0F170D4623B47E6AEB00CEFE5E25984CCC70F9E9AB1FC0FDB6E54B6127911109
            444E8826CA08514E586C8C179859E6BE3ABAF47C944EE7601540717915C3318C
            6CA81CD075045AFD7716C76024426E091174A289424E1474969A40BF0836CADC
            575D63C3C00BB367ABAC0228282A6E51CA9481436547E65FCC6C5C67F953BC6B
            B61C68586D1E048FE787CBE7AAAB6A562C5A34D32A8083B9B9FB2203435347E6
            41F8B59DF018A87EB4008C2F993EE63E0C06038E1717ED5EBF7AF536AB00D2BF
            CF591AA9D315F0AC390017433DA25AB790D568E2E960D3898C2C7A9C261DBCEF
            F2E1AADABA3AD4D45F59BC3131B1D02A80B4A2225950A7FE7A8836C8871F310A
            411D19F0EB393E612CB69CC80421066CB4F9E0636218E49F2A6AF7A4056D4242
            C2038772DC2F77F767677F141E1492460BE6B7D10283C8D677A5D118CF569E78
            19DD06A5E45B74A0619CC1CEA88420771DAEAAACA941636B4BDA86A4A44FC66A
            362E407A76B62768BA315A17E661329A975405DB254128998E31DB96B7ABB1AB
            3A06944CC07BCBFF409C6EECF7829381D3E583573D335CD5DEA947715969B7DC
            51199A9290D06B13C0DD5158AF7256ED0FD6048065CD3BB192B98E88AB1F92BF
            EDE3B69F3089593998D05CC02D6EB8EA3649DCC29212188D8694F5494987C66B
            3E21405A5A1AED1B1656A8F6F659E8EBE6296DEB4326E77A10D6F6295483976C
            03605DC1851D03EF1266AE220FE9545919BAFB7A7F494D4C5C4251D4B8DFD15A
            74C171302BCB9F0355E5AFD60478AA5404C2FC99624E683BBF85A6E70748CB88
            250082F88A259B1579F20ECEA3823F5D51017D4FCF3586C29CCD898937268ACD
            E21B9A7D59B9B341F3C51A6F2F57B59B1746EE0FA2B9DEAE4570473A9C8CA365
            F37D008C129CDF4EF001C9A3AA45BD73A6B2125DBDBDFD64999E9FBA76AD45BA
            C5AA2BA6AFB3B3E751A07E767751B904F94F83C964BAE7C378F8DC3C29C90E25
            DB391A807380E0FC1A58DDE764D814A3DA75F7F6A2B4BA1AFD8383FD344D2DD9
            B0664DA9A531597D47B63F2B378EA7F91FE532993A323804ACE97E892DCA6E9F
            BED350DFCC87D3B456086E24F0E01DA3A6CB90D53537E1E23F97C0B3EC0D8AA6
            E249D25AB5D5DB74C9772027279863B9A3144DCF9AE6EB072F373730CC83CF0A
            635D70F4DDBA85EADA1AA234894417F82A9216AF936963DDB1CD5600D1323333
            1D07E4F22FC8992755269753E1D3834013DDC0DF931BF70288BBEBDFF5F5B8D2
            DC2C26AD4051F45ECECB63FBA665CB8CB6C4F1D0D7ACE9870F2F1478FE00113D
            E18E0A0542B5D341F114389E1B056024F922065DD7D40446DC4F785CE241BDBD
            31794DF1C3F43F29F7C47979798A4E13BB99ACAEEFD3343C653207840468E1A4
            5042A351A3A1A515CD6D6D121481ED26B09FC907FAF7A6A4A4300FDBF7A45E74
            7F9599E921972B3751143692A2F7C8FF91FD4F4FD3C23E32DDF68C270D9E28C0
            9065641C77665C6E25110D9872A746386892C9B2B7AD5A3538D97DFD7F7F6A60
            2FF61FC85DF54F196981D60000000049454E44AE426082}
        end
        object lblAprovado: TLabel
          Left = 64
          Top = 24
          Width = 379
          Height = 17
          Caption = 'Planejamento aprovado por %s em %s. Alteração não permitida.'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
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

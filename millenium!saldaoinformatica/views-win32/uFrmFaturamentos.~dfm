object FFaturamentoOS: TFFaturamentoOS
  Left = 419
  Top = 127
  Width = 928
  Height = 480
  Caption = 'Faturamentos de Ordens de Serviços'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object dmPanel1: TdmPanel
    Left = 0
    Top = 0
    Width = 912
    Height = 441
    Style = psBackground
    Align = alClient
    Caption = 'dmPanel1'
    ShowCaption = False
    TabOrder = 0
    object dmPanel2: TdmPanel
      Left = 0
      Top = 0
      Width = 912
      Height = 441
      Style = psHeader
      Align = alClient
      Caption = 'Faturamento de Ordem de Serviço'
      ShowCaption = True
      TabOrder = 0
      object LinkList: TLinkList
        Left = 0
        Top = 20
        Width = 912
        Height = 421
        Links = <>
        LinksHeight = 24
        LinksSpacing = 10
        LinksMargin = 10
        ShortCutPos = scpLeft
        ShowtCutColor = clRed
        ButtonLeftGap = 50
        ButtonRightGap = 50
        List = True
        ListSmall = False
        AutoSize = False
        Margin = 2
        TabOrder = 0
        Align = alClient
      end
    end
  end
  object MVListaEventos: TwtsMethodView
    OnRefreshDone = MVListaEventosRefreshDone
    ObjectView = False
    Transaction = 
      'MILLENIUM!SALDAOINFORMATICA.ORDENS_SERVICO.ListaEventosPorClassi' +
      'ficaoCliente'
    Left = 248
    Top = 144
  end
end

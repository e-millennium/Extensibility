object FTerminal: TFTerminal
  Left = 283
  Top = 159
  BorderStyle = bsNone
  Caption = 'Terminal Consulta'
  ClientHeight = 543
  ClientWidth = 957
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBkd: TTransparentPanel
    Left = 0
    Top = 0
    Width = 957
    Height = 543
    Align = alClient
    Caption = 'pnlBkd'
    Color = clWhite
    TabOrder = 0
    Transparent = 0
    PartialDraw = False
    Shadow = False
    object pnlDadosProd: TTransparentPanel
      Left = 15
      Top = 15
      Width = 937
      Height = 304
      Anchors = [akLeft, akTop, akRight]
      Caption = 'pnlDadosProd'
      Color = clTeal
      TabOrder = 0
      Transparent = 0
      PartialDraw = True
      Shadow = True
      object TransparentPanel2: TTransparentPanel
        Left = 8
        Top = 1
        Width = 928
        Height = 208
        Align = alClient
        Caption = 'TransparentPanel2'
        Color = clTeal
        TabOrder = 0
        Transparent = 150
        PartialDraw = True
        Shadow = False
        object lblDescricaoProduto: TLabel
          Left = 1
          Top = 57
          Width = 926
          Height = 150
          Align = alBottom
          AutoSize = False
          Caption = 'lblDescricaoProduto'
          Color = 16744448
          Font.Charset = ANSI_CHARSET
          Font.Color = clWhite
          Font.Height = -45
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Transparent = True
          Layout = tlCenter
          WordWrap = True
        end
        object lblCodigoProduto: TLabel
          Left = 1
          Top = 23
          Width = 926
          Height = 34
          Align = alBottom
          AutoSize = False
          Caption = 'lblCodigoProduto'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWhite
          Font.Height = -24
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
          Layout = tlCenter
        end
        object lblCodigoDigitado: TLabel
          Left = 1
          Top = -47
          Width = 926
          Height = 70
          Align = alBottom
          Alignment = taCenter
          AutoSize = False
          Caption = 'Informe o código ou referência do produto'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
          Layout = tlBottom
        end
        object lblAlerta: TProEffectImage
          Left = 857
          Top = 90
          Width = 64
          Height = 64
          Anchors = [akTop, akRight]
          AutoSize = True
          Center = True
          Visible = False
        end
        object lblURLAppImg: TProEffectImage
          Left = 857
          Top = 8
          Width = 64
          Height = 65
          Anchors = [akTop, akRight]
          Center = True
          ParentShowHint = False
          Picture.Data = {
            0A54504E474F626A65637489504E470D0A1A0A0000000D494844520000004000
            0000400806000000AA6971DE000000097048597300000B1300000B1301009A9C
            18000008F64944415478DAD59B09B4555318C7BF149532470809AD4448A6C4E2
            0991583C43D62A43854599334F4944649E17C523F36C912153A5CC638321AC88
            289564CA58BEDFDADF5E77BFD37DEF9E73EF3DE7BEBEB5FEEB9DBDCFBE67F89F
            BDBF71BF46928EACA7D845D156B1B20199A198AEF844F15B4AF74E248DCA78AD
            8E8A53143D149B1418BB54314171B7E231C51FCB33015D1517287A1579BD5F14
            D72B2E57FCB53C11D04471A9E26CC50A05C62EB17BD5773F96C740C5ABCB0301
            ACED87153BE539F79162AC6292E27DC5AF8A3F15CD159B2BB654ECAB38D8FAA2
            72BEE28A864C401BC56423219497142324F7059B2A3A2BD614A70421E273C52C
            713A6055C5918A6136269491E266568323602DC544C516411FDAFC24C53D8AC6
            8AC315C789D30DCDF25CE327C5438AD18A0F14AD14D71A19A15CAD38AB2111B0
            82BDFC2E41DF578A9E8A2F14FB286E95C2162094FB1583153FDACB5E1539BFBF
            B8E5D4200818A4B825687F6F64CCB2071F9CF07A5E16280E50BCA9385E717B70
            6E9E621BC50F9526605DC5678AD5ACBD58B18338A7E64EC5B191F198B32714AF
            D8EF5082EB28B652F4566C17198F1F50AD18A7B843DC12F232467154A509606A
            0F0CDA5E530F555C1C195B63E7EBFB6A558ADBC459052F8BC4294D96C3FBC1B9
            7F159B8A9B69152100453647725FFF5371D39207448935B17E343B5F6E74CC7B
            B7503CA5D82BE8C3BAECA63850DC0CF272A3E2D44A1180567F2868331358A7E3
            15BB07FDA7296E48787F4C256B7FDBA0EF602386E5D5D1FAF0163195FF558200
            BE44B51DFF2D4E1F804F823190B14791CFD0413155B1A2B5DF52EC2CCEB4DE14
            8C43E7BC5709023075DEB4BD20CEECE1F09C138CC11ABC11F91DB101B382AFCB
            32E18B8E12170045E55EA9ED076CAC68A99816F49DA9B8266B0258FFBF4BCED7
            F71EDAEB8A5DAD0FEF2E54662B89D3E447D7714D48EC2BCE21F2D25D9CC5F072
            84E201710AB195F53DAE38346B02B6567C1CB40788FB82D86EEFBE46CDD465E2
            A2C3FAE41171BAC50BAE32EBBCB1B5BD17887EE86A7DB8D87B664D004A6E7CD0
            EE69EDC5411FBEBC378528AD2992B30C4481CF48CECE87AE31CECFB3419B19B1
            861DA3647D64E875CBDB0119991180499A1021E04571DAD8FF9638DE7F718818
            1A8CE72B3F62C73B8A33739E9CFBA4F6BA9F2BCE59426A14FD8DA05ED687A2DC
            3A6B02BA88734ABCF4513C282EB26B697D2C8901764C40E497C3425936CA7B57
            B1BD1D7B6D8FB4B06BFAE7C1C9C29942EB7BAF11F27695324B21029892A1B21A
            AAB8445CACEF832212191DEC187FC1AFED6FC469F3505E96DC3A46B774B6E3BD
            C5B9C15E50A0638C9416D687623D3E6B021034F1DA76CC4312F545CD6037710A
            AB58026A246735F028C935A0106706BFC513BCB1120490F9E96DC7043598A5F6
            8A0F83319E98620860F64C979C05F04B231A1E632A5FAB04017C999AA0ED5D61
            94618FA09F2FD42D21016875D6769760CC61E26C3E4B6B33EB2316D9505C6094
            390128BBD9E25258089E21612D5921A6BD776171989E979CB3128700C69F1B9C
            F7A6AE4A6A7F6DAF14CB2E71C361D6DEC991365F1C3D30C2FA581E646F0E4940
            00C4EE676DACC60E46302EF475D68F4E201C9E2929485C02A8F43025BDE9E3A1
            5893F80843C499270217CC649225C08B3E6AD7EB63E711A6FB64FB7B838D4B45
            92A4B0A24AE95B71B1FC8CA0AF1825E89F6169642C0E130A774E5A2F9F9400B4
            34DABE7BD0878F40F2625209045454922631F107F0E6C29A00F93F2CC5C30909
            20B374A138F7168707B38A52F57106CB0D73E89325B8C2D41ECA6A098AC9E2B6
            13A7A1431296D8C30E4E40403EF95A5C8295E8909C619BC8791424D9E9715226
            29A53446A628B4DFC400BD4A24208E90953A489C09AD180108F93CEC33511BF6
            1BFB3F2A030210CC27DE686B71C918A25396D0FC2C09C82749740042D6876583
            052009122D8F1100E1009147C0CC5607E7B0421B066D48A8519C212EC5DEE009
            200344FCEFF704904AC3E4F9A4085FB9ADE432C128C50536AE3EF94E9C3739BB
            A11390CF0C86F13F4E5655E4FC97E2BCC242F29CE41229A913C01E0192984475
            647D7C01250B0248A4B2745617978B0CCFC58A1E4B21602371D5DDBAB2346913
            F0BD1DFF69ED4EE27C052FC3C5F919A910C07A24F9D9AE9E31691340F5A83A72
            FE67C9CDC05819A462092000BA24682FB187E3E6AD3322205F9D8072BAAF2360
            928F9302522C014CB54E763CDF5E8A1991A512CC47C078C9D52B63D52A8B2500
            D3E5CD5118AE162280697BA01DE7CBF2E2EBFB6A319EE62191F3214154A1A3FB
            123610E707CCB6E7FA270D02F0D37F0FDAD40286C5248022C7D3465E1FA95D02
            47AAEC1AD87ED6F73B91F314536AC4ED4B62FBCC5429518A9D01615D8007EA1F
            9300B19727B45E5CC7B5C9032C95BA4BE1FCFE1F59367F90290161CD8E75D93E
            01010D4A8A2500FF7C78D0662D4F6E0004109293B5420790BD5E981601EC1720
            15E673F9DEF5AC915C810347A54DE22B972658A2ADEC986DBC43D22200A126D8
            2F68A3DD5916E7591B4BD12CE1354B9146764F9FA667F3E5196912C02C607384
            AFF692B66637D9C8600CD1DEBC8C08E05E738376AC1D25A50643785BC7046DA6
            6058C28EEE014853F00FC23D44EC4279206D0288D7496E36AFE37CAA39FD8844
            153391E9BB69138044B7D086829BBCBEC4F0C8CA20EC63F0394A3669A2800BFA
            0AE54A883C292E51994F084846A5FCF294D442AF918CF2A0383F2C17012C0176
            7FED96E71C692E1CA534FF492ADCB58610104DCC920064157133215FD61765D4
            37A597271D7F4FD0F67B156249B97382EC27C4F9A06A1CF5016239260985AF4E
            88DDD4DAC40F84D8D3E25EA0DC0478E13F4B70458745EE71A2385FA11C422E72
            ACDDCB0B25F5C1492E9216015ED85310DDD743BC708224C8DDE79141F6B2618A
            9C4A117E47A20DD5691380300B2E8AF411289D2E6E1365926227539EA55415E9
            9F62E77E4DFA705910805C296E7F41F47E044CC4146C969E51C76FB120045A24
            48F25919AC0FC99582915F250940B00E77894BA7E7934546027B0E0868D8924F
            8275AD3AC6E3E4E0F991915A52EC43654900C2462BFE4DB65F89F726FC66597D
            50EA03654D8017AA48E800B6C4AD19F337CC0CA6FBCDE2325265914A11E08550
            1AE58549239181FF4E998BD8618E812A3025304AF065FF9799FF01E8AF225F1D
            3FFCCD0000000049454E44AE426082}
          ShowHint = True
          Stretch = True
          Visible = False
          OnClick = lblURLAppDblClick
        end
        object Label1: TLabel
          Left = 877
          Top = 70
          Width = 22
          Height = 17
          Cursor = crHandPoint
          Anchors = [akRight]
          Caption = 'APP'
          DragCursor = crHandPoint
          FocusControl = pnlBkd
          Font.Charset = ANSI_CHARSET
          Font.Color = 15790320
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          Transparent = True
          WordWrap = True
          OnClick = lblURLAppDblClick
        end
      end
      object TransparentPanel4: TTransparentPanel
        Left = 1
        Top = 209
        Width = 935
        Height = 75
        Align = alBottom
        Caption = 'TransparentPanel4'
        Color = clTeal
        TabOrder = 1
        Transparent = 150
        PartialDraw = True
        Shadow = False
        object lblPrecoProduto: TLabel
          Left = -48
          Top = 1
          Width = 491
          Height = 73
          Align = alRight
          Alignment = taRightJustify
          Caption = 'lblPrecoProduto'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWhite
          Font.Height = -64
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
          Layout = tlBottom
        end
        object lblObs: TLabel
          Left = 113
          Top = 17
          Width = 45
          Height = 21
          Caption = 'lblObs'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          Transparent = True
          Visible = False
          WordWrap = True
        end
        object ImgMaisInformacoes: TProEffectImage
          Left = 8
          Top = 3
          Width = 48
          Height = 48
          Anchors = [akLeft]
          Center = True
          Picture.Data = {
            0A54504E474F626A65637489504E470D0A1A0A0000000D494844520000003000
            00003008060000005702F9870000000473424954080808087C08648800000009
            7048597300000B1300000B1301009A9C18000004DA4944415478DADD9A578C55
            6510C767515189182B222F0AB6A8C48E1AB057167B8B0F2ABE58C012A2C1181F
            C492188DD87B7B51230FA2C6C2DAB00BD81BB6D8DF8C59C09EB8BB2AFAFF65E6
            E8E1B8F7EE3D65EF9E75925F36E7DCBD73BEF9BE39F3CDCC773BAC3AD950EC2B
            A6886DC556716F9DF8FC57B1427C213E158BC4CBE2FB320FED2839E8B5C50962
            BA38A080BEBFC4F3E23E315FF4B4CB8051E21C71BED824EEF589C5E225F181F8
            5C748B5FE2F3D1628CD846EC28F61393C5C8F8FC3B71ADB855FC3698061C216E
            169BC5F53BE20EF190F831A7AEF5CD577086D839EE7D1393F364D50630EB378A
            D3E2FA3D719178D6DC15CA08E3982AAE123BC4BD3BC57936C06AB46AC0B89811
            961E3FBDD07CA9FF2C39F0ACAC2ECE15578A35C5BBE23073F72A6CC016E239B1
            B9B95F1F2F3EAC78E059D9C9FCA5DE527C2D0E8EBFB90D60E617C7E05F17879B
            87C276C8C66281D83D064F78FECF4A3433009F5F62EE366F8883CC63793B853D
            E40531C9DC9D30629550DBCC80BBCD5F58DC86705764E67181FBC56EE24DF3FD
            E2AB9C3A588925A1EB7671562B06102A1F0F6B59C2A23EFF9AD833758D3BEE55
            400FEF042ECC8B3D4D3CD5CC005CE713F3383F4BDC5470F0C8EFE691257D3DB2
            A02E42EA75E6EFC3448BF0DA9F011788ABCDE33CBE57265432E39353D7AF8A7D
            0AEA6222D834D927C800AEEFCF00721B7642D2033696674A0C1E2104DF6BEE86
            B8C0A9A1BFA8E03E5DE2DBD0DD9335607A3C104B99FDB23B6CD5D2116323ED38
            593C9035800DEB4071BAB867A847DB40C89B884678C7D4B401E4EECBCC5F345C
            286F6296C840AB563685DFC07C435B8D31A7951D2B1E162F9AE7F64565B00D40
            5E117B8BA3D2CAC8C579BB2F119757F09046C65461C065628EB826AD8C6CB353
            1C2D1EABB90189B774A59551ABB25D6F675EB3D6D980EDC5478C39AD8CE29A0A
            6923AB2EE31C2C03C88F285757A49551D3AE619E6FF4D5DC00C6489ED6F7BF32
            60D8BBD0B07F8993307A8C78B4E606246174417F1BD9A5E61B459D0D60A3BD58
            CC4D2B63E61F31EFACED5F7303A82BA8EC8E4C2B23495A6E9ECC8D153FD4D400
            924E92B9118C39AB6CA179F7E14C71574D0D98296E134F8BCEACB253CC3BC594
            93BB5AF982A66A033A626CB47A4E12F3B2CAD6322FF970A155AAFF92836E36A0
            3C4263ED09F3927282E8ED4FC16C31572C355F853F6A62005902CD2D3A127428
            6E68A480C2FE6331DE52D57F0D249958365C3A133DCD6620A9FE7BC51EE60716
            4329BB9837C9E8291D6ADED2B76606201C5A108DBE34EFED2C1BA2C18F89C1E3
            F3B798B7DFFF916606E04A8BC27AFA9A742BDADDDCE5588AE62EBDD5B7CD37AF
            DE560D4088463456C787111C362C6FD3E09979F23302095E4067BA3BFB4FAD44
            01966E61FC4511675AEF0FF2E059F5F9A9671E620D3A7AAD863156A22B14B384
            9C8D71D09737C40E24844A1ACA5798BFB06F99C7FEEE465FC81387D9E408A933
            E27A6918C26657C5211FEEC9D9D8C4B8C70B3BDB323E5FC680443A43F984B866
            6B276F7AD0F29FBA93989D28CE304F0F105CE66C4B85CAAA0D40885033638636
            8D7B64B174A0E9ECB16F7C66BEF43FC7E7EBDABF07DD1C5890B273F8919C1F90
            1EB05111BE5B3EB12F9B19E256C79927819C248EC8F9FD95E633CD311415566F
            CEEF57525C24B29EF9E1053D4B7EECB1B5798D313A3EE72707B8182B43CD4D51
            428FF3A7320FADD2802191616FC0DFF0BD12F473334D330000000049454E44AE
            426082}
          Stretch = True
          Visible = False
          OnClick = ImgMaisInformacoesClick
        end
        object Label2: TLabel
          Left = 4
          Top = 51
          Width = 64
          Height = 17
          Cursor = crHandPoint
          Caption = 'Saiba Mais'
          DragCursor = crHandPoint
          FocusControl = pnlBkd
          Font.Charset = ANSI_CHARSET
          Font.Color = 15790320
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          Transparent = True
          Visible = False
          WordWrap = True
          OnClick = lblURLAppDblClick
        end
        object lblPrecoProduto2: TLabel
          Left = 443
          Top = 1
          Width = 491
          Height = 73
          Align = alRight
          Alignment = taRightJustify
          Caption = 'lblPrecoProduto'
          Font.Charset = ANSI_CHARSET
          Font.Color = clBlack
          Font.Height = -64
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
          Layout = tlBottom
        end
      end
      object TransparentPanel5: TTransparentPanel
        Left = 1
        Top = 284
        Width = 935
        Height = 19
        Align = alBottom
        Caption = 'TransparentPanel5'
        Color = clTeal
        TabOrder = 2
        Transparent = 0
        PartialDraw = True
        Shadow = False
        object lblURLProd: TLabel
          Left = 1
          Top = 1
          Width = 933
          Height = 17
          Cursor = crHandPoint
          Align = alClient
          Caption = 'lblURLProd'
          DragCursor = crHandPoint
          Font.Charset = ANSI_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsUnderline]
          ParentFont = False
          Transparent = True
          WordWrap = True
          OnDblClick = lblURLProdDblClick
        end
      end
      object TransparentPanel3: TTransparentPanel
        Left = 1
        Top = 1
        Width = 7
        Height = 208
        Align = alLeft
        Caption = 'TransparentPanel2'
        Color = clTeal
        TabOrder = 3
        Transparent = 150
        PartialDraw = True
        Shadow = False
      end
    end
    object TransparentPanel1: TTransparentPanel
      Left = 1
      Top = 524
      Width = 955
      Height = 18
      Align = alBottom
      Caption = 'TransparentPanel1'
      TabOrder = 1
      Transparent = 0
      PartialDraw = True
      Shadow = False
      object lblData: TLabel
        Left = 915
        Top = 1
        Width = 39
        Height = 16
        Align = alRight
        Alignment = taRightJustify
        Caption = 'lblData'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        Layout = tlCenter
      end
      object lblRodape: TLabel
        Left = 1
        Top = 1
        Width = 39
        Height = 16
        Align = alLeft
        Alignment = taRightJustify
        Caption = 'lblData'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        Layout = tlCenter
      end
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 760
    Top = 360
  end
end

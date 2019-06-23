object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Form1'
  ClientHeight = 352
  ClientWidth = 489
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  GlassFrame.Enabled = True
  object lblInicio: TLabel
    Left = 11
    Top = 289
    Width = 25
    Height = 13
    Caption = 'Inicio'
  end
  object lblTermino: TLabel
    Left = 8
    Top = 308
    Width = 38
    Height = 13
    Caption = 'Termino'
  end
  object lbltempoEstimado: TLabel
    Left = 8
    Top = 327
    Width = 78
    Height = 13
    Caption = 'Tempo Estimado'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 474
    Height = 100
    Caption = 'Dados Autentica'#231#227'o'
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 44
      Width = 36
      Height = 13
      Caption = 'Usu'#225'rio'
    end
    object Label2: TLabel
      Left = 8
      Top = 70
      Width = 30
      Height = 13
      Caption = 'Senha'
    end
    object Label3: TLabel
      Left = 8
      Top = 19
      Width = 19
      Height = 13
      Caption = 'URL'
    end
    object Edituser: TEdit
      Left = 47
      Top = 41
      Width = 418
      Height = 21
      TabOrder = 0
      Text = 'denis@saojorge.com.br'
    end
    object Editpass: TEdit
      Left = 47
      Top = 68
      Width = 418
      Height = 21
      TabOrder = 1
      Text = 'Denis@0710'
    end
    object EditUrl: TEdit
      Left = 47
      Top = 16
      Width = 418
      Height = 21
      TabOrder = 2
      Text = 'https://ccadmin-prod-zcqa.oracleoutsourcing.com'
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 115
    Width = 474
    Height = 85
    Caption = 'Cadastrar Usu'#225'rio (Cliente)'
    TabOrder = 1
    object GAUGE: TGauge
      Left = 10
      Top = 24
      Width = 455
      Height = 17
      Progress = 0
    end
    object Label4: TLabel
      Left = 8
      Top = 45
      Width = 8
      Height = 16
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 8
      Top = 61
      Width = 8
      Height = 16
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Button1: TButton
      Left = 390
      Top = 50
      Width = 75
      Height = 25
      Caption = 'Processar'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 199
    Width = 474
    Height = 86
    Caption = 'Excluir Usu'#225'rio (Cliente)'
    TabOrder = 2
    object Label6: TLabel
      Left = 8
      Top = 27
      Width = 11
      Height = 13
      Caption = 'ID'
    end
    object Button2: TButton
      Left = 390
      Top = 51
      Width = 75
      Height = 25
      Caption = 'Excluir'
      TabOrder = 0
      OnClick = Button2Click
    end
    object edtIDClie: TEdit
      Left = 47
      Top = 24
      Width = 418
      Height = 21
      TabOrder = 1
    end
  end
end

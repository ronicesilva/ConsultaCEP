object FrmMain: TFrmMain
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Consulta CEP'
  ClientHeight = 408
  ClientWidth = 757
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PanelConsulta: TPanel
    Left = 0
    Top = 0
    Width = 757
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 645
    object RadioGroupTipoConsulta: TRadioGroup
      AlignWithMargins = True
      Left = 10
      Top = 10
      Width = 478
      Height = 53
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alLeft
      Caption = ' Tipo de consulta '
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        'Endere'#231'o pelo CEP'
        'CEP pelo endere'#231'o')
      TabOrder = 0
      ExplicitLeft = 11
      ExplicitTop = 11
      ExplicitHeight = 51
    end
    object ButtonConsultar: TButton
      Left = 576
      Top = 19
      Width = 113
      Height = 38
      Caption = 'Consultar'
      TabOrder = 1
    end
  end
  object GroupBoxDados: TGroupBox
    AlignWithMargins = True
    Left = 10
    Top = 76
    Width = 737
    Height = 79
    Margins.Left = 10
    Margins.Right = 10
    Margins.Bottom = 10
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 695
    ExplicitHeight = 109
    object LabelCEP: TLabel
      Left = 62
      Top = 16
      Width = 19
      Height = 13
      Caption = 'CEP'
    end
    object LabelLogradouro: TLabel
      Left = 26
      Top = 43
      Width = 55
      Height = 13
      Caption = 'Logradouro'
    end
    object LabelLocalidade: TLabel
      Left = 419
      Top = 43
      Width = 33
      Height = 13
      Caption = 'Cidade'
    end
    object LabelUF: TLabel
      Left = 648
      Top = 43
      Width = 13
      Height = 13
      Caption = 'UF'
    end
    object MaskEditCEP: TMaskEdit
      Left = 87
      Top = 13
      Width = 118
      Height = 21
      EditMask = '00000\-999;1;_'
      MaxLength = 9
      TabOrder = 0
      Text = '     -   '
    end
    object EditLogradouro: TEdit
      Left = 87
      Top = 40
      Width = 306
      Height = 21
      MaxLength = 100
      TabOrder = 1
    end
    object EditLocalidade: TEdit
      Left = 458
      Top = 40
      Width = 170
      Height = 21
      MaxLength = 100
      TabOrder = 2
    end
    object EditUF: TEdit
      Left = 666
      Top = 40
      Width = 38
      Height = 21
      MaxLength = 2
      TabOrder = 3
    end
  end
  object GroupBoxRetorno: TGroupBox
    AlignWithMargins = True
    Left = 10
    Top = 165
    Width = 737
    Height = 233
    Margins.Left = 10
    Margins.Top = 0
    Margins.Right = 10
    Margins.Bottom = 10
    Align = alBottom
    Caption = ' Retorno '
    TabOrder = 2
    ExplicitLeft = 292
    ExplicitTop = 3
    ExplicitWidth = 260
    ExplicitHeight = 230
    object MemoJSONRetorno: TMemo
      AlignWithMargins = True
      Left = 5
      Top = 18
      Width = 727
      Height = 210
      Align = alClient
      BorderStyle = bsNone
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
end

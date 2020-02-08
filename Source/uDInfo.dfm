object DInfo: TDInfo
  Left = 633
  Top = 357
  HelpContext = 1075
  BorderStyle = bsDialog
  Caption = 'DInfo'
  ClientHeight = 187
  ClientWidth = 313
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 106
  TextHeight = 14
  object FVersion: TLabel
    Left = 138
    Top = 51
    Width = 66
    Height = 18
    Caption = 'FVersion'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object FBuild: TLabel
    Left = 138
    Top = 74
    Width = 29
    Height = 13
    Caption = 'FBuild'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object FURI: TLabel
    Left = 138
    Top = 107
    Width = 25
    Height = 13
    Cursor = crHandPoint
    Caption = 'FURI'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = FURIClick
  end
  object FName: TLabel
    Left = 138
    Top = 16
    Width = 66
    Height = 23
    Caption = 'FName'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object PImage: TPanel
    Left = 17
    Top = 17
    Width = 95
    Height = 95
    BevelOuter = bvLowered
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object FImage: TImage
      Left = 13
      Top = 13
      Width = 69
      Height = 69
    end
  end
  object FBOk: TButton
    Left = 223
    Top = 149
    Width = 76
    Height = 24
    Cancel = True
    Caption = 'FBOk'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
end

object DDowndate: TDDowndate
  Left = 0
  Top = 0
  HelpContext = 1157
  BorderStyle = bsDialog
  Caption = 'DDowndate'
  ClientHeight = 196
  ClientWidth = 385
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    385
    196)
  PixelsPerInch = 106
  TextHeight = 14
  object FLDescription: TLabel
    Left = 8
    Top = 8
    Width = 369
    Height = 34
    AutoSize = False
    Caption = 'FLDescription'
    FocusControl = FDescription
    WordWrap = True
  end
  object FLMail: TLabel
    Left = 90
    Top = 126
    Width = 31
    Height = 14
    Anchors = [akRight, akBottom]
    Caption = 'FLMail'
  end
  object FBOk: TButton
    Left = 213
    Top = 163
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBOk'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object FBCancel: TButton
    Left = 302
    Top = 163
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 4
  end
  object FDescription: TMemo
    Left = 8
    Top = 48
    Width = 369
    Height = 65
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'FDescription')
    TabOrder = 0
  end
  object FBHelp: TButton
    Left = 8
    Top = 163
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'FBHelp'
    TabOrder = 2
    OnClick = FBHelpClick
  end
  object FMail: TEdit
    Left = 170
    Top = 123
    Width = 207
    Height = 22
    Anchors = [akRight, akBottom]
    TabOrder = 1
    Text = 'FMail'
  end
end

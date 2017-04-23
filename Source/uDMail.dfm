object DMail: TDMail
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'DMail'
  ClientHeight = 450
  ClientWidth = 482
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
    482
    450)
  PixelsPerInch = 106
  TextHeight = 14
  object FLName: TLabel
    Left = 8
    Top = 8
    Width = 43
    Height = 14
    Caption = 'FLName'
    FocusControl = FName
  end
  object FLMail: TLabel
    Left = 8
    Top = 64
    Width = 31
    Height = 14
    Caption = 'FLMail'
    FocusControl = FMail
  end
  object FLBody: TLabel
    Left = 8
    Top = 120
    Width = 39
    Height = 14
    Caption = 'FLBody'
    FocusControl = FBody
  end
  object FBody: TRichEdit
    Left = 8
    Top = 140
    Width = 465
    Height = 253
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      'FBody')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object FName: TEdit
    Left = 8
    Top = 28
    Width = 249
    Height = 22
    TabOrder = 0
  end
  object FMail: TEdit
    Left = 8
    Top = 84
    Width = 249
    Height = 22
    TabOrder = 1
  end
  object FBOk: TButton
    Left = 312
    Top = 416
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBOk'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object FBCancel: TButton
    Left = 400
    Top = 416
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 4
  end
end

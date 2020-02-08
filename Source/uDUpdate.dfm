object DUpdate: TDUpdate
  Left = 458
  Top = 281
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'DInstallUpdate'
  ClientHeight = 166
  ClientWidth = 345
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 106
  TextHeight = 13
  object FBCancel: TButton
    Left = 262
    Top = 131
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 0
  end
  object GroupBox: TGroupBox_Ext
    Left = 8
    Top = 8
    Width = 329
    Height = 101
    Caption = 'GroupBox'
    TabOrder = 1
    DesignSize = (
      329
      101)
    object FVersionInfo: TLabel
      Left = 8
      Top = 18
      Width = 59
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      Caption = 'FVersionInfo'
    end
    object FProgram: TLabel
      Left = 8
      Top = 41
      Width = 45
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      Caption = 'FProgram'
    end
    object FProgressBar: TProgressBar
      Left = 8
      Top = 72
      Width = 313
      Height = 16
      TabOrder = 0
    end
  end
  object FBForward: TButton
    Left = 173
    Top = 131
    Width = 75
    Height = 25
    Caption = 'FBForward'
    Default = True
    TabOrder = 2
    OnClick = FBForwardClick
  end
end

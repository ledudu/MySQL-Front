object DAccount: TDAccount
  Left = 616
  Top = 338
  HelpContext = 1065
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DAccount'
  ClientHeight = 362
  ClientWidth = 313
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCanResize = FormCanResize
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHide = FormHide
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    313
    362)
  PixelsPerInch = 106
  TextHeight = 13
  object FBOk: TButton
    Left = 142
    Top = 328
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBOk'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object FBCancel: TButton
    Left = 230
    Top = 328
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 3
  end
  object GBasics: TGroupBox_Ext
    Left = 8
    Top = 4
    Width = 297
    Height = 47
    Anchors = [akLeft, akTop, akRight]
    Caption = 'GBasics'
    TabOrder = 4
    DesignSize = (
      297
      47)
    object FLName: TLabel
      Left = 8
      Top = 19
      Width = 40
      Height = 13
      Caption = 'FLName'
    end
    object FName: TEdit
      Left = 128
      Top = 16
      Width = 157
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      MaxLength = 100
      TabOrder = 0
      Text = 'FName'
    end
  end
  object GConnection: TGroupBox_Ext
    Left = 8
    Top = 55
    Width = 297
    Height = 130
    Anchors = [akLeft, akTop, akRight]
    Caption = 'GConnection'
    TabOrder = 5
    DesignSize = (
      297
      130)
    object FLHost: TLabel
      Left = 8
      Top = 19
      Width = 34
      Height = 13
      Caption = 'FLHost'
      FocusControl = FHost
    end
    object FLPort: TLabel
      Left = 8
      Top = 43
      Width = 31
      Height = 13
      Caption = 'FLPort'
      FocusControl = FPort
    end
    object FLConnectionType: TLabel
      Left = 8
      Top = 75
      Width = 90
      Height = 13
      Caption = 'FLConnectionType'
      FocusControl = FConnectionType
    end
    object FLHTTPTunnelURI: TLabel
      Left = 8
      Top = 99
      Width = 93
      Height = 13
      Caption = 'FLHTTPTunnelURI'
      FocusControl = FHTTPTunnelURI
      Visible = False
    end
    object FLLibraryFilename: TLabel
      Left = 8
      Top = 99
      Width = 85
      Height = 13
      Caption = 'FLLibraryFilename'
      FocusControl = FLibraryFilename
      Visible = False
    end
    object FHTTPTunnelURI: TEdit
      Left = 128
      Top = 96
      Width = 161
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 5
      Text = 'FHTTPTunnelURI'
      Visible = False
      OnEnter = FHTTPTunnelURIEnter
    end
    object FHost: TEdit
      Left = 128
      Top = 16
      Width = 157
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'FHost'
      OnChange = FHostChange
      OnExit = FHostExit
    end
    object FPort: TEdit
      Left = 128
      Top = 40
      Width = 41
      Height = 21
      MaxLength = 5
      TabOrder = 1
      Text = '0'
    end
    object FConnectionType: TComboBox_Ext
      Left = 128
      Top = 72
      Width = 129
      Height = 21
      Style = csDropDownList
      TabOrder = 3
      OnChange = FConnectionTypeChange
    end
    object FLibraryFilename: TEdit
      Left = 128
      Top = 96
      Width = 97
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      Text = 'FLibraryFilename'
      Visible = False
      OnEnter = FLibraryFilenameEnter
    end
    object FUDPort: TUpDown
      Left = 169
      Top = 40
      Width = 16
      Height = 21
      Associate = FPort
      Max = 65535
      TabOrder = 2
      Thousands = False
    end
  end
  object GLogin: TGroupBox_Ext
    Left = 8
    Top = 191
    Width = 297
    Height = 117
    Anchors = [akLeft, akTop, akRight]
    Caption = 'GLogin'
    TabOrder = 0
    DesignSize = (
      297
      117)
    object FLDatabase: TLabel
      Left = 8
      Top = 87
      Width = 58
      Height = 13
      Caption = 'FLDatabase'
      FocusControl = FDatabase
    end
    object FLUser: TLabel
      Left = 8
      Top = 19
      Width = 34
      Height = 13
      Caption = 'FLUser'
      FocusControl = FUser
    end
    object FLPassword: TLabel
      Left = 8
      Top = 51
      Width = 58
      Height = 13
      Caption = 'FLPassword'
      FocusControl = FPassword
    end
    object FDatabase: TEdit
      Left = 128
      Top = 84
      Width = 137
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      Text = 'FDatabase'
    end
    object FUser: TEdit
      Left = 128
      Top = 16
      Width = 113
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      MaxLength = 50
      TabOrder = 0
      Text = 'FUser'
    end
    object FPassword: TEdit
      Left = 128
      Top = 48
      Width = 113
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      Text = 'FPassword'
    end
    object FBDatabase: TButton
      Left = 266
      Top = 84
      Width = 21
      Height = 21
      Anchors = [akTop, akRight]
      Caption = #183#183#183
      TabOrder = 3
      OnClick = FBDatabaseClick
    end
  end
  object FBHelp: TButton
    Left = 8
    Top = 328
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'FBHelp'
    TabOrder = 1
    OnClick = FBHelpClick
  end
end

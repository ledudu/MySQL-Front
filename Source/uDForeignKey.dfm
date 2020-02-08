object DForeignKey: TDForeignKey
  Left = 436
  Top = 175
  BorderStyle = bsDialog
  Caption = 'DForeignKey'
  ClientHeight = 461
  ClientWidth = 435
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHide = FormHide
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    435
    461)
  PixelsPerInch = 106
  TextHeight = 14
  object PSQLWait: TPanel
    Left = 9
    Top = 9
    Width = 419
    Height = 393
    Cursor = crHourGlass
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'PSQLWait'
    TabOrder = 0
    Visible = False
  end
  object FBOk: TButton
    Left = 252
    Top = 425
    Width = 81
    Height = 27
    Anchors = [akRight, akBottom]
    Caption = 'FBOk'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object FBCancel: TButton
    Left = 347
    Top = 425
    Width = 81
    Height = 27
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 3
  end
  object GBasics: TGroupBox_Ext
    Left = 9
    Top = 9
    Width = 419
    Height = 298
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'GBasics'
    TabOrder = 4
    DesignSize = (
      419
      298)
    object FLTable: TLabel
      Left = 9
      Top = 120
      Width = 42
      Height = 14
      Caption = 'FLTable'
      FocusControl = FParentTable
    end
    object FLFields: TLabel
      Left = 9
      Top = 154
      Width = 41
      Height = 14
      Caption = 'FLFields'
      FocusControl = FParentFields
    end
    object FLChild: TLabel
      Left = 129
      Top = 60
      Width = 37
      Height = 14
      Caption = 'FLChild'
    end
    object FLParent: TLabel
      Left = 276
      Top = 60
      Width = 48
      Height = 14
      Caption = 'FLParent'
    end
    object FLName: TLabel
      Left = 9
      Top = 20
      Width = 43
      Height = 14
      Caption = 'FLName'
      FocusControl = FName
    end
    object FLDatabase: TLabel
      Left = 9
      Top = 85
      Width = 62
      Height = 14
      Caption = 'FLDatabase'
      FocusControl = FParentDatabase
    end
    object FParentTable: TComboBox_Ext
      Left = 276
      Top = 116
      Width = 130
      Height = 22
      Style = csDropDownList
      TabOrder = 5
      OnChange = FParentTableChange
    end
    object FFields: TListBox
      Left = 129
      Top = 151
      Width = 131
      Height = 134
      Anchors = [akLeft, akTop, akBottom]
      ItemHeight = 14
      MultiSelect = True
      TabOrder = 3
      OnClick = FBOkCheckEnabled
    end
    object FParentFields: TListBox
      Left = 276
      Top = 151
      Width = 130
      Height = 134
      Anchors = [akLeft, akTop, akBottom]
      ItemHeight = 14
      MultiSelect = True
      TabOrder = 6
      OnClick = FBOkCheckEnabled
    end
    object FTable: TEdit
      Left = 129
      Top = 116
      Width = 131
      Height = 22
      Enabled = False
      TabOrder = 2
      Text = 'FTable'
    end
    object FName: TEdit
      Left = 129
      Top = 17
      Width = 156
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      MaxLength = 64
      TabOrder = 0
      Text = 'FName'
      OnChange = FBOkCheckEnabled
    end
    object FDatabase: TEdit
      Left = 129
      Top = 82
      Width = 131
      Height = 22
      Enabled = False
      TabOrder = 1
      Text = 'FDatabase'
    end
    object FParentDatabase: TComboBox_Ext
      Left = 276
      Top = 82
      Width = 130
      Height = 22
      Style = csDropDownList
      TabOrder = 4
      OnChange = FParentDatabaseChange
    end
  end
  object FBHelp: TButton
    Left = 9
    Top = 425
    Width = 80
    Height = 27
    Anchors = [akLeft, akBottom]
    Caption = 'FBHelp'
    TabOrder = 1
    OnClick = FBHelpClick
  end
  object GAttributes: TGroupBox_Ext
    Left = 9
    Top = 314
    Width = 419
    Height = 88
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'GAttributes'
    TabOrder = 5
    object FLOnDelete: TLabel
      Left = 9
      Top = 22
      Width = 64
      Height = 14
      Caption = 'FLOnDelete'
      FocusControl = FOnDelete
    end
    object FLOnUpdate: TLabel
      Left = 9
      Top = 56
      Width = 68
      Height = 14
      Caption = 'FLOnUpdate'
      FocusControl = FOnUpdate
    end
    object FOnDelete: TComboBox_Ext
      Left = 129
      Top = 17
      Width = 131
      Height = 22
      Style = csDropDownList
      TabOrder = 0
      OnChange = FBOkCheckEnabled
    end
    object FOnUpdate: TComboBox_Ext
      Left = 129
      Top = 52
      Width = 131
      Height = 22
      Style = csDropDownList
      TabOrder = 1
      OnChange = FBOkCheckEnabled
    end
  end
end

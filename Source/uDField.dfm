object DField: TDField
  Left = 764
  Top = 340
  BorderStyle = bsDialog
  Caption = 'DField'
  ClientHeight = 463
  ClientWidth = 337
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
  OnShow = FormShow
  DesignSize = (
    337
    463)
  PixelsPerInch = 106
  TextHeight = 13
  object PSQLWait: TPanel
    Left = 8
    Top = 8
    Width = 321
    Height = 403
    Cursor = crHourGlass
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'PSQLWait'
    TabOrder = 0
    Visible = False
  end
  object GBasics: TGroupBox_Ext
    Left = 8
    Top = 8
    Width = 321
    Height = 319
    Anchors = [akLeft, akTop, akRight]
    Caption = 'GBasics'
    TabOrder = 1
    DesignSize = (
      321
      319)
    object FLFormatDecimals: TLabel
      Left = 8
      Top = 146
      Width = 87
      Height = 13
      Caption = 'FLFormatDecimals'
      FocusControl = FFormatSize
    end
    object FLFormatSize: TLabel
      Left = 8
      Top = 146
      Width = 64
      Height = 13
      Caption = 'FLFormatSize'
      FocusControl = FFormatSize
    end
    object FLFormatFSP: TLabel
      Left = 8
      Top = 146
      Width = 64
      Height = 13
      Caption = 'FLFormatFSP'
      FocusControl = FFormatSize
    end
    object FLFormat: TLabel
      Left = 8
      Top = 146
      Width = 44
      Height = 13
      Caption = 'FLFormat'
    end
    object FLName: TLabel
      Left = 8
      Top = 52
      Width = 40
      Height = 13
      Caption = 'FLName'
      FocusControl = FName
    end
    object FLFieldType: TLabel
      Left = 8
      Top = 114
      Width = 58
      Height = 13
      Caption = 'FLFieldType'
      FocusControl = FFieldType
    end
    object FLDefault: TLabel
      Left = 8
      Top = 178
      Width = 46
      Height = 13
      Caption = 'FLDefault'
      FocusControl = FDefault
    end
    object FLPosition: TLabel
      Left = 8
      Top = 20
      Width = 49
      Height = 13
      Caption = 'FLPosition'
      FocusControl = FPosition
    end
    object FLComment: TLabel
      Left = 8
      Top = 289
      Width = 56
      Height = 13
      Caption = 'FLComment'
    end
    object FLCharset: TLabel
      Left = 8
      Top = 231
      Width = 48
      Height = 13
      Caption = 'FLCharset'
      FocusControl = FCharset
    end
    object FLCollation: TLabel
      Left = 8
      Top = 257
      Width = 52
      Height = 13
      Caption = 'FLCollation'
      FocusControl = FCollation
    end
    object FLUpdateTime: TLabel
      Left = 8
      Top = 243
      Width = 70
      Height = 13
      Caption = 'FLUpdateTime'
    end
    object FLKind: TLabel
      Left = 8
      Top = 81
      Width = 33
      Height = 13
      Caption = 'FLKind'
    end
    object FLExpression: TLabel
      Left = 8
      Top = 177
      Width = 63
      Height = 13
      Caption = 'FLExpression'
    end
    object FLStored: TLabel
      Left = 8
      Top = 205
      Width = 43
      Height = 13
      Caption = 'FLStored'
    end
    object FDefaultSet: TListBox
      Left = 120
      Top = 174
      Width = 189
      Height = 41
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 20
      OnClick = FBOkCheckEnabled
    end
    object FDefault: TEdit
      Left = 135
      Top = 194
      Width = 174
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 13
      Text = 'FDefault'
      OnChange = FDefaultChange
      OnEnter = FDefaultEnter
      OnExit = FDefaultExit
    end
    object FFormatUnion: TEdit
      Left = 120
      Top = 142
      Width = 189
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 10
      OnChange = FFormatUnionChange
    end
    object FFormatYear: TComboBox_Ext
      Left = 120
      Top = 142
      Width = 57
      Height = 21
      Style = csDropDownList
      TabOrder = 9
      OnChange = FFormatYearChange
      Items.Strings = (
        'YYYY'
        'YY')
    end
    object FFormatSize: TEdit
      Left = 120
      Top = 142
      Width = 41
      Height = 21
      TabOrder = 4
      Text = '0'
      OnChange = FFormatSizeChange
      OnExit = FFormatSizeExit
    end
    object FDefaultEnum: TComboBox_Ext
      Left = 120
      Top = 174
      Width = 189
      Height = 21
      Style = csDropDownList
      TabOrder = 19
      OnChange = FBOkCheckEnabled
    end
    object FRDefaultNull: TRadioButton
      Left = 120
      Top = 177
      Width = 188
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'FRDefaultNull'
      TabOrder = 11
      OnClick = FRDefaultClick
    end
    object FFormatTimestamp: TComboBox_Ext
      Left = 120
      Top = 142
      Width = 137
      Height = 21
      Style = csDropDownList
      TabOrder = 8
      OnChange = FBOkCheckEnabled
      Items.Strings = (
        'YYYYMMDDHHMMSS'
        'YYMMDDHHMMSS'
        'YYYYMMDD'
        'YYMMDD')
    end
    object FUDFormatSize: TUpDown
      Left = 161
      Top = 142
      Width = 16
      Height = 21
      Associate = FFormatSize
      TabOrder = 5
      TabStop = True
      OnMouseDown = FUDMouseDown
    end
    object FFormatDecimals: TEdit
      Left = 184
      Top = 142
      Width = 33
      Height = 21
      TabOrder = 6
      Text = '0'
      OnChange = FFormatDecimalsChange
    end
    object FUDFormatDecimals: TUpDown
      Left = 217
      Top = 142
      Width = 15
      Height = 21
      Associate = FFormatDecimals
      Max = 10
      TabOrder = 7
      Thousands = False
      OnMouseDown = FUDMouseDown
    end
    object FFieldType: TComboBox_Ext
      Left = 120
      Top = 110
      Width = 129
      Height = 21
      Style = csDropDownList
      DropDownCount = 15
      TabOrder = 3
      OnChange = FFieldTypeChange
      OnDrawItem = FFieldTypeDrawItem
      OnExit = FFieldTypeExit
      Items.Strings = (
        'TinyInt'
        'SmallInt'
        'MediumInt'
        'Int'
        'BigInt'
        'Float'
        'Double'
        'Decimal'
        'Date'
        'DateTime'
        'TimeStamp'
        'Time'
        'Year'
        'Char'
        'VarChar'
        'Binary'
        'VarBinary'
        'TinyText'
        'Text'
        'MediumText'
        'LongText'
        'TinyBlob'
        'Blob'
        'MediumBlob'
        'LongBlob'
        'Enum'
        'Set'
        'Geometry'
        'Point'
        'LineString'
        'Polygon'
        'MultiPoint'
        'MultiLineString'
        'MultiPolygon'
        'GeometryCollection')
    end
    object FName: TEdit
      Left = 120
      Top = 48
      Width = 145
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      MaxLength = 64
      TabOrder = 1
      Text = 'FName'
      OnChange = FBOkCheckEnabled
    end
    object FPosition: TComboBox_Ext
      Left = 120
      Top = 16
      Width = 189
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = FBOkCheckEnabled
    end
    object FComment: TEdit
      Left = 120
      Top = 286
      Width = 189
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      MaxLength = 1024
      TabOrder = 23
      Text = 'FComment'
      OnChange = FBOkCheckEnabled
    end
    object FCharset: TComboBox_Ext
      Left = 120
      Top = 228
      Width = 113
      Height = 21
      Style = csDropDownList
      TabOrder = 21
      OnChange = FCharsetChange
    end
    object FCollation: TComboBox_Ext
      Left = 120
      Top = 254
      Width = 145
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 22
      OnChange = FBOkCheckEnabled
    end
    object FRDefault: TRadioButton
      Left = 120
      Top = 196
      Width = 14
      Height = 17
      TabOrder = 12
      OnClick = FRDefaultClick
    end
    object FRDefaultInsertTime: TRadioButton
      Left = 120
      Top = 215
      Width = 188
      Height = 17
      Caption = 'FRDefaultInsertTime'
      TabOrder = 14
      OnClick = FRDefaultClick
    end
    object FUpdateTime: TCheckBox
      Left = 120
      Top = 242
      Width = 188
      Height = 17
      Caption = 'FUpdateTime'
      TabOrder = 16
      OnClick = FRDefaultClick
    end
    object FRDefaultAutoIncrement: TRadioButton
      Left = 120
      Top = 215
      Width = 188
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'FRDefaultAutoIncrement'
      TabOrder = 15
      OnClick = FRDefaultClick
      OnKeyDown = FRDefaultNullKeyDown
    end
    object FKind: TPanel
      Left = 120
      Top = 80
      Width = 189
      Height = 20
      BevelOuter = bvNone
      TabOrder = 2
      object FKindReal: TRadioButton
        Left = 0
        Top = 1
        Width = 90
        Height = 17
        Caption = 'FKindReal'
        TabOrder = 0
        OnClick = FFieldTypeChange
      end
      object FKindVirtual: TRadioButton
        Left = 100
        Top = 1
        Width = 90
        Height = 17
        Caption = 'FKindVirtual'
        TabOrder = 1
        OnClick = FFieldTypeChange
      end
    end
    object FExpression: TEdit
      Left = 120
      Top = 174
      Width = 189
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 17
      Text = 'FExpression'
      OnChange = FBOkCheckEnabled
    end
    object FStored: TPanel
      Left = 120
      Top = 205
      Width = 188
      Height = 41
      BevelOuter = bvNone
      FullRepaint = False
      TabOrder = 18
      object FStoredStored: TRadioButton
        Left = 0
        Top = 0
        Width = 188
        Height = 17
        Caption = 'FStoredStored'
        TabOrder = 0
        OnClick = FBOkCheckEnabled
      end
      object FStoredVirtual: TRadioButton
        Left = 0
        Top = 20
        Width = 188
        Height = 17
        Caption = 'FStoredVirtual'
        TabOrder = 1
        OnClick = FBOkCheckEnabled
      end
    end
  end
  object FBOk: TButton
    Left = 168
    Top = 430
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBOk'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object FBCancel: TButton
    Left = 256
    Top = 430
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 5
  end
  object GAttributes: TGroupBox_Ext
    Left = 8
    Top = 330
    Width = 321
    Height = 81
    Anchors = [akLeft, akTop, akRight]
    Caption = 'GAttributes'
    TabOrder = 2
    object FFlagNational: TCheckBox
      Left = 8
      Top = 36
      Width = 145
      Height = 17
      Caption = 'FFlagNational'
      TabOrder = 4
      OnClick = FBOkCheckEnabled
      OnKeyPress = FFlagNationalKeyPress
    end
    object FFlagNullAllowed: TCheckBox
      Left = 8
      Top = 16
      Width = 145
      Height = 17
      Caption = 'FFlagNullAllowed'
      TabOrder = 0
      OnClick = FFlagNullAllowedClick
      OnKeyPress = FFlagNullAllowedKeyPress
    end
    object FFlagUnsigned: TCheckBox
      Left = 160
      Top = 16
      Width = 145
      Height = 17
      Caption = 'FFlagUnsigned'
      TabOrder = 1
      OnClick = FFlagUnsignedClick
      OnKeyPress = FFlagUnsignedKeyPress
    end
    object FFlagBinary: TCheckBox
      Left = 160
      Top = 16
      Width = 145
      Height = 17
      Caption = 'FFlagBinary'
      TabOrder = 3
      OnClick = FFlagCharClick
      OnKeyPress = FFlagCharPress
    end
    object FFlagZerofill: TCheckBox
      Left = 160
      Top = 36
      Width = 145
      Height = 17
      Caption = 'FFlagZerofill'
      TabOrder = 2
      OnClick = FFlagZerofillClick
      OnKeyPress = FFlagZerofillKeyPress
    end
    object FFlagAscii: TCheckBox
      Left = 160
      Top = 36
      Width = 145
      Height = 17
      Caption = 'FFlagAscii'
      TabOrder = 5
      OnClick = FFlagCharClick
      OnKeyPress = FFlagCharPress
    end
    object FFlagUnicode: TCheckBox
      Left = 160
      Top = 56
      Width = 145
      Height = 17
      Caption = 'FFlagUnicode'
      TabOrder = 6
      OnClick = FFlagCharClick
      OnKeyPress = FFlagCharPress
    end
  end
  object FBHelp: TButton
    Left = 8
    Top = 430
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'FBHelp'
    TabOrder = 3
    OnClick = FBHelpClick
  end
end

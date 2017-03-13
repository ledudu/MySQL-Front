object DExport: TDExport
  Left = 486
  Top = 233
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DExport'
  ClientHeight = 331
  ClientWidth = 341
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
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    341
    331)
  PixelsPerInch = 106
  TextHeight = 13
  object PSQLWait: TPanel_Ext
    Left = 8
    Top = 0
    Width = 341
    Height = 281
    Cursor = crHourGlass
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'PSQLWait'
    ParentBackground = False
    TabOrder = 0
    Visible = False
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 341
    Height = 281
    ActivePage = TSExecute
    Anchors = [akLeft, akTop, akRight, akBottom]
    HotTrack = True
    Style = tsFlatButtons
    TabOrder = 1
    TabStop = False
    object TSSQLOptions: TTabSheet
      Caption = 'TSSQLOptions'
      TabVisible = False
      OnShow = TSSQLOptionsShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        333
        271)
      object GSQLWhat: TGroupBox_Ext
        Left = 4
        Top = 0
        Width = 325
        Height = 63
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GSQLWhat'
        TabOrder = 0
        DesignSize = (
          325
          63)
        object FLSQLWhat: TLabel
          Left = 8
          Top = 17
          Width = 59
          Height = 13
          Caption = 'FLSQLWhat'
        end
        object FSQLStructure: TCheckBox
          Left = 128
          Top = 16
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FSQLStructure'
          TabOrder = 0
          OnClick = FSQLOptionClick
          OnKeyPress = FSQLOptionKeyPress
        end
        object FSQLData: TCheckBox
          Left = 128
          Top = 36
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FSQLData'
          TabOrder = 1
          OnClick = FSQLOptionClick
          OnKeyPress = FSQLOptionKeyPress
        end
      end
      object GSQLOptions: TGroupBox_Ext
        Left = 4
        Top = 70
        Width = 325
        Height = 63
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GSQLOptions'
        TabOrder = 1
        object FLDrop: TLabel
          Left = 8
          Top = 17
          Width = 35
          Height = 13
          Caption = 'FLDrop'
        end
        object FDropStmts: TCheckBox
          Left = 128
          Top = 16
          Width = 193
          Height = 17
          Caption = 'FDropStmts'
          TabOrder = 0
          OnClick = FSQLOptionClick
          OnKeyPress = FSQLOptionKeyPress
        end
        object FReplaceData: TCheckBox
          Left = 128
          Top = 36
          Width = 193
          Height = 17
          Caption = 'FReplaceData'
          TabOrder = 1
          OnClick = FSQLOptionClick
          OnKeyPress = FSQLOptionKeyPress
        end
      end
    end
    object TSCSVOptions: TTabSheet
      Caption = 'TSCSVOptions'
      TabVisible = False
      OnShow = TSCSVOptionsShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        333
        271)
      object GCSVOptions: TGroupBox_Ext
        Left = 4
        Top = 0
        Width = 325
        Height = 197
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GCSVOptions'
        TabOrder = 0
        DesignSize = (
          325
          197)
        object FLCSVHeadline: TLabel
          Left = 8
          Top = 17
          Width = 75
          Height = 13
          Caption = 'FLCSVHeadline'
        end
        object PQuote: TPanel_Ext
          Left = 4
          Top = 98
          Width = 317
          Height = 89
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 2
          DesignSize = (
            317
            89)
          object FLQuoteValues: TLabel
            Left = 4
            Top = 4
            Width = 73
            Height = 13
            Caption = 'FLQuoteValues'
          end
          object FLQuoteChar: TLabel
            Left = 4
            Top = 67
            Width = 63
            Height = 13
            Caption = 'FLQuoteChar'
            FocusControl = FQuoteChar
          end
          object FQuoteChar: TEdit
            Left = 124
            Top = 64
            Width = 17
            Height = 21
            MaxLength = 1
            TabOrder = 3
            Text = 'FQuoteChar'
            OnExit = FQuoteCharExit
          end
          object FQuoteNone: TRadioButton
            Left = 124
            Top = 3
            Width = 193
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = 'FQuoteNone'
            TabOrder = 2
            OnClick = FQuoteClick
            OnKeyPress = FQuoteKeyPress
          end
          object FQuoteStrings: TRadioButton
            Left = 124
            Top = 23
            Width = 193
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = 'FQuoteStrings'
            TabOrder = 1
            OnClick = FQuoteClick
            OnKeyPress = FQuoteKeyPress
          end
          object FQuoteAll: TRadioButton
            Left = 124
            Top = 43
            Width = 193
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = 'FQuoteAll'
            TabOrder = 0
            OnClick = FQuoteClick
            OnKeyPress = FQuoteKeyPress
          end
        end
        object FCSVHeadline: TCheckBox
          Left = 128
          Top = 16
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FCSVHeadline'
          TabOrder = 0
        end
        object PSeparator: TPanel_Ext
          Left = 4
          Top = 44
          Width = 317
          Height = 53
          BevelOuter = bvNone
          Ctl3D = True
          ParentBackground = False
          ParentCtl3D = False
          TabOrder = 1
          DesignSize = (
            317
            53)
          object FLSeparator: TLabel
            Left = 4
            Top = 6
            Width = 58
            Height = 13
            Caption = 'FLSeparator'
          end
          object FSeparatorChar: TRadioButton
            Left = 124
            Top = 26
            Width = 77
            Height = 17
            Caption = 'FSeparatorChar'
            TabOrder = 1
            OnClick = FSeparatorClick
            OnKeyPress = FSeparatorKeyPress
          end
          object FSeparator: TEdit
            Left = 207
            Top = 24
            Width = 21
            Height = 21
            TabOrder = 2
            Text = 'FSeparatorChar'
          end
          object FSeparatorTab: TRadioButton
            Left = 124
            Top = 5
            Width = 193
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = 'FSeparatorTab'
            TabOrder = 0
            OnClick = FSeparatorClick
            OnKeyPress = FSeparatorKeyPress
          end
        end
      end
    end
    object TSXMLOptions: TTabSheet
      Caption = 'TSXMLOptions'
      TabVisible = False
      OnShow = TSXMLOptionsShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        333
        271)
      object GXMLHow: TGroupBox_Ext
        Left = 4
        Top = 0
        Width = 325
        Height = 265
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GXMLHow'
        TabOrder = 0
        object FLRootNode: TLabel
          Left = 8
          Top = 21
          Width = 61
          Height = 13
          Caption = 'FLRootNode'
          FocusControl = FRootNodeText
        end
        object FL2RootNodeText: TLabel
          Left = 128
          Top = 19
          Width = 6
          Height = 13
          Caption = '<'
        end
        object FL3RootNodeText: TLabel
          Left = 191
          Top = 19
          Width = 6
          Height = 13
          Caption = '>'
        end
        object FLRecordNode: TLabel
          Left = 8
          Top = 185
          Width = 73
          Height = 13
          Caption = 'FLRecordNode'
          FocusControl = FRecordNodeText
        end
        object FL2RecordTag: TLabel
          Left = 128
          Top = 185
          Width = 6
          Height = 13
          Caption = '<'
        end
        object FL3RecordTag: TLabel
          Left = 191
          Top = 185
          Width = 6
          Height = 13
          Caption = '>'
        end
        object FRootNodeText: TEdit
          Left = 134
          Top = 16
          Width = 57
          Height = 21
          CharCase = ecLowerCase
          TabOrder = 0
          Text = 'mysql'
          OnChange = TSXMLOptionChange
        end
        object PDatabaseNode: TPanel_Ext
          Left = 4
          Top = 48
          Width = 317
          Height = 57
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 4
          object FLDatabaseNode: TLabel
            Left = 4
            Top = 1
            Width = 84
            Height = 13
            Caption = 'FLDatabaseNode'
          end
          object FL1DatabaseTagFree: TLabel
            Left = 124
            Top = 37
            Width = 6
            Height = 13
            Caption = '<'
          end
          object FL2DatabaseNodeCustom: TLabel
            Left = 231
            Top = 37
            Width = 66
            Height = 13
            Caption = '="db_name">'
          end
          object FDatabaseNodeCustom: TRadioButton
            Left = 106
            Top = 36
            Width = 17
            Height = 17
            TabOrder = 2
            OnClick = FDatabaseNodeClick
            OnKeyPress = FDatabaseNodeKeyPress
          end
          object FDatabaseNodeText: TEdit
            Left = 130
            Top = 34
            Width = 57
            Height = 21
            CharCase = ecLowerCase
            TabOrder = 3
            Text = 'database'
            OnChange = TSXMLOptionChange
          end
          object FDatabaseNodeDisabled: TRadioButton
            Left = 106
            Top = 0
            Width = 185
            Height = 17
            Caption = 'FDatabaseNodeDisabled'
            Checked = True
            TabOrder = 0
            TabStop = True
            OnClick = FDatabaseNodeClick
            OnKeyPress = FDatabaseNodeKeyPress
          end
          object FDatabaseNodeName: TRadioButton
            Left = 106
            Top = 18
            Width = 185
            Height = 17
            Caption = '<db_name>'
            TabOrder = 1
            OnClick = FDatabaseNodeClick
            OnKeyPress = FDatabaseNodeKeyPress
          end
          object FDatabaseNodeAttribute: TEdit
            Left = 194
            Top = 34
            Width = 37
            Height = 21
            CharCase = ecLowerCase
            TabOrder = 4
            Text = 'name'
            OnChange = TSXMLOptionChange
          end
        end
        object PTableNode: TPanel_Ext
          Left = 4
          Top = 112
          Width = 317
          Height = 57
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 2
          object FLTableNode: TLabel
            Left = 4
            Top = 1
            Width = 65
            Height = 13
            Caption = 'FLTableNode'
          end
          object FL1TableNodeCustom: TLabel
            Left = 124
            Top = 37
            Width = 6
            Height = 13
            Caption = '<'
          end
          object FL2TableNodeCustom: TLabel
            Left = 231
            Top = 37
            Width = 65
            Height = 13
            Caption = '="tbl_name">'
          end
          object FTableNodeCustom: TRadioButton
            Left = 106
            Top = 36
            Width = 17
            Height = 17
            TabOrder = 2
            OnClick = FTableTagClick
            OnKeyPress = FTableTagKeyPress
          end
          object FTableNodeText: TEdit
            Left = 130
            Top = 34
            Width = 57
            Height = 21
            CharCase = ecLowerCase
            TabOrder = 3
            Text = 'table'
            OnChange = TSXMLOptionChange
          end
          object FTableNodeDisabled: TRadioButton
            Left = 106
            Top = 0
            Width = 185
            Height = 17
            Caption = 'FTableNodeDisabled'
            Checked = True
            TabOrder = 0
            TabStop = True
            OnClick = FTableTagClick
            OnKeyPress = FTableTagKeyPress
          end
          object FTableNodeName: TRadioButton
            Left = 106
            Top = 18
            Width = 185
            Height = 17
            Caption = '<tbl_name>'
            TabOrder = 1
            OnClick = FTableTagClick
            OnKeyPress = FTableTagKeyPress
          end
          object FTableNodeAttribute: TEdit
            Left = 194
            Top = 34
            Width = 37
            Height = 21
            CharCase = ecLowerCase
            TabOrder = 4
            Text = 'name'
            OnChange = TSXMLOptionChange
          end
        end
        object FRecordNodeText: TEdit
          Left = 134
          Top = 182
          Width = 57
          Height = 21
          CharCase = ecLowerCase
          TabOrder = 3
          Text = 'row'
          OnChange = TSXMLOptionChange
        end
        object PFieldNode: TPanel_Ext
          Left = 4
          Top = 216
          Width = 317
          Height = 41
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 1
          object FLFieldNode: TLabel
            Left = 4
            Top = 1
            Width = 60
            Height = 13
            Caption = 'FLFieldNode'
          end
          object FL1FieldNodeCustom: TLabel
            Left = 124
            Top = 19
            Width = 6
            Height = 13
            Caption = '<'
          end
          object FL2FieldNodeCustom: TLabel
            Left = 231
            Top = 19
            Width = 65
            Height = 13
            Caption = '="fld_name">'
          end
          object FFieldNodeCustom: TRadioButton
            Left = 106
            Top = 18
            Width = 17
            Height = 17
            Checked = True
            TabOrder = 1
            TabStop = True
            OnClick = FFieldTagClick
            OnKeyPress = FFieldTagKeyPress
          end
          object FFieldNodeText: TEdit
            Left = 130
            Top = 16
            Width = 57
            Height = 21
            CharCase = ecLowerCase
            TabOrder = 2
            Text = 'field'
            OnChange = TSXMLOptionChange
          end
          object FFieldNodeName: TRadioButton
            Left = 106
            Top = 0
            Width = 185
            Height = 17
            Caption = '<fld_name>'
            TabOrder = 0
            OnClick = FFieldTagClick
            OnKeyPress = FFieldTagKeyPress
          end
          object FFieldNodeAttribute: TEdit
            Left = 194
            Top = 16
            Width = 37
            Height = 21
            CharCase = ecLowerCase
            TabOrder = 3
            Text = 'name'
            OnChange = TSXMLOptionChange
          end
        end
      end
    end
    object TSHTMLOptions: TTabSheet
      Caption = 'TSHTMLOptions'
      TabVisible = False
      OnShow = TSHTMLOptionsShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        333
        271)
      object GHTMLWhat: TGroupBox_Ext
        Left = 4
        Top = 0
        Width = 325
        Height = 69
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GHTMLWhat'
        TabOrder = 0
        DesignSize = (
          325
          69)
        object FLHTMLWhat: TLabel
          Left = 8
          Top = 17
          Width = 68
          Height = 13
          Caption = 'FLHTMLWhat'
          FocusControl = FHTMLStructure
        end
        object FHTMLStructure: TCheckBox
          Left = 128
          Top = 16
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FHTMLStructure'
          TabOrder = 0
          OnClick = FHTMLStructureClick
          OnKeyPress = FHTMLStructureKeyPress
        end
        object FHTMLData: TCheckBox
          Left = 128
          Top = 40
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FHTMLData'
          TabOrder = 1
          OnClick = FHTMLDataClick
          OnKeyPress = FHTMLDataKeyPress
        end
      end
      object GHTMLOptions: TGroupBox_Ext
        Left = 5
        Top = 75
        Width = 325
        Height = 69
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GHTMLOptions'
        TabOrder = 1
        DesignSize = (
          325
          69)
        object FLHTMLNullValues: TLabel
          Left = 8
          Top = 17
          Width = 92
          Height = 13
          Caption = 'FLHTMLNullValues'
          FocusControl = FHTMLNullText
        end
        object FLHTMLViewDatas: TLabel
          Left = 8
          Top = 41
          Width = 93
          Height = 13
          Caption = 'FLHTMLViewDatas'
        end
        object FHTMLNullText: TCheckBox
          Left = 128
          Top = 16
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FHTMLNullText'
          TabOrder = 0
        end
        object FHTMLMemoContent: TCheckBox
          Left = 128
          Top = 40
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FHTMLMemoContent'
          TabOrder = 1
        end
      end
    end
    object TSFields: TTabSheet
      Caption = 'TSFields'
      TabVisible = False
      OnShow = TSFieldsShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        333
        271)
      object GFields: TGroupBox_Ext
        Left = 4
        Top = 0
        Width = 325
        Height = 265
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'GFields'
        TabOrder = 0
        DesignSize = (
          325
          265)
        object FLSourceFields: TLabel
          Left = 8
          Top = 24
          Width = 73
          Height = 13
          Caption = 'FLSourceFields'
        end
        object FLDestinationFields: TLabel
          Left = 172
          Top = 24
          Width = 92
          Height = 13
          Caption = 'FLDestinationFields'
        end
        object ScrollBox: TScrollBox
          Left = 4
          Top = 40
          Width = 318
          Height = 222
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelInner = bvNone
          BorderStyle = bsNone
          TabOrder = 0
          OnResize = ScrollBoxResize
          object FLReferrer1: TLabel
            Left = 149
            Top = 11
            Width = 9
            Height = 13
            Caption = '->'
            Visible = False
          end
          object FSourceField1: TComboBox_Ext
            Left = 4
            Top = 8
            Width = 135
            Height = 21
            Style = csDropDownList
            TabOrder = 0
            TabStop = False
            Visible = False
            OnChange = FSourceFieldChange
            OnExit = FSourceFieldExit
          end
          object FSourceField2: TComboBox_Ext
            Left = 4
            Top = 40
            Width = 135
            Height = 21
            Style = csDropDownList
            TabOrder = 1
            TabStop = False
            Visible = False
          end
          object FDestinationField1: TEdit
            Left = 168
            Top = 8
            Width = 117
            Height = 21
            TabStop = False
            TabOrder = 2
            Text = 'FDestinationField1'
            Visible = False
            OnChange = FDestinationFieldChange
          end
        end
      end
    end
    object TSExecute: TTabSheet
      Caption = 'TSExecute'
      TabVisible = False
      OnResize = TSExecuteResize
      OnShow = TSExecuteShow
      DesignSize = (
        333
        271)
      object GProgress: TGroupBox_Ext
        Left = 4
        Top = 0
        Width = 325
        Height = 169
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GProgress'
        TabOrder = 0
        DesignSize = (
          325
          169)
        object FLProgressObjects: TLabel
          Left = 8
          Top = 40
          Width = 89
          Height = 13
          Caption = 'FLProgressObjects'
        end
        object FLProgressRecords: TLabel
          Left = 8
          Top = 64
          Width = 93
          Height = 13
          Caption = 'FLProgressRecords'
        end
        object FDoneObjects: TLabel
          Left = 151
          Top = 40
          Width = 68
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FDoneObjects'
        end
        object FDoneRecords: TLabel
          Left = 147
          Top = 64
          Width = 72
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FDoneRecords'
        end
        object FLProgressTime: TLabel
          Left = 8
          Top = 88
          Width = 76
          Height = 13
          Caption = 'FLProgressTime'
        end
        object FDoneTime: TLabel
          Left = 164
          Top = 88
          Width = 55
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FDoneTime'
        end
        object FLDone: TLabel
          Left = 181
          Top = 16
          Width = 38
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FLDone'
        end
        object FLEntiered: TLabel
          Left = 263
          Top = 16
          Width = 51
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FLEntiered'
        end
        object FEntieredObjects: TLabel
          Left = 234
          Top = 40
          Width = 81
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FEntieredObjects'
        end
        object FEntieredRecords: TLabel
          Left = 230
          Top = 64
          Width = 85
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FEntieredRecords'
        end
        object FEntieredTime: TLabel
          Left = 247
          Top = 88
          Width = 68
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FEntieredTime'
        end
        object FLErrors: TLabel
          Left = 8
          Top = 148
          Width = 39
          Height = 13
          Caption = 'FLErrors'
        end
        object FErrors: TLabel
          Left = 281
          Top = 148
          Width = 33
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FErrors'
        end
        object FProgressBar: TProgressBar
          Left = 8
          Top = 120
          Width = 308
          Height = 16
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
        end
      end
      object GErrors: TGroupBox_Ext
        Left = 4
        Top = 176
        Width = 325
        Height = 89
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'GErrors'
        TabOrder = 1
        DesignSize = (
          325
          89)
        object PErrorMessages: TPanel_Ext
          Left = 8
          Top = 16
          Width = 308
          Height = 65
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelInner = bvRaised
          BevelOuter = bvLowered
          ParentBackground = False
          TabOrder = 0
          object FErrorMessages: TRichEdit
            Left = 2
            Top = 2
            Width = 304
            Height = 61
            TabStop = False
            Align = alClient
            BorderStyle = bsNone
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            ReadOnly = True
            ScrollBars = ssBoth
            TabOrder = 0
            WordWrap = False
          end
        end
      end
    end
  end
  object FBForward: TButton
    Left = 171
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBForward'
    Default = True
    TabOrder = 4
    OnClick = FBForwardClick
  end
  object FBCancel: TButton
    Left = 257
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 5
  end
  object FBBack: TButton
    Left = 96
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBBack'
    TabOrder = 3
    OnClick = FBBackClick
  end
  object FBHelp: TButton
    Left = 8
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'FBHelp'
    TabOrder = 2
    OnClick = FBHelpClick
  end
  object SaveDialog: TSaveDialog_Ext
    Options = [ofOverwritePrompt, ofHideReadOnly, ofExtensionDifferent, ofCreatePrompt, ofNoReadOnlyReturn, ofNoNetworkButton, ofEnableSizing]
    EncodingIndex = -1
    EncodingLabel = '&Encoding:'
    Left = 88
    Top = 288
  end
end

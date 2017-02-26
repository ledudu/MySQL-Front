object DImport: TDImport
  Left = 734
  Top = 156
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DImport'
  ClientHeight = 331
  ClientWidth = 341
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    341
    331)
  PixelsPerInch = 106
  TextHeight = 13
  object FBForward: TButton
    Left = 171
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBForward'
    Default = True
    TabOrder = 3
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
    TabOrder = 4
  end
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
    TabOrder = 5
    Visible = False
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 341
    Height = 281
    ActivePage = TSTables
    Anchors = [akLeft, akTop, akRight, akBottom]
    Style = tsButtons
    TabOrder = 0
    TabStop = False
    object TSTables: TTabSheet
      Caption = 'TSTables'
      TabVisible = False
      OnShow = TSTablesShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        333
        271)
      object GTables: TGroupBox_Ext
        Left = 4
        Top = 0
        Width = 325
        Height = 265
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'GTables'
        TabOrder = 0
        DesignSize = (
          325
          265)
        object PTables: TPanel_Ext
          Left = 8
          Top = 16
          Width = 310
          Height = 241
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelInner = bvRaised
          BevelOuter = bvLowered
          ParentBackground = False
          TabOrder = 0
          object FTables: TListView
            Left = 2
            Top = 2
            Width = 306
            Height = 237
            Align = alClient
            BorderStyle = bsNone
            Columns = <
              item
                Width = 304
              end>
            DoubleBuffered = True
            HideSelection = False
            MultiSelect = True
            ReadOnly = True
            ParentDoubleBuffered = False
            ShowColumnHeaders = False
            TabOrder = 0
            ViewStyle = vsList
            OnChange = FTablesChange
            OnDblClick = FTablesDblClick
            OnSelectItem = FTablesSelectItem
          end
        end
      end
    end
    object TSCSVOptions: TTabSheet
      Caption = 'TSCSVOptions'
      TabVisible = False
      OnShow = FCSVPreviewUpdate
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        333
        271)
      object GCSVHow: TGroupBox_Ext
        Left = 4
        Top = 0
        Width = 325
        Height = 137
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GCSVHow'
        TabOrder = 1
        DesignSize = (
          325
          137)
        object FLCSVHeadline: TLabel
          Left = 8
          Top = 17
          Width = 75
          Height = 13
          Caption = 'FLCSVHeadline'
        end
        object FCSVHeadline: TCheckBox
          Left = 128
          Top = 16
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FCSVHeadline'
          TabOrder = 0
          OnClick = FCSVPreviewUpdate
          OnKeyPress = FCSVKeyPress
        end
        object PDelimiter: TPanel_Ext
          Left = 4
          Top = 36
          Width = 317
          Height = 45
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 1
          object FLDelimiter: TLabel
            Left = 4
            Top = 6
            Width = 52
            Height = 13
            Caption = 'FLDelimiter'
          end
          object FDelimiterTab: TRadioButton
            Left = 124
            Top = 6
            Width = 193
            Height = 17
            Caption = 'FDelimiterTab'
            TabOrder = 0
            OnClick = FDelimiterClick
            OnKeyPress = FDelimiterKeyPress
          end
          object FDelimiterChar: TRadioButton
            Left = 124
            Top = 26
            Width = 81
            Height = 17
            Caption = 'FDelimiterChar'
            TabOrder = 1
            OnClick = FDelimiterClick
            OnKeyPress = FDelimiterKeyPress
          end
          object FDelimiter: TEdit
            Left = 204
            Top = 24
            Width = 17
            Height = 21
            MaxLength = 1
            TabOrder = 2
            Text = 'FDelimiter'
            OnChange = FCSVPreviewUpdate
          end
        end
        object PQuoting: TPanel_Ext
          Left = 4
          Top = 83
          Width = 317
          Height = 45
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 2
          object FLQuoteValues: TLabel
            Left = 4
            Top = 6
            Width = 73
            Height = 13
            Caption = 'FLQuoteValues'
          end
          object FQuoteStrings: TRadioButton
            Left = 124
            Top = 26
            Width = 193
            Height = 17
            Caption = 'FQuoteStrings'
            TabOrder = 0
            OnClick = FQuoteClick
            OnKeyPress = FQuoteKeyPress
          end
          object FQuoteChar: TEdit
            Left = 209
            Top = 24
            Width = 17
            Height = 21
            MaxLength = 1
            TabOrder = 1
            Text = 'FQuoteChar'
            OnChange = FCSVPreviewUpdate
          end
          object FQuoteNothing: TRadioButton
            Left = 125
            Top = 6
            Width = 193
            Height = 17
            Caption = 'FQuoteNothing'
            TabOrder = 2
            OnClick = FQuoteClick
            OnKeyPress = FQuoteKeyPress
          end
        end
        object Sizer: TRadioButton
          Left = 100
          Top = 16
          Width = 17
          Height = 17
          TabOrder = 3
          Visible = False
        end
      end
      object GCSVPreview: TGroupBox_Ext
        Left = 4
        Top = 143
        Width = 325
        Height = 125
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'GCSVPreview'
        TabOrder = 0
        DesignSize = (
          325
          125)
        object PCSVPreview: TPanel_Ext
          Left = 8
          Top = 16
          Width = 308
          Height = 99
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelInner = bvRaised
          BevelOuter = bvLowered
          ParentBackground = False
          TabOrder = 0
          object FCSVPreview: TListView
            Left = 2
            Top = 2
            Width = 304
            Height = 95
            Align = alClient
            BorderStyle = bsNone
            Columns = <>
            ColumnClick = False
            ReadOnly = True
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
          end
        end
      end
    end
    object TSWhat: TTabSheet
      Caption = 'TSWhat'
      TabVisible = False
      OnShow = TSWhatShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        333
        271)
      object GStructure: TGroupBox_Ext
        Left = 4
        Top = 76
        Width = 325
        Height = 161
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GStructure'
        TabOrder = 1
        DesignSize = (
          325
          161)
        object FLEngine: TLabel
          Left = 8
          Top = 23
          Width = 45
          Height = 13
          Caption = 'FLEngine'
          FocusControl = FEngine
        end
        object FLCharset: TLabel
          Left = 8
          Top = 59
          Width = 48
          Height = 13
          Caption = 'FLCharset'
          FocusControl = FCharset
        end
        object FLCollation: TLabel
          Left = 8
          Top = 95
          Width = 52
          Height = 13
          Caption = 'FLCollation'
          FocusControl = FCollation
        end
        object FLRowFormat: TLabel
          Left = 8
          Top = 131
          Width = 66
          Height = 13
          Caption = 'FLRowFormat'
          FocusControl = FRowFormat
        end
        object FEngine: TComboBox_Ext
          Left = 128
          Top = 20
          Width = 113
          Height = 21
          Style = csDropDownList
          TabOrder = 0
        end
        object FCharset: TComboBox_Ext
          Left = 128
          Top = 56
          Width = 113
          Height = 21
          Style = csDropDownList
          TabOrder = 1
          OnChange = FCharsetChange
        end
        object FCollation: TComboBox_Ext
          Left = 128
          Top = 92
          Width = 145
          Height = 21
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 2
        end
        object FRowFormat: TComboBox_Ext
          Left = 128
          Top = 128
          Width = 121
          Height = 21
          Style = csDropDownList
          TabOrder = 3
          Items.Strings = (
            ''
            'Fixed'
            'Dynamic'
            'Compressed'
            'Redundant'
            'Compact')
        end
      end
      object GWhat: TGroupBox_Ext
        Left = 4
        Top = 0
        Width = 325
        Height = 71
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GWhat'
        TabOrder = 0
        DesignSize = (
          325
          71)
        object FLWhat: TLabel
          Left = 8
          Top = 17
          Width = 38
          Height = 13
          Caption = 'FLWhat'
        end
        object FStructure: TCheckBox
          Left = 128
          Top = 16
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FStructure'
          TabOrder = 0
          OnClick = WhatClick
          OnKeyPress = WhatKeyPress
        end
        object FData: TCheckBox
          Left = 128
          Top = 42
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FData'
          TabOrder = 1
          OnClick = WhatClick
          OnKeyPress = WhatKeyPress
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
          Left = 156
          Top = 24
          Width = 92
          Height = 13
          Caption = 'FLDestinationFields'
        end
        object ScrollBox: TScrollBox
          Left = 4
          Top = 40
          Width = 318
          Height = 223
          Anchors = [akLeft, akTop, akRight, akBottom]
          BorderStyle = bsNone
          TabOrder = 0
          OnResize = ScrollBoxResize
          object FLReferrer1: TLabel
            Left = 131
            Top = 11
            Width = 9
            Height = 13
            Alignment = taCenter
            AutoSize = False
            Caption = '->'
            Visible = False
          end
          object FDestinationField1: TComboBox_Ext
            Left = 150
            Top = 8
            Width = 135
            Height = 21
            Style = csDropDownList
            TabOrder = 0
            Visible = False
            OnChange = FDestinationFieldChange
            OnExit = FFieldExit
          end
          object FSourceField1: TEdit
            Left = 4
            Top = 8
            Width = 117
            Height = 21
            TabOrder = 1
            Text = 'FSourceField1'
            Visible = False
            OnChange = FDestinationFieldChange
          end
          object FSourceField2: TEdit
            Left = 4
            Top = 40
            Width = 117
            Height = 21
            TabOrder = 2
            Text = 'FSourceField2'
            Visible = False
          end
        end
      end
    end
    object TSStmtType: TTabSheet
      Caption = 'TSStmtType'
      TabVisible = False
      OnShow = TSStmtTypeShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        333
        271)
      object GStmtType: TGroupBox_Ext
        Left = 4
        Top = 0
        Width = 325
        Height = 170
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GStmtType'
        TabOrder = 0
        DesignSize = (
          325
          170)
        object FLStmtType: TLabel
          Left = 8
          Top = 24
          Width = 57
          Height = 13
          Caption = 'FLStmtType'
        end
        object FLInsertUpdate: TLabel
          Left = 152
          Top = 144
          Width = 169
          Height = 13
          AutoSize = False
          Caption = 'FLInsertUpdate'
        end
        object FInsert: TRadioButton
          Left = 128
          Top = 24
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FInsert'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object FReplace: TRadioButton
          Left = 128
          Top = 56
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FReplace'
          TabOrder = 1
        end
        object FUpdate: TRadioButton
          Left = 128
          Top = 88
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FUpdate'
          TabOrder = 2
        end
        object FInsertOrUpdate: TRadioButton
          Left = 128
          Top = 120
          Width = 193
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FInsertOrUpdate'
          TabOrder = 3
        end
      end
    end
    object TSExecute: TTabSheet
      Caption = 'TSExecute'
      TabVisible = False
      OnResize = TSExecuteResize
      OnShow = TSExecuteShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        333
        271)
      object GErrorMessages: TGroupBox_Ext
        Left = 4
        Top = 176
        Width = 325
        Height = 89
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'GErrorMessages'
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
            Ctl3D = True
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            Lines.Strings = (
              'FErrorMessages')
            ParentCtl3D = False
            ParentFont = False
            ReadOnly = True
            ScrollBars = ssBoth
            TabOrder = 0
            WordWrap = False
          end
        end
      end
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
        object FLProgressTime: TLabel
          Left = 8
          Top = 88
          Width = 76
          Height = 13
          Caption = 'FLProgressTime'
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
        object FLProgressRecords: TLabel
          Left = 8
          Top = 64
          Width = 93
          Height = 13
          Caption = 'FLProgressRecords'
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
        object FEntieredRecords: TLabel
          Left = 230
          Top = 64
          Width = 85
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FEntieredRecords'
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
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FErrors'
        end
        object FLProgressObjects: TLabel
          Left = 8
          Top = 40
          Width = 89
          Height = 13
          Caption = 'FLProgressObjects'
          Color = clBtnFace
          ParentColor = False
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
        object FEntieredObjects: TLabel
          Left = 234
          Top = 40
          Width = 81
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FEntieredObjects'
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
    end
  end
  object FBBack: TButton
    Left = 96
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBBack'
    TabOrder = 2
    OnClick = FBBackClick
  end
  object FBHelp: TButton
    Left = 8
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'FBHelp'
    TabOrder = 1
    OnClick = FBHelpClick
  end
  object OpenDialog: TOpenDialog_Ext
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofNoNetworkButton, ofEnableSizing]
    EncodingIndex = -1
    EncodingLabel = '&Encoding:'
    Left = 296
    Top = 176
  end
end

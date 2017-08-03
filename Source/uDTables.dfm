object DTables: TDTables
  Left = 0
  Top = 0
  HelpContext = 1054
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DTable'
  ClientHeight = 377
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    337
    377)
  PixelsPerInch = 106
  TextHeight = 13
  object PSQLWait: TPanel
    Left = 8
    Top = 8
    Width = 321
    Height = 325
    Cursor = crHourGlass
    ParentCustomHint = False
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'PSQLWait'
    TabOrder = 0
    Visible = False
  end
  object FBOk: TButton
    Left = 167
    Top = 344
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBOk'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object FBCancel: TButton
    Left = 255
    Top = 344
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 3
  end
  object FBHelp: TButton
    Left = 8
    Top = 344
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'FBHelp'
    TabOrder = 1
    OnClick = FBHelpClick
  end
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 321
    Height = 325
    ActivePage = TSExtras
    Anchors = [akLeft, akTop, akRight, akBottom]
    HotTrack = True
    MultiLine = True
    TabOrder = 4
    object TSBasics: TTabSheet
      Caption = 'TSBasics'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        297)
      object GBasics: TGroupBox_Ext
        Left = 8
        Top = 8
        Width = 297
        Height = 169
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GBasics'
        TabOrder = 0
        DesignSize = (
          297
          169)
        object FLDatabase: TLabel
          Left = 8
          Top = 44
          Width = 58
          Height = 13
          Caption = 'FLDatabase'
        end
        object FLEngine: TLabel
          Left = 8
          Top = 79
          Width = 45
          Height = 13
          Caption = 'FLEngine'
          FocusControl = FEngine
        end
        object FLTablesCount: TLabel
          Left = 8
          Top = 20
          Width = 72
          Height = 13
          Caption = 'FLTablesCount'
        end
        object FTablesCount: TLabel
          Left = 120
          Top = 20
          Width = 66
          Height = 13
          Caption = 'FTablesCount'
        end
        object FLDefaultCharset: TLabel
          Left = 8
          Top = 109
          Width = 82
          Height = 13
          Caption = 'FLDefaultCharset'
          FocusControl = FDefaultCharset
        end
        object FLCollation: TLabel
          Left = 8
          Top = 135
          Width = 52
          Height = 13
          Caption = 'FLCollation'
          FocusControl = FCollation
        end
        object FEngine: TComboBox_Ext
          Left = 120
          Top = 76
          Width = 113
          Height = 21
          Style = csDropDownList
          TabOrder = 0
          OnChange = FBOkCheckEnabled
        end
        object FDefaultCharset: TComboBox_Ext
          Left = 120
          Top = 106
          Width = 89
          Height = 21
          Style = csDropDownList
          TabOrder = 1
          OnChange = FCharsetChange
        end
        object FCollation: TComboBox_Ext
          Left = 120
          Top = 132
          Width = 145
          Height = 21
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 2
          OnChange = FBOkCheckEnabled
        end
        object FDatabase: TEdit
          Left = 120
          Top = 44
          Width = 145
          Height = 21
          Enabled = False
          TabOrder = 3
          Text = 'FDatabase'
        end
      end
      object GRecords: TGroupBox_Ext
        Left = 8
        Top = 184
        Width = 297
        Height = 49
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GRecords'
        TabOrder = 1
        object FLRowType: TLabel
          Left = 8
          Top = 19
          Width = 58
          Height = 13
          Caption = 'FLRowType'
          FocusControl = FRowType
        end
        object FRowType: TComboBox_Ext
          Left = 120
          Top = 16
          Width = 97
          Height = 21
          Style = csDropDownList
          TabOrder = 0
          OnChange = FBOkCheckEnabled
          Items.Strings = (
            ''
            'Fixed'
            'Dynamic'
            'Compressed'
            'Redundant'
            'Compact')
        end
      end
    end
    object TSInformation: TTabSheet
      Caption = 'TSInformation'
      OnShow = TSInformationShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        297)
      object GDates: TGroupBox_Ext
        Left = 8
        Top = 8
        Width = 297
        Height = 71
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GDates'
        TabOrder = 0
        DesignSize = (
          297
          71)
        object FLCreated: TLabel
          Left = 8
          Top = 20
          Width = 49
          Height = 13
          Caption = 'FLCreated'
        end
        object FLUpdated: TLabel
          Left = 8
          Top = 44
          Width = 53
          Height = 13
          Caption = 'FLUpdated'
        end
        object FCreated: TLabel
          Left = 246
          Top = 20
          Width = 43
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FCreated'
        end
        object FUpdated: TLabel
          Left = 242
          Top = 44
          Width = 47
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FUpdated'
        end
      end
      object GSize: TGroupBox_Ext
        Left = 8
        Top = 88
        Width = 297
        Height = 71
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GSize'
        TabOrder = 1
        DesignSize = (
          297
          71)
        object FLIndexSize: TLabel
          Left = 8
          Top = 20
          Width = 58
          Height = 13
          Caption = 'FLIndexSize'
        end
        object FLDataSize: TLabel
          Left = 8
          Top = 44
          Width = 55
          Height = 13
          Caption = 'FLDataSize'
        end
        object FIndexSize: TLabel
          Left = 237
          Top = 20
          Width = 52
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FIndexSize'
        end
        object FDataSize: TLabel
          Left = 240
          Top = 44
          Width = 49
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FDataSize'
        end
      end
      object GRecordCount: TGroupBox_Ext
        Left = 8
        Top = 169
        Width = 297
        Height = 47
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GRecordCount'
        TabOrder = 2
        DesignSize = (
          297
          47)
        object FLRecordCount: TLabel
          Left = 8
          Top = 20
          Width = 75
          Height = 13
          Caption = 'FLRecordCount'
        end
        object FRecordCount: TLabel
          Left = 220
          Top = 20
          Width = 69
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FRecordCount'
        end
      end
    end
    object TSExtras: TTabSheet
      Caption = 'TSExtras'
      ParentShowHint = False
      ShowHint = True
      OnShow = TSExtrasShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        297)
      object GOptimize: TGroupBox_Ext
        Left = 8
        Top = 8
        Width = 297
        Height = 81
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GOptimize'
        TabOrder = 0
        DesignSize = (
          297
          81)
        object FLUnusedSize: TLabel
          Left = 8
          Top = 20
          Width = 69
          Height = 13
          Caption = 'FLUnusedSize'
        end
        object FUnusedSize: TLabel
          Left = 226
          Top = 20
          Width = 63
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FUnusedSize'
        end
        object FBOptimize: TButton
          Left = 168
          Top = 44
          Width = 122
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'FBOptimize'
          TabOrder = 0
          OnClick = FBOptimizeClick
        end
      end
      object GCheck: TGroupBox_Ext
        Left = 8
        Top = 96
        Width = 297
        Height = 81
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GCheck'
        TabOrder = 1
        DesignSize = (
          297
          81)
        object FLChecked: TLabel
          Left = 8
          Top = 20
          Width = 55
          Height = 13
          Caption = 'FLChecked'
        end
        object FChecked: TLabel
          Left = 240
          Top = 20
          Width = 49
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FChecked'
        end
        object FBCheck: TButton
          Left = 168
          Top = 44
          Width = 122
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'FBCheck'
          TabOrder = 0
          OnClick = FBCheckClick
        end
      end
      object GFlush: TGroupBox_Ext
        Left = 8
        Top = 188
        Width = 297
        Height = 53
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GFlush'
        TabOrder = 2
        DesignSize = (
          297
          53)
        object FBFlush: TButton
          Left = 168
          Top = 16
          Width = 121
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'FBFlush'
          TabOrder = 0
          OnClick = FBFlushClick
        end
      end
    end
    object TSSource: TTabSheet
      Caption = 'TSSource'
      OnShow = TSSourceShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        297)
      object FSource: TBCEditor
        Left = 13
        Top = 3
        Width = 297
        Height = 271
        ActiveLine.Visible = False
        Anchors = [akLeft, akTop, akRight, akBottom]
        CompletionProposal.CloseChars = '()[]. '
        CompletionProposal.Columns = <
          item
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Courier New'
            Font.Style = []
            Items = <>
            Title.Font.Charset = DEFAULT_CHARSET
            Title.Font.Color = clWindowText
            Title.Font.Height = -12
            Title.Font.Name = 'Courier New'
            Title.Font.Style = []
          end>
        CompletionProposal.Trigger.Chars = '.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        LeftMargin.Bookmarks.Visible = False
        LeftMargin.Colors.Foreground = clBlack
        LeftMargin.LineNumbers.DigitCount = 2
        LeftMargin.LineState.Enabled = False
        LeftMargin.Marks.Visible = False
        LeftMargin.MarksPanel.Visible = False
        LeftMargin.Width = 23
        PopupMenu = MSource
        ReadOnly = True
        SyncEdit.Enabled = False
        TabOrder = 0
      end
    end
  end
  object MSource: TPopupMenu
    Left = 104
    Top = 336
    object msCopy: TMenuItem
      Caption = 'aECopy'
      OnClick = msCopyClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object msSelectAll: TMenuItem
      Caption = 'aESelectAll'
    end
  end
end

object DDatabase: TDDatabase
  Left = 839
  Top = 666
  HelpContext = 1044
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DDatabase'
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
  OnCanResize = FormCanResize
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
    TabOrder = 4
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
    ActivePage = TSSource
    Anchors = [akLeft, akTop, akRight, akBottom]
    HotTrack = True
    MultiLine = True
    TabOrder = 3
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
        Height = 124
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GBasics'
        TabOrder = 0
        DesignSize = (
          297
          124)
        object FLName: TLabel
          Left = 8
          Top = 23
          Width = 40
          Height = 13
          Caption = 'FLName'
          FocusControl = FName
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
        object FName: TEdit
          Left = 120
          Top = 20
          Width = 145
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 64
          TabOrder = 0
          Text = 'FName'
          OnChange = FNameChange
        end
        object FCharset: TComboBox_Ext
          Left = 120
          Top = 56
          Width = 113
          Height = 21
          Style = csDropDownList
          TabOrder = 1
          OnChange = FCharsetChange
          OnExit = FCharsetExit
        end
        object FCollation: TComboBox_Ext
          Left = 120
          Top = 92
          Width = 145
          Height = 21
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 2
          OnChange = FCollationChange
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
        Height = 75
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GSize'
        TabOrder = 1
        DesignSize = (
          297
          75)
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
    end
    object TSExtras: TTabSheet
      Caption = 'TSExtras'
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
      DesignSize = (
        313
        297)
      object FSource: TSynMemo
        Left = 8
        Top = 8
        Width = 297
        Height = 270
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        PopupMenu = MSource
        TabOrder = 0
        CodeFolding.GutterShapeSize = 11
        CodeFolding.CollapsedLineColor = clGrayText
        CodeFolding.FolderBarLinesColor = clGrayText
        CodeFolding.IndentGuidesColor = clGray
        CodeFolding.IndentGuides = True
        CodeFolding.ShowCollapsedLine = False
        CodeFolding.ShowHintMark = True
        UseCodeFolding = False
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.Width = 0
        MaxScrollWidth = 65535
        Options = [eoAutoIndent, eoGroupUndo, eoHideShowScrollbars, eoNoCaret, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabsToSpaces, eoTrimTrailingSpaces]
        ReadOnly = True
        RightEdge = 0
        RightEdgeColor = clWindow
        ScrollHintFormat = shfTopToBottom
        WantReturns = False
        OnChange = FSourceChange
        FontSmoothing = fsmNone
      end
    end
  end
  object MSource: TPopupMenu
    Left = 96
    Top = 336
    object msCopy: TMenuItem
      Caption = 'msCopy'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object msSelectAll: TMenuItem
      Caption = 'aESelectAll'
    end
  end
end

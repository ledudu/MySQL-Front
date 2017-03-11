object DServer: TDServer
  Left = 487
  Top = 183
  HelpContext = 1091
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DServer'
  ClientHeight = 377
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    337
    377)
  PixelsPerInch = 106
  TextHeight = 13
  object FBCancel: TButton
    Left = 253
    Top = 344
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 2
  end
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 321
    Height = 321
    ActivePage = TSBasics
    Anchors = [akLeft, akTop, akRight, akBottom]
    HotTrack = True
    MultiLine = True
    TabOrder = 0
    object TSBasics: TTabSheet
      Caption = 'TSBasics'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        293)
      object GServer: TGroupBox_Ext
        Left = 8
        Top = 8
        Width = 296
        Height = 69
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GServer'
        TabOrder = 0
        DesignSize = (
          296
          69)
        object FLVersion: TLabel
          Left = 8
          Top = 20
          Width = 47
          Height = 13
          Caption = 'FLVersion'
        end
        object FLComment: TLabel
          Left = 8
          Top = 44
          Width = 56
          Height = 13
          Caption = 'FLComment'
        end
        object FVersion: TLabel
          Left = 120
          Top = 20
          Width = 165
          Height = 13
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'FVersion'
        end
        object FComment: TLabel
          Left = 120
          Top = 44
          Width = 165
          Height = 13
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'FComment'
        end
      end
      object GConnection: TGroupBox_Ext
        Left = 8
        Top = 84
        Width = 297
        Height = 117
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GConnection'
        TabOrder = 1
        DesignSize = (
          297
          117)
        object FLUser: TLabel
          Left = 8
          Top = 68
          Width = 34
          Height = 13
          Caption = 'FLUser'
        end
        object FLLibVersion: TLabel
          Left = 8
          Top = 44
          Width = 61
          Height = 13
          Caption = 'FLLibVersion'
        end
        object FLHost: TLabel
          Left = 8
          Top = 20
          Width = 34
          Height = 13
          Caption = 'FLHost'
        end
        object FUser: TLabel
          Left = 120
          Top = 68
          Width = 165
          Height = 13
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'FUser'
        end
        object FLibVersion: TLabel
          Left = 120
          Top = 44
          Width = 165
          Height = 13
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'FLibVersion'
        end
        object FHost: TLabel
          Left = 120
          Top = 20
          Width = 165
          Height = 13
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'FHost'
        end
        object FLThreadId: TLabel
          Left = 8
          Top = 92
          Width = 55
          Height = 13
          Caption = 'FLThreadId'
        end
        object FThreadId: TLabel
          Left = 120
          Top = 92
          Width = 165
          Height = 13
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'FThreadId'
        end
      end
    end
    object TSStartup: TTabSheet
      Caption = 'TSStartup'
      OnShow = TSStartupShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        293)
      object FStartup: TBCEditor
        Left = 8
        Top = 8
        Width = 297
        Height = 275
        Cursor = crIBeam
        ActiveLine.Indicator.Visible = False
        ActiveLine.Visible = False
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caret.Options = []
        CodeFolding.Hint.Font.Charset = DEFAULT_CHARSET
        CodeFolding.Hint.Font.Color = clWindowText
        CodeFolding.Hint.Font.Height = -12
        CodeFolding.Hint.Font.Name = 'Courier New'
        CodeFolding.Hint.Font.Style = []
        CodeFolding.Hint.Indicator.Glyph.Visible = False
        CodeFolding.Width = 16
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
        CompletionProposal.SecondaryShortCut = 0
        CompletionProposal.ShortCut = 16416
        CompletionProposal.Trigger.Chars = '.'
        CompletionProposal.Trigger.Enabled = False
        Directories.Colors = 'Colors'
        Directories.Highlighters = 'Highlighters'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        LeftMargin.Bookmarks.Visible = False
        LeftMargin.Font.Charset = DEFAULT_CHARSET
        LeftMargin.Font.Color = 13408665
        LeftMargin.Font.Height = -12
        LeftMargin.Font.Name = 'Courier New'
        LeftMargin.Font.Style = []
        LeftMargin.LineNumbers.DigitCount = 2
        LeftMargin.LineState.Enabled = False
        LeftMargin.Marks.Visible = False
        LeftMargin.MarksPanel.Visible = False
        LeftMargin.Width = 21
        Lines.Strings = (
          'FSource')
        LineSpacing = 0
        MatchingPair.Enabled = True
        Minimap.Font.Charset = DEFAULT_CHARSET
        Minimap.Font.Color = clWindowText
        Minimap.Font.Height = -1
        Minimap.Font.Name = 'Courier New'
        Minimap.Font.Style = []
        ReadOnly = True
        RightMargin.Visible = False
        Scroll.Options = [soPastEndOfLine, soWheelClickMove]
        SpecialChars.Style = scsDot
        SyncEdit.Enabled = False
        SyncEdit.ShortCut = 24650
        TabOrder = 0
        TokenInfo.Font.Charset = DEFAULT_CHARSET
        TokenInfo.Font.Color = clWindowText
        TokenInfo.Font.Height = -12
        TokenInfo.Font.Name = 'Courier New'
        TokenInfo.Font.Style = []
        TokenInfo.Title.Font.Charset = DEFAULT_CHARSET
        TokenInfo.Title.Font.Color = clWindowText
        TokenInfo.Title.Font.Height = -12
        TokenInfo.Title.Font.Name = 'Courier New'
        TokenInfo.Title.Font.Style = []
        UndoOptions = [uoGroupUndo]
        WordWrap.Indicator.Bitmap.Data = {
          7E030000424D7E0300000000000036000000280000000F0000000E0000000100
          2000000000004803000000000000000000000000000000000000FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
          000000000000000000000000000000000000FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0080000000FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000000000000000
          0000FF00FF00FF00FF00FF00FF00FF00FF008000000080000000FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF008000000080000000800000008000000080000000FF00
          FF00FF00FF00FF00FF00FF00FF00000000000000000000000000FF00FF00FF00
          FF00FF00FF00FF00FF008000000080000000FF00FF00FF00FF0080000000FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF0080000000FF00FF00FF00FF0080000000FF00FF00FF00
          FF00FF00FF000000000000000000000000000000000000000000FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF0080000000FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF0080000000FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00800000008000000080000000800000008000
          00008000000080000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00}
        WordWrap.Indicator.MaskColor = clFuchsia
      end
    end
    object TSPlugins: TTabSheet
      Caption = 'TSPlugins'
      OnShow = TSPluginsShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        293)
      object FPlugins: TListView
        Left = 8
        Top = 8
        Width = 296
        Height = 275
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            AutoSize = True
          end
          item
            AutoSize = True
          end>
        ReadOnly = True
        RowSelect = True
        SortType = stText
        TabOrder = 0
        ViewStyle = vsReport
        OnColumnClick = ListViewColumnClick
        OnCompare = ListViewCompare
      end
    end
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
  object MSource: TPopupMenu
    Left = 160
    Top = 336
    object msUndo: TMenuItem
      Caption = 'aEUndo'
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object msCut: TMenuItem
      Caption = 'aECut'
    end
    object msCopy: TMenuItem
      Caption = 'aECopy'
    end
    object msPaste: TMenuItem
      Caption = 'aEPaste'
    end
    object msDelete: TMenuItem
      Caption = 'aEDelete'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object msSelectAll: TMenuItem
      Caption = 'aESelectAll'
    end
  end
end

object DUser: TDUser
  Left = 831
  Top = 273
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DUser'
  ClientHeight = 294
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
    294)
  PixelsPerInch = 106
  TextHeight = 13
  object PSQLWait: TPanel
    Left = 8
    Top = 8
    Width = 321
    Height = 241
    Cursor = crHourGlass
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'PSQLWait'
    TabOrder = 0
    Visible = False
  end
  object FBCancel: TButton
    Left = 255
    Top = 260
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 4
  end
  object FBOk: TButton
    Left = 167
    Top = 260
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBOk'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 321
    Height = 241
    ActivePage = TSSource
    Anchors = [akLeft, akTop, akRight, akBottom]
    HotTrack = True
    MultiLine = True
    TabOrder = 1
    object TSBasics: TTabSheet
      Caption = 'TSBasics'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        213)
      object GBasics: TGroupBox_Ext
        Left = 8
        Top = 8
        Width = 297
        Height = 117
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GBasics'
        TabOrder = 0
        DesignSize = (
          297
          117)
        object FLName: TLabel
          Left = 8
          Top = 23
          Width = 40
          Height = 13
          Caption = 'FLName'
          FocusControl = FName
        end
        object FLPassword: TLabel
          Left = 8
          Top = 87
          Width = 58
          Height = 13
          Caption = 'FLPassword'
          FocusControl = FPassword
        end
        object FLHost: TLabel
          Left = 8
          Top = 55
          Width = 34
          Height = 13
          Caption = 'FLHost'
          FocusControl = FHost
        end
        object FPassword: TEdit
          Left = 128
          Top = 84
          Width = 97
          Height = 21
          MaxLength = 40
          TabOrder = 2
          Text = 'FPassword'
          OnChange = FBOkCheckEnabled
        end
        object FName: TEdit
          Left = 128
          Top = 20
          Width = 157
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 16
          TabOrder = 0
          Text = 'FName'
          OnChange = FBOkCheckEnabled
        end
        object FHost: TEdit
          Left = 128
          Top = 52
          Width = 157
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
          Text = 'FHost'
          OnChange = FBOkCheckEnabled
          OnExit = FHostExit
        end
      end
    end
    object TSRights: TTabSheet
      Caption = 'TSRights'
      OnShow = TSRightsShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        213)
      object FRights: TListView
        Left = 8
        Top = 8
        Width = 189
        Height = 195
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            AutoSize = True
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = FRightsDblClick
        OnSelectItem = FRightsSelectItem
      end
      object FBRightsNew: TButton
        Left = 208
        Top = 8
        Width = 95
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'FBRightsNew'
        TabOrder = 1
        OnClick = FBRightsNewClick
      end
      object FBRightsEdit: TButton
        Left = 208
        Top = 72
        Width = 95
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'FBRightsEdit'
        TabOrder = 3
        OnClick = FBRightsEditClick
      end
      object FBRightsDelete: TButton
        Left = 208
        Top = 40
        Width = 95
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'FBRightsDelete'
        TabOrder = 2
        OnClick = FBRightsDeleteClick
      end
    end
    object TSLimits: TTabSheet
      Caption = 'TSLimits'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        213)
      object GLimits: TGroupBox_Ext
        Left = 8
        Top = 8
        Width = 297
        Height = 145
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GLimits'
        TabOrder = 0
        object FLQueriesPerHour: TLabel
          Left = 8
          Top = 55
          Width = 87
          Height = 13
          Caption = 'FLQueriesPerHour'
          FocusControl = FQueriesPerHour
        end
        object FLUpdatesPerHour: TLabel
          Left = 8
          Top = 87
          Width = 91
          Height = 13
          Caption = 'FLUpdatesPerHour'
          FocusControl = FUpdatesPerHour
        end
        object FLConnectionsPerHour: TLabel
          Left = 8
          Top = 23
          Width = 110
          Height = 13
          Caption = 'FLConnectionsPerHour'
          FocusControl = FConnectionsPerHour
        end
        object FLUserConnections: TLabel
          Left = 8
          Top = 115
          Width = 93
          Height = 13
          Caption = 'FLUserConnections'
        end
        object FQueriesPerHour: TEdit
          Left = 232
          Top = 52
          Width = 41
          Height = 21
          TabOrder = 2
          Text = '0'
          OnChange = FBOkCheckEnabled
        end
        object FUpdatesPerHour: TEdit
          Left = 232
          Top = 84
          Width = 41
          Height = 21
          TabOrder = 4
          Text = '0'
          OnChange = FBOkCheckEnabled
        end
        object FConnectionsPerHour: TEdit
          Left = 232
          Top = 20
          Width = 41
          Height = 21
          TabOrder = 0
          Text = '0'
          OnChange = FBOkCheckEnabled
        end
        object FUDQueriesPerHour: TUpDown
          Left = 273
          Top = 52
          Width = 15
          Height = 21
          Associate = FQueriesPerHour
          TabOrder = 3
        end
        object FUDUpdatesPerHour: TUpDown
          Left = 273
          Top = 84
          Width = 15
          Height = 21
          Associate = FUpdatesPerHour
          TabOrder = 5
        end
        object FUDConnectionsPerHour: TUpDown
          Left = 273
          Top = 20
          Width = 15
          Height = 21
          Associate = FConnectionsPerHour
          TabOrder = 1
        end
        object FUserConnections: TEdit
          Left = 232
          Top = 112
          Width = 41
          Height = 21
          TabOrder = 6
          Text = '0'
        end
        object FUDUserConnections: TUpDown
          Left = 273
          Top = 112
          Width = 15
          Height = 21
          Associate = FUserConnections
          TabOrder = 7
        end
      end
    end
    object TSSource: TTabSheet
      Caption = 'TSSource'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        213)
      object FSource: TBCEditor
        Left = 8
        Top = 8
        Width = 297
        Height = 187
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
  end
  object FBHelp: TButton
    Left = 8
    Top = 260
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'FBHelp'
    TabOrder = 2
    OnClick = FBHelpClick
  end
  object MSource: TPopupMenu
    Left = 88
    Top = 256
    object msCopy: TMenuItem
      Caption = 'aECopy'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object msSelectAll: TMenuItem
      Caption = 'aESelectAll'
    end
  end
end

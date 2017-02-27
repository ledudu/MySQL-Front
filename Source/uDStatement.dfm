object DStatement: TDStatement
  Left = 711
  Top = 381
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DStatement'
  ClientHeight = 307
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    337
    307)
  PixelsPerInch = 106
  TextHeight = 13
  object FBClose: TButton
    Left = 255
    Top = 274
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBClose'
    ModalResult = 2
    TabOrder = 1
  end
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 321
    Height = 255
    ActivePage = TSSource
    Anchors = [akLeft, akTop, akRight, akBottom]
    MultiLine = True
    TabOrder = 0
    object TSInformation: TTabSheet
      Caption = 'TSInformation'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        227)
      object GStatement: TGroupBox_Ext
        Left = 8
        Top = 88
        Width = 297
        Height = 121
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GStatement'
        TabOrder = 2
        object FLRowsAffected: TLabel
          Left = 8
          Top = 48
          Width = 79
          Height = 13
          Caption = 'FLRowsAffected'
        end
        object FRowsAffected: TLabel
          Left = 128
          Top = 48
          Width = 73
          Height = 13
          Caption = 'FRowsAffected'
        end
        object FLInfo: TLabel
          Left = 8
          Top = 72
          Width = 30
          Height = 13
          Caption = 'FLInfo'
        end
        object FInfo: TLabel
          Left = 128
          Top = 72
          Width = 24
          Height = 13
          Caption = 'FInfo'
        end
        object FLStatementTime: TLabel
          Left = 8
          Top = 24
          Width = 83
          Height = 13
          Caption = 'FLStatementTime'
        end
        object FStatementTime: TLabel
          Left = 128
          Top = 24
          Width = 77
          Height = 13
          Caption = 'FStatementTime'
        end
        object FLInsertId: TLabel
          Left = 8
          Top = 96
          Width = 47
          Height = 13
          Caption = 'FLInsertId'
        end
        object FInsertId: TLabel
          Left = 128
          Top = 96
          Width = 41
          Height = 13
          Caption = 'FInsertId'
        end
      end
      object GProcess: TGroupBox_Ext
        Left = 8
        Top = 88
        Width = 297
        Height = 97
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GProcess'
        TabOrder = 3
        object FLUser: TLabel
          Left = 8
          Top = 48
          Width = 34
          Height = 13
          Caption = 'FLUser'
        end
        object FLHost: TLabel
          Left = 8
          Top = 72
          Width = 34
          Height = 13
          Caption = 'FLHost'
        end
        object FUser: TLabel
          Left = 128
          Top = 48
          Width = 28
          Height = 13
          Caption = 'FUser'
        end
        object FHost: TLabel
          Left = 128
          Top = 72
          Width = 28
          Height = 13
          Caption = 'FHost'
        end
        object FLId: TLabel
          Left = 8
          Top = 24
          Width = 21
          Height = 13
          Caption = 'FLId'
        end
        object FId: TLabel
          Left = 128
          Top = 24
          Width = 15
          Height = 13
          Caption = 'FId'
        end
      end
      object GBasics: TGroupBox_Ext
        Left = 8
        Top = 8
        Width = 297
        Height = 73
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GBasics'
        TabOrder = 0
        object FLExecutionTime: TLabel
          Left = 8
          Top = 24
          Width = 82
          Height = 13
          Caption = 'FLExecutionTime'
        end
        object FExecutionTime: TLabel
          Left = 128
          Top = 24
          Width = 76
          Height = 13
          Caption = 'FExecutionTime'
        end
        object FLDatabase: TLabel
          Left = 8
          Top = 48
          Width = 58
          Height = 13
          Caption = 'FLDatabase'
        end
        object FDatabase: TLabel
          Left = 128
          Top = 48
          Width = 52
          Height = 13
          Caption = 'FDatabase'
        end
      end
      object GQuery: TGroupBox_Ext
        Left = 8
        Top = 88
        Width = 297
        Height = 53
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GQuery'
        TabOrder = 1
        object FLQueryTime: TLabel
          Left = 8
          Top = 24
          Width = 63
          Height = 13
          Caption = 'FLQueryTime'
        end
        object FQueryTime: TLabel
          Left = 128
          Top = 24
          Width = 57
          Height = 13
          Caption = 'FQueryTime'
        end
      end
    end
    object TSSource: TTabSheet
      Caption = 'TSSource'
      ParentShowHint = False
      ShowHint = True
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        227)
      object FSource: TBCEditor
        Left = 8
        Top = 8
        Width = 297
        Height = 203
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
  object MSource: TPopupMenu
    Left = 88
    Top = 264
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

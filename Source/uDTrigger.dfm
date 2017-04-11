object DTrigger: TDTrigger
  Left = 675
  Top = 362
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DTrigger'
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
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'PSQLWait'
    TabOrder = 0
    Visible = False
  end
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 321
    Height = 325
    ActivePage = TSBasics
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
        297)
      object GBasics: TGroupBox_Ext
        Left = 8
        Top = 8
        Width = 297
        Height = 273
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'GBasics'
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        DesignSize = (
          297
          273)
        object FLName: TLabel
          Left = 8
          Top = 27
          Width = 40
          Height = 13
          Caption = 'FLName'
          FocusControl = FName
        end
        object FLTiming: TLabel
          Left = 8
          Top = 65
          Width = 43
          Height = 13
          Caption = 'FLTiming'
        end
        object FLEvent: TLabel
          Left = 8
          Top = 113
          Width = 40
          Height = 13
          Caption = 'FLEvent'
        end
        object FLStatement: TLabel
          Left = 8
          Top = 176
          Width = 60
          Height = 13
          Caption = 'FLStatement'
          FocusControl = FStatement
        end
        object FName: TEdit
          Left = 120
          Top = 24
          Width = 145
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 64
          TabOrder = 3
          Text = 'FName'
          OnChange = FNameChange
        end
        object PTiming: TPanel_Ext
          Left = 120
          Top = 64
          Width = 173
          Height = 41
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 1
          object FBefore: TRadioButton
            Left = 0
            Top = 0
            Width = 161
            Height = 17
            Caption = 'FBefore'
            TabOrder = 0
            OnClick = FTimingClick
          end
          object FAfter: TRadioButton
            Left = 0
            Top = 20
            Width = 161
            Height = 17
            Caption = 'FAfter'
            TabOrder = 1
            OnClick = FTimingClick
            OnKeyPress = FTimingKeyPress
          end
        end
        object PEvent: TPanel_Ext
          Left = 120
          Top = 112
          Width = 173
          Height = 57
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 2
          object FInsert: TRadioButton
            Left = 0
            Top = 0
            Width = 161
            Height = 17
            Caption = 'FInsert'
            TabOrder = 0
            OnClick = FEventClick
            OnKeyPress = FEventKeyPress
          end
          object FUpdate: TRadioButton
            Left = 0
            Top = 20
            Width = 161
            Height = 17
            Caption = 'FUpdate'
            TabOrder = 1
            OnClick = FEventClick
            OnKeyPress = FEventKeyPress
          end
          object FDelete: TRadioButton
            Left = 0
            Top = 40
            Width = 161
            Height = 17
            Caption = 'FDelete'
            TabOrder = 2
            OnClick = FEventClick
            OnKeyPress = FEventKeyPress
          end
        end
        object FStatement: TBCEditor
          Left = 8
          Top = 192
          Width = 281
          Height = 73
          ActiveLine.Indicator.Visible = False
          ActiveLine.Visible = False
          Anchors = [akLeft, akTop, akRight, akBottom]
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
          CompletionProposal.Trigger.Chars = '.'
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
          RightMargin.Visible = False
          Scroll.Options = [soPastEndOfLine, soWheelClickMove]
          SyncEdit.Enabled = False
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
        end
      end
    end
    object TSInformation: TTabSheet
      Caption = 'TSInformation'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        297)
      object GDefiner: TGroupBox_Ext
        Left = 8
        Top = 8
        Width = 297
        Height = 49
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GDefiner'
        TabOrder = 0
        DesignSize = (
          297
          49)
        object FLDefiner: TLabel
          Left = 8
          Top = 20
          Width = 46
          Height = 13
          Caption = 'FLDefiner'
        end
        object FDefiner: TLabel
          Left = 249
          Top = 20
          Width = 40
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FDefiner'
        end
      end
      object GSize: TGroupBox_Ext
        Left = 8
        Top = 64
        Width = 297
        Height = 49
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GSize'
        TabOrder = 1
        DesignSize = (
          297
          49)
        object FLSize: TLabel
          Left = 8
          Top = 20
          Width = 32
          Height = 13
          Caption = 'FLSize'
        end
        object FSize: TLabel
          Left = 263
          Top = 20
          Width = 26
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FSize'
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
        297)
      object FSource: TBCEditor
        Left = 8
        Top = 8
        Width = 297
        Height = 273
        ActiveLine.Indicator.Visible = False
        ActiveLine.Visible = False
        Anchors = [akLeft, akTop, akRight, akBottom]
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
        CompletionProposal.Trigger.Chars = '.'
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
        ReadOnly = True
        RightMargin.Visible = False
        Scroll.Options = [soPastEndOfLine, soWheelClickMove]
        SyncEdit.Enabled = False
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
      end
    end
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
    TabOrder = 3
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
    TabOrder = 2
    OnClick = FBHelpClick
  end
  object MSource: TPopupMenu
    Left = 96
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
      Caption = 'aESelectAl'
    end
  end
end

object DView: TDView
  Left = 720
  Top = 154
  HelpContext = 1098
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DView'
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
        279)
      object GBasics: TGroupBox_Ext
        Left = 8
        Top = 4
        Width = 297
        Height = 259
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'GBasics'
        TabOrder = 0
        DesignSize = (
          297
          259)
        object FLAlgorithm: TLabel
          Left = 8
          Top = 67
          Width = 55
          Height = 13
          Caption = 'FLAlgorithm'
          FocusControl = FAlgorithm
        end
        object FLCheckOption: TLabel
          Left = 8
          Top = 143
          Width = 74
          Height = 13
          Caption = 'FLCheckOption'
        end
        object FLStmt: TLabel
          Left = 8
          Top = 208
          Width = 33
          Height = 13
          Caption = 'FLStmt'
          FocusControl = FStatement
        end
        object FLName: TLabel
          Left = 8
          Top = 27
          Width = 40
          Height = 13
          Caption = 'FLName'
        end
        object FLSecurity: TLabel
          Left = 8
          Top = 97
          Width = 50
          Height = 13
          Caption = 'FLSecurity'
        end
        object FAlgorithm: TComboBox
          Left = 120
          Top = 64
          Width = 145
          Height = 21
          Style = csDropDownList
          TabOrder = 1
          OnSelect = FAlgorithmSelect
        end
        object FStatement: TBCEditor
          Left = 8
          Top = 224
          Width = 281
          Height = 27
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
          Minimap.Font.Charset = DEFAULT_CHARSET
          Minimap.Font.Color = clWindowText
          Minimap.Font.Height = -1
          Minimap.Font.Name = 'Courier New'
          Minimap.Font.Style = []
          OnChange = FStatementChange
          RightMargin.Visible = False
          Scroll.Options = [soPastEndOfLine, soWheelClickMove]
          SyncEdit.Enabled = False
          TabOrder = 7
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
        object FCheckOptionCascade: TCheckBox
          Left = 136
          Top = 164
          Width = 153
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FCheckOptionCascade'
          TabOrder = 5
          OnClick = FCheckOptionCascadeClick
          OnKeyPress = FCheckOptionCascadeKeyPress
        end
        object FCheckOptionLocal: TCheckBox
          Left = 136
          Top = 184
          Width = 153
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FCheckOptionLocal'
          TabOrder = 6
          OnClick = FCheckOptionLocalClick
          OnKeyPress = FCheckOptionLocalKeyPress
        end
        object FCheckOption: TCheckBox
          Left = 120
          Top = 142
          Width = 169
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FCheckOption'
          TabOrder = 4
          OnClick = FCheckOptionClick
          OnKeyPress = FCheckOptionKeyPress
        end
        object FName: TEdit
          Left = 120
          Top = 24
          Width = 145
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          Text = 'FName'
          OnChange = FNameChange
        end
        object FSecurityDefiner: TRadioButton
          Left = 120
          Top = 96
          Width = 169
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FSecurityDefiner'
          TabOrder = 2
          OnClick = FSecurityClick
          OnKeyPress = FSecurityKeyPress
        end
        object FSecurityInvoker: TRadioButton
          Left = 120
          Top = 116
          Width = 169
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'FSecurityInvoker'
          TabOrder = 3
          OnClick = FSecurityClick
          OnKeyPress = FSecurityKeyPress
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
        279)
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
    end
    object TSFields: TTabSheet
      Caption = 'TSFields'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        279)
      object FFields: TListView
        Left = 8
        Top = 8
        Width = 297
        Height = 255
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            AutoSize = True
            Caption = 'Name'
          end
          item
            AutoSize = True
            Caption = 'Type'
          end
          item
            AutoSize = True
            Caption = 'NULL'
          end
          item
            AutoSize = True
            Caption = 'Default'
          end
          item
            AutoSize = True
            Caption = 'Extras'
          end
          item
            AutoSize = True
            Caption = 'Comment'
          end>
        ColumnClick = False
        HideSelection = False
        MultiSelect = True
        ReadOnly = True
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object TSDependencies: TTabSheet
      Caption = 'TSDependencies'
      OnShow = TSDependenciesShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        313
        279)
      object FDependencies: TListView
        Left = 13
        Top = 3
        Width = 297
        Height = 255
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            AutoSize = True
            Caption = 'Name'
          end
          item
            AutoSize = True
            Caption = 'Type'
          end>
        ColumnClick = False
        HideSelection = False
        ReadOnly = True
        TabOrder = 0
        ViewStyle = vsReport
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
        279)
      object FSource: TBCEditor
        Left = 8
        Top = 8
        Width = 297
        Height = 255
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
        Minimap.Font.Charset = DEFAULT_CHARSET
        Minimap.Font.Color = clWindowText
        Minimap.Font.Height = -1
        Minimap.Font.Name = 'Courier New'
        Minimap.Font.Style = []
        OnChange = FSourceChange
        OnSelectionChanged = FSourceSelectionChanged
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
      Caption = 'aESelectAll'
    end
  end
end

object DSequence: TDSequence
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DSequence'
  ClientHeight = 412
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    337
    412)
  PixelsPerInch = 106
  TextHeight = 14
  object PSQLWait: TPanel
    Left = 8
    Top = 8
    Width = 321
    Height = 360
    Cursor = crHourGlass
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'PSQLWait'
    TabOrder = 4
    Visible = False
  end
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 321
    Height = 360
    ActivePage = TSBasics
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object TSBasics: TTabSheet
      Caption = 'TSBasics'
      DesignSize = (
        313
        331)
      object GBasics: TGroupBox_Ext
        Left = 8
        Top = 4
        Width = 297
        Height = 316
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GBasics'
        TabOrder = 0
        DesignSize = (
          297
          316)
        object FLName: TLabel
          Left = 8
          Top = 27
          Width = 43
          Height = 14
          Caption = 'FLName'
        end
        object FLIncrement: TLabel
          Left = 8
          Top = 63
          Width = 69
          Height = 14
          Caption = 'FLIncrement'
          FocusControl = FIncrement
        end
        object FLMinValue: TLabel
          Left = 8
          Top = 93
          Width = 60
          Height = 14
          Caption = 'FLMinValue'
        end
        object FLMaxValue: TLabel
          Left = 8
          Top = 144
          Width = 63
          Height = 14
          Caption = 'FLMaxValue'
        end
        object FLCache: TLabel
          Left = 8
          Top = 224
          Width = 45
          Height = 14
          Caption = 'FLCache'
        end
        object FLStart: TLabel
          Left = 8
          Top = 199
          Width = 39
          Height = 14
          Caption = 'FLStart'
          FocusControl = FStart
        end
        object FLCycle: TLabel
          Left = 8
          Top = 280
          Width = 40
          Height = 14
          Caption = 'FLCycle'
          FocusControl = FCycle
        end
        object FName: TEdit
          Left = 120
          Top = 24
          Width = 145
          Height = 22
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          Text = 'FName'
        end
        object FPMinValue: TPanel
          Left = 120
          Top = 92
          Width = 170
          Height = 43
          BevelOuter = bvNone
          TabOrder = 2
          object FRNoMinValue: TRadioButton
            Left = 0
            Top = 0
            Width = 169
            Height = 17
            Caption = 'FRNoMinValue'
            TabOrder = 0
            OnClick = FRMinValueClick
            OnKeyPress = FRMinValueKeyPress
          end
          object FRMinValue: TRadioButton
            Left = 0
            Top = 22
            Width = 17
            Height = 17
            Caption = 'RadioButton2'
            TabOrder = 1
            OnClick = FRMinValueClick
            OnKeyPress = FRMinValueKeyPress
          end
          object FMinValue: TEdit
            Left = 19
            Top = 19
            Width = 146
            Height = 22
            TabOrder = 2
            Text = 'FMinValue'
            OnChange = FBOkCheckEnabled
          end
        end
        object FPMaxValue: TPanel
          Left = 120
          Top = 144
          Width = 170
          Height = 43
          BevelOuter = bvNone
          TabOrder = 3
          object FRNoMaxValue: TRadioButton
            Left = 0
            Top = 0
            Width = 169
            Height = 17
            Caption = 'FRNoMaxValue'
            TabOrder = 0
            OnClick = FRMaxValueClick
            OnKeyPress = FRMaxValueKeyPress
          end
          object FRMaxValue: TRadioButton
            Left = 0
            Top = 22
            Width = 17
            Height = 17
            Caption = 'RadioButton2'
            TabOrder = 1
            OnClick = FRMaxValueClick
            OnKeyPress = FRMaxValueKeyPress
          end
          object FMaxValue: TEdit
            Left = 19
            Top = 19
            Width = 146
            Height = 22
            TabOrder = 2
            Text = 'FMaxValue'
            OnChange = FBOkCheckEnabled
          end
        end
        object FPCache: TPanel
          Left = 120
          Top = 224
          Width = 170
          Height = 43
          BevelOuter = bvNone
          TabOrder = 5
          object FRNoCache: TRadioButton
            Left = 0
            Top = 0
            Width = 169
            Height = 17
            Caption = 'FRNoCache'
            TabOrder = 0
            OnClick = FRCacheClick
            OnKeyPress = FRCacheKeyPress
          end
          object FRCache: TRadioButton
            Left = 0
            Top = 22
            Width = 17
            Height = 17
            Caption = 'RadioButton2'
            TabOrder = 1
            OnClick = FRCacheClick
            OnKeyPress = FRCacheKeyPress
          end
          object FCache: TEdit
            Left = 19
            Top = 19
            Width = 146
            Height = 22
            TabOrder = 2
            Text = 'FCache'
            OnChange = FBOkCheckEnabled
          end
        end
        object FIncrement: TEdit
          Left = 120
          Top = 60
          Width = 121
          Height = 22
          TabOrder = 1
          Text = 'FIncrement'
          OnChange = FBOkCheckEnabled
        end
        object FStart: TEdit
          Left = 120
          Top = 196
          Width = 121
          Height = 22
          TabOrder = 4
          Text = 'FStart'
          OnChange = FBOkCheckEnabled
        end
        object FCycle: TCheckBox
          Left = 120
          Top = 280
          Width = 169
          Height = 17
          Caption = 'FCycle'
          TabOrder = 6
          OnClick = FBOkCheckEnabled
          OnKeyPress = FCycleKeyPress
        end
      end
    end
    object TSDependencies: TTabSheet
      Caption = 'TSDependencies'
      ImageIndex = 2
      OnShow = TSDependenciesShow
      DesignSize = (
        313
        331)
      object FDependencies: TListView
        Left = 8
        Top = 8
        Width = 297
        Height = 316
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
      ImageIndex = 1
      DesignSize = (
        313
        331)
      object FSource: TSynMemo
        Left = 8
        Top = 8
        Width = 297
        Height = 316
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
        Options = [eoAutoIndent, eoGroupUndo, eoHideShowScrollbars, eoNoCaret, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabsToSpaces, eoTrimTrailingSpaces]
        ReadOnly = True
        RightEdge = 0
        RightEdgeColor = clWindow
        ScrollHintFormat = shfTopToBottom
        WantReturns = False
        FontSmoothing = fsmNone
      end
    end
  end
  object FBHelp: TButton
    Left = 8
    Top = 379
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'FBHelp'
    TabOrder = 1
    OnClick = FBHelpClick
  end
  object FBOk: TButton
    Left = 167
    Top = 379
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
    Top = 379
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 3
  end
  object MSource: TPopupMenu
    Left = 96
    Top = 344
    object msCopy: TMenuItem
      Caption = 'aECopy'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object msSelectAll: TMenuItem
      Caption = 'aSelectAll'
    end
  end
end

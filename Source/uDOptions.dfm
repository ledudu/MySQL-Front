object DOptions: TDOptions
  Left = 694
  Top = 207
  HelpContext = 1066
  BorderStyle = bsDialog
  Caption = 'DOptions'
  ClientHeight = 409
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 106
  TextHeight = 13
  object FBOk: TButton
    Left = 206
    Top = 376
    Width = 75
    Height = 25
    Caption = 'FBOk'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object FBCancel: TButton
    Left = 294
    Top = 376
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 3
  end
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 362
    Height = 345
    ActivePage = TSView
    HotTrack = True
    MultiLine = True
    TabOrder = 0
    object TSView: TTabSheet
      Caption = 'TSView'
      OnResize = TSViewResize
      object GProgram: TGroupBox_Ext
        Left = 4
        Top = 4
        Width = 345
        Height = 50
        Caption = 'GProgram'
        TabOrder = 0
        object FLLanguage: TLabel
          Left = 8
          Top = 19
          Width = 97
          Height = 13
          AutoSize = False
          Caption = 'FLLanguage'
          FocusControl = FLanguage
        end
        object FLanguage: TComboBox_Ext
          Left = 144
          Top = 16
          Width = 137
          Height = 21
          Style = csDropDownList
          DropDownCount = 40
          Sorted = True
          TabOrder = 0
          OnChange = FLanguageChange
        end
        object FBLanguage: TButton
          Left = 278
          Top = 16
          Width = 21
          Height = 21
          Caption = #183#183#183
          TabOrder = 1
          OnClick = FBLanguageClick
          OnKeyPress = FBLanguageKeyPress
        end
      end
      object GTabs: TGroupBox_Ext
        Left = 4
        Top = 62
        Width = 345
        Height = 44
        BiDiMode = bdLeftToRight
        Caption = 'GTabs'
        ParentBiDiMode = False
        TabOrder = 1
        object FLTabsVisible: TLabel
          Left = 8
          Top = 19
          Width = 66
          Height = 13
          Caption = 'FLTabsVisible'
        end
        object FTabsVisible: TCheckBox
          Left = 144
          Top = 18
          Width = 193
          Height = 17
          Caption = 'FTabsVisible'
          TabOrder = 0
        end
      end
      object GNavigator: TGroupBox
        Left = 4
        Top = 114
        Width = 345
        Height = 44
        Caption = 'GNavigator'
        TabOrder = 2
        object FLQuickAccessVisible: TLabel
          Left = 8
          Top = 19
          Width = 105
          Height = 13
          Caption = 'FLQuickAccessVisible'
        end
        object FQuickAccessVisible: TCheckBox
          Left = 144
          Top = 18
          Width = 193
          Height = 17
          Caption = 'FQuickAccessVisible'
          TabOrder = 0
        end
      end
    end
    object TSBrowser: TTabSheet
      Caption = 'TSBrowser'
      OnResize = TSBrowserResize
      object GGrid: TGroupBox_Ext
        Left = 4
        Top = 4
        Width = 345
        Height = 207
        Caption = 'GGrid'
        TabOrder = 0
        object FLGridFont: TLabel
          Left = 8
          Top = 19
          Width = 52
          Height = 13
          Caption = 'FLGridFont'
          FocusControl = FGridFont
        end
        object FLMaxColumnWidth: TLabel
          Left = 8
          Top = 53
          Width = 95
          Height = 13
          Caption = 'FLMaxColumnWidth'
          FocusControl = FMaxColumnWidth
        end
        object FLGridNullValues: TLabel
          Left = 8
          Top = 121
          Width = 81
          Height = 13
          Caption = 'FLGridNullValues'
          FocusControl = PGridNullBGColor
        end
        object FLViewDatas: TLabel
          Left = 8
          Top = 87
          Width = 63
          Height = 13
          Caption = 'FLViewDatas'
        end
        object FLGridCurrRowBGColor: TLabel
          Left = 8
          Top = 174
          Width = 111
          Height = 13
          Caption = 'FLGridCurrRowBGColor'
        end
        object FLMaxColumnWidthCharacters: TLabel
          Left = 200
          Top = 53
          Width = 146
          Height = 13
          Caption = 'FLMaxColumnWidthCharacters'
        end
        object FMaxColumnWidth: TEdit
          Left = 144
          Top = 50
          Width = 33
          Height = 21
          TabOrder = 3
          Text = '100'
        end
        object FUDMaxColumnWidth: TUpDown
          Left = 177
          Top = 50
          Width = 15
          Height = 21
          Associate = FMaxColumnWidth
          Min = 10
          Max = 1024
          Increment = 10
          Position = 100
          TabOrder = 4
        end
        object FGridFont: TEdit
          Left = 144
          Top = 16
          Width = 121
          Height = 21
          ReadOnly = True
          TabOrder = 0
          Text = 'FGridFont'
          OnClick = FBGridFontClick
          OnKeyPress = FGridFontKeyPress
        end
        object PGridFont: TPanel_Ext
          Left = 96
          Top = 16
          Width = 21
          Height = 21
          Caption = 'PGridFont'
          Enabled = False
          ParentBackground = False
          TabOrder = 1
          Visible = False
        end
        object FGridNullText: TCheckBox
          Left = 144
          Top = 146
          Width = 169
          Height = 17
          Caption = 'FGridNullText'
          TabOrder = 8
        end
        object FGridShowMemoContent: TCheckBox
          Left = 144
          Top = 86
          Width = 169
          Height = 17
          Caption = 'FGridShowMemoContent'
          TabOrder = 5
        end
        object PGridNullBGColorEnabled: TCheckBox
          Left = 144
          Top = 120
          Width = 30
          Height = 17
          TabOrder = 6
        end
        object PGridNullBGColor: TPanel_Ext
          Left = 162
          Top = 118
          Width = 49
          Height = 21
          BevelOuter = bvLowered
          ParentBackground = False
          TabOrder = 7
          OnClick = PGridNullBGColorClick
        end
        object FGridCurrRowBGColorEnabled: TCheckBox
          Left = 144
          Top = 174
          Width = 30
          Height = 17
          TabOrder = 9
        end
        object PGridCurrRowBGColor: TPanel_Ext
          Left = 162
          Top = 172
          Width = 49
          Height = 21
          BevelOuter = bvLowered
          ParentBackground = False
          TabOrder = 10
          OnClick = PGridCurrRowBGColorClick
        end
        object FBGridFont: TButton
          Left = 265
          Top = 16
          Width = 21
          Height = 21
          Caption = #183#183#183
          TabOrder = 2
          OnClick = FBGridFontClick
          OnKeyPress = FBGridFontKeyPress
        end
      end
    end
    object TSEditor: TTabSheet
      Caption = 'TSEditor'
      OnResize = TSEditorResize
      object GEditor: TGroupBox_Ext
        Left = 4
        Top = 4
        Width = 345
        Height = 140
        Caption = 'GEditor'
        TabOrder = 0
        object FLEditorFont: TLabel
          Left = 8
          Top = 19
          Width = 60
          Height = 13
          Caption = 'FLEditorFont'
          FocusControl = FEditorFont
        end
        object FLEditorCompletion: TLabel
          Left = 8
          Top = 84
          Width = 91
          Height = 13
          Caption = 'FLEditorCompletion'
          FocusControl = FEditorCompletionEnabled
        end
        object FLEditorCurrRowBGColor: TLabel
          Left = 8
          Top = 54
          Width = 119
          Height = 13
          Caption = 'FLEditorCurrRowBGColor'
          FocusControl = FEditorCurrRowBGColorEnabled
        end
        object FLEditorCompletionTime: TLabel
          Left = 224
          Top = 84
          Width = 114
          Height = 13
          Caption = 'FLEditorCompletionTime'
        end
        object FLEditorWordWrap: TLabel
          Left = 9
          Top = 114
          Width = 91
          Height = 13
          Caption = 'FLEditorWordWrap'
          FocusControl = FEditorWordWrap
        end
        object FEditorCurrRowBGColorEnabled: TCheckBox
          Left = 144
          Top = 53
          Width = 19
          Height = 17
          TabOrder = 3
        end
        object FEditorFont: TEdit
          Left = 144
          Top = 16
          Width = 121
          Height = 21
          ReadOnly = True
          TabOrder = 1
          Text = 'FEditorFont'
          OnClick = FBEditorFontClick
          OnKeyPress = FEditorFontKeyPress
        end
        object PEditorFont: TPanel_Ext
          Left = 112
          Top = 16
          Width = 21
          Height = 21
          Caption = 'PEditorFont'
          Enabled = False
          ParentBackground = False
          TabOrder = 0
          Visible = False
        end
        object FEditorCompletionEnabled: TCheckBox
          Left = 144
          Top = 83
          Width = 19
          Height = 17
          TabOrder = 5
        end
        object PEditorCurrRowBGColor: TPanel_Ext
          Left = 162
          Top = 51
          Width = 49
          Height = 21
          BevelOuter = bvLowered
          ParentBackground = False
          TabOrder = 4
          OnClick = PEditorCurrRowBGColorClick
        end
        object FEditorCompletionTime: TEdit
          Left = 162
          Top = 81
          Width = 41
          Height = 21
          TabOrder = 6
          Text = '1.000'
        end
        object FEditorWordWrap: TCheckBox
          Left = 144
          Top = 113
          Width = 198
          Height = 17
          Caption = 'FEditorWordWrap'
          TabOrder = 8
        end
        object FBEditorFont: TButton
          Left = 265
          Top = 16
          Width = 21
          Height = 21
          Caption = #183#183#183
          TabOrder = 2
          OnClick = FBEditorFontClick
          OnKeyPress = FEditorFontKeyPress
        end
        object FUDEditorCompletionTime: TUpDown
          Left = 203
          Top = 81
          Width = 15
          Height = 21
          Associate = FEditorCompletionTime
          Max = 5000
          Increment = 100
          Position = 1000
          TabOrder = 7
        end
      end
    end
    object TSLog: TTabSheet
      Caption = 'TSLog'
      OnResize = TSLogResize
      object GLog: TGroupBox_Ext
        Left = 4
        Top = 4
        Width = 345
        Height = 141
        Caption = 'GLog'
        TabOrder = 0
        object FLLogFont: TLabel
          Left = 8
          Top = 19
          Width = 51
          Height = 13
          Caption = 'FLLogFont'
          FocusControl = FLogFont
        end
        object FLLogLinenumbers: TLabel
          Left = 8
          Top = 53
          Width = 90
          Height = 13
          Caption = 'FLLogLinenumbers'
        end
        object FLLogSize: TLabel
          Left = 8
          Top = 111
          Width = 50
          Height = 13
          Caption = 'FLLogSize'
          FocusControl = FLogSize
        end
        object FL2LogSize: TLabel
          Left = 206
          Top = 112
          Width = 14
          Height = 13
          Caption = 'KB'
        end
        object PLogFont: TPanel_Ext
          Left = 112
          Top = 16
          Width = 21
          Height = 21
          Caption = 'PLogFont'
          Enabled = False
          ParentBackground = False
          TabOrder = 0
          Visible = False
        end
        object FLogFont: TEdit
          Left = 144
          Top = 16
          Width = 121
          Height = 21
          ReadOnly = True
          TabOrder = 1
          Text = 'FLogFont'
          OnClick = FBLogFontClick
          OnKeyPress = FLogFontKeyPress
        end
        object FLogSize: TEdit
          Left = 144
          Top = 108
          Width = 43
          Height = 21
          TabOrder = 5
          Text = '100'
        end
        object FLogTime: TCheckBox
          Left = 144
          Top = 52
          Width = 198
          Height = 17
          Caption = 'FLogTime'
          TabOrder = 3
        end
        object FLogResult: TCheckBox
          Left = 144
          Top = 76
          Width = 198
          Height = 17
          Caption = 'FLogResult'
          TabOrder = 4
        end
        object FUDLogSize: TUpDown
          Left = 187
          Top = 108
          Width = 15
          Height = 21
          Associate = FLogSize
          Max = 1000
          Increment = 100
          Position = 100
          TabOrder = 6
        end
        object FBLogFont: TButton
          Left = 265
          Top = 16
          Width = 21
          Height = 21
          Caption = #183#183#183
          TabOrder = 2
          OnClick = FBLogFontClick
          OnKeyPress = FBLogFontKeyPress
        end
      end
    end
  end
  object FBHelp: TButton
    Left = 7
    Top = 376
    Width = 75
    Height = 25
    Caption = 'FBHelp'
    TabOrder = 1
    OnClick = FBHelpClick
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [fdForceFontExist, fdNoOEMFonts]
    Left = 87
    Top = 368
  end
  object ColorDialog: TColorDialog
    Left = 119
    Top = 368
  end
end

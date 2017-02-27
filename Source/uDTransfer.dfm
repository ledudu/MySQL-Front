object DTransfer: TDTransfer
  Left = 689
  Top = 239
  HelpContext = 1094
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DTransfer'
  ClientHeight = 331
  ClientWidth = 445
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    445
    331)
  PixelsPerInch = 106
  TextHeight = 13
  object FBBack: TButton
    Left = 200
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBBack'
    TabOrder = 2
    OnClick = FBBackClick
  end
  object FBForward: TButton
    Left = 275
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBForward'
    Default = True
    TabOrder = 3
    OnClick = FBForwardClick
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 444
    Height = 281
    ActivePage = TSExecute
    Anchors = [akLeft, akTop, akRight, akBottom]
    Style = tsFlatButtons
    TabOrder = 0
    TabStop = False
    object TSSelect: TTabSheet
      Caption = 'TSSelect'
      TabVisible = False
      OnResize = TSSelectResize
      OnShow = TSSelectShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        436
        271)
      object GSource: TGroupBox_Ext
        Left = 4
        Top = 0
        Width = 210
        Height = 265
        Anchors = [akLeft, akTop, akBottom]
        Caption = 'GSource'
        DoubleBuffered = True
        ParentDoubleBuffered = False
        TabOrder = 0
        DesignSize = (
          210
          265)
        object PSource: TPanel_Ext
          Left = 8
          Top = 16
          Width = 194
          Height = 241
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelInner = bvRaised
          BevelOuter = bvLowered
          Caption = 'PSource'
          ParentBackground = False
          TabOrder = 0
          object FSource: TTreeView_Ext
            Left = 2
            Top = 2
            Width = 190
            Height = 237
            Align = alClient
            BorderStyle = bsNone
            DoubleBuffered = True
            HideSelection = False
            Indent = 19
            MultiSelect = True
            MultiSelectStyle = [msControlSelect, msShiftSelect, msSiblingOnly]
            ParentDoubleBuffered = False
            ReadOnly = True
            ShowLines = False
            TabOrder = 0
            OnChange = TreeViewChange
            OnChanging = FSourceChanging
            OnExpanding = TreeViewExpanding
            OnGetSelectedIndex = TreeViewGetSelectedIndex
          end
        end
      end
      object GDestination: TGroupBox_Ext
        Left = 222
        Top = 0
        Width = 210
        Height = 265
        Anchors = [akTop, akBottom]
        Caption = 'GDestination'
        DoubleBuffered = True
        ParentDoubleBuffered = False
        TabOrder = 1
        DesignSize = (
          210
          265)
        object PDestination: TPanel_Ext
          Left = 8
          Top = 16
          Width = 194
          Height = 241
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelInner = bvRaised
          BevelOuter = bvLowered
          ParentBackground = False
          TabOrder = 0
          object FDestination: TTreeView_Ext
            Left = 2
            Top = 2
            Width = 190
            Height = 237
            Align = alClient
            BorderStyle = bsNone
            DoubleBuffered = True
            HideSelection = False
            Indent = 19
            ParentDoubleBuffered = False
            ReadOnly = True
            ShowLines = False
            TabOrder = 0
            OnChange = TreeViewChange
            OnExpanding = TreeViewExpanding
            OnGetSelectedIndex = TreeViewGetSelectedIndex
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
        436
        271)
      object GWhat: TGroupBox
        Left = 4
        Top = 0
        Width = 429
        Height = 69
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GWhat'
        TabOrder = 0
        object FLWhat: TLabel
          Left = 8
          Top = 17
          Width = 38
          Height = 13
          Caption = 'FLWhat'
        end
        object FStructure: TCheckBox
          Left = 216
          Top = 16
          Width = 208
          Height = 17
          Caption = 'FStructure'
          TabOrder = 0
          OnClick = FStructureClick
          OnKeyPress = FStructureKeyPress
        end
        object FData: TCheckBox
          Left = 216
          Top = 42
          Width = 208
          Height = 17
          Caption = 'FData'
          TabOrder = 1
          OnClick = FDataClick
          OnKeyPress = FDataKeyPress
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
        436
        271)
      object GProgress: TGroupBox
        Left = 4
        Top = 0
        Width = 429
        Height = 169
        Anchors = [akLeft, akTop, akRight]
        Caption = 'GProgress'
        TabOrder = 0
        DesignSize = (
          429
          169)
        object FLProgressObjects: TLabel
          Left = 8
          Top = 40
          Width = 89
          Height = 13
          Caption = 'FLProgressObjects'
        end
        object FLProgressRecords: TLabel
          Left = 8
          Top = 64
          Width = 93
          Height = 13
          Caption = 'FLProgressRecords'
        end
        object FDoneObjects: TLabel
          Left = 259
          Top = 40
          Width = 68
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FDoneObjects'
        end
        object FDoneRecords: TLabel
          Left = 255
          Top = 64
          Width = 72
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FDoneRecords'
        end
        object FLProgressTime: TLabel
          Left = 8
          Top = 88
          Width = 76
          Height = 13
          Caption = 'FLProgressTime'
        end
        object FDoneTime: TLabel
          Left = 272
          Top = 88
          Width = 55
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FDoneTime'
        end
        object FLDone: TLabel
          Left = 290
          Top = 16
          Width = 38
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FLDone'
        end
        object FLEntiered: TLabel
          Left = 370
          Top = 16
          Width = 51
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FLEntiered'
        end
        object FEntieredObjects: TLabel
          Left = 340
          Top = 40
          Width = 81
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FEntieredObjects'
        end
        object FEntieredRecords: TLabel
          Left = 336
          Top = 64
          Width = 85
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FEntieredRecords'
        end
        object FEntieredTime: TLabel
          Left = 353
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
          Left = 385
          Top = 148
          Width = 33
          Height = 13
          Alignment = taRightJustify
          Anchors = [akTop, akRight]
          Caption = 'FErrors'
        end
        object FProgressBar: TProgressBar
          Left = 8
          Top = 120
          Width = 413
          Height = 16
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
        end
      end
      object GErrorMessages: TGroupBox_Ext
        Left = 4
        Top = 176
        Width = 429
        Height = 89
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'GErrorMessages'
        TabOrder = 1
        DesignSize = (
          429
          89)
        object PErrorMessages: TPanel_Ext
          Left = 8
          Top = 16
          Width = 413
          Height = 65
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelInner = bvRaised
          BevelOuter = bvLowered
          ParentBackground = False
          TabOrder = 0
          object FErrorMessages: TRichEdit
            Left = 2
            Top = 2
            Width = 409
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
    end
  end
  object FBHelp: TButton
    Left = 8
    Top = 296
    Width = 75
    Height = 25
    HelpContext = 1089
    Anchors = [akLeft, akBottom]
    Caption = 'FBHelp'
    TabOrder = 1
    OnClick = FBHelpClick
  end
  object FBCancel: TButton
    Left = 361
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 4
  end
end

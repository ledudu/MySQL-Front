object DLanguage: TDLanguage
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'DLanguage'
  ClientHeight = 521
  ClientWidth = 535
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHide = FormHide
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    535
    521)
  PixelsPerInch = 106
  TextHeight = 13
  object FLMail: TLabel
    Left = 240
    Top = 443
    Width = 31
    Height = 13
    Caption = 'FLMail'
  end
  object StringGrid: TStringGrid
    Left = 8
    Top = 8
    Width = 519
    Height = 426
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 3
    DefaultRowHeight = 21
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goTabs, goAlwaysShowEditor]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnKeyDown = StringGridKeyDown
    OnKeyPress = StringGridKeyPress
    OnMouseMove = StringGridMouseMove
    OnSelectCell = StringGridSelectCell
  end
  object FBOk: TButton
    Left = 360
    Top = 488
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBOk'
    Default = True
    ModalResult = 1
    TabOrder = 5
  end
  object FBCancel: TButton
    Left = 452
    Top = 488
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 6
  end
  object FBPublish: TButton
    Left = 8
    Top = 488
    Width = 177
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'FBPublish'
    TabOrder = 4
    OnClick = FBPublishClick
  end
  object FFind: TEdit
    Left = 8
    Top = 440
    Width = 121
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 1
    OnChange = FFindChange
    OnEnter = FFindEnter
    OnExit = FFindExit
    OnKeyPress = FFindKeyPress
  end
  object TBFind: TToolBar
    Left = 128
    Top = 440
    Width = 25
    Height = 21
    Align = alNone
    Anchors = [akLeft, akBottom]
    Caption = 'TBFind'
    TabOrder = 2
    object FFindStart: TToolButton
      Left = 0
      Top = 0
      Caption = 'FFindStart'
      Enabled = False
      ImageIndex = 89
      OnClick = FFindStartClick
    end
  end
  object FMail: TEdit
    Left = 320
    Top = 440
    Width = 207
    Height = 21
    TabOrder = 3
  end
end

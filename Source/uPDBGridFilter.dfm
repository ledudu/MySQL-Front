object PDBGridFilter: TPDBGridFilter
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'PDBGridFilter'
  ClientHeight = 42
  ClientWidth = 357
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 106
  TextHeight = 14
  object FActive: TCheckBox
    Left = 8
    Top = 13
    Width = 17
    Height = 17
    TabOrder = 0
    OnClick = FActiveClick
    OnKeyPress = FActiveKeyPress
  end
  object FOperator: TComboBox
    Left = 31
    Top = 10
    Width = 74
    Height = 22
    AutoDropDown = True
    Style = csDropDownList
    TabOrder = 1
    OnChange = FOperatorChange
  end
  object FNull: TComboBox
    Left = 111
    Top = 10
    Width = 194
    Height = 22
    AutoDropDown = True
    Style = csDropDownList
    TabOrder = 2
    Items.Strings = (
      'NULL'
      'NOT NULL')
  end
  object FExtender: TButton
    Left = 324
    Top = 10
    Width = 22
    Height = 22
    Caption = '+'
    TabOrder = 3
  end
  object FText: TEdit
    Left = 111
    Top = 10
    Width = 194
    Height = 22
    TabOrder = 4
    Text = 'FText'
  end
end

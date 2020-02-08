object PObjectSearch: TPObjectSearch
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'PObjectSearch'
  ClientHeight = 217
  ClientWidth = 195
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  PixelsPerInch = 106
  TextHeight = 14
  object FLWhat: TLabel
    Left = 8
    Top = 8
    Width = 42
    Height = 14
    Caption = 'FLWhat'
  end
  object FLWhere: TLabel
    Left = 8
    Top = 154
    Width = 49
    Height = 14
    Caption = 'FLWhere'
  end
  object FDatabases: TCheckBox
    Left = 8
    Top = 28
    Width = 177
    Height = 17
    Caption = 'FDatabases'
    Checked = True
    State = cbChecked
    TabOrder = 0
  end
  object FTables: TCheckBox
    Left = 8
    Top = 48
    Width = 177
    Height = 17
    TabStop = False
    Caption = 'FTables'
    Checked = True
    State = cbChecked
    TabOrder = 1
  end
  object FRoutines: TCheckBox
    Left = 8
    Top = 68
    Width = 177
    Height = 17
    Caption = 'FRoutines'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object FEvents: TCheckBox
    Left = 8
    Top = 88
    Width = 177
    Height = 17
    Caption = 'FEvents'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object FFields: TCheckBox
    Left = 8
    Top = 108
    Width = 177
    Height = 17
    Caption = 'FFields'
    TabOrder = 4
  end
  object FTriggers: TCheckBox
    Left = 8
    Top = 128
    Width = 177
    Height = 17
    Caption = 'FTriggers'
    TabOrder = 5
  end
  object FName: TCheckBox
    Left = 8
    Top = 174
    Width = 177
    Height = 17
    Caption = 'FName'
    Checked = True
    State = cbChecked
    TabOrder = 6
  end
  object FComment: TCheckBox
    Left = 8
    Top = 194
    Width = 177
    Height = 17
    Caption = 'FComment'
    TabOrder = 7
  end
end

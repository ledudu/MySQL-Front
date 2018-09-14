object DSequence: TDSequence
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DSequence'
  ClientHeight = 377
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    337
    377)
  PixelsPerInch = 106
  TextHeight = 14
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 321
    Height = 325
    ActivePage = TSSource
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object TSBasics: TTabSheet
      Caption = 'TSBasics'
    end
    object TSSource: TTabSheet
      Caption = 'TSSource'
      ImageIndex = 1
    end
  end
  object Button1: TButton
    Left = 8
    Top = 344
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Button1'
    TabOrder = 1
  end
  object Button2: TButton
    Left = 167
    Top = 344
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Button2'
    TabOrder = 2
  end
  object Button3: TButton
    Left = 255
    Top = 344
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Button3'
    TabOrder = 3
  end
end

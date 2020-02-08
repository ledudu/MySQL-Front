object DODBC: TDODBC
  Left = 878
  Top = 561
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'DODBC'
  ClientHeight = 241
  ClientWidth = 327
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
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  DesignSize = (
    327
    241)
  PixelsPerInch = 106
  TextHeight = 13
  object FDataSources: TListView
    Left = 8
    Top = 8
    Width = 312
    Height = 186
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsNone
    Columns = <
      item
        AutoSize = True
      end>
    ReadOnly = True
    RowSelect = True
    ShowColumnHeaders = False
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = FDataSourcesChange
    OnDblClick = FDataSourcesDblClick
  end
  object FBManage: TButton
    Left = 8
    Top = 209
    Width = 121
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'FBManage'
    TabOrder = 1
    OnClick = FBManageClick
  end
  object FBOk: TButton
    Left = 155
    Top = 209
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'FBOk'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object FBCancel: TButton
    Left = 245
    Top = 209
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'FBCancel'
    ModalResult = 2
    TabOrder = 3
  end
end

object WWindow: TWWindow
  Left = 387
  Top = 161
  Caption = 'WWindow'
  ClientHeight = 450
  ClientWidth = 683
  Color = clBtnFace
  Constraints.MinHeight = 485
  Constraints.MinWidth = 560
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu
  OldCreateOrder = False
  Position = poDefault
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 106
  TextHeight = 14
  object PWorkSpace: TPanel_Ext
    Left = 0
    Top = 80
    Width = 683
    Height = 349
    Align = alClient
    BevelOuter = bvNone
    Color = clAppWorkSpace
    ParentBackground = False
    TabOrder = 2
  end
  object TabControl: TTabControl
    Left = 0
    Top = 52
    Width = 683
    Height = 28
    Align = alTop
    MultiLine = True
    PopupMenu = MTabControl
    TabHeight = 23
    TabOrder = 1
    TabStop = False
    Visible = False
    OnChange = TabControlChange
    OnChanging = TabControlChanging
    OnContextPopup = TabControlContextPopup
    OnDragDrop = TabControlDragDrop
    OnDragOver = TabControlDragOver
    OnEndDrag = TabControlEndDrag
    OnGetImageIndex = TabControlGetImageIndex
    OnMouseDown = TabControlMouseDown
    OnMouseMove = TabControlMouseMove
    OnResize = TabControlResize
    OnStartDrag = TabControlStartDrag
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 429
    Width = 683
    Height = 21
    Panels = <
      item
        Text = 'sbMessage'
        Width = 200
      end
      item
        Text = 'sbItem'
        Width = 50
      end
      item
        Text = 'sbSummarize'
        Width = 50
      end
      item
        Bevel = pbNone
        Text = 'sbEdge'
        Width = 23
      end>
    ParentFont = True
    UseSystemFont = False
  end
  object CToolBar: TCoolBar
    Left = 0
    Top = 0
    Width = 683
    Height = 52
    AutoSize = True
    BandBorderStyle = bsNone
    BandMaximize = bmNone
    Bands = <
      item
        Break = False
        Control = ToolBar
        FixedSize = True
        ImageIndex = -1
        MinHeight = 52
        Width = 691
      end>
    EdgeInner = esNone
    EdgeOuter = esNone
    object ToolBar: TToolBar
      Left = 0
      Top = 0
      Width = 691
      Height = 52
      AutoSize = True
      TabOrder = 0
      Transparent = True
      object tbVRefresh: TToolButton
        Left = 0
        Top = 0
        Action = aVRefresh
      end
      object tbDCancel: TToolButton
        Left = 23
        Top = 0
        Action = aDCancel
      end
      object ToolButton30: TToolButton
        Left = 46
        Top = 0
        Width = 8
        Caption = 'ToolButton30'
        Enabled = False
        Style = tbsSeparator
      end
      object tbECut: TToolButton
        Left = 54
        Top = 0
        Action = aECut
      end
      object tbECopy: TToolButton
        Left = 77
        Top = 0
        Action = aECopy
      end
      object tbEPaste: TToolButton
        Left = 100
        Top = 0
        Action = aEPaste
      end
      object tbEDelete: TToolButton
        Left = 123
        Top = 0
        Action = aEDelete
      end
      object ToolButton11: TToolButton
        Left = 146
        Top = 0
        Width = 8
        Caption = 'ToolButton11'
        Enabled = False
        Style = tbsSeparator
      end
      object tbCreateDatabase: TToolButton
        Left = 154
        Top = 0
        Action = aDCreateDatabase
      end
      object tbDeleteDatabase: TToolButton
        Left = 177
        Top = 0
        Action = aDDeleteDatabase
      end
      object ToolButton14: TToolButton
        Left = 200
        Top = 0
        Width = 8
        Caption = 'ToolButton14'
        Enabled = False
        Style = tbsSeparator
      end
      object tbCreateTable: TToolButton
        Left = 208
        Top = 0
        Action = aDCreateTable
      end
      object tbDeleteTable: TToolButton
        Left = 231
        Top = 0
        Action = aDDeleteTable
      end
      object ToolButton12: TToolButton
        Left = 254
        Top = 0
        Width = 8
        Caption = 'ToolButton12'
        Enabled = False
        Style = tbsSeparator
      end
      object tbCreateIndex: TToolButton
        Left = 262
        Top = 0
        Action = aDCreateKey
      end
      object tbDeleteIndex: TToolButton
        Left = 285
        Top = 0
        Action = aDDeleteKey
      end
      object ToolButton15: TToolButton
        Left = 308
        Top = 0
        Width = 8
        Caption = 'ToolButton15'
        Enabled = False
        Style = tbsSeparator
      end
      object tbCreateField: TToolButton
        Left = 316
        Top = 0
        Action = aDCreateField
      end
      object tbDeleteField: TToolButton
        Left = 339
        Top = 0
        Action = aDDeleteField
      end
      object ToolButton16: TToolButton
        Left = 362
        Top = 0
        Width = 8
        Caption = 'ToolButton16'
        Enabled = False
        Style = tbsSeparator
      end
      object tbCreateForeignKey: TToolButton
        Left = 370
        Top = 0
        Action = aDCreateForeignKey
      end
      object tbDeleteForeignKey: TToolButton
        Left = 393
        Top = 0
        Action = aDDeleteForeignKey
      end
      object ToolButton5: TToolButton
        Left = 416
        Top = 0
        Width = 8
        Caption = 'ToolButton5'
        Enabled = False
        Style = tbsSeparator
      end
      object tbProperties: TToolButton
        Left = 424
        Top = 0
        Enabled = False
        ImageIndex = 11
        OnClick = tbPropertiesClick
      end
      object ToolButton2: TToolButton
        Left = 0
        Top = 0
        Width = 8
        Caption = 'ToolButton2'
        Enabled = False
        Wrap = True
        Style = tbsSeparator
      end
      object tbOpen: TToolButton
        Left = 0
        Top = 30
        Action = aFOpen
      end
      object tbSave: TToolButton
        Left = 23
        Top = 30
        Action = aFSave
      end
      object ToolButton4: TToolButton
        Left = 46
        Top = 30
        Width = 8
        Caption = 'ToolButton4'
        Enabled = False
        Style = tbsSeparator
      end
      object tbUndo: TToolButton
        Left = 54
        Top = 30
        Action = aEUndo
        Enabled = False
      end
      object tbRedo: TToolButton
        Left = 77
        Top = 30
        Action = aERedo
      end
      object ToolButton7: TToolButton
        Left = 100
        Top = 30
        Width = 8
        Caption = 'ToolButton7'
        Enabled = False
        Style = tbsSeparator
      end
      object tbSearchFind: TToolButton
        Left = 108
        Top = 30
        Action = aSSearchFind
      end
      object tbSearchReplace: TToolButton
        Left = 131
        Top = 30
        Action = aSSearchReplace
      end
      object ToolButton10: TToolButton
        Left = 154
        Top = 30
        Width = 8
        Caption = 'ToolButton10'
        Enabled = False
        Style = tbsSeparator
      end
      object tbRun: TToolButton
        Left = 162
        Top = 30
        Action = aDRun
      end
      object tbRunSelection: TToolButton
        Left = 185
        Top = 30
        Action = aDRunSelection
      end
      object tbPostObject: TToolButton
        Left = 208
        Top = 30
        Action = aDPostObject
      end
      object ToolButton13: TToolButton
        Left = 231
        Top = 30
        Width = 8
        Caption = 'ToolButton13'
        Enabled = False
        Style = tbsSeparator
      end
      object tbDBFirst: TToolButton
        Left = 239
        Top = 30
        Enabled = False
      end
      object tbDBPrev: TToolButton
        Left = 262
        Top = 30
        Enabled = False
      end
      object tbDBNext: TToolButton
        Left = 285
        Top = 30
        Enabled = False
      end
      object tbDBLast: TToolButton
        Left = 308
        Top = 30
        Enabled = False
      end
      object tbDInsertRecord: TToolButton
        Left = 331
        Top = 30
        Action = aDInsertRecord
      end
      object tbDDeleteRecord: TToolButton
        Left = 354
        Top = 30
        Action = aDDeleteRecord
      end
      object ToolButton23: TToolButton
        Left = 377
        Top = 30
        Width = 8
        Caption = 'ToolButton23'
        Style = tbsSeparator
      end
      object tbPostRecord: TToolButton
        Left = 385
        Top = 30
        Enabled = False
      end
      object tbCancelRecord: TToolButton
        Left = 408
        Top = 30
        Enabled = False
      end
      object ToolButton1: TToolButton
        Left = 431
        Top = 30
        Width = 8
        Caption = 'ToolButton1'
        Style = tbsSeparator
      end
      object tbFormatSQL: TToolButton
        Left = 439
        Top = 30
        Action = aEFormatSQL
      end
    end
  end
  object TBTabControl: TToolBar
    Left = 130
    Top = 80
    Width = 561
    Height = 22
    Align = alNone
    TabOrder = 0
    Transparent = False
    Visible = False
    object tcOpenAccount: TToolButton
      Left = 0
      Top = 0
      Action = aFOpenAccount
      ImageIndex = 15
    end
  end
  object ActionList: TActionList
    Left = 80
    Top = 240
    object aOGlobals: TAction
      Category = 'Options'
      Caption = 'aOGlobalSettings'
      HelpContext = 1066
      HelpType = htContext
      OnExecute = aOGlobalsExecute
    end
    object aOAccounts: TAction
      Category = 'Options'
      Caption = 'aOAccounts'
      HelpContext = 1065
      HelpType = htContext
      OnExecute = aOAccountsExecute
    end
    object aEFind: TAction
      Category = 'Extras'
      Caption = 'aEFind'
      OnExecute = aEFindExecute
    end
    object aEReplace: TAction
      Category = 'Extras'
      Caption = 'aEReplace'
      HelpContext = 1090
      HelpType = htContext
      OnExecute = aEReplaceExecute
    end
    object aETransfer: TAction
      Category = 'Extras'
      Caption = 'aETransfer'
      HelpType = htContext
      OnExecute = aETransferExecute
    end
    object aOImport: TAction
      Category = 'Options'
      Caption = 'aOImport'
      OnExecute = aOImportExecute
    end
    object aVObjects: TAction
      Category = 'View'
      Caption = 'aVObjects'
      Enabled = False
      HelpContext = 1035
      HelpType = htContext
      ImageIndex = 1
      ShortCut = 117
    end
    object aVBrowser: TAction
      Category = 'View'
      Caption = 'aVBrowser'
      Enabled = False
      HelpContext = 1036
      HelpType = htContext
      ImageIndex = 2
      ShortCut = 118
    end
    object aVIDE: TAction
      Category = 'View'
      Caption = 'aVIDE'
      Enabled = False
      HelpContext = 1121
      HelpType = htContext
      ImageIndex = 98
    end
    object aVBuilder: TAction
      Category = 'View'
      Caption = 'aVBuilder'
      Enabled = False
      HelpContext = 1120
      HelpType = htContext
      ImageIndex = 100
      ShortCut = 16503
    end
    object aVDiagram: TAction
      Category = 'View'
      Caption = 'aVDiagram'
      Enabled = False
      HelpContext = 1125
      ImageIndex = 99
    end
    object aVEditor: TAction
      Category = 'View'
      Caption = 'aVSQLEditor'
      Enabled = False
      HelpContext = 1037
      HelpType = htContext
      ImageIndex = 3
      ShortCut = 119
    end
    object aVEditor2: TAction
      Category = 'View'
      Caption = 'aVEditor2'
      Enabled = False
      HelpContext = 1037
      HelpType = htContext
      ImageIndex = 3
      ShortCut = 119
    end
    object aVEditor3: TAction
      Category = 'View'
      Caption = 'aVEditor3'
      Enabled = False
      HelpContext = 1037
      HelpType = htContext
      ImageIndex = 3
      ShortCut = 119
    end
    object aHIndex: TAction
      Category = 'Help'
      Caption = 'aHIndex'
      HelpContext = 1069
      HelpType = htContext
      ShortCut = 112
      OnExecute = aHIndexExecute
    end
    object aHManual: TAction
      Category = 'Help'
      Caption = 'aHManual'
      Enabled = False
      HelpContext = 1119
      HelpType = htContext
    end
    object aHSQL: TAction
      Category = 'Help'
      Caption = 'aHSQL'
      Enabled = False
      HelpContext = 1135
      HelpType = htContext
      ImageIndex = 14
    end
    object aHUpdate: TAction
      Category = 'Help'
      Caption = 'aHUpdate'
      HelpContext = 1073
      HelpType = htContext
      OnExecute = aHUpdateExecute
    end
    object aVNavigator: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'aVNavigator'
      Enabled = False
      HelpContext = 1038
      HelpType = htContext
      ImageIndex = 94
      ShortCut = 122
    end
    object aVExplorer: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'aVExplorer'
      Enabled = False
      HelpContext = 1108
      HelpType = htContext
      ImageIndex = 96
    end
    object aVSQLHistory: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'aVSQLHistory'
      Enabled = False
      HelpContext = 1112
      HelpType = htContext
      ImageIndex = 95
    end
    object aVSQLLog: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'aVSQLLog'
      Enabled = False
      HelpContext = 1039
      HelpType = htContext
      ShortCut = 16506
    end
    object aVRefresh: TAction
      Category = 'View'
      Caption = 'aVRefresh'
      Enabled = False
      ImageIndex = 22
      ShortCut = 116
    end
    object aVRefreshAll: TAction
      Category = 'View'
      Caption = 'aVRefreshAll'
      Enabled = False
      ImageIndex = 22
      ShortCut = 8308
    end
    object aVPrev: TAction
      Category = 'View'
      Caption = 'aVPrev'
      ImageIndex = 92
      ShortCut = 32805
    end
    object aVNext: TAction
      Category = 'View'
      Caption = 'aVNext'
      ImageIndex = 93
      ShortCut = 32807
    end
    object aFOpenAccount: TAction
      Category = 'File'
      Caption = 'aFOpenAccount'
      HelpContext = 1001
      HelpType = htContext
      ImageIndex = 40
      ShortCut = 123
      OnExecute = aFOpenAccountExecute
    end
    object aFOpen: TAction
      Category = 'File'
      Caption = 'aFOpen'
      Enabled = False
      HelpContext = 1006
      HelpType = htContext
      ImageIndex = 5
      ShortCut = 16463
    end
    object aFSave: TAction
      Category = 'File'
      Caption = 'aFSave'
      Enabled = False
      HelpContext = 1007
      HelpType = htContext
      ImageIndex = 6
      ShortCut = 16467
    end
    object aFSaveAs: TAction
      Category = 'File'
      Caption = 'aFSaveAs'
      Enabled = False
      HelpContext = 1008
      HelpType = htContext
    end
    object aFImportSQL: TAction
      Category = 'File'
      Caption = 'aFImportSQL'
      Enabled = False
      HelpContext = 1010
      HelpType = htContext
    end
    object aFImportText: TAction
      Category = 'File'
      Caption = 'aFImportText'
      Enabled = False
      HelpContext = 1133
      HelpType = htContext
    end
    object aFImportExcel: TAction
      Category = 'File'
      Caption = 'aFImportExcel'
      Enabled = False
      HelpContext = 1106
      HelpType = htContext
    end
    object aFImportAccess: TAction
      Category = 'File'
      Caption = 'aFImportAccess'
      Enabled = False
      HelpContext = 1013
      HelpType = htContext
    end
    object aFImportODBC: TAction
      Category = 'File'
      Caption = 'aFImportODBC'
      Enabled = False
      HelpContext = 1012
      HelpType = htContext
    end
    object aFExportSQL: TAction
      Category = 'File'
      Caption = 'aFExportSQL'
      Enabled = False
      HelpContext = 1014
      HelpType = htContext
    end
    object aFExportText: TAction
      Category = 'File'
      Caption = 'aFExportText'
      Enabled = False
      HelpContext = 1134
      HelpType = htContext
    end
    object aFExportExcel: TAction
      Category = 'File'
      Caption = 'aFExportExcel'
      Enabled = False
      HelpContext = 1107
      HelpType = htContext
    end
    object aFExportAccess: TAction
      Category = 'File'
      Caption = 'aFExportAccess'
      Enabled = False
      HelpContext = 1129
      HelpType = htContext
    end
    object aFExportODBC: TAction
      Category = 'File'
      Caption = 'aFExportODBC'
      Enabled = False
    end
    object aFExportXML: TAction
      Category = 'File'
      Caption = 'aFExportXML'
      Enabled = False
      HelpContext = 1017
      HelpType = htContext
    end
    object aFExportHTML: TAction
      Category = 'File'
      Caption = 'aFExportHTML'
      Enabled = False
      HelpContext = 1016
      HelpType = htContext
    end
    object aFExportPDF: TAction
      Category = 'File'
      Caption = 'aFExportPDF'
      Enabled = False
      HelpContext = 1137
      HelpType = htContext
    end
    object aFExportBitmap: TAction
      Category = 'File'
      Caption = 'aFExportBitmap'
      Enabled = False
    end
    object aESelectAll: TEditSelectAll
      Category = 'Edit'
      Caption = 'aESelectAll'
      HelpContext = 1028
      HelpType = htContext
      ShortCut = 16449
    end
    object aEPaste: TEditPaste
      Category = 'Edit'
      Caption = 'aEPaste'
      Enabled = False
      HelpContext = 1026
      HelpType = htContext
      ImageIndex = 9
      SecondaryShortCuts.Strings = (
        'Shift+Ins')
      ShortCut = 16470
    end
    object aSSearchFind: TSearchFind_Ext
      Category = 'Search'
      Caption = 'aSSearchFind'
      Enabled = False
      HelpContext = 1032
      HelpType = htContext
      ImageIndex = 12
      ShortCut = 16454
      OnNotFound = aSSearchFindNotFound
    end
    object aSSearchReplace: TSearchReplace_Ext
      Category = 'Search'
      Caption = 'aSSearchReplace'
      Enabled = False
      HelpContext = 1033
      HelpType = htContext
      ImageIndex = 29
      ShortCut = 16466
    end
    object aSSearchNext: TSearchFindNext
      Category = 'Search'
      Caption = 'aSSearchFindNext'
      Enabled = False
      HelpContext = 1034
      HelpType = htContext
      SearchFind = aSSearchFind
      ShortCut = 114
    end
    object aDCreateDatabase: TAction
      Category = 'Database'
      Caption = 'aDCreateDatabase'
      Enabled = False
      HelpContext = 1044
      HelpType = htContext
      ImageIndex = 59
    end
    object aDCreateTable: TAction
      Category = 'Database'
      Caption = 'aDCreateTable'
      Enabled = False
      HelpContext = 1045
      HelpType = htContext
      ImageIndex = 61
    end
    object aDCreateView: TAction
      Category = 'Database'
      Caption = 'aDCreateView'
      Enabled = False
      HelpContext = 1096
      HelpType = htContext
    end
    object aDCreateSequence: TAction
      Category = 'Database'
      Caption = 'aDCreateSequence'
      Enabled = False
      HelpContext = 1160
      HelpType = htContext
    end
    object aDCreateProcedure: TAction
      Category = 'Database'
      Caption = 'aDCreateProcedure'
      Enabled = False
      HelpContext = 1097
      HelpType = htContext
    end
    object aDCreateFunction: TAction
      Category = 'Database'
      Caption = 'aDCreateFunction'
      Enabled = False
      HelpContext = 1097
      HelpType = htContext
    end
    object aDCreateEvent: TAction
      Category = 'Database'
      Caption = 'aDCreateEvent'
      Enabled = False
      HelpContext = 1114
      HelpType = htContext
    end
    object aDCreateTrigger: TAction
      Category = 'Database'
      Caption = 'aDCreateTrigger'
      Enabled = False
      HelpContext = 1102
      HelpType = htContext
    end
    object aDCreateKey: TAction
      Category = 'Database'
      Caption = 'aDCreateKey'
      Enabled = False
      HelpContext = 1046
      HelpType = htContext
      ImageIndex = 63
    end
    object aDCreateForeignKey: TAction
      Category = 'Database'
      Caption = 'aDCreateForeignKey'
      Enabled = False
      HelpContext = 1048
      HelpType = htContext
      ImageIndex = 67
    end
    object aDCreateField: TAction
      Category = 'Database'
      Caption = 'aDCreateField'
      Enabled = False
      HelpContext = 1047
      HelpType = htContext
      ImageIndex = 65
    end
    object aDCreateUser: TAction
      Category = 'Database'
      Caption = 'aDCreateUser'
      Enabled = False
      HelpContext = 1077
      HelpType = htContext
    end
    object aDDeleteDatabase: TAction
      Category = 'Database'
      Caption = 'aDDeleteDatabase'
      Enabled = False
      HelpContext = 1049
      HelpType = htContext
      ImageIndex = 60
    end
    object aDDeleteTable: TAction
      Category = 'Database'
      Caption = 'aDDeleteTable'
      Enabled = False
      HelpContext = 1051
      HelpType = htContext
      ImageIndex = 62
    end
    object aDDeleteView: TAction
      Category = 'Database'
      Caption = 'aDDeleteView'
      Enabled = False
      HelpContext = 1100
      HelpType = htContext
    end
    object aDDeleteSequence: TAction
      Category = 'Database'
      Caption = 'aDDeleteSequence'
      Enabled = False
      HelpContext = 1159
      HelpType = htContext
    end
    object aDDeleteRoutine: TAction
      Category = 'Database'
      Caption = 'aDDeleteRoutine'
      Enabled = False
      HelpContext = 1101
      HelpType = htContext
    end
    object aDDeleteEvent: TAction
      Category = 'Database'
      Caption = 'aDDeleteEvent'
      Enabled = False
      HelpContext = 1115
      HelpType = htContext
    end
    object aDDeleteTrigger: TAction
      Category = 'Database'
      Caption = 'aDDeleteTrigger'
      Enabled = False
    end
    object aDDeleteKey: TAction
      Category = 'Database'
      Caption = 'aDDeleteKey'
      Enabled = False
      HelpContext = 1052
      HelpType = htContext
      ImageIndex = 64
    end
    object aDDeleteForeignKey: TAction
      Category = 'Database'
      Caption = 'aDDeleteForeignKey'
      Enabled = False
      HelpContext = 1053
      HelpType = htContext
      ImageIndex = 72
    end
    object aDDeleteField: TAction
      Category = 'Database'
      Caption = 'aDDeleteField'
      Enabled = False
      HelpContext = 1053
      HelpType = htContext
      ImageIndex = 66
    end
    object aDDeleteProcess: TAction
      Category = 'Database'
      Caption = 'aDDeleteProcesss'
      Enabled = False
      HelpContext = 1078
      HelpType = htContext
    end
    object aDDeleteUser: TAction
      Category = 'Database'
      Caption = 'aDDeleteUser'
      Enabled = False
      HelpContext = 1080
      HelpType = htContext
    end
    object aDEditServer: TAction
      Category = 'Database'
      Caption = 'aDEditServer'
      Enabled = False
      HelpContext = 1091
      HelpType = htContext
    end
    object aDEditDatabase: TAction
      Category = 'Database'
      Caption = 'aDEditDatabase'
      Enabled = False
    end
    object aDEditTable: TAction
      Category = 'Database'
      Caption = 'aDEditTable'
      Enabled = False
      HelpContext = 1054
      HelpType = htContext
    end
    object aDEditView: TAction
      Category = 'Database'
      Caption = 'aDEditView'
      Enabled = False
      HelpContext = 1098
      HelpType = htContext
    end
    object aDEditSequence: TAction
      Category = 'Database'
      Caption = 'aDEditSequence'
      Enabled = False
      HelpContext = 1158
      HelpType = htContext
    end
    object aDEditRoutine: TAction
      Category = 'Database'
      Caption = 'aDEditRoutine'
      Enabled = False
      HelpContext = 1099
      HelpType = htContext
    end
    object aDEditEvent: TAction
      Category = 'Database'
      Caption = 'aDEditEvent'
      Enabled = False
      HelpContext = 1113
      HelpType = htContext
    end
    object aDEditTrigger: TAction
      Category = 'Database'
      Caption = 'aDEditTrigger'
      Enabled = False
    end
    object aDEditKey: TAction
      Category = 'Database'
      Caption = 'aDEditKey'
      Enabled = False
      HelpContext = 1055
      HelpType = htContext
    end
    object aDEditForeignKey: TAction
      Category = 'Database'
      Caption = 'aDEditForeignKey'
      Enabled = False
      HelpContext = 1057
      HelpType = htContext
    end
    object aDEditField: TAction
      Category = 'Database'
      Caption = 'aDEditField'
      Enabled = False
      HelpContext = 1056
      HelpType = htContext
    end
    object aDEditProcess: TAction
      Category = 'Database'
      Caption = 'aDEditProcess'
      Enabled = False
    end
    object aDEditUser: TAction
      Category = 'Database'
      Caption = 'aDEditUser'
      Enabled = False
      HelpContext = 1059
      HelpType = htContext
    end
    object aDEditVariable: TAction
      Category = 'Database'
      Caption = 'aDEditVariable'
      Enabled = False
      HelpContext = 1060
      HelpType = htContext
    end
    object aDInsertRecord: TAction
      Category = 'Database'
      Caption = 'aDInsertRecord'
      Enabled = False
      HelpContext = 1061
      HelpType = htContext
      ImageIndex = 19
    end
    object aDDeleteRecord: TAction
      Category = 'Database'
      Caption = 'aDDeleteRecord'
      Enabled = False
      HelpContext = 1062
      HelpType = htContext
      ImageIndex = 20
    end
    object aDEditRecord: TAction
      Category = 'Database'
      Caption = 'aDEdit'
      Enabled = False
      HelpContext = 1063
      HelpType = htContext
    end
    object aDPostRecord: TDataSetPost
      Category = 'Database'
      Caption = 'aDPostRecord'
      Enabled = False
      ShortCut = 16397
    end
    object aDCancelRecord: TDataSetCancel
      Category = 'Database'
      Caption = 'aDCancelRecord'
      Enabled = False
    end
    object aDCancel: TAction
      Category = 'Database'
      Enabled = False
      ImageIndex = 68
    end
    object aDRun: TAction
      Category = 'Database'
      Caption = 'aDRun'
      Enabled = False
      HelpContext = 1042
      HelpType = htContext
      ImageIndex = 18
      ShortCut = 120
    end
    object aDRunSelection: TAction
      Category = 'Database'
      Caption = 'aDRunSelection'
      Enabled = False
      HelpContext = 1043
      HelpType = htContext
      ImageIndex = 30
      ShortCut = 16504
    end
    object aDPostObject: TAction
      Category = 'Database'
      Caption = 'aDPostObject'
      Enabled = False
      ImageIndex = 97
      ShortCut = 8312
      Visible = False
    end
    object aDEmpty: TAction
      Category = 'Database'
      Caption = 'aDEmpty'
      Enabled = False
      HelpContext = 1064
      HelpType = htContext
    end
    object aEUndo: TEditUndo
      Category = 'Edit'
      Caption = 'aEUndo'
      HelpContext = 1023
      ImageIndex = 37
      ShortCut = 16474
    end
    object aERedo: TAction
      Category = 'Edit'
      Caption = 'aERedo'
      Enabled = False
      HelpContext = 1092
      ImageIndex = 38
      ShortCut = 24666
    end
    object aECut: TEditCut
      Category = 'Edit'
      Caption = 'aECut'
      Enabled = False
      HelpContext = 1024
      HelpType = htContext
      ImageIndex = 7
      ShortCut = 16472
    end
    object aECopy: TEditCopy
      Category = 'Edit'
      Caption = 'aECopy'
      Enabled = False
      HelpContext = 1025
      HelpType = htContext
      ImageIndex = 8
      SecondaryShortCuts.Strings = (
        'Ctrl+Ins')
      ShortCut = 16451
    end
    object aEDelete: TEditDelete
      Category = 'Edit'
      Caption = 'aEDelete'
      Enabled = False
      HelpContext = 1027
      HelpType = htContext
      ImageIndex = 10
      ShortCut = 16430
    end
    object aECopyToFile: TAction
      Category = 'Edit'
      Caption = 'aECopyToFile'
      Enabled = False
      HelpContext = 1029
      HelpType = htContext
    end
    object aEPasteFromFile: TAction
      Category = 'Edit'
      Caption = 'aEPasteFromFile'
      Enabled = False
      HelpContext = 1030
      HelpType = htContext
    end
    object aFClose: TAction
      Category = 'File'
      Caption = 'aFClose'
      Enabled = False
      HelpContext = 1020
      HelpType = htContext
      ImageIndex = 45
      ShortCut = 16499
      OnExecute = aFCloseExecute
    end
    object aFCloseAll: TAction
      Category = 'File'
      Caption = 'aFCloseAll'
      Enabled = False
      HelpContext = 1021
      HelpType = htContext
      OnExecute = aFCloseAllExecute
    end
    object aFExit: TAction
      Category = 'File'
      Caption = 'aFExit'
      HelpContext = 1022
      HelpType = htContext
      ShortCut = 32883
      OnExecute = aFExitExecute
    end
    object aHDowndate: TAction
      Category = 'Help'
      Caption = 'aHDowndate'
      HelpContext = 1157
      HelpType = htContext
      OnExecute = aHDowndateExecute
    end
    object aHSupport: TAction
      Category = 'Help'
      Caption = 'aHSupport'
      Visible = False
      OnExecute = aHSupportExecute
    end
    object aHInfo: TAction
      Category = 'Help'
      Caption = 'aHInfo'
      HelpContext = 1075
      HelpType = htContext
      OnExecute = aHInfoExecute
    end
    object aERename: TAction
      Category = 'Edit'
      Caption = 'aERename'
      HelpContext = 1031
      HelpType = htContext
      ShortCut = 113
    end
    object aEFormatSQL: TAction
      Category = 'Extras'
      Caption = 'aEFormatSQL'
      Enabled = False
      HelpContext = 1153
      HelpType = htContext
      ImageIndex = 107
    end
    object aOExport: TAction
      Category = 'Options'
      Caption = 'aOExport'
      OnExecute = aOExportExecute
    end
  end
  object MainMenu: TMainMenu
    Left = 16
    Top = 240
    object miFile: TMenuItem
      Caption = 'miFile'
      object miFConnect: TMenuItem
        Action = aFOpenAccount
      end
      object N8: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object miFOpen: TMenuItem
        Action = aFOpen
        GroupIndex = 1
      end
      object miFSave: TMenuItem
        Action = aFSave
        GroupIndex = 1
      end
      object miFSaveAs: TMenuItem
        Action = aFSaveAs
        GroupIndex = 1
      end
      object miFReopen: TMenuItem
        Caption = 'miFOpenRecent'
        Enabled = False
        GroupIndex = 1
        HelpContext = 1136
        object TMenuItem
        end
      end
      object N18: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object miFImport: TMenuItem
        Caption = 'miFImport'
        GroupIndex = 1
        object miFImportSQL: TMenuItem
          Action = aFImportSQL
        end
        object miFImportText: TMenuItem
          Action = aFImportText
        end
        object miFImportExcel: TMenuItem
          Action = aFImportExcel
        end
        object miFImportAccess: TMenuItem
          Action = aFImportAccess
        end
        object miFImportODBC: TMenuItem
          Action = aFImportODBC
        end
      end
      object miFExport: TMenuItem
        Caption = 'miFExport'
        GroupIndex = 1
        object miFExportSQL: TMenuItem
          Action = aFExportSQL
        end
        object miFExportText: TMenuItem
          Action = aFExportText
        end
        object miFExportExcel: TMenuItem
          Action = aFExportExcel
        end
        object miFExportAccess: TMenuItem
          Action = aFExportAccess
        end
        object miFExportODBC: TMenuItem
          Action = aFExportODBC
        end
        object miFExportXML: TMenuItem
          Action = aFExportXML
        end
        object miFExportHTML: TMenuItem
          Action = aFExportHTML
        end
        object miFExportPDF: TMenuItem
          Action = aFExportPDF
        end
        object miFExportBitmap: TMenuItem
          Action = aFExportBitmap
        end
      end
      object N2: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object miFClose: TMenuItem
        Action = aFClose
        GroupIndex = 1
      end
      object N1: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object miFExit: TMenuItem
        Action = aFExit
        GroupIndex = 1
      end
    end
    object miEdit: TMenuItem
      Caption = 'miEdit'
      object miEUndo: TMenuItem
        Action = aEUndo
      end
      object miERedo: TMenuItem
        Action = aERedo
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object miECut: TMenuItem
        Action = aECut
      end
      object miECopy: TMenuItem
        Action = aECopy
      end
      object miEPaste: TMenuItem
        Action = aEPaste
      end
      object miEDelete: TMenuItem
        Action = aEDelete
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object miECopyToFile: TMenuItem
        Action = aECopyToFile
      end
      object miEPasteFrom: TMenuItem
        Action = aEPasteFromFile
      end
      object N21: TMenuItem
        Caption = '-'
      end
      object miESelectAll: TMenuItem
        Action = aESelectAll
      end
      object N25: TMenuItem
        Caption = '-'
      end
      object miERename: TMenuItem
        Action = aERename
      end
    end
    object miSearch: TMenuItem
      Caption = 'miSearch'
      object miSSearchFind: TMenuItem
        Action = aSSearchFind
      end
      object miSSearchReplace: TMenuItem
        Action = aSSearchReplace
      end
      object miSSearchNext: TMenuItem
        Action = aSSearchNext
      end
    end
    object miView: TMenuItem
      Caption = 'miView'
      GroupIndex = 3
      object miVObjects: TMenuItem
        Action = aVObjects
        RadioItem = True
      end
      object miVBrowser: TMenuItem
        Action = aVBrowser
        RadioItem = True
      end
      object miVIDE: TMenuItem
        Action = aVIDE
        RadioItem = True
      end
      object miVBuilder: TMenuItem
        Action = aVBuilder
        RadioItem = True
      end
      object miVDiagram: TMenuItem
        Action = aVDiagram
        RadioItem = True
      end
      object miVSQLEditor: TMenuItem
        Action = aVEditor
        RadioItem = True
      end
      object N12: TMenuItem
        Caption = '-'
      end
      object miVSidebar: TMenuItem
        Caption = 'miVSidebar'
        object miVNavigator: TMenuItem
          Action = aVNavigator
          AutoCheck = True
        end
        object miVExplorer: TMenuItem
          Action = aVExplorer
          AutoCheck = True
        end
        object miVSQLHistory: TMenuItem
          Action = aVSQLHistory
          AutoCheck = True
        end
      end
      object miVSQLLog: TMenuItem
        Action = aVSQLLog
        AutoCheck = True
      end
      object N22: TMenuItem
        Caption = '-'
      end
      object miVRefresh: TMenuItem
        Action = aVRefresh
        HelpContext = 1040
      end
      object miVRefreshAll: TMenuItem
        Action = aVRefreshAll
        HelpContext = 1041
      end
    end
    object miDatabase: TMenuItem
      Caption = 'miDatabase'
      GroupIndex = 3
      object miDCreate: TMenuItem
        Caption = 'miDCreate'
        object miDCreateDatabase: TMenuItem
          Action = aDCreateDatabase
        end
        object miDCreateTable: TMenuItem
          Action = aDCreateTable
        end
        object miDCreateView: TMenuItem
          Action = aDCreateView
        end
        object miDCreateSequence: TMenuItem
          Action = aDCreateSequence
        end
        object miDCreateRoutine: TMenuItem
          Action = aDCreateProcedure
        end
        object miDCreateFunction: TMenuItem
          Action = aDCreateFunction
        end
        object miDCreateEvent: TMenuItem
          Action = aDCreateEvent
        end
        object miDCreateIndex: TMenuItem
          Action = aDCreateKey
        end
        object miDCreateForeignKey: TMenuItem
          Action = aDCreateForeignKey
        end
        object miDCreateField: TMenuItem
          Action = aDCreateField
        end
        object miDCreateTrigger: TMenuItem
          Action = aDCreateTrigger
        end
        object miDCreateUser: TMenuItem
          Action = aDCreateUser
        end
      end
      object miDDelete: TMenuItem
        Caption = 'miDDelete'
        object miDDeleteDatabase: TMenuItem
          Action = aDDeleteDatabase
        end
        object miDDeleteTable: TMenuItem
          Action = aDDeleteTable
        end
        object miDDeleteView: TMenuItem
          Action = aDDeleteView
        end
        object miDDeleteSequence: TMenuItem
          Action = aDDeleteSequence
        end
        object miDDeleteRoutine: TMenuItem
          Action = aDDeleteRoutine
        end
        object miDDeleteEvent: TMenuItem
          Action = aDDeleteEvent
        end
        object miDDeleteIndex: TMenuItem
          Action = aDDeleteKey
        end
        object miDDeleteForeignKey: TMenuItem
          Action = aDDeleteForeignKey
        end
        object miDDeleteField: TMenuItem
          Action = aDDeleteField
        end
        object miDDeleteTrigger: TMenuItem
          Action = aDDeleteTrigger
        end
        object miDDeleteProcess: TMenuItem
          Action = aDDeleteProcess
        end
        object miDDeleteUser: TMenuItem
          Action = aDDeleteUser
        end
      end
      object miDProperties: TMenuItem
        Caption = 'miDProperties'
        object miDEditServer: TMenuItem
          Action = aDEditServer
        end
        object miDEditDatabase: TMenuItem
          Action = aDEditDatabase
        end
        object miDEditTable: TMenuItem
          Action = aDEditTable
        end
        object miDEditView: TMenuItem
          Action = aDEditView
        end
        object miDEditSequence: TMenuItem
          Action = aDEditSequence
        end
        object miDEditRoutine: TMenuItem
          Action = aDEditRoutine
        end
        object miDEditEvent: TMenuItem
          Action = aDEditEvent
        end
        object miDEditIndex: TMenuItem
          Action = aDEditKey
        end
        object miDEditForeignKey: TMenuItem
          Action = aDEditForeignKey
        end
        object miDEditField: TMenuItem
          Action = aDEditField
        end
        object miDEditTrigger: TMenuItem
          Action = aDEditTrigger
        end
        object miDEditProcess: TMenuItem
          Action = aDEditProcess
        end
        object miDEditUser: TMenuItem
          Action = aDEditUser
        end
        object miDEditVariable: TMenuItem
          Action = aDEditVariable
        end
      end
      object N15: TMenuItem
        Caption = '-'
      end
      object miDInsertRecord: TMenuItem
        Action = aDInsertRecord
      end
      object miDDeleteRecord: TMenuItem
        Action = aDDeleteRecord
      end
      object miDEditRecord: TMenuItem
        Action = aDEditRecord
      end
      object miDPostRecord: TMenuItem
        Action = aDPostRecord
      end
      object miDCancelRecord: TMenuItem
        Action = aDCancelRecord
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object miDRun: TMenuItem
        Action = aDRun
      end
      object miDRunSelection: TMenuItem
        Action = aDRunSelection
      end
      object miDPostObject: TMenuItem
        Action = aDPostObject
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object miDEmpty: TMenuItem
        Action = aDEmpty
      end
    end
    object miExtras: TMenuItem
      Caption = 'miExtras'
      GroupIndex = 3
      object miEFind: TMenuItem
        Action = aEFind
      end
      object miEReplace: TMenuItem
        Action = aEReplace
      end
      object N27: TMenuItem
        Caption = '-'
      end
      object miETransfer: TMenuItem
        Action = aETransfer
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object miEFormatSQL: TMenuItem
        Action = aEFormatSQL
      end
    end
    object miOptions: TMenuItem
      Caption = 'miOptions'
      GroupIndex = 3
      object miOGlobals: TMenuItem
        Action = aOGlobals
      end
      object miOAccounts: TMenuItem
        Action = aOAccounts
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object miOImport: TMenuItem
        Action = aOImport
      end
      object miOExport: TMenuItem
        Action = aOExport
      end
    end
    object miHelp: TMenuItem
      Caption = 'miHelp'
      GroupIndex = 3
      object miHIndex: TMenuItem
        Action = aHIndex
      end
      object miHSQL: TMenuItem
        Action = aHSQL
      end
      object miHManual: TMenuItem
        Action = aHManual
      end
      object N16: TMenuItem
        Caption = '-'
      end
      object miHUpdate: TMenuItem
        Action = aHUpdate
      end
      object miHDowndate: TMenuItem
        Action = aHDowndate
      end
      object miHSupport: TMenuItem
        Action = aHSupport
      end
      object N19: TMenuItem
        Caption = '-'
      end
      object miHInfo: TMenuItem
        Action = aHInfo
      end
    end
  end
  object MTabControl: TPopupMenu
    Left = 113
    Top = 112
    object mtFClose: TMenuItem
      Action = aFClose
    end
    object N30: TMenuItem
      Caption = '-'
    end
    object mtFOpenAccount: TMenuItem
      Action = aFOpenAccount
    end
    object mtTabs: TMenuItem
      Caption = 'mtTabs'
    end
  end
  object OpenDialog: TOpenDialog_Ext
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    EncodingIndex = -1
    EncodingLabel = 'Encoding:'
    Left = 16
    Top = 312
  end
  object SaveDialog: TSaveDialog_Ext
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    EncodingIndex = -1
    EncodingLabel = 'Encoding:'
    Left = 80
    Top = 312
  end
end

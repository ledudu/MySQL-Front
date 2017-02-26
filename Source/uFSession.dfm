object FSession: TFSession
  Left = 0
  Top = 0
  Width = 591
  Height = 315
  Align = alClient
  Constraints.MinHeight = 300
  Constraints.MinWidth = 200
  TabOrder = 0
  Visible = False
  OnResize = FormResize
  object SLog: TSplitter_Ext
    Left = 0
    Top = 267
    Width = 591
    Height = 4
    Cursor = crVSplit
    Align = alBottom
    AutoSnap = False
    Color = clBtnFace
    ParentColor = False
    ResizeStyle = rsUpdate
    OnCanResize = SLogCanResize
    OnMoved = SLogMoved
    ActiveBorder = alTop
    ActiveBorderColor = clWindow
    ExplicitTop = 252
    ExplicitWidth = 443
  end
  object SSideBar: TSplitter_Ext
    Left = 120
    Top = 22
    Width = 4
    Height = 245
    AutoSnap = False
    ResizeStyle = rsUpdate
    OnCanResize = SSideBarCanResize
    OnMoved = SSideBarMoved
    ActiveBorder = alRight
    ActiveBorderColor = clWindow
    ExplicitTop = 0
    ExplicitHeight = 252
  end
  object PSideBar: TPanel_Ext
    Left = 0
    Top = 22
    Width = 120
    Height = 245
    Align = alLeft
    BevelOuter = bvNone
    Color = clWindow
    Constraints.MinWidth = 120
    ParentBackground = False
    TabOrder = 0
    object PExplorer: TPanel_Ext
      Left = 0
      Top = 0
      Width = 120
      Height = 245
      Align = alClient
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Caption = 'PExplorer'
      ParentBackground = False
      TabOrder = 2
      Visible = False
      OnResize = PanelResize
      object SExplorer: TSplitter_Ext
        Left = 2
        Top = 102
        Width = 116
        Height = 4
        Cursor = crVSplit
        Align = alTop
        Color = clBtnFace
        Constraints.MinHeight = 4
        ParentColor = False
        OnCanResize = SplitterCanResize
        ActiveBorderColor = clWindow
        ExplicitTop = 150
      end
      object PFiles: TPanel_Ext
        Left = 2
        Top = 106
        Width = 116
        Height = 137
        Align = alClient
        BevelOuter = bvNone
        Color = clWindow
        Constraints.MinHeight = 50
        ParentBackground = False
        TabOrder = 0
      end
      object PFolders: TPanel_Ext
        Left = 2
        Top = 2
        Width = 116
        Height = 100
        Align = alTop
        BevelOuter = bvNone
        Color = clWindow
        Constraints.MinHeight = 50
        ParentBackground = False
        TabOrder = 1
      end
    end
    object PSQLHistory: TPanel_Ext
      Left = 0
      Top = 0
      Width = 120
      Height = 245
      Align = alClient
      BevelInner = bvRaised
      BevelOuter = bvLowered
      ParentBackground = False
      TabOrder = 1
      Visible = False
      object FSQLHistory: TTreeView_Ext
        Left = 2
        Top = 2
        Width = 116
        Height = 241
        HelpContext = 1112
        Align = alClient
        BorderStyle = bsNone
        DragMode = dmAutomatic
        HideSelection = False
        Indent = 19
        PopupMenu = MSQLHistory
        ReadOnly = True
        RightClickSelect = True
        RowSelect = True
        ShowLines = False
        TabOrder = 0
        OnChange = FSQLHistoryChange
        OnChanging = FSQLHistoryChanging
        OnCollapsed = TreeViewCollapsed
        OnCollapsing = TreeViewCollapsing
        OnDblClick = FSQLHistoryDblClick
        OnEndDrag = TreeViewEndDrag
        OnEnter = FSQLHistoryEnter
        OnExit = FSQLHistoryExit
        OnExpanded = TreeViewExpanded
        OnGetSelectedIndex = TreeViewGetSelectedIndex
        OnHint = FSQLHistoryHint
        OnKeyDown = FSQLHistoryKeyDown
        OnKeyPress = FSQLHistoryKeyPress
        OnMouseDown = FSQLHistoryMouseDown
        OnMouseUp = TreeViewMouseUp
      end
    end
    object PNavigator: TPanel_Ext
      Left = 0
      Top = 0
      Width = 120
      Height = 245
      Align = alClient
      BevelInner = bvRaised
      BevelOuter = bvLowered
      ParentBackground = False
      TabOrder = 0
      Visible = False
      object FNavigator: TTreeView_Ext
        Left = 2
        Top = 2
        Width = 116
        Height = 241
        HelpContext = 1038
        Align = alClient
        BorderStyle = bsNone
        DoubleBuffered = True
        DragMode = dmAutomatic
        HideSelection = False
        HotTrack = True
        Indent = 19
        ParentDoubleBuffered = False
        PopupMenu = MNavigator
        RightClickSelect = True
        ShowLines = False
        ShowRoot = False
        TabOrder = 0
        OnChange = FNavigatorChange
        OnChanging = FNavigatorChanging
        OnCollapsed = TreeViewCollapsed
        OnCollapsing = TreeViewCollapsing
        OnDragDrop = FNavigatorDragDrop
        OnDragOver = FNavigatorDragOver
        OnEdited = FNavigatorEdited
        OnEditing = FNavigatorEditing
        OnEndDrag = TreeViewEndDrag
        OnEnter = FNavigatorEnter
        OnExit = FNavigatorExit
        OnExpanding = FNavigatorExpanding
        OnExpanded = TreeViewExpanded
        OnGetSelectedIndex = TreeViewGetSelectedIndex
        OnKeyDown = FNavigatorKeyDown
        OnKeyPress = FNavigatorKeyPress
        OnKeyUp = FNavigatorKeyUp
        OnMouseDown = TreeViewMouseDown
        OnMouseMove = FNavigatorMouseMove
        OnMouseUp = TreeViewMouseUp
      end
    end
  end
  object PLog: TPanel_Ext
    Left = 0
    Top = 271
    Width = 591
    Height = 44
    Align = alBottom
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentBackground = False
    TabOrder = 2
    OnResize = PLogResize
    object FLog: TRichEdit
      Left = 19
      Top = 2
      Width = 570
      Height = 40
      HelpContext = 1039
      TabStop = False
      Align = alClient
      BorderStyle = bsNone
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      HideSelection = False
      Constraints.MinHeight = 35
      ParentFont = False
      PopupMenu = MLog
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 1
      WantReturns = False
      WordWrap = False
      OnEnter = FLogEnter
      OnExit = FLogExit
    end
    object PLogHeader: TPanel_Ext
      Left = 2
      Top = 2
      Width = 17
      Height = 40
      Align = alLeft
      BevelOuter = bvNone
      BorderWidth = 2
      ParentBackground = False
      TabOrder = 0
      OnMouseDown = PanelMouseDown
      OnMouseMove = PanelMouseMove
      OnMouseUp = PanelMouseUp
      OnPaint = PanelPaint
    end
  end
  object PContent: TPanel_Ext
    Left = 124
    Top = 22
    Width = 467
    Height = 245
    Align = alClient
    BevelOuter = bvNone
    Color = clWindow
    Constraints.MinHeight = 200
    Constraints.MinWidth = 200
    DoubleBuffered = False
    ParentBackground = False
    ParentDoubleBuffered = False
    TabOrder = 1
    OnResize = PContentResize
    object SResult: TSplitter_Ext
      Left = 0
      Top = 48
      Width = 467
      Height = 4
      Cursor = crVSplit
      Align = alBottom
      AutoSnap = False
      Color = clBtnFace
      Constraints.MinHeight = 4
      ParentColor = False
      ResizeStyle = rsUpdate
      Visible = False
      OnCanResize = SplitterCanResize
      ActiveBorder = alBottom
      ActiveBorderColor = clWindow
      ExplicitTop = 36
      ExplicitWidth = 319
    end
    object SBlob: TSplitter_Ext
      Left = 0
      Top = 182
      Width = 467
      Height = 4
      Cursor = crVSplit
      Align = alBottom
      AutoSnap = False
      Color = clBtnFace
      Constraints.MinHeight = 4
      ParentColor = False
      ResizeStyle = rsUpdate
      Visible = False
      OnCanResize = SplitterCanResize
      ActiveBorder = alTop
      ActiveBorderColor = clWindow
      ExplicitTop = 189
      ExplicitWidth = 319
    end
    object PListView: TPanel_Ext
      Left = 0
      Top = 0
      Width = 467
      Height = 56
      HelpContext = 1035
      Align = alTop
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Color = clWindow
      Constraints.MinHeight = 20
      ParentBackground = False
      TabOrder = 3
      Visible = False
      object FListView: TListView_Ext
        Left = 2
        Top = 2
        Width = 463
        Height = 52
        HelpContext = 1035
        Align = alClient
        BorderStyle = bsNone
        Columns = <>
        DoubleBuffered = True
        DragMode = dmAutomatic
        HideSelection = False
        MultiSelect = True
        GroupView = True
        ParentDoubleBuffered = False
        PopupMenu = MList
        TabOrder = 0
        ViewStyle = vsReport
        OnColumnClick = ListViewColumnClick
        OnCompare = ListViewCompare
        OnDblClick = ListViewDblClick
        OnEdited = ListViewEdited
        OnEditing = ListViewEditing
        OnEnter = ListViewEnter
        OnExit = ListViewExit
        OnDragDrop = FNavigatorDragDrop
        OnDragOver = ListViewDragOver
        OnKeyDown = ListViewKeyDown
        OnSelectItem = ListViewSelectItem
      end
    end
    object PSynMemo: TPanel_Ext
      Left = 0
      Top = 310
      Width = 467
      Height = 50
      Align = alTop
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Color = clWindow
      Constraints.MinHeight = 50
      ParentBackground = False
      TabOrder = 2
      Visible = False
      object FSQLEditorSynMemo: TSynMemo
        Left = 2
        Top = 2
        Width = 463
        Height = 46
        HelpContext = 1037
        OnSearchNotFound = SearchNotFound
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        PopupMenu = MSQLEditor
        TabOrder = 0
        Visible = False
        OnDragDrop = SynMemoDragDrop
        OnDragOver = SynMemoDragOver
        OnEnter = SynMemoEnter
        OnExit = SynMemoExit
        OnKeyPress = FSQLEditorSynMemoKeyPress
        BorderStyle = bsNone
        Gutter.AutoSize = True
        Gutter.DigitCount = 2
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.LeftOffset = 2
        Gutter.ShowLineNumbers = True
        MaxScrollWidth = 1048576
        Options = [eoAutoIndent, eoDragDropEditing, eoGroupUndo, eoHideShowScrollbars, eoScrollPastEol, eoShowScrollHint, eoSmartTabDelete, eoTabIndent, eoTabsToSpaces]
        RightEdge = 0
        ScrollHintFormat = shfTopToBottom
        SearchEngine = FSQLEditorSearch
        TabWidth = 2
        WantTabs = True
        OnStatusChange = SynMemoStatusChange
        FontSmoothing = fsmNone
        RemovedKeystrokes = <
          item
            Command = ecContextHelp
            ShortCut = 112
          end>
        AddedKeystrokes = <
          item
            Command = ecContextHelp
            ShortCut = 16496
          end>
      end
    end
    object PResult: TPanel_Ext
      Left = 0
      Top = 52
      Width = 467
      Height = 130
      Align = alBottom
      BevelOuter = bvNone
      Constraints.MinHeight = 130
      ParentBackground = False
      TabOrder = 5
      Visible = False
      object PResultHeader: TPanel_Ext
        Left = 0
        Top = 0
        Width = 17
        Height = 130
        Align = alLeft
        BevelOuter = bvNone
        ParentBackground = False
        TabOrder = 0
        OnMouseDown = PanelMouseDown
        OnMouseMove = PanelMouseMove
        OnMouseUp = PanelMouseUp
        OnPaint = PanelPaint
      end
      object PSQLEditorDBGrid: TPanel_Ext
        Left = 17
        Top = 0
        Width = 450
        Height = 130
        Align = alClient
        BevelInner = bvRaised
        BevelOuter = bvLowered
        Constraints.MinHeight = 50
        ParentBackground = False
        TabOrder = 1
        OnResize = PDBGridResize
      end
    end
    object PQueryBuilder: TPanel_Ext
      Left = 0
      Top = 160
      Width = 467
      Height = 150
      HelpContext = 1120
      Align = alTop
      BevelOuter = bvNone
      Constraints.MinHeight = 150
      ParentBackground = False
      TabOrder = 1
      Visible = False
      object SQueryBuilderSynMemo: TSplitter_Ext
        Left = 0
        Top = 96
        Width = 467
        Height = 4
        Cursor = crVSplit
        Align = alBottom
        AutoSnap = False
        ResizeStyle = rsUpdate
        OnCanResize = SplitterCanResize
        ActiveBorderColor = clWindow
        ExplicitWidth = 319
      end
      object PQueryBuilderSynMemo: TPanel_Ext
        Left = 0
        Top = 100
        Width = 467
        Height = 50
        Align = alBottom
        BevelInner = bvRaised
        BevelOuter = bvLowered
        Color = clWindow
        Constraints.MinHeight = 50
        ParentBackground = False
        TabOrder = 0
        object FQueryBuilderSynMemo: TSynMemo
          Left = 2
          Top = 2
          Width = 463
          Height = 46
          HelpContext = 1120
          OnSearchNotFound = SearchNotFound
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          PopupMenu = MSQLEditor
          TabOrder = 0
          OnDragDrop = SynMemoDragDrop
          OnDragOver = SynMemoDragOver
          OnEnter = FQueryBuilderSynMemoEnter
          OnExit = FQueryBuilderSynMemoExit
          BorderStyle = bsNone
          Gutter.AutoSize = True
          Gutter.DigitCount = 2
          Gutter.Font.Charset = DEFAULT_CHARSET
          Gutter.Font.Color = clWindowText
          Gutter.Font.Height = -11
          Gutter.Font.Name = 'Courier New'
          Gutter.Font.Style = []
          Gutter.LeftOffset = 2
          Gutter.ShowLineNumbers = True
          MaxScrollWidth = 65535
          Options = [eoAutoIndent, eoDragDropEditing, eoGroupUndo, eoHideShowScrollbars, eoScrollPastEol, eoShowScrollHint, eoSmartTabDelete, eoTabIndent, eoTabsToSpaces]
          ScrollHintFormat = shfTopToBottom
          SearchEngine = FSQLEditorSearch
          WantTabs = True
          OnChange = FQueryBuilderSynMemoChange
          OnStatusChange = SynMemoStatusChange
          FontSmoothing = fsmNone
        end
      end
      object FQueryBuilder: TacQueryBuilder
        Left = 0
        Top = 0
        Width = 467
        Height = 96
        HelpContext = 1120
        MetadataFilter = <>
        BorderStyle = qbbsFlat
        SplitterHeight = 4
        LinkPainterClassName = 'TacQueryBuilderLinkPainterAccess'
        LinkPainter.LinkColor = clBlack
        BkImagePos = bkipTopLeft
        BkImageDarkness = bgidLight
        BkColor = clAppWorkSpace
        OnValidatePopupMenu = FQueryBuilderValidatePopupMenu
        AddObjectFormOptions.Constraints.MinHeight = 150
        AddObjectFormOptions.Constraints.MinWidth = 150
        TreeOptions.TreeVisible = False
        TreeOptions.TreeWidth = 100
        TreeOptions.UnionsNodeText = 'UNIONS'
        TreeOptions.FieldsNodeText = 'FIELDS'
        TreeOptions.FromNodeText = 'FROM'
        TreeOptionsMetadata.TreeVisible = False
        TreeOptionsMetadata.TreeWidth = 100
        TreeOptionsMetadata.TablesNodeName = 'Tables'
        TreeOptionsMetadata.ViewsNodeName = 'Views'
        TreeOptionsMetadata.ProceduresNodeName = 'Procedures'
        TreeOptionsMetadata.SynonymsNodeName = 'Synonyms'
        QuoteAllIdentifiers = True
        SelectListOptions.ToolbarImageUp.Data = {
          2E020000424D2E02000000000000360000002800000012000000090000000100
          180000000000F801000000000000000000000000000000000000E3DFE0E3DFE0
          E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
          E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE00000E3DFE0E3DFE0E3DFE0E3DFE0E3DF
          E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3
          DFE0E3DFE0E3DFE00000E3DFE08E8E8E8484847A7A7A71717169696962626267
          6767E3DFE0E3DFE0B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7E3DFE0
          0000E3DFE0A4A4A4A5A5A5AFAFAFA9A9A9A2A2A2868686959595E3DFE0E3DFE0
          B7B7B7E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0B7B7B7E3DFE00000E3DFE0E3DFE0
          A9A9A9A8A8A8B1B1B1999999838383E3DFE0E3DFE0E3DFE0E3DFE0B7B7B7E3DF
          E0E3DFE0E3DFE0B7B7B7E3DFE0E3DFE00000E3DFE0E3DFE0E3DFE0ABABABABAB
          AB9A9A9AE3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0B7B7B7E3DFE0B7B7B7E3
          DFE0E3DFE0E3DFE00000E3DFE0E3DFE0E3DFE0E3DFE0B7B7B7E3DFE0E3DFE0E3
          DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0B7B7B7E3DFE0E3DFE0E3DFE0E3DFE0
          0000E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
          E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE00000E3DFE0E3DFE0
          E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
          E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE00000}
        SelectListOptions.ToolbarImageDown.Data = {
          2E020000424D2E02000000000000360000002800000012000000090000000100
          180000000000F801000000000000000000000000000000000000E3DFE0E3DFE0
          E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
          E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE00000E3DFE0E3DFE0E3DFE0E3DFE0E3DF
          E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3
          DFE0E3DFE0E3DFE00000E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3
          DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
          0000E3DFE0E3DFE0E3DFE0E3DFE0858585E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0
          E3DFE0E3DFE0E3DFE0B7B7B7E3DFE0E3DFE0E3DFE0E3DFE00000E3DFE0E3DFE0
          E3DFE09090909494947F7F7FE3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0B7B7
          B7E3DFE0B7B7B7E3DFE0E3DFE0E3DFE00000E3DFE0E3DFE0A9A9A9A8A8A8B1B1
          B1999999838383E3DFE0E3DFE0E3DFE0E3DFE0B7B7B7E3DFE0E3DFE0E3DFE0B7
          B7B7E3DFE0E3DFE00000E3DFE0BCBCBCBABABABFBFBFB9B9B9B3B3B39C9C9CA6
          A6A6E3DFE0E3DFE0B7B7B7E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0B7B7B7E3DFE0
          0000E3DFE0C0C0C0BABABAB3B3B3ABABABA2A2A2989898959595E3DFE0E3DFE0
          B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7E3DFE00000E3DFE0E3DFE0
          E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
          E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE00000}
        SelectListOptions.ToolbarImageInsert.Data = {
          2E020000424D2E02000000000000360000002800000012000000090000000100
          180000000000F801000000000000000000000000000000000000E3DFE0E3DFE0
          E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
          E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE00000E3DFE0B3B3B38A8A8A8484847F7F
          7F7979797474749C9C9CE3DFE0E3DFE0B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7
          B7B7B7B7B7E3DFE00000E3DFE09A9A9AC2C2C2C2C2C2C2C2C2C2C2C2C2C2C276
          7676E3DFE0E3DFE0B7B7B7E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0B7B7B7E3DFE0
          0000E3DFE0A3A3A3C2C2C2ADADADFFFFFFADADADC2C2C27F7F7FE3DFE0E3DFE0
          B7B7B7E3DFE0E3DFE0B7B7B7E3DFE0E3DFE0B7B7B7E3DFE00000E3DFE0ACACAC
          C2C2C2FFFFFFFFFFFFFFFFFFC2C2C2878787E3DFE0E3DFE0B7B7B7E3DFE0B7B7
          B7B7B7B7B7B7B7E3DFE0B7B7B7E3DFE00000E3DFE0B4B4B4C2C2C2ADADADFFFF
          FFADADADC2C2C2909090E3DFE0E3DFE0B7B7B7E3DFE0E3DFE0B7B7B7E3DFE0E3
          DFE0B7B7B7E3DFE00000E3DFE0BDBDBDC2C2C2C2C2C2C2C2C2C2C2C2C2C2C29A
          9A9AE3DFE0E3DFE0B7B7B7E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0B7B7B7E3DFE0
          0000E3DFE0D3D3D3BFBFBFBABABAB4B4B4AFAFAFA9A9A9BABABAE3DFE0E3DFE0
          B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7E3DFE00000E3DFE0E3DFE0
          E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
          E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE00000}
        SelectListOptions.ToolbarImageDelete.Data = {
          2E020000424D2E02000000000000360000002800000012000000090000000100
          180000000000F801000000000000000000000000000000000000E3DFE0E3DFE0
          E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
          E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE00000E3DFE0B3B3B38A8A8A8484847F7F
          7F7979797474749C9C9CE3DFE0E3DFE0B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7
          B7B7B7B7B7E3DFE00000E3DFE09A9A9AC2C2C2C2C2C2C2C2C2C2C2C2C2C2C276
          7676E3DFE0E3DFE0B7B7B7E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0B7B7B7E3DFE0
          0000E3DFE0A3A3A3C2C2C2ADADADADADADADADADC2C2C27F7F7FE3DFE0E3DFE0
          B7B7B7E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0B7B7B7E3DFE00000E3DFE0ACACAC
          C2C2C2FFFFFFFFFFFFFFFFFFC2C2C2878787E3DFE0E3DFE0ACACACE3DFE0B7B7
          B7B7B7B7B7B7B7E3DFE0B7B7B7E3DFE00000E3DFE0B4B4B4C2C2C2ADADADADAD
          ADADADADC2C2C2909090E3DFE0E3DFE0B4B4B4E3DFE0E3DFE0E3DFE0E3DFE0E3
          DFE0B7B7B7E3DFE00000E3DFE0BDBDBDC2C2C2C2C2C2C2C2C2C2C2C2C2C2C29A
          9A9AE3DFE0E3DFE0BDBDBDE3DFE0E3DFE0E3DFE0E3DFE0E3DFE0B7B7B7E3DFE0
          0000E3DFE0D3D3D3BFBFBFBABABAB4B4B4AFAFAFA9A9A9BABABAE3DFE0E3DFE0
          B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7B7E3DFE00000E3DFE0E3DFE0
          E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE0E3DF
          E0E3DFE0E3DFE0E3DFE0E3DFE0E3DFE00000}
        SelectListOptions.ToolbarImageCollapse.Data = {
          DE000000424DDE000000000000003600000028000000040000000E0000000100
          180000000000A800000000000000000000000000000000000000FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF616161FF00FFFF00FF7E7E7E62
          6262FF00FF969696999999696969B1B1B1ABABABB1B1B1717171FF00FFA8A8A8
          A8A8A87A7A7AFF00FFFF00FFA6A6A6848484FF00FFFF00FFFF00FF8E8E8EFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FF}
        SelectListOptions.ToolbarImageExpand.Data = {
          DE000000424DDE000000000000003600000028000000040000000E0000000100
          180000000000A800000000000000000000000000000000000000FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FF616161FF00FFFF00FFFF00FF6262627E7E7EFF00FFFF
          00FF696969999999969696FF00FF717171B1B1B1ABABABB1B1B17A7A7AA8A8A8
          A8A8A8FF00FF848484A6A6A6FF00FFFF00FF8E8E8EFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FF}
        FieldsListOptions.MarkColumnOptions.PKIcon.Data = {
          07544269746D617076010000424D760100000000000036000000280000000A00
          00000A0000000100180000000000400100000000000000000000000000000000
          0000FF808055A7D8519AD1FF8080FF8080FF8080FF8080FF8080FF8080FF8080
          00006EBFE886E9F94DD9F54397CEFF8080FF8080FF8080FF8080FF8080FF8080
          00006ABAE6A1E6F838D2F247D6F64298CEFF8080FF8080FF8080FF8080FF8080
          0000FF80805FB0E399E2F653DCF546D9F63F94CE478ED3488FD6FF8080FF8080
          0000FF8080FF80806CBBE766C1E85ED9F24EDBF65BDDF755D8F53483CEFF8080
          0000FF8080FF8080FF808094C9EB89DDF46AE0F673E2F75FDFF655DAF64185CF
          0000FF8080FF8080FF808078BEE7A9EEF97EE6F89AE8F87ED1F080E2F64A9EDB
          0000FF8080FF8080FF8080ABD5EF5EC1EAA3F0FB80D4F07EC7EC56A6DEFF8080
          0000FF8080FF8080FF8080FF8080A1CEED6FC9ECC9F3FB62BEE8FF8080FF8080
          0000FF8080FF8080FF8080FF8080FF808090C8EB6BBCE7FF8080FF8080FF8080
          0000}
        FieldsListOptions.TypeColumnOptions.FontColor = clGrayText
        FieldsListOptions.DescriptionColumnOptions.FontColor = clGrayText
        Align = alClient
        Constraints.MinHeight = 96
        TabOrder = 1
        OnDragDrop = FQueryBuilderDragDrop
        OnDragOver = FQueryBuilderDragOver
        OnEnter = FQueryBuilderEnter
        OnExit = FQueryBuilderExit
        OnResize = FQueryBuilderResize
      end
    end
    object PDataBrowser: TPanel_Ext
      Left = 0
      Top = 56
      Width = 467
      Height = 25
      Align = alTop
      BevelOuter = bvNone
      Constraints.MinWidth = 467
      DoubleBuffered = False
      ParentBackground = False
      ParentDoubleBuffered = False
      TabOrder = 0
      Visible = False
      OnResize = PDataBrowserResize
      object FOffset: TEdit
        Left = 0
        Top = 0
        Width = 43
        Height = 22
        TabOrder = 0
        Text = '0'
        OnChange = FOffsetChange
        OnKeyPress = FOffsetKeyPress
      end
      object FUDOffset: TUpDown
        Left = 43
        Top = 0
        Width = 15
        Height = 22
        Associate = FOffset
        Max = 2147483647
        TabOrder = 1
        Thousands = False
      end
      object FLimit: TEdit
        Left = 59
        Top = 0
        Width = 36
        Height = 22
        TabOrder = 2
        Text = '100'
        OnChange = FLimitChange
        OnKeyPress = FOffsetKeyPress
      end
      object FUDLimit: TUpDown
        Left = 95
        Top = 0
        Width = 15
        Height = 22
        Associate = FLimit
        Min = 1
        Max = 2147483647
        Increment = 10
        Position = 100
        TabOrder = 3
        Thousands = False
      end
      object TBLimitEnabled: TToolBar
        Left = 111
        Top = 0
        Width = 31
        Height = 23
        Align = alNone
        Caption = 'TBLimitEnabled'
        TabOrder = 4
        Transparent = True
        object FLimitEnabled: TToolButton
          Left = 0
          Top = 0
          Caption = 'FLimitEnabled'
          ImageIndex = 87
          Style = tbsCheck
          OnClick = FLimitEnabledClick
        end
      end
      object FFilter: TComboBox_Ext
        Left = 142
        Top = 0
        Width = 174
        Height = 22
        TabOrder = 5
        OnChange = FFilterChange
        OnDropDown = FFilterDropDown
        OnEnter = FFilterEnter
        OnKeyPress = FFilterKeyPress
      end
      object TBFilterEnabled: TToolBar
        Left = 316
        Top = 0
        Width = 31
        Height = 23
        Align = alNone
        Caption = 'TBFilterEnabled'
        TabOrder = 6
        Transparent = True
        object FFilterEnabled: TToolButton
          Left = 0
          Top = 0
          Enabled = False
          ImageIndex = 88
          Style = tbsCheck
          OnClick = FFilterEnabledClick
        end
      end
      object FQuickSearch: TEdit
        Left = 347
        Top = 0
        Width = 140
        Height = 22
        TabOrder = 7
        OnChange = FQuickSearchChange
        OnKeyPress = FQuickSearchKeyPress
      end
      object TBQuickSearchEnabled: TToolBar
        Left = 487
        Top = 0
        Width = 23
        Height = 22
        Align = alNone
        AutoSize = True
        TabOrder = 8
        Transparent = True
        object FQuickSearchEnabled: TToolButton
          Left = 0
          Top = 0
          Enabled = False
          ImageIndex = 89
          Style = tbsCheck
          OnClick = FQuickSearchEnabledClick
        end
      end
      object PDataBrowserSpacer: TPanel_Ext
        Left = 0
        Top = 22
        Width = 467
        Height = 3
        Align = alBottom
        BevelOuter = bvNone
        ParentBackground = False
        TabOrder = 9
      end
    end
    object PObjectIDE: TPanel_Ext
      Left = 0
      Top = 81
      Width = 467
      Height = 79
      Align = alTop
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 4
      Visible = False
      OnResize = PObjectIDEResize
      object PObjectIDESpacer: TPanel_Ext
        Left = 0
        Top = 35
        Width = 467
        Height = 3
        Align = alBottom
        BevelOuter = bvNone
        ParentBackground = False
        TabOrder = 0
      end
      object FObjectIDEGrid: TMySQLDBGrid
        Left = 0
        Top = 0
        Width = 467
        Height = 35
        HelpContext = 1122
        Align = alClient
        BorderStyle = bsNone
        DataSource = PObjectIDEGridDataSource
        DefaultDrawing = False
        Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete]
        ParentShowHint = False
        ShowHint = False
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        OnColEnter = DBGridColEnter
        OnColExit = DBGridColExit
        OnDrawColumnCell = DBGridDrawColumnCell
        OnEnter = DBGridEnter
        OnExit = DBGridExit
      end
      object PObjectIDETrigger: TPanel_Ext
        Left = 0
        Top = 38
        Width = 467
        Height = 41
        Align = alBottom
        BevelOuter = bvNone
        ParentBackground = False
        TabOrder = 2
        Visible = False
        object BINSERT: TButton
          Left = 6
          Top = 10
          Width = 89
          Height = 25
          Caption = 'INSERT'
          TabOrder = 0
          OnClick = BObjectIDEClick
        end
        object BREPLACE: TButton
          Left = 112
          Top = 8
          Width = 89
          Height = 25
          Caption = 'REPLACE'
          TabOrder = 1
          OnClick = BObjectIDEClick
        end
        object BUPDATE: TButton
          Left = 216
          Top = 8
          Width = 89
          Height = 25
          Caption = 'UPDATE'
          TabOrder = 2
          OnClick = BObjectIDEClick
        end
        object BDELETE: TButton
          Left = 320
          Top = 8
          Width = 89
          Height = 25
          Caption = 'DELETE'
          TabOrder = 3
          OnClick = BObjectIDEClick
        end
      end
    end
    object PBlob: TPanel_Ext
      Left = 0
      Top = 186
      Width = 467
      Height = 59
      Align = alBottom
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Constraints.MinHeight = 50
      ParentBackground = False
      TabOrder = 6
      Visible = False
      object FImage: TImage
        Left = 2
        Top = 25
        Width = 463
        Height = 32
        Align = alClient
        Center = True
        PopupMenu = MText
        Proportional = True
        ExplicitTop = 27
        ExplicitWidth = 315
        ExplicitHeight = 30
      end
      object PToolBarBlob: TPanel_Ext
        Left = 2
        Top = 2
        Width = 463
        Height = 23
        Align = alTop
        AutoSize = True
        BevelOuter = bvNone
        DoubleBuffered = False
        ParentBackground = False
        ParentDoubleBuffered = False
        TabOrder = 3
        OnResize = PToolBarBlobResize
        object TBBlob: TToolBar
          Left = 0
          Top = 0
          Width = 463
          Height = 23
          ButtonWidth = 97
          Color = clBtnFace
          DoubleBuffered = False
          ParentColor = False
          ParentDoubleBuffered = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = False
          Wrapable = False
          object tbBlobText: TToolButton
            Left = 0
            Top = 0
            Action = aVBlobText
            AutoSize = True
            Grouped = True
            Style = tbsCheck
          end
          object tbBlobRTF: TToolButton
            Left = 74
            Top = 0
            Action = aVBlobRTF
            AutoSize = True
            Grouped = True
            Style = tbsCheck
          end
          object tbBlobHTML: TToolButton
            Left = 143
            Top = 0
            Action = aVBlobHTML
            AutoSize = True
            Grouped = True
            Style = tbsCheck
          end
          object tbBlobImage: TToolButton
            Left = 222
            Top = 0
            Action = aVBlobImage
            AutoSize = True
            Grouped = True
            Style = tbsCheck
          end
          object tbBlobHexEditor: TToolButton
            Left = 304
            Top = 0
            Action = aVBlobHexEditor
            AutoSize = True
            Grouped = True
            Style = tbsCheck
          end
        end
      end
      object FText: TRichEdit
        Left = 2
        Top = 25
        Width = 463
        Height = 32
        Align = alClient
        BorderStyle = bsNone
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        HideSelection = False
        ParentFont = False
        PopupMenu = MText
        ScrollBars = ssVertical
        TabOrder = 0
        WantTabs = True
        OnChange = FTextChange
        OnEnter = FTextEnter
        OnExit = FTextExit
        OnKeyPress = FTextKeyPress
        OnKeyUp = FTextKeyUp
        OnMouseUp = FTextMouseUp
      end
      object FRTF: TRichEdit
        Left = 2
        Top = 25
        Width = 463
        Height = 32
        Align = alClient
        BorderStyle = bsNone
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Lines.Strings = (
          'FRTF')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 1
        WordWrap = False
        OnChange = FRTFChange
        OnEnter = FRTFEnter
        OnExit = FRTFExit
      end
      object FHexEditor: TMPHexEditorEx
        Left = 2
        Top = 25
        Width = 463
        Height = 32
        Cursor = crIBeam
        BackupExtension = '.bak'
        PrintOptions.MarginLeft = 20
        PrintOptions.MarginTop = 15
        PrintOptions.MarginRight = 25
        PrintOptions.MarginBottom = 25
        PrintOptions.Flags = [pfSelectionBold, pfMonochrome]
        PrintFont.Charset = DEFAULT_CHARSET
        PrintFont.Color = clWindowText
        PrintFont.Height = -15
        PrintFont.Name = 'Courier New'
        PrintFont.Style = []
        Align = alClient
        BorderStyle = bsNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        OnEnter = FHexEditorEnter
        OnKeyPress = FHexEditorKeyPress
        ParentFont = False
        PopupMenu = MText
        TabOrder = 2
        BytesPerRow = 16
        BytesPerColumn = 1
        Translation = tkAsIs
        OffsetFormat = '-!10:|'
        Colors.Background = clWindow
        Colors.ChangedBackground = 11075583
        Colors.ChangedText = clMaroon
        Colors.CursorFrame = clNavy
        Colors.Offset = clBlack
        Colors.OddColumn = clWindowText
        Colors.EvenColumn = clWindowText
        Colors.CurrentOffsetBackground = clBtnShadow
        Colors.OffsetBackground = clBtnFace
        Colors.CurrentOffset = clBtnHighlight
        Colors.Grid = clBtnFace
        Colors.NonFocusCursorFrame = clAqua
        Colors.ActiveFieldBackground = clWindow
        FocusFrame = True
        DrawGridLines = False
        GraySelectionIfNotFocused = True
        Version = 'september 30, 2007; '#169' markus stephany, vcl[at]mirkes[dot]de'
        OnChange = FHexEditorChange
        BytesPerBlock = 8
        SeparateBlocksInCharField = False
      end
    end
    object PWorkbench: TPanel_Ext
      Left = 0
      Top = 360
      Width = 467
      Height = 50
      HelpContext = 1125
      Align = alTop
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Color = clWindow
      Constraints.MinHeight = 20
      ParentBackground = False
      TabOrder = 7
      Visible = False
    end
  end
  object PHeader: TPanel_Ext
    Left = 0
    Top = 0
    Width = 591
    Height = 22
    Align = alTop
    BevelOuter = bvNone
    DoubleBuffered = False
    ParentBackground = False
    ParentDoubleBuffered = False
    TabOrder = 3
    OnMouseDown = PanelMouseDown
    OnMouseUp = PanelMouseUp
    OnResize = PHeaderResize
    OnPaint = PHeaderPaint
    DesignSize = (
      591
      22)
    object TBSideBar: TToolBar
      Left = 2
      Top = 0
      Width = 69
      Height = 22
      Align = alNone
      AutoSize = True
      TabOrder = 0
      Transparent = True
      Wrapable = False
      OnResize = ToolBarResize
      object tbNavigator: TToolButton
        Left = 0
        Top = 0
        Caption = 'tbNavigator'
        Grouped = True
        Style = tbsCheck
      end
      object tbExplorer: TToolButton
        Left = 23
        Top = 0
        Caption = 'tbExplorer'
        Grouped = True
        Style = tbsCheck
      end
      object tbSQLHistory: TToolButton
        Left = 46
        Top = 0
        Caption = 'tbSQLHistory'
        Grouped = True
        Style = tbsCheck
      end
    end
    object ToolBar: TToolBar
      Left = 124
      Top = 0
      Width = 508
      Height = 20
      Align = alNone
      AutoSize = True
      ButtonHeight = 20
      ButtonWidth = 68
      List = True
      PopupMenu = MToolBar
      ShowCaptions = True
      TabOrder = 1
      Transparent = True
      Wrapable = False
      OnResize = ToolBarResize
      object tbObjects: TToolButton
        Left = 0
        Top = 0
        AutoSize = True
        Caption = 'tbObjects'
        ImageIndex = 1
        PopupMenu = MToolBar
        Style = tbsCheck
      end
      object tbBrowser: TToolButton
        Left = 70
        Top = 0
        AutoSize = True
        Caption = 'tbBrowser'
        ImageIndex = 2
        PopupMenu = MToolBar
        Style = tbsCheck
      end
      object tbIDE: TToolButton
        Left = 142
        Top = 0
        AutoSize = True
        Caption = 'tbIDE'
        PopupMenu = MToolBar
        Style = tbsCheck
        Visible = False
      end
      object tbBuilder: TToolButton
        Left = 184
        Top = 0
        AutoSize = True
        Caption = 'tbBuilder'
        ImageIndex = 0
        PopupMenu = MToolBar
        Style = tbsCheck
      end
      object tbDiagram: TToolButton
        Left = 248
        Top = 0
        AutoSize = True
        Caption = 'tbDiagram'
        PopupMenu = MToolBar
        Style = tbsCheck
      end
      object tbEditor: TToolButton
        Left = 314
        Top = 0
        AutoSize = True
        Caption = 'tbEditor'
        ImageIndex = 3
        PopupMenu = MToolBar
        Style = tbsCheck
      end
      object tbEditor2: TToolButton
        Left = 374
        Top = 0
        AutoSize = True
        Caption = 'tbEditor2'
        ImageIndex = 3
        PopupMenu = MToolBar
        Style = tbsCheck
      end
      object tbEditor3: TToolButton
        Left = 441
        Top = 0
        AutoSize = True
        Caption = 'tbEditor3'
        ImageIndex = 3
        PopupMenu = MToolBar
        Style = tbsCheck
      end
    end
    object FObjectSearch: TEdit
      Left = 32752
      Top = 0
      Width = 140
      Height = 22
      TabStop = False
      Anchors = []
      TabOrder = 2
      Visible = False
      OnChange = FObjectSearchChange
      OnExit = FObjectSearchExit
      OnKeyPress = FObjectSearchKeyPress
      OnMouseDown = FObjectSearchMouseDown
    end
    object TBObjectSearch: TToolBar
      Left = 32752
      Top = 0
      Width = 23
      Height = 22
      Align = alNone
      Anchors = []
      TabOrder = 3
      Transparent = True
      Visible = False
      object FObjectSearchStart: TToolButton
        Left = 0
        Top = 0
        Caption = 'FObjectSearchStart'
        Enabled = False
        ImageIndex = 89
        OnClick = FObjectSearchStartClick
      end
    end
  end
  object MList: TPopupMenu
    OnPopup = MListPopup
    Left = 144
    Top = 48
    object mlOpen: TMenuItem
      Caption = 'mlOpen'
      OnClick = mlOpenClick
    end
    object mlFImport: TMenuItem
      Caption = 'mlFImport'
      object mlFImportSQL: TMenuItem
        Caption = 'aFImportSQL'
      end
      object mlFImportText: TMenuItem
        Caption = 'aFImportText'
      end
      object mlFImportExcel: TMenuItem
        Caption = 'aFImportExcel'
      end
      object mlFImportAccess: TMenuItem
        Caption = 'aFImportAccess'
      end
      object mlFImportODBC: TMenuItem
        Caption = 'aFImportODBC'
      end
    end
    object mlFExport: TMenuItem
      Caption = 'mlFExport'
      object mlFExportSQL: TMenuItem
        Caption = 'aFExportSQL'
      end
      object mlFExportText: TMenuItem
        Caption = 'aFExportText'
      end
      object mlFExportExcel: TMenuItem
        Caption = 'aFExportExcel'
      end
      object mlFExportAccess: TMenuItem
        Caption = 'aFExportAccess'
      end
      object mlFExportODBC: TMenuItem
        Caption = 'aFExportODBC'
      end
      object mlFExportXML: TMenuItem
        Caption = 'aFExportXML'
      end
      object mlFExportHTML: TMenuItem
        Caption = 'aFExportHTML'
      end
      object mlFExportPDF: TMenuItem
        Caption = 'aFExportPDF'
      end
    end
    object N02: TMenuItem
      Caption = '-'
    end
    object mlECopy: TMenuItem
      Caption = 'aECopy'
    end
    object mlEPaste: TMenuItem
      Caption = 'aEPaste'
    end
    object N03: TMenuItem
      Caption = '-'
    end
    object mlDCreate: TMenuItem
      Caption = 'mlDCreate'
      object mlDCreateDatabase: TMenuItem
        Caption = 'aDCreateDatabase'
      end
      object mlDCreateTable: TMenuItem
        Caption = 'aDCreateTable'
      end
      object mlDCreateView: TMenuItem
        Caption = 'aDCreateView'
      end
      object mlDCreateProcedure: TMenuItem
        Caption = 'aDCreateProcedure'
      end
      object mlDCreateFunction: TMenuItem
        Caption = 'aDCreateFunction'
      end
      object mlDCreateEvent: TMenuItem
        Caption = 'aDCreateEvent'
      end
      object mlDCreateIndex: TMenuItem
        Caption = 'aDCreateIndex'
      end
      object mlDCreateField: TMenuItem
        Caption = 'aDCreateField'
      end
      object mlDCreateForeignKey: TMenuItem
        Caption = 'aDCreateForeignKey'
      end
      object mlDCreateTrigger: TMenuItem
        Caption = 'aDCreateTrigger'
      end
      object mlDCreateUser: TMenuItem
        Caption = 'aDCreateUser'
      end
    end
    object mlDDelete: TMenuItem
      Action = aDDelete
    end
    object N04: TMenuItem
      Caption = '-'
    end
    object mlDEmpty: TMenuItem
      Caption = 'aDEmpty'
    end
    object N05: TMenuItem
      Caption = '-'
    end
    object mlERename: TMenuItem
      Caption = 'aERename'
      ShortCut = 113
    end
    object mlEProperties: TMenuItem
      Caption = 'mlEProperties'
      Visible = False
    end
  end
  object ActionList: TActionList
    Left = 8
    Top = 112
    object aTBOffset: TAction
      Category = 'ToolBar'
      Caption = 'aTBOffset'
      ShortCut = 24655
      OnExecute = aTBOffsetExecute
    end
    object aTBLimit: TAction
      Category = 'ToolBar'
      Caption = 'aTBLimit'
      ShortCut = 24652
      OnExecute = aTBLimitExecute
    end
    object aTBFilter: TAction
      Category = 'ToolBar'
      Caption = 'aTBFilter'
      ShortCut = 24646
      OnExecute = aTBFilterExecute
    end
    object aEClearAll: TAction
      Category = 'Edit'
      Caption = 'aEClearAll'
      ShortCut = 16471
      OnExecute = aEClearAllExecute
    end
    object aPCollapse: TAction
      Caption = 'aPCollapse'
      OnExecute = aPCollapseExecute
    end
    object aDCreate: TAction
      Category = 'Database'
      Caption = 'aDCreate'
      OnExecute = aDCreateExecute
    end
    object aDDelete: TAction
      Category = 'Database'
      Caption = 'aDDelete'
      OnExecute = aDDeleteExecute
    end
    object aDNext: TAction
      Category = 'Database'
      Enabled = False
      ImageIndex = 58
      OnExecute = aDNextExecute
    end
    object aPExpand: TAction
      Caption = 'aPExpand'
      OnExecute = aPExpandExecute
    end
    object aDPrev: TAction
      Category = 'Database'
      Enabled = False
      ImageIndex = 57
      OnExecute = aDPrevExecute
    end
    object DataSetDelete: TDataSetDelete
      Category = 'Database'
    end
    object DataSetFirst: TDataSetFirst
      Category = 'Database'
      ImageIndex = 53
    end
    object DataSetLast: TDataSetLast
      Category = 'Database'
      ImageIndex = 54
    end
    object DataSetPost: TDataSetPost
      Category = 'Database'
      ImageIndex = 55
    end
    object DataSetCancel: TDataSetCancel
      Category = 'Database'
      ImageIndex = 56
    end
    object aTBQuickSearch: TAction
      Category = 'ToolBar'
      Caption = 'aTBQuickSearch'
      ShortCut = 24659
      OnExecute = aTBQuickSearchExecute
    end
    object aPResult: TAction
      Caption = 'aPResult'
      OnExecute = aPResultExecute
    end
    object aVBlobText: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'aVBlobText'
      GroupIndex = 1
      OnExecute = aVBlobExecute
    end
    object aVBlobRTF: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'aVBlobRTF'
      GroupIndex = 1
      OnExecute = aVBlobExecute
    end
    object aVBlobHTML: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'aVBlobHTML'
      GroupIndex = 1
      OnExecute = aVBlobExecute
    end
    object aVBlobImage: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'aVBlobImage'
      GroupIndex = 1
      OnExecute = aVBlobExecute
    end
    object aVBlobHexEditor: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'aVBlobHexEditor'
      GroupIndex = 1
      OnExecute = aVBlobExecute
    end
    object aHRun: TAction
      Caption = 'aHRun'
      OnExecute = aHRunExecute
    end
    object aSynCompletionExecute: TAction
      Caption = 'aSynCompletionExecute'
      OnExecute = aSynCompletionExecuteExecute
    end
  end
  object MNavigator: TPopupMenu
    OnPopup = MNavigatorPopup
    Left = 8
    Top = 152
    object miNExpand: TMenuItem
      Action = aPExpand
      Visible = False
    end
    object miNCollapse: TMenuItem
      Action = aPCollapse
      Visible = False
    end
    object miNImport: TMenuItem
      Caption = 'miNImport'
      object miNImportSQL: TMenuItem
        Caption = 'aFImportSQL'
      end
      object miNImportText: TMenuItem
        Caption = 'aFImportText'
      end
      object miNImportExcel: TMenuItem
        Caption = 'aFImportExcel'
      end
      object miNImportAccess: TMenuItem
        Caption = 'aFImportAccess'
      end
      object miNImportODBC: TMenuItem
        Caption = 'aFImportODBC'
      end
    end
    object miNExport: TMenuItem
      Caption = 'miNExport'
      object miNExportSQL: TMenuItem
        Caption = 'aFExportSQL'
      end
      object miNExportText: TMenuItem
        Caption = 'aFExportText'
      end
      object miNExportExcel: TMenuItem
        Caption = 'aFExportExcel'
      end
      object miNExportAccess: TMenuItem
        Caption = 'aFExportAccess'
      end
      object miNExportODBC: TMenuItem
        Caption = 'aFExportODBC'
      end
      object miNExportXML: TMenuItem
        Caption = 'aFExportXML'
      end
      object miNExportHTML: TMenuItem
        Caption = 'aFExportHTML'
      end
      object miNExportPDF: TMenuItem
        Caption = 'aFExportPDF'
      end
    end
    object N07: TMenuItem
      Caption = '-'
    end
    object miNCopy: TMenuItem
      Caption = 'miNCopy'
    end
    object miNPaste: TMenuItem
      Caption = 'miNPaste'
    end
    object N08: TMenuItem
      Caption = '-'
    end
    object miNCreate: TMenuItem
      Caption = 'miNCreate'
      object miNCreateDatabase: TMenuItem
        Caption = 'aDCreateDatabase'
      end
      object miNCreateTable: TMenuItem
        Caption = 'aDCreateTable'
      end
      object miNCreateView: TMenuItem
        Caption = 'aDCreateView'
      end
      object miNCreateProcedure: TMenuItem
        Caption = 'aDCreateProcedure'
      end
      object miNCreateFunction: TMenuItem
        Caption = 'aDCreateRoutine'
      end
      object miNCreateEvent: TMenuItem
        Caption = 'aDCreateEvent'
      end
      object miNCreateIndex: TMenuItem
        Caption = 'aDCreateIndex'
      end
      object miNCreateField: TMenuItem
        Caption = 'aDCreateField'
      end
      object miNCreateForeignKey: TMenuItem
        Caption = 'aDCreateForeignKey'
      end
      object miNCreateTrigger: TMenuItem
        Caption = 'aDCreateTrigger'
      end
      object miNCreateUser: TMenuItem
        Caption = 'aDCreateUser'
      end
    end
    object miNDelete: TMenuItem
      Action = aDDelete
    end
    object N09: TMenuItem
      Caption = '-'
    end
    object miNEmpty: TMenuItem
      Caption = 'aDEmpty'
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object miNRename: TMenuItem
      Caption = 'aERename'
      ShortCut = 113
    end
    object miNProperties: TMenuItem
      Caption = 'miNProperties'
      Visible = False
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object miNFavoriteAdd: TMenuItem
      Caption = 'miNFavoriteAdd'
      OnClick = miNFavoriteAddClick
    end
    object miNFavoriteOpen: TMenuItem
      Caption = 'miNFavoriteOpen'
      OnClick = miNFavoriteOpenClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object miNFavoriteRemove: TMenuItem
      Caption = 'miNFavoriteRemove'
      OnClick = miNFavoriteRemoveClick
    end
  end
  object MLog: TPopupMenu
    Left = 72
    Top = 616
    object smECopy: TMenuItem
      Caption = 'aECopy'
    end
    object smEEmpty: TMenuItem
      Caption = 'smEEmpty'
      OnClick = smEEmptyClick
    end
    object smN1: TMenuItem
      Caption = '-'
    end
    object smESelectAll: TMenuItem
      Caption = 'aESelectAll'
    end
  end
  object FGridDataSource: TDataSource
    OnDataChange = DBGridDataSourceDataChange
    Left = 136
    Top = 472
  end
  object MGrid: TPopupMenu
    OnPopup = MGridPopup
    Left = 184
    Top = 472
    object gmDInsertRecord: TMenuItem
      Caption = 'aDInsertRecord'
    end
    object gmDDeleteRecord: TMenuItem
      Caption = 'aDDeleteRecord'
    end
    object gmDEditRecord: TMenuItem
      Caption = 'aDEditRecord'
    end
    object N12: TMenuItem
      Caption = '-'
    end
    object gmECut: TMenuItem
      Caption = 'aECut'
      ShortCut = 16472
    end
    object gmECopy: TMenuItem
      Caption = 'aECopy'
      ShortCut = 16451
    end
    object gmEPaste: TMenuItem
      Caption = 'aEPaste'
      ShortCut = 16470
    end
    object gmEDelete: TMenuItem
      Caption = 'aEDelete'
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object gmEmpty: TMenuItem
      Caption = 'aDEmpty'
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object gmECopyToFile: TMenuItem
      Caption = 'aCopyToFile'
      OnClick = DBGridCopyToExecute
    end
    object gmEPasteFromFile: TMenuItem
      Caption = 'aPasteFromFile'
      OnClick = aEPasteFromFileExecute
    end
    object N14: TMenuItem
      Caption = '-'
    end
    object gmFExport: TMenuItem
      Caption = 'aFExport'
      object gmFExportSQL: TMenuItem
        Caption = 'aFExportSQL'
      end
      object gmFExportText: TMenuItem
        Caption = 'aFExportText'
      end
      object gmFExportExcel: TMenuItem
        Caption = 'aFExportExcel'
      end
      object gmFExportXML: TMenuItem
        Caption = 'aFExportXML'
      end
      object gmFExportHTML: TMenuItem
        Caption = 'aFExportHTML'
      end
      object gmFExportPDF: TMenuItem
        Caption = 'aFExportPDF'
      end
    end
    object N15: TMenuItem
      Caption = '-'
    end
    object gmFilter: TMenuItem
      Caption = 'gmFilter'
    end
  end
  object MSQLEditor: TPopupMenu
    OnPopup = MSQLEditorPopup
    Left = 152
    Top = 208
    object mpDRun: TMenuItem
      Caption = 'aDRun'
    end
    object mpDRunSelection: TMenuItem
      Caption = 'aDRunSelection'
    end
    object N16: TMenuItem
      Caption = '-'
    end
    object mpECut: TMenuItem
      Caption = 'mpECut'
    end
    object mpECopy: TMenuItem
      Caption = 'mpECopy'
    end
    object mpEPaste: TMenuItem
      Caption = 'mpEPaste'
    end
    object mpEDelete: TMenuItem
      Caption = 'mpEDelete'
    end
    object N17: TMenuItem
      Caption = '-'
    end
    object mpECopyToFile: TMenuItem
      Caption = 'mpECopyToFile'
    end
    object mpEPasteFromFile: TMenuItem
      Caption = 'mpEPasteFromFile'
    end
    object N18: TMenuItem
      Caption = '-'
    end
    object mpESelectAll: TMenuItem
      Caption = 'mpESelectAll'
    end
  end
  object MText: TPopupMenu
    OnPopup = MTextPopup
    Left = 144
    Top = 544
    object tmECut: TMenuItem
      Caption = 'aECut'
    end
    object tmECopy: TMenuItem
      Caption = 'aECopy'
    end
    object tmEPaste: TMenuItem
      Caption = 'aEPaste'
    end
    object tmEDelete: TMenuItem
      Caption = 'aEDelete'
    end
    object N19: TMenuItem
      Caption = '-'
    end
    object tmESelectAll: TMenuItem
      Caption = 'aESelectAll'
    end
  end
  object FSQLEditorSearch: TSynEditSearch
    Left = 192
    Top = 208
  end
  object MGridHeader: TPopupMenu
    OnPopup = MGridHeaderPopup
    Left = 217
    Top = 472
    object ghmGoto: TMenuItem
      Caption = 'ghmGoto'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ghmCopy: TMenuItem
      Caption = 'ghmCopy'
      OnClick = ghmCopyClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object ghmSelectAll: TMenuItem
      Caption = 'ghmSelectAll'
      OnClick = ghmSelectAllClick
    end
  end
  object MSideBar: TPopupMenu
    Left = 8
    Top = 73
    object miSNavigator: TMenuItem
      Caption = 'miSNavigator'
    end
    object miSSQLHistory: TMenuItem
      Caption = 'miSSQLHistory'
    end
  end
  object MFiles: TPopupMenu
    OnPopup = MFilesPopup
    Left = 8
    Top = 182
    object mfOpen: TMenuItem
      Caption = 'mfOpen'
      Default = True
      OnClick = mfOpenClick
    end
    object N30: TMenuItem
      Caption = '-'
    end
    object mfFilter: TMenuItem
      Caption = 'mfFilter'
      object mfFilterClear: TMenuItem
        AutoCheck = True
        Caption = 'mfFilterClear'
        RadioItem = True
        OnClick = mfFilterClearClick
      end
      object N31: TMenuItem
        Caption = '-'
      end
      object mfFilterSQL: TMenuItem
        Caption = 'mfFilterSQL'
        RadioItem = True
        OnClick = mfFilterSQLClick
      end
      object mfFilterText: TMenuItem
        Caption = 'mfFilterText'
        RadioItem = True
        OnClick = mfFilterTextClick
      end
      object mfFilterExcel: TMenuItem
        Caption = 'mfFilterExcel'
        RadioItem = True
        OnClick = mfFilterExcelClick
      end
      object mfFilterAccess: TMenuItem
        Caption = 'mfFilterAccess'
        RadioItem = True
        OnClick = mfFilterAccessClick
      end
      object mfFilterHTML: TMenuItem
        Caption = 'mfFilterHTML'
        RadioItem = True
        OnClick = mfFilterHTMLClick
      end
      object mfFilterXML: TMenuItem
        Caption = 'mfFilterXML'
        RadioItem = True
        OnClick = mfFilterXMLClick
      end
    end
    object N32: TMenuItem
      Caption = '-'
    end
    object mfDelete: TMenuItem
      Caption = 'mfDelete'
      OnClick = mfDeleteClick
    end
    object mfRename: TMenuItem
      Caption = 'mfRename'
      OnClick = mfRenameClick
    end
    object N33: TMenuItem
      Caption = '-'
    end
    object mfProperties: TMenuItem
      Caption = 'mfProperties'
      OnClick = mfPropertiesClick
    end
  end
  object MSQLHistory: TPopupMenu
    OnPopup = MSQLHistoryPopup
    Left = 8
    Top = 216
    object miHStatementIntoSQLEditor: TMenuItem
      Caption = 'miHStatementIntoSQLEditor'
      OnClick = miHStatementIntoSQLEditorClick
    end
    object N21: TMenuItem
      Caption = '-'
    end
    object miHExpand: TMenuItem
      Action = aPExpand
    end
    object miHCollapse: TMenuItem
      Action = aPCollapse
    end
    object N22: TMenuItem
      Caption = '-'
    end
    object miHOpen: TMenuItem
      Caption = 'miHOpen'
      OnClick = miHOpenClick
    end
    object N23: TMenuItem
      Caption = '-'
    end
    object miHRun: TMenuItem
      Action = aHRun
    end
    object N24: TMenuItem
      Caption = '-'
    end
    object miHCopy: TMenuItem
      Caption = 'aECopy'
    end
    object N25: TMenuItem
      Caption = '-'
    end
    object miHProperties: TMenuItem
      Caption = 'miHProperties'
      OnClick = miHPropertiesClick
    end
  end
  object SQLBuilder: TacSQLBuilderPlainText
    OnSQLUpdated = FQueryBuilderSQLUpdated
    QueryBuilder = FQueryBuilder
    KeywordFormat = akfUpperCase
    QuoteAllIdentifiers = True
    MainQueryFormat.NewLineAfterPartKeywords = True
    MainQueryFormat.WhereFormat.NewLineAfter = nlAllLogical
    ExpressionsSubQueryFormat.MainPartsFromNewLine = False
    ExpressionsSubQueryFormat.FromClauseFormat.NewLineAfterDatasource = False
    Left = 232
    Top = 120
  end
  object PObjectIDEGridDataSource: TDataSource
    Enabled = False
    Left = 152
    Top = 160
  end
  object MWorkbench: TPopupMenu
    OnPopup = MWorkbenchPopup
    Left = 152
    Top = 392
    object mwFImport: TMenuItem
      Caption = 'mwFImport'
      object mwFImportSQL: TMenuItem
        Caption = 'aFImportSQL'
      end
      object mwFImportText: TMenuItem
        Caption = 'aFImportText'
      end
      object mwFImportExcel: TMenuItem
        Caption = 'aFImportExcel'
      end
      object mwFImportAccess: TMenuItem
        Caption = 'aFImportAccess'
      end
      object mwFImportODBC: TMenuItem
        Caption = 'aFImportODBC'
      end
    end
    object mwFExport: TMenuItem
      Caption = 'mwFExport'
      object mwFExportSQL: TMenuItem
        Caption = 'aFExportSQL'
      end
      object mwFExportText: TMenuItem
        Caption = 'aFExportText'
      end
      object mwFExportExcel: TMenuItem
        Caption = 'aFExportExcel'
      end
      object mwFExportAccess: TMenuItem
        Caption = 'aFExportAccess'
      end
      object mwFExportODBC: TMenuItem
        Caption = 'aFExportODBC'
      end
      object mwFExportXML: TMenuItem
        Caption = 'aFExportXML'
      end
      object mwFExportHTML: TMenuItem
        Caption = 'aFExportHTML'
      end
      object mwFExportPDF: TMenuItem
        Caption = 'aFExportPDF'
      end
      object mwFExportBitmap: TMenuItem
        Caption = 'aFExportBitmap'
      end
    end
    object N27: TMenuItem
      Caption = '-'
    end
    object mwAddTable: TMenuItem
      Caption = 'mwAddTable'
    end
    object mwECopy: TMenuItem
      Caption = 'mwECopy'
    end
    object mwEPaste: TMenuItem
      Caption = 'mwEPaste'
      OnClick = mwEPasteClick
    end
    object mwEDelete: TMenuItem
      Caption = 'mwEDelete'
      OnClick = mwEDeleteClick
    end
    object N28: TMenuItem
      Caption = '-'
    end
    object mwDCreate: TMenuItem
      Caption = 'mwDCreate'
      object mwDCreateTable: TMenuItem
        Caption = 'mwDCreateTable'
        OnClick = mwDCreateTableClick
      end
      object mwDCreateField: TMenuItem
        Caption = 'mwDCreateField'
      end
      object mwDCreateForeignKey: TMenuItem
        Caption = 'mwDCreateForeignKey'
      end
      object mwCreateSection: TMenuItem
        Caption = 'mwCreateSection'
        Enabled = False
        OnClick = mwCreateSectionClick
      end
      object mwCreateLink: TMenuItem
        Caption = 'mwCreateLink'
        Enabled = False
        OnClick = mwCreateLinkExecute
      end
    end
    object mwDDelete: TMenuItem
      Action = aDDelete
    end
    object N29: TMenuItem
      Caption = '-'
    end
    object mwDEmpty: TMenuItem
      Caption = 'mwDEmpty'
    end
    object N34: TMenuItem
      Caption = '-'
    end
    object mwDProperties: TMenuItem
      Caption = 'mwDProperties'
      Default = True
      OnClick = aDPropertiesExecute
    end
  end
  object MToolBar: TPopupMenu
    OnPopup = MToolBarPopup
    Left = 160
    Top = 8
    object mtObjects: TMenuItem
      Caption = 'mtObjects'
      OnClick = ToolBarTabsClick
    end
    object mtBrowser: TMenuItem
      Caption = 'mtBrowser'
      OnClick = ToolBarTabsClick
    end
    object mtIDE: TMenuItem
      Caption = 'mtIDE'
      OnClick = ToolBarTabsClick
    end
    object mtBuilder: TMenuItem
      Caption = 'mtBuilder'
      OnClick = ToolBarTabsClick
    end
    object mtDiagram: TMenuItem
      Caption = 'mtDiagram'
      OnClick = ToolBarTabsClick
    end
    object mtEditor: TMenuItem
      Caption = 'mtEditor'
      OnClick = ToolBarTabsClick
    end
    object mtEditor2: TMenuItem
      Caption = 'mtEditor2'
      OnClick = ToolBarTabsClick
    end
    object mtEditor3: TMenuItem
      Caption = 'mtEditor3'
      OnClick = ToolBarTabsClick
    end
    object mtObjectSearch: TMenuItem
      Caption = 'mtObjectSearch'
      OnClick = ToolBarTabsClick
    end
  end
  object SaveDialog: TSaveDialog_Ext
    Options = [ofOverwritePrompt, ofHideReadOnly, ofExtensionDifferent, ofCreatePrompt, ofNoReadOnlyReturn, ofNoNetworkButton, ofEnableSizing]
    EncodingIndex = -1
    EncodingLabel = '&Encoding:'
    Left = 64
    Top = 112
  end
  object OpenDialog: TOpenDialog_Ext
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofNoNetworkButton, ofEnableSizing]
    EncodingIndex = -1
    EncodingLabel = '&Encoding:'
    Left = 64
    Top = 72
  end
  object SynCompletion: TSynCompletionProposal
    Options = [scoLimitToMatchedText, scoUseInsertList, scoEndCharCompletion, scoConsiderWordBreakChars, scoCompleteWithEnter]
    EndOfTokenChr = '()[]. '
    TriggerChars = 
      '._$abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012345678' +
      '9'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clBtnText
    TitleFont.Height = -12
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = [fsBold]
    Columns = <>
    OnChange = SynCompletionChange
    OnClose = SynCompletionClose
    OnExecute = SynCompletionExecute
    ShortCut = 16416
    Editor = FSQLEditorSynMemo
    OnAfterCodeCompletion = SynCompletionAfterCodeCompletion
    OnCancelled = SynCompletionCancelled
    Left = 280
    Top = 208
  end
end

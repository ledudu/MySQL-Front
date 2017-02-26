unit MySQLDBGrid;

interface {********************************************************************}

uses
  Windows, Classes, Controls, Types, Grids, Messages, DB, Graphics, DBGrids,
  StdActns, DBCtrls, ComCtrls,
  StdActns_Ext;

type
  TMySQLDBGrid = class(TDBGrid)
  type

    THeaderSplitBottonEvent = procedure(DBGrid: TMySQLDBGrid; Column: TColumn; Shift: TShiftState) of object;

    TDBMySQLGridColumns = class(TDBGridColumns)
    protected
      procedure Update(Item: TCollectionItem); override;
    end;

    TMySQLDBGridFieldList = class(TList)
    private
      FGrid: TMySQLDBGrid;
    public
      constructor Create(const AGrid: TMySQLDBGrid);
      property Grid: TMySQLDBGrid read FGrid;
    end;

    TMySQLDBGridInplaceEdit = class(TInplaceEditList)
    private
      DoNotRemove: Integer; // Why is this needed???
      // Without this, there is Access Violation while freeing TMySQLDBGrid,
      // if the InplaceEditor has been used in Delphi XE4
    protected
      procedure CloseUp(Accept: Boolean); override;
      procedure DoEditButtonClick(); override;
      procedure DropDown(); override;
      procedure KeyPress(var Key: Char); override;
    public
      constructor Create(Owner: TComponent); override;
      property Font;
    end;

  const
    tiShowHint = 1;
    tiHideHint = 2;
    tiMouseMove = 3;
  private
    AltDownAnchor: record
      Col: Longint;
    end;
    FHeaderControl: THeaderControl;
    FHeaderSplitButton: THeaderSplitBottonEvent;
    FHintWindow: THintWindow;
    FIgnoreKeyPress: Boolean;
    FListView: HWND;
    FMouseMoveCell: TGridCoord;
    FOnCanEditShow: TNotifyEvent;
    FOnCanEditShowExecuted: Boolean;
    FOnSelect: TNotifyEvent;
    FSelectedFields: TMySQLDBGridFieldList;
    IgnoreTitleClick: Boolean;
    LeftClickAnchor: record
      Col: Longint;
      Shift: TShiftState;
      Rec: Integer;
    end;
    MouseMoveTimerData: record
      HorzCounter: Integer;
      Shift: TShiftState;
      X: Integer;
      Y: Integer;
    end;
    ShiftDownAnchor: record
      Col: Longint;
      Rec: Integer;
    end;
    TitleBoldFont: TFont;
    procedure ActivateHint();
    function CalcSelText(): string;
    function CalcSQLData(): string;
    function CanvasTextWidth(const Text: string): Integer; inline;
    procedure CMFontChanged(var Message); message CM_FONTCHANGED;
    function EditCopyExecute(): Boolean;
    function EditCutExecute(): Boolean;
    function EditDeleteExecute(): Boolean;
    function GetCurrentRow(): Boolean;
    function GetHeaderControl(): THeaderControl;
    function GetSelSQLData: string;
    procedure HeaderMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure HeaderSectionClick(HeaderControl: THeaderControl; Section: THeaderSection);
    procedure HeaderSectionDrag(Sender: TObject; FromSection, ToSection: THeaderSection; var AllowDrag: Boolean);
    procedure HeaderSectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
    procedure SetHeaderColumnArrows();
    procedure WMNotify(var Msg: TWMNotify); message WM_NOTIFY;
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
  protected
    procedure BeginAutoDrag(); override;
    function CanEditShow(): Boolean; override;
    function CanGridAcceptKey(Key: Word; Shift: TShiftState): Boolean; override;
    procedure ColEnter(); override;
    function CreateColumns(): TDBGridColumns; override;
    function CreateEditor(): TInplaceEdit; override;
    procedure CreateWnd(); override;
    procedure DoEnter(); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    function GetEditLimit(): Integer; override;
    function GetSelText(): string; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Resize(); override;
    procedure TitleClick(Column: TColumn); override;
    procedure TopLeftChanged(); override;
    procedure WndProc(var Msg: TMessage); override;
    property HeaderControl: THeaderControl read FHeaderControl;
    property IgnoreKeyPress: Boolean read FIgnoreKeyPress;
  public
    procedure CopyToClipboard(); virtual;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    procedure LayoutChanged(); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    function PasteFromClipboard(): Boolean;
    function PasteText(const Text: string): Boolean;
    procedure SelectAll(); virtual;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    procedure UpdateHeader(); virtual;
    property CurrentRow: Boolean read GetCurrentRow;
    property Header: THeaderControl read GetHeaderControl;
    property MouseDownShiftState: TShiftState read LeftClickAnchor.Shift;
    property OnHeaderSplitButton: THeaderSplitBottonEvent read FHeaderSplitButton write FHeaderSplitButton;
    property SelectedFields: TMySQLDBGridFieldList read FSelectedFields;
    property SelSQLData: string read GetSelSQLData;
    property SelText: string read GetSelText;
    property DefaultRowHeight;
    property GridLineWidth;
    property InplaceEditor;
    property LeftCol;
    property Row;
    property RowCount;
    property TopRow;
    property VisibleColCount;
  published
    property OnCanEditShow: TNotifyEvent read FOnCanEditShow write FOnCanEditShow;
    property OnSelect: TNotifyEvent read FOnSelect write FOnSelect;
  end;

const
  CF_MYSQLSQLDATA = CF_PRIVATEFIRST + 1; // Is used in uBase.pas too

implementation {***************************************************************}

uses
  Forms, Themes, SysUtils, Clipbrd, Dialogs, Consts, CommCtrl, UITypes,
  DBActns, StrUtils, Math, Variants, SysConst,
  MySQLDB, CSVUtils, SQLUtils;

{ TMySQLDBGrid.TDBMySQLGridColumns ********************************************}

procedure TMySQLDBGrid.TDBMySQLGridColumns.Update(Item: TCollectionItem);
var
  I: Integer;
  Section: THeaderSection;
begin
  inherited;

  if (Assigned(TMySQLDBGrid(Grid).HeaderControl)) then
  begin
    TMySQLDBGrid(Grid).HeaderControl.Sections.BeginUpdate();
    TMySQLDBGrid(Grid).HeaderControl.Sections.Clear();

    for I := 0 to Count - 1 do
    begin
      with Items[I] do
        TMySQLDBGrid(Grid).TabStops[I + TMySQLDBGrid(Grid).IndicatorOffset] := Showing and TMySQLDBGrid(Grid).DataLink.Active and
          Assigned(Field) and not (Field.FieldKind = fkCalculated);

      if (I >= TMySQLDBGrid(Grid).LeftCol) then
      begin
        Section := TMySQLDBGrid(Grid).HeaderControl.Sections.Insert(I - TMySQLDBGrid(Grid).LeftCol);
        Section.MinWidth := TMySQLDBGrid(Grid).HeaderControl.Height;
        Section.MaxWidth := TMySQLDBGrid(Grid).Width - TMySQLDBGrid(Grid).HeaderControl.Height - GetSystemMetrics(SM_CXVSCROLL);
        if (dgColLines in TMySQLDBGrid(Grid).Options) then
          Section.Width := Items[I].Width + TMySQLDBGrid(Grid).GridLineWidth
        else
          Section.Width := Items[I].Width;
        if (Assigned(Items[I].Field)) then
          Section.Text := Items[I].Field.DisplayName;
      end;

      if (Assigned(Items[I].Field) and Items[I].Field.IsIndexField) then
        Items[I].Font.Style := Items[I].Font.Style + [fsBold]
      else
        Items[I].Font.Style := Items[I].Font.Style - [fsBold];
    end;

    TMySQLDBGrid(Grid).HeaderControl.Sections.EndUpdate();
  end;

  TMySQLDBGrid(Grid).SetHeaderColumnArrows();
  TMySQLDBGrid(Grid).Resize();
end;

{ TMySQLDBGrid.TMySQLDBGridFieldList ******************************************}

constructor TMySQLDBGrid.TMySQLDBGridFieldList.Create(const AGrid: TMySQLDBGrid);
begin
  inherited Create();

  FGrid := AGrid;
end;

{ TMySQLDBGrid.TDBMySQLInplaceEdit ********************************************}

procedure TMySQLDBGrid.TMySQLDBGridInplaceEdit.CloseUp(Accept: Boolean);
begin
  inherited;

  if (Accept and Modified) then
  begin
    TMySQLDBGrid(Grid).SelectedField.AsString := Text;
    TMySQLDBGrid(Grid).DataLink.Modified();
    TMySQLDBGrid(Grid).DataSource.DataSet.Edit();
  end;
end;

constructor TMySQLDBGrid.TMySQLDBGridInplaceEdit.Create(Owner: TComponent);
begin
  inherited;

  DoNotRemove := 0; // This avoids compiler warning only

  Color := clWindow;
end;

procedure TMySQLDBGrid.TMySQLDBGridInplaceEdit.DoEditButtonClick();
begin
  inherited;

  TMySQLDBGrid(Grid).EditButtonClick();
end;

procedure TMySQLDBGrid.TMySQLDBGridInplaceEdit.DropDown();
var
  Column: TColumn;
begin
  if (not ListVisible) then
  begin
    Column := TMySQLDBGrid(Grid).Columns[TMySQLDBGrid(Grid).SelectedIndex];
    if (ActiveList = PickList) then
    begin
      PickList.Items.Assign(Column.PickList);
      DropDownRows := Column.DropDownRows;
    end;
  end;

  inherited;
end;

procedure TMySQLDBGrid.TMySQLDBGridInplaceEdit.KeyPress(var Key: Char);
begin
  if (TMySQLDBGrid(Grid).IgnoreKeyPress) then
    Key := #0
  else
    inherited;
end;

{ TMySQLDBGrid ****************************************************************}

procedure TMySQLDBGrid.ActivateHint();
var
  I: Integer;
  LogFont: TLogFont;
  NonClientMetrics: TNonClientMetrics;
  OldActiveRecord: Integer;
  Rect: TRect;
  StringList: TStringList;
begin
  if ((0 <= FMouseMoveCell.X) and (FMouseMoveCell.X < FieldCount)
    and not (Columns[FMouseMoveCell.X].Field.DataType in BinaryDataTypes)
    and not EditorMode) then
  begin
    if (not Assigned(FHintWindow)) then
    begin
      FHintWindow := THintWindow.Create(Self);
      FHintWindow.Color := clInfoBk;
    end;

    OldActiveRecord := DataLink.ActiveRecord;
    DataLink.ActiveRecord := FMouseMoveCell.Y - 1;

    StringList := TStringList.Create();
    if (FMouseMoveCell.Y = 0) then
      StringList.Text := Columns[FMouseMoveCell.X].Field.DisplayName
    else if (Columns[FMouseMoveCell.X].Field.IsNull) then
      StringList.Text := ''
    else if (Columns[FMouseMoveCell.X].Field.DataType = ftWideMemo) then
      StringList.Text := Columns[FMouseMoveCell.X].Field.AsString
    else
      StringList.Text := Columns[FMouseMoveCell.X].Field.DisplayText;

    if (Length(StringList.Text) < 10 * 1024) then
    begin
      if (SystemParametersInfo(SPI_GETNONCLIENTMETRICS, SizeOf(NonClientMetrics), @NonClientMetrics, 0)
        and (GetObject(Columns[FMouseMoveCell.X].Font.Handle, SizeOf(LogFont), @LogFont) <> 0)) then
      begin
        LogFont.lfQuality  := NonClientMetrics.lfMessageFont.lfQuality;
        FHintWindow.Canvas.Font.Handle := CreateFontIndirect(LogFont);
      end
      else
        FHintWindow.Canvas.Font := Columns[FMouseMoveCell.X].Font;

      Rect.Left := 0;
      for I := LeftCol to FMouseMoveCell.X - 1 do
        if (Columns[I].Visible) then
          if (dgColLines in Options) then
            Inc(Rect.Left, Columns[I].Width + GridLineWidth)
          else
            Inc(Rect.Left, Columns[I].Width);
      Rect.Top := 0;
      for I := 0 to FMouseMoveCell.Y - 1 do
        if ((I > 0) and (dgRowLines in Options)) then
          Inc(Rect.Top, RowHeights[I] + GridLineWidth)
        else
          Inc(Rect.Top, RowHeights[I]);

      Rect.Left := ClientToScreen(Point(Rect.Left, Rect.Top)).X - 1;
      Rect.Top := ClientToScreen(Point(Rect.Left, Rect.Top)).Y;

      Rect.Right := 0;
      for I := 0 to StringList.Count - 1 do
        Rect.Right := Max(Rect.Right, Rect.Left + FHintWindow.Canvas.TextWidth(StringList[I]) + 6);
      Rect.Bottom := Rect.Top + FHintWindow.Canvas.TextHeight('H') * StringList.Count + 2;

      if ((Rect.Right - Rect.Left - 2 > Columns[FMouseMoveCell.X].Width)
        or (Columns[FMouseMoveCell.X].Field.DataType = ftWideMemo)
        or (StringList.Count > 1)) then
      begin
        FHintWindow.ActivateHint(Rect, StringList.Text);
        SetTimer(Handle, tiHideHint, Application.HintHidePause, nil);
      end
      else
        FreeAndNil(FHintWindow);

      StringList.Free();
      DataLink.ActiveRecord := OldActiveRecord;
    end;
  end;
end;

procedure TMySQLDBGrid.BeginAutoDrag();
begin
  if (LeftClickAnchor.Shift = []) then
    BeginDrag(False);
end;

function TMySQLDBGrid.CalcSelText(): string;
var
  Buffer: TSQLBuffer;
  FirstColumn: Boolean;
  I: Integer;
  J: Integer;
  OldRecNo: Integer;
begin
  Buffer := TSQLBuffer.Create(10240);

  if ((SelectedFields.Count = 0) and (SelectedRows.Count = 0)) then
    Buffer.Write(SelectedField.AsString)
  else if (SelectedRows.Count = 0) then
  begin
    FirstColumn := True;
    for J := 0 to Columns.Count - 1 do
      if (Columns[J].Visible and ((SelectedFields.Count = 0) or (SelectedFields.IndexOf(Columns[J].Field) >= 0))) then
      begin
        if (FirstColumn) then FirstColumn := False else Buffer.WriteChar(#9);
        Buffer.Write(Columns[J].Field.AsString);
      end;
  end
  else
  begin
    OldRecNo := DataLink.DataSet.RecNo;

    for I := 0 to SelectedRows.Count - 1 do
    begin
      DataLink.DataSet.Bookmark := SelectedRows[I];
      if (I > 0) then Buffer.Write(#13#10, 2);
      FirstColumn := True;
      for J := 0 to Columns.Count - 1 do
        if (Columns[J].Visible and ((SelectedFields.Count = 0) or (SelectedFields.IndexOf(Columns[J].Field) >= 0))) then
        begin
          if (FirstColumn) then FirstColumn := False else Buffer.WriteChar(#9);
          Buffer.Write(Columns[J].Field.AsString);
        end;
    end;

    DataLink.DataSet.RecNo := OldRecNo;
  end;

  Result := Buffer.Read();
  Buffer.Free();
end;

function TMySQLDBGrid.CalcSQLData(): string;
var
  Buffer: TSQLBuffer;
  Field: TField;
  FirstColumn: Boolean;
  I: Integer;
  J: Integer;
  OldRecNo: Integer;
begin
  Buffer := TSQLBuffer.Create(10240);

  if ((SelectedFields.Count = 0) and (SelectedRows.Count = 0)) then
    Buffer.Write(TMySQLQuery(DataLink.DataSet).SQLFieldValue(SelectedField))
  else if ((SelectedFields.Count = 0) and (Columns.Count = 1) or (SelectedFields.Count = 1)) then
  begin
    if (SelectedFields.Count = 1) then
      Field := TField(SelectedFields[0])
    else
      Field := SelectedField;

    if (SelectedRows.Count > 1) then Buffer.WriteChar('(');
    if (SelectedRows.Count = 0) then
      Buffer.Write(TMySQLQuery(DataLink.DataSet).SQLFieldValue(Field))
    else
      for I := 0 to SelectedRows.Count - 1 do
      begin
        DataLink.DataSet.Bookmark := SelectedRows[I];

        if (I > 0) then Buffer.WriteChar(',');
        Buffer.Write(TMySQLQuery(DataLink.DataSet).SQLFieldValue(Field));
      end;
    if (SelectedRows.Count > 1) then Buffer.WriteChar(')');
  end
  else if (SelectedRows.Count = 0) then
  begin
    Buffer.WriteChar('(');
    FirstColumn := True;
    for J := 0 to Columns.Count - 1 do
      if (Columns[J].Visible and ((SelectedFields.Count = 0) or (SelectedFields.IndexOf(Columns[J].Field) >= 0))) then
      begin
        if (FirstColumn) then FirstColumn := False else Buffer.WriteChar(',');
        Buffer.Write(TMySQLQuery(DataLink.DataSet).SQLFieldValue(Columns[J].Field));
      end;
    Buffer.WriteChar(')');
  end
  else
  begin
    OldRecNo := DataLink.DataSet.RecNo;

    for I := 0 to SelectedRows.Count - 1 do
    begin
      DataLink.DataSet.Bookmark := SelectedRows[I];
      if (I > 0) then Buffer.Write(',' + #13#10, 3);
      Buffer.WriteChar('(');
      FirstColumn := True;
      for J := 0 to Columns.Count - 1 do
        if (Columns[J].Visible and ((SelectedFields.Count = 0) or (SelectedFields.IndexOf(Columns[J].Field) >= 0))) then
        begin
          if (FirstColumn) then FirstColumn := False else Buffer.WriteChar(',');
          Buffer.Write(TMySQLQuery(DataLink.DataSet).SQLFieldValue(Columns[J].Field));
        end;
      Buffer.WriteChar(')');
    end;

    DataLink.DataSet.RecNo := OldRecNo;
  end;

  Result := Buffer.Read();
  Buffer.Free();
end;

function TMySQLDBGrid.CanEditShow(): Boolean;
begin
  if (Assigned(FHintWindow)) then
    FreeAndNil(FHintWindow);

  Result := inherited CanEditShow();

  if (Result and not FOnCanEditShowExecuted and Assigned(FOnCanEditShow)) then
  begin
    FOnCanEditShowExecuted := True;
    FOnCanEditShow(Self);
  end;
end;

function TMySQLDBGrid.CanGridAcceptKey(Key: Word; Shift: TShiftState): Boolean;
begin
  Result := not ((Key in [VK_INSERT]))
    and not ((SelectedField = Columns[0].Field) and (Key in [VK_TAB]) and (ssShift in Shift))
    and not ((SelectedField = Columns[Columns.Count - 1].Field) and (Key in [VK_TAB]) and not (ssShift in Shift));
end;

function TMySQLDBGrid.CanvasTextWidth(const Text: string): Integer;
begin
  Result := Canvas.TextWidth(Text);
end;

procedure TMySQLDBGrid.CMFontChanged(var Message);
begin
  try
  inherited;
  except // Debug 2017-01-15
    on E: Exception do
      raise ERangeError.Create('csDestroying: ' + BoolToStr(csDestroying in ComponentState, True) + #13#10
        + E.Message);
  end;
  // On 2017-01-19 try ... except didn't work: AV in Vcl.DBGrids|CheckForPassthroughs

  if (FListView > 0) then
    SendMessage(FListView, WM_SETFONT, WPARAM(Font.Handle), LPARAM(TRUE));
  if (Assigned(FHeaderControl)) then
    FHeaderControl.Font := TitleFont;
  Resize();
end;

procedure TMySQLDBGrid.CopyToClipboard();
var
  ClipboardData: HGLOBAL;
  Content: string;
  FormatSettings: TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create(LOCALE_USER_DEFAULT);

  if (Assigned(InplaceEditor) and InplaceEditor.Visible) then
    InplaceEditor.CopyToClipboard()
  else if (OpenClipboard(Handle)) then
    try
      EmptyClipboard();

      DataLink.DataSet.DisableControls();

      Content := CalcSelText();

      ClipboardData := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, (Length(Content) + 1) * SizeOf(Char));
      Move(PChar(Content)^, GlobalLock(ClipboardData)^, (Length(Content) + 1) * SizeOf(Char));
      SetClipboardData(CF_UNICODETEXT, ClipboardData);
      GlobalUnlock(ClipboardData);


      Content := CalcSQLData();

      ClipboardData := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, (Length(Content) + 1) * SizeOf(Char));
      Move(PChar(Content)^, GlobalLock(ClipboardData)^, (Length(Content) + 1) * SizeOf(Char));
      SetClipboardData(CF_MYSQLSQLDATA, ClipboardData);
      GlobalUnlock(ClipboardData);

      DataLink.DataSet.EnableControls();
    finally
      CloseClipboard();
    end;
end;

procedure TMySQLDBGrid.ColEnter();
begin
  if (Assigned(InplaceEditor)) then
  begin
    if (InplaceEditor is TMySQLDBGridInplaceEdit) then
      TMySQLDBGridInplaceEdit(InplaceEditor).Font := Columns[SelectedIndex].Font;
    if (Columns[SelectedIndex].Alignment <> taRightJustify) then
      SetWindowLong(InplaceEditor.Handle, GWL_STYLE, GetWindowLong(InplaceEditor.Handle, GWL_STYLE) and not ES_RIGHT)
    else
      SetWindowLong(InplaceEditor.Handle, GWL_STYLE, GetWindowLong(InplaceEditor.Handle, GWL_STYLE) or ES_RIGHT);
    if (Columns[SelectedIndex].Field.CanModify) then
      SetWindowLong(InplaceEditor.Handle, GWL_STYLE, GetWindowLong(InplaceEditor.Handle, GWL_STYLE) and not ES_READONLY)
    else
      SetWindowLong(InplaceEditor.Handle, GWL_STYLE, GetWindowLong(InplaceEditor.Handle, GWL_STYLE) or ES_READONLY);
  end;

  inherited;
end;

constructor TMySQLDBGrid.Create(AOwner: TComponent);
begin
  AltDownAnchor.Col := -1;
  FHeaderControl := nil;
  FHeaderSplitButton := nil;
  FIgnoreKeyPress := False;
  FListView := 0;
  FOnCanEditShowExecuted := False;
  FSelectedFields := TMySQLDBGridFieldList.Create(Self);
  IgnoreTitleClick := False;
  LeftClickAnchor.Col := -1;
  LeftClickAnchor.Shift := [];
  LeftClickAnchor.Rec := -1;
  ShiftDownAnchor.Col := -1;
  ShiftDownAnchor.Rec := -1;
  TitleBoldFont := nil;

  FMouseMoveCell.X := -1;
  FMouseMoveCell.Y := -1;

  inherited;
end;

function TMySQLDBGrid.CreateColumns(): TDBGridColumns;
begin
  Result := TDBMySQLGridColumns.Create(Self, TColumn);
end;

function TMySQLDBGrid.CreateEditor(): TInplaceEdit;
begin
  Result := TMySQLDBGridInplaceEdit.Create(Self);

  if (Assigned(Result)) then
  begin
    Result.Parent := Self;
    TMySQLDBGridInplaceEdit(Result).Font := Columns[SelectedIndex].Font;
    if (Columns[SelectedIndex].Alignment <> taRightJustify) then
      SetWindowLong(Result.Handle, GWL_STYLE, GetWindowLong(Result.Handle, GWL_STYLE) and not ES_RIGHT)
    else
      SetWindowLong(Result.Handle, GWL_STYLE, GetWindowLong(Result.Handle, GWL_STYLE) or ES_RIGHT);
  end;
end;

procedure TMySQLDBGrid.CreateWnd();
var
  LVColumn: TLVColumn;
begin
  inherited;

  if (FListView > 0) then CloseHandle(FListView);
  FListView := CreateWindow(WC_LISTVIEW, nil, WS_CHILD, 0, 0, 50, 50, Handle, 0, hInstance, nil);
  SendMessage(FListView, WM_SETFONT, WPARAM(Font.Handle), LPARAM(TRUE));
  LVColumn.mask := LVCF_TEXT;
  LVColumn.pszText := 'E';
  LVColumn.cchTextMax := StrLen(LVColumn.pszText);
  SendMessage(FListView, LVM_INSERTCOLUMN, 0, LPARAM(@LVColumn));

  if (Assigned(FHeaderControl)) then FHeaderControl.Free();
  FHeaderControl := THeaderControl.Create(Self);
  FHeaderControl.ControlStyle := FHeaderControl.ControlStyle + [csDoubleClicks];
  FHeaderControl.DoubleBuffered := True;
  FHeaderControl.DragReorder := True;
  FHeaderControl.NoSizing := not (dgColumnResize in Options);
  if (not Assigned(OnTitleClick) or not (dgTitleClick in Options)) then
    FHeaderControl.Style := hsFlat
  else
    FHeaderControl.Style := hsButtons;
  FHeaderControl.OnMouseMove := HeaderMouseMove;
  FHeaderControl.OnSectionClick := HeaderSectionClick;
  FHeaderControl.OnSectionDrag := HeaderSectionDrag;
  FHeaderControl.OnSectionResize := HeaderSectionResize;
  if (not Assigned(OnTitleClick) or not (dgTitleClick in Options)) then
    FHeaderControl.Style := hsFlat
  else
    FHeaderControl.Style := hsButtons;
  FHeaderControl.Parent := Self;

  SetColumnAttributes();
  Resize();
end;

destructor TMySQLDBGrid.Destroy();
begin
  if (Assigned(FHintWindow)) then
    FHintWindow.Free();

  if (Assigned(TitleBoldFont)) then
    TitleBoldFont.Free();

  if (Assigned(FHeaderControl)) then
  begin
    FHeaderControl.Parent := nil;
    FHeaderControl.Free();
    FHeaderControl := nil;
  end;
  FSelectedFields.Free();

  inherited;
end;

procedure TMySQLDBGrid.DoEnter();
begin
  InvalidateCell(Col, Row);

  inherited;

  if (Assigned(InplaceEditor)) then
    if (Columns[SelectedIndex].Alignment <> taRightJustify) then
      SetWindowLong(InplaceEditor.Handle, GWL_STYLE, GetWindowLong(InplaceEditor.Handle, GWL_STYLE) and not ES_RIGHT)
    else
      SetWindowLong(InplaceEditor.Handle, GWL_STYLE, GetWindowLong(InplaceEditor.Handle, GWL_STYLE) or ES_RIGHT);
end;

function TMySQLDBGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  Result := not TMySQLDataSet(DataLink.DataSet).CachedUpdates
    and (not (ssShift in LeftClickAnchor.Shift) and not (ssCtrl in LeftClickAnchor.Shift))
    and not EditorMode;

  if (Result) then
    DataLink.DataSet.MoveBy(- WheelDelta div WHEEL_DELTA);
end;

procedure TMySQLDBGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
begin
  if ((ARow > 0) or not Assigned(FHeaderControl)) then // The header row has been replaced with the FHeaderControl
    inherited;
end;

function TMySQLDBGrid.EditCopyExecute(): Boolean;
begin
  Result := True;

  if (EditorMode and Assigned(InplaceEditor)) then
    InplaceEditor.CopyToClipboard()
  else
    CopyToClipboard();
end;

function TMySQLDBGrid.EditCutExecute(): Boolean;
begin
  Result := CanEditModify();

  if (Result) then
  begin
    if (EditorMode and Assigned(InplaceEditor)) then
      InplaceEditor.CopyToClipboard()
    else
      CopyToClipboard();

    Result := EditDeleteExecute();
  end;
end;

function TMySQLDBGrid.EditDeleteExecute(): Boolean;
begin
  Result := Assigned(DataLink.DataSet);

  if (Result) then
  begin
    DataLink.DataSet.Edit();
    if (EditorMode and Assigned(InplaceEditor)) then
      InplaceEditor.SelText := ''
    else
      SelectedField.Clear();
  end;
end;

function TMySQLDBGrid.ExecuteAction(Action: TBasicAction): Boolean;
begin
  if (Action is TEditCut) then
    Result := EditCutExecute()
  else if (Action is TEditCopy) then
    Result := EditCopyExecute()
  else if (Action is TEditPaste) then
    Result := PasteFromClipboard()
  else if (Action is TEditDelete) then
    Result := EditDeleteExecute()
  else if (Action is TEditSelectAll) then
    begin Result := True; SelectAll(); end
  else
    Result := inherited ExecuteAction(Action);
end;

function TMySQLDBGrid.GetCurrentRow(): Boolean;
begin
  Result := Row - 1 = DataLink.ActiveRecord;
end;

function TMySQLDBGrid.GetEditLimit(): Integer;
begin
  if (not Assigned(SelectedField)) then
    Result := 0
  else
    case (SelectedField.DataType) of
      ftString: Result := SelectedField.DataSize - 1;
      ftVarBytes:  Result := SelectedField.Size - 1;
      ftSmallInt,
      ftInteger:
        { Workaround, because TIntegerField.MinValue is sometimes not set }
        if ((TIntegerField(SelectedField).MinValue = 0) and (TIntegerField(SelectedField).MaxValue = $7FFFFFFF)) then
          Result := Length('-2147483648')
        else if ((TIntegerField(SelectedField).MinValue = 0) and (TIntegerField(SelectedField).MaxValue = 0)) then
          Result := 0
        else
          Result := Max(Length(IntToStr(TIntegerField(SelectedField).MinValue)), Length(IntToStr(TIntegerField(SelectedField).MaxValue)));
      ftWord: Result :=  max(Length(IntToStr(TWordField(SelectedField).MinValue)), Length(IntToStr(TWordField(SelectedField).MaxValue)));
      ftCurrency,
      ftFloat:
        if ((TFloatField(SelectedField).MinValue = 0) and (TFloatField(SelectedField).MaxValue = 0)) then
          Result := 0
        else
          Result := max(Length(FloatToStr(TFloatField(SelectedField).MinValue, TMySQLDataSet(DataLink.DataSet).Connection.FormatSettings)), Length(FloatToStr(TFloatField(SelectedField).MaxValue, TMySQLDataSet(DataLink.DataSet).Connection.FormatSettings)));
      ftDate: Result := Length(MySQLDB.DateToStr(Now(), TMySQLDataSet(DataLink.DataSet).Connection.FormatSettings));
      ftTime: Result := Length(TimeToStr(Now(), TMySQLDataSet(DataLink.DataSet).Connection.FormatSettings));
      ftDateTime: Result := Length(MySQLDB.DateTimeToStr(Now(), TMySQLDataSet(DataLink.DataSet).Connection.FormatSettings));
      ftBlob,
      ftWideMemo: Result := 0;
      ftLargeint:
        if ((TLargeintField(SelectedField).MinValue = 0) and (TLargeintField(SelectedField).MaxValue = 0)) then
          Result := 0
        else
          Result := Max(Length(IntToStr(TLargeintField(SelectedField).MinValue)), Length(IntToStr(TLargeintField(SelectedField).MaxValue)));
      ftTimeStamp: Result := SelectedField.Size;
      else Result := inherited GetEditLimit();
    end;
end;

function TMySQLDBGrid.GetHeaderControl(): THeaderControl;
begin
  if (not Assigned(FHeaderControl)) then
    HandleNeeded();

  Result := FHeaderControl;
end;

function TMySQLDBGrid.GetSelText(): string;
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create(LOCALE_USER_DEFAULT);

  if ((SelectedRows.Count = 0) and (SelectedFields.Count = 0)) then
    Result := SelectedField.AsString
  else
  begin
    DataLink.DataSet.DisableControls();

    Result := CalcSelText();

    DataLink.DataSet.EnableControls();
  end;
end;

function TMySQLDBGrid.GetSelSQLData: string;
var
  OldRecNo: Integer;
begin
  DataLink.DataSet.DisableControls();
  OldRecNo := DataLink.DataSet.RecNo;

  Result := CalcSQLData();

  DataLink.DataSet.RecNo := OldRecNo;
  DataLink.DataSet.EnableControls();
end;

procedure TMySQLDBGrid.HeaderMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  HDItem: THDItem;
  Index: Integer;
  NeededWidth: Integer;
begin
  FHeaderControl.Hint := '';
  for Index := 0 to FHeaderControl.Sections.Count - 1 do
    if ((FHeaderControl.Sections[Index].Left <= X) and (X <= FHeaderControl.Sections[Index].Right)
      and Assigned(Columns[LeftCol + Index].Field)) then
    begin
      if (Columns[LeftCol + Index].Field.IsIndexField and Assigned(TitleBoldFont)) then
        Canvas.Font := TitleBoldFont
      else if (Assigned(TitleFont)) then
        Canvas.Font := TitleFont;
      NeededWidth := Canvas.TextWidth(Columns[LeftCol + Index].DisplayName) + FHeaderControl.Height;
      Canvas.Font := Font;

      if (StyleServices.Enabled) then
      begin
        HDItem.Mask := HDI_FORMAT;
        if (BOOL(SendMessage(FHeaderControl.Handle, HDM_GETITEM, Index, LParam(@HDItem)))
          and (HDItem.fmt and (HDF_SORTUP or HDF_SORTUP) <> 0)) then
          Inc(NeededWidth, 2 * DefaultRowHeight);
      end;

      if ((FHeaderControl.Sections[Index].Width < NeededWidth)
        and (Y < DefaultRowHeight)) then
        FHeaderControl.Hint := Columns[LeftCol + Index].DisplayName;
    end;
end;

procedure TMySQLDBGrid.HeaderSectionClick(HeaderControl: THeaderControl; Section: THeaderSection);
begin
  TitleClick(Columns[Section.Index + LeftCol]);
end;

procedure TMySQLDBGrid.HeaderSectionDrag(Sender: TObject; FromSection, ToSection: THeaderSection; var AllowDrag: Boolean);
begin
  Columns[FromSection.Index + LeftCol].Index := ToSection.Index;
end;

procedure TMySQLDBGrid.HeaderSectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
begin
  if (EditorMode) then Perform(CM_Exit, 0, 0);
  if (dgColLines in Options) then
    Columns[Section.Index + LeftCol].Width := Section.Width - GridLineWidth
  else
    Columns[Section.Index + LeftCol].Width := Section.Width;
end;

procedure TMySQLDBGrid.KeyDown(var Key: Word; Shift: TShiftState);
var
  I: Integer;
  OldCol: Longint;
  OldRecNo: Integer;
begin
  if (Assigned(FHintWindow)) then
    FreeAndNil(FHintWindow);

  if ((Key = VK_SHIFT) and (ShiftDownAnchor.Rec < 0)) then
  begin
    ShiftDownAnchor.Col := Col;
    ShiftDownAnchor.Rec := DataLink.ActiveRecord;
  end;
  if ((Key = VK_SHIFT) and (AltDownAnchor.Col < 0)) then
  begin
    AltDownAnchor.Col := Col;
    Cursor := crCross;
    Perform(WM_SETCURSOR, Handle, HTCLIENT);
    MouseCapture := True;
  end;

  if ((Key = VK_UP) and (Shift = [ssCtrl]) and not EditorMode) then
  begin
    if (SelectedRows.Count = 0) then
      SelectedRows.CurrentRowSelected := True;
    if DataLink.DataSet.RecNo > 0 then
      DataLink.DataSet.MoveBy(-1);
    FIgnoreKeyPress := True;
  end
  else if ((Key = VK_DOWN) and (Shift = [ssCtrl]) and not EditorMode) then
  begin
    if (SelectedRows.Count = 0) then
      SelectedRows.CurrentRowSelected := True;
    if (DataLink.DataSet.RecNo < DataLink.DataSet.RecordCount - 1) then
      DataLink.DataSet.MoveBy(+1);
    FIgnoreKeyPress := True;
  end
  else if ((Key = VK_TAB) and (Shift = []) and (SelectedIndex = Columns.Count - 1) and DataSource.DataSet.FindNext() and not TMySQLDataSet(DataSource.DataSet).CachedUpdates) then
    SelectedIndex := 0
  else if ((Key = VK_TAB) and (ssShift in Shift) and (SelectedIndex = 0) and DataSource.DataSet.FindPrior() and not TMySQLDataSet(DataSource.DataSet).CachedUpdates) then
    SelectedIndex := Columns.Count - 1
  else if (((Key = VK_HOME) or (Key = VK_END)) and (ssShift in Shift) and not EditorMode) then
  begin
    if ((Key = VK_HOME) and (ssCtrl in Shift) and (DataLink.DataSet.RecNo = DataLink.DataSet.RecordCount - 1)
      or (Key = VK_END) and (ssCtrl in Shift) and (DataLink.DataSet.RecNo = 0)) then
    begin
      if (SelectedFields.IndexOf(SelectedField) < 0) then
        SelectedFields.Add(SelectedField);
      inherited;
    end
    else
      SelectedRows.CurrentRowSelected := not SelectedRows.CurrentRowSelected;
  end
  else if (((Key = VK_HOME) or (Key = VK_END)) and (ssCtrl in Shift)) then
  begin
    Col := 0;
    if (SelectedFields.Count > 0) then
    begin
      Invalidate();
      SelectedFields.Clear();
    end;
    SelectedRows.Clear();
    inherited;
  end
  else if ((Key = VK_LEFT) and (ssShift in Shift)) then
  begin
    if (Col > 0) then
    begin
      if (Col > ShiftDownAnchor.Col) then
        InvalidateCol(Col);
      Col := Col - 1;
      SelectedFields.Clear();
      for I := Min(Col, ShiftDownAnchor.Col) to Max(Col, ShiftDownAnchor.Col) do
        SelectedFields.Add(Columns[I].Field);
      if (Col < ShiftDownAnchor.Col) then
        InvalidateCol(Col);
    end;
  end
  else if ((Key = VK_RIGHT) and (ssShift in Shift)) then
  begin
    if (Col < Columns.Count - 2) then
    begin
      if (Col < ShiftDownAnchor.Col) then
        InvalidateCol(Col);
      Col := Col + 1;
      SelectedFields.Clear();
      for I := Min(Col, ShiftDownAnchor.Col) to Max(Col, ShiftDownAnchor.Col) do
        SelectedFields.Add(Columns[I].Field);
      if (Col > ShiftDownAnchor.Col) then
        InvalidateCol(Col);
    end;
  end
  else if ((Key = VK_LEFT) and (ssCtrl in Shift)) then
  begin
    if (Col > 0) then Col := Col - 1;
  end
  else if ((Key = VK_RIGHT) and (ssCtrl in Shift)) then
  begin
    if (Col < Columns.Count - 2) then Col := Col + 1;
  end
  else if ((Key = VK_SPACE) and (ssCtrl in Shift) and not EditorMode) then
  begin
    if ((SelectedRows.Count = 0) and (SelectedFields.Count > 0)) then
    begin
      if (SelectedFields.IndexOf(SelectedField) < 0) then
        SelectedFields.Add(SelectedField)
      else
        SelectedFields.Delete(SelectedFields.IndexOf(SelectedField));
      InvalidateCol(Col);
    end
    else if ((SelectedRows.Count > 0) or (SelectedFields.Count = 0)) then
      SelectedRows.CurrentRowSelected := not SelectedRows.CurrentRowSelected
    else
    begin
      DataLink.DataSet.DisableControls();
      OldRecNo := DataLink.DataSet.RecNo;

      if (DataLink.DataSet.FindFirst()) then
        repeat
          SelectedRows.CurrentRowSelected := True;
        until (not DataLink.DataSet.FindNext());

      DataLink.DataSet.RecNo := OldRecNo;
      SelectedRows.CurrentRowSelected := False;
      DataLink.DataSet.EnableControls();
    end;
    if ((SelectedFields.Count > 0) and (SelectedFields.IndexOf(SelectedField) < 0) and SelectedRows.CurrentRowSelected) then
    begin
      SelectedFields.Add(SelectedField);
      InvalidateCol(Col);
    end;
    FIgnoreKeyPress := True;
    Options := Options - [dgEditing];
  end
  else if ((Key = VK_ESCAPE) and (Shift = []) and EditorMode) then
  begin
    Datalink.Reset();
    if not (dgAlwaysShowEditor in Options) then
      HideEditor();
  end
  else if ((Key = VK_DELETE) and (Shift = []) and not ReadOnly and not SelectedField.ReadOnly) then
    EditDeleteExecute()
  else if ((Key = VK_DOWN) and (Shift = [ssAlt]) and (Columns[SelectedIndex].ButtonStyle = cbsEllipsis)) then
    EditButtonClick()
  else if ((Key = VK_DOWN) and (ssShift in Shift) and (DataLink.DataSet.RecNo = DataLink.DataSet.RecordCount - 1)) then
    // Do nothing - without this, an append will be executed
  else
  begin
    OldCol := Col;

    if (((Key = VK_UP) or (Key = VK_DOWN)) and (ssShift in Shift) and (ShiftDownAnchor.Rec = DataLink.DataSet.RecNo) and not EditorMode) then
      SelectedRows.CurrentRowSelected := True;

    inherited;

    if (not EditorMode) then
    begin
      if ((Key in [VK_LEFT, VK_RIGHT, VK_DOWN, VK_UP]) and (ssShift in Shift) and (ssAlt in Shift) and (AltDownAnchor.Col >= 0)) then
      begin
        if ((SelectedRows.Count > 0) or (SelectedFields.Count = 0)) then
          SelectedRows.CurrentRowSelected := True;
        if (SelectedFields.IndexOf(SelectedField) < 0) then
        begin
          SelectedFields.Add(Columns[AltDownAnchor.Col].Field);
          InvalidateCol(AltDownAnchor.Col);
        end;
        if ((Key = VK_RIGHT) and (Col <> OldCol)) then
          if (SelectedFields.IndexOf(Columns[Col].Field) < 0) then
          begin
            SelectedFields.Add(Columns[Col].Field);
            InvalidateCol(Col);
          end
          else
          begin
            SelectedFields.Delete(SelectedFields.IndexOf(Columns[Col - 1].Field));
            InvalidateCol(Col - 1);
          end
        else if ((Key = VK_LEFT) and (Col <> OldCol)) then
          if (SelectedFields.IndexOf(SelectedField) < 0) then
          begin
            SelectedFields.Add(Columns[Col].Field);
            InvalidateCol(Col);
          end
          else
          begin
            SelectedFields.Delete(SelectedFields.IndexOf(Columns[Col + 1].Field));
            InvalidateCol(Col + 1);
          end;
      end
      else if ((Key in [VK_LEFT, VK_RIGHT, VK_DOWN, VK_UP, VK_HOME, VK_END]) and not (ssShift in Shift)) then
      begin
        if ((SelectedRows.Count = 0) and (SelectedFields.Count > 0)) then
          Invalidate();
        SelectedRows.Clear();
        SelectedFields.Clear();
      end;
    end;
  end;
end;

procedure TMySQLDBGrid.KeyPress(var Key: Char);
begin
  if (IgnoreKeyPress) then
  begin
    Key := #0;
    FIgnoreKeyPress := False;
    Options := Options + [dgEditing];
  end;

  inherited;
end;

procedure TMySQLDBGrid.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_SHIFT) then
  begin
    ShiftDownAnchor.Rec := -1;
    AltDownAnchor.Col := -1;
    LeftClickAnchor.Col := -1;
    LeftClickAnchor.Rec := -1;
    Cursor := crDefault;
    Perform(WM_SETCURSOR, Handle, HTCLIENT);
    MouseCapture := False;
  end;

  inherited;
end;

procedure TMySQLDBGrid.LayoutChanged();
begin
  inherited;

  FOnCanEditShowExecuted := False;
end;

procedure TMySQLDBGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Cell: TGridCoord;
  BeginDragSelected: Boolean;
  OldRecord: Integer;
  I: Integer;
begin
  if (Assigned(FHintWindow)) then
    FreeAndNil(FHintWindow);

  Cell := MouseCoord(X, Y);

  if (Button = mbLeft) then
    LeftClickAnchor.Shift := Shift + LeftClickAnchor.Shift - [ssLeft, ssRight, ssMiddle, ssDouble];

  if ((Cell.X = -1) and (Cell.Y = -1) and EditorMode) then
    try
      SelectedField.AsString := TMySQLDBGridInplaceEdit(InplaceEditor).Text;
    except
    end;

  if (Cell.Y < 1) then
    OldRecord := -1
  else
    OldRecord := DataLink.ActiveRecord;

  BeginDragSelected := (Shift = [ssLeft])
    and (SelectedRows.Count > 0)
    and (OldRecord > 0)
    and ((SelectedFields.Count = 0) or (SelectedFields.IndexOf(Columns[Cell.X].Field) >= 0));
  if (BeginDragSelected) then
  begin
    if (Cell.Y <> Row) then
      DataLink.ActiveRecord := OldRecord + Cell.Y - Row;
    BeginDragSelected := SelectedRows.CurrentRowSelected;
    if (Cell.Y <> Row) then
      DataLink.ActiveRecord := OldRecord;
  end;

  if (BeginDragSelected) then
    BeginDrag(False)
  else
  begin
    if ((Shift = [ssLeft]) and (SelectedRows.Count = 0)) then
    begin
      SelectedFields.Clear();
      SelectedRows.Clear();
      BeginDrag(False);
    end;

    if ((Shift = [ssLeft]) and not (ssCtrl in Shift) and not (ssAlt in Shift)) then
    begin
      if (SelectedRows.Count = 0) then
        for I := 0 to Columns.Count - 1 do
          if (SelectedFields.IndexOf(Columns[I].Field) >= 0) then
            InvalidateCol(I);
      SelectedFields.Clear();
      SelectedRows.Clear();
    end;

    inherited;

    if (ssShift in Shift) then
    begin
      Cursor := crCross;
      Perform(WM_SETCURSOR, Handle, HTCLIENT);
      LeftClickAnchor.Col := Col;
      LeftClickAnchor.Rec := DataLink.ActiveRecord;

      if ((Shift = [ssLeft]) and (ssAlt in Shift)) then
      begin
        SelectedFields.Clear();
        SelectedFields.Add(Columns[Cell.X].Field);
      end;
    end;

    if ((Shift = [ssLeft]) and not (ssCtrl in Shift) and not (ssAlt in Shift) and (dgMultiSelect in Options) and (SelectedRows.Count = 1)) then
      SelectedRows.Clear();
  end;
end;

procedure TMySQLDBGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
const
  TimerCount = 4;
var
  Cell: TGridCoord;
  Delay: Integer;
  Distance: Integer;
  Msg: TMsg;
  UseTimer: Boolean;
begin
  KillTimer(Handle, tiMouseMove);

  inherited;

  Cell := MouseCoord(X, Y);
  if (LeftClickAnchor.Col < 0) then
  begin
    if (not ShowHint and not ParentShowHint or (Hint = '')) then
      if (((FMouseMoveCell.X >= 0) or (FMouseMoveCell.Y >= 0)) and ((Cell.X <> FMouseMoveCell.X) or (Cell.Y <> FMouseMoveCell.Y))) then
      begin
        FMouseMoveCell.X := -1; FMouseMoveCell.Y := -1;
        ReleaseCapture();
        if (Assigned(FHintWindow)) then
          FreeAndNil(FHintWindow);
      end
      else if ((Cell.X >= 0) and (Cell.Y >= 0) and ((Cell.X <> FMouseMoveCell.X) or (Cell.Y <> FMouseMoveCell.Y))) then
      begin
        FMouseMoveCell := Cell;
        SetCapture(Handle);
        SetTimer(Handle, tiShowHint, Application.HintPause, nil);
      end;
  end
  else if (PeekMessage(Msg, 0, 0, 0, PM_NOREMOVE) and (Msg.Message = WM_MOUSEMOVE) and (Msg.hwnd = Handle) and (KeysToShiftState(Msg.wParam) = Shift)) then
    // Do nothing - handle this message within the next equal message
  else
  begin
    UseTimer := False;

    if (ssAlt in Shift) then
    begin
      if (Cell.X > LeftCol + VisibleColCount) then
        Cell.X := -1;
      if (Cell.X < 0) then
      begin
        if (X < 0) then
          Cell.X := Col - 1
        else if (Col < Columns.Count - 1) then
          Cell.X := Col + 1;
      end;
      if ((Cell.X >= 0) and (MouseMoveTimerData.HorzCounter mod TimerCount = 0)) then
      begin
        while ((Cell.X < Col) and (LeftClickAnchor.Col < Col)
          or (Cell.X > Col) and (LeftClickAnchor.Col > Col)) do
        begin
          SelectedFields.Delete(SelectedFields.IndexOf(Columns[Col].Field));
          InvalidateCol(Col);
          Col := Col + Sign(Cell.X - Col);
        end;
        while (Col <> Cell.X) do
        begin
          Col := Col + Sign(Cell.X - Col);
          SelectedFields.Add(SelectedField);
          InvalidateCol(Col);
        end;
      end;
      UseTimer := (Cell.X < LeftCol - 1) or (Cell.X > LeftCol) and (Cell.X < Columns.Count - 1);
    end;

    if (Cell.Y >= 0) then
    begin
      while ((Cell.Y < Row) and (LeftClickAnchor.Rec < DataLink.ActiveRecord)
        or (Cell.Y > Row) and (LeftClickAnchor.Rec > DataLink.ActiveRecord)) do
      begin
        SelectedRows.CurrentRowSelected := False;
        DataLink.DataSet.MoveBy(Sign(Cell.Y - Row));
      end;
      SelectedRows.CurrentRowSelected := True;
      while ((Row <> Cell.Y)
        and (DataLink.DataSet.MoveBy(Sign(Cell.Y - Row)) <> 0)) do
        SelectedRows.CurrentRowSelected := True;
    end
    else
    begin
      if (X < 0) then
        Distance := Y div DefaultRowHeight
      else
        Distance := (Y - (VisibleRowCount * DefaultRowHeight)) div DefaultRowHeight;
      if (Distance <> 0) then
      begin
        while (DataLink.DataSet.MoveBy(Sign(Distance)) <> 0) do
        begin
          SelectedRows.CurrentRowSelected := True;
          Dec(Distance, Sign(Distance));
        end;
        UseTimer := True;
      end;
    end;

    if (UseTimer and SystemParametersInfo(SPI_GETKEYBOARDSPEED, 0, @Delay, 0)) then
    begin
      MouseMoveTimerData.Shift := Shift;
      MouseMoveTimerData.X := X;
      MouseMoveTimerData.Y := Y;
      SetTimer(Handle, tiMouseMove, (31 - Delay) * 12 + 33, nil);
    end;
    if (not UseTimer) then
      MouseMoveTimerData.HorzCounter := 0
    else
      MouseMoveTimerData.HorzCounter := (MouseMoveTimerData.HorzCounter + 1) mod TimerCount;
  end;
end;

procedure TMySQLDBGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

  if (Button = mbLeft) then
  begin
    LeftClickAnchor.Col := -1;
    LeftClickAnchor.Rec := -1;
    LeftClickAnchor.Shift := [];
  end;
end;

function TMySQLDBGrid.PasteFromClipboard(): Boolean;
var
  Global: HGLOBAL;
  Text: string;
begin
  Result := not ReadOnly;

  if (Result) then
    if (EditorMode and Assigned(InplaceEditor)) then
    begin
      InplaceEditor.PasteFromClipboard();
      Result := True;
    end
    else if ((DataLink.DataSet is TMySQLDataSet) and IsClipboardFormatAvailable(CF_UNICODETEXT)
      and OpenClipboard(Handle)) then
    begin
      Text := '';
      try
        Global := GetClipboardData(CF_UNICODETEXT);
        SetString(Text, PChar(GlobalLock(Global)), GlobalSize(Global) div SizeOf(Text[1]));
        GlobalUnlock(Global);
      finally
        CloseClipboard();
      end;
      Result := (Text <> '') and PasteText(Text);
    end;
end;

function TMySQLDBGrid.PasteText(const Text: string): Boolean;
var
  Bookmarks: array of TBookmark;
  I: Integer;
  Index: Integer;
  RecNo: Integer;
  Start: Integer;
  Value: Integer;
  Values: TCSVValues;
begin
  Result := not ReadOnly;

  if (Result) then
  begin
    Index := 1;
    if (CSVSplitValues(Text, Index, #9, '"', Values) and ((Length(Values) > 1) or (Index <= Length(Text)))) then
    begin
      if (DataLink.DataSet.State <> dsInsert) then
        DataLink.DataSet.CheckBrowseMode();
      DataLink.DataSet.DisableControls();
      try
        if (SelectedRows.Count > 0) then
        begin
          SetLength(Bookmarks, SelectedRows.Count);
          for I := 0 to Length(Bookmarks) - 1 do
            Bookmarks[I] := SelectedRows.Items[I];
          SelectedRows.Clear();
          TMySQLDataSet(DataLink.DataSet).Delete(Bookmarks);
          SetLength(Bookmarks, 0);
        end;

        RecNo := 0;
        try
          repeat
            if (Length(Values) > 0) then
            begin
              if ((DataLink.DataSet.State = dsInsert) or (RecNo > 0) and (DataLink.DataSet.RecNo = DataLink.DataSet.RecordCount - 1)) then
                DataLink.DataSet.Append()
              else
              begin
                if (RecNo > 1) then DataLink.DataSet.Next();
                DataLink.DataSet.Insert();
              end;

              Value := 0; Start := 0;
              for I := 0 to Columns.Count - 1 do
                if (Columns[I].Field = SelectedField) then
                  Start := I;
              for I := Start to Start + Min(Length(Values), Columns.Count - Start) - 1 do
              begin
                if (Values[Value].Length = 0) then
                  Columns[I].Field.Clear()
                else if (Columns[I].Field.AutoGenerateValue <> arAutoInc) then
                  try
                    Columns[I].Field.AsString := CSVUnescape(Values[Value].Text, Values[Value].Length);
                  except
                    MessageBeep(MB_ICONERROR);
                    DataLink.DataSet.Fields[I].Clear();
                  end;
                Inc(Value);
              end;

              if ((RecNo > 0) or (Index <= Length(Text))) then
                try
                  DataLink.DataSet.Post();
                except
                  on Error: EDatabaseError do
                    begin
                      DataLink.DataSet.Cancel();
                      DataLink.DataSet.Prior();
                    end;
                end;
              Inc(RecNo);
            end;
          until (not CSVSplitValues(Text, Index, #9, '"', Values) or (Length(Values) = 0));
        finally
          SetLength(Values, 0);
        end;
      finally
        DataLink.DataSet.EnableControls();
      end;
    end
    else if (not SelectedField.ReadOnly) then
    begin
      ShowEditor();
      if (EditorMode and Assigned(InplaceEditor)) then
        InplaceEditor.PasteFromClipboard()
      else
      begin
        DataLink.DataSet.Edit();
        SelectedField.AsString := Text;
      end;
    end;
  end;
end;

procedure TMySQLDBGrid.Resize();
var
  HDLayout: THDLayout;
  HDRect: TRect;
  HDWindowPos: TWindowPos;
  I: Integer;
begin
  inherited;

  DataLink.BufferCount := RowCount - 1;

  if (Assigned(FHeaderControl)) then
  begin
    HDLayout.Rect := @HDRect;
    HDLayout.WindowPos := @HDWindowPos;
    if ((FListView > 0) and Header_Layout(ListView_GetHeader(FListView), @HDLayout)) then
      FHeaderControl.Height := HDWindowPos.cy;

    if (Assigned(InplaceEditor)) then InplaceEditor.Hide();
    if (dgRowLines in Options) then
      RowHeights[0] := FHeaderControl.Height - GridLineWidth
    else
      RowHeights[0] := FHeaderControl.Height;

    for I := 0 to FHeaderControl.Sections.Count - 1 do
      FHeaderControl.Sections[I].MaxWidth := Width - FHeaderControl.Height - GetSystemMetrics(SM_CXVSCROLL);
  end;
end;

procedure TMySQLDBGrid.SelectAll();
var
  I: Integer;
begin
  DataLink.DataSet.CheckBrowseMode();

  DataLink.DataSet.DisableControls();
  EditorMode := False;

  if ((SelectedRows.Count > 0) and (SelectedRows.Count <> DataLink.DataSet.RecordCount)) then
    SelectedRows.Clear();

  if ((DataLink.DataSet is TMySQLTable) and TMySQLTable(DataLink.DataSet).LimitedDataReceived) then
    TMySQLTable(DataLink.DataSet).LoadNextRecords(True);

  for I := 0 to Columns.Count - 1 do
    SelectedFields.Add(Columns[I].Field);

  DataLink.DataSet.EnableControls();
end;

procedure TMySQLDBGrid.SetHeaderColumnArrows();
var
  HDItem: THDItem;
  I: Integer;
  Index: Integer;
begin
  Index := 0;
  HDItem.Mask := HDI_FORMAT;
  if (DataLink.DataSet is TMySQLDataSet) then
    for I := LeftCol to Min(LeftCol + VisibleColCount, Columns.Count) - 1 do
    begin
      // Debug 2017-02-07
      Assert((0 <= I) and (I < Columns.Count),
        'I: ' + IntToStr(I) + #13#10
        + 'LeftCol: ' + IntToStr(LeftCol) + #13#10
        + 'VisibleColCount: ' + IntToStr(VisibleColCount) + #13#10
        + 'Count: ' + IntToStr(Columns.Count) + #13#10
        + TMySQLDataSet(DataLink.DataSet).CommandText);

      if (Columns[I].Visible
        and Assigned(Columns[I].Field)
        and BOOL(SendMessage(Header.Handle, HDM_GETITEM, Index, LParam(@HDItem)))) then
      begin
        if (Columns[I].Field.Tag and ftAscSortedField <> 0) then
          HDItem.fmt := HDItem.fmt and not HDF_SORTDOWN or HDF_SORTUP
        else if (Columns[I].Field.Tag and ftDescSortedField <> 0) then
          HDItem.fmt := HDItem.fmt and not HDF_SORTUP or HDF_SORTDOWN
        else
          HDItem.fmt := HDItem.fmt and not HDF_SORTUP and not HDF_SORTDOWN;
        SendMessage(Header.Handle, HDM_SETITEM, Index, LPARAM(@HDItem));
        Inc(Index);
      end;
    end;
end;

procedure TMySQLDBGrid.TitleClick(Column: TColumn);
begin
  if (not IgnoreTitleClick) then
  begin
    LeftClickAnchor.Shift := [ssLeft];
    if (GetKeyState(VK_SHIFT) < 0) then LeftClickAnchor.Shift := LeftClickAnchor.Shift + [ssShift];
    if (GetKeyState(VK_CONTROL) < 0) then LeftClickAnchor.Shift := LeftClickAnchor.Shift + [ssCtrl];
    inherited;
  end;

  IgnoreTitleClick := False;
end;

procedure TMySQLDBGrid.TopLeftChanged();
begin
  inherited;

  TDBMySQLGridColumns(Columns).Update(nil);
end;

function TMySQLDBGrid.UpdateAction(Action: TBasicAction): Boolean;
begin
  if (Action is TEditAction) then
  begin
    Result := Focused() and Assigned(DataLink.DataSet) and DataLink.DataSet.Active and Assigned(SelectedField);

    if (Result) then
      if (Action is TEditCut) then
        TEditCut(Action).Enabled := not ReadOnly and not SelectedField.ReadOnly and not SelectedField.Required and not SelectedField.IsNull and SelectedField.CanModify and (not EditorMode or Assigned(InplaceEditor) and (InplaceEditor.SelText <> ''))
      else if (Action is TEditCopy) then
        TEditCopy(Action).Enabled := EditorMode and Assigned(InplaceEditor) and (InplaceEditor.SelText <> '') or not EditorMode and (not SelectedRows.CurrentRowSelected and not SelectedField.IsNull or SelectedRows.CurrentRowSelected and (DataSource.DataSet is TMySQLDataSet) and (DataSource.DataSet.State <> dsInsert))
      else if (Action is TEditPaste) then
        TEditPaste(Action).Enabled := not ReadOnly and SelectedField.CanModify and (EditorMode and IsClipboardFormatAvailable(CF_UNICODETEXT) or not EditorMode and IsClipboardFormatAvailable(CF_UNICODETEXT))
      else if (Action is TEditDelete) then
        TEditDelete(Action).Enabled := not ReadOnly and not SelectedField.ReadOnly and not SelectedField.Required and not SelectedField.IsNull and SelectedField.CanModify and (SelectedRows.Count = 0) and (SelectedFields.Count = 0) and (not EditorMode or Assigned(InplaceEditor) and (InplaceEditor.SelText <> ''))
      else if (Action is TEditSelectAll) then
        TEditSelectAll(Action).Enabled := (DataLink.DataSet.RecordCount > 0)
      else
        Result := False;
  end
  else
    Result := inherited UpdateAction(Action);
end;

procedure TMySQLDBGrid.UpdateHeader();
begin
  SetHeaderColumnArrows();
end;

procedure TMySQLDBGrid.WMNotify(var Msg: TWMNotify);
var
  Column: TColumn;
  HDItem: THDItem;
  HDNotify: PHDNotify;
  HDCustomDraw: PNMCustomDraw;
  LogFont: TLogFont;
  NewWidth: Integer;
  Shift: TShiftState;
begin
  HDNotify := PHDNotify(Msg.NMHdr);

  // Debug 2016-12-11
  if (not Assigned(HDNotify)) then
    raise ERangeError.Create(SRangeError);

  if (not Assigned(FHeaderControl)
    or not Assigned(FHeaderControl.Parent)
    or not Assigned(HDNotify)
    or (HDNotify^.Hdr.hwndFrom <> FHeaderControl.Handle)) then
    inherited
  else
    case (HDNotify^.Hdr.code) of
      HDN_ENDDRAG:
        if ((HDNotify^.PItem.Mask and HDI_ORDER <> 0) and (HDNotify^.PItem.iOrder >= 0)) then
        begin
          Column := Columns[LeftCol + HDNotify^.Item];
          Column.Index := HDNotify^.PItem.iOrder + LeftCol;
          Msg.Result := LRESULT(TRUE);
          Resize();
        end;
      HDN_DIVIDERDBLCLICK:
        begin
          Column := Columns[LeftCol + HDNotify^.Item];
          if ((DataLink.DataSet is TMySQLDataSet) and not (Column.Field is TBlobField)) then
          begin
            HDItem.Mask := HDI_WIDTH;
            if (BOOL(SendMessage(Header.Handle, HDM_GETITEM, HDNotify^.Item, LPARAM(@HDItem)))) then
            begin
              Canvas.Font := Column.Font;
              NewWidth := TMySQLDataSet(DataLink.DataSet).GetMaxTextWidth(Column.Field, CanvasTextWidth) + 4 + GridLineWidth;
              if (NewWidth < FHeaderControl.Sections[HDNotify^.Item].MinWidth) then
                NewWidth := FHeaderControl.Sections[HDNotify^.Item].MinWidth;
              if (NewWidth > Width - RowHeights[0]) then
                NewWidth := Width - RowHeights[0];

              HDItem.cxy := NewWidth;
              if (dgColLines in Options) then
                Inc(NewWidth, GridLineWidth);

              Column.Width := NewWidth;

              Resize();
            end;
          end;
        end;
      NM_CUSTOMDRAW:
        begin
          HDCustomDraw := PNMCustomDraw(HDNotify);
          case (HDCustomDraw^.dwDrawStage) of
            CDDS_PREPAINT:
              Msg.Result := CDRF_NOTIFYITEMDRAW;
            CDDS_ITEMPREPAINT:
              if ((Columns.Count <= LeftCol + Integer(HDCustomDraw^.dwItemSpec)) or not Assigned(Columns[LeftCol + Integer(HDCustomDraw^.dwItemSpec)])) then
                inherited
              else if ((LeftCol + Integer(HDCustomDraw^.dwItemSpec) < Columns.Count)
                and Assigned(Columns[LeftCol + Integer(HDCustomDraw^.dwItemSpec)].Field)
                and Columns[LeftCol + Integer(HDCustomDraw^.dwItemSpec)].Field.IsIndexField
                and (Assigned(TitleBoldFont) or (GetObject(TitleFont.Handle, SizeOf(LogFont), @LogFont) <> 0))) then
              begin
                if (not Assigned(TitleBoldFont)) then
                begin
                  TitleBoldFont := TFont.Create();
                  TitleBoldFont.Handle := CreateFontIndirect(LogFont);
                  TitleBoldFont.Style := TitleBoldFont.Style + [fsBold];
                end;

                SelectObject(HDCustomDraw^.hdc, TitleBoldFont.Handle);
                Msg.Result := CDRF_NEWFONT;
              end
              else
              begin
                SelectObject(HDCustomDraw^.hdc, TitleFont.Handle);
                Msg.Result := CDRF_NEWFONT;
              end;
            else
              inherited;
          end;
        end;
      HDN_DROPDOWN:
        if (Assigned(FHeaderSplitButton)) then
        begin
          case (HDNotify^.Button) of
            0: Shift := [ssLeft];
            1: Shift := [ssRight];
            2: Shift := [ssMiddle];
            else Shift := [];
          end;
          if (GetKeyState(VK_SHIFT) < 0) then Shift := Shift + [ssShift];
          if (GetKeyState(VK_CONTROL) < 0) then Shift := Shift + [ssCtrl];
          if (GetKeyState(VK_MENU) < 0) then Shift := Shift + [ssAlt];
          FHeaderSplitButton(Self, Columns[LeftCol + HDNotify^.Item], Shift);
        end;
      else
        inherited;
    end;
end;

procedure TMySQLDBGrid.WMTimer(var Msg: TWMTimer);
begin
  inherited;

  case (Msg.TimerID) of
    tiShowHint:
      begin
        KillTimer(Handle, Msg.TimerID);
        if (Visible) then
          ActivateHint();
      end;
    tiHideHint:
      begin
        KillTimer(Handle, Msg.TimerID);
        if (Assigned(FHintWindow)) then
          FreeAndNil(FHintWindow);
      end;
    tiMouseMove:
      begin
        KillTimer(Handle, Msg.TimerID);
        MouseMove(MouseMoveTimerData.Shift, MouseMoveTimerData.X, MouseMoveTimerData.Y);
      end;
  end;
end;

procedure TMySQLDBGrid.WndProc(var Msg: TMessage);
begin
  if ((Msg.Msg = WM_LBUTTONDOWN) and (DragMode = dmAutomatic)) then
    MouseDown(mbLeft, KeysToShiftState(TWMLButtonDown(Msg).Keys), TWMLButtonDown(Msg).XPos, TWMLButtonDown(Msg).YPos)
  else
    inherited;
end;

end.


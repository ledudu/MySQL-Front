unit uDAccounts;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus, ActnList, ImgList, ToolWin,
  StdCtrls_Ext, ComCtrls_Ext, ExtCtrls_Ext, Forms_Ext,
  uSession, uPreferences, uBase, System.Actions;

type
  TDAccounts = class (TForm_Ext)
    ActionList: TActionList;
    aDelete: TAction;
    aEdit: TAction;
    aNew: TAction;
    aOpen: TAction;
    aOpenInNewWindow: TAction;
    FBCancel: TButton;
    FBDelete: TButton;
    FBEdit: TButton;
    FBNew: TButton;
    FBOk: TButton;
    FList: TListView_Ext;
    GAccounts: TGroupBox_Ext;
    HeaderMenu: TPopupMenu;
    ItemMenu: TPopupMenu;
    miHHost: TMenuItem;
    miHName: TMenuItem;
    miHDatabase: TMenuItem;
    miHLastLogin: TMenuItem;
    miHUser: TMenuItem;
    miICopy: TMenuItem;
    miIDelete: TMenuItem;
    miIEdit: TMenuItem;
    miINew: TMenuItem;
    miIOpen: TMenuItem;
    miIOpenInNewWindow: TMenuItem;
    miIPaste: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    PAccounts: TPanel_Ext;
    procedure aDeleteExecute(Sender: TObject);
    procedure aEditExecute(Sender: TObject);
    procedure aNewExecute(Sender: TObject);
    procedure aOpenExecute(Sender: TObject);
    procedure aOpenInNewWindowExecute(Sender: TObject);
    procedure FBOkEnabledCheck(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FListColumnClick(Sender: TObject; Column: TListColumn);
    procedure FListColumnResize(Sender: TObject; Column: TListColumn);
    procedure FListCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure FListContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure FListDblClick(Sender: TObject);
    procedure FListResize(Sender: TObject);
    procedure FListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure HeaderMenuClick(Sender: TObject);
    procedure ItemMenuPopup(Sender: TObject);
  private
    IgnoreColumnResize: Boolean;
    IgnoreResize: Boolean;
    MinColumnWidth: Integer;
    procedure CMSysFontChanged(var Message: TMessage); message CM_SYSFONTCHANGED;
    procedure aECopyExecute(Sender: TObject);
    procedure aEPasteExecute(Sender: TObject);
    procedure ListViewShowSortDirection(const ListView: TListView);
    procedure SetFAccounts(const ASelected: TPAccount);
    procedure UMPostShow(var Message: TMessage); message UM_POST_SHOW;
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Account: TPAccount;
    Session: TSSession;
    Open: Boolean;
    function Execute(): Boolean;
  end;

function DAccounts(): TDAccounts;

implementation {***************************************************************}

{$R *.dfm}

uses
  CommCtrl, ShellAPI,
  Math, StrUtils, SysConst, Types,
  Clipbrd, Consts,
  MySQLConsts,
  uDAccount, uDConnecting;

var
  FDAccounts: TDAccounts;
  Process: string;

function DAccounts(): TDAccounts;
begin
  if (not Assigned(FDAccounts)) then
  begin
    Application.CreateForm(TDAccounts, FDAccounts);
    FDAccounts.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDAccounts;
end;

{ TDAccounts ******************************************************************}

procedure TDAccounts.aDeleteExecute(Sender: TObject);
begin
  if (MsgBox(Preferences.LoadStr(46, FList.Selected.Caption), Preferences.LoadStr(101), MB_YESNOCANCEL + MB_ICONQUESTION) = IDYES) then
    if (Accounts.DeleteAccount(Accounts.AccountByName(FList.Selected.Caption))) then
    begin
      SetFAccounts(nil);
      FBCancel.Caption := Preferences.LoadStr(231);
    end;

  ActiveControl := FList;
end;

procedure TDAccounts.aECopyExecute(Sender: TObject);
var
  Global: HGLOBAL;
  Opened: Boolean;
  Retry: Integer;
  S: string;
begin
  Retry := 0;
  repeat
    Opened := OpenClipboard(Handle);
    if (not Opened) then
    begin
      Sleep(50);
      Inc(Retry);
    end;
  until (Opened or (Retry = 10));

  if (not Opened) then
    raise EClipboardException.CreateFmt(SCannotOpenClipboard, [SysErrorMessage(GetLastError)])
  else
  begin
    try
      S := TPAccount(FList.Selected.Data).Name;
      Global := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, SizeOf(S[1]) * (Length(S) + 1));
      StrPCopy(GlobalLock(Global), S);
      SetClipboardData(CF_UNICODETEXT, Global);
      GlobalUnlock(Global);

      Global := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, SizeOf(S[1]) * (Length(S) + 1));
      StrPCopy(GlobalLock(Global), S);
      SetClipboardData(CF_ACCOUNT, Global);
      GlobalUnlock(Global);
    finally
      CloseClipboard();
    end;
  end;
end;

procedure TDAccounts.aEditExecute(Sender: TObject);
begin
  DAccount.Account := Accounts.AccountByName(FList.Selected.Caption);
  DAccount.Username := DAccount.Account.Connection.Username;
  DAccount.Password := DAccount.Account.Connection.Password;
  if (DAccount.Execute()) then
  begin
    SetFAccounts(Accounts.AccountByName(DAccount.AccountName));
    FBCancel.Caption := Preferences.LoadStr(231);
  end;
  ActiveControl := FList;
end;

procedure TDAccounts.aEPasteExecute(Sender: TObject);
var
  Account: TPAccount;
  AccountName: string;
  ClipboardData: Pointer;
  Global: HGLOBAL;
  I: Integer;
  Opened: Boolean;
  Retry: Integer;
  SourceAccount: TPAccount;
begin
  Retry := 0;
  repeat
    Opened := OpenClipboard(Handle);
    if (not Opened) then
    begin
      Sleep(50);
      Inc(Retry);
    end;
  until (Opened or (Retry = 10));

  if (not Opened) then
    raise EClipboardException.CreateFmt(SCannotOpenClipboard, [SysErrorMessage(GetLastError)])
  else
  begin
    try
      Global := GetClipboardData(CF_ACCOUNT);
      if (Global <> 0) then
      begin
        ClipboardData := GlobalLock(Global);
        if (Assigned(ClipboardData)) then
          AccountName := StrPas(PChar(ClipboardData));
        GlobalUnlock(Global);
      end;
    finally
      CloseClipboard();
    end;

    SourceAccount := Accounts.AccountByName(AccountName);
    if (Assigned(SourceAccount)) then
    begin
      I := 1;
      while (Assigned(Accounts.AccountByName(AccountName))) do
      begin
        if (I = 1) then
          AccountName := Preferences.LoadStr(680, SourceAccount.Name)
        else
          AccountName := Preferences.LoadStr(681, SourceAccount.Name, IntToStr(I));
        Inc(I);
      end;

      Account := TPAccount.Create(Accounts);
      Account.Assign(SourceAccount);
      Account.Name := AccountName;
      Accounts.AddAccount(Account);
      Account.Free();

      SetFAccounts(Accounts.AccountByName(AccountName));
    end;
  end;
end;

procedure TDAccounts.aNewExecute(Sender: TObject);
begin
  DAccount.Account := nil;
  DAccount.Username := 'root';
  DAccount.Password := '';
  if (DAccount.Execute()) then
  begin
    Accounts.Save();
    FList.Items.BeginUpdate();
    FList.Items.Clear();
    SetFAccounts(Accounts.AccountByName(DAccount.AccountName));
    FList.Items.EndUpdate();
    FBCancel.Caption := Preferences.LoadStr(231);
  end;

  ActiveControl := FList;
end;

procedure TDAccounts.aOpenExecute(Sender: TObject);
begin
  if (Open) then
    FBOk.Click()
  else
    if (Boolean(SendMessage(Application.MainForm.Handle, UM_ADDTAB, 0, LPARAM(TPAccount(FList.Selected.Data).Desktop.Address)))) then
      FBOk.Click();
end;

procedure TDAccounts.aOpenInNewWindowExecute(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar(Application.ExeName), PChar(TPAccount(TPAccount(FList.Selected.Data).Desktop.Address)), '', SW_SHOW);
  FBCancel.Click();
end;

procedure TDAccounts.CMSysFontChanged(var Message: TMessage);
begin
  inherited;

  MinColumnWidth := FList.Canvas.TextWidth('ee');
end;

function TDAccounts.Execute(): Boolean;
begin
  Process := Process + 'a';

  // Debug 2017-05-24
  CancelDrag;
  if Visible or not Enabled or (fsModal in FFormState) or
    (FormStyle = fsMDIChild) then
    raise EInvalidOperation.Create(
      'Visible: ' + BoolToStr(Visible, True) + #13#10
      + 'Enabled: ' + BoolToStr(Enabled, True) + #13#10
      + 'Modal: ' + BoolToStr(fsModal in FormState, True) + #13#10
      + 'FormStyle: ' + BoolToStr(FormStyle = fsMDIChild, True));

  try
    Result := ShowModal() = mrOk;
  except
      raise EAssertionFailed.Create(
        'Visible: ' + BoolToStr(Visible, True) + #13#10
        + 'Enabled: ' + BoolToStr(Enabled, True) + #13#10
        + 'Modal: ' + BoolToStr(fsModal in FormState, True) + #13#10
        + 'FormStyle: ' + BoolToStr(FormStyle = fsMDIChild, True)
        + 'Process: ' + Process);
  end;
  Process := Process + 'd';
end;

procedure TDAccounts.FBOkEnabledCheck(Sender: TObject);
begin
  FBOk.Enabled := Assigned(FList.Selected);
end;

procedure TDAccounts.FormActivate(Sender: TObject);
begin
  if (FList.Items.Count = 0) then
    aNew.Execute();
end;

procedure TDAccounts.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ((ModalResult = mrOk) and not Assigned(Session)) then
  begin
    Session := TSSession.Create(Sessions, Accounts.AccountByName(FList.Selected.Caption));
    DConnecting.Session := Session;
    CanClose := DConnecting.Execute();
    if (not CanClose) then
      FreeAndNil(Session);
  end;
end;

procedure TDAccounts.FormCreate(Sender: TObject);
begin
  FList.SmallImages := Preferences.Images;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  miICopy.Action := aECopy;
  miIPaste.Action := aEPaste;

  IgnoreColumnResize := False;
  IgnoreResize := False;
end;

procedure TDAccounts.FormHide(Sender: TObject);
begin
  Process := Process + 'c';

  if (ModalResult = mrOk) then
    Accounts.Default := Accounts.AccountByName(FList.Selected.Caption);

  aECopy.OnExecute := nil;
  aEPaste.OnExecute := nil;

  Preferences.Accounts.Height := Height;
  Preferences.Accounts.Width := Width;
  if (FList.Columns[FList.Tag] = TListColumn(miHName.Tag)) then
    Preferences.Accounts.Sort.Column := acName
  else if (FList.Columns[FList.Tag] = TListColumn(miHHost.Tag)) then
    Preferences.Accounts.Sort.Column := acHost
  else if (FList.Columns[FList.Tag] = TListColumn(miHUser.Tag)) then
    Preferences.Accounts.Sort.Column := acUser
  else if (FList.Columns[FList.Tag] = TListColumn(miHDatabase.Tag)) then
    Preferences.Accounts.Sort.Column := acDatabase
  else if (FList.Columns[FList.Tag] = TListColumn(miHLastLogin.Tag)) then
    Preferences.Accounts.Sort.Column := acLastLogin;
  Preferences.Accounts.Sort.Ascending := FList.Columns[FList.Tag].Tag = 1;
  Preferences.Accounts.Width := Width;
  Preferences.Accounts.Widths[acName] := FList.Columns[0].Width;
  if (not miHHost.Checked) then
    Preferences.Accounts.Widths[acHost] := -1
  else
    Preferences.Accounts.Widths[acHost] := TListColumn(miHHost.Tag).Width;
  if (not miHUser.Checked) then
    Preferences.Accounts.Widths[acUser] := -1
  else
    Preferences.Accounts.Widths[acUser] := TListColumn(miHUser.Tag).Width;
  if (not miHDatabase.Checked) then
    Preferences.Accounts.Widths[acDatabase] := -1
  else
    Preferences.Accounts.Widths[acDatabase] := TListColumn(miHDatabase.Tag).Width;
  if (not miHLastLogin.Checked) then
    Preferences.Accounts.Widths[acLastLogin] := -1
  else
    Preferences.Accounts.Widths[acLastLogin] := TListColumn(miHLastLogin.Tag).Width;
end;

procedure TDAccounts.FormShow(Sender: TObject);
begin
  Process := Process + 'b';

  if ((Preferences.Accounts.Width >= Width) and (Preferences.Accounts.Height >= Height)) then
  begin
    Width := Preferences.Accounts.Width;
    Height := Preferences.Accounts.Height;
  end;

  if (not Open) then
    Caption := Preferences.LoadStr(25)
  else
    Caption := Preferences.LoadStr(1);

  aECopy.OnExecute := aECopyExecute;
  aEPaste.OnExecute := aEPasteExecute;

  FList.Tag := -1;
  miHName.Checked := True;
  miHHost.Checked := Preferences.Accounts.Widths[acHost] >= 0;
  miHUser.Checked := Preferences.Accounts.Widths[acUser] >= 0;
  miHDatabase.Checked := Preferences.Accounts.Widths[acDatabase] >= 0;
  miHLastLogin.Checked := Preferences.Accounts.Widths[acLastLogin] >= 0;

  SetFAccounts(Accounts.Default);

  if ((Preferences.Accounts.Widths[acName] > 0) and Assigned(TListColumn(miHName.Tag))) then
    TListColumn(miHName.Tag).Width := Preferences.Accounts.Widths[acName];
  if ((Preferences.Accounts.Widths[acHost] > 0) and Assigned(TListColumn(miHHost.Tag))) then
    TListColumn(miHHost.Tag).Width := Preferences.Accounts.Widths[acHost];
  if ((Preferences.Accounts.Widths[acUser] > 0) and Assigned(TListColumn(miHUser.Tag))) then
    TListColumn(miHUser.Tag).Width := Preferences.Accounts.Widths[acUser];
  if ((Preferences.Accounts.Widths[acDatabase] > 0) and Assigned(TListColumn(miHDatabase.Tag))) then
    TListColumn(miHDatabase.Tag).Width := Preferences.Accounts.Widths[acDatabase];
  if ((Preferences.Accounts.Widths[acLastLogin] > 0) and Assigned(TListColumn(miHName.Tag))) then
    TListColumn(miHName.Tag).Width := Preferences.Accounts.Widths[acName];

  case (Preferences.Accounts.Sort.Column) of
    acName: FList.Tag := TListColumn(miHName.Tag).Index;
    acHost: FList.Tag := TListColumn(miHHost.Tag).Index;
    acUser: FList.Tag := TListColumn(miHUser.Tag).Index;
    acDatabase: FList.Tag := TListColumn(miHDatabase.Tag).Index;
    acLastLogin: FList.Tag := TListColumn(miHLastLogin.Tag).Index;
  end;
  if ((0 <= FList.Tag) and (FList.Tag < FList.Columns.Count)) then
    if (Preferences.Accounts.Sort.Ascending) then
      FList.Columns[FList.Tag].Tag := 1
    else
      FList.Columns[FList.Tag].Tag := -1;

  Session := nil;

  FBOk.Visible := Open;
  if (not Open) then
    FBCancel.Caption := Preferences.LoadStr(231)
  else
    FBCancel.Caption := Preferences.LoadStr(30);

  FBOk.Default := Open;
  FBCancel.Default := not FBOk.Default;

  ActiveControl := FList;

  FBOkEnabledCheck(Sender);

  PostMessage(Handle, UM_POST_SHOW, 0, 0);
end;

procedure TDAccounts.HeaderMenuClick(Sender: TObject);
begin
  FList.Tag := 0;

  if (not Assigned(FList.Selected)) then
    SetFAccounts(nil)
  else
    SetFAccounts(TPAccount(FList.Selected.Data));
end;

procedure TDAccounts.FListColumnClick(Sender: TObject;
  Column: TListColumn);
var
  I: Integer;
begin
  for I := 0 to FList.Columns.Count - 1 do
    if (FList.Column[I] <> Column) then
      FList.Column[I].Tag := 0
    else if (FList.Column[I].Tag < 0) then
      FList.Column[I].Tag := 1
    else if (FList.Column[I].Tag > 0) then
      FList.Column[I].Tag := -1
    else if (I = FList.Columns.Count - 1) then
      FList.Column[I].Tag := -1
    else
      FList.Column[I].Tag := 1;

  FList.Tag := Column.Index;
  FList.AlphaSort();

  ListViewShowSortDirection(FList);
end;

procedure TDAccounts.FListColumnResize(Sender: TObject; Column: TListColumn);
var
  ColumnIndex: Integer;
  I: Integer;
  ColumnWidthSum: Integer;
begin
  if (not IgnoreColumnResize) then
  begin
    ColumnIndex := -1;
    for I := 0 to FList.Columns.Count - 1 do
      if (FList.Columns[I] = Column) then
        ColumnIndex := I;

    if ((0 <= ColumnIndex) and (ColumnIndex < FList.Columns.Count - 1)) then
    begin
      IgnoreColumnResize := True;
      IgnoreResize := True;
      FList.DisableAlign();

      ColumnWidthSum := 0;
      for I := 0 to FList.Columns.Count - 1 do
        if (I <> ColumnIndex + 1) then
          Inc(ColumnWidthSum, FList.Columns[I].Width);
      FList.Columns[ColumnIndex + 1].Width := Max(FList.ClientWidth - ColumnWidthSum, MinColumnWidth);

      FList.EnableAlign();
      IgnoreResize := False;
      IgnoreColumnResize := False;
    end;
  end;
end;

procedure TDAccounts.FListCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Column: TListColumn;
begin
  Column := FList.Columns[FList.Tag];

  if (Column = TListColumn(miHName.Tag)) then
    Compare := TListColumn(miHName.Tag).Tag * Sign(lstrcmpi(PChar(TPAccount(Item1.Data).Name), PChar(TPAccount(Item2.Data).Name)))
  else if (Column = TListColumn(miHHost.Tag)) then
    Compare := TListColumn(miHHost.Tag).Tag * Sign(lstrcmpi(PChar(TPAccount(Item1.Data).Connection.Caption), PChar(TPAccount(Item2.Data).Connection.Caption)))
  else if (Column = TListColumn(miHUser.Tag)) then
    Compare := TListColumn(miHUser.Tag).Tag * Sign(lstrcmpi(PChar(TPAccount(Item1.Data).Connection.Username), PChar(TPAccount(Item2.Data).Connection.Username)))
  else if (Column = TListColumn(miHDatabase.Tag)) then
    Compare := TListColumn(miHDatabase.Tag).Tag * Sign(lstrcmpi(PChar(TPAccount(Item1.Data).Connection.Database), PChar(TPAccount(Item2.Data).Connection.Database)))
  else if (Column = TListColumn(miHLastLogin.Tag)) then
    Compare := TListColumn(miHLastLogin.Tag).Tag * Sign(TPAccount(Item1.Data).LastLogin - TPAccount(Item2.Data).LastLogin)
  else
    raise ERangeError.Create(SRangeError);
end;

procedure TDAccounts.FListContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  HeaderRect: TRect;
  Pos: TPoint;
begin
  GetWindowRect(ListView_GetHeader(FList.Handle), HeaderRect);
  Pos := FList.ClientToScreen(MousePos);
  if PtInRect(HeaderRect, Pos) then
    HeaderMenu.Popup(Pos.X, Pos.Y)
  else
    ItemMenu.Popup(Pos.X, Pos.Y);
end;

procedure TDAccounts.FListDblClick(Sender: TObject);
begin
  if (Open and FBOk.Enabled) then
    FBOk.Click()
  else if (not Open and aEdit.Enabled) then
    aEdit.Execute();
end;

procedure TDAccounts.FListResize(Sender: TObject);
var
  ColumnWidthsSum: Integer;
  I: Integer;
  LastColumnWidth: Integer;
begin
  if (not IgnoreResize and (FList.Columns.Count > 0)) then
  begin
    ColumnWidthsSum := 0;
    for I := 0 to FList.Columns.Count - 1 do
      Inc(ColumnWidthsSum, FList.Columns[I].Width);
    if (ColumnWidthsSum > 0) then
    begin
      IgnoreColumnResize := True;
      IgnoreResize := True;
      FList.DisableAlign();

      LastColumnWidth := FList.ClientWidth;
      for I := 0 to FList.Columns.Count - 2 do
      begin
        FList.Columns[I].Width := FList.Columns[I].Width * FList.ClientWidth div ColumnWidthsSum;
        Dec(LastColumnWidth, FList.Columns[I].Width);
      end;
      FList.Columns[FList.Columns.Count - 1].Width := LastColumnWidth;

      FList.EnableAlign();
      IgnoreResize := False;
      IgnoreColumnResize := False;
    end;
  end;

  if (Assigned(FList.ItemFocused) and (FList.Items.Count > 1) and (FList.ItemFocused.Position.Y - FList.ClientHeight + (FList.Items[1].Top - FList.Items[0].Top) > 0)) then
    FList.Scroll(0, FList.ItemFocused.Position.Y - FList.ClientHeight + (FList.Items[1].Top - FList.Items[0].Top));
end;

procedure TDAccounts.FListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  Account: TPAccount;
begin
  if (not Assigned(Item)) then
    Account := nil
  else
    Account := Accounts.AccountByName(Item.Caption);

  aECopy.Enabled := Assigned(Item) and Selected;
  aEPaste.Enabled := not Selected and IsClipboardFormatAvailable(CF_ACCOUNT);
  aDelete.Enabled := Assigned(Item) and Selected and Assigned(Account) and (Account.SessionCount = 0);
  aEdit.Enabled := Assigned(Item) and Selected and Assigned(Account);

  FBOkEnabledCheck(Sender);
  FBOk.Default := FBOk.Enabled;
end;

procedure TDAccounts.ItemMenuPopup(Sender: TObject);
begin
  aOpen.Enabled := Open and Assigned(FList.Selected);
  aOpenInNewWindow.Enabled := aOpen.Enabled;
  miIOpen.Default := Open;
  miIEdit.Default := not miIOpen.Default;
  ShowEnabledItems(ItemMenu.Items);
  miINew.Visible := not Assigned(FList.Selected);
end;

procedure TDAccounts.ListViewShowSortDirection(const ListView: TListView);
var
  Column: TListColumn;
  HDItem: THDItem;
  I: Integer;
begin
  Column := ListView.Column[ListView.Tag];

  HDItem.Mask := HDI_WIDTH or HDI_FORMAT;
  for I := 0 to ListView.Columns.Count - 1 do
    if (BOOL(SendMessage(ListView_GetHeader(ListView.Handle), HDM_GETITEM, I, LParam(@HDItem)))) then
    begin
      case (ListView.Column[I].Tag) of
        -1: HDItem.fmt := HDItem.fmt and not HDF_SORTUP or HDF_SORTDOWN;
        1: HDItem.fmt := HDItem.fmt and not HDF_SORTDOWN or HDF_SORTUP;
        else HDItem.fmt := HDItem.fmt and not HDF_SORTUP and not HDF_SORTDOWN;
      end;

      SendMessage(ListView_GetHeader(ListView.Handle), HDM_SETITEM, I, LParam(@HDItem));
    end;

  if (CheckWin32Version(6) and not CheckWin32Version(6, 1)) then
    SendMessage(ListView.Handle, LVM_SETSELECTEDCOLUMN, Column.Index, 0);
end;

procedure TDAccounts.SetFAccounts(const ASelected: TPAccount);
var
  I: Integer;
  Item: TListItem;
  LastColumnWidth: Integer;
  NewColumnCount: Integer;
  OldColumnCount: Integer;
  OldColumnWidths: array[0 .. 5 {HeaderMenu.Items.Count} - 1] of Integer;
begin
  IgnoreColumnResize := True;
  FList.DisableAlign();
  FList.Columns.BeginUpdate();
  FList.Items.BeginUpdate();
  FList.Items.Clear();

  OldColumnCount := FList.Columns.Count;
  for I := 0 to FList.Columns.Count - 1 do
    OldColumnWidths[I] := FList.Columns[I].Width;
  FList.Columns.Clear();
  if (not miHName.Checked) then
    miHName.Tag := 0
  else
  begin
    FList.Columns.Add().Caption := ReplaceStr(miHName.Caption, '&', '');
    miHName.Tag := NativeInt(FList.Columns[FList.Columns.Count - 1]);
  end;
  if (not miHHost.Checked) then
    miHHost.Tag := 0
  else
  begin
    FList.Columns.Add().Caption := ReplaceStr(miHHost.Caption, '&', '');
    miHHost.Tag := NativeInt(FList.Columns[FList.Columns.Count - 1]);
  end;
  if (not miHUser.Checked) then
    miHUser.Tag := 0
  else
  begin
    FList.Columns.Add().Caption := ReplaceStr(miHUser.Caption, '&', '');
    miHUser.Tag := NativeInt(FList.Columns[FList.Columns.Count - 1]);
  end;
  if (not miHDatabase.Checked) then
    miHDatabase.Tag := 0
  else
  begin
    FList.Columns.Add().Caption := ReplaceStr(miHDatabase.Caption, '&', '');
    miHDatabase.Tag := NativeInt(FList.Columns[FList.Columns.Count - 1]);
  end;
  if (not miHLastLogin.Checked) then
    miHLastLogin.Tag := 0
  else
  begin
    FList.Columns.Add().Caption := ReplaceStr(miHLastLogin.Caption, '&', '');
    miHLastLogin.Tag := NativeInt(FList.Columns[FList.Columns.Count - 1]);
  end;
  NewColumnCount := FList.Columns.Count;

  FList.Columns.EndUpdate();

  LastColumnWidth := FList.ClientWidth;
  for I := 0 to FList.Columns.Count - 2 do
  begin
    FList.Columns[I].Width := OldColumnWidths[I] * OldColumnCount div NewColumnCount;
    Dec(LastColumnWidth, FList.Columns[I].Width);
  end;
  FList.Columns[FList.Columns.Count - 1].Width := LastColumnWidth;

  if (Accounts.Count = 0) then
    FListSelectItem(FList, nil, False)
  else
    for I := 0 to Accounts.Count - 1 do
    begin
      Item := FList.Items.Add();
      Item.Caption := Accounts[I].Name;
      if (miHHost.Checked) then
        Item.SubItems.Add(Accounts[I].Connection.Caption);
      if (miHUser.Checked) then
        Item.SubItems.Add(Accounts[I].Connection.Username);
      if (miHDatabase.Checked) then
        Item.SubItems.Add(Accounts[I].Connection.Database);
      if (miHLastLogin.Checked) then
        if (Accounts[I].LastLogin = 0) then
          Item.SubItems.Add('???')
        else
          Item.SubItems.Add(DateTimeToStr(Accounts[I].LastLogin, LocaleFormatSettings));
      Item.ImageIndex := 23;
      Item.Data := Accounts[I];
    end;

  if ((0 <= FList.Tag) and (FList.Tag < FList.Columns.Count)) then
    FListColumnClick(Account, FList.Columns[FList.Tag]);

  if (not Assigned(ASelected)) and (FList.Items.Count > 0) then
    FList.Selected := FList.Items.Item[0]
  else
    for I := 0 to FList.Items.Count - 1 do
      if (ASelected <> nil) and (FList.Items.Item[I].Caption = ASelected.Name) then
        FList.Selected := FList.Items.Item[I];

  FList.ItemFocused := FList.Selected;
  FListResize(nil);

  FList.Items.EndUpdate();
  FList.EnableAlign();
  IgnoreColumnResize := False;
end;

procedure TDAccounts.UMPostShow(var Message: TMessage);
begin
  ListViewShowSortDirection(FList);
end;

procedure TDAccounts.UMPreferencesChanged(var Message: TMessage);
begin
  FList.Canvas.Font := Font;

  Preferences.Images.GetIcon(40, Icon);

  GAccounts.Caption := Preferences.LoadStr(25);
  miHName.Caption := Preferences.LoadStr(35);
  miHHost.Caption := Preferences.LoadStr(906);
  miHUser.Caption := Preferences.LoadStr(561);
  miHDatabase.Caption := Preferences.LoadStr(38);
  miHLastLogin.Caption := Preferences.LoadStr(693);

  aOpen.Caption := Preferences.LoadStr(581);
  aOpenInNewWindow.Caption := Preferences.LoadStr(760);
  aNew.Caption := Preferences.LoadStr(26) + '...';
  aEdit.Caption := Preferences.LoadStr(97) + '...';
  aDelete.Caption := Preferences.LoadStr(28);

  FBOk.Caption := Preferences.LoadStr(581);
end;

initialization
  FDAccounts := nil;
  Process := '';
end.


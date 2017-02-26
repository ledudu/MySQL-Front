unit uDAccounts;

interface {********************************************************************}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus, ActnList, ImgList, ToolWin,
  StdCtrls_Ext, ComCtrls_Ext, ExtCtrls_Ext, Forms_Ext,
  uSession, uPreferences, uBase, System.Actions;

type
  TDAccounts = class (TForm_Ext)
    ActionList: TActionList;
    aDelete: TAction;
    aEdit: TAction;
    aNew: TAction;
    aOpen: TAction;
    FBCancel: TButton;
    FBDelete: TButton;
    FBEdit: TButton;
    FBNew: TButton;
    FBOk: TButton;
    FAccounts: TListView_Ext;
    GAccounts: TGroupBox_Ext;
    HeaderMenu: TPopupMenu;
    ItemMenu: TPopupMenu;
    miHHost: TMenuItem;
    miHName: TMenuItem;
    miHDatabase: TMenuItem;
    miHLastLogin: TMenuItem;
    miHUser: TMenuItem;
    miIDelete: TMenuItem;
    miIEdit: TMenuItem;
    miINew: TMenuItem;
    miIOpen: TMenuItem;
    N2: TMenuItem;
    PAccounts: TPanel_Ext;
    procedure aDeleteExecute(Sender: TObject);
    procedure aEditExecute(Sender: TObject);
    procedure aNewExecute(Sender: TObject);
    procedure aOpenExecute(Sender: TObject);
    procedure FBOkEnabledCheck(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FAccountsColumnClick(Sender: TObject; Column: TListColumn);
    procedure FAccountsColumnResize(Sender: TObject; Column: TListColumn);
    procedure FAccountsCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure FAccountsContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure FAccountsDblClick(Sender: TObject);
    procedure FAccountsResize(Sender: TObject);
    procedure FAccountsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure HeaderMenuClick(Sender: TObject);
    procedure ItemMenuPopup(Sender: TObject);
  private
    IgnoreColumnResize: Boolean;
    IgnoreResize: Boolean;
    MinColumnWidth: Integer;
    procedure ListViewShowSortDirection(const ListView: TListView);
    procedure SetFAccounts(const ASelected: TPAccount);
    procedure CMSysFontChanged(var Message: TMessage); message CM_SYSFONTCHANGED;
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
    procedure UMPostShow(var Message: TMessage); message UM_POST_SHOW;
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
  CommCtrl, Math, StrUtils, SysConst,
  CommCtrl_Ext,
  MySQLConsts,
  uDAccount, uDConnecting;

var
  FDAccounts: TDAccounts;

function DAccounts(): TDAccounts;
begin
  if (not Assigned(FDAccounts)) then
  begin
    Application.CreateForm(TDAccounts, FDAccounts);
    FDAccounts.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDAccounts;
end;

{ TDAccounts ******************************************************************}

procedure TDAccounts.aDeleteExecute(Sender: TObject);
begin
  if (MsgBox(Preferences.LoadStr(46, FAccounts.Selected.Caption), Preferences.LoadStr(101), MB_YESNOCANCEL + MB_ICONQUESTION) = IDYES) then
    if (Accounts.DeleteAccount(Accounts.AccountByName(FAccounts.Selected.Caption))) then
    begin
      SetFAccounts(nil);
      FBCancel.Caption := Preferences.LoadStr(231);
    end;

  ActiveControl := FAccounts;
end;

procedure TDAccounts.aEditExecute(Sender: TObject);
begin
  DAccount.Account := Accounts.AccountByName(FAccounts.Selected.Caption);
  DAccount.Username := DAccount.Account.Connection.Username;
  DAccount.Password := DAccount.Account.Connection.Password;
  DAccount.ShowType := stDefault;
  if (DAccount.Execute()) then
  begin
    SetFAccounts(Accounts.AccountByName(DAccount.AccountName));
    FBCancel.Caption := Preferences.LoadStr(231);
  end;
  ActiveControl := FAccounts;
end;

procedure TDAccounts.aNewExecute(Sender: TObject);
begin
  DAccount.Account := nil;
  DAccount.Username := 'root';
  DAccount.Password := '';
  DAccount.ShowType := stDefault;
  if (DAccount.Execute()) then
  begin
    Accounts.Save();
    SetFAccounts(Accounts.AccountByName(DAccount.AccountName));
    FBCancel.Caption := Preferences.LoadStr(231);
  end;

  ActiveControl := FAccounts;
end;

procedure TDAccounts.aOpenExecute(Sender: TObject);
begin
  if (Open) then
    FBOk.Click()
  else
    if (Boolean(SendMessage(Application.MainForm.Handle, UM_ADDTAB, 0, LPARAM(Accounts.AccountByName(FAccounts.Selected.Caption).Desktop.Address)))) then
      FBOk.Click();
end;

procedure TDAccounts.CMSysFontChanged(var Message: TMessage);
begin
  inherited;

  MinColumnWidth := FAccounts.Canvas.TextWidth('ee');
end;

function TDAccounts.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;

  // Debug 2016-12-23
  // This is a helper for a problem in TWWindow.UMUpdateToolbar
  if (Assigned(Session) and not Assigned(Session.Account.Desktop)) then
    raise ERangeError.Create(SRangeError);
end;

procedure TDAccounts.FBOkEnabledCheck(Sender: TObject);
begin
  FBOk.Enabled := Assigned(FAccounts.Selected);
end;

procedure TDAccounts.FormActivate(Sender: TObject);
begin
  if (FAccounts.Items.Count = 0) then
    aNew.Execute();
end;

procedure TDAccounts.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ((ModalResult = mrOk) and not Assigned(Session)) then
  begin
    Session := TSSession.Create(Sessions, Accounts.AccountByName(FAccounts.Selected.Caption));
    DConnecting.Session := Session;
    CanClose := DConnecting.Execute();
    if (not CanClose) then
      FreeAndNil(Session)
    else
    begin
      // Debug 2016-12-23
      // This is a helper for a problem in TWWindow.UMUpdateToolbar
      if (not Assigned(Session.Account.Desktop)) then
        raise ERangeError.Create(SRangeError);
    end;
  end;
end;

procedure TDAccounts.FormCreate(Sender: TObject);
begin
  FAccounts.SmallImages := Preferences.Images;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  IgnoreColumnResize := False;
  IgnoreResize := False;
end;

procedure TDAccounts.FormHide(Sender: TObject);
begin
  if (ModalResult = mrOk) then
    Accounts.Default := Accounts.AccountByName(FAccounts.Selected.Caption);

  Preferences.Accounts.Height := Height;
  Preferences.Accounts.Width := Width;
  if (FAccounts.Columns[FAccounts.Tag] = TListColumn(miHName.Tag)) then
    Preferences.Accounts.Sort.Column := acName
  else if (FAccounts.Columns[FAccounts.Tag] = TListColumn(miHHost.Tag)) then
    Preferences.Accounts.Sort.Column := acHost
  else if (FAccounts.Columns[FAccounts.Tag] = TListColumn(miHUser.Tag)) then
    Preferences.Accounts.Sort.Column := acUser
  else if (FAccounts.Columns[FAccounts.Tag] = TListColumn(miHDatabase.Tag)) then
    Preferences.Accounts.Sort.Column := acDatabase
  else if (FAccounts.Columns[FAccounts.Tag] = TListColumn(miHLastLogin.Tag)) then
    Preferences.Accounts.Sort.Column := acLastLogin;
  Preferences.Accounts.Sort.Ascending := FAccounts.Columns[FAccounts.Tag].Tag = 1;
  Preferences.Accounts.Width := Width;
  Preferences.Accounts.Widths[acName] := FAccounts.Columns[0].Width;
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
  if ((Preferences.Accounts.Width >= Width) and (Preferences.Accounts.Height >= Height)) then
  begin
    Width := Preferences.Accounts.Width;
    Height := Preferences.Accounts.Height;
  end;

  if (not Open) then
    Caption := Preferences.LoadStr(25)
  else
    Caption := Preferences.LoadStr(1);

  FAccounts.Tag := -1;
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
    acName: FAccounts.Tag := TListColumn(miHName.Tag).Index;
    acHost: FAccounts.Tag := TListColumn(miHHost.Tag).Index;
    acUser: FAccounts.Tag := TListColumn(miHUser.Tag).Index;
    acDatabase: FAccounts.Tag := TListColumn(miHDatabase.Tag).Index;
    acLastLogin: FAccounts.Tag := TListColumn(miHLastLogin.Tag).Index;
  end;
  if ((0 <= FAccounts.Tag) and (FAccounts.Tag < FAccounts.Columns.Count)) then
    if (Preferences.Accounts.Sort.Ascending) then
      FAccounts.Columns[FAccounts.Tag].Tag := 1
    else
      FAccounts.Columns[FAccounts.Tag].Tag := -1;

  Session := nil;

  FBOk.Visible := Open;
  if (not Open) then
    FBCancel.Caption := Preferences.LoadStr(231)
  else
    FBCancel.Caption := Preferences.LoadStr(30);

  FBOk.Default := Open;
  FBCancel.Default := not FBOk.Default;

  ActiveControl := FAccounts;

  FBOkEnabledCheck(Sender);

  PostMessage(Handle, UM_POST_SHOW, 0, 0);
end;

procedure TDAccounts.HeaderMenuClick(Sender: TObject);
begin
  FAccounts.Tag := 0;

  if (not Assigned(FAccounts.Selected)) then
    SetFAccounts(nil)
  else
    SetFAccounts(TPAccount(FAccounts.Selected.Data));
end;

procedure TDAccounts.FAccountsColumnClick(Sender: TObject;
  Column: TListColumn);
var
  I: Integer;
begin
  for I := 0 to FAccounts.Columns.Count - 1 do
    if (FAccounts.Column[I] <> Column) then
      FAccounts.Column[I].Tag := 0
    else if (FAccounts.Column[I].Tag < 0) then
      FAccounts.Column[I].Tag := 1
    else if (FAccounts.Column[I].Tag > 0) then
      FAccounts.Column[I].Tag := -1
    else if (I = FAccounts.Columns.Count - 1) then
      FAccounts.Column[I].Tag := -1
    else
      FAccounts.Column[I].Tag := 1;

  FAccounts.Tag := Column.Index;
  FAccounts.AlphaSort();

  ListViewShowSortDirection(FAccounts);
end;

procedure TDAccounts.FAccountsColumnResize(Sender: TObject; Column: TListColumn);
var
  ColumnIndex: Integer;
  I: Integer;
  ColumnWidthSum: Integer;
begin
  if (not IgnoreColumnResize) then
  begin
    ColumnIndex := -1;
    for I := 0 to FAccounts.Columns.Count - 1 do
      if (FAccounts.Columns[I] = Column) then
        ColumnIndex := I;

    if ((0 <= ColumnIndex) and (ColumnIndex < FAccounts.Columns.Count - 1)) then
    begin
      IgnoreColumnResize := True;
      IgnoreResize := True;
      FAccounts.DisableAlign();

      ColumnWidthSum := 0;
      for I := 0 to FAccounts.Columns.Count - 1 do
        if (I <> ColumnIndex + 1) then
          Inc(ColumnWidthSum, FAccounts.Columns[I].Width);
      FAccounts.Columns[ColumnIndex + 1].Width := Max(FAccounts.ClientWidth - ColumnWidthSum, MinColumnWidth);

      FAccounts.EnableAlign();
      IgnoreResize := False;
      IgnoreColumnResize := False;
    end;
  end;
end;

procedure TDAccounts.FAccountsCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Column: TListColumn;
begin
  Column := FAccounts.Columns[FAccounts.Tag];

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

procedure TDAccounts.FAccountsContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  HeaderRect: TRect;
  Pos: TPoint;
begin
  GetWindowRect(ListView_GetHeader(FAccounts.Handle), HeaderRect);
  Pos := FAccounts.ClientToScreen(MousePos);
  if PtInRect(HeaderRect, Pos) then
    HeaderMenu.Popup(Pos.X, Pos.Y)
  else
    ItemMenu.Popup(Pos.X, Pos.Y);
end;

procedure TDAccounts.FAccountsDblClick(Sender: TObject);
begin
  if (Open and FBOk.Enabled) then
    FBOk.Click()
  else if (not Open and aEdit.Enabled) then
    aEdit.Execute();
end;

procedure TDAccounts.FAccountsResize(Sender: TObject);
var
  ColumnWidthsSum: Integer;
  I: Integer;
  LastColumnWidth: Integer;
begin
  if (not IgnoreResize and (FAccounts.Columns.Count > 0)) then
  begin
    ColumnWidthsSum := 0;
    for I := 0 to FAccounts.Columns.Count - 1 do
      Inc(ColumnWidthsSum, FAccounts.Columns[I].Width);
    if (ColumnWidthsSum > 0) then
    begin
      IgnoreColumnResize := True;
      IgnoreResize := True;
      FAccounts.DisableAlign();

      LastColumnWidth := FAccounts.ClientWidth;
      for I := 0 to FAccounts.Columns.Count - 2 do
      begin
        FAccounts.Columns[I].Width := FAccounts.Columns[I].Width * FAccounts.ClientWidth div ColumnWidthsSum;
        Dec(LastColumnWidth, FAccounts.Columns[I].Width);
      end;
      FAccounts.Columns[FAccounts.Columns.Count - 1].Width := LastColumnWidth;

      FAccounts.EnableAlign();
      IgnoreResize := False;
      IgnoreColumnResize := False;
    end;
  end;

  if (Assigned(FAccounts.ItemFocused) and (FAccounts.Items.Count > 1) and (FAccounts.ItemFocused.Position.Y - FAccounts.ClientHeight + (FAccounts.Items[1].Top - FAccounts.Items[0].Top) > 0)) then
    FAccounts.Scroll(0, FAccounts.ItemFocused.Position.Y - FAccounts.ClientHeight + (FAccounts.Items[1].Top - FAccounts.Items[0].Top));
end;

procedure TDAccounts.FAccountsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  Account: TPAccount;
begin
  if (not Assigned(Item)) then
    Account := nil
  else
    Account := Accounts.AccountByName(Item.Caption);

  aDelete.Enabled := Assigned(Item) and Selected and Assigned(Account) and (Account.SessionCount = 0);
  aEdit.Enabled := Assigned(Item) and Selected and Assigned(Account) and (Account.SessionCount = 0);

  FBOkEnabledCheck(Sender);
  FBOk.Default := FBOk.Enabled;
end;

procedure TDAccounts.ItemMenuPopup(Sender: TObject);
begin
  aOpen.Enabled := Open and Assigned(FAccounts.Selected);
  miIOpen.Default := Open;
  miIEdit.Default := not miIOpen.Default;
  ShowEnabledItems(ItemMenu.Items);
  miINew.Visible := not Assigned(FAccounts.Selected);
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
  FAccounts.DisableAlign();
  FAccounts.Columns.BeginUpdate();
  FAccounts.Items.BeginUpdate();
  FAccounts.Items.Clear();

  OldColumnCount := FAccounts.Columns.Count;
  for I := 0 to FAccounts.Columns.Count - 1 do
    OldColumnWidths[I] := FAccounts.Columns[I].Width;
  FAccounts.Columns.Clear();
  if (not miHName.Checked) then
    miHName.Tag := 0
  else
  begin
    FAccounts.Columns.Add().Caption := ReplaceStr(miHName.Caption, '&', '');
    miHName.Tag := NativeInt(FAccounts.Columns[FAccounts.Columns.Count - 1]);
  end;
  if (not miHHost.Checked) then
    miHHost.Tag := 0
  else
  begin
    FAccounts.Columns.Add().Caption := ReplaceStr(miHHost.Caption, '&', '');
    miHHost.Tag := NativeInt(FAccounts.Columns[FAccounts.Columns.Count - 1]);
  end;
  if (not miHUser.Checked) then
    miHUser.Tag := 0
  else
  begin
    FAccounts.Columns.Add().Caption := ReplaceStr(miHUser.Caption, '&', '');
    miHUser.Tag := NativeInt(FAccounts.Columns[FAccounts.Columns.Count - 1]);
  end;
  if (not miHDatabase.Checked) then
    miHDatabase.Tag := 0
  else
  begin
    FAccounts.Columns.Add().Caption := ReplaceStr(miHDatabase.Caption, '&', '');
    miHDatabase.Tag := NativeInt(FAccounts.Columns[FAccounts.Columns.Count - 1]);
  end;
  if (not miHLastLogin.Checked) then
    miHLastLogin.Tag := 0
  else
  begin
    FAccounts.Columns.Add().Caption := ReplaceStr(miHLastLogin.Caption, '&', '');
    miHLastLogin.Tag := NativeInt(FAccounts.Columns[FAccounts.Columns.Count - 1]);
  end;
  NewColumnCount := FAccounts.Columns.Count;

  FAccounts.Columns.EndUpdate();

  LastColumnWidth := FAccounts.ClientWidth;
  for I := 0 to FAccounts.Columns.Count - 2 do
  begin
    FAccounts.Columns[I].Width := OldColumnWidths[I] * OldColumnCount div NewColumnCount;
    Dec(LastColumnWidth, FAccounts.Columns[I].Width);
  end;
  FAccounts.Columns[FAccounts.Columns.Count - 1].Width := LastColumnWidth;

  if (Accounts.Count = 0) then
    FAccountsSelectItem(FAccounts, nil, False)
  else
    for I := 0 to Accounts.Count - 1 do
    begin
      Item := FAccounts.Items.Add();
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

  if ((0 <= FAccounts.Tag) and (FAccounts.Tag < FAccounts.Columns.Count)) then
    FAccountsColumnClick(Account, FAccounts.Columns[FAccounts.Tag]);

  if (not Assigned(ASelected)) and (FAccounts.Items.Count > 0) then
    FAccounts.Selected := FAccounts.Items.Item[0]
  else
    for I := 0 to FAccounts.Items.Count - 1 do
      if (ASelected <> nil) and (FAccounts.Items.Item[I].Caption = ASelected.Name) then
        FAccounts.Selected := FAccounts.Items.Item[I];

  FAccounts.ItemFocused := FAccounts.Selected;
  FAccountsResize(nil);

  FAccounts.Items.EndUpdate();
  FAccounts.EnableAlign();
  IgnoreColumnResize := False;
end;

procedure TDAccounts.UMChangePreferences(var Message: TMessage);
begin
  FAccounts.Canvas.Font := Font;

  Preferences.Images.GetIcon(40, Icon);

  GAccounts.Caption := Preferences.LoadStr(25);
  miHName.Caption := Preferences.LoadStr(35);
  miHHost.Caption := Preferences.LoadStr(906);
  miHUser.Caption := Preferences.LoadStr(561);
  miHDatabase.Caption := Preferences.LoadStr(38);
  miHLastLogin.Caption := Preferences.LoadStr(693);

  aOpen.Caption := Preferences.LoadStr(581);
  aNew.Caption := Preferences.LoadStr(26) + '...';
  aEdit.Caption := Preferences.LoadStr(97) + '...';
  aDelete.Caption := Preferences.LoadStr(28);

  FBOk.Caption := Preferences.LoadStr(581);
end;

procedure TDAccounts.UMPostShow(var Message: TMessage);
begin
  ListViewShowSortDirection(FAccounts);
end;

initialization
  FDAccounts := nil;
end.


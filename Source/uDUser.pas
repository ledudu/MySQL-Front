unit uDUser;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, Menus, ExtCtrls,
  BCEditor.Editor,
  Forms_Ext, StdCtrls_Ext, ComCtrls_Ext,
  uSession,
  uBase, BCEditor.Highlighter;

type
  TDUser = class (TForm_Ext)
    FBCancel: TButton;
    FBHelp: TButton;
    FBOk: TButton;
    FBRightsDelete: TButton;
    FBRightsEdit: TButton;
    FBRightsNew: TButton;
    FConnectionsPerHour: TEdit;
    FHost: TEdit;
    FLConnectionsPerHour: TLabel;
    FLHost: TLabel;
    FLPassword: TLabel;
    FLQueriesPerHour: TLabel;
    FLUpdatesPerHour: TLabel;
    FLName: TLabel;
    FLUserConnections: TLabel;
    FName: TEdit;
    FPassword: TEdit;
    FQueriesPerHour: TEdit;
    FRights: TListView;
    FSource: TBCEditor;
    FUDConnectionsPerHour: TUpDown;
    FUDQueriesPerHour: TUpDown;
    FUDUpdatesPerHour: TUpDown;
    FUDUserConnections: TUpDown;
    FUpdatesPerHour: TEdit;
    FUserConnections: TEdit;
    GBasics: TGroupBox_Ext;
    GLimits: TGroupBox_Ext;
    msCopy: TMenuItem;
    MSource: TPopupMenu;
    msSelectAll: TMenuItem;
    N1: TMenuItem;
    PageControl: TPageControl;
    PSQLWait: TPanel;
    TSBasics: TTabSheet;
    TSLimits: TTabSheet;
    TSRights: TTabSheet;
    TSSource: TTabSheet;
    procedure FBHelpClick(Sender: TObject);
    procedure FBOkCheckEnabled(Sender: TObject);
    procedure FBRightsDeleteClick(Sender: TObject);
    procedure FBRightsEditClick(Sender: TObject);
    procedure FBRightsNewClick(Sender: TObject);
    procedure FHostExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FRightsDblClick(Sender: TObject);
    procedure FRightsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListViewCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure ListViewResize(Sender: TObject);
    procedure TSRightsShow(Sender: TObject);
  private
    NewUser: TSUser;
    RightsModified: Boolean;
    SessionState: (ssCreate, ssInit, ssValid, ssAlter);
    procedure Built();
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure FRightsRefresh(Sender: TObject);
    procedure ListViewShowSortDirection(const ListView: TListView);
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
  public
    Session: TSSession;
    User: TSUser;
    function Execute(): Boolean;
  end;

function DUser(): TDUser;

implementation {***************************************************************}

{$R *.dfm}

uses
  CommCtrl,
  Math, StrUtils, SysConst,
  SQLUtils, MySQLDB,
  uPreferences,
  uDUserRight;

var
  FDUser: TDUser;

function DUser(): TDUser;
begin
  if (not Assigned(FDUser)) then
  begin
    Application.CreateForm(TDUser, FDUser);
    FDUser.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDUser;
end;

{ TDUser **********************************************************************}

procedure TDUser.Built();
begin
  NewUser.Assign(User);

  FName.Text := NewUser.Login;
  FHost.Text := NewUser.Host;
  if (NewUser.RawPassword = '') then
    FPassword.Text := ''
  else
    FPassword.Text := StringOfChar('*', FPassword.MaxLength);

  FRightsRefresh(nil);

  FUDConnectionsPerHour.Position := NewUser.ConnectionsPerHour;
  FUDQueriesPerHour.Position := NewUser.QueriesPerHour;
  FUDUpdatesPerHour.Position := NewUser.UpdatesPerHour;
  FUDUserConnections.Position := NewUser.UserConnections;

  FSource.Text := User.Source;
end;

function TDUser.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDUser.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDUser.FBOkCheckEnabled(Sender: TObject);
var
  Username: string;
begin
  Username := Trim(FName.Text);
  if (Trim(FHost.Text) <> '') then
    Username := Username + '@' + Trim(FHost.Text);

  FBOk.Enabled := (not Assigned(Session.UserByName(Username)) or (Session.Users.NameCmp(Username, NewUser.Name) = 0))
    and (FRights.Items.Count > 0);
end;

procedure TDUser.FBRightsDeleteClick(Sender: TObject);
begin
  NewUser.DeleteRight(FRights.Selected.Data);
  FRights.DeleteSelected();

  FRightsSelectItem(FRights, nil, False);
  FBOkCheckEnabled(Sender);
end;

procedure TDUser.FBRightsEditClick(Sender: TObject);
begin
  DUserRight.Session := Session;
  DUserRight.User := NewUser;
  DUserRight.UserRight := FRights.Selected.Data;
  if (DUserRight.Execute()) then
  begin
    FRightsRefresh(Sender);

    FBOkCheckEnabled(Sender);
  end;
  ActiveControl := FRights;
end;

procedure TDUser.FBRightsNewClick(Sender: TObject);
begin
  DUserRight.Session := Session;
  DUserRight.User := NewUser;
  DUserRight.UserRight := nil;
  if (DUserRight.Execute()) then
  begin
    FRightsRefresh(Sender);

    FBOkCheckEnabled(Sender);
  end;

  ActiveControl := FRights;
end;

procedure TDUser.FHostExit(Sender: TObject);
begin
  if (Trim(FHost.Text) = '') then
    FHost.Text := '%';
end;

procedure TDUser.FormSessionEvent(const Event: TSSession.TEvent);
var
  FirstValid: Boolean;
begin
  FirstValid := SessionState = ssInit;

  if ((SessionState = ssInit) and (Event.EventType = etError)) then
    ModalResult := mrCancel
  else if ((SessionState in [ssInit]) and (Event.EventType = etItemValid) and (Event.Item = User)) then
  begin
    Built();
    SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType = etError)) then
  begin
    if (not Assigned(User)) then
      SessionState := ssCreate
    else
      SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType in [etItemValid, etItemCreated, etItemRenamed])) then
    ModalResult := mrOk;

  if (SessionState in [ssCreate, ssValid]) then
  begin
    if (not PageControl.Visible) then
    begin
      PageControl.Visible := True;
      PSQLWait.Visible := not PageControl.Visible;
      FBOkCheckEnabled(nil);

      if (FirstValid) then
        if (not Assigned(Event)) then
          ActiveControl := FName;
    end;
  end;
end;

procedure TDUser.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  I: Integer;
begin
  if ((ModalResult = mrOk) and PageControl.Visible) then
  begin
    if (Trim(FHost.Text) = '') then
      NewUser.Name := Trim(FName.Text)
    else
      NewUser.Name := Trim(FName.Text) + '@' + Trim(FHost.Text);
    if (FPassword.Text <> StringOfChar('*', FPassword.MaxLength)) then
      NewUser.NewPassword := Trim(FPassword.Text)
    else
      NewUser.NewPassword := NewUser.RawPassword;
    NewUser.ConnectionsPerHour := FUDConnectionsPerHour.Position;
    NewUser.QueriesPerHour := FUDQueriesPerHour.Position;
    NewUser.UpdatesPerHour := FUDUpdatesPerHour.Position;
    NewUser.UserConnections := FUDUserConnections.Position;
    for I := 0 to NewUser.RightCount - 1 do
      NewUser.Rights[I].NewPassword := NewUser.NewPassword;

    SessionState := ssAlter;
    if (not Assigned(User)) then
      CanClose := Session.AddUser(NewUser)
    else
      CanClose := Session.UpdateUser(User, NewUser);

    PageControl.Visible := False;
    PSQLWait.Visible := not PageControl.Visible;
    FBOk.Enabled := False;
  end;
end;

procedure TDUser.FormCreate(Sender: TObject);
begin
  NewUser := nil;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  FRights.SmallImages := Preferences.Images;

  FSource.Highlighter.LoadFromResource('Highlighter', RT_RCDATA);
  FSource.Highlighter.Colors.LoadFromResource('Colors', RT_RCDATA);

  PageControl.ActivePage := TSBasics;
end;

procedure TDUser.FormHide(Sender: TObject);
begin
  Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.User.Width := Width;
  Preferences.User.Height := Height;

  FRights.Items.BeginUpdate();
  FRights.Items.Clear();
  FRights.Items.EndUpdate();
  FSource.Lines.Clear();

  if (Assigned(NewUser)) then
    FreeAndNil(NewUser);

  PageControl.ActivePage := TSBasics;
end;

procedure TDUser.FormShow(Sender: TObject);
var
  UserName: string;
begin
  Session.RegisterEventProc(FormSessionEvent);

  if ((Preferences.User.Width >= Width) and (Preferences.User.Height >= Height)) then
  begin
    Width := Preferences.User.Width;
    Height := Preferences.User.Height;
  end;

  FSource.Lines.Clear();
  Session.ApplyToBCEditor(FSource);

  NewUser := TSUser.Create(Session.Users);

  RightsModified := False;
  if (not Assigned(User)) then
  begin
    Caption := Preferences.LoadStr(286);
    HelpContext := 1077;
  end
  else
  begin
    Caption := Preferences.LoadStr(842, User.Caption);
    HelpContext := 1059;
  end;

  FBRightsEdit.Enabled := False;

  FUserConnections.Visible := Session.Connection.MySQLVersion >= 50003;
  FLUserConnections.Visible := FUserConnections.Visible;
  FUDUserConnections.Visible := FUserConnections.Visible;

  TSSource.TabVisible := Assigned(User);

  if (not Assigned(User)) then
    SessionState := ssCreate
  else if (not User.Valid and not User.Update()) then
    SessionState := ssInit
  else
    SessionState := ssValid;

  if (not Assigned(User)) then
  begin
    FName.Text := Preferences.LoadStr(280);
    while (Assigned(Session.UserByCaption(FName.Text))) do
    begin
      UserName := FName.Text;
      Delete(UserName, 1, Length(Preferences.LoadStr(280)));
      if (UserName = '') then UserName := '1';
      UserName := Preferences.LoadStr(280) + IntToStr(StrToInt(UserName) + 1);
      FName.Text := UserName;
    end;

    FHost.Text := '%';
    FPassword.Text := '';

    FRightsRefresh(nil);

    FUDConnectionsPerHour.Position := 0;
    FUDQueriesPerHour.Position := 0;
    FUDUpdatesPerHour.Position := 0;
    FUDUserConnections.Position := 0;
  end
  else
  begin
    if (SessionState = ssValid) then
      Built();
  end;

  PageControl.Visible := SessionState in [ssCreate, ssValid];
  PSQLWait.Visible := not PageControl.Visible;

  ActiveControl := FBCancel;
  if (PageControl.Visible) then
    ActiveControl := FName;

  PostMessage(Self.Handle, UM_POST_SHOW, 0, 0);
end;

procedure TDUser.FRightsDblClick(Sender: TObject);
begin
  if (Assigned(FRights.Selected)) then
    FBRightsEdit.Click();
end;

procedure TDUser.FRightsRefresh(Sender: TObject);
var
  I: Integer;
  Item: TListItem;
begin
  FRights.Clear();

  for I := 0 to NewUser.RightCount - 1 do
  begin
    Item := FRights.Items.Add();
    Item.Caption := NewUser.Rights[I].Caption;
    if (NewUser.Rights[I].FieldName <> '') then
      Item.ImageIndex := iiBaseField
    else if (NewUser.Rights[I].TableName <> '') then
      Item.ImageIndex := iiBaseTable
    else if (NewUser.Rights[I].ProcedureName <> '') then
      Item.ImageIndex := iiProcedure
    else if (NewUser.Rights[I].FunctionName <> '') then
      Item.ImageIndex := iiFunction
    else if (NewUser.Rights[I].DatabaseName <> '') then
      Item.ImageIndex := iiDatabase
    else
      Item.ImageIndex := iiServer;
    Item.Data := NewUser.Rights[I];
  end;

  if (FRights.Items.Count > 0) then
    FRights.Selected := FRights.Items[0];

  FRightsSelectItem(FRights, FRights.Selected, Assigned(FRights.Selected) and FRights.Selected.Selected);
end;

procedure TDUser.FRightsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  I: Integer;
  RGrant: Boolean;
begin
  RGrant := not Assigned(Session.User);
  if (Assigned(Session.User)) then
    for I := 0 to Session.User.RightCount - 1 do
      RGrant := RGrant or Session.User.Rights[I].RGrant;

  FBRightsNew.Enabled := RGrant;
  FBRightsEdit.Enabled := Selected;
  FBRightsDelete.Enabled := Selected and (FRights.Items.Count > 1) and RGrant;
end;

procedure TDUser.ListViewColumnClick(Sender: TObject;
  Column: TListColumn);
var
  I: Integer;
  ListView: TListView;
begin
  if (Sender is TListView) then
  begin
    ListView := TListView(Sender);

    for I := 0 to ListView.Columns.Count - 1 do
      if (ListView.Column[I] <> Column) then
        ListView.Column[I].Tag := 0
      else if (ListView.Column[I].Tag < 0) then
        ListView.Column[I].Tag := 1
      else if (ListView.Column[I].Tag > 0) then
        ListView.Column[I].Tag := -1
      else
        ListView.Column[I].Tag := 1;

    ListView.Tag := Column.Index;
    ListView.AlphaSort();

    ListViewShowSortDirection(ListView);
  end;
end;

procedure TDUser.ListViewCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Column: TListColumn;
  ListView: TListView;
begin
  ListView := TListView(Sender);
  Column := ListView.Column[ListView.Tag];

  if (Column.Index = 0) then
    Compare := Sign(lstrcmpi(PChar(Item1.Caption), PChar(Item2.Caption)))
  else
    Compare := Sign(lstrcmpi(PChar(Item1.SubItems[Column.Index - 1]), PChar(Item2.SubItems[Column.Index - 1])));

  if (Column.Tag < 0) then
    Compare := - Compare;
end;

procedure TDUser.ListViewResize(Sender: TObject);
begin
  if (Sender is TListView) then
    ListViewShowSortDirection(TListView(Sender));
end;

procedure TDUser.ListViewShowSortDirection(const ListView: TListView);
var
  HDItem: THDItem;
  I: Integer;
begin
  HDItem.Mask := HDI_FORMAT;
  for I := 0 to ListView.Columns.Count - 1 do
    if (BOOL(SendMessage(ListView_GetHeader(ListView.Handle), HDM_GETITEM, I, LPARAM(@HDItem)))) then
    begin
      case (ListView.Column[I].Tag) of
        -1: HDItem.fmt := HDItem.fmt and not HDF_SORTUP or HDF_SORTDOWN;
        1: HDItem.fmt := HDItem.fmt and not HDF_SORTDOWN or HDF_SORTUP;
        else HDItem.fmt := HDItem.fmt and not HDF_SORTUP and not HDF_SORTDOWN;
      end;
      SendMessage(ListView_GetHeader(ListView.Handle), HDM_SETITEM, I, LPARAM(@HDItem));
    end;
end;

procedure TDUser.TSRightsShow(Sender: TObject);
begin
  ActiveControl := FRights;
end;

procedure TDUser.UMChangePreferences(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiUser, Icon);

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  TSBasics.Caption := Preferences.LoadStr(108);
  GBasics.Caption := Preferences.LoadStr(85);
  FLName.Caption := Preferences.LoadStr(561) + ':';
  FLHost.Caption := Preferences.LoadStr(289) + ':';
  FLPassword.Caption := Preferences.LoadStr(283) + ':';

  TSRights.Caption := Preferences.LoadStr(284);
  FBRightsNew.Caption := Preferences.LoadStr(26) + '...';
  FBRightsEdit.Caption := Preferences.LoadStr(97) + '...';
  FBRightsDelete.Caption := Preferences.LoadStr(28);

  TSLimits.Caption := Preferences.LoadStr(294);
  GLimits.Caption := Preferences.LoadStr(294);
  FLConnectionsPerHour.Caption := Preferences.LoadStr(292) + ':';
  FLQueriesPerHour.Caption := Preferences.LoadStr(290) + ':';
  FLUpdatesPerHour.Caption := Preferences.LoadStr(291) + ':';
  FLUserConnections.Caption := Preferences.LoadStr(871) + ':';

  TSSource.Caption := Preferences.LoadStr(198);
  Preferences.ApplyToBCEditor(FSource);

  msCopy.Action := aECopy; msCopy.ShortCut := 0;
  msSelectAll.Action := aESelectAll; msSelectAll.ShortCut := 0;

  FBOk.Enabled := False;

  FBHelp.Caption := Preferences.LoadStr(167);
  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDUser := nil;
end.

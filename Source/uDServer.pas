unit uDServer;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, Menus, ExtCtrls,
  BCEditor.Editor, BCEditor.Editor.Base,
  Forms_Ext, StdCtrls_Ext, ExtCtrls_Ext,
  uSession,
  uBase;

type
  TDServer = class (TForm_Ext)
    FBCancel: TButton;
    FBHelp: TButton;
    FCharacterSet: TLabel;
    FComment: TLabel;
    FHost: TLabel;
    FLCharacterSet: TLabel;
    FLComment: TLabel;
    FLHost: TLabel;
    FLibVersion: TLabel;
    FLLibVersion: TLabel;
    FLThreadId: TLabel;
    FLUser: TLabel;
    FLVersion: TLabel;
    FPlugins: TListView;
    FStartup: TBCEditor;
    FThreadId: TLabel;
    FUser: TLabel;
    FVersion: TLabel;
    GConnection: TGroupBox_Ext;
    GServer: TGroupBox_Ext;
    msCopy: TMenuItem;
    msCut: TMenuItem;
    msDelete: TMenuItem;
    MSource: TPopupMenu;
    msPaste: TMenuItem;
    msSelectAll: TMenuItem;
    msUndo: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    PageControl: TPageControl;
    TSBasics: TTabSheet;
    TSPlugins: TTabSheet;
    TSStartup: TTabSheet;
    procedure FBHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListViewColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListViewCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure ListViewDblClick(Sender: TObject);
    procedure ListViewKeyPress(Sender: TObject; var Key: Char);
    procedure ListViewResize(Sender: TObject);
    procedure TSPluginsShow(Sender: TObject);
    procedure TSStartupShow(Sender: TObject);
  private
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure ListViewShowSortDirection(const ListView: TListView);
    function SessionUpdate(): Boolean;
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
    procedure VariableValid(const Variable: TSVariable);
  public
    Session: TSSession;
    Tab: TCustomFrame;
    function Execute(): Boolean;
  end;

function DServer(): TDServer;

implementation {***************************************************************}

{$R *.dfm}

uses
  CommCtrl,
  Math, StrUtils,
  MySQLConsts,
  CommCtrl_Ext,
  MySQLDB, SQLUtils,
  uPreferences,
  uDVariable, uDUser;

var
  FDServer: TDServer;

function DServer(): TDServer;
begin
  if (not Assigned(FDServer)) then
  begin
    Application.CreateForm(TDServer, FDServer);
    FDServer.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDServer;
end;

{TDServer *********************************************************************}

function TDServer.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDServer.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDServer.FormSessionEvent(const Event: TSSession.TEvent);
begin
  if (Event.EventType = etItemsValid) then
  begin
    if (Event.Items = Session.Plugins) then
    begin
      FPlugins.Cursor := crDefault;
      if (Assigned(TSPlugins.OnShow)) then
        TSPlugins.OnShow(nil);
    end;
  end
  else if (Event.EventType = etItemValid) then
    if (Event.Item is TSVariable) then
      VariableValid(TSVariable(Event.Item));

  if (Event.EventType = etAfterExecuteSQL) then
  begin
    FPlugins.Cursor := crDefault;
  end;
end;

procedure TDServer.FormCreate(Sender: TObject);
begin
  Preferences.Images.GetIcon(iiServer, Icon);

  FStartup.Highlighter.LoadFromResource('Highlighter', RT_RCDATA);
  FStartup.Highlighter.Colors.LoadFromResource('Colors', RT_RCDATA);
  FPlugins.SmallImages := Preferences.Images;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  PageControl.ActivePage := TSBasics;
end;

procedure TDServer.FormHide(Sender: TObject);
begin
  Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.Server.Width := Width;
  Preferences.Server.Height := Height;

  FStartup.Lines.Clear();

  FPlugins.DisableAlign(); FPlugins.Items.BeginUpdate();
  FPlugins.Items.Clear();
  FPlugins.EnableAlign(); FPlugins.Items.EndUpdate();
end;

procedure TDServer.FormShow(Sender: TObject);
begin
  Session.RegisterEventProc(FormSessionEvent);

  if ((Preferences.Server.Width >= Width) and (Preferences.Server.Height >= Height)) then
  begin
    Width := Preferences.Server.Width;
    Height := Preferences.Server.Height;
  end;

  FStartup.Lines.Clear();
  Session.ApplyToBCEditor(FStartup);

  Caption := Preferences.LoadStr(842, Session.Caption);

  FHost.Caption := Session.Connection.HostInfo;
  FVersion.Caption := Session.Connection.ServerVersionStr;
  FComment.Visible := Assigned(Session.VariableByName('version_comment'));
  FLComment.Visible := FComment.Visible;
  if (FComment.Visible) then
    FComment.Caption := Session.VariableByName('version_comment').Value;
  if (Session.Connection.LibraryType = MySQLDB.ltDLL) then
    FLibVersion.Caption := Session.Connection.Lib.VersionStr
  else
    FLibVersion.Caption := Preferences.LoadStr(649);
  if (Session.CurrentUser = '') then
    FUser.Caption := '???'
  else
    FUser.Caption := Session.CurrentUser;
  FCharacterSet.Caption := Session.Connection.Charset;
  FThreadId.Visible := Session.Connection.ThreadId > 0;
  FLThreadId.Visible := FThreadId.Visible;
  FThreadId.Caption := IntToStr(Session.Connection.ThreadId);

  FStartup.Lines.Clear();

  TSStartup.TabVisible := Assigned(Session.VariableByName('init_connect')) and (Session.VariableByName('init_connect').Value <> '');
  TSPlugins.TabVisible := Assigned(Session.Plugins);

  PageControl.ActivePage := TSBasics;

  ActiveControl := FBCancel;
end;

procedure TDServer.ListViewColumnClick(Sender: TObject; Column: TListColumn);
var
  I: Integer;
  ListView: TListView;
begin
  if (Sender is TListView) then
  begin
    ListView := TListView(Sender);

    for I := 0 to ListView.Columns.Count - 1 do
      if (ListView.Columns[I] <> Column) then
        ListView.Columns[I].Tag := 0
      else if (ListView.Columns[I].Tag < 0) then
        ListView.Columns[I].Tag := 1
      else if (ListView.Columns[I].Tag > 0) then
        ListView.Columns[I].Tag := -1
      else
        ListView.Columns[I].Tag := 1;

    ListView.Tag := Column.Index;
    ListView.AlphaSort();

    ListViewShowSortDirection(ListView);
  end;
end;

procedure TDServer.ListViewCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
var
  Column: TListColumn;
  ListView: TListView;
begin
  ListView := TListView(Sender);
  Column := ListView.Columns[ListView.Tag];

  if (Column.Index = 0) then
    Compare := Sign(lstrcmpi(PChar(Item1.Caption), PChar(Item2.Caption)))
  else
    Compare := Sign(lstrcmpi(PChar(Item1.SubItems[Column.Index - 1]), PChar(Item2.SubItems[Column.Index - 1])));

  if (Column.Tag < 0) then
    Compare := - Compare;
end;

procedure TDServer.ListViewDblClick(Sender: TObject);
var
  I: Integer;
  ListView: TListView;
  MenuItem: TMenuItem;
begin
  MenuItem := nil;

  ListView := TListView(Sender);
  if (Assigned(ListView.PopupMenu)) then
    for I := 0 to ListView.PopupMenu.Items.Count - 1 do
      if (ListView.PopupMenu.Items.Items[I].Default) and (ListView.PopupMenu.Items.Items[I].Enabled) then
        MenuItem := ListView.PopupMenu.Items.Items[I];
  if (Assigned(MenuItem) and Assigned(ListView.Selected)) then MenuItem.Click();
end;

procedure TDServer.ListViewKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
    ListViewDblClick(Sender);
end;

procedure TDServer.ListViewResize(Sender: TObject);
begin
  if (Sender is TListView) then
    ListViewShowSortDirection(TListView(Sender));
end;

procedure TDServer.ListViewShowSortDirection(const ListView: TListView);
var
  Column: TListColumn;
  HDItem: THDItem;
  I: Integer;
begin
  Column := ListView.Columns[ListView.Tag];

  HDItem.Mask := HDI_FORMAT;
  for I := 0 to ListView.Columns.Count - 1 do
    if (BOOL(SendMessage(ListView_GetHeader(ListView.Handle), HDM_GETITEM, I, LParam(@HDItem)))) then
    begin
      case (ListView.Columns[I].Tag) of
        -1: HDItem.fmt := HDItem.fmt and not HDF_SORTUP or HDF_SORTDOWN;
        1: HDItem.fmt := HDItem.fmt and not HDF_SORTDOWN or HDF_SORTUP;
        else HDItem.fmt := HDItem.fmt and not HDF_SORTUP and not HDF_SORTDOWN;
      end;
      SendMessage(ListView_GetHeader(ListView.Handle), HDM_SETITEM, I, LParam(@HDItem));
    end;

  if ((ComCtl32MajorVersion >= 6) and not CheckWin32Version(6, 1)) then
    SendMessage(ListView.Handle, LVM_SETSELECTEDCOLUMN, Column.Index, 0);
end;

function TDServer.SessionUpdate(): Boolean;
var
  List: TList;
begin
  List := TList.Create();
  if (Assigned(Session.Plugins) and not Session.Plugins.Valid) then
  begin
    FPlugins.Cursor := crSQLWait;
    List.Add(Session.Plugins);
  end;
  Result := Session.Update(List);
  List.Free();
end;

procedure TDServer.TSPluginsShow(Sender: TObject);
var
  I: Integer;
  Item: TListItem;
begin
  if (FPlugins.Items.Count = 0) then
    if (Session.Plugins.Valid or SessionUpdate()) then
    begin
      FPlugins.DisableAlign();
      FPlugins.Items.BeginUpdate();

      for I := 0 to Session.Plugins.Count - 1 do
      begin
        Item := FPlugins.Items.Add();
        Item.Caption := Session.Plugins[I].Name;
        Item.ImageIndex := iiPlugin;
        Item.SubItems.Add(Session.Plugins[I].Comment);
      end;
      if (FPlugins.Items.Count = 0) then
        FPlugins.Selected := nil
      else
        FPlugins.Selected := FPlugins.Items[0];
      FPlugins.ItemFocused := FPlugins.Selected;

      FPlugins.Items.EndUpdate();
      FPlugins.EnableAlign();

      FPlugins.Columns[0].Width := FPlugins.ClientWidth div 2;
      FPlugins.Columns[1].Width := FPlugins.ClientWidth - FPlugins.Columns[0].Width;

      FPlugins.Columns[0].Tag := 1;
      FPlugins.Columns[1].Tag := 0;
      ListViewShowSortDirection(FPlugins);
    end;
end;

procedure TDServer.TSStartupShow(Sender: TObject);
begin
  if (FStartup.Lines.Count = 0) then
    FStartup.Text := Trim(Session.VariableByName('init_connect').Value) + #13#10;
end;

procedure TDServer.UMChangePreferences(var Message: TMessage);
begin
  TSBasics.Caption := Preferences.LoadStr(108);
  GServer.Caption := Preferences.LoadStr(906);
  FLVersion.Caption := Preferences.LoadStr(169) + ':';
  FLComment.Caption := Preferences.LoadStr(111) + ':';
  GConnection.Caption := Preferences.LoadStr(486);
  FLHost.Caption := Preferences.LoadStr(305) + ':';
  FLLibVersion.Caption := Preferences.LoadStr(568) + ':';
  FLUser.Caption := Preferences.LoadStr(561) + ':';
  FLCharacterSet.Caption := Preferences.LoadStr(682) + ':';
  FLThreadId.Caption := Preferences.LoadStr(269) + ':';

  TSStartup.Caption := Preferences.LoadStr(805);
  Preferences.ApplyToBCEditor(FStartup);

  TSPlugins.Caption := Preferences.LoadStr(811);
  FPlugins.Columns[0].Caption := Preferences.LoadStr(35);
  FPlugins.Columns[1].Caption := Preferences.LoadStr(111);

  msUndo.Action := MainAction('aEUndo'); msCut.ShortCut := 0;
  msCut.Action := MainAction('aECut'); msCut.ShortCut := 0;
  msCopy.Action := MainAction('aECopy'); msCopy.ShortCut := 0;
  msPaste.Action := MainAction('aEPaste'); msPaste.ShortCut := 0;
  msDelete.Action := MainAction('aEDelete'); msDelete.ShortCut := 0;
  msSelectAll.Action := MainAction('aESelectAll'); msSelectAll.ShortCut := 0;

  FBHelp.Caption := Preferences.LoadStr(167);
  FBCancel.Caption := Preferences.LoadStr(231);
end;

procedure TDServer.VariableValid(const Variable: TSVariable);
begin
end;

initialization
  FDServer := nil;
end.

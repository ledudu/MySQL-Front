unit uDDatabases;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  ODBCAPI,
  Forms_Ext, StdCtrls_Ext,
  uBase, uSession;

type
  TDDatabases = class (TForm_Ext)
    FBCancel: TButton;
    FBOk: TButton;
    FDatabases: TListView;
    GroupBox: TGroupBox_Ext;
    PSQLWait: TPanel;
    procedure FDatabasesDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FDatabasesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
  private
    procedure Built();
    procedure FBOkCheckEnabled(Sender: TObject);
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Session: TSSession;
    SelectedDatabases: string;
    function Execute(): Boolean;
  end;

function DDatabases(): TDDatabases;

implementation {***************************************************************}

{$R *.dfm}

uses
  uTools, uPreferences, CSVUtils;

const
  STR_LEN = 128;

var
  FDDatabases: TDDatabases;

function DDatabases(): TDDatabases;
begin
  if (not Assigned(FDDatabases)) then
  begin
    Application.CreateForm(TDDatabases, FDDatabases);
    FDDatabases.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDDatabases;
end;

{ TDDatabases *****************************************************************}

procedure TDDatabases.Built();
var
  DatabaseNames: TCSVStrings;
  I: Integer;
  Item: TListItem;
  J: Integer;
begin
  for I := 0 to Session.Databases.Count - 1 do
  begin
    if (not (Session.Databases[I] is TSSystemDatabase)) then
    begin
      Item := FDatabases.Items.Add();
      Item.Caption := Session.Databases[I].Name;
      Item.ImageIndex := iiDatabase;
    end;
  end;

  SetLength(DatabaseNames, 0);
  CSVSplitValues(SelectedDatabases, ',', '"', DatabaseNames);
  for I := 0 to Length(DatabaseNames) - 1 do
    for J := 0 to FDatabases.Items.Count - 1 do
      FDatabases.Items[J].Selected := FDatabases.Items[J].Selected
        or (Session.Databases.NameCmp(FDatabases.Items[J].Caption, DatabaseNames[I]) = 0);
  SetLength(DatabaseNames, 0);

  FDatabases.SortType := stText;

  FDatabases.ItemFocused := nil;
  for I := FDatabases.Items.Count - 1 downto 0 do
    if (FDatabases.Items[I].Selected) then
      FDatabases.ItemFocused := FDatabases.Items[I];
  if (not Assigned(FDatabases.ItemFocused) and (FDatabases.Items.Count > 0)) then
    FDatabases.ItemFocused := FDatabases.Items[0];

  GroupBox.Visible := True;
  PSQLWait.Visible := not GroupBox.Visible;
  ActiveControl := FDatabases;
end;

function TDDatabases.Execute(): Boolean;
begin
  // Debug 2017-04-27
  Assert(not Visible);

  Result := ShowModal() = mrOk;
end;

procedure TDDatabases.FBOkCheckEnabled(Sender: TObject);
begin
  FBOk.Enabled := GroupBox.Visible
    and (Assigned(Session) or Assigned(FDatabases.Selected));
end;

procedure TDDatabases.FDatabasesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  FBOkCheckEnabled(Sender);
end;

procedure TDDatabases.FDatabasesDblClick(Sender: TObject);
begin
  FBOk.Click();
end;

procedure TDDatabases.FormSessionEvent(const Event: TSSession.TEvent);
begin
  if ((Event.EventType in [etItemsValid]) and (Event.Items = Session.Databases)) then
    Built();

  if ((Event.EventType = etError) and (ModalResult = mrNone)) then
    ModalResult := mrCancel
  else if (Event.EventType = etAfterExecuteSQL) then
  begin
    GroupBox.Visible := True;
    PSQLWait.Visible := not GroupBox.Visible;
    FBOkCheckEnabled(nil);
  end;
end;

procedure TDDatabases.FormCreate(Sender: TObject);
begin
  FDatabases.SmallImages := Preferences.Images;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;
end;

procedure TDDatabases.FormHide(Sender: TObject);
var
  I: Integer;
begin
  Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.Databases.Width := Width;
  Preferences.Databases.Height := Height;

  if (ModalResult = mrOk) then
  begin
    SelectedDatabases := '';
    for I := 0 to FDatabases.Items.Count - 1 do
      if (FDatabases.Items[I].Selected) then
      begin
        if (SelectedDatabases <> '') then SelectedDatabases := SelectedDatabases + ',';
        SelectedDatabases := SelectedDatabases + CSVEscape(FDatabases.Items[I].Caption);
      end;
  end;

  FDatabases.Items.BeginUpdate();
  FDatabases.Items.Clear();
  FDatabases.Items.EndUpdate();
end;

procedure TDDatabases.FormShow(Sender: TObject);
begin
  Session.RegisterEventProc(FormSessionEvent);

  if ((Preferences.Databases.Width >= Width) and (Preferences.Databases.Height >= Height)) then
  begin
    Width := Preferences.Databases.Width;
    Height := Preferences.Databases.Height;
  end;

  GroupBox.Visible := Session.Databases.Update();
  PSQLWait.Visible := not GroupBox.Visible;

  if (GroupBox.Visible) then
    Built();

  FBOkCheckEnabled(Sender);
  if (not GroupBox.Visible) then
    ActiveControl := FBCancel
  else
    ActiveControl := FDatabases;
end;

procedure TDDatabases.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiServer, Icon);

  Caption := Preferences.LoadStr(264);

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  GroupBox.Caption := Preferences.LoadStr(265) + ':';

  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDDatabases := nil;
end.

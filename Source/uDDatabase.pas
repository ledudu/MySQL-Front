unit uDDatabase;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, Menus, ComCtrls, ExtCtrls,
  Forms_Ext, StdCtrls_Ext,
  BCEditor.Editor,
  uSession, uBase;

type
  TDDatabase = class (TForm_Ext)
    FBCancel: TButton;
    FBCheck: TButton;
    FBFlush: TButton;
    FBHelp: TButton;
    FBOk: TButton;
    FBOptimize: TButton;
    FCollation: TComboBox_Ext;
    FCharset: TComboBox_Ext;
    FChecked: TLabel;
    FCreated: TLabel;
    FDataSize: TLabel;
    FIndexSize: TLabel;
    FLChecked: TLabel;
    FLCollation: TLabel;
    FLCreated: TLabel;
    FLCharset: TLabel;
    FLDataSize: TLabel;
    FLIndexSize: TLabel;
    FLName: TLabel;
    FLUnusedSize: TLabel;
    FLUpdated: TLabel;
    FName: TEdit;
    FSource: TBCEditor;
    FUnusedSize: TLabel;
    FUpdated: TLabel;
    GBasics: TGroupBox_Ext;
    GCheck: TGroupBox_Ext;
    GDates: TGroupBox_Ext;
    GFlush: TGroupBox_Ext;
    GOptimize: TGroupBox_Ext;
    GSize: TGroupBox_Ext;
    msCopy: TMenuItem;
    MSource: TPopupMenu;
    msSelectAll: TMenuItem;
    N1: TMenuItem;
    PageControl: TPageControl;
    PSQLWait: TPanel;
    TSBasics: TTabSheet;
    TSExtras: TTabSheet;
    TSInformation: TTabSheet;
    TSSource: TTabSheet;
    procedure FBCheckClick(Sender: TObject);
    procedure FBFlushClick(Sender: TObject);
    procedure FBHelpClick(Sender: TObject);
    procedure FBOkCheckEnabled(Sender: TObject);
    procedure FBOptimizeClick(Sender: TObject);
    procedure FCharsetChange(Sender: TObject);
    procedure FCharsetExit(Sender: TObject);
    procedure FCollationChange(Sender: TObject);
    procedure FNameChange(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FSourceChange(Sender: TObject);
    procedure TSExtrasShow(Sender: TObject);
    procedure TSInformationShow(Sender: TObject);
    procedure TSSourceShow(Sender: TObject);
  private
    SessionState: (ssCreate, ssInit, ssStatus, ssValid, ssAlter);
    procedure Built();
    procedure BuiltStatus();
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    function GetName(): string;
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
  public
    Session: TSSession;
    Database: TSDatabase;
    function Execute(): Boolean;
    property Name: string read GetName;
  end;

function DDatabase(): TDDatabase;

implementation {***************************************************************}

{$R *.dfm}

uses
  StrUtils,
  uPreferences;

var
  FDDatabase: TDDatabase;

function DDatabase(): TDDatabase;
begin
  if (not Assigned(FDDatabase)) then
  begin
    Application.CreateForm(TDDatabase, FDDatabase);
    FDDatabase.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDDatabase;
end;

{ TDDatabase ******************************************************************}

procedure TDDatabase.Built();
begin
  FName.Text := Database.Name;

  FCharset.ItemIndex := FCharset.Items.IndexOf(Database.Charset); FCharsetChange(nil);
  FCollation.ItemIndex := FCollation.Items.IndexOf(Database.Collation); FCollationChange(nil);

  FSource.Lines.Text := Database.Source;

  TSSource.TabVisible := Database.Source <> '';
end;

procedure TDDatabase.BuiltStatus();
begin
  if (Database.Created = 0) then FCreated.Caption := '???' else FCreated.Caption := SysUtils.DateTimeToStr(Database.Created, LocaleFormatSettings);
  if (Database.Updated = 0) then FUpdated.Caption := '???' else FUpdated.Caption := SysUtils.DateTimeToStr(Database.Updated, LocaleFormatSettings);

  FIndexSize.Caption := SizeToStr(Database.IndexSize);
  FDataSize.Caption := SizeToStr(Database.DataSize);

  FUnusedSize.Caption := SizeToStr(Database.UnusedSize);
  if (Database.Checked = 0) then FChecked.Caption := '???' else FChecked.Caption := SysUtils.DateTimeToStr(Database.Checked, LocaleFormatSettings);
end;

function TDDatabase.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDDatabase.FBCheckClick(Sender: TObject);
var
  I: Integer;
  List: TList;
begin
  List := TList.Create();
  for I := 0 to Database.Tables.Count - 1 do
    if (Database.Tables[I] is TSBaseTable) then
      List.Add(Database.Tables[I]);
  Database.CheckTables(List);
  List.Free();

  FBCheck.Enabled := False;
  ActiveControl := FBCancel;

  FBCancel.Caption := Preferences.LoadStr(231);
end;

procedure TDDatabase.FBFlushClick(Sender: TObject);
var
  I: Integer;
  List: TList;
begin
  List := TList.Create();
  for I := 0 to Database.Tables.Count - 1 do
    if (Database.Tables[I] is TSBaseTable) then
      List.Add(Database.Tables[I]);
  Database.FlushTables(List);
  List.Free();

  FBFlush.Enabled := False;
  ActiveControl := FBCancel;

  FBCancel.Caption := Preferences.LoadStr(231);
end;

procedure TDDatabase.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDDatabase.FBOkCheckEnabled(Sender: TObject);
begin
  FBOk.Enabled := (FName.Text <> '')
    and (not Assigned(Session.DatabaseByName(FName.Text)) or (Assigned(Database) and (((Session.LowerCaseTableNames = 0) and (FName.Text = Database.Name)) or ((Session.LowerCaseTableNames > 0) and ((lstrcmpi(PChar(FName.Text), PChar(Database.Name)) = 0))))));
end;

procedure TDDatabase.FBOptimizeClick(Sender: TObject);
var
  I: Integer;
  List: TList;
begin
  List := TList.Create();
  for I := 0 to Database.Tables.Count - 1 do
    if (Database.Tables[I] is TSBaseTable) then
      List.Add(Database.Tables[I]);
  Database.OptimizeTables(List);
  List.Free();

  FBOptimize.Enabled := False;
  ActiveControl := FBCancel;

  FBCancel.Caption := Preferences.LoadStr(231);
end;

procedure TDDatabase.FCharsetChange(Sender: TObject);
var
  Charset: TSCharset;
  I: Integer;
begin
  Charset := Session.CharsetByName(FCharset.Text);

  FCollation.Items.Clear();
  if (Assigned(Session.Collations)) then
  begin
    for I := 0 to Session.Collations.Count - 1 do
      if (Assigned(Charset) and (Session.Collations[I].Charset = Charset)) then
        FCollation.Items.Add(Session.Collations[I].Name);
    if (Assigned(Charset) and Assigned(Charset.DefaultCollation)) then
      FCollation.ItemIndex := FCollation.Items.IndexOf(Charset.DefaultCollation.Caption);
  end;
  FCollation.Enabled := FCharset.Text <> ''; FLCollation.Enabled := FCollation.Enabled;

  FBOkCheckEnabled(Sender);
  TSSource.TabVisible := False;
end;

procedure TDDatabase.FCharsetExit(Sender: TObject);
begin
  if ((FCharset.Text = '') and Assigned(Database)) then
    FCharset.Text := Database.Charset;
end;

procedure TDDatabase.FCollationChange(Sender: TObject);
begin
  FBOkCheckEnabled(Sender);
  TSSource.TabVisible := False;
end;

procedure TDDatabase.FNameChange(Sender: TObject);
begin
  FBOkCheckEnabled(Sender);
  TSSource.TabVisible := False;
end;

procedure TDDatabase.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  NewHeight := Height;
end;

procedure TDDatabase.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  NewDatabase: TSDatabase;
begin
  if ((ModalResult = mrOk) and PageControl.Visible) then
  begin
    NewDatabase := TSDatabase.Create(Session.Databases);
    if (Assigned(Database)) then
      NewDatabase.Assign(Database);

    NewDatabase.Name := Trim(FName.Text);
    if (not FCharset.Visible) then
      NewDatabase.Charset := ''
    else
      NewDatabase.Charset := FCharset.Text;
    if (not FCollation.Visible) then
      NewDatabase.Collation := ''
    else
      NewDatabase.Collation := FCollation.Text;

    SessionState := ssAlter;

    if (not Assigned(Database) or not Assigned(Session.DatabaseByName(Database.Name))) then
      CanClose := Session.AddDatabase(NewDatabase)
    else
      CanClose := Session.UpdateDatabase(Database, NewDatabase);

    NewDatabase.Free();

    PageControl.Visible := False;
    PSQLWait.Visible := not PageControl.Visible;
    FBOk.Enabled := False;
  end;
end;

procedure TDDatabase.FormCreate(Sender: TObject);
begin
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  FSource.Highlighter.LoadFromResource('Highlighter', RT_RCDATA);
  FSource.Highlighter.Colors.LoadFromResource('Colors', RT_RCDATA);

  PageControl.ActivePage := TSBasics;
end;

procedure TDDatabase.FormHide(Sender: TObject);
begin
  Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.Database.Width := Width;
  Preferences.Database.Height := Height;

  FSource.Lines.Clear();

  PageControl.ActivePage := TSBasics;
end;

procedure TDDatabase.FormSessionEvent(const Event: TSSession.TEvent);
var
  FirstValid: Boolean;
begin
  FirstValid := SessionState = ssInit;

  if ((SessionState = ssInit) and (Event.EventType = etError)) then
    ModalResult := mrCancel
  else if ((SessionState in [ssInit, ssStatus]) and (Event.EventType = etItemValid) and (Event.Item = Database)) then
  begin
    if (SessionState = ssInit) then
      Built()
    else
      BuiltStatus();
    SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType = etError)) then
  begin
    if (not Assigned(Database)) then
      SessionState := ssCreate
    else
      SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType in [etItemValid, etItemCreated, etItemRenamed])) then
    ModalResult := mrOk;

  if (SessionState in [ssCreate, ssValid]) then
  begin
    GDates.Cursor := crDefault;
    FLCreated.Cursor := crDefault;
    FLUpdated.Cursor := crDefault;
    GSize.Cursor := crDefault;
    FLIndexSize.Cursor := crDefault;
    FLDataSize.Cursor := crDefault;

    GOptimize.Cursor := crDefault;
    FLUnusedSize.Cursor := crDefault;
    GCheck.Cursor := crDefault;
    FLChecked.Cursor := crDefault;

    if (not PageControl.Visible) then
    begin
      PageControl.Visible := True;
      PSQLWait.Visible := not PageControl.Visible;
      FBOkCheckEnabled(nil);

      if (FirstValid) then
        if (FName.Enabled) then
          ActiveControl := FName
        else if (FCharset.Visible) then
          ActiveControl := FCharset
        else
          ActiveControl := FBCancel;
    end;
  end;
end;

procedure TDDatabase.FormShow(Sender: TObject);
var
  DatabaseName: string;
  I: Integer;
begin
  Session.RegisterEventProc(FormSessionEvent);

  if ((Preferences.Database.Width >= Width) and (Preferences.Database.Height >= Height)) then
  begin
    Width := Preferences.Database.Width;
    Height := Preferences.Database.Height;
  end;

  if (not Assigned(Database)) then
    Caption := Preferences.LoadStr(147)
  else
    Caption := Preferences.LoadStr(842, Database.Name);

  if (not Assigned(Database)) then
    HelpContext := 1044
  else
    HelpContext := 1095;

  FSource.Lines.Clear();
  Session.ApplyToBCEditor(FSource);

  if (not Assigned(Database) and (Session.LowerCaseTableNames = 1)) then
    FName.CharCase := ecLowerCase
  else
    FName.CharCase := ecNormal;

  FCharset.Items.Clear();
  for I := 0 to Session.Charsets.Count - 1 do
    FCharset.Items.Add(Session.Charsets[I].Name);

  if (not Assigned(Database)) then
    SessionState := ssCreate
  else if (not Database.Valid and not Database.Update()) then
    SessionState := ssInit
  else
    SessionState := ssValid;

  if (not Assigned(Database)) then
  begin
    FName.Text := Preferences.LoadStr(145);
    while (Assigned(Session.DatabaseByName(FName.Text))) do
    begin
      DatabaseName := FName.Text;
      Delete(DatabaseName, 1, Length(Preferences.LoadStr(145)));
      if (DatabaseName = '') then DatabaseName := '1';
      DatabaseName := Preferences.LoadStr(145) + IntToStr(StrToInt(DatabaseName) + 1);
      FName.Text := DatabaseName;
    end;

    FCharset.ItemIndex := FCharset.Items.IndexOf(Session.Charset); FCharsetChange(Sender);

    TSSource.TabVisible := False;
  end
  else
  begin
    if (SessionState = ssValid) then
      Built();
  end;

  FName.SelectAll();

  FName.Enabled := not Assigned(Database) or not Assigned(Session.DatabaseByName(Database.Name));
  FCharset.Visible := Session.Connection.MySQLVersion >= 40101; FLCharset.Visible := FCharset.Visible;
  FCollation.Visible := Session.Connection.MySQLVersion >= 40101; FLCollation.Visible := FCollation.Visible;

  FBOptimize.Enabled := True;
  FBCheck.Enabled := True;
  FBFlush.Enabled := True;

  TSInformation.TabVisible := Assigned(Database);
  TSExtras.TabVisible := Assigned(Database);

  PageControl.Visible := SessionState in [ssCreate, ssValid];
  PSQLWait.Visible := not PageControl.Visible;

  FBOk.Enabled := PageControl.Visible and not Assigned(Database);

  ActiveControl := FBCancel;
  if (PageControl.Visible) then
    if (FName.Enabled) then
      ActiveControl := FName
    else if (FCharset.Visible) then
      ActiveControl := FCharset;
end;

procedure TDDatabase.FSourceChange(Sender: TObject);
begin
  MainAction('aECopyToFile').Enabled := FSource.SelText <> '';
end;

function TDDatabase.GetName(): string;
begin
  Result := FName.Text;
end;

procedure TDDatabase.TSExtrasShow(Sender: TObject);
begin
  if (not Database.Update(True)) then
  begin
    SessionState := ssStatus;

    GOptimize.Cursor := crSQLWait;
    FLUnusedSize.Cursor := crSQLWait;
    FUnusedSize.Caption := '';
    GCheck.Cursor := crSQLWait;
    FLChecked.Cursor := crSQLWait;
    FChecked.Caption := '';
  end
  else
    BuiltStatus();
end;

procedure TDDatabase.TSInformationShow(Sender: TObject);
begin
  if (not Database.Update(True)) then
  begin
    SessionState := ssStatus;

    GDates.Cursor := crSQLWait;
    FLCreated.Cursor := crSQLWait;
    FCreated.Caption := '';
    FLUpdated.Cursor := crSQLWait;
    FUpdated.Caption := '';
    GSize.Cursor := crSQLWait;
    FLIndexSize.Cursor := crSQLWait;
    FIndexSize.Caption := '';
    FLDataSize.Cursor := crSQLWait;
    FDataSize.Caption := '';
  end
  else
    BuiltStatus();
end;

procedure TDDatabase.TSSourceShow(Sender: TObject);
begin
  if (FSource.Lines.Count = 0) then
    FSource.Lines.Text := Database.Source + #13#10;
end;

procedure TDDatabase.UMChangePreferences(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiDatabase, Icon);

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  TSBasics.Caption := Preferences.LoadStr(108);
  GBasics.Caption := Preferences.LoadStr(85);
  FLName.Caption := Preferences.LoadStr(35) + ':';
  FLCharset.Caption := Preferences.LoadStr(682) + ':';
  FLCollation.Caption := Preferences.LoadStr(702) + ':';

  TSInformation.Caption := Preferences.LoadStr(121);
  GDates.Caption := Preferences.LoadStr(122);
  FLCreated.Caption := Preferences.LoadStr(118) + ':';
  FLUpdated.Caption := Preferences.LoadStr(119) + ':';
  GSize.Caption := Preferences.LoadStr(125);
  FLIndexSize.Caption := Preferences.LoadStr(163) + ':';
  FLDataSize.Caption := Preferences.LoadStr(127) + ':';

  TSExtras.Caption := Preferences.LoadStr(73);
  GOptimize.Caption := Preferences.LoadStr(171);
  FLUnusedSize.Caption := Preferences.LoadStr(128) + ':';
  FBOptimize.Caption := Preferences.LoadStr(130);
  GCheck.Caption := Preferences.LoadStr(172);
  FLChecked.Caption := Preferences.LoadStr(120) + ':';
  FBCheck.Caption := Preferences.LoadStr(131);
  GFlush.Caption := Preferences.LoadStr(328);
  FBFlush.Caption := Preferences.LoadStr(329);

  TSSource.Caption := Preferences.LoadStr(198);
  Preferences.ApplyToBCEditor(FSource);

  msCopy.Action := MainAction('aECopy');
  msSelectAll.Action := MainAction('aESelectAll'); msSelectAll.ShortCut := 0;

  FBHelp.Caption := Preferences.LoadStr(167);
  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDDatabase := nil;
end.

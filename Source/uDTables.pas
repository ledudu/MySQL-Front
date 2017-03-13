unit uDTables;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, ComCtrls, Menus, StdCtrls, ToolWin, ActnList, ExtCtrls,
  BCEditor.Editor,
  StdCtrls_Ext, Forms_Ext, ExtCtrls_Ext, ComCtrls_Ext,
  MySQLDB,
  uSession,
  uBase, BCEditor.Highlighter;

type
  TDTables = class (TForm_Ext)
    FBCancel: TButton;
    FBCheck: TButton;
    FBFlush: TButton;
    FBHelp: TButton;
    FBOk: TButton;
    FBOptimize: TButton;
    FChecked: TLabel;
    FCollation: TComboBox_Ext;
    FCreated: TLabel;
    FDatabase: TEdit;
    FDataSize: TLabel;
    FDefaultCharset: TComboBox_Ext;
    FEngine: TComboBox_Ext;
    FIndexSize: TLabel;
    FLChecked: TLabel;
    FLCollation: TLabel;
    FLCreated: TLabel;
    FLDatabase: TLabel;
    FLDataSize: TLabel;
    FLDefaultCharset: TLabel;
    FLEngine: TLabel;
    FLIndexSize: TLabel;
    FLRecordCount: TLabel;
    FLRowType: TLabel;
    FLTablesCount: TLabel;
    FLUnusedSize: TLabel;
    FLUpdated: TLabel;
    FRecordCount: TLabel;
    FRowType: TComboBox_Ext;
    FSource: TBCEditor;
    FTablesCount: TLabel;
    FUnusedSize: TLabel;
    FUpdated: TLabel;
    GBasics: TGroupBox_Ext;
    GCheck: TGroupBox_Ext;
    GDates: TGroupBox_Ext;
    GFlush: TGroupBox_Ext;
    GOptimize: TGroupBox_Ext;
    GRecordCount: TGroupBox_Ext;
    GRecords: TGroupBox_Ext;
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
    procedure FDefaultCharsetChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure msCopyClick(Sender: TObject);
    procedure TSExtrasShow(Sender: TObject);
    procedure TSInformationShow(Sender: TObject);
    procedure TSSourceShow(Sender: TObject);
  private
    Database: TSDatabase;
    RecordCount: Integer;
    WaitingForClose: Boolean;
    procedure Built();
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
  public
    Tables: TList;
    function Execute(): Boolean;
  end;

function DTables(): TDTables;

implementation {***************************************************************}

{$R *.dfm}

uses
  StrUtils,
  Clipbrd,
  SQLUtils,
  uPreferences;

var
  FDTables: TDTables;

function DTables(): TDTables;
begin
  if (not Assigned(FDTables)) then
  begin
    Application.CreateForm(TDTables, FDTables);
    FDTables.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDTables;
end;

{ TDTables *********************************************************************}

procedure TDTables.Built();
var
  I: Integer;
begin
  FTablesCount.Caption := IntToStr(Tables.Count);
  FDatabase.Text := Database.Name;

  FEngine.ItemIndex := FEngine.Items.IndexOf(TSBaseTable(Tables[0]).Engine.Name);
  for I := 1 to Tables.Count - 1 do
    if (FEngine.Items.IndexOf(TSBaseTable(Tables[I]).Engine.Name) <> FEngine.ItemIndex) then
      FEngine.ItemIndex := 0;

  FDefaultCharset.ItemIndex := FDefaultCharset.Items.IndexOf(TSBaseTable(Tables[0]).Charset);
  for I := 1 to Tables.Count - 1 do
    if (FDefaultCharset.Items.IndexOf(TSBaseTable(Tables[I]).Charset) <> FDefaultCharset.ItemIndex) then
      FDefaultCharset.ItemIndex := 0;
  FDefaultCharsetChange(nil);

  FCollation.ItemIndex := FCollation.Items.IndexOf(TSBaseTable(Tables[0]).Collation);
  for I := 1 to Tables.Count - 1 do
    if (FCollation.Items.IndexOf(TSBaseTable(Tables[I]).Collation) <> FCollation.ItemIndex) then
      FCollation.ItemIndex := 0;

  FRowType.ItemIndex := FRowType.Items.IndexOf(TSBaseTable(Tables[0]).DBRowTypeStr());
  for I := 1 to Tables.Count - 1 do
    if (FRowType.Items.IndexOf(TSBaseTable(Tables[I]).DBRowTypeStr()) <> FRowType.ItemIndex) then
      FRowType.ItemIndex := 0;
end;

function TDTables.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDTables.FBCheckClick(Sender: TObject);
begin
  Database.CheckTables(Tables);

  FBCheck.Enabled := False;
  ActiveControl := FBCancel;

  FBCancel.Caption := Preferences.LoadStr(231);
end;

procedure TDTables.FBFlushClick(Sender: TObject);
begin
  Database.FlushTables(Tables);

  FBFlush.Enabled := False;
  ActiveControl := FBCancel;

  FBCancel.Caption := Preferences.LoadStr(231);
end;

procedure TDTables.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDTables.FBOkCheckEnabled(Sender: TObject);
begin
  FBOk.Enabled := PageControl.Visible;
end;

procedure TDTables.FBOptimizeClick(Sender: TObject);
begin
  Database.OptimizeTables(Tables);

  FBOptimize.Enabled := False;
  ActiveControl := FBCancel;

  FBCancel.Caption := Preferences.LoadStr(231);
end;

procedure TDTables.FDefaultCharsetChange(Sender: TObject);
var
  DefaultCharset: TSCharset;
  I: Integer;
begin
  DefaultCharset := Database.Session.CharsetByName(FDefaultCharset.Text);

  FCollation.Items.Clear();
  if (Assigned(Database.Session.Collations)) then
  begin
    for I := 0 to Database.Session.Collations.Count - 1 do
      if (Assigned(DefaultCharset) and (Database.Session.Collations[I].Charset = DefaultCharset)) then
        FCollation.Items.Add(Database.Session.Collations[I].Name);
    if (Assigned(DefaultCharset)) then
      FCollation.ItemIndex := FCollation.Items.IndexOf(DefaultCharset.DefaultCollation.Caption);
  end;
  FCollation.Enabled := Assigned(DefaultCharset); FLCollation.Enabled := FCollation.Enabled;
end;

procedure TDTables.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  I: Integer;
  UpdateTableNames: TStringList;
begin
  if ((ModalResult = mrOk) and PageControl.Visible) then
  begin
    UpdateTableNames := TStringList.Create();
    for I := 0 to Tables.Count - 1 do
      UpdateTableNames.Add(TSBaseTable(Tables[I]).Name);

    CanClose := Database.UpdateBaseTables(UpdateTableNames, FDefaultCharset.Text, FCollation.Text, FEngine.Text, TSTableField.TRowType(FRowType.ItemIndex));

    UpdateTableNames.Free();

    if (not CanClose) then
    begin
      PageControl.Visible := CanClose;
      PSQLWait.Visible := not PageControl.Visible;

      WaitingForClose := True;
    end;

    FBOk.Enabled := False;
  end;
end;

procedure TDTables.FormCreate(Sender: TObject);
begin
  Tables := nil;

  FSource.Highlighter.LoadFromResource('Highlighter', RT_RCDATA);
  FSource.Highlighter.Colors.LoadFromResource('Colors', RT_RCDATA);

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  if ((Preferences.Table.Width >= Width) and (Preferences.Table.Height >= Height)) then
  begin
    Width := Preferences.Table.Width;
    Height := Preferences.Table.Height;
  end;

  PageControl.ActivePage := TSBasics;
end;

procedure TDTables.FormHide(Sender: TObject);
begin
  Database.Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.Table.Width := Width;
  Preferences.Table.Height := Height;

  PageControl.ActivePage := TSBasics;

  FSource.Lines.Clear();

  Database := nil;
  RecordCount := -1;
end;

procedure TDTables.FormSessionEvent(const Event: TSSession.TEvent);
var
  I: Integer;
  Valid: Boolean;
begin
  if ((Event.EventType = etItemValid) and (Event.Items = Database.Tables)) then
  begin
    Valid := True;
    for I := 0 to Tables.Count - 1 do
      Valid := Valid and TSTable(Tables[I]).Valid;
    if (Valid) then
      Built();
  end;

  if (Event.EventType = etAfterExecuteSQL) then
  begin
    if (WaitingForClose and (Event.Session.Connection.ErrorCode = 0)) then
      ModalResult := mrOK
    else if (not PageControl.Visible and (ModalResult = mrNone)) then
    begin
      PageControl.Visible := True;
      PSQLWait.Visible := not PageControl.Visible;

      if (ActiveControl = FBCancel) then
      begin
        FBOkCheckEnabled(nil);
        ActiveControl := FEngine;
      end;
    end;
  end;
end;

procedure TDTables.FormShow(Sender: TObject);
var
  I: Integer;
begin
  Database := TSTable(Tables[0]).Database;

  Database.Session.RegisterEventProc(FormSessionEvent);

  HelpContext := 1054;

  RecordCount := -1;
  WaitingForClose := False;

  FSource.Lines.Clear();
  Database.Session.ApplyToBCEditor(FSource);

  FTablesCount.Caption := IntToStr(Tables.Count);

  FEngine.Items.Clear();
  for I := 0 to Database.Session.Engines.Count - 1 do
    FEngine.Items.Add(Database.Session.Engines[I].Name);

  FDefaultCharset.Items.Clear();
  for I := 0 to Database.Session.Charsets.Count - 1 do
    FDefaultCharset.Items.Add(Database.Session.Charsets[I].Name);
  FDefaultCharset.ItemIndex := -1; FDefaultCharsetChange(Sender);

  FCollation.Text := '';

  FDefaultCharset.Items.Text := FDefaultCharset.Items.Text;
  FDefaultCharset.Text := ''; FDefaultCharsetChange(Sender);
  FCollation.Text := '';


  FBOptimize.Enabled := True;
  FBCheck.Enabled := True;
  FBFlush.Enabled := True;

  PageControl.Visible := Database.Session.Update(Tables);
  PSQLWait.Visible := not PageControl.Visible;
  if (PageControl.Visible) then
    Built();

  FDefaultCharset.Visible := Database.Session.Connection.MySQLVersion >= 40101; FLDefaultCharset.Visible := FDefaultCharset.Visible;
  FCollation.Visible := Database.Session.Connection.MySQLVersion >= 40101; FLCollation.Visible := FCollation.Visible;
  FDefaultCharset.Visible := Database.Session.Connection.MySQLVersion >= 40101; FLDefaultCharset.Visible := FDefaultCharset.Visible;
  FCollation.Visible := Database.Session.Connection.MySQLVersion >= 40101; FLCollation.Visible := FCollation.Visible;

  FBOk.Enabled := PageControl.Visible;
  FBCancel.Caption := Preferences.LoadStr(30);

  if (PageControl.Visible) then
    ActiveControl := FEngine
  else
    ActiveControl := FBCancel;
end;

procedure TDTables.FCharsetChange(Sender: TObject);
var
  DefaultCharset: TSCharset;
  I: Integer;
begin
  DefaultCharset := Database.Session.CharsetByName(FDefaultCharset.Text);

  FCollation.Items.Clear();
  if (Assigned(Database.Session.Collations)) then
  begin
    for I := 0 to Database.Session.Collations.Count - 1 do
      if (Assigned(DefaultCharset) and (Database.Session.Collations[I].Charset = DefaultCharset)) then
        FCollation.Items.Add(Database.Session.Collations[I].Name);
    if (Assigned(DefaultCharset)) then
      FCollation.ItemIndex := FCollation.Items.IndexOf(DefaultCharset.DefaultCollation.Caption);
  end;
  FCollation.Enabled := Assigned(DefaultCharset); FLCollation.Enabled := FCollation.Enabled;

  FBOkCheckEnabled(Sender);
end;


procedure TDTables.msCopyClick(Sender: TObject);
begin
  FSource.CopyToClipboard();
end;

procedure TDTables.TSExtrasShow(Sender: TObject);
var
  DateTime: TDateTime;
  I: Integer;
  Size: Int64;
begin
  Size := 0;
  for I := 0 to Tables.Count - 1 do
    Inc(Size, TSBaseTable(Tables[I]).UnusedSize);
  FUnusedSize.Caption := SizeToStr(Size);

  DateTime := Now();
  for I := 0 to Tables.Count - 1 do
    if (TSBaseTable(Tables[I]).Checked < DateTime) then
      DateTime := TSBaseTable(Tables[I]).Checked;
  if (DateTime <= 0) then
    FChecked.Caption := '???'
  else
    FChecked.Caption := SysUtils.DateTimeToStr(DateTime, LocaleFormatSettings);
end;

procedure TDTables.TSInformationShow(Sender: TObject);
var
  DateTime: TDateTime;
  I: Integer;
  Size: Int64;
begin
  FCreated.Caption := '???';
  FUpdated.Caption := '???';
  FIndexSize.Caption := '???';
  FDataSize.Caption := '???';
  FRecordCount.Caption := '???';

  DateTime := Now();
  for I := 0 to Tables.Count - 1 do
    if (TSBaseTable(Tables[I]).Created < DateTime) then
      DateTime := TSBaseTable(Tables[I]).Created;
  if (DateTime <= 0) then FCreated.Caption := '???' else FCreated.Caption := SysUtils.DateTimeToStr(DateTime, LocaleFormatSettings);

  DateTime := 0;
  for I := 0 to Tables.Count - 1 do
    if (TSBaseTable(Tables[I]).Updated > DateTime) then
      DateTime := TSBaseTable(Tables[I]).Updated;
  if (DateTime = 0) then FUpdated.Caption := '???' else FUpdated.Caption := SysUtils.DateTimeToStr(DateTime, LocaleFormatSettings);

  Size := 0;
  for I := 0 to Tables.Count - 1 do
    Inc(Size, TSBaseTable(Tables[I]).IndexSize);
  FIndexSize.Caption := SizeToStr(Size);

  Size := 0;
  for I := 0 to Tables.Count - 1 do
    Inc(Size, TSBaseTable(Tables[I]).DataSize);
  FDataSize.Caption := SizeToStr(Size);

  if (RecordCount < 0) then
  begin
    RecordCount := 0;
    for I := 0 to Tables.Count - 1 do
      Inc(RecordCount, TSBaseTable(Tables[I]).RecordCount);
  end;
  FRecordCount.Caption := FormatFloat('#,##0', RecordCount, LocaleFormatSettings);
end;

procedure TDTables.TSSourceShow(Sender: TObject);
var
  I: Integer;
begin
  if (FSource.Lines.Count = 0) then
    for I := 0 to Tables.Count - 1 do
    begin
      if (I > 0) then FSource.Text := FSource.Text + #13#10;
      FSource.Text := FSource.Text + TSBaseTable(Tables[I]).Source;
    end;
end;

procedure TDTables.UMChangePreferences(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiBaseTable, Icon);

  Caption := Preferences.LoadStr(107);

  PSQLWait.Caption := Preferences.LoadStr(882);

  TSBasics.Caption := Preferences.LoadStr(108);
  GBasics.Caption := Preferences.LoadStr(85);
  FLTablesCount.Caption := Preferences.LoadStr(617) + ':';
  FLDatabase.Caption := Preferences.LoadStr(38) + ':';
  FLEngine.Caption := Preferences.LoadStr(110) + ':';
  FLDefaultCharset.Caption := Preferences.LoadStr(682) + ':';
  FLCollation.Caption := Preferences.LoadStr(702) + ':';
  GRecords.Caption := Preferences.LoadStr(124);
  FLRowType.Caption := Preferences.LoadStr(129) + ':';

  TSInformation.Caption := Preferences.LoadStr(121);
  GDates.Caption := Preferences.LoadStr(122);
  FLCreated.Caption := Preferences.LoadStr(118) + ':';
  FLUpdated.Caption := Preferences.LoadStr(119) + ':';
  GSize.Caption := Preferences.LoadStr(125);
  FLIndexSize.Caption := Preferences.LoadStr(163) + ':';
  FLDataSize.Caption := Preferences.LoadStr(127) + ':';
  GRecordCount.Caption := Preferences.LoadStr(170);
  FLRecordCount.Caption := Preferences.LoadStr(116) + ':';

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
end;

initialization
  FDTables := nil;
end.

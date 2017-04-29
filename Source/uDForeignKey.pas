unit uDForeignKey;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls, ExtCtrls,
  StdCtrls_Ext, Forms_Ext,
  uSession,
  uBase;

type
  TDForeignKey = class (TForm_Ext)
    FBCancel: TButton;
    FBHelp: TButton;
    FBOk: TButton;
    FDatabase: TEdit;
    FFields: TListBox;
    FLChild: TLabel;
    FLDatabase: TLabel;
    FLFields: TLabel;
    FLName: TLabel;
    FLOnDelete: TLabel;
    FLOnUpdate: TLabel;
    FLParent: TLabel;
    FLTable: TLabel;
    FName: TEdit;
    FOnDelete: TComboBox_Ext;
    FOnUpdate: TComboBox_Ext;
    FParentDatabase: TComboBox_Ext;
    FParentFields: TListBox;
    FParentTable: TComboBox_Ext;
    FTable: TEdit;
    GAttributes: TGroupBox_Ext;
    GBasics: TGroupBox_Ext;
    PSQLWait: TPanel;
    procedure FBHelpClick(Sender: TObject);
    procedure FBOkCheckEnabled(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FParentDatabaseChange(Sender: TObject);
    procedure FParentTableChange(Sender: TObject);
  private
    SessionState: (ssTable, ssCreate, ssInit, ssValid, ssAlter, ssParentDatabase, ssParentTable);
    Wanted: record
      ComboBox: TComboBox;
    end;
    procedure Built();
    procedure BuiltTable();
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    function GetParentDatabase(): TSDatabase;
    function GetParentTable(): TSBaseTable;
    property SelectedParentDatabase: TSDatabase read GetParentDatabase;
    property SelectedParentTable: TSBaseTable read GetParentTable;
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
    procedure UMPostAfterExecuteSQL(var Message: TMessage); message UM_POST_AFTEREXECUTESQL;
  public
    ForeignKey: TSForeignKey;
    ModifyTableOnly: Boolean;
    ParentTable: TSBaseTable;
    Table: TSBaseTable;
    function Execute(): Boolean;
  end;

function DForeignKey(): TDForeignKey;

implementation {***************************************************************}

{$R *.dfm}

uses
  MySQLDB,
  uPreferences;

var
  FDForeignKey: TDForeignKey;

function DForeignKey(): TDForeignKey;
begin
  if (not Assigned(FDForeignKey)) then
  begin
    Application.CreateForm(TDForeignKey, FDForeignKey);
    FDForeignKey.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDForeignKey;
end;

{ TDForeignKey ****************************************************************}

procedure TDForeignKey.Built();
var
  I: Integer;
  J: Integer;
begin
  FName.Text := ForeignKey.Name;

  for I := 0 to FFields.Items.Count - 1 do
    for J := 0 to Length(ForeignKey.Fields) - 1 do
      if (lstrcmpi(PChar(FFields.Items[I]), PChar(ForeignKey.Fields[J].Name)) = 0) then
        FFields.Selected[I] := True;

  FParentDatabase.ItemIndex := FParentDatabase.Items.IndexOf(ForeignKey.Parent.DatabaseName);
  FParentDatabaseChange(nil);

  FParentTable.ItemIndex := FParentTable.Items.IndexOf(ForeignKey.Parent.TableName);
  FParentTableChange(nil);

  case (ForeignKey.OnDelete) of
    dtRestrict: FOnDelete.ItemIndex := 0;
    dtCascade: FOnDelete.ItemIndex := 1;
    dtSetNull: FOnDelete.ItemIndex := 2;
    dtSetDefault: FOnDelete.ItemIndex := 3;
    dtNoAction: FOnDelete.ItemIndex := 4;
  end;
  case (ForeignKey.OnUpdate) of
    utRestrict: FOnUpdate.ItemIndex := 0;
    utCascade: FOnUpdate.ItemIndex := 1;
    utSetNull: FOnUpdate.ItemIndex := 2;
    utSetDefault: FOnUpdate.ItemIndex := 3;
    utNoAction: FOnUpdate.ItemIndex := 4;
  end;
end;

procedure TDForeignKey.BuiltTable();
var
  I: Integer;
begin
  FFields.Items.BeginUpdate();
  for I := 0 to Table.Fields.Count - 1 do
    FFields.Items.Add(Table.Fields[I].Name);
  FFields.Items.EndUpdate();
end;

function TDForeignKey.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDForeignKey.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDForeignKey.FBOkCheckEnabled(Sender: TObject);
begin
  FBOk.Enabled := (FFields.SelCount > 0) and (FParentTable.Text <> '') and (FParentFields.SelCount > 0)
    and (not Assigned(Table.ForeignKeyByName(FName.Text)) or (Assigned(ForeignKey) and (Table.ForeignKeys.NameCmp(FName.Text, ForeignKey.Name) = 0)));
end;

procedure TDForeignKey.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  I: Integer;
  NewForeignKey: TSForeignKey;
  NewTable: TSBaseTable;
begin
  if ((ModalResult = mrOk) and GBasics.Visible) then
  begin
    if (ModifyTableOnly) then
      NewTable := Table
    else
    begin
      NewTable := TSBaseTable.Create(Table.Tables);
      NewTable.Assign(Table);
    end;

    NewForeignKey := TSForeignKey.Create(nil);
    if (Assigned(ForeignKey)) then
      NewForeignKey.Assign(ForeignKey);

    NewForeignKey.Name := Trim(FName.Text);

    SetLength(NewForeignKey.Fields, 0);
    for I := 0 to FFields.Count - 1 do
      if (FFields.Selected[I]) then
      begin
        SetLength(NewForeignKey.Fields, Length(NewForeignKey.Fields) + 1);
        NewForeignKey.Fields[Length(NewForeignKey.Fields) - 1] := Table.FieldByName(FFields.Items.Strings[I]);
      end;
    NewForeignKey.Parent.DatabaseName := SelectedParentDatabase.Name;
    NewForeignKey.Parent.TableName := SelectedParentTable.Name;
    SetLength(NewForeignKey.Parent.FieldNames, 0);
    for I := 0 to FParentFields.Count - 1 do
      if (FParentFields.Selected[I]) then
      begin
        SetLength(NewForeignKey.Parent.FieldNames, Length(NewForeignKey.Parent.FieldNames) + 1);
        NewForeignKey.Parent.FieldNames[Length(NewForeignKey.Parent.FieldNames) - 1] := FParentFields.Items.Strings[I];
      end;

    NewForeignKey.OnDelete := dtRestrict;
    case (FOnDelete.ItemIndex) of
      0: NewForeignKey.OnDelete := dtRestrict;
      1: NewForeignKey.OnDelete := dtCascade;
      2: NewForeignKey.OnDelete := dtSetNull;
      3: NewForeignKey.OnDelete := dtSetDefault;
      4: NewForeignKey.OnDelete := dtNoAction;
    end;
    case (FOnUpdate.ItemIndex) of
      0: NewForeignKey.OnUpdate := utRestrict;
      1: NewForeignKey.OnUpdate := utCascade;
      2: NewForeignKey.OnUpdate := utSetNull;
      3: NewForeignKey.OnUpdate := utSetDefault;
      4: NewForeignKey.OnUpdate := utNoAction;
    end;

    if (ModifyTableOnly) then
      if (not Assigned(ForeignKey)) then
        Table.ForeignKeys.AddForeignKey(NewForeignKey)
      else
        Table.ForeignKeys[ForeignKey.Index].Assign(NewForeignKey)
    else
      if (not Assigned(ForeignKey)) then
        NewTable.ForeignKeys.AddForeignKey(NewForeignKey)
      else
        NewTable.ForeignKeys[ForeignKey.Index].Assign(NewForeignKey);

    if (not ModifyTableOnly) then
    begin
      SessionState := ssAlter;

      CanClose := Table.Database.UpdateBaseTable(Table, NewTable);

      GBasics.Visible := False;
      GAttributes.Visible := GBasics.Visible;
      PSQLWait.Visible := not GBasics.Visible;
      FBOk.Enabled := False;
    end;

    NewForeignKey.Free();
    if (NewTable <> Table) then
      NewTable.Free();
  end;
end;

procedure TDForeignKey.FormCreate(Sender: TObject);
begin
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;
end;

procedure TDForeignKey.FormHide(Sender: TObject);
begin
  Table.Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.ForeignKey.Width := Width;
  Preferences.ForeignKey.Height := Height;

  FFields.Items.BeginUpdate();
  FFields.Items.Clear();
  FFields.Items.EndUpdate();

  FParentDatabase.Items.BeginUpdate();
  FParentDatabase.Items.Clear();
  FParentDatabase.Items.EndUpdate();

  FParentTable.Items.BeginUpdate();
  FParentTable.Items.Clear();
  FParentTable.Items.EndUpdate();

  FParentFields.Items.BeginUpdate();
  FParentFields.Items.Clear();
  FParentFields.Items.EndUpdate();
end;

procedure TDForeignKey.FormResize(Sender: TObject);
begin
  FDatabase.Width := (GBasics.ClientWidth - FDatabase.Left - FLDatabase.Left) div 2 - FLDatabase.Left;
  FTable.Width := FDatabase.Width;
  FFields.Width := FDatabase.Width;

  FLParent.Left := FDatabase.Left + (GBasics.ClientWidth - FDatabase.Left - FLDatabase.Left) div 2 + FLDatabase.Left;
  FParentDatabase.Left := FLParent.Left;
  FParentTable.Left := FLParent.Left;
  FParentFields.Left := FLParent.Left;
  FParentDatabase.Width := FDatabase.Width;
  FParentTable.Width := FDatabase.Width;
  FParentFields.Width := FDatabase.Width;
end;

procedure TDForeignKey.FormSessionEvent(const Event: TSSession.TEvent);
var
  FirstValid: Boolean;
begin
  FirstValid := SessionState = ssInit;

  if ((SessionState in [ssTable, ssInit]) and (Event.EventType = etItemValid) and (Event.Item = Table)) then
  begin
    BuiltTable();
    if (not Assigned(ForeignKey)) then
      SessionState := ssCreate
    else
    begin
      Built();
      SessionState := ssValid;
    end;
  end
  else if ((SessionState = ssInit) and (Event.EventType = etError)) then
    ModalResult := mrCancel
  else if ((SessionState = ssAlter) and (Event.EventType = etError)) then
  begin
    if (not Assigned(ForeignKey)) then
      SessionState := ssCreate
    else
      SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType in [etItemValid, etItemRenamed]) and (Event.Item = Table)) then
    ModalResult := mrOk;

  if (SessionState in [ssCreate, ssValid]) then
  begin
    if (not GBasics.Visible) then
    begin
      GBasics.Visible := True;
      GAttributes.Visible := GBasics.Visible;
      PSQLWait.Visible := not GBasics.Visible;
      FBOkCheckEnabled(nil);

      if (FirstValid) then
        ActiveControl := FName;
    end;
  end;

  if (Event.EventType = etAfterExecuteSQL) then
    PostMessage(Handle, UM_POST_AFTEREXECUTESQL, 0, 0);
end;

procedure TDForeignKey.FormShow(Sender: TObject);
var
  I: Integer;
begin
  Table.Session.RegisterEventProc(FormSessionEvent);

  if ((Preferences.ForeignKey.Width >= Width) and (Preferences.ForeignKey.Height >= Height)) then
  begin
    Width := Preferences.ForeignKey.Width;
    Height := Preferences.ForeignKey.Height;
  end;

  if (not Assigned(ForeignKey)) then
  begin
    Caption := Preferences.LoadStr(249);
    HelpContext := 1048;
  end
  else
  begin
    Caption := Preferences.LoadStr(842, ForeignKey.Name);
    HelpContext := 1057;
  end;

  Wanted.ComboBox := nil;

  FDatabase.Text := Table.Database.Name;
  FTable.Text := Table.Name;

  FParentDatabase.Clear();
  FParentFields.Clear();
  for I := 0 to Table.Session.Databases.Count - 1 do
    if (not (Table.Session.Databases[I] is TSSystemDatabase)) then
      FParentDatabase.Items.Add(Table.Session.Databases[I].Name);

  FName.Enabled := not Assigned(ForeignKey) or (Table.Database.Session.Connection.MySQLVersion >= 40013);
  FLName.Enabled := not Assigned(ForeignKey) or (Table.Database.Session.Connection.MySQLVersion >= 40013);
  FLTable.Enabled := not Assigned(ForeignKey) or (Table.Database.Session.Connection.MySQLVersion >= 40013);
  FLFields.Enabled := not Assigned(ForeignKey) or (Table.Database.Session.Connection.MySQLVersion >= 40013);
  FLChild.Enabled := not Assigned(ForeignKey) or (Table.Database.Session.Connection.MySQLVersion >= 40013);
  FLParent.Enabled := not Assigned(ForeignKey) or (Table.Database.Session.Connection.MySQLVersion >= 40013);
  FFields.Enabled := not Assigned(ForeignKey) or (Table.Database.Session.Connection.MySQLVersion >= 40013);
  FOnDelete.Enabled := not Assigned(ForeignKey) or (Table.Database.Session.Connection.MySQLVersion >= 40013); FLOnDelete.Enabled := FOnDelete.Enabled;
  FOnUpdate.Enabled := not Assigned(ForeignKey) or (Table.Database.Session.Connection.MySQLVersion >= 40013); FLOnUpdate.Enabled := FOnUpdate.Enabled;

  if (not ModifyTableOnly and not Table.Update()) then
    SessionState := ssTable
  else if (not Assigned(ForeignKey)) then
    SessionState := ssCreate
  else if (not ModifyTableOnly and not Table.ForeignKeys.Valid and not Table.Update()) then
    SessionState := ssInit
  else
    SessionState := ssValid;

  if (SessionState <> ssTable) then
    BuiltTable();

  if (not Assigned(ForeignKey)) then
  begin
    FName.Text := '';

    FParentDatabase.ItemIndex := FParentDatabase.Items.IndexOf(Table.Database.Name);
    FParentDatabaseChange(nil);
    if (not Assigned(ParentTable)) then
      FParentTable.ItemIndex := -1
    else
      FParentTable.ItemIndex := FParentTable.Items.IndexOf(ParentTable.Name);
    FParentTableChange(nil);

    FOnDelete.ItemIndex := 0;
    FOnUpdate.ItemIndex := 0;
  end;

  if (SessionState = ssValid) then
    Built();

  GBasics.Visible := SessionState in [ssCreate, ssValid];
  GAttributes.Visible := GBasics.Visible;
  PSQLWait.Visible := not GBasics.Visible;

  FParentTable.Cursor := crDefault;
  FParentFields.Cursor := crDefault;

  FBOk.Visible := not Assigned(ForeignKey) or (Table.Database.Session.Connection.MySQLVersion >= 40013);
  if (FBOk.Visible) then
    FBCancel.Caption := Preferences.LoadStr(30)
  else
    FBCancel.Caption := Preferences.LoadStr(231);

  FBOk.Enabled := False;
  FBOk.Default := FBOk.Visible;
  FBCancel.Default := not FBOk.Default;

  ActiveControl := FBCancel;
  if (GBasics.Visible) then
    ActiveControl := FName;
end;

procedure TDForeignKey.FParentDatabaseChange(Sender: TObject);
var
  I: Integer;
begin
  Wanted.ComboBox := nil;

  FParentTable.Clear();

  if (not Assigned(SelectedParentDatabase)) then
    // do nothing
  else if (not SelectedParentDatabase.Update()) then
    Wanted.ComboBox := FParentDatabase
  else
  begin
    for I := 0 to SelectedParentDatabase.Tables.Count - 1 do
      if (SelectedParentDatabase.Tables.Table[I] is TSBaseTable) then
        FParentTable.Items.Add(SelectedParentDatabase.Tables.Table[I].Name);

    FParentTable.Enabled := not Assigned(ForeignKey) or (Table.Database.Session.Connection.MySQLVersion >= 40013);
    FBOkCheckEnabled(Sender);
  end;

  if (not Assigned(Wanted.ComboBox)) then
    FParentTable.Cursor := crDefault
  else
  begin
    SessionState := ssParentDatabase;
    FParentTable.Cursor := crSQLWait;
  end;
end;

procedure TDForeignKey.FParentTableChange(Sender: TObject);
var
  I: Integer;
  J: Integer;
begin
  Wanted.ComboBox := nil;

  FParentFields.Clear();

  if (not Assigned(SelectedParentTable)) then
    // do nothing
  else if (Table.Session.Connection.InUse or not SelectedParentTable.Update()) then
    Wanted.ComboBox := FParentTable
  else
  begin
    for I := 0 to SelectedParentTable.Fields.Count - 1 do
      FParentFields.Items.Add(SelectedParentTable.Fields[I].Name);

    if (Assigned(ForeignKey)) then
      for I := 0 to FParentFields.Items.Count - 1 do
        for J := 0 to Length(ForeignKey.Parent.FieldNames) - 1 do
          if (Table.ForeignKeys.NameCmp(FParentFields.Items.Strings[I], ForeignKey.Parent.FieldNames[J]) = 0) then
            FParentFields.Selected[I] := True;

    FParentFields.Enabled := not Assigned(ForeignKey) or (Table.Database.Session.Connection.MySQLVersion >= 40013);
    FBOkCheckEnabled(Sender);
  end;

  if (not Assigned(Wanted.ComboBox)) then
    FParentFields.Cursor := crDefault
  else
  begin
    SessionState := ssParentTable;
    FParentFields.Cursor := crSQLWait;
  end;
end;

function TDForeignKey.GetParentDatabase(): TSDatabase;
begin
  Result := Table.Database.Session.DatabaseByName(FParentDatabase.Text);
end;

function TDForeignKey.GetParentTable(): TSBaseTable;
begin
  if (not Assigned(SelectedParentDatabase)) then
    Result := nil
  else
    Result := SelectedParentDatabase.BaseTableByName(FParentTable.Text);
end;

procedure TDForeignKey.UMChangePreferences(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiForeignKey, Icon);

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  GBasics.Caption := Preferences.LoadStr(85);
  FLName.Caption := Preferences.LoadStr(35) + ':';
  FLDatabase.Caption := Preferences.LoadStr(38) + ':';
  FLTable.Caption := Preferences.LoadStr(302) + ':';
  FLFields.Caption := Preferences.LoadStr(253) + ':';
  FLChild.Caption := Preferences.LoadStr(254) + ':';
  FLParent.Caption := Preferences.LoadStr(263) + ':';

  GAttributes.Caption := Preferences.LoadStr(86);
  FLOnDelete.Caption := Preferences.LoadStr(260) + ' ...';
  FOnDelete.Items.Clear();
  FOnDelete.Items.Add(Preferences.LoadStr(255));
  FOnDelete.Items.Add(Preferences.LoadStr(256));
  FOnDelete.Items.Add(Preferences.LoadStr(257));
  FOnDelete.Items.Add(Preferences.LoadStr(258));
  FOnDelete.Items.Add('<' + Preferences.LoadStr(259) + '>');

  FLOnUpdate.Caption := Preferences.LoadStr(261) + ' ...';
  FOnUpdate.Items.Clear();
  FOnUpdate.Items.Add(Preferences.LoadStr(255));
  FOnUpdate.Items.Add(Preferences.LoadStr(256));
  FOnUpdate.Items.Add(Preferences.LoadStr(257));
  FOnUpdate.Items.Add(Preferences.LoadStr(258));
  FOnUpdate.Items.Add('<' + Preferences.LoadStr(259) + '>');

  FBHelp.Caption := Preferences.LoadStr(167);
  FBOk.Caption := Preferences.LoadStr(29);
end;

procedure TDForeignKey.UMPostAfterExecuteSQL(var Message: TMessage);
begin
  if (Assigned(Wanted.ComboBox) and Assigned(Wanted.ComboBox.OnChange)) then
    Wanted.ComboBox.OnChange(nil);
end;

initialization
  FDForeignKey := nil;
end.


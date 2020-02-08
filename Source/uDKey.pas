unit uDKey;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, Buttons, ComCtrls, StdCtrls, ToolWin, ExtCtrls,
  Forms_Ext, ComCtrls_Ext, StdCtrls_Ext,
  uSession, uPreferences,
  uBase;

type
  TDKey = class (TForm_Ext)
    FAvailableFields: TListView;
    FBCancel: TButton;
    FBHelp: TButton;
    FBOk: TButton;
    FFulltext: TCheckBox;
    FIndexedFields: TListView;
    FLAvailableFields: TLabel;
    FLength: TEdit;
    FLengthUD: TUpDown;
    FLIndexedFields: TLabel;
    FLLength: TLabel;
    FLName: TLabel;
    FName: TEdit;
    FOther: TRadioButton;
    FPrimary: TRadioButton;
    FUnique: TCheckBox;
    GAttributes: TGroupBox_Ext;
    GBasics: TGroupBox_Ext;
    Panel: TPanel;
    PSQLWait: TPanel;
    tbAddAll: TToolButton;
    tbAddOne: TToolButton;
    tbDown: TToolButton;
    tbRemoveAll: TToolButton;
    tbRemoveOne: TToolButton;
    tbUp: TToolButton;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolBar3: TToolBar;
    ToolBar4: TToolBar;
    ToolBar5: TToolBar;
    ToolBar6: TToolBar;
    FLComment: TLabel;
    FComment: TEdit;
    procedure FAvailableFieldsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FAvailableFieldsDeletion(Sender: TObject; Item: TListItem);
    procedure FAvailableFieldsEnter(Sender: TObject);
    procedure FAvailableFieldsExit(Sender: TObject);
    procedure FBHelpClick(Sender: TObject);
    procedure FBOkCheckEnabled(Sender: TObject);
    procedure FFulltextClick(Sender: TObject);
    procedure FIndexedFieldsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FIndexedFieldsDeletion(Sender: TObject; Item: TListItem);
    procedure FIndexedFieldsEnter(Sender: TObject);
    procedure FIndexedFieldsExit(Sender: TObject);
    procedure FLengthExit(Sender: TObject);
    procedure FNameChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FUniqueClick(Sender: TObject);
    procedure IndexTypeChange(Sender: TObject);
    procedure tbAddAllClick(Sender: TObject);
    procedure tbAddOneClick(Sender: TObject);
    procedure tbRemoveAllClick(Sender: TObject);
    procedure tbRemoveOneClick(Sender: TObject);
    procedure tbUpDownClick(Sender: TObject);
  private
    Lengths: array of Integer;
    SessionState: (ssTable, ssCreate, ssInit, ssValid, ssAlter);
    procedure Built();
    procedure BuiltTable();
    procedure CMSysFontChanged(var Message: TMessage); message CM_SYSFONTCHANGED;
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Key: TSKey;
    ModifyTableOnly: Boolean;
    Table: TSBaseTable;
    function Execute(): Boolean;
  end;

function DKey(): TDKey;

implementation {***************************************************************}

{$R *.dfm}

uses
  StrUtils, Math,
  MySQLDB;

var
  FDKey: TDKey;

function DKey(): TDKey;
begin
  if (not Assigned(FDKey)) then
  begin
    Application.CreateForm(TDKey, FDKey);
    FDKey.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDKey;
end;

{ TDIndex *********************************************************************}

procedure TDKey.Built();
var
  Found: Boolean;
  I: Integer;
  Item: TListItem;
  J: Integer;
begin
  FPrimary.Enabled := Key.PrimaryKey or (Table.Keys.Count = 0) or not Table.Keys[0].PrimaryKey;
  FPrimary.Checked := Key.PrimaryKey;
  FOther.Checked := not FPrimary.Checked;
  if (FOther.Checked) then FName.Text := Key.Name else FName.Text := '';

  FIndexedFields.Items.BeginUpdate();
  for I := 0 to Key.Columns.Count - 1 do
  begin
    Item := FIndexedFields.Items.Add();
    Item.Caption := Key.Columns.Column[I].Field.Name;
    Item.Data := Key.Columns.Column[I].Field;
  end;
  FIndexedFields.Selected := FIndexedFields.Items[0];
  FIndexedFields.Items.EndUpdate();

  FComment.Text := Key.Comment;

  FUnique.Checked := Key.Unique;
  FFulltext.Checked := Key.Fulltext;

  FAvailableFields.Items.BeginUpdate();
  FAvailableFields.Items.Clear();
  for I := 0 to Table.Fields.Count - 1 do
  begin
    Found := False;
    if (Assigned(Key)) then
      for J := 0 to Key.Columns.Count - 1 do
        if ((Key.Columns.Column[J].Field = Table.Fields[I])) then
          Found := True;
    if (not Found and ((Table.Fields[I].FieldKind <> mkVirtual) or (Table.Fields[I].Stored = msStored))) then
    begin
      Item := FAvailableFields.Items.Add();
      Item.Caption := Table.Fields[I].Name;
      Item.Data := Table.Fields[I];
    end;
  end;
  FAvailableFields.Items.EndUpdate();
  if (FAvailableFields.Items.Count > 0) then
    FAvailableFields.Items[0].Selected := True;

  FIndexedFieldsChange(nil, nil, ctState);
  IndexTypeChange(nil);
  FIndexedFieldsExit(nil);
  FAvailableFieldsExit(nil);
end;

procedure TDKey.BuiltTable();
var
  I: Integer;
  Item: TListItem;
begin
  for I := 0 to Table.Fields.Count - 1 do
  begin
    Item := FAvailableFields.Items.Add();
    Item.Caption := Table.Fields[I].Name;
    Item.Data := Table.Fields[I];
  end;

  SetLength(Lengths, Table.Fields.Count);
  for I := 0 to Length(Lengths) - 1 do
    if (Table.Fields[I].FieldType in [mfChar, mfVarChar]) then
      Lengths[I] := Table.Fields[I].Size
    else if (Table.Fields[I].FieldType in [mfTinyText, mfText, mfMediumText, mfLongText, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob]) then
      Lengths[I] := 10
    else
      Lengths[I] := 0;
end;

procedure TDKey.CMSysFontChanged(var Message: TMessage);

 procedure Change(const ToolBar: TToolBar);
 begin
  if (Assigned(ToolBar.Images)) then
  begin
    // Recalculate height of Toolbars:
    ToolBar.AutoSize := False;
    ToolBar.ButtonHeight := 0;
    ToolBar.ButtonHeight := Max(ToolBar.Images.Height + 6, ToolBar.Canvas.TextHeight('I') + 10);
    ToolBar.ButtonWidth := ToolBar.Images.Width + 7;
    ToolBar.AutoSize := True;
  end;
 end;

begin
  inherited;

  Change(ToolBar1);
  Change(ToolBar2); ToolBar2.Top := ToolBar1.Top + ToolBar1.Height;
  Change(ToolBar3); ToolBar3.Top := ToolBar2.Top + ToolBar2.Height + 13;
  Change(ToolBar4); ToolBar4.Top := ToolBar3.Top + ToolBar3.Height;
  Change(ToolBar5); ToolBar5.Top := ToolBar4.Top + ToolBar4.Height + 13;
  Change(ToolBar6); ToolBar6.Top := ToolBar5.Top + ToolBar5.Height;
end;

function TDKey.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDKey.FAvailableFieldsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  tbAddAll.Enabled := FAvailableFields.Items.Count > 0;
  tbAddOne.Enabled := Assigned(Item) and Item.Selected;

  FAvailableFields.Enabled := FAvailableFields.Items.Count > 0; FLAvailableFields.Enabled := FAvailableFields.Enabled;
end;

procedure TDKey.FAvailableFieldsDeletion(Sender: TObject; Item: TListItem);
begin
  FAvailableFields.Enabled := FAvailableFields.Items.Count > 1; FLAvailableFields.Enabled := FAvailableFields.Enabled;
  tbAddAll.Enabled := FAvailableFields.Enabled;
end;

procedure TDKey.FAvailableFieldsEnter(Sender: TObject);
begin
  FAvailableFieldsChange(Sender, FAvailableFields.Selected, ctState);
end;

procedure TDKey.FAvailableFieldsExit(Sender: TObject);
begin
  tbAddAll.Enabled := False;
  tbAddOne.Enabled := False;
end;

procedure TDKey.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDKey.FBOkCheckEnabled(Sender: TObject);
var
  I: Integer;
begin
  FBOk.Enabled := (FIndexedFields.Items.Count > 0)
    and (not FLength.Enabled or (FLengthUD.Position > 0));

  if (not Assigned(Key) and Visible) then
    if (FPrimary.Checked or (FName.Text = 'PRIMARY')) then
      FBOk.Enabled := FBOk.Enabled and not Assigned(Table.PrimaryKey)
    else
      for I := 0 to Table.Keys.Count - 1 do
        if (not Table.Keys[I].PrimaryKey and (Table.Keys.NameCmp(Table.Keys[I].Name, FName.Text) = 0)) then
          FBOk.Enabled := False;
end;

procedure TDKey.FFulltextClick(Sender: TObject);
begin
  if (FFulltext.Checked) then
    FUnique.Checked := False;

  FBOkCheckEnabled(Sender);
end;

procedure TDKey.FIndexedFieldsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  Field: TSBaseField;
  I: Integer;
begin
  if (Visible and Assigned(Item) and Assigned(Item.Data)) then
  begin
    IndexTypeChange(Sender);

    FIndexedFields.Enabled := (FIndexedFields.Items.Count > 0);
    FLIndexedFields.Enabled := FIndexedFields.Enabled;

    Field := Table.FieldByName(Item.Caption);

    FLength.Enabled := Field.FieldType in [mfChar, mfVarChar, mfTinyText, mfText, mfMediumText, mfLongText, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob, mfPoint];
    FLLength.Enabled := FLength.Enabled;
    FLengthUD.Enabled := FLength.Enabled;

    if (Field.FieldType in [mfChar, mfVarChar]) then
      FLengthUD.Max := Field.Size
    else
      FLengthUD.Max := 255;

    if (Table.Fields.IndexOf(Field) < Length(Lengths)) then
      FLengthUD.Position := Lengths[Table.Fields.IndexOf(Field)]
    else
      FLengthUD.Position := 0;

    if (FLengthUD.Position = 0) then
      FLength.Text := '';

    FFulltext.Enabled :=
      Table.Engine.IsInnoDB and (FIndexedFields.Items.Count > 0) and (Table.Session.Connection.MySQLVersion >= 50600)
        or Table.Engine.IsMyISAM and (FIndexedFields.Items.Count > 0) and (Table.Session.Connection.MySQLVersion >= 32323);
  end;

  for I := 0 to FIndexedFields.Items.Count - 1 do
    FFulltext.Enabled := FFulltext.Enabled
      and Assigned(Table)
      and Assigned(FIndexedFields.Items[I].Data)
      and (TSBaseField(FIndexedFields.Items[I].Data).FieldType in [mfChar, mfVarChar, mfTinyText, mfText, mfMediumText, mfLongText]);
  FFulltext.Checked := FFulltext.Enabled and FFulltext.Checked;

  tbUp.Enabled := Assigned(FIndexedFields.Selected) and (FIndexedFields.Items.IndexOf(Item) > 0);
  tbDown.Enabled := Assigned(FIndexedFields.Selected) and (FIndexedFields.Items.IndexOf(Item) + 1 < FIndexedFields.Items.Count);

  tbRemoveAll.Enabled := (FIndexedFields.Items.Count > 0);
  tbRemoveOne.Enabled := Assigned(FIndexedFields.Selected);

  FBOkCheckEnabled(Sender);
end;

procedure TDKey.FIndexedFieldsDeletion(Sender: TObject; Item: TListItem);
begin
  tbRemoveAll.Enabled := FIndexedFields.Enabled;
  FBOkCheckEnabled(Sender);
end;

procedure TDKey.FIndexedFieldsEnter(Sender: TObject);
begin
  FIndexedFieldsChange(Sender, FIndexedFields.Selected, ctState);
end;

procedure TDKey.FIndexedFieldsExit(Sender: TObject);
begin
  tbUp.Enabled := False;
  tbDown.Enabled := False;

  tbRemoveAll.Enabled := False;
  tbRemoveOne.Enabled := False;
end;

procedure TDKey.FLengthExit(Sender: TObject);
begin
  if (Assigned(FIndexedFields.Selected)) then
    Lengths[Table.Fields.IndexOf(TSBaseField(FIndexedFields.Selected.Data))] := FLengthUD.Position;
end;

procedure TDKey.FNameChange(Sender: TObject);
begin
  if (FName.Text <> '') then
    FOther.Checked := True
  else if (FPrimary.Enabled) then
    FPrimary.Checked := True;

  FBOkCheckEnabled(Sender);
end;

procedure TDKey.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  I: Integer;
  NewKey: TSKey;
  NewKeyColumn: TSKeyColumn;
  NewTable: TSBaseTable;
begin
  FLengthExit(Sender);

  // Debug 2017-02-28: Why is the >Visible< sometimes needed???
  if ((ModalResult = mrOk) and GBasics.Visible and Visible) then
  begin
    if (ModifyTableOnly) then
      NewTable := Table
    else
    begin
      NewTable := TSBaseTable.Create(Table.Tables);
      NewTable.Assign(Table);
    end;

    NewKey := TSKey.Create(Table.Keys);
    if (Assigned(Key)) then
      NewKey.Assign(Key);

    NewKey.PrimaryKey := FPrimary.Checked;
    if (not NewKey.PrimaryKey) then
      NewKey.Name := Trim(FName.Text);

    NewKey.Columns.Clear();
    for I := 0 to FIndexedFields.Items.Count - 1 do
    begin
      NewKeyColumn := TSKeyColumn.Create(NewKey.Columns);
      NewKeyColumn.Field := TSBaseField(FIndexedFields.Items[I].Data);
      NewKeyColumn.Length := Lengths[Table.Fields.IndexOf(NewKeyColumn.Field)];
      NewKey.Columns.AddColumn(NewKeyColumn);
      FreeAndNil(NewKeyColumn);
    end;

    NewKey.Comment := Trim(FComment.Text);

    NewKey.Unique := FUnique.Checked;
    NewKey.Fulltext := FFulltext.Checked;

    if (ModifyTableOnly) then
      if (not Assigned(Key)) then
        Table.Keys.AddKey(NewKey)
      else
        Table.Keys[Key.Index].Assign(NewKey)
    else
      if (not Assigned(Key)) then
        NewTable.Keys.AddKey(NewKey)
      else
        NewTable.Keys[Key.Index].Assign(NewKey);

    if (Assigned(Key) and Key.PrimaryKey and not NewKey.PrimaryKey) then
      for I := 0 to NewTable.Fields.Count - 1 do
        NewTable.Fields[I].AutoIncrement := False;

    if (not ModifyTableOnly) then
    begin
      SessionState := ssAlter;

      CanClose := Table.Database.UpdateBaseTable(Table, NewTable);

      GBasics.Visible := False;
      GAttributes.Visible := GBasics.Visible;
      PSQLWait.Visible := not GBasics.Visible;
      FBOk.Enabled := False;
    end;

    NewKey.Free();
    if (NewTable <> Table) then
      NewTable.Free();
  end;
end;

procedure TDKey.FormCreate(Sender: TObject);
begin
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  ToolBar1.Images := Preferences.Images;
  ToolBar2.Images := Preferences.Images;
  ToolBar3.Images := Preferences.Images;
  ToolBar4.Images := Preferences.Images;
  ToolBar5.Images := Preferences.Images;
  ToolBar6.Images := Preferences.Images;

  Panel.Left := GBasics.Width div 2 - Panel.Width div 2;
  Panel.Top := FAvailableFields.Top;
  Panel.Height := FAvailableFields.Height;
end;

procedure TDKey.FormHide(Sender: TObject);
begin
  Table.Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.Key.Width := Width;
  Preferences.Key.Height := Height;

  SetLength(Lengths, 0);
  Table := nil;

  FIndexedFields.Items.BeginUpdate();
  FIndexedFields.Items.Clear();
  FIndexedFields.Items.EndUpdate();
  FAvailableFields.Items.BeginUpdate();
  FAvailableFields.Items.Clear();
  FAvailableFields.Items.EndUpdate();
end;

procedure TDKey.FormResize(Sender: TObject);
begin
  DisableAlign();

  FIndexedFields.Width := (GBasics.ClientWidth - Panel.Width) div 2 - 2 * FIndexedFields.Left;
  Panel.Left := (GBasics.ClientWidth - Panel.Width) div 2;
  FLAvailableFields.Left := (GBasics.ClientWidth + Panel.Width) div 2 + FIndexedFields.Left;
  FAvailableFields.Left := FLAvailableFields.Left;
  FAvailableFields.Width := (GBasics.ClientWidth - Panel.Width) div 2 - 2 * FIndexedFields.Left;

  FComment.Width := FAvailableFields.Left + FAvailableFields.Width - FComment.Left;

  EnableAlign();
end;

procedure TDKey.FormSessionEvent(const Event: TSSession.TEvent);
var
  FirstValid: Boolean;
begin
  FirstValid := SessionState = ssInit;

  if ((SessionState in [ssTable, ssInit]) and (Event.EventType = etItemValid) and (Event.Item = Table)) then
  begin
    BuiltTable();
    if (not Assigned(Key)) then
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
    if (not Assigned(Key)) then
      SessionState := ssCreate
    else
      SessionState := ssValid
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
        ActiveControl := FLName.FocusControl;
    end;
  end;
end;

procedure TDKey.FormShow(Sender: TObject);
begin
  Table.Session.RegisterEventProc(FormSessionEvent);

  if ((Preferences.Key.Width >= Width) and (Preferences.Key.Height >= Height)) then
  begin
    Width := Preferences.Key.Width;
    Height := Preferences.Key.Height;
  end;

  if (not Assigned(Key)) then
  begin
    Caption := Preferences.LoadStr(160);
    HelpContext := 1046;
  end
  else
  begin
    Caption := Preferences.LoadStr(842, Key.Caption);
    HelpContext := 1055;
  end;

  FComment.Visible := Table.Session.Connection.MySQLVersion >= 50503; FLComment.Visible := FComment.Visible;

  if (not ModifyTableOnly and not Table.Update()) then
    SessionState := ssTable
  else if (not Assigned(Key)) then
    SessionState := ssCreate
  else if (not ModifyTableOnly and not Table.Keys.Valid and not Table.Update()) then
    SessionState := ssInit
  else
    SessionState := ssValid;

  if (SessionState <> ssTable) then
    BuiltTable();

  if (not Assigned(Key)) then
  begin
    FPrimary.Enabled := (Table.Keys.Count = 0) or not Table.Keys[0].PrimaryKey;
    FPrimary.Checked := FPrimary.Enabled;
    FOther.Checked := not FPrimary.Checked;

    FName.Text := '';
    FLength.Text := '';
    FComment.Text := '';

    FUnique.Checked := False;
    FFulltext.Checked := False;

    FIndexedFieldsChange(nil, nil, ctState);
    IndexTypeChange(nil);
    FIndexedFieldsExit(nil);
    FAvailableFieldsExit(nil);
  end;

  if (SessionState = ssValid) then
    Built();

  GBasics.Visible := SessionState in [ssCreate, ssValid];
  GAttributes.Visible := GBasics.Visible;
  PSQLWait.Visible := not GBasics.Visible;

  FBOk.Enabled := False;

  ActiveControl := FBCancel;
  if (GBasics.Visible) then
    ActiveControl := FLName.FocusControl;
end;

procedure TDKey.FUniqueClick(Sender: TObject);
begin
  if (FUnique.Checked) then
    FFulltext.Checked := False;

  FBOkCheckEnabled(Sender);
end;

procedure TDKey.IndexTypeChange(Sender: TObject);
begin
  if (FPrimary.Checked) then
    FLName.FocusControl := FPrimary
  else
    FLName.FocusControl := FName;

  FUnique.Enabled := not FPrimary.Checked;
  FUnique.Checked := FPrimary.Checked or FUnique.Checked;

  FBOkCheckEnabled(Sender);
end;

procedure TDKey.tbAddAllClick(Sender: TObject);
begin
  while (FAvailableFields.Items.Count > 0) do
  begin
    FAvailableFields.Items[0].Selected := True;
    tbAddOneClick(Sender);
  end;
end;

procedure TDKey.tbAddOneClick(Sender: TObject);
var
  Index: Integer;
  Item: TListItem;
begin
  Index := FAvailableFields.Items.IndexOf(FAvailableFields.Selected);

  if (Index >= 0) then
  begin
    Item := FIndexedFields.Items.Add();
    Item.Caption := FAvailableFields.Selected.Caption;
    Item.Data := FAvailableFields.Selected.Data;
    FIndexedFields.Selected := Item;

    FAvailableFields.Selected.Delete();

    if (Index < FAvailableFields.Items.Count) then
      FAvailableFields.Items[Index].Selected := True
    else if (FAvailableFields.Items.Count > 0) then
      FAvailableFields.Items[FAvailableFields.Items.Count - 1].Selected := True;
  end;
end;

procedure TDKey.tbRemoveAllClick(Sender: TObject);
begin
  while (FIndexedFields.Items.Count > 0) do
  begin
    FIndexedFields.Items[0].Selected := True;
    tbRemoveOneClick(Sender);
  end;
end;

procedure TDKey.tbRemoveOneClick(Sender: TObject);
var
  Field: TSTableField;
  I: Integer;
  Index: Integer;
  Item: TListItem;
begin
  if (Assigned(FIndexedFields.Selected)) then
  begin
    Field := Table.FieldByName(FIndexedFields.Selected.Caption);

    Index := FIndexedFields.Items.IndexOf(FIndexedFields.Selected);
    FIndexedFields.Items[Index].Delete();
    FIndexedFieldsChange(FIndexedFields, nil, ctState);
    if (Index = FIndexedFields.Items.Count) then Dec(Index);
    if (Index >= 0) then FIndexedFields.Items[Index].Selected := True;

    Index := 0;
    for I := 0 to FAvailableFields.Items.Count - 1 do
      if (Table.Fields.IndexOf(Field) > Table.Fields.IndexOf(Table.FieldByName(FAvailableFields.Items[I].Caption))) then
        Index := I + 1;
    if (Index >= 0) then
      Item := FAvailableFields.Items.Insert(Index)
    else
      Item := FAvailableFields.Items.Add();
    Item.Caption := Field.Name;
    Item.Data := Field;
    Item.Selected := True;
  end;
end;

procedure TDKey.tbUpDownClick(Sender: TObject);
var
  Index: Integer;
  Item: TListItem;
  OldCaption: string;
  OldData: TCustomData;
  OldIndex: Integer;
begin
  OldCaption := FIndexedFields.Selected.Caption;
  OldData := FIndexedFields.Selected.Data;
  OldIndex := FIndexedFields.Items.IndexOf(FIndexedFields.Selected);
  FIndexedFields.Items.Delete(OldIndex);

  if (Sender = tbUp) then
    Index := OldIndex - 1
  else
    Index := OldIndex + 1;

  Item := FIndexedFields.Items.Insert(Index);
  Item.Caption := OldCaption;
  Item.Data := OldData;
  FIndexedFields.Selected := FIndexedFields.Items[Index];
  FIndexedFields.ItemFocused := FIndexedFields.Selected;
end;

procedure TDKey.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiKey, Icon);

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  GBasics.Caption := Preferences.LoadStr(85);
  FLName.Caption := Preferences.LoadStr(35) + ':';
  FPrimary.Caption := Preferences.LoadStr(154);
  FLIndexedFields.Caption := Preferences.LoadStr(155) + ':';
  FLLength.Caption := Preferences.LoadStr(630) + ':';
  FLAvailableFields.Caption := Preferences.LoadStr(156) + ':';
  FLComment.Caption := Preferences.LoadStr(111) + ':';

  GAttributes.Caption := Preferences.LoadStr(157);
  FUnique.Caption := Preferences.LoadStr(158);
  FFulltext.Caption := Preferences.LoadStr(159);

  FBHelp.Caption := Preferences.LoadStr(167);
  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30)
end;

initialization
  FDKey := nil;
end.


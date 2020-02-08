unit uDTable;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes, Actions,
  Graphics, Controls, Forms, Dialogs, ComCtrls, Menus, StdCtrls, ToolWin, ActnList, ExtCtrls,
  SynEdit, SynMemo,
  StdCtrls_Ext, Forms_Ext, ExtCtrls_Ext, ComCtrls_Ext,
  MySQLDB,
  uSession,
  uBase;

type
  TDTable = class (TForm_Ext)
    ActionList: TActionList;
    aPCreateField: TAction;
    aPCreateForeignKey: TAction;
    aPCreateKey: TAction;
    aPCreatePartition: TAction;
    aPCreateTrigger: TAction;
    aPDeleteField: TAction;
    aPDeleteForeignKey: TAction;
    aPDeleteKey: TAction;
    aPDeletePartition: TAction;
    aPDeleteTrigger: TAction;
    aPDown: TAction;
    aPDown1: TMenuItem;
    aPEditField: TAction;
    aPEditForeignKey: TAction;
    aPEditKey: TAction;
    aPEditPartition: TAction;
    aPEditTrigger: TAction;
    aPUp: TAction;
    aPUp1: TMenuItem;
    FAutoIncrement: TEdit;
    FBCancel: TButton;
    FBCheck: TButton;
    FBFlush: TButton;
    FBHelp: TButton;
    FBOk: TButton;
    FBOptimize: TButton;
    FCharset: TComboBox_Ext;
    FChecked: TLabel;
    FCollation: TComboBox_Ext;
    FComment: TEdit;
    FCreated: TLabel;
    FDataSize: TLabel;
    FDependencies: TListView;
    FEngine: TComboBox_Ext;
    FFields: TListView;
    FForeignKeys: TListView;
    FIndexSize: TLabel;
    FKeys: TListView;
    FLAutoIncrement: TLabel;
    FLCharset: TLabel;
    FLChecked: TLabel;
    FLCollation: TLabel;
    FLComment: TLabel;
    FLCreated: TLabel;
    FLDataSize: TLabel;
    FLEngine: TLabel;
    FLIndexSize: TLabel;
    FLinear: TCheckBox;
    FLName: TLabel;
    FLPartitionExpr: TLabel;
    FLPartitions: TLabel;
    FLPartitionsNumber: TLabel;
    FLPartitionType: TLabel;
    FLRecordCount: TLabel;
    FLRowType: TLabel;
    FLUnusedSize: TLabel;
    FLUpdated: TLabel;
    FName: TEdit;
    FPartitionExpr: TEdit;
    FPartitions: TListView_Ext;
    FPartitionsNumber: TEdit;
    FPartitionType: TComboBox_Ext;
    FRecordCount: TLabel;
    FRowType: TComboBox_Ext;
    FSource: TSynMemo;
    FTriggers: TListView;
    FUDPartitionsNumber: TUpDown;
    FUnusedSize: TLabel;
    FUpdated: TLabel;
    GBasics: TGroupBox_Ext;
    GCheck: TGroupBox_Ext;
    GDates: TGroupBox_Ext;
    GFlush: TGroupBox_Ext;
    GOptimize: TGroupBox_Ext;
    GPartitions: TGroupBox_Ext;
    GRecordCount: TGroupBox_Ext;
    GRecords: TGroupBox_Ext;
    GSize: TGroupBox_Ext;
    mlDCreate: TMenuItem;
    mlDDelete: TMenuItem;
    mlDProperties: TMenuItem;
    MList: TPopupMenu;
    msCopy: TMenuItem;
    MSource: TPopupMenu;
    msSelectAll: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    PageControl: TPageControl;
    PPartitions: TPanel_Ext;
    PSQLWait: TPanel;
    tbCreateField: TToolButton;
    tbCreateForeignKey: TToolButton;
    tbCreateKey: TToolButton;
    tbDeleteField: TToolButton;
    tbDeleteForeignKey: TToolButton;
    tbDeleteKey: TToolButton;
    tbFieldDown: TToolButton;
    TBFields: TToolBar;
    tbFieldUp: TToolButton;
    TBForeignKeys: TToolBar;
    TBIndices: TToolBar;
    tbPropertiesField: TToolButton;
    tbPropertiesForeignKey: TToolButton;
    tbPropertiesKey: TToolButton;
    tbSeparator: TToolButton;
    TSBasics: TTabSheet;
    TSDependencies: TTabSheet;
    TSExtras: TTabSheet;
    TSFields: TTabSheet;
    TSForeignKeys: TTabSheet;
    TSInformation: TTabSheet;
    TSKeys: TTabSheet;
    TSPartitions: TTabSheet;
    TSSource: TTabSheet;
    TSTriggers: TTabSheet;
    procedure aPCreateFieldExecute(Sender: TObject);
    procedure aPCreateForeignKeyExecute(Sender: TObject);
    procedure aPCreateKeyExecute(Sender: TObject);
    procedure aPCreatePartitionExecute(Sender: TObject);
    procedure aPDeleteFieldExecute(Sender: TObject);
    procedure aPDeleteForeignKeyExecute(Sender: TObject);
    procedure aPDeleteKeyExecute(Sender: TObject);
    procedure aPDeletePartitionExecute(Sender: TObject);
    procedure aPDownExecute(Sender: TObject);
    procedure aPEditFieldExecute(Sender: TObject);
    procedure aPEditForeignKeyExecute(Sender: TObject);
    procedure aPEditKeyExecute(Sender: TObject);
    procedure aPEditPartitionExecute(Sender: TObject);
    procedure aPUpExecute(Sender: TObject);
    procedure FAutoIncrementExit(Sender: TObject);
    procedure FBCheckClick(Sender: TObject);
    procedure FBFlushClick(Sender: TObject);
    procedure FBHelpClick(Sender: TObject);
    procedure FBOkCheckEnabled(Sender: TObject);
    procedure FBOptimizeClick(Sender: TObject);
    procedure FCharsetChange(Sender: TObject);
    procedure FCharsetExit(Sender: TObject);
    procedure FCollationChange(Sender: TObject);
    procedure FEngineChange(Sender: TObject);
    procedure FFieldsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FFieldsEnter(Sender: TObject);
    procedure FForeignKeysChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FForeignKeysEnter(Sender: TObject);
    procedure FKeysChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FKeysEnter(Sender: TObject);
    procedure FLinearClick(Sender: TObject);
    procedure FLinearKeyPress(Sender: TObject; var Key: Char);
    procedure FListDblClick(Sender: TObject);
    procedure FListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FPartitionsNumberChange(Sender: TObject);
    procedure FPartitionExprChange(Sender: TObject);
    procedure FPartitionsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FPartitionTypeChange(Sender: TObject);
    procedure FTriggersChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FTriggersEnter(Sender: TObject);
    procedure msCopyClick(Sender: TObject);
    procedure TSDependenciesShow(Sender: TObject);
    procedure TSExtrasShow(Sender: TObject);
    procedure TSFieldsShow(Sender: TObject);
    procedure TSForeignKeysShow(Sender: TObject);
    procedure TSKeysShow(Sender: TObject);
    procedure TSInformationShow(Sender: TObject);
    procedure TSPartitionsShow(Sender: TObject);
    procedure TSSourceShow(Sender: TObject);
    procedure TSTriggersShow(Sender: TObject);
  private
    FCreatedName: string;
    NewTable: TSBaseTable;
    SessionState: (ssCreate, ssInit, ssStatus, ssDependencies, ssValid, ssAlter);
    procedure Built();
    procedure BuiltDependencies();
    procedure BuiltStatus();
    procedure FFieldsRefresh(Sender: TObject);
    procedure FForeignKeysRefresh(Sender: TObject);
    procedure FIndicesRefresh(Sender: TObject);
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure FPartitionsRefresh(Sender: TObject);
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Charset: string;
    Collation: string;
    Database: TSDatabase;
    Engine: string;
    RowType: TSTableField.TRowType;
    Table: TSBaseTable;
    function Execute(): Boolean;
    property CreatedName: string read FCreatedName;
  end;

function DTable(): TDTable;

implementation {***************************************************************}

{$R *.dfm}

uses
  StrUtils, SysConst,
  Clipbrd,
  SQLUtils,
  uPreferences,
  uDField, uDKey, uDForeignKey, uDTrigger, uDPartition, uDExecutingSQL;

var
  FDTable: TDTable;

function DTable(): TDTable;
begin
  if (not Assigned(FDTable)) then
  begin
    Application.CreateForm(TDTable, FDTable);
    FDTable.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDTable;
end;

{ TDTable *********************************************************************}

procedure TDTable.aPCreateFieldExecute(Sender: TObject);
begin
  DField.Table := NewTable;
  DField.Field := nil;
  DField.ModifyTableOnly := True;
  if (DField.Execute()) then
  begin
    FFieldsRefresh(Sender);

    FKeys.Items.Clear();

    TSSource.TabVisible := False;
  end;
end;

procedure TDTable.aPCreateForeignKeyExecute(Sender: TObject);
begin
  DForeignKey.Table := NewTable;
  DForeignKey.ForeignKey := nil;
  DForeignKey.ModifyTableOnly := True;
  if (DForeignKey.Execute()) then
  begin
    FForeignKeysRefresh(Sender);

    TSSource.TabVisible := False;
  end;
end;

procedure TDTable.aPCreateKeyExecute(Sender: TObject);
begin
  DKey.Table := NewTable;
  DKey.Key := nil;
  DKey.ModifyTableOnly := True;
  if (DKey.Execute()) then
  begin
    FIndicesRefresh(Sender);

    TSSource.TabVisible := False;
  end;
end;

procedure TDTable.aPCreatePartitionExecute(Sender: TObject);
begin
  DPartition.Table := NewTable;
  DPartition.Partition := nil;
  if (DPartition.Execute()) then
  begin
    FPartitionsRefresh(Sender);

    TSSource.TabVisible := False;
  end;
end;

procedure TDTable.aPDeleteFieldExecute(Sender: TObject);
var
  I: Integer;
  Msg: string;
begin
  if (FFields.SelCount = 1) then
    Msg := Preferences.LoadStr(100, FFields.Selected.Caption)
  else
    Msg := Preferences.LoadStr(413);
  if (MsgBox(Msg, Preferences.LoadStr(101), MB_YESNOCANCEL + MB_ICONQUESTION) = IDYES) then
  begin
    for I := FFields.Items.Count - 1 downto 0 do
      if (FFields.Items[I].Selected) then
        NewTable.Fields.Delete(NewTable.Fields[I]);

    FFieldsRefresh(Sender);
  end;
end;

procedure TDTable.aPDeleteForeignKeyExecute(Sender: TObject);
var
  I: Integer;
  Msg: string;
begin
  if (FForeignKeys.SelCount = 1) then
    Msg := Preferences.LoadStr(692, FForeignKeys.Selected.Caption)
  else
    Msg := Preferences.LoadStr(413);
  if (MsgBox(Msg, Preferences.LoadStr(101), MB_YESNOCANCEL + MB_ICONQUESTION) = IDYES) then
  begin
    for I := FForeignKeys.Items.Count - 1 downto 0 do
      if (FForeignKeys.Items[I].Selected) then
        NewTable.ForeignKeys.Delete(NewTable.ForeignKeys[I]);

    FForeignKeysRefresh(Sender);

    TSSource.TabVisible := False;
  end;
end;

procedure TDTable.aPDeleteKeyExecute(Sender: TObject);
var
  I: Integer;
  Msg: string;
begin
  if (FKeys.SelCount = 1) then
    Msg := Preferences.LoadStr(162, FKeys.Selected.Caption)
  else
    Msg := Preferences.LoadStr(413);
  if (MsgBox(Msg, Preferences.LoadStr(101), MB_YESNOCANCEL + MB_ICONQUESTION) = IDYES) then
  begin
    for I := FKeys.Items.Count - 1 downto 0 do
      if (FKeys.Items[I].Selected) then
        NewTable.Keys.Delete(NewTable.Keys[I]);

    FIndicesRefresh(Sender);

    TSSource.TabVisible := False;
  end;
end;

procedure TDTable.aPDeletePartitionExecute(Sender: TObject);
var
  I: Integer;
  Msg: string;
begin
  if (FPartitions.SelCount = 1) then
    Msg := Preferences.LoadStr(841, FPartitions.Selected.Caption)
  else
    Msg := Preferences.LoadStr(413);
  if (MsgBox(Msg, Preferences.LoadStr(101), MB_YESNOCANCEL + MB_ICONQUESTION) = IDYES) then
    for I := FPartitions.Items.Count - 1 downto 0 do
      if (FPartitions.Items[I].Selected) then
        NewTable.Partitions.Delete(NewTable.Partitions.Partition[I]);

  FPartitionsRefresh(Sender);
end;

procedure TDTable.aPDownExecute(Sender: TObject);
var
  Fields: array of TSTableField;
  FocusedField: TSTableField;
  I: Integer;
  Index: Integer;
  NewListItem: TListItem;
  OldListItem: TListItem;
begin
  if ((PageControl.ActivePage = TSFields) and Assigned(FFields.ItemFocused)) then
  begin
    FocusedField := NewTable.Fields[FFields.ItemFocused.Index];

    SetLength(Fields, FFields.SelCount);

    Index := 0;
    for I := 0 to FFields.Items.Count - 1 do
      if (FFields.Items[I].Selected) then
      begin
        Fields[Index] := NewTable.Fields[I];
        Inc(Index);
      end;

    for Index := Length(Fields) - 1 downto 0 do
    begin
      OldListItem := FFields.Items[Fields[Index].Index];

      TSBaseFields(NewTable.Fields).MoveField(Fields[Index], Fields[Index]);

      NewListItem := FFields.Items.Insert(Fields[Index].Index + 1);
      NewListItem.Caption := OldListItem.Caption;
      NewListItem.ImageIndex := OldListItem.ImageIndex;
      NewListItem.SubItems.Text := OldListItem.SubItems.Text;
      NewListItem.Selected := OldListItem.Selected;

      FFields.Items.Delete(OldListItem.Index);
    end;

    FFields.ItemFocused := FFields.Items[FocusedField.Index];

    FListSelectItem(FFields, FFields.ItemFocused, True);

    SetLength(Fields, FFields.SelCount);
  end
  else if (PageControl.ActivePage = TSPartitions) then
  begin
    NewTable.Partitions.MovePartition(NewTable.Partitions[FPartitions.Selected.Index], FPartitions.Selected.Index + 1);

    FPartitions.Items.BeginUpdate(); FPartitions.DisableAlign();

    OldListItem := FPartitions.Items[FPartitions.Selected.Index];

    NewListItem := FPartitions.Items.Insert(FPartitions.Selected.Index + 2);
    NewListItem.Caption := OldListItem.Caption;
    NewListItem.ImageIndex := OldListItem.ImageIndex;
    NewListItem.SubItems.Text := OldListItem.SubItems.Text;
    NewListItem.Selected := OldListItem.Selected;

    FPartitions.Items.Delete(OldListItem.Index);

    FPartitions.Items.EndUpdate(); FPartitions.EnableAlign();
  end;
end;

procedure TDTable.aPEditFieldExecute(Sender: TObject);
begin
  DField.Table := NewTable;
  DField.Field := TSBaseField(NewTable.Fields[FFields.ItemIndex]);
  DField.ModifyTableOnly := True;
  if (DField.Execute()) then
  begin
    FFieldsRefresh(Sender);

    TSSource.TabVisible := False;
  end;
end;

procedure TDTable.aPEditForeignKeyExecute(Sender: TObject);
var
  ForeignKey: TSForeignKey;
begin
  ForeignKey := NewTable.ForeignKeys[FForeignKeys.ItemIndex];

  DForeignKey.Table := NewTable;
  DForeignKey.ForeignKey := ForeignKey;
  DForeignKey.ModifyTableOnly := True;
  if (DForeignKey.Execute()) then
  begin
    FForeignKeysRefresh(Sender);

    TSSource.TabVisible := False;
  end;
end;

procedure TDTable.aPEditKeyExecute(Sender: TObject);
begin
  DKey.Table := NewTable;
  DKey.Key := NewTable.Keys[FKeys.ItemIndex];
  DKey.ModifyTableOnly := True;
  if (DKey.Execute()) then
  begin
    FIndicesRefresh(Sender);

    TSSource.TabVisible := False;
  end;
end;

procedure TDTable.aPEditPartitionExecute(Sender: TObject);
var
  Partition: TSPartition;
begin
  Partition := NewTable.Partitions[FPartitions.ItemIndex];

  DPartition.Table := NewTable;
  DPartition.Partition := Partition;
  if (DPartition.Execute()) then
  begin
    FPartitionsRefresh(Sender);

    TSSource.TabVisible := False;
  end;
end;

procedure TDTable.aPUpExecute(Sender: TObject);
var
  Fields: array of TSTableField;
  FocusedField: TSTableField;
  I: Integer;
  Index: Integer;
  NewListItem: TListItem;
  OldListItem: TListItem;
begin
  if ((PageControl.ActivePage = TSFields) and Assigned(FFields.ItemFocused)) then
  begin
    FocusedField := NewTable.Fields[FFields.ItemFocused.Index];

    SetLength(Fields, FFields.SelCount);

    Index := 0;
    for I := 0 to FFields.Items.Count - 1 do
      if (FFields.Items[I].Selected) then
      begin
        Fields[Index] := NewTable.Fields[I];
        Inc(Index);
      end;

    for Index := 0 to Length(Fields) - 1 do
    begin
      OldListItem := FFields.Items[Fields[Index].Index];

      TSBaseFields(NewTable.Fields).MoveField(Fields[Index], Fields[Index].FieldBefore.FieldBefore);

      NewListItem := FFields.Items.Insert(Fields[Index].Index);
      NewListItem.Caption := OldListItem.Caption;
      NewListItem.ImageIndex := OldListItem.ImageIndex;
      NewListItem.SubItems.Text := OldListItem.SubItems.Text;
      NewListItem.Selected := OldListItem.Selected;

      FFields.Items.Delete(OldListItem.Index);
    end;

    FFields.ItemFocused := FFields.Items[FocusedField.Index];

    FListSelectItem(FFields, FFields.ItemFocused, True);

    SetLength(Fields, FFields.SelCount);
  end
  else if (PageControl.ActivePage = TSPartitions) then
  begin
    NewTable.Partitions.MovePartition(NewTable.Partitions[FPartitions.Selected.Index], FPartitions.Selected.Index - 1);

    FPartitions.Items.BeginUpdate(); FPartitions.DisableAlign();

    OldListItem := FPartitions.Items[FPartitions.Selected.Index];

    NewListItem := FPartitions.Items.Insert(FPartitions.Selected.Index - 1);
    NewListItem.Caption := OldListItem.Caption;
    NewListItem.ImageIndex := OldListItem.ImageIndex;
    NewListItem.SubItems.Text := OldListItem.SubItems.Text;
    NewListItem.Selected := OldListItem.Selected;

    FPartitions.Items.Delete(OldListItem.Index);

    FPartitions.Items.EndUpdate(); FPartitions.EnableAlign();
  end;
end;

procedure TDTable.Built();
begin
  if (Assigned(Table)) then NewTable.Assign(Table);

  FName.Text := NewTable.Name;

  if (NewTable.Charset <> '') then
    FCharset.ItemIndex := FCharset.Items.IndexOf(NewTable.Charset)
  else
    FCharset.ItemIndex := -1;
  FCharsetChange(Self);
  if (NewTable.Collation <> '') then
    FCollation.ItemIndex := FCollation.Items.IndexOf(NewTable.Collation)
  else
    FCollation.ItemIndex := -1;
  FCollationChange(Self);

  FComment.Text := NewTable.Comment;

  if (not Assigned(NewTable.Engine)) then
    FEngine.ItemIndex := -1
  else
    FEngine.ItemIndex := FEngine.Items.IndexOf(NewTable.Engine.Name);
  FEngineChange(Self);

  FRowType.ItemIndex := Integer(NewTable.RowType);
  FAutoIncrement.Visible := NewTable.AutoIncrement > 0; FLAutoIncrement.Visible := FAutoIncrement.Visible;
  FAutoIncrement.Text := IntToStr(NewTable.AutoIncrement);

  if (Assigned(NewTable.Partitions)) then
  begin
    FPartitionsNumber.OnChange := nil;
    case (NewTable.Partitions.PartitionType) of
      ptHash: FPartitionType.ItemIndex := 1;
      ptKey: FPartitionType.ItemIndex := 2;
      ptRange: FPartitionType.ItemIndex := 3;
      ptList: FPartitionType.ItemIndex := 4;
      else FPartitionType.ItemIndex := 0
    end;
    FLinear.Checked := NewTable.Partitions.Linear;
    FPartitionExpr.Text := NewTable.Partitions.Expression;
    FPartitionsNumber.OnChange := FPartitionsNumberChange;
    FUDPartitionsNumber.Position := NewTable.Partitions.PartitionsNumber;

    FPartitionTypeChange(nil);
  end;

  TSSource.TabVisible := NewTable.Source <> '';
end;

procedure TDTable.BuiltDependencies();

  procedure AddDBObject(const DBObject: TSDBObject);
  var
    I: Integer;
    Item: TListItem;
  begin
    for I := 0 to DBObject.References.Count - 1 do
      if (DBObject.References[I].DBObject = Table) then
      begin
        Item := FDependencies.Items.Add();

        if (DBObject is TSBaseTable) then
        begin
          Item.ImageIndex := iiBaseTable;
          Item.Caption := DBObject.Caption;
          Item.SubItems.Add(Preferences.LoadStr(302));
        end
        else if (DBObject is TSView) then
        begin
          Item.ImageIndex := iiView;
          Item.Caption := DBObject.Caption;
          Item.SubItems.Add(Preferences.LoadStr(738));
        end
        else if (DBObject is TSProcedure) then
        begin
          Item.ImageIndex := iiProcedure;
          Item.Caption := DBObject.Caption;
          Item.SubItems.Add(Preferences.LoadStr(768));
        end
        else if (DBObject is TSFunction) then
        begin
          Item.ImageIndex := iiFunction;
          Item.Caption := DBObject.Caption;
          Item.SubItems.Add(Preferences.LoadStr(769));
        end
        else if (DBObject is TSTrigger) then
        begin
          Item.ImageIndex := iiTrigger;
          Item.Caption := DBObject.Caption;
          Item.SubItems.Add(Preferences.LoadStr(923, TSTrigger(DBObject).TableName));
        end
        else if (DBObject is TSEvent) then
        begin
          Item.ImageIndex := iiEvent;
          Item.Caption := DBObject.Caption;
          Item.SubItems.Add(Preferences.LoadStr(812));
        end
        else
          raise ERangeError.Create(SRangeError);
        Item.Data := DBObject;
      end;
  end;

var
  I: Integer;
begin
  FDependencies.Items.BeginUpdate();
  FDependencies.Items.Clear();

  for I := 0 to Database.Tables.Count - 1 do
    if (Database.Tables[I] <> Table) then
      AddDBObject(Database.Tables[I]);

  if (Assigned(Database.Routines)) then
    for I := 0 to Database.Routines.Count - 1 do
      AddDBObject(Database.Routines[I]);

  if (Assigned(Database.Triggers)) then
    for I := 0 to Database.Triggers.Count - 1 do
      if (Database.Triggers[I].Table <> Table) then
        AddDBObject(Database.Triggers[I]);

  if (Assigned(Database.Events)) then
    for I := 0 to Database.Events.Count - 1 do
      AddDBObject(Database.Events[I]);

  FDependencies.Items.EndUpdate();
end;

procedure TDTable.BuiltStatus();
begin
  if (Table.Created = 0) then FCreated.Caption := '???' else FCreated.Caption := SysUtils.DateTimeToStr(Table.Created, LocaleFormatSettings);
  if (Table.Updated = 0) then FUpdated.Caption := '???' else FUpdated.Caption := SysUtils.DateTimeToStr(Table.Updated, LocaleFormatSettings);

  FIndexSize.Caption := SizeToStr(Table.IndexSize);
  FDataSize.Caption := SizeToStr(Table.DataSize);

  if (Assigned(Table.Engine) and Table.Engine.IsInnoDB) then
    FRecordCount.Caption := FormatFloat('~#,##0', Table.RecordCount, LocaleFormatSettings)
  else
    FRecordCount.Caption := FormatFloat('#,##0', Table.RecordCount, LocaleFormatSettings);


  FUnusedSize.Caption := SizeToStr(Table.UnusedSize);

  if (Table.Checked <= 0) then
    FChecked.Caption := '???'
  else
    FChecked.Caption := SysUtils.DateTimeToStr(Table.Checked, LocaleFormatSettings);
end;

function TDTable.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDTable.FAutoIncrementExit(Sender: TObject);
var
  Value: Int64;
begin
  if (TryStrToInt64(FAutoIncrement.Text, Value)) then
    NewTable.AutoIncrement := Value;
end;

procedure TDTable.FBCheckClick(Sender: TObject);
var
  List: TList;
begin
  List := TList.Create();
  List.Add(NewTable);
  Database.CheckTables(List);
  List.Free();

  FBCheck.Enabled := False;
  ActiveControl := FBCancel;

  FBCancel.Caption := Preferences.LoadStr(231);
end;

procedure TDTable.FBFlushClick(Sender: TObject);
var
  List: TList;
begin
  List := TList.Create();
  List.Add(NewTable);
  Database.FlushTables(List);
  List.Free();

  FBFlush.Enabled := False;
  ActiveControl := FBCancel;

  FBCancel.Caption := Preferences.LoadStr(231);
end;

procedure TDTable.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDTable.FBOkCheckEnabled(Sender: TObject);
begin
  FBOk.Enabled := PageControl.Visible
    and (FName.Text <> '')
    and (not Assigned(Database.TableByName(FName.Text)) or (Assigned(Table) and (((Database.Session.LowerCaseTableNames = 0) and (FName.Text = Table.Name)) or ((Database.Session.LowerCaseTableNames > 0) and ((lstrcmpi(PChar(FName.Text), PChar(Table.Name)) = 0))))));
end;

procedure TDTable.FBOptimizeClick(Sender: TObject);
var
  List: TList;
begin
  List := TList.Create();
  List.Add(NewTable);
  Database.OptimizeTables(List);
  List.Free();

  FBOptimize.Enabled := False;
  ActiveControl := FBCancel;

  FBCancel.Caption := Preferences.LoadStr(231);
end;

procedure TDTable.FCharsetChange(Sender: TObject);
var
  Charset: TSCharset;
  I: Integer;
begin
  Charset := Database.Session.CharsetByName(FCharset.Text);

  FCollation.Items.Clear();
  if (Assigned(Database.Session.Collations)) then
  begin
    for I := 0 to Database.Session.Collations.Count - 1 do
      if (Assigned(Charset) and (Database.Session.Collations[I].Charset = Charset)) then
        FCollation.Items.Add(Database.Session.Collations[I].Name);
    if (Assigned(Charset) and Assigned(Charset.DefaultCollation)) then
      FCollation.ItemIndex := FCollation.Items.IndexOf(Charset.DefaultCollation.Caption);
  end;
  FCollation.Enabled := Assigned(Charset); FLCollation.Enabled := FCollation.Enabled;

  FBOkCheckEnabled(Sender);
end;

procedure TDTable.FCollationChange(Sender: TObject);
var
  Collation: TSCollation;
begin
  Collation := Database.Session.CollationByName(FCollation.Text);
  if (Assigned(Collation)) then
    NewTable.Collation := Collation.Name;

  FBOkCheckEnabled(Sender);
end;

procedure TDTable.FCharsetExit(Sender: TObject);
begin
  if (FCharset.Text = '') then
    FCharset.Text := NewTable.Charset;
end;

procedure TDTable.FEngineChange(Sender: TObject);
begin
  NewTable.Engine := Database.Session.EngineByName(Trim(FEngine.Text));

  TSForeignKeys.TabVisible := Assigned(Table) and Assigned(Database.Session.EngineByName(FEngine.Text)) and Database.Session.EngineByName(FEngine.Text).ForeignKeyAllowed;

  FBOkCheckEnabled(Sender);
end;

procedure TDTable.FFieldsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if (ctText = Change) then
    FBOkCheckEnabled(Sender);
end;

procedure TDTable.FFieldsEnter(Sender: TObject);
begin
  FListSelectItem(FFields, FFields.Selected, Assigned(FFields.Selected));
end;

procedure TDTable.FFieldsRefresh(Sender: TObject);
var
  I: Integer;
  SelectedField: string;
begin
  SelectedField := '';
  if (Assigned(FFields.Selected)) then SelectedField := FFields.Selected.Caption;

  FFields.Items.Clear();
  TSFieldsShow(Sender);
  for I := 0 to FFields.Items.Count - 1 do
    if (FFields.Items[I].Caption = SelectedField) then
    begin
      FFields.Selected := FFields.Items[I];
      FFields.ItemFocused := FFields.Selected;

      if (Assigned(FFields.ItemFocused) and (FFields.ItemFocused.Position.Y > FFields.ClientHeight)) then
        FFields.Scroll(0, (FFields.ItemFocused.Index + 2) * (FFields.Items[1].Top - FFields.Items[0].Top) - (FFields.ClientHeight - GetSystemMetrics(SM_CYHSCROLL)));
    end;

  FKeys.Items.Clear();

  FBOkCheckEnabled(Sender);
end;

procedure TDTable.FForeignKeysChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if (ctText = Change) then
    FBOkCheckEnabled(Sender);
end;

procedure TDTable.FForeignKeysEnter(Sender: TObject);
begin
  FListSelectItem(FForeignKeys, FForeignKeys.Selected, Assigned(FForeignKeys.Selected));
end;

procedure TDTable.FForeignKeysRefresh(Sender: TObject);
var
  I: Integer;
  SelectedField: string;
begin
  SelectedField := '';
  if (Assigned(FForeignKeys.Selected)) then SelectedField := FForeignKeys.Selected.Caption;

  FForeignKeys.Items.Clear();
  TSForeignKeysShow(Sender);
  for I := 0 to FForeignKeys.Items.Count - 1 do
    if (FForeignKeys.Items[I].Caption = SelectedField) then
    begin
      FForeignKeys.Selected := FForeignKeys.Items[I];
      FForeignKeys.ItemFocused := FForeignKeys.Selected;

      if (Assigned(FForeignKeys.ItemFocused) and (FForeignKeys.ItemFocused.Position.Y > FForeignKeys.ClientHeight)) then
        FForeignKeys.Scroll(0, (FForeignKeys.ItemFocused.Index + 2) * (FForeignKeys.Items[1].Top - FForeignKeys.Items[0].Top) - (FForeignKeys.ClientHeight - GetSystemMetrics(SM_CYHSCROLL)));
    end;

  FBOkCheckEnabled(Sender);
end;

procedure TDTable.FKeysChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if (ctText = Change) then
    FBOkCheckEnabled(Sender);
end;

procedure TDTable.FKeysEnter(Sender: TObject);
begin
  FListSelectItem(FKeys, FKeys.Selected, Assigned(FKeys.Selected));
end;

procedure TDTable.FIndicesRefresh(Sender: TObject);
var
  I: Integer;
  SelectedField: string;
begin
  SelectedField := '';
  if (Assigned(FKeys.Selected)) then SelectedField := FKeys.Selected.Caption;

  FKeys.Items.Clear();
  TSKeysShow(Sender);
  for I := 0 to FKeys.Items.Count - 1 do
    if (FKeys.Items[I].Caption = SelectedField) then
    begin
      FKeys.Selected := FKeys.Items[I];
      FKeys.ItemFocused := FKeys.Selected;

      if (Assigned(FKeys.ItemFocused) and (FKeys.ItemFocused.Position.Y > FKeys.ClientHeight)) then
        FKeys.Scroll(0, (FKeys.ItemFocused.Index + 2) * (FKeys.Items[1].Top - FKeys.Items[0].Top) - (FKeys.ClientHeight - GetSystemMetrics(SM_CYHSCROLL)));
    end;

  FBOkCheckEnabled(Sender);
end;

procedure TDTable.FLinearClick(Sender: TObject);
begin
  NewTable.Partitions.Linear := FLinear.Checked;
end;

procedure TDTable.FLinearKeyPress(Sender: TObject; var Key: Char);
begin
  FLinearClick(Sender);
end;

procedure TDTable.FListDblClick(Sender: TObject);
var
  I: Integer;
  ListView: TListView;
begin
  ListView := TListView(Sender);
  if (Assigned(ListView)) and (Assigned(ListView.PopupMenu)) then
    for I := 0 to MList.Items.Count - 1 do
      if (ListView.PopupMenu.Items.Items[I].Default) and (ListView.PopupMenu.Items.Items[I].Enabled) then
        ListView.PopupMenu.Items.Items[I].Click();
end;

procedure TDTable.FListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  ListView: TListView;
  I: Integer;
  Page: TTabSheet;
begin
  Page := TTabSheet(PageControl.ActivePage);
  for I := 0 to PageControl.PageCount - 1 do
    if (PageControl.Pages[I].Visible and (PageControl.Pages[I] <> Page)) then
      Page := TTabSheet(PageControl.Pages[I]);

  ListView := TListView(Sender);

  aPCreateField.Enabled := not Selected and (Page = TSFields);
  aPDeleteField.Enabled := Selected and (ListView.SelCount >= 1) and (Item.ImageIndex = iiBaseField) and (NewTable.Fields.Count > 1);
  aPEditField.Enabled := Selected and (ListView.SelCount = 1) and (Page = TSFields);
  aPCreateKey.Enabled := not Selected and (Page = TSKeys);
  aPDeleteKey.Enabled := Selected and (ListView.SelCount >= 1) and (Item.ImageIndex = iiKey);
  aPEditKey.Enabled := Selected and (ListView.SelCount = 1) and (Page = TSKeys);
  aPCreateForeignKey.Enabled := not Selected and (Page = TSForeignKeys);
  aPDeleteForeignKey.Enabled := Selected and (ListView.SelCount >= 1) and (Item.ImageIndex = iiForeignKey);
  aPEditForeignKey.Enabled := Selected and (ListView.SelCount = 1) and (Page = TSForeignKeys);
  aPCreateTrigger.Enabled := not Selected and (Page = TSTriggers);
  aPDeleteTrigger.Enabled := Selected and (ListView.SelCount >= 1) and (Item.ImageIndex = iiTrigger);
  aPEditTrigger.Enabled := Selected and (ListView.SelCount = 1) and (Page = TSTriggers);
  aPCreatePartition.Enabled := not Selected and (Page = TSPartitions);
  aPDeletePartition.Enabled := Selected and (ListView.SelCount >= 1);
  aPEditPartition.Enabled := Selected and (ListView.SelCount = 1) and (Page = TSPartitions);

  aPUp.Enabled := Selected and (ListView = FFields) and not ListView.Items[0].Selected and (NewTable.Database.Session.Connection.MySQLVersion >= 40001);
  aPDown.Enabled := Selected and (ListView = FFields) and not ListView.Items[ListView.Items.Count - 1].Selected and (NewTable.Database.Session.Connection.MySQLVersion >= 40001);

  ShowEnabledItems(MList.Items);

  mlDProperties.Default := mlDProperties.Enabled;
end;

procedure TDTable.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  I64: Int64;
begin
  if ((ModalResult = mrOk) and PageControl.Visible) then
  begin
    NewTable.Name := Trim(FName.Text);
    NewTable.Charset := FCharset.Text;
    NewTable.Collation := FCollation.Text;
    if (not Assigned(Table) or (Trim(FComment.Text) <> NewTable.Comment)) then
      NewTable.Comment := Trim(FComment.Text);

    if (GRecords.Visible) then
    begin
      NewTable.RowType := TSTableField.TRowType(FRowType.ItemIndex);
      if (TryStrToInt64(FAutoIncrement.Text, I64)) then NewTable.AutoIncrement := I64;
    end
    else
    begin
      NewTable.RowType := mrUnknown;
      NewTable.AutoIncrement := 0;
    end;

    SessionState := ssAlter;

    if (not Assigned(Table)) then
      CanClose := Database.AddBaseTable(NewTable)
    else
      CanClose := Database.UpdateBaseTable(Table, NewTable);

    if (Assigned(Table) or not CanClose) then
      FCreatedName := ''
    else
      FCreatedName := NewTable.Name;

    PageControl.Visible := False;
    PSQLWait.Visible := not PageControl.Visible;
    FBOk.Enabled := False;
  end;
end;

procedure TDTable.FormCreate(Sender: TObject);
begin
  FFields.SmallImages := Preferences.Images;
  FKeys.SmallImages := Preferences.Images;
  FForeignKeys.SmallImages := Preferences.Images;
  FTriggers.SmallImages := Preferences.Images;
  FDependencies.SmallImages := Preferences.Images;

  TBFields.Images := Preferences.Images;
  TBIndices.Images := Preferences.Images;
  TBForeignKeys.Images := Preferences.Images;
//  TBPartitions.Images := Preferences.Images;

  FSource.Highlighter := Preferences.Editor.Highlighter;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  msCopy.Action := aECopy;
  msSelectAll.Action := aESelectAll; msSelectAll.ShortCut := 0;

  SetWindowLong(FAutoIncrement.Handle, GWL_STYLE, GetWindowLong(FAutoIncrement.Handle, GWL_STYLE) or ES_NUMBER);
  FFields.RowSelect := CheckWin32Version(6);
  FKeys.RowSelect := CheckWin32Version(6);
  FForeignKeys.RowSelect := CheckWin32Version(6);
  FDependencies.RowSelect := CheckWin32Version(6);
  FPartitions.RowSelect := CheckWin32Version(6);

  PageControl.ActivePage := nil;
end;

procedure TDTable.FormDestroy(Sender: TObject);
begin
  NewTable.Free();
end;

procedure TDTable.FormHide(Sender: TObject);
begin
  Database.Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.Table.Width := Width;
  Preferences.Table.Height := Height;

  FFields.Items.BeginUpdate();
  FFields.Items.Clear();
  FFields.Items.EndUpdate();
  FKeys.Items.BeginUpdate();
  FKeys.Items.Clear();
  FKeys.Items.EndUpdate();
  FForeignKeys.Items.BeginUpdate();
  FForeignKeys.Items.Clear();
  FForeignKeys.Items.EndUpdate();
  FTriggers.Items.BeginUpdate();
  FTriggers.Items.Clear();
  FTriggers.Items.EndUpdate();
  FDependencies.Items.BeginUpdate();
  FDependencies.Items.Clear();
  FDependencies.Items.EndUpdate();

  FSource.Lines.Clear();

  PageControl.ActivePage := nil;

  // Must be after ActivePage := nil, since in FAutoIncrementExit NewTable will be accessed
  if (Assigned(NewTable)) then
    FreeAndNil(NewTable);
end;

procedure TDTable.FormSessionEvent(const Event: TSSession.TEvent);
var
  FirstValid: Boolean;
begin
  FirstValid := SessionState = ssInit;

  if ((SessionState = ssInit) and (Event.EventType = etError)) then
    ModalResult := mrCancel
  else if ((SessionState in [ssInit, ssStatus]) and (Event.EventType = etItemValid) and (Event.Item = Table)) then
  begin
    if (SessionState = ssInit) then
      Built()
    else if (SessionState = ssStatus) then
      BuiltStatus();
    SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType = etError)) then
  begin
    if (not Assigned(Table)) then
      SessionState := ssCreate
    else
      SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType in [etItemValid, etItemCreated, etItemRenamed])) then
    ModalResult := mrOk
  else if (Event.EventType = etAfterExecuteSQL) then
  begin
    BuiltDependencies();
    SessionState := ssValid;
  end
  else if ((SessionState = ssDependencies) and (Event.EventType = etAfterExecuteSQL)) then
  begin
    BuiltDependencies();
    SessionState := ssValid;
  end;

  if (SessionState in [ssCreate, ssValid]) then
  begin
    GDates.Cursor := crDefault;
    FLCreated.Cursor := crDefault;
    FLUpdated.Cursor := crDefault;
    GSize.Cursor := crDefault;
    FLIndexSize.Cursor := crDefault;
    FLDataSize.Cursor := crDefault;
    GRecordCount.Cursor := crDefault;

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
        ActiveControl := FName;
    end;
  end;
end;

procedure TDTable.FormShow(Sender: TObject);
var
  I: Integer;
  NewField: TSBaseField;
  NewKey: TSKey;
  NewKeyColumn: TSKeyColumn;
  TableName: string;
begin
  Database.Session.RegisterEventProc(FormSessionEvent);

  if ((Preferences.Table.Width >= Width) and (Preferences.Table.Height >= Height)) then
  begin
    Width := Preferences.Table.Width;
    Height := Preferences.Table.Height;
  end;

  if (not Assigned(Table)) then
  begin
    Caption := Preferences.LoadStr(383);
    HelpContext := 1045;
  end
  else
  begin
    Caption := Preferences.LoadStr(842, Table.Name);
    HelpContext := 1054;
  end;

  FSource.Lines.Clear();

  if (not Assigned(Table) and (Database.Session.LowerCaseTableNames = 1)) then
    FName.CharCase := ecLowerCase
  else
    FName.CharCase := ecNormal;

  FEngine.Items.Clear();
  for I := 0 to Database.Session.Engines.Count - 1 do
    if (not (Database.Session.Engines[I] is TSSystemEngine)) then
      FEngine.Items.Add(Database.Session.Engines[I].Name);

  FCharset.Items.Clear();
  for I := 0 to Database.Session.Charsets.Count - 1 do
    FCharset.Items.Add(Database.Session.Charsets[I].Name);
  FCharset.ItemIndex := -1; FCharsetChange(Sender);

  FCollation.Text := '';

  FPartitionType.ItemIndex := 0;


  FBOptimize.Enabled := True;
  FBCheck.Enabled := True;
  FBFlush.Enabled := True;

  NewTable := TSBaseTable.Create(Database.Tables);

  if (not Assigned(Table)) then
    SessionState := ssCreate
  else if (not Table.Valid and not Table.Update()) then
    SessionState := ssInit
  else
    SessionState := ssValid;

  if (not Assigned(Table)) then
  begin
    NewTable.Charset := Database.Charset;
    NewTable.Collation := Database.Collation;
    NewTable.Engine := Database.Session.Engines.DefaultEngine;

    NewField := TSBaseField.Create(NewTable.Fields);
    NewField.Name := 'Id';
    NewField.FieldKind := mkReal;
    NewField.FieldType := mfInt;
    NewField.Size := 11;
    NewField.Unsigned := False;
    NewField.NullAllowed := False;
    NewField.AutoIncrement := True;
    NewTable.Fields.AddField(NewField);
    FreeAndNil(NewField);

    NewKey := TSKey.Create(NewTable.Keys);
    NewKey.PrimaryKey := True;

    NewKeyColumn := TSKeyColumn.Create(NewKey.Columns);
    NewKeyColumn.Field := TSBaseField(NewTable.Fields[0]);
    NewKey.Columns.AddColumn(NewKeyColumn);
    FreeAndNil(NewKeyColumn);

    NewTable.Keys.AddKey(NewKey);
    FreeAndNil(NewKey);

    FName.Text := Preferences.LoadStr(114);
    Database.Session.Connection.BeginSynchron(28);
    Database.Tables.Update(False);
    Database.Session.Connection.EndSynchron(28);
    while (Assigned(Database.TableByName(FName.Text))) do
    begin
      TableName := FName.Text;
      Delete(TableName, 1, Length(Preferences.LoadStr(114)));
      if (TableName = '') then TableName := '1';
      TableName := Preferences.LoadStr(114) + IntToStr(StrToInt(TableName) + 1);
      FName.Text := TableName;
    end;

    FCharset.ItemIndex := FCharset.Items.IndexOf(Database.Charset); FCharsetChange(Sender);
    FCollation.ItemIndex := FCollation.Items.IndexOf(Database.Collation); FCollationChange(Sender);

    FComment.Text := '';

    if (not Assigned(NewTable.Engine)) then
      FEngine.ItemIndex := -1
    else
      FEngine.ItemIndex := FEngine.Items.IndexOf(NewTable.Engine.Name);
    FEngineChange(Sender);

    FRowType.ItemIndex := Integer(NewTable.RowType);
    FAutoIncrement.Visible := NewTable.AutoIncrement > 0; FLAutoIncrement.Visible := FAutoIncrement.Visible;
    FAutoIncrement.Text := IntToStr(NewTable.AutoIncrement);
  end
  else
  begin
    if (SessionState = ssValid) then
      Built();
  end;


  FCharset.Visible := Database.Session.Connection.MySQLVersion >= 40101; FLCharset.Visible := FCharset.Visible;
  FCollation.Visible := Database.Session.Connection.MySQLVersion >= 40101; FLCollation.Visible := FCollation.Visible;
  GRecords.Visible := Assigned(Table);

  FDependencies.Cursor := crDefault;

  TSInformation.TabVisible := Assigned(Table);
  TSKeys.TabVisible := True;
  TSFields.TabVisible := True;
  TSForeignKeys.TabVisible := Assigned(Table);
  TSTriggers.TabVisible := Assigned(Table) and Assigned(Database.Triggers);
  TSDependencies.TabVisible := Assigned(Table);
  TSPartitions.TabVisible := Assigned(Table) and Assigned(NewTable.Partitions);
  TSExtras.TabVisible := Assigned(Table);
  TSSource.TabVisible := Assigned(Table);

  PageControl.Visible := SessionState in [ssCreate, ssValid];
  PSQLWait.Visible := not PageControl.Visible;

  FBOk.Enabled := PageControl.Visible and not Assigned(Table);
  FBCancel.Caption := Preferences.LoadStr(30);

  PageControl.ActivePage := TSBasics;
  ActiveControl := FBCancel;
  if (PageControl.Visible) then
  begin
    FName.SelectAll();
    ActiveControl := FName;
  end;
end;

procedure TDTable.FPartitionsNumberChange(Sender: TObject);
begin
  NewTable.Partitions.PartitionsNumber := FUDPartitionsNumber.Position;

  FPartitionExpr.Enabled := FPartitions.Items.Count = 0;
  FLPartitionExpr.Enabled := FPartitionExpr.Enabled;

  FPartitionType.Enabled := FPartitions.Items.Count = 0;
  FLPartitionType.Enabled := FPartitionType.Enabled;

  FPartitionsNumber.Enabled := FPartitions.Items.Count = 0;
  FUDPartitionsNumber.Enabled := FPartitionsNumber.Enabled;
  FLPartitionsNumber.Enabled := FPartitionsNumber.Enabled;

  FBOkCheckEnabled(Sender);
end;

procedure TDTable.FPartitionExprChange(Sender: TObject);
begin
  NewTable.Partitions.Expression := FPartitionExpr.Text;
end;

procedure TDTable.FPartitionsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  FPartitionsNumberChange(Sender);

  FBOkCheckEnabled(Sender);
end;

procedure TDTable.FPartitionsRefresh(Sender: TObject);
var
  I: Integer;
  Item: TListItem;
  SelectedPartition: string;
begin
  if (not Assigned(FPartitions.Selected)) then
    SelectedPartition := ''
  else
    SelectedPartition := FPartitions.Selected.Caption;

  FPartitions.Items.Clear();
  if (NewTable.Partitions.PartitionType in [ptRange, ptList]) then
    for I := 0 to NewTable.Partitions.Count - 1 do
    begin
      Item := FPartitions.Items.Add();
      Item.ImageIndex := iiPartition;
      Item.Caption := NewTable.Partitions[I].Name;
      Item.SubItems.Add(NewTable.Partitions[I].ValuesExpr);
      if (NewTable.Partitions[I].MinRows < 0) then
        Item.SubItems.Add('')
      else
        Item.SubItems.Add(IntToStr(NewTable.Partitions[I].MinRows));
      if (NewTable.Partitions[I].MaxRows < 0) then
        Item.SubItems.Add('')
      else
        Item.SubItems.Add(IntToStr(NewTable.Partitions[I].MaxRows));
      Item.SubItems.Add(NewTable.Partitions[I].Comment);
    end;

  for I := 0 to FPartitions.Items.Count - 1 do
    if (FPartitions.Items[I].Caption = SelectedPartition) then
    begin
      FPartitions.Selected := FPartitions.Items[I];
      FPartitions.ItemFocused := FPartitions.Selected;

      if (Assigned(FPartitions.ItemFocused) and (FPartitions.ItemFocused.Position.Y > FPartitions.ClientHeight)) then
        FPartitions.Scroll(0, (FPartitions.ItemFocused.Index + 2) * (FPartitions.Items[1].Top - FPartitions.Items[0].Top) - (FPartitions.ClientHeight - GetSystemMetrics(SM_CYHSCROLL)));
    end;

  FBOkCheckEnabled(Sender);
end;

procedure TDTable.FPartitionTypeChange(Sender: TObject);
begin
  case (FPartitionType.ItemIndex) of
    1: NewTable.Partitions.PartitionType := ptHash;
    2: NewTable.Partitions.PartitionType := ptKey;
    3: NewTable.Partitions.PartitionType := ptRange;
    4: NewTable.Partitions.PartitionType := ptList;
    else NewTable.Partitions.PartitionType := ptNone;
  end;

  FLinear.Visible := NewTable.Partitions.PartitionType in [ptHash, ptKey];

  FPartitionExpr.Visible := NewTable.Partitions.PartitionType in [ptHash, ptRange, ptList];
  FLPartitionExpr.Visible := FPartitionExpr.Visible;

  FPartitionsNumber.Visible := NewTable.Partitions.PartitionType in [ptHash, ptKey, ptRange, ptList];
  FLPartitionsNumber.Visible := FPartitionsNumber.Visible;
  FUDPartitionsNumber.Visible := FPartitionsNumber.Visible;

  FPartitions.Items.Clear();
  FPartitions.Visible := NewTable.Partitions.PartitionType in [ptKey, ptRange, ptList];
  FLPartitions.Visible := FPartitions.Visible;

  FPartitionsChange(Sender, nil, ctState);

  FBOkCheckEnabled(Sender);
end;

procedure TDTable.FTriggersChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if (ctText = Change) then
    FBOkCheckEnabled(Sender);
end;

procedure TDTable.FTriggersEnter(Sender: TObject);
begin
  FListSelectItem(FTriggers, FTriggers.Selected, Assigned(FTriggers.Selected));
end;

procedure TDTable.msCopyClick(Sender: TObject);
begin
  FSource.CopyToClipboard();
end;

procedure TDTable.TSExtrasShow(Sender: TObject);
begin
  if (not Table.Update(True)) then
  begin
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

procedure TDTable.TSFieldsShow(Sender: TObject);
var
  I: Integer;
  ListItem: TListItem;
  S: string;
  TempOnChange: TLVChangeEvent;
begin
  TempOnChange := FFields.OnChange;
  FFields.OnChange := nil;

  mlDCreate.Action := aPCreateField;
  mlDDelete.Action := aPDeleteField;
  mlDProperties.Action := aPEditField;

  mlDCreate.Caption := Preferences.LoadStr(26) + '...';
  mlDDelete.Caption := Preferences.LoadStr(28);
  mlDCreate.ShortCut := VK_INSERT;
  mlDDelete.ShortCut := VK_DELETE;

  if (FFields.Items.Count = 0) then
    for I := 0 to NewTable.Fields.Count - 1 do
    begin
      ListItem := FFields.Items.Add();
      ListItem.Caption := NewTable.Fields[I].Name;
      ListItem.SubItems.Add(NewTable.Fields[I].DBTypeStr());
      if (NewTable.Fields[I].NullAllowed) then
        ListItem.SubItems.Add(Preferences.LoadStr(74))
      else
        ListItem.SubItems.Add(Preferences.LoadStr(75));
      if (NewTable.Fields[I].FieldKind = mkReal) then
      begin
        if (NewTable.Fields[I].AutoIncrement) then
          ListItem.SubItems.Add('<auto_increment>')
        else if (NewTable.Fields[I].Default = 'NULL') then
          ListItem.SubItems.Add('<' + Preferences.LoadStr(71) + '>')
        else if (NewTable.Fields[I].Default = 'CURRENT_TIMESTAMP') then
          ListItem.SubItems.Add('<INSERT-TimeStamp>')
        else
          ListItem.SubItems.Add(NewTable.Fields[I].UnescapeValue(NewTable.Fields[I].Default));
        if (not (NewTable.Fields[I].FieldType in TextFieldTypes)) then
          S := ''
        else
        begin
          if (NewTable.Fields[I].Charset = NewTable.Charset) then
            S := ''
          else
            S := NewTable.Fields[I].Charset;
          if (NewTable.Fields[I].Collation <> NewTable.Collation) then
          begin
            if (S <> '') then S := S + ', ';
            S := S + NewTable.Fields[I].Collation;
          end;
        end;
        ListItem.SubItems.Add(S);
        if (NewTable.Session.Connection.MySQLVersion >= 40100) then
          ListItem.SubItems.Add(NewTable.Fields[I].Comment);
        ListItem.ImageIndex := iiBaseField;
      end
      else if (NewTable.Fields[I].FieldKind = mkVirtual) then
      begin
        ListItem.SubItems.Add(NewTable.Fields[I].Expression);
        ListItem.SubItems.Add('');
        ListItem.SubItems.Add(NewTable.Fields[I].Comment);
        ListItem.ImageIndex := iiBaseField;
      end;
    end;

  FListSelectItem(FFields, FFields.Selected, Assigned(FFields.Selected));

  FFields.OnChange := TempOnChange;
end;

procedure TDTable.TSForeignKeysShow(Sender: TObject);
var
  I: Integer;
  ListItem: TListItem;
  S: string;
  S2: string;
  TempOnChange: TLVChangeEvent;
begin
  TempOnChange := FForeignKeys.OnChange;
  FForeignKeys.OnChange := nil;

  mlDCreate.Action := aPCreateForeignKey;
  mlDDelete.Action := aPDeleteForeignKey;
  mlDProperties.Action := aPEditForeignKey;

  mlDCreate.Caption := Preferences.LoadStr(26) + '...';
  mlDDelete.Caption := Preferences.LoadStr(28);

  mlDCreate.ShortCut := VK_INSERT;
  mlDDelete.ShortCut := VK_DELETE;

  if (FForeignKeys.Items.Count = 0) then
    for I := 0 to NewTable.ForeignKeys.Count - 1 do
    begin
      ListItem := FForeignKeys.Items.Add();
      ListItem.Caption := NewTable.ForeignKeys[I].Name;
      ListItem.SubItems.Add(NewTable.ForeignKeys[I].DBTypeStr());

      S := '';
      if (NewTable.ForeignKeys[I].OnDelete = dtCascade) then S := 'cascade on delete';
      if (NewTable.ForeignKeys[I].OnDelete = dtSetNull) then S := 'set NULL on delete';
      if (NewTable.ForeignKeys[I].OnDelete = dtSetDefault) then S := 'set default on delete';
      if (NewTable.ForeignKeys[I].OnDelete = dtNoAction) then S := 'no action on delete';

      S2 := '';
      if (NewTable.ForeignKeys[I].OnUpdate = utCascade) then S2 := 'cascade on update';
      if (NewTable.ForeignKeys[I].OnUpdate = utSetNull) then S2 := 'set NULL on update';
      if (NewTable.ForeignKeys[I].OnUpdate = utSetDefault) then S2 := 'set default on update';
      if (NewTable.ForeignKeys[I].OnUpdate = utNoAction) then S2 := 'no action on update';

      if (S <> '') and (S2 <> '') then S := S + ', ';
      S := S + S2;
      ListItem.SubItems.Add(S);

      ListItem.ImageIndex := iiForeignKey;
    end;

  FListSelectItem(FForeignKeys, FForeignKeys.Selected, Assigned(FForeignKeys.Selected));

  FForeignKeys.OnChange := TempOnChange;
end;

procedure TDTable.TSKeysShow(Sender: TObject);
var
  FieldNames: string;
  I: Integer;
  J: Integer;
  ListItem: TListItem;
  TempOnChange: TLVChangeEvent;
begin
  TempOnChange := FKeys.OnChange;
  FKeys.OnChange := nil;

  mlDCreate.Action := aPCreateKey;
  mlDDelete.Action := aPDeleteKey;
  mlDProperties.Action := aPEditKey;

  mlDCreate.Caption := Preferences.LoadStr(26) + '...';
  mlDDelete.Caption := Preferences.LoadStr(28);
  mlDCreate.ShortCut := VK_INSERT;
  mlDDelete.ShortCut := VK_DELETE;

  if (FKeys.Items.Count = 0) then
    for I := 0 to NewTable.Keys.Count - 1 do
    begin
      ListItem := FKeys.Items.Add();
      ListItem.Caption := NewTable.Keys[I].Caption;
      FieldNames := '';
      for J := 0 to NewTable.Keys[I].Columns.Count - 1 do
      begin
        if (FieldNames <> '') then FieldNames := FieldNames + ',';
        FieldNames := FieldNames + NewTable.Keys[I].Columns[J].Field.Name;
      end;
      ListItem.SubItems.Add(FieldNames);
      if (NewTable.Keys[I].Unique) then
        ListItem.SubItems.Add('unique')
      else if (NewTable.Keys[I].Fulltext) then
        ListItem.SubItems.Add('fulltext')
      else
        ListItem.SubItems.Add('');
      if (Database.Session.Connection.MySQLVersion >= 50503) then
        ListItem.SubItems.Add(NewTable.Keys[I].Comment);
      ListItem.ImageIndex := iiKey;
    end;

  FListSelectItem(FKeys, FKeys.Selected, Assigned(FKeys.Selected));

  FKeys.OnChange := TempOnChange;
end;

procedure TDTable.TSInformationShow(Sender: TObject);
begin
  if (not Table.Update(True)) then
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
    GRecordCount.Cursor := crSQLWait;
    FRecordCount.Caption := '';
  end
  else
    BuiltStatus();
end;

procedure TDTable.TSPartitionsShow(Sender: TObject);
begin
  mlDCreate.Action := aPCreatePartition;
  mlDDelete.Action := aPDeletePartition;
  mlDProperties.Action := aPEditPartition;

  mlDCreate.Caption := Preferences.LoadStr(26) + '...';
  mlDDelete.Caption := Preferences.LoadStr(28);
  mlDCreate.ShortCut := VK_INSERT;
  mlDDelete.ShortCut := VK_DELETE;

  FListSelectItem(FPartitions, FPartitions.Selected, Assigned(FPartitions.Selected));
end;

procedure TDTable.TSDependenciesShow(Sender: TObject);
var
  List: TList;
begin
  if (FDependencies.Items.Count = 0) then
  begin
    List := TList.Create();
    List.Add(Table.DependenciesSearch);
    if (not Database.Session.Update(List)) then
    begin
      SessionState := ssDependencies;
      FDependencies.Cursor := crSQLWait;
    end
    else
      BuiltDependencies();
    List.Free();
  end;
end;

procedure TDTable.TSSourceShow(Sender: TObject);
begin
  if (FSource.Lines.Count = 0) then
    if (Assigned(NewTable)) then
      FSource.Text := NewTable.Source;
end;

procedure TDTable.TSTriggersShow(Sender: TObject);
var
  I: Integer;
  ListItem: TListItem;
  S: string;
  TempOnChange: TLVChangeEvent;
begin
  TempOnChange := FTriggers.OnChange;
  FTriggers.OnChange := nil;

  mlDCreate.Action := aPCreateTrigger;
  mlDDelete.Action := aPDeleteTrigger;
  mlDProperties.Action := aPEditTrigger;

  mlDCreate.Caption := Preferences.LoadStr(26) + '...';
  mlDDelete.Caption := Preferences.LoadStr(28);
  mlDCreate.ShortCut := VK_INSERT;
  mlDDelete.ShortCut := VK_DELETE;

  if (FTriggers.Items.Count = 0) then
    for I := 0 to NewTable.Database.Triggers.Count - 1 do
      if (NewTable.Database.Triggers[I].TableName = NewTable.Name) then
      begin
        ListItem := FTriggers.Items.Add();
        ListItem.ImageIndex := iiTrigger;
        ListItem.Caption := NewTable.Database.Triggers[I].Name;
        S := '';
        case (NewTable.Database.Triggers[I].Timing) of
          ttBefore: S := S + 'before ';
          ttAfter: S := S + 'after ';
        end;
        case (NewTable.Database.Triggers[I].Event) of
          teInsert: S := S + 'insert';
          teUpdate: S := S + 'update';
          teDelete: S := S + 'delete';
        end;
        ListItem.SubItems.Add(S);
      end;

  FListSelectItem(FTriggers, FTriggers.Selected, Assigned(FTriggers.Selected));

  FTriggers.OnChange := TempOnChange;
end;

procedure TDTable.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiBaseTable, Icon);

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  aPUp.Caption := Preferences.LoadStr(563);
  aPDown.Caption := Preferences.LoadStr(564);

  TSBasics.Caption := Preferences.LoadStr(108);
  GBasics.Caption := Preferences.LoadStr(85);
  FLName.Caption := Preferences.LoadStr(35) + ':';
  FLEngine.Caption := Preferences.LoadStr(110) + ':';
  FLCharset.Caption := Preferences.LoadStr(682) + ':';
  FLCollation.Caption := Preferences.LoadStr(702) + ':';
  FLComment.Caption := Preferences.LoadStr(111) + ':';
  GRecords.Caption := Preferences.LoadStr(124);
  FLAutoIncrement.Caption := Preferences.LoadStr(117) + ':';
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

  TSFields.Caption := Preferences.LoadStr(253);
  tbCreateField.Hint := Preferences.LoadStr(87) + '...';
  tbDeleteField.Hint := Preferences.LoadStr(28);
  tbPropertiesField.Hint := Preferences.LoadStr(97) + '...';
  tbFieldUp.Hint := Preferences.LoadStr(545);
  tbFieldDown.Hint := Preferences.LoadStr(547);
  FFields.Column[0].Caption := Preferences.LoadStr(35);
  FFields.Column[1].Caption := Preferences.LoadStr(69);
  FFields.Column[2].Caption := Preferences.LoadStr(71);
  FFields.Column[3].Caption := Preferences.LoadStr(72);
  FFields.Column[4].Caption := Preferences.LoadStr(73);
  FFields.Column[5].Caption := Preferences.LoadStr(111);

  TSKeys.Caption := Preferences.LoadStr(458);
  tbCreateKey.Hint := Preferences.LoadStr(160) + '...';
  tbDeleteKey.Hint := Preferences.LoadStr(28);
  tbPropertiesKey.Hint := Preferences.LoadStr(97) + '...';
  FKeys.Column[0].Caption := Preferences.LoadStr(35);
  FKeys.Column[1].Caption := Preferences.LoadStr(69);
  FKeys.Column[2].Caption := Preferences.LoadStr(73);
  FKeys.Column[3].Caption := Preferences.LoadStr(111);

  TSForeignKeys.Caption := Preferences.LoadStr(459);
  tbCreateForeignKey.Hint := Preferences.LoadStr(249) + '...';
  tbDeleteForeignKey.Hint := Preferences.LoadStr(28);
  tbPropertiesForeignKey.Hint := Preferences.LoadStr(97) + '...';
  FForeignKeys.Column[0].Caption := Preferences.LoadStr(35);
  FForeignKeys.Column[1].Caption := Preferences.LoadStr(69);
  FForeignKeys.Column[2].Caption := Preferences.LoadStr(73);

  TSTriggers.Caption := Preferences.LoadStr(797);
  FTriggers.Column[0].Caption := Preferences.LoadStr(35);
  FTriggers.Column[1].Caption := Preferences.LoadStr(69);

  TSDependencies.Caption := Preferences.LoadStr(782);
  FDependencies.Column[0].Caption := Preferences.LoadStr(35);
  FDependencies.Column[1].Caption := Preferences.LoadStr(69);

  TSPartitions.Caption := Preferences.LoadStr(830);
  GPartitions.Caption := Preferences.LoadStr(85);
  FLPartitionType.Caption := Preferences.LoadStr(110) + ':';
  FPartitionType.Items.Clear();
  FPartitionType.Items.Add('<' + Preferences.LoadStr(912) + '>');
  FPartitionType.Items.Add(Preferences.LoadStr(831));
  FPartitionType.Items.Add(Preferences.LoadStr(832));
  FPartitionType.Items.Add(Preferences.LoadStr(833));
  FPartitionType.Items.Add(Preferences.LoadStr(834));
  FLinear.Caption := Preferences.LoadStr(835);
  FLPartitionExpr.Caption := Preferences.LoadStr(836) + ':';
  FLPartitionsNumber.Caption := Preferences.LoadStr(617) + ':';
  FLPartitions.Caption := Preferences.LoadStr(830) + ':';
//  tbPartitionUp.Hint := Preferences.LoadStr(545);
//  tbPartitionDown.Hint := Preferences.LoadStr(547);
  FPartitions.Column[0].Caption := Preferences.LoadStr(35);
  FPartitions.Column[1].Caption := Preferences.LoadStr(836);
  FPartitions.Column[2].Caption := Preferences.LoadStr(837);
  FPartitions.Column[3].Caption := Preferences.LoadStr(838);
  FPartitions.Column[4].Caption := Preferences.LoadStr(111);

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
  Preferences.ApplyToSynMemo(FSource);

  aPCreateKey.Caption := Preferences.LoadStr(26) + '...';
  aPDeleteKey.Caption := Preferences.LoadStr(28);
  aPEditKey.Caption := Preferences.LoadStr(97) + '...';
  aPCreateField.Caption := Preferences.LoadStr(26) + '...';
  aPDeleteField.Caption := Preferences.LoadStr(28);
  aPEditField.Caption := Preferences.LoadStr(97) + '...';
  aPCreateForeignKey.Caption := Preferences.LoadStr(26) + '...';
  aPDeleteForeignKey.Caption := Preferences.LoadStr(28);
  aPEditForeignKey.Caption := Preferences.LoadStr(97) + '...';
  aPCreateTrigger.Caption := Preferences.LoadStr(26) + '...';
  aPDeleteTrigger.Caption := Preferences.LoadStr(28);
  aPEditTrigger.Caption := Preferences.LoadStr(97) + '...';
  aPCreatePartition.Caption := Preferences.LoadStr(26) + '...';
  aPDeletePartition.Caption := Preferences.LoadStr(28);
  aPEditPartition.Caption := Preferences.LoadStr(97) + '...';

  FBHelp.Caption := Preferences.LoadStr(167);
  FBOk.Caption := Preferences.LoadStr(29);
end;

initialization
  FDTable := nil;
end.

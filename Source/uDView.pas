unit uDView;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, ActnList, Menus, ExtCtrls,
  BCEditor,
  Forms_Ext, StdCtrls_Ext,
  uSession,
  uBase, BCEditor.Highlighter;

type
  TDView = class(TForm_Ext)
    FAlgorithm: TComboBox;
    FBCancel: TButton;
    FBHelp: TButton;
    FBOk: TButton;
    FCheckOption: TCheckBox;
    FCheckOptionCascade: TCheckBox;
    FCheckOptionLocal: TCheckBox;
    FDefiner: TLabel;
    FDependencies: TListView;
    FFields: TListView;
    FLAlgorithm: TLabel;
    FLCheckOption: TLabel;
    FLDefiner: TLabel;
    FLName: TLabel;
    FLSecurity: TLabel;
    FLStmt: TLabel;
    FName: TEdit;
    FSecurityDefiner: TRadioButton;
    FSecurityInvoker: TRadioButton;
    FSource: TBCEditor;
    FStatement: TBCEditor;
    GBasics: TGroupBox_Ext;
    GDefiner: TGroupBox_Ext;
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
    PSQLWait: TPanel;
    TSBasics: TTabSheet;
    TSDependencies: TTabSheet;
    TSFields: TTabSheet;
    TSInformation: TTabSheet;
    TSSource: TTabSheet;
    procedure FAlgorithmSelect(Sender: TObject);
    procedure FBHelpClick(Sender: TObject);
    procedure FCheckOptionCascadeClick(Sender: TObject);
    procedure FCheckOptionCascadeKeyPress(Sender: TObject; var Key: Char);
    procedure FCheckOptionClick(Sender: TObject);
    procedure FCheckOptionKeyPress(Sender: TObject; var Key: Char);
    procedure FCheckOptionLocalClick(Sender: TObject);
    procedure FCheckOptionLocalKeyPress(Sender: TObject; var Key: Char);
    procedure FNameChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FSecurityClick(Sender: TObject);
    procedure FSecurityKeyPress(Sender: TObject; var Key: Char);
    procedure FSourceSelectionChanged(Sender: TObject);
    procedure TSDependenciesShow(Sender: TObject);
    procedure FStatementChange(Sender: TObject);
    procedure FSourceChange(Sender: TObject);
  private
    RecordCount: Integer;
    SessionState: (ssCreate, ssInit, ssDependencies, ssValid, ssAlter);
    procedure Built();
    procedure BuiltDependencies();
    procedure FBOkCheckEnabled(Sender: TObject);
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Database: TSDatabase;
    View: TSView;
    function Execute(): Boolean;
  end;

function DView(): TDView;

implementation {***************************************************************}

{$R *.dfm}

uses
  StrUtils, SysConst,
  SQLUtils,
  uPreferences;

var
  FDView: TDView;

function DView(): TDView;
begin
  if (not Assigned(FDView)) then
  begin
    Application.CreateForm(TDView, FDView);
    FDView.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDView;
end;

{ TDView **********************************************************************}

procedure TDView.Built();
var
  I: Integer;
  Item: TListItem;
  ViewField: TSViewField;
begin
  FName.Text := View.Name;

  case (View.Algorithm) of
    vaUndefined: FAlgorithm.ItemIndex := 0;
    vaMerge: FAlgorithm.ItemIndex := 1;
    vaTemptable: FAlgorithm.ItemIndex := 2;
    else FAlgorithm.Text := '';
  end;

  case (View.Security) of
    seDefiner: FSecurityDefiner.Checked := True;
    seInvoker: FSecurityInvoker.Checked := True;
  end;

  FCheckOption.Checked := View.CheckOption <> voNone;
  FCheckOptionCascade.Checked := View.CheckOption = voCascaded;
  FCheckOptionLocal.Checked := View.CheckOption = voLocal;

  FStatement.Text := View.Stmt;

  FDefiner.Caption := View.Definer;

  FFields.Items.BeginUpdate();
  for I := 0 to View.Fields.Count - 1 do
  begin
    ViewField := TSViewField(View.Fields[I]);
    Item := FFields.Items.Add();
    Item.Caption := ViewField.Name;
    if (ViewField.FieldType <> mfUnknown) then
    begin
      Item.SubItems.Add(ViewField.DBTypeStr());
      if (ViewField.NullAllowed) then
        Item.SubItems.Add(Preferences.LoadStr(74))
      else
        Item.SubItems.Add(Preferences.LoadStr(75));
      if (ViewField.AutoIncrement) then
        Item.SubItems.Add('<auto_increment>')
      else
        Item.SubItems.Add(ViewField.Default);
      if ((ViewField.Charset <> '') and (ViewField.Charset <> View.Database.Charset)) then
        Item.SubItems.Add(ViewField.Charset);
    end;
    Item.ImageIndex := iiViewField;
  end;
  FFields.Items.EndUpdate();

  FSource.Text := View.Source;

  TSSource.TabVisible := Assigned(View) and (View.Source <> '');
end;

procedure TDView.BuiltDependencies();

  procedure AddDBObject(const DBObject: TSDBObject);
  var
    I: Integer;
    Item: TListItem;
  begin
    for I := 0 to DBObject.References.Count - 1 do
      if (DBObject.References[I].DBObject = View) then
      begin
        Item := FDependencies.Items.Add();

        if (DBObject is TSView) then
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
    if (Database.Tables[I] <> View) then
      AddDBObject(Database.Tables[I]);

  if (Assigned(Database.Routines)) then
    for I := 0 to Database.Routines.Count - 1 do
      AddDBObject(Database.Routines[I]);

  if (Assigned(Database.Triggers)) then
    for I := 0 to Database.Triggers.Count - 1 do
      AddDBObject(Database.Triggers[I]);

  if (Assigned(Database.Events)) then
    for I := 0 to Database.Events.Count - 1 do
      AddDBObject(Database.Events[I]);

  FDependencies.Items.EndUpdate();
end;

function TDView.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDView.FAlgorithmSelect(Sender: TObject);
begin
  FBOkCheckEnabled(Sender);
  TSSource.TabVisible := False;
end;

procedure TDView.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDView.FBOkCheckEnabled(Sender: TObject);
var
  I: Integer;
  Parse: TSQLParse;
begin
  FBOk.Enabled := PageControl.Visible
    and (FName.Text <> '')
    and SQLSingleStmt(FStatement.Text) and SQLCreateParse(Parse, PChar(FStatement.Text), Length(FStatement.Text), Database.Session.Connection.MySQLVersion) and SQLParseKeyword(Parse, 'SELECT');
  for I := 0 to Database.Tables.Count - 1 do
    if (Database.Session.TableNameCmp(FName.Text, Database.Tables[I].Name) = 0) and not (not Assigned(View) or (Database.Session.TableNameCmp(FName.Text, View.Name) = 0)) then
      FBOk.Enabled := False;
end;

procedure TDView.FCheckOptionCascadeClick(Sender: TObject);
begin
  if (FCheckOptionCascade.Checked) then
  begin
    FCheckOption.Checked := True;
    FCheckOptionLocal.Checked := False;
  end;

  FBOkCheckEnabled(Sender);
  TSSource.TabVisible := False;
end;

procedure TDView.FCheckOptionCascadeKeyPress(Sender: TObject;
  var Key: Char);
begin
  FCheckOptionCascadeClick(Sender);
end;

procedure TDView.FCheckOptionClick(Sender: TObject);
begin
  if (not FCheckOption.Checked) then
  begin
    FCheckOptionCascade.Checked := False;
    FCheckOptionLocal.Checked := False;
  end;

  FBOkCheckEnabled(Sender);
  TSSource.TabVisible := False;
end;

procedure TDView.FCheckOptionKeyPress(Sender: TObject; var Key: Char);
begin
  FCheckOptionClick(Sender);
end;

procedure TDView.FCheckOptionLocalClick(Sender: TObject);
begin
  if (FCheckOptionLocal.Checked) then
  begin
    FCheckOption.Checked := True;
    FCheckOptionCascade.Checked := False;
  end;

  FBOkCheckEnabled(Sender);
  TSSource.TabVisible := False;
end;

procedure TDView.FCheckOptionLocalKeyPress(Sender: TObject; var Key: Char);
begin
  FCheckOptionLocalClick(Sender);
end;

procedure TDView.FNameChange(Sender: TObject);
begin
  FBOkCheckEnabled(Sender);
  TSSource.TabVisible := False;
end;

procedure TDView.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  NewView: TSView;
begin
  if ((ModalResult = mrOk) and PageControl.Visible) then
  begin
    NewView := TSView.Create(Database.Tables);
    if (Assigned(View)) then
      NewView.Assign(View);

    NewView.Name := Trim(FName.Text);
    case (FAlgorithm.ItemIndex) of
      0: NewView.Algorithm := vaUndefined;
      1: NewView.Algorithm := vaMerge;
      2: NewView.Algorithm := vaTemptable;
    end;
    if (FSecurityDefiner.Checked) then
      NewView.Security := seDefiner
    else if (FSecurityInvoker.Checked) then
      NewView.Security := seInvoker;
    if (not FCheckOption.Checked) then
      NewView.CheckOption := voNone
    else if (FCheckOptionCascade.Checked) then
      NewView.CheckOption := voCascaded
    else if (FCheckOptionLocal.Checked) then
      NewView.CheckOption := voLocal
    else
      NewView.CheckOption := voDefault;
    NewView.Stmt := Trim(FStatement.Text);

    SessionState := ssAlter;

    if (not Assigned(View)) then
      CanClose := Database.AddView(NewView)
    else
      CanClose := Database.UpdateView(View, NewView);

    NewView.Free();

    PageControl.Visible := False;
    PSQLWait.Visible := not PageControl.Visible;
    FBOk.Enabled := False;
  end;
end;

procedure TDView.FormCreate(Sender: TObject);
begin
  FFields.SmallImages := Preferences.Images;

  FStatement.Highlighter.LoadFromResource('Highlighter', RT_RCDATA);
  FStatement.Highlighter.Colors.LoadFromResource('Colors', RT_RCDATA);
  FDependencies.SmallImages := Preferences.Images;
  FSource.Highlighter.LoadFromResource('Highlighter', RT_RCDATA);
  FSource.Highlighter.Colors.LoadFromResource('Colors', RT_RCDATA);

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  msUndo.Action := aEUndo; msCut.ShortCut := 0;
  msCut.Action := aECut; msCut.ShortCut := 0;
  msCopy.Action := aECopy; msCopy.ShortCut := 0;
  msPaste.Action := aEPaste; msPaste.ShortCut := 0;
  msDelete.Action := aEDelete; msDelete.ShortCut := 0;
  msSelectAll.Action := aESelectAll; msSelectAll.ShortCut := 0;

  PageControl.ActivePage := TSBasics;

  FDependencies.RowSelect := CheckWin32Version(6);
end;

procedure TDView.FormHide(Sender: TObject);
begin
  Database.Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.View.Width := Width;
  Preferences.View.Height := Height;

  FStatement.Lines.Clear();

  FFields.Items.BeginUpdate();
  FFields.Items.Clear();
  FFields.Items.EndUpdate();
  FDependencies.Items.BeginUpdate();
  FDependencies.Items.Clear();
  FDependencies.Items.EndUpdate();

  FSource.Lines.Clear();

  PageControl.ActivePage := TSBasics;
end;

procedure TDView.FormSessionEvent(const Event: TSSession.TEvent);
var
  FirstValid: Boolean;
begin
  FirstValid := SessionState = ssInit;

  if ((SessionState = ssInit) and (Event.EventType = etError)) then
    ModalResult := mrCancel
  else if ((SessionState in [ssInit, ssDependencies]) and (Event.EventType = etItemValid) and (Event.Item = View)) then
  begin
    if (SessionState = ssInit) then
      Built()
    else
      BuiltDependencies();
    SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType = etError)) then
  begin
    if (not Assigned(View)) then
      SessionState := ssCreate
    else
      SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType in [etItemValid, etItemCreated, etItemRenamed])) then
    ModalResult := mrOk;

  if (SessionState in [ssCreate, ssValid]) then
  begin
    FDependencies.Cursor := crDefault;

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

procedure TDView.FormShow(Sender: TObject);
var
  TableName: string;
begin
  Database.Session.RegisterEventProc(FormSessionEvent);

  if ((Preferences.View.Width >= Width) and (Preferences.View.Height >= Height)) then
  begin
    Width := Preferences.View.Width;
    Height := Preferences.View.Height;
  end;

  if (not Assigned(View)) then
  begin
    Caption := Preferences.LoadStr(741);
    HelpContext := 1096;
  end
  else
  begin
    Caption := Preferences.LoadStr(842, View.Name);
    HelpContext := 1098;
  end;

  FStatement.Lines.Clear();
  Database.Session.ApplyToBCEditor(FStatement);
  FSource.Lines.Clear();
  Database.Session.ApplyToBCEditor(FSource);

  if (not Assigned(View) and (Database.Session.LowerCaseTableNames = 1)) then
    FName.CharCase := ecLowerCase
  else
    FName.CharCase := ecNormal;

  RecordCount := -1;

  if (not Assigned(View)) then
    SessionState := ssCreate
  else if (not View.Valid and not View.Update()) then
    SessionState := ssInit
  else
    SessionState := ssValid;

  if (not Assigned(View)) then
  begin
    FName.Text := Preferences.LoadStr(747);
    while (not Assigned(View) and Assigned(Database.TableByName(FName.Text))) do
    begin
      TableName := FName.Text;
      Delete(TableName, 1, Length(Preferences.LoadStr(747)));
      if (TableName = '') then TableName := '1';
      TableName := Preferences.LoadStr(747) + IntToStr(StrToInt(TableName) + 1);
      FName.Text := TableName;
    end;

    FAlgorithm.ItemIndex := 0;

    FSecurityDefiner.Checked := True;

    FCheckOption.Checked := False;
    FCheckOptionCascade.Checked := False;
    FCheckOptionLocal.Checked := False;

    FStatement.Text := 'SELECT 1;';

    TSSource.TabVisible := False;
  end
  else
  begin
    if (SessionState = ssValid) then
      Built();
  end;

  FDependencies.Cursor := crDefault;

  TSInformation.TabVisible := Assigned(View);
  TSFields.TabVisible := Assigned(View);
  TSDependencies.TabVisible := Assigned(View);

  PageControl.Visible := SessionState in [ssCreate, ssValid];
  PSQLWait.Visible := not PageControl.Visible;

  FBOk.Enabled := PageControl.Visible and not Assigned(View);

  ActiveControl := FBCancel;
  if (PageControl.Visible) then
    ActiveControl := FName;
end;

procedure TDView.FSecurityClick(Sender: TObject);
begin
  FBOkCheckEnabled(Sender);
  TSSource.TabVisible := False;
end;

procedure TDView.FSecurityKeyPress(Sender: TObject; var Key: Char);
begin
  FSecurityClick(Sender);
end;

procedure TDView.FSourceChange(Sender: TObject);
begin
  if (Visible) then
    TSFields.TabVisible := False;
end;

procedure TDView.FSourceSelectionChanged(Sender: TObject);
begin
  aECopyToFile.Enabled := FSource.SelText <> '';
end;

procedure TDView.FStatementChange(Sender: TObject);
begin
  FBOkCheckEnabled(Sender);
  TSFields.TabVisible := False;
  TSSource.TabVisible := False;
end;

procedure TDView.TSDependenciesShow(Sender: TObject);
var
  List: TList;
begin
  if (FDependencies.Items.Count = 0) then
  begin
    List := TList.Create();
    List.Add(View.DependenciesSearch);
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

procedure TDView.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiView, Icon);

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  TSBasics.Caption := Preferences.LoadStr(108);
  GBasics.Caption := Preferences.LoadStr(85);
  FLName.Caption := Preferences.LoadStr(35) + ':';
  FLAlgorithm.Caption := Preferences.LoadStr(743) + ':';
  FAlgorithm.Items.Add('<' + Preferences.LoadStr(744) + '>');
  FAlgorithm.Items.Add(Preferences.LoadStr(745));
  FAlgorithm.Items.Add(Preferences.LoadStr(318));
  FLSecurity.Caption := Preferences.LoadStr(798) + ':';
  FSecurityDefiner.Caption := Preferences.LoadStr(799);
  FSecurityInvoker.Caption := Preferences.LoadStr(561);
  FLCheckOption.Caption := Preferences.LoadStr(248) + ':';
  FCheckOption.Caption := Preferences.LoadStr(529);
  FCheckOptionCascade.Caption := Preferences.LoadStr(256);
  FCheckOptionLocal.Caption := Preferences.LoadStr(746);
  FLStmt.Caption := Preferences.LoadStr(307) + ':';

  Preferences.ApplyToBCEditor(FStatement);

  TSInformation.Caption := Preferences.LoadStr(121);
  GDefiner.Caption := Preferences.LoadStr(561);
  FLDefiner.Caption := Preferences.LoadStr(799) + ':';

  TSFields.Caption := Preferences.LoadStr(253);
  FFields.Column[0].Caption := Preferences.LoadStr(35);
  FFields.Column[1].Caption := Preferences.LoadStr(69);
  FFields.Column[2].Caption := Preferences.LoadStr(71);
  FFields.Column[3].Caption := Preferences.LoadStr(72);
  FFields.Column[4].Caption := Preferences.LoadStr(73);
  FFields.Column[5].Caption := Preferences.LoadStr(111);

  TSDependencies.Caption := Preferences.LoadStr(782);
  FDependencies.Column[0].Caption := Preferences.LoadStr(35);
  FDependencies.Column[1].Caption := Preferences.LoadStr(69);

  TSSource.Caption := Preferences.LoadStr(198);
  Preferences.ApplyToBCEditor(FSource);

  FBHelp.Caption := Preferences.LoadStr(167);
  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDView := nil;
end.

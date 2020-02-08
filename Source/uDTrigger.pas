unit uDTrigger;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, ActnList, Menus, ExtCtrls,
  SynEdit, SynMemo,
  Forms_Ext, ExtCtrls_Ext, StdCtrls_Ext,
  uSession,
  uBase;

type
  TDTrigger = class(TForm_Ext)
    FAfter: TRadioButton;
    FBCancel: TButton;
    FBefore: TRadioButton;
    FBHelp: TButton;
    FBOk: TButton;
    FDefiner: TLabel;
    FDelete: TRadioButton;
    FInsert: TRadioButton;
    FLDefiner: TLabel;
    FLEvent: TLabel;
    FLName: TLabel;
    FLSize: TLabel;
    FLStatement: TLabel;
    FLTiming: TLabel;
    FName: TEdit;
    FReferences: TListView;
    FSize: TLabel;
    FSource: TSynMemo;
    FStatement: TSynMemo;
    FUpdate: TRadioButton;
    GBasics: TGroupBox_Ext;
    GDefiner: TGroupBox_Ext;
    GSize: TGroupBox_Ext;
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
    PEvent: TPanel_Ext;
    PSQLWait: TPanel;
    PTiming: TPanel_Ext;
    TSBasics: TTabSheet;
    TSInformation: TTabSheet;
    TSReferences: TTabSheet;
    TSSource: TTabSheet;
    procedure FBHelpClick(Sender: TObject);
    procedure FEventClick(Sender: TObject);
    procedure FEventKeyPress(Sender: TObject; var Key: Char);
    procedure FNameChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FStatementChange(Sender: TObject);
    procedure FTableNameChange(Sender: TObject);
    procedure FTimingClick(Sender: TObject);
    procedure FTimingKeyPress(Sender: TObject; var Key: Char);
    procedure HideTSSource(Sender: TObject);
    procedure TSReferencesShow(Sender: TObject);
  private
    SessionState: (ssCreate, ssInit, ssValid, ssAlter);
    procedure Built();
    procedure FBOkCheckEnabled(Sender: TObject);
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Table: TSBaseTable;
    Trigger: TSTrigger;
    function Execute(): Boolean;
  end;

function DTrigger(): TDTrigger;

implementation {***************************************************************}

{$R *.dfm}

uses
  StrUtils, SysConst,
  SQLUtils,
  uPreferences;

var
  FDTrigger: TDTrigger;

function DTrigger(): TDTrigger;
begin
  if (not Assigned(FDTrigger)) then
  begin
    Application.CreateForm(TDTrigger, FDTrigger);
    FDTrigger.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDTrigger;
end;

{ TDTrigger *******************************************************************}

procedure TDTrigger.Built();
begin
  FName.Text := Trigger.Name;

  FBefore.Checked := Trigger.Timing = ttBefore;
  FAfter.Checked := Trigger.Timing = ttAfter;
  FInsert.Checked := Trigger.Event = teInsert;
  FUpdate.Checked := Trigger.Event = teUpdate;
  FDelete.Checked := Trigger.Event = teDelete;
  FStatement.Text := Trigger.Stmt + #13#10;

  FDefiner.Caption := Trigger.Definer;
  FSize.Caption := FormatFloat('#,##0', Length(Trigger.Source), LocaleFormatSettings);

  FSource.Text := Trigger.Source;

  TSSource.TabVisible := FSource.Text <> '';
end;

function TDTrigger.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDTrigger.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDTrigger.FBOkCheckEnabled(Sender: TObject);
var
  I: Integer;
begin
  FBOk.Enabled := (FName.Text <> '') and SQLSingleStmt(FStatement.Text)
    and (not Assigned(Table.Database.TriggerByName(FName.Text)) or (Assigned(Trigger) and (((Table.Database.Session.LowerCaseTableNames = 0) and (FName.Text = Trigger.Name)) or ((Table.Database.Session.LowerCaseTableNames > 0) and ((lstrcmpi(PChar(FName.Text), PChar(Trigger.Name)) = 0))))));
  for I := 0 to Table.Database.Triggers.Count - 1 do
    if (lstrcmpi(PChar(FName.Text), PChar(Table.Database.Triggers[I].Name)) = 0) and not (not Assigned(Trigger) or (lstrcmpi(PChar(FName.Text), PChar(Trigger.Name)) = 0)) then
      FBOk.Enabled := False;
end;

procedure TDTrigger.FEventClick(Sender: TObject);
begin
  FBOkCheckEnabled(Sender);
  HideTSSource(Sender);
end;

procedure TDTrigger.FEventKeyPress(Sender: TObject; var Key: Char);
begin
  FEventClick(Sender);
end;

procedure TDTrigger.FNameChange(Sender: TObject);
begin
  FBOkCheckEnabled(Sender);
  HideTSSource(Sender);
end;

procedure TDTrigger.FormSessionEvent(const Event: TSSession.TEvent);
var
  FirstValid: Boolean;
begin
  FirstValid := SessionState = ssInit;

  if ((SessionState = ssInit) and (Event.EventType = etError)) then
    ModalResult := mrCancel
  else if ((SessionState in [ssInit]) and (Event.EventType = etItemValid) and (Event.Item = Trigger)) then
  begin
    Built();
    SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType = etError)) then
  begin
    if (not Assigned(Trigger)) then
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

procedure TDTrigger.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  NewTrigger: TSTrigger;
begin
  if ((ModalResult = mrOk) and PageControl.Visible) then
  begin
    NewTrigger := TSTrigger.Create(Table.Database.Triggers);
    if (Assigned(Trigger)) then
      NewTrigger.Assign(Trigger);

    NewTrigger.Name := FName.Text;
    NewTrigger.DatabaseName := Table.Database.Name;
    NewTrigger.TableName := Table.Name;
    if (FBefore.Checked) then NewTrigger.Timing := ttBefore;
    if (FAfter.Checked) then NewTrigger.Timing := ttAfter;
    if (FInsert.Checked) then NewTrigger.Event := teInsert;
    if (FUpdate.Checked) then NewTrigger.Event := teUpdate;
    if (FDelete.Checked) then NewTrigger.Event := teDelete;
    NewTrigger.Stmt := Trim(FStatement.Text);

    SessionState := ssAlter;
    if (not Assigned(Trigger)) then
      CanClose := Table.Database.AddTrigger(NewTrigger)
    else
      CanClose := Table.Database.UpdateTrigger(Trigger, NewTrigger);

    NewTrigger.Free();

    PageControl.Visible := False;
    PSQLWait.Visible := not PageControl.Visible;

    FBOk.Enabled := False;
  end;
end;

procedure TDTrigger.FormCreate(Sender: TObject);
begin
  FStatement.Highlighter := Preferences.Editor.Highlighter;
  FReferences.SmallImages := Preferences.Images;
  FSource.Highlighter := Preferences.Editor.Highlighter;

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
end;

procedure TDTrigger.FormHide(Sender: TObject);
begin
  Table.Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.Trigger.Width := Width;
  Preferences.Trigger.Height := Height;

  FReferences.Items.BeginUpdate();
  FReferences.Items.Clear();
  FReferences.Items.EndUpdate();

  PageControl.ActivePage := TSBasics;

end;

procedure TDTrigger.FormShow(Sender: TObject);
var
  TriggerName: string;
begin
  Table.Session.RegisterEventProc(FormSessionEvent);

  if ((Preferences.Trigger.Width >= Width) and (Preferences.Trigger.Height >= Height)) then
  begin
    Width := Preferences.Trigger.Width;
    Height := Preferences.Trigger.Height;
  end;

  if (not Assigned(Trigger)) then
  begin
    Caption := Preferences.LoadStr(795);
    HelpContext := 1097;
  end
  else
  begin
    Caption := Preferences.LoadStr(842, Trigger.Name);
    HelpContext := 1104;
  end;

  FStatement.Lines.Clear();
  FSource.Lines.Clear();

  if (not Assigned(Trigger)) then
    SessionState := ssCreate
  else if (not Trigger.Valid and not Trigger.Update()) then
    SessionState := ssInit
  else
    SessionState := ssValid;

  if (not Assigned(Trigger)) then
  begin
    FName.Text := Preferences.LoadStr(789);
    while (Assigned(Table.Database.TriggerByName(FName.Text))) do
    begin
      TriggerName := FName.Text;
      Delete(TriggerName, 1, Length(Preferences.LoadStr(789)));
      if (TriggerName = '') then TriggerName := '1';
      TriggerName := Preferences.LoadStr(789) + IntToStr(StrToInt(TriggerName) + 1);
      FName.Text := TriggerName;
    end;

    FBefore.Checked := True;
    FInsert.Checked := True;
    FStatement.Text := 'BEGIN' + #13#10 + '  SET @A = 1;' + #13#10 + 'END;';

    TSSource.TabVisible := False;
  end
  else
  begin
    if (SessionState = ssValid) then
      Built();
  end;

  TSInformation.TabVisible := Assigned(Trigger);

  PageControl.Visible := SessionState in [ssCreate, ssValid];
  PSQLWait.Visible := not PageControl.Visible;

  TSReferences.TabVisible := Assigned(Trigger);

  FBOk.Enabled := PageControl.Visible and not Assigned(Trigger);

  ActiveControl := FBCancel;
  if (PageControl.Visible) then
    ActiveControl := FName;
end;

procedure TDTrigger.FStatementChange(Sender: TObject);
begin
  FBOkCheckEnabled(Sender);
  HideTSSource(Sender);
  TSReferences.TabVisible := False;
end;

procedure TDTrigger.FTableNameChange(Sender: TObject);
begin
  FBOkCheckEnabled(Sender);
  HideTSSource(Sender);
end;

procedure TDTrigger.FTimingClick(Sender: TObject);
begin
  FBOkCheckEnabled(Sender);
  HideTSSource(Sender);
end;

procedure TDTrigger.FTimingKeyPress(Sender: TObject; var Key: Char);
begin
  FTimingClick(Sender);
end;

procedure TDTrigger.HideTSSource(Sender: TObject);
begin
  TSSource.TabVisible := False;
end;

procedure TDTrigger.TSReferencesShow(Sender: TObject);
var
  I: Integer;
  Item: TListItem;
begin
  if (FReferences.Items.Count = 0) then
  begin
    FReferences.Items.BeginUpdate();

    for I := 0 to Trigger.References.Count - 1 do
    begin
      Item := FReferences.Items.Add();

      if (Trigger.References[I].DatabaseName = Table.Database.Name) then
        Item.Caption := Trigger.References[I].DBObjectName
      else
        Item.Caption := Trigger.References[I].DatabaseName + '.' + Trigger.References[I].DBObjectName;

      if (Trigger.References[I].DBObjectClass = TSBaseTable) then
      begin
        Item.ImageIndex := iiBaseTable;
        Item.SubItems.Add(Preferences.LoadStr(302));
      end
      else if (Trigger.References[I].DBObjectClass = TSView) then
      begin
        Item.ImageIndex := iiView;
        Item.SubItems.Add(Preferences.LoadStr(738));
      end
      else if (Trigger.References[I].DBObjectClass = TSTable) then
      begin
        Item.ImageIndex := iiTable;
        Item.SubItems.Add(Preferences.LoadStr(302));
      end
      else if (Trigger.References[I].DBObjectClass = TSProcedure) then
      begin
        Item.ImageIndex := iiProcedure;
        Item.SubItems.Add(Preferences.LoadStr(768));
      end
      else if (Trigger.References[I].DBObjectClass = TSFunction) then
      begin
        Item.ImageIndex := iiFunction;
        Item.SubItems.Add(Preferences.LoadStr(769));
      end
      else
        raise ERangeError.Create(SRangeError);
    end;

    FReferences.Items.EndUpdate();
  end;
end;

procedure TDTrigger.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiTrigger, Icon);

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  TSBasics.Caption := Preferences.LoadStr(108);
  GBasics.Caption := Preferences.LoadStr(85);
  FLName.Caption := Preferences.LoadStr(35) + ':';
  FLTiming.Caption := Preferences.LoadStr(790) + ':';
  FBefore.Caption := Preferences.LoadStr(791);
  FAfter.Caption := Preferences.LoadStr(792);
  FLEvent.Caption := Preferences.LoadStr(793) + ':';
  FInsert.Caption := 'INSERT';
  FUpdate.Caption := 'UPDATE';
  FDelete.Caption := 'DELETE';
  FLStatement.Caption := Preferences.LoadStr(794) + ':';

  FInsert.Font.Name := Preferences.SQLFontName;
  FUpdate.Font.Name := Preferences.SQLFontName;
  FDelete.Font.Name := Preferences.SQLFontName;

  Preferences.ApplyToSynMemo(FStatement);

  TSInformation.Caption := Preferences.LoadStr(121);
  GDefiner.Caption := Preferences.LoadStr(561);
  FLDefiner.Caption := Preferences.LoadStr(799) + ':';
  GSize.Caption := Preferences.LoadStr(67);
  FLSize.Caption := Preferences.LoadStr(67) + ':';

  TSReferences.Caption := Preferences.LoadStr(948);
  FReferences.Column[0].Caption := Preferences.LoadStr(35);
  FReferences.Column[1].Caption := Preferences.LoadStr(69);

  TSSource.Caption := Preferences.LoadStr(198);
  Preferences.ApplyToSynMemo(FSource);

  FBHelp.Caption := Preferences.LoadStr(167);
  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDTrigger := nil;
end.

unit uDEvent;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Menus, Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  BCEditor.Editor,
  StdCtrls_Ext, ComCtrls_Ext, Forms_Ext,
  uSession,
  uBase, BCEditor.Highlighter;

type
  TDEvent = class(TForm_Ext)
    FBCancel: TButton;
    FBHelp: TButton;
    FBOk: TButton;
    FComment: TEdit;
    FCreated: TLabel;
    FDefiner: TLabel;
    FEnabled: TCheckBox;
    FEndDate: TDateTimePicker;
    FEndEnabled: TCheckBox;
    FEndTime: TDateTimePicker;
    FExecuteDate: TDateTimePicker;
    FExecuteTime: TDateTimePicker;
    FIntervalDay: TEdit;
    FIntervalHour: TEdit;
    FIntervalMinute: TEdit;
    FIntervalMonth: TEdit;
    FIntervalQuarter: TEdit;
    FIntervalSecond: TEdit;
    FIntervalWeek: TEdit;
    FIntervalYear: TEdit;
    FLComment: TLabel;
    FLCreated: TLabel;
    FLDefiner: TLabel;
    FLEnabled: TLabel;
    FLEndDateTime: TLabel;
    FLExecuteDateTime: TLabel;
    FLIntervalDate: TLabel;
    FLIntervalTime: TLabel;
    FLIntervalWeeks: TLabel;
    FLMultipleExecution: TLabel;
    FLName: TLabel;
    FLPreserve: TLabel;
    FLSingleExecution: TLabel;
    FLStartDateTime: TLabel;
    FLStatement: TLabel;
    FLUpdated: TLabel;
    FMultipleExecution: TRadioButton;
    FName: TEdit;
    FPreserve: TCheckBox;
    FSingleExecution: TRadioButton;
    FSource: TBCEditor;
    FStartDate: TDateTimePicker;
    FStartEnabled: TCheckBox;
    FStartTime: TDateTimePicker;
    FStatement: TBCEditor;
    FUDIntervalDay: TUpDown;
    FUDIntervalHour: TUpDown;
    FUDIntervalMinute: TUpDown;
    FUDIntervalMonth: TUpDown;
    FUDIntervalQuarter: TUpDown;
    FUDIntervalSecond: TUpDown;
    FUDIntervalWeek: TUpDown;
    FUDIntervalYear: TUpDown;
    FUpdated: TLabel;
    GBasics: TGroupBox_Ext;
    GDates: TGroupBox_Ext;
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
    TSInformation: TTabSheet;
    TSSource: TTabSheet;
    procedure FBHelpClick(Sender: TObject);
    procedure FBOkCheckEnabled(Sender: TObject);
    procedure FEndEnabledClick(Sender: TObject);
    procedure FEndEnabledKeyPress(Sender: TObject; var Key: Char);
    procedure FExecutionClick(Sender: TObject);
    procedure FExecutionKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FStartEnabledClick(Sender: TObject);
    procedure FStartEnabledKeyPress(Sender: TObject; var Key: Char);
    procedure TSSourceShow(Sender: TObject);
  private
    SessionState: (ssCreate, ssInit, ssValid, ssAlter);
    procedure Built();
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Database: TSDatabase;
    Event: TSEvent;
    function Execute(): Boolean;
  end;

function DEvent(): TDEvent;

implementation {***************************************************************}

{$R *.dfm}

uses
  StrUtils,
  SQLUtils,
  uPreferences;

var
  FDEvent: TDEvent;

function DEvent(): TDEvent;
begin
  if (not Assigned(FDEvent)) then
  begin
    Application.CreateForm(TDEvent, FDEvent);
    FDEvent.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDEvent;
end;

{ TDEvent *********************************************************************}

procedure TDEvent.Built();
var
  Day: Word;
  Hour: Word;
  Minute: Word;
  Month: Word;
  MSec: Word;
  Quarter: Word;
  Second: Word;
  Week: Word;
  Year: Word;
begin
  FName.Text := Event.Name;

  FSingleExecution.Checked := Event.EventType = etSingle;
  if (Event.Execute = 0) then FExecuteDate.Date := Now() else FExecuteDate.Date := Event.Execute;
  FExecuteTime.Time := Event.Execute;

  FMultipleExecution.Checked := Event.EventType = etMultiple;
  Database.Session.DecodeInterval(Event.IntervalValue, Event.IntervalType, Year, Month, Day, Quarter, Week, Hour, Minute, Second, MSec);
  FUDIntervalYear.Position := Year;
  FUDIntervalMonth.Position := Month;
  FUDIntervalDay.Position := Day;
  FUDIntervalQuarter.Position := Quarter;
  FUDIntervalQuarter.Position := Quarter;
  FUDIntervalWeek.Position := Week;
  FUDIntervalHour.Position := Hour;
  FUDIntervalMinute.Position := Minute;
  FUDIntervalSecond.Position := Second;
  if (Event.StartDateTime = 0) then FStartDate.Date := Now() else FStartDate.Date := Event.StartDateTime;
  FStartTime.Time := Event.StartDateTime;
  if (Event.EndDateTime = 0) then FEndDate.Date := Now() + 1 else FEndDate.Date := Event.EndDateTime;
  FEndTime.Time := Event.EndDateTime;

  FEnabled.Checked := Event.Enabled;
  FPreserve.Checked := Event.Preserve;
  FComment.Text := SQLUnwrapStmt(Event.Comment, Database.Session.Connection.MySQLVersion);
  FStatement.Text := Event.Stmt;

  FDefiner.Caption := Event.Definer;
  FCreated.Caption := SysUtils.DateTimeToStr(Event.Created, LocaleFormatSettings);
  FUpdated.Caption := SysUtils.DateTimeToStr(Event.Updated, LocaleFormatSettings);

  TSSource.TabVisible := Event.Source <> '';
end;

function TDEvent.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDEvent.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDEvent.FBOkCheckEnabled(Sender: TObject);
var
  I: Integer;
  IntervalType: TSEvent.TIntervalType;
  Value: string;
begin
  FBOk.Enabled := (FName.Text <> '') and SQLSingleStmt(FStatement.Text);
  for I := 0 to Database.Events.Count - 1 do
    if (lstrcmpi(PChar(FName.Text), PChar(Database.Events[I].Name)) = 0) and not (not Assigned(Event) or (lstrcmpi(PChar(FName.Text), PChar(Event.Name)) = 0)) then
      FBOk.Enabled := False;

  if (FMultipleExecution.Checked) then
    FBOk.Enabled := FBOk.Enabled and Database.Session.EncodeInterval(FUDIntervalYear.Position, FUDIntervalMonth.Position, FUDIntervalDay.Position, FUDIntervalQuarter.Position, FUDIntervalWeek.Position, FUDIntervalHour.Position, FUDIntervalMinute.Position, FUDIntervalSecond.Position, 0, Value, IntervalType);

  TSSource.TabVisible := False;
end;

procedure TDEvent.FEndEnabledClick(Sender: TObject);
begin
  FEndDate.Enabled := FEndEnabled.Checked and FMultipleExecution.Checked;
  FEndTime.Enabled := FEndEnabled.Checked and FMultipleExecution.Checked;

  FBOkCheckEnabled(Sender);
end;

procedure TDEvent.FEndEnabledKeyPress(Sender: TObject; var Key: Char);
begin
  FEndEnabledClick(Sender);
end;

procedure TDEvent.FExecutionClick(Sender: TObject);
begin
  FExecuteDate.Enabled := FSingleExecution.Checked;
  FExecuteTime.Enabled := FSingleExecution.Checked;

  FIntervalYear.Enabled := FMultipleExecution.Checked; FUDIntervalYear.Enabled := FIntervalYear.Enabled;
  FIntervalMonth.Enabled := FMultipleExecution.Checked; FUDIntervalMonth.Enabled := FIntervalYear.Enabled;
  FIntervalDay.Enabled := FMultipleExecution.Checked; FUDIntervalDay.Enabled := FIntervalDay.Enabled;
  FIntervalQuarter.Enabled := FMultipleExecution.Checked; FUDIntervalQuarter.Enabled := FIntervalQuarter.Enabled;
  FIntervalWeek.Enabled := FMultipleExecution.Checked; FUDIntervalWeek.Enabled := FIntervalWeek.Enabled;
  FIntervalHour.Enabled := FMultipleExecution.Checked; FUDIntervalHour.Enabled := FIntervalHour.Enabled;
  FIntervalMinute.Enabled := FMultipleExecution.Checked; FUDIntervalMinute.Enabled := FIntervalMinute.Enabled;
  FIntervalSecond.Enabled := FMultipleExecution.Checked; FUDIntervalSecond.Enabled := FIntervalSecond.Enabled;
  FStartEnabled.Enabled := FMultipleExecution.Checked; FStartEnabledClick(Sender);
  FEndEnabled.Enabled := FMultipleExecution.Checked; FEndEnabledClick(Sender);

  FBOkCheckEnabled(Sender);
end;

procedure TDEvent.FExecutionKeyPress(Sender: TObject;
  var Key: Char);
begin
  FExecutionClick(Sender);
end;

procedure TDEvent.FormSessionEvent(const Event: TSSession.TEvent);
var
  FirstValid: Boolean;
begin
  FirstValid := SessionState = ssInit;

  if ((SessionState = ssInit) and (Event.EventType = etError)) then
    ModalResult := mrCancel
  else if ((SessionState in [ssInit]) and (Event.EventType = etItemValid) and (Event.Item = Self.Event)) then
  begin
    Built();
    SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType = etError)) then
  begin
    if (not Assigned(Self.Event)) then
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
          ActiveControl := FName
        else
          ActiveControl := FComment;
    end;
  end;
end;

procedure TDEvent.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  IntervalType: TSEvent.TIntervalType;
  IntervalValue: string;
  NewEvent: TSEvent;
begin
  if ((ModalResult = mrOk) and PageControl.Visible) then
  begin
    NewEvent := TSEvent.Create(Database.Events);
    if (Assigned(Event)) then
      NewEvent.Assign(Event);

    NewEvent.Name := Trim(FName.Text);
    if (FSingleExecution.Checked) then
      NewEvent.EventType := etSingle
    else if (FMultipleExecution.Checked) then
      NewEvent.EventType := etMultiple
    else
      NewEvent.EventType := TSEvent.TEventType.etUnknown;

    if (NewEvent.EventType <> etSingle) then
      NewEvent.Execute := 0
    else
      NewEvent.Execute := Trunc(FExecuteDate.Date) + FExecuteTime.Time - Trunc(FExecuteTime.Time);

    if (NewEvent.EventType <> etMultiple) then
    begin
      NewEvent.StartDateTime := 0;
      NewEvent.EndDateTime := 0;
    end
    else
    begin
      Database.Session.EncodeInterval(FUDIntervalYear.Position, FUDIntervalMonth.Position, FUDIntervalDay.Position, FUDIntervalQuarter.Position, FUDIntervalWeek.Position, FUDIntervalHour.Position, FUDIntervalMinute.Position, FUDIntervalSecond.Position, 0, IntervalValue, IntervalType);
      NewEvent.IntervalValue := IntervalValue;
      NewEvent.IntervalType := IntervalType;
      if (not FStartEnabled.Checked) then
       NewEvent.StartDateTime := 0
      else
       NewEvent.StartDateTime := Trunc(FStartDate.Date) + FStartTime.Time - Trunc(FStartTime.Time);
      if (not FEndEnabled.Checked) then
       NewEvent.EndDateTime := 0
      else
       NewEvent.EndDateTime := Trunc(FEndDate.Date) + FEndTime.Time - Trunc(FEndTime.Time);
    end;
    NewEvent.Enabled := FEnabled.Checked;
    NewEvent.Preserve := FPreserve.Checked;
    if (not Assigned(Event) or (Trim(FComment.Text) <> SQLUnwrapStmt(NewEvent.Comment, Database.Session.Connection.MySQLVersion))) then
      NewEvent.Comment := Trim(FComment.Text);
    NewEvent.Stmt := FStatement.Text;

    SessionState := ssAlter;
    if (not Assigned(Event)) then
      CanClose := Database.AddEvent(NewEvent)
    else
      CanClose := Database.UpdateEvent(Event, NewEvent);

    NewEvent.Free();

    PageControl.Visible := False;
    PSQLWait.Visible := not PageControl.Visible;
    FBOk.Enabled := False;
  end;
end;

procedure TDEvent.FormCreate(Sender: TObject);
begin
  FStatement.Highlighter.LoadFromResource('Highlighter', RT_RCDATA);
  FStatement.Highlighter.Colors.LoadFromResource('Colors', RT_RCDATA);
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

  PageControl.ActivePage := TSBasics
end;

procedure TDEvent.FormHide(Sender: TObject);
begin
  Database.Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.Event.Width := Width;
  Preferences.Event.Height := Height;

  FSource.Lines.Clear();
  PageControl.ActivePage := TSBasics;
end;

procedure TDEvent.FormShow(Sender: TObject);
var
  EventName: string;
  I: Integer;
  SQL: string;
begin
  Database.Session.RegisterEventProc(FormSessionEvent);

  if ((Preferences.View.Width >= Width) and (Preferences.View.Height >= Height)) then
  begin
    Width := Preferences.Event.Width;
    Height := Preferences.Event.Height;
  end;

  if (not Assigned(Event)) then
    Caption := Preferences.LoadStr(820)
  else
    Caption := Preferences.LoadStr(842, Event.Name);

  if (not Assigned(Event)) then
    HelpContext := 1114
  else
    HelpContext := 1113;

  FStatement.Lines.Clear();
  Database.Session.ApplyToBCEditor(FStatement);
  FSource.Lines.Clear();
  Database.Session.ApplyToBCEditor(FSource);

  if (not Assigned(Event)) then
    SessionState := ssCreate
  else if (not Event.Valid and not Event.Update()) then
    SessionState := ssInit
  else
    SessionState := ssValid;

  if (not Assigned(Event)) then
  begin
    EventName := Preferences.LoadStr(814);
    I := 2;
    while (Assigned(Database.EventByName(EventName))) do
    begin
      EventName := Preferences.LoadStr(814) + IntToStr(I);
      Inc(I);
    end;

    FName.Text := EventName;

    FSingleExecution.Checked := True;
    FExecuteDate.Date := Now() + 1; FExecuteTime.Time := 0;

    FUDIntervalYear.Position := 0;
    FUDIntervalMonth.Position := 0;
    FUDIntervalDay.Position := 0;
    FUDIntervalQuarter.Position := 0;
    FUDIntervalQuarter.Position := 0;
    FUDIntervalWeek.Position := 0;
    FUDIntervalHour.Position := 0;
    FUDIntervalMinute.Position := 0;
    FUDIntervalSecond.Position := 0;
    FStartDate.Date := Now() + 1; FStartTime.Time := 0;
    FEndDate.Date := Now() + 2; FEndTime.Time := 0;

    FEnabled.Checked := True;
    FPreserve.Checked := False;
    FComment.Text := '';
    SQL := 'BEGIN' + #13#10
      + '  SET @A = 1;' + #13#10
      + 'END;' + #13#10;
    FStatement.Text := SQL;
  end
  else
  begin
    if (SessionState = ssValid) then
      Built();
  end;

  FSource.Lines.Clear();

  TSInformation.TabVisible := Assigned(Event);
  TSSource.TabVisible := Assigned(Event);

  PageControl.Visible := SessionState in [ssCreate, ssValid];
  PSQLWait.Visible := not PageControl.Visible;

  FBOk.Enabled := PageControl.Visible and not Assigned(Event);

  ActiveControl := FBCancel;
  if (PageControl.Visible) then
    ActiveControl := FName;
end;

procedure TDEvent.FStartEnabledClick(Sender: TObject);
begin
  FStartDate.Enabled := FStartEnabled.Checked and FMultipleExecution.Checked;
  FStartTime.Enabled := FStartEnabled.Checked and FMultipleExecution.Checked;

  FBOkCheckEnabled(Sender);
end;

procedure TDEvent.FStartEnabledKeyPress(Sender: TObject; var Key: Char);
begin
  FStartEnabledClick(Sender);
end;

procedure TDEvent.TSSourceShow(Sender: TObject);
begin
  if (FSource.Lines.Count = 0) then
    FSource.Text := Event.Source
end;

procedure TDEvent.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiEvent, Icon);

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  TSBasics.Caption := Preferences.LoadStr(108);
  GBasics.Caption := Preferences.LoadStr(85);
  FLName.Caption := Preferences.LoadStr(35) + ':';
  FLSingleExecution.Caption := Preferences.LoadStr(174) + ':';
  FSingleExecution.Caption := Preferences.LoadStr(815) + ' ...';
  FLExecuteDateTime.Caption := Preferences.LoadStr(520) + ':';
  FMultipleExecution.Caption := Preferences.LoadStr(816) + ' ...';
  FLMultipleExecution.Caption := Preferences.LoadStr(174) + ':';
  FLIntervalDate.Caption := Preferences.LoadStr(822) + ' / ' + Preferences.LoadStr(823) + ' / ' + Preferences.LoadStr(824) + ':';
  FLIntervalWeeks.Caption := Preferences.LoadStr(825) + ' / ' + Preferences.LoadStr(826) + ':';
  FLIntervalTime.Caption := Preferences.LoadStr(827) + ' / ' + Preferences.LoadStr(828) + ' / ' + Preferences.LoadStr(829) + ':';
  FLStartDateTime.Caption := Preferences.LoadStr(817) + ':';
  FLEndDateTime.Caption := Preferences.LoadStr(818) + ':';
  FLEnabled.Caption := Preferences.LoadStr(812) + ':';
  FEnabled.Caption := Preferences.LoadStr(529);
  FLPreserve.Caption := Preferences.LoadStr(819) + ':';
  FPreserve.Caption := Preferences.LoadStr(884);
  FLComment.Caption := Preferences.LoadStr(111) + ':';
  FLStatement.Caption := Preferences.LoadStr(794) + ':';

  Preferences.ApplyToBCEditor(FStatement);

  TSInformation.Caption := Preferences.LoadStr(121);
  GDefiner.Caption := Preferences.LoadStr(561);
  FLDefiner.Caption := Preferences.LoadStr(799) + ':';
  GDates.Caption := Preferences.LoadStr(122);
  FLCreated.Caption := Preferences.LoadStr(118) + ':';
  FLUpdated.Caption := Preferences.LoadStr(119) + ':';

  TSSource.Caption := Preferences.LoadStr(198);
  Preferences.ApplyToBCEditor(FSource);

  FBHelp.Caption := Preferences.LoadStr(167);
  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDEvent := nil;
end.


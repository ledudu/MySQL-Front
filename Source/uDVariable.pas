unit uDVariable;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  Forms_Ext, StdCtrls_Ext,
  uSession,
  uBase;

type
  TDVariable = class (TForm_Ext)
    FBCancel: TButton;
    FBOk: TButton;
    FGlobal: TRadioButton;
    FLModify: TLabel;
    FLValue: TLabel;
    FSession: TRadioButton;
    FValue: TEdit;
    GroupBox: TGroupBox_Ext;
    PSQLWait: TPanel;
    procedure FBOkButtonEnable(Sender: TObject);
    procedure FGlobalClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FSessionClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
  private
    SessionState: (ssInit, ssValid, ssAlter);
    procedure Built();
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Session: TSSession;
    Variable: TSVariable;
    function Execute(): Boolean;
  end;

function DVariable(): TDVariable;

implementation {***************************************************************}

{$R *.dfm}

uses
  uPreferences;

var
  FDVariable: TDVariable;

function DVariable(): TDVariable;
begin
  if (not Assigned(FDVariable)) then
  begin
    Application.CreateForm(TDVariable, FDVariable);
    FDVariable.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDVariable;
end;

{ TDVariable ******************************************************************}

procedure TDVariable.Built();
begin
  FValue.Text := Variable.Value;
  FGlobal.Checked := False;
  FSession.Checked := True;
end;

function TDVariable.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDVariable.FBOkButtonEnable(Sender: TObject);
begin
  FBOk.Enabled := True;
end;

procedure TDVariable.FGlobalClick(Sender: TObject);
begin
  if (FGlobal.Checked) then FSession.Checked := False;
  FBOkButtonEnable(Sender);
end;

procedure TDVariable.FormSessionEvent(const Event: TSSession.TEvent);
var
  FirstValid: Boolean;
begin
  FirstValid := SessionState = ssInit;

  if ((SessionState = ssInit) and (Event.EventType = etError)) then
    ModalResult := mrCancel
  else if ((SessionState in [ssInit]) and (Event.EventType = etItemValid) and (Event.Item = Variable)) then
  begin
    Built();
    SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType = etError)) then
  begin
    SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType in [etItemValid, etItemRenamed]) and (Event.Item = Variable)) then
    ModalResult := mrOk;

  if (SessionState = ssValid) then
  begin
    if (not GroupBox.Visible) then
    begin
      GroupBox.Visible := True;
      PSQLWait.Visible := not GroupBox.Visible;

      if (FirstValid) then
        if (not Assigned(Event)) then
          ActiveControl := FValue;
    end;
  end;
end;

procedure TDVariable.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  NewHeight := Height;
end;

procedure TDVariable.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  NewVariable: TSVariable;
  UpdateModes: TSVariable.TUpdateModes;
begin
  if ((ModalResult = mrOk) and GroupBox.Visible) then
  begin
    NewVariable := TSVariable.Create(Session.Variables);
    if (Assigned(Variable)) then
      NewVariable.Assign(Variable);

    NewVariable.Value := Trim(FValue.Text);

    UpdateModes := [];
    if (FGlobal.Checked) then Include(UpdateModes, vuGlobal);
    if (FSession.Checked) then Include(UpdateModes, vuSession);

    SessionState := ssAlter;
    CanClose := Session.UpdateVariable(Variable, NewVariable, UpdateModes);

    NewVariable.Free();

    GroupBox.Visible := False;
    PSQLWait.Visible := not GroupBox.Visible;
    FBOk.Enabled := False;
  end;
end;

procedure TDVariable.FormCreate(Sender: TObject);
begin
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;
end;

procedure TDVariable.FormHide(Sender: TObject);
begin
  Session.UnRegisterEventProc(FormSessionEvent);
end;

procedure TDVariable.FormShow(Sender: TObject);
begin
  Session.RegisterEventProc(FormSessionEvent);

  Caption := Preferences.LoadStr(842, Variable.Name);

  FGlobal.Visible := Session.Connection.MySQLVersion >= 40003;
  FSession.Visible := Session.Connection.MySQLVersion >= 40003;

  FGlobal.Enabled := not Assigned(Session.UserRights) or Session.UserRights.RSuper;

  if (not Session.Variables.Valid and not Session.Variables.Update()) then
    SessionState := ssInit
  else
    SessionState := ssValid;

  if (SessionState = ssValid) then
    Built();

  GroupBox.Visible := SessionState = ssValid;
  PSQLWait.Visible := not GroupBox.Visible;
  FBOk.Enabled := False;

  FValue.SelectAll();
  ActiveControl := FValue;
end;

procedure TDVariable.FSessionClick(Sender: TObject);
begin
  if (FSession.Checked) then FGlobal.Checked := False;
  FBOkButtonEnable(Sender);
end;

procedure TDVariable.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiVariable, Icon);

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  GroupBox.Caption := Preferences.LoadStr(342);
  FLValue.Caption := Preferences.LoadStr(343) + ':';
  FLModify.Caption := Preferences.LoadStr(344) + ':';
  FGlobal.Caption := Preferences.LoadStr(345);
  FSession.Caption := Preferences.LoadStr(346);

  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDVariable := nil;
end.

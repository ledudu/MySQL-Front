unit uDExecutingSQL;

interface {********************************************************************}

uses
  Messages,
  Classes,
  Forms, Controls, StdCtrls,
  Forms_Ext,
  uSession,
  uBase;

type
  TDExecutingSQL = class (TForm_Ext)
    FBCancel: TButton;
    FInfo: TLabel;
    procedure FBCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure UMPostShow(var Message: TMessage); message UM_POST_SHOW;
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Session: TSSession;
    Update: TSSession.TUpdate;
    function Execute(): Boolean;
  end;

function DExecutingSQL(): TDExecutingSQL;

implementation {***************************************************************}

{$R *.dfm}

uses
  Windows, SysUtils, 
  MySQLDB, MySQLConsts,
  uPreferences,
  uDAccount;

var
  FDExecutingSQL: TDExecutingSQL;

function DExecutingSQL(): TDExecutingSQL;
begin
  if (not Assigned(FDExecutingSQL)) then
  begin
    Application.CreateForm(TDExecutingSQL, FDExecutingSQL);
    FDExecutingSQL.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDExecutingSQL;
end;

{ TDOpenConnection ************************************************************}

procedure TDExecutingSQL.FBCancelClick(Sender: TObject);
begin
  Session.Connection.Terminate();
  ModalResult := mrCancel;
end;

function TDExecutingSQL.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDExecutingSQL.FormHide(Sender: TObject);
begin
  Session.UnRegisterEventProc(FormSessionEvent);
end;

procedure TDExecutingSQL.FormSessionEvent(const Event: TSSession.TEvent);
begin
  if (Event.EventType = etAfterExecuteSQL) then
    if (Event.Session.Connection.ErrorCode <> 0) then
      ModalResult := mrCancel
    else
      ModalResult := mrOk;
end;

procedure TDExecutingSQL.FormShow(Sender: TObject);
begin
  Session.RegisterEventProc(FormSessionEvent);

  Caption := Session.Account.Name;

  PostMessage(Handle, UM_POST_SHOW, 0, 0);
end;

procedure TDExecutingSQL.UMPostShow(var Message: TMessage);
begin
  if (Update()) then
    ModalResult := mrOk;
end;

procedure TDExecutingSQL.UMPreferencesChanged(var Message: TMessage);
begin
  FInfo.Caption := Preferences.LoadStr(882) + '...';

  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDExecutingSQL := nil;
end.


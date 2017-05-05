unit uDLogin;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  Forms_Ext, StdCtrls_Ext,
  uSession, uPreferences,
  uBase;


type
  TDLogin = class (TForm_Ext)
    FBCancel: TButton;
    FBOk: TButton;
    FLPassword: TLabel;
    FLUsername: TLabel;
    FPassword: TEdit;
    FUsername: TEdit;
    GAccount: TGroupBox_Ext;
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Account: TPAccount;
    function Execute(): Boolean;
  end;

function DLogin(): TDLogin;

implementation {***************************************************************}

{$R *.dfm}

uses
  uDAccount;

var
  FDLogin: TDLogin;

function DLogin(): TDLogin;
begin
  if (not Assigned(FDLogin)) then
  begin
    Application.CreateForm(TDLogin, FDLogin);
    FDLogin.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDLogin;
end;

{ TDLogin *********************************************************************}

function TDLogin.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDLogin.FormHide(Sender: TObject);
begin
  if (ModalResult = mrOk) then
  begin
    Account.Connection.Username := Trim(FUsername.Text);
    Account.Connection.Password := Trim(FPassword.Text);
  end;
end;

procedure TDLogin.FormShow(Sender: TObject);
begin
  FUsername.Text := Account.Connection.Username;
  FPassword.Text := Account.Connection.Password;

  ActiveControl := FBCancel;
  if (not Assigned(Account)) then
    ActiveControl := FUsername
  else
    ActiveControl := FPassword;
end;

procedure TDLogin.UMPreferencesChanged(var Message: TMessage);
begin
  Caption := Preferences.LoadStr(49);

  GAccount.Caption := Preferences.LoadStr(34);
  FLUsername.Caption := Preferences.LoadStr(561) + ':';
  FLPassword.Caption := Preferences.LoadStr(40) + ':';

  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDLogin := nil;
end.

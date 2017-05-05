unit uDAccount;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus,
  ComCtrls_Ext, Forms_Ext, StdCtrls_Ext, ExtCtrls_Ext,
  uPreferences, uBase, uSession;

type
  TDAccount = class (TForm_Ext)
    FBCancel: TButton;
    FBDatabase: TButton;
    FBHelp: TButton;
    FBOk: TButton;
    FConnectionType: TComboBox_Ext;
    FDatabase: TEdit;
    FHost: TEdit;
    FHTTPTunnelURI: TEdit;
    FLConnectionType: TLabel;
    FLDatabase: TLabel;
    FLHost: TLabel;
    FLHTTPTunnelURI: TLabel;
    FLibraryFilename: TEdit;
    FLLibraryFilename: TLabel;
    FLName: TLabel;
    FLPassword: TLabel;
    FLPort: TLabel;
    FLUser: TLabel;
    FName: TEdit;
    FPassword: TEdit;
    FPort: TEdit;
    FUDPort: TUpDown;
    FUser: TEdit;
    GBasics: TGroupBox_Ext;
    GLogin: TGroupBox_Ext;
    GConnection: TGroupBox_Ext;
    procedure FBDatabaseClick(Sender: TObject);
    procedure FBHelpClick(Sender: TObject);
    procedure FConnectionTypeChange(Sender: TObject);
    procedure FHostExit(Sender: TObject);
    procedure FHTTPTunnelURIEnter(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function GetAccountName(): string;
    procedure FormHide(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FHostChange(Sender: TObject);
    procedure FLibraryFilenameEnter(Sender: TObject);
  private
    function CheckConnectInfos(): Boolean;
    procedure CMSysFontChanged(var Message: TMessage); message CM_SYSFONTCHANGED;
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Account: TPAccount;
    Password: string;
    Username: string;
    function Execute(): Boolean;
    property AccountName: string read GetAccountName;
  end;

function DAccount(): TDAccount;

implementation {***************************************************************}

{$R *.dfm}

uses
  WinINet, Shlwapi,
  UITypes, IOUtils, StrUtils, RegularExpressions,
  MySQLConsts, MySQLDB,
  uDDatabases, uDConnecting;

var
  FDAccount: TDAccount;

function DAccount(): TDAccount;
begin
  if (not Assigned(FDAccount)) then
  begin
    Application.CreateForm(TDAccount, FDAccount);
    FDAccount.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDAccount;
end;

function ValidHostName(const HostName: string; const Port: Integer): Boolean;
const
  IP4AddrPattern = '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$';
  IP6AddrPattern = '^(?:[A-F0-9]{1,4}:){7}[A-F0-9]{1,4}$';
  DomainnamePattern = '^(([a-z0-9\p{L}]|[a-z0-9\p{L}][a-z0-9\-\p{L}]*[a-z0-9\p{L}])\.)*([a-z0-9\p{L}]|[a-z0-9\p{L}][a-z0-9\-\p{L}]*[a-z0-9\p{L}])$';
begin
  Result := TRegEx.IsMatch(HostName, DomainnamePattern, [roSingleLine, roIgnoreCase])
    or TRegEx.IsMatch(HostName, IP4AddrPattern, [roSingleLine])
    or TRegEx.IsMatch(HostName, IP6AddrPattern, [roSingleLine]);
end;

function ValidURL(const URL: string): Boolean;
var
  URLComponents: TURLComponents;
  URLComponentsExtraInfo: array [0 .. INTERNET_MAX_PATH_LENGTH] of Char;
  URLComponentsHostName: array [0 .. INTERNET_MAX_HOST_NAME_LENGTH] of Char;
  URLComponentsPassword: array [0 .. INTERNET_MAX_PASSWORD_LENGTH] of Char;
  URLComponentsPath: array [0 .. INTERNET_MAX_PATH_LENGTH] of Char;
  URLComponentsSchemeName: array [0 .. INTERNET_MAX_SCHEME_LENGTH] of Char;
  URLComponentsUserName: array [0 .. INTERNET_MAX_USER_NAME_LENGTH] of Char;
begin
  URLComponents.dwStructSize := SizeOf(URLComponents);
  URLComponents.dwSchemeLength := Length(URLComponentsSchemeName);
  URLComponents.dwHostNameLength := Length(URLComponentsHostName);
  URLComponents.dwUserNameLength := Length(URLComponentsUserName);
  URLComponents.dwPasswordLength := Length(URLComponentsPassword);
  URLComponents.dwUrlPathLength := Length(URLComponentsPath);
  URLComponents.dwExtraInfoLength := Length(URLComponentsExtraInfo);
  URLComponents.lpszScheme := @URLComponentsSchemeName;
  URLComponents.lpszHostName := @URLComponentsHostName;
  URLComponents.lpszUserName := @URLComponentsUserName;
  URLComponents.lpszPassword := @URLComponentsPassword;
  URLComponents.lpszUrlPath := @URLComponentsPath;
  URLComponents.lpszExtraInfo := @URLComponentsExtraInfo;

  if (URL = '') then
    Result := False
  else
    Result := InternetCrackUrl(PChar(URL), Length(URL), 0, URLComponents);
end;

{ TDAccount *******************************************************************}

function TDAccount.CheckConnectInfos(): Boolean;
begin
  Result := False;

  if (FHost.Text = '') then
    begin MessageBeep(MB_ICONERROR); ActiveControl := nil; ActiveControl := FHost; end
  else if ((FConnectionType.ItemIndex = 1) and (FLibraryFilename.Text = '')) then
    begin MessageBeep(MB_ICONERROR); ActiveControl := nil; ActiveControl := FLibraryFilename; end
  else if ((FConnectionType.ItemIndex = 2) and (FHTTPTunnelURI.Text = '')) then
    begin MessageBeep(MB_ICONERROR); ActiveControl := nil; ActiveControl := FHTTPTunnelURI; end
  else
    Result := True;
end;

procedure TDAccount.CMSysFontChanged(var Message: TMessage);
begin
  inherited;

  FormResize(nil);
end;

function TDAccount.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDAccount.FBDatabaseClick(Sender: TObject);
var
  LibraryName: string;
  LibraryType: TMySQLLibrary.TLibraryType;
  Session: TSSession;
begin
  if (CheckConnectInfos()) then
  begin
    Session := TSSession.Create(Sessions);
    if (Assigned(Session)) then
    begin
      case (FConnectionType.ItemIndex) of
        1: LibraryType := ltDLL;
        2: LibraryType := ltHTTP;
        else LibraryType := ltBuiltIn;
      end;
      case (FConnectionType.ItemIndex) of
        1: LibraryName := FLibraryFilename.Text;
        2: LibraryName := FHTTPTunnelURI.Text;
        else LibraryName := '';
      end;

      Session.Connection.BeginSilent();
      DConnecting.LibraryType := LibraryType;
      DConnecting.LibraryName := LibraryName;
      DConnecting.Host := Trim(FHost.Text);
      DConnecting.User := Trim(FUser.Text);
      DConnecting.Password := Trim(FPassword.Text);
      DConnecting.Port := FUDPort.Position;
      DConnecting.Session := Session;
      if (DConnecting.Execute()) then
      begin
        DDatabases.Session := Session;
        DDatabases.SelectedDatabases := FDatabase.Text;
        if (DDatabases.Execute()) then
          FDatabase.Text := DDatabases.SelectedDatabases;
      end
      else if (Session.Connection.ErrorCode > 0) then
        Session.Connection.OnSQLError(Session.Connection, Session.Connection.ErrorCode, Session.Connection.ErrorMessage);
      Session.Connection.EndSilent();

      Session.Free();
    end;

    ActiveControl := FDatabase;
  end;
end;

procedure TDAccount.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext)
end;

procedure TDAccount.FConnectionTypeChange(Sender: TObject);
begin
  FLibraryFilename.Visible := FConnectionType.ItemIndex = 1;
  FHTTPTunnelURI.Visible := FConnectionType.ItemIndex = 2;
  FLLibraryFilename.Visible := FLibraryFilename.Visible;
  FLHTTPTunnelURI.Visible := FHTTPTunnelURI.Visible;
end;

procedure TDAccount.FHostChange(Sender: TObject);
begin
  FPort.Visible := Trim(FHost.Text) <> LOCAL_HOST_NAMEDPIPE;
  FUDPort.Visible := FPort.Visible;
  FLPort.Visible := FPort.Visible;
end;

procedure TDAccount.FHostExit(Sender: TObject);
var
  Host: string;
  Index: Integer;
begin
  if (Trim(FName.Text) = '') then
  begin
    Host := Trim(FHost.Text);

    if (not Assigned(Accounts.AccountByName(FHost.Text))) then
      FName.Text := Host
    else
    begin
      Index := 2;
      while (Assigned(Accounts.AccountByName(Host + ' (' + IntToStr(Index) + ')'))) do
        Inc(Index);
      FName.Text := Host + ' (' + IntToStr(Index) + ')';
    end;
  end;
end;

procedure TDAccount.FHTTPTunnelURIEnter(Sender: TObject);
begin
  if ((FHTTPTunnelURI.Text = '') and (Trim(FHost.Text) <> '') and (lstrcmpi(PChar(Trim(FHost.Text)), LOCAL_HOST) <> 0)) then
    FHTTPTunnelURI.Text := 'http://' + Trim(FHost.Text) + '/libMySQL.php';
end;

procedure TDAccount.FLibraryFilenameEnter(Sender: TObject);
begin
  if (FLibraryFilename.Text = '') then
    FLibraryFilename.Text := 'libMySQL.dll';
end;

procedure TDAccount.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  NewHeight := Height;
end;

procedure TDAccount.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  NewAccount: TPAccount;
begin
  if (ModalResult = mrOk) then
  begin
    if (Trim(FName.Text) = '') then
      FHostExit(Sender);

    if (CanClose
      and ((Trim(FName.Text) = '')
        or not Assigned(Account) and Assigned(Accounts.AccountByName(Trim(FName.Text)))
        or Assigned(Account) and Assigned(Accounts.AccountByName(Trim(FName.Text))) and (Accounts.AccountByName(Trim(FName.Text)) <> Account))) then
      begin MessageBeep(MB_ICONERROR); ActiveControl := nil; ActiveControl := FName; CanClose := False; end;

    if (CanClose
      and (Trim(FHost.Text) <> LOCAL_HOST_NAMEDPIPE) and (FUDPort.Position = 0)) then
      begin MessageBeep(MB_ICONERROR); ActiveControl := nil; ActiveControl := FPort; CanClose := False; end;

    if (CanClose
      and (Trim(FHost.Text) <> LOCAL_HOST_NAMEDPIPE) and not ValidHostname(Trim(FHost.Text), FUDPort.Position)) then
      begin MessageBeep(MB_ICONERROR); ActiveControl := nil; ActiveControl := FHost; CanClose := False; end;

    if (CanClose
      and (Trim(FHost.Text) <> LOCAL_HOST_NAMEDPIPE)
      and (FUDPort.Position = 0)) then
      begin MessageBeep(MB_ICONERROR); ActiveControl := nil; ActiveControl := FPort; CanClose := False; end;

    if (CanClose
      and (FConnectionType.ItemIndex = 1)
      and not TPath.HasValidFileNameChars(FLibraryFilename.Text, False)) then
      begin MessageBeep(MB_ICONERROR); ActiveControl := nil; ActiveControl := FLibraryFilename; CanClose := False; end;

    if (CanClose
      and (FConnectionType.ItemIndex = 2)
      and not ValidURL(PChar(FHTTPTunnelURI.Text))) then
      begin MessageBeep(MB_ICONERROR); ActiveControl := nil; ActiveControl := FHTTPTunnelURI; CanClose := False; end;

    if (CanClose) then
    begin
      NewAccount := TPAccount.Create(Accounts);
      if (Assigned(Account)) then
        NewAccount.Assign(Account);

      NewAccount.Name := Trim(FName.Text);
      NewAccount.Connection.Host := Trim(FHost.Text);
      NewAccount.Connection.Port := FUDPort.Position;
      case (FConnectionType.ItemIndex) of
        0: NewAccount.Connection.LibraryType := uPreferences.ltBuiltIn;
        1: NewAccount.Connection.LibraryType := uPreferences.ltDLL;
        2: NewAccount.Connection.LibraryType := uPreferences.ltHTTP;
      end;
      NewAccount.Connection.LibraryFilename := Trim(FLibraryFilename.Text);
      NewAccount.Connection.HTTPTunnelURI := Trim(FHTTPTunnelURI.Text);

      NewAccount.Connection.Username := Trim(FUser.Text);
      NewAccount.Connection.Password := Trim(FPassword.Text);
      NewAccount.Connection.Database := ReplaceStr(Trim(FDatabase.Text), ';', ',');

      Username := NewAccount.Connection.Username;
      Password := NewAccount.Connection.Password;

      if (not Assigned(Account)) then
        Accounts.AddAccount(NewAccount)
      else
        Accounts.UpdateAccount(Account, NewAccount);

      NewAccount.Free();
    end;
  end;
end;

procedure TDAccount.FormCreate(Sender: TObject);
begin
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;
end;

procedure TDAccount.FormHide(Sender: TObject);
begin
  Preferences.Account.Width := Width;
  Preferences.Account.Height := Height;

  if (ModalResult = mrOk) then
    Preferences.Save();
end;

procedure TDAccount.FormResize(Sender: TObject);
begin
  FBDatabase.Left := FDatabase.Left + FDatabase.Width;
  FBDatabase.Height := FDatabase.Height;
  FBDatabase.Width := FBDatabase.Height;
end;

procedure TDAccount.FormShow(Sender: TObject);
begin
  if ((Preferences.xDatabase.Width >= Width) and (Preferences.xDatabase.Height >= Height)) then
  begin
    Width := Preferences.Account.Width;
    Height := Preferences.Account.Height;
  end;

  if (not Assigned(Account)) then
    Caption := Preferences.LoadStr(204)
  else
    Caption := Preferences.LoadStr(842, Account.Name);

  FConnectionType.Items.Text := Preferences.LoadStr(649) + #13#10 + Preferences.LoadStr(650) + #13#10 + Preferences.LoadStr(651);

  if (not Assigned(Account)) then
  begin
    FName.Text := '';

    FHost.Text := '';
    FUDPort.Position := MYSQL_PORT;
    FConnectionType.ItemIndex := 0;
    FLibraryFilename.Text := 'libMySQL.dll';
    FHTTPTunnelURI.Text := '';

    FUser.Text := 'root';
    FPassword.Text := '';
    FDatabase.Text := '';
  end
  else
  begin
    FName.Text := Account.Name;

    FHost.Text := Account.Connection.Host;
    if (Account.Connection.Port = 0) then
      FUDPort.Position := MYSQL_PORT
    else
      FUDPort.Position := Account.Connection.Port;
    case (Account.Connection.LibraryType) of
      uPreferences.ltBuiltIn: FConnectionType.ItemIndex := 0;
      uPreferences.ltDLL: FConnectionType.ItemIndex := 1;
      uPreferences.ltHTTP: FConnectionType.ItemIndex := 2;
    end;
    FLibraryFilename.Text := Account.Connection.LibraryFilename;
    FHTTPTunnelURI.Text := Account.Connection.HTTPTunnelURI;

    FUser.Text := Username;
    FPassword.Text := Password;
    FDatabase.Text := Account.Connection.Database;
  end;

  FConnectionTypeChange(nil);

  ActiveControl := FBCancel;
  ActiveControl := FHost;
end;

function TDAccount.GetAccountName(): string;
begin
  Result := Trim(FName.Text);
end;

procedure TDAccount.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiServer, Icon);

  GBasics.Caption := Preferences.LoadStr(85);
  FLName.Caption := Preferences.LoadStr(35) + ':';

  GConnection.Caption := Preferences.LoadStr(486);
  FLHost.Caption := Preferences.LoadStr(906) + ':';
  FLPort.Caption := Preferences.LoadStr(436) + ':';
  FLConnectionType.Caption := Preferences.LoadStr(648) + ':';
  FConnectionType.Items.Text := '';
  FConnectionTypeChange(nil);
  FLLibraryFilename.Caption := Preferences.LoadStr(568) + ':';
  FLHTTPTunnelURI.Caption := Preferences.LoadStr(652) + ':';

  GLogin.Caption := Preferences.LoadStr(34);
  FLUser.Caption := Preferences.LoadStr(561) + ':';
  FLPassword.Caption := Preferences.LoadStr(40) + ':';
  FLDatabase.Caption := Preferences.LoadStr(38) + ':';

  FBHelp.Caption := Preferences.LoadStr(167);
  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDAccount := nil;
end.

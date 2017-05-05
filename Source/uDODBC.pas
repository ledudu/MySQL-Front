unit uDODBC;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  WinCred,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  ODBCAPI,
  Forms_Ext, StdCtrls_Ext,
  uSession,
  uBase;

const
  CREDUI_MAX_MESSAGE_LENGTH        = 32767;
  {$EXTERNALSYM CREDUI_MAX_MESSAGE_LENGTH}
  CREDUI_MAX_CAPTION_LENGTH        = 128;
  {$EXTERNALSYM CREDUI_MAX_CAPTION_LENGTH}
  CREDUI_MAX_GENERIC_TARGET_LENGTH = CRED_MAX_GENERIC_TARGET_NAME_LENGTH;
  {$EXTERNALSYM CREDUI_MAX_GENERIC_TARGET_LENGTH}
  CREDUI_MAX_DOMAIN_TARGET_LENGTH  = CRED_MAX_DOMAIN_TARGET_NAME_LENGTH;
  {$EXTERNALSYM CREDUI_MAX_DOMAIN_TARGET_LENGTH}
  CREDUI_MAX_USERNAME_LENGTH       = CRED_MAX_USERNAME_LENGTH;
  {$EXTERNALSYM CREDUI_MAX_USERNAME_LENGTH}
  CREDUI_MAX_PASSWORD_LENGTH       = CRED_MAX_CREDENTIAL_BLOB_SIZE div 2;
  {$EXTERNALSYM CREDUI_MAX_PASSWORD_LENGTH}

type
  TCredUIPromptForCredentials = function (pUiInfo: PCredUIInfoW;
    pszTargetName: PCWSTR; pContext: PCtxtHandle; dwAuthError: DWORD;
    pszUserName: PWSTR; ulUserNameBufferSize: ULONG; pszPassword: PWSTR;
    ulPasswordBufferSize: ULONG; var save: BOOL; dwFlags: DWORD): DWORD; stdcall;

type
  TDODBC = class (TForm_Ext)
    FBCancel: TButton;
    FBManage: TButton;
    FBOk: TButton;
    FDataSources: TListView;
    procedure FDataSourcesDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FDataSourcesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FBManageClick(Sender: TObject);
  private
    CredUIPromptForCredentials: TCredUIPromptForCredentials;
    LibHandle: THandle;
    ODBC: SQLHDBC;
    PasswordC: array [0 .. CREDUI_MAX_PASSWORD_LENGTH] of Char;
    UsernameC: array [0 .. CRED_MAX_USERNAME_LENGTH] of Char;
    procedure FBOkCheckEnabled(Sender: TObject);
    procedure FDataSourcesUpdate();
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    DataSource: string;
    Password: string;
    Username: string;
    function Execute(): Boolean;
  end;

function DODBC(): TDODBC;

implementation {***************************************************************}

{$R *.dfm}

uses
  SysConst,
  CSVUtils,
  uTools, uPreferences;

const
  STR_LEN = 128;

var
  FDODBC: TDODBC;

function DODBC(): TDODBC;
begin
  if (not Assigned(FDODBC)) then
  begin
    Application.CreateForm(TDODBC, FDODBC);
    FDODBC.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDODBC;
end;

{ TDODBC *****************************************************************}

function TDODBC.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDODBC.FBManageClick(Sender: TObject);
begin
  SQLManageDataSources(Handle);
  FDataSourcesUpdate();
end;

procedure TDODBC.FBOkCheckEnabled(Sender: TObject);
begin
  FBOk.Enabled := Assigned(FDataSources.Selected);
end;

procedure TDODBC.FDataSourcesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  FBOkCheckEnabled(Sender);
end;

procedure TDODBC.FDataSourcesDblClick(Sender: TObject);
begin
  FBOk.Click();
end;

procedure TDODBC.FDataSourcesUpdate();
var
  DataSource: array [0 .. STR_LEN] of SQLTCHAR;
  OldDataSource: string;
  I: Integer;
begin
  if (not Assigned(FDataSources.Selected)) then
    OldDataSource := ''
  else
    OldDataSource := FDataSources.Selected.Caption;

  FDataSources.Items.BeginUpdate();
  FDataSources.Items.Clear();
  FDataSources.SortType := stNone;

  if (SQL_SUCCEEDED(SQLDataSources(ODBCEnv, SQL_FETCH_FIRST, @DataSource, STR_LEN, nil, nil, 0, nil))) then
    repeat
      FDataSources.Items.Add().Caption := DataSource;
    until (not SQL_SUCCEEDED(SQLDataSources(ODBCEnv, SQL_FETCH_NEXT, @DataSource, STR_LEN, nil, nil, 0, nil)));

  FDataSources.SortType := stText;

  for I := 0 to FDataSources.Items.Count - 1 do
    if (lstrcmpi(PChar(FDataSources.Items[I].Caption), PChar(OldDataSource)) = 0) then
    begin
      FDataSources.Selected := FDataSources.Items[I];
      FDataSources.ItemFocused := FDataSources.Items[I];
    end;

  FDataSources.Items.EndUpdate();
end;

procedure TDODBC.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  cbMessageText: SQLSMALLINT;
  CredUIInfo: TCredUIInfoW;
  Save: BOOL;
  Flags: DWORD;
  MessageText: PSQLTCHAR;
  SQLState: array [0 .. SQL_SQLSTATE_SIZE] of SQLTCHAR;
begin
  if (ModalResult = mrOk) then
  begin
    CanClose := Assigned(FDataSources.Selected);
    if (CanClose) then
    begin
      StrPCopy(@UsernameC, Username);
      StrPCopy(@PasswordC, Password);

      ZeroMemory(@CredUIInfo, SizeOf(TCredUIInfo));
      CredUIInfo.cbSize := SizeOf(CredUIInfo);
      CredUIInfo.hwndParent := Handle;
      CredUIInfo.pszMessageText := PChar(FDataSources.Selected.Caption);
      CredUIInfo.pszCaptionText := PChar(Caption);

      Save := False;
      Flags := CREDUI_FLAGS_ALWAYS_SHOW_UI or CREDUI_FLAGS_DO_NOT_PERSIST or CREDUI_FLAGS_EXCLUDE_CERTIFICATES or CREDUI_FLAGS_GENERIC_CREDENTIALS;

      CanClose := CredUIPromptForCredentials(@CredUIInfo, CredUIInfo.pszMessageText, nil, 0,
        UsernameC, CRED_MAX_USERNAME_LENGTH,
        PasswordC, CREDUI_MAX_PASSWORD_LENGTH,
        Save, Flags) = NO_ERROR;

      if (CanClose) then
      begin
        if (not SQL_SUCCEEDED(SQLAllocHandle(SQL_HANDLE_DBC, ODBCEnv, @ODBC))) then
          raise ERangeError.Create(SRangeError);

        CanClose := SQL_SUCCEEDED(SQLConnect(ODBC, PSQLTCHAR(PChar(FDataSources.Selected.Caption)), SQL_NTS, PSQLTCHAR(@UsernameC), SQL_NTS, PSQLTCHAR(@PasswordC), SQL_NTS));
        if (not CanClose) then
        begin
          if (SQL_SUCCEEDED(SQLGetDiagRec(SQL_HANDLE_DBC, ODBC, 1, nil, nil, nil, 0, @cbMessageText))) then
          begin
            GetMem(MessageText, (cbMessageText + 1) * SizeOf(SQLTCHAR));
            if (SQL_SUCCEEDED(SQLGetDiagRec(SQL_HANDLE_DBC, ODBC, 1, @SQLState, nil, MessageText, cbMessageText + 1, nil))) then
              MsgBox(PChar(MessageText) + ' (' + SQLState + ')', Preferences.LoadStr(45), MB_OK + MB_ICONERROR);
            FreeMem(MessageText);
          end;
          SQLDisconnect(ODBC);
        end
        else
        begin
          Username := StrPas(PChar(@UsernameC));
          Password := StrPas(PChar(@PasswordC));
        end;
        SQLFreeHandle(SQL_HANDLE_DBC, ODBC);
      end;
    end;
  end;
end;

procedure TDODBC.FormCreate(Sender: TObject);
begin
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  Preferences.ODBC.Left := Left;
  Preferences.ODBC.Top := Top;

  BorderStyle := bsSizeable;

  ZeroMemory(@UsernameC, SizeOf(UsernameC));
  ZeroMemory(@PasswordC, SizeOf(PasswordC));
  Username := 'Admin';
  Password := '';

  LibHandle := LoadLibrary('CredUI.dll');
  if (LibHandle = 0) then RaiseLastOSError();
  CredUIPromptForCredentials := GetProcAddress(LibHandle, 'CredUIPromptForCredentialsW');
  if (not Assigned(CredUIPromptForCredentials)) then RaiseLastOSError();
end;

procedure TDODBC.FormDestroy(Sender: TObject);
begin
  FreeLibrary(LibHandle);
end;

procedure TDODBC.FormHide(Sender: TObject);
begin
  if (ModalResult = mrOk) then
    DataSource := FDataSources.Selected.Caption;

  FDataSources.Items.BeginUpdate();
  FDataSources.Items.Clear();
  FDataSources.Items.EndUpdate();

  Preferences.ODBC.Height := Height;
  Preferences.ODBC.Left := Left;
  Preferences.ODBC.Top := Top;
  Preferences.ODBC.Width := Width;
end;

procedure TDODBC.FormShow(Sender: TObject);
var
  I: Integer;
begin
  Left := Preferences.ODBC.Left;
  Top := Preferences.ODBC.Top;
  if ((Preferences.ODBC.Width >= Width) and (Preferences.ODBC.Height >= Height)) then
  begin
    Height := Preferences.ODBC.Height;
    Width := Preferences.ODBC.Width;
  end;

  FDataSourcesUpdate();

  for I := 0 to FDataSources.Items.Count - 1 do
    if (lstrcmpi(PChar(FDataSources.Items[I].Caption), PChar(DataSource)) = 0) then
    begin
      FDataSources.Selected := FDataSources.Items[I];
      FDataSources.ItemFocused := FDataSources.Items[I];
    end;

  FBOkCheckEnabled(Sender);
  ActiveControl := FDataSources;
end;

procedure TDODBC.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiODBC, Icon);

  Caption := Preferences.LoadStr(907);

  FBManage.Caption := Preferences.LoadStr(13) + '...';

  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDODBC := nil;
end.

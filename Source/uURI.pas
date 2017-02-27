unit uURI;

interface {********************************************************************}

uses
  WinInet,
  SysUtils;

type
  TUURI = class
  private
    FDatabase: string;
    FExtraInfos: string;
    FHost: string;
    FPath: TFileName;
    FScheme: string;
    FTable: string;
    function GetAddress(): string;
    function GetHost(): string;
    function GetParam(AName: string): Variant;
    function GetParamCount(): Integer;
    procedure SetAddress(const AAddress: string);
    procedure SetDatabase(const ADatabase: string);
    procedure SetParam(AName: string; const Value: Variant);
    procedure SetPath(const APath: TFileName);
    procedure SetScheme(const AScheme: string);
    procedure SetTable(const ATable: string);
  public
    Username: string;
    Password: string;
    Port: INTERNET_PORT;
    procedure Clear(); virtual;
    constructor Create(const AAddress: string = ''); virtual;
    property Address: string read GetAddress write SetAddress;
    property Database: string read FDatabase write SetDatabase;
    property Host: string read GetHost write FHost;
    property ExtraInfos: string read FExtraInfos write FExtraInfos;
    property Param[Name: string]: Variant read GetParam write SetParam;
    property ParamCount: Integer read GetParamCount;
    property Path: TFileName read FPath write SetPath;
    property Scheme: string read FScheme write SetScheme;
    property Table: string read FTable write SetTable;
  end;

function EscapeURL(const URL: string): string;
function UnescapeURL(const AParam: string): string;
function PathToURI(const APath: TFileName): string;
function URIToPath(const AURI: string): TFileName;
function ExtractURIHost(const AURI: string): string;

implementation {***************************************************************}

uses
  ShLwApi, Windows,
  RTLConsts, Variants, Classes, StrUtils,
  MySQLConsts;

function PathToURI(const APath: TFileName): string;
var
  Size: DWord;
  URL: Pointer;
begin
  URL := nil;

  try
    Size := (INTERNET_MAX_URL_LENGTH + 1) * SizeOf(Char);
    GetMem(URL, Size);
    if (UrlCreateFromPath(PChar(APath), URL, @Size, 0) <> S_OK) then
      raise EConvertError.CreateFmt(SConvStrParseError, [APath]);

    Result := PChar(URL);
  finally
    FreeMem(URL);
  end;
end;

function URIToPath(const AURI: string): TFileName;
var
  PathP: Pointer;
  Size: DWord;
begin
  PathP := nil;

  try
    Size := 2 * Length(AURI) + 1;
    GetMem(PathP, Size);
    if (PathCreateFromUrl(PChar(AURI), PathP, @Size, 0) <> S_OK) then
      raise EConvertError.CreateFmt(SConvStrParseError, [AURI]);

    Result := PChar(PathP);
  finally
    FreeMem(PathP);
  end;
end;

function ExtractURIHost(const AURI: string): string;
var
  URI: TUURI;
begin
  URI := TUURI.Create(AURI);

  Result := URI.FHost;

  URI.Free();
end;

function UnescapeURL(const AParam: string): string;
var
  Len: DWord;
  UnescapedURL: PChar;
begin
  Len := Length(AParam) + 1;
  GetMem(UnescapedURL, Len * SizeOf(UnescapedURL[0]));

  try
    if (UrlUnescape(PChar(AParam), UnescapedURL, @Len, 0) <> S_OK) then
      raise EConvertError.CreateFmt(SConvStrParseError, [AParam]);

    SetString(Result, UnescapedURL, Len);
  finally
    if (Assigned(UnescapedURL)) then
      FreeMem(UnescapedURL);
  end;
end;

function EscapeURL(const URL: string): string;
var
  C: Char;
  R: HRESULT;
  Len: DWord;
begin
  if (URL = '') then
    Result := ''
  else
  begin
    Len := 1;
    R := UrlEscape(PChar(URL), @C, @Len, 0);
    if ((R <> S_OK) and (R <> E_POINTER)) then
      RaiseLastOSError()
    else
    begin
      SetLength(Result, Len);
      if (UrlEscape(PChar(URL), PChar(Result), @Len, 0) <> S_OK) then
        RaiseLastOSError();
      SetLength(Result, Len); // Remove ending #0
    end;
  end;
end;

{ TUURI ***********************************************************************}

procedure TUURI.Clear();
begin
  FDatabase := '';
  FExtraInfos := '';
  FHost := '';
  FPath := '';
  FTable := '';
  Password := '';
  Port := 0;
  Scheme := '';
  Username := '';
end;

constructor TUURI.Create(const AAddress: string = '');
begin
  inherited Create();

  Address := AAddress;
end;

function TUURI.GetAddress(): string;
var
  Len: DWORD;
  URL: array [0 .. INTERNET_MAX_URL_LENGTH] of Char;
  URLComponents: TURLComponents;
begin
  ZeroMemory(@URLComponents, SizeOf(URLComponents));
  URLComponents.dwStructSize := SizeOf(URLComponents);

  if (FHost <> '') then
  begin
    if (Scheme = '') then
      URLComponents.lpszScheme := 'mysql'
    else
      URLComponents.lpszScheme := PChar(Scheme);
    URLComponents.lpszHostName := PChar(FHost);
    if (Port <> MYSQL_PORT) then
      URLComponents.nPort := Port;
    if (Username <> '') then
    begin
      URLComponents.lpszUserName := PChar(EscapeURL(Username));
      if (Password <> '') then
        URLComponents.lpszPassword := PChar(EscapeURL(Password));
    end;
    if (Path = '') then
      URLComponents.lpszUrlPath := '/'
    else
      URLComponents.lpszUrlPath := PChar(EscapeURL(Path));
    URLComponents.lpszExtraInfo := PChar(FExtraInfos);
  end;

  Len := Length(URL) - 1;
  if (not InternetCreateUrl(URLComponents, 0, @URL, Len)) then
    RaiseLastOSError()
  else
    SetString(Result, PChar(@URL), Len);
end;

function TUURI.GetHost(): string;
begin
  if ((LeftStr(FHost, 1) = '[') and (RightStr(FHost, 1) = ']')) then
    Result := Copy(FHost, 2, Length(FHost) - 2)
  else
    Result := FHost;
end;

function TUURI.GetParam(AName: string): Variant;
var
  I: Integer;
  Items: TStringList;
begin
  if (Length(FExtraInfos) <= 1) then
    Result := Null
  else
  begin
    Items := TStringList.Create();
    Items.Text := ReplaceStr(Copy(FExtraInfos, 2, Length(FExtraInfos) - 1), '&', #13#10);

    Result := Items.Values[AName];

    if (Result = '') then
    begin
      Result := Null;
      for I := 0 to Items.Count - 1 do
        if (AName + '=' = Items[I]) then
          Result := '';
    end;

    Items.Free();
  end;
end;

function TUURI.GetParamCount(): Integer;
var
  Items: TStringList;
begin
  if (Length(FExtraInfos) < 1) then
    Result := 0
  else
  begin
    Items := TStringList.Create();
    Items.Text := ReplaceStr(Copy(FExtraInfos, 2, Length(FExtraInfos) - 1), '&', #13#10);

    Result := Items.Count;

    Items.Free();
  end;
end;

procedure TUURI.SetAddress(const AAddress: string);
var
  Buffer: array [0..128] of Char;
  ErrorMessage: string;
  Len: DWORD;
  URLComponents: TURLComponents;
  URLComponentsExtraInfo: array [0 .. INTERNET_MAX_PATH_LENGTH] of Char;
  URLComponentsHostName: array [0 .. INTERNET_MAX_HOST_NAME_LENGTH] of Char;
  URLComponentsPassword: array [0 .. INTERNET_MAX_PASSWORD_LENGTH] of Char;
  URLComponentsPath: array [0 .. INTERNET_MAX_PATH_LENGTH] of Char;
  URLComponentsSchemeName: array [0 .. INTERNET_MAX_SCHEME_LENGTH] of Char;
  URLComponentsUserName: array [0 .. INTERNET_MAX_USER_NAME_LENGTH] of Char;
begin
  Clear();

  if (AAddress <> '') then
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

    if (not InternetCrackUrl(PChar(AAddress), Length(AAddress), 0, URLComponents)) then
    begin
      Len := FormatMessage(FORMAT_MESSAGE_FROM_HMODULE,
        Pointer(GetModuleHandle('Wininet.dll')), GetLastError(), 0, @Buffer, Length(Buffer), nil);
      while (Len > 0) and (CharInSet(Buffer[Len - 1], [#0..#32])) do Dec(Len);
      SetString(ErrorMessage, Buffer, Len);
      ErrorMessage := ErrorMessage + #13#10 + 'URL: ' + AAddress;
      raise EConvertError.Create(ErrorMessage);
    end;

    Scheme := URLComponents.lpszScheme;
    Username := UnescapeURL(URLComponents.lpszUserName);
    Password := UnescapeURL(URLComponents.lpszPassword);
    FHost := URLComponents.lpszHostName;
    if (URLComponents.nPort = 0) then
      Port := MYSQL_PORT
    else
      Port := URLComponents.nPort;
    Path := UnescapeURL(URLComponents.lpszUrlPath);
    if (URLComponents.dwExtraInfoLength = 0) then
      FExtraInfos := ''
    else
      FExtraInfos := StrPas(URLComponents.lpszExtraInfo);
  end;
end;

procedure TUURI.SetDatabase(const ADatabase: string);
begin
  FDatabase := ADatabase;
  FTable := '';

  if (FDatabase = '') then
    FPath := '/'
  else
    FPath := '/' + EscapeURL(FDatabase) + '/';
end;

procedure TUURI.SetParam(AName: string; const Value: Variant);
var
  Items: TStringList;
begin
  Items := TStringList.Create();
  if (Length(FExtraInfos) > 1) then
    Items.Text := ReplaceStr(Copy(FExtraInfos, 2, Length(FExtraInfos) - 1), '&', #13#10);

  if (Value = Null) then
    Items.Values[AName] := ''
  else
    Items.Values[AName] := Value;

  Items.Sort();

  FExtraInfos := ReplaceStr(Trim(Items.Text), #13#10, '&');

  if (FExtraInfos <> '') then
    FExtraInfos := '?' + FExtraInfos;

  Items.Free();
end;

procedure TUURI.SetPath(const APath: TFileName);
begin
  if (Pos('/', APath) <> 1) then
  begin
    FDatabase := '';
    FTable := '';
    FPath := '';
  end
  else
  begin
    FDatabase := Copy(APath, 2, Length(APath) - 1);
    if (copy(FDatabase, Length(FDatabase), 1) = '/') then
      Delete(FDatabase, Length(FDatabase), 1);
    if (Pos('/', FDatabase) > 0) then
    begin
      FTable := Copy(FDatabase, Pos('/', FDatabase) + 1, Length(FDatabase) - Pos('/', FDatabase));
      Delete(FDatabase, Pos('/', FDatabase), Length(FDatabase) - Pos('/', FDatabase) + 1);
    end;
    FDatabase := UnescapeURL(FDatabase);
    FTable := UnescapeURL(FTable);
    FPath := APath;
  end;
end;

procedure TUURI.SetScheme(const AScheme: string);
begin
  FScheme := LowerCase(AScheme);
end;

procedure TUURI.SetTable(const ATable: string);
begin
  FTable := ATable;

  if (FDatabase = '') then
    FPath := '/'
  else if (FTable = '') then
    FPath := '/' + EscapeURL(FDatabase) + '/'
  else
    FPath := '/' + EscapeURL(FDatabase) + '/' + EscapeURL(FTable) + '/';
end;

end.



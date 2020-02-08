unit HTTPTunnel;

interface {********************************************************************}

uses
  Windows, WinInet,
  SyncObjs,
  MySQLClient, MySQLConsts;

const
  CR_HTTPTUNNEL_UNKNOWN_ERROR              = 2200;
  CR_HTTPTUNNEL_OLD                        = 2201;
  CR_HTTPTUNNEL_CONN_ERROR                 = 2202;
  CR_HTTPTUNNEL_ACCESS_DENIED_ERROR        = 2203;
  CR_HTTPTUNNEL_NOT_FOUND                  = 2204;
  CR_HTTPTUNNEL_UNKNOWN_HOST               = 2205;
  CR_HTTPTUNNEL_INVALID_CONTENT_TYPE_ERROR = 2206;
  CR_HTTPTUNNEL_INVALID_SERVER_RESPONSE    = 2207;
  CR_HTTPTUNNEL_HTTP_CONNECTION            = 2208;
  CR_HTTPTUNNEL_UNKNOWN_SID                = 2209;
  CR_HTTPTUNNEL_SERVER_ERROR               = 2210;
  CR_HTTPTUNNEL_REDIRECT                   = 2211;

  MYSQL_OPT_HTTPTUNNEL_URL   = 240;
  MYSQL_OPT_HTTPTUNNEL_AGENT = 241;

type
  PPChar = ^PChar;

  MYSQL = class(MySQLClient.MYSQL)
  private
    Agent: string;
    Connection: HInternet;
    Handle: HInternet;
    LastRequest: TDateTime;
    SendBuffer: TMySQL_Packet.TBuffer;
    Request: HInternet;
    RequestComplete: TEvent;
    ResponseReceived: TEvent;
    SecurityFlags: ULONG;
    SID: string;
    URL: string;
    URLComponents: TURLComponents;
    function ExecuteHTTPRequest(const Connect: Boolean): Boolean;
  protected
    procedure Close(); override;
    function ExecuteCommand(const Command: enum_server_command;
      const Bin: my_char; const Size: my_int; const Retry: Boolean): my_int; override;
    function Receive(var Buffer; const BytesToRead: my_uint): Boolean; override;
    function ReceiveExitText(out Text: RawByteString): Boolean; virtual;
    function Send(const Buffer; const BytesToWrite: my_uint): Boolean; override;
  public
    constructor Create(); override;
    destructor Destroy(); override;
    function get_host_info(): my_char; override;
    function options(option: enum_mysql_option; const arg: my_char): my_int; override;
    function real_connect(host, user, passwd, db: my_char; port: my_uint; unix_socket: my_char; client_flag: my_uint): MySQLClient.MYSQL; override;
  end;
  TMYSQL = MYSQL;

function mysql_init(mysql: MYSQL): MYSQL; stdcall;

implementation {***************************************************************}

uses
  SysUtils, StrUtils, AnsiStrings,
  Forms,
  SQLUtils;

const
  OldMFVersions = [0..15, 17, 23..25];

const
  PROTOCOL_VERSION      = 10;

  HTTPTTUNNEL_ERRORS: array [0..11] of PChar = (
    'Unknown HTTP Tunnel error (# %d)',                                      {0}
    'HTTP Tunnel script (%s) is too old - please update',                    {1}
    'Can''t connect to MySQL server through HTTP Tunnel ''%s'' (# %d)',      {2}
    'Access denied (403)',                                                   {3}
    'File Not Found (404):  ''%s''',                                         {4}
    'Unknown HTTP Server Host ''%s'' (# %d)',                                {5}
    'Invalid HTTP content type (''%s'').',                                   {6}
    'The HTTP server response could not be parsed (%s):' + #10#10 + '%s',    {7}
    '%-.64s via HTTP',                                                       {8}
    'Unknown PHP Session ID',                                                {9}
    'HTTP server error (500)',                                              {10}
    'HTTP redirects are not supported'                                      {11}
  );

{******************************************************************************}

procedure InternetStatusCallback(Handle: HINTERNET; Context, dwInternetStatus: DWord; lpvStatusInformation: PInternetAsyncResult; StatusInformationLength: DWord); stdcall;
var
  mysql: TMYSQL;
begin
  mysql := TMYSQL(Context);

  case (dwInternetStatus) of
    INTERNET_STATUS_RESPONSE_RECEIVED: mysql.ResponseReceived.SetEvent();
    INTERNET_STATUS_REQUEST_COMPLETE: mysql.RequestComplete.SetEvent();
  end;
end;

{ C API ***********************************************************************}

function mysql_init(mysql: MYSQL): MYSQL;
begin
  if (Assigned(mysql)) then
    Result := mysql
  else
    Result := HTTPTunnel.MYSQL.Create();
end;

{ MYSQL ***********************************************************************}

procedure MYSQL.Close();
begin
  if (SendBuffer.Size - SendBuffer.Offset > 0) then
    ExecuteHTTPRequest(False);

  if (Assigned(Request)) then
    InternetCloseHandle(Request);

  if (Assigned(Connection)) then
    InternetCloseHandle(Connection);

  if (Assigned(Handle)) then
  begin
    InternetSetStatusCallback(Handle, nil);
    InternetCloseHandle(Handle);
  end;

  SID := '';

  inherited;

  if (Assigned(SendBuffer.Mem)) then
    FreeBuffer(SendBuffer);
end;

constructor MYSQL.Create();
begin
  inherited;

  Agent := LoadStr(1000);
  Connection := nil;
  Handle := nil;
  LastRequest := 0;
  SecurityFlags := SECURITY_FLAG_IGNORE_REVOCATION or SECURITY_FLAG_IGNORE_UNKNOWN_CA or SECURITY_FLAG_IGNORE_WRONG_USAGE or SECURITY_FLAG_IGNORE_CERT_CN_INVALID or SECURITY_FLAG_IGNORE_CERT_DATE_INVALID;

  SID := '';
  URL := '';

  FillChar(SendBuffer, SizeOf(SendBuffer), #0);

  URLComponents.dwStructSize := SizeOf(URLComponents);
  GetMem(URLComponents.lpszScheme, INTERNET_MAX_SCHEME_LENGTH);
  GetMem(URLComponents.lpszHostName, INTERNET_MAX_HOST_NAME_LENGTH);
  GetMem(URLComponents.lpszUserName, INTERNET_MAX_USER_NAME_LENGTH);
  GetMem(URLComponents.lpszPassword, INTERNET_MAX_PASSWORD_LENGTH);
  GetMem(URLComponents.lpszUrlPath, INTERNET_MAX_PATH_LENGTH);
  GetMem(URLComponents.lpszExtraInfo, 256);

  ResponseReceived := TEvent.Create(nil, False, False, '');
  RequestComplete := TEvent.Create(nil, True, False, '');
end;

destructor MYSQL.Destroy();
begin
  inherited;

  ResponseReceived.Free();
  RequestComplete.Free();

  FreeMem(URLComponents.lpszScheme);
  FreeMem(URLComponents.lpszHostName);
  FreeMem(URLComponents.lpszUserName);
  FreeMem(URLComponents.lpszPassword);
  FreeMem(URLComponents.lpszUrlPath);
  FreeMem(URLComponents.lpszExtraInfo);
end;

function MYSQL.ExecuteHTTPRequest(const Connect: Boolean): Boolean;
var
  Flags: Cardinal;
  Headers: string;
  HttpRequestError: Longint;
  Index: DWord;
  InternetError: Longint;
  ObjectName: string;
  pvData: Pointer;
  QueryInfo: array [0..2048] of Char;
  RBS: RawByteString;
  S: string;
  Size: DWord;
  StatusCode: array [0..4] of Char;
begin
  if (Assigned(Request)) then
    InternetCloseHandle(Request);

  ResponseReceived.ResetEvent();
  RequestComplete.ResetEvent();

  if (errno() = 0) then
  begin
    ObjectName := '';
    if (URLComponents.dwUrlPathLength > 0) then
      ObjectName := ObjectName + URLComponents.lpszUrlPath;
    if (URLComponents.dwExtraInfoLength > 0) then
      ObjectName := ObjectName + URLComponents.lpszExtraInfo;
    if (SID <> '') then
      if (URLComponents.dwExtraInfoLength = 0) then
        ObjectName := ObjectName + '?SID=' + SID
      else
        ObjectName := ObjectName + '&SID=' + SID;

    Flags := INTERNET_FLAG_NO_AUTO_REDIRECT or INTERNET_FLAG_RESYNCHRONIZE or INTERNET_FLAG_NO_CACHE_WRITE or INTERNET_FLAG_NO_UI or INTERNET_FLAG_KEEP_CONNECTION;
    if (SID = '') then
      Flags := Flags or INTERNET_FLAG_NO_COOKIES;
    if (URLComponents.lpszScheme = 'https') then
      Flags := Flags or INTERNET_FLAG_SECURE;

    Request := HttpOpenRequest(Connection, 'POST', PChar(ObjectName), 'HTTP/1.1', nil, nil, Flags, Cardinal(Self));
    if (not Assigned(Request)) then
      Seterror(CR_IPSOCK_ERROR)
    else
    begin
      InternetSetOption(Request, INTERNET_OPTION_SECURITY_FLAGS, @SecurityFlags, SizeOf(SecurityFlags));

      Headers := 'Content-Type: application/mysql-front' + #10;
	    Headers := Headers + 'Content-Transfer-Encoding: binary' + #10;
      Headers := Headers + 'Keep-Alive: 300' + #10;
      if (not Connect) then
        Headers := Headers + 'Referer: ' + URL + #10;

      repeat
        if (not HttpSendRequest(Request, PChar(Headers), Length(Headers), @SendBuffer.Mem[SendBuffer.Offset], SendBuffer.Size - SendBuffer.Offset)) then
        begin
          HttpRequestError := GetLastError();

          InternetError := InternetErrorDlg(Application.MainForm.Handle, Request, HttpRequestError,
            FLAGS_ERROR_UI_FILTER_FOR_ERRORS or FLAGS_ERROR_UI_FLAGS_CHANGE_OPTIONS or FLAGS_ERROR_UI_FLAGS_GENERATE_DATA, pvData);
        end
        else
        begin
          HttpRequestError := 0;
          InternetError := 0;
        end;
      until ((InternetError <> ERROR_INTERNET_FORCE_RETRY) and not ((InternetError = 0) and ((HttpRequestError = ERROR_INTERNET_SEC_CERT_DATE_INVALID) or (HttpRequestError = ERROR_INTERNET_INVALID_CA) or (HttpRequestError = 12057))));

      case (HttpRequestError) of
        NOERROR:
          begin
            SendBuffer.Offset := 0;
            SendBuffer.Size := 0;

            SecurityFlags := 0; Size := SizeOf(SecurityFlags);
            InternetQueryOption(Request, INTERNET_OPTION_SECURITY_FLAGS, @SecurityFlags, Size);

            ZeroMemory(@StatusCode, SizeOf(StatusCode));
            repeat
              ResponseReceived.WaitFor(50);
              Size := SizeOf(StatusCode); Index := 0;
            until (HttpQueryInfo(Request, HTTP_QUERY_STATUS_CODE, @StatusCode, Size, Index) or (Size = 0) or (SysUtils.StrToInt(StatusCode) <> 0));

            case (SysUtils.StrToInt(StatusCode)) of
              HTTP_STATUS_FORBIDDEN:
                begin
                  Seterror(CR_HTTPTUNNEL_ACCESS_DENIED_ERROR, RawByteString(StatusCode));
                  Size := SizeOf(QueryInfo); Index := 0;
                  if (HttpQueryInfo(Request, HTTP_QUERY_STATUS_TEXT, @QueryInfo, Size, Index)) then
                    Seterror(CR_HTTPTUNNEL_ACCESS_DENIED_ERROR, error() + ' ' + RawByteString(QueryInfo));
                end;
              HTTP_STATUS_REDIRECT,
              HTTP_STATUS_REDIRECT_METHOD:
                begin
                  Size := SizeOf(QueryInfo); Index := 0;
                  if (HttpQueryInfo(Request, HTTP_QUERY_LOCATION, @QueryInfo, Size, Index)) then
                  begin
                    SetString(ObjectName, PChar(@QueryInfo), Size);
                    SetString(S, URLComponents.lpszExtraInfo, URLComponents.dwExtraInfoLength);
                    if (S <> '') then
                      ObjectName := ObjectName + S;
                    Seterror(CR_HTTPTUNNEL_REDIRECT);
                  end;
                end;
              HTTP_STATUS_NOT_FOUND:
                Seterror(CR_HTTPTUNNEL_NOT_FOUND, RawByteString(Format(HTTPTTUNNEL_ERRORS[CR_HTTPTUNNEL_NOT_FOUND - CR_HTTPTUNNEL_UNKNOWN_ERROR], [ObjectName])));
              HTTP_STATUS_OK:
                begin
                  Size := SizeOf(QueryInfo);
                  if (HttpQueryInfo(Request, HTTP_QUERY_CONTENT_TYPE, @QueryInfo, Size, Index) and (LowerCase(QueryInfo) <> 'application/mysql-front')) then
                    if (not ReceiveExitText(RBS)) then
                      Seterror(CR_HTTPTUNNEL_INVALID_CONTENT_TYPE_ERROR, RawByteString(Format(HTTPTTUNNEL_ERRORS[CR_HTTPTUNNEL_INVALID_CONTENT_TYPE_ERROR - CR_HTTPTUNNEL_UNKNOWN_ERROR], [QueryInfo])))
                    else
                      Seterror(CR_HTTPTUNNEL_INVALID_SERVER_RESPONSE, RawByteString(Format(HTTPTTUNNEL_ERRORS[CR_HTTPTUNNEL_INVALID_SERVER_RESPONSE - CR_HTTPTUNNEL_UNKNOWN_ERROR], [URL, string(RBS)])));
                end;
              else
                begin
                  Size := SizeOf(QueryInfo); Index := 0;
                  if (not HttpQueryInfo(Request, HTTP_QUERY_STATUS_TEXT, @QueryInfo, Size, Index)) then
                    Seterror(CR_HTTPTUNNEL_SERVER_ERROR, RawByteString(StatusCode))
                  else
                    Seterror(CR_HTTPTUNNEL_SERVER_ERROR, RawByteString(StatusCode) + ' ' + RawByteString(QueryInfo));
                end;
            end;
          end;
        ERROR_IO_PENDING: ResponseReceived.WaitFor(NET_WAIT_TIMEOUT * 1000);
        ERROR_INTERNET_CANNOT_CONNECT,
        ERROR_INTERNET_CONNECTION_RESET,
        ERROR_INTERNET_TIMEOUT:
          if (IOType = itNone) then
            Seterror(CR_CONN_HOST_ERROR, RawByteString(Format(HTTPTTUNNEL_ERRORS[CR_HTTPTUNNEL_CONN_ERROR - CR_HTTPTUNNEL_UNKNOWN_ERROR], [ObjectName, GetLastError()])))
          else
            Seterror(CR_SERVER_GONE_ERROR);
        ERROR_INTERNET_NAME_NOT_RESOLVED:
          Seterror(CR_UNKNOWN_HOST, RawByteString(Format(HTTPTTUNNEL_ERRORS[CR_HTTPTUNNEL_UNKNOWN_HOST - CR_HTTPTUNNEL_UNKNOWN_ERROR], [URLComponents.lpszHostName, GetLastError()])));
        ERROR_HTTP_INVALID_SERVER_RESPONSE:
          Seterror(CR_SERVER_HANDSHAKE_ERR);
        else
          Seterror(CR_HTTPTUNNEL_UNKNOWN_ERROR, RawByteString(Format(HTTPTTUNNEL_ERRORS[CR_HTTPTUNNEL_UNKNOWN_ERROR - CR_HTTPTUNNEL_UNKNOWN_ERROR], [HttpRequestError])));
      end;
    end;

    LastRequest := Now();
  end;

  Result := errno() = 0;
end;

function MYSQL.get_host_info(): my_char;
begin
  if (fhost_info = '') then
    fhost_info := EncodeString(Format(HTTPTTUNNEL_ERRORS[CR_HTTPTUNNEL_HTTP_CONNECTION - CR_HTTPTUNNEL_UNKNOWN_ERROR], [fhost]));

  Result := my_char(fhost_info);
end;


function MYSQL.options(option: enum_mysql_option; const arg: my_char): my_int;
begin
  Result := 0;

  case (Integer(option)) of
    MYSQL_OPT_HTTPTUNNEL_URL: URL := DecodeString(RawByteString(arg));
    MYSQL_OPT_HTTPTUNNEL_AGENT: Agent := DecodeString(RawByteString(arg));
    else Result := inherited options(option, arg);
  end;
end;

function MYSQL.ExecuteCommand(const Command: enum_server_command; const Bin: my_char; const Size: my_int; const Retry: Boolean): my_int;
var
  Packet: my_char;
  PacketLen: Integer;
  SQL: string;
  SQLIndex: Integer;
  SQLLen: Integer;
  SQLStmtLen: Integer;
  StmtLen: Integer;
begin
  SendBuffer.Offset := 0;
  SendBuffer.Size := 0;

  Seterror(0);
  next_command();

  if (Command = COM_QUERY) then
  begin
    GetMem(Packet, Size);

    SQLLen := MultiByteToWideChar(CodePage, MB_ERR_INVALID_CHARS, Bin, Size, nil, 0);
    SetLength(SQL, SQLLen);
    MultiByteToWideChar(CodePage, MB_ERR_INVALID_CHARS, Bin, Size, PChar(SQL), Length(SQL));

    SQLIndex := 0;
    while (SQLIndex < SQLLen) do
    begin
      SQLStmtLen := SQLStmtLength(@PChar(SQL)[SQLIndex], SQLLen - SQLIndex);

      StmtLen := SQLStmtLength(@PChar(SQL)[SQLIndex], SQLStmtLen);

      if (StmtLen > 0) then
      begin
        PacketLen := WideCharToMultiByte(CodePage, 0, PChar(@PChar(SQL)[SQLIndex]), StmtLen, Packet, Size, nil, nil);

        if (GetPacketSize() > 0) then
          SetPacketPointer(1, PACKET_CURRENT);
        WritePacket(@Command, 1);
        WritePacket(Packet, PacketLen);
      end;

      Inc(SQLIndex, SQLStmtLen);
    end;

    FreeMem(Packet);
  end
  else
  begin
    WritePacket(Bin, Size);
  end;

  if ((FlushPacketBuffers() or (errno() = CR_SERVER_GONE_ERROR)) and ExecuteHTTPRequest(False) and (next_result() <= 0)) then
    Result := 0
  else
  begin
    if (errno() = 0) then
      Seterror(CR_SERVER_LOST);
    Result := 1;
  end;
end;

function MYSQL.real_connect(host, user, passwd, db: my_char; port: my_uint; unix_socket: my_char; client_flag: my_uint): MySQLClient.MYSQL;
var
  Buffer: array [0..127] of Char;
  CharsetNr: my_uint;
  Command: AnsiChar;
  ErrorMessage: string;
  I: Integer;
  Index: DWord;
  L: Longint;
  Len: Integer;
  ObjectName: string;
  ProtocolVersion: my_int;
  QueryInfo: array [0..2048] of Char;
  RBS: RawByteString;
  S: string;
  Salt: RawByteString;
  Size: DWord;
begin
  if (IOType <> itNone) then
    Seterror(CR_ALREADY_CONNECTED)
  else
  begin
    if (host = '') then
      fhost := LOCAL_HOST
    else
      fhost := host;
    fuser := user;
    fpasswd := passwd;
    fdb := db;
    if (port = 0) then
      fport := MYSQL_PORT
    else
      fport := port;
    if (AnsiStrings.StrLen(unix_socket) > 0) then
      Seterror(CR_SOCKET_CREATE_ERROR)
    else
    begin
      fpipe_name := '';
      CAPABILITIES := client_flag or CLIENT_CAPABILITIES or CLIENT_LONG_PASSWORD;
      if (fdb = '') then
        CAPABILITIES := CAPABILITIES and not CLIENT_CONNECT_WITH_DB;

      Handle := InternetOpen(PChar(Agent), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

      if (not Assigned(Handle)) then
        RaiseLastOSError()
      else
      begin
        InternetSetStatusCallback(Handle, @InternetStatusCallback);

        // Timeout seems not to work (Windows 7)
        L := ftimeout * 1000;
        InternetSetOption(Handle, INTERNET_OPTION_CONNECT_TIMEOUT, @L, SizeOf(L));

        L := NET_WAIT_TIMEOUT * 1000;
        InternetSetOption(Handle, INTERNET_OPTION_RECEIVE_TIMEOUT, @L, SizeOf(L));
        L := NET_WRITE_TIMEOUT * 1000;
        InternetSetOption(Handle, INTERNET_OPTION_SEND_TIMEOUT, @L, SizeOf(L));

        repeat
          Seterror(0);
          if (Assigned(Connection)) then
            InternetCloseHandle(Connection);

          URLComponents.dwSchemeLength := INTERNET_MAX_SCHEME_LENGTH;
          URLComponents.dwHostNameLength := INTERNET_MAX_HOST_NAME_LENGTH;
          URLComponents.dwUserNameLength := INTERNET_MAX_USER_NAME_LENGTH;
          URLComponents.dwPasswordLength := INTERNET_MAX_PASSWORD_LENGTH;
          URLComponents.dwUrlPathLength := INTERNET_MAX_PATH_LENGTH;
          URLComponents.dwExtraInfoLength := 256;
          if (not InternetCrackUrl(PChar(URL), Length(URL), ICU_DECODE, URLComponents)) then
          begin
            Len := FormatMessage(FORMAT_MESSAGE_FROM_HMODULE,
              Pointer(GetModuleHandle('Wininet.dll')), GetLastError(), 0, @Buffer, Length(Buffer), nil);
            while (Len > 0) and (CharInSet(Buffer[Len - 1], [#0..#32])) do Dec(Len);
            SetString(ErrorMessage, Buffer, Len);
            raise EConvertError.Create(ErrorMessage + #10 + 'URL: ' + URL);
          end;

          Connection := InternetConnect(Handle, URLComponents.lpszHostName, URLComponents.nPort, URLComponents.lpszUserName, URLComponents.lpszPassword, INTERNET_SERVICE_HTTP, 0, Cardinal(Self));
          if (not Assigned(Connection)) then
            Seterror(CR_HTTPTUNNEL_CONN_ERROR, RawByteString(Format(HTTPTTUNNEL_ERRORS[CR_HTTPTUNNEL_CONN_ERROR - CR_HTTPTUNNEL_UNKNOWN_ERROR], [URL, 0])))
          else
          begin
            Direction := idWrite;

            Command := AnsiChar(COM_CONNECT);
            WritePacket(@Command, SizeOf(Command));
            if (lstrcmpi(URLComponents.lpszHostName, PChar(DecodeString(fhost))) = 0) then
              WritePacket(LOCAL_HOST)
            else
              WritePacket(RawByteString(fhost));
            WritePacket(RawByteString(fuser));
            WritePacket(RawByteString(fpasswd));
            WritePacket(RawByteString(fdb));
            WritePacket(RawByteString(fcharacter_set_name));
            WritePacket(fport, 2);
            WritePacket(CAPABILITIES, 4);
            WritePacket(ftimeout, 2);
            FlushPacketBuffers();

            if (ExecuteHTTPRequest(True)) then
            begin
              StrPCopy(@Buffer, 'MF-Version'); Size := SizeOf(Buffer); Index := 0;
              if (not HttpQueryInfo(Request, HTTP_QUERY_CUSTOM, @Buffer, Size, Index)) then
                if (not ReceiveExitText(RBS)) then
                  Seterror(CR_HTTPTUNNEL_INVALID_CONTENT_TYPE_ERROR, my_char(RawByteString(Format(HTTPTTUNNEL_ERRORS[CR_HTTPTUNNEL_INVALID_CONTENT_TYPE_ERROR - CR_HTTPTUNNEL_UNKNOWN_ERROR], [QueryInfo]))))
                else
                begin
                  ObjectName := '';
                  if (URLComponents.dwUrlPathLength > 0) then
                    ObjectName := ObjectName + URLComponents.lpszUrlPath;
                  if (URLComponents.dwExtraInfoLength > 0) then
                    ObjectName := ObjectName + URLComponents.lpszExtraInfo;
                  Seterror(CR_HTTPTUNNEL_INVALID_SERVER_RESPONSE, RawByteString(Format(HTTPTTUNNEL_ERRORS[CR_HTTPTUNNEL_INVALID_SERVER_RESPONSE - CR_HTTPTUNNEL_UNKNOWN_ERROR], [ObjectName, string(RBS)])));
                end
              else if (StrToInt(StrPas(PChar(@Buffer))) in OldMFVersions) then
                Seterror(CR_HTTPTUNNEL_OLD, RawByteString(Format(HTTPTTUNNEL_ERRORS[CR_HTTPTUNNEL_OLD - CR_HTTPTUNNEL_UNKNOWN_ERROR], [URL])))
              else
              begin
                Size := SizeOf(Buffer); Index := 0;

                StrPCopy(@Buffer, 'MF-SID'); Size := SizeOf(Buffer); Index := 0;
                if (HttpQueryInfo(Request, HTTP_QUERY_CUSTOM, @Buffer, Size, Index)) then
                  SID := PChar(@Buffer)
                else
                  Seterror(CR_HTTPTUNNEL_UNKNOWN_SID, RawByteString(Format(HTTPTTUNNEL_ERRORS[CR_HTTPTUNNEL_UNKNOWN_SID - CR_HTTPTUNNEL_UNKNOWN_ERROR], [])));

                Direction := idRead;

                IOType := TMYSQL_IO.TType(Integer(High(TMYSQL_IO.TType)) + 1);
              end;

              if (SetPacketPointer(1, PACKET_CURRENT) < 0) then
                // errno() has been set by SetFilePointer()
              else if (ServerError()) then
                // errno() has been set by ServerError()
              else if (not ReadPacket(ProtocolVersion, 1)) then
                // errno() has been set by ReadFile()
              else if (ProtocolVersion <> PROTOCOL_VERSION) then
                Seterror(CR_VERSION_ERROR, EncodeString(Format(CLIENT_ERRORS[CR_VERSION_ERROR - CR_MIN_ERROR], [ProtocolVersion, PROTOCOL_VERSION])))
              else
              begin
                ReadPacket(fserver_info);
                ReadPacket(fthread_id, 4);
                ReadPacket(Salt);
                ReadPacket(SERVER_CAPABILITIES, 2);
                ReadPacket(CharsetNr, 1);
                ReadPacket(SERVER_STATUS, 2);

                if ((SetPacketPointer(13, FILE_CURRENT) + 1 < GetPacketSize()) and ReadPacket(RBS)) then
                  Salt := Salt + RBS
                else if (get_server_version() <> 40100) then
                  SERVER_CAPABILITIES := SERVER_CAPABILITIES and not CLIENT_SECURE_CONNECTION;

                if (errno() = 0) then
                begin
                  S := DecodeString(fserver_info);
                  if (Pos('-', S) > 0) then
                    S := LeftStr(S, Pos('-', S) - 1);
                  if ((Pos('.', S) = 0) or not TryStrToInt(LeftStr(S, Pos('.', S) - 1), I)) then
                    fserver_version := 0
                  else
                  begin
                    fserver_version := I * 10000;
                    Delete(S, 1, Pos('.', S));
                    if ((Pos('.', S) = 0) or not TryStrToInt(LeftStr(S, Pos('.', S) - 1), I)) then
                      fserver_version := 0
                    else
                    begin
                      fserver_version := fserver_version + my_uint(I) * 100;
                      Delete(S, 1, Pos('.', S));
                      TryStrToInt(S, I);
                      fserver_version := fserver_version + my_uint(I);
                    end;
                  end;

                  CAPABILITIES := CAPABILITIES and ($FFFF2481 or ($0000DB7E and SERVER_CAPABILITIES));
                  if (get_server_version() < 40101) then
                    CAPABILITIES := CAPABILITIES and $FFFFF
                  else if ((SERVER_CAPABILITIES and CLIENT_RESERVED <> 0) and (get_server_version() < 50000)) then
                    CAPABILITIES := CAPABILITIES or CLIENT_PROTOCOL_41 or CLIENT_RESERVED; //  CLIENT_PROTOCOL_41 has in some older 4.1.xx versions the value $04000 instead of $00200
                  CAPABILITIES := CAPABILITIES and not CLIENT_SSL;

                  if (fcharacter_set_name = '') then
                  begin
                    if (get_server_version() < 40101) then
                      fcharacter_set_name := MySQL_Character_Sets[CharsetNr].CharsetName
                    else
                      for I := 0 to Length(MySQL_Collations) - 1 do
                        if (MySQL_Collations[I].CharsetNr = CharsetNr) then
                          fcharacter_set_name := MySQL_Collations[I].CharsetName;
                  end
                  else if (CAPABILITIES and CLIENT_PROTOCOL_41 <> 0) then
                  begin
                    CharsetNr := 0;

                    for I := 0 to Length(MySQL_Collations) - 1 do
                      if ((AnsiStrings.StrIComp(MySQL_Collations[I].CharsetName, PAnsiChar(fcharacter_set_name)) = 0) and MySQL_Collations[I].Default) then
                      begin
                        CharsetNr := MySQL_Collations[I].CharsetNr;
                        fcharacter_set_name := MySQL_Collations[I].CharsetName;
                      end;
                    if (CharsetNr = 0) then
                      Seterror(CR_CANT_READ_CHARSET, EncodeString(Format(CLIENT_ERRORS[CR_CANT_READ_CHARSET - CR_MIN_ERROR], [fcharacter_set_name])));
                  end;
                end;

                if (errno() = 0) then
                begin
                  Direction := idWrite;
                  SetPacketPointer(1, PACKET_CURRENT);
                end;

                if (errno() = 0) then
                begin
                  Direction := idRead;

                  if (SetPacketPointer(1, PACKET_CURRENT) = 0) then
                    if (GetPacketSize() = 0) then
                      Seterror(CR_SERVER_HANDSHAKE_ERR)
                    else if (not ServerError()) then
                    begin
                      SetPacketPointer(1, FILE_CURRENT); // $00
                      ReadPacket(faffected_rows);
                      ReadPacket(finsert_id);

                      if (CAPABILITIES and CLIENT_PROTOCOL_41 <> 0) then
                      begin
                        ReadPacket(SERVER_STATUS, 2);
                        ReadPacket(fwarning_count, 2);
                      end
                      else if (SERVER_CAPABILITIES and CLIENT_TRANSACTIONS <> 0) then
                      begin
                        ReadPacket(SERVER_STATUS, 2);
                        fwarning_count := 0;
                      end;

                      UseCompression := CAPABILITIES and CLIENT_COMPRESS <> 0;
                    end;
                end;
              end;
            end;
          end;
        until (errno() <> CR_HTTPTUNNEL_REDIRECT);
      end;
    end;
  end;

  if (errno() <> 0) then
    Result := nil
  else
    Result := Self;
end;

function MYSQL.Receive(var Buffer; const BytesToRead: my_uint): Boolean;
var
  BytesRead: my_uint;
  Size: DWord;
begin
  BytesRead := 0;
  repeat
    Result := InternetReadFile(Request, @my_char(@Buffer)[BytesRead], BytesToRead - BytesRead, Size);
    if (not Result) then
      RaiseLastOSError()
    else if (Size = 0) then
    begin
      Seterror(CR_SERVER_LOST);
      Result := False;
    end
    else
      Inc(BytesRead, Size);
  until (not Result or (BytesRead = BytesToRead));
end;

function MYSQL.ReceiveExitText(out Text: RawByteString): Boolean;
var
  Buffer: array[0..199] of AnsiChar;
  BytesRead: my_uint;
  S: AnsiString;
  Size: DWord;
begin
  BytesRead := 0; Text := '';
  repeat
    Result := InternetReadFile(Request, @my_char(@Buffer)[BytesRead], SizeOf(Buffer), Size);
    if (not Result) then
      RaiseLastOSError()
    else if (Size = 0) then
    begin
      Seterror(CR_SERVER_LOST);
      Result := False;
    end
    else
    begin
      SetString(S, Buffer, Size);
      Text := Text + S;
    end;
  until (not Result or (Size < SizeOf(Buffer)));
end;

function MYSQL.Send(const Buffer; const BytesToWrite: my_uint): Boolean;
begin
  Result := ReallocBuffer(SendBuffer, SendBuffer.Size + BytesToWrite);

  if (Result) then
  begin
    MoveMemory(@SendBuffer.Mem[SendBuffer.Size], @Buffer, BytesToWrite);
    Inc(SendBuffer.Size, BytesToWrite);
  end;
end;

end.


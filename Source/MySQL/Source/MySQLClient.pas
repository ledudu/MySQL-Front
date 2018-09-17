unit MySQLClient;

interface {********************************************************************}

uses
  Windows, WinSock,
  SysUtils, SyncObjs, Classes,
  MySQLConsts;

type
  MYSQL_RES = class;
  MYSQL = class;

  TMySQL_IO = class
  type
    TType = (itNone, itNamedPipe, itTCPIP);
    TDirection = (idRead, idWrite);
  private
    FErrNo: my_uint;
    FError: RawByteString;
    FDirection: TDirection;
    Pipe: THandle;
    Socket: TSocket;
  protected
    IOType: TType;
    function GetCodePage(): Cardinal; virtual;
    procedure SetDirection(ADirection: TDirection); virtual;
    procedure Close(); virtual;
    function DecodeString(const Str: RawByteString): string; virtual;
    function EncodeString(const Str: string): RawByteString; virtual;
    function Open(const AIOType: TType; const Host: RawByteString;
      const Port, Timeout: my_uint): Boolean; virtual;
    function Receive(var Buffer; const BytesToRead: my_uint): Boolean; virtual;
    function Send(const Buffer; const BytesToWrite: my_uint): Boolean; virtual;
    function Seterror(const AErrNo: my_uint; const AError: RawByteString = ''): my_uint; virtual;
    property CodePage: Cardinal read GetCodePage;
    property Direction: TDirection read FDirection write SetDirection;
  public
    constructor Create(); virtual;
    destructor Destroy(); override;
    function errno(): my_uint; inline;
    function error(): my_char; inline;
  end;

  TMySQL_Packet = class(TMySQL_IO)
  type
    TBuffer = record
      Mem: my_char;
      MemSize: my_uint;
      Offset: my_uint;
      Size: my_uint;
    end;
    TClientStatus = (MYSQL_STATUS_READY, MYSQL_STATUS_GET_RESULT, MYSQL_STATUS_USE_RESULT);
  private
    CompPacketNr: Byte;
    CompressedBuffer: TBuffer;
    DecompressedBuffer: TBuffer;
    PacketBuffer: TBuffer;
    PacketNr: Byte;
    function ReceivePacket(): Boolean;
  protected
    UseCompression: Boolean;
    function CreatePacket(const AIOType: TMySQL_IO.TType;
      const Host: RawByteString; const Port, Timeout: my_uint): Boolean; virtual;
    procedure Close(); override;
    function FlushPacketBuffers(): Boolean; virtual;
    procedure FreeBuffer(var Buffer: TBuffer); virtual;
    function GetPacketSize(): my_int; virtual;
    procedure next_command(); virtual;
    function next_result(): my_int; virtual;
    function ReadMem(const Mem: PAnsiChar; const MemSize: Integer; out Value: my_ulonglong; const Size: Byte = 0): Integer; overload;
    function ReadPacket(const Buffer: my_char; const Size: my_uint): Boolean; overload;
    function ReadPacket(out Value: my_int; const Size: Byte = 0): Boolean; overload;
    function ReadPacket(out Value: my_uint; const Size: Byte = 0): Boolean; overload;
    function ReadPacket(out Value: my_ulonglong; const Size: Byte = 0): Boolean; overload;
    function ReadPacket(out Value: RawByteString; const NTS: Boolean = True; const Size: Byte = 0): Boolean; overload;
    function ReallocBuffer(var Buffer: TBuffer; const NeededSize: my_uint; const ReduceSize: Boolean = False): Boolean;
    function SetPacketPointer(const DistanceToMove: my_int; const MoveMethod: my_int): my_int; virtual;
    procedure SetDirection(ADirection: TMySQL_IO.TDirection); override;
    function WritePacket(const Buffer: my_char; const Size: my_uint): Boolean; overload; virtual;
    function WritePacket(const Value: my_ulonglong; const Size: my_uint): Boolean; overload; virtual;
    function WritePacket(const Value: RawByteString; const NTS: Boolean = True): Boolean; overload; virtual;
  public
    constructor Create(); override;
  end;

  MYSQL_RES = class
  type
    PRow = ^TRow;
    TRow = record
      MemSize: my_uint;
      Lengths: MYSQL_LENGTHS;
      Row: MYSQL_ROW;
      Next: PRow;
    end;
  private
    CurrentRow: PRow;
    FieldCount: my_uint;
    FieldIndex: my_int;
    FirstRow: PRow;
    mysql: MYSQL;
    ResultType: (rtUsed, rtStored);
    RowCount: my_ulonglong;
    RowIndex: my_ulonglong;
  protected
    Fields: MYSQL_FIELDS;
    Lengths: MYSQL_LENGTHS;
    property MysqlClient: MYSQL read mysql;
  public
    constructor Create(const Amysql: MYSQL; const AFieldCount: my_uint); virtual;
    procedure data_seek(offset: my_ulonglong); virtual;
    destructor Destroy(); override;
    function fetch_field(): MYSQL_FIELD; virtual;
    function fetch_field_direct(fieldnr: my_uint): MYSQL_FIELD; virtual;
    function fetch_fields(): MYSQL_FIELDS; virtual;
    function fetch_lengths(): MYSQL_LENGTHS; virtual;
    function fetch_row(): MYSQL_ROW; virtual;
    function num_fields(): my_uint; virtual;
    function num_rows(): my_ulonglong; virtual;
  end;

  MYSQL = class(TMySQL_Packet)
  protected const
    CLIENT_CAPABILITIES =
      CLIENT_LONG_PASSWORD
        or CLIENT_LONG_FLAG
        or CLIENT_LOCAL_FILES
        or CLIENT_INTERACTIVE
        or CLIENT_PROTOCOL_41
        or CLIENT_TRANSACTIONS
        or CLIENT_SECURE_CONNECTION
        or CLIENT_SESSION_TRACK
        or CLIENT_LONG_PASSWORD
        or CLIENT_PLUGIN_AUTH;
  private
    FieldCount: my_uint;
    FSQLState: array [0 .. SQLSTATE_LENGTH - 1] of AnsiChar;
    UseNamedPipe: Boolean;
    function Reconnect(): Boolean;
    function SendDataFile(const Filename: RawByteString): Boolean;
  protected
    CAPABILITIES: my_uint;
    CLIENT_STATUS: TMySQL_Packet.TClientStatus;
    faffected_rows: my_ulonglong;
    fca: RawByteString;
    fca_path: RawByteString;
    fcert: RawByteString;
    fcharacter_set_name: RawByteString;
    fcipher: RawByteString;
    fcompress: Boolean;
    fdb: RawByteString;
    fhost: RawByteString;
    fhost_info: RawByteString;
    finfo: RawByteString;
    finsert_id: my_ulonglong;
    fkey: RawByteString;
    flocal_infile_end: Tlocal_infile_end;
    flocal_infile_error: Tlocal_infile_error;
    flocal_infile_init: Tlocal_infile_init;
    flocal_infile_read: Tlocal_infile_read;
    flocal_infile_userdata: Pointer;
    fpasswd: RawByteString;
    fpipe_name: RawByteString;
    fport: Cardinal;
    freconnect: Boolean;
    fres: MYSQL_RES;
    fserver_info: RawByteString;
    fserver_version: my_uint;
    fstat: RawByteString;
    fthread_id: my_uint;
    ftimeout: my_uint;
    fuser: RawByteString;
    fwarning_count: my_uint;
    SERVER_CAPABILITIES: my_uint;
    SERVER_STATUS: my_int;
    StateInfo: record
      Data: RawByteString;
      Index: Integer;
      VariablenValue: Boolean;
    end;
    procedure Close(); override;
    function ExecuteCommand(const Command: enum_server_command; const Bin: my_char; const Size: my_int; const Retry: Boolean): my_int; virtual;
    function GetCodePage(): Cardinal; override;
    function ReadRow(var Row: MYSQL_RES.PRow): my_int; virtual;
    procedure ReadRows(const Ares: MYSQL_RES); virtual;
    function ServerError(): Boolean; virtual;
    function Seterror(const AErrNo: my_uint; const AError: RawByteString = ''): my_uint; override;
  public
    constructor Create(); override;
    function affected_rows(): my_ulonglong; virtual;
    function character_set_name(): my_char; virtual;
    function dump_debug_info(): my_int; virtual;
    function eof(): my_bool; virtual;
    function get_client_info(): my_char; virtual;
    function get_client_version(): my_uint; virtual;
    function get_host_info(): my_char; virtual;
    function get_server_info(): my_char; virtual;
    function get_server_version(): my_int; virtual;
    function info(): my_char; virtual;
    function insert_id(): my_ulonglong; virtual;
    function kill(pid: my_uint): my_int; virtual;
    function more_results(): my_bool; virtual;
    function next_result(): my_int; override;
    function options(option: enum_mysql_option; const arg: my_char): my_int; virtual;
    function ping(): my_int; virtual;
    function query(const q: my_char): my_int;
    function real_connect(host, user, passwd, db: my_char; port: my_uint; unix_socket: my_char; client_flag: my_uint): MYSQL; virtual;
    function real_escape_string(_to: my_char; const from: my_char; length: my_uint): my_uint; virtual;
    function real_query(query: my_char; length: my_int): my_int; virtual;
    function refresh(options: my_int): my_int; virtual;
    function select_db(db: my_char): my_int; virtual;
    function session_track_get_first(state_type: enum_session_state_type; out data: my_char; out length: size_t): my_int; virtual;
    function session_track_get_next(state_type: enum_session_state_type; out data: my_char; out length: size_t): my_int; virtual;
    function set_character_set(const csname: my_char): my_int; virtual;
    procedure set_local_infile_default(); virtual;
    procedure set_local_infile_handler(local_infile_init: Tlocal_infile_init; local_infile_read: Tlocal_infile_read; local_infile_end: Tlocal_infile_end; local_infile_error: Tlocal_infile_error; userdata: Pointer); virtual;
    function set_server_option(option: enum_mysql_set_option): my_int; virtual;
    function shutdown(shutdown_level: mysql_enum_shutdown_level): my_int; virtual;
    function sqlstate(): my_char; virtual;
    function store_result(): MYSQL_RES; virtual;
    function thread_id(): my_uint; virtual;
    function use_result(): MYSQL_RES; virtual;
    function warning_count(): my_uint; virtual;
    property res: MYSQL_RES read fres;
  end;

function mysql_affected_rows(mysql: MYSQL): my_ulonglong; stdcall;
// function mysql_change_user(mysql: MYSQL; const user, passwd, db: my_char): my_bool; stdcall;
function mysql_character_set_name(mysql: MYSQL): my_char; stdcall;
procedure mysql_close(mysql: MYSQL); stdcall;
// function mysql_connect(mysql: MYSQL; const host, user, passwd: my_char): MYSQL; stdcall;
// function mysql_create_db(mysql: MYSQL; const DB: my_char): my_int; stdcall;
procedure mysql_data_seek(res: MYSQL_RES; offset: my_ulonglong); stdcall;
// procedure mysql_debug(const debug: my_char); stdcall;
// function mysql_drop_db(mysql: MYSQL; const DB: my_char): my_int; stdcall;
// function mysql_dump_debug_info(mysql: MYSQL): my_int; stdcall;
function mysql_eof(mysql: MYSQL): my_bool; stdcall;
function mysql_errno(mysql: MYSQL): my_uint; stdcall;
function mysql_error(mysql: MYSQL): my_char; stdcall;
// function mysql_escape_string(_to: my_char; const from: my_char; from_length: my_uint): my_uint; stdcall;
function mysql_fetch_field(res: MYSQL_RES): MYSQL_FIELD; stdcall;
function mysql_fetch_fields(res: MYSQL_RES): MYSQL_FIELDS; stdcall;
function mysql_fetch_field_direct(res: MYSQL_RES; fieldnr: my_uint): MYSQL_FIELD; stdcall;
function mysql_fetch_lengths(res: MYSQL_RES): MYSQL_LENGTHS; stdcall;
function mysql_fetch_row(res: MYSQL_RES): MYSQL_ROW; stdcall;
function mysql_field_count(mysql: MYSQL): my_uint; stdcall;
procedure mysql_free_result(res: MYSQL_RES); stdcall;
function mysql_get_client_info: my_char; stdcall;
function mysql_get_client_version: my_uint; stdcall;
function mysql_get_host_info(mysql: MYSQL): my_char; stdcall;
function mysql_get_proto_info(mysql: MYSQL): my_uint; stdcall;
function mysql_get_server_info(mysql: MYSQL): my_char; stdcall;
function mysql_get_server_version(mysql: MYSQL): my_uint; stdcall;
function mysql_info(mysql: MYSQL): my_char; stdcall;
function mysql_init(mysql: MYSQL): MYSQL; stdcall;
function mysql_insert_id(mysql: MYSQL): my_ulonglong; stdcall;
function mysql_kill(mysql: MYSQL; pid: my_uint): my_int; stdcall;
// function mysql_list_dbs(mysql: MYSQL; const wild: my_char): MYSQL_RES; stdcall;
// function mysql_list_fields(mysql: MYSQL; const table, wild: my_char): MYSQL_RES; stdcall;
// function mysql_list_processes(mysql: MYSQL): MYSQL_RES; stdcall;
// function mysql_list_tables(mysql: MYSQL; const wild: my_char): MYSQL_RES; stdcall;
function mysql_num_fields(res: MYSQL_RES): my_uint; stdcall;
function mysql_num_rows(res: MYSQL_RES): my_ulonglong; stdcall;
function mysql_options(mysql: MYSQL; option: enum_mysql_option; const arg: my_char): my_int; stdcall;
function mysql_ping(mysql: MYSQL): my_int; stdcall;
function mysql_query(mysql: MYSQL; const q: my_char): my_int; stdcall;
function mysql_real_connect(mysql: MYSQL; host, user, passwd, db: my_char; port: my_uint; unix_socket: my_char; client_flag: my_uint): MYSQL; stdcall;
function mysql_real_escape_string(mysql: MYSQL; _to: my_char; const from: my_char; length: my_uint): my_uint; stdcall;
function mysql_real_query(mysql: MYSQL; query: my_char; length: my_int): my_int; stdcall;
// function mysql_reload(mysql: MYSQL): my_int; stdcall;
// function mysql_row_seek(res: MYSQL_RES; offset: MYSQL_ROW_OFFSET): MYSQL_ROW_OFFSET; stdcall;
// function mysql_row_tell(res: MYSQL_RES): MYSQL_ROW_OFFSET; stdcall;
function mysql_select_db(mysql: MYSQL; const db: my_char): my_int; stdcall;
function mysql_session_track_get_first(mysql: MYSQL; state_type: enum_session_state_type; out data: my_char; out length: size_t): my_int; stdcall;
function mysql_session_track_get_next(mysql: MYSQL; state_type: enum_session_state_type; out data: my_char; out length: size_t): my_int; stdcall;
function mysql_set_character_set(mysql: MYSQL; const csname: my_char): my_int; stdcall;
function mysql_set_server_option(mysql: MYSQL; option: enum_mysql_set_option): my_int; stdcall;
function mysql_shutdown(mysql: MYSQL; shutdown_level: mysql_enum_shutdown_level): my_int; stdcall;
function mysql_sqlstate(mysql: MYSQL): my_char; stdcall;
// function mysql_ssl_set(mysql: MYSQL; key, cert, ca, capath, cipher: my_char): my_int; stdcall;
// function mysql_stat(mysql: MYSQL): my_char; stdcall;
function mysql_store_result(mysql: MYSQL): MYSQL_RES; stdcall;
function mysql_thread_id(mysql: MYSQL): my_uint; stdcall;
function mysql_use_result(mysql: MYSQL): MYSQL_RES; stdcall;
function mysql_warning_count(mysql: MYSQL): my_uint; stdcall;
// function mysql_commit(mysql: MYSQL): my_bool; stdcall;
// function mysql_rollback(mysql: MYSQL): my_bool; stdcall;
// function mysql_autocommit(mysql: MYSQL; mode: my_bool): my_bool; stdcall;
function mysql_more_results(mysql: MYSQL): my_bool; stdcall;
function mysql_next_result(mysql: MYSQL): my_int; stdcall;
procedure mysql_set_local_infile_default(mysql: MYSQL); cdecl;
procedure mysql_set_local_infile_handler(mysql: MYSQL; local_infile_init: Tlocal_infile_init; local_infile_read: Tlocal_infile_read; local_infile_end: Tlocal_infile_end; local_infile_error: Tlocal_infile_error; userdata: Pointer); cdecl;

const
  PACKET_CURRENT = 4;

implementation {***************************************************************}

uses
  ZLib, StrUtils, SysConst, AnsiStrings;

const
  AF_INET6 = 23;

  COMP_HEADER_SIZE      = 3;
  MYSQL_ERRMSG_SIZE     = 512;
  MIN_COMPRESS_LENGTH   = 50;
  MYSQL_CLIENT_INFO     = '4.1.1';
  MYSQL_CLIENT_VERSION  = 40101;
  NET_HEADER_SIZE       = 4;
  PROTOCOL_VERSION      = 10;

type
  TWSAConnectByNameA = function(
    s: TSocket;
    nodename: LPSTR;
    servicename: LPSTR;
    LocalAddressLength: LPDWORD;
    LocalAddress: PSockAddrIn;
    RemoteAddressLength: LPDWORD;
    RemoteAddress: PSockAddrIn;
    timeout: PTimeVal;
    Reserved: POverlapped): Boolean; stdcall;

  TSHA1Context = record
    FLength: int64;
    FInterimHash: array[0..4] of Longint;
    FComputed: boolean;
    FCorrupted: boolean;
    FMsgBlockIndex: byte;
    FMsgBlock: array[0..63] of Byte
  end;

var
  WSAData: WinSock.WSADATA;
  WS2_32: THandle;
  WSAConnectByNameA: TWSAConnectByNameA;

{$Q-}

function Scramble(const Password: my_char; const Salt: my_char): RawByteString;

  procedure hashPassword(const pass: my_char; var res0, res1: my_int);
  var
    nr, add, nr2, tmp: my_ulonglong;
    I: my_int;
    e1: my_ulonglong;
    len: my_int;
  begin
    nr := 1345345333;
    add := 7;
    nr2 := $12345671;
    len := Length(pass)-1;
    for I := 0 to len do
    begin
      if (Pass[I] = #20) or (Pass[I] = #9)then
        continue;
      tmp := $ff and Byte(Pass[I]);
      e1 := (((nr and 63) +add)*tmp)+(nr shl 8);
      nr := nr xor e1;
      nr2 := nr2+((nr2 shl 8) xor nr);
      add := add+tmp;
    end;
    res0 := nr and $7fffffff;
    res1 := nr2 and $7fffffff;
  end;

  function Floor(X: Extended): my_int;
  begin
    Result := Trunc(X);
    if ((X < 0) and (Result <> X)) then
      Dec(Result);
  end;

var
  dRes: Double;
  e: Byte;
  hm0: my_int;
  hm1: my_int;
  hp0: my_int;
  hp1: my_int;
  I: my_int;
  maxValue: my_ulonglong;
  Scramled: array [0..7] of AnsiChar;
  Seed: my_ulonglong;
  Seed2: my_ulonglong;
begin
  hashPassword(Password, hp0, hp1);
  hashPassword(Salt, hm0, hm1);
  MaxValue := $3FFFFFFF;
  Seed  := (hp0 xor hm0) mod maxValue ;
  Seed2 := (hp1 xor hm1) mod maxValue ;
  for I := 0 to AnsiStrings.StrLen(Salt) - 1 do
  begin
    Seed  := (Seed * 3 + Seed2) mod MaxValue;
    Seed2 := (Seed + Seed2 + 33) mod MaxValue;
    dRes := Seed / maxValue;
    Scramled[I] := AnsiChar(Floor(dRes * 31) + 64);
  end;
  dRes := (Seed * 3 + Seed2) mod MaxValue / MaxValue;
  e := Floor(dRes * 31);
  for I := 0 to AnsiStrings.StrLen(Salt) - 1 do
    Scramled[I] := AnsiChar(Byte(Scramled[I]) xor e);

  SetString(Result, PAnsiChar(@Scramled), AnsiStrings.StrLen(Salt));
end;

procedure sha1_ProcessMessageBlock(var Context: TSHA1Context);
const
  ctKeys: array[0..3] of Longint =
    (Longint($5A827999), Longint($6ED9EBA1), Longint($8F1BBCDC), Longint($CA62C1D6));
var
  A: Longint;
  B: Longint;
  C: Longint;
  D: Longint;
  E: Longint;
  I: Integer;
  J: Integer;
  Temp: Longint;
  W: array [0..79] of Longint;
begin
  for I := 0 to 15 do
  begin
    J := I * 4;
    W[I] :=         Context.FMsgBlock[J + 0] shl 24;
    W[I] := W[I] or Context.FMsgBlock[J + 1] shl 16;
    W[I] := W[I] or Context.FMsgBlock[J + 2] shl 8;
    W[I] := W[I] or Context.FMsgBlock[J + 3];
  end;
  for I := 16 to 79 do
  begin
    W[I] := W[I-3] xor W[I-8] xor W[I-14] xor W[I-16];
    W[I] := (W[I] shl 1) or (W[I] shr 31);
  end;
  A := Context.FInterimHash[0];
  B := Context.FInterimHash[1];
  C := Context.FInterimHash[2];
  D := Context.FInterimHash[3];
  E := Context.FInterimHash[4];
  for I := 0 to 19 do
  begin
    Temp := ((A shl 5) or (A shr 27)) + ((B and C) or ((not B) and D)) + E + W[I] + ctKeys[0];
    E := D;
    D := C;
    C := (B shl 30) or (B shr 2);
    B := A;
    A := Temp;
  end;
  for I := 20 to 39 do
  begin
    Temp := ((A shl 5) or (A shr 27)) + (B xor C xor D) + E + W[I] + ctKeys[1];
    E := D;
    D := C;
    C := (B shl 30) or (B shr 2);
    B := A;
    A := Temp;
  end;
  for I := 40 to 59 do
  begin
    Temp := ((A shl 5) or (A shr 27)) + ((B and C) or (B and D) or (C and D)) + E + W[I] + ctKeys[2];
    E := D;
    D := C;
    C := (B shl 30) or (B shr 2);
    B := A;
    A := Temp;
  end;
  for I := 60 to 79 do
  begin
    Temp := ((A shl 5) or (A shr 27)) + (B xor C xor D) + E + W[I] + ctKeys[3];
    E := D;
    D := C;
    C := (B shl 30) or (B shr 2);
    B := A;
    A := Temp;
  end;
  Context.FInterimHash[0] := Context.FInterimHash[0] + A;
  Context.FInterimHash[1] := Context.FInterimHash[1] + B;
  Context.FInterimHash[2] := Context.FInterimHash[2] + C;
  Context.FInterimHash[3] := Context.FInterimHash[3] + D;
  Context.FInterimHash[4] := Context.FInterimHash[4] + E;
  Context.FMsgBlockIndex := 0;
end;

procedure sha1_reset(var context: TSHA1Context);
const
  ctSHAKeys: array[0..4] of Longint =
    (Longint($67452301), Longint($EFCDAB89), Longint($98BADCFE), Longint($10325476), Longint($C3D2E1F0));
begin
  context.FLength := 0;
  context.FMsgBlockIndex := 0;
  context.FInterimHash[0] := ctSHAKeys[0];
  context.FInterimHash[1] := ctSHAKeys[1];
  context.FInterimHash[2] := ctSHAKeys[2];
  context.FInterimHash[3] := ctSHAKeys[3];
  context.FInterimHash[4] := ctSHAKeys[4];
  context.FComputed := false;
  context.FCorrupted := false;
  FillChar(context.FMsgBlock[0], 64, #0);
end;

procedure sha1_input(var context: TSHA1Context; msgArray :PAnsiChar; msgLen:cardinal);
begin
  Assert(Assigned(msgArray), 'Empty array paased to sha1Input');

  if (context.FComputed) then
    context.FCorrupted := True;
  if (not context.FCorrupted) then
    while (msgLen > 0) do
    begin
      context.FMsgBlock[context.FMsgBlockIndex] := byte(msgArray[0]);
      Inc(context.FMsgBlockIndex);
      context.FLength := context.FLength+8;
      if (context.FMsgBlockIndex = 64) then
        sha1_ProcessMessageBlock(context);
      Dec(msgLen);
      Inc(msgArray);
    end;
end;

procedure sha1_result(var context: TSHA1Context; msgDigest: PAnsiChar);
var
  I: Integer;
begin
  Assert(Assigned(msgDigest), 'Empty array passed to sha1Result');

  if (not context.FCorrupted) then
  begin
    if (not context.FComputed) then
    begin
      I := context.FMsgBlockIndex;
      if (I <= 55) then
      begin
        context.FMsgBlock[I] := $80;
        Inc(I);
        FillChar(context.FMsgBlock[I], (56-I), #0);
        context.FMsgBlockIndex := 56;
      end
      else
      begin
        context.FMsgBlock[I] := $80;
        Inc(I);
        FillChar(context.FMsgBlock[I], (64-I), #0);
        context.FMsgBlockIndex := 64;
        sha1_ProcessMessageBlock(context);
        FillChar(context.FMsgBlock[0], 56, #0);
        context.FMsgBlockIndex := 56;
      end;
      context.FMsgBlock[56] := (context.FLength shr 56) and $FF;
      context.FMsgBlock[57] := (context.FLength shr 48) and $FF;
      context.FMsgBlock[58] := (context.FLength shr 40) and $FF;
      context.FMsgBlock[59] := (context.FLength shr 32) and $FF;
      context.FMsgBlock[60] := (context.FLength shr 24) and $FF;
      context.FMsgBlock[61] := (context.FLength shr 16) and $FF;
      context.FMsgBlock[62] := (context.FLength shr  8) and $FF;
      context.FMsgBlock[63] := (context.FLength       ) and $FF;

      sha1_ProcessMessageBlock(context);

      FillChar(context.FMsgBlock, SizeOf(context.FMsgBlock), #0);
      context.FLength := 0;
      context.FComputed := True;
    end;

    for I := 0 to SCRAMBLE_LENGTH -1 do
      msgDigest[I] := AnsiChar(context.FInterimHash[I shr 2] shr (8 * (3 - (I and 3))) and $FF);
  end;
end;

function SecureScramble(const Password: my_char; const Salt: my_char): RawByteString;
var
  hash_stage1: array [0 .. SCRAMBLE_LENGTH - 1] of AnsiChar;
  hash_stage2: array [0 .. SCRAMBLE_LENGTH - 1] of AnsiChar;
  I: my_int;
  Scramled: array [0 .. SCRAMBLE_LENGTH - 1] of AnsiChar;
  sha1_context: TSHA1Context;
begin
  sha1_reset(sha1_context);
  //* stage 1: hash Password */
  sha1_input(sha1_context, Password, AnsiStrings.StrLen(Password));
  sha1_result(sha1_context, @hash_stage1[0]);
  //* stage 2: hash stage 1; note that hash_stage2 is stored in the database */
  sha1_reset(sha1_context);
  sha1_input(sha1_context, @hash_stage1[0], SCRAMBLE_LENGTH);
  sha1_result(sha1_context, @hash_stage2[0]);
  //* create crypt AnsiString as sha1(message, hash_stage2) */;
  sha1_reset(sha1_context);
  sha1_input(sha1_context, PAnsiChar(Salt), SCRAMBLE_LENGTH);
  sha1_input(sha1_context, @hash_stage2[0], SCRAMBLE_LENGTH);
  //* xor allows 'from' and 'to' overlap: lets take advantage of it */
  sha1_result(sha1_context, @scramled);

  for I := 0 to SCRAMBLE_LENGTH - 1 do
    Scramled[I] := AnsiChar(Byte(Scramled[I]) xor Byte(hash_stage1[I]));

  SetString(Result, PAnsiChar(@Scramled), SCRAMBLE_LENGTH);
end;

function EncodePassword(const Password, AuthPluginData, AuthPluginName: RawByteString; const NewPassword: Boolean): RawByteString;
begin
  if (Password = '') then
    Result := ''
  else if (not NewPassword) then
    Result := Scramble(my_char(Password), my_char(AuthPluginData))
  else if (AuthPluginName <> 'caching_sha2_password') then
    Result := SecureScramble(my_char(Password), my_char(AuthPluginData))
  else
    raise Exception.Create('"chaching_sha2_password" is not supported. Please use DLL connection type.');
end;

{$IFDEF Debug}
{$Q+}
{$ENDIF}

{ C API functions *************************************************************}

function mysql_affected_rows(mysql: MYSQL): my_ulonglong; stdcall;
begin
  Result := mysql.affected_rows();
end;

// function mysql_change_user(mysql: MYSQL; const user, passwd, db: my_char): my_bool; stdcall;

function mysql_character_set_name(mysql: MYSQL): my_char; stdcall;
begin
  Result := mysql.character_set_name();
end;

procedure mysql_close(mysql: MYSQL); stdcall;
begin
  mysql.Free();
end;

// function mysql_connect(mysql: MYSQL; const host, user, passwd: my_char): MYSQL; stdcall;
// function mysql_create_db(mysql: MYSQL; const DB: my_char): my_int; stdcall;

procedure mysql_data_seek(res: MYSQL_RES; offset: my_ulonglong); stdcall;
begin
  res.data_seek(offset);
end;

// procedure mysql_debug(const debug: my_char); stdcall;
// function mysql_drop_db(mysql: MYSQL; const DB: my_char): my_int; stdcall;
// function mysql_dump_debug_info(mysql: MYSQL): my_int; stdcall;

function mysql_eof(mysql: MYSQL): my_bool; stdcall;
begin
  Result := mysql.eof();
end;

function mysql_errno(mysql: MYSQL): my_uint; stdcall;
begin
  Result := mysql.errno();
end;

function mysql_error(mysql: MYSQL): my_char; stdcall;
begin
  Result := mysql.error();
end;

// function mysql_escape_string(_to: my_char; const from: my_char; from_length: my_uint): my_uint; stdcall;

function mysql_fetch_field(res: MYSQL_RES): MYSQL_FIELD; stdcall;
begin
  Result := res.fetch_field();
end;

function mysql_fetch_fields(res: MYSQL_RES): MYSQL_FIELDS; stdcall;
begin
  Result := res.fetch_fields();
end;

function mysql_fetch_field_direct(res: MYSQL_RES; fieldnr: my_uint): MYSQL_FIELD; stdcall;
begin
  Result := res.fetch_field_direct(fieldnr);
end;

function mysql_fetch_lengths(res: MYSQL_RES): MYSQL_LENGTHS; stdcall;
begin
  Result := res.fetch_lengths();
end;

function mysql_fetch_row(res: MYSQL_RES): MYSQL_ROW; stdcall;
begin
  Result := res.fetch_row();
end;

function mysql_field_count(mysql: MYSQL): my_uint; stdcall;
begin
  Result := mysql.FieldCount;
end;

procedure mysql_free_result(res: MYSQL_RES); stdcall;
begin
  res.mysql.Seterror(0);
  res.Free();
end;

function mysql_get_client_info(): my_char; stdcall;
begin
  Result := MYSQL_CLIENT_INFO;
end;

function mysql_get_client_version: my_uint;
begin
  Result := MYSQL_CLIENT_VERSION;
end;

function mysql_get_host_info(mysql: MYSQL): my_char; stdcall;
begin
  Result := mysql.get_host_info();
end;

function mysql_get_proto_info(mysql: MYSQL): my_uint; stdcall;
begin
  Result := PROTOCOL_VERSION;
end;

function mysql_get_server_info(mysql: MYSQL): my_char; stdcall;
begin
  Result := mysql.get_server_info();
end;

function mysql_get_server_version(mysql: MYSQL): my_uint; stdcall;
begin
  Result := mysql.get_server_version();
end;

function mysql_info(mysql: MYSQL): my_char; stdcall;
begin
  Result := mysql.info();
end;

function mysql_init(mysql: MYSQL): MYSQL; stdcall;
begin
  if (Assigned(mysql)) then
    Result := mysql
  else
    Result := MySQLClient.MYSQL.Create();
end;

function mysql_insert_id(mysql: MYSQL): my_ulonglong; stdcall;
begin
  Result := mysql.insert_id();
end;

function mysql_kill(mysql: MYSQL; pid: my_uint): my_int; stdcall;
begin
  Result := mysql.kill(pid);
end;

// function mysql_list_dbs(mysql: MYSQL; const wild: my_char): MYSQL_RES; stdcall;
// function mysql_list_fields(mysql: MYSQL; const table, wild: my_char): MYSQL_RES; stdcall;
// function mysql_list_processes(mysql: MYSQL): MYSQL_RES; stdcall;
// function mysql_list_tables(mysql: MYSQL; const wild: my_char): MYSQL_RES; stdcall;

function mysql_num_fields(res: MYSQL_RES): my_uint; stdcall;
begin
  Result := res.num_fields();
end;

function mysql_num_rows(res: MYSQL_RES): my_ulonglong; stdcall;
begin
  Result := res.num_rows();
end;

function mysql_options(mysql: MYSQL; option: enum_mysql_option; const arg: my_char): my_int; stdcall;
begin
  Result := mysql.options(option, arg);
end;

function mysql_ping(mysql: MYSQL): my_int; stdcall;
begin
  Result := mysql.ping();
end;

function mysql_query(mysql: MYSQL; const q: my_char): my_int; stdcall;
begin
  Result := mysql.query(q);
end;

function mysql_real_connect(mysql: MYSQL; host, user, passwd, db: my_char; port: my_uint; unix_socket: my_char; client_flag: my_uint): MYSQL; stdcall;
begin
  Result := mysql.real_connect(host, user, passwd, db, port, unix_socket, client_flag);
end;

function mysql_real_escape_string(mysql: MYSQL; _to: my_char; const from: my_char; length: my_uint): my_uint; stdcall;
begin
  Result := mysql.real_escape_string(_to, from, length);
end;

function mysql_real_query(mysql: MYSQL; query: my_char; length: my_int): my_int; stdcall;
begin
  Result := mysql.real_query(query, length);
end;

// function mysql_reload(mysql: MYSQL): my_int; stdcall;
// function mysql_row_seek(res: MYSQL_RES; offset: MYSQL_ROW_OFFSET): MYSQL_ROW_OFFSET; stdcall;
// function mysql_row_tell(res: MYSQL_RES): MYSQL_ROW_OFFSET; stdcall;

function mysql_select_db(mysql: MYSQL; const db: my_char): my_int; stdcall;
begin
  Result := mysql.select_db(db);
end;

function mysql_session_track_get_first(mysql: MYSQL; state_type: enum_session_state_type; out data: my_char; out length: size_t): my_int; stdcall;
begin
  Result := mysql.session_track_get_first(state_type, data, length);
end;

function mysql_session_track_get_next(mysql: MYSQL; state_type: enum_session_state_type; out data: my_char; out length: size_t): my_int; stdcall;
begin
  Result := mysql.session_track_get_next(state_type, data, length);
end;

function mysql_set_character_set(mysql: MYSQL; const csname: my_char): my_int; stdcall;
begin
  Result := mysql.set_character_set(csname);
end;

function mysql_set_server_option(mysql: MYSQL; option: enum_mysql_set_option): my_int; stdcall;
begin
  Result := mysql.set_server_option(MySQLConsts.enum_mysql_set_option(option));
end;

function mysql_shutdown(mysql: MYSQL; shutdown_level: mysql_enum_shutdown_level): my_int; stdcall;
begin
  Result := mysql.shutdown(shutdown_level);
end;

function mysql_sqlstate(mysql: MYSQL): my_char; stdcall;
begin
  Result := mysql.sqlstate();
end;

// function mysql_ssl_set(mysql: MYSQL; key, cert, ca, capath, cipher: my_char): my_int; stdcall;
// function mysql_stat(mysql: MYSQL): my_char; stdcall;

function mysql_store_result(mysql: MYSQL): MYSQL_RES; stdcall;
begin
  Result := mysql.store_result();
end;

function mysql_thread_id(mysql: MYSQL): my_uint; stdcall;
begin
  Result := mysql.thread_id();
end;

function mysql_use_result(mysql: MYSQL): MYSQL_RES; stdcall;
begin
  Result := mysql.use_result();
end;

function mysql_warning_count(mysql: MYSQL): my_uint; stdcall;
begin
  Result := mysql.warning_count();
end;

// function mysql_commit(mysql: MYSQL): my_bool; stdcall;
// function mysql_rollback(mysql: MYSQL): my_bool; stdcall;
// function mysql_autocommit(mysql: MYSQL; mode: my_bool): my_bool; stdcall;

function mysql_more_results(mysql: MYSQL): my_bool; stdcall;
begin
  Result := mysql.more_results();
end;

function mysql_next_result(mysql: MYSQL): my_int; stdcall;
begin
  Result := mysql.next_result();
end;

procedure mysql_set_local_infile_default(mysql: MYSQL); cdecl;
begin
  mysql.set_local_infile_default();
end;

procedure mysql_set_local_infile_handler(mysql: MYSQL; local_infile_init: Tlocal_infile_init; local_infile_read: Tlocal_infile_read; local_infile_end: Tlocal_infile_end; local_infile_error: Tlocal_infile_error; userdata: Pointer); cdecl;
begin
  mysql.set_local_infile_handler(local_infile_init, local_infile_read, local_infile_end, local_infile_error, userdata);
end;

{ TMySQL_IO *******************************************************************}

procedure TMySQL_IO.Close();
begin
  case (IOType) of
    itNamedPipe:
      begin
        CloseHandle(Pipe); Pipe := INVALID_HANDLE_VALUE;
      end;
    itTCPIP:
      begin
        shutdown(Socket, SD_BOTH);
        closesocket(Socket); Socket := INVALID_SOCKET;
      end;
  end;

  IOType := itNone;
end;

constructor TMySQL_IO.Create();
begin
  FError := '';
  FErrno := 0;
  FDirection := idRead;
  Pipe := INVALID_HANDLE_VALUE;
  Socket := INVALID_SOCKET;
  IOType := itNone;
end;

destructor TMySQL_IO.Destroy();
begin
  Close();

  inherited;
end;

function TMySQL_IO.errno(): my_uint;
begin
  Result := FErrNo;
end;

function TMySQL_IO.error(): my_char;
begin
  Result := my_char(FError);
end;

function TMySQL_IO.GetCodePage(): Cardinal;
begin
  Result := 1252; // Base on the default character set "latin1"
end;

function TMySQL_IO.DecodeString(const Str: RawByteString): string;
var
  Len: Integer;
begin
  if (Str = '') then
    Result := ''
  else
  begin
    Len := MultiByteToWideChar(CodePage, 0, PAnsiChar(Str), Length(Str), nil, 0);
    SetLength(Result, Len);
    MultiByteToWideChar(CodePage, 0, PAnsiChar(Str), Length(Str), PChar(@Result[1]), Len);
  end;
end;

function TMySQL_IO.EncodeString(const Str: string): RawByteString;
begin
  if (Str = '') then
    Result := ''
  else
  begin
    SetLength(Result, WideCharToMultiByte(CodePage, 0, PChar(Str), Length(Str), nil, 0, nil, nil));
    WideCharToMultiByte(CodePage, 0, PChar(Str), Length(Str), PAnsiChar(Result), Length(Result), nil, nil);
  end;
end;

function TMySQL_IO.Open(const AIOType: TMYSQL_IO.TType;
  const Host: RawByteString; const Port, Timeout: my_uint): Boolean;
var
  Filename: string;
  HostEnt: PHostEnt;
  ip_addr: u_long;
  KeepAlive: BOOL;
  Mode: ULONG;
  RcvBuf: u_int;
  ReadFDS: TFDSet;
  sock_addr: sockaddr_in;
  Time: timeval;
begin
  Seterror(0);

  case (AIOType) of
    itNamedPipe:
      begin
        if (Host = LOCAL_HOST) then
          Filename := DecodeString('\\' + LOCAL_HOST_NAMEDPIPE + '\pipe\' + MYSQL_NAMEDPIPE)
        else
          Filename := DecodeString('\\' + Host + '\pipe\' + MYSQL_NAMEDPIPE);
        if (not WaitNamedPipe(PChar(Filename), Timeout * 1000)) then
          if (GetLastError() = 2) then
            Seterror(CR_NAMEDPIPEOPEN_ERROR, EncodeString(Format(CLIENT_ERRORS[CR_NAMEDPIPEOPEN_ERROR - CR_MIN_ERROR], [LOCAL_HOST, MYSQL_NAMEDPIPE, GetLastError()])))
          else
            Seterror(CR_NAMEDPIPEWAIT_ERROR, EncodeString(Format(CLIENT_ERRORS[CR_NAMEDPIPEWAIT_ERROR - CR_MIN_ERROR], [LOCAL_HOST, MYSQL_NAMEDPIPE, GetLastError()])))
        else
        begin
          Pipe := CreateFile(PChar(Filename), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_FLAG_WRITE_THROUGH, 0);
          if (Pipe = INVALID_HANDLE_VALUE) then
            if (GetLastError() = ERROR_PIPE_BUSY) then
              Seterror(CR_NAMEDPIPEWAIT_ERROR, EncodeString(Format(CLIENT_ERRORS[CR_NAMEDPIPEWAIT_ERROR - CR_MIN_ERROR], [LOCAL_HOST, MYSQL_NAMEDPIPE, GetLastError()])))
            else
              Seterror(CR_NAMEDPIPEOPEN_ERROR, EncodeString(Format(CLIENT_ERRORS[CR_NAMEDPIPEOPEN_ERROR - CR_MIN_ERROR], [LOCAL_HOST, MYSQL_NAMEDPIPE, GetLastError()])))
          else
          begin
            Mode := PIPE_READMODE_BYTE or PIPE_WAIT;
            if (not SetNamedPipeHandleState(Pipe, Mode, nil, nil)) then
            begin
              CloseHandle(Pipe); Pipe := INVALID_HANDLE_VALUE;

              Seterror(CR_NAMEDPIPESETSTATE_ERROR, EncodeString(Format(CLIENT_ERRORS[CR_NAMEDPIPESETSTATE_ERROR - CR_MIN_ERROR], [Host, MYSQL_NAMEDPIPE, GetLastError()])));
            end
            else
              IOType := itNamedPipe;
          end;
        end;
      end;
    itTCPIP:
      if ((WSAData.wVersion = 0) and (WSAStartup($0101, WSAData) <> 0)) then
        Seterror(CR_UNKNOWN_ERROR)
      else
      begin
        ip_addr := inet_addr(PAnsiChar(Host));
        if (ip_addr = u_long(INADDR_NONE)) then
        begin
          HostEnt := gethostbyname(PAnsiChar(Host));
          if (not Assigned(HostEnt)) then
            ip_addr := u_long(INADDR_NONE)
          else
            Move(HostEnt^.h_addr^[0], ip_addr, SizeOf(ip_addr));
        end;

        if (ip_addr = u_long(INADDR_NONE)) then
          Seterror(CR_UNKNOWN_HOST, EncodeString(Format(CLIENT_ERRORS[CR_UNKNOWN_HOST - CR_MIN_ERROR], [Host, WSAGetLastError()])))
        else
        begin
          FillChar(sock_addr, SizeOf(sock_addr), #0);
          sock_addr.sin_family := AF_INET;
          sock_addr.sin_addr := in_addr(ip_addr);
          sock_addr.sin_port := htons(Port);

          Socket := WinSock.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
          if (Socket = INVALID_SOCKET) then
            Seterror(CR_IPSOCK_ERROR, EncodeString(Format(CLIENT_ERRORS[CR_IPSOCK_ERROR - CR_MIN_ERROR], [WSAGetLastError()])))
          else if (connect(Socket, sock_addr, SizeOf(sock_addr)) = SOCKET_ERROR) then
          begin
            Seterror(CR_CONN_HOST_ERROR, EncodeString(Format(CLIENT_ERRORS[CR_CONN_HOST_ERROR - CR_MIN_ERROR], [Host, WSAGetLastError()])));

            closesocket(Socket); Socket := INVALID_SOCKET;
          end;
        end;

        if ((Socket = INVALID_SOCKET) and (Win32MajorVersion >= 6)) then
        begin
          WS2_32 := LoadLibrary('WS2_32.DLL');
          if (WS2_32 <> 0) then
          begin
            WSAConnectByNameA := GetProcAddress(WS2_32, 'WSAConnectByNameA');

            if (Assigned(WSAConnectByNameA)) then
            begin
              Socket := WinSock.socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
              if (Socket = INVALID_SOCKET) then
                Seterror(CR_IPSOCK_ERROR, EncodeString(Format(CLIENT_ERRORS[CR_IPSOCK_ERROR - CR_MIN_ERROR], [WSAGetLastError()])))
              else
              begin
                Time.tv_sec := Timeout; Time.tv_usec := Time.tv_sec * 1000;
                if (not WSAConnectByNameA(Socket, PAnsiChar(Host), PAnsiChar(RawByteString(IntToStr(Port))), nil, nil, nil, nil, @Time, nil)) then
                begin
                  closesocket(Socket); Socket := INVALID_SOCKET;
                end
                else
                  Seterror(0);
              end;
            end;
          end;
        end;

        if (Socket <> INVALID_SOCKET) then
        begin
          KeepAlive := TRUE; // Sends keep-alives.
          setsockopt(Socket, SOL_SOCKET, SO_KEEPALIVE, PAnsiChar(@KeepAlive), SizeOf(KeepAlive));

          RcvBuf := 2 * NET_BUFFER_LENGTH;
          setsockopt(Socket, SOL_SOCKET, SO_RCVBUF, PAnsiChar(@RcvBuf), SizeOf(RcvBuf));

          Direction := idRead;

          FD_ZERO(ReadFDS); FD_SET(Socket, ReadFDS);
          Time.tv_sec := Timeout; Time.tv_usec := Time.tv_sec * 1000;
          if (select(0, @ReadFDS, nil, nil, @Time) <> 1) then
          begin
            Seterror(CR_CONN_HOST_ERROR, EncodeString(Format(CLIENT_ERRORS[CR_CONN_HOST_ERROR - CR_MIN_ERROR], [Host, WSAGetLastError()])));

            shutdown(Socket, SD_BOTH);
            closesocket(Socket); Socket := INVALID_SOCKET;
          end
          else
            IOType := itTCPIP;
        end;
      end;
    else
      Seterror(CR_UNKNOWN_ERROR);
  end;

  Result := errno() = 0;
end;

function TMySQL_IO.Receive(var Buffer; const BytesToRead: my_uint): Boolean;
var
  arg: u_long;
  BytesRead: my_uint;
  ReadFDS: TFDSet;
  Res: Integer;
  Size: Cardinal;
  Time: timeval;
begin
  BytesRead := 0;
  repeat
    case (IOType) of
      itNamedPipe:
        begin
          Result := ReadFile(Pipe, PAnsiChar(@AnsiChar(Buffer))[BytesRead], BytesToRead - BytesRead, Size, nil) and (Size > 0);
          if (Result) then
            Inc(BytesRead, Size)
          else if (GetLastError() = ERROR_PIPE_NOT_CONNECTED) then
            Seterror(CR_SERVER_LOST)
          else
            RaiseLastOSError();
       end;
      itTCPIP:
        begin
          if (FErrNo = 0) then
            Size := BytesToRead
          else if (ioctlsocket(Socket, FIONREAD, arg) <> SOCKET_ERROR) then
            Size := arg
          else
            Size := 0;

          Result := Size > 0;
          if (Result) then
          begin
            FD_ZERO(ReadFDS); FD_SET(Socket, ReadFDS);
            Time.tv_sec := NET_WAIT_TIMEOUT; Time.tv_usec := Time.tv_sec * 1000;
            Res := select(0, @ReadFDS, nil, nil, @Time);
            if (Res = SOCKET_ERROR) then
              raise Exception.CreateFmt('select error (#%d)', [WSAGetLastError()])
            else if (Res = 0) then
            begin // Timeout
              Seterror(CR_SERVER_LOST);
              Result := False;
            end
            else
            begin
              Res := recv(Socket, PAnsiChar(@AnsiChar(Buffer))[BytesRead], BytesToRead - BytesRead, 0);
              if ((Res = SOCKET_ERROR) or (Res = 0)) then
              begin // Connection lost
                Seterror(CR_SERVER_LOST);
                Result := False;
              end
              else
                Inc(BytesRead, Res);
            end;
          end;
        end;
      else
        raise ERangeError.Create('Unknown IOType (' + IntToStr(Ord(IOType)) + ')');
    end;
  until (not Result or (BytesRead = BytesToRead));
end;

function TMySQL_IO.Send(const Buffer; const BytesToWrite: my_uint): Boolean;
var
  BytesWritten: my_uint;
  Len: my_int;
  Size: DWORD;
  Time: timeval;
  WriteFDS: TFDSet;
begin
  BytesWritten := 0;
  case (IOType) of
    itNamedPipe:
      repeat
        Result := WriteFile(Pipe, PAnsiChar(@AnsiChar(Buffer))[BytesWritten], BytesToWrite - BytesWritten, Size, nil);
        if (Result) then
          Inc(BytesWritten, Size);
      until (not Result or (BytesWritten = BytesToWrite));
    itTCPIP:
      begin
        FD_ZERO(WriteFDS); FD_SET(Socket, WriteFDS);
        Time.tv_sec := NET_WRITE_TIMEOUT; Time.tv_usec := Time.tv_sec * 1000;
        Result := (select(0, nil, @WriteFDS, nil, @Time) >= 1);
        if (Result) then
          repeat
            Len := WinSock.send(Socket, PAnsiChar(@AnsiChar(Buffer))[BytesWritten], BytesToWrite - BytesWritten, 0);
            Result := (Len > SOCKET_ERROR);
            if (Result) then
              Inc(BytesWritten, Len);
          until (not Result or (BytesWritten = BytesToWrite));
      end;
    else
      Result := False;
  end;

  if (not Result) then
    Seterror(CR_SERVER_GONE_ERROR);
end;

function TMySQL_IO.Seterror(const AErrNo: my_uint; const AError: RawByteString = ''): my_uint;
begin
  FErrNo := AErrNo;

  if (AError <> '') then
    FError := AError
  else if ((CR_MIN_ERROR <= FErrNo) and (FErrNo <= CR_MIN_ERROR + Length(CLIENT_ERRORS))) then
    FError := EncodeString(CLIENT_ERRORS[FErrNo - CR_MIN_ERROR])
  else
    FError := '';

  {$IFDEF EurekaLog}
    if (AErrNo = CR_UNKNOWN_ERROR) then
      raise ERangeError.Create(SRangeError + ' #' + IntToStr(AErrNo) + ' - ' + string(FError));
  {$ENDIF}

  Result := FErrNo;
end;

procedure TMySQL_IO.SetDirection(ADirection: TMySQL_IO.TDirection);
begin
  if (ADirection <> FDirection) then
    FDirection := ADirection;
end;

{ TMySQL_File *****************************************************************}

procedure TMySQL_Packet.Close();
var
  C: AnsiChar;
begin
  if ((IOType <> itNone) and (errno() <> CR_SERVER_GONE_ERROR) and (errno() <> CR_SERVER_LOST)) then
  begin
    next_command();
    C := AnsiChar(COM_QUIT); // inform the server we're gone
    WritePacket(@C, 1);
    FlushPacketBuffers();
  end;

  inherited;

  FreeBuffer(CompressedBuffer);
  FreeBuffer(DecompressedBuffer);
  FreeBuffer(PacketBuffer);
end;

constructor TMySQL_Packet.Create();
begin
  inherited;

  FillChar(CompressedBuffer, SizeOf(CompressedBuffer), #0);
  FillChar(DecompressedBuffer, SizeOf(DecompressedBuffer), #0);
  FillChar(PacketBuffer, SizeOf(PacketBuffer), #0);
end;

function TMySQL_Packet.CreatePacket(const AIOType: TMYSQL_IO.TType;
  const Host: RawByteString; const Port, Timeout: my_uint): Boolean;
begin
  Result := IOType = itNone;
  if (Result) then
  begin
    ReallocBuffer(PacketBuffer, NET_BUFFER_LENGTH);

    UseCompression := False;

    CompPacketNr := 0;
    PacketNr := 0;

    Result := Open(AIOType, Host, Port, Timeout);
  end;
end;

function TMySQL_Packet.FlushPacketBuffers(): Boolean;
var
  CompressBuffer: Pointer;
  CompressedSize: Integer;
  Header: array [0..NET_HEADER_SIZE + COMP_HEADER_SIZE - 1] of Byte;
  Offset: my_uint;
  Size: my_uint;
begin
  Assert(Assigned(PacketBuffer.Mem));

  Result := (errno() <> CR_SERVER_GONE_ERROR) and (errno() <> CR_SERVER_LOST);
  if (Result) then
  begin
    SetPacketPointer(1, PACKET_CURRENT);
    Dec(PacketBuffer.Size, NET_HEADER_SIZE);

    if (not UseCompression) then
      Result := Send(PacketBuffer.Mem[0], PacketBuffer.Size)
    else
    begin
      Result := True;
      Offset := 0;

      repeat
        Size := PacketBuffer.Size - Offset;
        if (Size > $FFFFFF) then Size := $FFFFFF;

        if (Size < MIN_COMPRESS_LENGTH) then
        begin
          CompressedSize := Size;
          CompressBuffer := nil;
        end
        else
          try
            ZCompress(@PacketBuffer.Mem[Offset], Size, CompressBuffer, CompressedSize);
          except
            Seterror(CR_UNKNOWN_ERROR); Result := False;
            CompressBuffer := nil;
          end;

        if (Result) then
          if (my_uint(CompressedSize) >= Size) then
          begin
            Move(Size, Header[0], 3);
            Move(CompPacketNr, Header[3], 1);
            FillChar(Header[4], 3, #0);

            Result := Send(Header, SizeOf(Header)) and Send(PacketBuffer.Mem[Offset], Size);
          end
          else
          begin
            Move(CompressedSize, Header[0], 3);
            Move(CompPacketNr, Header[3], 1);
            Move(Size, Header[4], 3);

            Result := Send(Header, SizeOf(Header)) and Send(CompressBuffer^, CompressedSize);
          end;

        Inc(Offset, Size);
        CompPacketNr := (CompPacketNr + 1) and $FF;

        if (Assigned(CompressBuffer)) then
          FreeMem(CompressBuffer);
      until (not Result or (Offset = PacketBuffer.Size));
    end;

    PacketBuffer.Offset := 0;
    PacketBuffer.Size := NET_HEADER_SIZE; // Reserve space for packet header
  end;
end;

procedure TMySQL_Packet.FreeBuffer(var Buffer: TBuffer);
begin
  if (Assigned(Buffer.Mem)) then
    FreeMem(Buffer.Mem);
  ZeroMemory(@Buffer, SizeOf(Buffer));
end;

function TMySQL_Packet.GetPacketSize(): my_int;
begin
  if (Direction = idRead) then
    Result := PacketBuffer.Size
  else if (PacketBuffer.Size = 0) then
    Result := 0
  else
    Result := PacketBuffer.Size - (NET_HEADER_SIZE + PacketBuffer.Offset);
end;

procedure TMySQL_Packet.next_command();
begin
  Direction := idWrite;

  CompPacketNr := 0;
  PacketNr := 0;
end;

function TMySQL_Packet.next_result(): my_int;
begin
  Direction := idRead;

  Result := 0;
end;

function TMySQL_Packet.ReadMem(const Mem: PAnsiChar; const MemSize: Integer; out Value: my_ulonglong; const Size: Byte = 0): Integer;
begin
  Result := 0;
  FillChar(Value, SizeOf(Value), #0);

  if (Size > 0) then
  begin
    if (Size <= MemSize) then
    begin
      Move(Mem[0], Value, Size);
      Result := Size;
    end;
  end
  else if (MemSize < 1) then
    Result := 0
  else if (Byte(Mem[0]) < $FB) then
  begin
    Move(Mem[0], Value, 1);
    Result := 1;
  end
  else if (Byte(Mem[0]) = $FB) then
  begin
    Value := NULL_LENGTH;
    Result := 1;
  end
  else if (Byte(Mem[0]) = $FC) then
  begin
    if (MemSize < 3) then
      raise Exception.Create('Range check error')
    else
    begin
      Move(Mem[1], Value, 2);
      Result := 3;
    end;
  end
  else if (Byte(Mem[0]) = $FD) then
  begin
    if (MemSize < 4) then
      raise Exception.Create('Range check error')
    else
    begin
      Move(Mem[1], Value, 3);
      Result := 4;
    end;
  end
  else if (Byte(Mem[0]) = $FE) then
  begin
    if (MemSize < 9) then
      raise Exception.Create('Range check error')
    else
    begin
      Move(Mem[1], Value, 8);
      Result := 9;
    end;
  end
  else // Byte(Mem[0]) = $FF
    raise Exception.Create('Range check error');
end;

function TMySQL_Packet.ReadPacket(const Buffer: my_char; const Size: my_uint): Boolean;
begin
  Assert(Direction = idRead);

  Result := PacketBuffer.Offset + Size <= PacketBuffer.Size;
  if (not Result) then
    Seterror(CR_SERVER_HANDSHAKE_ERR)
  else
  begin
    Move(PacketBuffer.Mem[PacketBuffer.Offset], Buffer^, Size);
    Inc(PacketBuffer.Offset, Size);
  end;
end;

function TMySQL_Packet.ReadPacket(out Value: my_int; const Size: Byte = 0): Boolean;
var
  LL: my_ulonglong;
begin
  Result := ReadPacket(LL, Size);
  if (Result) then
    Move(LL, Value, SizeOf(Value));
end;

function TMySQL_Packet.ReadPacket(out Value: my_uint; const Size: Byte = 0): Boolean;
var
  LL: my_ulonglong;
begin
  Result := ReadPacket(LL, Size);
  if (Result) then
    Move(LL, Value, SizeOf(Value));
end;

function TMySQL_Packet.ReadPacket(out Value: my_ulonglong; const Size: Byte = 0): Boolean;
var
  ReadSize: Integer;
begin
  if ((errno() <> 0) and (errno() <> CR_SERVER_LOST)) then
    Result := False
  else
  begin
    ReadSize := ReadMem(@PacketBuffer.Mem[PacketBuffer.Offset], PacketBuffer.Size - PacketBuffer.Offset, Value, Size);
    Inc(PacketBuffer.Offset, ReadSize);
    Result := ReadSize > 0;
  end;
end;

function TMySQL_Packet.ReadPacket(out Value: RawByteString; const NTS: Boolean = True; const Size: Byte = 0): Boolean;
var
  Len: my_ulonglong;
begin
  if ((errno() <> 0) and (errno() <> CR_SERVER_GONE_ERROR)) then
    Result := False
  else if (not NTS and (Size > 0)) then
    if (PacketBuffer.Offset + Size > PacketBuffer.Size) then
      Result := False
    else
    begin
      SetString(Value, PAnsiChar(@PacketBuffer.Mem[PacketBuffer.Offset]), Size);
      Inc(PacketBuffer.Offset, Size);
      Result := True;
    end
  else if (not NTS and ReadPacket(Len)) then
    if ((Len = NULL_LENGTH) or (PacketBuffer.Offset + Len > PacketBuffer.Size)) then
      Result := False
    else
    begin
      SetString(Value, PAnsiChar(@PacketBuffer.Mem[PacketBuffer.Offset]), Len);
      Inc(PacketBuffer.Offset, Len);
      Result := True;
    end
  else if (NTS and (PacketBuffer.Offset + 1 <= PacketBuffer.Size)) then
  begin
    Len := 0;
    while ((PacketBuffer.Offset + Len < PacketBuffer.Size) and (PacketBuffer.Mem[PacketBuffer.Offset + Len] <> #0)) do
      Inc(Len);
    SetString(Value, PAnsiChar(@PacketBuffer.Mem[PacketBuffer.Offset]), Len);
    Inc(PacketBuffer.Offset, Len);
    if (Size = 0) then
      Inc(PacketBuffer.Offset);
    Result := True;
  end
  else
    Result := False;
end;

function TMySQL_Packet.ReallocBuffer(var Buffer: TBuffer; const NeededSize: my_uint; const ReduceSize: Boolean = False): Boolean;
begin
  Result := True;

  if (Buffer.Size + NeededSize > Buffer.MemSize) then
  begin
    Buffer.MemSize := (((Buffer.Size + NeededSize - 1) div NET_BUFFER_LENGTH) + 1) * NET_BUFFER_LENGTH;

    try
      ReallocMem(Buffer.Mem, Buffer.MemSize);
    except
      FreeBuffer(Buffer);
      Seterror(CR_OUT_OF_MEMORY);
      Result := False;
    end;
  end;
end;

function TMySQL_Packet.ReceivePacket(): Boolean;

  function ReceiveCompressed(var Buffer; const BytesToRead: Integer): Boolean;
  var
    DecompressedSize: Integer;
    Header: array [0..NET_HEADER_SIZE + COMP_HEADER_SIZE - 1] of Byte;
    Nr: Byte;
    Offset: Integer;
    Size: Integer;
    UncompressedSize: my_uint;
  begin
    Offset := 0;
    repeat
      Size := DecompressedBuffer.Size - DecompressedBuffer.Offset;
      if (Size > 0) then
      begin
        if (Size > BytesToRead - Offset) then Size := BytesToRead - Offset;
        Move(DecompressedBuffer.Mem[DecompressedBuffer.Offset], PAnsiChar(@Buffer)[Offset], Size);
        Inc(DecompressedBuffer.Offset, Size);
        Inc(Offset, Size);

        Result := True;
      end
      else
      begin
        Result := Receive(Header, SizeOf(Header));

        if (Result) then
        begin
          Size := 0;
          UncompressedSize := 0;
          Move(Header[0], Size, 3);
          Move(Header[3], Nr, 1);
          Move(Header[4], UncompressedSize, 3);

          if (Nr <> CompPacketNr) then
            Result := Seterror(CR_SERVER_HANDSHAKE_ERR) = 0
          else
          begin
            PacketNr := CompPacketNr;
            CompPacketNr := (CompPacketNr + 1) and $FF;

            if (UncompressedSize = 0) then
            begin
              DecompressedBuffer.Offset := 0;
              DecompressedBuffer.Size := 0;
              Result := ReallocBuffer(DecompressedBuffer, Size);

              if (Result) then
                Result := Receive(DecompressedBuffer.Mem[0], Size);

              if (Result) then
                DecompressedBuffer.Size := Size;
            end
            else
            begin
              CompressedBuffer.Offset := 0;
              CompressedBuffer.Size := 0;
              Result := ReallocBuffer(CompressedBuffer, Size);

              if (Result) then
                Result := Receive(CompressedBuffer.Mem[0], Size);

              if (Result) then
              begin
                CompressedBuffer.Size := Size;

                if (Result) then
                begin
                  if (Assigned(DecompressedBuffer.Mem)) then
                    FreeBuffer(DecompressedBuffer);
                  try
                    ZDecompress(CompressedBuffer.Mem, CompressedBuffer.Size, Pointer(DecompressedBuffer.Mem), DecompressedSize);
                  except
                    Result := Seterror(CR_UNKNOWN_ERROR) = 0;
                  end;
                end;

                if (Result) then
                  if (DecompressedSize <> Integer(UncompressedSize)) then
                    Result := Seterror(CR_SERVER_HANDSHAKE_ERR) = 0
                  else
                  begin
                    DecompressedBuffer.Offset := 0;
                    DecompressedBuffer.Size := DecompressedSize;
                    DecompressedBuffer.MemSize := DecompressedBuffer.Size;
                  end;
              end;
            end;
          end;
        end;
      end;
    until (not Result or (Offset = BytesToRead));
  end;

var
  Header: array [0..NET_HEADER_SIZE - 1] of Byte;
  Nr: Byte;
  Size: my_uint;
begin
  Size := 0;
  repeat
    if (not UseCompression) then
      Result := Receive(Header, SizeOf(Header))
    else
      Result := ReceiveCompressed(Header, SizeOf(Header));

    if (Result) then
    begin
      Size := 0;
      Move(Header[0], Size, 3);
      Move(Header[3], Nr, 1);

      if (not UseCompression and (Nr <> PacketNr)) then
        Result := Seterror(CR_SERVER_HANDSHAKE_ERR) = 0
      else
      begin
        PacketNr := (PacketNr + 1) and $FF;

        PacketBuffer.Offset := 0;
        PacketBuffer.Size := 0;
        Result := ReallocBuffer(PacketBuffer, Size);

        if (Result) then
          if (not UseCompression) then
            Result := Receive(PacketBuffer.Mem[PacketBuffer.Offset], Size)
          else
            Result := ReceiveCompressed(PacketBuffer.Mem[PacketBuffer.Offset], Size);

        if (Result) then
          PacketBuffer.Size := Size;
      end;
    end;
  until (not Result or (Size < $FFFFFF));
end;

function TMySQL_Packet.SetPacketPointer(const DistanceToMove: my_int; const MoveMethod: my_int): my_int;
var
  I: my_int;
  Size: my_uint;
begin
  Assert((MoveMethod <> PACKET_CURRENT) or (DistanceToMove = 1));
  Assert((Direction = idRead) or (MoveMethod in [FILE_CURRENT, PACKET_CURRENT]) and (DistanceToMove >= 1));

  if (Direction = idRead) then
  begin
    if ((errno() <> 0) and (errno() <> CR_SERVER_GONE_ERROR)) then
      Result := -1
    else if (MoveMethod = PACKET_CURRENT) then // Switch to next packet
    begin
      if (not ReceivePacket()) then
        Result := -1
      else
        Result := 0;
    end
    else // Move inside a packet
    begin
      case (MoveMethod) of
        FILE_BEGIN: Result := DistanceToMove;
        FILE_CURRENT: Result := my_int(PacketBuffer.Offset) + DistanceToMove;
        FILE_END: Result := my_int(PacketBuffer.Size) + DistanceToMove;
        else Result := -1;
      end;
      if ((Result < 0) or (my_int(PacketBuffer.Size) < Result)) then
        Seterror(CR_SERVER_HANDSHAKE_ERR)
      else
        PacketBuffer.Offset := Result;
    end;
  end
  else // idWrite
    case (MoveMethod) of
      FILE_CURRENT:
        begin
          for I := 0 to DistanceToMove - 1 do WritePacket(0, 1);
          Result := PacketBuffer.Size - PacketBuffer.Offset;
        end;
      PACKET_CURRENT: // Switch to next packet
        begin
          Size := GetPacketSize();
          Move(Size, PacketBuffer.Mem[PacketBuffer.Offset + 0], 3);
          Move(PacketNr, PacketBuffer.Mem[PacketBuffer.Offset + 3], 1);
          PacketNr := (PacketNr + 1) and $FF;

          PacketBuffer.Offset := PacketBuffer.Size;
          Inc(PacketBuffer.Size, NET_HEADER_SIZE); // Reserve space for packet header

          Result := 0;
        end;
      else // Cannot occur, but for compiler warning...
        Result := -1;
    end;
end;

procedure TMySQL_Packet.SetDirection(ADirection: TMySQL_IO.TDirection);
const
  ReducedBufferSized = 2 * NET_BUFFER_LENGTH;
begin
  if (ADirection <> Direction) then
  begin
    ReallocBuffer(PacketBuffer, ReducedBufferSized, True);

    PacketBuffer.Offset := 0;
    if (ADirection = idRead) then
      PacketBuffer.Size := 0
    else
      PacketBuffer.Size := NET_HEADER_SIZE; // Resere space for packet header
  end;

  inherited;
end;

function TMySQL_Packet.WritePacket(const Buffer: my_char; const Size: my_uint): Boolean;
var
  Offset: my_uint;
  PartSize: my_uint;
begin
  Assert(Direction = idWrite);

  Offset := 0;
  repeat
    PartSize := Size - Offset;
    if (PartSize > $FFFFFF - (PacketBuffer.Size - (PacketBuffer.Offset + NET_HEADER_SIZE))) then
      PartSize := $FFFFFF - (PacketBuffer.Size - (PacketBuffer.Offset + NET_HEADER_SIZE));

    Result := ReallocBuffer(PacketBuffer, PartSize);

    if (Result) then
    begin
      Move(Buffer[Offset], PacketBuffer.Mem[PacketBuffer.Size], PartSize);
      Inc(PacketBuffer.Size, PartSize);
      Inc(Offset, PartSize);
    end;

    if (Result and (PacketBuffer.Size = NET_HEADER_SIZE + $FFFFFF)) then
      Result := FlushPacketBuffers();
  until (not Result or (Offset = Size) and (PartSize <> $FFFFFF));
end;

function TMySQL_Packet.WritePacket(const Value: my_ulonglong; const Size: my_uint): Boolean;
begin
  Result := WritePacket(@Value, Size);
end;

function TMySQL_Packet.WritePacket(const Value: RawByteString; const NTS: Boolean = True): Boolean;
begin
  Result := True;
  if (not NTS) then
    Result := Result and WritePacket(Length(Value), 1);
  if (Value <> '') then
    Result := Result and WritePacket(my_char(Value), Length(Value));
  if (NTS) then
    Result := Result and WritePacket(0, 1);
end;

{ MYSQL ****************************************************************}

function MYSQL.affected_rows(): my_ulonglong;
begin
  Result := faffected_rows;
end;

function MYSQL.character_set_name(): my_char;
begin
  Result := my_char(fcharacter_set_name);
end;

procedure MYSQL.Close();
begin
  if (Assigned(fres)) then
    FreeAndNil(fres);

  inherited;

  CLIENT_STATUS := MYSQL_STATUS_READY;
  finfo := '';
  StateInfo.Data := '';
  StateInfo.Index := 0;
  SERVER_CAPABILITIES := 0;
  fserver_info := '';
  fserver_version := 0;
  SERVER_STATUS := 0;
  FillChar(FSQLState, SizeOf(FSQLState), #0);
  fthread_id := 0;
end;

constructor MYSQL.Create();
begin
  inherited;

  CLIENT_STATUS := MYSQL_STATUS_READY;
  fres := nil;
  UseNamedPipe := False;

  CAPABILITIES := 0;
  faffected_rows := 0;
  fcharacter_set_name := '';
  fcompress := False;
  ftimeout := NET_READ_TIMEOUT;
  fdb := '';
  fhost := '';
  fhost_info := '';
  finfo := '';
  finsert_id := 0;
  flocal_infile_end := nil;
  flocal_infile_error := nil;
  flocal_infile_init := nil;
  flocal_infile_read := nil;
  flocal_infile_userdata := nil;
  fpasswd := '';
  fport := MYSQL_PORT;
  freconnect := False;
  fserver_info := '';
  fserver_version := 0;
  StateInfo.Data := '';
  StateInfo.Index := 0;
  fthread_id := 0;
  fuser := '';
  fpipe_name := '';
  fwarning_count := 0;
  SERVER_CAPABILITIES := 0;
  SERVER_STATUS := 0;
end;

function MYSQL.dump_debug_info(): my_int;
begin
  Result := ExecuteCommand(COM_DEBUG, nil, 0, freconnect);
end;

function MYSQL.eof(): my_bool;
begin
  if (not Assigned(res) or (res.ResultType = rtUsed) and (CLIENT_STATUS <> MYSQL_STATUS_READY)) then
    Result := 0
  else
    Result := 1;
end;

function MYSQL.ExecuteCommand(const Command: enum_server_command;
  const Bin: my_char; const Size: my_int; const Retry: Boolean): my_int;
begin
  if ((CLIENT_STATUS <> MYSQL_STATUS_READY) or (more_results() <> 0)) then
  begin
    Seterror(CR_COMMANDS_OUT_OF_SYNC);
    Result := -1;
  end
  else if ((IOType = itNone) and not (Retry and Reconnect())) then
  begin
    if (errno() = 0) then
      Seterror(CR_SERVER_GONE_ERROR);
    Result := -1;
  end
  else
  begin
    Seterror(0);
    next_command();

    if (WritePacket(@Command, 1) and WritePacket(Bin, Size) and (FlushPacketBuffers() or (errno() = CR_SERVER_GONE_ERROR)) and (next_result() <= 0)) then
      if (errno() = 0) then
        Result := 0
      else
        Result := -1
    else if (Retry and Reconnect()) then
      Result := ExecuteCommand(Command, Bin, Size, False)
    else
    begin
      if (errno() = 0) then
        Seterror(CR_UNKNOWN_ERROR);
      Result := -1;
    end;
  end;
end;

function MYSQL.GetCodePage(): Cardinal;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to Length(MySQL_Collations) - 1 do
    if (AnsiStrings.StrIComp(MySQL_Collations[I].CharsetName, PAnsiChar(fcharacter_set_name)) = 0) then
      Result := MySQL_Collations[I].CodePage;

  if (Result = 0) then
    Result := inherited GetCodePage();
end;

function MYSQL.get_client_info(): my_char;
begin
  Result := MYSQL_CLIENT_INFO;
end;

function MYSQL.get_client_version(): my_uint;
begin
  Result := MYSQL_CLIENT_VERSION;
end;

function MYSQL.get_host_info(): my_char;
begin
  if (fhost_info = '') then
    case (IOType) of
      itNamedPipe: fhost_info := RawByteString(Format(CLIENT_ERRORS[CR_NAMEDPIPE_CONNECTION - CR_MIN_ERROR], [MYSQL_NAMEDPIPE]));
      itTCPIP: fhost_info := RawByteString(Format(CLIENT_ERRORS[CR_TCP_CONNECTION - CR_MIN_ERROR], [fhost]));
    end;

  Result := my_char(fhost_info);
end;

function MYSQL.get_server_info(): my_char;
begin
  Result := my_char(fserver_info);
end;

function MYSQL.get_server_version(): my_int;
begin
  Result := fserver_version;
end;

function MYSQL.info(): my_char;
begin
  if (finfo = '') then
    Result := nil
  else
    Result := my_char(finfo);
end;

function MYSQL.insert_id(): my_ulonglong;
begin
  Result := finsert_id;
end;

function MYSQL.kill(pid: my_uint): my_int;
begin
  Result := ExecuteCommand(COM_PROCESS_KILL, @pid, SizeOf(pid), freconnect);
end;

function MYSQL.more_results(): my_bool;
//  0  No more results
//  1  More results
begin
  if ((CAPABILITIES and CLIENT_MULTI_RESULTS = 0) or (SERVER_STATUS and SERVER_MORE_RESULTS_EXISTS = 0)) then
    Result := 0
  else
    Result := 1;
end;

function MYSQL.next_result(): my_int;
// -1  Successful and there are no more results
//  0  Successful and there are more results
// >0  An error occurred
var
  FileSent: Boolean;
  RBS: RawByteString;
begin
  if (CLIENT_STATUS <> MYSQL_STATUS_READY)  then
  begin
    Seterror(CR_COMMANDS_OUT_OF_SYNC);
    Result := 1;
  end
  else
  begin
    faffected_rows := -1;
    finfo := '';
    finsert_id := -1;
    fwarning_count := 0;
    StateInfo.Data := '';
    StateInfo.Index := 0;
    fres := nil;

    repeat
      FileSent := False;

      if ((Direction = idRead) and (SERVER_STATUS and SERVER_MORE_RESULTS_EXISTS = 0)) then
        Result := -1
      else if ((inherited next_result() <> 0) or (SetPacketPointer(1, PACKET_CURRENT) < 0)) then
      begin
        if (errno() = 0) then
          Seterror(CR_UNKNOWN_ERROR);
        Result := 1;
      end
      else if (GetPacketSize() = 0) then
      begin
        Seterror(CR_SERVER_HANDSHAKE_ERR);
        Result := 1;
      end
      else if (ServerError()) then
        Result := 1
      else if (Byte(PacketBuffer.Mem[PacketBuffer.Offset]) = $00) then
      begin
        SetPacketPointer(1, FILE_CURRENT); // $00

        ReadPacket(faffected_rows);
        ReadPacket(finsert_id);

        if (CAPABILITIES and CLIENT_PROTOCOL_41 <> 0) then
        begin
          ReadPacket(SERVER_STATUS, 2);
          ReadPacket(fwarning_count, 2);
        end
        else if (CAPABILITIES and CLIENT_TRANSACTIONS <> 0) then
        begin
          ReadPacket(SERVER_STATUS, 2);
        end;

        if (CAPABILITIES and CLIENT_SESSION_TRACK <> 0) then
        begin
          ReadPacket(finfo, False);

          if (SERVER_STATUS and SERVER_SESSION_STATE_CHANGED <> 0) then
            if (ReadPacket(StateInfo.Data, False)) then
            begin
              StateInfo.Index := 1;
              StateInfo.VariablenValue := False;
            end;
        end
        else
          ReadPacket(finfo, True);

        CLIENT_STATUS := MYSQL_STATUS_READY;

        Result := 0;
      end
      else if (Byte(PacketBuffer.Mem[PacketBuffer.Offset]) = $FB) then // NULL_LENGTH
      begin
        SetPacketPointer(1, FILE_CURRENT); // $FB

        FileSent := True;
        if (not ReadPacket(RBS) or not SendDataFile(RBS)) then
          Result := 1
        else
          Result := 0;
      end
      else if (Byte(PacketBuffer.Mem[PacketBuffer.Offset]) = $FE) then
      begin
        SetPacketPointer(1, FILE_CURRENT); // $FE

        ReadPacket(faffected_rows);
        ReadPacket(finsert_id);

        if (CAPABILITIES and CLIENT_PROTOCOL_41 <> 0) then
        begin
          ReadPacket(SERVER_STATUS, 2);
          ReadPacket(fwarning_count, 2);
        end;

        Result := 0;
      end
      else if (not ReadPacket(FieldCount)) then
      begin
        if (errno() = 0) then
          Seterror(CR_SERVER_HANDSHAKE_ERR);
        Result := 1;
      end
      else
      begin
        // we can switch the server in transaction
        if (SERVER_STATUS and SERVER_STATUS_AUTOCOMMIT = 0) then
          SERVER_STATUS := SERVER_STATUS or SERVER_STATUS_IN_TRANS;

        CLIENT_STATUS := MYSQL_STATUS_GET_RESULT;

        Result := 0;
      end;
    until (not FileSent);
  end;
end;

function MYSQL.options(option: enum_mysql_option; const arg: my_char): my_int;
var
  I: my_int;
begin
  case option of
    MYSQL_OPT_CONNECT_TIMEOUT: if (TryStrToInt(string(arg), I) and (I > 0)) then ftimeout := I;
    MYSQL_OPT_COMPRESS: fcompress := True;
    MYSQL_OPT_NAMED_PIPE: UseNamedPipe := True;
    MYSQL_OPT_PROTOCOL: if (TryStrToInt(string(arg), I)) then UseNamedPipe := I = Ord(MYSQL_PROTOCOL_PIPE);
    MYSQL_SET_CHARSET_NAME: fcharacter_set_name := AnsiStrings.StrPas(arg);
    MYSQL_OPT_RECONNECT: freconnect := my_bool(arg) = 0;
  end;

  Result := 0;
end;

function MYSQL.ping(): my_int;
begin
  Result := ExecuteCommand(COM_PING, nil, 0, False);
end;

function MYSQL.ReadRow(var Row: MYSQL_RES.PRow): my_int;
// returns -1 on error
// returns 0 on EOF
// returns FieldCount on Success
var
  I: my_uint;
  Index: my_uint;
  Len: my_int;
  TotalSize: my_uint;
begin
  Assert(Direction = idRead);


  if ((SetPacketPointer(1, PACKET_CURRENT) < 0) or ServerError()) then
    Result := -1
  else if ((Byte(PacketBuffer.Mem[PacketBuffer.Offset]) = $FE) and (PacketBuffer.Size - PacketBuffer.Offset < 9)) then
  begin
    SetPacketPointer(1, FILE_CURRENT); // $FE

    if (CAPABILITIES and CLIENT_PROTOCOL_41 <> 0) then
    begin
      ReadPacket(fwarning_count, 2);
      ReadPacket(SERVER_STATUS, 2);
    end;

    if (CLIENT_STATUS = MYSQL_STATUS_GET_RESULT) then
      CLIENT_STATUS := MYSQL_STATUS_USE_RESULT
    else
      CLIENT_STATUS := MYSQL_STATUS_READY;

    Result := 0;
  end
  else if (Assigned(res) and (res.ResultType = rtUsed)) then
  begin
    for I := 0 to FieldCount - 1 do
      if ((errno() = 0) and ReadPacket(res.CurrentRow^.Lengths^[I])) then
        if (res.CurrentRow^.Lengths^[I] = NULL_LENGTH) then
        begin
          res.CurrentRow^.Lengths^[I] := 0;
          res.CurrentRow^.Row^[I] := nil;
        end
        else
        begin
          res.CurrentRow^.Row^[I] := @PacketBuffer.Mem[PacketBuffer.Offset];
          SetPacketPointer(res.CurrentRow^.Lengths^[I], FILE_CURRENT);
        end;
    if ((errno() = 0) and (PacketBuffer.Offset <> PacketBuffer.Offset)) then
      Seterror(CR_SERVER_HANDSHAKE_ERR);
    if (errno() <> 0) then
      Result := -1
    else
      Result := FieldCount;
  end
  else
  begin
    Result := 0;

    TotalSize := 0;
    while ((not Assigned(res) or (my_uint(Result) < FieldCount)) and (PacketBuffer.Offset < PacketBuffer.Size) and ReadPacket(Len)) do
    begin
      if (Len <> NULL_LENGTH) then
      begin
        SetPacketPointer(Len, FILE_CURRENT);
        Inc(TotalSize, Len);
      end;

      Inc(Result);
    end;

    if (Assigned(res) and (my_uint(Result) <> FieldCount)) then
      Seterror(CR_SERVER_HANDSHAKE_ERR)
    else if (PacketBuffer.Offset <> PacketBuffer.Size) then
      Seterror(CR_SERVER_HANDSHAKE_ERR)
    else
    begin
      Inc(TotalSize, SizeOf(Row^) + Result * (SizeOf(Row^.Lengths^[0]) + SizeOf(Row^.Row^[0])));

      try
        if (not Assigned(Row)) then
        begin
          GetMem(Row, TotalSize);
          Row^.MemSize := TotalSize;
        end
        else if (TotalSize > Row^.MemSize) then
        begin
          ReallocMem(Row, TotalSize);
          Row^.MemSize := TotalSize;
        end;
      except
        Seterror(CR_OUT_OF_MEMORY);
      end;
    end;

    if (errno() <> 0) then
      Result := -1
    else
    begin
      Row^.Lengths := Pointer(@PAnsiChar(Row)[SizeOf(Row^)]);
      Row^.Row := Pointer(@PAnsiChar(Row)[SizeOf(Row^) + Result * SizeOf(Row^.Lengths^[0])]);

      Index := SizeOf(Row^) + Result * (SizeOf(Row^.Lengths^[0]) + SizeOf(Row^.Row^[0]));
      SetPacketPointer(0, FILE_BEGIN);
      for I := 0 to Result - 1 do
        if (ReadPacket(Row^.Lengths^[I])) then
          if (Row^.Lengths^[I] = NULL_LENGTH) then
          begin
            Row^.Lengths^[I] := 0;
            Row^.Row^[I] := nil;
          end
          else
          begin
            Row^.Row^[I] := @PAnsiChar(Row)[Index];
            if (ReadPacket(Row^.Row^[I], Row^.Lengths^[I])) then
              Inc(Index, Row^.Lengths^[I]);

            if (Assigned(res) and (res.Fields^[I]^.max_length < my_uint(Row^.Lengths^[I]))) then
              res.Fields^[I]^.max_length := my_uint(Row^.Lengths^[I]);
          end;
    end;
  end;
end;

procedure MYSQL.ReadRows(const Ares: MYSQL_RES);
var
  PreviousRow: MYSQL_RES.PRow;
begin
  PreviousRow := nil;

  repeat
    if (Ares.ResultType = rtStored) then
    begin
      PreviousRow := Ares.CurrentRow;
      Ares.CurrentRow := nil;
    end;

    if (ReadRow(Ares.CurrentRow) = 0) then
      begin FreeMem(Ares.CurrentRow); Ares.CurrentRow := nil; end
    else
    begin
      Inc(Ares.RowIndex);
      Inc(Ares.RowCount);
    end;

    if (Ares.ResultType = rtStored) then
      if (not Assigned(Ares.FirstRow)) then
        Ares.FirstRow := Ares.CurrentRow
      else if (Assigned(PreviousRow)) then
        PreviousRow.Next := Ares.CurrentRow;
  until ((errno() <> 0) or not Assigned(Ares.CurrentRow));
end;

function MYSQL.query(const q: my_char): my_int;
begin
  Result := real_query(q, AnsiStrings.StrLen(q));
end;

function MYSQL.real_connect(host, user, passwd, db: my_char; port: my_uint; unix_socket: my_char; client_flag: my_uint): MYSQL;
var
  AuthPluginDataLen: my_int;
  AuthPluginName: RawByteString;
  CharsetNr: my_uint;
  I: my_int;
  ProtocolVersion: my_int;
  RBS: RawByteString;
  S: string;
  AuthPluginData: RawByteString;
  ServerCapabilitiesHi: my_uint;
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
    if (AnsiStrings.StrLen(unix_socket) = 0) then
      fpipe_name := MYSQL_NAMEDPIPE
    else
      fpipe_name := unix_socket;

    if (UseNamedPipe or (host = LOCAL_HOST_NAMEDPIPE)) then
      CreatePacket(itNamedPipe, fhost, fport, ftimeout)
    else if (unix_socket = LOCAL_HOST_NAMEDPIPE) then
      CreatePacket(itTCPIP, LOCAL_HOST_NAMEDPIPE, fport, ftimeout)
    else
      CreatePacket(itTCPIP, host, fport, ftimeout);


    if (IOType = itNone) then
      // errno() has been set by CreateFile()
    else if (SetPacketPointer(1, PACKET_CURRENT) < 0) then
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
      ReadPacket(AuthPluginData);
      ReadPacket(SERVER_CAPABILITIES, 2);
      ReadPacket(CharsetNr, 1);
      ReadPacket(SERVER_STATUS, 2);
      ReadPacket(ServerCapabilitiesHi, 2);
      SERVER_CAPABILITIES := ServerCapabilitiesHi shl 16 + SERVER_CAPABILITIES;
      if (SERVER_CAPABILITIES and CLIENT_PLUGIN_AUTH <> 0) then
        ReadPacket(AuthPluginDataLen, 1)
      else
        SetPacketPointer(1, FILE_CURRENT);
      SetPacketPointer(10, FILE_CURRENT);
      if ((SERVER_CAPABILITIES and CLIENT_SECURE_CONNECTION <> 0) and ReadPacket(RBS)) then
        AuthPluginData := AuthPluginData + RBS
      else if (get_server_version() <> 40100) then
        SERVER_CAPABILITIES := SERVER_CAPABILITIES and not CLIENT_SECURE_CONNECTION;
      if ((SERVER_CAPABILITIES and CLIENT_PLUGIN_AUTH = 0) or not ReadPacket(AuthPluginName)) then
        AuthPluginName := '';

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

        CAPABILITIES := CLIENT_CAPABILITIES or client_flag;
        ServerCapabilitiesHi := CAPABILITIES and SERVER_CAPABILITIES;
        CAPABILITIES := CAPABILITIES and (
          CLIENT_LONG_PASSWORD
          or CLIENT_LOCAL_FILES
          or CLIENT_INTERACTIVE
          or CLIENT_TRANSACTIONS
          or CLIENT_MULTI_STATEMENTS
          or CLIENT_MULTI_RESULTS
          or CLIENT_PS_MULTI_RESULTS
          or CLIENT_PLUGIN_AUTH
          or CLIENT_CONNECT_ATTRS
          or CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA
          or CLIENT_CAN_HANDLE_EXPIRED_PASSWORDS
          or CLIENT_SESSION_TRACK
          or CLIENT_DEPRECATE_EOF
          or CLIENT_SSL_VERIFY_SERVER_CERT
          or CLIENT_REMEMBER_OPTIONS
          or (SERVER_CAPABILITIES and $0000DB7E));
        if (fserver_version < 40101) then
          CAPABILITIES := CAPABILITIES and $FFFFF
        else if ((fserver_version < 50000) and (SERVER_CAPABILITIES and CLIENT_RESERVED <> 0)) then
          CAPABILITIES := CAPABILITIES or CLIENT_PROTOCOL_41; //  CLIENT_PROTOCOL_41 has in some older 4.1.xx versions the value $04000 instead of $00200
        if (fdb = '') then
          CAPABILITIES := CAPABILITIES and not CLIENT_CONNECT_WITH_DB;

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

          if ((get_server_version() >= 50503) and (AnsiStrings.StrIComp(PAnsiChar(fcharacter_set_name), 'utf8') = 0)) then
          begin
            CharsetNr := 45;
            fcharacter_set_name := 'utf8mb4';
          end
          else
            for I := 0 to Length(MySQL_Collations) - 1 do
              if ((AnsiStrings.StrIComp(MySQL_Collations[I].CharsetName, PAnsiChar(fcharacter_set_name)) = 0) and MySQL_Collations[I].Default) then
              begin
                CharsetNr := MySQL_Collations[I].CharsetNr;
                fcharacter_set_name := MySQL_Collations[I].CharsetName;
              end;
          if (CharsetNr = 0) then
            Seterror(CR_CANT_READ_CHARSET, EncodeString(Format(CLIENT_ERRORS[CR_CANT_READ_CHARSET - CR_MIN_ERROR], [fcharacter_set_name])));
        end;

        Direction := idWrite;
        if (CAPABILITIES and CLIENT_PROTOCOL_41 = 0) then
        begin
          WritePacket(CAPABILITIES and $FFFF, 2);
          WritePacket(MAX_ALLOWED_PACKET, 3); // Max allowed packet size (Client)
        end
        else
        begin
          WritePacket(CAPABILITIES, 4);
          WritePacket($40000000, 4); // Max allowed packet size (Client)
          WritePacket(CharsetNr, 1);
          WritePacket(RawByteString(StringOfChar(#0, 22))); // unused space
        end;
        WritePacket(fuser);
        if (SERVER_CAPABILITIES and CLIENT_SECURE_CONNECTION = 0) then
          WritePacket(EncodePassword(fpasswd, AuthPluginData, AuthPluginName, False))
        else
          try
            WritePacket(EncodePassword(fpasswd, AuthPluginData, AuthPluginName, True), False);
          except
            on E: Exception do
              SetError(CR_UNKNOWN_ERROR, RawByteString(E.Message));
          end;
        if (CAPABILITIES and CLIENT_CONNECT_WITH_DB <> 0) then
          WritePacket(fdb);
        if (CAPABILITIES and CLIENT_PLUGIN_AUTH <> 0) then
          WritePacket(AuthPluginName);
        if (errno() = 0) then
          FlushPacketBuffers();


        Direction := idRead;
        if (SetPacketPointer(1, PACKET_CURRENT) = 0) then
        begin
          if ((Byte(PacketBuffer.Mem[PacketBuffer.Offset]) = $FE) and (GetPacketSize() < 9) and (SERVER_CAPABILITIES and CLIENT_SECURE_CONNECTION <> 0)) then
          begin
            Direction := idWrite;
            WritePacket(EncodePassword(fpasswd, RawByteString(Copy(AuthPluginData, 1, SCRAMBLE_LENGTH_323)), AuthPluginName, False));
            if (not FlushPacketBuffers()) then
              Seterror(CR_SERVER_GONE_ERROR)
            else
            begin
              Direction := idRead;
              SetPacketPointer(1, PACKET_CURRENT);
            end;
          end;

          if (errno() = 0) then
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

    // if server does not support connect with db, so we need to select the db
    if ((errno() = 0) and (SERVER_CAPABILITIES and CLIENT_CONNECT_WITH_DB = 0) and (client_flag and CLIENT_CONNECT_WITH_DB <> 0)) then
      select_db(my_char(fdb));
  end;

  if (errno() <> 0) then
  begin
    Close();
    Result := nil;
  end
  else
    Result := Self;
end;

function MYSQL.real_escape_string(_to: my_char; const from: my_char; length: my_uint): my_uint;
var
  RBS: RawByteString;
begin
  SetString(RBS, from, length);

  RBS := EncodeString(StringReplace(StringReplace(StringReplace(StringReplace(StringReplace(StringReplace(DecodeString(RBS), '\', '\\', [rfReplaceAll]), #0, '\0', [rfReplaceAll]), #10, '\n', [rfReplaceAll]), #13, '\r', [rfReplaceAll]), '''', '\''', [rfReplaceAll]), '"', '\"', [rfReplaceAll]));

  AnsiStrings.StrPCopy(_to, RBS);
  Result := System.Length(RBS);
end;

function MYSQL.real_query(query: my_char; length: my_int): my_int;
begin
  if (AnsiStrings.StrLen(query) = 0) then
    Result := -1
  else
    Result := ExecuteCommand(COM_QUERY, query, length, False);
end;

function MYSQL.Reconnect(): Boolean;
begin
  if (SERVER_STATUS and SERVER_STATUS_IN_TRANS <> 0) then
  begin
    SERVER_STATUS := SERVER_STATUS and not SERVER_STATUS_IN_TRANS;
    Result := False;
  end
  else
    Result := Assigned(real_connect(my_char(fhost), my_char(fuser), my_char(fpasswd), my_char(fdb), fport, my_char(fpipe_name), CAPABILITIES));
end;

function MYSQL.refresh(options: my_int): my_int;
begin
  Result := ExecuteCommand(COM_REFRESH, @options, SizeOf(options), freconnect);
end;

function MYSQL.select_db(db: my_char): my_int;
begin
  if (db = '') then
    Result := 1
  else
  begin
    Result := ExecuteCommand(COM_INIT_DB, db, AnsiStrings.StrLen(db), freconnect);
    if (Result = 0) then
      fdb := db;
  end;
end;

function MYSQL.SendDataFile(const Filename: RawByteString): Boolean;
// send file, initiated by LOAD DATA LOCAL INFILE
const
  MaxFileBufferSize = NET_BUFFER_LENGTH;
var
  Buffer: PAnsiChar;
  BufferSize: DWord;
  BytesPerSector: DWord;
  ErrMsg: array [0 .. MYSQL_ERRMSG_SIZE] of AnsiChar;
  Handle: THandle;
  NumberofFreeClusters: DWord;
  ptr: Pointer;
  ReadSize: DWord;
  SectorsPerCluser: DWord;
  Size: my_int;
  TotalNumberOfClusters: DWord;
begin
  if (not Assigned(flocal_infile_init) or not Assigned(flocal_infile_read) or not Assigned(flocal_infile_end) or not Assigned(flocal_infile_error)) then
  begin
    Handle := Windows.CreateFile(PChar(DecodeString(Filename)),
                                  GENERIC_READ,
                                  FILE_SHARE_READ,
                                  nil, OPEN_EXISTING, FILE_FLAG_NO_BUFFERING, 0);

    Result := Handle <> INVALID_HANDLE_VALUE;
    if (not Result) then
      Seterror(EE_FILENOTFOUND, EncodeString(Format('%s  (%s)', [SysErrorMessage(GetLastError()), Filename])))
    else
    begin
      BufferSize := MaxFileBufferSize;
      if (BufferSize > 0) then
      begin
        if (GetDiskFreeSpace(PChar(DecodeString(Filename)), SectorsPerCluser, BytesPerSector, NumberofFreeClusters, TotalNumberOfClusters)) then
          if (BufferSize mod BytesPerSector > 0) then
            Inc(BufferSize, BytesPerSector - BufferSize mod BytesPerSector);
        Buffer := VirtualAlloc(nil, BufferSize, MEM_COMMIT, PAGE_READWRITE);

        Result := Assigned(Buffer);
        if (not Result) then
          Seterror(CR_OUT_OF_MEMORY)
        else
        begin
          repeat
            Result := Windows.ReadFile(Handle, Buffer^, BufferSize, ReadSize, nil);
            if (not Result) then
              Seterror(EE_READ, EncodeString(Format('%s  (%s)', [SysErrorMessage(GetLastError()), Filename])))
            else
            begin
              if ((GetPacketSize() > 0) and (GetPacketSize() + Integer(ReadSize) > 2 * NET_BUFFER_LENGTH)) then
                Result := FlushPacketBuffers();
              if (Result) then
                Result := WritePacket(Buffer, ReadSize);
            end;
          until (not Result or (ReadSize = 0));

          VirtualFree(Buffer, BufferSize, MEM_RELEASE);
        end;
      end;

      CloseHandle(Handle);
    end;
  end
  else
  begin
    ptr := nil;
    Result := flocal_infile_init(@ptr, my_char(Filename), flocal_infile_userdata^) = 0;
    if (not Result) then
      Seterror(flocal_infile_error(ptr, @ErrMsg[0], Length(ErrMsg)), AnsiStrings.StrPas(@ErrMsg[0]))
    else
    begin
      BufferSize := MaxFileBufferSize;
      try
        GetMem(Buffer, BufferSize);
      except
        Seterror(CR_OUT_OF_MEMORY);
        Buffer := nil;
      end;

      Result := Assigned(Buffer);
      if (Result) then
      begin
        Direction := idWrite;
        repeat
          Size := flocal_infile_read(ptr, Buffer, BufferSize);
          Result := Size >= 0;

          if (not Result) then
            Seterror(flocal_infile_error(ptr, @ErrMsg[0], Length(ErrMsg)), AnsiStrings.StrPas(@ErrMsg[0]))
          else
          begin
            if ((GetPacketSize() > 0) and (GetPacketSize() + Size > 2 * NET_BUFFER_LENGTH)) then
              Result := FlushPacketBuffers();
            if (Result) then
              Result := WritePacket(Buffer, Size);
          end;
        until (not Result or (Size <= 0));

        FreeMem(Buffer);
      end;

      flocal_infile_end(ptr);
    end;
  end;

  if (Result) then
  begin
    if (GetPacketSize() > 0) then
      SetPacketPointer(1, PACKET_CURRENT);
    FlushPacketBuffers();
  end;
end;

function MYSQL.ServerError(): Boolean;
var
  ErrorCode: my_uint;
  ErrorMessage: RawByteString;
begin
  Result := Byte(PacketBuffer.Mem[PacketBuffer.Offset]) = $FF;

  if (Result) then
  begin
    SetPacketPointer(1, FILE_CURRENT); // $FF

    ReadPacket(ErrorCode, 2);

    if (CAPABILITIES and CLIENT_PROTOCOL_41 <> 0) then
    begin
      SetPacketPointer(1, FILE_CURRENT); // '#'
      ReadPacket(@FSQLState, 5);
    end;

    ReadPacket(ErrorMessage);

    Seterror(ErrorCode, ErrorMessage);

    SERVER_STATUS := SERVER_STATUS and not SERVER_MORE_RESULTS_EXISTS;
  end;
end;

function MYSQL.Seterror(const AErrNo: my_uint; const AError: RawByteString = ''): my_uint;
begin
  Result := inherited;

  FillChar(FSQLState, SizeOf(FSQLState), #0);
end;

function MYSQL.session_track_get_first(state_type: enum_session_state_type; out data: my_char; out length: size_t): my_int;
begin
  if (StateInfo.Data = '') then
  begin
    data := nil;
    length := 0;
    Result := 1;
  end
  else
  begin
    StateInfo.Index := 1;
    StateInfo.VariablenValue := False;
    Result := session_track_get_next(state_type, data, length);
  end;
end;

function MYSQL.session_track_get_next(state_type: enum_session_state_type; out data: my_char; out length: size_t): my_int;
var
  Len: my_ulonglong;
  StateType: enum_session_state_type;
begin
  data := nil;
  length := 0;
  Result := 1;

  if (StateInfo.VariablenValue) then
  begin
    if (state_type = SESSION_TRACK_SYSTEM_VARIABLES) then
    begin
      Inc(StateInfo.Index, ReadMem(PAnsiChar(@StateInfo.Data[StateInfo.Index]), System.Length(StateInfo.Data) - (StateInfo.Index - 1), Len));
      data := PAnsiChar(@StateInfo.Data[StateInfo.Index]);
      length := Len;
      Inc(StateInfo.Index, Len);
      StateInfo.VariablenValue := False;
      Result := 0;
    end;
  end
  else if (StateInfo.Index - 1 < System.Length(StateInfo.Data)) then
  begin
    repeat
      StateType := enum_session_state_type(StateInfo.Data[StateInfo.Index]);
      Inc(StateInfo.Index);
      Inc(StateInfo.Index, ReadMem(PAnsiChar(@StateInfo.Data[StateInfo.Index]), System.Length(StateInfo.Data) - (StateInfo.Index - 1), Len));
      if (StateType <> state_type) then
        Inc(StateInfo.Index, Len)
      else
        case (StateType) of
          SESSION_TRACK_SYSTEM_VARIABLES,
          SESSION_TRACK_SCHEMA,
          SESSION_TRACK_STATE_CHANGE:
            begin
              Inc(StateInfo.Index, ReadMem(PAnsiChar(@StateInfo.Data[StateInfo.Index]), System.Length(StateInfo.Data) - (StateInfo.Index - 1), Len));
              data := PAnsiChar(@StateInfo.Data[StateInfo.Index]);
              length := Len;
              Inc(StateInfo.Index, Len);
              StateInfo.VariablenValue := StateType = SESSION_TRACK_SYSTEM_VARIABLES;
              Result := 0;
            end;
//          SESSION_TRACK_GTIDS:
          else
            Inc(StateInfo.Index, Len)
        end;
    until ((Result = 0) or (StateInfo.Index - 1 >= System.Length(StateInfo.Data)));
  end;
end;

function MYSQL.set_character_set(const csname: my_char): my_int;
begin
  if ((get_server_version() < 40101) or (fcharacter_set_name = csname)) then
    Result := 0
  else
  begin
    if (query(my_char(RawByteString('SET NAMES ') + RawByteString(csname))) = 0) then
      fcharacter_set_name := RawByteString(LowerCase(string(csname)));

    Result := errno();
  end;
end;

procedure MYSQL.set_local_infile_default();
begin
  flocal_infile_end := nil;
  flocal_infile_error := nil;
  flocal_infile_init := nil;
  flocal_infile_read := nil;
  flocal_infile_userdata := nil;
end;

procedure MYSQL.set_local_infile_handler(local_infile_init: Tlocal_infile_init; local_infile_read: Tlocal_infile_read; local_infile_end: Tlocal_infile_end; local_infile_error: Tlocal_infile_error; userdata: Pointer);
begin
  flocal_infile_init := local_infile_init;
  flocal_infile_read := local_infile_read;
  flocal_infile_end := local_infile_end;
  flocal_infile_error := local_infile_error;
  flocal_infile_userdata := userdata;
end;

function MYSQL.set_server_option(option: enum_mysql_set_option): my_int;
var
  W: Word;
begin
  W := Word(option);
  Result := ExecuteCommand(COM_SET_OPTION, @W, SizeOf(W), freconnect);
end;

function MYSQL.shutdown(shutdown_level: mysql_enum_shutdown_level): my_int;
begin
  Result := ExecuteCommand(COM_SHUTDOWN, @shutdown_level, SizeOf(shutdown_level), freconnect);
end;

function MYSQL.sqlstate(): my_char;
begin
  Result := @FSQLState;
end;

function MYSQL.store_result(): MYSQL_RES;
begin
  Result := use_result();

  if (Assigned(Result) and (errno() = 0)) then
  begin
    Result.ResultType := rtStored;

    ReadRows(Result);
    Result.RowIndex := -1;
    Result.CurrentRow := nil;

    faffected_rows := result.RowCount;
  end;
end;

function MYSQL.thread_id(): my_uint;
begin
  Result := fthread_id;
end;

function MYSQL.use_result(): MYSQL_RES;
begin
  if ((errno() <> 0) or (CLIENT_STATUS = MYSQL_STATUS_READY)) then
    Result := nil
  else if (CLIENT_STATUS <> MYSQL_STATUS_GET_RESULT) then
  begin
    Seterror(CR_COMMANDS_OUT_OF_SYNC);
    Result := nil;
  end
  else if (FieldCount = 0) then
  begin
    Seterror(CR_UNKNOWN_ERROR);
    Result := nil;
  end
  else
  begin
    fres := MYSQL_RES.Create(Self, FieldCount);

    if (errno() <> 0) then
      FreeAndNil(fres);

    Result := res;
  end;
end;

function MYSQL.warning_count(): my_uint;
begin
  Result := fwarning_count;
end;

{ MYSQL_RES *******************************************************************}

constructor MYSQL_RES.Create(const Amysql: MYSQL; const AFieldCount: my_uint);
var
  Field: MYSQL_FIELD;
  Index: Integer;
  ItemCount: Integer;
  MemSize: Integer;
  Row: MYSQL_RES.PRow;
begin
  inherited Create();

  mysql := Amysql;

  CurrentRow := nil;
  FieldCount := 0;
  FieldIndex := -1;
  Fields := nil;
  RowCount := 0;
  RowIndex := -1;
  ResultType := rtUsed;

  if (AFieldCount = 0) then
    mysql.Seterror(CR_UNKNOWN_ERROR)
  else
    try
      Fields := AllocMem(AFieldCount * SizeOf(Fields^[0]));
    except
      mysql.Seterror(CR_OUT_OF_MEMORY);
    end;

  if (mysql.errno() = 0) then
  begin
    Row := nil; Field := nil;

    repeat
      ItemCount := mysql.ReadRow(Row);
      if (ItemCount <= 0) then
        Field := nil
      else
      begin
        MemSize := SizeOf(Field^);
        if (mysql.CAPABILITIES and CLIENT_PROTOCOL_41 = 0) then
          if (ItemCount < 5) then
            mysql.Seterror(CR_SERVER_HANDSHAKE_ERR)
          else
          begin
            Inc(MemSize, Row^.Lengths^[0] + 1);
            Inc(MemSize, Row^.Lengths^[1] + 1);
            if (ItemCount > 5) then Inc(MemSize, Row^.Lengths^[5] + 1);
          end
        else
          if (ItemCount < 7) then
            mysql.Seterror(CR_SERVER_HANDSHAKE_ERR)
          else
          begin
            Inc(MemSize, Row^.Lengths^[0] + 1);
            Inc(MemSize, Row^.Lengths^[1] + 1);
            Inc(MemSize, Row^.Lengths^[2] + 1);
            Inc(MemSize, Row^.Lengths^[3] + 1);
            Inc(MemSize, Row^.Lengths^[4] + 1);
            Inc(MemSize, Row^.Lengths^[5] + 1);
            if (ItemCount > 7) then Inc(MemSize, Row^.Lengths^[7] + 1);
          end;

        if (mysql.errno() = 0) then
          try
            Field := AllocMem(MemSize);
          except
            mysql.Seterror(CR_OUT_OF_MEMORY);
          end;

        if (mysql.errno() = 0) then
        begin
          Index := SizeOf(Field^);
          if (mysql.CAPABILITIES and CLIENT_PROTOCOL_41 = 0) then
          begin
            if (Assigned(Row^.Row^[0])) then begin Field^.table := @PAnsiChar(Field)[Index]; MoveMemory(Field^.table, Row^.Row^[0], Row^.Lengths^[0]); end; Inc(Index, Row^.Lengths^[0] + 1);
            Field^.table_length := Row^.Lengths^[0];
            if (Assigned(Row^.Row^[1])) then begin Field^.name := @PAnsiChar(Field)[Index]; MoveMemory(Field^.name, Row^.Row^[1], Row^.Lengths^[1]); end; Inc(Index, Row^.Lengths^[1] + 1);
            Field^.name_length := Row^.Lengths^[1];
            if (Assigned(Row^.Row^[2])) then MoveMemory(@Field^.length, @Row^.Row^[2][0], 3);
            if (Assigned(Row^.Row^[3])) then MoveMemory(@Field^.field_type, @Row^.Row^[3][0], 1);
            if (Assigned(Row^.Row^[4])) then
              if (mysql.SERVER_CAPABILITIES and CLIENT_LONG_FLAG = 0) then
                MoveMemory(@Field^.flags, @Row^.Row^[4][0], 1)
              else
                MoveMemory(@Field^.flags, @Row^.Row^[4][0], 2);
            if (Assigned(Row^.Row^[4])) then
              if (mysql.SERVER_CAPABILITIES and CLIENT_LONG_FLAG = 0) then
                MoveMemory(@Field^.decimals, @Row^.Row^[4][1], 1)
              else
                MoveMemory(@Field^.decimals, @Row^.Row^[4][2], 1);
            if ((ItemCount > 5) and Assigned(Row^.Row^[5])) then begin Field^.def := @PAnsiChar(Field)[Index]; MoveMemory(Field^.def, Row^.Row^[5], Row^.Lengths^[5] + 1); end;
            if (ItemCount > 5) then if (Assigned(Field^.def)) then Field^.def_length := Row^.Lengths^[5];
          end
          else
          begin
            if (Assigned(Row^.Row^[0])) then begin Field^.catalog := @PAnsiChar(Field)[Index]; MoveMemory(Field^.catalog, Row^.Row^[0], Row^.Lengths^[0]); end; Inc(Index, Row^.Lengths^[0] + 1);
            Field^.catalog_length := Row^.Lengths^[0];
            if (Assigned(Row^.Row^[1])) then begin Field^.db := @PAnsiChar(Field)[Index]; MoveMemory(Field^.db, Row^.Row^[1], Row^.Lengths^[1]); end; Inc(Index, Row^.Lengths^[1] + 1);
            Field^.db_length := Row^.Lengths^[1];
            if (Assigned(Row^.Row^[2])) then begin Field^.table := @PAnsiChar(Field)[Index]; MoveMemory(Field^.table, Row^.Row^[2], Row^.Lengths^[2]); end; Inc(Index, Row^.Lengths^[2] + 1);
            Field^.table_length := Row^.Lengths^[2];
            if (Assigned(Row^.Row^[3])) then begin Field^.org_table := @PAnsiChar(Field)[Index]; MoveMemory(Field^.org_table, Row^.Row^[3], Row^.Lengths^[3]); end; Inc(Index, Row^.Lengths^[3] + 1);
            Field^.org_table_length := Row^.Lengths^[3];
            if (Assigned(Row^.Row^[4])) then begin Field^.name := @PAnsiChar(Field)[Index]; MoveMemory(Field^.name, Row^.Row^[4], Row^.Lengths^[4]); end; Inc(Index, Row^.Lengths^[4] + 1);
            Field^.name_length := Row^.Lengths^[4];
            if (Assigned(Row^.Row^[5])) then begin Field^.org_name := @PAnsiChar(Field)[Index]; MoveMemory(Field^.org_name, Row^.Row^[5], Row^.Lengths^[5]); end; Inc(Index, Row^.Lengths^[5] + 1);
            Field^.org_name_length := Row^.Lengths^[5];
            if (Row^.Lengths^[6] >= 2) then MoveMemory(@Field^.charsetnr, @Row^.Row^[6][0], 1);
            if (Row^.Lengths^[6] >= 6) then MoveMemory(@Field^.length, @Row^.Row^[6][2], 4);
            if (Row^.Lengths^[6] >= 7) then MoveMemory(@Field^.field_type, @Row^.Row^[6][6], 1);
            if (Row^.Lengths^[6] >= 9) then MoveMemory(@Field^.flags, @Row^.Row^[6][7], 2);
            if (Row^.Lengths^[6] >= 10) then MoveMemory(@Field^.decimals, @Row^.Row^[6][9], 1);
            if ((ItemCount > 7) and Assigned(Row^.Row^[7])) then begin Field^.def := @PAnsiChar(Field)[Index]; MoveMemory(Field^.def, Row^.Row^[7], Row^.Lengths^[7]); end;
            if (ItemCount > 7) then Field^.def_length := Row^.Lengths^[7];
          end;

          // NUM_FLAG is not sent by the server so it needs to be set
          if ((Field^.field_type <= MYSQL_TYPE_INT24) and ((Field^.field_type <> MYSQL_TYPE_TIMESTAMP) or (Field^.Length = 14) or (Field^.Length = 8)) or (Field^.field_type = MYSQL_TYPE_YEAR)) then
            Field^.flags := Field^.flags or NUM_FLAG;

          Fields^[FieldCount] := Field;
        end;
        Inc(FieldCount);
      end;
    until ((mysql.errno() <> 0) or not Assigned(Field) or (FieldCount = AFieldCount));

    if (Assigned(Row)) then
      begin FreeMem(Row); Row := nil; end;

    if ((mysql.errno() = 0) and (mysql.ReadRow(Row) > 0) or (FieldCount <> AFieldCount)) then
      mysql.Seterror(CR_SERVER_HANDSHAKE_ERR);

    if (mysql.errno() <> 0) then
    begin
      FreeMem(Fields); Fields := nil;
    end
    else if (ResultType = rtUsed) then
    begin
      try
        CurrentRow := AllocMem(SizeOf(CurrentRow^) + FieldCount * (SizeOf(CurrentRow^.Lengths^[0]) + SizeOf(CurrentRow^.Row^[0])));
        CurrentRow^.MemSize := SizeOf(CurrentRow^) + FieldCount * (SizeOf(CurrentRow^.Lengths^[0]) + SizeOf(CurrentRow^.Row^[0]));
        CurrentRow^.Lengths := Pointer(@PAnsiChar(CurrentRow)[SizeOf(CurrentRow^)]);
        CurrentRow^.Row := Pointer(@PAnsiChar(CurrentRow)[SizeOf(CurrentRow^) + FieldCount * SizeOf(CurrentRow^.Lengths^[0])]);
      except
        mysql.Seterror(CR_OUT_OF_MEMORY);
      end;
    end;
  end;
end;

procedure MYSQL_RES.data_seek(offset: my_ulonglong);
begin
  if ((ResultType = rtStored) and (0 <= offset) and (offset < RowCount)) then
  begin
    RowIndex := 0;
    CurrentRow := FirstRow;

    while (Assigned(CurrentRow) and (RowIndex < offset)) do
    begin
      CurrentRow := CurrentRow.Next;
      Inc(RowIndex);
    end;
  end;
end;

destructor MYSQL_RES.Destroy();
var
  I: my_int;
  Next_Row: MYSQL_RES.PRow;
begin
  if ((mysql.CLIENT_STATUS = MYSQL_STATUS_USE_RESULT)) then
    MysqlClient.ReadRows(Self);

  if (mysql.fres = Self) then
    mysql.fres := nil;

  if (ResultType = rtStored) then
    CurrentRow := FirstRow;
  while (Assigned(CurrentRow)) do
  begin
    Next_Row := CurrentRow.Next;
    FreeMem(CurrentRow);
    CurrentRow := Next_Row;
  end;
  if (Assigned(Fields)) then
  begin
    for I := 0 to FieldCount - 1 do
      FreeMem(Fields^[I]);
    FreeMem(Fields);
  end;

  inherited;
end;

function MYSQL_RES.fetch_field(): MYSQL_FIELD;
begin
  if (FieldIndex >= my_int(FieldCount) - 1) then
    Result := nil
  else
  begin
    Inc(FieldIndex);
    Result := Fields^[FieldIndex];
  end;
end;

function MYSQL_RES.fetch_field_direct(fieldnr: my_uint): MYSQL_FIELD;
begin
  if (fieldnr >= FieldCount) then
    Result := nil
  else
  begin
    Result := Fields^[fieldnr];
    FieldIndex := fieldnr;
  end;
end;

function MYSQL_RES.fetch_fields(): MYSQL_FIELDS;
begin
  Result := Fields;
end;

function MYSQL_RES.fetch_lengths(): MYSQL_LENGTHS;
begin
  if (not Assigned(CurrentRow)) then
    Result := nil
  else
    Result := CurrentRow^.Lengths;
end;

function MYSQL_RES.fetch_row(): MYSQL_ROW;
begin
  if (ResultType = rtStored) then
    if (RowIndex >= RowCount - 1) then
      Result := nil
    else
    begin
      if (not Assigned(CurrentRow)) then
        CurrentRow := FirstRow
      else
        CurrentRow := CurrentRow^.Next;
      Result := CurrentRow^.Row;
      Inc(RowIndex);
    end
  else if (MysqlClient.CLIENT_STATUS <> MYSQL_STATUS_USE_RESULT) then
  begin
    MysqlClient.Seterror(CR_COMMANDS_OUT_OF_SYNC);
    Result := nil;
  end
  else if (MysqlClient.ReadRow(CurrentRow) <= 0) then
  begin
    FreeMem(CurrentRow); CurrentRow := nil;
    mysql.CLIENT_STATUS := MYSQL_STATUS_READY;
    Result := nil;
  end
  else
  begin
    Result := CurrentRow^.Row;

    Inc(RowIndex);
    Inc(RowCount);
  end;
end;

function MYSQL_RES.num_fields(): my_uint;
begin
  Result := FieldCount;
end;

function MYSQL_RES.num_rows(): my_ulonglong;
begin
  Result := RowCount;
end;

initialization
  WSAData.wVersion := 0;
  WS2_32 := 0;
  WSAConnectByNameA := nil;
finalization
  if (WSAData.wVersion <> 0) then
    WSACleanup();
  if (WS2_32 <> 0) then
    FreeLibrary(WS2_32);
end.


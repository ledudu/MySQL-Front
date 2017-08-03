unit MySQLDB;

interface {********************************************************************}

uses
  Windows,
  SyncObjs, Classes, SysUtils, Generics.Collections,
  DB, DBCommon, SqlTimSt,
  SQLParser, MySQLConsts;

type
  TMySQLMonitor = class;
  TMySQLConnection = class;                      
  TMySQLQuery = class;
  TMySQLDataSet = class;

  TMySQLLibrary = class
  type
    TLibraryType = (ltBuiltIn, ltDLL, ltHTTP);
  strict private
    FHandle: HModule;
    FLibraryType: TLibraryType;
    FFilename: TFileName;
    FVersion: Integer;
    function GetVersionStr(): string;
  public
    my_init: Tmy_init;
    mysql_affected_rows: Tmysql_affected_rows;
    mysql_character_set_name: Tmysql_character_set_name;
    mysql_close: Tmysql_close;
    mysql_errno: Tmysql_errno;
    mysql_error: Tmysql_error;
    mysql_fetch_field: Tmysql_fetch_field;
    mysql_fetch_field_direct: Tmysql_fetch_field_direct;
    mysql_fetch_fields: Tmysql_fetch_fields;
    mysql_fetch_lengths: Tmysql_fetch_lengths;
    mysql_fetch_row: Tmysql_fetch_row;
    mysql_field_count: Tmysql_field_count;
    mysql_free_result: Tmysql_free_result;
    mysql_get_client_info: Tmysql_get_client_info;
    mysql_get_client_version: Tmysql_get_client_version;
    mysql_get_host_info: Tmysql_get_host_info;
    mysql_get_server_info: Tmysql_get_server_info;
    mysql_get_server_version: Tmysql_get_server_version;
    mysql_info: Tmysql_info;
    mysql_init: Tmysql_init;
    mysql_insert_id: Tmysql_insert_id;
    mysql_library_end: Tmysql_library_end;
    mysql_library_init: Tmysql_library_init;
    mysql_more_results: Tmysql_more_results;
    mysql_next_result: Tmysql_next_result;
    mysql_num_fields: Tmysql_num_fields;
    mysql_num_rows: Tmysql_num_rows;
    mysql_options: Tmysql_options;
    mysql_ping: Tmysql_ping;
    mysql_real_connect: Tmysql_real_connect;
    mysql_real_escape_string: Tmysql_real_escape_string;
    mysql_real_query: Tmysql_real_query;
    mysql_session_track_get_first: Tmysql_session_track_get_first;
    mysql_session_track_get_next: Tmysql_session_track_get_next;
    mysql_set_character_set: Tmysql_set_character_set;
    mysql_set_local_infile_default: Tmysql_set_local_infile_default;
    mysql_set_local_infile_handler: Tmysql_set_local_infile_handler;
    mysql_set_server_option: Tmysql_set_server_option;
    mysql_shutdown: Tmysql_shutdown;
    mysql_store_result: Tmysql_store_result;
    mysql_thread_end: Tmysql_thread_end;
    mysql_thread_id: Tmysql_thread_id;
    mysql_thread_init: Tmysql_thread_init;
    mysql_thread_save: Tmysql_thread_save;
    mysql_use_result: Tmysql_use_result;
    mysql_warning_count: Tmysql_warning_count;
    constructor Create(const ALibraryType: TLibraryType; const AFilename: TFileName);
    destructor Destroy(); override;
    procedure SetField(const RawField: MYSQL_FIELD; out Field: TMYSQL_FIELD); inline;
    property Filename: TFileName read FFilename;
    property Handle: HModule read FHandle;
    property LibraryType: TLibraryType read FLibraryType;
    property Version: Integer read FVersion;
    property VersionStr: string read GetVersionStr;
  end;

  EDatabasePostError = class(EDatabaseError);
  EDatabaseUpdateError = class(EDatabaseError);
  EMySQLEncodingError = class(Exception);

  EMySQLError = class(EDatabaseError)
  protected
    FConnection: TMySQLConnection;
    FErrorCode: Integer;
  public
    constructor Create(const Msg: string; const AErrorCode: Integer; const AConnection: TMySQLConnection);
    property Connection: TMySQLConnection read FConnection;
    property ErrorCode: Integer read FErrorCode;
  end;

  TMySQLMonitor = class(TComponent)
  type
    TTraceType = (ttTime, ttRequest, ttResult, ttInfo, ttDebug);
    TTraceTypes = set of TTraceType;
    TMySQLOnMonitor = procedure (const Connection: TMySQLConnection; const Text: PChar; const Length: Integer; const ATraceType: TTraceType) of object;
  strict private
    Cache: record
      First: Integer;
      ItemsLen: TList<Integer>;
      Mem: PChar;
      MemLen: Integer;
      UsedLen: Integer;
    end;
    FConnection: TMySQLConnection;
    FCriticalSection: TCriticalSection; // Debug 2017-03-18
    FEnabled: Boolean;
    FOnMonitor: TMySQLOnMonitor;
    FTraceTypes: TTraceTypes;
    function GetCacheSize(): Integer;
    function GetCacheText(): string;
    procedure SetConnection(const AConnection: TMySQLConnection);
    procedure SetCacheSize(const ACacheSize: Integer);
    procedure SetOnMonitor(const AOnMonitor: TMySQLOnMonitor);
  public
    procedure Append(const Text: PChar; const Length: Integer; const ATraceType: TTraceType); overload;
    procedure Append(const Text: string; const ATraceType: TTraceType); overload; inline;
    procedure Append2(const Text: PChar; const Length: Integer; const ATraceType: TTraceType);
    procedure Clear();
    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy(); override;
    property CacheText: string read GetCacheText;
  published
    property Connection: TMySQLConnection read FConnection write SetConnection;
    property Enabled: Boolean read FEnabled write FEnabled default False;
    property OnMonitor: TMySQLOnMonitor read FOnMonitor write SetOnMonitor default nil;
    property CacheSize: Integer read GetCacheSize write SetCacheSize;
    property TraceTypes: TTraceTypes read FTraceTypes write FTraceTypes default [ttRequest];
  end;

  TMySQLConnection = class(TCustomConnection)
  type
    TSyncThread = class;
    TDataHandle = TSyncThread;
    PResultHandle = ^TResultHandle;
    TResultHandle = record
      SQL: string;
      SQLIndex: Integer;
      SyncThread: TSyncThread;
    end;

    TConvertErrorNotifyEvent = procedure(Sender: TObject; Text: string) of object;
    TDatabaseChangeEvent = procedure(const Connection: TMySQLConnection; const NewName: string) of object;
    TErrorEvent = procedure(const Connection: TMySQLConnection; const ErrorCode: Integer; const ErrorMessage: string) of object;
    TVariableChangeEvent = procedure(const Connection: TMySQLConnection; const Name, NewValue: string) of object;
    TOnUpdateIndexDefsEvent = procedure(const DataSet: TMySQLQuery; const IndexDefs: TIndexDefs) of object;
    TResultEvent = function(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
      const CommandText: string; const DataHandle: TDataHandle; const Data: Boolean): Boolean of object;
    TSynchronizeEvent = procedure(const Data: Pointer; const Tag: NativeInt) of object;

    TLibraryDataType = (ldtConnecting, ldtExecutingSQL, ldtDisconnecting);
    Plocal_infile = ^Tlocal_infile;
    Tlocal_infile = record
      Buffer: Pointer;
      BufferSize: DWord;
      Connection: TMySQLConnection;
      ErrorCode: Integer;
      Filename: array [0 .. MAX_PATH] of Char;
      Handle: THandle;
      LastError: DWord;
      Position: DWord;
    end;

    TSyncThread = class(TThread)
    type
      TMode = (smSQL, smResultHandle, smDataSet);
      TState = (ssClose, ssConnect, ssConnecting, ssReady, ssBeforeExecuteSQL,
        ssFirst, ssNext, ssExecutingFirst, ssExecutingNext, ssResult,
        ssReceivingResult, ssAfterExecuteSQL, ssDisconnect, ssDisconnecting);
    strict private
      FConnection: TMySQLConnection;
      FRunExecute: TEvent;
      function GetCommandText(): string;
      function GetIsRunning(): Boolean;
      function GetNextCommandText(): string;
    protected
      CLStmts: array of Boolean;
      DataSet: TMySQLQuery;
      Done: TEvent;
      ErrorCode: Integer;
      ErrorMessage: string;
      Executed: TEvent;
      ExecutionTime: TDateTime;
      FinishedReceiving: Boolean;
      LibHandle: MySQLConsts.MYSQL;
      LibThreadId: my_uint;
      Mode: TMode;
      OnResult: TResultEvent;
      ResHandle: MYSQL_RES;
      SQL: string;
      SQLIndex: Integer;
      StmtIndex: Integer;
      StmtLengths: TList<Integer>;
      State: TState;
      SynchronCount: Integer;
      WarningCount: Integer;
      procedure Execute(); override;
      property CommandText: string read GetCommandText;
      property IsRunning: Boolean read GetIsRunning;
      property NextCommandText: string read GetNextCommandText;
      property RunExecute: TEvent read FRunExecute;
    public
      constructor Create(const AConnection: TMySQLConnection);
      destructor Destroy(); override;
      property Connection: TMySQLConnection read FConnection;
      property DebugResHandle: MYSQL_RES read ResHandle; // Debug 2017-03-21
      property DebugState: TState read State; // Debug 2017-02-16
      property DebugSQL: string read SQL; // Debug 2017-02-19
    end;

    TTerminatedThreads = class(TList)
    strict private
      CriticalSection: TCriticalSection;
      FConnection: TMySQLConnection;
    protected
      property Connection: TMySQLConnection read FConnection;
    public
      constructor Create(const AConnection: TMySQLConnection);
      destructor Destroy(); override;
      function Add(const Item: Pointer): Integer; reintroduce;
      procedure Delete(const Item: Pointer); overload;
    end;

  strict private
    BesideThreadWaits: Boolean;
    CountSQLLength: Boolean;
    FAfterExecuteSQL: TNotifyEvent;
    FAnsiQuotes: Boolean;
    FAsynchron: Boolean;
    FBeforeExecuteSQL: TNotifyEvent;
    FCharsetClient: string;
    FCharsetResult: string;
    FCodePageClient: Cardinal;
    FCodePageResult: Cardinal;
    FConnected: Boolean;
    FDebugMonitor: TMySQLMonitor;
    FErrorCode: Integer;
    FErrorMessage: string;
    FErrorCommandText: string;
    FHost: string;
    FHostInfo: string;
    FHTTPAgent: string;
    FIdentifierQuoted: Boolean;
    FIdentifierQuoter: Char;
    FLatestConnect: TDateTime;
    FLibraryName: string;
    FLibraryType: TMySQLLibrary.TLibraryType;
    FMariaDBVersion: Integer;
    FMySQLVersion: Integer;
    FOnConvertError: TConvertErrorNotifyEvent;
    FOnDatabaseChange: TDatabaseChangeEvent;
    FOnSQLError: TErrorEvent;
    FOnUpdateIndexDefs: TOnUpdateIndexDefsEvent;
    FOnVariableChange: TVariableChangeEvent;
    FPassword: string;
    FPort: Word;
    FServerTimeout: LongWord;
    FServerVersionStr: string;
    FSynchronCount: Integer;
    FSQLMonitors: TList;
    FSQLParser: TSQLParser;
    FTerminateCS: TCriticalSection;
    FTerminatedThreads: TTerminatedThreads;
    FThreadDeep: Integer;
    FThreadId: my_uint;
    FUsername: string;
    InMonitor: Boolean;
    InOnResult: Boolean;
    KillThreadId: my_uint;
    SilentCount: Integer;
    FSyncThreadExecuted: TEvent;
    function GetNextCommandText(): string;
    function GetServerTime(): TDateTime;
    function GetHandle(): MySQLConsts.MYSQL;
    function GetInfo(): string;
    procedure SetDatabaseName(const ADatabaseName: string);
    procedure SetHost(const AHost: string);
    procedure SetLibraryName(const ALibraryName: string);
    procedure SetLibraryType(const ALibraryType: TMySQLLibrary.TLibraryType);
    procedure SetPassword(const APassword: string);
    procedure SetPort(const APort: Word);
    procedure SetUsername(const AUsername: string);
    function UseCompression(): Boolean; inline;
  private
    CommittingDataSet: TMySQLDataSet;
  protected
    FDatabaseName: string;
    FExecutedStmts: Integer;
    FExecutionTime: TDateTime;
    FFormatSettings: TFormatSettings;
    FLib: TMySQLLibrary;
    FMultiStatements: Boolean;
    FRowsAffected: Int64;
    FSuccessfullExecutedSQLLength: Integer;
    FSyncThread: TSyncThread;
    FWarningCount: Integer;
    TimeDiff: TDateTime;
    procedure DoAfterExecuteSQL(); virtual;
    procedure DoBeforeExecuteSQL(); virtual;
    procedure DoConnect(); override;
    procedure DoConvertError(const Sender: TObject; const Text: string; const Error: EConvertError); virtual;
    procedure DoDatabaseChange(const NewName: string); virtual;
    procedure DoDisconnect(); override;
    procedure DoError(const AErrorCode: Integer; const AErrorMessage: string); virtual;
    procedure DoVariableChange(const Name, NewValue: string); virtual;
    function GetErrorMessage(const AHandle: MySQLConsts.MYSQL): string; virtual;
    function GetConnected(): Boolean; override;
    function GetDataFileAllowed(): Boolean; virtual;
    function GetInsertId(): my_ulonglong; virtual;
    function GetMaxAllowedServerPacket(): Integer; virtual;
    function InternExecuteSQL(const Mode: TSyncThread.TMode; const SQL: string;
      const OnResult: TResultEvent = nil; const Done: TEvent = nil;
      const DataSet: TMySQLDataSet = nil): Boolean; overload; virtual;
    procedure local_infile_end(const local_infile: Plocal_infile); virtual;
    function local_infile_error(const local_infile: Plocal_infile; const error_msg: my_char; const error_msg_len: my_uint): my_int; virtual;
    function local_infile_init(out local_infile: Plocal_infile; const filename: my_char): my_int; virtual;
    function local_infile_read(const local_infile: Plocal_infile; buf: my_char; const buf_len: my_uint): my_int; virtual;
    procedure RegisterSQLMonitor(const SQLMonitor: TMySQLMonitor); virtual;
    procedure SetAnsiQuotes(const AAnsiQuotes: Boolean); virtual;
    procedure SetCharsetClient(const ACharset: string); virtual;
    procedure SetCharsetResult(const ACharset: string); virtual;
    procedure SetConnected(Value: Boolean); override;
    function SQLUse(const DatabaseName: string): string; virtual;
    procedure Sync(const SyncThread: TSyncThread);
    procedure SyncAfterExecuteSQL(const SyncThread: TSyncThread);
    procedure SyncBeforeExecuteSQL(const SyncThread: TSyncThread);
    procedure SyncBindDataSet(const DataSet: TMySQLQuery);
    procedure SyncConnecting(const SyncThread: TSyncThread);
    procedure SyncConnected(const SyncThread: TSyncThread);
    procedure SyncDisconnecting(const SyncThread: TSyncThread);
    procedure SyncDisconnected(const SyncThread: TSyncThread);
    procedure SyncExecute(const SyncThread: TSyncThread);
    procedure SyncExecuted(const SyncThread: TSyncThread);
    procedure SyncExecutingFirst(const SyncThread: TSyncThread);
    procedure SyncExecutingNext(const SyncThread: TSyncThread);
    procedure SyncHandledResult(const SyncThread: TSyncThread);
    procedure SyncPing(const SyncThread: TSyncThread);
    procedure SyncReceivingResult(const SyncThread: TSyncThread);
    procedure SyncReleaseDataSet(const DataSet: TMySQLQuery);
    procedure UnRegisterSQLMonitor(const SQLMonitor: TMySQLMonitor); virtual;
    procedure WriteMonitor(const Text: string; const TraceType: TMySQLMonitor.TTraceType); overload; inline;
    procedure WriteMonitor(const Text: PChar; const Length: Integer; const TraceType: TMySQLMonitor.TTraceType); overload;
    property Handle: MySQLConsts.MYSQL read GetHandle;
    property IdentifierQuoter: Char read FIdentifierQuoter;
    property IdentifierQuoted: Boolean read FIdentifierQuoted write FIdentifierQuoted;
    property SynchronCount: Integer read FSynchronCount;
    property SyncThread: TSyncThread read FSyncThread;
    property SyncThreadExecuted: TEvent read FSyncThreadExecuted;
    property TerminateCS: TCriticalSection read FTerminateCS;
    property TerminatedThreads: TTerminatedThreads read FTerminatedThreads;
  public
    procedure BeginSilent(); virtual;
    procedure BeginSynchron(const Index: Integer); virtual;
    function CharsetToCharsetNr(const Charset: string): Byte; virtual;
    function CharsetToCodePage(const Charset: string): Cardinal; overload; virtual;
    procedure CancelResultHandle(var ResultHandle: TResultHandle);
    procedure CloseResultHandle(var ResultHandle: TResultHandle);
    function CodePageToCharset(const CodePage: Cardinal): string; virtual;
    constructor Create(AOwner: TComponent); override;
    function CreateResultHandle(out ResultHandle: TResultHandle; const SQL: string): Boolean;
    destructor Destroy(); override;
    procedure EndSilent(); virtual;
    procedure EndSynchron(const Index: Integer); virtual;
    function EscapeIdentifier(const Identifier: string): string; virtual;
    function ExecuteResult(var ResultHandle: TResultHandle): Boolean;
    function ExecuteSQL(const SQL: string; const OnResult: TResultEvent = nil): Boolean; overload; virtual;
    function InUse(): Boolean; virtual;
    function SendSQL(const SQL: string; const Done: TEvent): Boolean; overload; virtual;
    function SendSQL(const SQL: string; const OnResult: TResultEvent = nil; const Done: TEvent = nil): Boolean; overload; virtual;
    procedure Terminate();
    property AnsiQuotes: Boolean read FAnsiQuotes write SetAnsiQuotes;
    property CodePageClient: Cardinal read FCodePageClient;
    property CodePageResult: Cardinal read FCodePageResult;
    property DataFileAllowed: Boolean read GetDataFileAllowed;
    property DebugMonitor: TMySQLMonitor read FDebugMonitor;
    property ErrorCode: Integer read FErrorCode;
    property ErrorMessage: string read FErrorMessage;
    property ErrorCommandText: string read FErrorCommandText;
    property ExecutedStmts: Integer read FExecutedStmts;
    property ExecutionTime: TDateTime read FExecutionTime;
    property FormatSettings: TFormatSettings read FFormatSettings;
    property HostInfo: string read FHostInfo;
    property HTTPAgent: string read FHTTPAgent write FHTTPAgent;
    property Info: string read GetInfo;
    property InsertId: my_ulonglong read GetInsertId;
    property LatestConnect: TDateTime read FLatestConnect;
    property Lib: TMySQLLibrary read FLib;
    property MariaDBVersion: Integer read FMariaDBVersion;
    property MySQLVersion: Integer read FMySQLVersion;
    property MaxAllowedServerPacket: Integer read GetMaxAllowedServerPacket;
    property MultiStatements: Boolean read FMultiStatements;
    property NextCommandText: string read GetNextCommandText;
    property RowsAffected: Int64 read FRowsAffected;
    property ServerDateTime: TDateTime read GetServerTime;
    property ServerVersionStr: string read FServerVersionStr;
    property SQLParser: TSQLParser read FSQLParser;
    property SuccessfullExecutedSQLLength: Integer read FSuccessfullExecutedSQLLength;
    property ThreadId: my_uint read FThreadId;
    property WarningCount: Integer read FWarningCount;
    property DebugSyncThread: TSyncThread read FSyncThread; // Debug 2017-02-19
  published
    property Asynchron: Boolean read FAsynchron write FAsynchron default False;
    property AfterExecuteSQL: TNotifyEvent read FAfterExecuteSQL write FAfterExecuteSQL;
    property BeforeExecuteSQL: TNotifyEvent read FBeforeExecuteSQL write FBeforeExecuteSQL;
    property CharsetClient: string read FCharsetClient write SetCharsetClient;
    property CharsetResult: string read FCharsetResult write SetCharsetResult;
    property DatabaseName: string read FDatabaseName write SetDatabaseName;
    property Host: string read FHost write SetHost;
    property LibraryName: string read FLibraryName write SetLibraryName;
    property LibraryType: TMySQLLibrary.TLibraryType read FLibraryType write SetLibraryType default ltBuiltIn;
    property OnConvertError: TConvertErrorNotifyEvent read FOnConvertError write FOnConvertError;
    property OnDatabaseChange: TDatabaseChangeEvent read FOnDatabaseChange write FOnDatabaseChange;
    property OnSQLError: TErrorEvent read FOnSQLError write FOnSQLError;
    property OnUpdateIndexDefs: TOnUpdateIndexDefsEvent read FOnUpdateIndexDefs write FOnUpdateIndexDefs;
    property OnVariableChange: TVariableChangeEvent read FOnVariableChange write FOnVariableChange;
    property Password: string read FPassword write SetPassword;
    property Port: Word read FPort write SetPort default MYSQL_PORT;
    property ServerTimeout: LongWord read FServerTimeout write FServerTimeout default 0;
    property Username: string read FUsername write SetUsername;
    property Connected;
    property AfterConnect;
    property BeforeConnect;
    property AfterDisconnect;
    property BeforeDisconnect;
  end;

  TMySQLQuery = class(TDataSet)
  type
    TCommandType = (ctQuery, ctTable);
    PRecordBufferData = ^TRecordBufferData;
    TRecordBufferData = packed record
      Identifier963: Integer;
      LibLengths: MYSQL_LENGTHS;
      LibRow: MYSQL_ROW;
    end;
    TInternRecordBuffers = TList<PRecordBufferData>;
    TRecordCompareDefs = array of record Ascending: Boolean; DataSize: Integer; Field: TField; end;
  strict private
    FConnection: TMySQLConnection;
    FBufferSize: UInt64;
    FIndexDefs: TIndexDefs;
    FInformConvertError: Boolean;
    FInternRecordBuffers: TInternRecordBuffers;
    FInternRecordBuffersCS: TCriticalSection;
    FRecNo: Integer;
    FRecordReceived: TEvent;
    FRecordsReceived: TEvent;
    FRowsAffected: Integer;
    function GetFinishedReceiving(): Boolean; inline;
    function GetHandle(): MySQLConsts.MYSQL_RES;
  protected
    FDataSet: UInt64;
    FCommandText: string;
    FCommandType: TCommandType;
    FDatabaseName: string;
    SyncThread: TMySQLConnection.TSyncThread;
    function AllocRecordBuffer(): TRecordBuffer; override;
    function FindRecord(Restart, GoForward: Boolean): Boolean; override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    function GetCanModify(): Boolean; override;
    function GetFieldData(const Field: TField; const Buffer: Pointer; const Data: PRecordBufferData): Boolean; overload; virtual;
    function GetLibLengths(): MYSQL_LENGTHS; virtual;
    function GetLibRow(): MYSQL_ROW; virtual;
    function GetIsIndexField(Field: TField): Boolean; override;
    function GetRecNo(): Integer; override;
    function GetRecord(Buffer: TRecBuf; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordCount(): Integer; override;
    function GetUniDirectional(): Boolean; virtual;
    function InternAddRecord(const LibRow: MYSQL_ROW; const LibLengths: MYSQL_LENGTHS; const Index: Integer = -1): Boolean; virtual;
    procedure InternalClose(); override;
    procedure InternalHandleException(); override;
    procedure InternalInitFieldDefs(); override;
    procedure InternalOpen(); override;
    function IsCursorOpen(): Boolean; override;
    function MoveRecordBufferData(var DestData: TMySQLQuery.PRecordBufferData; const SourceData: TMySQLQuery.PRecordBufferData): Boolean;
    function RecordCompare(const CompareDefs: TRecordCompareDefs; const A, B: TMySQLQuery.PRecordBufferData; const FieldIndex: Integer = 0): Integer;
    procedure SetActive(Value: Boolean); override;
    function SetActiveEvent(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
      const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean; virtual;
    procedure SetCommandText(const ACommandText: string); virtual;
    procedure SetConnection(const AConnection: TMySQLConnection); virtual;
    procedure UpdateIndexDefs(); override;
    property DataSize: UInt64 read FBufferSize;
    property Handle: MySQLConsts.MYSQL_RES read GetHandle;
    property IndexDefs: TIndexDefs read FIndexDefs;
    property InternRecordBuffers: TInternRecordBuffers read FInternRecordBuffers;
    property InternRecordBuffersCS: TCriticalSection read FInternRecordBuffersCS;
    property RecordReceived: TEvent read FRecordReceived;
    property RecordsReceived: TEvent read FRecordsReceived;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;
    procedure Open(const DataHandle: TMySQLConnection.TDataHandle); overload; virtual;
    procedure Open(const ResultHandle: TMySQLConnection.TResultHandle); overload; inline;
    function SQLFieldValue(const Field: TField; Data: PRecordBufferData = nil): string; overload; virtual;
    property DatabaseName: string read FDatabaseName;
    property FinishedReceiving: Boolean read GetFinishedReceiving;
    property LibLengths: MYSQL_LENGTHS read GetLibLengths;
    property LibRow: MYSQL_ROW read GetLibRow;
    property RowsAffected: Integer read FRowsAffected;
    property UniDirectional: Boolean read GetUniDirectional;
  published
    property CommandText: string read FCommandText write SetCommandText;
    property CommandType: TCommandType read FCommandType;
    property Connection: TMySQLConnection read FConnection write SetConnection;
    property Active;
    property AfterClose;
    property AfterOpen;
    property AfterRefresh;
    property AfterScroll;
    property BeforeClose;
    property BeforeEdit;
    property BeforeInsert;
    property BeforeOpen;
    property BeforeRefresh;
    property BeforeScroll;
    property OnCalcFields;
    property OnFilterRecord;
    property OnNewRecord;
  end;

  TMySQLDataSet = class(TMySQLQuery)
  type
    PBookmarks = ^TBookmarks;
    TBookmarks = array of TBookmark;
    TTextWidth = function (const Text: string): Integer of object;
    PInternRecordBuffer = ^TInternRecordBuffer;
    TInternRecordBuffer = record
      Identifier123: Integer;
      NewData: TMySQLQuery.PRecordBufferData;
      OldData: TMySQLQuery.PRecordBufferData;
      SortIndex: Integer;
      VisibleInFilter: Boolean;
    end;
    PExternRecordBuffer = ^TExternRecordBuffer;
    TExternRecordBuffer = record
      Identifier432: Integer;
      Index: Integer;
      InternRecordBuffer: PInternRecordBuffer;
      BookmarkFlag: TBookmarkFlag;
    end;
    TWantedRecord = (wrNone, wrFirst, wrNext, wrLast);

    TInternRecordBuffers = class(TList<PInternRecordBuffer>)
    strict private
      FDataSet: TMySQLDataSet;
      FIndex: Integer;
      function GetSortDef(): TIndexDef; inline;
      procedure SetIndex(AValue: Integer);
      property SortDef: TIndexDef read GetSortDef;
    public
      FilteredRecordCount: Integer;
      procedure Clear();
      constructor Create(const ADataSet: TMySQLDataSet);
      procedure Delete(Index: Integer);
      function IndexOf(const Bookmark: TBookmark): Integer; overload; inline;
      function IndexFor(const Data: TMySQLQuery.TRecordBufferData; const IgnoreIndex: Integer = -1): Integer; overload;
      procedure Insert(Index: Integer; const Item: PInternRecordBuffer);
      property DataSet: TMySQLDataSet read FDataSet;
      property Index: Integer read FIndex write SetIndex;
    end;

  strict private
    DeleteByWhereClause: Boolean;
    FCachedUpdates: Boolean;
    FCanModify: Boolean;
    FCursorOpen: Boolean;
    FDataSize: UInt64;
    FilterParser: TExprParser;
    FInternRecordBuffers: TInternRecordBuffers;
    FLocateNext: Boolean;
    FSortDef: TIndexDef;
    FTableName: string;
    InGetNextRecords: Boolean;
    InternalPostResult: record
      Exception: Exception;
      InternRecordBuffer: PInternRecordBuffer;
      NewIndex: Integer;
    end;
    function AllocInternRecordBuffer(): PInternRecordBuffer;
    procedure FreeInternRecordBuffer(const InternRecordBuffer: PInternRecordBuffer);
    function GetPendingRecordCount(): Integer;
    function InternalPostEvent(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
      const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
    procedure SetCachedUpdates(AValue: Boolean);
    function VisibleInFilter(const InternRecordBuffer: PInternRecordBuffer): Boolean;
  private
    AppliedBuffers: TList<PInternRecordBuffer>;
    PendingBuffers: TList<PInternRecordBuffer>;
  protected
    DeleteBookmarks: PBookmarks;
    WantedRecord: TWantedRecord;
    procedure ActivateFilter(); virtual;
    function AllocRecordBuffer(): TRecordBuffer; override;
    procedure AfterCommit(); virtual;
    procedure DeactivateFilter(); virtual;
    function FindRecord(Restart, GoForward: Boolean): Boolean; override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure GetBookmarkData(Buffer: TRecBuf; Data: TBookmark); override;
    function GetBookmarkFlag(Buffer: TRecBuf): TBookmarkFlag; override;
    function GetCanModify(): Boolean; override;
    function GetLibLengths(): MYSQL_LENGTHS; override;
    function GetLibRow(): MYSQL_ROW; override;
    function GetNextRecords(): Integer; override;
    function GetRecNo(): Integer; override;
    function GetRecord(Buffer: TRecBuf; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetRecordCount(): Integer; override;
    function GetUniDirectional(): Boolean; override;
    procedure InternActivateFilter();
    function InternAddRecord(const LibRow: MYSQL_ROW; const LibLengths: MYSQL_LENGTHS; const Index: Integer = -1): Boolean; override;
    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); override;
    procedure InternalCancel(); override;
    procedure InternalClose(); override;
    procedure InternalDelete(); override;
    procedure InternalEdit(); override;
    procedure InternalFirst(); override;
    procedure InternalGotoBookmark(Bookmark: TBookmark); override;
    procedure InternalInitFieldDefs(); override;
    procedure InternalInitRecord(Buffer: TRecBuf); override;
    procedure InternalInsert(); override;
    procedure InternalLast(); override;
    procedure InternalOpen(); override;
    procedure InternalPost(); override;
    procedure InternalRefresh(); override;
    procedure InternalSetToRecord(Buffer: TRecBuf); override;
    function IsCursorOpen(): Boolean; override;
    procedure SetBookmarkData(Buffer: TRecBuf; Data: TBookmark); override;
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer); override;
    procedure SetFieldData(const Field: TField; const Buffer: Pointer;
      const Size: Integer; InternRecordBuffer: PInternRecordBuffer = nil); overload; virtual;
    procedure SetFieldsSortTag(); virtual;
    procedure SetFiltered(Value: Boolean); override;
    procedure SetFilterText(const Value: string); override;
    procedure SetRecNo(Value: Integer); override;
    function SQLFieldValue(const Field: TField; Buffer: TRecordBuffer = nil): string; overload; virtual;
    function SQLTableClause(): string; virtual;
    function SQLUpdate(): string; virtual;
    procedure UpdateIndexDefs(); override;
    property DataSize: UInt64 read FDataSize;
    property InternRecordBuffers: TInternRecordBuffers read FInternRecordBuffers;
  public
    Progress: string;
    function BookmarkValid(Bookmark: TBookmark): Boolean; override;
    function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer; override;
    constructor Create(AOwner: TComponent); override;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    function Commit(): Boolean; virtual;
    function CommitEvent(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
      const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
    procedure Delete(const Bookmarks: TBookmarks); overload;
    procedure DeleteAll();
    procedure DeletePendingRecords(); virtual;
    destructor Destroy(); override;
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;
    function GetMaxTextWidth(const Field: TField; const TextWidth: TTextWidth): Integer; virtual;
    function Locate(const KeyFields: string; const KeyValues: Variant;
      Options: TLocateOptions): Boolean; override;
    procedure Resync(Mode: TResyncMode); override;
    procedure Sort(const ASortDef: TIndexDef); virtual;
    function SQLDelete(): string; virtual;
    function SQLInsert(): string; virtual;
    function SQLWhereClause(const NewData: Boolean = False): string;
    property LocateNext: Boolean read FLocateNext write FLocateNext;
    property PendingRecordCount: Integer read GetPendingRecordCount;
    property SortDef: TIndexDef read FSortDef;
    property TableName: string read FTableName;
  published
    property CachedUpdates: Boolean read FCachedUpdates write SetCachedUpdates default False;
    property AfterCancel;
    property AfterDelete;
    property AfterEdit;
    property AfterInsert;
    property AfterPost;
    property BeforeCancel;
    property BeforeDelete;
    property BeforeEdit;
    property BeforeInsert;
    property BeforePost;
    property Filter;
    property Filtered;
    property FilterOptions;
    property OnDeleteError;
    property OnEditError;
    property OnPostError;
  end;

  TMySQLTable = class(TMySQLDataSet)
  strict private
    FAutomaticLoadNextRecords: Boolean;
    FLimit: Integer;
    FOffset: Integer;
  protected
    FLimitedDataReceived: Boolean;
    RequestedRecordCount: Integer;
    procedure DoBeforeScroll(); override;
    function GetCanModify(): Boolean; override;
    procedure InternalClose(); override;
    procedure InternalLast(); override;
    procedure InternalOpen(); override;
    procedure InternalRefresh(); override;
    function SQLSelect(): string; overload;
    function SQLSelect(const IgnoreLimit: Boolean): string; overload; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    function LoadNextRecords(const AllRecords: Boolean = False): Boolean; virtual;
    procedure Sort(const ASortDef: TIndexDef); override;
    property CommandText: string read FCommandText write SetCommandText;
    property LimitedDataReceived: Boolean read FLimitedDataReceived;
  published
    property AutomaticLoadNextRecords: Boolean read FAutomaticLoadNextRecords write FAutomaticLoadNextRecords default False;
    property Limit: Integer read FLimit write FLimit default 0;
    property Offset: Integer read FOffset write FOffset default 0;
  end;

  TMySQLBitField = class(TLargeintField)
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
    procedure SetAsString(const Value: string); override;
  end;

  TMySQLBlobField = class(TBlobField)
  protected
    function GetAsAnsiString(): AnsiString; override;
    function GetAsString(): string; override;
    function GetAsVariant(): Variant; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
    procedure SetAsString(const Value: string); override;
  end;

  TMySQLByteField = class(TByteField)
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
  end;

  TMySQLDateField = class(TDateField)
  strict private
    ZeroDateString: string;
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
    procedure SetAsString(const Value: string); override;
    procedure SetDataSet(ADataSet: TDataSet); override;
  end;

  TMySQLDateTimeField = class(TDateTimeField)
  strict private
    ZeroDateString: string;
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
    procedure SetAsString(const Value: string); override;
    procedure SetDataSet(ADataSet: TDataSet); override;
  end;

  TMySQLExtendedField = class(TExtendedField)
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
  end;

  TMySQLFloatField = class(TFloatField)
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
  end;

  TMySQLIntegerField = class(TIntegerField)
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
  end;

  TMySQLLargeintField = class(TLargeintField)
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
  end;

  TMySQLLargeWordField = class(TLargeintField)
  strict private
    FMaxValue: UInt64;
    FMinValue: UInt64;
    procedure CheckRange(Value, Min, Max: UInt64);
  protected
    function GetAsLargeInt(): Largeint; override;
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
    procedure SetAsLargeInt(Value: Largeint); override;
    procedure SetAsString(const Value: string); override;
  published
    property MinValue: UInt64 read FMinValue write FMinValue default 0;
    property MaxValue: UInt64 read FMaxValue write FMaxValue default 0;
  end;

  TMySQLLongWordField = class(TLongWordField)
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
  end;

  TMySQLShortIntField = class(TShortIntField)
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
  end;

  TMySQLSingleField = class(TSingleField)
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
  end;

  TMySQLSmallIntField = class(TSmallIntField)
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
  end;

  TMySQLStringField = class(TStringField)
  protected
    function GetAsAnsiString(): AnsiString; override;
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
    procedure SetAsString(const Value: string); override;
  end;

  TMySQLTimeField = class(TTimeField)
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
    procedure SetDataSet(ADataSet: TDataSet); override;
  end;

  TMySQLTimeStampField = class(TSQLTimeStampField)
  protected
    SQLFormat: string;
    function GetAsSQLTimeStamp(): TSQLTimeStamp; override;
    function GetAsString(): string; override;
    function GetAsVariant(): Variant; override;
    function GetDataSize(): Integer; override;
    function GetIsNull(): Boolean; override;
    function GetOldValue(): Variant;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
    procedure SetAsSQLTimeStamp(const Value: TSQLTimeStamp); override;
    procedure SetAsString(const Value: string); override;
    procedure SetAsVariant(const Value: Variant); override;
  public
    procedure SetDataSet(ADataSet: TDataSet); override;
    property Value: Variant read GetAsVariant write SetAsVariant;
  end;

  TMySQLWideMemoField = class(TWideMemoField)
  public
    function GetAsString(): string; override;
    function GetAsVariant: Variant; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
    procedure SetAsString(const Value: string); override;
  end;

  TMySQLWideStringField = class(TWideStringField)
  protected
    function GetAsDateTime(): TDateTime; override;
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
    procedure SetAsDateTime(Value: TDateTime); override;
  end;

  TMySQLWordField = class(TWordField)
  protected
    function GetAsString(): string; override;
    function GetIsNull(): Boolean; override;
    procedure GetText(var Text: string; DisplayText: Boolean); override;
  end;

  TMySQLSyncThreads = class(TList)
  strict private
    CriticalSection: TCriticalSection;
    function ThreadByIndex(Index: Integer): TMySQLConnection.TSyncThread; inline;
  public
    function Add(Item: Pointer): Integer;
    constructor Create();
    procedure Delete(Index: Integer);
    destructor Destroy(); override;
    procedure Lock();
    procedure Release();
    function ThreadByThreadId(const ThreadID: TThreadID): TMySQLConnection.TSyncThread;
    property Threads[Index: Integer]: TMySQLConnection.TSyncThread read ThreadByIndex; default;
  end;

function BitField(const Field: TField): Boolean;
function FieldCodePage(const Field: TField): Cardinal; inline;
function DateTimeToStr(const DateTime: TDateTime; const FormatSettings: TFormatSettings): string; overload;
function DateToStr(const Date: TDateTime; const FormatSettings: TFormatSettings): string; overload;
function ExecutionTimeToStr(const Time: TDateTime; const Digits: Byte = 2): string;
function GetZeroDateString(const FormatSettings: TFormatSettings): string;
function GeometryField(const Field: TField): Boolean;
procedure MySQLConnectionSynchronize(const Data: Pointer; const Tag: NativeInt);
function StrToDate(const S: string; const FormatSettings: TFormatSettings): TDateTime; overload;
function StrToDateTime(const S: string; const FormatSettings: TFormatSettings): TDateTime; overload;
function SQLFormatToDisplayFormat(const SQLFormat: string): string;
function AnsiCharToWideChar(const CodePage: UINT; const lpMultiByteStr: LPCSTR; const cchMultiByte: Integer; const lpWideCharStr: LPWSTR; const cchWideChar: Integer): Integer;
function WideCharToAnsiChar(const CodePage: UINT; const lpWideCharStr: LPWSTR; const cchWideChar: Integer; const lpMultiByteStr: LPSTR; const cchMultiByte: Integer): Integer;

const
  DS_ASYNCHRON     = -1;
  DS_MIN_ERROR     = 2300;
  DS_SERVER_OLD    = 2300;
  DS_OUT_OF_MEMORY = 2301;

  deSortChanged = TDataEvent(Ord(High(TDataEvent)) + 1);
  deCommitted = TDataEvent(Ord(High(TDataEvent)) + 2);

  NotQuotedDataTypes = [ftShortInt, ftByte, ftSmallInt, ftWord, ftInteger, ftLongWord, ftLargeint, ftSingle, ftFloat, ftExtended];
  BinaryDataTypes = [ftString, ftBlob];
  TextDataTypes = [ftWideString, ftWideMemo];
  RightAlignedDataTypes = [ftShortInt, ftByte, ftSmallInt, ftWord, ftInteger, ftLongWord, ftLargeint, ftSingle, ftFloat, ftExtended];

  MySQLZeroDate = -693593;

  ftAscSortedField  = $010000;
  ftDescSortedField = $020000;
  ftSortedField     = $030000;
  ftBitField        = $040000;
  ftGeometryField   = $080000;
  ftTimestampField  = $100000;
  ftDateTimeField   = $200000;

var
  LocaleFormatSettings: TFormatSettings;
  MySQLConnectionOnSynchronize: TMySQLConnection.TSynchronizeEvent;

implementation {***************************************************************}

uses
  Variants, RTLConsts, SysConst, Math, StrUtils, AnsiStrings,
  DBConsts,
  Forms, Consts,
  {$IFDEF EurekaLog}
  ExceptionLog7, EExceptionManager,
  {$ENDIF}
  MySQLClient,
  SQLUtils, CSVUtils, HTTPTunnel;

resourcestring
  SLibraryNotAvailable = 'Library can not be loaded ("%s")';
  SNoUpdate = 'Nothing to update';

const
  DATASET_ERRORS: array [0..1] of PChar = (
    'Require MySQL Server 3.23.20 or higher',                                   {0}
    'DataSet run out of memory');                                               {1}

const
  // Field mappings needed for filtering. (What field type should be compared with what internal type?)
  FldTypeMap: TFieldMap = (
    { ftUnknown          }  Ord(ftUnknown),
    { ftString           }  Ord(ftString),
    { ftSmallInt         }  Ord(ftSmallInt),
    { ftInteger          }  Ord(ftInteger),
    { ftWord             }  Ord(ftWord),
    { ftBoolean          }  Ord(ftBoolean),
    { ftFloat            }  Ord(ftFloat),
    { ftCurrency         }  Ord(ftFloat),
    { ftBCD              }  Ord(ftBCD),
    { ftDate             }  Ord(ftDate),
    { ftTime             }  Ord(ftTime),
    { ftDateTime         }  Ord(ftDateTime),
    { ftBytes            }  Ord(ftBytes),
    { ftVarBytes         }  Ord(ftVarBytes),
    { ftAutoInc          }  Ord(ftInteger),
    { fBlob              }  Ord(ftBlob),
    { ftMemo             }  Ord(ftBlob),
    { ftGraphic          }  Ord(ftBlob),
    { ftFmtMemo          }  Ord(ftBlob),
    { ftParadoxOle       }  Ord(ftBlob),
    { ftDBaseOle         }  Ord(ftBlob),
    { ftTypedBinary      }  Ord(ftBlob),
    { ftCursor           }  Ord(ftUnknown),
    { ftFixedChar        }  Ord(ftString),
    { ftWideString       }  Ord(ftWideString),
    { ftLargeInt         }  Ord(ftLargeInt),
    { ftADT              }  Ord(ftADT),
    { ftArray            }  Ord(ftArray),
    { ftReference        }  Ord(ftUnknown),
    { ftDataset          }  Ord(ftUnknown),
    { ftOraBlob          }  Ord(ftBlob),
    { ftOraClob          }  Ord(ftBlob),
    { ftVariant          }  Ord(ftUnknown),
    { ftInterface        }  Ord(ftUnknown),
    { ftIDispatch        }  Ord(ftUnknown),
    { ftGUID             }  Ord(ftGUID),
    { ftTimeStamp        }  Ord(ftTimeStamp),
    { ftFmtBCD           }  Ord(ftFmtBCD),
    { ftFixedWideChar    }  Ord(ftFixedWideChar),
    { ftWideMemo         }  Ord(ftWideMemo),
    { ftOraTimeStamp     }  Ord(ftOraTimeStamp),
    { ftOraInterval      }  Ord(ftOraInterval),
    { ftLongWord         }  Ord(ftLongWord),
    { ftShortint         }  Ord(ftShortint),
    { ftByte             }  Ord(ftByte),
    { ftExtended         }  Ord(ftExtended),
    { ftConnection       }  Ord(ftConnection),
    { ftParams           }  Ord(ftParams),
    { ftStream           }  Ord(ftStream),
    { ftTimeStampOffset  }  Ord(ftTimeStampOffset),
    { ftObject           }  Ord(ftObject),
    { ftSingle           }  Ord(ftSingle)
  );

type
  TMySQLQueryBlobStream = class(TMemoryStream)
  public
    constructor Create(const AField: TBlobField);
  end;

  TMySQLQueryMemoStream = TMySQLQueryBlobStream;

  TMySQLDataSetBlobStream = class(TMemoryStream)
  strict private
    Empty: Boolean;
    Field: TBlobField;
    Mode: TBlobStreamMode;
  public
    constructor Create(const AField: TBlobField; AMode: TBlobStreamMode);
    destructor Destroy; override;
    function Write(const Buffer: TBytes; Offset, Count: Longint): Longint; override;
  end;

var
  DataSetNumber: Integer;
  MySQLDataSets: TList<TMySQLDataSet>;
  MySQLLibraries: array of TMySQLLibrary;
  MySQLSyncThreads: TMySQLSyncThreads; // ... should be in implementation

{******************************************************************************}

function BitField(const Field: TField): Boolean;
begin
  Result := Assigned(Field) and (Field.Tag and ftBitField <> 0);
end;

function ConnectionLost(const ErrorCode: Integer): Boolean; inline;
begin
  Result := (ErrorCode = CR_UNKNOWN_ERROR)
    or (ErrorCode = CR_IPSOCK_ERROR)
    or (ErrorCode = CR_SERVER_GONE_ERROR)
    or (ErrorCode = CR_SERVER_HANDSHAKE_ERR)
    or (ErrorCode = CR_SERVER_LOST)
    or (ErrorCode = CR_COMMANDS_OUT_OF_SYNC);
end;

function FieldCodePage(const Field: TField): Cardinal;
begin
  Result := Field.Tag and $FFFF;
end;

function DateTimeToStr(const DateTime: TDateTime;
  const FormatSettings: TFormatSettings): string; overload;
begin
  if (Trunc(DateTime) <= MySQLZeroDate) then
    Result := GetZeroDateString(FormatSettings) + ' ' + TimeToStr(DateTime, FormatSettings)
  else
    Result := SysUtils.DateTimeToStr(DateTime, FormatSettings);
end;

function DateToStr(const Date: TDateTime;
  const FormatSettings: TFormatSettings): string; overload;
begin
  if (Trunc(Date) <= MySQLZeroDate) then
    Result := GetZeroDateString(FormatSettings)
  else
    Result := SysUtils.DateToStr(Date, FormatSettings);
end;

function DisplayFormatToSQLFormat(const DateTimeFormat: string): string;
var
  Index: Integer;
begin
  Result := DateTimeFormat;

  while (Pos('mm', Result) > 0) do
  begin
    Index := Pos('mm', Result);
    Result[Index] := '%';
    if ((Index > 1) and (Result[Index - 1] = 'h')) then
      Result[Index + 1] := 'i'
    else
      Result[Index + 1] := 'm';
  end;

  Result := ReplaceStr(Result, 'yyyy', '%Y');
  Result := ReplaceStr(Result, 'yy', '%y');
  Result := ReplaceStr(Result, 'MM', '%m');
  Result := ReplaceStr(Result, 'dd', '%d');
  Result := ReplaceStr(Result, 'hh', '%H');
  Result := ReplaceStr(Result, 'ss', '%s');
end;

function ExecutionTimeToStr(const Time: TDateTime; const Digits: Byte = 2): string;
var
  Hour: Word;
  Minute: Word;
  MSec: Word;
  Second: Word;
begin
  if (Time >= 1) then
    Result := IntToStr(Trunc(Time)) + ' days'
  else
  begin
    DecodeTime(Time, Hour, Minute, Second, MSec);
    if (Time < 0) then
      Result := '???'
    else if ((Hour > 0) or (Minute > 0)) then
      Result := TimeToStr(Time, LocaleFormatSettings)
    else
      Result := Format('%2.' + IntToStr(Digits) + 'f', [Second + MSec / 1000]);
  end;
end;

procedure FreeMySQLLibraries();
var
  I: Integer;
begin
  for I := 0 to Length(MySQLLibraries) - 1 do
    MySQLLibraries[I].Free();
  SetLength(MySQLLibraries, 0);
end;

function GeometryField(const Field: TField): Boolean;
begin
  Result := Assigned(Field) and (Field.Tag and ftGeometryField <> 0);
end;

function GetZeroDateString(const FormatSettings: TFormatSettings): string;
begin
  Result := FormatSettings.ShortDateFormat;
  Result := ReplaceStr(Result, 'Y', '0');
  Result := ReplaceStr(Result, 'y', '0');
  Result := ReplaceStr(Result, 'M', '0');
  Result := ReplaceStr(Result, 'm', '0');
  Result := ReplaceStr(Result, 'D', '0');
  Result := ReplaceStr(Result, 'd', '0');
  Result := ReplaceStr(Result, 'e', '0');
  Result := ReplaceStr(Result, '/', FormatSettings.DateSeparator);
end;

function LibDecode(const CodePage: Cardinal; const Text: my_char; const Length: my_int = -1): string;
label
  StringL;
var
  Len: Integer;
begin
  if (not Assigned(Text) or (Length = 0)) then
    Result := ''
  else
  begin
    if (Length >= 0) then
      Len := Length
    else
      Len := lstrlenA(Text);
    SetLength(Result, AnsiCharToWideChar(CodePage, Text, Len, nil, 0));
    if (Len > 0) then
      SetLength(Result, AnsiCharToWideChar(CodePage, Text, Len, PChar(Result), System.Length(Result)));
  end;
end;

function LibEncode(const CodePage: Cardinal; const Value: string): RawByteString;
var
  Len: Integer;
begin
  Len := WideCharToAnsiChar(CodePage, PChar(Value), Length(Value), nil, 0);
  SetLength(Result, Len);
  WideCharToAnsiChar(CodePage, PChar(Value), Length(Value), PAnsiChar(Result), Len);
end;

function LibPack(const Value: string): RawByteString;
label
  StringL;
var
  Len: Integer;
begin
  if (Value = '') then
    Result := ''
  else
  begin
    Len := Length(Value);
    SetLength(Result, Len);
    asm
        PUSH ES
        PUSH ESI
        PUSH EDI

        PUSH DS                          // string operations uses ES
        POP ES
        CLD                              // string operations uses forward direction

        MOV ESI,PChar(Value)             // Copy characters from Value
        MOV EAX,Result                   //   to Result
        MOV EDI,[EAX]

        MOV ECX,Len
      StringL:
        LODSW                            // Load WideChar from Value
        STOSB                            // Store AnsiChar into Result
        LOOP StringL                     // Repeat for all characters

        POP EDI
        POP ESI
        POP ES
    end;
  end;
end;

function LibUnpack(const Data: my_char; const Length: my_int = -1): string;
label
  StringL;
var
  Len: Integer;
begin
  if (Length = -1) then
    Len := lstrlenA(Data)
  else
    Len := Length;
  if (not Assigned(Data) or (Len = 0)) then
    Result := ''
  else
  begin
    SetLength(Result, Len);
    asm
        PUSH ES
        PUSH ESI
        PUSH EDI

        PUSH DS                          // string operations uses ES
        POP ES
        CLD                              // string operations uses forward direction

        MOV ESI,Data                     // Copy characters from Data
        MOV EAX,Result                   //   to Result
        MOV EDI,[EAX]
        MOV ECX,Len                      // Length of Data

        MOV AH,0                         // Clear AH, since AL will be load but AX stored
      StringL:
        LODSB                            // Load AnsiChar from Data
        STOSW                            // Store WideChar into S
        LOOP StringL                     // Repeat for all characters

        POP EDI
        POP ESI
        POP ES
    end;
  end;
end;

function LoadMySQLLibrary(const ALibraryType: TMySQLLibrary.TLibraryType; const AFileName: TFileName): TMySQLLibrary;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Length(MySQLLibraries) - 1 do
    if ((MySQLLibraries[I].LibraryType = ALibraryType) and (MySQLLibraries[I].FileName = AFileName)) then
      Result := MySQLLibraries[I];

  if (not Assigned(Result)) then
  begin
    Result := TMySQLLibrary.Create(ALibraryType, AFileName);
    if (Result.Version = 0) then
      FreeAndNil(Result);

    if (Assigned(Result)) then
    begin
      SetLength(MySQLLibraries, Length(MySQLLibraries) + 1);
      MySQLLibraries[Length(MySQLLibraries) - 1] := Result;
    end;
  end;
end;

procedure MySQLConnectionSynchronize(const Data: Pointer; const Tag: NativeInt);
var
  DataSet: TMySQLDataSet;
  SyncThread: TMySQLConnection.TSyncThread;
begin
  case (Tag) of
    0:
      begin
        SyncThread := TMySQLConnection.TSyncThread(Data);

        if (MySQLSyncThreads.IndexOf(SyncThread) >= 0) then
          SyncThread.Connection.Sync(SyncThread);
      end;
    1:
      begin
        DataSet := TMySQLDataSet(Data);

        if (MySQLDataSets.IndexOf(DataSet) >= 0) then
          DataSet.Resync([]);
      end;
    else raise ERangeError.Create('Tag: ' + IntToStr(Tag));
  end;
end;

function MySQLTimeStampToStr(const SQLTimeStamp: TSQLTimeStamp; const DisplayFormat: string): string;
var
  I: Integer;
begin
  Result := LowerCase(DisplayFormat);

  for I := Length(DisplayFormat) - 1 downto 0 do
  begin
    if (DisplayFormat[I] = 'c') then
    begin
      Delete(Result, I, 1);
      Insert(FormatSettings.ShortDateFormat, Result, I);
    end;
    if (Copy(DisplayFormat, I, 2) = 'tt') then
    begin
      Delete(Result, I, 1);
      Insert(FormatSettings.LongTimeFormat, Result, I);
    end;
    if (DisplayFormat[I] = 't') then
    begin
      Delete(Result, I, 1);
      Insert(FormatSettings.ShortTimeFormat, Result, I);
    end;
    if (DisplayFormat[I] = '/') then
    begin
      Delete(Result, I, 1);
      Insert(FormatSettings.DateSeparator, Result, I);
    end;
    if (DisplayFormat[I] = ':') then
    begin
      Delete(Result, I, 1);
      Insert(FormatSettings.TimeSeparator, Result, I);
    end;
  end;

  for I := Length(Result) downto 1 do
    if (Result[I] = 'm') then
      if ((I > 1) and (Result[I - 1] = 'm')) then
      else if (((I > 1) and (Result[I - 1] = 'h')) or ((I > 2) and (Result[I - 1] = FormatSettings.TimeSeparator) and (Result[I - 2] = 'h'))) then
        if ((I < Length(Result)) and (Result[I + 1] = 'm')) then
          begin Delete(Result, I, 2); Insert(ReplaceStr(Format('%2d', [SQLTimeStamp.Minute]), ' ', '0'), Result, I); end
        else
          begin Delete(Result, I, 1); Insert(IntToStr(SQLTimeStamp.Minute), Result, I); end;

  while (Pos('yyyy', Result) > 0) do
    Result := ReplaceStr(Result, 'yyyy', ReplaceStr(Format('%4d', [SQLTimeStamp.Year]), ' ', '0'));
  while (Pos('yy', Result) > 0) do
    Result := ReplaceStr(Result, 'yy', ReplaceStr(Format('%2d', [SQLTimeStamp.Year mod 100]), ' ', '0'));
  while (Pos('mm', Result) > 0) do
    Result := ReplaceStr(Result, 'mm', ReplaceStr(Format('%2d', [SQLTimeStamp.Month]), ' ', '0'));
  while (Pos('dd', Result) > 0) do
    Result := ReplaceStr(Result, 'dd', ReplaceStr(Format('%2d', [SQLTimeStamp.Day]), ' ', '0'));
  while (Pos('d', Result) > 0) do
    Result := ReplaceStr(Result, 'd', IntToStr(SQLTimeStamp.Day));
  while (Pos('hh', Result) > 0) do
    Result := ReplaceStr(Result, 'hh', ReplaceStr(Format('%2d', [SQLTimeStamp.Hour]), ' ', '0'));
  while (Pos('h', Result) > 0) do
    Result := ReplaceStr(Result, 'h', IntToStr(SQLTimeStamp.Hour));
  while (Pos('ss', Result) > 0) do
    Result := ReplaceStr(Result, 'ss', ReplaceStr(Format('%2d', [SQLTimeStamp.Second]), ' ', '0'));
  while (Pos('s', Result) > 0) do
    Result := ReplaceStr(Result, 's', IntToStr(SQLTimeStamp.Second));
end;

function StrToDate(const S: string;
  const FormatSettings: TFormatSettings): TDateTime; overload;
begin
  if (S = GetZeroDateString(FormatSettings)) then
    Result := MySQLZeroDate
  else
    Result := SysUtils.StrToDate(S, FormatSettings);
end;

function StrToDateTime(const S: string;
  const FormatSettings: TFormatSettings): TDateTime;
var
  ZeroDateString: string;
begin
  ZeroDateString := GetZeroDateString(FormatSettings);

  if (Copy(S, 1, Length(ZeroDateString)) = ZeroDateString) then
    Result := MySQLZeroDate - StrToTime(Copy(S, Length(ZeroDateString) + 1, Length(S) - Length(ZeroDateString)), FormatSettings)
  else
    Result := SysUtils.StrToDateTime(S, FormatSettings);
end;

function StrToMySQLTimeStamp(const Str: string; const SQLFormat: string): TSQLTimeStamp;
var
  I: Integer;
  Pos: Integer;
  SQLTimeStamp: TSQLTimeStamp;
begin
  SQLTimeStamp := NullSQLTimeStamp;

  I := 0; Pos := 1;
  while ((Pos <= Length(Str)) and (I < Length(SQLFormat) - 1)) do
  begin
    if (SQLFormat[I + 1] <> '%') then
      Inc(Pos, 1)
    else
    begin
      case (SQLFormat[I + 2]) of
        'Y': begin SQLTimeStamp.Year := StrToInt(Copy(Str, Pos, 4)); Inc(Pos, 4); end;
        'y': begin
               SQLTimeStamp.Year := StrToInt(Copy(Str, Pos, 2)); Inc(Pos, 2);
               if (SQLTimeStamp.Year <= 69) then
                 Inc(SQLTimeStamp.Year, 2000)
               else
                 Inc(SQLTimeStamp.Year, 1900);
             end;
        'm': begin SQLTimeStamp.Month := StrToInt(Copy(Str, Pos, 2)); Inc(Pos, 2); end;
        'd': begin SQLTimeStamp.Day := StrToInt(Copy(Str, Pos, 2)); Inc(Pos, 2); end;
        'H': begin SQLTimeStamp.Hour := StrToInt(Copy(Str, Pos, 2)); Inc(Pos, 2); end;
        'i': begin SQLTimeStamp.Minute := StrToInt(Copy(Str, Pos, 2)); Inc(Pos, 2); end;
        's': begin SQLTimeStamp.Second := StrToInt(Copy(Str, Pos, 2)); Inc(Pos, 2); end;
        else raise EConvertError.CreateFMT(SConvUnknownType, [SQLFormat[I + 2]]);
      end;
      Inc(I);
    end;
    Inc(I);
  end;

  Result := SQLTimeStamp;
end;

function StrToTime(const S, SQLFormat: string): Integer; overload;
var
  B: Byte;
  DisplayFormat: string;
  L: Byte;
  Str: string;
begin
  Result := 0;
  Str := S;
  if (S[1] = '-') then Delete(Str, 1, 1);

  DisplayFormat := SQLFormatToDisplayFormat(SQLFormat);
  DisplayFormat := ReplaceStr(DisplayFormat, 'hh', StringOfChar('h', Length(Str) - Length(DisplayFormat) + 2));

  if (Pos('ss', DisplayFormat) > 0) then
  begin
    B := StrToInt(Copy(Str, Pos('ss', DisplayFormat), 2));
    if (B >= 60) then
      raise EConvertError.CreateFmt(SInvalidTime, [S]);
    Result := Result + B;
  end;
  if (Pos('mm', DisplayFormat) > 0) then
  begin
    B := StrToInt(Copy(Str, Pos('mm', DisplayFormat), 2));
    if (B >= 60) then
      raise EConvertError.CreateFmt(SInvalidTime, [S]);
    Result := Result + B * 60;
  end;
  if (Pos('hh', DisplayFormat) > 0) then
  begin
    L := 2;
    while (DisplayFormat[Pos('hh', DisplayFormat) + L] = 'h') do Inc(L);
    Result := Result + StrToInt(Copy(Str, Pos('hh', DisplayFormat), L)) * 3600;
  end;
  if (S[1] = '-') then
    Result := - Result;

  if ((Result <= -3020400) or (3020400 <= Result))  then
    raise EConvertError.CreateFmt(SInvalidTime, [S]);
end;

function SQLFormatToDisplayFormat(const SQLFormat: string): string;
begin
  Result := SQLFormat;
  Result := ReplaceStr(Result, '%Y', 'yyyy');
  Result := ReplaceStr(Result, '%y', 'yy');
  Result := ReplaceStr(Result, '%M', 'mmmm');
  Result := ReplaceStr(Result, '%m', 'mm');
  Result := ReplaceStr(Result, '%c', 'm');
  Result := ReplaceStr(Result, '%D', 'dddd');
  Result := ReplaceStr(Result, '%d', 'dd');
  Result := ReplaceStr(Result, '%e', 'd');
  Result := ReplaceStr(Result, '%h', 'h');
  Result := ReplaceStr(Result, '%H', 'hh');
  Result := ReplaceStr(Result, '%p', 'x');
  Result := ReplaceStr(Result, '%i', 'mm');
  Result := ReplaceStr(Result, '%k', 'hh');
  Result := ReplaceStr(Result, '%l', 'n');
  Result := ReplaceStr(Result, '%S', 'ss');
  Result := ReplaceStr(Result, '%s', 'ss');
end;

function TimeToStr(const Time: Integer; const SQLFormat: string): string; overload;
var
  S: string;
  T: Integer;
begin
  T := Time;

  Result := SQLFormatToDisplayFormat(SQLFormat);

  if (T < 0) then
  begin
    T := -T;
    Result := ReplaceStr(Result, 'hh', '-hh');
  end;

  S := IntToStr(T mod 60); if (Length(S) = 1) then S := '0' + S; Result := ReplaceStr(Result, 'ss', S); T := T div 60;
  S := IntToStr(T mod 60); if (Length(S) = 1) then S := '0' + S; Result := ReplaceStr(Result, 'mm', S); T := T div 60;
  S := IntToStr(T       ); if (Length(S) = 1) then S := '0' + S; Result := ReplaceStr(Result, 'hh', S);
end;

function AnsiCharToWideChar(const CodePage: UINT; const lpMultiByteStr: LPCSTR; const cchMultiByte: Integer; const lpWideCharStr: LPWSTR; const cchWideChar: Integer): Integer;
var
  Hex: string;
  Length: Integer;
  Text: TBytes;
begin
  if (not Assigned(lpMultiByteStr) or (cchMultiByte = 0)) then
    Result := 0
  else
  begin
    Result := MultiByteToWideChar(CodePage, MB_ERR_INVALID_CHARS, lpMultiByteStr, cchMultiByte, lpWideCharStr, cchWideChar);
    if (Result = 0) then
    begin
      Length := cchMultiByte - 1;
      while ((Length > 0) and (MultiByteToWideChar(CodePage, MB_ERR_INVALID_CHARS, lpMultiByteStr, Length, nil, 0) = 0)) do
        Dec(Length);
      SetLength(Text, cchMultiByte);
      BinToHex(BytesOf(lpMultiByteStr, cchMultiByte), 0, Text, 0, cchMultiByte);
      Hex := '0x' + string(AnsiStrings.StrPas(PAnsiChar(@Text[0])));
      raise EMySQLEncodingError.CreateFMT('#%d %s (CodePage: %d, Hex: %s, Index: %d)', [GetLastError(), SysErrorMessage(GetLastError()), CodePage, Hex, Length]);
    end;
  end;
end;

function WideCharToAnsiChar(const CodePage: UINT; const lpWideCharStr: LPWSTR; const cchWideChar: Integer; const lpMultiByteStr: LPSTR; const cchMultiByte: Integer): Integer;
var
  Flags: DWord;
begin
  if (not Assigned(lpWideCharStr) or (cchWideChar = 0)) then
    Result := 0
  else
  begin
    if ((CodePage <> CP_UTF8) or not CheckWin32Version(6)) then Flags := 0 else Flags := WC_ERR_INVALID_CHARS;
    Result := WideCharToMultiByte(CodePage, Flags, lpWideCharStr, cchWideChar, lpMultiByteStr, cchMultiByte, nil, nil);
    if (Result = 0) then
      raise EOSError.CreateFmt('System Error.  Code: %d.' + #13#10 + '%s' + ' in %s (CodePage: %d)', [GetLastError(), SysErrorMessage(GetLastError()), '"' + StrPas(lpWideCharStr) + '"', CodePage]);
  end;
end;

function SwapUInt64(I: UInt64): UInt64; register; // swap byte order
asm
  MOV   EAX,DWORD [I]
  BSWAP EAX
  MOV   DWORD [Result + 4],EAX
  MOV   EAX,DWORD [I + 4]
  BSWAP EAX
  MOV   DWORD [Result],EAX
end;

{ Callback functions **********************************************************}

procedure local_infile_end(local_infile: TMySQLConnection.Plocal_infile); cdecl;
begin
  local_infile^.Connection.local_infile_end(local_infile);
end;

function local_infile_error(local_infile: TMySQLConnection.Plocal_infile; error_msg: my_char; error_msg_len: my_uint): my_int; cdecl;
begin
  Result := local_infile^.Connection.local_infile_error(local_infile, error_msg, error_msg_len);
end;

function local_infile_init(out local_infile: TMySQLConnection.Plocal_infile; filename: my_char; userdata: Pointer): my_int; cdecl;
begin
  Result := TMySQLConnection(userdata).local_infile_init(local_infile, filename);
end;

function local_infile_read(local_infile: TMySQLConnection.Plocal_infile; buf: my_char; buf_len: my_uint): my_int; cdecl;
begin
  Result := local_infile^.Connection.local_infile_read(local_infile, buf, buf_len);
end;

function TMySQLLibrary.GetVersionStr(): string;
begin
  Result := string(mysql_get_client_info());
end;

{ TMySQLLibrary ***************************************************************}

constructor TMySQLLibrary.Create(const ALibraryType: TLibraryType; const AFilename: TFileName);
var
  Code: Integer;
  S: string;
begin
  inherited Create();

  FHandle := 0;
  FLibraryType := ALibraryType;
  FFilename := AFilename;

  if (LibraryType = ltDLL) then
  begin
    Assert(FFilename <> '');

    FHandle := LoadLibrary(PChar(FFilename));

    if (Handle > 0) then
    begin
      my_init := GetProcAddress(Handle, 'my_init');
      mysql_affected_rows := GetProcAddress(Handle, 'mysql_affected_rows');
      mysql_character_set_name := GetProcAddress(Handle, 'mysql_character_set_name');
      mysql_close := GetProcAddress(Handle, 'mysql_close');
      mysql_errno := GetProcAddress(Handle, 'mysql_errno');
      mysql_error := GetProcAddress(Handle, 'mysql_error');
      mysql_fetch_field := GetProcAddress(Handle, 'mysql_fetch_field');
      mysql_fetch_fields := GetProcAddress(Handle, 'mysql_fetch_fields');
      mysql_fetch_field_direct := GetProcAddress(Handle, 'mysql_fetch_field_direct');
      mysql_fetch_lengths := GetProcAddress(Handle, 'mysql_fetch_lengths');
      mysql_fetch_row := GetProcAddress(Handle, 'mysql_fetch_row');
      mysql_field_count := GetProcAddress(Handle, 'mysql_field_count');
      mysql_free_result := GetProcAddress(Handle, 'mysql_free_result');
      mysql_get_client_info := GetProcAddress(Handle, 'mysql_get_client_info');
      mysql_get_client_version := GetProcAddress(Handle, 'mysql_get_client_version');
      mysql_get_host_info := GetProcAddress(Handle, 'mysql_get_host_info');
      mysql_get_server_info := GetProcAddress(Handle, 'mysql_get_server_info');
      mysql_get_server_version := GetProcAddress(Handle, 'mysql_get_server_version');
      mysql_info := GetProcAddress(Handle, 'mysql_info');
      mysql_init := GetProcAddress(Handle, 'mysql_init');
      mysql_insert_id := GetProcAddress(Handle, 'mysql_insert_id');
      mysql_more_results := GetProcAddress(Handle, 'mysql_more_results');
      mysql_next_result := GetProcAddress(Handle, 'mysql_next_result');
      mysql_library_end := GetProcAddress(Handle, 'mysql_library_end');
      mysql_library_init := GetProcAddress(Handle, 'mysql_library_init');
      mysql_num_fields := GetProcAddress(Handle, 'mysql_num_fields');
      mysql_num_rows := GetProcAddress(Handle, 'mysql_num_rows');
      mysql_options := GetProcAddress(Handle, 'mysql_options');
      mysql_ping := GetProcAddress(Handle, 'mysql_ping');
      mysql_real_connect := GetProcAddress(Handle, 'mysql_real_connect');
      mysql_real_escape_string := GetProcAddress(Handle, 'mysql_real_escape_string');
      mysql_real_query := GetProcAddress(Handle, 'mysql_real_query');
      mysql_session_track_get_first := GetProcAddress(Handle, 'mysql_session_track_get_first');
      mysql_session_track_get_next := GetProcAddress(Handle, 'mysql_session_track_get_next');
      mysql_set_character_set := GetProcAddress(Handle, 'mysql_set_character_set');
      mysql_set_local_infile_default := GetProcAddress(Handle, 'mysql_set_local_infile_default');
      mysql_set_local_infile_handler := GetProcAddress(Handle, 'mysql_set_local_infile_handler');
      mysql_set_server_option := GetProcAddress(Handle, 'mysql_set_server_option');
      mysql_shutdown := GetProcAddress(Handle, 'mysql_shutdown');
      mysql_store_result := GetProcAddress(Handle, 'mysql_store_result');
      mysql_thread_end := GetProcAddress(Handle, 'mysql_thread_end');
      mysql_thread_id := GetProcAddress(Handle, 'mysql_thread_id');
      mysql_thread_init := GetProcAddress(Handle, 'mysql_thread_init');
      mysql_thread_save := GetProcAddress(Handle, 'mysql_thread_save');
      mysql_use_result := GetProcAddress(Handle, 'mysql_use_result');
      mysql_warning_count := GetProcAddress(Handle, 'mysql_warning_count');
    end;
  end
  else
  begin
    my_init := nil;
    mysql_affected_rows := @MySQLClient.mysql_affected_rows;
    mysql_character_set_name := @MySQLClient.mysql_character_set_name;
    mysql_close := @MySQLClient.mysql_close;
    mysql_errno := @MySQLClient.mysql_errno;
    mysql_error := @MySQLClient.mysql_error;
    mysql_fetch_field := @MySQLClient.mysql_fetch_field;
    mysql_fetch_fields := @MySQLClient.mysql_fetch_fields;
    mysql_fetch_field_direct := @MySQLClient.mysql_fetch_field_direct;
    mysql_fetch_lengths := @MySQLClient.mysql_fetch_lengths;
    mysql_fetch_row := @MySQLClient.mysql_fetch_row;
    mysql_field_count := @MySQLClient.mysql_field_count;
    mysql_free_result := @MySQLClient.mysql_free_result;
    mysql_get_client_info := @MySQLClient.mysql_get_client_info;
    mysql_get_client_version := @MySQLClient.mysql_get_client_version;
    mysql_get_host_info := @MySQLClient.mysql_get_host_info;
    mysql_get_server_info := @MySQLClient.mysql_get_server_info;
    mysql_get_server_version := @MySQLClient.mysql_get_server_version;
    mysql_info := @MySQLClient.mysql_info;
    if (LibraryType <> ltHTTP) then
      mysql_init := @MySQLClient.mysql_init
    else
      mysql_init := @HTTPTunnel.mysql_init;
    mysql_insert_id := @MySQLClient.mysql_insert_id;
    mysql_more_results := @MySQLClient.mysql_more_results;
    mysql_next_result := @MySQLClient.mysql_next_result;
    mysql_library_end := nil;
    mysql_library_init := nil;
    mysql_num_fields := @MySQLClient.mysql_num_fields;
    mysql_num_rows := @MySQLClient.mysql_num_rows;
    mysql_options := @MySQLClient.mysql_options;
    mysql_ping := @MySQLClient.mysql_ping;
    mysql_real_connect := @MySQLClient.mysql_real_connect;
    mysql_real_escape_string := @MySQLClient.mysql_real_escape_string;
    mysql_real_query := @MySQLClient.mysql_real_query;
    mysql_session_track_get_first := @MySQLClient.mysql_session_track_get_first;
    mysql_session_track_get_next := @MySQLClient.mysql_session_track_get_next;
    mysql_set_character_set := @MySQLClient.mysql_set_character_set;
    mysql_set_local_infile_default := @MySQLClient.mysql_set_local_infile_default;
    mysql_set_local_infile_handler := @MySQLClient.mysql_set_local_infile_handler;
    mysql_set_server_option := @MySQLClient.mysql_set_server_option;
    if (LibraryType <> ltHTTP) then
      mysql_shutdown := @MySQLClient.mysql_shutdown
    else
      mysql_shutdown := nil;
    mysql_store_result := @MySQLClient.mysql_store_result;
    mysql_thread_end := nil;
    mysql_thread_id := @MySQLClient.mysql_thread_id;
    mysql_thread_init := nil;
    mysql_thread_save := nil;
    mysql_use_result := @MySQLClient.mysql_use_result;
    mysql_warning_count := @MySQLClient.mysql_warning_count;
  end;

  if (Assigned(mysql_library_init)) then
    mysql_library_init(0, nil, nil);

  if (Assigned(mysql_get_client_version)) then
    FVersion := mysql_get_client_version()
  else if (Assigned(mysql_get_client_info)) then
  begin
    S := string(mysql_get_client_info());
    if (Pos('-', S) > 0) then
      S := Copy(S, 1, Pos('-', S) - 1);
    if (S[2] = '.') and (S[4] = '.') then
      Insert('0', S, 3);
    if (S[2] = '.') and (Length(S) = 6) then
      Insert('0', S, 6);
    Val(StringReplace(S, '.', '', [rfReplaceAll	]), FVersion, Code);
  end;
end;

destructor TMySQLLibrary.Destroy();
begin
  if (Assigned(mysql_library_end)) then
    mysql_library_end();
  if (Handle > 0) then
    FreeLibrary(Handle);

  inherited;
end;

procedure TMySQLLibrary.SetField(const RawField: MYSQL_FIELD; out Field: TMYSQL_FIELD);
begin
  ZeroMemory(@Field, SizeOf(Field));

  if (Version >= 40101) then
  begin
    Field.name := MYSQL_FIELD_40101(RawField)^.name;
    Field.org_name := MYSQL_FIELD_40101(RawField)^.org_name;
    Field.table := MYSQL_FIELD_40101(RawField)^.table;
    Field.org_table := MYSQL_FIELD_40101(RawField)^.org_table;
    Field.db := MYSQL_FIELD_40101(RawField)^.db;
    Field.catalog := MYSQL_FIELD_40101(RawField)^.catalog;
    Field.def := MYSQL_FIELD_40101(RawField)^.def;
    Field.length := MYSQL_FIELD_40101(RawField)^.length;
    Field.max_length := MYSQL_FIELD_40101(RawField)^.max_length;
    Field.name_length := MYSQL_FIELD_40101(RawField)^.name_length;
    Field.org_name_length := MYSQL_FIELD_40101(RawField)^.org_name_length;
    Field.table_length := MYSQL_FIELD_40101(RawField)^.table_length;
    Field.org_table_length := MYSQL_FIELD_40101(RawField)^.org_table_length;
    Field.db_length := MYSQL_FIELD_40101(RawField)^.db_length;
    Field.catalog_length := MYSQL_FIELD_40101(RawField)^.catalog_length;
    Field.def_length := MYSQL_FIELD_40101(RawField)^.def_length;
    Field.flags := MYSQL_FIELD_40101(RawField)^.flags;
    Field.decimals := MYSQL_FIELD_40101(RawField)^.decimals;
    Field.charsetnr := MYSQL_FIELD_40101(RawField)^.charsetnr;
    Field.field_type := MYSQL_FIELD_40101(RawField)^.field_type;
  end
  else if (Version >= 40100) then
  begin
    Field.name := MYSQL_FIELD_40100(RawField)^.name;
    Field.org_name := MYSQL_FIELD_40100(RawField)^.org_name;
    Field.table := MYSQL_FIELD_40100(RawField)^.table;
    Field.org_table := MYSQL_FIELD_40100(RawField)^.org_table;
    Field.db := MYSQL_FIELD_40100(RawField)^.db;
    Field.catalog := nil;
    Field.def := MYSQL_FIELD_40100(RawField)^.def;
    Field.length := MYSQL_FIELD_40100(RawField)^.length;
    Field.max_length := MYSQL_FIELD_40100(RawField)^.max_length;
    Field.name_length := MYSQL_FIELD_40100(RawField)^.name_length;
    Field.org_name_length := MYSQL_FIELD_40100(RawField)^.org_name_length;
    Field.table_length := MYSQL_FIELD_40100(RawField)^.table_length;
    Field.org_table_length := MYSQL_FIELD_40100(RawField)^.org_table_length;
    Field.db_length := MYSQL_FIELD_40100(RawField)^.db_length;
    Field.catalog_length := 0;
    Field.def_length := MYSQL_FIELD_40100(RawField)^.def_length;
    Field.flags := MYSQL_FIELD_40100(RawField)^.flags;
    Field.decimals := MYSQL_FIELD_40100(RawField)^.decimals;
    Field.charsetnr := MYSQL_FIELD_40100(RawField)^.charsetnr;
    Field.field_type := MYSQL_FIELD_40100(RawField)^.field_type;
  end
  else if (Version >= 40000) then
  begin
    Field.name := MYSQL_FIELD_40000(RawField)^.name;
    Field.org_name := nil;
    Field.table := MYSQL_FIELD_40000(RawField)^.table;
    Field.org_table := MYSQL_FIELD_40000(RawField)^.org_table;
    if (Version = 40017) then
      Field.db := nil // libMySQL.dll 4.0.17 gives back an invalid pointer 
    else
      Field.db := MYSQL_FIELD_40000(RawField)^.db;
    Field.catalog := nil;
    Field.def := MYSQL_FIELD_40000(RawField)^.def;
    Field.length := MYSQL_FIELD_40000(RawField)^.length;
    Field.max_length := MYSQL_FIELD_40000(RawField)^.max_length;
    Field.name_length := 0;
    Field.org_name_length := 0;
    Field.table_length := 0;
    Field.org_table_length := 0;
    Field.db_length := 0;
    Field.catalog_length := 0;
    Field.def_length := 0;
    Field.flags := MYSQL_FIELD_40000(RawField)^.flags;
    Field.decimals := MYSQL_FIELD_40000(RawField)^.decimals;
    Field.charsetnr := 0;
    Field.field_type := MYSQL_FIELD_40000(RawField)^.field_type;
  end
  else
  begin
    Field.name := MYSQL_FIELD_32300(RawField)^.name;
    Field.org_name := nil;
    Field.table := MYSQL_FIELD_32300(RawField)^.table;
    Field.org_table := nil;
    Field.db := nil;
    Field.catalog := nil;
    Field.def := MYSQL_FIELD_32300(RawField)^.def;
    Field.length := MYSQL_FIELD_32300(RawField)^.length;
    Field.max_length := MYSQL_FIELD_32300(RawField)^.max_length;
    Field.name_length := 0;
    Field.org_name_length := 0;
    Field.table_length := 0;
    Field.org_table_length := 0;
    Field.db_length := 0;
    Field.catalog_length := 0;
    Field.def_length := 0;
    Field.flags := MYSQL_FIELD_32300(RawField)^.flags;
    Field.decimals := MYSQL_FIELD_32300(RawField)^.decimals;
    Field.charsetnr := 0;
    Field.field_type := MYSQL_FIELD_32300(RawField)^.field_type;
  end
end;

{ EMySQLError *****************************************************************}

constructor EMySQLError.Create(const Msg: string; const AErrorCode: Integer; const AConnection: TMySQLConnection);
begin
  inherited Create(Msg);

  FConnection := AConnection;
  FErrorCode := AErrorCode;
end;

{ TMySQLMonitor ***************************************************************}

procedure TMySQLMonitor.Append(const Text: PChar; const Length: Integer; const ATraceType: TTraceType);
begin
  FCriticalSection.Enter();

  Append2(Text, Length, ATraceType);

  FCriticalSection.Leave();

  if (Enabled and Assigned(OnMonitor) and Assigned(Connection)) then
  begin
    Assert(GetCurrentThreadId() = MainThreadId);

    OnMonitor(Connection, Text, Length, ATraceType);
  end;
end;

procedure TMySQLMonitor.Append2(const Text: PChar; const Length: Integer; const ATraceType: TTraceType);
var
  ItemLen: Integer;
  ItemText: PChar;
  MoveLen: Integer;
  Pos: Integer;
begin
  if ((Cache.MemLen > 0) and (Length > 0)) then
  begin
    ItemText := Text; ItemLen := Length;
    while ((ItemLen > 0) and CharInSet(ItemText[0], [#9,#10,#13,' '])) do
    begin
      ItemText := @ItemText[1];
      Dec(ItemLen);
    end;

    while ((ItemLen > 0) and CharInSet(ItemText[ItemLen - 1], [#9,#10,#13,' ',';'])) do
      Dec(ItemLen);

    MoveLen := ItemLen;

    if (ATraceType in [ttRequest, ttResult]) then
      Inc(ItemLen, 3) // ';' + New Line
    else
      Inc(ItemLen, 2); // New Line

    if (ItemLen > Cache.MemLen) then
      Clear()
    else
    begin
      while ((Cache.UsedLen + ItemLen > Cache.MemLen) and (Cache.ItemsLen.Count > 0)) do
      begin
        Inc(Cache.First, Cache.ItemsLen[0]); if (Cache.First >= Cache.MemLen) then Dec(Cache.First, Cache.MemLen);
        Dec(Cache.UsedLen, Cache.ItemsLen[0]);
        Cache.ItemsLen.Delete(0);
      end;

      Pos := (Cache.First + Cache.UsedLen) mod Cache.MemLen;
      if (Pos + MoveLen <= Cache.MemLen) then
        MoveMemory(@Cache.Mem[Pos], ItemText, MoveLen * SizeOf(Cache.Mem[0]))
      else
      begin
        MoveMemory(@Cache.Mem[Pos], @ItemText[0], (Cache.MemLen - Pos) * SizeOf(Cache.Mem[0]));
        MoveMemory(@Cache.Mem[0], @ItemText[Cache.MemLen - Pos], (MoveLen - (Cache.MemLen - Pos)) * SizeOf(Cache.Mem[0]));
      end;

      Inc(Cache.UsedLen, ItemLen);
      Cache.ItemsLen.Add(ItemLen);

      Pos := (Cache.First + Cache.UsedLen) mod Cache.MemLen;
      case (Pos) of
        0:
          begin
            if (ATraceType in [ttRequest, ttResult]) then
              Cache.Mem[Cache.MemLen - 3] := ';';
            Cache.Mem[Cache.MemLen - 2] := #13;
            Cache.Mem[Cache.MemLen - 1] := #10;
          end;
        1:
          begin
            if (ATraceType in [ttRequest, ttResult]) then
              Cache.Mem[Cache.MemLen - 2] := ';';
            Cache.Mem[Cache.MemLen - 1] := #13;
            Cache.Mem[0] := #10;
          end;
        2:
          begin
            if (ATraceType in [ttRequest, ttResult]) then
              Cache.Mem[Cache.MemLen - 1] := ';';
            Cache.Mem[0] := #13;
            Cache.Mem[1] := #10;
          end;
        else
          begin
            if (ATraceType in [ttRequest, ttResult]) then
              Cache.Mem[Pos - 3] := ';';
            Cache.Mem[Pos - 2] := #13;
            Cache.Mem[Pos - 1] := #10;
          end;
      end;
    end;
  end;
end;

procedure TMySQLMonitor.Append(const Text: string; const ATraceType: TTraceType);
begin
  Append(PChar(Text), Length(Text), ATraceType);
end;

procedure TMySQLMonitor.Clear();
begin
  Cache.First := 0;
  Cache.UsedLen := 0;
  Cache.ItemsLen.Clear();
end;

constructor TMySQLMonitor.Create(AOwner: TComponent);
begin
  inherited;

  FConnection := nil;
  FCriticalSection := TCriticalSection.Create();
  FEnabled := False;
  FOnMonitor := nil;
  FTraceTypes := [ttRequest];

  Cache.First := 0;
  Cache.ItemsLen := TList<Integer>.Create();
  Cache.Mem := nil;
  Cache.MemLen := 0;
  Cache.UsedLen := 0;
end;

destructor TMySQLMonitor.Destroy();
begin
  if (Assigned(Connection)) then
    Connection.UnRegisterSQLMonitor(Self);

  FreeMem(Cache.Mem);
  Cache.ItemsLen.Free();
  FCriticalSection.Free();

  inherited;
end;

function TMySQLMonitor.GetCacheSize(): Integer;
begin
  Result := Cache.MemLen * SizeOf(Cache.Mem[0]);
end;

function TMySQLMonitor.GetCacheText(): string;
var
  Len: Integer;
begin
  FCriticalSection.Enter();

  if (Cache.UsedLen < 2) then
    Result := ''
  else
  begin
    Len := Cache.UsedLen - 2; // Remove ending #13#10
    if (Cache.First + Len <= Cache.MemLen) then
      SetString(Result, PChar(@Cache.Mem[Cache.First]), Len)
    else
    begin
      SetLength(Result, Len);
      MoveMemory(@Result[1], @Cache.Mem[Cache.First], (Cache.MemLen - Cache.First) * SizeOf(Cache.Mem[0]));
      MoveMemory(@Result[1 + Cache.MemLen - Cache.First], @Cache.Mem[0], (Len - (Cache.MemLen - Cache.First)) * SizeOf(Cache.Mem[0]));
    end;
  end;

  FCriticalSection.Leave();
end;

procedure TMySQLMonitor.SetConnection(const AConnection: TMySQLConnection);
begin
  if (Assigned(Connection)) then
    Connection.UnRegisterSQLMonitor(Self);

  FConnection := AConnection;

  if (Assigned(Connection)) then
    Connection.RegisterSQLMonitor(Self);
end;

procedure TMySQLMonitor.SetCacheSize(const ACacheSize: Integer);
var
  NewMem: PChar;
  NewSize: Integer;
begin
  NewSize := ACacheSize - ACacheSize mod SizeOf(Cache.Mem[0]);
  if (NewSize = 0) then
  begin
    if (Assigned(Cache.Mem)) then
      FreeMem(Cache.Mem);
    Cache.Mem := nil;
    Cache.MemLen := 0;
    Clear();
  end
  else
  begin
    while (Cache.UsedLen * SizeOf(Cache.Mem[0]) > NewSize) do
    begin
      Cache.First := (Cache.First + Cache.ItemsLen[0]) mod Cache.MemLen;
      Dec(Cache.UsedLen, Cache.ItemsLen[0]);
      Cache.ItemsLen.Delete(0);
    end;

    GetMem(NewMem, NewSize);

    if (Cache.UsedLen > 0) then
      if (Cache.First + Cache.UsedLen <= Cache.MemLen) then
        MoveMemory(@NewMem[0], @Cache.Mem[Cache.First], Cache.UsedLen * SizeOf(Cache.Mem[0]))
      else
      begin
        MoveMemory(@NewMem[0], @Cache.Mem[Cache.First], (Cache.MemLen - Cache.First) * SizeOf(Cache.Mem[0]));
        MoveMemory(@NewMem[Cache.MemLen - Cache.First], @Cache.Mem[0], (Cache.First + Cache.UsedLen - Cache.MemLen) * SizeOf(Cache.Mem[0]));
      end;

    if (Assigned(Cache.Mem)) then
      FreeMem(Cache.Mem);

    Cache.Mem := NewMem;
    Cache.MemLen := NewSize div SizeOf(Cache.Mem[0]);
    Cache.First := 0;
  end;
end;

procedure TMySQLMonitor.SetOnMonitor(const AOnMonitor: TMySQLOnMonitor);
begin
  FOnMonitor := AOnMonitor;
end;

{ TMySQLConnection.TTerminatedThreads *****************************************}

function TMySQLConnection.TTerminatedThreads.Add(const Item: Pointer): Integer;
begin
  CriticalSection.Enter();

  Result := inherited Add(Item);

  CriticalSection.Leave();
end;

constructor TMySQLConnection.TTerminatedThreads.Create(const AConnection: TMySQLConnection);
begin
  inherited Create();

  FConnection := AConnection;

  CriticalSection := TCriticalSection.Create();
end;

procedure TMySQLConnection.TTerminatedThreads.Delete(const Item: Pointer);
var
  Index: Integer;
begin
  CriticalSection.Enter();

  Index := IndexOf(Item);
  if (Index >= 0) then
    Delete(Index);

  CriticalSection.Leave();
end;

destructor TMySQLConnection.TTerminatedThreads.Destroy();
begin
  CriticalSection.Enter();

  while (Count > 0) do
  begin
    TerminateThread(TThread(Items[0]).Handle, 1);
    inherited Delete(0);
  end;

  CriticalSection.Leave();

  CriticalSection.Free();

  inherited;
end;

{ TMySQLConnection.TSyncThread *********************************************}

constructor TMySQLConnection.TSyncThread.Create(const AConnection: TMySQLConnection);
begin
  inherited Create(False);

  FConnection := AConnection;

  FRunExecute := TEvent.Create(nil, True, False, '');
  SetLength(CLStmts, 0);
  FinishedReceiving := False;
  StmtLengths := TList<Integer>.Create();
  State := ssClose;

  MySQLSyncThreads.Add(Self);
end;

destructor TMySQLConnection.TSyncThread.Destroy();
begin
  MySQLSyncThreads.Delete(MySQLSyncThreads.IndexOf(Self));

  RunExecute.Free();
  SetLength(CLStmts, 0);
  StmtLengths.Free();

  inherited;
end;

procedure TMySQLConnection.TSyncThread.Execute();
var
  Timeout: LongWord;
  WaitResult: TWaitResult;
begin
  {$IFDEF EurekaLog}
  try
  {$ENDIF}

  while (not Terminated) do
  begin
    if ((Connection.ServerTimeout < 5) or (Connection.LibraryType = ltHTTP)) then
      Timeout := INFINITE
    else
      Timeout := (Connection.ServerTimeout - 5) * 1000;
    WaitResult := RunExecute.WaitFor(Timeout);

    if (not Terminated) then
      if (WaitResult = wrTimeout) then
      begin
        if (State = ssReady) then
          Connection.SyncPing(Self);
      end
      else
      begin
        case (State) of
          ssConnecting:
            Connection.SyncConnecting(Self);
          ssExecutingFirst:
            Connection.SyncExecutingFirst(Self);
          ssExecutingNext:
            Connection.SyncExecutingNext(Self);
          ssReceivingResult:
            Connection.SyncReceivingResult(Self);
          ssDisconnecting:
            Connection.SyncDisconnecting(Self);
          else
            raise ERangeError.Create('State: ' + IntToStr(Ord(State)));
        end;

        Connection.TerminateCS.Enter();
        RunExecute.ResetEvent();
        if (not Terminated) then
          if ((State = ssDisconnecting)
            or ((SynchronCount > 0)
              and ((Mode = smSQL) or (State <> ssReceivingResult))
              and not Connection.BesideThreadWaits)) then
          begin
            Connection.SyncThreadExecuted.SetEvent();
            Connection.DebugMonitor.Append('SyncThreadExecuted.Set - 1 - State: ' + IntToStr(Ord(State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
          end
          else
            MySQLConnectionOnSynchronize(Self, 0);
        Connection.TerminateCS.Leave();
      end;
  end;

  Connection.TerminateCS.Enter();
  Connection.TerminatedThreads.Delete(Self);
  Connection.TerminateCS.Leave();

  {$IFDEF EurekaLog}
  except
    on E: Exception do
      ExceptionManager.StandardEurekaNotify(E);
  end;
  {$ENDIF}
end;

function TMySQLConnection.TSyncThread.GetCommandText(): string;
begin
  if (StmtIndex = StmtLengths.Count) then
    Result := ''
  else
    SetString(Result, PChar(@SQL[SQLIndex]), StmtLengths[StmtIndex]);
end;

function TMySQLConnection.TSyncThread.GetIsRunning(): Boolean;
begin
  Result := not Terminated
    and ((RunExecute.WaitFor(IGNORE) = wrSignaled) or not (State in [ssClose, ssReady, ssAfterExecuteSQL]));
end;

function TMySQLConnection.TSyncThread.GetNextCommandText(): string;
var
  EndingCommentLength: Integer;
  Len: Integer;
  StartingCommentLength: Integer;
  StmtLength: Integer;
begin
  if (StmtIndex + 1 = StmtLengths.Count) then
    Result := ''
  else
  begin
    StmtLength := StmtLengths[StmtIndex + 1];
    Len := SQLTrimStmt(SQL, SQLIndex, StmtLength, StartingCommentLength, EndingCommentLength);
    Result := Copy(SQL, SQLIndex + StmtLengths[StmtIndex] + StartingCommentLength, Len);
  end;
end;

{ TMySQLConnection ************************************************************}

procedure TMySQLConnection.BeginSilent();
begin
  Inc(SilentCount);
end;

procedure TMySQLConnection.BeginSynchron(const Index: Integer);
begin
  Inc(FSynchronCount);

  DebugMonitor.Append('BeginSynchron - ' + IntToStr(Index) + ' - SynchronCount: ' + IntToStr(SynchronCount), ttDebug);
end;

function TMySQLConnection.CharsetToCharsetNr(const Charset: string): Byte;
var
  I: Integer;
begin
  Result := 0;

  if (MySQLVersion < 40101) then
  begin
    for I := 0 to Length(MySQL_Character_Sets) - 1 do
      if (AnsiStrings.StrIComp(PAnsiChar(AnsiString(Charset)), MySQL_Character_Sets[I].CharsetName) = 0) then
        Result := I;
  end
  else
  begin
    for I := 0 to Length(MySQL_Collations) - 1 do
      if (MySQL_Collations[I].Default and (AnsiStrings.StrIComp(PAnsiChar(AnsiString(Charset)), MySQL_Collations[I].CharsetName) = 0)) then
        Result := MySQL_Collations[I].CharsetNr;
  end;
end;

function TMySQLConnection.CharsetToCodePage(const Charset: string): Cardinal;
var
  I: Integer;
begin
  Result := CP_ACP;

  if (MySQLVersion < 40101) then
  begin
    for I := 0 to Length(MySQL_Character_Sets) - 1 do
      if (AnsiStrings.StrIComp(PAnsiChar(AnsiString(Charset)), MySQL_Character_Sets[I].CharsetName) = 0) then
        Result := MySQL_Character_Sets[I].CodePage;
  end
  else
  begin
    for I := 0 to Length(MySQL_Collations) - 1 do
      if (MySQL_Collations[I].Default and (AnsiStrings.StrIComp(PAnsiChar(AnsiString(Charset)), MySQL_Collations[I].CharsetName) = 0)) then
        Result := MySQL_Collations[I].CodePage;
  end;
end;

procedure TMySQLConnection.CancelResultHandle(var ResultHandle: TResultHandle);
begin
  Terminate();

  if (Assigned(SyncThread) and (SyncThread.State = ssAfterExecuteSQL)) then
    Sync(SyncThread);
end;

procedure TMySQLConnection.CloseResultHandle(var ResultHandle: TResultHandle);
begin
  CancelResultHandle(ResultHandle);

  ResultHandle.SQL := '';
  ResultHandle.SQLIndex := 0;
  ResultHandle.SyncThread := nil;
end;

function TMySQLConnection.CodePageToCharset(const CodePage: Cardinal): string;
var
  I: Integer;
begin
  Result := '';

  if (MySQLVersion < 40101) then
  begin
    for I := 0 to Length(MySQL_Character_Sets) - 1 do
      if ((Result = '') and (MySQL_Character_Sets[I].CodePage = CodePage)) then
        Result := string(AnsiStrings.StrPas(MySQL_Character_Sets[I].CharsetName));
  end
  else
  begin
    for I := 0 to Length(MySQL_Collations) - 1 do
      if ((Result = '') and (MySQL_Collations[I].CodePage = CodePage)) then
        Result := string(AnsiStrings.StrPas(MySQL_Collations[I].CharsetName));
  end;
end;

constructor TMySQLConnection.Create(AOwner: TComponent);
begin
  inherited;

  FFormatSettings := TFormatSettings.Create(GetSystemDefaultLCID());
  FFormatSettings.ThousandSeparator := #0;
  FFormatSettings.DecimalSeparator := '.';
  FFormatSettings.ShortDateFormat := 'yyyy/MM/dd';
  FFormatSettings.LongDateFormat := FFormatSettings.ShortDateFormat;
  FFormatSettings.LongTimeFormat := 'hh:mm:ss';
  FFormatSettings.DateSeparator := '-';
  FFormatSettings.TimeSeparator := ':';

  BesideThreadWaits := False;
  FAfterExecuteSQL := nil;
  FAnsiQuotes := False;
  FAsynchron := False;
  FBeforeExecuteSQL := nil;
  FCharsetClient := 'utf8';
  FCharsetResult := 'utf8';
  FCodePageClient := CP_UTF8;
  FCodePageResult := CP_UTF8;
  FConnected := False;
  FDatabaseName := '';
  FExecutionTime := 0;
  FHost := '';
  FHTTPAgent := '';
  FIdentifierQuoted := True;
  FIdentifierQuoter := '`';
  FLatestConnect := 0;
  FLib := nil;
  FSQLParser := nil;
  FSyncThread := nil;
  FLibraryType := ltBuiltIn;
  FMariaDBVersion := 0;
  FMultiStatements := True;
  FOnConvertError := nil;
  FOnSQLError := nil;
  FOnUpdateIndexDefs := nil;
  FPassword := '';
  FPort := MYSQL_PORT;
  FServerTimeout := 0;
  FSQLMonitors := TList.Create();
  FMySQLVersion := 0;
  FServerVersionStr := '';
  FTerminateCS := TCriticalSection.Create();
  FTerminatedThreads := TTerminatedThreads.Create(Self);
  FThreadDeep := 0;
  FThreadId := 0;
  FUserName := '';
  FSyncThreadExecuted := TEvent.Create(nil, False, False, '');
  InMonitor := False;
  InOnResult := False;
  CommittingDataSet := nil;
  SilentCount := 0;
  TimeDiff := 0;

  FDebugMonitor := TMySQLMonitor.Create(nil);
  FDebugMonitor.Connection := Self;
  FDebugMonitor.CacheSize := 10000;
  FDebugMonitor.Enabled := True;
  FDebugMonitor.TraceTypes := [ttTime, ttRequest, ttInfo, ttDebug];
end;

function TMySQLConnection.CreateResultHandle(out ResultHandle: TResultHandle; const SQL: string): Boolean;
begin
  Assert(GetCurrentThreadId() <> MainThreadId);

  if (SQL = '') then
    Result := False
  else
  begin
    ResultHandle.SQL := SQL;
    ResultHandle.SQLIndex := 1;
    ResultHandle.SyncThread := nil;

    Result := True;
  end;
end;

destructor TMySQLConnection.Destroy();
var
  I: Integer;
begin
  Asynchron := False;
  Close();

  while (DataSetCount > 0) do
    DataSets[0].Free();

  if (Assigned(SyncThread)) then
    // Forget the memory - speed is more important...
    if (SyncThread.IsRunning) then
      TerminateThread(SyncThread.Handle, 0)
    else
    begin
      SyncThread.Terminate();
      {$IFDEF Debug}
      SyncThread.RunExecute.SetEvent();
      SyncThread.WaitFor();
      SyncThread.Free();
      {$ENDIF}
    end;
  TerminateCS.Enter();
  for I := 0 to TerminatedThreads.Count - 1 do
    TerminateThread(TThread(TerminatedThreads[I]).Handle, 0);
  TerminateCS.Leave();
  TerminatedThreads.Free();

  TerminateCS.Free();
  FDebugMonitor.Free();
  FSQLMonitors.Free();
  if (Assigned(FSQLParser)) then
    FSQLParser.Free();
  SyncThreadExecuted.Free();

  inherited;
end;

procedure TMySQLConnection.DoAfterExecuteSQL();
begin
  if (Assigned(AfterExecuteSQL)) then AfterExecuteSQL(Self);
end;

procedure TMySQLConnection.DoBeforeExecuteSQL();
begin
  if (Assigned(BeforeExecuteSQL)) then BeforeExecuteSQL(Self);
end;

procedure TMySQLConnection.DoConnect();
begin
  Assert(Assigned(MySQLConnectionOnSynchronize));
  Assert(not Connected);

  FExecutionTime := 0;
  FErrorCode := DS_ASYNCHRON;
  FErrorMessage := '';
  FErrorCommandText := '';
  FWarningCount := 0;

  Terminate();
  if (not Assigned(FSyncThread)) then
    FSyncThread := TSyncThread.Create(Self);

  SyncThread.State := ssConnect;
  repeat
    Sync(SyncThread);
  until ((SynchronCount = 0)
    or not Assigned(SyncThread)
    or (SyncThread.State in [ssClose, ssReady]));
end;

procedure TMySQLConnection.DoConvertError(const Sender: TObject; const Text: string; const Error: EConvertError);
begin
  if (Assigned(FOnConvertError)) then
    FOnConvertError(Sender, Text)
  else
    raise Error;
end;

procedure TMySQLConnection.DoDatabaseChange(const NewName: string);
begin
  FDatabaseName := NewName;

  if (Assigned(FOnDatabaseChange)) then
    FOnDatabaseChange(Self, NewName);
end;

procedure TMySQLConnection.DoDisconnect();
begin
  Assert(Connected);

  SendConnectEvent(False);

  Terminate();

  FErrorCode := DS_ASYNCHRON;
  FErrorMessage := '';
  FErrorCommandText := '';
  FWarningCount := 0;

  if (not Assigned(SyncThread) or not Assigned(SyncThread.LibHandle)) then
    SyncDisconnected(nil)
  else if (not SyncThread.Terminated) then
  begin
    SyncThread.State := ssDisconnect;
    Sync(SyncThread);
    if ((SyncThreadExecuted.WaitFor(500) = wrSignaled) and (SyncThread.State = ssDisconnecting)) then
      Sync(SyncThread)
    else
    begin
      Terminate();
      FConnected := False;
    end;
  end;
end;

procedure TMySQLConnection.DoError(const AErrorCode: Integer; const AErrorMessage: string);
begin
  if ((ErrorCode = CR_UNKNOWN_HOST)
    or (ErrorCode = DS_SERVER_OLD)) then
    Close()
  else if (ConnectionLost(ErrorCode)) then
    SyncDisconnected(SyncThread);

  FErrorCode := AErrorCode;
  FErrorMessage := AErrorMessage;
  if (not Assigned(SyncThread)) then
    FErrorCommandText := ''
  else
    FErrorCommandText := SyncThread.CommandText;

  if (SilentCount = 0) then
    if (not Assigned(FOnSQLError)) then
      raise EMySQLError.Create(ErrorMessage, ErrorCode, Self)
    else
      FOnSQLError(Self, ErrorCode, ErrorMessage);
end;

procedure TMySQLConnection.DoVariableChange(const Name, NewValue: string);
begin
  if (Assigned(FOnVariableChange)) then
    FOnVariableChange(Self, Name, NewValue);
end;

procedure TMySQLConnection.EndSilent();
begin
  if (SilentCount > 0) then
    Dec(SilentCount);
end;

procedure TMySQLConnection.EndSynchron(const Index: Integer);
begin
  DebugMonitor.Append('EndSynchron - ' + IntToStr(Index) + ' - SynchronCount: ' + IntToStr(SynchronCount), ttDebug);

  if (SynchronCount > 0) then
    Dec(FSynchronCount);
end;

function TMySQLConnection.EscapeIdentifier(const Identifier: string): string;
begin
  Result := SQLEscape(Identifier, IdentifierQuoter);
end;

function TMySQLConnection.ExecuteResult(var ResultHandle: TResultHandle): Boolean;
begin
  if (Assigned(ResultHandle.SyncThread)) then
    Assert(ResultHandle.SyncThread.State in [ssClose, ssReady, ssFirst, ssNext, ssAfterExecuteSQL],
      'State: ' + IntToStr(Ord(ResultHandle.SyncThread.State)));

  BeginSynchron(1);
  if (ResultHandle.SQLIndex = Length(ResultHandle.SQL) + 1) then
    Result := False
  else if (not Assigned(ResultHandle.SyncThread) or (ResultHandle.SyncThread.State in [ssClose, ssReady])) then
  begin
    InternExecuteSQL(smResultHandle, RightStr(ResultHandle.SQL, Length(ResultHandle.SQL) - (ResultHandle.SQLIndex - 1)), TResultEvent(nil));
    ResultHandle.SyncThread := SyncThread;

    Result := ErrorCode = 0;
  end
  else
  begin
    Assert(ResultHandle.SyncThread = SyncThread);

    repeat
      Sync(SyncThread);
    until (SyncThread.State in [ssClose, ssResult, ssReady]);

    Result := ErrorCode = 0;
  end;
  EndSynchron(1);

  if (Result) then
    Inc(ResultHandle.SQLIndex, ResultHandle.SyncThread.StmtLengths[ResultHandle.SyncThread.StmtIndex]);
end;

function TMySQLConnection.ExecuteSQL(const SQL: string; const OnResult: TResultEvent = nil): Boolean;
begin
  BeginSynchron(2);
  Result := InternExecuteSQL(smSQL, SQL, OnResult);
  EndSynchron(2);
end;

function TMySQLConnection.GetConnected(): Boolean;
begin
  Result := FConnected;
end;

function TMySQLConnection.GetDataFileAllowed(): Boolean;
begin
  Result := Assigned(Lib) and not (Lib.LibraryType in [ltHTTP]);
end;

function TMySQLConnection.GetErrorMessage(const AHandle: MySQLConsts.MYSQL): string;
var
  B: Byte;
  Index: Integer;
  Len: Integer;
  RBS: RawByteString;
begin
  RBS := AnsiStrings.StrPas(Lib.mysql_error(AHandle));
  try
    Result := LibDecode(CodePageResult, my_char(RBS));
  except
    Result := string(RBS);
  end;

  repeat
    Index := Pos('\x', Result);
    if (Index > 0) then
    begin
      Len := HexToBin(PChar(@Result[Index + 2]), B, 1);
      if (Len = 0) then
        Index := 0
      else
        Result := LeftStr(Result, Index - 1) + Chr(B) + RightStr(Result, Length(Result) - Index - 3);
    end;
  until (Index = 0);
end;

function TMySQLConnection.GetHandle(): MySQLConsts.MYSQL;
begin
  if (not Assigned(SyncThread)) then
    Result := nil
  else
    Result := SyncThread.LibHandle;
end;

function TMySQLConnection.GetInfo(): string;
var
  Info: my_char;
begin
  if (not Assigned(Handle)) then
    Result := ''
  else
  begin
    Info := Lib.mysql_info(Handle);
    try
      Result := '--> ' + LibDecode(CodePageResult, Info);
    except
      Result := '--> ' + string(Info);
    end;
  end;
end;

function TMySQLConnection.GetInsertId(): my_ulonglong;
begin
  if (not Assigned(Handle)) then
    Result := 0
  else
    Result := Lib.mysql_insert_id(Handle);
end;

function TMySQLConnection.GetMaxAllowedServerPacket(): Integer;
begin
  // MAX_ALLOWED_PACKET Constante of the Server - SizeOf(COM_QUERY)
  Result := 1 * 1024 * 1024 - 1;
end;

function TMySQLConnection.GetNextCommandText(): string;
begin
  if (not Assigned(SyncThread) or not SyncThread.IsRunning) then
    Result := ''
  else
    Result := SyncThread.NextCommandText;
end;

function TMySQLConnection.GetServerTime(): TDateTime;
begin
  Result := Now() + TimeDiff;
end;

function TMySQLConnection.InternExecuteSQL(const Mode: TSyncThread.TMode;
  const SQL: string; const OnResult: TResultEvent = nil; const Done: TEvent = nil;
  const DataSet: TMySQLDataSet = nil): Boolean;
var
  CLStmt: TSQLCLStmt;
  SQLIndex: Integer;
  StmtIndex: Integer;
  StmtLength: Integer;
  ST: TSyncThread;
  Progress: string;
  S: string;
begin
  Assert(SQL <> '');
  Assert(not Assigned(Done) or (Done.WaitFor(IGNORE) <> wrSignaled));

  if (GetCurrentThreadId() = MainThreadID) then
  begin
    if (InOnResult) then
      raise Exception.Create('Thread synchronization error (in OnResult): ' + SyncThread.CommandText + #10 + 'New query: ' + SQL);
    if (InMonitor) then
      raise Exception.Create('Thread synchronization error (in Monitor): ' + SyncThread.CommandText + #10 + 'New query: ' + SQL);
  end;

  Terminate();
  if (not Assigned(SyncThread)) then
    FSyncThread := TSyncThread.Create(Self);

  Assert(MySQLSyncThreads.IndexOf(SyncThread) >= 0);

  SetLength(SyncThread.CLStmts, 0);
  SyncThread.DataSet := DataSet;
  SyncThread.ExecutionTime := 0;
  SyncThread.Mode := Mode;
  SyncThread.OnResult := OnResult;
  SyncThread.Done := Done;
  SyncThread.SQLIndex := 1;
  SyncThread.StmtIndex := 0;
  SyncThread.StmtLengths.Clear();

  if (KillThreadId = 0) then
    SyncThread.SQL := SQL
  else if (MySQLVersion < 50000) then
    SyncThread.SQL := 'KILL ' + IntToStr(KillThreadId) + ';' + #13#10 + SQL
  else
    SyncThread.SQL := 'KILL CONNECTION ' + IntToStr(KillThreadId) + ';' + #13#10 + SQL;


  FErrorCode := DS_ASYNCHRON;
  FErrorMessage := '';
  FErrorCommandText := '';
  FWarningCount := 0;
  FSuccessfullExecutedSQLLength := 0; FExecutedStmts := 0;
  FRowsAffected := -1; FExecutionTime := 0;


  // Debug 2017-02-04
  ST := SyncThread;
  if (SyncThread.SQL = '') then
    raise EDatabaseError.Create('Empty query');

  SQLIndex := 1;
  StmtLength := 1; // ... make sure, the first SQLStmtLength will be handled
  while ((SQLIndex <= Length(SyncThread.SQL)) and (StmtLength > 0)) do
  begin
    Progress := Progress + '.';
    Assert(SyncThread = ST,
      'Length: ' + IntToStr(Length(SyncThread.SQL)) + #13#10
      + 'Empty: ' + BoolToStr(SyncThread.SQL = '', True) + #13#10
      + 'Progress: ' + Progress + #13#10
      + SQLEscapeBin(SQL, True));
    S := SyncThread.SQL;
    StmtLength := SQLStmtLength(@SyncThread.SQL[SQLIndex], Length(SyncThread.SQL) - (SQLIndex - 1));
    Assert(SyncThread = ST,
      'Length: ' + IntToStr(Length(SyncThread.SQL)) + #13#10
      + 'Empty: ' + BoolToStr(SyncThread.SQL = '', True) + #13#10
      + 'Progress: ' + Progress + #13#10
      + SQLEscapeBin(SyncThread.SQL, True) + #13#10
      + 'Nils' + #13#10
      + SQLEscapeBin(SQL, True) + #13#10
      + 'Nils' + #13#10
      + SQLEscapeBin(S, True) + #13#10);

    if (StmtLength > 0) then
    begin
      SyncThread.StmtLengths.Add(StmtLength);
      Inc(SQLIndex, StmtLength);
    end;

    Progress := Progress + '.';
  end;

  if ((SyncThread.StmtLengths.Count > 0) and not CharInSet(SyncThread.SQL[SQLIndex - 1], [#10, #13, ';'])) then
  begin
    // The MySQL server answers sometimes about a problem "near ''", if a
    // statement is not terminated by ";". A ";" attached to the last statement
    // avoids this sometimes...
    if (SQLIndex < Length(SyncThread.SQL)) then
      SyncThread.SQL[SQLIndex] := ';'
    else
      SyncThread.SQL := SyncThread.SQL + ';';
    SyncThread.StmtLengths[SyncThread.StmtLengths.Count - 1] := SyncThread.StmtLengths[SyncThread.StmtLengths.Count - 1] + 1;
  end;

  SetLength(SyncThread.CLStmts, SyncThread.StmtLengths.Count);
  SQLIndex := 1;
  for StmtIndex := 0 to SyncThread.StmtLengths.Count - 1 do
  begin
    StmtLength := SyncThread.StmtLengths[StmtIndex];
    SyncThread.CLStmts[StmtIndex] := SQLParseCLStmt(CLStmt, @SyncThread.SQL[SQLIndex], StmtLength, MySQLVersion);
    Inc(SQLIndex, StmtLength);
  end;

  if (SyncThread.SQL = '') then
    raise EDatabaseError.Create('Empty query')
  else if (SyncThread.StmtLengths.Count = 0) then
    Result := False
  else if (SynchronCount > 0) then
  begin
    // Debug 2017-03-24
    Assert(SyncThreadExecuted.WaitFor(IGNORE) <> wrSignaled,
      'State: ' + IntToStr(Ord(SyncThread.State)) + #13#10
      + DebugMonitor.CacheText);
    DebugMonitor.Append('InternExecuteSQL - 1 - SynchronCount: ' + IntToStr(SynchronCount) + ' / ' + IntToStr(SyncThread.SynchronCount), ttDebug);

    SyncThread.State := ssBeforeExecuteSQL;
    repeat
      Sync(SyncThread);
    until (not Assigned(SyncThread)
      or (SyncThread.State in [ssClose, ssResult, ssReady])
      or (Mode = smDataSet) and (SyncThread.State = ssReceivingResult));
    Result := Assigned(SyncThread) and (SyncThread.ErrorCode = 0);

    DebugMonitor.Append('InternExecuteSQL - 2 - SynchronCount: ' + IntToStr(SynchronCount) + ' / ' + IntToStr(SyncThread.SynchronCount), ttDebug);
    // Debug 2017-03-25
    Assert(SyncThreadExecuted.WaitFor(IGNORE) <> wrSignaled,
      'State: ' + IntToStr(Ord(SyncThread.State)) + #13#10
      + 'Mode: ' + IntToStr(Ord(Mode)) + #13#10
      + DebugMonitor.CacheText);
  end
  else
  begin
    SyncThread.State := ssBeforeExecuteSQL;
    Sync(SyncThread);
    Result := False;
  end;
end;

function TMySQLConnection.InUse(): Boolean;
begin
  TerminateCS.Enter();
  Result := Assigned(SyncThread) and not (SyncThread.State in [ssClose, ssReady]) or InMonitor;
  TerminateCS.Leave();
end;

procedure TMySQLConnection.local_infile_end(const local_infile: Plocal_infile);
begin
  if (local_infile^.Handle <> INVALID_HANDLE_VALUE) then
    CloseHandle(local_infile^.Handle);
  if (Assigned(local_infile^.Buffer)) then
    VirtualFree(local_infile^.Buffer, local_infile^.BufferSize, MEM_RELEASE);

  FreeMem(local_infile);
end;

function TMySQLConnection.local_infile_error(const local_infile: Plocal_infile; const error_msg: my_char; const error_msg_len: my_uint): my_int;
var
  Buffer: PChar;
  Len: Integer;
begin
  Buffer := nil;
  Len := FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS, nil, local_infile^.LastError, 0, @Buffer, 0, nil);
  if (Len > 0) then
  begin
    Len := WideCharToAnsiChar(CodePageClient, Buffer, Len, error_msg, error_msg_len);
    error_msg[Len] := #0;
    LocalFree(HLOCAL(Buffer));
  end
  else if (GetLastError() = 0) then
    RaiseLastOSError();
  Result := local_infile^.ErrorCode;
end;

function TMySQLConnection.local_infile_init(out local_infile: Plocal_infile; const filename: my_char): my_int;
begin
  GetMem(local_infile, SizeOf(local_infile^));
  ZeroMemory(local_infile, SizeOf(local_infile^));
  local_infile^.Buffer := nil;
  local_infile^.Connection := Self;
  local_infile^.Position := 0;

  if ((AnsiCharToWideChar(CodePageClient, filename, lstrlenA(filename), @local_infile^.Filename, Length(local_infile^.Filename)) = 0) and (GetLastError() <> 0)) then
  begin
    local_infile^.ErrorCode := EE_FILENOTFOUND;
    local_infile^.LastError := GetLastError();
  end
  else
  begin
    local_infile^.Handle := CreateFile(@local_infile^.Filename, GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if (local_infile^.Handle = INVALID_HANDLE_VALUE) then
    begin
      local_infile^.ErrorCode := EE_FILENOTFOUND;
      local_infile^.LastError := GetLastError();
    end
    else
    begin
      local_infile^.ErrorCode := 0;
      local_infile^.LastError := 0;
    end;
  end;

  Result := local_infile^.ErrorCode;
end;

function TMySQLConnection.local_infile_read(const local_infile: Plocal_infile; buf: my_char; const buf_len: my_uint): my_int;
var
  BytesPerSector: DWord;
  NumberofFreeClusters: DWord;
  SectorsPerCluser: DWord;
  Size: DWord;
  TotalNumberOfClusters: DWord;
begin
  if (not Assigned(local_infile^.Buffer)) then
  begin
    local_infile^.BufferSize := buf_len;
    if (GetFileSize(local_infile^.Handle, nil) > 0) then
      local_infile^.BufferSize := Min(GetFileSize(local_infile^.Handle, nil), local_infile^.BufferSize);

    if (GetDiskFreeSpace(PChar(ExtractFileDrive(local_infile^.Filename)), SectorsPerCluser, BytesPerSector, NumberofFreeClusters, TotalNumberOfClusters)
      and (local_infile^.BufferSize mod BytesPerSector > 0)) then
      Inc(local_infile^.BufferSize, BytesPerSector - local_infile^.BufferSize mod BytesPerSector);
    local_infile^.Buffer := VirtualAlloc(nil, local_infile^.BufferSize, MEM_COMMIT, PAGE_READWRITE);

    if (not Assigned(local_infile^.Buffer)) then
      local_infile^.ErrorCode := EE_OUTOFMEMORY;
  end;

  if (not ReadFile(local_infile^.Handle, local_infile^.Buffer^, Min(buf_len, local_infile^.BufferSize), Size, nil)) then
  begin
    local_infile^.LastError := GetLastError();
    local_infile^.ErrorCode := EE_READ;
    Result := -1;
  end
  else
  begin
    MoveMemory(buf, local_infile^.Buffer, Size);
    Inc(local_infile^.Position, Size);
    Result := Size;
  end;
end;

procedure TMySQLConnection.RegisterSQLMonitor(const SQLMonitor: TMySQLMonitor);
begin
  if (FSQLMonitors.IndexOf(SQLMonitor) < 0) then
    FSQLMonitors.Add(SQLMonitor);
end;

function TMySQLConnection.SendSQL(const SQL: string; const Done: TEvent): Boolean;
begin
  Result := InternExecuteSQL(smSQL, SQL, TResultEvent(nil), Done);
end;

function TMySQLConnection.SendSQL(const SQL: string; const OnResult: TResultEvent = nil; const Done: TEvent = nil): Boolean;
begin
  Result := InternExecuteSQL(smSQL, SQL, OnResult, Done);
end;

procedure TMySQLConnection.SetAnsiQuotes(const AAnsiQuotes: Boolean);
begin
  FAnsiQuotes := AAnsiQuotes;

  if (AnsiQuotes) then
    FIdentifierQuoter := '"'
  else
    FIdentifierQuoter := '`';
end;

procedure TMySQLConnection.SetCharsetClient(const ACharset: string);
begin
  if ((ACharset <> '') and (ACharset <> CharsetClient)) then
  begin
    FCharsetClient := LowerCase(ACharset);
    FCodePageClient := CharsetToCodePage(FCharsetClient);

    // Debug 2017-05-25
    Assert(FCodePageClient <> 0,
      'FCharsetClient: ' + FCharsetClient);

    if (Connected and Assigned(Lib.mysql_options) and Assigned(SyncThread)) then
      Lib.mysql_options(Handle, MYSQL_SET_CHARSET_NAME, my_char(RawByteString(FCharsetClient)));
  end;
end;

procedure TMySQLConnection.SetCharsetResult(const ACharset: string);
begin
  if ((ACharset <> '') and (ACharset <> CharsetResult)) then
  begin
    FCharsetResult := LowerCase(ACharset);
    FCodePageResult := CharsetToCodePage(FCharsetResult);
  end;
end;

procedure TMySQLConnection.SetConnected(Value: Boolean);
begin
  if ((csReading in ComponentState) and Value) then
    inherited
  else if (Value and not GetConnected()) then
  begin
    if (Assigned(BeforeConnect)) then BeforeConnect(Self);
    if (not Assigned(FLib)) then
      FLib := LoadMySQLLibrary(FLibraryType, LibraryName);
    DoConnect();
    // Maybe we're using Asynchron. So the Events should be called after
    // thread execution in SyncConnected.
  end
  else if (not Value and GetConnected()) then
  begin
    if Assigned(BeforeDisconnect) then BeforeDisconnect(Self);
    DoDisconnect();
    // Maybe we're using Asynchron. So the Events should be called after
    // thread execution in SyncDisconncted.
  end;
end;

procedure TMySQLConnection.SetDatabaseName(const ADatabaseName: string);
begin
  Assert(not Connected);

  FDatabaseName := ADatabaseName;
end;

procedure TMySQLConnection.SetHost(const AHost: string);
begin
  Assert(not Connected);

  FHost := AHost;
end;

procedure TMySQLConnection.SetLibraryName(const ALibraryName: string);
begin
  Assert(not Connected);

  FLibraryName := ALibraryName;
end;

procedure TMySQLConnection.SetLibraryType(const ALibraryType: TMySQLLibrary.TLibraryType);
begin
  Assert(not Connected);

  FLibraryType := ALibraryType;
end;

procedure TMySQLConnection.SetPassword(const APassword: string);
begin
  Assert(not Connected);

  FPassword := APassword;
end;

procedure TMySQLConnection.SetPort(const APort: Word);
begin
  Assert(not Connected);

  FPort := APort;
end;

procedure TMySQLConnection.SetUsername(const AUsername: string);
begin
  Assert(not Connected);

  FUserName := AUserName;
end;

function TMySQLConnection.SQLUse(const DatabaseName: string): string;
begin
  Result := 'USE ' + EscapeIdentifier(DatabaseName) + ';' + #13#10;
end;

procedure TMySQLConnection.Sync(const SyncThread: TSyncThread);
begin
  Assert(Assigned(SyncThread));

  if (GetCurrentThreadId() <> MainThreadID) then
  begin
    DebugMonitor.Append('SyncT - start - Mode: ' + IntToStr(Ord(SyncThread.Mode)) + ', State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);

    BesideThreadWaits := True;
    MySQLConnectionOnSynchronize(SyncThread, 0);
    if (not Assigned(SyncThread.Done)) then
    begin
      SyncThreadExecuted.WaitFor(INFINITE);
      DebugMonitor.Append('SyncThreadExecuted.Wait - 1 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
    end;
    BesideThreadWaits := False;

    DebugMonitor.Append('SyncT - end - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
  end
  else if (not SyncThread.Terminated) then
  begin
    DebugMonitor.Append('Sync - start - Mode: ' + IntToStr(Ord(SyncThread.Mode)) + ', State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

    case (SyncThread.State) of
      ssConnect:
        begin
          SyncThread.State := ssConnecting;
          SyncThread.SynchronCount := SynchronCount;
          SyncThread.RunExecute.SetEvent();
          if ((SynchronCount > 0) and not BesideThreadWaits) then
          begin
            SyncThreadExecuted.WaitFor(INFINITE);
            DebugMonitor.Append('SyncThreadExecuted.Wait - 2 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
          end;
        end;
      ssConnecting:
        SyncConnected(SyncThread);
      ssBeforeExecuteSQL:
        begin
          SyncBeforeExecuteSQL(SyncThread);
          SyncExecute(SyncThread);
          SyncThread.SynchronCount := SynchronCount;
          SyncThread.RunExecute.SetEvent();
          if ((SynchronCount > 0) and not BesideThreadWaits) then
          begin
            SyncThreadExecuted.WaitFor(INFINITE);
            DebugMonitor.Append('SyncThreadExecuted.Wait - 3 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
          end;
        end;
      ssFirst,
      ssNext:
        begin
          SyncExecute(SyncThread);
          SyncThread.SynchronCount := SynchronCount;
          SyncThread.RunExecute.SetEvent();
         if ((SynchronCount > 0) and not BesideThreadWaits) then
          begin
            SyncThreadExecuted.WaitFor(INFINITE);
            DebugMonitor.Append('SyncThreadExecuted.Wait - 4 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
          end;
        end;
      ssExecutingFirst,
      ssExecutingNext:
        begin
          SyncExecuted(SyncThread);

          if ((SyncThread.Mode = smSQL) and (SyncThread.State = ssResult)) then
            SyncHandledResult(SyncThread);

          case (SyncThread.Mode) of
            smSQL,
            smDataSet:
              case (SyncThread.State) of
                ssFirst,
                ssNext:
                  begin
                    SyncExecute(SyncThread);
                    SyncThread.RunExecute.SetEvent();
                    if ((SynchronCount > 0) and not BesideThreadWaits) then
                    begin
                      SyncThreadExecuted.WaitFor(INFINITE);
                      DebugMonitor.Append('SyncThreadExecuted.Wait - 5 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
                    end;
                  end;
                ssResult,
                ssReceivingResult,
                ssReady:
                  begin
                    if (Assigned(SyncThread.DataSet) and (SyncThread.State = ssResult)) then
                      SyncBindDataSet(SyncThread.DataSet);
                    if (BesideThreadWaits and not InOnResult) then
                    begin
                      SyncThreadExecuted.SetEvent();
                      DebugMonitor.Append('SyncThreadExecuted.Set - 2 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
                    end;
                  end;
              end;
            smResultHandle:
              if (KillThreadId > 0) then
              begin
                SyncHandledResult(SyncThread);
                KillThreadId := 0;
                Sync(SyncThread);
              end;
          end;

          if (SyncThread.State = ssAfterExecuteSQL) then
          begin
            SyncAfterExecuteSQL(SyncThread);
            if (Assigned(SyncThread.Done)) then
              SyncThread.Done.SetEvent();
          end;

          if (BesideThreadWaits
            and ((SyncThread.State in [ssReady]) or (SyncThread.Mode = smResultHandle))) then
          begin
            SyncThreadExecuted.SetEvent();
            DebugMonitor.Append('SyncThreadExecuted.Set - 3 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
          end;
        end;
      ssReceivingResult:
        begin
          if ((SyncThread.DataSet is TMySQLDataSet) and (SyncThread.ErrorCode <> 0)) then
            DoError(SyncThread.ErrorCode, SyncThread.ErrorMessage);

          SyncReleaseDataSet(SyncThread.DataSet);

          if (not InOnResult) then
            case (SyncThread.Mode) of
              smSQL,
              smDataSet:
                case (SyncThread.State) of
                  ssNext,
                  ssFirst:
                    begin
                      SyncExecute(SyncThread);
                      SyncThread.RunExecute.SetEvent();
                      if ((SynchronCount > 0) and not BesideThreadWaits) then
                      begin
                        SyncThreadExecuted.WaitFor(INFINITE);
                        DebugMonitor.Append('SyncThreadExecuted.Wait - 6 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
                      end;
                    end;
                  ssReceivingResult:
                    if (BesideThreadWaits) then
                    begin
                      SyncThreadExecuted.SetEvent();
                      DebugMonitor.Append('SyncThreadExecuted.Set - 4 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
                    end;
                  ssAfterExecuteSQL:
                    begin
                      SyncAfterExecuteSQL(SyncThread);
                      if (Assigned(SyncThread.Done)) then
                        SyncThread.Done.SetEvent();
                      if (BesideThreadWaits) then
                      begin
                        SyncThreadExecuted.SetEvent();
                        DebugMonitor.Append('SyncThreadExecuted.Set - 5 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
                      end;
                    end;
                  ssReady: ; // Do nothing - and don't report a problem
                  else raise ERangeError.Create('State: ' + IntToStr(Ord(SyncThread.State)));
                end;
              smResultHandle:
                case (SyncThread.State) of
                  ssFirst,
                  ssNext,
                  ssAfterExecuteSQL:
                    if (BesideThreadWaits) then
                    begin
                      SyncThreadExecuted.SetEvent();
                      DebugMonitor.Append('SyncThreadExecuted.Set - 6 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
                    end;
                  else raise ERangeError.Create('State: ' + IntToStr(Ord(SyncThread.State)));
                end;
            end;
        end;
      ssAfterExecuteSQL:
        begin
          SyncAfterExecuteSQL(SyncThread);
          if (Assigned(SyncThread.Done)) then
            SyncThread.Done.SetEvent();
          if (BesideThreadWaits) then
          begin
            SyncThreadExecuted.SetEvent();
            DebugMonitor.Append('SyncThreadExecuted.Set - 7 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
          end;
        end;
      ssDisconnect:
        begin
          SyncThread.State := ssDisconnecting;
          SyncThread.SynchronCount := SynchronCount;
          SyncThread.RunExecute.SetEvent();
          if ((SynchronCount > 0) and not BesideThreadWaits) then
          begin
            SyncThreadExecuted.WaitFor(1000);
            DebugMonitor.Append('SyncThreadExecuted.Wait - 7 - State: ' + IntToStr(Ord(SyncThread.State)) + ', Thread: ' + IntToStr(GetCurrentThreadId()), ttDebug);
          end;
        end;
      ssDisconnecting:
        begin
          SyncDisconnected(SyncThread);
          if (Assigned(SyncThread.Done)) then
            SyncThread.Done.SetEvent();
        end;
      else raise ERangeError.Create('State: ' + IntToStr(Ord(SyncThread.State)));
    end;

    DebugMonitor.Append('Sync - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
  end;
end;

procedure TMySQLConnection.SyncAfterExecuteSQL(const SyncThread: TSyncThread);
begin
  DebugMonitor.Append('SyncAfterExecuteSQL - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  Assert(SyncThread.State in [ssAfterExecuteSQL]);

  FExecutionTime := SyncThread.ExecutionTime;

  if (FErrorCode = 0) then
    SyncThread.SQL := '';

  DoAfterExecuteSQL();

  if (not Connected) then
    SyncThread.State := ssClose
  else
    SyncThread.State := ssReady;

  if (Assigned(CommittingDataSet)) then
  begin
    CommittingDataSet.AfterCommit();
    CommittingDataSet := nil;
  end;

  DebugMonitor.Append('SyncAfterExecuteSQL - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.SyncBeforeExecuteSQL(const SyncThread: TSyncThread);
begin
  DebugMonitor.Append('SyncBeforeExecuteSQL - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  DoBeforeExecuteSQL();

  SyncThread.State := ssFirst;

  DebugMonitor.Append('SyncBeforeExecuteSQL - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.SyncBindDataSet(const DataSet: TMySQLQuery);
begin
  DebugMonitor.Append('SyncBindDataSet - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  Assert(Assigned(DataSet));
  Assert(Assigned(SyncThread));
  Assert(SyncThread.State = ssResult, 'State: ' + IntToStr(Ord(SyncThread.State)));

  DataSet.SyncThread := SyncThread;
  SyncThread.DataSet := DataSet;

  SyncThread.FinishedReceiving := False;
  SyncThread.State := ssReceivingResult;

  if (DataSet is TMySQLDataSet) then
    SyncThread.RunExecute.SetEvent();

  DebugMonitor.Append('SyncBindDataSet - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.SyncConnecting(const SyncThread: TSyncThread);
var
  ClientFlag: my_uint;
begin
  DebugMonitor.Append('SyncConnecting - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  if (not Assigned(Lib)) then
  begin
    SyncThread.ErrorCode := ER_CANT_OPEN_LIBRARY;
    SyncThread.ErrorMessage := Format(SLibraryNotAvailable, [LibraryName]);
  end
  else
  begin
    if (not Assigned(SyncThread.LibHandle)) then
    begin
      if (Assigned(Lib.my_init)) then
        Lib.my_init();
      SyncThread.LibHandle := Lib.mysql_init(nil);
      if (Assigned(Lib.mysql_set_local_infile_handler)) then
        Lib.mysql_set_local_infile_handler(SyncThread.LibHandle, @MySQLDB.local_infile_init, @MySQLDB.local_infile_read, @MySQLDB.local_infile_end, @MySQLDB.local_infile_error, Self);
    end;

    ClientFlag := CLIENT_INTERACTIVE or CLIENT_LOCAL_FILES or CLIENT_CAN_HANDLE_EXPIRED_PASSWORDS;
    if (DatabaseName <> '') then
      ClientFlag := ClientFlag or CLIENT_CONNECT_WITH_DB;
    if (Assigned(Lib.mysql_more_results) and Assigned(Lib.mysql_next_result)) then
      ClientFlag := ClientFlag or CLIENT_MULTI_STATEMENTS or CLIENT_MULTI_RESULTS;
    if (UseCompression()) then
      ClientFlag := ClientFlag or CLIENT_COMPRESS;

    Lib.mysql_options(SyncThread.LibHandle, MYSQL_OPT_READ_TIMEOUT, my_char(RawByteString(IntToStr(NET_WAIT_TIMEOUT))));
    Lib.mysql_options(SyncThread.LibHandle, MYSQL_OPT_WRITE_TIMEOUT, my_char(RawByteString(IntToStr(NET_WAIT_TIMEOUT))));
    Lib.mysql_options(SyncThread.LibHandle, MYSQL_SET_CHARSET_NAME, my_char(RawByteString(CharsetClient)));
    if (UseCompression()) then
      Lib.mysql_options(SyncThread.LibHandle, MYSQL_OPT_COMPRESS, nil);
    if (LibraryType = ltHTTP) then
    begin
      Lib.mysql_options(SyncThread.LibHandle, enum_mysql_option(MYSQL_OPT_HTTPTUNNEL_URL), my_char(LibEncode(CodePageClient, LibraryName)));
      if (HTTPAgent <> '') then
        Lib.mysql_options(SyncThread.LibHandle, enum_mysql_option(MYSQL_OPT_HTTPTUNNEL_AGENT), my_char(LibEncode(CodePageClient, HTTPAgent)));
    end;

    if (Host <> LOCAL_HOST_NAMEDPIPE) then
      Lib.mysql_real_connect(SyncThread.LibHandle,
        my_char(LibEncode(CodePageClient, Host)),
        my_char(LibEncode(CodePageClient, Username)), my_char(LibEncode(CodePageClient, Password)),
        my_char(LibEncode(CodePageClient, DatabaseName)), Port, '', ClientFlag)
    else
    begin
      Lib.mysql_options(SyncThread.LibHandle, enum_mysql_option(MYSQL_OPT_NAMED_PIPE), nil);
      Lib.mysql_real_connect(SyncThread.LibHandle,
        my_char(LOCAL_HOST),
        my_char(LibEncode(CodePageClient, Username)), my_char(LibEncode(CodePageClient, Password)),
        my_char(LibEncode(CodePageClient, DatabaseName)), Port, MYSQL_NAMEDPIPE, ClientFlag);
    end;

    if ((Lib.mysql_errno(SyncThread.LibHandle) <> 0) or (Lib.LibraryType = ltHTTP)) then
      SyncThread.LibThreadId := 0
    else
      SyncThread.LibThreadId := Lib.mysql_thread_id(SyncThread.LibHandle);

    SyncThread.ErrorCode := Lib.mysql_errno(SyncThread.LibHandle);
    SyncThread.ErrorMessage := GetErrorMessage(SyncThread.LibHandle);

    if ((SyncThread.ErrorCode = 0)
      and Assigned(Lib.mysql_set_character_set)
      and (Lib.mysql_get_server_version(SyncThread.LibHandle) >= 50503)
      and (AnsiStrings.StrIComp(Lib.mysql_character_set_name(SyncThread.LibHandle), 'utf8') = 0)) then
      Lib.mysql_set_character_set(SyncThread.LibHandle, 'utf8mb4');

    if (SyncThread.ErrorCode > 0) then
      SyncDisconnecting(SyncThread);
  end;

  DebugMonitor.Append('SyncConnecting - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.SyncConnected(const SyncThread: TSyncThread);
var
  I: Integer;
  S: string;
begin
  DebugMonitor.Append('SyncConnected - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  FConnected := SyncThread.ErrorCode = 0;
  FErrorCode := SyncThread.ErrorCode;
  FErrorMessage := SyncThread.ErrorMessage;
  FThreadId := SyncThread.LibThreadId;

  if (FErrorCode > 0) then
    DoError(FErrorCode, FErrorMessage)
  else
  begin
    FLatestConnect := Now();

    if ((ServerVersionStr = '') and (Lib.mysql_get_server_info(SyncThread.LibHandle) <> '')) then
    begin
      FServerVersionStr := string(Lib.mysql_get_server_info(SyncThread.LibHandle));
      if (Assigned(Lib.mysql_get_server_version)) then
        FMySQLVersion := Lib.mysql_get_server_version(SyncThread.LibHandle)
      else
      begin
        S := FServerVersionStr;
        if (Pos('-', S) > 0) then
          S := LeftStr(S, Pos('-', S) - 1);
        if ((Pos('.', S) = 0) or not TryStrToInt(LeftStr(S, Pos('.', S) - 1), I)) then
          FMySQLVersion := 0
        else
        begin
          FMySQLVersion := I * 10000;
          Delete(S, 1, Pos('.', S));
          if ((Pos('.', S) = 0) or not TryStrToInt(LeftStr(S, Pos('.', S) - 1), I)) then
            FMySQLVersion := 0
          else
          begin
            FMySQLVersion := FMySQLVersion + I * 100;
            Delete(S, 1, Pos('.', S));
            if (not TryStrToInt(S, I)) then
              FMySQLVersion := 0
            else
            begin
              FMySQLVersion := FMySQLVersion + I;
              Delete(S, 1, Pos('.', S));
            end;
          end;
        end;
      end;

      S := FServerVersionStr;
      if (Pos('-MariaDB', S) > 0) then
      begin
        S := LeftStr(S, Pos('-MariaDB', S) - 1);
        if (Pos('-', S) > 0) then
          Delete(S, 1, Pos('-', S));
        if ((Pos('.', S) = 0) or not TryStrToInt(LeftStr(S, Pos('.', S) - 1), I)) then
          FMariaDBVersion := 0
        else
        begin
          FMariaDBVersion := I * 10000;
          Delete(S, 1, Pos('.', S));
          if ((Pos('.', S) = 0) or not TryStrToInt(LeftStr(S, Pos('.', S) - 1), I)) then
            FMariaDBVersion := 0
          else
          begin
            FMariaDBVersion := FMariaDBVersion + I * 100;
            Delete(S, 1, Pos('.', S));
            TryStrToInt(S, I);
            FMariaDBVersion := FMariaDBVersion + I;
            Delete(S, 1, Pos('.', S));
          end;
        end;
      end;
    end;

    if ((0 < MySQLVersion) and (MySQLVersion < 32320)) then
      DoError(DS_SERVER_OLD, StrPas(DATASET_ERRORS[DS_SERVER_OLD - DS_MIN_ERROR]))
    else
    begin
      if ((MySQLVersion < 40101) or not Assigned(Lib.mysql_character_set_name)) then
        FCharsetClient := 'latin1'
      else
        FCharsetClient := string(Lib.mysql_character_set_name(SyncThread.LibHandle));
      FCodePageClient := CharsetToCodePage(FCharsetClient);
      FCharsetResult := FCharsetClient;
      FCodePageResult := FCodePageResult;

      // Debug 2017-05-25
      Assert(FCodePageClient <> 0,
        'FCharsetClient: ' + FCharsetClient);

      FHostInfo := LibDecode(CodePageResult, Lib.mysql_get_host_info(SyncThread.LibHandle));
      FMultiStatements := FMultiStatements and Assigned(Lib.mysql_more_results) and Assigned(Lib.mysql_next_result) and ((MySQLVersion > 40100) or (Lib.LibraryType = ltHTTP)) and not ((50000 <= MySQLVersion) and (MySQLVersion < 50007));
    end;
  end;

  if (not Connected) then
    SyncThread.State := ssClose
  else
    SyncThread.State := ssReady;

  if (Connected) then
  begin
    if (Assigned(FSQLParser)) then
      FSQLParser.Free();
    FSQLParser := TSQLParser.Create(MySQLVersion);
  end;

  if (Connected) then
    SendConnectEvent(True);
  if (Assigned(AfterConnect)) then
    AfterConnect(Self);

  DebugMonitor.Append('SyncConnected - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.SyncDisconnecting(const SyncThread: TSyncThread);
begin
  DebugMonitor.Append('SyncDisconnecting - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  Assert(Assigned(SyncThread.LibHandle));

  if (Assigned(SyncThread.LibHandle)) then
  begin
    Lib.mysql_close(SyncThread.LibHandle);
    SyncThread.LibHandle := nil;
  end;

  DebugMonitor.Append('SyncDisconnecting - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.SyncDisconnected(const SyncThread: TSyncThread);
begin
  DebugMonitor.Append('SyncDisconnected - start', ttDebug);

  FThreadId := 0;
  FConnected := False;

  if (Assigned(SyncThread)) then
    SyncThread.State := ssClose;

  if (Assigned(AfterDisconnect)) then AfterDisconnect(Self);

  DebugMonitor.Append('SyncDisconnected - end', ttDebug);
end;

procedure TMySQLConnection.SyncExecute(const SyncThread: TSyncThread);
var
  StmtLength: Integer;
begin
  DebugMonitor.Append('SyncExecute - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  Assert(SyncThread.State in [ssFirst, ssNext], 'State: ' + IntToStr(Ord(SyncThread.State)));

  if (SyncThread.State = ssFirst) then
    WriteMonitor('# ' + SysUtils.DateTimeToStr(GetServerTime(), FormatSettings), ttTime);

  if (SyncThread.StmtIndex < SyncThread.StmtLengths.Count) then
  begin
    StmtLength := SyncThread.StmtLengths[SyncThread.StmtIndex];
    WriteMonitor(@SyncThread.SQL[SyncThread.SQLIndex], StmtLength, ttRequest);
  end;

  SyncThread.FinishedReceiving := False;
  case (SyncThread.State) of
    ssFirst: SyncThread.State := ssExecutingFirst;
    ssNext: SyncThread.State := ssExecutingNext;
    else raise ERangeError.Create('State: ' + IntToStr(Ord(SyncThread.State)));
  end;

  DebugMonitor.Append('SyncExecute - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.SyncExecuted(const SyncThread: TSyncThread);
var
  CLStmt: TSQLCLStmt;
  Data: my_char;
  DataHandle: TDataHandle;
  Info: my_char;
  Name: string;
  Size: size_t;
  S: string;
  Value: string;
begin
  DebugMonitor.Append('SyncExecuted - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  Assert(SyncThread = Self.SyncThread);
  Assert(SyncThread.State in [ssExecutingFirst, ssExecutingNext]);

  FErrorCode := SyncThread.ErrorCode;
  FErrorMessage := SyncThread.ErrorMessage;
  Inc(FWarningCount, SyncThread.WarningCount);
  FThreadId := SyncThread.LibThreadId;

  if (SyncThread.StmtIndex < SyncThread.StmtLengths.Count) then
    WriteMonitor(@SyncThread.SQL[SyncThread.SQLIndex], SyncThread.StmtLengths[SyncThread.StmtIndex], ttResult);

  if (SyncThread.ErrorCode > 0) then
    WriteMonitor('--> Error #' + IntToStr(SyncThread.ErrorCode) + ': ' + SyncThread.ErrorMessage, ttInfo)
  else if (Assigned(SyncThread.LibHandle)) then
  begin
    Inc(FExecutedStmts);

    if (SyncThread.WarningCount > 0) then
      WriteMonitor('--> Warnings: ' + IntToStr(SyncThread.WarningCount), ttInfo);

    if (Assigned(Lib.mysql_session_track_get_first) and Assigned(Lib.mysql_session_track_get_next)) then
      if (Lib.mysql_session_track_get_first(SyncThread.LibHandle, SESSION_TRACK_SYSTEM_VARIABLES, Data, Size) = 0) then
        repeat
          Name := LibDecode(CodePageResult, Data, Size);
          if (Lib.mysql_session_track_get_next(SyncThread.LibHandle, SESSION_TRACK_SYSTEM_VARIABLES, Data, Size) = 0) then
          begin
            Value := LibDecode(CodePageResult, Data, Size);
            DoVariableChange(Name, Value);
          end;
        until (Lib.mysql_session_track_get_next(SyncThread.LibHandle, SESSION_TRACK_SYSTEM_VARIABLES, Data, Size) <> 0);

    if ((SyncThread.StmtIndex < Length(SyncThread.CLStmts)) and SyncThread.CLStmts[SyncThread.StmtIndex]) then
    begin
      if ((SyncThread.StmtIndex < SyncThread.StmtLengths.Count)
        and (SQLParseCLStmt(CLStmt, @SyncThread.SQL[SyncThread.SQLIndex], SyncThread.StmtLengths[SyncThread.StmtIndex], MySQLVersion))) then
        if ((CLStmt.CommandType = ctDropDatabase) and (CLStmt.ObjectName = DatabaseName)) then
        begin
          WriteMonitor('--> Database unselected', ttInfo);
          DoDatabaseChange('');
        end
        else if ((CLStmt.CommandType = ctUse) and (CLStmt.ObjectName <> FDatabaseName)) then
        begin
          WriteMonitor('--> Database selected: ' + CLStmt.ObjectName, ttInfo);
          DoDatabaseChange(CLStmt.ObjectName);
        end
        else if (CLStmt.CommandType = ctShutdown) then
          WriteMonitor('--> Server is going down', ttInfo)
        else
          WriteMonitor('--> Ok', ttInfo);
    end
    else if (not Assigned(SyncThread.ResHandle)) then
    begin
      if (Lib.mysql_affected_rows(SyncThread.LibHandle) >= 0) then
      begin
        if (FRowsAffected < 0) then FRowsAffected := 0;
        Inc(FRowsAffected, Lib.mysql_affected_rows(SyncThread.LibHandle));
      end;

      if (Assigned(Lib.mysql_info) and Assigned(Lib.mysql_info(SyncThread.LibHandle))) then
      begin
        Info := Lib.mysql_info(SyncThread.LibHandle);
        try
          S := '--> ' + LibDecode(CodePageResult, Info);
        except
          S := '--> ' + string(AnsiStrings.StrPas(Info));
        end;
        WriteMonitor(PChar(S), Length(S), ttInfo);
      end
      else if (Lib.mysql_affected_rows(SyncThread.LibHandle) > 0) then
        WriteMonitor('--> ' + IntToStr(Lib.mysql_affected_rows(SyncThread.LibHandle)) + ' Record(s) affected', ttInfo)
      else
        WriteMonitor('--> Ok', ttInfo);
    end;
  end;

  CountSQLLength := (SyncThread.ErrorCode = 0) and (KillThreadId = 0);

  if (not Assigned(SyncThread.OnResult) or (KillThreadId > 0) and (SyncThread.Mode <> smResultHandle)) then
  begin
    if (KillThreadId > 0) then
    begin
      KillThreadId := 0;
      SyncThread.State := ssResult;
      SyncHandledResult(SyncThread);
    end
    else if (SyncThread.ErrorCode > 0) then
    begin
      DoError(SyncThread.ErrorCode, SyncThread.ErrorMessage);
      SyncThread.State := ssAfterExecuteSQL;
      SyncHandledResult(SyncThread);
    end
    else if ((SyncThread.Mode = smSQL) and Assigned(SyncThread.ResHandle)) then
    begin
      SyncThread.FinishedReceiving := False;
      SyncThread.State := ssReceivingResult;
      while (Assigned(Lib.mysql_fetch_row(SyncThread.ResHandle))) do ;
      SyncHandledResult(SyncThread);
    end
    else
      SyncThread.State := ssResult;
  end
  else
  begin
    InOnResult := True;
    try
      if (SyncThread.ErrorCode <> 0) then
      begin
        DataHandle := nil;
        SyncThread.State := ssAfterExecuteSQL;
      end
      else
      begin
        DataHandle := SyncThread;
        SyncThread.State := ssResult;
      end;

      if (not SyncThread.OnResult(SyncThread.ErrorCode, SyncThread.ErrorMessage, SyncThread.WarningCount,
        SyncThread.CommandText, DataHandle, Assigned(SyncThread.ResHandle))
        and (SyncThread.ErrorCode > 0)
        and (not Assigned(SyncThread.DataSet) or not (SyncThread.DataSet is TMySQLDataSet))) then
      begin
        DoError(SyncThread.ErrorCode, SyncThread.ErrorMessage);
        SyncThread.State := ssAfterExecuteSQL;
        SyncHandledResult(SyncThread);
      end
      else if ((SyncThread.State = ssResult) and Assigned(SyncThread.ResHandle)) then
        if (SyncThread.CommandText = '') then
          raise EAssertionFailed.Create('Query has not been handled')
        else
          raise EAssertionFailed.Create('Query has not been handled: ' + SyncThread.CommandText);
    finally
      InOnResult := False;
    end;
  end;

  DebugMonitor.Append('SyncExecuted - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.SyncExecutingFirst(const SyncThread: TSyncThread);
var
  AlterTableAfterCreateTable: Boolean;
  CreateTableInPacket: Boolean;
  DDLStmt: TSQLDDLStmt;
  LibLength: Integer;
  LibSQL: RawByteString;
  NeedReconnect: Boolean;
  PacketComplete: (pcNo, pcExclusiveStmt, pcInclusiveStmt);
  PacketLength: Integer;
  ProcedureName: string;
  ResetPassword: Boolean;
  Retry: Integer;
  SQL: PChar;
  SQLIndex: Integer;
  StartTime: TDateTime;
  Stmt: RawByteString;
  StmtIndex: Integer;
  StmtLength: Integer;
  Success: Boolean;
begin
  DebugMonitor.Append('SyncExecutingFirst - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  Assert(SyncThread.State = ssExecutingFirst);

  CreateTableInPacket := False; AlterTableAfterCreateTable := False;
  PacketLength := 0; PacketComplete := pcNo;
  StmtIndex := SyncThread.StmtIndex; SQLIndex := SyncThread.SQLIndex;
  while ((StmtIndex < SyncThread.StmtLengths.Count) and (PacketComplete = pcNo)) do
  begin
    SQL := @SyncThread.SQL[SQLIndex];
    StmtLength := SyncThread.StmtLengths[StmtIndex];

    if (MySQLVersion <= 50100) then
      if (not CreateTableInPacket) then
        CreateTableInPacket := SQLParseDDLStmt(DDLStmt, SQL, StmtLength, MySQLVersion) and (DDLStmt.DefinitionType = dtCreate) and (DDLStmt.ObjectType = otTable)
      else
        AlterTableAfterCreateTable := SQLParseDDLStmt(DDLStmt, SQL, StmtLength, MySQLVersion) and (DDLStmt.DefinitionType = dtAlter) and (DDLStmt.ObjectType = otTable);

    if (AlterTableAfterCreateTable) then
      PacketComplete := pcExclusiveStmt
    else if ((StmtLength = 9) and (StrLIComp(SQL, 'SHUTDOWN;', 9) = 0) and (MySQLVersion < 50709)) then
      PacketComplete := pcExclusiveStmt
    else if ((SizeOf(COM_QUERY) + SQLIndex - 1 + StmtLength > MaxAllowedServerPacket)
      and (SizeOf(COM_QUERY) + WideCharToAnsiChar(CodePageClient, PChar(@SyncThread.SQL[SQLIndex]), StmtLength, nil, 0) > MaxAllowedServerPacket)) then
      PacketComplete := pcExclusiveStmt
    else if (not MultiStatements or (SQLIndex - 1 + StmtLength = Length(SyncThread.SQL))) then
      PacketComplete := pcInclusiveStmt
    else if (SQLParseCallStmt(SQL, StmtLength, ProcedureName, MySQLVersion) and (ProcedureName <> '')) then
      PacketComplete := pcInclusiveStmt
    else
      PacketComplete := pcNo;

    if ((PacketLength = 0) or (PacketComplete in [pcNo, pcInclusiveStmt])) then
      Inc(PacketLength, StmtLength);

    Inc(StmtIndex);
    Inc(SQLIndex, StmtLength);
  end;

  LibLength := WideCharToAnsiChar(CodePageClient, PChar(@SyncThread.SQL[SyncThread.SQLIndex]), PacketLength, nil, 0);
  SetLength(LibSQL, LibLength);
  WideCharToAnsiChar(CodePageClient, PChar(@SyncThread.SQL[SyncThread.SQLIndex]), PacketLength, PAnsiChar(LibSQL), LibLength);

  if (not MultiStatements) then
    while ((LibLength > 0) and (LibSQL[LibLength] in [#9, #10, #13, ' ', ';'])) do
      Dec(LibLength);

  Retry := 0; NeedReconnect := not Assigned(SyncThread.LibHandle);
  repeat
    if (not NeedReconnect) then
      Success := True
    else
    begin
      SyncConnecting(SyncThread);
      Success := Assigned(SyncThread.LibHandle) and (SyncThread.ErrorCode = 0);
      NeedReconnect := not Assigned(SyncThread.LibHandle) or ConnectionLost(SyncThread.ErrorCode);
    end;
    ResetPassword := False;

    if (not SyncThread.Terminated and Success) then
    begin
      if ((LibLength = 8) and (AnsiStrings.StrLIComp(my_char(LibSQL), 'SHUTDOWN', 8) = 0) and (MySQLVersion < 50709) and Assigned(Lib.mysql_shutdown)
        or (LibLength = 9) and (AnsiStrings.StrLIComp(my_char(LibSQL), 'SHUTDOWN;', 9) = 0) and (MySQLVersion < 50709) and Assigned(Lib.mysql_shutdown)) then
        Lib.mysql_shutdown(SyncThread.LibHandle, SHUTDOWN_DEFAULT)
      else
      begin
        StartTime := Now();
        Lib.mysql_real_query(SyncThread.LibHandle, my_char(LibSQL), LibLength);
        SyncThread.ExecutionTime := SyncThread.ExecutionTime + Now() - StartTime;
      end;

      if (Lib.mysql_errno(SyncThread.LibHandle) = ER_MUST_CHANGE_PASSWORD) then
      begin
        Stmt := LibEncode(CodePageClient, 'SET PASSWORD=Password(' + SQLEscape(Password) + ')');
        ResetPassword := Lib.mysql_real_query(SyncThread.LibHandle, my_char(Stmt), Length(Stmt)) = 0;
      end
      else
      begin
        NeedReconnect := not Assigned(SyncThread.LibHandle)
          or ConnectionLost(Lib.mysql_errno(SyncThread.LibHandle));
      end;
    end;

    Inc(Retry);
  until ((not ResetPassword and not NeedReconnect) or (Retry > RETRY_COUNT));

  if (Assigned(SyncThread.LibHandle)) then
  begin
    if ((Lib.mysql_errno(SyncThread.LibHandle) = 0) and not SyncThread.Terminated) then
      SyncThread.ResHandle := Lib.mysql_use_result(SyncThread.LibHandle);

    SyncThread.ErrorCode := Lib.mysql_errno(SyncThread.LibHandle);
    SyncThread.ErrorMessage := GetErrorMessage(SyncThread.LibHandle);
    if ((MySQLVersion < 40100) or not Assigned(Lib.mysql_warning_count)) then
      SyncThread.WarningCount := 0
    else
      SyncThread.WarningCount := Lib.mysql_warning_count(SyncThread.LibHandle);
  end;

  DebugMonitor.Append('SyncExecutingFirst - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.SyncExecutingNext(const SyncThread: TSyncThread);
var
  StartTime: TDateTime;
begin
  DebugMonitor.Append('SyncExecutingNext - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  Assert(SyncThread.State = ssExecutingNext);

  StartTime := Now();
  Lib.mysql_next_result(SyncThread.LibHandle);
  SyncThread.ExecutionTime := SyncThread.ExecutionTime + Now() - StartTime;

  if (SyncThread.ErrorCode = 0) then
    SyncThread.ResHandle := Lib.mysql_use_result(SyncThread.LibHandle);

  SyncThread.ErrorCode := Lib.mysql_errno(SyncThread.LibHandle);
  SyncThread.ErrorMessage := GetErrorMessage(SyncThread.LibHandle);
  if ((MySQLVersion < 40100) or not Assigned(Lib.mysql_warning_count)) then
    SyncThread.WarningCount := 0
  else
    SyncThread.WarningCount := Lib.mysql_warning_count(SyncThread.LibHandle);

  DebugMonitor.Append('SyncExecutingNext - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.SyncHandledResult(const SyncThread: TSyncThread);
begin
  DebugMonitor.Append('SyncHandledResult - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  Assert((SyncThread.State in [ssReceivingResult, ssAfterExecuteSQL]) or (SyncThread.State = ssResult) and not Assigned(SyncThread.ResHandle));

  if (SyncThread.State = ssReceivingResult) then
  begin
    WriteMonitor('--> ' + IntToStr(Lib.mysql_num_rows(SyncThread.ResHandle)) + ' Record(s) received', ttInfo);

    Lib.mysql_free_result(SyncThread.ResHandle);
    SyncThread.ResHandle := nil;

    if (SyncThread.ErrorCode > 0) then
      WriteMonitor('--> Error #' + IntToStr(FErrorCode) + ': ' + FErrorMessage + ' while receiving Record(s)', ttInfo);
  end;


  if (SyncThread.StmtIndex < SyncThread.StmtLengths.Count) then
  begin
    if (CountSQLLength) then
      Inc(FSuccessfullExecutedSQLLength, SyncThread.StmtLengths[SyncThread.StmtIndex]);
    Inc(SyncThread.SQLIndex, SyncThread.StmtLengths[SyncThread.StmtIndex]);
    Inc(SyncThread.StmtIndex);
  end;

  if (SyncThread.State = ssAfterExecuteSQL) then
    // An error occurred and it was NOT handled in OnResult
  else if (SyncThread.ErrorCode = CR_SERVER_GONE_ERROR) then
    SyncThread.State := ssAfterExecuteSQL
  else if (MultiStatements and Assigned(SyncThread.LibHandle) and (Lib.mysql_more_results(SyncThread.LibHandle) = 1)) then
    SyncThread.State := ssNext
  else if (SyncThread.StmtIndex < SyncThread.StmtLengths.Count) then
    SyncThread.State := ssFirst
  else
    SyncThread.State := ssAfterExecuteSQL;

  DebugMonitor.Append('SyncHandledResult - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.SyncPing(const SyncThread: TSyncThread);
begin
  if ((Lib.LibraryType <> ltHTTP) and Assigned(SyncThread.LibHandle)) then
    Lib.mysql_ping(SyncThread.LibHandle);
end;

procedure TMySQLConnection.SyncReceivingResult(const SyncThread: TSyncThread);
var
  DataSet: TMySQLQuery;
  LibRow: MYSQL_ROW;
  OldDataSize: Int64;
begin
  DebugMonitor.Append('SyncReceivingResult - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  Assert(SyncThread.State = ssReceivingResult);
  Assert(SyncThread.DataSet is TMySQLDataSet);
  Assert(Assigned(SyncThread.ResHandle));

  DataSet := TMySQLQuery(SyncThread.DataSet);

  OldDataSize := 0;
  repeat
    if (SyncThread.Terminated) then
      LibRow := nil
    else
    begin
      LibRow := Lib.mysql_fetch_row(SyncThread.ResHandle);
      SyncThread.FinishedReceiving := not Assigned(LibRow);

      TerminateCS.Enter();
      if (not SyncThread.Terminated) then
      begin
        if (Lib.mysql_errno(SyncThread.LibHandle) <> 0) then
        begin
          SyncThread.ErrorCode := Lib.mysql_errno(SyncThread.LibHandle);
          SyncThread.ErrorMessage := GetErrorMessage(SyncThread.LibHandle);
        end
        else if (not DataSet.InternAddRecord(LibRow, Lib.mysql_fetch_lengths(SyncThread.ResHandle))) then
        begin
          SyncThread.ErrorCode := DS_OUT_OF_MEMORY;
          SyncThread.ErrorMessage := StrPas(DATASET_ERRORS[DS_OUT_OF_MEMORY - DS_MIN_ERROR]);
        end
        else if ((DataSet is TMySQLDataSet) and (TMySQLDataSet(DataSet).DataSize >= OldDataSize + 10 * 1024)) then
        begin
          DataSet.RecordReceived.SetEvent();
          OldDataSize := TMySQLDataSet(DataSet).DataSize;
        end;

        case (TMySQLDataSet(DataSet).WantedRecord) of
          wrFirst,
          wrNext:
            begin
              TMySQLDataSet(DataSet).WantedRecord := wrNone;
              MySQLConnectionOnSynchronize(DataSet, 1);
            end;
        end;
      end;

      TerminateCS.Leave();
    end;
  until (not Assigned(LibRow) or (SyncThread.ErrorCode <> 0));

  TerminateCS.Enter();
  if (SyncThread.Terminated) then
    DataSet.SyncThread := nil
  else
  begin
    if (DataSet is TMySQLTable) then
      TMySQLTable(DataSet).FLimitedDataReceived := Lib.mysql_num_rows(SyncThread.ResHandle) = TMySQLTable(DataSet).RequestedRecordCount;

    DataSet.RecordsReceived.SetEvent();
    DataSet.RecordReceived.SetEvent(); // Release possible waiting thread
  end;
  TerminateCS.Leave();

  DebugMonitor.Append('SyncReceivingResult - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.SyncReleaseDataSet(const DataSet: TMySQLQuery);
begin
  DebugMonitor.Append('SyncReleaseDataSet - start - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);

  Assert(Assigned(DataSet));

  if (DataSet.SyncThread = SyncThread) then
  begin
    Assert(Assigned(SyncThread));

    DebugMonitor.Append('SyncReleaseDataSet - ' + DataSet.SyncThread.CommandText, ttDebug);

    SyncThread.DataSet := nil;

    TerminateCS.Enter();
    if (not SyncThread.Terminated and (SyncThread.State = ssReceivingResult)) then
    begin
      SyncHandledResult(SyncThread);

      if ((DataSet is TMySQLDataSet) and (TMySQLDataSet(DataSet).WantedRecord = wrLast)) then
        DataSet.Last();
    end;
    TerminateCS.Leave();
  end;

  DataSet.SyncThread := nil;

  DebugMonitor.Append('SyncReleaseDataSet - end - State: ' + IntToStr(Ord(SyncThread.State)), ttDebug);
end;

procedure TMySQLConnection.Terminate();
begin
  TerminateCS.Enter();

  if (Assigned(SyncThread) and SyncThread.IsRunning) then
  begin
    if (MySQLDataSets.IndexOf(CommittingDataSet) >= 0) then
      CommittingDataSet.DataEvent(deCommitted, NativeInt(True));

    KillThreadId := SyncThread.LibThreadId;

    {$IFDEF Debug}
      MessageBox(0, 'Terminate!', 'Warning', MB_OK + MB_ICONWARNING);
    {$ENDIF}

    MySQLSyncThreads.Delete(MySQLSyncThreads.IndexOf(SyncThread));

    SyncThread.Terminate();

    if (GetCurrentThreadId() = MainThreadID) then
      DebugMonitor.Append('--> Connection terminated!', ttInfo);

    {$IFDEF EurekaLog}
      SetEurekaLogStateInThread(SyncThread.ThreadID, False);
    {$ENDIF}

    TerminatedThreads.Add(SyncThread);

    Self.FSyncThread := nil;
  end;

  TerminateCS.Leave();
end;

procedure TMySQLConnection.UnRegisterSQLMonitor(const SQLMonitor: TMySQLMonitor);
begin
  if (FSQLMonitors.IndexOf(SQLMonitor) >= 0) then
    FSQLMonitors.Delete(FSQLMonitors.IndexOf(SQLMonitor));
end;

function TMySQLConnection.UseCompression(): Boolean;
begin
  Result := (Host <> LOCAL_HOST_NAMEDPIPE) or (LibraryType = ltHTTP);
end;

procedure TMySQLConnection.WriteMonitor(const Text: string; const TraceType: TMySQLMonitor.TTraceType);
begin
  WriteMonitor(PChar(Text), Length(Text), TraceType);
end;

procedure TMySQLConnection.WriteMonitor(const Text: PChar; const Length: Integer; const TraceType: TMySQLMonitor.TTraceType);
var
  I: Integer;
begin
  InMonitor := True;
  try
    for I := 0 to FSQLMonitors.Count - 1 do
      if (TraceType in TMySQLMonitor(FSQLMonitors[I]).TraceTypes) then
        TMySQLMonitor(FSQLMonitors[I]).Append(Text, Length, TraceType);
  finally
    InMonitor := False;
  end;
end;

{ TMySQLBitField **************************************************************}

function TMySQLBitField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLBitField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLBitField.GetText(var Text: string; DisplayText: Boolean);
var
  FmtStr: string;
  L: Largeint;
begin
  if (not GetValue(L)) then
    Text := ''
  else
  begin
    if (DisplayText or (EditFormat = '')) then
      FmtStr := DisplayFormat
    else
      FmtStr := EditFormat;
    while ((Length(FmtStr) > 0) and (FmtStr[1] = '#')) do Delete(FmtStr, 1, 1);
    Text := IntToBitString(L, Length(FmtStr));
  end;
end;

procedure TMySQLBitField.SetAsString(const Value: string);
var
  Error: Boolean;
  L: LargeInt;
begin
  L := BitStringToInt(PChar(Value), Length(Value), @Error);
  if (Error) then
    raise EConvertError.CreateFmt(SInvalidBinary, [Value])
  else
    SetAsLargeInt(L);
end;

{ TMySQLBlobField *************************************************************}

function TMySQLBlobField.GetAsAnsiString(): AnsiString;
begin
  SetLength(Result, TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  if (TMySQLQuery(DataSet).LibLengths^[FieldNo - 1] > 0) then
    MoveMemory(@Result[1], TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
end;

function TMySQLBlobField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLBlobField.GetAsVariant(): Variant;
begin
  if (IsNull) then
    Result := Null
  else
    Result := GetAsString();
end;

function TMySQLBlobField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLBlobField.GetText(var Text: string; DisplayText: Boolean);
begin
  if (IsNull) then
    Text := ''
  else
    Text := string(GetAsAnsiString);
end;

procedure TMySQLBlobField.SetAsString(const Value: string);
begin
  if (Length(Value) > 0) then
    inherited SetAsString(Value)
  else
    with DataSet.CreateBlobStream(Self, bmWrite) do
      try
        Write(Value, 0);
      finally
        Free();
      end;
end;

{ TMySQLByteField *************************************************************}

function TMySQLByteField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLByteField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLByteField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

{ TMySQLDateField *************************************************************}

function TMySQLDateField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLDateField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLDateField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

procedure TMySQLDateField.SetAsString(const Value: string);
begin
  try
    AsDateTime := MySQLDB.StrToDate(Value, TMySQLQuery(DataSet).Connection.FormatSettings);
  except
    on E: EConvertError do
      TMySQLQuery(DataSet).Connection.DoConvertError(Self, Value, E);
  end;
end;

procedure TMySQLDateField.SetDataSet(ADataSet: TDataSet);
begin
  inherited;

  ZeroDateString := GetZeroDateString(TMySQLQuery(DataSet).Connection.FormatSettings);

  if (DataSet is TMySQLQuery) then
    ValidChars := ['0'..'9', TMySQLConnection(TMySQLQuery(DataSet).Connection).FormatSettings.DateSeparator]
  else
    ValidChars := ['0'..'9', '-'];
end;

{ TMySQLDateTimeField *********************************************************}

function TMySQLDateTimeField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLDateTimeField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLDateTimeField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

procedure TMySQLDateTimeField.SetAsString(const Value: string);
begin
   if (Value = '') then
    AsDateTime := -1
  else
    AsDateTime := MySQLDB.StrToDateTime(Value, TMySQLQuery(DataSet).Connection.FormatSettings);
end;

procedure TMySQLDateTimeField.SetDataSet(ADataSet: TDataSet);
begin
  inherited;

  if (DataSet is TMySQLQuery) then
    ValidChars := ['0'..'9', ' ', TMySQLConnection(TMySQLQuery(DataSet).Connection).FormatSettings.DateSeparator, TMySQLConnection(TMySQLQuery(DataSet).Connection).FormatSettings.TimeSeparator]
  else
    ValidChars := ['0'..'9', ' ', '-', ':'];

  ZeroDateString := GetZeroDateString(TMySQLQuery(DataSet).Connection.FormatSettings);
end;

{ TMySQLExtendedField *********************************************************}

function TMySQLExtendedField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLExtendedField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLExtendedField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

{ TMySQLFloatField ************************************************************}

function TMySQLFloatField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLFloatField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLFloatField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

{ TMySQLIntegerField **********************************************************}

function TMySQLIntegerField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLIntegerField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLIntegerField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

{ TMySQLLargeintField *********************************************************}

function TMySQLLargeintField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLLargeintField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLLargeintField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

{ TMySQLLargeWordField ********************************************************}

procedure TMySQLLargeWordField.CheckRange(Value, Min, Max: UInt64);
begin
  if ((Value < Min) or (Value > Max)) then RangeError(Value, Min, Max);
end;

function TMySQLLargeWordField.GetAsLargeInt(): Largeint;
begin
  Result := StrToUInt64(AsString);
end;

function TMySQLLargeWordField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLLargeWordField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLLargeWordField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

procedure TMySQLLargeWordField.SetAsLargeInt(Value: Largeint);
begin
  if (FMinValue <> 0) or (FMaxValue <> 0) then
    CheckRange(UInt64(Value), UInt64(FMinValue), UInt64(FMaxValue));
  SetData(BytesOf(@Value, SizeOf(Value)));
end;

procedure TMySQLLargeWordField.SetAsString(const Value: string);
begin
  if (Value = '') then
    Clear()
  else
    SetAsLargeint(StrToUInt64(Value));
end;

{ TMySQLLongWordField *********************************************************}

function TMySQLLongWordField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLLongWordField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLLongWordField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

{ TMySQLShortIntField *********************************************************}

function TMySQLShortIntField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLShortIntField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLShortIntField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

{ TMySQLSingleField ***********************************************************}

function TMySQLSingleField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLSingleField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLSingleField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

{ TMySQLSmallIntField *********************************************************}

function TMySQLSmallIntField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLSmallIntField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLSmallIntField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

{ TMySQLStringField ***********************************************************}

function TMySQLStringField.GetAsAnsiString(): AnsiString;
begin
  if (IsNull) then
    Result := ''
  else
    SetString(Result, TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
end;

function TMySQLStringField.GetAsString(): string;
var
  Msg: string;
begin
  if (IsNull) then
    Result := ''
  else
  try
    Result := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

function TMySQLStringField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLStringField.GetText(var Text: string; DisplayText: Boolean);
begin
  Text := string(GetAsAnsiString());
end;

procedure TMySQLStringField.SetAsString(const Value: string);
begin
  if (Value <> AsString) then
  begin
    TMySQLDataSet(DataSet).SetFieldData(Self, PAnsiChar(RawByteString(Value)), Length(Value));
    TMySQLDataSet(DataSet).DataEvent(deFieldChange, Longint(Self));
  end;
end;

{ TMySQLTimeField *************************************************************}

function TMySQLTimeField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLTimeField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLTimeField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

procedure TMySQLTimeField.SetDataSet(ADataSet: TDataSet);
begin
  inherited;

  if (DataSet is TMySQLQuery) then
    ValidChars := ['-', '0'..'9', TMySQLConnection(TMySQLQuery(DataSet).Connection).FormatSettings.TimeSeparator]
  else
    ValidChars := ['-', '0'..'9', ':'];
end;

{ TMySQLTimeStampField ********************************************************}

function TMySQLTimeStampField.GetAsSQLTimeStamp(): TSQLTimeStamp;
var
  Data: TValueBuffer;
begin
  SetLength(Data, SizeOf(TSQLTimeStamp));
  if (not GetData(Data)) then
    Result := NULLSQLTimeStamp
  else
    Result := TSQLTimeStamp((@Data[0])^);
end;

function TMySQLTimeStampField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLTimeStampField.GetAsVariant: Variant;
var
  Data: TValueBuffer;
begin
  SetLength(Data, SizeOf(TSQLTimeStamp));
  if (not GetData(Data)) then
    Result := ''
  else
    Result := MySQLTimeStampToStr(TSQLTimeStamp((@Data[0])^), SQLFormatToDisplayFormat(SQLFormat));
end;

function TMySQLTimeStampField.GetDataSize: Integer;
begin
  Result := SizeOf(TSQLTimeStamp);
end;

function TMySQLTimeStampField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

function TMySQLTimeStampField.GetOldValue: Variant;
var
  Data: TValueBuffer;
begin
  SetLength(Data, SizeOf(TSQLTimeStamp));
  if (not GetData(Data)) then
    Result := ''
  else
    Result := MySQLTimeStampToStr(TSQLTimeStamp((@Data[0])^), SQLFormatToDisplayFormat(SQLFormat));
end;

procedure TMySQLTimeStampField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

procedure TMySQLTimeStampField.SetAsSQLTimeStamp(const Value: TSQLTimeStamp);
begin
  SetData(BytesOf(@Value, SizeOf(Value)));
end;

procedure TMySQLTimeStampField.SetAsString(const Value: string);
var
  SQLTimeStamp: TSQLTimeStamp;
begin
  if (Value = '') then
  begin
    SQLTimeStamp.Year := Word(-32767);
    SQLTimeStamp.Month := 0;
    SQLTimeStamp.Day := 0;
    SQLTimeStamp.Hour := 0;
    SQLTimeStamp.Minute := 0;
    SQLTimeStamp.Second := 0;
    SQLTimeStamp.Fractions := 0;
    AsSQLTimeStamp := SQLTimeStamp;
  end
  else if (DisplayFormat <> '') then
    AsSQLTimeStamp := StrToMySQLTimeStamp(Value, DisplayFormatToSQLFormat(DisplayFormat))
  else
    AsSQLTimeStamp := StrToMySQLTimeStamp(Value, SQLFormat);
end;

procedure TMySQLTimeStampField.SetAsVariant(const Value: Variant);
begin
  SetAsSQLTimeStamp(StrToMySQLTimeStamp(Value, SQLFormat));
end;

procedure TMySQLTimeStampField.SetDataSet(ADataSet: TDataSet);
begin
  inherited;

  if (DataSet is TMySQLQuery) then
    if (TMySQLConnection(TMySQLQuery(DataSet).Connection).MySQLVersion >= 40100) then
      ValidChars := ['0'..'9', TMySQLConnection(TMySQLQuery(DataSet).Connection).FormatSettings.DateSeparator, TMySQLConnection(TMySQLQuery(DataSet).Connection).FormatSettings.TimeSeparator, ' ']
    else
      ValidChars := ['0'..'9']
  else
    ValidChars := ['0'..'9', '-', ':', ' '];
end;

{ TMySQLWideMemoField *************************************************************}

function TMySQLWideMemoField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLWideMemoField.GetAsVariant(): Variant;
begin
  if (IsNull) then
    Result := Null
  else
    Result := GetAsString();
end;

function TMySQLWideMemoField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLWideMemoField.GetText(var Text: string; DisplayText: Boolean);
begin
  if (IsNull) then
    Text := ''
  else
    Text := LibDecode(FieldCodePage(Self), TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
end;

procedure TMySQLWideMemoField.SetAsString(const Value: string);
begin
  if (Length(Value) > 0) then
    inherited SetAsString(Value)
  else
    with DataSet.CreateBlobStream(Self, bmWrite) do
      try
        Write(Value, 0);
      finally
        Free();
      end;
end;

{ TMySQLWideStringField *******************************************************}

function TMySQLWideStringField.GetAsDateTime(): TDateTime;
begin
  Result := MySQLDB.StrToDateTime(GetAsString(), TMySQLQuery(DataSet).Connection.FormatSettings);
end;

function TMySQLWideStringField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLWideStringField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLWideStringField.GetText(var Text: string; DisplayText: Boolean);
begin
  if (IsNull) then
    Text := ''
  else
    Text := LibDecode(FieldCodePage(Self), TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
end;

procedure TMySQLWideStringField.SetAsDateTime(Value: TDateTime);
begin
  SetAsString(MySQLDB.DateTimeToStr(Value, TMySQLQuery(DataSet).Connection.FormatSettings));
end;

{ TMySQLWordField *************************************************************}

function TMySQLWordField.GetAsString(): string;
begin
  GetText(Result, False);
end;

function TMySQLWordField.GetIsNull(): Boolean;
var
  LibRow: MYSQL_ROW;
begin
  LibRow := TMySQLQuery(DataSet).LibRow;
  Result := not Assigned(LibRow) or not Assigned(LibRow^[FieldNo - 1]);
end;

procedure TMySQLWordField.GetText(var Text: string; DisplayText: Boolean);
var
  Msg: string;
begin
  if (IsNull) then
    Text := ''
  else
  try
    Assert(Assigned(DataSet));
    Assert(Assigned(TMySQLQuery(DataSet).LibRow));
    Assert(Assigned(TMySQLQuery(DataSet).LibLengths));
    Text := LibUnpack(TMySQLQuery(DataSet).LibRow^[FieldNo - 1], TMySQLQuery(DataSet).LibLengths^[FieldNo - 1]);
  except
    on E: Exception do
      begin
        Msg := 'DataSet: ' + DataSet.ClassName + #13#10;
        if (DataSet is TMySQLDataSet) then
        begin
          Msg := Msg
            + 'NewData: ' + BoolToStr(TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer^.OldData) + #13#10;
        end;
        Msg := Msg + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message;
        E.RaiseOuterException(EAssertionFailed.Create(Msg));
      end;
  end;
end;

{ TMySQLQueryBlobStream *******************************************************}

constructor TMySQLQueryBlobStream.Create(const AField: TBlobField);
begin
  Assert(AField.DataSet is TMySQLQuery);

  inherited Create();

  case (AField.DataType) of
    ftBlob:
      begin
        SetSize(TMySQLQuery.PRecordBufferData(AField.DataSet.ActiveBuffer())^.LibLengths^[AField.FieldNo - 1]);
        MoveMemory(Memory,
          TMySQLQuery.PRecordBufferData(AField.DataSet.ActiveBuffer())^.LibRow^[AField.FieldNo - 1],
          TMySQLQuery.PRecordBufferData(AField.DataSet.ActiveBuffer())^.LibLengths^[AField.FieldNo - 1]);
      end;
    ftWideMemo:
      begin
        SetSize(AnsiCharToWideChar(FieldCodePage(AField),
          TMySQLQuery.PRecordBufferData(AField.DataSet.ActiveBuffer())^.LibRow^[AField.FieldNo - 1],
          TMySQLQuery.PRecordBufferData(AField.DataSet.ActiveBuffer())^.LibLengths^[AField.FieldNo - 1], nil, 0) * SizeOf(WideChar));
        AnsiCharToWideChar(FieldCodePage(AField),
          TMySQLQuery.PRecordBufferData(AField.DataSet.ActiveBuffer())^.LibRow^[AField.FieldNo - 1],
          TMySQLQuery.PRecordBufferData(AField.DataSet.ActiveBuffer())^.LibLengths^[AField.FieldNo - 1],
          Memory,
          Size div SizeOf(WideChar));
      end;
  end;
end;

{ TMySQLQuery *****************************************************************}

function TMySQLQuery.AllocRecordBuffer(): TRecordBuffer;
begin
  GetMem(Result, SizeOf(PRecordBufferData(Result)^));

  if (Assigned(Result)) then
  begin
    PRecordBufferData(Result)^.Identifier963 := 963;
    PRecordBufferData(Result)^.LibLengths := nil;
    PRecordBufferData(Result)^.LibRow := nil;

    InitRecord(TRecBuf(Result));
  end;
end;

constructor TMySQLQuery.Create(AOwner: TComponent);
begin
  inherited;

  Name := 'TMySQLQuery' + IntToStr(DataSetNumber);
  Inc(DataSetNumber);

  FCommandText := '';
  FCommandType := ctQuery;
  FConnection := nil;
  FDatabaseName := '';
  FBufferSize := 0;
  FInternRecordBuffers := TInternRecordBuffers.Create();
  FInternRecordBuffersCS := TCriticalSection.Create();
  FRecordReceived := TEvent.Create(nil, True, False, '');
  FRecordsReceived := TEvent.Create(nil, True, False, '');
  SyncThread := nil;

  FIndexDefs := TIndexDefs.Create(Self);
  FRecNo := -1;

  SetUniDirectional(True);
end;

function TMySQLQuery.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
begin
  case (Field.DataType) of
    ftBlob: Result := TMySQLQueryBlobStream.Create(TMySQLBlobField(Field));
    ftWideMemo: Result := TMySQLQueryMemoStream.Create(TMySQLWideMemoField(Field));
    else Result := inherited CreateBlobStream(Field, Mode);
  end;
end;

destructor TMySQLQuery.Destroy();
begin
  Close();
  Connection := nil; // UnRegister Connection

  FIndexDefs.Free();
  FInternRecordBuffers.Free();
  FInternRecordBuffersCS.Free();
  FRecordReceived.Free();
  FRecordsReceived.Free();

  inherited;
end;

function TMySQLQuery.FindRecord(Restart, GoForward: Boolean): Boolean;
begin
  Result := not Restart and GoForward and (MoveBy(1) <> 0);

  SetFound(Result);
end;

procedure TMySQLQuery.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  FreeMem(Buffer); Buffer := nil;
end;

function TMySQLQuery.GetCanModify(): Boolean;
begin
  Result := False;
end;

function TMySQLQuery.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
begin
  Result := GetFieldData(Field, @Buffer[0], PRecordBufferData(ActiveBuffer()));
end;

function TMySQLQuery.GetFieldData(const Field: TField; const Buffer: Pointer; const Data: PRecordBufferData): Boolean;
var
  DTR: TDateTimeRec;
  S: string;
begin
  Result := Assigned(Field) and (Field.FieldNo > 0) and Assigned(Data) and Assigned(Data^.LibRow) and Assigned(Data^.LibRow^[Field.FieldNo - 1]);
  if (Result and Assigned(Buffer)) then
    try
      if (BitField(Field)) then
        begin
          ZeroMemory(Buffer, Field.DataSize);
          MoveMemory(@PAnsiChar(Buffer)[Field.DataSize - Data^.LibLengths^[Field.FieldNo - 1]], Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]);
          UInt64(Buffer^) := SwapUInt64(UInt64(Buffer^));
        end
      else
        case (Field.DataType) of
          ftString: begin Move(Data^.LibRow^[Field.FieldNo - 1]^, Buffer^, Data^.LibLengths^[Field.FieldNo - 1]); PAnsiChar(Buffer)[Data^.LibLengths^[Field.FieldNo - 1]] := #0; end;
          ftShortInt: begin SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]); ShortInt(Buffer^) := StrToInt(S); end;
          ftByte: begin SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]); Byte(Buffer^) := StrToInt(S); end;
          ftSmallInt: begin SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]); Smallint(Buffer^) := StrToInt(S); end;
          ftWord: begin SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]); Word(Buffer^) := StrToInt(S); end;
          ftInteger: begin SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]); Integer(Buffer^) := StrToInt(S); end;
          ftLongWord: begin SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]); LongWord(Buffer^) := StrToInt64(S); end;
          ftLargeint:
            if (not (Field is TMySQLLargeWordField)) then
              begin SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]); Largeint(Buffer^) := StrToInt64(S); end
            else
              begin SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]); UInt64(Buffer^) := StrToUInt64(S); end;
          ftSingle: begin SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]); Single(Buffer^) := StrToFloat(S, Connection.FormatSettings); end;
          ftFloat: begin SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]); Double(Buffer^) := StrToFloat(S, Connection.FormatSettings); end;
          ftExtended: begin SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]); Extended(Buffer^) := StrToFloat(S, Connection.FormatSettings); end;
          ftDate:
            begin
              SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]);
              DTR.Date := DateTimeToTimeStamp(MySQLDB.StrToDate(S, Connection.FormatSettings)).Date;
              Move(DTR, Buffer^, SizeOf(DTR));
            end;
          ftDateTime:
            begin
              SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]);
              DTR.DateTime := TimeStampToMSecs(DateTimeToTimeStamp(MySQLDB.StrToDateTime(S, Connection.FormatSettings)));
              Move(DTR, Buffer^, SizeOf(DTR));
            end;
          ftTime:
            begin
              SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]);
              DTR.Date := DateTimeToTimeStamp(StrToTime(S, Connection.FormatSettings)).Time;
              Move(DTR, Buffer^, SizeOf(DTR));
            end;
          ftTimeStamp: begin SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]); PSQLTimeStamp(Buffer)^ := StrToMySQLTimeStamp(S, TMySQLTimeStampField(Field).SQLFormat); end;
          ftBlob: MoveMemory(Buffer, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]);
          ftWideString:
            AnsiCharToWideChar(FieldCodePage(Field),
              Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1],
              Buffer, Field.Size div SizeOf(Char));
          else raise EDatabaseError.CreateFMT(SUnknownFieldType + '(%d)', [Field.Name, Integer(Field.DataType)]);
        end;
    except
      on E: EConvertError do
      begin
        if (FInformConvertError) then
        begin
          FInformConvertError := False;
          SetString(S, Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]);
          Connection.DoConvertError(Field, S, E);
        end;
        Result := False;
      end;
    end;
end;

function TMySQLQuery.GetFinishedReceiving(): Boolean;
begin
  Result := not Assigned(SyncThread) or SyncThread.FinishedReceiving;
end;

function TMySQLQuery.GetHandle(): MySQLConsts.MYSQL_RES;
begin
  if (not Assigned(Connection)) then
    Result := nil
  else
  begin
    Connection.TerminateCS.Enter();
    if (not Assigned(SyncThread)) then
      Result := nil
    else
      Result := SyncThread.ResHandle;
    Connection.TerminateCS.Leave();
  end;
end;

function TMySQLQuery.GetLibLengths(): MYSQL_LENGTHS;
begin
  Result := PRecordBufferData(ActiveBuffer())^.LibLengths;
end;

function TMySQLQuery.GetLibRow(): MYSQL_ROW;
begin
  Result := PRecordBufferData(ActiveBuffer())^.LibRow;
end;

function TMySQLQuery.GetIsIndexField(Field: TField): Boolean;
begin
  Result := pfInKey in Field.ProviderFlags;
end;

function TMySQLQuery.GetRecNo(): Integer;
begin
  Result := FRecNo;
end;

function TMySQLQuery.GetRecord(Buffer: TRecBuf; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
begin
  if (GetMode <> gmNext) then
    Result := grError
  else if (not Assigned(SyncThread.ResHandle)) then
    Result := grEOF
  else
  begin
    // Debug 2017-04-29
    Assert(Assigned(Connection.SyncThread.LibHandle));

    PRecordBufferData(ActiveBuffer())^.LibRow := Connection.Lib.mysql_fetch_row(SyncThread.ResHandle);
    SyncThread.FinishedReceiving := not Assigned(PRecordBufferData(ActiveBuffer())^.LibRow);
    if (Assigned(PRecordBufferData(ActiveBuffer())^.LibRow)) then
    begin
      PRecordBufferData(ActiveBuffer())^.LibLengths := Connection.Lib.mysql_fetch_lengths(SyncThread.ResHandle);

      Inc(FRecNo);
      Result := grOk;
    end
    else if (Connection.Lib.mysql_errno(Connection.SyncThread.LibHandle) <> 0) then
    begin
      SyncThread.ErrorCode := Connection.Lib.mysql_errno(Connection.SyncThread.LibHandle);
      SyncThread.ErrorMessage := Connection.GetErrorMessage(Connection.SyncThread.LibHandle);
      Connection.DoError(SyncThread.ErrorCode, SyncThread.ErrorMessage);
      Result := grError;
    end
    else
      Result := grEOF;
  end;
end;

function TMySQLQuery.GetRecordCount(): Integer;
begin
  Result := FRecNo + 1;
end;

function TMySQLQuery.GetUniDirectional(): Boolean;
begin
  Result := True;
end;

function TMySQLQuery.InternAddRecord(const LibRow: MYSQL_ROW;
  const LibLengths: MYSQL_LENGTHS; const Index: Integer = -1): Boolean;
var
  BufferData: TMySQLQuery.PRecordBufferData;
  Data: TMySQLQuery.TRecordBufferData;
  I: Integer;
begin
  if (not Assigned(LibRow)) then
    Result := True
  else
  begin
    Data.LibLengths := LibLengths;
    Data.LibRow := LibRow;

    BufferData := nil;
    Result := MoveRecordBufferData(BufferData, @Data);

    if (Result) then
    begin
      InternRecordBuffersCS.Enter();
      FInternRecordBuffers.Add(BufferData);
      for I := 0 to FieldCount - 1 do
        Inc(FBufferSize, Data.LibLengths^[I]);
      InternRecordBuffersCS.Leave();
    end;
  end;
end;

procedure TMySQLQuery.InternalClose();
begin
  if (Assigned(SyncThread)) then
    Connection.Sync(SyncThread);

  IndexDefs.Clear();

  FieldDefs.Clear();
  Fields.Clear();
end;

procedure TMySQLQuery.InternalHandleException();
begin
  Application.HandleException(Self);
end;

procedure TMySQLQuery.InternalInitFieldDefs();
var
  Binary: Boolean;
  CharsetNr: Byte;
  CodePage: Word;
  CreateField: Boolean;
  Decimals: Word;
  DName: string;
  Field: TField;
  I: Integer;
  Len: Longword;
  LibField: TMYSQL_FIELD;
  Name: string;
  RawField: MYSQL_FIELD;
  S: string;
  UniqueDatabaseName: Boolean;
begin
  if (FieldDefs.Count = 0) then
  begin
    if (not Assigned(Handle)) then
      for I := 0 to FieldCount - 1 do
      begin
        if (Fields[I].FieldName = '') then Fields[I].FieldName := Fields[I].Name;
        FieldDefs.Add(Fields[I].FieldName, Fields[I].DataType, Fields[I].Size, Fields[I].Required);
      end
    else
    begin
      FieldDefs.Clear();
      UniqueDatabaseName := True;

      repeat
        // Debug 2017-01-16
        if (not Assigned(Connection)) then
          raise ERangeError.Create(SRangeError);
        if (not Assigned(Connection.Lib)) then
          raise ERangeError.Create(SRangeError);

        // Debug 2017-02-19
        Assert(Assigned(Handle));

        CodePage := CP_ACP;
        RawField := MYSQL_FIELD(Connection.Lib.mysql_fetch_field(Handle));

        if (Assigned(RawField)) then
        begin
          Connection.Lib.SetField(RawField, LibField);

          if ((Connection.MySQLVersion < 40101) or (Connection.Lib.Version < 40101)) then
          begin
            Binary := LibField.flags and BINARY_FLAG <> 0;
            if (not (LibField.field_type in [MYSQL_TYPE_ENUM, MYSQL_TYPE_SET, MYSQL_TYPE_TINY_BLOB, MYSQL_TYPE_MEDIUM_BLOB, MYSQL_TYPE_LONG_BLOB, MYSQL_TYPE_BLOB, MYSQL_TYPE_VAR_STRING, MYSQL_TYPE_STRING]) or (LibField.flags and BINARY_FLAG <> 0)) then
              Len := LibField.length
            else if (Connection.MySQLVersion <= 40109) then // In 40109 this is needed. In 40122 and higher the problem is fixed. What is the exact ServerVersion?
              Len := LibField.length
            else
            begin
              CharsetNr := Connection.CharsetToCharsetNr(Connection.CharsetResult);
              CodePage := Connection.CharsetToCodePage(Connection.CharsetResult);
              if (MySQL_Character_Sets[CharsetNr].MaxLen = 0) then
                raise ERangeError.CreateFmt(SPropertyOutOfRange + ' - Charset: %s', ['MaxLen', MySQL_Character_Sets[CharsetNr].CharsetName])
              else
                Len := LibField.length div MySQL_Character_Sets[CharsetNr].MaxLen;
            end;
          end
          else
          begin
            Binary := LibField.charsetnr = 63;
            Len := LibField.length;
            if (not Binary and (Connection.MySQLVersion > 40109)) then // In 40109 this is needed. In 40122 and higher the problem is fixed.
            begin
              for I := 0 to Length(MySQL_Collations) - 1 do
                if (MySQL_Collations[I].CharsetNr = LibField.charsetnr) then
                begin
                  CodePage := MySQL_Collations[I].CodePage;
                  if (MySQL_Collations[I].MaxLen = 0) then
                    raise ERangeError.CreateFmt(SPropertyOutOfRange + ' - CharsetNr: %d', ['MaxLen', MySQL_Collations[I].CharsetNr])
                  else
                    Len := LibField.length div MySQL_Collations[I].MaxLen;
                end;
            end;
          end;
          Binary := Binary or (LibField.field_type = MYSQL_TYPE_IPV6);
          Len := Len and $7FFFFFFF;

          case (LibField.field_type) of
            MYSQL_TYPE_NULL:
              Field := TField.Create(Self);
            MYSQL_TYPE_BIT:
              begin Field := TMySQLBitField.Create(Self); Field.Tag := ftBitField; end;
            MYSQL_TYPE_TINY:
              if (LibField.flags and UNSIGNED_FLAG = 0) then
                Field := TMySQLShortIntField.Create(Self)
              else
                Field := TMySQLByteField.Create(Self);
            MYSQL_TYPE_SHORT:
              if (LibField.flags and UNSIGNED_FLAG = 0) then
                Field := TMySQLSmallIntField.Create(Self)
              else
                Field := TMySQLWordField.Create(Self);
            MYSQL_TYPE_INT24,
            MYSQL_TYPE_LONG:
              if (LibField.flags and UNSIGNED_FLAG = 0) then
                Field := TMySQLIntegerField.Create(Self)
              else
                Field := TMySQLLongWordField.Create(Self);
            MYSQL_TYPE_LONGLONG:
              if (LibField.flags and UNSIGNED_FLAG = 0) then
                Field := TMySQLLargeintField.Create(Self)
              else
                Field := TMySQLLargeWordField.Create(Self);
            MYSQL_TYPE_FLOAT:
              Field := TMySQLSingleField.Create(Self);
            MYSQL_TYPE_DOUBLE:
              Field := TMySQLFloatField.Create(Self);
            MYSQL_TYPE_DECIMAL,
            MYSQL_TYPE_NEWDECIMAL:
              Field := TMySQLExtendedField.Create(Self);
            MYSQL_TYPE_TIMESTAMP:
              begin
                if (Len in [2, 4, 6, 8, 10, 12, 14]) then
                  Field := TMySQLTimeStampField.Create(Self)
                else if ((Integer(Len) <= Length(Connection.FormatSettings.LongDateFormat + ' ' + Connection.FormatSettings.LongTimeFormat))) then
                  Field := TMySQLDateTimeField.Create(Self)
                else // Fractal seconds
                  begin Field := TMySQLWideStringField.Create(Self); Field.Size := Len; end;
                Field.Tag := Field.Tag or ftTimestampField;
              end;
            MYSQL_TYPE_DATE:
              Field := TMySQLDateField.Create(Self);
            MYSQL_TYPE_TIME:
              if (Integer(Len - 2) <= Length(Connection.FormatSettings.LongTimeFormat)) then
                Field := TMySQLTimeField.Create(Self)
              else
                begin Field := TMySQLWideStringField.Create(Self); Field.Size := Len; end;
            MYSQL_TYPE_DATETIME,
            MYSQL_TYPE_NEWDATE:
              begin
                if ((Integer(Len) <= Length(Connection.FormatSettings.LongDateFormat + ' ' + Connection.FormatSettings.LongTimeFormat))) then
                  Field := TMySQLDateTimeField.Create(Self)
                else
                  begin Field := TMySQLStringField.Create(Self); Field.Size := Len; end;
                if (LibField.field_type = MYSQL_TYPE_DATETIME) then
                  Field.Tag := Field.Tag or ftDateTimeField;
              end;
            MYSQL_TYPE_YEAR:
              if (Len = 2) then
                Field := TMySQLByteField.Create(Self)
              else
                Field := TMySQLWordField.Create(Self);
            MYSQL_TYPE_ENUM,
            MYSQL_TYPE_SET:
              if (Binary) then
                begin Field := TMySQLStringField.Create(Self); if (Connection.MySQLVersion < 40100) then Field.Size := Len + 1 else Field.Size := Len; end
              else
                begin Field := TMySQLWideStringField.Create(Self); Field.Size := Len; end;
            MYSQL_TYPE_TINY_BLOB,
            MYSQL_TYPE_MEDIUM_BLOB,
            MYSQL_TYPE_LONG_BLOB,
            MYSQL_TYPE_BLOB:
              if (Binary) then
                begin Field := TMySQLBlobField.Create(Self); Field.Size := Len; end
              else
                begin Field := TMySQLWideMemoField.Create(Self); Field.Size := Len; end;
            MYSQL_TYPE_IPV6,
            MYSQL_TYPE_VAR_STRING,
            MYSQL_TYPE_STRING:
              if (Binary) then
                begin Field := TMySQLStringField.Create(Self); if (Connection.MySQLVersion < 40100) then Field.Size := Len + 1 else Field.Size := Len; end
              else if ((Len <= $FF)  and (Connection.MySQLVersion < 50000)) { ENum&Set are not marked as MYSQL_TYPE_ENUM & MYSQL_TYPE_SET in older MySQL versions} then
                begin Field := TMySQLWideStringField.Create(Self); Field.Size := $FF; end
              else if ((Len <= $5555) and (Connection.MySQLVersion >= 50000)) then
                begin Field := TMySQLWideStringField.Create(Self); Field.Size := 65535; end
              else
                begin Field := TMySQLWideMemoField.Create(Self); Field.Size := Len; end;
            MYSQL_TYPE_GEOMETRY:
              begin Field := TMySQLBlobField.Create(Self); Field.Size := Len; Field.Tag := ftGeometryField; end;
            else
              raise EDatabaseError.CreateFMT(SBadFieldType + ' (%d)', [LibField.name, Byte(LibField.field_type)]);
          end;

          case (LibField.field_type) of
            MYSQL_TYPE_TINY:  // 8 bit
              if (LibField.flags and UNSIGNED_FLAG = 0) then
                begin TShortIntField(Field).MinValue := -$80; TShortIntField(Field).MaxValue := $7F; end
              else
                begin TByteField(Field).MinValue := 0; TByteField(Field).MaxValue := $FF; end;
            MYSQL_TYPE_SHORT: // 16 bit
              if (LibField.flags and UNSIGNED_FLAG = 0) then
                begin TSmallIntField(Field).MinValue := -$8000; TSmallIntField(Field).MaxValue := $7FFF; end
              else
                begin TWordField(Field).MinValue := 0; TWordField(Field).MaxValue := $FFFF; end;
            MYSQL_TYPE_INT24: // 24 bit
              if (LibField.flags and UNSIGNED_FLAG = 0) then
                begin TIntegerField(Field).MinValue := -$800000; TIntegerField(Field).MaxValue := $7FFFFF; end
              else
                begin TLongWordField(Field).MinValue := 0; TLongWordField(Field).MaxValue := $FFFFFF; end;
            MYSQL_TYPE_LONG: // 32 bit
              if (LibField.flags and UNSIGNED_FLAG = 0) then
                begin TIntegerField(Field).MinValue := -$80000000; TIntegerField(Field).MaxValue := $7FFFFFFF; end
              else
                begin TLongWordField(Field).MinValue := 0; TLongWordField(Field).MaxValue := $FFFFFFFF; end;
            MYSQL_TYPE_LONGLONG: // 64 bit
              if (LibField.flags and UNSIGNED_FLAG = 0) then
                begin TMySQLLargeintField(Field).MinValue := -$8000000000000000; TMySQLLargeintField(Field).MaxValue := $7FFFFFFFFFFFFFFF; end
              else
                begin TMySQLLargeWordField(Field).MinValue := 0; TMySQLLargeWordField(Field).MaxValue := $FFFFFFFFFFFFFFFF; end;
            MYSQL_TYPE_YEAR:
              if (Len = 2) then
                begin TByteField(Field).MinValue := 0; TByteField(Field).MaxValue := 99; end
              else
                begin TWordField(Field).MinValue := 1901; TWordField(Field).MaxValue := 2155; end
          end;

          Field.Tag := Field.Tag or CodePage;
          try
            Field.FieldName := LibDecode(Connection.CodePageResult, LibField.name);
          except
            Field.FieldName := LibUnpack(LibField.name);
          end;

          // Debug 2017-01-23
          if (Field.FieldName = '') then
            Field.FieldName := 'Field_' + IntToStr(Fields.Count);

          if (Assigned(FindField(Field.FieldName))) then
          begin
            I := 2;
            while (Assigned(FindField(Field.FieldName + '_' + IntToStr(I)))) do Inc(I);
            Field.FieldName := Field.FieldName + '_' + IntToStr(I);
          end;

          Field.Required := LibField.flags and NOT_NULL_FLAG <> 0;

          CreateField := Pos('.', Field.Origin) = 0;
          if (CreateField) then
          begin
            if ((Connection.Lib.Version >= 40100) and (LibField.org_name_length > 0)) then
              Field.Origin := '"' + LibDecode(Connection.CodePageResult, LibField.org_name) + '"'
            else if (LibField.name_length > 0) then
              Field.Origin := '"' + LibDecode(Connection.CodePageResult, LibField.name) + '"'
            else
              Field.Origin := '';
            if (Field.Origin <> '') then
              if ((Connection.Lib.Version >= 40000) and (LibField.org_table_length > 0)) then
              begin
                Field.Origin := '"' + LibDecode(Connection.CodePageResult, LibField.org_table) + '".' + Field.Origin;
                if ((Connection.Lib.Version >= 40101) and (LibField.db_length > 0)) then
                  Field.Origin := '"' + LibDecode(Connection.CodePageResult, LibField.db) + '".' + Field.Origin;
              end
              else if (LibField.table_length > 0) then
                Field.Origin := '"' + LibDecode(Connection.CodePageResult, LibField.table) + '".' + Field.Origin;
            Field.ReadOnly := LibField.table = '';
            if ((Connection.Lib.Version >= 40101) and (LibField.db_length > 0)) then
              if (DName = '') then
                DName := LibDecode(Connection.CodePageResult, LibField.db)
              else
                UniqueDatabaseName := UniqueDatabaseName and (LibDecode(Connection.CodePageResult, LibField.db) = DName);

            if (LibField.flags and AUTO_INCREMENT_FLAG <> 0) then
            begin
              Field.ProviderFlags := Field.ProviderFlags + [pfInWhere];
              Field.AutoGenerateValue := arAutoInc;
            end
            else if ((LibField.table = '')
              or (Field.Tag and ftTimestampField <> 0) and (Connection.MySQLVersion >= 40102)
              or (Field.Tag and ftDateTimeField <> 0) and (Connection.MySQLVersion >= 50605)) then
              Field.AutoGenerateValue := arDefault
            else
              Field.AutoGenerateValue := arNone;
            if (Field.DataType = ftTimeStamp) then
              case (Len) of
                2: TMySQLTimeStampField(Field).SQLFormat := '%y';
                4: TMySQLTimeStampField(Field).SQLFormat := '%y%m';
                6: TMySQLTimeStampField(Field).SQLFormat := '%y%m%d';
                8: TMySQLTimeStampField(Field).SQLFormat := '%Y%m%d';
                10: TMySQLTimeStampField(Field).SQLFormat := '%y%m%d%H%i';
                12: TMySQLTimeStampField(Field).SQLFormat := '%y%m%d%H%i%s';
                14: TMySQLTimeStampField(Field).SQLFormat := '%Y%m%d%H%i%s';
              end;

            case (Field.DataType) of
              ftShortInt,
              ftByte,
              ftSmallInt,
              ftWord,
              ftInteger,
              ftLongWord,
              ftSingle,
              ftFloat,
              ftExtended:
                begin
                  if (Len = 0) then
                    S := '0'
                  else if (BitField(Field) or (LibField.flags and ZEROFILL_FLAG <> 0)) then
                    S := StringOfChar('0', Len)
                  else
                    S := StringOfChar('#', Len - 1) + '0';
                  Decimals := LibField.decimals;
                  if (Decimals > Len) then Decimals := Len;
                  if ((Field.DataType in [ftSingle, ftFloat, ftExtended]) and (Decimals > 0)) then
                  begin
                    System.Delete(S, 1, Decimals + 1);
                    S := S + '.' + StringOfChar('0', Decimals);
                  end;
                  if (Length(S) > 256 - 32) then // Limit given because of the usage of SysUtils.FormatFloat
                    System.Delete(S, 1, Length(S) - 32);
                  TNumericField(Field).DisplayFormat := S;
                end;
              ftDate: TMySQLDateField(Field).DisplayFormat := Connection.FormatSettings.ShortDateFormat;
              ftTime: TMySQLTimeField(Field).DisplayFormat := Connection.FormatSettings.LongTimeFormat;
              ftDateTime: TMySQLDateTimeField(Field).DisplayFormat := Connection.FormatSettings.ShortDateFormat + ' ' + Connection.FormatSettings.LongTimeFormat;
              ftTimeStamp: TMySQLTimeStampField(Field).DisplayFormat := SQLFormatToDisplayFormat(TMySQLTimeStampField(Field).SQLFormat);
            end;

            if (Assigned(Handle)) then
            begin
              Field.DisplayLabel := LibDecode(Connection.CodePageResult, LibField.name);
              case (Field.DataType) of
                ftBlob: Field.DisplayWidth := 7;
                ftWideMemo: Field.DisplayWidth := 8;
                else
                  if (Field.Tag and ftGeometryField <> 0) then
                    Field.DisplayWidth := 7
                  else
                    Field.DisplayWidth := Len;
              end;
            end;

            if (Field.Name = '') then
            begin
              Name := ReplaceStr(ReplaceStr(Field.FieldName, ' ', '_'), '.', '_');
              if (not IsValidIdent(Name)) then
                Name := ''
              else
                for I := 0 to FieldDefs.Count - 1 do
                  if (FieldDefs[I].Name = Name) then
                    Name := '';
              if (Name = '') then
                Field.Name := 'Field' + '_' + IntToStr(FieldDefs.Count)
              else
                Field.Name := Name;
            end;

            if (Field.ReadOnly) then
              Field.ProviderFlags := Field.ProviderFlags - [pfInUpdate]
            else
              Field.ProviderFlags := Field.ProviderFlags + [pfInUpdate];
            if (LibField.flags and PRI_KEY_FLAG = 0) then
              Field.ProviderFlags := Field.ProviderFlags - [pfInKey]
            else
              Field.ProviderFlags := Field.ProviderFlags + [pfInKey];

            if (Assigned(Handle)) then
              Field.DataSet := Self;

            FieldDefs.Add(Field.FieldName, Field.DataType, Field.Size, Field.Required);

            if (not Assigned(Handle)) then
              FreeAndNil(Field)
          end;
        end;
      until (not Assigned(RawField));

      if (UniqueDatabaseName and (DName <> '')) then
        FDatabaseName := DName;
    end;
  end;
end;

procedure TMySQLQuery.InternalOpen();
var
  OpenFromSyncThread: Boolean;
begin
  Assert(Assigned(Connection) and Assigned(Connection.Lib) and not Assigned(SyncThread));

  FInformConvertError := True;
  FRowsAffected := -1;
  FRecNo := -1;

  OpenFromSyncThread := Assigned(Connection.SyncThread) and (Connection.SyncThread.State = ssResult);

  if (OpenFromSyncThread) then
    SyncThread := Connection.SyncThread;

  InitFieldDefs();
  BindFields(True);

  if (OpenFromSyncThread) then
    Connection.SyncBindDataSet(Self);
end;

function TMySQLQuery.IsCursorOpen(): Boolean;
begin
  Result := Assigned(SyncThread);
end;

function TMySQLQuery.MoveRecordBufferData(var DestData: TMySQLQuery.PRecordBufferData;
  const SourceData: TMySQLQuery.PRecordBufferData): Boolean;
var
  I: Integer;
  Index: Integer;
  MemSize: Integer;
begin
  Assert(Assigned(SourceData));
  Assert(Assigned(SourceData^.LibLengths));


  if (Assigned(DestData)) then
    FreeMem(DestData);

  MemSize := SizeOf(DestData^) + FieldCount * (SizeOf(DestData^.LibLengths^[0]) + SizeOf(DestData^.LibRow^[0]));
  for I := 0 to FieldCount - 1 do
    Inc(MemSize, SourceData^.LibLengths^[I]);

  GetMem(DestData, MemSize);

  Result := Assigned(DestData);
  if (Result) then
  begin
    DestData^.Identifier963 := 963;
    DestData^.LibLengths := Pointer(@PAnsiChar(DestData)[SizeOf(DestData^)]);
    DestData^.LibRow := Pointer(@PAnsiChar(DestData)[SizeOf(DestData^) + FieldCount * SizeOf(DestData^.LibLengths^[0])]);

    MoveMemory(DestData^.LibLengths, SourceData^.LibLengths, FieldCount * SizeOf(DestData^.LibLengths^[0]));
    Index := SizeOf(DestData^) + FieldCount * (SizeOf(DestData^.LibLengths^[0]) + SizeOf(DestData^.LibRow^[0]));
    for I := 0 to FieldCount - 1 do
      if (not Assigned(SourceData^.LibRow^[I])) then
        DestData^.LibRow^[I] := nil
      else
      begin
        DestData^.LibRow^[I] := @PAnsiChar(DestData)[Index];
        MoveMemory(DestData^.LibRow^[I], SourceData^.LibRow^[I], DestData^.LibLengths^[I]);
        Inc(Index, DestData^.LibLengths^[I]);
      end;
  end;
end;

procedure TMySQLQuery.Open(const DataHandle: TMySQLConnection.TDataHandle);
var
  EndingCommentLength: Integer;
  StartingCommentLength: Integer;
  StmtLength: Integer;
begin
  if (Assigned(DataHandle)) then
  begin
    Connection := DataHandle.Connection;

    if (CommandType = ctQuery) then
    begin
      FDatabaseName := Connection.DatabaseName;
      FCommandText := DataHandle.CommandText;
      StmtLength := SQLTrimStmt(PChar(FCommandText), Integer(Length(FCommandText)), StartingCommentLength, EndingCommentLength);
      if ((StmtLength > 0) and (FCommandText[1 + StartingCommentLength + StmtLength - 1] = ';')) then
        Dec(StmtLength);
      if (StmtLength = 0) then
        FCommandText := ''
      else
        SetString(FCommandText, PChar(@FCommandText[1 + StartingCommentLength]), StmtLength);
    end;

    SetActiveEvent(DataHandle.ErrorCode, DataHandle.ErrorMessage, DataHandle.WarningCount,
      FCommandText, DataHandle, Assigned(DataHandle.ResHandle));
  end;
end;

procedure TMySQLQuery.Open(const ResultHandle: TMySQLConnection.TResultHandle);
begin
  Open(ResultHandle.SyncThread);
end;

function TMySQLQuery.RecordCompare(const CompareDefs: TRecordCompareDefs; const A, B: TMySQLQuery.PRecordBufferData; const FieldIndex: Integer = 0): Integer;
var
  Field: TField;
  ShortIntA, ShortIntB: ShortInt;
  ByteA, ByteB: Byte;
  SmallIntA, SmallIntB: SmallInt;
  WordA, WordB: Word;
  IntegerA, IntegerB: Integer;
  LongWordA, LongWordB: LongWord;
  LargeIntA, LargeIntB: LargeInt;
  UInt64A, UInt64B: UInt64;
  SingleA, SingleB: Single;
  DoubleA, DoubleB: Double;
  ExtendedA, ExtendedB: Extended;
  DateTimeA, DateTimeB: TDateTimeRec;
  StringA, StringB: string;
begin
  Field := CompareDefs[FieldIndex].Field;

  if (A = B) then
    Result := 0
  else if (not Assigned(A^.LibRow[Field.FieldNo - 1]) and Assigned(B^.LibRow[Field.FieldNo - 1])) then
    Result := -1
  else if (Assigned(A^.LibRow[Field.FieldNo - 1]) and not Assigned(B^.LibRow[Field.FieldNo - 1])) then
    Result := +1
  else if ((A^.LibLengths[Field.FieldNo - 1] = 0) and (B^.LibLengths[Field.FieldNo - 1] > 0)) then
    Result := -1
  else if ((A^.LibLengths[Field.FieldNo - 1] > 0) and (B^.LibLengths[Field.FieldNo - 1] = 0)) then
    Result := +1
  else if ((A^.LibLengths[Field.FieldNo - 1] = 0) and (B^.LibLengths[Field.FieldNo - 1] = 0)) then
    Result := 0
  else
  begin
    case (Field.DataType) of
      ftString: Result := AnsiStrings.StrComp(A^.LibRow^[Field.FieldNo - 1], B^.LibRow^[Field.FieldNo - 1]);
      ftShortInt: begin GetFieldData(Field, @ShortIntA, A); GetFieldData(Field, @ShortIntB, B); Result := Sign(ShortIntA - ShortIntB); end;
      ftByte:
        begin
          GetFieldData(Field, @ByteA, A);
          GetFieldData(Field, @ByteB, B);
          if (ByteA < ByteB) then Result := -1 else if (ByteA > ByteB) then Result := +1 else Result := 0;
        end;
      ftSmallInt: begin GetFieldData(Field, @SmallIntA, A); GetFieldData(Field, @SmallIntB, B); Result := Sign(SmallIntA - SmallIntB); end;
      ftWord:
        begin
          GetFieldData(Field, @WordA, A);
          GetFieldData(Field, @WordB, B);
          if (WordA < WordB) then Result := -1 else if (WordA > WordB) then Result := +1 else Result := 0;
        end;
      ftInteger: begin GetFieldData(Field, @IntegerA, A); GetFieldData(Field, @IntegerB, B); Result := Sign(IntegerA - IntegerB); end;
      ftLongWord:
        begin
          GetFieldData(Field, @LongWordA, A);
          GetFieldData(Field, @LongWordB, B);
          if (LongWordA < LongWordB) then Result := -1 else if (LongWordA > LongWordB) then Result := +1 else Result := 0;
        end;
      ftLargeInt:
        if (not (Field is TMySQLLargeWordField)) then
          begin GetFieldData(Field, @LargeIntA, A); GetFieldData(Field, @LargeIntB, B); Result := Sign(LargeIntA - LargeIntB); end
        else
        begin
          GetFieldData(Field, @UInt64A, A);
          GetFieldData(Field, @UInt64B, B);
          if (UInt64A < UInt64B) then Result := -1 else if (UInt64A > UInt64B) then Result := +1 else Result := 0;
        end;
      ftSingle: begin GetFieldData(Field, @SingleA, A); GetFieldData(Field, @SingleB, B); Result := Sign(SingleA - SingleB); end;
      ftFloat: begin GetFieldData(Field, @DoubleA, A); GetFieldData(Field, @DoubleB, B); Result := Sign(DoubleA - DoubleB); end;
      ftExtended: begin GetFieldData(Field, @ExtendedA, A); GetFieldData(Field, @ExtendedB, B); Result := Sign(ExtendedA - ExtendedB); end;
      ftDate: begin GetFieldData(Field, @DateTimeA, A); GetFieldData(Field, @DateTimeB, B); Result := Sign(DateTimeA.Date - DateTimeB.Date); end;
      ftDateTime: begin GetFieldData(Field, @DateTimeA, A); GetFieldData(Field, @DateTimeB, B); Result := Sign(DateTimeA.DateTime - DateTimeB.DateTime); end;
      ftTime: begin GetFieldData(Field, @IntegerA, A); GetFieldData(Field, @IntegerB, B); Result := Sign(IntegerA - IntegerB); end;
      ftTimeStamp: Result := AnsiStrings.StrComp(A^.LibRow^[Field.FieldNo - 1], B^.LibRow^[Field.FieldNo - 1]);
      ftWideString,
      ftWideMemo:
        begin
          StringA := LibDecode(FieldCodePage(Field), A^.LibRow^[Field.FieldNo - 1], A^.LibLengths^[Field.FieldNo - 1]);
          StringB := LibDecode(FieldCodePage(Field), B^.LibRow^[Field.FieldNo - 1], B^.LibLengths^[Field.FieldNo - 1]);
          Result := AnsiCompareStr(StringA, StringB);
        end;
      ftBlob: Result := AnsiStrings.StrComp(A^.LibRow^[Field.FieldNo - 1], B^.LibRow^[Field.FieldNo - 1]);
      else
        raise EDatabaseError.CreateFMT(SUnknownFieldType + '(%d)', [Field.Name, Integer(Field.DataType)]);
    end;
  end;

  if (Result = 0) then
  begin
    if (FieldIndex + 1 < Length(CompareDefs)) then
      Result := RecordCompare(CompareDefs, A, B, FieldIndex + 1);
  end
  else if (not CompareDefs[FieldIndex].Ascending) then
    Result := -Result;
end;

procedure TMySQLQuery.SetActive(Value: Boolean);
var
  SQL: string;
begin
  if (Value <> Active) then
    if (not Value) then
      inherited
    else if (FieldCount > 0) then
      inherited
    else
    begin
      if ((CommandType = ctTable) and (Self is TMySQLTable)) then
        SQL := TMySQLTable(Self).SQLSelect()
      else
        SQL := CommandText;

      Connection.BeginSynchron(3);
      Connection.InternExecuteSQL(smDataSet, SQL, SetActiveEvent);
      Connection.EndSynchron(3);

      if (Self is TMySQLDataSet) then
        TMySQLDataSet(Self).Progress := TMySQLDataSet(Self).Progress + 'A';
    end;
end;

function TMySQLQuery.SetActiveEvent(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
  const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
begin
  Assert(not Assigned(SyncThread));

  if (Assigned(DataHandle)) then
  begin
    Assert(Assigned(Connection.SyncThread));
    Assert(DataHandle = Connection.SyncThread);

    if (not Data or (DataHandle.ErrorCode <> 0)) then
      SetState(dsInactive)
    else
    begin
      DoBeforeOpen();
      SetState(dsOpening);
      OpenCursorComplete();
    end;
  end;

  Result := False;
end;

procedure TMySQLQuery.SetCommandText(const ACommandText: string);
begin
  Assert(not Active);

  FCommandText := ACommandText;
end;

procedure TMySQLQuery.SetConnection(const AConnection: TMySQLConnection);
begin
  Assert(not Assigned(AConnection) or not IsCursorOpen(),
    'Active: ' + BoolToStr(Active, True) + #13#10
    + 'CommandText: ' + CommandText);

  if (not Assigned(FConnection) and Assigned(AConnection)) then
    AConnection.RegisterClient(Self);
  if (Assigned(FConnection) and not Assigned(AConnection)) then
    FConnection.UnRegisterClient(Self);

  FConnection := AConnection;
end;

function TMySQLQuery.SQLFieldValue(const Field: TField; Data: PRecordBufferData = nil): string;
begin
  if (not Assigned(Data)) then
    if (not (Self is TMySQLDataSet)) then
      Data := PRecordBufferData(ActiveBuffer())
    else
      Data := TMySQLDataSet.PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData;

  if (not Assigned(Data) or not Assigned(Data^.LibRow) or not Assigned(Data^.LibRow^[Field.FieldNo - 1])) then
    if (not Field.Required) then
      Result := 'NULL'
    else
      Result := 'DEFAULT'
  else if (BitField(Field)) then
    Result := 'b''' + Field.AsString + ''''
  else
    try // Debug 2017-05-10
    case (Field.DataType) of
      ftString: Result := SQLEscapeBin(Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1], Connection.MySQLVersion <= 40000);
      ftShortInt,
      ftByte,
      ftSmallInt,
      ftWord,
      ftInteger,
      ftLongWord,
      ftLargeint,
      ftSingle,
      ftFloat,
      ftExtended: Result := LibUnpack(Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]);
      ftDate,
      ftDateTime,
      ftTime: Result := '''' + LibUnpack(Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]) + '''';
      ftTimeStamp: LibUnpack(Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]);
      ftBlob: Result := SQLEscapeBin(Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1], Connection.MySQLVersion <= 40000);
      ftWideString,
      ftWideMemo: Result := SQLEscape(LibDecode(FieldCodePage(Field), Data^.LibRow^[Field.FieldNo - 1], Data^.LibLengths^[Field.FieldNo - 1]));
      else raise EDatabaseError.CreateFMT(SUnknownFieldType + '(%d)', [Field.Name, Integer(Field.DataType)]);
    end;
    except
      on E: Exception do
        Exception.RaiseOuterException(EAssertionFailed.Create('EAssertionFailed: ' + #13#10
          + 'TMySQLDataSet: ' + BoolToStr(Self is TMySQLDataSet, True) + #13#10
          + 'NewData: ' + BoolToStr((Self is TMySQLDataSet) and (TMySQLDataSet.PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData <> TMySQLDataSet.PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData), True)
          + #13#10
          + E.ClassName + ':' + #13#10
          + E.Message));
    end;
end;

procedure TMySQLQuery.UpdateIndexDefs();
begin
  if (not Assigned(Handle) and not IndexDefs.Updated) then
  begin
    if (Assigned(Connection.OnUpdateIndexDefs)) then
      Connection.OnUpdateIndexDefs(Self, IndexDefs);
    IndexDefs.Updated := True;
  end;
end;

{ TMySQLDataSetBlobStream *****************************************************}

constructor TMySQLDataSetBlobStream.Create(const AField: TBlobField; AMode: TBlobStreamMode);
begin
  inherited Create();

  Empty := True;
  Field := AField;
  Mode := AMode;

  if (Mode in [bmRead, bmReadWrite]) then
  begin
    Empty := not Assigned(TMySQLDataSet.PExternRecordBuffer(Field.DataSet.ActiveBuffer()))
      or not Assigned(TMySQLDataSet.PExternRecordBuffer(Field.DataSet.ActiveBuffer())^.InternRecordBuffer)
      or not Assigned(TMySQLDataSet.PExternRecordBuffer(Field.DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData)
      or not Assigned(TMySQLDataSet.PExternRecordBuffer(Field.DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData^.LibRow^[Field.FieldNo - 1]);
    if (not Empty) then
      if (Field.DataType in [ftMemo, ftBlob]) then
      begin
        SetSize(TMySQLDataSet.PExternRecordBuffer(Field.DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData^.LibLengths^[Field.FieldNo - 1]);
        MoveMemory(Memory, TMySQLDataSet.PExternRecordBuffer(Field.DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData^.LibRow^[Field.FieldNo - 1], Size);
      end
      else if (Field.DataType = ftWideMemo) then
      begin
        SetSize(
          AnsiCharToWideChar(FieldCodePage(Field),
            TMySQLDataSet.PExternRecordBuffer(Field.DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData^.LibRow^[Field.FieldNo - 1],
            TMySQLDataSet.PExternRecordBuffer(Field.DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData^.LibLengths^[Field.FieldNo - 1],
            nil,
            0) * SizeOf(Char));
        AnsiCharToWideChar(FieldCodePage(Field),
          TMySQLDataSet.PExternRecordBuffer(Field.DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData^.LibRow^[Field.FieldNo - 1],
          TMySQLDataSet.PExternRecordBuffer(Field.DataSet.ActiveBuffer())^.InternRecordBuffer^.NewData^.LibLengths^[Field.FieldNo - 1],
          Memory,
          Size);
      end
      else
        raise ERangeError.Create('DataType: ' + IntToStr(Ord(Field.DataType)));
  end;
end;

destructor TMySQLDataSetBlobStream.Destroy();
begin
  if (Mode in [bmWrite, bmReadWrite]) then
  begin
    if (Empty) then
      TMySQLDataSet(Field.DataSet).SetFieldData(Field, TValueBuffer(nil))
    else
      TMySQLDataSet(Field.DataSet).SetFieldData(Field, BytesOf(Memory, Size));

    TMySQLDataSet(Field.DataSet).DataEvent(deFieldChange, Longint(Field));
  end;

  inherited;
end;

function TMySQLDataSetBlobStream.Write(const Buffer: TBytes; Offset, Count: Longint): Longint;
begin
  Empty := False;
  Result := Write(Buffer[Offset], Count);
end;

{ TMySQLDataSet.TInternRecordBuffers ******************************************}

procedure TMySQLDataSet.TInternRecordBuffers.Clear();
var
  I: Integer;
begin
  DataSet.InternRecordBuffersCS.Enter();
  if ((DataSet.State = dsBrowse)
    and (DataSet.BufferCount > 0) and Assigned(Pointer(DataSet.ActiveBuffer()))
    and Assigned(PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer)) then
    PExternRecordBuffer(DataSet.ActiveBuffer())^.InternRecordBuffer := nil;
  for I := 0 to Count - 1 do
    DataSet.FreeInternRecordBuffer(Items[I]);
  inherited Clear();
  FilteredRecordCount := 0;
  Index := -1;
  DataSet.RecordReceived.ResetEvent();
  DataSet.InternRecordBuffersCS.Leave();
end;

constructor TMySQLDataSet.TInternRecordBuffers.Create(const ADataSet: TMySQLDataSet);
begin
  inherited Create();

  FDataSet := ADataSet;

  Index := -1;
end;

procedure TMySQLDataSet.TInternRecordBuffers.Delete(Index: Integer);
begin
  Assert(Index >= 0);
  // Debug 2017-03-27
  Assert(Index < Count);

  inherited;

  if (Index = Count) then
    Self.Index := Self.Index - 1;
end;

function TMySQLDataSet.TInternRecordBuffers.IndexOf(const Bookmark: TBookmark): Integer;
begin
  if (Length(Bookmark) <> DataSet.BookmarkSize) then
    Result := -1
  else
    Result := IndexOf(PInternRecordBuffer(PPointer(@Bookmark[0])^))
end;

function TMySQLDataSet.TInternRecordBuffers.IndexFor(const Data: TMySQLQuery.TRecordBufferData; const IgnoreIndex: Integer = -1): Integer;
var
  Comp: Integer;
  FieldName: string;
  I: Integer;
  Left: Integer;
  Mid: Integer;
  Pos: Integer;
  Right: Integer;
  CompareDefs: TRecordCompareDefs;
begin
  SetLength(CompareDefs, 0);
  Pos := 1;
  repeat
    FieldName := ExtractFieldName(SortDef.Fields, Pos);
    if (FieldName <> '') then
    begin
      SetLength(CompareDefs, Length(CompareDefs) + 1);
      CompareDefs[Length(CompareDefs) - 1].Field := DataSet.FieldByName(FieldName);
      CompareDefs[Length(CompareDefs) - 1].Ascending := True;
    end;
  until (FieldName = '');
  Pos := 1;
  repeat
    FieldName := ExtractFieldName(SortDef.DescFields, Pos);
    if (FieldName <> '') then
      for I := 0 to Length(CompareDefs) - 1 do
        if (CompareDefs[I].Field.FieldName = FieldName) then
          CompareDefs[I].Ascending := False;
  until (FieldName = '');

  Result := -1;
  Left := 0;
  Right := Count - 1;
  while (Left < Right) do
  begin
    Mid := (Right - Left) div 2 + Left;

    if (Mid = IgnoreIndex) then
      if (Right > Mid) then
        Inc(Mid)
      else
        Dec(Mid);

    Comp := DataSet.RecordCompare(CompareDefs, Items[Mid]^.NewData, @Data);
    case (Comp) of
      -1: Left := Mid + 1;
      0: begin Result := Mid; break; end;
      1: Right := Mid - 1;
    end;
  end;

  if ((Result < 0) and (IgnoreIndex >= 0)) then
    Result := Left + 1;

  Assert(Result >= 0);
end;

procedure TMySQLDataSet.TInternRecordBuffers.Insert(Index: Integer; const Item: PInternRecordBuffer);
var
  I: Integer;
begin
  inherited;

  for I := 0 to DataSet.BufferCount - 1 do
    if (TMySQLDataSet.PExternRecordBuffer(DataSet.Buffers[I])^.Index >= Index) then
      Inc(TMySQLDataSet.PExternRecordBuffer(DataSet.Buffers[I])^.Index);
end;

function TMySQLDataSet.TInternRecordBuffers.GetSortDef(): TIndexDef;
begin
  Result := DataSet.SortDef;
end;

procedure TMySQLDataSet.TInternRecordBuffers.SetIndex(AValue: Integer);
begin
  if (AValue < -1) then
    raise EAssertionFailed.Create('AValue: ' + IntToStr(AValue));

  FIndex := AValue;
end;

{ TMySQLDataSet ***************************************************************}

procedure TMySQLDataSet.ActivateFilter();
var
  OldBookmark: TBookmark;
begin
  CheckBrowseMode();

  DisableControls();
  DoBeforeScroll();

  OldBookmark := Bookmark;

  InternActivateFilter();

  if (not BookmarkValid(OldBookmark)) then
    First()
  else
    Bookmark := OldBookmark;

  DoAfterScroll();
  EnableControls();
end;

function TMySQLDataSet.AllocInternRecordBuffer(): PInternRecordBuffer;
begin
  GetMem(Result, SizeOf(Result^));

  if (Assigned(Result)) then
  begin
    Result^.Identifier123 := 123;
    Result^.NewData := nil;
    Result^.OldData := nil;
    Result^.VisibleInFilter := True;
  end;
end;

function TMySQLDataSet.AllocRecordBuffer(): TRecordBuffer;
begin
  GetMem(PExternRecordBuffer(Result), SizeOf(TExternRecordBuffer));

  PExternRecordBuffer(Result)^.Identifier432 := 432;
  PExternRecordBuffer(Result)^.Index := -1;
  PExternRecordBuffer(Result)^.InternRecordBuffer := nil;
  PExternRecordBuffer(Result)^.BookmarkFlag := bfInserted;
end;

procedure TMySQLDataSet.AfterCommit();
begin
  if ((Connection.ErrorCode > 0)
    and not ConnectionLost(Connection.ErrorCode)
    and (Connection.LibraryType <> ltHTTP)
    and Assigned(AppliedBuffers)
    and not Connection.ExecuteSQL('COMMIT;' + #13#10)) then
    AppliedBuffers.Clear();
  if (Assigned(AppliedBuffers)) then
  begin
    while (AppliedBuffers.Count > 0) do
    begin
      PendingBuffers.Delete(PendingBuffers.IndexOf(AppliedBuffers[0]));
      AppliedBuffers.Delete(0);
    end;
    AppliedBuffers.Free();
    AppliedBuffers := nil;
  end;

  EnableControls();

  // Debug 2017-05-24
  Resync([]); // Is this needed? Maybe without this, there is a problem in SQLUpdate while the following update

  DataEvent(deCommitted, NativeInt(False));
end;

function TMySQLDataSet.BookmarkValid(Bookmark: TBookmark): Boolean;
var
  Index: Integer;
begin
  Result := (Length(Bookmark) = BookmarkSize);
  if (Result) then
  begin
    Index := InternRecordBuffers.IndexOf(Bookmark);
    Result := (Index >= 0) and (not Filtered or InternRecordBuffers[Index]^.VisibleInFilter);
  end;
end;

function TMySQLDataSet.Commit(): Boolean;
var
  SQL: string;
begin
  SQL := SQLUpdate()
    + SQLInsert();

  if ((SQL <> '') and (Connection.LibraryType <> ltHTTP)) then
  begin
    if (Connection.MySQLVersion < 40011) then
      SQL := 'BEGIN;' + #13#10 + SQL
    else
      SQL := 'START TRANSACTION;' + #13#10 + SQL;
    SQL := SQL + 'COMMIT;' + #13#10;
    if (Connection.DatabaseName <> DatabaseName) then
      SQL := Connection.SQLUse(DatabaseName) + SQL;
  end;

  if (SQL = '') then
    Result := True
  else
  begin
    AppliedBuffers := TList<PInternRecordBuffer>.Create();
    Connection.CommittingDataSet := Self;
    DisableControls();
    Result := Connection.SendSQL(SQL, CommitEvent);
  end;
end;

function TMySQLDataSet.CommitEvent(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
  const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
var
  Parse: TSQLParse;
begin
  if (not SQLCreateParse(Parse, PChar(CommandText), Length(CommandText), Connection.MySQLVersion)
    or not SQLParseKeyword(Parse, 'INSERT')) then
    Result := False
  else
  begin
    InternalPostResult.InternRecordBuffer := PendingBuffers[AppliedBuffers.Count];
    InternalPostResult.Exception := nil;
    InternalPostResult.NewIndex := -1;
    Result := InternalPostEvent(ErrorCode, ErrorMessage, WarningCount, CommandText, DataHandle, Data);
    if (not Assigned(InternalPostResult.Exception)) then
      AppliedBuffers.Add(PendingBuffers[AppliedBuffers.Count]);
  end;
end;

function TMySQLDataSet.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer;
begin
  Result := Sign(InternRecordBuffers.IndexOf(Bookmark1) - InternRecordBuffers.IndexOf(Bookmark2));
end;

constructor TMySQLDataSet.Create(AOwner: TComponent);
begin
  inherited;

  AppliedBuffers := nil;
  DeleteBookmarks := nil;
  DeleteByWhereClause := False;
  FCanModify := False;
  FCommandType := ctQuery;
  FCursorOpen := False;
  FDataSize := 0;
  FilterParser := nil;
  FInternRecordBuffers := TInternRecordBuffers.Create(Self);
  FLocateNext := False;
  FSortDef := TIndexDef.Create(nil, '', '', []);
  FTableName := '';
  InGetNextRecords := False;
  PendingBuffers := nil;
  WantedRecord := wrNone;

  BookmarkSize := SizeOf(InternRecordBuffers[0]);

  SetUniDirectional(False);
  FilterOptions := [foNoPartialCompare];

  MySQLDataSets.Add(Self);
end;

function TMySQLDataSet.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
begin
  case (Field.DataType) of
    ftBlob: Result := TMySQLDataSetBlobStream.Create(TMySQLBlobField(Field), Mode);
    ftWideMemo: Result := TMySQLDataSetBlobStream.Create(TMySQLWideMemoField(Field), Mode);
    else Result := inherited CreateBlobStream(Field, Mode);
  end;
end;

procedure TMySQLDataSet.DeactivateFilter();
var
  OldBookmark: TBookmark;
begin
  CheckBrowseMode();
  DisableControls();
  DoBeforeScroll();

  OldBookmark := Bookmark;

  if (Assigned(FilterParser)) then
    FreeAndNil(FilterParser);

  if (not BookmarkValid(OldBookmark)) then
    First()
  else
    Bookmark := OldBookmark;

  DoAfterScroll();
  EnableControls();
end;

procedure TMySQLDataSet.Delete(const Bookmarks: TBookmarks);
begin
  DeleteBookmarks := @Bookmarks;

  Delete();

  DeleteBookmarks := nil;
end;

procedure TMySQLDataSet.DeleteAll();
begin
  DeleteByWhereClause := True;
  try
    Delete();
  finally
    DeleteByWhereClause := False;
  end;
end;

procedure TMySQLDataSet.DeletePendingRecords();
begin
  while (PendingBuffers.Count > 0) do
  begin
    InternRecordBuffers.Delete(InternRecordBuffers.IndexOf(PendingBuffers[0]));
    PendingBuffers.Delete(0);
  end;
  Resync([]);
end;

destructor TMySQLDataSet.Destroy();
begin
  MySQLDataSets.Delete(MySQLDataSets.IndexOf(Self));

  inherited;

  if (Assigned(AppliedBuffers)) then
    AppliedBuffers.Free();
  FSortDef.Free();
  if (Assigned(FilterParser)) then
    FreeAndNil(FilterParser);
  FInternRecordBuffers.Free();
  if (Assigned(PendingBuffers)) then
    PendingBuffers.Free();
end;

function TMySQLDataSet.FindRecord(Restart, GoForward: Boolean): Boolean;
var
  Distance: Integer;
begin
  if (Restart) then
  begin
    Result := RecordCount > 0;
    if (Result) then
      if (GoForward) then
        First()
      else
        Last();
  end
  else
  begin
    if (GoForward) then
      Distance := +1
    else
      Distance := -1;
    Result := MoveBy(Distance) <> 0;
  end;

  SetFound(Result);
end;

procedure TMySQLDataSet.FreeInternRecordBuffer(const InternRecordBuffer: PInternRecordBuffer);
begin
  // Debug 2017-05-10
  Assert(Assigned(InternRecordBuffer));

  if (Assigned(InternRecordBuffer^.NewData) and (InternRecordBuffer^.NewData <> InternRecordBuffer^.OldData)) then
    FreeMem(InternRecordBuffer^.NewData);
  if (Assigned(InternRecordBuffer^.OldData)) then
    FreeMem(InternRecordBuffer^.OldData);

  FreeMem(InternRecordBuffer);
end;

procedure TMySQLDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  FreeMem(Buffer); Buffer := nil;
end;

procedure TMySQLDataSet.GetBookmarkData(Buffer: TRecBuf; Data: TBookmark);
begin
  PPointer(@Data[0])^ := PExternRecordBuffer(Buffer)^.InternRecordBuffer;
end;

function TMySQLDataSet.GetBookmarkFlag(Buffer: TRecBuf): TBookmarkFlag;
begin
  Result := PExternRecordBuffer(Buffer)^.BookmarkFlag;
end;

function TMySQLDataSet.GetCanModify(): Boolean;
begin
  if (not IndexDefs.Updated) then
    UpdateIndexDefs();

  Result := CachedUpdates or FCanModify;
end;

function TMySQLDataSet.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
begin
  Result := Assigned(Pointer(ActiveBuffer()))
    and Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer);
  if (Result and (Length(Buffer) > 0)) then
    if (State = dsOldValue) then
      Result := GetFieldData(Field, @Buffer[0], PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData)
    else
      Result := GetFieldData(Field, @Buffer[0], PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData);
end;

function TMySQLDataSet.GetLibLengths(): MYSQL_LENGTHS;
begin
  Assert(Active);
  Assert(not (csDestroying in ComponentState));
  Assert((ActiveBuffer() = 0) or (PExternRecordBuffer(ActiveBuffer())^.Identifier432 = 432));

  if ((ActiveBuffer() = 0)
    or not Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer)
    or not Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData)) then
    Result := nil
  else
    Result := PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.LibLengths;
end;

function TMySQLDataSet.GetLibRow(): MYSQL_ROW;
begin
  Assert(Active);
  Assert(not (csDestroying in ComponentState));
  Assert((ActiveBuffer() = 0) or (PExternRecordBuffer(ActiveBuffer())^.Identifier432 = 432));
  // AV: 2017-06-01 - CallStack WMTimer, ActivateHint

  if ((ActiveBuffer() = 0)
    or not Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer)
    or not Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData)) then
    Result := nil
  else
  begin
    Assert(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.Identifier123 = 123,
      'Identifier123: ' + IntToStr(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.Identifier123) + #13#10
      + 'Destroying: ' + BoolToStr(csDestroying in ComponentState, True));
    // Occurred: 2017-05-22 - CallStack WMTimer, ActivateHint, Identifier123: 4, Destroing: False
    // Occurred: 2017-05-25 - CallStack aDDeleteRecordExecute, DrawCell: Identifier123: 132272, Destroing: False

    Assert(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.Identifier963 = 963,
      'Identifier963: ' + IntToStr(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.Identifier963));

    Result := PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.LibRow;
  end;
end;

function TMySQLDataSet.GetMaxTextWidth(const Field: TField; const TextWidth: TTextWidth): Integer;
var
  I: Integer;
  Index: Integer;
begin
  if (InternRecordBuffers.Count = 0) then
    Result := TextWidth(StringOfChar('e', Field.DisplayWidth))
  else
    Result := 10;

  InternRecordBuffersCS.Enter();
  Index := Field.FieldNo - 1;
  if ((not (Field.DataType in [ftWideString, ftWideMemo]))) then
    for I := 0 to InternRecordBuffers.Count - 1 do
      Result := Max(Result, TextWidth(LibUnpack(InternRecordBuffers[I]^.NewData^.LibRow^[Index], InternRecordBuffers[I]^.NewData^.LibLengths^[Index])))
  else
    for I := 0 to InternRecordBuffers.Count - 1 do
    begin
      // Debug 2017-04-01
      Assert(Assigned(InternRecordBuffers[I]^.NewData^.LibRow));
      Assert(Assigned(InternRecordBuffers[I]^.NewData^.LibLengths));

      Result := Max(Result, TextWidth(LibDecode(FieldCodePage(Field), InternRecordBuffers[I]^.NewData^.LibRow^[Index], InternRecordBuffers[I]^.NewData^.LibLengths^[Index])));
    end;
  InternRecordBuffersCS.Leave();
end;

function TMySQLDataSet.GetNextRecords(): Integer;
begin
  InGetNextRecords := True;

  Result := inherited;

  InGetNextRecords := False;
end;

function TMySQLDataSet.GetPendingRecordCount(): Integer;
begin
  if (not Assigned(PendingBuffers)) then
    Result := 0
  else
    Result := PendingBuffers.Count;
end;

function TMySQLDataSet.GetRecNo(): Integer;
begin
  if (PExternRecordBuffer(ActiveBuffer())^.BookmarkFlag <> bfCurrent) then
    Result := -1
  else
    Result := PExternRecordBuffer(ActiveBuffer())^.Index;
end;

function TMySQLDataSet.GetRecord(Buffer: TRecBuf; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
  NewIndex: Integer;
  Wait: Boolean;
begin
  NewIndex := InternRecordBuffers.Index;
  case (GetMode) of
    gmCurrent:
      if (Filtered) then
      begin
        if (NewIndex < 0) then
          Result := grBOF
        else if (NewIndex < InternRecordBuffers.Count) then
          repeat
            if (not Filtered or InternRecordBuffers[NewIndex]^.VisibleInFilter) then
              Result := grOk
            else if (NewIndex + 1 = InternRecordBuffers.Count) then
              Result := grEOF
            else
            begin
              Result := grError;
              Inc(NewIndex);
            end;
          until (Result <> grError)
        else
        begin
          Result := grEOF;
          NewIndex := InternRecordBuffers.Count - 1;
        end;
        while ((Result = grEOF) and (NewIndex > 0)) do
          if (not Filtered or InternRecordBuffers[NewIndex]^.VisibleInFilter) then
            Result := grOk
          else
            Dec(NewIndex);
      end
      else if ((0 <= NewIndex) and (NewIndex < InternRecordBuffers.Count)) then
        Result := grOk
      else
        Result := grEOF;
    gmNext:
      if ((State = dsInsert) and (InternRecordBuffers.Count = 1)) then
        Result := grEOF
      else
      begin
        Result := grError;
        while (Result = grError) do
        begin
          if (NewIndex + 1 = InternRecordBuffers.Count) then
          begin
            InternRecordBuffersCS.Enter();
            Wait := (NewIndex + 1 = InternRecordBuffers.Count) and not Filtered
              and (Assigned(SyncThread) and (RecordsReceived.WaitFor(IGNORE) <> wrSignaled)
                or not Assigned(SyncThread) and (Self is TMySQLTable) and not InGetNextRecords and TMySQLTable(Self).LimitedDataReceived and TMySQLTable(Self).AutomaticLoadNextRecords and TMySQLTable(Self).LoadNextRecords());
            if (Wait) then
              RecordReceived.ResetEvent();
            InternRecordBuffersCS.Leave();
            if (Wait
              and (RecordReceived.WaitFor(100) = wrTimeout)) then
            begin
              InternRecordBuffersCS.Enter();
              if (RecordReceived.WaitFor(IGNORE) <> wrSignaled) then
                WantedRecord := wrNext;
              InternRecordBuffersCS.Leave();
            end;
          end;

          if (NewIndex + 1 >= InternRecordBuffers.Count) then
            Result := grEOF
          else
          begin
            Inc(NewIndex);
            if (not Filtered or InternRecordBuffers[NewIndex]^.VisibleInFilter) then
              Result := grOk;
          end;
        end;
      end;
    gmPrior:
      begin
        Result := grError;
        while (Result = grError) do
          if (NewIndex < 0) then
            Result := grBOF
          else
          begin
            Dec(NewIndex);
            if ((0 <= NewIndex) and (NewIndex < InternRecordBuffers.Count)
              and (not Filtered or InternRecordBuffers[NewIndex]^.VisibleInFilter)) then
              Result := grOk;
          end;
      end;
    else
      raise ERangeError.Create(SRangeError);
  end;

  if (Result = grOk) then
  begin
    InternRecordBuffersCS.Enter();
    InternRecordBuffers.Index := NewIndex;

    PExternRecordBuffer(Buffer)^.Index := InternRecordBuffers.Index;
    PExternRecordBuffer(Buffer)^.InternRecordBuffer := InternRecordBuffers[InternRecordBuffers.Index];
    PExternRecordBuffer(Buffer)^.BookmarkFlag := bfCurrent;

    InternRecordBuffersCS.Leave();
  end;
end;

function TMySQLDataSet.GetRecordCount(): Integer;
begin
  if (Filtered) then
    Result := InternRecordBuffers.FilteredRecordCount
  else
    Result := InternRecordBuffers.Count;
end;

function TMySQLDataSet.GetUniDirectional(): Boolean;
begin
  Result := False;
end;

procedure TMySQLDataSet.InternActivateFilter();
var
  I: Integer;
begin
  if (Assigned(FilterParser)) then
    FilterParser.Free();
  FilterParser := TExprParser.Create(Self, Filter, FilterOptions, [poExtSyntax], '', nil, FldTypeMap);

  InternRecordBuffersCS.Enter();

  InternRecordBuffers.FilteredRecordCount := 0;
  for I := 0 to InternRecordBuffers.Count - 1 do
  begin
    InternRecordBuffers[I]^.VisibleInFilter := VisibleInFilter(InternRecordBuffers[I]);
    if (InternRecordBuffers[I]^.VisibleInFilter) then
      Inc(InternRecordBuffers.FilteredRecordCount);
  end;

  InternRecordBuffersCS.Leave();
end;

function TMySQLDataSet.InternAddRecord(const LibRow: MYSQL_ROW; const LibLengths: MYSQL_LENGTHS; const Index: Integer = -1): Boolean;
var
  Data: TMySQLQuery.TRecordBufferData;
  I: Integer;
  InternRecordBuffer: PInternRecordBuffer;
begin
  if (not Assigned(LibRow)) then
    Result := True
  else
  begin
    InternRecordBuffer := AllocInternRecordBuffer();

    if (not Assigned(InternRecordBuffer)) then
      Result := False
    else
    begin
      Data.LibLengths := LibLengths;
      Data.LibRow := LibRow;

      Result := MoveRecordBufferData(InternRecordBuffer^.OldData, @Data);
      if (not Result) then
        FreeInternRecordBuffer(InternRecordBuffer)
      else
      begin
        // Debug 2017-03-01
        Assert(Assigned(InternRecordBuffer^.OldData));

        InternRecordBuffer^.NewData := InternRecordBuffer^.OldData;
        InternRecordBuffer^.VisibleInFilter := not Filtered or VisibleInFilter(InternRecordBuffer);

        if (Filtered and InternRecordBuffer^.VisibleInFilter) then
          Inc(InternRecordBuffers.FilteredRecordCount);

        InternRecordBuffersCS.Enter();
        if (Index >= 0) then
          InternRecordBuffers.Insert(Index, InternRecordBuffer)
        else
          InternRecordBuffers.Add(InternRecordBuffer);
        for I := 0 to FieldCount - 1 do
          Inc(FDataSize, Data.LibLengths^[I]);
        InternRecordBuffersCS.Leave();
      end;
    end;
  end;
end;

procedure TMySQLDataSet.InternalAddRecord(Buffer: Pointer; Append: Boolean);
var
  Success: Boolean;
begin
  if (not Append and (InternRecordBuffers.Count > 0)) then
    Success := InternAddRecord(PExternRecordBuffer(Buffer)^.InternRecordBuffer^.NewData^.LibRow, PExternRecordBuffer(Buffer)^.InternRecordBuffer^.NewData^.LibLengths, InternRecordBuffers.Index)
  else
    Success := InternAddRecord(PExternRecordBuffer(Buffer)^.InternRecordBuffer^.NewData^.LibRow, PExternRecordBuffer(Buffer)^.InternRecordBuffer^.NewData^.LibLengths);

  if (not Success) then
    Connection.DoError(DS_OUT_OF_MEMORY, StrPas(CLIENT_ERRORS[DS_OUT_OF_MEMORY - DS_MIN_ERROR]));
end;

procedure TMySQLDataSet.InternalCancel();
var
  Index: Integer;
begin
  case (PExternRecordBuffer(ActiveBuffer())^.BookmarkFlag) of
    bfBOF,
    bfEOF:
      begin
        FreeInternRecordBuffer(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer);
        InternalInitRecord(ActiveBuffer());
      end;
    bfCurrent:
      if (PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData <> PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData) then
      begin
        FreeMem(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData);
        PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData := PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData;
      end;
    bfInserted:
      begin
        Index := PExternRecordBuffer(ActiveBuffer())^.Index;
        FreeInternRecordBuffer(InternRecordBuffers[Index]);
        InternRecordBuffers.Delete(Index);
        InternalInitRecord(ActiveBuffer());
      end;
  end;
end;

procedure TMySQLDataSet.InternalClose();
begin
  if (Assigned(SyncThread) and (SyncThread = Connection.SyncThread)
    and not CachedUpdates) then
    Connection.Terminate();

  FSortDef.Fields := '';

  FCursorOpen := False;

  inherited;

  InternRecordBuffers.Clear();
  InternRecordBuffers.FilteredRecordCount := 0;
  FDataSize := 0;
end;

procedure TMySQLDataSet.InternalDelete();
var
  I: Integer;
  Index: Integer;
  SQL: string;
  Success: Boolean;
begin
  WantedRecord := wrNone;

  if (not CachedUpdates) then
  begin
    SQL := SQLDelete();
    if (Connection.DatabaseName <> DatabaseName) then
      SQL := Connection.SQLUse(DatabaseName) + SQL;
    Success := Connection.ExecuteSQL(SQL);
    if (Success and (Connection.RowsAffected = 0)) then
      raise EDatabasePostError.Create(SRecordChanged);

    InternRecordBuffersCS.Enter();
    if (DeleteByWhereClause) then
    begin
      InternRecordBuffers.Clear();
      if ((BufferCount > 0) and (ActiveBuffer() > 0)) then
        InternalInitRecord(ActiveBuffer());
      for I := 0 to BufferCount - 1 do
        InternalInitRecord(Buffers[I]);
    end
    else if (not Assigned(DeleteBookmarks)) then
    begin
      FreeInternRecordBuffer(InternRecordBuffers[InternRecordBuffers.Index]);
      InternRecordBuffers.Delete(InternRecordBuffers.Index);
      if (Filtered) then
        Dec(InternRecordBuffers.FilteredRecordCount);
    end
    else
    begin
      for I := 0 to Length(DeleteBookmarks^) - 1 do
      begin
        Index := InternRecordBuffers.IndexOf(DeleteBookmarks^[I]);

        // Debug 2017-05-25
        Assert(Index >= 0);

        FreeInternRecordBuffer(InternRecordBuffers[Index]);
        InternRecordBuffers.Delete(Index);
        if (Filtered) then
          Dec(InternRecordBuffers.FilteredRecordCount);
      end;
      if ((BufferCount > 0) and (ActiveBuffer() > 0)) then
        InternalInitRecord(ActiveBuffer());
      for I := 0 to BufferCount - 1 do
        InternalInitRecord(Buffers[I]);
    end;
    InternRecordBuffersCS.Leave();

    if ((BufferCount > 0) and (ActiveBuffer() > 0)) then
      PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer := nil;
  end;
end;

procedure TMySQLDataSet.InternalEdit();
begin
  WantedRecord := wrNone;
end;

procedure TMySQLDataSet.InternalFirst();
begin
  InternRecordBuffers.Index := -1;
end;

procedure TMySQLDataSet.InternalGotoBookmark(Bookmark: TBookmark);
var
  Index: Integer;
begin
  Index := InternRecordBuffers.IndexOf(Bookmark);

  if (Index >= 0) then
  begin
    InternRecordBuffers.Index := Index;

    // Prepare for Resync()
    // This is a bad solution, but in Resync the index will be taken from
    // ActiveBuffer...
    PExternRecordBuffer(ActiveBuffer())^.Index := Index;
  end;
end;

procedure TMySQLDataSet.InternalInitFieldDefs();
var
  FieldInfo: TFieldInfo;
  I: Integer;
  UniqueTableName: Boolean;
begin
  inherited;

  if (Self is TMySQLTable) then
    FTableName := CommandText
  else
  begin
    UniqueTableName := True;
    for I := 0 to FieldCount - 1 do
      if (GetFieldInfo(Fields[I].Origin, FieldInfo)) then
      begin
        if (TableName = '') then
          FTableName := FieldInfo.TableName;
        UniqueTableName := UniqueTableName and ((TableName = '') or (TableName = FieldInfo.TableName));
      end;

    if (not UniqueTableName) then
      FTableName := '';
  end;
end;

procedure TMySQLDataSet.InternalInitRecord(Buffer: TRecBuf);
begin
  PExternRecordBuffer(Buffer)^.Index := -1;
  PExternRecordBuffer(Buffer)^.InternRecordBuffer := nil;
  PExternRecordBuffer(Buffer)^.BookmarkFlag := bfCurrent;
end;

procedure TMySQLDataSet.InternalInsert();
var
  I: Integer;
  Index: Integer;
  RBS: RawByteString;
begin
  WantedRecord := wrNone;

  case (PExternRecordBuffer(ActiveBuffer())^.BookmarkFlag) of
    bfBOF,
    bfEOF:
      begin
        PExternRecordBuffer(ActiveBuffer())^.Index := -1;
        PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer := AllocInternRecordBuffer();
      end;
    bfInserted:
      begin
        Index := InternRecordBuffers.IndexOf(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer);

        Assert(Index >= 0,
          'Identifier123: ' + IntToStr(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer.Identifier123));

        InternRecordBuffers.Insert(Index, AllocInternRecordBuffer());
        PExternRecordBuffer(ActiveBuffer())^.Index := Index;
        PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer := InternRecordBuffers[Index];
      end;
    else
      raise ERangeError.Create(SRangeError);
  end;

  if (Filtered) then
    Inc(InternRecordBuffers.FilteredRecordCount);

  for I := 0 to FieldCount - 1 do
    if (Fields[I].DefaultExpression <> '') then
    begin
      RBS := LibEncode(FieldCodePage(Fields[I]), SQLUnescape(Fields[I].DefaultExpression));
      SetFieldData(Fields[I], @RBS[1], Length(RBS));
    end
    else if (Fields[I].Required and (Fields[I].DataType in BinaryDataTypes * TextDataTypes)) then
      SetFieldData(Fields[I], Pointer(1), 0);
end;

procedure TMySQLDataSet.InternalLast();
begin
  Connection.TerminateCS.Enter();
  if (Assigned(SyncThread) and (SyncThread.State = ssReceivingResult)) then
    WantedRecord := wrLast
  else
    InternRecordBuffers.Index := InternRecordBuffers.Count;
  Connection.TerminateCS.Leave();
end;

procedure TMySQLDataSet.InternalOpen();
var
  DescFieldNames: string;
  FieldNames: string;
  NewSortDef: TIndexDef;
begin
  Assert(not IsCursorOpen());

  FCursorOpen := True;

  RecordsReceived.ResetEvent();

  inherited;

  if (Connection.SQLParser.ParseSQL(CommandText)
    and GetOrderFromSelectStmt(Connection.SQLParser.FirstStmt, FieldNames, DescFieldNames)) then
  begin
    NewSortDef := TIndexDef.Create(nil, '', FieldNames, []);
    NewSortDef.DescFields := DescFieldNames;
    SortDef.Assign(NewSortDef);
    NewSortDef.Free();
  end;
  Connection.SQLParser.Clear();

  SetFieldsSortTag();
end;

procedure TMySQLDataSet.InternalPost();
var
  AllWhereFieldsInWhere: Boolean;
  AutoGeneratedValues: Boolean;
  CheckPosition: Boolean; // Checks the position of the record (internally or externally)
  ControlPosition: Boolean; // Checks the position of the record externally
  ControlSQL: string;
  Field: TField;
  FieldName: string;
  I: Integer;
  J: Integer;
  SQL: string;
  Pos: Integer;
  RowCount: Integer;
  Update: Boolean;
  WhereClause: string;
  WhereFields: array of TField;
begin
  if (CachedUpdates) then
  begin
    case (PExternRecordBuffer(ActiveBuffer())^.BookmarkFlag) of
      bfBOF,
      bfEOF:
        begin
          // Debug 2017-05-10
          Assert(Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer));

          PExternRecordBuffer(ActiveBuffer())^.Index := InternRecordBuffers.Add(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer);
        end;
    end;
    if ((InternRecordBuffers.Index >= 0)
      and (PendingBuffers.IndexOf(InternRecordBuffers[InternRecordBuffers.Index]) < 0)) then
      PendingBuffers.Add(InternRecordBuffers[InternRecordBuffers.Index]);
  end
  else
  begin
    AutoGeneratedValues := False;
    CheckPosition := False;
    ControlPosition := False;

    Update := PExternRecordBuffer(ActiveBuffer())^.BookmarkFlag = bfCurrent;

    for I := 0 to FieldCount - 1 do
      if (Fields[I].AutoGenerateValue <> arNone) then
        AutoGeneratedValues := True;

    Pos := 1;
    while (Pos <= Length(SortDef.Fields)) do
    begin
      FieldName := ExtractFieldName(SortDef.Fields, Pos);
      if (FieldName <> '') then
      begin
        Field := FindField(FieldName);
        if (not Assigned(Field)) then
        begin
          ControlPosition := False;
          break;
        end;
        if (not Update or (Field.NewValue <> Field.OldValue)) then
        begin
          CheckPosition := True;
          if ((Field.DataType in TextDataTypes)
            or (Field.AutoGenerateValue = arDefault)) then
            ControlPosition := True;
        end;
      end;
    end;

    if (not (Self is TMySQLTable)) then
      SQL := CommandText
    else
      SQL := TMySQLTable(Self).SQLSelect();

    if ((SQL = '')
      or not Connection.SQLParser.ParseSQL(PChar(SQL), Length(SQL))
      or not AutoGeneratedValues and not ControlPosition) then
      ControlSQL := ''
    else
    begin
      SetLength(WhereFields, 0);

      if (not ControlPosition) then
      begin
        for I := 0 to Fields.Count - 1 do
          if (pfInWhere in Fields[I].ProviderFlags) then
          begin
            SetLength(WhereFields, Length(WhereFields) + 1);
            WhereFields[Length(WhereFields) - 1] := Fields[I];
          end;
      end
      else
      begin
        Pos := 1;
        repeat
          FieldName := ExtractFieldName(SortDef.Fields, Pos);
          if (FieldName <> '') then
          begin
            Field := FindField(FieldName);
            if (not Assigned(Field)) then
              raise ERangeError.CreateFMT(SFieldNotFound, [FieldName]);
            SetLength(WhereFields, Length(WhereFields) + 1);
            WhereFields[Length(WhereFields) - 1] := Field;
          end;
        until (FieldName = '');
      end;
      if (Length(WhereFields) = 0) then
      begin
        SetLength(WhereFields, FieldCount);
        for I := 0 to Fields.Count - 1 do
          WhereFields[I] := Fields[I];
      end;

      AllWhereFieldsInWhere := True;
      for I := 0 to FieldCount - 1 do
        if (AllWhereFieldsInWhere and (pfInWhere in Fields[I].ProviderFlags)) then
        begin
          AllWhereFieldsInWhere := False;
          for J := 0 to Length(WhereFields) - 1 do
            if (WhereFields[J] = Fields[I]) then
              AllWhereFieldsInWhere := True;
        end;
      if (AllWhereFieldsInWhere) then
        for I := Length(WhereFields) - 1 downto 0 do
          if (not (pfInWhere in WhereFields[I].ProviderFlags)) then
          begin
            if (I < Length(WhereFields) - 1) then
              MoveMemory(@WhereFields[I], @WhereFields[I + 1], SizeOf(WhereFields[0]));
            SetLength(WhereFields, Length(WhereFields) - 1);
          end;

      WhereClause := '';
      for I := 0 to Length(WhereFields) - 2 do
        if (not WhereFields[I].IsNull) then
        begin
          if (WhereClause <> '') then WhereClause := WhereClause + ' AND ';
          WhereClause := WhereClause
            + Connection.EscapeIdentifier(WhereFields[I].FieldName)
            + '='
            + SQLFieldValue(WhereFields[I], TRecordBuffer(PExternRecordBuffer(ActiveBuffer())));
        end
        else if (WhereFields[I].AutoGenerateValue = arAutoInc) then
        begin
          if (WhereClause <> '') then WhereClause := WhereClause + ' AND ';
          WhereClause := WhereClause
            + Connection.EscapeIdentifier(WhereFields[I].FieldName)
            + '='
            + 'LAST_INSERT_ID()';
        end;
      if (not WhereFields[Length(WhereFields) - 1].IsNull
        or ((WhereFields[Length(WhereFields) - 1].AutoGenerateValue = arAutoInc) and (WhereFields[Length(WhereFields) - 1].AsString = '0'))) then
      begin
        if (WhereClause <> '') then WhereClause := WhereClause + ' AND ';
        WhereClause := WhereClause + Connection.EscapeIdentifier(WhereFields[Length(WhereFields) - 1].FieldName);
        if (not ControlPosition) then
          WhereClause := WhereClause + '='
        else if (WhereFields[Length(WhereFields) - 1].Tag and ftDescSortedField = 0) then
          WhereClause := WhereClause + '>='
        else
          WhereClause := WhereClause + '<=';
        WhereClause := WhereClause + SQLFieldValue(WhereFields[Length(WhereFields) - 1], TRecordBuffer(PExternRecordBuffer(ActiveBuffer())));
      end
      else if (WhereFields[Length(WhereFields) - 1].AutoGenerateValue = arAutoInc) then
      begin
        if (WhereClause <> '') then WhereClause := WhereClause + ' AND ';
        WhereClause := WhereClause + Connection.EscapeIdentifier(WhereFields[Length(WhereFields) - 1].FieldName);
        if (not ControlPosition) then
          WhereClause := WhereClause + '='
        else if (WhereFields[Length(WhereFields) - 1].Tag and ftDescSortedField = 0) then
          WhereClause := WhereClause + '>='
        else
          WhereClause := WhereClause + '<=';
        WhereClause := WhereClause + 'LAST_INSERT_ID()';
      end;

      if (ControlPosition) then
      begin
        for I := 1 to Length(WhereFields) - 1 do
        begin
          WhereClause := WhereClause + ' OR ';

          for J := 0 to Length(WhereFields) - I - 1 do
          begin
            if (J > 0) then WhereClause := WhereClause + ' AND ';

            WhereClause := WhereClause + Connection.EscapeIdentifier(WhereFields[J].FieldName);

            if (J < Length(WhereFields) - I - 1) then
            begin
              if (not WhereFields[J].IsNull) then
                WhereClause := WhereClause + '=' + SQLFieldValue(WhereFields[J], TRecordBuffer(PExternRecordBuffer(ActiveBuffer())))
              else if (WhereFields[J].AutoGenerateValue = arAutoInc) then
                WhereClause := WhereClause + '=LAST_INSERT_ID()'
              else
                WhereClause := WhereClause + ' IS NULL';
            end
            else
            begin
              if (not WhereFields[J].IsNull) then
                if (WhereFields[J].Tag and ftDescSortedField = 0) then
                  WhereClause := WhereClause + '>' + SQLFieldValue(WhereFields[J], TRecordBuffer(PExternRecordBuffer(ActiveBuffer())))
                else
                  WhereClause := WhereClause + '<' + SQLFieldValue(WhereFields[J], TRecordBuffer(PExternRecordBuffer(ActiveBuffer())))
              else if (WhereFields[J].AutoGenerateValue = arAutoInc) then
                WhereClause := WhereClause + '=LAST_INSERT_ID()'
              else
                WhereClause := WhereClause + ' IS NOT NULL';
            end;
          end;
        end;

        if (WhereClause = '') then
          ControlSQL := ''
        else
        begin
          SQL := ExpandSelectStmtWhereClause(Connection.SQLParser.FirstStmt, WhereClause);

          if (not Connection.SQLParser.ParseSQL(SQL)) then
            ControlSQL := ''
          else
          begin
            if (not ControlPosition) then
              RowCount := -1
            else
              RowCount := 2;
            ControlSQL := ReplaceSelectStmtLimit(Connection.SQLParser.FirstStmt, 0, RowCount);

            if (ControlSQL <> '') then
              ControlSQL := ControlSQL + #13#10;
          end;
        end;
      end;
    end;

    Connection.SQLParser.Clear();

    if (Update) then
      SQL := SQLUpdate()
    else
      SQL := SQLInsert();
    if (SQL = '') then
      raise EDatabaseUpdateError.Create(SNoUpdate)
    else
    begin
      SQL := SQL + ControlSQL;

      if (Connection.DatabaseName <> DatabaseName) then
        SQL := Connection.SQLUse(DatabaseName) + SQL;

      InternalPostResult.InternRecordBuffer := PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer;
      InternalPostResult.Exception := nil;
      InternalPostResult.NewIndex := PExternRecordBuffer(ActiveBuffer())^.Index;

      Connection.BeginSilent();
      Connection.BeginSynchron(4);
      Connection.InternExecuteSQL(smSQL, SQL, InternalPostEvent);
      Connection.EndSynchron(4);
      Connection.EndSilent();

      if (Assigned(InternalPostResult.Exception)) then
        raise InternalPostResult.Exception;

      if (PExternRecordBuffer(ActiveBuffer())^.BookmarkFlag in [bfBOF, bfEOF]) then
      begin
        // Debug 2017-05-10
        Assert(Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer));

        PExternRecordBuffer(ActiveBuffer())^.Index := InternRecordBuffers.Add(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer);
      end;

      if ((ControlSQL = '') and CheckPosition) then
      begin
        InternalPostResult.NewIndex := InternRecordBuffers.IndexFor(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^, PExternRecordBuffer(ActiveBuffer())^.Index);
        if (InternalPostResult.NewIndex < 0) then
          InternalPostResult.NewIndex := InternRecordBuffers.Count - 1
        else if (InternalPostResult.NewIndex > PExternRecordBuffer(ActiveBuffer())^.Index) then
          Dec(InternalPostResult.NewIndex);
      end;

      if ((InternalPostResult.NewIndex >= 0)
        and ((PExternRecordBuffer(ActiveBuffer())^.Index < 0) or (PExternRecordBuffer(ActiveBuffer())^.Index <> InternalPostResult.NewIndex))) then
      begin
        // Position in InternRecordBuffers changed -> move it!

        // Debug 2017-03-02
        Assert((PExternRecordBuffer(ActiveBuffer())^.Index >= 0)
          and (InternalPostResult.NewIndex >= 0),
          'BookmarkFlag: ' + IntToStr(Ord(PExternRecordBuffer(ActiveBuffer())^.BookmarkFlag)) + #13#10
          + 'Index: ' + IntToStr(PExternRecordBuffer(ActiveBuffer())^.Index) + #13#10
          + 'NewIndex: ' + IntToStr(InternalPostResult.NewIndex));

        InternRecordBuffers.Move(PExternRecordBuffer(ActiveBuffer())^.Index, InternalPostResult.NewIndex);
        InternRecordBuffers.Index := InternalPostResult.NewIndex;
        PExternRecordBuffer(ActiveBuffer())^.Index := InternRecordBuffers.Index;
      end;
    end;
  end;
end;

function TMySQLDataSet.InternalPostEvent(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
  const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
var
  DataSet: TMySQLQuery;
  EqualFieldNames: Boolean;
  I: Integer;
  Index: Integer;
  RBS: RawByteString;
  Parse: TSQLParse;
  RecordBufferData: TMySQLQuery.TRecordBufferData;
  RecordMatch: Boolean;
  Update: Boolean;
begin
  Result := False;

  if (SQLCreateParse(Parse, PChar(CommandText), Length(CommandText), Connection.MySQLVersion)) then
  begin
    Update := SQLParseKeyword(Parse, 'UPDATE');
    if (Update or SQLParseKeyword(Parse, 'INSERT')) then
    begin
      if (ErrorCode <> 0) then
        InternalPostResult.Exception := EMySQLError.Create(ErrorMessage, ErrorCode, Connection)
      else if (Update and (Connection.RowsAffected = 0)) then
        InternalPostResult.Exception := EDatabasePostError.Create(SRecordChanged)
      else
      begin
        if (not Update) then
          for I := 0 to Fields.Count - 1 do
            if ((Fields[I].AutoGenerateValue = arAutoInc) and (Connection.InsertId > 0)) then
            begin
              RBS := RawByteString(IntToStr(Connection.InsertId));
              SetFieldData(Fields[I], PAnsiChar(RBS), Length(RBS), InternalPostResult.InternRecordBuffer);
            end;

        if (InternalPostResult.InternRecordBuffer^.OldData <> InternalPostResult.InternRecordBuffer^.NewData) then
          FreeMem(InternalPostResult.InternRecordBuffer^.OldData);

        InternalPostResult.InternRecordBuffer^.OldData := InternalPostResult.InternRecordBuffer^.NewData;
      end;
    end
    else if ((ErrorCode = 0) and SQLParseKeyword(Parse, 'SELECT')) then
    begin
      Result := True;

      DataSet := TMySQLQuery.Create(nil);
      DataSet.Open(DataHandle);

      if (not Assigned(InternalPostResult.Exception)) then
        if (DataSet.IsEmpty) then
        begin
          // Inserted / updated record is not in external filtered rows -> remove it
          Index := PExternRecordBuffer(ActiveBuffer())^.Index;
          FreeInternRecordBuffer(InternRecordBuffers[Index]);
          if (Index >= 0) then
          begin
            InternRecordBuffers.Delete(Index);
            if (Filtered) then
              Dec(InternRecordBuffers.FilteredRecordCount);
          end;
        end
        else
        begin
          EqualFieldNames := DataSet.FieldCount = FieldCount;
          if (EqualFieldNames) then
            for I := 0 to DataSet.FieldCount - 1 do
              EqualFieldNames := EqualFieldNames and (DataSet.Fields[I].FieldName = Fields[I].FieldName);
          if (not EqualFieldNames) then
            RecordMatch := False
          else
          begin
            RecordMatch := True;
            for I := 0 to DataSet.FieldCount - 1 do
              if (pfInWhere in Fields[I].ProviderFlags) then
                RecordMatch := RecordMatch and (DataSet.Fields[I].Value = Fields[I].Value);
            if (not RecordMatch) then
            begin
              // Inserted / updated record not in external filtered rows -> removed it
              Index := PExternRecordBuffer(ActiveBuffer())^.Index;
              if (Index >= 0) then
              begin
                FreeInternRecordBuffer(InternRecordBuffers[Index]);
                InternRecordBuffers.Delete(Index);
                if (Filtered) then
                  Dec(InternRecordBuffers.FilteredRecordCount);
              end;
            end
            else
            begin
              // Inserted / updated record matched -> update data of the record
              for I := 0 to DataSet.FieldCount - 1 do
                if (not (pfInWhere in Fields[I].ProviderFlags)) then
                  SetFieldData(Fields[I], DataSet.LibRow^[I], DataSet.LibLengths[I]);
            end;
          end;

          if (RecordMatch) then
          begin
            DataSet.FindNext();

            if (not DataSet.Eof) then
            begin
              // 2nd record found in SELECT -> Find position in InternRecordBuffers
              RecordBufferData.LibLengths := DataSet.LibLengths;
              RecordBufferData.LibRow := DataSet.LibRow;

              InternalPostResult.NewIndex := InternRecordBuffers.IndexFor(RecordBufferData, PExternRecordBuffer(ActiveBuffer())^.Index);
              if (InternalPostResult.NewIndex < 0) then
                InternalPostResult.NewIndex := InternRecordBuffers.Count - 1
              else if (InternalPostResult.NewIndex > PExternRecordBuffer(ActiveBuffer())^.Index) then
                Dec(InternalPostResult.NewIndex);
            end
            else
            begin
              // 2nd record not found -> End of InternRecordBuffers
              InternalPostResult.NewIndex := InternRecordBuffers.Count - 1;
            end;
          end;
        end;
      DataSet.Free();
    end;
  end;
end;

procedure TMySQLDataSet.InternalRefresh();
var
  I: Integer;
  SQL: string;
begin
  Progress := Progress + 'R';

  Connection.Terminate();

  InternRecordBuffers.Clear();
  if ((BufferCount > 0) and (ActiveBuffer() > 0)) then
    InternalInitRecord(ActiveBuffer());
  for I := 0 to BufferCount - 1 do
    InternalInitRecord(Buffers[I]);

  RecordsReceived.ResetEvent();

  if ((CommandType = ctTable) and (Self is TMySQLTable)) then
    SQL := TMySQLTable(Self).SQLSelect()
  else
    SQL := CommandText;

  if (SQL <> '') then
  begin
    Connection.InternExecuteSQL(smDataSet, SQL, TMySQLConnection.TResultEvent(nil), nil, Self);
    WantedRecord := wrFirst;
  end;
end;

procedure TMySQLDataSet.InternalSetToRecord(Buffer: TRecBuf);
begin
  InternRecordBuffers.Index := PExternRecordBuffer(Buffer)^.Index;
end;

function TMySQLDataSet.IsCursorOpen(): Boolean;
begin
  Result := FCursorOpen;
end;

function TMySQLDataSet.Locate(const KeyFields: string; const KeyValues: Variant;
  Options: TLocateOptions): Boolean;
var
  Bookmark: TBookmark;
  FieldNames: TCSVStrings;
  Fields: array of TField;
  FmtStrs: array of string;
  I: Integer;
  Index: Integer;
  L: Largeint;
  S: string;
  Values: array of string;
begin
  CheckBrowseMode();

  SetLength(FieldNames, 0);
  CSVSplitValues(KeyFields, ';', #0, FieldNames);
  SetLength(Fields, 0);
  for I := 0 to Length(FieldNames) - 1 do
    if (Assigned(FindField(FieldNames[I]))) then
    begin
      SetLength(Fields, Length(Fields) + 1);
      Fields[Length(Fields) - 1] := FieldByName(FieldNames[I]);
    end;

  SetLength(FmtStrs, Length(Fields));
  for I := 0 to Length(Fields) - 1 do
    if (Fields[I] is TMySQLBitField) then
    begin
      FmtStrs[I] := TMySQLBitField(Fields[I]).DisplayFormat;
      while ((Length(FmtStrs[I]) > 0) and (FmtStrs[I][1] = '#')) do System.Delete(FmtStrs[I], 1, 1);
    end;

  if (not VarIsArray(KeyValues)) then
  begin
    SetLength(Values, 1);
    Values[0] := KeyValues;
  end
  else
  begin
    SetLength(Values, Length(Fields));
    try
      for I := 0 to Length(Fields) - 1 do
        Values[I] := KeyValues[I];
    except
      SetLength(Values, 0);
    end;
  end;
  if ((loCaseInsensitive in Options) and (loPartialKey in Options)) then
    for I := 0 to Length(Values) - 1 do
      Values[I] := LowerCase(Values[I]);

  Result := (Length(Fields) = Length(FieldNames)) and (Length(Fields) = Length(Values));

  if (Result) then
  begin
    if (not LocateNext) then
      Index := 0
    else
      Index := RecNo + 1;

    Result := False;
    while (not Result and (Index < InternRecordBuffers.Count)) do
    begin
      Result := True;
      for I := 0 to Length(Fields) - 1 do
        if (not Assigned(InternRecordBuffers[Index]^.NewData^.LibRow^[I])) then
          Result := False
        else if (Fields[I] is TMySQLBitField) then
        begin
          L := 0;
          MoveMemory(@L, InternRecordBuffers[Index]^.NewData^.LibRow^[Fields[I].FieldNo - 1], InternRecordBuffers[Index]^.NewData^.LibLengths^[Fields[I].FieldNo - 1]);
          S := IntToBitString(L, Length(FmtStrs[I]));
          if (loPartialKey in Options) then
            Result := Result and (Pos(Values[I], S) > 0)
          else
            Result := Result and (Values[I] = S)
        end
        else if (loCaseInsensitive in Options) then
          if (loPartialKey in Options) then
            Result := Result and (Pos(Values[I], LowerCase(LibDecode(FieldCodePage(Fields[I]), InternRecordBuffers[Index]^.NewData^.LibRow^[Fields[I].FieldNo - 1], InternRecordBuffers[Index]^.NewData^.LibLengths^[Fields[I].FieldNo - 1]))) > 0)
          else
            Result := Result and (lstrcmpi(PChar(Values[I]), PChar(LibDecode(FieldCodePage(Fields[I]), InternRecordBuffers[Index]^.NewData^.LibRow^[Fields[I].FieldNo - 1], InternRecordBuffers[Index]^.NewData^.LibLengths^[Fields[I].FieldNo - 1]))) = 0)
        else
          if (loPartialKey in Options) then
            Result := Result and (Pos(Values[I], LibDecode(FieldCodePage(Fields[I]), InternRecordBuffers[Index]^.NewData^.LibRow^[I], InternRecordBuffers[Fields[I].FieldNo - 1]^.NewData^.LibLengths^[Fields[I].FieldNo - 1])) > 0)
          else
            Result := Result and (lstrcmp(PChar(Values[I]), PChar(LibDecode(FieldCodePage(Fields[I]), InternRecordBuffers[Index]^.NewData^.LibRow^[Fields[I].FieldNo - 1], InternRecordBuffers[Index]^.NewData^.LibLengths^[Fields[I].FieldNo - 1]))) = 0);

      if (not Result) then
        Inc(Index);
    end;

    if (Result) then
    begin
      CheckBrowseMode();
      SetLength(Bookmark, BookmarkSize);
      PPointer(@Bookmark[0])^ := InternRecordBuffers[Index];
      GotoBookmark(Bookmark);
      SetLength(Bookmark, 0);
    end;
  end;

  SetLength(Values, 0);
  SetLength(FieldNames, 0);
end;

procedure TMySQLDataSet.Resync(Mode: TResyncMode);
begin
  // Debug 2017-05-19
  Assert(not (csDestroying in ComponentState));

  if (ActiveBuffer() > 0) then
  begin
    Assert(PExternRecordBuffer(ActiveBuffer())^.Identifier432 = 432,
      'Identifier432: ' + IntToStr(PExternRecordBuffer(ActiveBuffer())^.Identifier432));
    InternRecordBuffers.Index := PExternRecordBuffer(ActiveBuffer())^.Index;
  end;

  inherited;
end;

procedure TMySQLDataSet.SetBookmarkData(Buffer: TRecBuf; Data: TBookmark);
begin
  PExternRecordBuffer(Buffer)^.InternRecordBuffer := PPointer(@Data[0])^;
end;

procedure TMySQLDataSet.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
begin
  PExternRecordBuffer(Buffer)^.BookmarkFlag := Value;
end;

procedure TMySQLDataSet.SetCachedUpdates(AValue: Boolean);
begin
  if (AValue <> FCachedUpdates) then
  begin
    FCachedUpdates := AValue;

    if (FCachedUpdates and not Assigned(PendingBuffers)) then
      PendingBuffers := TList<PInternRecordBuffer>.Create();
  end;
end;

procedure TMySQLDataSet.SetFieldData(Field: TField; Buffer: TValueBuffer);
var
  Len: Integer;
  RBS: RawByteString;
  TS: TTimeStamp;
  U: UInt64;
begin
  if ((Field.AutoGenerateValue <> arAutoInc) or (Length(Buffer) > 0)) then
  begin
    if (Length(Buffer) = 0) then
      SetFieldData(Field, nil, 0)
    else if (BitField(Field)) then
    begin
      ZeroMemory(@U, SizeOf(U));
      MoveMemory(@U, @Buffer[0], Field.DataSize);
      U := SwapUInt64(U);
      Len := SizeOf(U);
      while ((Len > 0) and (PAnsiChar(@U)[SizeOf(U) - Len] = #0)) do Dec(Len);
      SetFieldData(Field, @PAnsiChar(@U)[SizeOf(U) - Len], Len)
    end
    else
    begin
      case (Field.DataType) of
        ftString: SetString(RBS, PAnsiChar(@Buffer[0]), Field.DataSize);
        ftShortInt: RBS := LibPack(FormatFloat(TNumericField(Field).DisplayFormat, ShortInt((@Buffer[0])^), Connection.FormatSettings));
        ftByte: RBS := LibPack(FormatFloat(TNumericField(Field).DisplayFormat, Byte((@Buffer[0])^), Connection.FormatSettings));
        ftSmallInt: RBS := LibPack(FormatFloat(TNumericField(Field).DisplayFormat, SmallInt((@Buffer[0])^), Connection.FormatSettings));
        ftWord: RBS := LibPack(FormatFloat(TNumericField(Field).DisplayFormat, Word((@Buffer[0])^), Connection.FormatSettings));
        ftInteger: RBS := LibPack(FormatFloat(TNumericField(Field).DisplayFormat, Integer((@Buffer[0])^), Connection.FormatSettings));
        ftLongWord: RBS := LibPack(FormatFloat(TNumericField(Field).DisplayFormat, LongWord((@Buffer[0])^), Connection.FormatSettings));
        ftLargeint: RBS := LibPack(UInt64ToStr(UInt64((@Buffer[0])^)));
        ftSingle: RBS := LibPack(FormatFloat(TNumericField(Field).DisplayFormat, Single((@Buffer[0])^), Connection.FormatSettings));
        ftFloat: RBS := LibPack(FormatFloat(TNumericField(Field).DisplayFormat, Double((@Buffer[0])^), Connection.FormatSettings));
        ftExtended: RBS := LibPack(FormatFloat(TNumericField(Field).DisplayFormat, Extended((@Buffer[0])^), Connection.FormatSettings));
        ftDate:
          begin
            TS.Date := TDateTimeRec((@Buffer[0])^).Date;
            TS.Time := 0;
            RBS := LibPack(MySQLDB.DateToStr(TimeStampToDateTime(TS), Connection.FormatSettings));
          end;
        ftDateTime: RBS := LibPack(MySQLDB.DateTimeToStr(TimeStampToDateTime(MSecsToTimeStamp(TDateTimeRec((@Buffer[0])^).DateTime)), Connection.FormatSettings));
        ftTime:
          begin
            TS.Date := DateDelta;
            TS.Time := TDateTimeRec((@Buffer[0])^).Time;
            RBS := LibPack(TimeToStr(TimeStampToDateTime(TS), Connection.FormatSettings));
          end;
        ftTimeStamp: RBS := LibPack(MySQLTimeStampToStr(PSQLTimeStamp((@Buffer[0]))^, TMySQLTimeStampField(Field).DisplayFormat));
        ftBlob: SetString(RBS, PAnsiChar(@Buffer[0]), Length(Buffer));
        ftWideMemo:
          begin
            SetLength(RBS, WideCharToAnsiChar(FieldCodePage(Field), PChar(@Buffer[0]), Length(Buffer) div SizeOf(Char), nil, 0));
            WideCharToAnsiChar(FieldCodePage(Field), PChar(@Buffer[0]), Length(Buffer) div SizeOf(Char), PAnsiChar(RBS), Length(RBS));
          end;
        ftWideString:
          begin
            SetLength(RBS, WideCharToAnsiChar(FieldCodePage(Field), PChar(@Buffer[0]), StrLen(PChar(@Buffer[0])), nil, 0));
            WideCharToAnsiChar(FieldCodePage(Field), PChar(@Buffer[0]), StrLen(PChar(@Buffer[0])), PAnsiChar(RBS), Length(RBS));
          end;
        else raise EDatabaseError.CreateFMT(SUnknownFieldType + '(%d)', [Field.Name, Integer(Field.DataType)]);
      end;
      if (RBS = '') then
        SetFieldData(Field, Pointer(-1), 0)
      else
        SetFieldData(Field, PAnsiChar(RBS), Length(RBS));
    end;

    DataEvent(deFieldChange, Longint(Field));
  end;
end;

procedure TMySQLDataSet.SetFieldData(const Field: TField; const Buffer: Pointer;
  const Size: Integer; InternRecordBuffer: PInternRecordBuffer = nil);
var
  I: Integer;
  Index: Integer;
  MemSize: Integer;
  NewData: TMySQLQuery.PRecordBufferData;
  OldData: TMySQLQuery.PRecordBufferData;
begin
  if (not Assigned(InternRecordBuffer)) then
    InternRecordBuffer := PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer;

  OldData := InternRecordBuffer^.NewData;

  MemSize := SizeOf(NewData^) + FieldCount * (SizeOf(NewData^.LibLengths^[0]) + SizeOf(NewData^.LibRow^[0]));
  for I := 0 to FieldCount - 1 do
    if (I = Field.FieldNo - 1) then
      if (not Assigned(Buffer)) then
        // no data
      else
        Inc(MemSize, Size)
    else if (Assigned(OldData)) then
      Inc(MemSize, OldData^.LibLengths^[I]);

  GetMem(NewData, MemSize);

  NewData^.Identifier963 := 963;
  NewData^.LibLengths := Pointer(@PAnsiChar(NewData)[SizeOf(NewData^)]);
  NewData^.LibRow := Pointer(@PAnsiChar(NewData)[SizeOf(NewData^) + FieldCount * SizeOf(NewData^.LibLengths^[0])]);

  Index := SizeOf(NewData^) + FieldCount * (SizeOf(NewData^.LibLengths^[0]) + SizeOf(NewData^.LibRow^[0]));
  for I := 0 to FieldCount - 1 do
  begin
    if (I = Field.FieldNo - 1) then
      if (not Assigned(Buffer)) then
      begin
        NewData^.LibLengths^[I] := 0;
        NewData^.LibRow^[I] := nil;
      end
      else
      begin
        NewData^.LibLengths^[I] := Size;
        NewData^.LibRow^[I] := Pointer(@PAnsiChar(NewData)[Index]);
        MoveMemory(NewData^.LibRow^[I], Buffer, Size);
      end
    else
      if (not Assigned(OldData) or not Assigned(OldData^.LibRow^[I])) then
      begin
        NewData^.LibLengths^[I] := 0;
        NewData^.LibRow^[I] := nil;
      end
      else
      begin
        NewData^.LibLengths^[I] := OldData^.LibLengths^[I];
        NewData^.LibRow^[I] := Pointer(@PAnsiChar(NewData)[Index]);
        MoveMemory(NewData^.LibRow^[I], OldData^.LibRow^[I], OldData^.LibLengths^[I]);
      end;
    Inc(Index, NewData^.LibLengths^[I]);
  end;

  if (InternRecordBuffer^.NewData <> InternRecordBuffer^.OldData) then
    FreeMem(InternRecordBuffer^.NewData);
  InternRecordBuffer^.NewData := NewData;
end;

procedure TMySQLDataSet.SetFieldsSortTag();
var
  Field: TField;
  FieldName: string;
  Pos: Integer;
begin
  for Field in Fields do
    Field.Tag := Field.Tag and not ftSortedField;
  Pos := 1;
  repeat
    FieldName := ExtractFieldName(SortDef.Fields, Pos);
    if (FieldName <> '') then
    begin
      Field := FindField(FieldName);
      if (Assigned(Field)) then
        Field.Tag := Field.Tag or ftAscSortedField;
    end;
  until (FieldName = '');
  Pos := 1;
  repeat
    FieldName := ExtractFieldName(SortDef.DescFields, Pos);
    if (FieldName <> '') then
    begin
      Field := FindField(FieldName);
      if (Assigned(Field)) then
        Field.Tag := (Field.Tag and (not ftAscSortedField) or ftDescSortedField);
    end;
  until (FieldName = '');

  DataEvent(deSortChanged, 0);
end;

procedure TMySQLDataSet.SetFiltered(Value: Boolean);
begin
  if (Value <> Filtered) then
  begin
    inherited;

    if (Active) then
      if (Value) then
        ActivateFilter()
      else
        DeactivateFilter();
  end;
end;

procedure TMySQLDataSet.SetFilterText(const Value: string);
begin
  Filtered := Filtered and (Value <> '');

  if (Filtered) then
    DeactivateFilter();

  inherited;

  if (Filtered and (Filter <> '') and IsCursorOpen()) then
    ActivateFilter();
end;

procedure TMySQLDataSet.SetRecNo(Value: Integer);
var
  Bookmark: TBookmark;
  Index: Integer;
  VisibleRecords: Integer;
begin
  VisibleRecords := 0;

  Index := 0;
  while ((VisibleRecords < Value + 1) and (Index < InternRecordBuffers.Count)) do
  begin
    if (not Filtered or InternRecordBuffers[Index]^.VisibleInFilter) then
      Inc(VisibleRecords);
    Inc(Index);
  end;

  if ((VisibleRecords = Value + 1) and (Index < InternRecordBuffers.Count)) then
  begin
    SetLength(Bookmark, BookmarkSize);
    PPointer(@Bookmark[0])^ := InternRecordBuffers[Index - 1];
    GotoBookmark(Bookmark);
    SetLength(Bookmark, 0);
  end;
end;

procedure TMySQLDataSet.Sort(const ASortDef: TIndexDef);
var
  CompareDefs: TRecordCompareDefs;
  SortBuffers: array of PAnsiChar;

  function Compare(const RecA, RecB: Integer; const Def: Integer): Integer;
  var
    BufferA: Pointer;
    BufferB: Pointer;
    NullA: Boolean;
    NullB: Boolean;
  begin
    if (RecA = RecB) then
      Result := 0
    else
    begin
      // Debug 2017-05-31
      Assert((0 <= RecA) and (RecA < InternRecordBuffers.Count)
        and (0 <= RecB) and (RecB < InternRecordBuffers.Count),
        'RecA: ' + IntToStr(RecA) + #13#10
        + 'RecB: ' + IntToStr(RecB) + #13#10
        + 'Count: ' + IntToStr(InternRecordBuffers.Count) + #13#10
        + 'Def: ' + IntToStr(Def) + #13#10
        + 'Defs.Count: ' + IntToStr(Length(CompareDefs)) + #13#10
        + 'DataType: ' + IntToStr(Ord(CompareDefs[Def].Field.DataType)) + #13#10
        + 'Asc: ' + BoolToStr(CompareDefs[Def].Ascending, True));

      NullA := not Assigned(InternRecordBuffers[RecA]^.NewData^.LibRow[CompareDefs[Def].Field.FieldNo - 1]);
      NullB := not Assigned(InternRecordBuffers[RecB]^.NewData^.LibRow[CompareDefs[Def].Field.FieldNo - 1]);
      if (NullA and NullB) then
        Result := 0
      else if (NullA and not NullB) then
        Result := +1
      else if (not NullA and NullB) then
        Result := -1
      else
      begin
        BufferA := @SortBuffers[Def][InternRecordBuffers[RecA].SortIndex * CompareDefs[Def].DataSize];
        BufferB := @SortBuffers[Def][InternRecordBuffers[RecB].SortIndex * CompareDefs[Def].DataSize];
        if (BitField(CompareDefs[Def].Field)) then
          Result := Sign(UInt64(BufferA^) - UInt64(BufferB^))
        else
          case (CompareDefs[Def].Field.DataType) of
            ftString: Result := lstrcmpi(PChar(PString(BufferA)^), PChar(PString(BufferB)^));
            ftShortInt: Result := Sign(ShortInt(BufferA^) - ShortInt(BufferB^));
            ftByte: Result := Sign(Byte(BufferA^) - Byte(BufferB^));
            ftSmallInt: Result := Sign(SmallInt(BufferA^) - SmallInt(BufferB^));
            ftWord: Result := Sign(Integer(Word(BufferA^)) - Integer(Word(BufferB^)));
            ftInteger: Result := Sign(Integer(BufferA^) - Integer(BufferB^));
            ftLongWord: Result := Sign(Int64(LongWord(BufferA^)) - Int64(LongWord(BufferB^)));
            ftLargeInt:
              if (not (CompareDefs[Def].Field is TMySQLLargeWordField)) then
                Result := Sign(LargeInt(BufferA^) - LargeInt(BufferB^))
              else if (UInt64(BufferA^) = UInt64(BufferB^)) then
                Result := 0
              else if (UInt64(BufferA^) > UInt64(BufferB^)) then
                Result := 1
              else
                Result := -1;
            ftSingle: Result := Sign(Single(BufferA^) - Single(BufferB^));
            ftFloat: Result := Sign(Double(BufferA^) - Double(BufferB^));
            ftExtended: Result := Sign(Extended(BufferA^) - Extended(BufferB^));
            ftDate,
            ftDateTime,
            ftTime: Result := Sign(TDateTime(BufferA^) - TDateTime(BufferB^));
            ftTimeStamp: Result := AnsiStrings.StrComp(PAnsiChar(PString(BufferA^)), PAnsiChar(PString(BufferB^)));
            ftWideString,
            ftWideMemo: Result := lstrcmpi(PChar(PString(BufferA)^), PChar(PString(BufferB)^));
            ftBlob:
              if (PAnsiString(BufferA)^ = PAnsiString(BufferB)^) then
                Result := 0
              else if (PAnsiString(BufferA)^ > PAnsiString(BufferB)^) then
                Result := 1
              else
                Result := -1;
            else
              raise EDatabaseError.CreateFMT(SUnknownFieldType + '(%d)', [CompareDefs[Def].Field.Name, Integer(CompareDefs[Def].Field.DataType)]);
          end;
        end;
    end;

    if (Result = 0) then
    begin
      if (Def + 1 < Length(CompareDefs)) then
        Result := Compare(RecA, RecB, Def + 1);
    end
    else if (not CompareDefs[Def].Ascending) then
      Result := -Result;
  end;

  procedure QuickSort(Lo, Hi: Integer);
  var
    L: Integer;
    M: Integer;
    R: Integer;
  begin
    repeat
      L := Lo;
      R := Hi;
      M := (Lo + Hi) shr 1;
      repeat
        while (Compare(L, M, 0)) < 0 do Inc(L);
        while (Compare(R, M, 0)) > 0 do Dec(R);
        if (L <= R) then
        begin
          if (L <> R) then
            InternRecordBuffers.Exchange(L, R);
          Inc(L);
          Dec(R);
        end;
      until (L > R);
      if (Lo < R) then
        QuickSort(Lo, R);
      Lo := L;
    until (L >= Hi);
  end;

var
  Buffer: Pointer;
  Def: Integer;
  FieldName: string;
  I: Integer;
  Len: Integer;
  Mem: Pointer;
  OldBookmark: TBookmark;
  Pos: Integer;
  Rec: Integer;
begin
  Connection.Terminate();

  CheckBrowseMode();
  DoBeforeScroll();

  SortDef.Assign(ASortDef);

  OldBookmark := Bookmark;

  if ((ASortDef.Fields <> '') and (InternRecordBuffers.Count > 1)) then
  begin
    SetLength(CompareDefs, 0);
    Pos := 1;
    repeat
      FieldName := ExtractFieldName(SortDef.Fields, Pos);
      if (FieldName <> '') then
      begin
        SetLength(CompareDefs, Length(CompareDefs) + 1);
        CompareDefs[Length(CompareDefs) - 1].Field := FindField(FieldName);
        // Debug 2017-05-29
        Assert(Assigned(CompareDefs[Length(CompareDefs) - 1].Field),
          'SortDef.Fields: ' + SortDef.Fields + #13#10
          + 'FieldName: ' + FieldName);
        CompareDefs[Length(CompareDefs) - 1].Ascending := True;
      end;
    until (FieldName = '');
    Pos := 1;
    repeat
      FieldName := ExtractFieldName(SortDef.DescFields, Pos);
      if (FieldName <> '') then
        for I := 0 to Length(CompareDefs) - 1 do
          if (CompareDefs[I].Field.FieldName = FieldName) then
            CompareDefs[I].Ascending := False;
    until (FieldName = '');

    SetLength(SortBuffers, Length(CompareDefs));
    for Def := 0 to Length(CompareDefs) - 1 do
    begin
      if (BitField(CompareDefs[Def].Field)) then
        CompareDefs[Def].DataSize := SizeOf(UInt64)
      else
        case (CompareDefs[Def].Field.DataType) of
          ftString: CompareDefs[Def].DataSize := SizeOf(string);
          ftShortInt: CompareDefs[Def].DataSize := SizeOf(ShortInt);
          ftByte: CompareDefs[Def].DataSize := SizeOf(Byte);
          ftSmallInt: CompareDefs[Def].DataSize := SizeOf(SmallInt);
          ftWord: CompareDefs[Def].DataSize := SizeOf(Word);
          ftInteger: CompareDefs[Def].DataSize := SizeOf(Integer);
          ftLongWord: CompareDefs[Def].DataSize := SizeOf(LongWord);
          ftLargeInt:
            if (not (CompareDefs[Def].Field is TMySQLLargeWordField)) then
              CompareDefs[Def].DataSize := SizeOf(LargeInt)
            else
              CompareDefs[Def].DataSize := SizeOf(UInt64);
          ftSingle: CompareDefs[Def].DataSize := SizeOf(Single);
          ftFloat: CompareDefs[Def].DataSize := SizeOf(Double);
          ftExtended: CompareDefs[Def].DataSize := SizeOf(Extended);
          ftDate,
          ftDateTime,
          ftTime: CompareDefs[Def].DataSize := SizeOf(TDateTime);
          ftTimeStamp: CompareDefs[Def].DataSize := SizeOf(AnsiString);
          ftWideString,
          ftWideMemo: CompareDefs[Def].DataSize := SizeOf(string);
          ftBlob: CompareDefs[Def].DataSize := SizeOf(AnsiString);
          else
            raise EDatabaseError.CreateFMT(SUnknownFieldType + '(%d)', [CompareDefs[Def].Field.Name, Integer(CompareDefs[Def].Field.DataType)]);
        end;
      GetMem(Mem, InternRecordBuffers.Count * CompareDefs[Def].DataSize);
      SortBuffers[Def] := Mem;
      case (CompareDefs[Def].Field.DataType) of
        ftString,
        ftTimeStamp,
        ftWideString,
        ftWideMemo,
        ftBlob:
          ZeroMemory(SortBuffers[Def], InternRecordBuffers.Count * CompareDefs[Def].DataSize);
      end;
    end;

    for Rec := 0 to InternRecordBuffers.Count - 1 do
    begin
      InternRecordBuffers[Rec].SortIndex := Rec;

      // Debug 2017-06-01
      Assert(Assigned(InternRecordBuffers[Rec].NewData));
      Assert(Assigned(InternRecordBuffers[Rec].NewData^.LibRow));

      for Def := 0 to Length(CompareDefs) - 1 do
        if (Assigned(InternRecordBuffers[Rec].NewData^.LibRow[CompareDefs[Def].Field.FieldNo - 1])) then
        begin
          Buffer := @SortBuffers[Def][Rec * CompareDefs[Def].DataSize];
          case (CompareDefs[Def].Field.DataType) of
            ftString:
              begin
                Len := AnsiCharToWideChar(FieldCodePage(CompareDefs[Def].Field),
                  InternRecordBuffers[Rec].NewData^.LibRow[CompareDefs[Def].Field.FieldNo - 1], InternRecordBuffers[Rec].NewData^.LibLengths[CompareDefs[Def].Field.FieldNo - 1], nil, 0);
                SetLength(PString(Buffer)^, Len);
                AnsiCharToWideChar(FieldCodePage(CompareDefs[Def].Field),
                  InternRecordBuffers[Rec].NewData^.LibRow[CompareDefs[Def].Field.FieldNo - 1], InternRecordBuffers[Rec].NewData^.LibLengths[CompareDefs[Def].Field.FieldNo - 1],
                  PChar(PString(Buffer)^), Len);
              end;
            ftShortInt,
            ftByte,
            ftSmallInt,
            ftWord,
            ftInteger,
            ftLongWord,
            ftLargeInt,
            ftSingle,
            ftFloat,
            ftExtended,
            ftDate,
            ftDateTime,
            ftTime: GetFieldData(CompareDefs[Def].Field, Buffer, InternRecordBuffers[Rec].NewData);
            ftTimeStamp: SetString(PAnsiString(Buffer)^, InternRecordBuffers[Rec].NewData^.LibRow[CompareDefs[Def].Field.FieldNo - 1], InternRecordBuffers[Rec].NewData^.LibLengths[CompareDefs[Def].Field.FieldNo - 1]);
            ftWideString,
            ftWideMemo:
              begin
                Len := AnsiCharToWideChar(FieldCodePage(CompareDefs[Def].Field),
                  InternRecordBuffers[Rec].NewData^.LibRow[CompareDefs[Def].Field.FieldNo - 1], InternRecordBuffers[Rec].NewData^.LibLengths[CompareDefs[Def].Field.FieldNo - 1], nil, 0);
                SetLength(PString(Buffer)^, Len);
                AnsiCharToWideChar(FieldCodePage(CompareDefs[Def].Field),
                  InternRecordBuffers[Rec].NewData^.LibRow[CompareDefs[Def].Field.FieldNo - 1], InternRecordBuffers[Rec].NewData^.LibLengths[CompareDefs[Def].Field.FieldNo - 1],
                  PChar(PString(Buffer)^), Len);
              end;
            ftBlob: SetString(PAnsiString(Buffer)^, InternRecordBuffers[Rec].NewData^.LibRow[CompareDefs[Def].Field.FieldNo - 1], InternRecordBuffers[Rec].NewData^.LibLengths[CompareDefs[Def].Field.FieldNo - 1]);
            else
              raise EDatabaseError.CreateFMT(SUnknownFieldType + '(%d)', [CompareDefs[Def].Field.Name, Ord(CompareDefs[Def].Field.DataType)]);
          end;
        end;
    end;

    QuickSort(0, InternRecordBuffers.Count - 1);

    for Def := 0 to Length(CompareDefs) - 1 do
      case (CompareDefs[Def].Field.DataType) of
        ftString:
          for Rec := 0 to InternRecordBuffers.Count - 1 do
          begin
            Buffer := @SortBuffers[Def][Rec * CompareDefs[Def].DataSize];
            PString(Buffer)^ := '';
          end;
        ftTimeStamp:
          for Rec := 0 to InternRecordBuffers.Count - 1 do
          begin
            Buffer := @SortBuffers[Def][Rec * CompareDefs[Def].DataSize];
            PAnsiString(Buffer)^ := '';
          end;
        ftWideString,
        ftWideMemo:
          for Rec := 0 to InternRecordBuffers.Count - 1 do
          begin
            Buffer := @SortBuffers[Def][Rec * CompareDefs[Def].DataSize];
            PString(Buffer)^ := '';
          end;
        ftBlob:
          for Rec := 0 to InternRecordBuffers.Count - 1 do
          begin
            Buffer := @SortBuffers[Def][Rec * CompareDefs[Def].DataSize];
            PAnsiString(Buffer)^ := '';
          end;
      end;

    for Def := 0 to Length(CompareDefs) - 1 do
      FreeMem(SortBuffers[Def]);
  end;

  SetFieldsSortTag();

  Bookmark := OldBookmark;

  DoAfterScroll();
end;

function TMySQLDataSet.SQLDelete(): string;
var
  I: Integer;
  InternRecordBuffer: PInternRecordBuffer;
  J: Integer;
  NullValue: Boolean;
  SQL: string;
  ValueHandled: Boolean;
  Values: string;
  WhereClause: string;
  WhereField: TField;
  WhereFieldCount: Integer;
begin
  if (DeleteByWhereClause) then
  begin
    if (not (Self is TMySQLTable)) then
      SQL := CommandText
    else
      SQL := TMySQLTable(Self).SQLSelect();
    if (not Connection.SQLParser.ParseSQL(SQL)
      or not GetWhereClauseFromSelectStmt(Connection.SQLParser.FirstStmt, WhereClause)) then
      Result := ''
    else if (WhereClause = '') then
      Result := 'DELETE FROM ' + SQLTableClause()
    else
      Result := 'DELETE FROM ' + SQLTableClause() + ' WHERE ' + WhereClause;
    Connection.SQLParser.Clear();
  end
  else if (not Assigned(DeleteBookmarks)) then
    Result := 'DELETE FROM ' + SQLTableClause() + ' WHERE ' + SQLWhereClause()
  else
  begin
    Result := 'DELETE FROM ' + SQLTableClause() + ' WHERE ';

    WhereFieldCount := 0; WhereField := nil;
    for I := 0 to FieldCount - 1 do
      if (pfInWhere in Fields[I].ProviderFlags) then
      begin
        WhereField := Fields[I];
        Inc(WhereFieldCount);
      end;

    if (WhereFieldCount = 1) then
    begin
      Values := ''; NullValue := False;
      for I := 0 to Length(DeleteBookmarks^) - 1 do
      begin
        InternRecordBuffer := InternRecordBuffers[InternRecordBuffers.IndexOf(DeleteBookmarks^[I])];
        if (not Assigned(InternRecordBuffer^.OldData^.LibRow^[WhereField.FieldNo - 1])) then
          NullValue := True
        else
        begin
          if (Values <> '') then Values := Values + ',';
          Values := Values + SQLFieldValue(WhereField, InternRecordBuffer^.OldData);
        end;
      end;

      if (Values <> '') then
        Result := Result + Connection.EscapeIdentifier(WhereField.FieldName) + ' IN (' + Values + ')';
      if (NullValue) then
      begin
        if (Values <> '') then
          Result := Result + ' OR ';
        Result := Result + Connection.EscapeIdentifier(WhereField.FieldName) + ' IS NULL';
      end;
    end
    else
    begin
      for I := 0 to Length(DeleteBookmarks^) - 1 do
      begin
        if (I > 0) then Result := Result + ' OR ';
        Result := Result + '(';
        ValueHandled := False;
        for J := 0 to FieldCount - 1 do
          if (pfInWhere in Fields[J].ProviderFlags) then
          begin
            // Debug 2017-05-04
            Assert(Assigned(DeleteBookmarks));

            InternRecordBuffer := InternRecordBuffers[InternRecordBuffers.IndexOf(DeleteBookmarks^[I])];
            if (ValueHandled) then Result := Result + ' AND ';
            if (not Assigned(InternRecordBuffer^.OldData^.LibRow^[Fields[J].FieldNo - 1])) then
              Result := Result + Connection.EscapeIdentifier(Fields[J].FieldName) + ' IS NULL'
            else
              Result := Result + '(' + Connection.EscapeIdentifier(Fields[J].FieldName) + '=' + SQLFieldValue(Fields[J], InternRecordBuffer^.OldData) + ')';
            ValueHandled := True;
          end;
        Result := Result + ')';
      end;
    end;
  end;

  Result := Result + ';' + #13#10;
end;

function TMySQLDataSet.SQLFieldValue(const Field: TField; Buffer: TRecordBuffer = nil): string;
begin
  if (not Assigned(Buffer)) then
    Buffer := Pointer(ActiveBuffer());

  Result := SQLFieldValue(Field, PExternRecordBuffer(Buffer)^.InternRecordBuffer^.NewData);
end;

function TMySQLDataSet.SQLInsert(): string;
var
  EmptyData: TMySQLQuery.TRecordBufferData;
  Data: TMySQLQuery.PRecordBufferData;
  I: Integer;
  J: Integer;
  SQL: string;
  ValueHandled: Boolean;
begin
  Result := '';

  if (CachedUpdates) then
  begin
    EmptyData.LibLengths := nil;
    EmptyData.LibRow := nil;

    for J := 0 to PendingBuffers.Count - 1 do
    begin
      SQL := '';

      ValueHandled := False;
      for I := 0 to FieldCount - 1 do
        if ((pfInUpdate in Fields[I].ProviderFlags)
          and (not Assigned(PendingBuffers[J]^.NewData)
            or Assigned(PendingBuffers[J]^.NewData^.LibRow^[Fields[I].FieldNo - 1]))) then
        begin
          if (ValueHandled) then SQL := SQL + ',';
          if (not Assigned(PendingBuffers[J]^.NewData)) then
            SQL := SQL + Connection.EscapeIdentifier(Fields[I].FieldName) + '=' + SQLFieldValue(Fields[I], TMySQLQuery.PRecordBufferData(@EmptyData))
          else
            SQL := SQL + Connection.EscapeIdentifier(Fields[I].FieldName) + '=' + SQLFieldValue(Fields[I], PendingBuffers[J]^.NewData);
          ValueHandled := True;
        end;

      if (SQL <> '') then
        Result := Result + 'INSERT INTO ' + SQLTableClause() + ' SET ' + SQL + ';' + #13#10;
    end;
  end
  else
  begin
    // Debug 2017-04-24
    Assert(Assigned(PExternRecordBuffer(ActiveBuffer())));
    Assert(Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer));

    Data := PExternRecordBuffer(ActiveBuffer()).InternRecordBuffer^.NewData;

    if (Assigned(Data)) then
    begin
      ValueHandled := False;
      for I := 0 to FieldCount - 1 do
        if ((pfInUpdate in Fields[I].ProviderFlags)
          and (not Assigned(Data^.LibRow)
            or Assigned(LibRow^[Fields[I].FieldNo - 1]))) then
        begin
          if (ValueHandled) then Result := Result + ',';
          Result := Result + Connection.EscapeIdentifier(Fields[I].FieldName) + '=' + SQLFieldValue(Fields[I], Data);
          ValueHandled := True;
        end;

      if (Result <> '') then
        Result := 'INSERT INTO ' + SQLTableClause() + ' SET ' + Result + ';' + #13#10;
    end;
  end;
end;

function TMySQLDataSet.SQLTableClause(): string;
begin
  if (DatabaseName = '') then
    Result := ''
  else
    Result := Connection.EscapeIdentifier(DatabaseName) + '.';
  Result := Result + Connection.EscapeIdentifier(TableName);
end;

function TMySQLDataSet.SQLUpdate(): string;
var
  I: Integer;
  ValueHandled: Boolean;
  J: Integer;
begin
  if (CachedUpdates) then
  begin
    Result := '';
    for J := 0 to PendingBuffers.Count - 1 do
      if (Assigned(PendingBuffers[J]^.OldData)) then
      begin
        ValueHandled := False;
        for I := 0 to FieldCount - 1 do
          if ((pfInUpdate in Fields[I].ProviderFlags)
            and ((PendingBuffers[J]^.NewData^.LibLengths^[Fields[I].FieldNo - 1] <> PendingBuffers[J]^.OldData^.LibLengths^[Fields[I].FieldNo - 1])
              or (Assigned(PendingBuffers[J]^.NewData^.LibRow^[Fields[I].FieldNo - 1]) xor Assigned(PendingBuffers[J]^.OldData^.LibRow^[Fields[I].FieldNo - 1]))
              or (not CompareMem(PendingBuffers[J]^.NewData^.LibRow^[Fields[I].FieldNo - 1], PendingBuffers[J]^.OldData^.LibRow^[Fields[I].FieldNo - 1], PendingBuffers[J]^.OldData^.LibLengths^[Fields[I].FieldNo - 1])))) then
          begin
            if (ValueHandled) then Result := Result + ',';
            Result := Result + Connection.EscapeIdentifier(Fields[I].FieldName) + '=' + SQLFieldValue(Fields[I], PendingBuffers[J]^.OldData);
            ValueHandled := True;
          end;
        if (Result <> '') then
          Result := 'UPDATE ' + SQLTableClause() + ' SET ' + Result + ' WHERE ' + SQLWhereClause() + ';' + #13#10;
      end;
  end
  else if (PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData = PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData) then
    Result := ''
  else
  begin
    Result := '';
    ValueHandled := False;
    for I := 0 to FieldCount - 1 do
    begin
      // Debug 2017-05-29

      Assert(Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData));
      Assert(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.Identifier963 = 963);
      Assert(Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.LibLengths));
      Assert(Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.LibRow));

      if (pfInUpdate in Fields[I].ProviderFlags) then
        if (not (PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.LibLengths^[Fields[I].FieldNo - 1] <> PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData^.LibLengths^[Fields[I].FieldNo - 1])) then
        if (not (Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.LibRow^[Fields[I].FieldNo - 1]) xor Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData^.LibRow^[Fields[I].FieldNo - 1]))) then
        if (not (not CompareMem(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.LibRow^[Fields[I].FieldNo - 1], PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData^.LibRow^[Fields[I].FieldNo - 1], PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData^.LibLengths^[Fields[I].FieldNo - 1]))) then
        Write;

      if ((pfInUpdate in Fields[I].ProviderFlags)
        and ((PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.LibLengths^[Fields[I].FieldNo - 1] <> PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData^.LibLengths^[Fields[I].FieldNo - 1])
          or (Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.LibRow^[Fields[I].FieldNo - 1]) xor Assigned(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData^.LibRow^[Fields[I].FieldNo - 1]))
          or (not CompareMem(PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData^.LibRow^[Fields[I].FieldNo - 1], PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData^.LibRow^[Fields[I].FieldNo - 1], PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData^.LibLengths^[Fields[I].FieldNo - 1])))) then
      begin
        if (ValueHandled) then Result := Result + ',';
        Result := Result + Connection.EscapeIdentifier(Fields[I].FieldName) + '=' + SQLFieldValue(Fields[I], Pointer(ActiveBuffer()));
        ValueHandled := True;
      end;
    end;
    if (Result <> '') then
      Result := 'UPDATE ' + SQLTableClause() + ' SET ' + Result + ' WHERE ' + SQLWhereClause() + ';' + #13#10;
  end;
end;

function TMySQLDataSet.SQLWhereClause(const NewData: Boolean = False): string;
var
  Data: TMySQLQuery.PRecordBufferData;
  I: Integer;
  ValueHandled: Boolean;
begin
  Result := '';

  if (not NewData) then
    Data := PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.OldData
  else
    Data := PExternRecordBuffer(ActiveBuffer())^.InternRecordBuffer^.NewData;
  ValueHandled := False;
  for I := 0 to Fields.Count - 1 do
    if (pfInWhere in Fields[I].ProviderFlags) then
    begin
      if (ValueHandled) then Result := Result + ' AND ';
      if (not Assigned(Data) or not Assigned(Data^.LibRow^[Fields[I].FieldNo - 1])) then
        Result := Result + Connection.EscapeIdentifier(Fields[I].FieldName) + ' IS NULL'
      else
        Result := Result + Connection.EscapeIdentifier(Fields[I].FieldName) + '=' + SQLFieldValue(Fields[I], Data);
      ValueHandled := True;
    end;

  Assert(Result <> '', CommandText);
end;

procedure TMySQLDataSet.UpdateIndexDefs();
var
  DName: string;
  FieldName: string;
  Found: Boolean;
  I: Integer;
  Index: TIndexDef;
  Parse: TSQLParse;
  Pos: Integer;
  TName: string;
begin
  if (not Assigned(Handle)) then
  begin
    inherited;

    if (not (Self is TMySQLTable)) then
    begin
      Index := nil;
      for I := 0 to IndexDefs.Count - 1 do
        if (not Assigned(Index) and (ixUnique in IndexDefs[I].Options)) then
          Index := IndexDefs[I];
      FCanModify := Assigned(Index);

      if (not FCanModify and SQLCreateParse(Parse, PChar(CommandText), Length(CommandText), Connection.MySQLVersion) and SQLParseKeyword(Parse, 'SELECT') and SQLParseChar(Parse, '*') and SQLParseKeyword(Parse, 'FROM')) then
      begin
        TName := SQLParseValue(Parse);
        if (not SQLParseChar(Parse, '.')) then
          DName := DatabaseName
        else
        begin
          DName := TName;
          TName := SQLParseValue(Parse);
        end;
        if (((TName = TableName) or SQLParseKeyword(Parse, 'AS') and (SQLParseValue(Parse) = TableName))
          and ((SQLParseKeyword(Parse, 'FROM') or SQLParseKeyword(Parse, 'WHERE') or SQLParseKeyword(Parse, 'GROUP BY') or SQLParseKeyword(Parse, 'HAVING') or SQLParseKeyword(Parse, 'ORDER BY') or SQLParseKeyword(Parse, 'LIMIT') or SQLParseEnd(Parse)))) then
        begin
          FDatabaseName := DName;
          FTableName := TName;
          FCanModify := True;

          Found := False;
          for I := 0 to FieldCount - 1 do
            Found := Found or (pfInKey in Fields[I].ProviderFlags);

          if (Found) then
          begin
            Index := IndexDefs.AddIndexDef();
            Index.Name := '';
            Index.Options := [ixPrimary, ixUnique, ixCaseInsensitive];
            for I := 0 to FieldCount - 1 do
              if (pfInKey in Fields[I].ProviderFlags) then
              begin
                if (Index.Fields <> '') then Index.Fields := Index.Fields + ';';
                Index.Fields := Index.Fields + Fields[I].FieldName;
              end;
          end;
        end;
      end;
    end;

    Index := nil;
    for I := 0 to IndexDefs.Count - 1 do
      if (not Assigned(Index) and (ixUnique in IndexDefs[I].Options)) then
        Index := IndexDefs[I];

    if (not Assigned(Index)) then
    begin
      for I := 0 to FieldCount - 1 do
        Fields[I].ProviderFlags := Fields[I].ProviderFlags + [pfInWhere];
    end
    else
    begin
      FCanModify := True;

      for I := 0 to FieldCount - 1 do
        Fields[I].ProviderFlags := Fields[I].ProviderFlags - [pfInWhere];
      Pos := 1;
      repeat
        FieldName := ExtractFieldName(Index.Fields, Pos);
        for I := 0 to FieldCount - 1 do
          if (Fields[I].FieldName = FieldName) then
            Fields[I].ProviderFlags := Fields[I].ProviderFlags + [pfInWhere];
      until (FieldName = '');
    end;
  end;
end;

function TMySQLDataSet.VisibleInFilter(const InternRecordBuffer: PInternRecordBuffer): Boolean;

  type
    PCANExpr = ^TCANExpr;
    TCANExpr = packed record
      iVer: Word;
      iTotalSize: Word;
      iNodes: Word;
      iNodeStart: Word;
      iLiteralStart: Word;
    end;

    PCANHdr = ^TCANHdr;
    TCANHdr = packed record
      nodeClass: DBCommon.NODEClass;
      Reserved1: Byte;
      Reserved2: Word;
      coOp: DBCommon.TCANOperator;
      Reserved3: Byte;
      Reserved4: Word;
      case DBCommon.NODEClass of
        nodeUNARY: ( Unary: record
          NodeOfs: Word;
        end; );
        nodeBINARY: ( Binary: record
          LeftPosOfs: Word;
          RightPosOfs: Word;
        end; );
        nodeCOMPARE: ( Compare: record
          CaseInsensitive: WordBool;
          PartLength: Word;
          NodeOfs: Word;
          DataOfs: Word;
        end; );
        nodeFIELD: ( Field2: record
          FieldNo: Word;
          FieldNameOfs: Word;
        end; );
        nodeCONST: ( Const2: record
          FieldType: Word;
          Size: Word;
          DataOfs: Word;
        end; );
        nodeLIST: ( List: record
        end; );
        nodeFUNC: ( Func: record
          FunctionNameOfs: Word;
          ArgOfs: Word;
        end; );
        nodeLISTELEM: ( ListItem: record
        end; );
    end;

  var
    Expr: PCANExpr;

  function VIsNull(AVariant: Variant): Boolean;
  begin
    Result:= VarIsNull(AVariant) or VarIsEmpty(AVariant);
  end;

  function ParseNode(const Node: PCANHdr): Variant;
  type
    PLargeint = ^Largeint;
  var
    I, Z: Integer;
    Year, Month, Day, Hour, Min, Sec, MSec:word;
    P: Pointer;
    Arg1, Arg2: Variant;
    S: string;
    TS: TTimeStamp;
    TempNode: PCANHdr;
  begin
    case (Node^.nodeClass) of
      nodeFIELD:
        case (Node^.coOp) of
          coFIELD2:
            if (not Assigned(InternRecordBuffer^.NewData^.LibRow^[Node^.Field2.FieldNo - 1])) then
              Result := Null
            else if (BitField(Fields[Node^.Field2.FieldNo - 1])) then
              Result := Fields[Node^.Field2.FieldNo - 1].AsLargeInt
            else if (Fields[Node^.Field2.FieldNo - 1].DataType in [ftWideString, ftWideMemo]) then
              Result := LibDecode(FieldCodePage(Fields[Node^.Field2.FieldNo - 1]), InternRecordBuffer^.NewData^.LibRow^[Node^.Field2.FieldNo - 1], InternRecordBuffer^.NewData^.LibLengths^[Node^.Field2.FieldNo - 1])
            else
              Result := LibUnpack(InternRecordBuffer^.NewData^.LibRow^[Node^.Field2.FieldNo - 1], InternRecordBuffer^.NewData^.LibLengths^[Node^.Field2.FieldNo - 1]);
          else raise EDatabaseError.CreateFmt('coOp not supported (%d)', [Ord(Node^.coOp)]);
        end;

      nodeCONST:
        case (Node^.coOp) of
          coCONST2:
            begin
              P := @FilterParser.FilterData[Expr^.iLiteralStart + Node^.Const2.DataOfs];

              if (Node^.Const2.FieldType = $1007) then
              begin
                SetString(S, PChar(@PAnsiChar(P)[2]), PWord(@PAnsiChar(P)[0])^ div SizeOf(Char));
                Result := S;
              end
              else
                case (TFieldType(Node^.Const2.FieldType)) of
                  ftShortInt: Result := PShortInt(P)^;
                  ftByte: Result := PByte(P)^;
                  ftSmallInt: Result := PSmallInt(P)^;
                  ftWord: Result := PWord(P)^;
                  ftInteger: Result := PInteger(P)^;
                  ftLongword: Result := PLongword(P)^;
                  ftLargeint: Result := PLargeint(P)^;
                  ftSingle: Result := PSingle(P)^;
                  ftFloat: Result := PDouble(P)^;
                  ftExtended: Result := PExtended(P)^;
                  ftWideString: Result := PString(P)^;
                  ftDate: begin TS.Date := PInteger(P)^; TS.Time := 0; Result := TimeStampToDateTime(TS); end;
                  ftDateTime: Result := TimeStampToDateTime(MSecsToTimeStamp(PDouble(P)^));
                  ftTime: begin TS.Date := 0; TS.Time := PInteger(P)^; Result := TimeStampToDateTime(TS); end;
                  ftTimeStamp: Result := VarSQLTimeStampCreate(PSQLTimeStamp(P)^);
                  ftString,
                  ftFixedChar: Result := string(PChar(P));
                  ftBoolean: Result := PWordBool(P)^;
                  else raise EDatabaseError.CreateFmt('FieldType not supported (%d)', [Ord(Node^.Const2.FieldType)]);
                end;
            end;
          else raise EDatabaseError.CreateFmt('coOp not supported (%d)', [Ord(Node^.coOp)]);
        end;

      nodeUNARY:
        begin
          Arg1 := ParseNode(@FilterParser.FilterData[CANEXPRSIZE + Node^.Unary.NodeOfs]);

          case (Node^.coOp) of
            coISBLANK:
              Result := VIsNull(Arg1);
            coNOTBLANK:
              Result := not VIsNull(Arg1);
            coNOT:
              if (VIsNull(Arg1)) then Result := Null else Result := not Arg1;
            coMINUS:
              if (VIsNull(Arg1)) then Result := Null else Result := -Arg1;
            coUPPER:
              if (VIsNull(Arg1)) then Result := Null else Result := UpperCase(Arg1);
            coLOWER:
              if (VIsNull(Arg1)) then Result := Null else Result := LowerCase(Arg1);
            else raise EDatabaseError.CreateFmt('coOp not supported (%d)', [Ord(Node^.coOp)]);
          end;
        end;

      nodeBINARY:
        begin
          Arg1 := ParseNode(@FilterParser.FilterData[CANEXPRSIZE + Node^.Binary.LeftPosOfs]);
          Arg2 := ParseNode(@FilterParser.FilterData[CANEXPRSIZE + Node^.Binary.RightPosOfs]);

          case (Node^.coOp) of
            coEQ:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := False else Result := (Arg1 = Arg2);
            coNE:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := False else Result := (Arg1 <> Arg2);
            coGT:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := False else Result := (Arg1 > Arg2);
            coGE:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := False else Result := (Arg1 >= Arg2);
            coLT:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := False else Result := (Arg1 < Arg2);
            coLE:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := False else Result := (Arg1 <= Arg2);
            coOR:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := False else Result := (Arg1 or Arg2);
            coAND:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := False else Result := (Arg1 and Arg2);
            coADD:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := Null else Result := (Arg1 + Arg2);
            coSUB:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := Null else Result := (Arg1 - Arg2);
            coMUL:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := Null else Result := (Arg1 * Arg2);
            coDIV:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := Null else Result := (Arg1 / Arg2);
            coMOD,
            coREM:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then Result := Null else Result := (Arg1 mod Arg2);
            coIN:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then
                Result := False
              else if (VarIsArray(Arg2)) then
              begin
                Result := False;
                for i := 0 to VarArrayHighBound(Arg2, 1) do
                begin
                  if (VarIsEmpty(Arg2[i])) then break;
                  Result := (Arg1 = Arg2[i]);
                  if (Result) then break;
                end;
              end
              else
                Result := (Arg1 = Arg2);
            coLike:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then
                Result := False
              else if (Arg2 = '%') then
                Result := Arg1 <> ''
              else if ((LeftStr(Arg2, 1) = '%') and (RightStr(Arg2, 1) = '%')) then
                Result := ContainsText(Arg1, Copy(Arg2, 2, Length(Arg2) - 2))
              else if (LeftStr(Arg2, 1) = '%') then
                Result := EndsText(Copy(Arg2, 2, Length(Arg2) - 1), Arg1)
              else if (RightStr(Arg2, 1) = '%') then
                Result := StartsText(Copy(Arg2, 1, Length(Arg2) - 1), Arg1)
              else
                Result := UpperCase(Arg1) = UpperCase(Arg2);
            else raise EDatabaseError.CreateFmt('coOp not supported (%d)', [Ord(Node^.coOp)]);
          end;
        end;

      nodeCOMPARE:
        begin
          Arg1 := ParseNode(@FilterParser.FilterData[CANEXPRSIZE + Node^.Compare.NodeOfs]);
          Arg2 := ParseNode(@FilterParser.FilterData[CANEXPRSIZE + Node^.Compare.DataOfs]);

          case (Node^.coOp) of
            coEQ,
            coNE:
              begin
                if (VIsNull(Arg1) or VIsNull(Arg2)) then
                  Result := False
                else if (Node^.Compare.PartLength = 0) then
                  if (Node^.Compare.CaseInsensitive) then
                    Result := lstrcmpi(PChar(VarToStr(Arg1)), PChar(VarToStr(Arg2))) = 0
                  else
                    Result := lstrcmp(PChar(VarToStr(Arg1)), PChar(VarToStr(Arg2))) = 0
                else
                  if (Node^.Compare.CaseInsensitive) then
                    Result := lstrcmpi(PChar(LeftStr(Arg1, Node^.Compare.PartLength)), PChar(LeftStr(Arg2, Node^.Compare.PartLength))) = 0
                  else
                    Result := lstrcmp(PChar(LeftStr(Arg1, Node^.Compare.PartLength)), PChar(LeftStr(Arg2, Node^.Compare.PartLength))) = 0;
                if (Node^.coOp = coNE) then
                  Result := not Result;
              end;
            coLIKE:
              if (VIsNull(Arg1) or VIsNull(Arg2)) then
                Result := False
              else if (Arg2 = '%') then
                Result := Arg1 <> ''
              else if ((LeftStr(Arg2, 1) = '%') and (RightStr(Arg2, 1) = '%')) then
                Result := ContainsText(Arg1, Copy(Arg2, 2, Length(Arg2) - 2))
              else if (LeftStr(Arg2, 1) = '%') then
                Result := EndsText(Copy(Arg2, 2, Length(Arg2) - 1), Arg1)
              else if (RightStr(Arg2, 1) = '%') then
                Result := StartsText(Copy(Arg2, 1, Length(Arg2) - 1), Arg1)
              else
                Result := UpperCase(Arg1) = UpperCase(Arg2);
            else raise EDatabaseError.CreateFmt('coOp not supported (%d)', [Ord(Node^.coOp)]);
          end;
        end;

      nodeFUNC:
        case (Node^.coOp) of
          coFUNC2:
            begin
              P := PAnsiChar(@FilterParser.FilterData[Expr^.iLiteralStart + Node^.Func.FunctionNameOfs]);
              Arg1 := ParseNode(@FilterParser.FilterData[CANEXPRSIZE + Node^.Func.ArgOfs]);

              if (AnsiStrings.StrIComp(P, 'UPPER') = 0) then
                if (VIsNull(Arg1)) then Result := Null else Result := UpperCase(VarToStr(Arg1))

              else if (AnsiStrings.StrIComp(P, 'LOWER') = 0) then
                if (VIsNull(Arg1)) then Result := Null else Result := LowerCase(VarToStr(Arg1))

              else if (AnsiStrings.StrIComp(P, 'SUBSTRING') = 0) then
                if (VIsNull(Arg1)) then
                  Result := Null
                else
                begin
                  Result := Arg1;
                  try
                    Arg1 := VarToStr(Result[0]);
                  except
                    on EVariantError do // no Params for "SubString"
                      raise EDatabaseError.CreateFmt('InvMissParam',[Arg1]);
                  end;

                  if (Result[2] <> 0) then
                    Result := Copy(Arg1, Integer(Result[1]), Integer(Result[2]))
                  else if (Pos(',', Result[1]) > 0) then  // "From" and "To" entered without space!
                    Result := Copy(Arg1, Integer(Result[1]), StrToInt(Copy(Result[1], Pos(',', Result[1]) + 1, Length(Result[1]))))
                  else // No "To" entered so use all
                    Result := VarToStr(Arg1);
                end

              else if (AnsiStrings.StrIComp(P, 'TRIM') = 0) then
                if (VIsNull(Arg1)) then Result := Null else Result := Trim(VarToStr(Arg1))

              else if (AnsiStrings.StrIComp(P, 'TRIMLEFT') = 0) then
                if (VIsNull(Arg1)) then Result := Null else Result := TrimLeft(VarToStr(Arg1))

              else if (AnsiStrings.StrIComp(P, 'TRIMRIGHT') = 0) then
                if (VIsNull(Arg1)) then Result := Null else Result := TrimRight(VarToStr(Arg1))

              else if (AnsiStrings.StrIComp(P, 'GETDATE') = 0) then
                Result := Now()

              else if (AnsiStrings.StrIComp(P, 'YEAR') = 0) then
                if (VIsNull(Arg1)) then Result := Null else begin DecodeDate(VarToDateTime(Arg1), Year, Month, Day); Result := Year; end

              else if (AnsiStrings.StrIComp(P, 'MONTH') = 0) then
                if (VIsNull(Arg1)) then Result := Null else begin DecodeDate(VarToDateTime(Arg1), Year, Month, Day); Result := Month; end

              else if (AnsiStrings.StrIComp(P, 'DAY') = 0) then
                if (VIsNull(Arg1)) then Result := Null else begin DecodeDate(VarToDateTime(Arg1), Year, Month, Day); Result := Day; end

              else if (AnsiStrings.StrIComp(P, 'HOUR') = 0) then
                if (VIsNull(Arg1)) then Result := Null else begin DecodeTime(VarToDateTime(Arg1), Hour, Min, Sec, MSec); Result := Hour; end

              else if (AnsiStrings.StrIComp(P, 'MINUTE') = 0) then
                if (VIsNull(Arg1)) then Result := Null else begin DecodeTime(VarToDateTime(Arg1), Hour, Min, Sec, MSec); Result := Min; end

              else if (AnsiStrings.StrIComp(P, 'SECOND') = 0) then
                if (VIsNull(Arg1)) then Result := Null else begin DecodeTime(VarToDateTime(Arg1), Hour, Min, Sec, MSec); Result := Sec; end

              else if (AnsiStrings.StrIComp(P, 'DATE') = 0) then  // Format: DATE('datestring','formatstring')
              begin                                    //   or    DATE(datevalue)
                Result := Arg1;
                if VarIsArray(Result) then
                begin
                  try
                    Arg1 := VarToStr(Result[0]);
                    Arg1 := VarToStr(Result[1]);
                  except
                    on EVariantError do // no Params for DATE
                      raise EDatabaseError.CreateFmt('Missing parameter', [Arg1]);
                  end;

                  S := FormatSettings.ShortDateFormat;
                  try
                    FormatSettings.ShortDateFormat := Arg1;
                    Result := StrToDate(Arg1);
                  finally
                    FormatSettings.ShortDateFormat := S;
                  end;
                end
                else
                  Result := Longint(Trunc(VarToDateTime(Result)));
              end

              else if (AnsiStrings.StrIComp(P, 'TIME') = 0) then  // Format TIME('timestring','formatstring')
              begin                                               // or     TIME(datetimevalue)
                Result := Arg1;
                if (VarIsArray(Result)) then
                begin
                  try
                    Arg1 := VarToStr(Result[0]);
                    Arg1 := VarToStr(Result[1]);
                  except
                    on EVariantError do // no Params for TIME
                      raise EDatabaseError.CreateFmt('Missing parameter', [Arg1]);
                  end;

                  S := FormatSettings.ShortTimeFormat;
                  try
                    FormatSettings.ShortTimeFormat := Arg1;
                    Result := StrToTime(Arg1);
                  finally
                    FormatSettings.ShortTimeFormat := S;
                  end;
               end
               else
                 Result := Frac(VarToDateTime(Result));
              end

              else raise EDatabaseError.CreateFmt('Function not supported (%s)', [P]);
            end;

          else raise EDatabaseError.CreateFmt('coOp not supported', [Ord(Node^.coOp)]);
        end;

      nodeLISTELEM:
        case (Node^.coOp) of
          coLISTELEM2:
            begin
              Result := VarArrayCreate([0, 50], VarVariant); // Create VarArray for ListElements Values

              I := 0;
              TempNode := PCANHdr(@FilterParser.FilterData[CANEXPRSIZE + PWord(@PChar(Node)[CANHDRSIZE + I * 2])^]);
              while (TempNode^.nodeClass = nodeLISTELEM) do
              begin
                Arg1 := ParseNode(TempNode);
                if (not VarIsArray(Arg1)) then
                  Result[I] := Arg1
                else
                begin
                  Z := 0;
                  while (not VarIsEmpty(Arg1[Z])) do
                  begin
                    Result[I + Z] := Arg1[Z];
                    Inc(Z);
                  end;
                end;

                Inc(I);
                TempNode := PCANHdr(@FilterParser.FilterData[CANEXPRSIZE + PWord(@PChar(Node)[CANHDRSIZE + I * 2])^]);
             end;

             // Only one or no Value, so don't return as VarArray
             if (I < 2) then
               if (VIsNull(Result[0])) then
                 Result := False
               else
                 Result := VarAsType(Result[0], varString);
            end;
          else raise EDatabaseError.CreateFmt('coOp not supported (%d)', [Ord(Node^.coOp)]);
        end;

      else
        raise EDatabaseError.CreateFmt('nodeClass not supported', [Ord(Node^.nodeClass)]);
    end;
  end;

begin
  Expr := PCANExpr(@FilterParser.FilterData[0]);
  Result := ParseNode(@FilterParser.FilterData[Expr^.iNodeStart]);
end;

{ TMySQLTable *****************************************************************}

procedure TMySQLTable.DoBeforeScroll();
begin
  WantedRecord := wrNone;

  inherited;
end;

function TMySQLTable.GetCanModify(): Boolean;
begin
  if (not IndexDefs.Updated) then
    UpdateIndexDefs();

  Result := True;
end;

constructor TMySQLTable.Create(AOwner: TComponent);
begin
  inherited;

  FAutomaticLoadNextRecords := False;
  DeleteBookmarks := nil;
  FCommandType := ctTable;
  FLimitedDataReceived := False;
end;

procedure TMySQLTable.InternalClose();
begin
  inherited;

  FLimitedDataReceived := False;
  WantedRecord := wrNone;
end;

procedure TMySQLTable.InternalLast();
begin
  if (LimitedDataReceived and AutomaticLoadNextRecords and LoadNextRecords(True)) then
    WantedRecord := wrLast
  else
    inherited;
end;

procedure TMySQLTable.InternalOpen();
begin
  Assert(CommandText <> '');

  inherited;

  if (IsCursorOpen()) then
    if (Filtered) then
      InternActivateFilter();
end;

procedure TMySQLTable.InternalRefresh();
begin
  FLimitedDataReceived := False;

  inherited;
end;

function TMySQLTable.LoadNextRecords(const AllRecords: Boolean = False): Boolean;
begin
  Progress := Progress + 'N';

  RecordsReceived.ResetEvent();

  Connection.BeginSynchron(5);
  Result := Connection.InternExecuteSQL(smDataSet, SQLSelect(AllRecords), TMySQLConnection.TResultEvent(nil), nil, Self);
  Connection.EndSynchron(5);
  if (Result) then
    RecordReceived.WaitFor(INFINITE);
end;

procedure TMySQLTable.Sort(const ASortDef: TIndexDef);
var
  FieldName: string;
  Pos: Integer;
  StringFieldsEnclosed: Boolean;
begin
  StringFieldsEnclosed := False;
  Pos := 1;
  repeat
    FieldName := ExtractFieldName(ASortDef.Fields, Pos);
    if (Assigned(FindField(FieldName))) then
      StringFieldsEnclosed := StringFieldsEnclosed or (FieldByName(FieldName).DataType in [ftWideString, ftWideMemo]);
  until (FieldName = '');

  if (Active and ((ASortDef.Fields <> SortDef.Fields) or (ASortDef.DescFields <> SortDef.DescFields))) then
  begin
    if ((ASortDef.Fields <> '') and (RecordsReceived.WaitFor(IGNORE) = wrSignaled) and not LimitedDataReceived and (InternRecordBuffers.Count < 1000) and not StringFieldsEnclosed) then
      inherited
    else
    begin
      SortDef.Assign(ASortDef);
      FOffset := 0;

      Refresh();

      SetFieldsSortTag();
    end;
  end;
end;

function TMySQLTable.SQLSelect(): string;
begin
  Result := SQLSelect(False);
end;

function TMySQLTable.SQLSelect(const IgnoreLimit: Boolean): string;
var
  DescFieldName: string;
  DescPos: Integer;
  FieldName: string;
  FirstField: Boolean;
  Pos: Integer;
begin
  Result := 'SELECT * FROM ';
  if (DatabaseName <> '') then
    Result := Result + Connection.EscapeIdentifier(DatabaseName) + '.';
  Result := Result + Connection.EscapeIdentifier(CommandText);

  if (SortDef.Fields <> '') then
  begin
    Result := Result + ' ORDER BY ';
    Pos := 1; FirstField := True;
    repeat
      FieldName := ExtractFieldName(SortDef.Fields, Pos);
      if (FieldName <> '') then
      begin
        if (not FirstField) then Result := Result + ',';
        Result := Result + Connection.EscapeIdentifier(FieldName);

        DescPos := 1;
        repeat
          DescFieldName := ExtractFieldName(SortDef.DescFields, DescPos);
          if (DescFieldName = FieldName) then
            Result := Result + ' DESC';
        until (DescFieldName = '');
      end;
      FirstField := False;
    until (FieldName = '');
  end;

  if (Limit = 0) then
    RequestedRecordCount := $7fffffff
  else
  begin
    Result := Result + ' LIMIT ';
    if (Offset + InternRecordBuffers.Count > 0) then
      Result := Result + IntToStr(Offset + InternRecordBuffers.Count) + ',';
    if (IgnoreLimit) then
      RequestedRecordCount := $7fffffff - (Offset + InternRecordBuffers.Count)
    else if (InternRecordBuffers.Count = 0) then
      RequestedRecordCount := Limit
    else
      RequestedRecordCount := InternRecordBuffers.Count;
    Result := Result + IntToStr(RequestedRecordCount);
  end;
end;

{ TMySQLSyncThreads ****************************************************************}

function TMySQLSyncThreads.Add(Item: Pointer): Integer;
begin
  CriticalSection.Enter();

  Result := inherited;

  CriticalSection.Leave();
end;

constructor TMySQLSyncThreads.Create();
begin
  inherited;

  CriticalSection := TCriticalSection.Create();
end;

procedure TMySQLSyncThreads.Delete(Index: Integer);
begin
  CriticalSection.Enter();

  inherited;

  CriticalSection.Leave();
end;

destructor TMySQLSyncThreads.Destroy();
begin
  CriticalSection.Free();

  inherited;
end;

procedure TMySQLSyncThreads.Lock();
begin
  CriticalSection.Enter();
end;

procedure TMySQLSyncThreads.Release();
begin
  CriticalSection.Leave();
end;

function TMySQLSyncThreads.ThreadByIndex(Index: Integer): TMySQLConnection.TSyncThread;
begin
  Result := TMySQLConnection.TSyncThread(Items[Index]);
end;

function TMySQLSyncThreads.ThreadByThreadId(const ThreadID: TThreadID): TMySQLConnection.TSyncThread;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if (Threads[I].ThreadID = ThreadID) then
      Exit(Threads[I]);

  Result := nil;
end;

{******************************************************************************}

//var
//  Hex: string;
//  Len: Integer;
//  RBS: RawByteString;
//  SQL: string;
//  SL: TStringList;
initialization
//  Hex := '';
//  SetLength(RBS, Length(Hex) div 2);
//  HexToBin(PChar(Hex), PAnsiChar(RBS), Length(RBS));
//  SetLength(SQL, Length(RBS));
//  Len := AnsiCharToWideChar(65001, PAnsiChar(RBS), Length(RBS), PChar(SQL), Length(SQL));
//  SetLength(SQL, Len);
//
//  SL := TStringList.Create();
//  SL.Text := SQL;
//  SL.SaveToFile('C:\Test.sql');
//  SL.Free();

  MySQLConnectionOnSynchronize := nil;

  LocaleFormatSettings := TFormatSettings.Create(LOCALE_USER_DEFAULT);
  SetLength(MySQLLibraries, 0);

  MySQLDataSets := TList<TMySQLDataSet>.Create();
  MySQLSyncThreads := TMySQLSyncThreads.Create();
finalization
  MySQLDataSets.Free();
  MySQLSyncThreads.Free();

  FreeMySQLLibraries();
end.


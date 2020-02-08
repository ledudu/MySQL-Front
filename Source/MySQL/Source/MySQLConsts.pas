unit MySQLConsts;

interface {********************************************************************}

uses
  Windows;

const
  COLUMN_COMMENT_MAXLEN = 1024;
  HOSTNAME_LENGTH       = 60;
  INDEX_COMMENT_MAXLEN  = 1024;
  LOCAL_HOST            = 'localhost';
  LOCAL_HOST_NAMEDPIPE  = '.';
  MAX_ALLOWED_PACKET    = $1000000;
  MAX_PACKET_LENGTH     = $FFFFFE;
  MYSQL_NAMEDPIPE       = 'MySQL';
  MYSQL_PORT            = 3306;
  NAME_CHAR_LEN         = 64;
  NET_BUFFER_LENGTH     = $8000;
  NET_READ_TIMEOUT      = 30;
  NET_WAIT_TIMEOUT      = 8*60*60;
  NET_WRITE_TIMEOUT     = 60;
  NULL_LENGTH           = -1;
  PACKET_ERROR          = -1;
  RETRY_COUNT           = 2;
  SERVER_VERSION_LENGTH = 60;
  SCRAMBLE_LENGTH       = 20;
  SCRAMBLE_LENGTH_323   = 8;
  SQLSTATE_LENGTH       = 5;
  TABLE_COMMENT_MAXLEN  = 2048;
  TABLE_PARTITION_COMMENT_MAXLEN = 1024;
  USERNAME_LENGTH       = 16;

  // Server Status Flags
  SERVER_STATUS_IN_TRANS             = $0001;   // Transaction has started
  SERVER_STATUS_AUTOCOMMIT           = $0002;   // Server in auto_commit mode
  SERVER_STATUS_MORE_RESULTS         = $0004;   // More results on server
  SERVER_MORE_RESULTS_EXISTS         = $0008;   // Multi query - next query exists
  SERVER_QUERY_NO_GOOD_INDEX_USED    = $0010;
  SERVER_QUERY_NO_INDEX_USED         = $0020;   // The server was able to fulfill the clients request and opened a read-only non-scrollable cursor for a query. This flag comes in reply to COM_STMT_EXECUTE and COM_STMT_FETCH commands.
  SERVER_STATUS_CURSOR_EXISTS        = $0040;   // This flag is sent when a read-only cursor is exhausted, in reply to COM_STMT_FETCH command.
  SERVER_STATUS_LAST_ROW_SENT        = $0080;
  SERVER_STATUS_DB_DROPPED           = $0100;   // A database was dropped
  SERVER_STATUS_NO_BACKSLASH_ESCAPES = $0200;
  SERVER_STATUS_METADATA_CHANGED 	   = $0400;
  SERVER_QUERY_WAS_SLOW 	           = $0800;
  SERVER_PS_OUT_PARAMS 	             = $1000;
  SERVER_STATUS_IN_TRANS_READONLY 	 = $2000;   // in a read-only transaction
  SERVER_SESSION_STATE_CHANGED       = $4000;   // Connection state inform

  //client flags
  CLIENT_LONG_PASSWORD                  = $00000001;    // new more secure passwords
  CLIENT_FOUND_ROWS                     = $00000002;    // Found instead of affected rows
  CLIENT_LONG_FLAG                      = $00000004;    // Get all column flags
  CLIENT_CONNECT_WITH_DB                = $00000008;    // One can specify db on connect
  CLIENT_NO_SCHEMA                      = $00000010;    // Don't allow database.table.column
  CLIENT_COMPRESS                       = $00000020;    // Can use compression protocol
  CLIENT_ODBC                           = $00000040;    // Odbc client
  CLIENT_LOCAL_FILES                    = $00000080;    // Can use LOAD DATA LOCAL
  CLIENT_IGNORE_SPACE                   = $00000100;    // Ignore spaces before '('
  CLIENT_PROTOCOL_41                    = $00000200;    // New 4.1 protocol
  CLIENT_INTERACTIVE                    = $00000400;    // This is an interactive client
  CLIENT_SSL                            = $00000800;    // Switch to SSL after handshake
  CLIENT_IGNORE_SIGPIPE                 = $00001000;    // IGNORE sigpipes
  CLIENT_TRANSACTIONS                   = $00002000;    // Client knows about transactions
  CLIENT_RESERVED                       = $00004000;    // Old flag for 4.1 protocol
  CLIENT_SECURE_CONNECTION              = $00008000;    // Old flag for 4.1 authentication
  CLIENT_MULTI_STATEMENTS               = $00010000;    // Enable/disable multi-stmt support
  CLIENT_MULTI_RESULTS                  = $00020000;    // Enable/disable multi-results
  CLIENT_PS_MULTI_RESULTS               = $00040000;    // Multi-results and OUT parameters in PS-protocol.
  CLIENT_PLUGIN_AUTH                    = $00080000;    // Client supports plugin authentication.
  CLIENT_CONNECT_ATTRS                  = $00100000;    // Client supports connection attributes.
  CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA = $00200000;    // Enable authentication response packet to be larger than 255 bytes.
  CLIENT_CAN_HANDLE_EXPIRED_PASSWORDS   = $00400000;    // Don't close the connection for a user account with expired password.
  CLIENT_SESSION_TRACK                  = $00800000;    // Capable of handling server state change information.
  CLIENT_DEPRECATE_EOF                  = $01000000;    // Client no longer needs EOF_Packet and will use OK_Packet instead.
  CLIENT_SSL_VERIFY_SERVER_CERT         = $04000000;    // Verify server certificate.
  CLIENT_REMEMBER_OPTIONS               = $80000000;    // Don't reset the options after an unsuccessful connect.

  //field flags
  NOT_NULL_FLAG                  = $00000001;   // Field can't be NULL
  PRI_KEY_FLAG                   = $00000002;   // Field is part of a primary key
  UNIQUE_KEY_FLAG                = $00000004;   // Field is part of a unique key
  MULTIPLE_KEY_FLAG              = $00000008;   // Field is part of a key
  BLOB_FLAG                      = $00000010;   // Field is a blob
  UNSIGNED_FLAG                  = $00000020;   // Field is unsigned
  ZEROFILL_FLAG                  = $00000040;   // Field is zerofill
  BINARY_FLAG                    = $00000080;   // Field is binary
  ENUM_FLAG                      = $00000100;   // Field is an enum
  AUTO_INCREMENT_FLAG            = $00000200;   // Field is a autoincrement field
  TIMESTAMP_FLAG                 = $00000400;   // Field is a timestamp
  SET_FLAG                       = $00000800;   // field is a set
  NO_DEFAULT_VALUE_FLAG          = $00001000;   // Field doesn't have default value
  NUM_FLAG                       = $00002000;   // Field is num (for clients)
  PART_KEY_FLAG                  = $00004000;   // Intern; Part of some key
  GROUP_FLAG                     = $00008000;   // Intern: Group field
  UNIQUE_FLAG                    = $00010000;   // Intern: Used by sql_yacc
  BINCMP_FLAG                    = $00020000;   // Intern: Used by sql_yacc
  GET_FIXED_FIELDS_FLAG          = $00040000;   // Used to get fields in item tree
  FIELD_IN_PART_FUNC_FLAG        = $00080000;   // Field part of partition func
  FIELD_IN_ADD_INDEX             = $00100000;   // Intern: Field used in ADD INDEX
  FIELD_IS_RENAMED               = $00200000;   // Intern: Field is being renamed
  FIELD_FLAGS_STORAGE_MEDIA      = 22;          // Field storage media, bit 22-23
  FIELD_FLAGS_STORAGE_MEDIA_MASK = $00C00000;   // (3 shl FIELD_FLAGS_STORAGE_MEDIA)
  FIELD_FLAGS_COLUMN_FORMAT      = 24;          // Field column format, bit 24-25
  FIELD_FLAGS_COLUMN_FORMAT_MASK = $03000000;   // (3 shl FIELD_FLAGS_COLUMN_FORMAT)
  FIELD_IS_DROPPED               = $04000000;   // Intern: Field is being dropped
  EXPLICIT_NULL_FLAG             = $08000000;   // Field is explicitly specified as NULL by the user

  MAX_TINYINT_WIDTH        = 3;         // Max width for a TINY w.o. sign
  MAX_SMALLINT_WIDTH       = 5;         // Max width for a SHORT w.o. sign
  MAX_MEDIUMINT_WIDTH      = 8;         // Max width for a INT24 w.o. sign
  MAX_INT_WIDTH            = 10;        // Max width for a LONG w.o. sign
  MAX_BIGINT_WIDTH         = 20;        // Max width for a LONGLONG
  MAX_FLOAT_WIDTH          = 53;        // Max width for a FLOAT
  MAX_CHAR_WIDTH           = 255;       // Max length for a CHAR colum
  MAX_BLOB_WIDTH           = 16777216;  // Default width for blob

  REFRESH_GRANT            = $000001;  // Refresh grant tables
  REFRESH_LOG              = $000002;  // Start on new log file
  REFRESH_TABLES           = $000004;  // close all tables
  REFRESH_HOSTS            = $000008;  // Flush host cache
  REFRESH_STATUS           = $000010;  // Flush status variables
  REFRESH_THREADS          = $000020;  // Flush thread cache
  REFRESH_SLAVE            = $000040;  // Reset master info and restart slave thread
  REFRESH_MASTER           = $000080;  // Remove all bin logs in the in and truncate the index
  REFRESH_ERROR_LOG        = $000100;  // Rotate only the erorr log
  REFRESH_ENGINE_LOG       = $000200;  // Flush all storage engine logs
  REFRESH_BINARY_LOG       = $000400;  // Flush the binary log
  REFRESH_RELAY_LOG        = $000800;  // Flush the relay log
  REFRESH_GENERAL_LOG      = $001000;  // Flush the general log
  REFRESH_SLOW_LOG         = $002000;  // Flush the slow query log
  // The following can't be set with mysql_refresh()
  REFRESH_READ_LOCK        = $004000;  // Lock tables for read
  REFRESH_FAST             = $008000;  // Intern flag
  // RESET (remove all queries) from query cache
  REFRESH_QUERY_CACHE      = $010000;
  REFRESH_QUERY_CACHE_FREE = $020000;  // pack query cache
  REFRESH_DES_KEY_FILE     = $040000;
  REFRESH_USER_RESOURCES   = $080000;
  REFRESH_FOR_EXPORT       = $100000;  // FLUSH TABLES ... FOR EXPORT

  MYSQL_SHUTDOWN_KILLABLE_CONNECT    = $0;
  MYSQL_SHUTDOWN_KILLABLE_TRANS      = $1;
  MYSQL_SHUTDOWN_KILLABLE_LOCK_TABLE = $2;
  MYSQL_SHUTDOWN_KILLABLE_UPDATE     = $4;

type
  my_ulonglong = Int64;
  my_uint = Longword;
  my_int = Longint;
  my_bool = Byte;
  my_char = PAnsiChar;

  mysql_protocol_type = (
    MYSQL_PROTOCOL_DEFAULT = 0,
    MYSQL_PROTOCOL_TCP     = 1,
    MYSQL_PROTOCOL_SOCKET  = 2,
    MYSQL_PROTOCOL_PIPE    = 3,
    MYSQL_PROTOCOL_MEMORY  = 4
  );

  enum_server_command = (
    COM_SLEEP               = $00,  // (default, e.g. SHOW PROCESSLIST)
    COM_QUIT                = $01,  // mysql_close
    COM_INIT_DB             = $02,  // mysql_select_db
    COM_QUERY               = $03,  // mysql_real_query
    COM_FIELD_LIST          = $04,  // mysql_list_fields
    COM_CREATE_DB           = $05,  // mysql_create_db
    COM_DROP_DB             = $06,  // mysql_drop_db
    COM_REFRESH             = $07,  // mysql_refresh
    COM_SHUTDOWN            = $08,  // mysql_shutdown
    COM_STATISTICS          = $09,  // mysql_stat
    COM_PROCESS_INFO        = $0A,  // mysql_list_processes
    COM_CONNECT             = $0B,  // (during authentication handshake)
    COM_PROCESS_KILL        = $0C,  // mysql_kill
    COM_DEBUG               = $0D,  //
    COM_PING                = $0E,  // mysql_ping
    COM_TIME                = $0F,  // (special value for slow logs?)
    COM_DELAYED_INSERT      = $10,  //
    COM_CHANGE_USER         = $11,  // mysql_change_user
    COM_BINLOG_DUMP         = $12,  // (used by slave server / mysqlbinlog)
    COM_TABLE_DUMP          = $13,  // (used by slave server to get master table)
    COM_CONNECT_OUT         = $14,  // (used by slave to log connection to master)
    COM_REGISTER_SLAVE      = $15,  // (reports slave location to master)
    COM_STMT_PREPARE        = $16,  // see description of Prepare Packet
    COM_STMT_EXECUTE        = $17,  // see description of Execute Packet
    COM_STMT_SEND_LONG_DATA = $18,  // see description of Long Data Packet
    COM_STMT_CLOSE          = $19,  // new, for closing statement
    COM_STMT_RESET          = $1A,  //
    COM_SET_OPTION          = $1B,  // mysql_set_option
    COM_STMT_FETCH          = $1C,  //
    COM_DAEMON              = $1D,
    COM_BINLOG_DUMP_GTID    = $1E,
    COM_RESET_CONNECTION    = $1F
  );

  enum_field_types = (
    MYSQL_TYPE_DECIMAL      = 0,
    MYSQL_TYPE_TINY         = 1,
    MYSQL_TYPE_SHORT        = 2,
    MYSQL_TYPE_LONG         = 3,
    MYSQL_TYPE_FLOAT        = 4,
    MYSQL_TYPE_DOUBLE       = 5,
    MYSQL_TYPE_NULL         = 6,
    MYSQL_TYPE_TIMESTAMP    = 7,
    MYSQL_TYPE_LONGLONG     = 8,
    MYSQL_TYPE_INT24        = 9,
    MYSQL_TYPE_DATE         = 10,
    MYSQL_TYPE_TIME         = 11,
    MYSQL_TYPE_DATETIME     = 12,
    MYSQL_TYPE_YEAR         = 13,
    MYSQL_TYPE_NEWDATE      = 14,
    MYSQL_TYPE_BIT          = 16,
    MYSQL_TYPE_EUI64        = 242,
    MYSQL_TYPE_MAC48        = 243,
    MYSQL_TYPE_IPV4         = 244,
    MYSQL_TYPE_IPV6         = 245,
    MYSQL_TYPE_NEWDECIMAL   = 246,
    MYSQL_TYPE_ENUM         = 247,
    MYSQL_TYPE_SET          = 248,
    MYSQL_TYPE_TINY_BLOB    = 249,
    MYSQL_TYPE_MEDIUM_BLOB  = 250,
    MYSQL_TYPE_LONG_BLOB    = 251,
    MYSQL_TYPE_BLOB         = 252,
    MYSQL_TYPE_VAR_STRING   = 253,
    MYSQL_TYPE_STRING       = 254,
    MYSQL_TYPE_GEOMETRY     = 255
  );

  enum_mysql_option = (
    MYSQL_OPT_CONNECT_TIMEOUT              =    0,
    MYSQL_OPT_COMPRESS                     =    1,
    MYSQL_OPT_NAMED_PIPE                   =    2,
    MYSQL_INIT_COMMAND                     =    3,
    MYSQL_READ_DEFAULT_FILE                =    4,
    MYSQL_READ_DEFAULT_GROUP               =    5,
    MYSQL_SET_CHARSET_DIR                  =    6,
    MYSQL_SET_CHARSET_NAME                 =    7,
    MYSQL_OPT_LOCAL_INFILE                 =    8,
    MYSQL_OPT_PROTOCOL                     =    9,
    MYSQL_SHARED_MEMORY_BASE_NAME          =   10,
    MYSQL_OPT_READ_TIMEOUT                 =   11,
    MYSQL_OPT_WRITE_TIMEOUT                =   12,
    MYSQL_OPT_USE_RESULT                   =   13,
    MYSQL_OPT_USE_REMOTE_CONNECTION        =   14,
    MYSQL_OPT_USE_EMBEDDED_CONNECTION      =   15,
    MYSQL_OPT_GUESS_CONNECTION             =   16,
    MYSQL_SET_CLIENT_IP                    =   17,
    MYSQL_SECURE_AUTH                      =   18,
    MYSQL_REPORT_DATA_TRUNCATION           =   19,
    MYSQL_OPT_RECONNECT                    =   20,
    MYSQL_OPT_SSL_VERIFY_SERVER_CERT       =   21,
    MYSQL_PLUGIN_DIR                       =   22,
    MYSQL_DEFAULT_AUTH                     =   23,
    MYSQL_OPT_BIND                         =   24,
    MYSQL_OPT_SSL_KEY                      =   25,
    MYSQL_OPT_SSL_CERT                     =   26,
    MYSQL_OPT_SSL_CA                       =   27,
    MYSQL_OPT_SSL_CAPATH                   =   28,
    MYSQL_OPT_SSL_CIPHER                   =   29,
    MYSQL_OPT_SSL_CRL                      =   30,
    MYSQL_OPT_SSL_CRLPATH                  =   31,
    MYSQL_OPT_CONNECT_ATTR_RESET           =   32,
    MYSQL_OPT_CONNECT_ATTR_ADD             =   33,
    MYSQL_OPT_CONNECT_ATTR_DELETE          =   34,
    MYSQL_SERVER_PUBLIC_KEY                =   35,
    MYSQL_ENABLE_CLEARTEXT_PLUGIN          =   36,
    MYSQL_OPT_CAN_HANDLE_EXPIRED_PASSWORDS =   37,
    MYSQL_PROGRESS_CALLBACK                = 5999,
    MYSQL_OPT_NONBLOCK                     = 6000,
    MYSQL_OPT_USE_THREAD_SPECIFIC_MEMORY   = 6001
  );

  enum_mysql_set_option = (
    MYSQL_OPTION_MULTI_STATEMENTS_ON  = 0,
    MYSQL_OPTION_MULTI_STATEMENTS_OFF = 1
  );

  enum_session_state_type = (
    SESSION_TRACK_SYSTEM_VARIABLES,    // Session system variables
    SESSION_TRACK_SCHEMA,              // Current schema
    SESSION_TRACK_STATE_CHANGE,        // track session state changes
    SESSION_TRACK_GTIDS                // track GTIDs
  );
const
  SESSION_TRACK_BEGIN = SESSION_TRACK_SYSTEM_VARIABLES;
  SESSION_TRACK_END = SESSION_TRACK_STATE_CHANGE;

type
  mysql_enum_shutdown_level = (
    SHUTDOWN_DEFAULT               = 0,                                            // wait for existing connections to finish
    SHUTDOWN_WAIT_CONNECTIONS      = MYSQL_SHUTDOWN_KILLABLE_CONNECT,              // wait for existing trans to finish
    SHUTDOWN_WAIT_TRANSACTIONS     = MYSQL_SHUTDOWN_KILLABLE_TRANS,                // wait for existing updates to finish (=> no partial MyISAM update)
    SHUTDOWN_WAIT_UPDATES          = MYSQL_SHUTDOWN_KILLABLE_UPDATE,               // flush InnoDB buffers and other storage engines' buffers
    SHUTDOWN_WAIT_ALL_BUFFERS      = (MYSQL_SHUTDOWN_KILLABLE_UPDATE shl 1),       // don't flush InnoDB buffers, flush other storage engines' buffers
    SHUTDOWN_WAIT_CRITICAL_BUFFERS = (MYSQL_SHUTDOWN_KILLABLE_UPDATE shl 1) + 1,   // Now the 2 levels of the KILL command
    KILL_QUERY                     = 254,
    KILL_CONNECTION                = 255
  );

  enum_cursor_type = (
    CURSOR_TYPE_NO_CURSOR   = 0,
    CURSOR_TYPE_READ_ONLY   = 1,
    CURSOR_TYPE_FOR_UPDATE  = 2,
    CURSOR_TYPE_SCROLLABLE  = 4
  );


  MYSQL_FIELD_32300 = ^TMYSQL_FIELD_32300;  // MySQL 3.23.0 and higher
  TMYSQL_FIELD_32300 = record
    name: my_char;                // Name of column
    table: my_char;               // Table of column if column was a field
    def: my_char;                 // Default value (set by mysql_list_fields)
    field_type: enum_field_types; // Type of field. Se mysql_com.h for types
    length: my_uint;              // Width of column
    max_length: my_uint;          // Max width of selected set
    flags: my_uint;               // Div flags
    decimals: my_uint;            // Number of decimals in field
  end;

  MYSQL_FIELD_40000 = ^TMYSQL_FIELD_40000;  // MySQL 4.0.0 and higher
  TMYSQL_FIELD_40000 = packed record
    name: my_char;                // Name of column
    table: my_char;               // Table of column if column was a field
    org_table: my_char;           // Org table name if table was an alias
    db: my_char;                  // Database for table
    def: my_char;                 // Default value (set by mysql_list_fields)
    length: my_uint;              // Width of column
    max_length: my_uint;          // Max width of selected set
    flags: my_uint;               // Div flags
    decimals: my_uint;            // Number of decimals in field
    field_type: enum_field_types; // Type of field. Se mysql_com.h for types
  end;

  MYSQL_FIELD_40100 = ^TMYSQL_FIELD_40100;  // MySQL 4.1.0 and higher
  TMYSQL_FIELD_40100 = packed record
    name: my_char;                // Name of column
    org_name: my_char;            // Original column name, if an alias
    table: my_char;               // Table of column if column was a field
    org_table: my_char;           // Org table name if table was an alias
    db: my_char;                  // Database for table
    def: my_char;                 // Default value (set by mysql_list_fields)
    length: my_uint;              // Width of column
    max_length: my_uint;          // Max width of selected set
    name_length: my_uint;
    org_name_length: my_uint;
    table_length: my_uint;
    org_table_length: my_uint;
    db_length: my_uint;
    def_length: my_uint;
    flags: my_uint;               // Div flags
    decimals: my_uint;            // Number of decimals in field
    charsetnr: my_uint;           // Character set
    field_type: enum_field_types; // Type of field. Se mysql_com.h for types
  end;

  MYSQL_FIELD_40101 = ^TMYSQL_FIELD_40101;  // MySQL 4.1.1 and higher
  TMYSQL_FIELD_40101 = packed record
    name: my_char;                // Name of column
    org_name: my_char;            // Original column name, if an alias
    table: my_char;               // Table of column if column was a field
    org_table: my_char;           // Org table name if table was an  alias
    db: my_char;                  // Database for table
    catalog: my_char;             // Catalog for table
    def: my_char;                 // Default value (set by mysql_list_fields)
    length: my_uint;              // Width of column
    max_length: my_uint;          // Max width of selected set
    name_length: my_uint;
    org_name_length: my_uint;
    table_length: my_uint;
    org_table_length: my_uint;
    db_length: my_uint;
    catalog_length: my_uint;
    def_length: my_uint;
    flags: my_uint;               // Div flags
    decimals: my_uint;            // Number of decimals in field
    charsetnr: my_uint;           // Character set
    field_type: enum_field_types; // Type of field. Se mysql_com.h for types
  end;

  MYSQL_FIELD = MYSQL_FIELD_40101;
  TMYSQL_FIELD = TMYSQL_FIELD_40101;

  MYSQL_FIELDS = ^TMYSQL_FIELDS;
  TMYSQL_FIELDS = array[0 .. MaxInt div SizeOf(MYSQL_FIELD) - 1] of MYSQL_FIELD;

  MYSQL_FIELD_OFFSET = my_uint;

  MYSQL_ROW = ^TMYSQL_ROW;
  TMYSQL_ROW = array[0 .. MaxInt div SizeOf(MYSQL_ROW) - 1] of my_char;

  MYSQL_ROWS = Pointer;
  MYSQL_ROW_OFFSET = MYSQL_ROWS;

  MYSQL_LENGTHS = ^TMYSQL_LENGTHS;
  TMYSQL_LENGTHS = array[0 .. MaxInt div SizeOf(my_int) - 1] of my_int;

  MYSQL = Pointer;
  MYSQL_RES = Pointer;

type                                                                               
  Tlocal_infile_init = function (ptr: PPointer; filename: my_char; const userdata): my_int; cdecl;
  Tlocal_infile_read = function (ptr: Pointer; buf: my_char; buf_len: my_uint): my_int; cdecl;
  Tlocal_infile_end = procedure (ptr: Pointer); cdecl;
  Tlocal_infile_error = function (ptr: Pointer; error_msg: my_char; error_msg_len: my_uint): my_int; cdecl;

  Tmy_init = procedure (); stdcall;
  Tmysql_affected_rows = function (mysql: MYSQL): my_ulonglong; stdcall;
  Tmysql_change_user = function (mysql: MYSQL; const user, passwd, db: my_char): my_bool; stdcall;
  Tmysql_character_set_name = function (mysql: MYSQL): my_char; stdcall;
  Tmysql_close = procedure (mysql: MYSQL); stdcall;
  Tmysql_connect = function (mysql: MYSQL; const host, user, passwd: my_char): MYSQL; stdcall;
  Tmysql_create_db = function (mysql: MYSQL; const DB: my_char): my_int; stdcall;
  Tmysql_data_seek = procedure (res: MYSQL_RES; offset: my_ulonglong); stdcall;
  Tmysql_debug = procedure (const debug: my_char); stdcall;
  Tmysql_drop_db = function (mysql: MYSQL; const DB: my_char): my_int; stdcall;
  Tmysql_dump_debug_info = function (mysql: MYSQL): my_int; stdcall;
  Tmysql_eof = function (res: MYSQL_RES): my_bool; stdcall;
  Tmysql_errno = function (mysql: MYSQL): my_uint; stdcall;
  Tmysql_error = function (mysql: MYSQL): my_char; stdcall;
  Tmysql_escape_string = function (_to: my_char; const from: my_char; from_length: my_uint): my_uint; stdcall;
  Tmysql_fetch_field = function (res: MYSQL_RES): MYSQL_FIELD; stdcall;
  Tmysql_fetch_fields = function (res: MYSQL_RES): MYSQL_FIELDS; stdcall;
  Tmysql_fetch_field_direct = function (res: MYSQL_RES; fieldnr: my_uint): MYSQL_FIELD; stdcall;
  Tmysql_fetch_lengths = function (res: MYSQL_RES): MYSQL_LENGTHS; stdcall;
  Tmysql_fetch_row = function (res: MYSQL_RES): MYSQL_ROW; stdcall;
  Tmysql_field_count = function (mysql: MYSQL): my_uint; stdcall;
  Tmysql_field_seek = function (res: MYSQL_RES; offset: MYSQL_FIELD_OFFSET): MYSQL_FIELD_OFFSET; stdcall;
  Tmysql_field_tell = function (res: MYSQL_RES): my_uint; stdcall;
  Tmysql_free_result = procedure (res: MYSQL_RES); stdcall;
  Tmysql_get_client_info = function (): my_char; stdcall;
  Tmysql_get_client_version = function: my_uint; stdcall;
  Tmysql_get_host_info = function (mysql: MYSQL): my_char; stdcall;
  Tmysql_get_proto_info = function (mysql: MYSQL): my_uint; stdcall;
  Tmysql_get_server_info = function (mysql: MYSQL): my_char; stdcall;
  Tmysql_get_server_version = function (mysql: MYSQL): my_uint; stdcall;
  Tmysql_info = function (mysql: MYSQL): my_char; stdcall;
  Tmysql_init = function (mysql: MYSQL): MYSQL; stdcall;
  Tmysql_insert_id = function (mysql: MYSQL): my_ulonglong; stdcall;
  Tmysql_kill = function (mysql: MYSQL; pid: my_uint): my_int; stdcall;
  Tmysql_library_end = procedure (); stdcall;
  Tmysql_library_init = function (argc: my_int; const argv, groups: my_char): my_int; stdcall;
  Tmysql_list_dbs = function (mysql: MYSQL; const wild: my_char): MYSQL_RES; stdcall;
  Tmysql_list_fields = function (mysql: MYSQL; const table, wild: my_char): MYSQL_RES; stdcall;
  Tmysql_list_processes = function (mysql: MYSQL): MYSQL_RES; stdcall;
  Tmysql_list_tables = function (mysql: MYSQL; const wild: my_char): MYSQL_RES; stdcall;
  Tmysql_num_fields = function (res: MYSQL_RES): my_uint; stdcall;
  Tmysql_num_rows = function (res: MYSQL_RES): my_ulonglong; stdcall;
  Tmysql_options = function (mysql: MYSQL; option: enum_mysql_option; const arg: my_char): my_int; stdcall;
  Tmysql_ping = function (mysql: MYSQL): my_int; stdcall;
  Tmysql_query = function (mysql: MYSQL; const q: my_char): my_int; stdcall;
  Tmysql_real_connect = function (mysql: MYSQL; const host, user, passwd, db: my_char; port: my_uint; const unix_socket: my_char; clientflag: my_uint): MYSQL; stdcall;
  Tmysql_real_escape_string = function (mysql: MYSQL; _to: my_char; const from: my_char; length: my_uint): my_uint; stdcall;
  Tmysql_real_query = function (mysql: MYSQL; const query: my_char; length: my_uint): my_int; stdcall;
  Tmysql_reload = function (mysql: MYSQL): my_int; stdcall;
  Tmysql_row_seek = function (res: MYSQL_RES; offset: MYSQL_ROW_OFFSET): MYSQL_ROW_OFFSET; stdcall;
  Tmysql_row_tell = function (res: MYSQL_RES): MYSQL_ROWS; stdcall;
  Tmysql_select_db = function (mysql: MYSQL; const db: my_char): my_int; stdcall;
  Tmysql_session_track_get_first = function (mysql: MYSQL; state_type: enum_session_state_type; out data: my_char; out length: size_t): my_int; stdcall;
  Tmysql_session_track_get_next = function (mysql: MYSQL; state_type: enum_session_state_type; out data: my_char; out length: size_t): my_int; stdcall;
  Tmysql_set_character_set = function (mysql: MYSQL; const csname: my_char): my_int; stdcall;
  Tmysql_set_server_option = function (mysql: MYSQL; option: enum_mysql_set_option): my_int; stdcall;
  Tmysql_shutdown = function (mysql: MYSQL; shutdown_level: mysql_enum_shutdown_level): my_int; stdcall;
  Tmysql_sqlstate = function (mysql: MYSQL): my_char; stdcall;
  Tmysql_ssl_set = function (mysql: MYSQL; const key, cert, ca, capath: my_char): my_int; stdcall;
  Tmysql_stat = function (mysql: MYSQL): my_char; stdcall;
  Tmysql_store_result = function (mysql: MYSQL): MYSQL_RES; stdcall;
  Tmysql_thread_end = procedure (); stdcall;
  Tmysql_thread_id = function (mysql: MYSQL): my_uint; stdcall;
  Tmysql_thread_init = function (): my_bool; stdcall;
  Tmysql_thread_save = function (): my_uint; stdcall;
  Tmysql_use_result = function (mysql: MYSQL): MYSQL_RES; stdcall;
  Tmysql_warning_count = function (mysql: MYSQL): my_uint; stdcall;
  Tmysql_commit = function (mysql: MYSQL): my_bool; stdcall;
  Tmysql_rollback = function (mysql: MYSQL): my_bool; stdcall;
  Tmysql_autocommit = function (mysql: MYSQL; mode: my_bool): my_bool; stdcall;
  Tmysql_more_results = function (mysql: MYSQL): my_bool; stdcall;
  Tmysql_next_result = function (mysql: MYSQL): my_int; stdcall;
  Tmysql_set_local_infile_default = procedure (mysql: MYSQL); cdecl;
  Tmysql_set_local_infile_handler = procedure (mysql: MYSQL; local_infile_init: Tlocal_infile_init; local_infile_read: Tlocal_infile_read; local_infile_end: Tlocal_infile_end; local_infile_error: Tlocal_infile_error; userdata: Pointer); cdecl;

type
  TMySQL_Character_Sets = record
    CharsetName: PAnsiChar;
    CodePage: Word;
    MaxLen: Byte;
  end;
const
  MySQL_Character_Sets: array[0 .. 31 - 1] of TMySQL_Character_Sets = (
    (CharsetName: 'big5';       CodePage: 65000; MaxLen: 2; ),
    (CharsetName: 'czech';      CodePage: 28592; MaxLen: 1; ),
    (CharsetName: 'dec8';       CodePage:     0; MaxLen: 1; ),
    (CharsetName: 'dos';        CodePage:   437; MaxLen: 1; ),
    (CharsetName: 'german1';    CodePage:  1252; MaxLen: 1; ),
    (CharsetName: 'hp8';        CodePage:     0; MaxLen: 1; ),
    (CharsetName: 'koi8_ru';    CodePage: 21866; MaxLen: 1; ),
    (CharsetName: 'latin1';     CodePage:  1252; MaxLen: 1; ),
    (CharsetName: 'latin2';     CodePage: 28592; MaxLen: 1; ),
    (CharsetName: 'swe7';       CodePage: 20107; MaxLen: 1; ),
    (CharsetName: 'usa7';       CodePage:  1252; MaxLen: 1; ),
    (CharsetName: 'ujis';       CodePage: 20932; MaxLen: 1; ),
    (CharsetName: 'sjis';       CodePage:   932; MaxLen: 1; ),
    (CharsetName: 'cp1251';     CodePage:  1251; MaxLen: 1; ),
    (CharsetName: 'danish';     CodePage:  1252; MaxLen: 1; ),
    (CharsetName: 'hebrew';     CodePage:  1255; MaxLen: 1; ),
    (CharsetName: 'win1251';    CodePage:  1251; MaxLen: 1; ),
    (CharsetName: 'tis620';     CodePage:   874; MaxLen: 1; ),
    (CharsetName: 'euc_kr';     CodePage:   949; MaxLen: 1; ),
    (CharsetName: 'estonia';    CodePage: 28603; MaxLen: 1; ),
    (CharsetName: 'hungarian';  CodePage: 28592; MaxLen: 1; ),
    (CharsetName: 'koi8_ukr';   CodePage: 20866; MaxLen: 1; ),
    (CharsetName: 'win1251ukr'; CodePage:  1251; MaxLen: 1; ),
    (CharsetName: 'gb2312';     CodePage:   936; MaxLen: 1; ),
    (CharsetName: 'greek';      CodePage: 28597; MaxLen: 1; ),
    (CharsetName: 'win1250';    CodePage:  1250; MaxLen: 1; ),
    (CharsetName: 'croat';      CodePage: 28592; MaxLen: 1; ),
    (CharsetName: 'gbk';        CodePage:   936; MaxLen: 1; ),
    (CharsetName: 'cp1257';     CodePage:  1257; MaxLen: 1; ),
    (CharsetName: 'latin5';     CodePage:  1254; MaxLen: 1; ),
    (CharsetName: 'latin1_de';  CodePage:  1252; MaxLen: 1; )
  );

type
  TMySQL_Collations = packed record
    CharsetNr: Byte;
    CharsetName: PAnsiChar;
    Default: Boolean;
    CodePage: Word;
    MaxLen: Byte;
  end;
const
  MySQL_Collations: array[0 .. 199 - 1] of TMySQL_Collations = (
    (CharsetNr:   1; CharsetName: 'big5';    Default: True ; CodePage: 65000; MaxLen: 2; ),
    (CharsetNr:   2; CharsetName: 'latin2';  Default: False; CodePage: 28592; MaxLen: 1; ),
    (CharsetNr:   3; CharsetName: 'dec8';    Default: True ; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:   4; CharsetName: 'cp850';   Default: True ; CodePage:   850; MaxLen: 1; ),
    (CharsetNr:   5; CharsetName: 'latin1';  Default: False; CodePage:  1252; MaxLen: 1; ),
    (CharsetNr:   6; CharsetName: 'hp8';     Default: True ; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:   7; CharsetName: 'koi8r';   Default: True ; CodePage: 20866; MaxLen: 1; ),
    (CharsetNr:   8; CharsetName: 'latin1';  Default: True ; CodePage:  1252; MaxLen: 1; ),
    (CharsetNr:   9; CharsetName: 'latin2';  Default: True ; CodePage: 28592; MaxLen: 1; ),
    (CharsetNr:  10; CharsetName: 'swe7';    Default: True ; CodePage: 20107; MaxLen: 0; ),
    (CharsetNr:  11; CharsetName: 'ascii';   Default: True ; CodePage:  1252; MaxLen: 1; ),
    (CharsetNr:  12; CharsetName: 'ujis';    Default: True ; CodePage: 20932; MaxLen: 3; ),
    (CharsetNr:  13; CharsetName: 'sjis';    Default: True ; CodePage:   932; MaxLen: 2; ),
    (CharsetNr:  14; CharsetName: 'cp1251';  Default: False; CodePage:  1251; MaxLen: 1; ),
    (CharsetNr:  15; CharsetName: 'latin1';  Default: False; CodePage:  1252; MaxLen: 1; ),
    (CharsetNr:  16; CharsetName: 'hebrew';  Default: True ; CodePage:  1255; MaxLen: 1; ),
    (CharsetNr:  18; CharsetName: 'tis620';  Default: True ; CodePage:   874; MaxLen: 1; ),
    (CharsetNr:  19; CharsetName: 'euckr';   Default: True ; CodePage: 51949; MaxLen: 2; ),
    (CharsetNr:  20; CharsetName: 'latin7';  Default: False; CodePage: 28603; MaxLen: 1; ),
    (CharsetNr:  21; CharsetName: 'latin2';  Default: False; CodePage: 28592; MaxLen: 1; ),
    (CharsetNr:  22; CharsetName: 'koi8u';   Default: True ; CodePage: 20866; MaxLen: 1; ),
    (CharsetNr:  23; CharsetName: 'cp1251';  Default: False; CodePage:  1251; MaxLen: 1; ),
    (CharsetNr:  24; CharsetName: 'gb2312';  Default: True ; CodePage:   936; MaxLen: 2; ),
    (CharsetNr:  25; CharsetName: 'greek';   Default: True ; CodePage: 28597; MaxLen: 1; ),
    (CharsetNr:  26; CharsetName: 'cp1250';  Default: True ; CodePage:  1250; MaxLen: 1; ),
    (CharsetNr:  27; CharsetName: 'latin2';  Default: False; CodePage: 28592; MaxLen: 1; ),
    (CharsetNr:  28; CharsetName: 'gbk';     Default: True ; CodePage:   936; MaxLen: 2; ),
    (CharsetNr:  29; CharsetName: 'cp1257';  Default: False; CodePage:  1257; MaxLen: 1; ),
    (CharsetNr:  30; CharsetName: 'latin5';  Default: True ; CodePage:  1254; MaxLen: 1; ),
    (CharsetNr:  31; CharsetName: 'latin1';  Default: False; CodePage:  1252; MaxLen: 1; ),
    (CharsetNr:  32; CharsetName: 'armscii8';Default: True ; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:  33; CharsetName: 'utf8';    Default: True ; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr:  34; CharsetName: 'cp1250';  Default: False; CodePage:  1250; MaxLen: 1; ),
    (CharsetNr:  35; CharsetName: 'ucs2';    Default: True ; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr:  36; CharsetName: 'cp866';   Default: True ; CodePage:   866; MaxLen: 1; ),
    (CharsetNr:  37; CharsetName: 'keybcs2'; Default: True ; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:  38; CharsetName: 'macce';   Default: True ; CodePage: 10029; MaxLen: 1; ),
    (CharsetNr:  39; CharsetName: 'macroman';Default: True ; CodePage: 10000; MaxLen: 1; ),
    (CharsetNr:  40; CharsetName: 'cp852';   Default: True ; CodePage:   852; MaxLen: 1; ),
    (CharsetNr:  41; CharsetName: 'latin7';  Default: True ; CodePage: 28603; MaxLen: 1; ),
    (CharsetNr:  42; CharsetName: 'latin7';  Default: False; CodePage: 28603; MaxLen: 1; ),
    (CharsetNr:  43; CharsetName: 'macce';   Default: False; CodePage: 10029; MaxLen: 1; ),
    (CharsetNr:  44; CharsetName: 'cp1250';  Default: False; CodePage:  1250; MaxLen: 1; ),
    (CharsetNr:  45; CharsetName: 'utf8mb4'; Default: True; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr:  46; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr:  47; CharsetName: 'latin1';  Default: False; CodePage:  1252; MaxLen: 1; ),
    (CharsetNr:  48; CharsetName: 'latin1';  Default: False; CodePage:  1252; MaxLen: 1; ),
    (CharsetNr:  49; CharsetName: 'latin1';  Default: False; CodePage:  1252; MaxLen: 1; ),
    (CharsetNr:  50; CharsetName: 'cp1251';  Default: False; CodePage:  1251; MaxLen: 1; ),
    (CharsetNr:  51; CharsetName: 'cp1251';  Default: True ; CodePage:  1251; MaxLen: 1; ),
    (CharsetNr:  52; CharsetName: 'cp1251';  Default: False; CodePage:  1251; MaxLen: 1; ),
    (CharsetNr:  53; CharsetName: 'macroman';Default: False; CodePage: 10000; MaxLen: 1; ),
    (CharsetNr:  54; CharsetName: 'utf16';   Default: True ; CodePage:  1200; MaxLen: 1; ),
    (CharsetNr:  55; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 1; ),
    (CharsetNr:  57; CharsetName: 'cp1256';  Default: True ; CodePage:  1256; MaxLen: 1; ),
    (CharsetNr:  58; CharsetName: 'cp1257';  Default: False; CodePage:  1257; MaxLen: 1; ),
    (CharsetNr:  59; CharsetName: 'cp1257';  Default: True ; CodePage:  1257; MaxLen: 1; ),
    (CharsetNr:  60; CharsetName: 'utf32';   Default: True ; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:  61; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:  63; CharsetName: 'binary';  Default: True ; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:  64; CharsetName: 'armscii8';Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:  65; CharsetName: 'ascii';   Default: False; CodePage:  1252; MaxLen: 1; ),
    (CharsetNr:  66; CharsetName: 'cp1250';  Default: False; CodePage:  1250; MaxLen: 1; ),
    (CharsetNr:  67; CharsetName: 'cp1256';  Default: False; CodePage:  1256; MaxLen: 1; ),
    (CharsetNr:  68; CharsetName: 'cp866';   Default: False; CodePage:   866; MaxLen: 1; ),
    (CharsetNr:  69; CharsetName: 'dec8';    Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:  70; CharsetName: 'greek';   Default: False; CodePage: 28597; MaxLen: 1; ),
    (CharsetNr:  71; CharsetName: 'hebrew';  Default: False; CodePage:  1255; MaxLen: 1; ),
    (CharsetNr:  72; CharsetName: 'hp8';     Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:  73; CharsetName: 'keybcs2'; Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:  74; CharsetName: 'koi8r';   Default: False; CodePage: 20866; MaxLen: 1; ),
    (CharsetNr:  75; CharsetName: 'koi8u';   Default: False; CodePage: 21866; MaxLen: 1; ),
    (CharsetNr:  77; CharsetName: 'latin2';  Default: False; CodePage: 28592; MaxLen: 1; ),
    (CharsetNr:  78; CharsetName: 'latin5';  Default: False; CodePage:  1254; MaxLen: 1; ),
    (CharsetNr:  79; CharsetName: 'latin7';  Default: False; CodePage: 28603; MaxLen: 1; ),
    (CharsetNr:  80; CharsetName: 'cp850';   Default: False; CodePage:   850; MaxLen: 1; ),
    (CharsetNr:  81; CharsetName: 'cp852';   Default: False; CodePage:   852; MaxLen: 1; ),
    (CharsetNr:  82; CharsetName: 'swe7';    Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:  83; CharsetName: 'utf8';    Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr:  84; CharsetName: 'big5';    Default: False; CodePage: 65000; MaxLen: 2; ),
    (CharsetNr:  85; CharsetName: 'euckr';   Default: False; CodePage: 51949; MaxLen: 2; ),
    (CharsetNr:  86; CharsetName: 'gb2312';  Default: False; CodePage:   936; MaxLen: 2; ),
    (CharsetNr:  87; CharsetName: 'gbk';     Default: False; CodePage:   936; MaxLen: 2; ),
    (CharsetNr:  88; CharsetName: 'sjis';    Default: False; CodePage:   932; MaxLen: 2; ),
    (CharsetNr:  89; CharsetName: 'tis620';  Default: False; CodePage:   874; MaxLen: 1; ),
    (CharsetNr:  90; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr:  91; CharsetName: 'ujis';    Default: False; CodePage: 20932; MaxLen: 3; ),
    (CharsetNr:  92; CharsetName: 'geostd8'; Default: True ; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:  93; CharsetName: 'geostd8'; Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr:  94; CharsetName: 'latin1';  Default: False; CodePage:  1252; MaxLen: 1; ),
    (CharsetNr:  95; CharsetName: 'cp932';   Default: True ; CodePage:   932; MaxLen: 2; ),
    (CharsetNr:  96; CharsetName: 'cp932';   Default: False; CodePage:   932; MaxLen: 2; ),
    (CharsetNr:  97; CharsetName: 'eucjpms'; Default: True ; CodePage:     0; MaxLen: 3; ),
    (CharsetNr:  98; CharsetName: 'eucjpms'; Default: False; CodePage:     0; MaxLen: 3; ),
    (CharsetNr:  99; CharsetName: 'cp1250';  Default: False; CodePage:  1250; MaxLen: 1; ),
    (CharsetNr: 101; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 102; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 103; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 104; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 105; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 106; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 107; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 108; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 109; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 110; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 111; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 112; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 113; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 114; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 115; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 116; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 117; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 118; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 119; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 120; CharsetName: 'utf16';   Default: False; CodePage:  1200; MaxLen: 0; ),
    (CharsetNr: 128; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 129; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 130; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 131; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 132; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 133; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 134; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 135; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 136; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 137; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 138; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 139; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 140; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 141; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 142; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 143; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 144; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 145; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 146; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 147; CharsetName: 'ucs2';    Default: False; CodePage:  1200; MaxLen: 2; ),
    (CharsetNr: 160; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 161; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 162; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 163; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 164; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 165; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 166; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 167; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 168; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 169; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 170; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 171; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 172; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 173; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 174; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 175; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 176; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 177; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 178; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 179; CharsetName: 'utf32';   Default: False; CodePage:     0; MaxLen: 0; ),
    (CharsetNr: 192; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 193; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 194; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 195; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 196; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 197; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 198; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 199; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 200; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 201; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 202; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 203; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 204; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 205; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 206; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 207; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 208; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 209; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 210; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 211; CharsetName: 'utf8mb3'; Default: False; CodePage: 65001; MaxLen: 3; ),
    (CharsetNr: 224; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 225; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 226; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 227; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 228; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 229; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 230; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 231; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 232; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 233; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 234; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 235; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 236; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 237; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 238; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 239; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 240; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 241; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 242; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 243; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 244; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 245; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 246; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; ),
    (CharsetNr: 247; CharsetName: 'utf8mb4'; Default: False; CodePage: 65001; MaxLen: 4; )
  );
const
  EE_CANTCREATEFILE                          =    1;
  EE_READ                                    =    2;
  EE_WRITE                                   =    3;
  EE_BADCLOSE                                =    4;
  EE_OUTOFMEMORY                             =    5;
  EE_DELETE                                  =    6;
  EE_LINK                                    =    7;
  EE_EOFERR                                  =    9;
  EE_CANTLOCK                                =   10;
  EE_CANTUNLOCK                              =   11;
  EE_DIR                                     =   12;
  EE_STAT                                    =   13;
  EE_CANT_CHSIZE                             =   14;
  EE_CANT_OPEN_STREAM                        =   15;
  EE_GETWD                                   =   16;
  EE_SETWD                                   =   17;
  EE_LINK_WARNING                            =   18;
  EE_OPEN_WARNING                            =   19;
  EE_DISK_FULL                               =   20;
  EE_CANT_MKDIR                              =   21;
  EE_UNKNOWN_CHARSET                         =   22;
  EE_OUT_OF_FILERESOURCES                    =   23;
  EE_CANT_READLINK                           =   24;
  EE_CANT_SYMLINK                            =   25;
  EE_REALPATH                                =   26;
  EE_SYNC                                    =   27;
  EE_UNKNOWN_COLLATION                       =   28;
  EE_FILENOTFOUND                            =   29;
  EE_FILE_NOT_CLOSED                         =   30;

  ER_ERROR_FIRST                                                      = 1000;
  ER_HASHCHK                                                          = 1000;
  ER_NISAMCHK                                                         = 1001;
  ER_NO                                                               = 1002;
  ER_YES                                                              = 1003;
  ER_CANT_CREATE_FILE                                                 = 1004;
  ER_CANT_CREATE_TABLE                                                = 1005;
  ER_CANT_CREATE_DB                                                   = 1006;
  ER_DB_CREATE_EXISTS                                                 = 1007;
  ER_DB_DROP_EXISTS                                                   = 1008;
  ER_DB_DROP_DELETE                                                   = 1009;
  ER_DB_DROP_RMDIR                                                    = 1010;
  ER_CANT_DELETE_FILE                                                 = 1011;
  ER_CANT_FIND_SYSTEM_REC                                             = 1012;
  ER_CANT_GET_STAT                                                    = 1013;
  ER_CANT_GET_WD                                                      = 1014;
  ER_CANT_LOCK                                                        = 1015;
  ER_CANT_OPEN_FILE                                                   = 1016;
  ER_FILE_NOT_FOUND                                                   = 1017;
  ER_CANT_READ_DIR                                                    = 1018;
  ER_CANT_SET_WD                                                      = 1019;
  ER_CHECKREAD                                                        = 1020;
  ER_DISK_FULL                                                        = 1021;
  ER_DUP_KEY                                                          = 1022;
  ER_ERROR_ON_CLOSE                                                   = 1023;
  ER_ERROR_ON_READ                                                    = 1024;
  ER_ERROR_ON_RENAME                                                  = 1025;
  ER_ERROR_ON_WRITE                                                   = 1026;
  ER_FILE_USED                                                        = 1027;
  ER_FILSORT_ABORT                                                    = 1028;
  ER_FORM_NOT_FOUND                                                   = 1029;
  ER_GET_ERRNO                                                        = 1030;
  ER_ILLEGAL_HA                                                       = 1031;
  ER_KEY_NOT_FOUND                                                    = 1032;
  ER_NOT_FORM_FILE                                                    = 1033;
  ER_NOT_KEYFILE                                                      = 1034;
  ER_OLD_KEYFILE                                                      = 1035;
  ER_OPEN_AS_READONLY                                                 = 1036;
  ER_OUTOFMEMORY                                                      = 1037;
  ER_OUT_OF_SORTMEMORY                                                = 1038;
  ER_UNEXPECTED_EOF                                                   = 1039;
  ER_CON_COUNT_ERROR                                                  = 1040;
  ER_OUT_OF_RESOURCES                                                 = 1041;
  ER_BAD_HOST_ERROR                                                   = 1042;
  ER_HANDSHAKE_ERROR                                                  = 1043;
  ER_DBACCESS_DENIED_ERROR                                            = 1044;
  ER_ACCESS_DENIED_ERROR                                              = 1045;
  ER_NO_DB_ERROR                                                      = 1046;
  ER_UNKNOWN_COM_ERROR                                                = 1047;
  ER_BAD_NULL_ERROR                                                   = 1048;
  ER_BAD_DB_ERROR                                                     = 1049;
  ER_TABLE_EXISTS_ERROR                                               = 1050;
  ER_BAD_TABLE_ERROR                                                  = 1051;
  ER_NON_UNIQ_ERROR                                                   = 1052;
  ER_SERVER_SHUTDOWN                                                  = 1053;
  ER_BAD_FIELD_ERROR                                                  = 1054;
  ER_WRONG_FIELD_WITH_GROUP                                           = 1055;
  ER_WRONG_GROUP_FIELD                                                = 1056;
  ER_WRONG_SUM_SELECT                                                 = 1057;
  ER_WRONG_VALUE_COUNT                                                = 1058;
  ER_TOO_LONG_IDENT                                                   = 1059;
  ER_DUP_FIELDNAME                                                    = 1060;
  ER_DUP_KEYNAME                                                      = 1061;
  ER_DUP_ENTRY                                                        = 1062;
  ER_WRONG_FIELD_SPEC                                                 = 1063;
  ER_PARSE_ERROR                                                      = 1064;
  ER_EMPTY_QUERY                                                      = 1065;
  ER_NONUNIQ_TABLE                                                    = 1066;
  ER_INVALID_DEFAULT                                                  = 1067;
  ER_MULTIPLE_PRI_KEY                                                 = 1068;
  ER_TOO_MANY_KEYS                                                    = 1069;
  ER_TOO_MANY_KEY_PARTS                                               = 1070;
  ER_TOO_LONG_KEY                                                     = 1071;
  ER_KEY_COLUMN_DOES_NOT_EXITS                                        = 1072;
  ER_BLOB_USED_AS_KEY                                                 = 1073;
  ER_TOO_BIG_FIELDLENGTH                                              = 1074;
  ER_WRONG_AUTO_KEY                                                   = 1075;
  ER_READY                                                            = 1076;
  ER_NORMAL_SHUTDOWN                                                  = 1077;
  ER_GOT_SIGNAL                                                       = 1078;
  ER_SHUTDOWN_COMPLETE                                                = 1079;
  ER_FORCING_CLOSE                                                    = 1080;
  ER_IPSOCK_ERROR                                                     = 1081;
  ER_NO_SUCH_INDEX                                                    = 1082;
  ER_WRONG_FIELD_TERMINATORS                                          = 1083;
  ER_BLOBS_AND_NO_TERMINATED                                          = 1084;
  ER_TEXTFILE_NOT_READABLE                                            = 1085;
  ER_FILE_EXISTS_ERROR                                                = 1086;
  ER_LOAD_INFO                                                        = 1087;
  ER_ALTER_INFO                                                       = 1088;
  ER_WRONG_SUB_KEY                                                    = 1089;
  ER_CANT_REMOVE_ALL_FIELDS                                           = 1090;
  ER_CANT_DROP_FIELD_OR_KEY                                           = 1091;
  ER_INSERT_INFO                                                      = 1092;
  ER_UPDATE_TABLE_USED                                                = 1093;
  ER_NO_SUCH_THREAD                                                   = 1094;
  ER_KILL_DENIED_ERROR                                                = 1095;
  ER_NO_TABLES_USED                                                   = 1096;
  ER_TOO_BIG_SET                                                      = 1097;
  ER_NO_UNIQUE_LOGFILE                                                = 1098;
  ER_TABLE_NOT_LOCKED_FOR_WRITE                                       = 1099;
  ER_TABLE_NOT_LOCKED                                                 = 1100;
  ER_BLOB_CANT_HAVE_DEFAULT                                           = 1101;
  ER_WRONG_DB_NAME                                                    = 1102;
  ER_WRONG_TABLE_NAME                                                 = 1103;
  ER_TOO_BIG_SELECT                                                   = 1104;
  ER_UNKNOWN_ERROR                                                    = 1105;
  ER_UNKNOWN_PROCEDURE                                                = 1106;
  ER_WRONG_PARAMCOUNT_TO_PROCEDURE                                    = 1107;
  ER_WRONG_PARAMETERS_TO_PROCEDURE                                    = 1108;
  ER_UNKNOWN_TABLE                                                    = 1109;
  ER_FIELD_SPECIFIED_TWICE                                            = 1110;
  ER_INVALID_GROUP_FUNC_USE                                           = 1111;
  ER_UNSUPPORTED_EXTENSION                                            = 1112;
  ER_TABLE_MUST_HAVE_COLUMNS                                          = 1113;
  ER_RECORD_FILE_FULL                                                 = 1114;
  ER_UNKNOWN_CHARACTER_SET                                            = 1115;
  ER_TOO_MANY_TABLES                                                  = 1116;
  ER_TOO_MANY_FIELDS                                                  = 1117;
  ER_TOO_BIG_ROWSIZE                                                  = 1118;
  ER_STACK_OVERRUN                                                    = 1119;
  ER_WRONG_OUTER_JOIN                                                 = 1120;
  ER_NULL_COLUMN_IN_INDEX                                             = 1121;
  ER_CANT_FIND_UDF                                                    = 1122;
  ER_CANT_INITIALIZE_UDF                                              = 1123;
  ER_UDF_NO_PATHS                                                     = 1124;
  ER_UDF_EXISTS                                                       = 1125;
  ER_CANT_OPEN_LIBRARY                                                = 1126;
  ER_CANT_FIND_DL_ENTRY                                               = 1127;
  ER_FUNCTION_NOT_DEFINED                                             = 1128;
  ER_HOST_IS_BLOCKED                                                  = 1129;
  ER_HOST_NOT_PRIVILEGED                                              = 1130;
  ER_PASSWORD_ANONYMOUS_USER                                          = 1131;
  ER_PASSWORD_NOT_ALLOWED                                             = 1132;
  ER_PASSWORD_NO_MATCH                                                = 1133;
  ER_UPDATE_INFO                                                      = 1134;
  ER_CANT_CREATE_THREAD                                               = 1135;
  ER_WRONG_VALUE_COUNT_ON_ROW                                         = 1136;
  ER_CANT_REOPEN_TABLE                                                = 1137;
  ER_INVALID_USE_OF_NULL                                              = 1138;
  ER_REGEXP_ERROR                                                     = 1139;
  ER_MIX_OF_GROUP_FUNC_AND_FIELDS                                     = 1140;
  ER_NONEXISTING_GRANT                                                = 1141;
  ER_TABLEACCESS_DENIED_ERROR                                         = 1142;
  ER_COLUMNACCESS_DENIED_ERROR                                        = 1143;
  ER_ILLEGAL_GRANT_FOR_TABLE                                          = 1144;
  ER_GRANT_WRONG_HOST_OR_USER                                         = 1145;
  ER_NO_SUCH_TABLE                                                    = 1146;
  ER_NONEXISTING_TABLE_GRANT                                          = 1147;
  ER_NOT_ALLOWED_COMMAND                                              = 1148;
  ER_SYNTAX_ERROR                                                     = 1149;
  ER_DELAYED_CANT_CHANGE_LOCK                                         = 1150;
  ER_TOO_MANY_DELAYED_THREADS                                         = 1151;
  ER_ABORTING_CONNECTION                                              = 1152;
  ER_NET_PACKET_TOO_LARGE                                             = 1153;
  ER_NET_READ_ERROR_FROM_PIPE                                         = 1154;
  ER_NET_FCNTL_ERROR                                                  = 1155;
  ER_NET_PACKETS_OUT_OF_ORDER                                         = 1156;
  ER_NET_UNCOMPRESS_ERROR                                             = 1157;
  ER_NET_READ_ERROR                                                   = 1158;
  ER_NET_READ_INTERRUPTED                                             = 1159;
  ER_NET_ERROR_ON_WRITE                                               = 1160;
  ER_NET_WRITE_INTERRUPTED                                            = 1161;
  ER_TOO_LONG_STRING                                                  = 1162;
  ER_TABLE_CANT_HANDLE_BLOB                                           = 1163;
  ER_TABLE_CANT_HANDLE_AUTO_INCREMENT                                 = 1164;
  ER_DELAYED_INSERT_TABLE_LOCKED                                      = 1165;
  ER_WRONG_COLUMN_NAME                                                = 1166;
  ER_WRONG_KEY_COLUMN                                                 = 1167;
  ER_WRONG_MRG_TABLE                                                  = 1168;
  ER_DUP_UNIQUE                                                       = 1169;
  ER_BLOB_KEY_WITHOUT_LENGTH                                          = 1170;
  ER_PRIMARY_CANT_HAVE_NULL                                           = 1171;
  ER_TOO_MANY_ROWS                                                    = 1172;
  ER_REQUIRES_PRIMARY_KEY                                             = 1173;
  ER_NO_RAID_COMPILED                                                 = 1174;
  ER_UPDATE_WITHOUT_KEY_IN_SAFE_MODE                                  = 1175;
  ER_KEY_DOES_NOT_EXITS                                               = 1176;
  ER_CHECK_NO_SUCH_TABLE                                              = 1177;
  ER_CHECK_NOT_IMPLEMENTED                                            = 1178;
  ER_CANT_DO_THIS_DURING_AN_TRANSACTION                               = 1179;
  ER_ERROR_DURING_COMMIT                                              = 1180;
  ER_ERROR_DURING_ROLLBACK                                            = 1181;
  ER_ERROR_DURING_FLUSH_LOGS                                          = 1182;
  ER_ERROR_DURING_CHECKPOINT                                          = 1183;
  ER_NEW_ABORTING_CONNECTION                                          = 1184;
  ER_DUMP_NOT_IMPLEMENTED                                             = 1185;
  ER_FLUSH_MASTER_BINLOG_CLOSED                                       = 1186;
  ER_INDEX_REBUILD                                                    = 1187;
  ER_MASTER                                                           = 1188;
  ER_MASTER_NET_READ                                                  = 1189;
  ER_MASTER_NET_WRITE                                                 = 1190;
  ER_FT_MATCHING_KEY_NOT_FOUND                                        = 1191;
  ER_LOCK_OR_ACTIVE_TRANSACTION                                       = 1192;
  ER_UNKNOWN_SYSTEM_VARIABLE                                          = 1193;
  ER_CRASHED_ON_USAGE                                                 = 1194;
  ER_CRASHED_ON_REPAIR                                                = 1195;
  ER_WARNING_NOT_COMPLETE_ROLLBACK                                    = 1196;
  ER_TRANS_CACHE_FULL                                                 = 1197;
  ER_SLAVE_MUST_STOP                                                  = 1198;
  ER_SLAVE_NOT_RUNNING                                                = 1199;
  ER_BAD_SLAVE                                                        = 1200;
  ER_MASTER_INFO                                                      = 1201;
  ER_SLAVE_THREAD                                                     = 1202;
  ER_TOO_MANY_USER_CONNECTIONS                                        = 1203;
  ER_SET_CONSTANTS_ONLY                                               = 1204;
  ER_LOCK_WAIT_TIMEOUT                                                = 1205;
  ER_LOCK_TABLE_FULL                                                  = 1206;
  ER_READ_ONLY_TRANSACTION                                            = 1207;
  ER_DROP_DB_WITH_READ_LOCK                                           = 1208;
  ER_CREATE_DB_WITH_READ_LOCK                                         = 1209;
  ER_WRONG_ARGUMENTS                                                  = 1210;
  ER_NO_PERMISSION_TO_CREATE_USER                                     = 1211;
  ER_UNION_TABLES_IN_DIFFERENT_DIR                                    = 1212;
  ER_LOCK_DEADLOCK                                                    = 1213;
  ER_TABLE_CANT_HANDLE_FT                                             = 1214;
  ER_CANNOT_ADD_FOREIGN                                               = 1215;
  ER_NO_REFERENCED_ROW                                                = 1216;
  ER_ROW_IS_REFERENCED                                                = 1217;
  ER_CONNECT_TO_MASTER                                                = 1218;
  ER_QUERY_ON_MASTER                                                  = 1219;
  ER_ERROR_WHEN_EXECUTING_COMMAND                                     = 1220;
  ER_WRONG_USAGE                                                      = 1221;
  ER_WRONG_NUMBER_OF_COLUMNS_IN_SELECT                                = 1222;
  ER_CANT_UPDATE_WITH_READLOCK                                        = 1223;
  ER_MIXING_NOT_ALLOWED                                               = 1224;
  ER_DUP_ARGUMENT                                                     = 1225;
  ER_USER_LIMIT_REACHED                                               = 1226;
  ER_SPECIFIC_ACCESS_DENIED_ERROR                                     = 1227;
  ER_LOCAL_VARIABLE                                                   = 1228;
  ER_GLOBAL_VARIABLE                                                  = 1229;
  ER_NO_DEFAULT                                                       = 1230;
  ER_WRONG_VALUE_FOR_VAR                                              = 1231;
  ER_WRONG_TYPE_FOR_VAR                                               = 1232;
  ER_VAR_CANT_BE_READ                                                 = 1233;
  ER_CANT_USE_OPTION_HERE                                             = 1234;
  ER_NOT_SUPPORTED_YET                                                = 1235;
  ER_MASTER_FATAL_ERROR_READING_BINLOG                                = 1236;
  ER_SLAVE_IGNORED_TABLE                                              = 1237;
  ER_INCORRECT_GLOBAL_LOCAL_VAR                                       = 1238;
  ER_WRONG_FK_DEF                                                     = 1239;
  ER_KEY_REF_DO_NOT_MATCH_TABLE_REF                                   = 1240;
  ER_OPERAND_COLUMNS                                                  = 1241;
  ER_SUBQUERY_NO_1_ROW                                                = 1242;
  ER_UNKNOWN_STMT_HANDLER                                             = 1243;
  ER_CORRUPT_HELP_DB                                                  = 1244;
  ER_CYCLIC_REFERENCE                                                 = 1245;
  ER_AUTO_CONVERT                                                     = 1246;
  ER_ILLEGAL_REFERENCE                                                = 1247;
  ER_DERIVED_MUST_HAVE_ALIAS                                          = 1248;
  ER_SELECT_REDUCED                                                   = 1249;
  ER_TABLENAME_NOT_ALLOWED_HERE                                       = 1250;
  ER_NOT_SUPPORTED_AUTH_MODE                                          = 1251;
  ER_SPATIAL_CANT_HAVE_NULL                                           = 1252;
  ER_COLLATION_CHARSET_MISMATCH                                       = 1253;
  ER_SLAVE_WAS_RUNNING                                                = 1254;
  ER_SLAVE_WAS_NOT_RUNNING                                            = 1255;
  ER_TOO_BIG_FOR_UNCOMPRESS                                           = 1256;
  ER_ZLIB_Z_MEM_ERROR                                                 = 1257;
  ER_ZLIB_Z_BUF_ERROR                                                 = 1258;
  ER_ZLIB_Z_DATA_ERROR                                                = 1259;
  ER_CUT_VALUE_GROUP_CONCAT                                           = 1260;
  ER_WARN_TOO_FEW_RECORDS                                             = 1261;
  ER_WARN_TOO_MANY_RECORDS                                            = 1262;
  ER_WARN_NULL_TO_NOTNULL                                             = 1263;
  ER_WARN_DATA_OUT_OF_RANGE                                           = 1264;
  EARN_DATA_TRUNCATED                                                 = 1265;
  ER_WARN_USING_OTHER_HANDLER                                         = 1266;
  ER_CANT_AGGREGATE_2COLLATIONS                                       = 1267;
  ER_DROP_USER                                                        = 1268;
  ER_REVOKE_GRANTS                                                    = 1269;
  ER_CANT_AGGREGATE_3COLLATIONS                                       = 1270;
  ER_CANT_AGGREGATE_NCOLLATIONS                                       = 1271;
  ER_VARIABLE_IS_NOT_STRUCT                                           = 1272;
  ER_UNKNOWN_COLLATION                                                = 1273;
  ER_SLAVE_IGNORED_SSL_PARAMS                                         = 1274;
  ER_SERVER_IS_IN_SECURE_AUTH_MODE                                    = 1275;
  ER_WARN_FIELD_RESOLVED                                              = 1276;
  ER_BAD_SLAVE_UNTIL_COND                                             = 1277;
  ER_MISSING_SKIP_SLAVE                                               = 1278;
  ER_UNTIL_COND_IGNORED                                               = 1279;
  ER_WRONG_NAME_FOR_INDEX                                             = 1280;
  ER_WRONG_NAME_FOR_CATALOG                                           = 1281;
  ER_WARN_QC_RESIZE                                                   = 1282;
  ER_BAD_FT_COLUMN                                                    = 1283;
  ER_UNKNOWN_KEY_CACHE                                                = 1284;
  ER_WARN_HOSTNAME_WONT_WORK                                          = 1285;
  ER_UNKNOWN_STORAGE_ENGINE                                           = 1286;
  ER_WARN_DEPRECATED_SYNTAX                                           = 1287;
  ER_NON_UPDATABLE_TABLE                                              = 1288;
  ER_FEATURE_DISABLED                                                 = 1289;
  ER_OPTION_PREVENTS_STATEMENT                                        = 1290;
  ER_DUPLICATED_VALUE_IN_TYPE                                         = 1291;
  ER_TRUNCATED_WRONG_VALUE                                            = 1292;
  ER_TOO_MUCH_AUTO_TIMESTAMP_COLS                                     = 1293;
  ER_INVALID_ON_UPDATE                                                = 1294;
  ER_UNSUPPORTED_PS                                                   = 1295;
  ER_GET_ERRMSG                                                       = 1296;
  ER_GET_TEMPORARY_ERRMSG                                             = 1297;
  ER_UNKNOWN_TIME_ZONE                                                = 1298;
  ER_WARN_INVALID_TIMESTAMP                                           = 1299;
  ER_INVALID_CHARACTER_STRING                                         = 1300;
  ER_WARN_ALLOWED_PACKET_OVERFLOWED                                   = 1301;
  ER_CONFLICTING_DECLARATIONS                                         = 1302;
  ER_SP_NO_RECURSIVE_CREATE                                           = 1303;
  ER_SP_ALREADY_EXISTS                                                = 1304;
  ER_SP_DOES_NOT_EXIST                                                = 1305;
  ER_SP_DROP_FAILED                                                   = 1306;
  ER_SP_STORE_FAILED                                                  = 1307;
  ER_SP_LILABEL_MISMATCH                                              = 1308;
  ER_SP_LABEL_REDEFINE                                                = 1309;
  ER_SP_LABEL_MISMATCH                                                = 1310;
  ER_SP_UNINIT_VAR                                                    = 1311;
  ER_SP_BADSELECT                                                     = 1312;
  ER_SP_BADRETURN                                                     = 1313;
  ER_SP_BADSTATEMENT                                                  = 1314;
  ER_UPDATE_LOG_DEPRECATED_IGNORED                                    = 1315;
  ER_UPDATE_LOG_DEPRECATED_TRANSLATED                                 = 1316;
  ER_QUERY_INTERRUPTED                                                = 1317;
  ER_SP_WRONG_NO_OF_ARGS                                              = 1318;
  ER_SP_COND_MISMATCH                                                 = 1319;
  ER_SP_NORETURN                                                      = 1320;
  ER_SP_NORETURNEND                                                   = 1321;
  ER_SP_BAD_CURSOR_QUERY                                              = 1322;
  ER_SP_BAD_CURSOR_SELECT                                             = 1323;
  ER_SP_CURSOR_MISMATCH                                               = 1324;
  ER_SP_CURSOR_ALREADY_OPEN                                           = 1325;
  ER_SP_CURSOR_NOT_OPEN                                               = 1326;
  ER_SP_UNDECLARED_VAR                                                = 1327;
  ER_SP_WRONG_NO_OF_FETCH_ARGS                                        = 1328;
  ER_SP_FETCH_NO_DATA                                                 = 1329;
  ER_SP_DUP_PARAM                                                     = 1330;
  ER_SP_DUP_VAR                                                       = 1331;
  ER_SP_DUP_COND                                                      = 1332;
  ER_SP_DUP_CURS                                                      = 1333;
  ER_SP_CANT_ALTER                                                    = 1334;
  ER_SP_SUBSELECT_NYI                                                 = 1335;
  ER_SP_NO_USE                                                        = 1336;
  ER_SP_VARCOND_AFTER_CURSHNDLR                                       = 1337;
  ER_SP_CURSOR_AFTER_HANDLER                                          = 1338;
  ER_SP_CASE_NOT_FOUND                                                = 1339;
  ER_FPARSER_TOO_BIG_FILE                                             = 1340;
  ER_FPARSER_BAD_HEADER                                               = 1341;
  ER_FPARSER_EOF_IN_COMMENT                                           = 1342;
  ER_FPARSER_ERROR_IN_PARAMETER                                       = 1343;
  ER_FPARSER_EOF_IN_UNKNOWN_PARAMETER                                 = 1344;
  ER_VIEW_NO_EXPLAIN                                                  = 1345;
  ER_FRM_UNKNOWN_TYPE                                                 = 1346;
  ER_WRONG_OBJECT                                                     = 1347;
  ER_NONUPDATEABLE_COLUMN                                             = 1348;
  ER_VIEW_SELECT_DERIVED                                              = 1349;
  ER_VIEW_SELECT_CLAUSE                                               = 1350;
  ER_VIEW_SELECT_VARIABLE                                             = 1351;
  ER_VIEW_SELECT_TMPTABLE                                             = 1352;
  ER_VIEW_WRONG_LIST                                                  = 1353;
  ER_WARN_VIEW_MERGE                                                  = 1354;
  ER_WARN_VIEW_WITHOUT_KEY                                            = 1355;
  ER_VIEW_INVALID                                                     = 1356;
  ER_SP_NO_DROP_SP                                                    = 1357;
  ER_SP_GOTO_IN_HNDLR                                                 = 1358;
  ER_TRG_ALREADY_EXISTS                                               = 1359;
  ER_TRG_DOES_NOT_EXIST                                               = 1360;
  ER_TRG_ON_VIEW_OR_TEMP_TABLE                                        = 1361;
  ER_TRG_CANT_CHANGE_ROW                                              = 1362;
  ER_TRG_NO_SUCH_ROW_IN_TRG                                           = 1363;
  ER_NO_DEFAULT_FOR_FIELD                                             = 1364;
  ER_DIVISION_BY_ZERO                                                 = 1365;
  ER_TRUNCATED_WRONG_VALUE_FOR_FIELD                                  = 1366;
  ER_ILLEGAL_VALUE_FOR_TYPE                                           = 1367;
  ER_VIEW_NONUPD_CHECK                                                = 1368;
  ER_VIEW_CHECK_FAILED                                                = 1369;
  ER_PROCACCESS_DENIED_ERROR                                          = 1370;
  ER_RELAY_LOG_FAIL                                                   = 1371;
  ER_PASSWD_LENGTH                                                    = 1372;
  ER_UNKNOWN_TARGET_BINLOG                                            = 1373;
  ER_IO_ERR_LOG_INDEX_READ                                            = 1374;
  ER_BINLOG_PURGE_PROHIBITED                                          = 1375;
  ER_FSEEK_FAIL                                                       = 1376;
  ER_BINLOG_PURGE_FATAL_ERR                                           = 1377;
  ER_LOG_IN_USE                                                       = 1378;
  ER_LOG_PURGE_UNKNOWN_ERR                                            = 1379;
  ER_RELAY_LOG_INIT                                                   = 1380;
  ER_NO_BINARY_LOGGING                                                = 1381;
  ER_RESERVED_SYNTAX                                                  = 1382;
  ER_WSAS_FAILED                                                      = 1383;
  ER_DIFF_GROUPS_PROC                                                 = 1384;
  ER_NO_GROUP_FOR_PROC                                                = 1385;
  ER_ORDER_WITH_PROC                                                  = 1386;
  ER_LOGGING_PROHIBIT_CHANGING_OF                                     = 1387;
  ER_NO_FILE_MAPPING                                                  = 1388;
  ER_WRONG_MAGIC                                                      = 1389;
  ER_PS_MANY_PARAM                                                    = 1390;
  ER_KEY_PART_0                                                       = 1391;
  ER_VIEW_CHECKSUM                                                    = 1392;
  ER_VIEW_MULTIUPDATE                                                 = 1393;
  ER_VIEW_NO_INSERT_FIELD_LIST                                        = 1394;
  ER_VIEW_DELETE_MERGE_VIEW                                           = 1395;
  ER_CANNOT_USER                                                      = 1396;
  ER_XAER_NOTA                                                        = 1397;
  ER_XAER_INVAL                                                       = 1398;
  ER_XAER_RMFAIL                                                      = 1399;
  ER_XAER_OUTSIDE                                                     = 1400;
  ER_XAER_RMERR                                                       = 1401;
  ER_XA_RBROLLBACK                                                    = 1402;
  ER_NONEXISTING_PROC_GRANT                                           = 1403;
  ER_PROC_AUTO_GRANT_FAIL                                             = 1404;
  ER_PROC_AUTO_REVOKE_FAIL                                            = 1405;
  ER_DATA_TOO_LONG                                                    = 1406;
  ER_SP_BAD_SQLSTATE                                                  = 1407;
  ER_STARTUP                                                          = 1408;
  ER_LOAD_FROM_FIXED_SIZE_ROWS_TO_VAR                                 = 1409;
  ER_CANT_CREATE_USER_WITH_GRANT                                      = 1410;
  ER_WRONG_VALUE_FOR_TYPE                                             = 1411;
  ER_TABLE_DEF_CHANGED                                                = 1412;
  ER_SP_DUP_HANDLER                                                   = 1413;
  ER_SP_NOT_VAR_ARG                                                   = 1414;
  ER_SP_NO_RETSET_IN_FUNC                                             = 1415;
  ER_CANT_CREATE_GEOMETRY_OBJECT                                      = 1416;
  ER_FAILED_ROUTINE_BREAK_BINLOG                                      = 1417;
  ER_BINLOG_UNSAFE_ROUTINE                                            = 1418;
  ER_BINLOG_CREATE_ROUTINE_NEED_SUPER                                 = 1419;
  ER_EXEC_STMT_WITH_OPEN_CURSOR                                       = 1420;
  ER_STMT_HAS_NO_OPEN_CURSOR                                          = 1421;
  ER_COMMIT_NOT_ALLOWED_IN_SF_OR_TRG                                  = 1422;
  ER_NO_DEFAULT_FOR_VIEW_FIELD                                        = 1423;
  ER_SP_NO_RECURSION                                                  = 1424;
  ER_TOO_BIG_PRECISION                                                = 1426;
  ER_M_BIGGER_THAN_D                                                  = 1427;
  ER_WRONG_LOCK_OF_SYSTEM_TABLE                                       = 1428;
  ER_CONNECT_TO_FOREIGN_DATA_SOURCE                                   = 1429;
  ER_QUERY_ON_FOREIGN_DATA_SOURCE                                     = 1430;
  ER_FOREIGN_DATA_SOURCE_DOESNT_EXIST                                 = 1431;
  ER_FOREIGN_DATA_STRING_INVALID_CANT_CREATE                          = 1432;
  ER_FOREIGN_DATA_STRING_INVALID                                      = 1433;
  ER_CANT_CREATE_FEDERATED_TABLE                                      = 1434;
  ER_TRG_IN_WRONG_SCHEMA                                              = 1435;
  ER_STACK_OVERRUN_NEED_MORE                                          = 1436;
  ER_TOO_LONG_BODY                                                    = 1437;
  ER_WARN_CANT_DROP_DEFAULT_KEYCACHE                                  = 1438;
  ER_TOO_BIG_DISPLAYWIDTH                                             = 1439;
  ER_XAER_DUPID                                                       = 1440;
  ER_DATETIME_FUNCTION_OVERFLOW                                       = 1441;
  ER_CANT_UPDATE_USED_TABLE_IN_SF_OR_TRG                              = 1442;
  ER_VIEW_PREVENT_UPDATE                                              = 1443;
  ER_PS_NO_RECURSION                                                  = 1444;
  ER_SP_CANT_SET_AUTOCOMMIT                                           = 1445;
  ER_MALFORMED_DEFINER                                                = 1446;
  ER_VIEW_FRM_NO_USER                                                 = 1447;
  ER_VIEW_OTHER_USER                                                  = 1448;
  ER_NO_SUCH_USER                                                     = 1449;
  ER_FORBID_SCHEMA_CHANGE                                             = 1450;
  ER_ROW_IS_REFERENCED_2                                              = 1451;
  ER_NO_REFERENCED_ROW_2                                              = 1452;
  ER_SP_BAD_VAR_SHADOW                                                = 1453;
  ER_TRG_NO_DEFINER                                                   = 1454;
  ER_OLD_FILE_FORMAT                                                  = 1455;
  ER_SP_RECURSION_LIMIT                                               = 1456;
  ER_SP_PROC_TABLE_CORRUPT                                            = 1457;
  ER_SP_WRONG_NAME                                                    = 1458;
  ER_TABLE_NEEDS_UPGRADE                                              = 1459;
  ER_SP_NO_AGGREGATE                                                  = 1460;
  ER_MAX_PREPARED_STMT_COUNT_REACHED                                  = 1461;
  ER_VIEW_RECURSIVE                                                   = 1462;
  ER_NON_GROUPING_FIELD_USED                                          = 1463;
  ER_TABLE_CANT_HANDLE_SPKEYS                                         = 1464;
  ER_NO_TRIGGERS_ON_SYSTEM_SCHEMA                                     = 1465;
  ER_REMOVED_SPACES                                                   = 1466;
  ER_AUTOINC_READ_FAILED                                              = 1467;
  ER_USERNAME                                                         = 1468;
  ER_HOSTNAME                                                         = 1469;
  ER_WRONG_STRING_LENGTH                                              = 1470;
  ER_NON_INSERTABLE_TABLE                                             = 1471;
  ER_ADMIN_WRONG_MRG_TABLE                                            = 1472;
  ER_TOO_HIGH_LEVEL_OF_NESTING_FOR_SELECT                             = 1473;
  ER_NAME_BECOMES_EMPTY                                               = 1474;
  ER_AMBIGUOUS_FIELD_TERM                                             = 1475;
  ER_FOREIGN_SERVER_EXISTS                                            = 1476;
  ER_FOREIGN_SERVER_DOESNT_EXIST                                      = 1477;
  ER_ILLEGAL_HA_CREATE_OPTION                                         = 1478;
  ER_PARTITION_REQUIRES_VALUES_ERROR                                  = 1479;
  ER_PARTITION_WRONG_VALUES_ERROR                                     = 1480;
  ER_PARTITION_MAXVALUE_ERROR                                         = 1481;
  ER_PARTITION_SUBPARTITION_ERROR                                     = 1482;
  ER_PARTITION_SUBPART_MIX_ERROR                                      = 1483;
  ER_PARTITION_WRONG_NO_PART_ERROR                                    = 1484;
  ER_PARTITION_WRONG_NO_SUBPART_ERROR                                 = 1485;
  ER_CONST_EXPR_IN_PARTITION_FUNC_ERROR                               = 1486;
  ER_NO_CONST_EXPR_IN_RANGE_OR_LIST_ERROR                             = 1487;
  ER_FIELD_NOT_FOUND_PART_ERROR                                       = 1488;
  ER_LIST_OF_FIELDS_ONLY_IN_HASH_ERROR                                = 1489;
  ER_INCONSISTENT_PARTITION_INFO_ERROR                                = 1490;
  ER_PARTITION_FUNC_NOT_ALLOWED_ERROR                                 = 1491;
  ER_PARTITIONS_MUST_BE_DEFINED_ERROR                                 = 1492;
  ER_RANGE_NOT_INCREASING_ERROR                                       = 1493;
  ER_INCONSISTENT_TYPE_OF_FUNCTIONS_ERROR                             = 1494;
  ER_MULTIPLE_DEF_CONST_IN_LIST_PART_ERROR                            = 1495;
  ER_PARTITION_ENTRY_ERROR                                            = 1496;
  ER_MIX_HANDLER_ERROR                                                = 1497;
  ER_PARTITION_NOT_DEFINED_ERROR                                      = 1498;
  ER_TOO_MANY_PARTITIONS_ERROR                                        = 1499;
  ER_SUBPARTITION_ERROR                                               = 1500;
  ER_CANT_CREATE_HANDLER_FILE                                         = 1501;
  ER_BLOB_FIELD_IN_PART_FUNC_ERROR                                    = 1502;
  ER_UNIQUE_KEY_NEED_ALL_FIELDS_IN_PF                                 = 1503;
  ER_NO_PARTS_ERROR                                                   = 1504;
  ER_PARTITION_MGMT_ON_NONPARTITIONED                                 = 1505;
  ER_FOREIGN_KEY_ON_PARTITIONED                                       = 1506;
  ER_DROP_PARTITION_NON_EXISTENT                                      = 1507;
  ER_DROP_LAST_PARTITION                                              = 1508;
  ER_COALESCE_ONLY_ON_HASH_PARTITION                                  = 1509;
  ER_REORG_HASH_ONLY_ON_SAME_NO                                       = 1510;
  ER_REORG_NO_PARAM_ERROR                                             = 1511;
  ER_ONLY_ON_RANGE_LIST_PARTITION                                     = 1512;
  ER_ADD_PARTITION_SUBPART_ERROR                                      = 1513;
  ER_ADD_PARTITION_NO_NEW_PARTITION                                   = 1514;
  ER_COALESCE_PARTITION_NO_PARTITION                                  = 1515;
  ER_REORG_PARTITION_NOT_EXIST                                        = 1516;
  ER_SAME_NAME_PARTITION                                              = 1517;
  ER_NO_BINLOG_ERROR                                                  = 1518;
  ER_CONSECUTIVE_REORG_PARTITIONS                                     = 1519;
  ER_REORG_OUTSIDE_RANGE                                              = 1520;
  ER_PARTITION_FUNCTION_FAILURE                                       = 1521;
  ER_PART_STATE_ERROR                                                 = 1522;
  ER_LIMITED_PART_RANGE                                               = 1523;
  ER_PLUGIN_IS_NOT_LOADED                                             = 1524;
  ER_WRONG_VALUE                                                      = 1525;
  ER_NO_PARTITION_FOR_GIVEN_VALUE                                     = 1526;
  ER_FILEGROUP_OPTION_ONLY_ONCE                                       = 1527;
  ER_CREATE_FILEGROUP_FAILED                                          = 1528;
  ER_DROP_FILEGROUP_FAILED                                            = 1529;
  ER_TABLESPACE_AUTO_EXTEND_ERROR                                     = 1530;
  ER_WRONG_SIZE_NUMBER                                                = 1531;
  ER_SIZE_OVERFLOW_ERROR                                              = 1532;
  ER_ALTER_FILEGROUP_FAILED                                           = 1533;
  ER_BINLOG_ROW_LOGGING_FAILED                                        = 1534;
  ER_BINLOG_ROW_WRONG_TABLE_DEF                                       = 1535;
  ER_BINLOG_ROW_RBR_TO_SBR                                            = 1536;
  ER_EVENT_ALREADY_EXISTS                                             = 1537;
  ER_EVENT_STORE_FAILED                                               = 1538;
  ER_EVENT_DOES_NOT_EXIST                                             = 1539;
  ER_EVENT_CANT_ALTER                                                 = 1540;
  ER_EVENT_DROP_FAILED                                                = 1541;
  ER_EVENT_INTERVAL_NOT_POSITIVE_OR_TOO_BIG                           = 1542;
  ER_EVENT_ENDS_BEFORE_STARTS                                         = 1543;
  ER_EVENT_EXEC_TIME_IN_THE_PAST                                      = 1544;
  ER_EVENT_OPEN_TABLE_FAILED                                          = 1545;
  ER_EVENT_NEITHER_M_EXPR_NOR_M_AT                                    = 1546;
  ER_COL_COUNT_DOESNT_MATCH_CORRUPTED                                 = 1547;
  ER_CANNOT_LOAD_FROM_TABLE                                           = 1548;
  ER_EVENT_CANNOT_DELETE                                              = 1549;
  ER_EVENT_COMPILE_ERROR                                              = 1550;
  ER_EVENT_SAME_NAME                                                  = 1551;
  ER_EVENT_DATA_TOO_LONG                                              = 1552;
  ER_DROP_INDEX_FK                                                    = 1553;
  ER_WARN_DEPRECATED_SYNTAX_WITH_VER                                  = 1554;
  ER_CANT_WRITE_LOCK_LOG_TABLE                                        = 1555;
  ER_CANT_LOCK_LOG_TABLE                                              = 1556;
  ER_FOREIGN_DUPLICATE_KEY                                            = 1557;
  ER_COL_COUNT_DOESNT_MATCH_PLEASE_UPDATE                             = 1558;
  ER_TEMP_TABLE_PREVENTS_SWITCH_OUT_OF_RBR                            = 1559;
  ER_STORED_FUNCTION_PREVENTS_SWITCH_BINLOG_FORMAT                    = 1560;
  ER_NDB_CANT_SWITCH_BINLOG_FORMAT                                    = 1561;
  ER_PARTITION_NO_TEMPORARY                                           = 1562;
  ER_PARTITION_CONST_DOMAIN_ERROR                                     = 1563;
  ER_PARTITION_FUNCTION_IS_NOT_ALLOWED                                = 1564;
  ER_DDL_LOG_ERROR                                                    = 1565;
  ER_NULL_IN_VALUES_LESS_THAN                                         = 1566;
  ER_WRONG_PARTITION_NAME                                             = 1567;
  ER_CANT_CHANGE_TX_ISOLATION                                         = 1568;
  ER_DUP_ENTRY_AUTOINCREMENT_CASE                                     = 1569;
  ER_EVENT_MODIFY_QUEUE_ERROR                                         = 1570;
  ER_EVENT_SET_VAR_ERROR                                              = 1571;
  ER_PARTITION_MERGE_ERROR                                            = 1572;
  ER_CANT_ACTIVATE_LOG                                                = 1573;
  ER_RBR_NOT_AVAILABLE                                                = 1574;
  ER_BASE64_DECODE_ERROR                                              = 1575;
  ER_EVENT_RECURSION_FORBIDDEN                                        = 1576;
  ER_EVENTS_DB_ERROR                                                  = 1577;
  ER_ONLY_INTEGERS_ALLOWED                                            = 1578;
  ER_UNSUPORTED_LOG_ENGINE                                            = 1579;
  ER_BAD_LOG_STATEMENT                                                = 1580;
  ER_CANT_RENAME_LOG_TABLE                                            = 1581;
  ER_WRONG_PARAMCOUNT_TO_NATIVE_FCT                                   = 1582;
  ER_WRONG_PARAMETERS_TO_NATIVE_FCT                                   = 1583;
  ER_WRONG_PARAMETERS_TO_STORED_FCT                                   = 1584;
  ER_NATIVE_FCT_NAME_COLLISION                                        = 1585;
  ER_DUP_ENTRY_WITH_KEY_NAME                                          = 1586;
  ER_BINLOG_PURGE_EMFILE                                              = 1587;
  ER_EVENT_CANNOT_CREATE_IN_THE_PAST                                  = 1588;
  ER_EVENT_CANNOT_ALTER_IN_THE_PAST                                   = 1589;
  ER_SLAVE_INCIDENT                                                   = 1590;
  ER_NO_PARTITION_FOR_GIVEN_VALUE_SILENT                              = 1591;
  ER_BINLOG_UNSAFE_STATEMENT                                          = 1592;
  ER_SLAVE_FATAL_ERROR                                                = 1593;
  ER_SLAVE_RELAY_LOG_READ_FAILURE                                     = 1594;
  ER_SLAVE_RELAY_LOG_WRITE_FAILURE                                    = 1595;
  ER_SLAVE_CREATE_EVENT_FAILURE                                       = 1596;
  ER_SLAVE_MASTER_COM_FAILURE                                         = 1597;
  ER_BINLOG_LOGGING_IMPOSSIBLE                                        = 1598;
  ER_VIEW_NO_CREATION_CTX                                             = 1599;
  ER_VIEW_INVALID_CREATION_CTX                                        = 1600;
  ER_SR_INVALID_CREATION_CTX                                          = 1601;
  ER_TRG_CORRUPTED_FILE                                               = 1602;
  ER_TRG_NO_CREATION_CTX                                              = 1603;
  ER_TRG_INVALID_CREATION_CTX                                         = 1604;
  ER_EVENT_INVALID_CREATION_CTX                                       = 1605;
  ER_TRG_CANT_OPEN_TABLE                                              = 1606;
  ER_CANT_CREATE_SROUTINE                                             = 1607;
  ER_SLAVE_AMBIGOUS_EXEC_MODE                                         = 1608;
  ER_NO_FORMAT_DESCRIPTION_EVENT_BEFORE_BINLOG_STATEMENT              = 1609;
  ER_SLAVE_CORRUPT_EVENT                                              = 1610;
  ER_LOAD_DATA_INVALID_COLUMN                                         = 1611;
  ER_LOG_PURGE_NO_FILE                                                = 1612;
  ER_XA_RBTIMEOUT                                                     = 1613;
  ER_XA_RBDEADLOCK                                                    = 1614;
  ER_NEED_REPREPARE                                                   = 1615;
  ER_DELAYED_NOT_SUPPORTED                                            = 1616;
  WARN_NO_MASTER_INFO                                                 = 1617;
  WARN_OPTION_IGNORED                                                 = 1618;
  WARN_PLUGIN_DELETE_BUILTIN                                          = 1619;
  WARN_PLUGIN_BUSY                                                    = 1620;
  ER_VARIABLE_IS_READONLY                                             = 1621;
  ER_WARN_ENGINE_TRANSACTION_ROLLBACK                                 = 1622;
  ER_SLAVE_HEARTBEAT_FAILURE                                          = 1623;
  ER_SLAVE_HEARTBEAT_VALUE_OUT_OF_RANGE                               = 1624;
  ER_NDB_REPLICATION_SCHEMA_ERROR                                     = 1625;
  ER_CONFLICT_FN_PARSE_ERROR                                          = 1626;
  ER_EXCEPTIONS_WRITE_ERROR                                           = 1627;
  ER_TOO_LONG_TABLE_COMMENT                                           = 1628;
  ER_TOO_LONG_FIELD_COMMENT                                           = 1629;
  ER_FUNC_INEXISTENT_NAME_COLLISION                                   = 1630;
  ER_DATABASE_NAME                                                    = 1631;
  ER_TABLE_NAME                                                       = 1632;
  ER_PARTITION_NAME                                                   = 1633;
  ER_SUBPARTITION_NAME                                                = 1634;
  ER_TEMPORARY_NAME                                                   = 1635;
  ER_RENAMED_NAME                                                     = 1636;
  ER_TOO_MANY_CONCURRENT_TRXS                                         = 1637;
  WARN_NON_ASCII_SEPARATOR_NOT_IMPLEMENTED                            = 1638;
  ER_DEBUG_SYNC_TIMEOUT                                               = 1639;
  ER_DEBUG_SYNC_HIT_LIMIT                                             = 1640;
  ER_DUP_SIGNAL_SET                                                   = 1641;
  ER_SIGNAL_WARN                                                      = 1642;
  ER_SIGNAL_NOT_FOUND                                                 = 1643;
  ER_SIGNAL_EXCEPTION                                                 = 1644;
  ER_RESIGNAL_WITHOUT_ACTIVE_HANDLER                                  = 1645;
  ER_SIGNAL_BAD_CONDITION_TYPE                                        = 1646;
  WARN_COND_ITEM_TRUNCATED                                            = 1647;
  ER_COND_ITEM_TOO_LONG                                               = 1648;
  ER_UNKNOWN_LOCALE                                                   = 1649;
  ER_SLAVE_IGNORE_SERVER_IDS                                          = 1650;
  ER_QUERY_CACHE_DISABLED                                             = 1651;
  ER_SAME_NAME_PARTITION_FIELD                                        = 1652;
  ER_PARTITION_COLUMN_LIST_ERROR                                      = 1653;
  ER_WRONG_TYPE_COLUMN_VALUE_ERROR                                    = 1654;
  ER_TOO_MANY_PARTITION_FUNC_FIELDS_ERROR                             = 1655;
  ER_MAXVALUE_IN_VALUES_IN                                            = 1656;
  ER_TOO_MANY_VALUES_ERROR                                            = 1657;
  ER_ROW_SINGLE_PARTITION_FIELD_ERROR                                 = 1658;
  ER_FIELD_TYPE_NOT_ALLOWED_AS_PARTITION_FIELD                        = 1659;
  ER_PARTITION_FIELDS_TOO_LONG                                        = 1660;
  ER_BINLOG_ROW_ENGINE_AND_STMT_ENGINE                                = 1661;
  ER_BINLOG_ROW_MODE_AND_STMT_ENGINE                                  = 1662;
  ER_BINLOG_UNSAFE_AND_STMT_ENGINE                                    = 1663;
  ER_BINLOG_ROW_INJECTION_AND_STMT_ENGINE                             = 1664;
  ER_BINLOG_STMT_MODE_AND_ROW_ENGINE                                  = 1665;
  ER_BINLOG_ROW_INJECTION_AND_STMT_MODE                               = 1666;
  ER_BINLOG_MULTIPLE_ENGINES_AND_SELF_LOGGING_ENGINE                  = 1667;
  ER_BINLOG_UNSAFE_LIMIT                                              = 1668;
  ER_UNUSED4                                                          = 1669;
  ER_BINLOG_UNSAFE_SYSTEM_TABLE                                       = 1670;
  ER_BINLOG_UNSAFE_AUTOINC_COLUMNS                                    = 1671;
  ER_BINLOG_UNSAFE_UDF                                                = 1672;
  ER_BINLOG_UNSAFE_SYSTEM_VARIABLE                                    = 1673;
  ER_BINLOG_UNSAFE_SYSTEM_FUNCTION                                    = 1674;
  ER_BINLOG_UNSAFE_NONTRANS_AFTER_TRANS                               = 1675;
  ER_MESSAGE_AND_STATEMENT                                            = 1676;
  ER_SLAVE_CONVERSION_FAILED                                          = 1677;
  ER_SLAVE_CANT_CREATE_CONVERSION                                     = 1678;
  ER_INSIDE_TRANSACTION_PREVENTS_SWITCH_BINLOG_FORMAT                 = 1679;
  ER_PATH_LENGTH                                                      = 1680;
  ER_WARN_DEPRECATED_SYNTAX_NO_REPLACEMENT                            = 1681;
  ER_WRONG_NATIVE_TABLE_STRUCTURE                                     = 1682;
  ER_WRONG_PERFSCHEMA_USAGE                                           = 1683;
  ER_WARN_I_S_SKIPPED_TABLE                                           = 1684;
  ER_INSIDE_TRANSACTION_PREVENTS_SWITCH_BINLOG_DIRECT                 = 1685;
  ER_STORED_FUNCTION_PREVENTS_SWITCH_BINLOG_DIRECT                    = 1686;
  ER_SPATIAL_MUST_HAVE_GEOM_COL                                       = 1687;
  ER_TOO_LONG_INDEX_COMMENT                                           = 1688;
  ER_LOCK_ABORTED                                                     = 1689;
  ER_DATA_OUT_OF_RANGE                                                = 1690;
  ER_WRONG_SPVAR_TYPE_IN_LIMIT                                        = 1691;
  ER_BINLOG_UNSAFE_MULTIPLE_ENGINES_AND_SELF_LOGGING_ENGINE           = 1692;
  ER_BINLOG_UNSAFE_MIXED_STATEMENT                                    = 1693;
  ER_INSIDE_TRANSACTION_PREVENTS_SWITCH_SQL_LOG_BIN                   = 1694;
  ER_STORED_FUNCTION_PREVENTS_SWITCH_SQL_LOG_BIN                      = 1695;
  ER_FAILED_READ_FROM_PAR_FILE                                        = 1696;
  ER_VALUES_IS_NOT_INT_TYPE_ERROR                                     = 1697;
  ER_ACCESS_DENIED_NO_PASSWORD_ERROR                                  = 1698;
  ER_SET_PASSWORD_AUTH_PLUGIN                                         = 1699;
  ER_GRANT_PLUGIN_USER_EXISTS                                         = 1700;
  ER_TRUNCATE_ILLEGAL_FK                                              = 1701;
  ER_PLUGIN_IS_PERMANENT                                              = 1702;
  ER_SLAVE_HEARTBEAT_VALUE_OUT_OF_RANGE_MIN                           = 1703;
  ER_SLAVE_HEARTBEAT_VALUE_OUT_OF_RANGE_MAX                           = 1704;
  ER_STMT_CACHE_FULL                                                  = 1705;
  ER_MULTI_UPDATE_KEY_CONFLICT                                        = 1706;
  ER_TABLE_NEEDS_REBUILD                                              = 1707;
  WARN_OPTION_BELOW_LIMIT                                             = 1708;
  ER_INDEX_COLUMN_TOO_LONG                                            = 1709;
  ER_ERROR_IN_TRIGGER_BODY                                            = 1710;
  ER_ERROR_IN_UNKNOWN_TRIGGER_BODY                                    = 1711;
  ER_INDEX_CORRUPT                                                    = 1712;
  ER_UNDO_RECORD_TOO_BIG                                              = 1713;
  ER_BINLOG_UNSAFE_INSERT_IGNORE_SELECT                               = 1714;
  ER_BINLOG_UNSAFE_INSERT_SELECT_UPDATE                               = 1715;
  ER_BINLOG_UNSAFE_REPLACE_SELECT                                     = 1716;
  ER_BINLOG_UNSAFE_CREATE_IGNORE_SELECT                               = 1717;
  ER_BINLOG_UNSAFE_CREATE_REPLACE_SELECT                              = 1718;
  ER_BINLOG_UNSAFE_UPDATE_IGNORE                                      = 1719;
  ER_PLUGIN_NO_UNINSTALL                                              = 1720;
  ER_PLUGIN_NO_INSTALL                                                = 1721;
  ER_BINLOG_UNSAFE_WRITE_AUTOINC_SELECT                               = 1722;
  ER_BINLOG_UNSAFE_CREATE_SELECT_AUTOINC                              = 1723;
  ER_BINLOG_UNSAFE_INSERT_TWO_KEYS                                    = 1724;
  ER_TABLE_IN_FK_CHECK                                                = 1725;
  ER_UNSUPPORTED_ENGINE                                               = 1726;
  ER_BINLOG_UNSAFE_AUTOINC_NOT_FIRST                                  = 1727;
  ER_CANNOT_LOAD_FROM_TABLE_V2                                        = 1728;
  ER_MASTER_DELAY_VALUE_OUT_OF_RANGE                                  = 1729;
  ER_ONLY_FD_AND_RBR_EVENTS_ALLOWED_IN_BINLOG_STATEMENT               = 1730;
  ER_PARTITION_EXCHANGE_DIFFERENT_OPTION                              = 1731;
  ER_PARTITION_EXCHANGE_PART_TABLE                                    = 1732;
  ER_PARTITION_EXCHANGE_TEMP_TABLE                                    = 1733;
  ER_PARTITION_INSTEAD_OF_SUBPARTITION                                = 1734;
  ER_UNKNOWN_PARTITION                                                = 1735;
  ER_TABLES_DIFFERENT_METADATA                                        = 1736;
  ER_ROW_DOES_NOT_MATCH_PARTITION                                     = 1737;
  ER_BINLOG_CACHE_SIZE_GREATER_THAN_MAX                               = 1738;
  ER_WARN_INDEX_NOT_APPLICABLE                                        = 1739;
  ER_PARTITION_EXCHANGE_FOREIGN_KEY                                   = 1740;
  ER_NO_SUCH_KEY_VALUE                                                = 1741;
  ER_RPL_INFO_DATA_TOO_LONG                                           = 1742;
  ER_NETWORK_READ_EVENT_CHECKSUM_FAILURE                              = 1743;
  ER_BINLOG_READ_EVENT_CHECKSUM_FAILURE                               = 1744;
  ER_BINLOG_STMT_CACHE_SIZE_GREATER_THAN_MAX                          = 1745;
  ER_CANT_UPDATE_TABLE_IN_CREATE_TABLE_SELECT                         = 1746;
  ER_PARTITION_CLAUSE_ON_NONPARTITIONED                               = 1747;
  ER_ROW_DOES_NOT_MATCH_GIVEN_PARTITION_SET                           = 1748;
  ER_NO_SUCH_PARTITION__UNUSED                                        = 1749;
  ER_CHANGE_RPL_INFO_REPOSITORY_FAILURE                               = 1750;
  ER_WARNING_NOT_COMPLETE_ROLLBACK_WITH_CREATED_TEMP_TABLE            = 1751;
  ER_WARNING_NOT_COMPLETE_ROLLBACK_WITH_DROPPED_TEMP_TABLE            = 1752;
  ER_MTS_FEATURE_IS_NOT_SUPPORTED                                     = 1753;
  ER_MTS_UPDATED_DBS_GREATER_MAX                                      = 1754;
  ER_MTS_CANT_PARALLEL                                                = 1755;
  ER_MTS_INCONSISTENT_DATA                                            = 1756;
  ER_FULLTEXT_NOT_SUPPORTED_WITH_PARTITIONING                         = 1757;
  ER_DA_INVALID_CONDITION_NUMBER                                      = 1758;
  ER_INSECURE_PLAIN_TEXT                                              = 1759;
  ER_INSECURE_CHANGE_MASTER                                           = 1760;
  ER_FOREIGN_DUPLICATE_KEY_WITH_CHILD_INFO                            = 1761;
  ER_FOREIGN_DUPLICATE_KEY_WITHOUT_CHILD_INFO                         = 1762;
  ER_SQLTHREAD_WITH_SECURE_SLAVE                                      = 1763;
  ER_TABLE_HAS_NO_FT                                                  = 1764;
  ER_VARIABLE_NOT_SETTABLE_IN_SF_OR_TRIGGER                           = 1765;
  ER_VARIABLE_NOT_SETTABLE_IN_TRANSACTION                             = 1766;
  ER_GTID_NEXT_IS_NOT_IN_GTID_NEXT_LIST                               = 1767;
  ER_CANT_CHANGE_GTID_NEXT_IN_TRANSACTION_WHEN_GTID_NEXT_LIST_IS_NULL = 1768;
  ER_SET_STATEMENT_CANNOT_INVOKE_FUNCTION                             = 1769;
  ER_GTID_NEXT_CANT_BE_AUTOMATIC_IF_GTID_NEXT_LIST_IS_NON_NULL        = 1770;
  ER_SKIPPING_LOGGED_TRANSACTION                                      = 1771;
  ER_MALFORMED_GTID_SET_SPECIFICATION                                 = 1772;
  ER_MALFORMED_GTID_SET_ENCODING                                      = 1773;
  ER_MALFORMED_GTID_SPECIFICATION                                     = 1774;
  ER_GNO_EXHAUSTED                                                    = 1775;
  ER_BAD_SLAVE_AUTO_POSITION                                          = 1776;
  ER_AUTO_POSITION_REQUIRES_GTID_MODE_ON                              = 1777;
  ER_CANT_DO_IMPLICIT_COMMIT_IN_TRX_WHEN_GTID_NEXT_IS_SET             = 1778;
  ER_GTID_MODE_2_OR_3_REQUIRES_ENFORCE_GTID_CONSISTENCY_ON            = 1779;
  ER_GTID_MODE_REQUIRES_BINLOG                                        = 1780;
  ER_CANT_SET_GTID_NEXT_TO_GTID_WHEN_GTID_MODE_IS_OFF                 = 1781;
  ER_CANT_SET_GTID_NEXT_TO_ANONYMOUS_WHEN_GTID_MODE_IS_ON             = 1782;
  ER_CANT_SET_GTID_NEXT_LIST_TO_NON_NULL_WHEN_GTID_MODE_IS_OFF        = 1783;
  ER_FOUND_GTID_EVENT_WHEN_GTID_MODE_IS_OFF                           = 1784;
  ER_GTID_UNSAFE_NON_TRANSACTIONAL_TABLE                              = 1785;
  ER_GTID_UNSAFE_CREATE_SELECT                                        = 1786;
  ER_GTID_UNSAFE_CREATE_DROP_TEMPORARY_TABLE_IN_TRANSACTION           = 1787;
  ER_GTID_MODE_CAN_ONLY_CHANGE_ONE_STEP_AT_A_TIME                     = 1788;
  ER_MASTER_HAS_PURGED_REQUIRED_GTIDS                                 = 1789;
  ER_CANT_SET_GTID_NEXT_WHEN_OWNING_GTID                              = 1790;
  ER_UNKNOWN_EXPLAIN_FORMAT                                           = 1791;
  ER_CANT_EXECUTE_IN_READ_ONLY_TRANSACTION                            = 1792;
  ER_TOO_LONG_TABLE_PARTITION_COMMENT                                 = 1793;
  ER_SLAVE_CONFIGURATION                                              = 1794;
  ER_INNODB_FT_LIMIT                                                  = 1795;
  ER_INNODB_NO_FT_TEMP_TABLE                                          = 1796;
  ER_INNODB_FT_WRONG_DOCID_COLUMN                                     = 1797;
  ER_INNODB_FT_WRONG_DOCID_INDEX                                      = 1798;
  ER_INNODB_ONLINE_LOG_TOO_BIG                                        = 1799;
  ER_UNKNOWN_ALTER_ALGORITHM                                          = 1800;
  ER_UNKNOWN_ALTER_LOCK                                               = 1801;
  ER_MTS_CHANGE_MASTER_CANT_RUN_WITH_GAPS                             = 1802;
  ER_MTS_RECOVERY_FAILURE                                             = 1803;
  ER_MTS_RESET_WORKERS                                                = 1804;
  ER_COL_COUNT_DOESNT_MATCH_CORRUPTED_V2                              = 1805;
  ER_SLAVE_SILENT_RETRY_TRANSACTION                                   = 1806;
  ER_DISCARD_FK_CHECKS_RUNNING                                        = 1807;
  ER_TABLE_SCHEMA_MISMATCH                                            = 1808;
  ER_TABLE_IN_SYSTEM_TABLESPACE                                       = 1809;
  ER_IO_READ_ERROR                                                    = 1810;
  ER_IO_WRITE_ERROR                                                   = 1811;
  ER_TABLESPACE_MISSING                                               = 1812;
  ER_TABLESPACE_EXISTS                                                = 1813;
  ER_TABLESPACE_DISCARDED                                             = 1814;
  ER_INTERNAL_ERROR                                                   = 1815;
  ER_INNODB_IMPORT_ERROR                                              = 1816;
  ER_INNODB_INDEX_CORRUPT                                             = 1817;
  ER_INVALID_YEAR_COLUMN_LENGTH                                       = 1818;
  ER_NOT_VALID_PASSWORD                                               = 1819;
  ER_MUST_CHANGE_PASSWORD                                             = 1820;
  ER_FK_NO_INDEX_CHILD                                                = 1821;
  ER_FK_NO_INDEX_PARENT                                               = 1822;
  ER_FK_FAIL_ADD_SYSTEM                                               = 1823;
  ER_FK_CANNOT_OPEN_PARENT                                            = 1824;
  ER_FK_INCORRECT_OPTION                                              = 1825;
  ER_FK_DUP_NAME                                                      = 1826;
  ER_PASSWORD_FORMAT                                                  = 1827;
  ER_FK_COLUMN_CANNOT_DROP                                            = 1828;
  ER_FK_COLUMN_CANNOT_DROP_CHILD                                      = 1829;
  ER_FK_COLUMN_NOT_NULL                                               = 1830;
  ER_DUP_INDEX                                                        = 1831;
  ER_FK_COLUMN_CANNOT_CHANGE                                          = 1832;
  ER_FK_COLUMN_CANNOT_CHANGE_CHILD                                    = 1833;
  ER_UNUSED5                                                          = 1834;
  ER_MALFORMED_PACKET                                                 = 1835;
  ER_READ_ONLY_MODE                                                   = 1836;
  ER_GTID_NEXT_TYPE_UNDEFINED_GROUP                                   = 1837;
  ER_VARIABLE_NOT_SETTABLE_IN_SP                                      = 1838;
  ER_CANT_SET_GTID_PURGED_WHEN_GTID_MODE_IS_OFF                       = 1839;
  ER_CANT_SET_GTID_PURGED_WHEN_GTID_EXECUTED_IS_NOT_EMPTY             = 1840;
  ER_CANT_SET_GTID_PURGED_WHEN_OWNED_GTIDS_IS_NOT_EMPTY               = 1841;
  ER_GTID_PURGED_WAS_CHANGED                                          = 1842;
  ER_GTID_EXECUTED_WAS_CHANGED                                        = 1843;
  ER_BINLOG_STMT_MODE_AND_NO_REPL_TABLES                              = 1844;
  ER_ALTER_OPERATION_NOT_SUPPORTED                                    = 1845;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON                             = 1846;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON_COPY                        = 1847;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON_PARTITION                   = 1848;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON_FK_RENAME                   = 1849;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON_COLUMN_TYPE                 = 1850;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON_FK_CHECK                    = 1851;
  ER_UNUSED6                                                          = 1852;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON_NOPK                        = 1853;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON_AUTOINC                     = 1854;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON_HIDDEN_FTS                  = 1855;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON_CHANGE_FTS                  = 1856;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON_FTS                         = 1857;
  ER_SQL_SLAVE_SKIP_COUNTER_NOT_SETTABLE_IN_GTID_MODE                 = 1858;
  ER_DUP_UNKNOWN_IN_INDEX                                             = 1859;
  ER_IDENT_CAUSES_TOO_LONG_PATH                                       = 1860;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON_NOT_NULL                    = 1861;
  ER_MUST_CHANGE_PASSWORD_LOGIN                                       = 1862;
  ER_ROW_IN_WRONG_PARTITION                                           = 1863;
  ER_MTS_EVENT_BIGGER_PENDING_JOBS_SIZE_MAX                           = 1864;
  ER_INNODB_NO_FT_USES_PARSER                                         = 1865;
  ER_BINLOG_LOGICAL_CORRUPTION                                        = 1866;
  ER_WARN_PURGE_LOG_IN_USE                                            = 1867;
  ER_WARN_PURGE_LOG_IS_ACTIVE                                         = 1868;
  ER_AUTO_INCREMENT_CONFLICT                                          = 1869;
  WARN_ON_BLOCKHOLE_IN_RBR                                            = 1870;
  ER_SLAVE_MI_INIT_REPOSITORY                                         = 1871;
  ER_SLAVE_RLI_INIT_REPOSITORY                                        = 1872;
  ER_ACCESS_DENIED_CHANGE_USER_ERROR                                  = 1873;
  ER_INNODB_READ_ONLY                                                 = 1874;
  ER_STOP_SLAVE_SQL_THREAD_TIMEOUT                                    = 1875;
  ER_STOP_SLAVE_IO_THREAD_TIMEOUT                                     = 1876;
  ER_TABLE_CORRUPT                                                    = 1877;
  ER_TEMP_FILE_WRITE_FAILURE                                          = 1878;
  ER_INNODB_FT_AUX_NOT_HEX_ID                                         = 1879;
  ER_OLD_TEMPORALS_UPGRADED                                           = 1880;
  ER_INNODB_FORCED_RECOVERY                                           = 1881;
  ER_AES_INVALID_IV                                                   = 1882;
  ER_PLUGIN_CANNOT_BE_UNINSTALLED                                     = 1883;
  ER_GTID_UNSAFE_BINLOG_SPLITTABLE_STATEMENT_AND_GTID_GROUP           = 1884;
  ER_FILE_CORRUPT                                                     = 1885;
  ER_ERROR_ON_MASTER                                                  = 1886;
  ER_INCONSISTENT_ERROR                                               = 1887;
  ER_STORAGE_ENGINE_NOT_LOADED                                        = 1888;
  ER_GET_STACKED_DA_WITHOUT_ACTIVE_HANDLER                            = 1889;
  ER_WARN_LEGACY_SYNTAX_CONVERTED                                     = 1890;
  ER_BINLOG_UNSAFE_FULLTEXT_PLUGIN                                    = 1891;
  ER_CANNOT_DISCARD_TEMPORARY_TABLE                                   = 1892;
  ER_FK_DEPTH_EXCEEDED                                                = 1893;
  ER_COL_COUNT_DOESNT_MATCH_PLEASE_UPDATE_V2                          = 1894;
  ER_WARN_TRIGGER_DOESNT_HAVE_CREATED                                 = 1895;
  ER_REFERENCED_TRG_DOES_NOT_EXIST                                    = 1896;
  ER_EXPLAIN_NOT_SUPPORTED                                            = 1897;
  ER_INVALID_FIELD_SIZE                                               = 1898;
  ER_MISSING_HA_CREATE_OPTION                                         = 1899;
  ER_ENGINE_OUT_OF_MEMORY                                             = 1900;
  ER_PASSWORD_EXPIRE_ANONYMOUS_USER                                   = 1901;
  ER_SLAVE_SQL_THREAD_MUST_STOP                                       = 1902;
  ER_NO_FT_MATERIALIZED_SUBQUERY                                      = 1903;
  ER_INNODB_UNDO_LOG_FULL                                             = 1904;
  ER_INVALID_ARGUMENT_FOR_LOGARITHM                                   = 1905;
  ER_SLAVE_IO_THREAD_MUST_STOP                                        = 1906;
  ER_WARN_OPEN_TEMP_TABLES_MUST_BE_ZERO                               = 1907;
  ER_WARN_ONLY_MASTER_LOG_FILE_NO_POS                                 = 1908;
  ER_QUERY_TIMEOUT                                                    = 1909;
  ER_NON_RO_SELECT_DISABLE_TIMER                                      = 1910;
  ER_DUP_LIST_ENTRY                                                   = 1911;
  ER_SQL_MODE_NO_EFFECT                                               = 1912;
  ER_AGGREGATE_ORDER_FOR_UNION                                        = 1913;
  ER_AGGREGATE_ORDER_NON_AGG_QUERY                                    = 1914;
  ER_SLAVE_WORKER_STOPPED_PREVIOUS_THD_ERROR                          = 1915;
  ER_DONT_SUPPORT_SLAVE_PRESERVE_COMMIT_ORDER                         = 1916;
  ER_SERVER_OFFLINE_MODE                                              = 1917;
  ER_GIS_DIFFERENT_SRIDS                                              = 1918;
  ER_GIS_UNSUPPORTED_ARGUMENT                                         = 1919;
  ER_GIS_UNKNOWN_ERROR                                                = 1920;
  ER_GIS_UNKNOWN_EXCEPTION                                            = 1921;
  ER_GIS_INVALID_DATA                                                 = 1922;
  ER_BOOST_GEOMETRY_EMPTY_INPUT_EXCEPTION                             = 1923;
  ER_BOOST_GEOMETRY_CENTROID_EXCEPTION                                = 1924;
  ER_BOOST_GEOMETRY_OVERLAY_INVALID_INPUT_EXCEPTION                   = 1925;
  ER_BOOST_GEOMETRY_TURN_INFO_EXCEPTION                               = 1926;
  ER_BOOST_GEOMETRY_SELF_INTERSECTION_POINT_EXCEPTION                 = 1927;
  ER_BOOST_GEOMETRY_UNKNOWN_EXCEPTION                                 = 1928;
  ER_STD_BAD_ALLOC_ERROR                                              = 1929;
  ER_STD_DOMAIN_ERROR                                                 = 1930;
  ER_STD_LENGTH_ERROR                                                 = 1931;
  ER_STD_INVALID_ARGUMENT                                             = 1932;
  ER_STD_OUT_OF_RANGE_ERROR                                           = 1933;
  ER_STD_OVERFLOW_ERROR                                               = 1934;
  ER_STD_RANGE_ERROR                                                  = 1935;
  ER_STD_UNDERFLOW_ERROR                                              = 1936;
  ER_STD_LOGIC_ERROR                                                  = 1937;
  ER_STD_RUNTIME_ERROR                                                = 1938;
  ER_STD_UNKNOWN_EXCEPTION                                            = 1939;
  ER_GIS_DATA_WRONG_ENDIANESS                                         = 1940;
  ER_CHANGE_MASTER_PASSWORD_LENGTH                                    = 1941;
  ER_USER_LOCK_WRONG_NAME                                             = 1942;
  ER_USER_LOCK_DEADLOCK                                               = 1943;
  ER_REPLACE_INACCESSIBLE_ROWS                                        = 1944;
  ER_ALTER_OPERATION_NOT_SUPPORTED_REASON_GIS                         = 1945;
  ER_ILLEGAL_USER_VAR                                                 = 1946;
  ER_GTID_MODE_OFF                                                    = 1947;
  ER_UNSUPPORTED_BY_REPLICATION_THREAD                                = 1948;
  ER_INCORRECT_TYPE                                                   = 1949;
  ER_FIELD_IN_ORDER_NOT_SELECT                                        = 1950;
  ER_AGGREGATE_IN_ORDER_NOT_SELECT                                    = 1951;
  ER_INVALID_RPL_WILD_TABLE_FILTER_PATTERN                            = 1952;
  ER_NET_OK_PACKET_TOO_LARGE                                          = 1953;
  ER_INVALID_JSON_DATA                                                = 1954;
  ER_INVALID_GEOJSON_MISSING_MEMBER                                   = 1955;
  ER_INVALID_GEOJSON_WRONG_TYPE                                       = 1956;
  ER_INVALID_GEOJSON_UNSPECIFIED                                      = 1957;
  ER_DIMENSION_UNSUPPORTED                                            = 1958;
  ER_ERROR_LAST                                                       = 1958;


  CR_MIN_ERROR                                                        = 2000;
  CR_UNKNOWN_ERROR                                                    = 2000;   // Unknown MySQL error
  CR_SOCKET_CREATE_ERROR                                              = 2001;   // Can't create UNIX socket (%d)
  CR_CONNECTION_ERROR                                                 = 2002;   // Can't connect to local MySQL server through socket '%s' (%d)
  CR_CONN_HOST_ERROR                                                  = 2003;   // Can't connect to MySQL server on '%s' (%d)
  CR_IPSOCK_ERROR                                                     = 2004;   // Can't create TCP/IP socket (%d)
  CR_UNKNOWN_HOST                                                     = 2005;   // Unknown MySQL server host '%s' (%d)
  CR_SERVER_GONE_ERROR                                                = 2006;   // MySQL server has gone away
  CR_VERSION_ERROR                                                    = 2007;   // Protocol mismatch; server version                                                                                                     = %d, client version                                                                                                     = %d
  CR_OUT_OF_MEMORY                                                    = 2008;   // MySQL client ran out of memory
  CR_WRONG_HOST_INFO                                                  = 2009;   // Wrong host info
  CR_LOCALHOST_CONNECTION                                             = 2010;   // Localhost via UNIX socket
  CR_TCP_CONNECTION                                                   = 2011;   // s via TCP/IP
  CR_SERVER_HANDSHAKE_ERR                                             = 2012;   // Error in server handshake
  CR_SERVER_LOST                                                      = 2013;   // Lost connection to MySQL server during query
  CR_COMMANDS_OUT_OF_SYNC                                             = 2014;   // Commands out of sync; you can't run this command now
  CR_NAMEDPIPE_CONNECTION                                             = 2015;   // Named pipe: %s
  CR_NAMEDPIPEWAIT_ERROR                                              = 2016;   // Can't wait for named pipe to host: %s pipe: %s (%lu)
  CR_NAMEDPIPEOPEN_ERROR                                              = 2017;   // Can't open named pipe to host: %s pipe: %s (%lu)
  CR_NAMEDPIPESETSTATE_ERROR                                          = 2018;   // Can't set state of named pipe to host: %s pipe: %s (%lu)
  CR_CANT_READ_CHARSET                                                = 2019;   // Can't initialize character set %s (path: %s)
  CR_NET_PACKET_TOO_LARGE                                             = 2020;   // Got packet bigger than 'max_allowed_packet' bytes
  CR_EMBEDDED_CONNECTION                                              = 2021;   // Embedded server
  CR_PROBE_SLAVE_STATUS                                               = 2022;   // Error on SHOW SLAVE STATUS:
  CR_PROBE_SLAVE_HOSTS                                                = 2023;   // Error on SHOW SLAVE HOSTS:
  CR_PROBE_SLAVE_CONNECT                                              = 2024;   // Error connecting to slave:
  CR_PROBE_MASTER_CONNECT                                             = 2025;   // Error connecting to master:
  CR_SSL_CONNECTION_ERROR                                             = 2026;   // SSL connection error: %s
  CR_MALFORMED_PACKET                                                 = 2027;   // Malformed packet
  CR_WRONG_LICENSE                                                    = 2028;   // This client library is licensed only for use with MySQL servers having '%s' license
  CR_NULL_POINTER                                                     = 2029;   // Invalid use of null pointer
  CR_NO_PREPARE_STMT                                                  = 2030;   // Statement not prepared
  CR_PARAMS_NOT_BOUND                                                 = 2031;   // No data supplied for parameters in prepared statement
  CR_DATA_TRUNCATED                                                   = 2032;   // Data truncated
  CR_NO_PARAMETERS_EXISTS                                             = 2033;   // No parameters exist in the statement
  CR_INVALID_PARAMETER_NO                                             = 2034;   // Invalid parameter number
  CR_INVALID_BUFFER_USE                                               = 2035;   // Can't send long data for non-string/non-binary data types (parameter: %d)
  CR_UNSUPPORTED_PARAM_TYPE                                           = 2036;   // Using unsupported buffer type: %d (parameter: %d)
  CR_SHARED_MEMORY_CONNECTION                                         = 2037;   // Shared memory: %s
  CR_SHARED_MEMORY_CONNECT_REQUEST_ERROR                              = 2038;   // Can't open shared memory; client could not create request event (%lu)
  CR_SHARED_MEMORY_CONNECT_ANSWER_ERROR                               = 2039;   // Can't open shared memory; no answer event received from server (%lu)
  CR_SHARED_MEMORY_CONNECT_FILE_MAP_ERROR                             = 2040;   // Can't open shared memory; server could not allocate file mapping (%lu)
  CR_SHARED_MEMORY_CONNECT_MAP_ERROR                                  = 2041;   // Can't open shared memory; server could not get pointer to file mapping (%lu)
  CR_SHARED_MEMORY_FILE_MAP_ERROR                                     = 2042;   // Can't open shared memory; client could not allocate file mapping (%lu)
  CR_SHARED_MEMORY_MAP_ERROR                                          = 2043;   // Can't open shared memory; client could not get pointer to file mapping (%lu)
  CR_SHARED_MEMORY_EVENT_ERROR                                        = 2044;   // Can't open shared memory; client could not create %s event (%lu)
  CR_SHARED_MEMORY_CONNECT_ABANDONED_ERROR                            = 2045;   // Can't open shared memory; no answer from server (%lu)
  CR_SHARED_MEMORY_CONNECT_SET_ERROR                                  = 2046;   // Can't open shared memory; cannot send request event to server (%lu)
  CR_CONN_UNKNOW_PROTOCOL                                             = 2047;   // Wrong or unknown protocol
  CR_INVALID_CONN_HANDLE                                              = 2048;   // Invalid connection handle
  CR_SECURE_AUTH                                                      = 2049;   // Connection using old (pre-4.1.1) authentication protocol refused (client option 'secure_auth' enabled)
  CR_FETCH_CANCELED                                                   = 2050;   // Row retrieval was canceled by mysql_stmt_close() call
  CR_NO_DATA                                                          = 2051;   // Attempt to read column without prior row fetch
  CR_NO_STMT_METADATA                                                 = 2052;   // Prepared statement contains no metadata
  CR_NO_RESULT_SET                                                    = 2053;   // Attempt to read a row while there is no result set associated with the statement
  CR_NOT_IMPLEMENTED                                                  = 2054;   // This feature is not implemented yet
  CR_SERVER_LOST_EXTENDED                                             = 2055;   // Lost connection to MySQL server at '%s', system error: %d
  CR_STMT_CLOSED                                                      = 2056;   // Statement closed indirectly because of a preceding %s() call
  CR_NEW_STMT_METADATA                                                = 2057;   // The number of columns in the result set differs from the number of bound buffers. You must reset the statement, rebind the result set columns, and execute the statement again
  CR_ALREADY_CONNECTED                                                = 2058;   // This handle is already connected. Use a separate handle for each connection.
  CR_AUTH_PLUGIN_CANNOT_LOAD                                          = 2059;   // Authentication plugin '%s' cannot be loaded: %s
  CR_DUPLICATE_CONNECTION_ATTR                                        = 2060;   // There is an attribute with the same name already
  CR_AUTH_PLUGIN_ERR                                                  = 2061;   // Authentication plugin '%s' reported error: %s
  CR_INSECURE_API_ERR                                                 = 2062;   // Insecure API function call: '%s' Use instead: '%s'
  CR_MAX_ERROR                                                        = 2062;

var
  CLIENT_ERRORS: array [0..62] of PChar = (
    'Unknown MySQL error',
    'Can''t create UNIX socket (%d)',
    'Can''t connect to local MySQL server through socket ''%s'' (%d)',
    'Can''t connect to MySQL server on ''%s'' (%d)',
    'Can''t create TCP/IP socket (%d)',
    'Unknown MySQL server host ''%s'' (%d)',
    'MySQL server has gone away',
    'Protocol mismatch; server version = %d, client version = %d',
    'MySQL client ran out of memory',
    'Wrong host info',
    'Localhost via UNIX socket',
    '%s via TCP/IP',
    'Error in server handshake',
    'Lost connection to MySQL server during query',
    'Commands out of sync; you can''t run this command now',
    'Named pipe: %s',
    'Can''t wait for named pipe to host: %s pipe: %s (%d)',
    'Can''t open named pipe to host: %s pipe: %s (%d)',
    'Can''t set state of named pipe to host: %s pipe: %s (%d)',
    'Can''t initialize character set %s (path: %s)',
    'Got packet bigger than ''max_allowed_packet'' bytes',
    'Embedded server',
    'Error on SHOW SLAVE STATUS:',
    'Error on SHOW SLAVE HOSTS:',
    'Error connecting to slave:',
    'Error connecting to master:',
    'SSL connection error: %s',
    'Malformed packet',
    'This client library is licensed only for use with MySQL servers having ''%s'' license',
    'Invalid use of null pointer',
    'Statement not prepared',
    'No data supplied for parameters in prepared statement',
    'Data truncated',
    'No parameters exist in the statement',
    'Invalid parameter number',
    'Can''t send long data for non-string/non-binary data types (parameter: %d)',
    'Using unsupported buffer type: %d (parameter: %d)',
    'Shared memory: %s',
    'Can''t open shared memory; client could not create request event (%lu)',
    'Can''t open shared memory; no answer event received from server (%lu)',
    'Can''t open shared memory; server could not allocate file mapping (%lu)',
    'Can''t open shared memory; server could not get pointer to file mapping (%lu)',
    'Can''t open shared memory; client could not allocate file mapping (%lu)',
    'Can''t open shared memory; client could not get pointer to file mapping (%lu)',
    'Can''t open shared memory; client could not create %s event (%lu)',
    'Can''t open shared memory; no answer from server (%lu)',
    'Can''t open shared memory; cannot send request event to server (%lu)',
    'Wrong or unknown protocol',
    'Invalid connection handle',
    'Connection using old (pre-4.1.1) authentication protocol refused (client option ''secure_auth'' enabled)',
    'Row retrieval was canceled by mysql_stmt_close() call',
    'Attempt to read column without prior row fetch',
    'Prepared statement contains no metadata',
    'Attempt to read a row while there is no result set associated with the statement',
    'This feature is not implemented yet',
    'Lost connection to MySQL server at ''%s'', system error: %d',
    'Statement closed indirectly because of a preceding %s() call',
    'The number of columns in the result set differs from the number of bound buffers. You must reset the statement, rebind the result set columns, and execute the statement again',
    'This handle is already connected. Use a separate handle for each connection.',
    'Authentication plugin ''%s'' cannot be loaded: %s',
    'There is an attribute with the same name already',
    'Authentication plugin ''%s'' reported error: %s',
    'Insecure API function call: ''%s'' Use instead: ''%s'''
  );

implementation {***************************************************************}

end.


unit uSession;

interface {********************************************************************}

uses
  Windows,
  SysUtils, Classes, SyncObjs, Generics.Collections,
  DB,
  acMYSQLSynProvider, acQBEventMetaProvider,
  BCEditor.Editor, BCEditor.Highlighter,
  SQLUtils, MySQLDB, MySQLConsts, SQLParser,
uProfiling,
  uPreferences;

type
  TSItems = class;
  TSEntities = class;
  TSObjects = class;
  TSDBObject = class;
  TSDBObjects = class;
  TSReferences = class;
  TSKeyColumns = class;
  TSKey = class;
  TSTableField = class;
  TSBaseField = class;
  TSKeys = class;
  TSTableFields = class;
  TSForeignKey = class;
  TSForeignKeys = class;
  TSTable = class;
  TSBaseFields = class;
  TSBaseTable = class;
  TSView = class;
  TSTables = class;
  TSRoutine = class;
  TSRoutines = class;
  TSTrigger = class;
  TSTriggers = class;
  TSEvent = class;
  TSEvents = class;
  TSColumns = class;
  TSDatabase = class;
  TSDatabases = class;
  TSVariable = class;
  TSVariables = class;
  TSUserRight = class;
  TSUser = class;
  TSUsers = class;
  TSPlugin = class;
  TSPlugins = class;
  TSEngine = class;
  TSEngines = class;
  TSFieldType = class;
  TSFieldTypes = class;
  TSCharset = class;
  TSCharsets = class;
  TSCollation = class;
  TSCollations = class;
  TSConnection = class;
  TSItemSearch = class;
  TSSession = class;
  TSSessions = class;

  TSItem = class(TObject)
  private
    FName: string;
    FItems: TSItems;
  protected
    function GetAddress(): string; virtual;
    function GetCaption(): string; virtual;
    function GetIndex(): Integer; virtual;
    function GetSession(): TSSession; virtual;
    procedure SetName(const AName: string); virtual;
  public
    procedure Assign(const Source: TSItem); virtual;
    function Equal(const Second: TSItem): Boolean; virtual;
    constructor Create(const ASItems: TSItems; const AName: string = ''); virtual;
    property Address: string read GetAddress;
    property Caption: string read GetCaption;
    property Index: Integer read GetIndex;
    property Name: string read FName write SetName;
    property Session: TSSession read GetSession;
    property Items: TSItems read FItems;
  end;

  TSItems = class(TList)
  private
    FSession: TSSession;
    function GetItem(Index: Integer): TSItem; inline;
  protected
    procedure Delete(const AItem: TSItem; const FreeItem: Boolean = True); overload; virtual;
    function GetCount(): Integer; virtual;
    function InsertIndex(const Name: string; out Index: Integer): Boolean; virtual;
  public
    procedure Clear(); override;
    constructor Create(const ASession: TSSession);
    destructor Destroy(); override;
    function IndexByName(const Name: string): Integer; virtual;
    function NameCmp(const Name1, Name2: string): Integer; virtual;
    property Count: Integer read GetCount;
    property Item[Index: Integer]: TSItem read GetItem; default;
    property Session: TSSession read FSession;
  end;

  TSEntity = class(TSItem)
  private
    function GetEntities(): TSEntities; inline;
  public
    property Entities: TSEntities read GetEntities;
  end;

  TSEntities = class(TSItems)
  protected
    FValid: Boolean;
    function Add(const AEntity: TSEntity; const SendEvent: Boolean = False): Integer; virtual;
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
      Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; virtual;
    function GetValid(): Boolean; virtual;
    function SQLGetItems(const Name: string = ''): string; virtual; abstract;
  public
    procedure Clear(); override;
    constructor Create(const ASession: TSSession);
    procedure Invalidate(); virtual;
    procedure PushBuildEvent(const Sender: TObject); virtual;
    function Update(): Boolean; overload; virtual;
    property Valid: Boolean read GetValid;
  end;

  TSObject = class(TSEntity)
  type
    TDesktop = class
    private
      FSObject: TSObject;
    public
      constructor Create(const ASObject: TSObject);
      property SObject: TSObject read FSObject;
    end;
  private
    function GetObjects(): TSObjects; inline;
  protected
    FDesktop: TDesktop;
    FOriginalName: string;
    FSource: string;
    FValidSource: Boolean;
    function Build(const DataSet: TMySQLQuery): Boolean; overload; virtual; abstract;
    function Build(const Field: TField): Boolean; overload; virtual;
    procedure FreeDesktop(); virtual;
    function GetDesktop(): TDesktop; virtual;
    function GetValid(): Boolean; virtual;
    function GetValidSource(): Boolean; virtual;
    procedure SetName(const AName: string); override;
    procedure SetSource(const ASource: string); overload; virtual;
  public
    procedure Assign(const Source: TSObject); reintroduce; virtual;
    constructor Create(const AItems: TSItems; const AName: string = ''); reintroduce; virtual;
    destructor Destroy(); override;
    procedure Invalidate(); virtual;
    function Update(): Boolean; overload; virtual;
    property Desktop: TDesktop read GetDesktop;
    property Objects: TSObjects read GetObjects;
    property OriginalName: string read FOriginalName;
    property Source: string read FSource;
    property Valid: Boolean read GetValid;
    property ValidSource: Boolean read GetValidSource;
  end;

  TSObjects = class(TSEntities)
  protected
    function Add(const AEntity: TSEntity; const SendEvent: Boolean = False): Integer; override;
  public
    procedure Invalidate(); override;
  end;

  TSReference = class
  private
    FDatabaseName: string;
    FDBObjectClass: TClass;
    FDBObjectName: string;
    FReferences: TSReferences;
    function GetDBObject(): TSDBObject;
    function GetSession(): TSSession; inline;
  protected
    property Session: TSSession read GetSession;
  public
    constructor Create(const AReferences: TSReferences; const ADatabaseName: string;
      const ADBObjectClass: TClass; const ADBObjectName: string); reintroduce; virtual;
    property DBObject: TSDBObject read GetDBObject;
    property DatabaseName: string read FDatabaseName;
    property DBObjectClass: TClass read FDBObjectClass;
    property DBObjectName: string read FDBObjectName;
  end;

  TSReferences = class(TList)
  private
    FDBObject: TSDBObject;
    function GetReference(Index: Integer): TSReference;
    function GetSession(): TSSession; inline;
  public
    function Add(Item: Pointer): Integer;
    procedure Clear(); override;
    constructor Create(const ADBObject: TSDBObject); virtual;
    property DBObject: TSDBObject read FDBObject;
    property References[Index: Integer]: TSReference read GetReference; default;
    property Session: TSSession read GetSession;
  end;

  TSDependenciesSearch = class
  private
    FDBObject: TSDBObject;
    function GetDatabase(): TSDatabase; inline;
    function GetSession(): TSSession; inline;
  protected
    function BuildBaseTableReferences(const DataSet: TMySQLQuery): Boolean; virtual;
    function GetValid(): Boolean; virtual;
    function SQLGetReferences(): string; virtual;
  public
    constructor Create(const ADBObject: TSDBObject); virtual;
    property DBObject: TSDBObject read FDBObject;
    property Database: TSDatabase read GetDatabase;
    property Session: TSSession read GetSession;
    property Valid: Boolean read GetValid;
  end;

  TSDBObject = class(TSObject)
  type
    TSecurity = (seDefiner, seInvoker);
  private
    FDatabase: TSDatabase;
    FDependendciesSearch: TSDependenciesSearch;
    FReferences: TSReferences;
    function GetDBObjects(): TSDBObjects; inline;
  protected
    function Build(const DataSet: TMySQLQuery): Boolean; override; abstract;
    function Build(const Field: TField): Boolean; override;
    procedure SetDatabase(const ADatabase: TSDatabase); virtual;
    procedure SetReferences(const SQL: string); virtual;
    function SQLGetSource(): string; virtual; abstract;
  public
    procedure Assign(const Source: TSObject); override;
    procedure Clear(); virtual;
    constructor Create(const ADBObjects: TSDBObjects; const AName: string = ''); reintroduce; virtual;
    destructor Destroy(); override;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string; virtual; abstract;
    procedure Invalidate(); override;
    procedure PushBuildEvent(const ItemsEvents: Boolean = True); virtual;
    function Update(): Boolean; override;
    property Database: TSDatabase read FDatabase;
    property DBObjects: TSDBObjects read GetDBObjects;
    property References: TSReferences read FReferences;
    property DependenciesSearch: TSDependenciesSearch read FDependendciesSearch;
  end;

  TSDBObjects = class(TSObjects)
  private
    FDatabase: TSDatabase;
  protected
    function Add(const AEntity: TSEntity; const SendEvent: Boolean = False): Integer; override;
    procedure Delete(const AItem: TSItem; const FreeItem: Boolean = True); override;
  public
    constructor Create(const ADatabase: TSDatabase); reintroduce; virtual;
    property Database: TSDatabase read FDatabase;
  end;

  TSKeyColumn = class
  private
    FKeyColumns: TSKeyColumns;
  public
    Ascending: Boolean;
    Field: TSBaseField;
    Length: Integer;
    procedure Assign(const Source: TSKeyColumn); virtual;
    constructor Create(const AKeyColumns: TSKeyColumns); virtual;
    function Equal(const Second: TSKeyColumn): Boolean; virtual;
    property IndexColumns: TSKeyColumns read FKeyColumns;
  end;

  TSKeyColumns = class(TSItems)
  private
    FKey: TSKey;
    function GetColumn(Index: Integer): TSKeyColumn;
  public
    procedure AddColumn(const NewColumn: TSKeyColumn); virtual;
    constructor Create(const AKey: TSKey); virtual;
    procedure DeleteColumn(const AColumn: TSKeyColumn); virtual;
    function KeyByField(const AField: TSTableField): Integer; virtual;
    property Column[Index: Integer]: TSKeyColumn read GetColumn; default;
    property Count: Integer read GetCount;
    property Key: TSKey read FKey;
  end;

  TSKey = class(TSItem)
  private
    Created: Boolean;
    FColumns: TSKeyColumns;
    function GetKeys(): TSKeys; inline;
    function GetTable(): TSBaseTable;
  protected
    FOriginalName: string;
    function GetCaption(): string; override;
    procedure SetName(const AName: string); override;
  public
    BlockSize: Integer;
    Comment: string;
    Fulltext: Boolean;
    IndexType: string;
    PrimaryKey: Boolean;
    Unique: Boolean;
    procedure Assign(const Source: TSKey); reintroduce; virtual;
    procedure Clear(); virtual;
    function ColumnByField(const AField: TSBaseField): TSKeyColumn; virtual;
    function ColumnByFieldName(const AFieldName: string): TSKeyColumn; virtual;
    constructor Create(const AKeys: TSKeys; const AName: string = ''); reintroduce; virtual;
    destructor Destroy(); override;
    function Equal(const Second: TSKey): Boolean; reintroduce; virtual;
    procedure GetSortDef(var SortDef: TIndexDef);
    property Columns: TSKeyColumns read FColumns;
    property Index: Integer read GetIndex;
    property Keys: TSKeys read GetKeys;
    property OriginalName: string read FOriginalName;
    property Table: TSBaseTable read GetTable;
  end;

  TSKeys = class(TSItems)
  private
    FTable: TSBaseTable;
    function GetKey(Index: Integer): TSKey; inline;
    function GetPrimaryKey(): TSKey;
  protected
    FValid: Boolean;
  public
    function AddKey(const NewKey: TSKey): Integer; virtual;
    procedure Assign(const Source: TSKeys); virtual;
    constructor Create(const ATable: TSBaseTable);
    procedure Invalidate();
    procedure Delete(const AKey: TSKey); overload;
    property Key[Index: Integer]: TSKey read GetKey; default;
    property PrimaryKey: TSKey read GetPrimaryKey;
    property Table: TSBaseTable read FTable;
    property Valid: Boolean read FValid;
  end;

  TSField = class(TSItem)
  type
    TFieldKind = (mkUnknown, mkReal, mkVirtual);
    TFieldStored = (msUnknown, msVirtual, msStored);
    TFieldType = (mfUnknown,
      mfBit, mfTinyInt, mfSmallInt, mfMediumInt, mfInt, mfBigInt,
      mfFloat, mfDouble, mfDecimal, mfDate, mfDateTime, mfTimeStamp, mfTime, mfYear,
      mfChar, mfVarChar, mfTinyText, mfText, mfMediumText, mfLongText, mfEnum, mfSet,
      mfBinary, mfVarBinary, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob,
      mfGeometry, mfPoint, mfLineString, mfPolygon, mfMultiPoint, mfMultiLineString, mfMultiPolygon, mfGeometryCollection,
      mfJSON);
  private
    FFieldTypes: TSFieldTypes;
  protected
    function GetSession(): TSSession; override;
    procedure ParseFieldType(var Parse: TSQLParse); virtual;
    procedure SetName(const AName: string); override;
  public
    Charset: string;
    Collation: string;
    Decimals: Integer;
    Elements: array of string;
    Expression: string;
    FieldKind: TFieldKind;
    FieldType: TFieldType;
    National: Boolean;
    Size: Integer;
    Stored: TFieldStored;
    Unsigned: Boolean;
    procedure Assign(const Source: TSField); reintroduce; virtual;
    procedure Clear(); virtual;
    constructor Create(const AFieldTypes: TSFieldTypes; const AName: string = ''); reintroduce; virtual;
    function DBTypeStr(): string; virtual;
    function Equal(const Second: TSField): Boolean; reintroduce; virtual;
    function EscapeValue(const Value: string): string; virtual;
    property FieldTypes: TSFieldTypes read FFieldTypes;
  end;

  TSTableField = class(TSField)
  type
    TRowType = (mrUnknown, mrFixed, mrDynamic, mrCompressed, mrRedundant, mrCompact);
  private
    FInPrimaryKey: Boolean;
    FInUniqueKey: Boolean;
    function GetFields(): TSTableFields; inline;
    function GetTable(): TSTable; inline;
  protected
    procedure ParseFieldType(var Parse: TSQLParse); override;
  public
    Ascii: Boolean;
    AutoIncrement: Boolean;
    Binary: Boolean;
    Comment: string;
    Default: string;
    DefaultSize: Integer;
    FieldBefore: TSTableField;
    Format: TSTableField.TRowType;
    NullAllowed: Boolean;
    Unicode: Boolean;
    Zerofill: Boolean;
    procedure Assign(const Source: TSField); override;
    procedure Clear(); override;
    constructor Create(const AFields: TSTableFields; const AName: string = ''); reintroduce; virtual;
    function DBTypeStr(): string; override;
    destructor Destroy(); override;
    function Equal(const Second: TSTableField): Boolean; reintroduce; virtual;
    function UnescapeValue(const Value: string): string; virtual;
    property Fields: TSTableFields read GetFields;
    property InPrimaryKey: Boolean read FInPrimaryKey;
    property InUniqueKey: Boolean read FInUniqueKey;
    property Index: Integer read GetIndex;
    property Table: TSTable read GetTable;
  end;

  TSBaseField = class(TSTableField)
  private
    function GetTable(): TSBaseTable;
  protected
    FOriginalName: string;
    function GetIndex(): Integer; override;
  public
    Moved: Boolean;
    OnUpdate: string;
    OnUpdateSize: Integer;
    procedure Assign(const Source: TSField); override;
    procedure Clear(); override;
    constructor Create(const AFields: TSTableFields; const AName: string = ''); override;
    property OriginalName: string read FOriginalName;
    property Table: TSBaseTable read GetTable;
  end;

  TSViewField = class(TSTableField)
    function GetIndex(): Integer; override;
  end;

  TSTableFields = class(TSItems)
  private
    FTable: TSTable;
    function GetField(Index: Integer): TSTableField; inline;
  protected
    FValid: Boolean;
    function FieldByName(const FieldName: string): TSTableField; virtual;
    function InsertIndex(const Name: string; out Index: Integer): Boolean; override;
  public
    function AddField(const NewField: TSTableField): Integer; virtual;
    procedure Assign(const Source: TSTableFields); virtual;
    constructor Create(const ATable: TSTable);
    procedure Delete(const AField: TSTableField); overload;
    function IndexByName(const Name: string): Integer; override;
    function IndexOf(const AField: TSTableField): Integer; virtual;
    procedure Invalidate(); virtual;
    property Field[Index: Integer]: TSTableField read GetField; default;
    property Table: TSTable read FTable;
    property Valid: Boolean read FValid;
  end;

  TSBaseFields = class(TSTableFields)
  private
    function GetField(Index: Integer): TSBaseField; inline;
  public
    function AddField(const NewField: TSTableField): Integer; override;
    procedure Assign(const Source: TSTableFields); override;
    procedure MoveField(const AField: TSTableField; const NewFieldBefore: TSTableField); virtual;
    property Field[Index: Integer]: TSBaseField read GetField; default;
  end;

  TSViewFields = class(TSTableFields)
  public
    procedure Assign(const Source: TSTableFields); override;
  end;

  TSForeignKey = class(TSItem)
  type
    TForeignKeyDeleteType = (dtNoAction, dtCascade, dtSetNull, dtSetDefault, dtRestrict);
    TForeignKeyUpdateType = (utNoAction, utCascade, utSetNull, utSetDefault, utRestrict);
    TForeignKeyMatchType = (mtNo, mtFull, mtPartial);
  private
    function GetForeignKeys(): TSForeignKeys; inline;
    function GetTable(): TSBaseTable;
  protected
    Created: Boolean;
    FOriginalName: string;
    procedure SetName(const AName: string); override;
  public
    Fields: array of TSTableField;
    Match: TSForeignKey.TForeignKeyMatchType;
    OnDelete: TSForeignKey.TForeignKeyDeleteType;
    OnUpdate: TSForeignKey.TForeignKeyUpdateType;
    Parent : record
      DatabaseName: string;
      TableName: string;
      FieldNames: array of string;
    end;
    procedure Assign(const Source: TSForeignKey); reintroduce; virtual;
    procedure Clear(); virtual;
    constructor Create(const AForeignKeys: TSForeignKeys; const AName: string = ''); reintroduce; virtual;
    function DBTypeStr(): string; virtual;
    function Equal(const Second: TSForeignKey): Boolean; reintroduce; virtual;
    destructor Destroy(); override;
    property ForeignKeys: TSForeignKeys read GetForeignKeys;
    property Index: Integer read GetIndex;
    property OriginalName: string read FOriginalName;
    property Table: TSBaseTable read GetTable;
  end;

  TSForeignKeys = class(TSItems)
  private
    FTable: TSBaseTable;
    function GetForeignKey(Index: Integer): TSForeignKey; inline;
  protected
    FValid: Boolean;
  public
    function AddForeignKey(const NewForeignKey: TSForeignKey): Integer; virtual;
    procedure Assign(const Source: TSForeignKeys); virtual;
    procedure Clear(); override;
    constructor Create(const ATable: TSBaseTable); reintroduce; virtual;
    procedure Delete(const AForeignKey: TSForeignKey); overload;
    procedure Invalidate();
    property ForeignKey[Index: Integer]: TSForeignKey read GetForeignKey; default;
    property Table: TSBaseTable read FTable;
    property Valid: Boolean read FValid;
  end;

  TSMergeSourceTable = class
    DatabaseName: string;
    TableName: string;
  end;

  TSMergeSourceTables = class(TList)
  private
    function GetMergeSourceTable(Index: Integer): TSMergeSourceTable; inline;
  public
    procedure Clear(); override;
    destructor Destroy(); override;
    property MergeSourceTable[Index: Integer]: TSMergeSourceTable read GetMergeSourceTable; default;
  end;

  TSTable = class(TSDBObject)
  type
    TDataSet = class(TMySQLTable)
    private
      FFilterSQL: string;
      FQuickSearch: string;
      FTable: TSTable;
    protected
      function SQLSelect(const IgnoreLimit: Boolean = False): string; override;
    public
      constructor Create(const ATable: TSTable); reintroduce; virtual;
      procedure Invalidate(); virtual;
      property FilterSQL: string read FFilterSQL write FFilterSQL;
      property QuickSearch: string read FQuickSearch write FQuickSearch;
      property Table: TSTable read FTable;
    end;
  private
    function GetDataSet(): TDataSet;
    function GetTables(): TSTables; inline;
    function GetValidData(): Boolean;
    function OpenEvent(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
      const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
  protected
    FDataSet: TDataSet;
    FFilterSQL: string;
    function GetFields(): TSTableFields; virtual; abstract;
    procedure SetName(const AName: string); override;
  public
    procedure Assign(const Source: TSTable); reintroduce; virtual;
    constructor Create(const ASDBObjects: TSDBObjects; const AName: string = ''); reintroduce;
    destructor Destroy(); override;
    function FieldByName(const FieldName: string): TSTableField; virtual;
    procedure Invalidate(); override;
    procedure InvalidateData(); virtual;
    procedure Open(const FilterSQL, QuickSearch: string; const ASortDef: TIndexDef; const Offset: Integer; const Limit: Integer); virtual;
    procedure PushBuildEvent(const ItemsEvents: Boolean = True); override;
    property DataSet: TDataSet read GetDataSet;
    property Fields: TSTableFields read GetFields;
    property Index: Integer read GetIndex;
    property Tables: TSTables read GetTables;
    property ValidData: Boolean read GetValidData;
  end;

  TSPartition = class(TSItem)
  type
    TPartitionType = (ptNone, ptHash, ptKey, ptRange, ptList);
  private
    FTable: TSBaseTable;
  protected
    FOriginalName: string;
    function DBTypeStr(): string; virtual;
  public
    Comment: string;
    Engine: TSEngine;
    MaxRows: Integer;
    MinRows: Integer;
    ValuesExpr: string;
    procedure Assign(const Source: TSPartition); reintroduce; virtual;
    procedure Clear(); virtual;
    constructor Create(const ASItems: TSItems; const ATable: TSBaseTable); reintroduce; virtual;
    function Equal(const Second: TSPartition): Boolean; reintroduce; virtual;
    property OriginalName: string read FOriginalName;
    property Table: TSBaseTable read FTable;
  end;

  TSPartitions = class(TSItems)
  private
    FTable: TSBaseTable;
    function GetPartition(Index: Integer): TSPartition;
  public
    Expression: string;
    Linear: Boolean;
    PartitionsNumber: Integer;
    PartitionType: TSPartition.TPartitionType;
    procedure AddPartition(const NewPartition: TSPartition); virtual;
    procedure Assign(const Source: TSPartitions); virtual;
    procedure Clear(); override;
    constructor Create(const ATable: TSBaseTable); reintroduce; virtual;
    procedure Delete(const APartition: TSPartition); overload;
    function IndexOf(const APartition: TSPartition): Integer; virtual;
    procedure MovePartition(const APartition: TSPartition; const NewIndex: Integer); virtual;
    function UpdatePartition(const Partition, NewPartition: TSPartition): Boolean; virtual;
    property Table: TSBaseTable read FTable;
    property Partition[Index: Integer]: TSPartition read GetPartition; default;
  end;

  TSBaseTable = class(TSTable)
  type
    TPackKeys = (piUnpacked, piPacked, piDefault);
    TInsertMethod = (imNo, imFirst, imLast);
  private
    FAutoIncrement: Int64; // 0 -> unknown
    FAvgRowLength: LargeInt;
    FBlockSize: Integer;
    FChecked: TDateTime;
    FChecksum: Boolean;
    FCollation: string;
    FComment: string;
    FCreated: TDateTime;
    FDataSize: Int64;
    FCharset: string;
    FDelayKeyWrite: Boolean;
    FEngine: TSEngine;
    FFields: TSBaseFields;
    FForeignKeys: TSForeignKeys;
    FIndexSize: Int64;
    FInsertMethod: TInsertMethod;
    FKeys: TSKeys;
    FMaxDataSize: Int64;
    FMaxRows: Int64;
    FMergeSourceTables: TSMergeSourceTables;
    FMinRows: Int64;
    FPackKeys: TPackKeys;
    FPartitions: TSPartitions;
    FRecordCount: Int64;
    FRowType: TSTableField.TRowType;
    FTemporary: Boolean;
    FUnusedSize: Int64;
    FUpdated: TDateTime;
    function GetAutoIncrementField(): TSBaseField;
    function GetBaseTableFields(): TSBaseFields; inline;
    function GetPrimaryKey(): TSKey;
    function GetTriggers(Index: Integer): TSTrigger;
    function GetTriggerCount(): Integer;
  protected
    FValidStatus: Boolean;
    procedure AddReference(const ReferencedTable: TSBaseTable);
    function Build(const DataSet: TMySQLQuery): Boolean; override;
    function Build(const Field: TField): Boolean; override;
    function GetFields(): TSTableFields; override;
    function GetValid(): Boolean; override;
    procedure ParseAlterTable(const SQL: string);
    procedure ParseCreateTable(const SQL: string);
    procedure SetName(const AName: string); override;
    function SQLGetSource(): string; override;
    property MergeSourceTables: TSMergeSourceTables read FMergeSourceTables;
  public
    procedure Assign(const Source: TSTable); override;
    function FieldByName(const FieldName: string): TSBaseField; reintroduce; virtual;
    function ForeignKeyByName(const ForeignKeyName: string): TSForeignKey; virtual;
    constructor Create(const ASDBObjects: TSDBObjects; const AName: string = ''; const ASystemTable: Boolean = False); reintroduce; virtual;
    destructor Destroy(); override;
    function DBRowTypeStr(): string; virtual;
    procedure Empty(); virtual;
    function EmptyFields(const Fields: TList): Boolean; virtual;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string; override;
    procedure InvalidateData(); override;
    function KeyByCaption(const Caption: string): TSKey; virtual;
    function KeyByName(const Name: string): TSKey; virtual;
    procedure Invalidate(); override;
    procedure InvalidateStatus(); virtual;
    function PartitionByName(const PartitionName: string): TSPartition; virtual;
    function Update(const Status: Boolean): Boolean; reintroduce; overload; virtual;
    property AutoIncrement: Int64 read FAutoIncrement write FAutoIncrement;
    property AutoIncrementField: TSBaseField read GetAutoIncrementField;
    property AvgRowLength: LargeInt read FAvgRowLength;
    property BlockSize: Integer read FBlockSize write FBlockSize;
    property Checked: TDateTime read FChecked write FChecked;
    property Checksum: Boolean read FChecksum write FChecksum;
    property Collation: string read FCollation write FCollation;
    property Comment: string read FComment write FComment;
    property Created: TDateTime read FCreated;
    property DataSize: Int64 read FDataSize;
    property Charset: string read FCharset write FCharset;
    property DelayKeyWrite: Boolean read FDelayKeyWrite write FDelayKeyWrite;
    property Engine: TSEngine read FEngine write FEngine;
    property Fields: TSBaseFields read GetBaseTableFields;
    property IndexSize: Int64 read FIndexSize;
    property InsertMethod: TInsertMethod read FInsertMethod write FInsertMethod;
    property ForeignKeys: TSForeignKeys read FForeignKeys;
    property Keys: TSKeys read FKeys;
    property MaxDataSize: Int64 read FMaxDataSize;
    property MaxRows: Int64 read FMaxRows;
    property MinRows: Int64 read FMinRows;
    property PackKeys: TPackKeys read FPackKeys write FPackKeys;
    property Partitions: TSPartitions read FPartitions;
    property PrimaryKey: TSKey read GetPrimaryKey;
    property RecordCount: Int64 read FRecordCount;
    property RowType: TSTableField.TRowType read FRowType write FRowType;
    property Temporary: Boolean read FTemporary write FTemporary;
    property TriggerCount: Integer read GetTriggerCount;
    property Triggers[Index: Integer]: TSTrigger read GetTriggers;
    property UnusedSize: Int64 read FUnusedSize write FUnusedSize;
    property Updated: TDateTime read FUpdated;
    property ValidStatus: Boolean read FValidStatus;
  end;

  TSView = class(TSTable)
  type
    TAlgorithm = (vaUndefined, vaMerge, vaTemptable);
    TCheckOption = (voNone, voDefault, voCascaded, voLocal);
  private
    FAlgorithm: TAlgorithm;
    FCheckOption: TCheckOption;
    FDefiner: string;
    FFields: TSViewFields;
    FSecurity: TSDBObject.TSecurity;
    FStmt: string;
    function GetValidFields(): Boolean; inline;
    function GetViewFields(): TSViewFields; inline;
    function ParseCreateView(const SQL: string): string;
  protected
    FComment: string;
    function Build(const DataSet: TMySQLQuery): Boolean; overload; override;
    function Build(const Field: TField): Boolean; override;
    function GetFields(): TSTableFields; override;
    function GetValid(): Boolean; override;
    function SQLGetSource(): string; override;
    property ValidFields: Boolean read GetValidFields;
  public
    procedure Assign(const Source: TSTable); override;
    constructor Create(const ACDBObjects: TSDBObjects; const AName: string = '');
    destructor Destroy(); override;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string; overload; override;
    procedure Invalidate(); override;
    property Algorithm: TAlgorithm read FAlgorithm write FAlgorithm;
    property CheckOption: TCheckOption read FCheckOption write FCheckOption;
    property Definer: string read FDefiner;
    property Fields: TSViewFields read GetViewFields;
    property Security: TSDBObject.TSecurity read FSecurity write FSecurity;
    property Stmt: string read FStmt write FStmt;
  end;

  TSSystemView = class(TSTable)
  private
    FFields: TSViewFields;
    function GetValidFields(): Boolean; inline;
    function GetViewFields(): TSViewFields; inline;
  protected
    function Build(const DataSet: TMySQLQuery): Boolean; override;
    function GetFields(): TSTableFields; override;
    function SQLGetSource(): string; override;
    property ValidFields: Boolean read GetValidFields;
  public
    constructor Create(const ASDBObjects: TSDBObjects; const AName: string = '');
    destructor Destroy(); override;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string; override;
    property Fields: TSViewFields read GetViewFields;
  end;

  TSTables = class(TSDBObjects)
  private
    function GetTable(Index: Integer): TSTable; inline;
    function GetValidStatus(): Boolean;
  protected
    function Add(const AEntity: TSEntity; const SendEvent: Boolean = False): Integer; override;
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean; Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; overload; override;
    function BuildFields(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
    procedure Delete(const AItem: TSItem; const FreeItem: Boolean = True); override;
    function SQLGetItems(const Name: string = ''): string; override;
    function SQLGetStatus(const List: TList = nil): string;
  public
    function AddTable(const NewTable: TSTable): Integer; virtual;
    procedure Invalidate(); override;
    function NameCmp(const Name1, Name2: string): Integer; override;
    function Update(const Status: Boolean): Boolean; overload;
    property Table[Index: Integer]: TSTable read GetTable; default;
    property ValidStatus: Boolean read GetValidStatus;
  end;

  TSRoutineParameter = class(TSField)
  type
    TParameterType = (ptIn, ptOut, ptInOut);
  private
    FRoutine: TSRoutine;
    FParameterType: TParameterType;
  public
    procedure Assign(const Source: TSField); override;
    constructor Create(ARoutine: TSRoutine); reintroduce; virtual;
    property Routine: TSRoutine read FRoutine;
    property ParameterType: TParameterType read FParameterType;
  end;

  TSRoutine = class(TSDBObject)
  type
    TRoutineType = (rtUnknown, rtProcedure, rtFunction);
    TMySQLDataSets = array of TMySQLDataSet;
  private
    FComment: string;
    FCreated: TDateTime;
    FDefiner: string;
    FFunctionResult: TSField;
    FInputDataSet: TMySQLDataSet;
    FParameters: array of TSRoutineParameter;
    FRoutineType: TRoutineType;
    FSecurity: TSDBObject.TSecurity;
    FSourceEx: string;
    FStmt: string;
    FUpdated: TDateTime;
    function GetInputDataSet(): TMySQLDataSet;
    function GetParameter(Index: Integer): TSRoutineParameter;
    function GetParameterCount(): Integer;
    function GetRoutines(): TSRoutines; inline;
    procedure ParseCreateRoutine(const SQL: string; const SetNameOnly: Boolean = False);
  protected
    function Build(const Field: TField): Boolean; override;
    function SQLGetSource(): string; override;
  public
    procedure Assign(const Source: TSRoutine); reintroduce; virtual;
    constructor Create(const ACDBObjects: TSDBObjects; const AName: string = ''); override;
    destructor Destroy(); override;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string; override;
    function SQLRun(): string; virtual;
    property Stmt: string read FStmt;
    property Comment: string read FComment write FComment;
    property Created: TDateTime read FCreated;
    property Definer: string read FDefiner;
    property FunctionResult: TSField read FFunctionResult;
    property InputDataSet: TMySQLDataSet read GetInputDataSet;
    property Security: TSDBObject.TSecurity read FSecurity write FSecurity;
    property Source: string read FSource write SetSource;
    property Parameter[Index: Integer]: TSRoutineParameter read GetParameter;
    property ParameterCount: Integer read GetParameterCount;
    property Routines: TSRoutines read GetRoutines;
    property RoutineType: TRoutineType read FRoutineType;
    property Updated: TDateTime read FUpdated;
  end;

  TSProcedure = class(TSRoutine)
  protected
    function Build(const DataSet: TMySQLQuery): Boolean; overload; override;
    function SQLGetSource(): string; override;
  public
    function SQLRun(): string; override;
  end;

  TSFunction = class(TSRoutine)
  protected
    function Build(const DataSet: TMySQLQuery): Boolean; overload; override;
    function SQLGetSource(): string; override;
  public
    function SQLRun(): string; override;
  end;

  TSRoutines = class(TSDBObjects)
  private
    function GetRoutine(Index: Integer): TSRoutine;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean; Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    function AddRoutine(const NewRoutine: TSRoutine): Integer; virtual;
    property Routine[Index: Integer]: TSRoutine read GetRoutine; default;
  end;

  TSTrigger = class(TSDBObject)
  type
    TEvent = (teInsert, teUpdate, teDelete);
    TTiming = (ttBefore, ttAfter);
  private
    FInputDataSet: TMySQLDataSet;
    FSourceEx: string;
    function GetInputDataSet(): TMySQLDataSet;
    function GetTable(): TSBaseTable; inline;
    function GetTriggers(): TSTriggers; inline;
    procedure ParseCreateTrigger(const SQL: string);
  protected
    FCreated: TDateTime;
    FDatabaseName: string;
    FDefiner: string;
    FEvent: TEvent;
    FStmt: string;
    FTableName: string;
    FTiming: TTiming;
    FValid: Boolean;
    function Build(const DataSet: TMySQLQuery): Boolean; overload; override;
    function Build(const Field: TField): Boolean; override;
    function SQLGetSource(): string; override;
    property Valid: Boolean read FValid;
  public
    procedure Assign(const Source: TSTrigger); reintroduce; virtual;
    constructor Create(const ACDBObjects: TSDBObjects; const AName: string = ''); override;
    destructor Destroy(); override;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string; override;
    procedure Invalidate(); override;
    function SQLDelete(): string; virtual;
    function SQLInsert(): string; virtual;
    function SQLReplace(): string; virtual;
    function SQLUpdate(): string; virtual;
    property Created: TDateTime read FCreated;
    property DatabaseName: string read FDatabaseName write FDatabaseName;
    property Definer: string read FDefiner;
    property Event: TEvent read FEvent write FEvent;
    property InputDataSet: TMySQLDataSet read GetInputDataSet;
    property Stmt: string read FStmt write FStmt;
    property Table: TSBaseTable read GetTable;
    property TableName: string read FTableName write FTableName;
    property Timing: TTiming read FTiming write FTiming;
    property Triggers: TSTriggers read GetTriggers;
  end;

  TSTriggers = class(TSDBObjects)
  private
    function GetTrigger(Index: Integer): TSTrigger; inline;
  protected
    function Add(const AEntity: TSEntity; const SendEvent: Boolean = False): Integer; override;
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
      Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    procedure Invalidate(); override;
    property Trigger[Index: Integer]: TSTrigger read GetTrigger; default;
  end;

  TSEvent = class(TSDBObject)
  type
    TEventType = (etUnknown, etSingle, etMultiple);
    TIntervalType = (itUnknown, itYear, itQuarter, itMonth, itDay, itHour,
      itMinute, itWeek, itSecond, itMicrosecond, itYearMonth, itDayHour,
      itDayMinute, itDaySecond, itHourMinute, itHourSecond, itMinuteSecond,
      itDayMicrosecond, itHourMicrosecond, itMinuteMicrosecond, itSecondMicrosecond);
  private
    FCreated: TDateTime;
    FComment: string;
    FDefiner: string;
    FEnabled: Boolean;
    FEndDateTime: TDateTime;
    FEventType: TEventType;
    FExecute: TDateTime;
    FIntervalType: TIntervalType;
    FIntervalValue: string;
    FPreserve: Boolean;
    FSourceEx: string;
    FStartDateTime: TDateTime;
    FStmt: string;
    FUpdated: TDateTime;
    function GetEvents(): TSEvents; inline;
  protected
    procedure ParseCreateEvent(const SQL: string); virtual;
    function Build(const DataSet: TMySQLQuery): Boolean; override;
    function Build(const Field: TField): Boolean; override;
    function SQLGetSource(): string; override;
  public
    procedure Assign(const Source: TSEvent); reintroduce; virtual;
    constructor Create(const ACDBObjects: TSDBObjects; const AName: string = ''); override;
    function GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string; override;
    function SQLRun(): string; virtual;
    property Created: TDateTime read FCreated write FCreated;
    property Comment: string read FComment write FComment;
    property Definer: string read FDefiner write FDefiner;
    property Enabled: Boolean read FEnabled write FEnabled;
    property EndDateTime: TDateTime read FEndDateTime write FEndDateTime;
    property Events: TSEvents read GetEvents;
    property EventType: TEventType read FEventType write FEventType;
    property Execute: TDateTime read FExecute write FExecute;
    property IntervalType: TIntervalType read FIntervalType write FIntervalType;
    property IntervalValue: string read FIntervalValue write FIntervalValue;
    property Preserve: Boolean read FPreserve write FPreserve;
    property StartDateTime: TDateTime read FStartDateTime write FStartDateTime;
    property Stmt: string read FStmt write FStmt;
    property Updated: TDateTime read FUpdated;
  end;

  TSEvents = class(TSDBObjects)
  private
    function GetEvent(Index: Integer): TSEvent;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
      Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Event[Index: Integer]: TSEvent read GetEvent; default;
  end;

  TSColumns = class(TSObjects)
  private
    FDatabase: TSDatabase;
    Names: array of array [0 .. NAME_CHAR_LEN] of Char;
    function GetColumn(Index: Integer): PChar;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
      Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; override;
    function GetCount(): Integer; override;
    function SQLGetItems(const Name: string = ''): string; override;
    property Database: TSDatabase read FDatabase;
  public
    constructor Create(const ASession: TSSession; const ADatabase: TSDatabase);
    procedure Invalidate(); override;
    property Count: Integer read GetCount;
    property Column[Index: Integer]: PChar read GetColumn; default;
  end;

  TSDatabase = class(TSObject)
  private
    FCharset: string;
    FCollation: string;
    FColumns: TSColumns;
    FEvents: TSEvents;
    FRoutines: TSRoutines;
    FTables: TSTables;
    FTriggers: TSTriggers;
    RepairTableList: TList;
    function CheckTableEvent(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
      const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
    function GetCount(): Integer;
    function GetChecked(): TDateTime;
    function GetDatabases(): TSDatabases; inline;
    function GetDataSize(): Int64;
    function GetIndexSize(): Int64;
    function GetUnusedSize(): Int64;
    function GetUpdated(): TDateTime;
    function GetValidSources(): Boolean;
    procedure ParseCreateDatabase(const SQL: string);
  protected
    function Build(const DataSet: TMySQLQuery): Boolean; override;
    function Build(const Field: TField): Boolean; override;
    procedure FreeDesktop(); override;
    function GetCreated(): TDateTime; virtual;
    function GetValid(): Boolean; override;
    function GetValidSource(): Boolean; override;
    procedure InvalidateSource(); inline;
    procedure SetName(const AName: string); override;
    function SQLAlterTable(const Table, NewTable: TSBaseTable; const EncloseFields: Boolean = True): string; virtual;
    function SQLGetSource(): string; virtual;
    function SQLTruncateTable(const Table: TSBaseTable): string; virtual;
    property ValidSources: Boolean read GetValidSources;
  public
    function AddBaseTable(const NewTable: TSBaseTable): Boolean; virtual;
    function AddEvent(const NewEvent: TSEvent): Boolean; virtual;
    function AddRoutine(const NewRoutine: TSRoutine): Boolean; virtual;
    function AddTrigger(const NewTrigger: TSTrigger): Boolean; virtual;
    function AddView(const NewView: TSView): Boolean; virtual;
    procedure Assign(const Source: TSObject); reintroduce; virtual;
    function BaseTableByName(const TableName: string): TSBaseTable; overload; virtual;
    function CheckTables(const Tables: TList): Boolean; virtual;
    function CloneEvent(const Event: TSEvent; const NewEventName: string): Boolean;
    function CloneRoutine(const Routine: TSRoutine; const NewRoutineName: string): Boolean;
    function CloneTable(const Table: TSTable; const NewTableName: string; const Data: Boolean): Boolean;
    constructor Create(const ADatabases: TSDatabases; const AName: string = ''); reintroduce; virtual;
    function DeleteObject(const DBObject: TSDBObject): Boolean; virtual;
    destructor Destroy(); override;
    function EmptyTables(const List: TList = nil): Boolean; virtual;
    function EventByName(const EventName: string): TSEvent; virtual;
    function FlushTables(const Tables: TList): Boolean; virtual;
    function FunctionByName(const FunctionName: string): TSFunction; virtual;
    procedure Invalidate(); override;
    function OptimizeTables(const Tables: TList): Boolean; virtual;
    procedure PushBuildEvents(); virtual;
    function ProcedureByName(const ProcedureName: string): TSProcedure;
    function RenameTable(const Table: TSTable; const NewTableName: string): Boolean; virtual;
    function SQLUse(): string; virtual;
    function TableByName(const TableName: string): TSTable; overload; virtual;
    function TriggerByName(const TriggerName: string): TSTrigger; virtual;
    function Update(): Boolean; overload; override;
    function Update(const Status: Boolean): Boolean; overload; virtual;
    function UpdateBaseTable(const Table, NewTable: TSBaseTable): Boolean; virtual;
    function UpdateBaseTables(const TableNames: TStringList; const ACharset, ACollation, AEngine: string; const ARowType: TSTableField.TRowType): Boolean; virtual;
    function UpdateEvent(const Event, NewEvent: TSEvent): Boolean; virtual;
    function UpdateRoutine(const Routine: TSRoutine; const NewRoutine: TSRoutine): Boolean; overload; virtual;
    function UpdateTrigger(const Trigger, NewTrigger: TSTrigger): Boolean; virtual;
    function UpdateView(const View, NewView: TSView): Boolean; virtual;
    function ViewByName(const TableName: string): TSView; overload; virtual;
    property Collation: string read FCollation write FCollation;
    property Columns: TSColumns read FColumns;
    property Count: Integer read GetCount;
    property Created: TDateTime read GetCreated;
    property DataSize: Int64 read GetDataSize;
    property Charset: string read FCharset write FCharset;
    property Checked: TDateTime read GetChecked;
    property Databases: TSDatabases read GetDatabases;
    property Events: TSEvents read FEvents;
    property IndexSize: Int64 read GetIndexSize;
    property Routines: TSRoutines read FRoutines;
    property Tables: TSTables read FTables;
    property Triggers: TSTriggers read FTriggers;
    property UnusedSize: Int64 read GetUnusedSize;
    property Updated: TDateTime read GetUpdated;
  end;

  TSSystemDatabase = class(TSDatabase)
  protected
    function GetCreated(): TDateTime; override;
  end;

  TSDatabases = class(TSObjects)
  private
    function GetDatabase(Index: Integer): TSDatabase; inline;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
      Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; override;
    procedure Delete(const AItem: TSItem; const FreeItem: Boolean = True); override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    function NameCmp(const Name1, Name2: string): Integer; override;
    property Database[Index: Integer]: TSDatabase read GetDatabase; default;
  end;

  TSVariable = class(TSEntity)
  type
    TUpdateMode = (vuGlobal, vuSession);
    TUpdateModes = set of TUpdateMode;
  private
    FValue: string;
    function GetAsBoolean(): Boolean;
    function GetAsFloat(): Double;
    function GetAsInteger(): Integer;
    function GetAsString(): string;
    function GetVariables(): TSVariables; inline;
    procedure SetAsBoolean(const AAsBoolean: Boolean);
    procedure SetAsFloat(const AAsFloat: Double);
    procedure SetAsInteger(const AAsInteger: Integer);
    procedure SetAsString(const AAsString: string);
  public
    procedure Assign(const Source: TSVariable); reintroduce; virtual;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsString: string read GetAsString write SetAsString;
    property Value: string read FValue write FValue;
    property Variables: TSVariables read GetVariables;
  end;

  TSVariables = class(TSEntities)
  private
    function GetAddress(): string;
    function GetVariable(Index: Integer): TSVariable; inline;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
      Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Address: string read GetAddress;
    property Variable[Index: Integer]: TSVariable read GetVariable; default;
  end;

  TSEngine = class(TSEntity)
  private
    FComment: string;
    FDefault: Boolean;
    function GetEngines(): TSEngines; inline;
    function GetForeignKeyAllowed(): Boolean; inline;
    function GetIsInnoDB(): Boolean; inline;
    function GetIsMerge(): Boolean; inline;
    function GetIsMyISAM(): Boolean; inline;
  protected
    property Engines: TSEngines read GetEngines;
  public
    function FieldAvailable(const MySQLFieldType: TSField.TFieldType): Boolean; virtual;
    function ApplyMySQLFieldType(const MySQLFieldType: TSField.TFieldType; const MySQLFieldSize: Integer): TSField.TFieldType; virtual;
    property Comment: string read FComment write FComment;
    property Default: Boolean read FDefault;
    property ForeignKeyAllowed: Boolean read GetForeignKeyAllowed;
    property IsInnoDB: Boolean read GetIsInnoDB;
    property IsMerge: Boolean read GetIsMerge;
    property IsMyISAM: Boolean read GetIsMyISAM;
  end;

  TSSystemEngine = class(TSEngine);

  TSEngines = class(TSEntities)
  private
    function GetDefaultEngine(): TSEngine;
    function GetEngine(Index: Integer): TSEngine; inline;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
      Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    function Update(): Boolean; override;
    property DefaultEngine: TSEngine read GetDefaultEngine;
    property Engine[Index: Integer]: TSEngine read GetEngine; default;
  end;

  TSPlugin = class(TSEntity)
  private
    function GetPlugins(): TSPlugins; inline;
  protected
    FComment: string;
  public
    property Comment: string read FComment;
    property Plugins: TSPlugins read GetPlugins;
  end;

  TSPlugins = class(TSEntities)
  private
    function GetPlugin(Index: Integer): TSPlugin;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
      Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Plugin[Index: Integer]: TSPlugin read GetPlugin; default;
  end;

  TSFieldType = class(TSItem)
  private
    FName: string;
    FHighlighted: Boolean;
    FMySQLFieldType: TSField.TFieldType;
    function GetFieldTypes(): TSFieldTypes;
  public
    function DBTypeStr(): string; virtual;
    constructor Create(const AFieldTypes: TSFieldTypes; const AMySQLFieldType: TSField.TFieldType; const ACaption: string; const AHighlighted: Boolean); reintroduce; virtual;
    property Name: string read FName;
    property FieldTypes: TSFieldTypes read GetFieldTypes;
    property Highlighted: Boolean read FHighlighted;
    property MySQLFieldType: TSField.TFieldType read FMySQLFieldType;
  end;

  TSFieldTypes = class(TSItems)
  private
    procedure Add(const AMySQLFieldType: TSField.TFieldType; const ACaption: string; const AHighlighted: Boolean);
    function GetFieldType(Index: Integer): TSFieldType;
  protected
    function FieldAvailable(const Engine: TSEngine; const MySQLFieldType: TSField.TFieldType): Boolean; virtual;
  public
    function ApplyMySQLFieldType(const Engine: TSEngine; const MySQLFieldType: TSField.TFieldType): TSField.TFieldType; virtual;
    procedure Clear(); reintroduce;
    constructor Create(const ASession: TSSession); reintroduce; virtual;
    property FieldType[Index: Integer]: TSFieldType read GetFieldType; default;
  end;

  TSCharset = class(TSEntity)
  private
    FHint: string;
    FCollation: string;
    FMaxLength: Integer;
    function GetCharsets(): TSCharsets; inline;
    function GetCodePage(): Cardinal;
    function GetDefaultCollation(): TSCollation;
  public
    property Charsets: TSCharsets read GetCharsets;
    property CodePage: Cardinal read GetCodePage;
    property Collation: string read FCollation;
    property DefaultCollation: TSCollation read GetDefaultCollation;
    property Hint: string read FHint;
    property MaxLength: Integer read FMaxLength;
  end;

  TSCharsets = class(TSEntities)
  private
    function GetCharset(Index: Integer): TSCharset;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
      Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    function Update(): Boolean; override;
    property Charset[Index: Integer]: TSCharset read GetCharset; default;
  end;

  TSCollation = class(TSEntity)
  private
    FCharset: TSCharset;
    FCompiled: Boolean;
    FDefault: Boolean;
    FHint: string;
    FId: Word;
    FSortLength: Byte;
    function GetCollations(): TSCollations; inline;
  public
    property Charset: TSCharset read FCharset;
    property Compiled: Boolean read FCompiled;
    property Default: Boolean read FDefault;
    property Hint: string read FHint;
    property Id: Word read FId;
    property SortLength: Byte read FSortLength;
    property Collations: TSCollations read GetCollations;
  end;

  TSCollations = class(TSEntities)
  private
    function GetCollation(Index: Integer): TSCollation;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
      Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Collation[Index: Integer]: TSCollation read GetCollation; default;
  end;

  TSProcess = class(TSEntity)
  private
    FCommand: string;
    FDatabaseName: string;
    FHost: string;
    FUserName: string;
    FTime: TDateTime;
    FState: string;
    FSQL: string;
    function GetThreadId(): Longword;
    procedure SetThreadId(AThreadId: Longword);
  public
    constructor Create(const ASItems: TSItems; const AName: string = ''); override;
    property Command: string read FCommand;
    property DatabaseName: string read FDatabaseName;
    property Host: string read FHost;
    property UserName: string read FUserName;
    property Time: TDateTime read FTime;
    property State: string read FState;
    property SQL: string read FSQL;
    property ThreadId: Longword read GetThreadId write SetThreadId;
  end;

  TSProcesses = class(TSEntities)
  private
    function GetAddress(): string;
    function GetProcess(Index: Integer): TSProcess;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
      Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; override;
    procedure Delete(const AProcess: TSProcess); overload;
    function GetValid(): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    function NameCmp(const Name1, Name2: string): Integer; override;
    property Address: string read GetAddress;
    property Process[Index: Integer]: TSProcess read GetProcess; default;
  end;

  TSUserRight = class
  private
    FRawPassword: string;
    FUser: TSUser;
    function GetCaption(): string;
    function GetSession(): TSSession;
    property Session: TSSession read GetSession;
  public
    DatabaseName: string;
    FieldName: string;
    FunctionName: string;
    NewPassword: string;
    ProcedureName: string;
    TableName: string;
    RAlter: Boolean;
    RAlterRoutine: Boolean;
    RCreate: Boolean;
    RCreateTableSpace: Boolean;
    RCreateTempTable: Boolean;
    RCreateRoutine: Boolean;
    RCreateUser: Boolean;
    RCreateView: Boolean;
    RDelete: Boolean;
    RDrop: Boolean;
    REvent: Boolean;
    RExecute: Boolean;
    RFile: Boolean;
    RGrant: Boolean;
    RIndex: Boolean;
    RInsert: Boolean;
    RLockTables: Boolean;
    RProcess: Boolean;
    RReferences: Boolean;
    RReload: Boolean;
    RReplClient: Boolean;
    RReplSlave: Boolean;
    RSelect: Boolean;
    RShowDatabases, RShowView, RShutdown, RSuper, RTrigger, RUpdate: Boolean;
    procedure Assign(const Source: TSUserRight);
    constructor Create(const AUser: TSUser); virtual;
    function Equals(Obj: TObject): Boolean; override;
    property Caption: string read GetCaption;
    property RawPassword: string read FRawPassword;
    property User: TSUser read FUser;
  end;

  TSUser = class(TSObject)
  private
    FConnectionsPerHour: Int64;
    FNewPassword: string;
    FQueriesPerHour: Int64;
    FRawPassword: string;
    FRights: TList;
    FUserConnections: Int64;
    FUpdatesPerHour: Int64;
    function GetHost(): string;
    function GetLogin(): string;
    function GetRight(Index: Integer): TSUserRight; inline;
    function GetRightCount(): Integer; inline;
    function GetUsers(): TSUsers; inline;
    procedure ParseGrant(const SQL: string);
  protected
    function GetCaption(): string; override;
    function GetValid(): Boolean; override;
    procedure SetName(const AName: string); override;
    function Build(const DataSet: TMySQLQuery): Boolean; override;
    function SQLGetSource(): string;
  public
    function AddRight(const NewUserRight: TSUserRight): Boolean;
    procedure Assign(const Source: TSUser); reintroduce;
    procedure Clear(); virtual;
    constructor Create(const ASItems: TSItems; const AName: string = ''); reintroduce;
    procedure DeleteRight(const UserRight: TSUserRight);
    destructor Destroy(); override;
    function IndexOf(const UserRight: TSUserRight): Integer;
    function RightByCaption(const Caption: string): TSUserRight;
    function Update(): Boolean; override;
    function UpdateRight(const UserRight,  NewUserRight: TSUserRight): Boolean;
    property ConnectionsPerHour: Int64 read FConnectionsPerHour write FConnectionsPerHour;
    property Host: string read GetHost;
    property Login: string read GetLogin;
    property NewPassword: string read FNewPassword write FNewPassword;
    property QueriesPerHour: Int64 read FQueriesPerHour write FQueriesPerHour;
    property RawPassword: string read FRawPassword write FRawPassword;
    property Rights[Index: Integer]: TSUserRight read GetRight;
    property RightCount: Integer read GetRightCount;
    property UpdatesPerHour: Int64 read FUpdatesPerHour write FUpdatesPerHour;
    property UserConnections: Int64 read FUserConnections write FUserConnections;
    property Users: TSUsers read GetUsers;
  end;

  TSUsers = class(TSObjects)
  private
    function GetAddress(): string;
    function GetUser(Index: Integer): TSUser; inline;
  protected
    function Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
      Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean; override;
    procedure Delete(const AItem: TSItem; const FreeItem: Boolean = True); override;
    function GetValid(): Boolean; override;
    function SQLGetItems(const Name: string = ''): string; override;
  public
    property Address: string read GetAddress;
    property User[Index: Integer]: TSUser read GetUser; default;
  end;

  TSConnection = class(TMySQLConnection)
  private
    FSession: TSSession;
  protected
    FMaxAllowedPacket: Integer;
    procedure DoAfterExecuteSQL(); override;
    procedure DoBeforeExecuteSQL(); override;
    procedure DoError(const AErrorCode: Integer; const AErrorMessage: string); override;
    function GetDataFileAllowed(): Boolean; override;
    function GetMaxAllowedServerPacket(): Integer; override;
    procedure SetAnsiQuotes(const AAnsiQuotes: Boolean); override;
    procedure SetCharsetClient(const ACharset: string); override;
    procedure SetCharsetResult(const ACharset: string); override;
  public
    constructor Create(const ASession: TSSession); reintroduce; virtual;
    procedure Connect(); overload;
    procedure Connect(const ALibraryType: TMySQLLibrary.TLibraryType; const ALibraryName: string; const AHost, AUser, APassword, ADatabase: string; const APort: Integer; const AAsynchron: Boolean); overload;
    function SQLUse(const DatabaseName: string): string; override;
    property Session: TSSession read FSession;
  end;

  TSQuickAccess = class(TSItems)
  type
    TItem = record
      ClassType: TClass;
      DatabaseName: string;
      Name: string;
    end;
  private
    function SearchResult(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
      const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
  public
    procedure PushBuildEvent(); virtual;
    function Step1(const Items: array of TItem): Boolean;
  end;

  TSItemSearch = class(TSItems)
  private
    FSession: TSSession;
    NeededTables: TList;
    procedure AddColumns(const DataSet: TMySQLQuery);
    procedure AddTables(const DataSet: TMySQLQuery);
    function SearchResult(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
      const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
    function SQLDatabaseNames(): string;
  public
    Comment: Boolean;
    Databases: Boolean;
    Events: Boolean;
    Fields: Boolean;
    Location: TObject;
    Name: Boolean;
    Routines: Boolean;
    Tables: Boolean;
    Text: string;
    Triggers: Boolean;
    procedure Clear(); override;
    constructor Create(const ASession: TSSession);
    destructor Destroy(); override;
    function Step1(): Boolean;
    function Step2(): Boolean;
  end;

  TSItemSearches = class(TList)
  private
    function Get(Index: Integer): TSItemSearch; inline;
  protected
    procedure Delete(const AItem: TSItem); overload;
  public
    property ItemSearch[Index: Integer]: TSItemSearch read Get; default;
  end;

  TSSession = class(TObject)
  type
    TEvent = class(TObject)
    type
      TEventType = (etItemsValid, etItemValid, etItemCreated, etItemRenamed, etItemDeleted, etDatabaseChanged, etBeforeExecuteSQL, etAfterExecuteSQL, etMonitor, etError);
    public
      Session: TSSession;
      EventType: TEventType;
      Sender: TObject;
      Items: TSItems;
      Item: TSItem;
      constructor Create(const ASession: TSSession);
    end;

    TCreateDesktop = function(const CObject: TSObject): TSObject.TDesktop of object;
    TEventProc = procedure(const AEvent: TSSession.TEvent) of object;
    TUpdate = function(): Boolean of object;
  strict private
    EventProcs: TList<TEventProc>;
    FAccount: TPAccount;
    FCharsets: TSCharsets;
    FSessions: TSSessions;
    FCollations: TSCollations;
    FColumns: TSColumns;
    FConnection: TSConnection;
    FCreateDesktop: TCreateDesktop;
    FCurrentUser: string;
    FDatabases: TSDatabases;
    FEngines: TSEngines;
    FFieldTypes: TSFieldTypes;
    FItemSearches: TSItemSearches;
    FMetadataProvider: TacEventMetadataProvider;
    FPlugins: TSPlugins;
    FProcesses: TSProcesses;
    FQuickAccess: TSQuickAccess;
    FSQLMonitor: TMySQLMonitor;
    FStartTime: TDateTime;
    FSyntaxProvider: TacMYSQLSyntaxProvider;
    FUsers: TSUsers;
    FVariables: TSVariables;
    ManualURL: string;
    StmtMonitor: TMySQLMonitor;
    procedure BuildManualURL(const DataSet: TMySQLQuery);
    procedure ConnectChange(Sender: TObject; Connecting: Boolean);
    procedure DatabaseChange(const Connection: TMySQLConnection; const NewName: string);
    procedure DoSendEvent(const AEvent: TSSession.TEvent);
    function GetAddress(): string; inline;
    function GetCaption(): string;
    function GetCharset(): string;
    function GetCollation(): string;
    function GetSQLParser(): TSQLParser; inline;
    function GetUserRights(): TSUserRight;
    function GetValid(): Boolean;
    procedure SetCreateDesktop(ACreateDesktop: TCreateDesktop);
    procedure VariableChange(const Connection: TMySQLConnection; const Name, NewValue: string);
  protected
    FInformationSchema: TSDatabase;
    FLowerCaseTableNames: Byte;
    FPerformanceSchema: TSDatabase;
    FUser: TSUser;
    FUserRequested: Boolean;
    UnparsableSQL: string;
    function BuildEvents(const DataSet: TMySQLQuery; const Filtered: Boolean = False;
      const ItemSearch: TSItemSearch = nil): Boolean;
    function BuildRoutines(const DataSet: TMySQLQuery; const Filtered: Boolean = False;
      const ItemSearch: TSItemSearch = nil): Boolean;
    function BuildTables(const DataSet: TMySQLQuery; const Filtered: Boolean = False;
      const ItemSearch: TSItemSearch = nil): Boolean;
    function BuildTriggers(const DataSet: TMySQLQuery; const Filtered: Boolean = False;
      const ItemSearch: TSItemSearch = nil): Boolean;
    function BuildUser(const DataSet: TMySQLQuery): Boolean;
    procedure MonitorLog(const Connection: TMySQLConnection; const Text: PChar; const Len: Integer; const ATraceType: TMySQLMonitor.TTraceType);
    procedure MonitorExecutedStmts(const Connection: TMySQLConnection; const Text: PChar; const Len: Integer; const ATraceType: TMySQLMonitor.TTraceType);
    procedure SendEvent(const EventType: TSSession.TEvent.TEventType; const Sender: TObject = nil; const Items: TSItems = nil; const Item: TSItem = nil); overload;
    function SessionResult(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
      const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
    property Sessions: TSSessions read FSessions;
  public
InImport: Boolean;
    function AddDatabase(const NewDatabase: TSDatabase): Boolean;
    function AddUser(const ANewUser: TSUser): Boolean;
    function ApplyIdentifierName(const AIdentifierName: string): string;
    procedure ApplyToBCEditor(const ABCEditor: TBCEditor);
    procedure GridCanEditShow(Sender: TObject);
    function CharsetByName(const CharsetName: string): TSCharset;
    function CharsetByCollation(const Collation: string): TSCharset;
    function CollationByName(const CollationName: string): TSCollation;
    constructor Create(const ASessions: TSSessions; const AAccount: TPAccount = nil); reintroduce;
    function DatabaseByName(const DatabaseName: string): TSDatabase;
    procedure DecodeInterval(const Value: string; const IntervalType: TSEvent.TIntervalType; var Year, Month, Day, Quarter, Week, Hour, Minute, Second, MSec: Word);
    function DeleteDatabase(const Database: TSDatabase): Boolean;
    function DeleteEntities(const List: TList): Boolean;
    function DeleteProcess(const Process: TSProcess): Boolean;
    destructor Destroy(); override;
    procedure EmptyDatabases(const Databases: TList);
    function EncodeInterval(const Year, Month, Day, Quarter, Week, Hour, Minute, Second, MSec: Word; var Value: string; var IntervalType: TSEvent.TIntervalType): Boolean;
    function EngineByName(const EngineName: string): TSEngine;
    function EscapeRightIdentifier(const Identifier: string; const IdentifierQuoting: Boolean = False): string;
    function EscapeUser(const User: string; const IdentifierQuoting: Boolean = False): string;
    function FieldTypeByCaption(const Text: string): TSFieldType;
    function FieldTypeByMySQLFieldType(const MySQLFieldType: TSField.TFieldType): TSFieldType;
    procedure UpdateIndexDefs(const DataSet: TMySQLQuery; const IndexDefs: TIndexDefs);
    procedure Invalidate();
    function ItemByAddress(const Address: string; const ExecuteUpdates: Boolean = False): TSItem;
    function PluginByName(const PluginName: string): TSPlugin;
    function ProcessByThreadId(const ThreadId: Longword): TSProcess;
    procedure PushBuildEvents();
    procedure RegisterEventProc(const AEventProc: TEventProc);
    function SendSQL(const SQL: string; const OnResult: TMySQLConnection.TResultEvent = nil): Boolean;
    procedure SortDBObjects(const List: TList; const Asc: Boolean = True);
    function TableName(const Name: string): string;
    function TableNameCmp(const Name1, Name2: string): Integer; inline;
    function UnescapeValue(const Value: string; const FieldType: TSField.TFieldType = mfVarChar): string; overload;
    function UnecapeRightIdentifier(const Identifier: string): string;
    procedure UnRegisterEventProc(const AEventProc: TEventProc);
    function Update(): Boolean; overload;
    function Update(const Objects: TList; const Status: Boolean = False): Boolean; overload;
    function UpdateDatabase(const Database, NewDatabase: TSDatabase): Boolean;
    function UpdateUser(const User, NewUser: TSUser): Boolean;
    function UpdateVariable(const Variable, NewVariable: TSVariable; const UpdateModes: TSVariable.TUpdateModes): Boolean;
    function UserByCaption(const Caption: string): TSUser;
    function UserByName(const UserName: string): TSUser;
    function VariableByName(const VariableName: string): TSVariable;
    property Account: TPAccount read FAccount;
    property Address: string read GetAddress;
    property Caption: string read GetCaption;
    property Charset: string read GetCharset;
    property Charsets: TSCharsets read FCharsets;
    property Collation: string read GetCollation;
    property Collations: TSCollations read FCollations;
    property Columns: TSColumns read FColumns;
    property Connection: TSConnection read FConnection;
    property CreateDesktop: TCreateDesktop read FCreateDesktop write SetCreateDesktop;
    property CurrentUser: string read FCurrentUser;
    property Databases: TSDatabases read FDatabases;
    property Engines: TSEngines read FEngines;
    property FieldTypes: TSFieldTypes read FFieldTypes;
    property InformationSchema: TSDatabase read FInformationSchema;
    property ItemSearches: TSItemSearches read FItemSearches;
    property LowerCaseTableNames: Byte read FLowerCaseTableNames;
    property MetadataProvider: TacEventMetadataProvider read FMetadataProvider;
    property PerformanceSchema: TSDatabase read FPerformanceSchema;
    property Plugins: TSPlugins read FPlugins;
    property Processes: TSProcesses read FProcesses;
    property QuickAccess: TSQuickAccess read FQuickAccess;
    property StartTime: TDateTime read FStartTime;
    property SQLMonitor: TMySQLMonitor read FSQLMonitor;
    property SQLParser: TSQLParser read GetSQLParser;
    property SyntaxProvider: TacMYSQLSyntaxProvider read FSyntaxProvider;
    property User: TSUser read FUser;
    property UserRights: TSUserRight read GetUserRights;
    property Users: TSUsers read FUsers;
    property Valid: Boolean read GetValid;
    property Variables: TSVariables read FVariables;
  end;

  TSSessions = class(TList<TSSession>)
  private
    FOnSQLError: TMySQLConnection.TErrorEvent;
  public
    function Add(const Session: TSSession): Integer;
    function SessionByAccount(const Account: TPAccount): TSSession;
    property OnSQLError: TMySQLConnection.TErrorEvent read FOnSQLError write FOnSQLError;
  end;

const
  DefaultLimit = 100;
  DefaultLimitSize = 50 * 1024;

const
  NotQuotedFieldTypes = [mfBit, mfTinyInt, mfSmallInt, mfMediumInt, mfInt, mfBigInt, mfFloat, mfDouble, mfDecimal, mfYear];
  BinaryFieldTypes = [mfBinary, mfVarBinary, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob];
  TextFieldTypes = [mfChar, mfVarChar, mfTinyText, mfText, mfMediumText, mfLongText, mfEnum, mfSet, mfJSON];
  BLOBFieldTypes = [mfTinyText, mfText, mfMediumText, mfLongText, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob];

var
  Sessions: TSSessions;

implementation {***************************************************************}

uses
  WinInet, ShLwAPI,
  Variants, SysConst, RTLConsts, Math, DateUtils, StrUtils,
  DBConsts, DBCommon,
  Consts, DBGrids,
  BCEditor.Types,
  CSVUtils, HTTPTunnel, MySQLDBGrid,
  uURI, uDeveloper;

const
  INFORMATION_SCHEMA = 'INFORMATION_SCHEMA';
  PERFORMANCE_SCHEMA = 'PERFORMANCE_SCHEMA';
  OutParameterCaption = '<OUT>';
  InParameterCaption = '<IN>';

resourcestring
  SUnknownRoutineType = 'Unknown Routine type (%s)';
  SUnknownSQLStmt = 'Unknow SQL Stmt (%s)';
  SUnknownEngineType = 'Unknown Engine type (%s)';
  SSourceParseError = 'Source code of "%s" cannot be analyzed:' + #10#10 + '%s';
  SInvalidForeignKeyChildField = 'Source code of "%s" cannot be analyzed - Field "%s" was not defined:' + #10#10 + '%s';

type
  TMCharsetTranslation = record
    OldCharset: PChar;
    NewCharset: PChar;
    NewCollation: PChar;
  end;
const
  CharsetTranslations: array[0..29] of TMCharsetTranslation = (
    (OldCharset: 'big5';       NewCharset: 'big5';   NewCollation: 'big5_chinese_ci'),
    (OldCharset: 'czech';      NewCharset: 'latin2'; NewCollation: 'latin2_czech_ci'),
    (OldCharset: 'dec8';       NewCharset: 'dec8';   NewCollation: 'dec8_swedish_ci'),
    (OldCharset: 'dos';        NewCharset: 'cp850';  NewCollation: 'cp850_general_ci'),
    (OldCharset: 'german1';    NewCharset: 'latin1'; NewCollation: 'latin1_german1_ci'),
    (OldCharset: 'hp8';        NewCharset: 'hp8';    NewCollation: 'hp8_english_ci'),
    (OldCharset: 'koi8_ru';    NewCharset: 'koi8r';  NewCollation: 'koi8r_general_ci'),
    (OldCharset: 'latin1';     NewCharset: 'latin1'; NewCollation: 'latin1_swedish_ci'),
    (OldCharset: 'latin2';     NewCharset: 'latin2'; NewCollation: 'latin2_general_ci'),
    (OldCharset: 'swe7';       NewCharset: 'swe7';   NewCollation: 'swe7_swedish_ci'),
    (OldCharset: 'usa7';       NewCharset: 'ascii';  NewCollation: 'ascii_general_ci'),
    (OldCharset: 'ujis';       NewCharset: 'ujis';   NewCollation: 'ujis_japanese_ci'),
    (OldCharset: 'sjis';       NewCharset: 'sjis';   NewCollation: 'sjis_japanese_ci'),
    (OldCharset: 'cp1251';     NewCharset: 'cp1251'; NewCollation: 'cp1251_bulgarian_ci'),
    (OldCharset: 'danish';     NewCharset: 'latin1'; NewCollation: 'latin1_danish_ci'),
    (OldCharset: 'hebrew';     NewCharset: 'hebrew'; NewCollation: 'hebrew_general_ci'),
    (OldCharset: 'cp1251';     NewCharset: 'cp1251'; NewCollation: 'cp1251_bulgarian_ci'),
    (OldCharset: 'euc_kr';     NewCharset: 'euckr';  NewCollation: 'euckr_korean_ci'),
    (OldCharset: 'estonia';    NewCharset: 'latin7'; NewCollation: 'latin7_estonian_ci'),
    (OldCharset: 'hungarian';  NewCharset: 'latin2'; NewCollation: 'latin2_hungarian_ci'),
    (OldCharset: 'koi8_ukr';   NewCharset: 'koi8u';  NewCollation: 'koi8u_ukrainian_ci'),
    (OldCharset: 'win1251ukr'; NewCharset: 'cp1251'; NewCollation: 'cp1251_ukrainian_ci'),
    (OldCharset: 'gb2312';     NewCharset: 'gb2312'; NewCollation: 'gb2312_chinese_ci'),
    (OldCharset: 'greek';      NewCharset: 'greek';  NewCollation: 'greek_general_ci'),
    (OldCharset: 'win1250';    NewCharset: 'cp1250'; NewCollation: 'cp1250_general_ci'),
    (OldCharset: 'croat';      NewCharset: 'latin2'; NewCollation: 'latin2_croatian_ci'),
    (OldCharset: 'gbk';        NewCharset: 'gbk';    NewCollation: 'gbk_chinese_ci'),
    (OldCharset: 'cp1257';     NewCharset: 'cp1257'; NewCollation: 'cp1257_lithuanian_ci'),
    (OldCharset: 'latin5';     NewCharset: 'latin5'; NewCollation: 'latin5_turkish_ci'),
    (OldCharset: 'latin1_de';  NewCharset: 'latin1'; NewCollation: 'latin1_german2_ci')
  );

function StrToMySQLRowType(const Str: string): TSTableField.TRowType;
begin
  if (StrIComp(PChar(Str), 'FIXED') = 0) then Result := mrFixed
  else if (StrIComp(PChar(Str), 'DYNAMIC') = 0) then Result := mrDynamic
  else if (StrIComp(PChar(Str), 'COMPRESSED') = 0) then Result := mrCompressed
  else if (StrIComp(PChar(Str), 'REDUNDANT') = 0) then Result := mrRedundant
  else if (StrIComp(PChar(Str), 'COMPACT') = 0) then Result := mrCompact
  else Result := mrUnknown;
end;

function StrToPartitionType(const Str: string): TSPartition.TPartitionType;
begin
  if (StrIComp(PChar(Str), 'HASH') = 0) then Result := ptHash
  else if (StrIComp(PChar(Str), 'KEY') = 0) then Result := ptKey
  else if (StrIComp(PChar(Str), 'RANGE') = 0) then Result := ptRange
  else if (StrIComp(PChar(Str), 'LIST') = 0) then Result := ptList
  else Result := ptNone;
end;

function StrToEventType(const Str: string): TSEvent.TEventType;
begin
  if (StrIComp(PChar(Str), 'ONE TIME') = 0) then Result := etSingle
  else if (StrIComp(PChar(Str), 'RECURRING') = 0) then Result := etMultiple
  else Result := etUnknown;
end;

function StrToIntervalType(const Str: string): TSEvent.TIntervalType;
begin
  if (StrIComp(PChar(Str), 'YEAR') = 0) then Result := itYear
  else if (StrIComp(PChar(Str), 'QUARTER') = 0) then Result := itQuarter
  else if (StrIComp(PChar(Str), 'MONTH') = 0) then Result := itMonth
  else if (StrIComp(PChar(Str), 'DAY') = 0) then Result := itDay
  else if (StrIComp(PChar(Str), 'HOUR') = 0) then Result := itHour
  else if (StrIComp(PChar(Str), 'MINUTE') = 0) then Result := itMinute
  else if (StrIComp(PChar(Str), 'WEEK') = 0) then Result := itWeek
  else if (StrIComp(PChar(Str), 'SECOND') = 0) then Result := itSecond
  else if (StrIComp(PChar(Str), 'MICROSECOND') = 0) then Result := itMicrosecond
  else if (StrIComp(PChar(Str), 'YEAR_MONTH') = 0) then Result := itYearMonth
  else if (StrIComp(PChar(Str), 'DAY_HOUR') = 0) then Result := itDayMinute
  else if (StrIComp(PChar(Str), 'DAY_MINUTE') = 0) then Result := itDayMinute
  else if (StrIComp(PChar(Str), 'DAY_SECOND') = 0) then Result := itDaySecond
  else if (StrIComp(PChar(Str), 'HOUR_MINUTE') = 0) then Result := itHourMinute
  else if (StrIComp(PChar(Str), 'HOUR_SECOND') = 0) then Result := itHourSecond
  else if (StrIComp(PChar(Str), 'MINUTE_SECOND') = 0) then Result := itMinuteSecond
  else if (StrIComp(PChar(Str), 'DAY_MICROSECOND') = 0) then Result := itDayMicrosecond
  else if (StrIComp(PChar(Str), 'HOUR_MICROSECOND') = 0) then Result := itHourMicrosecond
  else if (StrIComp(PChar(Str), 'MINUTE_MICROSECOND') = 0) then Result := itMinuteMicrosecond
  else if (StrIComp(PChar(Str), 'SECOND_MICROSECOND') = 0) then Result := itSecondMicrosecond
  else Result := itUnknown;
end;

function IntervalToStr(const IntervalValue: string; const IntervalType: TSEvent.TIntervalType): string;
begin
  case (IntervalType) of
    itYear: Result := 'YEAR';
    itQuarter: Result := 'QUARTER';
    itMonth: Result := 'MONTH';
    itDay: Result := 'DAY';
    itHour: Result := 'HOUR';
    itMinute: Result := 'MINUTE';
    itWeek: Result := 'WEEK';
    itSecond: Result := 'SECOND';
    itMicrosecond: Result := 'MICROSECOND';
    itYearMonth: Result := 'YEAR_MONTH';
    itDayHour: Result := 'DAY_HOUR';
    itDayMinute: Result := 'DAY_MINUTE';
    itDaySecond: Result := 'DAY_SECOND';
    itHourMinute: Result := 'HOUR_MINUTE';
    itHourSecond: Result := 'HOUR_SECOND';
    itMinuteSecond: Result := 'MINUTE_SECOND';
    itDayMicrosecond: Result := 'DAY_MICROSECOND';
    itHourMicrosecond: Result := 'HOUR_MICROSECOND';
    itMinuteMicrosecond: Result := 'MINUTE_MICROSECOND';
    itSecondMicrosecond: Result := 'SECOND_MICROSECOND';
    else Result := '';
  end;
  if (Result <> '') then
    Result := '''' + IntervalValue + ''' ' + Result;
end;

{ TSResultSet *****************************************************************}

{ TSItem **********************************************************************}

procedure TSItem.Assign(const Source: TSItem);
begin
  // Debug 2016-11-21
  if (not Assigned(Source)) then
    raise ERangeError.Create(SRangeError);

  FName := Source.Name;
end;

constructor TSItem.Create(const ASItems: TSItems; const AName: string = '');
begin
  inherited Create();

  FItems := ASItems;
  FName := AName;
end;

function TSItem.Equal(const Second: TSItem): Boolean;
begin
  Result := Assigned(Second) and (Second.ClassType = ClassType);
end;

function TSItem.GetAddress(): string;
var
  URI: TUURI;
begin
  URI := TUURI.Create(Session.Address);

  if (Self is TSDatabase) then
    URI.Database := Name
  else if (Self is TSTable) then
  begin
    URI.Database := TSTable(Self).Database.Name;
    URI.Table := Name;
    if (TSTable(Self) is TSView) then
      URI.Param['objecttype'] := 'view'
    else if (TSTable(Self) is TSSystemView) then
      URI.Param['objecttype'] := 'systemview';
  end
  else if (TObject(Self) is TSKey) then
  begin
    URI.Database := TSKey(Self).Table.Database.Name;
    URI.Table := TSKey(Self).Table.Name;
    URI.Param['objecttype'] := 'key';
    URI.Param['object'] := Name;
  end
  else if (TObject(Self) is TSBaseField) then
  begin
    URI.Database := TSBaseField(Self).Table.Database.Name;
    URI.Table := TSBaseField(Self).Table.Name;
    URI.Param['objecttype'] := 'basefield';
    URI.Param['object'] := Name;
  end
  else if (TObject(Self) is TSForeignKey) then
  begin
    URI.Database := TSForeignKey(Self).Table.Database.Name;
    URI.Table := TSForeignKey(Self).Table.Name;
    URI.Param['objecttype'] := 'foreignkey';
    URI.Param['object'] := Name;
  end
  else if (TObject(Self) is TSViewField) then
  begin
    URI.Database := TSViewField(Self).Table.Database.Name;
    URI.Table := TSViewField(Self).Table.Name;
    URI.Param['objecttype'] := 'viewfield';
    URI.Param['object'] := Name;
  end
  else if (TObject(Self) is TSProcedure) then
  begin
    URI.Database := TSProcedure(Self).Database.Name;
    URI.Param['objecttype'] := 'procedure';
    URI.Param['object'] := Name;
  end
  else if (TObject(Self) is TSFunction) then
  begin
    URI.Database := TSFunction(Self).Database.Name;
    URI.Param['objecttype'] := 'function';
    URI.Param['object'] := Name;
  end
  else if (TObject(Self) is TSEvent) then
  begin
    URI.Database := TSEvent(Self).Database.Name;
    URI.Param['objecttype'] := 'event';
    URI.Param['object'] := Name;
  end
  else if (TObject(Self) is TSTrigger) then
  begin
    URI.Database := TSTrigger(Self).Database.Name;
    URI.Table := TSTrigger(Self).TableName;
    URI.Param['objecttype'] := 'trigger';
    URI.Param['object'] := Name;
  end;

  Result := URI.Address;
  URI.Free();
end;

function TSItem.GetCaption(): string;
begin
  Result := Name;
end;

function TSItem.GetIndex(): Integer;
begin
  Result := Items.IndexOf(Self);
end;

function TSItem.GetSession(): TSSession;
begin
  Result := Items.Session;
end;

procedure TSItem.SetName(const AName: string);
var
  NewIndex: Integer;
begin
  Assert(AName <> '');

  if (AName <> FName) then
  begin
    if (Items.InsertIndex(AName, NewIndex) and (Index >= 0)) then
    begin
      if (NewIndex > Index) then
        Dec(NewIndex);

      Items.Move(Index, NewIndex);
    end;
    FName := AName;
  end;
end;

{ TSDBItems *******************************************************************}

procedure TSItems.Clear();
var
  I: Integer;
begin
  for I := 0 to TList(Self).Count - 1 do
    TSItem(Items[I]).Free();

  inherited;
end;

constructor TSItems.Create(const ASession: TSSession);
begin
  // Debug 2017-05-13
  Assert(Assigned(ASession));

  inherited Create();

  FSession := ASession;
end;

procedure TSItems.Delete(const AItem: TSItem; const FreeItem: Boolean = True);
begin
  Delete(IndexOf(AItem));

  AItem.Free();
end;

destructor TSItems.Destroy();
begin
  Clear();

  inherited;
end;

function TSItems.GetItem(Index: Integer): TSItem;
begin
  Assert(TObject(Items[Index]) is TSItem);

  Result := TSItem(Items[Index]);
end;

function TSItems.GetCount(): Integer;
begin
  Result := TList(Self).Count;
end;

function TSItems.IndexByName(const Name: string): Integer;
type
  Tstrcmp = function (lpString1, lpString2: PWideChar): Integer; stdcall;
var
  Left: Integer;
  Mid: Integer;
  Right: Integer;
  strcmp: Tstrcmp;
begin
  Result := -1;

  if (((Self is TSTables) or (Self is TSDatabases)) and (Session.LowerCaseTableNames = 0)) then
    strcmp := lstrcmp
  else
    strcmp := lstrcmpi;

  Left := 0;
  Right := Count - 1;
  while (Left <= Right) do
  begin
    Mid := (Right - Left) div 2 + Left;
    case (strcmp(PChar(Item[Mid].Name), PChar(Name))) of
      -1: Left := Mid + 1;
      0: begin Result := Mid; break; end;
      1: Right := Mid - 1;
    end;
  end;
end;

function TSItems.InsertIndex(const Name: string; out Index: Integer): Boolean;
type
  Tstrcmp = function (lpString1, lpString2: PWideChar): Integer; stdcall;
var
  Left: Integer;
  Mid: Integer;
  Right: Integer;
  strcmp: Tstrcmp;
begin
  Assert((Self is TSKeys) or (Name <> ''));

  Result := True;

  if (((Self is TSTables) or (Self is TSDatabases)) and (Session.LowerCaseTableNames = 0)) then
    strcmp := lstrcmp
  else
    strcmp := lstrcmpi;

  if ((TList(Self).Count = 0) or (strcmp(PChar(Item[Count - 1].Name), PChar(Name)) < 0)) then
    Index := TList(Self).Count
  else
  begin
    Left := 0;
    Right := TList(Self).Count - 1;
    while (Left <= Right) do
    begin
      Mid := (Right + Left) div 2;
      case (strcmp(PChar(Item[Mid].Name), PChar(Name))) of
        -1: begin Left := Mid + 1;  Index := Mid + 1; end;
        0: begin Result := False; Index := Mid; break; end;
        1: begin Right := Mid - 1; Index := Mid; end;
      end;
    end;
  end;
end;

function TSItems.NameCmp(const Name1, Name2: string): Integer;
begin
  Result := lstrcmpi(PChar(Name1), PChar(Name2));
end;

{ TSEntity ********************************************************************}

function TSEntity.GetEntities(): TSEntities;
begin
  Assert(Items is TSEntities);

  Result := TSEntities(Items);
end;

{ TSEntities ******************************************************************}

function TSEntities.Add(const AEntity: TSEntity; const SendEvent: Boolean = False): Integer;
begin
  if (InsertIndex(AEntity.Name, Result)) then
    if (Result < TList(Self).Count) then
      TList(Self).Insert(Result, AEntity)
    else
      TList(Self).Add(AEntity);
end;

function TSEntities.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
begin
  FValid := FValid or not Filtered;

  Result := False;
end;

procedure TSEntities.Clear();
begin
  inherited;

  FValid := False;
end;

constructor TSEntities.Create(const ASession: TSSession);
begin
  inherited Create(ASession);

  FValid := False;
end;

function TSEntities.GetValid(): Boolean;
begin
  Result := FValid;
end;

procedure TSEntities.Invalidate();
begin
  FValid := False;
end;

procedure TSEntities.PushBuildEvent(const Sender: TObject);
begin
  Session.SendEvent(etItemsValid, Sender, Self);
end;

function TSEntities.Update(): Boolean;
var
  Objects: TList;
begin
  Objects := TList.Create();
  Objects.Add(Self);
  Result := Session.Update(Objects);
  Objects.Free();
end;

{ TSObject.TDesktop ***********************************************************}

constructor TSObject.TDesktop.Create(const ASObject: TSObject);
begin
  inherited Create();

  FSObject := ASObject;
end;

{ TSObject ********************************************************************}

procedure TSObject.Assign(const Source: TSObject);
begin
  Assert(Assigned(Source));

  inherited Assign(TSItem(Source));

  FSource := Source.Source;
  FValidSource := Source.ValidSource;
end;

function TSObject.Build(const Field: TField): Boolean;
var
  Len: Integer;
  RBS: RawByteString;
  SQL: string;
begin
  if (((Self is TSBaseTable) or (Self is TSDatabase))
    and (40100 <= Session.Connection.MySQLVersion) and (Session.Connection.MySQLVersion < 50000)
    and (Field.DataType in BinaryDataTypes)) then
  begin
    // In MySQL 4.1, SHOW CREATE TABLE / DATABASE will be answered in a binary field
    RBS := Field.AsAnsiString;
    Len := AnsiCharToWideChar(Session.Connection.CodePageResult, PAnsiChar(RBS), Length(RBS), nil, 0);
    SetLength(SQL, Len);
    AnsiCharToWideChar(Session.Connection.CodePageResult, PAnsiChar(RBS), Length(RBS), PChar(SQL), Len);
  end
  else
    SQL := Field.AsString;

  SetSource(SQL);

  Result := False;

  if ((GetUTCTime() <= IncDay(GetCompileTime(), 7)) and (SQL <> '')) then
  begin
    if (not Session.SQLParser.ParseSQL(SQL)) then
      Session.UnparsableSQL := Session.UnparsableSQL
        + '# Build()' + #13#10
        + '# Error: ' + Session.SQLParser.ErrorMessage + #13#10
        + Trim(SQL) + #13#10 + #13#10 + #13#10;
    Session.SQLParser.Clear();
  end;
end;

constructor TSObject.Create(const AItems: TSItems; const AName: string = '');
begin
  inherited;

  FOriginalName := AName;

  FSource := '';
  FValidSource := False;

  FDesktop := nil;
end;

destructor TSObject.Destroy();
begin
  if (Assigned(FDesktop)) then
    FDesktop.Free();

  inherited;
end;

procedure TSObject.FreeDesktop();
begin
  if (Assigned(FDesktop)) then
    FreeAndNil(FDesktop);
end;

function TSObject.GetDesktop(): TDesktop;
begin
  if (not Assigned(FDesktop) and Assigned(Session.CreateDesktop)) then
    FDesktop := Session.CreateDesktop(Self);

  Result := FDesktop;
end;

function TSObject.GetObjects(): TSObjects;
begin
  Assert(Items is TSObjects);

  Result := TSObjects(Items);
end;

function TSObject.GetValid(): Boolean;
begin
  Result := ValidSource;
end;

function TSObject.GetValidSource(): Boolean;
begin
  Result := FValidSource;
end;

procedure TSObject.Invalidate();
begin
  FSource := '';
  FValidSource := False;
end;

procedure TSObject.SetName(const AName: string);
begin
  if (AName <> FName) then
  begin
    inherited;

    FValidSource := False;
    FSource := '';

    if (FOriginalName <> '') then
    begin
      if (Self is TSDBObject) then
        Session.SendEvent(etItemRenamed, TSDBObject(Self).Database, Objects, Self)
      else
        Session.SendEvent(etItemRenamed, Session, Objects, Self);

      FOriginalName := AName;
    end;
  end;
end;

procedure TSObject.SetSource(const ASource: string);
begin
  if ((Pos(#13#10, ASource) = 0) and (Pos(#10, ASource) > 0)) then
    FSource := ReplaceStr(ASource, #10, #13#10)
  else
    FSource := ASource;
  if ((FSource <> '') and (FSource[Length(FSource)] <> ';')) then
    FSource := FSource + ';' + #13#10;

  FValidSource := True;
end;

function TSObject.Update(): Boolean;
begin
  if (not (Self is TSDatabase)) then
    raise EAbstractError.Create(SAbstractError)
  else
    Result := TSDatabase(Self).Update();
end;

{ TSObjects *******************************************************************}

function TSObjects.Add(const AEntity: TSEntity; const SendEvent: Boolean): Integer;
begin
  Assert(AEntity is TSObject);

  Result := inherited;

  if ((Result >= 0) and SendEvent) then
    Session.SendEvent(etItemCreated, Session, Self, AEntity);
end;

procedure TSObjects.Invalidate();
var
  I: Integer;
begin
  inherited;

  for I := 0 to Count - 1 do
    TSObject(Items[I]).Invalidate();
end;

{ TSReference *****************************************************************}

constructor TSReference.Create(const AReferences: TSReferences; const ADatabaseName: string;
  const ADBObjectClass: TClass; const ADBObjectName: string);
begin
  inherited Create();

  FReferences := AReferences;
  FDatabaseName := ADatabaseName;
  FDBObjectClass := ADBObjectClass;
  FDBObjectName := ADBObjectName;
end;

function TSReference.GetDBObject(): TSDBObject;
var
  Database: TSDatabase;
begin
  Database := Session.DatabaseByName(FDatabaseName);

  if (not Assigned(Database)) then
    Result := nil
  else if (FDBObjectClass = TSTable) then
    Result := Database.TableByName(FDBObjectName)
  else if (FDBObjectClass = TSProcedure) then
    Result := Database.ProcedureByName(FDBObjectName)
  else if (FDBObjectClass = TSFunction) then
    Result := Database.FunctionByName(FDBObjectName)
  else
    raise ERangeError.Create(SRangeError);
end;

function TSReference.GetSession(): TSSession;
begin
  Result := FReferences.Session;
end;

{ TSReferences ****************************************************************}

function TSReferences.Add(Item: Pointer): Integer;
var
  I: Integer;
  Reference: TSReference;
begin
  Assert(TObject(Item) is TSReference);

  Reference := TSReference(Item);

  if (Reference.DBObject = DBObject) then
    FreeAndNil(Reference)
  else
    for I := 0 to Count - 1 do
      if (Reference.DBObject = References[I].DBObject) then
      begin
        FreeAndNil(Reference);
        break;
      end;

  if (not Assigned(Reference)) then
    Result := -1
  else
    Result := TList(Self).Add(Reference);
end;

procedure TSReferences.Clear();
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TSReference(Items[I]).Free();

  inherited;
end;

constructor TSReferences.Create(const ADBObject: TSDBObject);
begin
  inherited Create();

  FDBObject := ADBObject;
end;

function TSReferences.GetReference(Index: Integer): TSReference;
begin
  Result := TSReference(Items[Index]);
end;

function TSReferences.GetSession(): TSSession;
begin
  Result := FDBObject.Session;
end;

{ TSDependenciesSearch ********************************************************}

function TSDependenciesSearch.BuildBaseTableReferences(const DataSet: TMySQLQuery): Boolean;
var
  DatabaseName: string;
  TableName: string;
begin
  if (not DataSet.IsEmpty()) then
    repeat
      DatabaseName := DataSet.FieldByName('CONSTRAINT_SCHEMA').AsString;
      TableName := DataSet.FieldByName('TABLE_NAME').AsString;

      if (Session.Databases.NameCmp(DatabaseName, Database.Name) = 0)
        and Assigned(Database.BaseTableByName(TableName)) then
        Database.BaseTableByName(TableName).AddReference(TSBaseTable(DBObject));
    until (not DataSet.FindNext());

  Result := False;
end;

constructor TSDependenciesSearch.Create(const ADBObject: TSDBObject);
begin
  inherited Create();

  FDBObject := ADBObject;
end;

function TSDependenciesSearch.GetDatabase(): TSDatabase;
begin
  Result := DBObject.Database;
end;

function TSDependenciesSearch.GetSession(): TSSession;
begin
  Result := DBObject.Session;
end;

function TSDependenciesSearch.GetValid(): Boolean;
var
  I: Integer;
begin
  Result := True;

  if (DBObject is TSBaseTable) then
    if (Session.Connection.MySQLVersion < 50116) then
    begin
      for I := 0 to Database.Tables.Count - 1 do
        if (Database.Tables[I] is TSBaseTable) then
          Result := Result and Database.Tables[I].ValidSource;
    end
    else
      Result := False;

  for I := 0 to Database.Tables.Count - 1 do
    if (Database.Tables[I] is TSView) then
      Result := Result and Database.Tables[I].ValidSource;

  if (Assigned(Database.Routines)) then
    for I := 0 to Database.Routines.Count - 1 do
      Result := Result and Database.Routines[I].ValidSource;

  if (Assigned(Database.Triggers)) then
    for I := 0 to Database.Triggers.Count - 1 do
      Result := Result and Database.Triggers[I].ValidSource;

  if (Assigned(Database.Events)) then
    for I := 0 to Database.Events.Count - 1 do
      Result := Result and Database.Events[I].ValidSource;
end;

function TSDependenciesSearch.SQLGetReferences(): string;
var
  I: Integer;
  SQL: string;
  TableCount: Integer;
begin
  if ((DBObject is TSEvent) or (DBObject is TSTrigger)) then
    raise EAbstractError.Create(SAbstractError);

  SQL := '';

  if (DBObject is TSBaseTable) then
    if (Session.Connection.MySQLVersion < 50116) then
    begin
      for I := 0 to Database.Tables.Count - 1 do
        if (not Database.Tables[I].ValidSource
          and (Database.Tables[I] is TSBaseTable)) then
          SQL := SQL + Database.Tables[I].SQLGetSource();
    end
    else
    begin
      TableCount := 0;
      for I := 0 to Database.Tables.Count - 1 do
        if ((Database.Tables[I] is TSBaseTable)
          and (Database.Tables[I] <> DBObject)
          and not Database.Tables[I].ValidSource
          and (not Assigned(Database.Tables[I].References) or not Database.Tables[I].ValidSource)) then
          Inc(TableCount);

      if (TableCount > 0) then
      begin
        SQL := SQL
          + 'SELECT * FROM '
          + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('REFERENTIAL_CONSTRAINTS')
          + ' WHERE ' + Session.Connection.EscapeIdentifier('UNIQUE_CONSTRAINT_SCHEMA') + ' = ' + SQLEscape(Database.Name)
          + ' AND ' + Session.Connection.EscapeIdentifier('REFERENCED_TABLE_NAME') + ' = ' + SQLEscape(DBObject.Name)
          + ' AND ' + Session.Connection.EscapeIdentifier('CONSTRAINT_SCHEMA') + ' = ' + SQLEscape(Database.Name) + ';' + #13#10;
      end;
    end;

  if ((DBObject is TSTable) or (DBObject is TSFunction)) then
    for I := 0 to Database.Tables.Count - 1 do
      if ((Database.Tables[I] is TSView)
        and not Database.Tables[I].ValidSource) then
        SQL := SQL + Database.Tables[I].SQLGetSource();

  if (Assigned(Database.Routines)) then
    for I := 0 to Database.Routines.Count - 1 do
      if (not Database.Routines[I].ValidSource) then
        SQL := SQL + Database.Routines[I].SQLGetSource();

  if (Assigned(Database.Triggers)) then
    for I := 0 to Database.Triggers.Count - 1 do
      if (not Database.Triggers[I].ValidSource
        and (not (DBObject is TSBaseTable) or (Database.Tables.NameCmp(Database.Triggers[I].TableName, DBObject.Name) <> 0))) then
        SQL := SQL + Database.Triggers[I].SQLGetSource();

  if (Assigned(Database.Events)) then
    for I := 0 to Database.Events.Count - 1 do
      if (not Database.Events[I].ValidSource) then
        SQL := SQL + Database.Events[I].SQLGetSource();

  Result := SQL;
end;

{ TSDBObject ******************************************************************}

procedure TSDBObject.Assign(const Source: TSObject);
begin
  Assert(Assigned(Source) and (Source is TSDBObject));

  inherited;

  if (not Assigned(FDatabase)) then FDatabase := TSDBObject(Source).Database;

  if (TSDBObject(Source).Database <> Database) then
  begin
    if (Session.SQLParser.ParseSQL(FSource)) then
      FSource := RemoveDatabaseName(Session.SQLParser.FirstStmt, TSDBObject(Source).Database.Name, Session.LowerCaseTableNames = 0);
    Session.SQLParser.Clear();
  end;
end;

function TSDBObject.Build(const Field: TField): Boolean;
begin
  Result := inherited;

  if (not (Self is TSBaseTable)) then
    SetReferences(Source);
end;

procedure TSDBObject.Clear();
begin
  References.Clear();

  inherited;
end;

constructor TSDBObject.Create(const ADBObjects: TSDBObjects; const AName: string = '');
begin
  inherited Create(ADBObjects, AName);

  FDatabase := ADBObjects.Database;

  FReferences := TSReferences.Create(Self);
  FDependendciesSearch := TSDependenciesSearch.Create(Self);
end;

destructor TSDBObject.Destroy();
begin
  FReferences.Free();
  FDependendciesSearch.Free();

  inherited;
end;

function TSDBObject.GetDBObjects(): TSDBObjects;
begin
  Assert(Items is TSDBObjects);

  Result := TSDBObjects(Items);
end;

procedure TSDBObject.Invalidate();
begin
  References.Clear();

  inherited;
end;

procedure TSDBObject.PushBuildEvent(const ItemsEvents: Boolean = True);
begin
  if (Valid) then
  begin
    if (ItemsEvents) then
      Session.SendEvent(etItemsValid, Database, Items);
    Session.SendEvent(etItemValid, Database, Items, Self);
  end;
end;

procedure TSDBObject.SetDatabase(const ADatabase: TSDatabase);
begin
  if (ADatabase <> FDatabase) then
  begin
    Entities.Delete(Self, False);
    if (Self is TSTable) then
      FItems := ADatabase.Tables
    else if (Self is TSRoutine) then
      FItems := ADatabase.Routines
    else if (Self is TSRoutine) then
      FItems := ADatabase.Routines
    else if (Self is TSTrigger) then
      FItems := ADatabase.Triggers
    else
      raise ERangeError.Create(SRangeError);
    TSEntities(FItems).Add(Self, True);
    FDatabase := ADatabase;
  end;
end;

procedure TSDBObject.SetReferences(const SQL: string);
var
  DatabaseName: string;
  FunctionName: string;
  PreviousToken1: TSQLParser.PToken;
  PreviousToken2: TSQLParser.PToken;
  Token: TSQLParser.PToken;
  S: string;
begin
  References.Clear();

  if (Session.SQLParser.ParseSQL(SQL) and Assigned(Session.SQLParser.FirstStmt)) then
  begin
    try
      PreviousToken1 := nil; PreviousToken2 := nil;
      Token := Session.SQLParser.FirstTokenAll;
      while (Assigned(Token)) do
      begin
        if (Token^.DbIdentType = ditTable) then
        begin
          if ((PreviousToken1^.OperatorType <> otDot) or (PreviousToken2^.DbIdentType <> ditDatabase)) then
            DatabaseName := Database.Name
          else
            DatabaseName := PreviousToken2^.AsString;
          References.Add(TSReference.Create(References, DatabaseName, TSTable, Token^.AsString));
        end
        else if ((Token^.DbIdentType = ditProcedure)) then
        begin
          if ((PreviousToken1^.OperatorType <> otDot) or (PreviousToken2^.DbIdentType <> ditDatabase)) then
            DatabaseName := Database.Name
          else
            DatabaseName := PreviousToken2^.AsString;
          References.Add(TSReference.Create(References, DatabaseName, TSProcedure, Token^.AsString));
        end
        else if (Token^.DbIdentType = ditFunction) then
        begin
          if ((PreviousToken1^.OperatorType <> otDot) or (PreviousToken2^.DbIdentType <> ditDatabase)) then
            DatabaseName := Database.Name
          else
            DatabaseName := PreviousToken2^.AsString;
          FunctionName := Token^.AsString;
          if ((PreviousToken2^.DbIdentType = ditDatabase) or (Session.SQLParser.FunctionList.IndexOf(FunctionName) < 0)) then
            References.Add(TSReference.Create(References, DatabaseName, TSFunction, Token^.AsString));
        end;

        PreviousToken2 := PreviousToken1;
        PreviousToken1 := Token;
        if (Token = Session.SQLParser.FirstStmt^.LastToken) then
          Token := nil
        else
          Token := Token^.NextToken;
      end;
    except
      on E: Exception do
        raise Exception.CreateFMT(E.Message + ' (Database: %s, Source: %s)', [Database.Name, S]);
    end;
  end;
  Session.SQLParser.Clear();
end;

function TSDBObject.Update(): Boolean;
var
  List: TList;
begin
  List := TList.Create();
  List.Add(Self);
  Result := Session.Update(List);
  List.Free();
end;

{ TSDBObjects *****************************************************************}

function TSDBObjects.Add(const AEntity: TSEntity; const SendEvent: Boolean = False): Integer;
begin
  Assert(AEntity is TSObject);

  if (InsertIndex(AEntity.Name, Result)) then
    if (Result < TList(Self).Count) then
      TList(Self).Insert(Result, AEntity)
    else
      TList(Self).Add(AEntity);

  if ((Result >= 0) and SendEvent) then
  begin
    Session.SendEvent(etItemValid, Session, Database.Databases, Database);
    Session.SendEvent(etItemCreated, Database, Self, AEntity);
  end;
end;

constructor TSDBObjects.Create(const ADatabase: TSDatabase);
begin
  inherited Create(ADatabase.Session);

  FDatabase := ADatabase;
end;

procedure TSDBObjects.Delete(const AItem: TSItem; const FreeItem: Boolean = True);
begin
  Assert(AItem is TSDBObject);

  Session.SendEvent(etItemDeleted, Database, Self, AItem);

  Delete(IndexOf(AItem));

  Session.SendEvent(etItemsValid, Session, Session.Databases);

  if (FreeItem) then
    AItem.Free();
end;

{ TSKeyColumn *****************************************************************}

procedure TSKeyColumn.Assign(const Source: TSKeyColumn);
begin
  Field := IndexColumns.Key.Table.FieldByName(Source.Field.Name);
  Length := Source.Length;
end;

constructor TSKeyColumn.Create(const AKeyColumns: TSKeyColumns);
begin
  inherited Create();

  FKeyColumns := AKeyColumns;

  Ascending := True;
  Field := nil;
  Length := 0;
end;

function TSKeyColumn.Equal(const Second: TSKeyColumn): Boolean;
begin
  Result := Assigned(Second) and (ClassType = Second.ClassType);

  Result := Result and (lstrcmpi(PChar(Field.Name), PChar(Second.Field.Name)) = 0);
  Result := Result and (Length = Second.Length);
end;

{ TSIndexColumns **************************************************************}

procedure TSKeyColumns.AddColumn(const NewColumn: TSKeyColumn);
begin
  Add(TSKeyColumn.Create(Self));
  Column[TList(Self).Count - 1].Assign(NewColumn);
end;

constructor TSKeyColumns.Create(const AKey: TSKey);
begin
  inherited Create(AKey.Session);

  FKey := AKey;
end;

procedure TSKeyColumns.DeleteColumn(const AColumn: TSKeyColumn);
begin
  AColumn.Free();
  Delete(IndexOf(AColumn));
end;

function TSKeyColumns.KeyByField(const AField: TSTableField): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to Count - 1 do
    if (AField = Column[I].Field) then
      Result := I;
end;

function TSKeyColumns.GetColumn(Index: Integer): TSKeyColumn;
begin
  Result := TSKeyColumn(Items[Index]);
end;

{ TSIndex *********************************************************************}

procedure TSKey.Assign(const Source: TSKey);
var
  I: Integer;
begin
  inherited Assign(Source);

  FOriginalName := Source.OriginalName;

  BlockSize := Source.BlockSize;
  Created := Source.Created;
  Columns.Clear();
  for I := 0 to Source.Columns.Count - 1 do
    Columns.AddColumn(Source.Columns[I]);
  Comment := Source.Comment;
  Fulltext := Source.Fulltext;
  IndexType := Source.IndexType;
  PrimaryKey := Source.PrimaryKey;
  Unique := Source.Unique;
end;

function TSKey.ColumnByField(const AField: TSBaseField): TSKeyColumn;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Columns.Count - 1 do
    if (Columns.Column[I].Field = AField) then
      Result := Columns.Column[I];
end;

function TSKey.ColumnByFieldName(const AFieldName: string): TSKeyColumn;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Columns.Count - 1 do
    if (Assigned(Columns[I]) and (lstrcmpi(PChar(Columns[I].Field.Name), PChar(AFieldName)) = 0)) then
      Result := Columns.Column[I];
end;

constructor TSKey.Create(const AKeys: TSKeys; const AName: string = '');
begin
  inherited Create(AKeys, AName);

  FColumns := TSKeyColumns.Create(Self);
  Clear();

  FOriginalName := AName;
end;

procedure TSKey.Clear();
begin
  Created := False;

  BlockSize := 0;
  if (Assigned(FColumns)) then
    FColumns.Clear();
  Comment := '';
  Fulltext := False;
  PrimaryKey := False;
  Unique := False;
end;

destructor TSKey.Destroy();
begin
  Clear();

  FColumns.Free();

  inherited;
end;

function TSKey.GetCaption(): string;
begin
  if (PrimaryKey) then
    Result := Preferences.LoadStr(154)
  else
    Result := Name;
end;

function TSKey.GetKeys(): TSKeys;
begin
  Assert(Items is TSKeys);

  Result := TSKeys(Items);
end;

procedure TSKey.GetSortDef(var SortDef: TIndexDef);
var
  I: Integer;
begin
  SortDef.Name := Name;
  SortDef.Fields := '';
  SortDef.DescFields := '';
  SortDef.Options := [];

  for I := 0 to Columns.Count - 1 do
  begin
    if (SortDef.Fields <> '') then SortDef.Fields := SortDef.Fields + ';';
    SortDef.Fields := SortDef.Fields + Columns[I].Field.Name;
    if (not Columns[I].Ascending) then
    begin
      if (SortDef.Fields <> '') then SortDef.DescFields := SortDef.DescFields + ';';
      SortDef.DescFields := SortDef.DescFields + Columns[I].Field.Name;
    end;
  end;
end;

function TSKey.GetTable(): TSBaseTable;
begin
  Result := Keys.Table;
end;

function TSKey.Equal(const Second: TSKey): Boolean;
var
  I: Integer;
begin
  Result := inherited Equal(Second);

  Result := Result and (lstrcmpi(PChar(Name), PChar(Second.Name)) = 0);
  Result := Result and (Columns.Count = Second.Columns.Count);
  for I := 0 to Columns.Count - 1 do
  begin
    Result := Result and (lstrcmpi(PChar(Columns[I].Field.OriginalName), PChar(Second.Columns[I].Field.OriginalName)) = 0);
    Result := Result and (Columns[I].Length = Second.Columns[I].Length);
  end;

  Result := Result and (BlockSize = Second.BlockSize);
  Result := Result and (Comment = Second.Comment);
  Result := Result and (Fulltext = Second.Fulltext);
  Result := Result and (PrimaryKey = Second.PrimaryKey);
  Result := Result and (Unique = Second.Unique);
end;

procedure TSKey.SetName(const AName: string);
begin
  FName := AName;
end;

{ TIndices ********************************************************************}

procedure TSKeys.Assign(const Source: TSKeys);
var
  I: Integer;
begin
  Clear();

  for I := 0 to Source.Count - 1 do
  begin
    AddKey(Source.Key[I]);
    Key[I].Created := Source.Key[I].Created;
    Key[I].FOriginalName := Source.Key[I].OriginalName;
  end;
end;

function TSKeys.AddKey(const NewKey: TSKey): Integer;
begin
  if (NewKey.PrimaryKey) then
    Result := 0
  else
    Result := Count;

  Insert(Result, TSKey.Create(Self));
  Key[Result].Assign(NewKey);
  Key[Result].FOriginalName := '';
  Key[Result].Created := True;
end;

constructor TSKeys.Create(const ATable: TSBaseTable);
begin
  inherited Create(ATable.Session);

  FTable := ATable;

  FValid := False;
end;

procedure TSKeys.Delete(const AKey: TSKey);
var
  I: Integer;
begin
  if (AKey.PrimaryKey) then
    for I := 0 to Table.Fields.Count - 1 do
      if (Table.Fields[I] is TSBaseField) then
        TSBaseField(Table.Fields[I]).AutoIncrement := False;

  Session.SendEvent(etItemDeleted, Table, Self, AKey);

  Delete(IndexOf(AKey));

  AKey.Free();
end;

function TSKeys.GetKey(Index: Integer): TSKey;
begin
  Result := TSKey(Items[Index]);
end;

function TSKeys.GetPrimaryKey(): TSKey;
begin
  if ((Count = 0) or (Key[0].Name <> '')) then
    Result := nil
  else
    Result := Key[0];
end;

procedure TSKeys.Invalidate();
begin
  FValid := False;
end;

{ TSField *********************************************************************}

procedure TSField.Assign(const Source: TSField);
begin
  Assert(Source is TSField);

  inherited Assign(Source);

  Charset := Source.Charset;
  Collation := Source.Collation;
  Decimals := Source.Decimals;
  Expression := Source.Expression;
  FieldKind := Source.FieldKind;
  FieldType := Source.FieldType;
  Elements := TSTableField(Source).Elements;
  National := TSTableField(Source).National;
  Size := Source.Size;
  Stored := Source.Stored;
  Unsigned := TSTableField(Source).Unsigned;
end;

procedure TSField.Clear();
begin
  Charset := '';
  Collation := '';
  Decimals := 0;
  Expression := '';
  FieldKind := mkUnknown;
  FieldType := mfUnknown;
  SetLength(Elements, 0);
  FName := '';
  National := False;
  Size := 0;
  Stored := msUnknown;
  Unsigned := False;
end;

constructor TSField.Create(const AFieldTypes: TSFieldTypes; const AName: string = '');
begin
  inherited Create(nil, AName);

  FFieldTypes := AFieldTypes;
end;

function TSField.DBTypeStr(): string;
var
  I: Integer;
begin
  Result := '';

  if (National and (Session.Connection.MySQLVersion < 40101)) then
    Result := Result + 'national ';

  // Debug 2017-01-20
  if (not Assigned(Session.FieldTypeByMySQLFieldType(FieldType))) then
    raise ERangeError.Create('FieldType: ' + IntToStr(Ord(FieldType)));

  Result := Result + Session.FieldTypeByMySQLFieldType(FieldType).DBTypeStr();

  if (FieldType in [mfEnum, mfSet]) then
  begin
    Result := Result + '(';
    for I := 0 to Length(Elements) - 1 do
    begin
      if (I > 0) then Result := Result + ',';
      Result := Result + SQLEscape(Elements[I]);
    end;
    Result := Result + ')';
  end
  else if ((FieldType in [mfFloat, mfDouble, mfDecimal]) and (Size > 0)) then
    Result := Result + '(' + IntToStr(Size) + ',' + IntToStr(Decimals) + ')'
  else if (FieldType in [mfChar, mfVarChar, mfBinary, mfVarBinary]) then
    Result := Result + '(' + IntToStr(Size) + ')'
  else if ((FieldType in [mfTime, mfDateTime, mfTimeStamp]) and (Size > 0) and (Session.Connection.MySQLVersion >= 50604)) then
    Result := Result + '(' + IntToStr(Size) + ')'
  else if (FieldType in [mfTinyText, mfText, mfMediumText, mfLongText, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob]) then
  else if (FieldType in [mfGeometry, mfPoint, mfLineString, mfPolygon, mfMultiPoint,  mfMultiLineString, mfMultiPolygon, mfGeometryCollection]) then
  else if (FieldType in [mfDate, mfDateTime, mfTime]) then
  else if (FieldType in [mfTimeStamp]) then
    if (Session.Connection.MySQLVersion < 40100) then
      Result := Result + '(' + IntToStr(Size) + ')'
    else
  else
    if (Size > 0) then Result := Result + '(' + IntToStr(Size) + ')';

  if (FieldType in [mfTinyInt, mfSmallInt, mfMediumInt, mfInt, mfBigInt, mfFloat, mfDouble, mfDecimal]) then
    if (Unsigned) then Result := Result + ' unsigned';
end;

function TSField.Equal(const Second: TSField): Boolean;
begin
  Result := inherited Equal(Second);

  Result := Result and (National = Second.National);
end;

function TSField.EscapeValue(const Value: string): string;
begin
  if (FieldType = mfBit) then
    if (Value = '') then Result := 'NULL' else Result := 'b''' + Value + ''''
  else if (FieldType in NotQuotedFieldTypes) then
    if (Value = '') then Result := 'NULL' else Result := Value
  else if (FieldType in BinaryFieldTypes) then
    Result := SQLEscapeBin(Value, Session.Connection.MySQLVersion <= 40000)
  else
    Result := SQLEscape(Value);
end;

function TSField.GetSession(): TSSession;
begin
  Result := FieldTypes.Session;
end;

procedure TSField.ParseFieldType(var Parse: TSQLParse);
var
  Identifier: string;
  S: string;
begin
  National := SQLParseKeyword(Parse, 'NATIONAL');

  Identifier := SQLParseValue(Parse);
  FieldType := Session.FieldTypeByCaption(Identifier).MySQLFieldType;

  Size := -1;
  Decimals := -1;
  if (SQLParseChar(Parse, '(')) then
  begin
    if (FieldType in [mfEnum, mfSet]) then
    begin
      SetLength(Elements, 0);
      repeat
        SetLength(Elements, Length(Elements) + 1);
        Elements[Length(Elements) - 1] := SQLParseValue(Parse);
      until (not SQLParseChar(Parse, ','));
    end
    else if (FieldType in [mfFloat, mfDouble, mfDecimal]) then
    begin
      if (SQLParseChar(Parse, ')', False)) then
        Size := 0
      else
        Size := SysUtils.StrToInt(SQLParseValue(Parse));

      if (not SQLParseChar(Parse, ',') and not SQLParseChar(Parse, '.')) then
        Decimals := 0
      else
        Decimals := SysUtils.StrToInt(SQLParseValue(Parse));
    end
    else if (FieldType in [mfTinyText, mfText, mfMediumText, mfLongText, mfTime, mfDateTime, mfTimeStamp]) then
    begin
      S := SQLParseValue(Parse);
      if (not TryStrToInt(S, Size)) then
        Size := -1;
    end
    else if (FieldType in [mfDateTime]) then
      Size := -1
    else if (FieldType in [mfGeometry, mfPoint, mfLineString, mfPolygon, mfMultiPoint, mfMultiLineString, mfMultiPolygon, mfGeometryCollection]) then
      Size := -1
    else
      Size := SysUtils.StrToInt(SQLParseValue(Parse));

    if (not SQLParseChar(Parse, ')')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Name, StrPas(Parse.Start)]);
  end
  else if ((FieldType = mfTinyInt) and ((StrIComp(PChar(Identifier), 'BOOL') = 0) or (StrIComp(PChar(Identifier), 'BOOLEAN') = 0))) then
    Size := 1
  else if (FieldType in [mfTinyText, mfTinyBlob]) then
    Size := (1 shl 8) - 1
  else if (FieldType in [mfText, mfBlob]) then
    Size := (1 shl 16) - 1
  else if (FieldType in [mfMediumText, mfMediumBlob]) then
    Size := (1 shl 24) - 1
  else if (FieldType in [mfLongText, mfLongBlob]) then
    Size := (1 shl 32) - 1
  else if (FieldType in [mfDouble]) then
    SQLParseKeyword(Parse, 'PRECISION');

  if (FieldType in TextFieldTypes) then
  begin
    if (SQLParseKeyword(Parse, 'CHARACTER SET') or SQLParseKeyword(Parse, 'CHARSET') or SQLParseKeyword(Parse, 'CHAR')) then
      Charset := SQLParseValue(Parse);
    if (SQLParseKeyword(Parse, 'COLLATE')) then
      Collation := SQLParseValue(Parse);
  end;

  Unsigned := SQLParseKeyword(Parse, 'UNSIGNED');
end;

procedure TSField.SetName(const AName: string);
begin
  Assert(AName <> '');

  if (AName <> FName) then
    FName := AName;
end;

{ TSTableField ****************************************************************}

procedure TSTableField.Assign(const Source: TSField);
begin
  inherited Assign(Source);

  Ascii := TSTableField(Source).Ascii;
  AutoIncrement := TSTableField(Source).AutoIncrement;
  Binary := TSTableField(Source).Binary;
  Comment := TSTableField(Source).Comment;
  Default := TSTableField(Source).Default;
  DefaultSize := TSTableField(Source).DefaultSize;
  FieldBefore := nil;
  FInPrimaryKey := TSTableField(Source).InPrimaryKey;
  FInUniqueKey := TSTableField(Source).InUniqueKey;
  if (Assigned(Fields) and Assigned(TSTableField(Source).Fields) and Assigned(TSTableField(Source).FieldBefore)) then
    FieldBefore := Fields.FieldByName(TSTableField(Source).FieldBefore.Name);
  NullAllowed := TSTableField(Source).NullAllowed or ((Default = 'NULL') and not TSTableField(Source).AutoIncrement and not (FieldType in [mfTinyText, mfText, mfMediumText, mfLongText, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob]));
  Unicode := TSTableField(Source).Unicode;
  Zerofill := TSTableField(Source).Zerofill;
end;

procedure TSTableField.Clear();
begin
  inherited;

  Ascii := False;
  AutoIncrement := False;
  Binary := False;
  Comment := '';
  Default := '';
  DefaultSize := 0;
  FieldBefore := nil;
  NullAllowed := True;
  Unicode := False;
  Zerofill := False;
end;

constructor TSTableField.Create(const AFields: TSTableFields; const AName: string = '');
begin
  inherited Create(AFields.Session.FieldTypes, AName);

  FItems := AFields;

  Clear();

  FName := AName;
end;

function TSTableField.DBTypeStr(): string;
begin
  Result := '';

  Result := Result + inherited DBTypeStr();

  if ((FieldType in [mfTinyInt, mfSmallInt, mfMediumInt, mfInt, mfBigInt, mfFloat, mfDouble, mfDecimal]) and Zerofill) then
    Result := Result + ' zerofill';
  if (Binary and (Session.Connection.MySQLVersion < 40101)) then
    Result := Result + ' binary';
end;

destructor TSTableField.Destroy();
begin
  Clear();

  inherited;
end;

function TSTableField.Equal(const Second: TSTableField): Boolean;
var
  I: Integer;
begin
  Result := inherited Equal(Second);

  Result := Result and (Ascii = Second.Ascii);
  Result := Result and (AutoIncrement = Second.AutoIncrement);
  Result := Result and (Binary = Second.Binary);
  Result := Result and (Collation = Second.Collation);
  Result := Result and (Comment = Second.Comment);
  Result := Result and (Decimals = Second.Decimals);
  Result := Result and (Default = Second.Default);
  Result := Result and (DefaultSize = Second.DefaultSize);
  Result := Result and (Charset = Second.Charset);
  Result := Result and (FieldType = Second.FieldType);
  Result := Result and (Name = Second.Name);
  Result := Result and (NullAllowed = Second.NullAllowed);
  Result := Result and (Length(Elements) = Length(Second.Elements));
  if (Result) then
    for I := 0 to Length(Elements) - 1 do
      Result := Result and (Elements[I] = Second.Elements[I]);
  Result := Result and (Size = Second.Size);
  Result := Result and (Unicode = Second.Unicode);
  Result := Result and (Unsigned = Second.Unsigned);
  Result := Result and (Zerofill = Second.Zerofill);
end;

function TSTableField.GetFields(): TSTableFields;
begin
  Result := TSTableFields(Items);
end;

function TSTableField.GetTable(): TSTable;
begin
  Result := Fields.Table;
end;

procedure TSTableField.ParseFieldType(var Parse: TSQLParse);
begin
  inherited ParseFieldType(Parse);

  Zerofill := SQLParseKeyword(Parse, 'ZEROFILL');

  Binary := SQLParseKeyword(Parse, 'BINARY');

  Ascii := SQLParseKeyword(Parse, 'ASCII');

  Unicode := SQLParseKeyword(Parse, 'UNICODE');
end;

function TSTableField.UnescapeValue(const Value: string): string;
begin
  Result := SQLUnescape(Value);

  case (FieldType) of
    mfBit:
      if (Value = 'NULL') then
        Result := ''
      else if (Pos('b', Value) = 1) then
        Result := Session.UnescapeValue(Copy(Value, 2, Length(Value) - 1), FieldType)
      else
        Result := Session.UnescapeValue(Value, FieldType);
    mfTinyInt, mfSmallInt, mfMediumInt, mfInt, mfBigInt:
      if (Value = 'NULL') then
        Result := ''
      else
        Result := Session.UnescapeValue(Value, FieldType);
    mfFloat, mfDouble, mfDecimal:
      begin
        Result := ReplaceStr(Session.UnescapeValue(Value, FieldType), '.', FormatSettings.DecimalSeparator);
        if ((Result = '') and (FieldKind = mkReal)) then Result := 'NULL';
      end;
    mfEnum, mfSet:
      Result := ReplaceStr(Session.UnescapeValue(Value, FieldType), '''''', '''');
    else
      try
        Result := Session.UnescapeValue(Value, FieldType);
      except
        on E: EConvertError do
          Session.Connection.DoConvertError(Self, Value, E);
      end;
  end;
end;

{ TSBaseTableField ************************************************************}

procedure TSBaseField.Assign(const Source: TSField);
begin
  Assert(Source is TSBaseField);

  inherited Assign(Source);
  FOriginalName := TSBaseField(Source).OriginalName;

  if (Assigned(TSBaseTable(TSTableField(Source).Fields.Table).FEngine)) then
    FieldType := TSBaseTable(TSTableField(Source).Fields.Table).Engine.ApplyMySQLFieldType(TSTableField(Source).FieldType, TSTableField(Source).Size);
  if (Session.Connection.MySQLVersion < 40102) then
    OnUpdate := ''
  else
  begin
    OnUpdate := TSBaseField(TSTableField(Source)).OnUpdate;
    OnUpdateSize := TSBaseField(TSTableField(Source)).OnUpdateSize;
  end;

  Moved := TSBaseField(TSTableField(Source)).Moved;
end;

procedure TSBaseField.Clear();
begin
  inherited;

  OnUpdate := '';
  OnUpdateSize := 0;
  Moved := False;
end;

constructor TSBaseField.Create(const AFields: TSTableFields; const AName: string = '');
begin
  inherited;

  FOriginalName := AName;
end;

function TSBaseField.GetIndex(): Integer;
begin
  Result := Table.Fields.IndexOf(Self);
end;

function TSBaseField.GetTable(): TSBaseTable;
begin
  Assert(Assigned(Fields));
  Assert(Fields.Table is TSBaseTable);

  Result := TSBaseTable(Fields.Table);
end;

{ TSViewField *****************************************************************}

function TSViewField.GetIndex(): Integer;
begin
  Result := Table.Fields.IndexOf(Self);
end;

{ TSTableFields ***************************************************************}

function TSTableFields.AddField(const NewField: TSTableField): Integer;
begin
  if (not Assigned(NewField.FieldBefore)) then
    Result := 0
  else
    Result := NewField.FieldBefore.Index + 1;

  if (NewField is TSBaseField) then
  begin
    Insert(Result, TSBaseField.Create(TSBaseFields(Self)));
    TSBaseField(Field[Result]).FOriginalName := '';
  end
  else if (NewField is TSViewField) then
    Insert(Result, TSViewField.Create(Self))
  else
    raise Exception.Create(sUnknownToType);
  Field[Result].Assign(NewField);
  if (Result > 0) then
    Field[Result].FieldBefore := Field[Result - 1];
  if (Result + 1 <= Count - 1) then
    Field[Result + 1].FieldBefore := Field[Result];
end;

procedure TSTableFields.Assign(const Source: TSTableFields);
begin
  raise EAbstractError.Create(SAbstractError)
end;

constructor TSTableFields.Create(const ATable: TSTable);
begin
  inherited Create(ATable.Session);

  FTable := ATable;

  FValid := False;
end;

procedure TSTableFields.Delete(const AField: TSTableField);
var
  I: Integer;
  Index: Integer;
  J: Integer;
begin
  Index := IndexOf(AField);

  if (Table is TSBaseTable) then
    for I := TSBaseTable(Table).Keys.Count - 1 downto 0 do
    begin
      for J := TSBaseTable(Table).Keys[I].Columns.Count - 1 downto 0 do
        if (TSBaseTable(Table).Keys[I].Columns[J].Field = AField) then
          TSBaseTable(Table).Keys[I].Columns.DeleteColumn(TSBaseTable(Table).Keys[I].Columns[J]);
      if (TSBaseTable(Table).Keys[I].Columns.Count = 0) then
        TSBaseTable(Table).Keys.Delete(TSBaseTable(Table).Keys[I]);
    end;

  if (Index + 1 < Count) then
    if (Index <= 0) then
      Field[Index + 1].FieldBefore := nil
    else
      Field[Index + 1].FieldBefore := Field[Index - 1];

  Session.SendEvent(etItemDeleted, Table, Self, AField);

  Delete(Index);

  AField.Free();
end;

function TSTableFields.FieldByName(const FieldName: string): TSTableField;
var
  Index: Integer;
begin
  Index := IndexByName(FieldName);
  if (Index < 0) then
    Result := nil
  else
    Result := Field[Index];
end;

function TSTableFields.GetField(Index: Integer): TSTableField;
begin
  Result := TSTableField(Items[Index]);
end;

function TSTableFields.IndexByName(const Name: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if (NameCmp(Item[I].Name, Name) = 0) then
    begin
      Result := I;
      break;
    end;
end;

function TSTableFields.InsertIndex(const Name: string; out Index: Integer): Boolean;
begin
  raise EAbstractError.Create(SAbstractError);
end;

function TSTableFields.IndexOf(const AField: TSTableField): Integer;
var
  I: Integer;
begin
  Result := -1;

  if (Assigned(AField)) then
    for I := 0 to Count - 1 do
      if (Field[I].Name = AField.Name) then
        Result := I;
end;

procedure TSTableFields.Invalidate();
begin
  FValid := False;
end;

{ TSBaseTableFields ***********************************************************}

function TSBaseFields.AddField(const NewField: TSTableField): Integer;
begin
  Result := inherited;

  Field[Result].FOriginalName := '';
end;

procedure TSBaseFields.Assign(const Source: TSTableFields);
var
  I: Integer;
  NewField: TSBaseField;
begin
  Clear();

  for I := 0 to TSBaseFields(Source).Count - 1 do
  begin
    NewField := TSBaseField.Create(Self, TSBaseFields(Source).Field[I].Name);
    NewField.Assign(TSBaseFields(Source).Field[I]);
    NewField.FOriginalName := TSBaseFields(Source).Field[I].OriginalName;
    AddField(NewField);
    NewField.Free();

    TSBaseField(Field[I]).FOriginalName := TSBaseFields(Source).Field[I].OriginalName;;
  end;
end;

function TSBaseFields.GetField(Index: Integer): TSBaseField;
begin
  Result := TSBaseField(Items[Index]);
end;

procedure TSBaseFields.MoveField(const AField: TSTableField; const NewFieldBefore: TSTableField);
var
  I: Integer;
  Index: Integer;
  NewIndex: Integer;
begin
  if (NewFieldBefore <> AField.FieldBefore) then
  begin
    Index := IndexOf(AField);

    if (not Assigned(NewFieldBefore)) then
      NewIndex := 0
    else
      NewIndex := IndexOf(NewFieldBefore) + 1;

    Move(Index, NewIndex);

    TSBaseField(Field[NewIndex]).Moved := True;

    Field[0].FieldBefore := nil;
    for I := 1 to Count - 1 do
      Field[I].FieldBefore := Field[I - 1];
  end;
end;

{ TSViewFields ****************************************************************}

procedure TSViewFields.Assign(const Source: TSTableFields);
var
  I: Integer;
  NewField: TSViewField;
begin
  Clear();

  for I := 0 to TSBaseFields(Source).Count - 1 do
  begin
    NewField := TSViewField.Create(Self, TSBaseFields(Source).Field[I].Name);
    NewField.Assign(TSBaseFields(Source).Field[I]);
    AddField(NewField);
    NewField.Free();
  end;
end;

{ TSForeignKey ****************************************************************}

procedure TSForeignKey.Assign(const Source: TSForeignKey);
var
  I: Integer;
begin
  inherited Assign(Source);

  Created := Source.Created;
  SetLength(Fields, Length(Source.Fields));
  for I := 0 to Length(Source.Fields) - 1 do
    Fields[I] := Source.Fields[I];
  Match := Source.Match;
  OnDelete := Source.OnDelete;
  OnUpdate := Source.OnUpdate;
  Parent.DatabaseName := Source.Parent.DatabaseName;
  Parent.TableName := Source.Parent.TableName;
  SetLength(Parent.FieldNames, Length(Source.Parent.FieldNames));
  for I := 0 to Length(Source.Parent.FieldNames) - 1 do
    Parent.FieldNames[I] := Source.Parent.FieldNames[I];
end;

procedure TSForeignKey.Clear();
begin
  Created := False;

  SetLength(Fields, 0);
  Match := mtNo;
  OnDelete := dtRestrict;
  OnUpdate := utRestrict;
  Parent.DatabaseName := '';
  Parent.TableName := '';
  SetLength(Parent.FieldNames, 0);
end;

constructor TSForeignKey.Create(const AForeignKeys: TSForeignKeys; const AName: string = '');
begin
  inherited Create(AForeignKeys, AName);

  Clear();

  FOriginalName := AName;
end;

function TSForeignKey.DBTypeStr(): string;
var
  J: Integer;
begin
  Result := '';
  if (Length(Fields) > 1) then Result := Result + '(';
  for J := 0 to Length(Fields) - 1 do
  begin
    if (J > 0) then Result := Result + ', ';
    if (not Assigned(Fields[J])) then
      Result := '???'
    else
      Result := Result + Fields[J].Name;
  end;
  if (Length(Fields) > 1) then Result := Result + ')';

  Result := Result + ' -> ';

  if (Parent.DatabaseName <> ForeignKeys.Table.Database.Name) then
    Result := Result + ForeignKeys.Table.Database.Name + '.';
  Result := Result + Parent.TableName + '.';
  if (Length(Parent.FieldNames) = 1) then
    Result := Result + Parent.FieldNames[0]
  else
  begin
    Result := Result + '(';
    for J := 0 to Length(Parent.FieldNames) - 1 do
    begin
      if (J > 0) then Result := Result + ', ';
      Result := Result + Parent.FieldNames[J];
    end;
    Result := Result + ')';
  end;
end;

destructor TSForeignKey.Destroy();
begin
  SetLength(Fields, 0);
  SetLength(Parent.FieldNames, 0);

  inherited;
end;

function TSForeignKey.Equal(const Second: TSForeignKey): Boolean;
var
  I: Integer;
begin
  Result := inherited Equal(Second);

  Result := Result and (Length(Fields) = Length(Second.Fields));
  for I := 0 to Length(Fields) - 1 do
    Result := Result and (Table.Fields.NameCmp(Fields[I].Name, Second.Fields[I].Name) = 0);
  Result := Result and (Match = Second.Match);
  Result := Result and (lstrcmpi(PChar(Name), PChar(Second.Name)) = 0);
  Result := Result and (OnDelete = Second.OnDelete);
  Result := Result and (OnUpdate = Second.OnUpdate);
  Result := Result and (Session.Databases.NameCmp(Parent.DatabaseName, Second.Parent.DatabaseName) = 0);
  Result := Result and ((Session.TableNameCmp(Parent.TableName, Second.Parent.TableName) = 0)
                     or (Session.TableNameCmp(Parent.TableName, Second.Parent.TableName) = 0));
  Result := Result and (Length(Parent.FieldNames) = Length(Second.Parent.FieldNames));
  for I := 0 to Length(Parent.FieldNames) - 1 do
    Result := Result
      and (Table.Fields.NameCmp(Parent.FieldNames[I], Second.Parent.FieldNames[I]) = 0);
end;

function TSForeignKey.GetForeignKeys(): TSForeignKeys;
begin
  Assert(Items is TSForeignKeys);

  Result := TSForeignKeys(Items);
end;

function TSForeignKey.GetTable(): TSBaseTable;
begin
  Result := ForeignKeys.Table;
end;

procedure TSForeignKey.SetName(const AName: string);
begin
  FName := AName;
end;

{ TSForeignKeys ***************************************************************}

function TSForeignKeys.AddForeignKey(const NewForeignKey: TSForeignKey): Integer;
begin
  Result := TList(Self).Count;
  Insert(Result, TSForeignKey.Create(Self));
  ForeignKey[Result].Assign(NewForeignKey);
  ForeignKey[Result].FOriginalName := '';
  ForeignKey[Result].Created := True;
end;

procedure TSForeignKeys.Assign(const Source: TSForeignKeys);
var
  I: Integer;
begin
  Clear();

  for I := 0 to Source.Count - 1 do
  begin
    AddForeignKey(Source.ForeignKey[I]);
    ForeignKey[I].Created := Source.ForeignKey[I].Created;
    ForeignKey[I].FOriginalName := Source.ForeignKey[I].OriginalName;
  end;
  FValid := Source.Valid;
end;

procedure TSForeignKeys.Clear();
begin
  inherited;

  FValid := False;
end;

constructor TSForeignKeys.Create(const ATable: TSBaseTable);
begin
  inherited Create(ATable.Session);

  FTable := ATable;

  FValid := False;
end;

procedure TSForeignKeys.Delete(const AForeignKey: TSForeignKey);
begin
  Session.SendEvent(etItemDeleted, Table, Self, AForeignKey);

  Delete(IndexOf(AForeignKey));

  AForeignKey.Free();
end;

function TSForeignKeys.GetForeignKey(Index: Integer): TSForeignKey;
begin
  Result := TSForeignKey(Items[Index]);
end;

procedure TSForeignKeys.Invalidate();
begin
  FValid := False;
end;

{ TSTableDataSet **************************************************************}

constructor TSTable.TDataSet.Create(const ATable: TSTable);
begin
  inherited Create(nil);

  FTable := ATable;

  Connection := Table.Session.Connection;
  FFilterSQL := '';
end;

procedure TSTable.TDataSet.Invalidate();
begin
  Close();
  FFilterSQL := '';
end;

function TSTable.TDataSet.SQLSelect(const IgnoreLimit: Boolean = False): string;
var
  DescFieldName: string;
  DescPos: Integer;
  FieldName: string;
  FirstField: Boolean;
  I: Integer;
  Pos: Integer;
begin
  Result := 'SELECT * FROM ' + Connection.EscapeIdentifier(Table.Database.Name) + '.' + Connection.EscapeIdentifier(Table.Name);
  if ((FilterSQL <> '') or (QuickSearch <> '')) then
  begin
    Result := Result + ' WHERE ';
    if ((FilterSQL <> '') and (QuickSearch <> '')) then
      Result := Result + '(';
    if (FilterSQL <> '') then
      Result := Result + FilterSQL;
    if ((FilterSQL <> '') and (QuickSearch <> '')) then
      Result := Result + ') AND (';
    if (QuickSearch <> '') then
      for I := 0 to Table.Fields.Count - 1 do
      begin
        if (I > 0) then Result := Result + ' OR ';
        Result := Result + Connection.EscapeIdentifier(Table.Fields[I].Name) + ' LIKE ' + SQLEscape('%' + QuickSearch + '%');
      end;
    if ((FilterSQL <> '') and (QuickSearch <> '')) then
      Result := Result + ')';
  end;
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
    if (Offset + RecordCount > 0) then
      Result := Result + IntToStr(Offset + RecordCount) + ',';
    if (IgnoreLimit) then
      RequestedRecordCount := $7fffffff - (Offset + RecordCount)
    else if (RecordCount = 0) then
      RequestedRecordCount := Limit
    else
      RequestedRecordCount := RecordCount;
    Result := Result + IntToStr(RequestedRecordCount);
  end;
  Result := Result + ';' + #13#10;
end;

{ TSMergeSourceTables *********************************************************}

procedure TSMergeSourceTables.Clear();
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    MergeSourceTable[I].Free();

  inherited;
end;

destructor TSMergeSourceTables.Destroy();
begin
  Clear();

  inherited;
end;

function TSMergeSourceTables.GetMergeSourceTable(Index: Integer): TSMergeSourceTable;
begin
  Result := TSMergeSourceTable(Items[Index]);
end;

{ TSTable *********************************************************************}

procedure TSTable.Assign(const Source: TSTable);
begin
  Assert(Assigned(Source.Fields));


  inherited Assign(Source);

  if (Assigned(FDataSet)) then
    FreeAndNil(FDataSet);

  Fields.Assign(Source.Fields);
end;

constructor TSTable.Create(const ASDBObjects: TSDBObjects; const AName: string = '');
begin
  inherited Create(ASDBObjects, AName);

  FDataSet := nil;
end;

destructor TSTable.Destroy();
begin
  inherited;

  if (Assigned(FDataSet)) then
    FDataSet.Free();
end;

function TSTable.FieldByName(const FieldName: string): TSTableField;
begin
  Result := Fields.FieldByName(FieldName);
end;

function TSTable.GetDataSet(): TDataSet;
begin
  Assert(Assigned(Database));
  Assert(Name <> ''); // Debug 2017-01-05

  if (not Assigned(FDataSet)) then
  begin
    FDataSet := TDataSet.Create(Self);
    FDataSet.AutomaticLoadNextRecords := True;
    FDataSet.FDatabaseName := Database.Name;
    FDataSet.CommandText := Name;
  end;

  Result := FDataSet;
end;

function TSTable.GetTables(): TSTables;
begin
  Result := TSTables(Items);
end;

function TSTable.GetValidData(): Boolean;
begin
  Result := Assigned(FDataSet) and FDataSet.Active;
end;

procedure TSTable.Invalidate();
begin
  inherited;

  Fields.Invalidate();
  InvalidateData();

  if (Assigned(Database.Columns)) then Database.Columns.Invalidate();
end;

procedure TSTable.InvalidateData();
begin
  if (Assigned(FDataSet) and FDataSet.Active) then
    DataSet.Invalidate();
end;

procedure TSTable.Open(const FilterSQL, QuickSearch: string; const ASortDef: TIndexDef; const Offset: Integer; const Limit: Integer);
begin
  FFilterSQL := FilterSQL;

  DataSet.Close();

  DataSet.Limit := Limit;
  DataSet.Offset := Offset;
  DataSet.FilterSQL := FilterSQL;
  DataSet.QuickSearch := QuickSearch;
  DataSet.SortDef.Assign(ASortDef);

  // Debug 2017-02-06
  Assert(not DataSet.Active);

  // Debug 2017-05-20
  Assert(Session.Connection.SynchronCount = 0);

  Session.SendSQL(DataSet.SQLSelect(), OpenEvent);
end;

function TSTable.OpenEvent(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
  const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
begin
  // Debug 2017-02-06
  Assert(not DataSet.Active);

  DataSet.Open(DataHandle);

  Result := False;
end;

procedure TSTable.PushBuildEvent(const ItemsEvents: Boolean = True);
begin
  if (ValidSource) then
  begin
    if (ItemsEvents) then
      Session.SendEvent(etItemsValid, Database, Items);
    Session.SendEvent(etItemValid, Database, Items, Self);
  end;

  // Debug 2017-05-06
  Assert(Assigned(Self));
  Assert(Self is TSTable);
  Assert(Assigned(Fields));

  if (Fields.Count > 0) then
    Session.SendEvent(etItemsValid, Self, Fields);
end;

procedure TSTable.SetName(const AName: string);
begin
  if (Session.LowerCaseTableNames = 1) then
    inherited SetName(LowerCase(AName))
  else
    inherited SetName(AName);
end;

{ TSPartition *****************************************************************}

procedure TSPartition.Assign(const Source: TSPartition);
begin
  inherited Assign(Source);

  if (Assigned(Source.Table)) then FTable := Source.Table;

  Comment := Source.Comment;
  Engine := Source.Engine;
  MaxRows := Source.MaxRows;
  MinRows := Source.MinRows;
  ValuesExpr := Source.ValuesExpr;
end;

procedure TSPartition.Clear();
begin
  Comment := '';
  Engine := nil;
  MaxRows := -1;
  MinRows := -1;
  ValuesExpr := '';
end;

constructor TSPartition.Create(const ASItems: TSItems; const ATable: TSBaseTable);
begin
  inherited Create(ASItems);

  Clear();

  FTable := ATable;
end;

function TSPartition.DBTypeStr(): string;
begin
  if (not (Table.Partitions.PartitionType in [ptRange, ptList])) then
    Result := ''
  else
  begin
    Result := 'PARTITION ';
    if (Name <> '') then
      Result := Result + Session.Connection.EscapeIdentifier(Name) + ' ';
    case (Table.Partitions.PartitionType) of
      ptRange: Result := Result + 'VALUES LESS THAN (' + ValuesExpr + ')';
      ptList: Result := Result + 'VALUES IN (' + ValuesExpr + ')';
    end;
    if (Comment <> '') then
      Result := Result + ' COMMENT=' + SQLEscape(Comment);
    if (MaxRows >= 0) then
      Result := Result + ' MAX_ROWS=' + IntToStr(MaxRows);
    if (MinRows >= 0) then
      Result := Result + ' MIN_ROWS=' + IntToStr(MinRows);
  end;
end;

function TSPartition.Equal(const Second: TSPartition): Boolean;
begin
  Result := inherited Equal(Second)
    and (Comment = Second.Comment)
    and (Engine = Second.Engine)
    and (Name = Second.Name)
    and (MaxRows = Second.MaxRows)
    and (MinRows = Second.MinRows)
    and (ValuesExpr = Second.ValuesExpr);
end;

{ TSPartitions ****************************************************************}

procedure TSPartitions.AddPartition(const NewPartition: TSPartition);
begin
  Add(TSPartition.Create(Self, TSBaseTable(Table)));
  Partition[Count - 1].Assign(NewPartition);
end;

procedure TSPartitions.Assign(const Source: TSPartitions);
var
  I: Integer;
begin
  Clear();

  if (Assigned(Source.FTable)) then FTable := Source.FTable;

  Expression := Source.Expression;
  Linear := Source.Linear;
  PartitionsNumber := Source.PartitionsNumber;
  PartitionType := Source.PartitionType;

  for I := 0 to TList(Source).Count - 1 do
    AddPartition(Source.Partition[I]);
end;

procedure TSPartitions.Clear();
begin
  Expression := '';
  Linear := False;
  PartitionsNumber := -1;
  PartitionType := ptNone;

  inherited;
end;

constructor TSPartitions.Create(const ATable: TSBaseTable);
begin
  inherited Create(ATable.Session);

  FTable := ATable;
end;

procedure TSPartitions.Delete(const APartition: TSPartition);
var
  Index: Integer;
begin
  Index := IndexOf(APartition);

  Partition[Index].Free();
  Delete(Index);
end;

function TSPartitions.GetPartition(Index: Integer): TSPartition;
begin
  Result := TSPartition(Items[Index]);
end;

function TSPartitions.IndexOf(const APartition: TSPartition): Integer;
var
  I: Integer;
begin
  Result := -1;

  if (Assigned(APartition)) then
    for I := 0 to Count - 1 do
      if (Partition[I].Name = APartition.Name) then
        Result := I;
end;

procedure TSPartitions.MovePartition(const APartition: TSPartition; const NewIndex: Integer);
begin
  Move(IndexOf(APartition), NewIndex);
end;

function TSPartitions.UpdatePartition(const Partition, NewPartition: TSPartition): Boolean;
begin
  Result := Assigned(Partition) and not Assigned(Table.PartitionByName(NewPartition.Name)) or (Table.PartitionByName(NewPartition.Name) = Partition);

  if (Result) then
    Partition.Assign(NewPartition);
end;

{ TSBaseTable *****************************************************************}

procedure TSBaseTable.AddReference(const ReferencedTable: TSBaseTable);
begin
  References.Add(TSReference.Create(References, ReferencedTable.Database.Name, TSTable, ReferencedTable.Name));
end;

procedure TSBaseTable.Assign(const Source: TSTable);
var
  I: Integer;
begin
  inherited;

  FAutoIncrement := TSBaseTable(Source).AutoIncrement;
  FAvgRowLength := TSBaseTable(Source).AvgRowLength;
  FBlockSize := TSBaseTable(Source).BlockSize;
  FChecked := TSBaseTable(Source).Checked;
  FChecksum := TSBaseTable(Source).Checksum;
  FCollation := TSBaseTable(Source).FCollation;
  FComment := TSBaseTable(Source).Comment;
  FCreated := TSBaseTable(Source).Created;
  FDataSize := TSBaseTable(Source).DataSize;
  FCharset := TSBaseTable(Source).FCharset;
  FDelayKeyWrite := TSBaseTable(Source).DelayKeyWrite;
  FEngine := TSBaseTable(Source).Engine;
  FIndexSize := TSBaseTable(Source).IndexSize;
  FInsertMethod := TSBaseTable(Source).InsertMethod;
  FMaxDataSize := TSBaseTable(Source).MaxDataSize;
  FMaxRows := TSBaseTable(Source).MaxRows;
  FMinRows := TSBaseTable(Source).MinRows;
  FPackKeys := TSBaseTable(Source).PackKeys;
  FRecordCount := TSBaseTable(Source).RecordCount;
  FRowType := TSBaseTable(Source).RowType;
  FUnusedSize := TSBaseTable(Source).UnusedSize;
  FUpdated := TSBaseTable(Source).Updated;
  FValidStatus := TSBaseTable(Source).ValidStatus;

  FKeys.Assign(TSBaseTable(Source).Keys);

  FForeignKeys.FValid := True; // Do not allow GetSource!
  FForeignKeys.Assign(TSBaseTable(Source).ForeignKeys);

  if (Assigned(FPartitions) and (not Assigned(Database) or (Session.Connection.MySQLVersion < 50107))) then
    FreeAndNil(FPartitions)
  else if (not Assigned(FPartitions) and Assigned(Database) and (Session.Connection.MySQLVersion >= 50107)) then
    FPartitions := TSPartitions.Create(Self);
  if (Assigned(FPartitions) and Assigned(TSBaseTable(Source).Partitions)) then FPartitions.Assign(TSBaseTable(Source).Partitions);

  if (Assigned(Source.Database) and Assigned(Database)) then
    if ((Session.Connection.MySQLVersion < 40101) and (Session.Connection.MySQLVersion < 40101) or (Source.Session.Connection.MySQLVersion >= 40101) and (Session.Connection.MySQLVersion >= 40101)) then
    begin
      Charset := TSBaseTable(Source).Charset;
      Collation := TSBaseTable(Source).Collation;
    end
    else if ((Source.Session.Connection.MySQLVersion < 40101) and (Session.Connection.MySQLVersion >= 40101)) then
    begin
      for I := 0 to Length(CharsetTranslations) - 1 do
        if (TSBaseTable(Source).Charset = StrPas(CharsetTranslations[I].OldCharset)) then
        begin
          Charset := StrPas(CharsetTranslations[I].NewCharset);
          Collation := StrPas(CharsetTranslations[I].NewCollation);
        end;
    end
    else if ((Session.Connection.MySQLVersion > 40101) and (Session.Connection.MySQLVersion < 40101)) then
    begin
      for I := 0 to Length(CharsetTranslations) - 1 do
        if ((TSBaseTable(Source).Charset = StrPas(CharsetTranslations[I].NewCharset)) and (TSBaseTable(Source).Collation = StrPas(CharsetTranslations[I].NewCollation))) then
          Charset := StrPas(CharsetTranslations[I].OldCharset);
      if (Charset = '') then
        for I := 0 to Length(CharsetTranslations) - 1 do
          if (TSBaseTable(Source).Charset = StrPas(CharsetTranslations[I].OldCharset)) then
            Charset := StrPas(CharsetTranslations[I].OldCharset);
      if (Charset = '') then
        for I := 0 to Length(CharsetTranslations) - 1 do
          if (TSBaseTable(Source).Charset = StrPas(CharsetTranslations[I].NewCharset)) then
            Charset := StrPas(CharsetTranslations[I].NewCharset);
    end;
end;

function TSBaseTable.Build(const DataSet: TMySQLQuery): Boolean;
begin
  // Debug 2017-05-01
  Assert(Assigned(DataSet.FindField('Create Table')),
    'CommandText: ' + DataSet.CommandText + #13#10
    + 'Fields[0].Name: ' + DataSet.Fields[0].Name);

  Result := Build(DataSet.FindField('Create Table'));
end;

function TSBaseTable.Build(const Field: TField): Boolean;
var
  RBS: RawByteString;
begin
  try
    Result := inherited;
  except
    on E: Exception do
      begin
        // Debug 2017-01-04
        Assert(Assigned(E));
        Assert(Assigned(Field), E.Message);
        Assert(Assigned(Field.DataSet), E.Message);
        Assert(Assigned(TMySQLQuery(Field.DataSet).LibRow), E.Message);
        Assert(Assigned(TMySQLQuery(Field.DataSet).LibLengths), E.Message);

        // Sometimes, the MySQL server sends wrong encoded field comments.
        // This code allow the user to handle this table - but the comments are still wrong...
        SetString(RBS, TMySQLQuery(Field.DataSet).LibRow^[Field.FieldNo - 1], TMySQLQuery(Field.DataSet).LibLengths^[Field.FieldNo - 1]);
        SetSource(string(RBS));

        Result := False;
      end;
  end;

  ParseCreateTable(Source);

  Session.SendEvent(etItemValid, Database, Items, Self);
  Session.SendEvent(etItemsValid, Self, Fields);
end;

constructor TSBaseTable.Create(const ASDBObjects: TSDBObjects; const AName: string = ''; const ASystemTable: Boolean = False);
begin
  inherited Create(ASDBObjects, AName);

  FKeys := TSKeys.Create(Self);
  FForeignKeys := TSForeignKeys.Create(Self);
  if (ASDBObjects.Database.Session.Connection.MySQLVersion < 50107) then
    FPartitions := nil
  else
    FPartitions := TSPartitions.Create(Self);

  FAutoIncrement := 0;
  FAvgRowLength := -1;
  FChecked := -1;
  FChecksum := False;
  FCollation := '';
  FComment := '';
  FCreated := -1;
  FDataSize := -1;
  if (Assigned(Database)) then
    FCharset := Database.Charset
  else
    FCharset := '';
  FDelayKeyWrite := False;
  FEngine := nil;
  FFields := TSBaseFields.Create(Self);
  FIndexSize := -1;
  FInsertMethod := imNo;
  FMaxDataSize := -1;
  FMaxRows := -1;
  FMergeSourceTables := TSMergeSourceTables.Create();
  FMinRows := -1;
  FPackKeys := piDefault;
  FRecordCount := -1;
  FRowType := mrUnknown;
  FUnusedSize := -1;
  FUpdated := -1;
end;

function TSBaseTable.DBRowTypeStr(): string;
begin
  Result := '';
  case (RowType) of
    mrFixed: Result := 'FIXED';
    mrDynamic: Result := 'DYNAMIC';
    mrCompressed: Result := 'COMPRESSED';
    mrRedundant: Result := 'REDUNDANT';
    mrCompact: if (Session.Connection.MySQLVersion >= 50003) then Result := 'COMPACT';
  end;
end;

destructor TSBaseTable.Destroy();
begin
  inherited;

  FKeys.Free();
  FFields.Free();
  FForeignKeys.Free();
  if (Assigned(FPartitions)) then
    FPartitions.Free();
  FMergeSourceTables.Free();
end;

procedure TSBaseTable.Empty();
var
  List: TList;
begin
  List := TList.Create();
  List.Add(Self);
  Database.EmptyTables(List);
  List.Free();
end;

function TSBaseTable.EmptyFields(const Fields: TList): Boolean;
var
  I: Integer;
  SQL: string;
begin
  SQL := '';
  for I := 0 to Fields.Count - 1 do
  begin
    if (SQL <> '') then SQL := SQL + ',';
    if (TSBaseField(Fields[I]).NullAllowed) then
      SQL := SQL + Session.Connection.EscapeIdentifier(TSBaseField(Fields[I]).Name) + '=NULL';
  end;

  SQL := 'UPDATE ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(Name) + ' SET ' + SQL + ';';

  if (Session.Connection.DatabaseName <> Name) then
    SQL := Database.SQLUse() + SQL;

  Result := Session.SendSQL(SQL);

  InvalidateData();
end;

function TSBaseTable.FieldByName(const FieldName: string): TSBaseField;
var
  Field: TSField;
begin
  Field := inherited FieldByName(FieldName);
  if (not (Field is TSBaseField)) then
    Result := nil
  else
    Result := TSBaseField(Field);
end;

function TSBaseTable.ForeignKeyByName(const ForeignKeyName: string): TSForeignKey;
var
  Index: Integer;
begin
  Index := ForeignKeys.IndexByName(ForeignKeyName);
  if (Index < 0) then
    Result := nil
  else
    Result := ForeignKeys[Index];
end;

function TSBaseTable.GetAutoIncrementField(): TSBaseField;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Fields.Count - 1 do
    if (Fields[I].AutoIncrement) then
      Result := TSBaseField(Fields[I]);
end;

function TSBaseTable.GetBaseTableFields(): TSBaseFields;
begin
  Result := TSBaseFields(GetFields());
end;

function TSBaseTable.GetPrimaryKey(): TSKey;
begin
  Result := KeyByName('');
end;

function TSBaseTable.GetFields(): TSTableFields;
begin
  Result := FFields;
end;

function TSBaseTable.GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string;
var
  SQL: string;
begin
  SQL := Trim(FSource) + #13#10;

  if (DropBeforeCreate) then
    SQL := 'DROP TABLE IF EXISTS ' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10 + SQL;

  if (FullQualifiedIdentifier) then
  begin
    if (Session.SQLParser.ParseSQL(SQL)) then
      SQL := AddDatabaseName(Session.SQLParser.FirstStmt, Database.Name);
    Session.SQLParser.Clear();
  end;

  Result := SQL;
end;

function TSBaseTable.GetTriggers(Index: Integer): TSTrigger;
var
  I: Integer;
  Counter: Integer;
begin
  Result := nil;
  if (Assigned(Database.Triggers)) then
  begin
    Counter := 0;
    for I := 0 to Database.Triggers.Count - 1 do
      if (Database.Triggers[I].Table = Self) then
      begin
        if (Counter = Index) then
          Result := Database.Triggers[I];
        Inc(Counter);
      end;
  end;
end;

function TSBaseTable.GetTriggerCount(): Integer;
var
  I: Integer;
begin
  Result := 0;
  if (Assigned(Database.Triggers)) then
    for I := 0 to Database.Triggers.Count - 1 do
      if (Database.Triggers[I].Table = Self) then
        Inc(Result);
end;

function TSBaseTable.GetValid(): Boolean;
begin
  Result := inherited and ValidStatus;
end;

procedure TSBaseTable.InvalidateData();
begin
  inherited;

  Keys.Invalidate();
  ForeignKeys.Invalidate();
  InvalidateStatus();
end;

function TSBaseTable.KeyByCaption(const Caption: string): TSKey;
var
  IndexName: string;
begin
  IndexName := Caption;

  Delete(IndexName, Pos(' (' + Preferences.LoadStr(377), IndexName), Length(IndexName) - Pos(' (' + Preferences.LoadStr(377), IndexName) + 2);
  if (IndexName = Preferences.LoadStr(154)) then IndexName := '';

  Result := KeyByName(IndexName);
end;

function TSBaseTable.KeyByName(const Name: string): TSKey;
var
  Index: Integer;
begin
  if (Keys.Count = 0) then
    Result := nil
  else if (Name = 'PRIMARY') and (Keys[0].Name = '') then
    Result := Keys[0]
  else
  begin
    Index := Keys.IndexByName(Name);
    if (Index < 0) then
      Result := nil
    else
      Result := Keys[Index];
  end;
end;

procedure TSBaseTable.Invalidate();
begin
  inherited;

  InvalidateStatus();
end;

procedure TSBaseTable.InvalidateStatus();
begin
  FValidStatus := False;
end;

function TSBaseTable.PartitionByName(const PartitionName: string): TSPartition;
var
  Index: Integer;
begin
  Index := Partitions.IndexByName(PartitionName);
  if (Index < 0) then
    Result := nil
  else
    Result := Partitions[Index];
end;

procedure TSBaseTable.ParseAlterTable(const SQL: string);
var
  Field: TSBaseField;
  NewFieldName: string;
  OldFieldName: string;
  Parse: TSQLParse;
  S: string;
begin
  if (SQLCreateParse(Parse, PChar(SQL), Length(SQL), Session.Connection.MySQLVersion)) then
  begin
    if (not SQLParseKeyword(Parse, 'ALTER')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

    SQLParseKeyword(Parse, 'IGNORE');

    if (not SQLParseKeyword(Parse, 'TABLE')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

    S := SQLParseValue(Parse);
    if (SQLParseChar(Parse, '.')) then
    begin
      if (Session.Databases.NameCmp(Database.Name, S) <> 0) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);
      S := SQLParseValue(Parse);
    end;
    if (Database.Tables.NameCmp(Name, S) <> 0) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

    while (not SQLParseEnd(Parse)) do
    begin
      if (SQLParseKeyword(Parse, 'CHANGE')) then
      begin
        SQLParseKeyword(Parse, 'COLUMN');

        OldFieldName := SQLParseValue(Parse);
        NewFieldName := SQLParseValue(Parse);

        Field := FieldByName(OldFieldName);
        if (Assigned(Field) and (NewFieldName <> OldFieldName)) then
        begin
          Field.Name := NewFieldName;
          Field.FOriginalName := NewFieldName;
        end;
      end;

      while (not SQLParseChar(Parse, ',') and not SQLParseEnd(Parse)) do
        SQLParseValue(Parse);
    end;
  end;
end;

procedure TSBaseTable.ParseCreateTable(const SQL: string);
var
  DeleteList: TList;
  Field: TSBaseField;
  FieldName: string;
  Fulltext: Boolean;
  I: Integer;
  Index: Integer;
  J: Integer;
  K: Integer;
  L: Largeint;
  Moved: Boolean;
  NewName: string;
  NewForeignKey: TSForeignKey;
  NewKey: TSKey;
  NewKeyColumn: TSKeyColumn;
  NewPartition: TSPartition;
  Parse: TSQLParse;
  Primary: Boolean;
  S: string;
  TempParse: TSQLParse;
  Unique: Boolean;
begin
  if (SQLCreateParse(Parse, PChar(SQL), Length(SQL), Session.Connection.MySQLVersion)) then
  begin
    MergeSourceTables.Clear();


    if (not SQLParseKeyword(Parse, 'CREATE')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

    Temporary := SQLParseKeyword(Parse, 'TEMPORARY');

    if (not SQLParseKeyword(Parse, 'TABLE')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

    NewName := SQLParseValue(Parse);
    if (SQLParseChar(Parse, '.')) then
    begin
      if (Session.Databases.NameCmp(Database.Name, NewName) <> 0) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);
      NewName := SQLParseValue(Parse);
    end;

    if (not SQLParseChar(Parse, '(')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

    if (not Assigned(Session.VariableByName('sql_quote_show_create'))) then
    begin
      Session.Connection.IdentifierQuoted := SQLParseChar(Parse, '`', False) or SQLParseChar(Parse, '"', False);
      if (not Assigned(Session.VariableByName('sql_mode')) and Session.Connection.IdentifierQuoted) then
        Session.Connection.AnsiQuotes := SQLParseChar(Parse, '"', False);
    end;


    DeleteList := TList.Create();
    DeleteList.Assign(FFields);
    Index := 0;
    while (Session.Connection.IdentifierQuoted and SQLParseChar(Parse, Session.Connection.IdentifierQuoter, False))
      or (not SQLParseChar(Parse, ')', False)
      and not SQLParseKeyword(Parse, 'PRIMARY', False)
      and not SQLParseKeyword(Parse, 'SPATIAL', False)
      and not SQLParseKeyword(Parse, 'KEY', False)
      and not SQLParseKeyword(Parse, 'INDEX', False)
      and not SQLParseKeyword(Parse, 'UNIQUE', False)
      and not SQLParseKeyword(Parse, 'FULLTEXT', False)
      and not SQLParseKeyword(Parse, 'CONSTRAINT', False)
      and not SQLParseKeyword(Parse, 'FOREIGN KEY', False)) do
    begin
      Assert(FFields is TSBaseFields);

      NewName := SQLParseValue(Parse);

      Moved := False;
      if (Index = FFields.Count) then
        Index := FFields.Add(TSBaseField.Create(TSBaseFields(FFields), NewName))
      else if (Index < FFields.IndexByName(NewName)) then
      begin
        FFields.Move(FFields.IndexByName(NewName), Index);
        DeleteList.Delete(DeleteList.IndexOf(FFields[Index]));
        TSBaseField(FFields[Index]).Clear();
        TSBaseField(FFields[Index]).FName := NewName;
        Moved := True;
      end
      else if (Fields.NameCmp(NewName, FFields[Index].Name) <> 0) then
        FFields.Insert(Index, TSBaseField.Create(TSBaseFields(FFields), NewName))
      else
      begin
        DeleteList.Delete(DeleteList.IndexOf(FFields[Index]));
        TSBaseField(FFields[Index]).Clear();
        TSBaseField(FFields[Index]).FName := NewName;
      end;

      Field := TSBaseField(FFields[Index]);

      // Debug 2017-03-01
      Assert(Field.OriginalName <> '');

      if (Index = 0) then
        Field.FieldBefore := nil
      else
        Field.FieldBefore := FFields.Field[Index - 1];

      try
        Field.ParseFieldType(Parse);
      except
        on E: Exception do
          E.RaiseOuterException(EAssertionFailed.CreateFmt(SSourceParseError + #13#10 + E.ClassName + ':' + E.Message, [Database.Name + '.' + Name, SQL]));
      end;

      // Debug 2017-01-15
      if (Field.FieldType = mfUnknown) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

      if (SQLParseKeyword(Parse, 'CHARACTER SET')) then
        Field.Charset := SQLParseValue(Parse);

      if (SQLParseKeyword(Parse, 'COLLATE')) then
        Field.Collation := SQLParseValue(Parse);

      SQLParseKeyword(Parse, 'GENERATED ALWAYS');

      if (SQLParseChar(Parse, ',', False) or SQLParseChar(Parse, ')', False)) then
        Field.FieldKind := mkReal
      else
        while (not SQLParseChar(Parse, ',', False) and not SQLParseChar(Parse, ')', False)) do
          if (not SQLParseKeyword(Parse, 'AS', False)) then
          begin
            Field.FieldKind := mkReal;

            if (SQLParseKeyword(Parse, 'NOT NULL')) then
              Field.NullAllowed := False
            else if (SQLParseKeyword(Parse, 'NULL')) then
              Field.NullAllowed := True
            else if (SQLParseKeyword(Parse, 'DEFAULT')) then
            begin
              if (SQLParseKeyword(Parse, 'NULL')) then
                Field.Default := 'NULL'
              else if (SQLParseKeyword(Parse, 'CURRENT_TIMESTAMP')) then
              begin
                Field.Default := 'CURRENT_TIMESTAMP';
                if (SQLParseChar(Parse, '(') and not SQLParseChar(Parse, ')')) then
                begin
                  Field.DefaultSize := SysUtils.StrToInt(SQLParseValue(Parse));
                  SQLParseChar(Parse, ')');
                end;
              end
              else if (Field.FieldType = mfBit) then
              begin
                S := SQLParseValue(Parse);
                if (LowerCase(Copy(S, 1, 1)) <> 'b') then
                begin
                  MoveMemory(@L, PAnsiChar(RawByteString(S)), Length(S));
                  Field.Default := IntToBitString(L, Field.Size);
                end
                else
                begin
                  Delete(S, 1, 1);
                  Field.Default := SQLUnescape(S);
                end;
              end
              else
              begin
                Field.Default := SQLParseValue(Parse);
                if (TryStrToInt(Field.Default, I) and SQLParseChar(Parse, '.')) then
                  Field.Default := Field.Default + '.' + SQLParseValue(Parse);
                Field.Default := SQLEscape(Field.Default);
              end;
            end
            else if (SQLParseKeyword(Parse, 'AUTO_INCREMENT')) then
              Field.AutoIncrement := True
            else if (SQLParseKeyword(Parse, 'COMMENT')) then
              Field.Comment := SQLParseValue(Parse)
            else if (SQLParseKeyword(Parse, 'COLUMN_FORMAT')) then
              Field.Format := StrToMySQLRowType(SQLParseValue(Parse))
            else if (SQLParseKeyword(Parse, 'ON UPDATE')) then
            begin
              if (SQLParseKeyword(Parse, 'CURRENT_TIMESTAMP')) then
              begin
                Field.OnUpdate := 'CURRENT_TIMESTAMP';
                if (SQLParseChar(Parse, '(') and not SQLParseChar(Parse, ')')) then
                begin
                  Field.OnUpdateSize := SysUtils.StrToInt(SQLParseValue(Parse));
                  SQLParseChar(Parse, ')');
                end;
              end
              else
                Field.OnUpdate := SQLParseValue(Parse);
            end
            else
              raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name + '.' + Field.Name, SQL]);
          end
          else if (SQLParseKeyword(Parse, 'AS')) then
          begin
            Field.FieldKind := mkVirtual;

            Field.Expression := SQLParseValue(Parse);
            if ((Length(Field.Expression) >= 2) and (Field.Expression[1] = '(') and (Field.Expression[Length(Field.Expression)] = ')')) then
              Field.Expression := Copy(Field.Expression, 1, Length(Field.Expression) - 2)
            else
              raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name + '.' + Field.Name, SQL]);

            if (SQLParseKeyword(Parse, 'VIRTUAL')) then
              Field.Stored := msVirtual
            else if ((Session.Connection.MariaDBVersion > 0) and SQLParseKeyword(Parse, 'PERSISTENT')) then
              Field.Stored := msStored
            else if ((Session.Connection.MariaDBVersion = 0) and SQLParseKeyword(Parse, 'STORED')) then
              Field.Stored := msStored;

            if (SQLParseKeyword(Parse, 'COMMENT')) then
              Field.Comment := SQLParseValue(Parse);

            if (SQLParseKeyword(Parse, 'NOT NULL')) then
              Field.NullAllowed := False
            else if (SQLParseKeyword(Parse, 'NULL')) then
              Field.NullAllowed := True;
          end
          else
            SQLParseValue(Parse);

      if (Moved) then
        Session.SendEvent(etItemRenamed, Self, FFields, Field);

      Inc(Index);
      SQLParseChar(Parse, ',');
    end;
    while (DeleteList.Count > 0) do
    begin
      FFields.Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
    FFields.FValid := True;


    DeleteList.Assign(FKeys);
    while (SQLParseKeyword(Parse, 'PRIMARY', False)
      or SQLParseKeyword(Parse, 'SPATIAL', False)
      or SQLParseKeyword(Parse, 'KEY', False)
      or SQLParseKeyword(Parse, 'INDEX', False)
      or SQLParseKeyword(Parse, 'UNIQUE', False)
      or SQLParseKeyword(Parse, 'FULLTEXT', False)) do
    begin
      Primary := SQLParseKeyword(Parse, 'PRIMARY');

      Unique := SQLParseKeyword(Parse, 'UNIQUE');

      SQLParseKeyword(Parse, 'SPATIAL');

      Fulltext := SQLParseKeyword(Parse, 'FULLTEXT');

      SQLParseKeyword(Parse, 'KEY');
      SQLParseKeyword(Parse, 'INDEX');

      if (Primary or SQLParseKeyword(Parse, 'TYPE', False) or SQLParseKeyword(Parse, 'USING', False) or SQLParseChar(Parse, '(', False)) then
        NewName := ''
      else
        NewName := SQLParseValue(Parse);


      if (not FKeys.InsertIndex(NewName, Index)) then
      begin
        DeleteList.Delete(DeleteList.IndexOf(FKeys[Index]));
        FKeys[Index].Clear();
      end
      else if (Index < FKeys.Count) then
        FKeys.Insert(Index, TSKey.Create(FKeys, NewName))
      else
        FKeys.Add(TSKey.Create(FKeys, NewName));
      NewKey := FKeys[Index];

      NewKey.PrimaryKey := Primary;
      NewKey.Unique := Unique;
      NewKey.Fulltext := FullText;

      if (SQLParseKeyword(Parse, 'TYPE') or SQLParseKeyword(Parse, 'USING')) then
        NewKey.IndexType := SQLParseValue(Parse);

      if (SQLParseChar(Parse, '(')) then
        if (SQLParseChar(Parse, ')')) then
          raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL])
        else
          repeat
            NewKeyColumn := TSKeyColumn.Create(NewKey.Columns);

            NewKeyColumn.Field := FieldByName(SQLParseValue(Parse));
            if (not Assigned(NewKeyColumn.Field)) then
              raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

            if (SQLParseChar(Parse, '(')) then
            begin
              NewKeyColumn.Length := SysUtils.StrToInt(SQLParseValue(Parse));
              SQLParseChar(Parse, ')')
            end;

            NewKey.Columns.AddColumn(NewKeyColumn);

            NewKeyColumn.Free();

            SQLParseChar(Parse, ',');
          until (SQLParseChar(Parse, ')'));

      while (not SQLParseChar(Parse, ',', False) and not SQLParseChar(Parse, ')', False)) do
      begin
        if (SQLParseKeyword(Parse, 'COMMENT')) then
          NewKey.Comment := SQLParseValue(Parse)
        else if (SQLParseKeyword(Parse, 'KEY_BLOCK_SIZE') and SQLParseChar(Parse, '=')) then
          NewKey.BlockSize := SysUtils.StrToInt(SQLParseValue(Parse))
        else if (SQLParseKeyword(Parse, 'USING')) then
          NewKey.IndexType := SQLParseValue(Parse)
        else
          SQLParseValue(Parse);
      end;

      NewKey.Unique := NewKey.Unique or NewKey.PrimaryKey;


      SQLParseChar(Parse, ',');
    end;
    while (DeleteList.Count > 0) do
    begin
      FKeys.Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
    FKeys.FValid := True;


    DeleteList.Assign(FForeignKeys);
    while (SQLParseKeyword(Parse, 'CONSTRAINT', False) or SQLParseKeyword(Parse, 'FOREIGN KEY', False)) do
    begin
      if (not SQLParseKeyword(Parse, 'CONSTRAINT')) then
        NewName := ''
      else
        NewName := SQLParseValue(Parse);// Symbol Name

      if (not SQLParseKeyword(Parse, 'FOREIGN KEY')) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

      if (not SQLParseChar(Parse, '(', False)) then
        NewName := SQLParseValue(Parse); // Index Name


      if (not FForeignKeys.InsertIndex(NewName, Index)) then
      begin
        // Debug 2017-03-30
        Assert(DeleteList.IndexOf(FForeignKeys.Items[Index]) >= 0,
          SQL);

        DeleteList.Delete(DeleteList.IndexOf(FForeignKeys.Items[Index]));
        FForeignKeys[Index].Clear();
      end
      else if (Index < FForeignKeys.Count) then
        FForeignKeys.Insert(Index, TSForeignKey.Create(FForeignKeys, NewName))
      else
        FForeignKeys.Add(TSForeignKey.Create(FForeignKeys, NewName));
      NewForeignKey := FForeignKeys[Index];

      if (not SQLParseChar(Parse, '(')) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);
      repeat
        FieldName := SQLParseValue(Parse);
        Field := FieldByName(FieldName);
        if (not Assigned(Field)) then
          raise EConvertError.CreateFmt(SInvalidForeignKeyChildField, [Database.Name + '.' + Name, FieldName, SQL]);
        SetLength(NewForeignKey.Fields, Length(NewForeignKey.Fields) + 1);
        NewForeignKey.Fields[Length(NewForeignKey.Fields) - 1] := Field;

        SQLParseChar(Parse, ',');
      until (SQLParseChar(Parse, ')'));

      if (not SQLParseKeyword(Parse, 'REFERENCES')) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

      NewForeignKey.Parent.DatabaseName := Database.Name;
      if (not SQLParseObjectName(Parse, NewForeignKey.Parent.DatabaseName, NewForeignKey.Parent.TableName)) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

      NewForeignKey.Parent.TableName := Session.TableName(NewForeignKey.Parent.TableName); // Sometimes MySQL reports parent table name in wrong case sensitive

      if (not SQLParseChar(Parse, '(')) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);
      repeat
        FieldName := SQLParseValue(Parse);
        SetLength(NewForeignKey.Parent.FieldNames, Length(NewForeignKey.Parent.FieldNames) + 1);
        NewForeignKey.Parent.FieldNames[Length(NewForeignKey.Parent.FieldNames) - 1] := FieldName;

        SQLParseChar(Parse, ',');
      until (SQLParseChar(Parse, ')'));

      if (not SQLParseKeyword(Parse, 'MATCH')) then
        NewForeignKey.Match := mtNo
      else if (not SQLParseKeyword(Parse, 'FULL')) then
        NewForeignKey.Match := mtFull
      else if (not SQLParseKeyword(Parse, 'PARTIAL')) then
        NewForeignKey.Match := mtPartial;

      if (not SQLParseKeyword(Parse, 'ON DELETE')) then
        NewForeignKey.OnDelete := dtRestrict
      else if (SQLParseKeyword(Parse, 'RESTRICT')) then
        NewForeignKey.OnDelete := dtRestrict
      else if (SQLParseKeyword(Parse, 'CASCADE')) then
        NewForeignKey.OnDelete := dtCascade
      else if (SQLParseKeyword(Parse, 'SET NULL')) then
        NewForeignKey.OnDelete := dtSetNull
      else if (SQLParseKeyword(Parse, 'SET DEFAULT')) then
        NewForeignKey.OnDelete := dtSetDefault
      else if (SQLParseKeyword(Parse, 'NO ACTION')) then
        NewForeignKey.OnDelete := dtNoAction;

      if (not SQLParseKeyword(Parse, 'ON UPDATE')) then
        NewForeignKey.OnUpdate := utRestrict
      else if (SQLParseKeyword(Parse, 'RESTRICT')) then
        NewForeignKey.OnUpdate := utRestrict
      else if (SQLParseKeyword(Parse, 'CASCADE')) then
        NewForeignKey.OnUpdate := utCascade
      else if (SQLParseKeyword(Parse, 'SET NULL')) then
        NewForeignKey.OnUpdate := utSetNull
      else if (SQLParseKeyword(Parse, 'SET DEFAULT')) then
        NewForeignKey.OnUpdate := utSetDefault
      else if (SQLParseKeyword(Parse, 'NO ACTION')) then
        NewForeignKey.OnUpdate := utNoAction;

      Inc(Index);
      SQLParseChar(Parse, ',');
    end;
    while (DeleteList.Count > 0) do
    begin
      FForeignKeys.Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
    DeleteList.Free();
    FForeignKeys.FValid := True;


    if (not SQLParseChar(Parse, ')')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

    while (not SQLParseChar(Parse, ')') and not SQLParseEnd(Parse) and not SQLParseChar(Parse, ';')) do
    begin
      if (SQLParseKeyword(Parse, 'TYPE') or SQLParseKeyword(Parse, 'ENGINE')) then
      begin
        SQLParseChar(Parse, '=');
        FEngine := Session.EngineByName(SQLParseValue(Parse));
      end
      else if (SQLParseKeyword(Parse, 'AUTO_INCREMENT')) then
      begin
        SQLParseChar(Parse, '=');
        TryStrToInt64(SQLParseValue(Parse), FAutoIncrement);
      end
      else if (SQLParseKeyword(Parse, 'CHECKSUM')) then
      begin
        SQLParseChar(Parse, '=');
        FChecksum := SQLParseValue(Parse) = '1';
      end
      else if (SQLParseKeyword(Parse, 'COLLATE')) then
      begin
        SQLParseChar(Parse, '=');
        FCollation := SQLParseValue(Parse);
      end
      else if (SQLParseKeyword(Parse, 'COMMENT')) then
      begin
        SQLParseChar(Parse, '=');
        FComment := SQLParseValue(Parse);
      end
      else if (SQLParseKeyword(Parse, 'DEFAULT CHARSET') or SQLParseKeyword(Parse, 'CHARSET')
        or SQLParseKeyword(Parse, 'DEFAULT CHARACTER SET') or SQLParseKeyword(Parse, 'CHARACTER SET')) then
      begin
        SQLParseChar(Parse, '=');
        Charset := SQLParseValue(Parse);
      end
      else if (SQLParseKeyword(Parse, 'DELAY_KEY_WRITE')) then
      begin
        SQLParseChar(Parse, '=');
        FDelayKeyWrite := SQLParseValue(Parse) = '1';
      end
      else if (SQLParseKeyword(Parse, 'INSERT_METHOD')) then
      begin
        SQLParseChar(Parse, '=');
        S := Uppercase(SQLParseValue(Parse));
        if (S = 'FIRST') then
          FInsertMethod := imFirst
        else if (S = 'LAST') then
          FInsertMethod := imLast
        else
          FInsertMethod := imNo;
      end
      else if (SQLParseKeyword(Parse, 'KEY_BLOCK_SIZE')) then
      begin
        SQLParseChar(Parse, '=');
        FBlockSize := SysUtils.StrToInt(SQLParseValue(Parse));
      end
      else if (SQLParseKeyword(Parse, 'MAX_ROWS')) then
      begin
        SQLParseChar(Parse, '=');
        FMaxRows := StrToUInt64(SQLParseValue(Parse));
      end
      else if (SQLParseKeyword(Parse, 'MIN_ROWS')) then
      begin
        SQLParseChar(Parse, '=');
        FMinRows := StrToUInt64(SQLParseValue(Parse));
      end
      else if (SQLParseKeyword(Parse, 'PACK_KEYS')) then
      begin
        SQLParseChar(Parse, '=');
        S := SQLParseValue(Parse);
        if (S = '0') then
          FPackKeys := piUnpacked
        else if (S = '1') then
          FPackKeys := piPacked
        else
          FPackKeys := piDefault;
      end
      else if (SQLParseKeyword(Parse, 'ROW_FORMAT')) then
      begin
        SQLParseChar(Parse, '=');
        FRowType := StrToMySQLRowType(SQLParseValue(Parse));
      end
      else if (SQLParseKeyword(Parse, 'PARTITION')) then
      begin
        SQLParseKeyword(Parse, 'BY');

        if (Assigned(FPartitions)) then
        begin
          FPartitions.Linear := SQLParseKeyword(Parse, 'LINEAR');

          FPartitions.PartitionType := StrToPartitionType(SQLParseValue(Parse));
          if (SQLParseChar(Parse, '(', False)) then
            FPartitions.Expression := SQLParseValue(Parse);

          if (SQLParseKeyword(Parse, 'PARTITIONS')) then
            FPartitions.PartitionsNumber := SysUtils.StrToInt(SQLParseValue(Parse));

          if (SQLParseChar(Parse, '(')) then
          begin
            while (not SQLParseEnd(Parse) and not SQLParseChar(Parse, ')')) do
            begin
              NewPartition := TSPartition.Create(FPartitions, Self);

              while (not SQLParseEnd(Parse) and not SQLParseChar(Parse, ',', False) and not SQLParseChar(Parse, ')', False)) do
              begin
                if (SQLParseKeyword(Parse, 'PARTITION')) then
                begin
                  NewPartition.FName := SQLParseValue(Parse);
                  NewPartition.FOriginalName := NewPartition.Name;
                end
                else if (SQLParseKeyword(Parse, 'VALUES')) then
                begin
                  SQLParseKeyword(Parse, 'IN');
                  SQLParseKeyword(Parse, 'LESS THAN');

                  NewPartition.ValuesExpr := SQLParseValue(Parse);
                end
                else if (SQLParseKeyword(Parse, 'ENGINE')) then
                begin
                  SQLParseChar(Parse, '=');
                  NewPartition.Engine := Session.EngineByName(SQLParseValue(Parse));
                end
                else if (SQLParseKeyword(Parse, 'COMMENT')) then
                begin
                  SQLParseChar(Parse, '=');
                  NewPartition.Comment := SQLParseValue(Parse);
                end
                else if (SQLParseKeyword(Parse, 'MAX_ROWS')) then
                begin
                  SQLParseChar(Parse, '=');
                  NewPartition.MaxRows := SysUtils.StrToInt(SQLParseValue(Parse));
                end
                else if (SQLParseKeyword(Parse, 'MIN_ROWS')) then
                begin
                  SQLParseChar(Parse, '=');
                  NewPartition.MinRows := SysUtils.StrToInt(SQLParseValue(Parse));
                end
                else
                begin
                  SQLParseValue(Parse);
                  SQLParseChar(Parse, '=');
                  SQLParseValue(Parse);
                end;
              end;

              FPartitions.AddPartition(NewPartition);
              FreeAndNil(NewPartition);

              SQLParseChar(Parse, ',');
            end;
          end;
        end;
      end
      else if (SQLParseKeyword(Parse, 'UNION')) then
      begin
        if (SQLParseChar(Parse, '(')) then
          repeat
            FMergeSourceTables.Add(TSMergeSourceTable.Create());
            FMergeSourceTables[Index].DatabaseName := Database.Name;

            if (not SQLParseObjectName(Parse, FMergeSourceTables[Index].DatabaseName, FMergeSourceTables[Index].TableName)) then
              raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);
            SQLParseChar(Parse, ',');
          until (SQLParseEnd(Parse) or SQLParseChar(Parse, ')'));
      end
      else
      begin
        SQLParseValue(Parse);
        if (SQLParseChar(Parse, '=')) then;
          SQLParseValue(Parse);
      end;

      // Subpartitioning has to be implemented
    end;

    for I := 0 to FFields.Count - 1 do
      if (FFields.Field[I] is TSBaseField) then
      begin
        TSBaseField(FFields.Field[I]).FInPrimaryKey := False;
        TSBaseField(FFields.Field[I]).FInUniqueKey := False;
        for J := 0 to FKeys.Count - 1 do
          if (J = 0) or (FKeys.Key[J].Unique) then
            for K := 0 to FKeys.Key[J].Columns.Count - 1 do
              if (TSBaseField(FFields.Field[I]) = FKeys.Key[J].Columns.Column[K].Field) then
                TSBaseField(FFields.Field[I]).FInUniqueKey := True;
      end;

    if ((FKeys.Count >= 1) and (FKeys[0].PrimaryKey)) then
      for J := 0 to FKeys.Key[0].Columns.Count - 1 do
        FKeys.Key[0].Columns.Column[J].Field.FInPrimaryKey := True;


    for I := 0 to MergeSourceTables.Count - 1 do
      References.Add(TSReference.Create(References, MergeSourceTables[I].DatabaseName, TSTable, MergeSourceTables[I].TableName));

    for I := 0 to ForeignKeys.Count - 1 do
      if (Assigned(Session.DatabaseByName(ForeignKeys[I].Parent.DatabaseName))
        and Assigned(Session.DatabaseByName(ForeignKeys[I].Parent.DatabaseName).TableByName(ForeignKeys[I].Parent.TableName))) then
        References.Add(TSReference.Create(References, ForeignKeys[I].Parent.DatabaseName, TSTable, ForeignKeys[I].Parent.TableName));


    // Debug 2017-01-15
    for I := 0 to FFields.Count - 1 do
      if (FFields[I].FieldType = mfUnknown) then
        raise ERangeError.Create('Name: ' + FFields[I].Name + #13#10
          + SQL);
  end;
end;

procedure TSBaseTable.SetName(const AName: string);
var
  I: Integer;
begin
  if ((FName <> '') and (AName <> FName) and Assigned(Database.Triggers)) then
    for I := 0 to Database.Triggers.Count - 1 do
      if (Database.Tables.NameCmp(Database.Triggers[I].FTableName, FName) = 0) then
        Database.Triggers[I].FTableName := AName;

  inherited;
end;

function TSBaseTable.SQLGetSource(): string;
begin
  Assert(Name <> '');

  Result := 'SHOW CREATE TABLE ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10;
end;

function TSBaseTable.Update(const Status: Boolean): Boolean;
var
  List: TList;
begin
  List := TList.Create();
  List.Add(Self);
  Result := Session.Update(List, True);
  List.Free();
end;

{ TSViewField *****************************************************************}

{ TSView **********************************************************************}

procedure TSView.Assign(const Source: TSTable);
begin
  inherited;

  FAlgorithm := TSView(Source).Algorithm;
  FDefiner := TSView(Source).Definer;
  FCheckOption := TSView(Source).CheckOption;
  FSecurity := TSView(Source).Security;
  FStmt := TSView(Source).Stmt;
end;

function TSView.Build(const DataSet: TMySQLQuery): Boolean;
begin
  Result := Build(DataSet.FieldByName('Create View'));
end;

function TSView.Build(const Field: TField): Boolean;
begin
  Result := inherited;

  if (Source <> '') then
    ParseCreateView(Source);
end;

constructor TSView.Create(const ACDBObjects: TSDBObjects; const AName: string = '');
begin
  inherited;

  FAlgorithm := vaUndefined;
  FCheckOption := voNone;
  FDefiner := '';
  FFields := TSViewFields.Create(Self);
  FSecurity := seDefiner;
  FStmt := '';
end;

destructor TSView.Destroy();
begin
  FFields.Free();

  inherited;
end;

function TSView.GetFields(): TSTableFields;
begin
  Result := FFields;
end;

function TSView.GetValid(): Boolean;
begin
  Result := inherited GetValid() and ValidFields;
end;

function TSView.GetValidFields(): Boolean;
begin
  Result := Fields.Valid;
end;

function TSView.GetViewFields(): TSViewFields;
begin
  Result := TSViewFields(GetFields());
end;

function TSView.GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string;
var
  SQL: string;
begin
  if (Source = '') then
    Result := ''
  else
  begin
    SQL := 'CREATE ';
    case (Algorithm) of
      vaUndefined: SQL := SQL + 'ALGORITHM=UNDEFINED ';
      vaMerge: SQL := SQL + 'ALGORITHM=MERGE ';
      vaTemptable: SQL := SQL + 'ALGORITHM=TEMPTABLE ';
    end;
    SQL := SQL + 'VIEW ' + Session.Connection.EscapeIdentifier(Name);
    SQL := SQL + ' AS ' + SQLTrimStmt(Stmt);
    if (SQL[Length(SQL)] = ';') then
      Delete(SQL, Length(SQL), 1);
    case (CheckOption) of
      voDefault: SQL := SQL + ' WITH CHECK OPTION';
      voCascaded: SQL := SQL + ' WITH CASCADED CHECK OPTION';
      voLocal: SQL := SQL + ' WITH LOCAL CHECK OPTION';
    end;
    SQL := SQL + ';' + #13#10;

    if (Session.SQLParser.ParseSQL(SQL)) then
      SQL := Session.SQLParser.FormatSQL() + #13#10;
    Session.SQLParser.Clear();

    if (DropBeforeCreate) then
      SQL := 'DROP VIEW IF EXISTS ' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10 + SQL;

    if (FullQualifiedIdentifier) then
    begin
      if (Session.SQLParser.ParseSQL(SQL)) then
        SQL := AddDatabaseName(Session.SQLParser.FirstStmt, Database.Name);
      Session.SQLParser.Clear();
    end;

    Result := SQL;
  end;
end;

procedure TSView.Invalidate();
begin
  inherited;

  Fields.Invalidate();
end;

function TSView.ParseCreateView(const SQL: string): string;
var
  DatabaseCount: Integer;
  DatabaseName: string;
  EndingCommentLen: Integer;
  Len: Integer;
  Parse: TSQLParse;
  StartingCommentLen: Integer;
  TableCount: Integer;
  TableName: string;
  Token: TSQLParser.PToken;
begin
  if (SQLCreateParse(Parse, PChar(SQL), Length(SQL), Session.Connection.MySQLVersion)) then
  begin
    Result := SQL;

    if (not SQLParseKeyword(Parse, 'CREATE')
      and not SQLParseKeyword(Parse, 'ALTER')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

    if (not SQLParseKeyword(Parse, 'ALGORITHM')) then
      Algorithm := vaUndefined
    else
    begin
      if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

      if (SQLParseKeyword(Parse, 'MERGE')) then
        FAlgorithm := vaMerge
      else if (SQLParseKeyword(Parse, 'TEMPTABLE')) then
        FAlgorithm := vaTemptable
      else if (SQLParseKeyword(Parse, 'UNDEFINED')) then
        FAlgorithm := vaUndefined
      else
        FAlgorithm := vaUndefined;
    end;

    if (SQLParseKeyword(Parse, 'DEFINER')) then
    begin
      if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);
      FDefiner := SQLParseValue(Parse);
    end;

    if (SQLParseKeyword(Parse, 'SQL SECURITY DEFINER')) then
      FSecurity := seDefiner
    else if (SQLParseKeyword(Parse, 'SQL SECURITY INVOKER')) then
      FSecurity := seInvoker;

    if (not SQLParseKeyword(Parse, 'VIEW')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

    FName := SQLParseValue(Parse);
    if (SQLParseChar(Parse, '.')) then
    begin
      if (Session.Databases.NameCmp(Database.Name, FName) <> 0) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + FName, SQL]);
      FName := SQLParseValue(Parse);
    end;

    if (not SQLParseKeyword(Parse, 'AS')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

    Len := SQLTrimStmt(SQL, SQLParseGetIndex(Parse), Length(SQL) - (SQLParseGetIndex(Parse) - 1), StartingCommentLen, EndingCommentLen);
    if (Copy(SQL, Length(SQL) - EndingCommentLen, 1) = ';') then
    begin
      Dec(Len);
      Inc(EndingCommentLen);
    end;

    if (StrIComp(PChar(RightStr(SQL, 18)), ' WITH CHECK OPTION') = 0) then
    begin
      FCheckOption := voDefault;
      Dec(Len, 18); Inc(EndingCommentLen, 18);
    end
    else if (StrIComp(PChar(RightStr(SQL, 27)), ' WITH CASCADED CHECK OPTION') = 0) then
    begin
      FCheckOption := voCascaded;
      Dec(Len, 27); Inc(EndingCommentLen, 27);
    end
    else if (StrIComp(PChar(RightStr(SQL, 24)), ' WITH LOCAL CHECK OPTION') = 0) then
    begin
      FCheckOption := voLocal;
      Dec(Len, 24); Inc(EndingCommentLen, 24);
    end
    else
      FCheckOption := voNone;

    FStmt := Copy(SQL, SQLParseGetIndex(Parse), Len) + ';';


    if (Session.SQLParser.ParseSQL(FStmt) and Assigned(Session.SQLParser.FirstStmt)) then
    begin
      DatabaseCount := 0; DatabaseName := '';
      TableCount := 0; TableName := '';
      Token := Session.SQLParser.FirstStmt^.FirstToken;
      while (Assigned(Token)) do
      begin
        if (Token^.DbIdentType = ditDatabase) then
          if (DatabaseCount = 0) then
          begin
            DatabaseName := Token^.AsString;
            DatabaseCount := 1;
          end
          else if (Session.TableNameCmp(Token^.AsString, DatabaseName) <> 0) then
            DatabaseCount := 2;
        if (Token^.DbIdentType = ditTable) then
          if (TableCount = 0) then
          begin
            TableName := Token^.AsString;
            TableCount := 1;
          end
          else if (Session.TableNameCmp(Token^.AsString, TableName) <> 0) then
            TableCount := 2;

        if (Token = Session.SQLParser.FirstStmt^.LastToken) then
          Token := nil
        else
          Token := Token^.NextToken;
      end;

      if (DatabaseCount = 1) then
        FStmt := RemoveDatabaseName(Session.SQLParser.FirstStmt, Database.Name, Session.LowerCaseTableNames = 0);

      if ((TableCount = 1) and Session.SQLParser.ParseSQL(FStmt)) then
        FStmt := RemoveTableName(Session.SQLParser.FirstStmt, TableName, Session.LowerCaseTableNames = 0);

      if (Session.SQLParser.ParseSQL(FStmt)) then
        FStmt := Session.SQLParser.FormatSQL();
    end;

    Session.SQLParser.Clear();
  end;
end;

function TSView.SQLGetSource(): string;
begin
  Result := 'SHOW CREATE VIEW ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10
    + 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('COLUMNS') + ' WHERE ' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + '=' + SQLEscape(Database.Name) + ' AND ' + Session.Connection.EscapeIdentifier('TABLE_NAME') + '=' + SQLEscape(Name) + ' ORDER BY ' + Session.Connection.EscapeIdentifier('TABLE_NAME') + ',' + Session.Connection.EscapeIdentifier('ORDINAL_POSITION') + ';' + #13#10
end;

{ TSSystemView ****************************************************************}

function TSSystemView.Build(const DataSet: TMySQLQuery): Boolean;
begin
  raise EAbstractError.Create(SAbstractError);
end;

constructor TSSystemView.Create(const ASDBObjects: TSDBObjects; const AName: string = '');
begin
  inherited;

  FFields := TSViewFields.Create(Self);
end;

destructor TSSystemView.Destroy();
begin
  FFields.Free();

  inherited;
end;

function TSSystemView.GetFields(): TSTableFields;
begin
  Result := FFields;
end;

function TSSystemView.GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string;
begin
  Result := '';
end;

function TSSystemView.GetValidFields(): Boolean;
begin
  Result := Fields.Valid;
end;

function TSSystemView.GetViewFields(): TSViewFields;
begin
  Result := TSViewFields(GetFields());
end;

function TSSystemView.SQLGetSource(): string;
begin
  Result := '';
end;

{ TSTables ********************************************************************}

function TSTables.Add(const AEntity: TSEntity; const SendEvent: Boolean = False): Integer;
begin
  if (Assigned(Database.Columns)) then Database.Columns.Invalidate();

  Result := inherited;
end;

function TSTables.AddTable(const NewTable: TSTable): Integer;
var
  I: Integer;
  TableName: string;
begin
  TableName := NewTable.Name;

  Result := TList(Self).Count - 1;
  for I := TList(Self).Count - 1 downto 0 do
    if (Session.TableNameCmp(TableName, Table[I].Name) <= 0) then
      Result := I;

  if (NewTable is TSBaseTable) then
  begin
    Insert(Result, TSBaseTable.Create(Self));
    Table[Result].Assign(TSBaseTable(NewTable));
  end
  else
  begin
    Insert(Result, TSView.Create(Self));
    Table[Result].Assign(TSView(NewTable));
  end;
end;

function TSTables.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean; Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  DeleteList: TList;
  Index: Integer;
  Item: TSItem;
  Name: string;
  NewTable: TSTable;
  RBS: RawByteString;
  TempCharset: TSCharset;
begin
  Item := nil;

  if (DataSet.FieldCount <= 2) then // SHOW [FULL] TABLES
  begin
    DeleteList := TList.Create();
    DeleteList.Assign(Self);

    if (not DataSet.IsEmpty()) then
    begin
      // Debug 2017-02-16
      Assert((Session.Connection.MySQLVersion < 50002) or Assigned(DataSet.FindField('Table_Type')),
        'SQL: ' + DataSet.CommandText + #13#10
        + 'FieldCount: ' + IntToStr(DataSet.FieldCount) + #13#10
        + 'Field[0]: ' + DataSet.Fields[0].DisplayName);

      repeat
        Name := DataSet.Fields[0].AsString;

        if (InsertIndex(Name, Index)) then
        begin
          if (Database = Session.PerformanceSchema) then
            NewTable := TSSystemView.Create(Self, Name)
          else if ((Session.Connection.MySQLVersion < 50002) or (StrIComp(PChar(DataSet.FieldByName('Table_Type').AsString), 'BASE TABLE') = 0) or (StrIComp(PChar(DataSet.FieldByName('Table_Type').AsString), 'ERROR') = 0)) then
            NewTable := TSBaseTable.Create(Self, Name)
          else if ((StrIComp(PChar(DataSet.FieldByName('Table_Type').AsString), 'SYSTEM VIEW') = 0) or ((50000 <= Session.Connection.MySQLVersion) and (Session.Connection.MySQLVersion < 50012) and (Database = Session.InformationSchema)) or (Database = Session.PerformanceSchema)) then
            NewTable := TSSystemView.Create(Self, Name)
          else if (StrIComp(PChar(DataSet.FieldByName('Table_Type').AsString), 'VIEW') = 0) then
            NewTable := TSView.Create(Self, Name)
          else
            raise EDatabaseError.CreateFmt('Unknown TABLE_TYPE "%s" for table %s.%s.' + #13#10#13#10 + 'SQL Query:' + #13#10 + '%s',
              [DataSet.FieldByName('TABLE_TYPE').AsString, Database.Name, Name, DataSet.CommandText]);

          if (Index < Count) then
            Insert(Index, NewTable)
          else
            Add(NewTable);
        end
        else if (DeleteList.IndexOf(Items[Index]) >= 0) then
          DeleteList.Delete(DeleteList.IndexOf(Items[Index]));
      until (not DataSet.FindNext());
    end;

    if (not Filtered) then
      FValid := True;

    if (not Filtered) then
      while (DeleteList.Count > 0) do
      begin
        Delete(DeleteList.Items[0]);
        DeleteList.Delete(0);
      end;
    DeleteList.Free();

    Session.SendEvent(etItemsValid, Session, Session.Databases);
    Session.SendEvent(etItemsValid, Database, Self);
  end
  else
  begin
    DeleteList := TList.Create();
    DeleteList.Assign(Self);

    if (not DataSet.IsEmpty()) then
      repeat
        if (not UseInformationSchema) then
          Name := DataSet.FieldByName('Name').AsString
        else
        begin
          // Debug 2017-02-15
          Assert(Assigned(DataSet.FindField('TABLE_NAME')),
            'FieldName: ' + DataSet.Fields[0].DisplayName + #13#10
            + DataSet.CommandText);
          Name := DataSet.FieldByName('TABLE_NAME').AsString;
        end;

        if (InsertIndex(Name, Index)) then
        begin
          if (Database = Session.PerformanceSchema) then
            NewTable := TSSystemView.Create(Self, Name)
          else if ((Session.Connection.MySQLVersion < 50002) or (StrIComp(PChar(DataSet.FieldByName('Table_Type').AsString), 'BASE TABLE') = 0) or (StrIComp(PChar(DataSet.FieldByName('Table_Type').AsString), 'ERROR') = 0)) then
            NewTable := TSBaseTable.Create(Self, Name)
          else if ((StrIComp(PChar(DataSet.FieldByName('Table_Type').AsString), 'SYSTEM VIEW') = 0) or ((50000 <= Session.Connection.MySQLVersion) and (Session.Connection.MySQLVersion < 50012) and (Database = Session.InformationSchema)) or (Database = Session.PerformanceSchema)) then
            NewTable := TSSystemView.Create(Self, Name)
          else if (StrIComp(PChar(DataSet.FieldByName('Table_Type').AsString), 'VIEW') = 0) then
            NewTable := TSView.Create(Self, Name)
          else
            raise EDatabaseError.CreateFmt('Unknown TABLE_TYPE "%s" for table %s.%s.' + #13#10#13#10 + 'SQL Query:' + #13#10 + '%s',
              [DataSet.FieldByName('TABLE_TYPE').AsString, Database.Name, Name, DataSet.CommandText]);

          if (Index < Count) then
            Insert(Index, NewTable)
          else
            Add(NewTable);
        end
        else if (DeleteList.IndexOf(Items[Index]) >= 0) then
          DeleteList.Delete(DeleteList.IndexOf(Items[Index]));

        if (Table[Index] is TSBaseTable) then
        begin
          if (not UseInformationSchema) then
          begin
            if (Assigned(DataSet.FindField('Type'))) then // MySQL < 4.1.2 and 5.0.0???
              TSBaseTable(Table[Index]).FEngine := Session.EngineByName(DataSet.FieldByName('Type').AsString)
            else
              TSBaseTable(Table[Index]).FEngine := Session.EngineByName(DataSet.FieldByName('Engine').AsString);
            TSBaseTable(Table[Index]).FRowType := StrToMySQLRowType(DataSet.FieldByName('Row_format').AsString);
            if (not TryStrToInt64(DataSet.FieldByName('Rows').AsString, TSBaseTable(Table[Index]).FRecordCount)) then TSBaseTable(Table[Index]).FRecordCount := 0;
            if (not TryStrToInt64(DataSet.FieldByName('Avg_row_length').AsString, TSBaseTable(Table[Index]).FAvgRowLength)) then TSBaseTable(Table[Index]).FAvgRowLength := 0;
            if (not TryStrToInt64(DataSet.FieldByName('Data_length').AsString, TSBaseTable(Table[Index]).FDataSize)) then TSBaseTable(Table[Index]).FDataSize := 0;
            if (not TryStrToInt64(DataSet.FieldByName('Index_length').AsString, TSBaseTable(Table[Index]).FIndexSize)) then TSBaseTable(Table[Index]).FIndexSize := 0;
            if (not TryStrToInt64(DataSet.FieldByName('Max_data_length').AsString, TSBaseTable(Table[Index]).FMaxDataSize)) then TSBaseTable(Table[Index]).FMaxDataSize := 0;
            if (not TryStrToInt64(DataSet.FieldByName('Data_free').AsString, TSBaseTable(Table[Index]).FUnusedSize)) then TSBaseTable(Table[Index]).FUnusedSize := 0;
            if (not TryStrToInt64(DataSet.FieldByName('Auto_increment').AsString, TSBaseTable(Table[Index]).FAutoIncrement)) then TSBaseTable(Table[Index]).FAutoIncrement := 0;
            if (not TryStrToDateTime(DataSet.FieldByName('Create_time').AsString, TSBaseTable(Table[Index]).FCreated)) then TSBaseTable(Table[Index]).FCreated := 0;
            if (not TryStrToDateTime(DataSet.FieldByName('Update_time').AsString, TSBaseTable(Table[Index]).FUpdated)) then TSBaseTable(Table[Index]).FUpdated := 0;
            if (not TryStrToDateTime(DataSet.FieldByName('Check_time').AsString, TSBaseTable(Table[Index]).FChecked)) then TSBaseTable(Table[Index]).FChecked := 0;
            TSBaseTable(Table[Index]).FComment := DataSet.FieldByName('Comment').AsString;
          end
          else
          begin
            TSBaseTable(Table[Index]).FEngine := Session.EngineByName(DataSet.FieldByName('ENGINE').AsString);
            TSBaseTable(Table[Index]).RowType := StrToMySQLRowType(DataSet.FieldByName('ROW_FORMAT').AsString);
            if (not TryStrToInt64(DataSet.FieldByName('TABLE_ROWS').AsString, TSBaseTable(Table[Index]).FRecordCount)) then TSBaseTable(Table[Index]).FRecordCount := 0;
            TSBaseTable(Table[Index]).FAvgRowLength := DataSet.FieldByName('AVG_ROW_LENGTH').AsInteger;
            if (not TryStrToInt64(DataSet.FieldByName('DATA_LENGTH').AsString, TSBaseTable(Table[Index]).FDataSize)) then TSBaseTable(Table[Index]).FDataSize := 0;
            if (not TryStrToInt64(DataSet.FieldByName('MAX_DATA_LENGTH').AsString, TSBaseTable(Table[Index]).FMaxDataSize)) then TSBaseTable(Table[Index]).FMaxDataSize := 0;
            if (not TryStrToInt64(DataSet.FieldByName('INDEX_LENGTH').AsString, TSBaseTable(Table[Index]).FIndexSize)) then TSBaseTable(Table[Index]).FIndexSize := 0;
            if (not TryStrToInt64(DataSet.FieldByName('DATA_FREE').AsString, TSBaseTable(Table[Index]).FUnusedSize)) then TSBaseTable(Table[Index]).FUnusedSize := 0;
            if (not TryStrToInt64(DataSet.FieldByName('AUTO_INCREMENT').AsString, TSBaseTable(Table[Index]).FAutoIncrement)) then TSBaseTable(Table[Index]).FAutoIncrement := 0;
            if (not TryStrToDateTime(DataSet.FieldByName('CREATE_TIME').AsString, TSBaseTable(Table[Index]).FCreated)) then TSBaseTable(Table[Index]).FCreated := 0;
            if (not TryStrToDateTime(DataSet.FieldByName('UPDATE_TIME').AsString, TSBaseTable(Table[Index]).FUpdated)) then TSBaseTable(Table[Index]).FUpdated := 0;
            if (not TryStrToDateTime(DataSet.FieldByName('CHECK_TIME').AsString, TSBaseTable(Table[Index]).FChecked)) then TSBaseTable(Table[Index]).FChecked := 0;
            if (Assigned(DataSet.FindField('TABLE_COLLATION'))) then
              TSBaseTable(Table[Index]).FCollation := DataSet.FieldByName('TABLE_COLLATION').AsString;
            try
              TSBaseTable(Table[Index]).FComment := DataSet.FieldByName('TABLE_COMMENT').AsString;
            except
              // Sometimes, the MySQL server sends wrong encoded table comments
              // This code allow the user to handle this table - but the comments are wrong.
              SetString(RBS,
                DataSet.LibRow^[DataSet.FieldByName('TABLE_COMMENT').FieldNo - 1],
                DataSet.LibLengths^[DataSet.FieldByName('TABLE_COMMENT').FieldNo - 1]);
              TSBaseTable(Table[Index]).FComment := string(RBS);
            end;
            TempCharset := Session.CharsetByCollation(TSBaseTable(Table[Index]).FCollation);
            if (not Assigned(TempCharset)) then
              TSBaseTable(Table[Index]).FCharset := ''
            else
              TSBaseTable(Table[Index]).FCharset := TempCharset.Name;
          end;

          if (Pos('InnoDB free: ', TSBaseTable(Table[Index]).FComment) > 0) then
          begin
            System.Delete(TSBaseTable(Table[Index]).FComment,
              Pos('InnoDB free: ', TSBaseTable(Table[Index]).FComment),
              Length(TSBaseTable(Table[Index]).FComment) - Pos('InnoDB free: ', TSBaseTable(Table[Index]).FComment) + 1);
            TSBaseTable(Table[Index]).FComment := Trim(TSBaseTable(Table[Index]).FComment);
            if (Copy(TSBaseTable(Table[Index]).FComment, System.Length(TSBaseTable(Table[Index]).FComment), 1) = ';') then
              System.Delete(TSBaseTable(Table[Index]).FComment, System.Length(TSBaseTable(Table[Index]).FComment), 1);
          end;

          TSBaseTable(Table[Index]).FValidStatus := True;
        end;

        Item := Table[Index];

        if (Assigned(ItemSearch)) then
          ItemSearch.Add(Item);
      until (not DataSet.FindNext() or (UseInformationSchema and (Session.Databases.NameCmp(DataSet.FieldByName('TABLE_SCHEMA').AsString, Database.Name) <> 0)));

    if (not Filtered) then
      FValid := True;

    if (not Filtered) then
      while (DeleteList.Count > 0) do
      begin
        Delete(DeleteList.Items[0]);
        DeleteList.Delete(0);
      end;
    DeleteList.Free();

    Session.SendEvent(etItemsValid, Session, Session.Databases);
    if (Database.Valid) then
      Session.SendEvent(etItemValid, Session, Session.Databases, Database);
    if (DataSet.RecordCount = 1) then
      Session.SendEvent(etItemValid, Database, Self, Item)
    else
      Session.SendEvent(etItemsValid, Database, Self);
  end;

  Result := False;
end;

function TSTables.BuildFields(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean): Boolean;
var
  I: Integer;
  Index: Integer;
  Name: string;
  NewField: TSTableField;
  Parse: TSQLParse;
  Table: TSTable;
begin
  Table := nil; Index := 0;

  if (DataSet.IsEmpty()) then
  begin
    if (SQLCreateParse(Parse, PChar(DataSet.CommandText), Length(DataSet.CommandText), Session.Connection.MySQLVersion)) then
    begin
      if (SQLParseKeyword(Parse, 'SELECT')) then
      begin
        if (SQLParseChar(Parse, '*')
        and SQLParseKeyword(Parse, 'FROM')
        and SQLParseValue(Parse, information_schema)
        and SQLParseChar(Parse, '.')
        and SQLParseValue(Parse, 'COLUMNS')
        and SQLParseKeyword(Parse, 'WHERE')
        and SQLParseValue(Parse, 'TABLE_SCHEMA')
        and SQLParseChar(Parse, '=')
        and SQLParseValue(Parse, PChar(Database.Name))
        and SQLParseKeyword(Parse, 'AND')
        and SQLParseValue(Parse, 'TABLE_NAME')
        and (SQLParseKeyword(Parse, 'IN') and SQLParseChar(Parse, '('))
          or (SQLParseChar(Parse, '='))) then
        repeat
          Table := Database.TableByName(SQLParseValue(Parse));
          if (Assigned(Table)) then
            Table.Fields.FValid := True;
        until (not SQLParseChar(Parse, ','));
        SQLParseChar(Parse, ')');
      end;
    end;
  end
  else
    repeat
      if (Assigned(Table) and (Database.TableByName(DataSet.FieldByName('TABLE_NAME').AsString) <> Table)) then
      begin
        while (Index < Table.Fields.Count) do
        begin
          Table.Fields[Index].Free();
          Table.Fields.Delete(Index);
        end;

        Table.Fields.FValid := True;
        Session.SendEvent(etItemValid, Database, Self, Table);
        Session.SendEvent(etItemsValid, Table, Table.Fields);

        Index := 0;
      end;

      Table := Database.TableByName(DataSet.FieldByName('TABLE_NAME').AsString);

      if (Assigned(Table)) then
      begin
        Name := DataSet.FieldByName('COLUMN_NAME').AsString;

        if (Index = Table.Fields.Count) then
          Index := Table.Fields.Add(TSViewField.Create(Table.Fields, Name))
        else if (Index < Table.Fields.IndexByName(Name)) then
        begin
          I := Table.Fields.IndexByName(Name);
          Table.Fields[I].Free();
          Table.Fields.Delete(I);
          Table.Fields.Insert(Index, TSViewField.Create(Table.Fields, Name));
        end
        else
        begin
          Table.Fields[Index].Clear();
          Table.Fields[Index].FName := Name;
        end;

        NewField := Table.Fields[Index];

        if (Index > 0) then
          NewField.FieldBefore := Table.Fields[Index - 1];

        NewField.AutoIncrement := Pos('AUTO_INCREMENT', UpperCase(DataSet.FieldByName('EXTRA').AsString)) > 0;
        NewField.Collation := DataSet.FieldByName('COLLATION_NAME').AsString;
        NewField.Comment := DataSet.FieldByName('COLUMN_COMMENT').AsString;
        NewField.Default := DataSet.FieldByName('COLUMN_DEFAULT').AsString;
        NewField.Charset := DataSet.FieldByName('CHARACTER_SET_NAME').AsString;
        if (DataSet.FieldByName('COLUMN_TYPE').IsNull
          or (DataSet.FieldByName('COLUMN_TYPE').AsString = 'null')
          or not SQLCreateParse(Parse, PChar(DataSet.FieldByName('COLUMN_TYPE').AsString), Length(DataSet.FieldByName('COLUMN_TYPE').AsString), Session.Connection.MySQLVersion)) then
          NewField.FieldType := mfUnknown
        else
          try
            NewField.ParseFieldType(Parse);
          except
            on E: Exception do
              raise Exception.Create(E.Message + ' COLUMN_TYPE: ' + DataSet.FieldByName('COLUMN_TYPE').AsString);
          end;
        NewField.FInPrimaryKey := StrIComp(PChar(DataSet.FieldByName('EXTRA').AsString), 'PRI') = 0;
        NewField.FInUniqueKey := NewField.InPrimaryKey or (StrIComp(PChar(DataSet.FieldByName('EXTRA').AsString), 'UNI') = 0);
        NewField.NullAllowed := DataSet.FieldByName('IS_NULLABLE').AsBoolean;

        Inc(Index);
      end;
    until (not DataSet.FindNext());

  if (Assigned(Table)) then
  begin
    while (Index < Table.Fields.Count) do
    begin
      Table.Fields[Index].Free();
      Table.Fields.Delete(Index);
    end;

    Table.Fields.FValid := True;
    Session.SendEvent(etItemValid, Database, Self, Table);
    Session.SendEvent(etItemsValid, Table, Table.Fields);
  end;

  Session.SendEvent(etItemsValid, Session, Session.Databases);
  Session.SendEvent(etItemsValid, Database, Self);
  if (Database.Valid) then
    Session.SendEvent(etItemValid, Session, Session.Databases, Database);

  Result := False;
end;

procedure TSTables.Delete(const AItem: TSItem; const FreeItem: Boolean = True);
begin
  if (Assigned(Database.Columns)) then Database.Columns.Invalidate();

  inherited;
end;

function TSTables.GetTable(Index: Integer): TSTable;
begin
  Result := TSTable(Items[Index]);
end;

function TSTables.GetValidStatus(): Boolean;
var
  I: Integer;
begin
  Result := Valid;

  for I := 0 to Count - 1 do
    Result := Result and (not (Table[I] is TSBaseTable) or TSBaseTable(Table[I]).ValidStatus);
end;

procedure TSTables.Invalidate();
begin
  if (Assigned(Database.Columns)) then Database.Columns.Invalidate();

  inherited;
end;

function TSTables.NameCmp(const Name1, Name2: string): Integer;
begin
  if (Session.LowerCaseTableNames = 0) then
    Result := lstrcmp(PChar(Name1), PChar(Name2))
  else
    Result := lstrcmpi(PChar(Name1), PChar(Name2));
end;

function TSTables.SQLGetItems(const Name: string = ''): string;
begin
  if (Session.Connection.MySQLVersion < 50002) then
    Result := 'SHOW TABLES FROM ' + Session.Connection.EscapeIdentifier(Database.Name) + ';' + #13#10
  else
    Result := 'SHOW FULL TABLES FROM ' + Session.Connection.EscapeIdentifier(Database.Name) + ';' + #13#10;
end;

function TSTables.SQLGetStatus(const List: TList = nil): string;
var
  I: Integer;
  Tables: TList;
begin
  Result := '';

  Tables := TList.Create();
  if (Assigned(List)) then
    Tables.Assign(List)
  else
    for I := 0 to Count - 1 do
      if ((Table[I] is TSBaseTable) and not TSBaseTable(Table[I]).ValidStatus) then
        Tables.Add(Table[I]);

  if (Session.Connection.MySQLVersion < 50003) then // 5.0.2 supports INFORMATION_SCHEMA, but the WHERE clause is supported up from 5.0.3
  begin
    if (Valid and (Tables.Count < Count)) then
    begin
      Result := '';
      for I := 0 to Tables.Count - 1 do
        Result := Result + 'SHOW TABLE STATUS FROM ' + Session.Connection.EscapeIdentifier(Database.Name) + ' LIKE ' + SQLEscape(TSTable(Tables[I]).Name) + ';' + #13#10;
    end
    else
      Result := 'SHOW TABLE STATUS FROM ' + Session.Connection.EscapeIdentifier(Database.Name) + ';' + #13#10;
  end
  else
  begin
    if (Valid and (Tables.Count < Count)) then
    begin
      for I := 0 to Tables.Count - 1 do
      begin
        if (Result <> '') then Result := Result + ',';
        Result := Result + SQLEscape(TSBaseTable(Tables[I]).Name);
      end;
      Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('TABLES')
        + ' WHERE ' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + '=' + SQLEscape(Database.Name)
        + ' AND ' + Session.Connection.EscapeIdentifier('TABLE_NAME') + ' IN (' + Result + ');' + #13#10;
    end
    else
      Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('TABLES')
        + ' WHERE ' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + '=' + SQLEscape(Database.Name) + ';' + #13#10;
  end;

  Tables.Free();
end;

function TSTables.Update(const Status: Boolean): Boolean;
var
  Objects: TList;
begin
  Objects := TList.Create();
  Objects.Add(Self);
  Result := Session.Update(Objects, Status);
  Objects.Free();
end;

{ TSRoutineParameter **********************************************************}

procedure TSRoutineParameter.Assign(const Source: TSField);
begin
  Assert(Source is TSRoutineParameter);

  inherited;

  FParameterType := TSRoutineParameter(Source).FParameterType;
end;

constructor TSRoutineParameter.Create(ARoutine: TSRoutine);
begin
  inherited Create(ARoutine.Session.FieldTypes);

  FRoutine := ARoutine;

  FParameterType := ptIn;
end;

{ TSRoutine *******************************************************************}

procedure TSRoutine.Assign(const Source: TSRoutine);
var
  I: Integer;
begin
  inherited Assign(Source);

  if (not Assigned(FDatabase)) then FDatabase := Source.FDatabase;

  Comment := Source.Comment;
  FCreated := Source.Created;
  FDefiner := Source.Definer;
  if (Assigned(Source.FFunctionResult)) then
  begin
    FFunctionResult := TSField.Create(Session.FieldTypes);
    FFunctionResult.Assign(Source.FFunctionResult);
  end;
  FUpdated := Source.Updated;
  SetLength(FParameters, Length(Source.FParameters));
  for I := 0 to Length(FParameters) - 1 do
  begin
    FParameters[I] := TSRoutineParameter.Create(Self);
    FParameters[I].Assign(Source.FParameters[I]);
  end;
  FRoutineType := Source.RoutineType;
  FSecurity := Source.Security;
  FSource := Source.Source;
  FValidSource := Source.ValidSource;
end;

function TSRoutine.Build(const Field: TField): Boolean;
begin
  Result := inherited;

  if (Source <> '') then
    ParseCreateRoutine(Source);

  Session.SendEvent(etItemValid, Database, Items, Self);
end;

constructor TSRoutine.Create(const ACDBObjects: TSDBObjects; const AName: string = '');
begin
  inherited;

  FComment := '';
  FCreated := 0;
  FDefiner := '';
  FFunctionResult := nil;
  FUpdated := 0;
  FRoutineType := rtUnknown;
  FSecurity := seDefiner;
  FStmt := '';
  SetLength(FParameters, 0);
  FValidSource := False;
end;

destructor TSRoutine.Destroy();
begin
  while (Length(FParameters) > 0) do
  begin
    FParameters[Length(FParameters) - 1].Free();
    SetLength(FParameters, Length(FParameters) - 1);
  end;

  if (Assigned(FInputDataSet)) then
  begin
    FInputDataSet.Cancel();
    FreeAndNil(FInputDataSet);
  end;
  if (Assigned(FFunctionResult)) then
    FFunctionResult.Free();

  inherited;
end;

function TSRoutine.GetInputDataSet(): TMySQLDataSet;
var
  Field: TField;
  FieldName: string;
  I: Integer;
begin
  if (Assigned(FInputDataSet) and (FInputDataSet.FieldCount <> ParameterCount)) then
    FreeAndNil(FInputDataSet);
  if (not Assigned(FInputDataSet) and (ParameterCount > 0)) then
  begin
    FInputDataSet := TMySQLDataSet.Create(nil);
    FInputDataSet.CachedUpdates := True;
    FInputDataSet.Connection := Session.Connection;
    for I := 0 to ParameterCount - 1 do
    begin
      if (not (Parameter[I].ParameterType in [ptIn, ptInOut])) then
      begin
        Field := TStringField.Create(nil);
        Field.Size := Length(OutParameterCaption);
      end
      else
        case (Parameter[I].FieldType) of
          mfBit:
            begin
              Field := TMySQLBlobField.Create(nil);
              if ((50020 <= Session.Connection.MySQLVersion) and (Session.Connection.MySQLVersion < 50100) or (Session.Connection.MySQLVersion >= 50110)) then
                Field.Size := Parameter[I].Size div 8
              else
                Field.Size := Parameter[I].Size;
              Field.Tag := ftBitField;
            end;
          mfTinyInt,
          mfSmallInt: if (not Parameter[I].Unsigned) then Field := TSmallIntField.Create(nil) else Field := TWordField.Create(nil);
          mfMediumInt,
          mfInt: if (not Parameter[I].Unsigned) then Field := TIntegerField.Create(nil) else Field := TLargeintField.Create(nil);
          mfBigInt: Field := TLargeintField.Create(nil);
          mfFloat,
          mfDouble,
          mfDecimal: Field := TFloatField.Create(nil);
          mfDate: Field := TMySQLDateField.Create(nil);
          mfDateTime: Field := TMySQLDateTimeField.Create(nil);
          mfTimeStamp:
            if (Session.Connection.MySQLVersion < 40100) then
              Field := TMySQLTimeStampField.Create(nil)
            else
              Field := TMySQLDateTimeField.Create(nil);
          mfTime: Field := TMySQLTimeField.Create(nil);
          mfYear: Field := TSmallIntField.Create(nil);
          mfChar,
          mfVarChar:
            begin
              if ((Parameter[I].Size <= $5555) and (Session.Connection.MySQLVersion >= 50000)) then
                begin Field := TMySQLWideStringField.Create(nil); Field.Size := 65535; end
              else
                begin Field := TMySQLWideMemoField.Create(nil); Field.Size := Parameter[I].Size; end;
              Field.Tag := Session.CharsetByName(Database.Charset).CodePage;
            end;
          mfBinary,
          mfVarBinary:
            begin
              Field := TMySQLBlobField.Create(nil);
              if (Parameter[I].Size > 0) then Field.Size := Parameter[I].Size and $7FFFFFFF;
            end;
          mfTinyText,
          mfText,
          mfMediumText,
          mfLongText:
            begin
                Field := TMySQLWideMemoField.Create(nil);
              if (Parameter[I].Size > 0) then Field.Size := Parameter[I].Size;
              Field.Tag := Session.CharsetByName(Database.Charset).CodePage;
            end;
          mfTinyBlob,
          mfBlob,
          mfMediumBlob,
          mfLongBlob:
            begin
              Field := TMySQLBlobField.Create(nil);
              if (Parameter[I].Size > 0) then Field.Size := Parameter[I].Size and $7FFFFFFF;
            end;
          mfEnum,
          mfSet:
            begin
              Field := TMySQLWideStringField.Create(nil);
              if (Parameter[I].Size > 0) then Field.Size := Parameter[I].Size;
              Field.Tag := Session.CharsetByName(Database.Charset).CodePage;
            end;
          mfGeometry,
          mfPoint,
          mfLineString,
          mfPolygon,
          mfMultiPoint,
          mfMultiLineString,
          mfMultiPolygon,
          mfGeometryCollection:
            begin
              Field := TMySQLBlobField.Create(nil);
              Field.Size := Parameter[I].Size and $7FFFFFFF;
              Field.Tag := ftGeometryField;
            end;
          mfJSON:
            begin
              Field := TMySQLWideStringField.Create(nil);
              if (Parameter[I].Size > 0) then Field.Size := Parameter[I].Size;
              Field.Tag := Session.CharsetByName(Database.Charset).CodePage;
            end;
          else raise EDatabaseError.CreateFMT(SUnknownFieldType + '(%s)', [Parameter[I].Name, Session.FieldTypeByMySQLFieldType(Parameter[I].FieldType).Name]);
        end;
      Field.FieldName := Parameter[I].Name;
      FieldName := ReplaceStr(ReplaceStr(ReplaceStr(ReplaceStr(Parameter[I].Name, ' ', '_'), '.', '_'), '$', '_'), '@', '_');
      Field.Name := FieldName;
      Field.DataSet := FInputDataSet;
    end;

    FInputDataSet.Open();
    if (not FInputDataSet.Active) then
      FreeAndNil(FInputDataSet)
    else
    begin
      FInputDataSet.CachedUpdates := True;
      FInputDataSet.Append();
      for I := 0 to ParameterCount - 1 do
        if (not (Parameter[I].ParameterType in [ptIn, ptInOut])) then
        begin
          FInputDataSet.Fields[I].AsString := OutParameterCaption;
          FInputDataSet.Fields[I].ReadOnly := True;
        end;
      FInputDataSet.Post();
      FInputDataSet.Edit();
    end;
  end;

  Result := FInputDataSet;
end;

function TSRoutine.GetParameter(Index: Integer): TSRoutineParameter;
begin
  Result := FParameters[Index];
end;

function TSRoutine.GetParameterCount(): Integer;
begin
  Result := Length(FParameters);
end;

function TSRoutine.GetRoutines(): TSRoutines;
begin
  Assert(Items is TSRoutines);

  Result := TSRoutines(Items);
end;

function TSRoutine.GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string;
var
  SQL: string;
begin
  SQL := FSourceEx;

  if (DropBeforeCreate) then
    if (RoutineType = rtProcedure) then
      SQL := 'DROP PROCEDURE IF EXISTS ' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10 + SQL
    else
      SQL := 'DROP FUNCTION IF EXISTS ' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10 + SQL;

  if (FullQualifiedIdentifier) then
  begin
    if (Session.SQLParser.ParseSQL(SQL)) then
      SQL := AddDatabaseName(Session.SQLParser.FirstStmt, Database.Name);
    Session.SQLParser.Clear();
  end;

  Result := SQL;
end;

procedure TSRoutine.ParseCreateRoutine(const SQL: string; const SetNameOnly: Boolean = False);
var
  Index: Integer;
  Parameter: TSRoutineParameter;
  Parse: TSQLParse;
  RemovedLength: Integer;
  S: string;
begin
  S := SQL; RemovedLength := 0;

  if (SQLCreateParse(Parse, PChar(S), Length(S), Session.Connection.MySQLVersion)) then
  begin
    while (Length(FParameters) > 0) do
    begin
      FParameters[Length(FParameters) - 1].Free();
      SetLength(FParameters, Length(FParameters) - 1);
    end;
    if (Assigned(FFunctionResult)) then
      FreeAndNil(FFunctionResult);

    if (not SQLParseKeyword(Parse, 'CREATE')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

    Index := SQLParseGetIndex(Parse);
    if (SQLParseKeyword(Parse, 'DEFINER')) then
    begin
      if (not SQLParseChar(Parse, '=')) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);
      SQLParseValue(Parse);
      Delete(S, Index - RemovedLength, SQLParseGetIndex(Parse) - Index);
      Inc(RemovedLength, SQLParseGetIndex(Parse) - Index);
    end;

    if (SQLParseKeyword(Parse, 'PROCEDURE')) then
      FRoutineType := rtProcedure
    else if (SQLParseKeyword(Parse, 'FUNCTION')) then
      FRoutineType := rtFunction
    else
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);

    FName := SQLParseValue(Parse);
    if (SQLParseChar(Parse, '.')) then
    begin
      if (Session.Databases.NameCmp(Database.Name, FName) <> 0) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + FName, SQL]);
      FName := SQLParseValue(Parse);
    end;

    if (not SetNameOnly) then
    begin
      if (SQLParseChar(Parse, '(')) then
        while (not SQLParseChar(Parse, ')')) do
        begin
          SetLength(FParameters, Length(FParameters) + 1);
          FParameters[Length(FParameters) - 1] := TSRoutineParameter.Create(Self);
          Parameter := FParameters[Length(FParameters) - 1];

          if (SQLParseKeyword(Parse, 'OUT')) then
            Parameter.FParameterType := ptOut
          else if (SQLParseKeyword(Parse, 'INOUT')) then
            Parameter.FParameterType := ptInOut
          else if (SQLParseKeyword(Parse, 'IN')) then
            Parameter.FParameterType := ptIn;

          Parameter.FName := SQLParseValue(Parse);

          try
            Parameter.ParseFieldType(Parse);
          except
            on E: Exception do
              E.RaiseOuterException(EAssertionFailed.CreateFmt(SSourceParseError + #13#10
                + E.ClassName + ':' + #13#10
                + E.Message, [Database.Name + '.' + Name, SQL]));
          end;

          if (SQLParseKeyword(Parse, 'CHARSET')) then
            Parameter.Charset := SQLParseValue(Parse)
          else if (SQLParseKeyword(Parse, 'BINARY')) then
            Parameter.Charset := 'binary';

          SQLParseChar(Parse, ',');
        end;

      if ((Self is TSFunction) and SQLParseKeyword(Parse, 'RETURNS')) then
      begin
        FFunctionResult := TSField.Create(Session.FieldTypes);

        try
          FFunctionResult.ParseFieldType(Parse);
        except
          raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, SQL]);
        end;

        if (SQLParseKeyword(Parse, 'CHARSET')) then
          FFunctionResult.Charset := SQLParseValue(Parse);
      end;

      repeat
        Index := SQLParseGetIndex(Parse);

        if (SQLParseKeyword(Parse, 'COMMENT')) then
          FComment := SQLParseValue(Parse)
        else if (SQLParseKeyword(Parse, 'LANGUAGE SQL')) then
        else if (SQLParseKeyword(Parse, 'NOT DETERMINISTIC') or SQLParseKeyword(Parse, 'DETERMINISTIC')) then
        else if (SQLParseKeyword(Parse, 'CONTAINS SQL') or SQLParseKeyword(Parse, 'NO SQL') or SQLParseKeyword(Parse, 'READS SQL DATA') or SQLParseKeyword(Parse, 'MODIFIES SQL DATA')) then
        else if (SQLParseKeyword(Parse, 'SQL SECURITY')) then
        begin
          if (StrIComp(PChar(SQLParseValue(Parse)), 'DEFINER') = 0) then
            FSecurity := seDefiner
          else
            FSecurity := seInvoker;
          Delete(S, Index - RemovedLength, SQLParseGetIndex(Parse) - Index);
          Inc(RemovedLength, SQLParseGetIndex(Parse) - Index);
        end;
      until (Index = SQLParseGetIndex(Parse));

      FStmt := SQLParseRest(Parse);

      FSourceEx := LeftStr(S, SQLParseGetIndex(Parse) - RemovedLength - 1) + #13#10;
    end;
  end;
end;

function TSRoutine.SQLGetSource(): string;
begin
  raise EAbstractError.Create(SAbstractError);
end;

function TSRoutine.SQLRun(): string;
begin
  raise EAbstractError.Create(SAbstractError);
end;

{ TSProcedure *****************************************************************}

function TSProcedure.Build(const DataSet: TMySQLQuery): Boolean;
begin
  Result := Build(DataSet.FieldByName('Create Procedure'));
end;

function TSProcedure.SQLGetSource(): string;
begin
  if ((Name = '') and (Source <> '')) then
  try
    ParseCreateRoutine(Source);
  except
    Exit('');
  end;

  Result := 'SHOW CREATE PROCEDURE ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10
end;

function TSProcedure.SQLRun(): string;
const
  ObjectIDEParameterName = 'MySQL_Front_Object_IDE_';
var
  I: Integer;
  InParameters: Boolean;
  OutParameters: Boolean;
begin
  InParameters := False; OutParameters := False;
  for I := 0 to ParameterCount - 1 do
  begin
    InParameters := InParameters or (Parameter[I].ParameterType in [ptIn, ptInOut]);
    OutParameters := OutParameters or (Parameter[I].ParameterType in [ptInOut, ptOut]);
  end;

  for I := 0 to ParameterCount - 1 do
    if (Parameter[I].ParameterType in [ptInOut]) then
    begin
      if (Result <> '') then Result := Result + ',';
      Result := '@' + ObjectIDEParameterName + Parameter[I].Name + '=' + InputDataSet.SQLFieldValue(InputDataSet.Fields[I]);
    end;
  if (Result <> '') then
    Result := 'SET ' + Result + ';' + #13#10;

  Result := Result + 'CALL ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(Name) + '(';
  for I := 0 to ParameterCount - 1 do
  begin
    if (I > 0) then Result := Result + ',';
    if (Parameter[I].ParameterType <> ptIn) then
      Result := Result + '@' + ObjectIDEParameterName + Parameter[I].Name
    else
      Result := Result + InputDataSet.SQLFieldValue(InputDataSet.Fields[I]);
  end;
  Result := Result + ');' + #13#10;

  if (OutParameters) then
  begin
    Result := Result + 'SELECT ';
    for I := 0 to ParameterCount - 1 do
    begin
      if (I > 0) then Result := Result + ',';
      if (Parameter[I].ParameterType = ptIn) then
        Result := Result + SQLEscape(InParameterCaption)
      else
        Result := Result + '@' + ObjectIDEParameterName + Parameter[I].Name;
      Result := Result + ' AS ' + Session.Connection.EscapeIdentifier(Parameter[I].Name);
    end;
    Result := Result + ';' + #13#10;
  end;
end;

{ TSFunction ******************************************************************}

function TSFunction.Build(const DataSet: TMySQLQuery): Boolean;
begin
  Result := Build(DataSet.FieldByName('Create Function'));
end;

function TSFunction.SQLGetSource(): string;
begin
  if ((Name = '') and (Source <> '')) then
    ParseCreateRoutine(Source, True);

  Result := 'SHOW CREATE FUNCTION ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10
end;

function TSFunction.SQLRun(): string;
var
  I: Integer;
begin
  Result := 'SELECT ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(Name) + '(';
  for I := 0 to ParameterCount - 1 do
  begin
    if (I > 0) then Result := Result + ',';
    if (InputDataSet.Fields[I].Value = Null) then
      Result := Result + 'NULL'
    else
      Result := Result + InputDataSet.SQLFieldValue(InputDataSet.Fields[I]);
  end;
  Result := Result + ');';
end;

{ TSRoutines ******************************************************************}

function TSRoutines.AddRoutine(const NewRoutine: TSRoutine): Integer;
begin
  if (NewRoutine is TSProcedure) then
  begin
    Result := Add(TSProcedure.Create(Self));
    TSProcedure(Items[Result]).Assign(TSProcedure(NewRoutine));
  end
  else
  begin
    Result := Add(TSFunction.Create(Self));
    TSFunction(Items[Result]).Assign(TSFunction(NewRoutine));
  end;
end;

function TSRoutines.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  DeleteList: TList;
  Index: Integer;
  Item: TSItem;
  Name: string;
  NewRoutine: TSRoutine;
  RoutineType: TSRoutine.TRoutineType;
begin
  Item := nil;

  DeleteList := TList.Create();
  DeleteList.Assign(Self);

  if (not DataSet.IsEmpty()) then
  begin
    // Debug 2017-02-16
    Assert(not UseInformationSchema or Assigned(DataSet.FieldByName('ROUTINE_SCHEMA')),
      DataSet.Fields[0].DisplayName);

    repeat
      RoutineType := rtUnknown;
      if (not UseInformationSchema) then
      begin
        Name := DataSet.FieldByName('Name').AsString;
        if (StrIComp(PChar(DataSet.FieldByName('Type').AsString), 'PROCEDURE') = 0) then
          RoutineType := rtProcedure
        else
          RoutineType := rtFunction;
      end
      else if (Session.Databases.NameCmp(DataSet.FieldByName('ROUTINE_SCHEMA').AsString, Database.Name) = 0) then
      begin
        Name := DataSet.FieldByName('ROUTINE_NAME').AsString;
        if (StrIComp(PChar(DataSet.FieldByName('ROUTINE_TYPE').AsString), 'PROCEDURE') = 0) then
          RoutineType := rtProcedure
        else
          RoutineType := rtFunction;
      end;

      if (RoutineType <> rtUnknown) then
      begin
        if (InsertIndex(Name, Index)) then
        begin
          if (RoutineType = rtProcedure) then
            NewRoutine := TSProcedure.Create(Self, Name)
          else
            NewRoutine := TSFunction.Create(Self, Name);
          if (Index < Count) then
            Insert(Index, NewRoutine)
          else
            Index := Add(NewRoutine);
        end
        else if (DeleteList.IndexOf(Items[Index]) >= 0) then
          DeleteList.Delete(DeleteList.IndexOf(Items[Index]));

        Routine[Index].FComment := DataSet.FieldByName('ROUTINE_COMMENT').AsString;
        if (DataSet.FieldByName('SECURITY_TYPE').AsString = 'INVOKER') then
          Routine[Index].FSecurity := seInvoker
        else
          Routine[Index].FSecurity := seDefiner;
        Routine[Index].FCreated := DataSet.FieldByName('CREATED').AsDateTime;
        Routine[Index].FDefiner := DataSet.FieldByName('DEFINER').AsString;
        Routine[Index].FUpdated := DataSet.FieldByName('LAST_ALTERED').AsDateTime;
        Routine[Index].FRoutineType := RoutineType;
        Routine[Index].FStmt := DataSet.FieldByName('ROUTINE_DEFINITION').AsString;

        Item := Routine[Index];

        if (Assigned(ItemSearch)) then
          ItemSearch.Add(Item);
      end;

      // Inside ROUTINE_DEFINITION there are no parameter, but for references
      // we don't need them, so we can set the references without a separated
      // SHOW CREATE PROCEDURE / FUNCTION
      // But in MySQL 5.7.14 the ROUTINE_DEFINITION does not escape strings
      // correctly like "'\\'". It will be shown as "'\'" ... and is not usable.
    until (not DataSet.FindNext() or (Session.Databases.NameCmp(DataSet.FieldByName('ROUTINE_SCHEMA').AsString, Database.Name) <> 0));
  end;

  Result := inherited or (Session.Connection.ErrorCode = ER_NO_SUCH_TABLE) or (Session.Connection.ErrorCode = ER_CANNOT_LOAD_FROM_TABLE);

  if (not Filtered) then
    while (DeleteList.Count > 0) do
    begin
      Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
  DeleteList.Free();

  Session.SendEvent(etItemsValid, Session, Session.Databases);
  if (Database.Valid) then
    Session.SendEvent(etItemValid, Session, Session.Databases, Database);
  if (DataSet.RecordCount = 1) then
    Session.SendEvent(etItemValid, Database, Self, Item)
  else
    Session.SendEvent(etItemsValid, Session, Session.Databases);
  Session.SendEvent(etItemsValid, Database, Self);
end;

function TSRoutines.GetRoutine(Index: Integer): TSRoutine;
begin
  Result := TSRoutine(Items[Index]);
end;

function TSRoutines.SQLGetItems(const Name: string = ''): string;
begin
  Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('ROUTINES')
    + ' WHERE ' + Session.Connection.EscapeIdentifier('ROUTINE_SCHEMA') + '=' + SQLEscape(Database.Name) + ';' + #13#10;
end;

{ TSTrigger *******************************************************************}

procedure TSTrigger.Assign(const Source: TSTrigger);
begin
  inherited Assign(Source);

  if (Assigned(Source.FDatabase)) then FDatabase := Source.FDatabase;

  FEvent := Source.Event;
  FDatabaseName := Source.FDatabaseName;
  FDefiner := Source.Definer;
  FStmt := Source.Stmt;
  FTableName := Source.FTableName;
  FTiming := Source.Timing;
end;

function TSTrigger.Build(const DataSet: TMySQLQuery): Boolean;
begin
  Result := Build(DataSet.FieldByName('SQL Original Statement'));
end;

function TSTrigger.Build(const Field: TField): Boolean;
begin
  Result := inherited;

  if (Source <> '') then
    ParseCreateTrigger(Source);

  Session.SendEvent(etItemValid, Database, Items, Self);
end;

constructor TSTrigger.Create(const ACDBObjects: TSDBObjects; const AName: string = '');
begin
  inherited;

  FEvent := teInsert;
  FCreated := 0;
  FDatabaseName := '';
  FDefiner := '';
  FStmt := '';
  FTiming := ttAfter;
  FValid := False;
end;

destructor TSTrigger.Destroy();
begin
  if (Assigned(FInputDataSet)) then
  begin
    FInputDataSet.Cancel();
    FreeAndNil(FInputDataSet);
  end;

  inherited;
end;

function TSTrigger.GetInputDataSet(): TMySQLDataSet;
begin
  if (not Assigned(FInputDataSet)) then
  begin
    FInputDataSet := TMySQLDataSet.Create(nil);
    FInputDataSet.Connection := Session.Connection;
    FInputDataSet.CommandText := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(FTableName) + ' LIMIT 0';
    FInputDataSet.Open();
    if (not FInputDataSet.Active) then
      FreeAndNil(FInputDataSet)
    else
    begin
      FInputDataSet.CachedUpdates := True;
      FInputDataSet.Append();
      FInputDataSet.Post();
      FInputDataSet.Edit();
    end;
  end;

  Result := FInputDataSet;
end;

function TSTrigger.GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string;
var
  SQL: string;
begin
  if (FSourceEx = '') then
  begin
    SQL := 'CREATE';
    SQL := SQL + ' TRIGGER ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(Name) + #13#10;
    case (Timing) of
      ttBefore: SQL := SQL + '  BEFORE';
      ttAfter: SQL := SQL + '  AFTER';
    end;
    SQL := SQL + ' ';
    case (Event) of
      teInsert: SQL := SQL + 'INSERT';
      teUpdate: SQL := SQL + 'UPDATE';
      teDelete: SQL := SQL + 'DELETE';
    end;
    SQL := SQL + ' ON ';
    SQL := SQL + Session.Connection.EscapeIdentifier(DatabaseName) + '.' + Session.Connection.EscapeIdentifier(TableName) + #13#10;
    SQL := SQL + '  FOR EACH ROW' + #13#10 + Stmt;
    if (RightStr(SQL, 1) <> ';') then SQL := SQL + ';';
    SQL := Trim(SQL) + #13#10;
  end
  else
    SQL := FSourceEx;

  if (DropBeforeCreate) then
    SQL := 'DROP TRIGGER IF EXISTS ' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10 + SQL;

  if (FullQualifiedIdentifier) then
  begin
    if (Session.SQLParser.ParseSQL(SQL)) then
      SQL := AddDatabaseName(Session.SQLParser.FirstStmt, Database.Name);
    Session.SQLParser.Clear();
  end;

  Result := SQL;
end;

function TSTrigger.GetTable(): TSBaseTable;
var
  Database: TSDatabase;
begin
  Database := Session.DatabaseByName(FDatabaseName);
  if (not Assigned(Database)) then
    Result := nil
  else
    Result := Database.BaseTableByName(FTableName);
end;

function TSTrigger.GetTriggers(): TSTriggers;
begin
  Assert(Items is TSTriggers);

  Result := TSTriggers(Items);
end;

procedure TSTrigger.Invalidate();
begin
  inherited;

  FValid := False;
end;

procedure TSTrigger.ParseCreateTrigger(const SQL: string);
var
  Index: Integer;
  Parse: TSQLParse;
  RemovedLength: Integer;
  S: string;
begin
  S := SQL; RemovedLength := 0;

  if (not SQLCreateParse(Parse, PChar(S), Length(S), Session.Connection.MySQLVersion)) then
    raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S])
  else
  begin
    if (not SQLParseKeyword(Parse, 'CREATE')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);

    Index := SQLParseGetIndex(Parse);
    if (SQLParseKeyword(Parse, 'DEFINER')) then
    begin
      if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);
      SQLParseValue(Parse);
      Delete(S, Index - RemovedLength, SQLParseGetIndex(Parse) - Index);
      Inc(RemovedLength, SQLParseGetIndex(Parse) - Index);
    end;

    if (not SQLParseKeyword(Parse, 'TRIGGER')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);

    S := Database.Name;
    if (not SQLParseObjectName(Parse, S, FName)) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);
    if (S <> Database.Name) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);

    if (SQLParseKeyword(Parse, 'BEFORE')) then
      FTiming := ttBefore
    else if (SQLParseKeyword(Parse, 'AFTER')) then
      FTiming := ttAfter
    else
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);

    if (SQLParseKeyword(Parse, 'INSERT')) then
      FEvent := teInsert
    else if (SQLParseKeyword(Parse, 'UPDATE')) then
      FEvent := teUpdate
    else if (SQLParseKeyword(Parse, 'DELETE')) then
      FEvent := teDelete
    else
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);

    if (not SQLParseKeyword(Parse, 'ON')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);

    if (not SQLParseObjectName(Parse, FDatabaseName, FTableName)) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);
    if (FDatabaseName = '') then
      FDatabaseName := Database.Name;

    if (not SQLParseKeyword(Parse, 'FOR EACH ROW')) then
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);

    FStmt := SQLParseRest(Parse);

    FSourceEx := LeftStr(S, SQLParseGetIndex(Parse) - RemovedLength - 1) + #13#10;

    if (Session.SQLParser.ParseSQL(FSourceEx)) then
      FSourceEx := RemoveDatabaseName(Session.SQLParser.FirstStmt, Database.Name, Session.LowerCaseTableNames = 0);
    Session.SQLParser.Clear();
  end;
end;

function TSTrigger.SQLDelete(): string;
begin
  Result := 'DELETE FROM '
    + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(TableName)
    + ' WHERE ' + InputDataSet.SQLWhereClause(True);
end;

function TSTrigger.SQLGetSource(): string;
begin
  if (Session.Connection.MySQLVersion < 50121) then
    Result := ''
  else
    Result := 'SHOW CREATE TRIGGER ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10
end;

function TSTrigger.SQLInsert(): string;
begin
  Result := InputDataSet.SQLInsert();
end;

function TSTrigger.SQLReplace(): string;
begin
  Result := SQLInsert();
  if (Result <> '') then
    Result := 'REPLACE' + RightStr(Result, Length(Result) - Length('INSERT'));
end;

function TSTrigger.SQLUpdate(): string;
var
  Valid: Boolean;
  I: Integer;
  SetClause: string;
  TableClause: string;
  WhereClause: string;
begin
  TableClause := Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(FTableName);
  SetClause := '';
  WhereClause := '';

  for I := 0 to InputDataSet.FieldCount - 1 do
    if (not (pfInWhere in InputDataSet.Fields[I].ProviderFlags) and (not InputDataSet.Fields[I].Required or not InputDataSet.Fields[I].IsNull)) then
    begin
      if (SetClause <> '') then SetClause := SetClause + ',';
      SetClause := SetClause + Session.Connection.EscapeIdentifier(InputDataSet.Fields[I].FieldName)
        + '=' + InputDataSet.SQLFieldValue(InputDataSet.Fields[I]);
    end;

  Valid := SetClause <> '';
  if (Valid) then
  begin
    for I := 0 to InputDataSet.FieldCount - 1 do
      if (pfInWhere in InputDataSet.Fields[I].ProviderFlags) then
        Valid := Valid and not InputDataSet.Fields[I].IsNull;

    if (Valid) then
      for I := 0 to InputDataSet.FieldCount - 1 do
        if ((pfInWhere in InputDataSet.Fields[I].ProviderFlags)) then
        begin
          if (WhereClause <> '') then WhereClause := WhereClause + ' AND ';
          WhereClause := WhereClause + Session.Connection.EscapeIdentifier(InputDataSet.Fields[I].FieldName)
            + '=' + InputDataSet.SQLFieldValue(InputDataSet.Fields[I]);
        end;
  end;

  if (not Valid) then
    Result := ''
  else
    Result := 'UPDATE ' + TableClause + ' SET ' + SetClause + ' WHERE ' + WhereClause + ';' + #13#10;
end;

{ TSTriggers ******************************************************************}

function TSTriggers.Add(const AEntity: TSEntity; const SendEvent: Boolean = False): Integer;
begin
  Assert(AEntity is TSTrigger);

  if (InsertIndex(AEntity.Name, Result)) then
    if (Result < TList(Self).Count) then
      TList(Self).Insert(Result, AEntity)
    else
      TList(Self).Add(AEntity);

  if (SendEvent) then
    Session.SendEvent(etItemCreated, Database, Self, AEntity);
end;

function TSTriggers.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  DeleteList: TList;
  Index: Integer;
  Item: TSItem;
  Name: string;
  SQL: string;
begin
  Item := nil;

  DeleteList := TList.Create();
  DeleteList.Assign(Self);

  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        Name := DataSet.FieldByName('Name').AsString
      else if (Session.Databases.NameCmp(DataSet.FieldByName('TRIGGER_SCHEMA').AsString, Database.Name) = 0) then
        Name := DataSet.FieldByName('TRIGGER_NAME').AsString
      else
        Name := '';

      if (Name <> '') then
      begin
        if (InsertIndex(Name, Index)) then
          if (Index < Count) then
            Insert(Index, TSTrigger.Create(Self, Name))
          else
            Add(TSTrigger.Create(Self, Name))
        else if (DeleteList.IndexOf(Items[Index]) >= 0) then
          DeleteList.Delete(DeleteList.IndexOf(Items[Index]));

        if (not UseInformationSchema) then
          raise ERangeError.Create(SRangeError)
        else
        begin
          if (StrIComp(PChar(DataSet.FieldByName('EVENT_MANIPULATION').AsString), 'INSERT') = 0) then
            Trigger[Index].FEvent := teInsert
          else if (StrIComp(PChar(DataSet.FieldByName('EVENT_MANIPULATION').AsString), 'UPDATE') = 0) then
            Trigger[Index].FEvent := teUpdate
          else if (StrIComp(PChar(DataSet.FieldByName('EVENT_MANIPULATION').AsString), 'DELETE') = 0) then
            Trigger[Index].FEvent := teDelete
          else
            raise ERangeError.Create(SRangeError);
          Trigger[Index].FName := DataSet.FieldByName('TRIGGER_NAME').AsString;
          if (Session.Connection.MySQLVersion >= 50017) then
            Trigger[Index].FDefiner := DataSet.FieldByName('DEFINER').AsString;
          Trigger[Index].FStmt := DataSet.FieldByName('ACTION_STATEMENT').AsString;
          if (RightStr(Trigger[Index].FStmt, 1) <> ';') then Trigger[Index].FStmt := Trigger[Index].FStmt + ';';
          Trigger[Index].FDatabaseName := DataSet.FieldByName('EVENT_OBJECT_SCHEMA').AsString;
          Trigger[Index].FTableName := DataSet.FieldByName('EVENT_OBJECT_TABLE').AsString;
          if (StrIComp(PChar(DataSet.FieldByName('ACTION_TIMING').AsString), 'BEFORE') = 0) then
            Trigger[Index].FTiming := ttBefore
          else if (StrIComp(PChar(DataSet.FieldByName('ACTION_TIMING').AsString), 'AFTER') = 0) then
            Trigger[Index].FTiming := ttAfter
          else
            raise ERangeError.Create(SRangeError);
          if (not TryStrToDateTime(DataSet.FieldByName('CREATED').AsString, Trigger[Index].FCreated)) then Trigger[Index].FCreated := 0;

          // Debug 2016-11-17
          if (Trigger[Index].FTableName = '') then
            raise ERangeError.Create(SRangeError);
        end;
        Trigger[Index].FValid := True;

        if (Session.Connection.MySQLVersion < 50121) then
        begin
          SQL := Trim(Trigger[Index].GetSourceEx());
          if ((SQL <> '') and (SQL[Length(SQL)] = ';')) then
            System.Delete(SQL, Length(SQL), 1);
          Trigger[Index].SetSource(SQL);
        end;

        Item := Trigger[Index];

        if (Assigned(ItemSearch)) then
          ItemSearch.Add(Item);
      end;
    until (not DataSet.FindNext() or (Session.Databases.NameCmp(DataSet.FieldByName('TRIGGER_SCHEMA').AsString, Database.Name) <> 0));

  Result := inherited;

  if (not Filtered) then
    while (DeleteList.Count > 0) do
    begin
      Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
  DeleteList.Free();

  Session.SendEvent(etItemsValid, Session, Session.Databases);
  if (Database.Valid) then
    Session.SendEvent(etItemValid, Session, Session.Databases, Database);
  if (DataSet.RecordCount = 1) then
    Session.SendEvent(etItemValid, Database, Self, Item)
  else
    Session.SendEvent(etItemsValid, Database, Self);
end;

function TSTriggers.GetTrigger(Index: Integer): TSTrigger;
begin
  Result := TSTrigger(Items[Index]);
end;

procedure TSTriggers.Invalidate();
var
  I: Integer;
begin
  inherited;

  for I := 0 to Count - 1 do
    Trigger[I].Invalidate();
end;

function TSTriggers.SQLGetItems(const Name: string = ''): string;
begin
  Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('TRIGGERS')
    + ' WHERE ' + Session.Connection.EscapeIdentifier('EVENT_OBJECT_SCHEMA') + '=' + SQLEscape(Database.Name);
  if (Name <> '') then
    Result := Result + ' AND ' + Session.Connection.EscapeIdentifier('TRIGGER_NAME') + '=' + SQLEscape(Name);
  Result := Result + ';' + #13#10;
end;

{ TSEvent *********************************************************************}

procedure TSEvent.Assign(const Source: TSEvent);
begin
  inherited Assign(Source);

  if (Assigned(Source.FDatabase)) then FDatabase := Source.FDatabase;

  FCreated := Source.Created;
  FComment := Source.Comment;
  FDefiner := Source.Definer;
  FEnabled := Source.Enabled;
  FEndDateTime := Source.EndDateTime;
  FEventType := Source.EventType;
  FExecute := Source.Execute;
  FIntervalType := Source.IntervalType;
  FIntervalValue := Source.IntervalValue;
  FPreserve := Source.Preserve;
  FStartDateTime := Source.StartDateTime;
  FStmt := Source.Stmt;
  FUpdated := Source.Updated;
end;

function TSEvent.Build(const DataSet: TMySQLQuery): Boolean;
begin
  Result := Build(DataSet.FieldByName('Create Event'));
end;

function TSEvent.Build(const Field: TField): Boolean;
begin
  Result := inherited;

  if (Source <> '') then
    ParseCreateEvent(Source);

  Session.SendEvent(etItemValid, Database, Items, Self);
end;

constructor TSEvent.Create(const ACDBObjects: TSDBObjects; const AName: string = '');
begin
  inherited;

  FCreated := 0;
  FComment := '';
  FDefiner := '';
  FEnabled := True;
  FEndDateTime := 0;
  FEventType := etUnknown;
  FExecute := 0;
  FIntervalType := itUnknown;
  FIntervalValue := '';
  FPreserve := False;
  FStartDateTime := 0;
  FStmt := '';
  FUpdated := 0;
end;

function TSEvent.GetEvents(): TSEvents;
begin
  Assert(Items is TSEvents);

  Result := TSEvents(Items);
end;

function TSEvent.GetSourceEx(const DropBeforeCreate: Boolean = False; const FullQualifiedIdentifier: Boolean = False): string;
var
  SQL: string;
begin
  SQL := FSourceEx;

  if (DropBeforeCreate) then
    SQL := 'DROP EVENT IF EXISTS ' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10 + SQL;

  if (FullQualifiedIdentifier) then
  begin
    if (Session.SQLParser.ParseSQL(SQL)) then
      SQL := AddDatabaseName(Session.SQLParser.FirstStmt, Database.Name);
    Session.SQLParser.Clear();
  end;

  Result := SQL;
end;

procedure TSEvent.ParseCreateEvent(const SQL: string);
var
  Index: Integer;
  Parse: TSQLParse;
  RemovedLength: Integer;
  S: string;
begin
  S := SQL; RemovedLength := 0;

  if (SQLCreateParse(Parse, PChar(S), Length(S), Session.Connection.MySQLVersion)) then
  begin
    if (not SQLParseKeyword(Parse, 'CREATE')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);

    Index := SQLParseGetIndex(Parse);
    if (SQLParseKeyword(Parse, 'DEFINER')) then
    begin
      if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);
      SQLParseValue(Parse);
      Delete(S, Index - RemovedLength, SQLParseGetIndex(Parse) - Index);
      Inc(RemovedLength, SQLParseGetIndex(Parse) - Index);
    end;

    if (not SQLParseKeyword(Parse, 'EVENT')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);

    FName := SQLParseValue(Parse);
    if (SQLParseChar(Parse, '.')) then
    begin
      if (Session.Databases.NameCmp(Database.Name, FName) = 0) then
        raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + FName, S]);
      FName := SQLParseValue(Parse);
    end;

    if (not SQLParseKeyword(Parse, 'ON SCHEDULE')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);

    if (SQLParseKeyword(Parse, 'AT')) then
    begin
      FExecute := MySQLDB.StrToDateTime(SQLParseValue(Parse), Session.Connection.FormatSettings);
      if (SQLParseChar(Parse, '+') and SQLParseKeyword(Parse, 'INTERVAL')) then
      begin
        FIntervalValue := SQLParseValue(Parse);
        FIntervalType := StrToIntervalType(SQLParseValue(Parse));
      end;
    end
    else if (SQLParseKeyword(Parse, 'EVERY')) then
    begin
      FIntervalValue := SQLParseValue(Parse);
      FIntervalType := StrToIntervalType(SQLParseValue(Parse));
      if (SQLParseKeyword(Parse, 'STARTS')) then
        FStartDateTime := MySQLDB.StrToDateTime(SQLParseValue(Parse), Session.Connection.FormatSettings);
      if (SQLParseKeyword(Parse, 'ENDS')) then
        FEndDateTime := MySQLDB.StrToDateTime(SQLParseValue(Parse), Session.Connection.FormatSettings);
    end
    else
      raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);

    FPreserve := SQLParseKeyword(Parse, 'ON COMPLETION PRESERVE') or not SQLParseKeyword(Parse, 'ON COMPLETION NOT PRESERVE');

    FEnabled := SQLParseKeyword(Parse, 'ENABLE');
    if (not FEnabled and SQLParseKeyword(Parse, 'DISABLE')) then
      SQLParseKeyword(Parse, 'ON SLAVE');

    if (SQLParseKeyword(Parse, 'COMMENT')) then
      FComment := SQLParseValue(Parse);

    if (not SQLParseKeyword(Parse, 'DO')) then raise EConvertError.CreateFmt(SSourceParseError, [Database.Name + '.' + Name, S]);

    FStmt := SQLParseRest(Parse);

    FSourceEx := LeftStr(S, SQLParseGetIndex(Parse) - RemovedLength - 1) + #13#10;
  end;
end;

function TSEvent.SQLGetSource(): string;
begin
  Result := 'SHOW CREATE EVENT ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10
end;

function TSEvent.SQLRun(): string;
const
  ObjectIDEEventProcedureName = 'MySQL_Front_Object_IDE_Event';
begin
  Result := 'DROP PROCEDURE IF EXISTS ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(ObjectIDEEventProcedureName) + ';' + #13#10;
  Result := Result + 'CREATE PROCEDURE ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(ObjectIDEEventProcedureName) + '()' + #13#10;
  Result := Result + Stmt + #13#10;
  Result := Result + 'CALL ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(ObjectIDEEventProcedureName) + '();' + #13#10;
  Result := Result + 'DROP PROCEDURE ' + Session.Connection.EscapeIdentifier(Database.Name) + '.' + Session.Connection.EscapeIdentifier(ObjectIDEEventProcedureName) + ';' + #13#10;
end;

{ TSEvents ********************************************************************}

function TSEvents.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  DeleteList: TList;
  Index: Integer;
  Item: TSItem;
  Name: string;
begin
  Item := nil;

  DeleteList := TList.Create();
  DeleteList.Assign(Self);

  if (not DataSet.IsEmpty()) then
    repeat
      if ((not UseInformationSchema and (DataSet.FieldByName('Db').AsString = Database.Name))
        or (UseInformationSchema and (Session.Databases.NameCmp(DataSet.FieldByName('EVENT_SCHEMA').AsString, Database.Name) = 0))) then
      begin
        if (not UseInformationSchema) then
          Name := DataSet.FieldByName('Name').AsString
        else
          Name := DataSet.FieldByName('EVENT_NAME').AsString;

        if (InsertIndex(Name, Index)) then
          if (Index < Count) then
            Insert(Index, TSEvent.Create(Self, Name))
          else
            Add(TSEvent.Create(Self, Name))
        else if (DeleteList.IndexOf(Items[Index]) >= 0) then
          DeleteList.Delete(DeleteList.IndexOf(Items[Index]));

        if (not UseInformationSchema) then
          raise ERangeError.Create(SRangeError)
        else
        begin
          Event[Index].FCreated := DataSet.FieldByName('CREATED').AsDateTime;
          Event[Index].FComment := DataSet.FieldByName('EVENT_COMMENT').AsString;
          Event[Index].FDefiner := DataSet.FieldByName('DEFINER').AsString;
          Event[Index].FEnabled := StrIComp(PChar(DataSet.FieldByName('STATUS').AsString), 'ENABLED') = 0;
          Event[Index].FEndDateTime := DataSet.FieldByName('ENDS').AsDateTime;
          Event[Index].FEventType := StrToEventType(DataSet.FieldByName('EVENT_TYPE').AsString);
          Event[Index].FExecute := DataSet.FieldByName('EXECUTE_AT').AsDateTime;
          Event[Index].FIntervalType := StrToIntervalType(DataSet.FieldByName('INTERVAL_FIELD').AsString);
          Event[Index].FIntervalValue := DataSet.FieldByName('INTERVAL_VALUE').AsString;
          Event[Index].FPreserve := StrIComp(PChar(DataSet.FieldByName('ON_COMPLETION').AsString), 'PRESERVE') = 0;
          Event[Index].FStartDateTime := DataSet.FieldByName('STARTS').AsDateTime;
          Event[Index].FStmt := DataSet.FieldByName('EVENT_DEFINITION').AsString;
          Event[Index].FUpdated := DataSet.FieldByName('LAST_ALTERED').AsDateTime;
        end;

        if (Copy(Event[Index].Stmt, Length(Event[Index].Stmt), 1) <> ';') then Event[Index].Stmt := Event[Index].Stmt + ';';

        Item := Event[Index];

        if (Assigned(ItemSearch)) then
          ItemSearch.Add(Item);
      end;
    until (not DataSet.FindNext() or (Session.Databases.NameCmp(DataSet.FieldByName('EVENT_SCHEMA').AsString, Database.Name) <> 0));

  Result := inherited or (Session.Connection.ErrorCode = ER_NO_SUCH_TABLE) or (Session.Connection.ErrorCode = ER_EVENTS_DB_ERROR);

  if (not Filtered) then
    while (DeleteList.Count > 0) do
    begin
      Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
  DeleteList.Free();

  Session.SendEvent(etItemsValid, Session, Session.Databases);
  if (Database.Valid) then
    Session.SendEvent(etItemValid, Session, Session.Databases, Database);
  if (DataSet.RecordCount = 1) then
    Session.SendEvent(etItemsValid, Database, Self, Item)
  else
    Session.SendEvent(etItemsValid, Database, Self);
end;

function TSEvents.GetEvent(Index: Integer): TSEvent;
begin
  Result := TSEvent(Items[Index]);
end;

function TSEvents.SQLGetItems(const Name: string = ''): string;
begin
  Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('EVENTS')
    + ' WHERE ' + Session.Connection.EscapeIdentifier('EVENT_SCHEMA') + '=' + SQLEscape(Database.Name) + ';' + #13#10;
end;

{ TSColumns *******************************************************************}

function TSColumns.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
begin
  if (not DataSet.IsEmpty()) then
  begin
    SetLength(Names, 1000);
    repeat
      if (DataSet.RecNo = Length(Names)) then
        SetLength(Names, Length(Names) + Length(Names) div 4);
      StrPCopy(@Names[DataSet.RecNo][0], DataSet.Fields[0].AsString);
    until (not DataSet.FindNext());
    SetLength(Names, DataSet.RecordCount);
  end;

  Result := inherited;
end;

constructor TSColumns.Create(const ASession: TSSession; const ADatabase: TSDatabase);
begin
  inherited Create(ASession);

  FDatabase := ADatabase;
end;

function TSColumns.GetColumn(Index: Integer): PChar;
begin
  Result := PChar(@Names[Index][0]);
end;

function TSColumns.GetCount(): Integer;
begin
  Result := Length(Names);
end;

procedure TSColumns.Invalidate();
begin
  SetLength(Names, 0);
  FValid := False;
end;

function TSColumns.SQLGetItems(const Name: string = ''): string;
begin
  Result := 'SELECT DISTINCT ' + Session.Connection.EscapeIdentifier('COLUMN_NAME')
    + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('COLUMNS')
    + ' WHERE ' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + '=' + SQLEscape(Database.Name)
    + ' ORDER BY ' + Session.Connection.EscapeIdentifier('COLUMN_NAME') + ';' + #13#10;
end;

{ TSDatabase ******************************************************************}

function TSDatabase.AddBaseTable(const NewTable: TSBaseTable): Boolean;
begin
  NewTable.FForeignKeys.FValid := True;
  Result := UpdateBaseTable(nil, NewTable);
end;

function TSDatabase.AddEvent(const NewEvent: TSEvent): Boolean;
begin
  Result := UpdateEvent(nil, NewEvent);
end;

function TSDatabase.AddRoutine(const NewRoutine: TSRoutine): Boolean;
begin
  Result := UpdateRoutine(nil, NewRoutine);
end;

function TSDatabase.AddTrigger(const NewTrigger: TSTrigger): Boolean;
begin
  NewTrigger.FDatabase := Self;
  Result := UpdateTrigger(nil, NewTrigger);
end;

function TSDatabase.AddView(const NewView: TSView): Boolean;
begin
  Result := UpdateView(nil, NewView);
end;

procedure TSDatabase.Assign(const Source: TSObject);
begin
  inherited Assign(Source);

  FCharset := TSDatabase(Source).Charset;
  FCollation := TSDatabase(Source).Collation;
end;

function TSDatabase.BaseTableByName(const TableName: string): TSBaseTable;
var
  Index: Integer;
begin
  Index := Tables.IndexByName(TableName);
  if ((Index < 0) or not (Tables[Index] is TSBaseTable)) then
    Result := nil
  else
    Result := TSBaseTable(Tables[Index]);
end;

function TSDatabase.Build(const DataSet: TMySQLQuery): Boolean;
begin
  Result := Build(DataSet.FieldByName('Create Database'));
end;

function TSDatabase.Build(const Field: TField): Boolean;
begin
  Result := inherited;

  ParseCreateDatabase(Source);

  Session.SendEvent(etItemValid, Session, Items, Self);
end;

function TSDatabase.CheckTables(const Tables: TList): Boolean;
var
  I: Integer;
  SQL: string;
begin
  SQL := '';
  for I := 0 to Tables.Count - 1 do
    if (TObject(Tables[I]) is TSBaseTable) then
    begin
      if (SQL <> '') then SQL := SQL + ',';
      SQL := SQL + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(TSBaseTable(Tables[I]).Name);
    end;

  Result := SQL <> '';
  if (Result) then
  begin
    RepairTableList := TList.Create();

    SQL := 'CHECK TABLE ' + SQL + ';' + #13#10;

    if (Session.Connection.DatabaseName <> Name) then
      SQL := SQLUse() + SQL;

    Result := Session.Connection.ExecuteSQL(SQL, CheckTableEvent);

    if (Result and (RepairTableList.Count > 0)) then
    begin
      SQL := '';
      for I := 0 to RepairTableList.Count - 1 do
        if (TObject(RepairTableList[I]) is TSBaseTable) then
        begin
          if (SQL <> '') then SQL := SQL + ',';
          SQL := SQL + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(TSBaseTable(RepairTableList[I]).Name);
        end;
      SQL := 'REPAIR TABLE ' + SQL + ';' + #13#10;

      Result := Session.Connection.ExecuteSQL(SQL);
    end;

    RepairTableList.Free();

    SQL := Self.Tables.SQLGetStatus(Tables);

    Session.SendSQL(SQL, Session.SessionResult);
  end;
end;

function TSDatabase.CheckTableEvent(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
  const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
var
  DatabaseName: string;
  DataSet: TMySQLQuery;
  Parse: TSQLParse;
  TableName: string;
begin
  if (Data) then
  begin
    DataSet := TMySQLQuery.Create(nil);
    DataSet.Open(DataHandle);
    if (not DataSet.IsEmpty) then
      repeat
        if ((lstrcmpi(PChar(DataSet.FieldByName('Msg_text').AsString), 'OK') <> 0)
          and SQLCreateParse(Parse, PChar(DataSet.FieldByName('Table').AsString), Length(DataSet.FieldByName('Table').AsString), Session.Connection.MySQLVersion)) then
        begin
          DatabaseName := Name;
          if (SQLParseObjectName(Parse, DatabaseName, TableName)) then
          begin
            // Debug 2017-05-12
            Assert(Assigned(Session.DatabaseByName(DatabaseName)),
              'DatabaseName: ' + DatabaseName + #13#10
              + 'Name: ' + Name + #13#10
              + 'CommandText: ' + CommandText);

            RepairTableList.Add(Session.DatabaseByName(DatabaseName).BaseTableByName(TableName));
          end;
        end;
      until (not DataSet.FindNext());
    DataSet.Free();
  end;

  Result := False;
end;

function TSDatabase.CloneEvent(const Event: TSEvent; const NewEventName: string): Boolean;
var
  DatabaseName: string;
  EventName: string;
  SQL: string;
  Parse: TSQLParse;
begin
  Session.Connection.BeginSynchron(6);
  Event.Update();
  Session.Connection.EndSynchron(6);

  if (not Session.Connection.SQLParser.ParseSQL(Event.Source)) then
    raise EConvertError.CreateFmt(SSourceParseError, [Event.Database.Name + '.' + Event.Name, Event.Source])
  else
  begin
    SQL := RemoveDatabaseName(Session.Connection.SQLParser.FirstStmt, Event.Database.Name, Session.LowerCaseTableNames = 0);
    if (not SQLCreateParse(Parse, PChar(SQL), Length(SQL), Session.Connection.MySQLVersion)) then
      raise EConvertError.CreateFmt(SSourceParseError, [Event.Database.Name + '.' + Event.Name, Event.Source])
    else
    begin
      if (not SQLParseKeyword(Parse, 'CREATE')) then raise EConvertError.CreateFmt(SSourceParseError, [Event.Database.Name + '.' + Event.Name, Event.Source]);

      if (SQLParseKeyword(Parse, 'DEFINER')) then
      begin
        if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Event.Database.Name + '.' + Event.Name, Event.Source]);
        SQLParseValue(Parse);
      end;

      if (not SQLParseKeyword(Parse, 'EVENT')) then raise EConvertError.CreateFmt(SSourceParseError, [Event.Database.Name + '.' + Event.Name, Event.Source]);

      DatabaseName := Name;
      if (not SQLParseObjectName(Parse, DatabaseName, EventName)) then raise EConvertError.CreateFmt(SSourceParseError, [Event.Database.Name + '.' + Event.Name, Event.Source]);

      SQL := 'CREATE EVENT ';
      SQL := SQL + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(NewEventName);
      SQL := SQL + RightStr(Event.Source, Length(Event.Source) - (SQLParseGetIndex(Parse) - 1));
    end;
  end;
  Session.Connection.SQLParser.Clear();

  if (Session.Connection.DatabaseName <> Name) then
    SQL := SQLUse() + SQL;

  Result := Session.SendSQL(SQL, Session.SessionResult);
end;

function TSDatabase.CloneRoutine(const Routine: TSRoutine; const NewRoutineName: string): Boolean;
var
  DatabaseName: string;
  NewRoutine: TSRoutine;
  Parse: TSQLParse;
  RoutineName: string;
  SQL: string;
begin
  Session.Connection.BeginSynchron(7);
  Routine.Update();
  Session.Connection.EndSynchron(7);

  if (not Session.Connection.SQLParser.ParseSQL(Routine.Source)) then
    raise EConvertError.CreateFmt(SSourceParseError, [Routine.Database.Name + '.' + Routine.Name, Routine.Source])
  else
  begin
    SQL := RemoveDatabaseName(Session.Connection.SQLParser.FirstStmt, Routine.Database.Name, Session.LowerCaseTableNames = 0);
    if (not SQLCreateParse(Parse, PChar(Routine.Source), Length(Routine.Source), Session.Connection.MySQLVersion)) then
      raise EConvertError.CreateFmt(SSourceParseError, [Routine.Database.Name + '.' + Routine.Name, Routine.Source])
    else
    begin
      if (not SQLParseKeyword(Parse, 'CREATE')) then raise EConvertError.CreateFmt(SSourceParseError, [Routine.Database.Name + '.' + Routine.Name, Routine.Source]);

      if (SQLParseKeyword(Parse, 'DEFINER')) then
      begin
        if (not SQLParseChar(Parse, '=')) then raise EConvertError.CreateFmt(SSourceParseError, [Routine.Database.Name + '.' + Routine.Name, Routine.Source]);
        SQLParseValue(Parse);
      end;

      if (not SQLParseKeyword(Parse, 'PROCEDURE') and not SQLParseKeyword(Parse, 'FUNCTION')) then raise EConvertError.CreateFmt(SSourceParseError, [Routine.Database.Name + '.' + Routine.Name, Routine.Source]);

      DatabaseName := Name;
      if (not SQLParseObjectName(Parse, DatabaseName, RoutineName)) then raise EConvertError.CreateFmt(SSourceParseError, [Routine.Database.Name + '.' + Routine.Name, Routine.Source]);

      if (Routine.RoutineType = rtProcedure) then
        SQL := 'CREATE PROCEDURE '
      else
        SQL := 'CREATE FUNCTION ';
      SQL := SQL + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(NewRoutineName);
      SQL := SQL + RightStr(Routine.Source, Length(Routine.Source) - (SQLParseGetIndex(Parse) - 1));
    end;
  end;

  if (Routine.RoutineType = rtProcedure) then
    NewRoutine := TSProcedure.Create(Routines, NewRoutineName)
  else
    NewRoutine := TSFunction.Create(Routines, NewRoutineName);
  SQL := SQL
    + NewRoutine.SQLGetSource();
  NewRoutine.Free();

  if ((Routine.RoutineType = rtProcedure) and Assigned(ProcedureByName(NewRoutineName))) then
    SQL := 'DROP PROCEDURE ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(NewRoutineName) + ';' + #13#10 + SQL
  else if ((Routine.RoutineType = rtFunction) and Assigned(FunctionByName(NewRoutineName))) then
    SQL := 'DROP FUNCTION ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(NewRoutineName) + ';' + #13#10 + SQL;

  if (Session.Connection.DatabaseName <> Name) then
    SQL := SQLUse() + SQL;

  Result := Session.SendSQL(SQL, Session.SessionResult);
end;

function TSDatabase.CloneTable(const Table: TSTable; const NewTableName: string; const Data: Boolean): Boolean;
var
  List: TList;
  NewBaseTable: TSBaseTable;
  NewView: TSView;
  SQL: string;
begin
  if (Table is TSBaseTable) then
  begin
    Session.Connection.BeginSynchron(8);
    Table.Update();
    Session.Connection.EndSynchron(8);

    NewBaseTable := TSBaseTable.Create(Tables);
    NewBaseTable.Assign(Table);
    NewBaseTable.Name := NewTableName;
    if (not Data) then
      NewBaseTable.AutoIncrement := 1;

    SQL := '';
    if (Assigned(TableByName(NewTableName))) then
      SQL := 'DROP TABLE ' + Session.Connection.EscapeIdentifier(NewTableName) + ';' + #13#10;

    SQL := SQL + SQLAlterTable(nil, NewBaseTable, not Data or (Session.Connection.MySQLVersion >= 40100));

    if (Data) then
    begin
      SQL := Trim(SQL);
      if (Copy(SQL, Length(SQL), 1) = ';') then
        SQL := Copy(SQL, 1, Length(SQL) - 1);
      SQL := SQL + ' SELECT * FROM ' + Session.Connection.EscapeIdentifier(Table.Database.Name) + '.' + Session.Connection.EscapeIdentifier(Table.Name) + ';' + #13#10;
    end;

    if (Data and (Session.Connection.MySQLVersion < 40100) and Assigned(TSBaseTable(Table).AutoIncrementField)) then
    begin
      SQL := SQL + 'ALTER TABLE ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(NewTableName) + #13#10;
      SQL := SQL + '  CHANGE COLUMN ' + Session.Connection.EscapeIdentifier(TSBaseTable(Table).AutoIncrementField.Name)
        + ' ' + Session.Connection.EscapeIdentifier(TSBaseTable(Table).AutoIncrementField.Name)
        + ' ' + TSBaseTable(Table).AutoIncrementField.DBTypeStr();
      if (not TSBaseTable(Table).AutoIncrementField.NullAllowed) then
        SQL := SQL + ' NOT NULL'
      else
        SQL := SQL + ' NULL';
      SQL := SQL + ' AUTO_INCREMENT;' + #13#10;
    end;

    List := TList.Create();
    List.Add(NewBaseTable);

    SQL := SQL
      + NewBaseTable.SQLGetSource()
      + Tables.SQLGetStatus(List);

    List.Free();

    NewBaseTable.Free();

    if (Session.Connection.DatabaseName <> Name) then
      SQL := SQLUse() + SQL;
  end
  else if (Table is TSView) then
  begin
    Session.Connection.BeginSynchron(9);
    Table.Update();
    Session.Connection.EndSynchron(9);

    SQL := '';
    if (Assigned(TableByName(NewTableName))) then
      SQL := 'DROP VIEW ' + Session.Connection.EscapeIdentifier(NewTableName) + ';' + #13#10;

    NewView := TSView.Create(Tables);
    NewView.Assign(Table);
    NewView.Name := NewTableName;

    SQL := SQL
      + NewView.GetSourceEx(False)
      + NewView.SQLGetSource();

    NewView.Free();

    if (Session.Connection.DatabaseName <> Name) then
      SQL := SQLUse() + SQL;
  end
  else
    SQL := '';

  Result := (SQL = '') or Session.SendSQL(SQL, Session.SessionResult);
end;

constructor TSDatabase.Create(const ADatabases: TSDatabases; const AName: string = '');
begin
  inherited Create(ADatabases, AName);

  FCollation := '';
  FCharset := '';


  if ((Session.Connection.MySQLVersion < 50000)                              ) then FColumns := nil else begin FColumns := TSColumns.Create(Session, Self); end;
  if ((Session.Connection.MySQLVersion < 50004) or (Self is TSSystemDatabase)) then FRoutines := nil else FRoutines := TSRoutines.Create(Self);
  FTables := TSTables.Create(Self);
  if ((Session.Connection.MySQLVersion < 50010) or (Self is TSSystemDatabase)) then FTriggers := nil else FTriggers := TSTriggers.Create(Self);
  if ((Session.Connection.MySQLVersion < 50106) or (Self is TSSystemDatabase)) then FEvents := nil else FEvents := TSEvents.Create(Self);
end;

function TSDatabase.DeleteObject(const DBObject: TSDBObject): Boolean;
var
  List: TList;
begin
  List := TList.Create();
  List.Add(DBObject);
  Result := Session.DeleteEntities(List);
  List.Free();
end;

destructor TSDatabase.Destroy();
begin
  FreeDesktop();

  if (Assigned(FColumns)) then FColumns.Free();
  FTables.Free();
  if (Assigned(FRoutines)) then FRoutines.Free();
  if (Assigned(FTriggers)) then FTriggers.Free();
  if (Assigned(FEvents)) then FEvents.Free();

  inherited;
end;

function TSDatabase.EventByName(const EventName: string): TSEvent;
var
  Index: Integer;
begin
  if (not Assigned(Events)) then
    Result := nil
  else
  begin
    Index := Events.IndexByName(EventName);
    if (Index < 0) then
      Result := nil
    else
      Result := Events[Index];
  end;
end;

function TSDatabase.EmptyTables(const List: TList = nil): Boolean;
var
  I: Integer;
  SQL: string;
  WorkingList: TList;
begin
  SQL := '';

  WorkingList := TList.Create();
  if (not Assigned(List)) then
    WorkingList.Assign(Self.Tables)
  else
    WorkingList.Assign(List);

  for I := 0 to WorkingList.Count - 1 do
    if (TObject(WorkingList[I]) is TSBaseTable) then
    begin
      TSBaseTable(WorkingList[I]).InvalidateStatus();
      SQL := SQL + SQLTruncateTable(TSBaseTable(WorkingList[I]));
    end;

  SQL := SQL + Tables.SQLGetStatus(WorkingList);

  WorkingList.Free();

  Result := (SQL = '') or Session.SendSQL(SQL, Session.SessionResult);
end;

function TSDatabase.FlushTables(const Tables: TList): Boolean;
var
  I: Integer;
  SQL: string;
begin
  SQL := '';
  for I := 0 to Tables.Count - 1 do
    if (TObject(Tables[I]) is TSBaseTable) then
    begin
      if (SQL <> '') then SQL := SQL + ',';
      SQL := SQL + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(TSBaseTable(Tables[I]).Name);

      TSBaseTable(Tables[I]).InvalidateStatus();
    end;
  SQL := 'FLUSH TABLE ' + SQL + ';' + #13#10;

  if (Session.Connection.DatabaseName <> Name) then
    SQL := SQLUse() + SQL;

  Result := Session.SendSQL(SQL, Session.SessionResult);
end;

procedure TSDatabase.FreeDesktop();
var
  I: Integer;
begin
  for I := 0 to Tables.Count - 1 do
  begin
    // Debug 2017-03-29
    Assert(Assigned(Tables[I]));

    Tables[I].FreeDesktop();
  end;
  if (Assigned(Routines)) then
    for I := 0 to Routines.Count - 1 do
      Routines[I].FreeDesktop();
  if (Assigned(Triggers)) then
    for I := 0 to Triggers.Count - 1 do
      Triggers[I].FreeDesktop();
  if (Assigned(Events)) then
    for I := 0 to Events.Count - 1 do
      Events[I].FreeDesktop();

  inherited;
end;

function TSDatabase.FunctionByName(const FunctionName: string): TSFunction;
var
  I: Integer;
begin
  Result := nil;

  if (Assigned(Routines)) then
    for I := 0 to Routines.Count - 1 do
      if ((lstrcmpi(PChar(Routines[I].Name), PChar(FunctionName)) = 0) and (Routines[I] is TSFunction)) then
        Result := TSFunction(Routines[I]);
end;

function TSDatabase.GetChecked(): TDateTime;
var
  I: Integer;
begin
  Result := Now();
  for I := 0 to Tables.Count - 1 do
    if (Tables[I] is TSBaseTable) then
      if ((Result = 0) or (TSBaseTable(Tables[I]).Checked < Result)) then
        Result := TSBaseTable(Tables[I]).Checked;
end;

function TSDatabase.GetCount(): Integer;
begin
  if (Tables.Valid or Assigned(Routines) and Routines.Valid or Assigned(Events) and Events.Valid) then
  begin
    Result := Tables.Count;
    if (Assigned(Routines)) then Inc(Result, Routines.Count);
    if (Assigned(Events)) then Inc(Result, Events.Count);
  end
  else
    Result := -1;
end;

function TSDatabase.GetCreated(): TDateTime;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to Tables.Count - 1 do
    if ((Tables[I] is TSBaseTable) and (TSBaseTable(Tables[I]).Created >= 0) and ((Result = 0) or (Result > TSBaseTable(Tables[I]).Created))) then
      Result := TSBaseTable(Tables[I]).Created;
end;

function TSDatabase.GetDatabases(): TSDatabases;
begin
  Assert(Items is TSDatabases);

  Result := TSDatabases(Items);
end;

function TSDatabase.GetDataSize(): Int64;
// Result in Byte
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Tables.Count - 1 do
    if ((Tables[I] is TSBaseTable) and TSBaseTable(Tables[I]).ValidStatus) then
      Inc(Result, TSBaseTable(Tables[I]).DataSize);
end;

function TSDatabase.GetIndexSize(): Int64;
// Result in Byte
var
  I: Integer;
begin
  if (not Tables.Valid) then
    Result := -1
  else
  begin
    Result := 0;
    for I := 0 to Tables.Count - 1 do
      if ((Tables[I] is TSBaseTable) and TSBaseTable(Tables[I]).ValidStatus) then
        Inc(Result, TSBaseTable(Tables[I]).IndexSize);
  end;
end;

function TSDatabase.GetUnusedSize(): Int64;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Tables.Count - 1 do
    if ((Tables[I] is TSBaseTable) and TSBaseTable(Tables[I]).ValidStatus) then
      Inc(Result, TSBaseTable(Tables[I]).UnusedSize);
end;

function TSDatabase.GetUpdated(): TDateTime;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Tables.Count - 1 do
    if ((Tables[I] is TSBaseTable) and ((Result = 0) or (TSBaseTable(Tables[I]).Updated < Result))) then
      Result := TSBaseTable(Tables[I]).Updated;
end;

function TSDatabase.GetValid(): Boolean;
begin
  Result := Assigned(Tables) and Tables.Valid
    and (not Assigned(Routines) or Routines.Valid)
    and (not Assigned(Triggers) or Triggers.Valid)
    and (not Assigned(Events) or Events.Valid);
end;

function TSDatabase.GetValidSource(): Boolean;
begin
  if (Self is TSSystemDatabase) then
    Result := True
  else if (Session.Connection.MySQLVersion < 40101) then
  begin
    if (FSource = '') then
      FSource := 'CREATE DATABASE ' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10;
    Result := True;
  end
  else
    Result := inherited;
end;

function TSDatabase.GetValidSources(): Boolean;
var
  I: Integer;
begin
  Result := ValidSource;
  for I := 0 to Tables.Count - 1 do
    Result := Result and Tables[I].ValidSource;
  if (Assigned(Routines)) then
  begin
    Result := Result and Routines.Valid;
    for I := 0 to Routines.Count - 1 do
      Result := Result and Routines[I].ValidSource;
  end;
  if (Assigned(Triggers)) then
  begin
    Result := Result and Triggers.Valid;
    for I := 0 to Triggers.Count - 1 do
      Result := Result and Triggers[I].ValidSource;
  end;
  if (Assigned(Events)) then
  begin
    Result := Result and Routines.Valid;
    for I := 0 to Events.Count - 1 do
      Result := Result and Events[I].ValidSource;
  end;
end;

procedure TSDatabase.Invalidate();
begin
  inherited;

  Tables.Invalidate();
  if (Assigned(Routines)) then
    Routines.Invalidate();
  if (Assigned(Triggers)) then
    Triggers.Invalidate();
  if (Assigned(Events)) then
    Events.Invalidate();
end;

procedure TSDatabase.InvalidateSource();
begin
  inherited Invalidate();
end;

function TSDatabase.OptimizeTables(const Tables: TList): Boolean;
var
  I: Integer;
  SQL: string;
begin
  SQL := '';
  for I := 0 to Tables.Count - 1 do
    if (TObject(Tables[I]) is TSBaseTable) then
    begin
      if (SQL <> '') then SQL := SQL + ',';
      SQL := SQL + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(TSBaseTable(Tables[I]).Name);
    end;

  Result := SQL <> '';
  if (Result) then
  begin
    SQL := 'OPTIMIZE TABLE ' + SQL + ';' + #13#10;

    SQL := SQL + Self.Tables.SQLGetStatus(Tables);

    if (Session.Connection.DatabaseName <> Name) then
      SQL := SQLUse() + SQL;

    Result := Session.SendSQL(SQL, Session.SessionResult);
  end;
end;

procedure TSDatabase.ParseCreateDatabase(const SQL: string);
var
  Parse: TSQLParse;
begin
  if (SQLCreateParse(Parse, PChar(SQL), Length(SQL), Session.Connection.MySQLVersion)) then
  begin
    if (not SQLParseKeyword(Parse, 'CREATE')) then raise EConvertError.CreateFmt(SSourceParseError, [Name, SQL]);

    SQLParseKeyword(Parse, 'OR REPLACE');

    if (not SQLParseKeyword(Parse, 'DATABASE')) then raise EConvertError.CreateFmt(SSourceParseError, [Name, SQL]);

    SQLParseKeyword(Parse, 'IF NOT EXISTS');

    FName := SQLParseValue(Parse);

    if (SQLParseKeyword(Parse, 'DEFAULT CHARACTER SET') or SQLParseKeyword(Parse, 'CHARACTER SET')) then
      FCharset := SQLParseValue(Parse)
    else
      FCharset := '';

    if (SQLParseKeyword(Parse, 'DEFAULT COLLATE') or SQLParseKeyword(Parse, 'COLLATE')) then
      FCollation := SQLParseValue(Parse)
    else if (Assigned(Session.CharsetByName(FCharset))) then
      FCollation := Session.CharsetByName(FCharset).DefaultCollation.Name
    else
      FCollation := '';
  end;
end;

function TSDatabase.ProcedureByName(const ProcedureName: string): TSProcedure;
var
  I: Integer;
begin
  Result := nil;

  if (Assigned(Routines)) then
    for I := 0 to Routines.Count - 1 do
      if ((lstrcmpi(PChar(Routines[I].Name), PChar(ProcedureName)) = 0) and (Routines[I] is TSProcedure)) then
        Result := TSProcedure(Routines[I]);
end;

procedure TSDatabase.PushBuildEvents();
begin
  Session.SendEvent(etItemsValid, Self, Tables);
  if (Assigned(Routines)) then
    Session.SendEvent(etItemsValid, Self, Routines);
  if (Assigned(Events)) then
    Session.SendEvent(etItemsValid, Self, Events);
end;

function TSDatabase.RenameTable(const Table: TSTable; const NewTableName: string): Boolean;
var
  NewView: TSView;
  SQL: string;
begin
  if (NewTableName = Table.Name) then
    Result := True
  else
  begin
    if (Assigned(Table.FDataSet)) then
    begin
      Table.FDataSet.Close();
      Table.FDataSet.CommandText := NewTableName;
    end;

    if ((Table is TSView) and (Session.Connection.MySQLVersion < 50014)) then
    begin
      NewView := TSView.Create(Tables);
      NewView.Assign(TSView(Table));
      NewView.FName := NewTableName;
      Result := UpdateView(TSView(Table), NewView);
      NewView.Free();
    end
    else
    begin
      SQL := 'RENAME TABLE ' + Session.Connection.EscapeIdentifier(Table.Database.Name) + '.' + Session.Connection.EscapeIdentifier(Table.Name) + ' TO ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(NewTableName) + ';' + #13#10;
      Result := Session.SendSQL(SQL, Session.SessionResult);
    end;
  end;
end;

procedure TSDatabase.SetName(const AName: string);
begin
  if (Session.LowerCaseTableNames = 1) then
    inherited SetName(LowerCase(AName))
  else
    inherited SetName(AName);
end;

function TSDatabase.SQLAlterTable(const Table, NewTable: TSBaseTable; const EncloseFields: Boolean): string;
var
  FieldNames: string;
  ForeignKeyAdded: Boolean;
  ForeignKeyDropClausel: string;
  Found: Boolean;
  I: Integer;
  J: Integer;
  Modified: Boolean;
  NewField: TSBaseField;
  NewForeignKey: TSForeignKey;
  NewKey: TSKey;
  NewKeyColumn: TSKeyColumn;
  NewPartition: TSPartition;
  OldField: TSBaseField;
  OldForeignKey: TSForeignKey;
  OldKey: TSKey;
  OldPartition: TSPartition;
  SQL: string;
  SQLPart: string;
begin
  if (EncloseFields) then
    for I := 0 to NewTable.Fields.Count - 1 do
    begin
      NewField := TSBaseField(NewTable.Fields.Field[I]);
      if (not Assigned(Table) or (NewField.OriginalName = '')) then
        OldField := nil
      else
        OldField := Table.FieldByName(NewField.OriginalName);
      if (not Assigned(OldField) or (not NewField.Equal(OldField) or NewField.Moved)) then
      begin
        SQLPart := '';
        if (SQL <> '') then SQLPart := SQLPart + ',' + #13#10; SQLPart := SQLPart + '  ';
        if (not Assigned(Table)) then
          SQLPart := SQLPart + Session.Connection.EscapeIdentifier(NewField.Name)
        else if (not Assigned(OldField)) then
          SQLPart := SQLPart + 'ADD COLUMN ' + Session.Connection.EscapeIdentifier(NewField.Name)
        else
          SQLPart := SQLPart + 'CHANGE COLUMN ' + Session.Connection.EscapeIdentifier(OldField.Name) + ' ' + Session.Connection.EscapeIdentifier(NewField.Name);
        SQLPart := SQLPart + ' ' + NewField.DBTypeStr();

        if (NewField.FieldKind = mkReal) then
        begin
          if ((NewField.FieldType in TextFieldTypes) and (Session.Connection.MySQLVersion >= 40101)) then
          begin
            if ((NewField.Charset <> '') and (NewField.Charset <> NewTable.Charset)) then
              SQLPart := SQLPart + ' CHARACTER SET ' + NewField.Charset;
            if ((NewField.Collation <> '') and (NewField.Collation <> NewTable.Collation)) then
              SQLPart := SQLPart + ' COLLATE ' + NewField.Collation;
          end;
          if (not NewField.NullAllowed) then SQLPart := SQLPart + ' NOT'; SQLPart := SQLPart + ' NULL';
          if (NewField.AutoIncrement) then
            SQLPart := SQLPart + ' AUTO_INCREMENT'
          else if ((NewField.Default <> '') and not (NewField.FieldType in [mfTinyText, mfText, mfMediumText, mfLongText, mfTinyBlob, mfBlob, mfMediumBlob, mfLongBlob])) then
          begin
            SQLPart := SQLPart + ' DEFAULT ' + NewField.Default;
            if (NewField.DefaultSize > 0) then
              SQLPart := SQLPart + '(' + IntToStr(NewField.DefaultSize) + ')';
          end;
          if ((NewField.OnUpdate <> '') and (NewField.FieldType = mfTimeStamp)) then
          begin
            SQLPart := SQLPart + ' ON UPDATE ' + NewField.OnUpdate;
            if (NewField.OnUpdateSize > 0) then
              SQLPart := SQLPart + '(' + IntToStr(NewField.OnUpdateSize) + ')';
          end;
          if ((Session.Connection.MySQLVersion >= 40100) and (NewField.Comment <> '')) then
            SQLPart := SQLPart + ' COMMENT ' + SQLEscape(NewField.Comment);
        end
        else if (NewField.FieldKind = mkVirtual) then
        begin
          SQLPart := SQLPart + ' AS (' + NewField.Expression + ')';
          if (NewField.Stored = msVirtual) then
            SQLPart := SQLPart + ' VIRTUAL'
          else if (NewField.Stored = msStored) then
            if (Session.Connection.MariaDBVersion > 0) then
              SQLPart := SQLPart + ' PERSISTENT'
            else
              SQLPart := SQLPart + ' STORED';
          if (NewField.Comment <> '') then
            SQLPart := SQLPart + ' COMMENT ' + SQLEscape(NewField.Comment);
          if (not NewField.NullAllowed) then
            SQLPart := SQLPart + ' NOT NULL';
        end
        else
          raise ERangeError.Create(SRangeError);
        if (Assigned(Table) and (not Assigned(OldField) or (Session.Connection.MySQLVersion >= 40001))) then
          if (not Assigned(NewField.FieldBefore) and (not Assigned(OldField) or Assigned(OldField.FieldBefore))) then
            SQLPart := SQLPart + ' FIRST'
          else if (Assigned(NewField.FieldBefore) and ((not Assigned(OldField) and Assigned(NewField.FieldBefore) and (NewField.FieldBefore.Index <> NewTable.Fields.Count - 2)) or (Assigned(OldField) and (not Assigned(OldField.FieldBefore) or (lstrcmpi(PChar(OldField.FieldBefore.Name), PChar(NewField.FieldBefore.Name)) <> 0) or (TSBaseField(NewField.FieldBefore).Moved))))) then
            SQLPart := SQLPart + ' AFTER ' + Session.Connection.EscapeIdentifier(NewField.FieldBefore.Name);

        SQL := SQL + SQLPart;
      end;
    end;

  for I := 0 to NewTable.Keys.Count - 1 do
  begin
    Modified := False;
    if (Assigned(Table)) then
      for J := 0 to Table.Keys.Count - 1 do
        if (not NewTable.Keys[I].Created and (NewTable.Keys.NameCmp(NewTable.Keys[I].OriginalName, Table.Keys[J].OriginalName) = 0)) then
          Modified := not NewTable.Keys[I].Equal(Table.Keys[J]);

    if (not Assigned(Table) or Modified or NewTable.Keys[I].Created) then
    begin
      NewKey := NewTable.Keys[I];

      SQLPart := '';
      SQLPart := SQLPart + '  ';
      if (Assigned(Table)) then SQLPart := SQLPart + 'ADD ';
      if (NewKey.PrimaryKey) then
        SQLPart := SQLPart + 'PRIMARY KEY'
      else if (NewKey.Unique) then
        SQLPart := SQLPart + 'UNIQUE INDEX'
      else if (NewKey.Fulltext) then
        SQLPart := SQLPart + 'FULLTEXT INDEX'
      else
        SQLPart := SQLPart + 'INDEX';
      if (not NewKey.PrimaryKey and (NewKey.Name <> '')) then
        SQLPart := SQLPart + ' ' + Session.Connection.EscapeIdentifier(NewKey.Name);

      if ((((40100 <= Session.Connection.MySQLVersion) and (Session.Connection.MySQLVersion < 50060)) or ((50100 <= Session.Connection.MySQLVersion) and (Session.Connection.MySQLVersion < 50110))) and (NewKey.IndexType <> '')) then
        SQLPart := SQLPart + ' USING=' + NewKey.IndexType;

      FieldNames := '';
      for J := 0 to NewKey.Columns.Count - 1 do
      begin
        if (FieldNames <> '') then FieldNames := FieldNames + ',';
        FieldNames := FieldNames + Session.Connection.EscapeIdentifier(NewKey.Columns.Column[J].Field.Name);
        if ((NewKey.Columns.Column[J].Field.FieldType in [mfChar, mfVarChar, mfTinyText, mfText, mfMediumText, mfLongText]) and (NewKey.Columns.Column[J].Length > 0)) then
          FieldNames := FieldNames + '(' + IntToStr(NewKey.Columns.Column[J].Length) + ')';
      end;
      SQLPart := SQLPart + ' (' + FieldNames + ')';

      if ((Session.Connection.MySQLVersion >= 50110) and (NewKey.BlockSize > 0)) then
        SQLPart := SQLPart + ' KEY_BLOCK_SIZE ' + IntToStr(NewKey.BlockSize);
      if ((((50060 <= Session.Connection.MySQLVersion) and (Session.Connection.MySQLVersion < 50100)) or (50110 <= Session.Connection.MySQLVersion)) and (NewKey.IndexType <> '')) then
        SQLPart := SQLPart + ' USING ' + NewKey.IndexType;
      if ((Session.Connection.MySQLVersion >= 50503) and (NewKey.Comment <> '')) then
        SQLPart := SQLPart + ' COMMENT ' + SQLEscape(NewKey.Comment);

      if (SQL <> '') then SQL := SQL + ',' + #13#10;
      SQL := SQL + SQLPart;
    end;
  end;

  ForeignKeyAdded := False;
  for I := 0 to NewTable.ForeignKeys.Count - 1 do
  begin
    Modified := False;
    if (Assigned(Table)) then
      for J := 0 to Table.ForeignKeys.Count - 1 do
        if (not NewTable.ForeignKeys[I].Created and (lstrcmpi(PChar(NewTable.ForeignKeys[I].OriginalName), PChar(Table.ForeignKeys[J].OriginalName)) = 0)) then
          Modified := not NewTable.ForeignKeys[I].Equal(Table.ForeignKeys[J]);

    if (not Assigned(Table) or Modified or NewTable.ForeignKeys[I].Created and (NewTable.ForeignKeys[I].Parent.TableName <> '')) then
    begin
      NewForeignKey := NewTable.ForeignKeys[I];

      SQLPart := '';
      if (SQL <> '') then SQLPart := SQLPart + ',' + #13#10; SQLPart := SQLPart + '  ';
      if (Assigned(Table)) then
      begin
        SQLPart := SQLPart + 'ADD ';
        ForeignKeyAdded := True;
      end;
      if (NewForeignKey.Name <> '') then
        SQLPart := SQLPart + 'CONSTRAINT ' + Session.Connection.EscapeIdentifier(NewForeignKey.Name) + ' ';
      SQLPart := SQLPart + 'FOREIGN KEY (';
      for J := 0 to Length(NewForeignKey.Fields) - 1 do
      if (Assigned(NewForeignKey.Fields[J])) then
        begin
          if (J > 0) then SQLPart := SQLPart + ',';
          SQLPart := SQLPart + Session.Connection.EscapeIdentifier(NewForeignKey.Fields[J].Name);
        end;
      SQLPart := SQLPart + ') REFERENCES ' + Session.Connection.EscapeIdentifier(NewForeignKey.Parent.DatabaseName) + '.' + Session.Connection.EscapeIdentifier(NewForeignKey.Parent.TableName) + ' (';
      for J := 0 to Length(NewForeignKey.Parent.FieldNames) - 1 do
      begin
        if (J > 0) then SQLPart := SQLPart + ',';
        SQLPart := SQLPart + Session.Connection.EscapeIdentifier(NewForeignKey.Parent.FieldNames[J]);
      end;
      SQLPart := SQLPart + ')';

      if (NewForeignKey.Match = mtFull) then
        SQLPart := SQLPart + ' MATCH FULL'
      else if (NewForeignKey.Match = mtPartial) then
        SQLPart := SQLPart + ' MATCH PARTIAL';

      if (NewForeignKey.OnDelete = dtNoAction) then SQLPart := SQLPart + ' ON DELETE NO ACTION';
      if (NewForeignKey.OnDelete = dtRestrict) then SQLPart := SQLPart + ' ON DELETE RESTRICT';
      if (NewForeignKey.OnDelete = dtCascade) then SQLPart := SQLPart + ' ON DELETE CASCADE';
      if (NewForeignKey.OnDelete = dtSetNull) then SQLPart := SQLPart + ' ON DELETE SET NULL';
      if (NewForeignKey.OnDelete = dtSetDefault) then SQLPart := SQLPart + ' ON DELETE SET DEFAULT';
      if (NewForeignKey.OnUpdate = utNoAction) then SQLPart := SQLPart + ' ON UPDATE NO ACTION';
      if (NewForeignKey.OnUpdate = utRestrict) then SQLPart := SQLPart + ' ON UPDATE RESTRICT';
      if (NewForeignKey.OnUpdate = utCascade) then SQLPart := SQLPart + ' ON UPDATE CASCADE';
      if (NewForeignKey.OnUpdate = utSetNull) then SQLPart := SQLPart + ' ON UPDATE SET NULL';
      if (NewForeignKey.OnUpdate = utSetDefault) then SQLPart := SQLPart + ' ON UPDATE SET DEFAULT';

      SQL := SQL + SQLPart;
    end;
  end;

  if (Assigned(Table)) then
    for I := 0 to Table.Fields.Count - 1 do
    begin
      OldField := TSBaseField(Table.Fields[I]);
      Found := False;
      for J := 0 to NewTable.Fields.Count - 1 do
        if (Session.TableNameCmp(TSBaseField(NewTable.Fields[J]).OriginalName, OldField.Name) = 0) then
          Found := True;
      if (not Found) then
      begin
        // Debug 2017-02-18
        for J := 0 to NewTable.Fields.Count - 1 do
          Assert(NewTable.Fields[J].Name <> OldField.Name,
            'OldField.Name: ' + OldField.Name + #13#10
            + 'NewTable.Fields[J].Name: ' + NewTable.Fields[J].Name + #13#10
            + 'NewTable.Fields[J].OriginalName: ' + NewTable.Fields[J].OriginalName + #13#10
            + SQL);

        if (SQL <> '') then SQL := SQL + ',' + #13#10;
        SQL := SQL + '  DROP COLUMN ' + Session.Connection.EscapeIdentifier(OldField.Name);
      end;
    end;

  if (Assigned(Table)) then
    for I := 0 to Table.Keys.Count - 1 do
    begin
      OldKey := Table.Keys[I];
      Modified := False;
      for J := 0 to NewTable.Keys.Count - 1 do
        if (not NewTable.Keys[J].Created and (lstrcmpi(PChar(NewTable.Keys[J].OriginalName), PChar(OldKey.Name)) = 0)) then
          Modified := NewTable.Keys[J].Equal(OldKey);
      if (not Modified) then
      begin
        if (SQL <> '') then SQL := SQL + ',' + #13#10;
        if (OldKey.Name = '') then
          SQL := SQL + '  DROP PRIMARY KEY'
        else
          SQL := SQL + '  DROP INDEX ' + Session.Connection.EscapeIdentifier(OldKey.Name);
      end;
    end;

  ForeignKeyDropClausel := '';
  if (Assigned(Table)) then
  begin
    for I := 0 to Table.ForeignKeys.Count - 1 do
    begin
      OldForeignKey := Table.ForeignKeys[I];
      Found := False;
      for J := 0 to NewTable.ForeignKeys.Count - 1 do
        if (Table.ForeignKeys.NameCmp(PChar(NewTable.ForeignKeys[J].OriginalName), PChar(OldForeignKey.Name)) = 0) then
          Found := NewTable.ForeignKeys[J].Equal(OldForeignKey);
      if (not Found) then
      begin
        if (ForeignKeyDropClausel <> '') then ForeignKeyDropClausel := ForeignKeyDropClausel + ',' + #13#10;
        ForeignKeyDropClausel := ForeignKeyDropClausel + '  DROP FOREIGN KEY ' + Session.Connection.EscapeIdentifier(OldForeignKey.Name);
      end;
    end;
    if (not ForeignKeyAdded and (ForeignKeyDropClausel <> '')) then
    begin
      if (SQL <> '') then SQL := SQL + ',' + #13#10;
      SQL := SQL + ForeignKeyDropClausel;
    end;
  end;

  if (not Assigned(Table)) then
    SQL := SQL + #13#10 + ')'
  else if (NewTable.FName <> Table.Name) then
    begin
      if (Assigned(Table)) and (SQL <> '') then SQL := SQL + ',' + #13#10;
      SQL := SQL + '  RENAME TO ' + Session.Connection.EscapeIdentifier(NewTable.Database.Name) + '.' + Session.Connection.EscapeIdentifier(NewTable.FName);
    end;

  if (Assigned(NewTable.FEngine) and (not Assigned(Table) and (NewTable.FEngine <> Session.Engines.DefaultEngine) or Assigned(Table) and (NewTable.FEngine <> Table.Engine))) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    if ((Session.Connection.MySQLVersion < 40102) and Assigned(NewTable.FEngine)) then
      SQL := SQL + '  TYPE=' + NewTable.FEngine.Name
    else
      SQL := SQL + '  ENGINE=' + NewTable.FEngine.Name;
  end;
  if ((not Assigned(Table) or Assigned(Table) and (NewTable.FAutoIncrement <> Table.AutoIncrement)) and (NewTable.FAutoIncrement > 0)) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    SQL := SQL + '  AUTO_INCREMENT=' + IntToStr(NewTable.FAutoIncrement);
  end;
  if ((not Assigned(Table) and NewTable.Checksum or Assigned(Table) and (NewTable.Checksum <> Table.Checksum))) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    if (not NewTable.Checksum) then
      SQL := SQL + '  CHECKSUM=0'
    else
      SQL := SQL + '  CHECKSUM=1';
  end;
  if (not Assigned(Table) and (NewTable.FComment <> '') or Assigned(Table) and (NewTable.FComment <> Table.Comment) and (Session.Connection.MySQLVersion >= 40100)) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    SQL := SQL + '  COMMENT=' + SQLEscape(NewTable.FComment);
  end;
  if (Session.Connection.MySQLVersion >= 40100) then
  begin
    if ((NewTable.Charset <> '') and (not Assigned(Table) or (NewTable.FCharset <> Table.Charset))) then
    begin
      if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
      SQL := SQL + '  DEFAULT CHARSET=' + NewTable.Charset;
    end;
    if ((NewTable.Collation <> '') and (not Assigned(Table) or (NewTable.Collation <> Table.Collation))) then
    begin
      if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
      SQL := SQL + '  COLLATE=' + NewTable.Collation;
    end;
  end;
  if ((not Assigned(Table) and NewTable.DelayKeyWrite or Assigned(Table) and (NewTable.DelayKeyWrite <> Table.DelayKeyWrite))) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    if (not NewTable.DelayKeyWrite) then
      SQL := SQL + '  DELAY_KEY_WRITE=0'
    else
      SQL := SQL + '  DELAY_KEY_WRITE=1';
  end;
  if (((not Assigned(Table) and (NewTable.InsertMethod <> imNo) or Assigned(Table) and (NewTable.Checksum <> Table.Checksum))) and (Session.Connection.MySQLVersion >= 40000)) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    case (NewTable.InsertMethod) of
      imFirst: SQL := SQL + ' INSERT_METHOD=FIRST';
      imLast: SQL := SQL + ' INSERT_METHOD=LAST';
      else {imNo} SQL := SQL + ' INSERT_METHOD=NO';
    end;
  end;
  if (not Assigned(Table) and (NewTable.BlockSize > 0) or Assigned(Table) and (NewTable.BlockSize <> Table.BlockSize)) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    SQL := SQL + '  KEY_BLOCK_SIZE=' + IntToStr(NewTable.BlockSize);
  end;
  if (not Assigned(Table) and (NewTable.MaxRows > 0) or Assigned(Table) and (NewTable.MaxRows <> Table.MaxRows)) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    SQL := SQL + '  MAX_ROWS=' + SQLEscape(IntToStr(NewTable.MaxRows));
  end;
  if (not Assigned(Table) and (NewTable.MinRows > 0) or Assigned(Table) and (NewTable.MinRows <> Table.MinRows)) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    SQL := SQL + '  MIN_ROWS=' + SQLEscape(IntToStr(NewTable.MinRows));
  end;
  if (not Assigned(Table) and (NewTable.FPackKeys <> piDefault) or Assigned(Table) and (NewTable.FPackKeys <> Table.PackKeys)) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    case (NewTable.FPackKeys) of
      piUnpacked: SQL := SQL + '  PACK_KEYS=0';
      piPacked: SQL := SQL + '  PACK_KEYS=1';
      else {piDefault} SQL := SQL + '  PACK_KEYS=DEFAULT';
    end;
  end;
  if ((not Assigned(Table) and (NewTable.FRowType <> mrUnknown) or Assigned(Table) and (NewTable.FRowType <> Table.RowType)) and (NewTable.DBRowTypeStr() <> '')) then
  begin
    if (Assigned(Table) and (SQL <> '')) then SQL := SQL + ',' + #13#10;
    SQL := SQL + '  ROW_FORMAT=' + NewTable.DBRowTypeStr();
  end;

  if (Assigned(Table) and Assigned(Table.Partitions) and (Table.Partitions.PartitionType <> ptNone) and (NewTable.Partitions.PartitionType = ptNone)) then
    SQL := SQL + '  REMOVE PARTITIONING'
  else if (Assigned(NewTable.Partitions) and (NewTable.Partitions.PartitionType <> ptNone)) then
  begin
    if (not Assigned(Table) or (NewTable.Partitions.PartitionType <> Table.Partitions.PartitionType) or (NewTable.Partitions.Expression <> Table.Partitions.Expression) or (NewTable.Partitions.PartitionsNumber <> Table.Partitions.PartitionsNumber)) then
    begin
      if (Assigned(Table) and (SQL <> '')) then SQL := SQL + #13#10;
      SQL := SQL + '  PARTITION BY ';
      if (NewTable.Partitions.Linear) then
        SQL := SQL + 'LINEAR ';
      case (NewTable.Partitions.PartitionType) of
        ptHash: SQL := SQL + 'HASH(' + NewTable.Partitions.Expression + ')';
        ptKey: SQL := SQL + 'KEY';
        ptRange: SQL := SQL + 'RANGE(' + NewTable.Partitions.Expression + ')';
        ptList: SQL := SQL + 'LIST(' + NewTable.Partitions.Expression + ')';
      end;
      if (NewTable.Partitions.PartitionsNumber > 0) then
        SQL := SQL + ' PARTITIONS ' + IntToStr(NewTable.Partitions.PartitionsNumber);
    end;

    if (NewTable.Partitions.PartitionType in [ptHash, ptKey]) then
    begin
      if (not Assigned(Table) or (NewTable.Partitions.Count <> Table.Partitions.Count) and (NewTable.Partitions.Count > 0)) then
      begin
        if (Assigned(Table) and (SQL <> '')) then SQL := SQL + #13#10;
        if (Assigned(Table)) then
          SQL := SQL + '  PARTITIONS ' + IntToStr(NewTable.Partitions.Count)
        else
          SQL := SQL + '  COALESCE PARTITION ' + IntToStr(NewTable.Partitions.Count);
      end;
    end
    else if (NewTable.Partitions.PartitionType in [ptRange, ptList]) then
    begin
      if (not Assigned(Table) or (Table.Partitions.Count = 0)) then
      begin
        SQL := SQL + ' (' + #13#10;
        for I := 0 to NewTable.Partitions.Count - 1 do
        begin
          if (I > 0) then SQL := SQL + ',' + #13#10;
          SQL := SQL + '  ' + NewTable.Partitions[I].DBTypeStr();
        end;
        SQL := SQL + #13#10 + ') ' + #13#10;
      end
      else
      begin
        Found := False;
        for I := 0 to NewTable.Partitions.Count - 1 do
        begin
          NewPartition := NewTable.Partitions.Partition[I];
          if (not Assigned(Table) or (NewPartition.OriginalName = '')) then
            OldPartition := nil
          else
            OldPartition := Table.PartitionByName(NewPartition.OriginalName);
          Found := Found or not Assigned(OldPartition);
          if (Assigned(OldPartition) and not NewPartition.Equal(OldPartition)) then
            SQL := SQL + '  REORGANIZE PARTITION ' + Session.Connection.EscapeIdentifier(OldPartition.Name) + ' INTO ' + NewPartition.DBTypeStr() + #13#10;
        end;

        if (Found) then
        begin
          Found := False;
          SQL := SQL + '  ADD PARTITION (';
          for I := 0 to NewTable.Partitions.Count - 1 do
          begin
            NewPartition := NewTable.Partitions.Partition[I];
            if (not Assigned(Table) or (NewPartition.OriginalName = '')) then
              OldPartition := nil
            else
              OldPartition := Table.PartitionByName(NewPartition.OriginalName);
            if (not Assigned(OldPartition)) then
            begin
              if (Found) then SQL := SQL + ', ';
              SQL := SQL + NewPartition.DBTypeStr();
              Found := True;
            end;
          end;
          SQL := SQL + ')' + #13#10;
        end;
      end;

      if (Assigned(Table)) then
      begin
        SQLPart := '';
        for I := 0 to Table.Partitions.Count - 1 do
        begin
          OldPartition := Table.Partitions.Partition[I];
          Found := False;
          for J := 0 to NewTable.Partitions.Count - 1 do
          begin
            NewPartition := NewTable.Partitions.Partition[J];
            if (lstrcmpi(PChar(NewPartition.OriginalName), PChar(OldPartition.Name)) = 0) then
              Found := True;
          end;
          if (not Found) then
          begin
            if (SQLPart <> '') then SQLPart := SQLPart + ', ';
            SQLPart := SQLPart + Session.Connection.EscapeIdentifier(OldPartition.Name);
          end;
        end;
        if (SQLPart <> '') then
          SQL := '  DROP PARTITION ' + SQLPart;
      end;
    end;
  end;

  if (Trim(SQL) = '') then
    Result := ''
  else if (not Assigned(Table)) then
    Result := 'CREATE TABLE ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(NewTable.Name) + ' (' + #13#10 + TrimRight(SQL) + ';' + #13#10
  else
  begin
    Result := '';

    if (ForeignKeyAdded and (ForeignKeyDropClausel <> '')) then
      Result := Result + 'ALTER TABLE ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(Table.Name) + #13#10 + TrimRight(ForeignKeyDropClausel) + ';' + #13#10;

    Result := Result + 'ALTER TABLE ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(Table.Name) + #13#10 + TrimRight(SQL) + ';' + #13#10;
  end;
end;

function TSDatabase.SQLGetSource(): string;
begin
  if ((Session.Connection.MySQLVersion < 40101) or (Self is TSSystemDatabase)) then
    Result := ''
  else
    Result := 'SHOW CREATE DATABASE ' + Session.Connection.EscapeIdentifier(Name) + ';' + #13#10;
end;

function TSDatabase.SQLTruncateTable(const Table: TSBaseTable): string;
begin
  if (Session.Connection.MySQLVersion < 32328) then
  begin
    Result := 'DELETE FROM ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(Table.Name) + ';' + #13#10;
    if (Assigned(Table.Engine) and Table.Engine.IsInnoDB) then
      Result := Result + 'ALTER TABLE ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(Table.Name) + ' AUTO_INCREMENT=1;' + #13#10;
  end
  else
    Result := 'TRUNCATE TABLE ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(Table.Name) + ';' + #13#10;

  if (Session.Connection.DatabaseName <> Name) then
    Result := SQLUse() + Result;
end;

function TSDatabase.SQLUse(): string;
begin
  Result := Session.Connection.SQLUse(Name);
end;

function TSDatabase.TableByName(const TableName: string): TSTable;
var
  Index: Integer;
begin
  Index := Tables.IndexByName(TableName);
  if (Index < 0) then
    Result := nil
  else
    Result := Tables[Index];
end;

function TSDatabase.TriggerByName(const TriggerName: string): TSTrigger;
var
  Index: Integer;
begin
  if (not Assigned(Triggers)) then
    Result := nil
  else
  begin
    Index := Triggers.IndexByName(TriggerName);
    if (Index < 0) then
      Result := nil
    else
      Result := Triggers[Index];
  end;
end;

function TSDatabase.Update(): Boolean;
begin
  Result := Update(False);
end;

function TSDatabase.Update(const Status: Boolean): Boolean;
var
  List: TList;
begin
  List := TList.Create();
  List.Add(Self);
  Result := Session.Update(List, Status);
  List.Free();
end;

function TSDatabase.UpdateBaseTable(const Table, NewTable: TSBaseTable): Boolean;
var
  I: Integer;
  List: TList;
  SQL: string;
begin
  if (Assigned(Table)) then
    for I := 0 to NewTable.Fields.Count - 1 do
      if (NewTable.Fields[I].FieldType in TextFieldTypes) then
      begin
        if ((NewTable.Fields[I].Charset = Table.Charset) or (NewTable.Fields[I].Charset = '') and (NewTable.Charset <> Table.Charset)) then
          NewTable.Fields[I].Charset := NewTable.Charset;
        if ((NewTable.Fields[I].Collation = Table.Collation) or (NewTable.Fields[I].Collation = '') and (NewTable.Collation <> Table.Collation)) then
          NewTable.Fields[I].Collation := NewTable.Collation;
      end;

  List := TList.Create();
  List.Add(NewTable);

  SQL := SQLAlterTable(Table, NewTable)
    + NewTable.SQLGetSource()
    + Tables.SQLGetStatus(List);

  if (Session.Connection.DatabaseName <> Name) then
    SQL := SQLUse() + SQL;

  List.Free();

  Result := Session.SendSQL(SQL, Session.SessionResult);
end;

function TSDatabase.UpdateBaseTables(const TableNames: TStringList; const ACharset, ACollation, AEngine: string; const ARowType: TSTableField.TRowType): Boolean;
var
  I: Integer;
  J: Integer;
  NewTable: TSBaseTable;
  SQL: string;
  Table: TSBaseTable;
begin
  SQL := '';

  NewTable := TSBaseTable.Create(Tables);

  for I := 0 to TableNames.Count - 1 do
    if (TableByName(TableNames.Strings[I]) is TSBaseTable) then
    begin
      Table := BaseTableByName(TableNames.Strings[I]);

      if ((lstrcmpi(PChar(ACharset), PChar(Table.Charset)) = 0)
        or (lstrcmpi(PChar(ACollation), PChar(Table.Collation)) <> 0)
        or (Session.EngineByName(AEngine) <> Table.Engine)
        or (ARowType <> Table.RowType)) then
      begin
        NewTable.Assign(Table);
        if (ACharset <> '') then
        begin
          NewTable.Charset := ACharset;

          for J := 0 to NewTable.Fields.Count - 1 do
            if (NewTable.Fields[J].FieldType in TextFieldTypes) then
            begin
              if ((NewTable.Charset <> Table.Charset) and ((NewTable.Fields[J].Charset = Table.Charset) or (NewTable.Fields[J].Charset = ''))) then
                NewTable.Fields[J].Charset := NewTable.Charset;
              if ((NewTable.Collation <> Table.Collation) and ((NewTable.Fields[J].Collation = Table.Collation) or (NewTable.Fields[J].Collation = ''))) then
                NewTable.Fields[J].Collation := NewTable.Collation;
            end;
        end;
        if (ACollation <> '') then NewTable.Collation := ACollation;
        if (AEngine <> '') then NewTable.Engine := Session.EngineByName(AEngine);
        if (ARowType <> mrUnknown) then NewTable.RowType := ARowType;

        SQL := SQL + SQLAlterTable(Table, NewTable);

        if (Session.Connection.DatabaseName <> Name) then
          SQL := SQLUse() + SQL;
      end;
    end;

  NewTable.Free();

  Result := (SQL = '') or Session.SendSQL(SQL, Session.SessionResult);
end;

function TSDatabase.UpdateEvent(const Event, NewEvent: TSEvent): Boolean;
var
  SQL: string;
begin
  SQL := '';

  if (not Assigned(Event) or (NewEvent.EventType <> Event.EventType) or (NewEvent.Execute <> Event.Execute) or (NewEvent.IntervalValue <> Event.IntervalValue) or (NewEvent.IntervalType <> Event.IntervalType)) then
  begin
    SQL := SQL + '  ON SCHEDULE ';
    case (NewEvent.EventType) of
      etSingle:
        SQL := SQL + 'AT ' + SQLEscape(MySQLDB.DateTimeToStr(NewEvent.Execute, Session.Connection.FormatSettings));
      etMultiple:
        begin
          SQL := SQL + 'EVERY ' + IntervalToStr(NewEvent.IntervalValue, NewEvent.IntervalType);
          if (NewEvent.StartDateTime > 0) then
            SQL := SQL + ' STARTS ' + SQLEscape(MySQLDB.DateTimeToStr(NewEvent.StartDateTime, Session.Connection.FormatSettings));
          if (NewEvent.EndDateTime > 0) then
            SQL := SQL + ' ENDS ' + SQLEscape(MySQLDB.DateTimeToStr(NewEvent.EndDateTime, Session.Connection.FormatSettings));
        end;
    end;
    SQL := SQL + #13#10;
  end;

  if (Assigned(Event) and (NewEvent.Name <> Event.Name))then
    SQL := SQL + '  RENAME TO ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(NewEvent.Name);

  if (not Assigned(Event) or (NewEvent.Preserve <> Event.Preserve)) then
    if (not NewEvent.Preserve) then
      SQL := SQL + '  ON COMPLETION NOT PRESERVE' + #13#10
    else
      SQL := SQL + '  ON COMPLETION PRESERVE' + #13#10;

  if ((not Assigned(Event) or (NewEvent.Enabled <> Event.Enabled)) and not NewEvent.Enabled) then
    SQL := SQL + '  DISABLE' + #13#10
  else if (Assigned(Event) and (NewEvent.Enabled <> Event.Enabled)) then
    SQL := SQL + '  ENABLE' + #13#10;

  if (not Assigned(Event) and (NewEvent.Comment <> '') or Assigned(Event) and (NewEvent.Comment <> Event.Comment))then
    SQL := SQL + '  COMMENT ' + SQLEscape(NewEvent.Comment) + #13#10;

  if (not Assigned(Event) and (SQLTrimStmt(NewEvent.Stmt) <> '') or Assigned(Event) and (SQLTrimStmt(NewEvent.Stmt) <> SQLTrimStmt(Event.Stmt)))then
  begin
    SQL := SQL + '  DO' + #13#10
      + SQLTrimStmt(NewEvent.Stmt);
    if (SQL[Length(SQL)] = ';') then Delete(SQL, Length(SQL), 1);
  end;

  if (SQL = '') then
    Result := True
  else
  begin
    if (not Assigned(Event)) then
      SQL := 'CREATE EVENT ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(NewEvent.Name) + #13#10 + TrimRight(SQL) + ';' + #13#10
    else
      SQL := 'ALTER EVENT ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(Event.Name) + #13#10 + TrimRight(SQL) + ';' + #13#10;
    SQL := SQL + NewEvent.SQLGetSource();

    Result := Session.SendSQL(SQL, Session.SessionResult);
  end;
end;

function TSDatabase.UpdateRoutine(const Routine: TSRoutine; const NewRoutine: TSRoutine): Boolean;
var
  SQL: string;
begin
  SQL := '';
  if (Assigned(Routine) and (NewRoutine.Source = '')) then
  begin
    if (NewRoutine.Security <> Routine.Security) then
      case (NewRoutine.Security) of
        seDefiner: SQL := SQL + ' SQL SECURITY DEFINER';
        seInvoker: SQL := SQL + ' SQL SECURITY INVOKER';
      end;
    if (Routine.Comment <> NewRoutine.Comment) then
      SQL := SQL + ' COMMENT ' + SQLEscape(NewRoutine.Comment);

    if (SQL <> '') then
      if (Routine.RoutineType = rtProcedure) then
        SQL := 'ALTER PROCEDURE ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(NewRoutine.Name) + SQL +  ';' + #13#10
      else
        SQL := 'ALTER FUNCTION ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(NewRoutine.Name) + SQL +  ';' + #13#10;
    if (Session.Connection.DatabaseName <> Name) then
      SQL := SQLUse() + SQL;
  end
  else
  begin
    if (not Assigned(Routine)) then
    begin
      if (Session.Connection.DatabaseName <> Name) then
        SQL := SQLUse() + SQL;
    end
    else
    begin
      if (Routine.Database.Name <> Name) then
        SQL := SQL + Session.Connection.SQLUse(Routine.Database.Name);
      if (Routine.RoutineType = rtProcedure) then
        SQL := SQL + 'DROP PROCEDURE ' + Session.Connection.EscapeIdentifier(Routine.Database.Name) + '.' + Session.Connection.EscapeIdentifier(Routine.Name) + ';' + #13#10
      else
        SQL := SQL + 'DROP FUNCTION ' + Session.Connection.EscapeIdentifier(Routine.Database.Name) + '.' + Session.Connection.EscapeIdentifier(Routine.Name) + ';' + #13#10;
      if ((Session.Connection.DatabaseName <> Name) or (Routine.Database <> NewRoutine.Database)) then
        SQL := SQLUse() + SQL;
    end;
    SQL := SQL + NewRoutine.Source + #13#10;
  end;

  SQL := SQL + Routines.SQLGetItems();
  SQL := SQL + NewRoutine.SQLGetSource();

  Result := Session.SendSQL(SQL, Session.SessionResult);
end;

function TSDatabase.UpdateTrigger(const Trigger, NewTrigger: TSTrigger): Boolean;
var
  SQL: string;
begin
  SQL := '';

  if (Session.Connection.DatabaseName <> Name) then
    SQL := SQL + SQLUse();

  if (Assigned(Trigger)) then
    SQL := SQL + 'DROP TRIGGER ' + Session.Connection.EscapeIdentifier(Name) + '.' + Session.Connection.EscapeIdentifier(Trigger.Name) + ';' + #13#10;

  SQL := SQL + NewTrigger.GetSourceEx();

  SQL := SQL + Triggers.SQLGetItems();
  SQL := SQL + NewTrigger.SQLGetSource();

  Result := Session.SendSQL(SQL, Session.SessionResult);
end;

function TSDatabase.UpdateView(const View, NewView: TSView): Boolean;
var
  SQL: string;
begin
  SQL := '';

  if (not Assigned(View) or Assigned(View) and (View.Algorithm <> NewView.Algorithm)) then
    case (NewView.Algorithm) of
      vaUndefined: SQL := SQL + 'ALGORITHM=UNDEFINED ';
      vaMerge: SQL := SQL + 'ALGORITHM=MERGE ';
      vaTemptable: SQL := SQL + 'ALGORITHM=TEMPTABLE ';
    end;
  if (Session.Connection.MySQLVersion >= 50016) then
  begin
    if (not Assigned(View) and (NewView.Definer <> '') or Assigned(View) and (View.Definer <> NewView.Definer)) then
      SQL := SQL + 'DEFINER=' + Session.EscapeUser(NewView.Definer, True) + ' ';
    if (not Assigned(View) or Assigned(View) and (View.Security <> NewView.Security)) then
      case (NewView.Security) of
        seDefiner: SQL := SQL + 'SQL SECURITY DEFINER ';
        seInvoker: SQL := SQL + 'SQL SECURITY INVOKER ';
      end;
  end;
  SQL := SQL + 'VIEW ' + Session.Connection.EscapeIdentifier(NewView.Database.Name) + '.' + Session.Connection.EscapeIdentifier(NewView.Name);
  SQL := SQL + ' AS ' + SQLTrimStmt(NewView.Stmt);
  if (SQL[Length(SQL)] = ';') then
    Delete(SQL, Length(SQL), 1);
  case (NewView.CheckOption) of
    voDefault: SQL := SQL + ' WITH CHECK OPTION';
    voCascaded: SQL := SQL + ' WITH CASCADED CHECK OPTION';
    voLocal: SQL := SQL + ' WITH LOCAL CHECK OPTION';
  end;

  if (not Assigned(View)) then
    SQL := 'CREATE ' + SQL
  else
    SQL := 'ALTER ' + SQL;
  SQL := Trim(SQL);
  if (SQL[Length(SQL)] <> ';') then
    SQL := SQL + ';';
  SQL := SQL + #13#10;

  SQL := SQL + NewView.SQLGetSource();

  if (Assigned(View) and (View.Name <> NewView.Name)) then
    SQL := 'RENAME TABLE '
      + Session.Connection.EscapeIdentifier(View.Database.Name) + '.' + Session.Connection.EscapeIdentifier(View.Name) + ' TO '
      + Session.Connection.EscapeIdentifier(NewView.Database.Name) + '.' + Session.Connection.EscapeIdentifier(NewView.Name) + ';' + #13#10
      + SQL;

  if (Session.Connection.DatabaseName <> Name) then
    SQL := SQLUse() + SQL;

  Result := Session.SendSQL(SQL, Session.SessionResult);
end;

function TSDatabase.ViewByName(const TableName: string): TSView;
var
  Index: Integer;
begin
  Index := Tables.IndexByName(TableName);
  if ((Index < 0) or not (Tables[Index] is TSView)) then
    Result := nil
  else
    Result := TSView(Tables[Index]);
end;

function TSSystemDatabase.GetCreated(): TDateTime;
begin
  if (Session.StartTime = 0) then
    Result := inherited
  else
    Result := Session.StartTime;
end;

{ TSDatabases *****************************************************************}

function TSDatabases.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  DatabaseNames: TCSVStrings;
  DeleteList: TList;
  Found: Boolean;
  I: Integer;
  Index: Integer;
  Item: TSItem;
  Name: string;
  NewDatabase: TSDatabase;
begin
  Item := nil;

  DeleteList := TList.Create();
  DeleteList.Assign(Self);

  if (not DataSet.IsEmpty()) then
  begin
    SetLength(DatabaseNames, 0);
    if (Assigned(Session.Account)) then
      CSVSplitValues(Session.Account.Connection.Database, ',', '"', DatabaseNames);

    repeat
      if (not UseInformationSchema) then
        Name := DataSet.Fields[0].AsString
      else
        Name := DataSet.FieldByName('SCHEMA_NAME').AsString;

      Found := ((NameCmp(Name, INFORMATION_SCHEMA) = 0)
        or (NameCmp(Name, PERFORMANCE_SCHEMA) = 0));
      for I := 0 to Length(DatabaseNames) - 1 do
        if (NameCmp(Name, DatabaseNames[I]) = 0) then
          Found := True;

      if (Found or (Length(DatabaseNames) = 0)) then
      begin
        if (InsertIndex(Name, Index)) then
        begin
          if (NameCmp(Name, INFORMATION_SCHEMA) = 0) then
          begin
            NewDatabase := TSSystemDatabase.Create(Self, Name);
            Session.FInformationSchema := NewDatabase;
          end
          else if (NameCmp(Name, PERFORMANCE_SCHEMA) = 0) then
          begin
            NewDatabase := TSSystemDatabase.Create(Self, Name);
            Session.FPerformanceSchema := NewDatabase;
          end
          else
            NewDatabase := TSDatabase.Create(Self, Name);

          if (Index < Count) then
            Insert(Index, NewDatabase)
          else
            Index := Add(NewDatabase);
        end
        else if (DeleteList.IndexOf(Items[Index]) >= 0) then
          DeleteList.Delete(DeleteList.IndexOf(Items[Index]));

        if (UseInformationSchema) then
        begin
          Database[Index].Charset := DataSet.FieldByName('DEFAULT_CHARACTER_SET_NAME').AsString;
          Database[Index].Collation := DataSet.FieldByName('DEFAULT_COLLATION_NAME').AsString;
        end;

        Item := Database[Index];

        if (Assigned(ItemSearch)) then
          ItemSearch.Add(Item);
      end;
    until (not DataSet.FindNext());
  end
  else if (Assigned(Session.Account) and (Session.Account.Connection.Database <> '')) then
  begin
    CSVSplitValues(Session.Account.Connection.Database, ',', '"', DatabaseNames);
    for I := 0 to Length(DatabaseNames) - 1 do
    begin
      Name := DatabaseNames[I];

      if (Session.Databases.NameCmp(Name, INFORMATION_SCHEMA) = 0) then
      begin
        Index := Add(TSSystemDatabase.Create(Self, Name));
        Session.FInformationSchema := Database[Index];
      end
      else if (Session.Databases.NameCmp(Name, PERFORMANCE_SCHEMA) = 0) then
      begin
        Index := Add(TSSystemDatabase.Create(Self, Name));
        Session.FInformationSchema := Database[Index];
      end
      else
        Index := Add(TSDatabase.Create(Self, Name));

      Item := Database[Index];
    end;
  end;

  Result := inherited;
  if (not Valid and Filtered) then
    FValid := DataSet.CommandText + ';' = Trim(SQLGetItems());

  if (Filtered) then
  begin
    Found := True;
    for I := 0 to Length(DatabaseNames) - 1 do
      Found := Found and (IndexByName(DatabaseNames[I]) >= 0);

    FValid := FValid or Found;
  end;

  if (not Filtered) then
    while (DeleteList.Count > 0) do
    begin
      Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
  DeleteList.Free();

  Session.SendEvent(etItemsValid, Session, Self);
  if (DataSet.RecordCount = 1) then
    Session.SendEvent(etItemValid, Session, Self, Item);
end;

procedure TSDatabases.Delete(const AItem: TSItem; const FreeItem: Boolean = True);
var
  I: Integer;
  J: Integer;
  Names: TCSVStrings;
begin
  Assert(AItem is TSDatabase);

  if (Session.Account.Connection.Database <> '') then
  begin
    SetLength(Names, 0);
    CSVSplitValues(Session.Account.Connection.Database, ',', '"', Names);
    for I := Length(Names) - 1 downto 0 do
      if (Names[I] = AItem.Name) then
      begin
        for J := I to Length(Names) - 2 do
          Names[I] := Names[I + 1];
        SetLength(Names, Length(Names) - 1);
      end;
    Session.Account.Connection.Database := '';
    for I := 0 to Length(Names) - 1 do
    begin
      if (I > 0) then Session.Account.Connection.Database := Session.Account.Connection.Database + ',';
      Session.Account.Connection.Database := Session.Account.Connection.Database + CSVEscape(Names[I]);
    end;
  end;

  Session.SendEvent(etItemDeleted, Session, Self, AItem);

  Delete(IndexOf(AItem));

  if (FreeItem) then
    AItem.Free();
end;

function TSDatabases.GetDatabase(Index: Integer): TSDatabase;
begin
  Result := TSDatabase(Items[Index]);
end;

function TSDatabases.NameCmp(const Name1, Name2: string): Integer;
begin
  if ((lstrcmpi(PChar(Name1), INFORMATION_SCHEMA) = 0) and (lstrcmpi(PChar(Name2), INFORMATION_SCHEMA) = 0)) then
    Result := 0
  else if ((lstrcmpi(PChar(Name1), PERFORMANCE_SCHEMA) = 0) and (lstrcmpi(PChar(Name2), PERFORMANCE_SCHEMA) = 0)) then
    Result := 0
  else if (Session.LowerCaseTableNames = 0) then
    Result := lstrcmp(PChar(Name1), PChar(Name2))
  else
    Result := lstrcmpi(PChar(Name1), PChar(Name2));
end;

function TSDatabases.SQLGetItems(const Name: string = ''): string;
var
  DatabaseNames: TCSVStrings;
  I: Integer;
begin
  if (Session.Connection.MySQLVersion < 50006) then
    Result := 'SHOW DATABASES;' + #13#10
  else
  begin
    Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('SCHEMATA');
    if (Assigned(Session.Account) and (Session.Account.Connection.Database <> '')) then
    begin
      Result := Result + ' WHERE ' + Session.Connection.EscapeIdentifier('SCHEMA_NAME') + ' IN (';

      SetLength(DatabaseNames, 0);
      CSVSplitValues(Session.Account.Connection.Database, ',', '"', DatabaseNames);
      for I := 0 to Length(DatabaseNames) - 1 do
      begin
        if (I > 0) then Result := Result + ',';
        Result := Result + SQLEscape(DatabaseNames[I]);
      end;
      Result := Result + ',' + SQLEscape(INFORMATION_SCHEMA);
      if (Session.Connection.MySQLVersion >= 50503) then
        Result := Result + ',' + SQLEscape(PERFORMANCE_SCHEMA);
      Result := Result + ')';

      SetLength(DatabaseNames, 0);
    end;
    Result := Result + ';' + #13#10;
  end;
end;

{ TSVariable ******************************************************************}

procedure TSVariable.Assign(const Source: TSVariable);
begin
  inherited Assign(Source);

  Value := Source.Value;
end;

function TSVariable.GetAsBoolean(): Boolean;
begin
  Result := (Value = '1')
    or (StrIComp(PChar(Value), 'TRUE') = 0)
    or (StrIComp(PChar(Value), 'YES') = 0)
    or (StrIComp(PChar(Value), 'ON') = 0);
end;

function TSVariable.GetAsFloat(): Double;
begin
  if (not Assigned(Variables)) then
    Result := StrToFloat(ReplaceStr(Value, ',', ''))
  else
    Result := StrToFloat(Value, Session.Connection.FormatSettings);
end;

function TSVariable.GetAsInteger(): Integer;
begin
  if (not TryStrToInt(ReplaceStr(Value, '.', ''), Result)) then
    if (StrIComp(PChar(Value), 'OFF') = 0) then
      Result := 0
    else if (StrIComp(PChar(Value), 'ON') = 0) then
      Result := 1
    else
      EConvertError.CreateFmt(SConvStrParseError + '(' + Value + ')', ['"' + Name + '"']);
end;

function TSVariable.GetAsString(): string;
begin
  Result := Value;
end;

function TSVariable.GetVariables(): TSVariables;
begin
  Assert(Items is TSVariables);

  Result := TSVariables(Items);
end;

procedure TSVariable.SetAsBoolean(const AAsBoolean: Boolean);
begin
  if (AAsBoolean <> AsBoolean) then
    if ((StrIComp(PChar(Value), 'YES') = 0) or (StrIComp(PChar(Value), 'NO') = 0)) then
      if (AAsBoolean) then Value := 'YES' else Value := 'NO'
    else if ((Value = '1') or (Value = '0')) then
      if (AAsBoolean) then Value := '1' else Value := '0'
    else if ((StrIComp(PChar(Value), 'ON') = 0) or (StrIComp(PChar(Value), 'OFF') = 0)) then
      if (AAsBoolean) then Value := 'ON' else Value := 'OFF'
    else
      if (AAsBoolean) then Value := 'TRUE' else Value := 'FALSE'
end;

procedure TSVariable.SetAsFloat(const AAsFloat: Double);
begin
  if (Assigned(Variables)) then
    Value := FloatToStr(AAsFloat)
  else
    Value := FloatToStr(AAsFloat, Session.Connection.FormatSettings);
end;

procedure TSVariable.SetAsInteger(const AAsInteger: Integer);
begin
  Value := IntToStr(AAsInteger);
end;

procedure TSVariable.SetAsString(const AAsString: string);
begin
  Value := AAsString;
end;

{ TSVariables *****************************************************************}

function TSVariables.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  DeleteList: TList;
  I: Integer;
  Index: Integer;
  Item: TSItem;
  Name: string;
begin
  Item := nil;

  DeleteList := TList.Create();
  DeleteList.Assign(Self);

  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        Name := DataSet.FieldByName('Variable_name').AsString
      else
        Name := DataSet.FieldByName('VARIABLE_NAME').AsString;

      if (InsertIndex(Name, Index)) then
        if (Index < Count) then
          Insert(Index, TSVariable.Create(Self, Name))
        else
          Index := Add(TSVariable.Create(Self, Name))
      else if (DeleteList.IndexOf(Items[Index]) >= 0) then
        DeleteList.Delete(DeleteList.IndexOf(Items[Index]));

      if (not UseInformationSchema) then
        Variable[Index].Value := DataSet.FieldByName('Value').AsString
      else
        Variable[Index].Value := DataSet.FieldByName('VARIABLE_VALUE').AsString;

      Item := Variable[Index];

      if (Assigned(ItemSearch)) then
        ItemSearch.Add(Item);
    until (not DataSet.FindNext());

  Result := inherited or (Session.Connection.ErrorCode = ER_NO_SUCH_TABLE);

  if (not Filtered) then
    while (DeleteList.Count > 0) do
    begin
      Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
  DeleteList.Free();

  if (Valid) then
  begin
    if (Assigned(Session.VariableByName('character_set'))) then
    begin
      Session.Charsets.Build(nil, False);
      Session.Connection.CharsetClient := Session.VariableByName('character_set').Value;
    end
    else
    begin
      if (Assigned(Session.VariableByName('character_set_client'))) then
        Session.Connection.CharsetClient := Session.VariableByName('character_set_client').Value;
      if (Assigned(Session.VariableByName('character_set_results'))) then
        Session.Connection.CharsetResult := Session.VariableByName('character_set_results').Value;
    end;

    if (Session.Connection.MySQLVersion < 40102) then
      Session.Engines.Build(nil, False);

    if (Assigned(Session.VariableByName('max_allowed_packet'))) then
      Session.Connection.FMaxAllowedPacket := Session.VariableByName('max_allowed_packet').AsInteger - 1; // 1 Byte for COM_QUERY

    if (Assigned(Session.VariableByName('lower_case_table_names'))) then
      Session.FLowerCaseTableNames := Session.VariableByName('lower_case_table_names').AsInteger;

    if (Assigned(Session.VariableByName('sql_mode')) and (POS('ANSI_QUOTES', Session.VariableByName('sql_mode').Value) > 0)) then
      Session.Connection.AnsiQuotes := True;
    if (Assigned(Session.VariableByName('sql_quote_show_create'))) then
      Session.Connection.IdentifierQuoted := Session.VariableByName('sql_quote_show_create').AsBoolean;

    if (Assigned(Session.VariableByName('wait_timeout')) and (Session.VariableByName('wait_timeout').AsInteger > 0)) then
      Session.Connection.ServerTimeout := Min(Session.VariableByName('wait_timeout').AsInteger, 24 * 60 * 60);

    if (Session.Connection.MySQLVersion < 40102) then
    begin
      Session.Engines.Clear();

      if ((Session.Connection.MySQLVersion >= 32334) and Assigned(Session.VariableByName('have_bdb')) and Session.VariableByName('have_bdb').AsBoolean) then
        Session.Engines.Add(TSEngine.Create(Session.Engines, 'BDB'));

      Session.Engines.Add(TSEngine.Create(Session.Engines, 'HEAP'));

      if (Assigned(Session.VariableByName('have_innodb')) and Session.VariableByName('have_innodb').AsBoolean) then
        Session.Engines.Add(TSEngine.Create(Session.Engines, 'InnoDB'));

      if (Assigned(Session.VariableByName('have_isam')) and Session.VariableByName('have_isam').AsBoolean) then
        Session.Engines.Add(TSEngine.Create(Session.Engines, 'ISAM'));

      if (Session.Connection.MySQLVersion >= 32325) then
        Session.Engines.Add(TSEngine.Create(Session.Engines, 'MERGE'));

      Session.Engines.Add(TSEngine.Create(Session.Engines, 'MyISAM'));
      Session.Engines[Session.Engines.Count - 1].FDefault := not Assigned(Session.VariableByName('table_type'));

      Session.Engines.Add(TSEngine.Create(Session.Engines, 'MRG_MyISAM'));

      if (Assigned(Session.VariableByName('table_type'))) then
        for I := 0 to Session.Engines.Count - 1 do
          Session.Engines[I].FDefault := StrIComp(PChar(Session.Engines[I].Name), PChar(Session.VariableByName('table_type').Value)) = 0;
      if (Assigned(Session.VariableByName('storage_engine'))) then
        for I := 0 to Session.Engines.Count - 1 do
          Session.Engines[I].FDefault := StrIComp(PChar(Session.Engines[I].Name), PChar(Session.VariableByName('storage_engine').Value)) = 0;

      Session.Engines.FValid := True;
    end;
  end;

  if (DataSet.RecordCount = 1) then
    Session.SendEvent(etItemValid, Session, Self, Item)
  else
    Session.SendEvent(etItemsValid, Session, Session.Databases);
end;

function TSVariables.GetAddress(): string;
begin
  Result := Session.Address + '?system=variables';
end;

function TSVariables.GetVariable(Index: Integer): TSVariable;
begin
  Result := TSVariable(Items[Index]);
end;

function TSVariables.SQLGetItems(const Name: string = ''): string;
begin
  if (Session.Connection.MySQLVersion < 50112) then
  begin
    if (Session.Connection.MySQLVersion < 40003) then
      Result := 'SHOW VARIABLES'
    else
      Result := 'SHOW SESSION VARIABLES';
    if (Name <> '') then
      Result := Result + ' LIKE ' + SQLEscape(Name);
    Result := Result + ';' + #13#10;
  end
  else if (Session.Connection.MySQLVersion < 50706) then
  begin
    Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('SESSION_VARIABLES');
    if (Name <> '') then
      Result := Result + ' WHERE ' + Session.Connection.EscapeIdentifier('VARIABLE_NAME') + '=' + SQLEscape(Name);
    Result := Result + ';' + #13#10;
  end
  else if (Session.Connection.MySQLVersion < 80000) then
  // PERFORMANCE_SCHEMA.SESSION_VARIABLES should be available in 5.7.8 and higher.
  // But a user reported not to have it on your 5.7.16 server.
  begin
    Result := 'SHOW SESSION VARIABLES';
    if (Name <> '') then
      Result := Result + ' LIKE ' + SQLEscape(Name);
    Result := Result + ';' + #13#10;
  end
  else
  begin
    Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(PERFORMANCE_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('SESSION_VARIABLES');
    if (Name <> '') then
      Result := Result + ' WHERE ' + Session.Connection.EscapeIdentifier('VARIABLE_NAME') + '=' + SQLEscape(Name);
    Result := Result + ';' + #13#10;
  end;
end;

{ TSEngine ********************************************************************}

function TSEngine.FieldAvailable(const MySQLFieldType: TSField.TFieldType): Boolean;
begin
  Result := Session.FieldTypes.FieldAvailable(Self, MySQLFieldType);
end;

function TSEngine.GetEngines(): TSEngines;
begin
  Assert(Items is TSEngines);

  Result := TSEngines(Items);
end;

function TSEngine.GetIsInnoDB(): Boolean;
begin
  Result := Engines.NameCmp(Name, 'InnoDB') = 0;
end;

function TSEngine.GetForeignKeyAllowed(): Boolean;
begin
  Result := IsInnoDB or IsMyISAM and (Session.Connection.MySQLVersion >= 50200);
end;

function TSEngine.GetIsMerge(): Boolean;
begin
  Result := (Engines.NameCmp(Name, 'MERGE') = 0)
    or (Engines.NameCmp(Name, 'MRG_ISAM') = 0)
    or (Engines.NameCmp(Name, 'MRG_MYISAM') = 0);
end;

function TSEngine.GetIsMyISAM(): Boolean;
begin
  Result := (Engines.NameCmp(Name, 'MyISAM') = 0);
end;

function TSEngine.ApplyMySQLFieldType(const MySQLFieldType: TSField.TFieldType; const MySQLFieldSize: Integer): TSField.TFieldType;
begin
  Result := Session.FieldTypes.ApplyMySQLFieldType(Self, MySQLFieldType);

  if (((Result in [mfChar, mfVarChar]) and (Session.Connection.MySQLVersion < 50003) or (Result in [mfTinyText])) and (MySQLFieldSize >= 1 shl 8)) then
    Result := mfText;
  if (((Result in [mfChar, mfVarChar]) and (Session.Connection.MySQLVersion >= 50003) or (Result in [mfText])) and (MySQLFieldSize >= 1 shl 16)) then
    Result := mfMediumText;
  if ((Result in [mfMediumText]) and (MySQLFieldSize >= 1 shl 24)) then
    Result := mfLongText;

  if (((Result in [mfBinary, mfVarBinary]) and (Session.Connection.MySQLVersion < 50003) or (Result in [mfTinyBlob])) and (MySQLFieldSize >= 1 shl 8)) then
    Result := mfBlob;
  if (((Result in [mfBinary, mfVarBinary]) and (Session.Connection.MySQLVersion >= 50003) or (Result in [mfBlob])) and (MySQLFieldSize >= 1 shl 16)) then
    Result := mfMediumBlob;
  if ((Result in [mfMediumBlob]) and (MySQLFieldSize >= 1 shl 24)) then
    Result := mfLongBlob;
end;

{ TSEngines *******************************************************************}

function TSEngines.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  DeleteList: TList;
  Index: Integer;
  Name: string;
  NewEngine: TSEngine;
begin
  DeleteList := TList.Create();
  DeleteList.Assign(Self);

  if (Assigned(DataSet) and not DataSet.IsEmpty()) then
    repeat
      if ((not UseInformationSchema and (StrIComp(PChar(DataSet.FieldByName('Support').AsString), 'NO') <> 0) and (StrIComp(PChar(DataSet.FieldByName('Support').AsString), 'DISABLED') <> 0))
        or (UseInformationSchema and (StrIComp(PChar(DataSet.FieldByName('SUPPORT').AsString), 'NO') <> 0) and (StrIComp(PChar(DataSet.FieldByName('SUPPORT').AsString), 'DISABLED') <> 0))) then
      begin
        if (not UseInformationSchema) then
          Name := DataSet.FieldByName('Engine').AsString
        else
          Name := DataSet.FieldByName('ENGINE').AsString;

        if (InsertIndex(Name, Index)) then
        begin
          if (Session.Databases.NameCmp(Name, 'PERFORMANCE_SCHEMA') = 0) then
            NewEngine := TSSystemEngine.Create(Self, Name)
          else
            NewEngine := TSEngine.Create(Self, Name);

          if (Index < Count) then
            Insert(Index, NewEngine)
          else
            Add(NewEngine);
        end
        else if (DeleteList.IndexOf(Items[Index]) >= 0) then
          DeleteList.Delete(DeleteList.IndexOf(Items[Index]));

        if (not UseInformationSchema) then
        begin
          Engine[Index].FComment := DataSet.FieldByName('Comment').AsString;
          Engine[Index].FDefault := StrIComp(PChar(DataSet.FieldByName('Support').AsString), 'DEFAULT') = 0;
        end
        else
        begin
          Engine[Index].FComment := DataSet.FieldByName('COMMENT').AsString;
          Engine[Index].FDefault := StrIComp(PChar(DataSet.FieldByName('SUPPORT').AsString), 'DEFAULT') = 0;
        end;
      end;
    until (not DataSet.FindNext());

  Result := inherited;

  if (not Filtered) then
    while (DeleteList.Count > 0) do
    begin
      Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
  DeleteList.Free();

  if (FValid) then
    Session.SendEvent(etItemsValid, Session, Self);
end;

function TSEngines.GetDefaultEngine(): TSEngine;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if (Engine[I].Default) then
      Result := Engine[I];
end;

function TSEngines.GetEngine(Index: Integer): TSEngine;
begin
  Result := TSEngine(Items[Index]);
end;

function TSEngines.SQLGetItems(const Name: string = ''): string;
begin
  if (Session.Connection.MySQLVersion < 40102) then
    Result := ''
  else if (Session.Connection.MySQLVersion < 50105) then
    Result := 'SHOW ENGINES;' + #13#10
  else
    Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('ENGINES') + ';' + #13#10;
end;

function TSEngines.Update(): Boolean;
begin
  if (Session.Connection.MySQLVersion < 40102) then
    Result := Session.Variables.Update()
  else
    Result := inherited;
end;

{ TSPlugin ********************************************************************}

function TSPlugin.GetPlugins(): TSPlugins;
begin
  Assert(Items is TSPlugins);

  Result := TSPlugins(Items);
end;

{ TSPlugins *******************************************************************}

function TSPlugins.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  DeleteList: TList;
  Index: Integer;
  Name: string;
begin
  DeleteList := TList.Create();
  DeleteList.Assign(Self);

  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        Name := DataSet.FieldByName('Name').AsString
      else
        Name := DataSet.FieldByName('PLUGIN_NAME').AsString;

      if (InsertIndex(Name, Index)) then
        if (Index < Count) then
          Insert(Index, TSPlugin.Create(Self, Name))
        else
          Add(TSPlugin.Create(Self, Name))
      else if (DeleteList.IndexOf(Items[Index]) >= 0) then
        DeleteList.Delete(DeleteList.IndexOf(Items[Index]));

      if (UseInformationSchema) then
        Plugin[Index].FComment := DataSet.FieldByName('PLUGIN_DESCRIPTION').AsString;
    until (not DataSet.FindNext());

  Result := inherited;

  if (not Filtered) then
    while (DeleteList.Count > 0) do
    begin
      Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
  DeleteList.Free();

  if (FValid) then
    Session.SendEvent(etItemsValid, Session, Self);
end;

function TSPlugins.GetPlugin(Index: Integer): TSPlugin;
begin
  Result := TSPlugin(Items[Index]);
end;

function TSPlugins.SQLGetItems(const Name: string = ''): string;
begin
  if (Session.Connection.MySQLVersion < 50109) then
    Result := 'SHOW PLUGIN;' + #13#10
  else if (Session.Connection.MySQLVersion < 50105) then
    Result := 'SHOW PLUGINS;' + #13#10
  else
    Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('PLUGINS') + ';' + #13#10;
end;

{ TSFieldType *****************************************************************}

constructor TSFieldType.Create(const AFieldTypes: TSFieldTypes; const AMySQLFieldType: TSField.TFieldType; const ACaption: string; const AHighlighted: Boolean);
begin
  inherited Create(AFieldTypes, ACaption);

  FName := ACaption;
  FHighlighted := AHighlighted;
  FMySQLFieldType := AMySQLFieldType;
end;

function TSFieldType.DBTypeStr(): string;
begin
  Result := LowerCase(Name);
end;

function TSFieldType.GetFieldTypes(): TSFieldTypes;
begin
  if (not (Items is TSFieldTypes)) then
    Result := nil
  else
    Result := TSFieldTypes(Items);
end;

{ TSFieldTypes ****************************************************************}

procedure TSFieldTypes.Add(const AMySQLFieldType: TSField.TFieldType; const ACaption: string; const AHighlighted: Boolean);
begin
  inherited Add(TSFieldType.Create(Self, AMySQLFieldType, ACaption, AHighlighted));
end;

function TSFieldTypes.ApplyMySQLFieldType(const Engine: TSEngine; const MySQLFieldType: TSField.TFieldType): TSField.TFieldType;
begin
  if (FieldAvailable(Engine, MySQLFieldType)) then
    Result := MySQLFieldType
  else
    case (MySQLFieldType) of
      mfBit: Result := mfBigInt;
      mfGeometry,
      mfPoint,
      mfLineString,
      mfPolygon,
      mfMultiPoint,
      mfMultiLineString,
      mfMultiPolygon,
      mfGeometryCollection: Result := mfBlob;
      mfJSON: Result := mfVarChar;
      else Result := MySQLFieldType;
    end;
end;

procedure TSFieldTypes.Clear();
begin
  raise EAbstractError.Create('Should never called!');
end;

constructor TSFieldTypes.Create(const ASession: TSSession);
begin
  inherited;

  Add(mfBit, 'Bit', False);
  Add(mfTinyInt, 'TinyInt', False);
  Add(mfSmallInt, 'SmallInt', False);
  Add(mfMediumInt, 'MediumInt', False);
  Add(mfInt, 'Int', True);
  Add(mfBigInt, 'BigInt', False);
  Add(mfFloat, 'Real', False);
  Add(mfDouble, 'Double', False);
  Add(mfFloat, 'Float', False);
  Add(mfDecimal, 'Decimal', False);
  Add(mfDecimal, 'Numeric', False);
  Add(mfDate, 'Date', False);
  Add(mfTime, 'Time', False);
  Add(mfTimeStamp, 'TimeStamp', False);
  Add(mfDateTime, 'DateTime', True);
  Add(mfYear, 'Year', False);
  Add(mfChar, 'Char', False);
  Add(mfVarChar, 'VarChar', True);
  Add(mfBinary, 'Binary', False);
  Add(mfVarBinary, 'VarBinary', False);
  Add(mfTinyBlob, 'TinyBlob', False);
  Add(mfBlob, 'Blob', True);
  Add(mfMediumBlob, 'MediumBlob', False);
  Add(mfLongBlob, 'LongBlob', False);
  Add(mfTinyText, 'TinyText', False);
  Add(mfText, 'Text', True);
  Add(mfMediumText, 'MediumText', False);
  Add(mfLongText, 'LongText', False);
  Add(mfEnum, 'Enum', False);
  Add(mfSet, 'Set', False);
  Add(mfGeometry, 'Geometry', False);
  Add(mfPoint, 'Point', False);
  Add(mfLineString, 'LineString', False);
  Add(mfPolygon, 'Polygon', False);
  Add(mfMultiPoint, 'MultiPoint', False);
  Add(mfMultiLineString, 'MultiLineString', False);
  Add(mfMultiPolygon, 'MultiPolygon', False);
  Add(mfGeometryCollection, 'GeometryCollection', False);
  Add(mfJSON, 'JSON', False);

  // Debug 2016-11-17
  if (Count = 0) then
    raise ERangeError.Create(SRangeError);
end;

function TSFieldTypes.FieldAvailable(const Engine: TSEngine; const MySQLFieldType: TSField.TFieldType): Boolean;
begin
  case (MySQLFieldType) of
    mfUnknown: Result := False;
    mfBit: Result := (Session.Connection.MySQLVersion >= 50003) and (Engine.Name = 'MyISAM') or (Session.Connection.MySQLVersion >= 50005) and ((Engine.Name = 'MEMORY') or Engine.IsInnoDB or (Engine.Name = 'BDB'));
    mfBinary,
    mfVarBinary: Result := Session.Connection.MySQLVersion >= 40102;
    mfGeometry,
    mfPoint,
    mfLineString,
    mfPolygon,
    mfMultiPoint,
    mfMultiLineString,
    mfMultiPolygon,
    mfGeometryCollection: Result := Assigned(Session.VariableByName('have_geometry')) and Session.VariableByName('have_geometry').AsBoolean and ((Engine.Name = 'MyISAM') or (Session.Connection.MySQLVersion >= 50016) and (Engine.IsInnoDB or (Engine.Name = 'NDB') or (Engine.Name = 'BDB') or (Engine.Name = 'ARCHIVE')));
    mfJSON: Result := Session.Connection.MySQLVersion >= 50708;
    else Result := True;
  end;
end;

function TSFieldTypes.GetFieldType(Index: Integer): TSFieldType;
begin
  Result := TSFieldType(Items[Index]);
end;

{ TSCharset *******************************************************************}

function TSCharset.GetCharsets(): TSCharsets;
begin
  Assert(Items is TSCharsets);

  Result := TSCharsets(Items);
end;

function TSCharset.GetCodePage(): Cardinal;
begin
  Result := Session.Connection.CharsetToCodePage(Name);
end;

function TSCharset.GetDefaultCollation(): TSCollation;
var
  I: Integer;
begin
  Result := nil;

  if (Assigned(Charsets.Session.Collations)) then
    for I := 0 to Charsets.Session.Collations.Count - 1 do
      if ((Charsets.Session.Collations[I].Charset = Self) and Charsets.Session.Collations[I].Default) then
        Result := Charsets.Session.Collations[I];
end;

{ TSCharsets ******************************************************************}

function TSCharsets.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  DeleteList: TList;
  Index: Integer;
  Name: string;
  Names: string;
begin
  DeleteList := TList.Create();
  DeleteList.Assign(Self);

  if (not Assigned(DataSet) and Session.Variables.Valid) then
  begin
    if (Assigned(Session.VariableByName('character_sets'))) then
    begin
      Names := Session.VariableByName('character_sets').Value;

      while (Names <> '') do
      begin
        if (Pos(' ', Names) > 0) then
        begin
          Name := Copy(Names, 1, Pos(' ', Names) - 1);
          System.Delete(Names, 1, Pos(' ', Names));
        end
        else
        begin
          Name := Names;
          Names := '';
        end;

        if (InsertIndex(Name, Index)) then
          if (Index < Count) then
            Insert(Index, TSCharset.Create(Self, Name))
          else
            Add(TSCharset.Create(Self, Name))
        else if (DeleteList.IndexOf(Items[Index]) >= 0) then
          DeleteList.Delete(DeleteList.IndexOf(Items[Index]));
      end;
    end;
  end
  else if (Assigned(DataSet) and not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        Name := DataSet.FieldByName('Charset').AsString
      else
        Name := DataSet.FieldByName('CHARACTER_SET_NAME').AsString;

      if (InsertIndex(Name, Index)) then
        if (Index < Count) then
          Insert(Index, TSCharset.Create(Self, Name))
        else
          Add(TSCharset.Create(Self, Name))
      else if (DeleteList.IndexOf(Items[Index]) >= 0) then
        DeleteList.Delete(DeleteList.IndexOf(Items[Index]));

      if (not UseInformationSchema) then
      begin
        Charset[Index].FHint := DataSet.FieldByName('Description').AsString;
        Charset[Index].FCollation := LowerCase(DataSet.FieldByName('Default collation').AsString);
        Charset[Index].FMaxLength := DataSet.FieldByName('Maxlen').AsInteger;
      end
      else
      begin
        Charset[Index].FHint := DataSet.FieldByName('DESCRIPTION').AsString;
        Charset[Index].FCollation := LowerCase(DataSet.FieldByName('DEFAULT_COLLATE_NAME').AsString);
        Charset[Index].FMaxLength := DataSet.FieldByName('MAXLEN').AsInteger;
      end;
    until (not DataSet.FindNext());

  Result := inherited;

  if (not Filtered) then
    while (DeleteList.Count > 0) do
    begin
      Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
  DeleteList.Free();

  if (FValid) then
    Session.SendEvent(etItemsValid, Session, Self);
end;

function TSCharsets.GetCharset(Index: Integer): TSCharset;
begin
  Result := TSCharset(Items[Index]);
end;

function TSCharsets.SQLGetItems(const Name: string = ''): string;
begin
  if (Session.Connection.MySQLVersion < 40100) then
    Result := ''
  else if (Session.Connection.MySQLVersion < 50006) then
    Result := 'SHOW CHARACTER SET;' + #13#10
  else
    Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('CHARACTER_SETS') + ';' + #13#10;
end;

function TSCharsets.Update(): Boolean;
begin
  if (Session.Connection.MySQLVersion < 40100) then
    Result := Session.Variables.Update()
  else
    Result := inherited;
end;

{ TSCollation *****************************************************************}

function TSCollation.GetCollations(): TSCollations;
begin
  Assert(Items is TSCollations);

  Result := TSCollations(Items);
end;

{ TSCollations ****************************************************************}

function TSCollations.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  DeleteList: TList;
  Index: Integer;
  Name: string;
begin
  DeleteList := TList.Create();
  DeleteList.Assign(Self);

  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        Name := DataSet.FieldByName('Collation').AsString
      else
        Name := DataSet.FieldByName('COLLATION_NAME').AsString;

      if (InsertIndex(Name, Index)) then
        if (Index < Count) then
          Insert(Index, TSCollation.Create(Self, Name))
        else
          Add(TSCollation.Create(Self, Name))
      else if (DeleteList.IndexOf(Items[Index]) >= 0) then
        DeleteList.Delete(DeleteList.IndexOf(Items[Index]));

      if (not UseInformationSchema) then
      begin
        Collation[Index].FCharset := Session.CharsetByName(DataSet.FieldByName('Charset').AsString);
        Collation[Index].FId := DataSet.FieldByName('Id').AsInteger;
        Collation[Index].FDefault := StrIComp(PChar(DataSet.FieldByName('Default').AsString), 'YES') = 0;
        Collation[Index].FCompiled := StrIComp(PChar(DataSet.FieldByName('Compiled').AsString), 'YES') = 0;
        Collation[Index].FSortLength := DataSet.FieldByName('Sortlen').AsInteger;
      end
      else
      begin
        Collation[Index].FCharset := Session.CharsetByName(DataSet.FieldByName('CHARACTER_SET_NAME').AsString);
        Collation[Index].FId := DataSet.FieldByName('ID').AsInteger;
        Collation[Index].FDefault := StrIComp(PChar(DataSet.FieldByName('IS_DEFAULT').AsString), 'YES') = 0;
        Collation[Index].FCompiled := StrIComp(PChar(DataSet.FieldByName('IS_COMPILED').AsString), 'YES') = 0;
        Collation[Index].FSortLength := DataSet.FieldByName('SORTLEN').AsInteger;
      end;
    until (not DataSet.FindNext());

  Result := inherited;

  if (not Filtered) then
    while (DeleteList.Count > 0) do
    begin
      Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
  DeleteList.Free();

  if (FValid) then
    Session.SendEvent(etItemsValid, Session, Self);
end;

function TSCollations.GetCollation(Index: Integer): TSCollation;
begin
  Result := TSCollation(Items[Index]);
end;

function TSCollations.SQLGetItems(const Name: string = ''): string;
begin
  if (Session.Connection.MySQLVersion < 50006) then
    Result := 'SHOW COLLATION;' + #13#10
  else
    Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('COLLATIONS') + ';' + #13#10;
end;

{ TSProcesse ******************************************************************}

constructor TSProcess.Create(const ASItems: TSItems; const AName: string = '');
begin
  inherited;

  // Debug 2017-04-12
  Assert(Name <> '');
end;

function TSProcess.GetThreadId(): Longword;
begin
  // Debug 2017-04-12
  Assert(Assigned(Self));
  Assert(Self is TSProcess);
  Assert(Name <> '');

  Result := StrToUInt64(Name);
end;

procedure TSProcess.SetThreadId(AThreadId: Longword);
begin
  Name := IntToStr(AThreadId);
end;

{ TSProcesses *****************************************************************}

function TSProcesses.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  Days: Integer;
  DeleteList: TList;
  Hours: Integer;
  Index: Integer;
  Item: TSItem;
  Minutes: Integer;
  Name: string;
  Seconds: Integer;
  ThreadId: UInt64;
begin
  Item := nil;

  DeleteList := TList.Create();
  DeleteList.Assign(Self);

  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        Name := DataSet.FieldByName('Id').AsString
      else
        Name := DataSet.FieldByName('ID').AsString;

      // Debug 2016-11-11
      if (not TryStrToUInt64(Name, ThreadId)) then
        raise ERangeError.CreateFmt(SPropertyOutOfRange, ['ID']);
      // Debug 2016-11-21
      if (Name = '') then
        raise ERangeError.Create(SRangeError);

      if (InsertIndex(Name, Index)) then
        if (Index < Count) then
          Insert(Index, TSProcess.Create(Self, Name))
        else
        begin
          // Debug 2016-12-04
          if (Name = '') then
            raise ERangeError.Create(SRangeError);
          Add(TSProcess.Create(Self, Name));
        end
      else if (DeleteList.IndexOf(Items[Index]) >= 0) then
        DeleteList.Delete(DeleteList.IndexOf(Items[Index]));

      if (not UseInformationSchema) then
      begin
        Process[Index].FUserName := DataSet.FieldByName('User').AsString;
        Process[Index].FHost := DataSet.FieldByName('Host').AsString;
        Process[Index].FDatabaseName := DataSet.FieldByName('db').AsString;
        Process[Index].FCommand := DataSet.FieldByName('Command').AsString;
        if (not TryStrToInt(DataSet.FieldByName('Time').AsString, Seconds) or (Seconds < 0)) then
          Process[Index].FTime := 0
        else
        begin
          Minutes := Seconds div SecsPerMin; Seconds := Seconds mod SecsPerMin;
          Hours := Minutes div MinsPerHour; Minutes := Minutes mod MinsPerHour;
          Days := Hours div HoursPerDay; Hours := Hours mod HoursPerDay;
          Process[Index].FTime := Days + EncodeTime(Hours, Minutes, Seconds, 0);
        end;
        Process[Index].FState := DataSet.FieldByName('State').AsString;
        Process[Index].FSQL := DataSet.FieldByName('Info').AsString;
      end
      else
      begin
        Process[Index].FUserName := DataSet.FieldByName('USER').AsString;
        Process[Index].FHost := DataSet.FieldByName('HOST').AsString;
        Process[Index].FDatabaseName := DataSet.FieldByName('DB').AsString;
        Process[Index].FCommand := DataSet.FieldByName('COMMAND').AsString;
        if (not TryStrToInt(DataSet.FieldByName('TIME').AsString, Seconds) or (Seconds < 0)) then
          Process[Index].FTime := 0
        else
        begin
          Minutes := Seconds div SecsPerMin; Seconds := Seconds mod SecsPerMin;
          Hours := Minutes div MinsPerHour; Minutes := Minutes mod MinsPerHour;
          Days := Hours div HoursPerDay; Hours := Hours mod HoursPerDay;
          Process[Index].FTime := Days + EncodeTime(Hours, Minutes, Seconds, 0);
        end;
        Process[Index].FState := DataSet.FieldByName('STATE').AsString;
        Process[Index].FSQL := DataSet.FieldByName('INFO').AsString;
      end;

      Item := Process[Index];

      if (Assigned(ItemSearch)) then
        ItemSearch.Add(Item);
    until (not DataSet.FindNext());

  Result := inherited;

  if (not Filtered) then
    while (DeleteList.Count > 0) do
    begin
      Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
  DeleteList.Free();

  Session.SendEvent(etItemsValid, Session, Self);
  if (DataSet.RecordCount = 1) then
    Session.SendEvent(etItemValid, Session, Self, Item);
end;

procedure TSProcesses.Delete(const AProcess: TSProcess);
begin
  Session.SendEvent(etItemDeleted, Session, Self, AProcess);

  Delete(IndexOf(AProcess));

  AProcess.Free();
end;

function TSProcesses.GetAddress(): string;
begin
  Result := Session.Address + '?system=processes';
end;

function TSProcesses.GetProcess(Index: Integer): TSProcess;
begin
  Result := TSProcess(Items[Index]);
end;

function TSProcesses.GetValid(): Boolean;
begin
  if ((Session.Connection.MySQLVersion >= 50000) and (not Assigned(Session.UserRights) or not Session.UserRights.RProcess)) then
    Result := False
  else
    Result := inherited;
end;

function TSProcesses.NameCmp(const Name1, Name2: string): Integer;
begin
  Result := Sign(SysUtils.StrToInt(Name1) - SysUtils.StrToInt(Name2));
end;

function TSProcesses.SQLGetItems(const Name: string = ''): string;
begin
  if (Session.Connection.MySQLVersion < 50107) then
    Result := 'SHOW FULL PROCESSLIST;' + #13#10
  else
  begin
    Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('PROCESSLIST');
    if (Name <> '') then
      Result := Result + ' WHERE ' + Session.Connection.EscapeIdentifier('ID') + '=' + Name;
    Result := Result + ';' + #13#10;
  end;
end;

{ TSUserRight *****************************************************************}

procedure TSUserRight.Assign(const Source: TSUserRight);
begin
  DatabaseName := Source.DatabaseName;
  TableName := Source.TableName;
  ProcedureName := Source.ProcedureName;
  FunctionName := Source.FunctionName;
  FieldName := Source.FieldName;

  RAlter := Source.RAlter;
  RAlterRoutine := Source.RAlterRoutine;
  RCreate := Source.RCreate;
  RCreateTableSpace := Source.RCreateTableSpace;
  RCreateTempTable := Source.RCreateTempTable;
  RCreateRoutine := Source.RCreateRoutine;
  RCreateUser := Source.RCreateUser;
  RCreateView := Source.RCreateView;
  RDelete := Source.RDelete;
  RDrop := Source.RDrop;
  REvent := Source.REvent;
  RExecute := Source.RExecute;
  RFile := Source.RFile;
  RGrant := Source.RGrant;
  RIndex := Source.RIndex;
  RInsert := Source.RInsert;
  RLockTables := Source.RLockTables;
  RProcess := Source.RProcess;
  RReferences := Source.RReferences;
  RReload := Source.RReload;
  RReplClient := Source.RReplClient;
  RReplSlave := Source.RReplSlave;
  RSelect := Source.RSelect;
  RShowDatabases := Source.RShowDatabases;
  RShowView := Source.RShowView;
  RShutdown := Source.RShutdown;
  RSuper := Source.RSuper;
  RTrigger := Source.RTrigger;
  RUpdate := Source.RUpdate;
end;

constructor TSUserRight.Create(const AUser: TSUser);
begin
  inherited Create();

  FUser := AUser;

  DatabaseName := '';
  TableName := '';
  ProcedureName := '';
  FunctionName := '';
  FieldName := '';

  RAlter := False;
  RAlterRoutine := False;
  RCreate := False;
  RCreateTableSpace := False;
  RCreateTempTable := False;
  RCreateRoutine := False;
  RCreateUser := False;
  RCreateView := False;
  RDelete := False;
  RDrop := False;
  REvent := False;
  RExecute := False;
  RFile := False;
  RGrant := False;
  RIndex := False;
  RInsert := False;
  RLockTables := False;
  RProcess := False;
  RReferences := False;
  RReload := False;
  RReplClient := False;
  RReplSlave := False;
  RSelect := False;
  RShowDatabases := False;
  RShowView := False;
  RShutdown := False;
  RTrigger := False;
  RSuper := False;
  RUpdate := False;
end;

function TSUserRight.Equals(Obj: TObject): Boolean;
begin
  Result := Obj is TSUserRight;
  Result := Result and (Session.Databases.NameCmp(TSUserRight(Obj).DatabaseName, DatabaseName) = 0);
  Result := Result and (Session.Databases.NameCmp(TSUserRight(Obj).TableName, TableName) = 0);
  Result := Result and (lstrcmpi(PChar(TSUserRight(Obj).ProcedureName), PChar(ProcedureName)) = 0);
  Result := Result and (lstrcmpi(PChar(TSUserRight(Obj).FunctionName), PChar(FunctionName)) = 0);
  Result := Result and (lstrcmpi(PChar(TSUserRight(Obj).FieldName), PChar(FieldName)) = 0);

  Result := Result and (TSUserRight(Obj).RAlter = RAlter);
  Result := Result and (TSUserRight(Obj).RAlterRoutine = RAlterRoutine);
  Result := Result and (TSUserRight(Obj).RCreate = RCreate);
  Result := Result and (TSUserRight(Obj).RCreateTableSpace = RCreateTableSpace);
  Result := Result and (TSUserRight(Obj).RCreateTempTable = RCreateTempTable);
  Result := Result and (TSUserRight(Obj).RCreateRoutine = RCreateRoutine);
  Result := Result and (TSUserRight(Obj).RCreateUser = RCreateUser);
  Result := Result and (TSUserRight(Obj).RCreateView = RCreateView);
  Result := Result and (TSUserRight(Obj).RDelete = RDelete);
  Result := Result and (TSUserRight(Obj).RDrop = RDrop);
  Result := Result and (TSUserRight(Obj).REvent = REvent);
  Result := Result and (TSUserRight(Obj).RExecute = RExecute);
  Result := Result and (TSUserRight(Obj).RFile = RFile);
  Result := Result and (TSUserRight(Obj).RGrant = RGrant);
  Result := Result and (TSUserRight(Obj).RIndex = RIndex);
  Result := Result and (TSUserRight(Obj).RInsert = RInsert);
  Result := Result and (TSUserRight(Obj).RLockTables = RLockTables);
  Result := Result and (TSUserRight(Obj).RProcess = RProcess);
  Result := Result and (TSUserRight(Obj).RReferences = RReferences);
  Result := Result and (TSUserRight(Obj).RReload = RReload);
  Result := Result and (TSUserRight(Obj).RReplClient = RReplClient);
  Result := Result and (TSUserRight(Obj).RReplSlave = RReplSlave);
  Result := Result and (TSUserRight(Obj).RSelect = RSelect);
  Result := Result and (TSUserRight(Obj).RShowDatabases = RShowDatabases);
  Result := Result and (TSUserRight(Obj).RShowView = RShowView);
  Result := Result and (TSUserRight(Obj).RShutdown = RShutdown);
  Result := Result and (TSUserRight(Obj).RTrigger = RTrigger);
  Result := Result and (TSUserRight(Obj).RSuper = RSuper);
  Result := Result and (TSUserRight(Obj).RUpdate = RUpdate);
end;

function TSUserRight.GetCaption(): string;
begin
  Result := '';
  if (DatabaseName <> '') then
    Result := Result + DatabaseName;
  if (TableName <> '') then
  begin
    Result := Result + '.' + TableName;
    if (FieldName <> '') then
      Result := Result + '.' + FieldName;
  end
  else if (ProcedureName <> '') then
    Result := Result + '.' + ProcedureName
  else if (FunctionName <> '') then
    Result := Result + '.' + FunctionName;
  if (Result = '') then
    Result := '<' + Preferences.LoadStr(214) + '>';
end;

function TSUserRight.GetSession(): TSSession;
begin
  Result := User.Session;
end;

{ TSUser **********************************************************************}

function TSUser.AddRight(const NewUserRight: TSUserRight): Boolean;
type
  Tstrcmp = function (lpString1, lpString2: PWideChar): Integer; stdcall;
var
  I: Integer;
  Index: Integer;
  strcmp: Tstrcmp;
begin
  if (Session.LowerCaseTableNames = 0) then
    strcmp := lstrcmp
  else
    strcmp := lstrcmpi;

  Index := FRights.Count;
  for I := FRights.Count - 1 downto 0 do
    if (strcmp(PChar(NewUserRight.DatabaseName), PChar(Rights[I].DatabaseName)) < 0) then
      Index := I
    else if (strcmp(PChar(NewUserRight.DatabaseName), PChar(Rights[I].DatabaseName)) = 0) then
      if ((strcmp(PChar(NewUserRight.TableName), PChar(Rights[I].TableName)) < 0) and (NewUserRight.ProcedureName = '') and (NewUserRight.FunctionName = '')) then
        Index := I
      else if ((strcmp(PChar(NewUserRight.TableName), PChar(Rights[I].TableName)) = 0) and (NewUserRight.ProcedureName = '') and (NewUserRight.FunctionName = '')) then
        if ((lstrcmpi(PChar(NewUserRight.FieldName), PChar(Rights[I].FieldName)) < 0) and (NewUserRight.ProcedureName = '') and (NewUserRight.FunctionName = '')) then
          Index := I
        else if (lstrcmpi(PChar(NewUserRight.ProcedureName), PChar(Rights[I].ProcedureName)) < 0) then
          Index := I
        else if (lstrcmpi(PChar(NewUserRight.FunctionName), PChar(Rights[I].FunctionName)) < 0) then
          Index := I;

  FRights.Insert(Index, TSUserRight.Create(Self));
  TSUserRight(FRights[Index]).Assign(NewUserRight);

  Result := True;
end;

procedure TSUser.Assign(const Source: TSUser);
var
  I: Integer;
begin
  inherited Assign(Source);

  if (not Assigned(FItems)) then FItems := Source.Users;

  FConnectionsPerHour := Source.ConnectionsPerHour;
  FRawPassword := Source.RawPassword;
  FNewPassword := Source.NewPassword;
  FQueriesPerHour := Source.QueriesPerHour;
  for I := 0 to Source.FRights.Count - 1 do
  begin
    FRights.Add(TSUserRight.Create(Self));
    TSUserRight(FRights[I]).Assign(Source.FRights[I]);
  end;
  FUpdatesPerHour := Source.UpdatesPerHour;
  FUserConnections := Source.UserConnections;
end;

procedure TSUser.Clear();
begin
  ConnectionsPerHour := 0;
  NewPassword := '';
  QueriesPerHour := 0;
  RawPassword := '';
  UpdatesPerHour := 0;
  UserConnections := 0;

  while (FRights.Count > 0) do
  begin
    TSUserRight(FRights[0]).Free();
    FRights.Delete(0);
  end;
end;

constructor TSUser.Create(const ASItems: TSItems; const AName: string = '');
begin
  inherited;

  ConnectionsPerHour := 0;
  NewPassword := '';
  QueriesPerHour := 0;
  RawPassword := '';
  FRights := TList.Create();
  UpdatesPerHour := 0;
  UserConnections := 0;
end;

procedure TSUser.DeleteRight(const UserRight: TSUserRight);
var
  Index: Integer;
begin
  if (UserRight <> nil) then
  begin
    Index := IndexOf(UserRight);

    Rights[Index].Free();
    FRights.Delete(Index);
  end;
end;

destructor TSUser.Destroy();
begin
  while (FRights.Count > 0) do
  begin
    TSUserRight(FRights[0]).Free();
    FRights.Delete(0);
  end;
  FRights.Free();

  inherited;
end;

function TSUser.GetCaption(): string;
begin
  if (Name <> '') then
    Result := Name
  else
    Result := '<' + Preferences.LoadStr(287) + '>';
end;

function TSUser.GetHost(): string;
begin
  if (Pos('@', Name) = 0) then
    Result := ''
  else
  begin
    Result := Name;
    Delete(Result, 1, Pos('@', Name));
  end;
end;

function TSUser.GetLogin(): string;
begin
  if (Pos('@', Name) = 0) then
    Result := Name
  else
    Result := Copy(Name, 1, Pos('@', Name) - 1);
end;

function TSUser.GetRight(Index: Integer): TSUserRight;
begin
  Result := FRights[Index];
end;

function TSUser.GetRightCount(): Integer;
begin
  Result := FRights.Count;
end;

function TSUser.GetUsers(): TSUsers;
begin
  Assert(Items is TSUsers);

  Result := TSUsers(Items);
end;

function TSUser.GetValid(): Boolean;
begin
  Result := ValidSource and (RightCount > 0);
end;

function TSUser.IndexOf(const UserRight: TSUserRight): Integer;
var
  I: Integer;
begin
  Result := - 1;

  for I := 0 to FRights.Count - 1 do
    if (Rights[I] = UserRight) then
      Result := I;
end;

procedure TSUser.ParseGrant(const SQL: string);

  procedure AddPrivileg(const Right: TSUserRight; const Privileg: string);
  begin
    with Right do
      begin
        RAlter           := (RAlter           or (Privileg = 'ALTER')                   or (Privileg = 'ALL PRIVILEGES'));
        RAlterRoutine    := (RAlterRoutine    or (Privileg = 'ALTER ROUTINE')           or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 50003);
        RCreate          := (RCreate          or (Privileg = 'CREATE')                  or (Privileg = 'ALL PRIVILEGES'));
        RCreateRoutine   := (RCreateRoutine   or (Privileg = 'CREATE ROUTINE')          or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 50003);
        RCreateTableSpace:= (RCreateTableSpace or(Privileg = 'CREATE TABLESPACE')       or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 50500);
        RCreateTempTable := (RCreateTempTable or (Privileg = 'CREATE TEMPORARY TABLES') or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 40002);
        RCreateUser      := (RCreateUser      or (Privileg = 'CREATE USER')             or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 50003);
        RCreateView      := (RCreateView      or (Privileg = 'CREATE VIEW')             or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 50001);
        RDelete          := (RDelete          or (Privileg = 'DELETE')                  or (Privileg = 'ALL PRIVILEGES'));
        RDrop            := (RDrop            or (Privileg = 'DROP')                    or (Privileg = 'ALL PRIVILEGES'));
        REvent           := (REvent           or (Privileg = 'EVENT')                   or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 50106);
        RExecute         := (RExecute         or (Privileg = 'EXECUTE')                 or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 50003);
        RFile            := (RFile            or (Privileg = 'FILE')                    or (Privileg = 'ALL PRIVILEGES'));
        RGrant           := (RGrant           or (Privileg = 'GRANT OPTION')            or (Privileg = 'ALL PRIVILEGES'));
        RIndex           := (RIndex           or (Privileg = 'INDEX')                   or (Privileg = 'ALL PRIVILEGES'));
        RInsert          := (RInsert          or (Privileg = 'INSERT')                  or (Privileg = 'ALL PRIVILEGES'));
        RLockTables      := (RLockTables      or (Privileg = 'LOCK TABLES')             or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 40002);
        RProcess         := (RProcess         or (Privileg = 'PROCESS')                 or (Privileg = 'ALL PRIVILEGES'));
        RReferences      := (RReferences      or (Privileg = 'REFERENCES')              or (Privileg = 'ALL PRIVILEGES'));
        RReload          := (RReload          or (Privileg = 'RELOAD')                  or (Privileg = 'ALL PRIVILEGES'));
        RReplClient      := (RReplClient      or (Privileg = 'REPLICATION CLIENT')      or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 40002);
        RReplSlave       := (RReplSlave       or (Privileg = 'REPLICATION SLAVE')       or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 40002);
        RSelect          := (RSelect          or (Privileg = 'SELECT')                  or (Privileg = 'ALL PRIVILEGES'));
        RShowDatabases   := (RShowDatabases   or (Privileg = 'SHOW DATABASES')          or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 40002);
        RShowView        := (RShowView        or (Privileg = 'SHOW VIEW')               or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 50001);
        RShutdown        := (RShutdown        or (Privileg = 'SHUTDOWN')                or (Privileg = 'ALL PRIVILEGES'));
        RSuper           := (RSuper           or (Privileg = 'SUPER')                   or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 40002);
        RTrigger         := (RTrigger         or (Privileg = 'TRIGGER')                 or (Privileg = 'ALL PRIVILEGES')) and (Session.Connection.MySQLVersion >= 50106);
        RUpdate          := (RUpdate          or (Privileg = 'UPDATE')                  or (Privileg = 'ALL PRIVILEGES'));
      end;
  end;

var
  DatabaseName: string;
  FieldName: string;
  FunctionName: string;
  Grant: Boolean;
  I: Integer;
  Index: Integer;
  NewRights: array of TSUserRight;
  Parse: TSQLParse;
  Privileg: string;
  ProcedureName: string;
  ProxyName: string;
  RawPassword: string;
  TableName: string;
begin
  Clear();

  if (SQLCreateParse(Parse, PChar(SQL), Length(SQL), Session.Connection.MySQLVersion)) then
  begin
    while (not SQLParseEnd(Parse)) do
    begin
      if (not SQLParseKeyword(Parse, 'GRANT')) then raise EConvertError.CreateFmt(SSourceParseError, [Name, SQL]);

      repeat
        Privileg := '';
        while (not SQLParseChar(Parse, '(', False) and not SQLParseChar(Parse, ',') and not SQLParseKeyword(Parse, 'ON', False)) do
        begin
          if (Privileg <> '') then Privileg := Privileg + ' ';
          Privileg := Privileg + SQLParseValue(Parse);
        end;

        if (Privileg = 'PROXY') then
        else if (not SQLParseChar(Parse, '(')) then
        begin
          Index := -1;
          for I := 0 to Length(NewRights) - 1 do
            if (NewRights[I].FieldName = '') then
              Index := I;

          if (Index < 0) then
          begin
            SetLength(NewRights, Length(NewRights) + 1);
            Index := Length(NewRights) - 1;
            NewRights[Index] := TSUserRight.Create(Self);
          end;

          AddPrivileg(NewRights[Index], Privileg);
        end
        else
        begin
          repeat
            FieldName := SQLParseValue(Parse);

            Index := -1;
            for I := 0 to Length(NewRights) - 1 do
              if (lstrcmpi(PChar(NewRights[I].FieldName), PChar(FieldName)) = 0) then
                Index := I;

            if (Index < 0) then
            begin
              SetLength(NewRights, Length(NewRights) + 1);
              Index := Length(NewRights) - 1;
              NewRights[Index] := TSUserRight.Create(Self);
              NewRights[Index].FieldName := FieldName;
            end;

            AddPrivileg(NewRights[Index], Privileg);
          until (not SQLParseChar(Parse, ','));
          if (not SQLParseChar(Parse, ')')) then raise EConvertError.CreateFmt(SSourceParseError, [Name, SQL]);
        end;
      until (SQLParseKeyword(Parse, 'ON'));

      DatabaseName := ''; TableName := ''; ProcedureName := ''; FunctionName := ''; RawPassword := '';

      if (Privileg = 'PROXY') then
        ProxyName := SQLParseValue(Parse)
      else if (SQLParseKeyword(Parse, 'PROCEDURE')) then
      begin
        ProcedureName := SQLParseValue(Parse);
        if (SQLParseChar(Parse, '.')) then
        begin
          DatabaseName := ProcedureName;
          ProcedureName := SQLParseValue(Parse);
        end;
      end
      else if (SQLParseKeyword(Parse, 'FUNCTION')) then
      begin
        FunctionName := SQLParseValue(Parse);
        if (SQLParseChar(Parse, '.')) then
        begin
          DatabaseName := FunctionName;
          FunctionName := SQLParseValue(Parse);
        end;
      end
      else
      begin
        SQLParseKeyword(Parse, 'TABLE');

        TableName := SQLParseValue(Parse);
        if (SQLParseChar(Parse, '.')) then
        begin
          DatabaseName := TableName;
          TableName := SQLParseValue(Parse);
        end;
      end;

      if (DatabaseName = '*') then DatabaseName := '';
      if (TableName = '*') then TableName := '';

      if (not SQLParseKeyword(Parse, 'TO')) then raise EConvertError.CreateFmt(SSourceParseError, [Name, SQL]);

      FName := SQLParseValue(Parse);

      if (SQLParseKeyword(Parse, 'IDENTIFIED BY')) then
      begin
        SQLParseKeyword(Parse, 'PASSWORD');
        if (SQLParseChar(Parse, '''', False)) then
          RawPassword := SQLParseValue(Parse)
        else if (SQLParseChar(Parse, '<', False)) then
          SQLParseValue(Parse);
      end;

      if (SQLParseKeyword(Parse, 'REQUIRE')) then
        repeat
          SQLParseValue(Parse);
        until (SQLParseKeyword(Parse, 'WITH', False) or SQLParseChar(Parse, ';', False) or SQLParseEnd(Parse));

      Grant := False;
      if (SQLParseKeyword(Parse, 'WITH')) then
        repeat
          if (SQLParseKeyword(Parse, 'GRANT OPTION')) then
            Grant := True
          else if (SQLParseKeyword(Parse, 'MAX_QUERIES_PER_HOUR')) then
            QueriesPerHour := StrToUInt64(SQLParseValue(Parse))
          else if (SQLParseKeyword(Parse, 'MAX_UPDATES_PER_HOUR')) then
            UpdatesPerHour := StrToUInt64(SQLParseValue(Parse))
          else if (SQLParseKeyword(Parse, 'MAX_CONNECTIONS_PER_HOUR')) then
            ConnectionsPerHour := StrToUInt64(SQLParseValue(Parse))
          else if (SQLParseKeyword(Parse, 'MAX_USER_CONNECTIONS')) then
            UserConnections := StrToUInt64(SQLParseValue(Parse))
          else
            SQLParseValue(Parse);
        until (SQLParseChar(Parse, ';', False) or SQLParseEnd(Parse));

      if (not SQLParseChar(Parse, ';')) then raise EConvertError.CreateFmt(SSourceParseError, [Name, SQL]);

      for I := 0 to Length(NewRights) - 1 do
        if (Privileg <> 'PROXY') then
        begin
          NewRights[I].DatabaseName := DatabaseName;
          NewRights[I].TableName := TableName;
          NewRights[I].ProcedureName := ProcedureName;
          NewRights[I].FunctionName := FunctionName;
          NewRights[I].FRawPassword := RawPassword;
          NewRights[I].RGrant := NewRights[I].RGrant or Grant;
          AddRight(NewRights[I]);
        end;

      for I := 0 to Length(NewRights) - 1 do
        NewRights[I].Free();
      SetLength(NewRights, 0);
    end;
  end;
end;

function TSUser.RightByCaption(const Caption: string): TSUserRight;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to FRights.Count - 1 do
    if (Rights[I].Caption = Caption) then
      Result := Rights[I];
end;

procedure TSUser.SetName(const AName: string);
var
  TempName: string;
begin
  if (AName <> FName) then
  begin
    if ((Pos('@', AName) = 0) and (AName <> '')) then
      TempName := AName + '@%'
    else
      TempName := AName;

    inherited SetName(TempName);
  end;
end;

function TSUser.Build(const DataSet: TMySQLQuery): Boolean;
var
  SQL: string;
begin
  SQL := '';
  if (not DataSet.IsEmpty) then
    repeat
      SQL := SQL + DataSet.Fields[0].AsString + ';' + #13#10;
    until (not DataSet.FindNext());

  if (SQL <> '') then
  begin
    SQL := Trim(SQL);
    if ((SQL <> '') and (SQL[Length(SQL)] = ';')) then
      System.Delete(SQL, Length(SQL), 1);
    SetSource(SQL);

    ParseGrant(Source);

    if (Session.Connection.MySQLVersion >= 50002) then
      FSource := 'CREATE USER ' + Session.EscapeUser(Name) + ';' + #13#10 + FSource;

    if (Valid) then
      Session.SendEvent(etItemValid, Session, Users, Self);
  end;

  Result := Session.Connection.ErrorCode = ER_OPTION_PREVENTS_STATEMENT;
end;

function TSUser.SQLGetSource(): string;
begin
  Result := 'SHOW GRANTS FOR ' + Session.EscapeUser(Name) + ';' + #13#10
end;

function TSUser.Update(): Boolean;
var
  List: TList;
begin
  List := TList.Create();
  List.Add(Self);
  Result := Session.Update(List);
  List.Free();
end;

function TSUser.UpdateRight(const UserRight,  NewUserRight: TSUserRight): Boolean;
var
  Index: Integer;
begin
  Index := IndexOf(UserRight);

  Result := Index >= 0;
  if (Result) then
    Rights[Index].Assign(NewUserRight);
end;

{ TSUsers *********************************************************************}

function TSUsers.Build(const DataSet: TMySQLQuery; const UseInformationSchema: Boolean;
  Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  DeleteList: TList;
  Index: Integer;
  Item: TSItem;
  Name: string;
  Parse: TSQLParse;
begin
  Item := nil;

  DeleteList := TList.Create();
  DeleteList.Assign(Self);

  if (not DataSet.IsEmpty()) then
    repeat
      if (not UseInformationSchema) then
        Name := DataSet.FieldByName('User').AsString + '@' + DataSet.FieldByName('Host').AsString
      else if (SQLCreateParse(Parse, PChar(DataSet.FieldByName('GRANTEE').AsString), Length(DataSet.FieldByName('GRANTEE').AsString), Session.Connection.MySQLVersion)) then
        Name := SQLParseValue(Parse)
      else
        raise ERangeError.CreateFmt(SPropertyOutOfRange, ['Name']);

      if (InsertIndex(Name, Index)) then
        if (Index < Count) then
          Insert(Index, TSUser.Create(Self, Name))
        else
          Add(TSUser.Create(Self, Name))
      else if (DeleteList.IndexOf(Items[Index]) >= 0) then
        DeleteList.Delete(DeleteList.IndexOf(Items[Index]));

      Item := User[Index];

      if (Assigned(ItemSearch)) then
        ItemSearch.Add(Item);
    until (not DataSet.FindNext());

  if ((Session.Connection.ErrorCode = 0) and not Filtered) then
    while (DeleteList.Count > 0) do
    begin
      if (Items[0] = Session.User) then
      begin
        Session.FUser := nil;
        Session.FUserRequested := False;
      end;
      Delete(DeleteList.Items[0]);
      DeleteList.Delete(0);
    end;
  DeleteList.Free();

  Result := inherited Build(DataSet, UseInformationSchema, Filtered)
    or (Session.Connection.ErrorCode = ER_DBACCESS_DENIED_ERROR)
    or (Session.Connection.ErrorCode = ER_TABLEACCESS_DENIED_ERROR);

  if (FValid and not Filtered) then
    if (DataSet.RecordCount = 1) then
      Session.SendEvent(etItemValid, Session, Self, Item)
    else
      Session.SendEvent(etItemsValid, Session, Self);
end;

procedure TSUsers.Delete(const AItem: TSItem; const FreeItem: Boolean = True);
begin
  Assert(AItem is TSUser);

  if (AItem = Session.FUser) then
  begin
    Session.FUser := nil;
    Session.FUserRequested := False;
  end;

  Session.SendEvent(etItemDeleted, Session, Self, AItem);

  Delete(IndexOf(AItem));

  if (FreeItem) then
    AItem.Free();
end;

function TSUsers.GetAddress(): string;
begin
  Result := Session.Address + '?system=users';
end;

function TSUsers.GetUser(Index: Integer): TSUser;
begin
  Result := TSUser(Items[Index]);
end;

function TSUsers.GetValid(): Boolean;
begin
  // Debug 2016-11-18
  if (not Assigned(Session)) then
    raise ERangeError.Create(SRangeError);

  Result := Assigned(Session.UserRights) and not Session.UserRights.RGrant or inherited;
end;

function TSUsers.SQLGetItems(const Name: string = ''): string;
begin
  if (Session.Connection.MySQLVersion < 50002) then
    Result := 'SELECT * FROM ' + Session.Connection.EscapeIdentifier('mysql') + '.' + Session.Connection.EscapeIdentifier('user') + ';' + #13#10
  else
  begin
    // If "only_full_group_by" is set in the sql_mode, the column of the GROUP BY clause is required in the column clause
    // Since only GRANTEE is used in the Build methode the other columns are not needed
    Result := 'SELECT ' + Session.Connection.EscapeIdentifier('GRANTEE') + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('USER_PRIVILEGES') + ' GROUP BY ' + Session.Connection.EscapeIdentifier('GRANTEE') + ';' + #13#10;
  end;
end;

{ TSConnection ****************************************************************}

constructor TSConnection.Create(const ASession: TSSession);
begin
  inherited Create(nil);

  FMaxAllowedPacket := 0;
  FSession := ASession;
end;

procedure TSConnection.DoAfterExecuteSQL();
begin
  inherited;

  Session.SendEvent(etAfterExecuteSQL);
end;

procedure TSConnection.DoBeforeExecuteSQL();
begin
  Session.SendEvent(etBeforeExecuteSQL);

  inherited;
end;

procedure TSConnection.DoError(const AErrorCode: Integer; const AErrorMessage: string);
begin
  Session.SendEvent(etError);

  inherited;
end;

procedure TSConnection.Connect();
begin
  Connected := False;

  Asynchron := True;
  FDatabaseName := Session.Account.GetDefaultDatabase();
  case (Session.Account.Connection.LibraryType) of
    ltBuiltIn: LibraryName := '';
    ltDLL: LibraryName := Session.Account.Connection.LibraryFilename;
    ltHTTP: LibraryName := Session.Account.Connection.HTTPTunnelURI;
  end;
  Host := Session.Account.Connection.Host;
  HTTPAgent := Preferences.InternetAgent;
  case (Session.Account.Connection.LibraryType) of
    uPreferences.ltDLL: LibraryType := MySQLDB.ltDLL;
    uPreferences.ltHTTP: LibraryType := MySQLDB.ltHTTP;
    else LibraryType := MySQLDB.ltBuiltIn;
  end;
  LoginPrompt := False;
  OnUpdateIndexDefs := Session.UpdateIndexDefs;
  Password := Session.Account.Connection.Password;
  Port := Session.Account.Connection.Port;
  Username := Session.Account.Connection.Username;

  try
    Open();
  except
    on E: EMySQLError do
      DoError(E.ErrorCode, E.Message);
  end;
end;

procedure TSConnection.Connect(const ALibraryType: TMySQLLibrary.TLibraryType; const ALibraryName: string; const AHost, AUser, APassword, ADatabase: string; const APort: Integer; const AAsynchron: Boolean);
begin
  Close();

  FDatabaseName := ADatabase;
  Host := AHost;
  HTTPAgent := Preferences.InternetAgent;
  LibraryName := ALibraryName;
  LibraryType := ALibraryType;
  LoginPrompt := False;
  FMultiStatements := True;
  Password := APassword;
  Port := APort;
  Username := AUser;

  Open();
  Asynchron := AAsynchron;
end;

function TSConnection.GetDataFileAllowed(): Boolean;
begin
  Result := inherited GetDataFileAllowed()
    and ((MySQLVersion < 40003) or Assigned(Session.VariableByName('local_infile')) and Session.VariableByName('local_infile').AsBoolean);
end;

function TSConnection.GetMaxAllowedServerPacket(): Integer;
begin
  if (FMaxAllowedPacket = 0) then
    Result := inherited
  else
    Result := FMaxAllowedPacket;
end;

procedure TSConnection.SetAnsiQuotes(const AAnsiQuotes: Boolean);
begin
  inherited;

  Session.SQLParser.AnsiQuotes := AnsiQuotes;
end;

procedure TSConnection.SetCharsetClient(const ACharset: string);
begin
  inherited;

  if (Assigned(Session.Variables) and Session.Variables.Valid) then
    if (Assigned(Session.VariableByName('character_set'))) then
      Session.VariableByName('character_set').Value := CharsetClient
    else if (Assigned(Session.VariableByName('character_set_client'))) then
      Session.VariableByName('character_set_client').Value := CharsetClient;
end;

procedure TSConnection.SetCharsetResult(const ACharset: string);
begin
  inherited;

  if (Assigned(Session.Variables) and Session.Variables.Valid) then
    if (Assigned(Session.VariableByName('character_set_results'))) then
      Session.VariableByName('character_set_results').Value := CharsetResult;
end;

function TSConnection.SQLUse(const DatabaseName: string): string;
begin
  Result := inherited;
end;

{ TSQuickAccess ***************************************************************}

function TSQuickAccess.SearchResult(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
  const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
var
  DataSet: TMySQLQuery;
  Parse: TSQLParse;
begin
  Result := False;

  if (ErrorCode = 0) then
  begin
    DataSet := TMySQLQuery.Create(nil);
    DataSet.Open(DataHandle);

    if (SQLCreateParse(Parse, PChar(CommandText), Length(CommandText), Session.Connection.MySQLVersion)) then
      if (SQLParseKeyword(Parse, 'SELECT')) then
      begin
        if (SQLParseChar(Parse, '*')
          and SQLParseKeyword(Parse, 'FROM')
          and SQLParseValue(Parse, INFORMATION_SCHEMA)
          and SQLParseChar(Parse, '.')) then
        begin
          if (SQLParseValue(Parse, 'EVENTS')) then
            Session.BuildEvents(DataSet, True)
          else if (SQLParseValue(Parse, 'ROUTINES')) then
            Session.BuildRoutines(DataSet, True)
          else if (SQLParseValue(Parse, 'SCHEMATA')) then
            Session.Databases.Build(DataSet, True, True)
          else if (SQLParseValue(Parse, 'TABLES')) then
            Session.BuildTables(DataSet, True)
          else if (SQLParseValue(Parse, 'TRIGGERS')) then
            Session.BuildTriggers(DataSet, True);
        end;
      end;

    DataSet.Free();
  end;
end;

procedure TSQuickAccess.PushBuildEvent();
begin
  Session.SendEvent(etItemsValid, Self, Self);
end;

function TSQuickAccess.Step1(const Items: array of TItem): Boolean;
var
  Database: TSDatabase;
  DatabaseNames: TStringList;
  EventsWhere: string;
  I: Integer;
  RoutinesWhere: string;
  SQL: string;
  TablesWhere: string;
  TriggersWhere: string;
begin
  DatabaseNames := TStringList.Create();
  EventsWhere := '';
  RoutinesWhere := '';
  SQL := '';
  TablesWhere := '';
  TriggersWhere := '';

  for I := 0 to Length(Items) - 1 do
  begin
    Database := Session.DatabaseByName(Items[I].DatabaseName);

    if (not Session.Databases.Valid or Assigned(Database)) then
    begin
      if ((not Assigned(Database) or not Database.Valid) and (DatabaseNames.IndexOf(Items[I].DatabaseName) < 0)) then
        DatabaseNames.Add(Items[I].DatabaseName);

      if (((Items[I].ClassType = TSBaseTable) or (Items[I].ClassType = TSView))
        and (not Assigned(Database) or not Database.Tables.ValidStatus)) then
      begin
        if (TablesWhere <> '') then TablesWhere := TablesWhere + ',';
        TablesWhere := TablesWhere + '(' + SQLEscape(Items[I].DatabaseName) + ',' + SQLEscape(Items[I].Name) + ')';
      end;

      if (((Items[I].ClassType = TSProcedure) or (Items[I].ClassType = TSFunction))
        and (Session.Connection.MySQLVersion >= 50004)
        and (not Assigned(Database) or not Database.Routines.Valid)) then
      begin
        if (RoutinesWhere <> '') then RoutinesWhere := RoutinesWhere + ',';
        if (Items[I].ClassType = TSProcedure) then
          RoutinesWhere := RoutinesWhere + '(' + SQLEscape(Items[I].DatabaseName) + ',' + SQLEscape(Items[I].Name) + ',' + SQLEscape('PROCEDURE') + ')'
        else
          RoutinesWhere := RoutinesWhere + '(' + SQLEscape(Items[I].DatabaseName) + ',' + SQLEscape(Items[I].Name) + ',' + SQLEscape('FUNCTION') + ')';
      end;

      if ((Items[I].ClassType = TSTrigger)
        and (Session.Connection.MySQLVersion >= 50010)
        and (not Assigned(Database) or not Database.Triggers.Valid)) then
      begin
        if (TriggersWhere <> '') then TriggersWhere := TriggersWhere + ',';
        TriggersWhere := TriggersWhere + '(' + SQLEscape(Items[I].DatabaseName) + ',' + SQLEscape(Items[I].Name) + ')';
      end;

      if ((Items[I].ClassType = TSEvent)
        and (Session.Connection.MySQLVersion >= 50106)
        and (not Assigned(Database) or not Database.Events.Valid)) then
      begin
        if (EventsWhere <> '') then EventsWhere := EventsWhere + ',';
        EventsWhere := EventsWhere + '(' + SQLEscape(Items[I].DatabaseName) + ',' + SQLEscape(Items[I].Name) + ')';
      end;
    end;
  end;


  if (DatabaseNames.Count > 0) then
  begin
    SQL := SQL + 'SELECT *'
      + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('SCHEMATA')
      + ' WHERE ' + Session.Connection.EscapeIdentifier('SCHEMA_NAME') + ' IN (';
    for I := 0 to DatabaseNames.Count - 1 do
    begin
      if (I > 0) then SQL := SQL + ',';
      SQL := SQL
        + SQLEscape(DatabaseNames[I]);
    end;
    SQL := SQL
      + ')'
      + ' ORDER BY ' + Session.Connection.EscapeIdentifier('SCHEMA_NAME') + ';' + #13#10;
  end;
  if (TablesWhere <> '') then
    SQL := SQL + 'SELECT *'
      + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('TABLES')
      + ' WHERE (' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + ',' + Session.Connection.EscapeIdentifier('TABLE_NAME') + ') IN (' + TablesWhere + ')'
      + ' ORDER BY ' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + ',' + Session.Connection.EscapeIdentifier('TABLE_NAME') + ';' + #13#10;
  if (RoutinesWhere <> '') then
    SQL := SQL + 'SELECT *'
      + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('ROUTINES')
      + ' WHERE (' + Session.Connection.EscapeIdentifier('ROUTINE_SCHEMA') + ',' + Session.Connection.EscapeIdentifier('ROUTINE_NAME') + ',' + Session.Connection.EscapeIdentifier('ROUTINE_TYPE') + ') IN (' + RoutinesWhere + ')'
      + ' ORDER BY ' + Session.Connection.EscapeIdentifier('ROUTINE_SCHEMA') + ',' + Session.Connection.EscapeIdentifier('ROUTINE_NAME') + ';' + #13#10;
  if (TriggersWhere <> '') then
    SQL := SQL + 'SELECT *'
      + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('TRIGGERS')
      + ' WHERE (' + Session.Connection.EscapeIdentifier('TRIGGER_SCHEMA') + ',' + Session.Connection.EscapeIdentifier('TRIGGER_NAME') + ') IN (' + TriggersWhere + ')'
      + ' ORDER BY ' + Session.Connection.EscapeIdentifier('TRIGGER_SCHEMA') + ',' + Session.Connection.EscapeIdentifier('TRIGGER_NAME') + ';' + #13#10;
  if (EventsWhere <> '') then
    SQL := SQL + 'SELECT *'
      + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('EVENTS')
      + ' WHERE (' + Session.Connection.EscapeIdentifier('EVENT_SCHEMA') + ',' + Session.Connection.EscapeIdentifier('EVENT_NAME') + ') IN (' + EventsWhere + ')'
      + ' ORDER BY ' + Session.Connection.EscapeIdentifier('EVENT_SCHEMA') + ',' + Session.Connection.EscapeIdentifier('EVENT_NAME') + ';' + #13#10;


  DatabaseNames.Free();


  Result := (SQL = '') or Session.SendSQL(SQL, SearchResult);
end;

{ TSItemSearch ****************************************************************}

procedure TSItemSearch.AddColumns(const DataSet: TMySQLQuery);
var
  Database: TSDatabase;
  Field: TSTableField;
  Table: TSTable;
begin
  if (not DataSet.IsEmpty) then
    repeat
      Database := Session.DatabaseByName(DataSet.FieldByName('TABLE_SCHEMA').AsString);
      if (Assigned(Database)) then
      begin
        Table := Database.TableByName(DataSet.FieldByName('TABLE_NAME').AsString);
        if (Assigned(Table)) then
        begin
          Field := Table.FieldByName(DataSet.FieldByName('COLUMN_NAME').AsString);
          if (Assigned(Field)) then
            Add(Field);
        end;
      end;
    until (not DataSet.FindNext());
end;

procedure TSItemSearch.AddTables(const DataSet: TMySQLQuery);
var
  Database: TSDatabase;
  Table: TSTable;
begin
  if (not DataSet.IsEmpty) then
    repeat
      Database := Session.DatabaseByName(DataSet.FieldByName('TABLE_SCHEMA').AsString);
      if (Assigned(Database) and not (Database is TSSystemDatabase)) then
      begin
        Table := Database.TableByName(DataSet.FieldByName('TABLE_NAME').AsString);
        if (Assigned(Table)) then
          NeededTables.Add(Table);
      end;
    until (not DataSet.FindNext);
end;

procedure TSItemSearch.Clear();
begin
  while (Count > 0) do
    Delete(0);
  NeededTables.Clear();
end;

constructor TSItemSearch.Create(const ASession: TSSession);
begin
  // Debug 2017-05-09
  Assert(Assigned(ASession));

  inherited;

  FSession := ASession;

  Location := nil;
  Text := '';
  NeededTables := TList.Create();

  Session.ItemSearches.Add(Self);
end;

destructor TSItemSearch.Destroy();
begin
  Session.ItemSearches.Delete(Session.ItemSearches.IndexOf(Self));

  inherited;

  NeededTables.Free();
end;

function TSItemSearch.SearchResult(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
  const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;
var
  Database: TSDatabase;
  DataSet: TMySQLQuery;
  Parse: TSQLParse;
  Table: TSTable;
begin
  Result := False;

  // Debug 2017-05-05
  Assert(Assigned(Session));
  Assert(Sessions.Count > 0);
  Assert(Sessions.IndexOf(Session) >= 0); // Occurred on 2017-05-17
  Assert(Assigned(Session.Connection));

  if (ErrorCode = 0) then
  begin
    DataSet := TMySQLQuery.Create(nil);
    DataSet.Open(DataHandle);

    if (SQLCreateParse(Parse, PChar(CommandText), Length(CommandText), Session.Connection.MySQLVersion)) then
      if (SQLParseKeyword(Parse, 'SELECT')) then
      begin
        if ((SQLParseChar(Parse, '*') or (SQLParseValue(Parse, 'GRANTEE')))
          and SQLParseKeyword(Parse, 'FROM')
          and SQLParseValue(Parse, INFORMATION_SCHEMA)
          and SQLParseChar(Parse, '.')) then
        begin
          if (SQLParseValue(Parse, 'COLUMNS')) then
            AddColumns(DataSet)
          else if (SQLParseValue(Parse, 'EVENTS')) then
            Session.BuildEvents(DataSet, True, Self)
          else if (SQLParseValue(Parse, 'PROCESSLIST')) then
            Session.Processes.Build(DataSet, True, True, Self)
          else if (SQLParseValue(Parse, 'ROUTINES')) then
            Session.BuildRoutines(DataSet, True, Self)
          else if (SQLParseValue(Parse, 'SCHEMATA')) then
            Session.Databases.Build(DataSet, True, True, Self)
          else if (SQLParseValue(Parse, 'TABLES')) then
            Session.BuildTables(DataSet, True, Self)
          else if (SQLParseValue(Parse, 'TRIGGERS')) then
            Session.BuildTriggers(DataSet, True, Self)
          else if (SQLParseValue(Parse, 'USER_PRIVILEGES')) then
            Session.Users.Build(DataSet, True, True, Self);

          Session.SendEvent(etItemsValid, Self, Self);
        end
        else if (SQLParseValue(Parse, 'TABLE_SCHEMA')) then
          AddTables(DataSet);
      end
      else if (SQLParseKeyword(Parse, 'SHOW')
        and SQLParseKeyword(Parse, 'CREATE')
        and (SQLParseKeyword(Parse, 'TABLE') or SQLParseKeyword(Parse, 'VIEW'))) then
      begin
        Database := Session.DatabaseByName(SQLParseValue(Parse));
        if (Assigned(Database) and SQLParseChar(Parse, '.')) then
        begin
          Table := Database.TableByName(SQLParseValue(Parse));
          if (Assigned(Table)) then
            Table.Build(DataSet);
        end;
      end;

    DataSet.Free();
  end;
end;

function TSItemSearch.SQLDatabaseNames(): string;
var
  DatabaseNames: TCSVStrings;
  I: Integer;
begin
  if (Location is TSSession) then
  begin
    SetLength(DatabaseNames, 0);
    CSVSplitValues(Session.Account.Connection.Database, ',', '"', DatabaseNames);
    if (Length(DatabaseNames) = 0) then
      Result := ''
    else
    begin
      if (Length(DatabaseNames) = 1) then
        Result := '='
      else
        Result := ' IN (';
      for I := 0 to Length(DatabaseNames) - 1 do
      begin
        if (I > 0) then Result := Result + ',';
        Result := Result + SQLEscape(CSVUnescape(DatabaseNames[I]));
      end;
      if (Length(DatabaseNames) > 1) then
        Result := Result + ')';
    end;
  end
  else if (Location is TSDatabase) then
    Result := '=' + SQLEscape(TSDatabase(Location).Name)
  else if (Location is TSTable) then
    Result := '=' + SQLEscape(TSTable(Location).Database.Name)
  else
    Result := '';
end;

function TSItemSearch.Step1(): Boolean;
var
  DatabaseNames: string;
  I: Integer;
  SQL: string;
  TableNames: string;
begin
  Clear();

  DatabaseNames := SQLDatabaseNames();
  if (not (Location is TSTable)) then
    TableNames := ''
  else
    TableNames := '=' + SQLEscape(TSTable(Location).Name);

  SQL := '';
  if ((Location is TSSession) and Databases and Name) then
    if (Session.Databases.Valid) then
    begin
      for I := 0 to Session.Databases.Count - 1 do
        if (Assigned(StrStrI(PChar(Session.Databases[I].Name), PChar(Text)))) then
          Add(Session.Databases[I]);
    end
    else
    begin
      SQL := SQL + 'SELECT *'
        + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('SCHEMATA')
        + ' WHERE ';
      if (DatabaseNames <> '') then
        SQL := SQL + Session.Connection.EscapeIdentifier('SCHEMA_NAME') + DatabaseNames + ' AND ';
      SQL := SQL
        + Session.Connection.EscapeIdentifier('SCHEMA_NAME') + ' LIKE ' + SQLEscape('%' + Text + '%');
      SQL := SQL
        + ' ORDER BY ' + Session.Connection.EscapeIdentifier('SCHEMA_NAME') + ';' + #13#10;
    end;
  if (((Location is TSSession) or (Location is TSDatabase)) and Tables) then
    if ((Location is TSDatabase) and TSDatabase(Location).Tables.Valid) then
    begin
      for I := 0 to TSDatabase(Location).Tables.Count - 1 do
        if (Name and Assigned(StrStrI(PChar(TSDatabase(Location).Tables[I].Name), PChar(Text)))
          or Comment and (TSDatabase(Location).Tables[I] is TSBaseTable) and Assigned(StrStrI(PChar(TSBaseTable(TSDatabase(Location).Tables[I]).Comment), PChar(Text)))) then
          Add(TSDatabase(Location).Tables[I]);
    end
    else
    begin
      SQL := SQL + 'SELECT *'
        + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('TABLES')
        + ' WHERE ';
      if (DatabaseNames <> '') then
        SQL := SQL + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + DatabaseNames + ' AND ';
      if ((DatabaseNames <> '') and Name and Comment) then
        SQL := SQL + '(';
      if (Name) then
        SQL := SQL
          + Session.Connection.EscapeIdentifier('TABLE_NAME') + ' LIKE ' + SQLEscape('%' + Text + '%');
      if (Name and Comment) then
        SQL := SQL + ' OR ';
      if (Comment) then
        SQL := SQL
          + Session.Connection.EscapeIdentifier('TABLE_COMMENT') + ' LIKE ' + SQLEscape('%' + Text + '%');
      if ((DatabaseNames <> '') and Name and Comment) then
        SQL := SQL + ')';
      SQL := SQL
        + ' ORDER BY ' + Session.Connection.EscapeIdentifier('TABLE_NAME') + ',' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + ';' + #13#10;
    end;
  if (((Location is TSSession) or (Location is TSDatabase)) and Routines and Assigned(TSDatabase(Location).Routines)) then
    if ((Location is TSDatabase) and TSDatabase(Location).Routines.Valid) then
    begin
      for I := 0 to TSDatabase(Location).Routines.Count - 1 do
        if (Name and Assigned(StrStrI(PChar(TSDatabase(Location).Routines[I].Name), PChar(Text)))
          or Comment and Assigned(StrStrI(PChar(TSDatabase(Location).Routines[I].Comment), PChar(Text)))) then
          Add(TSDatabase(Location).Routines[I]);
    end
    else
    begin
      SQL := SQL + 'SELECT *'
        + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('ROUTINES')
        + ' WHERE ';
      if (DatabaseNames <> '') then
        SQL := SQL + Session.Connection.EscapeIdentifier('ROUTINE_SCHEMA') + DatabaseNames + ' AND ';
      if ((DatabaseNames <> '') and Name and Comment) then
        SQL := SQL + '(';
      if (Name) then
        SQL := SQL
          + Session.Connection.EscapeIdentifier('ROUTINE_NAME') + ' LIKE ' + SQLEscape('%' + Text + '%');
      if (Name and Comment) then
        SQL := SQL + ' OR ';
      if (Comment) then
        SQL := SQL
          + Session.Connection.EscapeIdentifier('ROUTINE_COMMENT') + ' LIKE ' + SQLEscape('%' + Text + '%');
      if ((DatabaseNames <> '') and Name and Comment) then
        SQL := SQL + ')';
      SQL := SQL
        + ' ORDER BY ' + Session.Connection.EscapeIdentifier('ROUTINE_NAME') + ',' + Session.Connection.EscapeIdentifier('ROUTINE_SCHEMA') + ';' + #13#10;
    end;
  if (((Location is TSSession) or (Location is TSDatabase)) and Events and Assigned(TSDatabase(Location).Events)) then
    if ((Location is TSDatabase) and TSDatabase(Location).Events.Valid) then
    begin
      for I := 0 to TSDatabase(Location).Events.Count - 1 do
        if (Name and Assigned(StrStrI(PChar(TSDatabase(Location).Events[I].Name), PChar(Text)))
          or Comment and Assigned(StrStrI(PChar(TSDatabase(Location).Events[I].Comment), PChar(Text)))) then
          Add(TSDatabase(Location).Events[I]);
    end
    else
    begin
      SQL := SQL + 'SELECT *'
        + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('EVENTS')
        + ' WHERE ';
      if (DatabaseNames <> '') then
        SQL := SQL + Session.Connection.EscapeIdentifier('EVENT_SCHEMA') + DatabaseNames + ' AND ';
      if ((DatabaseNames <> '') and Name and Comment) then
        SQL := SQL + '(';
      if (Name) then
        SQL := SQL
          + Session.Connection.EscapeIdentifier('EVENT_NAME') + ' LIKE ' + SQLEscape('%' + Text + '%');
      if (Name and Comment) then
        SQL := SQL + ' OR ';
      if (Comment) then
        SQL := SQL
          + Session.Connection.EscapeIdentifier('EVENT_COMMENT') + ' LIKE ' + SQLEscape('%' + Text + '%');
      if ((DatabaseNames <> '') and Name and Comment) then
        SQL := SQL + ')';
      SQL := SQL
        + ' ORDER BY ' + Session.Connection.EscapeIdentifier('EVENT_NAME') + ',' + Session.Connection.EscapeIdentifier('EVENT_SCHEMA') + ';' + #13#10;
    end;
  if (((Location is TSSession) or (Location is TSDatabase) or (Location is TSTable)) and (Fields or Triggers and (Session.Connection.MySQLVersion >= 50010))) then
  begin
    SQL := SQL + 'SELECT ' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + ',' + Session.Connection.EscapeIdentifier('TABLE_NAME')
      + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('TABLES')
      + ' WHERE ';
    if (DatabaseNames <> '') then
      SQL := SQL + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + DatabaseNames + ' AND ';
    if ((DatabaseNames <> '') and Name and Comment) then
      SQL := SQL + '(';
    if (Fields) then
    begin
      SQL := SQL
        + '(' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + ',' + Session.Connection.EscapeIdentifier('TABLE_NAME') + ')'
        + ' IN '
        + '('
          + 'SELECT ' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + ', ' + Session.Connection.EscapeIdentifier('TABLE_NAME')
          + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('COLUMNS')
          + ' WHERE ';
      if (DatabaseNames <> '') then
        SQL := SQL
          + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + DatabaseNames + ' AND ';
      if (TableNames <> '') then
        SQL := SQL
          + Session.Connection.EscapeIdentifier('TABLE_NAME') + TableNames + ' AND ';
      if (Name and Comment) then
        SQL := SQL + '(';
      if (Name) then
        SQL := SQL
           + Session.Connection.EscapeIdentifier('COLUMN_NAME') + ' LIKE ' + SQLEscape('%' + Text + '%');
      if (Name and Comment) then
        SQL := SQL + ' OR ';
      if (Comment) then
        SQL := SQL
           + Session.Connection.EscapeIdentifier('COLUMN_COMMENT') + ' LIKE ' + SQLEscape('%' + Text + '%');
      if (Name and Comment) then
        SQL := SQL + ')';
      SQL := SQL
        + ')';
    end;
    if (Fields and Triggers and Name) then
      SQL := SQL + ' OR ';
    if (Triggers and Name) then
    begin
      SQL := SQL
        + '(' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + ',' + Session.Connection.EscapeIdentifier('TABLE_NAME') + ')'
        + ' IN '
        + '('
          + 'SELECT ' + Session.Connection.EscapeIdentifier('EVENT_OBJECT_SCHEMA') + ', ' + Session.Connection.EscapeIdentifier('EVENT_OBJECT_TABLE')
          + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('TRIGGERS')
          + ' WHERE ';
      if (DatabaseNames <> '') then
        SQL := SQL
            + Session.Connection.EscapeIdentifier('EVENT_OBJECT_SCHEMA') + DatabaseNames + ' AND ';
      if (TableNames <> '') then
        SQL := SQL
            + Session.Connection.EscapeIdentifier('EVENT_OBJECT_TABLE') + TableNames + ' AND ';
      SQL := SQL
           + Session.Connection.EscapeIdentifier('TRIGGER_NAME') + ' LIKE ' + SQLEscape('%' + Text + '%');
      SQL := SQL
        + ')';
    end;
    if ((DatabaseNames <> '') and Name and Comment) then
      SQL := SQL + ')';
    SQL := SQL
      + ' ORDER BY ' + Session.Connection.EscapeIdentifier('TABLE_NAME') + ',' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + ';' + #13#10;
  end;
  if (Location is TSProcesses) then
    if (Session.Processes.Valid) then
    begin
      for I := 0 to Session.Processes.Count - 1 do
        if (Session.Processes[I].Name = Text) then
          Add(Session.Processes[I]);
    end
    else
      SQL := SQL
        + Session.Processes.SQLGetItems(Text);
  if (Location is TSUsers) then
    if (Session.Users.Valid) then
    begin
      for I := 0 to Session.Users.Count - 1 do
        if (Assigned(StrStrI(PChar(Session.Users[I].Name), PChar(Text)))) then
          Add(Session.Users[I]);
    end
    else
      SQL := SQL
        + 'SELECT ' + Session.Connection.EscapeIdentifier('GRANTEE')
        + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('USER_PRIVILEGES')
        + ' WHERE ' + Session.Connection.EscapeIdentifier('GRANTEE') + ' LIKE ' + SQLEscape('%' + Text + '%')
        + ' GROUP BY ' + Session.Connection.EscapeIdentifier('GRANTEE')
        + ' ORDER BY ' + Session.Connection.EscapeIdentifier('GRANTEE') + ';' + #13#10;
  if (Location is TSVariables) then
  begin
    for I := 0 to Session.Variables.Count - 1 do
      if (Assigned(StrStrI(PChar(Session.Variables[I].Name), PChar(Text)))) then
        Add(Session.Variables[I]);
  end;

  if (Count > 0) then
    Session.SendEvent(etItemsValid, Self, Self);

  // Debug 2017-04-01
  Assert(Assigned(Session));

  Result := (SQL = '') or Session.SendSQL(SQL, SearchResult);
end;

function TSItemSearch.Step2(): Boolean;
var
  DatabaseNames: string;
  I: Integer;
  SQL: string;
  TableNames: string;
begin
  SQL := '';

  for I := 0 to NeededTables.Count - 1 do
    SQL := SQL + TSTable(NeededTables[I]).SQLGetSource();
  if (Fields) then
    if ((Location is TSTable) and TSTable(Location).Fields.Valid) then
    begin
      for I := 0 to TSTable(Location).Fields.Count - 1 do
        if (Name and Assigned(StrStrI(PChar(TSTable(Location).Fields[I].Name), PChar(Text)))
          or Comment and Assigned(StrStrI(PChar(TSTable(Location).Fields[I].Comment), PChar(Text)))) then
          Add(TSTable(Location).Fields[I]);
    end
    else
    begin
      SQL := SQL + 'SELECT *'
        + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('COLUMNS')
        + ' WHERE ';
      if (DatabaseNames <> '') then
        SQL := SQL + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + DatabaseNames + ' AND ';
      if (TableNames <> '') then
        SQL := SQL + Session.Connection.EscapeIdentifier('TABLE_NAME') + TableNames + ' AND ';
      if (((DatabaseNames <> '') or (TableNames <> '')) and Name and Comment) then
        SQL := SQL + '(';
      if (Name) then
        SQL := SQL
          + Session.Connection.EscapeIdentifier('COLUMN_NAME') + ' LIKE ' + SQLEscape('%' + Text + '%');
      if (Name and Comment) then
        SQL := SQL + ' OR ';
      if (Comment) then
        SQL := SQL
          + Session.Connection.EscapeIdentifier('COLUMN_COMMENT') + ' LIKE ' + SQLEscape('%' + Text + '%');
      if (((DatabaseNames <> '') or (TableNames <> '')) and Name and Comment) then
        SQL := SQL + ')';
      SQL := SQL
        + ' ORDER BY ' + Session.Connection.EscapeIdentifier('COLUMN_NAME') + ',' + Session.Connection.EscapeIdentifier('TABLE_NAME') + ',' + Session.Connection.EscapeIdentifier('TABLE_SCHEMA') + ';' + #13#10;
    end;
  if (Triggers and Assigned(TSDatabase(Location).Triggers) and Name) then
    if ((Location is TSDatabase) and TSDatabase(Location).Triggers.Valid) then
    begin
      for I := 0 to TSDatabase(Location).Triggers.Count - 1 do
        if (Name and Assigned(StrStrI(PChar(TSDatabase(Location).Triggers[I].Name), PChar(Text)))) then
          Add(TSDatabase(Location).Triggers[I]);
    end
    else
    else if ((Location is TSTable) and Assigned(TSTable(Location).Database.Triggers) and TSTable(Location).Database.Triggers.Valid) then
    begin
      for I := 0 to TSTable(Location).Database.Triggers.Count - 1 do
        if ((TSTable(Location).Database.Triggers[I].Table = TSTable(Location))
          and Name and Assigned(StrStrI(PChar(TSTable(Location).Database.Triggers[I].Name), PChar(Text)))) then
          Add(TSTable(Location).Database.Triggers[I]);
    end
    else
    begin
      SQL := SQL + 'SELECT *'
        + ' FROM ' + Session.Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Session.Connection.EscapeIdentifier('TRIGGERS')
        + ' WHERE ';
      if (DatabaseNames <> '') then
        SQL := SQL + Session.Connection.EscapeIdentifier('EVENT_OBJECT_SCHEMA') + DatabaseNames + ' AND ';
      if (TableNames <> '') then
        SQL := SQL + Session.Connection.EscapeIdentifier('EVENT_OBJECT_TABLE') + TableNames + ' AND ';
      SQL := SQL
        + Session.Connection.EscapeIdentifier('TRIGGER_NAME') + ' LIKE ' + SQLEscape('%' + Text + '%');
      SQL := SQL
        + ' ORDER BY ' + Session.Connection.EscapeIdentifier('TRIGGER_NAME') + ',' + Session.Connection.EscapeIdentifier('TRIGGER_SCHEMA') + ';' + #13#10;
    end;

  if (Count > 0) then
    Session.SendEvent(etItemsValid, Self, Self);

  // Debug 2017-04-01
  Assert(Assigned(Session));

  Result := (SQL = '') or Session.SendSQL(SQL, SearchResult);
end;

{ TSSession.TEvent ************************************************************}

constructor TSSession.TEvent.Create(const ASession: TSSession);
begin
  inherited Create();

  Session := ASession;
  Sender := nil;
  Items := nil;
end;

{ TSItemSearches **************************************************************}

procedure TSItemSearches.Delete(const AItem: TSItem);
var
  I: Integer;
  Index: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Index := ItemSearch[I].IndexOf(AItem);
    if (Index >= 0) then
      ItemSearch[I].Delete(Index);
  end;
end;

function TSItemSearches.Get(Index: Integer): TSItemSearch;
begin
  Result := TSItemSearch(Items[Index]);
end;

{ TSSession *******************************************************************}

function Compare(Item1, Item2: Pointer): Integer;

  function ClassOrder(const Obj: TObject): Integer;
  begin
    // Debug 2016-12-10
    if (not Assigned(Obj)) then
      raise ERangeError.Create(SRangeError);

    if (Obj is TSUser) then Result := 0
    else if (Obj is TSVariables) then Result := 1
    else if (Obj is TSEngines) then Result := 3
    else if (Obj is TSCharsets) then Result := 4
    else if (Obj is TSCollations) then Result := 5
    else if (Obj is TSPlugins) then Result := 6
    else if (Obj is TSUsers) then Result := 7
    else if (Obj is TSProcesses) then Result := 8
    else if (Obj is TSDatabases) then Result := 9
    else if (Obj is TSDatabase) then Result := 10
    else if (Obj is TSTables) then Result := 11
    else if (Obj is TSRoutines) then Result := 12
    else if (Obj is TSEvents) then Result := 13
    else if (Obj is TSTriggers) then Result := 14
    else if (Obj is TSColumns) then Result := 15
    else if (Obj is TSTable) then Result := 16
    else if (Obj is TSProcedure) then Result := 17
    else if (Obj is TSFunction) then Result := 18
    else if (Obj is TSTrigger) then Result := 19
    else if (Obj is TSEvent) then Result := 20
    else Result := -1;
  end;

begin
  if (Item1 = Item2) then
    Result := 0
  else
  begin
    Result := Sign(ClassOrder(TObject(Item1)) - ClassOrder(TObject(Item2)));
    if ((Result = 0) and (TObject(Item1) is TSDBObject) and (TObject(Item2) is TSDBObject)) then
      Result := Sign(TSDBObject(Item1).Database.Index - TSDBObject(Item2).Database.Index);
    if (Result = 0) then
      Result := Sign(TSObject(Item1).Index - TSObject(Item2).Index);
  end;
end;

function TSSession.AddDatabase(const NewDatabase: TSDatabase): Boolean;
begin
  Result := UpdateDatabase(nil, NewDatabase);

  if (Result and (Account.Connection.Database <> '')) then
    Account.Connection.Database := Account.Connection.Database + ',' + CSVEscape(NewDatabase.Name);
end;

function TSSession.AddUser(const ANewUser: TSUser): Boolean;
begin
  Result := UpdateUser(nil, ANewUser);
end;

function TSSession.ApplyIdentifierName(const AIdentifierName: string): string;
begin
  Result := AIdentifierName;

  Result := ReplaceStr(Result, #0, '_');
  if (Connection.MySQLVersion < 50106) then
  begin
    Result := ReplaceStr(Result, ' ', '_');
    Result := ReplaceStr(Result, '/', '_');
    Result := ReplaceStr(Result, '\', '_');
    Result := ReplaceStr(Result, '.', '_');
  end;
end;

procedure TSSession.ApplyToBCEditor(const ABCEditor: TBCEditor);
var
  I: Integer;
begin
  for I := 0 to ABCEditor.Highlighter.MainRules.RangeCount - 1 do
    if ((ABCEditor.Highlighter.MainRules.Ranges[I].TokenType = BCEditor.Types.ttString)
      and (ABCEditor.Highlighter.MainRules.Ranges[I].OpenToken.Symbols[0] = '"')
      and (ABCEditor.Highlighter.MainRules.Ranges[I].CloseToken.Symbols[0] = '"')) then
      if (Connection.AnsiQuotes) then
        ABCEditor.Highlighter.MainRules.Ranges[I].Attribute.Element := 'Identifier'
      else
        ABCEditor.Highlighter.MainRules.Ranges[I].Attribute.Element := 'String';
  ABCEditor.Invalidate();
end;

function TSSession.BuildEvents(const DataSet: TMySQLQuery; const Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  Database: TSDatabase;
  I: Integer;
begin
  if (not DataSet.IsEmpty()) then
    repeat
      Database := DatabaseByName(DataSet.FieldByName('EVENT_SCHEMA').AsString);
      if (Assigned(Database)) then
        Database.Events.Build(DataSet, True, Filtered, ItemSearch)
      else
        DataSet.FindNext();
    until (DataSet.Eof);

  if (not Filtered) then
    for I := 0 to Databases.Count - 1 do
      if (Assigned(Databases[I].Events)) then
        Databases[I].Events.FValid := True;

  Result := (Connection.ErrorCode = ER_NO_SUCH_TABLE) or (Connection.ErrorCode = ER_EVENTS_DB_ERROR);

  SendEvent(etItemsValid, Self, Databases);
end;

function TSSession.BuildRoutines(const DataSet: TMySQLQuery; const Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  Database: TSDatabase;
  I: Integer;
begin
  if (not DataSet.IsEmpty()) then
    repeat
      Database := DatabaseByName(DataSet.FieldByName('ROUTINE_SCHEMA').AsString);
      if (Assigned(Database) and Assigned(Database.Routines)) then
        Database.Routines.Build(DataSet, True, Filtered, ItemSearch)
      else
        DataSet.FindNext();
    until (DataSet.Eof);

  if (not Filtered) then
    for I := 0 to Databases.Count - 1 do
      if (Assigned(Databases[I].Routines)) then
        Databases[I].Routines.FValid := True;

  Result := False;

  SendEvent(etItemsValid, Self, Databases);
end;

function TSSession.BuildTables(const DataSet: TMySQLQuery; const Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  Database: TSDatabase;
  I: Integer;
begin
  if (not DataSet.IsEmpty()) then
    repeat
      Database := DatabaseByName(DataSet.FieldByName('TABLE_SCHEMA').AsString);
      if (Assigned(Database)) then
        Database.Tables.Build(DataSet, True, Filtered, ItemSearch)
      else
        DataSet.FindNext();
    until (DataSet.Eof);

  if (not Filtered) then
    for I := 0 to Databases.Count - 1 do
      Databases[I].Tables.FValid := True;

  Result := False;

  SendEvent(etItemsValid, Self, Databases);
end;

function TSSession.BuildTriggers(const DataSet: TMySQLQuery; const Filtered: Boolean = False; const ItemSearch: TSItemSearch = nil): Boolean;
var
  Database: TSDatabase;
  I: Integer;
begin
  if (not DataSet.IsEmpty()) then
    repeat
      Database := DatabaseByName(DataSet.FieldByName('TRIGGER_SCHEMA').AsString);
      if (Assigned(Database)) then
        Database.Triggers.Build(DataSet, True, Filtered, ItemSearch)
      else
        DataSet.FindNext();
    until (DataSet.Eof);

  if (not Filtered) then
    for I := 0 to Databases.Count - 1 do
      if (Assigned(Databases[I].Triggers)) then
        Databases[I].Triggers.FValid := True;

  Result := False;

  SendEvent(etItemsValid, Self, Databases);
end;

procedure TSSession.BuildManualURL(const DataSet: TMySQLQuery);
var
  Equal: Integer;
  I: Integer;
  URL: string;
begin
  if (not DataSet.IsEmpty() and Assigned(DataSet.FindField('description'))) then
  begin
    URL := DataSet.FieldByName('description').AsString;
    while (Pos('URL:', URL) > 1) do Delete(URL, 1, Pos('URL:', URL) - 1);
    if (Pos('URL:', URL) = 1) then Delete(URL, 1, Length('URL:'));
    URL := Trim(URL);

    if (ManualURL = '') then
      ManualURL := URL
    else
    begin
      Equal := 0;
      for I := 1 to Min(Length(ManualURL), Length(URL)) - 1 do
        if (ManualURL[I] = URL[I]) then
          Equal := I
        else
          break;

      if (Copy(ManualURL, 1, 7) = 'http://') then
        Account.ManualURL := Copy(ManualURL, 1, Equal);
    end;
  end;
end;

function TSSession.BuildUser(const DataSet: TMySQLQuery): Boolean;
var
  Index: Integer;
begin
  Assert(not Assigned(FUser));

  if (Connection.ErrorCode = ER_OPTION_PREVENTS_STATEMENT) then
    Result := True
  else if (DataSet.IsEmpty()) then
    Result := False
  else
  begin
    FUser := TSUser.Create(Users);

    Result := FUser.Build(DataSet);

    FUser.FOriginalName := FUser.Name;

    if (Users.InsertIndex(FUser.Name, Index)) then
      Users.Add(FUser)
    else if (Index >= 0) then
    begin
      Users[Index].Free();
      Users.Items[Index] := FUser;
    end;
  end;
end;

procedure TSSession.ConnectChange(Sender: TObject; Connecting: Boolean);
begin
  if (not Assigned(FEngines) and Connecting) then
  begin
    if (not Assigned(FCollations) and (Connection.MySQLVersion >= 40100)) then FCollations := TSCollations.Create(Self);
    if (not Assigned(FFieldTypes)) then FFieldTypes := TSFieldTypes.Create(Self);
    if (not Assigned(FEngines)) then FEngines := TSEngines.Create(Self);
    if (not Assigned(FPlugins) and (Connection.MySQLVersion >= 50105)) then FPlugins := TSPlugins.Create(Self);
    if (not Assigned(FProcesses)) then FProcesses := TSProcesses.Create(Self);

    if (Assigned(Account)) then
      Account.LastLogin := Now();

    // Debug 2016-11-17
    if (not Assigned(FFieldTypes)) then
      raise ERangeError.Create(SRangeError)
    else if (FFieldTypes.Count = 0) then
      raise ERangeError.Create(SRangeError);
  end;
end;

function TSSession.CharsetByName(const CharsetName: string): TSCharset;
var
  Index: Integer;
begin
  Index := Charsets.IndexByName(CharsetName);
  if (Index < 0) then
    Result := nil
  else
    Result := Charsets[Index];
end;

function TSSession.CharsetByCollation(const Collation: string): TSCharset;
var
  I: Integer;
begin
  Result := nil;

  if (Assigned(Collations)) then
    for I := 0 to Collations.Count - 1 do
      if (Collations[I].Name = Collation) then
        Result := Collations[I].Charset;
end;

function TSSession.CollationByName(const CollationName: string): TSCollation;
var
  Index: Integer;
begin
  if (not Assigned(Collations)) then
    Index := -1
  else
    Index := Collations.IndexByName(CollationName);
  if (Index < 0) then
    Result := nil
  else
    Result := Collations[Index];
end;

constructor TSSession.Create(const ASessions: TSSessions; const AAccount: TPAccount = nil);
begin
  inherited Create();

  FSessions := ASessions;
  FAccount := AAccount;

  if (Assigned(AAccount)) then AAccount.RegisterSession(Self);
  FConnection := TSConnection.Create(Self);
  Sessions.Add(Self);

  EventProcs := TList<TEventProc>.Create();
  FCurrentUser := '';
  FInformationSchema := nil;
  FItemSearches := TSItemSearches.Create();
  FLowerCaseTableNames := 0;
  FMetadataProvider := TacEventMetadataProvider.Create(nil);
  FPerformanceSchema := nil;
  FSyntaxProvider := TacMYSQLSyntaxProvider.Create(nil);
  FSyntaxProvider.ServerVersionInt := Connection.MySQLVersion;
  FUser := nil;
  FUserRequested := False;
  InImport := False;
  ManualURL := '';
  UnparsableSQL := '';

  if (not Assigned(AAccount)) then
  begin
    FSQLMonitor := nil;
    StmtMonitor := nil;

    FCharsets := TSCharsets.Create(Self);
    FCollations := nil;
    FDatabases :=  TSDatabases.Create(Self);
    FFieldTypes := nil;
    FEngines := nil;
    FPlugins := nil;
    FProcesses := nil;
    FUsers := nil;
    FVariables := TSVariables.Create(Self);
  end
  else
  begin
    Connection.OnDatabaseChange := DatabaseChange;
    Connection.OnVariableChange := VariableChange;

    FSQLMonitor := TMySQLMonitor.Create(nil);
    FSQLMonitor.Connection := Connection;
    FSQLMonitor.CacheSize := Preferences.LogSize;
    FSQLMonitor.Enabled := True;
    FSQLMonitor.TraceTypes := [ttRequest];
    if (Preferences.LogResult) then FSQLMonitor.TraceTypes := FSQLMonitor.TraceTypes + [ttInfo];
    if (Preferences.LogTime) then FSQLMonitor.TraceTypes := FSQLMonitor.TraceTypes + [ttTime];
    FSQLMonitor.OnMonitor := MonitorLog;
    StmtMonitor := TMySQLMonitor.Create(nil);
    StmtMonitor.Connection := Connection;
    StmtMonitor.Enabled := True;
    StmtMonitor.TraceTypes := [ttResult];
    StmtMonitor.OnMonitor := MonitorExecutedStmts;

    FCharsets := TSCharsets.Create(Self);
    FCollations := nil;
    FDatabases :=  TSDatabases.Create(Self);
    FFieldTypes := nil;
    FEngines := nil;
    FPlugins := nil;
    FProcesses := nil;
    FQuickAccess := TSQuickAccess.Create(Self);
    FUsers := nil;
    FVariables := TSVariables.Create(Self);
  end;

  Connection.RegisterClient(Self, ConnectChange);
end;

function TSSession.DatabaseByName(const DatabaseName: string): TSDatabase;
var
  Index: Integer;
begin
  Index := Databases.IndexByName(DatabaseName);
  if (Index < 0) then
    Result := nil
  else
    Result := Databases[Index];
end;

procedure TSSession.DatabaseChange(const Connection: TMySQLConnection; const NewName: string);
var
  Database: TSDatabase;
begin
  Database := DatabaseByName(NewName);
  if (not Assigned(Database) and (NewName <> '')) then
  begin
    Database := TSDatabase.Create(Databases, NewName);
    Databases.Add(Database, True);
  end;
  SendEvent(etDatabaseChanged, Self, Databases, Database);
end;

procedure TSSession.DecodeInterval(const Value: string; const IntervalType: TSEvent.TIntervalType; var Year, Month, Day, Quarter, Week, Hour, Minute, Second, MSec: Word);
var
  S: string;
begin
  S := UnescapeValue(Value);

  Year := 0;
  Month := 0;
  Day := 0;
  Quarter := 0;
  Week := 0;
  Hour := 0;
  Minute := 0;
  Second := 0;
  MSec := 0;

  case (IntervalType) of
    itYear: Year := SysUtils.StrToInt(S);
    itQuarter: Quarter := SysUtils.StrToInt(S);
    itMonth: Month := SysUtils.StrToInt(S);
    itDay: Day := SysUtils.StrToInt(S);
    itHour: Hour := SysUtils.StrToInt(S);
    itMinute: Minute := SysUtils.StrToInt(S);
    itWeek: Week := SysUtils.StrToInt(S);
    itSecond: Second := SysUtils.StrToInt(S);
    itMicrosecond: MSec := SysUtils.StrToInt(S);
    itYearMonth: begin Year := SysUtils.StrToInt(Copy(S, 1, Pos('-', S) - 1)); Month := SysUtils.StrToInt(Copy(S, Pos('-', S) - 1, Length(S) - Pos('-', S))); end;
    itDayHour: begin Day := SysUtils.StrToInt(Copy(S, 1, Pos(' ', S) - 1)); Hour := SysUtils.StrToInt(Copy(S, Pos(' ', S) - 1, Length(S) - Pos(' ', S))); end;
    itDayMinute: begin Day := SysUtils.StrToInt(Copy(S, 1, Pos(' ', S) - 1)); DecodeTime(StrToTime(Copy(S, Pos(' ', S) - 1, Length(S) - Pos(' ', S)) + ':00'), Hour, Minute, Second, MSec); end;
    itDaySecond: begin Day := SysUtils.StrToInt(Copy(S, 1, Pos(' ', S) - 1)); DecodeTime(StrToTime(Copy(S, Pos(' ', S) - 1, Length(S) - Pos(' ', S))), Hour, Minute, Second, MSec); end;
    itHourMinute: begin Hour := SysUtils.StrToInt(Copy(S, 1, Pos(':', S) - 1)); Minute := SysUtils.StrToInt(Copy(S, Pos(':', S) - 1, Length(S) - Pos(':', S))); end;
    itHourSecond: DecodeTime(StrToTime(S), Hour, Minute, Second, MSec);
    itMinuteSecond: begin Minute := SysUtils.StrToInt(Copy(S, 1, Pos(':', S) - 1)); Second := SysUtils.StrToInt(Copy(S, Pos(':', S) - 1, Length(S) - Pos(':', S))); end;
    itDayMicrosecond: begin Day := SysUtils.StrToInt(Copy(S, 1, Pos(' ', S) - 1)); DecodeTime(StrToTime(Copy(S, Pos(' ', S) - 1, Length(S) - Pos(' ', S))), Hour, Minute, Second, MSec); end;
    itHourMicrosecond: DecodeTime(StrToTime(S), Hour, Minute, Second, MSec);
    itMinuteMicrosecond: DecodeTime(StrToTime('00:' + S), Hour, Minute, Second, MSec);
    itSecondMicrosecond: begin Second := SysUtils.StrToInt(Copy(S, 1, Pos('.', S) - 1)); MSec := SysUtils.StrToInt(Copy(S, Pos('.', S) - 1, Length(S) - Pos('.', S))); end;
  end;
end;

function TSSession.DeleteDatabase(const Database: TSDatabase): Boolean;
var
  List: TList;
begin
  List := TList.Create();
  List.Add(Database);
  Result := DeleteEntities(List);
  List.Free();
end;

function TSSession.DeleteEntities(const List: TList): Boolean;
var
  Database: TSDatabase;
  FlushPrivileges: Boolean;
  I: Integer;
  Identifiers: string;
  SQL: string;
begin
  SortDBObjects(List);

  Database := nil; FlushPrivileges := False;
  SQL := '';

  for I := 0 to List.Count - 1 do
    if ((TObject(List[I]) is TSRoutine) or (TObject(List[I]) is TSTrigger) or (TObject(List[I]) is TSEvent)) then
    begin
      if (not Assigned(Database) or (TSDBObject(List[I]).Database <> Database) or not Assigned(Database) and (Databases.NameCmp(TSDBObject(List[I]).Database.Name, Connection.DatabaseName) <> 0)) then
      begin
        if (Assigned(Database) or (TSBaseTable(List[I]).Database.Name <> Connection.DatabaseName)) then
          SQL := SQL + TSBaseTable(List[I]).Database.SQLUse() + SQL;
        Database := TSDBObject(List[I]).Database;
      end;
      if (TSObject(List[I]) is TSProcedure) then
        SQL := SQL + 'DROP PROCEDURE ' + Connection.EscapeIdentifier(Database.Name) + '.' + Connection.EscapeIdentifier(TSObject(List[I]).Name) + ';' + #13#10
      else if (TSObject(List[I]) is TSFunction) then
        SQL := SQL + 'DROP FUNCTION ' + Connection.EscapeIdentifier(Database.Name) + '.' + Connection.EscapeIdentifier(TSObject(List[I]).Name) + ';' + #13#10
      else if (TSObject(List[I]) is TSTrigger) then
        SQL := SQL + 'DROP TRIGGER ' + Connection.EscapeIdentifier(Database.Name) + '.' + Connection.EscapeIdentifier(TSObject(List[I]).Name) + ';' + #13#10
      else if (TSObject(List[I]) is TSEvent) then
        SQL := SQL + 'DROP EVENT ' + Connection.EscapeIdentifier(Database.Name) + '.' + Connection.EscapeIdentifier(TSObject(List[I]).Name) + ';' + #13#10;
    end;

  Identifiers := '';
  for I := 0 to List.Count - 1 do
    if (TSObject(List[I]) is TSView) then
    begin
      if (not Assigned(Database) or (TSView(List[I]).Database <> Database) or not Assigned(Database) and (Databases.NameCmp(TSView(List[I]).Database.Name, Connection.DatabaseName) <> 0)) then
      begin
        if (Assigned(Database) or (TSBaseTable(List[I]).Database.Name <> Connection.DatabaseName)) then
          SQL := SQL + TSBaseTable(List[I]).Database.SQLUse() + SQL;
        Database := TSView(List[I]).Database;
        if (Identifiers <> '') then
        begin
          SQL := SQL + 'DROP VIEW ' + Identifiers + ';' + #13#10;
          Identifiers := '';
        end;
      end;
      if (Identifiers <> '') then Identifiers := Identifiers + ',';
      Identifiers := Identifiers + Connection.EscapeIdentifier(Database.Name) + '.' + Connection.EscapeIdentifier(TSView(List[I]).Name);
    end;
  if (Identifiers <> '') then
    SQL := SQL + 'DROP VIEW ' + Identifiers + ';' + #13#10;

  Identifiers := '';
  for I := 0 to List.Count - 1 do
    if (TSObject(List[I]) is TSBaseTable) then
    begin
      if (not Assigned(Database) or (TSBaseTable(List[I]).Database <> Database) or not Assigned(Database) and (Databases.NameCmp(TSBaseTable(List[I]).Database.Name, Connection.DatabaseName) <> 0)) then
      begin
        if (Assigned(Database) or (TSBaseTable(List[I]).Database.Name <> Connection.DatabaseName)) then
          SQL := SQL + TSBaseTable(List[I]).Database.SQLUse() + SQL;
        Database := TSBaseTable(List[I]).Database;
        if (Identifiers <> '') then
        begin
          SQL := SQL + 'DROP TABLE ' + Identifiers + ';' + #13#10;
          Identifiers := '';
        end;
      end;
      if (Identifiers <> '') then Identifiers := Identifiers + ',';
      Identifiers := Identifiers + Connection.EscapeIdentifier(Database.Name) + '.' + Connection.EscapeIdentifier(TSBaseTable(List[I]).Name);
    end;
  if (Identifiers <> '') then
    SQL := SQL + 'DROP TABLE ' + Identifiers + ';' + #13#10;

  for I := 0 to List.Count - 1 do
    if (TObject(List[I]) is TSDatabase) then
      SQL := SQL + 'DROP DATABASE ' + Connection.EscapeIdentifier(TSDatabase(List[I]).Name) + ';' + #13#10;

  for I := 0 to List.Count - 1 do
    if (TObject(List[I]) is TSUser) then
    begin
      if (Connection.MySQLVersion < 40101) then
      begin
        SQL := SQL + 'DELETE FROM ' + Connection.EscapeIdentifier('mysql') + '.' + Connection.EscapeIdentifier('user')         + ' WHERE ' + Connection.EscapeIdentifier('User') + '=' + SQLEscape(TSUser(List[I]).Name) + ';' + #13#10;
        SQL := SQL + 'DELETE FROM ' + Connection.EscapeIdentifier('mysql') + '.' + Connection.EscapeIdentifier('db')           + ' WHERE ' + Connection.EscapeIdentifier('User') + '=' + SQLEscape(TSUser(List[I]).Name) + ';' + #13#10;
        SQL := SQL + 'DELETE FROM ' + Connection.EscapeIdentifier('mysql') + '.' + Connection.EscapeIdentifier('tables_priv')  + ' WHERE ' + Connection.EscapeIdentifier('User') + '=' + SQLEscape(TSUser(List[I]).Name) + ';' + #13#10;
        SQL := SQL + 'DELETE FROM ' + Connection.EscapeIdentifier('mysql') + '.' + Connection.EscapeIdentifier('columns_priv') + ' WHERE ' + Connection.EscapeIdentifier('User') + '=' + SQLEscape(TSUser(List[I]).Name) + ';' + #13#10;
      end
      else
        SQL := SQL + 'DROP USER ' + EscapeUser(TSUser(List[I]).Name) + ';' + #13#10;
      FlushPrivileges := True;
    end;

  for I := 0 to List.Count - 1 do
    if (TObject(List[I]) is TSProcess) then
      if (Connection.MySQLVersion < 50000) then
        SQL := SQL + 'KILL ' + IntToStr(TSProcess(List[I]).ThreadId) + ';' + #13#10
      else
        SQL := SQL + 'KILL CONNECTION ' + IntToStr(TSProcess(List[I]).ThreadId) + ';' + #13#10;

  if (FlushPrivileges) then
    SQL := SQL + 'FLUSH PRIVILEGES;' + #13#10;

  Result := (SQL = '') or SendSQL(SQL, SessionResult);
end;

function TSSession.DeleteProcess(const Process: TSProcess): Boolean;
var
  List: TList;
begin
  List := TList.Create();
  List.Add(Process);
  Result := DeleteEntities(List);
  List.Free();
end;

destructor TSSession.Destroy();
begin
  Connection.UnRegisterClient(Self);
  if (Assigned(Account)) then Account.UnRegisterSession(Self);

  EventProcs.Free();

  if (Assigned(FCharsets)) then FCharsets.Free();
  if (Assigned(FCollations)) then FCollations.Free();
  if (Assigned(FDatabases)) then FDatabases.Free();
  if (Assigned(FEngines)) then FEngines.Free();
  if (Assigned(FFieldTypes)) then FFieldTypes.Free();
  if (Assigned(FItemSearches)) then FItemSearches.Free();
  if (Assigned(FPlugins)) then FPlugins.Free();
  if (Assigned(FProcesses)) then FProcesses.Free();
  if (Assigned(FQuickAccess)) then FQuickAccess.Free();
  if (Assigned(FSQLMonitor)) then FSQLMonitor.Free();
  if (Assigned(FUsers)) then FUsers.Free();
  if (Assigned(FVariables)) then FVariables.Free();
  if (Assigned(StmtMonitor)) then StmtMonitor.Free();

  Sessions.Delete(Sessions.IndexOf(Self));

  FMetadataProvider.Free();
  FSyntaxProvider.Free();
  if (UnparsableSQL <> '') then
  begin
    if (Connection.AnsiQuotes) then
      UnparsableSQL :=
        '# MySQL: ' + Self.Connection.ServerVersionStr + #13#10
        + '# AnsiQuotes: Enabled' + #13#10
        + #13#10
        + UnparsableSQL
    else
      UnparsableSQL :=
        '# MySQL: ' + Self.Connection.ServerVersionStr + #13#10
        + #13#10
        + UnparsableSQL;
    SendToDeveloper(UnparsableSQL, 7, True);
  end;

  FConnection.Free();

  inherited;
end;

procedure TSSession.DoSendEvent(const AEvent: TSSession.TEvent);
var
  I: Integer;
begin
  // Debug 2017-04-27
  Assert(Assigned(EventProcs));

  for I := 0 to EventProcs.Count - 1 do
    EventProcs[I](AEvent);
end;

procedure TSSession.EmptyDatabases(const Databases: TList);
var
  I: Integer;
begin
  for I := 0 to Databases.Count - 1 do
    TSDatabase(Databases[I]).EmptyTables();
end;

function TSSession.EncodeInterval(const Year, Month, Day, Quarter, Week, Hour, Minute, Second, MSec: Word; var Value: string; var IntervalType: TSEvent.TIntervalType): Boolean;
begin
  if ((Year <> 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Year); IntervalType := itYear; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter <> 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Quarter); IntervalType := itQuarter; end
  else if ((Year = 0) and (Month <> 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Month); IntervalType := itMonth; end
  else if ((Year = 0) and (Month = 0) and (Day <> 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Day); IntervalType := itDay; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour <> 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Hour); IntervalType := itHour; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute <> 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Minute); IntervalType := itMinute; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week <> 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := IntToStr(Week); IntervalType := itWeek; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second <> 0) and (MSec = 0)) then
    begin Value := IntToStr(Second); IntervalType := itSecond; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec <> 0)) then
    begin Value := IntToStr(MSec); IntervalType := itMicrosecond; end
  else if ((Year <> 0) and (Month <> 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Year) + '-' + IntToStr(Month)); IntervalType := itYearMonth; end
  else if ((Year = 0) and (Month = 0) and (Day <> 0) and (Quarter = 0) and (Week = 0) and (Hour <> 0) and (Minute = 0) and (Second = 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Day) + ' ' + IntToStr(Hour)); IntervalType := itDayHour; end
  else if ((Year = 0) and (Month = 0) and (Day <> 0) and (Quarter = 0) and (Week = 0)                 and (Minute <> 0) and (Second = 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Day) + ' ' + IntToStr(Hour) + ':' + IntToStr(Minute)); IntervalType := itDayMinute; end
  else if ((Year = 0) and (Month = 0) and (Day <> 0) and (Quarter = 0) and (Week = 0)                                 and (Second <> 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Day) + ' ' + IntToStr(Hour) + ':' + IntToStr(Minute) + ':' + IntToStr(Second)); IntervalType := itDaySecond; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour <> 0) and (Minute <> 0) and (Second = 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Hour) + ':' + IntToStr(Minute)); IntervalType := itHourMinute; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour <> 0)                  and (Second <> 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Hour) + ':' + IntToStr(Minute) + ':' + IntToStr(Second)); IntervalType := itHourSecond; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute <> 0) and (Second <> 0) and (MSec = 0)) then
    begin Value := SQLEscape(IntToStr(Minute) + ':' + IntToStr(Second)); IntervalType := itMinuteSecond; end
  else if ((Year = 0) and (Month = 0) and (Day <> 0)                                                                                   and (MSec <> 0)) then
    begin Value := SQLEscape(IntToStr(Day) + ' ' + IntToStr(Hour) + ':' + IntToStr(Minute) + IntToStr(Second) + '.' + IntToStr(MSec)); IntervalType := itDayMicrosecond; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour <> 0)                                   and (MSec <> 0)) then
    begin Value := SQLEscape(IntToStr(Hour) + ':' + IntToStr(Minute) + IntToStr(Second) + '.' + IntToStr(MSec)); IntervalType := itHourMicrosecond; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute <> 0)                  and (MSec <> 0)) then
    begin Value := SQLEscape(IntToStr(Minute) + IntToStr(Second) + '.' + IntToStr(MSec)); IntervalType := itMinuteMicrosecond; end
  else if ((Year = 0) and (Month = 0) and (Day = 0) and (Quarter = 0) and (Week = 0) and (Hour = 0) and (Minute = 0) and (Second <> 0) and (MSec <> 0)) then
    begin Value := SQLEscape(IntToStr(Hour) + ':' + IntToStr(Minute)); IntervalType := itSecondMicrosecond; end
  else
    begin Value := ''; IntervalType := itUnknown; end;

  Result := IntervalType <> itUnknown;
end;

function TSSession.EngineByName(const EngineName: string): TSEngine;
var
  Index: Integer;
begin
  Index := Engines.IndexByName(EngineName);
  if (Index < 0) then
    Result := nil
  else
    Result := Engines[Index];
end;

function TSSession.EscapeRightIdentifier(const Identifier: string; const IdentifierQuoting: Boolean = False): string;
begin
  if (IdentifierQuoting) then
    Result := SQLEscape(Identifier)
  else
    Result := Connection.EscapeIdentifier(Identifier);
end;

function TSSession.EscapeUser(const User: string; const IdentifierQuoting: Boolean = False): string;
var
  Count: Integer;
  Host: string;
  Username: string;
begin
  Count := Pos('@', User);
  if (Count = 0) then
    Count := Length(User)
  else
    Dec(Count);
  Username := Copy(User, 1, Count);
  if (Count < Length(User)) then
    Host := Copy(User, Count + 2, Length(User) - Count)
  else
    Host := '';

  if (IdentifierQuoting) then
    if (Host = '') then
      Result := SQLEscape(Username)
    else
      Result := SQLEscape(Username) + '@' + SQLEscape(Host)
  else
    if (Host = '') then
      Result := Connection.EscapeIdentifier(Username)
    else
      Result := Connection.EscapeIdentifier(Username) + '@' + Connection.EscapeIdentifier(Host);
end;

function TSSession.FieldTypeByCaption(const Text: string): TSFieldType;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to FieldTypes.Count - 1 do
    if (FieldTypes.NameCmp(FieldTypes[I].Name, Text) = 0) then
      Result := FieldTypes[I];

  if (not Assigned(Result)) then
    if ((StrIComp(PChar(Text), 'BOOL') = 0) or (StrIComp(PChar(Text), 'BOOLEAN') = 0)) then
      Result := FieldTypeByMySQLFieldType(mfTinyInt)
    else if (StrIComp(PChar(Text), 'INT4') = 0) then
      Result := FieldTypeByMySQLFieldType(mfMediumInt)
    else if (StrIComp(PChar(Text), 'INTEGER') = 0) then
      Result := FieldTypeByMySQLFieldType(mfInt)
    else if (StrIComp(PChar(Text), 'LONG') = 0) then
      Result := FieldTypeByMySQLFieldType(mfInt)
    else if (StrIComp(PChar(Text), 'DEC') = 0) then
      Result := FieldTypeByMySQLFieldType(mfDecimal)
    else if (StrIComp(PChar(Text), 'NVARCHAR') = 0) then
      Result := FieldTypeByMySQLFieldType(mfVarChar)
    else if (StrIComp(PChar(Text), 'SERIAL') = 0) then
      Result := FieldTypeByMySQLFieldType(mfInt);

  if (not Assigned(Result)) then
    raise Exception.CreateFMT('Unknown field type "%s"  (%d known field types)', [Text, FieldTypes.Count]);
end;

function TSSession.FieldTypeByMySQLFieldType(const MySQLFieldType: TSField.TFieldType): TSFieldType;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to FieldTypes.Count - 1 do
    if (FieldTypes[I].MySQLFieldType = MySQLFieldType) then
      Result := FieldTypes[I];
end;

function TSSession.GetAddress(): string;
begin
  Result := Account.ExpandAddress('/');
end;

function TSSession.GetCaption(): string;
begin
  Result := Connection.Host;
  if (Connection.Port <> MYSQL_PORT) then
    Result := Result + ':' + IntToStr(Connection.Port);
end;

function TSSession.GetCharset(): string;
begin
  if (Assigned(VariableByName('character_set'))) then
    Result := VariableByName('character_set').Value
  else if (Assigned(VariableByName('character_set_server'))) then
    Result := VariableByName('character_set_server').Value
  else
    Result := 'latin1';
end;

function TSSession.GetCollation(): string;
begin
  if (Assigned(VariableByName('collation_server'))) then
    Result := VariableByName('collation_server').Value
  else
    Result := '';
end;

function TSSession.GetSQLParser(): TSQLParser;
begin
  Result := Connection.SQLParser;
end;

function TSSession.GetUserRights(): TSUserRight;
begin
  if (not Assigned(User) or (User.RightCount = 0)) then
    Result := nil
  else
    Result := User.Rights[0];
end;

function TSSession.GetValid(): Boolean;
var
  I: Integer;
begin
  Result := (FCurrentUser <> '') and Assigned(FUser)
    and Variables.Valid and Engines.Valid and Charsets.Valid and (not Assigned(Collations) or Collations.Valid) and Users.Valid
    and Databases.Valid;
  for I := 0 to Databases.Count - 1 do
    Result := Result and (Databases[I].Valid);
end;

procedure TSSession.GridCanEditShow(Sender: TObject);
var
  Database: TSDatabase;
  Field: TSTableField;
  FieldInfo: TFieldInfo;
  Grid: TMySQLDBGrid;
  I: Integer;
  J: Integer;
  Table: TSTable;
begin
  if ((Sender is TMySQLDBGrid) and (TMySQLDBGrid(Sender).DataSource.DataSet is TMySQLDataSet)) then
  begin
    Grid := TMySQLDBGrid(Sender);

    for I := 0 to Grid.Columns.Count - 1 do
    begin
      if (Assigned(Grid.Columns[I].Field)
        and GetFieldInfo(Grid.Columns[I].Field.Origin, FieldInfo)) then
      begin
        Database := DatabaseByName(FieldInfo.DatabaseName);
        if (Assigned(Database)) then
        begin
          Table := Database.TableByName(FieldInfo.TableName);
          if (Assigned(Table)) then
          begin
            Field := Table.FieldByName(FieldInfo.OriginalFieldName);
            if (Assigned(Field)) then
            begin
              Grid.Columns[I].PickList.Clear();
              if (Field.FieldType = mfEnum) then
                for J := 0 to Length(Field.Elements) - 1 do
                  Grid.Columns[I].PickList.Add(Field.Elements[J]);

              Grid.Columns[I].ButtonStyle := cbsAuto;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TSSession.Invalidate();
begin
  if (Assigned(Variables)) then Variables.Invalidate();
  if (Assigned(Engines)) then Engines.Invalidate();
  if (Assigned(Charsets)) then Charsets.Invalidate();
  if (Assigned(Collations)) then Collations.Invalidate();
  if (Assigned(Databases)) then Databases.Invalidate();
  if (Assigned(Plugins)) then Plugins.Invalidate();
  if (Assigned(Users)) then Users.Invalidate();
end;

function TSSession.ItemByAddress(const Address: string; const ExecuteUpdates: Boolean = False): TSItem;
var
  Database: TSDatabase;
  Table: TSTable;
  URI: TUURI;
begin
  URI := TUURI.Create(Address);

  if (ExecuteUpdates and (URI.Database <> '')) then
  begin
    Connection.BeginSynchron(10);
    Databases.Update();
    Connection.EndSynchron(10);
  end;
  Database := DatabaseByName(URI.Database);
  if (not Assigned(Database)) then
    Table := nil
  else
  begin
    Table := Database.TableByName(URI.Table);
    if (ExecuteUpdates
      and Assigned(Table)
      and ((URI.Param['objecttype'] = 'key') or (URI.Param['objecttype'] = 'basefield') or (URI.Param['objecttype'] = 'foreigkey') or (URI.Param['objecttype'] = 'viewfield'))) then
    begin
      Connection.BeginSynchron(10);
      Table.Update();
      Connection.EndSynchron(10);
    end;
  end;

  if ((URI.Param['objecttype'] = 'view')
    or (URI.Param['objecttype'] = 'systemview')) then
    Result := Table
  else if (URI.Param['objecttype'] = 'procedure') then
    if (not Assigned(Database)) then
      Result := nil
    else
      Result := Database.ProcedureByName(URI.Param['object'])
  else if (URI.Param['objecttype'] = 'function') then
    if (not Assigned(Database)) then
      Result := nil
    else
      Result := Database.FunctionByName(URI.Param['object'])
  else if (URI.Param['objecttype'] = 'trigger') then
    if (not Assigned(Database)) then
      Result := nil
    else
      Result := Database.TriggerByName(URI.Param['object'])
  else if (URI.Param['objecttype'] = 'event') then
    if (not Assigned(Database)) then
      Result := nil
    else
      Result := Database.EventByName(URI.Param['object'])
  else if (URI.Param['objecttype'] = 'key') then
    if (not (Table is TSBaseTable)) then
      Result := nil
    else
      Result := TSBaseTable(Table).KeyByName(URI.Param['object'])
  else if (URI.Param['objecttype'] = 'basefield') then
    if (not (Table is TSBaseTable)) then
      Result := nil
    else
      Result := Database.BaseTableByName(URI.Table).FieldByName(URI.Param['object'])
  else if (URI.Param['objecttype'] = 'foreignkey') then
    if (not (Table is TSBaseTable)) then
      Result := nil
    else
      Result := Database.BaseTableByName(URI.Table).ForeignKeyByName(URI.Param['object'])
  else if (URI.Param['objecttype'] = 'viewfield') then
    if (not (Table is TSView)) then
      Result := nil
    else
      Result := TSView(Table).FieldByName(URI.Param['object'])
  else if (URI.Table <> '') then
    Result := Table
  else if (URI.Database <> '') then
    Result := Database
  else
    raise ERangeError.Create('Unknown Item for: ' + URI.Address);

  URI.Free();
end;

procedure TSSession.MonitorLog(const Connection: TMySQLConnection; const Text: PChar; const Len: Integer; const ATraceType: TMySQLMonitor.TTraceType);
begin
  SendEvent(etMonitor);
end;

procedure TSSession.MonitorExecutedStmts(const Connection: TMySQLConnection;
  const Text: PChar; const Len: Integer; const ATraceType: TMySQLMonitor.TTraceType);
var
  Database: TSDatabase;
  DatabaseName: string;
  DDLStmt: TSQLDDLStmt;
  DMLStmt: TSQLDMLStmt;
  Event: TSEvent;
  First: Boolean;
  NewUsername: string;
  NextDDLStmt: TSQLDDLStmt;
  NextSQL: string;
  ObjectName: string;
  OldObjectName: string;
  Parse: TSQLParse;
  Process: TSProcess;
  Routine: TSRoutine;
//  S: string;
  SQL: string;
  Table: TSTable;
  Trigger: TSTrigger;
  User: TSUser;
  Variable: TSVariable;
begin
  if (GetUTCTime() <= IncDay(GetCompileTime(), 7)) then
  begin
    SQL := SQLTrimStmt(Text, Len);
    if ((Length(SQL) > 0) and (SQL[1] <> ';')) then
    begin
      // Debug 2017-05-01
      Assert(Assigned(SQLParser));

      if ((Connection.ErrorCode = ER_PARSE_ERROR) and SQLParser.ParseSQL(SQL)) then
      begin
//        UnparsableSQL := UnparsableSQL
//          + '# MonitorExecutedStmts() - ER_PARSE_ERROR' + #13#10
//          + '# ErrorMessage: ' + Connection.ErrorMessage + #13#10
//          + Trim(SQL) + #13#10 + #13#10 + #13#10;
      end
      else if ((Connection.ErrorCode = 0)
        and not SQLParser.ParseSQL(SQL)
        and not (SQLParser.ErrorCode in [PE_IncompleteStmt, PE_IncompleteToken])) then
      begin
        UnparsableSQL := UnparsableSQL
          + '# MonitorExecutedStmts()' + #13#10
          + '# Error: ' + SQLParser.ErrorMessage + #13#10
          + Trim(SQL) + #13#10 + #13#10 + #13#10;
      end;
      SQLParser.Clear();
    end;
  end;

  if ((Connection.ErrorCode = 0) and SQLCreateParse(Parse, Text, Len, Connection.MySQLVersion)) then
    if (SQLParseKeyword(Parse, 'SELECT') or SQLParseKeyword(Parse, 'SHOW')) then
      // Do nothing - and do not parse the Text further more
    else if (SQLParseDDLStmt(DDLStmt, Text, Len, Connection.MySQLVersion)) then
    begin
      DDLStmt.DatabaseName := TableName(DDLStmt.DatabaseName);
      if (DDLStmt.ObjectType = otTable) then
        DDLStmt.ObjectName := TableName(DDLStmt.ObjectName);

      if (DDLStmt.ObjectType = otDatabase) then
        case (DDLStmt.DefinitionType) of
          dtCreate:
            if (Assigned(DatabaseByName(DDLStmt.ObjectName))) then
              DatabaseByName(DDLStmt.ObjectName).Invalidate()
            else
              Databases.Add(TSDatabase.Create(Databases, DDLStmt.ObjectName), True);
          dtRename,
          dtAlter:
            begin
              Database := DatabaseByName(DDLStmt.ObjectName);
              if (not Assigned(Database)) then
                Databases.Add(TSDatabase.Create(Databases, DDLStmt.ObjectName), True)
              else
              begin
                Database.InvalidateSource();
                if (DDLStmt.NewDatabaseName <> '') then
                  Database.Name := DDLStmt.NewDatabaseName;
              end;
            end;
          dtDrop:
            begin
              Database := DatabaseByName(DDLStmt.ObjectName);
              if (Assigned(Database)) then
                Databases.Delete(Database);
            end;
        end
      else
      begin
        if (DDLStmt.DatabaseName = '') then
          DatabaseName := Connection.DatabaseName
        else
          DatabaseName := DDLStmt.DatabaseName;
        Database := DatabaseByName(DatabaseName);
        if (Assigned(Database)) then
          case (DDLStmt.ObjectType) of
            otTable,
            otView:
              case (DDLStmt.DefinitionType) of
                dtCreate:
                  begin
                    Table := Database.TableByName(DDLStmt.ObjectName);
                    if (Assigned(Table)) then
                      Table.Invalidate()
                    else
                    begin
                      if (DDLStmt.ObjectType = otTable) then
                        Table := TSBaseTable.Create(Database.Tables, DDLStmt.ObjectName)
                      else
                        Table := TSView.Create(Database.Tables, DDLStmt.ObjectName);
                      Database.Tables.Add(Table, True);
                    end;
                  end;
                dtRename:
                  if (SQLParseKeyword(Parse, 'RENAME')
                    and (SQLParseKeyword(Parse, 'TABLE') or SQLParseKeyword(Parse, 'VIEW'))) then
                  repeat
                    DatabaseName := Connection.DatabaseName;
                    if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then
                    begin
                      Database := DatabaseByName(DatabaseName);
                      DDLStmt.NewDatabaseName := DatabaseName;
                      if (SQLParseKeyword(Parse, 'TO') and SQLParseObjectName(Parse, DDLStmt.NewDatabaseName, DDLStmt.NewObjectName)) then
                      begin
                        Table := Database.TableByName(ObjectName);
                        if (not Assigned(Table)) then
                          Database.Tables.Add(TSBaseTable.Create(Database.Tables, ObjectName))
                        else
                        begin
                          Table.SetDatabase(DatabaseByName(DDLStmt.NewDatabaseName));
                          Table.Name := DDLStmt.NewObjectName;
                        end;
                      end;
                    end;
                  until (not SQLParseChar(Parse, ','));
                dtAlter,
                dtAlterRename:
                  begin
                    Table := Database.TableByName(DDLStmt.ObjectName);
                    if (not Assigned(Table)) then
                      Database.Tables.Add(TSBaseTable.Create(Database.Tables, DDLStmt.ObjectName))
                    else
                    begin
                      Table.Invalidate();
                      if ((DDLStmt.ObjectType = otTable) and (Table is TSBaseTable)) then
                      begin
                        SetString(SQL, Text, Len);
                        TSBaseTable(Table).ParseAlterTable(SQL);
                      end;

                      if (DDLStmt.NewDatabaseName <> '') then
                        Table.SetDatabase(Database);
                      if (DDLStmt.NewObjectName <> '') then
                        Table.Name := DDLStmt.NewObjectName;
                    end;
                  end;
                dtDrop:
                  if (not SQLParseKeyword(Parse, 'DROP')
                    or not SQLParseKeyword(Parse, 'TABLE') and not SQLParseKeyword(Parse, 'VIEW')) then
                    raise ERangeError.Create('SQL: ' + SQL)
                  else
                  begin
                    SQLParseKeyword(Parse, 'IF EXISTS');
                    First := True; Database := nil;
                    repeat
                      DatabaseName := Connection.DatabaseName;
                      if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then
                      begin
                        if (Assigned(Database) and (Database <> DatabaseByName(DatabaseName))) then
                          SendEvent(etItemsValid, Database, Database.Tables);
                        Database := DatabaseByName(DatabaseName);
                        Table := Database.TableByName(ObjectName);
                        if (Assigned(Table)) then
                        begin
                          NextSQL := Connection.NextCommandText;
                          if (First
                            and not SQLParseChar(Parse, ',', False)
                            and SQLParseDDLStmt(NextDDLStmt, PChar(NextSQL), Length(NextSQL), Connection.MySQLVersion)
                            and (NextDDLStmt.ObjectType = DDLStmt.ObjectType)
                            and ((NextDDLStmt.DatabaseName = DDLStmt.DatabaseName) or (NextDDLStmt.DatabaseName = ''))
                            and (NextDDLStmt.ObjectName = DDLStmt.ObjectName)) then
                            // will be handled in the next Stmt
                          else
                            Database.Tables.Delete(Table);
                        end;
                      end;
                      First := False;
                    until (not SQLParseChar(Parse, ','));
                    SendEvent(etItemsValid, Database, Database.Tables);
                  end;
              end;
            otFunction,
            otProcedure:
              case (DDLStmt.DefinitionType) of
                dtCreate:
                  begin
                    if (DDLStmt.ObjectType = otProcedure) then
                      Routine := Database.ProcedureByName(DDLStmt.ObjectName)
                    else
                      Routine := Database.FunctionByName(DDLStmt.ObjectName);
                    if (Assigned(Routine)) then
                      Routine.Invalidate()
                    else if (DDLStmt.ObjectType = otProcedure) then
                      Database.Routines.Add(TSProcedure.Create(Database.Routines, DDLStmt.ObjectName), True)
                    else
                      Database.Routines.Add(TSFunction.Create(Database.Routines, DDLStmt.ObjectName), True);
                  end;
                dtAlter,
                dtAlterRename:
                  begin
                    if (DDLStmt.ObjectType = otProcedure) then
                      Routine := Database.ProcedureByName(DDLStmt.ObjectName)
                    else
                      Routine := Database.FunctionByName(DDLStmt.ObjectName);
                    if (not Assigned(Routine)) then
                      if (DDLStmt.ObjectType = otProcedure) then
                        Database.Routines.Add(TSRoutine.Create(Database.Routines, DDLStmt.ObjectName))
                      else
                        Database.Routines.Add(TSFunction.Create(Database.Routines, DDLStmt.ObjectName))
                    else
                    begin
                      Routine.Invalidate();
                      if (DDLStmt.NewDatabaseName <> '') then
                        Routine.SetDatabase(DatabaseByName(DDLStmt.NewDatabaseName));
                      if (DDLStmt.NewObjectName <> '') then
                        Routine.Name := DDLStmt.NewObjectName;
                    end;
                  end;
                dtDrop:
                  begin
                    NextSQL := Connection.NextCommandText;
                    if (SQLParseDDLStmt(NextDDLStmt, PChar(NextSQL), Length(NextSQL), Connection.MySQLVersion)
                      and (NextDDLStmt.ObjectType = DDLStmt.ObjectType)
                      and ((NextDDLStmt.DatabaseName = DDLStmt.DatabaseName) or (NextDDLStmt.DatabaseName = ''))
                      and ((NextDDLStmt.DatabaseName = DDLStmt.DatabaseName) or (NextDDLStmt.DatabaseName = ''))) then
                    begin
                      if (DDLStmt.ObjectType = otProcedure) then
                        Routine := Database.ProcedureByName(DDLStmt.ObjectName)
                      else
                        Routine := Database.FunctionByName(DDLStmt.ObjectName);
                      if ((NextDDLStmt.ObjectName <> DDLStmt.ObjectName) and Assigned(Routine)) then
                        Routine.Name := NextDDLStmt.ObjectName;
                      // The DROP will be ignored, since it will be re-created in the next statement...
                    end
                    else
                    begin
                      if (DDLStmt.ObjectType = otProcedure) then
                        Routine := Database.ProcedureByName(DDLStmt.ObjectName)
                      else
                        Routine := Database.FunctionByName(DDLStmt.ObjectName);
                      if (Assigned(Routine)) then
                        Database.Routines.Delete(Routine);
                    end;
                  end;
              end;
            otTrigger:
              case (DDLStmt.DefinitionType) of
                dtCreate:
                  begin
                    Trigger := Database.TriggerByName(DDLStmt.ObjectName);
                    if (Assigned(Trigger)) then
                      Trigger.Invalidate()
                    else
                      Database.Triggers.Add(TSTrigger.Create(Database.Triggers, DDLStmt.ObjectName), True);
                  end;
                dtAlter,
                dtAlterRename:
                  begin
                    Trigger := Database.TriggerByName(DDLStmt.ObjectName);
                    if (not Assigned(Trigger)) then
                      Database.Triggers.Add(TSTrigger.Create(Database.Triggers, DDLStmt.ObjectName))
                    else
                    begin
                      Trigger.Invalidate();
                      if (DDLStmt.NewDatabaseName <> '') then
                        Trigger.SetDatabase(DatabaseByName(DDLStmt.NewDatabaseName));
                      if (DDLStmt.NewObjectName <> '') then
                        Trigger.Name := DDLStmt.NewObjectName;
                    end;
                  end;
                dtDrop:
                  begin
                    NextSQL := Connection.NextCommandText;
                    if (SQLParseDDLStmt(NextDDLStmt, PChar(NextSQL), Length(NextSQL), Connection.MySQLVersion)
                      and (NextDDLStmt.ObjectType = DDLStmt.ObjectType)
                      and ((NextDDLStmt.DatabaseName = DDLStmt.DatabaseName) or (NextDDLStmt.DatabaseName = ''))) then
                    begin
                      Trigger := Database.TriggerByName(DDLStmt.ObjectName);
                      if ((NextDDLStmt.ObjectName <> DDLStmt.ObjectName) and Assigned(Trigger)) then
                        Trigger.Name := NextDDLStmt.ObjectName;
                      // The DROP will be ignored, since it will be re-created in the next statement...
                    end
                    else
                    begin
                      Trigger := Database.TriggerByName(DDLStmt.ObjectName);
                      if (Assigned(Trigger)) then
                        Database.Triggers.Delete(Trigger);
                    end;
                  end;
              end;
            otEvent:
              case (DDLStmt.DefinitionType) of
                dtCreate:
                  begin
                    Event := Database.EventByName(DDLStmt.ObjectName);
                    if (Assigned(Event)) then
                      Event.Invalidate()
                    else
                      Database.Events.Add(TSEvent.Create(Database.Events, DDLStmt.ObjectName), True);
                  end;
                dtAlter,
                dtAlterRename:
                  begin
                    Event := Database.EventByName(DDLStmt.ObjectName);
                    if (not Assigned(Event)) then
                      Database.Events.Add(TSEvent.Create(Database.Events, DDLStmt.ObjectName))
                    else
                    begin
                      Event.Invalidate();
                      if (DDLStmt.NewDatabaseName <> '') then
                        Event.SetDatabase(DatabaseByName(DDLStmt.NewDatabaseName));
                      if (DDLStmt.NewObjectName <> '') then
                        Event.Name := DDLStmt.NewObjectName;
                    end;
                  end;
                dtDrop:
                  begin
                    Event := Database.EventByName(DDLStmt.ObjectName);
                    if (Assigned(Event)) then
                      Database.Events.Delete(Event);
                  end;
              end;
        end;
      end;
    end
    else if (SQLParseDMLStmt(DMLStmt, PChar(SQL), Length(SQL), Connection.MySQLVersion)) then
    begin
      if ((Length(DMLStmt.DatabaseNames) = 1) and (Length(DMLStmt.TableNames) = 1)
        and (Databases.NameCmp(DMLStmt.DatabaseNames[0], 'mysql') = 0) and (TableNameCmp(DMLStmt.TableNames[0], 'user') = 0)) then
        Users.Invalidate();
      if ((DMLStmt.ManipulationType = mtDelete) and SQLParseKeyword(Parse, 'DELETE FROM')) then
      begin
        DatabaseName := Connection.DatabaseName;
        if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then
        begin
          Database := DatabaseByName(DatabaseName);
          if (Assigned(Database)) then
          begin
            Table := Database.BaseTableByName(ObjectName);
            if (Assigned(Table) and (SQLParseEnd(Parse) or SQLParseChar(Parse, ';'))) then
            begin
              // It's not possible to call Table.InvalidateData, since maybe
              // we are inside TDataSet.Delete - and we can not close the
              // DataSet while this
              TSBaseTable(Table).InvalidateStatus();
              SendEvent(etItemValid, Database, Database.Tables, Table);
            end;
          end;
        end;
      end;
    end
    else if (SQLParseKeyword(Parse, 'RENAME') and SQLParseKeyword(Parse, 'USER')) then
    begin
      User := UserByName(SQLParseValue(Parse));
      if (Assigned(User)) then
      begin
        User.Invalidate();
        if (SQLParseKeyword(Parse, 'TO')) then
        begin
          NewUsername := SQLParseValue(Parse);
          if (NewUsername <> '') then
            User.Name := NewUsername;
        end;
      end;
    end
    else if (SQLParseKeyword(Parse, 'SET')) then
    begin
      repeat
        if (SQLParseKeyword(Parse, 'NAMES') or SQLParseKeyword(Parse, 'CHARACTER SET') or SQLParseKeyword(Parse, 'CHARSET')) then
        begin
          Connection.CharsetClient := SQLParseValue(Parse);
          Connection.CharsetResult := Connection.CharsetClient;
        end
        else if ((SQLParseKeyword(Parse, 'GLOBAL') or SQLParseKeyword(Parse, 'SESSION')) and not SQLParseChar(Parse, '@', False)) then
        begin
          Variable := VariableByName(SQLParseValue(Parse));
          if (Assigned(Variable) and SQLParseChar(Parse, '=')) then
          begin
            Variable.FValue := SQLParseValue(Parse);
            SendEvent(etItemValid, Self, Variables, Variable);
          end;
        end
        else
        begin
          ObjectName := SQLParseValue(Parse);
          if (Copy(ObjectName, 1, 2) = '@@') then
          begin
            Delete(ObjectName, 1, 2);
            if (LowerCase(Copy(ObjectName, 1, 7)) = 'global.') then
              Delete(ObjectName, 1, 7)
            else if (LowerCase(Copy(ObjectName, 1, 8)) = 'session.') then
              Delete(ObjectName, 1, 8);
            Variable := VariableByName(ObjectName);
            if (Assigned(Variable) and SQLParseChar(Parse, '=')) then
            begin
              Variable.FValue := SQLParseValue(Parse);
              SendEvent(etItemValid, Self, Variables, Variable);
            end;
          end;
        end;
      until (not SQLParseChar(Parse, ','));
    end
    else if (SQLParseKeyword(Parse, 'OPTIMIZE')) then
    begin
      SQLParseKeyword(Parse, 'NO_WRITE_TO_BINLOG');
      SQLParseKeyword(Parse, 'LOCAL');
      if (SQLParseKeyword(Parse, 'TABLE')) then
        repeat
          DatabaseName := Connection.DatabaseName;
          if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then
          begin
            Database := DatabaseByName(DatabaseName);
            if (Assigned(Database)) then
            begin
              Table := Database.BaseTableByName(ObjectName);
              if (Assigned(Table)) then
              begin
                TSBaseTable(Table).InvalidateStatus();
                SendEvent(etItemValid, Database, Database.Tables, Table);
              end;
            end;
          end;
        until (not SQLParseChar(Parse, ','));
    end
    else if (SQLParseKeyword(Parse, 'TRUNCATE')) then
    begin
      SQLParseKeyword(Parse, 'TABLE');
      DatabaseName := Connection.DatabaseName;
      if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then
      begin
        Database := DatabaseByName(DatabaseName);
        if (Assigned(Database)) then
        begin
          Table := Database.TableByName(ObjectName);
          if (Assigned(Table)) then
          begin
            Table.InvalidateData();
            SendEvent(etItemValid, Database, Database.Tables, Table);
          end;
        end;
      end;
    end
    else if (SQLParseKeyword(Parse, 'CREATE USER')) then
      repeat
        ObjectName := SQLParseValue(Parse);
        Users.Add(TSUser.Create(Users, ObjectName), True);
        while (not SQLParseEnd(Parse) and not SQLParseChar(Parse, ',') and not SQLParseChar(Parse, ';')) do
          SQLParseValue(Parse);
      until (not SQLParseChar(Parse, ','))
    else if (SQLParseKeyword(Parse, 'RENAME USER')) then
      repeat
        OldObjectName := SQLParseValue(Parse);
        if (SQLParseKeyword(Parse, 'TO')) then
        begin
          ObjectName := SQLParseValue(Parse);
          User := UserByName(OldObjectName);
          if (Assigned(User)) then
            User.Name := ObjectName;
        end;
      until (not SQLParseChar(Parse, ','))
    else if (SQLParseKeyword(Parse, 'GRANT')) then
      begin
        while (not SQLParseChar(Parse, ';') and not SQLParseEnd(Parse) and not SQLParseKeyword(Parse, 'TO', False)) do
          SQLParseValue(Parse);
        if (SQLParseKeyword(Parse, 'TO')) then
          repeat
            ObjectName := SQLParseValue(Parse);
            User := UserByName(ObjectName);
            if (Assigned(User)) then
            begin
              User.Invalidate();
              SendEvent(etItemRenamed, Self, Users, User);
            end;
            while (not SQLParseChar(Parse, ';') and not SQLParseEnd(Parse) and not SQLParseKeyword(Parse, 'REQUIRE', False) and not SQLParseKeyword(Parse, 'WITH', False) and not SQLParseChar(Parse, ',', False)) do
              SQLParseValue(Parse);
          until (not SQLParseChar(Parse, ','));
      end
    else if (SQLParseKeyword(Parse, 'REVOKE')) then
      begin
        while (not SQLParseEnd(Parse) and not SQLParseKeyword(Parse, 'FROM', False)) do
          SQLParseValue(Parse);
        if (SQLParseKeyword(Parse, 'FROM')) then
          repeat
            ObjectName := SQLParseValue(Parse);
            User := UserByName(ObjectName);
            if (Assigned(User)) then
            begin
              User.Invalidate();
              SendEvent(etItemValid, Self, Users, User);
            end;
          until (not SQLParseChar(Parse, ','));
      end
    else if (SQLParseKeyword(Parse, 'DROP USER')) then
      repeat
        ObjectName := SQLParseValue(Parse);
        User := UserByName(ObjectName);
        if (Assigned(User)) then
          Users.Delete(User);
      until (not SQLParseChar(Parse, ','))
    else if (SQLParseKeyword(Parse, 'KILL') and (SQLParseKeyword(Parse, 'CONNECTION') or not SQLParseKeyword(Parse, 'QUERY'))) then
    begin
      ObjectName := SQLParseValue(Parse);
      Process := ProcessByThreadId(StrToInt64(ObjectName));
      if (Assigned(Process)) then
        Processes.Delete(Process);
    end;
end;

function TSSession.PluginByName(const PluginName: string): TSPlugin;
var
  Index: Integer;
begin
  Index := Plugins.IndexByName(PluginName);
  if (Index < 0) then
    Result := nil
  else
    Result := Plugins[Index];
end;

function TSSession.ProcessByThreadId(const ThreadId: Longword): TSProcess;
var
  I: Integer;
begin
  Result := nil;

  if (Assigned(Processes)) then
    for I := 0 to Processes.Count - 1 do
      if (Processes[I].ThreadId = ThreadId) then
        Result := Processes[I];
end;

procedure TSSession.PushBuildEvents();
begin
  Databases.PushBuildEvent(Self);
  if (Assigned(Users)) then
    Users.PushBuildEvent(Self);
  Variables.PushBuildEvent(Self);
end;

procedure TSSession.RegisterEventProc(const AEventProc: TEventProc);
var
  I: Integer;
  Index: Integer;
begin
  Index := -1;
  for I := 0 to EventProcs.Count - 1 do
    if (CompareMem(@TMethod(EventProcs.List[I]), @TMethod(AEventProc), SizeOf(TEventProc))) then
      Index := I;

  if (Index < 0) then
    EventProcs.Add(AEventProc);
end;

procedure TSSession.SendEvent(const EventType: TSSession.TEvent.TEventType; const Sender: TObject = nil; const Items: TSItems = nil; const Item: TSItem = nil);
var
  Event: TEvent;
  Profile: TProfile;
begin
  Event := TEvent.Create(Self);
  Event.EventType := EventType;
  Event.Sender := Sender;
  Event.Items := Items;
  Event.Item := Item;
  CreateProfile(Profile);
  DoSendEvent(Event);
  if (ProfilingTime(Profile) >= 10000) then
    SendToDeveloper('EventType: ' + Ord(EventType).ToString() + #13#10
      + ProfilingReport(Profile));
  CloseProfile(Profile);
  Event.Free();
end;

function TSSession.SendSQL(const SQL: string; const OnResult: TMySQLConnection.TResultEvent = nil): Boolean;
begin
  // Debug 2017-03-10
  Assert(Assigned(Connection));

  if (GetCurrentThreadId() = MainThreadId) then
    Result := Connection.SendSQL(SQL, OnResult)
  else
  begin
    Connection.BeginSynchron(11);
    Result := Connection.SendSQL(SQL, OnResult);
    Connection.EndSynchron(11);
  end;
end;

function TSSession.SessionResult(const ErrorCode: Integer; const ErrorMessage: string; const WarningCount: Integer;
  const CommandText: string; const DataHandle: TMySQLConnection.TDataHandle; const Data: Boolean): Boolean;

  function SQLParseColumnNames(var Handle: TSQLParse): Boolean;
  var
    ColumnName: string;
    TempHandle: TSQLParse;
  begin
    TempHandle := Handle;

    repeat
      ColumnName := SQLParseValue(Handle);
    until (SQLParseEnd(Handle) or not SQLParseChar(Handle, ','));
    Result := (ColumnName <> '') and (ColumnName <> 'FROM');

    Result := Result and not SQLParseChar(Handle, '(');
    if (not Result) then
      Handle := TempHandle;
  end;

var
  Database: TSDatabase;
  DatabaseName: string;
  DataSet: TMySQLQuery;
  DBObject: TSDBObject;
  Distinct: Boolean;
  Field: Integer;
  FunctionName: string;
  ObjectName: string;
  Parse: TSQLParse;
  SysDate: TDateTime;
  Table: TSTable;
begin
  Result := False;

  DataSet := TMySQLQuery.Create(nil);


  if (SQLCreateParse(Parse, PChar(CommandText), Length(CommandText), Connection.MySQLVersion)) then
    if (SQLParseKeyword(Parse, 'SELECT')) then
    begin
      DatabaseName := Connection.DatabaseName;
      Distinct := SQLParseKeyword(Parse, 'DISTINCT');
      if (FCurrentUser = '') then
      begin
        DataSet.Open(DataHandle);
        Field := 0;
        if (not DataSet.IsEmpty) then
          repeat
            FunctionName := SQLParseValue(Parse);
            if (SQLParseChar(Parse, '(', False)) then
              FunctionName := FunctionName + SQLParseValue(Parse);
            if (StrIComp(PChar(FunctionName), 'CURRENT_USER()') = 0) then
              FCurrentUser := DataSet.Fields[Field].AsString
            else if (StrIComp(PChar(FunctionName), 'SYSDATE()') = 0) then
            begin
              if (TryStrToDateTime(DataSet.Fields[Field].AsString, SysDate, FormatSettings)) then
                Connection.TimeDiff := SysDate - Now();
            end
            else if (StrIComp(PChar(FunctionName), 'USER()') = 0) then
              FCurrentUser := DataSet.Fields[Field].AsString;
            Inc(Field);
          until (not SQLParseChar(Parse, ','));
      end
      else if (SQLParseColumnNames(Parse) and SQLParseKeyword(Parse, 'FROM') and SQLParseObjectName(Parse, DatabaseName, ObjectName)) then
      begin
        if (Databases.NameCmp(DatabaseName, INFORMATION_SCHEMA) = 0) then
        begin
          DataSet.Open(DataHandle);
          if (TableNameCmp(ObjectName, 'CHARACTER_SETS') = 0) then
            Result := Charsets.Build(DataSet, True, not SQLParseEnd(Parse))
          else if (TableNameCmp(ObjectName, 'COLLATIONS') = 0) then
            Result := Collations.Build(DataSet, True, not SQLParseEnd(Parse))
          else if ((TableNameCmp(ObjectName, 'COLUMNS') = 0) and SQLParseKeyword(Parse, 'WHERE') and (StrIComp(PChar(SQLParseValue(Parse)), 'TABLE_SCHEMA') = 0) and SQLParseChar(Parse, '=')) then
            if (not Distinct) then
              Result := DatabaseByName(SQLParseValue(Parse)).Tables.BuildFields(DataSet, True)
            else
              Result := DatabaseByName(SQLParseValue(Parse)).Columns.Build(DataSet, True)
          else if (TableNameCmp(ObjectName, 'ENGINES') = 0) then
            Result := Engines.Build(DataSet, True, not SQLParseEnd(Parse))
          else if ((TableNameCmp(ObjectName, 'EVENTS') = 0) and (SQLParseKeyword(Parse, 'ORDER') or SQLParseEnd(Parse))) then
            Result := BuildEvents(DataSet)
          else if ((TableNameCmp(ObjectName, 'EVENTS') = 0) and SQLParseKeyword(Parse, 'WHERE') and (StrIComp(PChar(SQLParseValue(Parse)), 'EVENT_SCHEMA') = 0) and SQLParseChar(Parse, '=')) then
          begin
            Database := DatabaseByName(SQLParseValue(Parse));
            Result := Database.Events.Build(DataSet, True, not SQLParseEnd(Parse));
          end
          else if (TableNameCmp(ObjectName, 'PLUGINS') = 0) then
            Result := Plugins.Build(DataSet, True, not SQLParseEnd(Parse))
          else if (TableNameCmp(ObjectName, 'PROCESSLIST') = 0) then
            Result := Processes.Build(DataSet, True, not SQLParseEnd(Parse))
          else if ((TableNameCmp(ObjectName, 'REFERENTIAL_CONSTRAINTS') = 0)
            and SQLParseKeyword(Parse, 'WHERE')
            and (StrIComp(PChar(SQLParseValue(Parse)), 'UNIQUE_CONSTRAINT_SCHEMA') = 0)
            and SQLParseChar(Parse, '=')) then
          begin
            Database := DatabaseByName(SQLParseValue(Parse));
            if (Assigned(Database) and SQLParseKeyword(Parse, 'AND') and (StrIComp(PChar(SQLParseValue(Parse)), 'REFERENCED_TABLE_NAME') = 0) and SQLParseChar(Parse, '=')) then
            begin
              Table := Database.TableByName(SQLParseValue(Parse));
              if (Assigned(Table)) then
                Result := Table.DependenciesSearch.BuildBaseTableReferences(DataSet);
            end;
          end
          else if ((TableNameCmp(ObjectName, 'ROUTINES') = 0) and (SQLParseKeyword(Parse, 'ORDER') or SQLParseEnd(Parse))) then
            Result := BuildRoutines(DataSet)
          else if ((TableNameCmp(ObjectName, 'ROUTINES') = 0) and SQLParseKeyword(Parse, 'WHERE') and (StrIComp(PChar(SQLParseValue(Parse)), 'ROUTINE_SCHEMA') = 0) and SQLParseChar(Parse, '=')) then
          begin
            Database := DatabaseByName(SQLParseValue(Parse));
            Result := Database.Routines.Build(DataSet, True, not SQLParseEnd(Parse));
          end
          else if (TableNameCmp(ObjectName, 'SESSION_VARIABLES') = 0) then
            Result := Variables.Build(DataSet, True, not SQLParseEnd(Parse))
          else if (TableNameCmp(ObjectName, 'SCHEMATA') = 0) then
            Result := Databases.Build(DataSet, True, not SQLParseEnd(Parse))
          else if ((TableNameCmp(ObjectName, 'TABLES') = 0) and (SQLParseKeyword(Parse, 'ORDER') or SQLParseEnd(Parse))) then
            Result := BuildTables(DataSet)
          else if ((TableNameCmp(ObjectName, 'TABLES') = 0) and SQLParseKeyword(Parse, 'WHERE') and (StrIComp(PChar(SQLParseValue(Parse)), 'TABLE_SCHEMA') = 0) and SQLParseChar(Parse, '=')) then
          begin
            Database := DatabaseByName(SQLParseValue(Parse));
            Result := Database.Tables.Build(DataSet, True, SQLParseKeyword(Parse, 'AND') and SQLParseValue(Parse, 'TABLE_NAME'));
          end
          else if ((TableNameCmp(ObjectName, 'TRIGGERS') = 0) and (SQLParseKeyword(Parse, 'ORDER') or SQLParseEnd(Parse))) then
            Result := BuildTriggers(DataSet)
          else if ((TableNameCmp(ObjectName, 'TRIGGERS') = 0) and SQLParseKeyword(Parse, 'WHERE') and (StrIComp(PChar(SQLParseValue(Parse)), 'EVENT_OBJECT_SCHEMA') = 0) and SQLParseChar(Parse, '=')) then
          begin
            Database := DatabaseByName(SQLParseValue(Parse));
            Result := Database.Triggers.Build(DataSet, True, not SQLParseEnd(Parse));
          end
          else if ((TableNameCmp(ObjectName, 'USER_PRIVILEGES') = 0)) then
            Result := Users.Build(DataSet, True, not SQLParseKeyword(Parse, 'GROUP BY') and not SQLParseEnd(Parse))
          else
            raise EConvertError.CreateFmt(SUnknownSQLStmt, [CommandText]);
        end
        else if (Databases.NameCmp(DatabaseName, PERFORMANCE_SCHEMA) = 0) then
        begin
          DataSet.Open(DataHandle);
          if (TableNameCmp(ObjectName, 'SESSION_VARIABLES') = 0) then
            Result := Variables.Build(DataSet, True, not SQLParseEnd(Parse));
        end
        else if (Databases.NameCmp(DatabaseName, 'mysql') = 0) then
        begin
          DataSet.Open(DataHandle);
          if (TableNameCmp(ObjectName, 'user') = 0) then
            Result := Users.Build(DataSet, False, not SQLParseEnd(Parse));
        end;
      end;
    end
    else if (SQLParseKeyword(Parse, 'SHOW')) then
    begin
      DataSet.Open(DataHandle);
      DatabaseName := DataSet.DatabaseName;
      if (SQLParseKeyword(Parse, 'CHARACTER SET')) then
        Result := Charsets.Build(DataSet, False, not SQLParseEnd(Parse))
      else if (SQLParseKeyword(Parse, 'COLLATION')) then
        Result := Collations.Build(DataSet, False, not SQLParseEnd(Parse))
      else if (SQLParseKeyword(Parse, 'CREATE')) then
      begin
        if (not DataSet.Active) then
        begin
          DBObject := nil;
          if (SQLParseKeyword(Parse, 'DATABASE')) then
            DatabaseByName(SQLParseValue(Parse)).FValidSource := True
          else if (SQLParseKeyword(Parse, 'EVENT')) then
            begin if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then DBObject := DatabaseByName(DatabaseName).EventByName(ObjectName); end
          else if (SQLParseKeyword(Parse, 'FUNCTION')) then
            begin if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then DBObject := DatabaseByName(DatabaseName).FunctionByName(ObjectName); end
          else if (SQLParseKeyword(Parse, 'PROCEDURE')) then
            begin if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then DBObject := DatabaseByName(DatabaseName).ProcedureByName(ObjectName); end
          else if (SQLParseKeyword(Parse, 'TABLE')) then
            begin if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then DBObject := DatabaseByName(DatabaseName).TableByName(ObjectName); end
          else if (SQLParseKeyword(Parse, 'TRIGGER')) then
            begin if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then DBObject := DatabaseByName(DatabaseName).TriggerByName(ObjectName); end
          else if (SQLParseKeyword(Parse, 'VIEW')) then
          begin
            if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then DBObject := DatabaseByName(DatabaseName).TableByName(ObjectName);
            Result := Connection.ErrorCode = ER_TABLEACCESS_DENIED_ERROR;
          end;
          if (Assigned(DBObject)) then
            DBObject.FValidSource := True;
        end
        else
        begin
          if (SQLParseKeyword(Parse, 'DATABASE')) then
            DatabaseByName(SQLParseValue(Parse)).Build(DataSet)
          else if (SQLParseKeyword(Parse, 'EVENT')) then
            begin if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then DatabaseByName(DatabaseName).EventByName(ObjectName).Build(DataSet); end
          else if (SQLParseKeyword(Parse, 'FUNCTION')) then
            begin if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then DatabaseByName(DatabaseName).FunctionByName(ObjectName).Build(DataSet); end
          else if (SQLParseKeyword(Parse, 'PROCEDURE')) then
            begin if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then DatabaseByName(DatabaseName).ProcedureByName(ObjectName).Build(DataSet); end
          else if (SQLParseKeyword(Parse, 'TABLE')) then
            begin if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then DatabaseByName(DatabaseName).TableByName(ObjectName).Build(DataSet); end
          else if (SQLParseKeyword(Parse, 'TRIGGER')) then
            begin if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then DatabaseByName(DatabaseName).TriggerByName(ObjectName).Build(DataSet); end
          else if (SQLParseKeyword(Parse, 'VIEW')) then
            begin if (SQLParseObjectName(Parse, DatabaseName, ObjectName)) then DatabaseByName(DatabaseName).TableByName(ObjectName).Build(DataSet); end;
        end;
      end
      else if (SQLParseKeyword(Parse, 'DATABASES')) then
        Result := Databases.Build(DataSet, False, not SQLParseEnd(Parse))
      else if (SQLParseKeyword(Parse, 'ENGINES')) then
        Result := Engines.Build(DataSet, False, not SQLParseEnd(Parse))
      else if (SQLParseKeyword(Parse, 'EVENTS')) then
      begin
        if (not SQLParseKeyword(Parse, 'FROM') or SQLParseKeyword(Parse, 'IN')) then
          DatabaseName := Connection.DatabaseName
        else
          DatabaseName := SQLParseValue(Parse);
        Result := DatabaseByName(DatabaseName).Events.Build(DataSet, False, not SQLParseEnd(Parse));
      end
      else if (SQLParseKeyword(Parse, 'GRANTS FOR')) then
      begin
        if (not FUserRequested and (ErrorCode <> ER_OPTION_PREVENTS_STATEMENT)) then
        begin
          if (not Assigned(FUsers)) then FUsers := TSUsers.Create(Self);
          SendEvent(etItemsValid, Self, Users);
        end;
        if (not DataSet.Active) then
        begin
          FUserRequested := True;
          Result := (ErrorCode = ER_NONEXISTING_GRANT) // There is no such grant defined for user
            or (ErrorCode = ER_OPTION_PREVENTS_STATEMENT) // The MySQL server is running with the --skip-grant-tables option
        end
        else if (SQLParseKeyword(Parse, 'CURRENT_USER')) then
          Result := BuildUser(DataSet)
        else
        begin
          ObjectName := SQLParseValue(Parse);
          if (not Assigned(User) and (Users.NameCmp(ObjectName, FCurrentUser) = 0)) then
            Result := BuildUser(DataSet)
          else if (Assigned(UserByName(ObjectName))) then
            Result := UserByName(ObjectName).Build(DataSet)
          else
            Users.Invalidate();
        end;
      end
      else if (SQLParseKeyword(Parse, 'PLUGINS')) then
        Result := Plugins.Build(DataSet, False, not SQLParseEnd(Parse))
      else if (SQLParseKeyword(Parse, 'PROCEDURE STATUS')
        or SQLParseKeyword(Parse, 'FUNCTION STATUS')) then
      begin
        if (not SQLParseKeyword(Parse, 'WHERE') or not SQLParseKeyword(Parse, 'DB') or not SQLParseChar(Parse, '=')) then
          DatabaseName := Connection.DatabaseName
        else
          DatabaseName := SQLParseValue(Parse);
        Result := DatabaseByName(DatabaseName).Routines.Build(DataSet, False, not SQLParseEnd(Parse));
      end
      else if (SQLParseKeyword(Parse, 'FULL PROCESSLIST')
        or SQLParseKeyword(Parse, 'PROCESSLIST')) then
        Result := Processes.Build(DataSet, False, not SQLParseEnd(Parse))
      else if (SQLParseKeyword(Parse, 'VARIABLES')
        or SQLParseKeyword(Parse, 'SESSION VARIABLES')) then
        Result := Variables.Build(DataSet, False, not SQLParseEnd(Parse))
      else if (SQLParseKeyword(Parse, 'FULL TABLES')
        or SQLParseKeyword(Parse, 'OPEN TABLES')
        or SQLParseKeyword(Parse, 'TABLES')) then
      begin
        if (not SQLParseKeyword(Parse, 'FROM') or SQLParseKeyword(Parse, 'IN')) then
          DatabaseName := Connection.DatabaseName
        else
          DatabaseName := SQLParseValue(Parse);
        Result := DatabaseByName(DatabaseName).Tables.Build(DataSet, False, not SQLParseEnd(Parse));
      end
      else if (SQLParseKeyword(Parse, 'TABLE STATUS')) then
      begin
        if (not SQLParseKeyword(Parse, 'FROM') or SQLParseKeyword(Parse, 'IN')) then
          DatabaseName := Connection.DatabaseName
        else
          DatabaseName := SQLParseValue(Parse);
        Result := DatabaseByName(DatabaseName).Tables.Build(DataSet, False, not SQLParseEnd(Parse));
      end
      else if (SQLParseKeyword(Parse, 'TRIGGERS')) then
      begin
        if (not SQLParseKeyword(Parse, 'FROM') or SQLParseKeyword(Parse, 'IN')) then
          DatabaseName := Connection.DatabaseName
        else
          DatabaseName := SQLParseValue(Parse);
        Result := DatabaseByName(DatabaseName).Triggers.Build(DataSet, False, not SQLParseEnd(Parse));
      end
      else
        raise EConvertError.CreateFmt(SUnknownSQLStmt, [CommandText]);
    end
    else if (SQLParseKeyword(Parse, 'HELP')) then
    begin
      DataSet.Open(DataHandle);
      BuildManualURL(DataSet);
      Account.ManualURLVersion := Connection.ServerVersionStr;
      Result := True; // If the HELP query fails, the users does not be informed
    end
    else if (SQLParseKeyword(Parse, 'OPTIMIZE')) then
    begin
      DataSet.Open(DataHandle);
      if (not DataSet.IsEmpty) then
        repeat
          ObjectName := DataSet.FieldByName('Table').AsString;
          if (Pos('.', ObjectName) = 0) then
            DatabaseName := Connection.DatabaseName
          else
          begin
            DatabaseName := Copy(ObjectName, 1, Pos('.', ObjectName) - 1);
            Delete(ObjectName, 1, Pos('.', ObjectName));
          end;
          Database := DatabaseByName(DatabaseName);
          if (Assigned(Database)) then
          begin
            Table := Database.TableByName(ObjectName);
            if (Table is TSBaseTable) then
              TSBaseTable(Table).InvalidateStatus();
          end;
        until (not DataSet.FindNext());
    end;

  DataSet.Free();
end;

procedure TSSession.SetCreateDesktop(ACreateDesktop: TCreateDesktop);
var
  I: Integer;
begin
  if (Assigned(FCreateDesktop) and not Assigned(ACreateDesktop)) then
    for I := 0 to Databases.Count - 1 do
      Databases[I].FreeDesktop();

  FCreateDesktop := ACreateDesktop;
end;

procedure TSSession.SortDBObjects(const List: TList; const Asc: Boolean = True);
var
  CycleProtection: Integer;
  I: Integer;
  J: Integer;
  K: Integer;
begin
  Connection.BeginSynchron(12);
  Update(List); // We need the sources for the dependencies
  Connection.EndSynchron(12);

  List.Sort(Compare);

  I := 0; CycleProtection := List.Count * List.Count;
  while ((I < List.Count) and (CycleProtection >= 0)) do
  begin
    if (TObject(List[I]) is TSDBObject) then
      for J := 0 to TSDBObject(List[I]).References.Count - 1 do
        for K := I - 1 downto 0 do
          if ((TObject(List[K]) is TSDBObject)
            and (TSDBObject(List[K]) = TSDBObject(List[I]).References[J].DBObject)) then
          begin
            List.Move(K, I);
            Dec(I);
          end;

    Inc(I);
    Dec(CycleProtection);
  end;

  if (not Asc and (List.Count > 1)) then
    for I := List.Count - 2 to 0 do
      List.Move(I, List.Count - 1);
end;

function TSSession.TableName(const Name: string): string;
begin
  if (LowerCaseTableNames = 0) then
    Result := Name
  else
    Result := LowerCase(Name);
end;

function TSSession.TableNameCmp(const Name1, Name2: string): Integer;
begin
  if (LowerCaseTableNames = 0) then
    Result := lstrcmp(PChar(Name1), PChar(Name2))
  else
    Result := lstrcmpi(PChar(Name1), PChar(Name2));
end;

function TSSession.UnescapeValue(const Value: string; const FieldType: TSField.TFieldType = mfVarChar): string;
begin
  Result := SQLUnescape(Value);

  if (FieldType in [mfFloat, mfDouble, mfDecimal]) then
    Result := ReplaceStr(Result, '.', FormatSettings.DecimalSeparator)
  else
    Result := SQLUnescape(Value);
end;

function TSSession.UnecapeRightIdentifier(const Identifier: string): string;
var
  DBIdentifier: string;
begin
  DBIdentifier := UnescapeValue(Identifier);

  if (DBIdentifier = '%') then Result := '' else Result := DBIdentifier;
end;

procedure TSSession.UnRegisterEventProc(const AEventProc: TEventProc);
var
  I: Integer;
  Index: Integer;
begin
  Index := -1;
  for I := 0 to EventProcs.Count - 1 do
    if (CompareMem(@TMethod(EventProcs.List[I]), @TMethod(AEventProc), SizeOf(TEventProc))) then
      Index := I;

  if (Index >= 0) then
    EventProcs.Delete(Index);
end;

function TSSession.Update(): Boolean;
var
  List: TList;
begin
  List := TList.Create();
  Result := Update(List);
  List.Free();
end;

function TSSession.Update(const Objects: TList; const Status: Boolean = False): Boolean;
var
  BaseTableInTables: Boolean;
  Database: TSDatabase;
  I: Integer;
  List: TList;
  SQL: string;
  Tables: TList;
begin
  // Debug 2017-05-04
  Assert(Assigned(Connection));
  Assert(not InImport or (GetCurrentThreadId() <> MainThreadID));

  SQL := '';

  if (FCurrentUser = '') then
    if (Connection.MySQLVersion < 40006) then
      SQL := SQL + 'SELECT SYSDATE(),USER();' + #13#10
    else
      SQL := SQL + 'SELECT SYSDATE(),CURRENT_USER();' + #13#10;

  if (not Assigned(FUser) and not FUserRequested)  then
    if (Connection.MySQLVersion >= 40102) then
      SQL := SQL + 'SHOW GRANTS FOR CURRENT_USER();' + #13#10
    else if (FCurrentUser <> '') then
      SQL := SQL + 'SHOW GRANTS FOR ' + EscapeUser(FCurrentUser) + ';' + #13#10;

  if ((Connection.MySQLVersion > 40100) and Assigned(Account) and (Account.ManualURLVersion <> Connection.ServerVersionStr)) then
  begin
    SQL := SQL + 'HELP ' + SQLEscape('SELECT') + ';' + #13#10;
    SQL := SQL + 'HELP ' + SQLEscape('VERSION') + ';' + #13#10;
  end;

  List := TList.Create();

  if (Assigned(Variables) and not Variables.Valid) then List.Add(Variables);
  if (Assigned(Engines) and not Engines.Valid) then List.Add(Engines);
  if (Assigned(Charsets) and not Charsets.Valid) then List.Add(Charsets);
  if (Assigned(Collations) and not Collations.Valid) then List.Add(Collations);
  if (Assigned(Users) and not Users.Valid) then List.Add(Users);
  if (Assigned(Databases) and not Databases.Valid) then List.Add(Databases);

  if (Assigned(Objects)) then
    List.Assign(Objects, laOr);
  List.Sort(Compare);

  Tables := TList.Create();
  BaseTableInTables := False;

  Database := nil;
  for I := 0 to List.Count - 1 do
    if ((TObject(List[I]) is TSEntities) and not TSEntities(List[I]).Valid) then
      SQL := SQL + TSEntities(List[I]).SQLGetItems()
    else if (TObject(List[I]) is TSDatabase) then
    begin
      Database := TSDatabase(List[I]);
      if (not Database.ValidSource and not (TObject(List[I]) is TSSystemDatabase)) then
        SQL := SQL + Database.SQLGetSource();
      if (not Database.Tables.Valid) then
        SQL := SQL + Database.Tables.SQLGetItems();
      if (Assigned(Database.Routines) and not Database.Routines.Valid) then
        SQL := SQL + Database.Routines.SQLGetItems();
      if (Assigned(Database.Triggers) and not Database.Triggers.Valid) then
        SQL := SQL + Database.Triggers.SQLGetItems();
      if (Assigned(Database.Events) and not Database.Events.Valid) then
        SQL := SQL + Database.Events.SQLGetItems();
    end
    else if (TObject(List[I]) is TSDBObject) then
    begin
      if (Assigned(Database) and (TSDBObject(List[I]).Database <> Database)) then
        if (Tables.Count > 0) then
        begin
          if (BaseTableInTables and Status and not Database.Tables.ValidStatus) then
            SQL := SQL + Database.Tables.SQLGetStatus(Tables);
          Tables.Clear();
          BaseTableInTables := False;
        end;
      Database := TSDBObject(List[I]).Database;

      if (not TSDBObject(List[I]).ValidSource) then
        SQL := SQL + TSDBObject(List[I]).SQLGetSource();
      if ((TSDBObject(List[I]) is TSBaseTable) and not TSBaseTable(List[I]).ValidStatus) then
        Tables.Add(List[I])
      else if (((TSObject(List[I]) is TSView) or (TSObject(List[I]) is TSSystemView)) and not TSView(List[I]).ValidFields) then
        Tables.Add(List[I]);
      BaseTableInTables := BaseTableInTables or (TSObject(List[I]) is TSBaseTable);
    end
    else if ((TObject(List[I]) is TSUser) and not TSUser(List[I]).Valid) then
      SQL := SQL + TSUser(List[I]).SQLGetSource()
    else if ((TObject(List[I]) is TSDependenciesSearch) and not TSDependenciesSearch(List[I]).Valid) then
      SQL := SQL + TSDependenciesSearch(List[I]).SQLGetReferences;
  if (Tables.Count > 0) then
  begin
    if (BaseTableInTables and Status and not Database.Tables.ValidStatus) then
      SQL := SQL + Database.Tables.SQLGetStatus(Tables);
    Tables.Clear();
  end;

  if (Status) then
    for I := 0 to List.Count - 1 do
      if (TObject(List[I]) is TSDatabase) then
      begin
        if (not TSDatabase(List[I]).Tables.ValidStatus and not (TSDatabase(List[I]) is TSSystemDatabase)) then
          SQL := SQL + TSDatabase(List[I]).Tables.SQLGetStatus();
      end
      else if (TObject(List[I]) is TSTables) then
      begin
        if (not TSTables(List[I]).ValidStatus and not (TSTables(List[I]).Database is TSSystemDatabase)) then
          SQL := SQL + TSTables(List[I]).SQLGetStatus();
      end;

  if (not Assigned(Objects) and Status and not Valid and (Connection.MySQLVersion >= 50002) and (Account.Connection.Database = '')) then
  begin
    SQL := SQL + 'SELECT * FROM ' + Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Connection.EscapeIdentifier('TABLES') + ' ORDER BY ' + Connection.EscapeIdentifier('TABLE_SCHEMA') + ',' + Connection.EscapeIdentifier('TABLE_NAME') + ';' + #13#10;
    if (Connection.MySQLVersion >= 50004) then SQL := SQL + 'SELECT * FROM ' + Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Connection.EscapeIdentifier('ROUTINES') + ' ORDER BY ' + Connection.EscapeIdentifier('ROUTINE_SCHEMA') + ',' + Connection.EscapeIdentifier('ROUTINE_NAME') + ';' + #13#10;
    if (Connection.MySQLVersion >= 50010) then SQL := SQL + 'SELECT * FROM ' + Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Connection.EscapeIdentifier('TRIGGERS') + ' ORDER BY ' + Connection.EscapeIdentifier('TRIGGER_SCHEMA') + ',' + Connection.EscapeIdentifier('TRIGGER_NAME') + ';' + #13#10;
    if (Connection.MySQLVersion >= 50106) then SQL := SQL + 'SELECT * FROM ' + Connection.EscapeIdentifier(INFORMATION_SCHEMA) + '.' + Connection.EscapeIdentifier('EVENTS') + ' ORDER BY ' + Connection.EscapeIdentifier('EVENT_SCHEMA') + ',' + Connection.EscapeIdentifier('EVENT_NAME') + ';' + #13#10;
  end;


  Tables.Free();
  List.Free();

  Result := (SQL = '') or SendSQL(SQL, SessionResult);
end;

function TSSession.UpdateDatabase(const Database, NewDatabase: TSDatabase): Boolean;
var
  SQL: string;
begin
  SQL := '';
  if (Connection.MySQLVersion >= 40101) then
  begin
    if (NewDatabase.Charset <> '') then
      SQL := SQL + ' DEFAULT CHARACTER SET ' + NewDatabase.Charset;
    if (NewDatabase.Collation <> '') then
      SQL := SQL + ' COLLATE ' + NewDatabase.Collation;
  end;

  if (not Assigned(Database)) then
    SQL := 'CREATE DATABASE ' + Connection.EscapeIdentifier(NewDatabase.Name) + SQL + ';' + #13#10
  else if (SQL <> '') then
    if (Connection.MySQLVersion < 40108) then
    begin
      SQL := 'ALTER DATABASE ' + SQL + ';' + #13#10;
      if (Connection.DatabaseName <> Database.Name) then
        SQL := Database.SQLUse() + SQL;
    end
    else
      SQL := 'ALTER DATABASE ' + Connection.EscapeIdentifier(Database.Name) + SQL + ';' + #13#10;

  SQL := SQL
    + NewDatabase.SQLGetSource();

  Result := (SQL = '') or SendSQL(SQL, SessionResult);
end;

procedure TSSession.UpdateIndexDefs(const DataSet: TMySQLQuery; const IndexDefs: TIndexDefs);
var
  Database: TSDatabase;
  Field: TSBaseField;
  FieldInfo: TFieldInfo;
  Found: Boolean;
  I: Integer;
  IndexDef: TIndexDef;
  J: Integer;
  K: Integer;
  OriginalDatabaseName: string;
  OriginalTableName: string;
  Table: TSBaseTable;
  UniqueTable: Boolean;
begin
  if (DataSet is TSTable.TDataSet) then
  begin
    OriginalDatabaseName := DataSet.DatabaseName;
    OriginalTableName := DataSet.CommandText;
  end
  else if (Assigned(DataSet)) then
  begin
    OriginalTableName := ''; UniqueTable := True;
    for I := 0 to DataSet.FieldCount - 1 do
      if (GetFieldInfo(DataSet.Fields[I].Origin, FieldInfo) and (FieldInfo.DatabaseName <> '') and (FieldInfo.TableName <> '')) then
      begin
        if (OriginalDatabaseName = '') then
          OriginalDatabaseName := FieldInfo.DatabaseName
        else
          UniqueTable := UniqueTable and (Databases.NameCmp(FieldInfo.DatabaseName, OriginalDatabaseName) = 0);
        if (OriginalTableName = '') then
          OriginalTableName := FieldInfo.TableName
        else
          UniqueTable := UniqueTable and (TableNameCmp(FieldInfo.TableName, OriginalTableName) = 0);
      end;
    if (not UniqueTable) then
    begin
      OriginalDatabaseName := '';
      OriginalTableName := '';
    end;
  end;

  if (Assigned(DataSet)) then
  begin
    IndexDefs.Clear();

    Connection.BeginSynchron(13);
    Databases.Update();
    Connection.EndSynchron(13);

    Database := DatabaseByName(OriginalDatabaseName);
    if (Assigned(Database)) then
    begin
      Connection.BeginSynchron(14);
      Database.Tables.Update();
      Connection.EndSynchron(14);

      Table := Database.BaseTableByName(OriginalTableName);
      if (Assigned(Table)) then
      begin
        Connection.BeginSynchron(15);
        Table.Update();
        Connection.EndSynchron(15);

        if (Table.Keys.Count > 0) then
          for I := 0 to Table.Keys.Count - 1 do
          begin
            Found := True;
            for J := 0 to Table.Keys[I].Columns.Count - 1 do
              if (Found) then
              begin
                Found := False;
                for K := 0 to DataSet.FieldCount - 1 do
                  if (GetFieldInfo(DataSet.Fields[K].Origin, FieldInfo)) then
                    Found := Found or (FieldInfo.OriginalFieldName = Table.Keys[I].Columns[J].Field.Name);
              end;
            if (Found) then
            begin
              IndexDef := IndexDefs.AddIndexDef();
              IndexDef.Name := Table.Keys[I].Name;
              if (Table.Keys[I].PrimaryKey) then
                IndexDef.Options := [ixPrimary, ixUnique]
              else if (Table.Keys[I].Unique) then
                IndexDef.Options := [ixUnique];
              for J := 0 to Table.Keys[I].Columns.Count - 1 do
              begin
                if (IndexDef.Fields <> '') then IndexDef.Fields := IndexDef.Fields + ';';
                for K := 0 to DataSet.FieldCount - 1 do
                  if (GetFieldInfo(DataSet.Fields[K].Origin, FieldInfo) and (FieldInfo.OriginalFieldName = Table.Keys[I].Columns[J].Field.Name)) then
                  begin
                    IndexDef.Fields := IndexDef.Fields + DataSet.Fields[K].FieldName;
                    if (not Table.Keys[I].Columns[J].Ascending) then
                    begin
                      if (IndexDef.DescFields <> '') then IndexDef.DescFields := IndexDef.DescFields + ';';
                      IndexDef.Fields := IndexDef.Fields + DataSet.Fields[K].FieldName;
                    end;
                  end;
              end;
            end;
          end;
        end;
    end;
  end;

  Connection.BeginSynchron(16);
  for I := 0 to DataSet.FieldCount - 1 do
    if (GetFieldInfo(DataSet.Fields[I].Origin, FieldInfo)) then
    begin
      if (FieldInfo.DatabaseName = '') then
        Database := DatabaseByName(DataSet.DatabaseName)
      else
        Database := DatabaseByName(FieldInfo.DatabaseName);
      if (Assigned(Database) and Database.Update()) then
      begin
        Table := Database.BaseTableByName(FieldInfo.TableName);
        if (Assigned(Table) and Table.Update()) then
        begin
          Field := Table.FieldByName(FieldInfo.OriginalFieldName);
          if (Assigned(Field) and not Field.AutoIncrement and (Field.Default <> 'NULL') and (StrLIComp(PChar(Field.Default), 'CURRENT_TIMESTAMP', 17) <> 0)) then
            DataSet.Fields[I].DefaultExpression := Field.UnescapeValue(Field.Default);
          DataSet.Fields[I].ReadOnly := DataSet.Fields[I].ReadOnly or Assigned(Field) and (Field.FieldKind = mkVirtual);
        end;
      end;
    end;
  Connection.EndSynchron(16);
end;

function TSSession.UpdateUser(const User, NewUser: TSUser): Boolean;
type
  TRightType = (rtAll, rtDatabase, rtTable, rtRoutine, rtField);

  function GetRightType(const Right: TSUserRight): TRightType;
  begin
    if (Right.FieldName <> '') then
      Result := rtField
    else if ((Right.FunctionName <> '') or (Right.ProcedureName <> '')) then
      Result := rtRoutine
    else if (Right.TableName <> '') then
      Result := rtTable
    else if (Right.DatabaseName <> '') then
      Result := rtDatabase
    else
      Result := rtAll;
  end;

  function GetPrivileges(const Grant: Boolean; const OldRight, NewRight: TSUserRight; const RightType: TRightType): string;
  begin
    Result := '';

    if ((not Grant xor NewRight.RAlter          ) and (Grant xor (Assigned(OldRight) and OldRight.RAlter          )) and (RightType in [rtAll, rtDatabase])                                                  ) then       Result := Result + ',ALTER';
    if ((not Grant xor NewRight.RAlterRoutine   ) and (Grant xor (Assigned(OldRight) and OldRight.RAlterRoutine   )) and (RightType in [rtAll, rtDatabase, rtRoutine]) and (Connection.MySQLVersion >= 50003)) then       Result := Result + ',ALTER ROUTINE';
    if ((not Grant xor NewRight.RCreate         ) and (Grant xor (Assigned(OldRight) and OldRight.RCreate         )) and (RightType in [rtAll, rtDatabase])                                                  ) then       Result := Result + ',CREATE';
    if ((not Grant xor NewRight.RCreateRoutine  ) and (Grant xor (Assigned(OldRight) and OldRight.RCreateRoutine  )) and (RightType in [rtAll, rtDatabase])            and (Connection.MySQLVersion >= 50003)) then       Result := Result + ',CREATE ROUTINE';
    if ((not Grant xor NewRight.RCreateTableSpace)and (Grant xor (Assigned(OldRight) and OldRight.RCreateTableSpace))and (RightType in [rtAll])                        and (Connection.MySQLVersion >= 50500)) then       Result := Result + ',CREATE TABLESPACE';
    if ((not Grant xor NewRight.RCreateTempTable) and (Grant xor (Assigned(OldRight) and OldRight.RCreateTempTable)) and (RightType in [rtAll, rtDatabase])            and (Connection.MySQLVersion >= 40002)) then       Result := Result + ',CREATE TEMPORARY TABLES';
    if ((not Grant xor NewRight.RCreateUser     ) and (Grant xor (Assigned(OldRight) and OldRight.RCreateUser     )) and (RightType in [rtAll, rtDatabase])            and (Connection.MySQLVersion >= 50003)) then       Result := Result + ',CREATE USER';
    if ((not Grant xor NewRight.RCreateView     ) and (Grant xor (Assigned(OldRight) and OldRight.RCreateView     )) and (RightType in [rtAll, rtDatabase])            and (Connection.MySQLVersion >= 50001)) then       Result := Result + ',CREATE VIEW';
    if ((not Grant xor NewRight.RDelete         ) and (Grant xor (Assigned(OldRight) and OldRight.RDelete         )) and (RightType in [rtAll, rtDatabase, rtTable])                                         ) then       Result := Result + ',DELETE';
    if ((not Grant xor NewRight.RDrop           ) and (Grant xor (Assigned(OldRight) and OldRight.RDrop           )) and (RightType in [rtAll, rtDatabase])                                                  ) then       Result := Result + ',DROP';
    if ((not Grant xor NewRight.REvent          ) and (Grant xor (Assigned(OldRight) and OldRight.REvent          )) and (RightType in [rtAll, rtDatabase])            and (Connection.MySQLVersion >= 50106)) then       Result := Result + ',EVENT';
    if ((not Grant xor NewRight.RExecute        ) and (Grant xor (Assigned(OldRight) and OldRight.RExecute        )) and (RightType in [rtAll, rtDatabase, rtRoutine]) and (Connection.MySQLVersion >= 50003)) then       Result := Result + ',EXECUTE';
    if ((not Grant xor NewRight.RFile           ) and (Grant xor (Assigned(OldRight) and OldRight.RFile           )) and (RightType in [rtAll])                                                              ) then       Result := Result + ',FILE';
    if ((not Grant xor NewRight.RGrant          ) and (Grant xor (Assigned(OldRight) and OldRight.RGrant          )) and (RightType in [rtAll, rtDatabase, rtRoutine])                                       ) then       Result := Result + ',GRANT OPTION';
    if ((not Grant xor NewRight.RIndex          ) and (Grant xor (Assigned(OldRight) and OldRight.RIndex          )) and (RightType in [rtAll, rtDatabase])                                                  ) then       Result := Result + ',INDEX';
    if ((not Grant xor NewRight.RInsert         ) and (Grant xor (Assigned(OldRight) and OldRight.RInsert         ))                                                                                         ) then begin Result := Result + ',INSERT';                  if (not Grant and (OldRight.FieldName <> '')) then Result := Result + '(' + Connection.EscapeIdentifier(OldRight.FieldName) + ')' else if (Grant and (NewRight.FieldName <> '')) then Result := Result + '(' + Connection.EscapeIdentifier(NewRight.FieldName) + ')'; end;
    if ((not Grant xor NewRight.RLockTables     ) and (Grant xor (Assigned(OldRight) and OldRight.RLockTables     )) and (RightType in [rtAll, rtDatabase])            and (Connection.MySQLVersion >= 40002)) then       Result := Result + ',LOCK TABLES';
    if ((not Grant xor NewRight.RProcess        ) and (Grant xor (Assigned(OldRight) and OldRight.RProcess        )) and (RightType in [rtAll])                                                              ) then       Result := Result + ',PROCESS';
    if ((not Grant xor NewRight.RReferences     ) and (Grant xor (Assigned(OldRight) and OldRight.RReferences     ))                                                                                         ) then begin Result := Result + ',REFERENCES';              if (not Grant and (OldRight.FieldName <> '')) then Result := Result + '(' + Connection.EscapeIdentifier(OldRight.FieldName) + ')' else if (Grant and (NewRight.FieldName <> '')) then Result := Result + '(' + Connection.EscapeIdentifier(NewRight.FieldName) + ')'; end;
    if ((not Grant xor NewRight.RReload         ) and (Grant xor (Assigned(OldRight) and OldRight.RReload         )) and (RightType in [rtAll])                                                              ) then       Result := Result + ',RELOAD';
    if ((not Grant xor NewRight.RReplClient     ) and (Grant xor (Assigned(OldRight) and OldRight.RReplClient     )) and (RightType in [rtAll])                        and (Connection.MySQLVersion >= 40002)) then       Result := Result + ',REPLICATION CLIENT';
    if ((not Grant xor NewRight.RReplSlave      ) and (Grant xor (Assigned(OldRight) and OldRight.RReplSlave      )) and (RightType in [rtAll])                        and (Connection.MySQLVersion >= 40002)) then       Result := Result + ',REPLICATION SLAVE';
    if ((not Grant xor NewRight.RSelect         ) and (Grant xor (Assigned(OldRight) and OldRight.RSelect         ))                                                                                         ) then begin Result := Result + ',SELECT';                  if (not Grant and (OldRight.FieldName <> '')) then Result := Result + '(' + Connection.EscapeIdentifier(OldRight.FieldName) + ')' else if (Grant and (NewRight.FieldName <> '')) then Result := Result + '(' + Connection.EscapeIdentifier(NewRight.FieldName) + ')'; end;
    if ((not Grant xor NewRight.RShowDatabases  ) and (Grant xor (Assigned(OldRight) and OldRight.RShowDatabases  )) and (RightType in [rtAll])                        and (Connection.MySQLVersion >= 40002)) then       Result := Result + ',SHOW DATABASES';
    if ((not Grant xor NewRight.RShowView       ) and (Grant xor (Assigned(OldRight) and OldRight.RShowView       )) and (RightType in [rtAll, rtDatabase])            and (Connection.MySQLVersion >= 50001)) then       Result := Result + ',SHOW VIEW';
    if ((not Grant xor NewRight.RShutdown       ) and (Grant xor (Assigned(OldRight) and OldRight.RShutdown       )) and (RightType in [rtAll])                                                              ) then       Result := Result + ',SHUTDOWN';
    if ((not Grant xor NewRight.RSuper          ) and (Grant xor (Assigned(OldRight) and OldRight.RSuper          )) and (RightType in [rtAll])                        and (Connection.MySQLVersion >= 40002)) then       Result := Result + ',SUPER';
    if ((not Grant xor NewRight.RTrigger        ) and (Grant xor (Assigned(OldRight) and OldRight.RTrigger        )) and (RightType in [rtAll, rtDatabase])            and (Connection.MySQLVersion >= 50106)) then       Result := Result + ',TRIGGER';
    if ((not Grant xor NewRight.RUpdate         ) and (Grant xor (Assigned(OldRight) and OldRight.RUpdate         ))                                                                                         ) then begin Result := Result + ',UPDATE';                  if (not Grant and (OldRight.FieldName <> '')) then Result := Result + '(' + Connection.EscapeIdentifier(OldRight.FieldName) + ')' else if (Grant and (NewRight.FieldName <> '')) then Result := Result + '(' + Connection.EscapeIdentifier(NewRight.FieldName) + ')'; end;

    Delete(Result, 1, 1);

    if (Result = '') then
      Result := 'PROXY';
  end;

var
  EmptyRight: TSUserRight;
  I: Integer;
  J: Integer;
  NewRight: TSUserRight;
  OldRight: TSUserRight;
  Options: string;
  Privileges: string;
  RemovedUserRights: array of Boolean;
  SingleSQL: string;
  SQL: string;
begin
  SQL := '';

  if (Assigned(User) and (NewUser.Name <> User.Name)) then
    if (Connection.MySQLVersion < 50002) then
    begin
      SQL := SQL + 'UPDATE ' + Connection.EscapeIdentifier('mysql') + '.' + Connection.EscapeIdentifier('user'        ) + ' SET ' + Connection.EscapeIdentifier('User') + '=' + SQLEscape(NewUser.Login) + ',' + Connection.EscapeIdentifier('Host') + '=' + SQLEscape(NewUser.Host) + ' WHERE ' + Connection.EscapeIdentifier('User') + '=' + SQLEscape(User.Login) + ' AND ' + Connection.EscapeIdentifier('Host') + '=' + SQLEscape(User.Host) + ';' + #13#10;
      SQL := SQL + 'UPDATE ' + Connection.EscapeIdentifier('mysql') + '.' + Connection.EscapeIdentifier('db'          ) + ' SET ' + Connection.EscapeIdentifier('User') + '=' + SQLEscape(NewUser.Login) + ',' + Connection.EscapeIdentifier('Host') + '=' + SQLEscape(NewUser.Host) + ' WHERE ' + Connection.EscapeIdentifier('User') + '=' + SQLEscape(User.Login) + ' AND ' + Connection.EscapeIdentifier('Host') + '=' + SQLEscape(User.Host) + ';' + #13#10;
      SQL := SQL + 'UPDATE ' + Connection.EscapeIdentifier('mysql') + '.' + Connection.EscapeIdentifier('tables_priv' ) + ' SET ' + Connection.EscapeIdentifier('User') + '=' + SQLEscape(NewUser.Login) + ',' + Connection.EscapeIdentifier('Host') + '=' + SQLEscape(NewUser.Host) + ' WHERE ' + Connection.EscapeIdentifier('User') + '=' + SQLEscape(User.Login) + ' AND ' + Connection.EscapeIdentifier('Host') + '=' + SQLEscape(User.Host) + ';' + #13#10;
      SQL := SQL + 'UPDATE ' + Connection.EscapeIdentifier('mysql') + '.' + Connection.EscapeIdentifier('columns_priv') + ' SET ' + Connection.EscapeIdentifier('User') + '=' + SQLEscape(NewUser.Login) + ',' + Connection.EscapeIdentifier('Host') + '=' + SQLEscape(NewUser.Host) + ' WHERE ' + Connection.EscapeIdentifier('User') + '=' + SQLEscape(User.Login) + ' AND ' + Connection.EscapeIdentifier('Host') + '=' + SQLEscape(User.Host) + ';' + #13#10;
    end
    else
      SQL := SQL + 'RENAME USER ' + EscapeUser(User.Name) + ' TO ' + EscapeUser(NewUser.Name) + ';' + #13#10;

  if (not Assigned(User) and (Connection.MySQLVersion > 50002)) then
    SQL := SQL + 'CREATE USER ' + EscapeUser(NewUser.Name) + ';' + #13#10;

  if (not Assigned(User)) then
    SetLength(RemovedUserRights, 0)
  else
  begin
    SetLength(RemovedUserRights, User.RightCount);
    for I := 0 to Length(RemovedUserRights) - 1 do
      RemovedUserRights[I] := False;
  end;

  for I := 0 to NewUser.RightCount - 1 do
  begin
    NewRight := NewUser.Rights[I];

    OldRight := nil;
    if (Assigned(User)) then
      for J := 0 to User.RightCount - 1 do
        if ((Databases.NameCmp(User.Rights[J].DatabaseName , NewRight.DatabaseName ) = 0)
          and (TableNameCmp(User.Rights[J].TableName, NewRight.TableName) = 0)
          and (lstrcmpi(PChar(User.Rights[J].ProcedureName), PChar(NewRight.ProcedureName)) = 0)
          and (lstrcmpi(PChar(User.Rights[J].FunctionName), PChar(NewRight.FunctionName )) = 0)
          and (lstrcmpi(PChar(User.Rights[J].FieldName), PChar(NewRight.FieldName)) = 0)) then
          OldRight := User.Rights[J];

    if (not Assigned(OldRight) or not NewRight.Equals(OldRight)) then
    begin
      Privileges := GetPrivileges(False, OldRight, NewRight, GetRightType(NewRight));

      if ((Privileges <> '') and (Privileges <> 'PROXY')) then
      begin
        if (NewRight.TableName <> '') then
          SingleSQL := 'REVOKE ' + Privileges + ' ON ' + Connection.EscapeIdentifier(NewRight.DatabaseName) + '.' + Connection.EscapeIdentifier(NewRight.TableName)
        else if (NewRight.ProcedureName <> '') then
          SingleSQL := 'REVOKE ' + Privileges + ' ON PROCEDURE ' + Connection.EscapeIdentifier(NewRight.DatabaseName) + '.' + Connection.EscapeIdentifier(NewRight.ProcedureName)
        else if (NewRight.FunctionName <> '') then
          SingleSQL := 'REVOKE ' + Privileges + ' ON FUNCTION ' + Connection.EscapeIdentifier(NewRight.DatabaseName) + '.' + Connection.EscapeIdentifier(NewRight.FunctionName)
        else if (NewRight.DatabaseName <> '') then
          SingleSQL := 'REVOKE ' + Privileges + ' ON ' + Connection.EscapeIdentifier(NewRight.DatabaseName) + '.*'
        else
          SingleSQL := '';
        if (SingleSQL <> '') then
          SQL := SQL + SingleSQL + ' FROM ' + EscapeUser(NewUser.Name) + ';' + #13#10;
      end;

      Privileges := GetPrivileges(True, OldRight, NewRight, GetRightType(NewRight));

      Options := '';
      if (NewRight.RGrant and not (Assigned(OldRight) and OldRight.RGrant)) then Options := Options + ' GRANT OPTION';
      if (NewRight.DatabaseName = '') then
      begin
        if (not Assigned(User) and (NewUser.ConnectionsPerHour > 0) or Assigned(User) and (User.ConnectionsPerHour <> NewUser.ConnectionsPerHour)) then Options := Options + ' MAX_CONNECTIONS_PER_HOUR ' + IntToStr(NewUser.ConnectionsPerHour);
        if (not Assigned(User) and (NewUser.QueriesPerHour     > 0) or Assigned(User) and (User.QueriesPerHour     <> NewUser.QueriesPerHour    )) then Options := Options + ' MAX_QUERIES_PER_HOUR '     + IntToStr(NewUser.QueriesPerHour);
        if (not Assigned(User) and (NewUser.UpdatesPerHour     > 0) or Assigned(User) and (User.UpdatesPerHour     <> NewUser.UpdatesPerHour    )) then Options := Options + ' MAX_UPDATES_PER_HOUR '     + IntToStr(NewUser.UpdatesPerHour);
        if (Connection.MySQLVersion >= 50003) then
          if (not Assigned(User) and (NewUser.UserConnections    > 0) or Assigned(User) and (User.UserConnections    <> NewUser.UserConnections   )) then Options := Options + ' MAX_USER_CONNECTIONS '     + IntToStr(NewUser.UserConnections);
      end;
      Options := Trim(Options);

      if ((Privileges = '') and ((Options <> '') or (not Assigned(User) and (Connection.MySQLVersion <= 50002)))) then
        Privileges := 'USAGE';

      if (Privileges <> '') then
      begin
        if (NewRight.TableName <> '') then
          if (Connection.MySQLVersion < 50006) then
            SingleSQL := 'GRANT ' + Privileges + ' ON ' + Connection.EscapeIdentifier(NewRight.DatabaseName) + '.' + Connection.EscapeIdentifier(NewRight.TableName)
          else
            SingleSQL := 'GRANT ' + Privileges + ' ON TABLE ' + Connection.EscapeIdentifier(NewRight.DatabaseName) + '.' + Connection.EscapeIdentifier(NewRight.TableName)
        else if (NewRight.ProcedureName <> '') then
          SingleSQL := 'GRANT ' + Privileges + ' ON PROCEDURE ' + Connection.EscapeIdentifier(NewRight.DatabaseName) + '.' + Connection.EscapeIdentifier(NewRight.ProcedureName)
        else if (NewRight.FunctionName <> '') then
          SingleSQL := 'GRANT ' + Privileges + ' ON FUNCTION ' + Connection.EscapeIdentifier(NewRight.DatabaseName) + '.' + Connection.EscapeIdentifier(NewRight.FunctionName)
        else if (NewRight.DatabaseName <> '') then
          SingleSQL := 'GRANT ' + Privileges + ' ON ' + Connection.EscapeIdentifier(NewRight.DatabaseName) + '.*'
        else if (Privileges <> 'PROXY') then
          SingleSQL := 'GRANT ' + Privileges + ' ON ' + '*.*'
        else
          SingleSQL := '';
        if (SingleSQL <> '') then
        begin
          SingleSQL := SingleSQL + ' TO ' + EscapeUser(NewUser.Name);
          if (Options <> '') then
            SingleSQL := SingleSQL + ' WITH ' + Options;
          SQL := SQL + SingleSQL + ';' + #13#10;
        end;
      end;
    end;
  end;

  if (not Assigned(User) and (NewUser.NewPassword <> '') or Assigned(User) and (NewUser.NewPassword <> User.RawPassword) and (NewUser.RightCount > 0)) then
    SQL := SQL + 'SET PASSWORD FOR ' + EscapeUser(NewUser.Name) + '=PASSWORD(' + SQLEscape(NewUser.NewPassword) + ');' + #13#10;

  if (SQL <> '') then
    SQL := SQL
      + 'FLUSH PRIVILEGES;' + #13#10
      + NewUser.SQLGetSource();

  Result := (SQL = '') or SendSQL(SQL);
end;

function TSSession.UpdateVariable(const Variable, NewVariable: TSVariable; const UpdateModes: TSVariable.TUpdateModes): Boolean;
var
  I: Integer;
  SQL: string;
begin
  SQL := 'SET ';
  if (vuGlobal in UpdateModes) then
    SQL := SQL + 'GLOBAL '
  else if (vuSession in UpdateModes) then
    SQL := SQL + 'SESSION ';
  if (TryStrToInt(NewVariable.Value, I)) then
    SQL := SQL + Variable.Name + '=' + NewVariable.Value + ';' + #13#10
  else
    SQL := SQL + Variable.Name + '=' + SQLEscape(NewVariable.Value) + ';' + #13#10;

  SQL := SQL + Variables.SQLGetItems(Variable.Name);

  Result := (SQL = '') or SendSQL(SQL, SessionResult);
end;

function TSSession.UserByCaption(const Caption: string): TSUser;
begin
  if (Caption = '<' + Preferences.LoadStr(287) + '>') then
    Result := UserByName('')
  else
    Result := UserByName(Caption);
end;

function TSSession.UserByName(const UserName: string): TSUser;
var
  Index: Integer;
begin
  Index := Users.IndexByName(UserName);
  if (Index < 0) then
    Result := nil
  else
    Result := Users[Index];
end;

function TSSession.VariableByName(const VariableName: string): TSVariable;
var
  Index: Integer;
begin
  Index := Variables.IndexByName(VariableName);
  if (Index < 0) then
    Result := nil
  else
    Result := Variables[Index];
end;

procedure TSSession.VariableChange(const Connection: TMySQLConnection; const Name, NewValue: string);
var
  Variable: TSVariable;
begin
  Variable := VariableByName(Name);
  if (Assigned(Variable)) then
  begin
    Variable.FValue := NewValue;
    SendEvent(etItemValid, Self, Variables, Variable);
  end;
end;

{ TSSessions ******************************************************************}

function TSSessions.Add(const Session: TSSession): Integer;
begin
  Result := inherited Add(Session);

  Session.Connection.OnSQLError := OnSQLError;
end;

function TSSessions.SessionByAccount(const Account: TPAccount): TSSession;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
    if (Sessions[I].Account = Account) then
      Result := Sessions[I];
end;

{ *****************************************************************************}

initialization
  Sessions := TSSessions.Create();
finalization
  Sessions.Free();
end.


unit SQLParser;

interface {********************************************************************}

// SQL Syntax updated through MySQL 5.7.15

type
  TSQLParser = class
  protected
    type
      TOffset = Integer;
      POffsetArray = ^TOffsetArray;
      TOffsetArray = array [0..$FFFFFFF] of TOffset;

      TError = record
        Code: Byte;
        Line: Integer;
        Pos: PChar;
        Token: TOffset;
      end;

  private
    type
      TParseFunction = function(): TOffset of object;
      TTableOptionNodes = packed record
        AutoIncrementValue: TOffset;
        AvgRowLengthValue: TOffset;
        CharacterSetValue: TOffset;
        ChecksumValue: TOffset;
        CollateValue: TOffset;
        CommentValue: TOffset;
        ConnectionValue: TOffset;
        DataDirectoryValue: TOffset;
        DelayKeyWriteValue: TOffset;
        EngineIdent: TOffset;
        IndexDirectoryValue: TOffset;
        InsertMethodValue: TOffset;
        KeyBlockSizeValue: TOffset;
        MaxRowsValue: TOffset;
        MinRowsValue: TOffset;
        PackKeysValue: TOffset;
        PageChecksumInt: TOffset;
        PasswordValue: TOffset;
        RowFormatValue: TOffset;
        StatsAutoRecalc: TOffset;
        StatsPersistent: TOffset;
        StatsSamplePages: TOffset;
        TableChecksumInt: TOffset;
        TablespaceIdent: TOffset;
        TransactionalInt: TOffset;
        UnionList: TOffset;
      end;
      TSeparatorType = (stNone, stReturnBefore, stSpaceBefore, stSpaceAfter, stReturnAfter);
      TValueAssign = (vaYes, vaNo, vaAuto);

      TStringBuffer = class
      private
        Buffer: record
          Mem: PChar;
          MemSize: Integer;
          Write: PChar;
        end;
        function GetData(): Pointer; inline;
        function GetLength(): Integer; inline;
        function GetSize(): Integer; inline;
        function GetText(): PChar; inline;
        procedure Reallocate(const NeededLength: Integer);
      public
        procedure Clear();
        constructor Create(const InitialLength: Integer);
        procedure Delete(const Start: Integer; const Length: Integer);
        destructor Destroy(); override;
        function Read(): string; inline;
        procedure Write(const Text: PChar; const Length: Integer); overload; virtual;
        procedure Write(const Text: string); overload; {$IFNDEF Debug} inline; {$ENDIF}
        procedure Write(const Char: Char); overload; {$IFNDEF Debug} inline; {$ENDIF}
        property Data: Pointer read GetData;
        property Length: Integer read GetLength;
        property Size: Integer read GetSize;
        property Text: PChar read GetText;
      end;

      TWordList = class
      private type
        TIndex = SmallInt;
        TIndices = array [0 .. 7 - 1] of TIndex;
      private
        FCount: TIndex;
        FIndex: array of PChar;
        FFirst: array of Integer;
        FLength: array of Integer;
        FParser: TSQLParser;
        FText: string;
        function GetText(): string;
        function GetWord(Index: TIndex): string; {$IFNDEF Debug} inline; {$ENDIF}
        procedure SetText(AText: string);
      protected
        procedure Clear();
        procedure GetWordText(const Index: TIndex; out Text: PChar; out Length: Integer); {$IFNDEF Debug} inline; {$ENDIF}
        property Parser: TSQLParser read FParser;
      public
        constructor Create(const ASQLParser: TSQLParser; const AText: string = '');
        destructor Destroy(); override;
        function IndexOf(const Word: PChar; const Length: Integer): Integer; overload;
        function IndexOf(const Word: string): Integer; overload; {$IFNDEF Debug} inline; {$ENDIF}
        property Count: TIndex read FCount;
        property Text: string read GetText write SetText;
        property Word[Index: TIndex]: string read GetWord; default;
      end;

      TFormatBuffer = class(TStringBuffer)
      private
        FNewLine: Boolean;
        Indent: Integer;
        IndentSpaces: array [0 .. 1024 - 1] of Char;
      public
        constructor Create();
        procedure DecreaseIndent();
        procedure IncreaseIndent();
        procedure Write(const Text: PChar; const Length: Integer); override;
        procedure Write(const Text: string; const SpaceBefore: Boolean); overload;
        procedure WriteReturn(); {$IFNDEF Debug} inline; {$ENDIF}
        procedure WriteSpace(); {$IFNDEF Debug} inline; {$ENDIF}
      end;

      POffsetList = ^TOffsetList;
      TOffsetList = record
      private
        ArrayLength: Integer;
        FCount: Integer;
        FNodes: POffsetArray;
        DynamicArray: array of TOffset;
        StackArray: array [0 .. 20 - 1] of TOffset;
        function Get(Index: Integer): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
        procedure Put(Index: Integer; Node: TOffset); {$IFNDEF Debug} inline; {$ENDIF}
      public
        procedure Add(const Node: TOffset);
        procedure Delete(const Index: Integer; const Count: Integer = 1);
        function IndexOf(const Node: TOffset): Integer;
        procedure Init();
        property Count: Integer read FCount;
        property Node[Index: Integer]: TOffset read Get write Put; default;
        property Nodes: POffsetArray read FNodes;
      end;

  protected
    type
      TNodeType = (
        ntRoot,            // Root token, one usage by the parser to handle stmt list
        ntToken,           // Token node (smalles logical part of the SQL text)

        ntAccount,
        ntAnalyzeTableStmt,
        ntAlterDatabaseStmt,
        ntAlterEventStmt,
        ntAlterInstanceStmt,
        ntAlterRoutineStmt,
        ntAlterServerStmt,
        ntAlterTablespaceStmt,
        ntAlterTableStmt,
        ntAlterTableStmtAddField,
        ntAlterTableStmtAddFields,
        ntAlterTableStmtAlterField,
        ntAlterTableStmtConvertTo,
        ntAlterTableStmtDropObject,
        ntAlterTableStmtExchangePartition,
        ntAlterTableStmtOrderBy,
        ntAlterTableStmtReorganizePartition,
        ntAlterViewStmt,
        ntBeginLabel,
        ntBeginStmt,
        ntBetweenOp,
        ntBinaryOp,
        ntCallStmt,
        ntCaseOp,
        ntCaseOpBranch,
        ntCaseStmt,
        ntCaseStmtBranch,
        ntCastFunc,
        ntChangeMasterStmt,
        ntCharFunc,
        ntCheckTableStmt,
        ntChecksumTableStmt,
        ntCloseStmt,
        ntCommitStmt,
        ntCompoundStmt,
        ntConvertFunc,
        ntCountFunc,
        ntCreateDatabaseStmt,
        ntCreateEventStmt,
        ntCreateIndexStmt,
        ntCreateRoutineStmt,
        ntCreateServerStmt,
        ntCreateTablespaceStmt,
        ntCreateTableStmt,
        ntCreateTableStmtCheck,
        ntCreateTableStmtField,
        ntCreateTableStmtFieldOnUpdate,
        ntCreateTableStmtForeignKey,
        ntCreateTableStmtKey,
        ntCreateTableStmtKeyColumn,
        ntCreateTableStmtPartition,
        ntCreateTableStmtPartitionOptions,
        ntCreateTableStmtReference,
        ntCreateTriggerStmt,
        ntCreateUserStmt,
        ntCreateViewStmt,
        ntDatatype,
        ntDateAddFunc,
        ntDbIdent,
        ntDeallocatePrepareStmt,
        ntDeclareStmt,
        ntDeclareConditionStmt,
        ntDeclareCursorStmt,
        ntDeclareHandlerStmt,
        ntDefaultFunc,
        ntDeleteStmt,
        ntDoStmt,
        ntDropDatabaseStmt,
        ntDropEventStmt,
        ntDropIndexStmt,
        ntDropRoutineStmt,
        ntDropServerStmt,
        ntDropTablespaceStmt,
        ntDropTableStmt,
        ntDropTriggerStmt,
        ntDropUserStmt,
        ntDropViewStmt,
        ntEndLabel,
        ntExecuteStmt,
        ntExplainStmt,
        ntExtractFunc,
        ntFetchStmt,
        ntFlushStmt,
        ntFlushStmtOption,
        ntFlushStmtOptionLogs,
        ntFunctionReturns,
        ntGetDiagnosticsStmt,
        ntGetDiagnosticsStmtStmtInfo,
        ntGetDiagnosticsStmtCondInfo,
        ntGrantStmt,
        ntGrantStmtPrivileg,
        ntGrantStmtUserSpecification,
        ntGroupConcatFunc,
        ntGroupConcatFuncExpr,
        ntHelpStmt,
        ntIfStmt,
        ntIfStmtBranch,
        ntInOp,
        ntInsertStmt,
        ntInsertStmtSetItem,
        ntIntervalOp,
        ntInstallPluginStmt,
        ntIsOp,
        ntIterateStmt,
        ntKillStmt,
        ntLeaveStmt,
        ntLikeOp,
        ntList,
        ntLoadDataStmt,
        ntLoadXMLStmt,
        ntLockTablesStmt,
        ntLockTablesStmtItem,
        ntLoopStmt,
        ntMatchFunc,
        ntPositionFunc,
        ntPrepareStmt,
        ntPurgeStmt,
        ntOpenStmt,
        ntOptimizeTableStmt,
        ntRegExpOp,
        ntRenameStmt,
        ntRenameStmtPair,
        ntReleaseStmt,
        ntRepairTableStmt,
        ntRepeatStmt,
        ntResetStmt,
        ntReturnStmt,
        ntRevokeStmt,
        ntRollbackStmt,
        ntRoutineParam,
        ntSavepointStmt,
        ntSchedule,
        ntSecretIdent,
        ntSelectStmt,
        ntSelectStmtColumn,
        ntSelectStmtGroup,
        ntSelectStmtLimit,
        ntSelectStmtOrder,
        ntSelectStmtOrderBy,
        ntSelectStmtTableFactor,
        ntSelectStmtTableFactorIndexHint,
        ntSelectStmtTableFactorOj,
        ntSelectStmtTableFactorSubquery,
        ntSelectStmtTableJoin,
        ntSetNamesStmt,
        ntSetPasswordStmt,
        ntSetStmt,
        ntSetStmtAssignment,
        ntSetTransactionStmt,
        ntSetTransactionStmtCharacteristic,
        ntShowBinaryLogsStmt,
        ntShowBinlogEventsStmt,
        ntShowCharacterSetStmt,
        ntShowCollationStmt,
        ntShowColumnsStmt,
        ntShowCountStmt,
        ntShowCreateDatabaseStmt,
        ntShowCreateEventStmt,
        ntShowCreateFunctionStmt,
        ntShowCreateProcedureStmt,
        ntShowCreateTableStmt,
        ntShowCreateTriggerStmt,
        ntShowCreateUserStmt,
        ntShowCreateViewStmt,
        ntShowDatabasesStmt,
        ntShowEngineStmt,
        ntShowEnginesStmt,
        ntShowErrorsStmt,
        ntShowEventsStmt,
        ntShowFunctionStatusStmt,
        ntShowGrantsStmt,
        ntShowIndexStmt,
        ntShowMasterStatusStmt,
        ntShowOpenTablesStmt,
        ntShowPluginsStmt,
        ntShowPrivilegesStmt,
        ntShowProcedureStatusStmt,
        ntShowProcessListStmt,
        ntShowProfileStmt,
        ntShowProfilesStmt,
        ntShowRelaylogEventsStmt,
        ntShowRoutineCodeStmt,
        ntShowSlaveHostsStmt,
        ntShowSlaveStatusStmt,
        ntShowStatusStmt,
        ntShowTableStatusStmt,
        ntShowTablesStmt,
        ntShowTriggersStmt,
        ntShowVariablesStmt,
        ntShowWarningsStmt,
        ntShutdownStmt,
        ntSignalStmt,
        ntSignalStmtInformation,
        ntSoundsLikeOp,
        ntStartSlaveStmt,
        ntStartTransactionStmt,
        ntStopSlaveStmt,
        ntSubArea,
        ntSubPartition,
        ntSubquery,
        ntSubstringFunc,
        ntSumFunc,
        ntTag,
        ntTimestampAddFunc,
        ntTimestampDiffFunc,
        ntTrimFunc,
        ntTruncateStmt,
        ntUnaryOp,
        ntUninstallPluginStmt,
        ntUnknownStmt,
        ntUnlockTablesStmt,
        ntUpdateStmt,
        ntUseStmt,
        ntValue,
        ntVariableIdent,
        ntWeightStringFunc,
        ntWeightStringFuncLevel,
        ntWhileStmt,
        ntXAStmt,
        ntXAStmtID
      );

      TStmtType = (
        stAnalyzeTable,
        stAlterDatabase,
        stAlterEvent,
        stAlterInstance,
        stAlterRoutine,
        stAlterServer,
        stAlterTable,
        stAlterTablespace,
        stAlterView,
        stBegin,
        stCall,
        stCase,
        stChangeMaster,
        stCheckTable,
        stChecksumTable,
        stClose,
        stCommit,
        stCompound,
        stCreateDatabase,
        stCreateEvent,
        stCreateIndex,
        stCreateRoutine,
        stCreateServer,
        stCreateTablespace,
        stCreateTable,
        stCreateTrigger,
        stCreateUser,
        stCreateView,
        stDeallocatePrepare,
        stDeclare,
        stDeclareCondition,
        stDeclareCursor,
        stDeclareHandler,
        stDelete,
        stDo,
        stDropDatabase,
        stDropEvent,
        stDropIndex,
        stDropRoutine,
        stDropServer,
        stDropTable,
        stDropTablespace,
        stDropTrigger,
        stDropUser,
        stDropView,
        stExecute,
        stExplain,
        stFetch,
        stFlush,
        stGetDiagnostics,
        stGrant,
        stHelp,
        stIf,
        stInsert,
        stInstallPlugin,
        stIterate,
        stKill,
        stLeave,
        stLoadData,
        stLoadXML,
        stLockTable,
        stLoop,
        stPrepare,
        stPurge,
        stOpen,
        stOptimizeTable,
        stRename,
        stRelease,
        stRepairTable,
        stRepeat,
        stReset,
        stReturn,
        stRevoke,
        stRollback,
        stSavepoint,
        stSelect,
        stSetNames,
        stSetPassword,
        stSet,
        stSetTransaction,
        stShowBinaryLogs,
        stShowBinlogEvents,
        stShowCharacterSet,
        stShowCollation,
        stShowColumns,
        stShowCount,
        stShowCreateDatabase,
        stShowCreateEvent,
        stShowCreateFunction,
        stShowCreateProcedure,
        stShowCreateTable,
        stShowCreateTrigger,
        stShowCreateUser,
        stShowCreateView,
        stShowDatabases,
        stShowEngine,
        stShowEngines,
        stShowErrors,
        stShowEvents,
        stShowFunctionStatus,
        stShowGrants,
        stShowIndex,
        stShowMasterStatus,
        stShowOpenTables,
        stShowPlugins,
        stShowPrivileges,
        stShowProcedureStatus,
        stShowProcessList,
        stShowProfile,
        stShowProfiles,
        stShowRelaylogEvents,
        stShowRoutineCode,
        stShowSlaveHosts,
        stShowSlaveStatus,
        stShowStatus,
        stShowTableStatus,
        stShowTables,
        stShowTriggers,
        stShowVariables,
        stShowWarnings,
        stShutdown,
        stSignal,
        stStartSlave,
        stStartTransaction,
        stStopSlave,
        stTruncate,
        stUninstallPlugin,
        stUnknown,
        stUnlockTables,
        stUpdate,
        stUse,
        stWhile,
        stXA
      );

      TUsageType = (
        utUnknown,
        utComment,
        utDbIdent,
        utDatatype,
        utInteger,
        utKeyword,
        utLabel,
        utNumeric,
        utOperator,
        utString,
        utSymbol,
        utWhiteSpace
      );

      TTokenType = (
        ttUnknown,
        ttSpace,                  // <Tab> and <Space>
        ttReturn,                 // <CarriageReturn> and <NewLine>
        ttSLComment,              // Comment, like # comment | -- comment
        ttMLComment,              // Comment, like /* this is a multi line comment */
        ttDot,                    // "."
        ttColon,                  // ":"
        ttSemicolon,              // ";"
        ttComma,                  // ","
        ttOpenBracket,            // "("
        ttCloseBracket,           // ")"
        ttOpenCurlyBracket,       // "{"
        ttCloseCurlyBracket,      // "}"
        ttInteger,                // Integer constant like -123456
        ttNumeric,                // Numeric constant like -123.456E78
        ttString,                 // String constant enclosed in ''
        ttIdent,                  // Ident
        ttDQIdent,                // Ident | string, enclosed in ""
        ttMySQLIdent,             // Ident, enclosed in ``
        ttMySQLCondStart,         // MySQL specific code, like /*!50000 SELECT 1; */
        ttMySQLCondEnd,
        ttOperator,               // Symbolic operator like +, -, &&, *=
        ttAt                      // "@"
      );

      TOperatorType = (
        otNone,

        otDot,                    // "."

        otInterval,               // "INTERVAL"

        otBinary,                 // "BINARY"
        otCollate,                // "COLLATE"

        otUnaryNot,               // "!"

        otUnaryMinus,             // "-"
        otUnaryPlus,              // "+"
        otBitInversion,           // "~"

        otJSONExtract,            // "->"

        otBitXOR,                 // "^"

        otMulti,                  // "*"
        otDivision,               // "/"
        otDiv,                    // "DIV"
        otMod,                    // "%", "MOD"

        otMinus,                  // "-"
        otPlus,                   // "+"

        otShiftLeft,              // "<<
        otShiftRight,             // ">>"

        otBitAND,                 // "&"

        otBitOR,                  // "|"

        otEqual,                  // "="
        otNullSaveEqual,          // "<=>"
        otGreaterEqual,           // ">="
        otGreater,                // ">"
        otLessEqual,              // "<="
        otLess,                   // "<"
        otNotEqual,               // "!=", "<>"
        otIs,                     // "IS"
        otSounds,                 // "SOUNDS"
        otLike,                   // "LIKE"
        otEscape,                 // "ESCAPE"
        otRegExp,                 // "REGEXP", "RLIKE"
        otIn,                     // "IN"

        otBetween,                // "BETWEEN"
        otCase,                   // "CASE"

        otNot,                    // "NOT"

        otAnd,                    // "&&", "AND"

        otXOr,                    // "^", "XOR"

        otOr,                     // "||", "OR"

        otAssign                  // ":="
      );

      TDbIdentType = (
        ditUnknown,
        ditDatabase,
        ditTable,
        ditProcedure,
        ditFunction,
        ditTrigger,
        ditEvent,
        ditKey,
        ditField,
        ditForeignKey,
        ditPartition,
        ditUser,
        ditHost,
        ditConstraint,
        ditColumnAlias,
        ditTableAlias,
        ditConstante,
        ditTriggerRec,
        ditPlugin,
        ditEngine,
        ditCharset,
        ditCollation,
        ditDatatype,
        ditVariable,
        ditRoutineParam,
        ditCompoundVariable,
        ditCursor,
        ditCondition
      );

      TJoinType = (
        jtUnknown,
        jtInner,
        jtCross,
        jtStraight,
        jtEqui,
        jtLeft,
        jtRight,
        jtNaturalLeft,
        jtNaturalRight
      );

      TRoutineType = (
        rtFunction,
        rtProcedure
      );

    const
      NodeTypeToString: array [TNodeType] of PChar = (
        'ntRoot',
        'ntToken',

        'ntAccount',
        'ntAnalyzeTableStmt',
        'ntAlterDatabaseStmt',
        'ntAlterEventStmt',
        'ntAlterInstanceStmt',
        'ntAlterRoutineStmt',
        'ntAlterServerStmt',
        'ntAlterTablespaceStmt',
        'ntAlterTableStmt',
        'ntAlterTableStmtAddField',
        'ntAlterTableStmtAddFields',
        'ntAlterTableStmtAlterField',
        'ntAlterTableStmtConvertTo',
        'ntAlterTableStmtDropObject',
        'ntAlterTableStmtExchangePartition',
        'ntAlterTableStmtOrderBy',
        'ntAlterTableStmtReorganizePartition',
        'ntAlterViewStmt',
        'ntBeginLabel',
        'ntBeginStmt',
        'ntBetweenOp',
        'ntBinaryOp',
        'ntCallStmt',
        'ntCaseOp',
        'ntCaseOpBranch',
        'ntCaseStmt',
        'ntCaseStmtBranch',
        'ntCastFunc',
        'ntChangeMasterStmt',
        'ntCharFunc',
        'ntCheckTableStmt',
        'ntChecksumTableStmt',
        'ntCloseStmt',
        'ntCommitStmt',
        'ntCompoundStmt',
        'ntConvertFunc',
        'ntCountFunc',
        'ntCreateDatabaseStmt',
        'ntCreateEventStmt',
        'ntCreateIndexStmt',
        'ntCreateRoutineStmt',
        'ntCreateServerStmt',
        'ntCreateTablespaceStmt',
        'ntCreateTableStmt',
        'ntCreateTableStmtCheck',
        'ntCreateTableStmtField',
        'ntCreateTableStmtFieldOnUpdate',
        'ntCreateTableStmtForeignKey',
        'ntCreateTableStmtKey',
        'ntCreateTableStmtKeyColumn',
        'ntCreateTableStmtPartition',
        'ntCreateTableStmtPartitionOptions',
        'ntCreateTableStmtReference',
        'ntCreateTriggerStmt',
        'ntCreateUserStmt',
        'ntCreateViewStmt',
        'ntDatatype',
        'ntDateAddFunc',
        'ntDbIdent',
        'ntDeallocatePrepareStmt',
        'ntDeclareStmt',
        'ntDeclareConditionStmt',
        'ntDeclareCursorStmt',
        'ntDeclareHandlerStmt',
        'ntDefaultFunc',
        'ntDeleteStmt',
        'ntDoStmt',
        'ntDropDatabaseStmt',
        'ntDropEventStmt',
        'ntDropIndexStmt',
        'ntDropRoutineStmt',
        'ntDropServerStmt',
        'ntDropTablespaceStmt',
        'ntDropTableStmt',
        'ntDropTriggerStmt',
        'ntDropUserStmt',
        'ntDropViewStmt',
        'ntEndLabel',
        'ntExecuteStmt',
        'ntExplainStmt',
        'ntExtractFunc',
        'ntFetchStmt',
        'ntFlushStmt',
        'ntFlushStmtOption',
        'ntFlushStmtOptionLogs',
        'ntFunctionReturns',
        'ntGetDiagnosticsStmt',
        'ntGetDiagnosticsStmtStmtInfo',
        'ntGetDiagnosticsStmtCondInfo',
        'ntGrantStmt',
        'ntGrantStmtPrivileg',
        'ntGrantStmtUserSpecification',
        'ntGroupConcatFunc',
        'ntGroupConcatFuncExpr',
        'ntHelpStmt',
        'ntIfStmt',
        'ntIfStmtBranch',
        'ntInOp',
        'ntInsertStmt',
        'ntInsertStmtSetItem',
        'ntInstallPluginStmt',
        'ntIntervalOp',
        'ntIsOp',
        'ntIterateStmt',
        'ntKillStmt',
        'ntLeaveStmt',
        'ntLikeOp',
        'ntList',
        'ntLoadDataStmt',
        'ntLoadXMLStmt',
        'ntLockTablesStmt',
        'ntLockTablesStmtItem',
        'ntLoopStmt',
        'ntMatchFunc',
        'ntPositionFunc',
        'ntPrepareStmt',
        'ntPurgeStmt',
        'ntOpenStmt',
        'ntOptimizeTableStmt',
        'ntRegExpOp',
        'ntRenameStmt',
        'ntRenameStmtPair',
        'ntReleaseStmt',
        'ntRepairTableStmt',
        'ntRepeatStmt',
        'ntResetStmt',
        'ntReturnStmt',
        'ntRevokeStmt',
        'ntRollbackStmt',
        'ntRoutineParam',
        'ntSavepointStmt',
        'ntSchedule',
        'ntSecretIdent',
        'ntSelectStmt',
        'ntSelectStmtColumn',
        'ntSelectStmtGroup',
        'ntSelectStmtLimit',
        'ntSelectStmtOrder',
        'ntSelectStmtOrderBy',
        'ntSelectStmtTableFactor',
        'ntSelectStmtTableFactorIndexHint',
        'ntSelectStmtTableFactorOj',
        'ntSelectStmtTableFactorSubquery',
        'ntSelectStmtTableJoin',
        'ntSetNamesStmt',
        'ntSetPasswordStmt',
        'ntSetStmt',
        'ntSetStmtAssignment',
        'ntSetTransactionStmt',
        'ntSetTransactionStmtCharacteristic',
        'ntShowBinaryLogsStmt',
        'ntShowBinlogEventsStmt',
        'ntShowCharacterSetStmt',
        'ntShowCollationStmt',
        'ntShowColumnsStmt',
        'ntShowCountStmt',
        'ntShowCreateDatabaseStmt',
        'ntShowCreateEventStmt',
        'ntShowCreateFunctionStmt',
        'ntShowCreateProcedureStmt',
        'ntShowCreateTableStmt',
        'ntShowCreateTriggerStmt',
        'ntShowCreateUserStmt',
        'ntShowCreateViewStmt',
        'ntShowDatabasesStmt',
        'ntShowEngineStmt',
        'ntShowEnginesStmt',
        'ntShowErrorsStmt',
        'ntShowEventsStmt',
        'ntShowFunctionStatusStmt',
        'ntShowGrantsStmt',
        'ntShowIndexStmt',
        'ntShowMasterStatusStmt',
        'ntShowOpenTablesStmt',
        'ntShowPluginsStmt',
        'ntShowPrivilegesStmt',
        'ntShowProcedureStatusStmt',
        'ntShowProcessListStmt',
        'ntShowProfileStmt',
        'ntShowProfilesStmt',
        'ntShowRelaylogEventsStmt',
        'ntShowRoutineCodeStmt',
        'ntShowSlaveHostsStmt',
        'ntShowSlaveStatusStmt',
        'ntShowStatusStmt',
        'ntShowTableStatusStmt',
        'ntShowTablesStmt',
        'ntShowTriggersStmt',
        'ntShowVariablesStmt',
        'ntShowWarningsStmt',
        'ntShutdownStmt',
        'ntSignalStmt',
        'ntSignalStmtInformation',
        'ntSoundsLikeOp',
        'ntStartSlaveStmt',
        'ntStartTransactionStmt',
        'ntStopSlaveStmt',
        'ntSubArea',
        'ntSubPartition',
        'ntSubquery',
        'ntSubstringFunc',
        'ntSumFunc',
        'ntTag',
        'ntTimestampAddFunc',
        'ntTimestampDiffFunc',
        'ntTrimFunc',
        'ntTruncateStmt',
        'ntUnaryOp',
        'ntUninstallPluginStmt',
        'ntUnknownStmt',
        'ntUnlockTablesStmt',
        'ntUpdateStmt',
        'ntUseStmt',
        'ntValue',
        'ntVariableIdent',
        'ntWeightStringFunc',
        'ntWeightStringFuncLevel',
        'ntWhileStmt',
        'ntXAStmt',
        'ntXAStmtID'
      );

      StmtTypeToString: array [TStmtType] of PChar = (
        'stAnalyzeTable',
        'stAlterDatabase',
        'stAlterEvent',
        'stAlterInstance',
        'stAlterRoutine',
        'stAlterServer',
        'stAlterTable',
        'stAlterTablespace',
        'stAlterView',
        'stBegin',
        'stCall',
        'stCase',
        'stChangeMaster',
        'stCheckTable',
        'stChecksumTable',
        'stClose',
        'stCommit',
        'stCompound',
        'stCreateDatabase',
        'stCreateEvent',
        'stCreateIndex',
        'stCreateRoutine',
        'stCreateServer',
        'stCreateTablespace',
        'stCreateTable',
        'stCreateTrigger',
        'stCreateUser',
        'stCreateView',
        'stDeallocatePrepare',
        'stDeclare',
        'stDeclareCondition',
        'stDeclareCursor',
        'stDeclareHandler',
        'stDelete',
        'stDo',
        'stDropDatabase',
        'stDropEvent',
        'stDropIndex',
        'stDropRoutine',
        'stDropServer',
        'stDropTable',
        'stDropTablespace',
        'stDropTrigger',
        'stDropUser',
        'stDropView',
        'stExecute',
        'stExplain',
        'stFetch',
        'stFlush',
        'stGetDiagnostics',
        'stGrant',
        'stHelp',
        'stIf',
        'stInsert',
        'stInstallPlugin',
        'stIterate',
        'stKill',
        'stLeave',
        'stLoadData',
        'stLoadXML',
        'stLockTable',
        'stLoop',
        'stPrepare',
        'stPurge',
        'stOpen',
        'stOptimizeTable',
        'stRename',
        'stRelease',
        'stRepairTable',
        'stRepeat',
        'stReset',
        'stReturn',
        'stRevoke',
        'stRollback',
        'stSavepoint',
        'stSelect',
        'stSetNames',
        'stSetPassword',
        'stSet',
        'stSetTransaction',
        'stShowBinaryLogs',
        'stShowBinlogEvents',
        'stShowCharacterSet',
        'stShowCollation',
        'stShowColumns',
        'stShowCount',
        'stShowCreateDatabase',
        'stShowCreateEvent',
        'stShowCreateFunction',
        'stShowCreateProcedure',
        'stShowCreateTable',
        'stShowCreateTrigger',
        'stShowCreateUser',
        'stShowCreateView',
        'stShowDatabases',
        'stShowEngine',
        'stShowEngines',
        'stShowErrors',
        'stShowEvents',
        'stShowFunctionStatus',
        'stShowGrants',
        'stShowIndex',
        'stShowMasterStatus',
        'stShowOpenTables',
        'stShowPlugins',
        'stShowPrivileges',
        'stShowProcedureStatus',
        'stShowProcessList',
        'stShowProfile',
        'stShowProfiles',
        'stShowRelaylogEvents',
        'stShowRoutineCode',
        'stShowSlaveHosts',
        'stShowSlaveStatus',
        'stShowStatus',
        'stShowTableStatus',
        'stShowTables',
        'stShowTriggers',
        'stShowVariables',
        'stShowWarnings',
        'stShutdown',
        'stSignal',
        'stStartSlave',
        'stStartTransaction',
        'stStopSlave',
        'stTruncate',
        'stUninstallPlugin',
        'stUnknown',
        'stUnlockTables',
        'stUpdate',
        'stUse',
        'stWhile',
        'stXA'
      );

      TokenTypeToString: array [TTokenType] of PChar = (
        'ttUnknown',
        'ttSpace',
        'ttReturn',
        'ttLineComment',
        'ttMultiLineComment',
        'ttDot',
        'ttColon',
        'ttSemicolon',
        'ttComma',
        'ttOpenBracket',
        'ttCloseBracket',
        'ttOpenCurlyBracket',
        'ttCloseCurlyBracket',
        'ttInteger',
        'ttNumeric',
        'ttString',
        'ttIdent',
        'ttDQIdent',
        'ttMySQLIdent',
        'ttMySQLCondStart',
        'ttMySQLCondEnd',
        'ttOperator',
        'ttAt'
      );

      UsageTypeToString: array [TUsageType] of PChar = (
        'utUnknown',
        'utComment',
        'utDbIdent',
        'utDatatype',
        'utInteger',
        'utKeyword',
        'utLabel',
        'utNumeric',
        'utOperator',
        'utString',
        'utSymbol',
        'utWhiteSpace'
      );

      OperatorTypeToString: array [TOperatorType] of PChar = (
        'otUnknown',

        'otDot',

        'otInterval',

        'otBinary',
        'otCollate',

        'otUnaryNot',

        'otUnaryMinus',
        'otUnaryPlus',
        'otInvertBits',

        'otJSONExtract',

        'otBitXOR',

        'otMulti',
        'otDivision',
        'otDiv',
        'otMod',

        'otMinus',
        'otPlus',

        'otShiftLeft',
        'otShiftRight',

        'otBitAND',

        'otBitOR',

        'otEqual',
        'otNullSaveEqual',
        'otGreaterEqual',
        'otGreater',
        'otLessEqual',
        'otLess',
        'otNotEqual',
        'otIs',
        'otSounds',
        'otLike',
        'otEscape',
        'otRegExp',
        'otIn',

        'otBetween',
        'otCase',

        'otNot',

        'otAnd',

        'otXOr',

        'otOr',

        'otAssign'
      );

      DbIdentTypeToString: array [TDbIdentType] of PChar = (
        'ditUnknown',
        'ditDatabase',
        'ditTable',
        'ditProcedure',
        'ditFunction',
        'ditTrigger',
        'ditEvent',
        'ditKey',
        'ditField',
        'ditForeignKey',
        'ditPartition',
        'ditUser',
        'ditHost',
        'ditConstraint',
        'ditColumnAlias',
        'ditTableAlias',
        'ditConstante',
        'ditTriggerRec',
        'ditPlugin',
        'ditEngine',
        'ditCharset',
        'ditCollation',
        'ditDatatype',
        'ditVariable',
        'ditRoutineParam',
        'ditCompoundVariable',
        'ditCursor',
        'ditCondition'
      );

      JoinTypeToString: array [TJoinType] of PChar = (
        'jtUnknown',
        'jtInner',
        'jtCross',
        'jtStraight',
        'jtEqui',
        'jtLeft',
        'jtRight',
        'jtNaturalLeft',
        'jtNaturalRight'
      );

      RoutineTypeToString: array [TRoutineType] of PChar = (
        'rtFunction',
        'rtProcedure'
      );

      StmtNodeTypes = [
        ntAnalyzeTableStmt,
        ntAlterDatabaseStmt,
        ntAlterEventStmt,
        ntAlterInstanceStmt,
        ntAlterRoutineStmt,
        ntAlterServerStmt,
        ntAlterTablespaceStmt,
        ntAlterTableStmt,
        ntAlterViewStmt,
        ntBeginStmt,
        ntCallStmt,
        ntCaseStmt,
        ntChangeMasterStmt,
        ntCheckTableStmt,
        ntChecksumTableStmt,
        ntCloseStmt,
        ntCommitStmt,
        ntCompoundStmt,
        ntCreateDatabaseStmt,
        ntCreateEventStmt,
        ntCreateIndexStmt,
        ntCreateRoutineStmt,
        ntCreateServerStmt,
        ntCreateTablespaceStmt,
        ntCreateTableStmt,
        ntCreateTriggerStmt,
        ntCreateUserStmt,
        ntCreateViewStmt,
        ntDeallocatePrepareStmt,
        ntDeclareStmt,
        ntDeclareConditionStmt,
        ntDeclareCursorStmt,
        ntDeclareHandlerStmt,
        ntDeleteStmt,
        ntDoStmt,
        ntDropDatabaseStmt,
        ntDropEventStmt,
        ntDropIndexStmt,
        ntDropRoutineStmt,
        ntDropServerStmt,
        ntDropTableStmt,
        ntDropTablespaceStmt,
        ntDropTriggerStmt,
        ntDropUserStmt,
        ntDropViewStmt,
        ntExecuteStmt,
        ntExplainStmt,
        ntFetchStmt,
        ntFlushStmt,
        ntGetDiagnosticsStmt,
        ntGrantStmt,
        ntHelpStmt,
        ntIfStmt,
        ntInsertStmt,
        ntInstallPluginStmt,
        ntIterateStmt,
        ntKillStmt,
        ntLeaveStmt,
        ntLoadDataStmt,
        ntLoadXMLStmt,
        ntLockTablesStmt,
        ntLoopStmt,
        ntPrepareStmt,
        ntPurgeStmt,
        ntOpenStmt,
        ntOptimizeTableStmt,
        ntRenameStmt,
        ntReleaseStmt,
        ntRepairTableStmt,
        ntRepeatStmt,
        ntResetStmt,
        ntReturnStmt,
        ntRevokeStmt,
        ntRollbackStmt,
        ntSavepointStmt,
        ntSelectStmt,
        ntSetNamesStmt,
        ntSetPasswordStmt,
        ntSetStmt,
        ntSetTransactionStmt,
        ntShowBinaryLogsStmt,
        ntShowBinlogEventsStmt,
        ntShowCharacterSetStmt,
        ntShowCollationStmt,
        ntShowColumnsStmt,
        ntShowCountStmt,
        ntShowCreateDatabaseStmt,
        ntShowCreateEventStmt,
        ntShowCreateFunctionStmt,
        ntShowCreateProcedureStmt,
        ntShowCreateTableStmt,
        ntShowCreateTriggerStmt,
        ntShowCreateUserStmt,
        ntShowCreateViewStmt,
        ntShowDatabasesStmt,
        ntShowEngineStmt,
        ntShowEnginesStmt,
        ntShowErrorsStmt,
        ntShowEventsStmt,
        ntShowFunctionStatusStmt,
        ntShowGrantsStmt,
        ntShowIndexStmt,
        ntShowMasterStatusStmt,
        ntShowOpenTablesStmt,
        ntShowPluginsStmt,
        ntShowPrivilegesStmt,
        ntShowProcedureStatusStmt,
        ntShowProcessListStmt,
        ntShowProfileStmt,
        ntShowProfilesStmt,
        ntShowRelaylogEventsStmt,
        ntShowRoutineCodeStmt,
        ntShowSlaveHostsStmt,
        ntShowSlaveStatusStmt,
        ntShowStatusStmt,
        ntShowTableStatusStmt,
        ntShowTablesStmt,
        ntShowTriggersStmt,
        ntShowVariablesStmt,
        ntShowWarningsStmt,
        ntShutdownStmt,
        ntSignalStmt,
        ntStartSlaveStmt,
        ntStartTransactionStmt,
        ntStopSlaveStmt,
        ntTruncateStmt,
        ntUninstallPluginStmt,
        ntUnknownStmt,
        ntUnlockTablesStmt,
        ntUpdateStmt,
        ntUseStmt,
        ntWhileStmt,
        ntXAStmt
      ];

      FuncNodeTypes = [
        ntCastFunc,
        ntCharFunc,
        ntConvertFunc,
        ntCountFunc,
        ntDateAddFunc,
        ntDefaultFunc,
        ntExtractFunc,
        ntGroupConcatFunc,
        ntMatchFunc,
        ntPositionFunc,
        ntSubstringFunc,
        ntSumFunc,
        ntTimestampAddFunc,
        ntTimestampDiffFunc,
        ntTrimFunc,
        ntWeightStringFunc
      ];

      otUnaryOperators = [otUnaryNot, otUnaryMinus, otUnaryPlus, otBitInversion, otNot];

      OperatorPrecedenceByOperatorType: array [TOperatorType] of Integer = (
        0,   // otUnknown

        1,   // otDot

        2,   // otInterval

        3,   // otBinary
        3,   // otCollate

        4,   // otUnaryNot

        5,   // otUnaryMinus
        5,   // otUnaryPlus
        5,   // otBitInversion

        6,   // otJSONExtract

        7,   // otBitXOR

        8,   // otMulti
        8,   // otDivision
        8,   // otDiv
        8,   // otMod

        9,   // otMinus
        9,   // otPlus

        10,   // otShiftLeft
        10,   // otShiftRight

        11,  // otBitAND

        12,  // otBitOR

        13,  // otEqual
        13,  // otNullSaveEqual
        13,  // otGreaterEqual
        13,  // otGreater
        13,  // otLessEqual
        13,  // otLess
        13,  // otNotEqual
        13,  // otIs
        13,  // otSounds
        13,  // otLike
        13,  // otEscape
        13,  // otRegExp
        13,  // otIn

        14,  // otBetween
        14,  // otCase

        15,  // otNot

        16,  // otAnd

        17,  // otXOr

        18,  // otOr

        19   // otAssign
      );
      MaxOperatorPrecedence = 19;

      NodeTypeByStmtType: array [TStmtType] of TNodeType = (
        ntAnalyzeTableStmt,
        ntAlterDatabaseStmt,
        ntAlterEventStmt,
        ntAlterInstanceStmt,
        ntAlterRoutineStmt,
        ntAlterServerStmt,
        ntAlterTableStmt,
        ntAlterTablespaceStmt,
        ntAlterViewStmt,
        ntBeginStmt,
        ntCallStmt,
        ntCaseStmt,
        ntChangeMasterStmt,
        ntCheckTableStmt,
        ntChecksumTableStmt,
        ntCloseStmt,
        ntCommitStmt,
        ntCompoundStmt,
        ntCreateDatabaseStmt,
        ntCreateEventStmt,
        ntCreateIndexStmt,
        ntCreateRoutineStmt,
        ntCreateServerStmt,
        ntCreateTablespaceStmt,
        ntCreateTableStmt,
        ntCreateTriggerStmt,
        ntCreateUserStmt,
        ntCreateViewStmt,
        ntDeallocatePrepareStmt,
        ntDeclareStmt,
        ntDeclareConditionStmt,
        ntDeclareCursorStmt,
        ntDeclareHandlerStmt,
        ntDeleteStmt,
        ntDoStmt,
        ntDropDatabaseStmt,
        ntDropEventStmt,
        ntDropIndexStmt,
        ntDropRoutineStmt,
        ntDropServerStmt,
        ntDropTableStmt,
        ntDropTablespaceStmt,
        ntDropTriggerStmt,
        ntDropUserStmt,
        ntDropViewStmt,
        ntExecuteStmt,
        ntExplainStmt,
        ntFetchStmt,
        ntFlushStmt,
        ntGetDiagnosticsStmt,
        ntGrantStmt,
        ntHelpStmt,
        ntIfStmt,
        ntInsertStmt,
        ntInstallPluginStmt,
        ntIterateStmt,
        ntKillStmt,
        ntLeaveStmt,
        ntLoadDataStmt,
        ntLoadXMLStmt,
        ntLockTablesStmt,
        ntLoopStmt,
        ntPrepareStmt,
        ntPurgeStmt,
        ntOpenStmt,
        ntOptimizeTableStmt,
        ntRenameStmt,
        ntReleaseStmt,
        ntRepairTableStmt,
        ntRepeatStmt,
        ntResetStmt,
        ntReturnStmt,
        ntRevokeStmt,
        ntRollbackStmt,
        ntSavepointStmt,
        ntSelectStmt,
        ntSetNamesStmt,
        ntSetPasswordStmt,
        ntSetStmt,
        ntSetTransactionStmt,
        ntShowBinaryLogsStmt,
        ntShowBinlogEventsStmt,
        ntShowCharacterSetStmt,
        ntShowCollationStmt,
        ntShowColumnsStmt,
        ntShowCountStmt,
        ntShowCreateDatabaseStmt,
        ntShowCreateEventStmt,
        ntShowCreateFunctionStmt,
        ntShowCreateProcedureStmt,
        ntShowCreateTableStmt,
        ntShowCreateTriggerStmt,
        ntShowCreateUserStmt,
        ntShowCreateViewStmt,
        ntShowDatabasesStmt,
        ntShowEngineStmt,
        ntShowEnginesStmt,
        ntShowErrorsStmt,
        ntShowEventsStmt,
        ntShowFunctionStatusStmt,
        ntShowGrantsStmt,
        ntShowIndexStmt,
        ntShowMasterStatusStmt,
        ntShowOpenTablesStmt,
        ntShowPluginsStmt,
        ntShowPrivilegesStmt,
        ntShowProcedureStatusStmt,
        ntShowProcessListStmt,
        ntShowProfileStmt,
        ntShowProfilesStmt,
        ntShowRelaylogEventsStmt,
        ntShowRoutineCodeStmt,
        ntShowSlaveHostsStmt,
        ntShowSlaveStatusStmt,
        ntShowStatusStmt,
        ntShowTableStatusStmt,
        ntShowTablesStmt,
        ntShowTriggersStmt,
        ntShowVariablesStmt,
        ntShowWarningsStmt,
        ntShutdownStmt,
        ntSignalStmt,
        ntStartSlaveStmt,
        ntStartTransactionStmt,
        ntStopSlaveStmt,
        ntTruncateStmt,
        ntUninstallPluginStmt,
        ntUnknownStmt,
        ntUnlockTablesStmt,
        ntUpdateStmt,
        ntUseStmt,
        ntWhileStmt,
        ntXAStmt
      );

  public
    type
      TCompletionList = class
      public type
        PItem = ^TItem;
        TItem = record
          case ItemType: (itTag, itText, itList) of
            itTag: ( // for protected use only
              KeywordIndices: TWordList.TIndices;
            );
            itText: (
              Text: array [0 .. 256] of Char;
            );
            itList: (
              DatabaseName: array [0 .. 64] of Char;
              DbIdentType: TDbIdentType;
              TableName: array [0 .. 64] of Char;
            );
        end;
      private const
        DefaultListLength = 100;
      private
        Active: Boolean;
        FCount: Integer;
        FParser: TSQLParser;
        FItems: array of TItem;
        function GetItem(Index: Integer): PItem; {$IFNDEF Debug} inline; {$ENDIF}
        procedure SetActive(AActive: Boolean);
      protected
        procedure AddConst(const Text: string); inline;
        procedure AddList(DbIdentType: TDbIdentType;
          const DatabaseName: string = ''; TableName: string = '');
        procedure AddTag(const KeywordIndex1: TWordList.TIndex;
          const KeywordIndex2: TWordList.TIndex = -1; const KeywordIndex3: TWordList.TIndex = -1;
          const KeywordIndex4: TWordList.TIndex = -1; const KeywordIndex5: TWordList.TIndex = -1;
          const KeywordIndex6: TWordList.TIndex = -1; const KeywordIndex7: TWordList.TIndex = -1);
        procedure AddText(const Text: string);
        procedure Clear();
      public
        procedure Cleanup();
        constructor Create(const AParser: TSQLParser);
        procedure Delete(const Index: Integer);
        destructor Destroy(); override;
        property Count: Integer read FCount;
        property Items[Index: Integer]: PItem read GetItem; default;
        property Parser: TSQLParser read FParser;
      end;

      { Base nodes ------------------------------------------------------------}

      PToken = ^TToken;

      PNode = ^TNode;
      TNode = packed record
      private
        FNodeType: TNodeType;
        FParser: TSQLParser;
      private
        class function Create(const AParser: TSQLParser; const ANodeType: TNodeType): TOffset; static; {$IFNDEF Debug} inline; {$ENDIF}
        function GetFirstToken(): PToken;
        function GetLastToken(): PToken;
        function GetOffset(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
        function GetText(): string;
        property Offset: TOffset read GetOffset;
      public
        property FirstToken: PToken read GetFirstToken;
        property LastToken: PToken read GetLastToken;
        property NodeType: TNodeType read FNodeType;
        property Parser: TSQLParser read FParser;
        property Text: string read GetText;
      end;

      PChild = ^TChild;
      TChild = packed record  // Every node, except TRoot
      private
        Heritage: TNode;
      private
        FParentNode: TOffset;
        class function Create(const AParser: TSQLParser; const ANodeType: TNodeType): TOffset; static; {$IFNDEF Debug} inline; {$ENDIF}
        function GetParentNode(): PNode; {$IFNDEF Debug} inline; {$ENDIF}
        property Parser: TSQLParser read Heritage.FParser;
      public
        property NodeType: TNodeType read Heritage.FNodeType;
        property ParentNode: PNode read GetParentNode;
      end;

      TToken = packed record
      private
        Heritage: TChild;
      private
        {$IFDEF Debug}
        FIndex: Integer;
        {$ENDIF}
        FIsUsed: Boolean;
        FKeywordIndex: TWordList.TIndex;
        FLength: Integer;
        FOperatorType: TOperatorType;
        FText: PChar;
        FTokenType: TTokenType;
        FUsageType: TUsageType;
        class function Create(const AParser: TSQLParser;
          const AText: PChar; const ALength: Integer;
          const ATokenType: TTokenType; const AOperatorType: TOperatorType;
          const AKeywordIndex: TWordList.TIndex; const AIsUsed: Boolean
          {$IFDEF Debug}; const AIndex: Integer {$ENDIF}): TOffset; static; {$IFNDEF Debug} inline; {$ENDIF}
        function GetAsString(): string;
        function GetDbIdentType(): TDbIdentType;
        {$IFNDEF Debug}
        function GetIndex(): Integer;
        {$ENDIF}
        function GetNextToken(): PToken;
        function GetNextTokenAll(): PToken;
        function GetOffset(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
        function GetParentNode(): PNode; {$IFNDEF Debug} inline; {$ENDIF}
        function GetPos(): Integer; {$IFNDEF Debug} inline; {$ENDIF}
        function GetText(): string; overload;
        procedure GetText(out Text: PChar; out Length: Integer); overload;
        {$IFDEF Debug}
        property Index: Integer read FIndex;
        {$ELSE}
        property Index: Integer read GetIndex; // VERY slow.
        {$ENDIF}
        property IsUsed: Boolean read FIsUsed;
        property KeywordIndex: TWordList.TIndex read FKeywordIndex;
        property Length: Integer read FLength;
        property Offset: TOffset read GetOffset;
        property Parser: TSQLParser read Heritage.Heritage.FParser;
      public
        property AsString: string read GetAsString;
        property DbIdentType: TDbIdentType read GetDbIdentType;
        property NextToken: PToken read GetNextToken;
        property NextTokenAll: PToken read GetNextTokenAll;
        property OperatorType: TOperatorType read FOperatorType;
        property ParentNode: PNode read GetParentNode;
        property Pos: Integer read GetPos;
        property Text: string read GetText;
        property TokenType: TTokenType read FTokenType write FTokenType;
        property UsageType: TUsageType read FUsageType;
      end;

      PRange = ^TRange;
      TRange = packed record
      private
        Heritage: TChild;
        property FParentNode: TOffset read Heritage.FParentNode write Heritage.FParentNode;
      private
        FFirstToken: TOffset; // Cache for speeding
        FLastToken: TOffset; // Cache for speeding
        class function Create(const AParser: TSQLParser; const ANodeType: TNodeType): TOffset; static; {$IFNDEF Debug} inline; {$ENDIF}
        function GetFirstToken(): PToken; {$IFNDEF Debug} inline; {$ENDIF}
        function GetLastToken(): PToken; {$IFNDEF Debug} inline; {$ENDIF}
        function GetOffset(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
        function GetParentNode(): PNode; {$IFNDEF Debug} inline; {$ENDIF}
        function GetText(): string; {$IFNDEF Debug} inline; {$ENDIF}
        procedure AddChildren(const Count: Integer; const Children: POffsetArray);
        property Offset: TOffset read GetOffset;
        property Parser: TSQLParser read Heritage.Heritage.FParser;
      public
        property FirstToken: PToken read GetFirstToken;
        property LastToken: PToken read GetLastToken;
        property NodeType: TNodeType read Heritage.Heritage.FNodeType;
        property ParentNode: PNode read GetParentNode;
        property Text: string read GetText;
      end;

      PStmt = ^TStmt;
      TStmt = packed record
      private
        Heritage: TRange;
        property FFirstToken: TOffset read Heritage.FFirstToken write Heritage.FFirstToken;
      private
        Error: TError;
        class function Create(const AParser: TSQLParser; const AStmtType: TStmtType): TOffset; static;
        function GetDelimiter(): PToken; {$IFNDEF Debug} inline; {$ENDIF}
        function GetErrorMessage(): string; {$IFNDEF Debug} inline; {$ENDIF}
        function GetErrorToken(): PToken; {$IFNDEF Debug} inline; {$ENDIF}
        function GetFirstToken(): PToken; {$IFNDEF Debug} inline; {$ENDIF}
        function GetLastToken(): PToken; {$IFNDEF Debug} inline; {$ENDIF}
        function GetNextStmt(): PStmt;
        function GetStmtType(): TStmtType; {$IFNDEF Debug} inline; {$ENDIF}
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      public
        property Delimiter: PToken read GetDelimiter;
        property ErrorCode: Byte read Error.Code;
        property ErrorMessage: string read GetErrorMessage;
        property ErrorToken: PToken read GetErrorToken;
        property FirstToken: PToken read GetFirstToken;
        property LastToken: PToken read GetLastToken;
        property NextStmt: PStmt read GetNextStmt;
        property StmtType: TStmtType read GetStmtType;
      end;

      { Normal nodes ----------------------------------------------------------}

    protected type
      PAccount = ^TAccount;
      TAccount = packed record
      private type
        TNodes = packed record
          UserIdent: TOffset;
          AtToken: TOffset;
          HostIdent: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PAnalyzeTableStmt = ^TAnalyzeTableStmt;
      TAnalyzeTableStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          NoWriteToBinlogTag: TOffset;
          TableTag: TOffset;
          TablesList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PAlterDatabaseStmt = ^TAlterDatabaseStmt;
      TAlterDatabaseStmt = packed record
      private type
        TNodes = packed record
          AlterTag: TOffset;
          DatabaseTag: TOffset;
          Ident: TOffset;
          CharsetValue: TOffset;
          CollateValue: TOffset;
          UpgradeDataDirectoryNameTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PAlterEventStmt = ^TAlterEventStmt;
      TAlterEventStmt = packed record
      private type
        TNodes = packed record
          AlterTag: TOffset;
          DefinerValue: TOffset;
          EventTag: TOffset;
          EventIdent: TOffset;
          OnSchedule: packed record
            Tag: TOffset;
            Value: TOffset;
          end;
          OnCompletionTag: TOffset;
          RenameValue: TOffset;
          EnableTag: TOffset;
          CommentValue: TOffset;
          DoTag: TOffset;
          Stmt: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PAlterInstanceStmt = ^TAlterInstanceStmt;
      TAlterInstanceStmt = packed record
      private type
        TNodes = packed record
          AlterTag: TOffset;
          Tag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PAlterRoutineStmt = ^TAlterRoutineStmt;
      TAlterRoutineStmt = packed record
      private type
        TNodes = packed record
          AlterTag: TOffset;
          RoutineTag: TOffset;
          Ident: TOffset;
          CommentValue: TOffset;
          LanguageTag: TOffset;
          DeterministicTag: TOffset;
          NatureOfDataTag: TOffset;
          SQLSecurityTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        FRoutineType: TRoutineType;
        class function Create(const AParser: TSQLParser; const ARoutineType: TRoutineType; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
        property RoutineType: TRoutineType read FRoutineType;
      end;

      PAlterServerStmt = ^TAlterServerStmt;
      TAlterServerStmt = packed record
      private type
        TNodes = packed record
          AlterTag: TOffset;
          ServerTag: TOffset;
          Ident: TOffset;
          Options: packed record
            Tag: TOffset;
            List: TOffset;
          end;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PAlterTablespaceStmt = ^TAlterTablespaceStmt;
      TAlterTablespaceStmt = packed record
      private type
        TNodes = packed record
          AlterTag: TOffset;
          TablespaceTag: TOffset;
          Ident: TOffset;
          AddDatafileValue: TOffset;
          InitialSizeValue: TOffset;
          EngineValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PAlterTableStmt = ^TAlterTableStmt;
      TAlterTableStmt = packed record
      private type

        PAddField = ^TAddField;
        TAddField = packed record
        private type
          TNodes = packed record
            AddTag: TOffset;
            ColumnTag: TOffset;
            OldIdent: TOffset;
            Definition: TOffset;
            Position: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PAddFields = ^TAddFields;
        TAddFields = packed record
        private type
          TNodes = packed record
            AddTag: TOffset;
            ColumnTag: TOffset;
            DefinitionList: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PAlterField = ^TAlterField;
        TAlterField = packed record
        private type
          TNodes = packed record
            AlterTag: TOffset;
            ColumnTag: TOffset;
            Ident: TOffset;
            SetDefaultValue: TOffset;
            DropDefaultTag: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PConvertTo = ^TConvertTo;
        TConvertTo = packed record
        private type
          TNodes = packed record
            ConvertToTag: TOffset;
            CharsetValue: TOffset;
            CollateValue: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PDropObject = ^TDropObject;
        TDropObject = packed record
        private type
          TNodes = packed record
            DropTag: TOffset;
            ItemTypeTag: TOffset;
            Ident: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PExchangePartition = ^TExchangePartition;
        TExchangePartition = packed record
        private type
          TNodes = packed record
            ExchangePartitionTag: TOffset;
            PartitionIdent: TOffset;
            WithTableTag: TOffset;
            TableIdent: TOffset;
            WithValidationTag: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        POrderBy = ^TOrderBy;
        TOrderBy = packed record
        private type
          TNodes = packed record
            Tag: TOffset;
            List: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PReorganizePartition = ^TReorganizePartition;
        TReorganizePartition = packed record
        private type
          TNodes = packed record
            ReorganizePartitionTag: TOffset;
            IdentList: TOffset;
            IntoTag: TOffset;
            PartitionList: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          AlterTag: TOffset;
          IgnoreTag: TOffset;
          TableTag: TOffset;
          Ident: TOffset;
          SpecificationList: TOffset;
          AlgorithmValue: TOffset;
          ConvertToCharacterSetNode: TOffset;
          DiscardTablespaceTag: TOffset;
          EnableKeys: TOffset;
          ForceTag: TOffset;
          ImportTablespaceTag: TOffset;
          LockValue: TOffset;
          OrderByValue: TOffset;
          RenameNode: TOffset;
          PartitionOptions: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PAlterViewStmt = ^TAlterViewStmt;
      TAlterViewStmt = packed record
      private type
        TNodes = packed record
          AlterTag: TOffset;
          AlgorithmValue: TOffset;
          DefinerValue: TOffset;
          SQLSecurityTag: TOffset;
          ViewTag: TOffset;
          Ident: TOffset;
          Columns: TOffset;
          AsTag: TOffset;
          SelectStmt: TOffset;
          OptionTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PBeginLabel = ^TBeginLabel;
      TBeginLabel = packed record
      private type
        TNodes = packed record
          BeginToken: TOffset;
          ColonToken: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        function GetLabelName(): string;
      public
        property LabelName: string read GetLabelName;
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PBeginStmt = ^TBeginStmt;
      TBeginStmt = packed record
      private type
        TNodes = packed record
          BeginTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PBetweenOp = ^TBetweenOp;
      TBetweenOp = packed record
      private type
        TNodes = packed record
          Expr: TOffset;
          NotToken: TOffset;
          BetweenToken: TOffset;
          Min: TOffset;
          AndToken: TOffset;
          Max: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const AExpr, ANotToken, ABetweenToken, AMin, AAndToken, AMax: TOffset): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PBinaryOp = ^TBinaryOp;
      TBinaryOp = packed record
      private type
        TNodes = packed record
          OperatorToken: TOffset;
          Operand: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const AOperator, AOperand: TOffset): TOffset; static;
        function GetOperatorType(): TOperatorType; {$IFNDEF Debug} inline; {$ENDIF}
      public
        property OperatorType: TOperatorType read GetOperatorType;
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PCallStmt = ^TCallStmt;
      TCallStmt = packed record
      private type
        TNodes = packed record
          CallTag: TOffset;
          Ident: TOffset;
          ParamList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCaseOp = ^TCaseOp;
      TCaseOp = packed record
      private type

        PBranch = ^TBranch;
        TBranch = packed record
        private type
          TNodes = packed record
            WhenTag: TOffset;
            CondExpr: TOffset;
            ThenTag: TOffset;
            ResultExpr: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          CaseTag: TOffset;
          CompareExpr: TOffset;
          BranchList: TOffset;
          ElseTag: TOffset;
          ElseExpr: TOffset;
          EndTag: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PCaseStmt = ^TCaseStmt;
      TCaseStmt = packed record
      private type

        PBranch = ^TBranch;
        TBranch = packed record
        private type
          TNodes = packed record
            BranchTag: TOffset;
            ConditionExpr: TOffset;
            ThenTag: TOffset;
            StmtList: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          CaseTag: TOffset;
          CompareExpr: TOffset;
          BranchList: TOffset;
          EndTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCastFunc = ^TCastFunc;
      TCastFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          Expr: TOffset;
          AsTag: TOffset;
          DatatypeIdent: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PChangeMasterStmt = ^TChangeMasterStmt;
      TChangeMasterStmt = packed record
      private type
        TOptionNodes = packed record
          MasterBindValue: TOffset;
          MasterHostValue: TOffset;
          MasterUserValue: TOffset;
          MasterPasswordValue: TOffset;
          MasterPortValue: TOffset;
          MasterConnectRetryValue: TOffset;
          MaysterRetryCountValue: TOffset;
          MasterDelayValue: TOffset;
          MasterHeartbeatPeriodValue: TOffset;
          MasterLogFileValue: TOffset;
          MasterLogPosValue: TOffset;
          MasterAutoPositionValue: TOffset;
          RelayLogFileValue: TOffset;
          RelayLogPosValue: TOffset;
          MasterSSLValue: TOffset;
          MasterSSLCAValue: TOffset;
          MasterSSLCaPathValue: TOffset;
          MasterSSLCertValue: TOffset;
          MasterSSLCRLValue: TOffset;
          MasterSSLCRLPathValue: TOffset;
          MasterSSLKeyValue: TOffset;
          MasterSSLCipherValue: TOffset;
          MasterSSLVerifyServerCertValue: TOffset;
          MasterTLSVersionValue: TOffset;
          IgnoreServerIDsValue: TOffset;
        end;
        TNodes = packed record
          StmtTag: TOffset;
          ToTag: TOffset;
          OptionList: TOffset;
          ChannelOptionValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCharFunc = ^TCharFunc;
      TCharFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          ValueExpr: TOffset;
          UsingTag: TOffset;
          CharsetIdent: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PChecksumTableStmt = ^TChecksumTableStmt;
      TChecksumTableStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          TablesList: TOffset;
          OptionTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCheckTableStmt = ^TCheckTableStmt;
      TCheckTableStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          TablesList: TOffset;
          ForUpdateTag: TOffset;
          QuickTag: TOffset;
          FastTag: TOffset;
          MediumTag: TOffset;
          ExtendedTag: TOffset;
          ChangedTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCloseStmt = ^TCloseStmt;
      TCloseStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCommitStmt = ^TCommitStmt;
      TCommitStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          ChainTag: TOffset;
          ReleaseTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCompoundStmt = ^TCompoundStmt;
      TCompoundStmt = packed record
      private type
        TNodes = packed record
          BeginLabel: TOffset;
          BeginTag: TOffset;
          StmtList: TOffset;
          EndTag: TOffset;
          EndLabel: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PConvertFunc = ^TConvertFunc;
      TConvertFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          Expr: TOffset;
          Comma: TOffset;
          Datatype: TOffset;
          UsingTag: TOffset;
          CharsetIdent: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PCountFunc = ^TCountFunc;
      TCountFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          DistinctTag: TOffset;
          ExprNode: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PCreateDatabaseStmt = ^TCreateDatabaseStmt;
      TCreateDatabaseStmt = packed record
      private type
        TNodes = packed record
          CreateTag: TOffset;
          OrReplaceTag: TOffset;
          DatabaseTag: TOffset;
          IfNotExistsTag: TOffset;
          DatabaseIdent: TOffset;
          CharacterSetValue: TOffset;
          CollateValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCreateEventStmt = ^TCreateEventStmt;
      TCreateEventStmt = packed record
      private type
        TNodes = packed record
          CreateTag: TOffset;
          OrReplaceTag: TOffset;
          DefinerValue: TOffset;
          EventTag: TOffset;
          IfNotExistsTag: TOffset;
          EventIdent: TOffset;
          OnScheduleValue: TOffset;
          OnCompletitionTag: TOffset;
          EnableTag: TOffset;
          CommentValue: TOffset;
          DoTag: TOffset;
          Stmt: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCreateIndexStmt = ^TCreateIndexStmt;
      TCreateIndexStmt = packed record
      private type
        TNodes = packed record
          CreateTag: TOffset;
          OrReplaceTag: TOffset;
          KindTag: TOffset;
          IndexTag: TOffset;
          IfNotExistsTag: TOffset;
          Ident: TOffset;
          OnTag: TOffset;
          TableIdent: TOffset;
          IndexTypeValue: TOffset;
          KeyColumnList: TOffset;
          AlgorithmLockValue: TOffset;
          CommentValue: TOffset;
          KeyBlockSizeValue: TOffset;
          ParserValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCreateRoutineStmt = ^TCreateRoutineStmt;
      TCreateRoutineStmt = packed record
      private type
        TNodes = packed record
          CreateTag: TOffset;
          OrReplaceTag: TOffset;
          DefinerNode: TOffset;
          RoutineTag: TOffset;
          Ident: TOffset;
          ParameterList: TOffset;
          Returns: TOffset;
          CommentValue: TOffset;
          LanguageTag: TOffset;
          DeterministicTag: TOffset;
          NatureOfDataTag: TOffset;
          SQLSecurityTag: TOffset;
          Stmt: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        FRoutineType: TRoutineType;
        class function Create(const AParser: TSQLParser; const ARoutineType: TRoutineType; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
        property RoutineType: TRoutineType read FRoutineType;
      end;

      PCreateServerStmt = ^TCreateServerStmt;
      TCreateServerStmt = packed record
      private type
        TNodes = packed record
          CreateTag: TOffset;
          ServerTag: TOffset;
          Ident: TOffset;
          ForeignDataWrapperValue: TOffset;
          Options: packed record
            Tag: TOffset;
            List: TOffset;
          end;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCreateTablespaceStmt = ^TCreateTablespaceStmt;
      TCreateTablespaceStmt = packed record
      private type
        TNodes = packed record
          CreateTag: TOffset;
          TablespaceTag: TOffset;
          Ident: TOffset;
          AddDatafileValue: TOffset;
          FileBlockSizeValue: TOffset;
          EngineValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCreateTableStmt = ^TCreateTableStmt;
      TCreateTableStmt = packed record
      private type

        TFieldAddType = (fatNone, fatAdd, fatChange, fatModify);

        PCheck = ^TCheck;
        TCheck = packed record
        private type
          TNodes = packed record
            CheckTag: TOffset;
            ExprList: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PField = ^TField;
        TField = packed record
        private type

          POnUpdate = ^TOnUpdate;
          TOnUpdate = packed record
          private type
            TNodes = packed record
              OnUpdateTag: TOffset;
              Expr: TOffset;
            end;
          private
            Heritage: TRange;
          private
            Nodes: TNodes;
            class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
          public
            property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
          end;

          TNodes = packed record
            Ident: TOffset;
            Datatype: TOffset;
            Real: packed record
              Default: packed record
                Tag: TOffset;
                Expr: TOffset;
              end;
              OnUpdate: TOffset;
              AutoIncrementTag: TOffset;
              ColumnFormat: TOffset;
              StorageTag: TOffset;
              Reference: TOffset;
            end;
            Virtual: packed record
              GernatedAlwaysTag: TOffset;
              AsTag: TOffset;
              Expr: TOffset;
              Virtual: TOffset;
            end;
            NullTag: TOffset;
            KeyTag: TOffset;
            CommentValue: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PForeignKey = ^TForeignKey;
        TForeignKey = packed record
        private type
          TNodes = packed record
            AddTag: TOffset;
            ConstraintTag: TOffset;
            ConstraintIdent: TOffset;
            ForeignKeyTag: TOffset;
            NameIdent: TOffset;
            ColumnNameList: TOffset;
            Reference: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PKey = ^TKey;
        TKey = packed record
        private type
          TNodes = packed record
            AddTag: TOffset;
            ConstraintTag: TOffset;
            ConstraintIdent: TOffset;
            KeyTag: TOffset;
            KeyIdent: TOffset;
            IndexTypeTag: TOffset;
            KeyColumnList: TOffset;
            KeyBlockSizeValue: TOffset;
            WithParserValue: TOffset;
            CommentValue: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PKeyColumn = ^TKeyColumn;
        TKeyColumn = packed record
        private type
          TNodes = packed record
            IdentTag: TOffset;
            OpenBracket: TOffset;
            LengthToken: TOffset;
            CloseBracket: TOffset;
            SortTag: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PPartition = ^TPartition;
        TPartition = packed record
        private type
          TNodes = packed record
            AddTag: TOffset;
            PartitionTag: TOffset;
            NameIdent: TOffset;
            Values: packed record
              Tag: TOffset;
              Value: TOffset;
            end;
            EngineValue: TOffset;
            CommentValue: TOffset;
            DataDirectoryValue: TOffset;
            IndexDirectoryValue: TOffset;
            MaxRowsValue: TOffset;
            MinRowsValue: TOffset;
            SubPartitionList: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PPartitionOptions = ^TPartitionOptions;
        TPartitionOptions = packed record
        private type
          TNodes = packed record
            Tag: TOffset;
            KindTag: TOffset;
            AlgorithmValue: TOffset;
            Expr: TOffset;
            Columns: packed record
              Tag: TOffset;
              List: TOffset;
            end;
            PartitionCount: TOffset;
            SubPartition: packed record
              Tag: TOffset;
              KindTag: TOffset;
              Expr: TOffset;
              AlgorithmValue: TOffset;
              ColumnList: TOffset;
              Value: TOffset;
            end;
            DefinitionList: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PReference = ^TReference;
        TReference = packed record
        private type
          TNodes = packed record
            Tag: TOffset;
            ParentTableIdent: TOffset;
            FieldList: TOffset;
            MatchTag: TOffset;
            OnDeleteTag: TOffset;
            OnUpdateTag: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          CreateTag: TOffset;
          OrReplaceTag: TOffset;
          TemporaryTag: TOffset;
          TableTag: TOffset;
          IfNotExistsTag: TOffset;
          TableIdent: TOffset;
          DefinitionList: TOffset;
          TableOptionList: TOffset;
          PartitionOptions: TOffset;
          Like: packed record
            OpenBracket: TOffset;
            Tag: TOffset;
            TableIdent: TOffset;
            CloseBracket: TOffset;
          end;
          IgnoreReplaceTag: TOffset;
          AsTag: TOffset;
          SelectStmt2: TOffset;
        end;

      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCreateTriggerStmt = ^TCreateTriggerStmt;
      TCreateTriggerStmt = packed record
      private type
        TNodes = packed record
          CreateTag: TOffset;
          OrReplaceTag: TOffset;
          DefinerNode: TOffset;
          TriggerTag: TOffset;
          IfNotExistsTag: TOffset;
          Ident: TOffset;
          TimeTag: TOffset;
          EventTag: TOffset;
          OnTag: TOffset;
          TableIdent: TOffset;
          ForEachRowTag: TOffset;
          OrderValue: TOffset;
          Stmt: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCreateUserStmt = ^TCreateUserStmt;
      TCreateUserStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          OrReplaceTag: TOffset;
          UserTag: TOffset;
          IfNotExistsTag: TOffset;
          UserSpecifications: TOffset;
          WithTag: TOffset;
          MaxQueriesPerHour: TOffset;
          MaxUpdatesPerHour: TOffset;
          MaxConnectionsPerHour: TOffset;
          MaxUserConnections: TOffset;
          PasswordOption: record
            Tag: TOffset;
            QuantityInt: TOffset;
            UnitTag: TOffset;
          end;
          AccountTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PCreateViewStmt = ^TCreateViewStmt;
      TCreateViewStmt = packed record
      private type
        TNodes = packed record
          CreateTag: TOffset;
          OrReplaceTag: TOffset;
          AlgorithmValue: TOffset;
          DefinerValue: TOffset;
          SQLSecurityTag: TOffset;
          ViewTag: TOffset;
          IfNotExistsTag: TOffset;
          Ident: TOffset;
          FieldList: TOffset;
          AsTag: TOffset;
          SelectStmt: TOffset;
          OptionTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDatatype = ^TDatatype;
      TDatatype = packed record
      private type
        TNodes = packed record
          NationalToken: TOffset;
          SignedToken: TOffset;
          PreDatatypeToken: TOffset;
          DatatypeToken: TOffset;
          OpenBracket: TOffset;
          LengthToken: TOffset;
          CommaToken: TOffset;
          DecimalsToken: TOffset;
          CloseBracket: TOffset;
          ItemList: TOffset;
          ZerofillTag: TOffset;
          CharacterSetValue: TOffset;
          CollateValue: TOffset;
          BinaryToken: TOffset;
          ASCIIToken: TOffset;
          UnicodeToken: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PDateAddFunc = ^TDateAddFunc;
      TDateAddFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          DateExpr: TOffset;
          CommaToken: TOffset;
          IntervalExpr: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PDbIdent = ^TDbIdent;
      TDbIdent = packed record
      private type
        TNodes = packed record
          Ident: TOffset;
          DatabaseDot: TOffset;
          DatabaseIdent: TOffset;
          TableDot: TOffset;
          TableIdent: TOffset;
        end;
      private
        Heritage: TRange;
      private
        FDbIdentType: TDbIdentType;
        FDbTableType: TDbIdentType;
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ADbIdentType: TDbIdentType; const ANodes: TNodes): TOffset; overload; static;
        function GetDatabaseIdent(): PToken; {$IFNDEF Debug} inline; {$ENDIF}
        function GetIdent(): PToken; {$IFNDEF Debug} inline; {$ENDIF}
        function GetParentNode(): PNode; {$IFNDEF Debug} inline; {$ENDIF}
        function GetTableIdent(): PToken; {$IFNDEF Debug} inline; {$ENDIF}
      public
        property DatabaseIdent: PToken read GetDatabaseIdent;
        property DbIdentType: TDbIdentType read FDbIdentType;
        property Ident: PToken read GetIdent;
        property ParentNode: PNode read GetParentNode;
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        property TableIdent: PToken read GetTableIdent;
      end;

      PDeallocatePrepareStmt = ^TDeallocatePrepareStmt;
      TDeallocatePrepareStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDeclareStmt = ^TDeclareStmt;
      TDeclareStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IdentList: TOffset;
          TypeNode: TOffset;
          DefaultValue: TOffset;
          CursorForTag: TOffset;
          SelectStmt: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDeclareConditionStmt = ^TDeclareConditionStmt;
      TDeclareConditionStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IdentList: TOffset;
          ConditionTag: TOffset;
          ForTag: TOffset;
          ErrorCode: TOffset;
          SQLStateTag: TOffset;
          ErrorString: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDeclareCursorStmt = ^TDeclareCursorStmt;
      TDeclareCursorStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IdentList: TOffset;
          CursorTag: TOffset;
          SelectStmt: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDeclareHandlerStmt = ^TDeclareHandlerStmt;
      TDeclareHandlerStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          ActionTag: TOffset;
          HandlerTag: TOffset;
          ForTag: TOffset;
          ConditionsList: TOffset;
          Stmt: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDefaultFunc = ^TDefaultFunc;
      TDefaultFunc = packed record
      private type
        TNodes = packed record
          Ident: TOffset;
          ArgumentsList: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const AIdent, AArgumentsList: TOffset): TOffset; overload; static;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; overload; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PDeleteStmt = ^TDeleteStmt;
      TDeleteStmt = packed record
      private type
        TNodes = packed record
          DeleteTag: TOffset;
          LowPriorityTag: TOffset;
          QuickTag: TOffset;
          IgnoreTag: TOffset;
          From1: packed record
            Tag: TOffset;
            List: TOffset;
          end;
          Partition: packed record
            Tag: TOffset;
            List: TOffset;
          end;
          Using: packed record
            Tag: TOffset;
            TableReferenceList: TOffset;
          end;
          From2: packed record
            Tag: TOffset;
            TableReferenceList: TOffset;
          end;
          Where: packed record
            Tag: TOffset;
            Expr: TOffset;
          end;
          OrderBy: packed record
            Tag: TOffset;
            List: TOffset;
          end;
          Limit: packed record
            Tag: TOffset;
            Token: TOffset;
          end;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDoStmt = ^TDoStmt;
      TDoStmt = packed record
      private type
        TNodes = packed record
          DoTag: TOffset;
          ExprList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDropDatabaseStmt = ^TDropDatabaseStmt;
      TDropDatabaseStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IfExistsTag: TOffset;
          DatabaseIdent: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDropEventStmt = ^TDropEventStmt;
      TDropEventStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IfExistsTag: TOffset;
          EventIdent: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDropIndexStmt = ^TDropIndexStmt;
      TDropIndexStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IndexIdent: TOffset;
          OnTag: TOffset;
          TableIdent: TOffset;
          AlgorithmValue: TOffset;
          LockValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDropRoutineStmt = ^TDropRoutineStmt;
      TDropRoutineStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IfExistsTag: TOffset;
          RoutineIdent: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        FRoutineType: TRoutineType;
        class function Create(const AParser: TSQLParser; const ARoutineType: TRoutineType; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
        property RoutineType: TRoutineType read FRoutineType;
      end;

      PDropServerStmt = ^TDropServerStmt;
      TDropServerStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IfExistsTag: TOffset;
          ServerIdent: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDropTablespaceStmt = ^TDropTablespaceStmt;
      TDropTablespaceStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
          EngineValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDropTableStmt = ^TDropTableStmt;
      TDropTableStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IfExistsTag: TOffset;
          TableIdentList: TOffset;
          RestrictCascadeTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDropTriggerStmt = ^TDropTriggerStmt;
      TDropTriggerStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IfExistsTag: TOffset;
          TriggerIdent: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDropUserStmt = ^TDropUserStmt;
      TDropUserStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IfExistsTag: TOffset;
          UserList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PDropViewStmt = ^TDropViewStmt;
      TDropViewStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IfExistsTag: TOffset;
          ViewIdentList: TOffset;
          RestrictCascadeTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PEndLabel = ^TEndLabel;
      TEndLabel = packed record
      private type
        TNodes = packed record
          LabelToken: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PExecuteStmt = ^TExecuteStmt;
      TExecuteStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          StmtVariable: TOffset;
          UsingTag: TOffset;
          VariableIdents: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PExplainStmt = ^TExplainStmt;
      TExplainStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          TableIdent: TOffset;
          FieldIdent: TOffset;
          ExplainType: TOffset;
          AssignToken: TOffset;
          FormatKeyword: TOffset;
          ExplainStmt: TOffset;
          ForConnectionValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PExtractFunc = ^TExtractFunc;
      TExtractFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          UnitTag: TOffset;
          FromTag: TOffset;
          QuantityExpr: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PFetchStmt = ^TFetchStmt;
      TFetchStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          NextTag: TOffset;
          FromTag: TOffset;
          Ident: TOffset;
          IntoTag: TOffset;
          VariableList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PFlushStmt = ^TFlushStmt;
      TFlushStmt = packed record
      private type

          POption = ^TOption;
          TOption = packed record
          private type

            PLogs = ^TLogs;
            TLogs = packed record
            private type
              TNodes = packed record
                LogTypeTag: TOffset;
                LogTag: TOffset;
                ChannelOptionValue: TOffset;
              end;
            private
              Heritage: TRange;
            private
              Nodes: TNodes;
              class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
            public
              property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
            end;

            TNodes = packed record
              OptionTag: TOffset;
              TablesList: TOffset;
            end;
          private
            Heritage: TRange;
          private
            Nodes: TNodes;
            class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
          public
            property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
          end;

        TNodes = packed record
          StmtTag: TOffset;
          NoWriteToBinLogTag: TOffset;
          OptionList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PFunctionReturns = ^TFunctionReturns;
      TFunctionReturns = packed record
      private type
        TNodes = packed record
          ReturnsTag: TOffset;
          DatatypeNode: TOffset;
          CharsetValue: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PGetDiagnosticsStmt = ^TGetDiagnosticsStmt;
      TGetDiagnosticsStmt = packed record
      private type

        PStmtInfo = ^TStmtInfo;
        TStmtInfo = packed record
        private type
          TNodes = packed record
            Target: TOffset;
            EqualOp: TOffset;
            ItemTag: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PCondInfo = ^TCondInfo;
        TCondInfo = packed record
        private type
          TNodes = packed record
            Target: TOffset;
            EqualOp: TOffset;
            ItemTag: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          StmtTag: TOffset;
          ScopeTag: TOffset;
          DiagnosticsTag: TOffset;
          ConditionTag: TOffset;
          ConditionNumber: TOffset;
          InfoList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PGrantStmt = ^TGrantStmt;
      TGrantStmt = packed record
      private type

        PPrivileg = ^TPrivileg;
        TPrivileg = packed record
        private type
          TNodes = packed record
            PrivilegTag: TOffset;
            ColumnList: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PUserSpecification = ^TUserSpecification;
        TUserSpecification = packed record
        private type
          TNodes = packed record
            UserIdent: TOffset;
            IdentifiedToken: TOffset;
            PluginIdent: TOffset;
            AsTag: TOffset;
            AuthString: TOffset;
            WithGrantOptionTag: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          StmtTag: TOffset;
          PrivilegesList: TOffset;
          OnTag: TOffset;
          OnUser: TOffset;
          ObjectTypeTag: TOffset;
          ObjectIdent: TOffset;
          ToTag: TOffset;
          UserSpecifications: TOffset;
          Require: packed record
            Tag: TOffset;
            Options: TOffset;
          end;
          WithTag: TOffset;
          GrantOptionTag: TOffset;
          MaxQueriesPerHourTag: TOffset;
          MaxUpdatesPerHourTag: TOffset;
          MaxConnectionsPerHourTag: TOffset;
          MaxUserConnectionsTag: TOffset;
          MaxStatementTimeTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PGroupConcatFunc = ^TGroupConcatFunc;
      TGroupConcatFunc = packed record
      private type

        PExpr = ^TExpr;
        TExpr = packed record
        private type
          TNodes = packed record
            Expr: TOffset;
            Direction: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          DistinctTag: TOffset;
          ExprList: TOffset;
          OrderBy: packed record
            Tag: TOffset;
            Expr: TOffset;
          end;
          SeparatorValue: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PHelpStmt = ^THelpStmt;
      THelpStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          HelpString: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PIfStmt = ^TIfStmt;
      TIfStmt = packed record
      private type

        PBranch = ^TBranch;
        TBranch = packed record
        private type
          TNodes = packed record
            BranchTag: TOffset;
            ConditionExpr: TOffset;
            ThenTag: TOffset;
            StmtList: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          BranchList: TOffset;
          EndTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PInOp = ^TInOp;
      TInOp = packed record
      private type
        TNodes = packed record
          Operand: TOffset;
          NotToken: TOffset;
          InToken: TOffset;
          List: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const AOperand, ANotToken, AInToken, AList: TOffset): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PInsertStmt = ^TInsertStmt;
      TInsertStmt = packed record
      private type

        PSetItem = ^TSetItem;
        TSetItem = packed record
        private type
          TNodes = packed record
            FieldToken: TOffset;
            AssignToken: TOffset;
            ValueNode: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          InsertTag: TOffset;
          PriorityTag: TOffset;
          IgnoreTag: TOffset;
          IntoTag: TOffset;
          TableIdent: TOffset;
          Partition: packed record
            Tag: TOffset;
            List: TOffset;
          end;
          ColumnList: TOffset;
          Values: packed record
            Tag: TOffset;
            List: TOffset;
          end;
          Set_: packed record
            Tag: TOffset;
            List: TOffset;
          end;
          SelectStmt: TOffset;
          OnDuplicateKeyUpdateTag: TOffset;
          UpdateList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PInstallPluginStmt = ^TInstallPluginStmt;
      TInstallPluginStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
          SonameTag: TOffset;
          NameString: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PIntervalOp = ^TIntervalOp;
      TIntervalOp = packed record
      private type
        TNodes = packed record
          IntervalTag: TOffset;
          QuantityExpr: TOffset;
          UnitTag: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      end;

      PIsOp = ^TIsOp;
      TIsOp = packed record
      private type
        TNodes = packed record
          Operand1: TOffset;
          IsToken: TOffset;
          NotToken: TOffset;
          Operand2: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const AOperand1, AIsToken, ANotToken, AOperand2: TOffset): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PIterateStmt = ^TIterateStmt;
      TIterateStmt = packed record
      private type
        TNodes = packed record
          IterateToken: TOffset;
          LabelToken: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PKillStmt = ^TKillStmt;
      TKillStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          ProcessIdToken: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PLeaveStmt = ^TLeaveStmt;
      TLeaveStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          LabelToken: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PLikeOp = ^TLikeOp;
      TLikeOp = packed record
      private type
        TNodes = packed record
          Operand1: TOffset;
          NotToken: TOffset;
          LikeToken: TOffset;
          Operand2: TOffset;
          EscapeToken: TOffset;
          EscapeCharToken: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const AOperand1, ANotToken, ALikeToken, AOperand2, AEscapeToken, AEscapeCharToken: TOffset): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PList = ^TList;
      TList = packed record
      private type
        TNodes = packed record
          OpenBracket: TOffset;
          FirstElement: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        FDelimiterType: TTokenType;
        FElementCount: Integer;
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser;
          const ANodes: TNodes; const ADelimiterType: TTokenType;
          const AChildren: POffsetList): TOffset; static;
        function GetFirstElement(): PChild; {$IFNDEF Debug} inline; {$ENDIF}
      public
        function GetDelimiter(const Child: PChild): PToken;
        function GetNextElement(const Child: PChild): PChild;
        property DelimiterType: TTokenType read FDelimiterType;
        property ElementCount: Integer read FElementCount;
        property FirstElement: PChild read GetFirstElement;
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PLoadDataStmt = ^TLoadDataStmt;
      TLoadDataStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          PriorityTag: TOffset;
          InfileTag: TOffset;
          FilenameString: TOffset;
          ReplaceIgnoreTag: TOffset;
          IntoTableTag: TOffset;
          Ident: TOffset;
          PartitionTag: TOffset;
          PartitionList: TOffset;
          CharacterSetValue: TOffset;
          ColumnsTag: TOffset;
          ColumnsTerminatedByValue: TOffset;
          EnclosedByValue: TOffset;
          EscapedByValue: TOffset;
          Lines: packed record
            Tag: TOffset;
            StartingByValue: TOffset;
            TerminatedByValue: TOffset;
          end;
          Ignore: packed record
            Tag: TOffset;
            NumberToken: TOffset;
            LinesTag: TOffset;
          end;
          ColumnList: TOffset;
          SetList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PLoadXMLStmt = ^TLoadXMLStmt;
      TLoadXMLStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          PriorityTag: TOffset;
          InfileTag: TOffset;
          FilenameString: TOffset;
          ReplaceIgnoreTag: TOffset;
          IntoTableValue: TOffset;
          CharacterSetValue: TOffset;
          RowsIdentifiedByValue: TOffset;
          Ignore: packed record
            Tag: TOffset;
            NumberToken: TOffset;
            LinesTag: TOffset;
          end;
          FieldList: TOffset;
          SetList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PLockTablesStmt = ^TLockTablesStmt;
      TLockTablesStmt = packed record
      private type

        PItem = ^TItem;
        TItem = packed record
        private type
          TNodes = packed record
            Ident: TOffset;
            AsTag: TOffset;
            AliasIdent: TOffset;
            LockTypeTag: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          LockTablesTag: TOffset;
          ItemList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PLoopStmt = ^TLoopStmt;
      TLoopStmt = packed record
      private type
        TNodes = packed record
          BeginLabel: TOffset;
          BeginTag: TOffset;
          StmtList: TOffset;
          EndTag: TOffset;
          EndLabel: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PMatchFunc = ^TMatchFunc;
      TMatchFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          MatchList: TOffset;
          AgainstTag: TOffset;
          OpenBracket: TOffset;
          Expr: TOffset;
          SearchModifierTag: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PPositionFunc = ^TPositionFunc;
      TPositionFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          SubStr: TOffset;
          InTag: TOffset;
          Str: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PPrepareStmt = ^TPrepareStmt;
      TPrepareStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          StmtIdent: TOffset;
          FromTag: TOffset;
          Stmt: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PPurgeStmt = ^TPurgeStmt;
      TPurgeStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          TypeTag: TOffset;
          LogsTag: TOffset;
          Value: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      POpenStmt = ^TOpenStmt;
      TOpenStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      POptimizeTableStmt = ^TOptimizeTableStmt;
      TOptimizeTableStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          OptionTag: TOffset;
          TableTag: TOffset;
          TablesList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PRegExpOp = ^TRegExpOp;
      TRegExpOp = packed record
      private type
        TNodes = packed record
          Operand1: TOffset;
          NotToken: TOffset;
          RegExpToken: TOffset;
          Operand2: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const AOperand1, ANotToken, ARegExpToken, AOperand2: TOffset): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PReleaseStmt = ^TReleaseStmt;
      TReleaseStmt = packed record
      private type
        TNodes = packed record
          ReleaseTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PRenameStmt = ^TRenameStmt;
      TRenameStmt = packed record
      private type

        PPair = ^TPair;
        TPair = packed record
        private type
          TNodes = packed record
            OrgNode: TOffset;
            ToTag: TOffset;
            NewNode: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          StmtTag: TOffset;
          RenameList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PRepairTableStmt = ^TRepairTableStmt;
      TRepairTableStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          OptionTag: TOffset;
          TableTag: TOffset;
          TablesList: TOffset;
          QuickTag: TOffset;
          ExtendedTag: TOffset;
          UseFrmTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PRepeatStmt = ^TRepeatStmt;
      TRepeatStmt = packed record
      private type
        TNodes = packed record
          BeginLabel: TOffset;
          RepeatTag: TOffset;
          StmtList: TOffset;
          UntilTag: TOffset;
          SearchConditionExpr: TOffset;
          EndTag: TOffset;
          EndLabel: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PResetStmt = ^TResetStmt;
      TResetStmt = packed record
      private type

        POption = ^TOption;
        TOption = packed record
        private type
          TNodes = packed record
            OptionTag: TOffset;
            ChannelValue: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          StmtTag: TOffset;
          OptionList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PReturnStmt = ^TReturnStmt;
      TReturnStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Expr: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PRevokeStmt = ^TRevokeStmt;
      TRevokeStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          PrivilegesList: TOffset;
          CommaToken: TOffset;
          GrantOptionTag: TOffset;
          OnTag: TOffset;
          AccountIdent: TOffset;
          ObjectTypeTag: TOffset;
          PrivLevelIdent: TOffset;
          FromTag: TOffset;
          UserIdentList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PRollbackStmt = ^TRollbackStmt;
      TRollbackStmt = packed record
      private type
        TNodes = packed record
          RollbackTag: TOffset;
          ToValue: TOffset;
          ChainTag: TOffset;
          ReleaseTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PRoot = ^TRoot;
      TRoot = packed record
      private type
        TNodes = packed record
          StmtList: TOffset;
        end;
      private
        Heritage: TNode;
      private
        FFirstTokenAll: TOffset;
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const AFirstTokenAll, AStmtList: TOffset): TOffset; static;
        function GetFirstStmt(): PStmt; {$IFNDEF Debug} inline; {$ENDIF}
        function GetFirstTokenAll(): PToken; {$IFNDEF Debug} inline; {$ENDIF}
        property Parser: TSQLParser read Heritage.FParser;
      public
        property FirstStmt: PStmt read GetFirstStmt;
        property FirstTokenAll: PToken read GetFirstTokenAll;
        property NodeType: TNodeType read Heritage.FNodeType;
      end;

      PRoutineParam = ^TRoutineParam;
      TRoutineParam = packed record
      private type
        TNodes = packed record
          DirektionTag: TOffset;
          IdentToken: TOffset;
          DatatypeNode: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PSavepointStmt = ^TSavepointStmt;
      TSavepointStmt = packed record
      private type
        TNodes = packed record
          SavepointTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PSchedule = ^TSchedule;
      TSchedule = packed record
      private type
        TNodes = packed record
          AtValue: TOffset;
          EveryTag: TOffset;
          QuantityExpr: TOffset;
          UnitTag: TOffset;
          StartsValue: TOffset;
          EndsValue: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PSecretIdent = ^TSecretIdent;
      TSecretIdent = packed record
      private type
        TNodes = packed record
          OpenAngleBracket: TOffset;
          ItemToken: TOffset;
          CloseAngleBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PSelectStmt = ^TSelectStmt;
      TSelectStmt = packed record
      private type

        PColumn = ^TColumn;
        TColumn = packed record
        private type
          TNodes = packed record
            Expr: TOffset;
            AsTag: TOffset;
            AliasIdent: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PTableFactor = ^TTableFactor;
        TTableFactor = packed record
        private type

          PIndexHint = ^TIndexHint;
          TIndexHint = packed record
          public type
            TNodes = record
              HintTag: TOffset;
              ForTag: TOffset;
              IndexList: TOffset;
            end;
          private
            Heritage: TRange;
          private
            Nodes: TNodes;
            class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
          public
            property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
          end;

          TNodes = packed record
            Ident: TOffset;
            PartitionTag: TOffset;
            Partitions: TOffset;
            AsTag: TOffset;
            AliasIdent: TOffset;
            IndexHintList: TOffset;
            SelectStmt: TOffset;
          end;

        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PTableJoin = ^TTableJoin;
        TTableJoin = packed record
        private type
          TNodes = packed record
            JoinTag: TOffset;
            RightTable: TOffset;
            OnTag: TOffset;
            OnExpr: TOffset;
          end;
          TKeywordTokens = array [0..3] of Integer;
        private
          Heritage: TRange;
        private
          FJoinType: TJoinType;
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const AJoinType: TJoinType; const ANodes: TNodes): TOffset; static;
        public
          property JoinType: TJoinType read FJoinType;
        end;

        PTableFactorOj = ^TTableFactorOj;
        TTableFactorOj = packed record
        private type
          TNodes = packed record
            OpenBracket: TOffset;
            OjTag: TOffset;
            TableReference: TOffset;
            CloseBracket: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PTableFactorSubquery = ^TTableFactorSubquery;
        TTableFactorSubquery = packed record
        private type
          TNodes = packed record
            SelectStmt: TOffset;
            AsTag: TOffset;
            AliasIdent: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PGroup = ^TGroup;
        TGroup = packed record
        private type
          TNodes = packed record
            Expr: TOffset;
            DirectionTag: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        PLimit = ^TLimit;
        TLimit = packed record
        private type
          TNodes = packed record
            Tag: TOffset;
            OffsetTag: TOffset;
            OffsetToken: TOffset;
            CommaToken: TOffset;
            RowCountToken: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        POrder = ^TOrder;
        TOrder = packed record
        private type
          TNodes = packed record
            Expr: TOffset;
            DirectionTag: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        POrderBy = ^TOrderBy;
        TOrderBy = packed record
        private type
          TNodes = packed record
            Tag: TOffset;
            List: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TIntoNodes = packed record
          Tag: TOffset;
          Filename: TOffset;
          CharacterSetValue: TOffset;
          VariableList: TOffset;
          Fields: packed record
            Tag: TOffset;
            TerminatedByString: TOffset;
            EnclosedByString: TOffset;
            EscapedByString: TOffset;
          end;
          Lines: packed record
            Tag: TOffset;
            StartingByString: TOffset;
            TerminatedByString: TOffset;
          end;
        end;

        TNodes = packed record
          OpenBrackets: TOffset;
          SelectTag: TOffset;
          DistinctTag: TOffset;
          HighPriorityTag: TOffset;
          MaxStatementTime: TOffset;
          StraightJoinTag: TOffset;
          SQLSmallResultTag: TOffset;
          SQLBigResultTag: TOffset;
          SQLBufferResultTag: TOffset;
          SQLNoCacheTag: TOffset;
          SQLCalcFoundRowsTag: TOffset;
          ColumnsList: TOffset;
          Into1: TIntoNodes;
          From: packed record
            Tag: TOffset;
            TableReferenceList: TOffset;
          end;
          Partition: packed record
            Tag: TOffset;
            Ident: TOffset;
          end;
          Where: packed record
            Tag: TOffset;
            Expr: TOffset;
          end;
          GroupBy: packed record
            Tag: TOffset;
            List: TOffset;
            WithRollupTag: TOffset;
          end;
          Having: packed record
            Tag: TOffset;
            Expr: TOffset;
          end;
          OrderBy: TOffset;
          Limit: TOffset;
          Proc: packed record
            Tag: TOffset;
            Ident: TOffset;
            ParamList: TOffset;
          end;
          Into2: TIntoNodes;
          ForUpdatesTag: TOffset;
          LockInShareMode: TOffset;
          CloseBrackets1: TOffset;
          UnionList: TOffset;
          CloseBrackets2: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PSetStmt = ^TSetStmt;
      TSetStmt = packed record
      private type

        PAssignment = ^TAssignment;
        TAssignment = packed record
        private type
          TNodes = packed record
            VariableIdent: TOffset;
            AssignToken: TOffset;
            ValueExpr: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          SetTag: TOffset;
          ScopeTag: TOffset;
          AssignmentList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PSetNamesStmt = ^TSetNamesStmt;
      TSetNamesStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          CharsetValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PSetPasswordStmt = ^TSetPasswordStmt;
      TSetPasswordStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          ForValue: TOffset;
          AssignToken: TOffset;
          PasswordExpr: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PSetTransactionStmt = ^TSetTransactionStmt;
      TSetTransactionStmt = packed record
      private type

        PCharacteristic = ^TCharacteristic;
        TCharacteristic = packed record
        private type
          TNodes = packed record
            KindTag: TOffset;
            LevelTag: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          SetTag: TOffset;
          ScopeTag: TOffset;
          TransactionTag: TOffset;
          CharacteristicList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowBinaryLogsStmt = ^TShowBinaryLogsStmt;
      TShowBinaryLogsStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowBinlogEventsStmt = ^TShowBinlogEventsStmt;
      TShowBinlogEventsStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          InValue: TOffset;
          FromValue: TOffset;
          Limit: packed record
            Tag: TOffset;
            OffsetToken: TOffset;
            CommaToken: TOffset;
            RowCountToken: TOffset;
          end;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowCharacterSetStmt = ^TShowCharacterSetStmt;
      TShowCharacterSetStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          LikeValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowCollationStmt = ^TShowCollationStmt;
      TShowCollationStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          LikeValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowColumnsStmt = ^TShowColumnsStmt;
      TShowColumnsStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          FullTag: TOffset;
          ColumnsTag: TOffset;
          FromTableTag: TOffset;
          TableIdent: TOffset;
          FromDatabaseValue: TOffset;
          LikeValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowCountStmt = ^TShowCountStmt;
      TShowCountStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          CountFunc: TOffset;
          KindTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowCreateDatabaseStmt = ^TShowCreateDatabaseStmt;
      TShowCreateDatabaseStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          IfNotExistsTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowCreateEventStmt = ^TShowCreateEventStmt;
      TShowCreateEventStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowCreateFunctionStmt = ^TShowCreateFunctionStmt;
      TShowCreateFunctionStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowCreateProcedureStmt = ^TShowCreateProcedureStmt;
      TShowCreateProcedureStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowCreateTableStmt = ^TShowCreateTableStmt;
      TShowCreateTableStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowCreateTriggerStmt = ^TShowCreateTriggerStmt;
      TShowCreateTriggerStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowCreateUserStmt = ^TShowCreateUserStmt;
      TShowCreateUserStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          User: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowCreateViewStmt = ^TShowCreateViewStmt;
      TShowCreateViewStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowDatabasesStmt = ^TShowDatabasesStmt;
      TShowDatabasesStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          LikeValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowEngineStmt = ^TShowEngineStmt;
      TShowEngineStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
          KindTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowEnginesStmt = ^TShowEnginesStmt;
      TShowEnginesStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowErrorsStmt = ^TShowErrorsStmt;
      TShowErrorsStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Limit: record
            Tag: TOffset;
            OffsetToken: TOffset;
            CommaToken: TOffset;
            RowCountToken: TOffset;
          end;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowEventsStmt = ^TShowEventsStmt;
      TShowEventsStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          FromValue: TOffset;
          LikeValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowFunctionStatusStmt = ^TShowFunctionStatusStmt;
      TShowFunctionStatusStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowGrantsStmt = ^TShowGrantsStmt;
      TShowGrantsStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          ForValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowIndexStmt = ^TShowIndexStmt;
      TShowIndexStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          FromTableValue: TOffset;
          FromDatabaseValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowMasterStatusStmt = ^TShowMasterStatusStmt;
      TShowMasterStatusStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowOpenTablesStmt = ^TShowOpenTablesStmt;
      TShowOpenTablesStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          FromDatabaseValue: TOffset;
          LikeValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowPluginsStmt = ^TShowPluginsStmt;
      TShowPluginsStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowPrivilegesStmt = ^TShowPrivilegesStmt;
      TShowPrivilegesStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowProcedureStatusStmt = ^TShowProcedureStatusStmt;
      TShowProcedureStatusStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          LikeValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowProcessListStmt = ^TShowProcessListStmt;
      TShowProcessListStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowProfileStmt = ^TShowProfileStmt;
      TShowProfileStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          TypeList: TOffset;
          ForQueryValue: TOffset;
          Limit: packed record
            Tag: TOffset;
            Token: TOffset;
            OffsetTag: TOffset;
            OffsetToken: TOffset;
          end;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowProfilesStmt = ^TShowProfilesStmt;
      TShowProfilesStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowRelaylogEventsStmt = ^TShowRelaylogEventsStmt;
      TShowRelaylogEventsStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          InValue: TOffset;
          FromValue: TOffset;
          Limit: packed record
            Tag: TOffset;
            OffsetToken: TOffset;
            CommaToken: TOffset;
            RowCountToken: TOffset;
          end;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowRoutineCodeStmt = ^TShowRoutineCodeStmt;
      TShowRoutineCodeStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowSlaveHostsStmt = ^TShowSlaveHostsStmt;
      TShowSlaveHostsStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowSlaveStatusStmt = ^TShowSlaveStatusStmt;
      TShowSlaveStatusStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowStatusStmt = ^TShowStatusStmt;
      TShowStatusStmt = packed record
      private type
        TNodes = packed record
          ShowTag: TOffset;
          ScopeTag: TOffset;
          StatusTag: TOffset;
          LikeValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowTableStatusStmt = ^TShowTableStatusStmt;
      TShowTableStatusStmt = packed record
      private type
        TNodes = packed record
          ShowTag: TOffset;
          FromDatabaseValue: TOffset;
          LikeValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowTablesStmt = ^TShowTablesStmt;
      TShowTablesStmt = packed record
      private type
        TNodes = packed record
          ShowTag: TOffset;
          FullTag: TOffset;
          TablesTag: TOffset;
          FromDatabaseValue: TOffset;
          LikeValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowTriggersStmt = ^TShowTriggersStmt;
      TShowTriggersStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          FromDatabaseValue: TOffset;
          LikeValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowVariablesStmt = ^TShowVariablesStmt;
      TShowVariablesStmt = packed record
      private type
        TNodes = packed record
          ShowTag: TOffset;
          ScopeTag: TOffset;
          VariablesTag: TOffset;
          LikeValue: TOffset;
          WhereValue: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShowWarningsStmt = ^TShowWarningsStmt;
      TShowWarningsStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Limit: record
            Tag: TOffset;
            OffsetToken: TOffset;
            CommaToken: TOffset;
            RowCountToken: TOffset;
          end;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PShutdownStmt = ^TShutdownStmt;
      TShutdownStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PSignalStmt = ^TSignalStmt;
      TSignalStmt = packed record
      private type

        PInformation = ^TInformation;
        TInformation = packed record
        private type
          TNodes = packed record
            Value: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          StmtTag: TOffset;
          Condition: TOffset;
          SetTag: TOffset;
          InformationList: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PSoundsLikeOp = ^TSoundsLikeOp;
      TSoundsLikeOp = packed record
      private type
        TNodes = packed record
          Operand1: TOffset;
          Sounds: TOffset;
          Like: TOffset;
          Operand2: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const AOperand1, ASounds, ALike, AOperand2: TOffset): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PStartSlaveStmt = ^TStartSlaveStmt;
      TStartSlaveStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PStartTransactionStmt = ^TStartTransactionStmt;
      TStartTransactionStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          RealOnlyTag: TOffset;
          ReadWriteTag: TOffset;
          WithConsistentSnapshotTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PStopSlaveStmt = ^TStopSlaveStmt;
      TStopSlaveStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PSubArea = ^TSubArea;
      TSubArea = packed record
      private type
        TNodes = packed record
          OpenBracket: TOffset;
          AreaNode: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PSubPartition = ^TSubPartition;
      TSubPartition = packed record
      private type
        TNodes = packed record
          SubPartitionTag: TOffset;
          NameIdent: TOffset;
          EngineValue: TOffset;
          CommentValue: TOffset;
          DataDirectoryValue: TOffset;
          IndexDirectoryValue: TOffset;
          MaxRowsValue: TOffset;
          MinRowsValue: TOffset;
          TablespaceValue: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PSubquery = ^TSubquery;
      TSubquery = packed record
      private type
        TNodes = packed record
          IdentTag: TOffset;
          OpenToken: TOffset;
          Subquery: TOffset;
          CloseToken: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const AIdentTag, ASubquery: TOffset): TOffset; overload; static;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; overload; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PSubstringFunc = ^TSubstringFunc;
      TSubstringFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          Str: TOffset;
          FromTag: TOffset;
          Pos: TOffset;
          ForTag: TOffset;
          Len: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PSumFunc = ^TSumFunc;
      TSumFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          DistinctToken: TOffset;
          Expr: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PTag = ^TTag;
      TTag = packed record
      private type
        TNodes = packed record
          Keyword1Token: TOffset;
          Keyword2Token: TOffset;
          Keyword3Token: TOffset;
          Keyword4Token: TOffset;
          Keyword5Token: TOffset;
          Keyword6Token: TOffset;
          Keyword7Token: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PTimestampAddFunc = ^TTimestampAddFunc;
      TTimestampAddFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          UnitTag: TOffset;
          Comma1: TOffset;
          IntervalInt: TOffset;
          Comma2: TOffset;
          DatetimeExpr: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PTimestampDiffFunc = ^TTimestampDiffFunc;
      TTimestampDiffFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          UnitTag: TOffset;
          Comma1: TOffset;
          Datetime1Expr: TOffset;
          Comma2: TOffset;
          Datetime2Expr: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PTrimFunc = ^TTrimFunc;
      TTrimFunc = packed record
      private type
        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          LocationTag: TOffset;
          RemoveStr: TOffset;
          FromTag: TOffset;
          Str: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PTruncateStmt = ^TTruncateStmt;
      TTruncateStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          TableTag: TOffset;
          TableIdent: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PUnaryOp = ^TUnaryOp;
      TUnaryOp = packed record
      private type
        TNodes = packed record
          Operator: TOffset;
          Operand: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const AOperator, AOperand: TOffset): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PUninstallPluginStmt = ^TUninstallPluginStmt;
      TUninstallPluginStmt = packed record
      private type
        TNodes = packed record
          StmtTag: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PUnknownStmt = ^TUnknownStmt;
      TUnknownStmt = packed record
      private
        Heritage: TStmt;
      private
        class function Create(const AParser: TSQLParser; const ATokens: POffsetList): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PUnlockTablesStmt = ^TUnlockTablesStmt;
      TUnlockTablesStmt = packed record
      private type
        TNodes = packed record
          UnlockTablesTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PUpdateStmt = ^TUpdateStmt;
      TUpdateStmt = packed record
      private type
        TNodes = packed record
          UpdateTag: TOffset;
          PriorityTag: TOffset;
          TableReferenceList: TOffset;
          Set_: packed record
            Tag: TOffset;
            PairList: TOffset;
          end;
          Where: packed record
            Tag: TOffset;
            Expr: TOffset;
          end;
          OrderBy: packed record
            Tag: TOffset;
            List: TOffset;
          end;
          Limit: packed record
            Tag: TOffset;
            Token: TOffset;
          end;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PUseStmt = ^TUseStmt;
      TUseStmt = packed record
      private type
        TNodes = packed record
          StmtToken: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PValue = ^TValue;
      TValue = packed record
      private type
        TNodes = packed record
          Ident: TOffset;
          AssignToken: TOffset;
          Expr: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PVariable = ^TVariable;
      TVariable = packed record
      private type
        TNodes = packed record
          At1Token: TOffset;
          At2Token: TOffset;
          ScopeTag: TOffset;
          ScopeDotToken: TOffset;
          Ident: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PWeightStringFunc = ^TWeightStringFunc;
      TWeightStringFunc = packed record
      private type

        PLevel = ^TLevel;
        TLevel = packed record
        private type
          TNodes = packed record
            CountInt: TOffset;
            DirectionTag: TOffset;
            ReverseTag: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          IdentToken: TOffset;
          OpenBracket: TOffset;
          Str: TOffset;
          AsTag: TOffset;
          Datatype: TOffset;
          LevelTag: TOffset;
          LevelList: TOffset;
          CloseBracket: TOffset;
        end;
      private
        Heritage: TRange;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
      end;

      PWhileStmt = ^TWhileStmt;
      TWhileStmt = packed record
      private type
        TNodes = packed record
          BeginLabel: TOffset;
          WhileTag: TOffset;
          SearchConditionExpr: TOffset;
          DoTag: TOffset;
          StmtList: TOffset;
          EndTag: TOffset;
          EndLabel: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

      PXAStmt = ^TXAStmt;
      TXAStmt = packed record
      private type

        PID = ^TID;
        TID = packed record
        private type
          TNodes = packed record
            GTrId: TOffset;
            Comma1: TOffset;
            BQual: TOffset;
            Comma2: TOffset;
            FormatId: TOffset;
          end;
        private
          Heritage: TRange;
        private
          Nodes: TNodes;
          class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
        public
          property Parser: TSQLParser read Heritage.Heritage.Heritage.FParser;
        end;

        TNodes = packed record
          XATag: TOffset;
          ActionTag: TOffset;
          Ident: TOffset;
          RestTag: TOffset;
        end;
      private
        Heritage: TStmt;
      private
        Nodes: TNodes;
        class function Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset; static;
      public
        property Parser: TSQLParser read Heritage.Heritage.Heritage.Heritage.FParser;
      end;

  private type
    TSpacer = (sNone, sSpace, sReturn);
    TExprOptions = set of (eoIn, eoAllFields, eoOperators);
  private
    diBIGINT,
    diBINARY,
    diBIT,
    diBLOB,
    diBOOL,
    diBOOLEAN,
    diBYTE,
    diCHAR,
    diCHARACTER,
    diDEC,
    diDECIMAL,
    diDATE,
    diDATETIME,
    diDOUBLE,
    diENUM,
    diFLOAT,
    diGEOMETRY,
    diGEOMETRYCOLLECTION,
    diINT,
    diINT4,
    diJSON,
    diINTEGER,
    diLARGEINT,
    diLINESTRING,
    diLONG,
    diLONGBLOB,
    diLONGTEXT,
    diMEDIUMBLOB,
    diMEDIUMINT,
    diMEDIUMTEXT,
    diMULTILINESTRING,
    diMULTIPOINT,
    diMULTIPOLYGON,
    diNUMBER,
    diNUMERIC,
    diNCHAR,
    diNVARCHAR,
    diPOINT,
    diPOLYGON,
    diREAL,
    diSERIAL,
    diSET,
    diSIGNED,
    diSMALLINT,
    diTEXT,
    diTIME,
    diTIMESTAMP,
    diTINYBLOB,
    diTINYINT,
    diTINYTEXT,
    diUNSIGNED,
    diVARBINARY,
    diVARCHAR,
    diYEAR: Integer;
  
    kiACCOUNT,
    kiACTION,
    kiADD,
    kiAFTER,
    kiAGAINST,
    kiALGORITHM,
    kiALL,
    kiALTER,
    kiALWAYS,
    kiANALYZE,
    kiAND,
    kiANY,
    kiAS,
    kiASC,
    kiASCII,
    kiAT,
    kiAUTO_INCREMENT,
    kiAVG_ROW_LENGTH,
    kiBEFORE,
    kiBEGIN,
    kiBETWEEN,
    kiBINARY,
    kiBINLOG,
    kiBLOCK,
    kiBOOLEAN,
    kiBOTH,
    kiBTREE,
    kiBY,
    kiCACHE,
    kiCALL,
    kiCASCADE,
    kiCASCADED,
    kiCASE,
    kiCATALOG_NAME,
    kiCHANGE,
    kiCHANGED,
    kiCHANNEL,
    kiCHAIN,
    kiCHARACTER,
    kiCHARSET,
    kiCHECK,
    kiCHECKSUM,
    kiCLASS_ORIGIN,
    kiCLIENT,
    kiCLOSE,
    kiCOALESCE,
    kiCODE,
    kiCOLLATE,
    kiCOLLATION,
    kiCOLUMN,
    kiCOLUMN_FORMAT,
    kiCOLUMN_NAME,
    kiCOLUMNS,
    kiCOMMENT,
    kiCOMMIT,
    kiCOMMITTED,
    kiCOMPACT,
    kiCOMPLETION,
    kiCOMPRESSED,
    kiCONCURRENT,
    kiCONDITION,
    kiCONNECTION,
    kiCONSISTENT,
    kiCONSTRAINT,
    kiCONSTRAINT_CATALOG,
    kiCONSTRAINT_NAME,
    kiCONSTRAINT_SCHEMA,
    kiCONTAINS,
    kiCONTEXT,
    kiCONTINUE,
    kiCONVERT,
    kiCOPY,
    kiCPU,
    kiCREATE,
    kiCROSS,
    kiCURRENT,
    kiCURRENT_DATE,
    kiCURRENT_TIME,
    kiCURRENT_TIMESTAMP,
    kiCURRENT_USER,
    kiCURSOR,
    kiCURSOR_NAME,
    kiDATA,
    kiDATABASE,
    kiDATABASES,
    kiDATAFILE,
    kiDAY,
    kiDAY_HOUR,
    kiDAY_MICROSECOND,
    kiDAY_MINUTE,
    kiDAY_SECOND,
    kiDEALLOCATE,
    kiDECLARE,
    kiDEFAULT,
    kiDEFINER,
    kiDELAY_KEY_WRITE,
    kiDELAYED,
    kiDELETE,
    kiDESC,
    kiDESCRIBE,
    kiDETERMINISTIC,
    kiDIAGNOSTICS,
    kiDIRECTORY,
    kiDISABLE,
    kiDISCARD,
    kiDISK,
    kiDISTINCT,
    kiDISTINCTROW,
    kiDIV,
    kiDO,
    kiDROP,
    kiDUAL,
    kiDUMPFILE,
    kiDUPLICATE,
    kiDYNAMIC,
    kiEACH,
    kiELSE,
    kiELSEIF,
    kiENABLE,
    kiENCLOSED,
    kiEND,
    kiENDS,
    kiENGINE,
    kiENGINES,
    kiERROR,
    kiERRORS,
    kiESCAPE,
    kiESCAPED,
    kiEVENT,
    kiEVENTS,
    kiEVERY,
    kiEXCHANGE,
    kiEXCLUSIVE,
    kiEXECUTE,
    kiEXISTS,
    kiEXPANSION,
    kiEXPIRE,
    kiEXPLAIN,
    kiEXIT,
    kiEXTENDED,
    kiFALSE,
    kiFAST,
    kiFAULTS,
    kiFETCH,
    kiFILE_BLOCK_SIZE,
    kiFLUSH,
    kiFIELDS,
    kiFILE,
    kiFIRST,
    kiFIXED,
    kiFOLLOWS,
    kiFOR,
    kiFORCE,
    kiFORMAT,
    kiFOREIGN,
    kiFOUND,
    kiFROM,
    kiFULL,
    kiFULLTEXT,
    kiFUNCTION,
    kiGENERAL,
    kiGENERATED,
    kiGET,
    kiGLOBAL,
    kiGRANT,
    kiGRANTS,
    kiGROUP,
    kiHANDLER,
    kiHASH,
    kiHAVING,
    kiHELP,
    kiHIGH_PRIORITY,
    kiHOST,
    kiHOSTS,
    kiHOUR,
    kiHOUR_MICROSECOND,
    kiHOUR_MINUTE,
    kiHOUR_SECOND,
    kiIDENTIFIED,
    kiIF,
    kiIGNORE,
    kiIGNORE_SERVER_IDS,
    kiIMPORT,
    kiIN,
    kiINDEX,
    kiINDEXES,
    kiINFILE,
    kiINITIAL_SIZE,
    kiINNER,
    kiINNODB,
    kiINOUT,
    kiINPLACE,
    kiINSTANCE,
    kiINSERT,
    kiINSERT_METHOD,
    kiINSTALL,
    kiINTERVAL,
    kiINTO,
    kiINVOKER,
    kiIO,
    kiIPC,
    kiIS,
    kiISOLATION,
    kiITERATE,
    kiJOIN,
    kiJSON,
    kiKEY,
    kiKEY_BLOCK_SIZE,
    kiKEYS,
    kiKILL,
    kiLANGUAGE,
    kiLAST,
    kiLEADING,
    kiLEAVE,
    kiLEFT,
    kiLESS,
    kiLEVEL,
    kiLIKE,
    kiLIMIT,
    kiLINEAR,
    kiLINES,
    kiLIST,
    kiLOAD,
    kiLOCAL,
    kiLOCK,
    kiLOGS,
    kiLOOP,
    kiLOW_PRIORITY,
    kiMASTER,
    kiMASTER_AUTO_POSITION,
    kiMASTER_BIND,
    kiMASTER_CONNECT_RETRY,
    kiMASTER_DELAY,
    kiMASTER_HEARTBEAT_PERIOD,
    kiMASTER_HOST,
    kiMASTER_LOG_FILE,
    kiMASTER_LOG_POS,
    kiMASTER_PASSWORD,
    kiMASTER_PORT,
    kiMASTER_RETRY_COUNT,
    kiMASTER_SSL,
    kiMASTER_SSL_CA,
    kiMASTER_SSL_CAPATH,
    kiMASTER_SSL_CERT,
    kiMASTER_SSL_CIPHER,
    kiMASTER_SSL_CRL,
    kiMASTER_SSL_CRLPATH,
    kiMASTER_SSL_KEY,
    kiMASTER_SSL_VERIFY_SERVER_CERT,
    kiMASTER_TLS_VERSION,
    kiMASTER_USER,
    kiMATCH,
    kiMAX_QUERIES_PER_HOUR,
    kiMAX_ROWS,
    kiMAX_CONNECTIONS_PER_HOUR,
    kiMAX_STATEMENT_TIME,
    kiMAX_UPDATES_PER_HOUR,
    kiMAX_USER_CONNECTIONS,
    kiMAXVALUE,
    kiMEDIUM,
    kiMEMORY,
    kiMERGE,
    kiMESSAGE_TEXT,
    kiMICROSECOND,
    kiMIGRATE,
    kiMIN_ROWS,
    kiMINUTE,
    kiMINUTE_MICROSECOND,
    kiMINUTE_SECOND,
    kiMOD,
    kiMODE,
    kiMODIFIES,
    kiMODIFY,
    kiMONTH,
    kiMUTEX,
    kiMYSQL_ERRNO,
    kiNAME,
    kiNAMES,
    kiNATIONAL,
    kiNATURAL,
    kiNEVER,
    kiNEW,
    kiNEXT,
    kiNO,
    kiNONE,
    kiNOT,
    kiNULL,
    kiNO_WRITE_TO_BINLOG,
    kiNUMBER,
    kiOFFSET,
    kiOJ,
    kiOLD,
    kiON,
    kiONE,
    kiONLINE,
    kiONLY,
    kiOPEN,
    kiOPTIMIZE,
    kiOPTION,
    kiOPTIONALLY,
    kiOPTIONS,
    kiOR,
    kiORDER,
    kiOUT,
    kiOUTER,
    kiOUTFILE,
    kiOWNER,
    kiPACK_KEYS,
    kiPAGE,
    kiPAGE_CHECKSUM,
    kiPARSER,
    kiPARTIAL,
    kiPARTITION,
    kiPARTITIONING,
    kiPARTITIONS,
    kiPASSWORD,
    kiPERSISTENT,
    kiPHASE,
    kiPLUGIN,
    kiPLUGINS,
    kiPORT,
    kiPRECEDES,
    kiPREPARE,
    kiPRESERVE,
    kiPRIMARY,
    kiPRIVILEGES,
    kiPROCEDURE,
    kiPROCESS,
    kiPROCESSLIST,
    kiPROFILE,
    kiPROFILES,
    kiPROXY,
    kiPURGE,
    kiQUARTER,
    kiQUERY,
    kiQUICK,
    kiRANGE,
    kiREAD,
    kiREADS,
    kiREBUILD,
    kiRECOVER,
    kiREDUNDANT,
    kiREFERENCES,
    kiREGEXP,
    kiRELAY,
    kiRELAYLOG,
    kiRELEASE,
    kiRELAY_LOG_FILE,
    kiRELAY_LOG_POS,
    kiRELOAD,
    kiREMOVE,
    kiRENAME,
    kiREORGANIZE,
    kiREPAIR,
    kiREPEAT,
    kiREPEATABLE,
    kiREPLACE,
    kiREPLICATION,
    kiREQUIRE,
    kiRESET,
    kiRESIGNAL,
    kiRESTRICT,
    kiRESUME,
    kiRETURN,
    kiRETURNED_SQLSTATE,
    kiRETURNS,
    kiREVERSE,
    kiREVOKE,
    kiRIGHT,
    kiRLIKE,
    kiROLLBACK,
    kiROLLUP,
    kiROTATE,
    kiROUTINE,
    kiROW,
    kiROW_COUNT,
    kiROW_FORMAT,
    kiROWS,
    kiSAVEPOINT,
    kiSCHEDULE,
    kiSCHEMA,
    kiSCHEMA_NAME,
    kiSECOND,
    kiSECOND_MICROSECOND,
    kiSECURITY,
    kiSELECT,
    kiSEPARATOR,
    kiSERIALIZABLE,
    kiSERVER,
    kiSESSION,
    kiSET,
    kiSHARE,
    kiSHARED,
    kiSHOW,
    kiSHUTDOWN,
    kiSIGNAL,
    kiSIGNED,
    kiSIMPLE,
    kiSLAVE,
    kiSLOW,
    kiSNAPSHOT,
    kiSOCKET,
    kiSOME,
    kiSONAME,
    kiSOUNDS,
    kiSOURCE,
    kiSPATIAL,
    kiSQL,
    kiSQL_BIG_RESULT,
    kiSQL_BUFFER_RESULT,
    kiSQL_CACHE,
    kiSQL_CALC_FOUND_ROWS,
    kiSQL_NO_CACHE,
    kiSQL_SMALL_RESULT,
    kiSQL_TSI_MICROSECOND,
    kiSQL_TSI_SECOND,
    kiSQL_TSI_MINUTE,
    kiSQL_TSI_HOUR,
    kiSQL_TSI_DAY,
    kiSQL_TSI_WEEK,
    kiSQL_TSI_MONTH,
    kiSQL_TSI_QUARTER,
    kiSQL_TSI_YEAR,
    kiSQLEXCEPTION,
    kiSQLSTATE,
    kiSQLWARNING,
    kiSTACKED,
    kiSTARTING,
    kiSTART,
    kiSTARTS,
    kiSTATS_AUTO_RECALC,
    kiSTATS_PERSISTENT,
    kiSTATS_SAMPLE_PAGES,
    kiSTATUS,
    kiSTOP,
    kiSTORAGE,
    kiSTORED,
    kiSTRAIGHT_JOIN,
    kiSUBCLASS_ORIGIN,
    kiSUBPARTITION,
    kiSUBPARTITIONS,
    kiSUPER,
    kiSUSPEND,
    kiSWAPS,
    kiSWITCHES,
    kiTABLE,
    kiTABLE_CHECKSUM,
    kiTABLE_NAME,
    kiTABLES,
    kiTABLESPACE,
    kiTEMPORARY,
    kiTEMPTABLE,
    kiTERMINATED,
    kiTHAN,
    kiTHEN,
    kiTO,
    kiTRADITIONAL,
    kiTRAILING,
    kiTRANSACTION,
    kiTRANSACTIONAL,
    kiTRIGGER,
    kiTRIGGERS,
    kiTRUE,
    kiTRUNCATE,
    kiTYPE,
    kiUNCOMMITTED,
    kiUNDEFINED,
    kiUNDO,
    kiUNICODE,
    kiUNINSTALL,
    kiUNION,
    kiUNIQUE,
    kiUNKNOWN,
    kiUNLOCK,
    kiUNSIGNED,
    kiUNTIL,
    kiUPDATE,
    kiUPGRADE,
    kiUSAGE,
    kiUSE,
    kiUSE_FRM,
    kiUSER,
    kiUSING,
    kiVALIDATION,
    kiVALUE,
    kiVALUES,
    kiVARIABLES,
    kiVIEW,
    kiVIRTUAL,
    kiWAIT,
    kiWARNINGS,
    kiWEEK,
    kiWHEN,
    kiWHERE,
    kiWHILE,
    kiWRAPPER,
    kiWRITE,
    kiWITH,
    kiWITHOUT,
    kiWORK,
    kiXA,
    kiXID,
    kiXML,
    kiXOR,
    kiYEAR,
    kiYEAR_MONTH,
    kiZEROFILL: Integer;

    AllowedMySQLVersion: Integer;
    CharsetList: TWordList;
    Commands: TFormatBuffer;
    CommentsWritten: Boolean;
    CurrentToken: TOffset; // Cache for speeding
    DatatypeList: TWordList;
    Error: TError;
    FAnsiQuotes: Boolean;
    FCompletionList: TCompletionList;
    FConstantList: TWordList;
    FFunctionList: TWordList;
    FInCompound: Integer;
    FInPL_SQL: Integer;
    FirstError: TError;
    FMySQLVersion: Integer;
    FRoot: TOffset;
    KeywordList: TWordList;
    Nodes: record
      Mem: PAnsiChar;
      UsedSize: Integer;
      MemSize: Integer;
    end;
    OperatorTypeByKeywordIndex: array of TOperatorType;
    Parse: record
      Before: (pbOther, pbAt, pbIdent);
      InCreateEventStmt: Boolean;
      InCreateFunctionStmt: Boolean;
      InCreateProcedureStmt: Boolean;
      InCreateTriggerStmt: Boolean;
      Length: Integer;
      Line: Integer;
      Pos: PChar;
      SQL: string;
    end;
    ReservedWordList: TWordList;
    TokenBuffer: record
      Count: Integer;
      Items: array [0 .. 10000 - 1] of record Error: TError; Token: TOffset; end;
    end;
    {$IFDEF Debug}
    TokenIndex: Integer;
    {$ENDIF}
    ttIdents: set of TTokenType;
    ttStrings: set of TTokenType;
    function ApplyCurrentToken(const AUsageType: TUsageType): TOffset;
    procedure BeginPL_SQL(); {$IFNDEF Debug} inline; {$ENDIF}
    function EndOfStmt(const Token: PToken): Boolean; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function EndOfStmt(const Token: TOffset): Boolean; overload; {$IFNDEF Debug} inline; {$ENDIF}
    procedure EndPL_SQL(); {$IFNDEF Debug} inline; {$ENDIF}
    procedure FormatAccount(const Nodes: TAccount.TNodes);
    procedure FormatAlterDatabaseStmt(const Nodes: TAlterDatabaseStmt.TNodes);
    procedure FormatAlterEventStmt(const Nodes: TAlterEventStmt.TNodes);
    procedure FormatAlterRoutineStmt(const Nodes: TAlterRoutineStmt.TNodes);
    procedure FormatAlterTablespaceStmt(const Nodes: TAlterTablespaceStmt.TNodes);
    procedure FormatAlterTableStmt(const Nodes: TAlterTableStmt.TNodes);
    procedure FormatAlterTableStmtAlterField(const Nodes: TAlterTableStmt.TAlterField.TNodes);
    procedure FormatAlterViewStmt(const Nodes: TAlterViewStmt.TNodes);
    procedure FormatBeginLabel(const Nodes: TBeginLabel.TNodes);
    procedure FormatCallStmt(const Nodes: TCallStmt.TNodes);
    procedure FormatCaseOp(const Nodes: TCaseOp.TNodes);
    procedure FormatCaseStmt(const Nodes: TCaseStmt.TNodes);
    procedure FormatCaseStmtBranch(const Nodes: TCaseStmt.TBranch.TNodes);
    procedure FormatCastFunc(const Nodes: TCastFunc.TNodes);
    procedure FormatCharFunc(const Nodes: TCharFunc.TNodes);
    procedure FormatChangeMasterStmt(const Nodes: TChangeMasterStmt.TNodes);
    procedure FormatCompoundStmt(const Nodes: TCompoundStmt.TNodes);
    procedure FormatConvertFunc(const Nodes: TConvertFunc.TNodes);
    procedure FormatCountFunc(const Nodes: TCountFunc.TNodes);
    procedure FormatCreateEventStmt(const Nodes: TCreateEventStmt.TNodes);
    procedure FormatCreateIndexStmt(const Nodes: TCreateIndexStmt.TNodes);
    procedure FormatCreateRoutineStmt(const Nodes: TCreateRoutineStmt.TNodes);
    procedure FormatCreateServerStmt(const Nodes: TCreateServerStmt.TNodes);
    procedure FormatCreateTablespaceStmt(const Nodes: TCreateTablespaceStmt.TNodes);
    procedure FormatCreateTableStmt(const Nodes: TCreateTableStmt.TNodes);
    procedure FormatCreateTableStmtField(const Nodes: TCreateTableStmt.TField.TNodes);
    procedure FormatCreateTableStmtKey(const Nodes: TCreateTableStmt.TKey.TNodes);
    procedure FormatCreateTableStmtKeyColumn(const Nodes: TCreateTableStmt.TKeyColumn.TNodes);
    procedure FormatCreateTableStmtPartitionOptions(const Nodes: TCreateTableStmt.TPartitionOptions.TNodes);
    procedure FormatCreateTableStmtReference(const Nodes: TCreateTableStmt.TReference.TNodes);
    procedure FormatCreateTriggerStmt(const Nodes: TCreateTriggerStmt.TNodes);
    procedure FormatCreateUserStmt(const Nodes: TCreateUserStmt.TNodes);
    procedure FormatCreateViewStmt(const Nodes: TCreateViewStmt.TNodes);
    procedure FormatComments(const Token: PToken; Start: Boolean = False);
    procedure FormatDatatype(const Nodes: TDatatype.TNodes);
    procedure FormatDateAddFunc(const Nodes: TDateAddFunc.TNodes);
    procedure FormatDbIdent(const Nodes: TDbIdent.TNodes);
    procedure FormatDeclareCursorStmt(const Nodes: TDeclareCursorStmt.TNodes);
    procedure FormatDeclareHandlerStmt(const Nodes: TDeclareHandlerStmt.TNodes);
    procedure FormatDefaultFunc(const Nodes: TDefaultFunc.TNodes);
    procedure FormatDeleteStmt(const Nodes: TDeleteStmt.TNodes);
    procedure FormatDropTablespaceStmt(const Nodes: TDropTablespaceStmt.TNodes);
    procedure FormatExtractFunc(const Nodes: TExtractFunc.TNodes);
    procedure FormatFetchStmt(const Nodes: TFetchStmt.TNodes);
    procedure FormatGroupConcatFunc(const Nodes: TGroupConcatFunc.TNodes);
    procedure FormatIfStmt(const Nodes: TIfStmt.TNodes);
    procedure FormatIfStmtBranch(const Nodes: TIfStmt.TBranch.TNodes);
    procedure FormatInsertStmt(const Nodes: TInsertStmt.TNodes);
    procedure FormatList(const List: PList; const Spacer: TSpacer); overload;
    procedure FormatList(const Node: TOffset; const Spacer: TSpacer); overload; {$IFNDEF Debug} inline; {$ENDIF}
    procedure FormatLoadDataStmt(const Nodes: TLoadDataStmt.TNodes);
    procedure FormatLoadXMLStmt(const Nodes: TLoadXMLStmt.TNodes);
    procedure FormatLockTablesStmtItem(const Nodes: TLockTablesStmt.TItem.TNodes);
    procedure FormatLoopStmt(const Nodes: TLoopStmt.TNodes);
    procedure FormatMatchFunc(const Nodes: TMatchFunc.TNodes);
    procedure FormatNode(const Node: PNode; const Separator: TSeparatorType = stNone); overload;
    procedure FormatNode(const Node: TOffset; const Separator: TSeparatorType = stNone) overload; {$IFNDEF Debug} inline; {$ENDIF}
    procedure FormatPositionFunc(const Nodes: TPositionFunc.TNodes);
    procedure FormatRepeatStmt(const Nodes: TRepeatStmt.TNodes);
    procedure FormatRevokeStmt(const Nodes: TRevokeStmt.TNodes);
    procedure FormatRoot(const Node: PRoot);
    procedure FormatSchedule(const Nodes: TSchedule.TNodes);
    procedure FormatSecretIdent(const Nodes: TSecretIdent.TNodes);
    procedure FormatSelectStmt(const Nodes: TSelectStmt.TNodes);
    procedure FormatSelectStmtColumn(const Nodes: TSelectStmt.TColumn.TNodes);
    procedure FormatSelectStmtTableFactor(const Nodes: TSelectStmt.TTableFactor.TNodes);
    procedure FormatSelectStmtTableFactorOj(const Nodes: TSelectStmt.TTableFactorOj.TNodes);
    procedure FormatSelectStmtTableFactorSubquery(const Nodes: TSelectStmt.TTableFactorSubquery.TNodes);
    procedure FormatSelectStmtTableJoin(const Nodes: TSelectStmt.TTableJoin.TNodes);
    procedure FormatSetStmt(const Nodes: TSetStmt.TNodes);
    procedure FormatShowBinlogEventsStmt(const Nodes: TShowBinlogEventsStmt.TNodes);
    procedure FormatShowErrorsStmt(const Nodes: TShowErrorsStmt.TNodes);
    procedure FormatShowRelaylogEventsStmt(const Nodes: TShowBinlogEventsStmt.TNodes);
    procedure FormatShowWarningsStmt(const Nodes: TShowWarningsStmt.TNodes);
    procedure FormatSubArea(const Nodes: TSubArea.TNodes);
    procedure FormatSubPartition(const Nodes: TSubPartition.TNodes);
    procedure FormatSubquery(const Nodes: TSubquery.TNodes);
    procedure FormatSubstringFunc(const Nodes: TSubstringFunc.TNodes);
    procedure FormatSumFunc(const Nodes: TSumFunc.TNodes);
    procedure FormatTimestampAddFunc(const Nodes: TTimestampAddFunc.TNodes);
    procedure FormatTimestampDiffFunc(const Nodes: TTimestampDiffFunc.TNodes);
    procedure FormatToken(const Token: TToken);
    procedure FormatTrimFunc(const Nodes: TTrimFunc.TNodes);
    procedure FormatTruncateStmt(const Nodes: TTruncateStmt.TNodes);
    procedure FormatUnaryOp(const Nodes: TUnaryOp.TNodes);
    procedure FormatUnknownStmt(const Node: PUnknownStmt);
    procedure FormatUpdateStmt(const Nodes: TUpdateStmt.TNodes);
    procedure FormatVariableIdent(const Nodes: TVariable.TNodes);
    procedure FormatWeightStringFunc(const Nodes: TWeightStringFunc.TNodes);
    procedure FormatWhileStmt(const Nodes: TWhileStmt.TNodes);
    procedure FormatXID(const Nodes: TXAStmt.TID.TNodes);
    function GetCharsets(): string;
    function GetDatatypes(): string;
    function GetErrorFound(): Boolean; {$IFNDEF Debug} inline; {$ENDIF}
    function GetErrorMessage(): string;
    function GetErrorPos(): Integer;
    function GetErrorToken(): PToken;
    function GetFirstStmt(): PStmt;
    function GetFirstTokenAll(): PToken;
    function GetKeywords(): string;
    function GetNextToken(Index: Integer): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function GetInCompound(): Boolean; {$IFNDEF Debug} inline; {$ENDIF}
    function GetInPL_SQL(): Boolean; {$IFNDEF Debug} inline; {$ENDIF}
    function GetReservedWords(): string;
    function GetRoot(): PRoot; {$IFNDEF Debug} inline; {$ENDIF}
    function GetToken(const Index: Integer): TOffset;
    function IsNextTag(const Index: Integer; const KeywordIndex1: TWordList.TIndex;
      const KeywordIndex2: TWordList.TIndex = -1; const KeywordIndex3: TWordList.TIndex = -1;
      const KeywordIndex4: TWordList.TIndex = -1; const KeywordIndex5: TWordList.TIndex = -1;
      const KeywordIndex6: TWordList.TIndex = -1; const KeywordIndex7: TWordList.TIndex = -1): Boolean;
    function IsNextSymbol(const Index: Integer; const TokenType: TTokenType): Boolean;
    function IsSelectStmt(): Boolean;
    function IsSymbol(const TokenType: TTokenType): Boolean;
    function IsTag(const KeywordIndex1: TWordList.TIndex;
      const KeywordIndex2: TWordList.TIndex = -1; const KeywordIndex3: TWordList.TIndex = -1;
      const KeywordIndex4: TWordList.TIndex = -1; const KeywordIndex5: TWordList.TIndex = -1;
      const KeywordIndex6: TWordList.TIndex = -1; const KeywordIndex7: TWordList.TIndex = -1): Boolean; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseAccountIdent(): TOffset;
    function ParseAnalyzeTableStmt(): TOffset;
    function ParseAlterDatabaseStmt(const AlterTag: TOffset): TOffset;
    function ParseAlterEventStmt(const AlterTag, DefinerValue: TOffset): TOffset;
    function ParseAlterInstanceStmt(const AlterTag: TOffset): TOffset;
    function ParseAlterRoutineStmt(const ARoutineType: TRoutineType; const AlterTag: TOffset): TOffset;
    function ParseAlterServerStmt(const AlterTag: TOffset): TOffset;
    function ParseAlterStmt(): TOffset;
    function ParseAlterTablespaceStmt(const AlterTag: TOffset): TOffset;
    function ParseAlterTableStmt(const AlterTag, IgnoreTag: TOffset): TOffset;
    function ParseAlterTableStmtAddField(const AddType: TCreateTableStmt.TFieldAddType; const AddTag: TOffset): TOffset;
    function ParseAlterTableStmtAddFields(): TOffset;
    function ParseAlterTableStmtAlterField(): TOffset;
    function ParseAlterTableStmtConvertTo(): TOffset;
    function ParseAlterTableStmtDropItem(): TOffset;
    function ParseAlterTableStmtExchangePartition(): TOffset;
    function ParseAlterTableStmtOrderBy(): TOffset;
    function ParseAlterTableStmtReorganizePartition(): TOffset;
    function ParseAlterViewStmt(const AlterTag, AlgorithmValue, DefinerValue, SQLSecurityTag: TOffset): TOffset;
    function ParseBeginLabel(): TOffset;
    function ParseBeginStmt(): TOffset;
    function ParseCallStmt(): TOffset;
    function ParseCaseOp(): TOffset;
    function ParseCaseOpBranch(): TOffset;
    function ParseCaseStmt(): TOffset;
    function ParseCaseStmtBranch(): TOffset;
    function ParseCastFunc(): TOffset;
    function ParseCharFunc(): TOffset;
    function ParseChangeMasterStmt(): TOffset;
    function ParseCharsetIdent(): TOffset;
    function ParseCheckTableStmt(): TOffset;
    function ParseChecksumTableStmt(): TOffset;
    function ParseCloseStmt(): TOffset;
    function ParseCollateIdent(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseColumnAliasIdent(): TOffset;
    function ParseCommitStmt(): TOffset;
    function ParseCompoundStmt(const BeginLabel: TOffset = 0): TOffset;
    function ParseConstIdent(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseConvertFunc(): TOffset;
    function ParseCountFunc(): TOffset;
    function ParseCreateDatabaseStmt(const CreateTag, OrReplaceTag: TOffset): TOffset;
    function ParseCreateEventStmt(const CreateTag, OrReplaceTag, DefinerValue: TOffset): TOffset;
    function ParseCreateIndexStmt(const CreateTag, OrReplaceTag, KindTag: TOffset): TOffset;
    function ParseCreateRoutineStmt(const ARoutineType: TRoutineType; const CreateTag, OrReplaceTag, DefinerValue: TOffset): TOffset;
    function ParseCreateServerStmt(const CreateTag: TOffset): TOffset;
    function ParseCreateServerStmtOptionList(): TOffset;
    function ParseCreateStmt(): TOffset;
    function ParseCreateTablespaceStmt(const CreateTag: TOffset): TOffset;
    function ParseCreateTableStmt(const CreateTag, OrReplaceTag, TemporaryTag: TOffset): TOffset;
    function ParseCreateTableStmtCheck(): TOffset;
    function ParseCreateTableStmtField(): TOffset;
    function ParseCreateTableStmtFieldOnUpdate(): TOffset;
    function ParseCreateTableStmtDefinition(): TOffset; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseCreateTableStmtDefinition(const AlterTableStmt: Boolean): TOffset; overload;
    function ParseCreateTableStmtDefinitionPartitionNames(): TOffset;
    function ParseCreateTableStmtForeignKey(const ConstraintTag, ConstraintIdent, AddTag: TOffset): TOffset;
    function ParseCreateTableStmtKey(const ConstraintTag, ConstraintIdent, AddTag: TOffset): TOffset;
    function ParseCreateTableStmtKeyColumn(): TOffset;
    function ParseCreateTableStmtPartition(): TOffset; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseCreateTableStmtPartition(const AddTag: TOffset): TOffset; overload;
    function ParseCreateTableStmtPartitionOptions(): TOffset;
    function ParseCreateTableStmtReference(): TOffset;
    function ParseCreateTableStmtUnion(): TOffset;
    function ParseCreateTriggerStmt(const CreateTag, OrReplaceTag, DefinerValue: TOffset): TOffset;
    function ParseCreateUserStmt(const StmtTag: TOffset; const OrReplaceTag: TOffset = 0): TOffset;
    function ParseCreateViewStmt(const CreateTag, OrReplaceTag, AlgorithmValue, DefinerValue, SQLSecurityTag: TOffset): TOffset;
    function ParseDatabaseIdent(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseDatatype(): TOffset; overload; inline;
    function ParseDatatype(out DatatypeIndex: Integer): TOffset; overload;
    function ParseDateAddFunc(): TOffset;
    function ParseDbIdent(): TOffset; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseDbIdent(const ADbIdentType: TDbIdentType; const FullQualified: Boolean = True; const JokerAllowed: Boolean = False): TOffset; overload;
    function ParseDefinerValue(): TOffset;
    function ParseDeallocatePrepareStmt(): TOffset;
    function ParseDeclareConditionStmt(const StmtTag: TOffset; const IdentList: TOffset): TOffset;
    function ParseDeclareCursorStmt(const StmtTag: TOffset; const IdentList: TOffset): TOffset;
    function ParseDeclareHandlerStmt(): TOffset;
    function ParseDeclareHandlerStmtCondition(): TOffset;
    function ParseDeclareStmt(): TOffset;
    function ParseDefaultFunc(): TOffset;
    function ParseDeleteStmt(): TOffset;
    function ParseDeleteStmtTableIdent(): TOffset;
    function ParseDoStmt(): TOffset;
    function ParseDropDatabaseStmt(): TOffset;
    function ParseDropEventStmt(): TOffset;
    function ParseDropIndexStmt(): TOffset;
    function ParseDropRoutineStmt(const ARoutineType: TRoutineType): TOffset;
    function ParseDropServerStmt(): TOffset;
    function ParseDropTablespaceStmt(): TOffset;
    function ParseDropTableStmt(): TOffset;
    function ParseDropTriggerStmt(): TOffset;
    function ParseDropUserStmt(): TOffset;
    function ParseDropViewStmt(): TOffset;
    function ParseEventIdent(): TOffset;
    function ParseEndLabel(): TOffset;
    function ParseEngineIdent(): TOffset;
    function ParseExecuteStmt(): TOffset;
    function ParseExplainStmt(): TOffset;
    function ParseExpr(): TOffset; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseExpr(const Options: TExprOptions): TOffset; overload;
    function ParseExtractFunc(): TOffset;
    function ParseFetchStmt(): TOffset;
    function ParseFieldIdent(): TOffset;
    function ParseFieldIdentFullQualified(): TOffset;
    function ParseFieldOrVariableIdent(): TOffset;
    function ParseFlushStmt(): TOffset;
    function ParseFlushStmtOption(): TOffset;
    function ParseFlushStmtOptionLogs(): TOffset;
    function ParseForeignKeyIdent(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseFunctionIdent(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseFunctionParam(): TOffset;
    function ParseFunctionReturns(): TOffset;
    function ParseGetDiagnosticsStmt(): TOffset;
    function ParseGetDiagnosticsStmtStmtInfo(): TOffset;
    function ParseGetDiagnosticsStmtConditionInfo(): TOffset;
    function ParseGrantStmt(): TOffset;
    function ParseGrantStmtPrivileg(): TOffset;
    function ParseGrantStmtUserSpecification(): TOffset;
    function ParseGroupConcatFunc(): TOffset;
    function ParseGroupConcatFuncExpr(): TOffset;
    function ParseHelpStmt(): TOffset;
    function ParseIfStmt(): TOffset;
    function ParseInsertStmt(const Replace: Boolean = False): TOffset;
    function ParseInsertStmtSetItemsList(): TOffset;
    function ParseInsertStmtValuesList(): TOffset;
    function ParseInstallPluginStmt(): TOffset;
    function ParseInteger(): TOffset;
    function ParseInterval(): TOffset;
    function ParseIntervalUnitTag(): TOffset;
    function ParseIterateStmt(): TOffset;
    function ParseKeyIdent(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseKillStmt(): TOffset;
    function ParseLeaveStmt(): TOffset;
    function ParseList(const Brackets: Boolean; const ParseElement: TParseFunction;
      const DelimiterType: TTokenType = ttComma; const CanEmpty: Boolean = True;
      const RootStmtList: Boolean = False): TOffset; overload;
    function ParseLoadDataStmt(): TOffset;
    function ParseLoadStmt(): TOffset;
    function ParseLoadXMLStmt(): TOffset;
    function ParseLockTableStmt(): TOffset;
    function ParseLockStmtItem(): TOffset;
    function ParseLoopStmt(const BeginLabel: TOffset = 0): TOffset;
    function ParseMatchFunc(): TOffset;
    function ParseMaxValue(): TOffset;
    function ParseOpenStmt(): TOffset;
    function ParseOptimizeTableStmt(): TOffset;
    function ParsePartitionIdent(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function ParsePL_SQLStmt(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function ParsePositionFunc(): TOffset;
    function ParsePrepareStmt(): TOffset;
    function ParseProcedureIdent(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function ParsePurgeStmt(): TOffset;
    function ParseProcedureParam(): TOffset;
    function ParseReleaseStmt(): TOffset;
    function ParseRenameStmt(): TOffset;
    function ParseRenameStmtTablePair(): TOffset;
    function ParseRenameStmtUserPair(): TOffset;
    function ParseRepairTableStmt(): TOffset;
    function ParseRepeatStmt(const BeginLabel: TOffset = 0): TOffset;
    function ParseResetStmt(): TOffset;
    function ParseReturnStmt(): TOffset;
    function ParseResetStmtOption(): TOffset;
    function ParseRevokeStmt(): TOffset;
    function ParseRollbackStmt(): TOffset;
    function ParseRoot(): TOffset;
    function ParseRoutineParamIdent(): TOffset;
    function ParseSavepointStmt(): TOffset;
    function ParseSchedule(): TOffset;
    function ParseSecretIdent(): TOffset;
    function ParseSelectStmt(const SubSelect: Boolean; const UnionSelect: Boolean = False; const TableFactor: Boolean = False): TOffset; overload;
    function ParseSelectStmtColumn(): TOffset;
    function ParseSelectStmtGroup(): TOffset;
    function ParseSelectStmtLimit(): TOffset;
    function ParseSelectStmtOrder(): TOffset;
    function ParseSelectStmtOrderBy(): TOffset;
    function ParseSelectStmtTableEscapedReference(): TOffset;
    function ParseSelectStmtTableFactor(): TOffset;
    function ParseSelectStmtTableFactorIndexHint(): TOffset;
    function ParseSelectStmtTableFactorSubquery(): TOffset;
    function ParseSelectStmtTableFactorOj(): TOffset;
    function ParseSelectStmtTableReference(): TOffset;
    function ParseSetNamesStmt(): TOffset;
    function ParseSetPasswordStmt(): TOffset;
    function ParseSetStmt(): TOffset;
    function ParseSetStmtAssignment(): TOffset;
    function ParseSetTransactionStmt(): TOffset;
    function ParseSetTransactionStmtCharacterisic(): TOffset;
    function ParseShowBinaryLogsStmt(): TOffset;
    function ParseShowBinlogEventsStmt(): TOffset;
    function ParseShowCharacterSetStmt(): TOffset;
    function ParseShowCollationStmt(): TOffset;
    function ParseShowColumnsStmt(): TOffset;
    function ParseShowCountStmt(): TOffset;
    function ParseShowCreateDatabaseStmt(): TOffset;
    function ParseShowCreateEventStmt(): TOffset;
    function ParseShowCreateFunctionStmt(): TOffset;
    function ParseShowCreateProcedureStmt(): TOffset;
    function ParseShowCreateTableStmt(): TOffset;
    function ParseShowCreateTriggerStmt(): TOffset;
    function ParseShowCreateUserStmt(): TOffset;
    function ParseShowCreateViewStmt(): TOffset;
    function ParseShowDatabasesStmt(): TOffset;
    function ParseShowEngineStmt(): TOffset;
    function ParseShowEnginesStmt(): TOffset;
    function ParseShowErrorsStmt(): TOffset;
    function ParseShowEventsStmt(): TOffset;
    function ParseShowFunctionStatusStmt(): TOffset;
    function ParseShowGrantsStmt(): TOffset;
    function ParseShowIndexStmt(): TOffset;
    function ParseShowMasterStatusStmt(): TOffset;
    function ParseShowOpenTablesStmt(): TOffset;
    function ParseShowPluginsStmt(): TOffset;
    function ParseShowPrivilegesStmt(): TOffset;
    function ParseShowProcedureStatusStmt(): TOffset;
    function ParseShowProcessListStmt(): TOffset;
    function ParseShowProfileStmt(): TOffset;
    function ParseShowProfileStmtType(): TOffset;
    function ParseShowProfilesStmt(): TOffset;
    function ParseShowRelaylogEventsStmt(): TOffset;
    function ParseShowRoutineCodeStmt(): TOffset;
    function ParseShowSlaveHostsStmt(): TOffset;
    function ParseShowSlaveStatusStmt(): TOffset;
    function ParseShowStatusStmt(): TOffset;
    function ParseShowTableStatusStmt(): TOffset;
    function ParseShowTablesStmt(): TOffset;
    function ParseShowTriggersStmt(): TOffset;
    function ParseShowVariablesStmt(): TOffset;
    function ParseShowWarningsStmt(): TOffset;
    function ParseShutdownStmt(): TOffset;
    function ParseSignalStmt(): TOffset;
    function ParseSignalStmtInformation(): TOffset;
    function ParseStartSlaveStmt(): TOffset;
    function ParseStartTransactionStmt(): TOffset;
    function ParseStopSlaveStmt(): TOffset;
    function ParseString(): TOffset;
    function ParseSubArea(const ParseArea: TParseFunction): TOffset;
    function ParseSubPartition(): TOffset;
    function ParseSubSelectStmt(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseSubquery(): TOffset;
    function ParseSubstringFunc(): TOffset;
    function ParseSumFunc(): TOffset;
    function ParseStmt(): TOffset;
    function ParseSymbol(const TokenType: TTokenType): TOffset;
    function ParseTableAliasIdent(): TOffset;
    function ParseTableIdent(): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function ParseTag(const KeywordIndex1: TWordList.TIndex;
      const KeywordIndex2: TWordList.TIndex = -1; const KeywordIndex3: TWordList.TIndex = -1;
      const KeywordIndex4: TWordList.TIndex = -1; const KeywordIndex5: TWordList.TIndex = -1;
      const KeywordIndex6: TWordList.TIndex = -1; const KeywordIndex7: TWordList.TIndex = -1): TOffset; overload;
    function ParseTimestampAddFunc(): TOffset;
    function ParseTimestampDiffFunc(): TOffset;
    function ParseToken(out Error: TError): TOffset;
    function ParseTriggerIdent(): TOffset;
    function ParseTrimFunc(): TOffset;
    function ParseTruncateTableStmt(): TOffset;
    function ParseUninstallPluginStmt(): TOffset;
    function ParseUnknownStmt(const FirstToken: TOffset): TOffset;
    function ParseUnlockTablesStmt(): TOffset;
    function ParseUpdateStmt(): TOffset;
    function ParseUpdateStmtValue(): TOffset;
    function ParseUseStmt(): TOffset;
    function ParseValue(const KeywordIndex: TWordList.TIndex; const Assign: TValueAssign; const Brackets: Boolean; const ParseItem: TParseFunction): TOffset; overload;
    function ParseValue(const KeywordIndex: TWordList.TIndex; const Assign: TValueAssign; const OptionIndices: TWordList.TIndices): TOffset; overload;
    function ParseValue(const KeywordIndex: TWordList.TIndex; const Assign: TValueAssign; const ParseValueNode: TParseFunction): TOffset; overload;
    function ParseValue(const KeywordIndices: TWordList.TIndices; const Assign: TValueAssign; const ParseValueNode: TParseFunction): TOffset; overload;
    function ParseVariableIdent(): TOffset;
    function ParseWeightStringFunc(): TOffset;
    function ParseWeightStringFuncLevel(): TOffset;
    function ParseWhileStmt(const BeginLabel: TOffset = 0): TOffset;
    function ParseXAStmt(): TOffset;
    procedure SaveToDebugHTMLFile(const Filename: string);
    procedure SaveToFormatedSQLFile(const Filename: string);
    procedure SaveToSQLFile(const Filename: string);
    procedure SetCharsets(ACharsets: string);
    procedure SetDatatypes(ADatatypes: string);
    function SetError(const AErrorCode: Byte; const Node: TOffset = 0): TOffset;
    procedure SetKeywords(AKeywords: string);
    procedure SetReservedWords(AReservedWords: string);
    property ErrorFound: Boolean read GetErrorFound;
    property InCompound: Boolean read GetInCompound;
    property InPL_SQL: Boolean read GetInPL_SQL;
    property NextToken[Index: Integer]: TOffset read GetNextToken;
    property Root: PRoot read GetRoot;

  protected
    function ChildPtr(const Node: TOffset): PChild;
    function CreateErrorMessage(const Error: TError): string;
    function IsChild(const Node: PNode): Boolean; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function IsChild(const Node: TOffset): Boolean; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function IsStmt(const Node: PNode): Boolean; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function IsStmt(const Node: TOffset): Boolean; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function IsOperator(const Node: TOffset): Boolean;
    function IsRange(const Node: PNode): Boolean; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function IsRange(const Node: TOffset): Boolean; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function IsSimpleDbIdent(const Node: PNode): Boolean; overload;
    function IsSimpleDbIdent(const Node: TOffset): Boolean; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function IsToken(const Node: PNode): Boolean; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function IsToken(const Node: TOffset): Boolean; overload; {$IFNDEF Debug} inline; {$ENDIF}
    function NewNode(const NodeType: TNodeType): TOffset; {$IFNDEF Debug} inline; {$ENDIF}
    function NodePtr(const Node: TOffset): PNode; {$IFNDEF Debug} inline; {$ENDIF}
    function NodeSize(const NodeType: TNodeType): Integer;
    function RangePtr(const Node: TOffset): PRange;
    function StmtPtr(const Node: TOffset): PStmt;
    function TokenPtr(const Token: TOffset): PToken; {$IFNDEF Debug} inline; {$ENDIF}
    property ReservedWords: string read GetReservedWords write SetReservedWords;

  public
    type
      TFileType = (ftSQL, ftFormattedSQL, ftDebugHTML);

    procedure Clear();
    constructor Create(const AMySQLVersion: Integer = 0);
    destructor Destroy(); override;
    function FormatSQL(): string;
    function LoadFromFile(const Filename: string): Boolean;
    function ParseSQL(const SQL: PChar; const Length: Integer; const UseCompletionList: Boolean = False): Boolean; overload;
    function ParseSQL(const Text: string; const AUseCompletionList: Boolean = False): Boolean; overload; {$IFNDEF Debug} inline; {$ENDIF}
    procedure SaveToFile(const Filename: string; const FileType: TFileType = ftSQL);
    property AnsiQuotes: Boolean read FAnsiQuotes write FAnsiQuotes;
    property Charsets: string read GetCharsets write SetCharsets;
    property CompletionList: TCompletionList read FCompletionList;
    property ConstantList: TWordList read FConstantList;
    property Datatypes: string read GetDatatypes write SetDatatypes;
    property ErrorCode: Byte read FirstError.Code;
    property ErrorLine: Integer read FirstError.Line;
    property ErrorMessage: string read GetErrorMessage;
    property ErrorPos: Integer read GetErrorPos;
    property ErrorToken: PToken read GetErrorToken;
    property FirstStmt: PStmt read GetFirstStmt;
    property FirstTokenAll: PToken read GetFirstTokenAll;
    property FunctionList: TWordList read FFunctionList;
    property Keywords: string read GetKeywords write SetKeywords;
    property MySQLVersion: Integer read FMySQLVersion;
  end;

function AddDatabaseName(const Stmt: TSQLParser.PStmt; const DatabaseName: string): string;
function ExpandSelectStmtWhereClause(const Stmt: TSQLParser.PStmt; const WhereClause: string): string;
function GetOrderFromSelectStmt(const Stmt: TSQLParser.PStmt; out FieldNames, DescFieldNames: string): Boolean;
function RemoveDatabaseName(const Stmt: TSQLParser.PStmt; const DatabaseName: string; const CaseSensitive: Boolean = False): string;
function RemoveTableName(const Stmt: TSQLParser.PStmt; const TableName: string; const CaseSensitive: Boolean = False): string; overload;
function ReplaceSelectStmtLimit(const Stmt: TSQLParser.PStmt; const Offset, RowCount: Integer): string;

const
  PE_Success = 0; // No error

  PE_Unknown = 1; // Unknown error

  // Bugs while parsing Tokens:
  PE_IncompleteToken = 2; // Incomplete string or identifier near
  PE_UnexpectedChar = 3; // Unexpected character

  // Bugs with MySQL conditional options
  PE_InvalidMySQLCond = 4; // Invalid version number in MySQL conditional option
  PE_NestedMySQLCond = 5; // Nested conditional MySQL conditional options

  // Bugs while parsing Stmts:
  PE_IncompleteStmt = 6; // Incompleted statement
  PE_UnexpectedToken = 7; // Unexpected character
  PE_ExtraToken = 8; // Unexpected character

  // Bugs in the order of Stmts
  PE_UnexpectedStmt = 9; // Stmt not allowed here

implementation {***************************************************************}

uses
  Windows,
  Classes, SysUtils, StrUtils, SysConst, Math,
uDeveloper, uProfiling,
  SQLUtils;

resourcestring
  SUnknownError = 'Unknown Error';
  SDatatypeNotFound = 'Datatype "%s" not found';
  SKeywordNotFound = 'Keyword "%s" not found';
  SOutOfMemory = 'Out of memory (%d)';

const
  CP_UNICODE = 1200;
  BOM_UTF8: PAnsiChar = Chr($EF) + Chr($BB) + Chr($BF);
  BOM_UNICODE_LE: PAnsiChar = Chr($FF) + Chr($FE);

  DefaultNodesMemSize = 100 * 1024;

  IndentSize = 2;

  MySQLCharsets =
    'armscii8,big5,binary,cp1250,cp1251,cp1256,cp1257,cp850,cp852,' +
		'cp866,cp932,dec8,eucjpms,euckr,gb18030,gb2312,gbk,geostd8,greek,hebrew,' +
		'hp8,keybcs2,koi8r,koi8u,latin1,latin2,latin5,latin7,macce,macroman,sjis,' +
		'swe7,tis620,ucs2,ujis,utf16,utf16le,utf32,utf8,utf8mb4';

  MySQLConstants =
    'CURRENT_DATE,CURRENT_TIME,CURRENT_TIMESTAMP,CURRENT_USER,DEFAULT,FALSE,' +
    'LOCALTIME,LOCALTIMESTAMP,NULL,OFF,ON,TRUE,UNKNOWN,UTC_DATE,UTC_TIME,' +
    'UTC_TIMESTAMP';

  MySQLDatatypes =
    'BIGINT,BINARY,BIT,BLOB,BOOL,BOOLEAN,BYTE,CHAR,CHARACTER,DEC,DECIMAL,' +
    'DATE,DATETIME,DOUBLE,ENUM,FLOAT,GEOMETRY,GEOMETRYCOLLECTION,INT,INT4,' +
    'INTEGER,LARGEINT,LINESTRING,JSON,LONG,LONGBLOB,LONGTEXT,MEDIUMBLOB,' +
    'MEDIUMINT,MEDIUMTEXT,MULTILINESTRING,MULTIPOINT,MULTIPOLYGON,' +
    'NUMBER,NUMERIC,NCHAR,NVARCHAR,POINT,POLYGON,REAL,SERIAL,SET,SIGNED,' +
    'SMALLINT,TEXT,TIME,TIMESTAMP,TINYBLOB,TINYINT,TINYTEXT,UNSIGNED,' +
    'VARBINARY,VARCHAR,YEAR';

  MySQLEngineTypes =
    'ARCHIVE,BDB,BERKELEYDB,BLACKHOLE,CSV,EXAMPLE,FEDERATED,HEAP,INNOBASE,' +
    'InnoDB,ISAM,MEMORY,MERGE,MRG_ISAM,MRG_MYISAM,MyISAM,NDB,NDBCLUSTER';

  MySQLFunctions =
    'ABS,ACOS,ADDDATE,ADTIME,AES_DECRYPT,AES_ENCRYPT,ANY_VALUE,AREA,' +
    'ASBINARY,ASCII,ASIN,ASTEXT,ASWKBASWKT,ASYMMETRIC_DECRYPT,' +
    'ASYMMETRIC_DERIVE,ASYMMETRIC_ENCRYPT,ASYMMETRIC_SIGN,ASYMMETRIC_VERIFY,' +
    'ATAN,ATAN,ATAN2,AVG,BENCHMARK,BIN,BINARY,BIT_AND,BIT_COUNT,BIT_LENGTH,' +
    'BIT_OR,BIT_XOR,BUFFER,CAST,CEIL,CEILING,CENTROID,CHAR,CHAR_LENGTH,' +
    'CHARACTER_LENGTH,CHARSET,COALESCE,COERCIBILITY,COLLATION,COMPRESS,' +
    'CONCAT,CONCAT_WS,CONNECTION_ID,CONTAINS,CONV,CONVERT,CONVERT_TZ,' +
    'CONVEXHULL,COS,COT,COUNT,CRC32,CREATE_ASYMMETRIC_PRIV_KEY,' +
    'CREATE_ASYMMETRIC_PUB_KEY,CREATE_DH_PARAMETERS,CREATE_DIGEST,CROSSES,' +
    'CURDATE,CURRENT_DATE,CURRENT_TIME,CURRENT_TIMESTAMP,CURRENT_USER,' +
    'CURTIME,DATABASE,DATE,DATE_ADD,DATE_FORMAT,DATE_SUB,DATEDIFF,DAY,' +
    'DAYNAME,DAYOFMONTH,DAYOFWEEK,DAYOFYEAR,DECODE,DEFAULT,DEGREES,' +
    'DES_DECRYPT,DES_ENCRYPT,DIMENSION,DISJOINT,DISTANCE,ELT,ENCODE,ENCRYPT,' +
    'ENDPOINT,ENVELOPE,EQUALS,EXP,EXPORT_SET,EXTERIORRING,EXTRACT,' +
    'EXTRACTVALUE,FIELD,FIND_IN_SET,FLOOR,FORMAT,FOUND_ROWS,FROM_BASE64,' +
    'FROM_DAYS,FROM_UNIXTIME,GEOMCOLLFROMTEXT,GEOMCOLLFROMWKB,' +
    'GEOMETRYCOLLECTION,GEOMETRYCOLLECTIONFROMTEXT,GEOMETRYCOLLECTIONFROMWKB,' +
    'GEOMETRYFROMTEXT,GEOMETRYFROMWKB,GEOMETRYN,GEOMETRYTYPE,GEOMFROMTEXT,' +
    'GEOMFROMWKB,GET_FORMAT,GET_LOCK,GLENGTH,GREATEST,GROUP_CONCAT,' +
    'GTID_SUBSET,GTID_SUBTRACT,HEX,HOUR,IF,IFNULL,INET_ATON,INET_NTOA,' +
    'INET6_ATON,INET6_NTOA,INSERT,INSTR,INTERIORRINGN,INTERSECTS,INTERVAL,' +
    'IS_FREE_LOCK,IS_IPV4,IS_IPV4_COMPAT,IS_IPV4_MAPPED,IS_IPV6,IS_USED_LOCK,' +
    'ISCLOSED,ISEMPTY,ISNULL,ISSIMPLE,JSON_APPEND,JSON_ARRAY,' +
    'JSON_ARRAY_APPEND,JSON_ARRAY_INSERT,JSON_CONTAINS,JSON_CONTAINS_PATH,' +
    'JSON_DEPTH,JSON_EXTRACT,JSON_INSERT,JSON_KEYS,JSON_LENGTH,JSON_MERGE,' +
    'JSON_OBJECT,JSON_QUOTE,JSON_REMOVE,JSON_REPLACE,JSON_SEARCH,JSON_SET,' +
    'JSON_TYPE,JSON_UNQUOTE,JSON_VALID,LAST_DAY,LAST_INSERT_ID,LCASE,LEAST,' +
    'LEFT,LENGTH,LINEFROMTEXT,LINEFROMWKB,LINESTRING,LINESTRINGFROMTEXT,' +
    'LINESTRINGFROMWKB,LN,LOAD_FILE,LOCALTI,LOCALTIME,LOCALTIMESTAMP,LOCATE,' +
    'LOG,LOG10,LOG2,LOWER,LPAD,LTRIM,MAKE_SET,MAKEDATE,MAKETIME,' +
    'MASTER_POS_WAIT,MAX,MBRCONTAINS,MBRCOVEREDBY,MBRCOVERS,MBRDISJOINT,' +
    'MBREQUAL,MBREQUALS,MBRINTERSECTS,MBROVERLAPS,MBRTOUCHES,MBRWITHIN,MD5,' +
    'MICROSECOND,MID,MIN,MINUTE,MLINEFROMTEXT,MLINEFROMWKB,MOD,MONTH,' +
    'MONTHNAME,MPOINTFROMTEXT,MPOINTFROMWKB,MPOLYFROMTEXT,MPOLYFROMWKB,' +
    'MULTILINESTRING,MULTILINESTRINGFROMTEXT,MULTILINESTRINGFROMWKB,' +
    'MULTIPOINT,MULTIPOINTFROMTEXT,MULTIPOINTFROMWKB,MULTIPOLYGON,' +
    'MULTIPOLYGONFROMTEXT,MULTIPOLYGONFROMWKB,NAME_CONST,NOW,NULLIF,' +
    'NUMGEOMETRIES,NUMINTERIORRINGS,NUMPOINTS,OCT,OCTET_LENGTH,OLD_PASSWORD,' +
    'ORD,OVERLAPS,PASSWORD,PERIOD_ADD,PERIOD_DIFF,PI,POINT,POINTFROMTEXT,' +
    'POINTFROMWKB,POINTN,POLYFROMTEXT,POLYFROMWKB,POLYGON,POLYGONFROMTEXT,' +
    'POLYGONFROMWKB,POSITION,POW,POWER,QUARTER,QUOTE,RADIANS,RAND,' +
    'RANDOM_BYTES,RELEASE_ALL_LOCKS,RELEASE_LOCK,REPEAT,REPLACE,REVERSE,' +
    'RIGHT,ROUND,ROW_COUNT,RPAD,RTRIM,SCHEMA,SEC_TO_TIME,SECOND,SESSION_USER,' +
    'SHA,SHA1,SHA2,SIGN,SIN,SLEEP,SOUNDEX,SPACE,SQRT,SRID,ST_AREA,' +
    'ST_ASBINARY,ST_ASGEOJSON,ST_ASTEXT,ST_ASWKB,ST_ASWKT,ST_BUFFER,' +
    'ST_BUFFER_STRATEGY,ST_CENTROID,ST_CONTAINS,ST_CONVEXHULL,ST_CROSSES,' +
    'ST_DIFFERENCE,ST_DIMENSION,ST_DISJOINT,ST_DISTANCE,ST_DISTANCE_SPHERE,' +
    'ST_ENDPOINT,ST_ENVELOPE,ST_EQUALS,ST_EXTERIORRING,ST_GEOHASH,' +
    'ST_GEOMCOLLFROMTEXT,ST_GEOMCOLLFROMTXT,ST_GEOMCOLLFROMWKB,' +
    'ST_GEOMETRYCOLLECTIONFROMTEXT,ST_GEOMETRYCOLLECTIONFROMWKB,' +
    'ST_GEOMETRYFROMTEXT,ST_GEOMETRYFROMWKB,ST_GEOMETRYN,ST_GEOMETRYTYPE,' +
    'ST_GEOMFROMGEOJSON,ST_GEOMFROMTEXT,ST_GEOMFROMWKB,ST_INTERIORRINGN,' +
    'ST_INTERSECTION,ST_INTERSECTS,ST_ISCLOSED,ST_ISEMPTY,ST_ISSIMPLE,' +
    'ST_ISVALID,ST_LATFROMGEOHASH,ST_LENGTH,ST_LINEFROMTEXT,ST_LINEFROMWKB,' +
    'ST_LINESTRINGFROMTEXT,ST_LINESTRINGFROMWKB,ST_LONGFROMGEOHASH,' +
    'ST_MAKEENVELOPE,ST_MLINEFROMTEXT,ST_MLINEFROMWKB,ST_MPOINTFROMTEXT,' +
    'ST_MPOINTFROMWKB,ST_MPOLYFROMTEXT,ST_MPOLYFROMWKB,' +
    'ST_MULTILINESTRINGFROMTEXT,ST_MULTILINESTRINGFROMWKB,' +
    'ST_MULTIPOINTFROMTEXT,ST_MULTIPOINTFROMWKB,ST_MULTIPOLYGONFROMTEXT,' +
    'ST_MULTIPOLYGONFROMWKB,ST_NUMGEOMETRIES,ST_NUMINTERIORRING,' +
    'ST_NUMINTERIORRINGS,ST_NUMPOINTS,ST_OVERLAPS,ST_POINTFROMGEOHASH,' +
    'ST_POINTFROMTEXT,ST_POINTFROMWKB,ST_POINTN,ST_POLYFROMTEXT,' +
    'ST_POLYFROMWKB,ST_POLYGONFROMTEXT,ST_POLYGONFROMWKB,ST_SIMPLIFY,ST_SRID,' +
    'ST_STARTPOINT,ST_SYMDIFFERENCE,ST_TOUCHES,ST_UNION,ST_VALIDATE,' +
    'ST_WITHIN,ST_X,ST_Y,STARTPOINT,STD,STDDEV,STDDEV_POP,STDDEV_SAMP,' +
    'STR_TO_DATE,STRCMP,SUBDATE,SUBSTR,SUBSTRING,SUBSTRING_INDEX,SUBTIME,SUM,' +
    'SYSDATE,SYSTEM_USER,TAN,TIME,TIME_FORMAT,TIME_TO_SEC,TIMEDIFF,TIMESTAMP,' +
    'TIMESTAMPADD,TIMESTAMPDIFF,TO_BASE64,TO_DAYS,TO_SECONDS,TOUCHES,TRIM,' +
    'TRUNCATE,UCASE,UNCOMPRESS,UNCOMPRESSED_LENGTH,UNHEX,UNIX_TIMESTAMP,' +
    'UPDATEXML,UPPER,USER,UTC_DATE,UTC_TIME,UTC_TIMESTAMP,UUID,UUID_SHORT,' +
    'VALIDATE_PASSWORD_STRENGTH,VALUES,VAR_POP,VAR_SAMP,VARIANCE,VERSION,' +
    'WAIT_FOR_EXECUTED_GTID_SET,WAIT_UNTIL_SQL_THREAD_AFTER_GTIDS,WEEK,' +
    'WEEKDAY,WEEKOFYEAR,WEIGHT_STRING,WITHIN,X,Y,YEAR,YEARWEEK';

  MySQLKeywords =
    'ANY,SOME,STATS_SAMPLE_PAGES,DUAL,TABLE_CHECKSUM,NEW,OLD,ONLINE,ERROR,' +
    'SLOW,RELAY,GENERAL,SQL_TSI_MICROSECOND,SQL_TSI_SECOND,SQL_TSI_MINUTE,' +
    'SQL_TSI_HOUR,SQL_TSI_DAY,SQL_TSI_WEEK,SQL_TSI_MONTH,SQL_TSI_QUARTER,' +
    'SQL_TSI_YEAR,INSTALL,UNINSTALL,PLUGIN,' +

    'ACCOUNT,ACTION,ADD,AFTER,AGAINST,ALGORITHM,ALL,ALTER,ALWAYS,ANALYZE,AND,' +
    'AS,ASC,ASCII,AT,AUTO_INCREMENT,AVG_ROW_LENGTH,BEFORE,BEGIN,' +
    'BETWEEN,BINARY,BINLOG,BLOCK,BOOLEAN,BOTH,BTREE,BY,CACHE,CALL,CASCADE,' +
    'CASCADED,CASE,CATALOG_NAME,CHANGE,CHANGED,CHANNEL,CHAIN,CHARACTER,' +
    'CHARSET,CHECK,CHECKSUM,CLASS_ORIGIN,CLIENT,CLOSE,COALESCE,CODE,COLLATE,' +
    'COLLATION,COLUMN,COLUMN_FORMAT,COLUMN_NAME,COLUMNS,COMMENT,COMMIT,' +
    'COMMITTED,COMPACT,COMPLETION,COMPRESS,COMPRESSED,CONCURRENT,CONDITION,' +
    'CONNECTION,CONSISTENT,CONSTRAINT,CONSTRAINT_CATALOG,CONSTRAINT_NAME,' +
    'CONSTRAINT_SCHEMA,CONTAINS,CONTEXT,CONTINUE,CONVERT,COPY,' +
    'CPU,CREATE,CROSS,CURRENT,CURRENT_DATE,CURRENT_TIME,CURRENT_TIMESTAMP,' +
    'CURRENT_USER,CURSOR,CURSOR_NAME,DATA,DATABASE,DATABASES,DATAFILE,DAY,' +
    'DAY_HOUR,DAY_MICROSECOND,DAY_MINUTE,DAY_SECOND,DEALLOCATE,DECLARE,' +
    'DEFAULT,DEFINER,DELAY_KEY_WRITE,DELAYED,DELETE,DESC,DESCRIBE,' +
    'DETERMINISTIC,DIAGNOSTICS,DIRECTORY,DISABLE,DISCARD,DISK,DISTINCT,' +
    'DISTINCTROW,DIV,DO,DROP,DUMPFILE,DUPLICATE,DYNAMIC,EACH,ELSE,ELSEIF,' +
    'ENABLE,ENCLOSED,END,ENDS,ENGINE,ENGINES,ERRORS,ESCAPE,ESCAPED,EVENT,' +
    'EVENTS,EVERY,EXCHANGE,EXCLUSIVE,EXECUTE,EXISTS,EXPANSION,EXPIRE,EXPLAIN,' +
    'EXIT,EXTENDED,FALSE,FAST,FAULTS,FETCH,FILE_BLOCK_SIZE,FLUSH,FIELDS,FILE,' +
    'FIRST,FIXED,FOLLOWS,FOR,FORCE,FORMAT,FOREIGN,FOUND,FROM,FULL,FULLTEXT,' +
    'FUNCTION,GENERATED,GET,GLOBAL,GRANT,GRANTS,GROUP,HANDLER,HASH,HAVING,' +
    'HELP,HIGH_PRIORITY,HOST,HOSTS,HOUR,HOUR_MICROSECOND,HOUR_MINUTE,' +
    'HOUR_SECOND,IDENTIFIED,IF,IGNORE,IGNORE_SERVER_IDS,IMPORT,IN,INDEX,' +
    'INDEXES,INFILE,INITIAL_SIZE,INNER,INNODB,INOUT,INPLACE,INSTANCE,INSERT,' +
    'INSERT_METHOD,INTERVAL,INTO,INVOKER,IO,IPC,IS,ISOLATION,ITERATE,JOIN,' +
    'JSON,KEY,KEY_BLOCK_SIZE,KEYS,KILL,LANGUAGE,LAST,LEADING,LEAVE,LEFT,LESS,' +
    'LEVEL,LIKE,LIMIT,LINEAR,LINES,LIST,LOAD,LOCAL,' +
    'LOCK,LOGS,LOOP,LOW_PRIORITY,MASTER,MASTER_AUTO_POSITION,MASTER_BIND,' +
    'MASTER_CONNECT_RETRY,MASTER_DELAY,MASTER_HEARTBEAT_PERIOD,MASTER_HOST,' +
    'MASTER_LOG_FILE,MASTER_LOG_POS,MASTER_PASSWORD,MASTER_PORT,' +
    'MASTER_RETRY_COUNT,MASTER_SSL,MASTER_SSL_CA,MASTER_SSL_CAPATH,' +
    'MASTER_SSL_CERT,MASTER_SSL_CIPHER,MASTER_SSL_CRL,MASTER_SSL_CRLPATH,' +
    'MASTER_SSL_KEY,MASTER_SSL_VERIFY_SERVER_CERT,MASTER_TLS_VERSION,' +
    'MASTER_USER,MATCH,MAX_QUERIES_PER_HOUR,MAX_ROWS,' +
    'MAX_CONNECTIONS_PER_HOUR,MAX_STATEMENT_TIME,MAX_UPDATES_PER_HOUR,' +
    'MAX_USER_CONNECTIONS,MAXVALUE,MEDIUM,MEMORY,MERGE,MESSAGE_TEXT,' +
    'MICROSECOND,MIGRATE,MIN_ROWS,MINUTE,MINUTE_MICROSECOND,MINUTE_SECOND,' +
    'MOD,MODE,MODIFIES,MODIFY,MONTH,MUTEX,MYSQL_ERRNO,NAME,NAMES,NATIONAL,' +
    'NATURAL,NEVER,NEXT,NO,NONE,NOT,NULL,NO_WRITE_TO_BINLOG,NUMBER,OFFSET,' +
    'OJ,ON,ONE,ONLY,OPEN,OPTIMIZE,OPTION,OPTIONALLY,OPTIONS,OR,ORDER,OUT,' +
    'OUTER,OUTFILE,OWNER,PACK_KEYS,PAGE,PAGE_CHECKSUM,PARSER,PARTIAL,' +
    'PARTITION,PARTITIONING,PARTITIONS,PASSWORD,PERSISTENT,PHASE,PLUGINS,' +
    'PORT,PRECEDES,PREPARE,PRESERVE,PRIMARY,PRIVILEGES,PROCEDURE,PROCESS,' +
    'PROCESSLIST,PROFILE,PROFILES,PROXY,PURGE,QUARTER,QUERY,QUICK,RANGE,READ,' +
    'READS,REBUILD,RECOVER,REDUNDANT,REFERENCES,REGEXP,RELAYLOG,RELEASE,' +
    'RELAY_LOG_FILE,RELAY_LOG_POS,RELOAD,REMOVE,RENAME,REORGANIZE,REPAIR,' +
    'REPEAT,REPEATABLE,REPLACE,REPLICATION,REQUIRE,RESET,RESIGNAL,RESTRICT,' +
    'RESUME,RETURN,RETURNED_SQLSTATE,RETURNS,REVERSE,REVOKE,RIGHT,RLIKE,' +
    'ROLLBACK,ROLLUP,ROTATE,ROUTINE,ROW,ROW_COUNT,ROW_FORMAT,ROWS,SAVEPOINT,' +
    'SCHEDULE,SCHEMA,SCHEMA_NAME,SECOND,SECOND_MICROSECOND,SECURITY,SELECT,' +
    'SEPARATOR,SERIALIZABLE,SERVER,SESSION,SET,SHARE,SHARED,SHOW,SHUTDOWN,' +
    'SIGNAL,SIGNED,SIMPLE,SLAVE,SNAPSHOT,SOCKET,SONAME,SOUNDS,SOURCE,SPATIAL,' +
    'SQL,SQL_BIG_RESULT,SQL_BUFFER_RESULT,SQL_CACHE,SQL_CALC_FOUND_ROWS,' +
    'SQL_NO_CACHE,SQL_SMALL_RESULT,SQLEXCEPTION,SQLSTATE,SQLWARNING,STACKED,' +
    'STARTING,START,STARTS,STATS_AUTO_RECALC,STATS_PERSISTENT,STATUS,STOP,' +
    'STORAGE,STORED,STRAIGHT_JOIN,SUBCLASS_ORIGIN,SUBPARTITION,SUBPARTITIONS,' +
    'SUPER,SUSPEND,SWAPS,SWITCHES,TABLE,TABLE_NAME,TABLES,TABLESPACE,' +
    'TEMPORARY,TEMPTABLE,TERMINATED,THAN,THEN,TO,TRADITIONAL,TRAILING,' +
    'TRANSACTION,TRANSACTIONAL,TRIGGER,TRIGGERS,TRUE,TRUNCATE,TYPE,' +
    'UNCOMMITTED,UNDEFINED,UNDO,UNICODE,UNION,UNIQUE,UNKNOWN,UNLOCK,UNSIGNED,' +
    'UNTIL,UPDATE,UPGRADE,USAGE,USE,USE_FRM,USER,USING,VALIDATION,VALUE,' +
    'VALUES,VARIABLES,VIEW,VIRTUAL,WAIT,WARNINGS,WEEK,WHEN,WHERE,WHILE,' +
    'WRAPPER,WRITE,WITH,WITHOUT,WORK,XA,XID,XML,XOR,YEAR,YEAR_MONTH,ZEROFILL';

  MySQLReservedWords =
    'ACCESSIBLE,ADD,ALL,ALTER,ANALYZE,AND,AS,ASC,ASENSITIVE,BEFORE,BETWEEN,' +
    'BIGINT,BINARY,BLOB,BOTH,BY,CALL,CASCADE,CASE,CHANGE,CHAR,CHARACTER,' +
    'CHECK,COLLATE,COLUMN,CONDITION,CONSTRAINT,CONTINUE,CONVERT,CREATE,' +
    'CROSS,CURRENT_DATE,CURRENT_TIME,CURRENT_TIMESTAMP,CURRENT_USER,CURSOR,' +
    'DATABASE,DATABASES,DAY_HOUR,DAY_MICROSECOND,DAY_MINUTE,DAY_SECOND,' +
    'DEC,DECIMAL,DECLARE,DEFAULT,DELAYED,DELETE,DESC,DESCRIBE,DETERMINISTIC,' +
    'DISTINCT,DISTINCTROW,DIV,DOUBLE,DROP,DUAL,EACH,ELSE,ELSEIF,ENCLOSED,' +
    'ESCAPED,EXISTS,EXIT,EXPLAIN,FALSE,FETCH,FLOAT,FLOAT4,FLOAT8,FOR,FORCE,' +
    'FOREIGN,FROM,FULLTEXT,GENERATED,GET,GRANT,GROUP,HAVING,HIGH_PRIORITY,' +
    'HOUR_MICROSECOND,HOUR_MINUTE,HOUR_SECOND,IF,IGNORE,IN,INDEX,INFILE,' +
    'INNER,INOUT,INSENSITIVE,INSERT,INT,INT1,INT2,INT3,INT4,INT8,INTEGER,' +
    'INTERVAL,INTO,IO_AFTER_GTIDS,IO_BEFORE_GTIDS,IS,ITERATE,JOIN,KEY,KEYS,' +
    'KILL,LEADING,LEAVE,LEFT,LIKE,LIMIT,LINEAR,LINES,LOAD,LOCALTIME,' +
    'LOCALTIMESTAMP,LOCK,LONG,LONGBLOB,LONGTEXT,LOOP,LOW_PRIORITY,' +
    'MASTER_BIND,MASTER_SSL_VERIFY_SERVER_CERT,MATCH,MAXVALUE,MEDIUMBLOB,' +
    'MEDIUMINT,MEDIUMTEXT,MIDDLEINT,MINUTE_MICROSECOND,MINUTE_SECOND,MOD,' +
    'MODIFIES,NATURAL,NO_WRITE_TO_BINLOG,NOT,NULL,NUMERIC,ON,OPTIMIZE,' +
    'OPTIMIZER_COSTS,OPTION,OPTIONALLY,OR,ORDER,OUT,OUTER,OUTFILE,PARTITION,' +
    'PRECISION,PRIMARY,PROCEDURE,PURGE,RANGE,READ,READ_WRITE,READS,REAL,' +
    'REFERENCES,REGEXP,RELEASE,RENAME,REPEAT,REPLACE,REQUIRE,RESIGNAL,' +
    'RESTRICT,RETURN,REVOKE,RIGHT,RLIKE,SCHEMA,SCHEMAS,SECOND_MICROSECOND,' +
    'SELECT,SENSITIVE,SEPARATOR,SET,SHOW,SIGNAL,SMALLINT,SPATIAL,SPECIFIC,' +
    'SQL,SQL_BIG_RESULT,SQL_CALC_FOUND_ROWS,SQL_SMALL_RESULT,SQLEXCEPTION,' +
    'SQLSTATE,SQLWARNING,SSL,STARTING,STORED,STRAIGHT_JOIN,TABLE,TERMINATED,' +
    'THEN,TINYBLOB,TINYINT,TINYTEXT,TO,TRAILING,TRIGGER,TRUE,UNDO,UNION,' +
    'UNIQUE,UNLOCK,UNSIGNED,UPDATE,USAGE,USE,USING,UTC_DATE,UTC_TIME,' +
    'UTC_TIMESTAMP,VALUES,VARBINARY,VARCHAR,VARCHARACTER,VARYING,VIRTUAL,' +
    'WHEN,WHERE,WHILE,WITH,WRITE,XOR,YEAR_MONTH,ZEROFILL';

var
  Profile: TProfile;

function HTMLEscape(const Value: PChar; const ValueLen: Integer; const Escaped: PChar; const EscapedLen: Integer): Integer; overload;
label
  StartL,
  StringL, String2, String3, String4,
  MoveReplace, MoveReplaceL, MoveReplaceE,
  PosL, PosE,
  FindPos, FindPos2,
  Error,
  Finish;
const
  SearchLen = 6;
  Search: array [0 .. SearchLen - 1] of Char = (#0, #10, #13, '"', '<', '>');
  Replace: array [0 .. SearchLen - 1] of PChar = ('', '<br>' + #13#10, '', '&quot;', '&lt;', '&gt;');
var
  Len: Integer;
  Poss: packed array [0 .. SearchLen - 1] of Cardinal;
begin
  Result := 0;
  Len := EscapedLen;

  asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        PUSH DS                          // string operations uses ES
        POP ES
        CLD                              // string operations uses forward direction

        MOV ESI,PChar(Value)             // Copy characters from Value
        MOV EDI,Escaped                  //   to Escaped
        MOV ECX,ValueLen                 // Length of Value string

      // -------------------

        MOV EBX,0                        // Numbers of characters in Search
      StartL:
        CALL FindPos                     // Find Search character Pos
        INC EBX                          // Next character in Search
        CMP EBX,SearchLen                // All Search characters handled?
        JNE StartL                       // No!

      // -------------------

        CMP ECX,0                        // Empty string?
        JE Finish                        // Yes!
      StringL:
        PUSH ECX

        MOV ECX,0                        // Numbers of characters in Search
        MOV EBX,-1                       // Index of first Pos
        MOV EAX,0                        // Last character
        LEA EDX,Poss
      PosL:
        CMP [EDX + ECX * 4],EAX          // Pos before other Poss?
        JB PosE                          // No!
        MOV EBX,ECX                      // Index of first Pos
        MOV EAX,[EDX + EBX * 4]          // Value of first Pos
      PosE:
        INC ECX                          // Next Pos
        CMP ECX,SearchLen                // All Poss compared?
        JNE PosL                         // No!

        POP ECX

        SUB ECX,EAX                      // Copy normal characters from Value
        JZ String3                       // End of Value!
        ADD @Result,ECX                  // Characters to copy
        CMP Escaped,0                    // Calculate length only?
        JE String2                       // Yes!
        CMP Len,ECX                      // Enough character left in Escaped?
        JB Error                         // No!
        SUB Len,ECX                      // Calc new len space in Escaped
        REPNE MOVSW                      // Copy normal characters to Result
        JMP String3
      String2:
        SHL ECX,1
        ADD ESI,ECX

      String3:
        MOV ECX,EAX
        JECXZ Finish                     // End of Value!

        ADD ESI,2                        // Step of Search character


      MoveReplace:
        PUSH ESI
        LEA EDX,Replace                  // Insert Replace string
        MOV ESI,[EDX + EBX * 4]
      MoveReplaceL:
        LODSW                            // Get Replace character
        CMP AX,0                         // End of Replace?
        JE MoveReplaceE                  // Yes!
        INC @Result                      // One characters in replace
        CMP Escaped,0                    // Calculate length only?
        JE MoveReplaceL                  // Yes!
        CMP Len,ECX                      // Enough character left in Escaped?
        JB Error                         // No!
        STOSW                            // Put character in Result
        JMP MoveReplaceL
      MoveReplaceE:
        POP ESI


      String4:
        DEC ECX                          // Ignore Search character
        JZ Finish                        // All character in Value handled!
        CALL FindPos                     // Find Search character
        JMP StringL

      // -------------------

      FindPos:
        PUSH ECX
        PUSH EDI
        LEA EDI,Search                   // Character to Search
        MOV AX,[EDI + EBX * 2]
        MOV EDI,ESI                      // Search in Value
        REPNE SCASW                      // Find Search character
        JNE FindPos2                     // Search character not found!
        INC ECX
      FindPos2:
        LEA EDI,Poss
        MOV [EDI + EBX * 4],ECX          // Store found Position
        POP EDI
        POP ECX
        RET

      // -------------------

      Error:
        MOV @Result,0                    // Too few space in Escaped

      Finish:
        POP EBX
        POP EDI
        POP ESI
        POP ES
  end;
end;

function HTMLEscape(const Value: string): string; overload;
var
  Len: Integer;
begin
  Len := HTMLEscape(PChar(Value), Length(Value), nil, 0);
  SetLength(Result, Len);
  HTMLEscape(PChar(Value), Length(Value), PChar(Result), Len);
end;

function WordIndices(const Index0: TSQLParser.TWordList.TIndex;
  const Index1: TSQLParser.TWordList.TIndex = -1;
  const Index2: TSQLParser.TWordList.TIndex = -1;
  const Index3: TSQLParser.TWordList.TIndex = -1;
  const Index4: TSQLParser.TWordList.TIndex = -1;
  const Index5: TSQLParser.TWordList.TIndex = -1;
  const Index6: TSQLParser.TWordList.TIndex = -1): TSQLParser.TWordList.TIndices;
begin
  Result[0] := Index0;
  Result[1] := Index1;
  Result[2] := Index2;
  Result[3] := Index3;
  Result[4] := Index4;
  Result[5] := Index5;
  Result[6] := Index6;
end;

{ TSQLParser.TStringBuffer ****************************************************}

procedure TSQLParser.TStringBuffer.Clear();
begin
  Buffer.Write := Buffer.Mem;
end;

constructor TSQLParser.TStringBuffer.Create(const InitialLength: Integer);
begin
  Buffer.Mem := nil;
  Buffer.MemSize := 0;
  Buffer.Write := nil;

  Reallocate(InitialLength);
end;

procedure TSQLParser.TStringBuffer.Delete(const Start: Integer; const Length: Integer);
begin
  Move(Buffer.Mem[Start + Length], Buffer.Mem[Start], Size - Length);
  Buffer.Write := Pointer(Integer(Buffer.Write) - Length);
end;

destructor TSQLParser.TStringBuffer.Destroy();
begin
  FreeMem(Buffer.Mem);

  inherited;
end;

function TSQLParser.TStringBuffer.GetData(): Pointer;
begin
  Result := Pointer(Buffer.Mem);
end;

function TSQLParser.TStringBuffer.GetLength(): Integer;
begin
  Result := (Integer(Buffer.Write) - Integer(Buffer.Mem)) div SizeOf(Buffer.Mem[0]);
end;

function TSQLParser.TStringBuffer.GetSize(): Integer;
begin
  Result := Integer(Buffer.Write) - Integer(Buffer.Mem);
end;

function TSQLParser.TStringBuffer.GetText(): PChar;
begin
  Result := Buffer.Mem;
end;

function TSQLParser.TStringBuffer.Read(): string;
begin
  SetString(Result, PChar(Buffer.Mem), Size div SizeOf(Result[1]));
end;

procedure TSQLParser.TStringBuffer.Reallocate(const NeededLength: Integer);
var
  Index: Integer;
begin
  if (Buffer.MemSize = 0) then
  begin
    Buffer.MemSize := NeededLength * SizeOf(Buffer.Write[0]);
    GetMem(Buffer.Mem, Buffer.MemSize);
    Buffer.Write := Buffer.Mem;
  end
  else if (Size + NeededLength * SizeOf(Buffer.Mem[0]) > Buffer.MemSize) then
  begin
    Index := Size div SizeOf(Buffer.Write[0]);
    Inc(Buffer.MemSize, 2 * (Size + NeededLength * SizeOf(Buffer.Mem[0]) - Buffer.MemSize));
    ReallocMem(Buffer.Mem, Buffer.MemSize);
    Buffer.Write := @Buffer.Mem[Index];
  end;
end;

procedure TSQLParser.TStringBuffer.Write(const Text: PChar; const Length: Integer);
begin
  if (Length > 0) then
  begin
    Reallocate(Length);

    Move(Text^, Buffer.Write^, Length * SizeOf(Buffer.Mem[0]));
    Buffer.Write := @Buffer.Write[Length];
  end;
end;

procedure TSQLParser.TStringBuffer.Write(const Text: string);
begin
  Write(PChar(Text), System.Length(Text));
end;

procedure TSQLParser.TStringBuffer.Write(const Char: Char);
begin
  Write(@Char, 1);
end;

{ TSQLParser.TWordList ********************************************************}

procedure TSQLParser.TWordList.Clear();
begin
  FText := '';

  FCount := 0;
  SetLength(FIndex, 0);
end;

constructor TSQLParser.TWordList.Create(const ASQLParser: TSQLParser; const AText: string = '');
begin
  FParser := ASQLParser;

  FCount := 0;
  SetLength(FIndex, 0);

  Text := AText;
end;

destructor TSQLParser.TWordList.Destroy();
begin
  Clear();

  inherited;
end;

function TSQLParser.TWordList.GetText(): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(FIndex) - 1 do
    if (I < Length(FIndex) - 1) then
      Result := Result + StrPas(FIndex[I]) + ','
    else
      Result := Result + StrPas(FIndex[I]);
end;

function TSQLParser.TWordList.GetWord(Index: TWordList.TIndex): string;
begin
  Result := StrPas(FIndex[Index]);
end;

procedure TSQLParser.TWordList.GetWordText(const Index: TIndex; out Text: PChar; out Length: Integer);
begin
  Text := FIndex[Index];
  Length := FLength[Index];
end;

function TSQLParser.TWordList.IndexOf(const Word: PChar; const Length: Integer): Integer;
var
  Comp: Integer;
  Left: Integer;
  Mid: Integer;
  Right: Integer;
begin
  Result := -1;

  if (Length <= System.Length(FFirst) - 2) then
  begin
    Left := FFirst[Length];
    Right := FFirst[Length + 1] - 1;
    while (Left <= Right) do
    begin
      Mid := (Right - Left) div 2 + Left;
      Comp := StrLIComp(FIndex[Mid], Word, Length);
      if (Comp < 0) then
        Left := Mid + 1
      else if (Comp = 0) then
        begin Result := Mid; break; end
      else
        Right := Mid - 1;
    end;
  end;
end;

function TSQLParser.TWordList.IndexOf(const Word: string): Integer;
begin
  Result := IndexOf(PChar(Word), Length(Word));
end;

procedure TSQLParser.TWordList.SetText(AText: string);
var
  Counts: array of Integer;
  Words: array of array of PChar;

  function InsertIndex(const Word: PChar; const Len: Integer; out Index: Integer): Boolean;
  var
    Comp: Integer;
    Left: Integer;
    Mid: Integer;
    Msg: string; // Debug 2016-12-22
    Right: Integer;
  begin
    Result := True;

    if ((Counts[Len] = 0) or (StrLComp(Word, Words[Len][Counts[Len] - 1], Len) > 0)) then
      Index := Counts[Len]
    else
    begin
      Left := 0;
      Right := Counts[Len] - 1;
      while (Left <= Right) do
      begin
        Mid := (Right - Left) div 2 + Left;
try
        Comp := StrLComp(Words[Len][Mid], Word, Len);
except
  Msg := 'Len: ' + IntToStr(Len) + ' in [' + IntToStr(0) + '..' + IntToStr(Length(Words) - 1) + ']';
  if (Len < Length(Words)) then
    Msg := Msg + #13#10 + 'Mid: ' + IntToStr(Mid) + ' in [' + IntToStr(0) + '..' + IntToStr(Length(Words[Len]) - 1) + ']';
  raise ERangeError.Create(Msg);
end;
        if (Comp < 0) then
          begin Left := Mid + 1;  Index := Mid + 1; end
        else if (Comp = 0) then
          begin Result := False; Index := Mid; break; end
        else
          begin Right := Mid - 1; Index := Mid; end;
      end;
    end;
  end;

  procedure Add(const Word: PChar; const Len: Integer);
  var
    Index: Integer;
  begin
    if (InsertIndex(Word, Len, Index)) then
    begin
      Move(Words[Len][Index], Words[Len][Index + 1], (Counts[Len] - Index) * SizeOf(Words[Len][0]));
      Words[Len][Index] := Word;
      Inc(Counts[Len]);
    end;
  end;

var
  I: Integer;
  Index: Integer;
  J: Integer;
  Len: Integer;
  MaxLen: Integer;
  OldIndex: Integer;
begin
  Clear();

  if (AText <> '') then
  begin
    FText := UpperCase(ReplaceStr(AText, ',', #0)) + #0;

    OldIndex := 1; Index := 1; MaxLen := 0; FCount := 0;
    while (Index < Length(FText)) do
    begin
      while (FText[Index] <> #0) do Inc(Index);
      Len := Index - OldIndex;
      if (Len > MaxLen) then MaxLen := Len;
      Inc(FCount);
      Inc(Index); // Step over #0
      OldIndex := Index;
    end;

    SetLength(Words, MaxLen + 1);
    SetLength(Counts, MaxLen + 1);
    for I := 1 to MaxLen do
    begin
      Counts[I] := 0;
      SetLength(Words[I], FCount + 1);
      for J := 0 to FCount do
        Words[I][J] := #0;
    end;

    OldIndex := 1; Index := 1;
    while (Index < Length(FText)) do
    begin
      while (FText[Index] <> #0) do Inc(Index);
      Len := Index - OldIndex;
      Add(@FText[OldIndex], Len);
      Inc(Index); // Step over #0
      OldIndex := Index;
    end;

    FCount := 0;
    SetLength(FFirst, MaxLen + 2);
    for I := 1 to MaxLen do
    begin
      FFirst[I] := FCount;
      Inc(FCount, Counts[I]);
    end;
    FFirst[MaxLen + 1] := FCount;

    SetLength(FIndex, FCount);
    SetLength(FLength, FCount);
    Index := 0;
    for I := 1 to MaxLen do
      for J := 0 to Counts[I] - 1 do
      begin
        FIndex[Index] := Words[I][J];
        FLength[Index] := I;
        Inc(Index);
      end;

    // Clear helpers
    for I := 1 to MaxLen do
      SetLength(Words[I], 0);
    SetLength(Counts, 0);
    SetLength(Words, 0);
  end;
end;

{ TSQLParser.TFormatHandle ****************************************************}

constructor TSQLParser.TFormatBuffer.Create();
var
  S: string;
begin
  inherited Create(1024);

  FNewLine := False;
  Indent := 0;
  S := StringOfChar(' ', System.Length(IndentSpaces));
  Move(S[1], IndentSpaces, SizeOf(IndentSpaces));
end;

procedure TSQLParser.TFormatBuffer.DecreaseIndent();
begin
  Assert(Indent >= IndentSize);

  if (Indent >= IndentSize) then
    Dec(Indent, IndentSize);
end;

procedure TSQLParser.TFormatBuffer.IncreaseIndent();
begin
  Inc(Indent, IndentSize);
end;

procedure TSQLParser.TFormatBuffer.Write(const Text: PChar; const Length: Integer);
begin
  if (FNewLine and (Indent > 0)) then
    inherited Write(@IndentSpaces[0], Indent);

  inherited;

  FNewLine := False;
end;

procedure TSQLParser.TFormatBuffer.Write(const Text: string; const SpaceBefore: Boolean);
begin
  if (SpaceBefore) then
    WriteSpace();

  inherited Write(Text);
end;

procedure TSQLParser.TFormatBuffer.WriteReturn();
begin
  if (not FNewLine) then
  begin
    Write(#13#10);
    FNewLine := True;
  end;
end;

procedure TSQLParser.TFormatBuffer.WriteSpace();
begin
  if (not FNewLine) then
    Write(' ', 1);
end;

{ TSQLParser.TOffsetList ******************************************************}

procedure TSQLParser.TOffsetList.Add(const Node: TOffset);
begin
  if (Count = ArrayLength) then
  begin
    ArrayLength := 10 * ArrayLength;
    SetLength(DynamicArray, ArrayLength);
    if (Count = Length(StackArray)) then
      Move(StackArray[0], DynamicArray[0], SizeOf(StackArray));
    FNodes := @DynamicArray[0];
  end;

  FNodes^[FCount] := Node;
  Inc(FCount);
end;

procedure TSQLParser.TOffsetList.Delete(const Index: Integer; const Count: Integer = 1);
begin
  Assert((0 <= Index) and (Index < FCount));
  Assert(Index + Count - 1 < FCount);

  Move(FNodes^[Index + Count], FNodes^[Index], (FCount - Index - Count) * SizeOf(StackArray[0]));
  Dec(FCount, Count);
end;

function TSQLParser.TOffsetList.Get(Index: Integer): TOffset;
begin
  Assert((0 <= Index) and (Index < Count));

  Result := FNodes^[Index];
end;

function TSQLParser.TOffsetList.IndexOf(const Node: TOffset): Integer;
var
  Left: Integer;
  Mid: Integer;
  Right: Integer;
begin
  Result := -1;

  Left := 0;
  Right := Count - 1;
  while (Left <= Right) do
  begin
    Mid := (Right - Left) div 2 + Left;
    case (Sign(FNodes^[Mid] - Node)) of
      -1: Left := Mid + 1;
      0: begin Result := Mid; break; end;
      1: Right := Mid - 1;
    end;
  end;
end;

procedure TSQLParser.TOffsetList.Init();
begin
  ArrayLength := Length(StackArray);
  FCount := 0;
  FNodes := @StackArray;
  if (Length(DynamicArray) > 0) then
    SetLength(DynamicArray, 0);
end;

procedure TSQLParser.TOffsetList.Put(Index: Integer; Node: TOffset);
begin
  Assert((0 <= Index) and (Index < Count));

  FNodes^[Index] := Node;
end;

{ TSQLParser.TCompletionList **************************************************}

procedure TSQLParser.TCompletionList.AddConst(const Text: string);
begin
  AddText(Text);
end;

procedure TSQLParser.TCompletionList.AddList(DbIdentType: TDbIdentType;
  const DatabaseName: string = ''; TableName: string = '');
var
  Item: PItem;
begin
  if (Active) then
  begin
    if (FCount = Length(FItems)) then
      SetLength(FItems, 2 * Length(FItems));
    if (DbIdentType = ditField) then
    begin
      // ditField must be the first in the list, because of the large number
      // of column names, which will be added to the SynCompletion.ItemList.
      Move(FItems[0], FItems[1], FCount * SizeOf(FItems[0]));
      Item := @FItems[0];
    end
    else
      Item := @FItems[FCount];
    Inc(FCount);

    Item^.ItemType := itList;
    Item^.DbIdentType := DbIdentType;
    StrPCopy(Item^.DatabaseName, DatabaseName);
    StrPCopy(Item^.TableName, TableName);
  end;
end;

procedure TSQLParser.TCompletionList.AddTag(const KeywordIndex1: TWordList.TIndex;
  const KeywordIndex2: TWordList.TIndex = -1; const KeywordIndex3: TWordList.TIndex = -1;
  const KeywordIndex4: TWordList.TIndex = -1; const KeywordIndex5: TWordList.TIndex = -1;
  const KeywordIndex6: TWordList.TIndex = -1; const KeywordIndex7: TWordList.TIndex = -1);
var
  Item: PItem;
begin
  if (FCount = System.Length(FItems)) then
    SetLength(FItems, 2 * System.Length(FItems));
  Item := @FItems[FCount];
  Inc(FCount);
  Item^.ItemType := itTag;
  Item^.KeywordIndices[0] := KeywordIndex1;
  Item^.KeywordIndices[1] := KeywordIndex2;
  Item^.KeywordIndices[2] := KeywordIndex3;
  Item^.KeywordIndices[3] := KeywordIndex4;
  Item^.KeywordIndices[4] := KeywordIndex5;
  Item^.KeywordIndices[5] := KeywordIndex6;
  Item^.KeywordIndices[6] := KeywordIndex7;
end;

procedure TSQLParser.TCompletionList.AddText(const Text: string);
var
  Item: PItem;
begin
  if (Active) then
  begin
    if (FCount = System.Length(FItems)) then
      SetLength(FItems, 2 * System.Length(FItems));
    Item := @FItems[FCount];
    Inc(FCount);

    FillChar(Item^, SizeOf(Item^), 0);
    Item^.ItemType := itText;
    StrPLCopy(@Item^.Text[0], Text, Length(Item^.Text) - 1);
  end;
end;

procedure TSQLParser.TCompletionList.Cleanup();
var
  I: Integer;
  J: Integer;
  Item: PItem;
  Length: Integer;
  Tag: array[0 .. 256] of Char;
  TagP: PChar;
  Text: PChar;
begin
  if (not Active) then
    Clear()
  else
    for I := 0 to Count - 1 do
      if (Items[I]^.ItemType = itTag) then
      begin
        Item := Items[I];

        FillChar(Tag, SizeOf(Tag), 0);
        TagP := @Tag[0];

        for J := 0 to System.Length(Item^.KeywordIndices) - 1 do
          if (Item^.KeywordIndices[J] >= 0) then
          begin
            Parser.KeywordList.GetWordText(Item^.KeywordIndices[J], Text, Length);
            if (StrLen(PChar(@Tag[0])) > 0) then
              begin StrCopy(TagP, ' '); TagP := @TagP[1]; end;
            StrLCopy(TagP, Text, Length); TagP := @TagP[Length];
          end;

        FillChar(Item^, SizeOf(Item^), 0);
        Item^.ItemType := itText;
        StrCopy(PChar(@Item^.Text[0]), PChar(@Tag[0]));
      end;
end;

procedure TSQLParser.TCompletionList.Clear();
begin
  FCount := 0;
end;

constructor TSQLParser.TCompletionList.Create(const AParser: TSQLParser);
begin
  inherited Create();

  FParser := AParser;

  FCount := 0;
  SetLength(FItems, DefaultListLength);
end;

procedure TSQLParser.TCompletionList.Delete(const Index: Integer);
begin
  Assert((0 <= Index) and (Index < FCount));

  Move(FItems[Index + 1], FItems[Index], (FCount - Index - 1) * SizeOf(FItems[0]));
  Dec(FCount);
end;

destructor TSQLParser.TCompletionList.Destroy();
begin
  SetActive(False);

  inherited;
end;

function TSQLParser.TCompletionList.GetItem(Index: Integer): PItem;
begin
  Assert((0 <= Index) and (Index < FCount));

  Result := PItem(@FItems[Index]);
end;

procedure TSQLParser.TCompletionList.SetActive(AActive: Boolean);
begin
  if (Active and not AActive) then
  begin
    SetLength(FItems, DefaultListLength);
    FCount := 0;
  end;

  Active := AActive;
end;

{ TSQLParser.TNode ************************************************************}

class function TSQLParser.TNode.Create(const AParser: TSQLParser; const ANodeType: TNodeType): TOffset;
begin
  Result := AParser.NewNode(ANodeType);

  with PNode(AParser.NodePtr(Result))^ do
  begin
    FNodeType := ANodeType;
    FParser := AParser;
  end;
end;

function TSQLParser.TNode.GetFirstToken(): PToken;
begin
  if (NodeType = ntToken) then
    Result := TSQLParser.PToken(@Self)
  else if (Parser.IsRange(@Self)) then
    Result := TSQLParser.PRange(@Self)^.FirstToken
  else
    raise ERangeError.Create(SRangeError);
end;

function TSQLParser.TNode.GetLastToken(): PToken;
begin
  if (NodeType = ntToken) then
    Result := TSQLParser.PToken(@Self)
  else if (Parser.IsRange(@Self)) then
    Result := TSQLParser.PRange(@Self)^.LastToken
  else
    raise ERangeError.Create(SRangeError);
end;

function TSQLParser.TNode.GetOffset(): TOffset;
begin
  Assert(@Self > Parser.Nodes.Mem);

  Result := @Self - Parser.Nodes.Mem;
end;

function TSQLParser.TNode.GetText(): string;
begin
  if (Parser.IsToken(Offset)) then
    Result := Parser.TokenPtr(Offset)^.Text
  else if (NodeType = ntRoot) then
    Result := Parser.Parse.SQL
  else
    TSQLParser.PRange(@Self)^.Text;
end;

{ TSQLParser.TChild ***********************************************************}

class function TSQLParser.TChild.Create(const AParser: TSQLParser; const ANodeType: TNodeType): TOffset;
begin
  Result := TNode.Create(AParser, ANodeType);

  with PChild(AParser.NodePtr(Result))^ do
  begin
    FParentNode := 0;
  end;
end;


function TSQLParser.TChild.GetParentNode(): PNode;
begin
  Assert(FParentNode < Parser.Nodes.UsedSize);

  if (FParentNode = 0) then
    Result := nil
  else
    Result := Parser.NodePtr(FParentNode);
end;

{ TSQLParser.TToken ***********************************************************}

class function TSQLParser.TToken.Create(const AParser: TSQLParser;
  const AText: PChar; const ALength: Integer;
  const ATokenType: TTokenType; const AOperatorType: TOperatorType;
  const AKeywordIndex: TWordList.TIndex; const AIsUsed: Boolean
  {$IFDEF Debug}; const AIndex: Integer {$ENDIF}): TOffset;
begin
  Result := TChild.Create(AParser, ntToken);

  with PToken(AParser.NodePtr(Result))^ do
  begin
    {$IFDEF Debug}
    FIndex := AIndex;
    {$ENDIF}
    FIsUsed := AIsUsed;
    FKeywordIndex := AKeywordIndex;
    FOperatorType := AOperatorType;
    FLength := ALength;
    FText := AText;
    FTokenType := ATokenType;
    FUsageType := utUnknown;
  end;
end;

function TSQLParser.TToken.GetAsString(): string;
var
  Length: Integer;
  Text: PChar;
begin
  GetText(Text, Length);
  case (TokenType) of
    ttSLComment:
      begin
        if (Text[0] = '#') then
        begin
          Text := @Text[1]; // Step over "#"
          Dec(Length);
        end
        else
        begin
          Text := @Text[3]; // Step over "-- "
          Dec(Length, 3);
        end;
        while (CharInSet(Text[0], [#9, ' '])) do
        begin
          Text := @Text[1];
          Dec(Length);
        end;
        while (CharInSet(Text[Length], [#9, ' '])) do
          Dec(Length);
        SetString(Result, Text, Length);
      end;
    ttMLComment:
      begin
        Text := @Text[2]; // Step over "/*"
        Dec(Length, 2); // Remove "/*"
        if ((Length >= 2) and (Text[Length - 2] = '*') and (Text[Length - 1] = '/')) then
          Dec(Length, 2); // Remove "*/"
        while (CharInSet(Text[0], [#9, #10, #13, ' '])) do
        begin
          Text := @Text[1];
          Dec(Length);
        end;
        while (CharInSet(Text[Length - 1], [#9, #10, #13, ' '])) do
          Dec(Length);
        SetString(Result, Text, Length);
      end;
    ttString,
    ttDQIdent,
    ttMySQLIdent:
      begin
        if ((Length > 0)
          and (Text[0] = '_')
          and ((TokenType = ttString) or not Parser.AnsiQuotes and (TokenType = ttDQIdent))) then
          while (Text[0] <> Text[Length - 1]) do
          begin
            Text := @Text[1];
            Dec(Length);
          end;

        if (Length = 0) then
          Result := ''
        else
        begin
          SetLength(Result, SQLUnescape(Text, Length, nil, 0));
          SQLUnescape(Text, Length, PChar(Result), System.Length(Result));
        end;
      end;
    ttMySQLCondStart:
      SetString(Result, PChar(@Text[3]), Length - 3);
    else
      SetString(Result, Text, Length);
  end;
end;

function TSQLParser.TToken.GetDbIdentType(): TDbIdentType;
begin
  if ((UsageType <> utDbIdent) or not Assigned(Heritage.ParentNode)) then
    Result := ditUnknown
  else if (Heritage.ParentNode^.NodeType in FuncNodeTypes) then
    Result := ditFunction
  else if (Heritage.ParentNode^.NodeType <> ntDbIdent) then
    Result := ditUnknown
  else if (PDbIdent(Heritage.ParentNode)^.Nodes.DatabaseIdent = Offset) then
    Result := ditDatabase
  else if (PDbIdent(Heritage.ParentNode)^.Nodes.TableIdent = Offset) then
    if (PDbIdent(Heritage.ParentNode)^.FDbTableType in [ditTableAlias, ditTriggerRec]) then
      Result := PDbIdent(Heritage.ParentNode)^.FDbTableType
    else
      Result := ditTable
  else
    Result := PDbIdent(Heritage.ParentNode)^.DbIdentType;
end;

{$IFNDEF Debug}
function TSQLParser.TToken.GetIndex(): Integer;
var
  Token: PToken;
begin
  Token := Parser.Root^.FirstTokenAll;
  Result := 0;
  while (Assigned(Token) and (Token <> @Self)) do
  begin
    Inc(Result);
    Token := Token^.NextToken;
  end;
end;
{$ENDIF}

function TSQLParser.TToken.GetNextToken(): PToken;
var
  Offset: TOffset;
begin
  Offset := PNode(@Self)^.Offset;
  repeat
    repeat
      Inc(Offset, Parser.NodeSize(Parser.NodePtr(Offset)^.NodeType));
    until ((Offset = Parser.Nodes.UsedSize) or (Parser.NodePtr(Offset)^.NodeType = ntToken));
    if (Offset = Parser.Nodes.UsedSize) then
      Result := nil
    else
      Result := PToken(Parser.NodePtr(Offset));
  until (not Assigned(Result) or Result^.IsUsed);
end;

function TSQLParser.TToken.GetNextTokenAll(): PToken;
var
  Offset: TOffset;
begin
  Offset := PNode(@Self)^.Offset;
  repeat
    repeat
      Inc(Offset, Parser.NodeSize(Parser.NodePtr(Offset)^.NodeType));
    until ((Offset = Parser.Nodes.UsedSize) or (Parser.NodePtr(Offset)^.NodeType = ntToken));
    if (Offset = Parser.Nodes.UsedSize) then
      Result := nil
    else
      Result := PToken(Parser.NodePtr(Offset));
  until (not Assigned(Result) or Parser.IsToken(Offset));
end;

function TSQLParser.TToken.GetOffset(): TOffset;
begin
  Result := Heritage.Heritage.GetOffset();
end;

function TSQLParser.TToken.GetParentNode(): PNode;
begin
  Result := Heritage.GetParentNode();
end;

function TSQLParser.TToken.GetPos(): Integer;
begin
  Result := Integer(FText - PChar(Parser.Parse.SQL));
end;

function TSQLParser.TToken.GetText(): string;
var
  Text: PChar;
  Length: Integer;
begin
  GetText(Text, Length);
  SetString(Result, Text, Length);
end;

procedure TSQLParser.TToken.GetText(out Text: PChar; out Length: Integer);
begin
  Text := FText;
  Length := FLength;
end;

{ TSQLParser.TRange ***********************************************************}

procedure TSQLParser.TRange.AddChildren(const Count: Integer; const Children: POffsetArray);
var
  Child: PChild;
  First: TOffset;
  I: Integer;
  Last: TOffset;
begin
  for I := 0 to Count - 1 do
    if (Children^[I] > 0) then
    begin
      Child := Parser.ChildPtr(Children^[I]);
      Child^.FParentNode := Offset;

      if (Parser.IsToken(PNode(Child))) then
        First := Children^[I]
      else if (Parser.IsRange(PNode(Child))) then
        First := PRange(Child)^.FFirstToken
      else
        raise ERangeError.Create(SRangeError);
      if ((FFirstToken = 0) or (0 < First) and (First < FFirstToken)) then
        FFirstToken := First;

      if (Parser.IsToken(PNode(Child))) then
        Last := Children^[I]
      else if (Parser.IsRange(PNode(Child))) then
        Last := PRange(Child)^.FLastToken
      else
        raise ERangeError.Create(SRangeError);
      if (Last > FLastToken) then
        FLastToken := Last;
    end;
end;

class function TSQLParser.TRange.Create(const AParser: TSQLParser; const ANodeType: TNodeType): TOffset;
begin
  Result := TChild.Create(AParser, ANodeType);

  with PRange(AParser.NodePtr(Result))^ do
  begin
    FFirstToken := 0;
    FLastToken := 0;
  end;
end;

function TSQLParser.TRange.GetFirstToken(): PToken;
begin
  if (FFirstToken = 0) then
    Result := nil
  else
    Result := PToken(Parser.NodePtr(FFirstToken));
end;

function TSQLParser.TRange.GetLastToken(): PToken;
begin
  if (FLastToken = 0) then
    Result := nil
  else
    Result := PToken(Parser.NodePtr(FLastToken));
end;

function TSQLParser.TRange.GetOffset(): TOffset;
begin
  Result := Heritage.Heritage.Offset;
end;

function TSQLParser.TRange.GetParentNode(): PNode;
begin
  if (FParentNode = 0) then
    Result := nil
  else
    Result := Parser.NodePtr(FParentNode);
end;

function TSQLParser.TRange.GetText(): string;
begin
  SetString(Result, FirstToken^.FText, Integer(LastToken^.FText - FirstToken^.FText) + LastToken^.FLength);
end;

{ TSQLParser.TStmt ************************************************************}

class function TSQLParser.TStmt.Create(const AParser: TSQLParser; const AStmtType: TStmtType): TOffset;
begin
  Result := TRange.Create(AParser, NodeTypeByStmtType[AStmtType]);

  with PStmt(AParser.NodePtr(Result))^ do
  begin
    Error.Code := PE_Success;
    Error.Line := 0;
    Error.Token := 0;
  end;
end;

function TSQLParser.TStmt.GetDelimiter(): PToken;
var
  Token: PToken;
begin
  if (not Assigned(LastToken)) then
    Token := nil
  else
    Token := LastToken^.NextToken;
  if (not Assigned(Token) or (Token^.TokenType <> ttSemicolon)) then
    Result := nil
  else
    Result := Token;
end;

function TSQLParser.TStmt.GetErrorMessage(): string;
begin
  Result := Parser.CreateErrorMessage(Error);
end;

function TSQLParser.TStmt.GetErrorToken(): PToken;
begin
  if (Error.Token = 0) then
    Result := nil
  else
    Result := PToken(Parser.NodePtr(Error.Token));
end;

function TSQLParser.TStmt.GetFirstToken(): PToken;
begin
  if (FFirstToken = 0) then
    Result := nil
  else
    Result := PToken(Parser.NodePtr(FFirstToken));
end;

function TSQLParser.TStmt.GetLastToken(): PToken;
begin
  Result := PRange(@Self)^.LastToken;
end;

function TSQLParser.TStmt.GetNextStmt(): PStmt;
var
  Token: PToken;
  Child: PChild;
begin
  Token := Delimiter;

  if (not Assigned(Token)) then
    Result := nil
  else
  begin
    Token := Token^.NextToken;

    if (not Assigned(Token)) then
      Result := nil
    else
    begin
      Child := PChild(Token);

      while (Assigned(Child) and (Child^.ParentNode <> Heritage.ParentNode) and Parser.IsChild(Child^.ParentNode)) do
        Child := PChild(Child^.ParentNode);

      if (not Assigned(Child) or not Parser.IsStmt(PNode(Child))) then
        Result := nil
      else
        Result := PStmt(Child);
    end;
  end;
end;

function TSQLParser.TStmt.GetStmtType(): TStmtType;
var
  StmtType: TStmtType;
begin
  Result := Low(TStmtType); // For hiding compiler warnings only

  for StmtType := Low(TStmtType) to High(TStmtType) do
    if (NodeTypeByStmtType[StmtType] = PNode(@Self)^.NodeType) then
      Result := StmtType;
end;

{ TSQLParser.TAccount *********************************************************}

class function TSQLParser.TAccount.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntAccount);

  with PAccount(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAnalyzeTableStmt ************************************************}

class function TSQLParser.TAnalyzeTableStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stAnalyzeTable);

  with PAnalyzeTableStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterDatabase ***************************************************}

class function TSQLParser.TAlterDatabaseStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stAlterDatabase);

  with PAlterDatabaseStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterEvent ******************************************************}

class function TSQLParser.TAlterEventStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stAlterEvent);

  with PAlterEventStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterRoutine ****************************************************}

class function TSQLParser.TAlterInstanceStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stAlterInstance);

  with PAlterInstanceStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterRoutine ****************************************************}

class function TSQLParser.TAlterRoutineStmt.Create(const AParser: TSQLParser; const ARoutineType: TRoutineType; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stAlterRoutine);

  with PAlterRoutineStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;
    FRoutineType := ARoutineType;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterServerStmt *************************************************}

class function TSQLParser.TAlterServerStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stAlterServer);

  with PAlterServerStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterTablespaceStmt *********************************************}

class function TSQLParser.TAlterTablespaceStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stAlterTablespace);

  with PAlterTablespaceStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterTableStmt.TAddField **************************************}

class function TSQLParser.TAlterTableStmt.TAddField.Create(const AParser: TSQLParser; const ANodes: TAddField.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntAlterTableStmtAddField);

  with PAddField(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterTableStmt.TAddFields ***************************************}

class function TSQLParser.TAlterTableStmt.TAddFields.Create(const AParser: TSQLParser; const ANodes: TAddFields.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntAlterTableStmtAddFields);

  with PAddFields(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterTableStmt.TAlterField **************************************}

class function TSQLParser.TAlterTableStmt.TAlterField.Create(const AParser: TSQLParser; const ANodes: TAlterField.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntAlterTableStmtAlterField);

  with PAlterField(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterTableStmt.TConvertTo ***************************************}

class function TSQLParser.TAlterTableStmt.TConvertTo.Create(const AParser: TSQLParser; const ANodes: TConvertTo.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntAlterTableStmtConvertTo);

  with PConvertTo(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterTableStmt.TDropObject **************************************}

class function TSQLParser.TAlterTableStmt.TDropObject.Create(const AParser: TSQLParser; const ANodes: TDropObject.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntAlterTableStmtDropObject);

  with PDropObject(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterTableStmt.TExchangePartition *******************************}

class function TSQLParser.TAlterTableStmt.TExchangePartition.Create(const AParser: TSQLParser; const ANodes: TExchangePartition.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntAlterTableStmtExchangePartition);

  with PExchangePartition(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterTableStmt.TOrderBy ***************************}

class function TSQLParser.TAlterTableStmt.TOrderBy.Create(const AParser: TSQLParser; const ANodes: TOrderBy.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntAlterTableStmtOrderBy);

  with POrderBy(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterTableStmt.TReorganizePartition ***************************}

class function TSQLParser.TAlterTableStmt.TReorganizePartition.Create(const AParser: TSQLParser; const ANodes: TReorganizePartition.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntAlterTableStmtReorganizePartition);

  with PReorganizePartition(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterTableStmt **************************************************}

class function TSQLParser.TAlterTableStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stAlterTable);

  with PAlterTableStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TAlterViewStmt ***************************************************}

class function TSQLParser.TAlterViewStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stAlterView);

  with PAlterViewStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TBeginLabel ******************************************************}

class function TSQLParser.TBeginLabel.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntBeginLabel);

  with PBeginLabel(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

function TSQLParser.TBeginLabel.GetLabelName(): string;
begin
  if (not Parser.IsToken(Nodes.BeginToken)) then
    Result := ''
  else
    Result := Parser.TokenPtr(Nodes.BeginToken)^.AsString;
end;

{ TSQLParser.TBeginStmt *******************************************************}

class function TSQLParser.TBeginStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stBegin);

  with PBeginStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TBinaryOp ********************************************************}

class function TSQLParser.TBinaryOp.Create(const AParser: TSQLParser; const AOperator, AOperand: TOffset): TOffset;
begin
  Result := TRange.Create(AParser, ntBinaryOp);

  with PBinaryOp(AParser.NodePtr(Result))^ do
  begin
    Nodes.OperatorToken := AOperator;
    Nodes.Operand := AOperand;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

function TSQLParser.TBinaryOp.GetOperatorType(): TOperatorType;
begin
  if (not Parser.IsToken(Nodes.OperatorToken)) then
    Result := otNone
  else
    Result := Parser.TokenPtr(Nodes.OperatorToken)^.OperatorType;
end;

{ TSQLParser.TBetweenOp *******************************************************}

class function TSQLParser.TBetweenOp.Create(const AParser: TSQLParser; const AExpr, ANotToken, ABetweenToken, AMin, AAndToken, AMax: TOffset): TOffset;
begin
  Result := TRange.Create(AParser, ntBetweenOp);

  with PBetweenOp(AParser.NodePtr(Result))^ do
  begin
    Nodes.Expr := AExpr;
    Nodes.NotToken := ANotToken;
    Nodes.BetweenToken := ABetweenToken;
    Nodes.Min := AMin;
    Nodes.AndToken := AAndToken;
    Nodes.Max := AMax;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCallStmt ********************************************************}

class function TSQLParser.TCallStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCall);

  with PCallStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCaseOp.TBranch **************************************************}

class function TSQLParser.TCaseOp.TBranch.Create(const AParser: TSQLParser; const ANodes: TBranch.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCaseOpBranch);

  with PBranch(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCaseOp **********************************************************}

class function TSQLParser.TCaseOp.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCaseOp);

  with PCaseOp(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCaseStmt ********************************************************}

class function TSQLParser.TCaseStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCase);

  with PCaseStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCaseStmt.TBranch ************************************************}

class function TSQLParser.TCaseStmt.TBranch.Create(const AParser: TSQLParser; const ANodes: TBranch.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCaseStmtBranch);

  with PBranch(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCastFunc ********************************************************}

class function TSQLParser.TCastFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCastFunc);

  with PCastFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TChangeMasterStmt ************************************************}

class function TSQLParser.TChangeMasterStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stChangeMaster);

  with PChangeMasterStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCharFunc ********************************************************}

class function TSQLParser.TCharFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCharFunc);

  with PCharFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCheckTableStmt **************************************************}

class function TSQLParser.TCheckTableStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCheckTable);

  with PCheckTableStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TChecksumTableStmt ***********************************************}

class function TSQLParser.TChecksumTableStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stChecksumTable);

  with PChecksumTableStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCloseStmt *******************************************************}

class function TSQLParser.TCloseStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stClose);

  with PCloseStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCommitStmt ******************************************************}

class function TSQLParser.TCommitStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCommit);

  with PCommitStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCompoundStmt ****************************************************}

class function TSQLParser.TCompoundStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCompound);

  with PCompoundStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TConvertFunc *****************************************************}

class function TSQLParser.TConvertFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntConvertFunc);

  with PConvertFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCountFunc *****************************************************}

class function TSQLParser.TCountFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCountFunc);

  with PCountFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateDatabaseStmt **********************************************}

class function TSQLParser.TCreateDatabaseStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCreateDatabase);

  with PCreateDatabaseStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateEventStmt *************************************************}

class function TSQLParser.TCreateEventStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCreateEvent);

  with PCreateEventStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateIndexStmt *************************************************}

class function TSQLParser.TCreateIndexStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCreateIndex);

  with PCreateIndexStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateRoutineStmt ***********************************************}

class function TSQLParser.TCreateRoutineStmt.Create(const AParser: TSQLParser; const ARoutineType: TRoutineType; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCreateRoutine);

  with PCreateRoutineStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;
    FRoutineType := ARoutineType;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateServerStmt ************************************************}

class function TSQLParser.TCreateServerStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCreateServer);

  with PCreateServerStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateTablespaceStmt ********************************************}

class function TSQLParser.TCreateTablespaceStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCreateTablespace);

  with PCreateTablespaceStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateTableStmt *************************************************}

class function TSQLParser.TCreateTableStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCreateTable);

  with PCreateTableStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateTableStmt.TCheck ******************************************}

class function TSQLParser.TCreateTableStmt.TCheck.Create(const AParser: TSQLParser; const ANodes: TCheck.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCreateTableStmtCheck);

  with PCheck(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateTableStmt.TField.TOnUpdate ********************************}

class function TSQLParser.TCreateTableStmt.TField.TOnUpdate.Create(const AParser: TSQLParser; const ANodes: TOnUpdate.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCreateTableStmtFieldOnUpdate);

  with POnUpdate(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateTableStmt.TField ******************************************}

class function TSQLParser.TCreateTableStmt.TField.Create(const AParser: TSQLParser; const ANodes: TField.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCreateTableStmtField);

  with PField(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateTableStmt.TForeignKey *************************************}

class function TSQLParser.TCreateTableStmt.TForeignKey.Create(const AParser: TSQLParser; const ANodes: TForeignKey.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCreateTableStmtForeignKey);

  with PForeignKey(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateTableStmt.TKey ********************************************}

class function TSQLParser.TCreateTableStmt.TKey.Create(const AParser: TSQLParser; const ANodes: TKey.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCreateTableStmtKey);

  with PKey(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateTableStmt.TKeyColumn **************************************}

class function TSQLParser.TCreateTableStmt.TKeyColumn.Create(const AParser: TSQLParser; const ANodes: TKeyColumn.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCreateTableStmtKeyColumn);

  with PKeyColumn(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateTableStmt.TPartition **************************************}

class function TSQLParser.TCreateTableStmt.TPartition.Create(const AParser: TSQLParser; const ANodes: TPartition.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCreateTableStmtPartition);

  with PPartition(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateTableStmt.TPartitionOptions *******************************}

class function TSQLParser.TCreateTableStmt.TPartitionOptions.Create(const AParser: TSQLParser; const ANodes: TPartitionOptions.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCreateTableStmtPartitionOptions);

  with PPartitionOptions(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateTableStmt.TReferences *************************************}

class function TSQLParser.TCreateTableStmt.TReference.Create(const AParser: TSQLParser; const ANodes: TReference.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntCreateTableStmtReference);

  with PReference(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateTriggerStmt ***********************************************}

class function TSQLParser.TCreateTriggerStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCreateTrigger);

  with PCreateTriggerStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateUserStmt **************************************************}

class function TSQLParser.TCreateUserStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCreateUser);

  with PCreateUserStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TCreateViewStmt **************************************************}

class function TSQLParser.TCreateViewStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stCreateView);

  with PCreateViewStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDatatype ********************************************************}

class function TSQLParser.TDatatype.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntDatatype);

  with PDatatype(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDateAddFunc *****************************************************}

class function TSQLParser.TDateAddFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntDateAddFunc);

  with PDateAddFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDbIdent *********************************************************}

class function TSQLParser.TDbIdent.Create(const AParser: TSQLParser;
  const ADbIdentType: TDbIdentType; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntDbIdent);

  with PDbIdent(AParser.NodePtr(Result))^ do
  begin
    FDbIdentType := ADbIdentType;
    FDbTableType := ditUnknown;

    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

function TSQLParser.TDbIdent.GetDatabaseIdent(): PToken;
begin
  if (Nodes.DatabaseIdent = 0) then
    Result := nil
  else
    Result := Parser.TokenPtr(Nodes.DatabaseIdent);
end;

function TSQLParser.TDbIdent.GetIdent(): PToken;
begin
  if (Nodes.Ident = 0) then
    Result := nil
  else
    Result := Parser.TokenPtr(Nodes.Ident);
end;

function TSQLParser.TDbIdent.GetParentNode(): PNode;
begin
  Result := Heritage.GetParentNode();
end;

function TSQLParser.TDbIdent.GetTableIdent(): PToken;
begin
  if (Nodes.TableIdent = 0) then
    Result := nil
  else
    Result := Parser.TokenPtr(Nodes.TableIdent);
end;

{ TSQLParser.TDeallocatePrepareStmt *******************************************}

class function TSQLParser.TDeallocatePrepareStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDeallocatePrepare);

  with PDeallocatePrepareStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDeclareStmt *****************************************************}

class function TSQLParser.TDeclareStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDeclare);

  with PDeclareStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDeclareConditionStmt ********************************************}

class function TSQLParser.TDeclareConditionStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDeclareCondition);

  with PDeclareConditionStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDeclareCursorStmt ***********************************************}

class function TSQLParser.TDeclareCursorStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDeclareCursor);

  with PDeclareCursorStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDeclareHandlerStmt **********************************************}

class function TSQLParser.TDeclareHandlerStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDeclareHandler);

  with PDeclareHandlerStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDefaultFunc *****************************************************}

class function TSQLParser.TDefaultFunc.Create(const AParser: TSQLParser; const AIdent, AArgumentsList: TOffset): TOffset;
var
  Nodes: TNodes;
begin
  Nodes.Ident := AIdent;
  Nodes.ArgumentsList := AArgumentsList;

  Result := Create(AParser, Nodes);
end;

class function TSQLParser.TDefaultFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntDefaultFunc);

  with PDefaultFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDeleteStmt ******************************************************}

class function TSQLParser.TDeleteStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDelete);

  with PDeleteStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDoStmt **********************************************************}

class function TSQLParser.TDoStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDo);

  with PDoStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDropDatabaseStmt ************************************************}

class function TSQLParser.TDropDatabaseStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDropDatabase);

  with PDropDatabaseStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDropEventStmt ***************************************************}

class function TSQLParser.TDropEventStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDropEvent);

  with PDropEventStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDropIndexStmt ***************************************************}

class function TSQLParser.TDropIndexStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDropIndex);

  with PDropIndexStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDropRoutineStmt *************************************************}

class function TSQLParser.TDropRoutineStmt.Create(const AParser: TSQLParser; const ARoutineType: TRoutineType; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDropRoutine);

  with PDropRoutineStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;
    FRoutineType := ARoutineType;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDropServerStmt **************************************************}

class function TSQLParser.TDropServerStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDropServer);

  with PDropServerStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDropTablespaceStmt **********************************************}

class function TSQLParser.TDropTablespaceStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDropTable);

  with PDropTablespaceStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDropTableStmt ***************************************************}

class function TSQLParser.TDropTableStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDropTable);

  with PDropTableStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDropTriggerStmt *************************************************}

class function TSQLParser.TDropTriggerStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDropTrigger);

  with PDropTriggerStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDropUserStmt ****************************************************}

class function TSQLParser.TDropUserStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDropUser);

  with PDropUserStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TDropViewStmt ****************************************************}

class function TSQLParser.TDropViewStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stDropView);

  with PDropViewStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TEndLabel ********************************************************}

class function TSQLParser.TEndLabel.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntEndLabel);

  with PEndLabel(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TExecuteStmt *****************************************************}

class function TSQLParser.TExecuteStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stExecute);

  with PExecuteStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TExplainStmt *****************************************************}

class function TSQLParser.TExplainStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stExplain);

  with PExplainStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TExtractFunc *****************************************************}

class function TSQLParser.TExtractFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntExtractFunc);

  with PExtractFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TFetchStmt *******************************************************}

class function TSQLParser.TFetchStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stFetch);

  with PFetchStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TFlushStmt *******************************************************}

class function TSQLParser.TFlushStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stFlush);

  with PFlushStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TFlushStmtOption.TLogs *******************************************}

class function TSQLParser.TFlushStmt.TOption.TLogs.Create(const AParser: TSQLParser; const ANodes: TLogs.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntFlushStmtOptionLogs);

  with PLogs(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TFlushStmtOption *************************************************}

class function TSQLParser.TFlushStmt.TOption.Create(const AParser: TSQLParser; const ANodes: TOption.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntFlushStmtOption);

  with POption(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TFunctionReturns *************************************************}

class function TSQLParser.TFunctionReturns.Create(const AParser: TSQLParser; const ANodes: TFunctionReturns.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntFunctionReturns);

  with PFunctionReturns(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TGetDiagnosticsStmt **********************************************}

class function TSQLParser.TGetDiagnosticsStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stGetDiagnostics);

  with PGetDiagnosticsStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TGetDiagnosticsStmt.TStmtInfo ************************************}

class function TSQLParser.TGetDiagnosticsStmt.TStmtInfo.Create(const AParser: TSQLParser; const ANodes: TStmtInfo.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntGetDiagnosticsStmtStmtInfo);

  with PStmtInfo(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TGetDiagnosticsStmt.TConditionalInfo ***************************}

class function TSQLParser.TGetDiagnosticsStmt.TCondInfo.Create(const AParser: TSQLParser; const ANodes: TCondInfo.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntGetDiagnosticsStmtStmtInfo);

  with PCondInfo(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TGrantStmt *******************************************************}

class function TSQLParser.TGrantStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stGrant);

  with PGrantStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TGrantStmt.TPrivileg *********************************************}

class function TSQLParser.TGrantStmt.TPrivileg.Create(const AParser: TSQLParser; const ANodes: TPrivileg.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntGrantStmtPrivileg);

  with PPrivileg(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TGrantStmt.TUserSpecification ************************************}

class function TSQLParser.TGrantStmt.TUserSpecification.Create(const AParser: TSQLParser; const ANodes: TUserSpecification.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntGrantStmtUserSpecification);

  with PUserSpecification(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TGroupConcatFunc *************************************************}

class function TSQLParser.TGroupConcatFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntGroupConcatFunc);

  with PGroupConcatFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TGroupConcatFunc.TExpr *******************************************}

class function TSQLParser.TGroupConcatFunc.TExpr.Create(const AParser: TSQLParser; const ANodes: TExpr.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntGroupConcatFuncExpr);

  with PExpr(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.THelpStmt ********************************************************}

class function TSQLParser.THelpStmt.Create(const AParser: TSQLParser; const ANodes: THelpStmt.TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stHelp);

  with PHelpStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TIfStmt.TBranch **************************************************}

class function TSQLParser.TIfStmt.TBranch.Create(const AParser: TSQLParser; const ANodes: TBranch.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntIfStmtBranch);

  with PBranch(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TIfStmt **********************************************************}

class function TSQLParser.TIfStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stIf);

  with PIfStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TInOp ************************************************************}

class function TSQLParser.TInOp.Create(const AParser: TSQLParser; const AOperand, ANotToken, AInToken, AList: TOffset): TOffset;
begin
  Result := TRange.Create(AParser, ntInOp);

  with PInOp(AParser.NodePtr(Result))^ do
  begin
    Nodes.Operand := AOperand;
    Nodes.NotToken := ANotToken;
    Nodes.InToken := AInToken;
    Nodes.List := AList;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TInsertStmt ******************************************************}

class function TSQLParser.TInsertStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stInsert);

  with PInsertStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TInsertStmtSetItem ***********************************************}

class function TSQLParser.TInsertStmt.TSetItem.Create(const AParser: TSQLParser; const ANodes: TSetItem.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntInsertStmtSetItem);

  with PSetItem(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TInstallPluginStmt ******************************************************}

class function TSQLParser.TInstallPluginStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stInstallPlugin);

  with PInstallPluginStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TInterval ********************************************************}

class function TSQLParser.TIntervalOp.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntIntervalOp);

  with PIntervalOp(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TIsOp ************************************************************}

class function TSQLParser.TIsOp.Create(const AParser: TSQLParser; const AOperand1, AIsToken, ANotToken, AOperand2: TOffset): TOffset;
begin
  Result := TRange.Create(AParser, ntIsOp);

  with PIsOp(AParser.NodePtr(Result))^ do
  begin
    Nodes.Operand1 := AOperand1;
    Nodes.IsToken := AIsToken;
    Nodes.NotToken := ANotToken;
    Nodes.Operand2 := AOperand2;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TIterateStmt *****************************************************}

class function TSQLParser.TIterateStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stIterate);

  with PIterateStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TKillStmt ********************************************************}

class function TSQLParser.TKillStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stKill);

  with PKillStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TLeaveStmt *******************************************************}

class function TSQLParser.TLeaveStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stLeave);

  with PLeaveStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TLikeOp **********************************************************}

class function TSQLParser.TLikeOp.Create(const AParser: TSQLParser;
  const AOperand1, ANotToken, ALikeToken, AOperand2, AEscapeToken, AEscapeCharToken: TOffset): TOffset;
begin
  Result := TRange.Create(AParser, ntLikeOp);

  with PLikeOp(AParser.NodePtr(Result))^ do
  begin
    Nodes.Operand1 := AOperand1;
    Nodes.NotToken := ANotToken;
    Nodes.LikeToken := ALikeToken;
    Nodes.Operand2 := AOperand2;
    Nodes.EscapeToken := AEscapeToken;
    Nodes.EscapeCharToken := AEscapeCharToken;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TList ************************************************************}

class function TSQLParser.TList.Create(const AParser: TSQLParser;
  const ANodes: TNodes; const ADelimiterType: TTokenType;
  const AChildren: POffsetList): TOffset;
var
  I: Integer;
begin
  Result := TRange.Create(AParser, ntList);

  with PList(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;
    if (AChildren.Count > 0) then
      Nodes.FirstElement := AChildren^[0];

    FDelimiterType := ADelimiterType;

    if (ADelimiterType = ttUnknown) then
      FElementCount := AChildren^.Count
    else
    begin
      FElementCount := 0;
      for I := 0 to AChildren^.Count - 1 do
        if (not AParser.IsToken(AChildren^[I])
          or (AParser.TokenPtr(AChildren^[I])^.TokenType <> ADelimiterType)) then
          Inc(FElementCount)
    end;

    Heritage.AddChildren(1, @Nodes.OpenBracket);
    Heritage.AddChildren(AChildren.Count, AChildren.Nodes);
    Heritage.AddChildren(1, @Nodes.CloseBracket);
  end;
end;

function TSQLParser.TList.GetDelimiter(const Child: PChild): PToken;
var
  Token: PToken;
begin
  Assert(Assigned(Child));

  if (DelimiterType = ttUnknown) then
    Result := nil
  else
  begin
    if (Parser.IsToken(PNode(Child))) then
      Token := PToken(Child)^.NextToken
    else if (Parser.IsRange(PNode(Child))) then
      if (not Assigned(PRange(Child)^.LastToken)) then
        Token := nil
      else
        Token := PRange(Child)^.LastToken^.NextToken
    else
      raise ERangeError.Create(SRangeError);

    if (not Assigned(Token) or (Token^.TokenType <> DelimiterType)) then
      Result := nil
    else
      Result := Token;
  end;
end;

function TSQLParser.TList.GetFirstElement(): PChild;
begin
  if (Nodes.FirstElement = 0) then
    Result := nil
  else
    Result := PChild(Parser.NodePtr(Nodes.FirstElement));
end;

function TSQLParser.TList.GetNextElement(const Child: PChild): PChild;
var
  Token: PToken;
begin
  Assert(Assigned(Child));

  if (Parser.IsToken(PNode(Child))) then
    Token := PToken(Child)^.NextToken
  else if (Parser.IsRange((PNode(Child)))) then
    if (not Assigned(PRange(Child)^.LastToken)) then
      Token := nil
    else
      Token := PRange(Child)^.LastToken^.NextToken
  else
    raise ERangeError.Create(SRangeError);

  if (Assigned(Token) and (Token^.TokenType = DelimiterType)) then
    Token := Token^.NextToken;

  if (not Assigned(Token) or (Token^.Offset = Nodes.CloseBracket)) then
    Result := nil
  else
  begin
    Result := PChild(Token);

    while (Assigned(Result) and (Result^.ParentNode <> PNode(@Self))) do
      if (not Parser.IsChild(Result^.ParentNode)) then
        Result := nil
      else
        Result := PChild(Result^.ParentNode);
  end;
end;

{ TSQLParser.TLoadDataStmt ****************************************************}

class function TSQLParser.TLoadDataStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stLoadData);

  with PLoadDataStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TLoadXMLStmt *****************************************************}

class function TSQLParser.TLoadXMLStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stLoadXML);

  with PLoadXMLStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

  end;
end;

{ TSQLParser.TLockTablesStmt.TItem ********************************************}

class function TSQLParser.TLockTablesStmt.TItem.Create(const AParser: TSQLParser; const ANodes: TItem.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntLockTablesStmtItem);

  with PItem(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TLockTablesStmt **************************************************}

class function TSQLParser.TLockTablesStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stLockTable);

  with PLockTablesStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TLoopStmt ********************************************************}

class function TSQLParser.TLoopStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stLoop);

  with PLoopStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TMatchFunc *******************************************************}

class function TSQLParser.TMatchFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntMatchFunc);

  with PMatchFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TPositionFunc ****************************************************}

class function TSQLParser.TPositionFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntPositionFunc);

  with PPositionFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TPrepareStmt *****************************************************}

class function TSQLParser.TPrepareStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stPrepare);

  with PPrepareStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TPurgeStmt *******************************************************}

class function TSQLParser.TPurgeStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stPurge);

  with PPurgeStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TOpenStmt ********************************************************}

class function TSQLParser.TOpenStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stOpen);

  with POpenStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TOptimizeTableStmt ***********************************************}

class function TSQLParser.TOptimizeTableStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stOptimizeTable);

  with POptimizeTableStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TRenameTableStmt *************************************************}

class function TSQLParser.TRenameStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stRename);

  with PRenameStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TRenameStmt.TPair ************************************************}

class function TSQLParser.TRenameStmt.TPair.Create(const AParser: TSQLParser; const ANodes: TPair.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntRenameStmtPair);

  with PPair(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TRegExpOp ********************************************************}

class function TSQLParser.TRegExpOp.Create(const AParser: TSQLParser;
  const AOperand1, ANotToken, ARegExpToken, AOperand2: TOffset): TOffset;
begin
  Result := TRange.Create(AParser, ntRegExpOp);

  with PRegExpOp(AParser.NodePtr(Result))^ do
  begin
    Nodes.Operand1 := AOperand1;
    Nodes.NotToken := ANotToken;
    Nodes.RegExpToken := ARegExpToken;
    Nodes.Operand2 := AOperand2;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TReleaseStmt *****************************************************}

class function TSQLParser.TReleaseStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stRelease);

  with PReleaseStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TRepairTableStmt *************************************************}

class function TSQLParser.TRepairTableStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stRepairTable);

  with PRepairTableStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TRepeatStmt ******************************************************}

class function TSQLParser.TRepeatStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stRepeat);

  with PRepeatStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TRevokeStmt ******************************************************}

class function TSQLParser.TRevokeStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stRevoke);

  with PRevokeStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TResetStmt *******************************************************}

class function TSQLParser.TResetStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stReset);

  with PResetStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TResetStmt.TOption ***********************************************}

class function TSQLParser.TResetStmt.TOption.Create(const AParser: TSQLParser; const ANodes: TOption.TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stReset);

  with POption(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TReturnStmt ******************************************************}

class function TSQLParser.TReturnStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stReturn);

  with PReturnStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TRollbackStmt ****************************************************}

class function TSQLParser.TRollbackStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stRollback);

  with PRollbackStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TRoot ************************************************************}

class function TSQLParser.TRoot.Create(const AParser: TSQLParser; const AFirstTokenAll, AStmtList: TOffset): TOffset;
begin
  Result := TNode.Create(AParser, ntRoot);

  with PRoot(AParser.NodePtr(Result))^ do
  begin
    FFirstTokenAll := AFirstTokenAll;

    Nodes.StmtList := AStmtList;
  end;
end;

function TSQLParser.TRoot.GetFirstStmt(): PStmt;
begin
  Assert((Nodes.StmtList = 0) or (Parser.NodePtr(Nodes.StmtList)^.NodeType = ntList));

  if (Nodes.StmtList = 0) then
    Result := nil
  else
    Result := PStmt(PList(Parser.NodePtr(Nodes.StmtList))^.FirstElement);
end;

function TSQLParser.TRoot.GetFirstTokenAll(): PToken;
begin
  if (FFirstTokenAll = 0) then
    Result := nil
  else
    Result := PToken(Parser.NodePtr(FFirstTokenAll));
end;

{ TSQLParser.TRoutineParam ****************************************************}

class function TSQLParser.TRoutineParam.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntRoutineParam);

  with PRoutineParam(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSavepointStmt ***************************************************}

class function TSQLParser.TSavepointStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stSavepoint);

  with PSavepointStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSecretIdent *****************************************************}

class function TSQLParser.TSecretIdent.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSecretIdent);

  with PSecretIdent(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSelectStmt.TColumn **********************************************}

class function TSQLParser.TSelectStmt.TColumn.Create(const AParser: TSQLParser; const ANodes: TColumn.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSelectStmtColumn);

  with PColumn(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSelectStmt.TTableFactor.TIndexHint ****************************}

class function TSQLParser.TSelectStmt.TTableFactor.TIndexHint.Create(const AParser: TSQLParser; const ANodes: TIndexHint.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSelectStmtTableFactorIndexHint);

  with PIndexHint(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSelectStmt.TTableFactor *****************************************}

class function TSQLParser.TSelectStmt.TTableFactor.Create(const AParser: TSQLParser; const ANodes: TTableFactor.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSelectStmtTableFactor);

  with PTableFactor(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSelectStmt.TTableFactorOj ***************************************}

class function TSQLParser.TSelectStmt.TTableFactorOj.Create(const AParser: TSQLParser; const ANodes: TTableFactorOj.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSelectStmtTableFactorOj);

  with PTableFactorOj(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSelectStmt.TTableFactorSubquery ***********************************}

class function TSQLParser.TSelectStmt.TTableFactorSubquery.Create(const AParser: TSQLParser; const ANodes: TTableFactorSubquery.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSelectStmtTableFactorSubquery);

  with PTableFactorSubquery(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSelectStmt.TTableJoin *******************************************}

class function TSQLParser.TSelectStmt.TTableJoin.Create(const AParser: TSQLParser; const AJoinType: TJoinType; const ANodes: TTableJoin.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSelectStmtTableJoin);

  with PTableJoin(AParser.NodePtr(Result))^ do
  begin
    FJoinType := AJoinType;

    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSelectStmt.TGroup ***********************************************}

class function TSQLParser.TSelectStmt.TGroup.Create(const AParser: TSQLParser; const ANodes: TGroup.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSelectStmtGroup);

  with PGroup(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSelectStmt.TLimit ***********************************************}

class function TSQLParser.TSelectStmt.TLimit.Create(const AParser: TSQLParser; const ANodes: TLimit.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSelectStmtLimit);

  with PLimit(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSelectStmt.TOrder ***********************************************}

class function TSQLParser.TSelectStmt.TOrder.Create(const AParser: TSQLParser; const ANodes: TOrder.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSelectStmtOrder);

  with POrder(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSelectStmt.TOrderBy ***********************************************}

class function TSQLParser.TSelectStmt.TOrderBy.Create(const AParser: TSQLParser; const ANodes: TOrderBy.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSelectStmtOrderBy);

  with POrderBy(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSelectStmt ******************************************************}

class function TSQLParser.TSelectStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stSelect);

  with PSelectStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSchedule ********************************************************}

class function TSQLParser.TSchedule.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSchedule);

  with PSchedule(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSetStmt.TAssignment *********************************************}

class function TSQLParser.TSetStmt.TAssignment.Create(const AParser: TSQLParser; const ANodes: TAssignment.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSetStmtAssignment);

  with PAssignment(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSetStmt *********************************************************}

class function TSQLParser.TSetStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stSet);

  with PSetStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSetNamesStmt ****************************************************}

class function TSQLParser.TSetNamesStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stSetNames);

  with PSetNamesStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSetPasswordStmt *************************************************}

class function TSQLParser.TSetPasswordStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stSetPassword);

  with PSetPasswordStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSetTransactionStmt.TCharacteristic ****************************}

class function TSQLParser.TSetTransactionStmt.TCharacteristic.Create(const AParser: TSQLParser; const ANodes: TCharacteristic.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSetTransactionStmtCharacteristic);

  with PCharacteristic(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSetTransactionStmt **********************************************}

class function TSQLParser.TSetTransactionStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stSetTransaction);

  with PSetTransactionStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowBinaryLogsStmt **********************************************}

class function TSQLParser.TShowBinaryLogsStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowBinaryLogs);

  with PShowBinaryLogsStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowBinlogEventsStmt ********************************************}

class function TSQLParser.TShowBinlogEventsStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowBinlogEvents);

  with PShowBinlogEventsStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowCharacterSetStmt ********************************************}

class function TSQLParser.TShowCharacterSetStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowCharacterSet);

  with PShowCharacterSetStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowCollationStmt ***********************************************}

class function TSQLParser.TShowCollationStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowCollation);

  with PShowCollationStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowColumnsStmt *************************************************}

class function TSQLParser.TShowColumnsStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowColumns);

  with PShowColumnsStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowCountStmt ***************************************************}

class function TSQLParser.TShowCountStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowCount);

  with PShowCountStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowCreateDatabaseStmt ******************************************}

class function TSQLParser.TShowCreateDatabaseStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowCreateDatabase);

  with PShowCreateDatabaseStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowCreateEventStmt *********************************************}

class function TSQLParser.TShowCreateEventStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowCreateEvent);

  with PShowCreateEventStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowCreateFunctionStmt ******************************************}

class function TSQLParser.TShowCreateFunctionStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowCreateFunction);

  with PShowCreateFunctionStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowCreateProcedureStmt *****************************************}

class function TSQLParser.TShowCreateProcedureStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowCreateProcedure);

  with PShowCreateProcedureStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowCreateTableStmt *********************************************}

class function TSQLParser.TShowCreateTableStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowCreateTable);

  with PShowCreateTableStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowCreateTriggerStmt *******************************************}

class function TSQLParser.TShowCreateTriggerStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowCreateTrigger);

  with PShowCreateTriggerStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowCreateUserStmt **********************************************}

class function TSQLParser.TShowCreateUserStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowCreateUser);

  with PShowCreateUserStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowCreateViewStmt **********************************************}

class function TSQLParser.TShowCreateViewStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowCreateView);

  with PShowCreateViewStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowDatabasesStmt ***********************************************}

class function TSQLParser.TShowDatabasesStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowDatabases);

  with PShowDatabasesStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowEngineStmt **************************************************}

class function TSQLParser.TShowEngineStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowEngine);

  with PShowEngineStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowEnginesStmt *************************************************}

class function TSQLParser.TShowEnginesStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowEngines);

  with PShowEnginesStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowErrorsStmt **************************************************}

class function TSQLParser.TShowErrorsStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowErrors);

  with PShowErrorsStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowEventsStmt **************************************************}

class function TSQLParser.TShowEventsStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowEvents);

  with PShowEventsStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowFunctionStatusStmt ******************************************}

class function TSQLParser.TShowFunctionStatusStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowFunctionStatus);

  with PShowFunctionStatusStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowGrantsStmt **************************************************}

class function TSQLParser.TShowGrantsStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowGrants);

  with PShowGrantsStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowIndexStmt ***************************************************}

class function TSQLParser.TShowIndexStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowIndex);

  with PShowIndexStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowMasterStatusStmt ********************************************}

class function TSQLParser.TShowMasterStatusStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowMasterStatus);

  with PShowMasterStatusStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowOpenTablesStmt **********************************************}

class function TSQLParser.TShowOpenTablesStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowOpenTables);

  with PShowOpenTablesStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowPluginsStmt *************************************************}

class function TSQLParser.TShowPluginsStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowPlugins);

  with PShowPluginsStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowPrivilegesStmt **********************************************}

class function TSQLParser.TShowPrivilegesStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowPrivileges);

  with PShowPrivilegesStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowProcedureStatusStmt *****************************************}

class function TSQLParser.TShowProcedureStatusStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowProcedureStatus);

  with PShowProcedureStatusStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowProcessListStmt *********************************************}

class function TSQLParser.TShowProcessListStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowProcessList);

  with PShowProcessListStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowProfileStmt *************************************************}

class function TSQLParser.TShowProfileStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowProfile);

  with PShowProfileStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowProfilesStmt ************************************************}

class function TSQLParser.TShowProfilesStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowProfiles);

  with PShowProfilesStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowRelaylogEventsStmt ******************************************}

class function TSQLParser.TShowRelaylogEventsStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowRelaylogEvents);

  with PShowRelaylogEventsStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowRoutineCodeStmt *********************************************}

class function TSQLParser.TShowRoutineCodeStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowRoutineCode);

  with PShowRoutineCodeStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowSlaveHostsStmt **********************************************}

class function TSQLParser.TShowSlaveHostsStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowSlaveHosts);

  with PShowSlaveHostsStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowSlaveStatusStmt *********************************************}

class function TSQLParser.TShowSlaveStatusStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowSlaveStatus);

  with PShowSlaveStatusStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowStatusStmt **************************************************}

class function TSQLParser.TShowStatusStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowStatus);

  with PShowStatusStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowTableStatusStmt *********************************************}

class function TSQLParser.TShowTableStatusStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowTableStatus);

  with PShowTableStatusStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowTablesStmt **************************************************}

class function TSQLParser.TShowTablesStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowTables);

  with PShowTablesStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowTriggersStmt ************************************************}

class function TSQLParser.TShowTriggersStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowTriggers);

  with PShowTriggersStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowVariablesStmt ***********************************************}

class function TSQLParser.TShowVariablesStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowVariables);

  with PShowVariablesStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShowWarningsStmt ************************************************}

class function TSQLParser.TShowWarningsStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShowWarnings);

  with PShowWarningsStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TShutdownStmt ****************************************************}

class function TSQLParser.TShutdownStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stShutdown);

  with PShutdownStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSignalStmt ******************************************************}

class function TSQLParser.TSignalStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stSignal);

  with PSignalStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSignalStmt.TInformation *****************************************}

class function TSQLParser.TSignalStmt.TInformation.Create(const AParser: TSQLParser; const ANodes: TInformation.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSignalStmtInformation);

  with PInformation(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSoundsLikeOp ****************************************************}

class function TSQLParser.TSoundsLikeOp.Create(const AParser: TSQLParser; const AOperand1, ASounds, ALike, AOperand2: TOffset): TOffset;
begin
  Result := TRange.Create(AParser, ntSoundsLikeOp);

  with PSoundsLikeOp(AParser.NodePtr(Result))^ do
  begin
    Nodes.Operand1 := AOperand1;
    Nodes.Sounds := ASounds;
    Nodes.Like := ALike;
    Nodes.Operand2 := AOperand2;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TStartSlaveStmt **************************************************}

class function TSQLParser.TStartSlaveStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stStartSlave);

  with PStartSlaveStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TStartTransactionStmt ********************************************}

class function TSQLParser.TStartTransactionStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stStartTransaction);

  with PStartTransactionStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TStopSlaveStmt ***************************************************}

class function TSQLParser.TStopSlaveStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stStopSlave);

  with PStopSlaveStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSubArea *********************************************************}

class function TSQLParser.TSubArea.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSubArea);

  with PSubArea(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSubPartition ****************************************************}

class function TSQLParser.TSubPartition.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSubPartition);

  with PSubPartition(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSubquery ********************************************************}

class function TSQLParser.TSubquery.Create(const AParser: TSQLParser; const AIdentTag, ASubquery: TOffset): TOffset;
var
  Nodes: TNodes;
begin
  Nodes.IdentTag := AIdentTag;
  Nodes.Subquery := ASubquery;

  Result := Create(AParser, Nodes);
end;

class function TSQLParser.TSubquery.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSubquery);

  with PSubquery(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSubstringFunc ***************************************************}

class function TSQLParser.TSubstringFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSubstringFunc);

  with PSubstringFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TSumFunc *********************************************************}

class function TSQLParser.TSumFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntSumFunc);

  with PSumFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TTag *************************************************************}

class function TSQLParser.TTag.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntTag);

  with PTag(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TTimestampAddFunc ********************************************************}

class function TSQLParser.TTimestampAddFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntTimestampAddFunc);

  with PTimestampAddFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TTimestampDiffFunc ********************************************************}

class function TSQLParser.TTimestampDiffFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntTimestampDiffFunc);

  with PTimestampDiffFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TTrimFunc ********************************************************}

class function TSQLParser.TTrimFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntTrimFunc);

  with PTrimFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TTruncateStmt ****************************************************}

class function TSQLParser.TTruncateStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stTruncate);

  with PTruncateStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TUnaryOp *********************************************************}

class function TSQLParser.TUnaryOp.Create(const AParser: TSQLParser; const AOperator, AOperand: TOffset): TOffset;
begin
  Result := TRange.Create(AParser, ntUnaryOp);

  with PUnaryOp(AParser.NodePtr(Result))^ do
  begin
    Nodes.Operator := AOperator;
    Nodes.Operand := AOperand;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TUninstallPluginStmt *********************************************}

class function TSQLParser.TUninstallPluginStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stUninstallPlugin);

  with PUninstallPluginStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TUnknownStmt *****************************************************}

class function TSQLParser.TUnknownStmt.Create(const AParser: TSQLParser; const ATokens: POffsetList): TOffset;
begin
  Result := TStmt.Create(AParser, stUnknown);

  with PUnknownStmt(AParser.NodePtr(Result))^ do
  begin
    Heritage.Heritage.AddChildren(ATokens.Count, ATokens.Nodes);
  end;
end;

{ TSQLParser.TUnlockStmt ******************************************************}

class function TSQLParser.TUnlockTablesStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stUnlockTables);

  with PUnlockTablesStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TUpdateStmt ******************************************************}

class function TSQLParser.TUpdateStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stUpdate);

  with PUpdateStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TUseStmt *********************************************************}

class function TSQLParser.TUseStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stUse);

  with PUseStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TValue ***********************************************************}

class function TSQLParser.TValue.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntValue);

  with PValue(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TVariable ********************************************************}

class function TSQLParser.TVariable.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntVariableIdent);

  with PVariable(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TWeightStringFunc ************************************************}

class function TSQLParser.TWeightStringFunc.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntWeightStringFunc);

  with PWeightStringFunc(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TWeightStringFunc.TLevel *****************************************}

class function TSQLParser.TWeightStringFunc.TLevel.Create(const AParser: TSQLParser; const ANodes: TLevel.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntWeightStringFuncLevel);

  with TWeightStringFunc.PLevel(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TWhileStmt *******************************************************}

class function TSQLParser.TWhileStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stWhile);

  with PWhileStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TXAStmt **********************************************************}

class function TSQLParser.TXAStmt.Create(const AParser: TSQLParser; const ANodes: TNodes): TOffset;
begin
  Result := TStmt.Create(AParser, stXA);

  with PXAStmt(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser.TXAStmt.TID ******************************************************}

class function TSQLParser.TXAStmt.TID.Create(const AParser: TSQLParser; const ANodes: TID.TNodes): TOffset;
begin
  Result := TRange.Create(AParser, ntXAStmtID);

  with PID(AParser.NodePtr(Result))^ do
  begin
    Nodes := ANodes;

    Heritage.AddChildren(SizeOf(Nodes) div SizeOf(TOffset), @Nodes);
  end;
end;

{ TSQLParser ******************************************************************}

function TSQLParser.ApplyCurrentToken(const AUsageType: TUsageType): TOffset;
begin
  Result := CurrentToken;

  if (Result > 0) then
  begin
    TokenPtr(Result)^.FUsageType := AUsageType;

    if (not ErrorFound) then
      CompletionList.Clear();

    Dec(TokenBuffer.Count);
    Move(TokenBuffer.Items[1], TokenBuffer.Items[0], TokenBuffer.Count * SizeOf(TokenBuffer.Items[0]));

    CurrentToken := GetToken(0); // Cache for speeding

    if (not ErrorFound and (CurrentToken > 0) and (TokenBuffer.Items[0].Error.Code <> PE_Success)) then
      SetError(TokenBuffer.Items[0].Error.Code, CurrentToken);
  end;
end;

procedure TSQLParser.BeginPL_SQL();
begin
  Inc(FInPL_SQL);
end;

function TSQLParser.ChildPtr(const Node: TOffset): PChild;
begin
  if not ((0 < Node) and (Node < Nodes.UsedSize) and IsChild(Node)) then
    Write;
  Assert((0 < Node) and (Node < Nodes.UsedSize) and IsChild(Node));

  Result := @Nodes.Mem[Node];
end;

procedure TSQLParser.Clear();
begin
  AllowedMySQLVersion := 0;
  CompletionList.SetActive(False);
  Error.Code := PE_Success;
  Error.Line := 0;
  Error.Pos := nil;
  Error.Token := 0;
  FirstError.Code := PE_Success;
  FirstError.Line := 0;
  FirstError.Pos := nil;
  FirstError.Token := 0;
  FInPL_SQL := 0;
  if (Nodes.MemSize <> DefaultNodesMemSize) then
  begin
    Nodes.MemSize := DefaultNodesMemSize;
    ReallocMem(Nodes.Mem, Nodes.MemSize);
  end;
  Nodes.UsedSize := 1; // "0" means "not assigned", so we start with "1"
  Parse.Before := pbOther;
  Parse.InCreateEventStmt := False;
  Parse.InCreateFunctionStmt := False;
  Parse.InCreateProcedureStmt := False;
  Parse.InCreateTriggerStmt := False;
  Parse.Length := 0;
  Parse.Line := 0;
  Parse.Pos := nil;
  Parse.SQL := '';
  FRoot := 0;
  TokenBuffer.Count := 0;
  {$IFDEF Debug}
  TokenIndex := 0;
  {$ENDIF}
end;

constructor TSQLParser.Create(const AMySQLVersion: Integer = 0);
begin
  inherited Create();

  FAnsiQuotes := False;
  CharsetList := TWordList.Create(Self);
  Commands := nil;
  FCompletionList := TCompletionList.Create(Self);
  FConstantList := TWordList.Create(Self);
  DatatypeList := TWordList.Create(Self);
  FFunctionList := TWordList.Create(Self);
  KeywordList := TWordList.Create(Self);
  FMySQLVersion := AMySQLVersion;
  Nodes.Mem := nil;
  Nodes.UsedSize := 0;
  Nodes.MemSize := 0;
  SetLength(OperatorTypeByKeywordIndex, 0);
  ReservedWordList := TWordList.Create(Self);
  TokenBuffer.Count := 0;

  Charsets := MySQLCharsets;
  ConstantList.Text := MySQLConstants;
  Datatypes := MySQLDatatypes;
  FunctionList.Text := MySQLFunctions;
  Keywords := MySQLKeywords;
  ReservedWords := MySQLReservedWords;

  Clear();
end;

function TSQLParser.CreateErrorMessage(const Error: TError): string;

  function Location(const ErrorPos: PChar): string;
  begin
    Result := LeftStr(StrPas(ErrorPos), 11);
    if (Pos(#10, Result) > 0) then
      Result := LeftStr(Result, Pos(#10, Result) - 1);
    if (Pos(#13, Result) > 0) then
      Result := LeftStr(Result, Pos(#13, Result) - 1);
  end;

var
  Length: Integer;
  S: string;
  Text: PChar;
begin
  if (Error.Token = 0) then
  begin
    Text := nil;
    Length := 0;
  end
  else
    TokenPtr(Error.Token)^.GetText(Text, Length);

  case (Error.Code) of
    PE_Success:
      Result := '';
    PE_Unknown:
      Result := 'Unknown error';
    PE_IncompleteToken:
      Result := 'Incomplete token';
    PE_UnexpectedChar:
      Result := 'Unexpected character';
    PE_InvalidMySQLCond:
      Result := 'Invalid version number in MySQL conditional option';
    PE_NestedMySQLCond:
      Result := 'Nested conditional MySQL conditional options';
    PE_IncompleteStmt:
      Result := 'Incompleted statement';
    PE_UnexpectedToken:
      if (Length = 1) then
        Result := 'Unexpected character'
      else
        Result := 'Unexpected string';
    PE_ExtraToken:
      if (Length = 1) then
        Result := 'Unexpected character'
      else
        Result := 'Unexpected string';
    PE_UnexpectedStmt:
      Result := 'Statement not allowed here';
    else
      raise ERangeError.Create(SRangeError);
  end;

  if ((Error.Code in [PE_IncompleteToken, PE_UnexpectedChar]) and Assigned(Error.Pos)) then
  begin
    if (Error.Token > 0) then
    begin
      Dec(Length, Integer(Error.Pos - Text));
      SetString(S, Error.Pos, Length);
      Result := Result + ' near "' + Copy(S, 1, 20) + '"';
    end
    else if (Assigned(Error.Pos)) then
      Result := Result + ' near "' + Location(Error.Pos) + '"';
  end
  else if ((Error.Code in [PE_IncompleteToken, PE_UnexpectedChar, PE_UnexpectedToken, PE_ExtraToken]) and (Error.Token > 0)) then
  begin
    SetString(S, Text, Length);
    Result := Result + ' near "' + Copy(S, 1, 20) + '"';
  end;

  if ((Error.Code in [PE_IncompleteToken, PE_UnexpectedChar, PE_InvalidMySQLCond, PE_NestedMySQLCond, PE_IncompleteStmt, PE_UnexpectedToken, PE_ExtraToken, PE_UnexpectedStmt])
    and (Error.Line > 0)) then
    Result := Result + ' in line ' + IntToStr(Error.Line);
end;

destructor TSQLParser.Destroy();
begin
  if (Nodes.MemSize <> 0) then
    FreeMem(Nodes.Mem);

  CharsetList.Free();
  FCompletionList.Free();
  FConstantList.Free();
  DatatypeList.Free();
  FFunctionList.Free();
  KeywordList.Free();
  ReservedWordList.Free();

  inherited;
end;

function TSQLParser.EndOfStmt(const Token: PToken): Boolean;
begin
  Result := Token^.TokenType = ttSemicolon;
end;

function TSQLParser.EndOfStmt(const Token: TOffset): Boolean;
begin
  Result := (Token = 0) or (TokenPtr(Token)^.TokenType = ttSemicolon);
end;

procedure TSQLParser.EndPL_SQL();
begin
  Assert(FInPL_SQL > 0);

  if (FInPL_SQL > 0) then
    Dec(FInPL_SQL);
end;

procedure TSQLParser.FormatAccount(const Nodes: TAccount.TNodes);
begin
  FormatNode(Nodes.UserIdent);
  FormatNode(Nodes.AtToken);
  FormatNode(Nodes.HostIdent);
end;

procedure TSQLParser.FormatAlterDatabaseStmt(const Nodes: TAlterDatabaseStmt.TNodes);
begin
  FormatNode(Nodes.AlterTag);
  FormatNode(Nodes.DatabaseTag, stSpaceBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);

  if (Nodes.UpgradeDataDirectoryNameTag = 0) then
  begin
    FormatNode(Nodes.CharsetValue, stSpaceBefore);
    FormatNode(Nodes.CollateValue, stSpaceBefore);
  end
  else
    FormatNode(Nodes.UpgradeDataDirectoryNameTag, stSpaceBefore);
end;

procedure TSQLParser.FormatAlterEventStmt(const Nodes: TAlterEventStmt.TNodes);
begin
  FormatNode(Nodes.AlterTag);
  FormatNode(Nodes.DefinerValue, stSpaceBefore);
  FormatNode(Nodes.EventTag, stSpaceBefore);
  FormatNode(Nodes.EventIdent, stSpaceBefore);

  if (Nodes.OnSchedule.Tag > 0) then
  begin
    Assert(Nodes.OnSchedule.Value > 0);

    Commands.IncreaseIndent();
    FormatNode(Nodes.OnSchedule.Tag, stReturnBefore);
    Commands.IncreaseIndent();
    FormatNode(Nodes.OnSchedule.Value, stReturnBefore);
    Commands.DecreaseIndent();
    Commands.DecreaseIndent();
  end;

  if (Nodes.OnCompletionTag > 0) then
  begin
    Commands.IncreaseIndent();
    FormatNode(Nodes.OnCompletionTag, stReturnBefore);
    Commands.DecreaseIndent();
  end;

  if (Nodes.RenameValue > 0) then
  begin
    Commands.IncreaseIndent();
    FormatNode(Nodes.RenameValue, stReturnBefore);
    Commands.DecreaseIndent();
  end;

  if (Nodes.EnableTag > 0) then
  begin
    Commands.IncreaseIndent();
    FormatNode(Nodes.EnableTag, stReturnBefore);
    Commands.DecreaseIndent();
  end;

  if (Nodes.CommentValue > 0) then
  begin
    Commands.IncreaseIndent();
    FormatNode(Nodes.CommentValue, stReturnBefore);
    Commands.DecreaseIndent();
  end;

  if (Nodes.DoTag > 0) then
  begin
    Assert(Nodes.Stmt > 0);

    Commands.IncreaseIndent();
    FormatNode(Nodes.DoTag, stReturnBefore);
    Commands.DecreaseIndent();
    FormatNode(Nodes.Stmt, stReturnBefore);
  end;
end;

procedure TSQLParser.FormatAlterRoutineStmt(const Nodes: TAlterRoutineStmt.TNodes);
begin
  FormatNode(Nodes.AlterTag);
  FormatNode(Nodes.RoutineTag, stSpaceBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.CommentValue, stReturnBefore);
  FormatNode(Nodes.LanguageTag, stReturnBefore);
  FormatNode(Nodes.DeterministicTag, stReturnBefore);
  FormatNode(Nodes.NatureOfDataTag, stReturnBefore);
  FormatNode(Nodes.SQLSecurityTag, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatAlterTablespaceStmt(const Nodes: TAlterTablespaceStmt.TNodes);
begin
  FormatNode(Nodes.AlterTag);
  FormatNode(Nodes.TablespaceTag, stSpaceBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.AddDatafileValue, stReturnBefore);
  FormatNode(Nodes.InitialSizeValue, stReturnBefore);
  FormatNode(Nodes.EngineValue, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatAlterTableStmt(const Nodes: TAlterTableStmt.TNodes);
begin
  FormatNode(Nodes.AlterTag);
  FormatNode(Nodes.IgnoreTag, stSpaceBefore);
  FormatNode(Nodes.TableTag, stSpaceBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  if (Nodes.SpecificationList > 0) then
  begin
    Commands.WriteReturn();
    Commands.IncreaseIndent();
    FormatList(Nodes.SpecificationList, sReturn);
    Commands.DecreaseIndent();
  end;
  FormatNode(Nodes.PartitionOptions, stReturnBefore);
end;

procedure TSQLParser.FormatAlterTableStmtAlterField(const Nodes: TAlterTableStmt.TAlterField.TNodes);
begin
  FormatNode(Nodes.AlterTag);
  FormatNode(Nodes.ColumnTag, stSpaceBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  FormatNode(Nodes.SetDefaultValue, stSpaceBefore);
  FormatNode(Nodes.DropDefaultTag, stSpaceBefore);
end;

procedure TSQLParser.FormatAlterViewStmt(const Nodes: TAlterViewStmt.TNodes);
begin
  FormatNode(Nodes.AlterTag);
  Commands.IncreaseIndent();
  FormatNode(Nodes.AlgorithmValue, stReturnBefore);
  FormatNode(Nodes.DefinerValue, stReturnBefore);
  FormatNode(Nodes.SQLSecurityTag, stReturnBefore);
  FormatNode(Nodes.ViewTag, stReturnBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  FormatNode(Nodes.Columns, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.AsTag, stReturnBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.SelectStmt, stReturnBefore);
  Commands.DecreaseIndent();
  Commands.DecreaseIndent();
  FormatNode(Nodes.OptionTag, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatBeginLabel(const Nodes: TBeginLabel.TNodes);
begin
  FormatNode(Nodes.BeginToken);
  FormatNode(Nodes.ColonToken);
end;

procedure TSQLParser.FormatCallStmt(const Nodes: TCallStmt.TNodes);
begin
  FormatNode(Nodes.CallTag);
  FormatNode(Nodes.Ident, stSpaceBefore);
  FormatNode(Nodes.ParamList);
end;

procedure TSQLParser.FormatCaseOp(const Nodes: TCaseOp.TNodes);
var
  BranchCount: Integer;
  Separator: TSeparatorType;
  Spacer: TSpacer;
begin
  if ((Nodes.BranchList = 0) or (NodePtr(Nodes.BranchList)^.NodeType <> ntList)) then
    BranchCount := 1
  else
    BranchCount := PList(NodePtr(Nodes.BranchList))^.ElementCount;
  if (Nodes.ElseTag > 0) then
    Inc(BranchCount);
  if (BranchCount <= 3) then
  begin
    Separator := stSpaceBefore;
    Spacer := sSpace;
  end
  else
  begin
    Separator := stReturnBefore;
    Spacer := sReturn;
  end;

  FormatNode(Nodes.CaseTag);
  FormatNode(Nodes.CompareExpr, stSpaceBefore);
  if (Separator = stSpaceBefore) then
  begin
    FormatNode(Nodes.BranchList, Separator);
    FormatNode(Nodes.ElseTag, Separator);
    FormatNode(Nodes.ElseExpr, stSpaceBefore);
  end
  else
  begin
    Commands.IncreaseIndent();
    Commands.WriteReturn();
    FormatList(Nodes.BranchList, Spacer);
    FormatNode(Nodes.ElseTag, Separator);
    FormatNode(Nodes.ElseExpr, stSpaceBefore);
    Commands.DecreaseIndent();
  end;
  FormatNode(Nodes.EndTag, Separator);
end;

procedure TSQLParser.FormatCaseStmt(const Nodes: TCaseStmt.TNodes);
begin
  FormatNode(Nodes.CaseTag);
  FormatNode(Nodes.CompareExpr, stSpaceBefore);
  Commands.WriteReturn();
  FormatList(Nodes.BranchList, sReturn);
  FormatNode(Nodes.EndTag, stReturnBefore);
end;

procedure TSQLParser.FormatCaseStmtBranch(const Nodes: TCaseStmt.TBranch.TNodes);
begin
  if ((Nodes.BranchTag > 0) and (NodePtr(Nodes.BranchTag)^.NodeType = ntTag)) then
  begin
    FormatNode(Nodes.BranchTag);
    if (IsToken(PTag(NodePtr(Nodes.BranchTag))^.Nodes.Keyword1Token)
      and (TokenPtr(PTag(NodePtr(Nodes.BranchTag))^.Nodes.Keyword1Token)^.KeywordIndex = kiWHEN)) then
    begin
      FormatNode(Nodes.ConditionExpr, stSpaceBefore);
      FormatNode(Nodes.ThenTag, stSpaceBefore);
    end;
  end;
  Commands.WriteReturn();
  Commands.IncreaseIndent();
  FormatList(Nodes.StmtList, sReturn);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatCastFunc(const Nodes: TCastFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.Expr);
  FormatNode(Nodes.AsTag, stSpaceBefore);
  FormatNode(Nodes.DatatypeIdent, stSpaceBefore);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatCharFunc(const Nodes: TCharFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.ValueExpr);
  if (Nodes.UsingTag > 0) then
  begin
    FormatNode(Nodes.UsingTag, stSpaceBefore);
    FormatNode(Nodes.CharsetIdent, stSpaceBefore);
  end;
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatChangeMasterStmt(const Nodes: TChangeMasterStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.ToTag, stSpaceBefore);
  Commands.WriteReturn();
  Commands.IncreaseIndent();
  FormatList(Nodes.OptionList, sReturn);
  FormatNode(Nodes.ChannelOptionValue, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatCompoundStmt(const Nodes: TCompoundStmt.TNodes);
begin
  FormatNode(Nodes.BeginLabel, stSpaceAfter);
  FormatNode(Nodes.BeginTag);
  if (Nodes.StmtList > 0) then
  begin
    Commands.WriteReturn();
    Commands.IncreaseIndent();
    FormatList(Nodes.StmtList, sReturn);
    Commands.DecreaseIndent();
  end;
  FormatNode(Nodes.EndTag, stReturnBefore);
  FormatNode(Nodes.EndLabel, stSpaceBefore);
end;

procedure TSQLParser.FormatConvertFunc(const Nodes: TConvertFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.Expr);
  if (Nodes.Comma > 0) then
  begin
    FormatNode(Nodes.Comma);
    FormatNode(Nodes.Datatype, stSpaceBefore);
  end
  else
  begin
    FormatNode(Nodes.UsingTag, stSpaceBefore);
    FormatNode(Nodes.CharsetIdent, stSpaceBefore);
  end;
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatCountFunc(const Nodes: TCountFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.DistinctTag);
  if ((Nodes.DistinctTag > 0) and (Nodes.ExprNode > 0)) then
    Commands.WriteSpace();
  FormatNode(Nodes.ExprNode);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatCreateEventStmt(const Nodes: TCreateEventStmt.TNodes);
begin
  FormatNode(Nodes.CreateTag);
  FormatNode(Nodes.OrReplaceTag, stSpaceBefore);
  FormatNode(Nodes.DefinerValue, stSpaceBefore);
  FormatNode(Nodes.EventTag, stSpaceBefore);
  FormatNode(Nodes.IfNotExistsTag, stSpaceBefore);
  FormatNode(Nodes.EventIdent, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.OnScheduleValue, stReturnBefore);
  FormatNode(Nodes.OnCompletitionTag, stReturnBefore);
  FormatNode(Nodes.EnableTag, stReturnBefore);
  FormatNode(Nodes.CommentValue, stReturnBefore);
  FormatNode(Nodes.DoTag, stReturnBefore);
  Commands.DecreaseIndent();
  FormatNode(Nodes.Stmt, stReturnBefore);
end;

procedure TSQLParser.FormatCreateIndexStmt(const Nodes: TCreateIndexStmt.TNodes);
begin
  FormatNode(Nodes.CreateTag);
  FormatNode(Nodes.OrReplaceTag, stSpaceBefore);
  FormatNode(Nodes.KindTag, stSpaceBefore);
  FormatNode(Nodes.IndexTag, stSpaceBefore);
  FormatNode(Nodes.IfNotExistsTag, stSpaceBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.IndexTypeValue, stReturnBefore);
  FormatNode(Nodes.OnTag, stReturnBefore);
  FormatNode(Nodes.TableIdent, stSpaceBefore);
  FormatNode(Nodes.KeyColumnList, stSpaceBefore);
  FormatNode(Nodes.AlgorithmLockValue, stReturnBefore);
  FormatNode(Nodes.CommentValue, stReturnBefore);
  FormatNode(Nodes.KeyBlockSizeValue, stReturnBefore);
  FormatNode(Nodes.ParserValue, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatCreateRoutineStmt(const Nodes: TCreateRoutineStmt.TNodes);
var
  Spacer: TSpacer;
begin
  if (((Nodes.ParameterList = 0)
      or (NodePtr(Nodes.ParameterList)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.ParameterList))^.ElementCount <= 3))) then
  begin
    Spacer := sSpace;
  end
  else
  begin
    Spacer := sReturn;
  end;


  FormatNode(Nodes.CreateTag);
  FormatNode(Nodes.OrReplaceTag, stSpaceBefore);
  FormatNode(Nodes.DefinerNode, stSpaceBefore);
  FormatNode(Nodes.RoutineTag, stSpaceBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  FormatList(Nodes.ParameterList, Spacer);
  FormatNode(Nodes.Returns, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.CommentValue, stReturnBefore);
  FormatNode(Nodes.LanguageTag, stReturnBefore);
  FormatNode(Nodes.DeterministicTag, stReturnBefore);
  FormatNode(Nodes.NatureOfDataTag, stReturnBefore);
  FormatNode(Nodes.SQLSecurityTag, stReturnBefore);
  Commands.DecreaseIndent();
  FormatNode(Nodes.Stmt, stReturnBefore);
end;

procedure TSQLParser.FormatCreateServerStmt(const Nodes: TCreateServerStmt.TNodes);
begin
  FormatNode(Nodes.CreateTag);
  FormatNode(Nodes.ServerTag, stSpaceBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.ForeignDataWrapperValue, stReturnBefore);
  FormatNode(Nodes.Options.Tag, stReturnBefore);
  FormatNode(Nodes.Options.List, stSpaceBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatCreateTablespaceStmt(const Nodes: TCreateTablespaceStmt.TNodes);
begin
  FormatNode(Nodes.CreateTag);
  FormatNode(Nodes.TablespaceTag, stSpaceBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.AddDatafileValue, stReturnBefore);
  FormatNode(Nodes.FileBlockSizeValue, stReturnBefore);
  FormatNode(Nodes.EngineValue, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatCreateTableStmt(const Nodes: TCreateTableStmt.TNodes);
begin
  FormatNode(Nodes.CreateTag);
  FormatNode(Nodes.OrReplaceTag, stSpaceBefore);
  FormatNode(Nodes.TemporaryTag, stSpaceBefore);
  FormatNode(Nodes.TableTag, stSpaceBefore);
  FormatNode(Nodes.IfNotExistsTag, stSpaceBefore);
  FormatNode(Nodes.TableIdent, stSpaceBefore);
  if (Nodes.DefinitionList > 0) then
  begin
    Commands.WriteSpace();
    FormatList(Nodes.DefinitionList, sReturn);
  end
  else if (Nodes.Like.Tag > 0) then
  begin
    Commands.IncreaseIndent();
    Commands.WriteReturn();
    FormatNode(Nodes.Like.OpenBracket);
    FormatNode(Nodes.Like.Tag);
    FormatNode(Nodes.Like.TableIdent, stSpaceBefore);
    FormatNode(Nodes.Like.CloseBracket);
    Commands.DecreaseIndent();
  end;
  FormatNode(Nodes.TableOptionList, stSpaceBefore);
  FormatNode(Nodes.PartitionOptions, stReturnBefore);
  FormatNode(Nodes.IgnoreReplaceTag, stReturnBefore);
  if (Nodes.SelectStmt2 > 0) then
  begin
    FormatNode(Nodes.AsTag);
    Commands.IncreaseIndent();
    FormatNode(Nodes.SelectStmt2, stReturnBefore);
    Commands.DecreaseIndent();
  end;
end;

procedure TSQLParser.FormatCreateTableStmtField(const Nodes: TCreateTableStmt.TField.TNodes);
begin
  FormatNode(Nodes.Ident);
  FormatNode(Nodes.Datatype, stSpaceBefore);
  if (Nodes.Virtual.AsTag = 0) then
  begin // Real field
    FormatNode(Nodes.NullTag, stSpaceBefore);
    FormatNode(Nodes.Real.Default.Tag, stSpaceBefore);
    FormatNode(Nodes.Real.Default.Expr, stSpaceBefore);
    FormatNode(Nodes.Real.AutoIncrementTag, stSpaceBefore);
    FormatNode(Nodes.KeyTag, stSpaceBefore);
    FormatNode(Nodes.CommentValue, stSpaceBefore);
    FormatNode(Nodes.Real.ColumnFormat, stSpaceBefore);
    FormatNode(Nodes.Real.StorageTag, stSpaceBefore);
    FormatNode(Nodes.Real.Reference, stSpaceBefore);
  end
  else
  begin // Virtual field
    FormatNode(Nodes.Virtual.GernatedAlwaysTag, stSpaceBefore);
    FormatNode(Nodes.Virtual.AsTag, stSpaceBefore);
    FormatNode(Nodes.Virtual.Expr, stSpaceBefore);
    FormatNode(Nodes.Virtual.Virtual, stSpaceBefore);
    FormatNode(Nodes.KeyTag, stSpaceBefore);
    FormatNode(Nodes.CommentValue, stSpaceBefore);
    FormatNode(Nodes.NullTag, stSpaceBefore);
  end;
end;

procedure TSQLParser.FormatCreateTableStmtKey(const Nodes: TCreateTableStmt.TKey.TNodes);
begin
  FormatNode(Nodes.AddTag, stSpaceAfter);
  FormatNode(Nodes.ConstraintTag, stSpaceAfter);
  FormatNode(Nodes.ConstraintIdent, stSpaceAfter);
  FormatNode(Nodes.KeyTag);
  FormatNode(Nodes.KeyIdent, stSpaceBefore);
  FormatNode(Nodes.IndexTypeTag, stSpaceBefore);
  Commands.WriteSpace();
  FormatList(Nodes.KeyColumnList, sNone);
  FormatNode(Nodes.KeyBlockSizeValue, stSpaceBefore);
  FormatNode(Nodes.WithParserValue, stSpaceBefore);
  FormatNode(Nodes.CommentValue, stSpaceBefore);
end;

procedure TSQLParser.FormatCreateTableStmtKeyColumn(const Nodes: TCreateTableStmt.TKeyColumn.TNodes);
begin
  FormatNode(Nodes.IdentTag);

  if (Nodes.OpenBracket > 0) then
  begin
    FormatNode(Nodes.OpenBracket);
    FormatNode(Nodes.LengthToken);
    FormatNode(Nodes.CloseBracket);
  end;

  FormatNode(Nodes.SortTag, stSpaceBefore);
end;

procedure TSQLParser.FormatCreateTableStmtPartitionOptions(const Nodes: TCreateTableStmt.TPartitionOptions.TNodes);
begin
  Commands.IncreaseIndent();
  FormatNode(Nodes.Tag);
  Commands.IncreaseIndent();
  FormatNode(Nodes.KindTag, stReturnBefore);
  FormatNode(Nodes.Expr, stSpaceBefore);
  FormatNode(Nodes.AlgorithmValue, stSpaceBefore);
  FormatNode(Nodes.Columns.Tag, stSpaceBefore);
  FormatNode(Nodes.Columns.List, stSpaceBefore);
  Commands.DecreaseIndent();
  FormatNode(Nodes.PartitionCount, stReturnBefore);
  if (Nodes.SubPartition.Tag > 0) then
  begin
    FormatNode(Nodes.SubPartition.Tag, stReturnBefore);
    Commands.IncreaseIndent();
    FormatNode(Nodes.SubPartition.KindTag, stReturnBefore);
    FormatNode(Nodes.SubPartition.Expr, stSpaceBefore);
    FormatNode(Nodes.SubPartition.AlgorithmValue, stSpaceBefore);
    FormatNode(Nodes.SubPartition.ColumnList, stSpaceBefore);
    Commands.DecreaseIndent();
    FormatNode(Nodes.SubPartition.Value, stReturnBefore);
    Commands.WriteReturn();
  end;
  Commands.IncreaseIndent();
  FormatList(Nodes.DefinitionList, sReturn);
  Commands.DecreaseIndent();
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatCreateTableStmtReference(const Nodes: TCreateTableStmt.TReference.TNodes);
begin
  FormatNode(Nodes.Tag);
  FormatNode(Nodes.ParentTableIdent, stSpaceBefore);
  FormatNode(Nodes.FieldList, stSpaceBefore);
  FormatNode(Nodes.MatchTag, stSpaceBefore);
  FormatNode(Nodes.OnDeleteTag, stSpaceBefore);
  FormatNode(Nodes.OnUpdateTag, stSpaceBefore);
end;

procedure TSQLParser.FormatCreateTriggerStmt(const Nodes: TCreateTriggerStmt.TNodes);
begin
  FormatNode(Nodes.CreateTag);
  FormatNode(Nodes.OrReplaceTag, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.DefinerNode, stSpaceBefore);
  FormatNode(Nodes.TriggerTag, stSpaceBefore);
  FormatNode(Nodes.IfNotExistsTag, stSpaceBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  FormatNode(Nodes.TimeTag, stReturnBefore);
  FormatNode(Nodes.EventTag, stSpaceBefore);
  FormatNode(Nodes.OnTag, stSpaceBefore);
  FormatNode(Nodes.TableIdent, stSpaceBefore);
  FormatNode(Nodes.ForEachRowTag, stReturnBefore);
  FormatNode(Nodes.OrderValue, stReturnBefore);
  Commands.DecreaseIndent();
  FormatNode(Nodes.Stmt, stReturnBefore);
end;

procedure TSQLParser.FormatCreateUserStmt(const Nodes: TCreateUserStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.OrReplaceTag, stSpaceBefore);
  FormatNode(Nodes.UserTag, stSpaceBefore);
  FormatNode(Nodes.IfNotExistsTag, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.UserSpecifications, stReturnBefore);
  if (Nodes.WithTag > 0) then
  begin
    FormatNode(Nodes.WithTag, stReturnBefore);
    FormatNode(Nodes.MaxQueriesPerHour, stSpaceBefore);
    FormatNode(Nodes.MaxUpdatesPerHour, stSpaceBefore);
    FormatNode(Nodes.MaxConnectionsPerHour, stSpaceBefore);
    FormatNode(Nodes.MaxUserConnections, stSpaceBefore);
  end;
  FormatNode(Nodes.PasswordOption.Tag, stReturnBefore);
  FormatNode(Nodes.PasswordOption.QuantityInt, stSpaceBefore);
  FormatNode(Nodes.PasswordOption.UnitTag, stSpaceBefore);
  FormatNode(Nodes.AccountTag, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatCreateViewStmt(const Nodes: TCreateViewStmt.TNodes);
begin
  FormatNode(Nodes.CreateTag);
  Commands.IncreaseIndent();
  FormatNode(Nodes.OrReplaceTag, stReturnBefore);
  FormatNode(Nodes.AlgorithmValue, stReturnBefore);
  FormatNode(Nodes.DefinerValue, stReturnBefore);
  FormatNode(Nodes.SQLSecurityTag, stReturnBefore);
  FormatNode(Nodes.ViewTag, stReturnBefore);
  FormatNode(Nodes.IfNotExistsTag, stSpaceBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  FormatNode(Nodes.FieldList, stSpaceBefore);
  FormatNode(Nodes.AsTag, stReturnBefore);
  Commands.DecreaseIndent();
  FormatNode(Nodes.SelectStmt, stReturnBefore);
  Commands.IncreaseIndent();
  Commands.DecreaseIndent();
  FormatNode(Nodes.OptionTag, stReturnBefore);
end;

procedure TSQLParser.FormatComments(const Token: PToken; Start: Boolean = False);
var
  Comment: string;
  Index: Integer;
  Length: Integer;
  ReturnFound: Boolean;
  Spacer: TSpacer;
  T: PToken;
  Text: PChar;
begin
  ReturnFound := False; Spacer := sNone;
  T := Token;
  while (Assigned(T) and not T^.IsUsed) do
  begin
    case (T^.TokenType) of
      ttReturn:
        ReturnFound := True;
      ttSLComment:
        begin
          if (not Start) then
            if (not ReturnFound) then
              Commands.WriteSpace()
            else
              Commands.WriteReturn();
          T^.GetText(Text, Length);
          while ((Length > 0) and CharInSet(Text[0], [#9, #10, #13, ' '])) do
            Dec(Length);
          Commands.Write(Text, Length);
          ReturnFound := False;
          Spacer := sReturn;
          Start := False;
        end;
      ttMLComment:
        begin
          Comment := T^.AsString;
          if (Pos(#13#10, Comment) = 0) then
          begin
            if (not Start) then
              if (not ReturnFound) then
                Commands.WriteSpace()
              else
                Commands.WriteReturn();
            Commands.Write('/* ');
            Commands.Write(Comment);
            Commands.Write(' */');

            ReturnFound := False;
          end
          else
          begin
            if (not Start) then
              Commands.WriteReturn();
            Commands.Write('/*');
            Commands.IncreaseIndent();
            Commands.WriteReturn();

            Index := Pos(#13#10, Comment);
            while (Index > 0) do
            begin
              Commands.Write(Copy(Comment, 1, Index - 1));
              Commands.WriteReturn();
              System.Delete(Comment, 1, Index + 1);
              Index := Pos(#13#10, Comment);
            end;
            Commands.Write(Trim(Comment));

            Commands.DecreaseIndent();
            Commands.WriteReturn();
            Commands.Write('*/');

            ReturnFound := False;
            Spacer := sReturn;
          end;
          Start := False;
        end;
    end;

    T := T^.NextTokenAll;
  end;

  case (Spacer) of
    sSpace:
      begin
        Commands.WriteSpace();
        CommentsWritten := True;
      end;
    sReturn:
      begin
        Commands.WriteReturn();
        CommentsWritten := True;
      end;
  end;
end;

procedure TSQLParser.FormatDatatype(const Nodes: TDatatype.TNodes);
begin
  FormatNode(Nodes.NationalToken, stSpaceAfter);

  FormatNode(Nodes.DatatypeToken);
  if (Nodes.OpenBracket > 0) then
  begin
    FormatNode(Nodes.OpenBracket);
    FormatNode(Nodes.LengthToken);
    FormatNode(Nodes.CommaToken);
    FormatNode(Nodes.DecimalsToken);
    FormatNode(Nodes.CloseBracket);
  end
  else if (Nodes.ItemList > 0) then
    FormatList(Nodes.ItemList, sNone);

  FormatNode(Nodes.SignedToken, stSpaceBefore);
  FormatNode(Nodes.ZerofillTag, stSpaceBefore);
  FormatNode(Nodes.CharacterSetValue, stSpaceBefore);
  FormatNode(Nodes.CollateValue, stSpaceBefore);
  FormatNode(Nodes.BinaryToken, stSpaceBefore);
  FormatNode(Nodes.ASCIIToken, stSpaceBefore);
  FormatNode(Nodes.UnicodeToken, stSpaceBefore);
end;

procedure TSQLParser.FormatDateAddFunc(const Nodes: TDateAddFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.DateExpr);
  FormatNode(Nodes.CommaToken);
  FormatNode(Nodes.IntervalExpr, stSpaceBefore);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatDbIdent(const Nodes: TDbIdent.TNodes);
begin
  if (Nodes.DatabaseIdent > 0) then
  begin
    FormatNode(Nodes.DatabaseIdent);
    FormatNode(Nodes.DatabaseDot);
  end;
  if (Nodes.TableIdent > 0) then
  begin
    FormatNode(Nodes.TableIdent);
    FormatNode(Nodes.TableDot);
  end;
  FormatNode(Nodes.Ident);
end;

procedure TSQLParser.FormatDeclareCursorStmt(const Nodes: TDeclareCursorStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.IdentList, stSpaceBefore);
  FormatNode(Nodes.CursorTag, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.SelectStmt, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatDeclareHandlerStmt(const Nodes: TDeclareHandlerStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.ActionTag, stSpaceBefore);
  FormatNode(Nodes.HandlerTag, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.ForTag, stSpaceBefore);
  FormatNode(Nodes.ConditionsList, stSpaceBefore);
  FormatNode(Nodes.Stmt, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatDeleteStmt(const Nodes: TDeleteStmt.TNodes);
var
  Separator: TSeparatorType;
  Spacer: TSpacer;
begin
  if (((Nodes.From1.List = 0)
      or (NodePtr(Nodes.From1.List)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.From1.List))^.ElementCount = 1))
    and ((Nodes.From2.TableReferenceList = 0)
      or (NodePtr(Nodes.From2.TableReferenceList)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.From2.TableReferenceList))^.Nodes.FirstElement = 0)
      or (NodePtr(PList(NodePtr(Nodes.From2.TableReferenceList))^.Nodes.FirstElement)^.NodeType <> ntList)
      or (PList(NodePtr(PList(NodePtr(Nodes.From2.TableReferenceList))^.Nodes.FirstElement))^.ElementCount = 1))
    and ((Nodes.Using.TableReferenceList = 0)
      or (NodePtr(Nodes.Using.TableReferenceList)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.Using.TableReferenceList))^.Nodes.FirstElement = 0)
      or (NodePtr(PList(NodePtr(Nodes.Using.TableReferenceList))^.Nodes.FirstElement)^.NodeType <> ntList)
      or (PList(NodePtr(PList(NodePtr(Nodes.Using.TableReferenceList))^.Nodes.FirstElement))^.ElementCount = 1))
    and ((Nodes.Where.Expr = 0)
      or (NodePtr(Nodes.Where.Expr)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.Where.Expr))^.ElementCount <= 3))) then
  begin
    Separator := stSpaceBefore;
    Spacer := sSpace;
  end
  else
  begin
    Separator := stReturnBefore;
    Spacer := sReturn;
  end;

  FormatNode(Nodes.DeleteTag);
  FormatNode(Nodes.LowPriorityTag, stSpaceBefore);
  FormatNode(Nodes.QuickTag, stSpaceBefore);
  FormatNode(Nodes.IgnoreTag, stSpaceBefore);


  if ((Nodes.From2.Tag = 0)
    and (Nodes.From1.List > 0)
    and (NodePtr(Nodes.From1.List)^.NodeType = ntList)
    and (PList(NodePtr(Nodes.From1.List))^.ElementCount = 1)) then
  begin
    FormatNode(Nodes.From1.Tag, Separator);
    if (Separator = stSpaceBefore) then
      FormatNode(Nodes.From1.List, stSpaceBefore)
    else
    begin
      Commands.WriteReturn();
      Commands.IncreaseIndent();
      FormatList(Nodes.From1.List, Spacer);
      Commands.DecreaseIndent();
    end;
    if (Nodes.Partition.Tag > 0) then
    begin
      FormatNode(Nodes.Partition.Tag, Separator);
      if (Separator = stSpaceBefore) then
        FormatNode(Nodes.Partition.List, stSpaceBefore)
      else
      begin
        Commands.WriteReturn();
        Commands.IncreaseIndent();
        FormatList(Nodes.Partition.List, Spacer);
        Commands.DecreaseIndent();
      end;
    end;
  end
  else if (Nodes.From1.Tag = 0) then
  begin
    if (Separator = stSpaceBefore) then
      FormatNode(Nodes.From1.List, stSpaceBefore)
    else
    begin
      Commands.WriteReturn();
      Commands.IncreaseIndent();
      FormatList(Nodes.From1.List, Spacer);
      Commands.DecreaseIndent();
    end;
    FormatNode(Nodes.From2.Tag, Separator);
    if (Separator = stSpaceBefore) then
      FormatNode(Nodes.From2.TableReferenceList, stSpaceBefore)
    else
    begin
      Commands.WriteReturn();
      Commands.IncreaseIndent();
      FormatList(Nodes.From2.TableReferenceList, Spacer);
      Commands.DecreaseIndent();
    end;
  end
  else
  begin
    FormatNode(Nodes.From1.Tag, Separator);
    if (Separator = stSpaceBefore) then
      FormatNode(Nodes.From1.List, stSpaceBefore)
    else
    begin
      Commands.WriteReturn();
      Commands.IncreaseIndent();
      FormatList(Nodes.From1.List, Spacer);
      Commands.DecreaseIndent();
    end;
    FormatNode(Nodes.Using.Tag, Separator);
    if (Separator = stSpaceBefore) then
      FormatNode(Nodes.Using.TableReferenceList, stSpaceBefore)
    else
    begin
      Commands.WriteReturn();
      Commands.IncreaseIndent();
      FormatList(Nodes.Using.TableReferenceList, Spacer);
      Commands.DecreaseIndent();
    end;
  end;

  if (Nodes.Where.Tag > 0) then
  begin
    FormatNode(Nodes.Where.Tag, Separator);
    if (Separator = stSpaceBefore) then
      FormatNode(Nodes.Where.Expr, stSpaceBefore)
    else
    begin
      Commands.WriteReturn();
      Commands.IncreaseIndent();
      FormatList(Nodes.Where.Expr, Spacer);
      Commands.DecreaseIndent();
    end;
  end;

  if (Nodes.OrderBy.Tag > 0) then
  begin
    FormatNode(Nodes.Partition.Tag, Separator);
    if (Separator = stSpaceBefore) then
      FormatNode(Nodes.OrderBy.List, stSpaceBefore)
    else
    begin
      Commands.WriteReturn();
      Commands.IncreaseIndent();
      FormatList(Nodes.OrderBy.List, Spacer);
      Commands.DecreaseIndent();
    end;
  end;

  FormatNode(Nodes.Limit.Tag, Separator);
  FormatNode(Nodes.Limit.Token, stSpaceBefore);
end;

procedure TSQLParser.FormatDefaultFunc(const Nodes: TDefaultFunc.TNodes);
begin
  FormatNode(Nodes.Ident);
  FormatNode(Nodes.ArgumentsList);
end;

procedure TSQLParser.FormatDropTablespaceStmt(const Nodes: TDropTablespaceStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.Ident, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.EngineValue, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatExtractFunc(const Nodes: TExtractFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.UnitTag);
  FormatNode(Nodes.FromTag, stSpaceBefore);
  FormatNode(Nodes.QuantityExpr, stSpaceBefore);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatFetchStmt(const Nodes: TFetchStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.NextTag, stSpaceBefore);
  FormatNode(Nodes.FromTag, stSpaceBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  FormatNode(Nodes.IntoTag, stSpaceBefore);
  FormatNode(Nodes.VariableList, stSpaceBefore);
end;

procedure TSQLParser.FormatGroupConcatFunc(const Nodes: TGroupConcatFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.DistinctTag, stSpaceAfter);
  FormatNode(Nodes.ExprList);
  Commands.IncreaseIndent();
  if (Nodes.OrderBy.Tag > 0) then
  begin
    FormatNode(Nodes.OrderBy.Tag, stSpaceBefore);
    FormatNode(Nodes.OrderBy.Expr, stSpaceBefore);
  end;
  FormatNode(Nodes.SeparatorValue, stSpaceBefore);
  Commands.DecreaseIndent();
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatIfStmt(const Nodes: TIfStmt.TNodes);
begin
  FormatList(Nodes.BranchList, sReturn);
  FormatNode(Nodes.EndTag, stReturnBefore);
end;

procedure TSQLParser.FormatIfStmtBranch(const Nodes: TIfStmt.TBranch.TNodes);
begin
  Assert((Nodes.BranchTag > 0) and (NodePtr(Nodes.BranchTag)^.NodeType = ntTag));

  if ((Nodes.BranchTag > 0)
    and (NodePtr(Nodes.BranchTag)^.NodeType = ntTag)
    and IsToken(PTag(NodePtr(Nodes.BranchTag))^.Nodes.Keyword1Token)) then
    if (TokenPtr(PTag(NodePtr(Nodes.BranchTag))^.Nodes.Keyword1Token)^.KeywordIndex = kiIF) then
    begin
      FormatNode(Nodes.BranchTag);
      FormatNode(Nodes.ConditionExpr, stSpaceBefore);
      Commands.IncreaseIndent();
      FormatNode(Nodes.ThenTag, stSpaceBefore);
      FormatNode(Nodes.StmtList, stReturnBefore);
      Commands.DecreaseIndent();
    end
    else if (TokenPtr(PTag(NodePtr(Nodes.BranchTag))^.Nodes.Keyword1Token)^.KeywordIndex = kiELSEIF) then
    begin
      FormatNode(Nodes.BranchTag);
      Commands.IncreaseIndent();
      FormatNode(Nodes.ConditionExpr, stSpaceBefore);
      FormatNode(Nodes.ThenTag, stSpaceBefore);
      FormatNode(Nodes.StmtList, stReturnBefore);
      Commands.DecreaseIndent();
    end
    else if (TokenPtr(PTag(NodePtr(Nodes.BranchTag))^.Nodes.Keyword1Token)^.KeywordIndex = kiELSE) then
    begin
      FormatNode(Nodes.BranchTag);
      Commands.IncreaseIndent();
      FormatNode(Nodes.StmtList, stReturnBefore);
      Commands.DecreaseIndent();
    end;
end;

procedure TSQLParser.FormatInsertStmt(const Nodes: TInsertStmt.TNodes);
var
  Separator: TSeparatorType;
begin
  if ((Nodes.ColumnList = 0)
    and ((Nodes.Values.List = 0)
      or (NodePtr(Nodes.Values.List)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.Values.List))^.ElementCount = 1))
    and ((Nodes.Values.List = 0)
      or (NodePtr(Nodes.Values.List)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.Values.List))^.Nodes.FirstElement = 0)
      or (NodePtr(PList(NodePtr(Nodes.Values.List))^.Nodes.FirstElement)^.NodeType <> ntList)
      or (PList(NodePtr(PList(NodePtr(Nodes.Values.List))^.Nodes.FirstElement))^.ElementCount <= 3))) then
  begin
    Separator := stSpaceBefore;
  end
  else
  begin
    Separator := stReturnBefore;
  end;

  FormatNode(Nodes.InsertTag);
  FormatNode(Nodes.PriorityTag, stSpaceBefore);
  FormatNode(Nodes.IgnoreTag, stSpaceBefore);
  if (Separator = stSpaceBefore) then
  begin
    FormatNode(Nodes.IntoTag, stSpaceBefore);
    FormatNode(Nodes.TableIdent, stSpaceBefore);
    FormatNode(Nodes.Partition.Tag, stSpaceBefore);
    FormatNode(Nodes.Partition.List, stSpaceBefore);
    FormatNode(Nodes.ColumnList, stSpaceBefore);
    FormatNode(Nodes.Values.Tag, stSpaceBefore);
    FormatNode(Nodes.Values.List, stSpaceBefore);
    FormatNode(Nodes.Set_.Tag, stSpaceBefore);
    FormatNode(Nodes.Set_.List, stSpaceBefore);
    if (Nodes.SelectStmt > 0) then
    begin
      Commands.IncreaseIndent();
      FormatNode(Nodes.SelectStmt, stReturnBefore);
      Commands.DecreaseIndent();
      FormatNode(Nodes.OnDuplicateKeyUpdateTag, stReturnBefore);
    end
    else
      FormatNode(Nodes.OnDuplicateKeyUpdateTag, stSpaceBefore);
    FormatNode(Nodes.UpdateList, stSpaceBefore);
  end
  else
  begin
    Commands.IncreaseIndent();
    FormatNode(Nodes.IntoTag, stReturnBefore);
    FormatNode(Nodes.TableIdent, stSpaceBefore);
    FormatNode(Nodes.Partition.Tag, stSpaceBefore);
    FormatNode(Nodes.Partition.List, stSpaceBefore);
    FormatNode(Nodes.ColumnList, stReturnBefore);
    Commands.DecreaseIndent();
    if (Nodes.Values.Tag > 0) then
    begin
      FormatNode(Nodes.Values.Tag, stReturnBefore);
      Commands.WriteReturn();
      Commands.IncreaseIndent();
      FormatList(Nodes.Values.List, sReturn);
      Commands.DecreaseIndent();
    end;
    if (Nodes.Set_.Tag > 0) then
    begin
      FormatNode(Nodes.Set_.Tag, stReturnBefore);
      Commands.WriteReturn();
      Commands.IncreaseIndent();
      FormatList(Nodes.Set_.List, sReturn);
      Commands.DecreaseIndent();
    end;
    if (Nodes.SelectStmt > 0) then
    begin
      Commands.IncreaseIndent();
      FormatNode(Nodes.SelectStmt, stReturnBefore);
      Commands.DecreaseIndent();
      FormatNode(Nodes.OnDuplicateKeyUpdateTag, stReturnBefore);
    end
    else
      FormatNode(Nodes.OnDuplicateKeyUpdateTag, stSpaceBefore);
    FormatNode(Nodes.UpdateList, stSpaceBefore);
  end;
end;

procedure TSQLParser.FormatList(const List: PList; const Spacer: TSpacer);
var
  Child: PChild;
  Delimiter: PToken;
  Indent: Boolean;
begin
  if (List^.Nodes.OpenBracket > 0) then
  begin
    FormatNode(List^.Nodes.OpenBracket);
    if (Spacer = sReturn) then
    begin
      Commands.WriteReturn();
      Commands.IncreaseIndent();
    end;
  end;

  if (not IsChild(List^.Nodes.FirstElement)) then
    Child := nil
  else
    Child := ChildPtr(List^.Nodes.FirstElement);

  Indent := False;
  while (Assigned(Child)) do
  begin
    Delimiter := List^.GetDelimiter(Child);

    if (not Indent) then
    begin
      FormatNode(PNode(Child));
      FormatNode(PNode(Delimiter));
    end
    else
    begin
      Commands.IncreaseIndent();
      Commands.WriteReturn();
      FormatNode(PNode(Child));
      FormatNode(PNode(Delimiter));
      Commands.DecreaseIndent();
    end;

    Child := List^.GetNextElement(Child);

    if (Assigned(Child)) then
      case (Child^.NodeType) of
        ntBinaryOp:
          begin
            Indent := (Child^.ParentNode.NodeType = ntList) and (PList(Child^.ParentNode)^.ElementCount > 3);
            if (not Indent) then
              Commands.WriteSpace();
          end;
        ntSelectStmtTableJoin:
          Indent := True;
        else
          case (Spacer) of
            sSpace:
              Commands.WriteSpace();
            sReturn:
              Commands.WriteReturn();
          end;
      end;
  end;

  if (List^.Nodes.CloseBracket > 0) then
  begin
    if (Spacer = sReturn) then
    begin
      Commands.DecreaseIndent();
      Commands.WriteReturn();
    end;
    FormatNode(List^.Nodes.CloseBracket);
  end;
end;

procedure TSQLParser.FormatList(const Node: TOffset; const Spacer: TSpacer);
begin
  if (Node > 0) then
  begin
    Assert(NodePtr(Node)^.NodeType = ntList);

    FormatList(PList(NodePtr(Node)), Spacer);
  end;
end;

procedure TSQLParser.FormatLoadDataStmt(const Nodes: TLoadDataStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.PriorityTag, stSpaceBefore);
  FormatNode(Nodes.InfileTag, stSpaceBefore);
  FormatNode(Nodes.FilenameString, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.ReplaceIgnoreTag, stReturnBefore);
  FormatNode(Nodes.IntoTableTag, stReturnBefore);
  FormatNode(Nodes.Ident, stSpaceBefore);
  FormatNode(Nodes.PartitionTag, stReturnBefore);
  FormatNode(Nodes.PartitionList, stSpaceBefore);
  FormatNode(Nodes.CharacterSetValue, stReturnBefore);
  if (Nodes.ColumnsTag > 0) then
  begin
    FormatNode(Nodes.ColumnsTag, stReturnBefore);
    Commands.IncreaseIndent();
    FormatNode(Nodes.ColumnsTerminatedByValue, stReturnBefore);
    FormatNode(Nodes.EnclosedByValue, stReturnBefore);
    FormatNode(Nodes.EscapedByValue, stReturnBefore);
    Commands.DecreaseIndent();
  end;
  if (Nodes.Lines.Tag > 0) then
  begin
    FormatNode(Nodes.Lines.Tag, stReturnBefore);
    Commands.IncreaseIndent();
    FormatNode(Nodes.Lines.StartingByValue, stReturnBefore);
    FormatNode(Nodes.Lines.TerminatedByValue, stReturnBefore);
    Commands.DecreaseIndent();
  end;
  FormatNode(Nodes.Ignore.Tag, stReturnBefore);
  FormatNode(Nodes.Ignore.NumberToken, stSpaceBefore);
  FormatNode(Nodes.Ignore.LinesTag, stSpaceBefore);
  FormatNode(Nodes.ColumnList, stReturnBefore);
  FormatNode(Nodes.SetList, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatLoadXMLStmt(const Nodes: TLoadXMLStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.PriorityTag, stSpaceBefore);
  FormatNode(Nodes.InfileTag, stSpaceBefore);
  FormatNode(Nodes.FilenameString, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.ReplaceIgnoreTag, stReturnBefore);
  FormatNode(Nodes.IntoTableValue, stReturnBefore);
  FormatNode(Nodes.CharacterSetValue, stReturnBefore);
  FormatNode(Nodes.RowsIdentifiedByValue, stReturnBefore);
  FormatNode(Nodes.Ignore.Tag, stReturnBefore);
  FormatNode(Nodes.Ignore.NumberToken, stSpaceBefore);
  FormatNode(Nodes.Ignore.LinesTag, stSpaceBefore);
  FormatNode(Nodes.FieldList, stReturnBefore);
  FormatNode(Nodes.SetList, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatLockTablesStmtItem(const Nodes: TLockTablesStmt.TItem.TNodes);
var
  Ident: TOffset;
  AliasIdent: TOffset;
begin
  Ident := Nodes.Ident;
  if ((Ident > 0) and (NodePtr(Ident)^.NodeType = ntDbIdent)) then
    Ident := PDbIdent(NodePtr(Ident))^.Nodes.Ident;
  AliasIdent := Nodes.AliasIdent;
  if ((AliasIdent > 0) and (NodePtr(AliasIdent)^.NodeType = ntDbIdent)) then
    AliasIdent := PDbIdent(NodePtr(AliasIdent))^.Nodes.Ident;

  FormatNode(Nodes.Ident);
  if ((Nodes.AliasIdent > 0)
    and (not IsToken(Ident) or not IsToken(AliasIdent) or (TokenPtr(Ident)^.AsString <> TokenPtr(AliasIdent)^.AsString))) then
  begin
    FormatNode(Nodes.AsTag, stSpaceBefore);
    FormatNode(Nodes.AliasIdent, stSpaceBefore);
  end;
  FormatNode(Nodes.LockTypeTag, stSpaceBefore);
end;

procedure TSQLParser.FormatLoopStmt(const Nodes: TLoopStmt.TNodes);
begin
  FormatNode(Nodes.BeginLabel, stSpaceAfter);
  Commands.IncreaseIndent();
  FormatNode(Nodes.BeginTag);
  FormatNode(Nodes.StmtList, stReturnBefore);
  Commands.DecreaseIndent();
  FormatNode(Nodes.EndTag, stReturnBefore);
  FormatNode(Nodes.EndLabel, stSpaceBefore);
end;

procedure TSQLParser.FormatMatchFunc(const Nodes: TMatchFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.MatchList, stSpaceBefore);
  FormatNode(Nodes.AgainstTag, stSpaceBefore);
  FormatNode(Nodes.OpenBracket, stSpaceBefore);
  FormatNode(Nodes.Expr);
  FormatNode(Nodes.SearchModifierTag, stSpaceBefore);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatNode(const Node: PNode; const Separator: TSeparatorType = stNone);

  procedure DefaultFormatNode(const Nodes: POffsetArray; const Size: Integer);
  var
    Count: Integer;
    FirstNode: Boolean;
    I: Integer;
  begin
    Assert(Size mod SizeOf(TOffset) = 0);

    FirstNode := True; Count := Size div SizeOf(TOffset);
    for I := 0 to Count - 1 do
      if (Nodes^[I] > 0) then
        if (FirstNode) then
        begin
          FormatNode(Nodes^[I]);
          FirstNode := False;
        end
        else
          FormatNode(Nodes^[I], stSpaceBefore);
  end;

begin
  if (Assigned(Node)) then
  begin
    case (Separator) of
      stReturnBefore: Commands.WriteReturn();
      stSpaceBefore: Commands.WriteSpace();
    end;

    CommentsWritten := False;
    case (Node^.NodeType) of
      ntToken: FormatToken(PToken(Node)^);
      ntList:
        case (PList(Node)^.DelimiterType) of
          ttDot: FormatList(PList(Node), sNone);
          ttSemicolon: FormatList(PList(Node), sReturn);
          else FormatList(PList(Node), sSpace);
        end;

      ntAccount: FormatAccount(PAccount(Node)^.Nodes);
      ntAnalyzeTableStmt: DefaultFormatNode(@PAnalyzeTableStmt(Node)^.Nodes, SizeOf(TAnalyzeTableStmt.TNodes));
      ntAlterDatabaseStmt: FormatAlterDatabaseStmt(PAlterDatabaseStmt(Node)^.Nodes);
      ntAlterEventStmt: FormatAlterEventStmt(PAlterEventStmt(Node)^.Nodes);
      ntAlterInstanceStmt: DefaultFormatNode(@PAlterInstanceStmt(Node)^.Nodes, SizeOf(TAlterInstanceStmt.TNodes));
      ntAlterRoutineStmt: FormatAlterRoutineStmt(PAlterRoutineStmt(Node)^.Nodes);
      ntAlterServerStmt: DefaultFormatNode(@PAlterServerStmt(Node)^.Nodes, SizeOf(TAlterServerStmt.TNodes));
      ntAlterTablespaceStmt: FormatAlterTablespaceStmt(PAlterTablespaceStmt(Node)^.Nodes);
      ntAlterTableStmt: FormatAlterTableStmt(PAlterTableStmt(Node)^.Nodes);
      ntAlterTableStmtAddField: DefaultFormatNode(@TAlterTableStmt.PAddField(Node)^.Nodes, SizeOf(TAlterTableStmt.TAddField.TNodes));
      ntAlterTableStmtAddFields: DefaultFormatNode(@TAlterTableStmt.PAddFields(Node)^.Nodes, SizeOf(TAlterTableStmt.TAddFields.TNodes));
      ntAlterTableStmtAlterField: FormatAlterTableStmtAlterField(TAlterTableStmt.PAlterField(Node)^.Nodes);
      ntAlterTableStmtConvertTo: DefaultFormatNode(@TAlterTableStmt.PConvertTo(Node)^.Nodes, SizeOf(TAlterTableStmt.TConvertTo.TNodes));
      ntAlterTableStmtDropObject: DefaultFormatNode(@TAlterTableStmt.PDropObject(Node)^.Nodes, SizeOf(TAlterTableStmt.TDropObject.TNodes));
      ntAlterTableStmtExchangePartition: DefaultFormatNode(@TAlterTableStmt.PExchangePartition(Node)^.Nodes, SizeOf(TAlterTableStmt.TExchangePartition.TNodes));
      ntAlterTableStmtOrderBy: DefaultFormatNode(@TAlterTableStmt.POrderBy(Node)^.Nodes, SizeOf(TAlterTableStmt.TOrderBy.TNodes));
      ntAlterTableStmtReorganizePartition: DefaultFormatNode(@TAlterTableStmt.PReorganizePartition(Node)^.Nodes, SizeOf(TAlterTableStmt.TReorganizePartition.TNodes));
      ntAlterViewStmt: FormatAlterViewStmt(PAlterViewStmt(Node)^.Nodes);
      ntBeginLabel: FormatBeginLabel(PBeginLabel(Node)^.Nodes);
      ntBeginStmt: DefaultFormatNode(@PBeginStmt(Node)^.Nodes, SizeOf(TBeginStmt.TNodes));
      ntBetweenOp: DefaultFormatNode(@PBetweenOp(Node)^.Nodes, SizeOf(TBetweenOp.TNodes));
      ntBinaryOp: DefaultFormatNode(@PBinaryOp(Node)^.Nodes, SizeOf(TBinaryOp.TNodes));
      ntCallStmt: FormatCallStmt(PCallStmt(Node)^.Nodes);
      ntCaseOp: FormatCaseOp(PCaseOp(Node)^.Nodes);
      ntCaseOpBranch: DefaultFormatNode(@TCaseOp.PBranch(Node)^.Nodes, SizeOf(TCaseOp.TBranch.TNodes));
      ntCaseStmt: FormatCaseStmt(PCaseStmt(Node)^.Nodes);
      ntCaseStmtBranch: FormatCaseStmtBranch(TCaseStmt.PBranch(Node)^.Nodes);
      ntCastFunc: FormatCastFunc(PCastFunc(Node)^.Nodes);
      ntChangeMasterStmt: FormatChangeMasterStmt(PChangeMasterStmt(Node)^.Nodes);
      ntCharFunc: FormatCharFunc(PCharFunc(Node)^.Nodes);
      ntCheckTableStmt: DefaultFormatNode(@PCheckTableStmt(Node)^.Nodes, SizeOf(TCheckTableStmt.TNodes));
      ntChecksumTableStmt: DefaultFormatNode(@PChecksumTableStmt(Node)^.Nodes, SizeOf(TChecksumTableStmt.TNodes));
      ntCloseStmt: DefaultFormatNode(@PCloseStmt(Node)^.Nodes, SizeOf(TCloseStmt.TNodes));
      ntCommitStmt: DefaultFormatNode(@PCommitStmt(Node)^.Nodes, SizeOf(TCommitStmt.TNodes));
      ntCompoundStmt: FormatCompoundStmt(PCompoundStmt(Node)^.Nodes);
      ntConvertFunc: FormatConvertFunc(PConvertFunc(Node)^.Nodes);
      ntCountFunc: FormatCountFunc(PCountFunc(Node)^.Nodes);
      ntCreateDatabaseStmt: DefaultFormatNode(@PCreateDatabaseStmt(Node)^.Nodes, SizeOf(TCreateDatabaseStmt.TNodes));
      ntCreateEventStmt: FormatCreateEventStmt(PCreateEventStmt(Node)^.Nodes);
      ntCreateIndexStmt: FormatCreateIndexStmt(PCreateIndexStmt(Node)^.Nodes);
      ntCreateRoutineStmt: FormatCreateRoutineStmt(PCreateRoutineStmt(Node)^.Nodes);
      ntCreateServerStmt: FormatCreateServerStmt(PCreateServerStmt(Node)^.Nodes);
      ntCreateTablespaceStmt: FormatCreateTablespaceStmt(PCreateTablespaceStmt(Node)^.Nodes);
      ntCreateTableStmt: FormatCreateTableStmt(PCreateTableStmt(Node)^.Nodes);
      ntCreateTableStmtField: FormatCreateTableStmtField(TCreateTableStmt.PField(Node)^.Nodes);
      ntCreateTableStmtFieldOnUpdate: DefaultFormatNode(@TCreateTableStmt.TField.POnUpdate(Node)^.Nodes, SizeOf(TCreateTableStmt.TField.TOnUpdate.TNodes));
      ntCreateTableStmtForeignKey: DefaultFormatNode(@TCreateTableStmt.PForeignKey(Node)^.Nodes, SizeOf(TCreateTableStmt.TForeignKey.TNodes));
      ntCreateTableStmtKey: FormatCreateTableStmtKey(TCreateTableStmt.PKey(Node)^.Nodes);
      ntCreateTableStmtKeyColumn: FormatCreateTableStmtKeyColumn(TCreateTableStmt.PKeyColumn(Node)^.Nodes);
      ntCreateTableStmtPartition: DefaultFormatNode(@TCreateTableStmt.PPartition(Node)^.Nodes, SizeOf(TCreateTableStmt.TPartition.TNodes));
      ntCreateTableStmtPartitionOptions: FormatCreateTableStmtPartitionOptions(TCreateTableStmt.PPartitionOptions(Node)^.Nodes);
      ntCreateTableStmtReference: FormatCreateTableStmtReference(TCreateTableStmt.PReference(Node)^.Nodes);
      ntCreateTriggerStmt: FormatCreateTriggerStmt(PCreateTriggerStmt(Node)^.Nodes);
      ntCreateUserStmt: FormatCreateUserStmt(PCreateUserStmt(Node)^.Nodes);
      ntCreateViewStmt: FormatCreateViewStmt(PCreateViewStmt(Node)^.Nodes);
      ntDatatype: FormatDatatype(PDatatype(Node)^.Nodes);
      ntDateAddFunc: FormatDateAddFunc(PDateAddFunc(Node)^.Nodes);
      ntDbIdent: FormatDbIdent(PDbIdent(Node)^.Nodes);
      ntDeallocatePrepareStmt: DefaultFormatNode(@PDeallocatePrepareStmt(Node)^.Nodes, SizeOf(TDeallocatePrepareStmt.TNodes));
      ntDeclareStmt: DefaultFormatNode(@PDeclareStmt(Node)^.Nodes, SizeOf(TDeclareStmt.TNodes));
      ntDeclareConditionStmt: DefaultFormatNode(@PDeclareConditionStmt(Node)^.Nodes, SizeOf(TDeclareConditionStmt.TNodes));
      ntDeclareCursorStmt: FormatDeclareCursorStmt(PDeclareCursorStmt(Node)^.Nodes);
      ntDeclareHandlerStmt: FormatDeclareHandlerStmt(PDeclareHandlerStmt(Node)^.Nodes);
      ntDeleteStmt: FormatDeleteStmt(PDeleteStmt(Node)^.Nodes);
      ntDoStmt: DefaultFormatNode(@PDoStmt(Node)^.Nodes, SizeOf(TDoStmt.TNodes));
      ntDropDatabaseStmt: DefaultFormatNode(@PDropDatabaseStmt(Node)^.Nodes, SizeOf(TDropDatabaseStmt.TNodes));
      ntDropEventStmt: DefaultFormatNode(@PDropEventStmt(Node)^.Nodes, SizeOf(TDropEventStmt.TNodes));
      ntDropIndexStmt: DefaultFormatNode(@PDropIndexStmt(Node)^.Nodes, SizeOf(TDropIndexStmt.TNodes));
      ntDropRoutineStmt: DefaultFormatNode(@PDropRoutineStmt(Node)^.Nodes, SizeOf(TDropRoutineStmt.TNodes));
      ntDropServerStmt: DefaultFormatNode(@PDropServerStmt(Node)^.Nodes, SizeOf(TDropServerStmt.TNodes));
      ntDropTablespaceStmt: FormatDropTablespaceStmt(PDropTablespaceStmt(Node)^.Nodes);
      ntDropTableStmt: DefaultFormatNode(@PDropTableStmt(Node)^.Nodes, SizeOf(TDropTableStmt.TNodes));
      ntDropTriggerStmt: DefaultFormatNode(@PDropTriggerStmt(Node)^.Nodes, SizeOf(TDropTriggerStmt.TNodes));
      ntDropUserStmt: DefaultFormatNode(@PDropUserStmt(Node)^.Nodes, SizeOf(TDropUserStmt.TNodes));
      ntDropViewStmt: DefaultFormatNode(@PDropViewStmt(Node)^.Nodes, SizeOf(TDropViewStmt.TNodes));
      ntEndLabel: DefaultFormatNode(@PEndLabel(Node)^.Nodes, SizeOf(TEndLabel.TNodes));
      ntExecuteStmt: DefaultFormatNode(@PExecuteStmt(Node)^.Nodes, SizeOf(TExecuteStmt.TNodes));
      ntExplainStmt: DefaultFormatNode(@PExplainStmt(Node)^.Nodes, SizeOf(TExplainStmt.TNodes));
      ntExtractFunc: FormatExtractFunc(PExtractFunc(Node)^.Nodes);
      ntFetchStmt: FormatFetchStmt(PFetchStmt(Node)^.Nodes);
      ntFlushStmt: DefaultFormatNode(@PFlushStmt(Node)^.Nodes, SizeOf(TFlushStmt.TNodes));
      ntFlushStmtOption: DefaultFormatNode(@TFlushStmt.POption(Node)^.Nodes, SizeOf(TFlushStmt.TOption.TNodes));
      ntFlushStmtOptionLogs: DefaultFormatNode(@TFlushStmt.TOption.PLogs(Node)^.Nodes, SizeOf(TFlushStmt.TOption.TLogs.TNodes));
      ntDefaultFunc: FormatDefaultFunc(PDefaultFunc(Node)^.Nodes);
      ntFunctionReturns: DefaultFormatNode(@PFunctionReturns(Node)^.Nodes, SizeOf(TFunctionReturns.TNodes));
      ntGetDiagnosticsStmt: DefaultFormatNode(@PGetDiagnosticsStmt(Node)^.Nodes, SizeOf(TGetDiagnosticsStmt.TNodes));
      ntGetDiagnosticsStmtStmtInfo: DefaultFormatNode(@TGetDiagnosticsStmt.PStmtInfo(Node)^.Nodes, SizeOf(TGetDiagnosticsStmt.TStmtInfo.TNodes));
      ntGetDiagnosticsStmtCondInfo: DefaultFormatNode(@TGetDiagnosticsStmt.PCondInfo(Node)^.Nodes, SizeOf(TGetDiagnosticsStmt.TCondInfo.TNodes));
      ntGrantStmt: DefaultFormatNode(@PGrantStmt(Node)^.Nodes, SizeOf(TGrantStmt.TNodes));
      ntGrantStmtPrivileg: DefaultFormatNode(@TGrantStmt.PPrivileg(Node)^.Nodes, SizeOf(TGrantStmt.TPrivileg.TNodes));
      ntGrantStmtUserSpecification: DefaultFormatNode(@TGrantStmt.PUserSpecification(Node)^.Nodes, SizeOf(TGrantStmt.TUserSpecification.TNodes));
      ntGroupConcatFunc: FormatGroupConcatFunc(PGroupConcatFunc(Node)^.Nodes);
      ntGroupConcatFuncExpr: DefaultFormatNode(@TGroupConcatFunc.PExpr(Node)^.Nodes, SizeOf(TGroupConcatFunc.TExpr.TNodes));
      ntHelpStmt: DefaultFormatNode(@PHelpStmt(Node)^.Nodes, SizeOf(THelpStmt.TNodes));
      ntIfStmt: FormatIfStmt(PIfStmt(Node)^.Nodes);
      ntIfStmtBranch: FormatIfStmtBranch(TIfStmt.PBranch(Node)^.Nodes);
      ntInOp: DefaultFormatNode(@PInOp(Node)^.Nodes, SizeOf(TInOp.TNodes));
      ntInsertStmt: FormatInsertStmt(PInsertStmt(Node)^.Nodes);
      ntInsertStmtSetItem: DefaultFormatNode(@TInsertStmt.PSetItem(Node)^.Nodes, SizeOf(TInsertStmt.TSetItem.TNodes));
      ntInstallPluginStmt: DefaultFormatNode(@PInstallPluginStmt(Node)^.Nodes, SizeOf(TInstallPluginStmt.TNodes));
      ntIntervalOp: DefaultFormatNode(@PIntervalOp(Node)^.Nodes, SizeOf(TIntervalOp.TNodes));
      ntIsOp: DefaultFormatNode(@PIsOp(Node)^.Nodes, SizeOf(TIsOp.TNodes));
      ntIterateStmt: DefaultFormatNode(@PIterateStmt(Node)^.Nodes, SizeOf(TIterateStmt.TNodes));
      ntKillStmt: DefaultFormatNode(@PKillStmt(Node)^.Nodes, SizeOf(TKillStmt.TNodes));
      ntLeaveStmt: DefaultFormatNode(@PLeaveStmt(Node)^.Nodes, SizeOf(TLeaveStmt.TNodes));
      ntLikeOp: DefaultFormatNode(@PLikeOp(Node)^.Nodes, SizeOf(TLikeOp.TNodes));
      ntLoadDataStmt: FormatLoadDataStmt(PLoadDataStmt(Node)^.Nodes);
      ntLoadXMLStmt: FormatLoadXMLStmt(PLoadXMLStmt(Node)^.Nodes);
      ntLockTablesStmt: DefaultFormatNode(@PLockTablesStmt(Node)^.Nodes, SizeOf(TLockTablesStmt.TNodes));
      ntLockTablesStmtItem: FormatLockTablesStmtItem(TLockTablesStmt.PItem(Node)^.Nodes);
      ntLoopStmt: FormatLoopStmt(PLoopStmt(Node)^.Nodes);
      ntMatchFunc: FormatMatchFunc(PMatchFunc(Node)^.Nodes);
      ntPositionFunc: FormatPositionFunc(PPositionFunc(Node)^.Nodes);
      ntPrepareStmt: DefaultFormatNode(@PPrepareStmt(Node)^.Nodes, SizeOf(TPrepareStmt.TNodes));
      ntPurgeStmt: DefaultFormatNode(@PPurgeStmt(Node)^.Nodes, SizeOf(TPurgeStmt.TNodes));
      ntOpenStmt: DefaultFormatNode(@POpenStmt(Node)^.Nodes, SizeOf(TOpenStmt.TNodes));
      ntOptimizeTableStmt: DefaultFormatNode(@POptimizeTableStmt(Node)^.Nodes, SizeOf(TOptimizeTableStmt.TNodes));
      ntRegExpOp: DefaultFormatNode(@PRegExpOp(Node)^.Nodes, SizeOf(TRegExpOp.TNodes));
      ntRenameStmt: DefaultFormatNode(@PRenameStmt(Node)^.Nodes, SizeOf(TRenameStmt.TNodes));
      ntRenameStmtPair: DefaultFormatNode(@TRenameStmt.PPair(Node)^.Nodes, SizeOf(TRenameStmt.TPair.TNodes));
      ntReleaseStmt: DefaultFormatNode(@PReleaseStmt(Node)^.Nodes, SizeOf(TReleaseStmt.TNodes));
      ntRepairTableStmt: DefaultFormatNode(@PRepairTableStmt(Node)^.Nodes, SizeOf(TRepairTableStmt.TNodes));
      ntRepeatStmt: FormatRepeatStmt(PRepeatStmt(Node)^.Nodes);
      ntResetStmt: DefaultFormatNode(@PResetStmt(Node)^.Nodes, SizeOf(TResetStmt.TNodes));
      ntReturnStmt: DefaultFormatNode(@PReturnStmt(Node)^.Nodes, SizeOf(TReturnStmt.TNodes));
      ntRevokeStmt: FormatRevokeStmt(PRevokeStmt(Node)^.Nodes);
      ntRollbackStmt: DefaultFormatNode(@PRollbackStmt(Node)^.Nodes, SizeOf(TRollbackStmt.TNodes));
      ntRoutineParam: DefaultFormatNode(@PRoutineParam(Node)^.Nodes, SizeOf(TRoutineParam.TNodes));
      ntSavepointStmt: DefaultFormatNode(@PSavepointStmt(Node)^.Nodes, SizeOf(TSavepointStmt.TNodes));
      ntSchedule: FormatSchedule(PSchedule(Node)^.Nodes);
      ntSecretIdent: FormatSecretIdent(PSecretIdent(Node)^.Nodes);
      ntSelectStmt: FormatSelectStmt(PSelectStmt(Node)^.Nodes);
      ntSelectStmtColumn: FormatSelectStmtColumn(TSelectStmt.PColumn(Node)^.Nodes);
      ntSelectStmtGroup: DefaultFormatNode(@TSelectStmt.PGroup(Node)^.Nodes, SizeOf(TSelectStmt.TGroup.TNodes));
      ntSelectStmtLimit: DefaultFormatNode(@TSelectStmt.PLimit(Node)^.Nodes, SizeOf(TSelectStmt.TLimit.TNodes));
      ntSelectStmtOrder: DefaultFormatNode(@TSelectStmt.POrder(Node)^.Nodes, SizeOf(TSelectStmt.TOrder.TNodes));
      ntSelectStmtOrderBy: DefaultFormatNode(@TSelectStmt.POrderBy(Node)^.Nodes, SizeOf(TSelectStmt.TOrderBy.TNodes));
      ntSelectStmtTableFactor: FormatSelectStmtTableFactor(TSelectStmt.PTableFactor(Node)^.Nodes);
      ntSelectStmtTableFactorIndexHint: DefaultFormatNode(@TSelectStmt.TTableFactor.PIndexHint(Node)^.Nodes, SizeOf(TSelectStmt.TTableFactor.TIndexHint.TNodes));
      ntSelectStmtTableFactorOj: FormatSelectStmtTableFactorOj(TSelectStmt.PTableFactorOj(Node)^.Nodes);
      ntSelectStmtTableFactorSubquery: FormatSelectStmtTableFactorSubquery(TSelectStmt.PTableFactorSubquery(Node)^.Nodes);
      ntSelectStmtTableJoin: FormatSelectStmtTableJoin(TSelectStmt.PTableJoin(Node)^.Nodes);
      ntSetNamesStmt: DefaultFormatNode(@PSetNamesStmt(Node)^.Nodes, SizeOf(TSetNamesStmt.TNodes));
      ntSetPasswordStmt: DefaultFormatNode(@PSetPasswordStmt(Node)^.Nodes, SizeOf(TSetPasswordStmt.TNodes));
      ntSetStmt: FormatSetStmt(PSetStmt(Node)^.Nodes);
      ntSetStmtAssignment: DefaultFormatNode(@TSetStmt.PAssignment(Node)^.Nodes, SizeOf(TSetStmt.TAssignment.TNodes));
      ntSetTransactionStmt: DefaultFormatNode(@PSetTransactionStmt(Node)^.Nodes, SizeOf(TSetTransactionStmt.TNodes));
      ntSetTransactionStmtCharacteristic: DefaultFormatNode(@TSetTransactionStmt.PCharacteristic(Node)^.Nodes, SizeOf(TSetTransactionStmt.TCharacteristic.TNodes));
      ntShowBinaryLogsStmt: DefaultFormatNode(@PShowBinaryLogsStmt(Node)^.Nodes, SizeOf(TShowBinaryLogsStmt.TNodes));
      ntShowBinlogEventsStmt: FormatShowBinlogEventsStmt(PShowBinlogEventsStmt(Node)^.Nodes);
      ntShowCharacterSetStmt: DefaultFormatNode(@PShowCharacterSetStmt(Node)^.Nodes, SizeOf(TShowCharacterSetStmt.TNodes));
      ntShowCollationStmt: DefaultFormatNode(@PShowCollationStmt(Node)^.Nodes, SizeOf(TShowCollationStmt.TNodes));
      ntShowColumnsStmt: DefaultFormatNode(@PShowColumnsStmt(Node)^.Nodes, SizeOf(TShowColumnsStmt.TNodes));
      ntShowCountStmt: DefaultFormatNode(@PShowCountStmt(Node)^.Nodes, SizeOf(TShowCountStmt.TNodes));
      ntShowCreateDatabaseStmt: DefaultFormatNode(@PShowCreateDatabaseStmt(Node)^.Nodes, SizeOf(TShowCreateDatabaseStmt.TNodes));
      ntShowCreateEventStmt: DefaultFormatNode(@PShowCreateEventStmt(Node)^.Nodes, SizeOf(TShowCreateEventStmt.TNodes));
      ntShowCreateFunctionStmt: DefaultFormatNode(@PShowCreateFunctionStmt(Node)^.Nodes, SizeOf(TShowCreateFunctionStmt.TNodes));
      ntShowCreateProcedureStmt: DefaultFormatNode(@PShowCreateProcedureStmt(Node)^.Nodes, SizeOf(TShowCreateProcedureStmt.TNodes));
      ntShowCreateTableStmt: DefaultFormatNode(@PShowCreateTableStmt(Node)^.Nodes, SizeOf(TShowCreateTableStmt.TNodes));
      ntShowCreateTriggerStmt: DefaultFormatNode(@PShowCreateTriggerStmt(Node)^.Nodes, SizeOf(TShowCreateTriggerStmt.TNodes));
      ntShowCreateUserStmt: DefaultFormatNode(@PShowCreateUserStmt(Node)^.Nodes, SizeOf(TShowCreateUserStmt.TNodes));
      ntShowCreateViewStmt: DefaultFormatNode(@PShowCreateViewStmt(Node)^.Nodes, SizeOf(TShowCreateViewStmt.TNodes));
      ntShowDatabasesStmt: DefaultFormatNode(@PShowDatabasesStmt(Node)^.Nodes, SizeOf(TShowDatabasesStmt.TNodes));
      ntShowEngineStmt: DefaultFormatNode(@PShowEngineStmt(Node)^.Nodes, SizeOf(TShowEngineStmt.TNodes));
      ntShowEnginesStmt: DefaultFormatNode(@PShowEnginesStmt(Node)^.Nodes, SizeOf(TShowEnginesStmt.TNodes));
      ntShowErrorsStmt: FormatShowErrorsStmt(PShowErrorsStmt(Node)^.Nodes);
      ntShowEventsStmt: DefaultFormatNode(@PShowEventsStmt(Node)^.Nodes, SizeOf(TShowEventsStmt.TNodes));
      ntShowFunctionStatusStmt: DefaultFormatNode(@PShowFunctionStatusStmt(Node)^.Nodes, SizeOf(TShowFunctionStatusStmt.TNodes));
      ntShowGrantsStmt: DefaultFormatNode(@PShowGrantsStmt(Node)^.Nodes, SizeOf(TShowGrantsStmt.TNodes));
      ntShowIndexStmt: DefaultFormatNode(@PShowIndexStmt(Node)^.Nodes, SizeOf(TShowIndexStmt.TNodes));
      ntShowMasterStatusStmt: DefaultFormatNode(@PShowMasterStatusStmt(Node)^.Nodes, SizeOf(TShowMasterStatusStmt.TNodes));
      ntShowOpenTablesStmt: DefaultFormatNode(@PShowOpenTablesStmt(Node)^.Nodes, SizeOf(TShowOpenTablesStmt.TNodes));
      ntShowPluginsStmt: DefaultFormatNode(@PShowPluginsStmt(Node)^.Nodes, SizeOf(TShowPluginsStmt.TNodes));
      ntShowPrivilegesStmt: DefaultFormatNode(@PShowPrivilegesStmt(Node)^.Nodes, SizeOf(TShowPrivilegesStmt.TNodes));
      ntShowProcedureStatusStmt: DefaultFormatNode(@PShowProcedureStatusStmt(Node)^.Nodes, SizeOf(TShowProcedureStatusStmt.TNodes));
      ntShowProcessListStmt: DefaultFormatNode(@PShowProcessListStmt(Node)^.Nodes, SizeOf(TShowProcessListStmt.TNodes));
      ntShowProfileStmt: DefaultFormatNode(@PShowProfileStmt(Node)^.Nodes, SizeOf(TShowProfileStmt.TNodes));
      ntShowProfilesStmt: DefaultFormatNode(@PShowProfilesStmt(Node)^.Nodes, SizeOf(TShowProfilesStmt.TNodes));
      ntShowRelaylogEventsStmt: FormatShowRelaylogEventsStmt(PShowBinlogEventsStmt(Node)^.Nodes);
      ntShowRoutineCodeStmt: DefaultFormatNode(@PShowRoutineCodeStmt(Node)^.Nodes, SizeOf(TShowRoutineCodeStmt.TNodes));
      ntShowSlaveHostsStmt: DefaultFormatNode(@PShowSlaveHostsStmt(Node)^.Nodes, SizeOf(TShowSlaveHostsStmt.TNodes));
      ntShowSlaveStatusStmt: DefaultFormatNode(@PShowSlaveStatusStmt(Node)^.Nodes, SizeOf(TShowSlaveStatusStmt.TNodes));
      ntShowStatusStmt: DefaultFormatNode(@PShowStatusStmt(Node)^.Nodes, SizeOf(TShowStatusStmt.TNodes));
      ntShowTableStatusStmt: DefaultFormatNode(@PShowTableStatusStmt(Node)^.Nodes, SizeOf(TShowTableStatusStmt.TNodes));
      ntShowTablesStmt: DefaultFormatNode(@PShowTablesStmt(Node)^.Nodes, SizeOf(TShowTablesStmt.TNodes));
      ntShowTriggersStmt: DefaultFormatNode(@PShowTriggersStmt(Node)^.Nodes, SizeOf(TShowTriggersStmt.TNodes));
      ntShowVariablesStmt: DefaultFormatNode(@PShowVariablesStmt(Node)^.Nodes, SizeOf(TShowVariablesStmt.TNodes));
      ntShowWarningsStmt: FormatShowWarningsStmt(PShowWarningsStmt(Node)^.Nodes);
      ntShutdownStmt: DefaultFormatNode(@PShutdownStmt(Node)^.Nodes, SizeOf(TShutdownStmt.TNodes));
      ntSignalStmt: DefaultFormatNode(@PSignalStmt(Node)^.Nodes, SizeOf(TSignalStmt.TNodes));
      ntSignalStmtInformation: DefaultFormatNode(@TSignalStmt.PInformation(Node)^.Nodes, SizeOf(TSignalStmt.TInformation.TNodes));
      ntSoundsLikeOp: DefaultFormatNode(@PSoundsLikeOp(Node)^.Nodes, SizeOf(TSoundsLikeOp.TNodes));
      ntStartSlaveStmt: DefaultFormatNode(@PStartSlaveStmt(Node)^.Nodes, SizeOf(TSignalStmt.TNodes));
      ntStartTransactionStmt: DefaultFormatNode(@PStartTransactionStmt(Node)^.Nodes, SizeOf(TStartTransactionStmt.TNodes));
      ntStopSlaveStmt: DefaultFormatNode(@PStopSlaveStmt(Node)^.Nodes, SizeOf(TSignalStmt.TNodes));
      ntSubArea: FormatSubArea(PSubArea(Node)^.Nodes);
      ntSubPartition: FormatSubPartition(PSubPartition(Node)^.Nodes);
      ntSubquery: FormatSubquery(PSubquery(Node)^.Nodes);
      ntSubstringFunc: FormatSubstringFunc(PSubstringFunc(Node)^.Nodes);
      ntSumFunc: FormatSumFunc(PSumFunc(Node)^.Nodes);
      ntTag: DefaultFormatNode(@PTag(Node)^.Nodes, SizeOf(TTag.TNodes));
      ntTimestampAddFunc: FormatTimestampAddFunc(PTimestampAddFunc(Node)^.Nodes);
      ntTimestampDiffFunc: FormatTimestampDiffFunc(PTimestampDiffFunc(Node)^.Nodes);
      ntTrimFunc: FormatTrimFunc(PTrimFunc(Node)^.Nodes);
      ntTruncateStmt: FormatTruncateStmt(PTruncateStmt(Node)^.Nodes);
      ntUnaryOp: FormatUnaryOp(PUnaryOp(Node)^.Nodes);
      ntUninstallPluginStmt: DefaultFormatNode(@PUninstallPluginStmt(Node)^.Nodes, SizeOf(TUninstallPluginStmt.TNodes));
      ntUnlockTablesStmt: DefaultFormatNode(@PUnlockTablesStmt(Node)^.Nodes, SizeOf(TUnlockTablesStmt.TNodes));
      ntUpdateStmt: FormatUpdateStmt(PUpdateStmt(Node)^.Nodes);
      ntUnknownStmt: FormatUnknownStmt(PUnknownStmt(Node));
      ntUseStmt: DefaultFormatNode(@PUseStmt(Node)^.Nodes, SizeOf(TUseStmt.TNodes));
      ntValue: DefaultFormatNode(@PValue(Node)^.Nodes, SizeOf(TValue.TNodes));
      ntVariableIdent: FormatVariableIdent(PVariable(Node)^.Nodes);
      ntWeightStringFunc: FormatWeightStringFunc(PWeightStringFunc(Node)^.Nodes);
      ntWeightStringFuncLevel: DefaultFormatNode(@TWeightStringFunc.PLevel(Node)^.Nodes, SizeOf(TWeightStringFunc.TLevel.TNodes));
      ntWhileStmt: FormatWhileStmt(PWhileStmt(Node)^.Nodes);
      ntXAStmt: DefaultFormatNode(@PXAStmt(Node)^.Nodes, SizeOf(TXAStmt.TNodes));
      ntXAStmtID: FormatXID(TXAStmt.PID(Node)^.Nodes);
      else raise ERangeError.Create(SRangeError);
    end;

    if (not CommentsWritten) then
      case (Separator) of
        stReturnAfter: Commands.WriteReturn();
        stSpaceAfter: Commands.WriteSpace();
      end;
  end;
end;

procedure TSQLParser.FormatNode(const Node: TOffset; const Separator: TSeparatorType = stNone);
begin
  if (Node > 0) then
    FormatNode(NodePtr(Node), Separator);
end;

procedure TSQLParser.FormatPositionFunc(const Nodes: TPositionFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.SubStr);
  FormatNode(Nodes.InTag, stSpaceBefore);
  FormatNode(Nodes.Str, stSpaceBefore);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatRepeatStmt(const Nodes: TRepeatStmt.TNodes);
begin
  FormatNode(Nodes.BeginLabel, stSpaceAfter);
  FormatNode(Nodes.RepeatTag);
  Commands.IncreaseIndent();
  FormatNode(Nodes.StmtList, stReturnBefore);
  Commands.DecreaseIndent();
  FormatNode(Nodes.UntilTag, stReturnBefore);
  FormatNode(Nodes.SearchConditionExpr, stSpaceBefore);
  FormatNode(Nodes.EndTag, stSpaceBefore);
  FormatNode(Nodes.EndLabel, stSpaceBefore);
end;

procedure TSQLParser.FormatRevokeStmt(const Nodes: TRevokeStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  if (Nodes.PrivLevelIdent > 0) then
  begin
    FormatNode(Nodes.PrivilegesList, stSpaceBefore);
    FormatNode(Nodes.OnTag, stSpaceBefore);
    FormatNode(Nodes.ObjectTypeTag, stSpaceBefore);
    FormatNode(Nodes.PrivLevelIdent, stSpaceBefore);
    FormatNode(Nodes.FromTag, stSpaceBefore);
    FormatNode(Nodes.UserIdentList, stSpaceBefore);
  end
  else if (Nodes.CommaToken > 0) then
  begin
    FormatNode(Nodes.PrivilegesList, stSpaceBefore);
    FormatNode(Nodes.CommaToken);
    FormatNode(Nodes.GrantOptionTag, stSpaceBefore);
    FormatNode(Nodes.FromTag, stSpaceBefore);
    FormatNode(Nodes.UserIdentList, stSpaceBefore);
  end
  else
  begin
    FormatNode(Nodes.PrivilegesList, stSpaceBefore);
    FormatNode(Nodes.OnTag, stSpaceBefore);
    FormatNode(Nodes.AccountIdent, stSpaceBefore);
    FormatNode(Nodes.FromTag, stSpaceBefore);
    FormatNode(Nodes.UserIdentList, stSpaceBefore);
  end;
end;

procedure TSQLParser.FormatRoot(const Node: PRoot);
begin
  FormatComments(Node^.FirstTokenAll, True);
  FormatList(Node^.Nodes.StmtList, sReturn);
end;

procedure TSQLParser.FormatSchedule(const Nodes: TSchedule.TNodes);
begin
  if (Nodes.AtValue > 0) then
    FormatNode(Nodes.AtValue)
  else
  begin
    FormatNode(Nodes.EveryTag);
    FormatNode(Nodes.QuantityExpr, stSpaceBefore);
    FormatNode(Nodes.UnitTag, stSpaceBefore);

    if (Nodes.StartsValue > 0) then
    begin
      Commands.IncreaseIndent();
      FormatNode(Nodes.StartsValue, stReturnBefore);
      Commands.DecreaseIndent();
    end;

    if (Nodes.EndsValue > 0) then
    begin
      Commands.IncreaseIndent();
      FormatNode(Nodes.EndsValue, stReturnBefore);
      Commands.DecreaseIndent();
    end;
  end;
end;

procedure TSQLParser.FormatSecretIdent(const Nodes: TSecretIdent.TNodes);
begin
  FormatNode(Nodes.OpenAngleBracket);
  FormatNode(Nodes.ItemToken);
  FormatNode(Nodes.CloseAngleBracket);
end;

procedure TSQLParser.FormatSelectStmt(const Nodes: TSelectStmt.TNodes);
var
  ItemPerLine: Boolean;
  Separator: TSeparatorType;
  Spacer: TSpacer;

  procedure FormatInto(const Nodes: TSelectStmt.TIntoNodes);
  begin
    Assert((Nodes.Tag = 0) or (NodePtr(Nodes.Tag)^.NodeType = ntTag));

    if ((Nodes.Tag > 0) and (NodePtr(Nodes.Tag)^.NodeType = ntTag)) then
      if (PTag(NodePtr(Nodes.Tag))^.Nodes.Keyword2Token = kiOUTFILE) then
      begin
        FormatNode(Nodes.Tag, Separator);
        Commands.IncreaseIndent();
        if (Separator = stReturnBefore) then
          Commands.WriteReturn();
        FormatNode(Nodes.CharacterSetValue, stSpaceBefore);
        FormatNode(Nodes.Fields.Tag, stReturnBefore);
        FormatNode(Nodes.Fields.TerminatedByString, stSpaceBefore);
        FormatNode(Nodes.Fields.EnclosedByString, stSpaceBefore);
        FormatNode(Nodes.Fields.Tag, stSpaceBefore);
        FormatNode(Nodes.Lines.Tag, stReturnBefore);
        FormatNode(Nodes.Lines.StartingByString, stSpaceBefore);
        FormatNode(Nodes.Lines.TerminatedByString, stSpaceBefore);
        Commands.DecreaseIndent();
      end
      else if (PTag(NodePtr(Nodes.Tag))^.Nodes.Keyword2Token = kiDUMPFILE) then
      begin
        FormatNode(Nodes.Tag, Separator);
        if (Separator = stReturnBefore) then
          Commands.WriteReturn();
        Commands.IncreaseIndent();
        FormatNode(Nodes.Filename, stSpaceBefore);
        Commands.DecreaseIndent();
      end
      else
      begin
        FormatNode(Nodes.Tag, Separator);
        Commands.IncreaseIndent();
        if (not ItemPerLine) then
          FormatNode(Nodes.VariableList, Separator)
        else
        begin
          if (Separator = stReturnBefore) then
            Commands.WriteReturn();
          FormatList(Nodes.VariableList, Spacer);
        end;
        Commands.DecreaseIndent();
      end;
  end;

var
  ElementCount: Integer;
begin
  ElementCount := 1; // SELECT
  if (Nodes.From.Tag > 0) then Inc(ElementCount);
  if (Nodes.Into1.Tag > 0) then Inc(ElementCount);
  if (Nodes.Partition.Tag > 0) then Inc(ElementCount);
  if (Nodes.Where.Tag > 0) then Inc(ElementCount);
  if (Nodes.GroupBy.Tag > 0) then Inc(ElementCount);
  if (Nodes.Having.Tag > 0) then Inc(ElementCount);
  if (Nodes.OrderBy > 0) then Inc(ElementCount);
  if (Nodes.Limit > 0) then Inc(ElementCount);

  ItemPerLine := (Nodes.ColumnsList > 0)
    and (NodePtr(Nodes.ColumnsList)^.NodeType = ntList)
    and (PList(NodePtr(Nodes.ColumnsList))^.ElementCount >= 5);

  if (((Nodes.ColumnsList = 0)
      or (NodePtr(Nodes.ColumnsList)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.ColumnsList))^.ElementCount = 1))
    and ((Nodes.From.TableReferenceList = 0)
      or (NodePtr(Nodes.From.TableReferenceList)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.From.TableReferenceList))^.ElementCount = 1))
    and ((Nodes.From.TableReferenceList = 0)
      or (NodePtr(Nodes.From.TableReferenceList)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.From.TableReferenceList))^.Nodes.FirstElement = 0)
      or (NodePtr(PList(NodePtr(Nodes.From.TableReferenceList))^.Nodes.FirstElement)^.NodeType <> ntList)
      or (PList(NodePtr(PList(NodePtr(Nodes.From.TableReferenceList))^.Nodes.FirstElement))^.ElementCount = 1))
    and ((Nodes.Where.Expr = 0)
      or (NodePtr(Nodes.Where.Expr)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.Where.Expr))^.ElementCount <= 3))
    and (ElementCount <= 4)) then
  begin
    Separator := stSpaceBefore;
    Spacer := sSpace;
  end
  else
  begin
    Separator := stReturnBefore;
    Spacer := sReturn;
  end;

  FormatList(Nodes.OpenBrackets, sNone);
  FormatNode(Nodes.SelectTag);
  Commands.IncreaseIndent();
  FormatNode(Nodes.DistinctTag, stSpaceBefore);
  FormatNode(Nodes.HighPriorityTag, stSpaceBefore);
  FormatNode(Nodes.MaxStatementTime, stSpaceBefore);
  FormatNode(Nodes.StraightJoinTag, stSpaceBefore);
  FormatNode(Nodes.SQLSmallResultTag, stSpaceBefore);
  FormatNode(Nodes.SQLBigResultTag, stSpaceBefore);
  FormatNode(Nodes.SQLBufferResultTag, stSpaceBefore);
  FormatNode(Nodes.SQLNoCacheTag, stSpaceBefore);
  FormatNode(Nodes.SQLCalcFoundRowsTag, stSpaceBefore);
  if (not ItemPerLine) then
    FormatNode(Nodes.ColumnsList, Separator)
  else
  begin
    if (Separator = stSpaceBefore) then
      Commands.WriteSpace()
    else
      Commands.WriteReturn();
    FormatList(Nodes.ColumnsList, Spacer);
  end;
  Commands.DecreaseIndent();
  FormatInto(Nodes.Into1);
  if (Nodes.From.Tag > 0) then
  begin
    FormatNode(Nodes.From.Tag, Separator);
    Commands.IncreaseIndent();
    if (Separator = stSpaceBefore) then
      Commands.WriteSpace()
    else
      Commands.WriteReturn();
    FormatList(Nodes.From.TableReferenceList, Spacer);
    Commands.DecreaseIndent();
  end;
  if (Nodes.Partition.Tag > 0) then
  begin
    FormatNode(Nodes.Partition.Tag, Separator);
    Commands.IncreaseIndent();
    FormatNode(Nodes.Partition.Tag, Separator);
    Commands.DecreaseIndent();
  end;
  if (Nodes.Where.Tag > 0) then
  begin
    FormatNode(Nodes.Where.Tag, Separator);
    Commands.IncreaseIndent();
    FormatNode(Nodes.Where.Expr, Separator);
    Commands.DecreaseIndent();
  end;
  if (Nodes.GroupBy.Tag > 0) then
  begin
    FormatNode(Nodes.GroupBy.Tag, Separator);
    Commands.IncreaseIndent();
    FormatNode(Nodes.GroupBy.List, Separator);
    Commands.DecreaseIndent();
    FormatNode(Nodes.GroupBy.WithRollupTag, stSpaceBefore);
  end;
  if (Nodes.Having.Tag > 0) then
  begin
    FormatNode(Nodes.Having.Tag, Separator);
    Commands.IncreaseIndent();
    FormatNode(Nodes.Having.Expr, Separator);
    Commands.DecreaseIndent();
  end;
  FormatNode(Nodes.OrderBy, Separator);
  FormatNode(Nodes.Limit, Separator);
  if (Nodes.Proc.Tag > 0) then
  begin
    FormatNode(Nodes.Proc.Tag, Separator);
    Commands.IncreaseIndent();
    FormatNode(Nodes.Proc.Ident, Separator);
    FormatNode(Nodes.Proc.ParamList, stSpaceBefore);
    Commands.DecreaseIndent();
  end;
  FormatInto(Nodes.Into2);
  FormatNode(Nodes.ForUpdatesTag, Separator);
  FormatNode(Nodes.LockInShareMode, Separator);
  FormatList(Nodes.CloseBrackets1, sNone);
  if (Nodes.UnionList > 0) then
  begin
    Commands.WriteReturn();
    FormatList(Nodes.UnionList, sReturn);
  end;
  FormatList(Nodes.CloseBrackets2, sNone);
end;

procedure TSQLParser.FormatSelectStmtColumn(const Nodes: TSelectStmt.TColumn.TNodes);
var
  Expr: TOffset;
  AliasIdent: TOffset;
begin
  Expr := Nodes.Expr;
  if ((Expr > 0) and (NodePtr(Expr)^.NodeType = ntDbIdent)) then
    Expr := PDbIdent(NodePtr(Expr))^.Nodes.Ident;
  AliasIdent := Nodes.AliasIdent;
  if ((AliasIdent > 0) and (NodePtr(AliasIdent)^.NodeType = ntDbIdent)) then
    AliasIdent := PDbIdent(NodePtr(AliasIdent))^.Nodes.Ident;

  FormatNode(Nodes.Expr);
  if ((Nodes.AliasIdent > 0)
    and (not IsToken(Expr) or not IsToken(AliasIdent) or (TokenPtr(Expr)^.AsString <> TokenPtr(AliasIdent)^.AsString))) then
  begin
    FormatNode(Nodes.AsTag, stSpaceBefore);
    FormatNode(Nodes.AliasIdent, stSpaceBefore);
  end;
end;

procedure TSQLParser.FormatSelectStmtTableFactor(const Nodes: TSelectStmt.TTableFactor.TNodes);
var
  Ident: TOffset;
  AliasIdent: TOffset;
begin
  Ident := Nodes.Ident;
  if ((Ident > 0) and (NodePtr(Ident)^.NodeType = ntDbIdent)) then
    Ident := PDbIdent(NodePtr(Ident))^.Nodes.Ident;
  AliasIdent := Nodes.AliasIdent;
  if ((AliasIdent > 0) and (NodePtr(AliasIdent)^.NodeType = ntDbIdent)) then
    AliasIdent := PDbIdent(NodePtr(AliasIdent))^.Nodes.Ident;

  FormatNode(Nodes.Ident);
  FormatNode(Nodes.PartitionTag, stSpaceBefore);
  FormatNode(Nodes.Partitions, stSpaceBefore);
  if ((Nodes.AliasIdent > 0)
    and (not IsToken(Ident) or not IsToken(AliasIdent) or (TokenPtr(Ident)^.AsString <> TokenPtr(AliasIdent)^.AsString))) then
  begin
    FormatNode(Nodes.AsTag, stSpaceBefore);
    FormatNode(Nodes.AliasIdent, stSpaceBefore);
  end;
  FormatNode(Nodes.IndexHintList, stSpaceBefore);
  FormatNode(Nodes.SelectStmt, stSpaceBefore);
end;

procedure TSQLParser.FormatSelectStmtTableFactorOj(const Nodes: TSelectStmt.TTableFactorOj.TNodes);
begin
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.OjTag);
  FormatNode(Nodes.TableReference, stSpaceBefore);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatSelectStmtTableFactorSubquery(const Nodes: TSelectStmt.TTableFactorSubquery.TNodes);
begin
  FormatNode(Nodes.SelectStmt);
  FormatNode(Nodes.AsTag, stSpaceBefore);
  FormatNode(Nodes.AliasIdent, stSpaceBefore);
end;

procedure TSQLParser.FormatSelectStmtTableJoin(const Nodes: TSelectStmt.TTableJoin.TNodes);
var
  Separator: TSeparatorType;
  Spacer: TSpacer;
begin
  if (((Nodes.OnExpr = 0)
      or (NodePtr(Nodes.OnExpr)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.OnExpr))^.ElementCount <= 3))) then
  begin
    Separator := stSpaceBefore;
    Spacer := sSpace;
  end
  else
  begin
    Separator := stReturnBefore;
    Spacer := sReturn;
  end;

  FormatNode(Nodes.JoinTag);
  FormatNode(Nodes.RightTable, stSpaceBefore);
  if (Separator = stSpaceBefore) then
  begin
    FormatNode(Nodes.OnTag, Separator);
    FormatNode(Nodes.OnExpr, stSpaceBefore);
  end
  else
  begin
    Commands.IncreaseIndent();
    FormatNode(Nodes.OnTag, Separator);
    Commands.WriteReturn();
    Commands.IncreaseIndent();
    FormatList(Nodes.OnExpr, Spacer);
    Commands.DecreaseIndent();
    Commands.DecreaseIndent();
  end;
end;

procedure TSQLParser.FormatSetStmt(const Nodes: TSetStmt.TNodes);
var
  Separator: TSeparatorType;
begin
  if (((Nodes.AssignmentList = 0)
    or (NodePtr(Nodes.AssignmentList)^.NodeType <> ntList)
    or (PList(NodePtr(Nodes.AssignmentList))^.ElementCount = 1))) then
  begin
    Separator := stSpaceBefore;
  end
  else
  begin
    Separator := stReturnBefore;
  end;

  FormatNode(Nodes.SetTag);
  FormatNode(Nodes.ScopeTag, stSpaceBefore);

  if (Separator = stSpaceBefore) then
  begin
    FormatNode(Nodes.AssignmentList, stSpaceBefore);
  end
  else
  begin
    Commands.WriteReturn();
    Commands.IncreaseIndent();
    FormatList(Nodes.AssignmentList, sReturn);
    Commands.DecreaseIndent();
  end;
end;

procedure TSQLParser.FormatShowBinlogEventsStmt(const Nodes: TShowBinlogEventsStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.InValue, stSpaceBefore);
  FormatNode(Nodes.FromValue, stSpaceBefore);
  FormatNode(Nodes.Limit.Tag, stSpaceBefore);
  Commands.WriteSpace();
  FormatNode(Nodes.Limit.OffsetToken);
  FormatNode(Nodes.Limit.CommaToken);
  FormatNode(Nodes.Limit.RowCountToken);
end;

procedure TSQLParser.FormatShowErrorsStmt(const Nodes: TShowErrorsStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.Limit.Tag, stSpaceBefore);
  Commands.WriteSpace();
  FormatNode(Nodes.Limit.OffsetToken);
  FormatNode(Nodes.Limit.CommaToken);
  FormatNode(Nodes.Limit.RowCountToken);
end;

procedure TSQLParser.FormatShowRelaylogEventsStmt(const Nodes: TShowBinlogEventsStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.InValue, stSpaceBefore);
  FormatNode(Nodes.FromValue, stSpaceBefore);
  FormatNode(Nodes.Limit.Tag, stSpaceBefore);
  Commands.WriteSpace();
  FormatNode(Nodes.Limit.OffsetToken);
  FormatNode(Nodes.Limit.CommaToken);
  FormatNode(Nodes.Limit.RowCountToken);
end;

procedure TSQLParser.FormatShowWarningsStmt(const Nodes: TShowWarningsStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.Limit.Tag, stSpaceBefore);
  Commands.WriteSpace();
  FormatNode(Nodes.Limit.OffsetToken);
  FormatNode(Nodes.Limit.CommaToken);
  FormatNode(Nodes.Limit.RowCountToken);
end;

function TSQLParser.FormatSQL(): string;
begin
  if (not Assigned(Root)) then
    Result := ''
  else
  begin
    Commands := TFormatBuffer.Create();

    FormatRoot(Root);

    Result := Commands.Read();

    Commands.Free(); Commands := nil;
  end;
end;

procedure TSQLParser.FormatSubArea(const Nodes: TSubArea.TNodes);
begin
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.AreaNode);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatSubPartition(const Nodes: TSubPartition.TNodes);
begin
  FormatNode(Nodes.SubPartitionTag);
  FormatNode(Nodes.NameIdent, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.EngineValue, stReturnBefore);
  FormatNode(Nodes.CommentValue, stReturnBefore);
  FormatNode(Nodes.DataDirectoryValue, stReturnBefore);
  FormatNode(Nodes.IndexDirectoryValue, stReturnBefore);
  FormatNode(Nodes.MaxRowsValue, stReturnBefore);
  FormatNode(Nodes.MinRowsValue, stReturnBefore);
  FormatNode(Nodes.TablespaceValue, stReturnBefore);
  Commands.DecreaseIndent();
end;

procedure TSQLParser.FormatSubquery(const Nodes: TSubquery.TNodes);
begin
  FormatNode(Nodes.IdentTag);
  FormatNode(Nodes.OpenToken, stSpaceBefore);
  FormatNode(Nodes.Subquery);
  FormatNode(Nodes.CloseToken);
end;

procedure TSQLParser.FormatSubstringFunc(const Nodes: TSubstringFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.Str);
  if (not IsToken(Nodes.FromTag) or (TokenPtr(Nodes.FromTag)^.TokenType <> ttComma)) then
    FormatNode(Nodes.FromTag, stSpaceBefore)
  else
    FormatNode(Nodes.FromTag);
  FormatNode(Nodes.Pos);
  if (not IsToken(Nodes.ForTag) or (TokenPtr(Nodes.FromTag)^.TokenType <> ttComma)) then
    FormatNode(Nodes.ForTag, stSpaceBefore)
  else
    FormatNode(Nodes.ForTag);
  FormatNode(Nodes.Len, stSpaceBefore);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatSumFunc(const Nodes: TSumFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.DistinctToken, stSpaceAfter);
  FormatNode(Nodes.Expr);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatTimestampAddFunc(const Nodes: TTimestampAddFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.UnitTag);
  FormatNode(Nodes.Comma1);
  FormatNode(Nodes.IntervalInt, stSpaceBefore);
  FormatNode(Nodes.Comma2);
  FormatNode(Nodes.DatetimeExpr, stSpaceBefore);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatTimestampDiffFunc(const Nodes: TTimestampDiffFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.UnitTag);
  FormatNode(Nodes.Comma1);
  FormatNode(Nodes.Datetime1Expr, stSpaceBefore);
  FormatNode(Nodes.Comma2);
  FormatNode(Nodes.Datetime2Expr, stSpaceBefore);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatToken(const Token: TToken);
label
  UpcaseL, UpcaseLE,
  LowcaseL, LowcaseLE;
var
  Dest: PChar;
  Keyword: array [0 .. 255] of Char;
  Index: Integer;
  Length: Integer;
  S: string;
  Text: PChar;
begin
  if ((Token.UsageType in [utKeyword, utOperator])
    or (Token.UsageType = utDbIdent)
      and ((Token.DbIdentType = ditConstante)
        or (Token.DbIdentType = ditFunction) and (FunctionList.IndexOf(Token.FText, Token.FLength) >= 0)
        or (Token.DbIdentType = ditTriggerRec))) then
  begin
    Token.GetText(Text, Length);

    if (Length > 0) then
    begin
      Dest := @Keyword[0];

      asm // Convert SQL to upper case
          PUSH ES
          PUSH ESI
          PUSH EDI

          PUSH DS                          // string operations uses ES
          POP ES
          CLD                              // string operations uses forward direction

          MOV ESI,Text
          MOV ECX,Length
          MOV EDI,Dest

        UpcaseL:
          LODSW                            // Get character to AX
          CMP AX,'a'                       // Small character?
          JB UpcaseLE                      // No!
          CMP AX,'z'                       // Small character?
          JA UpcaseLE                      // No!
          AND AX,$FF - $20                 // Upcase character
        UpcaseLE:
          STOSW                            // Put character from AX
          LOOP UpcaseL                     // Further characters!

          POP EDI
          POP ESI
          POP ES
      end;

      Commands.Write(@Keyword[0], Token.Length);
    end;
  end
  else if (Token.UsageType = utDatatype) then
  begin
    Token.GetText(Text, Length);

    if (Length > 0) then
    begin
      Dest := @Keyword[0];

      asm // Convert SQL to upper case
          PUSH ES
          PUSH ESI
          PUSH EDI

          PUSH DS                          // string operations uses ES
          POP ES
          CLD                              // string operations uses forward direction

          MOV ESI,Text
          MOV ECX,Length
          MOV EDI,Dest

        LowcaseL:
          LODSW                            // Get character to AX
          CMP AX,'A'                       // Small character?
          JB LowcaseLE                     // No!
          CMP AX,'Z'                       // Small character?
          JA LowcaseLE                     // No!
          OR AX,$20                        // Locase character
        LowcaseLE:
          STOSW                            // Put character from AX
          LOOP LowcaseL                    // Further characters!

          POP EDI
          POP ESI
          POP ES
      end;

      Commands.Write(@Keyword[0], Token.Length);
    end;
  end
  else if (Token.UsageType = utDbIdent) then
    if (Token.TokenType = ttOperator) then
      Commands.Write(Token.FText, Token.FLength)
    else if (Token.DbIdentType in [ditUser, ditHost, ditColumnAlias]) then
      Commands.Write(SQLEscape(Token.AsString, ''''))
    else if ((Token.DbIdentType in [ditTableAlias, ditVariable, ditRoutineParam, ditCompoundVariable, ditCursor, ditCondition]) and IsSimpleDbIdent(@Token)) then
      Commands.Write(Token.AsString)
    else if (Token.DbIdentType in [ditDatabase, ditTable, ditProcedure, ditTrigger, ditEvent, ditKey, ditField, ditForeignKey, ditPartition, ditConstraint, ditTableAlias, ditPlugin, ditVariable, ditRoutineParam, ditCompoundVariable, ditCursor, ditCondition]) then
      if (AnsiQuotes) then
        Commands.Write(SQLEscape(Token.AsString, '"'))
      else
        Commands.Write(SQLEscape(Token.AsString, '`'))
    else
      Commands.Write(Token.FText, Token.FLength)
  else if (Token.UsageType = utString) then
  begin
    Token.GetText(Text, Length);
    if ((Length > 0) and (Text[0] = '_')) then
    begin
      // Remove character set identifieer
      Index := 0;
      while ((Index < Length) and not (CharInSet(Text[Index], [#9,#10,#13,' ','''','"']))) do
        Inc(Index);
      while ((Index < Length) and (CharInSet(Text[Index], [#9,#10,#13,' ']))) do
        Inc(Index);
      Text := @Text[Index];
      Dec(Length, Index);
    end;
    if ((Length > 1) and CharInSet(Text[0], ['N','X','n','x']) and CharInSet(Text[1], ['''', '"'])) then
    begin
      // Handle hex or national introducer without unescape / escape
      Commands.Write(Text, 1);
      Text := @Text[1];
      Dec(Length);
    end;
    SetLength(S, SQLUnescape(Text, Length, nil, 0));
    if (System.Length(S) > 0) then
      SQLUnescape(Text, Length, @S[1], System.Length(S));
    Commands.Write(SQLEscape(S));
  end
  else if (Token.UsageType = utNumeric) then
  begin
    Token.GetText(Text, Length);
    while ((Length > 1) and (Text[0] = '0') and (Text[0] <> '.')) do
      begin Text := @Text[1]; Dec(Length); end;
    while ((Length > 0) and (Text[Length - 1] = '0')) do
      Dec(Length);
    if ((Length > 0) and CharInSet(Text[Length - 1], ['E', 'e'])) then
      Dec(Length);
    while ((Length > 0) and (Text[Length - 1] = '0')) do
      Dec(Length);
    if ((Length > 0) and (Text[Length - 1] = '.')) then
      Dec(Length);
    if ((Length = 0) or (Text[0] = '.')) then
      Commands.Write('0');
    Commands.Write(Text, Length);
  end
  else if (Token.UsageType = utInteger) then
  begin
    Token.GetText(Text, Length);
    while ((Length > 1) and (Text[0] = '0')) do
      begin Text := @Text[1]; Dec(Length); end;
    Commands.Write(Text, Length);
  end
  else
  begin
    Token.GetText(Text, Length);
    Commands.Write(Text, Length);
  end;

  FormatComments(Token.NextTokenAll, False);
end;

procedure TSQLParser.FormatTrimFunc(const Nodes: TTrimFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.LocationTag, stSpaceAfter);
  FormatNode(Nodes.RemoveStr, stSpaceAfter);
  FormatNode(Nodes.FromTag, stSpaceAfter);
  FormatNode(Nodes.Str);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatTruncateStmt(const Nodes: TTruncateStmt.TNodes);
begin
  FormatNode(Nodes.StmtTag);
  FormatNode(Nodes.TableTag, stSpaceBefore);
  FormatNode(Nodes.TableIdent, stSpaceBefore);
end;

procedure TSQLParser.FormatUnaryOp(const Nodes: TUnaryOp.TNodes);
begin
  FormatNode(Nodes.Operator);
  if (IsToken(Nodes.Operator) and (TokenPtr(Nodes.Operator)^.KeywordIndex >= 0)) then
    Commands.WriteSpace();
  FormatNode(Nodes.Operand);
end;

procedure TSQLParser.FormatUnknownStmt(const Node: PUnknownStmt);
var
  Token: PToken;
begin
  Token := PRange(Node)^.FirstToken;
  while (Assigned(Token)) do
  begin
    FormatToken(Token^);

    if (Token = PRange(Node)^.LastToken) then
      Token := nil
    else
      Token := Token^.NextTokenAll;
  end;
end;

procedure TSQLParser.FormatUpdateStmt(const Nodes: TUpdateStmt.TNodes);
var
  Separator: TSeparatorType;
  Spacer: TSpacer;
begin
  if (((Nodes.TableReferenceList = 0)
      or (NodePtr(Nodes.TableReferenceList)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.TableReferenceList))^.ElementCount = 1))
    and ((Nodes.TableReferenceList = 0)
      or (NodePtr(Nodes.TableReferenceList)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.TableReferenceList))^.Nodes.FirstElement = 0)
      or (NodePtr(PList(NodePtr(Nodes.TableReferenceList))^.Nodes.FirstElement)^.NodeType <> ntList)
      or (PList(NodePtr(PList(NodePtr(Nodes.TableReferenceList))^.Nodes.FirstElement))^.ElementCount = 1))
    and ((Nodes.Set_.PairList = 0)
      or (NodePtr(Nodes.Set_.PairList)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.Set_.PairList))^.ElementCount <= 3))
    and ((Nodes.Where.Expr = 0)
      or (NodePtr(Nodes.Where.Expr)^.NodeType <> ntList)
      or (PList(NodePtr(Nodes.Where.Expr))^.ElementCount <= 3))) then
  begin
    Separator := stSpaceBefore;
    Spacer := sSpace;
  end
  else
  begin
    Separator := stReturnBefore;
    Spacer := sReturn;
  end;

  FormatNode(Nodes.UpdateTag);
  FormatNode(Nodes.PriorityTag, stSpaceBefore);

  if (Separator = stSpaceBefore) then
    FormatNode(Nodes.TableReferenceList, Separator)
  else
  begin
    Commands.WriteReturn();
    Commands.IncreaseIndent();
    FormatList(Nodes.TableReferenceList, Spacer);
    Commands.DecreaseIndent();
  end;
  FormatNode(Nodes.Set_.Tag, Separator);
  if (Separator = stSpaceBefore) then
    FormatNode(Nodes.Set_.PairList, Separator)
  else
  begin
    Commands.WriteReturn();
    Commands.IncreaseIndent();
    FormatList(Nodes.Set_.PairList, Spacer);
    Commands.DecreaseIndent();
  end;
  FormatNode(Nodes.Where.Tag, Separator);
  if (Separator = stSpaceBefore) then
    FormatNode(Nodes.Where.Expr, stSpaceBefore)
  else
  begin
    Commands.IncreaseIndent();
    FormatNode(Nodes.Where.Expr, Separator);
    Commands.DecreaseIndent();
  end;
  FormatNode(Nodes.Limit.Tag, Separator);
  FormatNode(Nodes.Limit.Token, stSpaceBefore);
end;

procedure TSQLParser.FormatVariableIdent(const Nodes: TVariable.TNodes);
begin
  FormatNode(Nodes.At1Token);
  FormatNode(Nodes.At2Token);
  FormatNode(Nodes.ScopeTag);
  FormatNode(Nodes.ScopeDotToken);
  FormatNode(Nodes.Ident);
end;

procedure TSQLParser.FormatWeightStringFunc(const Nodes: TWeightStringFunc.TNodes);
begin
  FormatNode(Nodes.IdentToken);
  FormatNode(Nodes.OpenBracket);
  FormatNode(Nodes.Str);
  FormatNode(Nodes.AsTag, stSpaceBefore);
  FormatNode(Nodes.Datatype, stSpaceBefore);
  FormatNode(Nodes.LevelTag, stSpaceBefore);
  FormatNode(Nodes.LevelList, stSpaceBefore);
  FormatNode(Nodes.CloseBracket);
end;

procedure TSQLParser.FormatWhileStmt(const Nodes: TWhileStmt.TNodes);
begin
  FormatNode(Nodes.BeginLabel, stSpaceAfter);
  FormatNode(Nodes.WhileTag);
  FormatNode(Nodes.SearchConditionExpr, stSpaceBefore);
  Commands.IncreaseIndent();
  FormatNode(Nodes.DoTag, stSpaceBefore);
  FormatNode(Nodes.StmtList, stReturnBefore);
  Commands.DecreaseIndent();
  FormatNode(Nodes.EndTag, stReturnBefore);
  FormatNode(Nodes.EndLabel, stSpaceBefore);
end;

procedure TSQLParser.FormatXID(const Nodes: TXAStmt.TID.TNodes);
begin
  FormatNode(Nodes.GTrId);
  FormatNode(Nodes.Comma1, stSpaceAfter);
  FormatNode(Nodes.BQual);
  FormatNode(Nodes.Comma2, stSpaceAfter);
  FormatNode(Nodes.FormatId);
end;

function TSQLParser.GetCharsets(): string;
begin
  Result := CharsetList.Text;
end;

function TSQLParser.GetDatatypes(): string;
begin
  Result := DatatypeList.Text;
end;

function TSQLParser.GetErrorFound(): Boolean;
begin
  Result := Error.Code <> PE_Success;
end;

function TSQLParser.GetErrorMessage(): string;
begin
  Result := CreateErrorMessage(FirstError);
end;

function TSQLParser.GetErrorPos(): Integer;
begin
  Result := FirstError.Pos - @Parse.SQL[1];
end;

function TSQLParser.GetErrorToken(): PToken;
begin
  if (not IsToken(FirstError.Token)) then
    Result := nil
  else
    Result := TokenPtr(FirstError.Token);
end;

function TSQLParser.GetFirstStmt(): PStmt;
begin
  if (FRoot = 0) then
    Result := nil
  else
    Result := Root^.FirstStmt;
end;

function TSQLParser.GetFirstTokenAll(): PToken;
begin
  if (FRoot = 0) then
    Result := nil
  else
    Result := Root^.FirstTokenAll;
end;

function TSQLParser.GetInCompound(): Boolean;
begin
  Result := FInCompound > 0;
end;

function TSQLParser.GetInPL_SQL(): Boolean;
begin
  Result := FInPL_SQL > 0;
end;

function TSQLParser.GetKeywords(): string;
begin
  Result := KeywordList.Text;
end;

function TSQLParser.GetNextToken(Index: Integer): TOffset;
begin
  Assert(Index >= 0);

  Result := GetToken(Index);
end;

function TSQLParser.GetReservedWords(): string;
begin
  Result := ReservedWordList.Text;
end;

function TSQLParser.GetRoot(): PRoot;
begin
  if (FRoot = 0) then
    Result := nil
  else
    Result := PRoot(NodePtr(FRoot));
end;

function TSQLParser.GetToken(const Index: Integer): TOffset;
var
  Error: TError;
  Token: TOffset;
begin
  if (Index > TokenBuffer.Count - 1) then
    repeat
      Token := ParseToken(Error);

      if ((Token > 0) and TokenPtr(Token)^.IsUsed) then
      begin
        {$IFDEF Debug}
        Inc(TokenIndex);
        {$ENDIF}

        if (TokenBuffer.Count = System.Length(TokenBuffer.Items)) then
          SetError(PE_Unknown)
        else
        begin
          TokenBuffer.Items[TokenBuffer.Count].Token := Token;
          TokenBuffer.Items[TokenBuffer.Count].Error := Error;
          Inc(TokenBuffer.Count);
        end;
      end;
    until ((Token = 0)
      or (TokenBuffer.Count = Index + 1)
      or (TokenBuffer.Count = System.Length(TokenBuffer.Items)));

  if ((Index >= TokenBuffer.Count) or (TokenBuffer.Count = System.Length(TokenBuffer.Items))) then
    Result := 0
  else
    Result := TokenBuffer.Items[Index].Token;
end;

function TSQLParser.IsChild(const Node: PNode): Boolean;
begin
  Result := Assigned(Node) and (Node^.NodeType <> ntRoot);
end;

function TSQLParser.IsChild(const Node: TOffset): Boolean;
begin
  Result := (Node > 0) and IsChild(NodePtr(Node));
end;

function TSQLParser.IsNextTag(const Index: Integer; const KeywordIndex1: TWordList.TIndex;
  const KeywordIndex2: TWordList.TIndex = -1; const KeywordIndex3: TWordList.TIndex = -1;
  const KeywordIndex4: TWordList.TIndex = -1; const KeywordIndex5: TWordList.TIndex = -1;
  const KeywordIndex6: TWordList.TIndex = -1; const KeywordIndex7: TWordList.TIndex = -1): Boolean;
begin
  Result := False;
  if (EndOfStmt(NextToken[Index]) or (TokenPtr(NextToken[Index])^.KeywordIndex <> KeywordIndex1)) then
  else if (KeywordIndex2 < 0) then
    Result := True
  else if (EndOfStmt(NextToken[Index + 1]) or (TokenPtr(NextToken[Index + 1])^.KeywordIndex <> KeywordIndex2)) then
  else if (KeywordIndex3 < 0) then
    Result := True
  else if (EndOfStmt(NextToken[Index + 2]) or (TokenPtr(NextToken[Index + 2])^.KeywordIndex <> KeywordIndex3)) then
  else if (KeywordIndex4 < 0) then
    Result := True
  else if (EndOfStmt(NextToken[Index + 3]) or (TokenPtr(NextToken[Index + 3])^.KeywordIndex <> KeywordIndex4)) then
  else if (KeywordIndex5 < 0) then
    Result := True
  else if (EndOfStmt(NextToken[Index + 4]) or (TokenPtr(NextToken[Index + 4])^.KeywordIndex <> KeywordIndex5)) then
  else if (KeywordIndex6 < 0) then
    Result := True
  else if (EndOfStmt(NextToken[Index + 5]) or (TokenPtr(NextToken[Index + 5])^.KeywordIndex <> KeywordIndex6)) then
  else if (KeywordIndex7 < 0) then
    Result := True
  else if (EndOfStmt(NextToken[Index + 6]) or (TokenPtr(NextToken[Index + 6])^.KeywordIndex <> KeywordIndex7)) then
  else
    Result := True;
end;

function TSQLParser.IsStmt(const Node: PNode): Boolean;
begin
  Result := Assigned(Node) and (Node^.NodeType in StmtNodeTypes);
end;

function TSQLParser.IsStmt(const Node: TOffset): Boolean;
begin
  Result := (Node > 0) and IsStmt(NodePtr(Node));
end;

function TSQLParser.IsNextSymbol(const Index: Integer; const TokenType: TTokenType): Boolean;
begin
  Result := (NextToken[Index] > 0) and (TokenPtr(NextToken[Index])^.TokenType = TokenType);
end;

function TSQLParser.IsSelectStmt(): Boolean;
var
  Index: Integer;
begin
  Index := 0;
  while (IsNextSymbol(Index, ttOpenBracket)) do Inc(Index);
  Result := IsNextTag(Index, kiSELECT);
end;

function TSQLParser.IsSymbol(const TokenType: TTokenType): Boolean;
begin
  Result := (CurrentToken > 0) and (TokenPtr(CurrentToken)^.TokenType = TokenType);
end;

function TSQLParser.IsTag(const KeywordIndex1: TWordList.TIndex;
  const KeywordIndex2: TWordList.TIndex = -1; const KeywordIndex3: TWordList.TIndex = -1;
  const KeywordIndex4: TWordList.TIndex = -1; const KeywordIndex5: TWordList.TIndex = -1;
  const KeywordIndex6: TWordList.TIndex = -1; const KeywordIndex7: TWordList.TIndex = -1): Boolean;
begin
  Result := False;
  if (EndOfStmt(CurrentToken) or (TokenPtr(CurrentToken)^.KeywordIndex <> KeywordIndex1)) then
    CompletionList.AddTag(KeywordIndex1, KeywordIndex2, KeywordIndex3, KeywordIndex4, KeywordIndex5, KeywordIndex6, KeywordIndex7)
  else if (KeywordIndex2 < 0) then
    Result := True
  else if (EndOfStmt(NextToken[1]) or (TokenPtr(NextToken[1])^.KeywordIndex <> KeywordIndex2)) then
    CompletionList.AddTag(KeywordIndex1, KeywordIndex2, KeywordIndex3, KeywordIndex4, KeywordIndex5, KeywordIndex6, KeywordIndex7)
  else if (KeywordIndex3 < 0) then
    Result := True
  else if (EndOfStmt(NextToken[2]) or (TokenPtr(NextToken[2])^.KeywordIndex <> KeywordIndex3)) then
    CompletionList.AddTag(KeywordIndex1, KeywordIndex2, KeywordIndex3, KeywordIndex4, KeywordIndex5, KeywordIndex6, KeywordIndex7)
  else if (KeywordIndex4 < 0) then
    Result := True
  else if (EndOfStmt(NextToken[3]) or (TokenPtr(NextToken[3])^.KeywordIndex <> KeywordIndex4)) then
    CompletionList.AddTag(KeywordIndex1, KeywordIndex2, KeywordIndex3, KeywordIndex4, KeywordIndex5, KeywordIndex6, KeywordIndex7)
  else if (KeywordIndex5 < 0) then
    Result := True
  else if (EndOfStmt(NextToken[4]) or (TokenPtr(NextToken[4])^.KeywordIndex <> KeywordIndex5)) then
    CompletionList.AddTag(KeywordIndex1, KeywordIndex2, KeywordIndex3, KeywordIndex4, KeywordIndex5, KeywordIndex6, KeywordIndex7)
  else if (KeywordIndex6 < 0) then
    Result := True
  else if (EndOfStmt(NextToken[5]) or (TokenPtr(NextToken[5])^.KeywordIndex <> KeywordIndex6)) then
    CompletionList.AddTag(KeywordIndex1, KeywordIndex2, KeywordIndex3, KeywordIndex4, KeywordIndex5, KeywordIndex6, KeywordIndex7)
  else if (KeywordIndex7 < 0) then
    Result := True
  else if (EndOfStmt(NextToken[6]) or (TokenPtr(NextToken[6])^.KeywordIndex <> KeywordIndex7)) then
    CompletionList.AddTag(KeywordIndex1, KeywordIndex2, KeywordIndex3, KeywordIndex4, KeywordIndex5, KeywordIndex6, KeywordIndex7)
  else
    Result := True;
end;

function TSQLParser.IsOperator(const Node: TOffset): Boolean;
var
  N: PNode;
begin
  if (Node = 0) then
    N := nil
  else
    N := NodePtr(Node);

  if (not Assigned(N) or (N^.NodeType <> ntToken)) then
    Result := False
  else
    Result := PToken(N)^.OperatorType <> otNone;
end;

function TSQLParser.IsRange(const Node: PNode): Boolean;
begin
  Assert(Assigned(Node));

  Result := Assigned(Node) and not (Node^.NodeType in [ntRoot, ntToken]);
end;

function TSQLParser.IsRange(const Node: TOffset): Boolean;
begin
  Result := (Node > 0) and IsRange(NodePtr(Node));
end;

function TSQLParser.IsSimpleDbIdent(const Node: PNode): Boolean;
var
  I: Integer;
  S: string;
begin
  Result := IsToken(Node) and (PToken(Node)^.DbIdentType <> ditUnknown);

  if (Result) then
  begin
    S := PToken(Node)^.AsString;
    for I := 1 to Length(S) do
      Result := Result and CharInSet(S[I], ['$', '0'..'9', 'A'..'Z', '_', 'a'..'z']);
  end;
end;

function TSQLParser.IsSimpleDbIdent(const Node: TOffset): Boolean;
begin
  Result := (Node > 0) and IsSimpleDbIdent(NodePtr(Node));
end;

function TSQLParser.IsToken(const Node: PNode): Boolean;
begin
  Result := Assigned(Node) and (Node^.NodeType = ntToken);
end;

function TSQLParser.IsToken(const Node: TOffset): Boolean;
begin
  Result := (Node > 0) and IsToken(NodePtr(Node));
end;

function TSQLParser.LoadFromFile(const Filename: string): Boolean;
var
  BytesPerSector: DWord;
  BytesRead: DWord;
  FileSize: DWord;
  Handle: THandle;
  Len: Integer;
  MemSize: DWord;
  NumberofFreeClusters: DWord;
  SectorsPerCluser: DWord;
  Mem: PAnsiChar;
  TotalNumberOfClusters: DWord;
begin
  FRoot := 0;

  Clear();

  if (not GetDiskFreeSpace(PChar(ExtractFileDrive(Filename)), SectorsPerCluser, BytesPerSector, NumberofFreeClusters, TotalNumberOfClusters)) then
    RaiseLastOSError();

  Handle := CreateFile(PChar(Filename),
                       GENERIC_READ,
                       FILE_SHARE_READ,
                       nil,
                       OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  if (Handle = INVALID_HANDLE_VALUE) then
    RaiseLastOSError()
  else
  begin
    FileSize := GetFileSize(Handle, nil);
    if (FileSize = INVALID_FILE_SIZE) then
    begin
      CloseHandle(Handle);
      RaiseLastOSError();
    end
    else
    begin
      MemSize := ((FileSize div BytesPerSector) + 1) * BytesPerSector;

      GetMem(Mem, MemSize);
      if (not Assigned(Mem)) then
      begin
        CloseHandle(Handle);
        raise Exception.CreateFmt(SOutOfMemory, [MemSize]);
      end
      else
      begin
        if (not ReadFile(Handle, Mem^, MemSize, BytesRead, nil)) then
          RaiseLastOSError()
        else if (BytesRead <> FileSize) then
          raise Exception.Create(SUnknownError)
        else if ((BytesRead >= DWord(Length(BOM_UTF8))) and (CompareMem(Mem, BOM_UTF8, Length(BOM_UTF8)))) then
        begin
          Len := MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, @Mem[Length(BOM_UTF8)], BytesRead - DWord(Length(BOM_UTF8)), nil, 0);
          SetLength(Parse.SQL, Len);
          MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, @Mem[Length(BOM_UTF8)], BytesRead - DWord(Length(BOM_UTF8)), @Parse.SQL[1], Len);
        end
        else if ((BytesRead >= DWord(Length(BOM_UNICODE_LE))) and (CompareMem(Mem, BOM_UNICODE_LE, Length(BOM_UNICODE_LE)))) then
        begin
          Len := (BytesRead - DWord(Length(BOM_UNICODE_LE))) div SizeOf(WideChar);
          SetLength(Parse.SQL, Len);
          MoveMemory(PChar(Parse.SQL), @Mem[Length(BOM_UNICODE_LE)], Len * SizeOf(WideChar));
        end
        else
        begin
          Len := MultiByteToWideChar(CP_ACP, MB_ERR_INVALID_CHARS, Mem, BytesRead, nil, 0);
          SetLength(Parse.SQL, Len);
          MultiByteToWideChar(CP_ACP, MB_ERR_INVALID_CHARS, Mem, BytesRead, PChar(Parse.SQL), Length(Parse.SQL));
        end;

        FreeMem(Mem);
        CloseHandle(Handle);

        FRoot := ParseRoot();
      end;
    end;
  end;

  Result := (FirstError.Code = PE_Success) and Assigned(FirstStmt);
end;

function TSQLParser.NewNode(const NodeType: TNodeType): TOffset;
var
  Size: Integer;
begin
  Size := NodeSize(NodeType);

  if (Nodes.UsedSize + Size > Nodes.MemSize) then
  begin
    Inc(Nodes.MemSize, Nodes.MemSize);
    ReallocMem(Nodes.Mem, Nodes.MemSize);
  end;

  Result := Nodes.UsedSize;
  Inc(Nodes.UsedSize, Size);
end;

function TSQLParser.NodePtr(const Node: TOffset): PNode;
begin
  Assert((0 < Node) and (Node < Nodes.UsedSize));

  Result := @Nodes.Mem[Node];
end;

function TSQLParser.NodeSize(const NodeType: TNodeType): Integer;
begin
  case (NodeType) of
    ntRoot: Result := SizeOf(TRoot);
    ntToken: Result := SizeOf(TToken);

    ntAccount: Result := SizeOf(TAccount);
    ntAnalyzeTableStmt: Result := SizeOf(TAnalyzeTableStmt);
    ntAlterDatabaseStmt: Result := SizeOf(TAlterDatabaseStmt);
    ntAlterEventStmt: Result := SizeOf(TAlterEventStmt);
    ntAlterInstanceStmt: Result := SizeOf(TAlterInstanceStmt);
    ntAlterRoutineStmt: Result := SizeOf(TAlterRoutineStmt);
    ntAlterServerStmt: Result := SizeOf(TAlterServerStmt);
    ntAlterTablespaceStmt: Result := SizeOf(TAlterTablespaceStmt);
    ntAlterTableStmt: Result := SizeOf(TAlterTableStmt);
    ntAlterTableStmtAddField: Result := SizeOf(TAlterTableStmt.TAddField);
    ntAlterTableStmtAddFields: Result := SizeOf(TAlterTableStmt.TAddFields);
    ntAlterTableStmtAlterField: Result := SizeOf(TAlterTableStmt.TAlterField);
    ntAlterTableStmtConvertTo: Result := SizeOf(TAlterTableStmt.TConvertTo);
    ntAlterTableStmtDropObject: Result := SizeOf(TAlterTableStmt.TDropObject);
    ntAlterTableStmtExchangePartition: Result := SizeOf(TAlterTableStmt.TExchangePartition);
    ntAlterTableStmtOrderBy: Result := SizeOf(TAlterTableStmt.TOrderBy);
    ntAlterTableStmtReorganizePartition: Result := SizeOf(TAlterTableStmt.TReorganizePartition);
    ntAlterViewStmt: Result := SizeOf(TAlterViewStmt);
    ntBeginLabel: Result := SizeOf(TBeginLabel);
    ntBeginStmt: Result := SizeOf(TBeginStmt);
    ntBetweenOp: Result := SizeOf(TBetweenOp);
    ntBinaryOp: Result := SizeOf(TBinaryOp);
    ntCallStmt: Result := SizeOf(TCallStmt);
    ntCaseOp: Result := SizeOf(TCaseOp);
    ntCaseOpBranch: Result := SizeOf(TCaseOp.TBranch);
    ntCaseStmt: Result := SizeOf(TCaseStmt);
    ntCaseStmtBranch: Result := SizeOf(TCaseStmt.TBranch);
    ntCastFunc: Result := SizeOf(TCastFunc);
    ntChangeMasterStmt: Result := SizeOf(TChangeMasterStmt);
    ntCharFunc: Result := SizeOf(TCharFunc);
    ntCheckTableStmt: Result := SizeOf(TCheckTableStmt);
    ntChecksumTableStmt: Result := SizeOf(TChecksumTableStmt);
    ntCloseStmt: Result := SizeOf(TCloseStmt);
    ntCommitStmt: Result := SizeOf(TCommitStmt);
    ntCompoundStmt: Result := SizeOf(TCompoundStmt);
    ntConvertFunc: Result := SizeOf(TConvertFunc);
    ntCountFunc: Result := SizeOf(TCountFunc);
    ntCreateDatabaseStmt: Result := SizeOf(TCreateDatabaseStmt);
    ntCreateEventStmt: Result := SizeOf(TCreateEventStmt);
    ntCreateIndexStmt: Result := SizeOf(TCreateIndexStmt);
    ntCreateRoutineStmt: Result := SizeOf(TCreateRoutineStmt);
    ntCreateServerStmt: Result := SizeOf(TCreateServerStmt);
    ntCreateTablespaceStmt: Result := SizeOf(TCreateTablespaceStmt);
    ntCreateTableStmt: Result := SizeOf(TCreateTableStmt);
    ntCreateTableStmtCheck: Result := SizeOf(TCreateTableStmt.TCheck);
    ntCreateTableStmtField: Result := SizeOf(TCreateTableStmt.TField);
    ntCreateTableStmtFieldOnUpdate: Result := SizeOf(TCreateTableStmt.TField.TOnUpdate);
    ntCreateTableStmtForeignKey: Result := SizeOf(TCreateTableStmt.TForeignKey);
    ntCreateTableStmtKey: Result := SizeOf(TCreateTableStmt.TKey);
    ntCreateTableStmtKeyColumn: Result := SizeOf(TCreateTableStmt.TKeyColumn);
    ntCreateTableStmtPartition: Result := SizeOf(TCreateTableStmt.TPartition);
    ntCreateTableStmtPartitionOptions: Result := SizeOf(TCreateTableStmt.TPartitionOptions);
    ntCreateTableStmtReference: Result := SizeOf(TCreateTableStmt.TReference);
    ntCreateTriggerStmt: Result := SizeOf(TCreateTriggerStmt);
    ntCreateUserStmt: Result := SizeOf(TCreateUserStmt);
    ntCreateViewStmt: Result := SizeOf(TCreateViewStmt);
    ntDatatype: Result := SizeOf(TDatatype);
    ntDateAddFunc: Result := SizeOf(TDateAddFunc);
    ntDbIdent: Result := SizeOf(TDbIdent);
    ntDeallocatePrepareStmt: Result := SizeOf(TDeallocatePrepareStmt);
    ntDeclareStmt: Result := SizeOf(TDeclareStmt);
    ntDeclareConditionStmt: Result := SizeOf(TDeclareConditionStmt);
    ntDeclareCursorStmt: Result := SizeOf(TDeclareCursorStmt);
    ntDeclareHandlerStmt: Result := SizeOf(TDeclareHandlerStmt);
    ntDefaultFunc: Result := SizeOf(TDefaultFunc);
    ntDeleteStmt: Result := SizeOf(TDeleteStmt);
    ntDoStmt: Result := SizeOf(TDoStmt);
    ntDropDatabaseStmt: Result := SizeOf(TDropDatabaseStmt);
    ntDropEventStmt: Result := SizeOf(TDropEventStmt);
    ntDropIndexStmt: Result := SizeOf(TDropIndexStmt);
    ntDropRoutineStmt: Result := SizeOf(TDropRoutineStmt);
    ntDropServerStmt: Result := SizeOf(TDropServerStmt);
    ntDropTablespaceStmt: Result := SizeOf(TDropTablespaceStmt);
    ntDropTableStmt: Result := SizeOf(TDropTableStmt);
    ntDropTriggerStmt: Result := SizeOf(TDropTriggerStmt);
    ntDropUserStmt: Result := SizeOf(TDropUserStmt);
    ntDropViewStmt: Result := SizeOf(TDropViewStmt);
    ntEndLabel: Result := SizeOf(TEndLabel);
    ntExecuteStmt: Result := SizeOf(TExecuteStmt);
    ntExplainStmt: Result := SizeOf(TExplainStmt);
    ntExtractFunc: Result := SizeOf(TExtractFunc);
    ntFetchStmt: Result := SizeOf(TFetchStmt);
    ntFlushStmt: Result := SizeOf(TFlushStmt);
    ntFlushStmtOption: Result := SizeOf(TFlushStmt.TOption);
    ntFlushStmtOptionLogs: Result := SizeOf(TFlushStmt.TOption.TLogs);
    ntFunctionReturns: Result := SizeOf(TFunctionReturns);
    ntGetDiagnosticsStmt: Result := SizeOf(TGetDiagnosticsStmt);
    ntGetDiagnosticsStmtStmtInfo: Result := SizeOf(TGetDiagnosticsStmt.TStmtInfo);
    ntGetDiagnosticsStmtCondInfo: Result := SizeOf(TGetDiagnosticsStmt.TStmtInfo);
    ntGrantStmt: Result := SizeOf(TGrantStmt);
    ntGrantStmtPrivileg: Result := SizeOf(TGrantStmt.TPrivileg);
    ntGrantStmtUserSpecification: Result := SizeOf(TGrantStmt.TUserSpecification);
    ntGroupConcatFunc: Result := SizeOf(TGroupConcatFunc);
    ntGroupConcatFuncExpr: Result := SizeOf(TGroupConcatFunc.TExpr);
    ntHelpStmt: Result := SizeOf(THelpStmt);
    ntIfStmt: Result := SizeOf(TIfStmt);
    ntIfStmtBranch: Result := SizeOf(TIfStmt.TBranch);
    ntInOp: Result := SizeOf(TInOp);
    ntInsertStmt: Result := SizeOf(TInsertStmt);
    ntInsertStmtSetItem: Result := SizeOf(TInsertStmt.TSetItem);
    ntInstallPluginStmt: Result := SizeOf(TInstallPluginStmt);
    ntIntervalOp: Result := SizeOf(TIntervalOp);
    ntIsOp: Result := SizeOf(TIsOp);
    ntIterateStmt: Result := SizeOf(TIterateStmt);
    ntKillStmt: Result := SizeOf(TKillStmt);
    ntLeaveStmt: Result := SizeOf(TLeaveStmt);
    ntLikeOp: Result := SizeOf(TLikeOp);
    ntList: Result := SizeOf(TList);
    ntLoadDataStmt: Result := SizeOf(TLoadDataStmt);
    ntLoadXMLStmt: Result := SizeOf(TLoadXMLStmt);
    ntLockTablesStmt: Result := SizeOf(TLockTablesStmt);
    ntLockTablesStmtItem: Result := SizeOf(TLockTablesStmt.TItem);
    ntLoopStmt: Result := SizeOf(TLoopStmt);
    ntMatchFunc: Result := SizeOf(TMatchFunc);
    ntOpenStmt: Result := SizeOf(TOpenStmt);
    ntOptimizeTableStmt: Result := SizeOf(TOptimizeTableStmt);
    ntPositionFunc: Result := SizeOf(TPositionFunc);
    ntPrepareStmt: Result := SizeOf(TPrepareStmt);
    ntPurgeStmt: Result := SizeOf(TPurgeStmt);
    ntRegExpOp: Result := SizeOf(TRegExpOp);
    ntRenameStmt: Result := SizeOf(TRenameStmt);
    ntRenameStmtPair: Result := SizeOf(TRenameStmt.TPair);
    ntReleaseStmt: Result := SizeOf(TReleaseStmt);
    ntRepairTableStmt: Result := SizeOf(TRepairTableStmt);
    ntRepeatStmt: Result := SizeOf(TRepeatStmt);
    ntResetStmt: Result := SizeOf(TResetStmt);
    ntReturnStmt: Result := SizeOf(TReturnStmt);
    ntRevokeStmt: Result := SizeOf(TRevokeStmt);
    ntRollbackStmt: Result := SizeOf(TRollbackStmt);
    ntRoutineParam: Result := SizeOf(TRoutineParam);
    ntSavepointStmt: Result := SizeOf(TSavepointStmt);
    ntSchedule: Result := SizeOf(TSchedule);
    ntSecretIdent: Result := SizeOf(TSecretIdent);
    ntSelectStmt: Result := SizeOf(TSelectStmt);
    ntSelectStmtColumn: Result := SizeOf(TSelectStmt.TColumn);
    ntSelectStmtGroup: Result := SizeOf(TSelectStmt.TGroup);
    ntSelectStmtLimit: Result := SizeOf(TSelectStmt.TLimit);
    ntSelectStmtOrder: Result := SizeOf(TSelectStmt.TOrder);
    ntSelectStmtOrderBy: Result := SizeOf(TSelectStmt.TOrderBy);
    ntSelectStmtTableFactor: Result := SizeOf(TSelectStmt.TTableFactor);
    ntSelectStmtTableFactorIndexHint: Result := SizeOf(TSelectStmt.TTableFactor.TIndexHint);
    ntSelectStmtTableFactorOj: Result := SizeOf(TSelectStmt.TTableFactorOj);
    ntSelectStmtTableFactorSubquery: Result := SizeOf(TSelectStmt.TTableFactorSubquery);
    ntSelectStmtTableJoin: Result := SizeOf(TSelectStmt.TTableJoin);
    ntSetNamesStmt: Result := SizeOf(TSetNamesStmt);
    ntSetPasswordStmt: Result := SizeOf(TSetPasswordStmt);
    ntSetStmt: Result := SizeOf(TSetStmt);
    ntSetStmtAssignment: Result := SizeOf(TSetStmt.TAssignment);
    ntSetTransactionStmt: Result := SizeOf(TSetTransactionStmt);
    ntSetTransactionStmtCharacteristic: Result := SizeOf(TSetTransactionStmt.TCharacteristic);
    ntShowBinaryLogsStmt: Result := SizeOf(TShowBinaryLogsStmt);
    ntShowBinlogEventsStmt: Result := SizeOf(TShowBinlogEventsStmt);
    ntShowCharacterSetStmt: Result := SizeOf(TShowCharacterSetStmt);
    ntShowCollationStmt: Result := SizeOf(TShowCollationStmt);
    ntShowColumnsStmt: Result := SizeOf(TShowColumnsStmt);
    ntShowCountStmt: Result := SizeOf(TShowCountStmt);
    ntShowCreateDatabaseStmt: Result := SizeOf(TShowCreateDatabaseStmt);
    ntShowCreateEventStmt: Result := SizeOf(TShowCreateEventStmt);
    ntShowCreateFunctionStmt: Result := SizeOf(TShowCreateFunctionStmt);
    ntShowCreateProcedureStmt: Result := SizeOf(TShowCreateProcedureStmt);
    ntShowCreateTableStmt: Result := SizeOf(TShowCreateTableStmt);
    ntShowCreateTriggerStmt: Result := SizeOf(TShowCreateTriggerStmt);
    ntShowCreateUserStmt: Result := SizeOf(TShowCreateUserStmt);
    ntShowCreateViewStmt: Result := SizeOf(TShowCreateViewStmt);
    ntShowDatabasesStmt: Result := SizeOf(TShowDatabasesStmt);
    ntShowEngineStmt: Result := SizeOf(TShowEngineStmt);
    ntShowEnginesStmt: Result := SizeOf(TShowEnginesStmt);
    ntShowErrorsStmt: Result := SizeOf(TShowErrorsStmt);
    ntShowEventsStmt: Result := SizeOf(TShowEventsStmt);
    ntShowFunctionStatusStmt: Result := SizeOf(TShowFunctionStatusStmt);
    ntShowGrantsStmt: Result := SizeOf(TShowGrantsStmt);
    ntShowIndexStmt: Result := SizeOf(TShowIndexStmt);
    ntShowMasterStatusStmt: Result := SizeOf(TShowMasterStatusStmt);
    ntShowOpenTablesStmt: Result := SizeOf(TShowOpenTablesStmt);
    ntShowPluginsStmt: Result := SizeOf(TShowPluginsStmt);
    ntShowPrivilegesStmt: Result := SizeOf(TShowPrivilegesStmt);
    ntShowProcedureStatusStmt: Result := SizeOf(TShowProcedureStatusStmt);
    ntShowProcessListStmt: Result := SizeOf(TShowProcessListStmt);
    ntShowProfileStmt: Result := SizeOf(TShowProfileStmt);
    ntShowProfilesStmt: Result := SizeOf(TShowProfilesStmt);
    ntShowRelaylogEventsStmt: Result := SizeOf(TShowRelaylogEventsStmt);
    ntShowRoutineCodeStmt: Result := SizeOf(TShowRoutineCodeStmt);
    ntShowSlaveHostsStmt: Result := SizeOf(TShowSlaveHostsStmt);
    ntShowSlaveStatusStmt: Result := SizeOf(TShowSlaveStatusStmt);
    ntShowStatusStmt: Result := SizeOf(TShowStatusStmt);
    ntShowTableStatusStmt: Result := SizeOf(TShowTableStatusStmt);
    ntShowTablesStmt: Result := SizeOf(TShowTablesStmt);
    ntShowTriggersStmt: Result := SizeOf(TShowTriggersStmt);
    ntShowVariablesStmt: Result := SizeOf(TShowVariablesStmt);
    ntShowWarningsStmt: Result := SizeOf(TShowWarningsStmt);
    ntShutdownStmt: Result := SizeOf(TShutdownStmt);
    ntSignalStmt: Result := SizeOf(TSignalStmt);
    ntSignalStmtInformation: Result := SizeOf(TSignalStmt.TInformation);
    ntSoundsLikeOp: Result := SizeOf(TSoundsLikeOp);
    ntStartSlaveStmt: Result := SizeOf(TStartSlaveStmt);
    ntStartTransactionStmt: Result := SizeOf(TStartTransactionStmt);
    ntStopSlaveStmt: Result := SizeOf(TStopSlaveStmt);
    ntSubArea: Result := SizeOf(TSubArea);
    ntSubPartition: Result := SizeOf(TSubPartition);
    ntSubquery: Result := SizeOf(TSubquery);
    ntSubstringFunc: Result := SizeOf(TSubstringFunc);
    ntSumFunc: Result := SizeOf(TSumFunc);
    ntTag: Result := SizeOf(TTag);
    ntTimestampAddFunc: Result := SizeOf(TTimestampAddFunc);
    ntTimestampDiffFunc: Result := SizeOf(TTimestampDiffFunc);
    ntTrimFunc: Result := SizeOf(TTrimFunc);
    ntTruncateStmt: Result := SizeOf(TTruncateStmt);
    ntUnaryOp: Result := SizeOf(TUnaryOp);
    ntUninstallPluginStmt: Result := SizeOf(TUninstallPluginStmt);
    ntUnknownStmt: Result := SizeOf(TUnknownStmt);
    ntUnlockTablesStmt: Result := SizeOf(TUnlockTablesStmt);
    ntUpdateStmt: Result := SizeOf(TUpdateStmt);
    ntUseStmt: Result := SizeOf(TUseStmt);
    ntValue: Result := SizeOf(TValue);
    ntVariableIdent: Result := SizeOf(TVariable);
    ntWeightStringFunc: Result := SizeOf(TWeightStringFunc);
    ntWeightStringFuncLevel: Result := SizeOf(TWeightStringFunc.TLevel);
    ntWhileStmt: Result := SizeOf(TWhileStmt);
    ntXAStmt: Result := SizeOf(TXAStmt);
    ntXAStmtID: Result := SizeOf(TXAStmt.TID);
    else raise ERangeError.Create(SRangeError);
  end;
end;

function TSQLParser.ParseAccountIdent(): TOffset;
var
  Nodes: TAccount.TNodes;
begin
  Result := 0;

  if (EndOfStmt(CurrentToken)) then
  begin
    CompletionList.AddList(ditUser);
    SetError(PE_IncompleteStmt);
  end
  else if (IsTag(kiCURRENT_USER)) then
    if (IsNextSymbol(1, ttOpenBracket) and IsNextSymbol(2, ttCloseBracket)) then
      Result := ParseDefaultFunc() // CURRENT_USER()
    else
      Result := ParseConstIdent() // CURRENT_USER
  else if ((TokenPtr(CurrentToken)^.TokenType in ttIdents) or (TokenPtr(CurrentToken)^.TokenType in ttStrings)) then
  begin
    FillChar(Nodes, SizeOf(Nodes), 0);

    Nodes.UserIdent := ParseDbIdent(ditUser, False);

    if (not ErrorFound and not EndOfStmt(CurrentToken) and (TokenPtr(CurrentToken)^.TokenType = ttAt)) then
    begin
      Nodes.AtToken := ParseSymbol(ttAt);

      if (not ErrorFound) then
        Nodes.HostIdent := ParseDbIdent(ditHost, False);
    end;

    Result := TAccount.Create(Self, Nodes);
  end
  else
    SetError(PE_UnexpectedToken);
end;

function TSQLParser.ParseAnalyzeTableStmt(): TOffset;
var
  Nodes: TAnalyzeTableStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiANALYZE);

  if (not ErrorFound) then
    if (IsTag(kiNO_WRITE_TO_BINLOG)) then
      Nodes.NoWriteToBinlogTag := ParseTag(kiNO_WRITE_TO_BINLOG)
    else if (IsTag(kiLOCAL)) then
      Nodes.NoWriteToBinlogTag := ParseTag(kiLOCAL);

  if (not ErrorFound) then
    Nodes.TableTag := ParseTag(kiTABLE);

  if (not ErrorFound) then
    Nodes.TablesList := ParseList(False, ParseTableIdent);

  Result := TAnalyzeTableStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterDatabaseStmt(const AlterTag: TOffset): TOffset;
var
  Found: Boolean;
  Nodes: TAlterDatabaseStmt.TNodes;
  OldCurrentToken: TOffset;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.AlterTag := AlterTag;

  if (IsTag(kiDATABASE)) then
    Nodes.DatabaseTag := ParseTag(kiDATABASE)
  else
    Nodes.DatabaseTag := ParseTag(kiSCHEMA);

  if (not ErrorFound) then
    Nodes.Ident := ParseDatabaseIdent();

  if (not ErrorFound) then
    if ((Nodes.Ident = 0) or not IsTag(kiUPGRADE, kiDATA, kiDIRECTORY, kiNAME)) then
    begin
      Found := True; OldCurrentToken := CurrentToken;
      while (not ErrorFound and Found) do
        if ((Nodes.CharsetValue = 0) and IsTag(kiCHARACTER)) then
          Nodes.CharsetValue := ParseValue(WordIndices(kiCHARACTER, kiSET), vaAuto, ParseCharsetIdent)
        else if ((Nodes.CharsetValue = 0) and IsTag(kiCHARSET)) then
          Nodes.CharsetValue := ParseValue(kiCHARSET, vaAuto, ParseDbIdent)
        else if ((Nodes.CollateValue = 0) and IsTag(kiCOLLATE)) then
          Nodes.CollateValue := ParseValue(kiCOLLATE, vaAuto, ParseCollateIdent)
        else if ((Nodes.CharsetValue = 0) and IsTag(kiDEFAULT, kiCHARACTER, kiSET)) then
          Nodes.CharsetValue := ParseValue(WordIndices(kiDEFAULT, kiCHARACTER, kiSET), vaAuto, ParseCharsetIdent)
        else if ((Nodes.CharsetValue = 0) and IsTag(kiDEFAULT, kiCHARSET)) then
          Nodes.CharsetValue := ParseValue(WordIndices(kiDEFAULT, kiCHARSET), vaAuto, ParseCharsetIdent)
        else if ((Nodes.CollateValue = 0) and IsTag(kiDEFAULT, kiCOLLATE)) then
          Nodes.CollateValue := ParseValue(WordIndices(kiDEFAULT, kiCOLLATE), vaAuto, ParseCollateIdent)
        else
          Found := False;

      if (not ErrorFound and (CurrentToken = OldCurrentToken)) then
        if (EndOfStmt(CurrentToken)) then
          SetError(PE_IncompleteStmt)
        else
          SetError(PE_UnexpectedToken);
    end
    else
    begin
      Nodes.UpgradeDataDirectoryNameTag := ParseTag(kiUPGRADE, kiDATA, kiDIRECTORY, kiNAME);
    end;

  Result := TAlterDatabaseStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterEventStmt(const AlterTag, DefinerValue: TOffset): TOffset;
var
  Nodes: TAlterEventStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.AlterTag := AlterTag;

  Nodes.DefinerValue := DefinerValue;

  Nodes.EventTag := ParseTag(kiEVENT);

  if (not ErrorFound) then
    Nodes.EventIdent := ParseEventIdent();

  if (not ErrorFound) then
    if (IsTag(kiON, kiSCHEDULE)) then
    begin
      Nodes.OnSchedule.Tag := ParseTag(kiON, kiSCHEDULE);

      if (not ErrorFound) then
        Nodes.OnSchedule.Value := ParseSchedule();
    end;

  if (not ErrorFound) then
    if (IsTag(kiON, kiCOMPLETION, kiPRESERVE)) then
      Nodes.OnCompletionTag := ParseTag(kiON, kiCOMPLETION, kiPRESERVE)
    else if (IsTag(kiON, kiCOMPLETION, kiNOT, kiPRESERVE)) then
      Nodes.OnCompletionTag := ParseTag(kiON, kiCOMPLETION, kiNOT, kiPRESERVE);

  if (not ErrorFound) then
    if (IsTag(kiRENAME, kiTO)) then
      Nodes.RenameValue := ParseValue(WordIndices(kiRENAME, kiTO), vaNo, ParseEventIdent);

  if (not ErrorFound) then
    if (IsTag(kiENABLE)) then
      Nodes.EnableTag := ParseTag(kiENABLE)
    else if (IsTag(kiDISABLE, kiON, kiSLAVE)) then
      Nodes.EnableTag := ParseTag(kiDISABLE, kiON, kiSLAVE)
    else if (IsTag(kiDISABLE)) then
      Nodes.EnableTag := ParseTag(kiDISABLE);

  if (not ErrorFound) then
    if (IsTag(kiCOMMENT)) then
      Nodes.CommentValue := ParseValue(kiCOMMENT, vaNo, ParseString);

  if (not ErrorFound) then
    if (IsTag(kiDO)) then
    begin
      Nodes.DoTag := ParseTag(kiDO);

      if (not ErrorFound) then
      begin
        Nodes.Stmt := ParsePL_SQLStmt();
        if (not ErrorFound and (Nodes.Stmt = 0)) then
          SetError(PE_IncompleteStmt);
      end;
    end;

  Result := TAlterEventStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterInstanceStmt(const AlterTag: TOffset): TOffset;
var
  Nodes: TAlterInstanceStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.AlterTag := AlterTag;

  Nodes.Tag := ParseTag(kiALTER, kiINSTANCE, kiROTATE, kiINNODB, kiMASTER, kiKEY);

  Result := TAlterInstanceStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterRoutineStmt(const ARoutineType: TRoutineType; const AlterTag: TOffset): TOffset;
var
  Found: Boolean;
  Nodes: TAlterRoutineStmt.TNodes;
  OldCurrentToken: TOffset;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.AlterTag := AlterTag;

  if (ARoutineType = rtProcedure) then
    Nodes.RoutineTag := ParseTag(kiPROCEDURE)
  else
    Nodes.RoutineTag := ParseTag(kiFUNCTION);

  if (not ErrorFound) then
    if (ARoutineType = rtProcedure) then
      Nodes.Ident := ParseProcedureIdent()
    else
      Nodes.Ident := ParseFunctionIdent();

  Found := True; OldCurrentToken := CurrentToken;
  while (not ErrorFound and Found) do
    if ((Nodes.CommentValue = 0) and IsTag(kiCOMMENT)) then
      Nodes.CommentValue := ParseValue(kiComment, vaNo, ParseString)
    else if ((Nodes.LanguageTag = 0) and IsTag(kiLANGUAGE, kiSQL)) then
      Nodes.LanguageTag := ParseTag(kiLANGUAGE, kiSQL)
    else if ((Nodes.DeterministicTag = 0) and IsTag(kiDETERMINISTIC)) then
      Nodes.DeterministicTag := ParseTag(kiDETERMINISTIC)
    else if ((Nodes.DeterministicTag = 0) and IsTag(kiNOT, kiDETERMINISTIC)) then
      Nodes.DeterministicTag := ParseTag(kiNOT, kiDETERMINISTIC)
    else if ((Nodes.NatureOfDataTag = 0) and IsTag(kiCONTAINS, kiSQL)) then
      Nodes.NatureOfDataTag := ParseTag(kiCONTAINS, kiSQL)
    else if ((Nodes.NatureOfDataTag = 0) and IsTag(kiNO, kiSQL)) then
      Nodes.NatureOfDataTag := ParseTag(kiNO, kiSQL)
    else if ((Nodes.NatureOfDataTag = 0) and IsTag(kiREADS, kiSQL, kiDATA)) then
      Nodes.NatureOfDataTag := ParseTag(kiREADS, kiSQL, kiDATA)
    else if ((Nodes.NatureOfDataTag = 0) and IsTag(kiMODIFIES, kiSQL, kiDATA)) then
      Nodes.NatureOfDataTag := ParseTag(kiMODIFIES, kiSQL, kiDATA)
    else if ((Nodes.NatureOfDataTag = 0) and IsTag(kiSQL, kiSECURITY, kiDEFINER)) then
      Nodes.SQLSecurityTag := ParseTag(kiSQL, kiSECURITY, kiDEFINER)
    else if ((Nodes.NatureOfDataTag = 0) and IsTag(kiSQL, kiSECURITY, kiINVOKER)) then
      Nodes.SQLSecurityTag := ParseTag(kiSQL, kiSECURITY, kiINVOKER)
    else
      Found := False;

  if (not ErrorFound and (CurrentToken = OldCurrentToken)) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  Result := TAlterRoutineStmt.Create(Self, ARoutineType, Nodes);
end;

function TSQLParser.ParseAlterServerStmt(const AlterTag: TOffset): TOffset;
var
  Nodes: TAlterServerStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.AlterTag := AlterTag;

  Nodes.ServerTag := ParseTag(kiSERVER);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent();

  if (not ErrorFound) then
    Nodes.Options.Tag := ParseTag(kiOPTIONS);

  if (not ErrorFound) then
    Nodes.Options.List := ParseCreateServerStmtOptionList();

  Result := TAlterServerStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterStmt(): TOffset;
var
  AlgorithmValue: TOffset;
  AlterTag: TOffset;
  DefinerValue: TOffset;
  IgnoreTag: TOffset;
  OnlineTag: TOffset;
  SQLSecurityTag: TOffset;
begin
  AlgorithmValue := 0;
  DefinerValue := 0;
  IgnoreTag := 0;
  OnlineTag := 0;
  SQLSecurityTag := 0;

  AlterTag := ParseTag(kiALTER);

  if (not ErrorFound) then
    if (IsTag(kiALGORITHM)) then
      AlgorithmValue := ParseValue(kiALGORITHM, vaYes, WordIndices(kiUNDEFINED, kiMERGE, kiTEMPTABLE));

  if (not ErrorFound) then
    if (IsTag(kiDEFINER)) then
      DefinerValue := ParseDefinerValue();

  if (not ErrorFound) then
    if (IsTag(kiSQL, kiSECURITY, kiDEFINER)) then
      SQLSecurityTag := ParseTag(kiSQL, kiSECURITY, kiDEFINER)
    else if (IsTag(kiSQL, kiSECURITY, kiINVOKER)) then
      SQLSecurityTag := ParseTag(kiSQL, kiSECURITY, kiINVOKER);

  if (not ErrorFound and (AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0)) then
    if (IsTag(kiONLINE)) then
      IgnoreTag := ParseTag(kiONLINE);

  if (not ErrorFound and (AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0)) then
    if (IsTag(kiIGNORE)) then
      IgnoreTag := ParseTag(kiIGNORE);

  if (ErrorFound) then
    Result := 0
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (OnlineTag = 0) and (IgnoreTag = 0)
    and IsTag(kiDATABASE)) then
    Result := ParseAlterDatabaseStmt(AlterTag)
  else if ((AlgorithmValue = 0) and (SQLSecurityTag = 0) and (IgnoreTag = 0)
    and IsTag(kiEVENT)) then
    Result := ParseAlterEventStmt(AlterTag, DefinerValue)
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (OnlineTag = 0) and (IgnoreTag = 0)
    and IsTag(kiFUNCTION)) then
    Result := ParseAlterRoutineStmt(rtFunction, AlterTag)
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (OnlineTag = 0) and (IgnoreTag = 0)
    and IsTag(kiINSTANCE)) then
    Result := ParseAlterInstanceStmt(AlterTag)
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (OnlineTag = 0) and (IgnoreTag = 0)
    and IsTag(kiPROCEDURE)) then
    Result := ParseAlterRoutineStmt(rtProcedure, AlterTag)
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (OnlineTag = 0) and (IgnoreTag = 0)
    and IsTag(kiSCHEMA)) then
    Result := ParseAlterDatabaseStmt(AlterTag)
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (OnlineTag = 0) and (IgnoreTag = 0)
    and IsTag(kiSERVER)) then
    Result := ParseAlterServerStmt(AlterTag)
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0)
    and IsTag(kiTABLE)) then
    Result := ParseAlterTableStmt(AlterTag, IgnoreTag)
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (OnlineTag = 0) and (IgnoreTag = 0)
    and IsTag(kiTABLESPACE)) then
    Result := ParseAlterTablespaceStmt(AlterTag)
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (OnlineTag = 0) and (IgnoreTag = 0)
    and IsTag(kiUSER)) then
    Result := ParseCreateUserStmt(AlterTag)
  else if ((OnlineTag = 0) and (IgnoreTag = 0)
    and IsTag(kiVIEW)) then
    Result := ParseAlterViewStmt(AlterTag, AlgorithmValue, DefinerValue, SQLSecurityTag)
  else if (EndOfStmt(CurrentToken)) then
    Result := SetError(PE_IncompleteStmt)
  else
    Result := SetError(PE_UnexpectedToken);
end;

function TSQLParser.ParseAlterTablespaceStmt(const AlterTag: TOffset): TOffset;
var
  Nodes: TAlterTablespaceStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.AlterTag := AlterTag;

  Nodes.TablespaceTag := ParseTag(kiTABLESPACE);

  if (not ErrorFound) then
    if (IsTag(kiADD, kiDATAFILE)) then
      Nodes.AddDatafileValue := ParseValue(WordIndices(kiADD, kiDATAFILE), vaNo, ParseString)
    else
      Nodes.AddDatafileValue := ParseValue(WordIndices(kiDROP, kiDATAFILE), vaNo, ParseString);

  if (not ErrorFound) then
    if (IsTag(kiINITIAL_SIZE)) then
      Nodes.InitialSizeValue := ParseValue(kiINITIAL_SIZE, vaAuto, ParseInteger);

  if (not ErrorFound) then
    Nodes.EngineValue := ParseValue(kiENGINE, vaAuto, ParseEngineIdent);

  Result := TAlterTablespaceStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterTableStmt(const AlterTag, IgnoreTag: TOffset): TOffset;
var
  Comma: TOffset;
  Found: Boolean;
  Found2: Boolean;
  ListNodes: TList.TNodes;
  Nodes: TAlterTableStmt.TNodes;
  OldSpecificationsCount: Integer;
  Specifications: TOffsetList;
  TableOptionFound: Boolean;
  TableOptions: TTableOptionNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);
  FillChar(TableOptions, SizeOf(TableOptions), 0);

  Specifications.Init();

  Nodes.AlterTag := AlterTag;

  Nodes.IgnoreTag := IgnoreTag;

  if (not ErrorFound) then
    Nodes.TableTag := ParseTag(kiTABLE);

  if (not ErrorFound) then
    Nodes.Ident := ParseTableIdent();


  Found := not EndOfStmt(CurrentToken);
  while (not ErrorFound and Found and not EndOfStmt(CurrentToken)) do
  begin

    Found2 := True; OldSpecificationsCount := Specifications.Count;
    while (not ErrorFound and Found2) do
    begin
      if ((TableOptions.AutoIncrementValue = 0) and IsTag(kiAUTO_INCREMENT)) then
      begin
        TableOptions.AutoIncrementValue := ParseValue(kiAUTO_INCREMENT, vaAuto, ParseInteger);
        Specifications.Add(TableOptions.AutoIncrementValue);
      end
      else if ((TableOptions.AvgRowLengthValue = 0) and IsTag(kiAVG_ROW_LENGTH)) then
      begin
        TableOptions.AvgRowLengthValue := ParseValue(kiAVG_ROW_LENGTH, vaAuto, ParseInteger);
        Specifications.Add(TableOptions.AvgRowLengthValue);
      end
      else if ((TableOptions.CharacterSetValue = 0) and IsTag(kiCHARACTER, kiSET)) then
      begin
        TableOptions.CharacterSetValue := ParseValue(WordIndices(kiCHARACTER, kiSET), vaAuto, ParseCharsetIdent);
        Specifications.Add(TableOptions.CharacterSetValue);
      end
      else if ((TableOptions.CharacterSetValue = 0) and IsTag(kiCHARSET)) then
      begin
        TableOptions.CharacterSetValue := ParseValue(kiCHARSET, vaAuto, ParseCharsetIdent);
        Specifications.Add(TableOptions.CharacterSetValue);
      end
      else if ((TableOptions.ChecksumValue = 0) and IsTag(kiCHECKSUM)) then
      begin
        TableOptions.ChecksumValue := ParseValue(kiCHECKSUM, vaAuto, ParseInteger);
        Specifications.Add(TableOptions.ChecksumValue);
      end
      else if ((TableOptions.CollateValue = 0) and IsTag(kiCOLLATE)) then
      begin
        TableOptions.CollateValue := ParseValue(kiCOLLATE, vaAuto, ParseCollateIdent);
        Specifications.Add(TableOptions.CollateValue);
      end
      else if ((TableOptions.CharacterSetValue = 0) and IsTag(kiDEFAULT, kiCHARACTER, kiSET)) then
      begin
        TableOptions.CharacterSetValue := ParseValue(WordIndices(kiDEFAULT, kiCHARACTER, kiSET), vaAuto, ParseCharsetIdent);
        Specifications.Add(TableOptions.CharacterSetValue);
      end
      else if ((TableOptions.CharacterSetValue = 0) and IsTag(kiDEFAULT, kiCHARSET)) then
      begin
        TableOptions.CharacterSetValue := ParseValue(WordIndices(kiDEFAULT, kiCHARSET), vaAuto, ParseCharsetIdent);
        Specifications.Add(TableOptions.CharacterSetValue);
      end
      else if ((TableOptions.CollateValue = 0) and IsTag(kiDEFAULT, kiCOLLATE)) then
      begin
        TableOptions.CollateValue := ParseValue(WordIndices(kiDEFAULT, kiCOLLATE), vaAuto, ParseCollateIdent);
        Specifications.Add(TableOptions.CollateValue);
      end
      else if ((TableOptions.CommentValue = 0) and IsTag(kiCOMMENT)) then
      begin
        TableOptions.CommentValue := ParseValue(kiCOMMENT, vaAuto, ParseString);
        Specifications.Add(TableOptions.CommentValue);
      end
      else if ((TableOptions.ConnectionValue = 0) and IsTag(kiCONNECTION)) then
      begin
        TableOptions.ConnectionValue := ParseValue(kiCONNECTION, vaAuto, ParseString);
        Specifications.Add(TableOptions.ConnectionValue);
      end
      else if ((TableOptions.DataDirectoryValue = 0) and IsTag(kiDATA, kiDIRECTORY)) then
      begin
        TableOptions.DataDirectoryValue := ParseValue(WordIndices(kiDATA, kiDIRECTORY), vaAuto, ParseString);
        Specifications.Add(TableOptions.DataDirectoryValue);
      end
      else if ((TableOptions.DelayKeyWriteValue = 0) and IsTag(kiDELAY_KEY_WRITE)) then
      begin
        TableOptions.DelayKeyWriteValue := ParseValue(kiDELAY_KEY_WRITE, vaAuto, ParseInteger);
        Specifications.Add(TableOptions.DelayKeyWriteValue);
      end
      else if ((TableOptions.EngineIdent = 0) and IsTag(kiENGINE) and (MySQLVersion >= 40018)) then
      begin
        TableOptions.EngineIdent := ParseValue(kiENGINE, vaAuto, ParseEngineIdent);
        Specifications.Add(TableOptions.EngineIdent);
      end
      else if ((TableOptions.IndexDirectoryValue = 0) and IsTag(kiINDEX, kiDIRECTORY)) then
      begin
        TableOptions.IndexDirectoryValue := ParseValue(WordIndices(kiINDEX, kiDIRECTORY), vaAuto, ParseString);
        Specifications.Add(TableOptions.IndexDirectoryValue);
      end
      else if ((TableOptions.InsertMethodValue = 0) and IsTag(kiINSERT_METHOD)) then
      begin
        TableOptions.InsertMethodValue := ParseValue(kiINSERT_METHOD, vaAuto, WordIndices(kiNO, kiFIRST, kiLAST));
        Specifications.Add(TableOptions.InsertMethodValue);
      end
      else if ((TableOptions.KeyBlockSizeValue = 0) and IsTag(kiKEY_BLOCK_SIZE)) then
      begin
        TableOptions.KeyBlockSizeValue := ParseValue(kiKEY_BLOCK_SIZE, vaAuto, ParseInteger);
        Specifications.Add(TableOptions.KeyBlockSizeValue);
      end
      else if ((TableOptions.MaxRowsValue = 0) and IsTag(kiMAX_ROWS)) then
      begin
        TableOptions.MaxRowsValue := ParseValue(kiMAX_ROWS, vaAuto, ParseInteger);
        Specifications.Add(TableOptions.MaxRowsValue);
      end
      else if ((TableOptions.MinRowsValue = 0) and IsTag(kiMIN_ROWS)) then
      begin
        TableOptions.MinRowsValue := ParseValue(kiMIN_ROWS, vaAuto, ParseInteger);
        Specifications.Add(TableOptions.MinRowsValue);
      end
      else if ((TableOptions.PackKeysValue = 0) and IsTag(kiPACK_KEYS)) then
      begin
        TableOptions.PackKeysValue := ParseValue(kiPACK_KEYS, vaAuto, ParseExpr);
        Specifications.Add(TableOptions.PackKeysValue);
      end
      else if ((TableOptions.PageChecksumInt = 0) and IsTag(kiPAGE_CHECKSUM)) then
      begin
        TableOptions.PageChecksumInt := ParseValue(kiPAGE_CHECKSUM, vaAuto, ParseInteger);
        Specifications.Add(TableOptions.PageChecksumInt);
      end
      else if ((TableOptions.PasswordValue = 0) and IsTag(kiPASSWORD)) then
      begin
        TableOptions.PasswordValue := ParseValue(kiPASSWORD, vaAuto, ParseString);
        Specifications.Add(TableOptions.PasswordValue);
      end
      else if ((TableOptions.RowFormatValue = 0) and IsTag(kiROW_FORMAT)) then
      begin
        TableOptions.RowFormatValue := ParseValue(kiROW_FORMAT, vaAuto, ParseDbIdent);
        Specifications.Add(TableOptions.RowFormatValue);
      end
      else if ((TableOptions.StatsAutoRecalc = 0) and IsTag(kiSTATS_AUTO_RECALC, kiDEFAULT)) then
      begin
        TableOptions.StatsAutoRecalc := ParseValue(kiSTATS_AUTO_RECALC, vaAuto, WordIndices(kiDEFAULT));
        Specifications.Add(TableOptions.StatsAutoRecalc);
      end
      else if ((TableOptions.StatsAutoRecalc = 0) and IsTag(kiSTATS_AUTO_RECALC)) then
      begin
        TableOptions.StatsAutoRecalc := ParseValue(kiSTATS_AUTO_RECALC, vaAuto, ParseInteger);
        Specifications.Add(TableOptions.StatsAutoRecalc);
      end
      else if ((TableOptions.StatsPersistent = 0) and IsTag(kiSTATS_PERSISTENT)) then
      begin
        TableOptions.StatsPersistent := ParseValue(kiSTATS_PERSISTENT, vaAuto, ParseExpr);
        Specifications.Add(TableOptions.StatsPersistent);
      end
      else if ((TableOptions.StatsSamplePages = 0) and IsTag(kiSTATS_SAMPLE_PAGES)) then
      begin
        TableOptions.StatsSamplePages := ParseValue(kiSTATS_SAMPLE_PAGES, vaAuto, ParseExpr);
        Specifications.Add(TableOptions.StatsSamplePages);
      end
      else if ((TableOptions.TablespaceIdent = 0) and IsTag(kiTABLESPACE)) then
      begin
        TableOptions.TablespaceIdent := ParseValue(kiTABLESPACE, vaAuto, ParseDbIdent);
        Specifications.Add(TableOptions.TablespaceIdent);
      end
      else if ((TableOptions.TableChecksumInt = 0) and IsTag(kiTABLE_CHECKSUM)) then
      begin
        TableOptions.TableChecksumInt := ParseValue(kiTABLE_CHECKSUM, vaAuto, ParseInteger);
        Specifications.Add(TableOptions.TableChecksumInt);
      end
      else if ((TableOptions.TransactionalInt = 0) and IsTag(kiTRANSACTIONAL)) then
      begin
        TableOptions.TransactionalInt := ParseValue(kiTRANSACTIONAL, vaAuto, ParseInteger);
        Specifications.Add(TableOptions.TransactionalInt);
      end
      else if ((TableOptions.EngineIdent = 0) and IsTag(kiTYPE) and (MySQLVersion < 50500)) then
      begin
        TableOptions.EngineIdent := ParseValue(kiTYPE, vaAuto, ParseEngineIdent);
        Specifications.Add(TableOptions.EngineIdent);
      end
      else if ((TableOptions.UnionList = 0) and IsTag(kiUNION)) then
      begin
        TableOptions.UnionList := ParseCreateTableStmtUnion();
        Specifications.Add(TableOptions.UnionList);
      end
      else
        Found2 := False;
    end;
    TableOptionFound := Specifications.Count > OldSpecificationsCount;


    if (TableOptionFound) then
      // Do nothing

    else if (IsTag(kiADD)) then
      if (not IsNextSymbol(1, ttOpenBracket)) then
        Specifications.Add(ParseCreateTableStmtDefinition(True))
      else
        Specifications.Add(ParseAlterTableStmtAddFields())
    else if (IsTag(kiALTER)) then
      Specifications.Add(ParseAlterTableStmtAlterField())
    else if (IsTag(kiCHANGE)) then
      Specifications.Add(ParseAlterTableStmtAddField(fatChange, ParseTag(kiCHANGE)))
    else if (IsTag(kiDROP)) then
      Specifications.Add(ParseAlterTableStmtDropItem())
    else if (IsTag(kiMODIFY)) then
      Specifications.Add(ParseAlterTableStmtAddField(fatModify, ParseTag(kiMODIFY)))


    else if ((Nodes.AlgorithmValue = 0) and IsTag(kiALGORITHM)) then
    begin
      Nodes.AlgorithmValue := ParseValue(kiALGORITHM, vaAuto, WordIndices(kiDEFAULT, kiINPLACE, kiCOPY));
      Specifications.Add(Nodes.AlgorithmValue);
    end
    else if ((Nodes.ConvertToCharacterSetNode = 0) and IsTag(kiCONVERT)) then
    begin
      Nodes.ConvertToCharacterSetNode := ParseAlterTableStmtConvertTo();
      Specifications.Add(Nodes.ConvertToCharacterSetNode);
    end
    else if ((Nodes.EnableKeys = 0) and IsTag(kiDISABLE, kiKEYS)) then
    begin
      Nodes.EnableKeys := ParseTag(kiDISABLE, kiKEYS);
      Specifications.Add(Nodes.EnableKeys);
    end
    else if ((Nodes.DiscardTablespaceTag = 0) and IsTag(kiDISCARD, kiTABLESPACE)) then
    begin
      Nodes.DiscardTablespaceTag := ParseTag(kiDISCARD, kiTABLESPACE);
      Specifications.Add(Nodes.DiscardTablespaceTag);
    end
    else if ((Nodes.EnableKeys = 0) and IsTag(kiENABLE, kiKEYS)) then
    begin
      Nodes.EnableKeys := ParseTag(kiENABLE, kiKEYS);
      Specifications.Add(Nodes.EnableKeys);
    end
    else if ((Nodes.ForceTag = 0) and IsTag(kiFORCE)) then
    begin
      Nodes.ForceTag := ParseTag(kiFORCE);
      Specifications.Add(Nodes.ForceTag);
    end
    else if ((Nodes.ImportTablespaceTag = 0) and IsTag(kiDISCARD, kiTABLESPACE)) then
    begin
      Nodes.ImportTablespaceTag := ParseTag(kiDISCARD, kiTABLESPACE);
      Specifications.Add(Nodes.ImportTablespaceTag);
    end
    else if ((Nodes.LockValue = 0) and IsTag(kiLOCK)) then
    begin
      Nodes.LockValue := ParseValue(kiLOCK, vaAuto, WordIndices(kiDEFAULT, kiNONE, kiSHARED, kiEXCLUSIVE));
      Specifications.Add(Nodes.LockValue);
    end
    else if ((Nodes.OrderByValue = 0) and IsTag(kiORDER, kiBY)) then
    begin
      Nodes.OrderByValue := ParseAlterTableStmtOrderBy();
      Specifications.Add(Nodes.OrderByValue);
    end
    else if ((Nodes.RenameNode = 0) and IsTag(kiRENAME, kiTO)) then
    begin
      Nodes.RenameNode := ParseValue(WordIndices(kiRENAME, kiTO), vaNo, ParseTableIdent);
      Specifications.Add(Nodes.RenameNode);
    end
    else if ((Nodes.RenameNode = 0) and IsTag(kiRENAME, kiAS)) then
    begin
      Nodes.RenameNode := ParseValue(WordIndices(kiRENAME, kiAS), vaNo, ParseTableIdent);
      Specifications.Add(Nodes.RenameNode);
    end
    else if ((Nodes.RenameNode = 0) and IsTag(kiRENAME)) then
    begin
      Nodes.RenameNode := ParseValue(kiRENAME, vaNo, ParseTableIdent);
      Specifications.Add(Nodes.RenameNode);
    end


    else if (IsTag(kiANALYZE, kiPARTITION)) then
      Specifications.Add(ParseValue(WordIndices(kiANALYZE, kiPARTITION), vaNo, ParseCreateTableStmtDefinitionPartitionNames))
    else if (IsTag(kiCHECK, kiPARTITION)) then
      Specifications.Add(ParseValue(WordIndices(kiCHECK, kiPARTITION), vaNo, ParseCreateTableStmtDefinitionPartitionNames))
    else if (IsTag(kiCOALESCE, kiPARTITION)) then
      Specifications.Add(ParseValue(WordIndices(kiCOALESCE, kiPARTITION), vaNo, ParseInteger))
    else if (IsTag(kiEXCHANGE, kiPARTITION)) then
      Specifications.Add(ParseAlterTableStmtExchangePartition())
    else if (IsTag(kiOPTIMIZE, kiPARTITION)) then
      Specifications.Add(ParseValue(WordIndices(kiOPTIMIZE, kiPARTITION), vaNo, ParseCreateTableStmtDefinitionPartitionNames))
    else if (IsTag(kiREBUILD, kiPARTITION)) then
      Specifications.Add(ParseValue(WordIndices(kiREBUILD, kiPARTITION), vaNo, ParseCreateTableStmtDefinitionPartitionNames))
    else if (IsTag(kiREMOVE, kiPARTITIONING)) then
      Specifications.Add(ParseTag(kiREMOVE, kiPARTITIONING))
    else if (IsTag(kiREORGANIZE, kiPARTITION)) then
      Specifications.Add(ParseAlterTableStmtReorganizePartition())
    else if (IsTag(kiREPAIR, kiPARTITION)) then
      Specifications.Add(ParseValue(WordIndices(kiREPAIR, kiPARTITION), vaNo, ParseCreateTableStmtDefinitionPartitionNames))
    else if (IsTag(kiTRUNCATE, kiPARTITION)) then
      Specifications.Add(ParseValue(WordIndices(kiTRUNCATE, kiPARTITION), vaNo, ParseCreateTableStmtDefinitionPartitionNames))
    else if (IsTag(kiUPGRADE, kiPARTITIONING)) then
      Specifications.Add(ParseTag(kiUPGRADE, kiPARTITIONING))
    else
      Found := False;

    if (Found) then
    begin
      Found := not ErrorFound and IsSymbol(ttComma);
      if (Found) then
      begin
        Comma := ParseSymbol(ttComma);
        if (Comma > 0) then
          Specifications.Add(Comma);
      end;
    end;
  end;

  if (not ErrorFound and Found) then
    SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
    if (IsTag(kiPARTITION, kiBY)) then
      Nodes.PartitionOptions := ParseCreateTableStmtPartitionOptions();

  FillChar(ListNodes, SizeOf(ListNodes), 0);
  Nodes.SpecificationList := TList.Create(Self, ListNodes, ttComma, @Specifications);
  Result := TAlterTableStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterTableStmtAddField(const AddType: TCreateTableStmt.TFieldAddType; const AddTag: TOffset): TOffset;
var
  Nodes: TAlterTableStmt.TAddField.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.AddTag := AddTag;

  if (not ErrorFound and (AddType <> fatNone)) then
    if (IsTag(kiCOLUMN)) then
      Nodes.ColumnTag := ParseTag(kiCOLUMN);

  if (not ErrorFound and (AddType in [fatChange])) then
    Nodes.OldIdent := ParseFieldIdent();

  if (not ErrorFound) then
    Nodes.Definition := ParseCreateTableStmtField();

  if (not ErrorFound and (AddType <> fatNone)) then
    if (IsTag(kiFIRST)) then
      Nodes.Position := ParseTag(kiFIRST)
    else if (IsTag(kiAFTER)) then
      Nodes.Position := ParseValue(kiAFTER, vaNo, ParseFieldIdent);

  Result := TAlterTableStmt.TAddField.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterTableStmtAddFields(): TOffset;
var
  Nodes: TAlterTableStmt.TAddFields.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.AddTag := ParseTag(kiADD);

  if (not ErrorFound) then
    if (IsTag(kiCOLUMN)) then
      Nodes.ColumnTag := ParseTag(kiCOLUMN);

  if (not ErrorFound) then
    Nodes.DefinitionList := ParseList(True, ParseCreateTableStmtField, ttComma, False);

  Result := TAlterTableStmt.TAddFields.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterTableStmtAlterField(): TOffset;
var
  Nodes: TAlterTableStmt.TAlterField.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiALTER)) then
    Nodes.AlterTag := ParseTag(kiALTER);

  if (not ErrorFound) then
    if (IsTag(kiCOLUMN)) then
      Nodes.ColumnTag := ParseTag(kiCOLUMN);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent(ditField, False);

  if (not ErrorFound) then
    if (IsTag(kiSET, kiDEFAULT)) then
      Nodes.SetDefaultValue := ParseValue(WordIndices(kiSET, kiDEFAULT), vaNo, ParseExpr)
    else
      Nodes.DropDefaultTag := ParseTag(kiDROP, kiDEFAULT);

  Result := TAlterTableStmt.TAlterField.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterTableStmtConvertTo(): TOffset;
var
  Nodes: TAlterTableStmt.TConvertTo.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.ConvertToTag := ParseTag(kiCONVERT, kiTO);

  if (not ErrorFound) then
    if (IsTag(kiCHARSET)) then
      Nodes.CharsetValue := ParseValue(kiCHARSET, vaNo, ParseCharsetIdent)
    else
      Nodes.CharsetValue := ParseValue(WordIndices(kiCHARACTER, kiSET), vaNo, ParseCharsetIdent);

  if (not ErrorFound) then
    if (IsTag(kiCOLLATE)) then
      Nodes.CollateValue := ParseValue(kiCOLLATE, vaNo, ParseCollateIdent);

  Result := TAlterTableStmt.TConvertTo.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterTableStmtDropItem(): TOffset;
var
  Nodes: TAlterTableStmt.TDropObject.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.DropTag := ParseTag(kiDROP);

  if (not ErrorFound) then
    if (IsTag(kiFOREIGN, kiKEY)) then
    begin
      Nodes.ItemTypeTag := ParseTag(kiFOREIGN, kiKEY);

      if (not ErrorFound) then
        Nodes.Ident := ParseForeignKeyIdent();
    end
    else if (IsTag(kiKEY)) then
    begin
      Nodes.ItemTypeTag := ParseTag(kiKEY);

      if (not ErrorFound) then
        Nodes.Ident := ParseKeyIdent();
    end
    else if (IsTag(kiINDEX)) then
    begin
      Nodes.ItemTypeTag := ParseTag(kiINDEX);

      if (not ErrorFound) then
        Nodes.Ident := ParseKeyIdent();
    end
    else if (IsTag(kiPARTITION)) then
    begin
      Nodes.ItemTypeTag := ParseTag(kiPARTITION);

      if (not ErrorFound) then
        Nodes.Ident := ParseList(False, ParsePartitionIdent);
    end
    else if (IsTag(kiPRIMARY, kiKEY)) then
      Nodes.ItemTypeTag := ParseTag(kiPRIMARY, kiKEY)
    else
    begin
      if (IsTag(kiCOLUMN)) then
        Nodes.ItemTypeTag := ParseTag(kiCOLUMN);

      if (not ErrorFound) then
        Nodes.Ident := ParseDbIdent(ditField, False);
    end;

  Result := TAlterTableStmt.TDropObject.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterTableStmtExchangePartition(): TOffset;
var
  Nodes: TAlterTableStmt.TExchangePartition.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.ExchangePartitionTag := ParseTag(kiEXCHANGE, kiPARTITION);

  if (not ErrorFound) then
    Nodes.PartitionIdent := ParsePartitionIdent();

  if (not ErrorFound) then
    Nodes.WithTableTag := ParseTag(kiWITH, kiTABLE);

  if (not ErrorFound) then
    Nodes.TableIdent := ParseTableIdent();

  if (not ErrorFound) then
    if (IsTag(kiWITH, kiVALIDATION)) then
      Nodes.WithValidationTag := ParseTag(kiWITH, kiVALIDATION)
    else if (IsTag(kiWITHOUT, kiVALIDATION)) then
      Nodes.WithValidationTag := ParseTag(kiWITHOUT, kiVALIDATION);

  Result := TAlterTableStmt.TExchangePartition.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterTableStmtOrderBy(): TOffset;
var
  Nodes: TAlterTableStmt.TOrderBy.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Tag := ParseTag(kiORDER, kiBY);

  if (not ErrorFound) then
    Nodes.List := ParseList(False, ParseCreateTableStmtKeyColumn);

  Result := TAlterTableStmt.TOrderBy.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterTableStmtReorganizePartition(): TOffset;
var
  Nodes: TAlterTableStmt.TReorganizePartition.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.ReorganizePartitionTag := ParseTag(kiREORGANIZE, kiPARTITION);

  if (not ErrorFound) then
    Nodes.IdentList := ParseList(False, ParsePartitionIdent);

  if (not ErrorFound) then
    Nodes.IntoTag := ParseTag(kiINTO);

  if (not ErrorFound) then
    Nodes.PartitionList := ParseList(True, ParseCreateTableStmtPartition);

  Result := TAlterTableStmt.TReorganizePartition.Create(Self, Nodes);
end;

function TSQLParser.ParseAlterViewStmt(const AlterTag, AlgorithmValue, DefinerValue, SQLSecurityTag: TOffset): TOffset;
var
  Nodes: TAlterViewStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.AlterTag := AlterTag;

  Nodes.AlgorithmValue := AlgorithmValue;

  Nodes.DefinerValue := DefinerValue;

  Nodes.SQLSecurityTag := SQLSecurityTag;

  if (not ErrorFound) then
    Nodes.ViewTag := ParseTag(kiVIEW);

  if (not ErrorFound) then
    Nodes.Ident := ParseTableIdent();

  if (not ErrorFound) then
    if (IsSymbol(ttOpenBracket)) then
      Nodes.Columns := ParseList(True, ParseFieldIdent);

  if (not ErrorFound) then
    Nodes.AsTag := ParseTag(kiAS);

  if (not ErrorFound) then
    Nodes.SelectStmt := ParseSelectStmt(True);

  if (not ErrorFound) then
    if (IsTag(kiWITH, kiCASCADED, kiCHECK, kiOPTION)) then
      Nodes.OptionTag := ParseTag(kiWITH, kiCASCADED, kiCHECK, kiOPTION)
    else if (IsTag(kiWITH, kiLOCAL, kiCHECK, kiOPTION)) then
      Nodes.OptionTag := ParseTag(kiWITH, kiLOCAL, kiCHECK, kiOPTION)
    else if (IsTag(kiWITH, kiCHECK, kiOPTION)) then
      Nodes.OptionTag := ParseTag(kiWITH, kiCHECK, kiOPTION);

  Result := TAlterViewStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseBeginLabel(): TOffset;
var
  Nodes: TBeginLabel.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.BeginToken := ApplyCurrentToken(utLabel);
  Nodes.ColonToken := ApplyCurrentToken(utSymbol);

  Result := TBeginLabel.Create(Self, Nodes);
end;

function TSQLParser.ParseBeginStmt(): TOffset;
var
  Nodes: TBeginStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiBEGIN, kiWORK)) then
    Nodes.BeginTag := ParseTag(kiBEGIN, kiWORK)
  else
    Nodes.BeginTag := ParseTag(kiBEGIN);

  Result := TBeginStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCallStmt(): TOffset;
var
  Nodes: TCallStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.CallTag := ParseTag(kiCALL);

  if (not ErrorFound) then
    Nodes.Ident := ParseProcedureIdent();

  if (not ErrorFound and IsSymbol(ttOpenBracket)) then
    Nodes.ParamList := ParseList(True, ParseExpr);

  Result := TCallStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCaseOp(): TOffset;
var
  Branches: TOffsetList;
  ListNodes: TList.TNodes;
  Nodes: TCaseOp.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Branches.Init();

  Nodes.CaseTag := ParseTag(kiCASE);

  if (not ErrorFound) then
    if (not IsTag(kiWHEN)) then
      Nodes.CompareExpr := ParseExpr();

  if (not ErrorFound) then
    repeat
      Branches.Add(ParseCaseOpBranch());
    until (ErrorFound or not IsTag(kiWHEN));

  FillChar(ListNodes, SizeOf(ListNodes), 0);
  Nodes.BranchList := TList.Create(Self, ListNodes, ttUnknown, @Branches);

  if (not ErrorFound) then
    if (IsTag(kiELSE)) then
    begin
      Nodes.ElseTag := ParseTag(kiELSE);

      if (not ErrorFound) then
        Nodes.ElseExpr := ParseExpr();
    end;

  if (not ErrorFound) then
    Nodes.EndTag := ParseTag(kiEND);

  Result := TCaseOp.Create(Self, Nodes);
end;

function TSQLParser.ParseCaseOpBranch(): TOffset;
var
  Nodes: TCaseOp.TBranch.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.WhenTag := ParseTag(kiWHEN);

  if (not ErrorFound) then
    Nodes.CondExpr := ParseExpr();

  if (not ErrorFound) then
    Nodes.ThenTag := ParseTag(kiTHEN);

  if (not ErrorFound) then
    Nodes.ResultExpr := ParseExpr();

  Result := TCaseOp.TBranch.Create(Self, Nodes);
end;

function TSQLParser.ParseCaseStmt(): TOffset;
var
  Branches: TOffsetList;
  ListNodes: TList.TNodes;
  Nodes: TCaseStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Branches.Init();

  Nodes.CaseTag := ParseTag(kiCASE);

  if (not ErrorFound and not IsTag(kiWHEN)) then
    Nodes.CompareExpr := ParseExpr();

  while (not ErrorFound and IsTag(kiWHEN)) do
  begin
    Branches.Add(ParseCaseStmtBranch());
  end;

  if (not ErrorFound) then
    if (IsTag(kiELSE)) then
    begin
      Branches.Add(ParseCaseStmtBranch());
    end;

  FillChar(ListNodes, SizeOf(ListNodes), 0);
  Nodes.BranchList := TList.Create(Self, ListNodes, ttUnknown, @Branches);

  if (not ErrorFound) then
    Nodes.EndTag := ParseTag(kiEND, kiCASE);

  Result := TCaseStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCaseStmtBranch(): TOffset;
var
  Nodes: TCaseStmt.TBranch.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiWHEN)) then
  begin
    Nodes.BranchTag := ParseTag(kiWHEN);

    if (not ErrorFound) then
      Nodes.ConditionExpr := ParseExpr();

    if (not ErrorFound) then
      Nodes.ThenTag := ParseTag(kiTHEN);
  end
  else if (IsTag(kiELSE)) then
    Nodes.BranchTag := ParseTag(kiELSE);

  if (not IsTag(kiWHEN)
    and not IsTag(kiELSE)
    and not IsTag(kiEND)) then
    Nodes.StmtList := ParseList(False, ParsePL_SQLStmt, ttSemicolon);

  Result := TCaseStmt.TBranch.Create(Self, Nodes);
end;

function TSQLParser.ParseCastFunc(): TOffset;
var
  Nodes: TCastFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    Nodes.Expr := ParseExpr();

  if (not ErrorFound) then
    Nodes.AsTag := ParseTag(kiAS);

  if (not ErrorFound) then
    Nodes.DatatypeIdent := ParseDatatype();

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TCastFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseCharFunc(): TOffset;
var
  Nodes: TCharFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    Nodes.ValueExpr := ParseList(False, ParseExpr);

  if (not ErrorFound) then
    if (IsTag(kiUSING)) then
    begin
      Nodes.UsingTag := ParseTag(kiUSING);

      if (not ErrorFound) then
        Nodes.CharsetIdent := ParseDbIdent();
    end;

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TCharFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseChangeMasterStmt(): TOffset;
var
  Found: Boolean;
  ListNodes: TList.TNodes;
  Nodes: TChangeMasterStmt.TNodes;
  OldCurrentToken: TOffset;
  OptionNodes: TChangeMasterStmt.TOptionNodes;
  Options: TOffsetList;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);
  FillChar(OptionNodes, SizeOf(OptionNodes), 0);

  Nodes.StmtTag := ParseTag(kiCHANGE, kiMASTER);

  if (not ErrorFound) then
    Nodes.ToTag := ParseTag(kiTO);

  Options.Init();
  Found := True; OldCurrentToken := CurrentToken;
  while (not ErrorFound and Found and not EndOfStmt(CurrentToken)) do
  begin
    if ((OptionNodes.MasterBindValue = 0) and IsTag(kiMASTER_BIND)) then
    begin
      OptionNodes.MasterBindValue := ParseValue(kiMASTER_BIND, vaYes, ParseString);
      Options.Add(OptionNodes.MasterBindValue);
    end
    else if ((OptionNodes.MasterHostValue = 0) and IsTag(kiMASTER_HOST)) then
    begin
      OptionNodes.MasterHostValue := ParseValue(kiMASTER_HOST, vaYes, ParseString);
      Options.Add(OptionNodes.MasterHostValue);
    end
    else if ((OptionNodes.MasterUserValue = 0) and IsTag(kiMASTER_USER)) then
    begin
      OptionNodes.MasterUserValue := ParseValue(kiMASTER_USER, vaYes, ParseString);
      Options.Add(OptionNodes.MasterUserValue);
    end
    else if ((OptionNodes.MasterPasswordValue = 0) and IsTag(kiMASTER_PASSWORD)) then
    begin
      OptionNodes.MasterPasswordValue := ParseValue(kiMASTER_PASSWORD, vaYes, ParseString);
      Options.Add(OptionNodes.MasterPasswordValue);
    end
    else if ((OptionNodes.MasterPortValue = 0) and IsTag(kiMASTER_PORT)) then
    begin
      OptionNodes.MasterPortValue := ParseValue(kiMASTER_PORT, vaYes, ParseInteger);
      Options.Add(OptionNodes.MasterPortValue);
    end
    else if ((OptionNodes.MasterConnectRetryValue = 0) and IsTag(kiMASTER_CONNECT_RETRY)) then
    begin
      OptionNodes.MasterConnectRetryValue := ParseValue(kiMASTER_CONNECT_RETRY, vaYes, ParseInteger);
      Options.Add(OptionNodes.MasterConnectRetryValue);
    end
    else if ((OptionNodes.MasterLogFileValue = 0) and IsTag(kiMASTER_LOG_FILE)) then
    begin
      OptionNodes.MasterLogFileValue := ParseValue(kiMASTER_LOG_FILE, vaYes, ParseString);
      Options.Add(OptionNodes.MasterLogFileValue);
    end
    else if ((OptionNodes.MasterLogPosValue = 0) and IsTag(kiMASTER_LOG_POS)) then
    begin
      OptionNodes.MasterLogPosValue := ParseValue(kiMASTER_LOG_POS, vaYes, ParseInteger);
      Options.Add(OptionNodes.MasterLogPosValue);
    end
    else if ((OptionNodes.MasterAutoPositionValue = 0) and IsTag(kiMASTER_AUTO_POSITION)) then
    begin
      OptionNodes.MasterAutoPositionValue := ParseValue(kiMASTER_AUTO_POSITION, vaYes, ParseInteger);
      Options.Add(OptionNodes.MasterAutoPositionValue);
    end
    else if ((OptionNodes.RelayLogFileValue = 0) and IsTag(kiRELAY_LOG_FILE)) then
    begin
      OptionNodes.RelayLogFileValue := ParseValue(kiRELAY_LOG_FILE, vaYes, ParseString);
      Options.Add(OptionNodes.RelayLogFileValue);
    end
    else if ((OptionNodes.RelayLogPosValue = 0) and IsTag(kiRELAY_LOG_POS)) then
    begin
      OptionNodes.RelayLogPosValue := ParseValue(kiRELAY_LOG_POS, vaYes, ParseInteger);
      Options.Add(OptionNodes.RelayLogPosValue);
    end
    else if ((OptionNodes.MasterSSLValue = 0) and IsTag(kiMASTER_SSL)) then
    begin
      OptionNodes.MasterSSLValue := ParseValue(kiMASTER_SSL, vaYes, ParseInteger);
      Options.Add(OptionNodes.MasterSSLValue);
    end
    else if ((OptionNodes.MasterSSLCAValue = 0) and IsTag(kiMASTER_SSL_CA)) then
    begin
      OptionNodes.MasterSSLCAValue := ParseValue(kiMASTER_SSL_CA, vaYes, ParseString);
      Options.Add(OptionNodes.MasterSSLCAValue);
    end
    else if ((OptionNodes.MasterSSLCaPathValue = 0) and IsTag(kiMASTER_SSL_CAPATH)) then
    begin
      OptionNodes.MasterSSLCaPathValue := ParseValue(kiMASTER_SSL_CAPATH, vaYes, ParseString);
      Options.Add(OptionNodes.MasterSSLCaPathValue);
    end
    else if ((OptionNodes.MasterSSLCertValue = 0) and IsTag(kiMASTER_SSL_CERT)) then
    begin
      OptionNodes.MasterSSLCertValue := ParseValue(kiMASTER_SSL_CERT, vaYes, ParseString);
      Options.Add(OptionNodes.MasterSSLCertValue);
    end
    else if ((OptionNodes.MasterSSLCRLValue = 0) and IsTag(kiMASTER_SSL_CRL)) then
    begin
      OptionNodes.MasterSSLCRLValue := ParseValue(kiMASTER_SSL_CRL, vaYes, ParseString);
      Options.Add(OptionNodes.MasterSSLCRLValue);
    end
    else if ((OptionNodes.MasterSSLCRLPathValue = 0) and IsTag(kiMASTER_SSL_CRLPATH)) then
    begin
      OptionNodes.MasterSSLCRLPathValue := ParseValue(kiMASTER_SSL_CRLPATH, vaYes, ParseString);
      Options.Add(OptionNodes.MasterSSLCRLPathValue);
    end
    else if ((OptionNodes.MasterSSLKeyValue = 0) and IsTag(kiMASTER_SSL_KEY)) then
    begin
      OptionNodes.MasterSSLKeyValue := ParseValue(kiMASTER_SSL_KEY, vaYes, ParseString);
      Options.Add(OptionNodes.MasterSSLKeyValue);
    end
    else if ((OptionNodes.MasterSSLCipherValue = 0) and IsTag(kiMASTER_SSL_CIPHER)) then
    begin
      OptionNodes.MasterSSLCipherValue := ParseValue(kiMASTER_SSL_CIPHER, vaYes, ParseString);
      Options.Add(OptionNodes.MasterSSLCipherValue);
    end
    else if ((OptionNodes.MasterSSLVerifyServerCertValue = 0) and IsTag(kiMASTER_SSL_VERIFY_SERVER_CERT)) then
    begin
      OptionNodes.MasterSSLVerifyServerCertValue := ParseValue(kiMASTER_SSL_VERIFY_SERVER_CERT, vaYes, ParseInteger);
      Options.Add(OptionNodes.MasterSSLVerifyServerCertValue);
    end
    else if ((OptionNodes.MasterTLSVersionValue = 0) and IsTag(kiMASTER_TLS_VERSION)) then
    begin
      OptionNodes.MasterTLSVersionValue := ParseValue(kiMASTER_TLS_VERSION, vaYes, ParseString);
      Options.Add(OptionNodes.MasterTLSVersionValue);
    end
    else if ((OptionNodes.IgnoreServerIDsValue = 0) and IsTag(kiIGNORE_SERVER_IDS)) then
    begin
      OptionNodes.IgnoreServerIDsValue := ParseValue(kiIGNORE_SERVER_IDS, vaYes, ParseString);
      Options.Add(OptionNodes.IgnoreServerIDsValue);
    end
    else
      Found := False;

    if (Found) then
    begin
      Found := IsSymbol(ttComma);
      if (Found) then
        Options.Add(ParseSymbol(ttComma));
    end;
  end;

  if (not ErrorFound and (CurrentToken = OldCurrentToken)) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  FillChar(ListNodes, SizeOf(ListNodes), 0);
  Nodes.OptionList := TList.Create(Self, ListNodes, ttComma, @Options);

  if (not ErrorFound and IsTag(kiFOR, kiCHANNEL)) then
    Nodes.ChannelOptionValue := ParseValue(WordIndices(kiFOR, kiCHANNEL), vaNo, ParseDbIdent);

  Result := TChangeMasterStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCharsetIdent(): TOffset;
begin
  Result := ParseDbIdent(ditCharset);
end;

function TSQLParser.ParseCheckTableStmt(): TOffset;
var
  Found: Boolean;
  Nodes: TCheckTableStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiCHECK, kiTABLE);

  if (not ErrorFound) then
    Nodes.TablesList := ParseList(False, ParseTableIdent);

  Found := True;
  while (not ErrorFound and Found) do
  begin
    if ((Nodes.ForUpdateTag = 0) and IsTag(kiFOR, kiUPGRADE)) then
      Nodes.ForUpdateTag := ParseTag(kiFOR, kiUPGRADE)
    else if ((Nodes.QuickTag = 0) and IsTag(kiQUICK)) then
      Nodes.QuickTag := ParseTag(kiQUICK)
    else if ((Nodes.FastTag = 0) and IsTag(kiFAST)) then
      Nodes.FastTag := ParseTag(kiFAST)
    else if ((Nodes.MediumTag = 0) and IsTag(kiMEDIUM)) then
      Nodes.MediumTag := ParseTag(kiMEDIUM)
    else if ((Nodes.ExtendedTag = 0) and IsTag(kiEXTENDED)) then
      Nodes.ExtendedTag := ParseTag(kiEXTENDED)
    else if ((Nodes.ChangedTag = 0) and IsTag(kiCHANGED)) then
      Nodes.ChangedTag := ParseTag(kiCHANGED)
    else
      Found := False;
  end;

  Result := TCheckTableStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseChecksumTableStmt(): TOffset;
var
  Nodes: TChecksumTableStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiCHECKSUM, kiTABLE);

  if (not ErrorFound) then
    Nodes.TablesList := ParseList(False, ParseTableIdent);

  if (not ErrorFound) then
    if (IsTag(kiQUICK)) then
      Nodes.OptionTag := ParseTag(kiQUICK)
    else if (IsTag(kiEXTENDED)) then
      Nodes.OptionTag := ParseTag(kiEXTENDED);

  Result := TChecksumTableStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCloseStmt(): TOffset;
var
  Nodes: TCloseStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiCLOSE);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent(ditCursor, False);

  Result := TCloseStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCollateIdent(): TOffset;
begin
  Result := ParseDbIdent(ditCollation);
end;

function TSQLParser.ParseColumnAliasIdent(): TOffset;
begin
  Result := ParseDbIdent(ditColumnAlias);
end;

function TSQLParser.ParseCommitStmt(): TOffset;
var
  Nodes: TCommitStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiCOMMIT, kiWORK)) then
    Nodes.StmtTag := ParseTag(kiCOMMIT, kiWORK)
  else
    Nodes.StmtTag := ParseTag(kiCOMMIT);

  if (not ErrorFound) then
    if (IsTag(kiAND, kiNO, kiCHAIN)) then
      Nodes.ChainTag := ParseTag(kiAND, kiNO, kiCHAIN)
    else if (IsTag(kiAND, kiCHAIN)) then
      Nodes.ChainTag := ParseTag(kiAND, kiCHAIN);

  if (not ErrorFound) then
    if (IsTag(kiNO, kiRELEASE)) then
      Nodes.ReleaseTag := ParseTag(kiNO, kiRELEASE)
    else if (IsTag(kiRELEASE)) then
      Nodes.ReleaseTag := ParseTag(kiRELEASE);

  Result := TCommitStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCompoundStmt(const BeginLabel: TOffset = 0): TOffset;
var
  Nodes: TCompoundStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Inc(FInCompound);

  Nodes.BeginLabel := BeginLabel;

  if (not ErrorFound) then
    Nodes.BeginTag := ParseTag(kiBEGIN);

  if (not ErrorFound) then
    if (not IsTag(kiEND)) then
      Nodes.StmtList := ParseList(False, ParsePL_SQLStmt, ttSemicolon);

  if (not ErrorFound) then
    Nodes.EndTag := ParseTag(kiEND);

  if (not ErrorFound
    and not EndOfStmt(CurrentToken) and (TokenPtr(CurrentToken)^.TokenType = ttIdent)
    and (Nodes.BeginLabel > 0) and (NodePtr(Nodes.BeginLabel)^.NodeType = ntBeginLabel)) then
    if ((Nodes.BeginLabel = 0) or (lstrcmpi(PChar(TokenPtr(CurrentToken)^.AsString), PChar(PBeginLabel(NodePtr(Nodes.BeginLabel))^.LabelName)) <> 0)) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.EndLabel := ParseEndLabel();

  Dec(FInCompound);

  Result := TCompoundStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseConstIdent(): TOffset;
begin
  Result := ParseDbIdent(ditConstante, False);
end;

function TSQLParser.ParseConvertFunc(): TOffset;
var
  Nodes: TConvertFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    Nodes.Expr := ParseExpr();

  if (not ErrorFound) then
    if (IsSymbol(ttComma)) then
    begin
      Nodes.Comma := ParseSymbol(ttComma);

      if (not ErrorFound) then
        Nodes.Datatype := ParseDatatype();
    end
    else if (IsTag(kiUSING)) then
    begin
      Nodes.UsingTag := ParseTag(kiUSING);

      if (not ErrorFound) then
        Nodes.CharsetIdent := ParseCharsetIdent();
    end
    else
      SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TConvertFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseCountFunc(): TOffset;
var
  Nodes: TCountFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    if (IsTag(kiDISTINCT)) then
    begin
      Nodes.DistinctTag := ParseTag(kiDISTINCT);

      if (not ErrorFound) then
        Nodes.ExprNode := ParseList(False, ParseExpr, ttComma, False);
    end
    else
      Nodes.ExprNode := ParseExpr([eoIn, eoAllFields, eoOperators]);

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TCountFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateDatabaseStmt(const CreateTag, OrReplaceTag: TOffset): TOffset;
var
  Found: Boolean;
  Nodes: TCreateDatabaseStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.CreateTag := CreateTag;

  if (IsTag(kiDATABASE)) then
    Nodes.DatabaseTag := ParseTag(kiDATABASE)
  else
    Nodes.DatabaseTag := ParseTag(kiSCHEMA);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiNOT, kiEXISTS)) then
      Nodes.IfNotExistsTag := ParseTag(kiIF, kiNOT, kiEXISTS);

  if (not ErrorFound) then
    Nodes.DatabaseIdent := ParseDatabaseIdent();

  Found := True;
  while (not ErrorFound and Found) do
    if ((Nodes.CharacterSetValue = 0) and IsTag(kiCHARACTER, kiSET)) then
      Nodes.CharacterSetValue := ParseValue(WordIndices(kiCHARACTER, kiSET), vaAuto, ParseCharsetIdent)
    else if ((Nodes.CharacterSetValue = 0) and IsTag(kiCHARSET)) then
      Nodes.CharacterSetValue := ParseValue(WordIndices(kiCHARSET), vaAuto, ParseCharsetIdent)
    else if ((Nodes.CollateValue = 0) and IsTag(kiCOLLATE)) then
      Nodes.CollateValue := ParseValue(kiCOLLATE, vaAuto, ParseCollateIdent)
    else if ((Nodes.CollateValue = 0) and IsTag(kiDEFAULT, kiCHARACTER, kiSET)) then
      Nodes.CharacterSetValue := ParseValue(WordIndices(kiDEFAULT, kiCHARACTER, kiSET), vaAuto, ParseCharsetIdent)
    else if ((Nodes.CollateValue = 0) and IsTag(kiDEFAULT, kiCHARSET)) then
      Nodes.CharacterSetValue := ParseValue(WordIndices(kiDEFAULT, kiCHARSET), vaAuto, ParseCharsetIdent)
    else if ((Nodes.CollateValue = 0) and IsTag(kiDEFAULT, kiCOLLATE)) then
      Nodes.CollateValue := ParseValue(WordIndices(kiDEFAULT, kiCOLLATE), vaAuto, ParseCollateIdent)
    else
      Found := False;

  Result := TCreateDatabaseStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateEventStmt(const CreateTag, OrReplaceTag, DefinerValue: TOffset): TOffset;
var
  Nodes: TCreateEventStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.CreateTag := CreateTag;

  Nodes.DefinerValue := DefinerValue;

  Nodes.EventTag := ParseTag(kiEVENT);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiNOT, kiEXISTS)) then
      Nodes.IfNotExistsTag := ParseTag(kiIF, kiNOT, kiEXISTS);

  if (not ErrorFound) then
    Nodes.EventIdent := ParseEventIdent();

  if (not ErrorFound) then
    Nodes.OnScheduleValue := ParseValue(WordIndices(kiON, kiSCHEDULE), vaNo, ParseSchedule);

  if (not ErrorFound) then
    if (IsTag(kiON, kiCOMPLETION, kiNOT, kiPRESERVE)) then
      Nodes.OnCompletitionTag := ParseTag(kiON, kiCOMPLETION, kiNOT, kiPRESERVE)
    else if (IsTag(kiON, kiCOMPLETION, kiPRESERVE)) then
      Nodes.OnCompletitionTag := ParseTag(kiON, kiCOMPLETION, kiPRESERVE);

  if (not ErrorFound) then
    if (IsTag(kiENABLE)) then
      Nodes.EnableTag := ParseTag(kiENABLE)
    else if (IsTag(kiDISABLE, kiON, kiSLAVE)) then
      Nodes.EnableTag := ParseTag(kiDISABLE, kiON, kiSLAVE)
    else if (IsTag(kiDISABLE)) then
      Nodes.EnableTag := ParseTag(kiDISABLE);

  if (not ErrorFound) then
    if (IsTag(kiCOMMENT)) then
      Nodes.CommentValue := ParseValue(kiCOMMENT, vaNo, ParseString);

  if (not ErrorFound) then
    Nodes.DoTag := ParseTag(kiDO);

  if (not ErrorFound) then
  begin
    Parse.InCreateEventStmt := True;
    Nodes.Stmt := ParsePL_SQLStmt();
    Parse.InCreateEventStmt := False;
    if (not ErrorFound and (Nodes.Stmt = 0)) then
      SetError(PE_IncompleteStmt);
  end;

  Result := TCreateEventStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateIndexStmt(const CreateTag, OrReplaceTag, KindTag: TOffset): TOffset;
var
  Found: Boolean;
  Nodes: TCreateIndexStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.CreateTag := CreateTag;

  Nodes.OrReplaceTag := OrReplaceTag;

  Nodes.KindTag := KindTag;

  Nodes.IndexTag := ParseTag(kiINDEX);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiNOT, kiEXISTS)) then
      Nodes.IfNotExistsTag := ParseTag(kiIF, kiNOT, kiEXISTS);

  Nodes.Ident := ParseKeyIdent();

  if (not ErrorFound) then
    if (IsTag(kiUSING, kiBTREE)) then
      Nodes.IndexTypeValue := ParseTag(kiUSING, kiBTREE)
    else if (IsTag(kiUSING, kiHASH)) then
      Nodes.IndexTypeValue := ParseTag(kiUSING, kiHASH);

  if (not ErrorFound) then
    Nodes.OnTag := ParseTag(kiON);

  if (not ErrorFound) then
    Nodes.TableIdent := ParseTableIdent();

  if (not ErrorFound) then
    Nodes.KeyColumnList := ParseList(True, ParseCreateTableStmtKeyColumn);

  Found := True;
  while (not ErrorFound and Found) do
    if ((Nodes.AlgorithmLockValue = 0) and IsTag(kiALGORITHM)) then
      Nodes.AlgorithmLockValue := ParseValue(kiALGORITHM, vaAuto, WordIndices(kiDEFAULT, kiINPLACE, kiCOPY))
    else if ((Nodes.CommentValue = 0) and IsTag(kiCOMMENT)) then
      Nodes.CommentValue := ParseValue(kiCOMMENT, vaAuto, ParseString)
    else if ((Nodes.KeyBlockSizeValue = 0) and IsTag(kiKEY_BLOCK_SIZE)) then
      Nodes.KeyBlockSizeValue := ParseValue(kiKEY_BLOCK_SIZE, vaAuto, ParseInteger)
    else if ((Nodes.AlgorithmLockValue = 0) and IsTag(kiLOCK)) then
      Nodes.AlgorithmLockValue := ParseValue(kiLOCK, vaAuto, WordIndices(kiDEFAULT, kiNONE, kiSHARED, kiEXCLUSIVE))
    else if ((Nodes.IndexTypeValue = 0) and IsTag(kiUSING, kiBTREE)) then
      Nodes.IndexTypeValue := ParseTag(kiUSING, kiBTREE)
    else if ((Nodes.IndexTypeValue = 0) and IsTag(kiUSING, kiHASH)) then
      Nodes.IndexTypeValue := ParseTag(kiUSING, kiHASH)
    else if ((Nodes.ParserValue = 0) and IsTag(kiWITH, kiPARSER)) then
      Nodes.ParserValue := ParseValue(WordIndices(kiWITH, kiPARSER), vaNo, ParseDbIdent)
    else
      Found := False;

  Result := TCreateIndexStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateRoutineStmt(const ARoutineType: TRoutineType; const CreateTag, OrReplaceTag, DefinerValue: TOffset): TOffset;
var
  Found: Boolean;
  Nodes: TCreateRoutineStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.CreateTag := CreateTag;

  Nodes.OrReplaceTag := OrReplaceTag;

  Nodes.DefinerNode := DefinerValue;

  if (ARoutineType = rtProcedure) then
    Nodes.RoutineTag := ParseTag(kiPROCEDURE)
  else
    Nodes.RoutineTag := ParseTag(kiFUNCTION);

  if (not ErrorFound) then
    if (ARoutineType = rtProcedure) then
      Nodes.Ident := ParseProcedureIdent()
    else
      Nodes.Ident := ParseFunctionIdent();

  if (not ErrorFound) then
    if (not IsSymbol(ttCloseBracket)) then
      if (ARoutineType = rtProcedure) then
        Nodes.ParameterList := ParseList(True, ParseProcedureParam)
      else
        Nodes.ParameterList := ParseList(True, ParseFunctionParam);

  if (not ErrorFound and (ARoutineType = rtFunction)) then
    Nodes.Returns := ParseFunctionReturns();

  Found := True;
  while (not ErrorFound and Found) do
    if ((Nodes.CommentValue = 0) and IsTag(kiCOMMENT)) then
      Nodes.CommentValue := ParseValue(kiComment, vaNo, ParseString)
    else if ((Nodes.LanguageTag = 0) and IsTag(kiLANGUAGE, kiSQL)) then
      Nodes.LanguageTag := ParseTag(kiLANGUAGE, kiSQL)
    else if ((Nodes.DeterministicTag = 0) and IsTag(kiDETERMINISTIC)) then
      Nodes.DeterministicTag := ParseTag(kiDETERMINISTIC)
    else if ((Nodes.DeterministicTag = 0) and IsTag(kiNOT, kiDETERMINISTIC)) then
      Nodes.DeterministicTag := ParseTag(kiNOT, kiDETERMINISTIC)
    else if ((Nodes.NatureOfDataTag = 0) and IsTag(kiCONTAINS, kiSQL)) then
      Nodes.NatureOfDataTag := ParseTag(kiCONTAINS, kiSQL)
    else if ((Nodes.NatureOfDataTag = 0) and IsTag(kiNO, kiSQL)) then
      Nodes.NatureOfDataTag := ParseTag(kiNO, kiSQL)
    else if ((Nodes.NatureOfDataTag = 0) and IsTag(kiREADS, kiSQL, kiDATA)) then
      Nodes.NatureOfDataTag := ParseTag(kiREADS, kiSQL, kiDATA)
    else if ((Nodes.NatureOfDataTag = 0) and IsTag(kiMODIFIES, kiSQL, kiDATA)) then
      Nodes.NatureOfDataTag := ParseTag(kiMODIFIES, kiSQL, kiDATA)
    else if ((Nodes.SQLSecurityTag = 0) and IsTag(kiSQL, kiSECURITY, kiDEFINER)) then
      Nodes.SQLSecurityTag := ParseTag(kiSQL, kiSECURITY, kiDEFINER)
    else if ((Nodes.SQLSecurityTag = 0) and IsTag(kiSQL, kiSECURITY, kiINVOKER)) then
      Nodes.SQLSecurityTag := ParseTag(kiSQL, kiSECURITY, kiINVOKER)
    else
      Found := False;

  if (not ErrorFound) then
  begin
    Parse.InCreateProcedureStmt := ARoutineType = rtProcedure;
    Parse.InCreateFunctionStmt := ARoutineType = rtFunction;
    Nodes.Stmt := ParsePL_SQLStmt();
    Parse.InCreateFunctionStmt := False;
    Parse.InCreateProcedureStmt := False;
    if (not ErrorFound and (Nodes.Stmt = 0)) then
      SetError(PE_IncompleteStmt);
  end;

  Result := TCreateRoutineStmt.Create(Self, ARoutineType, Nodes);
end;

function TSQLParser.ParseCreateServerStmt(const CreateTag: TOffset): TOffset;
var
  Nodes: TCreateServerStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.CreateTag := CreateTag;

  Nodes.ServerTag := ParseTag(kiSERVER);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent();

  if (not ErrorFound) then
    Nodes.ForeignDataWrapperValue := ParseValue(WordIndices(kiFOREIGN, kiDATA, kiWRAPPER), vaNo, ParseString);

  if (not ErrorFound) then
    Nodes.Options.Tag := ParseTag(kiOPTIONS);

  if (not ErrorFound) then
    Nodes.Options.List := ParseCreateServerStmtOptionList();

  Result := TCreateServerStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateServerStmtOptionList(): TOffset;
var
  Children: TOffsetList;
  Found: Boolean;
  ListNodes: TList.TNodes;
  Nodes: record
    DatabaseValue: TOffset;
    HostValue: TOffset;
    OwnerValue: TOffset;
    PasswordValue: TOffset;
    PortValue: TOffset;
    SocketValue: TOffset;
    UserValue: TOffset;
  end;
  OldCurrentToken: TOffset;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);
  FillChar(ListNodes, SizeOf(ListNodes), 0);

  Children.Init();

  ListNodes.OpenBracket := ParseSymbol(ttOpenBracket);

  Found := True; OldCurrentToken := CurrentToken;
  while (not ErrorFound and Found) do
  begin
    if ((Nodes.HostValue = 0) and IsTag(kiHOST)) then
    begin
      Nodes.HostValue := ParseValue(kiHOST, vaNo, ParseString);
      Children.Add(Nodes.HostValue);
    end
    else if ((Nodes.DatabaseValue = 0) and IsTag(kiDATABASE)) then
    begin
      Nodes.DatabaseValue := ParseValue(kiDATABASE, vaNo, ParseString);
      Children.Add(Nodes.DatabaseValue);
    end
    else if ((Nodes.UserValue = 0) and IsTag(kiUSER)) then
    begin
      Nodes.UserValue := ParseValue(kiUSER, vaNo, ParseString);
      Children.Add(Nodes.UserValue);
    end
    else if ((Nodes.PasswordValue = 0) and IsTag(kiPASSWORD)) then
    begin
      Nodes.PasswordValue := ParseValue(kiPASSWORD, vaNo, ParseString);
      Children.Add(Nodes.PasswordValue);
    end
    else if ((Nodes.SocketValue = 0) and IsTag(kiSOCKET)) then
    begin
      Nodes.SocketValue := ParseValue(kiSOCKET, vaNo, ParseString);
      Children.Add(Nodes.SocketValue);
    end
    else if ((Nodes.OwnerValue = 0) and IsTag(kiOWNER)) then
    begin
      Nodes.OwnerValue := ParseValue(kiOWNER, vaNo, ParseString);
      Children.Add(Nodes.OwnerValue);
    end
    else if ((Nodes.PortValue = 0) and IsTag(kiPORT)) then
    begin
      Nodes.PortValue := ParseValue(kiPort, vaNo, ParseInteger);
      Children.Add(Nodes.PortValue);
    end
    else
      Found := False;

    if (Found) then
    begin
      Found := IsSymbol(ttComma);
      if (Found) then
        Children.Add(ParseSymbol(ttComma));
    end;
  end;

  if (CurrentToken = OldCurrentToken) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
    ListNodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TList.Create(Self, ListNodes, ttComma, @Children);
end;

function TSQLParser.ParseCreateStmt(): TOffset;
var
  AlgorithmValue: TOffset;
  CreateTag: TOffset;
  DefinerValue: TOffset;
  KindTag: TOffset;
  OrReplaceTag: TOffset;
  SQLSecurityTag: TOffset;
  TemporaryTag: TOffset;
begin
  AlgorithmValue := 0;
  DefinerValue := 0;
  KindTag := 0;
  OrReplaceTag := 0;
  SQLSecurityTag := 0;
  TemporaryTag := 0;

  CreateTag := ParseTag(kiCREATE);

  if (not ErrorFound) then
    if (IsTag(kiOR, kiREPLACE)) then
      OrReplaceTag := ParseTag(kiOR, kiREPLACE);

  if (not ErrorFound) then
    if (IsTag(kiALGORITHM)) then
      AlgorithmValue := ParseValue(kiALGORITHM, vaYes, WordIndices(kiUNDEFINED, kiMERGE, kiTEMPTABLE));

  if (not ErrorFound) then
    if (IsTag(kiDEFINER)) then
      DefinerValue := ParseDefinerValue();

  if (not ErrorFound) then
    if (IsTag(kiSQL, kiSECURITY, kiDEFINER)) then
      SQLSecurityTag := ParseTag(kiSQL, kiSECURITY, kiDEFINER)
    else if (IsTag(kiSQL, kiSECURITY, kiINVOKER)) then
      SQLSecurityTag := ParseTag(kiSQL, kiSECURITY, kiINVOKER);

  if (not ErrorFound and (OrReplaceTag = 0) and (AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0)) then
    if (IsTag(kiTEMPORARY)) then
      TemporaryTag := ParseTag(kiTEMPORARY);

  if (not ErrorFound and (OrReplaceTag = 0) and (AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (TemporaryTag = 0)) then
    if (IsTag(kiUNIQUE)) then
      KindTag := ParseTag(kiUNIQUE)
    else if (IsTag(kiUNIQUE)) then
      KindTag := ParseTag(kiUNIQUE)
    else if (IsTag(kiFULLTEXT)) then
      KindTag := ParseTag(kiFULLTEXT)
    else if (IsTag(kiSPATIAL)) then
      KindTag := ParseTag(kiSPATIAL);

  if (ErrorFound) then
    Result := 0
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (TemporaryTag = 0) and (KindTag = 0)
    and IsTag(kiDATABASE)) then
    Result := ParseCreateDatabaseStmt(CreateTag, OrReplaceTag)
  else if ((AlgorithmValue = 0) and (SQLSecurityTag = 0) and (TemporaryTag = 0) and (KindTag = 0)
    and IsTag(kiEVENT)) then
    if (Parse.InCreateEventStmt or Parse.InCreateFunctionStmt or Parse.InCreateProcedureStmt or Parse.InCreateTriggerStmt) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseCreateEventStmt(CreateTag, OrReplaceTag, DefinerValue)
  else if ((AlgorithmValue = 0) and (SQLSecurityTag = 0) and (TemporaryTag = 0) and (KindTag = 0)
    and IsTag(kiFUNCTION)) then
    if (Parse.InCreateEventStmt or Parse.InCreateFunctionStmt or Parse.InCreateProcedureStmt or Parse.InCreateTriggerStmt) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseCreateRoutineStmt(rtFunction, CreateTag, OrReplaceTag, DefinerValue)
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (TemporaryTag = 0)
    and IsTag(kiINDEX)) then
    Result := ParseCreateIndexStmt(CreateTag, OrReplaceTag, KindTag)
  else if ((AlgorithmValue = 0) and (SQLSecurityTag = 0) and (TemporaryTag = 0) and (KindTag = 0)
    and IsTag(kiPROCEDURE)) then
    if (Parse.InCreateEventStmt or Parse.InCreateFunctionStmt or Parse.InCreateProcedureStmt or Parse.InCreateTriggerStmt) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseCreateRoutineStmt(rtProcedure, CreateTag, OrReplaceTag, DefinerValue)
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (TemporaryTag = 0) and (KindTag = 0)
    and IsTag(kiSCHEMA)) then
    Result := ParseCreateDatabaseStmt(CreateTag, OrReplaceTag)
  else if ((OrReplaceTag = 0) and (AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (TemporaryTag = 0) and (KindTag = 0)
    and IsTag(kiSERVER)) then
    Result := ParseCreateServerStmt(CreateTag)
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (KindTag = 0)
    and IsTag(kiTABLE)) then
    Result := ParseCreateTableStmt(CreateTag, OrReplaceTag, TemporaryTag)
  else if ((OrReplaceTag = 0) and (AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (TemporaryTag = 0) and (KindTag = 0)
    and IsTag(kiTABLESPACE)) then
    Result := ParseCreateTablespaceStmt(CreateTag)
  else if ((AlgorithmValue = 0) and (SQLSecurityTag = 0) and (TemporaryTag = 0) and (KindTag = 0)
    and IsTag(kiTRIGGER)) then
    if (Parse.InCreateEventStmt or Parse.InCreateFunctionStmt or Parse.InCreateProcedureStmt or Parse.InCreateTriggerStmt) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseCreateTriggerStmt(CreateTag, OrReplaceTag, DefinerValue)
  else if ((AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (TemporaryTag = 0) and (KindTag = 0)
    and IsTag(kiUSER)) then
    Result := ParseCreateUserStmt(CreateTag, OrReplaceTag)
  else if ((TemporaryTag = 0) and (KindTag = 0)
    and IsTag(kiVIEW)) then
    Result := ParseCreateViewStmt(CreateTag, OrReplaceTag, AlgorithmValue, DefinerValue, SQLSecurityTag)
  else if ((OrReplaceTag = 0) and (AlgorithmValue = 0) and (DefinerValue = 0) and (SQLSecurityTag = 0) and (TemporaryTag = 0) and (KindTag = 0)
    and EndOfStmt(CurrentToken)) then
    Result := SetError(PE_IncompleteStmt)
  else
    Result := SetError(PE_UnexpectedToken);
end;

function TSQLParser.ParseCreateTablespaceStmt(const CreateTag: TOffset): TOffset;
var
  Nodes: TCreateTablespaceStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.CreateTag := CreateTag;

  Nodes.TablespaceTag := ParseTag(kiTABLESPACE);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent();

  if (not ErrorFound) then
    Nodes.AddDatafileValue := ParseValue(WordIndices(kiADD, kiDATAFILE), vaNo, ParseString);

  if (not ErrorFound) then
    if (IsTag(kiFILE_BLOCK_SIZE)) then
      Nodes.FileBlockSizeValue := ParseValue(kiFILE_BLOCK_SIZE, vaAuto, ParseInteger);

  if (not ErrorFound) then
    if (IsTag(kiENGINE)) then
      Nodes.EngineValue := ParseValue(kiENGINE, vaAuto, ParseEngineIdent);

  Result := TCreateTablespaceStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateTableStmt(const CreateTag, OrReplaceTag, TemporaryTag: TOffset): TOffset;
var
  DelimiterFound: Boolean;
  Found: Boolean;
  ListNodes: TList.TNodes;
  Nodes: TCreateTableStmt.TNodes;
  Options: TOffsetList;
  TableOptions: TTableOptionNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.CreateTag := CreateTag;

  Nodes.OrReplaceTag := OrReplaceTag;

  Nodes.TemporaryTag := TemporaryTag;

  Nodes.TableTag := ParseTag(kiTABLE);

  if (not ErrorFound) then
    if (IsTag(kiIF)) then
      Nodes.IfNotExistsTag := ParseTag(kiIF, kiNOT, kiEXISTS);

  if (not ErrorFound) then
    Nodes.TableIdent := ParseTableIdent();

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
    begin
      Nodes.Like.Tag := ParseTag(kiLIKE);

      if (not ErrorFound) then
        Nodes.Like.TableIdent := ParseTableIdent();
    end
    else if (IsSymbol(ttOpenBracket) and IsNextTag(1, kiLIKE)) then
    begin
      Nodes.Like.OpenBracket := ParseSymbol(ttOpenBracket);

      if (not ErrorFound) then
        Nodes.Like.Tag := ParseTag(kiLIKE);

      if (not ErrorFound) then
        Nodes.Like.TableIdent := ParseTableIdent();

      if (not ErrorFound) then
        Nodes.Like.CloseBracket := ParseSymbol(ttCloseBracket);
    end
    else if (IsSymbol(ttOpenBracket) and IsNextTag(1, kiSELECT)) then
    begin
      // Where is this format definied in the manual???
      SetError(PE_UnexpectedToken, NextToken[1]);
    end
    else if (IsSymbol(ttOpenBracket)) then
    begin
      Nodes.DefinitionList := ParseList(True, ParseCreateTableStmtDefinition, ttComma, False);
    end;

  if (not ErrorFound and (Nodes.Like.Tag = 0)) then
  begin
    FillChar(TableOptions, SizeOf(TableOptions), 0);
    Options.Init();

    Found := True; DelimiterFound := False;
    while (not ErrorFound and Found) do
    begin
      if ((TableOptions.AutoIncrementValue = 0) and IsTag(kiAUTO_INCREMENT)) then
      begin
        TableOptions.AutoIncrementValue := ParseValue(kiAUTO_INCREMENT, vaAuto, ParseInteger);
        Options.Add(TableOptions.AutoIncrementValue);
      end
      else if ((TableOptions.AvgRowLengthValue = 0) and IsTag(kiAVG_ROW_LENGTH)) then
      begin
        TableOptions.AvgRowLengthValue := ParseValue(kiAVG_ROW_LENGTH, vaAuto, ParseInteger);
        Options.Add(TableOptions.AvgRowLengthValue);
      end
      else if ((TableOptions.CharacterSetValue = 0) and IsTag(kiCHARACTER, kiSET)) then
      begin
        TableOptions.CharacterSetValue := ParseValue(WordIndices(kiCHARACTER, kiSET), vaAuto, ParseCharsetIdent);
        Options.Add(TableOptions.CharacterSetValue);
      end
      else if ((TableOptions.CharacterSetValue = 0) and IsTag(kiCHARSET)) then
      begin
        TableOptions.CharacterSetValue := ParseValue(kiCHARSET, vaAuto, ParseCharsetIdent);
        Options.Add(TableOptions.CharacterSetValue);
      end
      else if ((TableOptions.ChecksumValue = 0) and IsTag(kiCHECKSUM)) then
      begin
        TableOptions.ChecksumValue := ParseValue(kiCHECKSUM, vaAuto, ParseInteger);
        Options.Add(TableOptions.ChecksumValue);
      end
      else if ((TableOptions.CollateValue = 0) and IsTag(kiCOLLATE)) then
      begin
        TableOptions.CollateValue := ParseValue(kiCOLLATE, vaAuto, ParseCollateIdent);
        Options.Add(TableOptions.CollateValue);
      end
      else if ((TableOptions.CharacterSetValue = 0) and IsTag(kiDEFAULT, kiCHARSET)) then
      begin
        TableOptions.CharacterSetValue := ParseValue(WordIndices(kiDEFAULT, kiCHARSET), vaAuto, ParseCharsetIdent);
        Options.Add(TableOptions.CharacterSetValue);
      end
      else if ((TableOptions.CharacterSetValue = 0) and IsTag(kiDEFAULT, kiCHARACTER, kiSET)) then
      begin
        TableOptions.CharacterSetValue := ParseValue(WordIndices(kiDEFAULT, kiCHARACTER, kiSET), vaAuto, ParseCharsetIdent);
        Options.Add(TableOptions.CharacterSetValue);
      end
      else if ((TableOptions.CollateValue = 0) and IsTag(kiDEFAULT, kiCOLLATE)) then
      begin
        TableOptions.CollateValue := ParseValue(WordIndices(kiDEFAULT, kiCOLLATE), vaAuto, ParseCollateIdent);
        Options.Add(TableOptions.CollateValue);
      end
      else if ((TableOptions.CommentValue = 0) and IsTag(kiCOMMENT)) then
      begin
        TableOptions.CommentValue := ParseValue(kiCOMMENT, vaAuto, ParseString);
        Options.Add(TableOptions.CommentValue);
      end
      else if ((TableOptions.ConnectionValue = 0) and IsTag(kiCONNECTION)) then
      begin
        TableOptions.ConnectionValue := ParseValue(kiCONNECTION, vaAuto, ParseString);
        Options.Add(TableOptions.ConnectionValue);
      end
      else if ((TableOptions.DataDirectoryValue = 0) and IsTag(kiDATA, kiDIRECTORY)) then
      begin
        TableOptions.DataDirectoryValue := ParseValue(WordIndices(kiDATA, kiDIRECTORY), vaAuto, ParseString);
        Options.Add(TableOptions.DataDirectoryValue);
      end
      else if ((TableOptions.DelayKeyWriteValue = 0) and IsTag(kiDELAY_KEY_WRITE)) then
      begin
        TableOptions.DelayKeyWriteValue := ParseValue(kiDELAY_KEY_WRITE, vaAuto, ParseInteger);
        Options.Add(TableOptions.DelayKeyWriteValue);
      end
      else if ((TableOptions.EngineIdent = 0) and IsTag(kiENGINE) and (MySQLVersion >= 40018)) then
      begin
        TableOptions.EngineIdent := ParseValue(kiENGINE, vaAuto, ParseEngineIdent);
        Options.Add(TableOptions.EngineIdent);
      end
      else if ((TableOptions.IndexDirectoryValue = 0) and IsTag(kiINDEX, kiDIRECTORY)) then
      begin
        TableOptions.IndexDirectoryValue := ParseValue(WordIndices(kiINDEX, kiDIRECTORY), vaAuto, ParseString);
        Options.Add(TableOptions.IndexDirectoryValue);
      end
      else if ((TableOptions.InsertMethodValue = 0) and IsTag(kiINSERT_METHOD)) then
      begin
        TableOptions.InsertMethodValue := ParseValue(kiINSERT_METHOD, vaAuto, WordIndices(kiNO, kiFIRST, kiLAST));
        Options.Add(TableOptions.InsertMethodValue);
      end
      else if ((TableOptions.KeyBlockSizeValue = 0) and IsTag(kiKEY_BLOCK_SIZE)) then
      begin
        TableOptions.KeyBlockSizeValue := ParseValue(kiKEY_BLOCK_SIZE, vaAuto, ParseInteger);
        Options.Add(TableOptions.KeyBlockSizeValue);
      end
      else if ((TableOptions.MaxRowsValue = 0) and IsTag(kiMAX_ROWS)) then
      begin
        TableOptions.MaxRowsValue := ParseValue(kiMAX_ROWS, vaAuto, ParseInteger);
        Options.Add(TableOptions.MaxRowsValue);
      end
      else if ((TableOptions.MinRowsValue = 0) and IsTag(kiMIN_ROWS)) then
      begin
        TableOptions.MinRowsValue := ParseValue(kiMIN_ROWS, vaAuto, ParseInteger);
        Options.Add(TableOptions.MinRowsValue);
      end
      else if ((TableOptions.PackKeysValue = 0) and IsTag(kiPACK_KEYS)) then
      begin
        TableOptions.PackKeysValue := ParseValue(kiPACK_KEYS, vaAuto, ParseExpr);
        Options.Add(TableOptions.PackKeysValue);
      end
      else if ((TableOptions.PageChecksumInt = 0) and IsTag(kiPAGE_CHECKSUM)) then
      begin
        TableOptions.PageChecksumInt := ParseValue(kiPAGE_CHECKSUM, vaAuto, ParseInteger);
        Options.Add(TableOptions.PageChecksumInt);
      end
      else if ((TableOptions.PasswordValue = 0) and IsTag(kiPASSWORD)) then
      begin
        TableOptions.PasswordValue := ParseValue(kiPASSWORD, vaAuto, ParseString);
        Options.Add(TableOptions.PasswordValue);
      end
      else if ((TableOptions.RowFormatValue = 0) and IsTag(kiROW_FORMAT)) then
      begin
        TableOptions.RowFormatValue := ParseValue(kiROW_FORMAT, vaAuto, ParseDbIdent);
        Options.Add(TableOptions.RowFormatValue);
      end
      else if ((TableOptions.StatsAutoRecalc = 0) and IsTag(kiSTATS_AUTO_RECALC, kiDEFAULT)) then
      begin
        TableOptions.StatsAutoRecalc := ParseValue(kiSTATS_AUTO_RECALC, vaAuto, WordIndices(kiDEFAULT));
        Options.Add(TableOptions.StatsAutoRecalc);
      end
      else if ((TableOptions.StatsAutoRecalc = 0) and IsTag(kiSTATS_AUTO_RECALC, kiDEFAULT)) then
      begin
        TableOptions.StatsAutoRecalc := ParseValue(kiSTATS_AUTO_RECALC, vaAuto, ParseInteger);
        Options.Add(TableOptions.StatsAutoRecalc);
      end
      else if ((TableOptions.StatsPersistent = 0) and IsTag(kiSTATS_PERSISTENT)) then
      begin
        TableOptions.StatsPersistent := ParseValue(kiSTATS_PERSISTENT, vaAuto, ParseExpr);
        Options.Add(TableOptions.StatsPersistent);
      end
      else if ((TableOptions.StatsSamplePages = 0) and IsTag(kiSTATS_SAMPLE_PAGES)) then
      begin
        TableOptions.StatsSamplePages := ParseValue(kiSTATS_SAMPLE_PAGES, vaAuto, ParseExpr);
        Options.Add(TableOptions.StatsSamplePages);
      end
      else if ((TableOptions.TablespaceIdent = 0) and IsTag(kiTABLESPACE)) then
      begin
        TableOptions.TablespaceIdent := ParseValue(kiTABLESPACE, vaAuto, ParseDbIdent);
        Options.Add(TableOptions.TablespaceIdent);
      end
      else if ((TableOptions.TableChecksumInt = 0) and IsTag(kiTABLE_CHECKSUM)) then
      begin
        TableOptions.TableChecksumInt := ParseValue(kiTABLE_CHECKSUM, vaAuto, ParseInteger);
        Options.Add(TableOptions.TableChecksumInt);
      end
      else if ((TableOptions.TransactionalInt = 0) and IsTag(kiTRANSACTIONAL)) then
      begin
        TableOptions.TransactionalInt := ParseValue(kiTRANSACTIONAL, vaAuto, ParseInteger);
        Options.Add(TableOptions.TransactionalInt);
      end
      else if ((TableOptions.EngineIdent = 0) and IsTag(kiTYPE) and (MySQLVersion < 50500)) then
      begin
        TableOptions.EngineIdent := ParseValue(kiTYPE, vaAuto, ParseEngineIdent);
        Options.Add(TableOptions.EngineIdent);
      end
      else if ((TableOptions.UnionList = 0) and IsTag(kiUNION)) then
      begin
        TableOptions.UnionList := ParseCreateTableStmtUnion();
        Options.Add(TableOptions.UnionList);
      end
      else
        Found := False;

      DelimiterFound := False;
      if (Found and IsSymbol(ttComma)) then
      begin
        DelimiterFound := True;
        Options.Add(ParseSymbol(ttComma));
      end;
    end;

    if (not ErrorFound and DelimiterFound) then
      if (EndOfStmt(CurrentToken)) then
        SetError(PE_IncompleteStmt)
      else
        SetError(PE_UnexpectedToken);

    if (Options.Count > 0) then
    begin
      FillChar(ListNodes, SizeOf(ListNodes), 0);
      Nodes.TableOptionList := TList.Create(Self, ListNodes, ttUnknown, @Options);
    end;
  end;

  if (not ErrorFound and (Nodes.Like.Tag = 0)) then
    if (IsTag(kiPARTITION, kiBY)) then
      Nodes.PartitionOptions := ParseCreateTableStmtPartitionOptions();

  if (not ErrorFound and (Nodes.Like.Tag = 0)) then
  begin
    if (IsTag(kiIGNORE)) then
      Nodes.IgnoreReplaceTag := ParseTag(kiIGNORE)
    else if (IsTag(kiREPLACE)) then
      Nodes.IgnoreReplaceTag := ParseTag(kiREPLACE);

    if (not ErrorFound) then
      if (IsTag(kiAS)) then
        Nodes.AsTag := ParseTag(kiAS);

    if (not ErrorFound) then
      if (EndOfStmt(CurrentToken) and (Nodes.AsTag > 0)) then
        SetError(PE_IncompleteStmt)
      else if (IsSelectStmt()) then
        Nodes.SelectStmt2 := ParseSelectStmt(True);
  end;

  Result := TCreateTableStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateTableStmtCheck(): TOffset;
var
  Nodes: TCreateTableStmt.TCheck.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.CheckTag := ParseTag(kiCHECK);

  if (not ErrorFound) then
    Nodes.ExprList := ParseList(True, ParseExpr);

  Result := TCreateTableStmt.TCheck.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateTableStmtField(): TOffset;
var
  DatatypeIndex: Integer;
  Found: Boolean;
  Nodes: TCreateTableStmt.TField.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Ident := ParseFieldIdent();

  if (not ErrorFound) then
    Nodes.Datatype := ParseDatatype(DatatypeIndex);

  if (not ErrorFound) then
    if (not IsTag(kiGENERATED)
      and not IsTag(kiAS)) then
    begin // Real field
      Found := True;
      while (not ErrorFound and Found) do
      begin
        if ((Nodes.NullTag = 0) and IsTag(kiNOT, kiNULL)) then
          Nodes.NullTag := ParseTag(kiNOT, kiNULL)
        else if ((Nodes.NullTag = 0) and IsTag(kiNULL)) then
          Nodes.NullTag := ParseTag(kiNULL)
        else if ((Nodes.Real.Default.Tag = 0) and IsTag(kiDEFAULT)) then
        begin
          Nodes.Real.Default.Tag := ParseTag(kiDEFAULT);

          if (not ErrorFound) then
            Nodes.Real.Default.Expr := ParseExpr([eoIn]);
        end
        else if ((DatatypeIndex in [diDatetime, diTimestamp]) and (Nodes.Real.OnUpdate = 0) and IsTag(kiON, kiUPDATE)) then
          Nodes.Real.OnUpdate := ParseCreateTableStmtFieldOnUpdate()
        else if ((Nodes.Real.AutoIncrementTag = 0) and IsTag(kiAUTO_INCREMENT)) then
          Nodes.Real.AutoIncrementTag := ParseTag(kiAUTO_INCREMENT)
        else if ((Nodes.KeyTag = 0) and IsTag(kiUNIQUE, kiKEY)) then
          Nodes.KeyTag := ParseTag(kiUNIQUE, kiKEY)
        else if ((Nodes.KeyTag = 0) and IsTag(kiUNIQUE))  then
          Nodes.KeyTag := ParseTag(kiUNIQUE)
        else if ((Nodes.KeyTag = 0) and IsTag(kiPRIMARY, kiKEY)) then
          Nodes.KeyTag := ParseTag(kiPRIMARY, kiKEY)
        else if ((Nodes.KeyTag = 0) and IsTag(kiKEY))  then
          Nodes.KeyTag := ParseTag(kiKEY)
        else if ((Nodes.CommentValue = 0) and IsTag(kiCOMMENT)) then
          Nodes.CommentValue := ParseValue(kiCOMMENT, vaNo, ParseString)
        else if ((Nodes.Real.ColumnFormat = 0) and IsTag(kiCOLUMN_FORMAT)) then
          Nodes.Real.ColumnFormat := ParseValue(kiCOLUMN_FORMAT, vaNo, WordIndices(kiFIXED, kiDYNAMIC, kiDEFAULT))
        else if ((Nodes.Real.StorageTag = 0) and IsTag(kiSTORAGE, kiDISK)) then
          Nodes.Real.StorageTag := ParseTag(kiSTORAGE, kiDISK)
        else if ((Nodes.Real.StorageTag = 0) and IsTag(kiSTORAGE, kiMEMORY)) then
          Nodes.Real.StorageTag := ParseTag(kiSTORAGE, kiMEMORY)
        else if ((Nodes.Real.StorageTag = 0) and IsTag(kiSTORAGE, kiDEFAULT)) then
          Nodes.Real.StorageTag := ParseTag(kiSTORAGE, kiDEFAULT)
        else if ((Nodes.Real.Reference = 0) and IsTag(kiREFERENCES)) then
          Nodes.Real.Reference := ParseCreateTableStmtReference()
        else
          Found := False;
      end;
    end
    else if (IsTag(kiGENERATED, kiALWAYS) or IsTag(kiAS)) then
    begin // Virtual field
      if (IsTag(kiGENERATED, kiALWAYS)) then
        Nodes.Virtual.GernatedAlwaysTag := ParseTag(kiGENERATED, kiALWAYS);

      if (not ErrorFound) then
        Nodes.Virtual.AsTag := ParseTag(kiAS);

      if (not ErrorFound) then
        Nodes.Virtual.Expr := ParseSubArea(ParseExpr);

      if (not ErrorFound) then
        if (IsTag(kiVIRTUAL)) then
          Nodes.Virtual.Virtual := ParseTag(kiVIRTUAL)
        else if (IsTag(kiSTORED)) then
          Nodes.Virtual.Virtual := ParseTag(kiSTORED)
        else if (IsTag(kiPERSISTENT)) then
          Nodes.Virtual.Virtual := ParseTag(kiPERSISTENT);

      Found := True;
      while (not ErrorFound and Found) do
      begin
        if ((Nodes.NullTag = 0) and IsTag(kiNOT)) then
          Nodes.NullTag := ParseTag(kiNOT, kiNULL)
        else if ((Nodes.NullTag = 0) and IsTag(kiNULL)) then
          Nodes.NullTag := ParseTag(kiNULL)
        else if ((Nodes.KeyTag = 0) and IsTag(kiUNIQUE, kiKEY)) then
          Nodes.KeyTag := ParseTag(kiUNIQUE, kiKEY)
        else if ((Nodes.KeyTag = 0) and IsTag(kiUNIQUE)) then
          Nodes.KeyTag := ParseTag(kiUNIQUE)
        else if ((Nodes.KeyTag = 0) and IsTag(kiPRIMARY, kiKEY)) then
          Nodes.KeyTag := ParseTag(kiPRIMARY, kiKEY)
        else if ((Nodes.KeyTag = 0) and IsTag(kiKEY)) then
          Nodes.KeyTag := ParseTag(kiKEY)
        else if ((Nodes.CommentValue = 0) and IsTag(kiCOMMENT)) then
          Nodes.CommentValue := ParseValue(kiCOMMENT, vaNo, ParseString)
        else
          Found := False;
      end;
  end
  else if (EndOfStmt(CurrentToken)) then
    SetError(PE_IncompleteStmt)
  else
    SetError(PE_UnexpectedToken);

  Result := TCreateTableStmt.TField.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateTableStmtFieldOnUpdate(): TOffset;
var
  Nodes: TCreateTableStmt.TField.TOnUpdate.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.OnUpdateTag := ParseTag(kiON, kiUPDATE);

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (IsNextSymbol(1, ttOpenBracket)
      and ((TokenPtr(CurrentToken)^.FLength = 12) and (StrLIComp(TokenPtr(CurrentToken)^.FText, 'CURRENT_DATE', 12) = 0)
        or (TokenPtr(CurrentToken)^.FLength = 12) and (StrLIComp(TokenPtr(CurrentToken)^.FText, 'CURRENT_TIME', 12) = 0)
        or (TokenPtr(CurrentToken)^.FLength = 17) and (StrLIComp(TokenPtr(CurrentToken)^.FText, 'CURRENT_TIMESTAMP', 17) = 0)
        or (TokenPtr(CurrentToken)^.FLength = 3) and (StrLIComp(TokenPtr(CurrentToken)^.FText, 'NOW', 3) = 0))) then
      Nodes.Expr := ParseDefaultFunc()
    else if ((TokenPtr(CurrentToken)^.FLength = 12) and (StrLIComp(TokenPtr(CurrentToken)^.FText, 'CURRENT_DATE', 12) = 0)
        or (TokenPtr(CurrentToken)^.FLength = 12) and (StrLIComp(TokenPtr(CurrentToken)^.FText, 'CURRENT_TIME', 12) = 0)
        or (TokenPtr(CurrentToken)^.FLength = 17) and (StrLIComp(TokenPtr(CurrentToken)^.FText, 'CURRENT_TIMESTAMP', 17) = 0)
        or (TokenPtr(CurrentToken)^.FLength = 3) and (StrLIComp(TokenPtr(CurrentToken)^.FText, 'NOW', 3) = 0)) then
      Nodes.Expr := ParseConstIdent()
    else
      SetError(PE_UnexpectedToken);

  Result := TCreateTableStmt.TField.TOnUpdate.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateTableStmtDefinition(): TOffset;
begin
  Result := ParseCreateTableStmtDefinition(False);
end;

function TSQLParser.ParseCreateTableStmtDefinition(const AlterTableStmt: Boolean): TOffset;
var
  AddTag: TOffset;
  ConstraintIdent: TOffset;
  ConstraintTag: TOffset;
begin
  AddTag := 0;
  if (AlterTableStmt) then
    AddTag := ParseTag(kiADD);

  ConstraintTag := 0; ConstraintIdent := 0;
  if (not ErrorFound) then
    if (IsTag(kiCONSTRAINT)) then
    begin
      ConstraintTag := ParseTag(kiCONSTRAINT);

      if (not ErrorFound) then
        if (not IsTag(kiPRIMARY, kiKEY)
          and not IsTag(kiFOREIGN, kiKEY)
          and not IsTag(kiUNIQUE)) then
          ConstraintIdent := ParseDbIdent(ditConstraint);
    end;

  if (ErrorFound) then
    Result := 0
  else if (IsTag(kiPRIMARY, kiKEY)
    or IsTag(kiUNIQUE, kiINDEX)
    or IsTag(kiUNIQUE, kiKEY)
    or IsTag(kiUNIQUE)
    or (ConstraintTag = 0) and IsTag(kiFULLTEXT)
    or (ConstraintTag = 0) and IsTag(kiSPATIAL)
    or (ConstraintTag = 0) and IsTag(kiINDEX)
    or (ConstraintTag = 0) and IsTag(kiKEY)) then
    Result := ParseCreateTableStmtKey(ConstraintTag, ConstraintIdent, AddTag)
  else if (IsTag(kiFOREIGN, kiKEY)) then
    Result := ParseCreateTableStmtForeignKey(ConstraintTag, ConstraintIdent, AddTag)
  else if ((AddTag = 0) and (ConstraintTag = 0) and IsTag(kiCHECK)) then
    Result := ParseCreateTableStmtCheck()
  else if ((ConstraintTag = 0) and IsTag(kiPARTITION)) then
    Result := ParseCreateTableStmtPartition(AddTag)
  else if (ConstraintTag = 0) then
    if (AlterTableStmt) then
      Result := ParseAlterTableStmtAddField(fatAdd, AddTag)
    else
      Result := ParseCreateTableStmtField()
  else if (EndOfStmt(CurrentToken)) then
    Result := SetError(PE_IncompleteStmt)
  else
    Result := SetError(PE_UnexpectedToken);
end;

function TSQLParser.ParseCreateTableStmtDefinitionPartitionNames(): TOffset;
begin
  if (IsTag(kiALL)) then
    Result := ParseTag(kiALL)
  else
    Result := ParseList(False, ParsePartitionIdent);
end;

function TSQLParser.ParseCreateTableStmtForeignKey(const ConstraintTag, ConstraintIdent, AddTag: TOffset): TOffset;
var
  Nodes: TCreateTableStmt.TForeignKey.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.AddTag := AddTag;

  Nodes.ConstraintTag := ConstraintTag;

  Nodes.ConstraintIdent := ConstraintIdent;

  if (not ErrorFound) then
    Nodes.ForeignKeyTag := ParseTag(kiFOREIGN, kiKEY);

  if (not ErrorFound) then
    if (not IsSymbol(ttOpenBracket)) then
      Nodes.NameIdent := ParseForeignKeyIdent();

  if (not ErrorFound) then
    Nodes.ColumnNameList := ParseList(True, ParseFieldIdent);

  if (not ErrorFound) then
    Nodes.Reference := ParseCreateTableStmtReference();

  Result := TCreateTableStmt.TForeignKey.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateTableStmtKey(const ConstraintTag, ConstraintIdent, AddTag: TOffset): TOffset;
var
  Found: Boolean;
  KeyName: Boolean;
  KeyType: Boolean;
  Nodes: TCreateTableStmt.TKey.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.AddTag := AddTag;

  Nodes.ConstraintTag := ConstraintTag;

  Nodes.ConstraintIdent := ConstraintIdent;

  KeyName := True; KeyType := False;
  if (not ErrorFound) then
    if (IsTag(kiPRIMARY, kiKEY)) then
      begin Nodes.KeyTag := ParseTag(kiPRIMARY, kiKEY); KeyName := False; KeyType := True; end
    else if (IsTag(kiINDEX)) then
      begin Nodes.KeyTag := ParseTag(kiINDEX); KeyType := True; end
    else if (IsTag(kiKEY)) then
      begin Nodes.KeyTag := ParseTag(kiKEY); KeyType := True; end
    else if (IsTag(kiUNIQUE, kiINDEX)) then
      begin Nodes.KeyTag := ParseTag(kiUNIQUE, kiINDEX); KeyType := True; end
    else if (IsTag(kiUNIQUE, kiKEY)) then
      begin Nodes.KeyTag := ParseTag(kiUNIQUE, kiKEY); KeyType := True; end
    else if (IsTag(kiUNIQUE)) then
      begin Nodes.KeyTag := ParseTag(kiUNIQUE); KeyType := True; end
    else if (IsTag(kiFULLTEXT, kiINDEX)) then
      Nodes.KeyTag := ParseTag(kiFULLTEXT, kiINDEX)
    else if (IsTag(kiFULLTEXT, kiKEY)) then
      Nodes.KeyTag := ParseTag(kiFULLTEXT, kiKEY)
    else if (IsTag(kiFULLTEXT)) then
      Nodes.KeyTag := ParseTag(kiFULLTEXT)
    else if (IsTag(kiSPATIAL, kiINDEX)) then
      Nodes.KeyTag := ParseTag(kiSPATIAL, kiINDEX)
    else if (IsTag(kiSPATIAL, kiKEY)) then
      Nodes.KeyTag := ParseTag(kiSPATIAL, kiKEY)
    else if (IsTag(kiSPATIAL)) then
      Nodes.KeyTag := ParseTag(kiSPATIAL)
    else if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  if (not ErrorFound and KeyName) then
    if (not IsTag(kiUSING) and not IsSymbol(ttOpenBracket)) then
      Nodes.KeyIdent := ParseKeyIdent();

  if (not ErrorFound and KeyType) then
    if (IsTag(kiUSING, kiBTREE)) then
      Nodes.IndexTypeTag := ParseTag(kiUSING, kiBTREE)
    else if (IsTag(kiUSING, kiHASH)) then
      Nodes.IndexTypeTag := ParseTag(kiUSING, kiHASH);

  if (not ErrorFound) then
    Nodes.KeyColumnList := ParseList(True, ParseCreateTableStmtKeyColumn, ttComma, False);

  if (not ErrorFound and KeyType and (Nodes.IndexTypeTag = 0)) then
    if (IsTag(kiUSING, kiBTREE)) then
      Nodes.IndexTypeTag := ParseTag(kiUSING, kiBTREE)
    else if (IsTag(kiUSING, kiHASH)) then
      Nodes.IndexTypeTag := ParseTag(kiUSING, kiHASH);

  Found := True;
  while (not ErrorFound and Found) do
    if ((Nodes.CommentValue = 0) and IsTag(kiCOMMENT)) then
      Nodes.CommentValue := ParseValue(kiCOMMENT, vaNo, ParseString)
    else if ((Nodes.KeyBlockSizeValue = 0) and IsTag(kiKEY_BLOCK_SIZE)) then
      Nodes.KeyBlockSizeValue := ParseValue(kiKEY_BLOCK_SIZE, vaAuto, ParseInteger)
    else if ((Nodes.WithParserValue = 0) and IsTag(kiWITH, kiPARSER)) then
      Nodes.WithParserValue := ParseValue(WordIndices(kiWITH, kiPARSER), vaNo, ParseDbIdent)
    else
      Found := False;

  Result := TCreateTableStmt.TKey.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateTableStmtKeyColumn(): TOffset;
var
  Nodes: TCreateTableStmt.TKeyColumn.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentTag := ParseDbIdent(ditField);

  if (not ErrorFound) then
    if (IsSymbol(ttOpenBracket)) then
    begin
      Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

      if (not ErrorFound) then
        Nodes.LengthToken := ParseInteger();

      if (not ErrorFound) then
        Nodes.CloseBracket := ParseSymbol(ttCloseBracket);
    end;

  if (not ErrorFound) then
    if (IsTag(kiASC)) then
      Nodes.SortTag := ParseTag(kiASC)
    else if (IsTag(kiDESC)) then
      Nodes.SortTag := ParseTag(kiDESC);

  Result := TCreateTableStmt.TKeyColumn.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateTableStmtPartition(): TOffset;
begin
  Result := ParseCreateTableStmtPartition(0);
end;

function TSQLParser.ParseCreateTableStmtPartition(const AddTag: TOffset): TOffset;
var
  Found: Boolean;
  Nodes: TCreateTableStmt.TPartition.TNodes;
  ValueNodes: TValue.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.AddTag := AddTag;

  if (not ErrorFound) then
    Nodes.PartitionTag := ParseTag(kiPARTITION);

  if (not ErrorFound) then
    Nodes.NameIdent := ParsePartitionIdent();

  if (not ErrorFound) then
    if (IsTag(kiVALUES)) then
    begin
      Nodes.Values.Tag := ParseTag(kiVALUES);

      if (not ErrorFound) then
        if (IsTag(kiLESS, kiTHAN, kiMAXVALUE)) then
          Nodes.Values.Value := ParseTag(kiLESS, kiTHAN, kiMAXVALUE)
        else if (IsTag(kiLESS, kiTHAN)) then
        begin
          FillChar(ValueNodes, SizeOf(ValueNodes), 0);
          ValueNodes.Ident := ParseTag(kiLESS, kiTHAN);
          if (IsSymbol(ttOpenBracket) and IsNextTag(1, kiMAXVALUE)) then
            ValueNodes.Expr := ParseSubArea(ParseMaxValue)
          else
            ValueNodes.Expr := ParseList(True, ParseExpr);
          Nodes.Values.Value := TValue.Create(Self, ValueNodes);
        end
        else if (IsTag(kiIN)) then
        begin
          FillChar(ValueNodes, SizeOf(ValueNodes), 0);
          ValueNodes.Ident := ParseTag(kiIN);
          if (not ErrorFound) then
            ValueNodes.Expr := ParseList(True, ParseExpr);
          Nodes.Values.Value := TValue.Create(Self, ValueNodes);
        end
        else if (EndOfStmt(CurrentToken)) then
          SetError(PE_IncompleteStmt)
        else
          SetError(PE_UnexpectedToken);
    end;

  Found := True;
  while (not ErrorFound and Found) do
    if ((Nodes.CommentValue = 0) and IsTag(kiCOMMENT)) then
      Nodes.CommentValue := ParseValue(kiCOMMENT, vaAuto, ParseString)
    else if ((Nodes.DataDirectoryValue = 0) and IsTag(kiDATA, kiDIRECTORY)) then
      Nodes.DataDirectoryValue := ParseValue(WordIndices(kiDATA, kiDIRECTORY), vaAuto, ParseString)
    else if ((Nodes.EngineValue = 0) and IsTag(kiSTORAGE, kiENGINE)) then
      Nodes.EngineValue := ParseValue(WordIndices(kiSTORAGE, kiENGINE), vaAuto, ParseDbIdent)
    else if ((Nodes.EngineValue = 0) and IsTag(kiENGINE)) then
      Nodes.EngineValue := ParseValue(kiENGINE, vaAuto, ParseEngineIdent)
    else if ((Nodes.IndexDirectoryValue = 0) and IsTag(kiINDEX, kiDIRECTORY)) then
      Nodes.IndexDirectoryValue := ParseValue(WordIndices(kiINDEX, kiDIRECTORY), vaAuto, ParseString)
    else if ((Nodes.MaxRowsValue = 0) and IsTag(kiMAX_ROWS)) then
      Nodes.MaxRowsValue := ParseValue(kiMAX_ROWS, vaAuto, ParseInteger)
    else if ((Nodes.MinRowsValue = 0) and IsTag(kiMIN_ROWS)) then
      Nodes.MinRowsValue := ParseValue(kiMIN_ROWS, vaAuto, ParseInteger)
    else if ((Nodes.EngineValue = 0) and IsTag(kiSTORAGE, kiENGINE)) then
      Nodes.EngineValue := ParseValue(WordIndices(kiSTORAGE, kiENGINE), vaAuto, ParseDbIdent)
    else if ((Nodes.SubPartitionList = 0) and IsSymbol(ttOpenBracket)) then
      Nodes.SubPartitionList := ParseList(True, ParseSubPartition)
    else
      Found := False;

  Result := TCreateTableStmt.TPartition.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateTableStmtPartitionOptions(): TOffset;
type
  TPartitionType = (ptUnknown, ptHash, ptKey, ptRANGE, ptList);
var
  Nodes: TCreateTableStmt.TPartitionOptions.TNodes;
  PartitionType: TPartitionType;
  SubPartitionType: TPartitionType;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Tag := ParseTag(kiPARTITION, kiBY);

  PartitionType := ptUnknown;
  if (not ErrorFound) then
    if (IsTag(kiHASH)) then
    begin
      Nodes.KindTag := ParseTag(kiHASH);
      PartitionType := ptHash;
    end
    else if (IsTag(kiLINEAR, kiHASH)) then
    begin
      Nodes.KindTag := ParseTag(kiLINEAR, kiHASH);
      PartitionType := ptHash;
    end
    else if (IsTag(kiLINEAR, kiKEY)) then
    begin
      Nodes.KindTag := ParseTag(kiLINEAR, kiKEY);
      PartitionType := ptKey;
    end
    else if (IsTag(kiKEY)) then
    begin
      Nodes.KindTag := ParseTag(kiKEY);
      PartitionType := ptKEY;
    end
    else if (IsTag(kiRANGE)) then
    begin
      Nodes.KindTag := ParseTag(kiRANGE);
      PartitionType := ptRange;
    end
    else if (IsTag(kiLIST)) then
    begin
      Nodes.KindTag := ParseTag(kiLIST);
      PartitionType := ptList;
    end
    else if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  if (PartitionType = ptHash) then
  begin
    if (not ErrorFound) then
      Nodes.Expr := ParseSubArea(ParseExpr);
  end
  else if (PartitionType = ptKey) then
  begin
    if (IsTag(kiALGORITHM)) then
      Nodes.AlgorithmValue := ParseValue(kiALGORITHM, vaAuto, ParseInteger);

    if (not ErrorFound) then
      Nodes.Columns.List := ParseList(True, ParseFieldIdent);
  end
  else if (PartitionType in [ptRange, ptList]) then
  begin
    if (not IsTag(kiCOLUMNS)) then
      Nodes.Expr := ParseSubArea(ParseExpr)
    else
    begin
      Nodes.Columns.Tag := ParseTag(kiCOLUMNS);

      if (not ErrorFound) then
        Nodes.Columns.List := ParseList(True, ParseFieldIdent);
    end;
  end;

  if (not ErrorFound) then
    if (IsTag(kiPARTITIONS)) then
      Nodes.PartitionCount := ParseValue(kiPARTITIONS, vaNo, ParseInteger);

  if (not ErrorFound) then
    if (IsTag(kiSUBPARTITION, kiBY)) then
    begin
      Nodes.SubPartition.Tag := ParseTag(kiSUBPARTITION, kiBY);

      SubPartitionType := ptUnknown;
      if (not ErrorFound) then
        if (IsTag(kiLINEAR, kiHASH)) then
        begin
          Nodes.SubPartition.KindTag := ParseTag(kiLINEAR, kiHASH);
          SubPartitionType := ptHash;
        end
        else if (IsTag(kiHASH)) then
        begin
          Nodes.SubPartition.KindTag := ParseTag(kiHASH);
          SubPartitionType := ptHash;
        end
        else if (IsTag(kiLINEAR, kiKEY)) then
        begin
          Nodes.SubPartition.KindTag := ParseTag(kiLINEAR, kiKEY);
          SubPartitionType := ptKey;
        end
        else if (IsTag(kiKEY)) then
        begin
          Nodes.SubPartition.KindTag := ParseTag(kiLINEAR, kiKEY);
          SubPartitionType := ptKey;
        end
        else if (EndOfStmt(CurrentToken)) then
          SetError(PE_IncompleteStmt)
        else
          SetError(PE_UnexpectedToken);

      if (not ErrorFound) then
        if (SubPartitionType = ptHash) then
        begin
          Nodes.SubPartition.Expr := ParseExpr();
        end
        else if (SubPartitionType = ptKey) then
        begin
          if (IsTag(kiALGORITHM)) then
            Nodes.SubPartition.AlgorithmValue := ParseValue(kiALGORITHM, vaAuto, ParseInteger);

          if (not ErrorFound) then
            Nodes.SubPartition.ColumnList := ParseList(True, ParseDbIdent);
        end;

      if (not ErrorFound) then
        if (IsTag(kiSUBPARTITIONS)) then
          Nodes.SubPartition.Value := ParseValue(kiSUBPARTITIONS, vaNo, ParseInteger);
    end;

  if (not ErrorFound) then
    if (IsSymbol(ttOpenBracket) and not IsNextTag(1, kiSELECT)) then
      Nodes.DefinitionList := ParseList(True, ParseCreateTableStmtPartition);

  Result := TCreateTableStmt.TPartitionOptions.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateTableStmtReference(): TOffset;
var
  Found: Boolean;
  Nodes: TCreateTableStmt.TReference.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (not ErrorFound) then
    Nodes.Tag := ParseTag(kiREFERENCES);

  if (not ErrorFound) then
    Nodes.ParentTableIdent := ParseTableIdent();

  if (not ErrorFound) then
    Nodes.FieldList := ParseList(True, ParseFieldIdent);

  if (not ErrorFound) then
    if (IsTag(kiMATCH, kiFULL)) then
      Nodes.MatchTag := ParseTag(kiMATCH, kiFULL)
    else if (IsTag(kiMATCH, kiPARTIAL)) then
      Nodes.MatchTag := ParseTag(kiMATCH, kiPARTIAL)
    else if (IsTag(kiMATCH, kiSIMPLE)) then
      Nodes.MatchTag := ParseTag(kiMATCH, kiSIMPLE);

  Found := True;
  while (not ErrorFound and Found) do
    if ((Nodes.OnDeleteTag = 0) and IsTag(kiON, kiDELETE, kiRESTRICT)) then
      Nodes.OnDeleteTag := ParseTag(kiON, kiDELETE, kiRESTRICT)
    else if ((Nodes.OnDeleteTag = 0) and IsTag(kiON, kiDELETE, kiCASCADE)) then
      Nodes.OnDeleteTag := ParseTag(kiON, kiDELETE, kiCASCADE)
    else if ((Nodes.OnDeleteTag = 0) and IsTag(kiON, kiDELETE, kiSET, kiNULL)) then
      Nodes.OnDeleteTag := ParseTag(kiON, kiDELETE, kiSET, kiNULL)
    else if ((Nodes.OnDeleteTag = 0) and IsTag(kiON, kiDELETE, kiNO, kiACTION)) then
      Nodes.OnDeleteTag := ParseTag(kiON, kiDELETE, kiNO, kiACTION)
    else if ((Nodes.OnUpdateTag = 0) and IsTag(kiON, kiUPDATE, kiRESTRICT)) then
      Nodes.OnUpdateTag := ParseTag(kiON, kiUPDATE, kiRESTRICT)
    else if ((Nodes.OnUpdateTag = 0) and IsTag(kiON, kiUPDATE, kiCASCADE)) then
      Nodes.OnUpdateTag := ParseTag(kiON, kiUPDATE, kiCASCADE)
    else if ((Nodes.OnUpdateTag = 0) and IsTag(kiON, kiUPDATE, kiSET, kiNULL)) then
      Nodes.OnUpdateTag := ParseTag(kiON, kiUPDATE, kiSET, kiNULL)
    else if ((Nodes.OnUpdateTag = 0) and IsTag(kiON, kiUPDATE, kiNO, kiACTION)) then
      Nodes.OnUpdateTag := ParseTag(kiON, kiUPDATE, kiNO, kiACTION)
    else
      Found := False;

  Result := TCreateTableStmt.TReference.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateTableStmtUnion(): TOffset;
var
  Nodes: TValue.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Ident := ParseTag(kiUNION);

  if (not ErrorFound) then
    if (not EndOfStmt(CurrentToken) and (TokenPtr(CurrentToken)^.OperatorType = otEqual)) then
      Nodes.AssignToken := ApplyCurrentToken(utOperator);

  if (not ErrorFound) then
    Nodes.Expr := ParseList(True, ParseTableIdent);

  Result := TValue.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateTriggerStmt(const CreateTag, OrReplaceTag, DefinerValue: TOffset): TOffset;
var
  Nodes: TCreateTriggerStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.CreateTag := CreateTag;

  Nodes.OrReplaceTag := OrReplaceTag;

  Nodes.DefinerNode := DefinerValue;

  if (not ErrorFound) then
    Nodes.TriggerTag := ParseTag(kiTRIGGER);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiNOT, kiEXISTS)) then
      Nodes.IfNotExistsTag := ParseTag(kiIF, kiNOT, kiEXISTS);

  if (not ErrorFound) then
    Nodes.Ident := ParseTriggerIdent();

  if (not ErrorFound) then
    if (IsTag(kiBEFORE)) then
      Nodes.TimeTag := ParseTag(kiBEFORE)
    else if (IsTag(kiAFTER)) then
      Nodes.TimeTag := ParseTag(kiAFTER)
    else if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
    if (IsTag(kiINSERT)) then
      Nodes.EventTag := ParseTag(kiINSERT)
    else if (IsTag(kiUPDATE)) then
      Nodes.EventTag := ParseTag(kiUPDATE)
    else if (IsTag(kiDELETE)) then
      Nodes.EventTag := ParseTag(kiDELETE)
    else if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
    Nodes.OnTag := ParseTag(kiON);

  if (not ErrorFound) then
    Nodes.TableIdent := ParseTableIdent();

  if (not ErrorFound) then
    Nodes.ForEachRowTag := ParseTag(kiFOR, kiEACH, kiROW);

  if (not ErrorFound) then
    if (IsTag(kiFOLLOWS)) then
      Nodes.OrderValue := ParseValue(kiFOLLOWS, vaNo, ParseTriggerIdent)
    else if (IsTag(kiPRECEDES)) then
      Nodes.OrderValue := ParseValue(kiPRECEDES, vaNo, ParseTriggerIdent);

  if (not ErrorFound) then
  begin
    Parse.InCreateTriggerStmt := True;
    Nodes.Stmt := ParsePL_SQLStmt();
    Parse.InCreateTriggerStmt := False;
    if (not ErrorFound and (Nodes.Stmt = 0)) then
      SetError(PE_IncompleteStmt);
  end;

  Result := TCreateTriggerStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateUserStmt(const StmtTag: TOffset; const OrReplaceTag: TOffset = 0): TOffset;
var
  Found: Boolean;
  Nodes: TCreateUserStmt.TNodes;
  OldCurrentToken: TOffset;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := StmtTag;

  Nodes.OrReplaceTag := OrReplaceTag;

  Nodes.UserTag := ParseTag(kiUSER);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiNOT, kiEXISTS)) then
      Nodes.IfNotExistsTag := ParseTag(kiIF, kiNOT, kiEXISTS);

  if (not ErrorFound) then
    Nodes.UserSpecifications := ParseList(False, ParseGrantStmtUserSpecification);

  if (not ErrorFound) then
    if (IsTag(kiWITH)) then
    begin
      Nodes.WithTag := ParseTag(kiWITH);

      Found := True; OldCurrentToken := CurrentToken;
      while (not ErrorFound and Found) do
        if ((Nodes.MaxQueriesPerHour = 0) and IsTag(kiMAX_QUERIES_PER_HOUR)) then
          Nodes.MaxQueriesPerHour := ParseValue(kiMAX_QUERIES_PER_HOUR, vaNo, ParseInteger)
        else if ((Nodes.MaxUpdatesPerHour = 0) and IsTag(kiMAX_UPDATES_PER_HOUR)) then
          Nodes.MaxUpdatesPerHour := ParseValue(kiMAX_UPDATES_PER_HOUR, vaNo, ParseInteger)
        else if ((Nodes.MaxConnectionsPerHour = 0) and IsTag(kiMAX_CONNECTIONS_PER_HOUR)) then
          Nodes.MaxConnectionsPerHour := ParseValue(kiMAX_CONNECTIONS_PER_HOUR, vaNo, ParseInteger)
        else if ((Nodes.MaxUserConnections = 0) and IsTag(kiMAX_USER_CONNECTIONS)) then
          Nodes.MaxUserConnections := ParseValue(kiMAX_USER_CONNECTIONS, vaNo, ParseInteger)
        else
          Found := False;

      if (CurrentToken = OldCurrentToken) then
        if (EndOfStmt(CurrentToken)) then
          SetError(PE_IncompleteStmt)
        else
          SetError(PE_UnexpectedToken);
    end;

  Found := True;
  while (not ErrorFound and Found) do
    if ((Nodes.PasswordOption.Tag = 0) and IsTag(kiPASSWORD, kiEXPIRE, kiDEFAULT)) then
      Nodes.PasswordOption.Tag := ParseTag(kiPASSWORD, kiEXPIRE, kiDEFAULT)
    else if ((Nodes.PasswordOption.Tag = 0) and IsTag(kiPASSWORD, kiEXPIRE, kiNEVER)) then
      Nodes.PasswordOption.Tag := ParseTag(kiPASSWORD, kiEXPIRE, kiNEVER)
    else if ((Nodes.PasswordOption.Tag = 0) and IsTag(kiPASSWORD, kiEXPIRE, kiINTERVAL)) then
    begin
      Nodes.PasswordOption.Tag := ParseTag(kiPASSWORD, kiEXPIRE, kiINTERVAL);
      if (not ErrorFound) then
        Nodes.PasswordOption.QuantityInt := ParseInteger();
      if (not ErrorFound) then
        Nodes.PasswordOption.UnitTag := ParseIntervalUnitTag();
    end
    else if ((Nodes.PasswordOption.Tag = 0) and IsTag(kiPASSWORD, kiEXPIRE)) then
      Nodes.PasswordOption.Tag := ParseTag(kiPASSWORD, kiEXPIRE)
    else if ((Nodes.AccountTag = 0) and IsTag(kiACCOUNT, kiLOCK)) then
      Nodes.AccountTag := ParseTag(kiACCOUNT, kiLOCK)
    else if ((Nodes.AccountTag = 0) and IsTag(kiACCOUNT, kiUNLOCK)) then
      Nodes.AccountTag := ParseTag(kiACCOUNT, kiUNLOCK)
    else
      Found := False;

  Result := TCreateUserStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseCreateViewStmt(const CreateTag, OrReplaceTag, AlgorithmValue, DefinerValue, SQLSecurityTag: TOffset): TOffset;
var
  Nodes: TCreateViewStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.CreateTag := CreateTag;

  Nodes.OrReplaceTag := OrReplaceTag;

  Nodes.AlgorithmValue := AlgorithmValue;

  Nodes.DefinerValue := DefinerValue;

  Nodes.SQLSecurityTag := SQLSecurityTag;

  if (not ErrorFound) then
    Nodes.ViewTag := ParseTag(kiVIEW);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiNOT, kiEXISTS)) then
      Nodes.IfNotExistsTag := ParseTag(kiIF, kiNOT, kiEXISTS);

  if (not ErrorFound) then
    Nodes.Ident := ParseTableIdent();

  if (not ErrorFound) then
    if (IsSymbol(ttOpenBracket)) then
      Nodes.FieldList:= ParseList(True, ParseFieldIdent);

  if (not ErrorFound) then
    Nodes.AsTag := ParseTag(kiAS);

  if (not ErrorFound) then
    Nodes.SelectStmt := ParseSelectStmt(True);

  if (not ErrorFound) then
    if (IsTag(kiWITH, kiCASCADED, kiCHECK, kiOPTION)) then
      Nodes.OptionTag := ParseTag(kiWITH, kiCASCADED, kiCHECK, kiOPTION)
    else if (IsTag(kiWITH, kiLOCAL, kiCHECK, kiOPTION)) then
      Nodes.OptionTag := ParseTag(kiWITH, kiLOCAL, kiCHECK, kiOPTION)
    else if (IsTag(kiWITH, kiCHECK, kiOPTION)) then
      Nodes.OptionTag := ParseTag(kiWITH, kiCHECK, kiOPTION);

  Result := TCreateViewStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDatabaseIdent(): TOffset;
begin
  Result := ParseDbIdent(ditDatabase);
end;

function TSQLParser.ParseDatatype(): TOffset;
var
  DatatypeIndex: Integer;
begin
  Result := ParseDatatype(DatatypeIndex);
end;

function TSQLParser.ParseDatatype(out DatatypeIndex: Integer): TOffset;
var
  DatatypeIndex2: Integer;
  Length: Integer;
  Nodes: TDatatype.TNodes;
  Text: PChar;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);
  DatatypeIndex := -1;

  if (IsTag(kiNATIONAL)) then
    Nodes.NationalToken := ApplyCurrentToken(utDatatype);

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
    begin
      CompletionList.AddList(ditDatatype);
      SetError(PE_IncompleteStmt);
    end
    else
    begin
      TokenPtr(CurrentToken)^.GetText(Text, Length);
      DatatypeIndex := DatatypeList.IndexOf(Text, Length);
      if (DatatypeIndex >= 0) then
        Nodes.DatatypeToken := ApplyCurrentToken(utDatatype)
      else
        SetError(PE_UnexpectedToken);
    end;

  if (not ErrorFound
    and ((DatatypeIndex = diSIGNED) or (DatatypeIndex = diUNSIGNED))
    and (TokenPtr(CurrentToken)^.TokenType = ttIdent)) then
  begin
    TokenPtr(CurrentToken)^.GetText(Text, Length);
    DatatypeIndex2 := DatatypeList.IndexOf(Text, Length);
    if ((DatatypeIndex2 = diBIGINT)
      or (DatatypeIndex2 = diBYTE)
      or (DatatypeIndex2 = diINT)
      or (DatatypeIndex2 = diINT4)
      or (DatatypeIndex2 = diINTEGER)
      or (DatatypeIndex2 = diLARGEINT)
      or (DatatypeIndex2 = diLONG)
      or (DatatypeIndex2 = diMEDIUMINT)
      or (DatatypeIndex2 = diSMALLINT)
      or (DatatypeIndex2 = diTINYINT)) then
    begin
      Nodes.SignedToken := Nodes.DatatypeToken;
      Nodes.DatatypeToken := ApplyCurrentToken(utDatatype);
      DatatypeIndex := DatatypeIndex2;
    end;
  end;

  if (not ErrorFound
    and (DatatypeIndex = diLONG)
    and (TokenPtr(CurrentToken)^.TokenType = ttIdent)) then
  begin
    TokenPtr(CurrentToken)^.GetText(Text, Length);
    DatatypeIndex2 := DatatypeList.IndexOf(Text, Length);
    if ((DatatypeIndex2 = diVARBINARY)
      or (DatatypeIndex2 = diVARCHAR)) then
    begin
      Nodes.PreDatatypeToken := Nodes.DatatypeToken;
      Nodes.DatatypeToken := ApplyCurrentToken(utDatatype);
      DatatypeIndex := DatatypeIndex2;
    end;
  end;

  if (not ErrorFound) then
    if (IsSymbol(ttOpenBracket)
      and ((DatatypeIndex = diBIGINT)
        or (DatatypeIndex = diBINARY)
        or (DatatypeIndex = diBIT)
        or (DatatypeIndex = diBLOB)
        or (DatatypeIndex = diCHAR)
        or (DatatypeIndex = diCHARACTER)
        or (DatatypeIndex = diDATETIME)
        or (DatatypeIndex = diDEC)
        or (DatatypeIndex = diDECIMAL)
        or (DatatypeIndex = diDOUBLE)
        or (DatatypeIndex = diFLOAT)
        or (DatatypeIndex = diINT)
        or (DatatypeIndex = diINTEGER)
        or (DatatypeIndex = diLONGTEXT)
        or (DatatypeIndex = diMEDIUMINT)
        or (DatatypeIndex = diMEDIUMTEXT)
        or (DatatypeIndex = diNCHAR)
        or (DatatypeIndex = diNVARCHAR)
        or (DatatypeIndex = diNUMBER)
        or (DatatypeIndex = diNUMERIC)
        or (DatatypeIndex = diREAL)
        or (DatatypeIndex = diSMALLINT)
        or (DatatypeIndex = diSIGNED)
        or (DatatypeIndex = diTIME)
        or (DatatypeIndex = diTIMESTAMP)
        or (DatatypeIndex = diTINYINT)
        or (DatatypeIndex = diTINYTEXT)
        or (DatatypeIndex = diTEXT)
        or (DatatypeIndex = diUNSIGNED)
        or (DatatypeIndex = diVARBINARY)
        or (DatatypeIndex = diVARCHAR)
        or (DatatypeIndex = diYEAR))) then
    begin
      Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

      if (not ErrorFound) then
        Nodes.LengthToken := ParseInteger();

      if (not ErrorFound) then
        if (((DatatypeIndex = diDEC)
            or (DatatypeIndex = diDECIMAL)
            or (DatatypeIndex = diNUMERIC))
          and IsSymbol(ttComma)) then
        begin
          Nodes.CommaToken := ParseSymbol(ttComma);

          if (not ErrorFound) then
            Nodes.DecimalsToken := ParseInteger();
        end
        else if (((DatatypeIndex = diDOUBLE)
            or (DatatypeIndex = diFLOAT)
            or (DatatypeIndex = diREAL))) then
        begin
          Nodes.CommaToken := ParseSymbol(ttComma);

          if (not ErrorFound) then
            Nodes.DecimalsToken := ParseInteger();
        end;

      if (not ErrorFound) then
        Nodes.CloseBracket := ParseSymbol(ttCloseBracket);
    end
    else if ((DatatypeIndex = diVARBINARY)
      or (DatatypeIndex = diVARCHAR)) then
      if (EndOfStmt(CurrentToken)) then
        SetError(PE_IncompleteStmt)
      else
        SetError(PE_UnexpectedToken);

  if (not ErrorFound
    and ((DatatypeIndex = diENUM)
      or (DatatypeIndex = diSET))) then
    Nodes.ItemList := ParseList(True, ParseString, ttComma, False);

  if (not ErrorFound) then
    if (IsTag(kiSIGNED)) then
      Nodes.SignedToken := ApplyCurrentToken(utDatatype)
    else if (IsTag(kiUNSIGNED)) then
      Nodes.SignedToken := ApplyCurrentToken(utDatatype);

  if (not ErrorFound
    and ((DatatypeIndex = diBIGINT)
      or (DatatypeIndex = diBYTE)
      or (DatatypeIndex = diDEC)
      or (DatatypeIndex = diDECIMAL)
      or (DatatypeIndex = diDOUBLE)
      or (DatatypeIndex = diFLOAT)
      or (DatatypeIndex = diINT)
      or (DatatypeIndex = diINTEGER)
      or (DatatypeIndex = diMEDIUMINT)
      or (DatatypeIndex = diNUMBER)
      or (DatatypeIndex = diNUMERIC)
      or (DatatypeIndex = diREAL)
      or (DatatypeIndex = diSMALLINT)
      or (DatatypeIndex = diTINYINT))) then
    if (IsTag(kiZEROFILL)) then
      Nodes.ZerofillTag := ParseTag(kiZEROFILL);

  if ((DatatypeIndex = diCHAR)
    or (DatatypeIndex = diCHARACTER)
    or (DatatypeIndex = diTEXT)
    or (DatatypeIndex = diLONGTEXT)
    or (DatatypeIndex = diMEDIUMTEXT)
    or (DatatypeIndex = diTINYTEXT)
    or (DatatypeIndex = diVARCHAR)) then
  begin
    if (not ErrorFound) then
      if (IsTag(kiBINARY)) then
        Nodes.BinaryToken := ApplyCurrentToken(utDatatype);

    if (not ErrorFound) then
      if (IsTag(kiASCII)) then
        Nodes.ASCIIToken := ApplyCurrentToken(utDatatype);

    if (not ErrorFound) then
      if (IsTag(kiUNICODE)) then
        Nodes.UnicodeToken := ApplyCurrentToken(utDatatype);
  end;

  if (not ErrorFound
    and ((DatatypeIndex = diCHAR)
      or (DatatypeIndex = diCHARACTER)
      or (DatatypeIndex = diENUM)
      or (DatatypeIndex = diLONGTEXT)
      or (DatatypeIndex = diMEDIUMTEXT)
      or (DatatypeIndex = diSET)
      or (DatatypeIndex = diTEXT)
      or (DatatypeIndex = diTINYTEXT)
      or (DatatypeIndex = diVARCHAR))) then
  begin
    if (IsTag(kiCHARACTER, kiSET)) then
      Nodes.CharacterSetValue := ParseValue(WordIndices(kiCHARACTER, kiSET), vaNo, ParseCharsetIdent)
    else if (IsTag(kiCHARSET)) then
      Nodes.CharacterSetValue := ParseValue(kiCHARSET, vaNo, ParseCharsetIdent);

    if (not ErrorFound) then
      if (IsTag(kiCOLLATE)) then
        Nodes.CollateValue := ParseValue(kiCOLLATE, vaNo, ParseCollateIdent);
  end;

  Result := TDatatype.Create(Self, Nodes);
end;

function TSQLParser.ParseDateAddFunc(): TOffset;
var
  Nodes: TDateAddFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    Nodes.DateExpr := ParseExpr();

  if (not ErrorFound) then
    Nodes.CommaToken := ParseSymbol(ttComma);

  if (not ErrorFound) then
    Nodes.IntervalExpr := ParseExpr();

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TDateAddFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseDbIdent(): TOffset;
begin
  Result := ParseDbIdent(ditUnknown, False);
end;

function TSQLParser.ParseDbIdent(const ADbIdentType: TDbIdentType;
  const FullQualified: Boolean = True; const JokerAllowed: Boolean = False): TOffset;

  function ParseDbIdentToken(const QualifiedIdentifier: Boolean): TOffset;
  begin
    if (EndOfStmt(CurrentToken)) then
      Result := SetError(PE_IncompleteStmt)
    else if ((TokenPtr(CurrentToken)^.TokenType = ttIdent)
        and (QualifiedIdentifier
          or (ReservedWordList.IndexOf(TokenPtr(CurrentToken)^.FText, TokenPtr(CurrentToken)^.FLength) < 0)
          or (ADbIdentType = ditCharset) and (StrLIComp(TokenPtr(CurrentToken)^.FText, 'binary', 6) = 0)
          or (ADbIdentType in [ditVariable, ditConstante]))
      or (TokenPtr(CurrentToken)^.TokenType = ttMySQLIdent) and not (ADbIdentType in [ditCharset, ditCollation])
      or (TokenPtr(CurrentToken)^.TokenType = ttDQIdent) and (AnsiQuotes or (ADbIdentType in [ditUser, ditHost, ditConstraint, ditColumnAlias, ditCharset, ditCollation]))
      or (TokenPtr(CurrentToken)^.TokenType = ttString) and (ADbIdentType in [ditUser, ditHost, ditConstraint, ditColumnAlias, ditCharset, ditCollation])
      or (TokenPtr(CurrentToken)^.OperatorType = otMulti) and JokerAllowed and (ADbIdentType in [ditDatabase, ditTable, ditProcedure, ditFunction, ditField])) then
    begin
      TokenPtr(CurrentToken)^.FOperatorType := otNone;
      Result := ApplyCurrentToken(utDbIdent);
    end
    else if ((ADbIdentType = ditKey) and (TokenPtr(CurrentToken)^.TokenType = ttIdent) and (TokenPtr(CurrentToken)^.KeywordIndex = kiPRIMARY)) then
      Result := ApplyCurrentToken(utKeyword)
    else if ((ADbIdentType = ditUnknown) and (ReservedWordList.IndexOf(TokenPtr(CurrentToken)^.FText, TokenPtr(CurrentToken)^.FLength) < 0)) then
      Result := ApplyCurrentToken(utDbIdent)
    else
      Result := SetError(PE_UnexpectedToken);
  end;

var
  DbIdentType: TDbIdentType;
  Nodes: TDbIdent.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);
  DbIdentType := ADbIdentType;

  if (EndOfStmt(CurrentToken)) then
  begin
    case (ADbIdentType) of
      ditDatabase:
        CompletionList.AddList(ditDatabase);
      ditTable,
      ditProcedure,
      ditFunction,
      ditTrigger,
      ditEvent:
        begin
          CompletionList.AddList(ditDatabase);
          CompletionList.AddList(ADbIdentType);
        end;
      ditKey,
      ditField,
      ditForeignKey:
        begin
          CompletionList.AddList(ditDatabase);
          CompletionList.AddList(ditTable);
          CompletionList.AddList(ADbIdentType);
        end;
      ditEngine,
      ditCharset,
      ditCollation:
        CompletionList.AddList(ADbIdentType);
    end;
    SetError(PE_IncompleteStmt);
  end
  else
    Nodes.Ident := ParseDbIdentToken(False);

  if (not ErrorFound
    and FullQualified
    and IsSymbol(ttDot)) then
    case (ADbIdentType) of
      ditTable,
      ditFunction,
      ditProcedure,
      ditTrigger,
      ditEvent:
        begin
          Nodes.DatabaseIdent := Nodes.Ident;
          Nodes.DatabaseDot := ApplyCurrentToken(utSymbol);

          if (EndOfStmt(CurrentToken)) then
          begin
            CompletionList.AddList(ADbIdentType, TokenPtr(Nodes.DatabaseIdent)^.AsString);
            Nodes.Ident := 0;
          end
          else if (TokenPtr(CurrentToken)^.TokenType = ttInteger) then
            Nodes.Ident := ApplyCurrentToken(utDbIdent)
          else
            Nodes.Ident := ParseDbIdentToken(True);
        end;
      ditKey,
      ditField,
      ditForeignKey:
        begin
          Nodes.TableIdent := Nodes.Ident;
          Nodes.TableDot := ApplyCurrentToken(utSymbol);

          if (EndOfStmt(CurrentToken)) then
          begin
            CompletionList.AddList(ditTable, TokenPtr(Nodes.TableIdent)^.AsString);
            CompletionList.AddList(ADbIdentType, '', TokenPtr(Nodes.TableIdent)^.AsString);
            Nodes.Ident := SetError(PE_IncompleteStmt);
          end
          else
          begin
            if (TokenPtr(CurrentToken)^.OperatorType = otMulti) then
              DbIdentType := ditUnknown;
            if (TokenPtr(CurrentToken)^.TokenType = ttInteger) then
              Nodes.Ident := ApplyCurrentToken(utDbIdent)
            else
              Nodes.Ident := ParseDbIdentToken(True);

            if (not ErrorFound
              and FullQualified
              and IsSymbol(ttDot)) then
            begin
              Nodes.DatabaseIdent := Nodes.TableIdent;
              Nodes.DatabaseDot := Nodes.TableDot;
              Nodes.TableIdent := Nodes.Ident;
              Nodes.TableDot := ApplyCurrentToken(utSymbol);

              if (EndOfStmt(CurrentToken)) then
              begin
                CompletionList.AddList(ADbIdentType, TokenPtr(Nodes.DatabaseIdent)^.AsString, TokenPtr(Nodes.TableIdent)^.AsString);
                Nodes.Ident := SetError(PE_IncompleteStmt);
              end
              else if (TokenPtr(CurrentToken)^.TokenType = ttInteger) then
                Nodes.Ident := ApplyCurrentToken(utDbIdent)
              else
                Nodes.Ident := ParseDbIdentToken(True);
            end;
          end;
        end;
    end;

  Result := TDbIdent.Create(Self, DbIdentType, Nodes);

  if (Parse.InCreateTriggerStmt and (Nodes.DatabaseIdent = 0) and IsToken(Nodes.TableIdent) and ((TokenPtr(Nodes.TableIdent)^.KeywordIndex = kiNEW) or (TokenPtr(Nodes.TableIdent)^.KeywordIndex = kiOLD))) then
    PDbIdent(NodePtr(Result))^.FDbTableType := ditTriggerRec;
end;

function TSQLParser.ParseDefinerValue(): TOffset;
var
  Nodes: TValue.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Ident := ParseTag(kiDEFINER);

  if (not ErrorFound) then
    Nodes.AssignToken := ApplyCurrentToken(utOperator);

  if (not ErrorFound) then
    Nodes.Expr := ParseAccountIdent();

  Result := TValue.Create(Self, Nodes);
end;

function TSQLParser.ParseDeallocatePrepareStmt(): TOffset;
var
  Nodes: TDeallocatePrepareStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiDEALLOCATE, kiPREPARE)) then
    Nodes.StmtTag := ParseTag(kiDEALLOCATE, kiPREPARE)
  else
    Nodes.StmtTag := ParseTag(kiDROP, kiPREPARE);

  if (not ErrorFound) then
    Nodes.Ident := ParseVariableIdent();

  Result := TDeallocatePrepareStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDeclareConditionStmt(const StmtTag: TOffset; const IdentList: TOffset): TOffset;
var
  Nodes: TDeclareConditionStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := StmtTag;

  Nodes.IdentList := IdentList;

  if (NodePtr(IdentList)^.NodeType <> ntList) then
    SetError(PE_Unknown)
  else if (PList(NodePtr(IdentList))^.ElementCount > 1) then
    SetError(PE_UnexpectedToken)
  else if (PNode(PList(NodePtr(IdentList))^.FirstElement)^.NodeType <> ntDbIdent) then
    SetError(PE_Unknown)
  else
    PDbIdent(PList(NodePtr(IdentList))^.FirstElement)^.FDbIdentType := ditCursor;

  if (not ErrorFound) then
    Nodes.ConditionTag := ParseTag(kiCONDITION, kiFOR);

  if (not ErrorFound) then
    if (not IsTag(kiSQLSTATE)) then
      Nodes.ErrorCode := ParseInteger()
    else
    begin
      if (IsTag(kiSQLSTATE, kiVALUE)) then
        Nodes.SQLStateTag := ParseTag(kiSQLSTATE, kiVALUE)
      else
        Nodes.SQLStateTag := ParseTag(kiSQLSTATE);

      if (not ErrorFound) then
        Nodes.ErrorString := ParseString();
    end
    else if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  Result := TDeclareConditionStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDeclareCursorStmt(const StmtTag: TOffset; const IdentList: TOffset): TOffset;
var
  Nodes: TDeclareCursorStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := StmtTag;

  Nodes.IdentList := IdentList;

  if (NodePtr(IdentList)^.NodeType <> ntList) then
    SetError(PE_Unknown)
  else if (PList(NodePtr(IdentList))^.ElementCount > 1) then
    SetError(PE_UnexpectedToken)
  else if (PNode(PList(NodePtr(IdentList))^.FirstElement)^.NodeType <> ntDbIdent) then
    SetError(PE_Unknown)
  else
    PDbIdent(PList(NodePtr(IdentList))^.FirstElement)^.FDbIdentType := ditCursor;

  if (not ErrorFound) then
    Nodes.CursorTag := ParseTag(kiCURSOR, kiFOR);

  if (not ErrorFound) then
    Nodes.SelectStmt := ParseSelectStmt(True);

  Result := TDeclareCursorStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDeclareHandlerStmt(): TOffset;
var
  Nodes: TDeclareHandlerStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiDECLARE);

  if (not ErrorFound) then
    if (IsTag(kiCONTINUE)) then
      Nodes.ActionTag := ParseTag(kiCONTINUE)
    else if (IsTag(kiEXIT)) then
      Nodes.ActionTag := ParseTag(kiEXIT)
    else if (IsTag(kiUNDO)) then
      Nodes.ActionTag := ParseTag(kiUNDO)
    else if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
    Nodes.HandlerTag := ParseTag(kiHANDLER);

  if (not ErrorFound) then
    Nodes.ForTag := ParseTag(kiFOR);

  if (not ErrorFound) then
    Nodes.ConditionsList := ParseList(False, ParseDeclareHandlerStmtCondition);

  if (not ErrorFound) then
  begin
    Nodes.Stmt := ParsePL_SQLStmt();
    if (not ErrorFound and (Nodes.Stmt = 0)) then
      SetError(PE_IncompleteStmt);
  end;

  Result := TDeclareHandlerStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDeclareHandlerStmtCondition(): TOffset;
begin
  Result := 0;
  if (TokenPtr(CurrentToken)^.TokenType = ttInteger) then
    Result := ParseInteger()
  else if (IsTag(kiSQLSTATE, kiVALUE)) then
    Result := ParseValue(WordIndices(kiSQLSTATE, kiVALUE), vaNo, ParseExpr)
  else if (IsTag(kiSQLSTATE)) then
    Result := ParseValue(kiSQLSTATE, vaNo, ParseExpr)
  else if (IsTag(kiSQLWARNING)) then
    Result := ParseTag(kiSQLWARNING)
  else if (IsTag(kiNOT, kiFOUND)) then
    Result := ParseTag(kiNOT, kiFOUND)
  else if (IsTag(kiSQLEXCEPTION)) then
    Result := ParseTag(kiSQLEXCEPTION)
  else if (TokenPtr(CurrentToken)^.TokenType in ttIdents) then // Must be in the end, because keywords are in ttIdents too
    Result := ParseDbIdent(ditCondition)
  else if (EndOfStmt(CurrentToken)) then
    SetError(PE_IncompleteStmt)
  else
    SetError(PE_UnexpectedToken);
end;

function TSQLParser.ParseDeclareStmt(): TOffset;
var
  Nodes: TDeclareStmt.TNodes;
  IdentList: TOffset;
  StmtTag: TOffset;
  Token: PToken;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiDECLARE, kiCONTINUE, kiHANDLER)
    or IsTag(kiDECLARE, kiEXIT, kiHANDLER)
    or IsTag(kiDECLARE, kiUNDO, kiHANDLER)) then
    Result := ParseDeclareHandlerStmt()
  else
  begin
    StmtTag := ParseTag(kiDECLARE);

    if (not ErrorFound) then
      IdentList := ParseList(False, ParseDbIdent)
    else
      IdentList := 0;

    if (ErrorFound) then
      Result := 0
    else if (IsTag(kiCONDITION, kiFOR)) then
      Result := ParseDeclareConditionStmt(StmtTag, IdentList)
    else if (not ErrorFound and IsTag(kiCURSOR, kiFOR)) then
      Result := ParseDeclareCursorStmt(StmtTag, IdentList)
    else
    begin
      Nodes.StmtTag := StmtTag;

      Nodes.IdentList := IdentList;

      if (not ErrorFound) then
        Nodes.TypeNode := ParseDatatype();

      if (not ErrorFound) then
        if (IsTag(kiDEFAULT)) then
          Nodes.DefaultValue := ParseValue(kiDEFAULT, vaNo, ParseExpr);

      Result := TDeclareStmt.Create(Self, Nodes);


      // change FDbIdentType to ditCompoundVariabel for IdentList elements

      if (IsRange(IdentList)) then
      begin
        Token := RangePtr(IdentList)^.FirstToken;
        while (Assigned(Token)) do
        begin
          if ((Token^.UsageType = utDbIdent)
            and Assigned(Token^.ParentNode) and (PNode(Token^.ParentNode)^.NodeType = ntDbIdent)) then
            PDbIdent(Token^.ParentNode)^.FDbIdentType := ditCompoundVariable;

          if (Token = RangePtr(IdentList)^.LastToken) then
            Token := nil
          else
            Token := Token^.NextToken;
        end;
      end;
    end;
  end;
end;

function TSQLParser.ParseDefaultFunc(): TOffset;
var
  Length: Integer;
  Nodes: TDefaultFunc.TNodes;
  Text: PChar;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  TokenPtr(CurrentToken)^.GetText(Text, Length);
  if (FunctionList.IndexOf(Text, Length) >= 0) then
    Nodes.Ident := ApplyCurrentToken(utDbIdent)
  else
    Nodes.Ident := ParseFunctionIdent();

  if (not ErrorFound) then
    Nodes.ArgumentsList := ParseList(True, ParseExpr);

  Result := TDefaultFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseDeleteStmt(): TOffset;
var
  Nodes: TDeleteStmt.TNodes;
  TableCount: Integer;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);
  TableCount := 1;

  Nodes.DeleteTag := ParseTag(kiDELETE);

  if (not ErrorFound) then
    if (IsTag(kiLOW_PRIORITY)) then
      Nodes.LowPriorityTag := ParseTag(kiLOW_PRIORITY);

  if (not ErrorFound) then
    if (IsTag(kiQUICK)) then
      Nodes.QuickTag := ParseTag(kiQUICK);

  if (not ErrorFound) then
    if (IsTag(kiIGNORE)) then
      Nodes.IgnoreTag := ParseTag(kiIGNORE);

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
    begin
      Nodes.From1.Tag := ParseTag(kiFROM);

      if (not ErrorFound) then
      begin
        Nodes.From1.List := ParseList(False, ParseTableIdent);
        if (not ErrorFound) then
          if (Nodes.From1.List = 0) then
            TableCount := 0
          else
            TableCount := PList(NodePtr(Nodes.From1.List))^.ElementCount;
      end;

      if (not ErrorFound) then
        if ((TableCount = 1) and IsTag(kiPARTITION)) then
        begin
          Nodes.Partition.Tag := ParseTag(kiPARTITION);

          if (not ErrorFound) then
            Nodes.Partition.List := ParseList(True, ParsePartitionIdent);
        end
        else if ((TableCount > 1) or IsTag(kiUSING)) then
        begin
          Nodes.Using.Tag := ParseTag(kiUSING);

          if (not ErrorFound) then
            Nodes.Using.TableReferenceList := ParseList(False, ParseSelectStmtTableEscapedReference);
        end;
    end
    else
    begin
      Nodes.From1.List := ParseList(False, ParseDeleteStmtTableIdent);

      if (not ErrorFound) then
        Nodes.From2.Tag := ParseTag(kiFROM);

      if (not ErrorFound) then
        Nodes.From2.TableReferenceList := ParseList(False, ParseSelectStmtTableEscapedReference);
    end;

  if (not ErrorFound) then
    if (IsTag(kiWHERE)) then
    begin
      Nodes.Where.Tag := ParseTag(kiWHERE);

      if (not ErrorFound) then
        Nodes.Where.Expr := ParseExpr();
    end;

  if (not ErrorFound and (TableCount = 1)) then
    if (IsTag(kiORDER, kiBY)) then
    begin
      Nodes.OrderBy.Tag := ParseTag(kiORDER, kiBY);

      if (not ErrorFound) then
        Nodes.OrderBy.List := ParseList(False, ParseSelectStmtOrder);
    end;

  if (not ErrorFound and (TableCount = 1)) then
    if (IsTag(kiLIMIT)) then
    begin
      Nodes.Limit.Tag := ParseTag(kiLIMIT);

      if (not ErrorFound) then
        Nodes.Limit.Token := ParseExpr();
    end;

  Result := TDeleteStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDeleteStmtTableIdent(): TOffset;
begin
  Result := 0;

  if (EndOfStmt(NextToken[1]) or not IsNextSymbol(1, ttDot)) then
    Result := ParseDbIdent(ditTable, False)
  else if (EndOfStmt(NextToken[2])) then
    SetError(PE_IncompleteStmt, NextToken[1])
  else if (TokenPtr(NextToken[2])^.OperatorType <> otMulti) then
    SetError(PE_UnexpectedToken, NextToken[2])
  else
    Result := ParseDbIdent(ditField, True, True);
end;

function TSQLParser.ParseDoStmt(): TOffset;
var
  Nodes: TDoStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.DoTag := ParseTag(kiDO);

  if (not ErrorFound) then
    Nodes.ExprList := ParseList(False, ParseExpr);

  Result := TDoStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDropDatabaseStmt(): TOffset;
var
  Nodes: TDropDatabaseStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiDROP, kiDATABASE)) then
    Nodes.StmtTag := ParseTag(kiDROP, kiDATABASE)
  else
    Nodes.StmtTag := ParseTag(kiDROP, kiSCHEMA);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiEXISTS)) then
      Nodes.IfExistsTag := ParseTag(kiIF, kiEXISTS);

  if (not ErrorFound) then
    Nodes.DatabaseIdent := ParseDatabaseIdent();

  Result := TDropDatabaseStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDropEventStmt(): TOffset;
var
  Nodes: TDropEventStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiDROP, kiEVENT);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiEXISTS)) then
      Nodes.IfExistsTag := ParseTag(kiIF, kiEXISTS);

  if (not ErrorFound) then
    Nodes.EventIdent := ParseDbIdent(ditEvent);

  Result := TDropEventStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDropIndexStmt(): TOffset;
var
  Found: Boolean;
  Nodes: TDropIndexStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiDROP, kiINDEX);

  if (not ErrorFound) then
    Nodes.IndexIdent := ParseKeyIdent();

  if (not ErrorFound) then
    Nodes.OnTag := ParseTag(kiON);

  if (not ErrorFound) then
    Nodes.TableIdent := ParseTableIdent();

  Found := True;
  while (not ErrorFound and Found) do
    if ((Nodes.AlgorithmValue = 0) and IsTag(kiALGORITHM)) then
      Nodes.AlgorithmValue := ParseValue(kiALGORITHM, vaAuto, WordIndices(kiDEFAULT, kiINPLACE, kiCOPY))
    else if ((Nodes.LockValue = 0) and IsTag(kiLOCK)) then
      Nodes.LockValue := ParseValue(kiLOCK, vaAuto, WordIndices(kiDEFAULT, kiNONE, kiSHARED, kiEXCLUSIVE))
    else
      Found := False;

  Result := TDropIndexStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDropRoutineStmt(const ARoutineType: TRoutineType): TOffset;
var
  Nodes: TDropRoutineStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (ARoutineType = rtFunction) then
    Nodes.StmtTag := ParseTag(kiDROP, kiFUNCTION)
  else
    Nodes.StmtTag := ParseTag(kiDROP, kiPROCEDURE);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiEXISTS)) then
      Nodes.IfExistsTag := ParseTag(kiIF, kiEXISTS);

  if (not ErrorFound) then
    if (ARoutineType = rtFunction) then
      Nodes.RoutineIdent := ParseFunctionIdent()
    else
      Nodes.RoutineIdent := ParseProcedureIdent();

  Result := TDropRoutineStmt.Create(Self, ARoutineType, Nodes);
end;

function TSQLParser.ParseDropServerStmt(): TOffset;
var
  Nodes: TDropServerStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiDROP, kiSERVER);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiEXISTS)) then
      Nodes.IfExistsTag := ParseTag(kiIF, kiEXISTS);

  if (not ErrorFound) then
    Nodes.ServerIdent := ParseDbIdent();

  Result := TDropServerStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDropTablespaceStmt(): TOffset;
var
  Nodes: TDropTablespaceStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiDROP, kiTABLESPACE);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent();

  if (not ErrorFound) then
    if (IsTag(kiENGINE)) then
      Nodes.EngineValue := ParseValue(kiENGINE, vaAuto, ParseEngineIdent);

  Result := TDropTablespaceStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDropTableStmt(): TOffset;
var
  Nodes: TDropTableStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiDROP, kiTABLE)) then
    Nodes.StmtTag := ParseTag(kiDROP, kiTABLE)
  else
    Nodes.StmtTag := ParseTag(kiDROP, kiTEMPORARY, kiTABLE);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiEXISTS)) then
      Nodes.IfExistsTag := ParseTag(kiIF, kiEXISTS);

  if (not ErrorFound) then
    Nodes.TableIdentList := ParseList(False, ParseTableIdent);

  if (not ErrorFound) then
    if (IsTag(kiRESTRICT)) then
      Nodes.RestrictCascadeTag := ParseTag(kiRESTRICT)
    else if (IsTag(kiCASCADE)) then
      Nodes.RestrictCascadeTag := ParseTag(kiCASCADE);

  Result := TDropTableStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDropTriggerStmt(): TOffset;
var
  Nodes: TDropTriggerStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiDROP, kiTrigger);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiEXISTS)) then
      Nodes.IfExistsTag := ParseTag(kiIF, kiEXISTS);

  if (not ErrorFound) then
    Nodes.TriggerIdent := ParseTriggerIdent();

  Result := TDropTriggerStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDropUserStmt(): TOffset;
var
  Nodes: TDropUserStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiDROP, kiUSER);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiExists)) then
      Nodes.IfExistsTag := ParseTag(kiIF, kiEXISTS);

  if (not ErrorFound) then
    Nodes.UserList := ParseList(False, ParseAccountIdent);

  Result := TDropUserStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseDropViewStmt(): TOffset;
var
  Nodes: TDropViewStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiDROP, kiVIEW);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiEXISTS)) then
      Nodes.IfExistsTag := ParseTag(kiIF, kiEXISTS);

  if (not ErrorFound) then
    Nodes.ViewIdentList := ParseList(False, ParseTableIdent);

  if (not ErrorFound) then
    if (IsTag(kiRESTRICT)) then
      Nodes.RestrictCascadeTag := ParseTag(kiRESTRICT)
    else if (IsTag(kiCASCADE)) then
      Nodes.RestrictCascadeTag := ParseTag(kiCASCADE);

  Result := TDropViewStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseEventIdent(): TOffset;
begin
  Result := ParseDbIdent(ditEvent);
end;

function TSQLParser.ParseEndLabel(): TOffset;
var
  Nodes: TEndLabel.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.LabelToken := ApplyCurrentToken(utLabel);

  Result := TEndLabel.Create(Self, Nodes);
end;

function TSQLParser.ParseEngineIdent(): TOffset;
begin
  Result := ParseDbIdent(ditEngine, False);
end;

function TSQLParser.ParseExecuteStmt(): TOffset;
var
  Nodes: TExecuteStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiEXECUTE);

  if (not ErrorFound) then
    Nodes.StmtVariable := ParseVariableIdent();

  if (not ErrorFound) then
    if (IsTag(kiUSING)) then
    begin
      Nodes.UsingTag := ParseTag(kiUSING);

      if (not ErrorFound) then
        Nodes.VariableIdents := ParseList(False, ParseVariableIdent);
    end;

  Result := TExecuteStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseExplainStmt(): TOffset;
var
  Nodes: TExplainStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiDESC)) then
    Nodes.StmtTag := ParseTag(kiDESC)
  else if (IsTag(kiDESCRIBE)) then
    Nodes.StmtTag := ParseTag(kiDESCRIBE)
  else
    Nodes.StmtTag := ParseTag(kiEXPLAIN);

  if (not ErrorFound) then
    if (not IsTag(kiEXTENDED)
      and not IsTag(kiPARTITIONS)
      and not IsTag(kiFORMAT)
      and not IsTag(kiSELECT)
      and not IsTag(kiDELETE)
      and not IsTag(kiINSERT)
      and not IsTag(kiREPLACE)
      and not IsTag(kiUPDATE)
      and not IsTag(kiFOR)) then
    begin
      Nodes.TableIdent := ParseTableIdent();

      if (not ErrorFound) then
        if (not EndOfStmt(CurrentToken)) then
          Nodes.FieldIdent := ParseFieldIdent();
    end
    else
    begin
      if (IsTag(kiEXTENDED)) then
        Nodes.ExplainType := ParseTag(kiEXTENDED)
      else if (IsTag(kiPARTITIONS)) then
        Nodes.ExplainType := ParseTag(kiPARTITIONS)
      else if (IsTag(kiFORMAT)) then
        Nodes.ExplainType := ParseValue(kiFORMAT, vaYes, WordIndices(kiTRADITIONAL, kiJSON));

      if (not ErrorFound) then
        if (IsSelectStmt()) then
          Nodes.ExplainStmt := ParseSelectStmt(True)
        else if (IsTag(kiDELETE)) then
          Nodes.ExplainStmt := ParseDeleteStmt()
        else if (IsTag(kiINSERT)) then
          Nodes.ExplainStmt := ParseInsertStmt(False)
        else if (IsTag(kiREPLACE)) then
          Nodes.ExplainStmt := ParseInsertStmt(True)
        else if (IsTag(kiUPDATE)) then
          Nodes.ExplainStmt := ParseUpdateStmt()
        else if (IsTag(kiFOR, kiCONNECTION)) then
          Nodes.ForConnectionValue := ParseValue(WordIndices(kiFOR, kiCONNECTION), vaNo, ParseInteger)
        else if (EndOfStmt(CurrentToken)) then
          SetError(PE_IncompleteStmt)
        else
          SetError(PE_UnexpectedToken);
    end;

  Result := TExplainStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseExpr(): TOffset;
begin
  Result := ParseExpr([eoIn, eoOperators]);
end;

function TSQLParser.ParseExpr(const Options: TExprOptions): TOffset;
var
  Nodes: TOffsetList;

  procedure AddOperandsToCompletionList();
  var
    I: Integer;
  begin
    if ((Nodes.Count >= 4)
      and IsToken(Nodes[Nodes.Count - 4]) and (TokenPtr(Nodes[Nodes.Count - 4])^.TokenType in ttIdents)
      and IsToken(Nodes[Nodes.Count - 3]) and (TokenPtr(Nodes[Nodes.Count - 3])^.OperatorType = otDot)
      and IsToken(Nodes[Nodes.Count - 2]) and (TokenPtr(Nodes[Nodes.Count - 2])^.TokenType in ttIdents)
      and IsToken(Nodes[Nodes.Count - 1]) and (TokenPtr(Nodes[Nodes.Count - 1])^.OperatorType = otDot)) then
    begin
      CompletionList.AddList(ditField, TokenPtr(Nodes[Nodes.Count - 4])^.AsString, TokenPtr(Nodes[Nodes.Count - 2])^.AsString);
    end
    else if ((Nodes.Count >= 2)
      and IsToken(Nodes[Nodes.Count - 2]) and (TokenPtr(Nodes[Nodes.Count - 2])^.TokenType in ttIdents)
      and IsToken(Nodes[Nodes.Count - 1]) and (TokenPtr(Nodes[Nodes.Count - 1])^.OperatorType = otDot)) then
    begin
      CompletionList.AddList(ditTable, TokenPtr(Nodes[Nodes.Count - 2])^.AsString);
      CompletionList.AddList(ditField, '', TokenPtr(Nodes[Nodes.Count - 2])^.AsString);
    end
    else if ((Nodes.Count = 0) or IsOperator(Nodes[Nodes.Count - 1])) then
    begin
      for I := 0 to ConstantList.Count - 1 do
        CompletionList.AddConst(ConstantList[I]);
      for I := 0 to FunctionList.Count - 1 do
        CompletionList.AddText(FunctionList[I]);
      CompletionList.AddList(ditDatabase);
      CompletionList.AddList(ditFunction);
      CompletionList.AddList(ditTable);
      CompletionList.AddList(ditField);
    end;
  end;

var
  KeywordIndex: Integer;
  Length: Integer;
  ListNodes: TList.TNodes;
  NodeIndex: Integer;
  Operands: TOffsetList;
  OperatorPrecedence: Integer;
  Text: PChar;
begin
  Nodes.Init();

  if (not EndOfStmt(CurrentToken)) then
    repeat
      if (TokenPtr(CurrentToken)^.TokenType = ttInteger) then
        Nodes.Add(ApplyCurrentToken(utInteger))
      else if (TokenPtr(CurrentToken)^.TokenType = ttNumeric) then
        Nodes.Add(ApplyCurrentToken(utNumeric))
      else if ((TokenPtr(CurrentToken)^.TokenType = ttString)
        or ((TokenPtr(CurrentToken)^.TokenType = ttDQIdent) and not AnsiQuotes)) then
        Nodes.Add(ApplyCurrentToken(utString))
      else if (TokenPtr(CurrentToken)^.TokenType = ttAt) then
        Nodes.Add(ParseVariableIdent())
      else if (IsSymbol(ttOpenBracket)) then
        if (IsNextTag(1, kiSELECT)) then
          Nodes.Add(ParseSubSelectStmt())
        else if (not (eoOperators in Options)) then
          SetError(PE_UnexpectedToken)
        else
          Nodes.Add(ParseList(True, ParseExpr, ttComma, False))
      else if (TokenPtr(CurrentToken)^.KeywordIndex = kiBINARY) then
        // BINARY is operator and function, so we have to handle it separately
        if (IsNextSymbol(1, ttOpenBracket)) then
        begin
          TokenPtr(CurrentToken)^.FOperatorType := otNone;
          Nodes.Add(ParseDefaultFunc());
        end
        else
          Nodes.Add(ApplyCurrentToken(utOperator))
      else if (TokenPtr(CurrentToken)^.KeywordIndex = kiMOD) then
        // MOD is operator and function, so we have to handle it separately
        if ((Nodes.Count = 0) or IsOperator(Nodes[Nodes.Count - 1])) then
          Nodes.Add(ParseDefaultFunc())
        else
          Nodes.Add(ApplyCurrentToken(utOperator))
      else if (TokenPtr(CurrentToken)^.OperatorType <> otNone) then
        if ((TokenPtr(CurrentToken)^.OperatorType = otMulti) and (Nodes.Count = 0) and (eoAllFields in Options)) then
        begin
          TokenPtr(CurrentToken)^.FOperatorType := otNone;
          Nodes.Add(ApplyCurrentToken(utDbIdent));
          break; // * is a complete expression!
        end
        else if ((TokenPtr(CurrentToken)^.OperatorType = otMinus) and ((Nodes.Count = 0) or IsOperator(Nodes[Nodes.Count - 1]))) then
        begin
          TokenPtr(CurrentToken)^.FOperatorType := otUnaryMinus;
          Nodes.Add(ApplyCurrentToken(utOperator));
        end
        else if ((TokenPtr(CurrentToken)^.OperatorType = otPlus) and ((Nodes.Count = 0) or IsOperator(Nodes[Nodes.Count - 1]))) then
        begin
          TokenPtr(CurrentToken)^.FOperatorType := otUnaryPlus;
          Nodes.Add(ApplyCurrentToken(utOperator));
        end
        else if ((TokenPtr(CurrentToken)^.OperatorType in [otUnaryNot, otNot]) and ((Nodes.Count = 0) or IsOperator(Nodes[Nodes.Count - 1]))) then
          Nodes.Add(ApplyCurrentToken(utOperator))
        else if (TokenPtr(CurrentToken)^.OperatorType = otInterval) then
          Nodes.Add(ParseInterval())
        else if (TokenPtr(CurrentToken)^.OperatorType = otCase) then
          Nodes.Add(ParseCaseOp())
        else if (((Nodes.Count = 0) or IsOperator(Nodes[Nodes.Count - 1]) and ((TokenPtr(Nodes[Nodes.Count - 1])^.OperatorType <> otNot) or not (TokenPtr(CurrentToken)^.OperatorType in [otBetween, otIn, otLike, otRegexp])))
          and not (TokenPtr(CurrentToken)^.OperatorType in otUnaryOperators)) then
          SetError(PE_UnexpectedToken)
        else
          Nodes.Add(ApplyCurrentToken(utOperator))
      else if (TokenPtr(CurrentToken)^.TokenType in ttIdents) then
        if (IsTag(kiEXISTS)
          or IsTag(kiNOT, kiEXISTS)
          or (Nodes.Count > 0) and IsToken(Nodes[Nodes.Count - 1]) and (TokenPtr(Nodes[Nodes.Count - 1])^.OperatorType in [otEqual, otGreater, otLess, otGreaterEqual, otLessEqual, otNotEqual])
            and (IsTag(kiALL) or IsTag(kiANY) or IsTag(kiNOT, kiALL) or IsTag(kiNOT, kiANY) or IsTag(kiNOT, kiSOME) or IsTag(kiSOME))) then
          Nodes.Add(ParseSubquery())
        else if (IsNextSymbol(1, ttOpenBracket)) then
        begin
          TokenPtr(CurrentToken)^.GetText(Text, Length);
          if ((Length = 7) and (StrLIComp(Text, 'ADDDATE', Length) = 0)) then
            Nodes.Add(ParseDateAddFunc())
          else if ((Length = 3) and (StrLIComp(Text, 'AVG', Length) = 0)) then
            Nodes.Add(ParseSumFunc())
          else if ((Length = 4) and (StrLIComp(Text, 'CAST', Length) = 0)) then
            Nodes.Add(ParseCastFunc())
          else if ((Length = 4) and (StrLIComp(Text, 'CHAR', Length) = 0)) then
            Nodes.Add(ParseCharFunc())
          else if ((Length = 7) and (StrLIComp(Text, 'CONVERT', Length) = 0)) then
            Nodes.Add(ParseConvertFunc())
          else if ((Length = 5) and (StrLIComp(Text, 'COUNT', Length) = 0)) then
            Nodes.Add(ParseCountFunc())
          else if ((Length = 8) and (StrLIComp(Text, 'DATE_ADD', Length) = 0)) then
            Nodes.Add(ParseDateAddFunc())
          else if ((Length = 8) and (StrLIComp(Text, 'DATE_SUB', Length) = 0)) then
            Nodes.Add(ParseDateAddFunc())
          else if ((Length = 7) and (StrLIComp(Text, 'EXTRACT', Length) = 0)) then
            Nodes.Add(ParseExtractFunc())
          else if ((Length = 12) and (StrLIComp(Text, 'GROUP_CONCAT', Length) = 0)) then
            Nodes.Add(ParseGroupConcatFunc())
          else if ((Length = 5) and (StrLIComp(Text, 'MATCH', Length) = 0)) then
            Nodes.Add(ParseMatchFunc())
          else if ((Length = 3) and (StrLIComp(Text, 'MAX', Length) = 0)) then
            Nodes.Add(ParseSumFunc())
          else if ((Length = 3) and (StrLIComp(Text, 'MIN', Length) = 0)) then
            Nodes.Add(ParseSumFunc())
          else if ((Length = 8) and (StrLIComp(Text, 'POSITION', Length) = 0)) then
            Nodes.Add(ParsePositionFunc())
          else if ((Length = 7) and (StrLIComp(Text, 'SUBDATE', Length) = 0)) then
            Nodes.Add(ParseDateAddFunc())
          else if ((Length = 6) and (StrLIComp(Text, 'SUBSTR', Length) = 0)) then
            Nodes.Add(ParseSubstringFunc())
          else if ((Length = 9) and (StrLIComp(Text, 'SUBSTRING', Length) = 0)) then
            Nodes.Add(ParseSubstringFunc())
          else if ((Length = 3) and (StrLIComp(Text, 'SUM', Length) = 0)) then
            Nodes.Add(ParseSumFunc())
          else if ((Length = 2) and (StrLIComp(Text, 'TIMESTAMPADD', Length) = 0)) then
            Nodes.Add(ParseTimestampAddFunc())
          else if ((Length = 13) and (StrLIComp(Text, 'TIMESTAMPDIFF', Length) = 0)) then
            Nodes.Add(ParseTimestampDiffFunc())
          else if ((Length = 4) and (StrLIComp(Text, 'TRIM', Length) = 0)) then
            Nodes.Add(ParseTrimFunc())
          else if ((Length = 13) and (StrLIComp(Text, 'WEIGHT_STRING', Length) = 0)) then
            Nodes.Add(ParseWeightStringFunc())
          else if ((FunctionList.IndexOf(Text, Length) < 0)
            and (ReservedWordList.IndexOf(Text, Length) >= 0)) then
            SetError(PE_UnexpectedToken)
          else
            Nodes.Add(ParseDefaultFunc()); // Func()
        end
        else if (ConstantList.IndexOf(TokenPtr(CurrentToken)^.FText, TokenPtr(CurrentToken)^.FLength) >= 0) then
          Nodes.Add(ParseConstIdent())
        else if (IsNextSymbol(1, ttDot)) then
          if (not EndOfStmt(NextToken[2]) and (TokenPtr(NextToken[2])^.TokenType in ttIdents)
            and not EndOfStmt(NextToken[3]) and (TokenPtr(NextToken[3])^.TokenType = ttOpenBracket)) then
            Nodes.Add(ParseDefaultFunc()) // Db.Func()
          else
            Nodes.Add(ParseDbIdent(ditField, True, eoAllFields in Options)) // Tbl.Clmn or Db.Tbl.Clmn
        else
          Nodes.Add(ParseDbIdent(ditUnknown, False, eoAllFields in Options))
      else
        SetError(PE_UnexpectedToken);

      Assert(ErrorFound or (Nodes.Count > 0) and (Nodes[Nodes.Count - 1] > 0));
    until (ErrorFound
      or EndOfStmt(CurrentToken)
      or IsOperator(CurrentToken) and not (eoOperators in Options)
      or not IsOperator(Nodes[Nodes.Count - 1]) and not IsOperator(CurrentToken)
      or not (eoIn in Options) and (TokenPtr(CurrentToken)^.OperatorType = otIn));

  if (not ErrorFound and (Nodes.Count > 1)) then
    for OperatorPrecedence := 1 to MaxOperatorPrecedence do
    begin
      NodeIndex := 0;
      while (not ErrorFound and (NodeIndex < Nodes.Count)) do
        if (not IsToken(Nodes[NodeIndex])
          or (OperatorPrecedenceByOperatorType[TokenPtr(Nodes[NodeIndex])^.OperatorType] <> OperatorPrecedence)) then
          Inc(NodeIndex)
        else
          case (TokenPtr(Nodes[NodeIndex])^.OperatorType) of
            otCase,
            otDot:
              SetError(PE_UnexpectedToken, Nodes[NodeIndex]);
            otBinary,
            otNot:
              if (NodeIndex + 1 = Nodes.Count) then
                begin
                  AddOperandsToCompletionList();
                  SetError(PE_IncompleteStmt);
                end
              else if (IsOperator(Nodes[NodeIndex + 1])) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex + 1])
              else
              begin
                Nodes[NodeIndex] := TUnaryOp.Create(Self, Nodes[NodeIndex], Nodes[NodeIndex + 1]);
                Nodes.Delete(NodeIndex + 1);
              end;
            otBitInversion,
            otUnaryMinus,
            otUnaryNot,
            otUnaryPlus:
              begin
                while ((NodeIndex + 1 < Nodes.Count)
                  and IsToken(Nodes[NodeIndex + 1]) and (TokenPtr(Nodes[NodeIndex + 1])^.OperatorType in [otBitInversion, otUnaryMinus, otUnaryNot, otUnaryPlus])) do
                  Inc(NodeIndex);
                if (NodeIndex + 1 = Nodes.Count) then
                begin
                  AddOperandsToCompletionList();
                  SetError(PE_IncompleteStmt);
                end
                else if (IsOperator(Nodes[NodeIndex + 1])) then
                  SetError(PE_UnexpectedToken, Nodes[NodeIndex + 1])
                else
                  repeat
                    Nodes[NodeIndex] := TUnaryOp.Create(Self, Nodes[NodeIndex], Nodes[NodeIndex + 1]);
                    Nodes.Delete(NodeIndex + 1);
                    if ((NodeIndex = 0) or not IsToken(Nodes[NodeIndex - 1]) or not (TokenPtr(Nodes[NodeIndex - 1])^.OperatorType in [otBitInversion, otUnaryMinus, otUnaryNot, otUnaryPlus])) then
                      break
                    else
                      Dec(NodeIndex);
                  until (False);
              end;
            otAnd,
            otAssign,
            otBitAND,
            otBitOR,
            otBitXOR,
            otCollate,
            otDiv,
            otDivision,
            otEqual,
            otGreater,
            otGreaterEqual,
            otLess,
            otLessEqual,
            otMinus,
            otMod,
            otMulti,
            otNotEqual,
            otNullSaveEqual,
            otOr,
            otPlus,
            otShiftLeft,
            otShiftRight,
            otXOr:
              if ((NodeIndex = 0) or IsOperator(Nodes[NodeIndex - 1])) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else
              begin
                Operands.Init();
                Operands.Add(Nodes[NodeIndex - 1]);
                repeat
                  if (NodeIndex + 1 = Nodes.Count) then
                  begin
                    AddOperandsToCompletionList();
                    SetError(PE_IncompleteStmt);
                  end
                  else if (IsOperator(Nodes[NodeIndex + 1])) then
                    SetError(PE_UnexpectedToken, Nodes[NodeIndex + 1])
                  else
                  begin
                    Operands.Add(TBinaryOp.Create(Self, Nodes[NodeIndex], Nodes[NodeIndex + 1]));
                    Nodes.Delete(NodeIndex, 2);
                  end;
                until (ErrorFound or (NodeIndex = Nodes.Count) or not IsToken(Nodes[NodeIndex]) or (OperatorPrecedenceByOperatorType[TokenPtr(Nodes[NodeIndex])^.OperatorType] <> OperatorPrecedence));

                FillChar(ListNodes, SizeOf(ListNodes), 0);
                Nodes[NodeIndex - 1] := TList.Create(Self, ListNodes, ttUnknown, @Operands);
                Dec(NodeIndex);
              end;
            otJSONExtract:
              if (NodeIndex = 0) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if (not (IsToken(Nodes[NodeIndex]) and (TokenPtr(Nodes[NodeIndex])^.DbIdentType in [ditUnknown, ditField]))
                and not ((NodePtr(Nodes[NodeIndex - 1])^.NodeType = ntDbIdent) and (PDbIdent(NodePtr(Nodes[NodeIndex - 1]))^.DbIdentType in [ditUnknown, ditField]))) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if (NodeIndex = Nodes.Count) then
              begin
                AddOperandsToCompletionList();
                SetError(PE_IncompleteStmt);
              end
              else
              begin
                Operands.Init();
                Operands.Add(Nodes[NodeIndex - 1]);
                Operands.Add(TBinaryOp.Create(Self, Nodes[NodeIndex], Nodes[NodeIndex + 1]));
                FillChar(ListNodes, SizeOf(ListNodes), 0);
                Nodes.Delete(NodeIndex, 2);
                Nodes[NodeIndex - 1] := TList.Create(Self, ListNodes, ttUnknown, @Operands);
                Dec(NodeIndex);
              end;
            otIs:
              if (NodeIndex = 0) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if (NodeIndex + 1 = Nodes.Count) then
              begin
                CompletionList.AddConst('FALSE');
                CompletionList.AddConst('NULL');
                CompletionList.AddConst('TRUE');
                CompletionList.AddConst('UNKNOWN');
                SetError(PE_IncompleteStmt);
              end
              else if ((NodePtr(Nodes[NodeIndex + 1])^.NodeType = ntDbIdent)
                and ((StrLIComp(PDbIdent(NodePtr(Nodes[NodeIndex + 1]))^.Ident^.FText, 'FALSE', 5) = 0)
                  or (StrLIComp(PDbIdent(NodePtr(Nodes[NodeIndex + 1]))^.Ident^.FText, 'NULL', 4) = 0)
                  or (StrLIComp(PDbIdent(NodePtr(Nodes[NodeIndex + 1]))^.Ident^.FText, 'TRUE', 4) = 0)
                  or (StrLIComp(PDbIdent(NodePtr(Nodes[NodeIndex + 1]))^.Ident^.FText, 'UNKNOWN', 7) = 0))) then
              begin // ... IS ...
                Nodes[NodeIndex - 1] := TIsOp.Create(Self, Nodes[NodeIndex - 1], Nodes[NodeIndex], 0, Nodes[NodeIndex + 1]);
                Nodes.Delete(NodeIndex, 2);
                Dec(NodeIndex);
              end
              else if (not IsToken(Nodes[NodeIndex + 1]) or (TokenPtr(Nodes[NodeIndex + 1])^.KeywordIndex <> kiNOT)) then
                SetError(PE_UnexpectedToken, NodePtr(Nodes[NodeIndex + 1])^.FirstToken^.Offset)
              else if (NodeIndex + 2 = Nodes.Count) then
              begin
                CompletionList.AddConst('FALSE');
                CompletionList.AddConst('NULL');
                CompletionList.AddConst('TRUE');
                CompletionList.AddConst('UNKNOWN');
                SetError(PE_IncompleteStmt);
              end
              else if ((NodePtr(Nodes[NodeIndex + 2])^.NodeType = ntDbIdent)
                and ((StrLIComp(PDbIdent(NodePtr(Nodes[NodeIndex + 2]))^.Ident^.FText, 'FALSE', 5) = 0)
                  or (StrLIComp(PDbIdent(NodePtr(Nodes[NodeIndex + 2]))^.Ident^.FText, 'NULL', 4) = 0)
                  or (StrLIComp(PDbIdent(NodePtr(Nodes[NodeIndex + 2]))^.Ident^.FText, 'TRUE', 4) = 0)
                  or (StrLIComp(PDbIdent(NodePtr(Nodes[NodeIndex + 2]))^.Ident^.FText, 'UNKNOWN', 7) = 0))) then
              begin // ... IS NOT ...
                Nodes[NodeIndex - 1] := TIsOp.Create(Self, Nodes[NodeIndex - 1], Nodes[NodeIndex], Nodes[NodeIndex + 1], Nodes[NodeIndex + 2]);
                Nodes.Delete(NodeIndex, 3);
                Dec(NodeIndex);
              end
              else
                SetError(PE_UnexpectedToken, NodePtr(Nodes[NodeIndex + 2])^.FirstToken^.Offset);
            otBetween:
              if (NodeIndex = 0) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if ((IsToken(Nodes[NodeIndex - 1]) and (TokenPtr(Nodes[NodeIndex - 1])^.KeywordIndex = kiNOT))
                and ((NodeIndex < 2) or IsOperator(Nodes[NodeIndex - 2]))) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if ((not IsToken(Nodes[NodeIndex - 1]) or (TokenPtr(Nodes[NodeIndex - 1])^.KeywordIndex <> kiNOT))
                and IsOperator(Nodes[NodeIndex - 1])) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if (NodeIndex + 2 = Nodes.Count) then
              begin
                CompletionList.AddTag(kiAND);
                SetError(PE_IncompleteStmt);
              end
              else if (not IsToken(Nodes[NodeIndex + 2]) or (TokenPtr(Nodes[NodeIndex + 2])^.OperatorType <> otAnd)) then
                SetError(PE_UnexpectedToken, NodePtr(Nodes[NodeIndex + 2])^.FirstToken^.Offset)
              else if (NodeIndex + 3 = Nodes.Count) then
              begin
                AddOperandsToCompletionList();
                SetError(PE_IncompleteStmt);
              end
              else if (IsOperator(Nodes[NodeIndex + 3])) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex + 3])
              else if (IsToken(Nodes[NodeIndex - 1]) and (TokenPtr(Nodes[NodeIndex - 1])^.KeywordIndex = kiNOT)) then
              begin // ... NOT BETWEEN ... AND ...
                Nodes[NodeIndex - 2] := TBetweenOp.Create(Self, Nodes[NodeIndex - 2], Nodes[NodeIndex - 1], Nodes[NodeIndex], Nodes[NodeIndex + 1], Nodes[NodeIndex + 2], Nodes[NodeIndex + 3]);
                Nodes.Delete(NodeIndex - 1, 5);
                Dec(NodeIndex, 2);
              end
              else
              begin // ... BETWEEN ... AND ...
                Nodes[NodeIndex - 1] := TBetweenOp.Create(Self, Nodes[NodeIndex - 1], 0, Nodes[NodeIndex], Nodes[NodeIndex + 1], Nodes[NodeIndex + 2], Nodes[NodeIndex + 3]);
                Nodes.Delete(NodeIndex, 4);
                Dec(NodeIndex);
              end;
            otIn:
              if (NodeIndex = 0) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if (IsToken(Nodes[NodeIndex - 1]) and (TokenPtr(Nodes[NodeIndex - 1])^.OperatorType = otNot)
                and ((NodeIndex < 2) or IsOperator(Nodes[NodeIndex - 2]))) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if (NodeIndex + 1 = Nodes.Count) then
                SetError(PE_IncompleteStmt)
              else if ((NodePtr(Nodes[NodeIndex + 1])^.NodeType <> ntSelectStmt)
                and (NodePtr(Nodes[NodeIndex + 1])^.NodeType <> ntList)) then
                SetError(PE_UnexpectedToken, NodePtr(Nodes[NodeIndex + 1])^.FirstToken^.Offset)
              else if (IsToken(Nodes[NodeIndex - 1]) and (TokenPtr(Nodes[NodeIndex - 1])^.OperatorType = otNot)) then
              begin // ... NOT IN (...)
                Nodes[NodeIndex - 2] := TInOp.Create(Self, Nodes[NodeIndex - 2], Nodes[NodeIndex - 1], Nodes[NodeIndex], Nodes[NodeIndex + 1]);
                Nodes.Delete(NodeIndex - 1, 3);
                Dec(NodeIndex, 2);
              end
              else
              begin // ... IN (...)
                Nodes[NodeIndex - 1] := TInOp.Create(Self, Nodes[NodeIndex - 1], 0, Nodes[NodeIndex], Nodes[NodeIndex + 1]);
                Nodes.Delete(NodeIndex, 2);
                Dec(NodeIndex);
              end;
            otLike:
              if (NodeIndex = 0) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if (IsToken(Nodes[NodeIndex - 1]) and (TokenPtr(Nodes[NodeIndex - 1])^.OperatorType = otNot)
                and ((NodeIndex < 2) or IsOperator(Nodes[NodeIndex - 2]))) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if ((not IsToken(Nodes[NodeIndex - 1]) or (TokenPtr(Nodes[NodeIndex - 1])^.KeywordIndex <> kiNOT))
                and IsOperator(Nodes[NodeIndex - 1])) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if (NodeIndex + 1 = Nodes.Count) then
              begin
                AddOperandsToCompletionList();
                SetError(PE_IncompleteStmt);
              end
              else if (IsOperator(Nodes[NodeIndex + 1])) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex + 1])
              else if (IsToken(Nodes[NodeIndex - 1]) and (TokenPtr(Nodes[NodeIndex - 1])^.OperatorType = otNot)) then
              begin // ... NOT LIKE ...
                if ((NodeIndex + 2 = Nodes.Count) or not IsToken(Nodes[NodeIndex + 2]) or (TokenPtr(Nodes[NodeIndex + 2])^.KeywordIndex <> kiESCAPE)) then
                begin // ... NOT LIKE ...
                  Nodes[NodeIndex - 2] := TLikeOp.Create(Self, Nodes[NodeIndex - 2], Nodes[NodeIndex - 1], Nodes[NodeIndex], Nodes[NodeIndex + 1], 0, 0);
                  Nodes.Delete(NodeIndex - 1, 3);
                  Dec(NodeIndex, 2);
                end
                else if (NodeIndex + 3 = Nodes.Count) then
                begin
                  AddOperandsToCompletionList();
                  SetError(PE_IncompleteStmt);
                end
                else if (IsOperator(Nodes[NodeIndex + 3])) then
                  SetError(PE_UnexpectedToken, Nodes[NodeIndex + 3])
                else
                begin // ... NOT LIKE ... ESCAPE ...
                  Nodes[NodeIndex - 2] := TLikeOp.Create(Self, Nodes[NodeIndex - 2], Nodes[NodeIndex - 1], Nodes[NodeIndex], Nodes[NodeIndex + 1], Nodes[NodeIndex + 2], Nodes[NodeIndex + 3]);
                  Nodes.Delete(NodeIndex - 1, 5);
                  Dec(NodeIndex, 4);
                end;
              end
              else
              begin // ... LIKE ...
                if ((NodeIndex + 2 = Nodes.Count) or not IsToken(Nodes[NodeIndex + 2]) or (TokenPtr(Nodes[NodeIndex + 2])^.KeywordIndex <> kiESCAPE)) then
                begin // ... LIKE ...
                  Nodes[NodeIndex - 1] := TLikeOp.Create(Self, Nodes[NodeIndex - 1], 0, Nodes[NodeIndex], Nodes[NodeIndex + 1], 0, 0);
                  Nodes.Delete(NodeIndex, 2);
                  Dec(NodeIndex);
                end
                else if (NodeIndex + 3 = Nodes.Count) then
                begin
                  AddOperandsToCompletionList();
                  SetError(PE_IncompleteStmt);
                end
                else if (IsOperator(Nodes[NodeIndex + 3])) then
                  SetError(PE_UnexpectedToken, Nodes[NodeIndex + 3])
                else
                begin // ... LIKE ... ESCAPE ...
                  Nodes[NodeIndex - 1] := TLikeOp.Create(Self, Nodes[NodeIndex - 1], 0, Nodes[NodeIndex], Nodes[NodeIndex + 1], Nodes[NodeIndex + 2], Nodes[NodeIndex + 3]);
                  Nodes.Delete(NodeIndex, 4);
                  Dec(NodeIndex);
                end
              end;
            otRegExp:
              if (NodeIndex = 0) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if (IsToken(Nodes[NodeIndex - 1]) and (TokenPtr(Nodes[NodeIndex - 1])^.OperatorType = otNot)
                and ((NodeIndex < 2) or IsOperator(Nodes[NodeIndex - 2]))) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if ((not IsToken(Nodes[NodeIndex - 1]) or (TokenPtr(Nodes[NodeIndex - 1])^.KeywordIndex <> kiNOT))
                and IsOperator(Nodes[NodeIndex - 1])) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if (NodeIndex + 1 = Nodes.Count) then
              begin
                AddOperandsToCompletionList();
                SetError(PE_IncompleteStmt);
              end
              else if (IsOperator(Nodes[NodeIndex + 1])) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex + 1])
              else if (IsToken(Nodes[NodeIndex - 1]) and (TokenPtr(Nodes[NodeIndex - 1])^.OperatorType = otNot)) then
              begin // ... NOT REGEXP ...
                Nodes[NodeIndex - 2] := TRegExpOp.Create(Self, Nodes[NodeIndex - 2], Nodes[NodeIndex - 1], Nodes[NodeIndex], Nodes[NodeIndex + 1]);
                Nodes.Delete(NodeIndex - 1, 3);
                Dec(NodeIndex, 2);
              end
              else
              begin // ... REGEXP ...
                Nodes[NodeIndex - 1] := TRegExpOp.Create(Self, Nodes[NodeIndex - 1], 0, Nodes[NodeIndex], Nodes[NodeIndex + 1]);
                Nodes.Delete(NodeIndex, 2);
                Dec(NodeIndex);
              end;
            otSounds:
              if (NodeIndex = 0) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if (IsToken(Nodes[NodeIndex - 1]) and (TokenPtr(Nodes[NodeIndex - 1])^.OperatorType = otNot)
                and ((NodeIndex < 2) or IsOperator(Nodes[NodeIndex - 2]))) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if ((not IsToken(Nodes[NodeIndex - 1]) or (TokenPtr(Nodes[NodeIndex - 1])^.KeywordIndex <> kiNOT))
                and IsOperator(Nodes[NodeIndex - 1])) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex])
              else if (NodeIndex + 1 = Nodes.Count) then
              begin
                AddOperandsToCompletionList();
                SetError(PE_IncompleteStmt);
              end
              else if (IsOperator(Nodes[NodeIndex + 1])) then
                SetError(PE_UnexpectedToken, Nodes[NodeIndex + 1])
              else
              begin // ... SOUNDS LIKE ...
                Nodes[NodeIndex - 1] := TSoundsLikeOp.Create(Self, Nodes[NodeIndex - 1], Nodes[NodeIndex], Nodes[NodeIndex + 1], Nodes[NodeIndex + 1]);
                Nodes.Delete(NodeIndex - 1, 3);
                Dec(NodeIndex, 2);
              end;
            else
              SetError(PE_Unknown);
          end;
    end;

  if (not ErrorFound and EndOfStmt(CurrentToken)) then
    if ((Nodes.Count = 0) or IsOperator(Nodes[Nodes.Count - 1])) then
    begin // Add operands
      AddOperandsToCompletionList();
      SetError(PE_IncompleteStmt);
    end
    else
    begin // Add operators
      for KeywordIndex := 0 to KeywordList.Count - 1 do
        if (OperatorTypeByKeywordIndex[KeywordIndex] <> otNone) then
          CompletionList.AddTag(KeywordIndex);
    end;

  if (not ErrorFound and (Nodes.Count <> 1)) then
    SetError(PE_Unknown);

  if (Nodes.Count = 0) then
    Result := 0
  else
    Result := Nodes[0];
end;

function TSQLParser.ParseExtractFunc(): TOffset;
var
  Nodes: TExtractFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    Nodes.UnitTag := ParseIntervalUnitTag();

  if (not ErrorFound) then
    Nodes.FromTag := ParseTag(kiFROM);

  if (not ErrorFound) then
    Nodes.QuantityExpr := ParseExpr();

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TExtractFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseFetchStmt(): TOffset;
var
  Nodes: TFetchStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiFETCH);

  if (not ErrorFound) then
    if (IsTag(kiNEXT)) then
    begin
      Nodes.NextTag := ParseTag(kiNEXT);

      if (not ErrorFound) then
        Nodes.FromTag := ParseTag(kiFROM);
    end
    else if (IsTag(kiFROM)) then
      Nodes.FromTag := ParseTag(kiFROM);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent(ditCursor, False);

  if (not ErrorFound) then
    Nodes.IntoTag := ParseTag(kiINTO);

  if (not ErrorFound) then
    Nodes.VariableList := ParseList(False, ParseVariableIdent);

  Result := TFetchStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseFieldIdent(): TOffset;
begin
  Result := ParseDbIdent(ditField, False);
end;

function TSQLParser.ParseFieldIdentFullQualified(): TOffset;
begin
  Result := ParseDbIdent(ditField, True);
end;

function TSQLParser.ParseFieldOrVariableIdent(): TOffset;
begin
  if (not IsSymbol(ttAT)) then
    Result := ParseFieldIdent()
  else
    Result := ParseVariableIdent();
end;

function TSQLParser.ParseFlushStmt(): TOffset;
var
  Nodes: TFlushStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiFLUSH);

  if (not ErrorFound and not EndOfStmt(CurrentToken)) then
    if (IsTag(kiNO_WRITE_TO_BINLOG)) then
      Nodes.NoWriteToBinLogTag := ParseTag(kiNO_WRITE_TO_BINLOG)
    else if (IsTag(kiLOCAL)) then
      Nodes.NoWriteToBinLogTag := ParseTag(kiLOCAL);

  if (not ErrorFound) then
    Nodes.OptionList := ParseList(False, ParseFlushStmtOption);

  Result := TFlushStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseFlushStmtOption(): TOffset;
var
  Nodes: TFlushStmt.TOption.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiHOSTS)) then
    Nodes.OptionTag := ParseTag(kiHOSTS)
  else if (IsTag(kiLOGS)
    or IsTag(kiBINARY, kiLOGS)
    or IsTag(kiENGINE, kiLOGS)
    or IsTag(kiERROR, kiLOGS)
    or IsTag(kiGENERAL, kiLOGS)
    or IsTag(kiRELAY, kiLOGS)
    or IsTag(kiSLOW, kiLOGS)) then
    Nodes.OptionTag := ParseFlushStmtOptionLogs()
  else if (IsTag(kiPRIVILEGES)) then
    Nodes.OptionTag := ParseTag(kiPRIVILEGES)
  else if (IsTag(kiSTATUS)) then
    Nodes.OptionTag := ParseTag(kiSTATUS)
  else if (IsTag(kiTABLE)) then
  begin
    Nodes.OptionTag := ParseTag(kiTABLE);

    if (not ErrorFound and not EndOfStmt(CurrentToken)) then
      Nodes.TablesList := ParseList(False, ParseTableIdent);
  end
  else if (IsTag(kiTABLES)) then
  begin
    Nodes.OptionTag := ParseTag(kiTABLES);

    if (not ErrorFound and not EndOfStmt(CurrentToken)) then
      Nodes.TablesList := ParseList(False, ParseTableIdent);
  end
  else if (EndOfStmt(CurrentToken)) then
    SetError(PE_IncompleteStmt)
  else
    SetError(PE_UnexpectedToken);

  Result := TFlushStmt.TOption.Create(Self, Nodes);
end;

function TSQLParser.ParseFlushStmtOptionLogs(): TOffset;
var
  Nodes: TFlushStmt.TOption.TLogs.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiBINARY)) then
    Nodes.LogTypeTag := ParseTag(kiBINARY)
  else if (IsTag(kiENGINE)) then
    Nodes.LogTypeTag := ParseTag(kiENGINE)
  else if (IsTag(kiERROR)) then
    Nodes.LogTypeTag := ParseTag(kiERROR)
  else if (IsTag(kiGENERAL)) then
    Nodes.LogTypeTag := ParseTag(kiGENERAL)
  else if (IsTag(kiRELAY)) then
    Nodes.LogTypeTag := ParseTag(kiRELAY)
  else if (IsTag(kiSLOW)) then
    Nodes.LogTypeTag := ParseTag(kiSLOW);

  if (not ErrorFound) then
    Nodes.LogTag := ParseTag(kiLOGS);

  if (not ErrorFound) then
    if (IsTag(kiFOR, kiCHANNEL)) then
      Nodes.ChannelOptionValue := ParseValue(WordIndices(kiFOR, kiCHANNEL), vaNo, ParseDbIdent);

  Result := TFlushStmt.TOption.TLogs.Create(Self, Nodes);
end;

function TSQLParser.ParseForeignKeyIdent(): TOffset;
begin
  Result := ParseDbIdent(ditForeignKey);
end;

function TSQLParser.ParseFunctionIdent(): TOffset;
begin
  Result := ParseDbIdent(ditFunction);
end;

function TSQLParser.ParseFunctionParam(): TOffset;
var
  Nodes: TRoutineParam.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ParseRoutineParamIdent();

  if (not ErrorFound) then
    Nodes.DatatypeNode := ParseDatatype();

  Result := TRoutineParam.Create(Self, Nodes);
end;

function TSQLParser.ParseFunctionReturns(): TOffset;
var
  Nodes: TFunctionReturns.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.ReturnsTag := ParseTag(kiRETURNS);

  if (not ErrorFound) then
    Nodes.DatatypeNode := ParseDatatype();

  Result := TFunctionReturns.Create(Self, Nodes);
end;

function TSQLParser.ParseGetDiagnosticsStmt(): TOffset;
var
  Nodes: TGetDiagnosticsStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiGET);

  if (not ErrorFound) then
    if (IsTag(kiCURRENT)) then
      Nodes.ScopeTag := ParseTag(kiCURRENT)
    else if (IsTag(kiSTACKED)) then
      Nodes.ScopeTag := ParseTag(kiSTACKED);

  if (not ErrorFound) then
    Nodes.DiagnosticsTag := ParseTag(kiDIAGNOSTICS);

  if (not ErrorFound) then
    if (not IsTag(kiCONDITION)) then
      Nodes.InfoList := ParseList(False, ParseGetDiagnosticsStmtStmtInfo)
    else
    begin
      Nodes.ConditionTag := ParseTag(kiCONDITION);

      if (not ErrorFound) then
        Nodes.ConditionNumber := ParseExpr();

      if (not ErrorFound) then
        Nodes.InfoList := ParseList(False, ParseGetDiagnosticsStmtConditionInfo)
    end;

  Result := TGetDiagnosticsStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseGetDiagnosticsStmtStmtInfo(): TOffset;
var
  Nodes: TGetDiagnosticsStmt.TStmtInfo.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Target := ParseVariableIdent();

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (TokenPtr(CurrentToken)^.OperatorType <> otEqual) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.EqualOp := ApplyCurrentToken(utOperator);

  if (not ErrorFound) then
    if (IsTag(kiNUMBER)) then
      Nodes.ItemTag := ParseTag(kiNUMBER)
    else
      Nodes.ItemTag := ParseTag(kiROW_COUNT);

  Result := TGetDiagnosticsStmt.TStmtInfo.Create(Self, Nodes);
end;

function TSQLParser.ParseGetDiagnosticsStmtConditionInfo(): TOffset;
var
  Nodes: TGetDiagnosticsStmt.TCondInfo.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Target := ParseVariableIdent();

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (TokenPtr(CurrentToken)^.OperatorType <> otEqual) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.EqualOp := ApplyCurrentToken(utOperator);

  if (not ErrorFound) then
    if (IsTag(kiCLASS_ORIGIN)) then
      Nodes.ItemTag := ParseTag(kiCLASS_ORIGIN)
    else if (IsTag(kiSUBCLASS_ORIGIN)) then
      Nodes.ItemTag := ParseTag(kiSUBCLASS_ORIGIN)
    else if (IsTag(kiRETURNED_SQLSTATE)) then
      Nodes.ItemTag := ParseTag(kiRETURNED_SQLSTATE)
    else if (IsTag(kiMESSAGE_TEXT)) then
      Nodes.ItemTag := ParseTag(kiMESSAGE_TEXT)
    else if (IsTag(kiMYSQL_ERRNO)) then
      Nodes.ItemTag := ParseTag(kiMYSQL_ERRNO)
    else if (IsTag(kiCONSTRAINT_CATALOG)) then
      Nodes.ItemTag := ParseTag(kiCONSTRAINT_CATALOG)
    else if (IsTag(kiCONSTRAINT_SCHEMA)) then
      Nodes.ItemTag := ParseTag(kiCONSTRAINT_SCHEMA)
    else if (IsTag(kiCONSTRAINT_NAME)) then
      Nodes.ItemTag := ParseTag(kiCONSTRAINT_NAME)
    else if (IsTag(kiCATALOG_NAME)) then
      Nodes.ItemTag := ParseTag(kiCATALOG_NAME)
    else if (IsTag(kiSCHEMA_NAME)) then
      Nodes.ItemTag := ParseTag(kiSCHEMA_NAME)
    else if (IsTag(kiCATALOG_NAME)) then
      Nodes.ItemTag := ParseTag(kiCATALOG_NAME)
    else if (IsTag(kiTABLE_NAME)) then
      Nodes.ItemTag := ParseTag(kiTABLE_NAME)
    else if (IsTag(kiCOLUMN_NAME)) then
      Nodes.ItemTag := ParseTag(kiCOLUMN_NAME)
    else
      Nodes.ItemTag := ParseTag(kiCURSOR_NAME);

  Result := TGetDiagnosticsStmt.TCondInfo.Create(Self, Nodes);
end;

function TSQLParser.ParseGrantStmt(): TOffset;
var
  Found: Boolean;
  Nodes: TGrantStmt.TNodes;
  OldCurrentToken: TOffset;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiGRANT);

  if (not ErrorFound) then
    if (not IsTag(kiPROXY)) then
    begin
      Nodes.PrivilegesList := ParseList(False, ParseGrantStmtPrivileg);

      if (not ErrorFound) then
        Nodes.OnTag := ParseTag(kiON);

      if (not ErrorFound) then
        if (IsTag(kiTABLE)) then
        begin
          Nodes.ObjectTypeTag := ParseTag(kiTABLE);
          Nodes.ObjectIdent := ParseDbIdent(ditTable, True, True);
        end
        else if (IsTag(kiFUNCTION)) then
        begin
          Nodes.ObjectTypeTag := ParseTag(kiFUNCTION);
          Nodes.ObjectIdent := ParseDbIdent(ditFunction, True, True);
        end
        else if (IsTag(kiPROCEDURE)) then
        begin
          Nodes.ObjectTypeTag := ParseTag(kiPROCEDURE);
          Nodes.ObjectIdent := ParseDbIdent(ditProcedure, True, True);
        end
        else
          Nodes.ObjectIdent := ParseDbIdent(ditTable, True, True);

      if (not ErrorFound) then
        Nodes.ToTag := ParseTag(kiTO);

      if (not ErrorFound) then
        Nodes.UserSpecifications := ParseList(False, ParseGrantStmtUserSpecification);

      if (not ErrorFound) then
        if (IsTag(kiREQUIRE)) then
        begin
          Nodes.Require.Tag := ParseTag(kiREQUIRE);

          if (not ErrorFound) then
            Nodes.Require.Options := ParseTag(kiNONE);
        end;

      if (not ErrorFound) then
        if (IsTag(kiWITH)) then
        begin
          Nodes.WithTag := ParseTag(kiWITH);

          Found := True; OldCurrentToken := CurrentToken;
          while (not ErrorFound and Found) do
            if ((Nodes.GrantOptionTag = 0) and IsTag(kiGRANT, kiOPTION)) then
              Nodes.GrantOptionTag := ParseTag(kiGRANT, kiOPTION)
            else if ((Nodes.MaxQueriesPerHourTag = 0) and IsTag(kiMAX_QUERIES_PER_HOUR)) then
              Nodes.MaxQueriesPerHourTag := ParseValue(kiMAX_QUERIES_PER_HOUR, vaNo, ParseInteger)
            else if ((Nodes.MaxUpdatesPerHourTag = 0) and IsTag(kiMAX_UPDATES_PER_HOUR)) then
              Nodes.MaxUpdatesPerHourTag := ParseValue(kiMAX_UPDATES_PER_HOUR, vaNo, ParseInteger)
            else if ((Nodes.MaxConnectionsPerHourTag = 0) and IsTag(kiMAX_CONNECTIONS_PER_HOUR)) then
              Nodes.MaxConnectionsPerHourTag := ParseValue(kiMAX_CONNECTIONS_PER_HOUR, vaNo, ParseInteger)
            else if ((Nodes.MaxUserConnectionsTag = 0) and IsTag(kiMAX_USER_CONNECTIONS)) then
              Nodes.MaxUserConnectionsTag := ParseValue(kiMAX_USER_CONNECTIONS, vaNo, ParseInteger)
            else if ((Nodes.MaxStatementTimeTag = 0) and IsTag(kiMAX_STATEMENT_TIME)) then
              Nodes.MaxStatementTimeTag := ParseValue(kiMAX_STATEMENT_TIME, vaNo, ParseInteger)
            else
              Found := False;

          if (CurrentToken = OldCurrentToken) then
            if (EndOfStmt(CurrentToken)) then
              SetError(PE_IncompleteStmt)
            else
              SetError(PE_UnexpectedToken);
        end;
    end
    else
    begin
      Nodes.PrivilegesList := ParseTag(kiPROXY);

      if (not ErrorFound) then
        Nodes.OnTag := ParseTag(kiON);

      if (not ErrorFound) then
        Nodes.OnUser := ParseAccountIdent();

      if (not ErrorFound) then
        Nodes.ToTag := ParseTag(kiTO);

      if (not ErrorFound) then
        Nodes.UserSpecifications := ParseList(False, ParseGrantStmtUserSpecification);

      if (not ErrorFound) then
        if (IsTag(kiWITH, kiGRANT, kiOPTION)) then
          Nodes.WithTag := ParseTag(kiWITH, kiGRANT, kiOPTION);
    end;

  Result := TGrantStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseGrantStmtPrivileg(): TOffset;
var
  Nodes: TGrantStmt.TPrivileg.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiALL, kiPRIVILEGES)) then
    Nodes.PrivilegTag := ParseTag(kiALL, kiPRIVILEGES)
  else if (IsTag(kiALL)) then
    Nodes.PrivilegTag := ParseTag(kiALL)
  else if (IsTag(kiALTER, kiROUTINE)) then
    Nodes.PrivilegTag := ParseTag(kiALTER, kiROUTINE)
  else if (IsTag(kiALTER)) then
    Nodes.PrivilegTag := ParseTag(kiALTER)
  else if (IsTag(kiCREATE, kiROUTINE)) then
    Nodes.PrivilegTag := ParseTag(kiCREATE, kiROUTINE)
  else if (IsTag(kiCREATE, kiTABLESPACE)) then
    Nodes.PrivilegTag := ParseTag(kiCREATE, kiTABLESPACE)
  else if (IsTag(kiCREATE, kiTEMPORARY, kiTABLES)) then
    Nodes.PrivilegTag := ParseTag(kiCREATE, kiTEMPORARY, kiTABLES)
  else if (IsTag(kiCREATE, kiUSER)) then
    Nodes.PrivilegTag := ParseTag(kiCREATE, kiUSER)
  else if (IsTag(kiCREATE, kiVIEW)) then
    Nodes.PrivilegTag := ParseTag(kiCREATE, kiVIEW)
  else if (IsTag(kiCREATE)) then
    Nodes.PrivilegTag := ParseTag(kiCREATE)
  else if (IsTag(kiDELETE)) then
    Nodes.PrivilegTag := ParseTag(kiDELETE)
  else if (IsTag(kiDROP)) then
    Nodes.PrivilegTag := ParseTag(kiDROP)
  else if (IsTag(kiEVENT)) then
    Nodes.PrivilegTag := ParseTag(kiEVENT)
  else if (IsTag(kiEXECUTE)) then
    Nodes.PrivilegTag := ParseTag(kiEXECUTE)
  else if (IsTag(kiFILE)) then
    Nodes.PrivilegTag := ParseTag(kiFILE)
  else if (IsTag(kiGRANT, kiOPTION)) then
    Nodes.PrivilegTag := ParseTag(kiGRANT, kiOPTION)
  else if (IsTag(kiINDEX)) then
    Nodes.PrivilegTag := ParseTag(kiINDEX)
  else if (IsTag(kiINSERT)) then
    Nodes.PrivilegTag := ParseTag(kiINSERT)
  else if (IsTag(kiLOCK, kiTABLES)) then
    Nodes.PrivilegTag := ParseTag(kiLOCK, kiTABLES)
  else if (IsTag(kiPROCESS)) then
    Nodes.PrivilegTag := ParseTag(kiPROCESS)
  else if (IsTag(kiPROXY)) then
    Nodes.PrivilegTag := ParseTag(kiPROXY)
  else if (IsTag(kiREFERENCES)) then
    Nodes.PrivilegTag := ParseTag(kiREFERENCES)
  else if (IsTag(kiRELOAD)) then
    Nodes.PrivilegTag := ParseTag(kiRELOAD)
  else if (IsTag(kiREPLICATION, kiCLIENT)) then
    Nodes.PrivilegTag := ParseTag(kiREPLICATION, kiCLIENT)
  else if (IsTag(kiREPLICATION, kiSLAVE)) then
    Nodes.PrivilegTag := ParseTag(kiREPLICATION, kiSLAVE)
  else if (IsTag(kiSELECT)) then
    Nodes.PrivilegTag := ParseTag(kiSELECT)
  else if (IsTag(kiSHOW, kiDATABASES)) then
    Nodes.PrivilegTag := ParseTag(kiSHOW, kiDATABASES)
  else if (IsTag(kiSHOW, kiVIEW)) then
    Nodes.PrivilegTag := ParseTag(kiSHOW, kiVIEW)
  else if (IsTag(kiSHUTDOWN)) then
    Nodes.PrivilegTag := ParseTag(kiSHUTDOWN)
  else if (IsTag(kiSUPER)) then
    Nodes.PrivilegTag := ParseTag(kiSUPER)
  else if (IsTag(kiTRIGGER)) then
    Nodes.PrivilegTag := ParseTag(kiTRIGGER)
  else if (IsTag(kiUPDATE)) then
    Nodes.PrivilegTag := ParseTag(kiUPDATE)
  else if (IsTag(kiUSAGE)) then
    Nodes.PrivilegTag := ParseTag(kiUSAGE)
  else if (EndOfStmt(CurrentToken)) then
    SetError(PE_IncompleteStmt)
  else
    SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
    if (IsSymbol(ttOpenBracket)) then
      Nodes.ColumnList := ParseList(True, ParseFieldIdent);

  Result := TGrantStmt.TPrivileg.Create(Self, Nodes);
end;

function TSQLParser.ParseGrantStmtUserSpecification(): TOffset;
var
  Nodes: TGrantStmt.TUserSpecification.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.UserIdent := ParseAccountIdent();

  if (not ErrorFound) then
    if (IsTag(kiIDENTIFIED, kiBY, kiPASSWORD)) then
    begin
      Nodes.IdentifiedToken := ParseTag(kiIDENTIFIED, kiBY, kiPASSWORD);

      if (not ErrorFound and not EndOfStmt(CurrentToken)) then
        if (TokenPtr(CurrentToken)^.TokenType in ttStrings - [ttIdent]) then
          Nodes.AuthString := ParseString()
        else if (not EndOfStmt(NextToken[2])
          and (TokenPtr(CurrentToken)^.OperatorType = otLess)
          and (TokenPtr(NextToken[1])^.TokenType = ttIdent)
          and (TokenPtr(NextToken[2])^.OperatorType = otGreater)) then
          Nodes.AuthString := ParseSecretIdent();
    end
    else if (IsTag(kiIDENTIFIED, kiBY)) then
    begin
      Nodes.IdentifiedToken := ParseTag(kiIDENTIFIED, kiBY);

      if (not ErrorFound) then
        Nodes.AuthString := ParseString();
    end
    else if (IsTag(kiIDENTIFIED, kiWITH)) then
    begin
      Nodes.IdentifiedToken := ParseTag(kiIDENTIFIED, kiWITH);

      if (not ErrorFound) then
        if (EndOfStmt(CurrentToken)) then
          SetError(PE_IncompleteStmt)
        else if ((TokenPtr(CurrentToken)^.TokenType = ttIdent) or (TokenPtr(CurrentToken)^.TokenType = ttDQIdent) and AnsiQuotes) then
          Nodes.PluginIdent := ParseDbIdent()
        else if ((TokenPtr(CurrentToken)^.TokenType = ttString) or (TokenPtr(CurrentToken)^.TokenType = ttDQIdent) and not AnsiQuotes) then
          Nodes.PluginIdent := ParseString()
        else
          SetError(PE_UnexpectedToken);

      if (not ErrorFound) then
        if (IsTag(kiAS)) then
        begin
          Nodes.AsTag := ParseTag(kiAS);

          if (not ErrorFound) then
            Nodes.AuthString := ParseString();
        end
        else if (IsTag(kiBY)) then
        begin
          Nodes.AsTag := ParseTag(kiBY);

          if (not ErrorFound) then
            Nodes.AuthString := ParseString();
        end;
  end;

  Result := TGrantStmt.TUserSpecification.Create(Self, Nodes);
end;

function TSQLParser.ParseGroupConcatFunc(): TOffset;
var
  Nodes: TGroupConcatFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    if (IsTag(kiDISTINCT)) then
      Nodes.DistinctTag := ParseTag(kiDISTINCT);

  if (not ErrorFound) then
    Nodes.ExprList := ParseList(False, ParseExpr);

  if (not ErrorFound) then
    if (IsTag(kiORDER, kiBY)) then
    begin
      Nodes.OrderBy.Tag := ParseTag(kiORDER, kiBY);

      if (not ErrorFound) then
        Nodes.OrderBy.Expr := ParseList(False, ParseGroupConcatFuncExpr);
    end;

  if (not ErrorFound) then
    if (IsTag(kiSEPARATOR)) then
      Nodes.SeparatorValue := ParseValue(kiSEPARATOR, vaNo, ParseString);

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TGroupConcatFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseGroupConcatFuncExpr(): TOffset;
var
  Nodes: TGroupConcatFunc.TExpr.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Expr := ParseExpr();

  if (not ErrorFound) then
    if (IsTag(kiASC)) then
      Nodes.Direction := ParseTag(kiASC)
    else if (IsTag(kiDESC)) then
      Nodes.Direction := ParseTag(kiDESC);

  Result := TGroupConcatFunc.TExpr.Create(Self, Nodes);
end;

function TSQLParser.ParseHelpStmt(): TOffset;
var
  Nodes: THelpStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiHELP);

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if ((TokenPtr(CurrentToken)^.TokenType = ttString) or (TokenPtr(CurrentToken)^.TokenType = ttDQIdent) and not AnsiQuotes) then
      Nodes.HelpString := ApplyCurrentToken(utString)
    else if ((TokenPtr(CurrentToken)^.TokenType = ttIdent) and (ReservedWordList.IndexOf(TokenPtr(CurrentToken)^.FText, TokenPtr(CurrentToken)^.FLength) < 0)) then
      Nodes.HelpString := ApplyCurrentToken(utDbIdent)
    else
      SetError(PE_UnexpectedToken);

  Result := THelpStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseIfStmt(): TOffset;

  function ParseBranch(): TOffset;
  var
    Nodes: TIfStmt.TBranch.TNodes;
  begin
    FillChar(Nodes, SizeOf(Nodes), 0);

    if (IsTag(kiIF)) then
    begin
      Nodes.BranchTag := ParseTag(kiIF);

      if (not ErrorFound) then
        Nodes.ConditionExpr := ParseExpr();

      if (not ErrorFound) then
        Nodes.ThenTag := ParseTag(kiTHEN);
    end
    else if (IsTag(kiELSEIF)) then
    begin
      Nodes.BranchTag := ParseTag(kiELSEIF);

      if (not ErrorFound) then
        Nodes.ConditionExpr := ParseExpr();

      if (not ErrorFound) then
        Nodes.ThenTag := ParseTag(kiTHEN);
    end
    else if (IsTag(kiELSE)) then
      Nodes.BranchTag := ParseTag(kiELSE)
    else
      SetError(PE_Unknown);

    if (not ErrorFound) then
      if (not IsTag(kiELSEIF)
        and not IsTag(kiELSE)
        and not IsTag(kiEND, kiIF)) then
        Nodes.StmtList := ParseList(False, ParsePL_SQLStmt, ttSemicolon)
      else if (EndOfStmt(CurrentToken)) then
        SetError(PE_IncompleteStmt)
      else
        SetError(PE_UnexpectedToken);

    Result := TIfStmt.TBranch.Create(Self, Nodes);
  end;

var
  Found: Boolean;
  Branches: TOffsetList;
  ListNodes: TList.TNodes;
  Nodes: TIfStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Branches.Init();
  Branches.Add(ParseBranch());

  Found := True;
  while (not ErrorFound and Found) do
    if (IsTag(kiELSEIF)) then
      Branches.Add(ParseBranch())
    else
      Found := False;

  if (not ErrorFound) then
    if (IsTag(kiELSE)) then
      Branches.Add(ParseBranch());

  if (not ErrorFound) then
    Nodes.EndTag := ParseTag(kiEND, kiIF);

  FillChar(ListNodes, SizeOf(ListNodes), 0);
  Nodes.BranchList := TList.Create(Self, ListNodes, ttUnknown, @Branches);

  Result := TIfStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseInsertStmt(const Replace: Boolean = False): TOffset;
var
  Nodes: TInsertStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiINSERT)) then
    Nodes.InsertTag := ParseTag(kiINSERT)
  else
    Nodes.InsertTag := ParseTag(kiREPLACE);

  if (not ErrorFound) then
    if (IsTag(kiLOW_PRIORITY)) then
      Nodes.PriorityTag := ParseTag(kiLOW_PRIORITY)
    else if (IsTag(kiDELAYED)) then
      Nodes.PriorityTag := ParseTag(kiDELAYED)
    else if (IsTag(kiHIGH_PRIORITY)) then
      Nodes.PriorityTag := ParseTag(kiHIGH_PRIORITY);

  if (not ErrorFound) then
    if (IsTag(kiIGNORE)) then
      Nodes.IgnoreTag := ParseTag(kiIGNORE);

  if (not ErrorFound) then
    if (IsTag(kiINTO)) then
      Nodes.IntoTag := ParseTag(kiINTO);

  if (not ErrorFound) then
    Nodes.TableIdent := ParseTableIdent();

  if (not ErrorFound) then
    if (IsTag(kiPARTITION)) then
    begin
      Nodes.Partition.Tag := ParseTag(kiPARTITION);

      if (not ErrorFound) then
        Nodes.Partition.List := ParseList(True, ParsePartitionIdent);
    end;

  if (not ErrorFound) then
    if (IsTag(kiSET)) then
    begin
      Nodes.Set_.Tag := ParseTag(kiSET);

      if (not ErrorFound) then
        Nodes.Set_.List := ParseList(False, ParseInsertStmtSetItemsList);
    end
    else if (IsTag(kiSELECT)) then
      Nodes.SelectStmt := ParseSelectStmt(True)
    else if (IsSymbol(ttOpenBracket) and IsNextTag(1, kiSELECT)) then
      Nodes.SelectStmt := ParseSelectStmt(True)
    else if (not EndOfStmt(CurrentToken)) then
    begin
      if (IsSymbol(ttOpenBracket)) then
        Nodes.ColumnList := ParseList(True, ParseFieldIdentFullQualified);

      if (not ErrorFound) then
        if (IsTag(kiVALUE)) then
        begin
          Nodes.Values.Tag := ParseTag(kiVALUE);

          if (not ErrorFound) then
            Nodes.Values.List := ParseList(False, ParseInsertStmtValuesList);
        end
        else if (IsTag(kiVALUES)) then
        begin
          Nodes.Values.Tag := ParseTag(kiVALUES);

          if (not ErrorFound) then
            Nodes.Values.List := ParseList(False, ParseInsertStmtValuesList);
        end
        else if ((Nodes.SelectStmt = 0) and IsTag(kiSELECT)) then
          Nodes.SelectStmt := ParseSelectStmt(True)
        else if ((Nodes.SelectStmt = 0) and IsSymbol(ttOpenBracket) and IsNextTag(1, kiSELECT)) then
          Nodes.SelectStmt := ParseSelectStmt(True)
        else if (EndOfStmt(CurrentToken)) then
          SetError(PE_IncompleteStmt)
        else
          SetError(PE_UnexpectedToken);
    end
    else
      SetError(PE_IncompleteStmt);

  if (not ErrorFound) then
    if (IsTag(kiON, kiDUPLICATE, kiKEY, kiUPDATE)) then
    begin
      Nodes.OnDuplicateKeyUpdateTag := ParseTag(kiON, kiDUPLICATE, kiKEY, kiUPDATE);

      if (not ErrorFound) then
        Nodes.UpdateList := ParseList(False, ParseUpdateStmtValue);
    end;

  Result := TInsertStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseInsertStmtSetItemsList(): TOffset;
var
  Nodes: TInsertStmt.TSetItem.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.FieldToken := ParseDbIdent(ditField);

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (TokenPtr(CurrentToken)^.OperatorType <> otEqual) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.AssignToken := ApplyCurrentToken(utSymbol);

  if (not ErrorFound) then
    Nodes.ValueNode := ParseExpr();

  Result := TInsertStmt.TSetItem.Create(Self, Nodes);
end;

function TSQLParser.ParseInsertStmtValuesList(): TOffset;
begin
  Result := ParseList(True, ParseExpr);
end;

function TSQLParser.ParseInstallPluginStmt(): TOffset;
var
  Nodes: TInstallPluginStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiINSTALL, kiPLUGIN);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent(ditPlugin, False);

  if (not ErrorFound) then
    Nodes.SonameTag := ParseTag(kiSONAME);

  if (not ErrorFound) then
    Nodes.NameString := ParseString();

  Result := TInstallPluginStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseInteger(): TOffset;
begin
  Result := 0;
  if (EndOfStmt(CurrentToken)) then
    SetError(PE_IncompleteStmt)
  else if (TokenPtr(CurrentToken)^.TokenType <> ttInteger) then
    SetError(PE_UnexpectedToken)
  else
    Result := ApplyCurrentToken(utInteger);
end;

function TSQLParser.ParseInterval(): TOffset;
var
  BracketDeep: Integer;
  Index: Integer;
  Nodes: TIntervalOp.TNodes;
begin
  BracketDeep := 0;

  if (IsNextSymbol(1, ttOpenBracket)) then
  begin
    Index := 1;
    repeat
      if (IsNextSymbol(Index, ttOpenBracket)) then
        Inc(BracketDeep)
      else if (IsNextSymbol(Index, ttCloseBracket)) then
        Dec(BracketDeep);
      Inc(Index);
    until (EndOfStmt(NextToken[Index])
      or (BracketDeep = 0)
      or (BracketDeep = 1) and IsNextSymbol(Index, ttComma));
  end;

  if (BracketDeep = 0) then
  begin
    FillChar(Nodes, SizeOf(Nodes), 0);

    Nodes.IntervalTag := ParseTag(kiINTERVAL);

    if (not ErrorFound) then
      Nodes.QuantityExpr := ParseExpr();

    if (not ErrorFound) then
      Nodes.UnitTag := ParseIntervalUnitTag();

    Result := TIntervalOp.Create(Self, Nodes);
  end
  else
  begin
    TokenPtr(CurrentToken)^.FOperatorType := otNone;
    Result := ParseDefaultFunc();
  end;
end;

function TSQLParser.ParseIntervalUnitTag(): TOffset;
begin
  if (IsTag(kiMICROSECOND)) then
    Result := ParseTag(kiMICROSECOND)
  else if (IsTag(kiSECOND)) then
    Result := ParseTag(kiSECOND)
  else if (IsTag(kiMINUTE)) then
    Result := ParseTag(kiMINUTE)
  else if (IsTag(kiHOUR)) then
    Result := ParseTag(kiHOUR)
  else if (IsTag(kiDAY)) then
    Result := ParseTag(kiDAY)
  else if (IsTag(kiWEEK)) then
    Result := ParseTag(kiWEEK)
  else if (IsTag(kiMONTH)) then
    Result := ParseTag(kiMONTH)
  else if (IsTag(kiQUARTER)) then
    Result := ParseTag(kiQUARTER)
  else if (IsTag(kiYEAR)) then
    Result := ParseTag(kiYEAR)
  else if (IsTag(kiSECOND_MICROSECOND)) then
    Result := ParseTag(kiSECOND_MICROSECOND)
  else if (IsTag(kiMINUTE_MICROSECOND)) then
    Result := ParseTag(kiMINUTE_MICROSECOND)
  else if (IsTag(kiMINUTE_SECOND)) then
    Result := ParseTag(kiMINUTE_SECOND)
  else if (IsTag(kiHOUR_MICROSECOND)) then
    Result := ParseTag(kiHOUR_MICROSECOND)
  else if (IsTag(kiHOUR_SECOND)) then
    Result := ParseTag(kiHOUR_SECOND)
  else if (IsTag(kiHOUR_MINUTE)) then
    Result := ParseTag(kiHOUR_MINUTE)
  else if (IsTag(kiDAY_MICROSECOND)) then
    Result := ParseTag(kiDAY_MICROSECOND)
  else if (IsTag(kiDAY_SECOND)) then
    Result := ParseTag(kiDAY_SECOND)
  else if (IsTag(kiDAY_MINUTE)) then
    Result := ParseTag(kiDAY_MINUTE)
  else if (IsTag(kiDAY_MINUTE)) then
    Result := ParseTag(kiDAY_MINUTE)
  else if (IsTag(kiDAY_HOUR)) then
    Result := ParseTag(kiDAY_HOUR)
  else if (IsTag(kiYEAR_MONTH)) then
    Result := ParseTag(kiYEAR_MONTH)
  else if (EndOfStmt(CurrentToken)) then
    Result := SetError(PE_IncompleteStmt)
  else
    Result := SetError(PE_UnexpectedToken);
end;

function TSQLParser.ParseIterateStmt(): TOffset;
var
  Nodes: TIterateStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IterateToken := ParseTag(kiITERATE);

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (TokenPtr(CurrentToken)^.TokenType <> ttIdent) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.LabelToken := ApplyCurrentToken(utLabel);

  Result := TIterateStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseKeyIdent(): TOffset;
begin
  Result := ParseDbIdent(ditKey);
end;

function TSQLParser.ParseKillStmt(): TOffset;
var
  Nodes: TKillStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiKILL, kiCONNECTION)) then
    Nodes.StmtTag := ParseTag(kiKILL, kiCONNECTION)
  else if (IsTag(kiKILL, kiQUERY)) then
    Nodes.StmtTag := ParseTag(kiKILL, kiQUERY)
  else
    Nodes.StmtTag := ParseTag(kiKILL);

  if (not ErrorFound) then
    Nodes.ProcessIdToken := ParseInteger();

  Result := TKillStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseLeaveStmt(): TOffset;
var
  Nodes: TLeaveStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiLEAVE);

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (TokenPtr(CurrentToken)^.TokenType <> ttIdent) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.LabelToken := ApplyCurrentToken(utLabel);

  Result := TLeaveStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseList(const Brackets: Boolean; const ParseElement: TParseFunction;
  const DelimiterType: TTokenType = ttComma; const CanEmpty: Boolean = True;
  const RootStmtList: Boolean = False): TOffset;
var
  Children: TOffsetList;
  DelimiterFound: Boolean;
  Nodes: TList.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (Brackets) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  Children.Init();
  DelimiterFound := False;
  if (not ErrorFound and (not Brackets or not IsSymbol(ttCloseBracket))) then
    repeat
      if (RootStmtList) then
        FillChar(Error, SizeOf(Error), 0);

      Children.Add(ParseElement());

      if (Children[Children.Count - 1] = 0) then
        DelimiterFound := False
      else
      begin
        DelimiterFound := IsSymbol(DelimiterType);
        if (DelimiterFound) then
          Children.Add(ParseSymbol(DelimiterType));
      end;
    until ((CurrentToken = 0)
      or ErrorFound and not RootStmtList
      or (DelimiterType <> ttUnknown) and not DelimiterFound
      or (DelimiterType <> ttSemicolon) and (ErrorFound or (CurrentToken > 0) and (TokenPtr(CurrentToken)^.TokenType = ttSemicolon))
      or (DelimiterType = ttSemicolon)
        and InPL_SQL
        and ((TokenPtr(CurrentToken)^.KeywordIndex = kiELSE)
          or (TokenPtr(CurrentToken)^.KeywordIndex = kiELSEIF)
          or (TokenPtr(CurrentToken)^.KeywordIndex = kiEND)
          or (TokenPtr(CurrentToken)^.KeywordIndex = kiUNTIL)
          or (TokenPtr(CurrentToken)^.KeywordIndex = kiWHEN)));

  if (not ErrorFound) then
    if (not (DelimiterType in [ttUnknown, ttSemicolon])
      and DelimiterFound
      and EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if ((DelimiterType = ttSemicolon) and not DelimiterFound and not EndOfStmt(CurrentToken)) then
      SetError(PE_UnexpectedToken)
    else if (not CanEmpty and (Children.Count = 0)) then
      if (EndOfStmt(CurrentToken)) then
        SetError(PE_IncompleteStmt)
      else
        SetError(PE_UnexpectedToken);

  if (not ErrorFound and Brackets) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TList.Create(Self, Nodes, DelimiterType, @Children);
end;

function TSQLParser.ParseLoadDataStmt(): TOffset;
var
  Found: Boolean;
  Nodes: TLoadDataStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiLOAD, kiDATA);

  if (not ErrorFound) then
    if (IsTag(kiLOW_PRIORITY)) then
      Nodes.PriorityTag := ParseTag(kiLOW_PRIORITY)
    else if (IsTag(kiCONCURRENT)) then
      Nodes.PriorityTag := ParseTag(kiCONCURRENT);

  if (not ErrorFound) then
    if (IsTag(kiLOCAL, kiINFILE)) then
      Nodes.InfileTag := ParseTag(kiLOCAL, kiINFILE)
    else
      Nodes.InfileTag := ParseTag(kiINFILE);

  if (not ErrorFound) then
    Nodes.FilenameString := ParseString();

  if (not ErrorFound) then
    if (IsTag(kiREPLACE)) then
      Nodes.ReplaceIgnoreTag := ParseTag(kiREPLACE)
    else if (IsTag(kiIGNORE)) then
      Nodes.ReplaceIgnoreTag := ParseTag(kiIGNORE);

  if (not ErrorFound) then
    Nodes.IntoTableTag := ParseTag(kiINTO, kiTABLE);

  if (not ErrorFound) then
    Nodes.Ident := ParseTableIdent();

  if (not ErrorFound) then
    if (IsTag(kiPARTITION)) then
    begin
      Nodes.PartitionTag := ParseTag(kiPARTITION);

      if (not ErrorFound) then
        Nodes.PartitionList := ParseList(True, ParsePartitionIdent);
    end;

  if (not ErrorFound) then
    if (IsTag(kiCHARACTER, kiSET)) then
      Nodes.CharacterSetValue := ParseValue(WordIndices(kiCHARACTER, kiSET), vaNo, ParseCharsetIdent)
    else if (IsTag(kiCHARSET)) then
      Nodes.CharacterSetValue := ParseValue(kiCHARSET, vaNo, ParseCharsetIdent);

  if (not ErrorFound) then
    if (IsTag(kiFIELDS)
      or IsTag(kiCOLUMNS)) then
    begin
      if (IsTag(kiFIELDS)) then
        Nodes.ColumnsTag := ParseTag(kiFIELDS)
      else
        Nodes.ColumnsTag := ParseTag(kiCOLUMNS);

      Found := True;
      while (not ErrorFound and Found) do
        if ((Nodes.ColumnsTerminatedByValue = 0) and IsTag(kiTERMINATED, kiBY)) then
          Nodes.ColumnsTerminatedByValue := ParseValue(WordIndices(kiTERMINATED, kiBY), vaNo, ParseString)
        else if ((Nodes.EnclosedByValue = 0) and IsTag(kiOPTIONALLY, kiENCLOSED, kiBY)) then
          Nodes.EnclosedByValue := ParseValue(WordIndices(kiOPTIONALLY, kiENCLOSED, kiBY), vaNo, ParseString)
        else if ((Nodes.EnclosedByValue = 0) and IsTag(kiENCLOSED, kiBY)) then
          Nodes.EnclosedByValue := ParseValue(WordIndices(kiENCLOSED, kiBY), vaNo, ParseString)
        else if ((Nodes.EscapedByValue = 0) and IsTag(kiESCAPED, kiBY)) then
          Nodes.EscapedByValue := ParseValue(WordIndices(kiESCAPED, kiBY), vaNo, ParseString)
        else
          Found := False;

      if (not ErrorFound
        and (Nodes.ColumnsTerminatedByValue = 0)
        and (Nodes.EnclosedByValue = 0)
        and (Nodes.EscapedByValue = 0)) then
        if (EndOfStmt(CurrentToken)) then
          SetError(PE_IncompleteStmt)
        else
          SetError(PE_UnexpectedToken);
    end;

  if (not ErrorFound) then
    if (IsTag(kiLINES)) then
    begin
      Nodes.Lines.Tag := ParseTag(kiLINES);

      Found := True;
      while (not ErrorFound and Found) do
        if ((Nodes.Lines.StartingByValue = 0) and IsTag(kiSTARTING, kiBY)) then
          Nodes.Lines.StartingByValue := ParseValue(WordIndices(kiSTARTING, kiBY), vaNo, ParseString)
        else if ((Nodes.Lines.TerminatedByValue = 0) and IsTag(kiTERMINATED, kiBY)) then
          Nodes.Lines.TerminatedByValue := ParseValue(WordIndices(kiTERMINATED, kiBY), vaNo, ParseString)
        else
          Found := False;

      if (not ErrorFound
        and (Nodes.Lines.StartingByValue = 0)
        and (Nodes.Lines.TerminatedByValue = 0)) then
        if (EndOfStmt(CurrentToken)) then
          SetError(PE_IncompleteStmt)
        else
          SetError(PE_UnexpectedToken);
    end;

  if (IsTag(kiIGNORE)) then
  begin
    Nodes.Ignore.Tag := ParseTag(kiIGNORE);

    if (not ErrorFound) then
      Nodes.Ignore.NumberToken := ParseInteger();

    if (not ErrorFound) then
      if (IsTag(kiLINES)) then
        Nodes.Ignore.LinesTag := ParseTag(kiLINES)
      else
        Nodes.Ignore.LinesTag := ParseTag(kiROWS);
  end;

  if (IsSymbol(ttOpenBracket)) then
    Nodes.ColumnList := ParseList(True, ParseFieldOrVariableIdent);

  if (not ErrorFound) then
    if (IsTag(kiSET)) then
      Nodes.SetList := ParseValue(kiSET, vaNo, False, ParseUpdateStmtValue);

  Result := TLoadDataStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseLoadStmt(): TOffset;
begin
  if (IsTag(kiLOAD, kiDATA)) then
    Result := ParseLoadDataStmt()
  else
    Result := ParseLoadXMLStmt();
end;

function TSQLParser.ParseLoadXMLStmt(): TOffset;
var
  Nodes: TLoadXMLStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiLOAD, kiXML);

  if (IsTag(kiLOW_PRIORITY)) then
      Nodes.PriorityTag := ParseTag(kiLOW_PRIORITY)
    else if (IsTag(kiCONCURRENT)) then
      Nodes.PriorityTag := ParseTag(kiCONCURRENT);

  if (not ErrorFound) then
    if (IsTag(kiLOCAL, kiINFILE)) then
      Nodes.InfileTag := ParseTag(kiLOCAL, kiINFILE)
    else
      Nodes.InfileTag := ParseTag(kiINFILE);

  if (not ErrorFound and not EndOfStmt(CurrentToken)) then
    if (IsTag(kiREPLACE)) then
      Nodes.ReplaceIgnoreTag := ParseTag(kiREPLACE)
    else if (IsTag(kiIGNORE)) then
      Nodes.ReplaceIgnoreTag := ParseTag(kiIGNORE);

  if (not ErrorFound) then
    Nodes.IntoTableValue := ParseValue(WordIndices(kiINTO, kiTABLE), vaNo, ParseTableIdent);

  if (not ErrorFound) then
    if (IsTag(kiCHARACTER, kiSET)) then
      Nodes.CharacterSetValue := ParseValue(WordIndices(kiCHARACTER, kiSET), vaNo, ParseCharsetIdent)
    else if (IsTag(kiCHARSET)) then
      Nodes.CharacterSetValue := ParseValue(kiCHARSET, vaNo, ParseCharsetIdent);

  if (not ErrorFound) then
    if (IsTag(kiROWS, kiIDENTIFIED, kiBY)) then
      Nodes.RowsIdentifiedByValue := ParseValue(WordIndices(kiROWS, kiIDENTIFIED, kiBY), vaNo, ParseString);

  if (not ErrorFound) then
    if (IsTag(kiIGNORE)) then
    begin
      Nodes.Ignore.Tag := ParseTag(kiIGNORE);

      if (not ErrorFound) then
        Nodes.Ignore.NumberToken := ParseInteger();

      if (not ErrorFound) then
        if (IsTag(kiLINES)) then
          Nodes.Ignore.LinesTag := ParseTag(kiLINES)
        else
          Nodes.Ignore.LinesTag := ParseTag(kiROWS);
    end;

  if (not ErrorFound) then
    if (IsSymbol(ttOpenBracket)) then
      Nodes.FieldList := ParseList(True, ParseFieldIdent);

  if (not ErrorFound) then
    if (IsTag(kiSET)) then
      Nodes.SetList := ParseValue(kiSET, vaNo, False, ParseUpdateStmtValue);

  Result := TLoadXMLStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseLockTableStmt(): TOffset;
var
  Nodes: TLockTablesStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.LockTablesTag := ParseTag(kiLOCK, kiTABLES);

  if (not ErrorFound) then
    Nodes.ItemList := ParseList(False, ParseLockStmtItem);

  Result := TLockTablesStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseLockStmtItem(): TOffset;
var
  Nodes: TLockTablesStmt.TItem.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Ident := ParseTableIdent();

  if (not ErrorFound) then
    if (IsTag(kiAS)) then
    begin
      Nodes.AsTag := ParseTag(kiAS);

      if (not ErrorFound) then
        Nodes.AliasIdent := ParseTableAliasIdent();
    end;

  if (not ErrorFound
    and not EndOfStmt(CurrentToken)
    and (Nodes.AliasIdent = 0)
    and ((TokenPtr(CurrentToken)^.TokenType in [ttString, ttMySQLIdent, ttDQIdent])
      or (TokenPtr(CurrentToken)^.TokenType = ttIdent) and (ReservedWordList.IndexOf(TokenPtr(CurrentToken)^.FText, TokenPtr(CurrentToken)^.FLength) < 0))) then
    Nodes.AliasIdent := ParseTableAliasIdent();

  if (not ErrorFound) then
    if (IsTag(kiREAD, kiLOCAL)) then
      Nodes.LockTypeTag := ParseTag(kiREAD, kiLOCAL)
    else if (IsTag(kiREAD)) then
      Nodes.LockTypeTag := ParseTag(kiREAD)
    else if (IsTag(kiLOW_PRIORITY, kiWRITE)) then
      Nodes.LockTypeTag := ParseTag(kiLOW_PRIORITY, kiWRITE)
    else
      Nodes.LockTypeTag := ParseTag(kiWRITE);

  Result := TLockTablesStmt.TItem.Create(Self, Nodes);
end;

function TSQLParser.ParseLoopStmt(const BeginLabel: TOffset = 0): TOffset;
var
  Nodes: TLoopStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.BeginLabel := BeginLabel;

  Nodes.BeginTag := ParseTag(kiLOOP);

  if (not ErrorFound) then
    Nodes.StmtList := ParseList(False, ParsePL_SQLStmt, ttSemicolon, False);

  if (not ErrorFound) then
    Nodes.EndTag := ParseTag(kiEND, kiLOOP);

  if (not ErrorFound
    and not EndOfStmt(CurrentToken) and (TokenPtr(CurrentToken)^.TokenType = ttIdent)
    and (Nodes.BeginLabel > 0) and (NodePtr(Nodes.BeginLabel)^.NodeType = ntBeginLabel)) then
    if ((Nodes.BeginLabel = 0) or (lstrcmpi(PChar(TokenPtr(CurrentToken)^.AsString), PChar(PBeginLabel(NodePtr(Nodes.BeginLabel))^.LabelName)) <> 0)) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.EndLabel := ParseEndLabel();

  Result := TLoopStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseMatchFunc(): TOffset;
var
  Nodes: TMatchFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.MatchList := ParseList(True, ParseExpr);

  if (not ErrorFound) then
    Nodes.AgainstTag := ParseTag(kiAGAINST);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    Nodes.Expr := ParseExpr([]);

  if (not ErrorFound and not EndOfStmt(CurrentToken)) then
    if (IsTag(kiIN, kiNATURAL, kiLANGUAGE, kiMODE, kiWITH, kiQUERY, kiEXPANSION)) then
      Nodes.SearchModifierTag := ParseTag(kiIN, kiNATURAL, kiLANGUAGE, kiMODE, kiWITH, kiQUERY, kiEXPANSION)
    else if (IsTag(kiIN, kiNATURAL, kiLANGUAGE, kiMODE)) then
      Nodes.SearchModifierTag := ParseTag(kiIN, kiNATURAL, kiLANGUAGE, kiMODE)
    else if (IsTag(kiIN, kiBOOLEAN, kiMODE)) then
      Nodes.SearchModifierTag := ParseTag(kiIN, kiBOOLEAN, kiMODE)
    else if (IsTag(kiWITH, kiQUERY, kiEXPANSION)) then
      Nodes.SearchModifierTag := ParseTag(kiWITH, kiQUERY, kiEXPANSION);

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TMatchFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseProcedureIdent(): TOffset;
begin
  Result := ParseDbIdent(ditProcedure);
end;

function TSQLParser.ParseMaxValue(): TOffset;
begin
  Result := ParseTag(kiMAXVALUE);
end;

function TSQLParser.ParseOpenStmt(): TOffset;
var
  Nodes: TOpenStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiOPEN);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent(ditCursor, False);

  Result := TOpenStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseOptimizeTableStmt(): TOffset;
var
  Nodes: TOptimizeTableStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiOPTIMIZE);

  if (not ErrorFound) then
    if (IsTag(kiNO_WRITE_TO_BINLOG)) then
      Nodes.OptionTag := ParseTag(kiNO_WRITE_TO_BINLOG)
    else if (IsTag(kiLOCAL)) then
      Nodes.OptionTag := ParseTag(kiLOCAL);

  if (not ErrorFound) then
    Nodes.TableTag := ParseTag(kiTABLE);

  if (not ErrorFound) then
    Nodes.TablesList := ParseList(False, ParseTableIdent);

  Result := TOptimizeTableStmt.Create(Self, Nodes);
end;

function TSQLParser.ParsePartitionIdent(): TOffset;
begin
  Result := ParseDbIdent(ditPartition);
end;

function TSQLParser.ParsePositionFunc(): TOffset;
var
  Nodes: TPositionFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    Nodes.SubStr := ParseExpr([]);

  if (not ErrorFound) then
    Nodes.InTag := ParseTag(kiIN);

  if (not ErrorFound) then
    Nodes.Str := ParseExpr();

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TPositionFunc.Create(Self, Nodes);
end;

function TSQLParser.ParsePL_SQLStmt(): TOffset;
begin
  BeginPL_SQL();
  Result := ParseStmt();
  EndPL_SQL();
end;

function TSQLParser.ParsePrepareStmt(): TOffset;
var
  Nodes: TPrepareStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiPREPARE);

  if (not ErrorFound) then
    Nodes.StmtIdent := ParseDbIdent();

  if (not ErrorFound) then
    Nodes.FromTag := ParseTag(kiFROM);

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (TokenPtr(CurrentToken)^.TokenType in ttStrings) then
      Nodes.Stmt := ParseString()
    else
      Nodes.Stmt := ParseVariableIdent();

  Result := TPrepareStmt.Create(Self, Nodes);
end;

function TSQLParser.ParsePurgeStmt(): TOffset;
var
  Nodes: TPurgeStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiPURGE);

  if (not ErrorFound) then
    if (IsTag(kiBINARY)) then
      Nodes.TypeTag := ParseTag(kiBINARY)
    else if (IsTag(kiMASTER)) then
      Nodes.TypeTag := ParseTag(kiMASTER)
    else if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
    Nodes.LogsTag := ParseTag(kiLOGS);

  if (not ErrorFound) then
    if (IsTag(kiTO)) then
      Nodes.Value := ParseValue(kiTO, vaNo, ParseString)
    else if (IsTag(kiBEFORE)) then
      Nodes.Value := ParseValue(kiBEFORE, vaNo, ParseExpr)
    else if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  Result := TPurgeStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseProcedureParam(): TOffset;
var
  Nodes: TRoutineParam.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiIN)) then
    Nodes.DirektionTag := ParseTag(kiIN)
  else if (IsTag(kiOUT)) then
    Nodes.DirektionTag := ParseTag(kiOUT)
  else if (IsTag(kiINOUT)) then
    Nodes.DirektionTag := ParseTag(kiINOUT);

  if (not ErrorFound) then
    Nodes.IdentToken := ParseRoutineParamIdent();

  if (not ErrorFound) then
    Nodes.DatatypeNode := ParseDatatype();

  Result := TRoutineParam.Create(Self, Nodes);
end;

function TSQLParser.ParseReleaseStmt(): TOffset;
var
  Nodes: TReleaseStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.ReleaseTag := ParseTag(kiRELEASE, kiSAVEPOINT);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent();

  Result := TReleaseStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseRenameStmt(): TOffset;
var
  Nodes: TRenameStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiRENAME, kiTABLE)) then
  begin
    Nodes.StmtTag := ParseTag(kiRENAME, kiTABLE);

    if (not ErrorFound) then
      Nodes.RenameList := ParseList(False, ParseRenameStmtTablePair);
  end
  else
  begin
    Nodes.StmtTag := ParseTag(kiRENAME, kiUSER);

    if (not ErrorFound) then
      Nodes.RenameList := ParseList(False, ParseRenameStmtUserPair);
  end;

  Result := TRenameStmt.Create(Self, Nodes)
end;

function TSQLParser.ParseRenameStmtTablePair(): TOffset;
var
  Nodes: TRenameStmt.TPair.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.OrgNode := ParseTableIdent();

  if (not ErrorFound) then
    Nodes.ToTag := ParseTag(kiTO);

  if (not ErrorFound) then
    Nodes.NewNode := ParseTableIdent();

  Result := TRenameStmt.TPair.Create(Self, Nodes);
end;

function TSQLParser.ParseRenameStmtUserPair(): TOffset;
var
  Nodes: TRenameStmt.TPair.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.OrgNode := ParseAccountIdent();

  if (not ErrorFound) then
    Nodes.ToTag := ParseTag(kiTO);

  if (not ErrorFound) then
    Nodes.NewNode := ParseAccountIdent();

  Result := TRenameStmt.TPair.Create(Self, Nodes);
end;

function TSQLParser.ParseRepairTableStmt(): TOffset;
var
  Nodes: TRepairTableStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiREPAIR);

  if (not ErrorFound) then
    if (IsTag(kiNO_WRITE_TO_BINLOG)) then
      Nodes.OptionTag := ParseTag(kiNO_WRITE_TO_BINLOG)
    else if (IsTag(kiLOCAL)) then
      Nodes.OptionTag := ParseTag(kiLOCAL);

  if (not ErrorFound) then
    Nodes.TableTag := ParseTag(kiTABLE);

  if (not ErrorFound) then
    Nodes.TablesList := ParseList(False, ParseTableIdent);

  if (not ErrorFound) then
    if (IsTag(kiQUICK)) then
      Nodes.QuickTag := ParseTag(kiQUICK);

  if (not ErrorFound) then
    if (IsTag(kiEXTENDED)) then
      Nodes.ExtendedTag := ParseTag(kiEXTENDED);

  if (not ErrorFound) then
    if (IsTag(kiUSE_FRM)) then
      Nodes.UseFrmTag := ParseTag(kiUSE_FRM);

  Result := TRepairTableStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseRepeatStmt(const BeginLabel: TOffset = 0): TOffset;
var
  Nodes: TRepeatStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.BeginLabel := BeginLabel;

  Nodes.RepeatTag := ParseTag(kiREPEAT);

  if (not ErrorFound) then
    Nodes.StmtList := ParseList(False, ParsePL_SQLStmt, ttSemicolon, False);

  if (not ErrorFound) then
    Nodes.UntilTag := ParseTag(kiUNTIL);

  if (not ErrorFound) then
    Nodes.SearchConditionExpr := ParseExpr();

  if (not ErrorFound) then
    Nodes.EndTag := ParseTag(kiEND, kiREPEAT);

  if (not ErrorFound
    and not EndOfStmt(CurrentToken) and (TokenPtr(CurrentToken)^.TokenType = ttIdent)
    and (Nodes.BeginLabel > 0) and (NodePtr(Nodes.BeginLabel)^.NodeType = ntBeginLabel)) then
    if ((Nodes.BeginLabel = 0) or (lstrcmpi(PChar(TokenPtr(CurrentToken)^.AsString), PChar(PBeginLabel(NodePtr(Nodes.BeginLabel))^.LabelName)) <> 0)) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.EndLabel := ParseEndLabel();

  Result := TRepeatStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseRevokeStmt(): TOffset;
var
  Nodes: TRevokeStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiREVOKE);

  if (not ErrorFound) then
    if (not IsTag(kiALL)
      and not IsTag(kiPROXY)) then
    begin
      Nodes.PrivilegesList := ParseList(False, ParseGrantStmtPrivileg);

      if (not ErrorFound) then
        Nodes.OnTag := ParseTag(kiON);

      if (not ErrorFound) then
        if (IsTag(kiTABLE)) then
        begin
          Nodes.ObjectTypeTag := ParseTag(kiTABLE);

          if (not ErrorFound) then
            Nodes.PrivLevelIdent := ParseDbIdent(ditTable, True, True);
        end
        else if (IsTag(kiPROCEDURE)) then
        begin
          Nodes.ObjectTypeTag := ParseTag(kiPROCEDURE);

          if (not ErrorFound) then
            Nodes.PrivLevelIdent := ParseDbIdent(ditProcedure, True, True);
        end
        else if (IsTag(kiFUNCTION)) then
        begin
          Nodes.ObjectTypeTag := ParseTag(kiFUNCTION);

          if (not ErrorFound) then
            Nodes.PrivLevelIdent := ParseDbIdent(ditFunction, True, True);
        end
        else
          Nodes.PrivLevelIdent := ParseDbIdent(ditTable, True, True);

      if (not ErrorFound) then
        Nodes.FromTag := ParseTag(kiFROM);

      if (not ErrorFound) then
        Nodes.UserIdentList := ParseList(False, ParseAccountIdent);
    end
    else if (IsTag(kiALL, kiPRIVILEGES)) then
    begin
      Nodes.PrivilegesList := ParseTag(kiALL, kiPRIVILEGES);

      if (not ErrorFound) then
        Nodes.CommaToken := ParseSymbol(ttComma);

      if (not ErrorFound) then
        Nodes.GrantOptionTag := ParseTag(kiGRANT, kiOPTION);

      if (not ErrorFound) then
        Nodes.FromTag := ParseTag(kiFROM);

      if (not ErrorFound) then
        Nodes.UserIdentList := ParseList(False, ParseAccountIdent);
    end
    else if (IsTag(kiPROXY, kiON)) then
    begin
      Nodes.PrivilegesList := ParseTag(kiPROXY);

      if (not ErrorFound) then
        Nodes.OnTag := ParseTag(kiON);

      if (not ErrorFound) then
        Nodes.AccountIdent := ParseAccountIdent();

      if (not ErrorFound) then
        Nodes.FromTag := ParseTag(kiFROM);

      if (not ErrorFound) then
        Nodes.UserIdentList := ParseList(False, ParseAccountIdent);
    end
    else if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  Result := TRevokeStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseResetStmt(): TOffset;
var
  Nodes: TResetStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiRESET);

  if (not ErrorFound) then
    Nodes.OptionList := ParseList(False, ParseResetStmtOption);

  Result := TResetStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseResetStmtOption(): TOffset;
var
  Nodes: TResetStmt.TOption.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiMASTER)) then
    Nodes.OptionTag := ParseTag(kiMASTER)
  else if (IsTag(kiQUERY, kiCACHE)) then
    Nodes.OptionTag := ParseTag(kiQUERY, kiCACHE)
  else if (IsTag(kiSLAVE, kiALL)) then
  begin
    Nodes.OptionTag := ParseTag(kiSLAVE, kiALL);

    if (IsTag(kiFOR, kiCHANNEL)) then
      Nodes.ChannelValue := ParseValue(WordIndices(kiFOR, kiCHANNEL), vaNo, ParseDbIdent);
  end
  else if (IsTag(kiSLAVE)) then
  begin
    Nodes.OptionTag := ParseTag(kiSLAVE);

    if (IsTag(kiFOR, kiCHANNEL)) then
      Nodes.ChannelValue := ParseValue(WordIndices(kiFOR, kiCHANNEL), vaNo, ParseDbIdent);
  end
  else if (EndOfStmt(CurrentToken)) then
    SetError(PE_IncompleteStmt)
  else
    SetError(PE_UnexpectedToken);

  Result := TResetStmt.TOption.Create(Self, Nodes);
end;

function TSQLParser.ParseReturnStmt(): TOffset;
var
  Nodes: TReturnStmt.TNodes;
begin
  Assert(Parse.InCreateFunctionStmt);

  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiRETURN);

  if (not ErrorFound) then
    Nodes.Expr := ParseExpr();

  Result := TReturnStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseRollbackStmt(): TOffset;
var
  Nodes: TRollbackStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiROLLBACK, kiWORK)) then
    Nodes.RollbackTag := ParseTag(kiROLLBACK, kiWORK)
  else
    Nodes.RollbackTag := ParseTag(kiROLLBACK);

  if (not ErrorFound) then
    if (IsTag(kiTO, kiSAVEPOINT)) then
      Nodes.ToValue := ParseValue(WordIndices(kiTO, kiSAVEPOINT), vaNo, ParseDbIdent)
    else if (IsTag(kiTO)) then
      Nodes.ToValue := ParseValue(kiTO, vaNo, ParseDbIdent)
    else
    begin
      if (IsTag(kiAND, kiNO, kiCHAIN)) then
        Nodes.ChainTag := ParseTag(kiAND, kiNO, kiCHAIN)
      else if (IsTag(kiAND, kiCHAIN)) then
        Nodes.ChainTag := ParseTag(kiAND, kiCHAIN);

      if (not ErrorFound) then
        if (IsTag(kiNO, kiRELEASE)) then
          Nodes.ReleaseTag := ParseTag(kiNO, kiRELEASE)
        else if (IsTag(kiRELEASE)) then
          Nodes.ReleaseTag := ParseTag(kiRELEASE);
    end;

  Result := TRollbackStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseRoot(): TOffset;
var
  FirstTokenAll: TOffset;
  StmtList: TOffset;
begin
  if (not AnsiQuotes) then
  begin
    ttIdents := [ttIdent, ttMySQLIdent];
    ttStrings := [ttIdent, ttString, ttDQIdent];
  end
  else
  begin
    ttIdents := [ttIdent, ttMySQLIdent, ttDQIdent];
    ttStrings := [ttIdent, ttString];
  end;

  Parse.Pos := PChar(Parse.SQL);
  Parse.Length := Length(Parse.SQL);
  Parse.Line := 1;

  if (Parse.Length = 0) then
    FirstTokenAll := 0
  else
    FirstTokenAll := Nodes.UsedSize;

  CurrentToken := GetToken(0); // Cache for speeding

  CreateProfile(Profile);

  StmtList := ParseList(False, ParseStmt, ttSemicolon, True, True);

  if (ProfilingTime(Profile) > 1000) then
    SendToDeveloper(ProfilingReport(Profile) + #13#10#13#10
      + Parse.SQL);
  CloseProfile(Profile);

  Result := TRoot.Create(Self, FirstTokenAll, StmtList);

  CompletionList.Cleanup();
end;

function TSQLParser.ParseRoutineParamIdent(): TOffset;
begin
  Result := ParseDbIdent(ditRoutineParam, False);
end;

function TSQLParser.ParseSavepointStmt(): TOffset;
var
  Nodes: TSavepointStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.SavepointTag := ParseTag(kiSAVEPOINT);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent();

  Result := TSavepointStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseSchedule(): TOffset;
var
  Nodes: TSchedule.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiAT)) then
    Nodes.AtValue := ParseValue(kiAT, vaNo, ParseExpr)
  else if (IsTag(kiEVERY)) then
  begin
    Nodes.EveryTag := ParseTag(kiEVERY);

    if (not ErrorFound) then
      Nodes.QuantityExpr := ParseExpr();

    if (not ErrorFound) then
      Nodes.UnitTag := ParseIntervalUnitTag();

    if (not ErrorFound) then
      if (IsTag(kiSTARTS)) then
        Nodes.StartsValue := ParseValue(kiSTARTS, vaNo, ParseExpr);

    if (not ErrorFound) then
      if (IsTag(kiENDS)) then
        Nodes.EndsValue := ParseValue(kiENDS, vaNo, ParseExpr);
  end
  else if (EndOfStmt(CurrentToken)) then
    SetError(PE_IncompleteStmt)
  else
    SetError(PE_UnexpectedToken);

  Result := TSchedule.Create(Self, Nodes);
end;

function TSQLParser.ParseSecretIdent(): TOffset;
var
  Nodes: TSecretIdent.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (EndOfStmt(CurrentToken)) then
    SetError(PE_IncompleteStmt)
  else if (TokenPtr(CurrentToken)^.OperatorType <> otLess) then
    SetError(PE_UnexpectedToken)
  else
    Nodes.OpenAngleBracket := ApplyCurrentToken(utSymbol);

  if (not ErrorFound) then
    Nodes.ItemToken := ParseDbIdent();

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (TokenPtr(CurrentToken)^.OperatorType <> otGreater) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.CloseAngleBracket := ApplyCurrentToken(utSymbol);

  Result := TSecretIdent.Create(Self, Nodes);
end;

function TSQLParser.ParseSelectStmt(const SubSelect: Boolean; const UnionSelect: Boolean = False; const TableFactor: Boolean = False): TOffset;

  function ParseInto(): TSelectStmt.TIntoNodes;
  var
    Found: Boolean;
  begin
    FillChar(Result, SizeOf(Result), 0);

    if (IsTag(kiINTO, kiOUTFILE)) then
    begin
      Result.Tag := ParseTag(kiINTO, kiOUTFILE);

      if (not ErrorFound) then
        Result.Filename := ParseString();

      if (not ErrorFound) then
        if (IsTag(kiCHARACTER, kiSET)) then
          Result.CharacterSetValue := ParseValue(WordIndices(kiCHARACTER, kiSET), vaNo, ParseCharsetIdent)
        else if (IsTag(kiCHARSET)) then
          Result.CharacterSetValue := ParseValue(kiCHARSET, vaNo, ParseCharsetIdent);

      if (not ErrorFound) then
      begin
        if (IsTag(kiFIELDS)) then
          Result.Fields.Tag := ParseTag(kiFIELDS)
        else if (IsTag(kiCOLUMNS)) then
          Result.Fields.Tag := ParseTag(kiCOLUMNS);

        if (Result.Fields.Tag > 0) then
        begin
          Found := True;
          while (not ErrorFound and Found) do
            if ((Result.Fields.TerminatedByString = 0) and IsTag(kiTERMINATED, kiBY)) then
              Result.Fields.TerminatedByString := ParseValue(WordIndices(kiTERMINATED, kiBY), vaNo, ParseString)
            else if ((Result.Fields.EnclosedByString = 0) and IsTag(kiOPTIONALLY, kiENCLOSED, kiBY)) then
              Result.Fields.EnclosedByString := ParseValue(WordIndices(kiOPTIONALLY, kiENCLOSED, kiBY), vaNo, ParseString)
            else if ((Result.Fields.EnclosedByString = 0) and IsTag(kiENCLOSED, kiBY)) then
              Result.Fields.EnclosedByString := ParseValue(WordIndices(kiENCLOSED, kiBY), vaNo, ParseString)
            else if ((Result.Fields.EscapedByString = 0) and IsTag(kiESCAPED, kiBY)) then
              Result.Fields.EscapedByString := ParseValue(WordIndices(kiESCAPED, kiBY), vaNo, ParseString)
            else
              Found := False;

          if (not ErrorFound
            and (Result.Fields.TerminatedByString = 0)
            and (Result.Fields.EnclosedByString = 0)
            and (Result.Fields.EscapedByString = 0)) then
            if (EndOfStmt(CurrentToken)) then
              SetError(PE_IncompleteStmt)
            else
              SetError(PE_UnexpectedToken);
        end;
      end;

      if (not ErrorFound) then
        if (IsTag(kiLINES)) then
        begin
          Result.Lines.Tag := ParseTag(kiLINES);

          Found := True;
          while (not ErrorFound and Found) do
            if ((Result.Lines.StartingByString = 0) and IsTag(kiSTARTING, kiBY)) then
              Result.Lines.StartingByString := ParseValue(WordIndices(kiSTARTING, kiBY), vaNo, ParseString)
            else if ((Result.Lines.TerminatedByString = 0) and IsTag(kiTERMINATED, kiBY)) then
              Result.Lines.TerminatedByString := ParseValue(WordIndices(kiTERMINATED, kiBY), vaNo, ParseString)
            else
              Found := False;

          if (not ErrorFound
            and (Result.Lines.StartingByString = 0)
            and (Result.Lines.TerminatedByString = 0)) then
            if (EndOfStmt(CurrentToken)) then
              SetError(PE_IncompleteStmt)
            else
              SetError(PE_UnexpectedToken);
        end;
    end
    else if (IsTag(kiINTO, kiDUMPFILE)) then
    begin
      Result.Tag := ParseTag(kiINTO, kiDUMPFILE);

      if (not ErrorFound) then
        Result.Filename := ParseString();
    end
    else
    begin
      Result.Tag := ParseTag(kiINTO);

      if (not ErrorFound) then
        Result.VariableList := ParseList(False, ParseVariableIdent);
    end;
  end;

var
  CloseBracket1Count: Integer;
  Element: PChild;
  Elements: TOffsetList;
  Found: Boolean;
  ListNodes: TList.TNodes;
  Nodes: TSelectStmt.TNodes;
  OpenBracketCount: Integer;
  UnionAllowed: Boolean;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);
  UnionAllowed := True;

  Elements.Init();
  while (IsSymbol(ttOpenBracket)) do
    Elements.Add(ParseSymbol(ttOpenBracket));
  OpenBracketCount := Elements.Count;
  if (OpenBracketCount > 0) then
  begin
    FillChar(ListNodes, SizeOf(ListNodes), 0);
    Nodes.OpenBrackets := TList.Create(Self, ListNodes, ttComma, @Elements);
  end;

  if (not ErrorFound) then
    Nodes.SelectTag := ParseTag(kiSELECT);

  Found := True;
  while (not ErrorFound and Found) do
    if ((Nodes.DistinctTag = 0) and IsTag(kiALL)) then
      Nodes.DistinctTag := ParseTag(kiALL)
    else if ((Nodes.DistinctTag = 0) and IsTag(kiDISTINCT)) then
      Nodes.DistinctTag := ParseTag(kiDISTINCT)
    else if ((Nodes.DistinctTag = 0) and IsTag(kiDISTINCTROW)) then
      Nodes.DistinctTag := ParseTag(kiDISTINCTROW)
    else if ((Nodes.HighPriorityTag = 0) and IsTag(kiHIGH_PRIORITY)) then
      Nodes.HighPriorityTag := ParseTag(kiHIGH_PRIORITY)
    else if ((Nodes.MaxStatementTime = 0) and IsTag(kiMAX_STATEMENT_TIME)) then
      Nodes.MaxStatementTime := ParseValue(kiMAX_STATEMENT_TIME, vaYes, ParseInteger)
    else if ((Nodes.StraightJoinTag = 0) and IsTag(kiSTRAIGHT_JOIN)) then
      Nodes.StraightJoinTag := ParseTag(kiSTRAIGHT_JOIN)
    else if ((Nodes.SQLSmallResultTag = 0) and IsTag(kiSQL_SMALL_RESULT)) then
      Nodes.SQLSmallResultTag := ParseTag(kiSQL_SMALL_RESULT)
    else if ((Nodes.SQLBigResultTag = 0) and IsTag(kiSQL_BIG_RESULT)) then
      Nodes.SQLBigResultTag := ParseTag(kiSQL_BIG_RESULT)
    else if ((Nodes.SQLBufferResultTag = 0) and IsTag(kiSQL_BUFFER_RESULT)) then
      Nodes.SQLBufferResultTag := ParseTag(kiSQL_BUFFER_RESULT)
    else if ((Nodes.SQLNoCacheTag = 0) and IsTag(kiSQL_CACHE)) then
      Nodes.SQLNoCacheTag := ParseTag(kiSQL_CACHE)
    else if ((Nodes.SQLNoCacheTag = 0) and IsTag(kiSQL_NO_CACHE)) then
      Nodes.SQLNoCacheTag := ParseTag(kiSQL_NO_CACHE)
    else if ((Nodes.SQLCalcFoundRowsTag = 0) and IsTag(kiSQL_CALC_FOUND_ROWS)) then
      Nodes.SQLCalcFoundRowsTag := ParseTag(kiSQL_CALC_FOUND_ROWS)
    else
      Found := False;

  if (not ErrorFound) then
  begin
    Nodes.ColumnsList := ParseList(False, ParseSelectStmtColumn);

    if (not ErrorFound and (Nodes.ColumnsList > 0)) then
    begin
      Element := PList(NodePtr(Nodes.ColumnsList))^.FirstElement;
      if (Assigned(Element)) then
        Element := PList(NodePtr(Nodes.ColumnsList))^.GetNextElement(Element);
      while (not ErrorFound and Assigned(Element)) do
      begin
        if (IsToken(TSelectStmt.PColumn(Element)^.Nodes.Expr)
          and (TokenPtr(TSelectStmt.PColumn(Element)^.Nodes.Expr)^.AsString = '*')) then
          SetError(PE_UnexpectedToken, TSelectStmt.PColumn(Element)^.Nodes.Expr);
        Element := PList(NodePtr(Nodes.ColumnsList))^.GetNextElement(Element);
      end;
    end;
  end;

  if (not ErrorFound and not SubSelect) then
    if (IsTag(kiINTO)) then
    begin
      UnionAllowed := False;
      Nodes.Into1 := ParseInto();
    end;

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
    begin
      Nodes.From.Tag := ParseTag(kiFROM);
      if (not ErrorFound) then
        Nodes.From.TableReferenceList := ParseList(False, ParseSelectStmtTableEscapedReference);

      if (not ErrorFound) then
        if (IsTag(kiPARTITION)) then
        begin
          Nodes.Partition.Tag := ParseTag(kiPARTITION);

          if (not ErrorFound) then
            Nodes.Partition.Ident := ParsePartitionIdent();
        end;

      if (not ErrorFound) then
        if (IsTag(kiWHERE)) then
        begin
          Nodes.Where.Tag := ParseTag(kiWHERE);

          if (not ErrorFound) then
            Nodes.Where.Expr := ParseExpr();
        end;

      if (not ErrorFound) then
        if (IsTag(kiGROUP, kiBY)) then
        begin
          Nodes.GroupBy.Tag := ParseTag(kiGROUP, kiBY);

          if (not ErrorFound) then
            Nodes.GroupBy.List := ParseList(False, ParseSelectStmtGroup);

          if (not ErrorFound) then
            if (IsTag(kiWITH, kiROLLUP)) then
              Nodes.GroupBy.WithRollupTag := ParseTag(kiWITH, kiROLLUP);
        end;

      if (not ErrorFound) then
        if (IsTag(kiHAVING)) then
        begin
          Nodes.Having.Tag := ParseTag(kiHAVING);

          if (not ErrorFound) then
            Nodes.Having.Expr := ParseExpr();
        end;

      if (not ErrorFound and not UnionSelect) then
        if (IsTag(kiORDER, kiBY)) then
          Nodes.OrderBy := ParseSelectStmtOrderBy();

      if (not ErrorFound and not UnionSelect) then
        if (IsTag(kiLIMIT)) then
          Nodes.Limit := ParseSelectStmtLimit();

      if (not ErrorFound) then
        if (IsTag(kiPROCEDURE)) then
        begin
          Nodes.Proc.Tag := ParseTag(kiPROCEDURE);

          if (not ErrorFound) then
            Nodes.Proc.Ident := ParseProcedureIdent();

          if (not ErrorFound) then
            Nodes.Proc.ParamList := ParseList(True, ParseExpr);
        end;

      if (not ErrorFound and not SubSelect) then
        if (IsTag(kiINTO)) then
          if (Nodes.Into1.Tag > 0) then
            SetError(PE_UnexpectedToken)
          else
          begin
            UnionAllowed := False;
            Nodes.Into2 := ParseInto();
          end;

      if (not ErrorFound and (Nodes.From.Tag > 0)) then
        if (IsTag(kiFOR, kiUPDATE)) then
          Nodes.ForUpdatesTag := ParseTag(kiFOR, kiUPDATE)
        else if (IsTag(kiLOCK, kiIN, kiSHARE, kiMODE)) then
          Nodes.LockInShareMode := ParseTag(kiLOCK, kiIN, kiSHARE, kiMODE);
    end;

  Elements.Init();
  while ((OpenBracketCount > Elements.Count) and IsSymbol(ttCloseBracket)) do
    Elements.Add(ParseSymbol(ttCloseBracket));
  CloseBracket1Count := Elements.Count;
  if (CloseBracket1Count > 0) then
  begin
    FillChar(ListNodes, SizeOf(ListNodes), 0);
    Nodes.CloseBrackets1 := TList.Create(Self, ListNodes, ttComma, @Elements);
  end;

  if (not ErrorFound
    and not UnionSelect
    and UnionAllowed
    and IsTag(kiUNION)) then
  begin
    Elements.Init();

    repeat
      if (IsTag(kiUNION, kiALL)) then
        Elements.Add(ParseTag(kiUNION, kiALL))
      else if (IsTag(kiUNION, kiDISTINCT)) then
        Elements.Add(ParseTag(kiUNION, kiDISTINCT))
      else
        Elements.Add(ParseTag(kiUNION));

      if (not ErrorFound) then
        Elements.Add(ParseSelectStmt(SubSelect, not IsSymbol(ttOpenBracket)));
    until (ErrorFound or not IsTag(kiUNION));

    if (not ErrorFound) then
      if (IsTag(kiORDER, kiBY)) then
        Elements.Add(ParseSelectStmtOrderBy());

    if (not ErrorFound) then
      if (IsTag(kiLIMIT)) then
        Elements.Add(ParseSelectStmtLimit());

    FillChar(ListNodes, SizeOf(ListNodes), 0);
    Nodes.UnionList := TList.Create(Self, ListNodes, ttUnknown, @Elements);
  end;

  Elements.Init();
  while ((OpenBracketCount - CloseBracket1Count > Elements.Count) and IsSymbol(ttCloseBracket)) do
    Elements.Add(ParseSymbol(ttCloseBracket));
  if (Elements.Count > 0) then
  begin
    FillChar(ListNodes, SizeOf(ListNodes), 0);
    Nodes.CloseBrackets2 := TList.Create(Self, ListNodes, ttComma, @Elements);
  end;

  Result := TSelectStmt.Create(Self, Nodes);

  if (not ErrorFound and (OpenBracketCount - CloseBracket1Count > Elements.Count)) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);
end;

function TSQLParser.ParseSelectStmtColumn(): TOffset;
var
  Nodes: TSelectStmt.TColumn.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Expr := ParseExpr([eoIn, eoAllFields, eoOperators]);

  if (not IsToken(Nodes.Expr)
    or (TokenPtr(Nodes.Expr)^.UsageType <> utDbIdent)
    or (TokenPtr(Nodes.Expr)^.AsString <> '*')) then
  begin
    if (not ErrorFound) then
      if (IsTag(kiAS)) then
      begin
        Nodes.AsTag := ParseTag(kiAS);

        if (not ErrorFound) then
          Nodes.AliasIdent := ParseColumnAliasIdent();
      end;

    if (not ErrorFound
      and not EndOfStmt(CurrentToken)
      and (Nodes.AliasIdent = 0)
      and ((TokenPtr(CurrentToken)^.TokenType in [ttString, ttMySQLIdent, ttDQIdent])
        or (TokenPtr(CurrentToken)^.TokenType = ttIdent) and (ReservedWordList.IndexOf(TokenPtr(CurrentToken)^.FText, TokenPtr(CurrentToken)^.FLength) < 0))) then
      Nodes.AliasIdent := ParseColumnAliasIdent();
  end;

  Result := TSelectStmt.TColumn.Create(Self, Nodes);
end;

function TSQLParser.ParseSelectStmtGroup(): TOffset;
var
  Nodes: TSelectStmt.TGroup.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Expr := ParseExpr();

  if (not ErrorFound) then
    if (IsTag(kiASC)) then
      Nodes.DirectionTag := ParseTag(kiASC)
    else if (IsTag(kiDESC)) then
      Nodes.DirectionTag := ParseTag(kiDESC);

  Result := TSelectStmt.TGroup.Create(Self, Nodes);
end;

function TSQLParser.ParseSelectStmtLimit(): TOffset;
var
  Nodes: TSelectStmt.TLimit.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Tag := ParseTag(kiLIMIT);

  if (not ErrorFound) then
    Nodes.RowCountToken := ParseExpr([]);

  if (not ErrorFound) then
    if (IsSymbol(ttComma)) then
    begin
      Nodes.CommaToken := ParseSymbol(ttComma);

      if (not ErrorFound) then
      begin
        Nodes.OffsetToken := Nodes.RowCountToken;
        Nodes.RowCountToken := ParseExpr([]);
      end;
    end
    else if (IsTag(kiOFFSET)) then
    begin
      Nodes.OffsetTag := ParseTag(kiOFFSET);

      if (not ErrorFound) then
        Nodes.OffsetToken := ParseExpr([]);
    end;
  Result := TSelectStmt.TLimit.Create(Self, Nodes);
end;

function TSQLParser.ParseSelectStmtOrder(): TOffset;
var
  Nodes: TSelectStmt.TOrder.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Expr := ParseExpr();

  if (not ErrorFound) then
    if (IsTag(kiASC)) then
      Nodes.DirectionTag := ParseTag(kiASC)
    else if (IsTag(kiDESC)) then
      Nodes.DirectionTag := ParseTag(kiDESC);

  Result := TSelectStmt.TOrder.Create(Self, Nodes);
end;

function TSQLParser.ParseSelectStmtOrderBy(): TOffset;
var
  Nodes: TSelectStmt.TOrderBy.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiORDER, kiBY, kiNULL)) then
    Nodes.Tag := ParseTag(kiORDER, kiBY, kiNULL)
  else if (IsTag(kiORDER, kiBY)) then
  begin
    Nodes.Tag := ParseTag(kiORDER, kiBY);

    if (not ErrorFound) then
      Nodes.List := ParseList(False, ParseSelectStmtOrder);
  end;

  Result := TSelectStmt.TOrderBy.Create(Self, Nodes);
end;

function TSQLParser.ParseSelectStmtTableFactor(): TOffset;
var
  Found: Boolean;
  IndexHints: TOffsetList;
  ListNodes: TList.TNodes;
  Nodes: TSelectStmt.TTableFactor.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Ident := ParseTableIdent();

  if (not ErrorFound) then
    if (IsTag(kiPARTITION)) then
    begin
      Nodes.PartitionTag := ParseTag(kiPARTITION);

      if (not ErrorFound) then
        Nodes.Partitions := ParseList(True, ParsePartitionIdent);
    end;

  if (not ErrorFound) then
    if (IsTag(kiAS)) then
    begin
      Nodes.AsTag := ParseTag(kiAS);

      if (not ErrorFound) then
        Nodes.AliasIdent := ParseTableAliasIdent();
    end;

  if (not ErrorFound
    and not EndOfStmt(CurrentToken)
    and (Nodes.AliasIdent = 0)
    and ((TokenPtr(CurrentToken)^.TokenType in [ttString, ttMySQLIdent, ttDQIdent])
      or (TokenPtr(CurrentToken)^.TokenType = ttIdent) and (ReservedWordList.IndexOf(TokenPtr(CurrentToken)^.FText, TokenPtr(CurrentToken)^.FLength) < 0))) then
    Nodes.AliasIdent := ParseTableAliasIdent();

  if (not ErrorFound) then
    if (IsTag(kiUSE)
      or IsTag(kiIGNORE)
      or IsTag(kiFORCE)) then
    begin
      IndexHints.Init();

      Found := True;
      while (not ErrorFound and Found) do
      begin
        Found := IsTag(kiUSE)
          or IsTag(kiIGNORE)
          or IsTag(kiFORCE);
        if (Found) then
        begin
          IndexHints.Add(ParseSelectStmtTableFactorIndexHint);
          if (not ErrorFound) then
          begin
            Found := IsSymbol(ttComma)
              and (IsNextTag(1, kiUSE)
                or IsNextTag(1, kiIGNORE)
                or IsNextTag(1, kiFORCE));
            if (Found) then
              IndexHints.Add(ParseSymbol(ttComma));
          end;
        end;
      end;

      FillChar(ListNodes, SizeOf(ListNodes), 0);
      Nodes.IndexHintList := TList.Create(Self, ListNodes, ttComma, @IndexHints);
    end;

  Result := TSelectStmt.TTableFactor.Create(Self, Nodes);
end;

function TSQLParser.ParseSelectStmtTableEscapedReference(): TOffset;
begin
  if (not IsSymbol(ttOpenCurlyBracket)) then
    Result := ParseSelectStmtTableReference()
  else
    Result := ParseSelectStmtTableFactorOj();
end;

function TSQLParser.ParseSelectStmtTableFactorSubquery(): TOffset;
var
  Nodes: TSelectStmt.TTableFactorSubquery.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.SelectStmt := ParseSelectStmt(True);

  if (not ErrorFound) then
  begin
    if (IsTag(kiAS)) then
      Nodes.AsTag := ParseTag(kiAS);

    if (not ErrorFound) then
      Nodes.AliasIdent := ParseTableAliasIdent();
  end;

  if (not ErrorFound
    and not EndOfStmt(CurrentToken)
    and (Nodes.AliasIdent = 0)
    and ((TokenPtr(CurrentToken)^.TokenType in [ttString, ttMySQLIdent, ttDQIdent])
      or (TokenPtr(CurrentToken)^.TokenType = ttIdent) and (ReservedWordList.IndexOf(TokenPtr(CurrentToken)^.FText, TokenPtr(CurrentToken)^.FLength) < 0))) then
    Nodes.AliasIdent := ParseTableAliasIdent();

  Result := TSelectStmt.TTableFactorSubquery.Create(Self, Nodes);
end;

function TSQLParser.ParseSelectStmtTableFactorIndexHint(): TOffset;
var
  Nodes: TSelectStmt.TTableFactor.TIndexHint.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiUSE, kiINDEX)) then
    Nodes.HintTag := ParseTag(kiUSE, kiINDEX)
  else if (IsTag(kiUSE, kiKEY)) then
    Nodes.HintTag := ParseTag(kiUSE, kiKEY)
  else if (IsTag(kiIGNORE, kiINDEX)) then
    Nodes.HintTag := ParseTag(kiIGNORE, kiINDEX)
  else if (IsTag(kiIGNORE, kiKEY)) then
    Nodes.HintTag := ParseTag(kiIGNORE, kiKEY)
  else if (IsTag(kiFORCE, kiINDEX)) then
    Nodes.HintTag := ParseTag(kiFORCE, kiINDEX)
  else
    Nodes.HintTag := ParseTag(kiFORCE, kiKEY);

  if (not ErrorFound) then
    if (IsTag(kiFOR, kiJOIN)) then
      Nodes.ForTag := ParseTag(kiFOR, kiJOIN)
    else if (IsTag(kiFOR, kiORDER, kiBY)) then
      Nodes.ForTag := ParseTag(kiFOR, kiORDER, kiBY)
    else if (IsTag(kiFOR, kiGROUP, kiBY)) then
      Nodes.ForTag := ParseTag(kiFOR, kiGROUP, kiBY);

  if (not ErrorFound) then
    Nodes.IndexList := ParseList(True, ParseKeyIdent);

  Result := TSelectStmt.TTableFactor.TIndexHint.Create(Self, Nodes);
end;

function TSQLParser.ParseSelectStmtTableFactorOj(): TOffset;
var
  Nodes: TSelectStmt.TTableFactorOj.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.OpenBracket := ParseSymbol(ttOpenCurlyBracket);

  if (not ErrorFound) then
    Nodes.OjTag := ParseTag(kiOJ);

  if (not ErrorFound) then
    Nodes.TableReference := ParseSelectStmtTableReference();

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseCurlyBracket);

  Result := TSelectStmt.TTableFactorOj.Create(Self, Nodes);
end;

function TSQLParser.ParseSelectStmtTableReference(): TOffset;

  function ParseTableFactor(): TOffset;
  var
    BracketDeep: Integer;
    Index: Integer;
  begin
    if (IsSymbol(ttOpenBracket)) then
    begin
      BracketDeep := 0;
      Index := 0;
      repeat
        if (IsNextSymbol(Index, ttOpenBracket)) then
          Inc(BracketDeep)
        else if (IsNextSymbol(Index, ttCloseBracket)) then
          Dec(BracketDeep);
        Inc(Index);
      until (EndOfStmt(NextToken[Index])
        or (BracketDeep = 0));

      if (IsNextTag(1, kiSELECT)
        and (EndOfStmt(NextToken[Index]) or IsNextTag(Index, kiAS) or (TokenPtr(NextToken[Index])^.TokenType in ttIdents) and (ReservedWords.IndexOf(TokenPtr(NextToken[Index])^.AsString) < 0))) then
        Result := ParseSelectStmtTableFactorSubquery()
      else
        Result := ParseList(True, ParseSelectStmtTableReference, ttComma, False);
    end
    else if (IsTag(kiDUAL)) then
      Result := ParseTag(kiDUAL)
    else if (IsTag(kiSELECT)) then
      Result := ParseSelectStmtTableFactorSubquery()
    else if (not EndOfStmt(CurrentToken) and (TokenPtr(CurrentToken)^.TokenType in ttIdents)) then
      Result := ParseSelectStmtTableFactor()
    else if (EndOfStmt(CurrentToken)) then
    begin
      CompletionList.AddList(ditDatabase);
      CompletionList.AddList(ditTable);
      Result := SetError(PE_IncompleteStmt);
    end
    else
      Result := SetError(PE_UnexpectedToken);
  end;

var
  Children: TOffsetList;
  JoinNodes: TSelectStmt.TTableJoin.TNodes;
  JoinType: TJoinType;
  Nodes: TList.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);
  Children.Init();

  Children.Add(ParseTableFactor());

  JoinType := jtInner;
  while (not ErrorFound and (JoinType <> jtUnknown)) do
  begin
    FillChar(JoinNodes, SizeOf(JoinNodes), 0);

    if (IsTag(kiINNER, kiJOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiINNER, kiJOIN);
      JoinType := jtInner
    end
    else if (IsTag(kiCROSS, kiJOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiCROSS, kiJOIN);
      JoinType := jtCross;
    end
    else if (IsTag(kiJOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiJOIN);
      JoinType := jtInner;
    end
    else if (IsTag(kiSTRAIGHT_JOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiSTRAIGHT_JOIN);
      JoinType := jtStraight;
    end
    else if (IsTag(kiLEFT, kiJOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiLEFT, kiJOIN);
      JoinType := jtLeft;
    end
    else if (IsTag(kiLEFT, kiOUTER, kiJOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiLEFT, kiOUTER, kiJOIN);
      JoinType := jtLeft;
    end
    else if (IsTag(kiRIGHT, kiJOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiRIGHT, kiJOIN);
      JoinType := jtRight;
    end
    else if (IsTag(kiRIGHT, kiOUTER, kiJOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiRIGHT, kiOUTER, kiJOIN);
      JoinType := jtRight;
    end
    else if (IsTag(kiNATURAL, kiJOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiNATURAL, kiJOIN);
      JoinType := jtEqui;
    end
    else if (IsTag(kiNATURAL, kiLEFT, kiJOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiNATURAL, kiLEFT, kiJOIN);
      JoinType := jtNaturalLeft;
    end
    else if (IsTag(kiNATURAL, kiLEFT, kiOUTER, kiJOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiNATURAL, kiLEFT, kiOUTER, kiJOIN);
      JoinType := jtNaturalLeft;
    end
    else if (IsTag(kiNATURAL, kiRIGHT, kiJOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiNATURAL, kiRIGHT, kiJOIN);
      JoinType := jtNaturalRight;
    end
    else if (IsTag(kiNATURAL, kiRIGHT, kiOUTER, kiJOIN)) then
    begin
      JoinNodes.JoinTag := ParseTag(kiNATURAL, kiRIGHT, kiOUTER, kiJOIN);
      JoinType := jtNaturalRight;
    end
    else
      JoinType := jtUnknown;

    case (JoinType) of
      jtInner,
      jtCross:
        begin
          JoinNodes.RightTable := ParseTableFactor();

          if (not ErrorFound) then
            if (IsTag(kiON)) then
            begin
              JoinNodes.OnTag := ParseTag(kiON);
              if (not ErrorFound) then
                JoinNodes.OnExpr := ParseExpr();
            end
            else if (IsTag(kiUSING)) then
            begin
              JoinNodes.OnTag := ParseTag(kiUSING);
              if (not ErrorFound) then
                JoinNodes.OnExpr := ParseList(True, ParseFieldIdent);
            end;
        end;
      jtEqui,
      jtNaturalLeft,
      jtNaturalRight:
        begin
          JoinNodes.RightTable := ParseTableFactor();
        end;
      jtStraight:
        begin
          JoinNodes.RightTable := ParseTableFactor();

          if (not ErrorFound) then
            if (IsTag(kiON)) then
            begin
              JoinNodes.OnTag := ParseTag(kiON);
              if (not ErrorFound) then
                JoinNodes.OnExpr := ParseExpr();
            end;
        end;
      jtLeft,
      jtRight:
        begin
          JoinNodes.RightTable := ParseSelectStmtTableReference();

          if (not ErrorFound) then
            if (IsTag(kiON)) then
            begin
              JoinNodes.OnTag := ParseTag(kiON);
              if (not ErrorFound) then
                if (EndOfStmt(CurrentToken)) then
                  SetError(PE_IncompleteStmt)
                else
                  JoinNodes.OnExpr := ParseExpr();
            end
            else if (IsTag(kiUSING)) then
            begin
              JoinNodes.OnTag := ParseTag(kiUSING);

              if (not ErrorFound) then
                JoinNodes.OnExpr := ParseList(True, ParseFieldIdent);
            end
            else if (EndOfStmt(CurrentToken)) then
              SetError(PE_IncompleteStmt)
            else
              SetError(PE_UnexpectedToken);
        end;
    end;

    if (JoinType <> jtUnknown) then
      Children.Add(TSelectStmt.TTableJoin.Create(Self, JoinType, JoinNodes));
  end;

  if (Children.Count = 0) then
    Result := 0
  else
    Result := TList.Create(Self, Nodes, ttUnknown, @Children);
end;

function TSQLParser.ParseSetNamesStmt(): TOffset;
var
  Nodes: TSetNamesStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiSET, kiNAMES)) then
    Nodes.StmtTag := ParseTag(kiSET, kiNAMES)
  else if (IsTag(kiSET, kiCHARACTER, kiSET)) then
    Nodes.StmtTag := ParseTag(kiSET, kiCHARACTER, kiSET)
  else if (IsTag(kiSET, kiCHARSET)) then
    Nodes.StmtTag := ParseTag(kiSET, kiCHARSET)
  else
    SetError(PE_Unknown);

  if (not ErrorFound) then
    Nodes.CharsetValue := ParseCharsetIdent();

  Result := TSetNamesStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseSetPasswordStmt(): TOffset;
var
  Nodes: TSetPasswordStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSET, kiPASSWORD);

  if (not ErrorFound) then
    if (IsTag(kiFOR)) then
      Nodes.ForValue := ParseValue(kiFOR, vaNo, ParseAccountIdent);

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (TokenPtr(CurrentToken)^.OperatorType <> otEqual) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.AssignToken := ApplyCurrentToken(utOperator);

  if (not ErrorFound) then
    Nodes.PasswordExpr := ParseExpr();

  Result := TSetPasswordStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseSetStmt(): TOffset;
var
  Nodes: TSetStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.SetTag := ParseTag(kiSET);

  if (not ErrorFound) then
    if (IsTag(kiGLOBAL)) then
      Nodes.ScopeTag := ParseTag(kiGLOBAL)
    else if (IsTag(kiSESSION)) then
      Nodes.ScopeTag := ParseTag(kiSESSION);

  if (not ErrorFound) then
    Nodes.AssignmentList := ParseList(False, ParseSetStmtAssignment);

  Result := TSetStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseSetStmtAssignment(): TOffset;
var
  Nodes: TSetStmt.TAssignment.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (not ErrorFound) then
    if (Parse.InCreateTriggerStmt
      and (IsTag(kiNEW) or IsTag(kiOLD))) then
      Nodes.VariableIdent := ParseDbIdent(ditField, True)
    else
      Nodes.VariableIdent := ParseVariableIdent();

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (not (TokenPtr(CurrentToken)^.OperatorType in [otEqual, otAssign])) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.AssignToken := ApplyCurrentToken(utOperator);

  if (not ErrorFound) then
    if (not EndOfStmt(CurrentToken)
      and ((StrLIComp(TokenPtr(CurrentToken)^.FText, 'ON', 2) = 0) or (StrLIComp(TokenPtr(CurrentToken)^.FText, 'OFF', 3) = 0))) then
      Nodes.ValueExpr := ParseConstIdent()
    else
      Nodes.ValueExpr := ParseExpr();

  Result := TSetStmt.TAssignment.Create(Self, Nodes);
end;

function TSQLParser.ParseSetTransactionStmt(): TOffset;
var
  Nodes: TSetTransactionStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.SetTag := ParseTag(kiSET);

  if (not ErrorFound) then
    if (IsTag(kiGLOBAL)) then
      Nodes.ScopeTag := ParseTag(kiGLOBAL)
    else if (IsTag(kiSESSION)) then
      Nodes.ScopeTag := ParseTag(kiSESSION);

  if (not ErrorFound) then
    Nodes.TransactionTag := ParseTag(kiTRANSACTION);

  if (not ErrorFound) then
    Nodes.CharacteristicList := ParseList(False, ParseSetTransactionStmtCharacterisic);

  Result := TSetTransactionStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseSetTransactionStmtCharacterisic(): TOffset;
var
  Nodes: TSetTransactionStmt.TCharacteristic.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiISOLATION, kiLEVEL)) then
  begin
    Nodes.KindTag := ParseTag(kiISOLATION, kiLEVEL);

    if (not ErrorFound) then
      if (IsTag(kiREPEATABLE, kiREAD)) then
        Nodes.LevelTag := ParseTag(kiREPEATABLE, kiREAD)
      else if (IsTag(kiREAD, kiCOMMITTED)) then
        Nodes.LevelTag := ParseTag(kiREAD, kiCOMMITTED)
      else if (IsTag(kiREAD, kiUNCOMMITTED)) then
        Nodes.LevelTag := ParseTag(kiREAD, kiUNCOMMITTED)
      else if (IsTag(kiSERIALIZABLE)) then
        Nodes.LevelTag := ParseTag(kiSERIALIZABLE)
      else if (EndOfStmt(CurrentToken)) then
        SetError(PE_IncompleteStmt)
      else
        SetError(PE_UnexpectedToken);
  end
  else if (IsTag(kiREAD, kiWRITE)) then
    Nodes.KindTag := ParseTag(kiREAD, kiWRITE)
  else if (IsTag(kiREAD, kiWRITE)) then
    Nodes.KindTag := ParseTag(kiREAD, kiONLY)
  else if (EndOfStmt(CurrentToken)) then
    SetError(PE_IncompleteStmt)
  else
    SetError(PE_UnexpectedToken);

  Result := TSetTransactionStmt.TCharacteristic.Create(Self, Nodes);
end;

function TSQLParser.ParseShowBinaryLogsStmt(): TOffset;
var
  Nodes: TShowBinaryLogsStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiBINARY, kiLOGS);

  Result := TShowBinaryLogsStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowBinlogEventsStmt(): TOffset;
var
  Nodes: TShowBinlogEventsStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiBINLOG, kiEVENTS);

  if (not ErrorFound) then
    if (IsTag(kiIN)) then
      Nodes.InValue := ParseValue(kiIN, vaNo, ParseString);

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
      Nodes.FromValue := ParseValue(kiFROM, vaNo, ParseInteger);

  if (not ErrorFound) then
    if (IsTag(kiLIMIT)) then
    begin
      Nodes.Limit.Tag := ParseTag(kiLIMIT);

      if (not ErrorFound) then
      begin
        Nodes.Limit.RowCountToken := ParseExpr([]);

        if (not ErrorFound) then
          if (IsSymbol(ttComma)) then
          begin
            Nodes.Limit.CommaToken := ParseSymbol(ttComma);

            if (not ErrorFound) then
            begin
              Nodes.Limit.OffsetToken := Nodes.Limit.RowCountToken;
              Nodes.Limit.RowCountToken := ParseExpr([]);
            end;
          end;
      end;
    end;

  Result := TShowBinlogEventsStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowCharacterSetStmt(): TOffset;
var
  Nodes: TShowCharacterSetStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiCHARACTER, kiSET);

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
      Nodes.LikeValue := ParseValue(kiLIKE, vaNo, ParseString)
    else if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowCharacterSetStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowCollationStmt(): TOffset;
var
  Nodes: TShowCollationStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiCOLLATION);

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
      Nodes.LikeValue := ParseValue(kiLIKE, vaNo, ParseString)
    else if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowCollationStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowColumnsStmt(): TOffset;
var
  Nodes: TShowColumnsStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW);

  if (not ErrorFound) then
    if (IsTag(kiFULL)) then
      Nodes.FullTag := ParseTag(kiFULL);

  if (not ErrorFound) then
    if (IsTag(kiCOLUMNS)) then
      Nodes.ColumnsTag := ParseTag(kiCOLUMNS)
    else
      Nodes.ColumnsTag := ParseTag(kiFIELDS);

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
      Nodes.FromTableTag := ParseTag(kiFROM)
    else
      Nodes.FromTableTag := ParseTag(kiIN);

  if (not ErrorFound) then
    Nodes.TableIdent := ParseTableIdent();

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
      Nodes.FromDatabaseValue := ParseValue(kiFROM, vaNo, ParseDatabaseIdent)
    else if (IsTag(kiIN)) then
      Nodes.FromDatabaseValue := ParseValue(kiFROM, vaNo, ParseDatabaseIdent);

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
      Nodes.LikeValue := ParseValue(kiLIKE, vaNo, ParseString)
    else if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowColumnsStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowCountStmt(): TOffset;
var
  Nodes: TShowCountStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW);

  if (not ErrorFound) then
    Nodes.CountFunc := ParseCountFunc();

  if (not ErrorFound) then
    if (IsTag(kiERRORS)) then
      Nodes.KindTag := ParseTag(kiERRORS)
    else
      Nodes.KindTag := ParseTag(kiWARNINGS);

  Result := TShowCountStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowCreateDatabaseStmt(): TOffset;
var
  Nodes: TShowCreateDatabaseStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiSCHEMA)) then
    Nodes.StmtTag := ParseTag(kiSHOW, kiCREATE, kiSCHEMA)
  else
    Nodes.StmtTag := ParseTag(kiSHOW, kiCREATE, kiDATABASE);

  if (not ErrorFound) then
    if (IsTag(kiIF, kiNOT, kiEXISTS)) then
      Nodes.IfNotExistsTag := ParseTag(kiIF, kiNOT, kiEXISTS);

  if (not ErrorFound) then
    Nodes.Ident := ParseDatabaseIdent();

  Result := TShowCreateDatabaseStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowCreateEventStmt(): TOffset;
var
  Nodes: TShowCreateEventStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiCREATE, kiEVENT);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent(ditEvent);

  Result := TShowCreateEventStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowCreateFunctionStmt(): TOffset;
var
  Nodes: TShowCreateFunctionStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiCREATE, kiFUNCTION);

  if (not ErrorFound) then
    Nodes.Ident := ParseFunctionIdent();

  Result := TShowCreateFunctionStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowCreateProcedureStmt(): TOffset;
var
  Nodes: TShowCreateProcedureStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiCREATE, kiPROCEDURE);

  if (not ErrorFound) then
    Nodes.Ident := ParseProcedureIdent();

  Result := TShowCreateProcedureStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowCreateTableStmt(): TOffset;
var
  Nodes: TShowCreateTableStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiCREATE, kiTABLE);

  if (not ErrorFound) then
    Nodes.Ident := ParseTableIdent();

  Result := TShowCreateTableStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowCreateTriggerStmt(): TOffset;
var
  Nodes: TShowCreateTriggerStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiCREATE, kiTRIGGER);

  if (not ErrorFound) then
    Nodes.Ident := ParseTriggerIdent();

  Result := TShowCreateTriggerStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowCreateUserStmt(): TOffset;
var
  Nodes: TShowCreateUserStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiCREATE, kiUSER);

  if (not ErrorFound) then
    Nodes.User := ParseAccountIdent();

  Result := TShowCreateUserStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowCreateViewStmt(): TOffset;
var
  Nodes: TShowCreateViewStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiCREATE, kiVIEW);

  if (not ErrorFound) then
    Nodes.Ident := ParseTableIdent();

  Result := TShowCreateViewStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowDatabasesStmt(): TOffset;
var
  Nodes: TShowDatabasesStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiSHOW, kiDATABASES)) then
    Nodes.StmtTag := ParseTag(kiSHOW, kiDATABASES)
  else
    Nodes.StmtTag := ParseTag(kiSHOW, kiSCHEMA);

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
      Nodes.LikeValue := ParseValue(kiLIKE, vaNo, ParseString)
    else if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowDatabasesStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowEngineStmt(): TOffset;
var
  Nodes: TShowEngineStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiENGINE);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent();

  if (not ErrorFound) then
    if (IsTag(kiSTATUS)) then
      Nodes.KindTag := ParseTag(kiSTATUS)
    else if (IsTag(kiMUTEX)) then
      Nodes.KindTag := ParseTag(kiMUTEX)
    else if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  Result := TShowEngineStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowEnginesStmt(): TOffset;
var
  Nodes: TShowEnginesStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiSHOW, kiSTORAGE, kiENGINES)) then
    Nodes.StmtTag := ParseTag(kiSHOW, kiSTORAGE, kiENGINES)
  else
    Nodes.StmtTag := ParseTag(kiSHOW, kiENGINES);

  Result := TShowEnginesStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowErrorsStmt(): TOffset;
var
  Nodes: TShowErrorsStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiERRORS);

  if (not ErrorFound) then
    if (IsTag(kiLIMIT)) then
    begin
      Nodes.Limit.Tag := ParseTag(kiLIMIT);

      if (not ErrorFound) then
      begin
        Nodes.Limit.RowCountToken := ParseExpr([]);

        if (not ErrorFound) then
          if (IsSymbol(ttComma)) then
          begin
            Nodes.Limit.CommaToken := ParseSymbol(ttComma);

            if (not ErrorFound) then
            begin
              Nodes.Limit.OffsetToken := Nodes.Limit.RowCountToken;
              Nodes.Limit.RowCountToken := ParseExpr([]);
            end;
          end;
      end;
    end;

  Result := TShowErrorsStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowEventsStmt(): TOffset;
var
  Nodes: TShowEventsStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiEVENTS);

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
      Nodes.FromValue := ParseValue(kiFROM, vaNo, ParseDatabaseIdent)
    else if (IsTag(kiIN)) then
      Nodes.FromValue := ParseValue(kiIN, vaNo, ParseDatabaseIdent);

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
      Nodes.LikeValue := ParseValue(kiLIKE, vaNo, ParseString)
    else if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowEventsStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowFunctionStatusStmt(): TOffset;
var
  Nodes: TShowFunctionStatusStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiFUNCTION, kiSTATUS);

  Result := TShowFunctionStatusStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowGrantsStmt(): TOffset;
var
  Nodes: TShowGrantsStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiGRANTS);

  if (not ErrorFound) then
    if (IsTag(kiFOR)) then
      Nodes.ForValue := ParseValue(kiFOR, vaNo, ParseAccountIdent);

  Result := TShowGrantsStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowIndexStmt(): TOffset;
var
  Nodes: TShowIndexStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiSHOW, kiINDEX)) then
    Nodes.StmtTag := ParseTag(kiSHOW, kiINDEX)
  else if (IsTag(kiSHOW, kiINDEXES)) then
    Nodes.StmtTag := ParseTag(kiSHOW, kiINDEXES)
  else
    Nodes.StmtTag := ParseTag(kiSHOW, kiKEYS);

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
      Nodes.FromTableValue := ParseValue(kiFROM, vaNo, ParseTableIdent)
    else
      Nodes.FromTableValue := ParseValue(kiIN, vaNo, ParseTableIdent);

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
      Nodes.FromDatabaseValue := ParseValue(kiFROM, vaNo, ParseDatabaseIdent)
    else if (IsTag(kiIN)) then
      Nodes.FromDatabaseValue := ParseValue(kiIN, vaNo, ParseDatabaseIdent);

  if (not ErrorFound) then
    if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowIndexStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowMasterStatusStmt(): TOffset;
var
  Nodes: TShowMasterStatusStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiMASTER, kiSTATUS);

  Result := TShowMasterStatusStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowOpenTablesStmt(): TOffset;
var
  Nodes: TShowOpenTablesStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiOPEN, kiTABLES);

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
      Nodes.FromDatabaseValue := ParseValue(kiFROM, vaNo, ParseDatabaseIdent)
    else if (IsTag(kiIN)) then
      Nodes.FromDatabaseValue := ParseValue(kiIN, vaNo, ParseDatabaseIdent);

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
      Nodes.LikeValue := ParseValue(kiLIKE, vaNo, ParseString)
    else if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowOpenTablesStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowPluginsStmt(): TOffset;
var
  Nodes: TShowPluginsStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiPLUGINS);

  Result := TShowPluginsStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowPrivilegesStmt(): TOffset;
var
  Nodes: TShowPrivilegesStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiPRIVILEGES);

  Result := TShowPrivilegesStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowProcedureStatusStmt(): TOffset;
var
  Nodes: TShowProcedureStatusStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiPROCEDURE, kiSTATUS);

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
      Nodes.LikeValue := ParseValue(kiLIKE, vaNo, ParseString)
    else if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowProcedureStatusStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowProcessListStmt(): TOffset;
var
  Nodes: TShowProcessListStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiSHOW, kiFULL, kiPROCESSLIST)) then
    Nodes.StmtTag := ParseTag(kiSHOW, kiFULL, kiPROCESSLIST)
  else
    Nodes.StmtTag := ParseTag(kiSHOW, kiPROCESSLIST);

  Result := TShowProcessListStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowProfileStmt(): TOffset;
var
  Nodes: TShowProfileStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiPROFILE);

  if (not ErrorFound) then
    Nodes.TypeList := ParseList(False, ParseShowProfileStmtType);

  if (not ErrorFound) then
    if (IsTag(kiFOR, kiQUERY)) then
      Nodes.ForQueryValue := ParseValue(WordIndices(kiFOR, kiQUERY), vaNo, ParseInteger);

  if (not ErrorFound) then
    if (IsTag(kiLIMIT)) then
    begin
      Nodes.Limit.Tag := ParseTag(kiLIMIT);

      if (not ErrorFound) then
        Nodes.Limit.Token := ParseExpr([]);

      if (not ErrorFound) then
        if (IsTag(kiOFFSET)) then
        begin
          Nodes.Limit.OffsetTag := ParseTag(kiOFFSET);

          if (not ErrorFound) then
            Nodes.Limit.OffsetToken := ParseExpr([]);
        end;
    end;

  Result := TShowProfileStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowProfilesStmt(): TOffset;
var
  Nodes: TShowProfilesStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiPROFILES);

  Result := TShowProfilesStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowProfileStmtType(): TOffset;
begin
  if (IsTag(kiALL)) then
    Result := ParseTag(kiALL)
  else if (IsTag(kiBLOCK, kiIO)) then
    Result := ParseTag(kiBLOCK, kiIO)
  else if (IsTag(kiCONTEXT, kiSWITCHES)) then
    Result := ParseTag(kiCONTEXT, kiSWITCHES)
  else if (IsTag(kiCPU)) then
    Result := ParseTag(kiCPU)
  else if (IsTag(kiIPC)) then
    Result := ParseTag(kiIPC)
  else if (IsTag(kiMEMORY)) then
    Result := ParseTag(kiMEMORY)
  else if (IsTag(kiPAGE, kiFAULTS)) then
    Result := ParseTag(kiPAGE, kiFAULTS)
  else if (IsTag(kiSOURCE)) then
    Result := ParseTag(kiSOURCE)
  else if (IsTag(kiSWAPS)) then
    Result := ParseTag(kiSWAPS)
  else if (EndOfStmt(CurrentToken)) then
    Result := SetError(PE_IncompleteStmt)
  else
    Result := SetError(PE_UnexpectedToken);
end;

function TSQLParser.ParseShowRelaylogEventsStmt(): TOffset;
var
  Nodes: TShowRelaylogEventsStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiRELAYLOG, kiEVENTS);

  if (not ErrorFound) then
    if (IsTag(kiIN)) then
      Nodes.InValue := ParseValue(kiIN, vaNo, ParseString);

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
      Nodes.InValue := ParseValue(kiFROM, vaNo, ParseInteger);

  if (not ErrorFound) then
    if (IsTag(kiLIMIT)) then
    begin
      Nodes.Limit.Tag := ParseTag(kiLIMIT);

      if (not ErrorFound) then
      begin
        Nodes.Limit.RowCountToken := ParseExpr([]);

        if (not ErrorFound) then
          if (IsSymbol(ttComma)) then
          begin
            Nodes.Limit.CommaToken := ParseSymbol(ttComma);

            if (not ErrorFound) then
            begin
              Nodes.Limit.OffsetToken := Nodes.Limit.RowCountToken;
              Nodes.Limit.RowCountToken := ParseExpr([]);
            end;
          end;
      end;
    end;

  Result := TShowRelaylogEventsStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowRoutineCodeStmt(): TOffset;
var
  Nodes: TShowRoutineCodeStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiSHOW, kiFUNCTION, kiCODE)) then
  begin
    Nodes.StmtTag := ParseTag(kiSHOW, kiFUNCTION, kiCODE);

    if (not ErrorFound) then
      Nodes.Ident := ParseFunctionIdent();
  end
  else
  begin
    Nodes.StmtTag := ParseTag(kiSHOW, kiPROCEDURE, kiCODE);

    if (not ErrorFound) then
      Nodes.Ident := ParseProcedureIdent();
  end;

  Result := TShowRoutineCodeStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowSlaveHostsStmt(): TOffset;
var
  Nodes: TShowSlaveHostsStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiSLAVE, kiHOSTS);

  Result := TShowSlaveHostsStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowSlaveStatusStmt(): TOffset;
var
  Nodes: TShowSlaveStatusStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiSLAVE, kiSTATUS);

  Result := TShowSlaveStatusStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowStatusStmt(): TOffset;
var
  Nodes: TShowStatusStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.ShowTag := ParseTag(kiSHOW);

  if (not ErrorFound) then
    if (IsTag(kiGLOBAL)) then
      Nodes.ScopeTag := ParseTag(kiGLOBAL)
    else if (IsTag(kiSESSION)) then
      Nodes.ScopeTag := ParseTag(kiSESSION);

  if (not ErrorFound) then
    Nodes.StatusTag := ParseTag(kiSTATUS);

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
      Nodes.LikeValue := ParseValue(kiLIKE, vaNo, ParseString)
    else if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowStatusStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowTableStatusStmt(): TOffset;
var
  Nodes: TShowTableStatusStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.ShowTag := ParseTag(kiSHOW, kiTABLE, kiSTATUS);

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
      Nodes.FromDatabaseValue := ParseValue(kiFROM, vaNo, ParseDatabaseIdent)
    else if (IsTag(kiIN)) then
      Nodes.FromDatabaseValue := ParseValue(kiIN, vaNo, ParseDatabaseIdent);

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
      Nodes.LikeValue := ParseValue(kiLIKE, vaNo, ParseString)
    else if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowTableStatusStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowTablesStmt(): TOffset;
var
  Nodes: TShowTablesStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.ShowTag := ParseTag(kiSHOW);

  if (not ErrorFound) then
    if (IsTag(kiFULL)) then
      Nodes.FullTag := ParseTag(kiFULL);

  if (not ErrorFound) then
    Nodes.TablesTag := ParseTag(kiTABLES);

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
      Nodes.FromDatabaseValue := ParseValue(kiFROM, vaNo, ParseDatabaseIdent)
    else if (IsTag(kiIN)) then
      Nodes.FromDatabaseValue := ParseValue(kiIN, vaNo, ParseDatabaseIdent);

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
      Nodes.LikeValue := ParseValue(kiLIKE, vaNo, ParseString)
    else if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowTablesStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowTriggersStmt(): TOffset;
var
  Nodes: TShowTriggersStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiTRIGGERS);

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
      Nodes.FromDatabaseValue := ParseValue(kiFROM, vaNo, ParseDatabaseIdent)
    else if (IsTag(kiIN)) then
      Nodes.FromDatabaseValue := ParseValue(kiIN, vaNo, ParseDatabaseIdent);

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
      Nodes.LikeValue := ParseValue(kiLIKE, vaNo, ParseString)
    else if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowTriggersStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowVariablesStmt(): TOffset;
var
  Nodes: TShowVariablesStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.ShowTag := ParseTag(kiSHOW);

  if (not ErrorFound) then
    if (IsTag(kiGLOBAL)) then
      Nodes.ScopeTag := ParseTag(kiGLOBAL)
    else if (IsTag(kiSESSION)) then
      Nodes.ScopeTag := ParseTag(kiSESSION);

  if (not ErrorFound) then
    Nodes.VariablesTag := ParseTag(kiVARIABLES);

  if (not ErrorFound) then
    if (IsTag(kiLIKE)) then
      Nodes.LikeValue := ParseValue(kiLIKE, vaNo, ParseString)
    else if (IsTag(kiWHERE)) then
      Nodes.WhereValue := ParseValue(kiWHERE, vaNo, ParseExpr);

  Result := TShowVariablesStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShowWarningsStmt(): TOffset;
var
  Nodes: TShowWarningsStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHOW, kiWARNINGS);

  if (not ErrorFound) then
    if (IsTag(kiLIMIT)) then
    begin
      Nodes.Limit.Tag := ParseTag(kiLIMIT);

      if (not ErrorFound) then
      begin
        Nodes.Limit.RowCountToken := ParseExpr([]);

        if (not ErrorFound) then
          if (IsSymbol(ttComma)) then
          begin
            Nodes.Limit.CommaToken := ParseSymbol(ttComma);

            if (not ErrorFound) then
            begin
              Nodes.Limit.OffsetToken := Nodes.Limit.RowCountToken;
              Nodes.Limit.RowCountToken := ParseExpr([]);
            end;
          end;
      end;
    end;

  Result := TShowWarningsStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseShutdownStmt(): TOffset;
var
  Nodes: TShutdownStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSHUTDOWN);

  Result := TShutdownStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseSignalStmt(): TOffset;
var
  Nodes: TSignalStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiSIGNAL)) then
  begin
    Nodes.StmtTag := ParseTag(kiSIGNAL);

    if (not ErrorFound) then
      if (IsTag(kiSQLSTATE, kiVALUE)) then
        Nodes.Condition := ParseValue(WordIndices(kiSQLSTATE, kiVALUE), vaNo, ParseExpr)
      else if (IsTag(kiSQLSTATE)) then
        Nodes.Condition := ParseValue(kiSQLSTATE, vaNo, ParseString)
      else
        Nodes.Condition := ParseDbIdent(ditCondition, False);
  end
  else
  begin
    Nodes.StmtTag := ParseTag(kiRESIGNAL);

    if (not ErrorFound) then
      if (IsTag(kiSQLSTATE, kiVALUE)) then
        Nodes.Condition := ParseValue(WordIndices(kiSQLSTATE, kiVALUE), vaYes, ParseExpr)
      else if (IsTag(kiSQLSTATE)) then
        Nodes.Condition := ParseValue(kiSQLSTATE, vaNo, ParseString)
      else if (not EndOfStmt(CurrentToken)) then
        Nodes.Condition := ParseDbIdent(ditCondition, False);
  end;

  if (not ErrorFound) then
    if (IsTag(kiSET)) then
    begin
      Nodes.SetTag := ParseTag(kiSET);

      if (not ErrorFound and not EndOfStmt(CurrentToken)) then
        Nodes.InformationList := ParseList(False, ParseSignalStmtInformation);
    end;

  Result := TSignalStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseSignalStmtInformation(): TOffset;
var
  Nodes: TSignalStmt.TInformation.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiCLASS_ORIGIN)) then
    Nodes.Value := ParseValue(kiCLASS_ORIGIN, vaYes, ParseExpr)
  else if (IsTag(kiSUBCLASS_ORIGIN)) then
    Nodes.Value := ParseValue(kiSUBCLASS_ORIGIN, vaYes, ParseExpr)
  else if (IsTag(kiMESSAGE_TEXT)) then
    Nodes.Value := ParseValue(kiMESSAGE_TEXT, vaYes, ParseExpr)
  else if (IsTag(kiMYSQL_ERRNO)) then
    Nodes.Value := ParseValue(kiMYSQL_ERRNO, vaYes, ParseExpr)
  else if (IsTag(kiCONSTRAINT_CATALOG)) then
    Nodes.Value := ParseValue(kiCONSTRAINT_CATALOG, vaYes, ParseExpr)
  else if (IsTag(kiCONSTRAINT_SCHEMA)) then
    Nodes.Value := ParseValue(kiCONSTRAINT_SCHEMA, vaYes, ParseExpr)
  else if (IsTag(kiCONSTRAINT_NAME)) then
    Nodes.Value := ParseValue(kiCONSTRAINT_NAME, vaYes, ParseExpr)
  else if (IsTag(kiCATALOG_NAME)) then
    Nodes.Value := ParseValue(kiCATALOG_NAME, vaYes, ParseExpr)
  else if (IsTag(kiSCHEMA_NAME)) then
    Nodes.Value := ParseValue(kiSCHEMA_NAME, vaYes, ParseExpr)
  else if (IsTag(kiTABLE_NAME)) then
    Nodes.Value := ParseValue(kiTABLE_NAME, vaYes, ParseExpr)
  else if (IsTag(kiCOLUMN_NAME)) then
    Nodes.Value := ParseValue(kiCOLUMN_NAME, vaYes, ParseExpr)
  else
    Nodes.Value := ParseValue(kiCURSOR_NAME, vaYes, ParseExpr);

  Result := TSignalStmt.TInformation.Create(Self, Nodes);
end;

function TSQLParser.ParseSQL(const SQL: PChar; const Length: Integer; const UseCompletionList: Boolean = False): Boolean;
begin
  Clear();

  SetString(Parse.SQL, SQL, Length);
  CompletionList.SetActive(UseCompletionList);

  try
    FRoot := ParseRoot();
  except
    on E: Exception do
      raise Exception.Create(E.Message + #13#10
        + ' SQL: ' + StrPas(SQL));
  end;

  Result := (FirstError.Code = PE_Success);
end;

function TSQLParser.ParseSQL(const Text: string; const AUseCompletionList: Boolean = False): Boolean;
begin
  Result := ParseSQL(PChar(Text), Length(Text), AUseCompletionList);
end;

function TSQLParser.ParseStartSlaveStmt(): TOffset;
var
  Nodes: TStartSlaveStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSTART, kiSLAVE);

  Result := TStartSlaveStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseStartTransactionStmt(): TOffset;
var
  Found: Boolean;
  Nodes: TStartTransactionStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSTART, kiTRANSACTION);

  Found := True;
  while (not ErrorFound and Found) do
    if ((Nodes.WithConsistentSnapshotTag = 0) and IsTag(kiWITH, kiCONSISTENT, kiSNAPSHOT)) then
      Nodes.WithConsistentSnapshotTag := ParseTag(kiWITH, kiCONSISTENT, kiSNAPSHOT)
    else if ((Nodes.ReadWriteTag = 0) and IsTag(kiREAD, kiWRITE)) then
      Nodes.RealOnlyTag := ParseTag(kiREAD, kiWRITE)
    else if ((Nodes.RealOnlyTag = 0) and IsTag(kiREAD, kiONLY)) then
      Nodes.RealOnlyTag := ParseTag(kiREAD, kiONLY)
    else
      Found := False;

  Result := TStartTransactionStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseStopSlaveStmt(): TOffset;
var
  Nodes: TStopSlaveStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiSTOP, kiSLAVE);

  Result := TStopSlaveStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseStmt(): TOffset;
var
  BeginLabel: TOffset;
  Continue: Boolean;
  FirstToken: TOffset;
  T: TOffset;
  Token: PToken;
begin
  {$IFDEF Debug}
  Continue := False;
  Result := 0;
  {$ENDIF}

  FirstToken := CurrentToken;

  if (InPL_SQL and not EndOfStmt(CurrentToken) and (TokenPtr(CurrentToken)^.TokenType = ttIdent) and IsNextSymbol(1, ttColon)) then
  begin
    BeginLabel := ParseBeginLabel();
    if (IsTag(kiBEGIN)) then
      Result := ParseCompoundStmt(BeginLabel)
    else if (IsTag(kiLOOP)) then
      Result := ParseLoopStmt(BeginLabel)
    else if (IsTag(kiREPEAT)) then
      Result := ParseRepeatStmt(BeginLabel)
    else if (IsTag(kiWHILE)) then
      Result := ParseWhileStmt(BeginLabel)
    else
      Result := SetError(PE_UnexpectedToken)
  end
  else if (IsTag(kiALTER)) then
    Result := ParseAlterStmt()
  else if (IsTag(kiANALYZE, kiTABLE)) then
    Result := ParseAnalyzeTableStmt()
  else if (IsTag(kiBEGIN)) then
    if (not InPL_SQL) then
      Result := ParseBeginStmt()
    else
      Result := ParseCompoundStmt()
  else if (IsTag(kiCALL)) then
    Result := ParseCallStmt()
  else if (IsTag(kiCASE)) then
    if (not InPL_SQL) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseCaseStmt()
  else if (IsTag(kiCHANGE)) then
    Result := ParseChangeMasterStmt()
  else if (IsTag(kiCHECK, kiTABLE)) then
    Result := ParseCheckTableStmt()
  else if (IsTag(kiCHECKSUM, kiTABLE)) then
    Result := ParseChecksumTableStmt()
  else if (IsTag(kiCLOSE)) then
    if (not InPL_SQL) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseCloseStmt()
  else if (IsTag(kiCOMMIT)) then
    Result := ParseCommitStmt()
  else if (IsTag(kiCREATE)) then
    Result := ParseCreateStmt()
  else if (IsTag(kiDEALLOCATE)) then
    Result := ParseDeallocatePrepareStmt()
  else if (IsTag(kiDECLARE)) then
    if (not InCompound) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseDeclareStmt()
  else if (IsTag(kiDELETE)) then
    Result := ParseDeleteStmt()
  else if (IsTag(kiDESC)) then
    Result := ParseExplainStmt()
  else if (IsTag(kiDESCRIBE)) then
    Result := ParseExplainStmt()
  else if (IsTag(kiDO)) then
    Result := ParseDoStmt()
  else if (IsTag(kiDROP, kiDATABASE)) then
    Result := ParseDropDatabaseStmt()
  else if (IsTag(kiDROP, kiEVENT)) then
    Result := ParseDropEventStmt()
  else if (IsTag(kiDROP, kiFUNCTION)) then
    Result := ParseDropRoutineStmt(rtFunction)
  else if (IsTag(kiDROP, kiINDEX)) then
    Result := ParseDropIndexStmt()
  else if (IsTag(kiDROP, kiPREPARE)) then
    Result := ParseDeallocatePrepareStmt()
  else if (IsTag(kiDROP, kiPROCEDURE)) then
    Result := ParseDropRoutineStmt(rtProcedure)
  else if (IsTag(kiDROP, kiSCHEMA)) then
    Result := ParseDropDatabaseStmt()
  else if (IsTag(kiDROP, kiSERVER)) then
    Result := ParseDropServerStmt()
  else if (IsTag(kiDROP, kiTEMPORARY, kiTABLE)
    or IsTag(kiDROP, kiTABLE)) then
    Result := ParseDropTableStmt()
  else if (IsTag(kiDROP, kiTABLESPACE)) then
    Result := ParseDropTablespaceStmt()
  else if (IsTag(kiDROP, kiTRIGGER)) then
    Result := ParseDropTriggerStmt()
  else if (IsTag(kiDROP, kiUSER)) then
    Result := ParseDropUserStmt()
  else if (IsTag(kiDROP, kiVIEW)) then
    Result := ParseDropViewStmt()
  else if (IsTag(kiEXECUTE)) then
    Result := ParseExecuteStmt()
  else if (IsTag(kiEXPLAIN)) then
    Result := ParseExplainStmt()
  else if (IsTag(kiFETCH)) then
    if (not InPL_SQL) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseFetchStmt()
  else if (IsTag(kiFLUSH)) then
    Result := ParseFlushStmt()
  else if (IsTag(kiGET, kiCURRENT, kiDIAGNOSTICS)
    or IsTag(kiGET, kiSTACKED, kiDIAGNOSTICS)
    or IsTag(kiGET, kiDIAGNOSTICS)) then
    Result := ParseGetDiagnosticsStmt()
  else if (IsTag(kiGRANT)) then
    Result := ParseGrantStmt()
  else if (IsTag(kiHELP)) then
    Result := ParseHelpStmt()
  else if (IsTag(kiIF)) then
    if (not InPL_SQL) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseIfStmt()
  else if (IsTag(kiINSERT)) then
    Result := ParseInsertStmt()
  else if (IsTag(kiINSTALL, kiPLUGIN)) then
    Result := ParseInstallPluginStmt()
  else if (IsTag(kiITERATE)) then
    if (not InPL_SQL) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseIterateStmt()
  else if (IsTag(kiKILL)) then
    Result := ParseKillStmt()
  else if (IsTag(kiLEAVE)) then
    if (not InPL_SQL) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseLeaveStmt()
  else if (IsTag(kiLOAD)) then
    Result := ParseLoadStmt()
  else if (IsTag(kiLOCK, kiTABLES)) then
    Result := ParseLockTableStmt()
  else if (IsTag(kiLOOP)) then
    if (not InPL_SQL) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseLoopStmt()
  else if (IsTag(kiPREPARE)) then
    Result := ParsePrepareStmt()
  else if (IsTag(kiPURGE)) then
    Result := ParsePurgeStmt()
  else if (IsTag(kiOPEN)) then
    if (not InPL_SQL) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseOpenStmt()
  else if (IsTag(kiOPTIMIZE, kiNO_WRITE_TO_BINLOG, kiTABLE)
    or IsTag(kiOPTIMIZE, kiLOCAL, kiTABLE)
    or IsTag(kiOPTIMIZE, kiTABLE)) then
    Result := ParseOptimizeTableStmt()
  else if (IsTag(kiRENAME)) then
    Result := ParseRenameStmt()
  else if (IsTag(kiREPAIR, kiTABLE)) then
    Result := ParseRepairTableStmt()
  else if (IsTag(kiRELEASE)) then
    Result := ParseReleaseStmt()
  else if (IsTag(kiREPEAT)) then
    if (not InPL_SQL) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseRepeatStmt()
  else if (IsTag(kiREPLACE)) then
    Result := ParseInsertStmt()
  else if (IsTag(kiRESET)) then
    Result := ParseResetStmt()
  else if (IsTag(kiRESIGNAL)) then
    Result := ParseSignalStmt()
  else if (IsTag(kiRETURN)) then
    if (not InPL_SQL
      or not Parse.InCreateFunctionStmt) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseReturnStmt()
  else if (IsTag(kiREVOKE)) then
    Result := ParseRevokeStmt()
  else if (IsTag(kiROLLBACK)) then
    Result := ParseRollbackStmt()
  else if (IsTag(kiSAVEPOINT)) then
    Result := ParseSavepointStmt()
  else if (IsSelectStmt()) then
    Result := ParseSelectStmt(False)
  else if (IsTag(kiSET, kiNAMES)) then
    Result := ParseSetNamesStmt()
  else if (IsTag(kiSET, kiCHARACTER)
    or IsTag(kiSET, kiCHARSET)) then
    Result := ParseSetNamesStmt()
  else if (IsTag(kiSET, kiPASSWORD)) then
    Result := ParseSetPasswordStmt()
  else if (IsTag(kiSET, kiGLOBAL, kiTRANSACTION)
    or IsTag(kiSET, kiSESSION, kiTRANSACTION)
    or IsTag(kiSET, kiTRANSACTION)) then
    Result := ParseSetTransactionStmt()
  else if (IsTag(kiSET)) then
    Result := ParseSetStmt()
  {$IFDEF Debug}
  else
    Continue := True;     // This "Hack" is needed to use <Ctrl+LeftClick>
  if (not Continue) then  // the Delphi XE4 IDE. But why???
  {$ENDIF}
  else if (IsTag(kiSHOW, kiBINARY, kiLOGS)) then
    Result := ParseShowBinaryLogsStmt()
  else if (IsTag(kiSHOW, kiMASTER, kiLOGS)) then
    Result := ParseShowBinaryLogsStmt()
  else if (IsTag(kiSHOW, kiBINLOG, kiEVENTS)) then
    Result := ParseShowBinlogEventsStmt()
  else if (IsTag(kiSHOW, kiCHARACTER, kiSET)) then
    Result := ParseShowCharacterSetStmt()
  else if (IsTag(kiSHOW, kiCOLLATION)) then
    Result := ParseShowCollationStmt()
  else if (IsTag(kiSHOW, kiCOLUMNS)) then
    Result := ParseShowColumnsStmt()
  else if (IsTag(kiSHOW) and not EndOfStmt(NextToken[1]) and (StrLIComp(PChar(TokenPtr(NextToken[1])^.Text), 'COUNT', 5) = 0)) then
    Result := ParseShowCountStmt()
  else if (IsTag(kiSHOW, kiFIELDS)) then
    Result := ParseShowColumnsStmt()
  else if (IsTag(kiSHOW, kiCREATE, kiDATABASE)) then
    Result := ParseShowCreateDatabaseStmt()
  else if (IsTag(kiSHOW, kiCREATE, kiEVENT)) then
    Result := ParseShowCreateEventStmt()
  else if (IsTag(kiSHOW, kiCREATE, kiFUNCTION)) then
    Result := ParseShowCreateFunctionStmt()
  else if (IsTag(kiSHOW, kiCREATE, kiPROCEDURE)) then
    Result := ParseShowCreateProcedureStmt()
  else if (IsTag(kiSHOW, kiCREATE, kiSCHEMA)) then
    Result := ParseShowCreateDatabaseStmt()
  else if (IsTag(kiSHOW, kiCREATE, kiPROCEDURE)) then
    Result := ParseShowCreateProcedureStmt()
  else if (IsTag(kiSHOW, kiCREATE, kiTABLE)) then
    Result := ParseShowCreateTableStmt()
  else if (IsTag(kiSHOW, kiCREATE, kiTRIGGER)) then
    Result := ParseShowCreateTriggerStmt()
  else if (IsTag(kiSHOW, kiCREATE, kiUSER)) then
    Result := ParseShowCreateUserStmt()
  else if (IsTag(kiSHOW, kiCREATE, kiVIEW)) then
    Result := ParseShowCreateViewStmt()
  else if (IsTag(kiSHOW, kiDATABASES)) then
    Result := ParseShowDatabasesStmt()
  else if (IsTag(kiSHOW, kiENGINE)) then
    Result := ParseShowEngineStmt()
  else if (IsTag(kiSHOW, kiENGINES)) then
    Result := ParseShowEnginesStmt()
  else if (IsTag(kiSHOW, kiERRORS)) then
    Result := ParseShowErrorsStmt()
  else if (IsTag(kiSHOW, kiEVENTS)) then
    Result := ParseShowEventsStmt()
  else if (IsTag(kiSHOW, kiFULL, kiCOLUMNS)) then
    Result := ParseShowColumnsStmt()
  else if (IsTag(kiSHOW, kiFULL, kiFIELDS)) then
    Result := ParseShowColumnsStmt()
  else if (IsTag(kiSHOW, kiFULL, kiTABLES)) then
    Result := ParseShowTablesStmt()
  else if (IsTag(kiSHOW, kiFULL, kiPROCESSLIST)) then
    Result := ParseShowProcessListStmt()
  else if (IsTag(kiSHOW, kiFUNCTION, kiCODE)) then
    Result := ParseShowRoutineCodeStmt()
  else if (IsTag(kiSHOW, kiFUNCTION, kiSTATUS)) then
    Result := ParseShowFunctionStatusStmt()
  else if (IsTag(kiSHOW, kiGRANTS)) then
    Result := ParseShowGrantsStmt()
  else if (IsTag(kiSHOW, kiINDEX)) then
    Result := ParseShowIndexStmt()
  else if (IsTag(kiSHOW, kiINDEXES)) then
    Result := ParseShowIndexStmt()
  else if (IsTag(kiSHOW, kiKEYS)) then
    Result := ParseShowIndexStmt()
  else if (IsTag(kiSHOW, kiMASTER, kiSTATUS)) then
    Result := ParseShowMasterStatusStmt()
  else if (IsTag(kiSHOW, kiOPEN, kiTABLES)) then
    Result := ParseShowOpenTablesStmt()
  else if (IsTag(kiSHOW, kiPLUGINS)) then
    Result := ParseShowPluginsStmt()
  else if (IsTag(kiSHOW, kiPRIVILEGES)) then
    Result := ParseShowPrivilegesStmt()
  else if (IsTag(kiSHOW, kiPROCEDURE, kiCODE)) then
    Result := ParseShowRoutineCodeStmt()
  else if (IsTag(kiSHOW, kiPROCEDURE, kiSTATUS)) then
    Result := ParseShowProcedureStatusStmt()
  else if (IsTag(kiSHOW, kiPROCESSLIST)) then
    Result := ParseShowProcessListStmt()
  else if (IsTag(kiSHOW, kiPROFILE)) then
    Result := ParseShowProfileStmt()
  else if (IsTag(kiSHOW, kiPROFILES)) then
    Result := ParseShowProfilesStmt()
  else if (IsTag(kiSHOW, kiRELAYLOG, kiEVENTS)) then
    Result := ParseShowRelaylogEventsStmt()
  else if (IsTag(kiSHOW, kiSCHEMA)) then
    Result := ParseShowDatabasesStmt()
  else if (IsTag(kiSHOW, kiSLAVE, kiHOSTS)) then
    Result := ParseShowSlaveHostsStmt()
  else if (IsTag(kiSHOW, kiSLAVE, kiSTATUS)) then
    Result := ParseShowSlaveStatusStmt()
  else if (IsTag(kiSHOW, kiGLOBAL, kiSTATUS)
    or IsTag(kiSHOW, kiSESSION, kiSTATUS)
    or IsTag(kiSHOW, kiSTATUS)) then
    Result := ParseShowStatusStmt()
  else if (IsTag(kiSHOW, kiTABLE, kiSTATUS)) then
    Result := ParseShowTableStatusStmt()
  else if (IsTag(kiSHOW, kiTABLES)) then
    Result := ParseShowTablesStmt()
  else if (IsTag(kiSHOW, kiTRIGGERS)) then
    Result := ParseShowTriggersStmt()
  else if (IsTag(kiSHOW, kiGLOBAL, kiVARIABLES)
    or IsTag(kiSHOW, kiSESSION, kiVARIABLES)
    or IsTag(kiSHOW, kiVARIABLES)) then
    Result := ParseShowVariablesStmt()
  else if (IsTag(kiSHOW, kiWARNINGS)) then
    Result := ParseShowWarningsStmt()
  else if (IsTag(kiSHOW, kiSTORAGE, kiENGINES)) then
    Result := ParseShowEnginesStmt()
  else if (IsTag(kiSHUTDOWN)) then
    Result := ParseShutdownStmt()
  else if (IsTag(kiSIGNAL)) then
    Result := ParseSignalStmt()
  else if (IsTag(kiSTART, kiSLAVE)) then
    Result := ParseStartSlaveStmt()
  else if (IsTag(kiSTART, kiTRANSACTION)) then
    Result := ParseStartTransactionStmt()
  else if (IsTag(kiSTOP, kiSLAVE)) then
    Result := ParseStopSlaveStmt()
  else if (IsTag(kiTRUNCATE)) then
    Result := ParseTruncateTableStmt()
  else if (IsTag(kiUNINSTALL, kiPLUGIN)) then
    Result := ParseUninstallPluginStmt()
  else if (IsTag(kiUNLOCK, kiTABLES)) then
    Result := ParseUnlockTablesStmt()
  else if (IsTag(kiUPDATE)) then
    Result := ParseUpdateStmt()
  else if (IsTag(kiUSE)) then
    Result := ParseUseStmt()
  else if (IsTag(kiWHILE)) then
    if (not InPL_SQL) then
      Result := SetError(PE_UnexpectedStmt)
    else
      Result := ParseWhileStmt()
  else if (IsTag(kiXA)) then
    Result := ParseXAStmt()
  else if (EndOfStmt(CurrentToken)) then
    Result := 0
  else
    Result := SetError(PE_UnexpectedToken);

  if ((Result = 0) and not EndOfStmt(FirstToken)) then
    Result := ParseUnknownStmt(FirstToken);

  if (IsStmt(Result) and not InCompound) then
  begin
    Token := StmtPtr(Result)^.FirstToken;
    while (Assigned(Token)) do
    begin
      if ((Token^.UsageType = utDbIdent)
        and (Token^.DbIdentType = ditUnknown)
        and Assigned(Token^.ParentNode) and (PNode(Token^.ParentNode)^.NodeType = ntDbIdent)) then
        PDbIdent(Token^.ParentNode)^.FDbIdentType := ditField;

      if (Token = StmtPtr(Result)^.LastToken) then
        Token := nil
      else
        Token := Token^.NextToken;
    end;

    if (not EndOfStmt(CurrentToken) and (not InCompound or (TokenPtr(CurrentToken)^.KeywordIndex <> kiEND))) then
    begin
      if (not ErrorFound) then
        SetError(PE_ExtraToken);

      // Add unparsed Tokens to the Stmt
      while (not EndOfStmt(CurrentToken) and (not InCompound or (TokenPtr(CurrentToken)^.KeywordIndex <> kiEND))) do
      begin
        T := ApplyCurrentToken(utUnknown);
        StmtPtr(Result)^.Heritage.AddChildren(1, @T);
      end;
    end;

    if (Error.Code > PE_Success) then
    begin
      StmtPtr(Result)^.Error.Code := Error.Code;
      StmtPtr(Result)^.Error.Line := Error.Line;
      StmtPtr(Result)^.Error.Pos := Error.Pos;
      StmtPtr(Result)^.Error.Token := Error.Token;
    end;
  end;
end;

function TSQLParser.ParseString(): TOffset;
begin
  Result := 0;
  if (EndOfStmt(CurrentToken)) then
    SetError(PE_IncompleteStmt)
  else if ((TokenPtr(CurrentToken)^.TokenType <> ttString) and ((TokenPtr(CurrentToken)^.TokenType <> ttDQIdent) or AnsiQuotes)) then
    SetError(PE_UnexpectedToken)
  else
    Result := ApplyCurrentToken(utString);
end;

function TSQLParser.ParseSubArea(const ParseArea: TParseFunction): TOffset;
var
  Nodes: TSubArea.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    Nodes.AreaNode := ParseArea();

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TSubArea.Create(Self, Nodes);
end;

function TSQLParser.ParseSubPartition(): TOffset;
var
  Found: Boolean;
  Nodes: TSubPartition.TNodes;
begin
  if (not ErrorFound) then
    Nodes.SubPartitionTag := ParseTag(kiSUBPARTITION);

  if (not ErrorFound) then
    Nodes.NameIdent := ParsePartitionIdent();

  Found := True;
  while (not ErrorFound and Found) do
    if ((Nodes.CommentValue = 0) and IsTag(kiCOMMENT)) then
      Nodes.CommentValue := ParseValue(kiCOMMENT, vaAuto, ParseString)
    else if ((Nodes.DataDirectoryValue = 0) and IsTag(kiDATA, kiDIRECTORY)) then
      Nodes.DataDirectoryValue := ParseValue(WordIndices(kiDATA, kiDIRECTORY), vaAuto, ParseString)
    else if ((Nodes.EngineValue = 0) and IsTag(kiSTORAGE, kiENGINE)) then
      Nodes.EngineValue := ParseValue(WordIndices(kiSTORAGE, kiENGINE), vaAuto, ParseDbIdent)
    else if ((Nodes.EngineValue = 0) and IsTag(kiENGINE)) then
      Nodes.EngineValue := ParseValue(kiENGINE, vaAuto, ParseEngineIdent)
    else if ((Nodes.IndexDirectoryValue = 0) and IsTag(kiINDEX, kiDIRECTORY)) then
      Nodes.IndexDirectoryValue := ParseValue(WordIndices(kiINDEX, kiDIRECTORY), vaAuto, ParseString)
    else if ((Nodes.MaxRowsValue = 0) and IsTag(kiMAX_ROWS)) then
      Nodes.MaxRowsValue := ParseValue(kiMAX_ROWS, vaAuto, ParseInteger)
    else if ((Nodes.MinRowsValue = 0) and IsTag(kiMIN_ROWS)) then
      Nodes.MinRowsValue := ParseValue(kiMIN_ROWS, vaAuto, ParseInteger)
    else if ((Nodes.TablespaceValue = 0) and IsTag(kiTABLESPACE)) then
      Nodes.TablespaceValue := ParseValue(kiTABLESPACE, vaAuto, ParseDbIdent)
    else
      Found := False;

  Result := TSubPartition.Create(Self, Nodes);
end;

function TSQLParser.ParseSubquery(): TOffset;
var
  Nodes: TSubquery.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsTag(kiALL)) then
    Nodes.IdentTag := ParseTag(kiALL)
  else if (IsTag(kiANY)) then
    Nodes.IdentTag := ParseTag(kiANY)
  else if (IsTag(kiEXISTS)) then
    Nodes.IdentTag := ParseTag(kiEXISTS)
  else if (IsTag(kiNOT, kiALL)) then
    Nodes.IdentTag := ParseTag(kiNOT, kiALL)
  else if (IsTag(kiNOT, kiANY)) then
    Nodes.IdentTag := ParseTag(kiNOT, kiANY)
  else if (IsTag(kiNOT, kiEXISTS)) then
    Nodes.IdentTag := ParseTag(kiNOT, kiEXISTS)
  else
    Nodes.IdentTag := ParseTag(kiSOME);

  if (not ErrorFound) then
    Nodes.OpenToken := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    Nodes.Subquery := ParseSelectStmt(True);

  if (not ErrorFound) then
    Nodes.CloseToken := ParseSymbol(ttCloseBracket);

  Result := TSubquery.Create(Self, Nodes);
end;

function TSQLParser.ParseSubSelectStmt(): TOffset;
begin
  Result := ParseSelectStmt(True);
end;

function TSQLParser.ParseSubstringFunc(): TOffset;
var
  Nodes: TSubstringFunc.TNodes;
  Symbol: Boolean;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);
  Symbol := False;

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    Nodes.Str := ParseExpr();

  if (not ErrorFound) then
    if (IsTag(kiFROM)) then
    begin
      Nodes.FromTag := ParseTag(kiFROM);
      Symbol := False;
    end
    else if (IsSymbol(ttComma)) then
    begin
      Nodes.FromTag := ParseSymbol(ttComma);
      Symbol := True;
    end
    else if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
    Nodes.Pos := ParseExpr();

  if (not ErrorFound) then
    if (not Symbol and IsTag(kiFOR)) then
      Nodes.ForTag := ParseTag(kiFOR)
    else if (Symbol and IsSymbol(ttComma)) then
      Nodes.ForTag := ParseSymbol(ttComma);

  if (not ErrorFound and (Nodes.ForTag > 0)) then
    Nodes.Len := ParseExpr();

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TSubstringFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseSumFunc(): TOffset;
var
  Nodes: TSumFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    if (IsTag(kiDISTINCT)) then
      Nodes.DistinctToken := ParseTag(kiDISTINCT);

  if (not ErrorFound) then
    Nodes.Expr := ParseExpr();

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TSumFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseSymbol(const TokenType: TTokenType): TOffset;
begin
  Result := 0;

  if ((CurrentToken = 0) or (TokenType <> ttSemicolon) and (TokenPtr(CurrentToken)^.TokenType = ttSemicolon)) then
    SetError(PE_IncompleteStmt)
  else if (TokenPtr(CurrentToken)^.TokenType <> TokenType) then
    SetError(PE_UnexpectedToken)
  else
    Result := ApplyCurrentToken(utSymbol);
end;

function TSQLParser.ParseTableAliasIdent(): TOffset;
begin
  Result := ParseDbIdent(ditTableAlias, False);
end;

function TSQLParser.ParseTableIdent(): TOffset;
begin
  Result := ParseDbIdent(ditTable);
end;

function TSQLParser.ParseTag(const KeywordIndex1: TWordList.TIndex;
  const KeywordIndex2: TWordList.TIndex = -1; const KeywordIndex3: TWordList.TIndex = -1;
  const KeywordIndex4: TWordList.TIndex = -1; const KeywordIndex5: TWordList.TIndex = -1;
  const KeywordIndex6: TWordList.TIndex = -1; const KeywordIndex7: TWordList.TIndex = -1): TOffset;
var
  Nodes: TTag.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (EndOfStmt(CurrentToken)) then
  begin
    CompletionList.AddTag(KeywordIndex1, KeywordIndex2, KeywordIndex3, KeywordIndex4, KeywordIndex5, KeywordIndex6, KeywordIndex7);
    SetError(PE_IncompleteStmt);
  end
  else if (TokenPtr(CurrentToken)^.KeywordIndex <> KeywordIndex1) then
    SetError(PE_UnexpectedToken)
  else
  begin
    Nodes.Keyword1Token := ApplyCurrentToken(utKeyword);

    if (KeywordIndex2 >= 0) then
    begin
      if (EndOfStmt(CurrentToken)) then
      begin
        CompletionList.AddTag(KeywordIndex2, KeywordIndex3, KeywordIndex4, KeywordIndex5, KeywordIndex6, KeywordIndex7);
        SetError(PE_IncompleteStmt);
      end
      else if (TokenPtr(CurrentToken)^.KeywordIndex <> KeywordIndex2) then
        SetError(PE_UnexpectedToken)
      else
      begin
        Nodes.Keyword2Token := ApplyCurrentToken(utKeyword);

        if (KeywordIndex3 >= 0) then
        begin
          if (EndOfStmt(CurrentToken)) then
          begin
            CompletionList.AddTag(KeywordIndex3, KeywordIndex4, KeywordIndex5, KeywordIndex6, KeywordIndex7);
            SetError(PE_IncompleteStmt);
          end
          else if (TokenPtr(CurrentToken)^.KeywordIndex <> KeywordIndex3) then
            SetError(PE_UnexpectedToken)
          else
          begin
            Nodes.Keyword3Token := ApplyCurrentToken(utKeyword);

            if (KeywordIndex4 >= 0) then
            begin
              if (EndOfStmt(CurrentToken)) then
              begin
                CompletionList.AddTag(KeywordIndex4, KeywordIndex5, KeywordIndex6, KeywordIndex7);
                SetError(PE_IncompleteStmt);
              end
              else if (TokenPtr(CurrentToken)^.KeywordIndex <> KeywordIndex4) then
                SetError(PE_UnexpectedToken)
              else
              begin
                Nodes.Keyword4Token := ApplyCurrentToken(utKeyword);

                if (KeywordIndex5 >= 0) then
                begin
                  if (EndOfStmt(CurrentToken)) then
                  begin
                    CompletionList.AddTag(KeywordIndex5, KeywordIndex6, KeywordIndex7);
                    SetError(PE_IncompleteStmt);
                  end
                  else if (TokenPtr(CurrentToken)^.KeywordIndex <> KeywordIndex5) then
                    SetError(PE_UnexpectedToken)
                  else
                  begin
                    Nodes.Keyword5Token := ApplyCurrentToken(utKeyword);

                    if (KeywordIndex6 >= 0) then
                    begin
                      if (EndOfStmt(CurrentToken)) then
                      begin
                         CompletionList.AddTag(KeywordIndex6, KeywordIndex7);
                        SetError(PE_IncompleteStmt);
                      end
                      else if (TokenPtr(CurrentToken)^.KeywordIndex <> KeywordIndex6) then
                        SetError(PE_UnexpectedToken)
                      else
                      begin
                        Nodes.Keyword6Token := ApplyCurrentToken(utKeyword);

                        if (KeywordIndex7 >= 0) then
                        begin
                          if (EndOfStmt(CurrentToken)) then
                          begin
                            CompletionList.AddTag(KeywordIndex7);
                            SetError(PE_IncompleteStmt);
                          end
                          else if (TokenPtr(CurrentToken)^.KeywordIndex <> KeywordIndex7) then
                            SetError(PE_UnexpectedToken)
                          else
                          begin
                            Nodes.Keyword7Token := ApplyCurrentToken(utKeyword);
                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;

  Result := TTag.Create(Self, Nodes);
end;

function TSQLParser.ParseTimestampAddFunc(): TOffset;
var
  Nodes: TTimestampAddFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    if (IsTag(kiMICROSECOND)) then
      Nodes.UnitTag := ParseTag(kiMICROSECOND)
    else if (IsTag(kiSECOND)) then
      Nodes.UnitTag := ParseTag(kiSECOND)
    else if (IsTag(kiMINUTE)) then
      Nodes.UnitTag := ParseTag(kiMINUTE)
    else if (IsTag(kiHOUR)) then
      Nodes.UnitTag := ParseTag(kiHOUR)
    else if (IsTag(kiDAY)) then
      Nodes.UnitTag := ParseTag(kiDAY)
    else if (IsTag(kiWEEK)) then
      Nodes.UnitTag := ParseTag(kiWEEK)
    else if (IsTag(kiMONTH)) then
      Nodes.UnitTag := ParseTag(kiMONTH)
    else if (IsTag(kiQUARTER)) then
      Nodes.UnitTag := ParseTag(kiQUARTER)
    else if (IsTag(kiYEAR)) then
      Nodes.UnitTag := ParseTag(kiYEAR)
    else if (IsTag(kiSQL_TSI_MICROSECOND)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_MICROSECOND)
    else if (IsTag(kiSQL_TSI_SECOND)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_SECOND)
    else if (IsTag(kiSQL_TSI_MINUTE)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_MINUTE)
    else if (IsTag(kiSQL_TSI_HOUR)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_HOUR)
    else if (IsTag(kiSQL_TSI_DAY)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_DAY)
    else if (IsTag(kiSQL_TSI_WEEK)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_WEEK)
    else if (IsTag(kiSQL_TSI_MONTH)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_MONTH)
    else if (IsTag(kiSQL_TSI_QUARTER)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_QUARTER)
    else
      Nodes.UnitTag := ParseTag(kiSQL_TSI_YEAR);

  if (not ErrorFound) then
    Nodes.Comma1 := ParseSymbol(ttComma);

  if (not ErrorFound) then
    Nodes.IntervalInt := ParseInteger();

  if (not ErrorFound) then
    Nodes.Comma2 := ParseSymbol(ttComma);

  if (not ErrorFound) then
    Nodes.DatetimeExpr := ParseExpr();

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TTimestampAddFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseTimestampDiffFunc(): TOffset;
var
  Nodes: TTimestampDiffFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    if (IsTag(kiMICROSECOND)) then
      Nodes.UnitTag := ParseTag(kiMICROSECOND)
    else if (IsTag(kiSECOND)) then
      Nodes.UnitTag := ParseTag(kiSECOND)
    else if (IsTag(kiMINUTE)) then
      Nodes.UnitTag := ParseTag(kiMINUTE)
    else if (IsTag(kiHOUR)) then
      Nodes.UnitTag := ParseTag(kiHOUR)
    else if (IsTag(kiDAY)) then
      Nodes.UnitTag := ParseTag(kiDAY)
    else if (IsTag(kiWEEK)) then
      Nodes.UnitTag := ParseTag(kiWEEK)
    else if (IsTag(kiMONTH)) then
      Nodes.UnitTag := ParseTag(kiMONTH)
    else if (IsTag(kiQUARTER)) then
      Nodes.UnitTag := ParseTag(kiQUARTER)
    else if (IsTag(kiYEAR)) then
      Nodes.UnitTag := ParseTag(kiYEAR)
    else if (IsTag(kiSQL_TSI_MICROSECOND)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_MICROSECOND)
    else if (IsTag(kiSQL_TSI_SECOND)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_SECOND)
    else if (IsTag(kiSQL_TSI_MINUTE)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_MINUTE)
    else if (IsTag(kiSQL_TSI_HOUR)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_HOUR)
    else if (IsTag(kiSQL_TSI_DAY)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_DAY)
    else if (IsTag(kiSQL_TSI_WEEK)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_WEEK)
    else if (IsTag(kiSQL_TSI_MONTH)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_MONTH)
    else if (IsTag(kiSQL_TSI_QUARTER)) then
      Nodes.UnitTag := ParseTag(kiSQL_TSI_QUARTER)
    else
      Nodes.UnitTag := ParseTag(kiSQL_TSI_YEAR);

  if (not ErrorFound) then
    Nodes.Comma1 := ParseSymbol(ttComma);

  if (not ErrorFound) then
    Nodes.Datetime1Expr := ParseExpr();

  if (not ErrorFound) then
    Nodes.Comma2 := ParseSymbol(ttComma);

  if (not ErrorFound) then
    Nodes.Datetime2Expr := ParseExpr();

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TTimestampDiffFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseToken(out Error: TError): TOffset;
label
  TwoChars,
  Selection, SelSpace, SelQuotedIdent,
    SelNot, SelUnaryNot, SelDoubleQuote, SelComment, SelModulo, SelDollar, SelAmpersand2,
    SelBitAND, SelSingleQuote, SelOpenBracket, SelCloseBracket, SelMySQLCondEnd,
    SelMulti, SelComma, SelDot, SelDot2, SelMySQLCode, SelDiv, SelHexODBCHigh,
    SelHexODBCLow, SelDigit, SelSLComment, SelSLComment2, SelExtract, SelMinus, SelPlus, SelAssign,
    SelColon, SelDelimiter, SelNULLSaveEqual, SelLessEqual, SelShiftLeft,
    SelNotEqual2, SelLess, SelEqual, SelGreaterEqual, SelShiftRight, SelGreater,
    SelAt, SelQuestionMark, SelBitLiteral, SelNatStringHigh, SelNatStringLow,
    SelHexLiteral, SelAnsiQuoteLiterals, SelAnsiBitLiteral, SelAnsiNatStringHigh,
    SelAnsiNatStringLow, SelAnsiHexLiteral, SelIdent, SelOpenSquareBracket,
    SelCloseSquareBracket, SelHat, SelUnderscore, SelMySQLIdent,
    SelUnquotedIdentLower, SelOpenCurlyBracket, SelPipe, SelBitOR,
    SelCloseCurlyBracket, SelTilde, SelE,
  SLComment, SLCommentL,
  MLComment, MLCommentL, MLCommentLSingle, MLCommentLNLDouble, MLCommentLNLSingle, MLCommentLE,
  Ident, IdentL, IdentL2, IdentLE,
    IdentCharset, IdentCharsetL, IdentCharsetLE, IdentString, IdentString2, IdentStringE,
  Quoted, QuotedL, QuotedL2, QuotedLE, QuotedE, QuotedE2, QuotedE3,
    QuotedSecondQuoter, QuotedSecondQuoterL, QuotedSecondQuoterLE,
  Numeric, NumericL, NumericDot, NumericExp, NumericExpSign, NumericAlpha, NumericLE, NumericE, NumericHex,
  HexODBC, HexODBCL, HexODBCLE, HexODBCE,
  HexSQL, HexSQLL, HexSQLLE, HexSQLE,
  Bit, BitL, BitLE, BitE,
  Return, Return2, ReturnE,
  WhiteSpace, WhiteSpaceL, WhiteSpaceLE,
  MySQLCondStart, MySQLCondStartL, MySQLCondStartErr,
  IncompleteToken, UnexpectedChar, UnexpectedCharL,
  TrippelChar,
  DoubleChar,
  SingleChar,
  Finish;
const
  Terminators: PChar = #9#10#13#32'"#%&''()*+,-./:;<=>@`{|}'#127; // Characters, terminating a token
  TerminatorsL = 28; // Count of Terminators
var
  AnsiQuotes: Boolean;
  AtBefore: Boolean;
  Charset: PChar;
  CharsetFound: Boolean;
  CharsetLength: Integer;
  DotFound: Boolean;
  EFound: Boolean;
  ErrorCode: Integer;
  ErrorLine: Integer;
  ErrorPos: PChar;
  IdentBefore: Boolean;
  InMySQLCond: Boolean;
  KeywordIndex: TWordList.TIndex;
  Length: Integer;
  Line: Integer;
  NewLines: Integer;
  OperatorType: TOperatorType;
  S: string;
  SQL: PChar;
  TokenLength: Integer;
  TokenType: TTokenType;
  IsUsed: Boolean;
begin
  if (Parse.Length = 0) then
    Result := 0
  else
  begin
    AnsiQuotes := Self.AnsiQuotes;
    AtBefore := Parse.Before = pbAt;
    ErrorCode := PE_Success;
    ErrorLine := Parse.Line;
    ErrorPos := Parse.Pos;
    IdentBefore := Parse.Before = pbIdent;
    InMySQLCond := AllowedMySQLVersion > 0;
    Length := Parse.Length;
    Line := Parse.Line;
    NewLines := 0;
    OperatorType := otNone;
    SQL := Parse.Pos;
    TokenType := ttUnknown;

    asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        PUSH DS                          // string operations uses ES
        POP ES
        CLD                              // string operations uses forward direction

        MOV ESI,SQL
        MOV ECX,Length

      // ------------------------------

        CMP ECX,2                        // Two character (or more) in SQL?
        JAE TwoChars                     // Yes!
        MOV EAX,0                        // Hi Char in EAX
        MOV AX,[ESI]                     // One character from SQL to AX
        JMP Selection
      TwoChars:
        MOV EAX,[ESI]                    // Two characters from SQL to AX

      Selection:
        CMP AX,9                         // <Tabublator> ?
        JE WhiteSpace                    // Yes!
        CMP AX,10                        // <NewLine> ?
        JE Return                        // Yes!
        CMP AX,13                        // <CarriadgeReturn> ?
        JE Return                        // Yes!
        CMP AX,31                        // Invalid char ?
        JBE UnexpectedChar               // Yes!
      SelSpace:
        CMP AX,' '                       // <Space> ?
        JE WhiteSpace                    // Yes!
        CMP AX,'!'                       // "!" ?
        JNE SelDoubleQuote               // No!
        CMP EAX,$003D0021                // "!=" ?
        JNE SelUnaryNot                  // No!
        MOV OperatorType,otNotEqual
        JMP DoubleChar

      SelUnaryNot:
        MOV OperatorType,otUnaryNot
        JMP SingleChar
      SelDoubleQuote:
        CMP AX,'"'                       // Double Quote  ?
        JNE SelComment                   // No!
        MOV TokenType,ttDQIdent
        JMP Quoted
      SelComment:
        CMP AX,'#'                       // "#" ?
        JE SLComment                     // Yes!
      SelDollar:
        CMP AX,'$'                       // "$" ?
        JE Ident                         // Yes!
      SelModulo:
        CMP AX,'%'                       // "%" ?
        JNE SelAmpersand2                // No!
        MOV OperatorType,otMOD
        JMP SingleChar
      SelAmpersand2:
        CMP AX,'&'                       // "&" ?
        JNE SelSingleQuote               // No!
        CMP EAX,$00260026                // "&&" ?
        JNE SelBitAND                    // No!
        MOV OperatorType,otAND
        JMP DoubleChar
      SelBitAND:
        MOV OperatorType,otBitAND
        JMP SingleChar
      SelSingleQuote:
        CMP AX,''''                      // Single Quote ?
        JNE SelOpenBracket               // No!
        MOV TokenType,ttString
        JMP Quoted
      SelOpenBracket:
        CMP AX,'('                       // "(" ?
        JNE SelCloseBracket              // No!
        MOV TokenType,ttOpenBracket
        JMP SingleChar
      SelCloseBracket:
        CMP AX,')'                       // ")" ?
        JNE SelMySQLCondEnd              // No!
        MOV TokenType,ttCloseBracket
        JMP SingleChar
      SelMySQLCondEnd:
        CMP AX,'*'                       // "*" ?
        JNE SelPlus                      // No!
        CMP InMySQLCond,True             // Inside MySQL cond. Code?
        JNE SelMulti                     // No!
        CMP EAX,$002F002A                // "*/" ?
        JNE SelMulti                     // No!
        MOV TokenType,ttMySQLCondEnd
        JMP DoubleChar
      SelMulti:
        MOV OperatorType,otMulti
        JMP SingleChar
      SelPlus:
        CMP AX,'+'                       // "+" ?
        JNE SelComma                     // No!
        MOV OperatorType,otPlus
        JMP SingleChar
      SelComma:
        CMP AX,','                       // "," ?
        JNE SelSLComment                 // No!
        MOV TokenType,ttComma
        JMP SingleChar
      SelSLComment:
        CMP AX,'-'                       // "-" ?
        JNE SelDot                       // No!
        CMP EAX,$002D002D                // "--" ?
        JNE SelExtract                   // No!
        CMP ECX,3                        // Three characters in SQL?
        JAE SelSLComment2                // Yes!
        ADD ESI,4                        // Step over "--"
        SUB ECX,2                        // Two character handled
        JMP IncompleteToken
      SelSLComment2:
        CMP WORD PTR [ESI + 4],9         // "--<Tab>" ?
        JE SLComment                     // Yes!
        CMP WORD PTR [ESI + 4],10        // "--<LF>" ?
        JE SLComment                     // Yes!
        CMP WORD PTR [ESI + 4],13        // "--<CR>" ?
        JE SLComment                     // Yes!
        CMP WORD PTR [ESI + 4],' '       // "-- " ?
        JE SLComment                     // Yes!
        ADD ESI,4                        // Step over "--"
        SUB ECX,2                        // Two characters handled
        JMP UnexpectedChar
      SelExtract:
        CMP EAX,$003E002D                // "->" ?
        JNE SelMinus                     // No!
        MOV OperatorType,otJSONExtract
        JMP DoubleChar
      SelMinus:
        MOV OperatorType,otMinus
        JMP SingleChar
      SelDot:
        CMP AX,'.'                       // "." ?
        JNE SelMySQLCode                 // No!
        CMP IdentBefore,True             // The last token was an Identifier, but not a reserved word?
        JE SelDot2                       // Yes
        CMP EAX,$0030002E                // ".0"?
        JB SelDot2                       // No, before!
        CMP EAX,$0039002E                // ".9"?
        JA SelDot2                       // No, after!
        JMP Numeric
      SelDot2:
        MOV TokenType,ttDot
        MOV OperatorType,otDot
        JMP SingleChar
      SelMySQLCode:
        CMP AX,'/'                       // "/" ?
        JNE SelHexODBCHigh               // No!
        CMP EAX,$002A002F                // "/*" ?
        JNE SelDiv                       // No!
        CMP ECX,3                        // Three characters in SQL?
        JB MLComment                     // No!
        CMP WORD PTR [ESI + 4],'!'       // "/*!" ?
        JNE MLComment                    // No!
        JMP MySQLCondStart               // MySQL Code!
      SelDiv:
        MOV OperatorType,otDivision
        JMP SingleChar
      SelHexODBCHigh:
        CMP EAX,$00580030                // "0X" ?
        JE HexODBC                       // Yes!
      SelHexODBCLow:
        CMP EAX,$00780030                // "0x" ?
        JE HexODBC                       // Yes!
      SelDigit:
        CMP AX,'9'                       // Digit?
        JA SelAssign                     // No!
        CMP AtBefore,True                // The last token was a "@"?
        JE Ident                         // Yes!
        JMP Numeric
      SelAssign:
        CMP EAX,$003D003A                // ":=" ?
        JNE SelColon                     // No!
        MOV OperatorType,otAssign
        JMP DoubleChar
      SelColon:
        CMP AX,':'                       // ":" ?
        JNE SelDelimiter                 // No!
        MOV TokenType,ttColon
        JMP SingleChar
      SelDelimiter:
        CMP AX,';'                       // ";" ?
        JNE SelNULLSaveEqual             // No!
        MOV TokenType,ttSemicolon
        JMP SingleChar
      SelNULLSaveEqual:
        CMP AX,'<'                       // "<" ?
        JNE SelEqual                     // No!
        CMP EAX,$003D003C                // "<=" ?
        JNE SelShiftLeft                 // No!
        CMP ECX,3                        // Three characters in SQL?
        JB SelLessEqual                  // No!
        CMP WORD PTR [ESI + 4],'>'       // "<=>" ?
        JNE SelLessEqual                 // No!
        MOV OperatorType,otNULLSaveEqual
        JMP TrippelChar
      SelLessEqual:
        MOV OperatorType,otLessEqual     // "<="!
        JMP DoubleChar
      SelShiftLeft:
        CMP EAX,$003C003C                // "<<" ?
        JNE SelNotEqual2                 // No!
        MOV OperatorType,otShiftLeft
        JMP DoubleChar
      SelNotEqual2:
        CMP EAX,$003E003C                // "<>" ?
        JNE SelLess                      // No!
        MOV OperatorType,otNotEqual
        JMP DoubleChar
      SelLess:
        MOV OperatorType,otLess
        JMP SingleChar
      SelEqual:
        CMP AX,'='                       // "=" ?
        JNE SelGreaterEqual              // No!
        MOV OperatorType,otEqual
        JMP SingleChar
      SelGreaterEqual:
        CMP AX,'>'                       // ">" ?
        JNE SelQuestionMark              // No!
        CMP EAX,$003D003E                // ">=" ?
        JNE SelShiftRight                // No!
        MOV OperatorType,otGreaterEqual
        JMP DoubleChar
      SelShiftRight:
        CMP EAX,$003E003E                // ">>" ?
        JNE SelGreater                   // No!
        MOV OperatorType,otShiftRight
        JMP DoubleChar
      SelGreater:
        MOV OperatorType,otGreater
        JMP SingleChar
      SelQuestionMark:
        CMP AX,'?'                       // "?" ?
        JE UnexpectedChar
      SelAt:
        CMP AX,'@'                       // "@" ?
        JNE SelBitLiteral                // No!
        MOV TokenType,ttAt
        JMP SingleChar
      SelBitLiteral:
        CMP EAX,$00270042                // "B'" ?
        JE Bit                           // Yes!
        CMP EAX,$00270062                // "b'" ?
        JE Bit                           // Yes!
      SelNatStringHigh:
        CMP EAX,$0027004E                // "N'" ?
        JNE SelNatStringLow              // No!
        MOV TokenType,ttString
        ADD ESI,2                        // Step over "N"
        DEC ECX                          // One character handled
        JMP Quoted
      SelNatStringLow:
        CMP EAX,$0027006E                // "n'" ?
        JNE SelHexLiteral                // No!
        ADD ESI,2                        // Step over "n"
        DEC ECX                          // One character handled
        JMP Quoted
      SelHexLiteral:
        CMP EAX,$00270058                // "X'" ?
        JE HexSQL                        // Yes!
        CMP EAX,$00270078                // "x'" ?
        JE HexSQL                        // Yes!
      SelAnsiQuoteLiterals:
        CMP AnsiQuotes,True              // AnsiQuotes?
        JE SelIdent                      // Yes!
      SelAnsiBitLiteral:
        CMP EAX,$00220042                // 'B"' ?
        JE Bit                           // Yes!
        CMP EAX,$00220062                // 'b"' ?
        JE Bit                           // Yes!
      SelAnsiNatStringHigh:
        CMP EAX,$0022004E                // 'N"' ?
        JNE SelAnsiNatStringLow          // No!
        MOV TokenType,ttString
        ADD ESI,2                        // Step over "N"
        DEC ECX                          // One character handled
        JMP Quoted
      SelAnsiNatStringLow:
        CMP EAX,$0022006E                // 'n"' ?
        JNE SelAnsiHexLiteral            // No!
        ADD ESI,2                        // Step over "n"
        DEC ECX                          // One character handled
        JMP Quoted
      SelAnsiHexLiteral:
        CMP EAX,$00220058                // 'X"' ?
        JE HexSQL                        // Yes!
        CMP EAX,$00220078                // 'x"' ?
        JE HexSQL                        // Yes!
      SelIdent:
        CMP AX,'Z'                       // Up case character?
        JBE Ident                        // Yes!
      SelOpenSquareBracket:
        CMP AX,'['                       // "[" ?
        JE UnexpectedChar                // Yes!
      SelCloseSquareBracket:
        CMP AX,']'                       // "]" ?
        JE UnexpectedChar                // Yes!
      SelHat:
        CMP AX,'^'                       // "^" ?
        JNE SelUnderscore                // No!
        MOV OperatorType,otBitXOR
        JMP SingleChar
      SelUnderscore:
        CMP AX,'_'                       // "_" ?
        JE Ident                         // Yes!
      SelMySQLIdent:
        CMP AX,'`'                       // "`" ?
        JNE SelUnquotedIdentLower        // No!
        MOV TokenType,ttMySQLIdent
        JMP Quoted
      SelUnquotedIdentLower:
        CMP AX,'z'                       // Low case character?
        JBE Ident                        // Yes!
      SelOpenCurlyBracket:
        CMP AX,'{'                       // "{" ?
        JNE SelPipe                      // No!
        MOV TokenType,ttOpenCurlyBracket
        JMP SingleChar
      SelPipe:
        CMP AX,'|'                       // "|" ?
        JNE SelCloseCurlyBracket         // No!
        CMP EAX,$007C007C                // "||" ?
        JNE SelBitOR                     // No!
        MOV OperatorType,otOr
        JMP DoubleChar
      SelBitOR:
        MOV OperatorType,otBitOr
        JMP SingleChar
      SelCloseCurlyBracket:
        CMP AX,'}'                       // "}" ?
        JNE SelTilde                     // No!
        MOV TokenType,ttCloseCurlyBracket
        JMP SingleChar
      SelTilde:
        CMP AX,'~'                       // "~" ?
        JNE SelE                         // No!
        MOV OperatorType,otBitInversion
        JMP SingleChar
      SelE:
        CMP AX,127                       // #127 ?
        JE UnexpectedChar                // Yes!
        JMP Ident

      // ------------------------------

      SLComment:
        MOV TokenType,ttSLComment
      SLCommentL:
        CMP AX,10                        // <NewLine> ?
        JE Finish                        // Yes!
        CMP AX,13                        // <CarriageReturn> ?
        JE Finish                        // Yes!
        ADD ESI,2                        // Next character in SQL
        MOV AX,[ESI]                     // One character from SQL to AX
        LOOP SLCommentL
        JMP Finish

      // ------------------------------

      MLComment:
        MOV TokenType,ttMLComment
        ADD ESI,4                        // Step over "/*" in SQL
        SUB ECX,2                        // Two characters handled
        JZ IncompleteToken               // End of SQL!
      MLCommentL:
        CMP ECX,1                        // Last characters in SQL?
        JE MLCommentLSingle              // Yes!
        MOV EAX,[ESI]                    // Get two character from SQL
        CMP EAX,$000A000D                // <CarriadgeReturn><NewLine>?
        JE MLCommentLNLDouble            // Yes!
        CMP EAX,$000D000A                // <NewLine><CarriadgeReturn>?
        JE MLCommentLNLDouble            // Yes!
        CMP EAX,$002F002A                // "*/"?
        JE DoubleChar                    // Yes!
      MLCommentLSingle:
        CMP AX,10                        // <NewLine>?
        JE MLCommentLNLSingle            // Yes!
        CMP AX,13                        // <CarriadgeReturn>?
        JE MLCommentLNLSingle            // Yes!
        JMP MLCommentLE
      MLCommentLNLDouble:
        ADD ESI,2                        // Step over first byte
        DEC ECX                          // One character handled
      MLCommentLNLSingle:
        INC NewLines                     // One new line
      MLCommentLE:
        ADD ESI,2                        // Next character in SQL
        LOOP MLCommentL
        JMP IncompleteToken

      // ------------------------------

      Ident:
        MOV TokenType,ttIdent
        MOV EDI,ESI
        MOV EDX,ECX
        ADD ESI,2                        // Step over first character
        DEC ECX                          // One character handled
        JZ Finish
      IdentL:
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,9                         // <Tabulator>?
        JE IdentCharset                  // Yes!
        CMP AX,10                        // <NewLine>?
        JE IdentCharset                  // Yes!
        CMP AX,13                        // <CarriadgeReturn>?
        JE IdentCharset                  // Yes!
        CMP AX,' '                       // " "?
        JE IdentCharset                  // Yes!
        CMP AX,'$'                       // "$"?
        JE IdentLE                       // Yes!
        CMP AX,''''                      // "'"?
        JE IdentCharset                  // Yes!
        CMP AnsiQuotes,True              // AnsiQuotes?
        JE IdentL2                       // Yes!
        CMP AX,'"'                       // '"'?
        JE IdentCharset                  // Yes!
      IdentL2:
        CMP AX,'0'                       // "0"?
        JB Finish                        // Before!
        CMP AX,'9'                       // "9"?
        JBE IdentLE                      // Before or equal!
        CMP AX,'A'                       // "A"?
        JB Finish                        // Before!
        CMP AX,'Z'                       // "Z"?
        JBE IdentLE                      // Before or equal!
        CMP AX,'_'                       // "_"?
        JE IdentLE                       // Yes!
        CMP AX,'a'                       // "a"?
        JB Finish                        // Before!
        CMP AX,'z'                       // "z"?
        JBE IdentLE                      // Before or equal!
        CMP AX,128                       // Extended character?
        JB Finish                        // No!
      IdentLE:
        ADD ESI,2                        // Next character in SQL
        DEC ECX                          // One character handled
        JNZ IdentL                       // Next character, if available!
        JMP Finish

      IdentCharset:
        MOV AX,[EDI]                     // First character from SQL to AX
        CMP AX,'_'                       // "_"?
        JNE Finish                       // No!
        ADD EDI,2                        // Step over "_"
        SUB EDX,ECX                      // Length of ident
        DEC EDX                          //   ... and decrement the "_" character
        MOV Charset,EDI
        MOV CharsetLength,EDX
        PUSH ES
        PUSH ESI
        PUSH ECX
    end;
    CharsetFound := CharsetList.IndexOf(Charset, CharsetLength) >= 0;
    asm
        POP ECX
        POP ESI
        POP ES
        CMP CharsetFound,True            // Ident found as charset?
        JNE Finish                       // No!
      IdentCharsetL:
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,9                         // <Tabulator>?
        JE IdentCharsetLE                // Before!
        CMP AX,10                        // <NewLine>?
        JE IdentCharsetLE                // Yes!
        CMP AX,13                        // <CarriadgeReturn>?
        JE IdentCharsetLE                // Yes!
        CMP AX,' '                       // " "?
        JE IdentCharsetLE                // Yes!
        JMP IdentString
      IdentCharsetLE:
        ADD ESI,2                        // Next character in SQL
        LOOP IdentCharsetL
        JMP IncompleteToken

      IdentString:
        MOV TokenType,ttString
        JZ IncompleteToken               // End of SQL!
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,''''                      // "'"?
        JE Quoted                        // Yes!
        CMP AnsiQuotes,True              // AnsiQuotes?
        JE IdentString2                  // Yes!
        CMP AX,'"'                       // '"'?
        JE Quoted                        // Yes!
      IdentString2:
        CMP ECX,2                        // Two (or more) characters left in SQL?
        JB UnexpectedChar                // No!
        MOV EAX,[ESI]                    // Two characters from SQL to EAX
        CMP EAX,$00580030                // '0X' ?
        JE HexODBC                       // Yes!
        CMP EAX,$00780030                // '0x' ?
        JE HexODBC                       // Yes!
        CMP EAX,$00270042                // "B'" ?
        JE Bit                           // Yes!
        CMP EAX,$00270062                // "b'" ?
        JE Bit                           // Yes!
        CMP EAX,$00270058                // "X'" ?
        JE HexSQL                        // Yes!
        CMP EAX,$00270078                // "x'" ?
        JE HexSQL                        // Yes!
        CMP AnsiQuotes,True              // AnsiQuotes?
        JE IdentStringE                  // Yes!
        CMP EAX,$00220042                // 'B"' ?
        JE Bit                           // Yes!
        CMP EAX,$00220062                // 'b"' ?
        JE Bit                           // Yes!
        CMP EAX,$00220058                // 'X"' ?
        JE HexSQL                        // Yes!
        CMP EAX,$00220078                // 'x"' ?
        JE HexSQL                        // Yes!
      IdentStringE:
        JMP UnexpectedChar

      // ------------------------------

      Quoted:
        MOV DX,[ESI]                     // End Quoter
        ADD ESI,2                        // Step over Start Quoter in SQL
        DEC ECX                          // One character handled
        JZ IncompleteToken               // End of SQL!
        MOV EDI,ESI
      QuotedL:
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,10                        // <NewLine> ?
        JNE QuotedL2                     // No!
        INC NewLines                     // One new line
      QuotedL2:
        CMP AX,'\'                       // Escaper?
        JNE QuotedLE                     // No!
        CMP ECX,0                        // End of SQL?
        JE IncompleteToken               // Yes!
        ADD ESI,2                        // Next character in SQL
        DEC ECX                          // One character handled
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,DX                        // Escaped End Quoter?
        JE Quoted                        // Yes!
      QuotedLE:
        CMP AX,DX                        // End Quoter (unescaped)?
        JE QuotedE                       // Yes!
        ADD ESI,2                        // One character handled
        LOOP QuotedL
        JMP IncompleteToken
      QuotedE:
        ADD ESI,2                        // Step over End Quoter in SQL
        DEC ECX                          // One character handled
        JZ Finish                        // End of SQL!
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP DX,''''                      // Quoter = "'"?
        JE QuotedE2                      // Yes!
        CMP AnsiQuotes,True              // AnsiQuotes?
        JE QuotedE3                      // Yes!
        CMP DX,'"'                       // Quoter = '"'?
        JNE QuotedE3                     // No!
      QuotedE2:
        CMP AX,9                         // <Tabulator> ?
        JE QuotedSecondQuoter            // Yes!
        CMP AX,10                        // <NewLine> ?
        JE QuotedSecondQuoter            // Yes!
        CMP AX,13                        // <CarriadgeReturn> ?
        JE QuotedSecondQuoter            // Yes!
        CMP AX,' '                       // <Space> ?
        JE QuotedSecondQuoter            // Yes!
      QuotedE3:
        CMP AX,DX                        // A seconed End Quoter (unescaped)?
        JNE Finish                       // No!
        ADD ESI,2                        // Step over second End Quoter in SQL
        DEC ECX
        JNZ QuotedL                      // Handle further characters
        JMP Finish

      QuotedSecondQuoter:
        PUSH ESI
        PUSH ECX
      QuotedSecondQuoterL:
        ADD ESI,2                        // One character handled
        DEC ECX
        JZ QuotedSecondQuoterLE          // Yes!
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,9                         // <Tabulator> ?
        JE QuotedSecondQuoterL           // Yes!
        CMP AX,10                        // <NewLine> ?
        JE QuotedSecondQuoterL           // Yes!
        CMP AX,13                        // <CarriadgeReturn> ?
        JE QuotedSecondQuoterL           // Yes!
        CMP AX,' '                       // <Space> ?
        JE QuotedSecondQuoterL           // Yes!
        CMP AX,DX                        // New Quoter?
        JNE QuotedSecondQuoterLE         // No!
        POP EAX                          // Restore Stack
        POP EAX                          // Restore Stack
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        JMP Quoted
      QuotedSecondQuoterLE:
        POP ECX
        POP ESI
        JMP Finish

      // ------------------------------

      Numeric:
        MOV DotFound,False               // One dot in a numeric value allowed only
        MOV EFound,False                 // One "E" in a numeric value allowed only
        MOV TokenType,ttInteger
      NumericL:
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,'.'                       // Dot?
        JE NumericDot                    // Yes!
        CMP AX,'E'                       // "E"?
        JE NumericExp                    // Yes!
        CMP AX,'e'                       // "e"?
        JE NumericExp                    // Yes!
        CMP AX,'0'                       // Digit?
        JB NumericE                      // No!
        CMP AX,'9'
        JBE NumericLE                    // Yes!
        CMP AX,'A'                       // "A"?
        JB Finish                        // Before!
        CMP AX,'Z'                       // "Z"?
        JBE NumericAlpha                 // Yes!
        CMP AX,'_'                       // "_"?
        JE NumericAlpha                  // Yes!
        CMP AX,'a'                       // "z"?
        JB Finish                        // Before!
        CMP AX,'z'                       // "z"?
        JBE NumericAlpha                 // Yes!
        CMP AX,127                       // Extended character?
        JBE Finish                       // No!
        JMP Ident
      NumericDot:
        CMP EFound,False                 // A 'e' before?
        JNE UnexpectedChar               // Yes!
        CMP DotFound,True                // A '.' before?
        JE Finish                        // Yes!
        MOV DotFound,True
        MOV TokenType,ttNumeric          // A dot means it's an Numeric token
        JMP NumericLE
      NumericExp:
        CMP DotFound,False               // A '.' before?
        JE Ident                         // Yes!
        CMP EFound,False                 // A 'e' before?
        JNE Ident                        // Yes!
        MOV EFound,True
        ADD ESI,2                        // Next character in SQL
        DEC ECX                          // One character handled
        JZ IncompleteToken               // End of SQL!
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,'+'                       // "+"?
        JE NumericExpSign                // Yes!
        CMP AX,'-'                       // "-"?
        JE NumericExpSign                // Yes!
        JMP NumericL
      NumericExpSign:
        ADD ESI,2                        // Next character in SQL
        DEC ECX                          // One character handled
        JZ IncompleteToken               // End of SQL!
        JMP NumericL
      NumericAlpha:
        CMP DotFound,False               // "." in Token?
        JE Ident                         // No!
        JMP Finish
      NumericLE:
        ADD ESI,2                        // Next character in SQL
        DEC ECX
        JNZ NumericL
      NumericE:
        JMP Finish

      // ------------------------------

      HexODBC:
        MOV TokenType,ttString
        ADD ESI,2                        // Step over "0"
        DEC ECX                          // One character handled
        ADD ESI,2                        // Step over "x"
        DEC ECX                          // One character handled
        JZ IncompleteToken               // End of SQL!
        MOV EBX,ECX
      HexODBCL:
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,'0'                       // Digit?
        JB HexODBCE                      // No!
        CMP AX,'9'
        JBE HexODBCLE                    // Yes!
        CMP AX,'A'                       // Upper hex char?
        JB HexODBCE                      // No!
        CMP AX,'F'
        JBE HexODBCLE                    // Yes!
        CMP AX,'a'                       // Lower hex char?
        JB HexODBCE                      // No!
        CMP AX,'f'
        JBE HexODBCLE                    // Yes!
        JMP HexODBCE
      HexODBCLE:
        ADD ESI,2                        // Next character in SQL
        LOOP HexODBCL
      HexODBCE:
        SUB EBX,ECX                      // Length of hex character
        CMP EBX,0                        // 0?
        JE IncompleteToken               // Yes!
        JMP Finish

      // ------------------------------

      HexSQL:
        MOV TokenType,ttString
        ADD ESI,2                        // Step over "X"
        DEC ECX                          // One character handled
        MOV DX,[ESI]                     // Start quoter
        ADD ESI,2                        // Step over quoter
        DEC ECX                          // One character handled
        JZ IncompleteToken               // End of SQL!
        MOV EBX,ECX
      HexSQLL:
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,DX                        // End quoter?
        JE HexSQLE                       // Yes!
        CMP AX,'0'                       // Digit?
        JB HexSQLE                       // No!
        CMP AX,'9'
        JBE HexSQLLE                     // Yes!
        CMP AX,'A'                       // Upper hex char?
        JB HexSQLE                       // No!
        CMP AX,'F'
        JBE HexSQLLE                     // Yes!
        CMP AX,'a'                       // Lower hex char?
        JB HexSQLE                       // No!
        CMP AX,'f'
        JBE HexSQLLE                     // Yes!
        JMP UnexpectedChar
      HexSQLLE:
        ADD ESI,2                        // Next character in SQL
        LOOP HexSQLL
        JMP IncompleteToken
      HexSQLE:
        SUB EBX,ECX                      // Length of hex character
        TEST EBX,1                       // Even length?
        JNZ IncompleteToken
        ADD ESI,2                        // Step over quoter
        DEC ECX                          // One character handled
        JMP Finish

      // ------------------------------

      Bit:
        MOV TokenType,ttString
        ADD ESI,2                        // Step over "B"
        DEC ECX                          // One character handled
        MOV DX,[ESI]                     // Start quoter
        ADD ESI,2                        // Step over Quoter
        DEC ECX                          // One character handled
        JZ IncompleteToken               // End of SQL!
      BitL:
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,DX                        // End quoter?
        JE BitE                          // Yes!
        CMP AX,'0'                       // "0"?
        JE BitLE                         // Yes!
        CMP AX,'1'                       // "1"?
        JE BitLE                         // Yes!
        JMP UnexpectedChar
      BitLE:
        ADD ESI,2                        // Next character in SQL
        LOOP BitL
        JMP IncompleteToken
      BitE:
        ADD ESI,2                        // Step over quoter
        DEC ECX                          // One character handled
        JMP Finish

      // ------------------------------

      Return:
        MOV TokenType,ttReturn
        INC NewLines                     // One new line
        CMP EAX,$000A000D                // <CarriadgeReturn><NewLine>?
        JE DoubleChar                    // Yes!
        CMP EAX,$000D000A                // <NewLine><CarriadgeReturn>?
        JE DoubleChar                    // Yes!
        JMP SingleChar

      // ------------------------------

      WhiteSpace:
        MOV TokenType,ttSpace
      WhiteSpaceL:
        CMP AX,9                         // Tabulator?
        JE WhiteSpaceLE                  // Yes!
        CMP AX,' '                       // Space?
        JNE Finish                       // No!
      WhiteSpaceLE:
        ADD ESI,2                        // Next character in SQL
        DEC ECX                          // One character handled
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        MOV AX,[ESI]                     // One character from SQL to AX
        JMP WhiteSpaceL

      // ------------------------------

      MySQLCondStart:
        MOV TokenType,ttMySQLCondStart
        ADD ESI,6                        // Step over "/*!" in SQL
        SUB ECX,3                        // Three characters handled
        CMP ECX,0                        // End of SQL?
        JE IncompleteToken               // Yes!
        MOV EDX,ECX
        SUB EDX,5                        // Version must be 5 characters long
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,'0'                       // First digit = '0'?
        JE MySQLCondStartErr             // Yes!
      MySQLCondStartL:
        CMP ECX,EDX                      // 5 digits handled?
        JE Finish
        MOV AX,[ESI]                     // One character from SQL to AX
        CMP AX,'0'                       // Digit?
        JB MySQLCondStartErr             // No!
        CMP AX,'9'                       // Digit?
        JA MySQLCondStartErr             // No!
        ADD ESI,2                        // Next character in SQL
        LOOP MySQLCondStartL
        JMP IncompleteToken
      MySQLCondStartErr:
        MOV ErrorCode,PE_InvalidMySQLCond
        MOV EAX,Line
        ADD EAX,NewLines
        MOV ErrorLine,EAX
        MOV ErrorPos,ESI
        ADD ESI,2                        // Step over invalid character
        JMP Finish

      // ------------------------------

      IncompleteToken:
        MOV ErrorCode,PE_IncompleteToken
        MOV EAX,Line
        MOV ErrorLine,EAX
        MOV EAX,SQL
        MOV ErrorPos,EAX
        JMP Finish

      UnexpectedChar:
        MOV ErrorCode,PE_UnexpectedChar
        MOV EAX,Line
        ADD EAX,NewLines
        MOV ErrorLine,EAX
        MOV ErrorPos,ESI
        ADD ESI,2                        // Step over unexpected character
        DEC ECX                          // One character handled
        JZ Finish                        // End of SQL!
      UnexpectedCharL:
        MOV AX,[ESI]                     // One character from SQL to AX
        PUSH ECX
        MOV EDI,[Terminators]
        MOV ECX,TerminatorsL
        REPNE SCASW                      // Character in Terminators?
        POP ECX
        JE Finish                        // Yes!
        ADD ESI,2                        // Next character in SQL
        LOOP UnexpectedCharL
        JMP Finish

      TrippelChar:
        ADD ESI,2                        // Next character in SQL
        DEC ECX                          // One character handled
      DoubleChar:
        ADD ESI,2                        // Next character in SQL
        DEC ECX                          // One character handled
      SingleChar:
        ADD ESI,2                        // Next character in SQL
        DEC ECX                          // One character handled

      Finish:
        MOV EAX,Length                   // Calculate TokenLength
        SUB EAX,ECX
        MOV TokenLength,EAX

        POP EBX
        POP EDI
        POP ESI
        POP ES
    end;

    if ((TokenLength = 0) and (ErrorCode = PE_Success)) then
      raise Exception.Create(SUnknownError);

    if ((TokenType = ttUnknown) and (OperatorType <> otNone)) then
      TokenType := ttOperator;

    // Debug 2017-01-27
    if ((ErrorCode = PE_Success) and (TokenType = ttUnknown)) then
    begin
      SetString(S, SQL, TokenLength);
      raise ERangeError.Create('Unknown TokenType for: ' + S);
    end;

    Assert((ErrorCode <> PE_Success) or (TokenType <> ttUnknown));

    if (TokenType <> ttIdent) then
      KeywordIndex := -1
    else
    begin
      KeywordIndex := KeywordList.IndexOf(SQL, TokenLength);
      if (KeywordIndex >= 0) then
        OperatorType := OperatorTypeByKeywordIndex[KeywordIndex];
    end;

    if (ErrorCode = 0) then
      case (TokenType) of
        ttMySQLCondStart:
          if (AllowedMySQLVersion = 0) then
          begin
            SetString(S, PChar(@SQL[3]), TokenLength - 3);
            AllowedMySQLVersion := StrToInt(S);
          end
          else
            ErrorCode := PE_NestedMySQLCond;
        ttMySQLCondEnd:
          if (AllowedMySQLVersion > 0) then
            AllowedMySQLVersion := 0
          else
            ErrorCode := PE_UnexpectedToken;
      end;

    IsUsed := not (TokenType in [ttSpace, ttReturn, ttSLComment, ttMLComment, ttMySQLCondStart, ttMySQLCondEnd])
      and ((AllowedMySQLVersion = 0) or (MySQLVersion >= AllowedMySQLVersion));

    Result := TToken.Create(Self, SQL, TokenLength, TokenType, OperatorType, KeywordIndex, IsUsed {$IFDEF Debug}, TokenIndex {$ENDIF});

    Error.Code := ErrorCode;
    Error.Line := ErrorLine;
    Error.Pos := ErrorPos;
    Error.Token := Result;

    Parse.Length := Parse.Length - TokenLength;
    Parse.Line := Parse.Line + NewLines;
    Parse.Pos := @Parse.Pos[TokenLength];
    if (IsUsed) then
      if (TokenType = ttAt) then
        Parse.Before := pbAt
      else if ((TokenType in ttIdents) and (ReservedWordList.IndexOf(SQL, TokenLength) < 0)) then
        Parse.Before := pbIdent
      else
        Parse.Before := pbOther;
  end;
end;

function TSQLParser.ParseTriggerIdent(): TOffset;
begin
  Result := ParseDbIdent(ditTrigger);
end;

function TSQLParser.ParseTrimFunc(): TOffset;
var
  Nodes: TTrimFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    if (IsTag(kiBOTH)) then
      Nodes.LocationTag := ParseTag(kiBOTH)
    else if (IsTag(kiLEADING)) then
      Nodes.LocationTag := ParseTag(kiLEADING)
    else if (IsTag(kiTRAILING)) then
      Nodes.LocationTag := ParseTag(kiTRAILING);

  if (Nodes.LocationTag > 0) then
  begin
    if (not ErrorFound) then
      Nodes.RemoveStr := ParseExpr();

    if (not ErrorFound) then
      Nodes.FromTag := ParseTag(kiFROM);

    if (not ErrorFound) then
      Nodes.Str := ParseExpr();
  end
  else
  begin
    if (not ErrorFound) then
      Nodes.Str := ParseExpr();

    if (IsTag(kiFROM)) then
    begin
      Nodes.RemoveStr := Nodes.Str;
      Nodes.Str := 0;

      Nodes.FromTag := ParseTag(kiFROM);

      if (not ErrorFound) then
        Nodes.Str := ParseExpr();
    end;
  end;

  if (not ErrorFound and (Nodes.OpenBracket > 0)) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TTrimFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseTruncateTableStmt(): TOffset;
var
  Nodes: TTruncateStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiTRUNCATE);

  if (not ErrorFound) then
    if (IsTag(kiTABLE)) then
      Nodes.TableTag := ParseTag(kiTABLE);

  if (not ErrorFound) then
    Nodes.TableIdent := ParseTableIdent();

  Result := TTruncateStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseUninstallPluginStmt(): TOffset;
var
  Nodes: TUninstallPluginStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtTag := ParseTag(kiUNINSTALL, kiPLUGIN);

  if (not ErrorFound) then
    Nodes.Ident := ParseDbIdent(ditPlugin, False);

  Result := TUninstallPluginStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseUnknownStmt(const FirstToken: TOffset): TOffset;
var
  Token: PToken;
  Tokens: TOffsetList;
begin
  Tokens.Init();

  if (not IsToken(FirstToken)) then
    Token := nil
  else
    Token := TokenPtr(FirstToken);

  while (Assigned(Token) and (Token^.Offset <> CurrentToken) and not EndOfStmt(Token^.Offset)) do
  begin
    Tokens.Add(Token^.Offset);
    Token := Token^.NextTokenAll;
  end;

  while (not EndOfStmt(CurrentToken)) do
    Tokens.Add(ApplyCurrentToken(utUnknown));

  Result := TUnknownStmt.Create(Self, @Tokens);
end;

function TSQLParser.ParseUnlockTablesStmt(): TOffset;
var
  Nodes: TUnlockTablesStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.UnlockTablesTag := ParseTag(kiUNLOCK, kiTABLES);

  Result := TUnlockTablesStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseUpdateStmt(): TOffset;
var
  Nodes: TUpdateStmt.TNodes;
  TableCount: Integer;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);
  TableCount := 0;

  Nodes.UpdateTag := ParseTag(kiUPDATE);

  if (not ErrorFound) then
    if (IsTag(kiLOW_PRIORITY)) then
      Nodes.PriorityTag := ParseTag(kiLOW_PRIORITY)
    else if (IsTag(kiIGNORE)) then
      Nodes.PriorityTag := ParseTag(kiIGNORE);

  if (not ErrorFound) then
  begin
    Nodes.TableReferenceList := ParseList(False, ParseSelectStmtTableEscapedReference);
    if (Nodes.TableReferenceList = 0) then
      TableCount := 0
    else
      TableCount := PList(NodePtr(Nodes.TableReferenceList))^.ElementCount;
  end;

  if (not ErrorFound) then
    Nodes.Set_.Tag := ParseTag(kiSET);

  if (not ErrorFound) then
    Nodes.Set_.PairList := ParseList(False, ParseUpdateStmtValue);

  if (not ErrorFound) then
    if (IsTag(kiWHERE)) then
    begin
      Nodes.Where.Tag := ParseTag(kiWHERE);

      if (not ErrorFound) then
        Nodes.Where.Expr := ParseExpr();
    end;

  if (not ErrorFound and (TableCount = 1)) then
  begin
    if (IsTag(kiORDER, kiBY)) then
    begin
      Nodes.OrderBy.Tag := ParseTag(kiORDER, kiBY);

      if (not ErrorFound) then
        Nodes.OrderBy.List := ParseList(False, ParseSelectStmtOrder);
    end;

    if (not ErrorFound) then
      if (IsTag(kiLIMIT)) then
      begin
        Nodes.Limit.Tag := ParseTag(kiLIMIT);

        if (not ErrorFound) then
          Nodes.Limit.Token := ParseExpr([]);
      end;
  end;

  Result := TUpdateStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseUpdateStmtValue(): TOffset;
var
  Nodes: TValue.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Ident := ParseFieldIdentFullQualified();

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (not (TokenPtr(CurrentToken)^.OperatorType in [otEqual, otAssign])) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.AssignToken := ApplyCurrentToken(utOperator);

  if (not ErrorFound) then
    Nodes.Expr := ParseExpr();

  Result := TValue.Create(Self, Nodes);
end;

function TSQLParser.ParseUseStmt(): TOffset;
var
  Nodes: TUseStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.StmtToken := ParseTag(kiUSE);

  if (not ErrorFound) then
    Nodes.Ident := ParseDatabaseIdent();

  Result := TUseStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseValue(const KeywordIndex: TWordList.TIndex;
  const Assign: TValueAssign; const Brackets: Boolean;
  const ParseItem: TParseFunction): TOffset;
var
  Nodes: TValue.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Ident := ParseTag(KeywordIndex);

  if (not ErrorFound and (Assign in [vaYes, vaAuto])) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (TokenPtr(CurrentToken)^.OperatorType = otEqual) then
      Nodes.AssignToken := ApplyCurrentToken(utOperator)
    else if (Assign = vaYes) then
      SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
    Nodes.Expr := ParseList(Brackets, ParseItem);

  Result := TValue.Create(Self, Nodes);
end;

function TSQLParser.ParseValue(const KeywordIndex: TWordList.TIndex;
  const Assign: TValueAssign; const OptionIndices: TWordList.TIndices): TOffset;
var
  I: Integer;
  Nodes: TValue.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Ident := ParseTag(KeywordIndex);

  if (not ErrorFound and (Assign in [vaYes, vaAuto])) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (TokenPtr(CurrentToken)^.OperatorType = otEqual) then
      Nodes.AssignToken := ApplyCurrentToken(utOperator)
    else if (Assign = vaYes) then
      SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
  begin
    for I := 0 to Length(OptionIndices) - 1 do
      if ((OptionIndices[I] < 0)) then
        break
      else if (OptionIndices[I] = TokenPtr(CurrentToken)^.KeywordIndex) then
      begin
        Nodes.Expr := ParseTag(TokenPtr(CurrentToken)^.KeywordIndex);
        break;
      end;
    if (Nodes.Expr = 0) then
      SetError(PE_UnexpectedToken);
  end;

  Result := TValue.Create(Self, Nodes);
end;

function TSQLParser.ParseValue(const KeywordIndex: TWordList.TIndex;
  const Assign: TValueAssign; const ParseValueNode: TParseFunction): TOffset;
var
  Nodes: TValue.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Ident := ParseTag(KeywordIndex);

  if (not ErrorFound and (Assign in [vaYes, vaAuto])) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (TokenPtr(CurrentToken)^.OperatorType = otEqual) then
      Nodes.AssignToken := ApplyCurrentToken(utOperator)
    else if (Assign = vaYes) then
      SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
    Nodes.Expr := ParseValueNode();

  Result := TValue.Create(Self, Nodes);
end;

function TSQLParser.ParseValue(const KeywordIndices: TWordList.TIndices; const Assign: TValueAssign; const ParseValueNode: TParseFunction): TOffset;
var
  Nodes: TValue.TNodes;
begin
  Assert(KeywordIndices[4] = -1);

  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.Ident := ParseTag(KeywordIndices[0], KeywordIndices[1], KeywordIndices[2], KeywordIndices[3], KeywordIndices[4], KeywordIndices[5], KeywordIndices[6]);

  if (not ErrorFound and (Assign in [vaYes, vaAuto])) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (TokenPtr(CurrentToken)^.OperatorType = otEqual) then
      Nodes.AssignToken := ApplyCurrentToken(utOperator)
    else if (Assign = vaYes) then
      SetError(PE_UnexpectedToken);

  if (not ErrorFound) then
    Nodes.Expr := ParseValueNode();

  Result := TValue.Create(Self, Nodes);
end;

function TSQLParser.ParseVariableIdent(): TOffset;
var
  Nodes: TVariable.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  if (IsSymbol(ttAt)) then
    Nodes.At1Token := ParseSymbol(ttAt);

  if (not ErrorFound and IsSymbol(ttAt)) then
  begin
    Nodes.At2Token := Nodes.At1Token;
    Nodes.At1Token := ParseSymbol(ttAt);
  end;

  if (not ErrorFound and ((Nodes.At1Token = 0) or (Nodes.At2Token > 0))) then
    if (IsTag(kiGLOBAL)
      or IsTag(kiSESSION)
      or IsTag(kiLOCAL)) then
    begin
      if (IsTag(kiGLOBAL)) then
        Nodes.ScopeTag := ParseTag(kiGLOBAL)
      else if (IsTag(kiSESSION)) then
        Nodes.ScopeTag := ParseTag(kiSESSION)
      else
        Nodes.ScopeTag := ParseTag(kiLOCAL);

      if (not ErrorFound) then
        if (EndOfStmt(CurrentToken)) then
          SetError(PE_IncompleteStmt)
        else if (TokenPtr(CurrentToken)^.OperatorType <> otDot) then
          SetError(PE_UnexpectedToken)
        else
          Nodes.ScopeDotToken := ApplyCurrentToken(utSymbol);
    end;

  if (not ErrorFound) then
    if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else if (IsNextSymbol(1, ttDot)) then
      Nodes.Ident := ParseList(False, ParseDbIdent, ttDot)
    else if ((Nodes.At1Token > 0) or (Nodes.ScopeTag > 0)) then
      Nodes.Ident := ParseDbIdent(ditVariable, False)
    else
      Nodes.Ident := ParseDbIdent(ditUnknown, False);

  Result := TVariable.Create(Self, Nodes);
end;

function TSQLParser.ParseWeightStringFunc(): TOffset;
var
  Nodes: TWeightStringFunc.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.IdentToken := ApplyCurrentToken(utDbIdent);

  if (not ErrorFound) then
    Nodes.OpenBracket := ParseSymbol(ttOpenBracket);

  if (not ErrorFound) then
    Nodes.Str := ParseString();

  if (not ErrorFound) then
    if (IsTag(kiAS)) then
    begin
      Nodes.AsTag := ParseTag(kiAS);

      if (not ErrorFound) then
        Nodes.Datatype := ParseDatatype();
    end;

  if (not ErrorFound) then
    if (IsTag(kiLEVEL)) then
    begin
      Nodes.AsTag := ParseTag(kiLEVEL);

      if (not ErrorFound) then
        Nodes.LevelList := ParseList(False, ParseWeightStringFuncLevel);
    end;

  if (not ErrorFound) then
    Nodes.CloseBracket := ParseSymbol(ttCloseBracket);

  Result := TWeightStringFunc.Create(Self, Nodes);
end;

function TSQLParser.ParseWeightStringFuncLevel(): TOffset;
var
  Nodes: TWeightStringFunc.TLevel.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.CountInt := ParseInteger();

  if (not ErrorFound) then
    if (IsTag(kiASC)) then
      Nodes.DirectionTag := ParseTag(kiASC)
    else if (IsTag(kiDESC)) then
      Nodes.DirectionTag := ParseTag(kiDESC);

  if (not ErrorFound) then
    if (IsTag(kiREVERSE)) then
      Nodes.DirectionTag := ParseTag(kiREVERSE);

  Result := TWeightStringFunc.TLevel.Create(Self, Nodes);
end;

function TSQLParser.ParseWhileStmt(const BeginLabel: TOffset): TOffset;
var
  Nodes: TWhileStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.BeginLabel := BeginLabel;

  if (not ErrorFound) then
    Nodes.WhileTag := ParseTag(kiWHILE);

  if (not ErrorFound) then
    Nodes.SearchConditionExpr := ParseExpr();

  if (not ErrorFound) then
    Nodes.DoTag := ParseTag(kiDO);

  if (not ErrorFound) then
    Nodes.StmtList := ParseList(False, ParsePL_SQLStmt, ttSemicolon, False);

  if (not ErrorFound) then
    Nodes.EndTag := ParseTag(kiEND, kiWHILE);

  if (not ErrorFound
    and not EndOfStmt(CurrentToken) and (TokenPtr(CurrentToken)^.TokenType = ttIdent)
    and (Nodes.BeginLabel > 0) and (NodePtr(Nodes.BeginLabel)^.NodeType = ntBeginLabel)) then
    if ((Nodes.BeginLabel = 0) or (lstrcmpi(PChar(TokenPtr(CurrentToken)^.AsString), PChar(PBeginLabel(NodePtr(Nodes.BeginLabel))^.LabelName)) <> 0)) then
      SetError(PE_UnexpectedToken)
    else
      Nodes.EndLabel := ParseEndLabel();

  Result := TWhileStmt.Create(Self, Nodes);
end;

function TSQLParser.ParseXAStmt(): TOffset;

  function ParseXID(): TOffset;
  var
    Nodes: TXAStmt.TID.TNodes;
  begin
    FillChar(Nodes, SizeOf(Nodes), 0);

    Nodes.GTrId := ParseString();

    if (not ErrorFound) then
      if (IsSymbol(ttComma)) then
      begin
        Nodes.Comma1 := ParseSymbol(ttComma);

        if (not ErrorFound) then
          Nodes.BQual := ParseString();

        if (not ErrorFound) then
          if (IsSymbol(ttComma)) then
          begin
            Nodes.Comma1 := ParseSymbol(ttComma);

            if (not ErrorFound) then
              Nodes.FormatId := ParseInteger();
          end;
      end;

    Result := TXAStmt.TID.Create(Self, Nodes);
  end;

var
  Nodes: TXAStmt.TNodes;
begin
  FillChar(Nodes, SizeOf(Nodes), 0);

  Nodes.XATag := ParseTag(kiXA);

  if (not ErrorFound) then
    if (IsTag(kiBEGIN)
      or IsTag(kiSTART)) then
    begin
      if (IsTag(kiBEGIN)) then
        Nodes.ActionTag := ParseTag(kiBEGIN)
      else
        Nodes.ActionTag := ParseTag(kiSTART);

      if (not ErrorFound) then
        Nodes.Ident := ParseXID();

      if (not ErrorFound) then
        if (IsTag(kiJOIN)) then
          Nodes.RestTag := ParseTag(kiJOIN)
        else if (IsTag(kiRESUME)) then
          Nodes.RestTag := ParseTag(kiRESUME);
    end
    else if (IsTag(kiCOMMIT)) then
    begin
      Nodes.ActionTag := ParseTag(kiCOMMIT);

      if (not ErrorFound) then
        Nodes.Ident := ParseXID();

      if (not ErrorFound) then
        if (IsTag(kiONE, kiPHASE)) then
          Nodes.RestTag := ParseTag(kiONE, kiPHASE);
    end
    else if (IsTag(kiEND)) then
    begin
      Nodes.ActionTag := ParseTag(kiEND);

      if (not ErrorFound) then
        Nodes.Ident := ParseXID();

      if (not ErrorFound) then
        if (IsTag(kiSUSPEND, kiFOR, kiMIGRATE)) then
          Nodes.RestTag := ParseTag(kiSUSPEND, kiFOR, kiMIGRATE)
        else if (IsTag(kiSUSPEND)) then
          Nodes.RestTag := ParseTag(kiSUSPEND);
    end
    else if (IsTag(kiPREPARE)) then
    begin
      Nodes.ActionTag := ParseTag(kiPREPARE);

      if (not ErrorFound) then
        Nodes.Ident := ParseXID();
    end
    else if (IsTag(kiRECOVER)) then
    begin
      Nodes.ActionTag := ParseTag(kiRECOVER);

      if (not ErrorFound) then
        if (IsTag(kiCONVERT, kiXID)) then
          Nodes.RestTag := ParseTag(kiCONVERT, kiXID);
    end
    else if (IsTag(kiROLLBACK)) then
    begin
      Nodes.ActionTag := ParseTag(kiROLLBACK);

      if (not ErrorFound) then
        Nodes.Ident := ParseXID();
    end
    else if (EndOfStmt(CurrentToken)) then
      SetError(PE_IncompleteStmt)
    else
      SetError(PE_UnexpectedToken);

  Result := TXAStmt.Create(Self, Nodes);
end;

procedure TSQLParser.SaveToFile(const Filename: string; const FileType: TFileType = ftSQL);
begin
  if (not Assigned(Root)) then
    raise Exception.Create('Empty Buffer');
  case (FileType) of
    ftSQL:
      SaveToSQLFile(Filename);
    ftFormattedSQL:
      SaveToFormatedSQLFile(Filename);
    ftDebugHTML:
      SaveToDebugHTMLFile(Filename);
  end;
end;

function TSQLParser.RangePtr(const Node: TOffset): PRange;
begin
  Assert((0 < Node) and (Node < Nodes.UsedSize) and IsRange(Node));

  Result := PRange(@Nodes.Mem[Node]);
end;

procedure TSQLParser.SaveToDebugHTMLFile(const Filename: string);
var
  G: Integer;
  Generation: Integer;
  GenerationCount: Integer;
  Handle: THandle;
  HTML: string;
  FirstTokenIndex: Integer;
  LastTokenIndex: Integer;
  Length: Integer;
  Node: PNode;
  ParentNodes: Classes.TList;
  PreviousLastTokenIndex: Integer;
  S: string;
  Size: Cardinal;
  SQL: string;
  Stmt: PStmt;
  Text: PChar;
  Token: PToken;
begin
  Handle := CreateFile(PChar(Filename),
                       GENERIC_WRITE,
                       0,
                       nil,
                       CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

  if (Handle = INVALID_HANDLE_VALUE) then
    RaiseLastOSError()
  else
  begin
    if (not WriteFile(Handle, PChar(BOM_UNICODE_LE)^, System.Length(BOM_UNICODE_LE), Size, nil)) then
      RaiseLastOSError();

    HTML :=
      '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' + #13#10 +
      '<html>' + #13#10 +
      '  <head>' + #13#10 +
      '  <meta http-equiv="content-type" content="text/html">' + #13#10 +
      '  <title>Debug - SQL Parser</title>' + #13#10 +
      '  <style type="text/css">' + #13#10 +
      '    body {' + #13#10 +
      '      font: 12px Verdana,Arial,Sans-Serif;' + #13#10 +
      '      color: #000;' + #13#10 +
      '    }' + #13#10 +
      '    td {' + #13#10 +
      '      font: 12px Verdana,Arial,Sans-Serif;' + #13#10 +
      '    }' + #13#10 +
      '    a {' + #13#10 +
      '      text-decoration: none;' + #13#10 +
      '    }' + #13#10 +
      '    a:link span { display: none; }' + #13#10 +
      '    a:visited span { display: none; }' + #13#10 +
      '    a:hover span {' + #13#10 +
      '      display: block;' + #13#10 +
      '      position: absolute;' + #13#10 +
      '      margin: 18px 0px 0px 0px;' + #13#10 +
      '      background-color: #FFD;' + #13#10 +
      '      padding: 0px 2px 2px 1px;' + #13#10 +
      '      border: 1px solid #000;' + #13#10 +
      '      color: #000;' + #13#10 +
      '    }' + #13#10 +
      '    .Node {' + #13#10 +
      '      font-size: 11px;' + #13#10 +
      '      text-align: center;' + #13#10 +
      '      background-color: #F0F0F0;' + #13#10 +
      '    }' + #13#10 +
      '    .SQL {' + #13#10 +
      '      font-size: 12px;' + #13#10 +
      '      background-color: #F0F0F0;' + #13#10 +
      '      text-align: center;' + #13#10 +
      '    }' + #13#10 +
      '    .StmtOk {' + #13#10 +
      '      font-size: 12px;' + #13#10 +
      '      background-color: #D0FFD0;' + #13#10 +
      '      text-align: center;' + #13#10 +
      '    }' + #13#10 +
      '    .StmtError {' + #13#10 +
      '      font-size: 12px;' + #13#10 +
      '      background-color: #FFC0C0;' + #13#10 +
      '      text-align: center;' + #13#10 +
      '    }' + #13#10 +
      '    .ErrorMessage {' + #13#10 +
      '      font-size: 12px;' + #13#10 +
      '      color: #E82020;' + #13#10 +
      '      font-weight:bold;' + #13#10 +
      '    }' + #13#10 +
      '  </style>' + #13#10 +
      '  </head>' + #13#10 +
      '  <body>' + #13#10;

    if (not WriteFile(Handle, PChar(HTML)^, System.Length(HTML) * SizeOf(HTML[1]), Size, nil)) then
      RaiseLastOSError()
    else
      HTML := '';

    Stmt := Root^.FirstStmt;
    while (Assigned(Stmt)) do
    begin
      Token := Stmt^.FirstToken; GenerationCount := 0;
      while (Assigned(Token)) do
      begin
        G := 0;
        Node := Token^.ParentNode;
        while (IsChild(Node)) do
        begin
          Inc(G);
          Node := PChild(Node)^.ParentNode;
        end;
        if (G > GenerationCount) then
          GenerationCount := G;
        if (Token = Stmt^.LastToken) then
          Token := nil
        else
          Token := Token^.NextToken;
      end;

      ParentNodes := Classes.TList.Create();
      ParentNodes.Add(Root);

      HTML := HTML
        + '<table cellspacing="2" cellpadding="0" border="0">' + #13#10;

      for Generation := 1 to GenerationCount - 1 do
      begin
        HTML := HTML
          + '<tr>' + #13#10;
        Token := Stmt^.FirstToken;
        PreviousLastTokenIndex := Token^.Index - 1;
        while (Assigned(Token)) do
        begin
          G := 0;
          Node := Token^.ParentNode;
          while (IsChild(Node)) do
          begin
            Inc(G);
            Node := PChild(Node)^.ParentNode;
          end;
          Node := Token^.ParentNode;
          while (IsChild(Node) and (G > Generation)) do
          begin
            Dec(G);
            if (G > Generation) then
              Node := PChild(Node)^.ParentNode;
          end;
          if (IsChild(Node) and (G = Generation) and (ParentNodes.IndexOf(Node) < 1)) then
          begin
            if (IsToken(Node)) then
              FirstTokenIndex := Token^.Index
            else if (IsRange(Node)) then
              FirstTokenIndex := PRange(Node)^.FirstToken.Index
            else
              raise ERangeError.Create(SRangeError);
            if (IsToken(Node)) then
              LastTokenIndex := Token^.Index
            else if (IsRange(Node)) then
              LastTokenIndex := PRange(Node)^.LastToken.Index
            else
              raise ERangeError.Create(SRangeError);
            if (FirstTokenIndex - PreviousLastTokenIndex - 1 > 0) then
              HTML := HTML
                + '<td colspan="' + IntToStr(FirstTokenIndex - PreviousLastTokenIndex - 1) + '"></td>';
            HTML := HTML
              + '<td colspan="' + IntToStr(LastTokenIndex - FirstTokenIndex + 1) + '" class="Node">';
            HTML := HTML
              + '<a href="">'
              + HTMLEscape(NodeTypeToString[Node^.NodeType]);
            HTML := HTML
              + '<span><table cellspacing="2" cellpadding="0">';
            if (Assigned(PChild(Node)^.ParentNode)) then
              HTML := HTML
                + '<tr><td>ParentNode Offset:</td><td>&nbsp;</td><td>' + IntToStr(PChild(Node)^.ParentNode^.Offset) + '</td></tr>';
            HTML := HTML
              + '<tr><td>Offset:</td><td>&nbsp;</td><td>' + IntToStr(Node^.Offset) + '</td></tr>';
            if (IsStmt(Node)) then
              HTML := HTML + '<tr><td>StmtType:</td><td>&nbsp;</td><td>' + StmtTypeToString[PStmt(Node)^.StmtType] + '</td></tr>'
            else
              case (Node^.NodeType) of
                ntAlterRoutineStmt:
                  HTML := HTML
                    + '<tr><td>AlterRoutineType:</td><td>&nbsp;</td><td>' + RoutineTypeToString[PAlterRoutineStmt(Node)^.RoutineType] + '</td></tr>';
                ntBinaryOp:
                  HTML := HTML
                    + '<tr><td>OperatorType:</td><td>&nbsp;</td><td>' + OperatorTypeToString[PBinaryOp(Node)^.OperatorType] + '</td></tr>';
                ntCreateRoutineStmt:
                  HTML := HTML
                    + '<tr><td>RoutineType:</td><td>&nbsp;</td><td>' + RoutineTypeToString[PCreateRoutineStmt(Node)^.RoutineType] + '</td></tr>';
                ntDropRoutineStmt:
                  HTML := HTML
                    + '<tr><td>RoutineType:</td><td>&nbsp;</td><td>' + RoutineTypeToString[PDropRoutineStmt(Node)^.RoutineType] + '</td></tr>';
                ntDbIdent:
                  HTML := HTML
                    + '<tr><td>DbIdentType:</td><td>&nbsp;</td><td>' + DbIdentTypeToString[PDbIdent(Node)^.DbIdentType] + '</td></tr>';
                ntList:
                  begin
                    HTML := HTML
                      + '<tr><td>DelimiterType:</td><td>&nbsp;</td><td>' + HTMLEscape(TokenTypeToString[PList(Node)^.DelimiterType]) + '</td></tr>';
                    if (Assigned(PList(Node)^.FirstElement)) then
                      HTML := HTML
                        + '<tr><td>FirstElement Offset:</td><td>&nbsp;</td><td>' + IntToStr(PNode(PList(Node)^.FirstElement)^.Offset) + '</td></tr>'
                        + '<tr><td>ElementCount:</td><td>&nbsp;</td><td>' + IntToStr(PList(Node)^.ElementCount) + '<td></tr>';
                  end;
                ntSelectStmtTableJoin:
                  HTML := HTML
                    + '<tr><td>JoinType:</td><td>&nbsp;</td><td>' + JoinTypeToString[TSelectStmt.PTableJoin(Node)^.JoinType] + '</td></tr>';
              end;
            HTML := HTML
              + '</table></span>';
            HTML := HTML
              + '</a>';
            HTML := HTML
              + '</td>' + #13#10;

            ParentNodes.Add(Node);

            if (IsToken(Node)) then
              Token := PToken(Node)
            else if (IsRange(Node)) then
              Token := PRange(Node)^.LastToken
            else
              raise ERangeError.Create(SRangeError);

            PreviousLastTokenIndex := Token^.Index;
          end;

          if (Token <> Stmt^.LastToken) then
            Token := Token^.NextToken
          else
          begin
            if (Token^.Index - PreviousLastTokenIndex > 0) then
              HTML := HTML
                + '<td colspan="' + IntToStr(Token^.Index - PreviousLastTokenIndex) + '"></td>';
            Token := nil;
          end;
        end;
        HTML := HTML
          + '</tr>' + #13#10;
      end;

      ParentNodes.Free();


      if (Stmt^.ErrorCode <> PE_Success) then
        HTML := HTML
          + '<tr class="SQL">' + #13#10
      else
        HTML := HTML
          + '<tr class="StmtOk">' + #13#10;

      Token := Stmt^.FirstToken;
      while (Assigned(Token)) do
      begin
        Token^.GetText(Text, Length);
        SetString(S, Text, Length);
        HTML := HTML
          + '<td>';
        HTML := HTML
          + '<a href="">';
        HTML := HTML
          + '<code>' + HTMLEscape(ReplaceStr(S, ' ', '&nbsp;')) + '</code>';
        HTML := HTML
          + '<span><table cellspacing="2" cellpadding="0">';
        if (Assigned(PChild(Token)^.ParentNode)) then
          HTML := HTML + '<tr><td>ParentNode Offset:</td><td>&nbsp;</td><td>' + IntToStr(PChild(Token)^.ParentNode^.Offset) + '</td></tr>';
        HTML := HTML + '<tr><td>Offset:</td><td>&nbsp;</td><td>' + IntToStr(PNode(Token)^.Offset) + '</td></tr>';
        HTML := HTML + '<tr><td>TokenType:</td><td>&nbsp;</td><td>' + HTMLEscape(TokenTypeToString[Token^.TokenType]) + '</td></tr>';
        if (Token^.KeywordIndex >= 0) then
          HTML := HTML + '<tr><td>KeywordIndex:</td><td>&nbsp;</td><td>ki' + HTMLEscape(KeywordList[Token^.KeywordIndex]) + '</td></tr>';
        if (Token^.OperatorType <> otNone) then
          HTML := HTML + '<tr><td>OperatorType:</td><td>&nbsp;</td><td>' + HTMLEscape(OperatorTypeToString[Token^.OperatorType]) + '</td></tr>'
            + '<tr><td>OperatorPrecedence:</td><td>&nbsp;</td><td>' + IntToStr(OperatorPrecedenceByOperatorType[Token^.OperatorType]) + '</td></tr>';
        if (Token^.DbIdentType <> ditUnknown) then
          HTML := HTML + '<tr><td>DbIdentType:</td><td>&nbsp;</td><td>' + HTMLEscape(DbIdentTypeToString[Token^.DbIdentType]) + '</td></tr>';
        if ((Trim(Token^.AsString) <> '') and (Token^.KeywordIndex < 0)) then
          HTML := HTML + '<tr><td>AsString:</td><td>&nbsp;</td><td>' + HTMLEscape(Token^.AsString) + '</td></tr>';
        if (Token^.UsageType <> utUnknown) then
          HTML := HTML + '<tr><td>UsageType:</td><td>&nbsp;</td><td>' + HTMLEscape(UsageTypeToString[Token^.UsageType]) + '</td></tr>';
        HTML := HTML
          + '</table></span>';
        HTML := HTML
          + '</a></td>' + #13#10;

        if (Token = Stmt^.LastToken) then
          Token := nil
        else
          Token := Token.NextToken;
      end;
      HTML := HTML
        + '</tr>' + #13#10;

      if ((Stmt^.ErrorCode <> PE_Success) and (Stmt^.ErrorCode <> PE_IncompleteStmt) and Assigned(Stmt^.ErrorToken)) then
      begin
        HTML := HTML
          + '<tr>';
        if (Stmt^.ErrorToken^.Index - Stmt^.FirstToken^.Index > 0) then
          HTML := HTML
            + '<td colspan="' + IntToStr(Stmt^.ErrorToken^.Index - Stmt^.FirstToken^.Index) + '"></td>';
        HTML := HTML
          + '<td class="StmtError">&uarr;</td>';
        if (Stmt^.ErrorToken^.Index - Stmt^.LastToken^.Index > 0) then
          HTML := HTML
            + '<td colspan="' + IntToStr(Stmt^.LastToken^.Index - Stmt^.ErrorToken^.Index) + '"></td>';
        HTML := HTML
          + '</tr>' + #13#10;
      end;

      HTML := HTML
        + '</table>' + #13#10;

      if (Stmt^.ErrorCode <> PE_Success) then
        HTML := HTML
          + '<div class="ErrorMessage">' + HTMLEscape('Error: ' + ReplaceStr(ReplaceStr(Stmt^.ErrorMessage, #10, ''), #13, '')) + '</div>';

      Stmt := Stmt^.NextStmt;

      if (Assigned(Stmt)) then
        HTML := HTML
          + '<br><br>' + #13#10;

      if (not WriteFile(Handle, PChar(HTML)^, System.Length(HTML) * SizeOf(HTML[1]), Size, nil)) then
        RaiseLastOSError()
      else
        HTML := '';
    end;

    SQL := FormatSQL();
    HTML := HTML
      + '<br><br>'
      + '<code>' + HTMLEscape(ReplaceStr(SQL, ' ', '&nbsp;')) + '</code>';

    HTML := HTML
      + '    <br>' + #13#10
      + '    <br>' + #13#10
      + '  </body>' + #13#10
      + '</html>';

    if (not WriteFile(Handle, PChar(HTML)^, System.Length(HTML) * SizeOf(HTML[1]), Size, nil)) then
      RaiseLastOSError();

    if (not CloseHandle(Handle)) then
      RaiseLastOSError();
  end;
end;

procedure TSQLParser.SaveToFormatedSQLFile(const Filename: string);
var
  Handle: THandle;
  Size: Cardinal;
  SQL: string;
begin
  Handle := CreateFile(PChar(Filename),
                       GENERIC_WRITE,
                       0,
                       nil,
                       CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

  if (Handle = INVALID_HANDLE_VALUE) then
    RaiseLastOSError();

  SQL := FormatSQL();

  if (not WriteFile(Handle, PChar(BOM_UNICODE_LE)^, Length(BOM_UNICODE_LE), Size, nil)
    or not WriteFile(Handle, PChar(SQL)^, Length(SQL) * SizeOf(SQL[1]), Size, nil)
    or not CloseHandle(Handle)) then
    RaiseLastOSError();
end;

procedure TSQLParser.SaveToSQLFile(const Filename: string);
var
  Handle: THandle;
  Length: Integer;
  Size: Cardinal;
  StringBuffer: TStringBuffer;
  Text: PChar;
  Token: PToken;
begin
  StringBuffer := TStringBuffer.Create(1024);

  if (not Assigned(Root) or not IsToken(Root^.FFirstTokenAll)) then
    Token := nil
  else
    Token := TokenPtr(Root^.FFirstTokenAll);
  while (Assigned(Token)) do
  begin
    Token^.GetText(Text, Length);
    StringBuffer.Write(Text, Length);
    Token := Token^.NextTokenAll;
  end;

  Handle := CreateFile(PChar(Filename),
                       GENERIC_WRITE,
                       0,
                       nil,
                       CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

  if (Handle = INVALID_HANDLE_VALUE) then
    RaiseLastOSError();

  if (not WriteFile(Handle, PChar(BOM_UNICODE_LE)^, System.Length(BOM_UNICODE_LE), Size, nil)
    or not WriteFile(Handle, StringBuffer.Data^, StringBuffer.Size, Size, nil)
    or not CloseHandle(Handle)) then
    RaiseLastOSError();

  StringBuffer.Free();
end;

procedure TSQLParser.SetCharsets(ACharsets: string);
begin
  CharsetList.Text := ACharsets;
end;

procedure TSQLParser.SetDatatypes(ADatatypes: string);

  function IndexOf(const Word: PChar): Integer;
  begin
    Result := DatatypeList.IndexOf(Word, StrLen(Word));

    if (Result < 0) then
      raise ERangeError.CreateFmt(SDatatypeNotFound, [Word]);
  end;

begin
  DatatypeList.Text := ADatatypes;

  if (ADatatypes <> '') then
  begin
    diBIGINT               := IndexOf('BIGINT');
    diBINARY               := IndexOf('BINARY');
    diBIT                  := IndexOf('BIT');
    diBLOB                 := IndexOf('BLOB');
    diBOOL                 := IndexOf('BOOL');
    diBOOLEAN              := IndexOf('BOOLEAN');
    diBYTE                 := IndexOf('BYTE');
    diCHAR                 := IndexOf('CHAR');
    diCHARACTER            := IndexOf('CHARACTER');
    diDEC                  := IndexOf('DEC');
    diDECIMAL              := IndexOf('DECIMAL');
    diDATE                 := IndexOf('DATE');
    diDATETIME             := IndexOf('DATETIME');
    diDOUBLE               := IndexOf('DOUBLE');
    diENUM                 := IndexOf('ENUM');
    diFLOAT                := IndexOf('FLOAT');
    diGEOMETRY             := IndexOf('GEOMETRY');
    diGEOMETRYCOLLECTION   := IndexOf('GEOMETRYCOLLECTION');
    diINT                  := IndexOf('INT');
    diINT4                 := IndexOf('INT4');
    diINTEGER              := IndexOf('INTEGER');
    diJSON                 := IndexOf('JSON');
    diLARGEINT             := IndexOf('LARGEINT');
    diLINESTRING           := IndexOf('LINESTRING');
    diLONG                 := IndexOf('LONG');
    diLONGBLOB             := IndexOf('LONGBLOB');
    diLONGTEXT             := IndexOf('LONGTEXT');
    diMEDIUMBLOB           := IndexOf('MEDIUMBLOB');
    diMEDIUMINT            := IndexOf('MEDIUMINT');
    diMEDIUMTEXT           := IndexOf('MEDIUMTEXT');
    diMULTILINESTRING      := IndexOf('MULTILINESTRING');
    diMULTIPOINT           := IndexOf('MULTIPOINT');
    diMULTIPOLYGON         := IndexOf('MULTIPOLYGON');
    diNUMBER               := IndexOf('NUMBER');
    diNUMERIC              := IndexOf('NUMERIC');
    diNCHAR                := IndexOf('NCHAR');
    diNVARCHAR             := IndexOf('NVARCHAR');
    diPOINT                := IndexOf('POINT');
    diPOLYGON              := IndexOf('POLYGON');
    diREAL                 := IndexOf('REAL');
    diSERIAL               := IndexOf('SERIAL');
    diSET                  := IndexOf('SET');
    diSIGNED               := IndexOf('SIGNED');
    diSMALLINT             := IndexOf('SMALLINT');
    diTEXT                 := IndexOf('TEXT');
    diTIME                 := IndexOf('TIME');
    diTIMESTAMP            := IndexOf('TIMESTAMP');
    diTINYBLOB             := IndexOf('TINYBLOB');
    diTINYINT              := IndexOf('TINYINT');
    diTINYTEXT             := IndexOf('TINYTEXT');
    diUNSIGNED             := IndexOf('UNSIGNED');
    diVARBINARY            := IndexOf('VARBINARY');
    diVARCHAR              := IndexOf('VARCHAR');
    diYEAR                 := IndexOf('YEAR');
  end;
end;

function TSQLParser.SetError(const AErrorCode: Byte; const Node: TOffset = 0): TOffset;
const
  EmptyIndices: TWordList.TIndices = (-1, -1, -1, -1, -1, -1, -1);
var
  Found: Boolean;
  I: Integer;
  J: Integer;
  KeywordIndices: TWordList.TIndices;
  TokenCount: Integer;
  FoundTokenCount: Integer;
begin
  Assert(not ErrorFound and ((AErrorCode <> PE_IncompleteStmt) or (Node = 0)),
    'ErrorCode: ' + IntToStr(AErrorCode) + #13#10
    + Parse.SQL);

  Error.Code := AErrorCode;

  if (Node = 0) then
    Error.Token := CurrentToken
  else if (IsToken(Node)) then
    Error.Token := Node
  else if (IsRange(Node)) then
    Error.Token := RangePtr(Node)^.FFirstToken
  else
    raise ERangeError.Create(SRangeError);

  if (AErrorCode in [PE_UnexpectedToken, PE_ExtraToken]) then
  begin
    TokenCount := 0;
    for I := 0 to Length(KeywordIndices) -1 do
      if (((I = 0) or (I = TokenCount))
        and not EndOfStmt(NextToken[I]) and (TokenPtr(NextToken[I])^.KeywordIndex >= 0)) then
      begin
        KeywordIndices[I] := TokenPtr(NextToken[I])^.KeywordIndex;
        Inc(TokenCount);
      end
      else
        KeywordIndices[I] := - 1;

    FoundTokenCount := 0;
    for I := 0 to CompletionList.Count - 1 do
      for J := 0 to TokenCount - 1 do
        if (KeywordIndices[J] <> CompletionList[I]^.KeywordIndices[J]) then
          break
        else if (J + 1 > FoundTokenCount) then
          FoundTokenCount := J + 1;

    for I := CompletionList.Count - 1 downto 0 do
      if (CompletionList[I]^.ItemType = itTag) then
      begin
        Found := True;
        for J := 0 to FoundTokenCount - 1 do
          if ((CompletionList[I]^.KeywordIndices[J] <> KeywordIndices[J])) then
            Found := False;
        if (not Found) then
          CompletionList.Delete(I);
      end;

    Found := False;
    if (TokenCount > 0) then
      for J := 0 to CompletionList.Count - 1 do
        if (CompletionList[J]^.ItemType = itTag) then
        begin
          Found := True;

          if (FoundTokenCount > 0) then
          begin
            Move(CompletionList[J]^.KeywordIndices[FoundTokenCount], CompletionList[J]^.KeywordIndices[0], (Length(CompletionList[J]^.KeywordIndices) - FoundTokenCount) * SizeOf(CompletionList[J]^.KeywordIndices[0]));
            Move(EmptyIndices, CompletionList[J]^.KeywordIndices[Length(CompletionList[J]^.KeywordIndices) - FoundTokenCount], FoundTokenCount * SizeOf(CompletionList[J]^.KeywordIndices[0]));
          end;
        end;

    if (Found) then
      if (EndOfStmt(NextToken[FoundTokenCount])) then
      begin
        Error.Code := PE_IncompleteStmt;
        Error.Token := 0;
      end
      else
        Error.Token := NextToken[FoundTokenCount];
  end;

  if (Error.Code = PE_InvalidMySQLCond) then
    Error.Line := Parse.Line
  else
    for I := 0 to TokenBuffer.Count - 1 do
      if (Error.Token = TokenBuffer.Items[I].Token) then
      begin
        Error.Line := TokenBuffer.Items[I].Error.Line;
        Error.Pos := TokenBuffer.Items[I].Error.Pos;
      end;

  if (FirstError.Code = PE_Success) then
    FirstError := Error;

  Result := 0;
end;

procedure TSQLParser.SetKeywords(AKeywords: string);

  function IndexOf(const Word: PChar): Integer;
  begin
    Result := KeywordList.IndexOf(Word, StrLen(Word));

    if (Result < 0) then
      raise ERangeError.CreateFmt(SKeywordNotFound, [Word]);
  end;

var
  Index: Integer;
begin
  KeywordList.Text := AKeywords;

  if (AKeywords <> '') then
  begin
    kiACCOUNT                       := IndexOf('ACCOUNT');
    kiACTION                        := IndexOf('ACTION');
    kiADD                           := IndexOf('ADD');
    kiAFTER                         := IndexOf('AFTER');
    kiAGAINST                       := IndexOf('AGAINST');
    kiALGORITHM                     := IndexOf('ALGORITHM');
    kiALL                           := IndexOf('ALL');
    kiALTER                         := IndexOf('ALTER');
    kiALWAYS                        := IndexOf('ALWAYS');
    kiANALYZE                       := IndexOf('ANALYZE');
    kiAND                           := IndexOf('AND');
    kiANY                           := IndexOf('ANY');
    kiAS                            := IndexOf('AS');
    kiASC                           := IndexOf('ASC');
    kiASCII                         := IndexOf('ASCII');
    kiAT                            := IndexOf('AT');
    kiAUTO_INCREMENT                := IndexOf('AUTO_INCREMENT');
    kiAVG_ROW_LENGTH                := IndexOf('AVG_ROW_LENGTH');
    kiBEFORE                        := IndexOf('BEFORE');
    kiBEGIN                         := IndexOf('BEGIN');
    kiBETWEEN                       := IndexOf('BETWEEN');
    kiBINARY                        := IndexOf('BINARY');
    kiBINLOG                        := IndexOf('BINLOG');
    kiBLOCK                         := IndexOf('BLOCK');
    kiBOOLEAN                       := IndexOf('BOOLEAN');
    kiBOTH                          := IndexOf('BOTH');
    kiBTREE                         := IndexOf('BTREE');
    kiBY                            := IndexOf('BY');
    kiCACHE                         := IndexOf('CACHE');
    kiCALL                          := IndexOf('CALL');
    kiCASCADE                       := IndexOf('CASCADE');
    kiCASCADED                      := IndexOf('CASCADED');
    kiCASE                          := IndexOf('CASE');
    kiCATALOG_NAME                  := IndexOf('CATALOG_NAME');
    kiCHANGE                        := IndexOf('CHANGE');
    kiCHANGED                       := IndexOf('CHANGED');
    kiCHANNEL                       := IndexOf('CHANNEL');
    kiCHAIN                         := IndexOf('CHAIN');
    kiCHARACTER                     := IndexOf('CHARACTER');
    kiCHARSET                       := IndexOf('CHARSET');
    kiCHECK                         := IndexOf('CHECK');
    kiCHECKSUM                      := IndexOf('CHECKSUM');
    kiCLASS_ORIGIN                  := IndexOf('CLASS_ORIGIN');
    kiCLIENT                        := IndexOf('CLIENT');
    kiCLOSE                         := IndexOf('CLOSE');
    kiCOALESCE                      := IndexOf('COALESCE');
    kiCODE                          := IndexOf('CODE');
    kiCOLLATE                       := IndexOf('COLLATE');
    kiCOLLATION                     := IndexOf('COLLATION');
    kiCOLUMN                        := IndexOf('COLUMN');
    kiCOLUMN_NAME                   := IndexOf('COLUMN_NAME');
    kiCOLUMN_FORMAT                 := IndexOf('COLUMN_FORMAT');
    kiCOLUMNS                       := IndexOf('COLUMNS');
    kiCOMMENT                       := IndexOf('COMMENT');
    kiCOMMIT                        := IndexOf('COMMIT');
    kiCOMMITTED                     := IndexOf('COMMITTED');
    kiCOMPACT                       := IndexOf('COMPACT');
    kiCOMPLETION                    := IndexOf('COMPLETION');
    kiCOMPRESSED                    := IndexOf('COMPRESSED');
    kiCONCURRENT                    := IndexOf('CONCURRENT');
    kiCONNECTION                    := IndexOf('CONNECTION');
    kiCONDITION                     := IndexOf('CONDITION');
    kiCONSISTENT                    := IndexOf('CONSISTENT');
    kiCONSTRAINT                    := IndexOf('CONSTRAINT');
    kiCONSTRAINT_CATALOG            := IndexOf('CONSTRAINT_CATALOG');
    kiCONSTRAINT_NAME               := IndexOf('CONSTRAINT_NAME');
    kiCONSTRAINT_SCHEMA             := IndexOf('CONSTRAINT_SCHEMA');
    kiCONTAINS                      := IndexOf('CONTAINS');
    kiCONTEXT                       := IndexOf('CONTEXT');
    kiCONTINUE                      := IndexOf('CONTINUE');
    kiCONVERT                       := IndexOf('CONVERT');
    kiCOPY                          := IndexOf('COPY');
    kiCPU                           := IndexOf('CPU');
    kiCREATE                        := IndexOf('CREATE');
    kiCROSS                         := IndexOf('CROSS');
    kiCURRENT                       := IndexOf('CURRENT');
    kiCURRENT_DATE                  := IndexOf('CURRENT_DATE');
    kiCURRENT_TIME                  := IndexOf('CURRENT_TIME');
    kiCURRENT_TIMESTAMP             := IndexOf('CURRENT_TIMESTAMP');
    kiCURRENT_USER                  := IndexOf('CURRENT_USER');
    kiCURSOR                        := IndexOf('CURSOR');
    kiCURSOR_NAME                   := IndexOf('CURSOR_NAME');
    kiDATA                          := IndexOf('DATA');
    kiDATABASE                      := IndexOf('DATABASE');
    kiDATABASES                     := IndexOf('DATABASES');
    kiDATAFILE                      := IndexOf('DATAFILE');
    kiDAY                           := IndexOf('DAY');
    kiDAY_HOUR                      := IndexOf('DAY_HOUR');
    kiDAY_MICROSECOND               := IndexOf('DAY_MICROSECOND');
    kiDAY_MINUTE                    := IndexOf('DAY_MINUTE');
    kiDAY_SECOND                    := IndexOf('DAY_SECOND');
    kiDEALLOCATE                    := IndexOf('DEALLOCATE');
    kiDECLARE                       := IndexOf('DECLARE');
    kiDEFAULT                       := IndexOf('DEFAULT');
    kiDEFINER                       := IndexOf('DEFINER');
    kiDELAY_KEY_WRITE               := IndexOf('DELAY_KEY_WRITE');
    kiDELAYED                       := IndexOf('DELAYED');
    kiDELETE                        := IndexOf('DELETE');
    kiDESC                          := IndexOf('DESC');
    kiDESCRIBE                      := IndexOf('DESCRIBE');
    kiDETERMINISTIC                 := IndexOf('DETERMINISTIC');
    kiDIAGNOSTICS                   := IndexOf('DIAGNOSTICS');
    kiDIRECTORY                     := IndexOf('DIRECTORY');
    kiDISABLE                       := IndexOf('DISABLE');
    kiDISCARD                       := IndexOf('DISCARD');
    kiDISK                          := IndexOf('DISK');
    kiDISTINCT                      := IndexOf('DISTINCT');
    kiDISTINCTROW                   := IndexOf('DISTINCTROW');
    kiDIV                           := IndexOf('DIV');
    kiDO                            := IndexOf('DO');
    kiDROP                          := IndexOf('DROP');
    kiDUAL                          := IndexOf('DUAL');
    kiDUMPFILE                      := IndexOf('DUMPFILE');
    kiDUPLICATE                     := IndexOf('DUPLICATE');
    kiDYNAMIC                       := IndexOf('DYNAMIC');
    kiEACH                          := IndexOf('EACH');
    kiELSE                          := IndexOf('ELSE');
    kiELSEIF                        := IndexOf('ELSEIF');
    kiENABLE                        := IndexOf('ENABLE');
    kiENABLE                        := IndexOf('ENABLE');
    kiENCLOSED                      := IndexOf('ENCLOSED');
    kiEND                           := IndexOf('END');
    kiENDS                          := IndexOf('ENDS');
    kiENGINE                        := IndexOf('ENGINE');
    kiENGINES                       := IndexOf('ENGINES');
    kiEVENT                         := IndexOf('EVENT');
    kiEVENTS                        := IndexOf('EVENTS');
    kiERROR                         := IndexOf('ERROR');
    kiERRORS                        := IndexOf('ERRORS');
    kiESCAPE                        := IndexOf('ESCAPE');
    kiESCAPED                       := IndexOf('ESCAPED');
    kiEVERY                         := IndexOf('EVERY');
    kiEXCHANGE                      := IndexOf('EXCHANGE');
    kiEXCLUSIVE                     := IndexOf('EXCLUSIVE');
    kiEXECUTE                       := IndexOf('EXECUTE');
    kiEXISTS                        := IndexOf('EXISTS');
    kiEXPANSION                     := IndexOf('EXPANSION');
    kiEXPIRE                        := IndexOf('EXPIRE');
    kiEXPLAIN                       := IndexOf('EXPLAIN');
    kiEXIT                          := IndexOf('EXIT');
    kiEXTENDED                      := IndexOf('EXTENDED');
    kiFALSE                         := IndexOf('FALSE');
    kiFAST                          := IndexOf('FAST');
    kiFAULTS                        := IndexOf('FAULTS');
    kiFETCH                         := IndexOf('FETCH');
    kiFILE_BLOCK_SIZE               := IndexOf('FILE_BLOCK_SIZE');
    kiFLUSH                         := IndexOf('FLUSH');
    kiFIELDS                        := IndexOf('FIELDS');
    kiFILE                          := IndexOf('FILE');
    kiFIRST                         := IndexOf('FIRST');
    kiFIXED                         := IndexOf('FIXED');
    kiFOLLOWS                       := IndexOf('FOLLOWS');
    kiFOR                           := IndexOf('FOR');
    kiFORCE                         := IndexOf('FORCE');
    kiFOREIGN                       := IndexOf('FOREIGN');
    kiFORMAT                        := IndexOf('FORMAT');
    kiFOUND                         := IndexOf('FOUND');
    kiFROM                          := IndexOf('FROM');
    kiFULL                          := IndexOf('FULL');
    kiFULLTEXT                      := IndexOf('FULLTEXT');
    kiFUNCTION                      := IndexOf('FUNCTION');
    kiGENERAL                       := IndexOf('GENERAL');
    kiGENERATED                     := IndexOf('GENERATED');
    kiGET                           := IndexOf('GET');
    kiGLOBAL                        := IndexOf('GLOBAL');
    kiGRANT                         := IndexOf('GRANT');
    kiGRANTS                        := IndexOf('GRANTS');
    kiGROUP                         := IndexOf('GROUP');
    kiHANDLER                       := IndexOf('HANDLER');
    kiHASH                          := IndexOf('HASH');
    kiHAVING                        := IndexOf('HAVING');
    kiHELP                          := IndexOf('HELP');
    kiHIGH_PRIORITY                 := IndexOf('HIGH_PRIORITY');
    kiHOST                          := IndexOf('HOST');
    kiHOSTS                         := IndexOf('HOSTS');
    kiHOUR                          := IndexOf('HOUR');
    kiHOUR_MICROSECOND              := IndexOf('HOUR_MICROSECOND');
    kiHOUR_MINUTE                   := IndexOf('HOUR_MINUTE');
    kiHOUR_SECOND                   := IndexOf('HOUR_SECOND');
    kiIDENTIFIED                    := IndexOf('IDENTIFIED');
    kiIF                            := IndexOf('IF');
    kiIGNORE                        := IndexOf('IGNORE');
    kiIGNORE_SERVER_IDS             := IndexOf('IGNORE_SERVER_IDS');
    kiIMPORT                        := IndexOf('IMPORT');
    kiIN                            := IndexOf('IN');
    kiINDEX                         := IndexOf('INDEX');
    kiINDEXES                       := IndexOf('INDEXES');
    kiINITIAL_SIZE                  := IndexOf('INITIAL_SIZE');
    kiINNER                         := IndexOf('INNER');
    kiINFILE                        := IndexOf('INFILE');
    kiINNODB                        := IndexOf('INNODB');
    kiINOUT                         := IndexOf('INOUT');
    kiINPLACE                       := IndexOf('INPLACE');
    kiINSTANCE                      := IndexOf('INSTANCE');
    kiINSERT                        := IndexOf('INSERT');
    kiINSERT_METHOD                 := IndexOf('INSERT_METHOD');
    kiINSTALL                       := IndexOf('INSTALL');
    kiINTERVAL                      := IndexOf('INTERVAL');
    kiINTO                          := IndexOf('INTO');
    kiINVOKER                       := IndexOf('INVOKER');
    kiIO                            := IndexOf('IO');
    kiIPC                           := IndexOf('IPC');
    kiIS                            := IndexOf('IS');
    kiISOLATION                     := IndexOf('ISOLATION');
    kiITERATE                       := IndexOf('ITERATE');
    kiJOIN                          := IndexOf('JOIN');
    kiJSON                          := IndexOf('JSON');
    kiKEY                           := IndexOf('KEY');
    kiKEY_BLOCK_SIZE                := IndexOf('KEY_BLOCK_SIZE');
    kiKEYS                          := IndexOf('KEYS');
    kiKILL                          := IndexOf('KILL');
    kiLANGUAGE                      := IndexOf('LANGUAGE');
    kiLAST                          := IndexOf('LAST');
    kiLEADING                       := IndexOf('LEADING');
    kiLEAVE                         := IndexOf('LEAVE');
    kiLEFT                          := IndexOf('LEFT');
    kiLESS                          := IndexOf('LESS');
    kiLEVEL                         := IndexOf('LEVEL');
    kiLIKE                          := IndexOf('LIKE');
    kiLIMIT                         := IndexOf('LIMIT');
    kiLINEAR                        := IndexOf('LINEAR');
    kiLINES                         := IndexOf('LINES');
    kiLIST                          := IndexOf('LIST');
    kiLOGS                          := IndexOf('LOGS');
    kiLOAD                          := IndexOf('LOAD');
    kiLOCAL                         := IndexOf('LOCAL');
    kiLOCK                          := IndexOf('LOCK');
    kiLOOP                          := IndexOf('LOOP');
    kiLOW_PRIORITY                  := IndexOf('LOW_PRIORITY');
    kiMASTER                        := IndexOf('MASTER');
    kiMASTER_AUTO_POSITION          := IndexOf('MASTER_AUTO_POSITION');
    kiMASTER_BIND                   := IndexOf('MASTER_BIND');
    kiMASTER_CONNECT_RETRY          := IndexOf('MASTER_CONNECT_RETRY');
    kiMASTER_DELAY                  := IndexOf('MASTER_DELAY');
    kiMASTER_HEARTBEAT_PERIOD       := IndexOf('MASTER_HEARTBEAT_PERIOD');
    kiMASTER_HOST                   := IndexOf('MASTER_HOST');
    kiMASTER_LOG_FILE               := IndexOf('MASTER_LOG_FILE');
    kiMASTER_LOG_POS                := IndexOf('MASTER_LOG_POS');
    kiMASTER_PASSWORD               := IndexOf('MASTER_PASSWORD');
    kiMASTER_PORT                   := IndexOf('MASTER_PORT');
    kiMASTER_RETRY_COUNT            := IndexOf('MASTER_RETRY_COUNT');
    kiMASTER_SSL                    := IndexOf('MASTER_SSL');
    kiMASTER_SSL_CA                 := IndexOf('MASTER_SSL_CA');
    kiMASTER_SSL_CAPATH             := IndexOf('MASTER_SSL_CAPATH');
    kiMASTER_SSL_CERT               := IndexOf('MASTER_SSL_CERT');
    kiMASTER_SSL_CIPHER             := IndexOf('MASTER_SSL_CIPHER');
    kiMASTER_SSL_CRL                := IndexOf('MASTER_SSL_CRL');
    kiMASTER_SSL_CRLPATH            := IndexOf('MASTER_SSL_CRLPATH');
    kiMASTER_SSL_KEY                := IndexOf('MASTER_SSL_KEY');
    kiMASTER_SSL_VERIFY_SERVER_CERT := IndexOf('MASTER_SSL_VERIFY_SERVER_CERT');
    kiMASTER_TLS_VERSION            := IndexOf('MASTER_TLS_VERSION');
    kiMASTER_USER                   := IndexOf('MASTER_USER');
    kiMATCH                         := IndexOf('MATCH');
    kiMAX_CONNECTIONS_PER_HOUR      := IndexOf('MAX_CONNECTIONS_PER_HOUR');
    kiMAX_QUERIES_PER_HOUR          := IndexOf('MAX_QUERIES_PER_HOUR');
    kiMAX_ROWS                      := IndexOf('MAX_ROWS');
    kiMAX_STATEMENT_TIME            := IndexOf('MAX_STATEMENT_TIME');
    kiMAX_UPDATES_PER_HOUR          := IndexOf('MAX_UPDATES_PER_HOUR');
    kiMAX_USER_CONNECTIONS          := IndexOf('MAX_USER_CONNECTIONS');
    kiMAXVALUE                      := IndexOf('MAXVALUE');
    kiMEDIUM                        := IndexOf('MEDIUM');
    kiMEMORY                        := IndexOf('MEMORY');
    kiMERGE                         := IndexOf('MERGE');
    kiMESSAGE_TEXT                  := IndexOf('MESSAGE_TEXT');
    kiMICROSECOND                   := IndexOf('MICROSECOND');
    kiMIGRATE                       := IndexOf('MIGRATE');
    kiMIN_ROWS                      := IndexOf('MIN_ROWS');
    kiMINUTE                        := IndexOf('MINUTE');
    kiMINUTE_SECOND                 := IndexOf('MINUTE_SECOND');
    kiMINUTE_MICROSECOND            := IndexOf('MINUTE_MICROSECOND');
    kiMOD                           := IndexOf('MOD');
    kiMODE                          := IndexOf('MODE');
    kiMODIFIES                      := IndexOf('MODIFIES');
    kiMODIFY                        := IndexOf('MODIFY');
    kiMONTH                         := IndexOf('MONTH');
    kiMUTEX                         := IndexOf('MUTEX');
    kiMYSQL_ERRNO                   := IndexOf('MYSQL_ERRNO');
    kiNAME                          := IndexOf('NAME');
    kiNAMES                         := IndexOf('NAMES');
    kiNATIONAL                      := IndexOf('NATIONAL');
    kiNATURAL                       := IndexOf('NATURAL');
    kiNEVER                         := IndexOf('NEVER');
    kiNEW                           := IndexOf('NEW');
    kiNEXT                          := IndexOf('NEXT');
    kiNO                            := IndexOf('NO');
    kiNONE                          := IndexOf('NONE');
    kiNOT                           := IndexOf('NOT');
    kiNO_WRITE_TO_BINLOG            := IndexOf('NO_WRITE_TO_BINLOG');
    kiNULL                          := IndexOf('NULL');
    kiNUMBER                        := IndexOf('NUMBER');
    kiOFFSET                        := IndexOf('OFFSET');
    kiOJ                            := IndexOf('OJ');
    kiOLD                           := IndexOf('OLD');
    kiON                            := IndexOf('ON');
    kiONE                           := IndexOf('ONE');
    kiONLINE                        := IndexOf('ONLINE');
    kiONLY                          := IndexOf('ONLY');
    kiOPEN                          := IndexOf('OPEN');
    kiOPTIMIZE                      := IndexOf('OPTIMIZE');
    kiOPTION                        := IndexOf('OPTION');
    kiOPTIONALLY                    := IndexOf('OPTIONALLY');
    kiOPTIONS                       := IndexOf('OPTIONS');
    kiOR                            := IndexOf('OR');
    kiORDER                         := IndexOf('ORDER');
    kiOUT                           := IndexOf('OUT');
    kiOUTER                         := IndexOf('OUTER');
    kiOUTFILE                       := IndexOf('OUTFILE');
    kiOWNER                         := IndexOf('OWNER');
    kiPACK_KEYS                     := IndexOf('PACK_KEYS');
    kiPAGE                          := IndexOf('PAGE');
    kiPAGE_CHECKSUM                 := IndexOf('PAGE_CHECKSUM');
    kiPARSER                        := IndexOf('PARSER');
    kiPARTIAL                       := IndexOf('PARTIAL');
    kiPARTITION                     := IndexOf('PARTITION');
    kiPARTITIONING                  := IndexOf('PARTITIONING');
    kiPARTITIONS                    := IndexOf('PARTITIONS');
    kiPASSWORD                      := IndexOf('PASSWORD');
    kiPERSISTENT                    := IndexOf('PERSISTENT');
    kiPHASE                         := IndexOf('PHASE');
    kiPLUGIN                        := IndexOf('PLUGIN');
    kiQUERY                         := IndexOf('QUERY');
    kiRECOVER                       := IndexOf('RECOVER');
    kiREDUNDANT                     := IndexOf('REDUNDANT');
    kiPLUGIN                        := IndexOf('PLUGIN');
    kiPLUGINS                       := IndexOf('PLUGINS');
    kiPORT                          := IndexOf('PORT');
    kiPRECEDES                      := IndexOf('PRECEDES');
    kiPREPARE                       := IndexOf('PREPARE');
    kiPRESERVE                      := IndexOf('PRESERVE');
    kiPRIMARY                       := IndexOf('PRIMARY');
    kiPRIVILEGES                    := IndexOf('PRIVILEGES');
    kiPROCEDURE                     := IndexOf('PROCEDURE');
    kiPROCESS                       := IndexOf('PROCESS');
    kiPROCESSLIST                   := IndexOf('PROCESSLIST');
    kiPROFILE                       := IndexOf('PROFILE');
    kiPROFILES                      := IndexOf('PROFILES');
    kiPROXY                         := IndexOf('PROXY');
    kiPURGE                         := IndexOf('PURGE');
    kiQUARTER                       := IndexOf('QUARTER');
    kiQUICK                         := IndexOf('QUICK');
    kiRANGE                         := IndexOf('RANGE');
    kiREAD                          := IndexOf('READ');
    kiREADS                         := IndexOf('READS');
    kiREBUILD                       := IndexOf('REBUILD');
    kiREFERENCES                    := IndexOf('REFERENCES');
    kiREGEXP                        := IndexOf('REGEXP');
    kiRELAY_LOG_FILE                := IndexOf('RELAY_LOG_FILE');
    kiRELAY_LOG_POS                 := IndexOf('RELAY_LOG_POS');
    kiRELAY                         := IndexOf('RELAY');
    kiRELAYLOG                      := IndexOf('RELAYLOG');
    kiRELEASE                       := IndexOf('RELEASE');
    kiRELOAD                        := IndexOf('RELOAD');
    kiREMOVE                        := IndexOf('REMOVE');
    kiRENAME                        := IndexOf('RENAME');
    kiREORGANIZE                    := IndexOf('REORGANIZE');
    kiREPEAT                        := IndexOf('REPEAT');
    kiREPLICATION                   := IndexOf('REPLICATION');
    kiREPAIR                        := IndexOf('REPAIR');
    kiREPEATABLE                    := IndexOf('REPEATABLE');
    kiREPLACE                       := IndexOf('REPLACE');
    kiREQUIRE                       := IndexOf('REQUIRE');
    kiRESET                         := IndexOf('RESET');
    kiRESIGNAL                      := IndexOf('RESIGNAL');
    kiRESTRICT                      := IndexOf('RESTRICT');
    kiRESUME                        := IndexOf('RESUME');
    kiRETURN                        := IndexOf('RETURN');
    kiRETURNED_SQLSTATE             := IndexOf('RETURNED_SQLSTATE');
    kiRETURNS                       := IndexOf('RETURNS');
    kiREVERSE                       := IndexOf('REVERSE');
    kiREVOKE                        := IndexOf('REVOKE');
    kiRIGHT                         := IndexOf('RIGHT');
    kiRLIKE                         := IndexOf('RLIKE');
    kiROLLBACK                      := IndexOf('ROLLBACK');
    kiROLLUP                        := IndexOf('ROLLUP');
    kiROTATE                        := IndexOf('ROTATE');
    kiROUTINE                       := IndexOf('ROUTINE');
    kiROW                           := IndexOf('ROW');
    kiROW_COUNT                     := IndexOf('ROW_COUNT');
    kiROW_FORMAT                    := IndexOf('ROW_FORMAT');
    kiROWS                          := IndexOf('ROWS');
    kiSAVEPOINT                     := IndexOf('SAVEPOINT');
    kiSCHEDULE                      := IndexOf('SCHEDULE');
    kiSCHEMA                        := IndexOf('SCHEMA');
    kiSCHEMA_NAME                   := IndexOf('SCHEMA_NAME');
    kiSECOND                        := IndexOf('SECOND');
    kiSECOND_MICROSECOND            := IndexOf('SECOND_MICROSECOND');
    kiSECURITY                      := IndexOf('SECURITY');
    kiSELECT                        := IndexOf('SELECT');
    kiSEPARATOR                     := IndexOf('SEPARATOR');
    kiSERIALIZABLE                  := IndexOf('SERIALIZABLE');
    kiSERVER                        := IndexOf('SERVER');
    kiSESSION                       := IndexOf('SESSION');
    kiSET                           := IndexOf('SET');
    kiSHARE                         := IndexOf('SHARE');
    kiSHARED                        := IndexOf('SHARED');
    kiSHOW                          := IndexOf('SHOW');
    kiSHUTDOWN                      := IndexOf('SHUTDOWN');
    kiSIGNAL                        := IndexOf('SIGNAL');
    kiSIGNED                        := IndexOf('SIGNED');
    kiSIMPLE                        := IndexOf('SIMPLE');
    kiSLAVE                         := IndexOf('SLAVE');
    kiSLOW                          := IndexOf('SLOW');
    kiSNAPSHOT                      := IndexOf('SNAPSHOT');
    kiSOCKET                        := IndexOf('SOCKET');
    kiSOME                          := IndexOf('SOME');
    kiSONAME                        := IndexOf('SONAME');
    kiSOUNDS                        := IndexOf('SOUNDS');
    kiSOURCE                        := IndexOf('SOURCE');
    kiSPATIAL                       := IndexOf('SPATIAL');
    kiSQL                           := IndexOf('SQL');
    kiSQL_BIG_RESULT                := IndexOf('SQL_BIG_RESULT');
    kiSQL_BUFFER_RESULT             := IndexOf('SQL_BUFFER_RESULT');
    kiSQL_CACHE                     := IndexOf('SQL_CACHE');
    kiSQL_CALC_FOUND_ROWS           := IndexOf('SQL_CALC_FOUND_ROWS');
    kiSQL_NO_CACHE                  := IndexOf('SQL_NO_CACHE');
    kiSQL_SMALL_RESULT              := IndexOf('SQL_SMALL_RESULT');
    kiSQL_TSI_MICROSECOND           := IndexOf('SQL_TSI_MICROSECOND');
    kiSQL_TSI_SECOND                := IndexOf('SQL_TSI_SECOND');
    kiSQL_TSI_MINUTE                := IndexOf('SQL_TSI_MINUTE');
    kiSQL_TSI_HOUR                  := IndexOf('SQL_TSI_HOUR');
    kiSQL_TSI_DAY                   := IndexOf('SQL_TSI_DAY');
    kiSQL_TSI_WEEK                  := IndexOf('SQL_TSI_WEEK');
    kiSQL_TSI_MONTH                 := IndexOf('SQL_TSI_MONTH');
    kiSQL_TSI_QUARTER               := IndexOf('SQL_TSI_QUARTER');
    kiSQL_TSI_YEAR                  := IndexOf('SQL_TSI_YEAR');
    kiSQLEXCEPTION                  := IndexOf('SQLEXCEPTION');
    kiSQLSTATE                      := IndexOf('SQLSTATE');
    kiSQLWARNING                    := IndexOf('SQLWARNING');
    kiSTACKED                       := IndexOf('STACKED');
    kiSTARTING                      := IndexOf('STARTING');
    kiSTART                         := IndexOf('START');
    kiSTARTS                        := IndexOf('STARTS');
    kiSTATS_AUTO_RECALC             := IndexOf('STATS_AUTO_RECALC');
    kiSTATS_PERSISTENT              := IndexOf('STATS_PERSISTENT');
    kiSTATS_SAMPLE_PAGES            := IndexOf('STATS_SAMPLE_PAGES');
    kiSTATUS                        := IndexOf('STATUS');
    kiSTOP                          := IndexOf('STOP');
    kiSTORAGE                       := IndexOf('STORAGE');
    kiSTORED                        := IndexOf('STORED');
    kiSTRAIGHT_JOIN                 := IndexOf('STRAIGHT_JOIN');
    kiSUBCLASS_ORIGIN               := IndexOf('SUBCLASS_ORIGIN');
    kiSUBPARTITION                  := IndexOf('SUBPARTITION');
    kiSUBPARTITIONS                 := IndexOf('SUBPARTITIONS');
    kiSUPER                         := IndexOf('SUPER');
    kiSUSPEND                       := IndexOf('SUSPEND');
    kiSWAPS                         := IndexOf('SWAPS');
    kiSWITCHES                      := IndexOf('SWITCHES');
    kiTABLE                         := IndexOf('TABLE');
    kiTABLE_CHECKSUM                := IndexOf('TABLE_CHECKSUM');
    kiTABLE_NAME                    := IndexOf('TABLE_NAME');
    kiTABLES                        := IndexOf('TABLES');
    kiTABLESPACE                    := IndexOf('TABLESPACE');
    kiTEMPORARY                     := IndexOf('TEMPORARY');
    kiTEMPTABLE                     := IndexOf('TEMPTABLE');
    kiTERMINATED                    := IndexOf('TERMINATED');
    kiTHAN                          := IndexOf('THAN');
    kiTHEN                          := IndexOf('THEN');
    kiTO                            := IndexOf('TO');
    kiTRAILING                      := IndexOf('TRAILING');
    kiTRADITIONAL                   := IndexOf('TRADITIONAL');
    kiTRANSACTION                   := IndexOf('TRANSACTION');
    kiTRANSACTIONAL                 := IndexOf('TRANSACTIONAL');
    kiTRIGGER                       := IndexOf('TRIGGER');
    kiTRIGGERS                      := IndexOf('TRIGGERS');
    kiTRUNCATE                      := IndexOf('TRUNCATE');
    kiTRUE                          := IndexOf('TRUE');
    kiTYPE                          := IndexOf('TYPE');
    kiUNCOMMITTED                   := IndexOf('UNCOMMITTED');
    kiUNDEFINED                     := IndexOf('UNDEFINED');
    kiUNDO                          := IndexOf('UNDO');
    kiUNICODE                       := IndexOf('UNICODE');
    kiUNINSTALL                     := IndexOf('UNINSTALL');
    kiUNION                         := IndexOf('UNION');
    kiUNIQUE                        := IndexOf('UNIQUE');
    kiUNKNOWN                       := IndexOf('UNKNOWN');
    kiUNLOCK                        := IndexOf('UNLOCK');
    kiUNSIGNED                      := IndexOf('UNSIGNED');
    kiUNTIL                         := IndexOf('UNTIL');
    kiUPDATE                        := IndexOf('UPDATE');
    kiUPGRADE                       := IndexOf('UPGRADE');
    kiUSAGE                         := IndexOf('USAGE');
    kiUSE                           := IndexOf('USE');
    kiUSE_FRM                       := IndexOf('USE_FRM');
    kiUSER                          := IndexOf('USER');
    kiUSING                         := IndexOf('USING');
    kiVALIDATION                    := IndexOf('VALIDATION');
    kiVALUE                         := IndexOf('VALUE');
    kiVALUES                        := IndexOf('VALUES');
    kiVARIABLES                     := IndexOf('VARIABLES');
    kiVIEW                          := IndexOf('VIEW');
    kiVIRTUAL                       := IndexOf('VIRTUAL');
    kiWAIT                          := IndexOf('WAIT');
    kiWARNINGS                      := IndexOf('WARNINGS');
    kiWEEK                          := IndexOf('WEEK');
    kiWHEN                          := IndexOf('WHEN');
    kiWHERE                         := IndexOf('WHERE');
    kiWHILE                         := IndexOf('WHILE');
    kiWRAPPER                       := IndexOf('WRAPPER');
    kiWITH                          := IndexOf('WITH');
    kiWITHOUT                       := IndexOf('WITHOUT');
    kiWORK                          := IndexOf('WORK');
    kiWRITE                         := IndexOf('WRITE');
    kiXA                            := IndexOf('XA');
    kiXID                           := IndexOf('XID');
    kiXML                           := IndexOf('XML');
    kiXOR                           := IndexOf('XOR');
    kiYEAR                          := IndexOf('YEAR');
    kiYEAR_MONTH                    := IndexOf('YEAR_MONTH');
    kiZEROFILL                      := IndexOf('ZEROFILL');

    SetLength(OperatorTypeByKeywordIndex, KeywordList.Count);
    for Index := 0 to KeywordList.Count - 1 do
      OperatorTypeByKeywordIndex[Index] := otNone;
    OperatorTypeByKeywordIndex[kiAND]      := otAnd;
    OperatorTypeByKeywordIndex[kiCASE]     := otCase;
    OperatorTypeByKeywordIndex[kiBETWEEN]  := otBetween;
    OperatorTypeByKeywordIndex[kiBINARY]   := otBinary;
    OperatorTypeByKeywordIndex[kiCOLLATE]  := otCollate;
    OperatorTypeByKeywordIndex[kiDIV]      := otDiv;
    OperatorTypeByKeywordIndex[kiESCAPE]   := otEscape;
    OperatorTypeByKeywordIndex[kiIS]       := otIs;
    OperatorTypeByKeywordIndex[kiIN]       := otIn;
    OperatorTypeByKeywordIndex[kiINTERVAL] := otInterval;
    OperatorTypeByKeywordIndex[kiLIKE]     := otLike;
    OperatorTypeByKeywordIndex[kiMOD]      := otMod;
    OperatorTypeByKeywordIndex[kiNOT]      := otNot;
    OperatorTypeByKeywordIndex[kiOR]       := otOr;
    OperatorTypeByKeywordIndex[kiREGEXP]   := otRegExp;
    OperatorTypeByKeywordIndex[kiRLIKE]    := otRegExp;
    OperatorTypeByKeywordIndex[kiSOUNDS]   := otSounds;
    OperatorTypeByKeywordIndex[kiXOR]      := otXOr;
  end;
end;

procedure TSQLParser.SetReservedWords(AReservedWords: string);
begin
  ReservedWordList.Text := AReservedWords;
end;

function TSQLParser.StmtPtr(const Node: TOffset): PStmt;
begin
  Assert((0 < Node) and (Node < Nodes.UsedSize) and IsStmt(Node));

  Result := PStmt(@Nodes.Mem[Node]);
end;

function TSQLParser.TokenPtr(const Token: TOffset): PToken;
begin
  Assert((0 < Token) and (Token < Nodes.UsedSize) and (NodePtr(Token)^.NodeType = ntToken),
    Parse.SQL);

  Result := PToken(@Nodes.Mem[Token]);
end;

{******************************************************************************}

function AddDatabaseName(const Stmt: TSQLParser.PStmt; const DatabaseName: string): string;
var
  Length: Integer;
  Text: PChar;
  Token: TSQLParser.PToken;
begin
  if (not Assigned(Stmt)) then
    Result := ''
  else
  begin
    Stmt^.Parser.Commands := TSQLParser.TFormatBuffer.Create();

    Token := Stmt^.FirstToken;
    while (Assigned(Token)) do
    begin
      if ((Token^.DbIdentType in [ditTable, ditProcedure, ditFunction, ditTrigger, ditEvent])
        and (not Assigned(Token^.ParentNode) or (Token^.ParentNode^.NodeType = ntDbIdent) and not Assigned(TSQLParser.PDbIdent(Token^.ParentNode)^.DatabaseIdent))) then
      begin
        if (Stmt^.Parser.AnsiQuotes) then
          Stmt^.Parser.Commands.Write(SQLEscape(DatabaseName, '"'))
        else
          Stmt^.Parser.Commands.Write(SQLEscape(DatabaseName, '`'));
        Stmt^.Parser.Commands.Write('.');
      end;
      Token^.GetText(Text, Length);
      Stmt^.Parser.Commands.Write(Text, Length);

      Token := Token^.NextTokenAll;
    end;

    Result := Stmt^.Parser.Commands.Read();

    Stmt^.Parser.Commands.Free(); Stmt^.Parser.Commands := nil;
  end;
end;

function ExpandSelectStmtWhereClause(const Stmt: TSQLParser.PStmt; const WhereClause: string): string;
var
  Index: Integer;
  LastToken: TSQLParser.PToken;
  Length: Integer;
  MultiLine: Boolean;
  Nodes: TSQLParser.POffsetArray;
  Text: PChar;
  Token: TSQLParser.PToken;
begin
  if (not Assigned(Stmt) or (Stmt^.StmtType <> stSelect)) then
    Result := ''
  else
  begin
    Stmt^.Parser.Commands := TSQLParser.TFormatBuffer.Create();

    if (TSQLParser.PSelectStmt(Stmt)^.Nodes.Where.Tag = 0) then
      // Append whole WHERE clause
    begin
      MultiLine := False;
      Token := Stmt^.FirstToken;
      while (Assigned(Token)) do
      begin
        if (Token^.TokenType = ttReturn) then
        begin
          MultiLine := True;
          break;
        end;

        if (Token = Stmt^.LastToken) then
          Token := nil
        else
          Token := Token^.NextTokenAll;
      end;

      Nodes := TSQLParser.POffsetArray(@TSQLParser.PSelectStmt(Stmt)^.Nodes);
      Index := (Integer(@TSQLParser.PSelectStmt(Stmt)^.Nodes.Where.Tag) - Integer(Nodes)) div SizeOf(TSQLParser.TOffset);
      while ((Index > 0) and (Nodes^[Index] = 0)) do Dec(Index);
      LastToken := Stmt^.Parser.NodePtr(Nodes^[Index])^.LastToken;

      Token := Stmt^.FirstToken;
      while (Assigned(Token)) do
      begin
        Token^.GetText(Text, Length);
        Stmt^.Parser.Commands.Write(Text, Length);

        if (Token = LastToken) then
          Token := nil
        else
          Token := Token^.NextTokenAll;
      end;

      if (not MultiLine) then
        Stmt^.Parser.Commands.WriteSpace()
      else
        Stmt^.Parser.Commands.WriteReturn();
      Stmt^.Parser.Commands.Write('WHERE ');
      Stmt^.Parser.Commands.Write(WhereClause);
    end
    else
      // Expand existing WHERE clause with AND
    begin
      Token := Stmt^.FirstToken;
      repeat
        Token^.GetText(Text, Length);
        Stmt^.Parser.Commands.Write(Text, Length);

        Token := Token^.NextTokenAll;
      until (Token = Stmt^.Parser.NodePtr(TSQLParser.PSelectStmt(Stmt)^.Nodes.Where.Expr)^.FirstToken);

      Stmt^.Parser.Commands.Write('(');

      LastToken := Stmt^.Parser.NodePtr(TSQLParser.PSelectStmt(Stmt)^.Nodes.Where.Expr)^.LastToken;
      while (Assigned(Token)) do
      begin
        Token^.GetText(Text, Length);
        Stmt^.Parser.Commands.Write(Text, Length);

        if (Token = LastToken) then
          Token := nil
        else
          Token := Token^.NextTokenAll;
      end;

      Stmt^.Parser.Commands.Write(') AND (');
      Stmt^.Parser.Commands.Write(WhereClause);
      Stmt^.Parser.Commands.Write(')');
    end;

    Token := LastToken^.NextTokenAll;
    while (Assigned(Token)) do
    begin
      Token^.GetText(Text, Length);
      Stmt^.Parser.Commands.Write(Text, Length);

      if (Token = Stmt^.LastToken) then
        Token := nil
      else
        Token := Token^.NextTokenAll;
    end;

    Result := Stmt^.Parser.Commands.Read();

    Stmt^.Parser.Commands.Free(); Stmt^.Parser.Commands := nil;
  end;
end;

function GetOrderFromSelectStmt(const Stmt: TSQLParser.PStmt; out FieldNames, DescFieldNames: string): Boolean;
var
  Column: TSQLParser.PChild;
  Expr: TSQLParser.PNode;
  List: TSQLParser.PList;
begin
  Result := False;

  if (Assigned(Stmt)
    and (Stmt^.StmtType = stSelect)
    and (TSQLParser.PSelectStmt(Stmt)^.Nodes.OrderBy > 0)
    and (TSQLParser.TSelectStmt.POrderBy(Stmt^.Parser.NodePtr(TSQLParser.PSelectStmt(Stmt)^.Nodes.OrderBy))^.Nodes.List > 0)) then
  begin
    List := TSQLParser.PList(Stmt^.Parser.NodePtr(TSQLParser.TSelectStmt.POrderBy(Stmt^.Parser.NodePtr(TSQLParser.PSelectStmt(Stmt)^.Nodes.OrderBy))^.Nodes.List));

    Column := List^.FirstElement;
    while (Assigned(Column)) do
    begin
      if ((TSQLParser.PNode(Column)^.NodeType <> ntSelectStmtOrder)
        or (TSQLParser.TSelectStmt.POrder(Column)^.Nodes.Expr = 0)) then
        Exit(False);

      Expr := Stmt^.Parser.NodePtr(TSQLParser.TSelectStmt.POrder(Column)^.Nodes.Expr);

      if ((Expr^.NodeType <> ntDbIdent)
        or (TSQLParser.PDbIdent(Expr)^.Nodes.Ident = 0)
        or (Stmt^.Parser.NodePtr(TSQLParser.PDbIdent(Expr)^.Nodes.Ident)^.NodeType <> ntToken)) then
        Exit(False);

      if (FieldNames <> '') then FieldNames := FieldNames + ';';
      FieldNames := FieldNames + Stmt^.Parser.TokenPtr(TSQLParser.PDbIdent(Expr)^.Nodes.Ident)^.AsString;

      if ((TSQLParser.TSelectStmt.POrder(Column)^.Nodes.DirectionTag > 0)
        and (Stmt^.Parser.NodePtr(TSQLParser.TSelectStmt.POrder(Column)^.Nodes.DirectionTag)^.NodeType = ntTag)
        and (TSQLParser.PTag(Stmt^.Parser.NodePtr(TSQLParser.TSelectStmt.POrder(Column)^.Nodes.DirectionTag))^.Nodes.Keyword1Token > 0)
        and (TSQLParser.PTag(Stmt^.Parser.NodePtr(TSQLParser.TSelectStmt.POrder(Column)^.Nodes.DirectionTag))^.Nodes.Keyword2Token = 0)
        and (Stmt^.Parser.TokenPtr(TSQLParser.PTag(Stmt^.Parser.NodePtr(TSQLParser.TSelectStmt.POrder(Column)^.Nodes.DirectionTag))^.Nodes.Keyword1Token)^.KeywordIndex = Stmt^.Parser.kiDESC)) then
      begin
        if (DescFieldNames <> '') then DescFieldNames := DescFieldNames + ';';
        DescFieldNames := DescFieldNames + Stmt^.Parser.TokenPtr(TSQLParser.PDbIdent(Expr)^.Nodes.Ident)^.AsString;
      end;

      Column := List^.GetNextElement(Column);
    end;

    Result := True;
  end;
end;

function RemoveDatabaseName(const Stmt: TSQLParser.PStmt; const DatabaseName: string; const CaseSensitive: Boolean = False): string;
var
  Length: Integer;
  Text: PChar;
  Token: TSQLParser.PToken;
begin
  if (not Assigned(Stmt)) then
    Result := ''
  else
  begin
    Stmt^.Parser.Commands := TSQLParser.TFormatBuffer.Create();

    Token := Stmt^.FirstToken;
    while (Assigned(Token)) do
    begin
      if ((Token^.DbIdentType = ditDatabase)
        and Assigned(Token^.NextToken) and (Token^.NextToken^.TokenType = ttDot)
        and (CaseSensitive and (StrComp(PChar(Token^.AsString), PChar(DatabaseName)) = 0)
          or not CaseSensitive and (StrIComp(PChar(Token^.AsString), PChar(DatabaseName)) = 0))) then
        Token := Token^.NextTokenAll
      else
      begin
        Token^.GetText(Text, Length);
        Stmt^.Parser.Commands.Write(Text, Length);
      end;

      if (Token = Stmt^.LastToken) then
        Token := nil
      else
        Token := Token^.NextTokenAll;
    end;

    Result := Stmt^.Parser.Commands.Read();

    Stmt^.Parser.Commands.Free(); Stmt^.Parser.Commands := nil;
  end;
end;

function RemoveTableName(const Stmt: TSQLParser.PStmt; const TableName: string; const CaseSensitive: Boolean = False): string;
var
  Length: Integer;
  Text: PChar;
  Token: TSQLParser.PToken;
  PreviousToken: TSQLParser.PToken;
begin
  if (not Assigned(Stmt)) then
    Result := ''
  else
  begin
    Stmt^.Parser.Commands := TSQLParser.TFormatBuffer.Create();

    Token := Stmt^.FirstToken; PreviousToken := nil;
    while (Assigned(Token)) do
    begin
      if ((not Assigned(PreviousToken) or (PreviousToken.TokenType <> ttDot))
        and (Token^.DbIdentType = ditTable)
        and Assigned(Token^.NextToken) and (Token^.NextToken^.TokenType = ttDot)
        and (CaseSensitive and (StrComp(PChar(Token^.AsString), PChar(TableName)) = 0)
          or not CaseSensitive and (StrIComp(PChar(Token^.AsString), PChar(TableName)) = 0))) then
        Token := Token^.NextTokenAll
      else
      begin
        Token^.GetText(Text, Length);
        Stmt^.Parser.Commands.Write(Text, Length);
      end;

      PreviousToken := Token;
      if (Token = Stmt^.LastToken) then
        Token := nil
      else
        Token := Token^.NextTokenAll;
    end;

    Result := Stmt^.Parser.Commands.Read();

    Stmt^.Parser.Commands.Free(); Stmt^.Parser.Commands := nil;
  end;
end;

function ReplaceSelectStmtLimit(const Stmt: TSQLParser.PStmt; const Offset, RowCount: Integer): string;
var
  Index: Integer;
  LastToken: TSQLParser.PToken;
  Length: Integer;
  Nodes: TSQLParser.POffsetArray;
  MultiLine: Boolean;
  Text: PChar;
  Token: TSQLParser.PToken;
begin
  if (not Assigned(Stmt) or (Stmt^.StmtType <> stSelect)) then
    Result := ''
  else
  begin
    Stmt^.Parser.Commands := TSQLParser.TFormatBuffer.Create();

    if ((TSQLParser.PSelectStmt(Stmt)^.Nodes.Limit = 0)
      and (RowCount >= 0)) then
      // Add new LIMIT clause
    begin
      MultiLine := False;
      Token := Stmt^.FirstToken;
      while (Assigned(Token)) do
      begin
        if (Token^.TokenType = ttReturn) then
        begin
          MultiLine := True;
          break;
        end;

        if (Token = Stmt^.LastToken) then
          Token := nil
        else
          Token := Token^.NextTokenAll;
      end;

      Nodes := TSQLParser.POffsetArray(@TSQLParser.PSelectStmt(Stmt)^.Nodes);
      Index := (Integer(@TSQLParser.PSelectStmt(Stmt)^.Nodes.Limit) - Integer(Nodes)) div SizeOf(TSQLParser.TOffset);
      while ((Index > 0) and (Nodes^[Index] = 0)) do Dec(Index);
      LastToken := Stmt^.Parser.NodePtr(Nodes^[Index])^.LastToken;

      Token := Stmt^.FirstToken;
      while (Assigned(Token)) do
      begin
        Token^.GetText(Text, Length);
        Stmt^.Parser.Commands.Write(Text, Length);

        if (Token = LastToken) then
          Token := nil
        else
          Token := Token^.NextTokenAll;
      end;

      if (not MultiLine) then
        Stmt^.Parser.Commands.WriteSpace()
      else
        Stmt^.Parser.Commands.WriteReturn();
      Stmt^.Parser.Commands.Write('LIMIT ');
      if (Offset > 0) then
      begin
        Stmt^.Parser.Commands.Write(IntToStr(Offset));
        Stmt^.Parser.Commands.Write(',');
      end;
      Stmt^.Parser.Commands.Write(IntToStr(RowCount));

      while (Assigned(Token)) do
      begin
        Token^.GetText(Text, Length);
        Stmt^.Parser.Commands.Write(Text, Length);

        if (Token = Stmt^.LastToken) then
          Token := nil
        else
          Token := Token^.NextTokenAll;
      end;
    end
    else if ((TSQLParser.PSelectStmt(Stmt)^.Nodes.Limit > 0)
      and (RowCount >= 0)) then
      // Replace existing LIMIT clause
    begin
      LastToken := Stmt^.Parser.NodePtr(TSQLParser.TSelectStmt.PLimit(Stmt^.Parser.NodePtr(TSQLParser.PSelectStmt(Stmt)^.Nodes.Limit)).Nodes.Tag)^.LastToken;

      Token := Stmt^.FirstToken;
      while (Assigned(Token)) do
      begin
        Token^.GetText(Text, Length);
        Stmt^.Parser.Commands.Write(Text, Length);

        if (Token = LastToken) then
          Token := nil
        else
          Token := Token^.NextTokenAll;
      end;

      Stmt^.Parser.Commands.WriteSpace();
      if (Offset > 0) then
      begin
        Stmt^.Parser.Commands.Write(IntToStr(Offset));
        Stmt^.Parser.Commands.Write(',');
      end;
      Stmt^.Parser.Commands.Write(IntToStr(RowCount));

      Token := Stmt^.Parser.NodePtr(TSQLParser.TSelectStmt.PLimit(Stmt^.Parser.NodePtr(TSQLParser.PSelectStmt(Stmt)^.Nodes.Limit)).Nodes.RowCountToken)^.LastToken^.NextTokenAll;
      while (Assigned(Token)) do
      begin
        Token^.GetText(Text, Length);
        Stmt^.Parser.Commands.Write(Text, Length);

        if (Token = Stmt^.LastToken) then
          Token := nil
        else
          Token := Token^.NextTokenAll;
      end;
    end
    else if (TSQLParser.PSelectStmt(Stmt)^.Nodes.Limit > 0) then
      // Remove existing LIMIT clause
    begin
      Assert(Stmt^.Parser.NodePtr(TSQLParser.PSelectStmt(Stmt)^.Nodes.Limit)^.NodeType = ntSelectStmtLimit);
      Token := Stmt^.FirstToken;
      while (Token <> Stmt^.Parser.NodePtr(TSQLParser.TSelectStmt.PLimit(Stmt^.Parser.NodePtr(TSQLParser.PSelectStmt(Stmt)^.Nodes.Limit)).Nodes.Tag)^.LastToken) do
      begin
        Token^.GetText(Text, Length);
        Stmt^.Parser.Commands.Write(Text, Length);

        Token := Token^.NextTokenAll;
      end;

      if (TSQLParser.TSelectStmt.PLimit(Stmt^.Parser.NodePtr(TSQLParser.PSelectStmt(Stmt)^.Nodes.Limit)).Nodes.RowCountToken = 0) then
        raise ERangeError.Create(SRangeError);

      Token := Stmt^.Parser.TokenPtr(TSQLParser.TSelectStmt.PLimit(Stmt^.Parser.NodePtr(TSQLParser.PSelectStmt(Stmt)^.Nodes.Limit)).Nodes.RowCountToken);
      if (Token = Stmt^.LastToken) then
        Token := nil
      else
        Token := Token^.NextToken;

      while (Assigned(Token)) do
      begin
        Token^.GetText(Text, Length);
        Stmt^.Parser.Commands.Write(Text, Length);

        if (Token = Stmt^.LastToken) then
          Token := nil
        else
          Token := Token^.NextTokenAll;
      end;
    end;

    Result := Stmt^.Parser.Commands.Read();

    Stmt^.Parser.Commands.Free(); Stmt^.Parser.Commands := nil;
  end;
end;

{$IFDEF Debug}
var
  Max: Integer;
  OperatorType: TSQLParser.TOperatorType;
{$ENDIF}
initialization
  {$IFDEF Debug}
    Max := 0;
    for OperatorType := Low(TSQLParser.TOperatorType) to High(TSQLParser.TOperatorType) do
      if (TSQLParser.OperatorPrecedenceByOperatorType[OperatorType] > Max) then
        Max := TSQLParser.OperatorPrecedenceByOperatorType[OperatorType];
    Assert(Max = TSQLParser.MaxOperatorPrecedence);
  {$ENDIF}
end.


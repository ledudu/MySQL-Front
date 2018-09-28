unit SQLUtils;

interface {********************************************************************}

uses
  SysUtils;

type
  TSQLStrings = array of string;

  TSQLCLStmt = packed record // must be "packed", since asm code address it as packed
    CommandType: (ctDropDatabase, ctSetNames, ctSetCharacterSet, ctSetCharset, ctShutdown, ctUse);
    ObjectName: string;
  end;

  TSQLDDLStmt = packed record // must be "packed", since asm code address it as packed
    DefinitionType: (dtCreate, dtAlter, dtAlterRename, dtRename, dtDrop);
    ObjectType: (otDatabase, otEvent, otFunction, otProcedure, otSequence, otTable, otTrigger, otView);
    DatabaseName: string;
    ObjectName: string;
    NewDatabaseName: string;
    NewObjectName: string;
  end;

  TSQLDMLStmt = packed record // must be "packed", since asm code address it as packed
    ManipulationType: (mtInsert, mtUpdate, mtDelete);
    DatabaseNames: array of string;
    TableNames: array of string;
  end;

  TSQLSLStmt = packed record // must be "packed", since asm code address it as packed
    SelectType: (stSelect, stShow);
    DatabaseName: string;
    ItemName: string;
  end;

  TSQLParse = packed record // must be "packed", since asm code address it as packed
    Pos: PChar;                          // Current point of parsing
    Len: Integer;
    EDX: Cardinal;                       // Version of MySQL conditional Code
    Start: PChar;                        // Complete parsed SQL
  end;

function BitStringToInt(const BitString: PChar; const Length: Integer; const Error: PBoolean = nil): UInt64;
function IntToBitString(const Value: UInt64; const MinWidth: Integer = 1): string;
function SQLCreateParse(out Handle: TSQLParse; const SQL: PChar; const Len: Integer; const Version: Integer; const InCondCode: Boolean = False): Boolean;
function SQLEscape(const Value: string; const Quoter: Char = ''''): string; overload;
function SQLEscape(Value: PChar; ValueLen: Integer; Escaped: PChar; EscapedLen: Integer; Quoter: Char = ''''): Integer; overload;
function SQLEscapeBin(Value: PAnsiChar; ValueLen: Integer; Escaped: PChar; EscapedLen: Integer; ODBCEncoding: Boolean): Integer; overload;
function SQLEscapeBin(const Data: PAnsiChar; const Len: Integer; const ODBCEncoding: Boolean): string; overload;
function SQLEscapeBin(const Value: string; const ODBCEncoding: Boolean): string; overload;
function SQLParseCallStmt(const SQL: PChar; const Len: Integer; out ProcedureName: string; const Version: Integer): Boolean;
function SQLParseChar(var Handle: TSQLParse; const Character: Char; const IncrementIndex: Boolean = True): Boolean; overload;
function SQLParseCLStmt(out CLStmt: TSQLCLStmt; const SQL: PChar; const Len: Integer; const Version: Integer): Boolean;
function SQLParseDDLStmt(out DDLStmt: TSQLDDLStmt; const SQL: PChar; const Len: Integer; const Version: Integer): Boolean;
function SQLParseDMLStmt(out DMLStmt: TSQLDMLStmt; const SQL: PChar; const Len: Integer; const Version: Integer): Boolean;
function SQLParseEnd(const Handle: TSQLParse): Boolean; inline;
function SQLParseGetIndex(const Handle: TSQLParse): Integer;
function SQLParseKeyword(var Handle: TSQLParse; const Keyword: PChar; const IncrementIndex: Boolean = True): Boolean;
function SQLParseObjectName(var Handle: TSQLParse; var DatabaseName: string; out ObjectName: string): Boolean;
function SQLParseRest(var Handle: TSQLParse): string;
function SQLParseValue(var Handle: TSQLParse; const TrimAfterValue: Boolean = True): string; overload;
function SQLParseValue(var Handle: TSQLParse; const Value: PChar; const TrimAfterValue: Boolean = True): Boolean; overload;
function SQLSingleStmt(const SQL: string): Boolean;
procedure SQLSplitValues(const Text: string; out Values: TSQLStrings);
function SQLStmtLength(SQL: PChar; Len: Integer; const Delimited: PBoolean = nil): Integer;
function SQLStmtToCaption(const SQL: string; const Len: Integer = 50): string;
function SQLUnescape(const Value: PChar; const ValueLen: Integer; const Unescaped: PChar; const UnescapedLen: Integer): Integer; overload;
function SQLUnescape(const Value: string): string; overload;
function StrToUInt64(const S: string): UInt64;
function TryStrToUInt64(const S: string; out Value: UInt64): Boolean;
function UInt64ToStr(Value: UInt64): string;

type
  TSQLBuffer = class
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
    function Read(): string;
    procedure Write(const Text: PChar; const Length: Integer); overload;
    procedure Write(const Text: string); overload; inline;
    procedure WriteChar(const Char: Char);
    procedure WriteData(Value: PAnsiChar; ValueLen: Integer; Quote: Boolean = False; Quoter: Char = ''''); overload;
    function WriteExternal(const Length: Integer): PChar;
    procedure WriteText(const Text: PChar; const Length: Integer);
    property Data: Pointer read GetData;
    property Length: Integer read GetLength;
    property Size: Integer read GetSize;
    property Text: PChar read GetText;
  end;

implementation {***************************************************************}

uses
  RTLConsts, Classes, SysConst, AnsiStrings;

resourcestring
  SInvalidSQLText = 'Invalid SQL text near "%s".';
  SInvalidUInt64 = '"%s" is not a valid UInt64 value';

type
  UInt64Rec = packed record
    case Integer of
      0: (Lo, Hi: Cardinal);
      1: (Cardinals: array [0..1] of Cardinal);
      2: (Words: array [0..3] of Word);
      3: (Bytes: array [0..7] of Byte);
  end;

const
  KAlgorithm: PChar = 'ALGORITHM';
  KAlter: PChar = 'ALTER';
  KBegin: PChar = 'BEGIN';
  KBeginWork: PChar = 'BEGIN WORK';
  KCall: PChar = 'CALL';
  KCase: PChar = 'CASE';
  KCreate: PChar = 'CREATE';
  KDatabase: PChar = 'DATABASE';
  KDefiner: PChar = 'DEFINER';
  KDelayed: PChar = 'DELAYED';
  KDelete: PChar = 'DELETE';
  KDrop: PChar = 'DROP';
  KDropDatabase: PChar = 'DROP DATABASE';
  KDropSchema: PChar = 'DROP SCHEMA';
  KEnd: PChar = 'END';
  KEndIf: PChar = 'END IF';
  KEndLoop: PChar = 'END LOOP';
  KEndRepeat: PChar = 'END REPEAT';
  KEndWhile: PChar = 'END WHILE';
  KEvent: PChar = 'EVENT';
  KExists: PChar = 'EXISTS';
  KFrom: PChar = 'FROM';
  KFunction: PChar = 'FUNCTION';
  KHighPriority: PChar = 'HIGH_PRIORITY';
  KIf: PChar = 'IF';
  KIgnore: PChar = 'IGNORE';
  KInsert: PChar = 'INSERT';
  KInto: PChar = 'INTO';
  KLoop: PChar = 'LOOP';
  KLowPriority: PChar = 'LOW_PRIORITY';
  KNot: PChar = 'NOT';
  KOrReplace: PChar = 'OR REPLACE';
  KProcedure: PChar = 'PROCEDURE';
  KQuick: PChar = 'QUICK';
  KRename: PChar = 'RENAME';
  KRepeat: PChar = 'REPEAT';
  KSelect: PChar = 'SELECT';
  KSetNames: PChar = 'SET NAMES';
  KSetCharacterSet: PChar = 'SET CHARACTER SET';
  KSetCharset: PChar = 'SET CHARSET';
  KSequence: PChar = 'SEQUENCE';
  KShow: PChar = 'SHOW';
  KShutdown: PChar = 'SHUTDOWN';
  KSQLSecurityDefiner: PChar = 'SQL SECURITY DEFINER';
  KSQLSecurityInvoker: PChar = 'SQL SECURITY INVOKER';
  KTable: PChar = 'TABLE';
  KThen: PChar = 'THEN';
  KTemporary: PChar = 'TEMPORARY';
  KTrigger: PChar = 'TRIGGER';
  KUpdate: PChar = 'UPDATE';
  KUse: PChar = 'USE';
  KView: PChar = 'VIEW';
  KWhile: PChar = 'WHILE';
  KWork: PChar = 'WORK';

procedure MoveString();
// ESI: Pointer to SQL
// ECX: Characters left in SQL
// EDI: Pointer to Result
// ESI will be moved to the next usable character inside SQL
// ECX will be decremened of the string length
// ZF if no string copied
label
  Quoted, Quoted1, QuotedL, QuotedL1, QuotedL2, QuotedLA, QuotedL4, QuotedLE,
  Finish;
asm
        PUSH EAX
        PUSH EBX
        PUSH EDX

        CMP WORD PTR [ESI],''''          // Start quotation in SQL?
        JE Quoted                        // Yes!
        CMP WORD PTR [ESI],'"'           // Start quotation in SQL?
        JE Quoted                        // Yes!
        CMP WORD PTR [ESI],'`'           // Start quotation in SQL?
        JE Quoted                        // Yes!
        MOV EBX,False                    // string not found!
        JMP Finish

      Quoted:
        MOV EBX,True                     // string found!
        LODSW                            // Get used Quoter
        CMP EDI,0                        // Store the string somewhere?
        JE Quoted1                       // No!
        STOSW                            // Put Quoter
      Quoted1:
        MOV DX,AX                        // Remember Quoter
        DEC ECX                          // Quoter handled
        JZ Finish                        // End of SQL!

      QuotedL:
        LODSW                            // Get character from SQL
        CMP EDI,0                        // Store the string somewhere?
        JE QuotedL1                      // No!
        STOSW                            // Put character
      QuotedL1:
        CMP AX,'\'                       // Character = Escaper?
        JNE QuotedL4                     // No!
        CMP ECX,1                        // Last character in SQL?
        JE QuotedLE                      // Yes!
        MOV AX,[ESI]                     // Character after Escape
        CMP AX,'\'                       // Character = second Escaper?
        JE QuotedL2                      // Yes!
        CMP AX,''''                      // "'"?
        JE QuotedL2                      // Yes!
        CMP AX,'"'                       // '"'?
        JE QuotedL2                      // Yes!
        JMP QuotedLE
      QuotedL2:
        DEC ECX                          // Escaper handled
        LODSW                            // Get char after Escaper from SQL
        CMP EDI,0                        // Store the string somewhere?
        JE QuotedLA                      // No!
        STOSW                            // Put character
      QuotedLA:
        JMP QuotedLE
      QuotedL4:
        CMP AX,DX                        // End Quoter?
        JNE QuotedLE                     // No!
        DEC ECX                          // End Quoter handled
        JZ Finish                        // End of SQL!
        CMP [ESI],DX                     // Second Quoter?
        JNE Finish                       // No!
        LODSW                            // Get char after Escaper from SQL
        CMP EDI,0                        // Store the string somewhere?
        JE QuotedLE                      // No!
        STOSW                            // Put character
      QuotedLE:
        LOOP QuotedL

      Finish:
        CMP EBX,True
        POP EDX
        POP EBX
        POP EAX
end;

procedure Trim();
// ESI: Pointer to SQL
// ECX: Characters left in SQL
// EDI: Pointer to Result
// EDX: Version for MySQL conditional code
// ESI will be moved to the next usable character inside SQL
// ECX will be decremened by the ignored characters
// ZF if no string copied
label
  StringL, StringL2,
  EndOfStatement,
  EmptyCharacter,
  LineComment, LineCommentL,
  EnclosedComment,
  Version, VersionL, VersionE,
  EnclosedCommentL, EnclosedCommentLE, EnclosedCommentE,
  CondCodeEnd,
  Finish;
asm
        PUSH EBX
        PUSH EDI

        MOV EBX,False                    // No empty character!
        XOR EDI,EDI                      // Don't copy comment

        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!

      StringL:
        CMP WORD PTR [ESI],9             // Current character inside SQL?
        JE EmptyCharacter                // Tabulator!
        CMP WORD PTR [ESI],10            // New Line?
        JE EmptyCharacter                // Yes!
        CMP WORD PTR [ESI],13            // Carrige Return?
        JE EmptyCharacter                // Yes!
        CMP WORD PTR [ESI],' '           // Space?
        JE EmptyCharacter                // Yes!
        CMP WORD PTR [ESI],'#'           // End of line comment ("#") in SQL?
        JE LineComment                   // Yes!
        CMP WORD PTR [ESI],';'           // End of Statement?
        JE EndOfStatement                // Yes!
        CMP ECX,2                        // Are there two characters left in SQL?
        JB Finish                        // No!
        CMP LONGWORD PTR [ESI],$002D002D // End of line comment ("--") in SQL?
        JNE StringL2                     // No!
        CMP ECX,3                        // Thre characters inside SQL?
        JB StringL2                      // No!
        CMP WORD PTR [ESI + 4],9         // Current character inside SQL?
        JE LineComment                   // Tabulator!
        CMP WORD PTR [ESI + 4],10        // New Line?
        JE LineComment                   // Yes!
        CMP WORD PTR [ESI + 4],13        // Carrige Return?
        JE LineComment                   // Yes!
        CMP WORD PTR [ESI + 4],' '       // Space?
        JE LineComment                   // Yes!
      StringL2:
        CMP LONGWORD PTR [ESI],$002A002F // Start of "/*" comment in SQL?
        JE EnclosedComment               // Yes!
        TEST EDX,$80000000               // Are we inside cond. MySQL code?
        JZ Finish                        // No!
        CMP LONGWORD PTR [ESI],$002F002A // End of "*/" comment in SQL?
        JE CondCodeEnd                   // Yes!
        JMP Finish

      // -------------------

      EndOfStatement:
        AND EDX,NOT $80000000            // We're outside cond. MySQL code!
        JMP Finish

      // -------------------

      EmptyCharacter:
        MOV EBX,True                     // Empty characters found!
        ADD ESI,2                        // Step over empty character
        DEC ECX                          // One character handled
        JNZ StringL                      // There are still character left in SQL!
        JMP Finish

      // -------------------

      LineComment:
        MOV EBX,True                     // Comment found!
      LineCommentL:
        CMP WORD PTR [ESI],10            // End of line found in SQL?
        JE StringL                       // Yes!
        CMP WORD PTR [ESI],13            // End of line found in SQL?
        JE StringL                       // Yes!
        ADD ESI,2                        // Step over comment character
        LOOP LineCommentL
        JMP Finish

      // -------------------

      EnclosedComment:
        MOV EBX,True                     // Comment found!
        ADD ESI,4                        // Step over "/*"
        SUB ECX,2                        // "/*" handled
        JZ Finish                        // End of SQL!

        CMP WORD PTR [ESI],'!'           // Conditional MySQL code?
        JNE EnclosedCommentL             // No!
        CMP EDX,0                        // MySQL version given?
        JE EnclosedCommentL              // No!

      Version:
        ADD ESI,2                        // Step over "!"
        DEC ECX                          // "!" handled
        JZ Finish                        // End of SQL!

        PUSH EAX
        PUSH EBX
        PUSH EDX
        MOV EAX,6                        // Max. 6 version digits
        MOV EBX,0                        // Version inside SQL
      VersionL:
        CMP WORD PTR [ESI],'0'           // Version digit?
        JB VersionE                      // No!
        CMP WORD PTR [ESI],'9'           // Version digit?
        JA VersionE                      // No!

        PUSH EAX
        PUSH EDX
        MOV EAX,EBX
        MOV BX,10
        MUL BX                           // Shift version one digi left
        MOV EBX,EAX
        MOV EAX,0
        LODSW                            // Get version digit
        DEC ECX                          // One character handled
        SUB AX,'0'                       // Convert digit numerical
        ADD EBX,EAX                      // Add digit to version
        POP EDX
        POP EAX

        CMP ECX,0
        JNE VersionL

      VersionE:
        POP EDX
        CMP EBX,EDX                      // Use cond. MySQL code?
        POP EBX
        POP EAX
        JGE EnclosedCommentL             // No!

        OR EDX,$80000000                 // We're inside cond. MySQL code!
        JECXZ Finish                     // End of SQL!
        JMP StringL

      EnclosedCommentL:
        CMP ECX,2                        // Are there two characters left in SQL?
        JB EnclosedCommentLE             // No!
        CMP LONGWORD PTR [ESI],$002F002A    // "*/" in SQL?
        JE EnclosedCommentE              // Yes!
      EnclosedCommentLE:
        ADD ESI,2                        // Step over commenct character in SQL
        LOOP EnclosedCommentL            // There are more characters left in SQL!
        JMP Finish
      EnclosedCommentE:
        ADD ESI,4                        // Ignore "*/"
        SUB ECX,2                        // "*/" handled in SQL
        JNZ StringL                      // There are more characters left in SQL!
        JMP Finish

      // -------------------

      CondCodeEnd:
        TEST EDX,$80000000               // Are we inside cond. MySQL code?
        JZ Finish                        // No!
        MOV EBX,True                     // Empty characters found!
        AND EDX,NOT $80000000            // Now we're outside cond. MySQL code!
        ADD ESI,4                        // Step over "*/"
        SUB ECX,2                        // "*/" handled in SQL
        JNZ StringL                      // There are more characters left in SQL!
        JMP Finish

      // -------------------

      Finish:
        CMP EBX,True                     // Empty characters found?

        POP EDI
        POP EBX
end;

procedure CompareKeyword();
// EAX: Pointer to Keyword
// ECX: Characters left in SQL
// ESI: Pointer to SQL
// ECX will be decremened by a found keyword length
// ZF if keyword found
label
  CharactersL, Characters2, CharactersLE,
  KeywordSpace,
  KeywordTerminated, KeywordTerminatedL, KeywordTerminatedE,
  KeywordNotFound,
  KeywordFound,
  Finish;
const
  Terminators: PChar = #9#10#13#32'"(),.:;=`'; // Characters terminating the identifier
asm
        PUSH EDX                         // Conditional Code Marker, changed in Trim
        PUSH EDI
        PUSH ECX
        PUSH ESI

        MOV EDI,EAX

      CharactersL:
        CMP WORD PTR [EDI],0             // End of Keyword?
        JE KeywordTerminated             // Yes!
        CMP WORD PTR [EDI],' '           // Space in Keyword?
        JNE Characters2                  // No!
        CALL Trim                        // Empty characters in SQL?
        JNE KeywordNotFound              // No!
        ADD EDI,2                        // Step over space in Keyword
        JECXZ KeywordNotFound            // End of SQL!
        JMP CharactersL

      Characters2:
        MOV DX,[ESI]                     // Compare character inside SQL
        AND DX,not $20                   //   (upcased)
        CMP DX,[EDI]                     //   with character in keyword
        JNE KeywordNotFound              // Not equal!
        ADD ESI,2                        // Step over equal character inside SQL

      CharactersLE:
        ADD EDI,2                        // Next character inside SQL
        LOOP CharactersL

        CMP WORD PTR [EDI],0             // End of Keyword?
        JE KeywordFound                  // Yes!
        JMP KeywordNotFound

      // -------------------

      KeywordTerminated:
        MOV DX,[ESI]                     // Character in SQL
        MOV EDI,[Terminators]            // Terminating characters
      KeywordTerminatedL:
        CMP WORD PTR [EDI],0             // All terminators checked?
        JE KeywordTerminatedE            // Yes!
        CMP DX,[EDI]                     // Charcter in SQL = Terminator?
        JE KeywordFound                  // Yes!
        ADD EDI,2                        // Next terminator
        JMP KeywordTerminatedL
      KeywordTerminatedE:
        TEST EDX,$80000000               // Are we inside cond. MySQL code?
        JZ KeywordNotFound               // No!
        CMP ECX,2                        // End of SQL?
        JB KeywordNotFound               // Yes!
        CMP LONGWORD PTR [ESI],$002F002A // End of "*/" comment in SQL?
        JE KeywordFound                  // Yes!

      // -------------------

      KeywordNotFound:
        POP ESI                          // Restore ESI, since keyword not found
        POP ECX                          // Restore ECX, since keyword not found
        MOV EDX,EDI
        JMP Finish

      // -------------------

      KeywordFound:
        POP EDX                          // Restore Stack
        POP EDX                          // Restore Stack
        MOV EDX,ESI
        JMP Finish

      // -------------------

      Finish:
        CMP EDX,ESI                      // Keyword found?
        POP EDI
        POP EDX
        RET
end;

procedure UnescapeString();
// EBX: Needed length of text buffer
// ECX: Length of quoted SQL
// EDX: Unused length of text buffer
// ESI: Pointer to quoted SQL
// EDI: Pointer to unquoted text buffer
// EBX will be incresed of the needed length in text buffer
// ESI will be moved to the next usable character inside SQL
// EAX Updated quoted string length
// EBX Updated needed length of text buffer
// EDX Updated unused length of text buffer
// ZF if no text buffer or text buffer too small or unterminated string
label
  StringL, String1, String2, String3, String4, String5, String6, String7,
  String8, String9, String10, String11, String12, String13, String14, String15,
  String16, StringLE, StringLE2, StringE,
  Finish;
var
  Quoter: Char;
asm
        LODSW                            // Load Quoter from ESI
        MOV Quoter,AX
        DEC ECX                          // Starting Quoter handled
        JZ Finish                        // End of SQL!

      StringL:
        LODSW                            // One character from SQL
        CMP AX,Quoter                    // Quoter?
        JNE String1                      // No!
        CMP ECX,1                        // Last character?
        JE StringE                       // Yes!
        PUSH EAX
        MOV AX,[ESI]
        CMP AX,Quoter                    // Two quoters?
        POP EAX
        JNE StringE                      // No!
        ADD ESI,2                        // Step over quoter
        DEC ECX                          // One character handled
        JMP StringLE                     // Next character
      String1:
        CMP AX,'\'                       // Escape character?
        JNE StringLE                     // No!
        CMP ECX,1                        // Last character?
        JE StringE                       // Yes!
        MOV BX,[ESI]                     // Character after "\"
        CMP BX,'0'                       // "\0"?
        JNE String2                      // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,0                         // replace with #0
        JMP StringLE
      String2:
        CMP BX,''''                      // "\'"?
        JNE String3                      // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,BX                        // replace with "'"
        JMP StringLE
      String3:
        CMP BX,'"'                       // '\"'?
        JNE String4                      // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,BX                        // replace with '"'
        JMP StringLE
      String4:
        CMP BX,'B'                       // "\B"?
        JNE String5                      // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,8                         // replace with Backspace
        JMP StringLE
      String5:
        CMP BX,'b'                       // "\b"?
        JNE String6                      // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,8                         // replace with Backspace
        JMP StringLE
      String6:
        CMP BX,'N'                       // "\N"?
        JNE String7                      // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,10                        // replace with NewLine
        JMP StringLE
      String7:
        CMP BX,'n'                       // "\n"?
        JNE String8                      // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,10                        // replace with NewLine
        JMP StringLE
      String8:
        CMP BX,'R'                       // "\R"?
        JNE String9                      // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,13                        // replace with CarriadeReturn
        JMP StringLE
      String9:
        CMP BX,'r'                       // "\r"?
        JNE String10                     // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,13                        // replace with CarriadeReturn
        JMP StringLE
      String10:
        CMP BX,'T'                       // "\T"?
        JNE String11                     // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,9                         // replace with Tabulator
        JMP StringLE
      String11:
        CMP BX,'t'                       // "\t"?
        JNE String12                     // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,9                         // replace with Tabulator
        JMP StringLE
      String12:
        CMP BX,'Z'                       // "\Z"?
        JNE String13                     // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,26                        // replace with EOF
        JMP StringLE
      String13:
        CMP BX,'z'                       // "\Z"?
        JNE String14                     // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,26                        // replace with EOF
        JMP StringLE
      String14:
        CMP BX,'\'                       // "\\"?
        JNE String15                     // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,BX                        // replace with "\"
        JMP StringLE
      String15:
        CMP BX,'%'                       // "\%"?
        JNE String16                     // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,BX                        // replace with "%"
        JMP StringLE
      String16:
        CMP BX,'_'                       // "\_"?
        JNE StringLE                     // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Ignore Escaper
        MOV AX,BX                        // replace with "_"
        JMP StringLE
      StringLE:
        INC EBX                          // One character needed in text buffer
        CMP EDI,0                        // Store the string somewhere?
        JE StringLE2                     // No!
        CMP EDX,0                        // One character left in text buffer?
        JZ Finish                        // No!
        STOSW                            // Store character in EDI
        DEC EDX                          // One character filled to text buffer
      StringLE2:
        DEC ECX
        JNZ StringL                      // Loop for every character in SQL
      StringE:
        CMP ECX,0                        // All characters handled?
        JE Finish                        // Yes!
        DEC ECX                          // Ending Quoter handled
        CMP ESI,0                        // Success: Clear ZF!
        JMP Finish

      // -------------------

      Finish:
        MOV EAX,ECX

      // ECX will be restored by POP of the Delphi compiler, since we use
      // a local variable. Because of this, ECX will be returned in EAX.
end;

{******************************************************************************}

function BitStringToInt(const BitString: PChar; const Length: Integer; const Error: PBoolean = nil): UInt64;
var
  I: Integer;
begin
  Result := 0;
  if (Assigned(Error)) then
    Error^ := False;
  for I := 0 to Length - 1 do
    if (BitString[I] = '0') then
      Result := Result shl 1
    else
    begin
      Result := Result shl 1 + 1;
      if (Assigned(Error) and (BitString[I] <> '1')) then
        Error^ := True;
    end;
end;

function IntToBitString(const Value: UInt64; const MinWidth: Integer = 1): string;
var
  I: Integer;
begin
  for I := 64 - 1 downto 0 do
    if (Value shr I and $1 = 1) then
      Result := Result + '1'
    else if (Result <> '') then
      Result := Result + '0';
end;

function RemoveDatabaseNameFromStmt(const Stmt: string; const DatabaseName: string; const NameQuoter: Char): string;
begin
  Result := Stmt;
end;

function SQLCreateParse(out Handle: TSQLParse; const SQL: PChar; const Len: Integer; const Version: Integer; const InCondCode: Boolean = False): Boolean;
var
  L: Integer;
  Pos: PChar;
begin
  Result := Assigned(SQL) and (Len > 0);
  if (Result) then
  begin
    asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        PUSH DS                          // string operations uses ES
        POP ES
        CLD                              // string operations uses forward direction

        MOV ESI,PChar(SQL)               // Scan characters from SQL
        MOV ECX,Len

        MOV EDI,0
        MOV EDX,Version

        CALL Trim

        MOV Pos,ESI
        MOV L,ECX

        POP EBX
        POP EDI
        POP ESI
        POP ES
    end;

    Handle.Pos := Pos;
    Handle.Len := L;
    Handle.EDX := Version;
    Handle.Start := Handle.Pos;
    if (InCondCode) then
      Handle.EDX := Handle.EDX or $80000000;
  end;
end;

function SQLEscape(const Value: string; const Quoter: Char = ''''): string;
var
  Len: Integer;
begin
  Len := SQLEscape(PChar(Value), Length(Value), nil, 0, Quoter);
  SetLength(Result, Len);
  SQLEscape(PChar(Value), Length(Value), PChar(Result), Len, Quoter);
end;

function SQLEscape(Value: PChar; ValueLen: Integer; Escaped: PChar; EscapedLen: Integer; Quoter: Char = ''''): Integer; overload;
begin
  if (Assigned(Escaped)) then
  begin
    if (EscapedLen < 1) then
      Exit(0); // Too few space in Escaped
    Escaped^ := Quoter;
    Inc(Escaped); Dec(EscapedLen);
  end;
  Result := 1;

  while (ValueLen > 0) do
  begin
    if (Value^ = #0) then
    begin
      if (Assigned(Escaped)) then
      begin
        if (EscapedLen < 2) then
          Exit(0); // Too few space in Escaped
        Escaped^ := '\'; Inc(Escaped); Dec(EscapedLen);
        Escaped^ := '0'; Inc(Escaped); Dec(EscapedLen);
      end;
      Inc(Value);
      Inc(Result, 2);
    end
    else if (Value^ = #9) then
    begin
      if (Assigned(Escaped)) then
      begin
        if (EscapedLen < 2) then
          Exit(0); // Too few space in Escaped
        Escaped^ := '\'; Inc(Escaped); Dec(EscapedLen);
        Escaped^ := 't'; Inc(Escaped); Dec(EscapedLen);
      end;
      Inc(Value);
      Inc(Result, 2);
    end
    else if (Value^ = #10) then
    begin
      if (Assigned(Escaped)) then
      begin
        if (EscapedLen < 2) then
          Exit(0); // Too few space in Escaped
        Escaped^ := '\'; Inc(Escaped); Dec(EscapedLen);
        Escaped^ := 'n'; Inc(Escaped); Dec(EscapedLen);
      end;
      Inc(Value);
      Inc(Result, 2);
    end
    else if (Value^ = #13) then
    begin
      if (Assigned(Escaped)) then
      begin
        if (EscapedLen < 2) then
          Exit(0); // Too few space in Escaped
        Escaped^ := '\'; Inc(Escaped); Dec(EscapedLen);
        Escaped^ := 'r'; Inc(Escaped); Dec(EscapedLen);
      end;
      Inc(Value);
      Inc(Result, 2);
    end
    else if (Value^ = '"') then
    begin
      if (Assigned(Escaped)) then
      begin
        if (EscapedLen < 2) then
          Exit(0); // Too few space in Escaped
        Escaped^ := '\'; Inc(Escaped); Dec(EscapedLen);
        Escaped^ := '"'; Inc(Escaped); Dec(EscapedLen);
      end;
      Inc(Value);
      Inc(Result, 2);
    end
    else if (Value^ = '''') then
    begin
      if (Assigned(Escaped)) then
      begin
        if (EscapedLen < 2) then
          Exit(0); // Too few space in Escaped
        Escaped^ := '\'; Inc(Escaped); Dec(EscapedLen);
        Escaped^ := ''''; Inc(Escaped); Dec(EscapedLen);
      end;
      Inc(Value);
      Inc(Result, 2);
    end
    else if (Value^ = '\') then
    begin
      if (Assigned(Escaped)) then
      begin
        if (EscapedLen < 2) then
          Exit(0); // Too few space in Escaped
        Escaped^ := '\'; Inc(Escaped); Dec(EscapedLen);
        Escaped^ := '\'; Inc(Escaped); Dec(EscapedLen);
      end;
      Inc(Value);
      Inc(Result, 2);
    end
    else
    begin
      if (Assigned(Escaped)) then
      begin
        if (EscapedLen < 1) then
          Exit(0); // Too few space in Escaped
        Escaped^ := Value^; Inc(Escaped); Dec(EscapedLen);
      end;
      Inc(Value);
      Inc(Result);
    end;
    Dec(ValueLen);
  end;

  if (Assigned(Escaped)) then
  begin
    if (EscapedLen < 1) then
      Exit(0); // Too few space in Escaped
    Escaped^ := Quoter;
  end;
  Inc(Result);
end;

function SQLEscapeBin(Value: PAnsiChar; ValueLen: Integer; Escaped: PChar; EscapedLen: Integer; ODBCEncoding: Boolean): Integer;
const
  Convert: array[0..15] of WideChar = '0123456789ABCDEF';
var
  RequiredLen: Integer;
  I: Integer;
begin
  if (ODBCEncoding) then
    RequiredLen := 2 + 2 * ValueLen
  else
    RequiredLen := 2 + 2 * ValueLen + 1;

  if (not Assigned(Escaped)) then
    Result := RequiredLen
  else if (EscapedLen < RequiredLen) then
    Result := 0 // Escaped buffer too small
  else
  begin
    if (Assigned(Escaped)) then
    begin
      if (ODBCEncoding) then
      begin
        Escaped^ := '0'; Inc(Escaped);
        Escaped^ := 'x'; Inc(Escaped);
      end
      else
      begin
        Escaped^ := 'X'; Inc(Escaped);
        Escaped^ := ''''; Inc(Escaped);
      end;

      for I := 0 to ValueLen - 1 do
      begin
        Escaped[0] := Convert[Byte(Value[I]) shr 4];
        Escaped[1] := Convert[Byte(Value[I]) and $F];
        Inc(Escaped, 2);
      end;

      if (not ODBCEncoding) then
      begin
        Escaped^ := '''';
      end;
    end;

    Result := RequiredLen;
  end;
end;

function SQLEscapeBin(const Data: PAnsiChar; const Len: Integer; const ODBCEncoding: Boolean): string;
const
  HexDigits: PChar = '0123456789ABCDEF';
label
  BinL;
begin
  if (Len = 0) then
    Result := ''''''
  else
  begin
    if (ODBCEncoding) then
      SetLength(Result, 2 + 2 * Len)
    else
      SetLength(Result, 2 + 2 * Len + 1);
    SQLEscapeBin(Data, Len, PChar(Result), Length(Result), ODBCEncoding);
  end;
end;

function SQLEscapeBin(const Value: string; const ODBCEncoding: Boolean): string;
var
  Len: Integer;
begin
  Len := SQLEscapeBin(PAnsiChar(RawByteString(Value)), Length(Value), nil, 0, ODBCEncoding);
  SetLength(Result, Len);
  SQLEscapeBin(PAnsiChar(RawByteString(Value)), Length(Value), PChar(Result), Len, ODBCEncoding);
end;

function SQLParseCallStmt(const SQL: PChar; const Len: Integer; out ProcedureName: string; const Version: Integer): Boolean;
label
  Priority, Ignore, Into2,
  Found,
  Finish, FinishE;
var
  InCondCode: Boolean;
  Index: Integer;
  Parse: TSQLParse;
begin
  asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        PUSH DS                          // string operations uses ES
        POP ES

        MOV ESI,PChar(SQL)               // Scan characters from SQL
        MOV ECX,Len
        MOV EDX,Version                  // Version of MySQL conditional Code

      // -------------------

        MOV @Result,False
        MOV EDI,0                        // Don't copy inside MoveString

        CALL Trim                        // Step over empty characters
        JECXZ Finish                     // End of SQL!

        MOV EAX,[KCall]
        CALL CompareKeyword              // 'CALL'?
        JNE Finish                       // No!
        CALL Trim                        // Step over empty characters
        JECXZ Finish                     // End of SQL!
        JMP Found

      // -------------------

      Found:
        MOV @Result,True                 // SQL is CALL!

      // -------------------

      Finish:
        MOV ECX,ESI
        SUB ECX,Pointer(SQL)
        SHR ECX,1                        // 2 Bytes = 1 character
        MOV Index,ECX

        MOV InCondCode,False
        TEST EDX,$80000000               // Are we inside cond. MySQL code?
        JZ FinishE                       // No!
        MOV InCondCode,True

      FinishE:
        POP EBX
        POP EDI
        POP ESI
        POP ES
  end;

  if (Result and SQLCreateParse(Parse, PChar(@SQL[Index]), Len - Index, Version, InCondCode)) then
    ProcedureName := SQLParseValue(Parse);
end;

function SQLParseChar(var Handle: TSQLParse; const Character: Char; const IncrementIndex: Boolean = True): Boolean;
label
  Finish;
begin
    asm
        PUSH ESI
        PUSH EBX

        MOV EBX,Handle
        MOV ESI,[EBX + 0]                // Position in SQL
        MOV ECX,[EBX + 4]                // Characters left in SQL
        MOV EDX,[EBX + 8]                // MySQL version

        MOV @Result,False                // Character not found!

        JECXZ Finish                     // End of SQL!

        MOV AX,[ESI]
        CMP AX,Character                 // Character in SQL?
        JNE Finish                       // No!

        MOV @Result,True                 // Character found!

        CMP IncrementIndex,False         // Increment Index?
        JE Finish                        // No!

        ADD ESI,2                        // Step over Char
        DEC ECX                          // IgnoreCharacter
        CALL Trim                        // Step over empty characters

        MOV [EBX + 0],ESI                // New Position in SQL
        MOV [EBX + 4],ECX                // Characters left in SQL
        MOV [EBX + 8],EDX                // MySQL version

      Finish:
        POP EBX
        POP ESI
    end;
end;

function SQLParseCLStmt(out CLStmt: TSQLCLStmt; const SQL: PChar; const Len: Integer; const Version: Integer): Boolean;
label
  Commands, DropDatabase, DropSchema, SetNames, SetCharacterSet, SetCharset, Shutdown, Use,
  Found, FoundL, FoundE,
  Finish, FinishE;
var
  InCondCode: Boolean;
  Index: Integer;
  Parse: TSQLParse;
begin
    asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        PUSH DS                          // string operations uses ES
        POP ES
        CLD                              // string operations uses forward direction

        MOV @Result,False

        MOV ESI,PChar(SQL)               // Scan characters from SQL
        MOV EDX,Version                  // Version of MySQL conditional Code

        MOV ECX,Len                      // Length
        CMP ECX,0                        // Empty SQL?
        JE Finish                        // Yes!

      // -------------------

        MOV EBX,CLStmt

      Commands:
        CALL Trim                        // Empty characters?

      DropDatabase:
        MOV EAX,[KDropDatabase]
        CALL CompareKeyword              // 'DROP DATABASE'?
        JNE DropSchema                   // No!
        MOV BYTE PTR [EBX + 0],ctDropDatabase
        JMP Found

      DropSchema:
        MOV EAX,[KDropSchema]
        CALL CompareKeyword              // 'DROP SCHEMA'?
        JNE SetNames                     // No!
        MOV BYTE PTR [EBX + 0],ctDropDatabase
        JMP Found

      SetNames:
        MOV EAX,[KSetNames]
        CALL CompareKeyword              // 'SET NAMES'?
        JNE SetCharacterSet              // No!
        MOV BYTE PTR [EBX + 0],ctSetNames
        JMP Found

      SetCharacterSet:
        MOV EAX,[KSetCharacterSet]
        CALL CompareKeyword              // 'SET CHARACTER SET'?
        JNE SetCharset                   // No!
        MOV BYTE PTR [EBX + 0],ctSetCharacterSet
        JMP Found

      SetCharset:
        MOV EAX,[KSetCharset]
        CALL CompareKeyword              // 'SET CHARSET'?
        JNE Shutdown                     // No!
        MOV BYTE PTR [EBX + 0],ctSetCharset
        JMP Found

      Shutdown:
        MOV EAX,[KShutdown]
        CALL CompareKeyword              // 'SHUTDOWN'?
        JNE Use                          // No!
        MOV BYTE PTR [EBX + 0],ctShutdown
        JMP Found

      Use:
        MOV EAX,[KUse]
        CALL CompareKeyword              // 'USE'?
        JNE Finish                       // No!
        MOV BYTE PTR [EBX + 0],ctUse

      Found:
        CALL Trim                        // Empty characters?

      FoundE:
        MOV @Result,True

        MOV ECX,ESI                      // Calculate ObjectName position
        SUB ECX,Pointer(SQL)
        SHR ECX,1                        // 2 Bytes = 1 character
        MOV Index,ECX

      // -------------------

      Finish:
        MOV InCondCode,False
        TEST EDX,$80000000               // Are we inside cond. MySQL code?
        JZ FinishE                       // No!
        MOV InCondCode,True

      FinishE:
        POP EBX
        POP EDI
        POP ESI
        POP ES
    end;

  if (not Result or not SQLCreateParse(Parse, PChar(@SQL[Index]), Len - Index, Version, InCondCode)) then
    CLStmt.ObjectName := ''
  else
  begin
    if (CLStmt.CommandType = ctDropDatabase) then
      SQLParseKeyWord(Parse, 'IF EXISTS');
    CLStmt.ObjectName := SQLParseValue(Parse);
  end;
end;

function SQLParseDDLStmt(out DDLStmt: TSQLDDLStmt; const SQL: PChar; const Len: Integer; const Version: Integer): Boolean;
label
  Create, Drop, RenameTable,
  Temporary,
  Algorithm, AlgorithmL,
  Definer,
  ObjType,
  Definer1, Definer2, Definer3,
  ODatabase, OEvent, OFunction, OProcedure, OSequence, OTable, OTrigger, OView,
  Name,
  Found,
  Rename, RenameL, RenameLE, RenameC, RenameE,
  Finish, Finish2;
var
  InCondCode: Boolean;
  Index: Integer;
  IndexNewObjectName: Integer;
  Parse: TSQLParse;
begin
  asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        PUSH DS                          // string operations uses ES
        POP ES

        MOV ESI,SQL                      // Scan characters from SQL
        MOV ECX,Len

        MOV EBX,DDLStmt
        MOV EDX,Version

      // -------------------

        MOV @Result,False
        MOV EDI,0                        // Don't copy inside MoveString

        CALL Trim                        // Step over empty characters
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!

        MOV EAX,[KAlter]
        CALL CompareKeyword              // 'ALTER'?
        JNE Create                       // No!
        MOV BYTE PTR [EBX + 0],dtAlter
        JMP Algorithm
      Create:
        MOV EAX,[KCreate]
        CALL CompareKeyword              // 'CREATE'?
        JNE Drop                         // No!
        MOV BYTE PTR [EBX + 0],dtCreate
        CALL Trim                        // Step over empty characters
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        MOV EAX,[KOrReplace]
        CALL CompareKeyword              // 'OR REPLACE'?
        JNE Temporary                    // No!
        MOV BYTE PTR [EBX + 0],dtAlter
        JMP Temporary
      Drop:
        MOV EAX,[KDrop]
        CALL CompareKeyword              // 'DROP'?
        JNE RenameTable                  // No!
        MOV BYTE PTR [EBX + 0],dtDrop
        JMP ObjType
      RenameTable:
        MOV EAX,[KRename]
        CALL CompareKeyword              // 'RENAME'?
        JNE Finish                       // No!
        MOV BYTE PTR [EBX + 0],dtRename
        JMP ObjType

      // -------------------

      Temporary:
        CALL Trim                        // Step over empty characters
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        MOV EAX,[KTemporary]
        CALL CompareKeyword              // 'TEMPORARY'?

      // -------------------

      Algorithm:
        CALL Trim                        // Step over empty characters
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        MOV EAX,[KAlgorithm]
        CALL CompareKeyword              // 'ALGORITHM'?
        JNE Definer                      // No!

        CALL Trim                        // Step over empty characters
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        CMP WORD PTR [ESI],'='           // '=' ?
        JNE Finish                       // No!

        ADD ESI,2                        // Next character
        DEC ECX                          // '=' handled
        CALL Trim                        // step over empty character
      AlgorithmL:
        CALL Trim                        // Empty character?
        JZ Definer                       // Yes!
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        ADD ESI,2                        // Next character in SQL
        DEC ECX                          // character handled
        JMP AlgorithmL

      // -------------------

      Definer:
        CALL Trim                        // Step over empty characters
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!

        MOV EAX,[KDefiner]
        CALL CompareKeyword              // 'DEFINER'?
        JNE ObjType                      // No!

        CALL Trim                        // Step over empty characters
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        CMP WORD PTR [ESI],'='           // '=' ?
        JNE Finish                       // No!
        ADD ESI,2                        // Next character
        DEC ECX                          // One character ('=') handled
        JZ Finish                        // End of SQL!
        CALL Trim                        // Step over empty characters
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        CALL MoveString                  // Quoted identifier?
        JE Definer2                      // Yes!
      Definer1:
        CALL Trim                        // Empty character found?
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        JE ObjType                       // Yes!
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        CMP WORD PTR [ESI],'@'           // '@'?
        JE Definer2                      // Yes!
        CMP WORD PTR [ESI],''''          // Start quotation in SQL?
        JE ObjType                       // Yes!
        CMP WORD PTR [ESI],'"'           // Start quotation in SQL?
        JE ObjType                       // Yes!
        CMP WORD PTR [ESI],'`'           // Start quotation in SQL?
        JE ObjType                       // Yes!
        ADD ESI,2                        // Next character in SQL
        JMP Definer1
      Definer2:
        ADD ESI,2                        // Step over '@'
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        CALL MoveString                  // Quoted identifier?
        JE ObjType                       // Yes!
      Definer3:
        CALL Trim                        // Empty character?
        JE ObjType                       // Yes!
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        ADD ESI,2                        // Next character in SQL
        JMP Definer3

      ObjType:
        CALL Trim                        // Step over empty characters
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!
        MOV EAX,[KSQLSecurityDefiner]    // Step over
        CALL CompareKeyword              //   'SQL SECURITY DEFINER'
        MOV EAX,[KSQLSecurityInvoker]    // Step over
        CALL CompareKeyword              //   'SQL SECURITY INVOKER'
        CALL Trim                        // Step over empty characters
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!

      ODatabase:
        MOV EAX,[KDatabase]
        CALL CompareKeyword              // 'DATABASE'?
        JNE OEvent                       // No!
        MOV BYTE PTR [EBX + 1],otDatabase
        JMP Found
      OEvent:
        MOV EAX,[KEvent]
        CALL CompareKeyword              // 'EVENT'?
        JNE OFunction                    // No!
        MOV BYTE PTR [EBX + 1],otEvent
        JMP Found
      OFunction:
        MOV EAX,[KFunction]
        CALL CompareKeyword              // 'FUNCTION'?
        JNE OProcedure                   // No!
        MOV BYTE PTR [EBX + 1],otFunction
        JMP Found
      OProcedure:
        MOV EAX,[KProcedure]
        CALL CompareKeyword              // 'PROCEDURE'?
        JNE OSequence                    // No!
        MOV BYTE PTR [EBX + 1],otProcedure
        JMP Found
      OSequence:
        MOV EAX,[KSequence]
        CALL CompareKeyword              // 'SEQUENCE'?
        JNE OTable                       // No!
        MOV BYTE PTR [EBX + 1],otSequence
        JMP Found
      OTable:
        MOV EAX,[KTable]
        CALL CompareKeyword              // 'TABLE'?
        JNE OTrigger                     // No!
        MOV BYTE PTR [EBX + 1],otTable
        JMP Found
      OTrigger:
        MOV EAX,[KTrigger]
        CALL CompareKeyword              // 'TRIGGER'?
        JNE OView                        // No!
        MOV BYTE PTR [EBX + 1],otTrigger
        JMP Found
      OView:
        MOV EAX,[KView]
        CALL CompareKeyword              // 'VIEW'?
        JNE Finish                       // No!
        MOV BYTE PTR [EBX + 1],otView
        JMP Found

      // -------------------

      Found:
        MOV @Result,True                 // SQL is DDL!

        CALL Trim                        // Step over empty characters
        JECXZ Finish                     // End of SQL!

        CMP BYTE PTR [EBX + 0],dtAlter   // Alter statement?
        JNE Finish                       // No!
        CMP BYTE PTR [EBX + 1],otTable   // Table object?
        JE Rename                        // Yes!
        CMP BYTE PTR [EBX + 1],otEvent   // Event object?
        JE Rename                        // Yes!
        JMP Finish

      Rename:
        PUSH ESI

        MOV EAX,[KRename]
        MOV EDI,0                        // Don't copy inside MoveString
      RenameL:
        CMP ECX,0                        // End of SQL?
        JE RenameE                       // Yes!
        CMP WORD PTR [ESI],';'           // End of statement?
        JE RenameE                       // Yes!
        CALL Trim                        // Empty characters in SQL?
        JE RenameL                       // Yes!
        JECXZ Finish                     // End of SQL!
        CALL MoveString                  // Quoted string?
        JE RenameL                       // Yes!
        CALL CompareKeyword              // 'RENAME'?
        JNE RenameC                      // No!
        CALL Trim                        // Empty characters in SQL?
        JECXZ Finish                     // End of SQL!
        MOV BYTE PTR [EBX + 0],dtAlterRename
        PUSH ECX
        MOV ECX,ESI
        SUB ECX,Pointer(SQL)
        SHR ECX,1                        // 2 Bytes = 1 character
        MOV IndexNewObjectName,ECX
        POP ECX
        JMP RenameE
      RenameC:
        ADD ESI,2
      RenameLE:
        LOOP RenameL

      RenameE:
        POP ESI
        JMP Finish

      // -------------------

      Finish:
        MOV ECX,ESI
        SUB ECX,Pointer(SQL)
        SHR ECX,1                        // 2 Bytes = 1 character
        MOV Index,ECX

        MOV InCondCode,False
        TEST EDX,$80000000               // Are we inside cond. MySQL code?
        JZ Finish2                       // No!
        MOV InCondCode,True

      Finish2:
        POP EBX
        POP EDI
        POP ESI
        POP ES
  end;

  if (Result and SQLCreateParse(Parse, PChar(@SQL[Index]), Len - Index, Version, InCondCode)) then
  begin
    SQLParseKeyword(Parse, 'IF EXISTS');
    SQLParseKeyword(Parse, 'IF NOT EXISTS');
    DDLStmt.DatabaseName := '';
    if (DDLStmt.ObjectType = otDatabase) then
      DDLStmt.ObjectName := SQLParseValue(Parse)
    else
      Result := SQLParseObjectName(Parse, DDLStmt.DatabaseName, DDLStmt.ObjectName);
  end;
  if (Result and (DDLStmt.DefinitionType = dtAlterRename) and SQLCreateParse(Parse, PChar(@SQL[IndexNewObjectName]), Len - IndexNewObjectName, Version)) then
  begin
    SQLParseKeyword(Parse, 'TO');
    DDLStmt.NewDatabaseName := '';
    Result := SQLParseObjectName(Parse, DDLStmt.NewDatabaseName, DDLStmt.NewObjectName);
  end;
  Result := Result and (DDLStmt.ObjectName <> '');
end;

function SQLParseDMLStmt(out DMLStmt: TSQLDMLStmt; const SQL: PChar; const Len: Integer; const Version: Integer): Boolean;
label
  Insert, Update, Delete,
  Priority, Ignore, Into2,
  Found,
  From,
  Finish, FinishE;
var
  InCondCode: Boolean;
  Index: Integer;
  Parse: TSQLParse;
  TableName: string;
begin
  asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        PUSH DS                          // string operations uses ES
        POP ES

        MOV ESI,PChar(SQL)               // Scan characters from SQL
        MOV ECX,Len

        MOV EBX,DMLStmt

      // -------------------

        MOV @Result,False
        MOV EDI,0                        // Don't copy inside MoveString

        CALL Trim                        // Step over empty characters
        CMP ECX,0                        // End of SQL?
        JE Finish                        // Yes!

      Insert:
        MOV EAX,[KInsert]
        CALL CompareKeyword              // 'INSERT'?
        JNE Update                       // No!
        MOV BYTE PTR [EBX + 0],mtInsert
        JMP Found
      Update:
        MOV EAX,[KUpdate]
        CALL CompareKeyword              // 'UPDATE'?
        JNE Delete                       // No!
        MOV BYTE PTR [EBX + 0],mtUpdate
        JMP Found
      Delete:
        MOV EAX,[KDelete]
        CALL CompareKeyword              // 'DELETE'?
        JNE Finish                       // No!
        MOV BYTE PTR [EBX + 0],mtDelete
        JMP Found

      // -------------------

      Found:
        CALL Trim                        // Step over empty characters
        JECXZ Finish                     // End of SQL!

        MOV EAX,[KLowPriority]
        CALL CompareKeyword              // 'LOW_PRIORITY'?
        JE Ignore                        // No!
        MOV EAX,[KQuick]
        CALL CompareKeyword              // 'QUICK'?
        JE Ignore                        // No!
        MOV EAX,[KDelayed]
        CALL CompareKeyword              // 'DELAYED'?
        JE Ignore                        // No!
        MOV EAX,[KHighPriority]
        CALL CompareKeyword              // 'HIGH_PRIORITY'?
        JE Ignore                        // No!

      Ignore:
        CALL Trim                        // Step over empty characters
        JECXZ Finish                     // End of SQL!

        MOV EAX,[KIgnore]
        CALL CompareKeyword              // 'IGNORE'?

        CALL Trim                        // Step over empty characters
        JECXZ Finish                     // End of SQL!

        CMP BYTE PTR [EBX + 0],mtDelete  // DELETE?
        JE From

        MOV EAX,[KInto]
        CALL CompareKeyword              // 'INTO'?
        JNE Finish                       // No!
        MOV @Result,True                 // SQL is DML!
        CALL Trim                        // Step over empty characters
        JMP Finish

      From:
        MOV EAX,[KFrom]
        CALL CompareKeyword              // 'FROM'?
        JNE Finish                       // No!
        MOV @Result,True                 // SQL is DML!
        CALL Trim                        // Step over empty characters

      // -------------------

      Finish:
        MOV ECX,ESI
        SUB ECX,Pointer(SQL)
        SHR ECX,1                        // 2 Bytes = 1 character
        MOV Index,ECX

        MOV InCondCode,False
        TEST EDX,$80000000               // Are we inside cond. MySQL code?
        JZ FinishE                       // No!
        MOV InCondCode,True
      FinishE:

        POP EBX
        POP EDI
        POP ESI
        POP ES
  end;

  if (Result and SQLCreateParse(Parse, PChar(@SQL[Index]), Len - Index, Version, InCondCode)) then
    repeat
      TableName := SQLParseValue(Parse);
      if (TableName <> '') then
      begin
        SetLength(DMLStmt.DatabaseNames, System.Length(DMLStmt.DatabaseNames) + 1);
        SetLength(DMLStmt.TableNames, Length(DMLStmt.TableNames) + 1);
        DMLStmt.TableNames[Length(DMLStmt.TableNames) - 1] := TableName;

        if (not SQLParseChar(Parse, '.')) then
          DMLStmt.DatabaseNames[Length(DMLStmt.DatabaseNames) - 1] := ''
        else
        begin
          DMLStmt.DatabaseNames[Length(DMLStmt.DatabaseNames) - 1] := TableName;
          DMLStmt.TableNames[Length(DMLStmt.TableNames) - 1] := SQLParseValue(Parse);
        end;
      end;
    until (not SQLParseChar(Parse, ','));
end;

function SQLParseEnd(const Handle: TSQLParse): Boolean;
begin
  Result := (Handle.Len = 0) or (Handle.Pos[0] = ';');
end;

function SQLParseGetIndex(const Handle: TSQLParse): Integer;
begin
  Result := 1 + Handle.Pos - Handle.Start;
end;

function SQLParseKeyword(var Handle: TSQLParse; const Keyword: PChar; const IncrementIndex: Boolean = True): Boolean;
label
  Finish;
begin
    asm
        PUSH ESI
        PUSH EBX

        MOV EBX,Handle
        MOV ESI,[EBX + 0]                // Position in SQL
        MOV ECX,[EBX + 4]                // Characters left in SQL
        MOV EDX,[EBX + 8]                // MySQL version

        MOV @Result,False                // Keyword not found!

        MOV EAX,PChar(Keyword)
        CALL CompareKeyword              // Keyword?
        JNE Finish                       // No!

        MOV @Result,True                 // Keyword found!

        CMP IncrementIndex,False         // Increment Index?
        JE Finish                        // No!

        CALL Trim                        // Step over empty characters

        MOV [EBX + 0],ESI                // Position in SQL
        MOV [EBX + 4],ECX                // Characters left in SQL
        MOV [EBX + 8],EDX                // MySQL version

      Finish:
        POP EBX
        POP ESI
    end;
end;

function SQLParseObjectName(var Handle: TSQLParse; var DatabaseName: string; out ObjectName: string): Boolean;
begin
  ObjectName := SQLParseValue(Handle);
  if (SQLParseChar(Handle, '.')) then
  begin
    DatabaseName := ObjectName;
    ObjectName := SQLParseValue(Handle);
  end;
  Result := (ObjectName <> '');
end;

function SQLParseRest(var Handle: TSQLParse): string;
var
  Len: Integer;
begin
  Len := Handle.Len;
  while ((Len > 0) and CharInSet(Handle.Pos[Len - 1], [' ', #9, #10, #13])) do
    Dec(Len);
  SetString(Result, Handle.Pos, Len);
  Handle.Pos := @Handle.Pos[Len];
  Dec(Handle.Len, Len);
end;

function SQLParseValue(var Handle: TSQLParse; const TrimAfterValue: Boolean = True): string;
label
  StringL,
  Unquoted, Unquoted1, Unquoted2, UnquotedTerminatorsL, UnquotedTerminatorsE, UnquotedC, UnquotedLE,
  Quoted, QuotedE,
  Finish, FinishE;
const
  Terminators: PChar = #9#10#13#32'",-.:;=`'; // Characters, terminating the value
var
  BracketDeep: Integer;
  Len: Integer;
  OldPos: PChar;
begin
  Len := Handle.Len;
  SetLength(Result, Len);

  if (Len > 0) then
  begin
    OldPos := Handle.Pos;

    asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        PUSH DS                          // string operations uses ES
        POP ES
        CLD                              // string operations uses forward direction

        MOV EBX,Handle
        MOV ESI,[EBX + 0]                // Position in SQL
        MOV ECX,[EBX + 4]                // Characters left in SQL
        MOV EDX,[EBX + 8]                // MySQL Version
        MOV EAX,Result                   // Copy characters to Result
        MOV EDI,[EAX]
        MOV EDX,Len

      // -------------------

        MOV BracketDeep,0                // Bracket deep
      StringL:
        MOV AX,[ESI]                     // First character
        CMP AX,''''                      // Start quotation in SQL?
        JE Quoted                        // Yes!
        CMP AX,'"'                       // Start quotation in SQL?
        JE Quoted                        // Yes!
        CMP AX,'`'                       // Start quotation in SQL?
        JE Quoted                        // Yes!

      Unquoted:
        MOV AX,[ESI]                     // Character in SQL

        CALL MoveString                  // If quoted string: Copy it
        JE UnquotedLE                    // Quoted string!

        CMP AX,'('                       // Start brackets?
        JNE Unquoted1                    // No!
        INC BracketDeep                  // Open bracket
        CMP ECX,[EBX + 4]                // First character?
        JE UnquotedC                     // Yes!
        CMP BracketDeep,1                // First bracket?
        JE Finish                        // Yes!
        JMP UnquotedC

      Unquoted1:
        CMP AX,')'                       // End brackets?
        JNE Unquoted2                    // No!
        CMP BracketDeep,0                // Are we inside an brackts?
        JE Finish                        // No!
        DEC BracketDeep                  // Close bracket
        JNZ UnquotedC                    // We're still inside brackets!
        MOVSW                            // Copy closing bracket to Result
        JMP Finish

      Unquoted2:
        CMP BracketDeep,0                // Are we inside an brackts?
        JNE UnquotedC                    // Yes!

        CMP AX,';'                       // End of SQL statement?
        JE Finish                        // Yes!

        MOV EBX,Handle
        CMP ECX,[EBX + 4]                // First character?
        JE UnquotedC                     // Yes!

        MOV EBX,[Terminators]            // Terminating characters
      UnquotedTerminatorsL:
        CMP WORD PTR [EBX],0             // All terminators checked?
        JE UnquotedTerminatorsE          // Yes!
        CMP AX,[EBX]                     // Charcter in SQL = Terminator?
        JE Finish                        // Yes!
        ADD EBX,2                        // Next character in Terminators
        JMP UnquotedTerminatorsL
      UnquotedTerminatorsE:
        CMP AX,'/'                       // '/'?
        JNE UnquotedC                    // No!
        CMP ECX,2                        // Two or more characters left?
        JB UnquotedC                     // No!
        CMP WORD PTR [ESI + 2],'*'                // '/*'?
        JE Finish                        // Yes!

      UnquotedC:
        MOVSW                            // Copy character from SQL to Result
      UnquotedLE:
        JECXZ Finish                     // End of SQL!
        DEC ECX
        JMP StringL

      // -------------------

      Quoted:
        CALL UnescapeString              // Unquote and unescape string
        MOV ECX,EAX
        JECXZ Finish                     // End of SQL!
        CMP WORD PTR [ESI],'@'           // '@' in SQL?
        JNE QuotedE                      // No!
        MOVSW                            // Copy '@' from SQL to Result
        DEC ECX                          // '@' handled
        JMP StringL
      QuotedE:
        CMP BracketDeep,0                // Are we inside an brackts?
        JNE StringL                      // Yes!
        JMP Finish

      // -------------------

      Finish:
        MOV EAX,Result                   // Calculate new length of Result
        MOV EAX,[EAX]
        SUB EDI,EAX
        SHR EDI,1                        // 2 Bytes = 1 character
        MOV Len,EDI

        CMP TrimAfterValue,False
        JE FinishE

        MOV EBX,Handle
        MOV EDX,[EBX + 8]                // MySQL Version
        CALL Trim                        // Step over emtpy characters

      FinishE:
        MOV EBX,Handle
        MOV [EBX + 0],ESI                // Position in SQL
        MOV [EBX + 4],ECX                // Characters left in SQL

        POP EBX
        POP EDI
        POP ESI
        POP ES
    end;

    if ((Handle.Pos = OldPos) and (Handle.Len > 0) and (Handle.Pos[0] <> ';')) then
      raise ERangeError.Create('Empty Value' + #13#10
        + StrPas(Handle.Start));

    if (Len <> Length(Result)) then
      SetLength(Result, Len);
  end;
end;

function SQLParseValue(var Handle: TSQLParse; const Value: PChar; const TrimAfterValue: Boolean = True): Boolean;
label
  StringL,
  Quoted, QuotedE,
  Unquoted, UnquotedL, Unquoted1, Unquoted2, UnquotedTerminatorsL, UnquotedC, UnquotedLE,
  Compare,
  Found,
  Finish, Finish2, Finish3;
const
  Terminators: PChar = #9#10#13#32'",.:;=`'; // Characters, terminating the value
var
  BracketDeep: Integer;
  Buffer: PChar;
  DynamicBuffer: array of Char;
  Len: Integer;
  StackBuffer: array[0 .. 255] of Char;
begin
  if (Handle.Len > 0) then
  begin
    Len := StrLen(Value);

    if (Len <= Length(StackBuffer)) then
      Buffer := @StackBuffer[0]
    else
    begin
      SetLength(DynamicBuffer, Len);
      Buffer := @DynamicBuffer[0];
    end;

    asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        PUSH DS                          // string operations uses ES
        POP ES
        CLD                              // string operations uses forward direction

        MOV EBX,Handle
        MOV ESI,[EBX + 0]                // Position in SQL
        MOV ECX,[EBX + 4]                // Characters left in SQL
        MOV EDX,[EBX + 8]                // MySQL Version

        MOV EDI,Buffer
        MOV EDX,Len

        MOV @Result,False

      // -------------------

        MOV BracketDeep,0                // Bracket deep
      StringL:
        MOV AX,[ESI]                     // First character
        CMP AX,''''                      // Start quotation in SQL?
        JE Quoted                        // Yes!
        CMP AX,'"'                       // Start quotation in SQL?
        JE Quoted                        // Yes!
        CMP AX,'`'                       // Start quotation in SQL?
        JE Quoted                        // Yes!

      Unquoted:
      UnquotedL:
        MOV AX,[ESI]                     // Character in SQL

        CALL MoveString                  // If quoted string: Copy it
        JE UnquotedLE                    // Quoted string!

        CMP AX,'('                       // Start brackets?
        JNE Unquoted1                    // No!
        INC BracketDeep                  // Open bracket
        CMP ECX,[EBX + 4]                // First character?
        JE UnquotedC                     // Yes!
        CMP BracketDeep,1                // First bracket?
        JE Compare                       // Yes!
        JMP UnquotedC

      Unquoted1:
        CMP AX,')'                       // End brackets?
        JNE Unquoted2                    // No!
        CMP BracketDeep,0                // Are we inside an open brackt?
        JE Compare                       // No!
        DEC BracketDeep                  // Close bracket
        JNZ UnquotedC                    // We're still in open brackets!
        MOVSW                            // Copy closing bracket to Result
        JMP Compare

      Unquoted2:
        CMP BracketDeep,0                // Are we inside an brackts?
        JNE UnquotedC                    // Yes!

        CMP AX,';'                       // End of SQL statement?
        JE Compare                       // Yes!

        MOV EBX,Handle
        CMP ECX,[EBX + 4]                // First character?
        JE UnquotedC                     // Yes!

        MOV EBX,[Terminators]            // Terminating characters
      UnquotedTerminatorsL:
        CMP WORD PTR [EBX],0             // All terminators checked?
        JE UnquotedC                     // Yes!
        CMP AX,[EBX]                     // Charcter in SQL = Terminator?
        JE Compare                       // Yes!
        ADD EBX,2                        // Next character in Terminators
        JMP UnquotedTerminatorsL

      UnquotedC:
        MOVSW                            // Copy character from SQL to Result
      UnquotedLE:
        LOOP UnquotedL
        JMP Compare

      // -------------------

      Quoted:
        CALL UnescapeString              // Unquote and unescape string
        MOV ECX,EAX
        JECXZ Compare                    // End of SQL!
        CMP WORD PTR [ESI],'@'           // '@' in SQL?
        JNE QuotedE                      // No!
        MOVSW                            // Copy '@' from SQL to Result
        DEC ECX                          // '@' handled
        JMP StringL
      QuotedE:
        CMP BracketDeep,0                // Are we inside an brackts?
        JNE StringL                      // Yes!
        JMP Compare

      // -------------------

      Compare:
        SUB EDI,Buffer                   // Calculate length of found value
        SHR EDI,1                        // 2 Bytes = 1 character
        CMP EDI,Len                      // found length = length of value?
        JNE Finish                       // No!

        PUSH ESI
        PUSH ECX
        MOV ESI,Value
        MOV EDI,Buffer
        MOV ECX,Len
        REPE CMPSW                       // Found value = searched value?
        POP ECX
        POP ESI
        JNE Finish                       // No!

      Found:
        MOV @Result,True                 // Value found!

      Finish:
        CMP TrimAfterValue,False
        JE Finish2

        MOV EBX,Handle
        MOV EDX,[EBX + 8]                // MySQL Version
        CALL Trim                        // Step over emtpy characters

      Finish2:
        CMP @Result,True                 // Value found?
        JNE Finish3                      // No!

        MOV EBX,Handle
        MOV [EBX + 0],ESI                // Position in SQL
        MOV [EBX + 4],ECX                // Characters left in SQL

      Finish3:
        POP EBX
        POP EDI
        POP ESI
        POP ES
    end;
  end;
end;

function SQLSingleStmt(const SQL: string): Boolean;
var
  CompleteStmt: Boolean;
  Len: Integer;
  LocalSQL: string;
begin
  LocalSQL := SysUtils.Trim(SQL);
  Len := SQLStmtLength(PChar(LocalSQL), Length(LocalSQL), @CompleteStmt);
  Result := (0 < Len) and (not CompleteStmt or (Len >= Length(LocalSQL)));
end;

procedure SQLSplitValues(const Text: string; out Values: TSQLStrings);
label
  Start,
  UnquotedL,
  Quoted, QuotedL, Quoted2, QuotedLE,
  Finish, FinishL, Finish2, Finish3, Finish4, Finish5, FinishE;
var
  EOF: Boolean;
  EOL: Boolean;
  Len: Integer;
  SQL: PChar;
  Value: Integer;
  ValueData: PChar;
  ValueLength: Integer;
begin
  if (Text = '') then
    SetLength(Values, 0)
  else
  begin
    Value := 0;
    SQL := PChar(Text);
    Len := Length(Text);
    repeat
      if (Value >= Length(Values)) then
        SetLength(Values, 2 * Value + 1);

      asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        MOV ESI,SQL                      // Get character from Text

        MOV ECX,Len
        CMP ECX,0                        // Are there characters left in SQL?
        JNE Start                        // Yes!
        MOV EOL,True
        MOV EOF,True
        JMP Finish

      // -------------------

      Start:
        MOV ValueData,ESI                // Start of value
        MOV AX,[ESI]                     // Get character from Text
        CMP AX,''''                      // Character in Text = Quoter?
        JE Quoted                        // Yes!

      // -------------------

      UnquotedL:
        MOV AX,[ESI]                     // Get character from Text
        CMP AX,','                       // Character = Delimiter?
        JE Finish                        // Yes!
        CMP AX,13                        // Character = CarrigeReturn?
        JE Finish                        // Yes!
        CMP AX,10                        // Character = NewLine?
        JE Finish                        // Yes!
        ADD ESI,2                        // Next character!
        LOOP UnquotedL
        JMP Finish

      // -------------------

      Quoted:
        ADD ESI,2                        // Step over starting Quoter
        DEC ECX                          // Starting Quoter handled
        JZ Finish                        // End of Text!
      QuotedL:
        MOV AX,[ESI]                     // Get character from Text
        CMP AX,''''                      // Character = Quoter?
        JNE Quoted2                      // No!
        ADD ESI,2                        // Step over ending Quoter
        DEC ECX                          // Ending Quoter handled
        JMP Finish
      Quoted2:
        CMP AX,'\'                       // Character = Escaper?
        JNE QuotedLE                     // No!
        ADD ESI,2                        // Step over Escaper
        DEC ECX                          // Escaper handled
        JZ Finish                        // End of Text!
        MOV AX,[ESI]                     // Get character from Text
        CMP AX,''''                      // Character = Quoter?
        JNE QuotedLE                     // No!
        ADD ESI,2                        // Step over ending Quoter
        DEC ECX                          // Ending Quoter handled
        JMP Finish                       // End of Text!
      QuotedLE:
        ADD ESI,2                        // Next character!
        LOOP QuotedL

      // -------------------

      Finish:
        MOV EAX,Len                      // Calculate length of value
        SUB EAX,ECX
        MOV ValueLength,EAX

      FinishL:
        CMP ECX,0                        // Are there characters left in SQL?
        JNE Finish2                      // Yes!
        MOV EOL,True
        MOV EOF,True
        JMP FinishE
      Finish2:
        MOV EOF,False
        MOV AX,[ESI]                     // Get character from Text
        CMP AX,','                       // Delimiter?
        JNE Finish3
        ADD ESI,2                        // Step over Delimiter
        DEC ECX                          // Ignore Delimiter
        MOV EOL,False
        JMP FinishE
      Finish3:
        MOV EOL,True
        CMP ECX,2                        // Are there two characters left in SQL?
        JB Finish4                       // No!
        MOV EAX,[ESI]
        CMP EAX,$000A000D                // CarriageReturn + LineFeed?
        JNE Finish4
        ADD ESI,4                        // Step over CarriageReturn + LineFeed
        SUB ECX,2                        // Ignore CarriageReturn + LineFeed
        JMP FinishE
      Finish4:
        CMP AX,13                        // CarriageReturn?
        JE Finish5
        CMP AX,10                        // LineFeed?
        JE Finish5
        ADD ESI,2                        // Step over unknow character
        DEC ECX                          // Ignore unknow character
        JMP FinishL
      Finish5:
        ADD ESI,2                        // Step over CarriageReturn / LineFeed
        DEC ECX                          // Ignore CarriageReturn / LineFeed
        JMP FinishE

      FinishE:
        MOV SQL,ESI
        MOV Len,ECX

        POP EBX
        POP EDI
        POP ESI
        POP ES
      end;

      SetString(Values[Value], ValueData, ValueLength);
      Inc(Value);
    until (EOL or EOF);

    if (Value <> Length(Values)) then
      SetLength(Values, Value);
  end;
end;

function LeftTrimNew(var SQL: PChar; var Len: Integer; const Version: Integer; var CondVersion: Integer): Boolean;
var
  Found: Boolean;
  OldLen: Integer;
  Ver: Integer;
begin
  OldLen := Len;

  Found := True;
  while (Found) do
  begin
    Found := False;
    if (Len >= 1) then
      if ((SQL[0] = #9) or (SQL[0] = #10) or (SQL[0] = #13) or (SQL[0] = ' ')) then
      begin
        Found := True;
        Inc(SQL); Dec(Len);
      end
      else if ((SQL[0] = '#')
        or ((Len >= 3) and (SQL[0] = '-') and (SQL[1] = '-') and ((SQL[2] = #9) or (SQL[2] = #10) or (SQL[2] = #13) or (SQL[2] = ' ')))) then
      begin
        Found := True;
        while (Len > 0) do
          if ((SQL[0] = #10) or (SQL[0] = #13)) then
            break
          else
          begin
            Inc(SQL); Dec(Len);
          end;
      end
      else if ((Len >= 2) and (SQL[0] = '/') and (SQL[1] = '*')) then
      begin
        Found := True;
        Inc(SQL); Dec(Len);
        Inc(SQL); Dec(Len);
        if ((Len >= 1) and (SQL[0] = '!')) then
        begin
          Inc(SQL); Dec(Len);
          Ver := 0;
          while ((Len >= 1) and ('0' <= SQL[0]) and (SQL[0] <= '9')) do
          begin
            Ver := Ver * 10 + Byte(SQL[0]) - Byte('0');
            Inc(SQL); Dec(Len);
          end;
          if (Version < Ver) then
          begin
            while ((Len >= 2) and (SQL[0] <> '*') or (SQL[1] <> '/')) do
            begin
              Inc(SQL); Dec(Len);
            end;
            if ((Len >= 2) and (SQL[0] = '*') and (SQL[1] = '/')) then
            begin
              Inc(SQL); Dec(Len);
              Inc(SQL); Dec(Len);
            end;
          end;
        end
        else
        begin
          while ((Len >= 2) and (SQL[0] <> '*') or (SQL[1] <> '/')) do
          begin
            Inc(SQL); Dec(Len);
          end;
          if ((Len >= 2) and (SQL[0] = '*') and (SQL[1] = '/')) then
          begin
            Inc(SQL); Dec(Len);
            Inc(SQL); Dec(Len);
          end;
        end;
      end
      else if ((Len >= 2) and (SQL[0] = '*') and (SQL[1] = '/')) then
      begin
        Found := True;
        Inc(SQL); Dec(Len);
        Inc(SQL); Dec(Len);
      end;
  end;

  Result := Len < OldLen;
end;

function CompareKeywordNew(var SQL: PChar; var Len: Integer; const Keyword: PChar): Boolean;
var
  I: Integer;
begin
  I := 0;
  while ((Len - I >= 1) and (Char(Byte(SQL[I]) and not $20) = Keyword[I]) and (Keyword[I] <> #0)) do
    Inc(I);
  Result := Keyword[I] = #0;
  Result := Result and ((Len = 0) or not (('A' <= SQL[I]) and (SQL[I] <= 'Z')) and not (('a' <= SQL[I]) and (SQL[I] <= 'z')) and not (SQL[I] = '_'));
  if (Result) then
  begin
    Inc(SQL, I); Dec(Len, I);
  end;
end;

function CopyStringNew(var SQL: PChar; var Len: Integer): Boolean;
var
  Quoter: Char;
begin
  Result := False;
  while ((Len >= 1) and ((SQL[0] = '"') or (SQL[0] = '''') or (SQL[0] = '`'))) do
  begin
    Result := True;
    Quoter := SQL[0];
    Inc(SQL); Dec(Len);
    while ((Len >= 1) and (SQL[0] <> Quoter)) do
    begin
      if (SQL[0] = '\') then
      begin
        Inc(SQL); Dec(Len);
      end;
      if (Len >= 1) then
      begin
        Inc(SQL); Dec(Len);
      end;
    end;
    if ((Len >= 1) and (SQL[0] = Quoter)) then
    begin
      Inc(SQL); Dec(Len);
    end;
  end;
end;

function BracketAreaNew(var SQL: PChar; var Len: Integer; const Version: Integer; var CondVersion: Integer): Boolean;
var
  Deep: Integer;
begin
  Result := (Len >= 0) and (SQL[0] = '(');
  if (Result) then
  begin
    Deep := 1;
    Inc(SQL); Dec(Len);
    while ((Len >= 1) and ((SQL[0] <> ')') or (Deep > 1))) do
    begin
      if (SQL[0] = '(') then
      begin
        Inc(Deep);
        Inc(SQL); Dec(Len);
      end
      else if (SQL[0] = ')') then
      begin
        Dec(Deep);
        Inc(SQL); Dec(Len);
      end
      else if (not LeftTrimNew(SQL, Len, Version, CondVersion)
        and not CopyStringNew(SQL, Len)) then
      begin
        Inc(SQL); Dec(Len);
      end;
    end;
    if ((Len >= 1) and (SQL[0] = ')')) then
    begin
      Inc(SQL); Dec(Len);
    end;
  end;
end;

function SQLStmtLengthNew(SQL: PChar; Len: Integer; const Delimited: PBoolean = nil): Integer;
const
  Version = $7FFFFFFF;
var
  CaseDeep: Integer;
  CompoundDeep: Integer;
  CondVersion: Integer;
  IfDeep: Integer;
  LoopDeep: Integer;
  OldLen: Integer;
  RepeatDeep: Integer;
  SimpleBody: Boolean;
  WhileDeep: Integer;
begin
  OldLen := Len;

  CondVersion := 0;

  CaseDeep := 0;
  CompoundDeep := 0;
  IfDeep := 0;
  LoopDeep := 0;
  RepeatDeep := 0;
  WhileDeep := 0;

  LeftTrimNew(SQL, Len, Version, CondVersion);

  SimpleBody := False;
  if (CompareKeywordNew(SQL, Len, KAlter)
    or CompareKeywordNew(SQL, Len, KCreate)) then
  begin
    LeftTrimNew(SQL, Len, Version, CondVersion);
    if (CompareKeywordNew(SQL, Len, KDatabase)
      or CompareKeywordNew(SQL, Len, KTable)) then
      SimpleBody := True;
  end
  else if (CompareKeywordNew(SQL, Len, KBegin)) then
    Inc(CompoundDeep)
  else if (CompareKeywordNew(SQL, Len, KCase)) then
    Inc(CaseDeep)
  else if (CompareKeywordNew(SQL, Len, KIf)) then
    Inc(IfDeep)
  else if (CompareKeywordNew(SQL, Len, KLoop)) then
    Inc(LoopDeep)
  else if (CompareKeywordNew(SQL, Len, KRepeat)) then
    Inc(RepeatDeep)
  else if (CompareKeywordNew(SQL, Len, KWhile)) then
    Inc(WhileDeep)
  else
    SimpleBody := True;

  if (SimpleBody) then
  begin
    while (Len > 0) do
      if (not LeftTrimNew(SQL, Len, Version, CondVersion)
        and not CopyStringNew(SQL, Len)) then
        if (SQL[0] = ';') then
          break
        else
        begin
          Inc(SQL); Dec(Len);
        end;
  end
  else
  begin
    repeat
      if (not LeftTrimNew(SQL, Len, Version, CondVersion)
        and not CopyStringNew(SQL, Len)
        and not BracketAreaNew(SQL, Len, Version, CondVersion)) then
        if (CompareKeywordNew(SQL, Len, KBegin)) then
          Inc(CompoundDeep)
        else if (CompareKeywordNew(SQL, Len, KCase)) then
        begin
          LeftTrimNew(SQL, Len, Version, CondVersion);
          if ((Len >= 0) and (SQL[0] = '(')) then
            BracketAreaNew(SQL, Len, Version, CondVersion)
          else
            Inc(CaseDeep);
        end
        else if (CompareKeywordNew(SQL, Len, KIf)) then
        begin
          LeftTrimNew(SQL, Len, Version, CondVersion);
          if ((Len >= 0) and (SQL[0] = '(')) then
          begin
            BracketAreaNew(SQL, Len, Version, CondVersion);
            if (CompareKeywordNew(SQL, Len, KThen)) then
              Inc(IfDeep);
          end
          else if (not CompareKeywordNew(SQL, Len, KNot)
            and not CompareKeywordNew(SQL, Len, KExists)) then
            Inc(IfDeep);
        end
        else if (CompareKeywordNew(SQL, Len, KLoop)) then
          Inc(LoopDeep)
        else if (CompareKeywordNew(SQL, Len, KRepeat)) then
          Inc(RepeatDeep)
        else if (CompareKeywordNew(SQL, Len, KWhile)) then
          Inc(WhileDeep)
        else if (BracketAreaNew(SQL, Len, Version, CondVersion)) then
          // Do nothing
        else if (CompareKeywordNew(SQL, Len, KEnd)) then
        begin
          LeftTrimNew(SQL, Len, Version, CondVersion);
          if (CompareKeywordNew(SQL, Len, KCase)) then
          begin
            if (CaseDeep > 0) then Dec(CaseDeep);
          end
          else if (CompareKeywordNew(SQL, Len, KIf)) then
          begin
            if (IfDeep > 0) then Dec(IfDeep);
          end
          else if (CompareKeywordNew(SQL, Len, KLoop)) then
          begin
            if (LoopDeep > 0) then Dec(LoopDeep);
          end
          else if (CompareKeywordNew(SQL, Len, KRepeat)) then
          begin
            if (RepeatDeep > 0) then Dec(RepeatDeep);
          end
          else if (CompareKeywordNew(SQL, Len, KWhile)) then
          begin
            if (WhileDeep > 0) then Dec(WhileDeep);
          end
          else
          begin
            if (CompoundDeep > 0) then Dec(CompoundDeep);
          end;
        end
        else if (Len >= 1) then
        begin
          if (not ('A' <= SQL[0]) and (SQL[0] <= 'Z'))
            and not (('a' <= SQL[0]) and (SQL[0] <= 'z')
            and not (SQL[0] = '_')) then
          begin
            Inc(SQL); Dec(Len);
          end
          else
            repeat
              Inc(SQL); Dec(Len);
            until ((Len = 0)
              or not (('A' <= SQL[0]) and (SQL[0] <= 'Z'))
                and not (('a' <= SQL[0]) and (SQL[0] <= 'z'))
                and not (SQL[0] = '_'));
        end;
    until ((Len = 0)
      or (SQL[0] = ';')
        and (CompoundDeep = 0)
        and (CaseDeep = 0)
        and (IfDeep = 0)
        and (LoopDeep = 0)
        and (RepeatDeep = 0)
        and (WhileDeep = 0));
  end;


  if (Assigned(Delimited)) then
    Delimited^ := SQL[0] = ';';

  if ((Len >= 1) and (SQL[0] = ';')) then
  begin
    Inc(SQL); Dec(Len);
  end;
  if ((Len >= 1) and (SQL[0] = #13)) then
  begin
    Inc(SQL); Dec(Len);
  end;
  if ((Len >= 1) and (SQL[0] = #10)) then
  begin
    Inc(SQL); Dec(Len);
  end;

  Result := OldLen - Len;
end;

function SQLStmtLength(SQL: PChar; Len: Integer; const Delimited: PBoolean = nil): Integer;
var
  S: string;
begin
  Result := 0;
  try
    Result := SQLStmtLengthNew(SQL, Len, Delimited);
  except
    on E: Exception do
      begin
        SetString(S, SQL, Len);
        E.RaiseOuterException(EAssertionFailed.Create(E.ClassName + #13#10
          + E.Message + #13#10
          + 'SQL: ' + #13#10
          + S));
      end;
  end;
end;

function SQLStmtToCaption(const SQL: string; const Len: Integer = 50): string;
begin
  if (Length(SQL) <= Len) then
    Result := SQL
  else
    Result := copy(SQL, 1, Len) + '...';
end;

function UnescapeStringNew(var SQL: PChar; var Len: Integer; var Unescaped: PChar; var UnescapedLen: Integer): Integer;
var
  Quoter: Char;
begin
  Result := 0;
  Quoter := SQL[0];
  Inc(SQL); Dec(Len); // Opening quoter
  while ((Len >= 1) and (SQL[0] <> Quoter)) do
  begin
    if ((SQL[0] <> '\') or (Len < 2)) then
    begin
      if (Assigned(Unescaped)) then
      begin
        if (UnescapedLen = 0) then
          Exit(0);
        Unescaped^ := SQL^; Inc(Unescaped); Dec(UnescapedLen);
      end;
      Inc(SQL); Dec(Len); Inc(Result);
    end
    else if ((SQL[1] = '"') or (SQL[1] = '''') or (SQL[1] = '`')) then
    begin
      Inc(SQL); Dec(Len); // Escaper
      if (Assigned(Unescaped)) then
      begin
        if (UnescapedLen = 0) then
          Exit(0);
        Unescaped^ := SQL^; Inc(Unescaped); Dec(UnescapedLen);
      end;
      Inc(SQL); Dec(Len); Inc(Result);
    end
    else if (SQL[1] = '0') then
    begin
      Inc(SQL); Dec(Len); // Escaper
      if (Assigned(Unescaped)) then
      begin
        if (UnescapedLen = 0) then
          Exit(0);
        Unescaped^ := #0; Inc(Unescaped); Dec(UnescapedLen);
      end;
      Inc(SQL); Dec(Len); Inc(Result);
    end
    else if ((SQL[1] = 'B') or (SQL[1] = 'b')) then
    begin
      Inc(SQL); Dec(Len); // Escaper
      if (Assigned(Unescaped)) then
      begin
        if (UnescapedLen = 0) then
          Exit(0);
        Unescaped^ := #8; Inc(Unescaped); Dec(UnescapedLen);
      end;
      Inc(SQL); Dec(Len); Inc(Result);
    end
    else if ((SQL[1] = 'N') or (SQL[1] = 'n')) then
    begin
      Inc(SQL); Dec(Len); // Escaper
      if (Assigned(Unescaped)) then
      begin
        if (UnescapedLen = 0) then
          Exit(0);
        Unescaped^ := #10; Inc(Unescaped); Dec(UnescapedLen);
      end;
      Inc(SQL); Dec(Len); Inc(Result);
    end
    else if ((SQL[1] = 'R') or (SQL[1] = 'r')) then
    begin
      Inc(SQL); Dec(Len); // Escaper
      if (Assigned(Unescaped)) then
      begin
        if (UnescapedLen = 0) then
          Exit(0);
        Unescaped^ := #13; Inc(Unescaped); Dec(UnescapedLen);
      end;
      Inc(SQL); Dec(Len); Inc(Result);
    end
    else if ((SQL[1] = 'T') or (SQL[1] = 't')) then
    begin
      Inc(SQL); Dec(Len); // Escaper
      if (Assigned(Unescaped)) then
      begin
        if (UnescapedLen = 0) then
          Exit(0);
        Unescaped^ := #9; Inc(Unescaped); Dec(UnescapedLen);
      end;
      Inc(SQL); Dec(Len); Inc(Result);
    end
    else if ((SQL[1] = 'Z') or (SQL[1] = 'z')) then
    begin
      Inc(SQL); Dec(Len); // Escaper
      if (Assigned(Unescaped)) then
      begin
        if (UnescapedLen = 0) then
          Exit(0);
        Unescaped^ := #26; Inc(Unescaped); Dec(UnescapedLen);
      end;
      Inc(SQL); Dec(Len); Inc(Result);
    end
    else
    begin
      Inc(SQL); Dec(Len); // Escaper
      if (Assigned(Unescaped)) then
      begin
        if (UnescapedLen = 0) then
          Exit(0);
        Unescaped^ := SQL^; Inc(Unescaped); Dec(UnescapedLen);
      end;
      Inc(SQL); Dec(Len); Inc(Result);
    end;
  end;
  if ((Len >= 1) and (SQL[0] = Quoter)) then
  begin
    Inc(SQL); Dec(Len); // Closing quoter
  end;
end;

function SQLUnescapeNew(SQL: PChar; SQLLen: Integer; Unescaped: PChar; UnescapedLen: Integer): Integer; overload;
var
  Len: Integer;
begin
  Result := 0;
  while (SQLLen >= 1) do
    if ((SQL^ <> '"') and (SQL^ <> '''') and (SQL^ <> '`')) then
    begin
      if (Assigned(Unescaped)) then
      begin
        if (UnescapedLen < 1) then
          Exit(0);
        Unescaped^ := SQL^; Inc(Unescaped); Dec(UnescapedLen);
      end;
      Inc(SQL); Dec(SQLLen); Inc(Result);
    end
    else
    begin
      Len := UnescapeStringNew(SQL, SQLLen, Unescaped, UnescapedLen);
      if (Len = 0) then
        Exit(0); // Unescaped too small
      Inc(Result, Len);
      if (SQLLen = 0) then
        Exit;
      while ((SQLLen >= 1) and ((SQL^ = #9) or (SQL^ = #10) or (SQL^ = #13) or (SQL^ = ' '))) do
      begin
        Inc(SQL); Dec(SQLLen);
      end;
    end;
end;

function SQLUnescape(const Value: PChar; const ValueLen: Integer; const Unescaped: PChar; const UnescapedLen: Integer): Integer;
label
  Start, StartLE,
  Quoted, QuotedL, QuotedLE,
  Error, Success, Finish;
begin
  asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        PUSH DS                          // string operations uses ES
        POP ES
        CLD                              // string operations uses forward direction

        MOV ESI,Value                    // Copy characters from Value
        MOV EDI,Unescaped                //   to Unescaped
        MOV ECX,ValueLen
        MOV EDX,UnescapedLen

        MOV EBX,0                        // Needed length in Unescaped

        CMP ECX,0                        // End of SQL?
        JE Success                       // Yes!

      // -------------------

      Start:
        MOV AX,[ESI]                     // Get character from Value
        CMP AX,''''                      // Start quotation in SQL?
        JE Quoted                        // Yes!
        CMP AX,'"'                       // Start quotation in SQL?
        JE Quoted                        // Yes!
        CMP AX,'`'                       // Start quotation in SQL?
        JE Quoted                        // Yes!
        INC EBX                          // One character needed in Unescape
        CMP EDI,0                        // Store the string somewhere?
        JE StartLE                       // No!
        CMP EDX,0                        // One charcacter left in Unescaped?
        JE Error                         // No!
        STOSW                            // Store one character
        DEC EDX                          // One character filled to Unescaped
      StartLE:
        ADD ESI,2                        // Once character handled
        LOOP Start
        JMP Success

      Quoted:
        CALL UnescapeString              // Copy and unescape quoted string
        MOV ECX,EAX
        JZ Error                         // Unescaped too small

      QuotedL:
        CMP ECX,0                        // End of SQL?
        JE Success                       // Yes!
        MOV AX,[ESI]
        CMP AX,9                         // Tabulator?
        JE QuotedLE                      // Yes!
        CMP AX,10                        // NewLine?
        JE QuotedLE                      // Yes!
        CMP AX,13                        // CarriadgeReturn?
        JE QuotedLE                      // Yes!
        CMP AX,' '                       // Space?
        JE QuotedLE                      // Yes!
        JMP Start
      QuotedLE:
        ADD ESI,2                        // One character handled
        LOOP QuotedL
        JMP Success

      // -------------------

      Error:
        MOV @Result,0                    // UnescapedLen too small
        JMP Finish

      Success:
        MOV @Result,EBX                  // Needed / used size in Unescape
        JMP Finish

      Finish:
        POP EBX
        POP EDI
        POP ESI
        POP ES
  end;
end;

function SQLUnescapeNew(const Value: string): string; overload;
var
  Len: Integer;
begin
  if (Value = '') then
    Result := ''
  else
  begin
    Len := SQLUnescapeNew(PChar(Value), Length(Value), nil, 0);
    SetLength(Result, Len);
    SQLUnescapeNew(PChar(Value), Length(Value), PChar(Result), Length(Result));
  end;
end;

function SQLUnescape(const Value: string): string;
var
  Len: Integer;
begin
  if (Value = '') then
    Result := ''
  else
  begin
    Len := SQLUnescape(PChar(Value), Length(Value), nil, 0);
    SetLength(Result, Len);
    SQLUnescape(PChar(Value), Length(Value), PChar(Result), Length(Result));
  end;
end;

function StrToUInt64(const S: string): UInt64;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(S) do
    if (('0' <= S[I]) and (S[I] <= '9')) then
      Result := Result * 10 + Ord(S[I]) - Ord('0')
    else
      raise ERangeError.Create(SInvalidInput);
end;

function TryStrToUInt64(const S: string; out Value: UInt64): Boolean;
begin
  try
    Value := StrToUInt64(S);
    Result := True;
  except
    Result := False;
  end;
end;

function UInt64ToStr(Value: UInt64): string;
begin
  while (Value > 0) do
  begin
    Result := Chr(Ord('0') + Value mod 10) + Result;
    Value := Value div 10;
  end;
  if (Result = '') then
    Result := '0';
end;

{ TSQLBuffer ******************************************************************}

procedure TSQLBuffer.Clear();
begin
  Buffer.Write := Buffer.Mem;
end;

constructor TSQLBuffer.Create(const InitialLength: Integer);
begin
  Buffer.Mem := nil;
  Buffer.MemSize := 0;
  Buffer.Write := nil;

  Reallocate(InitialLength);
end;

procedure TSQLBuffer.Delete(const Start: Integer; const Length: Integer);
begin
  Move(Buffer.Mem[Start + Length], Buffer.Mem[Start], Size - Length);
  Buffer.Write := Pointer(Integer(Buffer.Write) - Length);
end;

destructor TSQLBuffer.Destroy();
begin
  FreeMem(Buffer.Mem);

  inherited;
end;

function TSQLBuffer.GetData(): Pointer;
begin
  Result := Pointer(Buffer.Mem);
end;

function TSQLBuffer.GetLength(): Integer;
begin
  Result := (Integer(Buffer.Write) - Integer(Buffer.Mem)) div SizeOf(Buffer.Mem[0]);
end;

function TSQLBuffer.GetSize(): Integer;
begin
  Result := Integer(Buffer.Write) - Integer(Buffer.Mem);
end;

function TSQLBuffer.GetText(): PChar;
begin
  Result := Buffer.Mem;
end;

function TSQLBuffer.Read(): string;
begin
  SetString(Result, PChar(Buffer.Mem), Size div SizeOf(Result[1]));
  Clear();
end;

procedure TSQLBuffer.Reallocate(const NeededLength: Integer);
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

procedure TSQLBuffer.Write(const Text: PChar; const Length: Integer);
begin
  if (Length > 0) then
  begin
    Reallocate(Length);

    Move(Text^, Buffer.Write^, Length * SizeOf(Buffer.Mem[0]));
    Buffer.Write := @Buffer.Write[Length];
  end;
end;

procedure TSQLBuffer.Write(const Text: string);
begin
  Write(PChar(Text), System.Length(Text));
end;

procedure TSQLBuffer.WriteChar(const Char: Char);
begin
  Reallocate(1);
  Move(Char, Buffer.Write^, SizeOf(Char));
  Buffer.Write := @Buffer.Write[1];
end;

procedure TSQLBuffer.WriteData(Value: PAnsiChar; ValueLen: Integer; Quote: Boolean = False; Quoter: Char = '''');
begin
  if (not Quote) then
    Reallocate(Length)
  else
    Reallocate(1 + Length + 1);

  if (Length > 0) then
  begin
    if (Quote) then
    begin
      Buffer.Write^ := Quoter; Inc(Buffer.Write);
    end;

    while (ValueLen > 0) do
    begin
      Buffer.Write^ := Char(Value^); Inc(Buffer.Write); Inc(Value); Dec(ValueLen);
    end;

    if (Quote) then
    begin
      Buffer.Write^ := Quoter; Inc(Buffer.Write);
    end;
  end;
end;

function TSQLBuffer.WriteExternal(const Length: Integer): PChar;
begin
  if (Length = 0) then
    Result := nil
  else
  begin
    Reallocate(Length);

    Result := Buffer.Write;

    Buffer.Write := @Buffer.Write[Length];
  end;
end;

procedure TSQLBuffer.WriteText(const Text: PChar; const Length: Integer);
var
  Len: Integer;
begin
  Len := SQLEscape(Text, Length, nil, 0);
  if (Len > 0) then
    SQLEscape(Text, Length, WriteExternal(Len), Len);
end;

begin
  {$IFDEF Debug}
  SQLUnescapeNew('H"a\r\n"123');
  {$ENDIF}
end.


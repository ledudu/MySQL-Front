unit uPreferences;

interface {********************************************************************}

uses
  Windows,
  Classes, SysUtils, IniFiles,
  Registry,
  XMLDoc, XMLIntf,
  Controls, Forms, ComCtrls, Graphics,
  BCEditor.Editor;

type
  TExportType = (etUnknown, etSQLFile, etTextFile, etExcelFile, etAccessFile, etODBC, etHTMLFile, etXMLFile, etPDFFile);
  TImportType = (itUnknown, itSQLFile, itTextFile, itAccessFile, itExcelFile, itODBC);
  TAccountColumn = (acName, acHost, acUser, acDatabase, acLastLogin);

  TPAccounts = class;

  TPPreferences = class(TRegistry)
  type
    TItems = class;

    TDelimiterType = (dtTab, dtChar);
    TNodeType = (ntDisabled, ntName, ntCustom);
    TStmtType = (stInsert, stReplace, stUpdate, stInsertOrUpdate);
    TQuotingType = (qtNone, qtStrings, qtAll);

    TItem = class
    private
      FName: string;
    protected
      FAItems: TItems;
      function GetIndex(): Integer; inline;
      procedure LoadFromXML(const XML: IXMLNode); virtual; abstract;
      procedure SaveToXML(const XML: IXMLNode); virtual; abstract;
    public
      procedure Assign(const Source: TItem); virtual;
      constructor Create(const AAItems: TItems; const AName: string = '');
      property AItems: TItems read FAItems;
      property Index: Integer read GetIndex;
      property Name: string read FName write FName;
    end;

    TItems = class(TList)
    private
      function GetItem(Index: Integer): TItem; inline;
    protected
      function InsertIndex(const Name: string; out Index: Integer): Boolean; virtual;
    public
      function Add(const AItem: TItem): Integer; overload; virtual;
      procedure Clear(); override;
      function IndexByName(const Name: string): Integer; virtual;
      property Item[Index: Integer]: TItem read GetItem; default;
    end;

    TMRUList = class
    private
      FMaxCount: Integer;
      function GetCount(): Integer;
    protected
      FValues: array of string;
      function Get(Index: Integer): string; inline;
    public
      procedure Add(const Value: string); virtual;
      procedure Assign(const Source: TMRUList); virtual;
      procedure Clear(); virtual;
      constructor Create(const AMaxCount: Integer); virtual;
      procedure Delete(const Index: Integer);
      destructor Destroy(); override;
      function IndexOf(const Value: string): Integer; virtual;
      procedure LoadFromXML(const XML: IXMLNode; const NodeName: string); virtual;
      procedure SaveToXML(const XML: IXMLNode; const NodeName: string); virtual;
      property Count: Integer read GetCount;
      property Items[Index: Integer]: string read Get; default;
      property MaxCount: Integer read FMaxCount;
    end;

    TWindow = class(TItem)
    protected
      procedure LoadFromXML(const XML: IXMLNode); override;
      procedure SaveToXML(const XML: IXMLNode); override;
    public
      Height: Integer;
      Width: Integer;
      constructor Create(); virtual;
    end;

    TDatabase = class(TWindow);

    TDatabases = class(TWindow);

    TEditor = class
    protected
      procedure LoadFromXML(const XML: IXMLNode); virtual;
      procedure SaveToXML(const XML: IXMLNode); virtual;
    public
      CodeCompletion: Boolean;
      CodeCompletionTime: Integer;
      CurrRowBGColorEnabled: Boolean;
      CurrRowBGColor: TColor;
      WordWrap: Boolean;
      constructor Create(); virtual;
    end;

    TEvent = class(TWindow);

    TExport = class(TWindow)
    protected
      procedure LoadFromXML(const XML: IXMLNode); override;
      procedure SaveToXML(const XML: IXMLNode); override;
    public
      CSV: record
        Headline: Boolean;
        QuoteValues: TQuotingType;
        Quoter: Char;
        Delimiter: string;
        DelimiterType: TDelimiterType;
      end;
      Excel: record
        Excel2003: Boolean;
      end;
      Access: record
        Access2003: Boolean;
      end;
      HTML: record
        Data: Boolean;
        NULLText: Boolean;
        MemoContent: Boolean;
        Structure: Boolean;
      end;
      ODBC: record
        DataSource: string;
      end;
      SQL: record
        Data: Boolean;
        DropStmts: Boolean;
        ReplaceData: Boolean;
        Structure: Boolean;
      end;
      XML: record
        Database: record
          NodeType: TNodeType;
          NodeText: string;
          NodeAttribute: string;
        end;
        Field: record
          NodeType: TNodeType;
          NodeText: string;
          NodeAttribute: string;
        end;
        Row: record
          NodeText: string;
        end;
        Root: record
          NodeText: string;
        end;
        Table: record
          NodeType: TNodeType;
          NodeText: string;
          NodeAttribute: string;
        end;
      end;
      procedure Assign(const Source: TItem); override;
      constructor Create(const AAItems: TItems = nil; const AName: string = ''); reintroduce; virtual;
    end;

    TField = class(TWindow);

    TFind = class(TWindow)
    type
      TOption = (foMatchCase, foWholeValue, foRegExpr);
      TOptions = set of TOption;
    protected
      procedure LoadFromXML(const XML: IXMLNode); override;
      procedure SaveToXML(const XML: IXMLNode); override;
    public
      FindTextMRU: TMRUList;
      Left: Integer;
      Options: TOptions;
      Top: Integer;
      constructor Create(); override;
      destructor Destroy(); override;
    end;

    THost = class(TWindow);

    TForeignKey = class(TWindow);

    TImport = class(TWindow)
    protected
      procedure LoadFromXML(const XML: IXMLNode); override;
      procedure SaveToXML(const XML: IXMLNode); override;
    public
      CSV: record
        Headline: Boolean;
        Quote: TQuotingType;
        QuoteChar: string;
        Delimiter: string;
        DelimiterType: TDelimiterType;
      end;
      Charset: string;
      Collation: string;
      Data: Boolean;
      Engine: string;
      RowType: Integer;
      StmtType: TStmtType;
      Structure: Boolean;
      procedure Assign(const Source: TItem); override;
      constructor Create(const AAItems: TItems = nil; const AName: string = ''); reintroduce; virtual;
    end;

    TKey = class(TWindow);

    TODBC = class(TWindow)
    public
      Left: Integer;
      Top: Integer;
      constructor Create(); override;
    end;

    TPaste = class
    private
      FPreferences: TPPreferences;
    protected
      property Preferences: TPPreferences read FPreferences;
      procedure LoadFromXML(const XML: IXMLNode); virtual;
      procedure SaveToXML(const XML: IXMLNode); virtual;
    public
      Data: Boolean;
      constructor Create(); virtual;
    end;

    TReplace = class(TWindow)
    type
      TOption = (roMatchCase, roWholeValue, roRegExpr);
      TOptions = set of TOption;
    protected
      procedure LoadFromXML(const XML: IXMLNode); override;
      procedure SaveToXML(const XML: IXMLNode); override;
    public
      FindTextMRU: TMRUList;
      ReplaceTextMRU: TMRUList;
      Left: Integer;
      Options: TOptions;
      Top: Integer;
      constructor Create(); override;
      destructor Destroy(); override;
    end;

    TRoutine = class(TWindow);

    TServer = class(TWindow);

    TSQLHelp = class(TWindow)
    protected
      procedure LoadFromXML(const XML: IXMLNode); override;
      procedure SaveToXML(const XML: IXMLNode); override;
    public
      Left: Integer;
      Top: Integer;
      constructor Create(); override;
    end;

    TAccount = class(TWindow);

    TAccounts = class(TWindow)
    protected
      procedure LoadFromXML(const XML: IXMLNode); override;
      procedure SaveToXML(const XML: IXMLNode); override;
    public
      Sort: record
        Column: TAccountColumn;
        Ascending: Boolean;
      end;
      Widths: array[TAccountColumn] of Integer;
      constructor Create(); override;
    end;

    TStatement = class(TWindow);

    TTable = class(TWindow);

    TTableService = class(TWindow)
    protected
      procedure LoadFromXML(const XML: IXMLNode); override;
      procedure SaveToXML(const XML: IXMLNode); override;
    public
      Analyze: Boolean;
      Check: Boolean;
      Flush: Boolean;
      Optimize: Boolean;
      Repair: Boolean;
      constructor Create(); override;
    end;

    TTransfer = class(TWindow)
    protected
      procedure LoadFromXML(const XML: IXMLNode); override;
      procedure SaveToXML(const XML: IXMLNode); override;
    public
      Data: Boolean;
      Structure: Boolean;
      constructor Create(); override;
    end;

    TTrigger = class(TWindow);

    TUser = class(TWindow);

    TPView = class(TWindow);

    TLanguage = class(TMemIniFile)
    private
      FActiveQueryBuilderLanguageName: string;
      FLanguageId: Integer;
      FStrs: array of string;
      function GetStr(Index: Integer): string;
    protected
      property Strs[Index: Integer]: string read GetStr;
    public
      property ActiveQueryBuilderLanguageName: string read FActiveQueryBuilderLanguageName;
      property LanguageId: Integer read FLanguageId;
      constructor Create(const FileName: string); reintroduce;
      destructor Destroy(); override;
    end;

    TToolbarTab = (ttObjects, ttBrowser, ttIDE, ttBuilder, ttDiagram, ttEditor, ttEditor2, ttEditor3, ttObjectSearch);
    TToolbarTabs = set of TToolbarTab;
  private
    FDowndateFilename: TFileName;
    FImages: TImageList;
    FInternetAgent: string;
    FLanguage: TLanguage;
    FOnlineVersion: Integer;
    FUserPath: TFileName;
    FXMLDocument: IXMLDocument;
    OldAssociateSQL: Boolean;
    procedure LoadFromRegistry();
    procedure LoadFromXML(const XML: IXMLNode);
    function GetDowndateVersionStr(): string;
    function GetFilename(): TFileName;
    function GetLanguage(): TLanguage;
    function GetLanguagePath(): TFileName;
    function GetXMLDocument(): IXMLDocument;
    procedure HandleSetupProgram(const Filename: TFileName);
    procedure SaveToRegistry();
    procedure SaveToXML(const XML: IXMLNode);
  protected
    property XMLDocument: IXMLDocument read GetXMLDocument;
  public
    Account: TAccount;
    Accounts: TAccounts;
    AssociateSQL: Boolean;
    Database: TDatabase;
    Databases: TDatabases;
    Editor: TEditor;
    Event: TEvent;
    Export: TExport;
    Field: TField;
    Find: TFind;
    ForeignKey: TForeignKey;
    GridCurrRowBGColor: TColor;
    GridCurrRowBGColorEnabled: Boolean;
    GridDefaultSorting: Boolean;
    GridFontColor: TColor;
    GridFontName: TFontName;
    GridFontSize, GridFontCharset: Integer;
    GridFontStyle: TFontStyles;
    GridMaxColumnWidth: Integer;
    GridMemoContent: Boolean;
    GridNullBGColor: TColor;
    GridNullBGColorEnabled: Boolean;
    GridNullText: Boolean;
    Height: Integer;
    Host: THost;
    Import: TImport;
    Key: TKey;
    LanguageFilename: TFileName;
    Left: Integer;
    LogFontColor: TColor;
    LogFontName: TFontName;
    LogFontSize, LogFontCharset: Integer;
    LogFontStyle: TFontStyles;
    LogResult: Boolean;
    LogSize: Integer;
    LogTime: Boolean;
    ODBC: TODBC;
    Paste: TPaste;
    Path: TFileName;
    QuickAccessVisible: Boolean;
    Replace: TReplace;
    Routine: TRoutine;
    Server: TServer;
    SetupProgram: TFileName;
    SetupProgramExecute: Boolean;
    SetupProgramInstalled: Boolean;
    SoundFileNavigating: string;
    SQLFontCharset: Integer;
    SQLFontColor: TColor;
    SQLFontName: TFontName;
    SQLFontSize: Integer;
    SQLHelp: TSQLHelp;
    Statement: TStatement;
    Table: TTable;
    TableService: TTableService;
    TabsVisible: Boolean;
    ToolbarTabs: TToolbarTabs;
    Top: Integer;
    Transfer: TTransfer;
    Trigger: TTrigger;
    UpdateRemoved: string;
    User: TUser;
    View: TPView;
    Width: Integer;
    WindowState: TWindowState;
    procedure ApplyToBCEditor(const BCEditor: TBCEditor);
    constructor Create();
    destructor Destroy(); override;
    function LoadStr(const Index: Integer; const Param1: string = ''; const Param2: string = ''; const Param3: string = ''): string; overload;
    procedure Open();
    procedure Save();
    property DowndateFilename: TFileName read FDowndateFilename;
    property DowndateVersionStr: string read GetDowndateVersionStr;
    property Filename: TFileName read GetFilename;
    property Images: TImageList read FImages;
    property InternetAgent: string read FInternetAgent;
    property Language: TLanguage read GetLanguage;
    property LanguagePath: TFileName read GetLanguagePath;
    property UserPath: TFileName read FUserPath;
  end;

  TPAccount = class
  type
    TFavorites = class;
    TFiles = class;
    TDesktop = class;

    TAddresses = class(TPPreferences.TMRUList)
    private
      procedure Put(Index: Integer; Address: string); inline;
    public
      property Addresses[Index: Integer]: string read Get write Put; default;
    end;

    TFavorite = class
    private
      FAddress: string;
      FFavorites: TFavorites;
      procedure SetAddress(AAddress: string);
    public
      constructor Create(const AFavorites: TFavorites; const AAddress: string);
      property Address: string read FAddress write SetAddress;
      property Favorites: TFavorites read FFavorites;
    end;

    TFavorites = class(TList)
    type
      TEventProc = procedure(const Favorites: TFavorites) of object;
    private
      EventProcs: array of TEventProc;
      FAccount: TPAccount;
      function GetFavorite(Index: Integer): TFavorite; inline;
    protected
      procedure Changed();
      procedure LoadFromXML(const XML: IXMLNode);
      procedure SaveToXML(const XML: IXMLNode);
    public
      procedure Add(const Address: string); overload;
      procedure Clear(); override;
      constructor Create(const AAccount: TPAccount); reintroduce;
      procedure Delete(Index: Integer);
      function IndexOf(const Address: string): Integer; overload;
      procedure Insert(Index: Integer; const Address: string); overload;
      procedure Move(CurIndex, NewIndex: Integer);
      procedure RegisterEventProc(const AEventProc: TEventProc);
      procedure UnRegisterEventProc(const AEventProc: TEventProc);
      property Account: TPAccount read FAccount;
      property Favorite[Index: Integer]: TFavorite read GetFavorite; default;
    end;

    TFile = class
    private
      FFiles: TFiles;
    protected
      FCodePage: Cardinal;
      FFilename: TFileName;
      procedure LoadFromXML(const XML: IXMLNode); virtual;
      procedure SaveToXML(const XML: IXMLNode); virtual;
      property Files: TFiles read FFiles;
    public
      constructor Create(const AFiles: TFiles);
      property CodePage: Cardinal read FCodePage write FCodePage;
      property Filename: TFileName read FFilename write FFilename;
    end;

    TFiles = class(TList)
    private
      FDesktop: TDesktop;
      FMaxCount: Integer;
      function GetFile(Index: Integer): TFile; inline;
    protected
      procedure LoadFromXML(const XML: IXMLNode); virtual;
      procedure SaveToXML(const XML: IXMLNode); virtual;
      property Desktop: TDesktop read FDesktop;
      property MaxCount: Integer read FMaxCount;
    public
      procedure Add(const AFilename: TFileName; const ACodePage: Cardinal); reintroduce; virtual;
      procedure Clear(); override;
      constructor Create(const ADesktop: TDesktop; const AMaxCount: Integer);
      property Files[Index: Integer]: TFile read GetFile; default;
    end;

    TDesktop = class
    type
      TListViewKind = (lkServer, lkDatabase, lkTable, lkProcesses, lkUsers, lkVariables, lkObjectSearch, lkQuickAccess);
    private
      FAccount: TPAccount;
      FAddresses: TAddresses;
      FFiles: TFiles;
      FPath: string;
      function GetAddress(): string;
      procedure SetAddress(AAddress: string); inline;
    protected
      procedure Assign(const Source: TDesktop); virtual;
      procedure LoadFromXML(const XML: IXMLNode); virtual;
      procedure SaveToXML(const XML: IXMLNode); virtual;
      property Account: TPAccount read FAccount;
    public
      BlobHeight: Integer;
      ColumnWidths: array [lkServer .. lkQuickAccess] of array [0..7] of Integer;
      DataHeight: Integer;
      EditorContent: array [ttEditor .. ttEditor3] of string;
      ExplorerVisible: Boolean;
      FilesFilter: string;
      FoldersHeight: Integer;
      LogHeight: Integer;
      LogVisible: Boolean;
      NavigatorVisible: Boolean;
      QuickAccessMFUVisible: Boolean;
      QuickAccessMRUVisible: Boolean;
      SidebarWitdth: Integer;
      SQLHistoryVisible: Boolean;
      constructor Create(const AAccount: TPAccount); overload; virtual;
      destructor Destroy(); override;
      property Address: string read GetAddress write SetAddress;
      property Addresses: TAddresses read FAddresses;
      property Files: TFiles read FFiles;
    end;

    TConnection = class
    private
      function GetCaption(): string;
    protected
      Section: string;
      procedure LoadFromXML(const XML: IXMLNode); virtual;
      procedure SaveToXML(const XML: IXMLNode); virtual;
    public
      Database: string;
      Host: string;
      HTTPTunnelURI: string;
      LibraryFilename: TFileName;
      LibraryType: (ltBuiltIn, ltDLL, ltHTTP);
      Password: string;
      Port: Integer;
      Username: string;
      procedure Assign(const Source: TConnection); virtual;
      constructor Create(); virtual;
      property Caption: string read GetCaption;
    end;

  private
    DesktopXMLDocument: IXMLDocument;
    FAccounts: TPAccounts;
    FConnection: TConnection;
    FDesktop: TDesktop;
    FFavorites: TFavorites;
    FHistoryXMLDocument: IXMLDocument;
    FLastLogin: TDateTime;
    FName: string;
    FSessions: TList;
    FTabs: TList;
    FXML: IXMLNode;
    Modified: Boolean;
    function GetDataPath(): TFileName;
    function GetDesktopFilename(): TFileName;
    function GetDesktopXML(): IXMLNode;
    function GetHistoryFilename(): TFileName;
    function GetHistoryXML(): IXMLNode;
    function GetName(): string;
    function GetSessionCount(): Integer;
    function GetTabCount(): Integer;
    procedure SetLastLogin(const ALastLogin: TDateTime);
  protected
    Section: string;
    function GetIndex(): Integer;
    procedure Load(); virtual;
    procedure Save(); virtual;
    function ValidDatabaseName(const ADatabaseName: string): Boolean;
    property DesktopFilename: TFileName read GetDesktopFilename;
    property HistoryFilename: TFileName read GetHistoryFilename;
    property HistoryXMLDocument: IXMLDocument read FHistoryXMLDocument;
    property XML: IXMLNode read FXML;
  public
    ManualURL: string;
    ManualURLVersion: string;
    procedure Assign(const Source: TPAccount); virtual;
    constructor Create(const AAccounts: TPAccounts; const AXML: IXMLNode = nil); virtual;
    destructor Destroy(); override;
    function ExtractPath(const AAddress: string): string; virtual;
    function ExpandAddress(const APath: string): string; virtual;
    function FirstTab(): Pointer; virtual;
    function GetDefaultDatabase(): string; virtual;
    procedure RegisterSession(const ASession: Pointer);
    procedure RegisterTab(const ATab: Pointer);
    procedure UnRegisterSession(const ASession: Pointer);
    procedure UnRegisterTab(const ATab: Pointer);
    property Accounts: TPAccounts read FAccounts;
    property Connection: TConnection read FConnection;
    property DataPath: TFileName read GetDataPath;
    property Desktop: TDesktop read FDesktop;
    property DesktopXML: IXMLNode read GetDesktopXML;
    property Favorites: TFavorites read FFavorites;
    property HistoryXML: IXMLNode read GetHistoryXML;
    property Index: Integer read GetIndex;
    property LastLogin: TDateTime read FLastLogin write SetLastLogin;
    property Name: string read GetName write FName;
    property SessionCount: Integer read GetSessionCount;
    property TabCount: Integer read GetTabCount;
  end;

  TPAccounts = class(TList)
  type
    TDBLogin = function(const Account: Pointer): Boolean of object;
  private
    DefaultAccountName: string;
    FDBLogin: TDBLogin;
    FXMLDocument: IXMLDocument;
    function GetDataPath(): TFileName;
    function GetDefault(): TPAccount; inline;
    function GetFilename(): TFileName;
    function GetXMLDocument(): IXMLDocument;
    function GetFAccounts(Index: Integer): TPAccount; inline;
    procedure SetDefault(const AAccount: TPAccount);
  protected
    Section: string;
    property DataPath: TFileName read GetDataPath;
    property XMLDocument: IXMLDocument read GetXMLDocument;
  public
    function AccountByName(const AccountName: string): TPAccount;
    function AccountByURI(const AURI: string; const DefaultAccount: TPAccount = nil): TPAccount;
    procedure AddAccount(const NewAccount: TPAccount);
    procedure Clear(); override;
    constructor Create(const ADBLogin: TDBLogin);
    function DeleteAccount(const AAccount: TPAccount): Boolean;
    destructor Destroy(); override;
    procedure Open();
    procedure Save();
    procedure UpdateAccount(const Account, NewAccount: TPAccount);
    property Account[Index: Integer]: TPAccount read GetFAccounts; default;
    property Default: TPAccount read GetDefault write SetDefault;
    property DBLogin: TDBLogin read FDBLogin;
    property Filename: TFileName read GetFilename;
  end;

function XMLNode(const XML: IXMLNode; const Path: string; const NodeAutoCreate: Boolean = False): IXMLNode; overload;

function VersionStrToVersion(VersionStr: string): Integer;
function CopyDir(const fromDir, toDir: string): Boolean;
function TrySplitParam(const Param: string; out Name, Value: string): Boolean;
function ValidXMLText(const Text: string): Boolean;

var
  Accounts: TPAccounts;
  FileFormatSettings: TFormatSettings;
  Preferences: TPPreferences;

implementation {***************************************************************}

uses
  CommCtrl, SHFolder, WinInet, ShellAPI, ShlObj, ActiveX, GDIPAPI, GDIPObj,
  Math, SysConst, Variants, RTLConsts, StrUtils,
  Consts, ImgList,
  MySQLConsts,
  CSVUtils,
  uURI;

function VersionStrToVersion(VersionStr: string): Integer;
begin
  if (Pos('.', VersionStr) = 0) then
    Result := StrToInt(VersionStr) * 10000
  else
    Result := StrToInt(Copy(VersionStr, 1, Pos('.', VersionStr) - 1)) * 10000
      + VersionStrToVersion(Copy(VersionStr, Pos('.', VersionStr) + 1, Length(VersionStr) - Pos('.', VersionStr))) div 100;
end;

function CopyDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_COPY;
    fFlags := FOF_FILESONLY;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

function TryStrToWindowState(const Str: string; var WindowState: TWindowState): Boolean;
begin
  Result := True;
  if (StrIComp(PChar(Str), 'Normal') = 0) then WindowState := wsNormal
  else if (StrIComp(PChar(Str), 'Minimized') = 0) then WindowState := wsMinimized
  else if (StrIComp(PChar(Str), 'Maximized') = 0) then WindowState := wsMaximized
  else Result := False;
end;

function WindowStateToStr(const WindowState: TWindowState): string;
begin
  case (WindowState) of
    wsMaximized: Result := 'Maximized';
    else Result := 'Normal';
  end;
end;

function TryStrToQuote(const Str: string; var Quote: TPPreferences.TQuotingType): Boolean;
begin
  Result := True;
  if (StrIComp(PChar(Str), 'Nothing') = 0) then Quote := qtNone
  else if (StrIComp(PChar(Str), 'Stings') = 0) then Quote := qtStrings
  else if (StrIComp(PChar(Str), 'All') = 0) then Quote := qtAll
  else Result := False;
end;

function QuoteToStr(const Quote: TPPreferences.TQuotingType): string;
begin
  case Quote of
    qtStrings: Result := 'Stings';
    qtAll: Result := 'All';
    else Result := 'Nothing';
  end;
end;

function TryStrToSeparatorType(const Str: string; var SeparatorType: TPPreferences.TDelimiterType): Boolean;
begin
  Result := True;
  if (StrIComp(PChar(Str), 'Standard') = 0) then SeparatorType := dtChar
  else if (StrIComp(PChar(Str), 'Tab') = 0) then SeparatorType := dtTab
  else Result := False;
end;

function SeparatorTypeToStr(const SeparatorType: TPPreferences.TDelimiterType): string;
begin
  case (SeparatorType) of
    dtTab: Result := 'Tab';
    else Result := 'Standard';
  end;
end;

function TryStrToNodeType(const Str: string; var NodeType: TPPreferences.TNodeType): Boolean;
begin
  Result := True;
  if (StrIComp(PChar(Str), 'Disabled') = 0) then NodeType := ntDisabled
  else if (StrIComp(PChar(Str), 'Name') = 0) then NodeType := ntName
  else if (StrIComp(PChar(Str), 'Custom') = 0) then NodeType := ntCustom
  else Result := False;
end;

function NodeTypeToStr(const NodeType: TPPreferences.TNodeType): string;
begin
  case (NodeType) of
    ntDisabled: Result := 'Disabled';
    ntCustom: Result := 'Custom';
    else Result := 'Name';
  end;
end;

function TryStrToStmtType(const Str: string; var StmtType: TPPreferences.TStmtType): Boolean;
begin
  Result := True;
  if (StrIComp(PChar(Str), 'Insert') = 0) then StmtType := stInsert
  else if (StrIComp(PChar(Str), 'Result') = 0) then StmtType := stReplace
  else if (StrIComp(PChar(Str), 'Update') = 0) then StmtType := stUpdate
  else if (StrIComp(PChar(Str), 'InsertUpdate') = 0) then StmtType := stInsertOrUpdate
  else Result := False;
end;

function StmtTypeToStr(const StmtType: TPPreferences.TStmtType): string;
begin
  case (StmtType) of
    stReplace: Result := 'Replace';
    stUpdate: Result := 'Update';
    stInsertOrUpdate: Result := 'InsertUpdate';
    else Result := 'Insert';
  end;
end;

function StrToStyle(const Str: string): TFontStyles;
begin
  Result := [];
  if (Pos('BOLD', UpperCase(Str)) > 0) then Result := Result + [fsBold];
  if (Pos('ITALIC', UpperCase(Str)) > 0) then Result := Result + [fsItalic];
  if (Pos('UNDERLINE', UpperCase(Str)) > 0) then Result := Result + [fsUnderline];
  if (Pos('STRIKEOUT', UpperCase(Str)) > 0) then Result := Result + [fsStrikeOut];
end;

function StyleToStr(const Style: TFontStyles): string;
begin
  Result := '';

  if (fsBold in Style) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'Bold'; end;
  if (fsItalic in Style) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'Italic'; end;
  if (fsUnderline in Style) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'Underline'; end;
  if (fsStrikeOut in Style) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'StrikeOut'; end;
end;

function StrToFindOptions(const Str: string): TPPreferences.TFind.TOptions;
begin
  Result := [];
  if (Pos('MATCHCASE', UpperCase(Str)) > 0) then Result := Result + [foMatchCase];
  if (Pos('WHOLEWORD', UpperCase(Str)) > 0) then Result := Result + [foWholeValue];
  if (Pos('REGEXPR', UpperCase(Str)) > 0) then Result := Result + [foRegExpr];
end;

function FindOptionsToStr(const FindOptions: TPPreferences.TFind.TOptions): string;
begin
  Result := '';

  if (foMatchCase in FindOptions) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'MatchCase'; end;
  if (foWholeValue in FindOptions) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'WholeValue'; end;
  if (foRegExpr in FindOptions) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'RegExpr'; end;
end;

function TryStrToRowType(const Str: string; var RowType: Integer): Boolean;
begin
  Result := True;
  if (Str = '') then RowType := 0
  else if (StrIComp(PChar(Str), 'Fixed') = 0) then RowType := 1
  else if (StrIComp(PChar(Str), 'Dynamic') = 0) then RowType := 2
  else if (StrIComp(PChar(Str), 'Compressed') = 0) then RowType := 3
  else if (StrIComp(PChar(Str), 'Redundant') = 0) then RowType := 4
  else if (StrIComp(PChar(Str), 'Compact') = 0) then RowType := 5
  else Result := False;
end;

function RowTypeToStr(const RowType: Integer): string;
begin
  case RowType of
    1: Result := 'Fixed';
    2: Result := 'Dynamic';
    3: Result := 'Compressed';
    4: Result := 'Redundant';
    5: Result := 'Compact';
    else Result := '';
  end;
end;

function StrToReplaceOptions(const Str: string): TPPreferences.TReplace.TOptions;
begin
  Result := [];
  if (Pos('MATCHCASE', UpperCase(Str)) > 0) then Result := Result + [roMatchCase];
  if (Pos('WHOLEWORD', UpperCase(Str)) > 0) then Result := Result + [roWholeValue];
  if (Pos('REGEXPR', UpperCase(Str)) > 0) then Result := Result + [roRegExpr];
end;

function ReplaceOptionsToStr(const Options: TPPreferences.TReplace.TOptions): string;
begin
  Result := '';

  if (roMatchCase in Options) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'MatchCase'; end;
  if (roWholeValue in Options) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'WholeValue'; end;
  if (roRegExpr in Options) then begin if (Result <> '') then Result := Result + ','; Result := Result + 'RegExpr'; end;
end;

function TryStrToImportType(const Str: string; var ImportType: TImportType): Boolean;
begin
  Result := True;
  if (StrIComp(PChar(Str), 'SQLFile') = 0) then ImportType := itSQLFile
  else if (StrIComp(PChar(Str), 'TextFile') = 0) then ImportType := itTextFile
  else if (StrIComp(PChar(Str), 'ExcelFile') = 0) then ImportType := itExcelFile
  else if (StrIComp(PChar(Str), 'AccessFile') = 0) then ImportType := itAccessFile
  else if (StrIComp(PChar(Str), 'ODBC') = 0) then ImportType := itODBC
  else Result := False;
end;

function ImportTypeToStr(const ImportType: TImportType): string;
begin
  case (ImportType) of
    itSQLFile: Result := 'SQLFile';
    itTextFile: Result := 'TextFile';
    itExcelFile: Result := 'ExcelFile';
    itAccessFile: Result := 'AccessFile';
    itODBC: Result := 'ODBC';
    else raise ERangeError.CreateFmt(SPropertyOutOfRange, ['ImportType']);
  end;
end;

function TryStrToExportType(const Str: string; var ExportType: TExportType): Boolean;
begin
  Result := True;
  if (StrIComp(PChar(Str), 'SQLFile') = 0) then ExportType := etSQLFile
  else if (StrIComp(PChar(Str), 'TextFile') = 0) then ExportType := etTextFile
  else if (StrIComp(PChar(Str), 'ExcelFile') = 0) then ExportType := etExcelFile
  else if (StrIComp(PChar(Str), 'AccessFile') = 0) then ExportType := etAccessFile
  else if (StrIComp(PChar(Str), 'ODBC') = 0) then ExportType := etODBC
  else if (StrIComp(PChar(Str), 'HTMLFile') = 0) then ExportType := etHTMLFile
  else if (StrIComp(PChar(Str), 'XMLFile') = 0) then ExportType := etXMLFile
  else if (StrIComp(PChar(Str), 'PDFFile') = 0) then ExportType := etPDFFile
  else Result := False;
end;

function ExportTypeToStr(const ExportType: TExportType): string;
begin
  case (ExportType) of
    etSQLFile: Result := 'SQLFile';
    etTextFile: Result := 'TextFile';
    etExcelFile: Result := 'ExcelFile';
    etAccessFile: Result := 'AccessFile';
    etODBC: Result := 'ODBC';
    etHTMLFile: Result := 'HTMLFile';
    etXMLFile: Result := 'XMLFile';
    etPDFFile: Result := 'PDFFile';
    else raise ERangeError.CreateFmt(SPropertyOutOfRange, ['ExportType']);
  end;
end;

function TryStrToColumn(const Str: string; var Column: TAccountColumn): Boolean;
begin
  Result := True;
  if (StrIComp(PChar(Str), 'Name') = 0) then Column := acName
  else if (StrIComp(PChar(Str), 'Host') = 0) then Column := acHost
  else if (StrIComp(PChar(Str), 'User') = 0) then Column := acUser
  else if (StrIComp(PChar(Str), 'Database') = 0) then Column := acDatabase
  else if (StrIComp(PChar(Str), 'LastLogin') = 0) then Column := acLastLogin
  else Result := False;
end;

function ColumnToStr(const Column: TAccountColumn): string;
begin
  case (Column) of
    acName: Result := 'Name';
    acHost: Result := 'Host';
    acUser: Result := 'User';
    acDatabase: Result := 'Database';
    acLastLogin: Result := 'LastLogin';
    else raise ERangeError.CreateFmt(SPropertyOutOfRange, ['Column']);
  end;
end;

function ReplaceEnviromentVariables(const AStr: string): string;
var
  Len: Integer;
begin
  Len := ExpandEnvironmentStrings(PChar(AStr), nil, 0);
  SetLength(Result, Len);
  ExpandEnvironmentStrings(PChar(AStr), PChar(Result), Len);
  if (RightStr(Result, 1) = #0) then
    Delete(Result, Length(Result), 1);
end;

function XMLNode(const XML: IXMLNode; const Path: string; const NodeAutoCreate: Boolean = False): IXMLNode;
var
  ChildKey: string;
  CurrentKey: string;
begin
  if (not Assigned(XML)) then
    Result := nil
  else if (Path = '') then
    Result := XML
  else
  begin
    if (Pos('/', Path) = 0) then
    begin
      CurrentKey := Path;
      ChildKey := '';
    end
    else
    begin
      CurrentKey := Copy(Path, 1, Pos('/', Path) - 1);
      ChildKey := Path; Delete(ChildKey, 1, Length(CurrentKey) + 1);
    end;

    if (Assigned(XML.ChildNodes.FindNode(CurrentKey))) then
      Result := XMLNode(XML.ChildNodes.FindNode(CurrentKey), ChildKey, NodeAutoCreate)
    else if (NodeAutoCreate or (doNodeAutoCreate in XML.OwnerDocument.Options)) then
      Result := XMLNode(XML.AddChild(CurrentKey), ChildKey, NodeAutoCreate)
    else
      Result := nil;
  end;
end;

function GetFileIcon(const CSIDL: Integer): HIcon; overload;
var
  FileInfo: TSHFileInfo;
  PIDL: PItemIDList;
begin
  PIDL := nil;
  SHGetFolderLocation(0, CSIDL, 0, 0, PIDL);
  ZeroMemory(@FileInfo, SizeOf(FileInfo));
  SHGetFileInfo(PChar(PIDL), 0, FileInfo, SizeOf(FileInfo), SHGFI_PIDL or SHGFI_ICON or SHGFI_SMALLICON);
  Result := FileInfo.hIcon;
end;

function GetFileIcon(const Path: TFileName): HIcon; overload;
var
  FileInfo: TSHFileInfo;
begin
  ZeroMemory(@FileInfo, SizeOf(FileInfo));
  SHGetFileInfo(PChar(Path), 0, FileInfo, SizeOf(FileInfo), SHGFI_ICON or SHGFI_SMALLICON);
  Result := FileInfo.hIcon;
end;

function ViewStyleToInteger(const ViewStyle: TViewStyle): Integer;
begin
  Result := 2;
  case (ViewStyle) of
    vsIcon: Result := 0;
    vsSmallIcon: Result := 1;
    vsList: Result := 2;
    vsReport: Result := 3;
  end;
end;

function TryStrToViewStyle(const Str: string; var ViewStyle: TViewStyle): Boolean;
begin
  Result := True;
  if (UpperCase(Str) = 'ICON') then ViewStyle := vsIcon
  else if (UpperCase(Str) = 'SMALLICON') then ViewStyle := vsSmallIcon
  else if (UpperCase(Str) = 'LIST') then ViewStyle := vsList
  else if (UpperCase(Str) = 'REPORT') then ViewStyle := vsReport
  else Result := False;
end;

function ViewStyleToStr(const ViewStyle: TViewStyle): string;
begin
  case (ViewStyle) of
    vsIcon: Result := 'Icon';
    vsList: Result := 'List';
    vsReport: Result := 'Report';
    else Result := 'SmallIcon';
  end;
end;

function IntegerToViewStyle(const Int: Integer): TViewStyle;
begin
  Result := vsList;
  case (Int) of
    0: Result := vsIcon;
    1: Result := vsSmallIcon;
    2: Result := vsList;
    3: Result := vsReport;
  end;
end;

function TrySplitParam(const Param: string; out Name, Value: string): Boolean;
begin
  Result := (Copy(Param, 1, 1) = '/') and (Pos('=', Param) > 2);
  if (True) then
  begin
    Name := Trim(Copy(Param, 2, Pos('=', Param) - 2));
    Value := Trim(Copy(Param, Pos('=', Param) + 1, Length(Param) - Pos('=', Param)));
  end;
end;

function ValidXMLText(const Text: string): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 1 to Length(Text) do
    if (CharInSet(Text[I], [#0 .. #8, #11 .. #12, #14 .. #31])) then
      Exit(False);
end;

function GetFileInfo(const Filename: TFileName; var FileInfo: VS_FIXEDFILEINFO): Boolean;
var
  Buffer: PChar;
  BufferSize: Cardinal;
  FileInfoSize: UINT;
  Handle: Cardinal;
  PFileInfo: Pointer;
begin
  BufferSize := GetFileVersionInfoSize(PChar(Filename), Handle);
  Result := BufferSize > 0;
  if (Result) then
  begin
    GetMem(Buffer, BufferSize);
    PFileInfo := nil;
    Result := GetFileVersionInfo(PChar(Filename), 0, BufferSize, Buffer)
      and (VerQueryValue(Buffer, '\', PFileInfo, FileInfoSize))
      and (FileInfoSize >= SizeOf(FileInfo));
    if (Result) then
      MoveMemory(@FileInfo, PFileInfo, SizeOf(FileInfo));
    FreeMem(Buffer);
  end;
end;

{ TPPreferences.TItem *********************************************************}

procedure TPPreferences.TItem.Assign(const Source: TItem);
begin
  Assert(Assigned(Source) and (Source.ClassType = ClassType));


  FName := Source.Name;
end;

constructor TPPreferences.TItem.Create(const AAItems: TItems; const AName: string = '');
begin
  inherited Create();

  FAItems := AAItems;
  FName := AName;
end;

function TPPreferences.TItem.GetIndex(): Integer;
begin
  Result := AItems.IndexOf(Self);
end;

{ TPPreferences.TItems ********************************************************}

function TPPreferences.TItems.Add(const AItem: TItem): Integer;
begin
  if (InsertIndex(AItem.Name, Result)) then
    if (Result < TList(Self).Count) then
      TList(Self).Insert(Result, AItem)
    else
      TList(Self).Add(AItem);
end;

procedure TPPreferences.TItems.Clear();
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Item[I].Free();

  inherited;
end;

function TPPreferences.TItems.GetItem(Index: Integer): TItem;
begin
  Result := TItem(Items[Index]);
end;

function TPPreferences.TItems.IndexByName(const Name: string): Integer;
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
    case (lstrcmpi(PChar(Item[Mid].Name), PChar(Name))) of
      -1: Left := Mid + 1;
      0: begin Result := Mid; break; end;
      1: Right := Mid - 1;
    end;
  end;
end;

function TPPreferences.TItems.InsertIndex(const Name: string; out Index: Integer): Boolean;
var
  Left: Integer;
  Mid: Integer;
  Right: Integer;
begin
  Result := True;

  if ((Count = 0) or (lstrcmpi(PChar(Item[Count - 1].Name), PChar(Name)) < 0)) then
    Index := Count
  else
  begin
    Left := 0;
    Right := Count - 1;
    while (Left <= Right) do
    begin
      Mid := (Right - Left) div 2 + Left;
      case (lstrcmpi(PChar(Item[Mid].Name), PChar(Name))) of
        -1: begin Left := Mid + 1;  Index := Mid + 1; end;
        0: begin Result := False; Index := Mid; break; end;
        1: begin Right := Mid - 1; Index := Mid; end;
      end;
    end;

    if (Index < 0) then
      raise ERangeError.CreateFmt(SPropertyOutOfRange, ['Index']);
  end;
end;

{ TPPreferences.TMRUList ******************************************************}

procedure TPPreferences.TMRUList.Add(const Value: string);
var
  I: Integer;
  Index: Integer;
begin
  if (Value <> '') then
  begin
    Index := IndexOf(Value);

    if (Index >= 0) then
      Delete(Index);

    while (Length(FValues) >= FMaxCount) do
      Delete(FMaxCount - 1);

    SetLength(FValues, Length(FValues) + 1);
    for I := Length(FValues) - 2 downto 0 do
      FValues[I + 1] := FValues[I];
    FValues[0] := Value;
  end;
end;

procedure TPPreferences.TMRUList.Assign(const Source: TMRUList);
var
  I: Integer;
begin
  Clear();

  if (Assigned(Source)) then
  begin
    FMaxCount := Source.MaxCount;
    for I := Source.Count - 1 downto 0 do
      Add(Source[I]);
  end;
end;

procedure TPPreferences.TMRUList.Clear();
begin
  SetLength(FValues, 0);
end;

constructor TPPreferences.TMRUList.Create(const AMaxCount: Integer);
begin
  FMaxCount := AMaxCount;

  Clear();
end;

procedure TPPreferences.TMRUList.Delete(const Index: Integer);
var
  I: Integer;
begin
  if ((Index < 0) or (Length(FValues) <= Index)) then
    raise ERangeError.CreateRes(@SInvalidCurrentItem);

  for I := Index to Length(FValues) - 2 do
    FValues[I] := FValues[I + 1];
  SetLength(FValues, Length(FValues) - 1);
end;

destructor TPPreferences.TMRUList.Destroy();
begin
  Clear();

  inherited;
end;

function TPPreferences.TMRUList.Get(Index: Integer): string;
begin
  Result := FValues[Index];
end;

function TPPreferences.TMRUList.GetCount(): Integer;
begin
  Result := Length(FValues);
end;

function TPPreferences.TMRUList.IndexOf(const Value: string): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to Length(FValues) - 1 do
    if (lstrcmpi(PChar(Value), PChar(FValues[I])) = 0) then
      Result := I;
end;

procedure TPPreferences.TMRUList.LoadFromXML(const XML: IXMLNode; const NodeName: string);
var
  I: Integer;
begin
  Clear();

  for I := 0 to XML.ChildNodes.Count - 1 do
    if ((XML.ChildNodes[I].NodeName = NodeName) and (Length(FValues) < MaxCount)) then
    begin
      SetLength(FValues, Length(FValues) + 1);
      FValues[Length(FValues) - 1] := XML.ChildNodes[I].Text;
    end;
end;

procedure TPPreferences.TMRUList.SaveToXML(const XML: IXMLNode; const NodeName: string);
var
  I: Integer;
begin
  for I := XML.ChildNodes.Count - 1 downto 0 do
    if (XML.ChildNodes[I].NodeName = NodeName) then
      XML.ChildNodes.Delete(I);
  for I := 0 to Count - 1 do
    XML.AddChild(NodeName).Text := Items[I];
end;

{ TPPreferences.TWindow *******************************************************}

constructor TPPreferences.TWindow.Create();
begin
  inherited Create(nil);

  Height := -1;
  Width := -1;
end;

procedure TPPreferences.TWindow.LoadFromXML(const XML: IXMLNode);
var
  PixelsPerInch: Integer;
begin
  inherited;

  if (not TryStrToInt(XML.OwnerDocument.DocumentElement.Attributes['pixelsperinch'], PixelsPerInch)) then PixelsPerInch := Screen.PixelsPerInch;

  if (Assigned(XMLNode(XML, 'height')) and TryStrToInt(XMLNode(XML, 'height').Text, Height)) then Height := Round(Height * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'width')) and TryStrToInt(XMLNode(XML, 'width').Text, Width)) then Width := Round(Width * Screen.PixelsPerInch / PixelsPerInch);
end;

procedure TPPreferences.TWindow.SaveToXML(const XML: IXMLNode);
begin
  inherited;

  XMLNode(XML, 'height').Text := IntToStr(Height);
  XMLNode(XML, 'width').Text := IntToStr(Width);
end;

{ TPPreferences.TDatabases ****************************************************}

{ TPPreferences.TEditor *******************************************************}

constructor TPPreferences.TEditor.Create();
begin
  inherited;

  CodeCompletion := False;
  CodeCompletionTime := 1000;
  CurrRowBGColorEnabled := True; CurrRowBGColor := $C0FFFF;
  WordWrap := False;
end;

procedure TPPreferences.TEditor.LoadFromXML(const XML: IXMLNode);
begin
  if (Assigned(XMLNode(XML, 'autocompletion'))) then TryStrToBool(XMLNode(XML, 'autocompletion').Attributes['enabled'], CodeCompletion);
  if (Assigned(XMLNode(XML, 'autocompletion/time'))) then TryStrToInt(XMLNode(XML, 'autocompletion/time').Text, CodeCompletionTime);
  if (Assigned(XMLNode(XML, 'currentrow/background'))) then TryStrToBool(XMLNode(XML, 'currentrow/background').Attributes['visible'], CurrRowBGColorEnabled);
  if (Assigned(XMLNode(XML, 'currentrow/background/color'))) then CurrRowBGColor := StringToColor(XMLNode(XML, 'currentrow/background/color').Text);
  if (Assigned(XMLNode(XML, 'wordwrap'))) then TryStrToBool(XMLNode(XML, 'wordwrap').Text, WordWrap);
end;

procedure TPPreferences.TEditor.SaveToXML(const XML: IXMLNode);
begin
  XMLNode(XML, 'autocompletion').Attributes['enabled'] := CodeCompletion;
  XMLNode(XML, 'autocompletion/time').Text := IntToStr(CodeCompletionTime);
  XMLNode(XML, 'currentrow/background').Attributes['visible'] := CurrRowBGColorEnabled;
  XMLNode(XML, 'currentrow/background/color').Text := ColorToString(CurrRowBGColor);
  XMLNode(XML, 'wordwrap').Text := BoolToStr(WordWrap, True);
end;

{ TPPreferences.TExport *******************************************************}

procedure TPPreferences.TExport.Assign(const Source: TItem);
begin
  Assert(Source is TExport);

  inherited Assign(Source);

  CSV := TExport(Source).CSV;
  Excel := TExport(Source).Excel;
  HTML := TExport(Source).HTML;
  SQL := TExport(Source).SQL;
  XML := TExport(Source).XML;
end;

constructor TPPreferences.TExport.Create(const AAItems: TItems = nil; const AName: string = '');
begin
  inherited Create();

  CSV.Headline := True;
  CSV.QuoteValues := qtStrings;
  CSV.Quoter := '"';
  CSV.Delimiter := ',';
  CSV.DelimiterType := dtChar;
  Excel.Excel2003 := False;
  Access.Access2003 := False;
  HTML.Data := True;
  HTML.NULLText := False;
  HTML.MemoContent := False;
  HTML.Structure := False;
  SQL.Data := True;
  SQL.DropStmts := True;
  SQL.Structure := True;
  SQL.ReplaceData := False;
  XML.Database.NodeType := ntDisabled;
  XML.Database.NodeText := 'database';
  XML.Database.NodeAttribute := 'name';
  XML.Field.NodeType := ntName;
  XML.Field.NodeText := 'field';
  XML.Field.NodeAttribute := 'name';
  XML.Root.NodeText := 'mysql';
  XML.Row.NodeText := 'row';
  XML.Table.NodeType := ntDisabled;
  XML.Table.NodeText := 'table';
  XML.Table.NodeAttribute := 'name';
end;

procedure TPPreferences.TExport.LoadFromXML(const XML: IXMLNode);
begin
  inherited;

  if (Assigned(XMLNode(XML, 'csv/headline'))) then TryStrToBool(XMLNode(XML, 'csv/headline').Attributes['enabled'], CSV.Headline);
  if (Assigned(XMLNode(XML, 'csv/quote/string')) and (XMLNode(XML, 'csv/quote/string').Text <> '')) then CSV.Quoter := XMLNode(XML, 'csv/quote/string').Text[1];
  if (Assigned(XMLNode(XML, 'csv/quote/type'))) then TryStrToQuote(XMLNode(XML, 'csv/quote/type').Text, CSV.QuoteValues);
  if (Assigned(XMLNode(XML, 'csv/separator/character/string'))) then CSV.Delimiter := XMLNode(XML, 'csv/separator/character/string').Text;
  if (Assigned(XMLNode(XML, 'csv/separator/character/type'))) then TryStrToSeparatorType(XMLNode(XML, 'csv/separator/character/type').Text, CSV.DelimiterType);
  if (Assigned(XMLNode(XML, 'excel/format')) and (XMLNode(XML, 'excel/format').Text = '2007')) then Excel.Excel2003 := True else Excel.Excel2003 := False;
  if (Assigned(XMLNode(XML, 'access/format')) and (XMLNode(XML, 'access/format').Text = '2003')) then Access.Access2003 := True else Access.Access2003 := False;
  if (Assigned(XMLNode(XML, 'html/data'))) then TryStrToBool(XMLNode(XML, 'html/data').Attributes['enabled'], HTML.Data);
  if (Assigned(XMLNode(XML, 'html/memo')) and (XMLNode(XML, 'html/memo').Attributes['visible'] <> Null)) then TryStrToBool(XMLNode(XML, 'html/memo').Attributes['visible'], HTML.MemoContent);
  if (Assigned(XMLNode(XML, 'html/null')) and (XMLNode(XML, 'html/null').Attributes['visible'] <> Null)) then TryStrToBool(XMLNode(XML, 'html/null').Attributes['visible'], HTML.NULLText);
  if (Assigned(XMLNode(XML, 'html/structure'))) then TryStrToBool(XMLNode(XML, 'html/structure').Attributes['enabled'], HTML.Structure);
  if (Assigned(XMLNode(XML, 'odbc/datasource'))) then ODBC.DataSource := XMLNode(XML, 'odbc/datasource').Text;
  if (Assigned(XMLNode(XML, 'sql/data'))) then TryStrToBool(XMLNode(XML, 'sql/data').Attributes['enabled'], SQL.Data);
  if (Assigned(XMLNode(XML, 'sql/data'))) then TryStrToBool(XMLNode(XML, 'sql/data').Attributes['replace'], SQL.ReplaceData);
  if (Assigned(XMLNode(XML, 'sql/structure'))) then TryStrToBool(XMLNode(XML, 'sql/structure').Attributes['enabled'], SQL.Structure);
  if (Assigned(XMLNode(XML, 'sql/structure'))) then TryStrToBool(XMLNode(XML, 'sql/structure').Attributes['drop'], SQL.DropStmts);
  if (Assigned(XMLNode(XML, 'xml/database')) and (XMLNode(XML, 'xml/database').Attributes['type'] <> Null)) then TryStrToNodeType(XMLNode(XML, 'xml/database').Attributes['type'], Self.XML.Database.NodeType);
  if (Assigned(XMLNode(XML, 'xml/database')) and (XMLNode(XML, 'xml/database').Text <> '')) then Self.XML.Database.NodeText := XMLNode(XML, 'xml/database').Text;
  if (Assigned(XMLNode(XML, 'xml/database')) and (XMLNode(XML, 'xml/database').Attributes['attribute'] <> Null)) then Self.XML.Database.NodeAttribute := XMLNode(XML, 'xml/database').Attributes['attribute'];
  if (Assigned(XMLNode(XML, 'xml/field')) and (XMLNode(XML, 'xml/field').Attributes['type'] <> Null)) then TryStrToNodeType(XMLNode(XML, 'xml/field').Attributes['type'], Self.XML.Field.NodeType);
  if (Assigned(XMLNode(XML, 'xml/field')) and (XMLNode(XML, 'xml/field').Text <> '')) then Self.XML.Field.NodeText := XMLNode(XML, 'xml/field').Text;
  if (Assigned(XMLNode(XML, 'xml/field')) and (XMLNode(XML, 'xml/field').Attributes['attribute'] <> Null)) then Self.XML.Field.NodeAttribute := XMLNode(XML, 'xml/field').Attributes['attribute'];
  if (Assigned(XMLNode(XML, 'xml/record')) and (XMLNode(XML, 'xml/record').Text <> '')) then Self.XML.Root.NodeText := XMLNode(XML, 'xml/record').Text;
  if (Assigned(XMLNode(XML, 'xml/root')) and (XMLNode(XML, 'xml/root').Text <> '')) then Self.XML.Root.NodeText := XMLNode(XML, 'xml/root').Text;
  if (Assigned(XMLNode(XML, 'xml/table')) and (XMLNode(XML, 'xml/table').Attributes['type'] <> Null)) then TryStrToNodeType(XMLNode(XML, 'xml/table').Attributes['type'], Self.XML.Table.NodeType);
  if (Assigned(XMLNode(XML, 'xml/table')) and (XMLNode(XML, 'xml/table').Text <> '')) then Self.XML.Table.NodeText := XMLNode(XML, 'xml/table').Text;
  if (Assigned(XMLNode(XML, 'xml/table')) and (XMLNode(XML, 'xml/table').Attributes['attribute'] <> Null)) then Self.XML.Table.NodeAttribute := XMLNode(XML, 'xml/table').Attributes['attribute'];
end;

procedure TPPreferences.TExport.SaveToXML(const XML: IXMLNode);
begin
  inherited;

  XMLNode(XML, 'csv/headline').Attributes['enabled'] := CSV.Headline;
  XMLNode(XML, 'csv/quote/string').Text := CSV.Quoter;
  XMLNode(XML, 'csv/quote/type').Text := QuoteToStr(CSV.QuoteValues);
  XMLNode(XML, 'csv/separator/character/string').Text := CSV.Delimiter;
  XMLNode(XML, 'csv/separator/character/type').Text := SeparatorTypeToStr(CSV.DelimiterType);
  if (Excel.Excel2003) then XMLNode(XML, 'excel/format').Text := '2007' else XMLNode(XML, 'excel/format').Text := '';
  if (Access.Access2003) then XMLNode(XML, 'access/format').Text := '2003' else XMLNode(XML, 'access/format').Text := '';
  XMLNode(XML, 'html/data').Attributes['enabled'] := HTML.Data;
  XMLNode(XML, 'html/memo').Attributes['visible'] := HTML.MemoContent;
  XMLNode(XML, 'html/null').Attributes['visible'] := HTML.NullText;
  XMLNode(XML, 'html/structure').Attributes['enabled'] := HTML.Structure;
  XMLNode(XML, 'odbc/datasource').Text := ODBC.DataSource;
  XMLNode(XML, 'sql/data').Attributes['enabled'] := SQL.Data;
  XMLNode(XML, 'sql/data').Attributes['replace'] := SQL.ReplaceData;
  XMLNode(XML, 'sql/structure').Attributes['enabled'] := SQL.Structure;
  XMLNode(XML, 'sql/structure').Attributes['drop'] := SQL.DropStmts;
  XMLNode(XML, 'xml/database').Text := Self.XML.Database.NodeText;
  XMLNode(XML, 'xml/database').Attributes['type'] := NodeTypeToStr(Self.XML.Database.NodeType);
  XMLNode(XML, 'xml/database').Attributes['attribute'] := Self.XML.Database.NodeAttribute;
  XMLNode(XML, 'xml/field').Text := Self.XML.Field.NodeText;
  XMLNode(XML, 'xml/field').Attributes['type'] := NodeTypeToStr(Self.XML.Field.NodeType);
  XMLNode(XML, 'xml/field').Attributes['attribute'] := Self.XML.Field.NodeAttribute;
  XMLNode(XML, 'xml/record').Text := Self.XML.Row.NodeText;
  XMLNode(XML, 'xml/root').Text := Self.XML.Root.NodeText;
  XMLNode(XML, 'xml/table').Text := Self.XML.Table.NodeText;
  XMLNode(XML, 'xml/table').Attributes['type'] := NodeTypeToStr(Self.XML.Table.NodeType);
  XMLNode(XML, 'xml/table').Attributes['attribute'] := Self.XML.Table.NodeAttribute;
end;

{ TPPreferences.TFind *********************************************************}

constructor TPPreferences.TFind.Create();
begin
  inherited;

  FindTextMRU := TPPreferences.TMRUList.Create(10);
  Left := -1;
  Options := [foMatchCase];
  Top := -1;
end;

destructor TPPreferences.TFind.Destroy();
begin
  FindTextMRU.Free();

  inherited;
end;

procedure TPPreferences.TFind.LoadFromXML(const XML: IXMLNode);
var
  I: Integer;
begin
  inherited;

  FindTextMRU.Clear();
  if (Assigned(XMLNode(XML, 'findtext/mru'))) then
    for I := XMLNode(XML, 'findtext/mru').ChildNodes.Count - 1 downto 0 do
      if (XMLNode(XML, 'findtext/mru').ChildNodes[I].NodeName = 'text') then
        FindTextMRU.Add(XMLNode(XML, 'findtext/mru').ChildNodes[I].Text);
  if (Assigned(XMLNode(XML, 'options'))) then Options := StrToFindOptions(XMLNode(XML, 'options').Text);
end;

procedure TPPreferences.TFind.SaveToXML(const XML: IXMLNode);
var
  I: Integer;
begin
  inherited;

  XMLNode(XML, 'findtext/mru').ChildNodes.Clear();
  for I := 0 to FindTextMRU.Count - 1 do
    XMLNode(XML, 'findtext/mru').AddChild('text').Text := FindTextMRU[I];
  XMLNode(XML, 'options').Text := FindOptionsToStr(Options);
end;

{ TPPreferences.TImport *******************************************************}

procedure TPPreferences.TImport.Assign(const Source: TItem);
begin
  Assert(Assigned(Source) and (Source.ClassType = ClassType));


  inherited;

  Charset := TImport(Source).Charset;
  CSV.Headline := TImport(Source).CSV.Headline;
  CSV.Quote := TImport(Source).CSV.Quote;
  CSV.QuoteChar := TImport(Source).CSV.QuoteChar;
  CSV.Delimiter := TImport(Source).CSV.Delimiter;
  CSV.DelimiterType := TImport(Source).CSV.DelimiterType;
  Collation := TImport(Source).Collation;
  Data := TImport(Source).Data;
  Engine := TImport(Source).Engine;
  RowType := TImport(Source).RowType;
  StmtType := TImport(Source).StmtType;
  Structure := TImport(Source).Structure;
end;

constructor TPPreferences.TImport.Create(const AAItems: TItems = nil; const AName: string = '');
begin
  inherited Create();

  Charset := '';
  CSV.Headline := True;
  CSV.Quote := qtStrings;
  CSV.QuoteChar := '"';
  CSV.Delimiter := ',';
  CSV.DelimiterType := dtChar;
  Collation := '';
  Data := True;
  Engine := '';
  RowType := 0;
  StmtType := stInsert;
  Structure := True;
end;

procedure TPPreferences.TImport.LoadFromXML(const XML: IXMLNode);
begin
  inherited;

  if (Assigned(XMLNode(XML, 'csv/headline'))) then TryStrToBool(XMLNode(XML, 'csv/headline').Attributes['enabled'], CSV.Headline);
  if (Assigned(XMLNode(XML, 'csv/quote/string'))) then CSV.QuoteChar := XMLNode(XML, 'csv/quote/string').Text;
  if (Assigned(XMLNode(XML, 'csv/quote/type'))) then TryStrToQuote(XMLNode(XML, 'csv/quote/type').Text, CSV.Quote);
  if (Assigned(XMLNode(XML, 'csv/separator/character/string'))) then CSV.Delimiter := XMLNode(XML, 'csv/separator/character/string').Text;
  if (Assigned(XMLNode(XML, 'csv/separator/character/type'))) then TryStrToSeparatorType(XMLNode(XML, 'csv/separator/character/type').Text, CSV.DelimiterType);
  if (Assigned(XMLNode(XML, 'data')) and (XMLNode(XML, 'data').Attributes['enabled'] <> Null)) then TryStrToBool(XMLNode(XML, 'data').Attributes['enabled'], Data);
  if (Assigned(XMLNode(XML, 'data/importtype'))) then TryStrToStmtType(XMLNode(XML, 'data/importtype').Text, StmtType);
  if (Assigned(XMLNode(XML, 'rowtype'))) then TryStrToRowType(XMLNode(XML, 'rowtype').Text, RowType);
  if (Assigned(XMLNode(XML, 'structure')) and (XMLNode(XML, 'structure').Attributes['charset'] <> Null)) then Charset := XMLNode(XML, 'structure').Attributes['charset'];
  if (Assigned(XMLNode(XML, 'structure')) and (XMLNode(XML, 'structure').Attributes['collation'] <> Null)) then Collation := XMLNode(XML, 'structure').Attributes['collation'];
  if (Assigned(XMLNode(XML, 'structure')) and (XMLNode(XML, 'structure').Attributes['enabled'] <> Null)) then TryStrToBool(XMLNode(XML, 'structure').Attributes['enabled'], Structure);
  if (Assigned(XMLNode(XML, 'structure')) and (XMLNode(XML, 'structure').Attributes['engine'] <> Null)) then Engine := XMLNode(XML, 'structure').Attributes['engine'];
  if (Assigned(XMLNode(XML, 'structure')) and (XMLNode(XML, 'structure').Attributes['rowtype'] <> Null)) then TryStrToRowType(XMLNode(XML, 'structure').Attributes['rowtype'], RowType);
end;

procedure TPPreferences.TImport.SaveToXML(const XML: IXMLNode);
begin
  inherited;

  XMLNode(XML, 'csv/headline').Attributes['enabled'] := BoolToStr(CSV.Headline, True);
  XMLNode(XML, 'csv/quote/string').Text := CSV.QuoteChar;
  XMLNode(XML, 'csv/quote/type').Text := QuoteToStr(CSV.Quote);
  XMLNode(XML, 'csv/separator/character/string').Text := CSV.Delimiter;
  XMLNode(XML, 'csv/separator/character/type').Text := SeparatorTypeToStr(CSV.DelimiterType);
  XMLNode(XML, 'data').Attributes['enabled'] := BoolToStr(Data, True);
  XMLNode(XML, 'data/importtype').Text := StmtTypeToStr(StmtType);
  XMLNode(XML, 'rowtype').Text := RowTypeToStr(RowType);
  XMLNode(XML, 'structure').Attributes['charset'] := Charset;
  XMLNode(XML, 'structure').Attributes['collation'] := Collation;
  XMLNode(XML, 'structure').Attributes['enabled'] := Structure;
  XMLNode(XML, 'structure').Attributes['engine'] := Engine;
  XMLNode(XML, 'structure').Attributes['rowtype'] := RowTypeToStr(RowType);
end;

{ TPPreferences.TODBC *********************************************************}

constructor TPPreferences.TODBC.Create();
begin
  inherited;

  Left := -1;
  Top := -1;
end;

{ TPPreferences.TPaste ********************************************************}

constructor TPPreferences.TPaste.Create();
begin
  inherited;

  Data := True;
end;

procedure TPPreferences.TPaste.LoadFromXML(const XML: IXMLNode);
begin
  if (Assigned(XMLNode(XML, 'data'))) then TryStrToBool(XMLNode(XML, 'data').Text, Data);
end;

procedure TPPreferences.TPaste.SaveToXML(const XML: IXMLNode);
begin
  XMLNode(XML, 'data').Text := BoolToStr(Data, True);
end;

{ TPPreferences.TReplace ******************************************************}

constructor TPPreferences.TReplace.Create();
begin
  inherited;

  FindTextMRU := TPPreferences.TMRUList.Create(10);
  ReplaceTextMRU := TPPreferences.TMRUList.Create(10);
  Left := -1;
  Options := [roMatchCase];
  Top := -1;
end;

destructor TPPreferences.TReplace.Destroy();
begin
  FindTextMRU.Free();
  ReplaceTextMRU.Free();

  inherited;
end;

procedure TPPreferences.TReplace.LoadFromXML(const XML: IXMLNode);
var
  I: Integer;
begin
  inherited;

  FindTextMRU.Clear();
  if (Assigned(XMLNode(XML, 'findtext/mru'))) then
    for I := XMLNode(XML, 'findtext/mru').ChildNodes.Count - 1 downto 0 do
      if (XMLNode(XML, 'findtext/mru').ChildNodes[I].NodeName = 'text') then
        FindTextMRU.Add(XMLNode(XML, 'findtext/mru').ChildNodes[I].Text);
  if (Assigned(XMLNode(XML, 'options'))) then Options := StrToReplaceOptions(XMLNode(XML, 'options').Text);
  ReplaceTextMRU.Clear();
  if (Assigned(XMLNode(XML, 'replacetext/mru'))) then
    for I := XMLNode(XML, 'replacetext/mru').ChildNodes.Count - 1 downto 0 do
      if (XMLNode(XML, 'replacetext/mru').ChildNodes[I].NodeName = 'text') then
        ReplaceTextMRU.Add(XMLNode(XML, 'replacetext/mru').ChildNodes[I].Text);
end;

procedure TPPreferences.TReplace.SaveToXML(const XML: IXMLNode);
var
  I: Integer;
begin
  inherited;

  XMLNode(XML, 'findtext/mru').ChildNodes.Clear();
  for I := 0 to FindTextMRU.Count - 1 do
    XMLNode(XML, 'findtext/mru').AddChild('text').Text := FindTextMRU[I];
  XMLNode(XML, 'options').Text := ReplaceOptionsToStr(Options);
  XMLNode(XML, 'replacetext/mru').ChildNodes.Clear();
  for I := 0 to ReplaceTextMRU.Count - 1 do
    XMLNode(XML, 'replacetext/mru').AddChild('text').Text := ReplaceTextMRU[I];
end;

{ TPPreferences.TServer *******************************************************}

{ TPPreferences.TSQLHelp ******************************************************}

constructor TPPreferences.TSQLHelp.Create();
begin
  inherited;

  Left := -1;
  Top := -1;
end;

procedure TPPreferences.TSQLHelp.LoadFromXML(const XML: IXMLNode);
var
  PixelsPerInch: Integer;
begin
  inherited;

  if (not TryStrToInt(XML.OwnerDocument.DocumentElement.Attributes['pixelsperinch'], PixelsPerInch)) then PixelsPerInch := Screen.PixelsPerInch;

  if (Assigned(XMLNode(XML, 'left')) and TryStrToInt(XMLNode(XML, 'left').Text, Left)) then Left := Round(Left * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'top')) and TryStrToInt(XMLNode(XML, 'top').Text, Top)) then Top := Round(Top * Screen.PixelsPerInch / PixelsPerInch);
end;

procedure TPPreferences.TSQLHelp.SaveToXML(const XML: IXMLNode);
begin
  inherited;

  XMLNode(XML, 'left').Text := IntToStr(Left);
  XMLNode(XML, 'top').Text := IntToStr(Top);
end;

{ TPPreferences.TAccounts *****************************************************}

constructor TPPreferences.TAccounts.Create();
begin
  inherited;

  Sort.Column := acName;
  Sort.Ascending := True;
  Widths[acDatabase] := -1;
  Widths[acHost] := -1;
  Widths[acLastLogin] := 0;
  Widths[acName] := 0;
  Widths[acUser] := -1;
end;

procedure TPPreferences.TAccounts.LoadFromXML(const XML: IXMLNode);
var
  PixelsPerInch: Integer;
begin
  inherited;

  if (not TryStrToInt(XML.OwnerDocument.DocumentElement.Attributes['pixelsperinch'], PixelsPerInch)) then PixelsPerInch := Screen.PixelsPerInch;

  if (Assigned(XMLNode(XML, 'database')) and (XMLNode(XML, 'database').Attributes['width'] <> Null) and TryStrToInt(XMLNode(XML, 'database').Attributes['width'], Widths[acDatabase])) then Widths[acDatabase] := Round(Widths[acDatabase] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'host')) and (XMLNode(XML, 'host').Attributes['width'] <> Null) and TryStrToInt(XMLNode(XML, 'host').Attributes['width'], Widths[acHost])) then Widths[acHost] := Round(Widths[acHost] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'lastlogin')) and (XMLNode(XML, 'lastlogin').Attributes['width'] <> Null) and TryStrToInt(XMLNode(XML, 'lastlogin').Attributes['width'], Widths[acLastLogin])) then Widths[acLastLogin] := Round(Widths[acLastLogin] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'name')) and (XMLNode(XML, 'name').Attributes['width'] <> Null) and TryStrToInt(XMLNode(XML, 'name').Attributes['width'], Widths[acName])) then Widths[acName] := Round(Widths[acName] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'sort')) and (XMLNode(XML, 'sort').Attributes['column'] <> Null)) then TryStrToColumn(XMLNode(XML, 'sort').Attributes['column'], Sort.Column);
  if (Assigned(XMLNode(XML, 'sort')) and (XMLNode(XML, 'sort').Attributes['ascending'] <> Null)) then TryStrToBool(XMLNode(XML, 'sort').Attributes['ascending'], Sort.Ascending);
  if (Assigned(XMLNode(XML, 'user')) and (XMLNode(XML, 'user').Attributes['width'] <> Null) and TryStrToInt(XMLNode(XML, 'user').Attributes['width'], Widths[acUser])) then Widths[acUser] := Round(Widths[acUser] * Screen.PixelsPerInch / PixelsPerInch);
end;

procedure TPPreferences.TAccounts.SaveToXML(const XML: IXMLNode);
begin
  inherited;

  XMLNode(XML, 'database').Attributes['width'] := IntToStr(Widths[acDatabase]);
  XMLNode(XML, 'host').Attributes['width'] := IntToStr(Widths[acHost]);
  XMLNode(XML, 'lastlogin').Attributes['width'] := IntToStr(Widths[acLastLogin]);
  XMLNode(XML, 'name').Attributes['width'] := IntToStr(Widths[acName]);
  XMLNode(XML, 'sort').Attributes['column'] := ColumnToStr(Sort.Column);
  XMLNode(XML, 'sort').Attributes['ascending'] := BoolToStr(Sort.Ascending, True);
  XMLNode(XML, 'user').Attributes['width'] := IntToStr(Widths[acUser]);
end;

{ TPPreferences.TTableService *************************************************}

constructor TPPreferences.TTableService.Create();
begin
  inherited;

  Analyze := False;
  Check := False;
  Flush := False;
  Optimize := False;
  Repair := False;
end;

procedure TPPreferences.TTableService.LoadFromXML(const XML: IXMLNode);
begin
  inherited;

  if (Assigned(XMLNode(XML, 'analyze'))) then TryStrToBool(XMLNode(XML, 'analyze').Attributes['enabled'], Analyze);
  if (Assigned(XMLNode(XML, 'check'))) then TryStrToBool(XMLNode(XML, 'check').Attributes['enabled'], Check);
  if (Assigned(XMLNode(XML, 'flush'))) then TryStrToBool(XMLNode(XML, 'flush').Attributes['enabled'], Flush);
  if (Assigned(XMLNode(XML, 'optimize'))) then TryStrToBool(XMLNode(XML, 'optimize').Attributes['enabled'], Optimize);
  if (Assigned(XMLNode(XML, 'repair'))) then TryStrToBool(XMLNode(XML, 'repair').Attributes['enabled'], Repair);
end;

procedure TPPreferences.TTableService.SaveToXML(const XML: IXMLNode);
begin
  inherited;

  XMLNode(XML, 'analyze').Attributes['enabled'] := Analyze;
  XMLNode(XML, 'check').Attributes['enabled'] := Check;
  XMLNode(XML, 'flush').Attributes['enabled'] := Flush;
  XMLNode(XML, 'optimize').Attributes['enabled'] := Optimize;
  XMLNode(XML, 'repair').Attributes['enabled'] := Repair;
end;

{ TPPreferences.TTransfer *****************************************************}

constructor TPPreferences.TTransfer.Create();
begin
  inherited;

  Data := True;
  Structure := False;
end;

procedure TPPreferences.TTransfer.LoadFromXML(const XML: IXMLNode);
begin
  inherited;

  if (Assigned(XMLNode(XML, 'data'))) then TryStrToBool(XMLNode(XML, 'data').Attributes['enabled'], Data);
  if (Assigned(XMLNode(XML, 'structure'))) then TryStrToBool(XMLNode(XML, 'structure').Attributes['enabled'], Structure);
end;

procedure TPPreferences.TTransfer.SaveToXML(const XML: IXMLNode);
begin
  inherited;

  XMLNode(XML, 'data').Attributes['enabled'] := Data;
  XMLNode(XML, 'structure').Attributes['enabled'] := Structure;
end;

{ TPPreferences.TLanguage *****************************************************}

constructor TPPreferences.TLanguage.Create(const FileName: string);
var
  I: Integer;
  Item: Integer;
  MaxItem: Integer;
  Strings: TStringList;
begin
  inherited;

  FActiveQueryBuilderLanguageName := 'English';
  if (not FileExists(Filename)) then
    FLanguageId := LANG_NEUTRAL
  else
  begin
    FLanguageId := ReadInteger('Global', 'LanguageId', LANG_NEUTRAL);
    FActiveQueryBuilderLanguageName := ReadString('Global', 'ActiveQueryBuilderLanguage', 'English');

    Strings := TStringList.Create();

    ReadSectionValues('Strings', Strings);

    MaxItem := 0;
    for I := 0 to Strings.Count - 1 do
      if (TryStrToInt(Strings.Names[I], Item) and (Item > MaxItem)) then
        MaxItem := Item;

    SetLength(FStrs, MaxItem + 1);

    for I := 0 to Strings.Count - 1 do
      if (TryStrToInt(Strings.Names[I], Item)) then
        FStrs[Item] := Strings.ValueFromIndex[I];

    Strings.Free();
  end;
end;

destructor TPPreferences.TLanguage.Destroy();
begin
  SetLength(FStrs, 0);

  inherited;
end;

function TPPreferences.TLanguage.GetStr(Index: Integer): string;
begin
  if ((Index >= Length(FStrs)) or (FStrs[Index] = '')) then
    Result := SysUtils.LoadStr(10000 + Index)
  else
    Result := FStrs[Index];

  Result := ReplaceStr(ReplaceStr(Trim(Result), '\n', #10), '\r', #13);
end;

{ TPPreferences ***************************************************************}

procedure TPPreferences.ApplyToBCEditor(const BCEditor: TBCEditor);
var
  S: string;
begin
  BCEditor.ActiveLine.Visible := Editor.CurrRowBGColorEnabled;
  BCEditor.ActiveLine.Color := Editor.CurrRowBGColor;
  BCEditor.Font.Name := SQLFontName;
  BCEditor.Font.Charset := SQLFontCharset;
  BCEditor.Font.Color := SQLFontColor;
  BCEditor.Font.Size := SQLFontSize;
  S := BCEditor.Font.Name; {$MESSAGE 'Nils'}
  BCEditor.LeftMargin.Font.Name := S;
  BCEditor.LeftMargin.Font.Charset := BCEditor.Font.Charset;
  BCEditor.LeftMargin.Font.Size := BCEditor.Font.Size;
end;

constructor TPPreferences.Create();
var
  Bitmap: Graphics.TBitmap;
  Filename: TFileName;
  Foldername: array [0..MAX_PATH] of Char;
  Font: TFont;
  FontSize: Integer;
  GPBitmap: TGPBitmap;
  GPGraphics: TGPGraphics;
  I: Integer;
  Icon: HICON;
  IconId: Integer;
  MaxIconIndex: Integer;
  NonClientMetrics: TNonClientMetrics;
  Path: string;
  ResData: HGLOBAL;
  ResIndex: Integer;
  ResInfo: HRSRC;
  Resource: Pointer;
  StringList: TStringList;
begin
  inherited Create(KEY_ALL_ACCESS);

  FOnlineVersion := 0;
  FXMLDocument := nil;

  NonClientMetrics.cbSize := SizeOf(NonClientMetrics);
  if (not SystemParametersInfo(SPI_GETNONCLIENTMETRICS, SizeOf(NonClientMetrics), @NonClientMetrics, 0)) then
    FontSize := 9
  else
  begin
    Font := TFont.Create();
    Font.Handle := CreateFontIndirect(NonClientMetrics.lfMessageFont);
    FontSize := Font.Size;
    Font.Free();
  end;

  WindowState := wsNormal;
  Top := 0;
  Left := 0;
  Height := 0;
  Width := 0;
  GridFontName := 'Microsoft Sans Serif';
  GridFontColor := clWindowText;
  GridFontStyle := [];
  GridFontSize := FontSize;
  GridFontCharset := DEFAULT_CHARSET;
  GridMaxColumnWidth := Round(100 * Screen.PixelsPerInch / USER_DEFAULT_SCREEN_DPI);
  GridCurrRowBGColor := $C0FFFF;
  GridCurrRowBGColorEnabled := True;
  GridNullBGColorEnabled := False;
  GridNullBGColor := $E0F0E0;
  GridNullText := True;
  GridMemoContent := False;
  GridDefaultSorting := True;
  QuickAccessVisible := True;
  SetupProgramExecute := False;
  SetupProgramInstalled := False;
  SQLFontName := 'Courier New';
  SQLFontColor := clWindowText;
  SQLFontSize := FontSize;
  SQLFontCharset := DEFAULT_CHARSET;
  LogFontName := 'Courier New';
  LogFontColor := clWindowText;
  LogFontStyle := [];
  LogFontSize := 8;
  LogFontCharset := DEFAULT_CHARSET;
  LogTime := False;
  LogResult := False;
  LogSize := 100 * 1024;
  LanguageFilename := 'English.ini';
  TabsVisible := False;
  ToolbarTabs := [ttObjects, ttBrowser, ttEditor, ttObjectSearch];


  SHGetFolderPath(0, CSIDL_PERSONAL, 0, 0, @Foldername);
  Path := IncludeTrailingPathDelimiter(PChar(@Foldername));
  if (FileExists(IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + 'Desktop.xml') or (SHGetFolderPath(0, CSIDL_APPDATA, 0, 0, @Foldername) <> S_OK)) then
    FUserPath := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName))
  else if (SysUtils.LoadStr(1002) = '') then
    FUserPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(StrPas(PChar(@Foldername))) + 'MySQL-Front')
  else
    FUserPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(StrPas(PChar(@Foldername))) + SysUtils.LoadStr(1002));

  SoundFileNavigating := '';
  if (OpenKeyReadOnly('\AppEvents\Schemes\Apps\Explorer\Navigating\.Current')) then
  begin
    if (ValueExists('')) then
      SoundFileNavigating := ReplaceEnviromentVariables(ReadString(''));
    if (not FileExists(SoundFileNavigating)) then
      SoundFileNavigating := '';

    CloseKey();
  end;

  LoadFromRegistry();

  Filename := ExtractFileName(Application.ExeName);
  Filename := LeftStr(Filename, Length(Filename) - Length(ExtractFileExt(Filename)));
  Filename := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + 'Install' + PathDelim + Filename + '_Setup.exe';
  if (FileExists(Filename)) then
    HandleSetupProgram(Filename);

  Filename := ExtractFileName(Application.ExeName);
  Filename := LeftStr(Filename, Length(Filename) - Length(ExtractFileExt(Filename)));
  FDowndateFilename := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + 'Install' + PathDelim + Filename + '_Setup (2).exe';
  if (not FileExists(FDowndateFilename)) then
    FDowndateFilename := '';


  if (DirectoryExists(PChar(@Foldername) + PathDelim + 'SQL-Front' + PathDelim)
    and not DirectoryExists(UserPath)) then
  begin
    Path := PChar(@Foldername) + PathDelim + 'SQL-Front' + PathDelim;
    CopyDir(Path, UserPath);
    StringList := TStringList.Create();
    StringList.LoadFromFile(Filename);
    StringList.Text := ReplaceStr(StringList.Text, '<session', '<account');
    StringList.Text := ReplaceStr(StringList.Text, '</session', '</account');
    StringList.SaveToFile(Filename);
    StringList.Free();
  end;


  MaxIconIndex := 0;
  for I := 1 to 200 do
    if (FindResource(HInstance, MAKEINTRESOURCE(10000 + I), RT_GROUP_ICON) > 0) then
      MaxIconIndex := I;

  FImages := TImageList.Create(nil);
  FImages.ColorDepth := cd32Bit;
  FImages.Height := GetSystemMetrics(SM_CYSMICON);
  FImages.Width := GetSystemMetrics(SM_CXSMICON);

  for I := 0 to MaxIconIndex do
    if (I = 16) then
    begin // ODBC icon
      SHGetFolderPath(0, CSIDL_SYSTEM, 0, 0, @Foldername);
      ImageList_AddIcon(FImages.Handle, GetFileIcon(StrPas(PChar(@Foldername)) + '\odbcad32.exe'));
    end
    else if (FindResource(HInstance, MAKEINTRESOURCE(10000 + I), RT_GROUP_ICON) > 0) then
      if (FImages.Width = 16) then
        ImageList_AddIcon(FImages.Handle, LoadImage(hInstance, MAKEINTRESOURCE(10000 + I), IMAGE_ICON, FImages.Width, FImages.Height, LR_DEFAULTCOLOR))
      else
      begin
        ResInfo := FindResource(HInstance, MAKEINTRESOURCE(10000 + I), RT_GROUP_ICON);
        ResData := LoadResource(HInstance, ResInfo);
        Resource := LockResource(ResData);
        IconId := LookupIconIdFromDirectoryEx(Resource, TRUE, 64, 64, LR_DEFAULTCOLOR);
        ResInfo := FindResource(HInstance, MAKEINTRESOURCE(IconId), RT_ICON);
        ResData := LoadResource(HInstance, ResInfo);
        Icon := CreateIconFromResourceEx(
          LockResource(ResData), SizeOfResource(HInstance, ResInfo),
          TRUE, $00030000, 64, 64, LR_DEFAULTCOLOR);

        Bitmap := Graphics.TBitmap.Create();
        Bitmap.PixelFormat := pf32bit;
        SetBkMode(Bitmap.Canvas.Handle, TRANSPARENT);
        Bitmap.SetSize(FImages.Width, FImages.Height);

        GPBitmap := TGPBitmap.Create(Icon);

        GPGraphics := TGPGraphics.Create(Bitmap.Canvas.Handle);
        GPGraphics.SetInterpolationMode(InterpolationModeHighQuality);
        GPGraphics.DrawImage(GPBitmap, 0, 0, Bitmap.Width, Bitmap.Height);

        ImageList_Add(FImages.Handle, Bitmap.Handle, Bitmap.MaskHandle);

        GPGraphics.Free();
        Bitmap.Free();
      end
    else if (I > 0) then
    begin
      ImageList_AddIcon(FImages.Handle, ImageList_GetIcon(FImages.Handle, 0, 0));
    end;

  Database := TDatabase.Create();
  Databases := TDatabases.Create();
  Editor := TEditor.Create();
  Event := TEvent.Create();
  Export := TExport.Create();
  Field := TField.Create();
  Find := TFind.Create();
  ForeignKey := TForeignKey.Create();
  Host := THost.Create();
  Import := TImport.Create();
  Key := TKey.Create();
  ODBC := TODBC.Create();
  Paste := TPaste.Create();
  Replace := TReplace.Create();
  Routine := TRoutine.Create();
  Server := TServer.Create();
  Account := TAccount.Create();
  Accounts := TAccounts.Create();
  SQLHelp := TSQLHelp.Create();
  Statement := TStatement.Create();
  Table := TTable.Create();
  TableService := TTableService.Create();
  Transfer := TTransfer.Create();
  Trigger := TTrigger.Create();
  User := TUser.Create();
  View := TPView.Create();

  Open();
end;

destructor TPPreferences.Destroy();
begin
  SaveToRegistry();

  Database.Free();
  Databases.Free();
  Editor.Free();
  Event.Free();
  Export.Free();
  Field.Free();
  Find.Free();
  ForeignKey.Free();
  Host.Free();
  Import.Free();
  Key.Free();
  ODBC.Free();
  Paste.Free();
  Replace.Free();
  Routine.Free();
  Server.Free();
  Account.Free();
  Accounts.Free();
  SQLHelp.Free();
  Statement.Free();
  Table.Free();
  TableService.Free();
  Transfer.Free();
  Trigger.Free();
  User.Free();
  View.Free();

  FImages.Free();

  if (Assigned(FLanguage)) then
    FLanguage.Free();

  inherited;
end;

function TPPreferences.GetDowndateVersionStr(): string;
var
  FileInfo: VS_FIXEDFILEINFO;
begin
  if (not FileExists(DowndateFilename)
    or not GetFileInfo(DowndateFilename, FileInfo)) then
    Result := ''
  else
    Result :=
      IntToStr(FileInfo.dwFileVersionMS shr 16) + '.' + IntToStr(FileInfo.dwFileVersionMS and $FFFF)
        + '  (Build ' + IntToStr(FileInfo.dwFileVersionLS shr 16) + '.' + IntToStr(FileInfo.dwFileVersionLS and $FFFF) + ')';
end;

function TPPreferences.GetFilename(): TFileName;
begin
  Result := UserPath + 'Desktop.xml';
end;

function TPPreferences.GetLanguage(): TLanguage;
begin
  if (not Assigned(FLanguage)) then
    FLanguage := TPPreferences.TLanguage.Create(LanguagePath + LanguageFilename);

  Result := FLanguage;
end;

function TPPreferences.GetLanguagePath(): TFileName;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName) + 'Languages');

  {$IFDEF Debug}
    if (not FileExists(Result)) then
      Result := IncludeTrailingPathDelimiter('..\Languages\');
  {$ENDIF}
end;

function TPPreferences.GetXMLDocument(): IXMLDocument;
begin
  if (not Assigned(FXMLDocument)) then
  begin
    if (FileExists(Filename)) then
      try
        FXMLDocument := LoadXMLDocument(Filename);

        if (VersionStrToVersion(FXMLDocument.DocumentElement.Attributes['version']) < 10002)  then
        begin
          XMLNode(FXMLDocument.DocumentElement, 'grid/maxcolumnwidth').Text := IntToStr(100);

          FXMLDocument.DocumentElement.Attributes['version'] := '1.0.2';
        end;

        if (VersionStrToVersion(FXMLDocument.DocumentElement.Attributes['version']) < 10100)  then
        begin
          FXMLDocument.DocumentElement.ChildNodes.Delete('session');
          FXMLDocument.DocumentElement.ChildNodes.Delete('sessions');

          FXMLDocument.DocumentElement.Attributes['version'] := '1.1.0';
        end;

        if (VersionStrToVersion(FXMLDocument.DocumentElement.Attributes['version']) < 10101)  then
        begin
          if (Assigned(XMLNode(FXMLDocument.DocumentElement, 'updates/check'))
            and (UpperCase(XMLNode(FXMLDocument.DocumentElement, 'updates/check').Text) = 'STARTUP')) then
            XMLNode(FXMLDocument.DocumentElement, 'updates/check').Text := 'Daily';

          FXMLDocument.DocumentElement.Attributes['version'] := '1.1.1';
        end;

        if (VersionStrToVersion(FXMLDocument.DocumentElement.Attributes['version']) < 10200)  then
        begin
          FXMLDocument.DocumentElement.Attributes['pixelsperinch'] := IntToStr(Screen.PixelsPerInch);

          FXMLDocument.DocumentElement.Attributes['version'] := '1.2.0';
        end;
      except
        FXMLDocument := nil;
      end;

    if (not Assigned(FXMLDocument) or not Assigned(FXMLDocument.DocumentElement)) then
    begin
      FXMLDocument := NewXMLDocument();
      FXMLDocument.Encoding := 'utf-8';
      FXMLDocument.Node.AddChild('desktop').Attributes['version'] := '1.1.1';
    end;

    FXMLDocument.Options := FXMLDocument.Options - [doAttrNull, doNodeAutoCreate];
  end;

  Result := FXMLDocument;
end;

procedure TPPreferences.HandleSetupProgram(const Filename: TFileName);
var
  Directory: TFileName;
  Ext: TFileName;
  Found: Boolean;
  Name: TFileName;
  SearchFileInfo: VS_FIXEDFILEINFO;
  SearchRec: TSearchRec;
  SetupProgramFileInfo: VS_FIXEDFILEINFO;
begin
  Directory := IncludeTrailingPathDelimiter(ExtractFileDir(Filename));
  Ext := ExtractFileExt(Filename);
  Name := ExtractFileName(Filename);
  Name := LeftStr(Name, Length(Name) - Length(Ext));

  if (UpdateRemoved = '') then
  begin
    if (not GetFileInfo(Filename, SetupProgramFileInfo)
      or (FindFirst(Directory + Name + ' (*)' + Ext, faNormal, SearchRec) <> 0)) then
      MoveFile(PChar(Filename), PChar(Directory + Name + ' (1)' + Ext))
    else
    begin
      Found := False;
      repeat
        Found := Found
          or (GetFileInfo(Directory + SearchRec.Name, SearchFileInfo) and CompareMem(@SearchFileInfo, @SetupProgramFileInfo, SizeOf(VS_FIXEDFILEINFO)));
      until (FindNext(SearchRec) <> 0);
      FindClose(SearchRec);

      if (Found) then
        DeleteFile(Filename)
      else
      begin
        if (FileExists(Directory + Name + ' (1)' + Ext)) then
        begin
          if (FileExists(Directory + Name + ' (2)' + Ext)) then
          begin
            if (FileExists(Directory + Name + ' (3)' + Ext)) then
            begin
              if (FileExists(Directory + Name + ' (4)' + Ext)) then
              begin
                if (FileExists(Directory + Name + ' (5)' + Ext)) then
                begin
                  if (FileExists(Directory + Name + ' (6)' + Ext)) then
                    DeleteFile(Directory + Name + ' (6)' + Ext);
                  MoveFile(PChar(Directory + Name + ' (5)' + Ext), PChar(Directory + Name + ' (6)' + Ext));
                end;
                MoveFile(PChar(Directory + Name + ' (4)' + Ext), PChar(Directory + Name + ' (5)' + Ext));
              end;
              MoveFile(PChar(Directory + Name + ' (3)' + Ext), PChar(Directory + Name + ' (4)' + Ext));
            end;
            MoveFile(PChar(Directory + Name + ' (2)' + Ext), PChar(Directory + Name + ' (3)' + Ext));
          end;
          MoveFile(PChar(Directory + Name + ' (1)' + Ext), PChar(Directory + Name + ' (2)' + Ext));
        end;
        MoveFile(PChar(Filename), PChar(Directory + Name + ' (1)' + Ext));
      end;
    end;
  end
  else
  begin
    if (GetFileInfo(Filename, SetupProgramFileInfo)
      and FileExists(Directory + Name + ' (2)' + Ext)
      and GetFileInfo(Directory + Name + ' (2)' + Ext, SearchFileInfo)
      and CompareMem(@SearchFileInfo, @SetupProgramFileInfo, SizeOf(VS_FIXEDFILEINFO))) then
    begin
      if (FileExists(Directory + Name + ' (1)' + Ext)) then
        DeleteFile(Directory + Name + ' (1)' + Ext);
      MoveFile(PChar(Directory + Name + ' (2)' + Ext), PChar(Directory + Name + ' (1)' + Ext));
      if (FileExists(Directory + Name + ' (3)' + Ext)) then
      begin
        MoveFile(PChar(Directory + Name + ' (3)' + Ext), PChar(Directory + Name + ' (2)' + Ext));
        if (FileExists(Directory + Name + ' (4)' + Ext)) then
        begin
          MoveFile(PChar(Directory + Name + ' (4)' + Ext), PChar(Directory + Name + ' (3)' + Ext));
          if (FileExists(Directory + Name + ' (5)' + Ext)) then
          begin
            MoveFile(PChar(Directory + Name + ' (5)' + Ext), PChar(Directory + Name + ' (4)' + Ext));
            if (FileExists(Directory + Name + ' (6)' + Ext)) then
              MoveFile(PChar(Directory + Name + ' (6)' + Ext), PChar(Directory + Name + ' (5)' + Ext));
          end;
        end;
      end;
    end;

   UpdateRemoved := '';
  end;

  if (FileExists(Filename)) then
    DeleteFile(Filename);
end;

procedure TPPreferences.LoadFromRegistry();
var
  KeyName: string;
begin
  RootKey := HKEY_CLASSES_ROOT;

  AssociateSQL := False;
  if (OpenKeyReadOnly('.sql')) then
  begin
    if (ValueExists('')) then KeyName := ReadString('');
    CloseKey();

    if (OpenKeyReadOnly(KeyName + '\shell\open\command')) then
    begin
      AssociateSQL := Pos(UpperCase(Application.ExeName), UpperCase(ReadString(''))) > 0;
      CloseKey();
    end;
  end;
  OldAssociateSQL := AssociateSQL;

  RootKey := HKEY_CURRENT_USER;

  if (OpenKeyReadOnly(SysUtils.LoadStr(1003))) then
  begin
    if (ValueExists('LanguageFile')) then LanguageFilename := ExtractFileName(ReadString('LanguageFile'));
    if (ValueExists('Path') and DirectoryExists(ReadString('Path'))) then Path := IncludeTrailingPathDelimiter(ReadString('Path'));
    if (ValueExists('SetupProgram') and FileExists(ReadString('SetupProgram'))) then SetupProgram := ReadString('SetupProgram');
    if (ValueExists('SetupProgramInstalled')) then SetupProgramInstalled := ReadBool('SetupProgramInstalled');
    if (ValueExists('UpdateRemoved')) then UpdateRemoved := ReadString('UpdateRemoved');

    CloseKey();
  end;
end;

procedure TPPreferences.LoadFromXML(const XML: IXMLNode);
var
  PixelsPerInch: Integer;
  Visible: Boolean;
begin
  inherited;

  XML.OwnerDocument.Options := XML.OwnerDocument.Options - [doNodeAutoCreate];

  if (not TryStrToInt(XML.OwnerDocument.DocumentElement.Attributes['pixelsperinch'], PixelsPerInch)) then PixelsPerInch := Screen.PixelsPerInch;

  if (Assigned(XMLNode(XML, 'grid/currentrow/background'))) then TryStrToBool(XMLNode(XML, 'grid/currentrow/background').Attributes['visible'], GridCurrRowBGColorEnabled);
  if (Assigned(XMLNode(XML, 'grid/currentrow/background/color'))) then GridCurrRowBGColor := StringToColor(XMLNode(XML, 'grid/currentrow/background/color').Text);
  if (Assigned(XMLNode(XML, 'grid/font/charset'))) then TryStrToInt(XMLNode(XML, 'grid/font/charset').Text, GridFontCharset);
  if (Assigned(XMLNode(XML, 'grid/font/color'))) then GridFontColor := StringToColor(XMLNode(XML, 'grid/font/color').Text);
  if (Assigned(XMLNode(XML, 'grid/font/name'))) then GridFontName := XMLNode(XML, 'grid/font/name').Text;
  if (Assigned(XMLNode(XML, 'grid/font/size'))) then TryStrToInt(XMLNode(XML, 'grid/font/size').Text, GridFontSize);
  if (Assigned(XMLNode(XML, 'grid/font/style'))) then GridFontStyle := StrToStyle(XMLNode(XML, 'grid/font/style').Text);
  if (Assigned(XMLNode(XML, 'grid/memo'))) then TryStrToBool(XMLNode(XML, 'grid/memo').Attributes['visible'], GridMemoContent);
  if (Assigned(XMLNode(XML, 'grid/null'))) then TryStrToBool(XMLNode(XML, 'grid/null').Attributes['visible'], GridNullText);
  if (Assigned(XMLNode(XML, 'grid/null/background'))) then TryStrToBool(XMLNode(XML, 'grid/null/background').Attributes['visible'], GridNullBGColorEnabled);
  if (Assigned(XMLNode(XML, 'grid/null/background/color'))) then GridNullBGColor := StringToColor(XMLNode(XML, 'grid/null/background/color').Text);
  if (Assigned(XMLNode(XML, 'grid/maxcolumnwidth')) and TryStrToInt(XMLNode(XML, 'grid/maxcolumnwidth').Text, GridMaxColumnWidth)) then GridMaxColumnWidth := Round(GridMaxColumnWidth * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'height')) and TryStrToInt(XMLNode(XML, 'height').Text, Height)) then Height := Round(Height * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'language/file'))) then LanguageFilename := ExtractFileName(XMLNode(XML, 'language/file').Text);
  if (Assigned(XMLNode(XML, 'left'))) then TryStrToInt(XMLNode(XML, 'left').Text, Left);
  if (Assigned(XMLNode(XML, 'log/font/charset'))) then TryStrToInt(XMLNode(XML, 'log/font/charset').Text, LogFontCharset);
  if (Assigned(XMLNode(XML, 'log/font/color'))) then LogFontColor := StringToColor(XMLNode(XML, 'log/font/color').Text);
  if (Assigned(XMLNode(XML, 'log/font/name'))) then LogFontName := XMLNode(XML, 'log/font/name').Text;
  if (Assigned(XMLNode(XML, 'log/font/size'))) then TryStrToInt(XMLNode(XML, 'log/font/size').Text, LogFontSize);
  if (Assigned(XMLNode(XML, 'log/font/style'))) then LogFontStyle := StrToStyle(XMLNode(XML, 'log/font/style').Text);
  if (Assigned(XMLNode(XML, 'log/size')) and TryStrToInt(XMLNode(XML, 'log/size').Text, LogSize)) then LogSize := Round(LogSize * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'log/dbresult'))) then TryStrToBool(XMLNode(XML, 'log/dbresult').Attributes['visible'], LogResult);
  if (Assigned(XMLNode(XML, 'log/time'))) then TryStrToBool(XMLNode(XML, 'log/time').Attributes['visible'], LogTime);
  if (Assigned(XMLNode(XML, 'quickaccess'))) then TryStrToBool(XMLNode(XML, 'quickaccess').Attributes['visible'], QuickAccessVisible);
  if (Assigned(XMLNode(XML, 'sql/font/charset'))) then TryStrToInt(XMLNode(XML, 'sql/font/charset').Text, SQLFontCharset);
  if (Assigned(XMLNode(XML, 'sql/font/color'))) then SQLFontColor := StringToColor(XMLNode(XML, 'sql/font/color').Text);
  if (Assigned(XMLNode(XML, 'sql/font/name'))) then SQLFontName := XMLNode(XML, 'sql/font/name').Text;
  if (Assigned(XMLNode(XML, 'sql/font/size'))) then TryStrToInt(XMLNode(XML, 'sql/font/size').Text, SQLFontSize);
  if (Assigned(XMLNode(XML, 'tabs'))) then TryStrToBool(XMLNode(XML, 'tabs').Attributes['visible'], TabsVisible);
  if (Assigned(XMLNode(XML, 'toolbar/objects')) and TryStrToBool(XMLNode(XML, 'toolbar/objects').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttObjects] else ToolbarTabs := ToolbarTabs - [ttObjects];
  if (Assigned(XMLNode(XML, 'toolbar/browser')) and TryStrToBool(XMLNode(XML, 'toolbar/browser').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttBrowser] else ToolbarTabs := ToolbarTabs - [ttBrowser];
  if (Assigned(XMLNode(XML, 'toolbar/ide')) and TryStrToBool(XMLNode(XML, 'toolbar/ide').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttIDE] else ToolbarTabs := ToolbarTabs - [ttIDE];
  if (Assigned(XMLNode(XML, 'toolbar/builder')) and TryStrToBool(XMLNode(XML, 'toolbar/builder').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttBuilder] else ToolbarTabs := ToolbarTabs - [ttBuilder];
  if (Assigned(XMLNode(XML, 'toolbar/diagram')) and TryStrToBool(XMLNode(XML, 'toolbar/diagram').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttDiagram] else ToolbarTabs := ToolbarTabs - [ttDiagram];
  if (Assigned(XMLNode(XML, 'toolbar/editor')) and TryStrToBool(XMLNode(XML, 'toolbar/editor').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttEditor] else ToolbarTabs := ToolbarTabs - [ttEditor];
  if (Assigned(XMLNode(XML, 'toolbar/editor2')) and TryStrToBool(XMLNode(XML, 'toolbar/editor2').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttEditor2] else ToolbarTabs := ToolbarTabs - [ttEditor2];
  if (Assigned(XMLNode(XML, 'toolbar/editor3')) and TryStrToBool(XMLNode(XML, 'toolbar/editor3').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttEditor3] else ToolbarTabs := ToolbarTabs - [ttEditor3];
  if (Assigned(XMLNode(XML, 'toolbar/objectsearch')) and TryStrToBool(XMLNode(XML, 'toolbar/objectsearch').Attributes['visible'], Visible)) then
    if (Visible) then ToolbarTabs := ToolbarTabs + [ttObjectSearch] else ToolbarTabs := ToolbarTabs - [ttObjectSearch];
  if (Assigned(XMLNode(XML, 'top')) and TryStrToInt(XMLNode(XML, 'top').Text, Top)) then Top := Round(Top * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'width')) and TryStrToInt(XMLNode(XML, 'width').Text, Width)) then Width := Round(Width * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'windowstate'))) then TryStrToWindowState(XMLNode(XML, 'windowstate').Text, WindowState);

  if (Assigned(XMLNode(XML, 'database'))) then Database.LoadFromXML(XMLNode(XML, 'database'));
  if (Assigned(XMLNode(XML, 'editor'))) then Editor.LoadFromXML(XMLNode(XML, 'editor'));
  if (Assigned(XMLNode(XML, 'event'))) then Event.LoadFromXML(XMLNode(XML, 'event'));
  if (Assigned(XMLNode(XML, 'export'))) then Export.LoadFromXML(XMLNode(XML, 'export'));
  if (Assigned(XMLNode(XML, 'field'))) then Field.LoadFromXML(XMLNode(XML, 'field'));
  if (Assigned(XMLNode(XML, 'find'))) then Find.LoadFromXML(XMLNode(XML, 'find'));
  if (Assigned(XMLNode(XML, 'foreignkey'))) then ForeignKey.LoadFromXML(XMLNode(XML, 'foreignkey'));
  if (Assigned(XMLNode(XML, 'host'))) then Host.LoadFromXML(XMLNode(XML, 'host'));
  if (Assigned(XMLNode(XML, 'import'))) then Import.LoadFromXML(XMLNode(XML, 'import'));
  if (Assigned(XMLNode(XML, 'index'))) then Key.LoadFromXML(XMLNode(XML, 'index'));
  if (Assigned(XMLNode(XML, 'odbc'))) then ODBC.LoadFromXML(XMLNode(XML, 'odbc'));
  if (Assigned(XMLNode(XML, 'paste'))) then Paste.LoadFromXML(XMLNode(XML, 'paste'));
  if (Assigned(XMLNode(XML, 'replace'))) then Replace.LoadFromXML(XMLNode(XML, 'replace'));
  if (Assigned(XMLNode(XML, 'routine'))) then Routine.LoadFromXML(XMLNode(XML, 'routine'));
  if (Assigned(XMLNode(XML, 'server'))) then Server.LoadFromXML(XMLNode(XML, 'server'));
  if (Assigned(XMLNode(XML, 'account'))) then Account.LoadFromXML(XMLNode(XML, 'account'));
  if (Assigned(XMLNode(XML, 'accounts'))) then Accounts.LoadFromXML(XMLNode(XML, 'accounts'));
  if (Assigned(XMLNode(XML, 'sqlhelp'))) then SQLHelp.LoadFromXML(XMLNode(XML, 'sqlhelp'));
  if (Assigned(XMLNode(XML, 'statement'))) then Statement.LoadFromXML(XMLNode(XML, 'statement'));
  if (Assigned(XMLNode(XML, 'table'))) then Table.LoadFromXML(XMLNode(XML, 'table'));
  if (Assigned(XMLNode(XML, 'tableservice'))) then TableService.LoadFromXML(XMLNode(XML, 'tableservice'));
  if (Assigned(XMLNode(XML, 'transfer'))) then Transfer.LoadFromXML(XMLNode(XML, 'transfer'));
  if (Assigned(XMLNode(XML, 'trigger'))) then Trigger.LoadFromXML(XMLNode(XML, 'trigger'));
  if (Assigned(XMLNode(XML, 'user'))) then User.LoadFromXML(XMLNode(XML, 'user'));
  if (Assigned(XMLNode(XML, 'view'))) then View.LoadFromXML(XMLNode(XML, 'view'));

  FreeAndNil(FLanguage);
end;

function TPPreferences.LoadStr(const Index: Integer; const Param1: string = ''; const Param2: string = ''; const Param3: string = ''): string;
begin
  SetLength(Result, 100);
  if (Assigned(Language) and (Language.Strs[Index] <> '')) then
    Result := Language.Strs[Index]
  else
    Result := SysUtils.LoadStr(10000 + Index);
  if (Result = '') then
    Result := '<' + IntToStr(Index) + '>';

  Result := ReplaceStr(Result, '%1', Param1);
  Result := ReplaceStr(Result, '%2', Param2);
  Result := ReplaceStr(Result, '%3', Param3);
end;

procedure TPPreferences.Open();
begin
  if Assigned(XMLDocument.DocumentElement) then LoadFromXML(XMLDocument.DocumentElement);
end;

procedure TPPreferences.Save();
begin
  FreeAndNil(FLanguage);
  SaveToXML(XMLDocument.DocumentElement);
end;

procedure TPPreferences.SaveToRegistry();
var
  KeyName: string;
begin
  Access := KEY_ALL_ACCESS;

  if (AssociateSQL <> OldAssociateSQL) then
  begin
    RootKey := HKEY_CLASSES_ROOT;

    if (OpenKey('.sql', True)) then
    begin
      if (not ValueExists('')) then WriteString('', 'SQLFile');
      KeyName := ReadString('');
      CloseKey();
    end;

    if (not AssociateSQL) then
    begin
      if (OpenKey(KeyName + '\DefaultIcon', False)) then
      begin
        if (ValueExists('')) then
          DeleteValue('');
        CloseKey();
      end;
      if (OpenKey(KeyName + '\shell\open\command', False)) then
      begin
        if (ValueExists('')) then
          DeleteValue('');
        CloseKey();
      end;
    end
    else
    begin
      if (OpenKey(KeyName + '\DefaultIcon', True)) then
        begin WriteString('', Application.ExeName + ',0'); CloseKey(); end;
      if (OpenKey(KeyName + '\shell\open\command', True)) then
        begin WriteString('', '"' + Application.ExeName + '" "%0"'); CloseKey(); end;
    end;

    RootKey := HKEY_CURRENT_USER;
  end;

  RootKey := HKEY_CURRENT_USER;

  if (OpenKey(SysUtils.LoadStr(1003), False) or (UserPath <> ExtractFilePath(Application.ExeName)) and OpenKey(SysUtils.LoadStr(1003), True)) then
  begin
    if (SetupProgram <> '') then
      WriteString('SetupProgram', SetupProgram)
    else if (ValueExists('SetupProgram')) then
      DeleteValue('SetupProgram');
    if (SetupProgramInstalled) then
      WriteBool('SetupProgramInstalled', SetupProgramInstalled)
    else if (ValueExists('SetupProgramInstalled')) then
      DeleteValue('SetupProgramInstalled');
    WriteString('Path', Path);
    if (UpdateRemoved <> '') then
      WriteString('UpdateRemoved', UpdateRemoved)
    else if (ValueExists('UpdateRemoved')) then
      DeleteValue('UpdateRemoved');

    CloseKey();
  end;

  Access := KEY_READ;

  SaveToXML(XMLDocument.DocumentElement);
end;

procedure TPPreferences.SaveToXML(const XML: IXMLNode);
begin
  XML.OwnerDocument.Options := XML.OwnerDocument.Options + [doNodeAutoCreate];

  XML.OwnerDocument.DocumentElement.Attributes['pixelsperinch'] := IntToStr(Screen.PixelsPerInch);

  XMLNode(XML, 'grid/currentrow/background').Attributes['visible'] := GridCurrRowBGColorEnabled;
  XMLNode(XML, 'grid/currentrow/background/color').Text := ColorToString(GridCurrRowBGColor);
  XMLNode(XML, 'grid/font/charset').Text := IntToStr(GridFontCharset);
  XMLNode(XML, 'grid/font/color').Text := ColorToString(GridFontColor);
  XMLNode(XML, 'grid/font/name').Text := GridFontName;
  XMLNode(XML, 'grid/font/size').Text := IntToStr(GridFontSize);
  XMLNode(XML, 'grid/font/style').Text := StyleToStr(GridFontStyle);
  XMLNode(XML, 'grid/memo').Attributes['visible'] := GridMemoContent;
  XMLNode(XML, 'grid/null').Attributes['visible'] := GridNullText;
  XMLNode(XML, 'grid/null/background').Attributes['visible'] := GridNullBGColorEnabled;
  XMLNode(XML, 'grid/null/background/color').Text := ColorToString(GridNullBGColor);
  XMLNode(XML, 'grid/maxcolumnwidth').Text := IntToStr(GridMaxColumnWidth);
  XMLNode(XML, 'height').Text := IntToStr(Height);
  XMLNode(XML, 'language/file').Text := ExtractFileName(LanguageFilename);
  XMLNode(XML, 'left').Text := IntToStr(Left);
  XMLNode(XML, 'log/font/charset').Text := IntToStr(LogFontCharset);
  XMLNode(XML, 'log/font/color').Text := ColorToString(LogFontColor);
  XMLNode(XML, 'log/font/name').Text := LogFontName;
  XMLNode(XML, 'log/font/size').Text := IntToStr(LogFontSize);
  XMLNode(XML, 'log/font/style').Text := StyleToStr(LogFontStyle);
  XMLNode(XML, 'log/size').Text := IntToStr(LogSize);
  XMLNode(XML, 'log/dbresult').Attributes['visible'] := LogResult;
  XMLNode(XML, 'log/time').Attributes['visible'] := LogTime;
  if (WindowState in [wsNormal, wsMaximized	]) then
    XMLNode(XML, 'windowstate').Text := WindowStateToStr(WindowState);
  XMLNode(XML, 'quickaccess').Attributes['visible'] := QuickAccessVisible;
  XMLNode(XML, 'sql/font/charset').Text := IntToStr(SQLFontCharset);
  XMLNode(XML, 'sql/font/color').Text := ColorToString(SQLFontColor);
  XMLNode(XML, 'sql/font/name').Text := SQLFontName;
  XMLNode(XML, 'sql/font/size').Text := IntToStr(SQLFontSize);
  XMLNode(XML, 'tabs').Attributes['visible'] := TabsVisible;
  XMLNode(XML, 'toolbar/objects').Attributes['visible'] := ttObjects in ToolbarTabs;
  XMLNode(XML, 'toolbar/browser').Attributes['visible'] := ttBrowser in ToolbarTabs;
  XMLNode(XML, 'toolbar/ide').Attributes['visible'] := ttIDE in ToolbarTabs;
  XMLNode(XML, 'toolbar/builder').Attributes['visible'] := ttBuilder in ToolbarTabs;
  XMLNode(XML, 'toolbar/diagram').Attributes['visible'] := ttDiagram in ToolbarTabs;
  XMLNode(XML, 'toolbar/editor').Attributes['visible'] := ttEditor in ToolbarTabs;
  XMLNode(XML, 'toolbar/editor2').Attributes['visible'] := ttEditor2 in ToolbarTabs;
  XMLNode(XML, 'toolbar/editor3').Attributes['visible'] := ttEditor3 in ToolbarTabs;
  XMLNode(XML, 'toolbar/objectsearch').Attributes['visible'] := ttObjectSearch in ToolbarTabs;
  XMLNode(XML, 'top').Text := IntToStr(Top);

  XMLNode(XML, 'width').Text := IntToStr(Width);

  // Debug 2017-04-25
  Assert(Assigned(Database));

  Database.SaveToXML(XMLNode(XML, 'database', True));
  Editor.SaveToXML(XMLNode(XML, 'editor', True));
  Event.SaveToXML(XMLNode(XML, 'event', True));
  Export.SaveToXML(XMLNode(XML, 'export', True));
  Field.SaveToXML(XMLNode(XML, 'field', True));
  Find.SaveToXML(XMLNode(XML, 'find', True));
  ForeignKey.SaveToXML(XMLNode(XML, 'foreignkey', True));
  Host.SaveToXML(XMLNode(XML, 'host', True));
  Import.SaveToXML(XMLNode(XML, 'import', True));
  Key.SaveToXML(XMLNode(XML, 'index', True));
  ODBC.SaveToXML(XMLNode(XML, 'odbc', True));
  Paste.SaveToXML(XMLNode(XML, 'paste', True));
  Replace.SaveToXML(XMLNode(XML, 'replace', True));
  Routine.SaveToXML(XMLNode(XML, 'routine', True));
  Server.SaveToXML(XMLNode(XML, 'server', True));
  Account.SaveToXML(XMLNode(XML, 'account', True));
  Accounts.SaveToXML(XMLNode(XML, 'accounts', True));
  SQLHelp.SaveToXML(XMLNode(XML, 'sqlhelp', True));
  Statement.SaveToXML(XMLNode(XML, 'statement', True));
  Table.SaveToXML(XMLNode(XML, 'table', True));
  TableService.SaveToXML(XMLNode(XML, 'tableservice', True));
  Transfer.SaveToXML(XMLNode(XML, 'transfer', True));
  Trigger.SaveToXML(XMLNode(XML, 'trigger', True));
  User.SaveToXML(XMLNode(XML, 'user', True));
  View.SaveToXML(XMLNode(XML, 'view', True));

  if (XML.OwnerDocument.Modified and ForceDirectories(ExtractFilePath(Filename))) then
    try
      // We do not have to know about problems.
      XML.OwnerDocument.SaveToFile(Filename);
    except
    end;
end;

{ TPAccount.TAddresses ********************************************************}

procedure TPAccount.TAddresses.Put(Index: Integer; Address: string);
begin
  FValues[Index] := Address;
end;

{ TPAccount.TFavorite *********************************************************}

constructor TPAccount.TFavorite.Create(const AFavorites: TFavorites; const AAddress: string);
begin
  inherited Create();

  FFavorites := AFavorites;
  FAddress := AAddress;
end;

procedure TPAccount.TFavorite.SetAddress(AAddress: string);
begin
  FAddress := AAddress;

  Favorites.Changed();
end;

{ TPAccount.TFavorites ********************************************************}

procedure TPAccount.TFavorites.Add(const Address: string);
begin
  if (IndexOf(Address) < 0) then
  begin
    Add(TFavorite.Create(Self, Address));

    Changed();
  end;
end;

procedure TPAccount.TFavorites.Changed();
var
  I: Integer;
begin
  for I := 0 to Length(EventProcs) - 1 do
    EventProcs[I](Self);
end;

procedure TPAccount.TFavorites.Clear();
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Favorite[I].Free();

  inherited;
end;

constructor TPAccount.TFavorites.Create(const AAccount: TPAccount);
begin
  inherited Create();

  FAccount := AAccount;
end;

procedure TPAccount.TFavorites.Delete(Index: Integer);
begin
  Favorite[Index].Free();

  inherited;

  Changed();
end;

function TPAccount.TFavorites.GetFavorite(Index: Integer): TFavorite;
begin
  Result := TFavorite(Items[Index]);
end;

function TPAccount.TFavorites.IndexOf(const Address: string): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to Count - 1 do
    if (Favorite[I].Address = Address) then
      Result := I;
end;

procedure TPAccount.TFavorites.Insert(Index: Integer; const Address: string);
begin
  if (IndexOf(Address) < 0) then
  begin
    inherited Insert(Index, TFavorite.Create(Self, Address));

    Changed();
  end;
end;

procedure TPAccount.TFavorites.LoadFromXML(const XML: IXMLNode);
var
  Node: IXMLNode;
begin
  Clear();

  Node := XML.ChildNodes.First();
  while (Assigned(Node)) do
  begin
    if ((Node.NodeName = 'favorite')
      and (Node.Text <> '')) then
      Add(TFavorite.Create(Self, Account.ExpandAddress(Node.Text)));
    Node := Node.NextSibling();
  end;

  Changed();
end;

procedure TPAccount.TFavorites.Move(CurIndex, NewIndex: Integer);
begin
  inherited;

  Changed();
end;

procedure TPAccount.TFavorites.SaveToXML(const XML: IXMLNode);
var
  I: Integer;
begin
  for I := XML.ChildNodes.Count - 1 downto 0 do
    if (XML.ChildNodes[I].NodeName = 'favorite') then
      XML.ChildNodes.Delete(I);

  for I := 0 to Count - 1 do
    XML.AddChild('favorite').Text := Account.ExtractPath(Favorite[I].Address);
end;

procedure TPAccount.TFavorites.RegisterEventProc(const AEventProc: TEventProc);
var
  I: Integer;
  Index: Integer;
begin
  Index := -1;
  for I := 0 to Length(EventProcs) - 1 do
    if (CompareMem(@TMethod(EventProcs[I]), @TMethod(AEventProc), SizeOf(TEventProc))) then
      Index := I;

  if (Index < 0) then
  begin
    SetLength(EventProcs, Length(EventProcs) + 1);
    EventProcs[Length(EventProcs) - 1] := AEventProc;
  end;
end;

procedure TPAccount.TFavorites.UnRegisterEventProc(const AEventProc: TEventProc);
var
  I: Integer;
  Index: Integer;
begin
  Index := -1;
  for I := 0 to Length(EventProcs) - 1 do
    if (CompareMem(@TMethod(EventProcs[I]), @TMethod(AEventProc), SizeOf(TEventProc))) then
      Index := I;

  if (Index >= 0) then
  begin
    if (Index + 1 < Length(EventProcs)) then
      MoveMemory(@TMethod(EventProcs[Index]), @TMethod(EventProcs[Index + 1]), (Length(EventProcs) - Index - 1) * SizeOf(TEventProc));
    SetLength(EventProcs, Length(EventProcs) - 1);
  end;
end;

{ TPAccount.TFile *************************************************************}

constructor TPAccount.TFile.Create(const AFiles: TPAccount.TFiles);
begin
  inherited Create();

  FFiles := AFiles;
end;

procedure TPAccount.TFile.LoadFromXML(const XML: IXMLNode);
var
  CodePage: Integer;
begin
  FFilename := XML.Text;
  if ((XML.Attributes['codepage'] <> Null) and TryStrToInt(XML.Attributes['codepage'], CodePage)) then FCodePage := CodePage;
end;

procedure TPAccount.TFile.SaveToXML(const XML: IXMLNode);
begin
  XML.OwnerDocument.Options := XML.OwnerDocument.Options + [doNodeAutoCreate];

  XML.Text := Filename;
  if (CodePage <> CP_ACP) then
    XML.Attributes['codepage'] := IntToStr(CodePage)
  else if (XML.Attributes['codepage'] <> Null) then
    XML.Attributes['codepage'] := Null;

  XML.OwnerDocument.Options := XML.OwnerDocument.Options - [doNodeAutoCreate];
end;

{ TPAccount.TFiles ************************************************************}

procedure TPAccount.TFiles.Add(const AFilename: TFileName; const ACodePage: Cardinal);
var
  I: Integer;
  Index: Integer;
begin
  Index := -1;

  I := 0;
  while ((I < Count) and (Index < 0)) do
    if (lstrcmpi(PChar(AFilename), PChar(Files[I].Filename)) = 0) then
      Index := I
    else
      Inc(I);

  if (Index < 0) then
  begin
    Index := 0;
    Insert(Index, TPAccount.TFile.Create(Self));

    while (Count > MaxCount) do
    begin
      Files[Count - 1].Free();
      Delete(Count - 1);
    end;
  end
  else if (Index <> 0) then
    Move(Index, 0);

  Files[0].FFilename := AFilename;
  Files[0].FCodePage := ACodePage
end;

procedure TPAccount.TFiles.Clear();
begin
  while (Count > 0) do
  begin
    Files[0].Free();
    Delete(0);
  end;

  inherited;
end;

constructor TPAccount.TFiles.Create(const ADesktop: TDesktop; const AMaxCount: Integer);
begin
  inherited Create();

  FDesktop := ADesktop;

  FMaxCount := AMaxCount;
end;

function TPAccount.TFiles.GetFile(Index: Integer): TPAccount.TFile;
begin
  Result := TPAccount.TFile(Items[Index]);
end;

procedure TPAccount.TFiles.LoadFromXML(const XML: IXMLNode);
var
  I: Integer;
begin
  Clear();

  for I := 0 to XML.ChildNodes.Count - 1 do
    if ((XML.ChildNodes[I].NodeName = 'file')
      and FileExists(XML.ChildNodes[I].Text)) then
    begin
      inherited Add(TPAccount.TFile.Create(Self));
      Files[Count - 1].LoadFromXML(XML.ChildNodes[I]);
    end;
end;

procedure TPAccount.TFiles.SaveToXML(const XML: IXMLNode);
var
  I: Integer;
  Node: IXMLNode;
begin
  while (XML.ChildNodes.Count > 0) do
    XML.ChildNodes.Delete(0);

  for I := 0 to Count - 1 do
  begin
    Node := XML.AddChild('file');
    Files[I].SaveToXML(Node);
  end;
end;

{ TPAccount.TDesktop **********************************************************}

procedure TPAccount.TDesktop.Assign(const Source: TDesktop);
var
  I: Integer;
  Kind: TListViewKind;
begin
  Address := Account.ExpandAddress(Source.Account.ExtractPath(Source.Address));
  BlobHeight := Source.BlobHeight;
  for Kind := Low(Kind) to High(Kind) do
    for I := 0 to Length(ColumnWidths[Kind]) - 1 do
      ColumnWidths[Kind, I] := Source.ColumnWidths[Kind, I];
  DataHeight := Source.DataHeight;
  EditorContent := Source.EditorContent;
  ExplorerVisible := Source.ExplorerVisible;
  FilesFilter := Source.FilesFilter;
  FoldersHeight := Source.FoldersHeight;
  LogHeight := Source.LogHeight;
  LogVisible := Source.LogVisible;
  NavigatorVisible := Source.NavigatorVisible;
  QuickAccessMFUVisible := Source.QuickAccessMFUVisible;
  QuickAccessMRUVisible := Source.QuickAccessMRUVisible;
  SidebarWitdth := Source.SidebarWitdth;
  SQLHistoryVisible := Source.SQLHistoryVisible;
end;

constructor TPAccount.TDesktop.Create(const AAccount: TPAccount);
var
  I: Integer;
  Kind: TListViewKind;
begin
  inherited Create();

  FAccount := AAccount;

  BlobHeight := Round(100 * Screen.PixelsPerInch / USER_DEFAULT_SCREEN_DPI);
  for Kind := Low(Kind) to High(Kind) do
    for I := 0 to Length(ColumnWidths[Kind]) - 1 do
      ColumnWidths[Kind][I] := ColumnTextWidth;
  DataHeight := Round(150 * Screen.PixelsPerInch / USER_DEFAULT_SCREEN_DPI);
  EditorContent[ttEditor] := '';
  EditorContent[ttEditor2] := '';
  EditorContent[ttEditor3] := '';
  ExplorerVisible := False;
  FilesFilter := '*.sql';
  FoldersHeight := Round(100 * Screen.PixelsPerInch / USER_DEFAULT_SCREEN_DPI);
  NavigatorVisible := True;
  LogHeight := Round(80 * Screen.PixelsPerInch / USER_DEFAULT_SCREEN_DPI);
  LogVisible := False;
  FPath := '/';
  QuickAccessMFUVisible := True;
  QuickAccessMRUVisible := True;
  SidebarWitdth := Round(150 * Screen.PixelsPerInch / USER_DEFAULT_SCREEN_DPI);
  SQLHistoryVisible := False;

  FAddresses := TAddresses.Create(200);
  FFiles := TFiles.Create(Self, 10);
end;

destructor TPAccount.TDesktop.Destroy();
begin
  FAddresses.Free();
  FFiles.Free();

  inherited;
end;

function TPAccount.TDesktop.GetAddress(): string;
begin
  Result := Account.ExpandAddress(FPath);
end;

procedure TPAccount.TDesktop.LoadFromXML(const XML: IXMLNode);
var
  PixelsPerInch: Integer;
begin
  inherited;

  if (not TryStrToInt(XML.OwnerDocument.DocumentElement.Attributes['pixelsperinch'], PixelsPerInch)) then PixelsPerInch := Screen.PixelsPerInch;

  if (Assigned(XMLNode(XML, 'datagrid/height')) and TryStrToInt(XMLNode(XML, 'datagrid/height').Text, DataHeight)) then DataHeight := Round(DataHeight * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'datagrid/blob/height')) and TryStrToInt(XMLNode(XML, 'datagrid/blob/height').Text, BlobHeight)) then BlobHeight := Round(BlobHeight * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'editor/content'))) then EditorContent[ttEditor] := XMLNode(XML, 'editor/content').Text;
  if (Assigned(XMLNode(XML, 'editor2/content'))) then EditorContent[ttEditor2] := XMLNode(XML, 'editor2/content').Text;
  if (Assigned(XMLNode(XML, 'editor3/content'))) then EditorContent[ttEditor3] := XMLNode(XML, 'editor3/content').Text;
  if (Assigned(XMLNode(XML, 'log/height')) and TryStrToInt(XMLNode(XML, 'log/height').Text, LogHeight)) then LogHeight := Round(LogHeight * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'log/visible'))) then TryStrToBool(XMLNode(XML, 'log/visible').Text, LogVisible);
  if (Assigned(XMLNode(XML, 'objects/server/widths/name')) and TryStrToInt(XMLNode(XML, 'objects/server/widths/name').Text, ColumnWidths[lkServer][0])) then ColumnWidths[lkServer][0] := Round(ColumnWidths[lkServer][0] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/server/widths/size')) and TryStrToInt(XMLNode(XML, 'objects/server/widths/size').Text, ColumnWidths[lkServer][1])) then ColumnWidths[lkServer][1] := Round(ColumnWidths[lkServer][1] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/server/widths/count')) and TryStrToInt(XMLNode(XML, 'objects/server/widths/count').Text, ColumnWidths[lkServer][2])) then ColumnWidths[lkServer][2] := Round(ColumnWidths[lkServer][2] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/server/widths/created')) and TryStrToInt(XMLNode(XML, 'objects/server/widths/created').Text, ColumnWidths[lkServer][3])) then ColumnWidths[lkServer][3] := Round(ColumnWidths[lkServer][3] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/server/widths/extras')) and TryStrToInt(XMLNode(XML, 'objects/server/widths/extras').Text, ColumnWidths[lkServer][4])) then ColumnWidths[lkServer][4] := Round(ColumnWidths[lkServer][4] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/database/widths/name')) and TryStrToInt(XMLNode(XML, 'objects/database/widths/name').Text, ColumnWidths[lkDatabase][0])) then ColumnWidths[lkDatabase][0] := Round(ColumnWidths[lkDatabase][0] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/database/widths/type')) and TryStrToInt(XMLNode(XML, 'objects/database/widths/type').Text, ColumnWidths[lkDatabase][1])) then ColumnWidths[lkDatabase][1] := Round(ColumnWidths[lkDatabase][1] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/database/widths/recordcount')) and TryStrToInt(XMLNode(XML, 'objects/database/widths/recordcount').Text, ColumnWidths[lkDatabase][2])) then ColumnWidths[lkDatabase][2] := Round(ColumnWidths[lkDatabase][2] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/database/widths/size')) and TryStrToInt(XMLNode(XML, 'objects/database/widths/size').Text, ColumnWidths[lkDatabase][3])) then ColumnWidths[lkDatabase][3] := Round(ColumnWidths[lkDatabase][3] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/database/widths/updated')) and TryStrToInt(XMLNode(XML, 'objects/database/widths/updated').Text, ColumnWidths[lkDatabase][4])) then ColumnWidths[lkDatabase][4] := Round(ColumnWidths[lkDatabase][4] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/database/widths/extras')) and TryStrToInt(XMLNode(XML, 'objects/database/widths/extras').Text, ColumnWidths[lkDatabase][5])) then ColumnWidths[lkDatabase][5] := Round(ColumnWidths[lkDatabase][5] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/database/widths/comment')) and TryStrToInt(XMLNode(XML, 'objects/database/widths/comment').Text, ColumnWidths[lkDatabase][6])) then ColumnWidths[lkDatabase][6] := Round(ColumnWidths[lkDatabase][6] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/table/widths/name')) and TryStrToInt(XMLNode(XML, 'objects/table/widths/name').Text, ColumnWidths[lkTable][0])) then ColumnWidths[lkTable][0] := Round(ColumnWidths[lkTable][0] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/table/widths/type')) and TryStrToInt(XMLNode(XML, 'objects/table/widths/type').Text, ColumnWidths[lkTable][1])) then ColumnWidths[lkTable][1] := Round(ColumnWidths[lkTable][1] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/table/widths/null')) and TryStrToInt(XMLNode(XML, 'objects/table/widths/null').Text, ColumnWidths[lkTable][2])) then ColumnWidths[lkTable][2] := Round(ColumnWidths[lkTable][2] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/table/widths/default')) and TryStrToInt(XMLNode(XML, 'objects/table/widths/default').Text, ColumnWidths[lkTable][3])) then ColumnWidths[lkTable][3] := Round(ColumnWidths[lkTable][3] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/table/widths/extras')) and TryStrToInt(XMLNode(XML, 'objects/table/widths/extras').Text, ColumnWidths[lkTable][4])) then ColumnWidths[lkTable][4] := Round(ColumnWidths[lkTable][4] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/table/widths/comment')) and TryStrToInt(XMLNode(XML, 'objects/table/widths/comment').Text, ColumnWidths[lkTable][5])) then ColumnWidths[lkTable][5] := Round(ColumnWidths[lkTable][5] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/processes/widths/id')) and TryStrToInt(XMLNode(XML, 'objects/processes/widths/id').Text, ColumnWidths[lkProcesses][0])) then ColumnWidths[lkProcesses][0] := Round(ColumnWidths[lkProcesses][0] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/processes/widths/user')) and TryStrToInt(XMLNode(XML, 'objects/processes/widths/user').Text, ColumnWidths[lkProcesses][1])) then ColumnWidths[lkProcesses][1] := Round(ColumnWidths[lkProcesses][1] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/processes/widths/host')) and TryStrToInt(XMLNode(XML, 'objects/processes/widths/host').Text, ColumnWidths[lkProcesses][2])) then ColumnWidths[lkProcesses][2] := Round(ColumnWidths[lkProcesses][2] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/processes/widths/database')) and TryStrToInt(XMLNode(XML, 'objects/processes/widths/database').Text, ColumnWidths[lkProcesses][3])) then ColumnWidths[lkProcesses][3] := Round(ColumnWidths[lkProcesses][3] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/processes/widths/command')) and TryStrToInt(XMLNode(XML, 'objects/processes/widths/command').Text, ColumnWidths[lkProcesses][4])) then ColumnWidths[lkProcesses][4] := Round(ColumnWidths[lkProcesses][4] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/processes/widths/statement')) and TryStrToInt(XMLNode(XML, 'objects/processes/widths/statement').Text, ColumnWidths[lkProcesses][5])) then ColumnWidths[lkProcesses][5] := Round(ColumnWidths[lkProcesses][5] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/processes/widths/time')) and TryStrToInt(XMLNode(XML, 'objects/processes/widths/time').Text, ColumnWidths[lkProcesses][6])) then ColumnWidths[lkProcesses][6] := Round(ColumnWidths[lkProcesses][6] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/processes/widths/state')) and TryStrToInt(XMLNode(XML, 'objects/processes/widths/state').Text, ColumnWidths[lkProcesses][7])) then ColumnWidths[lkProcesses][7] := Round(ColumnWidths[lkProcesses][7] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/users/widths/name')) and TryStrToInt(XMLNode(XML, 'objects/users/widths/name').Text, ColumnWidths[lkUsers][0])) then ColumnWidths[lkUsers][0] := Round(ColumnWidths[lkUsers][0] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/users/widths/fullname')) and TryStrToInt(XMLNode(XML, 'objects/users/widths/fullname').Text, ColumnWidths[lkUsers][1])) then ColumnWidths[lkUsers][1] := Round(ColumnWidths[lkUsers][1] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/users/widths/comment')) and TryStrToInt(XMLNode(XML, 'objects/users/widths/comment').Text, ColumnWidths[lkUsers][2])) then ColumnWidths[lkUsers][2] := Round(ColumnWidths[lkUsers][2] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/variables/widths/name')) and TryStrToInt(XMLNode(XML, 'objects/variables/widths/name').Text, ColumnWidths[lkVariables][0])) then ColumnWidths[lkVariables][0] := Round(ColumnWidths[lkVariables][0] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/variables/widths/value')) and TryStrToInt(XMLNode(XML, 'objects/variables/widths/value').Text, ColumnWidths[lkVariables][1])) then ColumnWidths[lkVariables][1] := Round(ColumnWidths[lkVariables][1] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/objectsearch/widths/name')) and TryStrToInt(XMLNode(XML, 'objects/objectsearch/widths/name').Text, ColumnWidths[lkObjectSearch][0])) then ColumnWidths[lkObjectSearch][0] := Round(ColumnWidths[lkObjectSearch][0] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/objectsearch/widths/type')) and TryStrToInt(XMLNode(XML, 'objects/objectsearch/widths/type').Text, ColumnWidths[lkObjectSearch][1])) then ColumnWidths[lkObjectSearch][1] := Round(ColumnWidths[lkObjectSearch][1] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/objectsearch/widths/location')) and TryStrToInt(XMLNode(XML, 'objects/objectsearch/widths/location').Text, ColumnWidths[lkObjectSearch][2])) then ColumnWidths[lkObjectSearch][2] := Round(ColumnWidths[lkObjectSearch][2] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/objectsearch/widths/date')) and TryStrToInt(XMLNode(XML, 'objects/objectsearch/widths/date').Text, ColumnWidths[lkObjectSearch][3])) then ColumnWidths[lkObjectSearch][3] := Round(ColumnWidths[lkObjectSearch][3] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/objectsearch/widths/comment')) and TryStrToInt(XMLNode(XML, 'objects/objectsearch/widths/comment').Text, ColumnWidths[lkObjectSearch][4])) then ColumnWidths[lkObjectSearch][4] := Round(ColumnWidths[lkObjectSearch][4] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/quickaccess/mfu'))) then TryStrToBool(XMLNode(XML, 'objects/quickaccess/mfu').Attributes['visible'], QuickAccessMFUVisible);
  if (Assigned(XMLNode(XML, 'objects/quickaccess/mru'))) then TryStrToBool(XMLNode(XML, 'objects/quickaccess/mru').Attributes['visible'], QuickAccessMRUVisible);
  if (Assigned(XMLNode(XML, 'objects/quickaccess/widths/name')) and TryStrToInt(XMLNode(XML, 'objects/quickaccess/widths/name').Text, ColumnWidths[lkQuickAccess][0])) then ColumnWidths[lkQuickAccess][0] := Round(ColumnWidths[lkQuickAccess][0] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/quickaccess/widths/type')) and TryStrToInt(XMLNode(XML, 'objects/quickaccess/widths/type').Text, ColumnWidths[lkQuickAccess][1])) then ColumnWidths[lkQuickAccess][1] := Round(ColumnWidths[lkQuickAccess][1] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/quickaccess/widths/location')) and TryStrToInt(XMLNode(XML, 'objects/quickaccess/widths/location').Text, ColumnWidths[lkQuickAccess][2])) then ColumnWidths[lkQuickAccess][2] := Round(ColumnWidths[lkQuickAccess][2] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/quickaccess/widths/date')) and TryStrToInt(XMLNode(XML, 'objects/quickaccess/widths/date').Text, ColumnWidths[lkQuickAccess][3])) then ColumnWidths[lkQuickAccess][3] := Round(ColumnWidths[lkQuickAccess][3] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'objects/quickaccess/widths/comment')) and TryStrToInt(XMLNode(XML, 'objects/quickaccess/widths/comment').Text, ColumnWidths[lkQuickAccess][4])) then ColumnWidths[lkQuickAccess][4] := Round(ColumnWidths[lkQuickAccess][4] * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'path'))) then FPath := XMLNode(XML, 'path').Text;
  if (Assigned(XMLNode(XML, 'sidebar/explorer/folders/height')) and TryStrToInt(XMLNode(XML, 'sidebar/explorer/folders/height').Text, FoldersHeight)) then FoldersHeight := Round(FoldersHeight * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'sidebar/explorer/files/filter'))) then FilesFilter := XMLNode(XML, 'sidebar/explorer/files/filter').Text;
  if (Assigned(XMLNode(XML, 'sidebar/width')) and TryStrToInt(XMLNode(XML, 'sidebar/width').Text, SidebarWitdth)) then SidebarWitdth := Round(SidebarWitdth * Screen.PixelsPerInch / PixelsPerInch);
  if (Assigned(XMLNode(XML, 'sidebar/visible'))) then
  begin
    NavigatorVisible := UpperCase(XMLNode(XML, 'sidebar/visible').Text) = 'NAVIGATOR';
    ExplorerVisible := not NavigatorVisible and (UpperCase(XMLNode(XML, 'sidebar/visible').Text) = 'EXPLORER');
    SQLHistoryVisible := not NavigatorVisible and not ExplorerVisible and (UpperCase(XMLNode(XML, 'sidebar/visible').Text) = 'SQL HISTORY');
  end;

  if (Assigned(XMLNode(XML, 'history'))) then Addresses.LoadFromXML(XMLNode(XML, 'history'), 'address');
  if (Assigned(XMLNode(XML, 'editor/files'))) then Files.LoadFromXML(XMLNode(XML, 'editor/files'));
end;

procedure TPAccount.TDesktop.SaveToXML(const XML: IXMLNode);
begin
  XML.OwnerDocument.Options := XML.OwnerDocument.Options + [doNodeAutoCreate];

  XML.OwnerDocument.DocumentElement.Attributes['pixelsperinch'] := IntToStr(Screen.PixelsPerInch);

  XMLNode(XML, 'datagrid/height').Text := IntToStr(DataHeight);
  XMLNode(XML, 'datagrid/blob/height').Text := IntToStr(BlobHeight);
  if (not ValidXMLText(EditorContent[ttEditor])) then
    XMLNode(XML, 'editor').ChildNodes.Remove(XMLNode(XML, 'editor/content'))
  else
    XMLNode(XML, 'editor/content').Text := EditorContent[ttEditor];
  if (not ValidXMLText(EditorContent[ttEditor2])) then
    XMLNode(XML, 'editor2').ChildNodes.Remove(XMLNode(XML, 'editor2/content'))
  else
    XMLNode(XML, 'editor2/content').Text := EditorContent[ttEditor2];
  if (not ValidXMLText(EditorContent[ttEditor3])) then
    XMLNode(XML, 'editor3').ChildNodes.Remove(XMLNode(XML, 'editor3/content'))
  else
    XMLNode(XML, 'editor3/content').Text := EditorContent[ttEditor3];
  XMLNode(XML, 'log/height').Text := IntToStr(LogHeight);
  XMLNode(XML, 'log/visible').Text := BoolToStr(LogVisible, True);
  XMLNode(XML, 'objects/server/widths/name').Text := IntToStr(ColumnWidths[lkServer][0]);
  XMLNode(XML, 'objects/server/widths/count').Text := IntToStr(ColumnWidths[lkServer][1]);
  XMLNode(XML, 'objects/server/widths/size').Text := IntToStr(ColumnWidths[lkServer][2]);
  XMLNode(XML, 'objects/server/widths/created').Text := IntToStr(ColumnWidths[lkServer][3]);
  XMLNode(XML, 'objects/server/widths/extras').Text := IntToStr(ColumnWidths[lkServer][4]);
  XMLNode(XML, 'objects/database/widths/name').Text := IntToStr(ColumnWidths[lkDatabase][0]);
  XMLNode(XML, 'objects/database/widths/type').Text := IntToStr(ColumnWidths[lkDatabase][1]);
  XMLNode(XML, 'objects/database/widths/recordcount').Text := IntToStr(ColumnWidths[lkDatabase][2]);
  XMLNode(XML, 'objects/database/widths/size').Text := IntToStr(ColumnWidths[lkDatabase][3]);
  XMLNode(XML, 'objects/database/widths/updated').Text := IntToStr(ColumnWidths[lkDatabase][4]);
  XMLNode(XML, 'objects/database/widths/extras').Text := IntToStr(ColumnWidths[lkDatabase][5]);
  XMLNode(XML, 'objects/database/widths/comment').Text := IntToStr(ColumnWidths[lkDatabase][6]);
  XMLNode(XML, 'objects/table/widths/name').Text := IntToStr(ColumnWidths[lkTable][0]);
  XMLNode(XML, 'objects/table/widths/type').Text := IntToStr(ColumnWidths[lkTable][1]);
  XMLNode(XML, 'objects/table/widths/null').Text := IntToStr(ColumnWidths[lkTable][2]);
  XMLNode(XML, 'objects/table/widths/default').Text := IntToStr(ColumnWidths[lkTable][3]);
  XMLNode(XML, 'objects/table/widths/extras').Text := IntToStr(ColumnWidths[lkTable][4]);
  XMLNode(XML, 'objects/table/widths/comment').Text := IntToStr(ColumnWidths[lkTable][5]);
  XMLNode(XML, 'objects/processes/widths/id').Text := IntToStr(ColumnWidths[lkProcesses][0]);
  XMLNode(XML, 'objects/processes/widths/user').Text := IntToStr(ColumnWidths[lkProcesses][1]);
  XMLNode(XML, 'objects/processes/widths/host').Text := IntToStr(ColumnWidths[lkProcesses][2]);
  XMLNode(XML, 'objects/processes/widths/database').Text := IntToStr(ColumnWidths[lkProcesses][3]);
  XMLNode(XML, 'objects/processes/widths/command').Text := IntToStr(ColumnWidths[lkProcesses][4]);
  XMLNode(XML, 'objects/processes/widths/statement').Text := IntToStr(ColumnWidths[lkProcesses][5]);
  XMLNode(XML, 'objects/processes/widths/time').Text := IntToStr(ColumnWidths[lkProcesses][6]);
  XMLNode(XML, 'objects/processes/widths/state').Text := IntToStr(ColumnWidths[lkProcesses][7]);
  XMLNode(XML, 'objects/users/widths/name').Text := IntToStr(ColumnWidths[lkUsers][0]);
  XMLNode(XML, 'objects/users/widths/fullname').Text := IntToStr(ColumnWidths[lkUsers][1]);
  XMLNode(XML, 'objects/users/widths/comment').Text := IntToStr(ColumnWidths[lkUsers][2]);
  XMLNode(XML, 'objects/variables/widths/name').Text := IntToStr(ColumnWidths[lkVariables][0]);
  XMLNode(XML, 'objects/variables/widths/value').Text := IntToStr(ColumnWidths[lkVariables][1]);
  XMLNode(XML, 'objects/objectsearch/widths/name').Text := IntToStr(ColumnWidths[lkObjectSearch][0]);
  XMLNode(XML, 'objects/objectsearch/widths/type').Text := IntToStr(ColumnWidths[lkObjectSearch][1]);
  XMLNode(XML, 'objects/objectsearch/widths/location').Text := IntToStr(ColumnWidths[lkObjectSearch][2]);
  XMLNode(XML, 'objects/objectsearch/widths/date').Text := IntToStr(ColumnWidths[lkObjectSearch][3]);
  XMLNode(XML, 'objects/objectsearch/widths/comment').Text := IntToStr(ColumnWidths[lkObjectSearch][4]);
  XMLNode(XML, 'objects/quickaccess/mfu').Attributes['visible'] := BoolToStr(QuickAccessMFUVisible, True);
  XMLNode(XML, 'objects/quickaccess/mru').Attributes['visible'] := BoolToStr(QuickAccessMRUVisible, True);
  XMLNode(XML, 'objects/quickaccess/widths/name').Text := IntToStr(ColumnWidths[lkQuickAccess][0]);
  XMLNode(XML, 'objects/quickaccess/widths/type').Text := IntToStr(ColumnWidths[lkQuickAccess][1]);
  XMLNode(XML, 'objects/quickaccess/widths/location').Text := IntToStr(ColumnWidths[lkQuickAccess][2]);
  XMLNode(XML, 'objects/quickaccess/widths/date').Text := IntToStr(ColumnWidths[lkQuickAccess][3]);
  XMLNode(XML, 'objects/quickaccess/widths/comment').Text := IntToStr(ColumnWidths[lkQuickAccess][4]);
  XMLNode(XML, 'path').Text := FPath;
  XMLNode(XML, 'sidebar/explorer/folders/height').Text := IntToStr(FoldersHeight);
  XMLNode(XML, 'sidebar/explorer/files/filter').Text := FilesFilter;
  XMLNode(XML, 'sidebar/width').Text := IntToStr(SidebarWitdth);
  if (NavigatorVisible) then
    XMLNode(XML, 'sidebar/visible').Text := 'Navigator'
  else if (ExplorerVisible) then
    XMLNode(XML, 'sidebar/visible').Text := 'Explorer'
  else if (SQLHistoryVisible) then
    XMLNode(XML, 'sidebar/visible').Text := 'SQL History'
  else
    XMLNode(XML, 'sidebar/visible').Text := BoolToStr(False, True);

  Addresses.SaveToXML(XMLNode(XML, 'history', True), 'address');
  Files.SaveToXML(XMLNode(XML, 'editor/files', True));

  XML.OwnerDocument.Options := XML.OwnerDocument.Options - [doNodeAutoCreate];
end;

procedure TPAccount.TDesktop.SetAddress(AAddress: string);
begin
  FPath := Account.ExtractPath(AAddress);
end;

{ TPAccount.TConnection *******************************************************}

procedure TPAccount.TConnection.Assign(const Source: TConnection);
begin
  Assert(Assigned(Source));

  Database := Source.Database;
  Host := Source.Host;
  HTTPTunnelURI := Source.HTTPTunnelURI;
  LibraryFilename := Source.LibraryFilename;
  LibraryType := Source.LibraryType;
  Password := Source.Password;
  Port := Source.Port;
  Username := Source.Username;
end;

constructor TPAccount.TConnection.Create();
begin
  inherited Create();

  Database := '';
  Host := '';
  HTTPTunnelURI := '';
  LibraryFilename := 'libMySQL.dll';
  LibraryType := ltBuiltIn;
  Password := '';
  Port := MYSQL_PORT;
  Username := '';
end;


function TPAccount.TConnection.GetCaption(): string;
begin
  if (Host = LOCAL_HOST_NAMEDPIPE) then
    Result := LOCAL_HOST
  else
    Result := Host;
  if (Port <> MYSQL_PORT) then
    Result := Result + ':' + IntToStr(Port);
end;

procedure TPAccount.TConnection.LoadFromXML(const XML: IXMLNode);
begin
  if (Assigned(XMLNode(XML, 'database'))) then Database := XMLNode(XML, 'database').Text;
  if (Assigned(XMLNode(XML, 'host'))) then Host := XMLNode(XML, 'host').Text;
  if (Assigned(XMLNode(XML, 'library/type'))) then
    if (UpperCase(XMLNode(XML, 'library/type').Text) = 'FILE') then LibraryType := ltDLL
    else if (UpperCase(XMLNode(XML, 'library/type').Text) = 'TUNNEL') then LibraryType := ltHTTP
    else if (UpperCase(XMLNode(XML, 'library/type').Text) = 'HTTPTUNNEL') then LibraryType := ltHTTP
    else LibraryType := ltBuiltIn;
  if (Assigned(XMLNode(XML, 'library/filename'))) then LibraryFilename := XMLNode(XML, 'library/filename').Text;
  if (Assigned(XMLNode(XML, 'library/tunnel_url'))) then HTTPTunnelURI := XMLNode(XML, 'library/tunnel_url').Text;
  if (Assigned(XMLNode(XML, 'password')) and (XMLNode(XML, 'password').Attributes['encode'] = 'none')) then Password := XMLNode(XML, 'password').Text;
  if (Assigned(XMLNode(XML, 'port'))) then TryStrToInt(XMLNode(XML, 'port').Text, Port);
  if (Assigned(XMLNode(XML, 'user'))) then Username := XMLNode(XML, 'user').Text;
end;

procedure TPAccount.TConnection.SaveToXML(const XML: IXMLNode);
begin
  XMLNode(XML, 'database').Text := Database;
  XMLNode(XML, 'host').Text := Host;
  case (LibraryType) of
    ltDLL: XMLNode(XML, 'library/type').Text := 'File';
    ltHTTP: XMLNode(XML, 'library/type').Text := 'HTTPTunnel';
    else XMLNode(XML, 'library').ChildNodes.Delete('type');
  end;
  XMLNode(XML, 'library/filename').Text := LibraryFilename;
  XMLNode(XML, 'library/tunnel_url').Text := HTTPTunnelURI;
  XMLNode(XML, 'password').Attributes['encode'] := 'none';
  XMLNode(XML, 'password').Text := Password;
  XMLNode(XML, 'port').Text := IntToStr(Port);
  XMLNode(XML, 'user').Text := Username;
end;

{ TPAccount *******************************************************************}

procedure TPAccount.Assign(const Source: TPAccount);
begin
  Assert(Assigned(Source));

  if (not Assigned(Accounts)) then FAccounts := Source.Accounts;

  FLastLogin := Source.LastLogin;
  ManualURL := Source.ManualURL;
  ManualURLVersion := Source.ManualURLVersion;
  Name := Source.Name;

  Modified := True;

  Connection.Assign(Source.Connection);
  if (Assigned(Desktop) and Assigned(Source.Desktop)) then
  try
    Desktop.Assign(Source.Desktop);
  except
    // Debug 2016-12-23
    on E: Exception do
      raise Exception.Create(E.Message + #13#10
        + 'Source.Desktop.FPath: ' + Source.Desktop.FPath + #13#10
        + 'Source.Desktop.Address: ' + Source.Desktop.Address);
  end;
end;

constructor TPAccount.Create(const AAccounts: TPAccounts; const AXML: IXMLNode = nil);
var
  Node: IXMLNode;
begin
  FAccounts := AAccounts;
  FXML := AXML;

  FHistoryXMLDocument := nil;
  FLastLogin := 0;
  FSessions := TList.Create();
  FTabs := TList.Create();
  ManualURL := '';
  ManualURLVersion := '';
  Modified := False;

  FConnection := TConnection.Create();
  FDesktop := TDesktop.Create(Self);
  FFavorites := TFavorites.Create(Self);

  if (not FileExists(DesktopFilename)) then
    DesktopXMLDocument := nil
  else
    try
      DesktopXMLDocument := LoadXMLDocument(DesktopFilename);
    except
      DesktopXMLDocument := nil;
    end;

  if (not Assigned(DesktopXMLDocument) or not Assigned(DesktopXMLDocument.DocumentElement)) then
  begin
    DesktopXMLDocument := NewXMLDocument();
    DesktopXMLDocument.Encoding := 'utf-8';
    DesktopXMLDocument.Node.AddChild('desktop').Attributes['version'] := '1.3.1';
  end;

  if (DesktopXMLDocument.DocumentElement.Attributes['version'] <> Null) then
  begin
    if (VersionStrToVersion(DesktopXMLDocument.DocumentElement.Attributes['version']) < 10300)  then
    begin
      Node := DesktopXMLDocument.DocumentElement;
      if (Assigned(Node) and Assigned(XMLNode(Node, 'address'))) then
        Node.ChildNodes.Remove(XMLNode(Node, 'address'));

      DesktopXMLDocument.DocumentElement.Attributes['version'] := '1.3';
    end;

    if (VersionStrToVersion(DesktopXMLDocument.DocumentElement.Attributes['version']) < 10301)  then
    begin
      Node := DesktopXMLDocument.DocumentElement;
      if (Assigned(XMLNode(Node, 'browser'))) then
        Node.ChildNodes.Remove(XMLNode(Node, 'browser'));
      Node := XMLNode(Node, 'editor');
      if (Assigned(XMLNode(Node, 'filename'))) then
        Node.ChildNodes.Remove(XMLNode(Node, 'filename'));

      DesktopXMLDocument.DocumentElement.Attributes['version'] := '1.3.1';
    end;

    if (VersionStrToVersion(DesktopXMLDocument.DocumentElement.Attributes['version']) < 10400)  then
    begin
      DesktopXMLDocument.DocumentElement.Attributes['pixelsperinch'] := IntToStr(Screen.PixelsPerInch);

      DesktopXMLDocument.DocumentElement.Attributes['version'] := '1.4.0';
    end;
  end;

  DesktopXMLDocument.Options := DesktopXMLDocument.Options - [doAttrNull, doNodeAutoCreate];
end;

destructor TPAccount.Destroy();
begin
  FTabs.Free();
  FSessions.Free();
  FFavorites.Free();
  FDesktop.Free();
  FConnection.Free();

  inherited;
end;

function TPAccount.ExtractPath(const AAddress: string): string;
var
  URI: TUURI;
begin
  URI := TUURI.Create(AAddress);
  Result := URI.Path + URI.ExtraInfos;
  URI.Free();
end;

function TPAccount.ExpandAddress(const APath: string): string;
var
  Len: DWORD;
  URL: array [0 .. INTERNET_MAX_URL_LENGTH] of Char;
  URLComponents: URL_COMPONENTS;
begin
  ZeroMemory(@URLComponents, SizeOf(URLComponents));
  URLComponents.dwStructSize := SizeOf(URLComponents);

  URLComponents.lpszScheme := PChar('mysql');
  if (Connection.Host = LOCAL_HOST_NAMEDPIPE) then
    URLComponents.lpszHostName := LOCAL_HOST
  else
    URLComponents.lpszHostName := PChar(Connection.Host);
  if (Connection.Port <> MYSQL_PORT) then
    URLComponents.nPort := Connection.Port;
  URLComponents.lpszUrlPath := PChar(APath);

  Len := Length(URL) - 1;
  if (not InternetCreateUrl(URLComponents, 0, @URL, Len)) then
    RaiseLastOSError()
  else
    SetString(Result, PChar(@URL), Len);
end;

function TPAccount.FirstTab(): Pointer;
begin
  if (FTabs.Count = 0) then
    Result := nil
  else
    Result := FTabs[0];
end;

function TPAccount.GetDataPath(): TFileName;
begin
  Result := Accounts.DataPath + ReplaceStr(Name, '/', '_') + PathDelim;
end;

function TPAccount.GetDefaultDatabase(): string;
var
  DatabaseNames: TCSVStrings;
  Found: Boolean;
  I: Integer;
  URI: TUURI;
begin
  Result := '';

  URI := TUURI.Create(Desktop.Address);

  if (ValidDatabaseName(URI.Database)) then
  begin
    Result := URI.Database;

    if (Connection.Database <> '') then
    begin
      SetLength(DatabaseNames, 0);
      CSVSplitValues(Connection.Database, ',', '"', DatabaseNames);

      Found := False;
      for I := 0 to Length(DatabaseNames) - 1 do
        if (lstrcmpi(PChar(DatabaseNames[I]), PChar(Result)) = 0) then
          Found := True;
      if (not Found) then
        Result := '';

      SetLength(DatabaseNames, 0);
    end;
  end;

  URI.Free();

  if (Result = '') then
  begin
    SetLength(DatabaseNames, 0);
    CSVSplitValues(Connection.Database, ',', '"', DatabaseNames);

    if (Length(DatabaseNames) = 0) then
      Result := ''
    else
      Result := DatabaseNames[0];

    SetLength(DatabaseNames, 0);
  end;
end;

function TPAccount.GetDesktopFilename(): TFileName;
begin
  if (not DirectoryExists(DataPath)) then
    Result := ''
  else
    Result := DataPath + 'Desktop.xml';
end;

function TPAccount.GetDesktopXML(): IXMLNode;
begin
  if (not Assigned(DesktopXMLDocument)) then
    Result := nil
  else
    Result := DesktopXMLDocument.DocumentElement;
end;

function TPAccount.GetHistoryFilename(): TFileName;
begin
  if (not DirectoryExists(DataPath)) then
    Result := ''
  else
    Result := DataPath + 'History.xml';
end;

function TPAccount.GetHistoryXML(): IXMLNode;
begin
  if (not Assigned(FHistoryXMLDocument)) then
  begin
    if (FileExists(HistoryFilename)) then
      try
        FHistoryXMLDocument := LoadXMLDocument(HistoryFilename);
      except
        // If there are errors inside the History.xml the user should not bothered with it...
        FHistoryXMLDocument := nil;
      end;

    if (not Assigned(FHistoryXMLDocument) or not Assigned(FHistoryXMLDocument.DocumentElement)) then
    begin
      FHistoryXMLDocument := NewXMLDocument();
      FHistoryXMLDocument.Encoding := 'utf-8';
      FHistoryXMLDocument.Node.AddChild('history').Attributes['version'] := '1.0';
    end;

    FHistoryXMLDocument.Options := FHistoryXMLDocument.Options - [doAttrNull, doNodeAutoCreate];
  end;

  Result := FHistoryXMLDocument.DocumentElement;
end;

function TPAccount.GetIndex(): Integer;
begin
  Result := Accounts.IndexOf(Self);
end;

function TPAccount.GetName(): string;
begin
  if ((FName = '') and Assigned(XML)) then
    FName := XML.Attributes['name'];

  Result := FName;
end;

function TPAccount.GetSessionCount(): Integer;
begin
  Result := FSessions.Count;
end;

function TPAccount.GetTabCount(): Integer;
begin
  Result := FTabs.Count;
end;

procedure TPAccount.Load();
begin
  if (Assigned(XML)) then
  begin
    if (Assigned(XMLNode(XML, 'lastlogin'))) then
      TryStrToFloat(ReplaceStr(XMLNode(XML, 'lastlogin').Text, '.', FormatSettings.DecimalSeparator), Double(FLastLogin));
    if (Assigned(XMLNode(XML, 'manualurl'))) then ManualURL := XMLNode(XML, 'manualurl').Text;
    if (Assigned(XMLNode(XML, 'manualurl'))) then ManualURLVersion := XMLNode(XML, 'manualurl').Attributes['version'];

    Modified := False;

    if (Assigned(XMLNode(XML, 'connection'))) then
      Connection.LoadFromXML(XMLNode(XML, 'connection'));
    if (Assigned(DesktopXMLDocument.DocumentElement)) then
      Desktop.LoadFromXML(DesktopXMLDocument.DocumentElement); // Desktop must be loaded to use ExpandAddress correctly
    if (Assigned(XMLNode(XML, 'favorites'))) then
      Favorites.LoadFromXML(XMLNode(XML, 'favorites'));
  end;
end;

procedure TPAccount.RegisterSession(const ASession: Pointer);
begin
  Assert(FSessions.IndexOf(ASession) < 0);

  FSessions.Add(ASession);
end;

procedure TPAccount.RegisterTab(const ATab: Pointer);
begin
  Assert(FTabs.IndexOf(ATab) < 0);

  FTabs.Add(ATab);
end;

procedure TPAccount.Save();
begin
  if (Assigned(XML)) then
  begin
    XML.Attributes['name'] := Name;

    XMLNode(XML, 'lastlogin').Text := FloatToStr(LastLogin);
    XMLNode(XML, 'manualurl').Text := ManualURL;
    XMLNode(XML, 'manualurl').Attributes['version'] := ManualURLVersion;

    Connection.SaveToXML(XMLNode(XML, 'connection', True));

    Desktop.SaveToXML(DesktopXMLDocument.DocumentElement);
    Favorites.SaveToXML(XMLNode(XML, 'favorites', True));

    if (ForceDirectories(DataPath)) then
    begin
      if (DesktopXMLDocument.Modified) then
        if (ForceDirectories(ExtractFilePath(DesktopFilename))) then
          try
            DesktopXMLDocument.SaveToFile(DesktopFilename);
          except
            // Do not inform user about problems while saving file
          end;
        if (Assigned(HistoryXMLDocument) and HistoryXMLDocument.Modified) then
          if (ForceDirectories(ExtractFilePath(HistoryFilename))) then
            HistoryXMLDocument.SaveToFile(HistoryFilename);
    end;

    Modified := False;
  end;
end;

procedure TPAccount.SetLastLogin(const ALastLogin: TDateTime);
begin
  FLastLogin := ALastLogin;

  Modified := True;
end;

procedure TPAccount.UnRegisterSession(const ASession: Pointer);
begin
  Assert(FSessions.IndexOf(ASession) >= 0);

  FSessions.Delete(FSessions.IndexOf(ASession));
end;

procedure TPAccount.UnRegisterTab(const ATab: Pointer);
begin
  Assert(FTabs.IndexOf(ATab) >= 0);

  FTabs.Delete(FTabs.IndexOf(ATab));
end;

function TPAccount.ValidDatabaseName(const ADatabaseName: string): Boolean;
var
  S: string;
  TempDatabaseName: string;
begin
  Result := False;
  S := Connection.Database;

  while (S <> '') do
    if (Pos(',', S) = 0) then
      begin
        if (S = ADatabaseName) then
          Result := True;
        S := '';
      end
    else
      begin
        TempDatabaseName := Copy(S, 1, Pos(',', S) - 1);
        Delete(S, 1, Pos(',', S));
        if (TempDatabaseName = ADatabaseName) then
          Result := True;
      end;
end;

{ TAAccounts ******************************************************************}

function TPAccounts.AccountByName(const AccountName: string): TPAccount;
var
  I: Integer;
begin
  Result := nil;

  for I:=0 to Count - 1 do
    if (Account[I].Name = AccountName) then
      Result := Account[I];
end;

function TPAccounts.AccountByURI(const AURI: string; const DefaultAccount: TPAccount = nil): TPAccount;
var
  Found: Integer;
  Host: string;
  I: Integer;
  Name: string;
  NewAccount: TPAccount;
  NewAccountName: string;
  URI: TUURI;
  URLComponents: TURLComponents;
begin
  Result := nil;

  URI := nil;
  if (LowerCase(Copy(AURI, 1, 8)) = 'mysql://') then
    try
      URI := TUURI.Create(AURI);
    except
      URI := nil;
    end;

  if (Assigned(URI)) then
  begin
    Found := 0;
    for I := 0 to Count - 1 do
    begin
      ZeroMemory(@URLComponents, SizeOf(URLComponents));
      URLComponents.dwStructSize := SizeOf(URLComponents);
      if ((Account[I].Connection.LibraryType <> ltHTTP) or (lstrcmpi(PChar(Account[I].Connection.Host), LOCAL_HOST) <> 0)) then
        Host := LowerCase(Account[I].Connection.Host)
      else if (InternetCrackUrl(PChar(Account[I].Connection.HTTPTunnelURI), Length(Account[I].Connection.HTTPTunnelURI), 0, URLComponents)) then
      begin
        Inc(URLComponents.dwHostNameLength);
        GetMem(URLComponents.lpszHostName, URLComponents.dwHostNameLength * SizeOf(URLComponents.lpszHostName[0]));
        InternetCrackUrl(PChar(Account[I].Connection.HTTPTunnelURI), Length(Account[I].Connection.HTTPTunnelURI), 0, URLComponents);
        SetString(Host, URLComponents.lpszHostName, URLComponents.dwHostNameLength);
        FreeMem(URLComponents.lpszHostName);
      end
      else
        Host := LOCAL_HOST;
      if ((lstrcmpi(PChar(Host), PChar(URI.Host)) = 0) and (URI.Port = Account[I].Connection.Port)
        and ((URI.Username = '') or (lstrcmpi(PChar(URI.Username), PChar(Account[I].Connection.Username)) = 0))) then
      begin
        Result := Account[I];
        Inc(Found);
        if ((Result = DefaultAccount) or (Result.TabCount > 0)) then
          break;
      end;
    end;

    if (Found = 0) then
    begin
      NewAccountName := URI.Host;
      if (URI.Username <> '') then
        NewAccountName := NewAccountName + ' (' + URI.Username + ')';
      Name := NewAccountName;
      I := 1;
      while (Assigned(AccountByName(Name))) do
      begin
        Inc(I);
        Name := NewAccountName + ' (' + IntToStr(I) + ')';
      end;

      NewAccount := TPAccount.Create(Self);
      NewAccount.Name := Name;
      NewAccount.Connection.Host := URI.Host;
      NewAccount.Connection.Port := URI.Port;
      NewAccount.Connection.Username := URI.Username;
      NewAccount.Connection.Password := URI.Password;
      NewAccount.Connection.Database := URI.Database;
      AddAccount(NewAccount);
      NewAccount.Free();

      Result := AccountByName(NewAccountName);

      Save();
    end;

    URI.Free();
  end;
end;

procedure TPAccounts.AddAccount(const NewAccount: TPAccount);
var
  XML: IXMLNode;
begin
  // Debug 2016-11-15
  if (NewAccount.Name = '') then
    raise ERangeError.Create(SRangeError)
  else if (Assigned(AccountByName(NewAccount.Name))) then
    raise ERangeError.Create(SRangeError);

  XML := Accounts.XMLDocument.DocumentElement.AddChild('account');
  XML.Attributes['name'] := NewAccount.Name;
  Add(TPAccount.Create(Self, XML));
  Account[Count - 1].Assign(NewAccount);
end;

procedure TPAccounts.Clear();
begin
  while (Count > 0) do
  begin
    Account[0].Free();
    Delete(0);
  end;

  inherited;
end;

constructor TPAccounts.Create(const ADBLogin: TDBLogin);
var
  Msg: string;
  StringList: TStringList;
begin
  inherited Create();

  FDBLogin := ADBLogin;

  DefaultAccountName := '';
  FXMLDocument := nil;

  Section := 'Accounts';

  // "Sessions" used up to version 5.1 // May 2012
  if (DirectoryExists(Preferences.UserPath + 'Sessions' + PathDelim)
    and not DirectoryExists(DataPath)
    and not CopyDir(PChar(Preferences.UserPath + 'Sessions' + PathDelim), PChar(DataPath))) then
  begin
    Msg := 'Cannot copy folder'  + #13#10
      + Preferences.UserPath + 'Sessions' + PathDelim + #13#10
      + 'to' + #13#10
      + DataPath + #13#10
      + '(Error #' + IntToStr(GetLastError()) + ': ' + SysErrorMessage(GetLastError()) + ')';
    MessageBox(0, PChar(Msg), 'ERROR', MB_OK + MB_ICONERROR);
  end;
  if (not FileExists(Filename)
    and FileExists(DataPath + 'Sessions.xml')
    and CopyFile(PChar(DataPath + 'Sessions.xml'), PChar(Filename), False)) then
    begin
      StringList := TStringList.Create();
      StringList.LoadFromFile(Filename);
      StringList.Text := ReplaceStr(StringList.Text, '<session', '<account');
      StringList.Text := ReplaceStr(StringList.Text, '</session', '</account');
      StringList.SaveToFile(Filename);
      StringList.Free();
    end;

  // File moved in Nov 2016
  if (not FileExists(Filename)
    and FileExists(Preferences.UserPath + 'Accounts\Accounts.xml')) then
    if (not MoveFile(PChar(Preferences.UserPath + 'Accounts\Accounts.xml'), PChar(Filename))) then
      RaiseLastOSError()
    else
    try
      CreateSymbolicLink(PChar(Preferences.UserPath + 'Accounts\Accounts.xml'), PChar(Filename), 0);
    except
    end;

  Open();
end;

function TPAccounts.DeleteAccount(const AAccount: TPAccount): Boolean;
var
  I: Integer;
  Index: Integer;
begin
  if (FileExists(AAccount.DesktopFilename)) then
    DeleteFile(PChar(AAccount.DesktopFilename));
  if (FileExists(AAccount.HistoryFilename)) then
    DeleteFile(PChar(AAccount.HistoryFilename));
  if (DirectoryExists(AAccount.DataPath)) then
    RemoveDirectory(PChar(AAccount.DataPath));

  for I := XMLDocument.DocumentElement.ChildNodes.Count - 1 downto 0 do
    if ((XMLDocument.DocumentElement.ChildNodes[I].NodeName = 'account') and (lstrcmpi(PChar(string(XMLDocument.DocumentElement.ChildNodes[I].Attributes['name'])), PChar(AAccount.Name)) = 0)) then
      XMLDocument.DocumentElement.ChildNodes.Remove(XMLDocument.DocumentElement.ChildNodes[I]);

  Index := IndexOf(AAccount);

  Account[Index].Free();
  Delete(Index);

  Save();

  Result := True;
end;

destructor TPAccounts.Destroy();
begin
  Save();

  Clear();

  inherited;
end;

function TPAccounts.GetDataPath(): TFileName;
begin
  Result := Preferences.UserPath + 'Accounts' + PathDelim;
end;

function TPAccounts.GetDefault(): TPAccount;
begin
  Result := AccountByName(DefaultAccountName);
end;

function TPAccounts.GetFilename(): TFileName;
begin
  Result := Preferences.UserPath + 'Accounts.xml';
end;

function TPAccounts.GetFAccounts(Index: Integer): TPAccount;
begin
  Result := TPAccount(Items[Index]);
end;

function TPAccounts.GetXMLDocument(): IXMLDocument;
begin
  if (not Assigned(FXMLDocument)) then
  begin
    if (FileExists(Filename)) then
      try
        FXMLDocument := LoadXMLDocument(Filename);
      except
        FXMLDocument := nil;
      end;

    if (not Assigned(FXMLDocument)) then
    begin
      FXMLDocument := NewXMLDocument();
      FXMLDocument.Encoding := 'utf-8';
      FXMLDocument.Node.AddChild('accounts').Attributes['version'] := '1.1.0';
    end;

    FXMLDocument.Options := FXMLDocument.Options - [doAttrNull, doNodeAutoCreate];
  end;

  Result := FXMLDocument;
end;

procedure TPAccounts.Open();
var
  I: Integer;
  Index: Integer;
  J: Integer;
begin
  Clear();

  XMLDocument.Options := XMLDocument.Options - [doNodeAutoCreate];

  for I := 0 to XMLDocument.DocumentElement.ChildNodes.Count - 1 do
  begin
    if ((XMLDocument.DocumentElement.ChildNodes[I].NodeName = 'account') and (XMLDocument.DocumentElement.ChildNodes[I].Attributes['name'] <> '')) then
    begin
      Index := TList(Self).Count;
      for J := TList(Self).Count - 1 downto 0 do
        if (lstrcmpi(PChar(string(XMLDocument.DocumentElement.ChildNodes[I].Attributes['name'])), PChar(Account[J].Name)) <= 0) then
          Index := J;

      Insert(Index, TPAccount.Create(Self, XMLDocument.DocumentElement.ChildNodes[I]));
      Account[Index].Load();
    end;
  end;

  if (Assigned(XMLNode(XMLDocument.DocumentElement, 'default'))) then
    DefaultAccountName := XMLNode(XMLDocument.DocumentElement, 'default').Text;

  XMLDocument.Options := XMLDocument.Options + [doNodeAutoCreate];
end;

procedure TPAccounts.Save();
var
  I: Integer;
begin
  XMLDocument.Options := XMLDocument.Options + [doNodeAutoCreate];

  for I := 0 to Count - 1 do
    if (Account[I].Modified) then
      Account[I].Save();

  XMLNode(XMLDocument.DocumentElement, 'default').Text := DefaultAccountName;

  XMLDocument.Options := XMLDocument.Options - [doNodeAutoCreate];


  try
    if (XMLDocument.Modified) then
      if (ForceDirectories(ExtractFilePath(Filename))) then
        XMLDocument.SaveToFile(Filename);
  except
    on E: EOSError do
      MessageBox(Application.MainFormHandle, PChar(E.Message), 'Error', MB_OK or MB_ICONERROR);
  end;
end;

procedure TPAccounts.SetDefault(const AAccount: TPAccount);
begin
  if (not Assigned(AAccount)) then
    DefaultAccountName := ''
  else
    DefaultAccountName := AAccount.Name;
end;

procedure TPAccounts.UpdateAccount(const Account, NewAccount: TPAccount);
begin
  if (Assigned(Account) and Assigned(NewAccount) and (not Assigned(AccountByName(NewAccount.Name)) or (NewAccount.Name = Account.Name))) then
  begin
    if (NewAccount.Name <> Account.Name) then
      if (DirectoryExists(Account.DataPath)) then
        RenameFile(Account.DataPath, NewAccount.DataPath);

    Account.Assign(NewAccount);

    Save();
  end;
end;

{******************************************************************************}

initialization
  Preferences := nil;

  FileFormatSettings := TFormatSettings.Create(LOCALE_SYSTEM_DEFAULT);
  FileFormatSettings.ThousandSeparator := ',';
  FileFormatSettings.DecimalSeparator := '.';
  FileFormatSettings.DateSeparator := '/';
  FileFormatSettings.TimeSeparator := ':';
  FileFormatSettings.ListSeparator := ',';
  FileFormatSettings.ShortDateFormat := 'dd/mm/yy';
  FileFormatSettings.LongDateFormat := 'dd/mm/yyyy';
  FileFormatSettings.TimeAMString := '';
  FileFormatSettings.TimePMString := '';
  FileFormatSettings.ShortTimeFormat := 'hh:mm';
  FileFormatSettings.LongTimeFormat := 'hh:mm:ss';

  CoInitialize(nil);
finalization
  CoUninitialize();
end.


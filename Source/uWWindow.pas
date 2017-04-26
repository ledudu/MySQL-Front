unit uWWindow;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes, Types, Actions,
  Graphics, Controls, Forms, Dialogs, ActnList, ComCtrls, DBActns, ExtCtrls,
  ImgList, Menus, StdActns, ActnCtrls, StdCtrls, ToolWin,
  ExtCtrls_Ext, Forms_Ext, StdCtrls_Ext, ComCtrls_Ext, Dialogs_Ext, StdActns_Ext,
  MySQLDB,
  uSession, uPreferences, uDeveloper,
  uFSession, uBase;

const
  cWindowClassName = 'MySQL-Front.Application';

const
  UM_ACTIVATEFRAME = WM_USER + 601;
  UM_MYSQLCLIENT_SYNCHRONIZE = WM_USER + 602;

type
  TWWindow = class (TForm_Ext)
    ActionList: TActionList;
    aDCancel: TAction;
    aDCancelRecord: TDataSetCancel;
    aDCreateDatabase: TAction;
    aDCreateEvent: TAction;
    aDCreateField: TAction;
    aDCreateForeignKey: TAction;
    aDCreateFunction: TAction;
    aDCreateFunction1: TMenuItem;
    aDCreateKey: TAction;
    aDCreateProcedure: TAction;
    aDCreateTable: TAction;
    aDCreateTrigger: TAction;
    aDCreateUser: TAction;
    aDCreateView: TAction;
    aDDeleteDatabase: TAction;
    aDDeleteEvent: TAction;
    aDDeleteField: TAction;
    aDDeleteForeignKey: TAction;
    aDDeleteKey: TAction;
    aDDeleteProcess: TAction;
    aDDeleteRecord: TAction;
    aDDeleteRoutine: TAction;
    aDDeleteTable: TAction;
    aDDeleteTrigger: TAction;
    aDDeleteUser: TAction;
    aDDeleteView: TAction;
    aDEditDatabase: TAction;
    aDEditEvent: TAction;
    aDEditField: TAction;
    aDEditForeignKey: TAction;
    aDEditKey: TAction;
    aDEditProcess: TAction;
    aDEditRecord: TAction;
    aDEditRoutine: TAction;
    aDEditServer: TAction;
    aDEditTable: TAction;
    aDEditTrigger: TAction;
    aDEditUser: TAction;
    aDEditVariable: TAction;
    aDEditView: TAction;
    aDEmpty: TAction;
    aDInsertRecord: TAction;
    aDPostObject: TAction;
    aDPostRecord: TDataSetPost;
    aDRun: TAction;
    aDRunSelection: TAction;
    aECopy: TEditCopy;
    aECopyToFile: TAction;
    aECut: TEditCut;
    aEDelete: TEditDelete;
    aEFind: TAction;
    aEFormatSQL: TAction;
    aEPaste: TEditPaste;
    aEPasteFrom1: TMenuItem;
    aEPasteFromFile: TAction;
    aERedo: TAction;
    aERename: TAction;
    aEReplace: TAction;
    aESelectAll: TEditSelectAll;
    aETransfer: TAction;
    aEUndo: TEditUndo;
    aFClose: TAction;
    aFCloseAll: TAction;
    aFExit: TAction;
    aFExportAccess: TAction;
    aFExportBitmap: TAction;
    aFExportExcel: TAction;
    aFExportHTML: TAction;
    aFExportODBC: TAction;
    aFExportPDF: TAction;
    aFExportSQL: TAction;
    aFExportText: TAction;
    aFExportXML: TAction;
    aFImportAccess: TAction;
    aFImportExcel: TAction;
    aFImportODBC: TAction;
    aFImportSQL: TAction;
    aFImportText: TAction;
    aFOpen: TAction;
    aFOpenAccount: TAction;
    aFSave: TAction;
    aFSaveAs: TAction;
    aHIndex: TAction;
    aHInfo: TAction;
    aHManual: TAction;
    aHSQL: TAction;
    aHUpdate: TAction;
    aOAccounts: TAction;
    aOGlobals: TAction;
    aOExport: TAction;
    aOImport: TAction;
    aSSearchFind: TSearchFind_Ext;
    aSSearchNext: TSearchFindNext;
    aSSearchReplace: TSearchReplace_Ext;
    aVBrowser: TAction;
    aVBuilder: TAction;
    aVDiagram: TAction;
    aVExplorer: TAction;
    aVNavigator: TAction;
    aVObjects: TAction;
    aVIDE: TAction;
    aVRefresh: TAction;
    aVRefreshAll: TAction;
    aVSQLEditor: TAction;
    aVSQLEditor2: TAction;
    aVSQLEditor3: TAction;
    aVSQLHistory: TAction;
    aVSQLLog: TAction;
    CToolBar: TCoolBar;
    MainMenu: TMainMenu;
    miDatabase: TMenuItem;
    miDCancelRecord: TMenuItem;
    miDCreate: TMenuItem;
    miDCreateDatabase: TMenuItem;
    miDCreateEvent: TMenuItem;
    miDCreateField: TMenuItem;
    miDCreateForeignKey: TMenuItem;
    miDCreateIndex: TMenuItem;
    miDCreateRoutine: TMenuItem;
    miDCreateTable: TMenuItem;
    miDCreateTrigger: TMenuItem;
    miDCreateUser: TMenuItem;
    miDCreateView: TMenuItem;
    miDDelete: TMenuItem;
    miDDeleteDatabase: TMenuItem;
    miDDeleteEvent: TMenuItem;
    miDDeleteField: TMenuItem;
    miDDeleteForeignKey: TMenuItem;
    miDDeleteIndex: TMenuItem;
    miDDeleteProcess: TMenuItem;
    miDDeleteRecord: TMenuItem;
    miDDeleteRoutine: TMenuItem;
    miDDeleteTable: TMenuItem;
    miDDeleteTrigger: TMenuItem;
    miDDeleteUser: TMenuItem;
    miDDeleteView: TMenuItem;
    miDEditDatabase: TMenuItem;
    miDEditEvent: TMenuItem;
    miDEditField: TMenuItem;
    miDEditForeignKey: TMenuItem;
    miDEditIndex: TMenuItem;
    miDEditProcess: TMenuItem;
    miDEditRecord: TMenuItem;
    miDEditRoutine: TMenuItem;
    miDEditServer: TMenuItem;
    miDEditTable: TMenuItem;
    miDEditTrigger: TMenuItem;
    miDEditUser: TMenuItem;
    miDEditVariable: TMenuItem;
    miDEditView: TMenuItem;
    miDEmpty: TMenuItem;
    miDInsertRecord: TMenuItem;
    miDPostObject: TMenuItem;
    miDPostRecord: TMenuItem;
    miDProperties: TMenuItem;
    miDRun: TMenuItem;
    miDRunSelection: TMenuItem;
    miECopy: TMenuItem;
    miECopyToFile: TMenuItem;
    miECut: TMenuItem;
    miEDelete: TMenuItem;
    miEdit: TMenuItem;
    miEFind: TMenuItem;
    miEFormatSQL: TMenuItem;
    miEPaste: TMenuItem;
    miERedo: TMenuItem;
    miERename: TMenuItem;
    miEReplace: TMenuItem;
    miESelectAll: TMenuItem;
    miETransfer: TMenuItem;
    miEUndo: TMenuItem;
    miExtras: TMenuItem;
    miFClose: TMenuItem;
    miFConnect: TMenuItem;
    miFExit: TMenuItem;
    miFExport: TMenuItem;
    miFExportAccess: TMenuItem;
    miFExportBitmap: TMenuItem;
    miFExportExcel: TMenuItem;
    miFExportHTML: TMenuItem;
    miFExportODBC: TMenuItem;
    miFExportPDF: TMenuItem;
    miFExportSQL: TMenuItem;
    miFExportText: TMenuItem;
    miFExportXML: TMenuItem;
    miFile: TMenuItem;
    miFImport: TMenuItem;
    miFImportAccess: TMenuItem;
    miFImportExcel: TMenuItem;
    miFImportODBC: TMenuItem;
    miFImportSQL: TMenuItem;
    miFImportText: TMenuItem;
    miFOpen: TMenuItem;
    miFReopen: TMenuItem;
    miFSave: TMenuItem;
    miFSaveAs: TMenuItem;
    miHelp: TMenuItem;
    miHIndex: TMenuItem;
    miHInfo: TMenuItem;
    miHManual: TMenuItem;
    miHSQL: TMenuItem;
    miHUpdate: TMenuItem;
    miOAccounts: TMenuItem;
    miOGlobals: TMenuItem;
    miOptions: TMenuItem;
    miOExport: TMenuItem;
    miOImport: TMenuItem;
    miSearch: TMenuItem;
    miSSearchFind: TMenuItem;
    miSSearchNext: TMenuItem;
    miSSearchReplace: TMenuItem;
    miVBrowser: TMenuItem;
    miVBuilder: TMenuItem;
    miVDiagram: TMenuItem;
    miVExplorer: TMenuItem;
    miVIDE: TMenuItem;
    miView: TMenuItem;
    miVNavigator: TMenuItem;
    miVObjects: TMenuItem;
    miVRefresh: TMenuItem;
    miVRefreshAll: TMenuItem;
    miVSidebar: TMenuItem;
    miVSQLEditor: TMenuItem;
    miVSQLHistory: TMenuItem;
    miVSQLLog: TMenuItem;
    MTabControl: TPopupMenu;
    mtFClose: TMenuItem;
    mtFOpenAccount: TMenuItem;
    mtTabs: TMenuItem;
    N10: TMenuItem;
    N12: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N2: TMenuItem;
    N21: TMenuItem;
    N22: TMenuItem;
    N25: TMenuItem;
    N27: TMenuItem;
    N30: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    OpenDialog: TOpenDialog_Ext;
    PWorkSpace: TPanel_Ext;
    SaveDialog: TSaveDialog_Ext;
    StatusBar: TStatusBar;
    TabControl: TTabControl;
    tbCancelRecord: TToolButton;
    tbCreateDatabase: TToolButton;
    tbCreateField: TToolButton;
    tbCreateForeignKey: TToolButton;
    tbCreateIndex: TToolButton;
    tbCreateTable: TToolButton;
    tbDBFirst: TToolButton;
    tbDBLast: TToolButton;
    tbDBNext: TToolButton;
    tbDBPrev: TToolButton;
    tbDCancel: TToolButton;
    tbDDeleteRecord: TToolButton;
    tbDeleteDatabase: TToolButton;
    tbDeleteField: TToolButton;
    tbDeleteForeignKey: TToolButton;
    tbDeleteIndex: TToolButton;
    tbDeleteTable: TToolButton;
    tbDInsertRecord: TToolButton;
    tbECopy: TToolButton;
    tbECut: TToolButton;
    tbEDelete: TToolButton;
    tbEPaste: TToolButton;
    tbFormatSQL: TToolButton;
    tbOpen: TToolButton;
    tbPostObject: TToolButton;
    tbPostRecord: TToolButton;
    tbProperties: TToolButton;
    tbRedo: TToolButton;
    tbRun: TToolButton;
    tbRunSelection: TToolButton;
    tbSave: TToolButton;
    tbSearchFind: TToolButton;
    tbSearchReplace: TToolButton;
    TBTabControl: TToolBar;
    tbUndo: TToolButton;
    tbVRefresh: TToolButton;
    tcOpenAccount: TToolButton;
    ToolBar: TToolBar;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton2: TToolButton;
    ToolButton23: TToolButton;
    ToolButton30: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton7: TToolButton;
    ToolButton1: TToolButton;
    aHSupport: TAction;
    miHSupport: TMenuItem;
    aHDowndate: TAction;
    miHDowndate: TMenuItem;
    procedure aDCreateParentExecute(Sender: TObject);
    procedure aEFindExecute(Sender: TObject);
    procedure aEReplaceExecute(Sender: TObject);
    procedure aETransferExecute(Sender: TObject);
    procedure aFCloseAllExecute(Sender: TObject);
    procedure aFCloseExecute(Sender: TObject);
    procedure aFExitExecute(Sender: TObject);
    procedure aFOpenAccountExecute(Sender: TObject);
    procedure aHDowndateExecute(Sender: TObject);
    procedure aHIndexExecute(Sender: TObject);
    procedure aHInfoExecute(Sender: TObject);
    procedure aHSupportExecute(Sender: TObject);
    procedure aHUpdateExecute(Sender: TObject);
    procedure aOGlobalsExecute(Sender: TObject);
    procedure aOAccountsExecute(Sender: TObject);
    procedure aOExportExecute(Sender: TObject);
    procedure aOImportExecute(Sender: TObject);
    procedure aSSearchFindNotFound(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    procedure TabControlChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure TabControlContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TabControlDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TabControlDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TabControlEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure TabControlGetImageIndex(Sender: TObject; TabIndex: Integer;
      var ImageIndex: Integer);
    procedure TabControlMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TabControlMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TabControlResize(Sender: TObject);
    procedure TabControlStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure tbPropertiesClick(Sender: TObject);
  const
    tiEmptyWorkingMem = 1;
    tiFormDeactivated = 2;
  type
    PTabControlRepaint = ^TTabControlRepaint;
    TTabControlRepaint = record
      Active: Boolean;
      Rect: TRect;
    end;
  private
    AddTabParam: string;
    CheckOnlineVersionThread: TCheckOnlineVersionThread;
    FSessions: TList;
    MouseDownPoint: TPoint;
    OnlineRecommendedUpdateFound: Boolean;
    ModalForm: TForm;
    QuitAfterShow: Boolean;
    TabControlDragMarkedTabIndex: Integer;
    TabControlDragStartTabIndex: Integer;
    TabControlRepaint: TList;
    UniqueTabNameCounter: Integer;
    UpdateStarted: Boolean;
    procedure ActivateTab(const Tab: TFSession);
    procedure ApplicationActivate(Sender: TObject);
    procedure ApplicationDeactivate(Sender: TObject);
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure ApplicationModalBegin(Sender: TObject);
    procedure ApplicationModalEnd(Sender: TObject);
    function CloseAll(): Boolean;
    procedure CloseTab(const Tab: TFSession);
    procedure CMSysFontChanged(var Message: TMessage); message CM_SYSFONTCHANGED;
    procedure DeactivateTab(const Tab: TFSession);
    procedure EmptyWorkingMem();
    function GetActiveTab(): TFSession;
    function GetNewTabIndex(Sender: TObject; X, Y: Integer): Integer;
    procedure HidePopupChildren();
    procedure InformOnlineUpdateFound();
    procedure miFReopenClick(Sender: TObject);
    procedure mtTabsClick(Sender: TObject);
    procedure MySQLConnectionSynchronize(const Data: Pointer); inline;
    procedure OnlineVersionChecked(Sender: TObject);
    procedure SetActiveTab(const FSession: TFSession);
    procedure SQLError(const Connection: TMySQLConnection; const ErrorCode: Integer; const ErrorMessage: string);
    procedure UMActivateFrame(var Message: TMessage); message UM_ACTIVATEFRAME;
    procedure UMAddTab(var Message: TMessage); message UM_ADDTAB;
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
    procedure UMCrashRescue(var Message: TMessage); message UM_CRASH_RESCUE;
    procedure UMMySQLClientSynchronize(var Message: TMessage); message UM_MYSQLCLIENT_SYNCHRONIZE;
    procedure UMOnlineUpdateFound(var Message: TMessage); message UM_ONLINE_UPDATE_FOUND;
    procedure UMTerminate(var Message: TMessage); message UM_TERMINATE;
    procedure UMUpdateToolbar(var Message: TMessage); message UM_UPDATETOOLBAR;
    procedure WMDrawItem(var Message: TWMDrawItem); message WM_DRAWITEM;
    procedure WMHelp(var Message: TWMHelp); message WM_HELP;
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    property ActiveTab: TFSession read GetActiveTab write SetActiveTab;
  protected
    {$IFNDEF EurekaLog}
    procedure ApplicationException(Sender: TObject; E: Exception);
    {$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    function DBLogin(const Account: Pointer): Boolean;
  end;

var
  WWindow: TWWindow;

implementation {***************************************************************}

{$R *.dfm}

uses
  ShellApi, ShlObj, CommCtrl, ShLwApi, WinINet,
  SysConst, StrUtils, IniFiles, Variants, Math, Zip, DateUtils,
  DBConsts,
  Themes,
  ODBCAPI,
  {$IFDEF EurekaLog}
  ESysInfo,
  {$ENDIF}
  acQBLocalizer,
  MySQLConsts, HTTPTunnel, SQLUtils,
  uTools, uURI,
  uDAccounts, uDAccount, uDOptions, uDLogin, uDStatement, uDTransfer, uDSearch,
  uDConnecting, uDInfo, uDUpdate, uDMail, uDDowndate;

{ TWWindow ********************************************************************}

procedure TWWindow.ActivateTab(const Tab: TFSession);
begin
  ActiveTab := Tab;

  Color := clBtnFace;

  if (ActiveTab.Visible) then
    ActiveTab.FrameActivate(Self);

  tbDBPrev.Action := ActiveTab.aDPrev;
  tbDBFirst.Action := ActiveTab.DataSetFirst;
  tbDBLast.Action := ActiveTab.DataSetLast;
  tbDBNext.Action := ActiveTab.aDNext;
  tbPostRecord.Action := ActiveTab.DataSetPost;
  tbCancelRecord.Action := ActiveTab.DataSetCancel;

  tbDBPrev.Hint := ActiveTab.aDPrev.Caption + ' (' + ShortCutToText(VK_PRIOR) + ')';
  tbDBFirst.Hint := ActiveTab.DataSetFirst.Caption + ' (' + ShortCutToText(scCtrl + VK_HOME) + ')';
  tbDBLast.Hint := ActiveTab.DataSetLast.Caption + ' (' + ShortCutToText(scCtrl + VK_END) + ')';
  tbDBNext.Hint := ActiveTab.aDNext.Caption + ' (' + ShortCutToText(VK_NEXT) + ')';

  aFClose.Enabled := True;

  Perform(UM_UPDATETOOLBAR, 0, LPARAM(Tab));
end;

procedure TWWindow.aDCreateParentExecute(Sender: TObject);
begin
  ; // Dummy, damit MenuItem enabled
end;

procedure TWWindow.aEFindExecute(Sender: TObject);
begin
  if (Assigned(ActiveTab) and (ActiveTab is TFSession)) then
    TFSession(ActiveTab).aEFindExecute(Sender)
  else
  begin
    DSearch.Session := nil;
    DSearch.SearchOnly := True;
    DSearch.Tab := nil;
    DSearch.Execute();
  end;
end;

procedure TWWindow.aEReplaceExecute(Sender: TObject);
begin
  if (Assigned(ActiveTab) and (ActiveTab is TFSession)) then
    TFSession(ActiveTab).aEReplaceExecute(Sender)
  else
  begin
    DSearch.Session := nil;
    DSearch.SearchOnly := False;
    DSearch.Tab := nil;
    DSearch.Execute();
  end;
end;

procedure TWWindow.aETransferExecute(Sender: TObject);
begin
  if (Assigned(ActiveTab) and (ActiveTab is TFSession)) then
    TFSession(ActiveTab).aETransferExecute(Sender)
  else
  begin
    DTransfer.SourceSession := nil;
    DTransfer.DestinationSession := nil;
    DTransfer.Execute();
  end;
end;

procedure TWWindow.aFCloseAllExecute(Sender: TObject);
begin
  CloseAll();
end;

procedure TWWindow.aFCloseExecute(Sender: TObject);
var
  CanClose: Boolean;
begin
  Assert(Assigned(ActiveTab));

  CanClose := True;
  ActiveTab.FrameCloseQuery(Sender, CanClose);
  if (CanClose) then
    CloseTab(ActiveTab);
end;

procedure TWWindow.aFExitExecute(Sender: TObject);
begin
  Close();
end;

procedure TWWindow.aFOpenAccountExecute(Sender: TObject);
begin
  Perform(UM_ADDTAB, 0, 0);
end;

procedure TWWindow.aHDowndateExecute(Sender: TObject);
begin
  if (DDowndate.Execute()) then
  begin
    Preferences.SetupProgram := Preferences.DowndateFilename;
    Preferences.SetupProgramExecute := FileExists(Preferences.SetupProgram);
    if (Preferences.SetupProgramExecute) then
    begin
      Preferences.UpdateRemoved := IntToStr(ProgramVersionMajor) + '.' + IntToStr(ProgramVersionMinor) + '.' + IntToStr(ProgramVersionPatch) + '.' + IntToStr(ProgramVersionBuild);
      Close();
    end;
  end;
end;

procedure TWWindow.aHIndexExecute(Sender: TObject);
var
  Control: TWinControl;
begin
  Control := ActiveControl;
  while (Assigned(Control) and (Control.HelpContext = 0)) do
    // Needed for TacQueryBuilder
    Control := Control.Parent;

  if (not Assigned(Control) or (Control.HelpContext < 0)) then
    Application.HelpCommand(HELP_FINDER, 0)
  else
    Application.HelpCommand(HELP_CONTEXT, Control.HelpContext);
end;

procedure TWWindow.aHInfoExecute(Sender: TObject);
begin
  DInfo.ShowModal();
end;

procedure TWWindow.aHSupportExecute(Sender: TObject);
var
  CheckOnlineVersionThread: TCheckOnlineVersionThread;
begin
  if (not UpdateAvailable and (DateOf(LastUpdateCheck) < Today())) then
  begin
    CheckOnlineVersionThread := TCheckOnlineVersionThread.Create();
    CheckOnlineVersionThread.Execute();
    CheckOnlineVersionThread.Free();
  end;

  if (UpdateAvailable) then
  begin
    MsgBox('An update of ' + LoadStr(1000) + ' is available. Please install that update first.', Preferences.LoadStr(45), MB_OK or MB_ICONERROR);
    InformOnlineUpdateFound();
    exit;
  end
  else if (DateOf(LastUpdateCheck) < Today()) then
    MsgBox('Can''t check, if you are using the latest update. Maybe an update of ' + LoadStr(1000) + ' is available...', Preferences.LoadStr(47), MB_OK + MB_ICONWARNING);

  DMail.Execute();
end;

procedure TWWindow.aHUpdateExecute(Sender: TObject);
begin
  if (CloseAll()) then
  begin
    Preferences.SetupProgramExecute := DUpdate.Execute();
    if (Preferences.SetupProgramExecute) then
      Close();
  end;
end;

procedure TWWindow.aOAccountsExecute(Sender: TObject);
begin
  DAccounts.Account := nil;
  DAccounts.Open := False;
  DAccounts.Execute();
end;

procedure TWWindow.aOGlobalsExecute(Sender: TObject);
var
  I: Integer;
begin
  if (DOptions.Execute()) then
  begin
    Preferences.Save();
    TabControl.Visible := Preferences.TabsVisible or not Preferences.TabsVisible and (FSessions.Count >= 2);
    TBTabControl.Visible := Preferences.TabsVisible;
    for I := 0 to Screen.FormCount - 1 do
      PostMessage(Screen.Forms[I].Handle, UM_CHANGEPREFERENCES, 0, 0);
  end;
end;

procedure TWWindow.aOExportExecute(Sender: TObject);
var
  ZipFile: TZipFile;
begin
  SaveDialog.Title := Preferences.LoadStr(200);
  SaveDialog.FileName := SysUtils.LoadStr(1000) + '_Settings.zip';
  SaveDialog.Filter := FilterDescription('zip') + ' (*.zip)|*.zip';
  SaveDialog.DefaultExt := '.zip';
  if (SaveDialog.Execute()) then
  begin
    Preferences.Save();
    Accounts.Save();

    ZipFile := TZipFile.Create();
    ZipFile.Open(SaveDialog.FileName, zmWrite);
    ZipFile.Add(Preferences.Filename);
    ZipFile.Add(Accounts.Filename);
    ZipFile.Close();
    ZipFile.Free();
  end;
end;

procedure TWWindow.aOImportExecute(Sender: TObject);
var
  I: Integer;
  ZipFile: TZipFile;
begin
  OpenDialog.Title := Preferences.LoadStr(371);
  OpenDialog.FileName := SysUtils.LoadStr(1000) + '_Settings.zip';
  OpenDialog.Filter := FilterDescription('zip') + ' (*.zip)|*.zip';
  OpenDialog.DefaultExt := '.zip';
  if (CloseAll() and OpenDialog.Execute()) then
  begin
    ZipFile := TZipFile.Create();
    try
      SetLastError(0);
      ZipFile.Open(OpenDialog.FileName, zmRead);
    except
      on E: EZipException do
        begin
          MsgBox(E.Message, Preferences.LoadStr(45), MB_OK + MB_ICONERROR);
          ZipFile.Free();
          ZipFile := nil;
        end;
      on E: EFOpenError do
        if (GetLastError() > 0) then
          MsgBox(SysErrorMessage(GetLastError()), Preferences.LoadStr(45), MB_OK + MB_ICONERROR)
        else
          raise;
    end;

    if (Assigned(ZipFile)) then
    begin
      try
        ZipFile.Extract(ExtractFileName(Preferences.Filename), Preferences.UserPath);
        ZipFile.Extract(ExtractFileName(Accounts.Filename), Preferences.UserPath);
      except
        on E: EZipException do
          MsgBox(E.Message, Preferences.LoadStr(45), MB_OK + MB_ICONERROR);
      end;
      ZipFile.Close();
      ZipFile.Free();

      Preferences.Open();
      Accounts.Open();

      TabControl.Visible := Preferences.TabsVisible or not Preferences.TabsVisible and (FSessions.Count >= 2);
      TBTabControl.Visible := Preferences.TabsVisible;
      for I := 0 to Screen.FormCount - 1 do
        PostMessage(Screen.Forms[I].Handle, UM_CHANGEPREFERENCES, 0, 0);
    end;
  end;
end;

procedure TWWindow.ApplicationActivate(Sender: TObject);
begin
  if (not (csDestroying in ComponentState)) then
    KillTimer(Handle, tiEmptyWorkingMem);
end;

procedure TWWindow.ApplicationDeactivate(Sender: TObject);
begin
  SetTimer(Handle, tiFormDeactivated, 100, nil);
  SetTimer(Handle, tiEmptyWorkingMem, 60000, nil);
end;

{$IFNDEF EurekaLog}
procedure TWWindow.ApplicationException(Sender: TObject; E: Exception);
begin
  if (E.Message <> SRecordChanged) then
  begin
    if (not UpdateAvailable and InternetGetConnectedState(nil, 0)) then
      if (Assigned(CheckOnlineVersionThread)) then
        CheckOnlineVersionThread.WaitFor()
      else
      begin
        CheckOnlineVersionThread := TCheckOnlineVersionThread.Create();
        CheckOnlineVersionThread.Execute();
        FreeAndNil(CheckOnlineVersionThread);
      end;

    MsgBox('Internal Program Error:' + #13#10 + E.Message, Preferences.LoadStr(45), MB_OK + MB_ICONERROR);

    if (UpdateAvailable) then
      InformOnlineUpdateFound();
    if (ObsoleteVersion < ProgramVersion) then
      ObsoleteVersion := ProgramVersion;
  end;
end;
{$ENDIF}

procedure TWWindow.ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
var
  NewTabIndex: Integer;
begin
  if ((Screen.ActiveForm = Self) and (WM_KEYFIRST <= Msg.Message) and (Msg.Message <= WM_KEYLAST)
    and ((TWMKey(Pointer(@Msg.message)^).CharCode = VK_TAB) or (TWMKey(Pointer(@Msg.message)^).CharCode = VK_PRIOR) or (TWMKey(Pointer(@Msg.message)^).CharCode = VK_NEXT) or (TWMKey(Pointer(@Msg.message)^).CharCode in [Ord('1') .. Ord('9')])) and (GetKeyState(VK_CONTROL) < 0)) then
  begin
    if (Msg.Message = WM_KEYDOWN) then
    begin
      if ((TWMKey(Pointer(@Msg.message)^).CharCode = VK_TAB) and (GetKeyState(VK_SHIFT) < 0) or (TWMKey(Pointer(@Msg.message)^).CharCode =  VK_PRIOR)) then
      begin
        NewTabIndex := TabControl.TabIndex - 1;
        if (NewTabIndex < 0) then
          NewTabIndex := FSessions.Count - 1;
        Handled := True;
      end
      else if ((TWMKey(Pointer(@Msg.message)^).CharCode = VK_TAB) and (GetKeyState(VK_SHIFT) >= 0) or (TWMKey(Pointer(@Msg.message)^).CharCode =  VK_NEXT)) then
      begin
        NewTabIndex := TabControl.TabIndex + 1;
        if (NewTabIndex >= FSessions.Count) then
          NewTabIndex := 0;
        Handled := True;
      end
      else if ((Ord('1') <= TWMKey(Pointer(@Msg.message)^).CharCode) and (TWMKey(Pointer(@Msg.message)^).CharCode < Ord('1') + FSessions.Count)) then
      begin
        NewTabIndex := TWMKey(Pointer(@Msg.message)^).CharCode - Ord('1');
        Handled := True;
      end
      else
        NewTabIndex := TabControl.TabIndex;

      if (NewTabIndex <> TabControl.TabIndex) then
      begin
        DeactivateTab(FSessions[NewTabIndex]);
        ActivateTab(FSessions[NewTabIndex]);
      end;
    end;
  end;
end;

procedure TWWindow.ApplicationModalBegin(Sender: TObject);
begin
  if (Assigned(Screen.ActiveForm) and Screen.ActiveForm.Active) then
  begin
    ModalForm := Screen.ActiveForm;

    if ((Screen.ActiveForm = Self) and Assigned(ActiveTab)) then
      ActiveTab.FrameDeactivate(Self);
  end;
end;

procedure TWWindow.ApplicationModalEnd(Sender: TObject);
begin
  if (Assigned(ModalForm)) then
  begin
    ModalForm := nil;

    if (OnlineRecommendedUpdateFound) then
    begin
      OnlineRecommendedUpdateFound := False;
      InformOnlineUpdateFound();
    end;

    if ((Screen.ActiveForm = Self) and Assigned(ActiveTab)) then
      PostMessage(Handle, UM_ACTIVATEFRAME, 0, LPARAM(ActiveTab));
  end;
end;

procedure TWWindow.aSSearchFindNotFound(Sender: TObject);
var
  FindText: string;
begin
  if (Sender is TSearchFind) then
    FindText := TSearchFind(Sender).Dialog.FindText
  else if (Sender is TSearchReplace) then
    FindText := TSearchReplace(Sender).Dialog.FindText
  else
    FindText := '';
  MsgBox(Preferences.LoadStr(533, FindText), Preferences.LoadStr(43), MB_OK + MB_ICONINFORMATION);
end;

function TWWindow.CloseAll(): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := FSessions.Count - 1 downto 0 do
    if (Result) then
    begin
      // Debug 2017-04-26
      Assert(Assigned(FSessions[I]));

      TFSession(FSessions[I]).FrameCloseQuery(Self, Result);
      if (Result) then
        CloseTab(TFSession(FSessions[I]));
    end;
end;

procedure TWWindow.CloseTab(const Tab: TFSession);
var
  Session: TSSession;
  NewTabIndex: Integer;
begin
  DeactivateTab(Tab);

  NewTabIndex := FSessions.IndexOf(Tab);

  if (0 <= NewTabIndex) and (NewTabIndex < TabControl.Tabs.Count) then
  begin
    TabControl.Tabs.Delete(NewTabIndex);
    FSessions.Delete(FSessions.IndexOf(Tab));
    if (TabControl.TabIndex < 0) then
      TabControl.TabIndex := FSessions.Count - 1;

    Dec(NewTabIndex, 1);
    if ((NewTabIndex < 0) and (FSessions.Count > 0)) then
      NewTabIndex := 0;
    if (NewTabIndex >= 0) then
      ActivateTab(FSessions[NewTabIndex]);

    Session := Tab.Session;

    Tab.Visible := False;
    Tab.Free();

    Session.Free();

    TBTabControl.Visible := Preferences.TabsVisible or not Preferences.TabsVisible and (FSessions.Count >= 2);
    TabControl.Visible := TBTabControl.Visible;
    TabControlResize(nil);

    aFCloseAll.Enabled := FSessions.Count > 0;
  end;

  Perform(UM_UPDATETOOLBAR, 0, 0);
end;

procedure TWWindow.CMSysFontChanged(var Message: TMessage);
begin
  if (StyleServices.Enabled or not CheckWin32Version(6)) then
    ToolBar.BorderWidth := 0
  else
    ToolBar.BorderWidth := GetSystemMetrics(SM_CXEDGE);

  if (Assigned(ToolBar.Images)) then
  begin
    // Recalculate height of Toolbar:
    CToolBar.AutoSize := False;
    ToolBar.AutoSize := False;
    ToolBar.ButtonHeight := 0;
    ToolBar.ButtonHeight := ToolBar.Images.Height + 2 * GetSystemMetrics(SM_CYFIXEDFRAME);
    ToolBar.ButtonWidth := ToolBar.Images.Width + 2 * GetSystemMetrics(SM_CXFIXEDFRAME) + 1;
    ToolBar.AutoSize := True;
    CToolBar.AutoSize := True;
  end;
end;

constructor TWWindow.Create(AOwner: TComponent);
var
  WindowPlacement: TWindowPlacement;
  Wnd: HWND;
begin
  Wnd := FindWindow(PChar(cWindowClassName), nil);

  inherited;

  ModalForm := nil;

  WindowPlacement.length := SizeOf(WindowPlacement);
  if ((Wnd > 0) and GetWindowPlacement(Wnd, @WindowPlacement)) then
  begin
    Inc(WindowPlacement.rcNormalPosition.Left, 2 * GetSystemMetrics(SM_CXBORDER) + GetSystemMetrics(SM_CYCAPTION));
    Inc(WindowPlacement.rcNormalPosition.Top, 2 * GetSystemMetrics(SM_CYBORDER) + GetSystemMetrics(SM_CYCAPTION));
    Inc(WindowPlacement.rcNormalPosition.Right, 2 * GetSystemMetrics(SM_CXBORDER) + GetSystemMetrics(SM_CYCAPTION));
    Inc(WindowPlacement.rcNormalPosition.Bottom, 2 * GetSystemMetrics(SM_CYBORDER) + GetSystemMetrics(SM_CYCAPTION));

    if (WindowPlacement.rcNormalPosition.Right > Screen.WorkAreaRect.Right) then
    begin
      Dec(WindowPlacement.rcNormalPosition.Right, WindowPlacement.rcNormalPosition.Left);
      WindowPlacement.rcNormalPosition.Left := 0;
      Dec(WindowPlacement.rcNormalPosition.Bottom, WindowPlacement.rcNormalPosition.Top);
      WindowPlacement.rcNormalPosition.Top := 0;
    end
    else if (WindowPlacement.rcNormalPosition.Bottom > Screen.WorkAreaRect.Bottom) then
    begin
      Dec(WindowPlacement.rcNormalPosition.Bottom, WindowPlacement.rcNormalPosition.Top);
      WindowPlacement.rcNormalPosition.Top := 0;
    end;

    Left := WindowPlacement.rcNormalPosition.Left;
    Top := WindowPlacement.rcNormalPosition.Top;
    Width := WindowPlacement.rcNormalPosition.Right - WindowPlacement.rcNormalPosition.Left;
    Height := WindowPlacement.rcNormalPosition.Bottom - WindowPlacement.rcNormalPosition.Top;
  end
  else if (((Preferences.Height > 0) and (Preferences.Width > 0))) then
  begin
    Left := Preferences.Left;
    Top := Preferences.Top;
    Width := Preferences.Width;
    Height := Preferences.Height;
    WindowState := Preferences.WindowState;

    if (WindowState = wsNormal) then
    begin
      if (Width > Screen.WorkAreaRect.Right - Screen.WorkAreaRect.Left) then
        Left := 0
      else if (Left + Width > Screen.WorkAreaRect.Right) then
        Left := Screen.WorkAreaRect.Right - Width;

      if (Height > Screen.WorkAreaRect.Bottom - Screen.WorkAreaRect.Top) then
        Top := 0
      else if (Top + Height > Screen.WorkAreaRect.Bottom) then
        Top := Screen.WorkAreaRect.Bottom - Height;
    end;
  end;
end;

function TWWindow.DBLogin(const Account: Pointer): Boolean;
begin
  DLogin.Account := TPAccount(Account);
  Result := DLogin.Execute();
end;

procedure TWWindow.DeactivateTab(const Tab: TFSession);
var
  I: Integer;
begin
  Assert(Assigned(Tab));

  Tab.FrameDeactivate(Self);

  TabControl.TabIndex := -1;

  Caption := LoadStr(1000);

  aFClose.Enabled := False;


  aVObjects.Checked := False;
  aVBrowser.Checked := False;
  aVIDE.Checked := False;
  aVBuilder.Checked := False;
  aVSQLEditor.Checked := False;
  aVSQLEditor2.Checked := False;
  aVSQLEditor3.Checked := False;
  aVNavigator.Checked := False;
  aVExplorer.Checked := False;
  aVSQLHistory.Checked := False;
  aVSQLLog.Checked := False;
  tbVRefresh.Enabled := False;

  aFOpen.Enabled := False;
  aFSave.Enabled := False;
  aFSaveAs.Enabled := False;
  aECopy.Enabled := False;
  aEPaste.Enabled := False;
  aVObjects.Enabled := False;
  aVBrowser.Enabled := False;
  aVIDE.Enabled := False;
  aVBuilder.Enabled := False;
  aVDiagram.Enabled := False;
  aVSQLEditor.Enabled := False;
  aVSQLEditor2.Enabled := False;
  aVSQLEditor3.Enabled := False;
  aVNavigator.Enabled := False;
  aVExplorer.Enabled := False;
  aVSQLHistory.Enabled := False;
  aVSQLLog.Enabled := False;
  aDCancel.Enabled := False;
  aDInsertRecord.Enabled := False;
  aDDeleteRecord.Enabled := False;
  aDRun.Enabled := False;
  aDRunSelection.Enabled := False;
  aHManual.Enabled := False;

  miVRefresh.Enabled := False;
  miVRefreshAll.Enabled := False;

  Perform(UM_UPDATETOOLBAR, 0, 0);
  for I := 0 to StatusBar.Panels.Count - 1 do
    StatusBar.Panels[I].Text := '';
end;

destructor TWWindow.Destroy();
begin
  FreeAndNil(FSessions);
  FreeAndNil(Accounts);

  inherited;
end;

procedure TWWindow.EmptyWorkingMem();
var
  Process: THandle;
begin
  Process := OpenProcess(PROCESS_ALL_ACCESS, FALSE, GetCurrentProcessId());
  if (Process <> 0) then
  begin
    SetProcessWorkingSetSize(Process, Size_T(-1), Size_T(-1));
    CloseHandle(Process);
  end;
end;

procedure TWWindow.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := CloseAll();
end;

procedure TWWindow.FormCreate(Sender: TObject);
var
  I: Integer;
  Foldername: array [0..MAX_PATH] of Char;
begin
  MouseDownPoint := Point(-1, -1);
  OnlineRecommendedUpdateFound := False;
  QuitAfterShow := False;
  UniqueTabNameCounter := 0;
  UpdateStarted := False;

  MySQLDB.MySQLConnectionOnSynchronize := MySQLConnectionSynchronize;

  Application.HelpFile := ExtractFilePath(Application.ExeName) + Copy(ExtractFileName(Application.ExeName), 1, Length(ExtractFileName(Application.ExeName)) - 4) + '.chm';
  {$IFNDEF EurekaLog}
  Application.OnException := ApplicationException;
  {$ENDIF}
  Application.OnMessage := ApplicationMessage;
  Application.OnModalBegin := ApplicationModalBegin;
  Application.OnModalEnd := ApplicationModalEnd;
  Application.OnActivate := ApplicationActivate;
  Application.OnDeactivate := ApplicationDeactivate;

  Accounts := TPAccounts.Create(DBLogin);

  Sessions.OnSQLError := SQLError;

  MainActionList := ActionList;


  TabControl.Images := Preferences.Images;
  TBTabControl.Images := Preferences.Images;

  if (not CheckWin32Version(6)) then
    CToolBar.EdgeBorders := [ebTop,ebBottom]
  else
    CToolBar.EdgeBorders := [];

  FSessions := TList.Create();
  TBTabControl.Visible := Preferences.TabsVisible;
  TabControlRepaint := TList.Create();

  aFImportAccess.Visible := (odAccess in ODBCDrivers) or (odAccess2003 in ODBCDrivers);
  aFImportExcel.Visible := (odExcel in ODBCDrivers) or (odExcel2003 in ODBCDrivers);
  aFImportODBC.Visible := ODBCEnv <> SQL_NULL_HANDLE;
  aFExportAccess.Visible := (odAccess in ODBCDrivers) or (odAccess2003 in ODBCDrivers);
  aFExportExcel.Visible := (odExcel in ODBCDrivers) or (odExcel2003 in ODBCDrivers);
  aFExportODBC.Visible := ODBCEnv <> SQL_NULL_HANDLE;
  aHIndex.Enabled := FileExists(Application.HelpFile);
  aHUpdate.Enabled := (Preferences.SetupProgram = '') and InternetGetConnectedState(nil, 0);
  aHDowndate.Enabled := Preferences.DowndateFilename <> '';
  aHSupport.Enabled := (Preferences.SetupProgram = '') and InternetGetConnectedState(nil, 0);

  Perform(UM_UPDATETOOLBAR, 0, 0);

  if (SHGetFolderPath(0, CSIDL_DESKTOP, 0, 0, @Foldername) <> S_OK) then
    OpenDialog.InitialDir := 'C:\'
  else
    OpenDialog.InitialDir := StrPas(PChar(@Foldername[0]));
  if (SHGetFolderPath(0, CSIDL_DESKTOP, 0, 0, @Foldername) <> S_OK) then
    SaveDialog.InitialDir := 'C:\'
  else
    SaveDialog.InitialDir := StrPas(PChar(@Foldername[0]));

  TabControl.Height := TabControl.Height - 1;

  for I := 0 to StatusBar.Panels.Count - 1 do
    StatusBar.Panels[I].Text := '';
end;

procedure TWWindow.FormDeactivate(Sender: TObject);
begin
  SetTimer(Handle, tiFormDeactivated, 100, nil);
end;

procedure TWWindow.FormDestroy(Sender: TObject);
begin
  while (TabControlRepaint.Count > 0) do
  begin
    FreeMem(TabControlRepaint[0]);
    TabControlRepaint.Delete(0);
  end;
  TabControlRepaint.Free();

  {$IFNDEF EurekaLog}
  Application.OnException := nil;
  {$ENDIF}
  Application.OnMessage := nil;
  Application.OnModalBegin := nil;
  Application.OnModalEnd := nil;
  Application.OnActivate := nil;
  Application.OnDeactivate := nil;

  if (Assigned(CheckOnlineVersionThread)) then
    TerminateThread(CheckOnlineVersionThread.Handle, 0);
end;

procedure TWWindow.FormHide(Sender: TObject);
begin
  Preferences.WindowState := WindowState;
  if (WindowState = wsNormal) then
    begin Preferences.Top := Top; Preferences.Left := Left; Preferences.Height := Height; Preferences.Width := Width; end;
end;

procedure TWWindow.FormResize(Sender: TObject);
var
  I: Integer;
  PanelWidth: Integer;
begin
  if (Assigned(Preferences)) then
  begin
    StatusBar.Panels[sbNavigation].Width := StatusBar.Canvas.TextWidth('9999 (999999999)') + StatusBar.BorderWidth + 15;
    StatusBar.Panels[sbSummarize].Width := StatusBar.Canvas.TextWidth(Preferences.LoadStr(889, '9999', '999999999')) + StatusBar.BorderWidth + 15;

    PanelWidth := StatusBar.Width;
    for I := 1 to StatusBar.Panels.Count - 2 do
      Dec(PanelWidth, StatusBar.Panels[I].Width);
    if (WindowState = wsNormal) then
      Dec(PanelWidth, StatusBar.Height);
    StatusBar.Panels[sbMessage].Width := PanelWidth;
  end;

  if (not TabControl.Visible and Assigned(TabControl.OnResize)) then
    TabControl.OnResize(Sender);
end;

procedure TWWindow.FormShow(Sender: TObject);
begin
  if ((not UpdateAvailable and (DateOf(LastUpdateCheck) < Today()) or (ObsoleteVersion >= ProgramVersion)) and InternetGetConnectedState(nil, 0)) then
  begin
    CheckOnlineVersionThread := TCheckOnlineVersionThread.Create();
    CheckOnlineVersionThread.OnTerminate := OnlineVersionChecked;
    CheckOnlineVersionThread.Start();
  end;

  AddTabParam := ParamStr(1);
  PostMessage(Handle, UM_ADDTAB, 0, LPARAM(PChar(AddTabParam)));
end;

function TWWindow.GetActiveTab(): TFSession;
begin
  if (not Assigned(FSessions) or (TabControl.TabIndex < 0) or (FSessions.Count <= TabControl.TabIndex)) then
    Result := nil
  else
    Result := TFSession(FSessions[TabControl.TabIndex]);
end;

function TWWindow.GetNewTabIndex(Sender: TObject; X, Y: Integer): Integer;
var
  I: Integer;
begin
  Result := TabControlDragStartTabIndex;
  for I := TabControlDragStartTabIndex - 1 downto 0 do
    if (X < TabControl.TabRect(I).Left + 3 * ((TabControl.TabRect(I).Right - TabControl.TabRect(I).Left) div 4)) then
      Result := I;
  for I := TabControlDragStartTabIndex + 1 to TabControl.Tabs.Count - 1 do
    if (X > TabControl.TabRect(I).Left + ((TabControl.TabRect(I).Right - TabControl.TabRect(I).Left) div 4)) then
      Result := I;
end;

procedure TWWindow.HidePopupChildren();
var
  I: Integer;
begin
  for I := 0 to PopupChildren.Count - 1 do
    if (TCustomForm(PopupChildren[I]).Visible) then
    begin
      ActiveControl := nil;
      TCustomForm(PopupChildren[I]).Hide();
    end;
end;

procedure TWWindow.InformOnlineUpdateFound();
begin
  if (MsgBox(Preferences.LoadStr(506) + #10#10 + Preferences.LoadStr(845), Preferences.LoadStr(101), MB_ICONQUESTION + MB_YESNOCANCEL) = ID_YES) then
    UpdateStarted := aHUpdate.Execute();
end;

procedure TWWindow.miFReopenClick(Sender: TObject);
begin
  ActiveTab.OpenSQLFile(ActiveTab.Session.Account.Desktop.Files[TMenuItem(Sender).Tag].Filename, ActiveTab.Session.Account.Desktop.Files[TMenuItem(Sender).Tag].CodePage);
end;

procedure TWWindow.mtTabsClick(Sender: TObject);
begin
  if (Sender is TMenuItem) then
  begin
    if (Assigned(ActiveTab)) then
      DeactivateTab(ActiveTab);
    ActivateTab(TFSession(FSessions[TMenuItem(Sender).Parent.IndexOf(TMenuItem(Sender))]));
  end;
end;

procedure TWWindow.MySQLConnectionSynchronize(const Data: Pointer);
begin
  PostMessage(Handle, UM_MYSQLCLIENT_SYNCHRONIZE, 0, LPARAM(Data));
end;

procedure TWWindow.OnlineVersionChecked(Sender: TObject);
begin
  PostMessage(Handle, UM_TERMINATE, 0, 0);
  if ((Sender is TCheckOnlineVersionThread)
    and (TCheckOnlineVersionThread(Sender).ErrorCode = 0)
    and (TCheckOnlineVersionThread(Sender).HTTPStatus = HTTP_STATUS_OK)
    and (RecommendedUpdateAvailable or (ObsoleteVersion > 0) and UpdateAvailable)) then
    PostMessage(Handle, UM_ONLINE_UPDATE_FOUND, 0, 0);
end;

procedure TWWindow.SetActiveTab(const FSession: TFSession);
begin
  TabControl.TabIndex := FSessions.IndexOf(FSession);

  TFSession(FSessions[FSessions.IndexOf(FSession)]).BringToFront();
end;

procedure TWWindow.SQLError(const Connection: TMySQLConnection; const ErrorCode: Integer; const ErrorMessage: string);
var
  Flags: Longint;
  Msg: string;
begin
  case (ErrorCode) of
    EE_READ: Msg := ErrorMessage;
    ER_DBACCESS_DENIED_ERROR: Msg := Preferences.LoadStr(165, IntToStr(ErrorCode), ErrorMessage);
    ER_ACCESS_DENIED_ERROR: Msg := Preferences.LoadStr(165, IntToStr(ErrorCode), ErrorMessage);
    ER_CANT_OPEN_LIBRARY: Msg := Preferences.LoadStr(570, Connection.LibraryName, ExtractFilePath(Application.ExeName));
    CR_COMMANDS_OUT_OF_SYNC: Msg := 'Internal Program Bug #' + IntToStr(ErrorCode) + ': ' + ErrorMessage;
    CR_CONN_HOST_ERROR: if (Connection.Port = MYSQL_PORT) then Msg := Preferences.LoadStr(495, Connection.Host) else Msg := Preferences.LoadStr(495, Connection.Host + ':' + IntToStr(Connection.Port));
    CR_SERVER_GONE_ERROR: if (Connection.Port = MYSQL_PORT) then Msg := Preferences.LoadStr(881, Connection.Host) else Msg := Preferences.LoadStr(881, Connection.Host + ':' + IntToStr(Connection.Port));
    CR_UNKNOWN_HOST: if (ErrorMessage <> '') then Msg := ErrorMessage else if (Connection.Host <> '') then Msg := Preferences.LoadStr(706, Connection.Host) else Msg := Preferences.LoadStr(706);
    CR_OUT_OF_MEMORY: Msg := Preferences.LoadStr(733);
    CR_SERVER_LOST: Msg := Preferences.LoadStr(806, TSConnection(Connection).Session.Caption);
    CR_HTTPTUNNEL_UNKNOWN_ERROR: Msg := ErrorMessage + #10#10 + Preferences.LoadStr(652) + ': ' + Connection.LibraryName;
    CR_HTTPTUNNEL_OLD: Msg := Preferences.LoadStr(659, Connection.LibraryName);
    CR_HTTPTUNNEL_CONN_ERROR: Msg := ErrorMessage;
    CR_HTTPTUNNEL_ACCESS_DENIED_ERROR: Msg := Preferences.LoadStr(860, Preferences.LoadStr(859), Copy(ErrorMessage, 1, Pos(' ', ErrorMessage) - 1)) + ':' + #10#10 + ErrorMessage  + #10#10 + ' (' + Connection.LibraryName + ')';
    CR_HTTPTUNNEL_NOT_FOUND: Msg := Preferences.LoadStr(523, Connection.LibraryName);
    CR_HTTPTUNNEL_INVALID_CONTENT_TYPE_ERROR: Msg := ErrorMessage;
    CR_HTTPTUNNEL_SERVER_ERROR: Msg := Preferences.LoadStr(860, Preferences.LoadStr(859), Copy(ErrorMessage, 1, Pos(' ', ErrorMessage) - 1)) + ':' + #10#10 + ErrorMessage  + #10#10 + ' (' + Connection.LibraryName + ')';
    CR_HTTPTUNNEL_INVALID_SERVER_RESPONSE,
    CR_IPSOCK_ERROR: Msg := ErrorMessage;
    DS_SERVER_OLD: Msg := Preferences.LoadStr(696, '3.23.20');
    DS_OUT_OF_MEMORY: Msg := Preferences.LoadStr(733);
    else
      if ((CR_MIN_ERROR <= ErrorCode) and (ErrorCode <= CR_MAX_ERROR)) then
        Msg := ErrorMessage
      else
        Msg := Preferences.LoadStr(165, IntToStr(ErrorCode), ErrorMessage);
  end;

  if (Msg <> '') then
  begin
    case (ErrorCode) of
      ER_DBACCESS_DENIED_ERROR,
      ER_ACCESS_DENIED_ERROR: MsgBoxHelpContext := 1145;
      CR_CONN_HOST_ERROR: MsgBoxHelpContext := 1146;
      CR_UNKNOWN_HOST: MsgBoxHelpContext := 1144;
      else MsgBoxHelpContext := 0;
    end;
    Flags := MB_OK + MB_ICONERROR;
    if (MsgBoxHelpContext <> 0) then
      Flags := Flags or MB_HELP;

    MsgBox(Msg, Preferences.LoadStr(45), Flags);
  end;
end;

procedure TWWindow.TabControlChange(Sender: TObject);
begin
  if ((0 <= TabControl.TabIndex) and (TabControl.TabIndex < FSessions.Count)) then
    ActivateTab(TFSession(FSessions[TabControl.TabIndex]));
end;

procedure TWWindow.TabControlChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  if (Assigned(ActiveTab)) then
    DeactivateTab(ActiveTab);
end;

procedure TWWindow.TabControlContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  I: Integer;
  MenuItem: TMenuItem;
begin
  mtTabs.Clear();
  if (TabControl.Tabs.Count > 1) then
    for I := 0 to FSessions.Count - 1 do
    begin
      MenuItem := TMenuItem.Create(Self);
      MenuItem.Caption := TFSession(FSessions[I]).ToolBarData.Caption;
      MenuItem.RadioItem := True;
      MenuItem.Checked := I = TabControl.TabIndex;
      MenuItem.OnClick := mtTabsClick;
      mtTabs.Add(MenuItem);
    end;

  ShowEnabledItems(MTabControl.Items);
end;

procedure TWWindow.TabControlDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  I: Integer;
  NewTabIndex: Integer;
begin
  NewTabIndex := GetNewTabIndex(Sender, X, Y);

  FSessions.Move(TabControlDragStartTabIndex, NewTabIndex);

  TabControl.Tabs.Clear();
  for I := 0 to FSessions.Count - 1 do
    TabControl.Tabs.Add(TFSession(FSessions[I]).Session.Account.Name);

  TabControl.TabIndex := NewTabIndex;
end;

procedure TWWindow.TabControlDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  NewTabIndex: Integer;
begin
  NewTabIndex := GetNewTabIndex(Sender, X, Y);
  Accept := (Source = TabControl) and (NewTabIndex <> TabControlDragStartTabIndex);

  if ((TabControlDragStartTabIndex >= 0) and (NewTabIndex <> TabControlDragMarkedTabIndex)) then
    TabControl.Repaint();
  if (Accept) then
  begin
    TabControl.Canvas.Brush.Color := clBtnText;
    if (NewTabIndex < TabControlDragStartTabIndex) then
      TabControl.Canvas.FillRect(Rect(TabControl.TabRect(NewTabIndex).Left - 2, 0, TabControl.TabRect(NewTabIndex).Left + 2, TabControl.Height))
    else
      TabControl.Canvas.FillRect(Rect(TabControl.TabRect(NewTabIndex).Right - 2, 0, TabControl.TabRect(NewTabIndex).Right + 2, TabControl.Height));
    TabControlDragMarkedTabIndex := NewTabIndex;
  end;
end;

procedure TWWindow.TabControlEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  TabControl.Repaint();
end;

procedure TWWindow.TabControlGetImageIndex(Sender: TObject;
  TabIndex: Integer; var ImageIndex: Integer);
begin
  ImageIndex := iiServer;

  if (ImageIndex < 0) then
    ImageIndex := iiServer;
end;

procedure TWWindow.TabControlMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  AllowChange: Boolean;
  I: Integer;
begin
  if (Button = mbRight) then
    for I := 0 to TabControl.Tabs.Count - 1 do
      if ((TabControl.TabRect(I).Left <= X) and (X <= TabControl.TabRect(I).Right)) then
      begin
        AllowChange := True;
        TabControlChanging(Sender, AllowChange);
        if (AllowChange) then
        begin
          TabControl.TabIndex := I;
          TabControlChange(Sender);
        end;
      end;
end;

procedure TWWindow.TabControlMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Index: Integer;
  S: string;
  Tab: TFSession;
begin
  Index := TabControl.IndexOfTabAt(X, Y);
  if ((Index < 0) or (FSessions.Count <= Index)) then
    TabControl.Hint := ''
  else
  begin
    Tab := TFSession(FSessions[Index]);

    S := Tab.Session.Caption;
    if (Tab.ToolBarData.Caption <> '') then
      S := S + ' - ' + Tab.ToolBarData.Caption;
    TabControl.Hint := S;
  end;
end;

procedure TWWindow.TabControlResize(Sender: TObject);
begin
  if (TabControl.Tabs.Count > 0) then
  begin
    TBTabControl.Left := TabControl.TabRect(TabControl.Tabs.Count - 1).Right + 5;
    TBTabControl.Top := TabControl.Top + 1;
    TBTabControl.Width := TabControl.Width - TBTabControl.Left;
    TBTabControl.Height := TabControl.Height - 3;
  end
  else
  begin
    TBTabControl.Left := CToolBar.Left;
    TBTabControl.Top := CToolBar.Top + CToolBar.Height;
    TBTabControl.Width := CToolBar.Width;
    TBTabControl.Height := TabControl.Height - 3;
  end
end;

procedure TWWindow.TabControlStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  TabControlDragStartTabIndex := TabControl.TabIndex;
  TabControlDragMarkedTabIndex := -1;
end;

procedure TWWindow.tbPropertiesClick(Sender: TObject);
begin
  ActiveTab.ToolBarData.tbPropertiesAction.Execute();
end;

procedure TWWindow.UMActivateFrame(var Message: TMessage);
begin
  TFSession(Message.LParam).FrameActivate(Self);
end;

procedure TWWindow.UMAddTab(var Message: TMessage);
var
  FSession: TFSession;
begin
  DAccounts.Open := True;
  DAccounts.Account := nil;
  DAccounts.Session := nil;
  if (LowerCase(LeftStr(PChar(Message.LParam), 8)) = 'mysql://') then
  begin
    DAccounts.Account := Accounts.AccountByURI(StrPas(PChar(Message.LParam)));
    if (Assigned(DAccounts.Account)) then
    begin
      DConnecting.Session := TSSession.Create(Sessions, DAccounts.Account);
      if (not DConnecting.Execute()) then
        DConnecting.Session.Free()
      else
        DAccounts.Session := DConnecting.Session;
    end;
  end;
  if ((not Assigned(DAccounts.Session) and not DAccounts.Execute()) or UpdateStarted) then
    FSession := nil
  else
  begin
    if (Assigned(ActiveTab)) then
      DeactivateTab(ActiveTab);

    if (FSessions.Count = 0) then
    begin
      TabControl.Tabs.Add(DAccounts.Session.Account.Name);
      TabControl.Visible := Preferences.TabsVisible;
      if (TabControl.Visible) then
        TabControlResize(nil);
    end
    else
    begin
      TabControl.Tabs.Add(DAccounts.Session.Account.Name);
      if (TabControl.Tabs.Count < 0) then
        raise ERangeError.Create(SRangeError);
      TabControl.TabIndex := TabControl.Tabs.Count - 1;
      if (not TabControl.Visible) then
      begin
        TabControl.Visible := True;
        TabControlResize(nil);
      end;
    end;

    FSession := TFSession.Create(Self, PWorkSpace, DAccounts.Session, PChar(Message.LParam));
    FSession.Visible := True;

    Inc(UniqueTabNameCounter);
    FSession.Name := FSession.ClassName + '_0_' + IntToStr(UniqueTabNameCounter);

    FSession.StatusBar := StatusBar;

    aFCloseAll.Enabled := True;

    FSessions.Add(FSession);

    ActivateTab(FSession);

    TBTabControl.Visible := TabControl.Visible;
  end;

  Message.Result := LRESULT(Assigned(FSession));
end;

procedure TWWindow.UMChangePreferences(var Message: TMessage);
var
  I: Integer;
begin
  ToolBar.Images := Preferences.Images;
  TabControl.Images := Preferences.Images;
  TBTabControl.Images := Preferences.Images;

  TabControl.Canvas.Font := Font;

  Caption := LoadStr(1000);

  miFile.Caption := Preferences.LoadStr(3);
  aFOpenAccount.Caption := Preferences.LoadStr(1) + '...';
  aFOpen.Caption := Preferences.LoadStr(581) + '...';
  aFSave.Caption := Preferences.LoadStr(582);
  aFSaveAs.Caption := Preferences.LoadStr(583) + '...';
  miFReopen.Caption := Preferences.LoadStr(885);
  miFImport.Caption := Preferences.LoadStr(371);
  aFImportSQL.Caption := Preferences.LoadStr(409) + '...';
  aFImportText.Caption := Preferences.LoadStr(410) + '...';
  aFImportExcel.Caption := Preferences.LoadStr(801) + '...';
  aFImportAccess.Caption := Preferences.LoadStr(695) + '...';
  aFImportODBC.Caption := Preferences.LoadStr(607) + '...';
  miFExport.Caption := Preferences.LoadStr(200);
  aFExportSQL.Caption := Preferences.LoadStr(409) + '...';
  aFExportText.Caption := Preferences.LoadStr(410) + '...';
  aFExportExcel.Caption := Preferences.LoadStr(801) + '...';
  aFExportAccess.Caption := Preferences.LoadStr(695) + '...';
  aFExportODBC.Caption := Preferences.LoadStr(607) + '...';
  aFExportHTML.Caption := Preferences.LoadStr(453) + '...';
  aFExportXML.Caption := Preferences.LoadStr(454) + '...';
  aFExportPDF.Caption := Preferences.LoadStr(890) + '...';
  aFExportBitmap.Caption := Preferences.LoadStr(868) + '...';
  aFClose.Caption := Preferences.LoadStr(7);
  aFExit.Caption := Preferences.LoadStr(8);

  miEdit.Caption := Preferences.LoadStr(62);
  aEUndo.Caption := Preferences.LoadStr(425);
  aERedo.Caption := Preferences.LoadStr(705);
  aECut.Caption := Preferences.LoadStr(63);
  aECopy.Caption := Preferences.LoadStr(64);
  aEPaste.Caption := Preferences.LoadStr(65);
  aEDelete.Caption := Preferences.LoadStr(28);
  aESelectAll.Caption := Preferences.LoadStr(572);
  aECopyToFile.Caption := Preferences.LoadStr(182) + '...';
  aEPasteFromFile.Caption := Preferences.LoadStr(183) + '...';
  aERename.Caption := Preferences.LoadStr(98);

  miSearch.Caption := Preferences.LoadStr(424);
  aSSearchFind.Caption := Preferences.LoadStr(187) + '...';
  aSSearchReplace.Caption := Preferences.LoadStr(416) + '...';
  aSSearchNext.Caption := Preferences.LoadStr(188);

  miView.Caption := Preferences.LoadStr(9);
  aVObjects.Caption := Preferences.LoadStr(4);
  aVBrowser.Caption := Preferences.LoadStr(5);
  aVIDE.Caption := Preferences.LoadStr(865);
  aVBuilder.Caption := Preferences.LoadStr(852);
  aVDiagram.Caption := Preferences.LoadStr(800);
  aVSQLEditor.Caption := Preferences.LoadStr(6);
  aVSQLEditor2.Caption := Preferences.LoadStr(6) + ' #2';
  aVSQLEditor3.Caption := Preferences.LoadStr(6) + ' #3';
  miVSidebar.Caption := Preferences.LoadStr(736);
  aVNavigator.Caption := Preferences.LoadStr(10);
  aVExplorer.Caption := Preferences.LoadStr(435);
  aVSQLHistory.Caption := Preferences.LoadStr(807);
  aVSQLLog.Caption := Preferences.LoadStr(11);
  aVRefresh.Caption := Preferences.LoadStr(41);
  aVRefreshAll.Caption := Preferences.LoadStr(623);

  miDatabase.Caption := Preferences.LoadStr(38);
  miDCreate.Caption := Preferences.LoadStr(26);
  aDCreateDatabase.Caption := Preferences.LoadStr(38) + '...';
  aDCreateTable.Caption := Preferences.LoadStr(302) + '...';
  aDCreateView.Caption := Preferences.LoadStr(738) + '...';
  aDCreateProcedure.Caption := Preferences.LoadStr(768) + '...';
  aDCreateFunction.Caption := Preferences.LoadStr(769) + '...';
  aDCreateTrigger.Caption := Preferences.LoadStr(788) + '...';
  aDCreateEvent.Caption := Preferences.LoadStr(812) + '...';
  aDCreateKey.Caption := Preferences.LoadStr(163) + '...';
  aDCreateField.Caption := Preferences.LoadStr(164) + '...';
  aDCreateForeignKey.Caption := Preferences.LoadStr(248) + '...';
  aDCreateUser.Caption := Preferences.LoadStr(561) + '...';
  miDDelete.Caption := Preferences.LoadStr(28);
  aDDeleteDatabase.Caption := Preferences.LoadStr(38);
  aDDeleteTable.Caption := Preferences.LoadStr(302);
  aDDeleteView.Caption := Preferences.LoadStr(738);
  aDDeleteRoutine.Caption := Preferences.LoadStr(774);
  aDDeleteKey.Caption := Preferences.LoadStr(163);
  aDDeleteField.Caption := Preferences.LoadStr(164);
  aDDeleteForeignKey.Caption := Preferences.LoadStr(248);
  aDDeleteTrigger.Caption := Preferences.LoadStr(788);
  aDDeleteEvent.Caption := Preferences.LoadStr(812);
  aDDeleteUser.Caption := Preferences.LoadStr(561);
  aDDeleteProcess.Caption := Preferences.LoadStr(562);
  miDProperties.Caption := Preferences.LoadStr(97);
  aDEditServer.Caption := Preferences.LoadStr(37) + '...';
  aDEditDatabase.Caption := Preferences.LoadStr(38) + '...';
  aDEditTable.Caption := Preferences.LoadStr(302) + '...';
  aDEditView.Caption := Preferences.LoadStr(738) + '...';
  aDEditRoutine.Caption := Preferences.LoadStr(774) + '...';
  aDEditKey.Caption := Preferences.LoadStr(163) + '...';
  aDEditField.Caption := Preferences.LoadStr(164) + '...';
  aDEditForeignKey.Caption := Preferences.LoadStr(248) + '...';
  aDEditTrigger.Caption := Preferences.LoadStr(788) + '...';
  aDEditEvent.Caption := Preferences.LoadStr(812) + '...';
  aDEditProcess.Caption := Preferences.LoadStr(562) + '...';
  aDEditUser.Caption := Preferences.LoadStr(561) + '...';
  aDEditVariable.Caption := Preferences.LoadStr(267) + '...';
  aDInsertRecord.Caption := Preferences.LoadStr(179);
  aDDeleteRecord.Caption := Preferences.LoadStr(178);
  aDEditRecord.Caption := Preferences.LoadStr(500);
  aDPostRecord.Caption := Preferences.LoadStr(516);
  aDCancelRecord.Caption := Preferences.LoadStr(517);
  aDCancel.Caption := Preferences.LoadStr(517);
  aDRun.Caption := Preferences.LoadStr(174);
  aDRunSelection.Caption := Preferences.LoadStr(175);
  aDPostObject.Caption := Preferences.LoadStr(582);
  aDEmpty.Caption := Preferences.LoadStr(181);

  miOptions.Caption := Preferences.LoadStr(13);
  aOGlobals.Caption := Preferences.LoadStr(52) + '...';
  aOAccounts.Caption := Preferences.LoadStr(25) + '...';
  aOImport.Caption := Preferences.LoadStr(371) + '...';
  aOExport.Caption := Preferences.LoadStr(200) + '...';

  miExtras.Caption := Preferences.LoadStr(707);
  aEFind.Caption := Preferences.LoadStr(187) + '...';
  aEReplace.Caption := Preferences.LoadStr(416) + '...';
  aETransfer.Caption := Preferences.LoadStr(753) + '...';
  aEFormatSQL.Caption := Preferences.LoadStr(921);

  miHelp.Caption := Preferences.LoadStr(167);
  aHIndex.Caption := Preferences.LoadStr(653) + '...';
  aHSQL.Caption := Preferences.LoadStr(883) + '...';
  aHManual.Caption := Preferences.LoadStr(573);
  aHUpdate.Caption := Preferences.LoadStr(666) + '...';
  aHDowndate.Caption := Preferences.LoadStr(943);
  aHSupport.Caption := 'Support...';
  aHInfo.Caption := Preferences.LoadStr(168) + '...';

  for I := 0 to ActionList.ActionCount - 1 do
    if (ActionList.Actions[I] is TCustomAction) and (TCustomAction(ActionList.Actions[I]).Hint = '') then
      TCustomAction(ActionList.Actions[I]).Hint := TCustomAction(ActionList.Actions[I]).Caption;

  mtTabs.Caption := Preferences.LoadStr(851);

  SetToolBarHints(ToolBar);
  tbCreateDatabase.Hint := Preferences.LoadStr(147) + '...';
  tbDeleteDatabase.Hint := Preferences.LoadStr(28);
  tbCreateTable.Hint := Preferences.LoadStr(383) + '...';
  tbDeleteTable.Hint := Preferences.LoadStr(28);
  tbCreateIndex.Hint := Preferences.LoadStr(160) + '...';
  tbDeleteIndex.Hint := Preferences.LoadStr(28);
  tbCreateField.Hint := Preferences.LoadStr(87) + '...';
  tbDeleteField.Hint := Preferences.LoadStr(28);
  tbCreateForeignKey.Hint := Preferences.LoadStr(249) + '...';
  tbDeleteForeignKey.Hint := Preferences.LoadStr(28);
  tbProperties.Hint := Preferences.LoadStr(97) + '...';
  tbPostRecord.Hint := Preferences.LoadStr(516);
  tbCancelRecord.Hint := Preferences.LoadStr(517);


  SetToolBarHints(TBTabControl);


  try
    acQBLanguageManager.CurrentLanguageIndex := -1;
    for I := 0 to acQBLanguageManager.LanguagesCount - 1 do
      if (lstrcmpi(PChar(acQBLanguageManager.Language[i].LanguageName), PChar(Preferences.Language.ActiveQueryBuilderLanguageName)) = 0) then
        acQBLanguageManager.CurrentLanguageIndex := I;
  except
    // There is a bug inside acQBLocalizer.pas ver. 1.18 - but it's not interested to get informed
  end;

  if (Assigned(FSessions)) then
    for I := 0 to FSessions.Count - 1 do
      SendMessage(TFSession(FSessions[0]).Handle, Message.Msg, Message.WParam, Message.LParam);
end;

procedure TWWindow.UMCrashRescue(var Message: TMessage);
var
  I: Integer;
begin
  if (not (csDestroying in ComponentState)) then
  begin
    for I := 0 to FSessions.Count - 1 do
      try TFSession(FSessions[I]).CrashRescue(); except end;

    try Accounts.Save(); except end;

    try Preferences.Save(); except end;
  end;
end;

procedure TWWindow.UMMySQLClientSynchronize(var Message: TMessage);
begin
  MySQLDB.MySQLConnectionSynchronize(Pointer(Message.LParam));
end;

procedure TWWindow.UMOnlineUpdateFound(var Message: TMessage);
begin
  if (Screen.ActiveForm <> Self) then
    OnlineRecommendedUpdateFound := True
  else
    InformOnlineUpdateFound();
end;

procedure TWWindow.UMTerminate(var Message: TMessage);
begin
  CheckOnlineVersionThread.WaitFor();
  CheckOnlineVersionThread.Free();
  CheckOnlineVersionThread := nil;
end;

procedure TWWindow.UMUpdateToolbar(var Message: TMessage);
var
  Found: Boolean;
  I: Integer;
  MenuItem: TMenuItem;
  S: string;
  Tab: TFSession;
begin
  Tab := TFSession(Message.LParam);

  for I := ToolBar.ButtonCount - 1 downto ToolButton11.Index do
    ToolBar.Buttons[I].Visible := False;

  if (not Assigned(Tab)) then
  begin
    Caption := LoadStr(1000);
    Application.Title := Caption;
  end
  else if (Tab = ActiveTab) then
  begin
    S := Tab.Session.Caption;
    if (Tab.ToolBarData.Caption <> '') then
      S := S + ' - ' + Tab.ToolBarData.Caption;
    Caption := S + ' - ' + LoadStr(1000);
    Application.Title := Caption;

    tbProperties.Action := Tab.ToolBarData.tbPropertiesAction;
    tbProperties.Caption := Preferences.LoadStr(97) + '...';
    tbProperties.ImageIndex := 11;
  end;

  tbCreateDatabase.Visible   := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vObjects, vObjectSearch]);
  tbDeleteDatabase.Visible   := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vObjects, vObjectSearch]);
  tbCreateTable.Visible      := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vObjects, vDiagram, vObjectSearch]);
  tbDeleteTable.Visible      := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vObjects, vDiagram, vObjectSearch]);
  tbCreateIndex.Visible      := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vObjects, vObjectSearch]);
  tbDeleteIndex.Visible      := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vObjects, vObjectSearch]);
  tbCreateField.Visible      := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vObjects, vObjectSearch]);
  tbDeleteField.Visible      := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vObjects, vObjectSearch]);
  tbCreateForeignKey.Visible := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vObjects, vDiagram, vObjectSearch]);
  tbDeleteForeignKey.Visible := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vObjects, vDiagram, vObjectSearch]);
  tbProperties.Visible       := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vObjects, vDiagram, vObjectSearch]);

  tbOpen.Visible             := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vIDE, vBuilder, vEditor, vEditor2, vEditor3]);
  tbSave.Visible             := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vIDE, vBuilder, vEditor, vEditor2, vEditor3]);
  tbUndo.Visible             := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vIDE, vBuilder, vEditor, vEditor2, vEditor3]);
  tbRedo.Visible             := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vIDE, vBuilder, vEditor, vEditor2, vEditor3]);
  tbSearchFind.Visible       := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vIDE, vBuilder, vEditor, vEditor2, vEditor3]);
  tbSearchReplace.Visible    := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vIDE, vBuilder, vEditor, vEditor2, vEditor3]);
  tbRun.Visible              := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vIDE, vBuilder, vEditor, vEditor2, vEditor3]);
  tbRunSelection.Visible     := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vIDE, vEditor, vEditor2, vEditor3]);
  tbPostObject.Visible       := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vIDE]);
  tbFormatSQL.Visible        := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vIDE, vEditor, vEditor2, vEditor3]);

  tbDBFirst.Visible          := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vBrowser, vBuilder, vEditor, vEditor2, vEditor3]);
  tbDBPrev.Visible           := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vBrowser]);
  tbDBNext.Visible           := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vBrowser]);
  tbDBLast.Visible           := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vBrowser, vBuilder, vEditor, vEditor2, vEditor3]);
  tbDInsertRecord.Visible    := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vBrowser, vBuilder, vEditor, vEditor2, vEditor3]);
  tbDDeleteRecord.Visible    := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vBrowser, vBuilder, vEditor, vEditor2, vEditor3]);
  tbPostRecord.Visible       := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vBrowser]);
  tbCancelRecord.Visible     := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vBrowser]);

  // Auto hide unneeded separator buttons
  Found := False;
  for I := ToolBar.ButtonCount - 1 downto ToolButton11.Index do
    if (ToolBar.Buttons[I].ImageIndex >= 0) then
      Found := Found or ToolBar.Buttons[I].Visible
    else
    begin
      ToolBar.Buttons[I].Visible := Found;
      Found := False;
    end;

  // Recreate Toolbar, to apply correct ButtonWidth on higher DPI
  Toolbar.Images := Toolbar.Images;

  while (miFReopen.Count > 1) do
    miFReopen.Delete(0);

  miFReopen.Enabled := Assigned(Tab) and Tab.Visible and (Tab.ToolBarData.View in [vEditor, vEditor2, vEditor3]) and (Tab.Session.Account.Desktop.Files.Count > 0);
  if (miFReopen.Enabled) then
  begin
    for I := 0 to Tab.Session.Account.Desktop.Files.Count - 1 do
    begin
      MenuItem := TMenuItem.Create(Owner);
      MenuItem.Caption := '&' + IntToStr(miFReopen.Count) + ' ' + Tab.Session.Account.Desktop.Files[I].Filename;
      MenuItem.OnClick := miFReopenClick;
      MenuItem.Tag := I;
      miFReopen.Add(MenuItem);
    end;
    miFReopen.Delete(0);
  end;
end;

procedure TWWindow.WMDrawItem(var Message: TWMDrawItem);
var
  Control: TControl;
begin
  Control := FindControl(Message.DrawItemStruct^.hwndItem);

  if ((Control is TTabControl) and TTabControl(Control).OwnerDraw) then
    Control.Perform(Message.Msg + CN_BASE, TMessage(Message).WParam, TMessage(Message).LParam)
  else
    inherited;
end;

procedure TWWindow.WMHelp(var Message: TWMHelp);
begin
  if (Message.HelpInfo.iContextType = HELPINFO_MENUITEM) then
    inherited
  else if (MsgBoxHelpContext <> 0) then
    Application.HelpCommand(HELP_CONTEXT, MsgBoxHelpContext);
end;

procedure TWWindow.WMTimer(var Message: TWMTimer);
var
  HideChildren: Boolean;
  I: Integer;
  Wnd: HWND;
begin
  case (Message.TimerID) of
    tiEmptyWorkingMem:
      EmptyWorkingMem();
    tiFormDeactivated:
      begin
        Wnd := GetActiveWindow();
        HideChildren := Wnd <> Handle;
        for I := 0 to PopupChildren.Count - 1 do
          HideChildren := HideChildren and (Wnd <> TCustomForm(PopupChildren[I]).Handle);
        if (HideChildren) then
          HidePopupChildren();
      end;
  end;
end;

procedure TWWindow.WMWindowPosChanging(var Message: TWMWindowPosChanging);
var
  I: Integer;
  PopupChildVisible: Boolean;
begin
  if (not (csDestroying in ComponentState)) then
  begin
    if (Message.WindowPos^.flags and SWP_NOMOVE = 0) then
      HidePopupChildren()
    else if (Message.WindowPos^.flags and SWP_NOZORDER = 0) then
    begin
      PopupChildVisible := False;
      for I := 0 to PopupChildren.Count - 1 do
        PopupChildVisible := PopupChildVisible or TCustomForm(PopupChildren[I]).Visible;
      if (PopupChildVisible) then
        Message.WindowPos^.flags := Message.WindowPos^.flags or SWP_NOZORDER;
    end;
  end;

  inherited;
end;

end.

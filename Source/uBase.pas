unit uBase;

interface {********************************************************************}

uses
  Windows,
  Classes, SysUtils, Messages,
  ComCtrls, Forms, Menus, ActnList, Controls, ExtCtrls, Dialogs, Graphics,
  MySQLDB, MySQLDBGrid,
  uPreferences;

const
  iiBaseField = 27;
  iiBaseTable = 25;
  iiCalendar = 81;
  iiDatabase = 24;
  iiEvent = 85;
  iiExport = 104;
  iiForeignKey = 28;
  iiFunction = 77;
  iiImport = 103;
  iiKey = 26;
  iiODBC = 16;
  iiPartition = iiBaseTable;
  iiPlugin = 86;
  iiProcedure = 76;
  iiProcess = 43;
  iiProcesses = 31;
  iiQuery = 83;
  iiQuickAccess = 73;
  iiServer = 23;
  iiStatement = 82;
  iiStatus = 44;
  iiSystemDatabase = 90;
  iiSystemView = 79;
  iiSystemViewField = 80;
  iiTable = 4;
  iiTransfer = 105;
  iiTrigger = 78;
  iiUser = 41;
  iiUsers = 33;
  iiVariable = 42;
  iiVariables = 34;
  iiView = 74;
  iiViewField = 75;
  iiVirtualField = 106;

  crClone = 33;

  UM_ADDTAB = WM_USER + 100;
  UM_CRASH_RESCUE = WM_USER + 103;
  UM_ONLINE_UPDATE_FOUND = WM_USER + 106;
  UM_POST_AFTEREXECUTESQL = WM_USER + 107;
  UM_POST_SHOW = WM_USER + 109;
  UM_PREFERENCES_CHANGED = WM_USER + 101;
  UM_TERMINATE = WM_USER + 110;
  UM_TOOL_ERROR = WM_USER + 111;
  UM_UPDATEPROGRESSINFO = WM_USER + 112;
  UM_UPDATETOOLBAR = WM_USER + 113;

  CF_MYSQLSQLDATA = MySQLDBGrid.CF_MYSQLSQLDATA;
  CF_MYSQLSERVER = CF_PRIVATEFIRST + 3;
  CF_MYSQLDATABASE = CF_PRIVATEFIRST + 4;
  CF_MYSQLTABLE = CF_PRIVATEFIRST + 5;
  CF_MYSQLVIEW = CF_PRIVATEFIRST + 6;
  CF_MYSQLUSERS = CF_PRIVATEFIRST + 7;
  CF_ACCOUNT = CF_PRIVATEFIRST + 8;

  MB_CANCELTRYCONTINUE = $00000006;
  MB_YESYESTOALLNOCANCEL = $00000007;

  IDALL = 12;
  IDNOALL = 13;
  IDYESALL = 14;

procedure ConvertError(Sender: TObject; Text: string);
procedure DrawCloseBitmap(const Bitmap: Graphics.TBitmap; const Rect: TRect);
function EditWordBreakProc(lpch: LPTSTR; ichCurrent: Integer; cch: Integer;
  code: Integer): Integer; stdcall;
function FilterDescription(const Ext: string): string;
function FindMenuItemByName(const Item: TMenuItem; const Name: string): TMenuItem;
function MsgBoxCheck(const Text: string; const Caption: string; uType: UINT;
  Default: Integer; RegVal: PChar): Integer;
function MsgBox(const Text: string; const Caption: string; const Flags: Longint): Integer;
procedure SetControlCursor(const Control: TControl; const Cursor: TCursor);
procedure SetToolBarHints(const ToolBar: TToolBar);
function ShowEnabledItems(const Item: TMenuItem): Boolean;
function SizeToStr(const Size: LongLong): string;
function StrToInt(const S: string): Integer;
function TryStrToInt(const S: string; out Value: Integer): Boolean;

var
  DurationFormatSettings: TFormatSettings;
  LocaleFormatSettings: TFormatSettings;
  MainActionList: TActionList;
  MsgBoxHelpContext: Longint;

  aDCancel: TAction;
  aDCancelRecord: TAction;
  aDCreateDatabase: TAction;
  aDCreateEvent: TAction;
  aDCreateField: TAction;
  aDCreateForeignKey: TAction;
  aDCreateFunction: TAction;
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
  aDPostRecord: TAction;
  aDRun: TAction;
  aDRunSelection: TAction;
  aECopy: TAction;
  aECopyToFile: TAction;
  aECut: TAction;
  aEDelete: TAction;
  aEFind: TAction;
  aEFormatSQL: TAction;
  aEPaste: TAction;
  aEPasteFromFile: TAction;
  aERedo: TAction;
  aERename: TAction;
  aEReplace: TAction;
  aESelectAll: TAction;
  aETransfer: TAction;
  aEUndo: TAction;
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
  aVBrowser: TAction;
  aVBuilder: TAction;
  aVDiagram: TAction;
  aVExplorer: TAction;
  aVNavigator: TAction;
  aVObjects: TAction;
  aVIDE: TAction;
  aVRefresh: TAction;
  aVRefreshAll: TAction;
  aVEditor: TAction;
  aVEditor2: TAction;
  aVEditor3: TAction;
  aVSQLHistory: TAction;
  aVSQLLog: TAction;

implementation {***************************************************************}

uses
  ShlObj, ActiveX, CommCtrl, RichEdit,
  UITypes, StrUtils, Math,
  System.Win.Registry,
  DB, DBCommon, DBCommonTypes,
  StdActns, StdCtrls,
  uSession;

var
  CBTHook: HHOOK;
  MessageBoxCentered: Boolean;

procedure ConvertError(Sender: TObject; Text: string);
var
  FieldInfo: TFieldInfo;
  I: Integer;
  Msg: string;
begin
  Msg := '';

  if (Sender is TField) then
    for I := 0 to TField(Sender).DataSet.FieldCount - 1 do
      if (TField(Sender).DataSet.Fields[I].IsIndexField) then
      begin
        if (I > 0) then Msg := Msg + ', ';
        if ((TField(Sender).DataSet is TMySQLQuery) and not GetFieldInfo(TMySQLQuery(TField(Sender).DataSet).Fields[I].Origin, FieldInfo)) then
          Msg := Msg + TField(Sender).DataSet.Fields[I].FieldName
        else
        begin
          if (FieldInfo.DatabaseName <> '') then
            Msg := Msg + FieldInfo.DatabaseName + '.';
          if (FieldInfo.DatabaseName <> '') then
            Msg := Msg + FieldInfo.TableName + '.';
          Msg := Msg + FieldInfo.OriginalFieldName;
        end;
        if (TField(Sender).DataSet.Fields[I].AsString <> '') then
          Msg := Msg + '=' + TField(Sender).DataSet.Fields[I].AsString;
      end;

  if ((Msg = '') and (Sender is TField) and (TField(Sender).DataSet is TMySQLQuery)) then
  begin
    if (not GetFieldInfo(TField(Sender).Origin, FieldInfo)) then
      Msg := Msg + TField(Sender).DisplayLabel
    else
    begin
      if (FieldInfo.DatabaseName <> '') then
        Msg := Msg + FieldInfo.DatabaseName + '.';
      if (FieldInfo.DatabaseName <> '') then
        Msg := Msg + FieldInfo.TableName + '.';
      Msg := Msg + FieldInfo.OriginalFieldName;
    end;
    if (TField(Sender).AsString <> '') then
      Msg := Msg + '=' + TField(Sender).AsString;
  end;
  if (Msg <> '') then
    Msg := '  (' + Msg + ')' + #13#10 + #13#10;

  if (Sender is TMySQLBitField) then
    Msg := Preferences.LoadStr(866, Text) + Msg
  else if (Sender is TLargeintField) then
    Msg := Preferences.LoadStr(867, Text) + Msg
  else if (Sender is TMySQLBitField) then
    Msg := Preferences.LoadStr(866, Text) + Msg
  else if (Sender is TDateTimeField) then
    Msg := Preferences.LoadStr(585, Text) + Msg
  else if (Sender is TDateField) then
    Msg := Preferences.LoadStr(586, Text) + Msg
  else if ((Sender is TField) and (TField(Sender).DataType = ftTime)) then
    Msg := Preferences.LoadStr(587, Text) + Msg
  else if ((Sender is TSBaseField) and (TSBaseField(Sender).FieldType in [mfDate, mfDateTime])) then
    Msg := Preferences.LoadStr(586, Text) + Msg
  else
    Msg := Preferences.LoadStr(588, Text) + Msg;

  // Wenn Fehler mit raise erzeugt wird wird die Tabelle bei einem falschen Datum nicht im Data Browser angezeigt
  // Wenn Fehler als MsgBox angezeigt wird werden falsche Eingaben im Data Browser nicht abgefangen

  if ((Sender is TField) and (not TField(Sender).DataSet.Active or (TField(Sender).DataSet.State in [dsBrowse, dsEdit, dsInsert, dsInactive])) or (Sender is TSBaseField)) then
    MsgBox(Msg + ' ' + Preferences.LoadStr(657), Preferences.LoadStr(45), MB_OK + MB_ICONERROR)
  else
    raise EConvertError.Create(Msg);
end;

procedure DrawCloseBitmap(const Bitmap: Graphics.TBitmap; const Rect: TRect);
var
  I: Integer;
  Size: Integer;
  Width: Integer;
begin
  Size := Min(Rect.Width, Rect.Height);
  Width := (Size + GetSystemMetrics(SM_CXEDGE)) div 4;

  if (Width mod 2 = 0) then
  begin
    for I := 1 to Width div 2 do
      begin Bitmap.Canvas.MoveTo(Rect.Left + I, Rect.Top); Bitmap.Canvas.LineTo(Rect.Left + Size, Rect.Top + Size - I); end;
    Bitmap.Canvas.MoveTo(Rect.Left, Rect.Top); Bitmap.Canvas.LineTo(Rect.Left + Size - 1, Rect.Top + Size - 1);
    for I := 1 to (Width - 1) div 2 do
      begin Bitmap.Canvas.MoveTo(Rect.Left, Rect.Top + I); Bitmap.Canvas.LineTo(Rect.Left + Size - 1 - I, Rect.Top + Size - 1); end;
  end
  else
  begin
    for I := 1 to Width div 2 do
      begin Bitmap.Canvas.MoveTo(Rect.Left + I, Rect.Top); Bitmap.Canvas.LineTo(Rect.Left + Size, Rect.Top + Size - I); end;
    Bitmap.Canvas.MoveTo(Rect.Left, Rect.Top); Bitmap.Canvas.LineTo(Rect.Left + Size, Rect.Top + Size);
    for I := 1 to Width div 2 do
      begin Bitmap.Canvas.MoveTo(Rect.Left, Rect.Top + I); Bitmap.Canvas.LineTo(Rect.Left + Size - I, Rect.Top + Size); end;
  end;

  if (Width mod 2 = 0) then
  begin
    for I := 1 to (Width - 1) div 2 do
      begin Bitmap.Canvas.MoveTo(Rect.Left, Rect.Top + Size - 2 - I); Bitmap.Canvas.LineTo(Rect.Left + Size - 1 - I, Rect.Top - 1); end;
    Bitmap.Canvas.MoveTo(Rect.Left, Rect.Top + Size - 2); Bitmap.Canvas.LineTo(Rect.Left + Size - 1, Rect.Top - 1);
    for I := 1 to Width div 2 do
      begin Bitmap.Canvas.MoveTo(Rect.Left + I, Rect.Top + Size - 1 - I); Bitmap.Canvas.LineTo(Rect.Left + Size - 1 + I, Rect.Top - 1); end;
  end
  else
  begin
    for I := 1 to Width div 2 do
      begin Bitmap.Canvas.MoveTo(Rect.Left, Rect.Top + Size - 1 - I); Bitmap.Canvas.LineTo(Rect.Left + Size - I, Rect.Top - 1); end;
    Bitmap.Canvas.MoveTo(Rect.Left, Rect.Top + Size - 1); Bitmap.Canvas.LineTo(Rect.Left + Size, Rect.Top - 1);
    for I := 1 to Width div 2 do
      begin Bitmap.Canvas.MoveTo(Rect.Left + I, Rect.Top + Size - 1); Bitmap.Canvas.LineTo(Rect.Left + Size, Rect.Top + I - 1); end;
  end;
end;

function EditWordBreakProc(lpch: LPTSTR; ichCurrent: Integer; cch: Integer;
  code: Integer): Integer; stdcall;
label
  WBIsDelimiter, WBIsDelimiterTrue, WBIsDelimiterFalse,
  WBLeft, WBLeftL,
  WBRight, WBRightL,
  WBClassify, WBClassifyLinebreak, WBClassifyDelimiter, WBClassifyNormal,
  WBMoveWordLeft, WBMoveWordLeft1, WBMoveWordLeft2,
  WBMoveWordRight, WBMoveWordRight1, WBMoveWordRight2,
  WBLeftBreak, WBLeftBreakL,
  WBRightBreak, WBRightBreakL,
  WBUnknown,
  CheckLinebreak, CheckLinebreakYes,
  CheckDelimiter, CheckDelimiterL, CheckDelimiterNo, CheckDelimiterYes,
  FinishLeftRight, Finish;
const
  WB_CLASS_WHITESPACE = 0;
  WB_CLASS_LINEBREAK = 1;
  WB_CLASS_DELIMITER = 2;
  WB_CLASS_NORMALCHAR = 3;

  Delimiters: PChar = #9#10#13 + ' .,;';

  // Inside FLog there should no line wrap - so we have to overwrite
  // this function, to say: No word wrap at Delimiters - but Delimiters
  // are used for <Ctrl+Left> and <Ctrl+Right>.
  // Since this function will be called VERY often, it's written in assembler
asm
        PUSH EBX
        PUSH ESI
        PUSH EDI

        MOV ESI,lpch
        MOV EBX,ichCurrent
        SHL EBX,1

      WBIsDelimiter:
        CMP code,WB_ISDELIMITER          // WB_ISDELIMITER?
        JNE WBLeft                       // No!
        MOV AX,WORD PTR [ESI + EBX]
        CALL CheckDelimiter
        JE WBIsDelimiterTrue
      WBIsDelimiterFalse:
        MOV [Result],0
        JMP Finish
      WBIsDelimiterTrue:
        MOV [Result],-1
        JMP Finish

      WBLeft:
        CMP code,WB_LEFT                 // WB_LEFT?
        JNE WBRight                      // No!
      WBLeftL:
        CMP EBX,0
        SUB EBX,2
        JE FinishLeftRight
        MOV AX,[ESI + EBX]
        CALL CheckLinebreak
        JNE WBLeftL
        JMP FinishLeftRight

      WBRight:
        CMP code,WB_RIGHT                // code = WB_RIGHT?
        JNE WBClassify                   // No!
        SHL cch,1
      WBRightL:
        ADD EBX,2
        CMP EBX,cch
        JE FinishLeftRight
        MOV AX,[ESI + EBX]
        CALL CheckLinebreak
        JNE WBRightL
        JMP FinishLeftRight

      WBClassify:
        CMP code,WB_CLASSIFY             // WB_CLASSIFY?
        JNE WBMoveWordLeft               // No!
        MOV AX,[ESI + EBX]
      WBClassifyLinebreak:
        CALL CheckLinebreak
        JNE WBClassifyDelimiter
        MOV [Result],WB_CLASS_LINEBREAK or WBF_BREAKLINE
        JMP Finish
      WBClassifyDelimiter:
        CALL CheckDelimiter
        JNE WBClassifyNormal
        MOV [Result],WB_CLASS_DELIMITER
        JMP Finish
      WBClassifyNormal:
        MOV [Result],WB_CLASS_NORMALCHAR
        JMP Finish

      WBMoveWordLeft:
        CMP code,WB_MOVEWORDLEFT         // WB_MOVEWORDLEFT?
        JNE WBMoveWordRight              // No!
      WBMoveWordLeft1:
        CMP EBX,0
        JE FinishLeftRight
        SUB EBX,2
        MOV AX,[ESI + EBX]
        CALL CheckDelimiter
        JE WBMoveWordLeft1
      WBMoveWordLeft2:
        CMP EBX,0
        JE FinishLeftRight
        SUB EBX,2
        MOV AX,[ESI + EBX]
        CALL CheckDelimiter
        JNE WBMoveWordLeft2
        ADD EBX,2
        JMP FinishLeftRight

      WBMoveWordRight:
        CMP code,WB_MOVEWORDRIGHT        // WB_MOVEWORDRIGHT?
        JNE WBLeftBreak                  // No!
        SHL cch,1
      WBMoveWordRight1:
        ADD EBX,2
        CMP EBX,cch
        JE FinishLeftRight
        MOV AX,[ESI + EBX]
        CALL CheckDelimiter
        JNE WBMoveWordRight1
      WBMoveWordRight2:
        CALL CheckLinebreak
        JE FinishLeftRight
        ADD EBX,2
        CMP EBX,cch
        JE FinishLeftRight
        MOV AX,[ESI + EBX]
        CALL CheckDelimiter
        JE WBMoveWordRight2
        JMP FinishLeftRight

      WBLeftBreak:
        CMP code,WB_LEFTBREAK            // WB_LEFTBREAK?
        JNE WBRightBreak                 // No!
      WBLeftBreakL:
        CMP EBX,0
        JE FinishLeftRight
        SUB EBX,2
        MOV AX,[ESI + EBX]
        CALL CheckLinebreak
        JE WBLeftBreakL
        JMP FinishLeftRight

      WBRightBreak:
        CMP code,WB_RIGHTBREAK           // WB_RIGHTBREAK?
        JNE WBUnknown                    // No!
        SHL cch,1
      WBRightBreakL:
        ADD EBX,2
        CMP EBX,cch
        JE FinishLeftRight
        MOV AX,[ESI + EBX]
        CALL CheckLinebreak
        JE WBRightBreakL
        JMP FinishLeftRight

      WBUnknown:
        MOV [Result],0                   // Should never reached!
        JMP Finish

      // -------------------

      CheckLinebreak:
        CMP AX,10
        JE CheckLinebreakYes
        CMP AX,13
      CheckLinebreakYes:
        RET

      // -------------------

      CheckDelimiter:
        MOV EDI,Delimiters
      CheckDelimiterL:
        CMP WORD PTR [EDI],0
        JE CheckDelimiterNo
        CMP AX,[EDI]
        JE CheckDelimiterYes
        ADD EDI,2
        JMP CheckDelimiterL
      CheckDelimiterNo:
        CMP WORD PTR [EDI],1             // Clear ZF
      CheckDelimiterYes:
        RET

      // -------------------

      FinishLeftRight:
        SHR EBX,1
        MOV [Result],EBX

      Finish:
        POP EDI
        POP ESI
        POP EBX
end;

function FilterDescription(const Ext: string): string;
var
  Description: string;
  Key: string;
  Reg: TRegistry;
begin
  Key := ''; Description := '';
  Reg := TRegistry.Create();
  Reg.RootKey := HKEY_CLASSES_ROOT;
  if (Reg.OpenKey('.' + Ext, False)) then
  begin
    Key := Reg.ReadString('');
    Reg.CloseKey();
  end;
  if (Key <> '') and (Reg.OpenKeyReadOnly(Key)) then
  begin
    Description := Reg.ReadString('');
    Reg.CloseKey();
  end;
  FreeAndNil(Reg);

  if (Description = '') then
    if (LowerCase(Ext) = '*') then
      Description := Preferences.LoadStr(190)
    else if (LowerCase(Ext) = 'bmp') then
      Description := Preferences.LoadStr(868)
    else if (LowerCase(Ext) = 'html') then
      Description := Preferences.LoadStr(455)
    else if (LowerCase(Ext) = 'mdb') then
      Description := Preferences.LoadStr(695)
    else if (LowerCase(Ext) = 'accdb') then
      Description := Preferences.LoadStr(900)
    else if (LowerCase(Ext) = 'pdf') then
      Description := Preferences.LoadStr(890)
    else if (LowerCase(Ext) = 'sql') then
      Description := Preferences.LoadStr(184)
    else if (LowerCase(Ext) = 'txt') then
      Description := Preferences.LoadStr(350)
    else if (LowerCase(Ext) = 'xls') then
      Description := Preferences.LoadStr(801)
    else if (LowerCase(Ext) = 'xlsb') then
      Description := Preferences.LoadStr(901)
    else if (LowerCase(Ext) = 'xml') then
      Description := Preferences.LoadStr(456);

  Result := Description;
end;

function FindMenuItemByName(const Item: TMenuItem; const Name: string): TMenuItem;
var
  I: Integer;
begin
  Result := nil;

  if (Item <> nil) then
    if (Item.Name = Name) then
      Result := Item
    else
      for I := 0 to Item.Count - 1 do
        if (Result = nil) then
          Result := FindMenuItemByName(Item.Items[I], Name);
end;

function MainAction(const Name: string): TAction;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to MainActionList.ActionCount - 1 do
    if (not Assigned(Result)) then
      if ((MainActionList.Actions[I].Name = Name) and (MainActionList.Actions[I] is TAction)) then
        Result := TAction(MainActionList.Actions[I]);

  {$IFOPT R+}
    if (not Assigned(Result)) then
      raise EAccessViolation.CreateFMT('Action "%s" not found in action list "%s"', [Name, MainActionList.Name]);
  {$ENDIF}
end;

function MessageBox_Extended(const Text, Caption: string; const Flags: Longint): Integer;

type
  TMsgDlgBtn = (mbYes, mbYesToAll, mbNo, mbNoToAll, mbOK, mbCancel, mbAbort, mbRetry, mbIgnore,
    mbAll, mbHelp);
  TMsgDlgButtons = set of TMsgDlgBtn;

const
  CommandIDs: array[TMsgDlgBtn] of Integer = (
    IDYES, IDYESALL, IDNO, IDNOALL, IDOK, IDCANCEL, IDABORT, IDTRYAGAIN, IDIGNORE, IDALL,
    IDHELP);

  function GetAveCharSize(Canvas: TCanvas): TPoint;
  var
    I: Integer;
    Buffer: array[0..51] of Char;
    tm: TTextMetric;
  begin
    for I := 0 to 25 do Buffer[I] := Char(I + Ord('A'));
    for I := 0 to 25 do Buffer[I + 26] := Char(I + Ord('a'));
    GetTextMetrics(Canvas.Handle, tm);
    GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
    Result.X := (Result.X div 26 + 1) div 2;
    Result.Y := tm.tmHeight;
  end;

  function GetButtonCaption(MsgDlgBtn: TMsgDlgBtn): string;
  begin
    case MsgDlgBtn of
      mbYes:         Result := Preferences.LoadStr(74);
      mbYesToAll:    Result := Preferences.LoadStr(930);
      mbNo:          Result := Preferences.LoadStr(75);
      mbNoToAll:     Result := Preferences.LoadStr(931);
      mbOK:          Result := Preferences.LoadStr(29);
      mbCancel:      Result := Preferences.LoadStr(30);
      mbAbort:       Result := 'Abort';
      mbRetry:       Result := 'Retry';
      mbIgnore:      Result := 'Ignore';
      mbAll:         Result := Preferences.LoadStr(214);
      mbHelp:        Result := Preferences.LoadStr(167);
    end;
  end;

const
  mcHorzMargin = 6;
  mcVertMargin = 6;
  mcHorzSpacing = 10;
  mcVertSpacing = 10;
  mcButtonWidth = 50;
  mcButtonHeight = 14;
  mcButtonSpacing = 5;

var
  ALeft: Integer;
  ButtonCount: Integer;
  ButtonGroupWidth: Integer;
  ButtonHeight: Integer;
  ButtonRect: TRect;
  Buttons: TMsgDlgButtons;
  ButtonSpacing: Integer;
  ButtonWidth: Integer;
  CancelButton: TMsgDlgBtn;
  DialogUnits: TPoint;
  FButton: TButton;
  FIcon: TImage;
  FLabel: TLabel;
  Form: TForm;
  FPanel: TPanel;
  HorzMargin: Integer;
  HorzSpacing: Integer;
  IconName: PChar;
  IconTextHeight: Integer;
  IconTextWidth: Integer;
  LabelRect: TRect;
  MsgDlgBtn: TMsgDlgBtn;
  NonClientMetrics: TNonClientMetrics;
  VertMargin: Integer;
  VertSpacing: Integer;
  X: Integer;
begin
  case (Flags and $00000070) of
    MB_ICONHAND: IconName := IDI_HAND;
    MB_ICONQUESTION: IconName := IDI_QUESTION;
    MB_ICONEXCLAMATION: IconName := IDI_EXCLAMATION;
    MB_ICONASTERISK: IconName := IDI_ASTERISK;
    else IconName := nil;
  end;

  case (Flags and $00000007) of
    MB_OK: Buttons := [mbOk];
    MB_OKCANCEL: Buttons := [mbOk, mbCancel];
    MB_ABORTRETRYIGNORE: Buttons := [mbAbort, mbRetry, mbIgnore];
    MB_YESNOCANCEL: Buttons := [mbYes, mbNo, mbCancel];
    MB_YESNO: Buttons := [mbYes, mbNo];
    MB_RETRYCANCEL: Buttons := [mbRetry, mbCancel];
    MB_YESYESTOALLNOCANCEL: Buttons := [mbYes, mbYesToAll, mbNo, mbCancel];
    else Buttons := [];
  end;

  Form := TForm.CreateNew(Application);
  Form.BorderStyle := bsDialog;
  Form.BiDiMode := Application.BiDiMode;
  Form.Canvas.Font := Form.Font;
  Form.Position := poScreenCenter;
  Form.Caption := Caption;
  NonClientMetrics.cbSize := sizeof(NonClientMetrics);
  if (SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0)) then
  begin
    Form.Font.Charset := NonClientMetrics.lfMessageFont.lfCharSet;

    if (NonClientMetrics.lfMessageFont.lfPitchAndFamily and DEFAULT_PITCH <> 0) then
      Form.Font.Pitch := fpDefault
    else if (NonClientMetrics.lfMessageFont.lfPitchAndFamily and VARIABLE_PITCH <> 0) then
      Form.Font.Pitch := fpVariable
    else if (NonClientMetrics.lfMessageFont.lfPitchAndFamily and FIXED_PITCH <> 0) then
      Form.Font.Pitch := fpFixed;
    Form.Font.Height := NonClientMetrics.lfMessageFont.lfHeight;
    Form.Font.Name := NonClientMetrics.lfMessageFont.lfFaceName;
    Form.Font.Style := [];
    if (Boolean(NonClientMetrics.lfMessageFont.lfItalic)) then Form.Font.Style := Form.Font.Style + [fsItalic];
    if (Boolean(NonClientMetrics.lfMessageFont.lfUnderline)) then Form.Font.Style := Form.Font.Style + [fsUnderline];
    if (Boolean(NonClientMetrics.lfMessageFont.lfStrikeOut)) then Form.Font.Style := Form.Font.Style + [fsStrikeOut];
  end;


  DialogUnits := GetAveCharSize(Form.Canvas);
  HorzMargin := MulDiv(mcHorzMargin, DialogUnits.X, 4);
  VertMargin := MulDiv(mcVertMargin, DialogUnits.Y, 8);
  HorzSpacing := MulDiv(mcHorzSpacing, DialogUnits.X, 4);
  VertSpacing := MulDiv(mcVertSpacing, DialogUnits.Y, 8);
  ButtonWidth := MulDiv(mcButtonWidth, DialogUnits.X, 4);


  SetRect(LabelRect, 0, 0, Screen.Width div 4, Screen.Height div 2);
  DrawText(Form.Canvas.Handle, PChar(Text), Length(Text) + 1, LabelRect,
    DT_EXPANDTABS or DT_CALCRECT or DT_WORDBREAK or Form.DrawTextBiDiModeFlagsReadingOnly);
  IconTextWidth := LabelRect.Right;
  if (Assigned(IconName)) then
    Inc(IconTextWidth, HorzSpacing + GetSystemMetrics(SM_CXICON) + HorzMargin);
  IconTextHeight := Max(VertSpacing + GetSystemMetrics(SM_CYICON) + VertSpacing, LabelRect.Bottom);

  for MsgDlgBtn := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
  begin
    if MsgDlgBtn in Buttons then
    begin
      ButtonRect := Rect(0,0,0,0);
      DrawText(Form.Canvas.Handle, PChar(GetButtonCaption(MsgDlgBtn)), -1, ButtonRect,
        DT_CALCRECT or DT_LEFT or DT_SINGLELINE or Form.DrawTextBiDiModeFlagsReadingOnly);
      ButtonWidth := Max(ButtonRect.Right - ButtonRect.Left + 8, ButtonWidth);
    end;
  end;
  ButtonHeight := MulDiv(mcButtonHeight, DialogUnits.Y, 8);
  ButtonSpacing := MulDiv(mcButtonSpacing, DialogUnits.X, 4);

  ButtonCount := 0;
  for MsgDlgBtn := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
    if (MsgDlgBtn in Buttons) then Inc(ButtonCount);
  if (ButtonCount = 0) then
    ButtonGroupWidth := 0
  else
    ButtonGroupWidth := HorzSpacing + ButtonWidth * ButtonCount + ButtonSpacing * (ButtonCount - 1);

  Form.ClientWidth := HorzMargin + Max(IconTextWidth, ButtonGroupWidth) + HorzMargin;
  Form.ClientHeight := VertMargin + IconTextHeight + VertMargin + ButtonHeight + VertMargin;


  if (not CheckWin32Version(6)) then
    FPanel := nil
  else
  begin
    FPanel := TPanel.Create(Form);
    FPanel.BevelInner := bvNone;
    FPanel.BevelOuter := bvNone;
    FPanel.Color := clWindow;
    FPanel.Parent := Form;
    FPanel.SetBounds(0, 0, Form.ClientWidth, IconTextHeight + VertSpacing);
    Form.ClientHeight := Form.ClientHeight + VertMargin;
  end;

  if (Assigned(IconName)) then
  begin
    FIcon := TImage.Create(Form);
    if (Assigned(FPanel)) then
      FIcon.Parent := FPanel
    else
      FIcon.Parent := Form;
    FIcon.Picture.Icon.Handle := LoadIcon(0, IconName);
    FIcon.SetBounds(HorzMargin + HorzSpacing, VertMargin + (IconTextHeight - FIcon.Picture.Height) div 2, FIcon.Picture.Width, FIcon.Picture.Height);
  end;

  FLabel := TLabel.Create(Form);
  if (Assigned(FPanel)) then
    FLabel.Parent := FPanel
  else
    FLabel.Parent := Form;
  FLabel.WordWrap := True;
  FLabel.Caption := Text;
  FLabel.BoundsRect := LabelRect;
  FLabel.BiDiMode := Form.BiDiMode;
  ALeft := IconTextWidth - LabelRect.Right + HorzMargin;
  if FLabel.UseRightToLeftAlignment then
    ALeft := Form.ClientWidth - ALeft - FLabel.Width;
  FLabel.SetBounds(ALeft, VertMargin + (IconTextHeight - LabelRect.Bottom) div 2, LabelRect.Right, LabelRect.Bottom);

  if mbCancel in Buttons then
    CancelButton := mbCancel
  else if mbNo in Buttons then
    CancelButton := mbNo
  else
    CancelButton := mbOk;
  X := Form.ClientWidth - ButtonWidth * ButtonCount - ButtonSpacing * (ButtonCount - 1) - HorzMargin;
  for MsgDlgBtn := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
    if MsgDlgBtn in Buttons then
    begin
      FButton := TButton.Create(Form);
      FButton.Parent := Form;
      FButton.Caption := GetButtonCaption(MsgDlgBtn);
      FButton.ModalResult := CommandIDs[MsgDlgBtn];
      FButton.Cancel := MsgDlgBtn = CancelButton;
      FButton.SetBounds(X, Form.ClientHeight - VertMargin - ButtonHeight, ButtonWidth, ButtonHeight);

      Inc(X, ButtonWidth + ButtonSpacing);
    end;

    
  case (Flags and $00000050) of
    MB_ICONHAND,
    MB_ICONQUESTION,
    MB_ICONEXCLAMATION,
    MB_ICONASTERISK: MessageBeep(Flags and $00000050);
    else if (Flags and MB_OK <> 0) then MessageBeep(MB_OK);
  end;
  Result := Form.ShowModal();

  Form.Free();
end;

function CBTProc(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT stdcall;
var
  ClassName: array[0..256] of Char;
  MessageBoxRect: TRect;
  ActiveWindowRect: TRect;
begin
  if ((Code = HCBT_ACTIVATE)
    and (GetClassName(HWND(wParam), @ClassName, Length(ClassName)) > 0)
    and (lstrcmp(@ClassName, '#32770') = 0) // '#32770' is the class name of the MessageBox dialog
    and not MessageBoxCentered) then
  begin
    MessageBoxCentered := True;

    if (GetWindowRect(HWND(wParam), MessageBoxRect)
    and GetWindowRect(PCBTActivateStruct(lParam).hWndActive, ActiveWindowRect)) then
      SetWindowPos(HWND(wParam), 0,
        (ActiveWindowRect.Left + ActiveWindowRect.Right) div 2 - (MessageBoxRect.Right - MessageBoxRect.Left) div 2,
        (ActiveWindowRect.Top + ActiveWindowRect.Bottom) div 2 - (MessageBoxRect.Bottom - MessageBoxRect.Top) div 2,
        0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
  end;

  Result := CallNextHookEx(CBTHook, Code, wParam, lParam);
end;

function MsgBoxCheck(const Text: string; const Caption: string; uType: UINT;
  Default: Integer; RegVal: PChar): Integer;
type
  TSHMessageBoxCheck = function(hWnd: THandle; pszText, pszCaption: LPCTSTR;
    uType: UINT; iDefault: Integer; RegVal: LPCTSTR): Integer; stdcall;
var
  Handle: THandle;
  SHMessageBoxCheck: TSHMessageBoxCheck;
  Wnd: HWND;
begin
  Handle := LoadLibrary('shlwapi.dll');
  if (Handle = 0) then
    SHMessageBoxCheck := nil
  else
    SHMessageBoxCheck := GetProcAddress(Handle, PChar(191));
  if (Assigned(Screen.ActiveForm)) then
    Wnd := Screen.ActiveForm.Handle
  else if (Assigned(Application.MainForm)) then
    Wnd := Application.MainForm.Handle
  else
    Wnd := GetFocus();
  if (not Assigned(SHMessageBoxCheck)) then
    Result := MessageBox(Wnd, PChar(Text), PChar(Caption), uType)
  else
    Result := SHMessageBoxCheck(Wnd, PChar(Text), PChar(Caption), uType, Default, RegVal);

  if (Handle > 0) then
    FreeLibrary(Handle);
end;

function MsgBox(const Text: string; const Caption: string; const Flags: Longint): Integer;
var
  TopWindow: HWND;
  MsgBoxParams: TMsgBoxParams;
begin
  TopWindow := Application.ActiveFormHandle;

  if (Flags and MB_YESYESTOALLNOCANCEL = MB_YESYESTOALLNOCANCEL) then
    Result := MessageBox_Extended(Text, Caption, Flags or MB_APPLMODAL)
  else
  begin
    ZeroMemory(@MsgBoxParams, SizeOf(MsgBoxParams));
    MsgBoxParams.cbSize := SizeOf(MsgBoxParams);
    if (Assigned(Screen.ActiveForm)) then
      MsgBoxParams.hwndOwner := Screen.ActiveForm.Handle
    else if (Assigned(Application.MainForm)) then
      MsgBoxParams.hwndOwner := Application.MainForm.Handle
    else
      MsgBoxParams.hwndOwner := GetFocus();
    MsgBoxParams.hInstance := HInstance;
    MsgBoxParams.lpszText := PChar(Text);
    MsgBoxParams.lpszCaption := PChar(Caption);
    MsgBoxParams.dwStyle := Flags or MB_APPLMODAL;
    MsgBoxParams.lpszIcon := nil;
    MsgBoxParams.lpfnMsgBoxCallback := nil;
    MsgBoxParams.dwLanguageId := Preferences.Language.LanguageId;

    MessageBoxCentered := False;
    {$IFNDEF Debug}
    CBTHook := SetWindowsHookEx(WH_CBT, CBTProc, 0, GetCurrentThreadId());
    {$ENDIF}

    Result := MessageBoxIndirect(MsgBoxParams);

    {$IFNDEF Debug}
    UnhookWindowsHookEx(CBTHook);
    {$ENDIF}
  end;
  MsgBoxHelpContext := 0;

  SetForegroundWindow(TopWindow);
end;

procedure SetControlCursor(const Control: TControl; const Cursor: TCursor);
var
  I: Integer;
begin
  if (Control is TWinControl) then
    for I := 0 to TWinControl(Control).ControlCount - 1 do
      SetControlCursor(TWinControl(Control).Controls[I], Cursor);

  Control.Cursor := Cursor;
end;

procedure SetToolBarHints(const ToolBar: TToolBar);
var
  I: Integer;
begin
  for I := 0 to ToolBar.ButtonCount - 1 do
    if (Assigned(ToolBar.Buttons[I].Action) and (TAction(ToolBar.Buttons[I].Action).Caption <> '')) then
    begin
      if (not (ToolBar.Buttons[I] is TToolButton)) then
        ToolBar.Buttons[I].Hint := TAction(ToolBar.Buttons[I].Action).Caption
      else if (ToolBar.Buttons[I].Action is TAction) then
        TToolButton(ToolBar.Buttons[I]).Hint := TAction(ToolBar.Buttons[I].Action).Caption
      else if (ToolBar.Buttons[I].Action is TWindowClose) then
        TToolButton(ToolBar.Buttons[I]).Hint := TWindowClose(ToolBar.Buttons[I].Action).Caption
      else if (ToolBar.Buttons[I].Action is TEditCut) then
        TToolButton(ToolBar.Buttons[I]).Hint := TEditCut(ToolBar.Buttons[I].Action).Caption
      else if (ToolBar.Buttons[I].Action is TEditCopy) then
        TToolButton(ToolBar.Buttons[I]).Hint := TEditCopy(ToolBar.Buttons[I].Action).Caption
      else if (ToolBar.Buttons[I].Action is TEditPaste) then
        TToolButton(ToolBar.Buttons[I]).Hint := TEditPaste(ToolBar.Buttons[I].Action).Caption
      else if (ToolBar.Buttons[I].Action is TEditSelectAll) then
        TToolButton(ToolBar.Buttons[I]).Hint := TEditSelectAll(ToolBar.Buttons[I].Action).Caption
      else if (ToolBar.Buttons[I].Action is TEditUndo) then
        TToolButton(ToolBar.Buttons[I]).Hint := TEditUndo(ToolBar.Buttons[I].Action).Caption
      else if (ToolBar.Buttons[I].Action is TEditDelete) then
        TToolButton(ToolBar.Buttons[I]).Hint := TEditDelete(ToolBar.Buttons[I].Action).Caption
      else
        TToolButton(ToolBar.Buttons[I]).Hint := TAction(ToolBar.Buttons[I].Action).Caption;

      if (Pos(#9, TToolButton(ToolBar.Buttons[I]).Hint) > 0) then
        TToolButton(ToolBar.Buttons[I]).Hint := Copy(TToolButton(ToolBar.Buttons[I]).Hint, 1, Pos(#9, TToolButton(ToolBar.Buttons[I]).Hint) - 1);
    end;
end;

function ShowEnabledItems(const Item: TMenuItem): Boolean;
var
  I: Integer;
begin
  if (Item.Count = 0) then
    Item.Visible := Item.Enabled and (Assigned(Item.OnClick) or (Assigned(Item.Action) and TEditAction(Item.Action).Enabled))
  else
  begin
    Item.Visible := False;
    for I := 0 to Item.Count - 1 do
      Item.Visible := ShowEnabledItems(Item.Items[I]) or Item.Visible;
    Item.Enabled := Item.Visible;
  end;
  if (Item.Caption = '-') then
    Item.Hint := ''
  else if (Pos(#9, Item.Caption) > 0) then
    Item.Hint := Copy(Item.Caption, 1, Pos(#9, Item.Caption) - 1)
  else
    Item.Hint := Item.Caption;
  Item.Default := Item.Default and Item.Visible;

  Result := Item.Visible and (Item.Caption <> '-');
end;

function SizeToStr(const Size: Int64): string;
begin
  if (Size < 10 * 1024) then
    Result := FormatFloat('#,##0 B', Size, LocaleFormatSettings)
  else if (Size < 10 * 1024 * 1024) then
    Result := FormatFloat('#,##0 KB', Size div 1024, LocaleFormatSettings)
  else if (Size < 10737418240) then
    Result := FormatFloat('#,##0 MB', Size div 1024 div 1024, LocaleFormatSettings)
  else
    Result := FormatFloat('#,##0 GB', Size div 1024 div 1024 div 1024, LocaleFormatSettings);
end;

function StrToInt(const S: string): Integer;
var
  Str: string;
begin
  Str := S;
  while Pos(LocaleFormatSettings.ThousandSeparator, Str) > 0 do
    Delete(Str, Pos(LocaleFormatSettings.ThousandSeparator, Str), 1);
  if (Str = '') then
    Result := 0
  else
    Result := SysUtils.StrToInt(Str);
end;

function TryStrToInt(const S: string; out Value: Integer): Boolean;
var
  Str: string;
begin
  Str := S;
  while Pos(LocaleFormatSettings.ThousandSeparator, Str) > 0 do
    Delete(Str, Pos(LocaleFormatSettings.ThousandSeparator, Str), 1);
  if (Str = '') then
    begin Value := 0; Result := True; end
  else
    Result := SysUtils.TryStrToInt(Str, Value);
end;

initialization
  LocaleFormatSettings := TFormatSettings.Create(LOCALE_USER_DEFAULT);

  DurationFormatSettings := TFormatSettings.Create(LOCALE_SYSTEM_DEFAULT);
  DurationFormatSettings.TimeAMString := '';
  DurationFormatSettings.TimePMString := '';
  DurationFormatSettings.ShortTimeFormat := 'hh:mm';
  DurationFormatSettings.LongTimeFormat := 'hh:mm:ss';

  Screen.Cursors[crHandPoint] := LoadCursor(0, IDC_HAND);
  Screen.Cursors[crSQLWait] := LoadCursor(0, IDC_WAIT);
end.


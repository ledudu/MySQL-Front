unit uDImport;

interface {********************************************************************}

uses
  Windows, Messages, RichEdit,
  SysUtils, Classes, Contnrs,
  DB,
  Graphics, Controls, Forms, Dialogs, ComCtrls, ExtCtrls, StdCtrls, Consts,
  ComCtrls_Ext, Forms_Ext, StdCtrls_Ext, ExtCtrls_Ext, Dialogs_Ext,
  MySQLDB,
  uSession, uTools, uPreferences,
  uBase;

const
  LargeSQLScriptSize = 100 * 1024;

type
  TLoadFromStream = procedure(Stream: TStream) of object;

  TDImport = class (TForm_Ext)
    FBBack: TButton;
    FBCancel: TButton;
    FBForward: TButton;
    FBHelp: TButton;
    FCharset: TComboBox_Ext;
    FCollation: TComboBox_Ext;
    FCSVHeadline: TCheckBox;
    FCSVPreview: TListView;
    FData: TCheckBox;
    FDelimiter: TEdit;
    FDelimiterChar: TRadioButton;
    FDelimiterTab: TRadioButton;
    FDestinationField1: TComboBox_Ext;
    FDoneObjects: TLabel;
    FDoneRecords: TLabel;
    FDoneTime: TLabel;
    FEngine: TComboBox_Ext;
    FEntieredObjects: TLabel;
    FEntieredRecords: TLabel;
    FEntieredTime: TLabel;
    FErrorMessages: TRichEdit;
    FErrors: TLabel;
    FInsert: TRadioButton;
    FInsertOrUpdate: TRadioButton;
    FLCharset: TLabel;
    FLCollation: TLabel;
    FLCSVHeadline: TLabel;
    FLDelimiter: TLabel;
    FLDestinationFields: TLabel;
    FLDone: TLabel;
    FLEngine: TLabel;
    FLEntiered: TLabel;
    FLErrors: TLabel;
    FLProgressObjects: TLabel;
    FLProgressRecords: TLabel;
    FLProgressTime: TLabel;
    FLQuoteValues: TLabel;
    FLReferrer1: TLabel;
    FLRowFormat: TLabel;
    FLSourceFields: TLabel;
    FLStmtType: TLabel;
    FLWhat: TLabel;
    FProgressBar: TProgressBar;
    FQuoteChar: TEdit;
    FQuoteNothing: TRadioButton;
    FQuoteStrings: TRadioButton;
    FReplace: TRadioButton;
    FRowFormat: TComboBox_Ext;
    FSourceField1: TEdit;
    FSourceField2: TEdit;
    FStructure: TCheckBox;
    FTables: TListView;
    FUpdate: TRadioButton;
    GCSVHow: TGroupBox_Ext;
    GCSVPreview: TGroupBox_Ext;
    GErrorMessages: TGroupBox_Ext;
    GFields: TGroupBox_Ext;
    GProgress: TGroupBox_Ext;
    GStmtType: TGroupBox_Ext;
    GStructure: TGroupBox_Ext;
    GTables: TGroupBox_Ext;
    GWhat: TGroupBox_Ext;
    OpenDialog: TOpenDialog_Ext;
    PageControl: TPageControl;
    PCSVPreview: TPanel_Ext;
    PDelimiter: TPanel_Ext;
    PErrorMessages: TPanel_Ext;
    PQuoting: TPanel_Ext;
    PSQLWait: TPanel_Ext;
    PTables: TPanel_Ext;
    ScrollBox: TScrollBox;
    Sizer: TRadioButton;
    TSCSVOptions: TTabSheet;
    TSExecute: TTabSheet;
    TSFields: TTabSheet;
    TSStmtType: TTabSheet;
    TSTables: TTabSheet;
    TSWhat: TTabSheet;
    FLInsertUpdate: TLabel;
    procedure FBBackClick(Sender: TObject);
    procedure FBForwardClick(Sender: TObject);
    procedure FBHelpClick(Sender: TObject);
    procedure FCharsetChange(Sender: TObject);
    procedure FCSVKeyPress(Sender: TObject; var Key: Char);
    procedure FCSVPreviewUpdate(Sender: TObject);
    procedure FDelimiterClick(Sender: TObject);
    procedure FDelimiterKeyPress(Sender: TObject; var Key: Char);
    procedure FDestinationFieldChange(Sender: TObject);
    procedure FFieldExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FQuoteClick(Sender: TObject);
    procedure FQuoteKeyPress(Sender: TObject; var Key: Char);
    procedure FSelectGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure FTablesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FTablesDblClick(Sender: TObject);
    procedure FTablesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ScrollBoxResize(Sender: TObject);
    procedure TSExecuteShow(Sender: TObject);
    procedure TSFieldsShow(Sender: TObject);
    procedure TSStmtTypeShow(Sender: TObject);
    procedure TSTablesShow(Sender: TObject);
    procedure TSWhatShow(Sender: TObject);
    procedure WhatClick(Sender: TObject);
    procedure WhatKeyPress(Sender: TObject; var Key: Char);
    procedure TSExecuteResize(Sender: TObject);
  type
    TTableName = class
    private
      FSourceName: string;
      function GetCaption(): string;
      function GetTableName(): string;
    public
      constructor Create(const ASourceName: string);
      property Caption: string read GetCaption;
      property TableName: string read GetTableName;
      property SourceName: string read FSourceName;
    end;
    TTableNames = class(TList)
    private
      function GetTableName(Index: Integer): TTableName; inline;
    public
      procedure Add(const SourceName: string);
      procedure Clear(); override;
      property TableName[Index: Integer]: TTableName read GetTableName; default;
    end;
  private
    Database: TSDatabase;
    FDestinationFields: array of TComboBox_Ext;
    FLReferrers: array of TLabel;
    FSourceFields: array of TEdit;
    Import: TTImport;
Progress: string; // Debug 2017-01-27
    ProgressInfos: TTool.TProgressInfos;
    Space: Integer;
    TableNames: TTableNames;
    TerminateTime: TDateTime;
    Wanted: record
      Page: TTabSheet;
    end;
    procedure CheckActivePageChange(const ActivePage: TTabSheet);
    procedure ClearTSFields(Sender: TObject);
    procedure CMSysFontChanged(var Message: TMessage); message CM_SYSFONTCHANGED;
    procedure CreateImport();
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    function GetDataSource(): Boolean;
    function GetFilename(): Boolean;
    function OnError(const Details: TTool.TErrorDetails): TDataAction;
    procedure OnTerminate(Sender: TObject);
    procedure OnUpdate(const AProgressInfos: TTool.TProgressInfos);
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
    procedure UMPostAfterExecuteSQL(var Message: TMessage); message UM_POST_AFTEREXECUTESQL;
    procedure UMPostShow(var Message: TMessage); message UM_POST_SHOW;
    procedure UMTerminate(var Message: TMessage); message UM_TERMINATE;
    procedure UMToolError(var Message: TMessage); message UM_TOOL_ERROR;
    procedure UMUpdateProgressInfo(var Message: TMessage); message UM_UPDATEPROGRESSINFO;
    procedure WMHelp(var Message: TWMHelp); message WM_HELP;
  public
    CodePage: Cardinal;
    Filename: TFileName;
    FNavigator: PPointer; // Debug 2017-01-25
    ImportType: TImportType;
    Session: TSSession;
    SObject: TSObject;
    Window: TForm;
    function Execute(): Boolean;
  end;

function DImport(): TDImport;

implementation {***************************************************************}

{$R *.dfm}

uses
  CommDlg, Dlgs,
  Math, StrUtils, SysConst,
  SQLUtils, CSVUtils,
uDeveloper,
  uDLogin, uDODBC;

const
  ImportBufferSize = 1024 * 1024;
  STR_LEN = 128;

var
  FDImport: TDImport;

function DImport(): TDImport;
begin
  if (not Assigned(FDImport)) then
  begin
    Application.CreateForm(TDImport, FDImport);
    FDImport.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDImport;
end;

{ TDImport.TTableName *********************************************************}

constructor TDImport.TTableName.Create(const ASourceName: string);
begin
  inherited Create();

  FSourceName := ASourceName;
end;

function TDImport.TTableName.GetCaption(): string;
begin
  if (DImport.ImportType <> itExcelFile) then
    Result := SourceName
  else if (Pos('$', SourceName) = Length(SourceName)) then
    Result := LeftStr(SourceName, Length(SourceName) - 1)
  else
    Result := LeftStr(SourceName, Pos('$', SourceName) - 1) + ' (' + RightStr(SourceName, Length(SourceName) - Pos('$', SourceName)) + ')';
end;

function TDImport.TTableName.GetTableName(): string;
begin
  if (DImport.ImportType <> itExcelFile) then
    Result := SourceName
  else if (Pos('$', SourceName) = Length(SourceName)) then
    Result := LeftStr(SourceName, Length(SourceName) - 1)
  else
    Result := LeftStr(SourceName, Pos('$', SourceName) - 1) + '_' + RightStr(SourceName, Length(SourceName) - Pos('$', SourceName));

  Result := DImport.Session.ApplyIdentifierName(Result);
end;

{ TDImport.TTableNames ********************************************************}

procedure TDImport.TTableNames.Add(const SourceName: string);
begin
  inherited Add(TTableName.Create(SourceName));
end;

procedure TDImport.TTableNames.Clear();
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TableName[I].Free();

  inherited;
end;

function TDImport.TTableNames.GetTableName(Index: Integer): TTableName;
begin
  Result := TTableName(Items[Index]);
end;

{ TDImport ********************************************************************}

procedure TDImport.CheckActivePageChange(const ActivePage: TTabSheet);
var
  I: Integer;
  NextActivePageIndex: Integer;
begin
  NextActivePageIndex := -1;
  if (Assigned(ActivePage)) then
    for I := PageControl.PageCount - 1 downto ActivePage.PageIndex + 1 do
      if (PageControl.Pages[I].Enabled) then
        NextActivePageIndex := I;
  if (NextActivePageIndex >= 0) then
    for I := NextActivePageIndex + 1 to PageControl.PageCount - 1 do
      PageControl.Pages[I].Enabled := False;

  FBBack.Enabled := False;
  if (Assigned(ActivePage)) then
    for I := ActivePage.PageIndex - 1 downto 0 do
      FBBack.Enabled := FBBack.Enabled or PageControl.Pages[I].Enabled;
  if ((NextActivePageIndex < TSExecute.PageIndex) and (ActivePage <> TSExecute)) then
    FBForward.Caption := Preferences.LoadStr(229) + ' >'
  else
    FBForward.Caption := Preferences.LoadStr(174);
  FBForward.Enabled := NextActivePageIndex >= 0;
  FBCancel.Caption := Preferences.LoadStr(30);
  FBCancel.ModalResult := mrCancel;
end;

procedure TDImport.ClearTSFields(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to Length(FSourceFields) - 1 do
    FSourceFields[I].Free();
  SetLength(FSourceFields, 0);
  for I := 0 to Length(FLReferrers) - 1 do
    FLReferrers[I].Free();
  SetLength(FLReferrers, 0);
  for I := 0 to Length(FDestinationFields) - 1 do
    FDestinationFields[I].Free();
  SetLength(FDestinationFields, 0);
end;

procedure TDImport.CMSysFontChanged(var Message: TMessage);
begin
  inherited;

  FErrorMessages.Font := Font;

  FDelimiter.Left := FDelimiterChar.Left + Sizer.Width + PageControl.Canvas.TextWidth(FDelimiterChar.Caption);
  FQuoteChar.Left := FQuoteStrings.Left + Sizer.Width + PageControl.Canvas.TextWidth(FQuoteStrings.Caption);
end;

procedure TDImport.CreateImport();
begin
  case (ImportType) of
    itSQLFile: Import := TTImportSQL.Create(Filename, CodePage, Session, Database);
    itTextFile: Import := TTImportText.Create(Filename, CodePage, Session, Database);
    itAccessFile: Import := TTImportAccess.Create(Session, Database, Filename);
    itExcelFile: Import := TTImportExcel.Create(Session, Database, Filename);
    itODBC: Import := TTImportODBC.Create(Session, Database, DODBC.DataSource, DODBC.Username, DODBC.Password);
    else raise ERangeError.Create('ImportType: ' + IntToStr(Ord(ImportType)));
  end;
end;

function TDImport.Execute(): Boolean;
begin
  // Debug 2017-02-19
  if (Assigned(FNavigator) and not Assigned(FNavigator^)) then
    raise EAssertionFailed.Create(SRangeError);

  Progress := 'a';

  ModalResult := mrNone;

  if ((ImportType in [itSQLFile, itTextFile, itAccessFile, itExcelFile]) and (Filename = '')) then
    if (not GetFilename()) then
      ModalResult := mrCancel;
  if (ImportType in [itODBC]) then
    if (not GetDataSource()) then
      ModalResult := mrCancel;

  if (ModalResult = mrCancel) then
    Result := False
  else
  begin
    Progress := Progress + 'b';
    Result := ShowModal() = mrOk;
    Progress := Progress + 'c'
  end;

  Progress := Progress + 'd';
end;

procedure TDImport.FBBackClick(Sender: TObject);
var
  PageIndex: Integer;
begin
  for PageIndex := PageControl.ActivePageIndex - 1 downto 0 do
    if (PageControl.Pages[PageIndex].Enabled) then
    begin
      PageControl.ActivePageIndex := PageIndex;
      exit;
    end;
end;

procedure TDImport.FBForwardClick(Sender: TObject);
var
  PageIndex: Integer;
begin
  for PageIndex := PageControl.ActivePageIndex + 1 to PageControl.PageCount - 1 do
    if (PageControl.Pages[PageIndex].Enabled) then
    begin
      PageControl.ActivePageIndex := PageIndex;
      exit;
    end;
end;

procedure TDImport.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDImport.FCSVKeyPress(Sender: TObject; var Key: Char);
begin
  FCSVPreviewUpdate(Sender);
end;

procedure TDImport.FCSVPreviewUpdate(Sender: TObject);
var
  Column: TListColumn;
  I: Integer;
  Item: TListItem;
  MissingFieldname: Boolean;
  Values: TSQLStrings;
begin
  if (Visible) then
  begin
    FCSVPreview.DisableAlign(); FCSVPreview.Items.BeginUpdate();
    FCSVPreview.Columns.Clear();
    FCSVPreview.Items.Clear();

    CreateImport();

    if (Assigned(Import)) then
    begin
      if (FDelimiterTab.Checked) then
        TTImportText(Import).Delimiter := #9
      else if (FDelimiter.Text = '') then
        TTImportText(Import).Delimiter := #0
      else
        TTImportText(Import).Delimiter := FDelimiter.Text[1];
      if (not FQuoteStrings.Checked) or (FQuoteChar.Text = '') then
        TTImportText(Import).Quoter := #0
      else
        TTImportText(Import).Quoter := FQuoteChar.Text[1];
      TTImportText(Import).UseHeadLine := FCSVHeadline.Checked;
      TTImportText(Import).Open();

      MissingFieldname := False;
      for I := 0 to TTImportText(Import).HeadlineNameCount - 1 do
      begin
        Column := FCSVPreview.Columns.Add();
        Column.Caption := TTImportText(Import).HeadlineNames[I];
        if (not MissingFieldname and (Column.Caption = '')) then
        begin
          MsgBox(Preferences.LoadStr(942, IntToStr(I + 1)), Preferences.LoadStr(45), MB_OK + MB_ICONERROR);
          MissingFieldname := True;
        end;
      end;

      Item := nil;
      while ((FCSVPreview.Items.Count < 10) and TTImportText(Import).GetPreviewValues(nil, Values)) do
        for I := 0 to Min(Length(Values), FCSVPreview.Columns.Count) - 1 do
          if (I = 0) then
          begin
            Item := FCSVPreview.Items.Add();
            Item.Caption := Values[I];
          end
          else
            Item.SubItems.Add(Values[I]);

      for I := 0 to FCSVPreview.Columns.Count - 1 do
        FCSVPreview.Column[I].AutoSize := True;

      TTImportText(Import).Close();
      SetLength(Values, 0);
    end;

    FCSVPreview.Items.EndUpdate(); FCSVPreview.EnableAlign();

    ClearTSFields(Sender);

    FTables.Items.BeginUpdate();
    FTables.Items.Clear();
    FTables.Items.EndUpdate();

    if (not FDelimiterTab.Checked and (FDelimiter.Text = '') or not FQuoteNothing.Checked and (FQuoteChar.Text = '')) then
    begin
      TSFields.Enabled := False;
      TSWhat.Enabled := False;
    end
    else
    begin
      TSFields.Enabled := (SObject is TSTable);
      TSWhat.Enabled := not TSFields.Enabled;
    end;

    CheckActivePageChange(TSCSVOptions);
  end;
end;

procedure TDImport.FCharsetChange(Sender: TObject);
var
  Charset: TSCharset;
  I: Integer;
begin
  Charset := Session.CharsetByName(FCharset.Text);

  FCollation.Items.Clear();
  if (Assigned(Session.Collations)) then
  begin
    for I := 0 to Session.Collations.Count - 1 do
      if (Assigned(Charset) and (Session.Collations[I].Charset = Charset)) then
        FCollation.Items.Add(Session.Collations[I].Name);
    if (Assigned(Charset) and Assigned(Charset.DefaultCollation)) then
      FCollation.ItemIndex := FCollation.Items.IndexOf(Charset.DefaultCollation.Caption);
  end;
  FCollation.Enabled := FCharset.Text <> ''; FLCollation.Enabled := FCollation.Enabled;
end;

procedure TDImport.FDelimiterClick(Sender: TObject);
begin
  FDelimiter.Enabled := FDelimiterChar.Checked;
  FCSVPreviewUpdate(Sender);
end;

procedure TDImport.FDelimiterKeyPress(Sender: TObject; var Key: Char);
begin
  FDelimiterClick(Sender);
end;

procedure TDImport.FDestinationFieldChange(Sender: TObject);
var
  I: Integer;
begin
  TSStmtType.Enabled := False;
  for I := 0 to Length(FDestinationFields) - 1 do
    if ((FSourceFields[I].Text <> '') and (FDestinationFields[I].ItemIndex > 0)) then
      TSStmtType.Enabled := True;

  CheckActivePageChange(TSFields);
end;

procedure TDImport.FFieldExit(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to Length(FDestinationFields) - 1 do
    if ((Sender is TComboBox) and (FDestinationFields[I] <> Sender) and (FDestinationFields[I].ItemIndex = TComboBox(Sender).ItemIndex)) then
      FDestinationFields[I].ItemIndex := 0;
end;

procedure TDImport.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (not Visible) then
    // I can't find out, why this happens. Seems to be executed while closeing
    // the application, but why???
  else
  begin
    Progress := Progress + 'f';

    if (Assigned(FNavigator) and not Assigned(FNavigator^)) then
      raise EAssertionFailed.Create('Visible: ' + BoolToStr(Visible, True) + #13#10
      + 'ModalResult: ' + IntToStr(Ord(ModalResult)) + #13#10
      + 'Assigned(FNavigator): ' + BoolToStr(Assigned(FNavigator^), True) + #13#10
      + 'Assigned(Import): ' + BoolToStr(Assigned(Import), True) + #13#10
      + 'Import.Terminated: ' + BoolToStr(Assigned(Import) and Import.Terminated, True) + #13#10
      + 'Progress: ' + Progress);

    if (Assigned(Import) and Import.Suspended) then
    begin
      Import.Free();
      Import := nil;
    end;


    if (Assigned(FNavigator) and not Assigned(FNavigator^)) then
      raise EAssertionFailed.Create('Visible: ' + BoolToStr(Visible, True) + #13#10
      + 'ModalResult: ' + IntToStr(Ord(ModalResult)) + #13#10
      + 'Assigned(FNavigator): ' + BoolToStr(Assigned(FNavigator^), True) + #13#10
      + 'Assigned(Import): ' + BoolToStr(Assigned(Import), True) + #13#10
      + 'Import.Terminated: ' + BoolToStr(Assigned(Import) and Import.Terminated, True) + #13#10
      + 'Progress: ' + Progress);


    if (Assigned(Import)) then
    begin
      Progress := Progress + 'g';
      Import.Terminate();
      TerminateTime := Now();
      CanClose := False;
    end
    else
    begin
      Progress := Progress + 'h';
      CanClose := True;
    end;

    FBCancel.Enabled := CanClose;
    if (FBCancel.Enabled) then
      EnableMenuItem(GetSystemMenu(Handle, FALSE), SC_CLOSE, MF_BYCOMMAND or MF_ENABLED)
    else
      EnableMenuItem(GetSystemMenu(Handle, FALSE), SC_CLOSE, MF_BYCOMMAND or MF_DISABLED);

    if (Assigned(FNavigator) and not Assigned(FNavigator^)) then
      raise EAssertionFailed.Create('Visible: ' + BoolToStr(Visible, True) + #13#10
      + 'ModalResult: ' + IntToStr(Ord(ModalResult)) + #13#10
      + 'Assigned(FNavigator): ' + BoolToStr(Assigned(FNavigator^), True) + #13#10
      + 'Assigned(Import): ' + BoolToStr(Assigned(Import), True) + #13#10
      + 'Import.Terminated: ' + BoolToStr(Assigned(Import) and Import.Terminated, True) + #13#10
      + 'Progress: ' + Progress);

    Progress := Progress + 'i';
  end;
end;

procedure TDImport.FormCreate(Sender: TObject);
begin
  Space := (FLEntiered.Left + FLEntiered.Width) - (FLDone.Left + FLDone.Width);

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  if ((Preferences.Import.Width >= Width) and (Preferences.Import.Height >= Height)) then
  begin
    Width := Preferences.Import.Width;
    Height := Preferences.Import.Height;
  end;

  FTables.SmallImages := Preferences.Images;

  Import := nil;

  FCSVHeadline.Checked := Preferences.Import.CSV.Headline;
  FDelimiterTab.Checked := Preferences.Import.CSV.DelimiterType = dtTab;
  FDelimiterChar.Checked := Preferences.Import.CSV.DelimiterType = dtChar;
  FDelimiter.Text := Preferences.Import.CSV.Delimiter;
  FQuoteNothing.Checked := Preferences.Import.CSV.Quote = qtNone;
  FQuoteStrings.Checked := Preferences.Import.CSV.Quote = qtStrings;
  FQuoteChar.Text := Preferences.Import.CSV.QuoteChar;

  SendMessage(FErrorMessages.Handle, EM_SETTEXTMODE, TM_PLAINTEXT, 0);
  SendMessage(FErrorMessages.Handle, EM_SETWORDBREAKPROC, 0, LPARAM(@EditWordBreakProc));

  PageControl.ActivePage := nil;
end;

procedure TDImport.FormHide(Sender: TObject);
begin
  if (Assigned(Import)) then
  begin
    SendToDeveloper('Visible: ' + BoolToStr(Visible, True) + #13#10
      + 'ModalResult: ' + IntToStr(Ord(ModalResult)) + #13#10
      + 'Assigned(FNavigator): ' + BoolToStr(Assigned(FNavigator^), True) + #13#10
      + 'Assigned(Import): ' + BoolToStr(Assigned(Import), True) + #13#10
      + 'Import.Terminated: ' + BoolToStr(Assigned(Import) and Import.Terminated, True) + #13#10
      + 'Progress: ' + Progress);

    Import.WaitFor();
    Import.Free();
    Import := nil;
  end;

  Progress := Progress + 'j';

  if (Assigned(FNavigator) and not Assigned(FNavigator^)
    or Visible
    or Assigned(Import)) then
    raise EAssertionFailed.Create('Visible: ' + BoolToStr(Visible, True) + #13#10
      + 'ModalResult: ' + IntToStr(Ord(ModalResult)) + #13#10
      + 'Assigned(FNavigator): ' + BoolToStr(Assigned(FNavigator^), True) + #13#10
      + 'Assigned(Import): ' + BoolToStr(Assigned(Import), True) + #13#10
      + 'Import.Terminated: ' + BoolToStr(Assigned(Import) and Import.Terminated, True) + #13#10
      + 'Progress: ' + Progress + #13#10
      + 'csDestroying: ' + BoolToStr(csDestroying in ComponentState, True) + #13#10
      + 'TimeToHide: ' + DateTimeToStr(Now() - TerminateTime));

  Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.Import.Width := Width;
  Preferences.Import.Height := Height;

  if (ModalResult = mrOk) then
  begin
    case (ImportType) of
      itTextFile:
        begin
          Preferences.Import.CSV.Headline := FCSVHeadline.Checked;
          if (FDelimiterTab.Checked) then
            Preferences.Import.CSV.DelimiterType := dtTab
          else if (FDelimiterChar.Checked) then
            Preferences.Import.CSV.DelimiterType := dtChar;
          Preferences.Import.CSV.Delimiter := FDelimiter.Text;
          Preferences.Import.CSV.QuoteChar := FQuoteChar.Text;
          if (FQuoteNothing.Checked) then
            Preferences.Import.CSV.Quote := qtNone
          else
            Preferences.Import.CSV.Quote := qtStrings;
        end;
      itODBC:
        begin
          Preferences.Import.Structure := FStructure.Checked;
          Preferences.Import.Data := FData.Checked;
        end;
    end;

    if (FReplace.Checked) then
      Preferences.Import.StmtType := stReplace
    else if (FUpdate.Checked) then
      Preferences.Import.StmtType := stUpdate
    else if (FInsertOrUpdate.Checked) then
      Preferences.Import.StmtType := stInsertOrUpdate
    else
      Preferences.Import.StmtType := stInsert;
  end;

  FTables.Items.BeginUpdate();
  FTables.Items.Clear();
  FTables.Items.EndUpdate();
  ClearTSFields(Sender);

  FCSVPreview.Items.BeginUpdate();
  FCSVPreview.Items.Clear();
  FCSVPreview.Columns.Clear();
  FCSVPreview.Items.EndUpdate();

  FEngine.Items.BeginUpdate();
  FEngine.Items.Clear();
  FEngine.Items.EndUpdate();
  FCharset.Items.BeginUpdate();
  FCharset.Items.Clear();
  FCharset.Items.EndUpdate();
  FCollation.Items.BeginUpdate();
  FCollation.Items.Clear();
  FCollation.Items.EndUpdate();

  TableNames.Free();

  PageControl.ActivePage := nil;
end;

procedure TDImport.FormSessionEvent(const Event: TSSession.TEvent);
begin
  if (Event.EventType = etError) then
  begin
    SetControlCursor(GFields, crDefault);
    SetControlCursor(GProgress, crDefault);

    Wanted.Page := nil;
  end
  else if (Event.EventType = etAfterExecuteSQL) then
    PostMessage(Handle, UM_POST_AFTEREXECUTESQL, 0, 0);
end;

procedure TDImport.FormShow(Sender: TObject);
var
  I: Integer;
begin
  Session.RegisterEventProc(FormSessionEvent);

  TableNames := TTableNames.Create();

  ModalResult := mrNone;

  Wanted.Page := nil;
  TerminateTime := 0;

  if (ExtractFileName(Filename) = '') then
    Caption := Preferences.LoadStr(386)
  else
    Caption := Preferences.LoadStr(386) + ' ' + ExtractFileName(Filename);

  case (ImportType) of
    itSQLFile: HelpContext := 1010;
    itTextFile: HelpContext := 1133;
    itAccessFile: HelpContext := 1013;
    itExcelFile: HelpContext := 1106;
    itODBC: HelpContext := 1012;
    else raise ERangeError.Create('ImportType: ' + IntToStr(Ord(ImportType)));
  end;
  FBHelp.Visible := HelpContext >= 0;

  if (SObject is TSDatabase) then
    Database := TSDatabase(SObject)
  else if (SObject is TSDBObject) then
    Database := TSDBObject(SObject).Database
  else
    Database := nil;

  TSTables.Enabled := ImportType in [itAccessFile, itExcelFile, itODBC];
  TSCSVOptions.Enabled := ImportType in [itTextFile];
  TSWhat.Enabled := False;
  TSFields.Enabled := False;
  TSStmtType.Enabled := False;
  TSExecute.Enabled := False;

  for I := 0 to PageControl.PageCount - 1 do
    if (not Assigned(PageControl.ActivePage) and PageControl.Pages[I].Enabled) then
      PageControl.ActivePageIndex := I;
  CheckActivePageChange(PageControl.ActivePage);

  FBBack.Visible := not (ImportType in [itSQLFile]);
  FBForward.Visible := FBBack.Visible;

  FBCancel.Enabled := True;
  EnableMenuItem(GetSystemMenu(Handle, FALSE), SC_CLOSE, MF_BYCOMMAND or MF_ENABLED);
  if (FBForward.Visible and FBForward.Enabled) then
    ActiveControl := FBForward
  else
    ActiveControl := FBCancel;

  if (ImportType in [itSQLFile]) then
    PostMessage(Handle, UM_POST_SHOW, 0, 0);
end;

procedure TDImport.FQuoteClick(Sender: TObject);
begin
  FQuoteChar.Enabled := not FQuoteNothing.Checked;

  FCSVPreviewUpdate(Sender);
end;

procedure TDImport.FQuoteKeyPress(Sender: TObject; var Key: Char);
begin
  FQuoteClick(Sender);
end;

procedure TDImport.FSelectGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure TDImport.FTablesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  ClearTSFields(Sender);

  TSCSVOptions.Enabled := (ImportType in [itTextFile]) and (SObject is TSTable);
  TSWhat.Enabled := (ImportType in [itTextFile, itAccessFile, itExcelFile, itODBC]) and (SObject is TSDatabase) and not TSCSVOptions.Enabled;

  CheckActivePageChange(TSTables);
end;

procedure TDImport.FTablesDblClick(Sender: TObject);
begin
  FTablesSelectItem(Sender, FTables.Selected, Assigned(FTables.Selected));
  if (FBForward.Enabled) then
    FBForward.Click();
end;

procedure TDImport.FTablesSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  TSWhat.Enabled := (FTables.SelCount > 0) and (ImportType in [itTextFile, itAccessFile, itExcelFile, itODBC]) and not (SObject is TSBaseTable);
  TSFields.Enabled := (FTables.SelCount > 0) and not TSWhat.Enabled;
  CheckActivePageChange(TSTables);
end;

function TDImport.GetDataSource(): Boolean;
begin
  Result := DODBC.Execute();
end;

function TDImport.GetFilename(): Boolean;
begin
  OpenDialog.Title := Preferences.LoadStr(581);
  OpenDialog.InitialDir := Preferences.Path;
  OpenDialog.Filter := '';

  case (ImportType) of
    itSQLFile:
      begin
        OpenDialog.Filter := FilterDescription('sql') + ' (*.sql)|*.sql';
        OpenDialog.DefaultExt := 'sql';
        OpenDialog.Encodings.Text := EncodingCaptions();
      end;
    itTextFile:
      begin
        OpenDialog.Filter := FilterDescription('txt') + ' (*.txt;*.csv;*.tab;*.asc)|*.txt;*.csv;*.tab;*.asc';
        OpenDialog.DefaultExt := 'csv';
        OpenDialog.Encodings.Text := EncodingCaptions();
      end;
    itExcelFile:
      begin
        if (odExcel2003 in ODBCDrivers) then
          OpenDialog.Filter := FilterDescription('xlsb') + ' (*.xls;*.xlsm;*.xlsb;*.xlsx)|*.xls;*.xlsm;*.xlsb;*.xlsx'
        else
          OpenDialog.Filter := FilterDescription('xls') + ' (*.xls)|*.xls';
        if (odExcel2003 in ODBCDrivers) then
          OpenDialog.DefaultExt := '.xlsb'
        else
          OpenDialog.DefaultExt := '.xls';
        OpenDialog.Encodings.Clear();
      end;
    itAccessFile:
      begin
        if (odAccess2003 in ODBCDrivers) then
          OpenDialog.Filter := FilterDescription('mdb') + ' (*.mdb;*.accdb)|*.mdb;*.accdb'
        else
          OpenDialog.Filter := FilterDescription('mdb') + ' (*.mdb)|*.mdb';
        if (odAccess2003 in ODBCDrivers) then
          OpenDialog.DefaultExt := '.accdb'
        else
          OpenDialog.DefaultExt := '.mdb';
        OpenDialog.Encodings.Clear();
      end;
  end;
  OpenDialog.Filter := OpenDialog.Filter + '|' + FilterDescription('*') + ' (*.*)|*.*';

  OpenDialog.FileName := '';
  OpenDialog.EncodingIndex := OpenDialog.Encodings.IndexOf(CodePageToEncoding(CP_ACP));

  Result := OpenDialog.Execute();
  if (Result) then
  begin
    Preferences.Path := ExtractFilePath(OpenDialog.FileName);

    if ((OpenDialog.EncodingIndex < 0) or (OpenDialog.Encodings.Count = 0)) then
      CodePage := GetACP()
    else
      CodePage := EncodingToCodePage(OpenDialog.Encodings[OpenDialog.EncodingIndex]);
    Filename := OpenDialog.FileName;
  end;
end;

function TDImport.OnError(const Details: TTool.TErrorDetails): TDataAction;
begin
  Result := TDataAction(SendMessage(Handle, UM_TOOL_ERROR, 0, LPARAM(@Details)));
end;

procedure TDImport.OnTerminate(Sender: TObject);
begin
  PostMessage(Handle, UM_TERMINATE, WPARAM(not Import.Terminated), 0);
end;

procedure TDImport.OnUpdate(const AProgressInfos: TTool.TProgressInfos);
begin
  MoveMemory(@ProgressInfos, @AProgressInfos, SizeOf(AProgressInfos));
  PostMessage(Handle, UM_UPDATEPROGRESSINFO, 0, LPARAM(@ProgressInfos))
end;

procedure TDImport.ScrollBoxResize(Sender: TObject);
var
  I: Integer;
  Padding: Integer;
begin
  Padding := ScrollBox.Left + FSourceField1.Left;

  for I := 0 to Length(FSourceFields) - 1 do
    if ((Length(FSourceFields) > I) and Assigned(FSourceFields[I])) then
      FSourceFields[I].Width :=
        (ScrollBox.ClientWidth
          - FLReferrer1.Canvas.TextWidth(FLReferrer1.Caption)
          - 3 * Padding
          - GetSystemMetrics(SM_CXVSCROLL)) div 2;

  for I := 0 to Length(FLReferrers) - 1 do
    if ((Length(FLReferrers) > I) and Assigned(FLReferrers[I])) then
      FLReferrers[I].Left := FSourceFields[I].Left + FSourceFields[I].Width + Padding;

  for I := 0 to Length(FDestinationFields) - 1 do
    if ((Length(FDestinationFields) > I) and Assigned(FDestinationFields[I]) and (Length(FLReferrers) > 0) and Assigned(FLReferrers[I]) and (Length(FSourceFields) > 0) and Assigned(FSourceFields[I])) then
    begin
      FDestinationFields[I].Left := FLReferrers[I].Left + FLReferrers[I].Width + Padding;
      FDestinationFields[I].Width := FSourceFields[I].Width;
    end;

  if ((Length(FDestinationFields) > 0) and (Assigned(FDestinationFields[0]))) then
    FLDestinationFields.Left := FDestinationFields[0].Left + 6;
end;

procedure TDImport.TSExecuteResize(Sender: TObject);
begin
  FLEntiered.Left := GProgress.ClientWidth - FLProgressObjects.Left - FLEntiered.Width;
  FLDone.Left := GProgress.ClientWidth - FLProgressObjects.Left - Space - FLDone.Width;
  FEntieredObjects.Left := GProgress.ClientWidth - FLProgressObjects.Left - FEntieredObjects.Width;
  FLDone.Left := GProgress.ClientWidth - FLProgressObjects.Left - Space - FDoneObjects.Width;
  FEntieredRecords.Left := GProgress.ClientWidth - FLProgressObjects.Left - FEntieredRecords.Width;
  FDoneRecords.Left := GProgress.ClientWidth - FLProgressObjects.Left - Space - FDoneRecords.Width;
  FEntieredTime.Left := GProgress.ClientWidth - FLProgressObjects.Left - FEntieredTime.Width;
  FDoneTime.Left := GProgress.ClientWidth - FLProgressObjects.Left - Space - FDoneTime.Width;
  FErrors.Left := GProgress.ClientWidth - FLProgressObjects.Left - FErrors.Width;
end;

procedure TDImport.TSExecuteShow(Sender: TObject);
var
  Answer: Integer;

  procedure ImportAdd(TableName: string; const SourceTableName: string = '');
  begin
    TableName := Session.ApplyIdentifierName(TableName);
    if ((Answer <> IDYESALL) and not (SObject is TSTable) and Assigned(Database.TableByName(TableName))) then
      Answer := MsgBox(Preferences.LoadStr(700, Database.Name + '.' + TableName), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION);
    if (Answer in [IDYES, IDYESALL]) then
      Import.AddTable(TableName, SourceTableName);
  end;

var
  I: Integer;
  Success: Boolean;
begin
  FLProgressObjects.Visible := ImportType in [itODBC, itAccessFile, itExcelFile];
  FEntieredObjects.Visible := FLProgressObjects.Visible;
  FDoneObjects.Visible := FLProgressObjects.Visible;
  if (ImportType in [itODBC, itAccessFile, itExcelFile]) then
    FLProgressRecords.Caption := Preferences.LoadStr(235) + ':'
  else
    FLProgressRecords.Caption := Preferences.LoadStr(67) + ':';

  FEntieredObjects.Caption := '';
  FDoneObjects.Caption := '';
  FEntieredRecords.Caption := '';
  FDoneRecords.Caption := '';
  FEntieredTime.Caption := '';
  FDoneTime.Caption := '';
  FProgressBar.Position := 0;
  FErrors.Caption := '0';
  FErrorMessages.Lines.Clear();

  if (not Assigned(Import)) then
    CreateImport();

  Answer := IDYES;
  case (ImportType) of
    itTextFile:
      begin
        if (FDelimiterTab.Checked) then
          TTImportText(Import).Delimiter := #9
        else if (FDelimiter.Text = '') then
          TTImportText(Import).Delimiter := #0
        else
          TTImportText(Import).Delimiter := FDelimiter.Text[1];
        if (not FQuoteStrings.Checked) or (FQuoteChar.Text = '') then
          TTImportText(Import).Quoter := #0
        else
          TTImportText(Import).Quoter := FQuoteChar.Text[1];
        TTImportText(Import).UseHeadline := FCSVHeadline.Checked;

        if (SObject is TSTable) then
          ImportAdd(SObject.Name)
        else
          ImportAdd(Copy(Filename, 1 + Length(ExtractFilePath(Filename)), Length(Filename) - Length(ExtractFilePath(Filename)) - Length(ExtractFileExt(Filename))));
      end;
    itAccessFile:
      begin
        if (SObject is TSTable) then
          ImportAdd(SObject.Name, TTableName(FTables.Selected.Data).SourceName)
        else
          for I := 0 to FTables.Items.Count - 1 do
            if (FTables.Items[I].Selected) then
              ImportAdd(TTableName(FTables.Items[I].Data).TableName, TTableName(FTables.Items[I].Data).SourceName);
      end;
    itExcelFile:
      begin
        if (SObject is TSTable) then
          ImportAdd(SObject.Name, TTableName(FTables.Selected.Data).SourceName)
        else
          for I := 0 to FTables.Items.Count - 1 do
            if (FTables.Items[I].Selected) then
              ImportAdd(TTableName(FTables.Items[I].Data).TableName, TTableName(FTables.Items[I].Data).SourceName);
      end;
    itODBC:
      begin
        if (SObject is TSTable) then
          ImportAdd(SObject.Name, TTableName(FTables.Selected.Data).SourceName)
        else
          for I := 0 to FTables.Items.Count - 1 do
            if (FTables.Items[I].Selected) then
              ImportAdd(TTableName(FTables.Items[I].Data).TableName, TTableName(FTables.Items[I].Data).SourceName);
      end;
  end;

  Success := (Answer <> IDCANCEL);
  if (not Success) then
    FreeAndNil(Import)
  else
  begin
    Import.Data := (SObject is TSTable) or FData.Checked;
    Import.Charset := FCharset.Text;
    Import.Collation := FCollation.Text;
    Import.Engine := FEngine.Text;
    if (Import.Structure) then
      Import.StmtType := stInsert
    else if (FReplace.Checked) then
      Import.StmtType := stReplace
    else if (FUpdate.Checked and FUpdate.Enabled) then
      Import.StmtType := stUpdate
    else if (FInsertOrUpdate.Checked and FInsertOrUpdate.Enabled) then
      Import.StmtType := stInsertOrUpdate
    else
      Import.StmtType := stInsert;
    Import.RowType := TSTableField.TRowType(FRowFormat.ItemIndex);
    Import.Structure := not (SObject is TSTable) and FStructure.Checked;

    if (SObject is TSTable) then
    begin
      TSTable(SObject).InvalidateData();
      for I := 0 to Length(FSourceFields) - 1 do
        if (FDestinationFields[I].ItemIndex > 0) then
          Import.AddField(TSTable(SObject).Fields[FDestinationFields[I].ItemIndex - 1], FSourceFields[I].Text);
    end;

    FBBack.Enabled := False;

    Import.Wnd := Self.Handle;
    Import.OnError := OnError;
    Import.OnTerminate := OnTerminate;
    Import.OnUpdate := OnUpdate;
    Import.Start();
    Progress := Progress + 'k';
  end;

  CheckActivePageChange(TSExecute);
  FBBack.Enabled := False;
  ActiveControl := FBCancel;
end;

procedure TDImport.TSFieldsShow(Sender: TObject);
var
  FieldNames: TStringList;
  I: Integer;
  J: Integer;
begin
  Wanted.Page := nil;

  if (not SObject.Update()) then
    Wanted.Page := TSFields
  else if (Length(FSourceFields) = 0) then
  begin
    FieldNames := TStringList.Create();

    if (ImportType in [itTextFile]) then
    begin
      FLSourceFields.Caption := Preferences.LoadStr(400) + ':';

      for I := 0 to FCSVPreview.Columns.Count - 1 do
        FieldNames.Add(FCSVPreview.Column[I].Caption);
    end
    else if (ImportType in [itExcelFile, itAccessFile, itODBC]) then
    begin
      if (ImportType = itODBC) then
        FLSourceFields.Caption := Preferences.LoadStr(610) + ':'
      else
        FLSourceFields.Caption := Preferences.LoadStr(400) + ':';

      if (not Assigned(Import)) then
        CreateImport();
      TTImportODBC(Import).GetFieldNames(TTableName(FTables.Selected.Data).SourceName, FieldNames);
    end;

    if (SObject is TSTable) then
    begin
      ScrollBox.DisableAlign();

      SetLength(FSourceFields, FieldNames.Count);
      for I := 0 to Length(FSourceFields) - 1 do FSourceFields[I] := nil;
      SetLength(FLReferrers, Length(FSourceFields));
      for I := 0 to Length(FLReferrers) - 1 do FLReferrers[I] := nil;
      SetLength(FDestinationFields, Length(FSourceFields));
      for I := 0 to Length(FDestinationFields) - 1 do FDestinationFields[I] := nil;

      for I := 0 to Length(FSourceFields) - 1 do
      begin
        FSourceFields[I] := TEdit.Create(ScrollBox);
        FSourceFields[I].Parent := ScrollBox;
        FSourceFields[I].Left := FSourceField1.Left;
        FSourceFields[I].Top := FSourceField1.Top + I * (FSourceField2.Top - FSourceField1.Top);
        FSourceFields[I].Width := FSourceField1.Width;
        FSourceFields[I].Height := FSourceField1.Height;
        FSourceFields[I].Enabled := False;
        FSourceFields[I].Text := FieldNames[I];
        FSourceFields[I].OnChange := FSourceField1.OnChange;

        FLReferrers[I] := TLabel.Create(ScrollBox);
        FLReferrers[I].Parent := ScrollBox;
        FLReferrers[I].Left := FLReferrer1.Left;
        FLReferrers[I].Top := FLReferrer1.Top + I * (FSourceField2.Top - FSourceField1.Top);
        FLReferrers[I].Width := FLReferrer1.Width;
        FLReferrers[I].Height := FLReferrer1.Height;
        FLReferrers[I].Caption := FLReferrer1.Caption;

        FDestinationFields[I] := TComboBox_Ext.Create(ScrollBox);
        FDestinationFields[I].Parent := ScrollBox;
        FDestinationFields[I].Left := FDestinationField1.Left;
        FDestinationFields[I].Top := FDestinationField1.Top + I * (FSourceField2.Top - FSourceField1.Top);
        FDestinationFields[I].Width := FDestinationField1.Width;
        FDestinationFields[I].Height := FDestinationField1.Height;
        FDestinationFields[I].Style := FDestinationField1.Style;
        FDestinationFields[I].Enabled := not FSourceFields[I].Enabled;
        if (I = 0) then
        begin
          FDestinationFields[I].Items.Add('');
          for J := 0 to TSTable(SObject).Fields.Count - 1 do
            if (not (SObject is TSBaseTable) or (TSBaseTable(SObject).Fields[J].FieldKind = mkReal)) then
              FDestinationFields[I].Items.Add(TSBaseTable(SObject).Fields.Field[J].Name);
        end
        else
          FDestinationFields[I].Items.Text := FDestinationFields[0].Items.Text;
        if ((ImportType in [itTextFile]) and FCSVHeadline.Checked or (ImportType in [itExcelFile, itAccessFile, itODBC])) then
          FDestinationFields[I].ItemIndex := FDestinationFields[I].Items.IndexOf(FSourceFields[I].Text)
        else
          FDestinationFields[I].ItemIndex := I + 1;
        FDestinationFields[I].OnChange := FDestinationField1.OnChange;
        FDestinationFields[I].OnExit := FDestinationField1.OnExit;
      end;

      ScrollBoxResize(ScrollBox);
      ScrollBox.EnableAlign();

      FDestinationFieldChange(Sender);
      FFieldExit(Sender);
    end;

    FieldNames.Free();
  end;

  if (Assigned(Wanted.Page)) then
    SetControlCursor(GFields, crSQLWait)
  else
    SetControlCursor(GFields, crDefault);

  CheckActivePageChange(TSFields);
end;

procedure TDImport.TSWhatShow(Sender: TObject);
var
  I: Integer;
begin
  Wanted.Page := nil;

  if (not Session.Update()) then
    Wanted.Page := TSWhat
  else if (FEngine.Items.Count = 0) then
  begin
    for I := 0 to Session.Engines.Count - 1 do
      FEngine.Items.Add(Session.Engines[I].Name);

    FCharset.Visible := Session.Connection.MySQLVersion >= 40101; FLCharset.Visible := FCharset.Visible;
    if (FCharset.Visible) then
      for I := 0 to Session.Charsets.Count - 1 do
        FCharset.Items.Add(Session.Charsets[I].Name);

    FCollation.Visible := Session.Connection.MySQLVersion >= 40101; FLCollation.Visible := FCollation.Visible;
    if (FCollation.Visible) then
      for I := 0 to Session.Charsets.Count - 1 do
        FCollation.Items.Add(Session.Charsets[I].Name);


    FStructure.Checked := Preferences.Import.Structure and not (SObject is TSTable);
    FData.Checked := Preferences.Import.Data and (FStructure.Checked or (SObject is TSTable));
    FEngine.ItemIndex := FEngine.Items.IndexOf(Preferences.Import.Engine);
    FCharset.ItemIndex := FCharset.Items.IndexOf(Preferences.Import.Charset);
    FRowFormat.ItemIndex := Preferences.Import.RowType;
    case (Preferences.Import.StmtType) of
      stReplace: FReplace.Checked := True;
      stUpdate: FUpdate.Checked := True;
      stInsertOrUpdate: FInsertOrUpdate.Checked := True;
      else FInsert.Checked := True;
    end;

    if (Assigned(Session.Engines.DefaultEngine)) then
      FEngine.ItemIndex := FEngine.Items.IndexOf(Session.Engines.DefaultEngine.Name);

    if ((SObject is TSDatabase) and (TSDatabase(SObject).Charset <> '')) then
      FCharset.ItemIndex := FCharset.Items.IndexOf(TSDatabase(SObject).Charset)
    else if ((SObject is TSDBObject) and (TSDBObject(SObject).Database.Charset <> '')) then
      FCharset.ItemIndex := FCharset.Items.IndexOf(TSDBObject(SObject).Database.Charset)
    else if (Session.Charset <> '') then
      FCharset.ItemIndex := FCharset.Items.IndexOf(Session.Charset);
    FCharsetChange(Sender);
  end;

  TSFields.Enabled := not Assigned(Wanted.Page) and (FStructure.Checked or FData.Checked) and (SObject is TSTable);
  TSExecute.Enabled := not Assigned(Wanted.Page) and (FStructure.Checked or FData.Checked) and not TSFields.Enabled;
  CheckActivePageChange(TSWhat);
end;

procedure TDImport.TSStmtTypeShow(Sender: TObject);
var
  Found: Boolean;
  I: Integer;
  J: Integer;
begin
  FUpdate.Enabled := (SObject is TSBaseTable) and Assigned(TSBaseTable(SObject).PrimaryKey);
  if (FUpdate.Enabled) then
    for J := 0 to TSBaseTable(SObject).PrimaryKey.Columns.Count - 1 do
    begin
      Found := False;
      for I := 0 to Length(FDestinationFields) - 1 do
        Found := Found or (Database.Tables.NameCmp(FDestinationFields[I].Text, TSBaseTable(SObject).PrimaryKey.Columns[J].Field.Name) = 0);
      FUpdate.Enabled := FUpdate.Enabled and Found;
    end;
  FInsertOrUpdate.Enabled := (ImportType in [itTextFile, itExcelFile]) and FUpdate.Enabled; FLInsertUpdate.Enabled := FInsertOrUpdate.Enabled;

  TSExecute.Enabled := True;
  CheckActivePageChange(TSStmtType);
end;

procedure TDImport.TSTablesShow(Sender: TObject);
var
  I: Integer;
  ListItem: TListItem;
  StringList: TStringList;
begin
  if (FTables.Items.Count = 0) then
  begin
    if (not Assigned(Import)) then
      CreateImport();

    TableNames.Clear();

    StringList := TStringList.Create();
    case (ImportType) of
      itExcelFile:
        TTImportExcel(Import).GetTableNames(StringList);
      itAccessFile:
        TTImportAccess(Import).GetTableNames(StringList);
      itODBC:
        TTImportODBC(Import).GetTableNames(StringList);
    end;
    for I := 0 to StringList.Count - 1 do
      TableNames.Add(StringList[I]);
    StringList.Free();

    FTables.MultiSelect := not (SObject is TSTable);
    FTables.SortType := stNone;
    FTables.Items.BeginUpdate();
    for I := 0 to TableNames.Count - 1 do
    begin
      ListItem := FTables.Items.Add();
      ListItem.Caption := TableNames[I].Caption;
      ListItem.ImageIndex := iiTable;
      ListItem.Data := TCustomData(TableNames[I]);
    end;
    FTables.Items.EndUpdate();
    FTables.SortType := stText;
    FTables.Column[0].AutoSize := False;
    FTables.Column[0].Width := ColumnTextWidth;
    FTables.Column[0].AutoSize := True;

    if (FTables.Items.Count = 1) then
    begin
      FTables.Selected := FTables.Items[0];
      FTables.ItemFocused := FTables.Items[0];
    end
    else if (FTables.Items.Count > 1) then
      FTables.ItemFocused := FTables.Items[0];
  end;

  FTablesSelectItem(FTables, FTables.Selected, Assigned(FTables.Selected));
  FTablesChange(FTables, FTables.Selected, ctState);
  CheckActivePageChange(TSTables);
end;

procedure TDImport.UMChangePreferences(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiImport, Icon);

  OpenDialog.EncodingLabel := Preferences.LoadStr(682) + ':';

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  GTables.Caption := Preferences.LoadStr(234);

  GCSVHow.Caption := Preferences.LoadStr(238);
  FLCSVHeadline.Caption := Preferences.LoadStr(393) + ':';
  FCSVHeadline.Caption := Preferences.LoadStr(398);
  FLDelimiter.Caption := Preferences.LoadStr(352) + ':';
  FDelimiterTab.Caption := Preferences.LoadStr(394);
  FDelimiterChar.Caption := Preferences.LoadStr(355) + ':';
  FLQuoteValues.Caption := Preferences.LoadStr(353) + ':';
  FQuoteNothing.Caption := Preferences.LoadStr(359);
  FQuoteStrings.Caption := Preferences.LoadStr(397) + ':';
  GCSVPreview.Caption := Preferences.LoadStr(423);

  GWhat.Caption := Preferences.LoadStr(227);
  FLWhat.Caption := Preferences.LoadStr(218) + ':';
  FStructure.Caption := Preferences.LoadStr(215);
  FData.Caption := Preferences.LoadStr(216);
  GStructure.Caption := Preferences.LoadStr(238);
  FLEngine.Caption := Preferences.LoadStr(110) + ':';
  FLCharset.Caption := Preferences.LoadStr(682) + ':';
  FLCollation.Caption := Preferences.LoadStr(702) + ':';
  FLRowFormat.Caption := Preferences.LoadStr(129) + ':';

  GFields.Caption := Preferences.LoadStr(253);
  FLDestinationFields.Caption := Preferences.LoadStr(401) + ':';

  GStmtType.Caption := Preferences.LoadStr(238);
  FLStmtType.Caption := Preferences.LoadStr(124) + ':';
  FInsert.Caption := LowerCase(Preferences.LoadStr(880)) + ' (INSERT)';
  FReplace.Caption := LowerCase(Preferences.LoadStr(416)) + ' (REPLACE)';
  FUpdate.Caption := LowerCase(Preferences.LoadStr(726)) + ' (UPDATE)';
  FInsertOrUpdate.Caption := LowerCase(Preferences.LoadStr(910));
  FLInsertUpdate.Caption := '(INSERT / UPDATE)';

  GProgress.Caption := Preferences.LoadStr(224);
  FLEntiered.Caption := Preferences.LoadStr(211) + ':';
  FLDone.Caption := Preferences.LoadStr(232) + ':';
  FLProgressObjects.Caption := Preferences.LoadStr(234) + ':';
  FLProgressTime.Caption := Preferences.LoadStr(661) + ':';
  FLErrors.Caption := Preferences.LoadStr(391) + ':';

  GErrorMessages.Caption := Preferences.LoadStr(392);

  FBHelp.Caption := Preferences.LoadStr(167);
  FBBack.Caption := '< ' + Preferences.LoadStr(228);
  FBForward.Caption := Preferences.LoadStr(229) + ' >';
  FBCancel.Caption := Preferences.LoadStr(30);
end;

procedure TDImport.UMPostAfterExecuteSQL(var Message: TMessage);
begin
  if (Assigned(Wanted.Page) and Assigned(Wanted.Page.OnShow)) then
    Wanted.Page.OnShow(nil);
end;

procedure TDImport.UMPostShow(var Message: TMessage);
begin
  TSExecute.Enabled := True;
  PageControl.ActivePage := TSExecute;
end;

procedure TDImport.UMTerminate(var Message: TMessage);
var
  Success: Boolean;
begin
  Success := Boolean(Message.WParam);

  Import.WaitFor();

  if (Success and (Import.WarningCount > 0)) then
    MsgBoxCheck(Preferences.LoadStr(932, IntToStr(Import.WarningCount)), Preferences.LoadStr(43), MB_OK + MB_ICONINFORMATION,
      ID_OK, '{3b9746df-b0d6-47e4-9fb2-b2e9dfd93596}');

  Import.Free();
  Import := nil;

  if (not Application.Active) then
    FlashWindow(Application.MainFormHandle, True);

  FBBack.Enabled := True;
  FBCancel.Enabled := True;
  EnableMenuItem(GetSystemMenu(Handle, FALSE), SC_CLOSE, MF_BYCOMMAND or MF_ENABLED);
  FBCancel.Caption := Preferences.LoadStr(231);
  if (Success) then
    FBCancel.ModalResult := mrOk
  else
    FBCancel.ModalResult := mrCancel;
end;

procedure TDImport.UMToolError(var Message: TMessage);
var
  Details: ^TTool.TErrorDetails;
  ErrorMsg: string;
  Flags: Integer;
  Msg: string;
begin
  Details := Pointer(Message.LParam);

  ErrorMsg := '';
  case (Details^.Error.ErrorType) of
    TE_Database:
      begin
        Msg := Preferences.LoadStr(165, IntToStr(Details^.Error.Session.Connection.ErrorCode), Details^.Error.Session.Connection.ErrorMessage);
        ErrorMsg := Details^.Error.ErrorMessage
          + ' (#' + IntToStr(Details^.Error.ErrorCode) + ') - ' + Trim(Details^.Error.Session.Connection.ErrorCommandText) + #13#10;
      end;
    TE_File:
      begin
        Msg := Details^.Error.ErrorMessage;
        ErrorMsg := Msg;
        if (Details^.Error.ErrorCode = ERROR_NO_UNICODE_TRANSLATION) then
          MsgBoxHelpContext := 1150;
      end;
    TE_ODBC:
      begin
        if (Details^.Error.ErrorCode = 0) then
          Msg := Details^.Error.ErrorMessage
        else
          Msg := Details^.Error.ErrorMessage + ' (#' + IntToStr(Details^.Error.ErrorCode) + ')';
        ErrorMsg := Msg;
      end;
    else
      begin
        Msg := Details^.Error.ErrorMessage;
        ErrorMsg := Msg;
      end;
  end;

  if (not Details^.ShowRetry) then
    Flags := MB_OK + MB_ICONERROR
  else
    Flags := MB_CANCELTRYCONTINUE + MB_ICONERROR;
  if (MsgBoxHelpContext <> 0) then
    Flags := Flags or MB_HELP;
  case (MsgBox(Msg, Preferences.LoadStr(45), Flags)) of
    IDOK,
    IDCANCEL,
    IDABORT: Message.Result := LRESULT(daAbort);
    IDRETRY,
    IDTRYAGAIN: Message.Result := LRESULT(daRetry);
    IDCONTINUE,
    IDIGNORE: Message.Result := LRESULT(daFail);
    else raise ERangeError.Create(SRangeError);
  end;

  if ((TDataAction(Message.Result) in [daAbort, daFail]) and (ErrorMsg <> '')) then
  begin
    FErrors.Caption := IntToStr(Details^.Tool.ErrorCount);
    FErrorMessages.Text := FErrorMessages.Text + Trim(ErrorMsg);
  end;
end;

procedure TDImport.UMUpdateProgressInfo(var Message: TMessage);
var
  Infos: TTool.PProgressInfos;
begin
  Infos := TTool.PProgressInfos(Message.LParam);

  if (Infos^.ObjectsSum < 0) then
    FEntieredObjects.Caption := '???'
  else
    FEntieredObjects.Caption := FormatFloat('#,##0', Infos^.ObjectsSum, LocaleFormatSettings);
  if (Infos^.ObjectsDone < 0) then
    FDoneObjects.Caption := '???'
  else
    FDoneObjects.Caption := FormatFloat('#,##0', Infos^.ObjectsDone, LocaleFormatSettings);

  if (Infos^.RecordsSum < 0) then
    FEntieredRecords.Caption := '???'
  else
    FEntieredRecords.Caption := FormatFloat('#,##0', Infos^.RecordsSum, LocaleFormatSettings);
  if (Infos^.RecordsDone < 0) then
    FDoneRecords.Caption := '???'
  else
    FDoneRecords.Caption := FormatFloat('#,##0', Infos^.RecordsDone, LocaleFormatSettings);
  FEntieredTime.Caption := TimeToStr(Infos^.TimeSum, DurationFormatSettings);
  FDoneTime.Caption := TimeToStr(Infos^.TimeDone, DurationFormatSettings);

  FProgressBar.Position := Infos^.Progress;
end;

procedure TDImport.WhatClick(Sender: TObject);
begin
  if ((Sender = FStructure) and not FStructure.Checked) then
    FData.Checked := False;
  if ((Sender = FData) and FData.Checked) then
    FStructure.Checked := True;

  TSFields.Enabled := FStructure.Checked and FData.Checked and (SObject is TSTable);
  TSExecute.Enabled := not TSFields.Enabled and FStructure.Checked;
  CheckActivePageChange(TSWhat);
end;

procedure TDImport.WhatKeyPress(Sender: TObject; var Key: Char);
begin
  WhatClick(Sender);
end;

procedure TDImport.WMHelp(var Message: TWMHelp);
begin
  if (Message.HelpInfo.iContextType = HELPINFO_MENUITEM) then
    inherited
  else if (MsgBoxHelpContext <> 0) then
    Application.HelpCommand(HELP_CONTEXT, MsgBoxHelpContext);
end;

initialization
  FDImport := nil;
end.


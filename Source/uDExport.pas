unit uDExport;

interface {********************************************************************}

uses
  Windows, Messages, RichEdit,
  SysUtils, Classes,
  DB,
  Graphics, Controls, Forms, Dialogs, ComCtrls, ExtCtrls, StdCtrls, DBGrids,
  ComCtrls_Ext, Forms_Ext, StdCtrls_Ext, ExtCtrls_Ext, Dialogs_Ext,
  MySQLDB, MySQLDBGrid,
  uSession, uPreferences, uTools,
  uBase;

type
  TDExport = class (TForm_Ext)
    FBBack: TButton;
    FBCancel: TButton;
    FBForward: TButton;
    FBHelp: TButton;
    FCSVHeadline: TCheckBox;
    FDatabaseNodeAttribute: TEdit;
    FDatabaseNodeCustom: TRadioButton;
    FDatabaseNodeDisabled: TRadioButton;
    FDatabaseNodeName: TRadioButton;
    FDatabaseNodeText: TEdit;
    FDestinationField1: TEdit;
    FDoneRecords: TLabel;
    FDoneObjects: TLabel;
    FDoneTime: TLabel;
    FDropStmts: TCheckBox;
    FEntieredRecords: TLabel;
    FEntieredObjects: TLabel;
    FEntieredTime: TLabel;
    FErrorMessages: TRichEdit;
    FErrors: TLabel;
    FSourceField1: TComboBox_Ext;
    FSourceField2: TComboBox_Ext;
    FFieldNodeAttribute: TEdit;
    FFieldNodeCustom: TRadioButton;
    FFieldNodeName: TRadioButton;
    FFieldNodeText: TEdit;
    FHTMLData: TCheckBox;
    FHTMLMemoContent: TCheckBox;
    FHTMLNullText: TCheckBox;
    FHTMLStructure: TCheckBox;
    FL1DatabaseTagFree: TLabel;
    FL1FieldNodeCustom: TLabel;
    FL1TableNodeCustom: TLabel;
    FL2DatabaseNodeCustom: TLabel;
    FL2FieldNodeCustom: TLabel;
    FL2RecordTag: TLabel;
    FL2RootNodeText: TLabel;
    FL2TableNodeCustom: TLabel;
    FL3RecordTag: TLabel;
    FL3RootNodeText: TLabel;
    FLCSVHeadline: TLabel;
    FLDatabaseNode: TLabel;
    FLDestinationFields: TLabel;
    FLDone: TLabel;
    FLDrop: TLabel;
    FLEntiered: TLabel;
    FLErrors: TLabel;
    FLFieldNode: TLabel;
    FLSourceFields: TLabel;
    FLHTMLNullValues: TLabel;
    FLHTMLViewDatas: TLabel;
    FLHTMLWhat: TLabel;
    FLProgressRecords: TLabel;
    FLProgressObjects: TLabel;
    FLProgressTime: TLabel;
    FLQuoteChar: TLabel;
    FLQuoteValues: TLabel;
    FLRecordNode: TLabel;
    FLReferrer1: TLabel;
    FLRootNode: TLabel;
    FLSeparator: TLabel;
    FLSQLWhat: TLabel;
    FLTableNode: TLabel;
    FProgressBar: TProgressBar;
    FQuoteAll: TRadioButton;
    FQuoteChar: TEdit;
    FQuoteNone: TRadioButton;
    FQuoteStrings: TRadioButton;
    FRecordNodeText: TEdit;
    FReplaceData: TCheckBox;
    FRootNodeText: TEdit;
    FSeparator: TEdit;
    FSeparatorChar: TRadioButton;
    FSeparatorTab: TRadioButton;
    FSQLData: TCheckBox;
    FSQLStructure: TCheckBox;
    FTableNodeAttribute: TEdit;
    FTableNodeCustom: TRadioButton;
    FTableNodeDisabled: TRadioButton;
    FTableNodeName: TRadioButton;
    FTableNodeText: TEdit;
    GCSVOptions: TGroupBox_Ext;
    GErrors: TGroupBox_Ext;
    GFields: TGroupBox_Ext;
    GHTMLOptions: TGroupBox_Ext;
    GHTMLWhat: TGroupBox_Ext;
    GProgress: TGroupBox_Ext;
    GSQLOptions: TGroupBox_Ext;
    GSQLWhat: TGroupBox_Ext;
    GXMLHow: TGroupBox_Ext;
    PageControl: TPageControl;
    PDatabaseNode: TPanel_Ext;
    PErrorMessages: TPanel_Ext;
    PFieldNode: TPanel_Ext;
    PQuote: TPanel_Ext;
    PSeparator: TPanel_Ext;
    PSQLWait: TPanel_Ext;
    PTableNode: TPanel_Ext;
    SaveDialog: TSaveDialog_Ext;
    ScrollBox: TScrollBox;
    TSCSVOptions: TTabSheet;
    TSExecute: TTabSheet;
    TSFields: TTabSheet;
    TSHTMLOptions: TTabSheet;
    TSSQLOptions: TTabSheet;
    TSXMLOptions: TTabSheet;
    procedure FBBackClick(Sender: TObject);
    procedure FBForwardClick(Sender: TObject);
    procedure FBHelpClick(Sender: TObject);
    procedure FDatabaseDblClick(Sender: TObject);
    procedure FDatabaseNodeClick(Sender: TObject);
    procedure FDatabaseNodeKeyPress(Sender: TObject; var Key: Char);
    procedure FDestinationFieldChange(Sender: TObject);
    procedure FSourceFieldChange(Sender: TObject);
    procedure FSourceFieldExit(Sender: TObject);
    procedure FFieldTagClick(Sender: TObject);
    procedure FFieldTagKeyPress(Sender: TObject; var Key: Char);
    procedure FHTMLDataClick(Sender: TObject);
    procedure FHTMLDataKeyPress(Sender: TObject; var Key: Char);
    procedure FHTMLStructureClick(Sender: TObject);
    procedure FHTMLStructureKeyPress(Sender: TObject; var Key: Char);
    procedure FODBCSelectDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FQuoteCharExit(Sender: TObject);
    procedure FQuoteClick(Sender: TObject);
    procedure FQuoteKeyPress(Sender: TObject; var Key: Char);
    procedure FSelectGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure FSeparatorClick(Sender: TObject);
    procedure FSeparatorKeyPress(Sender: TObject; var Key: Char);
    procedure FSQLOptionClick(Sender: TObject);
    procedure FSQLOptionKeyPress(Sender: TObject; var Key: Char);
    procedure FTableTagClick(Sender: TObject);
    procedure FTableTagKeyPress(Sender: TObject; var Key: Char);
    procedure ScrollBoxResize(Sender: TObject);
    procedure TSCSVOptionsShow(Sender: TObject);
    procedure TSExecuteShow(Sender: TObject);
    procedure TSFieldsShow(Sender: TObject);
    procedure TSHTMLOptionsShow(Sender: TObject);
    procedure TSSQLOptionsShow(Sender: TObject);
    procedure TSXMLOptionChange(Sender: TObject);
    procedure TSXMLOptionsShow(Sender: TObject);
    procedure TSExecuteResize(Sender: TObject);
  private
    CodePage: Cardinal;
    Database: TSDatabase;
    Export: TTExport;
    FDestinationFields: array of TEdit;
    Filename: string;
    FLReferrers: array of TLabel;
    FObjects: TList;
    FSourceFields: array of TComboBox_Ext;
    ProgressInfos: TTool.TProgressInfos;
    SingleTable: Boolean;
    Space: Integer;
    Title: string;
    Wanted: record
      Page: TTabSheet;
    end;
    procedure CheckActivePageChange(const ActivePage: TTabSheet);
    procedure ClearTSFields();
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure CMSysFontChanged(var Message: TMessage); message CM_SYSFONTCHANGED;
    function GetDataSource(): Boolean;
    function GetFilename(): Boolean;
    function OnError(const Details: TTool.TErrorDetails): TDataAction;
    procedure OnTerminate(Sender: TObject);
    procedure OnUpdate(const AProgressInfos: TTool.TProgressInfos);
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
    procedure UMPostAfterExecuteSQL(var Message: TMessage); message UM_POST_AFTEREXECUTESQL;
    procedure UMTerminate(var Message: TMessage); message UM_TERMINATE;
    procedure UMToolError(var Message: TMessage); message UM_TOOL_ERROR;
    procedure UMUpdateProgressInfo(var Message: TMessage); message UM_UPDATEPROGRESSINFO;
  public
    DBGrid: TMySQLDBGrid;
    ExportType: TExportType;
    Session: TSSession;
    Window: TForm;
    function Execute(): Boolean;
    property DBObjects: TList read FObjects;
  end;

function DExport(): TDExport;

implementation {***************************************************************}

{$R *.dfm}

uses
  Math, StrUtils, DBCommon, SysConst,
  SQLUtils,
  uDLogin, uDODBC;

var
  FDExport: TDExport;

function DExport(): TDExport;
begin
  if (not Assigned(FDExport)) then
  begin
    Application.CreateForm(TDExport, FDExport);
    FDExport.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDExport;
end;

{ TDExport ********************************************************************}

procedure TDExport.CheckActivePageChange(const ActivePage: TTabSheet);
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

procedure TDExport.ClearTSFields();
var
  I: Integer;
begin
  for I := 0 to Length(FSourceFields) - 1 do
  begin
    FSourceFields[I].Free();
    FSourceFields[I] := nil;
  end;
  SetLength(FSourceFields, 0);
  for I := 0 to Length(FLReferrers) - 1 do
  begin
    FLReferrers[I].Free();
    FLReferrers[I] := nil;
  end;
  SetLength(FLReferrers, 0);
  for I := 0 to Length(FDestinationFields) - 1 do
  begin
    FDestinationFields[I].Free();
    FDestinationFields[I] := nil;
  end;
  SetLength(FDestinationFields, 0);
end;

procedure TDExport.CMSysFontChanged(var Message: TMessage);
begin
  inherited;

  FErrorMessages.Font := Font;

  FDatabaseNodeText.Left := FL1DatabaseTagFree.Left + FL1DatabaseTagFree.Width;
  FDatabaseNodeAttribute.Left := FDatabaseNodeText.Left + FDatabaseNodeText.Width + PDatabaseNode.Canvas.TextWidth('  ') + 2;
  FL2DatabaseNodeCustom.Left := FDatabaseNodeAttribute.Left + FDatabaseNodeAttribute.Width + 1;

  FTableNodeText.Left := FL1TableNodeCustom.Left + FL1TableNodeCustom.Width;
  FTableNodeAttribute.Left := FTableNodeText.Left + FTableNodeText.Width + PTableNode.Canvas.TextWidth('  ') + 2;
  FL2TableNodeCustom.Left := FTableNodeAttribute.Left + FTableNodeAttribute.Width + 1;

  FFieldNodeText.Left := FL1FieldNodeCustom.Left + FL1FieldNodeCustom.Width;
  FFieldNodeAttribute.Left := FFieldNodeText.Left + FFieldNodeText.Width + PFieldNode.Canvas.TextWidth('  ') + 2;
  FL2FieldNodeCustom.Left := FFieldNodeAttribute.Left + FFieldNodeAttribute.Width + 1;
end;

function TDExport.Execute(): Boolean;
var
  I: Integer;
begin
  ModalResult := mrNone;

  SingleTable := (DBObjects.Count = 1) and (TSObject(DBObjects[0]) is TSTable);

  Database := nil;
  for I := 0 to DBObjects.Count - 1 do
    if (TObject(DBObjects[I]) is TSDatabase) then
      if (not Assigned(Database) or (DBObjects[I] = Database)) then
        Database := TSDatabase(DBObjects[I])
      else
      begin
        Database := nil;
        break;
      end
    else if (TObject(DBObjects[I]) is TSDBObject) then
      if (not Assigned(Database) or (TSDBObject(DBObjects[I]).Database = Database)) then
        Database := TSDBObject(DBObjects[I]).Database
      else
      begin
        Database := nil;
        break;
      end;

  if (Assigned(DBGrid)) then
    Title := Preferences.LoadStr(362)
  else if (SingleTable) then
    Title := TSObject(DBObjects[0]).Name
  else if (Assigned(Database)) then
    Title := Database.Name
  else
    Title := ReplaceStr(Session.Caption, ':', '_');

  if (Assigned(DBGrid) or (DBObjects.Count > 0)) then
    case (ExportType) of
      etODBC:
        if (not GetDataSource()) then
          ModalResult := mrCancel;
      else
      begin
        if (not GetFilename()) then
          ModalResult := mrCancel;
      end;
    end;

  Result := (ModalResult = mrNone) and (ShowModal() = mrOk);
end;

procedure TDExport.FBBackClick(Sender: TObject);
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

procedure TDExport.FBForwardClick(Sender: TObject);
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

procedure TDExport.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDExport.FDatabaseDblClick(Sender: TObject);
begin
  FBForward.Click();
end;

procedure TDExport.FDatabaseNodeClick(Sender: TObject);
begin
  FDatabaseNodeText.Enabled := FDatabaseNodeCustom.Checked;

  TSXMLOptionChange(Sender);
end;

procedure TDExport.FDatabaseNodeKeyPress(Sender: TObject;
  var Key: Char);
begin
  FDatabaseNodeClick(Sender);
end;

procedure TDExport.FDestinationFieldChange(Sender: TObject);
var
  I: Integer;
  J: Integer;
begin
  TSExecute.Enabled := False;
  for I := 0 to Length(FSourceFields) - 1 do
    if ((FSourceFields[I].ItemIndex > 0) and (FDestinationFields[I].Text <> '')) then
      TSExecute.Enabled := True;

  for I := 0 to Length(FSourceFields) - 1 do
    for J := 0 to I - 1 do
      if ((I <> J) and FDestinationFields[I].Enabled and FDestinationFields[J].Enabled and (lstrcmpi(PChar(FDestinationFields[J].Text), PChar(FDestinationFields[I].Text)) = 0)) then
        TSExecute.Enabled := False;

  CheckActivePageChange(TSFields);
end;

procedure TDExport.FSourceFieldChange(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to Length(FDestinationFields) - 1 do
    if (Sender = FSourceFields[I]) then
    begin
      FDestinationFields[I].Enabled := (FSourceFields[I].ItemIndex > 0) and (ExportType in [etTextFile, etExcelFile, etHTMLFile, etPDFFile, etXMLFile]);
      FDestinationFields[I].Text := FSourceFields[I].Text;
    end;

  if (Length(FDestinationFields) > 0) then
    FDestinationFieldChange(Sender);
end;

procedure TDExport.FSourceFieldExit(Sender: TObject);
var
  I: Integer;
begin
  if (Sender is TComboBox_Ext) then
    for I := 0 to Length(FSourceFields) - 1 do
      if ((FSourceFields[I] <> Sender) and (FSourceFields[I].ItemIndex = TComboBox_Ext(Sender).ItemIndex)) then
      begin
        FSourceFields[I].ItemIndex := 0;
        FSourceFieldChange(FSourceFields[I]);
      end;
end;

procedure TDExport.FFieldTagClick(Sender: TObject);
begin
  FFieldNodeText.Enabled := FFieldNodeCustom.Checked;

  TSXMLOptionChange(Sender);
end;

procedure TDExport.FFieldTagKeyPress(Sender: TObject;
  var Key: Char);
begin
  FFieldTagClick(Sender);
end;

procedure TDExport.FHTMLDataClick(Sender: TObject);
begin
  FLHTMLNullValues.Enabled := FHTMLData.Checked;
  FHTMLNullText.Enabled := FHTMLData.Checked;
  FLHTMLViewDatas.Enabled := FHTMLData.Checked;
  FHTMLMemoContent.Enabled := FHTMLData.Checked;

  TSExecute.Enabled := FHTMLStructure.Checked or FHTMLData.Checked;
  CheckActivePageChange(TSHTMLOptions);
end;

procedure TDExport.FHTMLDataKeyPress(Sender: TObject; var Key: Char);
begin
  FHTMLDataClick(Sender);
end;

procedure TDExport.FHTMLStructureClick(Sender: TObject);
begin
  TSExecute.Enabled := FHTMLStructure.Checked or FHTMLData.Checked;

  CheckActivePageChange(TSHTMLOptions);
end;

procedure TDExport.FHTMLStructureKeyPress(Sender: TObject; var Key: Char);
begin
  FHTMLStructureClick(Sender);
end;

procedure TDExport.FODBCSelectDblClick(Sender: TObject);
begin
  FBForward.Click();
end;

procedure TDExport.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (Assigned(Export)) then
  begin
    Export.Terminate();
    CanClose := False;
  end
  else
    CanClose := True;

  FBCancel.Enabled := CanClose;
  if (FBCancel.Enabled) then
    EnableMenuItem(GetSystemMenu(Handle, FALSE), SC_CLOSE, MF_BYCOMMAND or MF_ENABLED)
  else
    EnableMenuItem(GetSystemMenu(Handle, FALSE), SC_CLOSE, MF_BYCOMMAND or MF_DISABLED);
end;

procedure TDExport.FormCreate(Sender: TObject);
begin
  Space := (FLEntiered.Left + FLEntiered.Width) - (FLDone.Left + FLDone.Width);

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  if ((Preferences.Export.Width >= Width) and (Preferences.Export.Height >= Height)) then
  begin
    Width := Preferences.Export.Width;
    Height := Preferences.Export.Height;
  end;

  Export := nil;

  FObjects := TList.Create();

  FCSVHeadline.Checked := Preferences.Export.CSV.Headline;
  FSeparatorTab.Checked := Preferences.Export.CSV.DelimiterType = dtTab;
  FSeparatorChar.Checked := Preferences.Export.CSV.DelimiterType = dtChar;
  FSeparator.Text := Preferences.Export.CSV.Delimiter;
  FQuoteNone.Checked := Preferences.Export.CSV.QuoteValues = qtNone;
  FQuoteStrings.Checked := Preferences.Export.CSV.QuoteValues = qtStrings;
  FQuoteAll.Checked := Preferences.Export.CSV.QuoteValues = qtAll;
  FQuoteChar.Text := Preferences.Export.CSV.Quoter;

  FSQLStructure.Checked := Preferences.Export.SQL.Structure;
  FSQLData.Checked := Preferences.Export.SQL.Data;
  FDropStmts.Checked := Preferences.Export.SQL.DropStmts;
  FReplaceData.Checked := Preferences.Export.SQL.ReplaceData;

  FSQLOptionClick(Sender);

  FHTMLStructure.Checked := Preferences.Export.HTML.Structure;
  FHTMLData.Checked := Preferences.Export.HTML.Data;
  FHTMLNullText.Checked := Preferences.Export.HTML.NULLText;
  FHTMLMemoContent.Checked := Preferences.Export.HTML.MemoContent;

  FRootNodeText.Text := Preferences.Export.XML.Root.NodeText;
  case (Preferences.Export.XML.Database.NodeType) of
    ntDisabled: FDatabaseNodeDisabled.Checked := True;
    ntName: FDatabaseNodeName.Checked := True;
    ntCustom: FDatabaseNodeCustom.Checked := True;
  end;
  FDatabaseNodeText.Text := Preferences.Export.XML.Database.NodeText;
  FDatabaseNodeAttribute.Text := Preferences.Export.XML.Database.NodeAttribute;
  case (Preferences.Export.XML.Table.NodeType) of
    ntDisabled: FTableNodeDisabled.Checked := True;
    ntName: FTableNodeName.Checked := True;
    ntCustom: FTableNodeCustom.Checked := True;
  end;
  FTableNodeText.Text := Preferences.Export.XML.Table.NodeText;
  FTableNodeAttribute.Text := Preferences.Export.XML.Table.NodeAttribute;
  FRecordNodeText.Text := Preferences.Export.XML.Row.NodeText;
  case (Preferences.Export.XML.Field.NodeType) of
    ntName: FFieldNodeName.Checked := True;
    ntCustom: FFieldNodeCustom.Checked := True;
  end;
  FFieldNodeText.Text := Preferences.Export.XML.Field.NodeText;
  FFieldNodeAttribute.Text := Preferences.Export.XML.Field.NodeAttribute;

  FRootNodeText.Text := Preferences.Export.XML.Root.NodeText;
  case (Preferences.Export.XML.Database.NodeType) of
    ntDisabled: FDatabaseNodeDisabled.Checked := True;
    ntName: FDatabaseNodeName.Checked := True;
    ntCustom: FDatabaseNodeCustom.Checked := True;
  end;
  FDatabaseNodeText.Text := Preferences.Export.XML.Database.NodeText;
  FDatabaseNodeAttribute.Text := Preferences.Export.XML.Database.NodeAttribute;

  SendMessage(FErrorMessages.Handle, EM_SETTEXTMODE, TM_PLAINTEXT, 0);
  SendMessage(FErrorMessages.Handle, EM_SETWORDBREAKPROC, 0, LPARAM(@EditWordBreakProc));

  PageControl.ActivePage := nil;
end;

procedure TDExport.FormDestroy(Sender: TObject);
begin
  FObjects.Free();
end;

procedure TDExport.FormHide(Sender: TObject);
begin
  Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.Export.Width := Width;
  Preferences.Export.Height := Height;

  if (ModalResult = mrOk) then
    case (ExportType) of
      etSQLFile:
        begin
          Preferences.Export.SQL.Structure := FSQLStructure.Checked;
          Preferences.Export.SQL.Data := FSQLData.Checked;
          Preferences.Export.SQL.DropStmts := FDropStmts.Checked;
          Preferences.Export.SQL.ReplaceData := FReplaceData.Checked;
        end;
      etTextFile:
        begin
          Preferences.Export.CSV.Headline := FCSVHeadline.Checked;
          if (FSeparatorTab.Checked) then
            Preferences.Export.CSV.DelimiterType := dtTab
          else if (FSeparatorChar.Checked) then
            Preferences.Export.CSV.DelimiterType := dtChar;
          Preferences.Export.CSV.Delimiter := FSeparator.Text;
          if (FQuoteNone.Checked) then
            Preferences.Export.CSV.QuoteValues := qtNone
          else if (FQuoteAll.Checked) then
            Preferences.Export.CSV.QuoteValues := qtAll
          else
            Preferences.Export.CSV.QuoteValues := qtStrings;
          if (FQuoteChar.Text <> '') then
            Preferences.Export.CSV.Quoter := FQuoteChar.Text[1];
        end;
      etExcelFile:
        Preferences.Export.Excel.Excel2003 := (odExcel2003 in ODBCDrivers) and (SaveDialog.FilterIndex = 1);
      etAccessFile:
        Preferences.Export.Access.Access2003 := (odAccess2003 in ODBCDrivers) and (SaveDialog.FilterIndex = 1);
      etODBC:
        begin
          Preferences.Export.ODBC.DataSource := DODBC.DataSource;
        end;
      etHTMLFile,
      etPDFFile:
        begin
          Preferences.Export.HTML.Data := FHTMLData.Checked;
          Preferences.Export.HTML.MemoContent := FHTMLMemoContent.Checked;
          Preferences.Export.HTML.NULLText := FHTMLNullText.Checked;
          Preferences.Export.HTML.Structure := FHTMLStructure.Checked;
        end;
      etXMLFile:
        begin
          Preferences.Export.XML.Root.NodeText := Trim(FRootNodeText.Text);
          if (FDatabaseNodeDisabled.Checked) then
            Preferences.Export.XML.Database.NodeType := ntDisabled
          else if (FDatabaseNodeName.Checked) then
            Preferences.Export.XML.Database.NodeType := ntName
          else
            Preferences.Export.XML.Database.NodeType := ntCustom;
          Preferences.Export.XML.Database.NodeText := Trim(FDatabaseNodeText.Text);
          Preferences.Export.XML.Database.NodeAttribute := Trim(FDatabaseNodeAttribute.Text);
          if (FTableNodeDisabled.Checked) then
            Preferences.Export.XML.Table.NodeType := ntDisabled
          else if (FTableNodeName.Checked) then
            Preferences.Export.XML.Table.NodeType := ntName
          else
            Preferences.Export.XML.Table.NodeType := ntCustom;
          Preferences.Export.XML.Table.NodeText := Trim(FTableNodeText.Text);
          Preferences.Export.XML.Table.NodeAttribute := Trim(FTableNodeAttribute.Text);
          Preferences.Export.XML.Row.NodeText := Trim(FRecordNodeText.Text);
          if (FFieldNodeName.Checked) then
            Preferences.Export.XML.Field.NodeType := ntName
          else
            Preferences.Export.XML.Field.NodeType := ntCustom;
          Preferences.Export.XML.Field.NodeText := Trim(FFieldNodeText.Text);
          Preferences.Export.XML.Field.NodeAttribute := Trim(FFieldNodeAttribute.Text);
        end;
    end;

  ClearTSFields();

  PageControl.ActivePage := nil;
end;

procedure TDExport.FormSessionEvent(const Event: TSSession.TEvent);
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

procedure TDExport.FormShow(Sender: TObject);
var
  I: Integer;
begin
  Session.RegisterEventProc(FormSessionEvent);

  ModalResult := mrNone;

  Wanted.Page := nil;

  Caption := Preferences.LoadStr(210) + ' ' + ExtractFileName(Filename);

  case (ExportType) of
    etSQLFile: HelpContext := 1014;
    etTextFile: HelpContext := 1134;
    etExcelFile: HelpContext := 1107;
    etAccessFile: HelpContext := 1129;
    etXMLFile: HelpContext := 1017;
    etHTMLFile: HelpContext := 1016;
    etPDFFile: HelpContext := 1137;
    else HelpContext := -1;
  end;
  FBHelp.Visible := HelpContext >= 0;

  if (Assigned(DBGrid)) then
    FHTMLStructure.Caption := Preferences.LoadStr(794)
  else
    FHTMLStructure.Caption := Preferences.LoadStr(215);

  TSSQLOptions.Enabled := ExportType in [etSQLFile];
  TSCSVOptions.Enabled := ExportType in [etTextFile];
  TSXMLOptions.Enabled := (ExportType in [etXMLFile]) and not Assigned(DBGrid);
  TSHTMLOptions.Enabled := ExportType in [etHTMLFile, etPDFFile];
  TSFields.Enabled := (ExportType in [etExcelFile, etODBC]) and (SingleTable and (TObject(DBObjects[0]) is TSTable) or Assigned(DBGrid)) or (ExportType in [etXMLFile]) and Assigned(DBGrid);
  TSExecute.Enabled := not TSSQLOptions.Enabled and not TSCSVOptions.Enabled and not TSHTMLOptions.Enabled and not TSFields.Enabled;

  FBBack.Visible := TSSQLOptions.Enabled or TSCSVOptions.Enabled or TSXMLOptions.Enabled or TSHTMLOptions.Enabled or TSFields.Enabled;
  FBForward.Visible := FBBack.Visible;

  for I := 0 to PageControl.PageCount - 1 do
    if (not Assigned(PageControl.ActivePage) and PageControl.Pages[I].Enabled) then
      PageControl.ActivePageIndex := I;
  CheckActivePageChange(PageControl.ActivePage);

  FBCancel.Enabled := True;
  EnableMenuItem(GetSystemMenu(Handle, FALSE), SC_CLOSE, MF_BYCOMMAND or MF_ENABLED);
  if (FBForward.Visible and FBForward.Enabled) then
    ActiveControl := FBForward
  else
    ActiveControl := FBCancel;
end;

procedure TDExport.FQuoteCharExit(Sender: TObject);
begin
  if (FQuoteChar.Text = '') then
    FQuoteNone.Checked := True;
end;

procedure TDExport.FQuoteClick(Sender: TObject);
begin
  FQuoteChar.Enabled := not FQuoteNone.Checked;
  FLQuoteChar.Enabled := FQuoteChar.Enabled;

  if (not FQuoteNone.Checked and (FQuoteChar.Text = '')) then
    FQuoteChar.Text := '"';
end;

procedure TDExport.FQuoteKeyPress(Sender: TObject; var Key: Char);
begin
  FQuoteClick(Sender);
end;

procedure TDExport.FSelectGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure TDExport.FSeparatorClick(Sender: TObject);
begin
  if (not FQuoteStrings.Enabled and FQuoteStrings.Checked) then
    FQuoteAll.Checked := True;
end;

procedure TDExport.FSeparatorKeyPress(Sender: TObject; var Key: Char);
begin
  FSeparatorClick(Sender);
end;

procedure TDExport.FSQLOptionClick(Sender: TObject);
begin
  FDropStmts.Enabled := FSQLStructure.Checked;
  FDropStmts.Checked := FDropStmts.Checked and FDropStmts.Enabled;
  FReplaceData.Enabled := FSQLData.Checked and not FDropStmts.Checked;
  FReplaceData.Checked := FReplaceData.Checked and FReplaceData.Enabled;

  TSExecute.Enabled := FSQLStructure.Checked or FSQLData.Checked;

  CheckActivePageChange(TSSQLOptions);
end;

procedure TDExport.FSQLOptionKeyPress(Sender: TObject; var Key: Char);
begin
  FSQLOptionClick(Sender);
end;

procedure TDExport.FTableTagClick(Sender: TObject);
begin
  FTableNodeText.Enabled := FTableNodeCustom.Checked;

  TSXMLOptionChange(Sender);
end;

procedure TDExport.FTableTagKeyPress(Sender: TObject;
  var Key: Char);
begin
  FTableTagClick(Sender);
end;

function TDExport.GetDataSource(): Boolean;
begin
  Result := DODBC.Execute();
end;

function TDExport.GetFilename(): Boolean;
begin
  if (Assigned(DBGrid)) then
    Filename := Preferences.LoadStr(362)
  else if (SingleTable and (TObject(DBObjects[0]) is TSBaseTable)) then
    Filename := TSBaseTable(DBObjects[0]).Name
  else if (DBObjects.Count = 1) then
    Filename := TSObject(DBObjects[0]).Name
  else if (Assigned(Database)) then
    Filename := Database.Name
  else if (Assigned(Session)) then
    Filename := Session.Account.Connection.Host
  else
    Filename := '';

  SaveDialog.Title := Preferences.LoadStr(582);
  SaveDialog.InitialDir := Preferences.Path;
  SaveDialog.Filter := '';
  SaveDialog.DefaultExt := '';
  case (ExportType) of
    etSQLFile:
      begin
        SaveDialog.Filter := FilterDescription('sql') + ' (*.sql)|*.sql';
        SaveDialog.DefaultExt := '.sql';
        SaveDialog.Encodings.Text := EncodingCaptions();
      end;
    etTextFile:
      begin
        SaveDialog.Filter := FilterDescription('txt') + ' (*.txt;*.csv;*.tab)|*.txt;*.csv;*.tab';
        SaveDialog.DefaultExt := '.csv';
        SaveDialog.Encodings.Text := EncodingCaptions();
      end;
    etExcelFile:
      begin
        SaveDialog.Filter := '';
        if (odExcel2003 in ODBCDrivers) then
          SaveDialog.Filter := SaveDialog.Filter + FilterDescription('xlsb') + ' (*.xlsb)|*.xlsb|';
        SaveDialog.Filter := SaveDialog.Filter + FilterDescription('xls') + ' (*.xls)|*.xls';
        if (odExcel2003 in ODBCDrivers) then
          SaveDialog.DefaultExt := '.xlsb'
        else
          SaveDialog.DefaultExt := '.xls';
        SaveDialog.Encodings.Clear();
      end;
    etAccessFile:
      begin
        SaveDialog.Filter := '';
        if (odAccess2003 in ODBCDrivers) then
          SaveDialog.Filter := FilterDescription('accdb') + ' (*.accdb)|*.accdb|';
        SaveDialog.Filter := SaveDialog.Filter + FilterDescription('mdb') + ' (*.mdb)|*.mdb';
        if (odAccess2003 in ODBCDrivers) then
          SaveDialog.DefaultExt := '.accdb'
        else
          SaveDialog.DefaultExt := '.mdb';
        SaveDialog.Encodings.Clear();
      end;
    etHTMLFile:
      begin
        SaveDialog.Filter := FilterDescription('html') + ' (*.html;*.htm)|*.html;*.htm';
        SaveDialog.DefaultExt := '.html';
        SaveDialog.Encodings.Clear();
      end;
    etPDFFile:
      begin
        SaveDialog.Filter := FilterDescription('pdf') + ' (*.pdf)|*.pdf';
        SaveDialog.DefaultExt := '.pdf';
        SaveDialog.Encodings.Clear();
      end;
    etXMLFile:
      begin
        SaveDialog.Filter := FilterDescription('xml') + ' (*.xml)|*.xml';
        SaveDialog.DefaultExt := '.xml';
        SaveDialog.Encodings.Clear();
      end;
  end;
  SaveDialog.Filter := SaveDialog.Filter + '|' + FilterDescription('*') + ' (*.*)|*.*';

  if (Filename <> '') then
    SaveDialog.FileName := Filename
  else
    SaveDialog.FileName := Title + SaveDialog.DefaultExt;

  CodePage := CP_UTF8;
  if (SaveDialog.Encodings.Count = 0) then
    SaveDialog.EncodingIndex := -1
  else
    SaveDialog.EncodingIndex := SaveDialog.Encodings.IndexOf(CodePageToEncoding(CodePage));

  Result := SaveDialog.Execute();
  if (Result) then
  begin
    Preferences.Path := ExtractFilePath(SaveDialog.FileName);

    if ((SaveDialog.EncodingIndex < 0) or (SaveDialog.Encodings.Count = 0)) then
      CodePage := GetACP()
    else
      CodePage := EncodingToCodePage(SaveDialog.Encodings[SaveDialog.EncodingIndex]);
    Filename := SaveDialog.FileName;
  end;
end;

function TDExport.OnError(const Details: TTool.TErrorDetails): TDataAction;
begin
  Result := TDataAction(SendMessage(Handle, UM_TOOL_ERROR, 0, LPARAM(@Details)));
end;

procedure TDExport.OnTerminate(Sender: TObject);
begin
  PostMessage(Handle, UM_TERMINATE, WPARAM(not Export.Terminated), 0);
end;

procedure TDExport.OnUpdate(const AProgressInfos: TTool.TProgressInfos);
begin
  MoveMemory(@ProgressInfos, @AProgressInfos, SizeOf(AProgressInfos));

  PostMessage(Handle, UM_UPDATEPROGRESSINFO, 0, LPARAM(@ProgressInfos));
end;

procedure TDExport.ScrollBoxResize(Sender: TObject);
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
    if ((Length(FLReferrers) > 0) and Assigned(FLReferrers[I])) then
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

procedure TDExport.TSCSVOptionsShow(Sender: TObject);
begin
  ClearTSFields();

  FSeparatorClick(Self);

  if (SingleTable) then
    TSFields.Enabled := not TSFields.Enabled
  else
    TSExecute.Enabled := not TSFields.Enabled;
  CheckActivePageChange(TSCSVOptions);
end;

procedure TDExport.TSExecuteResize(Sender: TObject);
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

procedure TDExport.TSExecuteShow(Sender: TObject);
var
  Answer: Integer;
  I: Integer;
  J: Integer;
  K: Integer;
begin
  FEntieredObjects.Caption := '';
  FDoneObjects.Caption := '';
  FEntieredRecords.Caption := '';
  FDoneRecords.Caption := '';
  FEntieredTime.Caption := '';
  FDoneTime.Caption := '';
  FProgressBar.Position := 0;
  FErrors.Caption := '0';
  FErrorMessages.Lines.Clear();

  Wanted.Page := nil;

  I := 0;
  while (not Assigned(Wanted.Page) and (I < DBObjects.Count)) do
    if (TObject(DBObjects[I]) is TSDatabase) then
    begin
      Database := TSDatabase(DBObjects[I]);
      if (not Database.Update()) then
        Wanted.Page := TSExecute
      else
      begin
        for J := 0 to Database.Tables.Count - 1 do
          if (DBObjects.IndexOf(Database.Tables[J]) < 0) then
          begin
            DBObjects.Add(Database.Tables[J]);
            if ((Database.Tables[J] is TSBaseTable) and Assigned(Database.Triggers)) then
              for K := 0 to TSBaseTable(Database.Tables[J]).TriggerCount - 1 do
                if (DBObjects.IndexOf(TSBaseTable(Database.Tables[J]).Triggers[K]) < 0) then
                  DBObjects.Add(TSBaseTable(Database.Tables[J]).Triggers[K]);
          end;
        if (Assigned(Database.Routines)) then
          for J := 0 to Database.Routines.Count - 1 do
            if (DBObjects.IndexOf(Database.Routines[J]) < 0) then
              DBObjects.Add(Database.Routines[J]);
        if (Assigned(Database.Events)) then
          for J := 0 to Database.Events.Count - 1 do
            if (DBObjects.IndexOf(Database.Events[J]) < 0) then
              DBObjects.Add(Database.Events[J]);
        DBObjects.Delete(I);
      end;
    end
    else if (TObject(DBObjects[I]) is TSBaseTable) then
    begin
      Database := TSBaseTable(DBObjects[I]).Database;
      if (Assigned(Database.Triggers)) then
        for J := 0 to TSBaseTable(DBObjects[I]).TriggerCount - 1 do
          if (DBObjects.IndexOf(TSBaseTable(DBObjects[I]).Triggers[J]) < 0) then
            DBObjects.Add(TSBaseTable(DBObjects[I]).Triggers[J]);
      Inc(I);
    end
    else
      Inc(I);

  if (not Assigned(Wanted.Page)) then
    if (not Session.Update(DBObjects)) then
      Wanted.Page := TSExecute;

  if (not Assigned(Wanted.Page)) then
  begin
    case (ExportType) of
      etSQLFile:
        begin
          Export := TTExportSQL.Create(Session, Filename, CodePage);
          TTExportSQL(Export).Data := FSQLData.Checked;
          TTExportSQL(Export).DropStmts := FDropStmts.Checked;
          TTExportSQL(Export).ReplaceData := FReplaceData.Checked;
          TTExportSQL(Export).Structure := FSQLStructure.Checked;
        end;
      etTextFile:
        begin
          Export := TTExportText.Create(Session, Filename, CodePage);
          TTExportText(Export).Data := True;
          if (FSeparatorTab.Checked) then
            TTExportText(Export).Delimiter := #9;
          if (FSeparatorChar.Checked) then
            TTExportText(Export).Delimiter := FSeparator.Text;
          if (FQuoteNone.Checked) then
            TTExportText(Export).QuoteValues := qtNone
          else if (FQuoteAll.Checked) then
            TTExportText(Export).QuoteValues := qtAll
          else
            TTExportText(Export).QuoteValues := qtStrings;
          if (FQuoteChar.Text <> '') then
            TTExportText(Export).Quoter := FQuoteChar.Text[1];
          TTExportText(Export).Structure := FCSVHeadline.Checked;
        end;
      etODBC:
        begin
          Export := TTExportODBC.Create(Session, DODBC.DataSource, DODBC.Username, DODBC.Password);
          TTExportBaseODBC(Export).Data := True;
          TTExportBaseODBC(Export).Structure := True;
        end;
      etExcelFile:
        begin
          Export := TTExportExcel.Create(Session, Filename);
          TTExportExcel(Export).Data := True;
          TTExportExcel(Export).Excel2003 := (odExcel2003 in ODBCDrivers) and (SaveDialog.FilterIndex = 1);
          TTExportExcel(Export).Structure := True;
        end;
      etAccessFile:
        begin
          Export := TTExportAccess.Create(Session, Filename);
          TTExportAccess(Export).Access2003 := (odAccess2003 in ODBCDrivers) and (SaveDialog.FilterIndex = 1);
          TTExportAccess(Export).Data := True;
          TTExportAccess(Export).Structure := True;
        end;
      etHTMLFile:
        begin
          Export := TTExportHTML.Create(Session, Filename);
          TTExportHTML(Export).Data := FHTMLData.Checked;
          TTExportHTML(Export).TextContent := FHTMLMemoContent.Checked;
          TTExportHTML(Export).NULLText := FHTMLNullText.Checked;
          TTExportHTML(Export).Structure := FHTMLStructure.Checked;
        end;
      etXMLFile:
        begin
          Export := TTExportXML.Create(Session, Filename);
          TTExportXML(Export).Data := True;
          if (FDatabaseNodeName.Checked) then
          begin
            TTExportXML(Export).DatabaseNodeText := 'database';
            TTExportXML(Export).DatabaseNodeAttribute := '';
          end
          else if (FDatabaseNodeCustom.Checked) then
          begin
            TTExportXML(Export).DatabaseNodeText := FDatabaseNodeText.Text;
            TTExportXML(Export).DatabaseNodeAttribute := FDatabaseNodeAttribute.Text;
          end
          else
          begin
            TTExportXML(Export).DatabaseNodeText := '';
            TTExportXML(Export).DatabaseNodeAttribute := '';
          end;
          TTExportXML(Export).RootNodeText := FRootNodeText.Text;
          TTExportXML(Export).Structure := True;
          if (FTableNodeName.Checked) then
          begin
            TTExportXML(Export).TableNodeText := 'Table';
            TTExportXML(Export).TableNodeAttribute := '';
          end
          else if (FTableNodeCustom.Checked) then
          begin
            TTExportXML(Export).TableNodeText := FTableNodeText.Text;
            TTExportXML(Export).TableNodeAttribute := FTableNodeAttribute.Text;
          end
          else
          begin
            TTExportXML(Export).TableNodeText := '';
            TTExportXML(Export).TableNodeAttribute := '';
          end;
          TTExportXML(Export).RecoreNodeText := FRecordNodeText.Text;
          if (FFieldNodeName.Checked) then
          begin
            TTExportXML(Export).FieldNodeText := 'database';
            TTExportXML(Export).FieldNodeAttribute := '';
          end
          else
          begin
            TTExportXML(Export).FieldNodeText := FFieldNodeText.Text;
            TTExportXML(Export).FieldNodeAttribute := FFieldNodeAttribute.Text;
          end;
        end;
      etPDFFile:
        begin
          Export := TTExportPDF.Create(Session, Filename);
          TTExportCanvas(Export).Data := FHTMLData.Checked;
          TTExportCanvas(Export).NULLText := FHTMLNullText.Checked;
          TTExportCanvas(Export).Structure := FHTMLStructure.Checked;
        end;
      else
        Export := nil;
    end;

    if (Assigned(Export)) then
    begin
      Answer := IDYES;

      if (Assigned(DBGrid)) then
      begin
        Export.Add(DBGrid);

        if (Length(FSourceFields) = 0) then
        begin
          for I := 0 to DBGrid.Columns.Count - 1 do
            if (((ExportType <> etSQLFile) or not DBGrid.Columns[I].Field.ReadOnly)
              and DBGrid.Columns[I].Visible
              and ((DBGrid.SelectedFields.Count = 0) or (DBGrid.SelectedFields.IndexOf(DBGrid.Fields[I]) >= 0))) then
            begin
              SetLength(Export.Fields, Length(Export.Fields) + 1);
              Export.Fields[Length(Export.Fields) - 1] := DBGrid.Fields[I];
              SetLength(Export.DestinationFields, Length(Export.DestinationFields) + 1);
              Export.DestinationFields[Length(Export.DestinationFields) - 1].Name := DBGrid.Fields[I].DisplayName;
            end;
        end
        else
          for I := 0 to Length(FSourceFields) - 1 do
            if (FSourceFields[I].ItemIndex > 0) then
            begin
              SetLength(Export.Fields, Length(Export.Fields) + 1);
              Export.Fields[Length(Export.Fields) - 1] := DBGrid.Fields[FSourceFields[I].ItemIndex - 1];
              SetLength(Export.DestinationFields, Length(Export.DestinationFields) + 1);
              Export.DestinationFields[Length(Export.DestinationFields) - 1].Name := FDestinationFields[I].Text;
            end;
      end
      else
      begin
        for I := 0 to DBObjects.Count - 1 do
          if (Answer <> IDCANCEL) then
          begin
            if ((ExportType = etSQLFile)
              and (TSDBObject(DBObjects[I]).Source = '')
              and (Answer = IDYES)) then
              if (TSDBObject(DBObjects[I]) is TSBaseTable) then
                Answer := MsgBox(Preferences.LoadStr(924, TSDBObject(DBObjects[I]).Database.Name + '.' + TSDBObject(DBObjects[I]).Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
              else if (TSDBObject(DBObjects[I]) is TSView) then
                Answer := MsgBox(Preferences.LoadStr(925, TSDBObject(DBObjects[I]).Database.Name + '.' + TSDBObject(DBObjects[I]).Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
              else if (TSDBObject(DBObjects[I]) is TSProcedure) then
                Answer := MsgBox(Preferences.LoadStr(926, TSDBObject(DBObjects[I]).Database.Name + '.' + TSDBObject(DBObjects[I]).Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
              else if (TSDBObject(DBObjects[I]) is TSFunction) then
                Answer := MsgBox(Preferences.LoadStr(927, TSDBObject(DBObjects[I]).Database.Name + '.' + TSDBObject(DBObjects[I]).Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
              else if (TSDBObject(DBObjects[I]) is TSTrigger) then
                Answer := MsgBox(Preferences.LoadStr(928, TSDBObject(DBObjects[I]).Database.Name + '.' + TSDBObject(DBObjects[I]).Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
              else if (TSDBObject(DBObjects[I]) is TSEvent) then
                Answer := MsgBox(Preferences.LoadStr(929, TSDBObject(DBObjects[I]).Database.Name + '.' + TSDBObject(DBObjects[I]).Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
              else
                raise ERangeError.Create(SRangeError);
            if (Answer = IDNO) then
              Answer := IDCANCEL;

            if ((ExportType <> etSQLFile) or (TSDBObject(DBObjects[I]).Source <> '')) then
              Export.Add(TSDBObject(DBObjects[I]));
          end;

        if ((Answer <> IDCANCEL) and SingleTable) then
          for I := 0 to Length(FSourceFields) - 1 do
            if (FSourceFields[I].ItemIndex > 0) then
            begin
              SetLength(Export.TableFields, Length(Export.TableFields) + 1);
              Export.TableFields[Length(Export.TableFields) - 1] := TSTable(DBObjects[0]).Fields[FSourceFields[I].ItemIndex - 1];
              SetLength(Export.DestinationFields, Length(Export.DestinationFields) + 1);
              if (Length(FDestinationFields) = 0) then
                Export.DestinationFields[Length(Export.DestinationFields) - 1].Name := FSourceFields[I].Text
              else
                Export.DestinationFields[Length(Export.DestinationFields) - 1].Name := Session.ApplyIdentifierName(FDestinationFields[I].Text);
            end;
      end;

      if ((Answer = IDCANCEL) or (Export.Items.Count = 0)) then
      begin
        Export.Free();
        Export := nil;
      end
      else
      begin
        FBBack.Enabled := False;

        Export.Wnd := Handle;
        Export.OnTerminate := OnTerminate;
        Export.OnUpdate := OnUpdate;
        Export.OnError := OnError;
        Export.Start();
      end;
    end;
  end;

  if (Assigned(Wanted.Page)) then
    SetControlCursor(GProgress, crSQLWait)
  else
    SetControlCursor(GProgress, crDefault);

  CheckActivePageChange(TSExecute);
  FBBack.Enabled := False;
  ActiveControl := FBCancel;
end;

procedure TDExport.TSFieldsShow(Sender: TObject);
var
  I: Integer;
  J: Integer;
  K: Integer;
  FieldNames: string;
begin
  Wanted.Page := nil;

  if (SingleTable and not TSTable(DBObjects[0]).Update()) then
    Wanted.Page := TSFields
  else if (Length(FSourceFields) = 0) then
  begin
    FLDestinationFields.Visible :=
      (ExportType = etTextFile) and FCSVHeadline.Checked
      or (ExportType in [etExcelFile, etXMLFile])
      or (ExportType in [etHTMLFile, etPDFFile]) and not FHTMLStructure.Checked;

    if (SingleTable) then
      SetLength(FSourceFields, TSTable(DBObjects[0]).Fields.Count)
    else if (Assigned(DBGrid)) then
      SetLength(FSourceFields, DBGrid.DataSource.DataSet.FieldCount)
    else
      SetLength(FSourceFields, 0);

    if (FLDestinationFields.Visible) then
    begin
      SetLength(FLReferrers, Length(FSourceFields));
      SetLength(FDestinationFields, Length(FSourceFields));
    end;

    FieldNames := #13#10;
    if (SingleTable) then
      for J := 0 to TSTable(DBObjects[0]).Fields.Count - 1 do
        FieldNames := FieldNames + TSTable(DBObjects[0]).Fields[J].Name + #13#10
    else if (Assigned(DBGrid)) then
      for J := 0 to DBGrid.FieldCount - 1 do
        FieldNames := FieldNames + DBGrid.DataSource.DataSet.Fields[J].DisplayName + #13#10;

    ScrollBox.DisableAlign();
    for I := 0 to Length(FSourceFields) - 1 do
    begin
      FSourceFields[I] := TComboBox_Ext.Create(ScrollBox);
      FSourceFields[I].Left := FSourceField1.Left;
      FSourceFields[I].Top := FSourceField1.Top + I * (FSourceField2.Top - FSourceField1.Top);
      FSourceFields[I].Width := FSourceField1.Width;
      FSourceFields[I].Height := FSourceField1.Height;
      FSourceFields[I].Style := FSourceField1.Style;
      FSourceFields[I].OnChange := FSourceField1.OnChange;
      FSourceFields[I].OnExit := FSourceField1.OnExit;
      FSourceFields[I].Parent := ScrollBox;
      FSourceFields[I].Items.Text := FieldNames;
      FSourceFields[I].ItemIndex := I + 1;

      if (FLDestinationFields.Visible) then
      begin
        FLReferrers[I] := TLabel.Create(ScrollBox);
        FLReferrers[I].Left := FLReferrer1.Left;
        FLReferrers[I].Top := FLReferrer1.Top + I * (FSourceField2.Top - FSourceField1.Top);
        FLReferrers[I].Width := FLReferrer1.Width;
        FLReferrers[I].Height := FLReferrer1.Height;
        FLReferrers[I].Caption := FLReferrer1.Caption;

        FDestinationFields[I] := TEdit.Create(ScrollBox);
        FDestinationFields[I].Parent := ScrollBox;
        FDestinationFields[I].Left := FDestinationField1.Left;
        FDestinationFields[I].Top := FDestinationField1.Top + I * (FSourceField2.Top - FSourceField1.Top);
        FDestinationFields[I].Width := FDestinationField1.Width;
        FDestinationFields[I].Height := FDestinationField1.Height;
        FDestinationFields[I].Enabled := ExportType in [etTextFile, etExcelFile, etHTMLFile, etPDFFile, etXMLFile];
        TEdit(FDestinationFields[I]).Text := FSourceFields[I].Text;
        K := 2;
        for J := 0 to I - 1 do
          if (FSourceFields[I].Text = FSourceFields[J].Text) then
          begin
            TEdit(FDestinationFields[I]).Text := FSourceFields[J].Text + '_' + IntToStr(K);
            Inc(K);
          end;
        FDestinationFields[I].OnChange := FDestinationField1.OnChange;
        FLReferrers[I].Parent := ScrollBox;
      end;
    end;

    ScrollBoxResize(ScrollBox);
    ScrollBox.EnableAlign();

    FSourceFieldChange(Sender);
  end;

  if (Assigned(Wanted.Page)) then
    SetControlCursor(GFields, crSQLWait)
  else
    SetControlCursor(GFields, crDefault);

  CheckActivePageChange(TSFields);
end;

procedure TDExport.TSHTMLOptionsShow(Sender: TObject);
begin
  FHTMLStructure.Enabled := not Assigned(DBGrid) or not (DBGrid.DataSource.DataSet is TMySQLTable);
  FHTMLStructure.Checked := FHTMLStructure.Checked and FHTMLStructure.Enabled;
  FHTMLStructureClick(Sender);
  FHTMLDataClick(Sender);

  FHTMLMemoContent.Visible := not (ExportType in [etPDFFile]); FLHTMLViewDatas.Visible := FHTMLMemoContent.Visible;

  CheckActivePageChange(TSHTMLOptions);
end;

procedure TDExport.TSSQLOptionsShow(Sender: TObject);
begin
  FSQLStructure.Enabled := not Assigned(DBGrid) or (DBGrid.DataSource.DataSet is TMySQLTable) and (TMySQLTable(DBGrid.DataSource.DataSet).CommandText <> '');
  FSQLData.Enabled := not Assigned(DBGrid);

  FSQLStructure.Checked := FSQLStructure.Checked and FSQLStructure.Enabled;
  FSQLData.Checked := FSQLData.Checked or Assigned(DBGrid);

  FSQLOptionClick(Sender);
end;

procedure TDExport.TSXMLOptionChange(Sender: TObject);
var
  TabSheet: TTabSheet;
begin
  if (SingleTable) then
    TabSheet := TSFields
  else
    TabSheet := TSExecute;

  TabSheet.Enabled :=
    (FRootNodeText.Text <> '')
    and (not FDatabaseNodeDisabled.Checked or FDatabaseNodeDisabled.Enabled)
    and (not FDatabaseNodeName.Checked or FDatabaseNodeName.Enabled)
    and (not FDatabaseNodeCustom.Checked or FDatabaseNodeCustom.Enabled and (FDatabaseNodeText.Text <> '') and (FDatabaseNodeAttribute.Text <> ''))
    and (not FTableNodeDisabled.Checked or FTableNodeDisabled.Enabled)
    and (not FTableNodeName.Checked or FTableNodeName.Enabled)
    and (not FTableNodeCustom.Checked or FTableNodeCustom.Enabled and (FTableNodeText.Text <> '') and (FTableNodeAttribute.Text <> ''))
    and (FRecordNodeText.Text <> '')
    and (not FFieldNodeName.Checked or FFieldNodeName.Enabled)
    and (not FFieldNodeCustom.Checked or FFieldNodeCustom.Enabled and (FFieldNodeText.Text <> '') and (FFieldNodeAttribute.Text <> ''));
  CheckActivePageChange(TSXMLOptions);

  FDatabaseNodeText.Enabled := FDatabaseNodeCustom.Checked;
  FDatabaseNodeAttribute.Enabled := FDatabaseNodeCustom.Checked;

  FTableNodeText.Enabled := FTableNodeCustom.Checked;
  FTableNodeAttribute.Enabled := FTableNodeCustom.Checked;
end;

procedure TDExport.TSXMLOptionsShow(Sender: TObject);
var
  DatabaseCount: Integer;
  I: Integer;
  OldDatabase: TSDatabase;
begin
  DatabaseCount := 0;
  OldDatabase := nil;
  for I := 0 to DBObjects.Count - 1 do
  begin
    if (TSDBObject(DBObjects[I]).Database <> OldDatabase) then
      Inc(DatabaseCount);
    OldDatabase := TSDBObject(DBObjects[I]).Database;
  end;

  FDatabaseNodeDisabled.Enabled := DatabaseCount <= 1;
  if (FDatabaseNodeDisabled.Checked and not FDatabaseNodeDisabled.Enabled) then
    FDatabaseNodeCustom.Checked := True;

  FTableNodeDisabled.Enabled := SingleTable;
  if (FTableNodeDisabled.Checked and not FTableNodeDisabled.Enabled) then
    FTableNodeCustom.Checked := True;

  CheckActivePageChange(TSXMLOptions);
  TSXMLOptionChange(Sender);
end;

procedure TDExport.UMChangePreferences(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiExport, Icon);

  SaveDialog.EncodingLabel := Preferences.LoadStr(682) + ':';

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  GSQLWhat.Caption := Preferences.LoadStr(227);
  FLSQLWhat.Caption := Preferences.LoadStr(218) + ':';
  FSQLStructure.Caption := Preferences.LoadStr(215);
  FSQLData.Caption := Preferences.LoadStr(216);

  GSQLOptions.Caption := Preferences.LoadStr(238);
  FLDrop.Caption := Preferences.LoadStr(242) + ':';
  FDropStmts.Caption := Preferences.LoadStr(243);
  FReplaceData.Caption := LowerCase(Preferences.LoadStr(416));

  GCSVOptions.Caption := Preferences.LoadStr(238);
  FLCSVHeadline.Caption := Preferences.LoadStr(393) + ':';
  FCSVHeadline.Caption := Preferences.LoadStr(408);
  FLSeparator.Caption := Preferences.LoadStr(352) + ':';
  FSeparatorTab.Caption := Preferences.LoadStr(354);
  FSeparatorChar.Caption := Preferences.LoadStr(355) + ':';
  FLQuoteValues.Caption := Preferences.LoadStr(353) + ':';
  FQuoteNone.Caption := Preferences.LoadStr(359);
  FQuoteStrings.Caption := Preferences.LoadStr(360);
  FQuoteAll.Caption := Preferences.LoadStr(361);
  FLQuoteChar.Caption := Preferences.LoadStr(356) + ':';

  GProgress.Caption := Preferences.LoadStr(224);
  FLEntiered.Caption := Preferences.LoadStr(211) + ':';
  FLDone.Caption := Preferences.LoadStr(232) + ':';
  FLProgressObjects.Caption := Preferences.LoadStr(909) + ':';
  FLProgressRecords.Caption := Preferences.LoadStr(235) + ':';
  FLProgressTime.Caption := Preferences.LoadStr(661) + ':';
  FLErrors.Caption := Preferences.LoadStr(391) + ':';

  GXMLHow.Caption := Preferences.LoadStr(238);
  FLRootNode.Caption := 'Root:';
  FLDatabaseNode.Caption := Preferences.LoadStr(265) + ':';
  FDatabaseNodeDisabled.Caption := Preferences.LoadStr(554);
  FLTableNode.Caption := Preferences.LoadStr(234) + ':';
  FTableNodeDisabled.Caption := Preferences.LoadStr(554);
  FLRecordNode.Caption := Preferences.LoadStr(124) + ':';
  FLFieldNode.Caption := Preferences.LoadStr(253) + ':';

  GHTMLWhat.Caption := Preferences.LoadStr(227);
  FLHTMLWhat.Caption := Preferences.LoadStr(218) + ':';
  FHTMLData.Caption := Preferences.LoadStr(216);

  GHTMLOptions.Caption := Preferences.LoadStr(238);
  FLHTMLNullValues.Caption := Preferences.LoadStr(498) + ':';
  FHTMLNullText.Caption := Preferences.LoadStr(499);
  FLHTMLViewDatas.Caption := Preferences.LoadStr(574) + ':';
  FHTMLMemoContent.Caption := Preferences.LoadStr(575);

  GFields.Caption := Preferences.LoadStr(253);
  FLSourceFields.Caption := Preferences.LoadStr(401) + ':';
  FLDestinationFields.Caption := Preferences.LoadStr(400) + ':';

  GErrors.Caption := Preferences.LoadStr(392);

  FBHelp.Caption := Preferences.LoadStr(167);
  FBBack.Caption := '< ' + Preferences.LoadStr(228);
end;

procedure TDExport.UMPostAfterExecuteSQL(var Message: TMessage);
begin
  if (Assigned(Wanted.Page) and Assigned(Wanted.Page.OnShow)) then
    Wanted.Page.OnShow(nil);
end;

procedure TDExport.UMTerminate(var Message: TMessage);
var
  Success: Boolean;
begin
  Success := Boolean(Message.WParam);

  Export.WaitFor();
  Export.Free();
  Export := nil;

  if (not Application.Active) then
    FlashWindow(Application.Handle, True);

  FBBack.Enabled := True;
  FBCancel.Enabled := True;
  EnableMenuItem(GetSystemMenu(Handle, FALSE), SC_CLOSE, MF_BYCOMMAND or MF_ENABLED);
  FBCancel.Caption := Preferences.LoadStr(231);
  if (Success) then
    FBCancel.ModalResult := mrOk
  else
    FBCancel.ModalResult := mrCancel;
end;

procedure TDExport.UMToolError(var Message: TMessage);
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
        Msg := Preferences.LoadStr(165, IntToStr(Session.Connection.ErrorCode), Session.Connection.ErrorMessage);
        ErrorMsg := Details^.Error.ErrorMessage
          + ' (#' + IntToStr(Details^.Error.ErrorCode) + ') - ' + Trim(Session.Connection.ErrorCommandText);
      end;
    TE_File:
      begin
        Msg := Details^.Error.ErrorMessage + ' (#' + IntToStr(Details^.Error.ErrorCode) + ')';
        ErrorMsg := Msg;
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

procedure TDExport.UMUpdateProgressInfo(var Message: TMessage);
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

initialization
  FDExport := nil;
end.


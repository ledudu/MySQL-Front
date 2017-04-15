unit uDSearch;

interface {********************************************************************}

uses
  Windows, Messages, RichEdit,
  SysUtils, Classes,
  DB,
  Graphics, Controls, Forms, Menus, Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  ComCtrls_Ext, Forms_Ext, StdCtrls_Ext, ExtCtrls_Ext,
  uSession, uPreferences, uTools,
  uBase, uFSession;

type
  TDSearch = class(TForm_Ext)
    FBBack: TButton;
    FBCancel: TButton;
    FBForward: TButton;
    FBHelp: TButton;
    FDBObjects: TListView_Ext;
    FDoneRecords: TLabel;
    FDoneObjects: TLabel;
    FDoneTime: TLabel;
    FEntieredRecords: TLabel;
    FEntieredObjects: TLabel;
    FEntieredTime: TLabel;
    FErrorMessages: TRichEdit;
    FErrors: TLabel;
    FFFindText: TComboBox_Ext;
    FFMatchCase: TCheckBox;
    FFRegExpr: TCheckBox;
    FFWholeValue: TCheckBox;
    FLDone: TLabel;
    FLEntiered: TLabel;
    FLErrors: TLabel;
    FLFFindText: TLabel;
    FLFSearchOptions: TLabel;
    FLProgressRecords: TLabel;
    FLProgressObjects: TLabel;
    FLProgressTime: TLabel;
    FLReplaceText: TLabel;
    FLRFindText: TLabel;
    FLRSearchOptions: TLabel;
    FProgressBar: TProgressBar;
    FReplaceText: TComboBox_Ext;
    FRFindText: TComboBox_Ext;
    FRMatchCase: TCheckBox;
    FRRegExpr: TCheckBox;
    FRWholeValue: TCheckBox;
    FSelect: TTreeView_Ext;
    GFOptions: TGroupBox_Ext;
    GFWhat: TGroupBox_Ext;
    GMessages: TGroupBox_Ext;
    GProgress: TGroupBox_Ext;
    GROptions: TGroupBox_Ext;
    GRWhat: TGroupBox_Ext;
    GSelect: TGroupBox_Ext;
    MTables: TPopupMenu;
    mTCopy: TMenuItem;
    PageControl: TPageControl;
    PErrorMessages: TPanel_Ext;
    PSelect: TPanel_Ext;
    TSExecute: TTabSheet;
    TSFOptions: TTabSheet;
    TSROptions: TTabSheet;
    TSSelect: TTabSheet;
    procedure FBBackClick(Sender: TObject);
    procedure FBForwardClick(Sender: TObject);
    procedure FBHelpClick(Sender: TObject);
    procedure FDBObjectsDblClick(Sender: TObject);
    procedure FDBObjectsKeyPress(Sender: TObject; var Key: Char);
    procedure FFFindTextChange(Sender: TObject);
    procedure FFRegExprClick(Sender: TObject);
    procedure FFRegExprKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FRFindTextChange(Sender: TObject);
    procedure FRRegExprClick(Sender: TObject);
    procedure FRRegExprKeyPress(Sender: TObject; var Key: Char);
    procedure FSelectChange(Sender: TObject; Node: TTreeNode);
    procedure FSelectExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure FSelectGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure mTCopyClick(Sender: TObject);
    procedure TSExecuteShow(Sender: TObject);
    procedure TSExecuteResize(Sender: TObject);
    procedure TSFOptionsShow(Sender: TObject);
    procedure TSROptionsShow(Sender: TObject);
    procedure TSSelectShow(Sender: TObject);
  private
    ExecuteSession: TSSession;
    ProgressInfos: TTool.TProgressInfos;
    ReplaceSession: TSSession;
    Search: TTSearch;
    Sessions: array of record
      Created: Boolean;
      Session: TSSession;
    end;
    Space: Integer;
    Wanted: record
      Node: TTreeNode;
      Page: TTabSheet;
    end;
    procedure CheckActivePageChange(const ActivePage: TTabSheet);
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    function GetSession(const TreeNode: TTreeNode): TSSession;
    function OnError(const Details: TTool.TErrorDetails): TDataAction;
    procedure OnSearched(const AItem: TTSearch.TItem);
    procedure OnTerminate(Sender: TObject);
    procedure OnUpdate(const AProgressInfos: TTool.TProgressInfos);
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
    procedure UMPostAfterExecuteSQL(var Message: TMessage); message UM_POST_AFTEREXECUTESQL;
    procedure UMTerminate(var Message: TMessage); message UM_TERMINATE;
    procedure UMToolError(var Message: TMessage); message UM_TOOL_ERROR;
    procedure UMUpdateProgressInfo(var Message: TMessage); message UM_UPDATEPROGRESSINFO;
  public
    Session: TSSession;
    Database: TSDatabase;
    Tab: TFSession;
    SearchOnly: Boolean;
    SearchType: TSearchType;
    function Execute(): Boolean;
  end;

function DSearch(): TDSearch;

implementation {***************************************************************}

{$R *.dfm}

uses
  CommCtrl,
  Consts, StrUtils, SysConst,
  SQLUtils,
  uURI,
  uDConnecting;

var
  FDSearch: TDSearch;

function DSearch(): TDSearch;
begin
  if (not Assigned(FDSearch)) then
  begin
    Application.CreateForm(TDSearch, FDSearch);
    FDSearch.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDSearch;
end;

{ TDSearch ********************************************************************}

procedure TDSearch.CheckActivePageChange(const ActivePage: TTabSheet);
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

function TDSearch.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDSearch.FBBackClick(Sender: TObject);
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

procedure TDSearch.FBForwardClick(Sender: TObject);
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

procedure TDSearch.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDSearch.FDBObjectsDblClick(Sender: TObject);
var
  Result: Boolean;
  URI: TUURI;
  FSession: TFSession;
begin
  if (Assigned(FDBObjects.Selected)) then
  begin
    URI := TUURI.Create('');

    URI.Scheme := 'mysql';
    URI.Host := TSTable(FDBObjects.Selected.Data).Database.Session.Account.Connection.Host;
    URI.Port := TSTable(FDBObjects.Selected.Data).Database.Session.Account.Connection.Port;
    URI.Database := TSTable(FDBObjects.Selected.Data).Database.Name;
    URI.Table := TSTable(FDBObjects.Selected.Data).Name;
    URI.Param['view'] := 'browser';

    if (Assigned(Tab)) then
      FSession := Tab
    else
      FSession := TFSession(TSTable(FDBObjects.Selected.Data).Database.Session.Account.FirstTab());

    Result := True;
    if (Assigned(FSession)) then
      FSession.CurrentAddress := URI.Address
    else
      Result := Boolean(SendMessage(Application.MainForm.Handle, UM_ADDTAB, 0, LPARAM(URI.Address)));

    URI.Free();

    if (Result) then
      FBCancel.Click();
  end;
end;

procedure TDSearch.FDBObjectsKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
    FDBObjectsDblClick(Sender)
  else
    MessageBeep(MB_ICONERROR);
end;

procedure TDSearch.FFFindTextChange(Sender: TObject);
begin
  TSExecute.Enabled := Trim(FFFindText.Text) <> '';

  CheckActivePageChange(TSFOptions);
end;

procedure TDSearch.FFRegExprClick(Sender: TObject);
begin
  FFWholeValue.Enabled := not FFRegExpr.Checked;
end;

procedure TDSearch.FFRegExprKeyPress(Sender: TObject; var Key: Char);
begin
  FFRegExprClick(Sender);
end;

procedure TDSearch.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (Assigned(Search)) then
  begin
    Search.Terminate();
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

procedure TDSearch.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  Space := (FLEntiered.Left + FLEntiered.Width) - (FLDone.Left + FLDone.Width);

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  Search := nil;

  FSelect.Images := Preferences.Images;
  FDBObjects.SmallImages := Preferences.Images;

  FFFindText.Items.Clear();
  for I := Preferences.Find.FindTextMRU.Count - 1 downto 0 do
    FFFindText.Items.Add(Preferences.Find.FindTextMRU[I]);
  FFFindText.Text := '';

  FFMatchCase.Checked := foMatchCase in Preferences.Find.Options;
  FFWholeValue.Checked := foWholeValue in Preferences.Find.Options;
  FFRegExpr.Checked := foRegExpr in Preferences.Find.Options;
  FFRegExprClick(Sender);

  FRFindText.Items.Clear();
  for I := Preferences.Replace.FindTextMRU.Count - 1 downto 0 do
    FRFindText.Items.Add(Preferences.Replace.FindTextMRU[I]);
  FRFindText.Text := '';
  FReplaceText.Items.Clear();
  for I := Preferences.Replace.ReplaceTextMRU.Count - 1 downto 0 do
    FReplaceText.Items.Add(Preferences.Replace.ReplaceTextMRU[I]);
  FReplaceText.Text := '';

  FRMatchCase.Checked := roMatchCase in Preferences.Replace.Options;
  FRWholeValue.Checked := roWholeValue in Preferences.Replace.Options;
  FRRegExpr.Checked := roRegExpr in Preferences.Replace.Options;
  FRRegExprClick(Sender);

  SendMessage(FErrorMessages.Handle, EM_SETTEXTMODE, TM_PLAINTEXT, 0);
  SendMessage(FErrorMessages.Handle, EM_SETWORDBREAKPROC, 0, LPARAM(@EditWordBreakProc));

  PageControl.ActivePage := nil;
end;

procedure TDSearch.FormHide(Sender: TObject);
var
  I: Integer;
begin
  FSelect.Selected := nil;
  FSelect.Items.BeginUpdate();
  FSelect.Items.Clear();
  FSelect.Items.EndUpdate();
  FDBObjects.Items.BeginUpdate();
  FDBObjects.Items.Clear();
  FDBObjects.Items.EndUpdate();

  for I := 0 to Length(Sessions) - 1 do
    if (Assigned(Sessions[I].Session)) then
    begin
      Sessions[I].Session.UnRegisterEventProc(FormSessionEvent);
      if (Sessions[I].Created) then
        Sessions[I].Session.Free();
    end;
  SetLength(Sessions, 0);

  if (SearchOnly) then
  begin
    Preferences.Find.Height := Height;
    Preferences.Find.Width := Width;
    Preferences.Find.Left := Left;
    Preferences.Find.Top := Top;
  end
  else
  begin
    Preferences.Replace.Height := Height;
    Preferences.Replace.Width := Width;
    Preferences.Replace.Left := Left;
    Preferences.Replace.Top := Top;
  end;

  PageControl.ActivePage := nil;
end;

procedure TDSearch.FormSessionEvent(const Event: TSSession.TEvent);
begin
  if (Event.EventType in [etAfterExecuteSQL]) then
  begin
    if (Assigned(Wanted.Node) or Assigned(Wanted.Page) and Assigned(Wanted.Page.OnShow)) then
      PostMessage(Handle, UM_POST_AFTEREXECUTESQL, 0, 0);
  end;
end;

procedure TDSearch.FormShow(Sender: TObject);
var
  I: Integer;
begin
  if (SearchOnly) then
  begin
    Caption := Preferences.LoadStr(187);
    Preferences.Images.GetIcon(12, Icon);
    HelpContext := 1093;

    GMessages.Caption := Preferences.LoadStr(234);

    if ((Preferences.Find.Width > 0) and (Preferences.Find.Height > 0)) then
    begin
      Width := Preferences.Find.Width;
      Height := Preferences.Find.Height;
    end
    else
    begin
      Width := Constraints.MinWidth;
      Height := Constraints.MinHeight;
    end;
    if ((Preferences.Find.Left > 0) and (Preferences.Find.Top > 0)) then
    begin
      Left := Preferences.Find.Left;
      Top := Preferences.Find.Top;
    end;
  end
  else
  begin
    Caption := Preferences.LoadStr(416);
    Preferences.Images.GetIcon(29, Icon);
    HelpContext := 1090;

    GMessages.Caption := Preferences.LoadStr(392);

    if ((Preferences.Replace.Width > 0) and (Preferences.Replace.Height > 0)) then
    begin
      Width := Preferences.Replace.Width;
      Height := Preferences.Replace.Height;
    end
    else
    begin
      Width := Constraints.MinWidth;
      Height := Constraints.MinHeight;
    end;
    if ((Preferences.Replace.Left > 0) and (Preferences.Replace.Top > 0)) then
    begin
      Left := Preferences.Replace.Left;
      Top := Preferences.Replace.Top;
    end;
  end;

  ExecuteSession := nil;
  Wanted.Node := nil;
  Wanted.Page := nil;
  FErrorMessages.Visible := not SearchOnly;
  FDBObjects.Visible := SearchOnly;

  SetLength(Sessions, Accounts.Count);
  for I := 0 to Length(Sessions) - 1 do
  begin
    Sessions[I].Created := False;
    Sessions[I].Session := nil;
  end;

  TSFOptions.Enabled := SearchOnly;
  TSROptions.Enabled := not SearchOnly;
  TSExecute.Enabled := False;

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

procedure TDSearch.FRFindTextChange(Sender: TObject);
begin
  TSExecute.Enabled := (Trim(FRFindText.Text) <> '')
    and (Trim(FReplaceText.Text) <> '')
    and (Trim(FRFindText.Text) <> Trim(FReplaceText.Text));

  CheckActivePageChange(TSFOptions);
end;

procedure TDSearch.FRRegExprClick(Sender: TObject);
begin
  FRWholeValue.Enabled := not FRRegExpr.Checked;
end;

procedure TDSearch.FRRegExprKeyPress(Sender: TObject; var Key: Char);
begin
  FRRegExprClick(Sender);
end;

procedure TDSearch.FSelectChange(Sender: TObject; Node: TTreeNode);
begin
  if ((ModalResult = mrNone) and Assigned(Node)) then
    FSelect.MultiSelect := Assigned(Node.Parent);

  TSFOptions.Enabled := SearchOnly and Assigned(Node);
  TSROptions.Enabled := not SearchOnly and Assigned(Node);

  CheckActivePageChange(TSSelect);
end;

procedure TDSearch.FSelectExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
var
  Session: TSSession;
  Database: TSDatabase;
  I: Integer;
  NewNode: TTreeNode;
  Table: TSTable;
  TreeView: TTreeView_Ext;
begin
  TreeView := TTreeView_Ext(Sender);

  if (Assigned(Wanted.Node)) then
    Wanted.Node := nil;

  if (Assigned(Node)) then
    if (Node.HasChildren and not Assigned(Node.getFirstChild())) then
    begin
      case (Node.ImageIndex) of
        iiServer:
          begin
            Session := GetSession(Node);
            if (Assigned(Session)) then
            begin
              Node.Data := Session;
              if (not Session.Update()) then
                Wanted.Node := Node
              else
              begin
                for I := 0 to Session.Databases.Count - 1 do
                  if (not (Session.Databases[I] is TSSystemDatabase)) then
                  begin
                    NewNode := TreeView.Items.AddChild(Node, Session.Databases[I].Name);
                    NewNode.ImageIndex := iiDatabase;
                    NewNode.Data := Session.Databases[I];
                    NewNode.HasChildren := True;
                  end;
                Node.HasChildren := Assigned(Node.getFirstChild());
              end;
            end;
          end;
        iiDatabase:
          begin
            Database := TSDatabase(Node.Data);
            if (not Database.Tables.Update()) then
              Wanted.Node := Node
            else
            begin
              for I := 0 to Database.Tables.Count - 1 do
                if (Database.Tables[I] is TSBaseTable) then
                begin
                  NewNode := TreeView.Items.AddChild(Node, Database.Tables[I].Name);
                  NewNode.ImageIndex := iiBaseTable;
                  NewNode.Data := Database.Tables[I];
                  NewNode.HasChildren := True;
                end
                else if ((Database.Tables[I] is TSView) and SearchOnly) then
                begin
                  NewNode := TreeView.Items.AddChild(Node, Database.Tables[I].Name);
                  NewNode.ImageIndex := iiView;
                  NewNode.Data := Database.Tables[I];
                  NewNode.HasChildren := True;
                end;
              Node.HasChildren := Assigned(Node.getFirstChild());
            end;
          end;
        iiBaseTable,
        iiView:
          begin
            Table := TSTable(Node.Data);
            if (not Table.Update() or (Table is TSBaseTable) and Assigned(Table.Database.Triggers) and not Table.Database.Triggers.Update()) then
              Wanted.Node := Node
            else
            begin
              for I := 0 to Table.Fields.Count - 1 do
              begin
                NewNode := TreeView.Items.AddChild(Node, Table.Fields[I].Name);
                if (Table is TSView) then
                  NewNode.ImageIndex := iiViewField
                else if (TSBaseField(Table.Fields[I]).FieldKind = mkVirtual) then
                  NewNode.ImageIndex := iiVirtualField
                else
                  NewNode.ImageIndex := iiBaseField;
                NewNode.Data := Table.Fields[I];
              end;
              Node.HasChildren := Assigned(Node.getFirstChild());
            end;
          end;
      end;
    end;

  if (not Assigned(Wanted.Node)) then
    TreeView.Cursor := crDefault
  else
    TreeView.Cursor := crSQLWait;
end;

procedure TDSearch.FSelectGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

function TDSearch.GetSession(const TreeNode: TTreeNode): TSSession;
var
  Index: Integer;
  Node: TTreeNode;
begin
  Node := TreeNode;
  while (Assigned(Node.Parent)) do
    Node := Node.Parent;

  if (not Assigned(Node.Data)) then
  begin
    Index := Node.Index; // Cache for speeding - Index is slow

    if (Assigned(Session) and (Session.Account = Accounts[Index])) then
      Sessions[Index].Session := Session;

    if (not Assigned(Sessions[Index].Session)) then
      Sessions[Index].Session := uSession.Sessions.SessionByAccount(Accounts[Index]);

    if (not Assigned(Sessions[Index].Session)) then
    begin
      DConnecting.Session := TSSession.Create(uSession.Sessions, Accounts[Index]);
      if (not DConnecting.Execute()) then
        DConnecting.Session.Free()
      else
      begin
        Sessions[Index].Created := True;
        Sessions[Index].Session := DConnecting.Session;
      end;
    end;

    if (Assigned(Sessions[Index].Session)) then
      Sessions[Index].Session.RegisterEventProc(FormSessionEvent);

    Node.Data := Sessions[Index].Session;
  end;

  Result := TSSession(Node.Data);
end;

procedure TDSearch.mTCopyClick(Sender: TObject);
var
  ClipboardData: HGLOBAL;
  I: Integer;
  S: string;
begin
  S := '';
  for I := 0 to FDBObjects.Items.Count - 1 do
    if ((FDBObjects.SelCount = 0) or FDBObjects.Items[I].Selected) then
      S := S + FDBObjects.Items[I].Caption + #13#10;

  if ((S <> '') and OpenClipboard(Handle)) then
  begin
    try
      EmptyClipboard();

      ClipboardData := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, SizeOf(S[1]) * (Length(S) + 1));
      StrPCopy(GlobalLock(ClipboardData), S);
      SetClipboardData(CF_UNICODETEXT, ClipboardData);
      GlobalUnlock(ClipboardData);
    finally
      CloseClipboard();
    end;
  end;
end;

function TDSearch.OnError(const Details: TTool.TErrorDetails): TDataAction;
begin
  Result := TDataAction(SendMessage(Handle, UM_TOOL_ERROR, 0, LPARAM(@Details)));
end;

procedure TDSearch.OnSearched(const AItem: TTSearch.TItem);
var
  Item: TListItem;
begin
  if (AItem.Done and (AItem.RecordsFound > 0)) then
  begin
    Item := FDBObjects.Items.Add();
    if (AItem.SObject is TSDatabase) then
      Item.Caption := AItem.SObject.Name + ' (' + IntToStr(AItem.RecordsFound) + ')'
    else if (AItem.SObject is TSDBObject) then
      Item.Caption := TSDBObject(AItem.SObject).Database.Name + '.' + AItem.SObject.Name + ' (' + IntToStr(AItem.RecordsFound) + ')'
    else
      raise ERangeError.Create(SRangeError);
    if (AItem.SObject is TSDatabase) then
      Item.ImageIndex := iiDatabase
    else if (AItem.SObject is TSBaseTable) then
      Item.ImageIndex := iiBaseTable
    else if (AItem.SObject is TSView) then
      Item.ImageIndex := iiView
    else if (AItem.SObject is TSProcedure) then
      Item.ImageIndex := iiProcedure
    else if (AItem.SObject is TSFunction) then
      Item.ImageIndex := iiFunction
    else if (AItem.SObject is TSTrigger) then
      Item.ImageIndex := iiTrigger
    else if (AItem.SObject is TSEvent) then
      Item.ImageIndex := iiEvent;
    Item.Data := AItem.SObject;
  end;
end;

procedure TDSearch.OnTerminate(Sender: TObject);
begin
  PostMessage(Handle, UM_TERMINATE, WPARAM(not Search.Terminated), 0);
end;

procedure TDSearch.OnUpdate(const AProgressInfos: TTool.TProgressInfos);
begin
  MoveMemory(@ProgressInfos, @AProgressInfos, SizeOf(AProgressInfos));

  PostMessage(Handle, UM_UPDATEPROGRESSINFO, 0, LPARAM(@ProgressInfos))
end;

procedure TDSearch.TSExecuteResize(Sender: TObject);
begin
  FLEntiered.Left := GProgress.ClientWidth - FLProgressObjects.Left - FLEntiered.Width;
  FLDone.Left := GProgress.ClientWidth - FLProgressObjects.Left - Space - FLDone.Width;
  FEntieredObjects.Left := GProgress.ClientWidth - FLProgressObjects.Left - FEntieredObjects.Width;
  FDoneObjects.Left := GProgress.ClientWidth - FLProgressObjects.Left - Space - FDoneObjects.Width;
  FEntieredRecords.Left := GProgress.ClientWidth - FLProgressObjects.Left - FEntieredRecords.Width;
  FDoneRecords.Left := GProgress.ClientWidth - FLProgressObjects.Left - Space - FDoneRecords.Width;
  FEntieredTime.Left := GProgress.ClientWidth - FLProgressObjects.Left - FEntieredTime.Width;
  FDoneTime.Left := GProgress.ClientWidth - FLProgressObjects.Left - Space - FDoneTime.Width;
  FErrors.Left := GProgress.ClientWidth - FLProgressObjects.Left - FErrors.Width;
end;

procedure TDSearch.TSExecuteShow(Sender: TObject);

  procedure InitializeNode(const Session: TSSession; const Node: TTreeNode);
  var
    I: Integer;
    Objects: TList;
  begin
    // Debug 2017-04-03
    Assert(Assigned(Session));

    Objects := TList.Create();
    case (Node.ImageIndex) of
      iiServer:
        if (not Session.Update() or not Session.Update(Session.Databases)) then
          Wanted.Page := TSExecute
        else
          for I := 0 to Session.Databases.Count - 1 do
            if (not (Session.Databases[I] is TSSystemDatabase)) then
              Objects.Add(Session.Databases[I]);
      iiDatabase:
        for I := 0 to Node.Parent.Count - 1 do
          if (Node.Parent[I].Selected) then
            Objects.Add(TSDatabase(Node.Parent[I].Data).Tables);
    end;
    if (not Assigned(Wanted.Page) and not Session.Update(Objects)) then
      Wanted.Page := TSExecute;
    Objects.Free();
  end;

var
  Database: TSDatabase;
  I: Integer;
  J: Integer;
  K: Integer;
  List: TList;
  Node: TTreeNode;
  Table: TSTable;
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
  FDBObjects.Items.BeginUpdate();
  FDBObjects.Items.Clear();
  FDBObjects.Items.EndUpdate();

  Wanted.Page := nil;

  Node := FSelect.Selected;
  while (Assigned(Node.Parent)) do Node := Node.Parent;
  ExecuteSession := TSSession(Node.Data);
  if (not Assigned(ExecuteSession) and not Assigned(Node.Parent)) then
    ExecuteSession := GetSession(Node);
  InitializeNode(ExecuteSession, FSelect.Selected);

  if (not Assigned(Wanted.Page)) then
  begin
    Preferences.Find.FindTextMRU.Add(Trim(FFFindText.Text));

    Preferences.Find.Options := [];
    if (FFMatchCase.Checked) then
      Include(Preferences.Find.Options, foMatchCase);
    if (FFWholeValue.Checked) then
      Include(Preferences.Find.Options, foWholeValue);
    if (FFRegExpr.Checked) then
      Include(Preferences.Find.Options, foRegExpr);

    Preferences.Replace.FindTextMRU.Add(Trim(FRFindText.Text));
    Preferences.Replace.ReplaceTextMRU.Add(Trim(FReplaceText.Text));

    Preferences.Replace.Options := [];
    if (FRMatchCase.Checked) then
      Include(Preferences.Replace.Options, roMatchCase);
    if (FRWholeValue.Checked) then
      Include(Preferences.Replace.Options, roWholeValue);
    if (FRRegExpr.Checked) then
      Include(Preferences.Replace.Options, roRegExpr);

    if (SearchOnly) then
    begin
      Search := TTSearch.Create(ExecuteSession);
      Search.Wnd := Self.Handle;
      Search.FindText := Trim(FFFindText.Text);
      Search.MatchCase := FFMatchCase.Checked;
      Search.RegExpr := FFRegExpr.Checked;
      Search.WholeValue := FFWholeValue.Checked;
    end
    else
    begin
      DConnecting.Session := TSSession.Create(uSession.Sessions, ExecuteSession.Account);
      if (not DConnecting.Execute()) then
        DConnecting.Session.Free()
      else
      begin
        ReplaceSession := DConnecting.Session;
        Search := TTReplace.Create(ExecuteSession, ReplaceSession);

        TTReplace(Search).Wnd := Self.Handle;
        TTReplace(Search).OnError := OnError;
        TTReplace(Search).FindText := Trim(FRFindText.Text);
        TTReplace(Search).ReplaceText := Trim(FReplaceText.Text);
        TTReplace(Search).MatchCase := FRMatchCase.Checked;
        TTReplace(Search).WholeValue := FRWholeValue.Checked;
        TTReplace(Search).RegExpr := FRRegExpr.Checked;
      end;
    end;
    Search.OnSearched := OnSearched;

    List := TList.Create();
    for I := 0 to FSelect.Items.Count - 1 do
      if (FSelect.Items[I].Selected) then
        if (FSelect.Items[I].ImageIndex = iiServer) then
        begin
          for K := 0 to ExecuteSession.Databases.Count - 1 do
          begin
            Database := ExecuteSession.Databases[K];
            if (not (Database is TSSystemDatabase)) then
              for J := 0 to Database.Tables.Count - 1 do
              begin
                Table := Database.Tables[J];
                List.Add(Table);
                Search.Add(Table, nil);
              end;
          end;
        end
        else if (FSelect.Items[I].ImageIndex = iiDatabase) then
        begin
          Database := ExecuteSession.DatabaseByName(FSelect.Items[I].Text);
          for J := 0 to Database.Tables.Count - 1 do
          begin
            Table := Database.Tables[J];
            List.Add(Table);
            Search.Add(Table);
          end;
        end
        else if (FSelect.Items[I].ImageIndex in [iiBaseTable, iiView]) then
        begin
          Table := TSTable(FSelect.Items[I].Data);
          List.Add(Table);
          Search.Add(Table);
        end
        else if (FSelect.Items[I].ImageIndex in [iiProcedure, iiFunction, iiTrigger, iiEvent]) then
          Search.Add(FSelect.Items[I].Data)
        else if (FSelect.Selected.ImageIndex in [iiBaseField, iiViewField, iiVirtualField]) then
        begin
          Table := TSTable(FSelect.Items[I].Parent.Data);
          List.Add(Table);
          Search.Add(Table, Table.FieldByName(FSelect.Items[I].Text));
        end
        else if (FSelect.Items[I].ImageIndex in [iiBaseTable, iiView]) then
        begin
          Table := TSTable(FSelect.Items[I].Data);
          List.Add(Table);
          Search.Add(Table);
        end
        else
          raise ERangeError.Create(SRangeError);
    if (not SearchOnly) then
      for I := 0 to List.Count - 1 do
        if (TObject(List) is TSTable) then
          TSTable(List[I]).InvalidateData();
    List.Free();

    FBBack.Enabled := False;

    Search.OnTerminate := OnTerminate;
    Search.OnUpdate := OnUpdate;
    Search.Start();
  end;

  if (Assigned(Wanted.Page)) then
    SetControlCursor(GProgress, crSQLWait)
  else
    SetControlCursor(GProgress, crDefault);

  CheckActivePageChange(TSExecute);
  FBBack.Enabled := False;
  ActiveControl := FBCancel;
end;

procedure TDSearch.TSFOptionsShow(Sender: TObject);
begin
  FFFindTextChange(Sender);

  CheckActivePageChange(TSFOptions);
end;

procedure TDSearch.TSROptionsShow(Sender: TObject);
begin
  CheckActivePageChange(TSROptions);
end;

procedure TDSearch.TSSelectShow(Sender: TObject);
var
  I: Integer;
  J: Integer;
  Node: TTreeNode;
begin
  if (FSelect.Items.Count = 0) then
    for I := 0 to Accounts.Count - 1 do
    begin
      Node := FSelect.Items.Add(nil, Accounts[I].Name);
      Node.ImageIndex := iiServer;
      Node.HasChildren := True;

      if (Assigned(Session) and (Accounts[I] = Session.Account) and Session.Databases.Valid) then
      begin
        FSelect.Selected := Node;
        Node.Expand(False);
        if (Assigned(Database)) then
          for J := 0 to Node.Count - 1 do
            if (Node[J].Data = Database) then
            begin
              FSelect.Selected := Node[J];
              Node[J].Expand(False);
            end;
      end;
    end;

  FSelectChange(Sender, FSelect.Selected);
  CheckActivePageChange(TSSelect);
end;

procedure TDSearch.UMChangePreferences(var Message: TMessage);
begin
  GSelect.Caption := Preferences.LoadStr(721);

  GFWhat.Caption := Preferences.LoadStr(227);
  FLFFindText.Caption := Preferences.LoadStr(719) + ':';

  GFOptions.Caption := Preferences.LoadStr(238);
  FLFSearchOptions.Caption := Preferences.LoadStr(715) + ':';
  FFMatchCase.Caption := Preferences.LoadStr(716);
  FFWholeValue.Caption := Preferences.LoadStr(717);
  FFRegExpr.Caption := Preferences.LoadStr(718);

  GRWhat.Caption := Preferences.LoadStr(227);
  FLRFindText.Caption := Preferences.LoadStr(719) + ':';
  FLRFindText.Caption := Preferences.LoadStr(719) + ':';
  FLReplaceText.Caption := Preferences.LoadStr(720) + ':';

  GROptions.Caption := Preferences.LoadStr(238);
  FLRSearchOptions.Caption := Preferences.LoadStr(715) + ':';
  FRMatchCase.Caption := Preferences.LoadStr(716);
  FRWholeValue.Caption := Preferences.LoadStr(717);
  FRRegExpr.Caption := Preferences.LoadStr(718);

  GProgress.Caption := Preferences.LoadStr(224);
  FLEntiered.Caption := Preferences.LoadStr(211);
  FLDone.Caption := Preferences.LoadStr(232);
  FLProgressObjects.Caption := Preferences.LoadStr(234) + ':';
  FLProgressRecords.Caption := Preferences.LoadStr(235) + ':';
  FLProgressTime.Caption := Preferences.LoadStr(661) + ':';
  FLErrors.Caption := Preferences.LoadStr(391) + ':';

  mtCopy.Caption := MainAction('aECopy').Caption;

  FBHelp.Caption := Preferences.LoadStr(167);
  FBBack.Caption := '< ' + Preferences.LoadStr(228);
end;

procedure TDSearch.UMPostAfterExecuteSQL(var Message: TMessage);
var
  Node: TTreeNode;
begin
  if (Assigned(Wanted.Node)) then
  begin
    Node := Wanted.Node;
    Wanted.Node := nil;
    Node.Expand(False);
  end
  else if (Assigned(Wanted.Page)) then
  begin
    Wanted.Page.OnShow(nil);
  end;
end;

procedure TDSearch.UMTerminate(var Message: TMessage);
var
  Success: Boolean;
begin
  Success := Boolean(Message.WParam);

  if (Success and SearchOnly and (FDBObjects.Items.Count = 0)) then
    MsgBox(Preferences.LoadStr(533, Search.FindText), Preferences.LoadStr(43), MB_OK + MB_ICONINFORMATION);

  Search.WaitFor();
  Search.Free();
  Search := nil;

  ReplaceSession.Free();

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

procedure TDSearch.UMToolError(var Message: TMessage);
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
          + ' (#' + IntToStr(Details^.Error.ErrorCode) + ') - ' + Trim(Session.Connection.ErrorCommandText);
      end;
    TE_File:
      begin
        Msg := Details^.Error.ErrorMessage + ' (#' + IntToStr(Details^.Error.ErrorCode) + ')';
        ErrorMsg := Msg;
      end;
    TE_NoPrimaryIndex:
      if (TTSearch.TItem(Details^.Item).SObject is TSBaseTable) then
        Msg := Preferences.LoadStr(722, TSBaseTable(TTSearch.TItem(Details^.Item).SObject).Database.Name + '.' + TTSearch.TItem(Details^.Item).SObject.Name)
      else
        raise ERangeError.Create(SRangeError);
    else
      Msg := Details^.Error.ErrorMessage;
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

procedure TDSearch.UMUpdateProgressInfo(var Message: TMessage);
var
  Infos: TTool.PProgressInfos;
begin
  Infos := TTool.PProgressInfos(Message.LParam);

  if (Infos.ObjectsSum < 0) then
    FEntieredObjects.Caption := '???'
  else
    FEntieredObjects.Caption := FormatFloat('#,##0', Infos.ObjectsSum, LocaleFormatSettings);
  if (Infos.ObjectsDone < 0) then
    FDoneObjects.Caption := '???'
  else
    FDoneObjects.Caption := FormatFloat('#,##0', Infos.ObjectsDone, LocaleFormatSettings);

  if (Infos.RecordsSum < 0) then
    FEntieredRecords.Caption := '???'
  else
    FEntieredRecords.Caption := FormatFloat('#,##0', Infos.RecordsSum, LocaleFormatSettings);
  if (Infos.RecordsDone < 0) then
    FDoneRecords.Caption := '???'
  else
    FDoneRecords.Caption := FormatFloat('#,##0', Infos.RecordsDone, LocaleFormatSettings);

  FEntieredTime.Caption := TimeToStr(Infos.TimeSum, DurationFormatSettings);
  FDoneTime.Caption := TimeToStr(Infos.TimeDone, DurationFormatSettings);

  FProgressBar.Position := Infos.Progress;
end;

initialization
  FDSearch := nil;
end.


unit uDTransfer;

interface {********************************************************************}

uses
  Windows, Messages, RichEdit,
  SysUtils, Classes,
  DB,
  Graphics, Controls, Forms, Dialogs, ComCtrls, ExtCtrls, StdCtrls, Menus,
  ComCtrls_Ext, Forms_Ext, ExtCtrls_Ext, StdCtrls_Ext,
  MySQLDB,
  uSession, uTools,
  uBase;

type
  TDTransfer = class(TForm_Ext)
    FBBack: TButton;
    FBCancel: TButton;
    FBForward: TButton;
    FBHelp: TButton;
    FData: TCheckBox;
    FDestination: TTreeView_Ext;
    FDoneRecords: TLabel;
    FDoneObjects: TLabel;
    FDoneTime: TLabel;
    FEntieredRecords: TLabel;
    FEntieredObjects: TLabel;
    FEntieredTime: TLabel;
    FErrorMessages: TRichEdit;
    FErrors: TLabel;
    FLDone: TLabel;
    FLEntiered: TLabel;
    FLErrors: TLabel;
    FLProgressRecords: TLabel;
    FLProgressObjects: TLabel;
    FLProgressTime: TLabel;
    FLWhat: TLabel;
    FProgressBar: TProgressBar;
    FSource: TTreeView_Ext;
    FStructure: TCheckBox;
    GDestination: TGroupBox_Ext;
    GErrorMessages: TGroupBox_Ext;
    GProgress: TGroupBox;
    GSource: TGroupBox_Ext;
    GWhat: TGroupBox;
    PageControl: TPageControl;
    PDestination: TPanel_Ext;
    PErrorMessages: TPanel_Ext;
    PSource: TPanel_Ext;
    TSExecute: TTabSheet;
    TSSelect: TTabSheet;
    TSWhat: TTabSheet;
    procedure FBBackClick(Sender: TObject);
    procedure FBForwardClick(Sender: TObject);
    procedure FBHelpClick(Sender: TObject);
    procedure FDataClick(Sender: TObject);
    procedure FDataKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FSourceChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure FStructureClick(Sender: TObject);
    procedure FStructureKeyPress(Sender: TObject; var Key: Char);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure TreeViewExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure TreeViewGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure TSExecuteShow(Sender: TObject);
    procedure TSSelectResize(Sender: TObject);
    procedure TSSelectShow(Sender: TObject);
    procedure TSWhatShow(Sender: TObject);
    procedure TSExecuteResize(Sender: TObject);
  private
    FirstShow: Boolean;
    ProgressInfos: TTool.TProgressInfos;
    Sessions: array of record
      Created: Boolean;
      Session: TSSession;
    end;
    Space: Integer;
    Transfer: TTTransfer;
    Wanted: record
      Node: TTreeNode;
      Page: TTabSheet;
    end;
    procedure CheckActivePageChange(const ActivePage: TTabSheet);
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    function GetSession(const TreeNode: TTreeNode): TSSession;
    function OnError(const Details: TTool.TErrorDetails): TDataAction;
    procedure OnTerminate(Sender: TObject);
    procedure OnUpdate(const AProgressInfos: TTool.TProgressInfos);
    procedure UMPostAfterExecuteSQL(var Message: TMessage); message UM_POST_AFTEREXECUTESQL;
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
    procedure UMTerminate(var Message: TMessage); message UM_TERMINATE;
    procedure UMToolError(var Message: TMessage); message UM_TOOL_ERROR;
    procedure UMUpdateProgressInfo(var Message: TMessage); message UM_UPDATEPROGRESSINFO;
  public
    DestinationAddress: string;
    DestinationSession: TSSession;
    SourceAddresses: string;
    SourceSession: TSSession;
    function Execute(): Boolean;
  end;

function DTransfer(): TDTransfer;

implementation {***************************************************************}

{$R *.dfm}

uses
  CommCtrl,
  StrUtils, Consts, SysConst, Variants,
  SQLUtils,
  uPreferences, uURI,
  uDConnecting, uDExecutingSQL;

var
  FDTransfer: TDTransfer;

function DTransfer(): TDTransfer;
begin
  if (not Assigned(FDTransfer)) then
  begin
    Application.CreateForm(TDTransfer, FDTransfer);
    FDTransfer.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDTransfer;
end;

{ TDTransfer ******************************************************************}

procedure TDTransfer.CheckActivePageChange(const ActivePage: TTabSheet);
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

function TDTransfer.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDTransfer.FBBackClick(Sender: TObject);
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

procedure TDTransfer.FBForwardClick(Sender: TObject);
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

procedure TDTransfer.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDTransfer.FDataClick(Sender: TObject);
begin
  FStructure.Checked := FStructure.Checked or FData.Checked and (not Assigned(FSource.Selected) or (FSource.Selected.ImageIndex <> iiBaseTable) or not Assigned(FDestination.Selected) or (FDestination.Selected.ImageIndex <> iiBaseTable));

  TSExecute.Enabled := FStructure.Checked or FData.Checked;
  CheckActivePageChange(TSWhat);
end;

procedure TDTransfer.FDataKeyPress(Sender: TObject; var Key: Char);
begin
  FDataClick(Sender);
end;

procedure TDTransfer.FormSessionEvent(const Event: TSSession.TEvent);
begin
  if (Event.EventType = etError) then
  begin
    FSource.Cursor := crDefault;
    FDestination.Cursor := crDefault;
    SetControlCursor(GProgress, crDefault);

    Wanted.Node := nil;
    Wanted.Page := nil;
  end
  else if (Event.EventType = etAfterExecuteSQL) then
  begin
    if (Assigned(Wanted.Node) or Assigned(Wanted.Page) and Assigned(Wanted.Page.OnShow)) then
      PostMessage(Handle, UM_POST_AFTEREXECUTESQL, 0, 0);
  end;
end;

procedure TDTransfer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (Assigned(Transfer)) then
  begin
    Transfer.Terminate();
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

procedure TDTransfer.FormCreate(Sender: TObject);
begin
  Space := FLEntiered.Left + FLEntiered.Width - (FLDone.Left + FLDone.Width);

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  if ((Preferences.Transfer.Width >= Width) and (Preferences.Transfer.Height >= Height)) then
  begin
    Width := Preferences.Transfer.Width;
    Height := Preferences.Transfer.Height;
  end;

  Transfer := nil;

  FSource.Images := Preferences.Images;
  FDestination.Images := Preferences.Images;

  SendMessage(FErrorMessages.Handle, EM_SETTEXTMODE, TM_PLAINTEXT, 0);
  SendMessage(FErrorMessages.Handle, EM_SETWORDBREAKPROC, 0, LPARAM(@EditWordBreakProc));

  FStructure.Checked := Preferences.Transfer.Structure;
  FData.Checked := Preferences.Transfer.Data;

  PageControl.ActivePage := nil;
end;

procedure TDTransfer.FormHide(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to Length(Sessions) - 1 do
    if (Assigned(Sessions[I].Session)) then
    begin
      Sessions[I].Session.UnRegisterEventProc(FormSessionEvent);
      if (Sessions[I].Created) then
        Sessions[I].Session.Free();
    end;
  SetLength(Sessions, 0);

  Preferences.Transfer.Height := Height;
  Preferences.Transfer.Width := Width;

  if (ModalResult = mrOK) then
  begin
    Preferences.Transfer.Data := FData.Checked;
    Preferences.Transfer.Structure := FStructure.Checked;
  end;

  FSource.Items.BeginUpdate();
  FSource.Items.Clear();
  FSource.Items.EndUpdate();
  FDestination.Items.BeginUpdate();
  FDestination.Items.Clear();
  FDestination.Items.EndUpdate();

  PageControl.ActivePage := nil;
end;

procedure TDTransfer.FormShow(Sender: TObject);
var
  I: Integer;
begin
  Wanted.Node := nil;
  Wanted.Page := nil;

  SetLength(Sessions, Accounts.Count);
  for I := 0 to Length(Sessions) - 1 do
  begin
    Sessions[I].Created := False;
    Sessions[I].Session := nil;
  end;


  FirstShow := True;

  TSSelect.Enabled := True;
  TSWhat.Enabled := False;
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

procedure TDTransfer.FSourceChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
  AllowChange := Assigned(Node) and (Node.ImageIndex <> iiServer);
end;

procedure TDTransfer.FStructureClick(Sender: TObject);
begin
  FData.Checked := FData.Checked and (FStructure.Checked or Assigned(FSource.Selected) and (FSource.Selected.ImageIndex = iiBaseTable) and Assigned(FDestination.Selected) and (FDestination.Selected.ImageIndex = iiBaseTable));

  TSExecute.Enabled := FStructure.Checked or FData.Checked;
  CheckActivePageChange(TSWhat);
end;

procedure TDTransfer.FStructureKeyPress(Sender: TObject; var Key: Char);
begin
  FStructureClick(Sender);
end;

function TDTransfer.GetSession(const TreeNode: TTreeNode): TSSession;
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

    if (Assigned(SourceSession) and (SourceSession.Account = Accounts[Index])) then
      Sessions[Index].Session := SourceSession
    else if (Assigned(DestinationSession) and (DestinationSession.Account = Accounts[Index])) then
      Sessions[Index].Session := DestinationSession;

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

function TDTransfer.OnError(const Details: TTool.TErrorDetails): TDataAction;
begin
  Result := TDataAction(SendMessage(Handle, UM_TOOL_ERROR, 0, LPARAM(@Details)));
end;

procedure TDTransfer.OnTerminate(Sender: TObject);
begin
  PostMessage(Handle, UM_TERMINATE, WPARAM(not Transfer.Terminated), 0);
end;

procedure TDTransfer.OnUpdate(const AProgressInfos: TTool.TProgressInfos);
begin
  MoveMemory(@ProgressInfos, @AProgressInfos, SizeOf(AProgressInfos));

  PostMessage(Handle, UM_UPDATEPROGRESSINFO, 0, LPARAM(@ProgressInfos));
end;

procedure TDTransfer.TreeViewChange(Sender: TObject; Node: TTreeNode);
begin
  if (ModalResult = mrNone) then
  begin
    if ((Sender = FSource) and Assigned(Node)) then
      FSource.MultiSelect := Assigned(Node.Parent);

    TSWhat.Enabled := Assigned(FSource.Selected) and Assigned(FSource.Selected.Parent) and Assigned(FDestination.Selected)
      and ((FSource.Selected.Parent.Level = FDestination.Selected.Level)
          and ((FSource.Selected.ImageIndex <> iiDatabase) or (FSource.Selected.Parent.Text <> FDestination.Selected.Text))
          and ((FSource.Selected.ImageIndex <> iiBaseTable) or (FSource.Selected.Parent.Text <> FDestination.Selected.Text) or (FSource.Selected.Parent.Parent.Text <> FDestination.Selected.Parent.Text))
        or (FSource.SelectionCount = 1)
          and (FSource.Selected.ImageIndex = FDestination.Selected.ImageIndex) and (FSource.Selected.ImageIndex in [iiDatabase, iiBaseTable]));

    CheckActivePageChange(PageControl.ActivePage);
  end;
end;

procedure TDTransfer.TreeViewExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
var
  Session: TSSession;
  Database: TSDatabase;
  I: Integer;
  NewNode: TTreeNode;
  TreeView: TTreeView_Ext;
begin
  TreeView := TTreeView_Ext(Sender);

  if (not Assigned(TreeView.Selected)) then
    TreeView.Selected := Node;

  if (Assigned(Node)) then
  begin
    if (Assigned(Wanted.Node)) then
    begin
      GetSession(Wanted.Node).Connection.Terminate();
      Wanted.Node := nil;
    end;
    if (Node.HasChildren and not Assigned(Node.getFirstChild())) then
    begin
      case (Node.ImageIndex) of
        iiServer:
          begin
            Session := GetSession(Node);
            if (Assigned(Session)) then
              if (not Session.Databases.Update()) then
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
        iiDatabase:
          begin
            Session := TSSession(Node.Parent.Data);
            Database := Session.DatabaseByName(Node.Text);
            if (not Database.Update()) then
              Wanted.Node := Node
            else
            begin
              for I := 0 to Database.Tables.Count - 1 do
                if (Database.Tables[I] is TSBaseTable) then
                begin
                  NewNode := TreeView.Items.AddChild(Node, Database.Tables[I].Name);
                  NewNode.ImageIndex := iiBaseTable;
                  NewNode.Data := Database.Tables[I];
                end
                else if (Database.Tables[I] is TSView) then
                begin
                  NewNode := TreeView.Items.AddChild(Node, Database.Tables[I].Name);
                  NewNode.ImageIndex := iiView;
                  NewNode.Data := Database.Tables[I];
                end;
              if (Assigned(Database.Routines)) then
                for I := 0 to Database.Routines.Count - 1 do
                  if (Database.Routines[I] is TSProcedure) then
                  begin
                    NewNode := TreeView.Items.AddChild(Node, Database.Routines[I].Name);
                    NewNode.ImageIndex := iiProcedure;
                    NewNode.Data := Database.Routines[I];
                  end
                  else if (Database.Routines[I] is TSFunction) then
                  begin
                    NewNode := TreeView.Items.AddChild(Node, Database.Routines[I].Name);
                    NewNode.ImageIndex := iiFunction;
                    NewNode.Data := Database.Routines[I];
                  end;
              if (Assigned(Database.Events)) then
                for I := 0 to Database.Events.Count - 1 do
                begin
                  NewNode := TreeView.Items.AddChild(Node, Database.Events[I].Name);
                  NewNode.ImageIndex := iiEvent;
                  NewNode.Data := Database.Events[I];
                end;
            end;
          end;
      end;
    end;
  end;

  if (not Assigned(Wanted.Node)) then
    TreeView.Cursor := crDefault
  else
    TreeView.Cursor := crSQLWait;
end;

procedure TDTransfer.TreeViewGetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure TDTransfer.TSExecuteResize(Sender: TObject);
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

procedure TDTransfer.TSExecuteShow(Sender: TObject);
var
  OverrideAnswer: Integer;
  SkipAnswer: Integer;

  procedure AddDBObject(const SourceDBObject: TSDBObject; const DestinationSession: TSSession; const DestinationDatabaseName: string);
  var
    DestinationDatabase: TSDatabase;
  begin
    if ((SourceDBObject.Source = '')
      and (SkipAnswer = IDYES)) then
      if (SourceDBObject is TSBaseTable) then
        SkipAnswer := MsgBox(Preferences.LoadStr(924, SourceDBObject.Database.Name + '.' + SourceDBObject.Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
      else if (SourceDBObject is TSView) then
        SkipAnswer := MsgBox(Preferences.LoadStr(925, SourceDBObject.Database.Name + '.' + SourceDBObject.Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
      else if (SourceDBObject is TSProcedure) then
        SkipAnswer := MsgBox(Preferences.LoadStr(926, SourceDBObject.Database.Name + '.' + SourceDBObject.Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
      else if (SourceDBObject is TSFunction) then
        SkipAnswer := MsgBox(Preferences.LoadStr(927, SourceDBObject.Database.Name + '.' + SourceDBObject.Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
      else if (SourceDBObject is TSTrigger) then
        SkipAnswer := MsgBox(Preferences.LoadStr(928, SourceDBObject.Database.Name + '.' + SourceDBObject.Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
      else if (SourceDBObject is TSEvent) then
        SkipAnswer := MsgBox(Preferences.LoadStr(929, SourceDBObject.Database.Name + '.' + SourceDBObject.Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
      else
        raise ERangeError.Create(SRangeError);
    if (SkipAnswer = IDNO) then
      SkipAnswer := IDCANCEL;

    if ((SkipAnswer <> IDCANCEL) and not (OverrideAnswer in [IDCANCEL, IDYESALL])) then
    begin
      DestinationDatabase := DestinationSession.DatabaseByName(DestinationDatabaseName);
      if (Assigned(DestinationDatabase)) then
        if ((SourceDBObject is TSTable) and Assigned(DestinationDatabase.TableByName(SourceDBObject.Name))) then
          OverrideAnswer := MsgBox(Preferences.LoadStr(700, DestinationDatabase.Name + '.' + SourceDBObject.Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
        else if ((SourceDBObject is TSProcedure) and Assigned(DestinationDatabase.ProcedureByName(SourceDBObject.Name))) then
          OverrideAnswer := MsgBox(Preferences.LoadStr(777, DestinationDatabase.Name + '.' + SourceDBObject.Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
        else if ((SourceDBObject is TSFunction) and Assigned(DestinationDatabase.FunctionByName(SourceDBObject.Name))) then
          OverrideAnswer := MsgBox(Preferences.LoadStr(778, DestinationDatabase.Name + '.' + SourceDBObject.Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION)
        else if ((SourceDBObject is TSEvent) and Assigned(DestinationDatabase.EventByName(SourceDBObject.Name))) then
          OverrideAnswer := MsgBox(Preferences.LoadStr(920, DestinationDatabase.Name + '.' + SourceDBObject.Name), Preferences.LoadStr(101), MB_YESYESTOALLNOCANCEL + MB_ICONQUESTION);
    end;

    if ((SourceDBObject.Source <> '') and (OverrideAnswer in [IDYES, IDYESALL])) then
      Transfer.Add(SourceDBObject, DestinationDatabaseName);
  end;

var
  Database: TSDatabase;
  DestinationSession: TSSession;
  I: Integer;
  J: Integer;
  List: TList;
  Node: TTreeNode;
  SourceDatabase: TSDatabase;
  SourceSession: TSSession;
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

  Node := FSource.Selected;
  while (Assigned(Node.Parent)) do Node := Node.Parent;
  SourceSession := TSSession(Node.Data);
  Wanted.Page := nil;

  List := TList.Create();
  case (FSource.Selected.ImageIndex) of
    iiDatabase:
      begin
        for I := 0 to FSource.Selected.Parent.Count - 1 do
          if (FSource.Selected.Parent.Item[I].Selected) then
            List.Add(TSDatabase(FSource.Selected.Parent.Item[I].Data));
        if (not SourceSession.Update(List, FData.Checked)) then
          Wanted.Page := TSExecute
        else
        begin
          List.Clear();
          for I := 0 to FSource.Selected.Parent.Count - 1 do
            if (FSource.Selected.Parent.Item[I].Selected) then
            begin
              Database := SourceSession.DatabaseByName(FSource.Selected.Parent[I].Text);
              for J := 0 to Database.Tables.Count - 1 do
                List.Add(Database.Tables[J]);
              if (Assigned(Database.Routines)) then
                for J := 0 to Database.Routines.Count - 1 do
                  List.Add(Database.Routines[J]);
              if (Assigned(Database.Triggers)) then
                for J := 0 to Database.Triggers.Count - 1 do
                  List.Add(Database.Triggers[J]);
              if (Assigned(Database.Events)) then
                for J := 0 to Database.Events.Count - 1 do
                  List.Add(Database.Events[J]);
            end;
        end;
      end;
    iiBaseTable,
    iiView,
    iiProcedure,
    iiFunction,
    iiEvent:
      begin
        for I := 0 to FSource.Selected.Parent.Count - 1 do
          if (FSource.Selected.Parent.Item[I].Selected) then
            List.Add(FSource.Selected.Parent.Item[I].Data);
      end;
  end;
  if (not Assigned(Wanted.Page) and not SourceSession.Update(List, FData.Checked)) then
    Wanted.Page := TSExecute;
  List.Free();

  if (Assigned(Wanted.Page)) then
    DestinationSession := nil
  else
  begin
    Node := FDestination.Selected;
    while (Assigned(Node) and Assigned(Node.Parent)) do Node := Node.Parent;
    DestinationSession := GetSession(Node);

    if (Assigned(DestinationSession) and not DestinationSession.Databases.Update()) then
      Wanted.Page := TSExecute;
  end;

  if (not Assigned(Wanted.Page) and Assigned(DestinationSession)) then
    case (FDestination.Selected.ImageIndex) of
      iiDatabase:
        if (not TSDatabase(FDestination.Selected.Data).Update()) then
          Wanted.Page := TSExecute;
      iiBaseTable:
        if (not TSBaseTable(FDestination.Selected.Data).Update()) then
          Wanted.Page := TSExecute;
    end;

  if (not Assigned(Wanted.Page) and Assigned(DestinationSession)) then
  begin
    List := TList.Create();

    case (FSource.Selected.ImageIndex) of
      iiDatabase:
        if (FDestination.Selected.ImageIndex = iiServer) then
        begin
          for I := 0 to FSource.Selected.Parent.Count - 1 do
            if (FSource.Selected.Parent[I].Selected) then
            begin
              Database := DestinationSession.DatabaseByName(FSource.Selected.Parent[I].Text);
              if (Assigned(Database) and (List.IndexOf(Database) < 0)) then
                List.Add(Database);
            end;
        end
        else if (FDestination.Selected.ImageIndex in [iiDatabase]) then
          List.Add(TSDatabase(FDestination.Selected.Data))
        else
          Assert(False);
      iiBaseTable,
      iiView:
        if (FDestination.Selected.ImageIndex in [iiDatabase]) then
        begin
          if (List.IndexOf(TSDatabase(FDestination.Selected.Data).Tables) < 0) then
            List.Add(TSDatabase(FDestination.Selected.Data).Tables);
          if ((FSource.Selected.ImageIndex = iiBaseTable)
            and Assigned(TSDatabase(FDestination.Selected.Data).Triggers)
            and (List.IndexOf(TSDatabase(FDestination.Selected.Data).Triggers) < 0)) then
            List.Add(TSDatabase(FDestination.Selected.Data).Triggers);
        end
        else if (FDestination.Selected.ImageIndex in [iiBaseTable, iiView]) then
          List.Add(TSTable(FDestination.Selected.Data))
        else
          Assert(False,
            'ImageIndex: ' + IntToStr(FDestination.Selected.ImageIndex));
      iiProcedure,
      iiFunction:
        if (FDestination.Selected.ImageIndex in [iiDatabase]) then
        begin
          if (List.IndexOf(TSDatabase(FDestination.Selected.Data).Routines) < 0) then
            List.Add(TSDatabase(FDestination.Selected.Data).Routines);
        end
        else
          Assert(False);
      iiEvent:
        if (FDestination.Selected.ImageIndex in [iiDatabase]) then
        begin
          if (List.IndexOf(TSDatabase(FDestination.Selected.Data).Events) < 0) then
            List.Add(TSDatabase(FDestination.Selected.Data).Events);
        end
        else
          Assert(False);
    end;

    if (not DestinationSession.Update(List)) then
      Wanted.Page := TSExecute;

    List.Free();
  end;

  if (not Assigned(Wanted.Page) and Assigned(DestinationSession)) then
  begin
    OverrideAnswer := IDYES;
    SkipAnswer := IDYES;

    Transfer := TTTransfer.Create(SourceSession, DestinationSession);
    Transfer.Wnd := Self.Handle;
    Transfer.Data := FData.Checked;
    Transfer.Structure := FStructure.Checked;

    for I := 0 to FSource.Selected.Parent.Count - 1 do
      if (FSource.Selected.Parent[I].Selected) then
        if (FSource.Selected.Level = FDestination.Selected.Level) then
          case (FSource.Selected.Parent[I].ImageIndex) of
            iiDatabase:
              begin
                SourceDatabase := SourceSession.DatabaseByName(FSource.Selected.Text);
                for J := 0 to SourceDatabase.Tables.Count - 1 do
                  AddDBObject(SourceDatabase.Tables[J], DestinationSession, FDestination.Selected.Text);
              end;
            iiBaseTable:
              AddDBObject(SourceSession.DatabaseByName(FSource.Selected.Parent.Text).TableByName(FSource.Selected.Parent[I].Text),
                DestinationSession, FDestination.Selected.Parent.Text);
          end
        else
          case (FSource.Selected.Parent[I].ImageIndex) of
            iiDatabase:
              begin
                SourceDatabase := SourceSession.DatabaseByName(FSource.Selected.Parent[I].Text);
                for J := 0 to SourceDatabase.Tables.Count - 1 do
                  AddDBObject(SourceDatabase.Tables[J], DestinationSession, SourceDatabase.Name);
                if (Assigned(SourceDatabase.Routines)) then
                  for J := 0 to SourceDatabase.Routines.Count - 1 do
                    AddDBObject(SourceDatabase.Routines[J], DestinationSession, SourceDatabase.Name);
                if (Assigned(SourceDatabase.Events)) then
                  for J := 0 to SourceDatabase.Events.Count - 1 do
                    AddDBObject(SourceDatabase.Events[J], DestinationSession, SourceDatabase.Name);
              end;
            iiBaseTable,
            iiView:
              AddDBObject(SourceSession.DatabaseByName(FSource.Selected.Parent.Text).TableByName(FSource.Selected.Parent[I].Text),
                DestinationSession, FDestination.Selected.Text);
            iiProcedure:
              AddDBObject(SourceSession.DatabaseByName(FSource.Selected.Parent.Text).ProcedureByName(FSource.Selected.Parent[I].Text),
                DestinationSession, FDestination.Selected.Text);
            iiFunction:
              AddDBObject(SourceSession.DatabaseByName(FSource.Selected.Parent.Text).FunctionByName(FSource.Selected.Parent[I].Text),
                DestinationSession, FDestination.Selected.Text);
            iiEvent:
              AddDBObject(SourceSession.DatabaseByName(FSource.Selected.Parent.Text).EventByName(FSource.Selected.Parent[I].Text),
                DestinationSession, FDestination.Selected.Text);
          end;

    if ((SkipAnswer = IDCANCEL) or (OverrideAnswer = IDCANCEL)) then
    begin
      Transfer.Free();
      Transfer := nil;
    end
    else
    begin
      FSource.Items.BeginUpdate();
      FSource.Items.Clear();
      FSource.Items.EndUpdate();
      FDestination.Items.BeginUpdate();
      FDestination.Items.Clear();
      FDestination.Items.EndUpdate();

      TSWhat.Enabled := False;

      FBBack.Enabled := False;

      Transfer.OnError := OnError;
      Transfer.OnTerminate := OnTerminate;
      Transfer.OnUpdate := OnUpdate;
      Transfer.Start();
    end;
  end;

  if (Assigned(Wanted.Page)) then
    SetControlCursor(GProgress, crSQLWait)
  else
    SetControlCursor(GProgress, crDefault);

  CheckActivePageChange(TSExecute);
  FBBack.Enabled := not Assigned(Wanted.Page) and not Assigned(Transfer);
  ActiveControl := FBCancel;
end;

procedure TDTransfer.TSSelectResize(Sender: TObject);
begin
  GSource.Width := (TSSelect.ClientWidth - 2 * TSSelect.Left - 3 * GSource.Left) div 2;
  GDestination.Width := GSource.Width;
  GDestination.Left := TSSelect.ClientWidth - GSource.Left - GDestination.Width;
end;

procedure TDTransfer.TSSelectShow(Sender: TObject);
var
  Addresses: TStringList;
  Database: TSDatabase;
  FSourceOnChange: TTVChangedEvent;
  FDestinationOnChange: TTVChangedEvent;
  I: Integer;
  Node: TTreeNode;
  SItem: TSItem;
  URI: TUURI;
begin
  Wanted.Node := nil;
  Wanted.Page := nil;
  TSExecute.Enabled := False;

  if (FSource.Items.Count = 0) then
  begin
    FSourceOnChange := FSource.OnChange;
    FSource.OnChange := nil;
    FDestinationOnChange := FDestination.OnChange;
    FDestination.OnChange := nil;

    for I := 0 to Accounts.Count - 1 do
    begin
      Node := FSource.Items.Add(nil, Accounts[I].Name);
      Node.ImageIndex := iiServer;
      Node.HasChildren := True;
      if (Assigned(SourceSession) and (Accounts[I] = SourceSession.Account)) then
        Node.Expand(False);

      Node := FDestination.Items.Add(nil, Accounts[I].Name);
      Node.ImageIndex := iiServer;
      Node.HasChildren := True;
      if (Assigned(DestinationSession) and (Accounts[I] = DestinationSession.Account)) then
        Node.Expand(False);
    end;
    TreeViewChange(Sender, nil);

    FSource.OnChange := FSourceOnChange;
    FDestination.OnChange := FDestinationOnChange;
  end;

  if (not Assigned(Wanted.Node) and (SourceAddresses <> '')) then
  begin
    Addresses := TStringList.Create();
    Addresses.Text := SourceAddresses;

    for I := 0 to Addresses.Count - 1 do
      if (not Assigned(Wanted.Page)) then
      begin
        URI := TUURI.Create(Addresses[I]);

        Node := FSource.Items.GetFirstNode();
        while (Assigned(Node) and (Node.Data <> SourceSession)) do
          Node := Node.getNextSibling();

        if (Assigned(Node) and (URI.Database <> '')) then
        begin
          Database := SourceSession.DatabaseByName(URI.Database);
          if (Assigned(Database)) then
          begin
            Node := Node.getFirstChild();
            while (Assigned(Node) and (Node.Data <> Database)) do
              Node := Node.getNextSibling();

            if (Assigned(Node)) then
            begin
              Node.Expand(False);
              if (Assigned(Wanted.Node)) then
                Wanted.Page := TSSelect
              else
              begin
                SItem := SourceSession.ItemByAddress(URI.Address);
                if (Assigned(SItem)) then
                begin
                  Node := Node.getFirstChild();
                  while (Assigned(Node) and (Node.Data <> SItem)) do
                    Node := Node.getNextSibling();
                  if (Assigned(Node)) then
                    FSource.Select(Node, [ssCtrl]);
                end;
              end;
            end;
          end;
        end;

        URI.Free();
      end;

    Addresses.Free();

    if (not Assigned(Wanted.Page)) then
      SourceAddresses := '';
  end;

  if (not Assigned(Wanted.Node) and (DestinationAddress <> '')) then
  begin
    if (not Assigned(Wanted.Page)) then
    begin
      URI := TUURI.Create(DestinationAddress);

      Node := FDestination.Items.GetFirstNode();
      while (Assigned(Node) and (Node.Data <> DestinationSession)) do
        Node := Node.getNextSibling();

      if (Assigned(Node) and (URI.Database <> '')) then
      begin
        Database := DestinationSession.DatabaseByName(URI.Database);
        if (Assigned(Database)) then
        begin
          Node := Node.getFirstChild();
          while (Assigned(Node) and (Node.Data <> Database)) do
            Node := Node.getNextSibling();

          if (Assigned(Node)) then
            if ((URI.Table = '') and (URI.Param['object'] = Null)) then
            begin
              SItem := DestinationSession.ItemByAddress(URI.Address);
              while (Assigned(Node) and (Node.Data <> SItem)) do
                Node := Node.getNextSibling();
              if (Assigned(Node)) then
                FDestination.Select(Node, [ssCtrl]);
            end
            else
            begin
              Node.Expand(False);
              if (Assigned(Wanted.Node)) then
                Wanted.Page := TSSelect
              else
              begin
                SItem := DestinationSession.ItemByAddress(URI.Address);
                if (Assigned(SItem)) then
                begin
                  Node := Node.getFirstChild();
                  while (Assigned(Node) and (Node.Data <> SItem)) do
                    Node := Node.getNextSibling();
                  if (Assigned(Node)) then
                    FDestination.Select(Node, [ssCtrl]);
                end;
              end;
            end;
        end;
      end;

      URI.Free();
    end;

    if (not Assigned(Wanted.Page)) then
      DestinationAddress := '';
  end;

  if (not Assigned(Wanted.Page)) then
  begin
    if ((FSource.SelectionCount > 0) and (FDestination.SelectionCount > 0) and FirstShow) then
    begin
      TSWhat.Enabled := True;
      PageControl.ActivePage := TSWhat;

      if (not FBForward.Enabled and FStructure.Enabled) then
        ActiveControl := FStructure
      else if (not FBForward.Enabled and FData.Enabled) then
        ActiveControl := FData
      else
        ActiveControl := FBForward;
    end
    else
      CheckActivePageChange(TSSelect);
    FirstShow := False;
  end;
end;

procedure TDTransfer.TSWhatShow(Sender: TObject);
var
  I: Integer;
  J: Integer;
  List: TList;
  Node: TTreeNode;
begin
  Wanted.Node := nil;
  Wanted.Page := nil;

  List := TList.Create();
  for I := 0 to FSource.SelectionCount - 1 do
    if ((TObject(FSource.Selections[I].Data) is TSDatabase)
      or (TObject(FSource.Selections[I].Data) is TSBaseTable)) then
      List.Add(FSource.Selections[I].Data);
  Node := FSource.Selected;
  while (Assigned(Node.Parent)) do Node := Node.Parent;
  if (not TSSession(Node.Data).Update(List)) then
    Wanted.Page := TSWhat;
  List.Free();

  if (Assigned(Wanted.Page)) then
  begin
    FData.Enabled := True;
    FData.Checked := Preferences.Transfer.Data;
  end
  else
  begin
    FData.Enabled := False;
    for I := 0 to FSource.SelectionCount - 1 do
      if (TObject(FSource.Selections[I].Data) is TSDatabase) then
      begin
        for J := 0 to TSDatabase(FSource.Selections[I].Data).Tables.Count - 1 do
          if (TSDatabase(FSource.Selections[I].Data).Tables[J] is TSBaseTable) then
            FData.Enabled := True;
      end
      else if (FSource.Selections[I].ImageIndex = iiBaseTable) then
        FData.Enabled := True;
  end;

  FStructure.Checked := FStructure.Checked and ((FDestination.Selected.ImageIndex = iiDatabase) or (FSource.Selected.ImageIndex <> FDestination.Selected.ImageIndex));
  FData.Checked := FData.Checked and FData.Enabled;

  TSExecute.Enabled := not Assigned(Wanted.Page) and FStructure.Checked;

  CheckActivePageChange(TSWhat);
end;

procedure TDTransfer.UMPostAfterExecuteSQL(var Message: TMessage);
var
  Node: TTreeNode;
begin
  if (Assigned(Wanted.Node)) then
  begin
    Node := Wanted.Node;
    Wanted.Node := nil;
    Node.Expand(False);
  end;
  if (not Assigned(Wanted.Node) and Assigned(Wanted.Page) and Assigned(Wanted.Page.OnShow)) then
    Wanted.Page.OnShow(Wanted.Page);
end;

procedure TDTransfer.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiTransfer, Icon);

  Caption := Preferences.LoadStr(753);;

  GSource.Caption := Preferences.LoadStr(754);
  GDestination.Caption := Preferences.LoadStr(755);

  GWhat.Caption := Preferences.LoadStr(227);
  FLWhat.Caption := Preferences.LoadStr(218) + ':';
  FStructure.Caption := Preferences.LoadStr(215);
  FData.Caption := Preferences.LoadStr(216);

  GProgress.Caption := Preferences.LoadStr(224);
  FLEntiered.Caption := Preferences.LoadStr(211) + ':';
  FLDone.Caption := Preferences.LoadStr(232) + ':';
  FLProgressObjects.Caption := Preferences.LoadStr(909) + ':';
  FLProgressRecords.Caption := Preferences.LoadStr(235) + ':';
  FLProgressTime.Caption := Preferences.LoadStr(661) + ':';
  FLErrors.Caption := Preferences.LoadStr(391) + ':';

  GErrorMessages.Caption := Preferences.LoadStr(392);

  FBHelp.Caption := Preferences.LoadStr(167);
  FBBack.Caption := '< ' + Preferences.LoadStr(228);
end;

procedure TDTransfer.UMTerminate(var Message: TMessage);
var
  Success: Boolean;
begin
  Success := Boolean(Message.WParam);

  Transfer.WaitFor();

  if (Success and (Transfer.WarningCount > 0)) then
    MsgBoxCheck(Preferences.LoadStr(932, IntToStr(Transfer.WarningCount)), Preferences.LoadStr(43), MB_OK + MB_ICONINFORMATION,
      ID_OK, '{3b9746df-b0d6-47e4-9fb2-b2e9dfd93596}');

  Transfer.Free();
  Transfer := nil;

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

procedure TDTransfer.UMToolError(var Message: TMessage);
var
  Details: ^TTool.TErrorDetails;
  ErrorMsg: string;
  Flags: Integer;
  Text: string;
begin
  Details := Pointer(Message.LParam);

  ErrorMsg := '';
  case (Details^.Error.ErrorType) of
    TE_Database:
      begin
        Text := Preferences.LoadStr(165, IntToStr(Details^.Error.Session.Connection.ErrorCode), Details^.Error.Session.Connection.ErrorMessage);
        ErrorMsg := Details^.Error.ErrorMessage
          + ' (#' + IntToStr(Details^.Error.ErrorCode) + ') - ' + Trim(Details^.Error.Session.Connection.ErrorCommandText);
      end;
    TE_File:
      begin
        Text := Details^.Error.ErrorMessage + ' (#' + IntToStr(Details^.Error.ErrorCode) + ')';
        ErrorMsg := Text;
      end;
    TE_NoPrimaryIndex:
      if ((Details^.Tool is TTTransfer) and (Details^.Error.Session = TTTransfer(Details^.Tool).Session)) then
        Text := Preferences.LoadStr(722, TTTransfer.TItem(Details^.Item).DBObject.Name)
      else if ((Details^.Tool is TTTransfer) and (Details^.Error.Session = TTTransfer(Details^.Tool).DestinationSession)) then
        Text := Preferences.LoadStr(722, TTTransfer.TItem(Details^.Item).DBObject.Name)
      else
        raise ERangeError.CreateFmt(SPropertyOutOfRange, ['Sender | Details^.Error.Session']);
    else
      Text := Details^.Error.ErrorMessage;
  end;

  if (not Details^.ShowRetry) then
    Flags := MB_OK + MB_ICONERROR
  else
    Flags := MB_CANCELTRYCONTINUE + MB_ICONERROR;
  case (MsgBox(Text, Preferences.LoadStr(45), Flags)) of
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

procedure TDTransfer.UMUpdateProgressInfo(var Message: TMessage);
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
  FDTransfer := nil;
end.

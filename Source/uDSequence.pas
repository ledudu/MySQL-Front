unit uDSequence;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls, Menus, ExtCtrls,
  SynEdit, SynMemo,
  Forms_Ext, StdCtrls_Ext,
  uSession,
  uBase;

type
  TDSequence = class(TForm_Ext)
    PageControl: TPageControl;
    FBHelp: TButton;
    FBOk: TButton;
    FBCancel: TButton;
    TSBasics: TTabSheet;
    TSSource: TTabSheet;
    TSDependencies: TTabSheet;
    MSource: TPopupMenu;
    msCopy: TMenuItem;
    N1: TMenuItem;
    msSelectAll: TMenuItem;
    FSource: TSynMemo;
    GBasics: TGroupBox_Ext;
    FLName: TLabel;
    FName: TEdit;
    PSQLWait: TPanel;
    FDependencies: TListView;
    FLMinValue: TLabel;
    FPMinValue: TPanel;
    FRNoMinValue: TRadioButton;
    FRMinValue: TRadioButton;
    FMinValue: TEdit;
    FLMaxValue: TLabel;
    FPMaxValue: TPanel;
    FRNoMaxValue: TRadioButton;
    FRMaxValue: TRadioButton;
    FMaxValue: TEdit;
    FCache: TEdit;
    FLCache: TLabel;
    FPCache: TPanel;
    FRNoCache: TRadioButton;
    FRCache: TRadioButton;
    FIncrement: TEdit;
    FLIncrement: TLabel;
    FLStart: TLabel;
    FStart: TEdit;
    FCycle: TCheckBox;
    FLCycle: TLabel;
    procedure FBOkCheckEnabled(Sender: TObject);
    procedure FBHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure TSDependenciesShow(Sender: TObject);
    procedure FRMinValueClick(Sender: TObject);
    procedure FRMinValueKeyPress(Sender: TObject; var Key: Char);
    procedure FRMaxValueClick(Sender: TObject);
    procedure FRMaxValueKeyPress(Sender: TObject; var Key: Char);
    procedure FRCacheKeyPress(Sender: TObject; var Key: Char);
    procedure FRCacheClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FCycleKeyPress(Sender: TObject; var Key: Char);
  private
    SessionState: (ssCreate, ssInit, ssDependencies, ssValid, ssAlter);
    procedure Built();
    procedure BuiltDependencies();
    procedure FormSessionEvent(const Event: TSSession.TEvent);
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Database: TSDatabase;
    Sequence: TSSequence;
    function Execute(): Boolean;
  end;

function DSequence(): TDSequence;

implementation {***************************************************************}

{$R *.dfm}

uses
  SysConst,
  uPreferences;

var
  FDSequence: TDSequence;

function DSequence(): TDSequence;
begin
  if (not Assigned(FDSequence)) then
  begin
    Application.CreateForm(TDSequence, FDSequence);
    FDSequence.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDSequence;
end;

{ TDSequence ******************************************************************}

procedure TDSequence.Built();
var
  Code: Integer;
  I64: Int64;
begin
  FName.Text := Sequence.Name;

  FIncrement.Text := Sequence.Increment;

  Val(Sequence.MinValue, I64, Code); if (I64 = 0) then Write;
  FRNoMinValue.Checked := Code <> 0;
  FRMinValue.Checked := not FRNoMinValue.Checked;
  if (FRNoMinValue.Checked) then
    FMinValue.Text := ''
  else
    FMinValue.Text := Sequence.MinValue;

  Val(Sequence.MaxValue, I64, Code); if (I64 = 0) then Write;
  FRNoMaxValue.Checked := Code <> 0;
  FRMaxValue.Checked := not FRNoMaxValue.Checked;
  if (FRNoMaxValue.Checked) then
    FMaxValue.Text := ''
  else
    FMaxValue.Text := Sequence.MaxValue;

  FStart.Text := Sequence.Start;

  Val(Sequence.Cache, I64, Code); if (I64 = 0) then Write;
  FRNoCache.Checked := Code <> 0;
  FRCache.Checked := not FRNoCache.Checked;
  if (FRNoCache.Checked) then
    FCache.Text := ''
  else
    FCache.Text := Sequence.Cache;

  FCycle.Checked := Sequence.Cycle;

  FSource.Text := Sequence.Source;

  TSSource.TabVisible := Assigned(Sequence) and (Sequence.Source <> '');
end;

procedure TDSequence.BuiltDependencies();

  procedure AddDBObject(const DBObject: TSDBObject);
  var
    I: Integer;
    Item: TListItem;
  begin
    for I := 0 to DBObject.References.Count - 1 do
      if (DBObject.References[I].DBObject = Sequence) then
      begin
        Item := FDependencies.Items.Add();

        if (DBObject is TSSequence) then
        begin
          Item.ImageIndex := iiSequence;
          Item.Caption := DBObject.Caption;
          Item.SubItems.Add(Preferences.LoadStr(738));
        end
        else if (DBObject is TSTable) then
        begin
          Item.ImageIndex := iiTable;
          Item.Caption := DBObject.Caption;
          Item.SubItems.Add(Preferences.LoadStr(302));
        end
        else if (DBObject is TSProcedure) then
        begin
          Item.ImageIndex := iiProcedure;
          Item.Caption := DBObject.Caption;
          Item.SubItems.Add(Preferences.LoadStr(768));
        end
        else if (DBObject is TSFunction) then
        begin
          Item.ImageIndex := iiFunction;
          Item.Caption := DBObject.Caption;
          Item.SubItems.Add(Preferences.LoadStr(769));
        end
        else if (DBObject is TSTrigger) then
        begin
          Item.ImageIndex := iiTrigger;
          Item.Caption := DBObject.Caption;
          Item.SubItems.Add(Preferences.LoadStr(923, TSTrigger(DBObject).TableName));
        end
        else if (DBObject is TSEvent) then
        begin
          Item.ImageIndex := iiEvent;
          Item.Caption := DBObject.Caption;
          Item.SubItems.Add(Preferences.LoadStr(812));
        end
        else
          raise ERangeError.Create(SRangeError);
        Item.Data := DBObject;
      end;
  end;

var
  I: Integer;
begin
  FDependencies.Items.BeginUpdate();
  FDependencies.Items.Clear();

  for I := 0 to Database.Tables.Count - 1 do
    if (Database.Tables[I] <> Sequence) then
      AddDBObject(Database.Tables[I]);

  FDependencies.Items.EndUpdate();
end;

function TDSequence.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDSequence.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDSequence.FBOkCheckEnabled(Sender: TObject);
var
  I: Integer;
begin
  FBOk.Enabled := PageControl.Visible
    and (FName.Text <> '');
  for I := 0 to Database.Tables.Count - 1 do
    if (Database.Session.TableNameCmp(FName.Text, Database.Tables[I].Name) = 0) and not (not Assigned(Sequence) or (Database.Session.TableNameCmp(FName.Text, Sequence.Name) = 0)) then
      FBOk.Enabled := False;
end;

procedure TDSequence.FCycleKeyPress(Sender: TObject; var Key: Char);
begin
  FBOkCheckEnabled(Sender);
end;

procedure TDSequence.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  NewSequence: TSSequence;
begin
  if ((ModalResult = mrOk) and PageControl.Visible) then
  begin
    NewSequence := TSSequence.Create(Database.Tables);
    if (Assigned(Sequence)) then
      NewSequence.Assign(Sequence);

    NewSequence.Name := Trim(FName.Text);
    NewSequence.Increment := FIncrement.Text;
    if (FRNoMinValue.Checked) then
      NewSequence.MinValue := 'NOMINVALUE'
    else
      NewSequence.MinValue := FMinValue.Text;
    if (FRNoMaxValue.Checked) then
      NewSequence.MaxValue := 'NOMAXVALUE'
    else
      NewSequence.MaxValue := FMaxValue.Text;
    NewSequence.Start := FStart.Text;
    if (FRNoCache.Checked) then
      NewSequence.Cache := 'NOCACHE'
    else
      NewSequence.Cache := FCache.Text;
    NewSequence.Cycle := FCycle.Checked;


    SessionState := ssAlter;

    if (not Assigned(Sequence)) then
      CanClose := Database.AddSequence(NewSequence)
    else
      CanClose := Database.UpdateSequence(Sequence, NewSequence);

    NewSequence.Free();

    PageControl.Visible := False;
    PSQLWait.Visible := not PageControl.Visible;
    FBOk.Enabled := False;
  end;
end;

procedure TDSequence.FormCreate(Sender: TObject);
begin
  FDependencies.SmallImages := Preferences.Images;
  FSource.Highlighter := Preferences.Editor.Highlighter;

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  msCopy.Action := aECopy; msCopy.ShortCut := 0;
  msSelectAll.Action := aESelectAll; msSelectAll.ShortCut := 0;

  FName.OnChange := FBOkCheckEnabled;

  PageControl.ActivePage := TSBasics;
end;

procedure TDSequence.FormHide(Sender: TObject);
begin
  Database.Session.UnRegisterEventProc(FormSessionEvent);

  Preferences.Sequence.Width := Width;
  Preferences.Sequence.Height := Height;

  FSource.Lines.Clear();

  PageControl.ActivePage := TSBasics;
end;

procedure TDSequence.FormSessionEvent(const Event: TSSession.TEvent);
var
  FirstValid: Boolean;
begin
  FirstValid := SessionState = ssInit;

  if ((SessionState = ssInit) and (Event.EventType = etError)) then
    ModalResult := mrCancel
  else if ((SessionState = ssInit) and (Event.EventType = etItemValid) and (Event.Item = Sequence)) then
  begin
    Built();
    SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType = etError)) then
  begin
    if (not Assigned(Sequence)) then
      SessionState := ssCreate
    else
      SessionState := ssValid;
  end
  else if ((SessionState = ssAlter) and (Event.EventType in [etItemValid, etItemCreated, etItemRenamed])) then
    ModalResult := mrOk
  else if ((SessionState = ssDependencies) and (Event.EventType = etAfterExecuteSQL)) then
  begin
    BuiltDependencies();
    SessionState := ssValid;
  end;


  if (SessionState in [ssCreate, ssValid]) then
  begin
    FDependencies.Cursor := crDefault;

    if (not PageControl.Visible) then
    begin
      PageControl.Visible := True;
      PSQLWait.Visible := not PageControl.Visible;
      FBOkCheckEnabled(nil);

      if (FirstValid) then
        if (FName.Enabled) then
          ActiveControl := FName
        else
          ActiveControl := FIncrement;
    end;
  end;
end;

procedure TDSequence.FormShow(Sender: TObject);
var
  SequenceName: string;
begin
  Database.Session.RegisterEventProc(FormSessionEvent);

  if ((Preferences.Sequence.Width >= Width) and (Preferences.Sequence.Height >= Height)) then
  begin
    Width := Preferences.Sequence.Width;
    Height := Preferences.Sequence.Height;
  end;

  if (not Assigned(Sequence)) then
  begin
    Caption := Preferences.LoadStr(952);
    HelpContext := 1160;
  end
  else
  begin
    Caption := Preferences.LoadStr(842, Sequence.Name);
    HelpContext := 1158;
  end;

  FSource.Lines.Clear();

  if (not Assigned(Sequence) and (Database.Session.LowerCaseTableNames = 1)) then
    FName.CharCase := ecLowerCase
  else
    FName.CharCase := ecNormal;

  if (not Assigned(Sequence)) then
    SessionState := ssCreate
  else if (not Sequence.Valid and not Sequence.Update()) then
    SessionState := ssInit
  else
    SessionState := ssValid;

  if (not Assigned(Sequence)) then
  begin
    FName.Text := Preferences.LoadStr(953);
    Database.Session.Connection.BeginSynchron(26);
    Database.Tables.Update(False);
    Database.Session.Connection.EndSynchron(26);
    while (Assigned(Database.TableByName(FName.Text))) do
    begin
      SequenceName := FName.Text;
      Delete(SequenceName, 1, Length(Preferences.LoadStr(953)));
      if (SequenceName = '') then SequenceName := '1';
      SequenceName := Preferences.LoadStr(953) + IntToStr(StrToInt(SequenceName) + 1);
      FName.Text := SequenceName;
    end;

    FIncrement.Text := '1';
    FRMinValue.Checked := True;
    FMinValue.Text := '1';
    FRMaxValue.Checked := True;
    FMaxValue.Text := '9223372036854775806';
    FStart.Text := '1';
    FRCache.Checked := True;
    FCache.Text := '1';
    FCycle.Checked := False;
  end
  else
  begin
    if (SessionState = ssValid) then
      Built();
  end;

  FDependencies.Cursor := crDefault;

  FName.Enabled := not Assigned(Sequence);

  TSDependencies.TabVisible := Assigned(Sequence);

  PageControl.Visible := SessionState in [ssCreate, ssValid];
  PSQLWait.Visible := not PageControl.Visible;

  FBOk.Enabled := PageControl.Visible and not Assigned(Sequence);

  ActiveControl := FBCancel;
  if (PageControl.Visible) then
    if (FName.Enabled) then
      ActiveControl := FName
    else
      ActiveControl := FIncrement;
end;

procedure TDSequence.FRCacheClick(Sender: TObject);
begin
  FCache.Enabled := FRCache.Checked;
  FBOkCheckEnabled(Sender);
end;

procedure TDSequence.FRCacheKeyPress(Sender: TObject; var Key: Char);
begin
  FRCacheClick(Sender);
end;

procedure TDSequence.FRMaxValueClick(Sender: TObject);
begin
  FMaxValue.Enabled := FRMaxValue.Checked;
  FBOkCheckEnabled(Sender);
end;

procedure TDSequence.FRMaxValueKeyPress(Sender: TObject; var Key: Char);
begin
  FRMaxValueClick(Sender);
end;

procedure TDSequence.FRMinValueClick(Sender: TObject);
begin
  FMinValue.Enabled := FRMinValue.Checked;
  FBOkCheckEnabled(Sender);
end;

procedure TDSequence.FRMinValueKeyPress(Sender: TObject; var Key: Char);
begin
  FRMinValueClick(Sender);
end;

procedure TDSequence.TSDependenciesShow(Sender: TObject);
var
  List: TList;
begin
  if (FDependencies.Items.Count = 0) then
  begin
    List := TList.Create();
    List.Add(Sequence.DependenciesSearch);
    if (not Database.Session.Update(List)) then
    begin
      SessionState := ssDependencies;

      FDependencies.Cursor := crSQLWait;
    end
    else
      BuiltDependencies();
    List.Free();
  end;
end;

procedure TDSequence.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(iiSequence, Icon);

  PSQLWait.Caption := Preferences.LoadStr(882) + '...';

  TSBasics.Caption := Preferences.LoadStr(108);
  GBasics.Caption := Preferences.LoadStr(85);
  FLName.Caption := Preferences.LoadStr(35) + ':';
  FLIncrement.Caption := Preferences.LoadStr(954) + ':';
  FLMinValue.Caption := Preferences.LoadStr(955) + ':';
  FRNoMinValue.Caption := Preferences.LoadStr(957);
  FLMaxValue.Caption := Preferences.LoadStr(956) + ':';
  FRNoMaxValue.Caption := Preferences.LoadStr(957);
  FLStart.Caption := Preferences.LoadStr(817) + ':';
  FLCache.Caption := Preferences.LoadStr(958) + ':';
  FRNoCache.Caption := Preferences.LoadStr(959);
  FLCycle.Caption := Preferences.LoadStr(960) + ':';
  FCycle.Caption := Preferences.LoadStr(955) + ':';

  TSDependencies.Caption := Preferences.LoadStr(782);
  FDependencies.Column[0].Caption := Preferences.LoadStr(35);
  FDependencies.Column[1].Caption := Preferences.LoadStr(69);

  TSSource.Caption := Preferences.LoadStr(198);
  Preferences.ApplyToSynMemo(FSource);

  FBHelp.Caption := Preferences.LoadStr(167);
  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDSequence := nil;
end.

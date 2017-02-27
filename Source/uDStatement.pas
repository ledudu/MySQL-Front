unit uDStatement;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, Menus, ComCtrls, StdCtrls,
  BCEditor.Editor, BCEditor.Editor.Base,
  Forms_Ext, StdCtrls_Ext,
  uBase, uSession;

type
  TDStatementViewType = (vtQuery, vtStatement, vtProcess);

  TDStatement = class(TForm_Ext)
    FBClose: TButton;
    FDatabase: TLabel;
    FExecutionTime: TLabel;
    FHost: TLabel;
    FId: TLabel;
    FInfo: TLabel;
    FInsertId: TLabel;
    FLDatabase: TLabel;
    FLExecutionTime: TLabel;
    FLHost: TLabel;
    FLId: TLabel;
    FLInfo: TLabel;
    FLInsertId: TLabel;
    FLQueryTime: TLabel;
    FLRowsAffected: TLabel;
    FLStatementTime: TLabel;
    FLUser: TLabel;
    FQueryTime: TLabel;
    FRowsAffected: TLabel;
    FSource: TBCEditor;
    FStatementTime: TLabel;
    FUser: TLabel;
    GBasics: TGroupBox_Ext;
    GProcess: TGroupBox_Ext;
    GQuery: TGroupBox_Ext;
    GStatement: TGroupBox_Ext;
    msCopy: TMenuItem;
    MSource: TPopupMenu;
    msSelectAll: TMenuItem;
    N1: TMenuItem;
    PageControl: TPageControl;
    TSInformation: TTabSheet;
    TSSource: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
  public
    DatabaseName: string;
    DateTime: TDateTime;
    Host: string;
    Id: Int64;
    Info: string;
    RowsAffected: Integer;
    Session: TSSession;
    SQL: string;
    StatementTime: TDateTime;
    UserName: string;
    ViewType: TDStatementViewType;
    function Execute(): Boolean;
  end;

function DStatement(): TDStatement;

implementation {***************************************************************}

{$R *.dfm}

uses
  StrUtils,
  MySQLDB,
  uPreferences;

var
  FDStatement: TDStatement;

function DStatement(): TDStatement;
begin
  if (not Assigned(FDStatement)) then
  begin
    Application.CreateForm(TDStatement, FDStatement);
    FDStatement.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDStatement;
end;

{ TDStatement *****************************************************************}

function TDStatement.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDStatement.FormCreate(Sender: TObject);
begin
  FSource.Highlighter.LoadFromResource('Highlighter', RT_RCDATA);
  FSource.Highlighter.Colors.LoadFromResource('Colors', RT_RCDATA);

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  msCopy.Action := MainAction('aECopy'); msCopy.ShortCut := 0;
  msSelectAll.Action := MainAction('aESelectAll');
end;

procedure TDStatement.FormHide(Sender: TObject);
begin
  Preferences.Statement.Width := Width;
  Preferences.Statement.Height := Height;
end;

procedure TDStatement.FormShow(Sender: TObject);
begin
  if ((Preferences.Statement.Width >= Width) and (Preferences.Statement.Height >= Height)) then
  begin
    Width := Preferences.Statement.Width;
    Height := Preferences.Statement.Height;
  end;

  case (ViewType) of
    vtQuery:
      begin
        Preferences.Images.GetIcon(iiStatement, Icon);
        Caption := Preferences.LoadStr(794);
      end;
    vtStatement:
      begin
        Preferences.Images.GetIcon(iiQuery, Icon);
        Caption := Preferences.LoadStr(794);
      end;
    vtProcess:
      begin
        Preferences.Images.GetIcon(iiProcess, Icon);
        Caption := Preferences.LoadStr(562);
      end;
  end;

  FSource.Lines.Clear();
  Session.ApplyToBCEditor(FSource);

  if (DateTime = MySQLZeroDate) then
    FExecutionTime.Caption := '???'
  else
    FExecutionTime.Caption := SysUtils.DateTimeToStr(DateTime, LocaleFormatSettings);
  FDatabase.Caption := DatabaseName;

  GStatement.Visible := ViewType = vtStatement;
  if (StatementTime = MySQLZeroDate) then
    FStatementTime.Caption := '???'
  else
    FStatementTime.Caption := ExecutionTimeToStr(StatementTime);
  FRowsAffected.Visible := RowsAffected >= 0; FLRowsAffected.Visible := FRowsAffected.Visible;
  if (FRowsAffected.Visible) then
    FRowsAffected.Caption := IntToStr(RowsAffected);
  FInfo.Visible := Info <> ''; FLInfo.Visible := FInfo.Visible;
  if (FInfo.Visible) then
    FInfo.Caption := Info;
  FInsertId.Visible := Id > 0; FLInsertId.Visible := FInsertId.Visible;
  if (FInsertId.Visible) then
    FInsertId.Caption := IntToStr(Id);

  GQuery.Visible := ViewType = vtQuery;
  FQueryTime.Caption := FStatementTime.Caption;

  GProcess.Visible := ViewType = vtProcess;
  FId.Caption := IntToStr(Id);
  FUser.Caption := UserName;
  FHost.Caption := Host;

  TSSource.TabVisible := SQL <> '';
  if (TSSource.TabVisible) then
  begin
    FSource.Lines.Text := SQL + #13#10;
    FSource.ReadOnly := True;
  end;

  PageControl.ActivePage := TSInformation;
  ActiveControl := FBClose;
end;

procedure TDStatement.UMChangePreferences(var Message: TMessage);
begin
  TSInformation.Caption := Preferences.LoadStr(121);
  GBasics.Caption := Preferences.LoadStr(85);
  FLExecutionTime.Caption := Preferences.LoadStr(520) + ':';
  FLDatabase.Caption := Preferences.LoadStr(38) + ':';

  GStatement.Caption := Preferences.LoadStr(662);
  FLStatementTime.Caption := Preferences.LoadStr(661) + ':';
  FLRowsAffected.Caption := Preferences.LoadStr(808) + ':';
  FLInfo.Caption := Preferences.LoadStr(274) + ':';
  FLInsertId.Caption := Preferences.LoadStr(84) + ':';

  GQuery.Caption := Preferences.LoadStr(662);
  FLQueryTime.Caption := Preferences.LoadStr(661) + ':';

  GProcess.Caption := Preferences.LoadStr(684);
  FLId.Caption := Preferences.LoadStr(269) + ':';
  FLUser.Caption := Preferences.LoadStr(561) + ':';
  FLHost.Caption := Preferences.LoadStr(271) + ':';

  TSSource.Caption := Preferences.LoadStr(198);
  Preferences.ApplyToBCEditor(FSource);

  FBClose.Caption := Preferences.LoadStr(231);
end;

initialization
  FDStatement := nil;
end.


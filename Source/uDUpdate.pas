unit uDUpdate;

interface {********************************************************************}

uses
  Windows, Messages, Classes, Controls, SysUtils,
  Dialogs, StdCtrls, ComCtrls, Forms,
  Forms_Ext, StdCtrls_Ext,
  uDeveloper,
  uBase;

const
  UM_PAD_FILE_RECEIVED = WM_USER + 200;
  UM_SETUP_FILE_RECEIVED = WM_USER + 202;
  UM_UPDATE_PROGRESSBAR = WM_USER + 203;

type
  TDUpdate = class(TForm_Ext)
    FBCancel: TButton;
    FBForward: TButton;
    FProgram: TLabel;
    FProgressBar: TProgressBar;
    FVersionInfo: TLabel;
    GroupBox: TGroupBox_Ext;
    procedure FBForwardClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    SetupProgramStream: TFileStream;
    SetupProgramURI: string;
    FullHeight: Integer;
    HTTPThread: THTTPThread;
    PADFileStream: TStringStream;
    SetupPrgFilename: TFileName;
    procedure OnProgress(Sender: TObject; const Done, Size: Int64);
    procedure OnTerminate(Sender: TObject);
    procedure UMChangePreferences(var Msg: TMessage); message UM_CHANGEPREFERENCES;
    procedure UMPADFileReceived(var Msg: TMessage); message UM_PAD_FILE_RECEIVED;
    procedure UMSetupFileReceived(var Msg: TMessage); message UM_SETUP_FILE_RECEIVED;
    procedure UMTerminate(var Msg: TMessage); message UM_TERMINATE;
    procedure UMUpdateProgressBar(var Msg: TMessage); message UM_UPDATE_PROGRESSBAR;
  public
    function Execute(): Boolean;
  end;

function DUpdate(): TDUpdate;

implementation {***************************************************************}

{$R *.dfm}

uses
  StrUtils, WinInet, SysConst,
  uPreferences;

var
  FDUpdate: TDUpdate;

function DUpdate(): TDUpdate;
begin
  if (not Assigned(FDUpdate)) then
  begin
    Application.CreateForm(TDUpdate, FDUpdate);
    FDUpdate.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDUpdate;
end;

{ TDUpdate *************************************************************}

function TDUpdate.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDUpdate.FBForwardClick(Sender: TObject);
var
  Ext: string;
  FilenameP: array [0 .. MAX_PATH] of Char;
  I: Integer;
begin
  if (GetTempPath(MAX_PATH, FilenameP) > 0) then
  begin
    SetupPrgFilename := SetupProgramURI;
    while (Pos('/', SetupPrgFilename) > 0) do Delete(SetupPrgFilename, 1, Pos('/', SetupPrgFilename));

    if (not FileExists(FilenameP + SetupPrgFilename)) then
      SetupPrgFilename := FilenameP + SetupPrgFilename
    else
    begin
      Ext := ExtractFileExt(SetupPrgFilename);
      Delete(SetupPrgFilename, Length(SetupPrgFilename) - Length(Ext) + 1, Length(Ext));
      I := 2;
      while (FileExists(FilenameP + SetupPrgFilename + ' (' + IntToStr(I) + ')' + Ext)) do Inc(I);
      SetupPrgFilename := FilenameP + SetupPrgFilename + ' (' + IntToStr(I) + ')' + Ext;
    end;

    FProgram.Caption := Preferences.LoadStr(665) + ' ...';
    FProgram.Enabled := True;
    FBForward.Enabled := False;
    ActiveControl := FBCancel;

    SetupProgramStream := TFileStream.Create(SetupPrgFilename, fmCreate);

    HTTPThread := THTTPThread.Create(SetupProgramURI, nil, SetupProgramStream);
    HTTPThread.OnProgress := OnProgress;
    HTTPThread.OnTerminate := OnTerminate;

    SendMessage(Handle, UM_UPDATE_PROGRESSBAR, 2, 100);

    HTTPThread.Start();
  end;
end;

procedure TDUpdate.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (Assigned(HTTPThread)) then
  begin
    HTTPThread.Terminate();
    CanClose := False;
  end
  else
    CanClose := True;

  FBCancel.Enabled := CanClose;
end;

procedure TDUpdate.FormCreate(Sender: TObject);
begin
  FullHeight := Height;
  HTTPThread := nil;
end;

procedure TDUpdate.FormHide(Sender: TObject);
begin
  if (Assigned(PADFileStream)) then
    FreeAndNil(PADFileStream);
  if (Assigned(SetupProgramStream)) then
    FreeAndNil(SetupProgramStream);
end;

procedure TDUpdate.FormShow(Sender: TObject);
begin
  FVersionInfo.Caption := Preferences.LoadStr(663);
  FVersionInfo.Enabled := False;

  FProgram.Caption := Preferences.LoadStr(665);
  FProgram.Enabled := False;

  PADFileStream := TStringStream.Create();
  SetupProgramStream := nil;

  FVersionInfo.Caption := Preferences.LoadStr(663) + ' ...';
  FVersionInfo.Enabled := True;

  if (Assigned(HTTPThread)) then
    TerminateThread(HTTPThread.Handle, 0);
  HTTPThread := THTTPThread.Create(SysUtils.LoadStr(1005), nil, PADFileStream);
  HTTPThread.OnProgress := OnProgress;
  HTTPThread.OnTerminate := OnTerminate;

  SendMessage(Handle, UM_UPDATE_PROGRESSBAR, 10, 100);

  HTTPThread.Start();

  FBForward.Enabled := False;
  FBCancel.Enabled := True;
  FBCancel.Caption := Preferences.LoadStr(30);
end;

procedure TDUpdate.OnProgress(Sender: TObject; const Done, Size: Int64);
begin
  PostMessage(Handle, UM_UPDATE_PROGRESSBAR, Done, Size);
end;

procedure TDUpdate.OnTerminate(Sender: TObject);
begin
  PostMessage(Handle, UM_TERMINATE, 0, 0);
end;

procedure TDUpdate.UMChangePreferences(var Msg: TMessage);
begin
  Caption := ReplaceStr(Preferences.LoadStr(666), '&', '');

  GroupBox.Caption := ReplaceStr(Preferences.LoadStr(224), '&', '');

  FBForward.Caption := Preferences.LoadStr(230);
end;

procedure TDUpdate.UMPADFileReceived(var Msg: TMessage);
var
  VersionStr: string;
begin
  if (not CheckOnlineVersion(PADFileStream, VersionStr, SetupProgramURI)) then
  begin
    FVersionInfo.Caption := Preferences.LoadStr(663) + ': ' + Preferences.LoadStr(384);
    MsgBox(Preferences.LoadStr(508), Preferences.LoadStr(45), MB_OK + MB_ICONERROR);
    FBCancel.Click();
  end
  else
  begin
    FVersionInfo.Caption := Preferences.LoadStr(663) + ': ' + VersionStr;

    {$MESSAGE 'Reinhard'}
//    if (not UpdateAvailable) then
//    begin
//      MsgBox(Preferences.LoadStr(507), Preferences.LoadStr(43), MB_OK + MB_ICONINFORMATION);
//      FBCancel.Click();
//    end
//    else
    begin
      SendMessage(Handle, UM_UPDATE_PROGRESSBAR, 0, 0);

      FBForward.Enabled := True;
      ActiveControl := FBForward;
    end;
  end;

  FreeAndNil(PADFileStream);
end;

procedure TDUpdate.UMSetupFileReceived(var Msg: TMessage);
begin
  FProgram.Caption := Preferences.LoadStr(665) + ': ' + Preferences.LoadStr(138);

  FreeAndNil(SetupProgramStream);

  Preferences.SetupProgram := SetupPrgFilename;

  MessageBox(0, PChar('Datei " + SetupPrgFilename + " sollte geschrieben worden sein.'), 'Debug für Reinhard', MB_OK);

  ModalResult := mrOk;
end;

procedure TDUpdate.UMTerminate(var Msg: TMessage);
begin
  HTTPThread.WaitFor();

  if ((INTERNET_ERROR_BASE <= HTTPThread.ErrorCode) and (HTTPThread.ErrorCode <= INTERNET_ERROR_LAST)) then
    MsgBox(HTTPThread.ErrorMessage + ' (#' + IntToStr(HTTPThread.ErrorCode), Preferences.LoadStr(45), MB_OK or MB_ICONERROR)
  else if (HTTPThread.ErrorCode <> 0) then
    RaiseLastOSError(HTTPThread.ErrorCode)
  else if (HTTPThread.HTTPStatus <> HTTP_STATUS_OK) then
    MsgBox(HTTPThread.HTTPMessage, Preferences.LoadStr(45), MB_OK or MB_ICONERROR)
  else if ((HTTPThread.DebugReceiveFileSize > 0) and (HTTPThread.DebugReceiveFileSize < HTTPThread.DebugReceivedFileSize)) then
    raise EAssertionFailed.Create('DebugReceiveFileSize: ' + IntToStr(HTTPThread.DebugReceiveFileSize) + #13#10
      + 'DebugReceivedFileSize: ' + IntToStr(HTTPThread.DebugReceivedFileSize))
  else if (Assigned(PADFileStream)) then
    Perform(UM_PAD_FILE_RECEIVED, 0, 0)
  else if (Assigned(SetupProgramStream)) then
    Perform(UM_SETUP_FILE_RECEIVED, 0, 0)
  else
    raise ERangeError.Create(SRangeError);

  HTTPThread.Free();
  HTTPThread := nil;

  FBCancel.Enabled := True;
  if (not FBForward.Enabled) then
    FBCancel.Caption := Preferences.LoadStr(231);
end;

procedure TDUpdate.UMUpdateProgressBar(var Msg: TMessage);
begin
  if (Msg.LParam <= 0) then
  begin
    FProgressBar.Position := 0;
    FProgressBar.Max := 0;
  end
  else
  begin
    FProgressBar.Position := Integer(Msg.WParam * 100) div Integer(Msg.LParam);
    FProgressBar.Max := 100;
  end;
end;

initialization
  FDUpdate := nil;
end.

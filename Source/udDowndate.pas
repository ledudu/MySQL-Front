unit udDowndate;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls,
  Forms_Ext,
  uBase;

type
  TDDowndate = class(TForm_Ext)
    FBOk: TButton;
    FBCancel: TButton;
    FDescription: TMemo;
    FLDescription: TLabel;
    FBHelp: TButton;
    FMail: TEdit;
    FLMail: TLabel;
    procedure FBHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    function Execute(): Boolean;
  end;

function DDowndate(): TDDowndate;

implementation {***************************************************************}

{$R *.dfm}

uses
  WinInet,
  RegularExpressions, DateUtils,
  uDeveloper, uPreferences;

var
  FDDowndate: TDDowndate;

function DDowndate(): TDDowndate;
begin
  if (not Assigned(FDDowndate)) then
  begin
    Application.CreateForm(TDDowndate, FDDowndate);
    FDDowndate.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDDowndate;
end;

{ TDDowndate ******************************************************************}

function TDDowndate.Execute(): Boolean;
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
    MsgBoxHelpContext := HelpContext;
    Result := MsgBox(Preferences.LoadStr(944, VersionString(Preferences.DowndateVersion)), Preferences.LoadStr(101), MB_YESNOCANCEL + MB_HELP + MB_ICONQUESTION) = IDYES;
  end
  else
    Result := ShowModal() = mrOk;
end;

procedure TDDowndate.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDDowndate.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Body: string;
  Flags: DWORD;
  Size: Integer;
  Stream: TMemoryStream;
  Thread: THTTPThread;
begin
  if ((ModalResult = mrOk) and (Trim(FDescription.Text) <> '')) then
  begin
    if ((Trim(FMail.Text) <> '') and not TRegEx.IsMatch(Trim(FMail.Text), MailPattern, [roSingleLine, roIgnoreCase])) then
      MsgBox('Invalid mail address.', Preferences.LoadStr(45), MB_OK or MB_ICONERROR)
    else
    begin
      Body := Trim(FDescription.Text);

      Stream := TMemoryStream.Create();

      if (not CheckWin32Version(6)) then
        Flags := 0
      else
        Flags := WC_ERR_INVALID_CHARS;
      Size := WideCharToMultiByte(CP_UTF8, Flags, PChar(Body), Length(Body), nil,
        0, nil, nil);
      Stream.SetSize(Size);
      WideCharToMultiByte(CP_UTF8, Flags, PChar(Body), Length(Body),
        PAnsiChar(Stream.Memory), Stream.Size, nil, nil);

      Thread := THTTPThread.Create(LoadStr(1006), Stream, nil, 'Downdate', '', FMail.Text);
      Thread.Execute();
      if ((INTERNET_ERROR_BASE <= Thread.ErrorCode) and (Thread.ErrorCode <= INTERNET_ERROR_LAST)) then
      begin
        MsgBox(Thread.ErrorMessage + ' (#' + IntToStr(Thread.ErrorCode), Preferences.LoadStr(45), MB_OK or MB_ICONERROR);
        CanClose := False;
      end
      else if (Thread.ErrorCode <> 0) then
        RaiseLastOSError(Thread.ErrorCode)
      else if (Thread.HTTPStatus <> HTTP_STATUS_OK) then
      begin
        MsgBox(Thread.HTTPMessage, Preferences.LoadStr(45), MB_OK or MB_ICONERROR);
        CanClose := False;
      end;
      Thread.Free();
    end;
  end;
end;

procedure TDDowndate.FormCreate(Sender: TObject);
begin
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  FDescription.Text := '';
  FMail.Text := '';
end;

procedure TDDowndate.FormShow(Sender: TObject);
begin
  FDescription.SelectAll();
  ActiveControl := FDescription;
end;

procedure TDDowndate.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(109, Icon);

  Caption := Preferences.LoadStr(943);

  FLDescription.Caption := 'Please write a short notice to the developer,'
    + ' why you remove this update. This helps him to improve ' + LoadStr(1000) + '.';

  FLMail.Caption := 'Your E-Mail:';

  FBHelp.Caption := Preferences.LoadStr(167);
  FBOk.Caption := Preferences.LoadStr(230);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDDowndate := nil;
end.


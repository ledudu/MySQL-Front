unit uDMail;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs,
  uBase,
  Forms_Ext, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TDMail = class(TForm_Ext)
    FBody: TRichEdit;
    FName: TEdit;
    FLName: TLabel;
    FLMail: TLabel;
    FMail: TEdit;
    FBOk: TButton;
    FBCancel: TButton;
    FLBody: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
  private
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    function Execute(): Boolean;
  end;

function DMail(): TDMail;

implementation {***************************************************************}

{$R *.dfm}

uses
  WinInet, CommCtrl,
  RegularExpressions,
  uPreferences, uDeveloper;

var
  FDMail: TDMail;

function DMail(): TDMail;
begin
  if (not Assigned(FDMail)) then
  begin
    Application.CreateForm(TDMail, FDMail);
    FDMail.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDMail;
end;

{ TDMail **********************************************************************}

function TDMail.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDMail.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Body: string;
  Flags: DWORD;
  Size: Integer;
  Stream: TMemoryStream;
  Thread: THTTPThread;
begin
  if (ModalResult = mrOK) then
  begin
    if (FName.Text = 'raise exception') then
      raise Exception.Create('Error Message');

    if (Trim(FName.Text) = '') then
      begin MessageBeep(MB_ICONERROR); ActiveControl := nil; ActiveControl := FName; CanClose := False; end;

    if (CanClose
      and ((Trim(FMail.Text) = '') or not TRegEx.IsMatch(Trim(FMail.Text), MailPattern, [roSingleLine, roIgnoreCase]))) then
      begin MessageBeep(MB_ICONERROR); ActiveControl := nil; ActiveControl := FMail; CanClose := False; end;

    if (CanClose and (Trim(FBody.Text) = '')) then
      begin MessageBeep(MB_ICONERROR); ActiveControl := nil; ActiveControl := FBody; CanClose := False; end;

    if (CanClose) then
    begin
      Body := Trim(FBody.Text);

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

      Thread := THTTPThread.Create(LoadStr(1006), Stream, nil, 'Support', FName.Text, FMail.Text);
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
        MsgBox('Response from the Web-Server:' + #13#10 + IntToStr(Thread.HTTPStatus) + ' ' + Thread.HTTPMessage, Preferences.LoadStr(45), MB_OK or MB_ICONERROR);
        CanClose := False;
      end
      else
        MsgBox('Your message was sent to the developer.', Preferences.LoadStr(43), MB_OK + MB_ICONINFORMATION);
      Thread.Free();
    end;
  end;
end;

procedure TDMail.FormCreate(Sender: TObject);
var
  Size: DWORD;
  UserName: string;
begin
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  Size := 64 + 1;
  SetLength(UserName, Size);
  if (GetUserName(PChar(UserName), Size)) then
  begin
    SetLength(UserName, Size - 1);
    FName.Text := UserName;
  end;
end;

procedure TDMail.FormShow(Sender: TObject);
begin
  FBody.Text := 'Hi Nils,' + #13#10#13#10;
end;

procedure TDMail.UMPreferencesChanged(var Message: TMessage);
begin
  Preferences.Images.GetIcon(109, Icon);

  Caption := 'Support';

  FLName.Caption := 'Name:';
  FLMail.Caption := 'E-Mail:';
  FLBody.Caption := 'Message:';

  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDMail := nil;
end.


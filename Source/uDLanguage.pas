unit uDLanguage;

interface {********************************************************************}

uses
  Messages, Classes, IniFiles, ToolWin,
  Forms, Controls, StdCtrls, Grids, ComCtrls,
  Forms_Ext,
  uBase;

type
  TDLanguage = class(TForm_Ext)
    StringGrid: TStringGrid;
    FBOk: TButton;
    FBCancel: TButton;
    FBPublish: TButton;
    FFind: TEdit;
    TBFind: TToolBar;
    FFindStart: TToolButton;
    FMail: TEdit;
    FLMail: TLabel;
    procedure FBPublishClick(Sender: TObject);
    procedure FFindChange(Sender: TObject);
    procedure FFindEnter(Sender: TObject);
    procedure FFindExit(Sender: TObject);
    procedure FFindKeyPress(Sender: TObject; var Key: Char);
    procedure FFindStartClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure StringGridKeyPress(Sender: TObject; var Key: Char);
    procedure StringGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StringGridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure StringGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    EnglishFile: TMemIniFile;
    FindFirst: Boolean;
    LanguageFile: TMemIniFile;
    procedure CMSysFontChanged(var Message: TMessage); message CM_SYSFONTCHANGED;
    procedure Find();
    procedure StringGridResize(Sender: TObject);
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
    procedure UpdateLanguageFile();
  public
    Filename: string;
    function Execute(): Boolean;
  end;

function DLanguage(): TDLanguage;

implementation {***************************************************************}

{$R *.dfm}

uses
  Windows, Math, SysUtils, StrUtils, ShlwApi, CommCtrl, WinInet,
  RegularExpressions,
  uPreferences, uDeveloper;

var
  FDLanguage: TDLanguage;

function DLanguage(): TDLanguage;
begin
  if (not Assigned(FDLanguage)) then
  begin
    Application.CreateForm(TDLanguage, FDLanguage);
    FDLanguage.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDLanguage;
end;

{ TDLanguage ******************************************************************}

procedure TDLanguage.CMSysFontChanged(var Message: TMessage);
begin
  inherited;

  StringGridResize(nil);

  TBFind.Left := FFind.Left + FFind.Width;
  TBFind.ButtonHeight := FFind.Height;
  TBFind.Height := TBFind.ButtonHeight;
end;

function TDLanguage.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDLanguage.FBPublishClick(Sender: TObject);
var
  Body: String;
  Flags: DWORD;
  Thread: THTTPThread;
  Size: Integer;
  Stream: TMemoryStream;
  Strings: TStringList;
begin
  if (MsgBox('You can send your translation to the developer of ' + LoadStr(1000) + '.'
    + ' He will enclose your work within the next update to share it to other users.' + #10#10
    + 'Send now?', Preferences.LoadStr(101), MB_YESNOCANCEL + MB_ICONQUESTION) = IDYES) then
  begin
    if ((Trim(FMail.Text) <> '') and not TRegEx.IsMatch(Trim(FMail.Text), MailPattern, [roSingleLine, roIgnoreCase])) then
      MsgBox('Invalid mail address.', Preferences.LoadStr(45), MB_OK or MB_ICONERROR)
    else
    begin
      UpdateLanguageFile();
      Strings := TStringList.Create();
      LanguageFile.GetStrings(Strings);

      Body := 'Language: ' + LanguageFile.ReadString('Global', 'Name', 'Translation') + #13#10
        + 'E-Mail: ' + Trim(FMail.Text) + #13#10
        + #13#10
        + Strings.Text;

      Strings.Free();

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

      Thread := THTTPThread.Create(LoadStr(1006), Stream, nil, 'Language Translation');
      Thread.Execute();
      if ((INTERNET_ERROR_BASE <= Thread.ErrorCode) and (Thread.ErrorCode <= INTERNET_ERROR_LAST)) then
        MsgBox(Thread.ErrorMessage + ' (#' + IntToStr(Thread.ErrorCode), Preferences.LoadStr(45), MB_OK or MB_ICONERROR)
      else if (Thread.ErrorCode <> 0) then
        RaiseLastOSError(Thread.ErrorCode)
      else if (Thread.HTTPStatus <> HTTP_STATUS_OK) then
        MsgBox(Thread.HTTPMessage, Preferences.LoadStr(45), MB_OK or MB_ICONERROR)
      else
        MsgBox('Your translation was sent to the developer.', Preferences.LoadStr(43), MB_OK + MB_ICONINFORMATION);
      Thread.Free();
    end;
  end;
end;

procedure TDLanguage.FFindChange(Sender: TObject);
begin
  FFindStart.Enabled := Trim(FFind.Text) <> '';
end;

procedure TDLanguage.FFindEnter(Sender: TObject);
begin
  FBOk.Default := False;
end;

procedure TDLanguage.FFindExit(Sender: TObject);
begin
  FBOk.Default := True;
end;

procedure TDLanguage.FFindKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
  begin
    FFindStart.Click();
    Key := #0;
  end
  else
    FindFirst := True;
end;

procedure TDLanguage.FFindStartClick(Sender: TObject);
begin
  Find();
end;

procedure TDLanguage.Find();
var
  I: Integer;
  Index: Integer;
  J: Integer;
begin
  if (FindFirst) then
    Index := 1
  else
    Index := StringGrid.Row + 2;
  FindFirst := False;

  for I := Index to StringGrid.RowCount - 1 do
    for J := 0 to 2 do
      if (Assigned(StrStrI(PChar(StringGrid.Rows[I][J]), PChar(Trim(FFind.Text))))) then
      begin
        StringGrid.Row := I;
        StringGrid.Col := 2;
        ActiveControl := StringGrid;
        exit;
      end;

  for I := 1 to Index - 1 do
    for J := 0 to 2 do
      if (Assigned(StrStrI(PChar(StringGrid.Rows[I][J]), PChar(Trim(FFind.Text))))) then
      begin
        StringGrid.Row := I;
        StringGrid.Col := 2;
        exit;
      end;

  MsgBox(Preferences.LoadStr(533, FFind.Text), Preferences.LoadStr(45), MB_OK or MB_ICONERROR);
end;

procedure TDLanguage.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (ModalResult = mrOk) then
  begin
    UpdateLanguageFile();
    try
      LanguageFile.UpdateFile();
    except
      on E: Exception do
        begin
          MsgBox(E.Message, Preferences.LoadStr(45), MB_OK or MB_ICONERROR);
          CanClose := False;
        end;
    end;
  end;
end;

procedure TDLanguage.FormCreate(Sender: TObject);
begin
  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;

  BorderStyle := bsSizeable;

  StringGrid.Options := StringGrid.Options + [goEditing];
  TBFind.Images := Preferences.Images;
end;

procedure TDLanguage.FormHide(Sender: TObject);
begin
  EnglishFile.Free();
  LanguageFile.Free();
end;

procedure TDLanguage.FormResize(Sender: TObject);
begin
  StringGridResize(nil);
end;

procedure TDLanguage.FormShow(Sender: TObject);
var
  I: Integer;
  Section: TStrings;
begin
  EnglishFile := TMemIniFile.Create(Preferences.LanguagePath + 'English.ini');
  LanguageFile := TMemIniFile.Create(Preferences.LanguagePath + Filename);

  Section := TStringList.Create();

  EnglishFile.ReadSectionValues('Strings', Section);

  StringGrid.RowCount := Section.Count + 1;
  StringGrid.Rows[0][1] := 'English';
  StringGrid.Rows[0][2] := LanguageFile.ReadString('Global', 'Name', 'Translation');
  for I := 0 to Section.Count - 1 do
  begin
    if (Section.Names[I] = '') then
      StringGrid.Rows[I + 1][1] := Section[I]
    else
    begin
      StringGrid.Rows[I + 1][0] := Section.Names[I];
      StringGrid.Rows[I + 1][1] := Section.ValueFromIndex[I];
    end;
  end;

  LanguageFile.ReadSectionValues('Strings', Section);
  for I := 1 to StringGrid.RowCount - 1 do
  begin
    StringGrid.Rows[I][2] := Section.Values[StringGrid.Rows[I][0]];
  end;

  Section.Free();

  StringGrid.Row := 1;
  StringGrid.Col := 2;
  ActiveControl := StringGrid;
end;

procedure TDLanguage.StringGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F3) then
  begin
    Find();
    Key := 0;
  end;
end;

procedure TDLanguage.StringGridKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #6) then
  begin
    ActiveControl := FFind;
    Key := #0;
  end;
end;

procedure TDLanguage.StringGridMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Col: Integer;
  Row: Integer;
begin
  StringGrid.MouseToCell(X, Y, Col, Row);

  if (Col <> 1) then
    StringGrid.Hint := ''
  else
    StringGrid.Hint := StringGrid.Rows[Row][Col];
end;

procedure TDLanguage.StringGridResize(Sender: TObject);
begin
  StringGrid.ColWidths[0] := Canvas.TextWidth('123456');
  StringGrid.ColWidths[1] := (StringGrid.ClientWidth - 2 * GetSystemMetrics(SM_CXEDGE) - StringGrid.ColWidths[0]) div 2;
  StringGrid.ColWidths[2] := StringGrid.ClientWidth - 2 * GetSystemMetrics(SM_CXEDGE) - StringGrid.ColWidths[0] - StringGrid.ColWidths[1];
end;

procedure TDLanguage.StringGridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  CanSelect := (ACol = 2);
end;

procedure TDLanguage.UMChangePreferences(var Message: TMessage);
begin
  Preferences.Images.GetIcon(108, Icon);

  Caption := 'Translation';

  SendMessage(FFind.Handle, EM_SETCUEBANNER, 0, LParam(PChar(Preferences.LoadStr(424))));
  SendMessage(FMail.Handle, EM_SETCUEBANNER, 0, LParam(PChar('My@Mail-Address.com')));

  FLMail.Caption := 'Your E-Mail:';
  FBPublish.Caption := 'Publish for other users...';

  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

procedure TDLanguage.UpdateLanguageFile();
var
  I: Integer;
  Name: string;
begin
  if (not LanguageFile.ValueExists('Global', 'Name')) then
  begin
    LanguageFile.WriteString('Global', 'Type', 'Language');
    if (LowerCase(RightStr(Filename, 4)) = '.ini') then
      Name := LeftStr(Filename, Length(Filename) - 4)
    else
      Name := Filename;
    LanguageFile.WriteString('Global', 'Name', Name);
  end;

  for I := 1 to StringGrid.RowCount - 1 do
    if ((StringGrid.Rows[I][0] <> '') and (Trim(StringGrid.Rows[I][2]) <> '')) then
      LanguageFile.WriteString('Strings', StringGrid.Rows[I][0], Trim(StringGrid.Rows[I][2]));
end;

initialization
  FDLanguage := nil;
end.


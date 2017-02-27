unit Dialogs_Ext;

interface {********************************************************************}

uses
  Windows, Messages, ShlObj,
  SysUtils, Classes,
  Dialogs, ExtCtrls, Controls, StdCtrls, ExtDlgs,
  StdCtrls_Ext;

type
  TOpenDialog_Ext = class;
  TSaveDialog_Ext = class;

  TVistaOpenDialog = class(TFileOpenDialog)
  private
    FileDialogCustomize: IFileDialogCustomize;
  strict protected
    function CreateFileDialog(): IFileDialog; override;
    function GetResults(): HResult; override;
  public
    OpenDialog: TOpenDialog_Ext;
  end;

  TVistaSaveDialog = class(TFileSaveDialog)
  private
    FileDialogCustomize: IFileDialogCustomize;
  strict protected
    function CreateFileDialog(): IFileDialog; override;
    function GetResults(): HResult; override;
  public
    SaveDialog: TSaveDialog_Ext;
  end;

  TOpenDialog_Ext = class(TOpenDialog)
  private
    FEncodingIndex: Integer;
    FEncodingLabel: String;
    FEncodings: TStrings;
    FSelector: THandle;
    HEncoding: THandle;
    HEncodingLabel: THandle;
    SelectorRect: TRect;
    VistaDialog: TCustomFileDialog;
    WindowRect: TRect;
    procedure SetEncodings(const Value: TStrings);
  protected
    procedure DoClose(); override;
    procedure DoShow(); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    function Execute(): Boolean; override;
  published
    property EncodingIndex: Integer read FEncodingIndex write FEncodingIndex default 0;
    property EncodingLabel: String read FEncodingLabel write FEncodingLabel;
    property Encodings: TStrings read FEncodings write SetEncodings;
  end;

  TSaveDialog_Ext = class(TOpenDialog_Ext)
  public
    function Execute(): Boolean; override;
  end;

function CodePageToEncoding(const CodePage: Cardinal): string;
function EncodingToCodePage(const Encoding: String): Cardinal;
function EncodingCaptions(const SBCSOnly: Boolean = False): String;

const
  START_PAGE_GENERAL = $ffffffff;

  {$EXTERNALSYM PD_CURRENTPAGE}
  PD_CURRENTPAGE = $00400000;
  {$EXTERNALSYM PD_NOCURRENTPAGE}
  PD_NOCURRENTPAGE = $00800000;
  {$EXTERNALSYM PD_EXCLUSIONFLAGS}
  PD_EXCLUSIONFLAGS = $01000000;
  {$EXTERNALSYM PD_USELARGETEMPLATE}
  PD_USELARGETEMPLATE = $10000000;
  {$EXTERNALSYM PD_NONETWORKBUTTON}
  PD_NONETWORKBUTTON = $00200000;

type
  HPROPSHEETPAGE = array of HWND;

procedure Register();

implementation {***************************************************************}

uses
  CommDlg, Dlgs, ActiveX, WinSpool,
  RTLConsts, StrUtils, SysConst, ComObj,
  Forms, Consts;

const
  CP_UNICODE = 1200;

type
  TCharacter_Set = record
    Caption: PChar;
    CodePage: Cardinal;
  end;
const
  Character_Sets: array[0..2] of TCharacter_Set = (
    (Caption: 'ANSI'; CodePage: CP_ACP),
    (Caption: 'UTF-8'; CodePage: CP_UTF8),
    (Caption: 'Unicode'; CodePage: CP_UNICODE)
  );

procedure Register();
begin
  RegisterComponents('VCL Extensions', [TOpenDialog_Ext]);
  RegisterComponents('VCL Extensions', [TSaveDialog_Ext]);
end;

function CodePageToEncoding(const CodePage: Cardinal): string;
var
  I: Integer;
begin
  Result := Character_Sets[0].Caption;

  for I := 0 to Length(Character_Sets) - 1 do
    if (Character_Sets[I].CodePage = CodePage) then
      Result := Character_Sets[I].Caption;
end;

function EncodingToCodePage(const Encoding: String): Cardinal;
var
  I: Integer;
begin
  Result := CP_ACP;

  for I := 0 to Length(Character_Sets) - 1 do
    if (Character_Sets[I].Caption = Encoding) then
      Result := Character_Sets[I].CodePage;

  if (Result = CP_ACP) then
    Result := GetACP();
end;

function EncodingCaptions(const SBCSOnly: Boolean = False): String;
var
  I: Integer;
begin
  Result := '';

  for I := 0 to Length(Character_Sets) - 1 do
    if (not SBCSOnly or (Character_Sets[I].CodePage <> CP_UNICODE)) then
    begin
      if (Result <> '') then Result := Result + #13#10;
      Result := Result + Character_Sets[I].Caption;
    end;
end;

{ TVistaOpenDialog ************************************************************}

const
  idEncoding = 1000;
  idGEncoding = 1010;

function TVistaOpenDialog.CreateFileDialog(): IFileDialog;
var
  I: Integer;
begin
  Result := inherited CreateFileDialog;

  if ((OpenDialog.Encodings.Count = 0) or (Result.QueryInterface(StringToGUID('{8016B7B3-3D49-4504-A0AA-2A37494E606F}'), FileDialogCustomize) <> S_OK)) then
    FileDialogCustomize := nil
  else
  begin
    FileDialogCustomize.StartVisualGroup(idGEncoding, PChar(OpenDialog.EncodingLabel));
    FileDialogCustomize.AddComboBox(idEncoding);
    for I := 0 to OpenDialog.Encodings.Count - 1 do
      FileDialogCustomize.AddControlItem(idEncoding, I, PChar(OpenDialog.Encodings[I]));
    if (OpenDialog.EncodingIndex >= 0) then
      FileDialogCustomize.SetSelectedControlItem(idEncoding, OpenDialog.EncodingIndex);
    FileDialogCustomize.EndVisualGroup();
  end;
end;

function TVistaOpenDialog.GetResults(): HResult;
var
  dwIDItem: Cardinal;
begin
  Result := inherited GetResults();

  if ((Result = S_OK) and Assigned(FileDialogCustomize)) then
    if (FileDialogCustomize.GetSelectedControlItem(idEncoding, dwIDItem) <> S_OK) then
      OpenDialog.EncodingIndex := -1
    else
      OpenDialog.EncodingIndex := dwIDItem;
end;

{ TVistaSaveDialog ************************************************************}

function TVistaSaveDialog.CreateFileDialog(): IFileDialog;
var
  I: Integer;
begin
  Result := inherited CreateFileDialog();

  // Debug 2016-11-30
  if (not Assigned(Result)) then
    raise ERangeError.Create(SRangeError);

  if ((SaveDialog.Encodings.Count = 0) or (Result.QueryInterface(StringToGUID('{8016B7B3-3D49-4504-A0AA-2A37494E606F}'), FileDialogCustomize) <> S_OK)) then
    FileDialogCustomize := nil
  else
  begin
    FileDialogCustomize.StartVisualGroup(idGEncoding, PChar(SaveDialog.EncodingLabel));
    FileDialogCustomize.AddComboBox(idEncoding);
    for I := 0 to SaveDialog.Encodings.Count - 1 do
      FileDialogCustomize.AddControlItem(idEncoding, I, PChar(SaveDialog.Encodings[I]));
    if (SaveDialog.EncodingIndex >= 0) then
      FileDialogCustomize.SetSelectedControlItem(idEncoding, SaveDialog.EncodingIndex);
    FileDialogCustomize.EndVisualGroup();
  end;
end;

function TVistaSaveDialog.GetResults(): HResult;
var
  dwIDItem: Cardinal;
begin
  Result := inherited GetResults();

  if ((Result = S_OK) and Assigned(FileDialogCustomize)) then
    if (FileDialogCustomize.GetSelectedControlItem(idEncoding, dwIDItem) <> S_OK) then
      SaveDialog.EncodingIndex := -1
    else
      SaveDialog.EncodingIndex := dwIDItem;
end;

{ TOpenDialog_Ext *************************************************************}

constructor TOpenDialog_Ext.Create(AOwner: TComponent);
begin
  inherited;

  FEncodings := TStringList.Create;
  FEncodingIndex := -1;
  FEncodingLabel := SEncodingLabel;

  HEncodingLabel := 0;
  HEncoding := 0;
end;

destructor TOpenDialog_Ext.Destroy();
begin
  FEncodings.Free();

  inherited;
end;

procedure TOpenDialog_Ext.DoClose();
begin
  if (HEncodingLabel = 0) then
    FEncodingIndex := -1
  else
  begin
    FEncodingIndex := SendMessage(HEncoding, CB_GETCURSEL, 0, 0);

    CloseWindow(HEncodingLabel);
    CloseWindow(HEncoding);

    if (FSelector > 0) then
      SetWindowPos(FSelector, 0, 0, 0, SelectorRect.Right - SelectorRect.Left, SelectorRect.Bottom - SelectorRect.Top, SWP_NOMOVE);

    SetWindowPos(GetParent(Handle), 0, 0, 0, WindowRect.Right - WindowRect.Left, WindowRect.Bottom - WindowRect.Top, SWP_NOMOVE);
  end;

  inherited;
end;

procedure TOpenDialog_Ext.DoShow();
var
  ClientRect: TRect;
  FilenameRect: TRect;
  FilterRect: TRect;
  I: Integer;
  LabelRect: TRect;
  Parent: THandle;
begin
  if (FEncodings.Count > 0) then
  begin
    Parent := GetParent(Handle);

    GetWindowRect(Parent, WindowRect);
    Windows.GetClientRect(Parent, ClientRect);

    GetWindowRect(GetDlgItem(Parent, stc2), LabelRect);
    if (not GetWindowRect(GetDlgItem(Parent, cmb13), FilenameRect)) then
      GetWindowRect(GetDlgItem(Parent, edt1), FilenameRect);
    GetWindowRect(GetDlgItem(Parent, cmb1), FilterRect);

    SetWindowPos(Parent, 0, 0, 0, WindowRect.Right - WindowRect.Left, WindowRect.Bottom - WindowRect.Top
      + FilterRect.Top - FilenameRect.Top, SWP_NOMOVE);

    if (CheckWin32Version(5, 1)) then
    begin
      FSelector := GetNextDlgTabItem(Parent, GetDlgItem(Parent, lst1), True);
      if ((FSelector > 0) and GetWindowRect(FSelector, SelectorRect)) then
        if ((SelectorRect.Bottom - SelectorRect.Top) div (SelectorRect.Right - SelectorRect.Left) >= 3) then
          SetWindowPos(FSelector, 0, 0, 0, SelectorRect.Right - SelectorRect.Left, SelectorRect.Bottom - SelectorRect.Top
            + FilterRect.Top - FilenameRect.Top, SWP_NOMOVE)
        else
          FSelector := 0;
    end;

    HEncodingLabel := CreateWindow('STATIC', '', WS_CHILD or WS_VISIBLE,
                LabelRect.Left - WindowRect.Left - (WindowRect.Right - WindowRect.Left - ClientRect.Right) div 2,
                LabelRect.Top + FilterRect.Top - FilenameRect.Top - WindowRect.Top - (WindowRect.Bottom - WindowRect.Top - ClientRect.Bottom) + (WindowRect.Right - WindowRect.Left - ClientRect.Right) div 2,
                LabelRect.Right - LabelRect.Left,
                LabelRect.Bottom - LabelRect.Top,
                Parent, 0, HInstance, nil);
    SendMessage(HEncodingLabel, WM_SETFONT, SendMessage(GetDlgItem(Parent, stc2), WM_GETFONT, 0, 0), MAKELPARAM(1, 0));
    SetWindowText(HEncodingLabel, PChar(FEncodingLabel));

    HEncoding := CreateWindow('COMBOBOX', '',
                CBS_DROPDOWNLIST or CBS_AUTOHSCROLL or WS_HSCROLL or WS_VSCROLL or WS_CHILD or WS_VISIBLE or WS_TABSTOP,
                FilterRect.Left - WindowRect.Left - (WindowRect.Right - WindowRect.Left - ClientRect.Right) div 2,
                FilterRect.Top + FilterRect.Top - FilenameRect.Top - WindowRect.Top - (WindowRect.Bottom - WindowRect.Top - ClientRect.Bottom) + (WindowRect.Right - WindowRect.Left - ClientRect.Right) div 2,
                FilterRect.Right - FilterRect.Left,
                FilterRect.Bottom - FilterRect.Top,
                Parent, 0, HInstance, nil);
    SendMessage(HEncoding, WM_SETFONT, SendMessage(GetDlgItem(Parent, cmb1), WM_GETFONT, 0, 0), MAKELPARAM(1, 0));
    SetWindowPos(HEncoding, GetDlgItem(Parent, cmb1), 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);

    for I := 0 to FEncodings.Count - 1 do
      SendMessage(HEncoding, CB_ADDSTRING, 0, lParam(PChar(FEncodings[I])));
    SendMessage(HEncoding, CB_SETCURSEL, FEncodingIndex, 0);
  end;
end;

function TOpenDialog_Ext.Execute(): Boolean;
var
  FileTypeItem: TFileTypeItem;
  Filters: TStringList;
  I: Integer;
begin
  if (not CheckWin32Version(6)) then
  begin
    VistaDialog := nil;

    Result := inherited Execute();

    if (CommDlgExtendedError = FNERR_INVALIDFILENAME) then
      raise Exception.CreateFmt(SInvalidFileName, [Filename]);
  end
  else
  begin
    if (not (Self is TSaveDialog_Ext)) then
    begin
      VistaDialog := TVistaOpenDialog.Create(Owner);
      TVistaOpenDialog(VistaDialog).OpenDialog := Self;
    end
    else
    begin
      VistaDialog := TVistaSaveDialog.Create(Owner);
      TVistaSaveDialog(VistaDialog).SaveDialog := TSaveDialog_Ext(Self);
    end;

    Result := Assigned(VistaDialog);
    if (Result) then
    begin
      VistaDialog.Title :=  Title;
      VistaDialog.DefaultFolder := InitialDir;
      VistaDialog.FileName := FileName;
      VistaDialog.DefaultExtension := DefaultExt;
      Filters := TStringList.Create();
      Filters.Text := ReplaceStr(Filter, '|', #10);
      for I := 0 to (Filters.Count div 2) - 1 do
      begin
        FileTypeItem := VistaDialog.FileTypes.Add();
        FileTypeItem.DisplayName := Filters[2 * I];
        FileTypeItem.FileMask := Filters[2 * I + 1];
      end;
      Filters.Free();
      VistaDialog.FileTypeIndex := FilterIndex;

      if (ofOverwritePrompt in Options)          then VistaDialog.Options := VistaDialog.Options + [fdoOverWritePrompt]    else VistaDialog.Options := VistaDialog.Options - [fdoOverWritePrompt];
      if (ofNoChangeDir in Options)              then VistaDialog.Options := VistaDialog.Options + [fdoNoChangeDir]        else VistaDialog.Options := VistaDialog.Options - [fdoNoChangeDir];
      if (ofNoValidate in Options)               then VistaDialog.Options := VistaDialog.Options + [fdoNoValidate]         else VistaDialog.Options := VistaDialog.Options - [fdoNoValidate];
      if (ofAllowMultiSelect in Options)         then VistaDialog.Options := VistaDialog.Options + [fdoAllowMultiSelect]   else VistaDialog.Options := VistaDialog.Options - [fdoAllowMultiSelect];
      if (not (ofExtensionDifferent in Options)) then VistaDialog.Options := VistaDialog.Options + [fdoStrictFileTypes]    else VistaDialog.Options := VistaDialog.Options - [fdoStrictFileTypes];
      if (ofPathMustExist in Options)            then VistaDialog.Options := VistaDialog.Options + [fdoPathMustExist]      else VistaDialog.Options := VistaDialog.Options - [fdoPathMustExist];
      if (ofFileMustExist in Options)            then VistaDialog.Options := VistaDialog.Options + [fdoFileMustExist]      else VistaDialog.Options := VistaDialog.Options - [fdoFileMustExist];
      if (ofCreatePrompt in Options)             then VistaDialog.Options := VistaDialog.Options + [fdoCreatePrompt]       else VistaDialog.Options := VistaDialog.Options - [fdoCreatePrompt];
      if (ofShareAware in Options)               then VistaDialog.Options := VistaDialog.Options + [fdoShareAware]         else VistaDialog.Options := VistaDialog.Options - [fdoShareAware];
      if (ofNoReadOnlyReturn in Options)         then VistaDialog.Options := VistaDialog.Options + [fdoNoReadOnlyReturn]   else VistaDialog.Options := VistaDialog.Options - [fdoNoReadOnlyReturn];
      if (ofNoTestFileCreate in Options)         then VistaDialog.Options := VistaDialog.Options + [fdoNoTestFileCreate]   else VistaDialog.Options := VistaDialog.Options - [fdoNoTestFileCreate];
      if (ofNoNetworkButton in Options)          then VistaDialog.Options := VistaDialog.Options + [fdoForceFileSystem]    else VistaDialog.Options := VistaDialog.Options - [fdoForceFileSystem];
      if (ofNoDereferenceLinks in Options)       then VistaDialog.Options := VistaDialog.Options + [fdoNoDereferenceLinks] else VistaDialog.Options := VistaDialog.Options - [fdoNoDereferenceLinks];
      if (ofDontAddToRecent in Options)          then VistaDialog.Options := VistaDialog.Options + [fdoDontAddToRecent]    else VistaDialog.Options := VistaDialog.Options - [fdoDontAddToRecent];
      if (ofForceShowHidden in Options)          then VistaDialog.Options := VistaDialog.Options + [fdoForceShowHidden]    else VistaDialog.Options := VistaDialog.Options - [fdoForceShowHidden];

      Result := VistaDialog.Execute();
      if (Result) then
      begin
        if (VistaDialog.Files.Count = 1) then
          FileName := VistaDialog.FileName
        else
          for I := 0 to VistaDialog.Files.Count - 1 do
          begin
            if (I > 0) then FileName := FileName + ' ';
            FileName := FileName + '"' + VistaDialog.Files[I] + '"';
          end;
        FilterIndex := VistaDialog.FileTypeIndex;
      end;

      VistaDialog.Free();
    end;
  end;
end;

procedure TOpenDialog_Ext.SetEncodings(const Value: TStrings);
begin
  FEncodings.Assign(Value);
end;

{ TSaveDialog_Ext *************************************************************}

function TSaveDialog_Ext.Execute(): Boolean;
begin
  if (not CheckWin32Version(6)) then
  begin
    Result := DoExecute(@GetSaveFileName);

    if (CommDlgExtendedError = FNERR_INVALIDFILENAME) then
      raise Exception.CreateFmt(SInvalidFileName, [Filename]);
  end
  else
    Result := inherited Execute();
end;

end.

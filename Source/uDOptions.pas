unit uDOptions;

interface {********************************************************************}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls,
  ExtCtrls_Ext, StdCtrls_Ext, ComCtrls_Ext, Forms_Ext,
  BCEditor.Editor, BCEditor.Editor.Base,
  uPreferences, uSession,
  uBase;

type
  TIniFileRecord = record
    Name: string;
    Filename: TFileName;
  end;

  TDOptions = class (TForm_Ext)
    ColorDialog: TColorDialog;
    FBCancel: TButton;
    FBEditorFont: TButton;
    FBGridFont: TButton;
    FBHelp: TButton;
    FBLanguage: TButton;
    FBOk: TButton;
    FEditorCompletionEnabled: TCheckBox;
    FEditorCompletionTime: TEdit;
    FEditorCurrRowBGColorEnabled: TCheckBox;
    FEditorFont: TEdit;
    FEditorWordWrap: TCheckBox;
    FGridCurrRowBGColorEnabled: TCheckBox;
    FGridFont: TEdit;
    FGridNullText: TCheckBox;
    FGridShowMemoContent: TCheckBox;
    FL2LogSize: TLabel;
    FLanguage: TComboBox_Ext;
    FLEditorCompletion: TLabel;
    FLEditorCompletionTime: TLabel;
    FLEditorCurrRowBGColor: TLabel;
    FLEditorFont: TLabel;
    FLEditorWordWrap: TLabel;
    FLGridCurrRowBGColor: TLabel;
    FLGridFont: TLabel;
    FLGridNullValues: TLabel;
    FLLanguage: TLabel;
    FLLogFont: TLabel;
    FLLogLinenumbers: TLabel;
    FLLogSize: TLabel;
    FLMaxColumnWidth: TLabel;
    FLMaxColumnWidthCharacters: TLabel;
    FLogFont: TEdit;
    FLogResult: TCheckBox;
    FLogSize: TEdit;
    FLogTime: TCheckBox;
    FLTabsVisible: TLabel;
    FLViewDatas: TLabel;
    FMaxColumnWidth: TEdit;
    FontDialog: TFontDialog;
    FTabsVisible: TCheckBox;
    FUDEditorCompletionTime: TUpDown;
    FUDLogSize: TUpDown;
    FUDMaxColumnWidth: TUpDown;
    GEditor: TGroupBox_Ext;
    GGrid: TGroupBox_Ext;
    GLog: TGroupBox_Ext;
    GProgram: TGroupBox_Ext;
    GTabs: TGroupBox_Ext;
    PageControl: TPageControl;
    PEditorCurrRowBGColor: TPanel_Ext;
    PEditorFont: TPanel_Ext;
    PGridCurrRowBGColor: TPanel_Ext;
    PGridFont: TPanel_Ext;
    PGridNullBGColor: TPanel_Ext;
    PGridNullBGColorEnabled: TCheckBox;
    PLogFont: TPanel_Ext;
    TSBrowser: TTabSheet;
    TSEditor: TTabSheet;
    TSLog: TTabSheet;
    TSView: TTabSheet;
    FBLogFont: TButton;
    GNavigator: TGroupBox;
    FQuickAccessVisible: TCheckBox;
    FLQuickAccessVisible: TLabel;
    procedure FBEditorCurrRowBGColorClick(Sender: TObject);
    procedure FBEditorFontClick(Sender: TObject);
    procedure FBGridCurrRowBGColorClick(Sender: TObject);
    procedure FBGridFontClick(Sender: TObject);
    procedure FBHelpClick(Sender: TObject);
    procedure FBLanguageClick(Sender: TObject);
    procedure FBLanguageKeyPress(Sender: TObject; var Key: Char);
    procedure FBLogFontClick(Sender: TObject);
    procedure FEditorFontKeyPress(Sender: TObject; var Key: Char);
    procedure FGridFontKeyPress(Sender: TObject; var Key: Char);
    procedure FLogFontKeyPress(Sender: TObject; var Key: Char);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PEditorCurrRowBGColorClick(Sender: TObject);
    procedure PGridCurrRowBGColorClick(Sender: TObject);
    procedure PGridNullBGColorClick(Sender: TObject);
    procedure TSBrowserResize(Sender: TObject);
    procedure TSEditorResize(Sender: TObject);
    procedure FBGridFontKeyPress(Sender: TObject; var Key: Char);
    procedure TSLogResize(Sender: TObject);
    procedure FBLogFontKeyPress(Sender: TObject; var Key: Char);
    procedure TSViewResize(Sender: TObject);
    procedure FLanguageChange(Sender: TObject);
  private
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
  public
    Languages: array of TIniFileRecord;
    function Execute(): Boolean;
  end;

function DOptions(): TDOptions;

implementation {***************************************************************}

{$R *.dfm}

uses
  IniFiles, UITypes, DateUtils,
  StrUtils,
  uDeveloper,
  uDLanguage;

var
  FDOptions: TDOptions;

function DOptions(): TDOptions;
begin
  if (not Assigned(FDOptions)) then
  begin
    Application.CreateForm(TDOptions, FDOptions);
    FDOptions.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDOptions;
end;

function TDOptions.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDOptions.FBEditorCurrRowBGColorClick(Sender: TObject);
begin
  if (PEditorCurrRowBGColor.Color = clNone) then
    ColorDialog.Color := clWindow
  else
    ColorDialog.Color := PEditorCurrRowBGColor.Color;

  if (ColorDialog.Execute()) then
    PEditorCurrRowBGColor.Color := ColorDialog.Color;
end;

procedure TDOptions.FBEditorFontClick(Sender: TObject);
begin
  FontDialog.Font := PEditorFont.Font;
  FontDialog.Options := FontDialog.Options + [fdFixedPitchOnly];
  if (FontDialog.Execute()) then
  begin
    FEditorFont.Text := FontDialog.Font.Name;
    PEditorFont.Font := FontDialog.Font;
  end;
end;

procedure TDOptions.FBGridCurrRowBGColorClick(Sender: TObject);
begin
  if (PGridCurrRowBGColor.Color = clNone) then
    ColorDialog.Color := clWindow
  else
    ColorDialog.Color := PGridCurrRowBGColor.Color;

  if (ColorDialog.Execute()) then
    PGridCurrRowBGColor.Color := ColorDialog.Color;
end;

procedure TDOptions.FBGridFontClick(Sender: TObject);
begin
  FontDialog.Font := PGridFont.Font;
  FontDialog.Options := FontDialog.Options - [fdFixedPitchOnly];
  if (FontDialog.Execute()) then
  begin
    FGridFont.Text := FontDialog.Font.Name;
    PGridFont.Font := FontDialog.Font;
  end;
end;

procedure TDOptions.FBGridFontKeyPress(Sender: TObject; var Key: Char);
begin
  FBGridFontClick(Sender);
end;

procedure TDOptions.FBHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDOptions.FBLanguageClick(Sender: TObject);
var
  CheckOnlineVersionThread: TCheckOnlineVersionThread;
  I: Integer;
begin
  if (not UpdateAvailable and (DateOf(LastUpdateCheck) < Today())) then
  begin
    CheckOnlineVersionThread := TCheckOnlineVersionThread.Create();
    CheckOnlineVersionThread.Execute();
    CheckOnlineVersionThread.Free();
  end;

  if (UpdateAvailable) then
  begin
    MsgBox('An update of ' + LoadStr(1000) + ' is available. Please install that update first.', Preferences.LoadStr(45), MB_OK or MB_ICONERROR);
    PostMessage(Application.MainForm.Handle, UM_ONLINE_UPDATE_FOUND, 0, 0);
    exit;
  end
  else if (DateOf(LastUpdateCheck) < Today()) then
    MsgBox('Can''t check, if you are using the latest update. Maybe an update of ' + LoadStr(1000) + ' is available...', Preferences.LoadStr(47), MB_OK + MB_ICONWARNING);


  DLanguage.Filename := '';
  for I := 0 to Length(Languages) - 1 do
    if (Trim(FLanguage.Text) = Languages[I].Name) then
      DLanguage.Filename := Languages[I].Filename;
  if (DLanguage.Execute()) then
    MsgBox('Please restart ' + LoadStr(1000) + ' to apply your changes.', Preferences.LoadStr(43), MB_OK + MB_ICONINFORMATION);
end;

procedure TDOptions.FBLanguageKeyPress(Sender: TObject; var Key: Char);
begin
  FBLanguageClick(Sender);
end;

procedure TDOptions.FBLogFontClick(Sender: TObject);
begin
  FontDialog.Font := PLogFont.Font;
  FontDialog.Options := FontDialog.Options + [fdFixedPitchOnly];
  if (FontDialog.Execute()) then
  begin
    FLogFont.Text := FontDialog.Font.Name;
    PLogFont.Font := FontDialog.Font;
  end;
end;

procedure TDOptions.FBLogFontKeyPress(Sender: TObject; var Key: Char);
begin
  FBLogFontClick(Sender);
end;

procedure TDOptions.FEditorFontKeyPress(Sender: TObject; var Key: Char);
begin
  FBEditorFontClick(Sender);
end;

procedure TDOptions.FGridFontKeyPress(Sender: TObject; var Key: Char);
begin
  FBGridFontClick(Sender);
end;

procedure TDOptions.FLanguageChange(Sender: TObject);
var
  I: Integer;
  Language: string;
begin
  if (FLanguage.ItemIndex = 0) then
  begin
    for I := 0 to Length(Languages) - 1 do
      if (lstrcmpi(PChar(Preferences.LanguageFilename), PChar(Languages[I].Filename)) = 0) then
        FLanguage.ItemIndex := FLanguage.Items.IndexOf(Languages[I].Name);

    Language := Trim(InputBox('Add new translation', 'Language:', ''));
    if (Language <> '') then
      if (FileExists(Preferences.LanguagePath + Language + '.ini')) then
        MsgBox('The language "' + Language + '" already exists!', Preferences.LoadStr(45), MB_OK or MB_ICONERROR)
      else
      begin
        DLanguage.Filename := Language + '.ini';
        if (DLanguage.Execute()) then
          MsgBox('Please restart ' + LoadStr(1000) + ' to apply your changes.', Preferences.LoadStr(43), MB_OK + MB_ICONINFORMATION);
      end;
  end;
end;

procedure TDOptions.FLogFontKeyPress(Sender: TObject; var Key: Char);
begin
  FBLogFontClick(Sender);
end;

{ TDOptions *******************************************************************}

procedure TDOptions.FormHide(Sender: TObject);
var
  I: Integer;
begin
  if (ModalResult = mrOk) then
  begin
    if (FLanguage.ItemIndex >= 0) then
      for I := 0 to Length(Languages) - 1 do
        if (Trim(FLanguage.Text) = Languages[I].Name) then
          Preferences.LanguageFilename := Languages[I].Filename;

    Preferences.TabsVisible := FTabsVisible.Checked;
    Preferences.QuickAccessVisible := FQuickAccessVisible.Checked;

    Preferences.GridFontName := PGridFont.Font.Name;
    Preferences.GridFontStyle := PGridFont.Font.Style - [fsBold];
    Preferences.GridFontColor := PGridFont.Font.Color;
    Preferences.GridFontSize := PGridFont.Font.Size;
    Preferences.GridFontCharset := PGridFont.Font.Charset;
    Preferences.GridNullBGColorEnabled := PGridNullBGColorEnabled.Checked;
    Preferences.GridNullBGColor := PGridNullBGColor.Color;
    Preferences.GridNullText := FGridNullText.Checked;
    Preferences.GridCurrRowBGColorEnabled := FGridCurrRowBGColorEnabled.Checked;
    Preferences.GridCurrRowBGColor := PGridCurrRowBGColor.Color;

    Preferences.SQLFontName := PEditorFont.Font.Name;
    Preferences.SQLFontColor := PEditorFont.Font.Color;
    Preferences.SQLFontSize := PEditorFont.Font.Size;
    Preferences.SQLFontCharset := PEditorFont.Font.Charset;
    Preferences.Editor.CurrRowBGColorEnabled := FEditorCurrRowBGColorEnabled.Checked;
    Preferences.Editor.CurrRowBGColor := PEditorCurrRowBGColor.Color;
    Preferences.Editor.CodeCompletion := FEditorCompletionEnabled.Checked;
    Preferences.Editor.WordWrap := FEditorWordWrap.Checked;
    TryStrToInt(FEditorCompletionTime.Text, Preferences.Editor.CodeCompletionTime);

    Preferences.LogFontName := PLogFont.Font.Name;
    Preferences.LogFontStyle := PLogFont.Font.Style;
    Preferences.LogFontColor := PLogFont.Font.Color;
    Preferences.LogFontSize := PLogFont.Font.Size;
    Preferences.LogFontCharset := PLogFont.Font.Charset;
    Preferences.LogTime := FLogTime.Checked;
    Preferences.LogResult := FLogResult.Checked;
    Preferences.LogSize := FUDLogSize.Position * 1024;

    Preferences.GridMaxColumnWidth := FUDMaxColumnWidth.Position;

    Preferences.GridMemoContent := FGridShowMemoContent.Checked;
  end;
end;

procedure TDOptions.FormShow(Sender: TObject);
var
  I: Integer;
  IniFile: TMemIniFile;
  SearchRec: TSearchRec;
begin
  SetLength(Languages, 0);
  if (FindFirst(Preferences.LanguagePath + '*.ini', faAnyFile, SearchRec) = NO_ERROR) then
  begin
    repeat
      IniFile := TMemIniFile.Create(Preferences.LanguagePath + SearchRec.Name);

      if (UpperCase(IniFile.ReadString('Global', 'Type', '')) = 'LANGUAGE') then
      begin
        SetLength(Languages, Length(Languages) + 1);
        Languages[Length(Languages) - 1].Name := IniFile.ReadString('Global', 'Name', '');
        Languages[Length(Languages) - 1].Filename := SearchRec.Name;
      end;

      FreeAndNil(IniFile);
    until (FindNext(SearchRec) <> NO_ERROR);
    FindClose(SearchRec);
  end;

  FLanguage.Items.Clear();
  for I := 0 to Length(Languages) - 1 do
    FLanguage.Items.Add(Languages[I].Name);
  for I := 0 to Length(Languages) - 1 do
    if (lstrcmpi(PChar(Preferences.LanguageFilename), PChar(Languages[I].Filename)) = 0) then
      FLanguage.ItemIndex := FLanguage.Items.IndexOf(Languages[I].Name);
  FLanguage.Items.Add('Add new...');


  FTabsVisible.Checked := Preferences.TabsVisible;
  FQuickAccessVisible.Checked := Preferences.QuickAccessVisible;

  FUDMaxColumnWidth.Position := Preferences.GridMaxColumnWidth;

  FGridShowMemoContent.Checked := Preferences.GridMemoContent;

  FGridFont.Text := Preferences.GridFontName;
  PGridFont.Font.Name := Preferences.GridFontName;
  PGridFont.Font.Style := Preferences.GridFontStyle;
  PGridFont.Font.Color := Preferences.GridFontColor;
  PGridFont.Font.Size := Preferences.GridFontSize;
  PGridFont.Font.Charset := Preferences.GridFontCharset;
  PGridNullBGColorEnabled.Checked := Preferences.GridNullBGColorEnabled;
  PGridNullBGColor.Color := Preferences.GridNullBGColor;
  FGridNullText.Checked := Preferences.GridNullText;
  FGridCurrRowBGColorEnabled.Checked := Preferences.GridCurrRowBGColorEnabled;
  PGridCurrRowBGColor.Color := Preferences.GridCurrRowBGColor;

  FEditorFont.Text := Preferences.SQLFontName;
  PEditorFont.Font.Name := Preferences.SQLFontName;
  PEditorFont.Font.Color := Preferences.SQLFontColor;
  PEditorFont.Font.Size := Preferences.SQLFontSize;
  PEditorFont.Font.Charset := Preferences.SQLFontCharset;
  FEditorCurrRowBGColorEnabled.Checked := Preferences.Editor.CurrRowBGColorEnabled;
  PEditorCurrRowBGColor.Color := Preferences.Editor.CurrRowBGColor;
  FEditorCompletionEnabled.Checked := Preferences.Editor.CodeCompletion;
  FUDEditorCompletionTime.Position := Preferences.Editor.CodeCompletionTime;
  FEditorWordWrap.Checked := Preferences.Editor.WordWrap;

  FLogFont.Text := Preferences.LogFontName;
  PLogFont.Font.Name := Preferences.LogFontName;
  PLogFont.Font.Style := Preferences.LogFontStyle;
  PLogFont.Font.Color := Preferences.LogFontColor;
  PLogFont.Font.Size := Preferences.LogFontSize;
  PLogFont.Font.Charset := Preferences.LogFontCharset;
  FLogTime.Checked := Preferences.LogTime;
  FLogResult.Checked := Preferences.LogResult;
  FUDLogSize.Position := Preferences.LogSize div 1024;

  PageControl.ActivePage := TSView;
  ActiveControl := FLanguage;
end;

procedure TDOptions.PEditorCurrRowBGColorClick(Sender: TObject);
begin
  FBEditorCurrRowBGColorClick(Sender);
end;

procedure TDOptions.PGridCurrRowBGColorClick(Sender: TObject);
begin
  FBGridCurrRowBGColorClick(Sender);
end;

procedure TDOptions.PGridNullBGColorClick(Sender: TObject);
begin
  if (PGridNullBGColor.Color = clNone) then
    ColorDialog.Color := clWindow
  else
    ColorDialog.Color := PGridNullBGColor.Color;

  if (ColorDialog.Execute()) then
    PGridNullBGColor.Color := ColorDialog.Color;
end;

procedure TDOptions.TSBrowserResize(Sender: TObject);
begin
  FBGridFont.Left := FGridFont.Left + FGridFont.Width;
  FBGridFont.Height := FGridFont.Height;
end;

procedure TDOptions.TSEditorResize(Sender: TObject);
begin
  FBEditorFont.Left := FEditorFont.Left + FEditorFont.Width;
  FBEditorFont.Height := FEditorFont.Height;
end;

procedure TDOptions.TSLogResize(Sender: TObject);
begin
  FBLogFont.Left := FLogFont.Left + FLogFont.Width;
  FBLogFont.Height := FLogFont.Height;
end;

procedure TDOptions.TSViewResize(Sender: TObject);
begin
  FBLanguage.Left := FLanguage.Left + FLanguage.Width;
  FBLanguage.Height := FLanguage.Height;
end;

procedure TDOptions.UMChangePreferences(var Message: TMessage);
begin
  Canvas.Font := Font;

  Caption := Preferences.LoadStr(52);

  TSView.Caption := Preferences.LoadStr(491);
  GProgram.Caption := Preferences.LoadStr(52);
  FLLanguage.Caption := Preferences.LoadStr(32) + ':';
  GTabs.Caption := Preferences.LoadStr(851);
  FLTabsVisible.Caption := Preferences.LoadStr(699) + ':';
  FTabsVisible.Caption := Preferences.LoadStr(851);

  GNavigator.Caption := Preferences.LoadStr(10);
  FLQuickAccessVisible.Caption := Preferences.LoadStr(527) + ':';
  FQuickAccessVisible.Caption := Preferences.LoadStr(939);

  TSBrowser.Caption := Preferences.LoadStr(739);
  GGrid.Caption := Preferences.LoadStr(17);
  FLGridFont.Caption := Preferences.LoadStr(430) + ':';
  FLGridNullValues.Caption := Preferences.LoadStr(498) + ':';
  FGridNullText.Caption := Preferences.LoadStr(499);
  FLMaxColumnWidth.Caption := Preferences.LoadStr(208) + ':';
  FLMaxColumnWidthCharacters.Caption := Preferences.LoadStr(869);
  FLMaxColumnWidthCharacters.Left := FUDMaxColumnWidth.Left + FUDMaxColumnWidth.Width + Canvas.TextWidth('  ');
  FLViewDatas.Caption := Preferences.LoadStr(574) + ':';
  FGridShowMemoContent.Caption := Preferences.LoadStr(575);
  FLGridCurrRowBGColor.Caption := Preferences.LoadStr(784) + ':';

  TSEditor.Caption := Preferences.LoadStr(473);
  GEditor.Caption := Preferences.LoadStr(473);
  FLEditorFont.Caption := Preferences.LoadStr(439) + ':';
  FLEditorCurrRowBGColor.Caption := Preferences.LoadStr(784) + ':';
  FLEditorCurrRowBGColor.Caption := Preferences.LoadStr(784) + ':';
  FLEditorCompletion.Caption := Preferences.LoadStr(660) + ':';
  FEditorCompletionEnabled.Width := FEditorCurrRowBGColorEnabled.Width + Canvas.TextWidth(FEditorCompletionEnabled.Caption);
  FLEditorCompletionTime.Caption := Preferences.LoadStr(843);
  FLEditorCompletionTime.Left := FUDEditorCompletionTime.Left + FUDEditorCompletionTime.Width + Canvas.TextWidth('  ');
  FLEditorWordWrap.Caption := Preferences.LoadStr(891) + ':';
  FEditorWordWrap.Caption := Preferences.LoadStr(892);

  TSLog.Caption := Preferences.LoadStr(524);
  GLog.Caption := Preferences.LoadStr(524);
  FLLogFont.Caption := Preferences.LoadStr(525) + ':';
  FLLogLinenumbers.Caption := Preferences.LoadStr(527) + ':';
  FLogTime.Caption := Preferences.LoadStr(661);
  FLogResult.Caption := Preferences.LoadStr(662);
  FLLogSize.Caption := Preferences.LoadStr(844) + ':';
  FL2LogSize.Caption := 'KB';

  FBHelp.Caption := Preferences.LoadStr(167);
  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDOptions := nil;
end.

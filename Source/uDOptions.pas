unit uDOptions;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, ExtCtrls, ComCtrls, StdCtrls,
  ExtCtrls_Ext, StdCtrls_Ext, ComCtrls_Ext, Forms_Ext,
  BCEditor, BCEditor.Highlighter,
  uPreferences, uSession,
  uBase;

type
  TIniFileRecord = record
    Name: string;
    Filename: TFileName;
  end;

  TDOptions = class (TForm_Ext)
    ColorDialog: TColorDialog;
    FBackground: TCheckBox;
    FBBackground: TButton;
    FBCancel: TButton;
    FBEditorFont: TButton;
    FBForeground: TButton;
    FBGridFont: TButton;
    FBHelp: TButton;
    FBLanguage: TButton;
    FBLogFont: TButton;
    FBOk: TButton;
    FBold: TCheckBox;
    FEditorCaretBeyondEOL: TCheckBox;
    FEditorCompletionEnabled: TCheckBox;
    FEditorCompletionTime: TEdit;
    FEditorCurrRowBGColorEnabled: TCheckBox;
    FEditorFont: TEdit;
    FEditorWordWrap: TCheckBox;
    FForeground: TCheckBox;
    FGridCurrRowBGColorEnabled: TCheckBox;
    FGridFont: TEdit;
    FGridNullText: TCheckBox;
    FGridShowMemoContent: TCheckBox;
    FItalic: TCheckBox;
    FL2LogSize: TLabel;
    FLanguage: TComboBox_Ext;
    FLEditorCaretBeyondEOL: TLabel;
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
    FLQuickAccessVisible: TLabel;
    FLTabsVisible: TLabel;
    FLViewDatas: TLabel;
    FMaxColumnWidth: TEdit;
    FontDialog: TFontDialog;
    FPreview: TBCEditor;
    FQuickAccessVisible: TCheckBox;
    FSizer: TCheckBox;
    FStyles: TListView;
    FTabsVisible: TCheckBox;
    FUDEditorCompletionTime: TUpDown;
    FUDLogSize: TUpDown;
    FUDMaxColumnWidth: TUpDown;
    FUnderline: TCheckBox;
    GColors: TGroupBox_Ext;
    GEditor: TGroupBox_Ext;
    GGrid: TGroupBox_Ext;
    GLog: TGroupBox_Ext;
    GNavigator: TGroupBox;
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
    PQuery: TPanel_Ext;
    TSBrowser: TTabSheet;
    TSEditor: TTabSheet;
    TSHighlighter: TTabSheet;
    TSLog: TTabSheet;
    TSView: TTabSheet;
    procedure FBackgroundClick(Sender: TObject);
    procedure FBackgroundKeyPress(Sender: TObject; var Key: Char);
    procedure FBBackgroundClick(Sender: TObject);
    procedure FBEditorCurrRowBGColorClick(Sender: TObject);
    procedure FBEditorFontClick(Sender: TObject);
    procedure FBForegroundClick(Sender: TObject);
    procedure FBGridCurrRowBGColorClick(Sender: TObject);
    procedure FBGridFontClick(Sender: TObject);
    procedure FBGridFontKeyPress(Sender: TObject; var Key: Char);
    procedure FBHelpClick(Sender: TObject);
    procedure FBLanguageClick(Sender: TObject);
    procedure FBLanguageKeyPress(Sender: TObject; var Key: Char);
    procedure FBLogFontClick(Sender: TObject);
    procedure FBLogFontKeyPress(Sender: TObject; var Key: Char);
    procedure FBoldClick(Sender: TObject);
    procedure FBoldKeyPress(Sender: TObject; var Key: Char);
    procedure FEditorFontKeyPress(Sender: TObject; var Key: Char);
    procedure FForegroundClick(Sender: TObject);
    procedure FForegroundKeyPress(Sender: TObject; var Key: Char);
    procedure FGridFontKeyPress(Sender: TObject; var Key: Char);
    procedure FItalicClick(Sender: TObject);
    procedure FItalicKeyPress(Sender: TObject; var Key: Char);
    procedure FLanguageChange(Sender: TObject);
    procedure FLogFontKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FStylesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FUnderlineClick(Sender: TObject);
    procedure FUnderlineKeyPress(Sender: TObject; var Key: Char);
    procedure PEditorCurrRowBGColorClick(Sender: TObject);
    procedure PGridCurrRowBGColorClick(Sender: TObject);
    procedure PGridNullBGColorClick(Sender: TObject);
    procedure TSHighlighterShow(Sender: TObject);
    procedure TSBrowserResize(Sender: TObject);
    procedure TSEditorResize(Sender: TObject);
    procedure TSLogResize(Sender: TObject);
    procedure TSViewResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    LineNumbersElement: TBCEditorHighlighter.TElement;
    procedure CMSysFontChanged(var Message: TMessage); message CM_SYSFONTCHANGED;
    procedure FPreviewRefresh();
    function StylesElement(const Caption: string): TBCEditorHighlighter.TElement;
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Languages: array of TIniFileRecord;
    function Execute(): Boolean;
  end;

function DOptions(): TDOptions;

implementation {***************************************************************}

{$R *.dfm}

uses
  IniFiles, UITypes, DateUtils, StrUtils,
  BCEditor.Properties,
  uDeveloper,
  uDLanguage;

var
  FDOptions: TDOptions;

function DOptions(): TDOptions;
begin
  if (not Assigned(FDOptions)) then
  begin
    Application.CreateForm(TDOptions, FDOptions);
    FDOptions.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDOptions;
end;

{ TDOptions *******************************************************************}

procedure TDOptions.CMSysFontChanged(var Message: TMessage);
begin
  inherited;

  Perform(UM_PREFERENCES_CHANGED, 0, 0);
end;

function TDOptions.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDOptions.FBackgroundClick(Sender: TObject);
begin
  if (not FBackground.Checked) and Assigned(FStyles.Selected) then
    StylesElement(FStyles.Selected.Caption).Background := clNone;
  FPreviewRefresh();

  FBBackground.Enabled := FBackground.Checked;
end;

procedure TDOptions.FBackgroundKeyPress(Sender: TObject; var Key: Char);
begin
  FBackgroundClick(Sender);
end;

procedure TDOptions.FBBackgroundClick(Sender: TObject);
var
  Element: TBCEditorHighlighter.TElement;
begin
  if (Assigned(FStyles.Selected)) then
  begin
    Element := StylesElement(FStyles.Selected.Caption);
    if (Element.Background = clNone) then
      ColorDialog.Color := FPreview.Color
    else
      ColorDialog.Color := Element.Background;

    if (ColorDialog.Execute()) then
      Element.Background := ColorDialog.Color;
    FPreviewRefresh();
  end;
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

procedure TDOptions.FBForegroundClick(Sender: TObject);
var
  Element: TBCEditorHighlighter.TElement;
begin
  if (Assigned(FStyles.Selected)) then
  begin
    Element := StylesElement(FStyles.Selected.Caption);
    if (Element.Foreground = clNone) then
      ColorDialog.Color := FPreview.Font.Color
    else
      ColorDialog.Color := Element.Foreground;
    if (ColorDialog.Execute()) then
      Element.Foreground := ColorDialog.Color;
    FPreviewRefresh();
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

procedure TDOptions.FBoldClick(Sender: TObject);
var
  Element: TBCEditorHighlighter.TElement;
begin
  if (Assigned(FStyles.Selected)) then
  begin
    Element := StylesElement(FStyles.Selected.Caption);
    if (FBold.Checked) then
      Element.Style := Element.Style + [fsBold]
    else
      Element.Style := Element.Style - [fsBold];
    FPreviewRefresh();
  end;
end;

procedure TDOptions.FBoldKeyPress(Sender: TObject; var Key: Char);
begin
  FBoldClick(Sender);
end;

procedure TDOptions.FEditorFontKeyPress(Sender: TObject; var Key: Char);
begin
  FBEditorFontClick(Sender);
end;

procedure TDOptions.FForegroundClick(Sender: TObject);
begin
  if (not FForeground.Checked) and Assigned(FStyles.Selected) then
    StylesElement(FStyles.Selected.Caption).Foreground := clNone;
  FPreviewRefresh();

  FBForeground.Enabled := FForeground.Checked;
end;

procedure TDOptions.FForegroundKeyPress(Sender: TObject; var Key: Char);
begin
  FForegroundClick(Sender);
end;

procedure TDOptions.FGridFontKeyPress(Sender: TObject; var Key: Char);
begin
  FBGridFontClick(Sender);
end;

procedure TDOptions.FItalicClick(Sender: TObject);
var
  Element: TBCEditorHighlighter.TElement;
begin
  if (Assigned(FStyles.Selected)) then
  begin
    Element := StylesElement(FStyles.Selected.Caption);
    if (FItalic.Checked) then
      Element.Style := Element.Style + [fsItalic]
    else
      Element.Style := Element.Style - [fsItalic];
    FPreviewRefresh();
  end;
end;

procedure TDOptions.FItalicKeyPress(Sender: TObject; var Key: Char);
begin
  FItalicClick(Sender);
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


procedure TDOptions.FormCreate(Sender: TObject);
begin
  FPreview.Highlighter.LoadFromResource('Highlighter', RT_RCDATA);
  FPreview.Highlighter.Colors.LoadFromResource('Colors', RT_RCDATA);
  Preferences.ApplyToBCEditor(FPreview);
  LineNumbersElement := TBCEditorHighlighter.TElement.Create(FPreview.Highlighter.Colors, '');
  LineNumbersElement.Foreground := Preferences.Editor.LineNumbersForeground;
  LineNumbersElement.Background := Preferences.Editor.LineNumbersBackground;
end;

procedure TDOptions.FormDestroy(Sender: TObject);
begin
  LineNumbersElement.Free();
end;

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
    Preferences.Editor.CaretBeyondEOL := FEditorCaretBeyondEOL.Checked;
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
    Preferences.Editor.ConditionalCommentForeground := FPreview.Highlighter.Colors['Conditional'].Foreground;
    Preferences.Editor.ConditionalCommentBackground := FPreview.Highlighter.Colors['Conditional'].Background;
    Preferences.Editor.ConditionalCommentStyle := FPreview.Highlighter.Colors['Conditional'].Style;
    Preferences.Editor.CommentForeground := FPreview.Highlighter.Colors['Comment'].Foreground;
    Preferences.Editor.CommentBackground := FPreview.Highlighter.Colors['Comment'].Background;
    Preferences.Editor.CommentStyle := FPreview.Highlighter.Colors['Comment'].Style;
    Preferences.Editor.DataTypeForeground := FPreview.Highlighter.Colors['Type'].Foreground;
    Preferences.Editor.DataTypeBackground := FPreview.Highlighter.Colors['Type'].Background;
    Preferences.Editor.DataTypeStyle := FPreview.Highlighter.Colors['Type'].Style;
    Preferences.Editor.FunctionForeground := FPreview.Highlighter.Colors['Method'].Foreground;
    Preferences.Editor.FunctionBackground := FPreview.Highlighter.Colors['Method'].Background;
    Preferences.Editor.FunctionStyle := FPreview.Highlighter.Colors['Method'].Style;
    Preferences.Editor.IdentifierForeground := FPreview.Highlighter.Colors['Identifier'].Foreground;
    Preferences.Editor.IdentifierBackground := FPreview.Highlighter.Colors['Identifier'].Background;
    Preferences.Editor.IdentifierStyle := FPreview.Highlighter.Colors['Identifier'].Style;
    Preferences.Editor.KeywordForeground := FPreview.Highlighter.Colors['Keyword'].Foreground;
    Preferences.Editor.KeywordBackground := FPreview.Highlighter.Colors['Keyword'].Background;
    Preferences.Editor.KeywordStyle := FPreview.Highlighter.Colors['Keyword'].Style;
    Preferences.Editor.NumberForeground := FPreview.Highlighter.Colors['Number'].Foreground;
    Preferences.Editor.NumberBackground := FPreview.Highlighter.Colors['Number'].Background;
    Preferences.Editor.NumberStyle := FPreview.Highlighter.Colors['Number'].Style;
    Preferences.Editor.StringForeground := FPreview.Highlighter.Colors['String'].Foreground;
    Preferences.Editor.StringBackground := FPreview.Highlighter.Colors['String'].Background;
    Preferences.Editor.StringStyle := FPreview.Highlighter.Colors['String'].Style;
    Preferences.Editor.SymbolForeground := FPreview.Highlighter.Colors['Symbol'].Foreground;
    Preferences.Editor.SymbolBackground := FPreview.Highlighter.Colors['Symbol'].Background;
    Preferences.Editor.SymbolStyle := FPreview.Highlighter.Colors['Symbol'].Style;
    Preferences.Editor.VariableForeground := FPreview.Highlighter.Colors['Variable'].Foreground;
    Preferences.Editor.VariableBackground := FPreview.Highlighter.Colors['Variable'].Background;
    Preferences.Editor.VariableStyle := FPreview.Highlighter.Colors['Variable'].Style;
    Preferences.Editor.LineNumbersForeground := FPreview.Colors.LineNumbers.Foreground;
    Preferences.Editor.LineNumbersBackground := FPreview.Colors.LineNumbers.Background;
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
  FEditorCaretBeyondEOL.Checked := Preferences.Editor.CaretBeyondEOL;

  FLogFont.Text := Preferences.LogFontName;
  PLogFont.Font.Name := Preferences.LogFontName;
  PLogFont.Font.Style := Preferences.LogFontStyle;
  PLogFont.Font.Color := Preferences.LogFontColor;
  PLogFont.Font.Size := Preferences.LogFontSize;
  PLogFont.Font.Charset := Preferences.LogFontCharset;
  FLogTime.Checked := Preferences.LogTime;
  FLogResult.Checked := Preferences.LogResult;
  FUDLogSize.Position := Preferences.LogSize div 1024;

  FStyles.ItemIndex := 0; FStylesSelectItem(Self, FStyles.Selected, True);
  PageControl.ActivePage := TSView;
  ActiveControl := FLanguage;
end;

procedure TDOptions.FPreviewRefresh();
begin
  if (LineNumbersElement.Foreground = clNone) then
    FPreview.Colors.LineNumbers.Foreground := clWindowText
  else
    FPreview.Colors.LineNumbers.Foreground := LineNumbersElement.Foreground;
  if (LineNumbersElement.Background = clNone) then
    FPreview.Colors.LineNumbers.Background := clBtnFace
  else
    FPreview.Colors.LineNumbers.Background := LineNumbersElement.Background;
  FPreview.Invalidate();
end;

procedure TDOptions.FStylesSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  Element: TBCEditorHighlighter.TElement;
begin
  if (not Assigned(Item)) then
    Element := nil
  else
    Element := StylesElement(Item.Caption);

  FForeground.Checked := False;
  FBackground.Checked := False;
  FBold.Checked := False;
  FItalic.Checked := False;
  FUnderline.Checked := False;

  if (Selected and Assigned(Element)) then
  begin
    FForeground.Checked := Element.Foreground <> clNone;
    FBackground.Checked := Element.Background <> clNone;
    FBold.Checked := fsBold in Element.Style;
    FItalic.Checked := fsItalic in Element.Style;
    FUnderline.Checked := fsUnderline in Element.Style;
  end;

  FForeground.Enabled := Selected;
  FBackground.Enabled := Selected;
  FBold.Enabled := Selected and (Item.Caption <> Preferences.LoadStr(526));
  FItalic.Enabled := Selected and (Item.Caption <> Preferences.LoadStr(526));
  FUnderline.Enabled := Selected and (Item.Caption <> Preferences.LoadStr(526));

  FBForeground.Enabled := FForeground.Checked;
  FBBackground.Enabled := FBackground.Checked;
end;

procedure TDOptions.FUnderlineClick(Sender: TObject);
var
  Element: TBCEditorHighlighter.TElement;
begin
  if (Assigned(FStyles.Selected)) then
  begin
    Element := StylesElement(FStyles.Selected.Caption);
    if (FUnderline.Checked) then
      Element.Style := Element.Style + [fsUnderline]
    else
      Element.Style := Element.Style - [fsUnderline];
    FPreviewRefresh();
  end;
end;

procedure TDOptions.FUnderlineKeyPress(Sender: TObject; var Key: Char);
begin
  FUnderlineClick(Sender);
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

function TDOptions.StylesElement(const Caption: string): TBCEditorHighlighter.TElement;
begin
  Result := nil;

  if (Caption = Preferences.LoadStr(461)) then Result := FPreview.Highlighter.Colors['Comment'];
  if (Caption = Preferences.LoadStr(462)) then Result := FPreview.Highlighter.Colors['String'];
  if (Caption = Preferences.LoadStr(463)) then Result := FPreview.Highlighter.Colors['Keyword'];
  if (Caption = Preferences.LoadStr(464)) then Result := FPreview.Highlighter.Colors['Number'];
  if (Caption = Preferences.LoadStr(465)) then Result := FPreview.Highlighter.Colors['Identifier'];
  if (Caption = Preferences.LoadStr(466)) then Result := FPreview.Highlighter.Colors['Symbol'];
  if (Caption = Preferences.LoadStr(467)) then Result := FPreview.Highlighter.Colors['Method'];
  if (Caption = Preferences.LoadStr(468)) then Result := FPreview.Highlighter.Colors['Type'];
  if (Caption = Preferences.LoadStr(469)) then Result := FPreview.Highlighter.Colors['Variable'];
  if (Caption = Preferences.LoadStr(735)) then Result := FPreview.Highlighter.Colors['Conditional'];
  if (Caption = Preferences.LoadStr(526)) then Result := LineNumbersElement;
end;

procedure TDOptions.TSBrowserResize(Sender: TObject);
begin
  FBGridFont.Left := FGridFont.Left + FGridFont.Width;
  FBGridFont.Height := FGridFont.Height;
  FBGridFont.Width := FBGridFont.Height;
end;

procedure TDOptions.TSEditorResize(Sender: TObject);
begin
  FBEditorFont.Left := FEditorFont.Left + FEditorFont.Width;
  FBEditorFont.Height := FEditorFont.Height;
  FBEditorFont.Width := FBEditorFont.Height;
end;

procedure TDOptions.TSHighlighterShow(Sender: TObject);
begin
  FPreview.Font := PEditorFont.Font;

  FStyles.Selected := FStyles.Items.Item[0];
  FStyles.ItemFocused := FStyles.Selected;
  ActiveControl := FStyles;
end;

procedure TDOptions.TSLogResize(Sender: TObject);
begin
  FBLogFont.Left := FLogFont.Left + FLogFont.Width;
  FBLogFont.Height := FLogFont.Height;
  FBLogFont.Width := FBLogFont.Height;
end;

procedure TDOptions.TSViewResize(Sender: TObject);
begin
  FBLanguage.Left := FLanguage.Left + FLanguage.Width;
  FBLanguage.Height := FLanguage.Height;
  FBLanguage.Width := FBLanguage.Height;
end;

procedure TDOptions.UMPreferencesChanged(var Message: TMessage);
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
  FLEditorCaretBeyondEOL.Caption := Preferences.LoadStr(494) + ':';
  FEditorCaretBeyondEOL.Caption := Preferences.LoadStr(946);
  TSHighlighter.Caption := Preferences.LoadStr(528);
  GColors.Caption := Preferences.LoadStr(474);
  FStyles.Items.Clear();
  FStyles.Items.Add().Caption := Preferences.LoadStr(461);
  FStyles.Items.Add().Caption := Preferences.LoadStr(462);
  FStyles.Items.Add().Caption := Preferences.LoadStr(463);
  FStyles.Items.Add().Caption := Preferences.LoadStr(464);
  FStyles.Items.Add().Caption := Preferences.LoadStr(465);
  FStyles.Items.Add().Caption := Preferences.LoadStr(466);
  FStyles.Items.Add().Caption := Preferences.LoadStr(467);
  FStyles.Items.Add().Caption := Preferences.LoadStr(468);
  FStyles.Items.Add().Caption := Preferences.LoadStr(469);
  FStyles.Items.Add().Caption := Preferences.LoadStr(735);
  FStyles.Items.Add().Caption := Preferences.LoadStr(526);
  FStyles.SortType := Comctrls.stText;
  FBold.Caption := Preferences.LoadStr(477);
  FItalic.Caption := Preferences.LoadStr(478);
  FUnderline.Caption := Preferences.LoadStr(479);
  FForeground.Caption := Preferences.LoadStr(475);
  FForeground.Width := FSizer.Width + Canvas.TextWidth(FForeground.Caption);
  FBForeground.Left := FForeground.Left + FForeground.Width + FStyles.Left;
  FBackground.Caption := Preferences.LoadStr(476);
  FBackground.Width := FSizer.Width + Canvas.TextWidth(FBackground.Caption);
  FBBackground.Left := FBackground.Left + FBackground.Width + FStyles.Left;

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

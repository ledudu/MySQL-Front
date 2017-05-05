unit uDInfo;

interface {********************************************************************}

uses
  Windows, Messages,
  Classes, SysUtils,
  ExtCtrls, Controls, StdCtrls, Graphics, Forms,
  ExtCtrls_Ext, Forms_Ext,
  uPreferences,
  uBase;

type
  TDInfo = class(TForm_Ext)
    FBuild: TLabel;
    FImage: TImage;
    FBOk: TButton;
    FURI: TLabel;
    FVersion: TLabel;
    PImage: TPanel;
    FName: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FURIClick(Sender: TObject);
  private
    procedure CMSysFontChanged(var Message: TMessage); message CM_SYSFONTCHANGED;
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    function Execute(): Boolean;
  end;

function DInfo(): TDInfo;

implementation {***************************************************************}

{$R *.dfm}

uses
  ShellAPI, GDIPObj, GDIPAPI,
  uDeveloper;

var
  FDInfo: TDInfo;

function DInfo(): TDInfo;
begin
  if (not Assigned(FDInfo)) then
  begin
    Application.CreateForm(TDInfo, FDInfo);
    FDInfo.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDInfo;
end;

{ TDInfo **********************************************************************}

procedure TDInfo.CMSysFontChanged(var Message: TMessage);
begin
  inherited;

  FName.Font.Name := Font.Name;
  FVersion.Font.Name := Font.Name;
  FBuild.Font.Name := Font.Name;
  FURI.Font.Name := Font.Name;
end;

function TDInfo.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDInfo.FormCreate(Sender: TObject);
var
  GPBitmap: TGPBitmap;
  GPGraphics: TGPGraphics;
  Icon: HICON;
  IconId: Integer;
  ResData: HGLOBAL;
  ResInfo: HRSRC;
  Resource: Pointer;
begin
  ResInfo := FindResource(HInstance, 'MAINICON', RT_GROUP_ICON);
  ResData := LoadResource(HInstance, ResInfo);
  Resource := LockResource(ResData);
  IconId := LookupIconIdFromDirectoryEx(Resource, TRUE, 256, 256, LR_DEFAULTCOLOR);
  ResInfo := FindResource(HInstance, MAKEINTRESOURCE(IconId), RT_ICON);
  ResData := LoadResource(HInstance, ResInfo);
  Icon := CreateIconFromResourceEx(
    LockResource(ResData), SizeOfResource(HInstance, ResInfo),
    TRUE, $00030000, 256, 256, LR_DEFAULTCOLOR);

  FImage.Picture.Bitmap.PixelFormat := pf32bit;
  SetBkMode(FImage.Picture.Bitmap.Canvas.Handle, TRANSPARENT);
  FImage.Picture.Bitmap.SetSize(FImage.Width, FImage.Height);

  GPBitmap := TGPBitmap.Create(ICON);
  GPGraphics := TGPGraphics.Create(FImage.Canvas.Handle);
  GPGraphics.SetInterpolationMode(InterpolationModeHighQuality);
  GPGraphics.DrawImage(GPBitmap, 0, 0, FImage.Width, FImage.Height);
  GPGraphics.Free();
  GPBitmap.Free();
end;

procedure TDInfo.FormDestroy(Sender: TObject);
begin
  if (Assigned(FImage.Picture.Graphic)) then
    FImage.Picture.Graphic := nil;
end;

procedure TDInfo.FormShow(Sender: TObject);
begin
  ActiveControl := FBOk;
end;

procedure TDInfo.FURIClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(FURI.Caption), '', '', SW_SHOW);
end;

procedure TDInfo.UMPreferencesChanged(var Message: TMessage);
begin
  Caption := Preferences.LoadStr(367) + ' ' + LoadStr(1000);

  FName.Caption := SysUtils.LoadStr(1000);
  FVersion.Caption := Preferences.LoadStr(169) + ' ' + IntToStr(ProgramVersionMajor) + '.' + IntToStr(ProgramVersionMinor);
  FBuild.Caption := '(' + Preferences.LoadStr(737) + ': ' + IntToStr(ProgramVersionPatch) + '.' + IntToStr(ProgramVersionBuild) + ')';

  FURI.Caption := SysUtils.LoadStr(1004);

  FBOk.Caption := Preferences.LoadStr(231);
end;

initialization
  FDInfo := nil;
end.


unit uDPaste;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls,
  Forms_Ext,
  uBase;

type
  TDPaste = class(TForm_Ext)
    FBCancel: TButton;
    FBOk: TButton;
    FData: TCheckBox;
    FStructure: TCheckBox;
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure UMPreferencesChanged(var Message: TMessage); message UM_PREFERENCES_CHANGED;
  public
    Data: Boolean;
    Structure: Boolean;
    function Execute(): Boolean;
  end;

function DPaste(): TDPaste;

implementation {***************************************************************}

{$R *.dfm}

uses
  StrUtils,
  uPreferences;

var
  FDPaste: TDPaste;

function DPaste(): TDPaste;
begin
  if (not Assigned(FDPaste)) then
  begin
    Application.CreateForm(TDPaste, FDPaste);
    FDPaste.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDPaste;
end;

{ TDPaste *********************************************************************}

function TDPaste.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDPaste.FormHide(Sender: TObject);
begin
  if (ModalResult = mrOk) then
  begin
    Structure := FStructure.Checked;
    Data := FData.Checked;

    Preferences.Paste.Data := FData.Checked;
  end;
end;

procedure TDPaste.FormShow(Sender: TObject);
begin
  FData.Checked := Preferences.Paste.Data;

  ActiveControl := FData;
end;

procedure TDPaste.UMPreferencesChanged(var Message: TMessage);
begin
  Caption := Preferences.LoadStr(65);

  FStructure.Caption := Preferences.LoadStr(215);
  FData.Caption := Preferences.LoadStr(216);

  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDPaste := nil;
end.

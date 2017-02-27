unit uDQuickFilter;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls,
  Forms_Ext,
  uBase;

type
  TDQuickFilter = class (TForm_Ext)
    FBOk: TButton;
    FBCancel: TButton;
    FLValue: TLabel;
    FValue: TEdit;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    procedure UMChangePreferences(var Message: TMessage); message UM_CHANGEPREFERENCES;
  public
    Data: string;
    function Execute(): Boolean;
  end;

function DQuickFilter(): TDQuickFilter;

implementation {***************************************************************}

{$R *.dfm}

uses
  uPreferences;

var
  FDQuickFilter: TDQuickFilter;

function DQuickFilter(): TDQuickFilter;
begin
  if (not Assigned(FDQuickFilter)) then
  begin
    Application.CreateForm(TDQuickFilter, FDQuickFilter);
    FDQuickFilter.Perform(UM_CHANGEPREFERENCES, 0, 0);
  end;

  Result := FDQuickFilter;
end;

{ TDQuickFilter ***************************************************************}

function TDQuickFilter.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

procedure TDQuickFilter.FormShow(Sender: TObject);
begin
  FValue.Text := Data;

  ActiveControl := FBCancel;
  ActiveControl := FValue;
end;

procedure TDQuickFilter.FormHide(Sender: TObject);
begin
  if (ModalResult = mrOk) then
  begin
    Data := Trim(FValue.Text);
  end;
end;

procedure TDQuickFilter.UMChangePreferences(var Message: TMessage);
begin
  Caption := Preferences.LoadStr(489);

  FLValue.Caption := Preferences.LoadStr(490) + ':';

  FBOk.Caption := Preferences.LoadStr(29);
  FBCancel.Caption := Preferences.LoadStr(30);
end;

initialization
  FDQuickFilter := nil;
end.

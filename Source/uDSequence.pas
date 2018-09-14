unit uDSequence;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls,
  uBase, uSession;

type
  TDSequence = class(TForm)
    PageControl1: TPageControl;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    TSBasics: TTabSheet;
    TSSource: TTabSheet;
  private
  public
    Database: TSDatabase;
    Sequence: TSSequence;
    function Execute(): Boolean;
  end;

function DSequence(): TDSequence;

implementation {***************************************************************}

{$R *.dfm}

var
  FDSequence: TDSequence;

function DSequence(): TDSequence;
begin
  if (not Assigned(FDSequence)) then
  begin
    Application.CreateForm(TDSequence, FDSequence);
    FDSequence.Perform(UM_PREFERENCES_CHANGED, 0, 0);
  end;

  Result := FDSequence;
end;

{ TDSequence ******************************************************************}

function TDSequence.Execute(): Boolean;
begin
  Result := ShowModal() = mrOk;
end;

initialization
  FDSequence := nil;
end.

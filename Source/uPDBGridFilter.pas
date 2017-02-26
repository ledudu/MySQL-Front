unit uPDBGridFilter;

interface

uses
  Messages, Classes,
  Controls, StdCtrls, Forms, DBGrids,
  uBase, uSession, Vcl.ComCtrls;

type
  TPDBGridFilter = class(TForm)
    FActive: TCheckBox;
    FOperator: TComboBox;
    FNull: TComboBox;
    FExtender: TButton;
    FText: TEdit;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FOperatorChange(Sender: TObject);
  private
    procedure CMShowingChanged(var Msg: TMessage); message CM_SHOWINGCHANGED;
    procedure WMActivate(var Msg: TWMActivate); message WM_ACTIVATE;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    Column: TColumn;
  end;

var
  PDBGridFilter: TPDBGridFilter;

implementation

{$R *.dfm}

uses
  Windows,
  MySQLDB;

{ TPDBGridFilter **************************************************************}

procedure TPDBGridFilter.CMShowingChanged(var Msg: TMessage);
var
  Animation: BOOL;
begin
  Include(FFormState, fsShowing);
  try
    try
      if (Showing) then
        DoShow()
      else
        DoHide();
    except
      Application.HandleException(Self);
    end;
    if (not Showing) then
      SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_HIDEWINDOW or SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER)
    else if (SystemParametersInfo(SPI_GETCLIENTAREAANIMATION, 0, @Animation, 0) and Animation) then
      AnimateWindow(Handle, 100, AW_VER_POSITIVE or AW_SLIDE or AW_ACTIVATE)
    else
      SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER);
    DoubleBuffered := Visible;
  finally
    Exclude(FFormState, fsShowing);
  end;
end;

procedure TPDBGridFilter.CreateParams(var Params: TCreateParams);
begin
  inherited;

  Params.Style := WS_POPUP or WS_BORDER;
  Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW;

  if (Assigned(PopupParent)) then
    Params.WndParent := PopupParent.Handle;
end;

procedure TPDBGridFilter.FOperatorChange(Sender: TObject);
begin
  FNull.Visible := (FOperator.Text = 'IS');
  FText.Visible := not FNull.Visible;
end;

procedure TPDBGridFilter.FormCreate(Sender: TObject);
begin
  FExtender.Height := FText.Height;
  FExtender.Width := FExtender.Height;
end;

procedure TPDBGridFilter.FormHide(Sender: TObject);
begin
  FOperator.Items.BeginUpdate();
  FOperator.Items.Clear();
  FOperator.Items.EndUpdate();
end;

procedure TPDBGridFilter.FormShow(Sender: TObject);
begin
  FOperator.Items.BeginUpdate();
  FOperator.Items.Add('=');
  FOperator.Items.Add('<>');
  FOperator.Items.Add('>');
  FOperator.Items.Add('<');
  if (Column.Field.DataType in TextDataTypes) then
  begin
    FOperator.Items.Add('LIKE');
    FOperator.Items.Add('NOT LIKE');
  end;
  if (not Column.Field.Required) then
    FOperator.Items.Add('IS');
  FOperator.Items.EndUpdate();
  FOperator.ItemIndex := 0;

  FText.Text := Column.Field.AsString;
  if (Column.Field.IsNull) then
    FNull.ItemIndex := 0
  else
    FNull.ItemIndex := 1;

  FOperatorChange(FOperator);

  if (FNull.Visible) then
    ActiveControl := FNull
  else
    ActiveControl := FText;
end;

procedure TPDBGridFilter.WMActivate(var Msg: TWMActivate);
begin
  if ((Msg.Active <> WA_INACTIVE) and Assigned(PopupParent)) then
    SendMessage(PopupParent.Handle, WM_NCACTIVATE, WPARAM(TRUE), 0);

  inherited;

  if (Msg.Active = WA_INACTIVE) then
    Hide();
end;

end.


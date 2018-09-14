unit uPDBGridFilter;

interface

uses
  Messages,
  Classes,
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
    procedure FActiveKeyPress(Sender: TObject; var Key: Char);
    procedure FActiveClick(Sender: TObject);
  type
    TOnHideEvent = procedure(Sender: TObject) of object;
    TOnShowEvent = procedure(Sender: TObject) of object;
  private
    FOnHide: TOnHideEvent;
    FOnShow: TOnShowEvent;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure WMActivate(var Msg: TWMActivate); message WM_ACTIVATE;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    Column: TColumn;
    Actives: array of Boolean;
    Operators: array of string;
    Values: array of string;
    property OnHide: TOnHideEvent read FOnHide write FOnHide;
    property OnShow: TOnShowEvent read FOnShow write FOnShow;
  end;

var
  PDBGridFilter: TPDBGridFilter;

implementation

{$R *.dfm}

uses
  Windows,
  MySQLDB;

{ TPDBGridFilter **************************************************************}

procedure TPDBGridFilter.CMShowingChanged(var Message: TMessage);
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

procedure TPDBGridFilter.FActiveClick(Sender: TObject);
begin
  if (FActive.Checked) then
    Close();
end;

procedure TPDBGridFilter.FActiveKeyPress(Sender: TObject; var Key: Char);
begin
  FActiveClick(Sender);
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
  SetLength(Actives, 1);
  Actives[0] := FActive.Checked;
  SetLength(Operators, 1);
  Operators[0] := FOperator.Text;
  SetLength(Values, 1);
  if (FText.Visible) then
    Values[0] := FText.Text
  else if (FNull.Visible) then
    Values[0] := FNull.Text
  else
    Values[0] := '';

  if (Assigned(FOnHide)) then
    FOnHide(Self);

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
  FOperator.Items.Add('>=');
  FOperator.Items.Add('<');
  FOperator.Items.Add('<=');
  if (Column.Field.DataType in TextDataTypes) then
  begin
    FOperator.Items.Add('LIKE');
    FOperator.Items.Add('NOT LIKE');
  end;
  if (not Column.Field.Required) then
    FOperator.Items.Add('IS');
  FOperator.Items.EndUpdate();
  FOperator.ItemIndex := 0;

  if (Assigned(FOnShow)) then
    FOnShow(Self);

  FActive.Checked := (Length(Actives) >= 1) and Actives[0];
  if (Length(Operators) = 0) then
    FOperator.ItemIndex := 0
  else
    FOperator.Text := Operators[0];
  if (Length(Values) = 0) then
    FText.Text := ''
  else
    FText.Text := Values[0];
  if ((Length(Values) = 0) or (Values[0] <> 'NOT NULL')) then
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


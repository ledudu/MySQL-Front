unit ComCtrls_Ext;

interface {********************************************************************}

uses
  Windows, Messages, CommCtrl,
  SysUtils, Classes,
  Controls, ComCtrls;

type
  TLVColumnResizeEvent = procedure(Sender: TObject; Column: TListColumn) of object;
  TListView_Ext = class(TListView)
  private
    FOnColumnResize: TLVColumnResizeEvent;
    procedure WMNotify(var Message: TWMNotify); message WM_NOTIFY;
  public
    constructor Create(AOwner: TComponent); override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
  published
    property OnColumnResize: TLVColumnResizeEvent read FOnColumnResize write FOnColumnResize;
  end;

type
  TTreeView_Ext = class(TTreeView)
  private
    ShiftDownSelected: TTreeNode;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  end;

procedure Register();

implementation {***************************************************************}

uses
  Types, Math,
  StdActns, StdCtrls;

procedure Register();
begin
  RegisterComponents('VCL Extensions', [TListView_Ext]);
  RegisterComponents('VCL Extensions', [TTreeView_Ext]);
end;

{ TListView_Ext ***************************************************************}

constructor TListView_Ext.Create(AOwner: TComponent);
begin
  inherited;

  FOnColumnResize := nil;
end;

function TListView_Ext.ExecuteAction(Action: TBasicAction): Boolean;
begin
  if (Action is TEditSelectAll) then
    begin SelectAll(); Result := True; end
  else
    Result := inherited ExecuteAction(Action);
end;

procedure TListView_Ext.WMNotify(var Message: TWMNotify);
begin
  inherited;

  with PHDNotify(Message.NMHdr)^ do
    case (Hdr.Code) of
      HDN_ITEMCHANGED:
        if (((PItem^.mask and HDI_WIDTH) <> 0) and Assigned(FOnColumnResize)) then
          FOnColumnResize(Self, Columns[PHDNotify(Message.NMHdr)^.Item]);
    end;
end;

function TListView_Ext.UpdateAction(Action: TBasicAction): Boolean;
begin
  if (Action is TEditSelectAll) then
  begin
    Result := Focused;
    if (Result) then
      TEditSelectAll(Action).Enabled := Items.Count > 0;
  end
  else
    Result := inherited UpdateAction(Action);
end;

{ TTreeView_Ext ***************************************************************}

procedure TTreeView_Ext.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_SHIFT) then
    ShiftDownSelected := Selected;

  inherited;
end;

procedure TTreeView_Ext.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if (Key = VK_SHIFT) then
    ShiftDownSelected := nil;
end;

procedure TTreeView_Ext.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Child: TTreeNode;
  Node: TTreeNode;
  NodeIndex: Integer;
  OldSelectedIndex: Integer;
begin
  if (not Assigned(Parent)) then
    Node := nil
  else
    Node := GetNodeAt(X, Y);

  inherited;

  if (MultiSelect and Assigned(Node) and Assigned(ShiftDownSelected) and (ShiftDownSelected.Parent = Node.Parent) and (Shift = [ssShift, ssLeft])) then
  begin
    OldSelectedIndex := ShiftDownSelected.Parent.IndexOf(ShiftDownSelected);
    NodeIndex := Node.Parent.IndexOf(Node);

    Child := Node.Parent.getFirstChild();
    while (Assigned(Child)) do
    begin
      // Debug 2017-01-03
      if (not Assigned(Child.Parent)) then
        raise ERangeError.Create('ImageIndex: ' + IntToStr(Child.ImageIndex) + #13#10
          + 'Text: ' + Child.Text + #13#10
          + 'Name: ' + Name);

      if ((Child.Parent.IndexOf(Child) in [Min(OldSelectedIndex, NodeIndex) .. Max(OldSelectedIndex, NodeIndex)]) and not Child.Selected) then
        Select(Child, [ssCtrl]);
      Child := Node.Parent.GetNextChild(Child);
    end;
  end;
end;

end.

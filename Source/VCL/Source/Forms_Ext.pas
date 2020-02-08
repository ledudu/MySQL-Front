unit Forms_Ext;

interface {********************************************************************}

uses
  Windows, Messages,
  SysUtils, Classes, Controls, Graphics, Forms;

type
  TForm_Ext = class(TForm)
  private
    FShowGripper: Boolean;
    MouseDownPoint: TPoint;
    MouseDownSize: TPoint;
    MouseMovePoint: TPoint;
    MouseMoveTime: TDateTime;
    procedure CMSysFontChanged(var Message: TMessage); message CM_SYSFONTCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
    procedure WMUpdateUIState(var Message: TWMUpdateUIState); message WM_UPDATEUISTATE;
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint(); override;
  public
    procedure ApplyWinAPIUpdates(const Control: TWinControl); virtual;
    constructor Create(AOwner: TComponent); override;
  published
    property ShowGripper: Boolean read FShowGripper write FShowGripper default True;
  end;

function IsWine(): Boolean;
procedure Register();

implementation {***************************************************************}

uses
  CommCtrl, Consts, Themes, UxTheme, Buttons, SysConst, Types,
  ComCtrls, ExtCtrls, Grids, StdCtrls;

const tiMouseMove = 1;

var
  Wine: Boolean;

function IsWine(): Boolean;
begin
  Result := Wine;
end;

procedure Register();
begin
  RegisterComponents('VCL Extensions', [TForm_Ext]);
end;

{ TForm_Ext *******************************************************************}

procedure TForm_Ext.ApplyWinAPIUpdates(const Control: TWinControl);
var
  I: Integer;
begin
  for I := 0 to Control.ControlCount - 1 do
    if (Control.Controls[I] is TWinControl) then
      ApplyWinAPIUpdates(TWinControl(Control.Controls[I]));

  if (Control is TListView) then
  begin
    if (CheckWin32Version(6,1)) then
      SendMessage(Control.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_JUSTIFYCOLUMNS, 0);
    SendMessage(Control.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_DOUBLEBUFFER, LVS_EX_DOUBLEBUFFER);
    SendMessage(Control.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_COLUMNSNAPPOINTS, LVS_EX_COLUMNSNAPPOINTS);
  end
  else if (Control is TStatusBar) then
  begin
    TStatusBar(Control).ClientHeight := TStatusBar(Control).Canvas.TextHeight('I') + 5;
  end
  else if (Control is TTabControl) then
  begin
    TTabControl(Control).TabHeight := TTabControl(Control).Canvas.TextHeight('I') + 10;
    if (not StyleServices.Enabled) then
      TTabControl(Control).Height := TTabControl(Control).TabHeight + 1
    else
      TTabControl(Control).Height := TTabControl(Control).TabHeight + 2;
  end
  else if (Control is TToolBar) then
  begin
    if (CheckWin32Version(6)) then
      for I := 0 to TToolBar(Control).ButtonCount - 1 do
        if (TToolBar(Control).Buttons[I].Style = tbsSeparator) then
        begin
          TToolBar(Control).Buttons[I].AutoSize := True;
          TToolBar(Control).Buttons[I].Enabled := False;
          TToolBar(Control).Buttons[I].Style := tbsButton;
        end;
  end
  else if (Control is TTreeView) then
  begin
    SendMessage(Control.Handle, TVM_SETITEMHEIGHT, GetSystemMetrics(SM_CYSMICON) + GetSystemMetrics(SM_CXEDGE), 0);
    if (CheckWin32Version(6)) then
    begin
      TTreeView(Control).Indent := GetSystemMetrics(SM_CXSMICON) div 2 + GetSystemMetrics(SM_CXEDGE);
      SetWindowLong(Control.Handle, GWL_STYLE, GetWindowLong(Control.Handle, GWL_STYLE) or TVS_NOHSCROLL);
      SendMessage(Control.Handle, TVM_SETEXTENDEDSTYLE, TVS_EX_AUTOHSCROLL or TVS_EX_FADEINOUTEXPANDOS or TVS_EX_DOUBLEBUFFER, TVS_EX_AUTOHSCROLL or TVS_EX_FADEINOUTEXPANDOS or TVS_EX_DOUBLEBUFFER);
    end;
  end
  else if (Control is TUpDown) then
  begin
    if (Assigned(TUpDown(Control).Associate) and (TUpDown(Control).Associate is TEdit)) then
    begin
      TUpDown(Control).Height := TEdit(TUpDown(Control).Associate).Height;
      SetWindowLong(TEdit(TUpDown(Control).Associate).Handle, GWL_STYLE, GetWindowLong(TEdit(TUpDown(Control).Associate).Handle, GWL_STYLE) or ES_NUMBER or ES_RIGHT);
    end;
  end;
end;

procedure TForm_Ext.CMSysFontChanged(var Message: TMessage);
var
  NonClientMetrics: TNonClientMetrics;
begin
  inherited;

  NonClientMetrics.cbSize := SizeOf(NonClientMetrics);
  if (SystemParametersInfo(SPI_GETNONCLIENTMETRICS, SizeOf(NonClientMetrics), @NonClientMetrics, 0)) then
    Font.Handle := CreateFontIndirect(NonClientMetrics.lfMessageFont);

  if ((BorderStyle = bsSizeable) and (MouseDownPoint.X >= 0)) then
  begin
    ReleaseCapture();
    MouseDownPoint := Point(-1, -1);
  end;
end;

constructor TForm_Ext.Create(AOwner: TComponent);
begin
  inherited;

  DoubleBuffered := True;
  MouseDownPoint := Point(-1, -1);
  FShowGripper := True;

  ApplyWinAPIUpdates(Self);
end;

procedure TForm_Ext.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;

  PostMessage(Handle, CM_SYSFONTCHANGED, 0, 0);
end;

procedure TForm_Ext.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ((Button = mbLeft) and (BorderStyle = bsSizeable) and (X >= ClientWidth - GetSystemMetrics(SM_CXVSCROLL)) and (Y >= ClientHeight - GetSystemMetrics(SM_CYHSCROLL))) then
  begin
    MouseDownPoint := Point(X, Y);
    MouseDownSize := Point(Width, Height);
    MouseMoveTime := 0;
    SetCapture(Handle);
  end
  else
    inherited;
end;

procedure TForm_Ext.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Hour: Word;
  Msg: TMsg;
  Min: Word;
  MSec: Word;
  Sec: Word;
begin
  if (PeekMessage(Msg, Handle, WM_MOUSEMOVE, WM_MOUSEMOVE, PM_NOREMOVE) and (Msg.Message = WM_MOUSEMOVE) and (Msg.hwnd = Handle) and (KeysToShiftState(Msg.wParam) = Shift)) then
    // Handle this Message within the next equal message
  else if ((BorderStyle = bsSizeable) and (MouseDownPoint.X < 0)) then
  begin
    if (PtInRect(Rect(ClientWidth - GetSystemMetrics(SM_CXVSCROLL), ClientHeight - GetSystemMetrics(SM_CYHSCROLL), ClientWidth, ClientHeight), Point(X, Y)) and not Assigned(ControlAtPos(Point(X, Y), True, True))) then
    begin
      Cursor := crSizeNWSE;
      SetCapture(Handle);
    end
    else
    begin
      Cursor := crDefault;
      ReleaseCapture();
    end
  end
  else if (MouseDownPoint.X >= 0) then
  begin
    if (Now() - MouseMoveTime > EncodeTime(0, 0, 0, 5)) then
    begin
      SetWindowPos(Handle, 0, 0, 0,
        Width + (X - MouseDownPoint.X),
        Height + (Y - MouseDownPoint.Y),
        SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOOWNERZORDER);
      MouseMoveTime := Now();
    end
    else
    begin
      MouseMovePoint := Point(X, Y);
      DecodeTime((Now() - MouseMoveTime) + EncodeTime(0, 0, 0, 5), Hour, Min, Sec, MSec);
      SetTimer(Handle, tiMouseMove, MSec, nil);
    end;
  end
  else
    inherited;
end;

procedure TForm_Ext.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ((Button = mbLeft) and (MouseDownPoint.X >= 0)) then
  begin
    ReleaseCapture();
    MouseDownPoint := Point(-1, -1);
    MouseMoveTime := 0;
    KillTimer(Handle, tiMouseMove);
  end
  else
    inherited;
end;

procedure TForm_Ext.Paint();
begin
  if ((BorderStyle = bsSizeable) and ShowGripper) then
    if (not StyleServices.Enabled) then
      DrawFrameControl(Canvas.Handle, Rect(ClientWidth - GetSystemMetrics(SM_CXVSCROLL), ClientHeight - GetSystemMetrics(SM_CYHSCROLL), ClientWidth, ClientHeight), DFC_SCROLL, DFCS_SCROLLSIZEGRIP)
    else
      StyleServices.DrawElement(Canvas.Handle, StyleServices.GetElementDetails(tsGripper), Rect(ClientWidth - GetSystemMetrics(SM_CXVSCROLL) + 1, ClientHeight - GetSystemMetrics(SM_CYHSCROLL), ClientWidth, ClientHeight));

  inherited;
end;

procedure TForm_Ext.WMSize(var Message: TWMSize);
begin
  if (MouseDownPoint.X >= 0) then
  begin
    Inc(MouseDownPoint.X, Width - MouseDownSize.X);
    Inc(MouseDownPoint.Y, Height - MouseDownSize.Y);
    MouseDownSize := Point(Width, Height);
  end;

  Invalidate();

  inherited;
end;

procedure TForm_Ext.WMTimer(var Message: TWMTimer);
begin
  case (Message.TimerID) of
    tiMouseMove:
      begin
        MouseMove([], MouseMovePoint.X, MouseMovePoint.Y);
        MouseMoveTime := 0;
      end;
  end;
end;

procedure TForm_Ext.WMUpdateUIState(var Message: TWMUpdateUIState);

  procedure InvalidateControls(Control: TControl);
  var
    I: Integer;
  begin
    if (Control is TButtonControl) or (Control is TCustomStaticText) then
      TWinControl(Control).Invalidate()
    else if (Control is TWinControl) then
      for I := 0 to TWinControl(Control).ControlCount - 1 do
      begin
        // only paint controls on active tabsheet of page control
        if (Control is TTabSheet) and
            (TTabSheet(Control).PageIndex <> TTabSheet(Control).PageControl.ActivePageIndex) then
          continue;
        InvalidateControls(TWinControl(Control).Controls[I]);
      end;
  end;

begin
  inherited;

  if ((Message.Action = UIS_CLEAR) and (Message.Flags = UISF_HIDEACCEL)) then
    InvalidateControls(Self);
end;

{******************************************************************************}

var
  Handle: THandle;
begin
  Handle := LoadLibrary(PChar('Kernel32.dll'));
  if (Handle = 0) then
    Wine := False
  else
  begin
    Wine := Assigned(GetProcAddress(Handle, 'wine_get_unix_file_name'));
    FreeLibrary(Handle);
  end;
end.


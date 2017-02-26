unit uProfiling;

interface {********************************************************************}

uses
  SyncObjs;

type
  TProfile = record
    CriticalSection: TCriticalSection;
    DisableFreezeDetection: Boolean;
    LastCount: Int64;
    Points: array of record
      Disabled: Integer;
      Sum: Int64;
    end;
    Start: Int64;
  end;

procedure CloseProfile(var Profile: TProfile);
procedure CreateProfile(out Profile: TProfile; const DisableFreezeDetection: Boolean = True);
procedure ProfilingDisablePoint(var Profile: TProfile; const Index: Integer); overload;
procedure ProfilingEnablePoint(var Profile: TProfile; const Index: Integer); overload;
procedure ProfilingPoint(var Profile: TProfile; const Index: Integer); overload;
function ProfilingReport(var Profile: TProfile; const Filename: string = ''): string; overload;
procedure ProfilingReset(var Profile: TProfile); overload;
function ProfilingTime(const Profile: TProfile): Int64; overload;

implementation {***************************************************************}

uses
  Windows, SysUtils
  {$IFDEF EurekaLog}
  , EFreeze
  {$ENDIF};

var
  FormatSettings: TFormatSettings;
  Frequency: Int64;
  Profile: TProfile;

procedure CloseProfile(var Profile: TProfile);
begin
  {$IFDEF EurekaLog}
  if (Profile.DisableFreezeDetection) then
    ResumeFreezeCheck();
  {$ENDIF}

  SetLength(Profile.Points, 0);
  Profile.CriticalSection.Free();
end;

procedure CreateProfile(out Profile: TProfile; const DisableFreezeDetection: Boolean = True);
begin
  Profile.CriticalSection := TCriticalSection.Create();
  Assert(Assigned(Profile.CriticalSection));

  Profile.DisableFreezeDetection := DisableFreezeDetection;
  SetLength(Profile.Points, 0);
  ProfilingReset(Profile);

  {$IFDEF EurekaLog}
  if (Profile.DisableFreezeDetection) then
    PauseFreezeCheck();
  {$ENDIF}
end;

procedure ProfilingDisablePoint(var Profile: TProfile; const Index: Integer);
begin
  Profile.CriticalSection.Enter();
  Inc(Profile.Points[Index].Disabled);
  Profile.CriticalSection.Leave();
end;

procedure ProfilingEnablePoint(var Profile: TProfile; const Index: Integer);
begin
  Profile.CriticalSection.Enter();
  Dec(Profile.Points[Index].Disabled);
  Profile.CriticalSection.Leave();
end;

procedure ProfilingPoint(var Profile: TProfile; const Index: Integer);
var
  Count: Int64;
begin
  Profile.CriticalSection.Enter();

  while (Index >= Length(Profile.Points)) do
  begin
    SetLength(Profile.Points, Length(Profile.Points) + 1);
    Profile.Points[Length(Profile.Points) - 1].Disabled := 0;
    Profile.Points[Length(Profile.Points) - 1].Sum := 0;
  end;

  if (Profile.Points[Index].Disabled = 0) then
  begin
    if (not QueryPerformanceCounter(Count)) then Count := 0;
    Inc(Profile.Points[Index].Sum, Count - Profile.LastCount);
    Profile.LastCount := Count;
  end;

  Profile.CriticalSection.Leave();
end;

function ProfilingReport(var Profile: TProfile; const Filename: string = ''): string;
const
  BOM: PAnsiChar = #$FF + #$FE;
var
  BytesWritten: DWord;
  Frequency: Int64;
  Index: Integer;
  Handle: THandle;
  Sum: Int64;
begin
  Profile.CriticalSection.Enter();

  Index := Length(Profile.Points);

  ProfilingPoint(Profile, Index);

  Result := '';

  if (not QueryPerformanceFrequency(Frequency)) then
    Result := 'QueryPerformanceFrequency failed'
  else
  begin
    Sum := 0;
    for Index := 1 to Length(Profile.Points) - 1 do
      Inc(Sum, Profile.Points[Index].Sum);

    for Index := 1 to Length(Profile.Points) - 1 do
      Result := Result + Format('%2d:  %7s %s  %3d %s' + #13#10, [Index, FormatFloat('#,##0.000', Profile.Points[Index].Sum * 1000 div Frequency / 1000, FormatSettings), 's', Profile.Points[Index].Sum * 100 div Sum, '%']);

    Result := Result + Format('----------------------' + #13#10, []);
    Result := Result + Format('     %7s %s  %3d %s' + #13#10, [FormatFloat('#,##0.000', Sum * 1000 div Frequency / 1000, FormatSettings), 's', 100, '%']);

    if (Filename <> '') then
    begin
      Handle := CreateFile(PChar(Filename),
                           GENERIC_WRITE,
                           FILE_SHARE_READ,
                           nil,
                           CREATE_ALWAYS, 0, 0);
      if (Handle = INVALID_HANDLE_VALUE) then
        RaiseLastOSError()
      else
      begin
        WriteFile(Handle, BOM^, Length(BOM), BytesWritten, nil);
        WriteFile(Handle, Result[1], Length(Result) * SizeOf(Result[1]), BytesWritten, nil);
        CloseHandle(Handle);
      end;
    end;
  end;

  Profile.CriticalSection.Leave();
end;

procedure ProfilingReset(var Profile: TProfile);
begin
  Profile.CriticalSection.Enter();

  SetLength(Profile.Points, 1);
  Profile.Points[0].Disabled := 0;
  Profile.Points[0].Sum := 0;

  if (not QueryPerformanceCounter(Profile.LastCount)) then Profile.LastCount := 0;
  Profile.Start := Profile.LastCount;

  Profile.CriticalSection.Leave();
end;

function ProfilingTime(const Profile: TProfile): Int64;
var
  Finish: Int64;
begin
  if (not QueryPerformanceCounter(Finish)) then Finish := 0;
  if ((Profile.Start = 0) or (Finish = 0) or (Frequency = 0)) then
    Result := 0
  else
    Result := (Finish - Profile.Start) * 1000 div Frequency;
end;

initialization
  FormatSettings := TFormatSettings.Create(LOCALE_USER_DEFAULT);
  if (not QueryPerformanceFrequency(Frequency)) then Frequency := 0;
  CreateProfile(Profile, False);
finalization
  CloseProfile(Profile);
end.

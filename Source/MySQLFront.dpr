program MySQLFront;

uses
  {$IFDEF EurekaLog}
  EMemLeaks,
  EResLeaks,
  EDialogWinAPIMSClassic,
  EMapWin32,
  EAppVCL,
  ExceptionLog7,
  {$ELSE}
  {$IFDEF Debug}
  FastMM4,
  {$ENDIF}
  {$ENDIF}
  Windows,
  ShellAPI,
  SysUtils,
  Forms,
  HTMLHelpViewer,
  MySQLClient in 'MySQL\Source\MySQLClient.pas',
  MySQLConsts in 'MySQL\Source\MySQLConsts.pas',
  SQLParser in 'MySQL\Source\SQLParser.pas',
  MySQLDB in 'MySQL\Source\MySQLDB.pas',
  HTTPTunnel in 'MySQL\Source\HTTPTunnel.pas',
  SQLUtils in 'MySQL\Source\SQLUtils.pas',
  CSVUtils in 'MySQL\Source\CSVUtils.pas',
  MySQLDBGrid in 'MySQL\Source\MySQLDBGrid.pas',
  ExtCtrls_Ext in 'VCL\Source\ExtCtrls_Ext.pas',
  StdCtrls_Ext in 'VCL\Source\StdCtrls_Ext.pas',
  StdActns_Ext in 'VCL\Source\StdActns_Ext.pas',
  Dialogs_Ext in 'VCL\Source\Dialogs_Ext.pas',
  ComCtrls_Ext in 'VCL\Source\ComCtrls_Ext.pas',
  Forms_Ext in 'VCL\Source\Forms_Ext.pas',
  uDeveloper in 'uDeveloper.pas',
  uPreferences in 'uPreferences.pas',
  uSession in 'uSession.pas',
  uTools in 'uTools.pas',
  uURI in 'uURI.pas',
  uBase in 'uBase.pas',
  uDAccount in 'uDAccount.pas' {DAccount},
  uDAccounts in 'uDAccounts.pas' {DAccounts},
  uDConnecting in 'uDConnecting.pas' {DConnecting},
  uDDatabase in 'uDDatabase.pas' {DDatabase},
  uDDatabases in 'uDDatabases.pas' {DDatabases},
  udDowndate in 'udDowndate.pas' {DDowndate},
  uDEvent in 'uDEvent.pas' {DEvent},
  uDExecutingSQL in 'uDExecutingSQL.pas' {DExecutingSQL},
  uDExport in 'uDExport.pas' {DExport},
  uDField in 'uDField.pas' {DField},
  uDForeignKey in 'uDForeignKey.pas' {DForeignKey},
  uDImport in 'uDImport.pas' {DImport},
  uDInfo in 'uDInfo.pas' {DInfo},
  uDKey in 'uDKey.pas' {DIndex},
  uDLanguage in 'uDLanguage.pas' {DLanguage},
  uDLogin in 'uDLogin.pas' {DDBLogin},
  uDMail in 'uDMail.pas' {DMail},
  uDODBC in 'uDODBC.pas' {DDBODBC},
  uDOptions in 'uDOptions.pas' {DOptions},
  uDPartition in 'uDPartition.pas' {DPartition},
  uDPaste in 'uDPaste.pas' {DPaste},
  uDQuickFilter in 'uDQuickFilter.pas' {DQuickFilter},
  uDRoutine in 'uDRoutine.pas' {DRoutine},
  uDSearch in 'uDSearch.pas' {DSearch},
  uDSegment in 'uDSegment.pas' {DSegment},
  uDSelection in 'uDSelection.pas' {DSelection},
  uDServer in 'uDServer.pas' {DServer},
  uDStatement in 'uDStatement.pas' {DStatement},
  uDTable in 'uDTable.pas' {DTable},
  uDTables in 'uDTables.pas' {DTables},
  uDTransfer in 'uDTransfer.pas' {DTransfer},
  uDTrigger in 'uDTrigger.pas' {DTrigger},
  uDUpdate in 'uDUpdate.pas' {DUpdate},
  uDUser in 'uDUser.pas' {DUser},
  uDUserRight in 'uDUserRight.pas' {DUserRight},
  uDVariable in 'uDVariable.pas' {DVariable},
  uDView in 'uDView.pas' {DView},
  uCWorkbench in 'uCWorkbench.pas',
  uFSession in 'uFSession.pas' {FSession},
  uPDBGridFilter in 'uPDBGridFilter.pas' {PDBGridFilter},
  uPObjectSearch in 'uPObjectSearch.pas' {PObjectSearch},
  uWSQLHelp in 'uWSQLHelp.pas' {WSQLHelp},
  uWWindow in 'uWWindow.pas' {WWindow};

{$R *.res}

var
  ExecError: DWORD;
  ExecInfo: TShellExecuteInfo;
  SetupProgram: TFileName;
  SetupProgramExecute: Boolean;
begin
  Preferences := TPPreferences.Create();

  if (Preferences.SetupProgramInstalled) then
  begin
    if (FileExists(PChar(Preferences.SetupProgram))) then
      DeleteFile(PChar(Preferences.SetupProgram));
    Preferences.SetupProgram := '';
    Preferences.SetupProgramInstalled := False;
  end
  else if (Preferences.SetupProgram <> '') then
  begin
    Preferences.SetupProgramExecute := FindWindow(cWindowClassName, nil) = 0;
    if (not Preferences.SetupProgramExecute) then
      MsgBox(Preferences.LoadStr(908, LoadStr(1000)), Preferences.LoadStr(45), MB_OK + MB_ICONERROR)
  end;

  SetupProgramExecute := Preferences.SetupProgramExecute;
  if (not SetupProgramExecute) then
  begin
    Application.Initialize();
    Application.Title := LoadStr(1000);
    Application.CreateForm(TWWindow, WWindow);
    Application.MainForm.Perform(UM_CHANGEPREFERENCES, 0, 0);
    Application.Run();
    if (Application.Handle <> 0) then
      ShowOwnedPopups(Application.Handle, False);
    Application.ShowHint := False;
    Application.Destroying();
    Application.DestroyComponents();

    SetupProgramExecute := Preferences.SetupProgramExecute;
  end;

  SetupProgram := Preferences.SetupProgram;
  Preferences.Free(); Preferences := nil;

  if (SetupProgramExecute) then
  begin
    FillChar(ExecInfo, SizeOf(ExecInfo), 0);
    ExecInfo.cbSize := SizeOf(ExecInfo);
    ExecInfo.fMask := SEE_MASK_DEFAULT;
    ExecInfo.lpVerb := 'open';
    ExecInfo.lpFile := PChar(SetupProgram);
    ExecInfo.lpParameters := '/SILENT /NOICONS /TASKS=""';
    ExecInfo.nShow := SW_SHOWNORMAL;
    if (not ShellExecuteEx(@ExecInfo)) then
    begin
      ExecError := GetLastError();

      Preferences := TPPreferences.Create();
      Preferences.SetupProgram := '';
      Preferences.SetupProgramInstalled := False;
      Preferences.Free(); Preferences := nil;
      Windows.DeleteFile(PChar(SetupProgram));

      RaiseLastOSError(ExecError);
    end;
  end;
end.

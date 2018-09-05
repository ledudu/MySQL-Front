@ECHO OFF


REM ****************************************************************************


SET CleanRootPath=%CD%
SET CleanImagesPath=%CleanRootPath%\Images
SET CleanImagesPureFlatPath=%CleanImagesPath%\PureFlat
SET CleanSourcePath=%CleanRootPath%\Source
SET ClearSourceSynEditPath=%CleanSourcePath%\SynEdit
SET ClearSourceBCHexEditorPath=%CleanSourcePath%\BCHexEditor
SET ClearSourceFastMMPath=%CleanSourcePath%\FastMM
SET ClearSourceMySQLPath=%CleanSourcePath%\MySQL
SET ClearSourceQueryBuilderPath=%CleanSourcePath%\QueryBuilder
SET ClearSourceShellBrowserPath=%CleanSourcePath%\ShellBrowser
SET ClearSourceSynopsePDFPath=%CleanSourcePath%\SynopsePDF
SET ClearSourceVCLPath=%CleanSourcePath%\VCL
SET ClearSourceWin32Path=%CleanSourcePath%\Win32
SET CleanPublishPath=%CleanRootPath%\Publish
SET CleanTempPath=%CleanRootPath%\Temp


REM ****************************************************************************


CD "%CleanRootPath%"

if exist "%CleanPublishPath%" RMDIR /S /Q "%CleanPublishPath%"
if exist "%CleanTempPath%" RMDIR /S /Q "%CleanTempPath%"

if not exist "%CleanImagesPureFlatPath%" MKDIR "%CleanImagesPureFlatPath%"
if not exist "%ClearSourceFastMMPath%\Bin" MKDIR "%ClearSourceFastMMPath%\Bin"
if not exist "%ClearSourceMySQLPath%\Source" MKDIR "%ClearSourceMySQLPath%\Source"
if not exist "%ClearSourceSynEditPath%\Source" MKDIR "%ClearSourceSynEditPath%\Source"
if not exist "%ClearSourceSynEditPath%\Bin" MKDIR "%ClearSourceSynEditPath%\Bin"
if not exist "%ClearSourceBCHexEditorPath%\Source" MKDIR "%ClearSourceBCHexEditorPath%\Source"
if not exist "%ClearSourceBCHexEditorPath%\Resource" MKDIR "%ClearSourceBCHexEditorPath%\Resource"
if not exist "%ClearSourceBCHexEditorPath%\Bin" MKDIR "%ClearSourceBCHexEditorPath%\Bin2"
if not exist "%ClearSourceQueryBuilderPath%\Source" MKDIR "%ClearSourceQueryBuilderPath%\Source"
if not exist "%ClearSourceQueryBuilderPath%\Resource" MKDIR "%ClearSourceQueryBuilderPath%\Resource"
if not exist "%ClearSourceQueryBuilderPath%\Bin" MKDIR "%ClearSourceQueryBuilderPath%\Bin"
if not exist "%ClearSourceShellBrowserPath%\Source" MKDIR "%ClearSourceShellBrowserPath%\Source"
if not exist "%ClearSourceShellBrowserPath%\Resource" MKDIR "%ClearSourceShellBrowserPath%\Resource"
if not exist "%ClearSourceShellBrowserPath%\Bin" MKDIR "%ClearSourceShellBrowserPath%\Bin"
if not exist "%ClearSourceSynopsePDFPath%\Source" MKDIR "%ClearSourceSynopsePDFPath%\Source"
if not exist "%ClearSourceSynopsePDFPath%\Resource" MKDIR "%ClearSourceSynopsePDFPath%\Resource"
if not exist "%ClearSourceSynopsePDFPath%\Bin" MKDIR "%ClearSourceSynopsePDFPath%\Bin"
if not exist "%ClearSourceVCLPath%\Source" MKDIR "%ClearSourceVCLPath%\Source"
if not exist "%ClearSourceWin32Path%\Source" MKDIR "%ClearSourceWin32Path%\Source"

MKDIR "%CleanTempPath%"
if exist "%CleanSourcePath%\FastMM\FastMM_FullDebugMode.dll" COPY "%CleanSourcePath%\FastMM\FastMM_FullDebugMode.dll" "%CleanTempPath%" > nul

for /D /R %%I in (*) do (
  if exist "%%I\__history" RMDIR /S /Q %%I\__history"
  if exist "%%I\*.~dsk" DEL "%%I\*.~dsk"
  if exist "%%I\*.drc" DEL %%I\*.drc"
  if exist "%%I\*.dproj.local" DEL %%I\*.dproj.local"
  if exist "%%I\*.identcache" DEL "%%I\*.identcache"
  if exist "%%I\*.tvsconfig" DEL "%%I\*.tvsconfig"
  if exist "%%I\*.vlb" DEL %%I\*.vlb"
)

CHOICE /M "Clean built packages"
if Errorlevel 2 goto End
if Errorlevel 1 goto CleanAll
goto End

:CleanAll
for /D /R %%I in (*) do (
  if exist "%%I\Bin\*" DEL /Q "%%I\Bin\*"
)

:End

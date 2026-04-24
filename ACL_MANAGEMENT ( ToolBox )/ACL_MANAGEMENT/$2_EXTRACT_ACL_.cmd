@ECHO OFF

CLS

CD /D "%~dp0"

:Start

	ECHO.
	ECHO ### INIT ### %0 ### %DATE% %TIME% ###
	ECHO.

	REM PRIMARY PARAMETERS FROM INIT SCRIPT :
	REM ACL_PARAM_PVWA_URL
	REM ACL_PARAM_VAULT_CONTEXT
	REM ACL_PARAM_MATRIX_CONTEXT
	REM ACL_PARAM_TOKEN
	REM ACL_PARAM_POWER_SHELL_PATH
	ECHO ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SET ACL_PARAM_
	ECHO ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	ECHO.

IF NOT DEFINED ACL_PARAM_PVWA_URL GOTO ERROR_EXTRACT_CMD_PARAMETERS
IF NOT DEFINED ACL_PARAM_VAULT_CONTEXT GOTO ERROR_EXTRACT_CMD_PARAMETERS
IF NOT DEFINED ACL_PARAM_MATRIX_CONTEXT GOTO ERROR_EXTRACT_CMD_PARAMETERS
IF NOT DEFINED ACL_PARAM_TOKEN GOTO ERROR_EXTRACT_CMD_PARAMETERS
IF NOT DEFINED ACL_PARAM_POWER_SHELL_PATH GOTO ERROR_EXTRACT_CMD_PARAMETERS
IF NOT EXIST "sql\CONVERT_1_ACL_OUTPUT_to_ACL_SmartString.sql" GOTO ERROR_EXTRACT_DEDICATED_SCRIPT
IF NOT EXIST "sql\CONVERT_2_[_%ACL_PARAM_MATRIX_CONTEXT%_]_ACL_SmartString_to_ACL_Role.sql" GOTO ERROR_EXTRACT_DEDICATED_SCRIPT

IF /I "%~1" == "-CONVERT-ONLY" GOTO Convert_only_current_Owners_List_as_Role_Matrix

	SET ACL_PARAM_temp_debug_parameters_for_power_shell=
	IF DEFINED DEBUG SET ACL_PARAM_temp_debug_parameters_for_power_shell=-IncludeCallStack -UseVerboseFile
	SET /A ACL_PARAM_temp_multithreading_limit=20

	SET ACL_PARAM_temp_safe_filter=%~1
	IF NOT DEFINED ACL_PARAM_temp_safe_filter SET /P ACL_PARAM_temp_safe_filter=(+) Enter Safe Filter with FINDSTR /R syntax ( optional ) : 
	IF NOT DEFINED ACL_PARAM_temp_safe_filter SET ACL_PARAM_temp_safe_filter=###_N/A_###
	ECHO *** ACL_PARAM_temp_safe_filter=%ACL_PARAM_temp_safe_filter% ***

	IF EXIST ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_EXTRACT_SAFES_LIST_.csv" DEL ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_EXTRACT_SAFES_LIST_.csv"
	IF EXIST ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log" DEL ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log"
	CALL "%ACL_PARAM_POWER_SHELL_PATH%" ".\bin\Safe-Management-CUSTOM.ps1" -PVWAURL "%ACL_PARAM_PVWA_URL%" -AuthType cyberark -DisableSSLVerify -AllowInsecureURL -logonToken "%ACL_PARAM_TOKEN%" -concurrentSession -VaultContext "%ACL_PARAM_VAULT_CONTEXT%" -Report -IncludeSystemSafes -ReportPath ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_EXTRACT_SAFES_LIST_.csv" %ACL_PARAM_temp_debug_parameters_for_power_shell%

	IF EXIST ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_EXTRACT_OWNERS_LIST_.csv" DEL ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_EXTRACT_OWNERS_LIST_.csv"
	IF EXIST ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_*_+.cmd" DEL ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_*_+.cmd"
	IF EXIST ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_*_+.csv" DEL ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_*_+.csv"
	IF "%ACL_PARAM_temp_safe_filter%" == "###_N/A_###" FOR /F "tokens=1,* delims=," %%i IN ('TYPE ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_EXTRACT_SAFES_LIST_.csv" ^| SORT ^| FINDSTR /V /R /C:"^.safeName.,.managingCPM." 2^> NUL') DO CALL :Collect_Safe_Owners_For_One_Safe "%%~i" ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_%%~i_+.csv"
	IF NOT "%ACL_PARAM_temp_safe_filter%" == "###_N/A_###" FOR /F "tokens=1,* delims=," %%i IN ('TYPE ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_EXTRACT_SAFES_LIST_.csv" ^| SORT ^| FINDSTR /V /R /C:"^.safeName.,.managingCPM." 2^> NUL ^| FINDSTR /I /R /C:"^.%ACL_PARAM_temp_safe_filter%.,.*,.*,.*,.*$" 2^> NUL') DO CALL :Collect_Safe_Owners_For_One_Safe "%%~i" ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_%%~i_+.csv"

	ECHO.
	ECHO *** Waiting for Threads Completion... ***
	ECHO.

:Waiting_for_Threads_Completion_LOOP

	SET /A ACL_PARAM_temp_number_of_cmd=0
	FOR /F "tokens=*" %%i IN ('DIR ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_*_+.cmd" /B 2^> NUL ^| FIND /C "."') DO SET /A ACL_PARAM_temp_number_of_cmd=%%i

IF %ACL_PARAM_temp_number_of_cmd% EQU 0 GOTO Waiting_for_Threads_Completion_NEXT

	ECHO . | SET /P ACL_PARAM_temp_dot=.
	TIMEOUT /T 1 > NUL 2>&1

GOTO Waiting_for_Threads_Completion_LOOP

:Waiting_for_Threads_Completion_NEXT

	SET ACL_PARAM_temp_number_of_cmd=
	SET ACL_PARAM_temp_dot=

	ECHO.

	TYPE ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_*_+.csv" > ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_EXTRACT_OWNERS_LIST_.csv" 2> NUL
	IF EXIST ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_*_+.csv" DEL ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_*_+.csv"

:Convert_only_current_Owners_List_as_Role_Matrix

	IF EXIST ".\tmp\[_%ACL_PARAM_VAULT_CONTEXT%_]_OWNERS_SMART_MATRIX_.tmp" DEL ".\tmp\[_%ACL_PARAM_VAULT_CONTEXT%_]_OWNERS_SMART_MATRIX_.tmp"
	TYPE ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_EXTRACT_OWNERS_LIST_.csv" | SORT | FINDSTR /I /V /R /C:".safeName.,.memberName.,.memberType.,.permissions." | bin\LogParser.exe -i:CSV -headerRow:OFF -iDQuotes:Auto -o:CSV -headers:OFF -oDQuotes:ON file:"sql\CONVERT_1_ACL_OUTPUT_to_ACL_SmartString.sql" -stats:OFF > ".\tmp\[_%ACL_PARAM_VAULT_CONTEXT%_]_OWNERS_SMART_MATRIX_.tmp"

	ECHO SAFE	MEMBER	memberType	ACL_ROLE> ".\[_%ACL_PARAM_VAULT_CONTEXT%_]_OWNERS_ROLE_MATRIX_.tsv"
	TYPE ".\tmp\[_%ACL_PARAM_VAULT_CONTEXT%_]_OWNERS_SMART_MATRIX_.tmp" | bin\LogParser.exe -i:CSV -headerRow:OFF -iDQuotes:Auto -o:DATAGRID -rtp:-1 file:"sql\CONVERT_2_[_%ACL_PARAM_MATRIX_CONTEXT%_]_ACL_SmartString_to_ACL_Role.sql" -stats:OFF
	TYPE ".\tmp\[_%ACL_PARAM_VAULT_CONTEXT%_]_OWNERS_SMART_MATRIX_.tmp" | bin\LogParser.exe -i:CSV -headerRow:OFF -iDQuotes:Auto -o:TSV -headers:OFF file:"sql\CONVERT_2_[_%ACL_PARAM_MATRIX_CONTEXT%_]_ACL_SmartString_to_ACL_Role.sql" -stats:OFF >> ".\[_%ACL_PARAM_VAULT_CONTEXT%_]_OWNERS_ROLE_MATRIX_.tsv"

	IF NOT EXIST ".\[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_REFRESH_#_.tsv" ECHO SAFE	MEMBER	memberType	ACL_ROLE> ".\[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_REFRESH_#_.tsv"
	IF NOT EXIST ".\[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_SUPPRESS_#_.tsv" ECHO SAFE	MEMBER> ".\[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_SUPPRESS_#_.tsv"

:End_of_Script

	SET ACL_PARAM_temp_safe_filter=
	SET ACL_PARAM_temp_debug_parameters_for_power_shell=
	SET ACL_PARAM_temp_multithreading_limit=

	ECHO.
	ECHO ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	ECHO Search for PowerShell Errors ( in ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log" )...
	IF EXIST ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log" FINDSTR /I /C:"ERROR" ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log"
	IF EXIST ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log" IF ERRORLEVEL 1 ECHO ### NO ERRORS ###
	IF NOT EXIST ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log" ECHO ### LOG FILES DID NOT EXIST ###
	ECHO ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SET ACL_PARAM_
	ECHO ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	ECHO.
	ECHO ### TERM ### %0 ### %DATE% %TIME% ###
	ECHO.

GOTO End

REM -------- FUNCTION SECTION -----------------------------------------------------------------------------------------------------------------------------------

:Collect_Safe_Owners_For_One_Safe

	ECHO 	### %~1 ### %~2 ###

:Collect_Safe_Owners_For_One_Safe_BACK_LOOP

	SET /A ACL_PARAM_temp_number_of_cmd=0
	FOR /F "tokens=*" %%i IN ('DIR ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_*_+.cmd" /B 2^> NUL ^| FIND /C "."') DO SET /A ACL_PARAM_temp_number_of_cmd=%%i
IF %ACL_PARAM_temp_number_of_cmd% GEQ %ACL_PARAM_temp_multithreading_limit% GOTO Collect_Safe_Owners_For_One_Safe_WAIT_LOOP

	ECHO CALL "%ACL_PARAM_POWER_SHELL_PATH%" ".\bin\Safe-Management-CUSTOM.ps1" -PVWAURL "%ACL_PARAM_PVWA_URL%" -AuthType cyberark -DisableSSLVerify -AllowInsecureURL -logonToken "%ACL_PARAM_TOKEN%" -concurrentSession -VaultContext "%ACL_PARAM_VAULT_CONTEXT%" -Members -SafeName "%~1" -IncludeDefault -ReportPath "%~2" %ACL_PARAM_temp_debug_parameters_for_power_shell% > ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_%~1_+.cmd"
	ECHO DEL "%%~0">> ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_%~1_+.cmd"

	START "_THREAD_ %ACL_PARAM_VAULT_CONTEXT%" /MIN CMD /C ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_THREAD_+_%~1_+.cmd"

	SET ACL_PARAM_temp_number_of_cmd=
	SET ACL_PARAM_temp_dot=

GOTO :EOF

:Collect_Safe_Owners_For_One_Safe_WAIT_LOOP

	ECHO . | SET /P ACL_PARAM_temp_dot=.
	TIMEOUT /T 1 > NUL 2>&1

GOTO Collect_Safe_Owners_For_One_Safe_BACK_LOOP

REM -------- ERROR SECTION --------------------------------------------------------------------------------------------------------------------------------------

:ERROR_EXTRACT_CMD_PARAMETERS

	ECHO /!\ AT LEAST ONE CMD MANDATORY PARAMETER IS MISSING... /!\
	ECHO Run $1_INIT_.cmd script first and check for completion...
	ECHO.

GOTO End_of_Script

:ERROR_EXTRACT_DEDICATED_SCRIPT

	ECHO /!\ AT LEAST ONE DEDICATED FILE IS MISSING... /!\
	ECHO Check your ACL MANAGEMENT Workspace...
	DIR sql\*.sql
	ECHO.

GOTO End_of_Script

REM -------- END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------

:End


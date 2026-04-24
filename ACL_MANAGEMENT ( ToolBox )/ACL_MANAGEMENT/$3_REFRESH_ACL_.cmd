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

IF NOT DEFINED ACL_PARAM_PVWA_URL GOTO ERROR_REFRESH_CMD_PARAMETERS
IF NOT DEFINED ACL_PARAM_VAULT_CONTEXT GOTO ERROR_REFRESH_CMD_PARAMETERS
IF NOT DEFINED ACL_PARAM_MATRIX_CONTEXT GOTO ERROR_REFRESH_CMD_PARAMETERS
IF NOT DEFINED ACL_PARAM_TOKEN GOTO ERROR_REFRESH_CMD_PARAMETERS
IF NOT DEFINED ACL_PARAM_POWER_SHELL_PATH GOTO ERROR_REFRESH_CMD_PARAMETERS
IF NOT EXIST "sql\CONVERT_3_[_%ACL_PARAM_MATRIX_CONTEXT%_]_ACL_Role_to_ACL_SmartString.sql" GOTO ERROR_REFRESH_DEDICATED_SCRIPT
IF NOT EXIST "sql\CONVERT_4_ACL_Smartstring_to_REST_API.sql" GOTO ERROR_REFRESH_DEDICATED_SCRIPT
IF NOT EXIST "[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_REFRESH_#_.tsv" GOTO ERROR_REFRESH_MISSING_INPUT_FILE

	SET ACL_PARAM_temp_debug_parameters_for_power_shell=
	IF DEFINED DEBUG SET ACL_PARAM_temp_debug_parameters_for_power_shell=-IncludeCallStack -UseVerboseFile

	IF EXIST ".\tmp\[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_REFRESH_ACL_CODE_#_.tmp" DEL ".\tmp\[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_REFRESH_ACL_CODE_#_.tmp"
	TYPE ".\[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_REFRESH_#_.tsv" | FINDSTR /I /V /R /C:"	Administrator	User	" | bin\LogParser.exe -i:TSV -headerRow:ON -o:TSV -headers:ON file:"sql\CONVERT_3_[_%ACL_PARAM_MATRIX_CONTEXT%_]_ACL_Role_to_ACL_SmartString.sql" -stats:OFF > ".\tmp\[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_REFRESH_ACL_CODE_#_.tmp"

	START /WAIT NOTEPAD ".\tmp\[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_REFRESH_ACL_CODE_#_.tmp"

	IF EXIST ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_ROLE_MATRIX_#_REST_API_#_.csv" DEL ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_ROLE_MATRIX_#_REST_API_#_.csv"
	TYPE ".\tmp\[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_REFRESH_ACL_CODE_#_.tmp" | bin\LogParser.exe -i:TSV -headerRow:ON -o:CSV -headers:ON -oDQuotes:OFF file:"sql\CONVERT_4_ACL_Smartstring_to_REST_API.sql" -stats:OFF > ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_ROLE_MATRIX_#_REST_API_#_.csv"

IF /I "%~1" == "-CONVERT-ONLY" GOTO End_of_Script

	IF EXIST ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log" DEL ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log"
	CALL "%ACL_PARAM_POWER_SHELL_PATH%" ".\bin\Safe-Management-CUSTOM.ps1" -PVWAURL "%ACL_PARAM_PVWA_URL%" -AuthType cyberark -DisableSSLVerify -AllowInsecureURL -logonToken "%ACL_PARAM_TOKEN%" -concurrentSession -VaultContext "%ACL_PARAM_VAULT_CONTEXT%" -UpdateMembers -FilePath ".\tmp\+_%ACL_PARAM_VAULT_CONTEXT%_+_ROLE_MATRIX_#_REST_API_#_.csv" -AddOnUpdate %ACL_PARAM_temp_debug_parameters_for_power_shell%

:End_of_Script

	SET ACL_PARAM_temp_debug_parameters_for_power_shell=

	ECHO.
	ECHO ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	ECHO Search for PowerShell Errors ( in ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log" )...
	IF EXIST ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log" FINDSTR /I /C:"ERROR" ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log"
	TF EXIST ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log" IF ERRORLEVEL 1 ECHO ### NO ERRORS ###
	IF NOT EXIST ".\log\!_%ACL_PARAM_VAULT_CONTEXT%_!_*.log" ECHO ### LOG FILES DID NOT EXIST ###
	ECHO ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SET ACL_PARAM_
	ECHO ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	ECHO.
	ECHO ### TERM ### %0 ### %DATE% %TIME% ###
	ECHO.

GOTO End

REM -------- FUNCTION SECTION -----------------------------------------------------------------------------------------------------------------------------------

:Function_Place_Holder

	REM ...

GOTO :EOF

REM -------- ERROR SECTION --------------------------------------------------------------------------------------------------------------------------------------

:ERROR_REFRESH_CMD_PARAMETERS

	ECHO /!\ AT LEAST ONE CMD MANDATORY PARAMETER IS MISSING... /!\
	ECHO Run $1_INIT_.cmd script first and check for completion...
	ECHO.

GOTO End_of_Script

:ERROR_REFRESH_DEDICATED_SCRIPT

	ECHO /!\ AT LEAST ONE DEDICATED SCRIPT IS MISSING... /!\
	ECHO Check your ACL MANAGEMENT Workspace...
	DIR sql\*.sql
	ECHO.

GOTO End_of_Script

:ERROR_REFRESH_MISSING_INPUT_FILE

	ECHO /!\ REFRESH INPUT FILE IS MISSING... /!\
	ECHO Run "$2_EXTRACT_ACL_.cmd" again or create file "[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_REFRESH_#_.tsv" manually...
	DIR "[_%ACL_PARAM_VAULT_CONTEXT%_]_*"
	ECHO.

GOTO End_of_Script

REM -------- END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------

:End


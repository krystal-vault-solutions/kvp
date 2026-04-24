@ECHO OFF

CLS

CD /D "%~dp0"

:Start

	ECHO.
	ECHO ### INIT ### %0 ### %DATE% %TIME% ###
	ECHO.

	REM RESET PRIMARY PARAMETERS ( AT SESSION LEVEL ) :
	SET ACL_PARAM_PVWA_URL=
	SET ACL_PARAM_VAULT_CONTEXT=
	SET ACL_PARAM_MATRIX_CONTEXT=
	SET ACL_PARAM_TOKEN=
	SET ACL_PARAM_POWER_SHELL_PATH=
	REM ACL_PARAM_temp_config_file_name can be reused between INIT runs until we use TERM command...

IF NOT EXIST "cfg\*" GOTO ERROR_CONFIG_FILES_ARE_MISSING

	DIR /B cfg\*.ini
	ECHO.
	SET ACL_PARAM_temp_previous_conf=%ACL_PARAM_temp_config_file_name%
	IF NOT DEFINED ACL_PARAM_temp_previous_conf SET /P ACL_PARAM_temp_config_file_name=Please select one configuration file from above list ( mandatory ) : 
	IF DEFINED ACL_PARAM_temp_previous_conf SET /P ACL_PARAM_temp_config_file_name=Please select another configuration file from above list ( or keep current as %ACL_PARAM_temp_previous_conf% ) : 
	IF NOT DEFINED ACL_PARAM_temp_config_file_name SET ACL_PARAM_temp_config_file_name=%ACL_PARAM_temp_previous_conf%
	SET ACL_PARAM_temp_previous_conf=
IF NOT DEFINED ACL_PARAM_temp_config_file_name GOTO End_of_Script
	IF NOT EXIST "cfg\%ACL_PARAM_temp_config_file_name%" IF EXIST "cfg\%ACL_PARAM_temp_config_file_name%.ini" SET ACL_PARAM_temp_config_file_name=%ACL_PARAM_temp_config_file_name%.ini
IF NOT EXIST "cfg\%ACL_PARAM_temp_config_file_name%" GOTO End_of_Script

	FOR /F "tokens=1,* delims==" %%i IN ('TYPE "cfg\%ACL_PARAM_temp_config_file_name%" ^| FINDSTR /B /V /C:"#" 2^> NUL') DO SET ACL_PARAM_%%i=%%j
IF NOT DEFINED ACL_PARAM_PVWA_URL GOTO ERROR_MISSING_PARAM
IF NOT DEFINED ACL_PARAM_VAULT_CONTEXT GOTO ERROR_MISSING_PARAM
IF NOT DEFINED ACL_PARAM_MATRIX_CONTEXT GOTO ERROR_MISSING_PARAM
IF NOT EXIST "sql\CONVERT_1_ACL_OUTPUT_to_ACL_SmartString.sql" GOTO ERROR_MISSING_SQL_FILE
IF NOT EXIST "sql\CONVERT_2_[_%ACL_PARAM_MATRIX_CONTEXT%_]_ACL_SmartString_to_ACL_Role.sql" GOTO ERROR_MISSING_SQL_FILE
IF NOT EXIST "sql\CONVERT_3_[_%ACL_PARAM_MATRIX_CONTEXT%_]_ACL_Role_to_ACL_SmartString.sql" GOTO ERROR_MISSING_SQL_FILE
IF NOT EXIST "sql\CONVERT_4_ACL_Smartstring_to_REST_API.sql" GOTO ERROR_MISSING_SQL_FILE

	ECHO *** ACL_PARAM_PVWA_URL=%ACL_PARAM_PVWA_URL% ***
	ECHO *** ACL_PARAM_VAULT_CONTEXT=%ACL_PARAM_VAULT_CONTEXT% ***
	ECHO *** ACL_PARAM_MATRIX_CONTEXT=%ACL_PARAM_MATRIX_CONTEXT% ***
	ECHO.

	ECHO.
	SET ACL_PARAM_temp_authentication_type=
	SET /P ACL_PARAM_temp_authentication_type=(+) Authentication Type ( default is "Cyberark" ) -^> 
	IF NOT DEFINED ACL_PARAM_temp_authentication_type SET ACL_PARAM_temp_authentication_type=cyberark
	ECHO *** ACL_PARAM_temp_authentication_type=%ACL_PARAM_temp_authentication_type% ***

	ECHO.
	SET ACL_PARAM_temp_username=
	SET /P ACL_PARAM_temp_username=(+) Enter UserName      ( default is "Auditor" ) -^> 
	IF NOT DEFINED ACL_PARAM_temp_username SET ACL_PARAM_temp_username=Auditor
	ECHO *** ACL_PARAM_temp_username=%ACL_PARAM_temp_username% ***

	SET ACL_PARAM_temp_password=
	SET /P ACL_PARAM_temp_password=(+) Enter Password      ( default is "Check411!" ) -^> 
	IF NOT DEFINED ACL_PARAM_temp_password SET ACL_PARAM_temp_password=Check411!

	SET ACL_PARAM_temp_curl_output_file=tmp\%~n0.CURL.tmp
	SET ACL_PARAM_temp_curl_error_file=tmp\%~n0.CURL.err
	IF EXIST "%ACL_PARAM_temp_curl_output_file%" DEL "%ACL_PARAM_temp_curl_output_file%"
	IF EXIST "%ACL_PARAM_temp_curl_error_file%" DEL "%ACL_PARAM_temp_curl_error_file%"

	SET ACL_PARAM_TOKEN=
	CALL bin\curl.exe -k -X POST --header "Content-Type: application/json" --header "Accept: application/json" -d "{ """"UserName"""": """"%ACL_PARAM_temp_username%"""", """"Password"""": """"%ACL_PARAM_temp_password%"""", """"SecureMode"""": true, """"concurrentSession"""": true }" "%ACL_PARAM_PVWA_URL%/api/Auth/%ACL_PARAM_temp_authentication_type%/Logon" > "%ACL_PARAM_temp_curl_output_file%" 2> "%ACL_PARAM_temp_curl_error_file%"
	ECHO ### RC=%ERRORLEVEL% ###
IF ERRORLEVEL 1 GOTO ERROR_INIT_CURL
	SET ACL_PARAM_temp_password=
	TYPE "%ACL_PARAM_temp_curl_output_file%" | FIND /I "ERROR" > NUL
IF NOT ERRORLEVEL 1 GOTO ERROR_INIT_CURL
	FOR /F "tokens=*" %%i IN (%ACL_PARAM_temp_curl_output_file%) DO SET ACL_PARAM_TOKEN=%%~i
	ECHO *** ACL_PARAM_TOKEN=%ACL_PARAM_TOKEN% ***
IF NOT DEFINED ACL_PARAM_TOKEN GOTO ERROR_INIT_CURL

	IF EXIST "%ACL_PARAM_temp_curl_output_file%" DEL "%ACL_PARAM_temp_curl_output_file%"
	IF EXIST "%ACL_PARAM_temp_curl_error_file%" DEL "%ACL_PARAM_temp_curl_error_file%"
	SET ACL_PARAM_temp_curl_output_file=
	SET ACL_PARAM_temp_curl_error_file=

	SET ACL_PARAM_POWER_SHELL_PATH=
	IF EXIST "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" SET ACL_PARAM_POWER_SHELL_PATH=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
	IF EXIST "C:\Program Files\PowerShell\7\pwsh.exe" SET ACL_PARAM_POWER_SHELL_PATH=C:\Program Files\PowerShell\7\pwsh.exe
	IF NOT DEFINED ACL_PARAM_POWER_SHELL_PATH SET /P ACL_PARAM_POWER_SHELL_PATH=(+) Enter fully qualified path to local PowerShell Engine ( including exe and quotations ) -^> 
rem	FOR /F "tokens=*" %%i IN ("%ACL_PARAM_POWER_SHELL_PATH%") DO SET ACL_PARAM_POWER_SHELL_PATH="%%~i"
rem IF NOT EXIST %ACL_PARAM_POWER_SHELL_PATH% GOTO ERROR_INIT_POWER_SHELL
	ECHO *** ACL_PARAM_POWER_SHELL_PATH="%ACL_PARAM_POWER_SHELL_PATH%" ***

	TITLE [ %ACL_PARAM_VAULT_CONTEXT% ]-[ %ACL_PARAM_MATRIX_CONTEXT% ]-[ %ACL_PARAM_temp_username% ]-[ %ACL_PARAM_PVWA_URL% ]

:End_of_Script

	SET ACL_PARAM_temp_authentication_type=
	SET ACL_PARAM_temp_username=
	SET ACL_PARAM_temp_password=

	ECHO.
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

:ERROR_CONFIG_FILES_ARE_MISSING

	ECHO /!\ CONFIGURATION FILES ARE MISSING IN [ CFG ] FOLDER /!\
	ECHO Please create at least one Config File and restart script later...
	ECHO.

GOTO End_of_Script

:ERROR_MISSING_PARAM

	ECHO /!\ ONE OF THE REQUIRED PARAMETER IS MISSING IN CONFIG FILE ( %ACL_PARAM_temp_config_file_name% ) /!\
	ECHO Please check it and adjust based on template and restart script later...
	TYPE cfg\_TEMPLATE_.txt
	ECHO.

	SET ACL_PARAM_temp_config_file_name=

GOTO End_of_Script

:ERROR_MISSING_SQL_FILE

	ECHO /!\ ONE LOGPARSER SQL FILE IS MISSING IN [ SQL ] FOLDER /!\
	ECHO Please check SQL files and restart script later...
	DIR sql\*.sql
	ECHO.

GOTO End_of_Script

:ERROR_INIT_CURL

	ECHO /!\ CURL QUERY DID NOT SUCCEED ( RETURN-CODE IS NOT 0 OR ERROR MESSAGE IN RESPONSE ) /!\
	ECHO Look at command output below and adjust input data as required...
	ECHO *** STDOUT ***
	TYPE "%ACL_PARAM_temp_curl_output_file%"
	ECHO.
	ECHO *** STDERR ***
	TYPE "%ACL_PARAM_temp_curl_error_file%"
	ECHO.
	ECHO *** ****** ***
	IF EXIST "%ACL_PARAM_temp_curl_output_file%" DEL "%ACL_PARAM_temp_curl_output_file%"
	IF EXIST "%ACL_PARAM_temp_curl_error_file%" DEL "%ACL_PARAM_temp_curl_error_file%"
	SET ACL_PARAM_temp_curl_output_file=
	SET ACL_PARAM_temp_curl_error_file=
	ECHO.

GOTO End_of_Script

:ERROR_INIT_POWER_SHELL

	ECHO /!\ POWERSHELL ENGINE HAD NOT BEEN FOUND ON LOCAL SYSTEM /!\
	ECHO Look at relevant binary on your system and retry by entering the right PATH to PowerShell you want using...
	ECHO.
	ECHO ### DO NOT PROCEED WITH OTHER ACL MANAGEMENT SCRIPTS UNTIL YOU SOLVE THIS ISSUE ###
	ECHO ### DO NOT PROCEED WITH OTHER ACL MANAGEMENT SCRIPTS UNTIL YOU SOLVE THIS ISSUE ###
	ECHO ### DO NOT PROCEED WITH OTHER ACL MANAGEMENT SCRIPTS UNTIL YOU SOLVE THIS ISSUE ###
	ECHO.

GOTO End_of_Script

REM -------- END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------

:End


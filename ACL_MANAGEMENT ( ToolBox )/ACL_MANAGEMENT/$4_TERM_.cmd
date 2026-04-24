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

IF NOT DEFINED ACL_PARAM_PVWA_URL GOTO ERROR_TERM_CMD_PARAMETERS
IF NOT DEFINED ACL_PARAM_VAULT_CONTEXT GOTO ERROR_TERM_CMD_PARAMETERS
IF NOT DEFINED ACL_PARAM_MATRIX_CONTEXT GOTO ERROR_TERM_CMD_PARAMETERS
IF NOT DEFINED ACL_PARAM_TOKEN GOTO ERROR_TERM_CMD_PARAMETERS
IF NOT DEFINED ACL_PARAM_POWER_SHELL_PATH GOTO ERROR_TERM_CMD_PARAMETERS

	SET ACL_PARAM_temp_curl_output_file=tmp\%~n0.CURL.tmp
	SET ACL_PARAM_temp_curl_error_file=tmp\%~n0.CURL.err
	IF EXIST "%ACL_PARAM_temp_curl_output_file%" DEL "%ACL_PARAM_temp_curl_output_file%"
	IF EXIST "%ACL_PARAM_temp_curl_error_file%" DEL "%ACL_PARAM_temp_curl_error_file%"

	CALL curl.exe -k -X POST --header "Accept: application/json" --header "Authorization: %ACL_PARAM_TOKEN%" -d "" "%ACL_PARAM_PVWA_URL%/api/Auth/Logoff" > "%ACL_PARAM_temp_curl_output_file%" 2> "%ACL_PARAM_temp_curl_error_file%"
	ECHO ### RC=%ERRORLEVEL% ###
IF ERRORLEVEL 1 GOTO ERROR_TERM_CURL
	TYPE "%ACL_PARAM_temp_curl_output_file%" | FIND /I "{""LogoffUrl"":""""}" > NUL
IF NOT ERRORLEVEL 1 GOTO Logoff_Completed
GOTO ERROR_TERM_CURL

:Logoff_Completed

	IF EXIST "%ACL_PARAM_temp_curl_output_file%" DEL "%ACL_PARAM_temp_curl_output_file%"
	IF EXIST "%ACL_PARAM_temp_curl_error_file%" DEL "%ACL_PARAM_temp_curl_error_file%"
	SET ACL_PARAM_temp_curl_output_file=
	SET ACL_PARAM_temp_curl_error_file=

	TITLE [ ### ]-[ ### ]-[ ### ]-[ ### ]

	SET ACL_PARAM_PVWA_URL=
	SET ACL_PARAM_VAULT_CONTEXT=
	SET ACL_PARAM_MATRIX_CONTEXT=
	SET ACL_PARAM_TOKEN=
	SET ACL_PARAM_POWER_SHELL_PATH=
	SET ACL_PARAM_temp_config_file_name=

:End_of_Script

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

:ERROR_TERM_CMD_PARAMETERS

	ECHO /!\ AT LEAST ONE CMD MANDATORY PARAMETER IS MISSING... /!\
	ECHO Run $1_INIT_.cmd script first and check for completion...
	ECHO.

GOTO End_of_Script

:ERROR_TERM_CURL

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

REM -------- END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------

:End


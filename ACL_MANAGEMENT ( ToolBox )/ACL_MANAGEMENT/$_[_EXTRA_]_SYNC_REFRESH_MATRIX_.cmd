@ECHO OFF

CLS

CD /D "%~dp0"

:Start

	ECHO.
	ECHO 	### INIT ### %0 ### %DATE% %TIME% ###
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

	SET ACL_PARAM_temp_beyond_compare_path=
	IF EXIST "C:\Program Files (x86)\Beyond Compare 2\BC2.exe" SET ACL_PARAM_temp_beyond_compare_path=C:\Program Files (x86)\Beyond Compare 2\BC2.exe
	IF EXIST "C:\Program Files\Beyond Compare 2\BC2.exe" SET ACL_PARAM_temp_beyond_compare_path=C:\Program Files\Beyond Compare 2\BC2.exe
IF NOT DEFINED ACL_PARAM_temp_beyond_compare_path GOTO ERROR_BEYOND_COMPARE_PATH

	CALL "%ACL_PARAM_temp_beyond_compare_path%" ".\[_%ACL_PARAM_VAULT_CONTEXT%_]_OWNERS_ROLE_MATRIX_.tsv" ".\[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_REFRESH_#_.tsv"

:End_of_Script

	SET ACL_PARAM_temp_beyond_compare_path=

	ECHO.
	ECHO ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SET ACL_PARAM_
	ECHO ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	ECHO.
	ECHO 	### TERM ### %0 ### %DATE% %TIME% ###
	ECHO.

GOTO End

REM -------- ERROR SECTION --------------------------------------------------------------------------------------------------------------------------------------

:ERROR_BEYOND_COMPARE_PATH

	ECHO /!\ BEYOND COMPARE IS NOT INSTALLED ON THIS COMPUTER /!\
	ECHO You have to make manual comparison between Extracted ACL and Refresh ACL files.
	ECHO (+) Extracted ACL file = ".\[_%ACL_PARAM_VAULT_CONTEXT%_]_OWNERS_ROLE_MATRIX_.tsv"
	ECHO (+) Refresh ACL file   = ".\[_%ACL_PARAM_VAULT_CONTEXT%_]_ROLE_MATRIX_#_REFRESH_#_.tsv"
	ECHO.

GOTO End_of_Script

REM -------- END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------

:End


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

IF NOT EXIST "sql\CONVERT_2_[_%ACL_PARAM_MATRIX_CONTEXT%_]_ACL_SmartString_to_ACL_Role.sql" GOTO ERROR_INVERT_DEDICATED_SCRIPT
IF NOT EXIST "sql\CONVERT_3_[_%ACL_PARAM_MATRIX_CONTEXT%_]_ACL_Role_to_ACL_SmartString.sql" GOTO ERROR_INVERT_DEDICATED_SCRIPT

	SET ACL_PARAM_temp_beyond_compare_path=
	IF EXIST "C:\Program Files (x86)\Beyond Compare 2\BC2.exe" SET ACL_PARAM_temp_beyond_compare_path=C:\Program Files (x86)\Beyond Compare 2\BC2.exe
	IF EXIST "C:\Program Files\Beyond Compare 2\BC2.exe" SET ACL_PARAM_temp_beyond_compare_path=C:\Program Files\Beyond Compare 2\BC2.exe

	IF EXIST ".\tmp\+INVERTED_MATRIX.txt" DEL ".\tmp\+INVERTED_MATRIX.txt"
	TYPE "sql\CONVERT_2_[_%ACL_PARAM_MATRIX_CONTEXT%_]_ACL_SmartString_to_ACL_Role.sql" | FINDSTR /B /I /C:"/* " >> ".\tmp\+INVERTED_MATRIX.txt"
	ECHO. >> ".\tmp\+INVERTED_MATRIX.txt"
	FOR /F "tokens=1,2,3,4,* delims=	" %%i IN ('TYPE ".\sql\CONVERT_2_[_%ACL_PARAM_MATRIX_CONTEXT%_]_ACL_SmartString_to_ACL_Role.sql" ^| FINDSTR /I /R /C:"	WHEN	" 2^> NUL') DO ECHO 		%%i	%%l	%%k	%%j	%%m>> ".\tmp\+INVERTED_MATRIX.txt"
	IF NOT DEFINED ACL_PARAM_temp_beyond_compare_path START NOTEPAD ".\tmp\+INVERTED_MATRIX.txt"
	IF DEFINED ACL_PARAM_temp_beyond_compare_path CALL "%ACL_PARAM_temp_beyond_compare_path%" ".\tmp\+INVERTED_MATRIX.txt" ".\sql\CONVERT_3_[_%ACL_PARAM_MATRIX_CONTEXT%_]_ACL_Role_to_ACL_SmartString.sql"

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

REM -------- FUNCTION SECTION -----------------------------------------------------------------------------------------------------------------------------------

:Function_Place_Holder

	REM ...

GOTO :EOF

REM -------- ERROR SECTION --------------------------------------------------------------------------------------------------------------------------------------

:ERROR_INVERT_DEDICATED_SCRIPT

	ECHO /!\ AT LEAST ONE DEDICATED FILE IS MISSING... /!\
	ECHO Check your ACL MANAGEMENT Workspace...
	DIR sql\*.sql
	ECHO.

GOTO End_of_Script

REM -------- END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------

:End


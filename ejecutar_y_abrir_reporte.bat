@echo off
setlocal
cd /d "%~dp0"
echo ==================================================
echo        KARATE - FLUJO COMPLETO (5 ESCENARIOS)
echo ==================================================
echo.
echo Java utilizado por Maven:
call mvn -version
echo.
echo Ejecutando escenarios...
call mvn clean test
set "CODIGO_MAVEN=%ERRORLEVEL%"
set "REPORTE=%CD%\target\karate-reports\karate-summary.html"
echo.
if exist "%REPORTE%" (
    echo Abriendo reporte HTML: "%REPORTE%"
    start "" "%REPORTE%"
) else (
    echo El reporte HTML no se genero. Consulta los errores de la consola.
)
echo.
if "%CODIGO_MAVEN%"=="0" (
    echo Las pruebas finalizaron correctamente.
) else (
    echo Maven termino con errores. Codigo: %CODIGO_MAVEN%.
)
pause
exit /b %CODIGO_MAVEN%

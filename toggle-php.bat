@echo off
setlocal enabledelayedexpansion

:: Definir la ruta de XAMPP
set "XAMPP_PATH=C:\xampp"
cd /d "%XAMPP_PATH%"

:menu
echo ================================================
echo             PHP Version Switcher
echo ================================================
echo.
echo Available PHP versions:
echo 1.- 8.1.25
echo 2.- 8.2.28
echo 3.- 8.3.21
echo 4.- 8.4.7
echo 0.- Exit
echo.

set "TARGET="
set /p option=Enter the number of the version to switch:
if "%option%"=="1" set "TARGET=8.1.25"
if "%option%"=="2" set "TARGET=8.2.28"
if "%option%"=="3" set "TARGET=8.3.21"
if "%option%"=="4" set "TARGET=8.4.7"
if "%option%"=="0" goto abort

if not defined TARGET (
    echo Invalid selection. Aborting.
    goto abort
)

:: --- MODIFICACION: Verificar si la carpeta php existe antes de intentar obtener la version ---
if not exist "%XAMPP_PATH%\php" (
    echo Error: Cannot find the 'php' directory in %XAMPP_PATH%.
    echo Please ensure the currently active PHP version is in a folder named 'php'.
    goto abort
)
:: --- FIN MODIFICACION ---

:: Detectar versión actual ejecutando php -v
:: La salida tipica de php -v es algo como: PHP 8.2.28 (cli) (built: ...)
:: for /f "tokens=2 delims= " extrae el segundo token ("8.2.28") usando el espacio como delimitador.
for /f "tokens=2 delims= " %%A in ('php\php.exe -v') do (
    set "CURRENT=%%A"
    goto found
)

:found
:: Si CURRENT sigue vacio, significa que php -v no produjo la salida esperada o fallo por otra razon.
if "%CURRENT%"=="" (
    echo Cannot determine current version from 'php\php.exe -v' output.
    echo Please check the output of 'C:\xampp\php\php.exe -v' manually.
    goto abort
)

if "%CURRENT%"=="%TARGET%" (
    echo Already using PHP %CURRENT%.
    pause
    goto menu
)

echo ================================================
echo    Switching from PHP %CURRENT% to %TARGET%...
echo ================================================

:: Detener servicios
echo Stopping Apache and MySQL...
:: Usamos >nul para ocultar la salida de estos comandos si tienen exito.
net stop Apache2.4 >nul 2>&1
net stop MySQL >nul 2>&1

:: Renombrar carpetas
:: Usamos >nul para ocultar la salida de estos comandos si tienen exito.
:: 2>&1 redirige los errores a la salida nula tambien.
ren php php-%CURRENT% >nul 2>&1
ren php-%TARGET% php >nul 2>&1

:: Reiniciar servicios
echo Starting Apache and MySQL...
:: Usamos >nul para ocultar la salida de estos comandos si tienen exito.
net start Apache2.4 >nul 2>&1
net start MySQL >nul 2>&1

:end
echo ================================================
echo       PHP version switch complete.
echo ================================================
timeout /t 3 >nul
goto :eof

:abort
echo ================================================
echo       PHP version switch aborted.
echo ================================================
timeout /t 3 >nul
goto :eof

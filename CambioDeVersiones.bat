@echo off
:: Verificar permisos de administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Ejecuta este script como administrador.
    pause
    exit /b
)

title Configurador Psych Engine (0.6.3 / 0.7.3)
setlocal ENABLEEXTENSIONS
setlocal ENABLEDELAYEDEXPANSION

echo =============================================
echo        CONFIGURADOR DE PSYCH ENGINE
echo =============================================
echo.
echo 1. Psych Engine 0.6.3 (Haxe 4.2.5)
echo 2. Psych Engine 0.7.3 (Haxe 4.3.2)
echo.

set /p choice=Selecciona la version (1 o 2): 

if "%choice%"=="1" (
    set ENGINE_VERSION=0.6.3
    set REQUIRED_HAXE=4.2.5
    set HAXE_EXECUTABLE=For_063.exe
    goto check_haxe
)
if "%choice%"=="2" (
    set ENGINE_VERSION=0.7.3
    set REQUIRED_HAXE=4.3.2
    set HAXE_EXECUTABLE=For_073.exe
    goto check_haxe
)

echo Opcion invalida.
pause
exit /b

:check_haxe
echo.
echo Verificando Haxe...

where haxe
if errorlevel 1 goto try_install_haxe

for /f "delims=" %%i in ('haxe --version') do set HAXEVERSION=%%i
echo Version actual de Haxe: %HAXEVERSION%

if "%HAXEVERSION%"=="%REQUIRED_HAXE%" (
    echo Haxe %REQUIRED_HAXE% ya esta activo.
    goto check_haxelib
)

echo Tienes Haxe %HAXEVERSION%, pero se requiere %REQUIRED_HAXE%.
set /p confirm=¿Quieres desinstalar la version actual de Haxe y continuar con la instalacion de la version %REQUIRED_HAXE%? (S/N): 
if /i "%confirm%"=="S" goto uninstall_haxe
goto end

:uninstall_haxe
echo =============================================
echo Desinstalando Haxe actual...
echo =============================================

for /f "delims=" %%i in ('where haxe') do set HAXE_PATH=%%i
set HAXE_DIR=!HAXE_PATH:\haxe.exe=!

set HAXE_PARENT_DIR=C:\HaxeToolkit

if exist "!HAXE_PARENT_DIR!\Uninstall.exe" (
    echo Ejecutando desinstalador oficial desde "!HAXE_PARENT_DIR!\Uninstall.exe"...
    start /wait "" "!HAXE_PARENT_DIR!\Uninstall.exe" /S
    timeout /t 5
) else (
    echo No se encontro el desinstalador oficial en "!HAXE_PARENT_DIR!".
    echo Intentando desinstalacion manual...
    if exist "!HAXE_PATH!" (
        del /f /q "!HAXE_PATH!"
    )
)

reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v HAXEPATH /f >nul 2>&1
reg delete "HKCU\Environment" /v HAXEPATH /f >nul 2>&1

echo Haxe desinstalado correctamente.
goto try_install_haxe

:try_install_haxe
echo =============================================
echo Instalando Haxe %REQUIRED_HAXE%...
echo =============================================

if not exist "%HAXE_EXECUTABLE%" (
    echo ERROR: Falta el archivo "%HAXE_EXECUTABLE%".
    echo Asegurate de que este en la misma carpeta que este script.
    pause
    exit /b
)

echo Ejecutando el instalador de Haxe: %HAXE_EXECUTABLE%...
start /wait "" "%HAXE_EXECUTABLE%"
if errorlevel 1 (
    echo ERROR: Fallo la instalacion de Haxe.
    pause
    exit /b
)

echo Haxe %REQUIRED_HAXE% instalado correctamente.
goto check_haxelib

:check_haxelib
echo.
echo Configurando haxelib en modo local...

set HAXELIB_LOCAL_DIR=%~dp0haxelib
if not exist "%HAXELIB_LOCAL_DIR%" (
    mkdir "%HAXELIB_LOCAL_DIR%"
)

haxelib setup "%HAXELIB_LOCAL_DIR%"
if errorlevel 1 (
    echo ERROR: No se pudo configurar haxelib en modo local.
    pause
    exit /b
)

goto set_libs

:set_libs
echo.
echo Estableciendo librerias para Psych Engine %ENGINE_VERSION%...
echo.

if "%ENGINE_VERSION%"=="0.6.3" goto set_063
if "%ENGINE_VERSION%"=="0.7.3" goto set_073

:set_063
haxelib install flixel 5.2.2
haxelib install flixel-addons 3.0.2
haxelib install flixel-demos 2.9.0
haxelib install flixel-templates 2.6.6
haxelib install flixel-tools 1.5.1
haxelib install flixel-ui 2.5.0
haxelib git flxanimate https://github.com/ShadowMario/flxanimate.git dev
haxelib install hscript 2.5.0
haxelib install hxCodec 2.6.1
haxelib install lime-samples 7.0.0
haxelib install lime 8.0.1
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit.git
haxelib install openfl 9.2.1
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc.git
goto done

:set_073
haxelib install flixel 5.5.0
haxelib install flixel-addons 3.2.1
haxelib install flixel-tools 1.5.1
haxelib install flixel-ui 2.5.0
haxelib git flxanimate https://github.com/ShadowMario/flxanimate.git dev
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git
haxelib install hxcpp-debug-server 1.2.4
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc.git
haxelib install lime 8.0.1
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit.git
haxelib install openfl 9.3.2
haxelib install tjson 1.4.0

set ZIP_FILE=SScript-8.1.6.zip
set EXTRACT_DIR=%HAXELIB_LOCAL_DIR%\SScript\8.1.6

if not exist "%ZIP_FILE%" (
    echo ERROR: Falta el archivo "%ZIP_FILE%".
    echo Asegurate de que este en la misma carpeta que este script.
    pause
    exit /b
)

if not exist "%HAXELIB_LOCAL_DIR%\SScript" (
    mkdir "%HAXELIB_LOCAL_DIR%\SScript"
)

echo Descomprimiendo SScript...
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%EXTRACT_DIR%' -Force"
if errorlevel 1 (
    echo ERROR: Fallo al descomprimir el archivo ZIP.
    pause
    exit /b
)

haxelib set SScript 8.1.6
goto done

:done
echo.
echo =============================================
echo Configuracion completada para Psych Engine %ENGINE_VERSION%!
echo Librerias instaladas en: %HAXELIB_LOCAL_DIR%
echo =============================================
pause
exit /b

:end
echo Operacion cancelada. Fin del proceso.
pause
exit /b
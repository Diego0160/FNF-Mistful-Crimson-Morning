@echo off
:: Verificar permisos de administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Ejecuta este script como administrador.
    pause
    exit /b
)

title Instalador Psych Engine 0.7.3
setlocal ENABLEEXTENSIONS
setlocal ENABLEDELAYEDEXPANSION

echo =============================================
echo        INSTALADOR DE PSYCH ENGINE 0.7.3
echo =============================================
echo.

:: Verificar si Visual Studio está instalado
:check_vs
echo Verificando Visual Studio Community...

if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC" (
    echo Visual Studio Community 2022 ya esta instalado.
    goto check_vs_components
)

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC" (
    echo Visual Studio Community 2019 ya esta instalado.
    goto check_vs_components
)

echo Visual Studio Community no esta instalado.
set /p install_vs=¿Deseas instalar Visual Studio Community? (S/N): 
if /i "%install_vs%"=="S" goto install_vs
goto check_haxe

:check_vs_components
echo Verificando componentes necesarios de Visual Studio...

:: Verificar si los componentes necesarios están instalados
set COMPONENTS_MISSING=0

if not exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC" (
    if not exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC" (
        set COMPONENTS_MISSING=1
    )
)

if not exist "C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0" (
    set COMPONENTS_MISSING=1
)

if %COMPONENTS_MISSING%==1 (
    echo Faltan componentes necesarios de Visual Studio.
    set /p install_components=¿Deseas instalar los componentes necesarios? (S/N): 
    if /i "%install_components%"=="S" goto install_vs
)

goto check_haxe

:install_vs
echo =============================================
echo Instalando Microsoft Visual Studio Community
echo =============================================

echo Descargando Visual Studio Community Installer...
echo Este proceso puede tardar varios minutos dependiendo de tu conexion a internet.

:: Guardar directorio actual
set CURRENT_DIR=%CD%

:: Cambiar al directorio raíz del proyecto
cd %~dp0..

:: Descargar el instalador con barra de progreso
curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe

if not exist "vs_Community.exe" (
    echo ERROR: No se pudo descargar el instalador de Visual Studio.
    cd %CURRENT_DIR%
    pause
    exit /b
)

echo Ejecutando el instalador de Visual Studio...
echo IMPORTANTE: Selecciona los componentes "Desarrollo de escritorio con C++" cuando se abra el instalador.

vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p

if errorlevel 1 (
    echo ERROR: Fallo la instalacion de Visual Studio.
    cd %CURRENT_DIR%
    pause
    exit /b
)

echo Limpiando archivos temporales...
del vs_Community.exe

:: Volver al directorio original
cd %CURRENT_DIR%

echo Visual Studio Community instalado correctamente.

:: Continuar con la instalación de Haxe

set REQUIRED_HAXE=4.3.2
set HAXE_EXECUTABLE=Haxe_4.3.2.exe

:check_haxe
echo.
echo Verificando Haxe...

where haxe >nul 2>&1
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

if not exist "%~dp0%HAXE_EXECUTABLE%" (
    echo ERROR: Falta el archivo "%HAXE_EXECUTABLE%".
    echo Asegurate de que este en la misma carpeta que este script: %~dp0
    pause
    exit /b
)

echo Ejecutando el instalador de Haxe: %HAXE_EXECUTABLE%...
start /wait "" "%~dp0%HAXE_EXECUTABLE%"
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

set HAXELIB_LOCAL_DIR=%~dp0..\.haxelib
if not exist "%HAXELIB_LOCAL_DIR%" (
    mkdir "%HAXELIB_LOCAL_DIR%"
)

haxelib setup "%HAXELIB_LOCAL_DIR%"
if errorlevel 1 (
    echo ERROR: No se pudo configurar haxelib en modo local.
    pause
    exit /b
)

goto install_libs

:install_libs
echo.
echo Instalando librerias para Psych Engine 0.7.3...
echo.

haxelib --never install flixel 5.5.0
haxelib --never install flixel-addons 3.2.1
haxelib --never install flixel-tools 1.5.1
haxelib --never install flixel-ui 2.5.0
haxelib --never git flxanimate https://github.com/ShadowMario/flxanimate.git dev
haxelib --never git hxCodec https://github.com/polybiusproxy/hxCodec.git
haxelib --never install hxcpp-debug-server 1.2.4
haxelib --never git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc.git
haxelib --never install lime 8.0.1
haxelib --never git linc_luajit https://github.com/superpowers04/linc_luajit.git
haxelib --never install openfl 9.3.2
haxelib --never install tjson 1.4.0

echo Instalando SScript 21.0.0...
if not exist "%~dp0install.py" (
    echo ERROR: Falta el archivo install.py.
    echo Asegurate de que este en la misma carpeta que este script: %~dp0
    pause
    exit /b
)

python "%~dp0install.py" 21.0.0
if errorlevel 1 (
    echo ERROR: Fallo la instalacion de SScript.
    pause
    exit /b
)

goto done

:done
echo.
echo =============================================
echo Configuracion completada para Psych Engine 0.7.3!
echo Librerias instaladas en: %HAXELIB_LOCAL_DIR%
echo =============================================
pause
exit /b

:end
echo Operacion cancelada. Fin del proceso.
pause
exit /b
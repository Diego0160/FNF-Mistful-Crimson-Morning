@echo off
color 0a
title Instalador FNF Psych Engine - Diego


echo ============================
echo  Instalando librerías Haxelib
echo ============================
echo.

haxelib --never install lime
haxelib --never install openfl
haxelib --never install flixel
haxelib --never install flixel-addons
haxelib --never install flixel-ui
haxelib --never install flixel-tools
haxelib --never install SScript
haxelib --never install hxCodec
haxelib --never install tjson

haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc

echo ============================
echo  Todo instalado correctamente
echo ============================
echo.

:: Compilar el juego (opcional)
echo ¿Deseas compilar Psych Engine ahora?
pause
:: Descomenta esta línea si deseas compilar directamente al final:
:: lime test windows -debug

echo.
echo ¡Listo! Puedes compilar el juego con: lime test windows -debug
pause

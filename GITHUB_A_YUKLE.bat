@echo off
title RanaxMM2 GitHub Otomatik Yukleyici
color 0a

echo ===================================================
echo     RANAX MM2 - GITHUB OTOMATIK GUNCELLEYICI
echo       Repo: sapsikxcters/ranax (main)
echo ===================================================
echo.

cd /d "%~dp0"

git add ranax_mmv.lua ranax_key_system.lua
git -c user.name="sapsikxcters" -c user.email="sapsikxcters@users.noreply.github.com" commit -m "Auto update ranax_mmv.lua" >nul 2>&1

echo GitHub'a gonderiliyor...
echo.
git -c credential.helper="" push -u origin main
if errorlevel 1 goto :fail

:success
echo.
echo ===================================================
echo [BASARILI] Kodlar GitHub'a sorunsuz yuklendi!
echo.
echo Loadstring Linkin:
echo loadstring(game:HttpGet("https://raw.githubusercontent.com/sapsikxcters/ranax/main/ranax_mmv.lua"))()
echo ===================================================
echo.
goto :end

:fail
echo.
echo [HATA] Bir sorun olustu, internet baglantini kontrol et.
echo.

:end
pause

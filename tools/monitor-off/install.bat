@echo off
REM Creates a desktop shortcut for monitor-off.bat. Double-click this file.
set "SRC=%~dp0monitor-off.bat"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$n=-join [char[]](0xBAA8,0xB2C8,0xD130,0x20,0xB044,0xAE30); $d=[Environment]::GetFolderPath('Desktop'); $s=(New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path $d ($n+'.lnk'))); $s.TargetPath=$env:SRC; $s.WindowStyle=7; $s.IconLocation=\"$env:SystemRoot\System32\imageres.dll,-1003\"; $s.Save()"
echo.
echo Done! Check your desktop for the new icon.
pause

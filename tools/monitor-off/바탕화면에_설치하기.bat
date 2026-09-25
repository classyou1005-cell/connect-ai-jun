@echo off
chcp 65001 >nul
REM 바탕화면에 "모니터 끄기" 바로가기를 만들어 줍니다. 이 파일을 더블클릭하세요.
set "SRC=%~dp0모니터끄기.bat"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$d=[Environment]::GetFolderPath('Desktop'); $s=(New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path $d '모니터 끄기.lnk')); $s.TargetPath='%SRC%'; $s.WindowStyle=7; $s.IconLocation='%SystemRoot%\System32\imageres.dll,-1003'; $s.Save()"
echo.
echo 완료! 바탕화면에 "모니터 끄기" 아이콘이 생겼습니다.
pause

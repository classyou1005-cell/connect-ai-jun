@echo off
REM 노트북 모니터(화면)만 끄는 프로그램입니다.
REM 컴퓨터는 계속 켜져 있고, 마우스를 움직이거나 키보드를 누르면 화면이 다시 켜집니다.
start "" /min powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Start-Sleep -Milliseconds 500; Add-Type -Namespace W -Name M -MemberDefinition '[DllImport(\"user32.dll\")] public static extern bool PostMessage(int h, int m, int w, int l);'; [W.M]::PostMessage(0xFFFF, 0x0112, 0xF170, 2) | Out-Null"

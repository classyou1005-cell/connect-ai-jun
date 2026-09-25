@echo off
REM Turns off the laptop screen only. Move the mouse or press a key to turn it back on.
start "" /min powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Start-Sleep -Milliseconds 500; Add-Type -Namespace W -Name M -MemberDefinition '[DllImport(\"user32.dll\")] public static extern bool PostMessage(int h, int m, int w, int l);'; [W.M]::PostMessage(0xFFFF, 0x0112, 0xF170, 2) | Out-Null"

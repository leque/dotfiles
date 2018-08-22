reg add ^
  "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" ^
  /v "%programfiles%\VcXsrv\vcxsrv.exe" ^
  /t REG_SZ ^
  /d "~ HIGHDPIAWARE" ^
  /f
pause

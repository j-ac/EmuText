@echo off
:: Build script for Emu LiveText
echo Building server executable...
pyinstaller %cd%\server.py --icon=.\resources\64x64.ico --onefile --name EmuLiveText
move %CD%\dist\EmuLiveText.exe %CD%
rmdir dist
pause

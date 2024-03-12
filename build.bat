@echo off
:: Build script for Emu LiveText
echo Building server executable...
pyinstaller %cd%\server.py --icon=.\resources\64x64.ico
pause
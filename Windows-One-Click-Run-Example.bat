@echo off
:: A script to launch all of Emu LiveText's many moving parts all at once.
:: Replace each path with the path on your own windows system. Certain paths may already be correct.

:: Launch BizHawk and immediately load the ROM and the script
set executable="%USERPROFILE%\Downloads\emulivetext\Bizhawk\BizHawk-2.9.1-win-x64\EmuHawk.exe"
set rom="%USERPROFILE%\Documents\roms\Pokemon Blue (Japan).sgb"
set script="%CD%\game_resources\Pokemon_Blue_JP\BizHawk_text_dump.lua"

:start "" %executable% --lua=%script% %rom%

:: Launch the server, using the appropriate resource folder 
set python="%USERPROFILE%\AppData\Local\Microsoft\WindowsApps\python.exe"
set server="%CD%\server.py"
set resources="%CD%/game_resources/Pokemon_Blue_JP/"

:: install websockets if you do not already have it
%python% -m pip install websockets

:: launch
start "" %python% %server% %resources% %*

:: Launch the local web client
set client="%CD%\EmuText.html"
%client%
pause

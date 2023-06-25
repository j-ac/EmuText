:: A script to launch all of Emu LiveText's many moving parts all at once.
:: Replace each path with the path on your own windows system.

:: Launch BizHawk and immediately load the ROM and the script
set executable="%USERPROFILE%\Documents\EmuText\BizHawk-2.9.1-win-x64\EmuHawk.exe"
set rom="%USERPROFILE%\Documents\EmuText\BizHawk-2.9.1-win-x64\ROM\Pocket Monsters - Blue Version (J) [S].sgb"
set script="%USERPROFILE%\Documents\EmuText\game_resources\Pokemon_Blue_JP\BizHawk_text_dump.lua"

start "" %executable% --lua=%script% %rom%

:: Launch the server minimized, using the appropriate resource folder 
set python="%USERPROFILE%\AppData\Local\Microsoft\WindowsApps\python.exe"
set server="%USERPROFILE%\Documents\EmuText\server.py"
set resources="%USERPROFILE%/Documents/EmuText/game_resources/Pokemon_Blue_JP/"

start /min "" %python% %server% %resources% %*

:: Launch the local web client
set client="%USERPROFILE%\Documents\EmuText\EmuText.html"
%client%

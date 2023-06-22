:: A script to launch all of Emu LiveText's many moving parts all at once.
:: Replace each path with the path on your own windows system.

:: Launch BizHawk and immediately load the ROM and the script
set executable="C:\Users\j-ac\Documents\EmuText\BizHawk-2.9.1-win-x64\EmuHawk.exe"
set rom="C:\Users\j-ac\Documents\EmuText\BizHawk-2.9.1-win-x64\ROM\Pocket Monsters - Blue Version (J) [S].sgb"
set script="C:\Users\j-ac\Documents\EmuText\game_resources\Pokemon_Blue_JP\BizHawk_text_dump.lua"

start "" %executable% --lua=%script% %rom%

:: Launch the server minimized, using the appropriate resource pack 
set python="C:\Users\j-ac\AppData\Local\Microsoft\WindowsApps\python.exe"
set server="C:\Users\j-ac\Documents\EmuText\server.py"
set resources="C:/Users/j-ac/Documents/EmuText/game_resources/Pokemon_Blue_JP/"

start /min "" %python% %server% %resources% %*

:: Launch the local web client
set client="C:\Users\j-ac\Documents\EmuText\EmuText.html"
%client%

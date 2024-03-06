:: A script to launch all of Emu LiveText's many moving parts all at once. Requires BizHawk's location to be set, as well as the ROM location

:: Launch the server and web page
set server=EmuLiveText.exe.lnk
set resources=%cd%\game_resources\Pokemon_Blue_JP

start "" "%server%" "%resources%" %*
start "" EmuText.html

:: Launch BizHawk and immediately load the ROM and the script
::SET THESE TWO TO THE PATH ON YOUR SYSTEM
set bizhawk="path\to\bizhawk\EmuHawk.exe"
set rom="%USERPROFILE%\path\to\roms\Pocket Monsters - Blue Version (J) [S].sgb" 

set script="%resources%\BizHawk_text_dump.lua"

start "" %bizhawk% --lua=%script% %rom%
@ echo off
:: THIS FILE IS FOR USERS OF THE GITHUB RELEASE ONLY
:: A script to launch all of Emu LiveText's many moving parts all at once. Requires a few paths to be set to work.

:: STEP 1
:: ***REPLACE THE GAME HERE WITH THE ONE YOU WANT TO PLAY IN game_resources***
set resources=%cd%\game_resources\Pokemon_Blue_JP

:: STEP 2
:: *** SET THE FOLLOWING PATHS TO THE RELEVANT ONES FOR YOUR SYSTEM ***
set bizhawk="path\to\Bizhawk\EmuHawk.exe"
set rom="path\to\roms\Pokemon Blue (Japan).sgb" 

:: You're Done! Launch this script to begin using Emu LiveText!

:: If you would like to use positional arguments to launch the server to a particular game automatically, change the following line to a shortcut you have configured to do so
set server=%cd%\EmuliveText.exe

start "" "%server%" %resources%
start "" EmuText.html

set script="%resources%\BizHawk_text_dump.lua"
start "" %bizhawk% --lua=%script% %rom%
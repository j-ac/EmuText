# Emu LiveText
A system of programs which allow in-game dialogue to be displayed instantly in a web browser.

![A demonstration of Emu LiveText in Pokemon Crystal. Definition box powered by Yomichan](https://github.com/j-ac/EmuText/assets/83185117/5e53a2aa-9817-40f2-b8d6-9addbc17b46f)

Designed as a tool for studying Japanese, it works great with browser plugins such as [Yomichan](https://foosoft.net/projects/yomichan/), allowing for painless dictionary lookups, or
vocabulary mining by using Yomichan's [Anki](https://apps.ankiweb.net/) integration.

## Getting started using Emu LiveText

Emu LiveText consists of
- The Python server `server.py` or `server.exe`
- A Lua Script for the [BizHawk](https://github.com/TASEmulators/BizHawk/releases) emulator
- The local web page EmuText.html

### Using Emu LiveText
**The easiest way to begin with Emu LiveText is by downloading its latest release** found on the **right hand side of the github page**. That way you do not need Python installed to use the Emu LiveText, and you do not have to launch the program from the commandline. More experienced users may prefer to clone the repository, if they do not care about the previous two conveniences. There is currently no Github Release for Linux, so Linux users must clone.

#### Option 1: Using the Github Release (Windows Only)
1. Download the Github Release (right hand side of the Github Page), and extract the contents.
1. Download the [BizHawk](https://github.com/TASEmulators/BizHawk/releases) emulator.
1. *Reccomended:* To launch all components simultaneously with a script, follow the short instructions in `Release-Windows-One-Click-Run-Example.bat` and skip steps 4 - 6.
1. Open your desired rom in Bizhawk, and run `BizHawk_text_dump.lua` found in `game_resources\GAME_TITLE` by drag-and-dropping it into the Bizhawk window.
1. Launch EmuLiveText.exe and enter the directory to your game's resource folder eg `game_resources\Pokemon_Blue_JP`
1. Open EmuText.html
1. Send text to Emu LiveText with the dump key (Default: G). You may need to refresh the web page once.


#### Option 2: Cloning (Windows or Linux)
Install [Python](https://www.python.org/downloads/) on your local machine if you do not have it already.
1. Clone this repository, and download the [BizHawk](https://github.com/TASEmulators/BizHawk/releases) Emulator.
2. Launch server.py using a games' resource folder as a positional argument. For example:
`./server.py game_resources/Pokemon_Blue_JP`. You will see the following prompt: `Waiting for connection to web client.`
3. To establish a connection, open EmuText.html with a web browser. You should recieve the following prompt on the Python server: `Connection established with web client.`
4. To begin seeing text from game, open BizHawk and load the game you wish to play.
5.  Drag and drop the lua script found in your games' directory within game_resources into BizHawk's window.
Each time you press the dump key (Default: G), text will appear in your web browser.

#### Optional Launch Script
For Windows users, the repo is bundled with a batch file named Windows-One-Click-Run-Example.bat, which allows you to launch each part of Emu LiveText simultaneously. 
*note:* Another File exists called Release-Windows-One-Click-Run.bat, which is only for Github Release users.

Follow the instructions within Windows-One-Click-Run-Example.bat. Now launching this script will directly launch the sever, web client, and Bizhawk with the appropriate ROM and Lua script simultaneously. 

## Getting the most out of Emu LiveText
To make use of instant definition lookups, install [Yomichan](https://foosoft.net/projects/yomichan/). To instantly create Anki flashcards from Yomichan definitions, follow
[these steps](https://foosoft.net/projects/anki-connect/) from Yomichan's official site.

To change the dump key, open the lua file for the desired console in /lib/. Modify the line `DUMP_KEY = "G"` to your desired key.
Special characters are case sensitive and must be written begining with a capital letter eg: "Alt", "Shift", "Ctrl" or "Space"
Be aware that BizHawk uses hotkeys. For instance F will pause the game if used as a dump key. Most keys are unused but can be checked from Config > Hotkeys in Bizhawk.

### Learning More
* RESOURCES.md is located in /game_resources/, and covers the purpose of each resource file needed to add support for new games

## Currently Supported Games
### Gameboy
* Pokemon Blue (ポケットモンスター 青)
* Pokemon Crystal (ポケットモンスター　クリスタルバージョン)
* Pokemon Trading Card Game 2: (ポケモンカードＧＢ２) (Uses kanji!)

### Famicom
* Legend of Zelda (ゼルダの伝説) (cartridge version)
* Mother (Earthbound Beginnings)

**More coming soon! Open a GitHub issue to request new titles!**

## Gallery
![demonstration of Emu LiveText in Pokemon TCG2, showing a Surfing Pikachu, and  a demonstration in Legend of Zelda where link receives his sword and Yomichan shows an inline definition for "Alone"](https://github.com/j-ac/EmuText/assets/83185117/4c404bf8-fa04-451b-af1c-f3367b3bb996)
![A player getting into a battle in Pokemon Red, a player fighting a hippie in Earthbound Zero](https://github.com/j-ac/EmuText/assets/83185117/9a368abe-4f35-498b-a84b-4e770204dd6b)
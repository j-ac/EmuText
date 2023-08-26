# Emu LiveText
A system of programs which allow in-game dialogue to be displayed instantly in a web browser.

![A demonstration of Emu LiveText in Pokemon Crystal. Definition box powered by Yomichan](https://github.com/j-ac/EmuText/assets/83185117/afd11325-9801-43cf-8764-ed9eb0483bde)


Designed as a tool for studying Japanese, it works great with browser plugins such as [Yomichan](https://foosoft.net/projects/yomichan/), allowing for painless dictionary lookups, or
vocabulary mining by using Yomichan's [Anki](https://apps.ankiweb.net/) integration.

## Getting started using Emu LiveText

Emu LiveText consists of
- The Python server `server.py`
- A Lua Script for the [BizHawk](https://github.com/TASEmulators/BizHawk/releases) emulator
- The local web page EmuText.html

### Using Emu LiveText
#### Option 1: Launching manually
1. To begin using Emu LiveText, download this repository, as well as [BizHawk](https://github.com/TASEmulators/BizHawk/releases).
2. Launch server.py using a games' resource folder as a positional argument. For example:
`./server.py game_resources/Pokemon_Blue_JP`. You will see the following prompt: `Waiting for connection to web client.`
3. To establish a connection, open EmuText.html with a web browser. You should recieve the following prompt on the Python server: `Connection established with web client.`
4. To begin seeing text from game, open BizHawk and load the game you wish to play.
5.  Drag and drop the lua script found in your games' directory within game_resources into BizHawk's window.
Each time you press the dump key (Default: G), text will appear in your web browser.

#### Option 2: Launching all components simulatenously with a script
For Windows users, the repo is bundled with a batch file named Windows-One-Click-Run-Example.bat

Replace the paths on any lines beginning with `set` with the relevant paths for your file system. Most of them simply need to be set to the location you cloned the repository into. Now it will directly launch the sever, web client, and Bizhawk with the appropriate ROM and Lua script simultaneously. 

A Bash script example for Linux is planned in the near future.

### Optional
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

### Famicom
* Legend of Zelda (ゼルダの伝説) (cartridge version)
* Mother (Earthbound Beginnings)
#### More coming soon!

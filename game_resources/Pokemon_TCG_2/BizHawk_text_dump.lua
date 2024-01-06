-- Dumps text from Pokemon TCG 2 (ポケモンカードＧＢ２ ＧＲ団参上!)
-- For use with the BizHawk emulator

local BACKGROUND_MEM_START = 0x1800	-- Game specific, but probably common. 
local BACKGROUND_MEM_END = 0x1BFF

local WINDOW_MEM_START = 0x1C00 	-- Game specific, but probably common. 
local WINDOW_MEM_END = 0x1E33

-- Majority of the logic is found in the gameboy library located in /lib/
package.path = "../../lib/?.lua;" .. package.path
local gameboy = require("gameboy")
gameboy.init_memory_positions(BACKGROUND_MEM_START, BACKGROUND_MEM_END, WINDOW_MEM_START, WINDOW_MEM_END)

local needs_dump_tileset = true --indicates this game does tileswapping
gameboy.perform_dumps_forever(needs_dump_tileset)

-- Dumps sprites from Pokemon TCG 2 (ポケモンカードＧＢ２ ＧＲ団参上!)
-- This script dumps sprites into json format. To view the sprites easily, use an editor to find and replace all newline escape sequences '\n' to newline literals.
-- THIS IS NOT THE SCRIPT THAT DRIVES EMULIVETEXT
-- For use with the BizHawk emulator

local remove_grey_sprites = true
local start_tile = 128
local num_sprites = 256

package.path = "../../lib/?.lua;"
local dumper = require("gameboy_tile_dump")

dumper.dump_sprites_forever(remove_grey_sprites, start_tile, num_sprites)

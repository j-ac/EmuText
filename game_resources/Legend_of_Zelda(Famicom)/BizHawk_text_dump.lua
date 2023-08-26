-- Dumps text from Legend of Zelda for Famicom (Full title: Zelda no Densestu 1 - The Hyrule Fantasy)
-- For use with the BizHawk emulator

-- This game always uses horizontal mirroring
function get_mirroring()
	return "H"
end

package.path = "../../lib/?.lua;" .. package.path
local nes = require("nes")
nes.perform_dumps_forever(get_mirroring)

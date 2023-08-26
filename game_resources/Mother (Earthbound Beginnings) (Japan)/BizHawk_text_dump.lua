-- Dumps text from Mother 1 (Known as Earthbound Beginnings outside Japan)
-- For use with the BizHawk emulator

-- The NES does not have a standardized way to represent the mirroring type, nor is it strictly limited to vertical and horizontal types.
-- 0x00F0 usually corresponds to the mirroring type in Mother 1
function get_mirroring()
	if memory.read_u8(0x00F0, "RAM") == 120 then 
		return "H"
	else
		return "V"
	end
end

-- The bulk of the code is located in /lib/nes.lua
package.path = "../../lib/?.lua;" .. package.path
local nes = require("nes")
nes.perform_dumps_forever(get_mirroring)

-- Dumps text from Mother 1 (Known as Earthbound Beginnings outside Japan)
-- For use with the BizHawk emulator

-- The NES hardware adds unique complications to text dumping, so this file will be much less 
-- approachable than the scripts made for GameBoy games, for example.
--
-- Resources to help understand the content of this script:
-- https://www.youtube.com/watch?v=3uzcN9PHZZs
-- https://www.youtube.com/watch?v=wfrNnwJrujw
-- https://www.nesdev.org/wiki/PPU_nametables
-- https://www.nesdev.org/wiki/PPU_registers (Particularly the register 2000 and 2005 content)

DUMP_KEY = "G" -- Change this to rebind the dump key. Be aware of conflicting BizHawk shortcuts.
client.displaymessages(false) -- Prevents obnoxious messages from getting in your screenshot

local SCREEN_WIDTH_PIXELS = 256
local SCREEN_HEIGHT_PIXELS = 240
local row_length = 32 --in tiles, 256 pixels / 8 tiles per pixel
local num_rows = 30   --in tiles, 240/8

local combined_nametable_row_length = row_length * 2 -- When nametables are arranged in a 2x2 grid
local combined_nametable_num_rows = num_rows * 2 -- When arranged in 2x2 grid

-- Event-Driven storage of scroll position
-- this cannot be done by simply dumping these values from the bus, as they do not represent the same thing at all times.
-- This is not game-specific, and can be used elsewhere. Thank you to github.com/CasualPokePlayer for this section.
local reg_2000 = 0
local reg_2005_x = 0
local reg_2005_y = 0
local reg_2005_toggle

event.on_bus_write(function(addr, val, flags)
    reg_2000 = val
end, 0x2000, "hook_2000")

event.on_bus_write(function(addr, val, flags)
    if not reg_2005_toggle then
        reg_2005_x = val
        reg_2005_toggle = true
    else
        reg_2005_y = val
        reg_2005_toggle = false
    end
end, 0x2005, "hook_2005")

-- The NES does not have a standardized way to represent the mirroring type, nor is it strictly limited to vertical and horizontal types.
-- 0x00F0 usually corresponds to the mirroring type in Mother 1
function get_mirroring()
	if memory.read_u8(0x00F0, "RAM") == 120 then 
		return "H"
	else
		return "V"
	end
end

-- UNCOMMENT TO DISPLAY SCROLL POSITION WHEN IT Y CHANGES (DEBUG)
--------------------------------------------------------------------
--local old_reg_2005_y = 0
--while true do
--	scroll_bit_x = reg_2000 & 0x1
--	scroll_bit_y = reg_2000 & 0x2 
--
--	if reg_2005_y ~= old_reg_2005_y	then
--		print(reg_2000)
--		old_reg_2005_y = reg_2005_y
--		print("x: " .. reg_2005_x .. " scroll:" .. scroll_bit_x)
--		print("y: " .. reg_2005_y .. " scroll:" .. scroll_bit_y)
--	end
--	emu.frameadvance();
--end
--------------------------------------------------------------------

while true do
	local keys = input.get()
	if keys[DUMP_KEY] == true then
		client.screenshot("out.png")
		print("sent screenshot")
			
		memory.usememorydomain("CIRAM (nametables)")
		nametable_size = 960 -- in bytes
		nametable_size_with_padding = 960 + 64 -- in bytes, includes 64 byte attribute table (pallete data)

		-- ====================================
		-- = ARRANGE NAMETABLES INTO 2x2 GRID =
		-- ====================================
		if get_mirroring() == "V" then
			nametable_top_left = memory.read_bytes_as_array(0x0, nametable_size)
			nametable_top_right = memory.read_bytes_as_array(nametable_size_with_padding, nametable_size)		
			nametable_bottom_left = nametable_top_left --mirror
			nametable_bottom_right = nametable_top_right --mirror

		elseif get_mirroring() == "H" then
			nametable_top_left = memory.read_bytes_as_array(0x0, nametable_size)
			nametable_bottom_left = memory.read_bytes_as_array(nametable_size_with_padding, nametable_size)
			nametable_top_right = nametable_top_left --mirror
			nametable_bottom_right = nametable_bottom_left --mirror
		else
			print("Invalid mirroring type found: " .. get_mirroring())
		end

		-- ==============================================
		-- = STITCH NAMETABLES INTO A SINGLE DICTIONARY =
		-- ==============================================
		-- eg (vertical mirroring example):
		--    A B     C D                 A B C D 
		--    E F     G H                 E F G H
		--                    =======>    A B C D  
		--    A B     C D                 E F G H
		--    E F     G H
		--
		-- The resultant dictionary is 1-Dimensional, but can be interpreted as a 2-D image by assuming rows
		-- match the NES' fixed width of 32 tiles
	
		combined_nametables = {}
		for i= 0, num_rows-1 do
			for j = 1, row_length do
				table.insert(combined_nametables, nametable_top_left[i * row_length + j])
			end
			for j = 1, row_length do
				table.insert(combined_nametables, nametable_top_right[i * row_length + j])
			end
		end
	
		for i= 0, num_rows-1 do
			for j = 1, row_length do
				table.insert(combined_nametables, nametable_bottom_left[i * row_length + j])
			end
			for j = 1, row_length do
				table.insert(combined_nametables, nametable_bottom_right[i * row_length + j])
			end
		end

-- UNCOMMENT TO CREATE A DUMP OF THE COMBINED NAMETABLES FOR DEBUGGING PURPOSES
-----------------------------------------------------------------------------------------------------------------
--		local f = io.open("combined_nametables.txt", "w")
--		io.output(f)
--		for i = 1, #combined_nametables do
--			io.write(string.format("%4d", combined_nametables[i]) .. ", ")
--			if (i % (2 * row_length) == 0) then --Makes one row in the dump correspond to one row in the viewport
--				io.write("\n")
--			end
--		end
--		io.close()
------------------------------------------------------------------------------------------------------------------
--
		-- =========================================================================================
		-- = EXTRACT THE VISABLE PORTION OF THE SCREEN FROM THE DICTIONARY USING THE SCROLL VALUES =
		-- =========================================================================================
		scroll_bit_x = reg_2000 & 0x1
		scroll_bit_y = (reg_2000 & 0x2) >> 1
		scroll_bits = reg_2000 & 0x3
	
		scroll_x = (reg_2005_x + scroll_bit_x * SCREEN_WIDTH_PIXELS) / 8
		scroll_y = (reg_2005_y + scroll_bit_y * SCREEN_HEIGHT_PIXELS) / 8

		viewport = {}
		for i = 0, (SCREEN_HEIGHT_PIXELS /8) -1 do
			for j = 0, (SCREEN_WIDTH_PIXELS/8) -1 do
				row_num = (i + scroll_y) % combined_nametable_num_rows
				col_num = (j + scroll_x) % (combined_nametable_row_length)
				location = row_num * combined_nametable_row_length + col_num + 1
				viewport[i * (SCREEN_WIDTH_PIXELS/8) + j + 1] = combined_nametables[location]
			end
		end

		-- ===============
		-- === FILE IO ===
		-- ===============
		local f = io.open("dump.txt", "w")
		io.output(f)
		for i = 1, #viewport do
			io.write(string.format("%4d", viewport[i]) .. ", ")
			if (i % row_length == 0) then --Makes dump have NES screen dimensions for readability
				io.write("\n")
			end
		end
		io.close()

	end
		emu.frameadvance()
end

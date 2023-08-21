-- Dumps text from Pokemon Crystal (GBC) in both the American and Japanese versions.
-- For use with the BizHawk emulator

local DUMP_KEY = "G"				-- Key which triggers a text dump
client.displaymessages(false) 			-- prevents obnoxious text printouts from getting in your screenshot
memory.usememorydomain("VRAM")			-- Defines which section of memory the memory API accesses, indexed from 0x0

local BACKGROUND_MEM_START = 0x1800	-- Game specific, but probably common. 
local BACKGROUND_MEM_END = 0x1BFF
local BACKGROUND_LENGTH = BACKGROUND_MEM_END - BACKGROUND_MEM_START

local WINDOW_MEM_START = 0x1C00 	-- Game specific, but probably common. 
local WINDOW_MEM_END = 0x1E33
local WINDOW_LENGTH = WINDOW_MEM_END - WINDOW_MEM_START

local TILE_MAP_WIDTH = 32
local TILE_MAP_HEIGHT = 32

local ROW_LENGTH = 20 --Tiles
local NUM_ROWS = 18

function window_is_rendered()
	local LCD_control = memory.read_u8(0xFF40, "System Bus")
	local window_enabled = (LCD_control & 32)  >> 5 -- bitmasking for bit 00100000

	local y_pos = memory.read_u8(0xFF4A, "System Bus")
	local x_pos = memory.read_u8(0xFF4B, "System Bus")
	return window_enabled and y_pos <= 143 and x_pos <= 166 
end

while true do
	local keys = input.get()
	if keys[DUMP_KEY] == true then
		client.screenshot("out.png")
		print("sent screenshot")

		if window_is_rendered() then
			viewport = memory.read_bytes_as_array(WINDOW_MEM_START, WINDOW_LENGTH)
		else
			tile_map = memory.read_bytes_as_array(BACKGROUND_MEM_START, BACKGROUND_LENGTH)
			scroll_y = memory.read_u8(0xFF42, "System Bus") /8
			scroll_x = memory.read_u8(0xFF43, "System Bus") /8 --should it be plus 1 then divided by 8?

			viewport = {}
			debug_str = ""
			for i = 1, NUM_ROWS do
				for j = 1, ROW_LENGTH do
					col_num = (j + scroll_x) % (TILE_MAP_WIDTH + 1)
					row_num = (i + scroll_y) % TILE_MAP_HEIGHT
	--				debug_str = debug_str .. "col: " .. col_num .. "row: " .. row_num .. "\n"

					location = row_num * TILE_MAP_WIDTH + col_num
					debug_str = debug_str .. string.format("%x", location + BACKGROUND_MEM_START) .. " "

					viewport[(i-1) * ROW_LENGTH + j] = tile_map[location]
				end
			end

		end
		print(debug_str)

		-- ===============
		-- === FILE IO ===
		-- ===============
		local f = io.open("dump.txt", "w")
		io.output(f)
		for i = 1, #viewport
		do
			io.write(string.format("%4d", viewport[i]) .. ", ")
			if i % ROW_LENGTH == 0 then
				io.write("\n")
			end
		end
		io.close()

	end
	emu.frameadvance() -- otherwise the script hogs CPU and starves the game
end

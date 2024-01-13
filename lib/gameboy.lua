local misc = require("misc")

local gameboy = {}
print("Gameboy libary imported")

DUMP_KEY = "G"				-- Key which triggers a text dump
client.displaymessages(false) 			-- prevents obnoxious text printouts from getting in your screenshot
memory.usememorydomain("VRAM")			-- Defines which section of memory the memory API accesses, indexed from 0x0
TILE_MAP_WIDTH = 32			--width of the entire VRAM space, not only viewport
TILE_MAP_HEIGHT = 32

ROW_LENGTH = 20 --tiles in the viewport
NUM_ROWS = 18

-- PanDocs 4.2 explains particulars of Gameboy Color.
GBC_INFO_BLOCK_START = 0x3800
GBC_INFO_BLOCK_END = 0x3BFF
GBC_INFO_BLOCK_LENGTH = GBC_INFO_BLOCK_END - GBC_INFO_BLOCK_START

gameboy.init_memory_positions = function(bg_start, bg_end, win_start, win_end)
	BACKGROUND_MEM_START = bg_start
	BACKGROUND_MEM_END = bg_end
	BACKGROUND_LENGTH = bg_end - bg_start

	WINDOW_MEM_START = win_start
	WINDOW_MEM_END = win_end
	WINDOW_LENGTH = win_end - win_start
end

function window_is_rendered()
	LCD_control = memory.read_u8(0xFF40, "System Bus")
	window_enabled = (LCD_control & 32)  >> 5 == 1-- bitmasking for bit 00100000
	y_pos = memory.read_u8(0xFF4A, "System Bus")
	x_pos = memory.read_u8(0xFF4B, "System Bus")

	return window_enabled and y_pos <= 143 and x_pos <= 166 
end

function send_to_file(viewport)
	local f = io.open("dump.txt", "w")
	io.output(f)
	for i = 1, #viewport
	do
		if viewport[i] == nil then viewport[i] = 0 end -- Shouldn't be necessary, yet crashes without it
		io.write(string.format("%4d", viewport[i]) .. ", ")
		if i % ROW_LENGTH == 0 then
			io.write("\n")
		end
	end
	io.close(f)
end


-- Dump 
-- Most information required to understand this is in PanDocs section 4.1
function dump_tileset()
	local TILES_PER_BANK = 384
	local SPRITE_SIZE = 16

	local BLOCK_0_END = 0x07FF
	local BLOCK_1_END = 0x0FFF
	local BLOCK_2_END = 0x17FF

	-- detect indexing mode
	local is_unsigned = misc.extract(memory.read_u8(0xFF40, "System Bus"), 4) == 1


	-- See Panda Docs 4.1 Table 1
	local f = io.open("active_sprites.txt", "w")
	io.output(f)
	if is_unsigned then
		for i= 0, BLOCK_0_END, SPRITE_SIZE do
			io.write(misc.byte_array_to_string(memory.read_bytes_as_array(i, SPRITE_SIZE)) .. "\n")
		end 
	else
		for i = BLOCK_1_END + 1, BLOCK_2_END, SPRITE_SIZE do			
			io.write(misc.byte_array_to_string(memory.read_bytes_as_array(i, SPRITE_SIZE)) .. "\n")
		end
	end

	-- This section is identical between both indexing schemes.
	for i = BLOCK_0_END + 1, BLOCK_1_END, SPRITE_SIZE do
			debug_str = debug_str .. string.format("%04X", i) .. "\n"
			io.write(misc.byte_array_to_string(memory.read_bytes_as_array(i, SPRITE_SIZE)) .. "\n")	
	end
	
	io.close(f)

end

gameboy.perform_dumps_forever = function(needs_dump_tileset)
	if needs_dump_tileset == nil then needs_dump_tileset = false end -- Optional argument for games that use tile swapping.
	while true do
		local keys = input.get()
		if keys[DUMP_KEY] == true then
			client.screenshot("out.png")
			print("sent screenshot")

			if needs_dump_tileset then -- On games with tile swapping
				dump_tileset()
			end

			-- PanDocs 4.2
			local GAMEBOY_COLOR = true
			if GAMEBOY_COLOR then
				GBC_tile_info = memory.read_bytes_as_array(GBC_INFO_BLOCK_START, GBC_INFO_BLOCK_LENGTH)
			end

			if window_is_rendered() then
				tile_map = memory.read_bytes_as_array(WINDOW_MEM_START, WINDOW_LENGTH)
				scroll_y = 0
				scroll_x = 0
			else
				tile_map = memory.read_bytes_as_array(BACKGROUND_MEM_START, BACKGROUND_LENGTH)
				scroll_y = memory.read_u8(0xFF42, "System Bus") /8
				scroll_x = memory.read_u8(0xFF43, "System Bus") /8 
			end

			viewport = {}
			debug_str = ""
			for i = 0, NUM_ROWS -1 do
				for j = 1, ROW_LENGTH do
					col_num = (j + scroll_x) % TILE_MAP_WIDTH
					row_num = (i + scroll_y) % TILE_MAP_HEIGHT

					location = row_num * TILE_MAP_WIDTH + col_num

					local tile_in_bank_2 = misc.extract(GBC_tile_info[location], 4) == 1
					if not tile_in_bank_2 then 
						viewport[i * ROW_LENGTH + j] = tile_map[location]
					else
						viewport[i* ROW_LENGTH + j] = 0 -- It is assumed fonts never go in Bank 2
					end
				end
			end
			send_to_file(viewport)
		end
		emu.frameadvance() -- otherwise the script hogs CPU and starves the game
	end
end

return gameboy

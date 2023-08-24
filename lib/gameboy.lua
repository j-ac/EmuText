local gameboy = {}
print("Gameboy libary imported")

DUMP_KEY = "G"				-- Key which triggers a text dump
client.displaymessages(false) 			-- prevents obnoxious text printouts from getting in your screenshot
memory.usememorydomain("VRAM")			-- Defines which section of memory the memory API accesses, indexed from 0x0
TILE_MAP_WIDTH = 32			--width of the entire VRAM space, not only viewport
TILE_MAP_HEIGHT = 32

ROW_LENGTH = 20 --tiles in the viewport
NUM_ROWS = 18

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
	window_enabled = (LCD_control & 32)  >> 5 -- bitmasking for bit 00100000
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
	io.close()
end

gameboy.perform_dumps_forever = function()
	while true do
		local keys = input.get()
		if keys[DUMP_KEY] == true then
			client.screenshot("out.png")
			print("sent screenshot")

			if window_is_rendered() then
				tile_map = memory.read_bytes_as_array(WINDOW_MEM_START, WINDOW_LENGTH)
				scroll_y = 0
				scroll_x = 0
			else
				tile_map = memory.read_bytes_as_array(BACKGROUND_MEM_START, BACKGROUND_LENGTH)
				scroll_y = memory.read_u8(0xFF42, "System Bus") /8
				scroll_x = memory.read_u8(0xFF43, "System Bus") /8 --should it be plus 1 then divided by 8?
			end
				viewport = {}
				debug_str = ""
				for i = 0, NUM_ROWS -1 do
					for j = 1, ROW_LENGTH do
						col_num = (j + scroll_x) % (TILE_MAP_WIDTH)
						row_num = (i + scroll_y) % TILE_MAP_HEIGHT

						location = row_num * TILE_MAP_WIDTH + col_num

						viewport[(i) * ROW_LENGTH + j] = tile_map[location]
					end
				end
			send_to_file(viewport)
		end
		emu.frameadvance() -- otherwise the script hogs CPU and starves the game
	end
end

return gameboy

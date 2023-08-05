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

function get_mirroring()
	if memory.read_u8(0x00F0, "RAM") == 120 then 
		return "H"
	else
		return "V"
	end
end

--local old_reg_2005_y = 0
--while true do
--	scroll_bit_x = reg_2000 & 0x1
--	scroll_bit_y = reg_2000 & 0x2 

--	if reg_2005_y ~= old_reg_2005_y	then
--		print(reg_2000)
--		old_reg_2005_y = reg_2005_y
--		print("x: " .. reg_2005_x .. " scroll:" .. scroll_bit_x)
--		print("y: " .. reg_2005_y .. " scroll:" .. scroll_bit_y)
--	end

--	emu.frameadvance();
--end


	memory.usememorydomain("CIRAM (nametables)")
	nametable_size = 960 --bytes, the data I want
	nametable_size_with_padding = 960 + 64 --bytes, includes attribute table (pallete data)

	-- ARRANGE NAMETABLES INTO 2x2 GRID
	if get_mirroring() == "V" then
		nametable_top_left = memory.read_bytes_as_array(0x0, nametable_size)
		nametable_top_right = memory.read_bytes_as_array(nametable_size_with_padding, nametable_size)		
		nametable_bottom_left = nametable_top_left --mirror
		nametable_bottom_right = nametable_top_right --mirror

	elseif get_mirroring == "H" then
		nametable_top_left = memory.read_bytes_as_array(0x0, nametable_size)
		nametable_bottom_left = memory.read_bytes_as_array(nametable_size_with_padding, nametable_size)
		nametable_top_right = nametable_top_left --mirror
		nametable_bottom_right = nametable_bottom_left --mirror
	else
		print("Invalid mirroring type found: " .. get_mirroring())
	end


	-- STITCH NAMETABLES INTO A SINGLE DICTIONARY
	-- eg (vertical mirroring example):
	--    A B     C D                 A B C D 
	--    E F     G H                 E F G H
	--                    =======>    A B C D  
	--    A B     C D                 E F G H
	--    E F     G H
	--
	-- The resultant dictionary is 1-Dimensional, but can be interpreted as a 2-D image by assuming rows
	-- match the NES' fixed width of 32 tiles

	row_length = 32
	num_rows = 30
	combined_nametables = {}
	for i= 0, num_rows do
		for j = 1, row_length do
			table.insert(combined_nametables, nametable_top_left[i * row_length + j])
		end
		for j = 1, row_length do
			table.insert(combined_nametables, nametable_top_right[i * row_length + j])
		end
	end
	
	for i= 0, num_rows do
		for j = 1, row_length do
			table.insert(combined_nametables, nametable_bottom_left[i * row_length + j])
		end
		for j = 1, row_length do
			table.insert(combined_nametables, nametable_bottom_right[i * row_length + j])
		end
	end

	-- EXTRACT THE VISABLE PORTION OF THE SCREEN FROM THE DICTIONARY USING THE SCROLL VALUES
	scroll_bit_x = reg_2000 & 0x1
	scroll_bit_y = (reg_2000 & 0x2) >> 1
	scroll_bits = reg_2000 & 0x3

	SCREEN_WIDTH_PIXELS = 256
	SCREEN_HEIGHT_PIXELS = 240
	scroll_x = (reg_2005_x + scroll_bit_x * SCREEN_WIDTH_PIXELS) / 8
	scroll_y = (reg_2005_y + scroll_bit_y * SCREEN_HEIGHT_PIXELS) / 8

	viewport = {}
	errs = 0
	debug_string = ""
	for i = 1, SCREEN_HEIGHT_PIXELS /8 do
		for j = 1, SCREEN_WIDTH_PIXELS/8 do
			location = ((i+scroll_y) % (SCREEN_HEIGHT_PIXELS / 8)) * (SCREEN_WIDTH_PIXELS / 8) + ((j + scroll_x) % (SCREEN_WIDTH_PIXELS/8))
			--debug_string = debug_string .. "i: " .. i .. " j: " .. j .. " loc: " .. location .. "\n"
--			print("saving to " .. (i-1) * SCREEN_WIDTH_PIXELS + j)
			viewport[(i-1) * (SCREEN_WIDTH_PIXELS/8) + j] = combined_nametables[location]
		end
	end
	print(debug_string)
	
	print(#viewport)
	local f = io.open("dump.txt", "w")
	io.output(f)
	for i = 1, #viewport do
		io.write(tostring(viewport[i]) .. ", ")
	end
	io.close()

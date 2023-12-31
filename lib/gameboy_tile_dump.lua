-- Library to assist in dumping tile data (such as fonts) from gameboy and gameboy color games to JSON

-- Games that "hotswap" tiles during execution cannot be used with EmuLiveText under simpler strategies used in games like Pokemon Blue, because the strategies in those games assume that the font data remains in a fixed location in the tilebank
-- Games that use kanji such as Pokemon TCG 2 must hotswap tiles as the bank is simply too small to hold all kanji data concurrently.

-- Once font data is stored in JSON, and meanings are mapped between data in VRAM and corresponding UTF-8 characters, EmuLiveText's Python server can interpret dynamically changing data.

json = dofile "./json.lua"
memory.usememorydomain("VRAM")
output_file = "tiles.json"

local DUMP_KEY = "J"
BYTE_SIZE = 8
SPRITE_SIZE = 2 * BYTE_SIZE --bytes
START_TILE = 320 -- Tile number
NUM_SPRITES = 64 -- number of sprites in contiguous memory from the starting tile.

DUMP_START = SPRITE_SIZE * START_TILE
DUMP_END = DUMP_START + NUM_SPRITES * SPRITE_SIZE


--brkpnt = true
--while brkpnt do
--	emu.frameadvance()
--end

-- Loads in a json file and converts it into a dictionary using "data" as its key
function decode_json()
	ret = {}

	f = io.open(output_file)
	if f then
		for line in f:lines() do
			if line ~= "\n" then 
			local tbl = json.decode(line)
			ret[tbl["data"]] = {picture=tbl["picture"], character=tbl["character"]}
			end
		end
	end

	return ret
end
sprite_data = decode_json()



function extract(number, index)
	local mask = 2^(index-1)
	--if mask == nil or mask > 32 or mask < 0 then print(mask) end
	return number & mask == mask and 1 or 0
end

-- A helper function for interpret_sprite() that interprets a single line
function interpret_line(first_byte, second_byte)
	pixels_clean = {}
	for i = 1, BYTE_SIZE do
		pixels_clean[i] = extract(first_byte, i) + extract(second_byte, i) * 2
	end

	return pixels_clean
end

-- Turn a sprite byte array into a string of human-readable UTF-8 characters ▒▓█

num_pics = 0 -- DEBUG
function interpret_sprite(data)
	local pic = "\n"

	for i = 1, #data, 2 do
		local row = interpret_line(data[i], data[i+1])
		for j = #row, 1, -1 do
			if row[j] == 3 then
				pic = pic .. "██"
			elseif row[j] == 2 then
				pic = pic .. "▓▓"
			elseif row[j] == 1 then
				pic = pic .. "▒▒"
			elseif row[j] == 0 then
				pic = pic .. "  "
			end
		end
		pic = pic .. "\n"
	end


	-- DEBUG
--	if num_pics % 1 == 0 then
--		print(pic)
--		print (byte_array_to_string(data))
--	end
--	num_pics = num_pics + 1
	-- DEBUG

	return pic
end

function byte_array_to_string(arr)
	ret = ""
	for byte = 1, #arr do
		ret = ret .. string.format("%02X", arr[byte])
	end
	return ret
end

while true do
	for i=DUMP_START, DUMP_END - SPRITE_SIZE, SPRITE_SIZE do -- For each sprite
		bytes = memory.read_bytes_as_array(i, SPRITE_SIZE)
		as_string = byte_array_to_string(bytes)

		if sprite_data[as_string] == nil then
			sprite_data[as_string] = {picture = interpret_sprite(bytes), character = ""}
		end
	end


	local keys = input.get()
	if keys[DUMP_KEY] == true then
		local f = io.open(output_file, "wb")
		io.output(f)

		for key, val in pairs(sprite_data) do
			out_str = json.encode({
			data = key,
			picture = val.picture,
			character = val.character})
			io.write(out_str .. "\n")
		end

		io.close()
		print("Successfully wrote to ".. output_file)
	end

	emu.frameadvance()

end

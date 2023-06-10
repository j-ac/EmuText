-- Dumps text from Pokemon Blue (GBC)
-- For use with the BizHawk emulator


local DUMP_KEY = "G"				-- Key which triggers a text dump
memory.usememorydomain("VRAM")			-- Defines which section of memory the memory API accesses, indexed from 0x0
local POSITION_IN_VRAM = 0x1C00
local TEXT_LENGTH_BYTES = 0x500			-- You know what this means

while true
do
	local keys = input.get()
	if keys[DUMP_KEY] == true
	then
		mem = memory.read_bytes_as_array(POSITION_IN_VRAM, TEXT_LENGTH_BYTES)

		-- ===============
		-- === FILE IO ===
		-- ===============
		local f = io.open("dump.txt", "w")
		io.output(f)
		for i = 1, #mem
		do
			io.write(tostring(mem[i]) .. ", ")
		end
		io.close()

	end
	emu.frameadvance() -- otherwise the script hogs CPU and starves the game
end
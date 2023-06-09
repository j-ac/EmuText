-- Dumps text from Pokemon Crystal (GBC) in both the American and Japanese versions.
-- For use with the BizHawk emulator


local DUMP_KEY = "G"				-- Key which triggers a text dump
memory.usememorydomain("VRAM")			-- Defines which section of memory the memory API accesses, indexed from 0x0
local VRAM_MEMORY_START = 0x8000		-- Absolute position of the memory domain
local TEXT_MEMORY_START = 0x9800		-- Position that text begins (in a global frame of reference, not within the domain)
local POSITION_IN_VRAM = TEXT_MEMORY_START - VRAM_MEMORY_START -- Position relative to the memory domain, required by BizHawk's API
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
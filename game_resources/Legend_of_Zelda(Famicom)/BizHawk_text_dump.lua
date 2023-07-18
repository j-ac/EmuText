-- Dumps text from Legend of Zelda for Famicom (Full title: Zelda no Densestu 1 - The Hyrule Fantasy)
-- For use with the BizHawk emulator

local DUMP_KEY = "G"				-- Key which triggers a text dump
memory.usememorydomain("CIRAM (nametables)")	-- Defines which section of memory the memory API accesses indexed from 0x0
local POSITION_IN_CIRAM = 0x0090
local TEXT_LENGTH_BYTES = 0x260
client.displaymessages(false) 			-- prevents obnoxious text printouts from getting in your screenshot

while true
do
	local keys = input.get()
	if keys[DUMP_KEY] == true
	then
		mem = memory.read_bytes_as_array(POSITION_IN_CIRAM, TEXT_LENGTH_BYTES)
		client.screenshot("out.png")
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
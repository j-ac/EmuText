-- This script was originally written for the VBArr emulator, which I am not planning to support.
-- earlier iterations of the project used this, and it (probably) still works, but Bizhawk will be my targeted
-- platform in the future.
while true do
	if ((joypad.get(0)["left"]) == true) then
	mem = memory.readbyterange(0x9800, 0x500)
	f = io.open("dump.txt", "w")
	f:write(tostring(mem))
	end
	vba.frameadvance()
end
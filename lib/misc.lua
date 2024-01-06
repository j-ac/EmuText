-- Miscellaneous functions which may be relevant to any platform or context

local misc = {}

-- Returns the bit at position `index` in a `number`
function misc.extract(number, index)
	local mask = 2^(index-1)
	return number & mask == mask and 1 or 0
end

-- Given an array of bytes, return a string which concatenates their hex values successively
function misc.byte_array_to_string(arr)
	local ret = ""
	for byte = 1, #arr do
		ret = ret .. string.format("%02X", arr[byte])
	end
	return ret
end

return misc
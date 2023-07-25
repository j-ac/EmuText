-- ======================================
-- === HIRAGANA VALUE RELATIVE SEARCH ===
-- ======================================
-- Automatically finds candidates for mappings between hex values and hiragana characters
-- Used to create thingy tables. Entering the output from this into thingy_tbl_generator.lua generates a table likely to be close to the correct table. May require some adjustments and old games often make unusual encoding choices

-- Create Form
local form_width = 400;
local form_height = 200;
handle = forms.newform(form_width, form_height, "Value Relative Search");

-- Text Box
local text_box_width = 200
local text_box_height = 16
local text_box_x_pos = form_width/2 - text_box_width * (1/2) 
local text_box_y_pos = form_height * (2/3) - text_box_height/2
input = forms.textbox(handle, "よ,う,こ,そ", text_box_width, text_box_height, nil, text_box_x_pos, text_box_y_pos, false, false)

-- Button
local button_width = 50
local button_height = 16
local button_x_pos = form_width/2 - button_width * (2/3)
local button_y_pos = form_height * (2/3) - button_height * (1/2) + text_box_height + 15 
button = forms.button(handle, "Search", relative_search, button_x_pos, button_y_pos)

-- Dropdown
memory_domains = memory.getmemorydomainlist()
dropdown = forms.dropdown(handle, memory_domains)

-- Label
label_width = 300 
label_height = 120
label_x_pos = form_width/2 - label_width * (1/2)
label_y_pos = form_height * (1/2) - label_height * (1/2)
forms.label(handle, "Select a memory domain, and your comma separated text search. Find a segment of uninterupted hiragana text containing no diacritics. Longer strings are less likely to have false positives. Candidates are printed to the Lua console", label_x_pos, label_y_pos, label_width, label_height)

local hiragana = {
        ["あ"] = 1, ["い"] = 2, ["う"] = 3, ["え"] = 4, ["お"] = 5,
        ["か"] = 6, ["き"] = 7, ["く"] = 8, ["け"] = 9, ["こ"] = 10,
        ["さ"] = 11, ["し"] = 12, ["す"] = 13, ["せ"] = 14, ["そ"] = 15,
        ["た"] = 16, ["ち"] = 17, ["つ"] = 18, ["て"] = 19, ["と"] = 20,
        ["な"] = 21, ["に"] = 22, ["ぬ"] = 23, ["ね"] = 24, ["の"] = 25,
        ["は"] = 26, ["ひ"] = 27, ["ふ"] = 28, ["へ"] = 29, ["ほ"] = 30,
        ["ま"] = 31, ["み"] = 32, ["む"] = 33, ["め"] = 34, ["も"] = 35,
        ["や"] = 36, ["ゆ"] = 37, ["よ"] = 38,
        ["ら"] = 39, ["り"] = 40, ["る"] = 41, ["れ"] = 42, ["ろ"] = 43,
        ["わ"] = 44, ["を"] = 45, ["ん"] = 46,
    }

function relative_search()
	-- Load in the memory dump
	local mem_domain = forms.gettext(dropdown)
	local domain_size = memory.getmemorydomainsize(mem_domain)
	local memory_dump = memory.read_bytes_as_array(0, domain_size, mem_domain)

	-- Interpret the query as an array of relative distances relative to the first value
	-- eg  4, 5, 1  -> 0, 1, -3
	-- because 4+0=4; 4+1=5; 4-3=1 
	local query = forms.gettext(input)
	local hiragana_dict = bizstring.split(query, ",")
	local relative_distances = {}
	for i,c in pairs(hiragana_dict) do
		relative_distances[i] = hiragana[c] - hiragana[hiragana_dict[1]]
	end

	-- Search
	local found_candidate = false
	for i=1, #memory_dump, 1 do
		local sequence_length = 0
		for j=1,#relative_distances, 1 do
			if j > #memory_dump then break end
			if (memory_dump[i] + relative_distances[j] == memory_dump[j + i - 1]) then
				sequence_length = sequence_length + 1
			end
		end
		if sequence_length == #relative_distances then -- if we could follow the entire sequence
			print("value 0x" .. bizstring.hex(memory_dump[i]) .. " might be " .. hiragana_dict[1])
			found_candidate = true
		end
	end

	if found_candidate == false then
		print("No candidates found. Try other strings or changing memory domains. If problem persists the ROM may use a highly unusual encoding scheme such as two-byte")
	end
end

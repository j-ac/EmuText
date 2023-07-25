-- ==============================
-- === THINGY TABLE GENERATOR ===
-- ==============================
-- Generates .tbl files based off knowledge about a single character's encoding
-- Assumes the game uses Gojuon "Japanese alphabetical order".
-- Errors can occur on characters that deviate from Gojuon. Adjustments will probably be necessary.
-- Figure out the errors by loading the .tbl file into Bizhawk's hex editor and identifying where it renders text incorrectly. Make changes, reload, and hunt the errors.
-- This script APPENDS to an existing table, so you can run it twice, once for hiragana and once for katakana. This also means you may want to delete the table before regenerating depending on your circumstances.

-- Create Form
local form_width = 200;
local form_height = 100;
handle = forms.newform(form_width, form_height, "Thingy Table Generator");

-- Text Box
local text_box_width = 32
local text_box_height = 16
local text_box_x_pos = 75
local text_box_y_pos = form_height * (1/3) - text_box_height/2
hex_val = forms.textbox(handle, "0xD6", text_box_width, text_box_height, nil, text_box_x_pos, text_box_y_pos, false, false)

-- Text Box
local text_box_width_2 = 16
local text_box_height_2 = 16
local text_box_x_pos_2 = 125
local text_box_y_pos_2 = form_height * (1/3) - text_box_height/2
representation = forms.textbox(handle, "よ", text_box_width_2, text_box_height_2, nil, text_box_x_pos_2, text_box_y_pos_2, false, false)

local label_width = 32
local label_height = 16
local label_x_pos = (text_box_x_pos + text_box_x_pos_2) / 2
local label_y_pos = text_box_y_pos
forms.label(handle, " -->", label_x_pos, label_y_pos, label_width, label_height)

-- Button
local button_width = 50
local button_height = 16
local button_x_pos = form_width/2 - button_width * (2/3)
local button_y_pos = form_height * (2/3) - button_height * (1/2) 
button = forms.button(handle, "Generate", make_thingy, button_x_pos, button_y_pos)

-- Dropdown
dropdown_options = {"1. へ：Hiragana Only", "2. へ：Katakana Only", "3. Both"}
dropdown = forms.dropdown(handle, dropdown_options)

local hiragana = {
    ["あ"] = 0, ["い"] = 1, ["う"] = 2, ["え"] = 3, ["お"] = 4,
    ["か"] = 5, ["き"] = 6, ["く"] = 7, ["け"] = 8, ["こ"] = 9,
    ["さ"] = 10, ["し"] = 11, ["す"] = 12, ["せ"] = 13, ["そ"] = 14,
    ["た"] = 15, ["ち"] = 16, ["つ"] = 17, ["て"] = 18, ["と"] = 19,
    ["な"] = 20, ["に"] = 21, ["ぬ"] = 22, ["ね"] = 23, ["の"] = 24,
    ["は"] = 25, ["ひ"] = 26, ["ふ"] = 27, ["へ"] = 28, ["ほ"] = 29,
    ["ま"] = 30, ["み"] = 31, ["む"] = 32, ["め"] = 33, ["も"] = 34,
    ["や"] = 35, ["ゆ"] = 36, ["よ"] = 37,
    ["ら"] = 38, ["り"] = 39, ["る"] = 40, ["れ"] = 41, ["ろ"] = 42,
    ["わ"] = 43, ["を"] = 44, ["ん"] = 45
}

--へ removed. The character is the same in hiragana and katakana so most games only encode it once. Sometimes in Hiragana set sometimes in the Katakana set.
local hiragana_no_he = {
    ["あ"] = 0, ["い"] = 1, ["う"] = 2, ["え"] = 3, ["お"] = 4,
    ["か"] = 5, ["き"] = 6, ["く"] = 7, ["け"] = 8, ["こ"] = 9,
    ["さ"] = 10, ["し"] = 11, ["す"] = 12, ["せ"] = 13, ["そ"] = 14,
    ["た"] = 15, ["ち"] = 16, ["つ"] = 17, ["て"] = 18, ["と"] = 19,
    ["な"] = 20, ["に"] = 21, ["ぬ"] = 22, ["ね"] = 23, ["の"] = 24,
    ["は"] = 25, ["ひ"] = 26, ["ふ"] = 27, ["ほ"] = 28,
    ["ま"] = 29, ["み"] = 30, ["む"] = 31, ["め"] = 32, ["も"] = 33,
    ["や"] = 34, ["ゆ"] = 35, ["よ"] = 36,
    ["ら"] = 37, ["り"] = 38, ["る"] = 39, ["れ"] = 40, ["ろ"] = 41,
    ["わ"] = 42, ["を"] = 43, ["ん"] = 44
}

local katakana = {
    ["ア"] = 0, ["イ"] = 1, ["ウ"] = 2, ["エ"] = 3, ["オ"] = 4,
    ["カ"] = 5, ["キ"] = 6, ["ク"] = 7, ["ケ"] = 8, ["コ"] = 9,
    ["サ"] = 10, ["シ"] = 11, ["ス"] = 12, ["セ"] = 13, ["ソ"] = 14,
    ["タ"] = 15, ["チ"] = 16, ["ツ"] = 17, ["テ"] = 18, ["ト"] = 19,
    ["ナ"] = 20, ["ニ"] = 21, ["ヌ"] = 22, ["ネ"] = 23, ["ノ"] = 24,
    ["ハ"] = 25, ["ヒ"] = 26, ["フ"] = 27, ["ヘ"] = 28, ["ホ"] = 29,
    ["マ"] = 30, ["ミ"] = 31, ["ム"] = 32, ["メ"] = 33, ["モ"] = 34,
    ["ヤ"] = 35, ["ユ"] = 36, ["ヨ"] = 37,
    ["ラ"] = 38, ["リ"] = 39, ["ル"] = 40, ["レ"] = 41, ["ロ"] = 42,
    ["ワ"] = 43, ["ヲ"] = 44, ["ン"] = 45
}

--へ removed. The character is the same in hiragana and katakana so most games only encode it once. Sometimes in Hiragana set sometimes in the Katakana set.
local katakana_no_he = {
    ["ア"] = 0, ["イ"] = 1, ["ウ"] = 2, ["エ"] = 3, ["オ"] = 4,
    ["カ"] = 5, ["キ"] = 6, ["ク"] = 7, ["ケ"] = 8, ["コ"] = 9,
    ["サ"] = 10, ["シ"] = 11, ["ス"] = 12, ["セ"] = 13, ["ソ"] = 14,
    ["タ"] = 15, ["チ"] = 16, ["ツ"] = 17, ["テ"] = 18, ["ト"] = 19,
    ["ナ"] = 20, ["ニ"] = 21, ["ヌ"] = 22, ["ネ"] = 23, ["ノ"] = 24,
    ["ハ"] = 25, ["ヒ"] = 26, ["フ"] = 27, ["ホ"] = 28,
    ["マ"] = 29, ["ミ"] = 30, ["ム"] = 31, ["メ"] = 32, ["モ"] = 33,
    ["ヤ"] = 34, ["ユ"] = 35, ["ヨ"] = 36,
    ["ラ"] = 37, ["リ"] = 38, ["ル"] = 39, ["レ"] = 40, ["ロ"] = 41,
    ["ワ"] = 42, ["ヲ"] = 43, ["ン"] = 44
}

function make_thingy()
	print("ryrr121")
	hex_value = forms.gettext(hex_val)
	thingy_character = forms.gettext(representation)

	-- SELECT CORRECT CHARACTER SET --
	-- IF HIRAGANA OR KATAKANA DO NOT USE へ, THEN REMOVE IT FROM THE SET
	local he_encoding_set = forms.gettext(dropdown) -- ie the set that contains へ
	if he_encoding_set == "2. へ：Katakana Only" then hiragana = hiragana_no_he end
	if he_encoding_set == "1. へ：Hiragana Only" then katakana = katakana_no_he end 

	character_type = {}
	if hiragana[thingy_character] ~= nil then
		character_type = hiragana
	else 
		character_type = katakana
	end

	known_char_hex_val = tonumber(string.sub(hex_value, 3), 16) --string.sub removes the 0x from the start
	offset = known_char_hex_val - character_type[thingy_character]

	local f = io.open("encodings.tbl", "a")
	io.output(f)
	for key, value in pairs(character_type) do
		character_type[key] = character_type[key] + offset
		io.write(bizstring.hex(character_type[key]) .."=" .. key .. "\n")
	end
	io.close()
end

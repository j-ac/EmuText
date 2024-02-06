package.path = "../lib/?.lua;" .. package.path

local misc = require("misc")
local json = require("json")
local gtd = require("gameboy_tile_dump")

local form_width = 400
local form_height = 400

local form = forms.newform(form_width, form_height, "Sprite to json")

local in_box_width = 100
local in_box_height = 20
local out_box_width = form_width * 2/3
local out_box_height = form_height * 1/2

local input_box = forms.textbox(
    form,                                   -- handle
    "8000",                                 -- caption
    in_box_width,                           -- w
    in_box_height,                          -- h
    "HEX",                                  -- restriction
    form_width/2 - in_box_width/2,          -- x
    form_height * 10/100 - in_box_height/2) -- y

local hex_prefix = forms.label(form, 
    "0x",                                       -- label
    form_width/2 - in_box_height/2 - 60,        -- x
    form_height * 10/100 - in_box_height/2 + 2, -- y
    30,                                         -- width
    20,                                         -- height
    true)                                       -- fixed width

local output_box = forms.textbox(
    form,                                    -- handle
    "",                                      -- caption
    out_box_width,                           -- w
    out_box_height,                          -- h
    "",                                      -- restriction
    form_width/2 - out_box_width/2,          -- x
    form_height * 50/100 - out_box_height/2, -- y
    true,                                    -- multiline
    true,                                    -- monospace
    "Vertical")                              -- scrollbars

--local output_box = forms.textbox(
  --  form, "", out_box_width, out_box_height, nil, )

local button_func = function ()
    -- export given sprite following the tiles.json schema
    local SPRITE_SIZE = 16
    local location = tonumber(forms.gettext(input_box), 16) - 0x8000

    local bytes = memory.read_bytes_as_array(location, SPRITE_SIZE)
    local picture = gtd.interpret_sprite(bytes)
    local hex_string = misc.byte_array_to_string(bytes)

    local json_string = json.encode({
        data = hex_string,
        picture = picture,
        character = "",
        location = string.format("%x", location + 0x8000)
    })
    old_output = forms.gettext(output_box)
    forms.settext(output_box, old_output .. json_string .. "\n")

    -- Increment input argument by 0x10
    forms.settext(input_box, string.format("%x", location + 0x8000 + 0x10))

end

local button_width = 75
local button_height = 25
local button = forms.button(form,
 "Generate json", 
 button_func,  
 form_width/2 - button_width/2, 
 form_height * 17/100 - button_height/2, 
 button_width, 
 button_height)
# Reverse Engineering Scripts
This document describes bundled scripts designed to assist in reverse engineering text encodings and aid in creating an encodings.tbl file for Emu LiveText.

### hiragana_value_relative_search.lua
This script is intended to be run through the BizHawk Lua scripting menu. Its primary goal is to help users discover the encoding scheme used in a game by assuming it will be encoded according to [Gojuon](https://en.wikipedia.org/wiki/Goj%C5%ABon) ordering. Not all games use Gojuon, and if they deviate even a little bit from the ordering it can make finding a legal string quite difficult, but not impossible.

#### How to Use

1. Play the game and reach a point where a useful hiragana string appears on the screen. A useful hiragana string should contain no diacritic characters (e.g., ばぱぴごぎ), no spaces, numbers, letters, or hyphens. It does not need to be a complete word; it can even be the ending of one word and the beginning of the next, as long as there is no space between them.

2. Enter the useful hiragana string into the search box, separating each character by commas. For example: `よ,う,こ,そ`.

3. If successful, the script will print some candidates to the Lua console, ideally just one. For example: `value 0xD6 might be よ`.

4. Once you have a good hypothesis, use the other script, thingy_table_generator.lua, to produce an encodings.tbl

**Note:** Do not forget to set your memory domain, as incorrect domains can cause errors, and will prevent the script from producing anything useful. Below is a summary of the correct domains discovered so far:
* Gameboy: VRAM
* Famicom: CIRAM (nametables)


### thingy_table_generator.lua
This script generates a thingy.tbl based on a hypothesis for a single character, assuming Gojuon ordering. The hypothesis can be obtained using the hiragana_value_relative_search.lua script. 

#### How to Use
1. Use the output from the hiragana_value_relative_search.lua script to create your hypothesis.

2. Fill in the hypothesis memory value (preceded by 0x) and the character it corresponds to in the script.

3. Run the script, and it will generate the thingy.tbl based on your hypothesis. If the game does not strictly adhere to Gojuon, some characters may be slightly off, which you can correct later.

It supports hiragana and katakana, but I reccomend not generating any katakana until after you figure out the quirks in the hiragana system, they will likely share similarities.

Each time you run the script the output is **appended** to the file, so that the hiragana output and katakana outputs can append nicely and produce a working file. This means however, that rerunning on different hypotheses produces an invalid file. **You should delete your encoding.tbl file if you want to start over**.

#### へ policy
A tricky detail in Japanese encoding is that へ is identical in the hiragana and katakana syllabaries, and so it most likely will not be encoded twice. A few options to reflect this are present in the dropdown menu in this script. In my experience it usually is encoded in the hiragana character block.

#### After generating
The generated **encodings.tbl** may not be perfect at this point. This may be due to an incorrect hypothesis, in which case it may be required to find a new candidate string and run hiragana_value_relative_search once again. 

However, some characters may be slightly off because of variations in the Gojuon ordering, or entire deletions of characters. (One deletion example is found in Pokemon Blue, which does not use り, opting to use katakana リ in all cases.)


#### Testing 
To test and correct your .tbl file, open the BizHawk hex editor from `Tools -> Hex Editor`, and load your table from `File -> Load .tbl file`. Set the correct memory domain with `Options -> Memory Domains`.

Look for text that appears intelligible, and see if it bears any resemblance to the text on screen in game. By incrementing and decrementing values, you may discover that a particular address affects a single character on screen. Once you figure this out, it becomes dramatically easier. By experimenting with setting this character to different values, you can see how the game renders each one, and discover each character's hex value. Update your thingy table with each new discovery. Once your loaded thingy table correctly represents all the in-game text in BizHawk's text editor, your thingy table is complete.


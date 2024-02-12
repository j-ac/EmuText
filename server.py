#!/usr/bin/env python3
import asyncio
import websockets
import re
import sys
import argparse
import os
import base64
import json
from typing import NamedTuple

parser = argparse.ArgumentParser(description="Interprets and serves text in emulated software to a web browser for live viewing.", epilog="More detail found in README")
parser.add_argument('-v', '--verbose', action='store_true')
parser.add_argument('-r', '--regex_verbose', action='store_true', help="Prints regex matches to the console whenever an artifact is removed")
parser.add_argument('resources_path', action='store', help="A directory containing the following:\n1. lua script to dump text\n2. The output of that lua script (does not have to exist at run time)\n3. An encodings.tbl 4. If diacritic encodings are used, a diacritics.txt file")
args = parser.parse_args()

console_screen_width = {"Gameboy": 20, "Gameboy Color": 20, "NES": 32, "Famicom": 32} #In tiles

# Retains information necessary for interpreting diacritic characters when they
# act as modifiers on a "base character" in a seperate byte. eg ゛て ->　で
class DiacriticEncoding(NamedTuple):
    dictionary: dict # eg AX+BC=ぴ   Format: diacritic_hex+base_character_hex=base_with_diacritic_literal   NO SPACES!
    offset: int # number of bytes the diacritic is found from the "base" character. eg -32 for 32 bytes before, or +1 for one byte after.

async def run_server(websocket):
    # =============
    # === SETUP ===
    # =============
    print("Connection established with web client")
    encoding, artifacts, diacritic_encoding_list, meta_data, tileswap_data = load_game_resources()
    image_path = os.path.join(args.resources_path, "out.png")

    # =================
    # === MAIN LOOP ===
    # =================
    message = ""
    while True:
        await asyncio.sleep(0.01)
        # OPEN DUMP FILE
        with open(os.path.join(args.resources_path, "dump.txt"), encoding="utf-8") as f:
            dump = f.read()
            dump_as_nums = lua_table_to_nums(dump) # deserialize

        # GENERATE MESSAGE
        screen_width = console_screen_width[meta_data["console"]]
        if meta_data["tile-swapping"]:
            await wait_for_filewrite(os.path.join(args.resources_path, "active_sprites.txt"))
            new_message = generate_text_with_swapping(dump_as_nums, tileswap_data, screen_width)
        else:
            new_message = generate_text(encoding, diacritic_encoding_list, dump_as_nums, screen_width)

        # SEND OR SKIP MESSAGE
        if new_message == message:
            continue # Don't send repeating messages
        else: 
            message = new_message

        if message == "": 
            continue #must be after the preceeding else block otherwise the message can never be updated after init

        # REMOVE ARTIFACTS
        cleaned_message = message # Prevents the next iteration detecting a change in the message and acting as if there was a new dump
        for regex in artifacts:
            if args.regex_verbose:
                matches = re.findall(regex, cleaned_message)
                if len(matches) > 0:
                    print(regex + " removed these matches: " + str(matches) + "\n")

            cleaned_message = re.sub(regex, '', cleaned_message) 

        cleaned_message = cleaned_message + "\n" + "─" * screen_width + "\t"

        # ENCODE IMAGE
        image_b64 = image_to_base_64(image_path)

        # BUNDLE TEXT AND IMAGE AS JSON
        json_message = message_and_image_to_json(cleaned_message, image_b64)
 
        # === SEND MESSAGE ===
        if args.verbose:
            print("Sending message")
            print(cleaned_message + '\n')

        await websocket.send(json_message)
        print("Message sent")
        await asyncio.sleep(0.5)

async def wait_for_filewrite(path):
    old_filesize = 0
    filesize = 1
    while old_filesize != filesize and filesize != 0:
        old_filesize = os.path.getsize(path)
        await asyncio.sleep(0.02)
        filesize = os.path.getsize(path)
    
    return

def file_exists(filename):
    return os.path.exists(os.path.join(args.resources_path, filename))

def load_game_resources():
    # ============================
    # === CHECK FILE DIRECTORY ===
    # ============================

    # Verify critical files are present
    if not file_exists("meta.json") or not file_exists("BizHawk_text_dump.lua"):
        sys.exit("Error: " + args.resources_path + " is missing one or more of the following: meta.json, Bizhawk_text_dump.lua")

    # Load metadata
    meta_data = json.loads(open(os.path.join(args.resources_path, "meta.json")).read())

    # Metadata specific 
    if "tile-swapping" not in meta_data or not isinstance(meta_data["tile-swapping"], bool):
        sys.exit("Error: tile-swapping parameter in meta.json not found or is not set to a boolean value.")

    if meta_data["tile-swapping"]:
        if not file_exists("tiles.json"):
            sys.exit("Error: Games with tile-swapping enabled in meta.json must have a tiles.json file.")
        with open(os.path.join(args.resources_path, "active_sprites.txt"), "a") as f:
            pass
    else:
        if not file_exists("encodings.tbl"):
            sys.exit("Error: Games with tile-swapping disabled in meta.json must have an encodings.tbl file.")

    # Create any non-critical files if not present
    with open(os.path.join(args.resources_path, "artifacts.txt"), "a") as f:
        pass

    with open(os.path.join(args.resources_path, "dump.txt"), "a") as f:
        pass

    # ======================
    # === LOAD RESOURCES ===
    # ======================

    # === INTERPRET ENCODINGS IN THE RESOURCE FOLDER ====
    encoding = thingy_table_to_dict(os.path.join(args.resources_path, "encodings.tbl")) if not meta_data["tile-swapping"] else None

    # === LOAD ARTIFACT DETECTION REGEXES ===
    artifacts = load_artifact_detection(os.path.join(args.resources_path, "artifacts.txt"))

    # === Diacritics ===
    # More than one encoding may be used in the same game
    diacritic_encoding_list = None
    if not meta_data["tile-swapping"]:
        diacritics_dir = os.path.join(args.resources_path, "diacritics")
        diacritic_encoding_list = []
        for encoding_file in os.listdir(diacritics_dir):
            d_table = diacritic_table_to_dict(os.path.join(diacritics_dir, encoding_file))
            diacritic_encoding_list.append(d_table)

    # === Tileswap data ===
    tileswap_data = None
    if meta_data["tile-swapping"]:
        with open(os.path.join(args.resources_path, "tiles.json"), 'r') as file:
            json_data = [json.loads(line) for line in file]
            tileswap_data = {entry['data']: entry['character'] for entry in json_data}

            #Makes testing WIP data easier by filling it with recognizable symbols
            #for i, x in enumerate(tileswap_data):
            #    if tileswap_data[x] == "":
            #        tileswap_data[x] = chr(i % 0x5B + 0x0023) #readable latin character range

    return encoding, artifacts, diacritic_encoding_list, meta_data, tileswap_data

def message_and_image_to_json(text, image_b64):
    json_dict = {
        'message': text,
        'image': 'data:image/png;base64,' + image_b64
    }
    return json.dumps(json_dict)

def image_to_base_64(path_to_image):
    if not os.path.exists(path_to_image):
        return ""

    with open(path_to_image, 'rb') as image_file:
        image_data = image_file.read()

    return base64.b64encode(image_data).decode('utf-8')


# Load regexes from artifacts.txt in the game resources folder
# Substrings matching these regexes will be removed before sending to client
def load_artifact_detection(path_to_artifacts):
    artifacts = open(path_to_artifacts, encoding="utf-8").read()
    lines = artifacts.splitlines()
    return lines


# BizHawk's API gives a memory dump as a string of decimal integers eg {243, 195, 11, 1, 0 ....}
def lua_table_to_nums(f):
    numbers = re.findall("\d+", f) # returns a list of strings ["243", "195", "11", "1", "0"]
    numbers[:] = [int(x) for x in numbers]
    return numbers


# Constructs a dictionary which relates the hex values for a diacritic, and a particular character, with the version of that character literal containing the diacritic
# Eg if E5 represents゛ and C3 representsて, then dictionary["E5C3"] -> で  
def diacritic_table_to_dict(path_to_diacritic_table):
    dictionary = {}
    table = open(path_to_diacritic_table, encoding="utf-8").read()
    lines = table.splitlines()

    # Ex first row is OFFSET=-32
    offset_declaration_row = lines.pop(0)
    offset_string = re.search("[+-]?[0-9]+", offset_declaration_row)[0] # Sign indicates whether the diacritic precedes(-) or follows(+) the character it modifies
    offset = int(offset_string)

    for line in lines:
        segments = re.findall("[^+=\\n]+", line) # Matches seperated by + = and newlines
        diacritic = segments[0]             # Hex value for a diacritic eg E4 for゛in Pokemon Crystal
        without_diacritic = segments[1]     # Hex value for a character eg CB for てin Pokemon Crystal
        with_diacritic = segments[2]        # Literal character containing diacritic で

        dictionary[diacritic + without_diacritic] = with_diacritic 

    return DiacriticEncoding(dictionary, offset)

# Character encodings are defined according to a "thingy table" which is a plaintext document of the following format (specific values will differ)
# left side corresponds to a hex value, and right side indicates its character equivalent
# 50=A
# 51=B
# 52=C
# ...
# 6A=?
# 6B=,
def thingy_table_to_dict(path_to_thingy_table):
    dictionary = {}
    table = open(path_to_thingy_table, encoding="utf-8").read()
    lines = table.splitlines()

    for line in lines:
       split = line.split('=', 1) #Seperate the string into everything which occurs before the first = and everything after it. Split only at most once otherwise '=' can not be encoded
       num = split[0]
       character = split[1]
       dictionary[int(num, 16)] = character 

    return dictionary

# Iterate through the dump and using the known encoding and diacritic rules, return it as a python string.
def generate_text(encoding, diacritics_list, dump, screen_width):
    text = ""
    for i, num in enumerate(dump):
        if i != 0 and i % screen_width == 0: text += "\n"

        if num not in encoding:
            text += chr(0x3000) #kana-width space
            continue 

        diacritic = generate_diacritic_text(num, i, diacritics_list, dump)
        if diacritic != "": #ie there was a diacritic
            text += diacritic
            continue

        text += encoding[num]

    return text

# Generate text for a game which uses tileswapping (tile-swapping is true in meta.json)
# considers the dump as a list of pointers, which reference tiles in active_sprites
# determines a UTF-8 character match using the game's tiles.json
def generate_text_with_swapping(dump, tileswap_data, screen_width):
    # === GENERATE TEXT ===
    active_sprites = []
    text = ""
    with open(os.path.join(args.resources_path, "active_sprites.txt")) as file:
        for line in file:
            active_sprites.append(line.rstrip())

    for i, pointer in enumerate(dump):
        if i != 0 and i % screen_width == 0: text += "\n"

        if pointer > len(active_sprites) - 1:
            print("ERR: pointer in dump exceeds expected size. Pointer:" + str(pointer) + "pointer limit: " + str(len(active_sprites)-1))
        
        sprite_data = active_sprites[pointer] if pointer < len(active_sprites) else None
 
        if sprite_data in tileswap_data:
            text += tileswap_data[sprite_data]
        else:
            text += chr(0x3000) #kana-width space

    return text 

# Check if the character we are looking at matches any of the known diacritic rules, and if it does return that diacritic.
def generate_diacritic_text(num, num_position, diacritics_list, dump):
    ret = ""
    for diacritic_encoding in diacritics_list:
        diacritic_candidate_in_boundary = 0 <= num_position + diacritic_encoding.offset < len(dump) # ie the check will not probe out of bounds characters
        if diacritic_candidate_in_boundary: 
            diacritic_candidate = dump[num_position + diacritic_encoding.offset] # we will check if there is actually a diacritic marker at this position later

            key = "%0.2X" % diacritic_candidate + "%0.2X" % num  # using hex() doesn't match the desired format
            if key in diacritic_encoding.dictionary: # iff the diacritic_candidate is a diacritic, AND it meaningfully combines with the dump character. Eg ゜and ひ make ぴ
                ret = diacritic_encoding.dictionary[key]

    return ret

async def main():
    async with websockets.serve(run_server, "localhost", 5678):
        print("Waiting for connection to web client")
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())

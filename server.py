#!/usr/bin/env python3
import asyncio
import websockets
import re
import sys
import argparse
import os

parser = argparse.ArgumentParser(description="Interprets and serves text in emulated software to a web browser for live viewing.", epilog="More detail found in README")
parser.add_argument('-v', '--verbose', action='store_true')
parser.add_argument('resources_path', action='store', help="A directory containing the following:\n1. lua script to dump text\n2. The output of that lua script (does not have to exist at run time)\n3. An encodings.tbl 4. If diacritic encodings are used, a diacritics.txt file")
args = parser.parse_args()

async def run_server(websocket):
    print("Connection established with web client")

    # ===================================================
    # === INTERPRET ENCODINGS IN THE RESOURCE FOLDER ====
    # ===================================================
    encoding = thingy_table_to_dict(os.path.join(args.resources_path, "encodings.tbl"))
    diacritic_offset, diacritic_encoding = diacritic_table_to_dict(os.path.join(args.resources_path, "diacritics.txt"))

    message = ""
    while True:
        # ============================
        # === GENERATE NEW MESSAGE ===
        # ============================

        with open(os.path.join(args.resources_path, "dump.txt")) as f:
            dump = f.read()
            dump_as_nums = lua_table_to_nums(dump)

        new_message = generate_text(encoding, diacritic_encoding, diacritic_offset, dump_as_nums)
        if new_message == message:
            continue # Don't send repeating messages
        else: 
            message = new_message
            if args.verbose: print(message + '\n')

        if message == "": 
            continue #must be after the preceeding else block otherwise the message can never be updated after init

        # ====================
        # === SEND MESSAGE ===
        # ====================
        if args.verbose: print("Sending message")
        await websocket.send(message)

        print("Message sent")
        await asyncio.sleep(0.5)

# VBArr's API gives a memory dump as a string of decimal integers eg {243, 195, 11, 1, 0 ....}
def lua_table_to_nums(f):
    numbers = re.findall("\d+", f) # returns a list of strings ["243", "195", "11", "1", "0"]
    numbers[:] = [int(x) for x in numbers]
    return numbers


# Constructs a dictionary which relates the hex values for a diacritic, and a particular character, with the version of that character literal containing the diacritic
# Eg if E5 represents゛ and C3 representsて, then dictionary["E5C3"] -> で  
def diacritic_table_to_dict(path_to_diacritic_table):
    dictionary = {}
    table = open(path_to_diacritic_table).read()
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

    return offset, dictionary

    


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
    table = open(path_to_thingy_table).read()
    lines = table.splitlines()

    for line in lines:
       split = line.split('=', 1) #Seperate the string into everything which occurs before the first = and everything after it. Split only at most once otherwise '=' can not be encoded
       num = split[0]
       character = split[1]
       dictionary[int(num, 16)] = character 

    return dictionary

def generate_text(encoding, diacritic_encoding, diacritic_offset, dump):
    text = ""
    for i, num in enumerate(dump):
        if num not in encoding:
            continue # Scrap junk characters

        if encoding[num] == "NEWLINE":
            text+= '\n'
            continue

        diacritic_candidate_in_boundary = 0 <= i + diacritic_offset < len(dump) # ie the check will not probe out of bounds characters
        if diacritic_candidate_in_boundary: 
            diacritic_candidate = dump[i + diacritic_offset]

            key = "%0.2X" % diacritic_candidate + "%0.2X" % num # hex() produces 0x prefixes, and lowercase letters, which is not how the encodings are expected.
            if key in diacritic_encoding:
                text += diacritic_encoding[key]
                continue

        text += encoding[num]


           
    text = re.sub("\s{2,}", '\n', text) # Long strings of spaces usually encode newlines
    return text


async def main():
    async with websockets.serve(run_server, "localhost", 5678):
        print("Waiting for connection to web client")
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())

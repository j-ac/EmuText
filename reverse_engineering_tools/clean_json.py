#!/usr/bin/env python3

# Beautify tiles.json file.
#   -> Sort the rows in UTF-8 ordering (which is a largely sensible order for human reading)
#   -> remove "location" parameter as it is only for debugging purposes.

import sys
import queue
import json
from typing import Any
from dataclasses import dataclass, field
from typing import Any

@dataclass(order=True)
class CharacterPriority:
    priority: int
    item: Any=field(compare=False)

pq = queue.PriorityQueue(maxsize = 2500)
with open(file=sys.argv[1], mode='r') as f:
    for line in f:
        row = json.loads(line)
        p = ord(row["character"][0]) if row["character"] != "" else sys.maxsize
        item = CharacterPriority(priority=p, item=row)
        pq.put(item)

with open(file="tiles.json", mode='w') as f:
    while not pq.empty():
        out = pq.get().item
        if "location" in out:
            del out["location"]
        #print(out)
        json.dump(out, f, ensure_ascii=False, sort_keys=True)
        f.write("\n")

print("tiles.json cleaned and exported successfully")
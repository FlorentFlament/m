#!/usr/bin/env python3
import sys

from PIL import Image

import asmlib
from imglib import *

def by_column(data, width):
    res = [[], [], [], []]
    for i in range(len(data)):
        res[i%width].append(data[i])
    return res

def fix_format(data, width):
    """Reverse last column data"""
    for i in range(0, len(data), width):
        # For each line
        data[i+width-8:i+width] = reversed(data[i+width-8:i+width])

def main():
    if len(sys.argv) < 2:
        raise Exception("At least one filename is required")

    fnames = sys.argv[1:]
    width = None
    height = 0
    arr = []
    for f in fnames:
        # Convert to 1 byte in {0,255} per pixel
        im   = Image.open(f)
        width, _ = im.size # All files should have the same width

        # Beware im.convert('1') seems to introduce bugs !
        # To be troubleshooted and fixed upstream !
        # In the mean time using im.convert('L') instead
        grey = im.convert('L')
        arr.extend(bool_array(grey))

    fix_format(arr, width)
    pbs  = pack_bytes(arr)
    width //= 8
    cols = by_column(pbs, width)

    print(asmlib.lst2asm([0xff]*30, 15))
    print("")
    for i, c in enumerate(cols):
        rev  = [~v & 0xff for v in c]
        print(asmlib.lst2asm(reversed(c), 15))
        print("")
        print("; col_{}".format(i))
        print(asmlib.lst2asm([0xff]*30, 15))
        print("")

main()

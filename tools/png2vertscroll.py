#!/usr/bin/env python3
import sys

from PIL import Image

import asmlib
from imglib import *

def by_column(data, width):
    res = [[]]*width
    for i in range(data):
        res[i%width].append(data[i])
    return res

def main():
    fnames = sys.argv[1:]
    width = None
    height = 0
    arr = []
    for f in fnames:
        # Convert to 1 byte in {0,255} per pixel
        im   = Image.open(f)
        width = im.size[0] if width is None else width

        # Beware im.convert('1') seems to introduce bugs !
        # To be troubleshooted and fixed upstream !
        # In the mean time using im.convert('L') instead
        grey = im.convert('L')
        arr.extend(bool_array(grey))

    pfs  = pack_bytes(arr)
    cols = by_column(pfs, width)
    for i, c in enumerate(cols):
        rev  = [~v & 0xff for v in c]
        print("; col_{}".format(i))
        print(asmlib.lst2asm(c, 15))
        print("")

main()

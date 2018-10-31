#!/usr/bin/env python3
import sys

from PIL import Image

import asmlib
from imglib import *

def by_column(data, width_bytes):
    res = [ [] for i in range(width_bytes) ]
    for i in range(len(data)):
        res[i%width_bytes].append(data[i])
    return res

def fix_format_32(data):
    """Reverse last column data"""
    for i in range(0, len(data), 32):
        # For each line
        data[i+32-8:i+32] = reversed(data[i+32-8:i+32])

def fix_format_40(data):
    res = []
    for l in [data[i:i+40] for i in range(0, len(data), 40)]:
        pfs = []
        pfs.append(list(reversed(l[0:4])) + 4*[False])
        pfs.append(l[4:12])
        pfs.append(list(reversed(l[12:20])))
        pfs.append(list(reversed(l[20:24])) + 4*[False])
        pfs.append(l[24:32])
        pfs.append(list(reversed(l[32:40])))
        res.extend(flatten(pfs))
    data.clear()
    data.extend(res)

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

    print(len(arr))
    width_bytes = None
    if width == 32:
        fix_format_32(arr)
        width_bytes = 4
    elif width == 40:
        fix_format_40(arr)
        width_bytes = 6
    else:
        raise Exception("width not supported: {}".format(width))

    print(len(arr))
    pbs  = pack_bytes(arr)
    cols = by_column(pbs, width_bytes)

    for i, c in enumerate(cols):
        rev  = [~v & 0xff for v in c]
        print("; col_{}".format(i))
        print(asmlib.lst2asm([0xff]*30, 15))
        print("")
        print(asmlib.lst2asm(c, 15))

    print("")
    print(asmlib.lst2asm([0xff]*30, 15))

main()

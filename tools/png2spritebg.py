#!/usr/bin/env python3
import sys

from PIL import Image

import asmlib
from imglib import *

def playfields(l):
    pfs = []
    pfs.append(list(reversed(l[0:4])) + 4*[False])
    pfs.append(l[4:12])
    pfs.append(list(reversed(l[12:20])))
    pfs.append(list(reversed(l[20:24])) + 4*[False])
    pfs.append(l[24:32])
    pfs.append(list(reversed(l[32:40])))
    return flatten(pfs)

def main():
    fname = sys.argv[1]
    # Convert to 1 byte in {0,255} per pixel
    im   = Image.open(fname)

    # Beware im.convert('1') seems to introduce bugs !
    # To be troubleshooted and fixed upstream !
    # In the mean time using im.convert('L') instead
    grey = im.convert('L')
    arr   = bool_array(grey)

    cols = None
    if (len(sys.argv) > 2) and (sys.argv[2] == 's') :
        lines = [arr[i:i+16] for i in range(0, 16*24, 16)] # 24 lines - 16 pixels per line
        lines = [[False]*16]*3 + lines + [[False]*16]*3
        lines.reverse()
        print(len(lines))
        pack = pack_bytes(flatten(lines))
        cols = [pack[i:2*30:2] for i in range(2)]
    else:
        lines = [arr[i:i+40] for i in range(0, 40*30, 40)] # 30 lines - 40 pixels per line
        lines.reverse()
        pfs  = [playfields(l) for l in lines]
        pack = pack_bytes(flatten(pfs))
        cols = [pack[i:6*30:6] for i in range(6)]

    print("; " + fname)
    print(asmlib.lst2asm(flatten(cols), 15))
    print("")

main()

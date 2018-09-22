#!/usr/bin/env python3
import sys

from PIL import Image

import asmlib
from imglib import *

def playfields(l):
    pfs = []
    pfs.append(8*[False])
    pfs.append(l[0:8])
    pfs.append(list(reversed(l[8:16])))
    pfs.append(list(reversed(l[16:20])) + 4*[False])
    pfs.append(l[20:28])
    pfs.append(4*[False] + list(reversed(l[28:32])))
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
    lines = [arr[i:i+32] for i in range(0, 32*30, 32)] # 30 lines - 32 pixels per line
    lines.reverse()
    pfs   = [playfields(l) for l in lines]
    pack  = pack_bytes(flatten(pfs))
    cols  = [pack[i:6*30:6] for i in range(6)]
    #rev   = [~v & 0xff for v in pack]
    print("; " + fname)
    print(asmlib.lst2asm(flatten(cols), 15))
    print("")

main()

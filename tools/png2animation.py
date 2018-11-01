#!/usr/bin/env python3
import os
import sys

from PIL import Image

import asmlib
from imglib import *

def playfields(l):
    pfs = []
    pfs.append(l[0:8])
    pfs.append(l[8:16])
    pfs.append(l[16:24])
    pfs.append(l[31:23:-1])
    return flatten(pfs)

def process(fname):
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
    cols  = [pack[i:4*30:4] for i in range(4)]
    #rev   = [~v & 0xff for v in pack]

    _, name, frame = os.path.basename(fname).split('.')[0].split('-')
    label = "fxa_" + name + frame + ":"
    print(label)
    print(asmlib.lst2asm(flatten(cols), 15))
    print("")

def main():
    for fname in sys.argv[1:]:
        process(fname)

main()

#!/usr/bin/env python3
import sys

from PIL import Image

import asmlib
from imglib import *

def main():
    fname = sys.argv[1]
    # Convert to 1 byte in {0,255} per pixel
    im   = Image.open(fname)

    # Beware im.convert('1') seems to introduce bugs !
    # To be troubleshooted and fixed upstream !
    # In the mean time using im.convert('L') instead
    grey = im.convert('L')
    mask = [0x10 if p else 0x0f for p in grey.getdata()]
    print(asmlib.lst2asm(mask, 11))

main()

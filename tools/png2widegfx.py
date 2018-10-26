#!/usr/bin/env python3
import sys

from PIL import Image

import asmlib
from imglib import *

def sanity_check(im):
    """Checks that the image has the appropriate format:
    * width is a multiple of 8
    * height is 30

    """
    w,h = im.size
    msg = None
    if w%8 != 0:
        msg = "Image width is not a multiple of 8: {}".format(w)
    if h != 30:
        msg = "Image height is different than 30: {}".format(h)
    if msg:
        raise BadImageException(msg)

def by_column(data):
    """Reorder the image bytes to have them by column instead of
    lines. Note that this relies on the fact that the image behind the
    data is 30 lines high.

    """
    width = len(data)//30
    return [data[i] for j in range(width) for i in range(j, len(data), width)]

def count_pixels(data):
    h = {}
    for d in data:
        h[d] = h.get(d,0) + 1
    return h

def main():
    fname = sys.argv[1]
    # Convert to 1 byte in {0,255} per pixel
    im   = Image.open(fname)

    # Beware im.convert('1') seems to introduce bugs !
    # To be troubleshooted and fixed upstream !
    # In the mean time using im.convert('L') instead
    grey = im.convert('L')
    sanity_check(grey)

    arr  = bool_array(grey)
    pfs  = pack_bytes(arr)
    cols = by_column(pfs)
    rev  = [~v & 0xff for v in cols]
    print("; " + fname)
    print(asmlib.lst2asm(cols, 15))
    print("")

main()

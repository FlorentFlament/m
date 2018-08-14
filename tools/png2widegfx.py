#!/usr/bin/env python3
import sys

from PIL import Image

import asmlib
import imglib

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
        raise imglib.BadImageException(msg)

def bool_array(im):
    """Converts an image to an array of booleans. The image is flattened,
    so each line succeeds the previous one.

    """
    return [v != 0 for v in im.getdata()]

def pack_bytes(arr):
    """Pack each 8 bools nibble into a byte.
    Return a list of int.

    """
    nibbles = [arr[i:i+8] for i in range(0, len(arr), 8)]
    return [imglib.lbool2int(n) for n in nibbles]

def by_column(data):
    """Reorder the image bytes to have them by column instead of
    lines. Note that this relies on the fact that the image behind the
    data is 30 lines high.

    """
    width = len(data)//30
    return [data[i] for j in range(width) for i in range(j, len(data), width)]

def main():
    fname = sys.argv[1]
    # Convert to 1 byte in {0,255} per pixel
    im   = Image.open(fname).convert('1')
    sanity_check(im)
    arr  = bool_array(im)
    pfs  = pack_bytes(arr)
    cols = by_column(pfs)
    rev  = [~v & 0xff for v in cols]
    print(asmlib.lst2asm(rev))

main()

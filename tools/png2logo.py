#!/usr/bin/env python3
import sys

from PIL import Image

import asmlib
import imglib

def sanity_check(im):
    """Checks that the image has the appropriate format:
    * width is a multiple of 8

    """
    w,h = im.size
    msg = None
    if w%8 != 0:
        msg = "Image width is not a multiple of 8: {}".format(w)
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

def flatten(l):
    return [item for sublist in l for item in sublist]

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
    sanity_check(grey)
    arr   = bool_array(grey)
    lines = [arr[i:i+40] for i in range(0, 400, 40)]
    pfs   = [playfields(l) for l in lines]
    pack  = pack_bytes(flatten(pfs))
    rev   = [~v & 0xff for v in pack]
    print(asmlib.lst2asm(rev, 6))

main()

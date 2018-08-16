#!/usr/bin/env python3

from math import sqrt
from math import sin

from PIL import Image

from asmlib import lst2asm

def distance(xy1, xy2):
    x1, y1 = xy1
    x2, y2 = xy2
    return sqrt((x2-x1)**2 + (y2-y1)**2)

class Plasma:

    def __plasma_function(self, coords):
        dists = [distance(coords, s) for s in self.__sources]
        def pfunc(x):
            return sin(x)/x if x != 0 else 1
        return sum([pfunc(d) for d in dists])

    def __compute_plasma(self):
        self.__data = []
        width, height = self.__size
        for i in range(height):
            line = []
            for j in range(width):
                line.append(self.__plasma_function((j, i)))
            self.__data.append(line)

    def __init__(self, size, sources):
        """
        size is the (width, height) dimension of the plasma.
        sources is a list of plasma source coordinates [(x,y)].
        """
        self.__sources = sources
        self.__size = size
        self.__compute_plasma()

    def get_bytes(self, maxval):
        flat = [val for line in self.__data for val in line]
        ma = max(flat)
        mi = min(flat)
        data = [min(int((f-mi)*(maxval+1)/(ma-mi)), maxval) for f in flat]
        return bytes(data)

    def __str__(self):
        lines = []
        for l in self.__data:
            lines.append(", ".join(["{:05.2f}".format(v) for v in l]))
        return '\n'.join(lines)

def main():
    plasma = Plasma((11, 11), [(2, 2), (7, 10)])
    buf = plasma.get_bytes(15)
    #buf = plasma.get_bytes(255)
    print(lst2asm(buf,11))
    im = Image.frombytes('L', (11, 11), buf)
    #im.show()

main()

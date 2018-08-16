#!/usr/bin/env python3

from random import random

from PIL import Image

from asmlib import lst2asm

SIZE = 2**4+1

class Plasma:
    def __init__(self, size, values, randfact):
        """* size must be 2**n+1. This is the size the grid's side.
        * values are the 4 corner initial values (top-left, top-right,
          bottom-left, bottom-righ).
        * randfact is the random factor to use. Random values will be
          taken in [-randfact, randfact).

        """
        self.__size = size-1 # Though we keep the power of 2
        self.__randfact = randfact
        self.__data = []
        for _ in range(size):
            self.__data.append([0]*size)
        d = self.__data
        s = size - 1
        d[0][0], d[0][s], d[s][0], d[s][s] = values


    def r(self):
        return random() * (2*self.__randfact) - self.__randfact

    def diamond_step(self, granularity):
        """Granularity must be a power of two, and start at self.__size

        """
        g = granularity
        o = granularity//2
        d = self.__data
        for i in range(0, self.__size, g):
            for j in range(0, self.__size, g):
                d[i+o][j+o] = (d[i][j] + d[i+g][j] + d[i][j+g] + d[i+g][j+g]) / 4 + self.r()


    def square_step(self, granularity):
        g = granularity
        o = granularity//2
        s = self.__size
        d = self.__data
        # Odd lines
        for i in range(o, self.__size, g):
            for j in range(g, self.__size, g):
                d[i][j] = (d[i-o][j] + d[i+o][j] + d[i][j-o] + d[i][j+o]) / 4 + self.r()
        # Even lines
        for i in range(g, self.__size, g):
            for j in range(o, self.__size, g):
                d[i][j] = (d[i-o][j] + d[i+o][j] + d[i][j-o] + d[i][j+o]) / 4 + self.r()
        # Top and Bottom special cases
        for j in range(o, self.__size, g):
            # Top line
            d[0][j] = (d[0+o][j] + d[0][j-o] + d[0][j+o]) / 3 + self.r()
            # Bottom line
            d[s][j] = (d[s-o][j] + d[s][j-o] + d[s][j+o]) / 3 + self.r()
        # Left and Right special cases
        for i in range(o, self.__size, g):
            # Left column
            d[i][0] = (d[i-o][0] + d[i+o][0] + d[i][0+o]) / 3 + self.r()
            # Right column
            d[i][s] = (d[i-o][s] + d[i+o][s] + d[i][s-o]) / 3 + self.r()

    def compute(self):
        g = self.__size
        while g>=2 :
            self.diamond_step(g)
            self.square_step(g)
            g //= 2

    def get_bytes(self):
        flat = [val for line in self.__data for val in line]
        ma = max(flat)
        mi = min(flat)
        data = [min(int((f-mi)*16/(ma-mi)),15) for f in flat]
        print(max(data))
        print(min(data))
        #print(data)
        return bytes(data)

    def __str__(self):
        lines = []
        for l in self.__data:
            lines.append(", ".join(["{:05.2f}".format(v) for v in l]))
        return '\n'.join(lines)

def main():
    plasma = Plasma(SIZE, [0, 50, 150, 200], 15)
    plasma.compute()
    buf = plasma.get_bytes()
    im = Image.frombytes('L', (SIZE,SIZE), buf)
    im.show()
    print(lst2asm(buf))

main()

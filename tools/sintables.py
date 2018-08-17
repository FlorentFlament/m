from math import pi
from math import sin

from asmlib import lst2asm

N= 64

def main():
    x = [round((sin(x*2*pi/(N-1))+1)*10) for x in range(N)]
    y = [round((sin(2*x*2*pi/(N-1))+1)*10) for x in range(N)]

    print("fxpl_path_x:")
    print(lst2asm(x))
    print()
    print("fxpl_path_y:")
    print(lst2asm(y))

main()

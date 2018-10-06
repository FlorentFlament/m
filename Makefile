INCDIRS=include sound_asm src
DFLAGS=$(patsubst %,-I%,$(INCDIRS)) -f3 -d

# asm files
SRC=$(wildcard src/*.asm)

main.bin: src/main.asm $(SRC)
	dasm $< -f3 -o$@ -lmain.lst -smain.sym $(DFLAGS)

run: main.bin
	stella $<

clean:
	rm -f main.bin main.lst main.sym

INCDIRS=include src
DFLAGS=$(patsubst %,-I%,$(INCDIRS)) -f3 -d

# asm files
SRC=$(wildcard src/*.asm)

VENV=. venv/bin/activate;

main.bin: src/main.asm $(SRC)
	dasm $< -o$@ -lmain.lst -smain.sym $(DFLAGS)

venv: venv/bin/activate

venv/bin/activate: tools/requirements.txt
	test -d venv || virtualenv venv -p $(shell which python3)
	. venv/bin/activate; pip install -Ur $<
	touch venv/bin/activate

run: main.bin
	stella $<

clean:
	rm -f main.bin main.lst main.sym
	rm -rf venv

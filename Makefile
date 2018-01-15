
NASM = nasm
CC =  x86_64-pc-elf-gcc

NASMFLAGS = -f elf64

%.o: %.asm
	$(NASM) $(NASMFLAGS) $<

ASMSRCS := $(wildcard *.asm)
ASMOBJS := $(patsubst %.asm,%.o,$(ASMSRCS))

objects: $(ASMOBJS)

all: objects

.PHONY: all clean

clean:
	rm *.o

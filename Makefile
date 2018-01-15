
BUILDDIR := build

NASM = nasm
CC = x86_64-pc-elf-gcc
LD = x86_64-pc-elf-ld

NASMFLAGS = -f elf64

$(BUILDDIR)/%.o: %.asm
	mkdir -p $(BUILDDIR)
	$(NASM) $(NASMFLAGS) $< -o $@

default: build

build: $(BUILDDIR)/os.iso

$(BUILDDIR)/kernel.bin: $(BUILDDIR)/multiboot_header.o $(BUILDDIR)/boot.o
	$(LD) --nmagic --output=kernel.bin --script=linker.ld $(BUILDDIR)/multiboot_header.o $(BUILDDIR)/boot.o -o $@

$(BUILDDIR)/os.iso: $(BUILDDIR)/kernel.bin grub.cfg
	mkdir -p $(BUILDDIR)/isofiles/boot/grub
	cp grub.cfg $(BUILDDIR)/isofiles/boot/grub
	cp $(BUILDDIR)/kernel.bin $(BUILDDIR)/isofiles/boot/
	grub-mkrescue -o $(BUILDDIR)/os.iso $(BUILDDIR)/isofiles

all: build

run: $(BUILDDIR)/os.iso
	qemu-system-x86_64 -cdrom $(BUILDDIR)/os.iso

.PHONY: default build run clean

clean:
	-rm -rf build

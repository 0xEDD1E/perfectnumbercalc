NASM=nasm -f elf -g -F stabs
LD=ld -o

perfectnum: perfectnum.o
	$(LD) perfectnum perfectnum.o
perfectnum.o: perfectnum.asm
	$(NASM) perfectnum.asm
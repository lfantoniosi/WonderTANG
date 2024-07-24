CC = sdcc
CFLAGS = -mz80 --opt-code-size --std-sdcc11
ASM = sdasz80
ASMFLAGS =

%.asm : %.c
	$(CC) $(CFLAGS) -S $<

smram.com: crt0.rel smram.rel 
	$(CC) $(CFLAGS) --data-loc 0 --code-loc 0x200 --no-std-crt0 $^ -osmram.ihx
	hex2bin -e com smram.ihx
	cp smram.com disk/SMRAM.COM

all: smram.com

smram.rel: smram.c types.h

%.rel : %.c
	$(CC) $(CFLAGS) -o$@ -c $<

%.rel : %.s
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	+rm *.rel *.asm *.lst *.sym *.map *.ihx smram.com *.lk *.noi disk/SMRAM.COM
	


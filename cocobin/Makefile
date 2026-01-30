all: cocobin.dsk

bin: test.bin

clean:
	rm -f test.bin cocobin.dsk

test.bin: test.asm Makefile
	lwasm -9 -b -otest.bin test.asm

cocobin.dsk: test.bin Makefile
	rm -f cocobin.dsk
	decb dskini cocobin.dsk
	decb copy -2 -b test.bin cocobin.dsk,TEST.BIN

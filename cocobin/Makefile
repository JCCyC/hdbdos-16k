all: cocobin.dsk

bin: menu.bin

clean:
	rm -f menu.bin menu.lst cocobin.dsk

menu.bin: menu.asm ecb_equates.asm rom16kvars.asm Makefile
	lwasm -9 -b -omenu.bin -lmenu.lst menu.asm
	sed -e 's/([^()]*):[0-9]*        //' <menu.lst >menu.lst.tmp
	mv menu.lst.tmp menu.lst

cocobin.dsk: menu.bin menu.bas Makefile
	rm -f cocobin.dsk
	decb dskini cocobin.dsk
	decb copy -2 -b menu.bin cocobin.dsk,MENU.BIN
	decb copy menu.bas -t cocobin.dsk,MENU.BAS

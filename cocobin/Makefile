all: cocobin.dsk

bin: menu.bin type.bin

clean:
	rm -f menu.bin menu.lst type.bin type.lst cocobin.dsk

menu.bin: menu.asm ecb_equates.asm rom16kvars.asm Makefile
	lwasm -9 -b -omenu.bin -lmenu.lst menu.asm
	sed -e 's/([^()]*):[0-9]*        //' <menu.lst >menu.lst.tmp
	mv menu.lst.tmp menu.lst

type.bin: type.asm ecb_equates.asm rom16kvars.asm Makefile
	lwasm -9 -b -otype.bin -ltype.lst type.asm
	sed -e 's/([^()]*):[0-9]*        //' <type.lst >type.lst.tmp
	mv type.lst.tmp type.lst

cocobin.dsk: menu.bin menu.bas type.bin type.bas Makefile
	rm -f cocobin.dsk
	decb dskini cocobin.dsk
	decb copy -2 -b type.bin cocobin.dsk,TYPE.BIN
	decb copy type.bas -t cocobin.dsk,TYPE.BAS
	decb copy -2 -b menu.bin cocobin.dsk,MENU.BIN
	decb copy menu.bas -t cocobin.dsk,MENU.BAS
	cp /proc/meminfo /tmp/meminfo_cocobin
	decb copy /tmp/meminfo_cocobin -1 -b -l -r cocobin.dsk,MEMINFO.TXT
	rm -f /tmp/meminfo_cocobin
	decb copy /etc/passwd -1 -b -l -r cocobin.dsk,PASSWD.TXT

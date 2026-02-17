* LBB2F  -> fp(X)->FPA1
* LBC14  -> fp(X)->FPA0
* LBC35  -> FPA0->fp(X)
* LB740  -> FPA0->X (0-65535)
* LB4F3  -> ACCB->FPA0 (0-255)
* GIVABF -> ACCD->FPA0 (0-65535)


ROM16K		equ	1
		USE	ecb_equates.asm

* Option flags

MFLAG_LARROW	equ	1	Allow exiting menu with left arrow
MFLAG_RARROW	equ	2	Allow exiting menu with right arrow
MFLAG_BREAK	equ	4	Allow exiting menu with Break
MFLAG_WIPE	equ	8	Wipe menu area upon exit
MFLAG_RESTORE	equ	16	Restore menu area upon exit
MFLAG_LETTERS	equ	32	Future - allow F to select "[F]ile",
				* X to select "e[X]it" etc

		org	$7C00
entry		bra	start

errbadparm	jmp	LB44A		FC error if bad parm
errsubscript	jmp	LB447		BS error if not one-dimensional
errnotfound	jmp	L8CDD		NF error if array not found

* Returns number of items in one-dimensional array pointed to by X
* Number of items returned in ACCD or ?BS ERROR if not one-dimensional

arygetlen	ldb	4,x		number of dimensions
		decb
		bne	errsubscript	not one-dimensional -> error
		ldd	5,x		return length of array
myrts		rts			(descriptors start at 7,x)

* Finds array name in accd in array storage
* Trashes U
* Returns array pointer in X or ?NE ERROR

aryfind		tfr	d,u
		ldx	ARYTAB		traverse array list
@loop		cmpx	ARYEND
		bhs	errnotfound
		cmpd	,x
		beq	myrts
		ldd	2,x		jump to next array
		leax	d,x
		tfr	u,d
		bra	@loop

start		jsr	LB146		Check for string parameter
		ldx	FPA0+2		x = string descriptor addr
		lda	,x		acca = len (gotta be 1 or 2)
		beq	errbadparm
		cmpa	#2
		bhi	errbadparm
		ldu	2,x		u = string bytes
		ldu	,u		u = first 2 bytes
		stu	aryname		save 'em
		cmpa	#2
		beq	name2chars
		clr	aryname+1	if 1-byte name, zero 2nd byte
name2chars	ldd	aryname
		orb	#$80		look for string version of array
		bsr	aryfind		get array start in X
		bsr	arygetlen	get array length in ACCD
		std	nstrings	(descriptors start at 7,x)
		leax	7,x
		stx	firststrdesc

		ldd	aryname		look for numeric version of array
		bsr	aryfind		get array start in X
		bsr	arygetlen	get array length in ACCD
		cmpd	#4		must have at least 4 elements
		blo	errsubscript
		leax	7,x
		stx	firstnumdesc

		jsr	LBC14		1st descriptor = selected item
		jsr	LB740
		cmpx	nstrings
		blo	inlistrange
		ldx	#0
inlistrange	stx	selected

		ldx	firstnumdesc
		leax	5,x		2nd descriptor = flags
		jsr	LBC14
		jsr	LB740
		tfr	x,d
		tsta
		lbne	errbadparm
		stb	menuflags

		ldx	firstnumdesc
		leax	10,x		3rd descriptor = x pos - VALIDATE!
		jsr	LBC14
		jsr	LB740
		stx	xpos

		ldx	firstnumdesc
		leax	15,x		4th descriptor = y pos - VALIDATE!
		jsr	LBC14
		jsr	LB740
		stx	ypos

* Some sanity checks

		ldd	nstrings
		addd	ypos
		bcs	erroutofstring
		cmpd	#24
		bhi	erroutofstring
		ldb	HRTEXTWIDTH
		clra
		subd	xpos
		bcc	gotmaxwidth
erroutofstring	ldb	#2*13		OS error if menu too large
		jmp	LAC46
gotmaxwidth	std	maxwidth

* Determine menu width

		ldx	firststrdesc
		ldd	nstrings
		clr	menuwidth
loopgetwidth	pshs	d
		lda	,x
		lbeq	errbadparm
		cmpa	menuwidth
		bls	noexcesswidth
		sta	menuwidth
		tfr	a,b
		clra
		cmpd	maxwidth
		bls	noexcesswidth
errstrtoolong	jmp	$B625		LS error if menu item overshoots width
noexcesswidth	leax	5,x
		puls	d
		subd	#1
		bne	loopgetwidth

* Calculate memory parameters

		ldb	xpos+1		get byte occupied by first
		lda	ypos+1		char of first line
		jsr	[$E004]		GETMEMPOSXY
		sty	memini		and save it
		ldb	xpos+1		get byte occupied by last
		addb	menuwidth	char of last line
		decb
		lda	ypos+1
		jsr	[$E004]		GETMEMPOSXY
		cmpb	#4		one more byte if char is on
		blo	nousenextbyte	bit 4 or ahead
		leay	1,y
nousenextbyte	sty	memend1stline	save addr of last byte of line
		ldb	nstrings+1
		aslb
		aslb
		aslb
		stb	ngrlineswipe	num of items * 8 = graphics lines
		ldd	memend1stline
		subd	memini
		incb			ACCB = bytes per line
		stb	ngrbyteswipe
		lda	ngrlineswipe
		mul
		std	totalbyteswipe

* Calculate free RAM for screen save

		tfr	s,d
		subd	#STKBUF
		subd	ARYEND
		cmpd	totalbyteswipe
		lbls	LAC44		OM error if no RAM to save graph data

* Save screen if restore flag specified

		lda	menuflags
		anda	#MFLAG_RESTORE
		beq	displaymenu1st

		ldy	#screen2buf
		jsr	framexfer

* Display strings for the first time

displaymenu1st	clra
		clrb
dispnextitem	jsr	disp1item
		addd	#1
		cmpd	nstrings
		bne	dispnextitem

* Keyboard loop

getakey		jsr	[POLCAT]	get a key
		beq	getakey
		tfr	a,b
		cmpa	#8		left arrow?
		beq	tstkeylarrow
		cmpa	#9		right arrow?
		beq	tstkeyrarrow
		cmpa	#3		break?
		beq	tstkeybreak
		cmpa	#13		enter?
		beq	keyout
		cmpa	#94		up arrow?
		beq	uparrow
		cmpa	#10		down arrow?
		beq	downarrow
		bra	getakey

* These keys will only be acted upon if flags allow it

tstkeybreak	ldb	menuflags
		andb	#MFLAG_BREAK
		bne	keyout
		bra	getakey
tstkeylarrow	ldb	menuflags
		andb	#MFLAG_LARROW
		bne	keyout
		bra	getakey
tstkeyrarrow	ldb	menuflags
		andb	#MFLAG_RARROW
		bne	keyout
		bra	getakey

* Handle navigation and selection change

uparrow		ldd	selected
		cmpd	#0
		beq	getakey
		subd	#1
		bra	chgsel

downarrow	ldd	selected
		addd	#1
		cmpd	nstrings
		bhs	getakey

chgsel		tfr	d,u		U = new selected
		ldd	selected	ACCD = old selected
		stu	selected
		bsr	disp1item
		tfr	u,d
		bsr	disp1item
		bra	getakey

* Terminating key has been pressed

keyout		tfr	a,b		exit key in 2nd item of num array
		pshs	a
		jsr	LB4F3
		ldx	firstnumdesc
		leax	5,x
		jsr	LBC35

		ldd	selected	selected item in 1st item of num array
		jsr	GIVABF
		ldx	firstnumdesc
		jsr	LBC35

		lda	menuflags
		anda	#MFLAG_WIPE+MFLAG_RESTORE
		beq	goreturnval	do nothing if neither wipe nor restore
		ldy	#buf2screen
		anda	#MFLAG_RESTORE	restore if restore flag
		bne	opisrestore
		ldy	#wipe2screen	if it wasn't restore, it is wipe
opisrestore	bsr	framexfer

* 		lda	#MFLAG_WIPE	wipe menu area if flags say so
* 		anda	menuflags
* 		beq	goreturnval
* 		bsr	wipemenu

goreturnval	puls	a
		cmpa	#13
		beq	retselected
		ldd	#$FFFF		return -1 if exited with non-Enter key
		bra	retthisvalue
retselected	ldd	selected	return selected item if pressed Enter
retthisvalue	jmp	GIVABF

* Outputs string to console
* X points to BASIC string descriptor

outstrdesc	pshs	x,d
		ldb	,x
		ldx	2,x

outstrloop	pshs	b
		ldb	,x+
		jsr	[$E006]		PAINTCHAR
		puls	b
		inc	CURX
		decb
		bne	outstrloop

		ldx	2,s
		ldb	,x
		subb	menuwidth
		beq	nomorespaces

		negb

spacesloop	pshs	b
		ldb	#$20
		jsr	[$E006]		PAINTCHAR
		puls	b
		inc	CURX
		decb
		bne	spacesloop

nomorespaces	puls	x,d,pc

* Display ACCDth string in position and in reverse if selected

disp1item	pshs	d,x
		ldx	firststrdesc
		aslb			Multiply ACCD by 5
		rola
		aslb
		rola
		addd	,s
		leax	d,x
		ldd	,s
		addd	ypos
		stb	CURY
		ldb	xpos+1
		stb	CURX
		ldd	,s
		cmpd	selected
		bne	noneedtorev
		com	REVERSE
		bsr	outstrdesc
		com	REVERSE
		bra	showed1item
noneedtorev	bsr	outstrdesc
showed1item	puls	d,x,pc

* Memory transfer multi-use loop - call with Y = byte-transfer subroutine

framexfer	ldu	ARYEND
framexfernou	ldx	memini
		ldb	ngrlineswipe
loopxferframe	pshs	b,x
		ldb	ngrbyteswipe
loopxferline	jsr	,y		transfer or wipe, increment X and U
		decb
		bne	loopxferline
		puls	b,x
		leax	32,x
		decb
		bne	loopxferframe
		rts

screen2buf	lda	,x+
		sta	,u+
		rts

buf2screen	lda	,u+
		sta	,x+
		rts

wipe2screen	lda	REVERSE
		sta	,x+
		rts

programend	equ	*
programlength	equ	*-entry

* Variables
		org	DBUF1
aryname		rmb	2
nstrings	rmb	2
firststrdesc	rmb	2
firstnumdesc	rmb	2
xpos		rmb	2
ypos		rmb	2
selected	rmb	2
menuflags	rmb	2
maxwidth	rmb	2
memini		rmb	2
memend1stline	rmb	2
totalbyteswipe	rmb	2
menuwidth	rmb	1
ngrlineswipe	rmb	1
ngrbyteswipe	rmb	1

		end	entry

* LBB2F  -> fp(X)->FPA1
* LBC14  -> fp(X)->FPA0
* LBC35  -> FPA0->fp(X)
* LB740  -> FPA0->X (0-65535)
* LB4F3  -> ACCB->FPA0 (0-255)
* GIVABF -> ACCD->FPA0 (0-65535)


ROM16K		equ	1
		USE	ecb_equates.asm

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
		cmpd	#4		must have 4 elements
		bne	errsubscript
		leax	7,x
		stx	firstnumdesc

		jsr	LBC14		1st descriptor = selected item
		jsr	LB740
		cmpx	nstrings
		blo	inlistrange
		ldx	#0
inlistrange	stx	selected
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

* Display strings for the first time

		ldx	firststrdesc
		ldd	nstrings
		ldu	#0
		ldy	ypos
		clr	menuwidth
outnextstr	pshs	d
		lda	,x
		cmpa	menuwidth
		bls	notbiggestitem
		sta	menuwidth
notbiggestitem	lda	xpos+1
		sta	CURX
		tfr	y,d
		stb	CURY
		leay	1,y
		puls	d
		cmpu	selected
		bne	outnohilite
		com	REVERSE
		jsr	outstrdesc
		com	REVERSE
		bra	displaynxtitem
outnohilite	bsr	outstrdesc
displaynxtitem	leax	5,x
		leau	1,u
		subd	#1
		bne	outnextstr

getakey		jsr	[POLCAT]	get a key
		beq	getakey
		cmpa	#3		break?
		beq	keyout
		cmpa	#13		enter?
		beq	keyout
		cmpa	#8		left arrow?
		beq	keyout
		cmpa	#9		right arrow?
		beq	keyout
		cmpa	#94		up arrow?
		beq	uparrow
		cmpa	#10		down arrow?
		beq	downarrow
		bra	getakey

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

keyout		tfr	a,b		store exit key in 2nd item of num array
		jsr	LB4F3
		ldx	firstnumdesc
		leax	5,x
		jsr	LBC35

		ldd	selected	selected item in 1st item of num array
		jsr	GIVABF
		ldx	firstnumdesc
		jsr	LBC35

		ldb	menuwidth	for now, return menu width
		clra
		jmp	GIVABF

* Outputs string to console
* X points to BASIC string descriptor

outstrdesc	pshs	x,d
		ldb	,x
		ldx	2,x
		jsr	LB9A3-1
*		lda	#$0D
*		jsr	PUTCHR
		puls	x,d,pc

* Display ACCDth string in position

disp1item	pshs	d,x
		ldx	firststrdesc
		bsr	accdx5
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

* Multiply ACCD by five

accdx5		pshs	d
		aslb
		rola
		aslb
		rola
		addd	,s++
		rts

* Variables

aryname		rmb	2
nstrings	rmb	2
firststrdesc	rmb	2
firstnumdesc	rmb	2
xpos		rmb	2
ypos		rmb	2
selected	rmb	2
menuwidth	rmb	1

		end	entry

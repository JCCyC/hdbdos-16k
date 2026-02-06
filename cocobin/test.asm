		USE	ecb_equates.asm

		org	$7C00
entry		jsr	LB146		Check for string parameter
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
		orb	#$80
		bsr	aryfind		get array start in X
		bsr	arygetlen	get array length in ACCD
		std	nstrings	(descriptors start at 7,x)

		leax	7,x
		stx	firststrdesc
		clr	menuwidth
outnextstr	pshs	a
		lda	,x
		cmpa	menuwidth
		bls	notbiggestitem
		sta	menuwidth
notbiggestitem	puls	a
		bsr	outstrdesc
		leax	5,x
		subd	#1
		bne	outnextstr

		ldb	menuwidth
		clra
		jmp	GIVABF

* Error jumps

errnotfound	jmp	L8CDD		NF error if array not found
errbadparm	jmp	LB44A		FC error if bad parm
errsubscript	jmp	LB447		BS error if not one-dimensional

* Outputs string to console, followed by a newline
* X points do BASIC string descriptor

outstrdesc	pshs	x,d
		ldb	,x
		ldx	2,x
		jsr	LB9A3-1
		lda	#$0D
		jsr	PUTCHR
		puls	x,d,pc

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

* Returns number of items in one-dimensional array pointed to by X
* Number of items returned in ACCD or ?BS ERROR if not one-dimensional

arygetlen	ldb	4,x		number of dimensions
		decb
		bne	errsubscript	not one-dimensional -> error
		ldd	5,x		return length of array
myrts		rts			(descriptors start at 7,x)

* Variables

aryname		rmb	2
nstrings	rmb	2
firststrdesc	rmb	2
menuwidth	rmb	1

		end	entry

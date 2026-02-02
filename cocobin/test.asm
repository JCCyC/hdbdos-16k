		USE	ecb_equates.asm

		org	$7C00
entry		jsr	LB146		Check for string parameter
		ldx	FPA0+2		x = string descriptor addr
		lda	,x		acca = len (gotta be 1 or 2)
		beq	badlen
		cmpa	#2
		bhi	badlen
		ldu	2,x		u = string bytes
		ldu	,u		u = first 2 bytes
		stu	aryname		save 'em
		cmpa	#2
		beq	name2chars
		clr	aryname+1	if 1-byte name, zero 2nd byte
name2chars	jsr	stringizevar

		ldx	ARYTAB		traverse array list
arysearchloop	cmpx	ARYEND
		bhs	arynotfound
		ldd	aryname
		cmpd	,x
		beq	aryfound
		ldd	2,x		jump to next array
		leax	d,x
		bra	arysearchloop

aryfound	ldb	4,x		number of dimensions
		decb
		bne	notonedim	not one-dimensional -> error

		ldd	5,x		return length of array
		std	nstrings	(descriptors start at 7,x)

		leax	7,x
		stx	firststrdesc
outnextstr	bsr	outstrdesc
		leax	5,x
		subd	#1
		bne	outnextstr

		ldd	nstrings
		jmp	GIVABF

arynotfound	jmp	L8CDD		NF error if array not found

badlen		jmp	LB44A		FC error if bad parm

notonedim	jmp	LB447		BS error if not one-dimensional

aryname		rmb	2
nstrings	rmb	2
firststrdesc	rmb	2

outstrdesc	pshs	x,d
		ldb	,x
		ldx	2,x
		jsr	LB9A3-1
		lda	#$0D
		jsr	PUTCHR
		puls	x,d,pc

stringizevar	lda	aryname+1
		ora	#$80
		sta	aryname+1
		rts

numerizevar	lda	aryname+1
		anda	#$7F
		sta	aryname+1
		rts

		end	entry

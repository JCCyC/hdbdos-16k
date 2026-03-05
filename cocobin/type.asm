* LBB2F  -> fp(X)->FPA1
* LBC14  -> fp(X)->FPA0
* LBC35  -> FPA0->fp(X)
* LB740  -> FPA0->X (0-65535)
* LB4F3  -> ACCB->FPA0 (0-255)
* GIVABF -> ACCD->FPA0 (0-65535)


ROM16K		equ	1
		USE	ecb_equates.asm

		org	$7C00
entry		lda	DEVNUM
		pshs	a

charloop	lda	#1
		sta	DEVNUM
		jsr	LA176
		tst	CINBFL
		bne	typeend

		tfr	a,b
		lda	#0
		sta	DEVNUM
		tfr	b,a
		jsr	[CHROUT]
		bra	charloop

typeend		puls	a
		sta	DEVNUM
		rts

		end	entry

		USE	ecb_equates.asm

		org	$4000
entry		jsr	LB146
		ldx	FPA0+2
		lda	,x
		beq	badlen
		cmpa	#2
		bhi	badlen
		ldx	2,x
		ldd	,x
gogivabf	jmp	GIVABF
badlen		ldd	#-1
		bra	gogivabf


*		ldx	#$400
*		ldd	#'J'*256+'C'
*		std	,x++
*		ldd	#'C'*256+'Y'
*		std	,x++
*		ldd	#'C'*256+' '
*		std	,x++
*		rts

		end	entry

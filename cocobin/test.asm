		org	$4000
entry		ldx	#$400
		ldd	#'J'*256+'C'
		std	,x++
		ldd	#'C'*256+'Y'
		std	,x++
		ldd	#'C'*256+' '
		std	,x++
		rts

		end	entry

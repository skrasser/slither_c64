	;; *** set score to zero
score_reset	lda #$00
		sta score
		sta score+1
		sta score+2
		rts

	;; *** increment score by one
score_inc	sed		; decimal mode
		lda score
		clc		; clear carry
		adc #1		; add 1 in decimal mode
		sta score
		bcc .score_inc1	; no carry, done
		lda score+1	; carry set, increment second byte
		clc
		adc #1
		sta score+1
		bcc .score_inc1
		lda score+2	; carry set, increment third byte
		clc
		adc #1
		sta score+2
		bcc .score_inc1
.score_inc1	cld		; binary mode
		rts

	;; *** print score, screen mem pos given in zbl/zbh
score_print 	lda score+2	; start with most significant digit
		lsr		; get high nibble
		lsr
		lsr
		lsr
		clc
		adc #$30	; add 30 to make it a screen code
		jsr cpchar	; print it
		+w_inc_08 zbl	; next cell on screen
		lda score+2	; load it again
		and #%00001111	; this time take the low nibble
		clc
		adc #$30
		jsr cpchar
		+w_inc_08 zbl
		lda score+1	; repeat this for the next lower order score byte
		lsr
		lsr
		lsr
		lsr
		clc
		adc #$30
		jsr cpchar
		+w_inc_08 zbl
		lda score+1
		and #%00001111
		clc
		adc #$30
		jsr cpchar
		+w_inc_08 zbl
		lda score	; repear for least significant byte/last two digits
		lsr
		lsr
		lsr
		lsr
		clc
		adc #$30
		jsr cpchar
		+w_inc_08 zbl
		lda score
		and #%00001111
		clc
		adc #$30
		jsr cpchar
		rts
	
score	!byte $00,$00,$00
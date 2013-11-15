!macro w_inc_08 .mem {
		lda .mem	; load low byte
		clc		; clear carry
		adc #$08	; add 8
		sta .mem	; write back
		bcc .cc		; carry clear, done
		inc .mem+1	; otherwise increment high byte
.cc
}

!macro w_mov .mem, .val16 {
		lda #<.val16	; load low byte of value
		sta .mem	; store in .mem
		lda #>.val16	; load high byte of value
		sta .mem+1	; store in next address in memory
}

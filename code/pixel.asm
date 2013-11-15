	;; *** init position
initpos		lda #$30
		sta shh
		lda #$00
		sta shl
		lda #$80
		sta shb
		rts

	;; *** draw a pixel at memory shl/shh in position shb
drawpix		ldy #$00
		lda (shl),y 	; load current content
		ora shb		; OR with pixel mask
		sta (shl),y	; write back
		rts

	;; *** read current pixel, set Z accordingly
readpix		ldy #$00
		lda (shl),y
		and shb
		rts

go_left		asl shb		; shift pixel mask to left
		bcc go_left1	; nothing more needed, no roll-over
		lda #$01	; we rolled over, set bit 0
		sta shb		; write back
		lda shl		; load low byte of current position
		sec		; set carry for subtraction
		sbc #$08	; subtract 8 to go one cell left
		sta shl		; write back
		bcs go_left1	; carry still set, no underflow
		dec shh		; subtract from high byte if there was an underflow
go_left1	rts

go_up		lda shl		; load low byte
		and #$07	; bitmask %00000111
		beq go_up0	; we need to go a row of cells up, already in top byte
		dec shl		; not in top byte, just subtract one
		rts		; and done
go_up0		dec shh		; minus 256
		lda shl		; load low byte
		sec		; set carry
		sbc #57		; subtract another 57 to make the total 320 - 7
		sta shl		; store result
		bcs go_up1	; carry still set, all good
		dec shh		; if no carry, decrement high byte again
go_up1		rts

go_right	lsr shb		; shift pixel mask to right
		bne go_right1	; no roll-over, done
		lda #$80	; we rolled over, set bit 7
		sta shb		; write back
		lda shl		; load low byte
		clc		; clear carry
		adc #$08	; and add 8 to go one cell right
		sta shl		; write back
		bcc go_right1	; no carry, we're done
		inc shh		; carry is set, increment high byte
go_right1	rts

go_down		lda shl		; load low byte
		and #$07	; bitmask %00000111
		cmp #$07	; all bits set?
		beq go_down0	; then we need to go down a row of cells
		inc shl		; otherwise just increment low byte
		rts		; and done
go_down0	inc shh		; add 256
		lda shl		; load low byte
		clc		; clear carry
		adc #57		; add 57 for a total of 320 - 7
		sta shl		; store result
		bcc go_down1	; no carry, we're done
		inc shh		; carry set, increment high byte again
go_down1	rts

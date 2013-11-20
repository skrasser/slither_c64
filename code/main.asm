		jsr cpcharmem	; copy character data to $4000
		jsr initsid
		jsr vicsetup
		jsr clearscreen
		jsr drawframe
		jsr printscore
gamestart	jsr pressfire
		jsr clearscreen
		jsr drawframe
		jsr printscore
		jsr score_reset
		jsr initpos
		jsr snd_crash_rel ; turn off crash sound
	
		lda #%11111011	; init left direction
		sta shd		; store in direction var

joy_read
		jsr score_inc
		jsr printscore

		jsr readpix
		beq no_collision
		jsr snd_crash
		lda #$00	; collision, set border color to black
		sta vic+$20
		jsr busyloop
		jmp gamestart
no_collision
		jsr drawpix
		jsr busyloop
		jsr busyloop
		jsr busyloop
	
		lda $dc00	; load joystick port 2 status
		and #%00001111	; check if any directions are set
		cmp #%00001111
		bne .joy_dir	; we have at least one direction
		lda shd		; no direction set right now, load last one
.joy_dir	sta shd		; store direction for later
		lsr		; shift "up" into carry
		bcs joy_not_up
		jsr go_up
		jmp joy_read
joy_not_up	lsr		; shift "down"
		bcs joy_not_down
		jsr go_down
		jmp joy_read	
joy_not_down	lsr		; shift "left"
		bcs joy_not_left
		jsr go_left
		jmp joy_read	
joy_not_left	lsr		; shift "right"
		bcs joy_not_right
		jsr go_right
joy_not_right	jmp joy_read

	;; end of main loop

	
	;; *** Fill $ff bytes of memory referenced at zbl with accumulator
fillmem 	ldy #$00
.fillmem1	sta (zbl),y
		iny
		bne .fillmem1
		rts

	;; *** Fill x bytes of memory referenced at zbl with accumulator
fillmemn	ldy #$00
.fillmemn1	sta (zbl),y
		iny
		dex
		bne .fillmemn1
		rts
	
busyloop	ldx #$00
busyloop1	inx
		bne busyloop1
		rts

pressfire	+w_mov zbl,bmpram+$cd8	; store $2cd8 in zbh/zbl
		+w_mov zcl,pressfirestr	; store string address
		jsr puts
		+w_mov zbl,scrram+$19b	; store $059b in zbh/zbl (corresponding color mem)
		lda #$18		; set color to white (1) on orange (8)
		ldx #18			; 18 characters
		jsr fillmemn
	
		lda #$10	; bit 4
.pressfire1	bit $dc00	; check fire button of jostick in port 2
		bne .pressfire1	; loop until bit is unset
		rts

pressfirestr	!scr ">>> press fire <<<@"

printscore	+w_mov zbl,bmpram
		+w_mov zcl,scorestr
		jsr puts
		jsr score_print
		rts

scorestr	!scr "score @"

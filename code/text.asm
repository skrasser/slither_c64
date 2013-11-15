	;; *** Copy character memory
cpcharmem	sei		; disable interrupts
		lda $01		; load $01
		and #$fb	; clear bit 4
		sta $01		; write back, character rom is now visible $d000

		lda #$00	; load source address $d000 into zal/zah
		sta zal
		lda #$d0
		sta zah

		lda #$00	; load destination address $3000 into zal/zah
		sta zbl
		lda #$40
		sta zbh

		ldy #$00	; init offset in page to zero
		ldx #$08	; copy 8 pages
.cpcharmem1	lda (zal),y	; read source byte
		sta (zbl),y	; store at destination
		iny		; next offset
		bne .cpcharmem1	; do until y wraps around
		inc zah		; next source page
		inc zbh		; next destination page
		dex		; one less page to go
		bne .cpcharmem1	; pages left?
	
		lda $01		; load $01 again
		ora #$04	; set bit 4
		sta $01		; write back, back to normal
		cli		; enable interrupts
		rts		; that's all

	;; *** Copy character data (8 bytes) with screen code a from character
	;; *** memory copy to address in zbl/zbh
cpchar		cmp #32		; screen code less than 32
		bcc .cpchar1	; then branch
		sec		; set carry for subtraction
		sbc #32		; subtract 32 from screen code, we're on the second page
		asl		; times 8 yields page offset (8 bytes per char)
		asl
		asl
		sta zal		; store in low byte
		lda #$41	; high byte is next page
		sta zah		; address in zah/zal is $41xx
		jmp .cpchar2
.cpchar1	asl		; screen code is <32, multiply by 8
		asl
		asl
		sta zal		; yields page offset
		lda #$40	; location is $4000 + offset
		sta zah		; now in zah/zal
.cpchar2	ldy #$00	; set y to 0
.cpchar3	lda (zal),y	; load from char mem copy based on the screen code calculation above
		sta (zbl),y	; save in given memory location
		iny
		cpy #$08	; 8 bytes for 1 character
		bne .cpchar3
		rts

	;; *** Print string pointed to in zcl/zch as bitmap into screen memory
	;; *** at address zbl/zbh; string is @/zero-terminated
puts		ldy #$00
.puts1		lda (zcl),y	; load character
		beq .puts2	; if it's @ (screen code 0), then stop
		sty zx1		; store y on zeropage since sub uses it
		jsr cpchar	; print the char
		ldy zx1		; restore y
		iny		; increment y to get to next char in string
		beq .puts2
		lda zbl		; load low byte of destination
		clc		; clear carry
		adc #$08	; move to next cell
		sta zbl
		bcc .puts1	; carry clear, loop
		inc zbh		; carry set, increment high byte of destination
		jmp .puts1	; then loop
.puts2		rts

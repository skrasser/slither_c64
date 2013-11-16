	;; *** set up vic for hires gfx
vicsetup	lda $d011 	; load vic control register 1
		ora #$20	; set bit 5
		sta $d011	; write back

		lda #$18	; 1: $0400, 8: $2000
		sta $d018	; set vic base addresses
		rts
	
	;; *** clear all pixels and colors; set border color
clearscreen	lda #$01
		sta $d020	; set white border

		lda #$00
		sta zbl
		lda #$20
		sta zbh
	;; clear pixels from $2000 to $3f40 ($1f40 bytes)
	;; this clear to $3f00
		ldx #$00
setpix		lda #$00
		jsr fillmem
		inc zbh		; increment high byte of vector (adding $100 to vector)
		inx		; increment counter
		cpx #$1f	; and check if reached $1f00 bytes
		bne setpix
	;; till $3f40, with some overlap starting from $3e40
		ldx #$3e
		stx zbh
		ldx #$40
		stx zbl
		jsr fillmem	
	
	;; set colors for $3e8 cells starting at $0400
		ldy #$00
		lda #$81
setcol		sta $0400,y
		sta $0500,y
		sta $0600,y
		sta $06e8,y

		iny
		bne setcol
		rts

	;; *** Draw a frame starting in second row
drawframe
		lda #$40 	; store address in zero page for indirect addressing
		sta zbl
		lda #$21
		sta zbh
	
		ldx #$00
drawframe1
		lda #$80	; set bit 7 for the left boundary
		ldy #$00
drawframe11
		sta (zbl),y
		iny
		cpy #8
		bne drawframe11

		lda	#160
		clc
		adc	zbl
		sta	zbl
		bcc	drawframe12
		inc	zbh	; carry was set, next page
drawframe12	lda	#160
		clc
		adc	zbl
		sta	zbl
		bcc	drawframe13
		inc	zbh	; carry was set, next page
drawframe13	

		inx		; count this cell
		cpx #24		; did 200-8 rows, i.e. 24 cells?
		bne drawframe1

	
		lda #$78 	; for the right border we start at $2278 (top right cell is $2138)
		sta zbl
		lda #$22
		sta zbh
	
		ldx #$00
drawframe2
		lda #$01	; set bit 1 for the right boundary
		ldy #$00
drawframe21
		sta (zbl),y
		iny
		cpy #8
		bne drawframe21

		lda	#160
		clc
		adc	zbl
		sta	zbl
		bcc	drawframe22
		inc	zbh	; carry was set, next page
drawframe22	lda	#160
		clc
		adc	zbl
		sta	zbl
		bcc	drawframe23
		inc	zbh	; carry was set, next page
drawframe23	

		inx		; count this cell
		cpx #24		; did 200-8 rows, i.e. 24 cells?
		bne drawframe2


		lda #$ff	; set all pixels
		ldy #$00
drawframe3
		sta $2140,y	; first 256 pixels of second row
		sta $2180,y	; the rest with some overlap
		sta $3e07,y	; same for the bottom
		sta $3e47,y
		iny		; skip 8 bytes to get to next cell
		iny
		iny
		iny
		iny
		iny
		iny
		iny
		bne drawframe3	; loop if Z is unset
		
		rts

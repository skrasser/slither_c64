vic=$d000
bmpram=$2000	; bitmap ram $2000 - $3fff
scrram=$0400	; screen ram with color data $0400 - $07ff
	
	;; *** set up vic for hires gfx
vicsetup	lda vic+$11 	; load vic control register 1
		ora #$20	; set bit 5
		sta vic+$11	; write back

		lda #$18	; 1: $0400, 8: $2000
		sta vic+$18	; set vic base addresses
		rts
	
	;; *** clear all pixels and colors; set border color
clearscreen	lda #$01
		sta vic+$20	; set white border
		+w_mov zbl,bmpram

	;; clear pixels from $2000 to $3f40 ($1f40 bytes)
	;; this clear to $3f00
		ldx #$00
.setpix		lda #$00
		jsr fillmem
		inc zbh		; increment high byte of vector (adding $100 to vector)
		inx		; increment counter
		cpx #$1f	; and check if reached $1f00 bytes
		bne .setpix
	;; till $3f40, with some overlap starting from $3e40
		ldx #$3e
		stx zbh
		ldx #$40
		stx zbl
		jsr fillmem	
	
	;; set colors for $3e8 cells starting at $0400
		ldy #$00
		lda #$51	; 5 = green fg, 1 = white bg
.setcol		sta scrram,y
		sta scrram+$100,y
		sta scrram+$200,y
		sta scrram+$2e8,y
		iny
		bne .setcol
	
	;; set color for first row of cells (40)
	;; (optimize: this is overwriting $51 set above)
		ldy #39
		lda #$81
.setcoltop	sta scrram,y
		dey
		bpl .setcoltop	; branch if bit 7 is unset

		rts

	;; *** Draw a frame starting in second row
drawframe	+w_mov zbl,bmpram+$140 ; store address for second row in zero page for indirect addressing
		ldx #$00
.drawframe1	lda #$80	; set bit 7 for the left boundary
		ldy #$00
.drawframe11	sta (zbl),y
		iny
		cpy #8		; 8 bytes in this cell to change
		bne .drawframe11
		lda #160	; add 160, then deal with carry
		clc
		adc zbl
		sta zbl
		bcc .drawframe12
		inc zbh		; carry was set, next page
.drawframe12	lda #160	; add another 160 to make it 320 (next row of cells)
		clc
		adc zbl
		sta zbl
		bcc .drawframe13
		inc zbh		; carry was set, next page
.drawframe13	inx		; count this cell
		cpx #24		; did 200-8 rows, i.e. 24 cells?
		bne .drawframe1
	
 		+w_mov zbl, bmpram+$278	; for the right border we start at $2278 (top right cell is $2138)
		ldx #$00
.drawframe2	lda #$01	; set bit 1 for the right boundary
		ldy #$00
.drawframe21	sta (zbl),y
		iny
		cpy #8
		bne .drawframe21

		lda #160
		clc
		adc zbl
		sta zbl
		bcc .drawframe22
		inc zbh		; carry was set, next page
.drawframe22	lda #160
		clc
		adc zbl
		sta zbl
		bcc .drawframe23
		inc zbh		; carry was set, next page
.drawframe23	inx		; count this cell
		cpx #24		; did 200-8 rows, i.e. 24 cells?
		bne .drawframe2

		lda #$ff	; set all pixels for horizontal lines
		ldy #$00
.drawframe3	sta bmpram+$140,y	; first 256 pixels of second row
		sta bmpram+$180,y	; the rest with some overlap
		sta bmpram+$1e07,y	; same for the bottom
		sta bmpram+$1e47,y
		iny		; skip 8 bytes to get to next cell
		iny
		iny
		iny
		iny
		iny
		iny
		iny
		bne .drawframe3	; loop if Z is unset
		
		rts

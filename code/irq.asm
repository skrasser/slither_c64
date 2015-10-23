music_init=$1000
music_play=$1003	
	
irq_setup	sei
		lda #$7f	; disable CIA timer interrups
		sta $dc0d
		sta $dd0d
		lda $dc0d	; read to get rid of pending interrupts
		lda $dd0d
	
		lda #$00	; raster irq for line 0 (bits 0-7)
		sta vic+$12
		lda vic+$11	; for bit 8, clean MSB in register $11
		and #$7f
		sta vic+$11	; and write back
	
		lda #<irq_handler
		sta $0314
		lda #>irq_handler
		sta $0315
	
		cli
		rts
	
irq_handler	lda #$01
		sta vic+$19
		jsr $1003
		jmp $ea81	; continue with original system handler

music_stop	lda #$00	; disable raster irq
		sta vic+$1a
		rts
	
music_start	lda #$00
		jsr music_init
		lda #$01	; enable raster irq	
		sta vic+$1a
		rts

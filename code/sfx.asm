sid=$d400

initsid		ldy #24		; 24 SID registers to clear
.initsid1	lda #$00
		sta sid,y	; write 0 into register
		dey		; decrement counter
		bpl .initsid1	; loop until N is set (underflow y to $ff)
		lda #$0f
		sta sid+24	; set volume to max
		lda #$09	; attack 0, delay 9
		sta sid+5
		lda #$00	; sustain 0, release 0
		sta sid+6
		rts

snd_crash	lda #6		; freq high byte
		sta sid+1
		lda #0		; freq low byte
		sta sid
		lda #129	; white noise
		sta sid+4
		rts

snd_crash_rel	lda #128	; release
		sta sid+4
		rts

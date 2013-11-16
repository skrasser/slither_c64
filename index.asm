	;; Root source file, based on empty asm project from http://www.dustlayer.com
!cpu 6502
!to "build/slither.prg",cbm    ; output file

	;; BASIC loader
* = $0801                               ; BASIC start address (#2049)
!byte $0d,$08,$dc,$07,$9e,$20,$34,$39   ; BASIC loader to start at $c000...
!byte $31,$35,$32,$00,$00,$00           ; puts BASIC line 2012 SYS 49152
* = $c000 			        ; start address for 6502 code

!source "code/zero.asm"
!source "code/macro.asm"
!source "code/main.asm"
!source "code/gfx.asm"
!source "code/text.asm"
!source "code/pixel.asm"
!source "code/score.asm"
!source "code/sfx.asm"

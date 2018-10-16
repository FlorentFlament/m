FXSB_BG_MODULUS equ #41

; 51 bytes fastcode
fx_spritebg_fastcode:
			;28  703e	  .outer_loop
	.byte $a2, $07	;29  703e	      ldx #7
			;30  7040	  .inner_loop
	.byte $85, $02	;31  7040	      sta WSYNC
	.byte $b9, $83, $d0	;32  7042	      lda fx_spritebg_pf0,Y
	.byte $85, $0d	;33  7045	      sta PF0
	.byte $b9, $a3, $d0	;34  7047	      lda fx_spritebg_pf1,Y
	.byte $85, $0e	;35  704a	      sta PF1
	.byte $b9, $c3, $d0	;36  704c	      lda fx_spritebg_pf2,Y
	.byte $85, $0f	;37  704f	      sta PF2
	.byte $b9, $43, $d1	;38  7051	      lda fx_spritebg_sp0,Y
	.byte $85, $1b	;39  7054	      sta GRP0
	.byte $b9, $63, $d1	;40  7056	      lda fx_spritebg_sp1,Y
	.byte $85, $1c	;41  7059	      sta GRP1
	.byte $b9, $e3, $d0	;42  705b	      lda fx_spritebg_pf3,Y
	.byte $85, $0d	;43  705e	      sta PF0
	.byte $b9, $03, $d1	;44  7060	      lda fx_spritebg_pf4,Y
	.byte $85, $0e	;45  7063	      sta PF1
	.byte $b9, $23, $d1	;46  7065	      lda fx_spritebg_pf5,Y
	.byte $85, $0f	;47  7068	      sta PF2
	.byte $ca		;48  706a	      dex
	.byte $10, $d3	;49  706b	      bpl .inner_loop
	.byte $88		;50  706d	      dey
	.byte $10, $ce	;51  706e	      bpl .outer_loop
	.byte $60		;52  7070	      rts

; Fast code initialization macro
	MAC m_fxsb_init_fastcode
	ldy #50 ; 51 bytes of fastcode to load in memory
.loop:
	lda fx_spritebg_fastcode,Y
	sta fxsb_buffer,Y
	dey
	bpl .loop
	ENDM

; Fast code update macro
; Using the following 2 memory registers
; fxsb_bg_base : base pointer for the background to display
; fxsb_sp_base : base pointer for the sprite to display
; Uses ptr, tmp and tmp1
	MAC m_fxsb_update_fastcode
	m_copy_pointer fxsb_bg_base, ptr
	m_copy_pointer fxsb_sp_base, tmp
	;32  7042		       b9 83 d0	      lda	fx_spritebg_pf0,Y
	lda ptr
	sta fxsb_buffer + 5
	lda ptr+1
	sta fxsb_buffer + 6
	;34  7047		       b9 a3 d0	      lda	fx_spritebg_pf1,Y
	m_add_to_pointer ptr, FXSB_BG_MODULUS ; FBM pixs high background
	lda ptr
	sta fxsb_buffer + 10
	lda ptr+1
	sta fxsb_buffer + 11
	;36  704c		       b9 c3 d0	      lda	fx_spritebg_pf2,Y
	m_add_to_pointer ptr, FXSB_BG_MODULUS ; FBM pixs high background
	lda ptr
	sta fxsb_buffer + 15
	lda ptr+1
	sta fxsb_buffer + 16
	;38  7051		       b9 43 d1	      lda	fx_spritebg_sp0,Y
	lda tmp
	sta fxsb_buffer + 20
	lda tmp+1
	sta fxsb_buffer + 21
	;40  7056		       b9 63 d1	      lda	fx_spritebg_sp1,Y
	m_add_to_pointer tmp, #30 ; 30 pixs high sprites
	lda tmp
	sta fxsb_buffer + 25
	lda tmp+1
	sta fxsb_buffer + 26
	;42  705b		       b9 e3 d0	      lda	fx_spritebg_pf3,Y
	m_add_to_pointer ptr, FXSB_BG_MODULUS ; FBM pixs high background
	lda ptr
	sta fxsb_buffer + 30
	lda ptr+1
	sta fxsb_buffer + 31
	;44  7060		       b9 03 d1	      lda	fx_spritebg_pf4,Y
	m_add_to_pointer ptr, FXSB_BG_MODULUS ; FBM pixs high background
	lda ptr
	sta fxsb_buffer + 35
	lda ptr+1
	sta fxsb_buffer + 36
	;46  7065		       b9 23 d1	      lda	fx_spritebg_pf5,Y
	m_add_to_pointer ptr, FXSB_BG_MODULUS ; FBM pixs high background
	lda ptr
	sta fxsb_buffer + 40
	lda ptr+1
	sta fxsb_buffer + 41
	ENDM

fx_spritebg_init SUBROUTINE
	lda #$cc
	sta COLUPF
	lda #$0e
	sta COLUP0
	sta COLUP1

	; COLUBK will be set at the very last minute
	lda #$00
	sta COLUBK

	; quad sized players
	lda #$07
	sta NUSIZ0
	sta NUSIZ1

	; Positioning the players
	sta WSYNC
	ldy #5
.pos_loop	dey
	bpl .pos_loop
	SLEEP 3
	sta RESP0
	SLEEP 8
	sta RESP1
	lda #$10
	sta HMP0
	lda #$20
	sta HMP1
	sta WSYNC
	sta HMOVE

	; Initialize sprite to be displayed
	lda #0
	sta fxsb_sprite_idx

	m_fxsb_init_fastcode

	; WIP Test base pointers
	SET_POINTER fxsb_bg_base, fx_spritebg_pf0
	jmp RTSBank

; Macro incrementing a register and resetting it if > than max val
	MAC m_fxsb_inc_mod
	inc {1}
	lda {1}
	cmp {2}
	bne .end
	lda #0
	sta {1}
.end
	ENDM

fx_spritebg_vblank SUBROUTINE
	; Setup sprite
	lda frame_cnt
	and #$03
	bne .after_sprite_update
	m_fxsb_inc_mod fxsb_sprite_idx, #3

.after_sprite_update:
	lda fxsb_sprite_idx
	asl
	tay
	lda fx_spritebg_sprites,Y
	sta fxsb_sp_base
	lda fx_spritebg_sprites+1,Y
	sta fxsb_sp_base+1

	; Setup background
	lda frame_cnt
	and #$01
	bne .after_bg_update
	m_fxsb_inc_mod fxsb_bg_idx, #11

.after_bg_update
	SET_POINTER fxsb_bg_base, fx_spritebg_pf0
	m_add_to_pointer fxsb_bg_base, fxsb_bg_idx

	m_fxsb_update_fastcode
	jmp RTSBank

fx_spritebg_kernel SUBROUTINE
	sta WSYNC
	ldy #29
	lda #$d6
	SLEEP 58
	sta COLUBK

	; In memory fast loop
	jsr fxsb_buffer

	sta WSYNC
	lda #$0
	sta COLUBK
	sta PF0
	sta PF1
	sta PF2
	sta GRP0
	sta GRP1

	jmp RTSBank

; /home/florent/src/SV2018/graphics/glafouk/2018-10-02-01/anime-fond-40x30-bw.png
fx_spritebg_pf0:
	dc.b $10, $00, $10, $10, $10, $10, $10, $10, $00, $00, $00
	dc.b $10, $00, $10, $10, $10, $10, $10, $10, $00, $00, $00, $10, $00, $10, $10
	dc.b $10, $10, $10, $10, $00, $00, $00, $10, $00, $10, $10, $10, $10, $10, $10

	dc.b $fe, $00, $c6, $c6, $d6, $fe, $ee, $c6, $00, $00, $00
	dc.b $fe, $00, $c6, $c6, $d6, $fe, $ee, $c6, $00, $00, $00, $fe, $00, $c6, $c6
	dc.b $d6, $fe, $ee, $c6, $00, $00, $00, $fe, $00, $c6, $c6, $d6, $fe, $ee, $c6

	dc.b $fc, $00, $8c, $8c, $ac, $fc, $dc, $8c, $00, $00, $00
	dc.b $fc, $00, $8c, $8c, $ac, $fc, $dc, $8c, $00, $00, $00, $fc, $00, $8c, $8c
	dc.b $ac, $fc, $dc, $8c, $00, $00, $00, $fc, $00, $8c, $8c, $ac, $fc, $dc, $8c

	dc.b $10, $00, $10, $10, $10, $10, $10, $10, $00, $00, $00
	dc.b $10, $00, $10, $10, $10, $10, $10, $10, $00, $00, $00, $10, $00, $10, $10
	dc.b $10, $10, $10, $10, $00, $00, $00, $10, $00, $10, $10, $10, $10, $10, $10

	dc.b $fe, $00, $c6, $c6, $d6, $fe, $ee, $c6, $00, $00, $00
	dc.b $fe, $00, $c6, $c6, $d6, $fe, $ee, $c6, $00, $00, $00, $fe, $00, $c6, $c6
	dc.b $d6, $fe, $ee, $c6, $00, $00, $00, $fe, $00, $c6, $c6, $d6, $fe, $ee, $c6

	dc.b $fc, $00, $8c, $8c, $ac, $fc, $dc, $8c, $00, $00, $00
	dc.b $fc, $00, $8c, $8c, $ac, $fc, $dc, $8c, $00, $00, $00, $fc, $00, $8c, $8c
	dc.b $ac, $fc, $dc, $8c, $00, $00, $00, $fc, $00, $8c, $8c, $ac, $fc, $dc, $8c

fx_spritebg_sp0:
; graphics/glafouk/2018-10-02-01/anime-fond-sprite32x30-spriteA.png
	dc.b $00, $00, $00, $40, $ff, $20, $10, $3f, $08, $04, $0f, $02, $0f, $1f, $1b
	dc.b $11, $1b, $1f, $1f, $1f, $18, $10, $10, $10, $10, $1f, $0f, $00, $00, $00
	dc.b $00, $00, $00, $02, $ff, $04, $08, $fc, $10, $20, $f0, $40, $f0, $f8, $d8
	dc.b $88, $d8, $f8, $f8, $f8, $18, $08, $08, $08, $08, $f8, $f0, $00, $00, $00

fx_spritebg_sp1:
; graphics/glafouk/2018-10-02-01/anime-fond-sprite32x30-spriteB.png
	dc.b $00, $00, $00, $ff, $40, $20, $7f, $10, $08, $1f, $06, $0f, $1f, $1b, $11
	dc.b $1b, $1f, $1f, $1f, $18, $10, $10, $10, $10, $1f, $0f, $00, $00, $00, $00
	dc.b $00, $00, $00, $ff, $02, $04, $fe, $08, $10, $f8, $60, $f0, $f8, $d8, $88
	dc.b $d8, $f8, $f8, $f8, $18, $08, $08, $08, $08, $f8, $f0, $00, $00, $00, $00

fx_spritebg_sp2:
; graphics/glafouk/2018-10-02-01/anime-fond-sprite32x30-spriteC.png
	dc.b $00, $00, $00, $80, $40, $ff, $20, $10, $3f, $08, $04, $03, $0f, $1f, $1b
	dc.b $11, $1b, $1f, $1f, $1f, $18, $10, $10, $10, $10, $1f, $0f, $00, $00, $00
	dc.b $00, $00, $00, $01, $02, $ff, $04, $08, $fc, $10, $20, $c0, $f0, $f8, $d8
	dc.b $88, $d8, $f8, $f8, $f8, $18, $08, $08, $08, $08, $f8, $f0, $00, $00, $00

fx_spritebg_sprites:
	dc.w fx_spritebg_sp0
	dc.w fx_spritebg_sp1
	dc.w fx_spritebg_sp2

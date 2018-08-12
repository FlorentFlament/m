; Sets a sprite horizontal position
; * 1st argument is the sprite to setup (0 or 1)
; * 2nd argument is the rough position
; * 3rd argument is the fine position in [-8, 7]
; ex: m_set_sprite_position 0, 5, 3
	MAC m_set_sprite_position
	sta WSYNC
	; rough positioning
	ldx {2}
.rough_pos:
	dex
	bpl .rough_pos
	sta RESP{1}
	; fine positioning
	lda {3}
	REPEAT 4
	asl
	REPEND
	; Beware ! HMPx value must be in bits 7-4
	sta HMP{1}
	sta WSYNC
	sta HMOVE
	ldx #5
.wait_loop:
	dex
	bpl .wait_loop
	lda #0
	; Beware HMPx should not be modified during 24 computer
	; cycles after HMOVE
	sta HMP{1}
	ENDM

fx_pixscroll_init SUBROUTINE
	; Set the picture to be displayed
	SET_POINTER fxp_pix_base, fxp_test_gfx

	; Set playfield to mirror mode and clear playfield registers
	lda #$01
	sta CTRLPF
	lda #$00
	sta PF0
	sta PF1
	sta PF2

	; Set large sprites
	lda #$07
	sta NUSIZ0
	sta NUSIZ1

	; Position sprites
	m_set_sprite_position 0, #6, #7
	m_set_sprite_position 1, #8, #5

	; Set the colors
	lda #$00
	sta COLUBK
	lda #$7c
	sta COLUPF
	sta COLUP0
	sta COLUP1

	rts

fx_pixscroll_vblank SUBROUTINE
	; Initialize
	m_copy_pointer fxp_pix_base, ptr
	lda frame_cnt
	REPEAT 3
	lsr
	REPEND
	and #$03
	beq .continue
	tax
.rough_move:
	m_add_to_pointer ptr, #30
	dex
	bne .rough_move

.continue:
	; Precompute the first line
	ldx #$00
	ldy #$00
	REPEAT 5
	jsr s_fxp_load_elmt
	REPEND

	; store pix shift in X and tmp
	lda frame_cnt
	and #$07
	sta tmp

	tax
	beq .end
.shift_loop:
	jsr s_fxp_rotate_line_left
	dex
	bne .shift_loop

.end:
	m_add_to_pointer ptr, #1
	m_reverse_pf3buf
	rts

fxp_test_gfx:
	dc.b $00, $9f, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $9f, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $9f, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $9f, $00, $ff, $00, $ff
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00
	dc.b $06, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $06, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $06, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $06, $ff, $00, $ff, $00, $ff
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00
	dc.b $00, $9f, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $9f, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $9f, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $9f, $00, $ff, $00, $ff
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00
	dc.b $06, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $06, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $06, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $06, $ff, $00, $ff, $00, $ff
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00

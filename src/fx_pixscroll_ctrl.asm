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
	and #$07
	bne .no_shift

	; Shift the picture
	inc fxp_shift_i
	lda fxp_shift_i
	cmp #6 ; 6 columns picture
	bne .no_shift
	lda #0
	sta fxp_shift_i

.no_shift
	; no rough repositionning if fxp_shift_i is null
	lda fxp_shift_i
	beq .no_rough

	; Shift the pointer in the image
	; i.e Move the picture by 8 bits
	tax
.rough_move:
	m_add_to_pointer ptr, #30
	dex
	bne .rough_move

.no_rough:
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
	dc.b $00, $00, $00, $00, $00, $00, $00, $1f
	dc.b $00, $00, $78, $fc, $e0, $e0, $f0, $f0
	dc.b $e0, $e0, $e0, $60, $00, $00, $1f, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $1f, $00, $ff, $00, $00
	dc.b $60, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	dc.b $fc, $78, $00, $00, $ff, $00, $1f, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $30
	dc.b $00, $ff, $00, $ff, $00, $00, $64, $e4
	dc.b $e4, $e4, $e4, $e4, $e4, $ec, $fc, $78
	dc.b $00, $00, $ff, $00, $ff, $00, $30, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $e0
	dc.b $00, $ff, $00, $00, $78, $fc, $e0, $e0
	dc.b $f8, $7c, $04, $04, $fc, $78, $00, $00
	dc.b $ff, $00, $e0, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $e0
	dc.b $00, $00, $64, $e4, $e4, $e4, $fc, $fc
	dc.b $e4, $e4, $e4, $64, $00, $00, $e0, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $44, $cc, $00, $00, $fc, $78
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $1f
	dc.b $00, $00, $78, $fc, $e0, $e0, $f0, $f0
	dc.b $e0, $e0, $e0, $60, $00, $00, $1f, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $1f, $00, $ff, $00, $00
	dc.b $60, $e0, $e0, $e0, $e0, $e0, $e0, $e0
	dc.b $fc, $78, $00, $00, $ff, $00, $1f, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $30
	dc.b $00, $ff, $00, $ff, $00, $00, $64, $e4
	dc.b $e4, $e4, $e4, $e4, $e4, $ec, $fc, $78
	dc.b $00, $00, $ff, $00, $ff, $00, $30, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $e0
	dc.b $00, $ff, $00, $00, $78, $fc, $e0, $e0
	dc.b $f8, $7c, $04, $04, $fc, $78, $00, $00
	dc.b $ff, $00, $e0, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $e0
	dc.b $00, $00, $64, $e4, $e4, $e4, $fc, $fc
	dc.b $e4, $e4, $e4, $64, $00, $00, $e0, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $44, $cc, $00, $00, $fc, $78
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00

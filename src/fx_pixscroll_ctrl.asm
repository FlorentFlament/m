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

fx_pixscroll_metro_init SUBROUTINE
	; Set the picture to be displayed
	SET_POINTER fxp_pix_base, fxp_metro_gfx
	SET_POINTER fxp_scr_base, fxp_metro_screens
	jmp fx_pixscroll_init_common

fx_pixscroll_inside_init SUBROUTINE
	; Set the picture to be displayed
	SET_POINTER fxp_pix_base, fxp_inside_gfx
	SET_POINTER fxp_scr_base, fxp_inside_screens
	jmp fx_pixscroll_init_common

fx_pixscroll_init_common SUBROUTINE
	; Set playfield to mirror mode and clear playfield registers
	lda #$01
	sta CTRLPF

	; Set large sprites
	lda #$07
	sta NUSIZ0
	sta NUSIZ1

	; Position sprites
	m_set_sprite_position 0, #6, #7
	m_set_sprite_position 1, #8, #5

	; Sets non-displayable zone and hidden zone to $00
	lda #$00
	sta PF0
	sta PF2

	; Sets displayable zone to $ff
	lda #$ff
	sta PF1
	sta GRP0
	sta GRP1

	; Set the colors
	lda #$00
	sta COLUBK
	sta COLUPF
	sta COLUP0
	sta COLUP1

	; Init counter
	lda #$00
	sta fxp_cnt
	sta fxp_cnt+1

	jmp RTSBank

; This subroutine setups:
; * fxp_pix_ptr
; * fxp_shift_fine
; * fxp_col_ptr
fx_pixscroll_vblank_color SUBROUTINE
	; update color
	SET_POINTER fxp_col_ptr, fxp_test_color
	lda fxp_cnt
	lsr
	lsr
	and #$0f
	sta tmp
	m_add_to_pointer fxp_col_ptr, tmp
	jmp fx_pixscroll_metro_vblank

; This subroutine setups:
; * fxp_pix_ptr
; * fxp_shift_fine
fx_pixscroll_metro_vblank SUBROUTINE
	m_copy_pointer fxp_cnt, ptr
	jmp fx_pixscroll_vblank_common

fx_pixscroll_inside_vblank SUBROUTINE
	m_copy_pointer fxp_cnt, ptr
	; Slow movement
	REPEAT 1
	m_shift_pointer_right ptr
	REPEND
	jmp fx_pixscroll_vblank_common

; ptr signifies the deplacement of the picture
fx_pixscroll_vblank_common SUBROUTINE
	jsr fxp_compute_move

	; Precompute the first line
	ldx #$00
	ldy #$00
	REPEAT 5
	jsr s_fxp_load_elmt
	REPEND

	lda fxp_shift_fine
	beq .end
	tax
.shift_loop:
	jsr s_fxp_rotate_line_left
	dex
	bne .shift_loop

.end:
	m_add_to_pointer fxp_pix_ptr, #1
	m_reverse_pf3buf

	m_add_to_pointer fxp_cnt, 1
	jmp RTSBank

; total shift value (bit wise) must be stored in ptr (word)
; ptr value will be interpreted as follows
; bits 3-0: bit shifting
; bits 5-4: byte shifting
; bite 13-6: screen shifting
fxp_compute_move SUBROUTINE
	; 3 LSBs are used for fine shifting (bit wise)
	lda ptr
	and #$07
	sta fxp_shift_fine

	; Set fxp_pix_ptr according to rough (byte wise) move
	m_copy_pointer fxp_pix_base, fxp_pix_ptr

	; bits 12-4 of ptr are used for rough shifting (byte wise)
	REPEAT 3
	m_shift_pointer_right ptr
	REPEND
	lda ptr
	and #$03
	sta tmp ; byte (i.e rough) shifting

	; Computing screen index
	REPEAT 2
	m_shift_pointer_right ptr
	REPEND
	lda ptr
	and #$0f ; 16 screens for now
	tay

	lda (fxp_scr_base),Y
	beq .no_screen_move
	tax
.screen_move:
	m_add_to_pointer fxp_pix_ptr, #120 ; 120 bytes per screen
	dex
	bne .screen_move

.no_screen_move
	lda tmp ; where we store rough move
	beq .end
	tax
.rough_move:
	m_add_to_pointer fxp_pix_ptr, #30 ; 30 bytes per column
	dex
	bne .rough_move

.end:
	rts

fxp_test_color:
	dc.b $d0, $d2, $d4, $d6, $d8, $da, $dc, $de
	dc.b $80, $82, $84, $86, $88, $8a, $8c, $8e
	dc.b $d0, $d2, $d4, $d6, $d8, $da, $dc, $de
	dc.b $80, $82, $84, $86, $88, $8a, $8c, $8e
	dc.b $d0, $d2, $d4, $d6, $d8, $da, $dc, $de
	dc.b $80, $82, $84, $86, $88, $8a, $8c, $8e

fxp_metro_gfx:
	INCLUDE "fx_pixscroll_data.asm"

fxp_metro_screens:
	dc.b 0, 1, 2, 3, 4, 5, 8, 4, 5, 8, 4, 5, 6, 1, 2, 10

fxp_inside_gfx:
	INCLUDE "fx_pixscroll_data_inside.asm"

fxp_inside_screens:
	dc.b 0, 1, 2, 3, 4, 5, 6, 7
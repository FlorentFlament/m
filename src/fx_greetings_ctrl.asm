fx_greetings_init SUBROUTINE
	INCLUDE "PasteHeck_init.asm"

	; Set the picture to be displayed
	SET_POINTER fxp_pix_base, fxp_greetings_gfx
	SET_POINTER fxp_scr_base, fxp_greetings_screens

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

s_greetz_load_elmt SUBROUTINE
	m_fxp_load_elmt
	rts

s_greetz_rotate_line_left SUBROUTINE
	m_fxp_rotate_line_left
	rts

fx_greetings_vblank SUBROUTINE
	 ; Loop when reaching last screen
 	lda fxp_cnt+1
	cmp #$06
	bmi .continue
	lda fxp_cnt
	cmp #$80
	bmi .continue
	lda #$00
	sta fxp_cnt
	sta fxp_cnt+1

.continue:
	m_copy_pointer fxp_cnt, ptr
	; Slow movement
	REPEAT 2
	m_shift_pointer_right ptr
	REPEND

	jsr greetz_compute_move

	; Precompute the first line
	ldx #$00
	ldy #$00
	REPEAT 5
	jsr s_greetz_load_elmt
	REPEND

	lda fxp_shift_fine
	beq .end
	tax
.shift_loop:
	jsr s_greetz_rotate_line_left
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
greetz_compute_move SUBROUTINE
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


fxp_greetings_screens:
	dc.b 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12

fxp_greetings_gfx:
	INCLUDE "fx_greetings_data.asm"

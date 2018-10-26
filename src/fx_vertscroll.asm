fx_vertscroll_init SUBROUTINE
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

	SET_POINTER fxv_screen_ptr0, (fx_vertscroll_ligneMetro0 + 330)
	SET_POINTER fxv_screen_ptr1, (fx_vertscroll_ligneMetro1 + 330)
	SET_POINTER fxv_screen_ptr2, (fx_vertscroll_ligneMetro2 + 330)
	SET_POINTER fxv_screen_ptr3, (fx_vertscroll_ligneMetro3 + 330)
	jmp RTSBank

fx_vertscroll_vblank SUBROUTINE
	lda frame_cnt
	and #$01
	bne .end
	m_sub_from_pointer fxv_screen_ptr0, #1
	m_sub_from_pointer fxv_screen_ptr1, #1
	m_sub_from_pointer fxv_screen_ptr2, #1
	m_sub_from_pointer fxv_screen_ptr3, #1
.end:
	jmp RTSBank

fx_vertscroll_kernel SUBROUTINE
	ldy #29

	; prepare for kern_loop
	lda #$00
	sta COLUBK
	; Set background color at the very last minute
	;lda (fxp_col_ptr),y
	lda #$3c
	sta COLUP0
	sta COLUP1
	sta COLUPF

	jmp .inner_loop
.bottom_loop:
	ldx #7
.inner_loop:
	sta WSYNC
	lda (fxv_screen_ptr0),Y
	sta PF1
	lda (fxv_screen_ptr1),Y
	sta GRP0
	lda (fxv_screen_ptr2),Y
	sta GRP1
	SLEEP 6
	lda (fxv_screen_ptr3),Y
	sta PF1
	dex
	bpl .inner_loop

	dey
	bpl .bottom_loop

	sta WSYNC

	lda #$ff
	sta PF1
	sta GRP0
	sta GRP1
	lda #$00
	sta COLUPF
	sta COLUP0
	sta COLUP1

	jmp RTSBank

	INCLUDE "fx_vertscroll_data_ligneMetro.asm"
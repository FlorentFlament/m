; Set Foreground color to argument
	MAC m_fxv_setcolor
	lda {1}
	sta COLUPF
	sta COLUP0
	sta COLUP1
	ENDM

fx_vertscroll_init_quaiSouris SUBROUTINE
	; 180 fatlines i.e 1440 thinlines
	; 512 frames
	; using 2.75 lines per frame -> 1408 thinlines
	SET_POINTER fxv_screen_ptr0, (fx_vertscroll_quaiSouris0)
	SET_POINTER fxv_screen_ptr1, (fx_vertscroll_quaiSouris1)
	SET_POINTER fxv_screen_ptr2, (fx_vertscroll_quaiSouris2)
	SET_POINTER fxv_screen_ptr3, (fx_vertscroll_quaiSouris3)
	m_fxv_setcolor #$3c
	jmp fx_vertscroll_init_common

fx_vertscroll_init_mistressStella SUBROUTINE
	; 150 fatlines i.e 1200 thinlines
	; 480 frames
	; 2.5 lines per frame (3+2)/2
	SET_POINTER fxv_screen_ptr0, (fx_vertscroll_mistressStella0)
	SET_POINTER fxv_screen_ptr1, (fx_vertscroll_mistressStella1)
	SET_POINTER fxv_screen_ptr2, (fx_vertscroll_mistressStella2)
	SET_POINTER fxv_screen_ptr3, (fx_vertscroll_mistressStella3)
	m_fxv_setcolor #$9c
	jmp fx_vertscroll_init_common

fx_vertscroll_init_ticketMetro SUBROUTINE
	; 110  fatlines i.e 880 thinlines
	; to fit in 320 frames
	; 2.75 thinlines per frames i.e 11/4 (3+3+3+2)/4
	SET_POINTER fxv_screen_ptr0, (fx_vertscroll_ticketMetro0)
	SET_POINTER fxv_screen_ptr1, (fx_vertscroll_ticketMetro1)
	SET_POINTER fxv_screen_ptr2, (fx_vertscroll_ticketMetro2)
	SET_POINTER fxv_screen_ptr3, (fx_vertscroll_ticketMetro3)
	m_fxv_setcolor #$9c
	jmp fx_vertscroll_init_common

fx_vertscroll_init_ligneMetro SUBROUTINE
	; Height is 330 fatlines i.e 2640 thinlines
	; To fit in 768 frames
	; 330 * 7/2 = 2688 thinlines in 768 frames (4+3)/2
	; i.e 336 fatlines
	SET_POINTER fxv_screen_ptr0, (fx_vertscroll_ligneMetro0)
	SET_POINTER fxv_screen_ptr1, (fx_vertscroll_ligneMetro1)
	SET_POINTER fxv_screen_ptr2, (fx_vertscroll_ligneMetro2)
	SET_POINTER fxv_screen_ptr3, (fx_vertscroll_ligneMetro3)
	m_fxv_setcolor #$3c
	jmp fx_vertscroll_init_common

fx_vertscroll_init_common SUBROUTINE
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

	; Sets graphic registers to 0
	lda #$00
	sta PF0
	sta PF1
	sta PF2
	sta GRP0
	sta GRP1

	; Set FX colors
	lda #$00
	sta COLUBK

	; initialize fx counter
	lda #$00
	sta fxv_cnt

	jmp RTSBank

fx_vertscroll_vblank_mistressStella SUBROUTINE
	lda fxv_cnt
	and #$01
	beq .even

	lda #3
	jmp fx_vertscroll_vblank_common
.even:
	lda #2
	jmp fx_vertscroll_vblank_common

fx_vertscroll_vblank_ligneMetro SUBROUTINE
	lda fxv_cnt
	and #$01
	beq .even

	lda #4
	jmp fx_vertscroll_vblank_common
.even:
	lda #3
	jmp fx_vertscroll_vblank_common

fx_vertscroll_vblank_ticketMetro SUBROUTINE
fx_vertscroll_vblank_quaiSouris
	lda fxv_cnt
	and #$03
	beq .even

	lda #3
	jmp fx_vertscroll_vblank_common
.even:
	lda #2
	jmp fx_vertscroll_vblank_common

fx_vertscroll_vblank_common SUBROUTINE
.next:
	clc
	adc fxv_first_height
	cmp #8
	bmi .keep_line

	and #$07
	sta fxv_first_height
	m_add_to_pointer fxv_screen_ptr0, #1
	m_add_to_pointer fxv_screen_ptr1, #1
	m_add_to_pointer fxv_screen_ptr2, #1
	m_add_to_pointer fxv_screen_ptr3, #1
	jmp .end

.keep_line
	and #$07
	sta fxv_first_height

.end:
	inc fxv_cnt
	jmp RTSBank

fx_vertscroll_kernel SUBROUTINE
	ldy #0
	lda #240
	sta tmp

	lda #7
	sec
	sbc fxv_first_height
	tax

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
	dec tmp
	beq .end_loop
	dex
	bpl .inner_loop

	iny
	jmp .bottom_loop

.end_loop:
	sta WSYNC

	lda #$00
	sta PF1
	sta GRP0
	sta GRP1

	jmp RTSBank

	INCLUDE "fx_vertscroll_data_ligneMetro.asm"
	INCLUDE "fx_vertscroll_data_ticketMetro.asm"
	INCLUDE "fx_vertscroll_data_mistressStella.asm"
	INCLUDE "fx_vertscroll_data_quaiSouris.asm"

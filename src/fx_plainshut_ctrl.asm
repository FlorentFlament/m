; Computes the pattern index into ptr
	MAC m_fxps_compute_pattern
	m_copy_pointer frame_cnt, ptr
	REPEAT 3
	m_shift_pointer_right ptr
	REPEND
	ENDM

; Switch to next shutters color
	MAC m_fxps_next_color
	lda fxps_fg_col
	sta fxps_bg_col ; Turn PF color to background

	; Load new color
	lda fxps_col_i
	and #$03 ; 4 colors for now
	tax
	lda fxps_colors,X
	sta fxps_fg_col

	inc fxps_col_i
	ENDM

fx_plainshut_init SUBROUTINE
	; Not using players
	lda #$00
	sta GRP0
	sta GRP1

	; Setting reasonable colors
	sta fxps_move_i
	sta fxps_col_i
	tax
	lda fxps_colors,X
	sta fxps_fg_col

	inc fxps_col_i
	m_fxps_next_color

	jmp RTSBank

fx_plainshut_vblank SUBROUTINE
	lda frame_cnt
	and #$07
	bne .no_change

	; Compute next pattern into ptr (16 bits)
	m_fxps_compute_pattern

	; if last move wasn't a nop, switch colors
	lda fxps_move_i
	beq .no_color_switch
	m_fxps_next_color

.no_color_switch:
	; Setup next move
	lda ptr
	and #$3f ; 64 patterns for now
	tax
	lda fxps_patterns,X
	sta fxps_move_i
	beq .no_change

.no_change:
	jsr fxps_call_vblank
	jmp RTSBank

fxps_call_vblank SUBROUTINE
	lda fxps_move_i
	asl
	tax
	lda fxps_vblanks+1,X
	pha
	lda fxps_vblanks,X
	pha
	rts

; Just clear playfield registers
	MAC m_fxps_clear_pf
	lda #$00
	sta PF0
	sta PF1
	sta PF2
	ENDM

fxps_vblank_nop SUBROUTINE
	m_fxps_clear_pf
	rts

fxps_vblank_topdown SUBROUTINE
	m_fxps_clear_pf
	lda frame_cnt
	and #$07 ; 3 LSBs (i.e 8 frames) patterns
	REPEAT 5
	asl
	REPEND
	sta fxps_m0_cnt
	rts

fxps_vblanks:
	.word (fxps_vblank_nop - 1)
	.word (fxps_vblank_topdown - 1)
	.word (fxps_vblank_nop - 1) ; Same vblank for nop and Switch
	.word (fxps_vblank_topdown - 1) ; Same vblank for topdown and bottomup

fxps_patterns:
	.byte 0, 0, 0, 0, 1, 0, 0, 0
	.byte 0, 0, 0, 0, 1, 0, 0, 0
	.byte 0, 0, 0, 0, 3, 0, 0, 0
	.byte 0, 0, 0, 0, 3, 0, 0, 0
	.byte 0, 0, 0, 0, 1, 0, 0, 0
	.byte 0, 0, 0, 0, 3, 0, 0, 0
	.byte 2, 2, 2, 0, 1, 0, 1, 0
	.byte 3, 0, 3, 0, 2, 2, 2, 2

fxps_colors:
	.byte $00, $8c, $9c, $2c
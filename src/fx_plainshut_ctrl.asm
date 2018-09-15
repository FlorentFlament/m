; Computes the pattern index into ptr
	MAC m_fxps_compute_pattern
	m_copy_pointer fxps_cnt, ptr
	REPEAT 3
	m_shift_pointer_right ptr
	REPEND
	ENDM

; Switch to next shutters color
	MAC m_fxps_next_color

	; Load new color
	lda fxps_col_i
	and #$1f ; 32 colors for now
	tax
	lda fxps_colors,X
	; if the color didn't change, don't switch
	cmp fxps_fg_col
	beq .end

	sta tmp
	lda fxps_fg_col
	sta fxps_bg_col ; Turn PF color to background
	lda tmp
	sta fxps_fg_col

.end:
	inc fxps_col_i
	ENDM

fx_plainshut_init SUBROUTINE
	; Doing some cleanup
	lda #$00
	sta CTRLPF ; Set playfield in non mirror mode
	sta GRP0
	sta GRP1
	sta PF0
	sta PF1
	sta PF2
	sta COLUP0
	sta COLUP1
	sta COLUBK
	sta COLUPF

	; Setting reasonable colors
	sta fxps_move_i
	sta fxps_col_i
	tax
	lda fxps_colors,X
	sta fxps_fg_col

	inc fxps_col_i
	m_fxps_next_color

	; Initializing counter
	lda #$00
	sta fxps_cnt
	sta fxps_cnt+1

	jmp RTSBank

fx_plainshut_vblank SUBROUTINE
	lda fxps_cnt
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

	m_add_to_pointer fxps_cnt, 1
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
	lda fxps_cnt
	and #$07 ; 3 LSBs (i.e 8 frames) patterns
	REPEAT 5
	asl
	REPEND
	sta fxps_m0_cnt
	rts

fxps_vblank_leftright SUBROUTINE
	m_fxps_clear_pf
	; Setup initial mask index
	lda fxps_cnt
	and #$07
	; multiply fxps_cnt by 6
	asl
	sta fxps_m0_i
	asl
	clc
	adc fxps_m0_i
	sta fxps_m0_i
	rts

fxps_vblank_vertstripe SUBROUTINE
	m_fxps_clear_pf
	lda #0
	sta fxps_m0_i
	rts

fxps_vblanks:
	.word (fxps_vblank_nop - 1)
	.word (fxps_vblank_nop - 1) ; Same vblank for nop and Switch
	.word (fxps_vblank_topdown - 1)
	.word (fxps_vblank_topdown - 1) ; Same vblank for topdown and bottomup
	.word (fxps_vblank_leftright - 1)
	.word (fxps_vblank_leftright - 1) ; Same vblank for leftright and rightleft
	.word (fxps_vblank_vertstripe - 1)
	.word (fxps_vblank_vertstripe - 1)
	.word (fxps_vblank_vertstripe - 1)

fxps_leftright_pf:
	.byte $00, $00, $00, $00, $00, $00
	.byte $f0, $80, $00, $00, $00, $00
	.byte $f0, $fc, $00, $00, $00, $00
	.byte $f0, $ff, $07, $00, $00, $00
	.byte $f0, $ff, $ff, $00, $00, $00
	.byte $f0, $ff, $ff, $f0, $80, $00
	.byte $f0, $ff, $ff, $f0, $fc, $00
	.byte $f0, $ff, $ff, $f0, $ff, $07

fxps_rightleft_pf:
	.byte $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $f8
	.byte $00, $00, $00, $00, $03, $ff
	.byte $00, $00, $00, $00, $7f, $ff
	.byte $00, $00, $00, $f0, $ff, $ff
	.byte $00, $00, $f8, $f0, $ff, $ff
	.byte $00, $03, $ff, $f0, $ff, $ff
	.byte $00, $7f, $ff, $f0, $ff, $ff

fxps_patterns:
	.byte 0, 0, 0, 0, 2, 0, 0, 0
	.byte 0, 0, 0, 0, 4, 0, 0, 0
	.byte 0, 0, 0, 0, 3, 0, 0, 0
	.byte 0, 0, 0, 0, 5, 0, 0, 0
	.byte 0, 0, 0, 0, 2, 0, 0, 0
	.byte 0, 0, 0, 0, 3, 0, 0, 0
	.byte 1, 1, 1, 0, 2, 0, 4, 0
	.byte 3, 0, 5, 0, 1, 6, 7, 8

fxps_colors:
	.byte $00, $3c, $9c, $8c, $00, $3c, $9c, $8c
	.byte $3c, $9c, $8c, $3c, $9c, $8c, $00, $3c
	.byte $3c, $3c

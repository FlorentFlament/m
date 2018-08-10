SHNOTE_LEN = 20 ; 25 frames = half a second

fx_shutters_init SUBROUTINE
	; Initializing playfield data pointers
	lda #<gfx_test_pf0
	sta gfx_pf_base+0
	lda #>gfx_test_pf0
	sta gfx_pf_base+1

	lda #<gfx_test_pf1
	sta gfx_pf_base+2
	lda #>gfx_test_pf1
	sta gfx_pf_base+3

	lda #<gfx_test_pf2
	sta gfx_pf_base+4
	lda #>gfx_test_pf2
	sta gfx_pf_base+5

	lda #<gfx_test_pf3
	sta gfx_pf_base+6
	lda #>gfx_test_pf3
	sta gfx_pf_base+7

	lda #<gfx_test_pf4
	sta gfx_pf_base+8
	lda #>gfx_test_pf4
	sta gfx_pf_base+9

	lda #<gfx_test_pf5
	sta gfx_pf_base+10
	lda #>gfx_test_pf5
	sta gfx_pf_base+11

	; Setting reasonable colors
	lda #$00
	sta COLUBK
	lda #$8c
	sta COLUPF

	rts


; fills mask provided as argument with a value
; ex: fill_mask mask_m0_val
	MAC fill_mask
I	SET 0
	REPEAT 6
	sta {1} + I
I	SET I + 1
	REPEND
	ENDM

fxs_full_top_down SUBROUTINE
	lda shnote_cnt
	cmp #8 ; 30 lines 4by4
	bpl .move_done
.move_progress:
	asl
	asl
	sta mask_m0_cnt
	lda #30
	sec
	sbc mask_m0_cnt
	sta mask_m1_cnt
	jmp .end
.move_done:
	lda #30
	sta mask_m0_cnt
	lda #0
	sta mask_m1_cnt
.end:
	rts

fxs_full_enter_top SUBROUTINE
	lda #$00
	fill_mask mask_m1_val
	lda #$ff
	fill_mask mask_m0_val
	jsr fxs_full_top_down
	rts

fxs_full_exit_bottom SUBROUTINE
	lda #$ff
	fill_mask mask_m1_val
	lda #$00
	fill_mask mask_m0_val
	jsr fxs_full_top_down
	rts

; Shifts 6 bytes mask
; mask address has to be passed as argument
; Value to put as msb of byte 0 must be in Y
; ex: ldy #$01
;     m_shift_mask_right mask_m0_val
	MAC m_shift_mask_right
	; Save PF2 MSB and position in for PF3
	lda {1} + 2
	and #$80
	REPEAT 3
	lsr
	REPEND
	sta tmp
	ora #$ef
	sta tmp1
	; Do the shiftings
	rol {1} + 0
	ror {1} + 1
	rol {1} + 2
	rol {1} + 3
	ror {1} + 4
	rol {1} + 5
	; Fix PF3
	lda {1} + 3
	ora tmp
	and tmp1
	sta {1} + 3
	; Fix PF0
	tya
	REPEAT 4
	asl
	REPEND
	sta tmp
	ora #$ef
	sta tmp1
	lda {1}
	ora tmp
	and tmp1
	sta {1}
	ENDM

fxs_shift_m0_right SUBROUTINE
	m_shift_mask_right mask_m0_val
	rts

fxs_only_m0 SUBROUTINE
	; Only use mask m0
	lda #30
	sta mask_m0_cnt
	lda #0
	sta mask_m1_cnt
	sta mask_m2_cnt
	rts

; Left to Right move
; Argument is the initial mask value #$00 or #$ff
	MAC m_left_right_move
	lda shnote_cnt
	beq .move_init
	cmp #10 ; 40 lines 4by4
	bpl .move_done
	ldy ~{1} & #$01
	ldx #$04
.shift_loop:
	jsr fxs_shift_m0_right
	dex
	bpl .shift_loop
	jmp .end
.move_init:
	jsr fxs_only_m0
	; Initialize m0 to $00,$00,..,$00
	lda {1}
	fill_mask mask_m0_val
	jmp .end
.move_done:
	lda ~{1}
	fill_mask mask_m0_val
.end:
	ENDM

fxs_full_enter_left SUBROUTINE
	m_left_right_move #$00
	rts

fxs_full_exit_right SUBROUTINE
	m_left_right_move #$ff
	rts

fxs_call_move SUBROUTINE
	lda shtime_cnt
	and #$07
	tax
	lda fx_shutters_timeline,X
	asl
	tax
	ldy fx_shutters_moves,X
	inx
	lda fx_shutters_moves,X
	pha
	tya
	pha
	rts

fx_shutters_vblank SUBROUTINE
	jsr fxs_call_move

.house_keep:
	inc shnote_cnt
	lda shnote_cnt
	cmp SHNOTE_LEN
	bmi .end
	lda #0
	sta shnote_cnt
	inc shtime_cnt
.end:
	rts


fx_shutters_moves:
	dc.w fxs_full_enter_top - 1
	dc.w fxs_full_exit_bottom - 1
	dc.w fxs_full_enter_left - 1
	dc.w fxs_full_exit_right - 1

fx_shutters_timeline:
	dc.b $00, $01, $02, $03, $00, $03, $02, $01

gfx_test_pf0:
	dc.b $00, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $ff, $00, $ff, $00, $ff

gfx_test_pf1:
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00

gfx_test_pf2:
	dc.b $00, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $ff, $00, $ff, $00, $ff

gfx_test_pf3:
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00

gfx_test_pf4:
	dc.b $00, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $ff, $00, $ff, $00, $ff, $00, $ff
	dc.b $00, $ff, $00, $ff, $00, $ff

gfx_test_pf5:
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00, $ff, $00
	dc.b $ff, $00, $ff, $00, $ff, $00

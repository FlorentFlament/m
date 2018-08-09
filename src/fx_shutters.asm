fx_shutters_init:
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

	; Initializing frame buffer 0
	lda #$00
	sta fb0_base+0
	sta fb0_base+2
	sta fb0_base+4
	lda #$ff
	sta fb0_base+1
	sta fb0_base+3
	sta fb0_base+5

	; Initializing mask
	lda #$ff
	sta mask_m0_val
	sta mask_m0_val+1
	lda #$00
	sta mask_m0_val+2
	sta mask_m0_val+3
	sta mask_m0_val+4
	sta mask_m0_val+5

	lda #$ff
	sta mask_m1_val
	sta mask_m1_val+1
	sta mask_m1_val+2
	lda #$00
	sta mask_m1_val+3
	sta mask_m1_val+4
	sta mask_m1_val+5

	lda #8
	sta mask_m0_cnt
	lda #12
	sta mask_m1_cnt

	; Setting reasonable colors
	lda #$00
	sta COLUBK
	lda #$ff
	sta COLUPF

	rts

	; Flushes a buffer to actual PF0 - PF2 registers
	; The buffer to flush must be passed as argument
	; ex: m_pf_flush fb0_base
	MAC m_pf_flush
	lda {1} + 0
	sta PF0
	lda {1} + 1
	sta PF1
	lda {1} + 2
	sta PF2
	ENDM

	; Flushes a full line to the screen.
	; The macro calls m_pf_flush for the left part of the screen
          ; then for the right part.
	; The frame buffer base address must be passed as argument.
	; ex: m_line_flush fb0_base
	MAC m_line_flush
	m_pf_flush {1} + 0 ; Left screen part
	REPEAT 3
	nop
	REPEND
	m_pf_flush {1} + 3 ; Right screen part
	ENDM

fb0_flush:
	m_line_flush fb0_base
	rts

fb1_flush:
	m_line_flush fb1_base
	rts

	; Updates a frame buffer element from
	; * the graph pointed at by gfx_pf_base
	; * the frame buffer address provided as 1st argument
	; * the mask to apply provided as 2ns argument
	; * the frame buffer element provided as 3rd argument
	; * y's value must be the index of the GFX line to fetch
	; ex: m_update_db fb1_base,mask_m0_val,2
	MAC m_update_fb
	lda (gfx_pf_base + {3}*2),y
	ora {2} + {3}
	sta {1} + {3}
	ENDM

	MAC m_two_lines
	; Flushing fb0 and updating fb1
	; the mask to apply provided as argument
I	SET 0
	REPEAT 6
	sta WSYNC
	jsr fb0_flush
	m_update_fb fb1_base,{1},I
I	SET I + 1
	REPEND
	REPEAT 2
	sta WSYNC
	jsr fb0_flush
	REPEND
	dey

	; Flushing fb1 and updating fb0
I	SET 0
	REPEAT 6
	sta WSYNC
	jsr fb1_flush
	m_update_fb fb0_base,{1},I
I	SET I + 1
	REPEND
	REPEAT 2
	sta WSYNC
	jsr fb1_flush
	REPEND
	dey
	ENDM

fx_shutters_kernel:
	ldy mask_m0_cnt
	bne .m0_block
	jmp .mask_m1
.m0_block	dey
.m0_loop	m_two_lines mask_m0_val
	bmi .mask_m1
	jmp .m0_loop

.mask_m1	ldy mask_m1_cnt
	bne .m1_block
	jmp .mask_m2
.m1_block	dey
.m1_loop	m_two_lines mask_m1_val
	bmi .mask_m2
	jmp .m1_loop

.mask_m2	ldy mask_m2_cnt
	bne .m2_block
	jmp .kernend
.m2_block	dey
.m2_loop	m_two_lines mask_m2_val
	bmi .kernend
	jmp .m2_loop

.kernend
	sta WSYNC
	lda #$00
	sta PF0
	sta PF1
	sta PF2
	rts


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

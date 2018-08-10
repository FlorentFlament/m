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

	; Initializing frame buffer 0
	lda #$00
	sta fb0_base+0
	sta fb0_base+2
	sta fb0_base+4
	lda #$ff
	sta fb0_base+1
	sta fb0_base+3
	sta fb0_base+5

	lda #$00
	sta fb_switch

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


fx_shutters_vblank SUBROUTINE
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

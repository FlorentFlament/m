fx_intro_kernel SUBROUTINE
	lda fxi_logo_pos
	cmp #80 ; Logo height
	bpl .call_fxi_slide
	jsr fxi_enter
	jmp .end
.call_fxi_slide
	sec
	sbc #80
	tax
	jsr fxi_slide

.end:
	lda #$00
	sta PF0
	sta PF1
	sta PF2
	jmp RTSBank

fxi_enter SUBROUTINE
	rts

; X register must contain the desired logo position in [0, 160]
fxi_slide SUBROUTINE
	; Beware subtlety. The first WSYNC there ends the last blank
	; line. So this top_loop only skips fxi_logo_pos-1
	; lines. The last line to be skipped is done by the first
	; WSYNC of the bottom_loop. And the last line displayed by
	; the WSYNC after the bottom loop.
	beq .skip_top
.top_loop:
	sta WSYNC
	dex
	bne .top_loop

.skip_top:
	ldx #0
.bottom_loop:
	ldy #7
.inner_loop:
	sta WSYNC
.skip_sync
	lda fx_intro_gfx,X
	sta PF0
	lda fx_intro_gfx+1,X
	sta PF1
	lda fx_intro_gfx+2,X
	sta PF2
	SLEEP 6
	lda fx_intro_gfx+3,X
	sta PF0
	lda fx_intro_gfx+4,X
	sta PF1
	lda fx_intro_gfx+5,X
	sta PF2
	dey
	bpl .inner_loop

	txa
	clc
	adc #6
	tax
	cpx #60 ; after the picture
	bmi .bottom_loop

	sta WSYNC
	rts


fx_intro_gfx:
	.byte $00, $00, $f0, $f0, $00, $00
	.byte $00, $00, $f0, $f0, $00, $00
	.byte $00, $00, $f0, $f0, $00, $00
	.byte $00, $00, $f0, $f0, $00, $00
	.byte $00, $00, $f0, $f0, $00, $00
	.byte $00, $00, $0f, $00, $f0, $00
	.byte $00, $0f, $00, $00, $0f, $00
	.byte $00, $f0, $00, $00, $00, $0f
	.byte $f0, $00, $00, $00, $00, $f0
	.byte $f0, $00, $00, $00, $00, $f0

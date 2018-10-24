fx_intro_kernel SUBROUTINE
	lda fxi_logo_pos
	beq .end
	cmp #80 ; Logo height
	bpl .call_fxi_slide
	jsr fxi_enter
	jmp .end
.call_fxi_slide
	sec
	sbc #80
	sta tmp
	jsr fxi_slide

.end:
	lda #$00
	sta PF0
	sta PF1
	sta PF2

	; skip remaining kernel lines
	lda #240
	sec
	sbc fxi_logo_pos
	tax
.bottom_loop:
	sta WSYNC
	dex
	bne .bottom_loop

	lda #$00
	sta COLUBK
	jmp RTSBank

fxi_enter SUBROUTINE
	lda #80
	sec
	sbc fxi_logo_pos
	tax
	and #$07 ; inter-line displacement
	sta tmp
	lda #$07
	sec
	sbc tmp
	tay
	txa
	and #$f8 ; line offset
	lsr ; /2
	sta tmp
	lsr ; /4
	clc
	adc tmp

	tax
	jsr fxi_display
	rts

; tmp register must contain the desired logo position in [0, 160]
fxi_slide SUBROUTINE
	; Beware subtlety. The first WSYNC there ends the last blank
	; line. So this top_loop only skips fxi_logo_pos-1
	; lines. The last line to be skipped is done by the first
	; WSYNC of the bottom_loop. And the last line displayed by
	; the WSYNC after the bottom loop.
	ldx tmp
	beq .skip_top
.top_loop:
	sta WSYNC
	lda #$3c
	sta COLUBK
	dex
	bne .top_loop

.skip_top:
	ldx #0
	ldy #7
	jsr fxi_display
	rts

; X register must index of the first line of the logo to display.
; Y register must index the number of pixel lines of the first logo line to display.
; if X=0, the whole logo will be displayed
; if Y=7, only y logo lines will be displayed
fxi_display SUBROUTINE
	jmp .inner_loop
.bottom_loop:
	ldy #7
.inner_loop:
	sta WSYNC
	lda #$3c
	sta COLUBK
	lda fx_intro_gfx,X
	sta PF0
	lda fx_intro_gfx+1,X
	sta PF1
	lda fx_intro_gfx+2,X
	sta PF2
	SLEEP 2
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
	dc.b $0f, $00, $00, $0f, $00, $00
	dc.b $0f, $00, $00, $0f, $00, $00
	dc.b $0f, $07, $c6, $2f, $ed, $00
	dc.b $0f, $0e, $c6, $af, $8d, $00
	dc.b $0f, $0c, $c6, $2f, $cf, $00
	dc.b $0f, $0e, $c6, $2f, $6d, $00
	dc.b $0f, $0c, $c6, $af, $ed, $00
	dc.b $0f, $0c, $dc, $9f, $cd, $00
	dc.b $0f, $00, $00, $0f, $00, $00
	dc.b $0f, $00, $00, $0f, $00, $00

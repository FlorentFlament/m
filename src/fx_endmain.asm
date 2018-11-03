fx_endmain_init SUBROUTINE
	lda #$01
	sta CTRLPF

	lda #$00
	sta PF0
	sta PF1
	sta PF2
	sta GRP0
	sta GRP1
	sta COLUBK

	lda #$3c
	sta COLUPF

	lda #$00
	sta fxe_cnt
	sta fxe_idx


fx_endmain_vblank SUBROUTINE
	lda fxe_cnt
	cmp #50
	bmi .wait
	cmp #70
	bpl .end
	inc fxe_idx

.wait:
	inc fxe_cnt
.end:
	jmp RTSBank


fx_endmain_kernel SUBROUTINE
	ldx fxe_idx
	sta WSYNC

	lda #$ff
	sta PF0
	sta PF1
	sta PF2
	ldy #178
.top_loop:
	sta WSYNC
	dey
	bne .top_loop

	lda fx_endmain_pf0,X
	sta PF0
	lda fx_endmain_pf1,X
	sta PF1
	lda fx_endmain_pf2,X
	sta PF2
	REPEAT 2
	sta WSYNC
	REPEND

	lda #$ff
	sta PF0
	sta PF1
	sta PF2
	ldy #60
.bottom_loop:
	sta WSYNC
	dey
	bne .bottom_loop

	lda #$00
	sta PF0
	sta PF1
	sta PF2

	jmp RTSBank


fx_endmain_pf0:
	dc.b $00, $10, $30, $70, $f0
	dc.b $f0, $f0, $f0, $f0, $f0
	dc.b $f0, $f0, $f0, $f0, $f0
	dc.b $f0, $f0, $f0, $f0, $f0
	dc.b $f0
fx_endmain_pf1:
	dc.b $00, $00, $00, $00, $00
	dc.b $80, $c0, $e0, $f0, $f8
	dc.b $fc, $fe, $ff, $ff, $ff
	dc.b $ff, $ff, $ff, $ff, $ff
	dc.b $ff
fx_endmain_pf2:
	dc.b $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $01, $03
	dc.b $07, $0f, $1f, $3f, $7f
	dc.b $ff


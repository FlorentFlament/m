fx_animation_init SUBROUTINE
	lda #$00
	sta CTRLPF ; Set playfield in non mirror mode
	sta GRP0
	sta GRP1
	sta PF0
	sta PF1
	sta PF2

	lda #$00
	sta COLUBK
	lda #$3c
	sta COLUPF

	jmp RTSBank

fx_animation_vblank SUBROUTINE
I	SET 0
	REPEAT 6
	SET_POINTER fxa_pf0_ptr+2*I, fxa_lapinmainA+30*I
I	SET I+1
	REPEND
	jmp RTSBank

fx_animation_kernel SUBROUTINE
	ldy #29
.outer_loop:
	ldx #7
.inner_loop:
	sta WSYNC
	lda (fxa_pf0_ptr),Y
	sta PF0
	lda (fxa_pf1_ptr),Y
	sta PF1
	lda (fxa_pf2_ptr),Y
	sta PF2
	lda (fxa_pf3_ptr),Y
	sta PF0
	lda (fxa_pf4_ptr),Y
	sta PF1
	lda (fxa_pf5_ptr),Y
	sta PF2
	dex
	bpl .inner_loop
	dey
	bpl .outer_loop

	sta WSYNC
	lda #0
	sta PF0
	sta PF1
	sta PF2
	jmp RTSBank

fxa_lapinmainA:
	dc.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $fd, $fd, $fd, $fd, $fd, $fc, $fa, $f9, $fa, $fd, $fc, $fd, $3d, $dd, $dd
	dc.b $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $3d, $fd
	dc.b $ff, $ff, $ff, $ff, $ff, $fe, $fd, $fa, $01, $be, $83, $3a, $02, $fd, $7d
	dc.b $bd, $5d, $dd, $bd, $7d, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $03, $ff
	dc.b $60, $60, $e0, $c0, $90, $b0, $b0, $b0, $60, $50, $30, $70, $e0, $00, $f0
	dc.b $80, $70, $f0, $b0, $10, $a0, $10, $b0, $b0, $b0, $b0, $b0, $b0, $c0, $f0
	dc.b $ef, $67, $77, $33, $bb, $f5, $86, $7b, $fb, $fb, $fb, $f6, $fc, $fb, $07
	dc.b $c7, $e7, $a7, $17, $b0, $ff, $68, $67, $50, $57, $ab, $ab, $9b, $a8, $b3
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0e, $0e, $0e, $0e, $0f, $00, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0e, $0d, $0a, $07, $08, $0f, $0f, $0f, $00, $0f

fxa_lapinmainB:
	dc.b $0f, $20, $08, $0f, $d0, $c3
	dc.b $ff, $10, $a8, $8f, $22, $90
	dc.b $0f, $25, $44, $4f, $09, $a0
	dc.b $af, $22, $04, $9f, $05, $4a
	dc.b $4f, $20, $09, $5f, $9e, $44
	dc.b $0f, $90, $f5, $8f, $22, $90
	dc.b $0f, $98, $45, $4f, $09, $9e
	dc.b $ef, $62, $04, $9f, $a0, $50
	dc.b $4f, $20, $e9, $2f, $f2, $44
	dc.b $0f, $a2, $97, $4f, $22, $30

fxa_lapinmainC:
	dc.b $0f, $24, $00, $0f, $d0, $43
	dc.b $2f, $00, $a8, $8f, $22, $02
	dc.b $0f, $25, $44, $4f, $40, $a0
	dc.b $af, $22, $24, $0f, $05, $4a
	dc.b $4f, $24, $00, $5f, $9e, $44
	dc.b $2f, $00, $f5, $8f, $22, $02
	dc.b $0f, $98, $45, $4f, $40, $9e
	dc.b $ef, $62, $24, $0f, $a0, $50
	dc.b $4f, $24, $e8, $2f, $f2, $44
	dc.b $2f, $22, $97, $4f, $22, $22

fxa_lapinmainD:
	dc.b $0f, $24, $00, $0f, $d0, $43
	dc.b $2f, $00, $a8, $8f, $22, $02
	dc.b $0f, $25, $44, $4f, $40, $a0
	dc.b $af, $22, $24, $0f, $05, $4a
	dc.b $4f, $24, $00, $5f, $9e, $44
	dc.b $2f, $00, $f5, $8f, $22, $02
	dc.b $0f, $98, $45, $4f, $40, $9e
	dc.b $ef, $62, $24, $0f, $a0, $50
	dc.b $4f, $24, $e8, $2f, $f2, $44
	dc.b $2f, $22, $97, $4f, $22, $23


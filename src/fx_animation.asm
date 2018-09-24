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
	lda fxa_cnt
	lsr
	lsr
	lsr
	lsr
	;and #$0f
	tax
	lda fxa_timeline,X
	asl
	tax
	lda fxa_pics,X
	sta ptr
	lda fxa_pics+1,X
	sta ptr+1

	SET_POINTER tmp, fxa_pf0_ptr ; Using tmp & tmp1 as pointer

	ldy #0
	ldx #5
.loop:
	lda ptr
	sta (tmp),Y
	m_add_to_pointer tmp, #1
	lda ptr+1
	sta (tmp),Y
	m_add_to_pointer tmp, #1
	m_add_to_pointer ptr, #30
	dex
	bpl .loop

	inc fxa_cnt
	jmp RTSBank

fx_animation_kernel SUBROUTINE
	sta WSYNC
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
	dc.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $fd, $fd, $fd, $fd, $fd, $fc, $fa, $f9, $fa, $fd, $fc, $fd, $3c, $dd, $dd
	dc.b $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $3c, $fd
	dc.b $7f, $7f, $7f, $7f, $7f, $7e, $3d, $3a, $01, $be, $83, $3a, $72, $6d, $6f
	dc.b $af, $4f, $cf, $af, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $6f, $70, $7f
	dc.b $60, $60, $e0, $c0, $90, $b0, $b0, $b0, $60, $50, $30, $70, $e0, $00, $f0
	dc.b $80, $70, $f0, $b0, $10, $a0, $10, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
	dc.b $ee, $66, $76, $32, $ba, $f4, $86, $7b, $fb, $fb, $fb, $f6, $fc, $fa, $06
	dc.b $ce, $ee, $ae, $16, $b0, $ff, $68, $67, $50, $56, $aa, $aa, $da, $ea, $f2
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0e, $0e, $0c, $0e, $0e, $0f, $07, $0b, $0b
	dc.b $0b, $0b, $0b, $0b, $0b, $0a, $09, $0a, $07, $08, $0b, $0b, $0b, $07, $0f

fxa_lapinmainC:
	dc.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $fd, $fd, $fd, $fd, $fd, $fc, $fc, $fd, $fc, $fd, $fc, $fd, $3d, $dd, $dd
	dc.b $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $3d, $fd
	dc.b $fd, $fd, $fd, $fd, $fd, $fc, $fd, $fa, $01, $be, $83, $3a, $fa, $fd, $7d
	dc.b $3d, $dd, $dd, $bd, $7d, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd
	dc.b $60, $60, $e0, $c0, $90, $b0, $b0, $b0, $60, $50, $30, $70, $e0, $00, $f0
	dc.b $b0, $c0, $f0, $b0, $10, $a0, $10, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
	dc.b $ef, $67, $77, $33, $bb, $f5, $86, $7b, $fb, $fb, $fb, $f6, $fd, $fb, $07
	dc.b $cf, $ef, $af, $17, $b0, $ff, $68, $67, $50, $57, $ab, $ab, $db, $eb, $f3
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0e, $0e, $0e, $0e, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0e, $0d, $0a, $07, $08, $0f, $0f, $0f, $0f, $0f

fxa_lapinmainD:
	dc.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $fd, $fd, $e5, $f1, $f1, $d8, $80, $e1, $f0, $f1, $c0, $80, $18, $d0, $d1
	dc.b $c5, $cd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $dd, $3d, $fd
	dc.b $fd, $fd, $f5, $f1, $f8, $98, $c1, $e2, $01, $be, $83, $32, $e2, $c0, $70
	dc.b $30, $c4, $dc, $bd, $7d, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd
	dc.b $60, $60, $e0, $c0, $90, $b0, $b0, $b0, $60, $50, $30, $70, $e0, $00, $f0
	dc.b $b0, $c0, $f0, $b0, $10, $a0, $10, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
	dc.b $ef, $67, $77, $33, $bb, $f5, $86, $7b, $fb, $fb, $fb, $f6, $fd, $fb, $07
	dc.b $cf, $ef, $af, $17, $b0, $ff, $68, $67, $50, $57, $ab, $ab, $db, $eb, $f3
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0e, $0e, $0e, $0e, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0e, $0d, $0a, $07, $08, $0f, $0f, $0f, $0f, $0f

fxa_pics:
	dc.w fxa_lapinmainA
	dc.w fxa_lapinmainB
	dc.w fxa_lapinmainC
	dc.w fxa_lapinmainD

fxa_timeline:
	dc.b 0, 0, 1, 1, 1, 1, 2, 2
	dc.b 2, 2, 3, 3, 2, 2, 3, 3

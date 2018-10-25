fx_vertscroll_init SUBROUTINE
	; Set playfield to mirror mode and clear playfield registers
	lda #$01
	sta CTRLPF

	; Set large sprites
	lda #$07
	sta NUSIZ0
	sta NUSIZ1

	; Position sprites
	m_set_sprite_position 0, #6, #7
	m_set_sprite_position 1, #8, #5

	; Sets non-displayable zone and hidden zone to $00
	lda #$00
	sta PF0
	sta PF2

	; Sets displayable zone to $ff
	lda #$ff
	sta PF1
	sta GRP0
	sta GRP1

	; Set the colors
	lda #$00
	sta COLUBK
	sta COLUPF
	sta COLUP0
	sta COLUP1

	lda #0
	sta fxv_x
	lda #7
	sta fxv_y
	jmp RTSBank

fx_vertscroll_vblank SUBROUTINE
	lda fxv_x
	clc
	adc #6
	sta fxv_x
	jmp RTSBank

fx_vertscroll_kernel SUBROUTINE
	lda #30
	sta tmp
	ldx fxv_x
	ldy fxv_y

	; prepare for kern_loop
	lda #$00
	sta COLUBK
	; Set background color at the very last minute
	;lda (fxp_col_ptr),y
	lda #$3c
	sta COLUP0
	sta COLUP1
	sta COLUPF

	jmp .inner_loop
.bottom_loop:
	ldy #7
.inner_loop:
	sta WSYNC
	lda fx_vertscroll_test,X
	sta PF1
	lda fx_vertscroll_test+1,X
	sta GRP0
	lda fx_vertscroll_test+2,X
	sta GRP1
	SLEEP 2
	lda fx_vertscroll_test+3,X
	sta PF1
	dey
	bpl .inner_loop

	txa
	clc
	adc #4
	tax
	dec tmp
	bne .bottom_loop

	sta WSYNC

	lda #$ff
	sta PF1
	sta GRP0
	sta GRP1
	lda #$00
	sta COLUPF
	sta COLUP0
	sta COLUP1

	jmp RTSBank

fx_vertscroll_test:
	dc.b $ff, $33, $d5, $95, $55, $b5, $ff, $ff
	dc.b $00, $ff, $fe, $fd, $fb, $fa, $f6, $f6
	dc.b $ee, $de, $df, $de, $e8, $f0, $f0, $e0
	dc.b $e0, $e0, $c4, $cc, $8c, $9c, $ff, $de
	dc.b $df, $9f, $5e, $3f, $ff, $ff, $00, $ff
	dc.b $0f, $f7, $1b, $eb, $4d, $ed, $ae, $ef
	dc.b $5f, $07, $42, $01, $41, $00, $40, $00
	dc.b $44, $04, $44, $06, $ff, $6e, $ae, $2e
	dc.b $ae, $73, $ff, $ff, $00, $ff, $ff, $ff
	dc.b $ff, $ff, $ff, $ff, $ff, $7f, $7f, $7f
	dc.b $fe, $fd, $fb, $fb, $fb, $f6, $f6, $f6
	dc.b $7b, $7b, $ff, $f8, $fd, $fd, $fd, $3d
	dc.b $ff, $ff, $00, $ff, $ff, $ff, $e0, $c0
	dc.b $9f, $95, $9f, $9b, $df, $8e, $40, $ce
	dc.b $ce, $80, $55, $aa, $55, $aa, $55, $2a
	dc.b $ff, $ad, $aa, $89, $ab, $ac, $ff, $ff
	dc.b $00, $ff, $ff, $ff, $ff, $7f, $3f, $3f
	dc.b $3f, $3f, $7f, $3f, $4f, $77, $7b, $3b
	dc.b $ff, $33, $d5, $95, $55, $b5, $ff, $ff
	dc.b $00, $ff, $fe, $fd, $fb, $fa, $f6, $f6
	dc.b $ee, $de, $df, $de, $e8, $f0, $f0, $e0
	dc.b $e0, $e0, $c4, $cc, $8c, $9c, $ff, $de
	dc.b $df, $9f, $5e, $3f, $ff, $ff, $00, $ff
	dc.b $0f, $f7, $1b, $eb, $4d, $ed, $ae, $ef
	dc.b $5f, $07, $42, $01, $41, $00, $40, $00
	dc.b $44, $04, $44, $06, $ff, $6e, $ae, $2e
	dc.b $ae, $73, $ff, $ff, $00, $ff, $ff, $ff
	dc.b $ff, $ff, $ff, $ff, $ff, $7f, $7f, $7f
	dc.b $fe, $fd, $fb, $fb, $fb, $f6, $f6, $f6
	dc.b $7b, $7b, $ff, $f8, $fd, $fd, $fd, $3d
	dc.b $ff, $ff, $00, $ff, $ff, $ff, $e0, $c0
	dc.b $9f, $95, $9f, $9b, $df, $8e, $40, $ce
	dc.b $ce, $80, $55, $aa, $55, $aa, $55, $2a
	dc.b $ff, $ad, $aa, $89, $ab, $ac, $ff, $ff
	dc.b $00, $ff, $ff, $ff, $ff, $7f, $3f, $3f
	dc.b $3f, $3f, $7f, $3f, $4f, $77, $7b, $3d
	dc.b $ff, $33, $d5, $95, $55, $b5, $ff, $ff
	dc.b $00, $ff, $fe, $fd, $fb, $fa, $f6, $f6
	dc.b $ee, $de, $df, $de, $e8, $f0, $f0, $e0
	dc.b $e0, $e0, $c4, $cc, $8c, $9c, $ff, $de
	dc.b $df, $9f, $5e, $3f, $ff, $ff, $00, $ff
	dc.b $0f, $f7, $1b, $eb, $4d, $ed, $ae, $ef
	dc.b $5f, $07, $42, $01, $41, $00, $40, $00
	dc.b $44, $04, $44, $06, $ff, $6e, $ae, $2e
	dc.b $ae, $73, $ff, $ff, $00, $ff, $ff, $ff
	dc.b $ff, $ff, $ff, $ff, $ff, $7f, $7f, $7f
	dc.b $fe, $fd, $fb, $fb, $fb, $f6, $f6, $f6
	dc.b $7b, $7b, $ff, $f8, $fd, $fd, $fd, $3d
	dc.b $ff, $ff, $00, $ff, $ff, $ff, $e0, $c0
	dc.b $9f, $95, $9f, $9b, $df, $8e, $40, $ce
	dc.b $ce, $80, $55, $aa, $55, $aa, $55, $2a
	dc.b $ff, $ad, $aa, $89, $ab, $ac, $ff, $ff
	dc.b $00, $ff, $ff, $ff, $ff, $7f, $3f, $3f
	dc.b $3f, $3f, $7f, $3f, $4f, $77, $7b, $3bb

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

	SET_POINTER fxv_screen_ptr0, fx_vertscroll_test
	SET_POINTER fxv_screen_ptr1, fx_vertscroll_test+10
	SET_POINTER fxv_screen_ptr2, fx_vertscroll_test+20
	SET_POINTER fxv_screen_ptr3, fx_vertscroll_test+30
	jmp RTSBank

fx_vertscroll_vblank SUBROUTINE
	m_add_to_pointer fxv_screen_ptr0, #1
	m_add_to_pointer fxv_screen_ptr1, #1
	m_add_to_pointer fxv_screen_ptr2, #1
	m_add_to_pointer fxv_screen_ptr3, #1
	jmp RTSBank

fx_vertscroll_kernel SUBROUTINE
	ldy #29

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
	ldx #7
.inner_loop:
	sta WSYNC
	lda (fxv_screen_ptr0),Y
	sta PF1
	lda (fxv_screen_ptr1),Y
	sta GRP0
	lda (fxv_screen_ptr2),Y
	sta GRP1
	SLEEP 2
	lda (fxv_screen_ptr3),Y
	sta PF1
	dex
	bpl .inner_loop

	dey
	bpl .bottom_loop

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
	dc.b $3f, $3f, $7f, $3f, $4f, $77, $7b, $3b

fx_vertscroll_init SUBROUTINE
	jmp RTSBank

fx_vertscroll_vblank SUBROUTINE
	jmp RTSBank

fx_vertscroll_kernel SUBROUTINE
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

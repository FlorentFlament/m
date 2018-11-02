; graphics/glafouk/2018-10-17_21/40x60-lapinMarche-fond2-nb.png
fx_spritebg_lapinMarche_pf:
	dc.b $70, $e0, $c0, $80, $10, $30
	dc.b $70, $e0, $c0, $80, $10, $30, $70, $e0, $c0, $80, $10, $30, $70, $e0, $c0
	dc.b $80, $10, $30, $70, $e0, $c0, $80, $10, $30, $70, $e0, $c0, $80, $10, $30

	dc.b $38, $1c, $8e, $c7, $e3, $71
	dc.b $38, $1c, $8e, $c7, $e3, $71, $38, $1c, $8e, $c7, $e3, $71, $38, $1c, $8e
	dc.b $c7, $e3, $71, $38, $1c, $8e, $c7, $e3, $71, $38, $1c, $8e, $c7, $e3, $71

	dc.b $c7, $8e, $1c, $38, $71, $e3
	dc.b $c7, $8e, $1c, $38, $71, $e3, $c7, $8e, $1c, $38, $71, $e3, $c7, $8e, $1c
	dc.b $38, $71, $e3, $c7, $8e, $1c, $38, $71, $e3, $c7, $8e, $1c, $38, $71, $e3

	dc.b $10, $30, $70, $e0, $c0, $80
	dc.b $10, $30, $70, $e0, $c0, $80, $10, $30, $70, $e0, $c0, $80, $10, $30, $70
	dc.b $e0, $c0, $80, $10, $30, $70, $e0, $c0, $80, $10, $30, $70, $e0, $c0, $80

	dc.b $e3, $71, $38, $1c, $8e, $c7
	dc.b $e3, $71, $38, $1c, $8e, $c7, $e3, $71, $38, $1c, $8e, $c7, $e3, $71, $38
	dc.b $1c, $8e, $c7, $e3, $71, $38, $1c, $8e, $c7, $e3, $71, $38, $1c, $8e, $c7

	dc.b $71, $e3, $c7, $8e, $1c, $38
	dc.b $71, $e3, $c7, $8e, $1c, $38, $71, $e3, $c7, $8e, $1c, $38, $71, $e3, $c7
	dc.b $8e, $1c, $38, $71, $e3, $c7, $8e, $1c, $38, $71, $e3, $c7, $8e, $1c, $38


; graphics/lapinMarche/16x28-lapinMarche-spriteX2-A.png
fx_spritebg_lapinMarche_sp0:
	dc.b $00, $1e, $3e, $38, $3c, $1e, $0e, $0e, $0e, $0f, $07, $07, $0f, $1d, $3b
	dc.b $37, $37, $3b, $1b, $0f, $07, $07, $07, $06, $3f, $7f, $ff, $c7, $0f, $00
	dc.b $00, $1e, $3e, $38, $38, $78, $f0, $e0, $e0, $e0, $e0, $c0, $c0, $e0, $e0
	dc.b $a0, $a0, $a0, $a0, $e0, $b0, $cc, $fc, $b8, $e0, $e0, $00, $00, $00, $00

; graphics/lapinMarche/16x28-lapinMarche-spriteX2-B.png
fx_spritebg_lapinMarche_sp1:
	dc.b $00, $07, $0f, $0e, $0f, $0f, $07, $07, $07, $03, $07, $0f, $1d, $3b, $37
	dc.b $37, $3b, $1b, $0f, $07, $07, $07, $06, $3f, $7f, $ff, $c7, $0f, $0f, $00
	dc.b $00, $c0, $d0, $10, $70, $20, $a0, $a0, $90, $f0, $e0, $c0, $e0, $e0, $a0
	dc.b $a0, $a0, $a0, $e0, $b0, $cc, $fc, $b8, $e0, $e0, $00, $00, $00, $00, $00

; graphics/lapinMarche/16x28-lapinMarche-spriteX2-C.png
fx_spritebg_lapinMarche_sp2:
	dc.b $00, $02, $07, $0e, $1f, $0f, $03, $01, $03, $07, $07, $03, $07, $0f, $1d
	dc.b $3b, $37, $37, $3b, $1b, $0f, $07, $07, $07, $06, $3f, $7f, $ff, $c7, $00
	dc.b $00, $00, $3e, $7e, $78, $f0, $f0, $f8, $f0, $e0, $e0, $e0, $e0, $c0, $e0
	dc.b $e0, $a0, $a0, $a0, $a0, $e0, $b0, $cc, $fc, $b8, $e0, $e0, $00, $00, $00


fx_spritebg_lapinMarche_sprites:
	dc.w fx_spritebg_lapinMarche_sp0
	dc.w fx_spritebg_lapinMarche_sp1
	dc.w fx_spritebg_lapinMarche_sp2

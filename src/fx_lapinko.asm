fx_lapinko_init SUBROUTINE
	lda #$00
	sta CTRLPF
	sta COLUBK
	lda #$3c
	sta COLUPF

	jmp RTSBank

fx_lapinko_vblank SUBROUTINE
	ldx frame_cnt
	lda fxl_cos_table,X
	sta tmp

	and #$03
	sta fxl_fine_offset

	lda tmp
	REPEAT 2
	lsr
	REPEND
	sta fxl_fat_offset

	jmp RTSBank

fx_lapinko_kernel SUBROUTINE
	lda #240
	sta tmp

	ldy fxl_fat_offset

	lda #3
	sec
	sbc fxl_fine_offset
	tax

	jmp .inner_loop
.bottom_loop:
	ldx #3
.inner_loop:
	sta WSYNC
	lda fxl_pf0,Y
	sta PF0
	lda fxl_pf1,Y
	sta PF1
	lda fxl_pf2,Y
	sta PF2
	SLEEP 8
	lda fxl_pf3,Y
	sta PF0
	lda fxl_pf4,Y
	sta PF1
	lda fxl_pf5,Y
	sta PF2
	dec tmp
	beq .end_loop
	dex
	bpl .inner_loop

	iny
	jmp .bottom_loop

.end_loop:
	sta WSYNC

	lda #$00
	sta PF0
	sta PF1
	sta PF2

	jmp RTSBank

	INCLUDE "fx_lapinko_data.asm"

;[floor((1-cos(x*2*pi/256))/2*152) for x in range(256)]
fxl_cos_table:
	dc.b $00, $00, $00, $00, $00, $00, $00, $01
	dc.b $01, $01, $02, $02, $03, $03, $04, $05
	dc.b $05, $06, $07, $08, $08, $09, $0a, $0b
	dc.b $0c, $0d, $0e, $10, $11, $12, $13, $14
	dc.b $16, $17, $18, $1a, $1b, $1d, $1e, $20
	dc.b $21, $23, $24, $26, $28, $29, $2b, $2d
	dc.b $2e, $30, $32, $34, $35, $37, $39, $3b
	dc.b $3d, $3f, $40, $42, $44, $46, $48, $4a
	dc.b $4b, $4d, $4f, $51, $53, $55, $57, $58
	dc.b $5a, $5c, $5e, $60, $62, $63, $65, $67
	dc.b $69, $6a, $6c, $6e, $6f, $71, $73, $74
	dc.b $76, $77, $79, $7a, $7c, $7d, $7f, $80
	dc.b $81, $83, $84, $85, $86, $87, $89, $8a
	dc.b $8b, $8c, $8d, $8e, $8f, $8f, $90, $91
	dc.b $92, $92, $93, $94, $94, $95, $95, $96
	dc.b $96, $96, $97, $97, $97, $97, $97, $97
	dc.b $98, $97, $97, $97, $97, $97, $97, $96
	dc.b $96, $96, $95, $95, $94, $94, $93, $92
	dc.b $92, $91, $90, $8f, $8f, $8e, $8d, $8c
	dc.b $8b, $8a, $89, $87, $86, $85, $84, $83
	dc.b $81, $80, $7f, $7d, $7c, $7a, $79, $77
	dc.b $76, $74, $73, $71, $6f, $6e, $6c, $6a
	dc.b $69, $67, $65, $63, $62, $60, $5e, $5c
	dc.b $5a, $58, $57, $55, $53, $51, $4f, $4d
	dc.b $4c, $4a, $48, $46, $44, $42, $40, $3f
	dc.b $3d, $3b, $39, $37, $35, $34, $32, $30
	dc.b $2e, $2d, $2b, $29, $28, $26, $24, $23
	dc.b $21, $20, $1e, $1d, $1b, $1a, $18, $17
	dc.b $16, $14, $13, $12, $11, $10, $0e, $0d
	dc.b $0c, $0b, $0a, $09, $08, $08, $07, $06
	dc.b $05, $05, $04, $03, $03, $02, $02, $01
	dc.b $01, $01, $00, $00, $00, $00, $00, $00


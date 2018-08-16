fx_plasma_init SUBROUTINE
	rts

fx_plasma_vblank SUBROUTINE
	SET_POINTER ptr, fx_plasma_data
	lda frame_cnt
	lsr
	lsr
	lsr
	sta tmp
	m_add_to_pointer ptr, tmp

	jsr fxpl_workload_fast
	rts

; Load our fast code into fxpl_buffer
; ptr must points towards the colors to display on the line
; Uses X, Y and A registers
fxpl_workload_fast SUBROUTINE
	ldy #0
I	SET 0
	REPEAT 11
	lda #$a9 ; LDA Immediate instruction
	sta fxpl_buffer + 4*I
	lda (ptr),Y ; The Color to display
	sta fxpl_buffer + 4*I + 1
	lda #$85 ; STA Zero Page instruction
	sta fxpl_buffer + 4*I + 2
	lda #$09 ; COLUBK register
	sta fxpl_buffer + 4*I + 3
	iny
I	SET I + 1
	REPEND
	lda #$60 ; rts instruction
	sta fxpl_buffer + 44
	rts

fxpl_workload_slow SUBROUTINE
	ldy #0
	ldx #0
.prep_loop
	lda #$a9 ; LDA Immediate instruction
	sta fxpl_buffer+0,X
	lda (ptr),Y; The colors to load in memory
	sta fxpl_buffer+1,X
	lda #$85 ; STA Zero Page instruction
	sta fxpl_buffer+2,X
	lda #$09 ; COLUBK register
	sta fxpl_buffer+3,X
	REPEAT 4
	inx
	REPEND
	iny
	cpy #11
	bne .prep_loop
	lda #$60 ; RTS instruction
	sta fxpl_buffer + 44
	rts

; ptr must point towards the the first color to display
; Beware that ptr will be modified !!
fx_plasma_kernel SUBROUTINE
	sta WSYNC
	lda #10 ; Display 11 lines
	sta tmp

 	; see disp_line comment. Also we dont want to add 62
	; additional cycles to the display_loop
	 ALIGN 32, #$ea ; nop
.display_loop:

	; Actually displays one line
	ldx #17
	sta WSYNC
	SLEEP 7
	; The disp_line loop must not cross a memory page
.disp_line:
	SLEEP 4
	jsr fxpl_buffer
	dex
	bne .disp_line
	lda #00
	sta COLUBK

	m_add_to_pointer ptr, 32
	jsr fxpl_workload_fast
	dec tmp
	bpl .display_loop

	lda #0
	sta COLUBK

	rts

fx_plasma_data:
	dc.b $00, $20, $28, $37, $2a, $35, $2d, $2a
	dc.b $2d, $4a, $39, $27, $32, $38, $40, $4e
	dc.b $50, $47, $53, $40, $45, $3c, $54, $5d
	dc.b $4b, $50, $3d, $55, $3b, $50, $4b, $3c
	dc.b $3e, $2a, $2e, $18, $29, $3f, $34, $2e
	dc.b $44, $2a, $42, $34, $3d, $36, $30, $34
	dc.b $50, $46, $4c, $4a, $5b, $3d, $3a, $49
	dc.b $4c, $4e, $56, $5c, $5a, $3f, $50, $54
	dc.b $43, $46, $30, $30, $21, $33, $31, $30
	dc.b $49, $49, $37, $43, $49, $42, $4a, $3f
	dc.b $4a, $48, $51, $42, $5e, $50, $40, $4e
	dc.b $3e, $4a, $43, $62, $4e, $4e, $58, $4e
	dc.b $4a, $4f, $41, $3d, $1c, $34, $39, $43
	dc.b $46, $39, $3e, $46, $4c, $45, $46, $50
	dc.b $52, $58, $3e, $50, $4f, $61, $44, $48
	dc.b $3a, $4c, $4e, $62, $5e, $52, $5f, $61
	dc.b $62, $56, $4c, $4e, $3d, $3e, $2d, $34
	dc.b $37, $5a, $58, $4b, $4d, $56, $53, $44
	dc.b $40, $44, $40, $38, $51, $54, $5f, $46
	dc.b $4e, $57, $47, $4a, $55, $64, $6a, $58
	dc.b $5f, $7b, $6e, $57, $6a, $4d, $39, $2b
	dc.b $46, $30, $54, $5a, $58, $4a, $48, $4a
	dc.b $3f, $35, $36, $41, $39, $4b, $4e, $42
	dc.b $4d, $4a, $5a, $4b, $50, $56, $5e, $4d
	dc.b $51, $6e, $7c, $78, $70, $5e, $54, $41
	dc.b $44, $3a, $37, $42, $4f, $44, $4c, $3d
	dc.b $59, $60, $52, $47, $3e, $50, $3f, $3c
	dc.b $49, $53, $4e, $4a, $6f, $65, $78, $65
	dc.b $5d, $55, $67, $7f, $72, $7a, $79, $45
	dc.b $5d, $39, $38, $48, $3b, $32, $52, $3b
	dc.b $41, $43, $58, $4f, $41, $4e, $45, $37
	dc.b $3d, $3d, $4c, $5c, $5b, $53, $64, $7b
	dc.b $62, $54, $60, $77, $6c, $6a, $85, $6a
	dc.b $52, $5b, $45, $38, $3d, $3b, $36, $59
	dc.b $4a, $42, $5c, $67, $51, $59, $54, $61
	dc.b $59, $5c, $57, $6a, $6a, $5c, $64, $70
	dc.b $76, $7e, $75, $67, $80, $72, $7e, $90
	dc.b $74, $4d, $63, $50, $4e, $4d, $3e, $46
	dc.b $52, $50, $58, $58, $5c, $5c, $6e, $5e
	dc.b $62, $55, $6b, $67, $61, $55, $5f, $7f
	dc.b $80, $8c, $85, $7f, $77, $71, $86, $87
	dc.b $80, $69, $5d, $6a, $64, $54, $58, $44
	dc.b $4a, $40, $4e, $49, $4c, $6a, $60, $7a
	dc.b $73, $70, $71, $61, $67, $71, $6b, $6d
	dc.b $6f, $6f, $89, $90, $74, $85, $79, $83
	dc.b $74, $6e, $70, $6e, $57, $65, $55, $4f
	dc.b $49, $3c, $4e, $66, $61, $52, $55, $74
	dc.b $68, $5b, $5f, $5b, $67, $62, $66, $77
	dc.b $70, $7b, $84, $8f, $8f, $84, $71, $84
	dc.b $8f, $7c, $7a, $7f, $68, $50, $58, $55
	dc.b $57, $4b, $51, $60, $5e, $6c, $5d, $70
	dc.b $71, $5d, $69, $6d, $6f, $7f, $73, $62
	dc.b $6e, $7c, $74, $87, $86, $98, $7f, $78
	dc.b $85, $7f, $8c, $76, $8e, $6f, $5b, $6a
	dc.b $5a, $58, $6a, $67, $60, $6b, $54, $59
	dc.b $76, $5f, $77, $69, $73, $80, $81, $63
	dc.b $6b, $6d, $7d, $82, $83, $8a, $83, $7a
	dc.b $8d, $81, $9c, $7f, $89, $89, $6e, $69
	dc.b $7d, $64, $80, $6d, $69, $5b, $65, $6a
	dc.b $74, $66, $63, $85, $75, $69, $68, $78
	dc.b $73, $81, $7a, $6c, $71, $99, $95, $7e
	dc.b $8f, $8c, $95, $9f, $86, $93, $8b, $85
	dc.b $78, $73, $80, $80, $69, $7f, $6f, $73
	dc.b $7a, $67, $78, $70, $82, $86, $75, $87
	dc.b $80, $7d, $82, $72, $81, $73, $93, $99
	dc.b $9d, $a5, $8f, $8a, $93, $85, $91, $89
	dc.b $77, $87, $81, $86, $7f, $89, $79, $70
	dc.b $6c, $76, $68, $73, $77, $70, $7b, $85
	dc.b $7d, $8e, $6e, $8e, $7a, $7b, $8b, $88
	dc.b $97, $a0, $8e, $89, $9a, $80, $80, $89
	dc.b $86, $80, $75, $77, $80, $89, $81, $84
	dc.b $66, $77, $73, $6a, $8a, $8f, $8c, $8d
	dc.b $8e, $80, $98, $93, $8c, $85, $97, $90
	dc.b $88, $a1, $a3, $93, $a7, $ab, $87, $86
	dc.b $84, $8c, $83, $89, $87, $94, $85, $88
	dc.b $6c, $75, $62, $6e, $84, $89, $8c, $8c
	dc.b $8c, $92, $9c, $95, $94, $89, $83, $8a
	dc.b $8b, $95, $a1, $a4, $a6, $9f, $9a, $81
	dc.b $83, $97, $94, $86, $83, $85, $8b, $95
	dc.b $8a, $81, $70, $62, $7e, $90, $80, $82
	dc.b $8a, $7b, $96, $a6, $97, $8e, $8b, $9e
	dc.b $8e, $9b, $a8, $ae, $a6, $8f, $8e, $87
	dc.b $82, $9a, $86, $81, $86, $a1, $94, $80
	dc.b $83, $8d, $86, $6d, $73, $7f, $86, $7c
	dc.b $7b, $8c, $83, $85, $99, $a4, $ab, $8d
	dc.b $9e, $8f, $9d, $ac, $98, $b2, $a1, $89
	dc.b $90, $8e, $91, $91, $97, $8c, $a1, $87
	dc.b $7f, $82, $8e, $8c, $79, $75, $90, $8f
	dc.b $87, $84, $85, $9d, $97, $87, $a4, $ac
	dc.b $ac, $8d, $9a, $9d, $9d, $94, $b3, $9a
	dc.b $a0, $98, $a7, $89, $99, $af, $9b, $98
	dc.b $96, $7b, $83, $87, $89, $98, $85, $89
	dc.b $86, $85, $8d, $7d, $8f, $9c, $88, $82
	dc.b $97, $9f, $8d, $ab, $a9, $95, $a4, $9b
	dc.b $aa, $b8, $a7, $b0, $9b, $97, $b7, $a3
	dc.b $9c, $95, $91, $a6, $9b, $8f, $9e, $a1
	dc.b $96, $97, $8a, $84, $81, $97, $86, $97
	dc.b $82, $84, $90, $82, $97, $ac, $9a, $a8
	dc.b $9f, $a6, $b4, $aa, $b8, $bc, $a9, $b9
	dc.b $96, $84, $98, $9e, $a4, $94, $a4, $a8
	dc.b $93, $8c, $9a, $82, $89, $a8, $ab, $9e
	dc.b $a2, $93, $89, $91, $90, $87, $98, $a0
	dc.b $a1, $9a, $9b, $a9, $a9, $af, $b4, $af
	dc.b $c5, $8b, $8a, $82, $9a, $a5, $95, $a5
	dc.b $8f, $8d, $92, $9f, $a5, $a0, $a1, $ba
	dc.b $b4, $b6, $98, $83, $8f, $95, $99, $a0
	dc.b $9a, $95, $9d, $9c, $96, $98, $af, $d0
	dc.b $cc, $bb, $8b, $8f, $95, $a9, $a6, $9d
	dc.b $8b, $92, $9c, $9a, $8c, $a6, $9c, $ac
	dc.b $ae, $ab, $a0, $91, $9c, $ad, $95, $89
	dc.b $93, $9e, $9a, $b2, $aa, $a4, $b4, $c1
	dc.b $cc, $dc, $c4, $9c, $a7, $92, $8a, $a4
	dc.b $a6, $89, $90, $8a, $9d, $9f, $ac, $b3
	dc.b $ab, $b6, $ad, $a6, $ab, $a7, $b1, $af
	dc.b $a0, $95, $a3, $b7, $a9, $ab, $ac, $b9
	dc.b $b3, $d6, $ce, $c0, $ae, $9c, $94, $8a
	dc.b $9e, $99, $90, $a1, $94, $9c, $a4, $ad
	dc.b $a1, $9a, $9e, $9d, $ae, $ac, $b7, $bb
	dc.b $aa, $a9, $b4, $b0, $b8, $b4, $b4, $c5
	dc.b $bd, $c7, $c3, $da, $e4, $c4, $ae, $9c
	dc.b $b1, $ad, $9a, $a3, $9b, $90, $97, $8a
	dc.b $8f, $89, $99, $a3, $ad, $c0, $bb, $aa
	dc.b $ae, $b4, $ba, $b9, $b8, $c7, $b3, $cc
	dc.b $c1, $b3, $cb, $c9, $cf, $e2, $c2, $a4
	dc.b $ab, $9f, $aa, $ba, $ae, $ae, $95, $8d
	dc.b $94, $a2, $91, $af, $a8, $a9, $bd, $c3
	dc.b $b4, $bb, $bc, $b1, $bd, $cc, $c6, $cb
	dc.b $c0, $bd, $c6, $cd, $d1, $cf, $e2, $a4
	dc.b $a4, $9d, $a0, $ba, $bc, $bf, $b8, $9a
	dc.b $9e, $a7, $9d, $a3, $b7, $b2, $c7, $ad
	dc.b $b3, $ca, $cd, $b4, $bc, $bc, $d5, $df
	dc.b $d8, $c3, $d3, $da, $d1, $eb, $f3, $ff
	dc.b $ba, $a3, $a7, $a0, $b3, $a4, $b0, $c0
	dc.b $ac, $9e, $b0, $b2, $a3, $a3, $be, $b9
	dc.b $c0, $aa, $b9, $b7, $c6, $b6, $c0, $d1
	dc.b $ca, $bd, $cb, $da, $d0, $c8, $eb, $e8
	dc.b $f8

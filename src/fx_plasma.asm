fx_plasma_init SUBROUTINE
	ldx #15
.loop:
	lda fxpl_palette_orig,X
	sta fxpl_palette,X
	dex
	bpl .loop
	rts

fxp_rotate_palette_back SUBROUTINE
	; Backup first value
	lda fxpl_palette+15
	sta tmp
	ldx #14
.rotate_loop
	lda fxpl_palette,X
	sta fxpl_palette+1,X
	dex
	bpl .rotate_loop
	lda tmp
	sta fxpl_palette
	rts

fxp_rotate_palette SUBROUTINE
	; Backup first value
	lda fxpl_palette
	sta tmp
	ldx #0
.rotate_loop
	lda fxpl_palette+1,X
	sta fxpl_palette,X
	inx
	cpx #15
	bne .rotate_loop
	lda tmp
	sta fxpl_palette+15
	rts

fx_plasma_vblank SUBROUTINE
	SET_POINTER ptr, fx_plasma_data
	lda frame_cnt
	lsr
	lsr
	lsr
	sta tmp
	;m_add_to_pointer ptr, tmp

	lda frame_cnt
	and #$03
	bne .no_palette_rot
	jsr fxp_rotate_palette

.no_palette_rot:
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
	tax
	lda fxpl_palette,X
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
	ldx #16
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

	m_add_to_pointer ptr, 11
	jsr fxpl_workload_fast
	dec tmp
	bpl .display_loop

	lda #0
	sta COLUBK

	rts

fx_plasma_data:

	dc.b $05, $07, $08, $07, $04, $02, $01, $02, $04, $05, $04
	dc.b $07, $0b, $0d, $0c, $08, $04, $02, $03, $04, $06, $05
	dc.b $08, $0d, $0f, $0e, $0a, $06, $03, $03, $05, $06, $07
	dc.b $08, $0c, $0f, $0d, $0a, $05, $03, $03, $05, $07, $07
	dc.b $06, $09, $0b, $09, $06, $03, $01, $02, $04, $06, $06
	dc.b $04, $06, $06, $04, $02, $00, $00, $01, $03, $04, $04
	dc.b $03, $03, $02, $01, $00, $00, $01, $02, $03, $03, $03
	dc.b $04, $03, $01, $00, $00, $02, $04, $06, $06, $04, $02
	dc.b $06, $04, $02, $01, $03, $06, $09, $0b, $09, $06, $02
	dc.b $07, $05, $03, $03, $05, $0a, $0d, $0f, $0c, $08, $03
	dc.b $06, $05, $03, $03, $06, $0a, $0e, $0f, $0d, $08, $04

fxpl_palette_orig:
	dc.b $90, $92, $94, $96, $98, $9a, $9c, $9e
	dc.b $9e, $9c, $9a, $98, $96, $94, $92, $90
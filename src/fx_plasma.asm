fx_plasma_init SUBROUTINE
	ldx #16
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
	m_copy_pointer frame_cnt, ptr1
	REPEAT 3
	m_shift_pointer_right ptr1
	REPEND
	lda ptr1
	and #$3f
	tax
	lda fxpl_path_x,X
	sta tmp
	m_add_to_pointer ptr, tmp
	ldy fxpl_path_y,X
	beq .end_add_loop
.add_loop:
	m_add_to_pointer ptr, #32 ; 32 pixels per line
	dey
	bne .add_loop
.end_add_loop:

	lda frame_cnt
	and #$03 ; possible values are #$00, #$01, #$03
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

	m_add_to_pointer ptr, 32
	jsr fxpl_workload_fast
	dec tmp
	bpl .display_loop

	lda #0
	sta COLUBK

	rts

fx_plasma_data:
	;dc.b $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	;dc.b $0a, $0a, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0a, $0a
	;dc.b $0a, $0b, $0b, $0c, $0c, $0c, $0c, $0c, $0b, $0b, $0a
	;dc.b $0a, $0b, $0c, $0c, $0d, $0d, $0d, $0c, $0c, $0b, $0a
	;dc.b $0a, $0b, $0c, $0d, $10, $10, $10, $0d, $0c, $0b, $0a
	;dc.b $0a, $0b, $0c, $0d, $10, $10, $10, $0d, $0c, $0b, $0a
	;dc.b $0a, $0b, $0c, $0d, $10, $10, $10, $0d, $0c, $0b, $0a
	;dc.b $0a, $0b, $0c, $0c, $0d, $0d, $0d, $0c, $0c, $0b, $0a
	;dc.b $0a, $0b, $0b, $0c, $0c, $0c, $0c, $0c, $0b, $0b, $0a
	;dc.b $0a, $0a, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0a, $0a
	;dc.b $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	dc.b $06, $07, $07, $07, $06, $05, $04, $03
	dc.b $02, $02, $02, $02, $03, $03, $04, $04
	dc.b $04, $04, $04, $04, $03, $03, $03, $03
	dc.b $04, $04, $05, $06, $07, $07, $07, $06
	dc.b $09, $09, $0a, $09, $08, $07, $05, $04
	dc.b $03, $02, $01, $01, $01, $02, $03, $03
	dc.b $04, $04, $04, $03, $03, $03, $03, $04
	dc.b $04, $05, $06, $06, $07, $07, $07, $07
	dc.b $0b, $0c, $0c, $0c, $0a, $09, $07, $05
	dc.b $03, $02, $01, $00, $00, $01, $02, $02
	dc.b $03, $03, $03, $03, $03, $03, $03, $04
	dc.b $04, $05, $06, $06, $07, $07, $07, $07
	dc.b $0d, $0e, $0e, $0d, $0c, $0a, $08, $06
	dc.b $03, $02, $00, $00, $00, $00, $01, $02
	dc.b $03, $03, $04, $04, $04, $03, $03, $04
	dc.b $04, $04, $05, $06, $06, $06, $06, $06
	dc.b $0e, $0f, $0f, $0f, $0d, $0b, $09, $06
	dc.b $04, $02, $00, $00, $00, $00, $01, $02
	dc.b $03, $03, $04, $04, $04, $04, $03, $03
	dc.b $03, $04, $04, $05, $05, $05, $05, $05
	dc.b $0e, $0f, $0f, $0f, $0e, $0c, $09, $07
	dc.b $04, $02, $00, $00, $00, $00, $01, $02
	dc.b $03, $04, $05, $05, $04, $04, $03, $03
	dc.b $03, $03, $03, $03, $04, $04, $04, $04
	dc.b $0d, $0e, $0f, $0f, $0e, $0c, $09, $07
	dc.b $04, $02, $01, $00, $00, $01, $02, $03
	dc.b $04, $05, $05, $05, $05, $04, $03, $03
	dc.b $02, $02, $02, $02, $02, $02, $03, $03
	dc.b $0b, $0d, $0d, $0e, $0d, $0b, $09, $07
	dc.b $04, $02, $01, $01, $01, $02, $03, $04
	dc.b $05, $06, $06, $06, $06, $05, $03, $02
	dc.b $01, $01, $01, $01, $01, $01, $02, $02
	dc.b $09, $0b, $0c, $0c, $0b, $0a, $08, $06
	dc.b $04, $03, $02, $01, $02, $02, $04, $05
	dc.b $06, $07, $07, $07, $06, $05, $04, $02
	dc.b $01, $00, $00, $00, $00, $01, $01, $02
	dc.b $07, $08, $09, $0a, $09, $08, $07, $05
	dc.b $04, $03, $02, $02, $02, $03, $05, $06
	dc.b $07, $08, $08, $08, $07, $05, $04, $02
	dc.b $01, $00, $00, $00, $00, $01, $02, $02
	dc.b $05, $06, $07, $08, $08, $07, $06, $05
	dc.b $03, $02, $02, $02, $03, $04, $05, $07
	dc.b $08, $08, $08, $08, $07, $05, $04, $02
	dc.b $01, $00, $00, $00, $01, $02, $03, $03
	dc.b $03, $04, $05, $06, $06, $05, $05, $04
	dc.b $03, $02, $02, $02, $03, $04, $05, $07
	dc.b $08, $08, $08, $08, $07, $05, $03, $02
	dc.b $01, $00, $00, $01, $02, $03, $04, $05
	dc.b $02, $03, $04, $04, $04, $04, $04, $03
	dc.b $02, $02, $01, $02, $03, $04, $05, $06
	dc.b $07, $08, $08, $07, $06, $05, $03, $02
	dc.b $01, $01, $01, $02, $04, $05, $07, $08
	dc.b $01, $02, $03, $03, $03, $03, $03, $02
	dc.b $02, $01, $01, $01, $02, $03, $04, $05
	dc.b $06, $07, $07, $06, $05, $04, $03, $02
	dc.b $02, $02, $02, $04, $05, $07, $09, $0a
	dc.b $01, $02, $03, $03, $03, $03, $02, $02
	dc.b $01, $01, $01, $01, $02, $03, $04, $04
	dc.b $05, $05, $05, $05, $04, $03, $02, $02
	dc.b $02, $02, $03, $05, $07, $09, $0b, $0c
	dc.b $02, $03, $03, $03, $03, $03, $02, $02
	dc.b $01, $01, $01, $01, $01, $02, $03, $03
	dc.b $04, $04, $04, $03, $03, $02, $02, $02
	dc.b $02, $03, $04, $06, $08, $0a, $0c, $0e
	dc.b $03, $03, $04, $03, $03, $03, $02, $02
	dc.b $01, $01, $01, $01, $01, $02, $02, $03
	dc.b $03, $03, $03, $02, $02, $01, $01, $01
	dc.b $02, $03, $05, $07, $09, $0b, $0d, $0e
	dc.b $04, $04, $04, $04, $04, $03, $02, $02
	dc.b $02, $01, $01, $01, $02, $02, $02, $02
	dc.b $02, $02, $02, $01, $01, $01, $01, $01
	dc.b $02, $03, $05, $07, $09, $0b, $0d, $0e
	dc.b $05, $05, $05, $04, $04, $03, $03, $02
	dc.b $02, $02, $02, $02, $03, $03, $03, $03
	dc.b $03, $02, $02, $01, $00, $00, $00, $01
	dc.b $01, $03, $04, $06, $08, $0a, $0c, $0d
	dc.b $06, $05, $05, $04, $04, $04, $03, $03
	dc.b $03, $03, $04, $04, $04, $04, $04, $04
	dc.b $03, $03, $02, $01, $00, $00, $00, $00
	dc.b $01, $02, $04, $05, $07, $09, $0a, $0b
	dc.b $06, $05, $05, $04, $04, $04, $03, $04
	dc.b $04, $04, $05, $06, $06, $06, $06, $05
	dc.b $05, $04, $03, $02, $01, $00, $00, $01
	dc.b $01, $02, $03, $05, $06, $07, $08, $08
	dc.b $06, $05, $04, $04, $03, $03, $03, $04
	dc.b $05, $06, $07, $08, $08, $08, $08, $08
	dc.b $07, $05, $04, $03, $02, $01, $01, $01
	dc.b $01, $02, $03, $04, $04, $05, $05, $06
	dc.b $05, $04, $04, $03, $03, $03, $03, $04
	dc.b $06, $07, $08, $0a, $0a, $0b, $0a, $0a
	dc.b $08, $07, $05, $04, $03, $02, $01, $01
	dc.b $01, $02, $02, $03, $03, $03, $03, $03
	dc.b $04, $03, $03, $02, $02, $02, $03, $04
	dc.b $06, $08, $0a, $0b, $0c, $0d, $0c, $0c
	dc.b $0a, $09, $07, $05, $04, $03, $02, $02
	dc.b $02, $02, $02, $02, $02, $02, $02, $02
	dc.b $03, $02, $02, $01, $01, $02, $03, $04
	dc.b $06, $09, $0b, $0c, $0e, $0e, $0e, $0d
	dc.b $0b, $0a, $08, $06, $04, $03, $03, $02
	dc.b $02, $02, $02, $02, $02, $02, $01, $01
	dc.b $03, $02, $01, $00, $00, $01, $02, $04
	dc.b $06, $09, $0b, $0d, $0e, $0f, $0f, $0e
	dc.b $0c, $0a, $08, $06, $05, $04, $03, $03
	dc.b $03, $03, $03, $03, $02, $02, $01, $01
	dc.b $02, $01, $00, $00, $00, $01, $02, $04
	dc.b $06, $09, $0b, $0d, $0e, $0f, $0e, $0d
	dc.b $0c, $0a, $08, $06, $05, $04, $03, $03
	dc.b $03, $03, $04, $03, $03, $03, $02, $01
	dc.b $02, $01, $00, $00, $00, $00, $02, $03
	dc.b $06, $08, $0a, $0c, $0d, $0e, $0d, $0c
	dc.b $0b, $09, $07, $05, $04, $03, $03, $03
	dc.b $04, $04, $04, $04, $04, $04, $03, $02
	dc.b $03, $02, $01, $00, $00, $00, $01, $03
	dc.b $05, $07, $09, $0b, $0c, $0c, $0b, $0a
	dc.b $09, $07, $05, $04, $03, $03, $03, $03
	dc.b $04, $05, $05, $05, $05, $05, $04, $03
	dc.b $03, $02, $01, $01, $00, $00, $01, $03
	dc.b $04, $06, $08, $09, $0a, $0a, $09, $08
	dc.b $07, $05, $04, $03, $02, $02, $02, $03
	dc.b $04, $05, $06, $06, $06, $06, $05, $05
	dc.b $04, $03, $02, $01, $01, $01, $01, $02
	dc.b $03, $05, $06, $07, $07, $07, $07, $06
	dc.b $04, $03, $02, $01, $01, $01, $02, $03
	dc.b $04, $05, $06, $06, $06, $06, $06, $05
	dc.b $05, $04, $03, $02, $02, $01, $02, $02
	dc.b $03, $04, $05, $05, $05, $05, $05, $04
	dc.b $02, $01, $01, $00, $00, $01, $01, $03
	dc.b $04, $05, $06, $06, $07, $07, $06, $06

fxpl_palette_orig:
	dc.b $90, $92, $94, $96, $98, $9a, $9c, $9e
	dc.b $9e, $9c, $9a, $98, $96, $94, $92, $90
	dc.b $00
	;dc.b $90, $9c, $90, $00, $00, $00, $00, $00
	;dc.b $90, $9c, $90, $00, $00, $00, $00, $00
	;dc.b $00

fxpl_path_x:
	dc.b $0a, $0b, $0c, $0d, $0e, $0f, $10, $10
	dc.b $11, $12, $12, $13, $13, $14, $14, $14
	dc.b $14, $14, $14, $13, $13, $13, $12, $11
	dc.b $11, $10, $0f, $0e, $0d, $0c, $0b, $0a
	dc.b $0a, $09, $08, $07, $06, $05, $04, $03
	dc.b $03, $02, $01, $01, $01, $00, $00, $00
	dc.b $00, $00, $00, $01, $01, $02, $02, $03
	dc.b $04, $04, $05, $06, $07, $08, $09, $0a

fxpl_path_y:
	dc.b $0a, $0c, $0e, $10, $11, $12, $13, $14
	dc.b $14, $14, $13, $12, $11, $0f, $0d, $0b
	dc.b $0a, $08, $06, $04, $03, $01, $01, $00
	dc.b $00, $00, $01, $02, $04, $05, $07, $09
	dc.b $0b, $0d, $0f, $10, $12, $13, $14, $14
	dc.b $14, $13, $13, $11, $10, $0e, $0c, $0a
	dc.b $09, $07, $05, $03, $02, $01, $00, $00
	dc.b $00, $01, $02, $03, $04, $06, $08, $0a

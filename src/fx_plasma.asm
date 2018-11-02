; Copy palette from ROM to RAM
; This should be removed at some point
	MAC m_copy_palette
	ldx #16
.loop:
	lda {1},X
	sta fxpl_palette,X
	dex
	bpl .loop
	ENDM

fx_plasma1_init SUBROUTINE
	SET_POINTER fxpl_tim_ptr, fxpl_timeline1
	m_copy_palette fxpl_palette_orig1
	jmp fx_plasma_init

fx_plasma2_init SUBROUTINE
	SET_POINTER fxpl_tim_ptr, fxpl_timeline2
	m_copy_palette fxpl_palette_orig2
	jmp fx_plasma_init

fx_plasma3_init SUBROUTINE
	SET_POINTER fxpl_tim_ptr, fxpl_timeline3
	m_copy_palette fxpl_palette_orig3
	jmp fx_plasma_init

fx_plasma_init SUBROUTINE
	lda #$00
	sta PF0
	sta PF1
	sta PF2
	sta GRP0
	sta GRP1
	sta fxpl_cnt
	sta fxpl_cnt+1

	jmp RTSBank

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
	; Set fxpl_mask_ptr to the beginning of the plasma mask
	m_copy_pointer fxpl_cnt, ptr
	REPEAT 3
	m_shift_pointer_right ptr
	REPEND
	lda ptr
	and #$3f ; 64 bytes for now
	tay
	lda (fxpl_tim_ptr),Y
	asl
	tax
	lda fxpl_masks,X
	sta fxpl_mask_ptr
	lda fxpl_masks+1,X
	sta fxpl_mask_ptr+1
	jmp fx_plasma_vblank_common

; Uses ptr
fx_plasma_vblank_common SUBROUTINE
	SET_POINTER fxpl_col_ptr, fx_plasma_data

	; Use ptr to position the pointer on the plasma map
	; Then update fxpl_col_ptr using fxpl_path_x and fxpl_path_y tables
	m_copy_pointer frame_cnt, ptr
	REPEAT 3
	m_shift_pointer_right ptr
	REPEND
	lda ptr
	and #$3f
	tax
	lda fxpl_path_x,X
	sta tmp
	m_add_to_pointer fxpl_col_ptr, tmp
	ldy fxpl_path_y,X
	beq .end_add_loop
.add_loop:
	m_add_to_pointer fxpl_col_ptr, #32 ; 32 pixels per line
	dey
	bne .add_loop
.end_add_loop:

	; Possilby rotate the palette
	lda frame_cnt
	and #$03 ; possible values are #$00, #$01, #$03
	bne .no_palette_rot
	jsr fxp_rotate_palette

.no_palette_rot:
	jsr fxpl_workload_fast

	m_add_to_pointer fxpl_cnt, 1
	jmp RTSBank

; Load our fast code into fxpl_buffer
; Uses X, Y and A registers
fxpl_workload_fast SUBROUTINE
	ldy #0
I	SET 0
	REPEAT 11
	lda #$a9 ; LDA Immediate instruction
	sta fxpl_buffer + 4*I
	lda (fxpl_col_ptr),Y ; The Color to display
	ora $10
	and (fxpl_mask_ptr),Y
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

	; Update pointer to the plasma map (32x32)
	m_add_to_pointer fxpl_col_ptr, 32
	; Update pointer to the plasma mask (11x11)
	m_add_to_pointer fxpl_mask_ptr, 11
	jsr fxpl_workload_fast
	dec tmp
	bpl .display_loop

	lda #0
	sta COLUBK

	jmp RTSBank

fx_plasma_data:
	dc.b $16, $17, $17, $17, $16, $15, $14, $13
	dc.b $12, $12, $12, $12, $13, $13, $14, $14
	dc.b $14, $14, $14, $14, $13, $13, $13, $13
	dc.b $14, $14, $15, $16, $17, $17, $17, $16
	dc.b $19, $19, $1a, $19, $18, $17, $15, $14
	dc.b $13, $12, $11, $11, $11, $12, $13, $13
	dc.b $14, $14, $14, $13, $13, $13, $13, $14
	dc.b $14, $15, $16, $16, $17, $17, $17, $17
	dc.b $1b, $1c, $1c, $1c, $1a, $19, $17, $15
	dc.b $13, $12, $11, $10, $10, $11, $12, $12
	dc.b $13, $13, $13, $13, $13, $13, $13, $14
	dc.b $14, $15, $16, $16, $17, $17, $17, $17
	dc.b $1d, $1e, $1e, $1d, $1c, $1a, $18, $16
	dc.b $13, $12, $10, $10, $10, $10, $11, $12
	dc.b $13, $13, $14, $14, $14, $13, $13, $14
	dc.b $14, $14, $15, $16, $16, $16, $16, $16
	dc.b $1e, $1f, $1f, $1f, $1d, $1b, $19, $16
	dc.b $14, $12, $10, $10, $10, $10, $11, $12
	dc.b $13, $13, $14, $14, $14, $14, $13, $13
	dc.b $13, $14, $14, $15, $15, $15, $15, $15
	dc.b $1e, $1f, $1f, $1f, $1e, $1c, $19, $17
	dc.b $14, $12, $10, $10, $10, $10, $11, $12
	dc.b $13, $14, $15, $15, $14, $14, $13, $13
	dc.b $13, $13, $13, $13, $14, $14, $14, $14
	dc.b $1d, $1e, $1f, $1f, $1e, $1c, $19, $17
	dc.b $14, $12, $11, $10, $10, $11, $12, $13
	dc.b $14, $15, $15, $15, $15, $14, $13, $13
	dc.b $12, $12, $12, $12, $12, $12, $13, $13
	dc.b $1b, $1d, $1d, $1e, $1d, $1b, $19, $17
	dc.b $14, $12, $11, $11, $11, $12, $13, $14
	dc.b $15, $16, $16, $16, $16, $15, $13, $12
	dc.b $11, $11, $11, $11, $11, $11, $12, $12
	dc.b $19, $1b, $1c, $1c, $1b, $1a, $18, $16
	dc.b $14, $13, $12, $11, $12, $12, $14, $15
	dc.b $16, $17, $17, $17, $16, $15, $14, $12
	dc.b $11, $10, $10, $10, $10, $11, $11, $12
	dc.b $17, $18, $19, $1a, $19, $18, $17, $15
	dc.b $14, $13, $12, $12, $12, $13, $15, $16
	dc.b $17, $18, $18, $18, $17, $15, $14, $12
	dc.b $11, $10, $10, $10, $10, $11, $12, $12
	dc.b $15, $16, $17, $18, $18, $17, $16, $15
	dc.b $13, $12, $12, $12, $13, $14, $15, $17
	dc.b $18, $18, $18, $18, $17, $15, $14, $12
	dc.b $11, $10, $10, $10, $11, $12, $13, $13
	dc.b $13, $14, $15, $16, $16, $15, $15, $14
	dc.b $13, $12, $12, $12, $13, $14, $15, $17
	dc.b $18, $18, $18, $18, $17, $15, $13, $12
	dc.b $11, $10, $10, $11, $12, $13, $14, $15
	dc.b $12, $13, $14, $14, $14, $14, $14, $13
	dc.b $12, $12, $11, $12, $13, $14, $15, $16
	dc.b $17, $18, $18, $17, $16, $15, $13, $12
	dc.b $11, $11, $11, $12, $14, $15, $17, $18
	dc.b $11, $12, $13, $13, $13, $13, $13, $12
	dc.b $12, $11, $11, $11, $12, $13, $14, $15
	dc.b $16, $17, $17, $16, $15, $14, $13, $12
	dc.b $12, $12, $12, $14, $15, $17, $19, $1a
	dc.b $11, $12, $13, $13, $13, $13, $12, $12
	dc.b $11, $11, $11, $11, $12, $13, $14, $14
	dc.b $15, $15, $15, $15, $14, $13, $12, $12
	dc.b $12, $12, $13, $15, $17, $19, $1b, $1c
	dc.b $12, $13, $13, $13, $13, $13, $12, $12
	dc.b $11, $11, $11, $11, $11, $12, $13, $13
	dc.b $14, $14, $14, $13, $13, $12, $12, $12
	dc.b $12, $13, $14, $16, $18, $1a, $1c, $1e
	dc.b $13, $13, $14, $13, $13, $13, $12, $12
	dc.b $11, $11, $11, $11, $11, $12, $12, $13
	dc.b $13, $13, $13, $12, $12, $11, $11, $11
	dc.b $12, $13, $15, $17, $19, $1b, $1d, $1e
	dc.b $14, $14, $14, $14, $14, $13, $12, $12
	dc.b $12, $11, $11, $11, $12, $12, $12, $12
	dc.b $12, $12, $12, $11, $11, $11, $11, $11
	dc.b $12, $13, $15, $17, $19, $1b, $1d, $1e
	dc.b $15, $15, $15, $14, $14, $13, $13, $12
	dc.b $12, $12, $12, $12, $13, $13, $13, $13
	dc.b $13, $12, $12, $11, $10, $10, $10, $11
	dc.b $11, $13, $14, $16, $18, $1a, $1c, $1d
	dc.b $16, $15, $15, $14, $14, $14, $13, $13
	dc.b $13, $13, $14, $14, $14, $14, $14, $14
	dc.b $13, $13, $12, $11, $10, $10, $10, $10
	dc.b $11, $12, $14, $15, $17, $19, $1a, $1b
	dc.b $16, $15, $15, $14, $14, $14, $13, $14
	dc.b $14, $14, $15, $16, $16, $16, $16, $15
	dc.b $15, $14, $13, $12, $11, $10, $10, $11
	dc.b $11, $12, $13, $15, $16, $17, $18, $18
	dc.b $16, $15, $14, $14, $13, $13, $13, $14
	dc.b $15, $16, $17, $18, $18, $18, $18, $18
	dc.b $17, $15, $14, $13, $12, $11, $11, $11
	dc.b $11, $12, $13, $14, $14, $15, $15, $16
	dc.b $15, $14, $14, $13, $13, $13, $13, $14
	dc.b $16, $17, $18, $1a, $1a, $1b, $1a, $1a
	dc.b $18, $17, $15, $14, $13, $12, $11, $11
	dc.b $11, $12, $12, $13, $13, $13, $13, $13
	dc.b $14, $13, $13, $12, $12, $12, $13, $14
	dc.b $16, $18, $1a, $1b, $1c, $1d, $1c, $1c
	dc.b $1a, $19, $17, $15, $14, $13, $12, $12
	dc.b $12, $12, $12, $12, $12, $12, $12, $12
	dc.b $13, $12, $12, $11, $11, $12, $13, $14
	dc.b $16, $19, $1b, $1c, $1e, $1e, $1e, $1d
	dc.b $1b, $1a, $18, $16, $14, $13, $13, $12
	dc.b $12, $12, $12, $12, $12, $12, $11, $11
	dc.b $13, $12, $11, $10, $10, $11, $12, $14
	dc.b $16, $19, $1b, $1d, $1e, $1f, $1f, $1e
	dc.b $1c, $1a, $18, $16, $15, $14, $13, $13
	dc.b $13, $13, $13, $13, $12, $12, $11, $11
	dc.b $12, $11, $10, $10, $10, $11, $12, $14
	dc.b $16, $19, $1b, $1d, $1e, $1f, $1e, $1d
	dc.b $1c, $1a, $18, $16, $15, $14, $13, $13
	dc.b $13, $13, $14, $13, $13, $13, $12, $11
	dc.b $12, $11, $10, $10, $10, $10, $12, $13
	dc.b $16, $18, $1a, $1c, $1d, $1e, $1d, $1c
	dc.b $1b, $19, $17, $15, $14, $13, $13, $13
	dc.b $14, $14, $14, $14, $14, $14, $13, $12
	dc.b $13, $12, $11, $10, $10, $10, $11, $13
	dc.b $15, $17, $19, $1b, $1c, $1c, $1b, $1a
	dc.b $19, $17, $15, $14, $13, $13, $13, $13
	dc.b $14, $15, $15, $15, $15, $15, $14, $13
	dc.b $13, $12, $11, $11, $10, $10, $11, $13
	dc.b $14, $16, $18, $19, $1a, $1a, $19, $18
	dc.b $17, $15, $14, $13, $12, $12, $12, $13
	dc.b $14, $15, $16, $16, $16, $16, $15, $15
	dc.b $14, $13, $12, $11, $11, $11, $11, $12
	dc.b $13, $15, $16, $17, $17, $17, $17, $16
	dc.b $14, $13, $12, $11, $11, $11, $12, $13
	dc.b $14, $15, $16, $16, $16, $16, $16, $15
	dc.b $15, $14, $13, $12, $12, $11, $12, $12
	dc.b $13, $14, $15, $15, $15, $15, $15, $14
	dc.b $12, $11, $11, $10, $10, $11, $11, $13
	dc.b $14, $15, $16, $16, $17, $17, $16, $16

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

fxpl_mask_blank:
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f

fxpl_mask_glafouk:

fxpl_mask_m:
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $10, $10, $0f, $0f, $0f, $0f, $0f, $10, $10, $0f
	dc.b $0f, $10, $10, $10, $0f, $0f, $0f, $10, $10, $10, $0f
	dc.b $0f, $10, $10, $10, $10, $0f, $10, $10, $10, $10, $0f
	dc.b $0f, $10, $10, $0f, $10, $10, $10, $0f, $10, $10, $0f
	dc.b $0f, $10, $10, $0f, $0f, $10, $0f, $0f, $10, $10, $0f
	dc.b $0f, $10, $10, $0f, $0f, $0f, $0f, $0f, $10, $10, $0f
	dc.b $0f, $10, $10, $0f, $0f, $0f, $0f, $0f, $10, $10, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $10, $10, $10, $10, $10, $10, $10, $10, $10, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f

fxpl_mask_metro:
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $10, $10, $10, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f
	dc.b $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f
	dc.b $0f, $0f, $10, $10, $10, $10, $10, $10, $10, $0f, $0f
	dc.b $0f, $0f, $10, $10, $10, $10, $10, $10, $10, $0f, $0f
	dc.b $0f, $0f, $10, $0f, $10, $10, $10, $0f, $10, $0f, $0f
	dc.b $0f, $0f, $10, $10, $10, $10, $10, $10, $10, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $10, $10, $10, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $0f, $0f, $0f, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f

fxpl_mask_atari:
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $0f, $10, $0f, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $0f, $10, $0f, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $0f, $10, $0f, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $0f, $10, $0f, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $10, $10, $0f, $10, $0f, $10, $10, $0f, $0f
	dc.b $0f, $10, $10, $10, $0f, $10, $0f, $10, $10, $10, $0f
	dc.b $0f, $10, $10, $0f, $0f, $10, $0f, $0f, $10, $10, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f

fxpl_mask_vcs:
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $10, $10, $10, $10, $10, $10, $10, $10, $10, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $10, $0f, $10, $0f, $0f, $10, $10, $0f, $0f, $10, $10
	dc.b $10, $0f, $10, $0f, $10, $0f, $0f, $0f, $10, $0f, $0f
	dc.b $10, $0f, $10, $0f, $10, $0f, $0f, $0f, $0f, $10, $0f
	dc.b $10, $0f, $10, $0f, $10, $0f, $0f, $0f, $0f, $0f, $10
	dc.b $0f, $10, $0f, $0f, $0f, $10, $10, $0f, $10, $10, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $10, $10, $10, $10, $10, $10, $10, $10, $10, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f

fxpl_mask_boy:
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $10, $10, $10, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $10, $10, $0f
	dc.b $0f, $0f, $0f, $10, $10, $10, $0f, $10, $0f, $10, $0f
	dc.b $0f, $0f, $10, $0f, $0f, $0f, $10, $0f, $0f, $0f, $0f
	dc.b $0f, $10, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $0f
	dc.b $0f, $10, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $0f
	dc.b $0f, $10, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $10, $0f, $0f, $0f, $10, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $10, $10, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f

fxpl_mask_girl:
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $10, $10, $10, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $0f, $0f, $0f, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f
	dc.b $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $0f, $0f, $0f, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $10, $10, $10, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $10, $10, $10, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f

fxpl_mask_cochon:
	dc.b $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f
	dc.b $0f, $10, $0f, $10, $0f, $0f, $0f, $10, $0f, $10, $0f
	dc.b $0f, $10, $0f, $0f, $10, $10, $10, $0f, $0f, $10, $0f
	dc.b $10, $0f, $0f, $10, $0f, $0f, $0f, $10, $0f, $0f, $10
	dc.b $10, $0f, $0f, $0f, $10, $10, $10, $0f, $0f, $0f, $10
	dc.b $10, $0f, $0f, $10, $10, $10, $10, $10, $0f, $0f, $10
	dc.b $10, $0f, $0f, $10, $0f, $10, $0f, $10, $0f, $0f, $10
	dc.b $10, $0f, $0f, $10, $10, $10, $10, $10, $0f, $0f, $10
	dc.b $0f, $10, $0f, $0f, $10, $10, $10, $0f, $0f, $10, $0f
	dc.b $0f, $0f, $10, $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $10, $10, $10, $10, $0f, $0f, $0f

fxpl_mask_lapin:
	dc.b $0f, $0f, $0f, $0f, $0f, $10, $0f, $0f, $10, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $10, $10, $0f, $10, $10, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $10, $10, $0f, $10, $10, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $10, $10, $0f, $10, $10, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $10, $0f, $0f, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $10, $10, $10, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $10, $0f, $10, $0f, $10, $10, $10, $0f, $0f
	dc.b $0f, $0f, $10, $10, $10, $10, $10, $10, $10, $0f, $0f
	dc.b $0f, $0f, $10, $10, $10, $10, $0f, $10, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $10, $0f, $0f, $10, $0f, $0f, $0f, $0f
	dc.b $0f, $0f, $0f, $0f, $10, $10, $0f, $0f, $0f, $0f, $0f

fxpl_masks:
	dc.w fxpl_mask_blank ; 0
	dc.w fxpl_mask_glafouk ; 1
	dc.w fxpl_mask_m ; 2
	dc.w fxpl_mask_metro ; 3
	dc.w fxpl_mask_atari ; 4
	dc.w fxpl_mask_vcs ; 5
	dc.w fxpl_mask_boy ; 6
	dc.w fxpl_mask_girl ; 7
	dc.w fxpl_mask_cochon ; 8
	dc.w fxpl_mask_lapin ; 9

fxpl_palette_orig1:
	dc.b $90, $92, $94, $96, $98, $9a, $9c, $9e
	dc.b $9e, $9c, $9a, $98, $96, $94, $92, $90
	dc.b $0e

fxpl_palette_orig2:
	dc.b $30, $32, $34, $36, $38, $3a, $3c, $3e
	dc.b $3e, $3c, $3a, $38, $36, $34, $32, $30
	dc.b $0e

fxpl_palette_orig3:
	dc.b $80, $82, $84, $86, $88, $8a, $8c, $8e
	dc.b $8e, $8c, $8a, $88, $86, $84, $82, $80
	dc.b $0e

fxpl_timeline1:
	.byte 0, 0, 0, 0, 2, 2, 2, 2
	.byte 2, 2, 2, 2, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 3, 3, 3, 3
	.byte 3, 3, 3, 3, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 2, 2, 2, 2
	.byte 2, 2, 2, 2, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 3, 3, 0, 0
	.byte 2, 2, 0, 0, 3, 2, 3, 2

fxpl_timeline2:
	.byte 0, 0, 0, 0, 6, 6, 6, 6
	.byte 6, 6, 6, 6, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 7, 7, 7, 7
	.byte 7, 7, 7, 7, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 6, 6, 6, 6
	.byte 6, 6, 6, 6, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 7, 7, 7, 7
	.byte 7, 7, 7, 7, 6, 7, 6, 7

fxpl_timeline3:
	.byte 0, 0, 0, 0, 8, 8, 8, 8
	.byte 8, 8, 8, 8, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 9, 9, 9, 9
	.byte 9, 9, 9, 9, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 8, 8, 8, 8
	.byte 8, 8, 8, 8, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 9, 9, 9, 9
	.byte 9, 9, 9, 9, 8, 9, 8, 9

fxpl_timeline4:
	.byte 0, 0, 0, 0, 4, 4, 4, 4
	.byte 4, 4, 4, 4, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 5, 5, 5, 5
	.byte 5, 5, 5, 5, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 4, 4, 4, 4
	.byte 4, 4, 4, 4, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 5, 5, 5, 5
	.byte 5, 5, 5, 5, 4, 5, 4, 5

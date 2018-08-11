; Copies pointer A to pointer B
; ex: m_copy_pointer src, dst
	MAC m_copy_pointer
	lda {1}
	sta {2}
	lda {1} + 1
	sta {2} + 1
	ENDM

; Add a byte to a pointer
; * 1st argument is the pointer to update
; * 2nd argument is the value to add
; ex: m_add_to_pointer ptr, #30
	MAC m_add_to_pointer
	clc
	lda {2}
	adc {1}
	sta {1}
	lda #0
	adc {1} + 1
	sta {1} + 1
	ENDM

; Loads one graphics unit into an fxp_line buffer item
; X is the index in the fxp_line
; Y is the offset from the graphics pointer
; ex: ldx #$00
;     ldy #$00
;     m_fxp_load_elmt
	MAC m_fxp_load_elmt
	lda (ptr),y
	sta fxp_line,x
	tya
	clc
	adc #30 ; 30 displayed lines
	tay
	inx
	ENDM


; Load graphics into fxp_line registers
; ptr must points towards the first element of the line to display
; This macro uses a, x and y registers
	MAC m_fxp_load_gfx
	ldx #0
	ldy #0
.load_loop:
	m_fxp_load_elmt
	cpx #5 ; 5 registers to fill
	bne .load_loop
	ENDM

; rotate one line to the left
	MAC m_fxp_rotate_line_left
	lda fxp_line
	asl
I	SET 4
	REPEAT 5
	rol fxp_line + I
I	SET I - 1
	REPEND
	ENDM

fx_pixscroll_kernel SUBROUTINE
	; Initialize
	m_copy_pointer fxp_pix_base, ptr

	lda #29
	sta tmp ; Displaying 30 lines
.kern_loop:
	sta WSYNC
	lda fxp_line
	sta PF1
	lda fxp_line + 1
	sta GRP0
	lda fxp_line + 2
	sta GRP1

	ldx #$0
	ldy #$0
	
	m_fxp_load_gfx
	m_fxp_rotate_line_left
	m_fxp_rotate_line_left
	m_fxp_rotate_line_left
	m_fxp_rotate_line_left

 	m_add_to_pointer ptr, #1
	dec tmp
	bpl .kern_loop

	lda #$0
	sta PF1
	sta GRP0
	sta GRP1
	rts
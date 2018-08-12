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
; ptr points towards the graphic to load
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

; rotate one line to the right
	MAC m_fxp_rotate_line_right
; TODO: We can probably remove one rotation - also on the left rotation
	lda fxp_line + 4
	lsr
I	SET 0
	REPEAT 5
	ror fxp_line + I
I	SET I + 1
	REPEND
	ENDM

; reverse PF3 buffer
	MAC m_reverse_pf3buf
	lda fxp_line + 3
	REPEAT 8
	asl
	ror fxp_line + 3
	REPEND
	ENDM

s_fxp_load_elmt SUBROUTINE
	m_fxp_load_elmt
	rts

s_fxp_rotate_line_left SUBROUTINE
	m_fxp_rotate_line_left
	rts

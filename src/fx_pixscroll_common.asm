; Loads one graphics unit into an fxp_line buffer item
; X is the index in the fxp_line
; Y is the offset from the graphics pointer fxp_pix_ptr
; ex: ldx #$00
;     ldy #$00
;     m_fxp_load_elmt
	MAC m_fxp_load_elmt
	lda (fxp_pix_ptr),y
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

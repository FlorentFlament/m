; Display a line while loading 2 elements of next line
fxp_line_load2elts SUBROUTINE
	sta WSYNC
	lda fxp_pf0_buf
	sta PF1
	m_fxp_load_elmt
	m_fxp_load_elmt
	lda fxp_pf3_buf
	sta PF1
	rts

; Display a line while rotating left next line
fxp_line_rotleft SUBROUTINE
	sta WSYNC
	lda fxp_pf0_buf
	sta PF1
	m_fxp_rotate_line_left
	lda fxp_pf3_buf
	sta PF1
	rts

fx_pixscroll_kernel SUBROUTINE
	lda #29
	sta tmp ; Displaying 30 lines
.kern_loop:
	sta WSYNC
	lda fxp_line
	sta fxp_pf0_buf
	sta PF1
	lda fxp_line + 1
	sta GRP0
	lda fxp_line + 2
	sta GRP1
	lda fxp_line + 3
	sta fxp_pf3_buf

	ldx #$0
	ldy #$0
	m_fxp_load_elmt
	lda fxp_pf3_buf
	sta PF1

	jsr fxp_line_load2elts
	jsr fxp_line_load2elts

	jsr fxp_line_rotleft
	jsr fxp_line_rotleft
	jsr fxp_line_rotleft
	jsr fxp_line_rotleft

	sta WSYNC
	lda fxp_pf0_buf
	sta PF1
 	m_add_to_pointer ptr, #1
	REPEAT 4
	nop
	REPEND
	lda fxp_pf3_buf
	sta PF1

	dec tmp
	bpl .kern_loop

.end:
	sta WSYNC
	lda #$0
	sta PF1
	sta GRP0
	sta GRP1

	ldx #$04
.zero_fxp_line
	sta fxp_line,x
	dex
	bpl .zero_fxp_line
	rts
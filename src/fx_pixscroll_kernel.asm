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

; Display a line without rotating next line
; Use X register
s_fxp_line_display SUBROUTINE
	lda fxp_pf0_buf
	sta PF1
	ldx #4
.wait_loop:
	dex
	bpl .wait_loop
	lda fxp_pf3_buf
	sta PF1
	rts

s_fxp_1line_rotleft SUBROUTINE
	lda fxp_pf0_buf
	sta PF1
	m_fxp_rotate_line_left
	lda fxp_pf3_buf
	sta PF1
	rts

s_fxp_2lines_rotleft0 SUBROUTINE
	jsr s_fxp_line_display
	sta WSYNC
	jsr s_fxp_line_display
	sta WSYNC
	rts

s_fxp_2lines_rotleft1 SUBROUTINE
	jsr s_fxp_1line_rotleft
	sta WSYNC
	jsr s_fxp_line_display
	sta WSYNC
	rts

s_fxp_2lines_rotleft2 SUBROUTINE
	jsr s_fxp_1line_rotleft
	sta WSYNC
	jsr s_fxp_1line_rotleft
	sta WSYNC
	rts

s_fxp_2lines_rotleft3 SUBROUTINE
	lda fxp_pf0_buf
	sta PF1
	m_fxp_rotate_line_left
	lda fxp_pf3_buf
	sta PF1
	m_fxp_rotate_line_left
	lda fxp_pf0_buf
	sta PF1
	m_fxp_rotate_line_left
	lda fxp_pf3_buf
	sta PF1
	sta WSYNC
	rts

s_fxp_2lines_rotleft4 SUBROUTINE
	lda fxp_pf0_buf
	sta PF1
	m_fxp_rotate_line_left
	lda fxp_pf3_buf
	sta PF1
	m_fxp_rotate_line_left
	lda fxp_pf0_buf
	sta PF1
	m_fxp_rotate_line_left
	lda fxp_pf3_buf
	sta PF1
	m_fxp_rotate_line_left
	rts

fxp_call_rotate:
	lda fxp_line_rotate_h,X
	pha
	lda fxp_line_rotate_l,X
	pha
	rts

; * ptr must contain a pointer towards the 1st elememt of the next
;   line to display
; * tmp must contain the number of shift to perform on the line
;   in [-4, 3]
; The kernel uses tmp1, and A, X, Y registers
fx_pixscroll_kernel SUBROUTINE
	lda #29
	sta tmp1 ; Displaying 30 lines
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

	; Rotate the next line appropriately
	ldx tmp
	jsr fxp_call_rotate

	ldx fxp_pf0_buf
	stx PF1
	m_add_to_pointer ptr, #1

	; Start rotating PF3
	lda fxp_line + 3
	REPEAT 2
	asl
	ror fxp_line + 3
	REPEND

	ldx fxp_pf3_buf
	stx PF1
	sta WSYNC
	ldx fxp_pf0_buf
	stx PF1

	; Finish rotating PF3
	REPEAT 6
	asl
	ror fxp_line + 3
	REPEND

	ldx fxp_pf3_buf
	stx PF1
	sta WSYNC
	jsr s_fxp_line_display
	dec tmp1
	bmi .end
	jmp .kern_loop

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

fxp_line_rotate_l:
	dc.b #<(s_fxp_2lines_rotleft0 - 1)
	dc.b #<(s_fxp_2lines_rotleft1 - 1)
	dc.b #<(s_fxp_2lines_rotleft2 - 1)
	dc.b #<(s_fxp_2lines_rotleft3 - 1)
	dc.b #<(s_fxp_2lines_rotleft4 - 1)
	dc.b #<(s_fxp_2lines_rotleft0 - 1)
	dc.b #<(s_fxp_2lines_rotleft1 - 1)
	dc.b #<(s_fxp_2lines_rotleft2 - 1)
fxp_line_rotate_h:
	dc.b #>(s_fxp_2lines_rotleft0 - 1)
	dc.b #>(s_fxp_2lines_rotleft1 - 1)
	dc.b #>(s_fxp_2lines_rotleft2 - 1)
	dc.b #>(s_fxp_2lines_rotleft3 - 1)
	dc.b #>(s_fxp_2lines_rotleft4 - 1)
	dc.b #>(s_fxp_2lines_rotleft0 - 1)
	dc.b #>(s_fxp_2lines_rotleft1 - 1)
	dc.b #>(s_fxp_2lines_rotleft2 - 1)

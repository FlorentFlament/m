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

s_fxp_1line_rotright SUBROUTINE
	lda fxp_pf0_buf
	sta PF1
	m_fxp_rotate_line_right
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

s_fxp_2lines_rotright1 SUBROUTINE
	jsr s_fxp_1line_rotright
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

s_fxp_2lines_rotright2 SUBROUTINE
	jsr s_fxp_1line_rotright
	sta WSYNC
	jsr s_fxp_1line_rotright
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

s_fxp_2lines_rotright3 SUBROUTINE
	lda fxp_pf0_buf
	sta PF1
	m_fxp_rotate_line_right
	lda fxp_pf3_buf
	sta PF1
	m_fxp_rotate_line_right
	lda fxp_pf0_buf
	sta PF1
	m_fxp_rotate_line_right
	lda fxp_pf3_buf
	sta PF1
	sta WSYNC
	rts

s_fxp_2lines_rotright4 SUBROUTINE
	lda fxp_pf0_buf
	sta PF1
	m_fxp_rotate_line_right
	lda fxp_pf3_buf
	sta PF1
	m_fxp_rotate_line_right
	lda fxp_pf0_buf
	sta PF1
	m_fxp_rotate_line_right
	lda fxp_pf3_buf
	sta PF1
	m_fxp_rotate_line_right
	rts

; After this call X and Y have the appropriate values
; for proper loading of the line elements
s_fxp_load_elt0_at0 SUBROUTINE
	ldx #0
	ldy #0
	m_fxp_load_elmt
	ldx #1
	rts

s_fxp_load_elt0_at4 SUBROUTINE
	ldx #4
	ldy #0
	m_fxp_load_elmt
	ldx #0
	rts

fxp_call_rotate:
	ldx fxp_shift_fine
	lda fxp_line_rotate_h,X
	pha
	lda fxp_line_rotate_l,X
	pha
	rts

fxp_call_load:
	ldx fxp_shift_fine
	lda fxp_line_load_h,X
	pha
	lda fxp_line_load_l,X
	pha
	lda fxp_pf3_buf
	sta PF1
	rts

; The kernel uses tmp1, and A, X, Y registers
fx_pixscroll_kernel SUBROUTINE
	sta WSYNC
	lda #29
	sta tmp1 ; Displaying 30 lines
.kern_loop:
	ldy tmp1
	;lda (fxp_col_ptr),y
	lda #$3c
	sta WSYNC
	sta COLUBK
	lda fxp_line
	sta fxp_pf0_buf
	sta PF1
	lda fxp_line + 1
	sta GRP0
	lda fxp_line + 2
	sta GRP1
	lda fxp_line + 3
	sta fxp_pf3_buf

	; Load the next line appropriately
	; The subroutine deals with updating PF1
	; After the call X and Y are set to be used by subsequent
	; calls to m_fxp_load_elmt
	jsr fxp_call_load

	lda fxp_pf0_buf
	sta PF1
	m_fxp_load_elmt
	lda fxp_pf3_buf
	sta PF1
	m_fxp_load_elmt

	sta WSYNC
	lda fxp_pf0_buf
	sta PF1
	m_fxp_load_elmt
	m_fxp_load_elmt
	lda fxp_pf3_buf
	sta PF1

	; Rotate the next line appropriately
	jsr fxp_call_rotate

	ldx fxp_pf0_buf
	stx PF1
	m_add_to_pointer fxp_pix_ptr, #1

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
	lda #$ff
	sta PF1
	sta GRP0
	sta GRP1

	ldx #$04
.zero_fxp_line
	sta fxp_line,x
	dex
	bpl .zero_fxp_line

	jmp RTSBank

fxp_line_load_l:
	dc.b #<(s_fxp_load_elt0_at0 - 1)
	dc.b #<(s_fxp_load_elt0_at0 - 1)
	dc.b #<(s_fxp_load_elt0_at0 - 1)
	dc.b #<(s_fxp_load_elt0_at0 - 1)
	dc.b #<(s_fxp_load_elt0_at4 - 1)
	dc.b #<(s_fxp_load_elt0_at4 - 1)
	dc.b #<(s_fxp_load_elt0_at4 - 1)
	dc.b #<(s_fxp_load_elt0_at4 - 1)
fxp_line_load_h:
	dc.b #>(s_fxp_load_elt0_at0 - 1)
	dc.b #>(s_fxp_load_elt0_at0 - 1)
	dc.b #>(s_fxp_load_elt0_at0 - 1)
	dc.b #>(s_fxp_load_elt0_at0 - 1)
	dc.b #>(s_fxp_load_elt0_at4 - 1)
	dc.b #>(s_fxp_load_elt0_at4 - 1)
	dc.b #>(s_fxp_load_elt0_at4 - 1)
	dc.b #>(s_fxp_load_elt0_at4 - 1)

fxp_line_rotate_l:
	dc.b #<(s_fxp_2lines_rotleft0 - 1)
	dc.b #<(s_fxp_2lines_rotleft1 - 1)
	dc.b #<(s_fxp_2lines_rotleft2 - 1)
	dc.b #<(s_fxp_2lines_rotleft3 - 1)
	dc.b #<(s_fxp_2lines_rotright4 - 1)
	dc.b #<(s_fxp_2lines_rotright3 - 1)
	dc.b #<(s_fxp_2lines_rotright2 - 1)
	dc.b #<(s_fxp_2lines_rotright1 - 1)
fxp_line_rotate_h:
	dc.b #>(s_fxp_2lines_rotleft0 - 1)
	dc.b #>(s_fxp_2lines_rotleft1 - 1)
	dc.b #>(s_fxp_2lines_rotleft2 - 1)
	dc.b #>(s_fxp_2lines_rotleft3 - 1)
	dc.b #>(s_fxp_2lines_rotright4 - 1)
	dc.b #>(s_fxp_2lines_rotright3 - 1)
	dc.b #>(s_fxp_2lines_rotright2 - 1)
	dc.b #>(s_fxp_2lines_rotright1 - 1)

; Setup monochrome animation with the animation provided as argument
	MAC m_fxa_vblank
	lda fxa_cnt
	REPEAT 3
	lsr
	REPEND
	tax
	lda fxa_{1}_timeline,X
	asl
	tax
	lda fxa_{1}_pics,X
	sta ptr
	lda fxa_{1}_pics+1,X
	sta ptr+1
	ENDM

; fx_animation_vblank_common code - needed in several banks
	MAC m_fxa_vblank_common
	SET_POINTER tmp, fxa_pf0_ptr ; Using tmp & tmp1 as pointer
	ldy #0
	ldx #5
.loop:
	lda ptr
	sta (tmp),Y
	m_add_to_pointer tmp, #1
	lda ptr+1
	sta (tmp),Y
	m_add_to_pointer tmp, #1
	m_add_to_pointer ptr, #30
	dex
	bpl .loop
	inc fxa_cnt
	ENDM

; fx_animation_kernel - needed in several banks
	MAC m_fxa_kernel
	sta WSYNC
	ldy #29
.outer_loop:
	ldx #7
.inner_loop:
	sta WSYNC
	lda (fxa_pf0_ptr),Y
	sta PF0
	lda (fxa_pf1_ptr),Y
	sta PF1
	lda (fxa_pf2_ptr),Y
	sta PF2
	lda (fxa_pf3_ptr),Y
	sta PF0
	lda (fxa_pf4_ptr),Y
	sta PF1
	lda (fxa_pf5_ptr),Y
	sta PF2
	dex
	bpl .inner_loop
	dey
	bpl .outer_loop

	sta WSYNC
	lda #0
	sta PF0
	sta PF1
	sta PF2
	ENDM
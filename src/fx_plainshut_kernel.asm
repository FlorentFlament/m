; Plain shutters FX - no picture behind

fx_plainshut_kernel SUBROUTINE
	jsr fxps_call_kernel
	lda #0 ; End with black anyway
	sta COLUBK
	jmp RTSBank

fxps_call_kernel SUBROUTINE
	lda fxps_move_i
	asl
	tax
	lda fxps_kernels+1,X
	pha
	lda fxps_kernels,X
	pha
	rts

; Plain screen macro
; Screen color must be passed as argument
	MAC m_fxps_plain
	sta WSYNC
	lda {1}
	sta COLUBK

	ldx #240
.loop:
	sta WSYNC
	dex
	bne .loop
	ENDM


fxps_kernel_nop SUBROUTINE
	m_fxps_plain fxps_bg_col
	rts

fxps_kernel_switch SUBROUTINE
	m_fxps_plain fxps_fg_col
	rts

fxps_kernel_topdown SUBROUTINE
	sta WSYNC

	ldx fxps_m0_cnt ; Lines count
	beq .bottom_part

	; Setup foreground color
	lda fxps_fg_col
	sta COLUBK
.upper_loop:
	sta WSYNC
	dex
	bne .upper_loop

.bottom_part
	; Should never be empty
	; Setup background color
	lda fxps_bg_col
	sta COLUBK

	; Computing bottom lines count
	lda #240 ; 240 total lines to display
	sec
	sbc fxps_m0_cnt
	tax
.bottom_loop:
	sta WSYNC
	dex
	bne .bottom_loop

.end_loop:
	rts

fxps_kernel_bottomup SUBROUTINE
	sta WSYNC

	; Setup background color
	lda fxps_bg_col
	sta COLUBK

	; Computing top lines count
	lda #240 ; 240 total lines to display
	sec
	sbc fxps_m0_cnt
	tax

.upper_loop:
	sta WSYNC
	dex
	bne .upper_loop

.bottom_part
	ldx fxps_m0_cnt ; Lines count
	beq .end_loop

	lda fxps_fg_col
	sta COLUBK
.bottom_loop:
	sta WSYNC
	dex
	bne .bottom_loop

.end_loop:
	rts

fxps_kernels:
	.word (fxps_kernel_nop - 1)
	.word (fxps_kernel_topdown - 1)
	.word (fxps_kernel_switch - 1)
	.word (fxps_kernel_bottomup - 1)

; Plain shutters FX - no picture behind

fx_plainshut_kernel SUBROUTINE
	sta WSYNC

	ldx fxps_m0_cnt ; Lines count
	beq .end_loop

	; Setup foreground color
	lda fxps_pf_col
	sta COLUBK

.upper_loop:
	sta WSYNC
	dex
	bne .upper_loop

.end_loop:
	lda fxps_bg_col
	sta COLUBK

	jmp RTSBank
; Plain shutters FX - no picture behind

fx_plainshut_kernel SUBROUTINE
	sta WSYNC

	ldx fxps_m0_cnt ; Lines count
	beq .end_loop

	; Setup foreground color
	lda fxps_fg_col
	sta COLUBK

.upper_loop:
	sta WSYNC
	dex
	bne .upper_loop

.end_loop:
	; Setup background color
	lda fxps_bg_col
	sta COLUBK

	jmp RTSBank
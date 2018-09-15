fx_intro_init SUBROUTINE
	lda #$3c
	sta COLUBK
	lda #$00
	sta COLUPF

	lda #$00
	sta fxi_logo_pos
	jmp RTSBank

fx_intro_vblank SUBROUTINE
	; go down for 160 frames/pixels then stop
	lda frame_cnt+1
	bne .end
	lda frame_cnt
	and #$80
	beq .move_logo ; frame_cnt < 128
	lda frame_cnt
	and #$7f
	cmp #32
	bpl .end ; frame_cnt >= 128+32
.move_logo
	inc fxi_logo_pos

.end:
	jmp RTSBank

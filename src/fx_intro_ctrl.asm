fx_intro_init SUBROUTINE
	lda #$3c
	sta COLUBK
	lda #$00
	sta COLUPF

	lda #$00
	sta fxi_logo_pos
	sta fxi_cnt
	jmp RTSBank

fx_intro_vblank SUBROUTINE
	lda fxi_logo_pos
	cmp #160
	beq .end

	inc fxi_cnt
	lda fxi_cnt
	cmp #2
	bne .end
	lda #$00
	sta fxi_cnt
	inc fxi_logo_pos

.end:
	jmp RTSBank

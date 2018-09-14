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
	; Logo must stop after 384 frames
	; go down for 320 frames/pixels then stop
	lda frame_cnt+1
	cmp #$01
	bmi .skip_64frames
	bne .end
	; if equals we must test LSB
	lda frame_cnt
	cmp #$80
	bpl .end
	cmp #$7c
	bpl .end
	jmp .go_down

.skip_64frames:
	lda frame_cnt
	cmp #$80
	bpl .go_down
	cmp #$40
	bmi .end

.go_down:
	inc fxi_cnt
	lda fxi_cnt
	cmp #2
	bne .end
	lda #$00
	sta fxi_cnt
	inc fxi_logo_pos

.end:
	jmp RTSBank

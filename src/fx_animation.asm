fx_animation_init SUBROUTINE
	lda #$00
	sta CTRLPF ; Set playfield in non mirror mode
	sta GRP0
	sta GRP1
	sta PF0
	sta PF1
	sta PF2

	lda #$00
	sta COLUBK
	lda #$3c
	sta COLUPF

	jmp RTSBank

fx_animation_lapin_vblank SUBROUTINE
	lda fxa_cnt
	REPEAT 4
	lsr
	REPEND
	tax
	lda fxa_lapin_timeline,X
	asl
	tax
	lda fxa_lapin_pics,X
	sta ptr
	lda fxa_lapin_pics+1,X
	sta ptr+1
	jmp fx_animation_vblank_common

fx_animation_meufkick_vblank SUBROUTINE
	lda fxa_cnt
	REPEAT 4
	lsr
	REPEND
	tax
	lda fxa_meufkick_timeline,X
	asl
	tax
	lda fxa_meufkick_pics,X
	sta ptr
	lda fxa_meufkick_pics+1,X
	sta ptr+1
	jmp fx_animation_vblank_common

fx_animation_vblank_common SUBROUTINE
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
	jmp RTSBank

fx_animation_kernel SUBROUTINE
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
	jmp RTSBank

	INCLUDE "fx_animation_data_lapin.asm"

fxa_lapin_pics:
	dc.w fxa_lapinmainA
	dc.w fxa_lapinmainB
	dc.w fxa_lapinmainC
	dc.w fxa_lapinmainD

fxa_lapin_timeline:
	dc.b 0, 0, 1, 1, 1, 1, 2, 2
	dc.b 2, 2, 3, 2, 3, 2, 3, 2

fxa_meufkick_pics:
	dc.w fxa_lapinmainA
	dc.w fxa_lapinmainB
	dc.w fxa_lapinmainC
	dc.w fxa_lapinmainD

fxa_meufkick_timeline:
	dc.b 0, 0, 1, 1, 1, 1, 2, 2
	dc.b 2, 2, 3, 2, 3, 2, 3, 2

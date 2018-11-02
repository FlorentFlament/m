fx_animation_init SUBROUTINE
	lda #$8c
	sta COLUPF
	sta COLUP0
	sta COLUP1
	jmp fx_animation_init_common

fx_animation_meufkick_init SUBROUTINE
	lda #$9c
	sta COLUPF
	sta COLUP0
	sta COLUP1
	jmp fx_animation_init_common

fx_animation_init_common SUBROUTINE
	; Set playfield to mirror mode and clear playfield registers
	lda #$01
	sta CTRLPF

	; Set large sprites
	lda #$07
	sta NUSIZ0
	sta NUSIZ1

	; Position sprites
	m_set_sprite_position 0, #6, #7
	m_set_sprite_position 1, #8, #5

	; Sets graphic registers to 0
	lda #$00
	sta PF0
	sta PF1
	sta PF2
	sta GRP0
	sta GRP1

	; Set FX colors
	lda #$00
	sta COLUBK

	lda #$00
	sta fxa_cnt

	jmp RTSBank

fx_animation_lapin_vblank SUBROUTINE
	m_fxa_vblank lapin
	jmp fx_animation_vblank_common

fx_animation_meufkick_vblank SUBROUTINE
	m_fxa_vblank meufkick
	jmp fx_animation_vblank_common

fx_animation_vblank_common SUBROUTINE
	m_fxa_vblank_common
	jmp RTSBank

fx_animation_kernel SUBROUTINE
	m_fxa_kernel
	jmp RTSBank

	INCLUDE "fx_animation_data_lapin.asm"
	INCLUDE "fx_animation_data_meufkick.asm"

fxa_lapin_pics:
	dc.w fxa_lapinmainA
	dc.w fxa_lapinmainB
	dc.w fxa_lapinmainC
	dc.w fxa_lapinmainD

fxa_lapin_timeline:
	dc.b 0, 0, 0, 0, 1, 1, 1, 1
	dc.b 1, 1, 1, 1, 2, 2, 2, 2
	dc.b 2, 2, 2, 2, 3, 3, 2, 2
	dc.b 3, 3, 2, 2, 3, 3, 2, 2

fxa_meufkick_pics:
	dc.w fxa_meufKickA
	dc.w fxa_meufKickB
	dc.w fxa_meufKickC
	dc.w fxa_meufKickD
	dc.w fxa_meufKickE
	dc.w fxa_meufKickF
	dc.w fxa_meufKickG
	dc.w fxa_meufKickH
	dc.w fxa_meufKickI

fxa_meufkick_timeline:
	dc.b 0, 0, 0, 0, 1, 1, 1, 1
	dc.b 1, 1, 1, 1, 2, 2, 2, 2
	dc.b 2, 2, 2, 2, 3, 4, 5, 6
	dc.b 5, 6, 7, 8, 0, 0, 0, 0

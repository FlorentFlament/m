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
	dc.b 0, 0, 1, 1, 1, 1, 2, 2
	dc.b 2, 2, 3, 2, 3, 2, 3, 2

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
	dc.b 0, 0, 1, 1, 2, 2, 3, 4
	dc.b 5, 6, 5, 6, 7, 8, 8, 8

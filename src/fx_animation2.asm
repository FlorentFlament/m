fx_animation_portique_vblank SUBROUTINE
	m_fxa_vblank portique
	jmp fx_animation2_vblank_common

fx_animation2_vblank_common SUBROUTINE
	m_fxa_vblank_common
	jmp RTSBank

fx_animation2_kernel SUBROUTINE
	m_fxa_kernel
	jmp RTSBank

	INCLUDE "fx_animation_data_portique.asm"

fxa_portique_pics:
	dc.w fxa_portiqueA
	dc.w fxa_portiqueB
	dc.w fxa_portiqueC
	dc.w fxa_portiqueD
	dc.w fxa_portiqueE
	dc.w fxa_portiqueF
	dc.w fxa_portiqueG
	dc.w fxa_portiqueH
	dc.w fxa_portiqueI
	dc.w fxa_portiqueJ

fxa_portique_timeline:
	dc.b 0, 0, 1, 2, 3, 4, 5, 6
	dc.b 7, 8, 7, 8, 7, 8, 9, 0
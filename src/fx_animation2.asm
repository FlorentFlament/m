fx_animation_portique_vblank SUBROUTINE
	m_fxa_vblank portique
	jmp fx_animation2_vblank_common

fx_animation_meufDrague_vblank SUBROUTINE
	m_fxa_vblank meufDrague
	jmp fx_animation2_vblank_common

fx_animation2_vblank_common SUBROUTINE
	m_fxa_vblank_common
	jmp RTSBank

fx_animation2_kernel SUBROUTINE
	m_fxa_kernel
	jmp RTSBank

	INCLUDE "fx_animation_data_portique.asm"
	INCLUDE "fx_animation_data_meufDrague.asm"

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
	dc.w fxa_portiqueAA

fxa_portique_timeline:
	dc.b 0, 0, 0, 0, 9, 9, 9, 9
	dc.b 9, 9, 9, 9, 1, 1, 1, 1
	dc.b 1, 1, 1, 1, 2, 2, 2, 2
	dc.b 3, 4, 5, 6, 7, 8, 7, 8


fxa_meufDrague_pics:
	dc.w fxa_meufDragueA
	dc.w fxa_meufDragueB
	dc.w fxa_meufDragueC
	dc.w fxa_meufDragueD
	dc.w fxa_meufDragueE
	dc.w fxa_meufDragueF
	dc.w fxa_meufDragueG
	dc.w fxa_meufDragueH
	dc.w fxa_meufDragueI

fxa_meufDrague_timeline:
	dc.b 0, 0, 0, 0, 1, 1, 1, 1
	dc.b 2, 2, 2, 2, 3, 3, 3, 3
	dc.b 3, 3, 2, 2, 4, 4, 4, 4
	dc.b 4, 4, 2, 5, 6, 7, 8, 0

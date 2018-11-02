;;;-----------------------------------------------------------------------------
;;; Header

	PROCESSOR 6502
	INCLUDE "vcs.h"	; Provides RIOT & TIA memory map
	INCLUDE "macro.h"	; This file includes some helper macros

; The 2 next constants can be used to ease FXs developments
; Use START_PART to select on which part to start the demo
; Set SINGLE_PART to 1 to disable parts switching
START_PART  equ 0 ; default 0
SINGLE_PART equ 0 ; default 0
ENDMAIN_PART equ 24 ; Turn off soundtrack if reached last track
GREETZ_PART equ 25

;;;-----------------------------------------------------------------------------
;;; RAM segment

	SEG.U ram
	ORG $0080

	; Songs variables first
	INCLUDE "SilverWoman_nogoto_variables.asm"
	INCLUDE "PasteHeck_variables.asm"

tmp	equ tt_ptr
tmp1	equ tt_ptr+1
ptr	ds 2
frame_cnt	ds 2 ; 16 bits frames counter
curpart   ds 1 ; Index of current part (FX)

; part-specific RAM starts here
PARTRAM equ *
;4 bytes of stack used
RAMEND  equ $FC
	echo "RAM available for parts:", (RAMEND-PARTRAM)d, "bytes"

	INCLUDE "fx_intro_variables.asm"
	echo "fx_intro:", (RAMEND-*)d, "bytes left"
	INCLUDE "fx_plainshut_variables.asm"
	echo "fx_plainshut:", (RAMEND-*)d, "bytes left"
	INCLUDE "fx_pixscroll_variables.asm"
	echo "fx_pixscroll:", (RAMEND-*)d, "bytes left"
	INCLUDE "fx_animation_variables.asm"
	echo "fx_animation:", (RAMEND-*)d, "bytes left"
	INCLUDE "fx_vertscroll_variables.asm"
	echo "fx_vertscroll_variables:", (RAMEND-*)d, "bytes left"
	INCLUDE "fx_plasma_variables.asm"
	echo "fx_plasma:", (RAMEND-*)d, "bytes left"
	INCLUDE "fx_spritebg_variables.asm"
	echo "fx_spritebg:", (RAMEND-*)d, "bytes left"
	INCLUDE "fx_endmain_variables.asm"
	echo "fx_endmain:", (RAMEND-*)d, "bytes left"
	INCLUDE "fx_lapinko_variables.asm"
	echo "fx_lapinko:", (RAMEND-*)d, "bytes left"

; Bank switching macro by Tjoppen (slightly adapted)
RTSBank equ $1FD9
JMPBank equ $1FE6

;39 byte bootstrap macro
;Includes RTSBank, JMPBank routines and JMP to Start in Bank 7
	MAC END_SEGMENT_CODE
	;RTSBank
	;Perform a long RTS
	tsx
	lda $02,X
	;decode bank
	;bank 0: $1000-$1FFF
	;bank 1: $3000-$3FFF
	;...
	;bank 7: $F000-$FFFF
	lsr
	lsr
	lsr
	lsr
	lsr
	tax
	nop $1FF4,X ;3 B
	rts
	;JMPBank
	;Perform a long jmp to (ptr)
	;The bank number is stored in the topmost three bits of (ptr)
	;Example usage:
	;   SET_POINTER ptr, Address
	;   jsr JMPBank
	;
	;$1FE6-$1FED
	lda ptr+1
	lsr
	lsr
	lsr
	lsr
	lsr
	tax
	;$1FEE-$1FF3
	nop $1FF4,X ;3 B
	jmp (ptr)   ;3 B
	ENDM

	MAC END_SEGMENT
.BANK	SET {1}
	echo "Bank",(.BANK)d,":", ((RTSBank + (.BANK * 8192)) - *)d, "free"

	ORG RTSBank + (.BANK * 4096)
	RORG RTSBank + (.BANK * 8192)
	END_SEGMENT_CODE
;$1FF4-$1FFB - These are the bankswitching hotspots
	.byte 0,0,0,0
	.byte 0,0,0,$4C ;JMP Start (reading the instruction jumps to bank 7, i.e init address)
;$1FFC-1FFF
	.word $1FFB
	.word $1FFB
;Bank .BANK+1
	ORG $1000 + ((.BANK + 1) * 4096)
	RORG $1000 + ((.BANK + 1) * 8192)
	ENDM

	; Adding small JSRBank macro
	MAC JSRBank
	SET_POINTER ptr, {1}
	jsr JMPBank
	ENDM
; End of bank switching macro definitions

; Handy macros
	INCLUDE "common.asm"
	INCLUDE "fx_animation_common.asm"
	INCLUDE "fx_pixscroll_common.asm"

;-----------------------------------------------------------------------------
; Code segment
	echo "--- ROM follows ---"
	SEG code

; Bank 0
	ORG $1000
	RORG $1000
tt_player_proxy SUBROUTINE
PARTSTART_ZIK1 equ *
	; Turn off soundtrack at the end of demo
	lda curpart
	cmp ENDMAIN_PART
	bne tt_PlayerStart
	lda #$00
	sta AUDC0
	sta AUDC1
	jmp tt_player_proxy_end
	INCLUDE "SilverWoman_nogoto_player.asm"
tt_player_proxy_end:
	jmp RTSBank
	INCLUDE "SilverWoman_nogoto_trackdata.asm"
	echo "zik1:", (*-PARTSTART_ZIK1)d, "B"
PARTSTART_ENDMAIN equ *
	INCLUDE "fx_endmain.asm"
	echo "fx_endmain:", (*-PARTSTART_ENDMAIN)d, "B"
PARTSTART_LAPINKO equ *
	INCLUDE "fx_lapinko.asm"
	echo "fx_lapinko:", (*-PARTSTART_LAPINKO)d, "B"
	END_SEGMENT 0


; Bank 1
PARTSTART_VERTSCROLL equ *
	INCLUDE "fx_vertscroll.asm"
	echo "fx_vertscroll:", (*-PARTSTART_VERTSCROLL)d, "B"
PARTSTART_INTRO equ *
	INCLUDE "fx_intro_ctrl.asm"
	INCLUDE "fx_intro_kernel.asm"
	echo "fx_intro:", (*-PARTSTART_INTRO)d, "B"
	END_SEGMENT 1

; Bank 2
PARTSTART_PLASMA equ *
	INCLUDE "fx_plasma.asm"
	echo "fx_plasma:", (*-PARTSTART_PLASMA)d, "B"
	END_SEGMENT 2

; Bank 3
PARTSTART_GREETINGS equ *
	INCLUDE "fx_greetings_ctrl.asm"
	INCLUDE "fx_greetings_kernel.asm"
	echo "fx_greetings:", (*-PARTSTART_GREETINGS)d, "B"
PARTSTART_ZIK2 equ *
	INCLUDE "PasteHeck_player.asm"
	jmp RTSBank
	INCLUDE "PasteHeck_trackdata.asm"
	echo "zik2:", (*-PARTSTART_ZIK2)d, "B"
	END_SEGMENT 3

; Bank 4
PARTSTART_ANIM2 equ *
	INCLUDE "fx_animation2.asm"
	echo "fx_animation2:", (*-PARTSTART_ANIM2)d, "B"
PARTSTART_SPRITEBG equ *
	INCLUDE "fx_spritebg.asm"
	echo "fx_spritebg:", (*-PARTSTART_SPRITEBG)d, "B"
	END_SEGMENT 4

; Bank 5
PARTSTART_PIXSCROLL3 equ *
	INCLUDE "fx_pixscroll_ctrl3.asm"
	INCLUDE "fx_pixscroll_kernel3.asm"
	echo "fx_pixscroll3:", (*-PARTSTART_PIXSCROLL3)d, "B"
PARTSTART_ANIMATION equ *
	INCLUDE "fx_animation.asm"
	echo "fx_animation:", (*-PARTSTART_ANIMATION)d, "B"
	END_SEGMENT 5

; Bank 6
PARTSTART_PIXSCROLL2 equ *
	INCLUDE "fx_pixscroll_ctrl2.asm"
	INCLUDE "fx_pixscroll_kernel2.asm"
	echo "fx_pixscroll2:", (*-PARTSTART_PIXSCROLL2)d, "B"
PARTSTART_SHUTTER equ *
	INCLUDE "fx_plainshut_ctrl.asm"
	INCLUDE "fx_plainshut_kernel.asm"
	echo "fx_shutter:", (*-PARTSTART_SHUTTER)d, "B"
	END_SEGMENT 6

; Bank 7
PARTSTART_MAIN equ *
inits:
	.word fx_intro_init ; 0
	.word fx_plainshut1_init ; 1

	.word fx_vertscroll_init_ligneMetro ; 2 metro line
	.word fx_animation_init ; 3 portique
	.word fx_plasma1_init ; 4 blue plasma
	.word fx_plainshut3_init ; 5

	.word fx_pixscroll_metro_init ; 6 train arrives
	.word fx_animation_init ; 7 rabbit hand in metro door
	.word fx_spritebg_train_init ; 8 moving train
	.word fx_plainshut2_init ; 9

	.word fx_vertscroll_init_ticketMetro ; 10 ticket metro
	.word fx_pixscroll_inside_init ; 11 look inside
	.word fx_animation_init ; 12 girl punching lapin
	.word fx_plasma2_init ; 13 yellow plasma
	.word fx_plainshut1_init ; 14

	.word fx_vertscroll_init_quaiSouris ; 15 quai Souris
	.word fx_pixscroll_murstation_init ; 16 mur station
	.word fx_animation_init ; 17 girl kicking lapin
	.word fx_plasma3_init ; 18 red plasma (cochon + lapin)

	.word fx_spritebg_lapinMarche_init ; 19 lapin marche
	.word fx_vertscroll_init_mistressStella ; 20 mistress Stella
	.word fx_pixscroll_freewomen_init ; 21 Free women
	.word fx_plasma3_init ; 22 purple plasma

	.word fx_lapinko_init ; 23
	.word fx_endmain_init ; 24
	.word fx_greetings_init ; 25

vblanks:
	.word fx_intro_vblank
	.word fx_plainshut_vblank

	.word fx_vertscroll_vblank_ligneMetro ; metro line
	.word fx_animation_portique_vblank ; portique
	.word fx_plasma_vblank ; blue plasma
	.word fx_plainshut_vblank

	.word fx_pixscroll_metro_vblank ; train arrives
	.word fx_animation_lapin_vblank ; rabbit hand in metro door
	.word fx_spritebg_train_vblank ; moving train
	.word fx_plainshut_vblank

	.word fx_vertscroll_vblank_ticketMetro ; ticket metro
	.word fx_pixscroll_inside_vblank ; look inside
	.word fx_animation_meufDrague_vblank ; girl punching lapin
	.word fx_plasma_vblank ; green plasma
	.word fx_plainshut_vblank

	.word fx_vertscroll_vblank_quaiSouris ; quai Souris
	.word fx_pixscroll_murstation_vblank ; mur station
	.word fx_animation_meufkick_vblank ; girl kicking lapin
	.word fx_plasma_vblank ; red plasma

	.word fx_spritebg_lapinMarche_vblank ; lapin marche
	.word fx_vertscroll_vblank_mistressStella ; mistress Stella
	.word fx_pixscroll_freewomen_vblank ; Free women
	.word fx_plasma_vblank ; red plasma

	.word fx_lapinko_vblank
	.word fx_endmain_vblank
	.word fx_greetings_vblank

kernels:
	.word fx_intro_kernel
	.word fx_plainshut_kernel

	.word fx_vertscroll_kernel ; metro line - green
	.word fx_animation2_kernel ; portique - red
	.word fx_plasma_kernel ; blue plasma
	.word fx_plainshut_kernel

	; Red
	.word fx_pixscroll_kernel ; train arrives - green
	.word fx_animation_kernel ; rabbit hand in metro door - red
	.word fx_spritebg_kernel ; moving train - blue
	.word fx_plainshut_kernel

	; Blue
	.word fx_vertscroll_kernel ; ticket metro - blue
	.word fx_pixscroll_kernel ; look inside - vert
	.word fx_animation2_kernel ; girl punching lapin - red
	.word fx_plasma_kernel ; green plasma
	.word fx_plainshut_kernel

	; Vert
	.word fx_vertscroll_kernel ; quai Souris - blue
	.word fx_pixscroll_kernel2 ; mur station - green
	.word fx_animation_kernel ; girl kicking lapin - red
	.word fx_plasma_kernel ; red plasma

	.word fx_spritebg_kernel ; lapin marche
	.word fx_vertscroll_kernel ; mistress Stella - blue
	.word fx_pixscroll_kernel3 ; free women - green
	.word fx_plasma_kernel ; purple plasma

	.word fx_lapinko_kernel ; red
	.word fx_endmain_kernel
	.word fx_greetings_kernel ; white


; specifies on which frame to switch parts
M_P0  equ 256
M_P1  equ M_P0  + 512
M_P2  equ M_P1  + 768
M_P3  equ M_P2  + 256
M_P4  equ M_P3  + 512
M_P5  equ M_P4  + 512
M_P6  equ M_P5  + 512
M_P7  equ M_P6  + 512
M_P8  equ M_P7  + 512
M_P9  equ M_P8  + 512
M_P10 equ M_P9  + 320
M_P11 equ M_P10 + 448
M_P12 equ M_P11 + 256
M_P13 equ M_P12 + 512
M_P14 equ M_P13 + 512
M_P15 equ M_P14 + 512
M_P16 equ M_P15 + 512
M_P17 equ M_P16 + 512
M_P18 equ M_P17 + 512
M_P19 equ M_P18 + 512
M_P20 equ M_P19 + 480
M_P21 equ M_P20 + 544
M_P22 equ M_P21 + 512
M_P23 equ M_P22 + 512
M_P24 equ M_P23 + 256
M_P25 equ 0

partswitch:
	.word M_P0
	.word M_P1
	.word M_P2
	.word M_P3
	.word M_P4
	.word M_P5
	.word M_P6
	.word M_P7
	.word M_P8
	.word M_P9
	.word M_P10
	.word M_P11
	.word M_P12
	.word M_P13
	.word M_P14
	.word M_P15
	.word M_P16
	.word M_P17
	.word M_P18
	.word M_P19
	.word M_P20
	.word M_P21
	.word M_P22
	.word M_P23
	.word M_P24
	.word M_P25

; Calls current part
; unique argument is the stuff to call (inits, vblanks or kernels)
; ex: call_curpart vblanks
	MAC call_curpart
	lda curpart
	asl
	tax
	lda {1},X
	sta ptr
	lda {1}+1,X
	sta ptr+1
	jsr JMPBank
	ENDM

init	CLEAN_START ; Initializes Registers & Memory
	INCLUDE "SilverWoman_nogoto_init.asm"
	lda #START_PART
	sta curpart
	call_curpart inits ; Initialize first part

main_loop SUBROUTINE
	VERTICAL_SYNC		; 4 scanlines Vertical Sync signal

	; ===== VBLANK =====
	; 34 VBlank lines (76 cycles/line)
	lda #39			; (/ (* 34.0 76) 64) = 40.375
	sta TIM64T
	call_curpart vblanks
	jsr wait_timint

	; ===== KERNEL =====
	; 248 Kernel lines
	lda #19			; (/ (* 248.0 76) 1024) = 18.40
	sta T1024T
	call_curpart kernels
	jsr wait_timint		; scanline 289 - cycle 30

	; ===== OVERSCAN ======
	; 26 Overscan lines
	lda #22			; (/ (* 26.0 76) 64) = 30.875
	sta TIM64T

	; Play song according to the part
	lda curpart
	cmp GREETZ_PART
	beq .greetz_song
	JSRBank tt_player_proxy
	jmp .song_chosen
.greetz_song:
	JSRBank PasteHeck_tt_PlayerStart
.song_chosen:
	m_add_to_pointer frame_cnt, #1
	jsr check_partswitch
	jsr wait_timint

	jmp main_loop		; scanline 308 - cycle 15


check_partswitch SUBROUTINE
	IF SINGLE_PART
	rts
	ENDIF
	lda curpart
	asl
	tax
	lda partswitch,X
	cmp frame_cnt
	bne .no_switch
	lda partswitch+1,X
	cmp frame_cnt+1
	bne .no_switch
	; Switch part
	inc curpart
	call_curpart inits
.no_switch:
	rts


wait_timint SUBROUTINE
	lda TIMINT
	beq wait_timint
	rts

	echo "main:", (*-PARTSTART_MAIN)d, "B"

PARTSTART_PIXSCROLL equ *
	INCLUDE "fx_pixscroll_ctrl.asm"
	INCLUDE "fx_pixscroll_kernel.asm"
	echo "fx_pixscroll:", (*-PARTSTART_PIXSCROLL)d, "B"

	echo "Bank 7 :", ((RTSBank + (7 * 8192)) - *)d, "free"
;;;-----------------------------------------------------------------------------
;;; Reset Vector
	ORG RTSBank + $7000
	RORG RTSBank + $E000
	END_SEGMENT_CODE
	;$1FF4-$1FFB
	.byte 0,0,0,0
	.byte 0,0,0,$4C
	;$1FFC-1FFF
	.word init
	.word init

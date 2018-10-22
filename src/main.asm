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

;;;-----------------------------------------------------------------------------
;;; RAM segment

	SEG.U ram
	ORG $0080

	; Songs variables first
	INCLUDE "SilverWoman_nogoto_variables.asm"

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
	INCLUDE "fx_plasma_variables.asm"
	echo "fx_plasma:", (RAMEND-*)d, "bytes left"
	INCLUDE "fx_spritebg_variables.asm"
	echo "fx_spritebg:", (RAMEND-*)d, "bytes left"

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
	INCLUDE "SilverWoman_nogoto_trackdata.asm"
	INCLUDE "SilverWoman_nogoto_player.asm"
	jmp RTSBank
	END_SEGMENT 0

; Bank 1
PARTSTART_SHUTTER equ *
	INCLUDE "fx_plainshut_ctrl.asm"
	INCLUDE "fx_plainshut_kernel.asm"
	INCLUDE "fx_pixscroll_ctrl2.asm"
	INCLUDE "fx_pixscroll_kernel2.asm"
	echo "fx_shutter:", (*-PARTSTART_SHUTTER)d, "B"
	END_SEGMENT 1

; Bank 2
PARTSTART_PIXSCROLL equ *
	INCLUDE "fx_pixscroll_ctrl.asm"
	INCLUDE "fx_pixscroll_kernel.asm"
	echo "fx_pixscroll:", (*-PARTSTART_PIXSCROLL)d, "B"
	END_SEGMENT 2

; Bank 3
PARTSTART_PLASMA equ *
	INCLUDE "fx_plasma.asm"
	echo "fx_plasma:", (*-PARTSTART_PLASMA)d, "B"
	END_SEGMENT 3

; Bank 4
PARTSTART_INTRO equ *
	INCLUDE "fx_intro_ctrl.asm"
	INCLUDE "fx_intro_kernel.asm"
	echo "fx_intro:", (*-PARTSTART_INTRO)d, "B"
PARTSTART_ANIM2 equ *
	INCLUDE "fx_animation2.asm"
	echo "fx_animation2:", (*-PARTSTART_ANIM2)d, "B"
	END_SEGMENT 4

; Bank 5
PARTSTART_ANIMATION equ *
	INCLUDE "fx_animation.asm"
	echo "fx_animation:", (*-PARTSTART_ANIMATION)d, "B"
	END_SEGMENT 5

; Bank 6
PARTSTART_SPRITEBG equ *
	INCLUDE "fx_spritebg.asm"
	echo "fx_spritebg:", (*-PARTSTART_SPRITEBG)d, "B"
	END_SEGMENT 6

; Bank 7
inits:
	.word fx_intro_init
	.word fx_plainshut1_init
	.word fx_pixscroll_metro_init2 ; train arrives
	.word fx_pixscroll_metro_init ; train arrives
	.word fx_animation_init ; rabbit hand in metro door
	.word fx_plasma1_init ; blue plasma
	.word fx_plainshut1_init
	.word fx_animation_init ; portique
	.word fx_pixscroll_inside_init ; look inside
	.word fx_spritebg_init ; moving train
	.word fx_animation_init ; girl punching lapin
	.word fx_plasma2_init ; yellow plasma
	.word fx_plainshut1_init
	.word fx_animation_init ; girl kicking lapin
	.word fx_plasma3_init ; red plasma

vblanks:
	.word fx_intro_vblank
	.word fx_plainshut_vblank
	.word fx_pixscroll_metroline_vblank ; train arrives
	.word fx_pixscroll_metro_vblank ; train arrives
	.word fx_animation_lapin_vblank ; rabbit hand in metro door
	.word fx_plasma_vblank ; blue plasma
	.word fx_plainshut_vblank
	.word fx_animation_portique_vblank ; portique
	.word fx_pixscroll_inside_vblank ; look inside
	.word fx_spritebg_vblank ; moving train
	.word fx_animation_meufDrague_vblank ; girl punching lapin
	.word fx_plasma_vblank ; yellow plasma
	.word fx_plainshut_vblank
	.word fx_animation_meufkick_vblank ; girl kicking lapin
	.word fx_plasma_vblank ; red plasma

kernels:
	.word fx_intro_kernel
	.word fx_plainshut_kernel
	.word fx_pixscroll_kernel2 ; train arrives
	.word fx_pixscroll_kernel ; train arrives
	.word fx_animation_kernel ; rabbit hand in metro door
	.word fx_plasma_kernel ; blue plasma
	.word fx_plainshut_kernel
	.word fx_animation2_kernel ; portique
	.word fx_pixscroll_kernel ; look inside
	.word fx_spritebg_kernel ; moving train
	.word fx_animation2_kernel ; girl punching lapin
	.word fx_plasma_kernel ; yellow plasma
	.word fx_plainshut_kernel
	.word fx_animation_kernel ; girl kicking lapin
	.word fx_plasma_kernel ; red plasma

; specifies on which frame to switch parts
M_I    equ 256
M_P0   equ M_I  + 512
M_P1   equ M_P0 + 768
M_P2   equ M_P1 + 512
M_P3   equ M_P2 + 512
M_P4   equ M_P3 + 512
M_P5   equ M_P4 + 512
M_P6   equ M_P5 + 512
M_P7   equ M_P6 + 512
M_P8   equ M_P7 + 512
M_P9   equ M_P8 + 512
M_P10  equ M_P9 + 512
M_P11  equ M_P10+ 512
M_P12  equ M_P11+ 512
M_PEND equ 0
partswitch:
	.word M_I
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
	.word M_PEND

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
	JSRBank tt_PlayerStart
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

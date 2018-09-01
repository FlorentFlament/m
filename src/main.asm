;;;-----------------------------------------------------------------------------
;;; Header

	PROCESSOR 6502
	INCLUDE "vcs.h"	; Provides RIOT & TIA memory map
	INCLUDE "macro.h"	; This file includes some helper macros


;;;-----------------------------------------------------------------------------
;;; RAM segment

	SEG.U ram
	ORG $0080

	; Songs variables first
	INCLUDE "SilverWoman_nogoto_variables.asm"

tmp	equ tt_ptr
tmp1	equ tt_ptr+1
ptr	ds 2
ptr1	ds 2
frame_cnt	ds 2 ; 16 bits frames counter
curpart   ds 1 ; Index of current part (FX)

; part-specific RAM starts here
PARTRAM equ *
;4 bytes of stack used
RAMEND  equ $FC
	echo "RAM available for parts:", (RAMEND-PARTRAM)d, "bytes"

	INCLUDE "fx_shutters_variables.asm"
	echo "fx_shutters:", (RAMEND-*)d, "bytes left"
	INCLUDE "fx_pixscroll_variables.asm"
	echo "fx_pixscroll:", (RAMEND-*)d, "bytes left"
	INCLUDE "fx_plasma_variables.asm"
	echo "fx_plasma:", (RAMEND-*)d, "bytes left"

;;;-----------------------------------------------------------------------------
;;; Code segment

	SEG code
	ORG $F000

	INCLUDE "common.asm"
	;INCLUDE "fx_shutters_control.asm"
	;INCLUDE "fx_shutters_kernel.asm"
	INCLUDE "fx_pixscroll_common.asm"
	INCLUDE "fx_pixscroll_ctrl.asm"
	INCLUDE "fx_pixscroll_kernel.asm"
	;INCLUDE "fx_plasma.asm"

; Then the remaining of the code
init	CLEAN_START		; Initializes Registers & Memory

	; Initialization
	; Put here whatever initialization code
	INCLUDE "SilverWoman_nogoto_init.asm"
	;jsr fx_shutters_init
	jsr fx_pixscroll_init

	;jsr fx_plasma_init

main_loop SUBROUTINE
	VERTICAL_SYNC		; 4 scanlines Vertical Sync signal

	; ===== VBLANK =====
	; 34 VBlank lines (76 cycles/line)
	lda #39			; (/ (* 34.0 76) 64) = 40.375
	sta TIM64T
	INCLUDE "SilverWoman_nogoto_player.asm"

	;jsr fx_shutters_vblank
	jsr fx_pixscroll_vblank
	;jsr fx_plasma_vblank
	jsr wait_timint

	; ===== KERNEL =====
	; 248 Kernel lines
	lda #19			; (/ (* 248.0 76) 1024) = 18.40
	sta T1024T
	;jsr fx_shutters_kernel	; scanline 33 - cycle 23
	jsr fx_pixscroll_kernel	; scanline 33 - cycle 23
	;jsr fx_plasma_kernel
	jsr wait_timint		; scanline 289 - cycle 30

	; ===== OVERSCAN ======
	; 26 Overscan lines
	lda #22			; (/ (* 26.0 76) 64) = 30.875
	sta TIM64T
	m_add_to_pointer frame_cnt, #1
	jsr wait_timint

	jmp main_loop		; scanline 308 - cycle 15


; X register must contain the number of scanlines to skip
; X register will have value 0 on exit
wait_timint:
	lda TIMINT
	beq wait_timint
	rts

; Data
	INCLUDE "SilverWoman_nogoto_trackdata.asm"

	echo "ROM left: ", ($fffc - *)d, "bytes"

;;;-----------------------------------------------------------------------------
;;; Reset Vector

	SEG reset
	ORG $FFFC
	DC.W init
	DC.W init

; Flushes a buffer to actual PF0 - PF2 registers
; The buffer to flush must be passed as argument
; ex: m_pf_flush fb0_base
	MAC m_pf_flush
	lda {1} + 0
	sta PF0
	lda {1} + 1
	sta PF1
	lda {1} + 2
	sta PF2
	ENDM

; Flushes a full line to the screen.
; The macro calls m_pf_flush for the left part of the screen
; then for the right part.
; The frame buffer base address must be passed as argument.
; ex: m_line_flush fb0_base
	MAC m_line_flush
	m_pf_flush {1} + 0 ; Left screen part
	REPEAT 6
	nop
	REPEND
	m_pf_flush {1} + 3 ; Right screen part
	ENDM

; Updates a frame buffer element from
; * the graph pointed at by gfx_pf_base
; * the frame buffer address provided as 1st argument
; * the mask to apply provided as 2ns argument
; * the frame buffer element provided as 3rd argument
; * y's value must be the index of the GFX line to fetch
; ex: m_update_db fb1_base,mask_m0_val,2
	MAC m_update_fb
	lda (gfx_pf_base + {3}*2),y
	ora {2} + {3}
	sta {1} + {3}
	ENDM

; Update flag to switch the 2 frame buffers
	MAC m_switch_fb
	lda fb_switch
	eor #$01
	sta fb_switch
	ENDM

; Flushing fb0 and updating fb1
; The mask to use must be passed as argument
	MAC m_fb0_line
I	SET 0
	REPEAT 6
	sta WSYNC
	m_line_flush fb0_base
	m_update_fb fb1_base,{1},I
I	SET I + 1
	REPEND
	sta WSYNC
	m_line_flush fb0_base
	m_switch_fb
	sta WSYNC
	m_line_flush fb0_base
	ENDM

; Flushing fb1 and updating fb0
; The mask to use must be passed as argument
	MAC m_fb1_line
I	SET 0
	REPEAT 6
	sta WSYNC
	m_line_flush fb1_base
	m_update_fb fb0_base,{1},I
I	SET I + 1
	REPEND
	sta WSYNC
	m_line_flush fb1_base
	m_switch_fb
	sta WSYNC
	m_line_flush fb1_base
	ENDM


; the mask to apply provided as argument
; The mask to use must be passed as argument
	MAC m_one_line
	lda fb_switch
	beq .fb0_active
	jmp .fb1_active

.fb0_active:
	m_fb0_line {1}
	jmp .end

.fb1_active:
	m_fb1_line {1}

.end:
	ENDM


; Pre-compute first lines in frame buffer fb0
; the mask value to use has to be provided as argument
; ex: m_precomp_fb4mask mask_m0_val
	MAC m_precomp_fb4mask
I	SET 0
	REPEAT 6
	m_update_fb fb0_base,{1},I
I	SET I + 1
	REPEND
	ENDM

; Compute first buffer
	MAC m_precomp_fb
	ldy mask_m0_cnt
	beq .m1
	dey
	m_precomp_fb4mask mask_m0_val
	jmp .end
.m1
	ldy mask_m1_cnt
	beq .m2
	dey
	m_precomp_fb4mask mask_m1_val
	jmp .end
.m2
	ldy mask_m2_cnt
	dey
	m_precomp_fb4mask mask_m2_val
.end:
	ENDM

fx_shutters_kernel SUBROUTINE
	sta WSYNC
	m_precomp_fb
	ldy mask_m0_cnt
	bne .m0_block
	jmp .mask_m1
.m0_block	dey
.m0_loop	m_one_line mask_m0_val
	dey
	bmi .mask_m1
	jmp .m0_loop

.mask_m1	ldy mask_m1_cnt
	bne .m1_block
	jmp .mask_m2
.m1_block	dey
.m1_loop	m_one_line mask_m1_val
	dey
	bmi .mask_m2
	jmp .m1_loop

.mask_m2	ldy mask_m2_cnt
	bne .m2_block
	jmp .kernend
.m2_block	dey
.m2_loop	m_one_line mask_m2_val
	dey
	bmi .kernend
	jmp .m2_loop

.kernend
	sta WSYNC
	lda #$00
	sta PF0
	sta PF1
	sta PF2
	jmp RTSBank

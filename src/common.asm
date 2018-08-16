; Copies pointer A to pointer B
; ex: m_copy_pointer src, dst
	MAC m_copy_pointer
	lda {1}
	sta {2}
	lda {1} + 1
	sta {2} + 1
	ENDM

; Add a byte to a pointer
; * 1st argument is the pointer to update
; * 2nd argument is the value to add
; ex: m_add_to_pointer ptr, #30
	MAC m_add_to_pointer
	clc
	lda {2}
	adc {1}
	sta {1}
	lda #0
	adc {1} + 1
	sta {1} + 1
	ENDM

	ORG PARTRAM
fxp_pix_base ds 2 ; Pointer towards the picture to display (base address)
fxp_line     ds 5 ; registers to compute a line's graphics
fxp_pf0_buf  ds 1 ; pf0 buffer
fxp_pf3_buf  ds 1 ; pf3 buffer
fxp_shift_i  ds 1 ; How many bytes to shift in the picture

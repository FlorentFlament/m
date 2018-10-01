	ORG PARTRAM
fxp_cnt         ds 2 ; 16-bits counter
fxp_pix_base    ds 2 ; Pointer towards the picture to display (base address)
fxp_scr_base    ds 2 ; Pointer towards the screens sequence of the pictures to display
fxp_pix_ptr     ds 2 ; pointer towards the 1st elememt of the next line to display
fxp_col_ptr     ds 2 ; Pointer towards the 1st color to use

fxp_shift_fine  ds 1 ; number of bit shifts to perform on the line in [-4, 3]

fxp_line        ds 5 ; registers to compute a line's graphics
fxp_pf0_buf     ds 1 ; pf0 buffer
fxp_pf3_buf     ds 1 ; pf3 buffer

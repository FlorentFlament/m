	ORG PARTRAM
fxps_cnt     ds 2 ; 16-bits counter
fxps_pat_ptr ds 2 ; Pointer towards the patterns table
fxps_col_ptr ds 2 ; Pointer towards the colors table
fxps_bg_col  ds 1 ; Shutters background color
fxps_fg_col  ds 1 ; Shutters foreground color
fxps_col_i   ds 1 ; Shutters color index
fxps_move_i  ds 1 ; identifies the shutter move to perform
fxps_m0_cnt  ds 1 ; How many lines to display mask m0
fxps_m0_i    ds 1 ; Index in shutters mask table

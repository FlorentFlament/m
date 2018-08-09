; Memory structures required for the shutters FX

gfx_pf_base ds 12 ; pointers towards GFX PF0 - PF5 data
fb0_base    ds 6  ; Frame buffer 0 (for 1 line i.e 6 PF registers)
fb1_base    ds 6  ; Frame buffer 1

mask_m0_val ds 6  ; Shutter mask 0 - val is the actual value to apply
mask_m1_val ds 6  ; Shutter mask 1
mask_m2_val ds 6  ; Shutter mask 2

mask_m0_cnt ds 1  ; cnt is the number of line with the corresponding mask
mask_m1_cnt ds 1
mask_m2_cnt ds 1

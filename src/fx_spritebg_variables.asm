	ORG PARTRAM
fxsb_sp_base	ds 2 ; sprites base pointer
fxsb_bg_base	ds 2 ; background base pointer
fxsb_buffer	ds 51; 51 bytes fast code buffer
fxsb_sprite_idx	ds 1 ; Sprite index
fxsb_bg_idx	ds 1 ; Background index
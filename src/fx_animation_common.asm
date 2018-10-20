	MAC m_fxa_vblank
	lda fxa_cnt
	REPEAT 4
	lsr
	REPEND
	tax
	lda fxa_{1}_timeline,X
	asl
	tax
	lda fxa_{1}_pics,X
	sta ptr
	lda fxa_{1}_pics+1,X
	sta ptr+1
	ENDM

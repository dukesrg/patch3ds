@ Credit to Steveice10, AuroraWright
.section agb.signature, "a0x7ff00000" @available custom flag mask
"00040138000002020E51"=.+0x080182A8	@0B O3DS 6.0 0x0009D2A8
@"00040138000002020A10"=.+	@0A O3DS 4.0
@"00040138000002020611"=.+	@09 O3DS ?
@"00040138000002020207"=.+	@07 O3DS 3.0
@"000401382000020212D0"=.+	@00 N3DS 8.1 0x0009DF64
.thumb
	mov	r0, #0
	add	sp, #0x138
	pop	{r4-r6,pc}

@ Credit to mid-kid
.section ctr.slot25keyx.main, "a"
"00040138000000026F60"=.	@5E O3DS 11.4
"00040138000000026B54"=.	@5C O3DS 11.3
@"00040138000000026740"=.	@58 O3DS 11.2
@"00040138000000026334"=.	@56 O3DS 11.1
"00040138000000025F30"=.	@52 O3DS 11.0
"00040138000000025B2D"=.	@50 O3DS 10.4
@"00040138000000025729"=.	@4C O3DS 10.2
@"00040138000000025328"=.	@4B O3DS 10.0
"00040138000000024F26"=.	@49 O3DS 9.6
@"00040138000000024B10"=.	@40 O3DS 9.5
@"00040138000000024706"=.	@3F O3DS 9.3
"000401380000000242E0"=.	@38 O3DS 9.0
"00040138000000023AC7"=.	@37 O3DS 8.0
"00040138000000023684"=.	@30 O3DS 7.2
@"00040138000000023274"=.	@2E O3DS 7.0
.arm
.align	4
_set_slot0x25:
	adr	r2, _slot0x25keyx
	mov	r1, #5
	mov	r0, #0x25

	ldr	r6, _aes_setkey
	orr	r6, #1
	blx	r6
	ldr	r6, _aes_unk
	orr	r6, #1
	blx	r6

	pop	{r4-r6, lr}
	bx	lr

_slot0x25keyx:
.fill	0x10
.size	_slot0x25keyx, .-_slot0x25keyx

_aes_setkey:
.word	0
.size	_aes_setkey, .-_aes_setkey

_aes_unk:
.word	0
.size	_aes_unk, .-_aes_unk

@ Credit to mid-kid
.section ctr.reboot.2, "a0x40000000"
"00040138000000026F60"=.+0x08094220	@5E O3DS 11.4
"00040138000000026B54"=.+0x080941F0	@5C O3DS 11.3
@"00040138000000026740"=.+0x	@58 O3DS 11.2
@"00040138000000026334"=.+0x	@56 O3DS 11.1
"00040138000000025F30"=.+0x080940C8	@52 O3DS 11.0
"00040138000000025B2D"=.+0x080933CC	@50 O3DS 10.4
@"00040138000000025729"=.+0x	@4C O3DS 10.2
@"00040138000000025328"=.+0x	@4B O3DS 10.0
"00040138000000024F26"=.+0x08094454	@49 O3DS 9.6
@"00040138000000024B10"=.+0x	@40 O3DS 9.5
@"00040138000000024706"=.+0x	@3F O3DS 9.3
"000401380000000242E0"=.+0x08094200	@38 O3DS 9.0
"00040138000000023AC7"=.+0x080943A4	@37 O3DS 8.0
"00040138000000023684"=.+0x080940AC	@30 O3DS 7.2
@"00040138000000023274"=.+0x	@2E O3DS 7.0
"00040138000000022E60"=.+0x08093F28	@2A O3DS 6.1
@"00040138000000022A51"=.+0x	@29 O3DS 6.0
@"00040138000000022640"=.+0x	@26 O3DS 5.1
@"00040138000000022236"=.+0x	@25 O3DS 5.0
"00040138000000021E20"=.+0x0809744C	@1F O3DS 4.1
@"00040138000000021A15"=.+0x	@1D O3DS 4.0
@"0004013800000002160F"=.+0x	@18 O3DS 3.0
@"000401380000000211F3"=.+0x	@0F O3DS 2.2
@"00040138000000020DE1"=.+0x	@0B O3DS 2.1
@"000401380000000209D4"=.+0x	@09 O3DS 2.0
@"000401380000000205C0"=.+0x	@02 O3DS 1.1
@"00040138000000020432"=.+0x	@00 O3DS 1.0
"00040138200000026F60"=.+0x08094298	@2F N3DS 11.4
"00040138200000026B54"=.+0x08094260	@2D N3DS 11.3
@"00040138200000026740"=.+0x	@28 N3DS 11.2
@"00040138200000026334"=.+0x	@26 N3DS 11.1
"00040138200000025F30"=.+0x08094134	@21 N3DS 11.0
"00040138200000025B2D"=.+0x0809343C	@1F N3DS 10.4
"00040138200000025729"=.+0x08093420	@1B N3DS 10.2
@"00040138200000025328"=.+0x	@1A N3DS 10.0
@"00040138200000024F26"=.+0x	@18 N3DS 9.6
"00040138200000024B12"=.+0x0809435C	@0F N3DS 9.5
@"00040138200000024706"=.+0x	@0C N3DS 9.3
@"000401382000000242E0"=.+0x	@04 N3DS 9.0
.arm
@ Set MPU settings
	mrc	p15, 0, r0, c2, c0, 0	@ dcacheable
	mrc	p15, 0, r12, c2, c0, 1	@ icacheable
	mrc	p15, 0, r1, c3, c0, 0	@ write bufferable
	mrc	p15, 0, r2, c5, c0, 2	@ daccess
	mrc	p15, 0, r3, c5, c0, 3	@ iaccess
	ldr	r4, =0x18000035	@ 0x18000000 128M
	bic	r2, r2, #0xF0000	@ unprotect region 4
	bic	r3, r3, #0xF0000	@ unprotect region 4
	orr	r0, r0, #0x10	@ dcacheable region 4
	orr	r2, r2, #0x30000	@ region 4 r/w
	orr	r3, r3, #0x30000	@ region 4 r/w
	orr	r12, r12, #0x10	@ icacheable region 4
	orr	r1, r1, #0x10	@ write bufferable region 4
	mcr	p15, 0, r0, c2, c0, 0
	mcr	p15, 0, r12, c2, c0, 1
	mcr	p15, 0, r1, c3, c0, 0	@ write bufferable
	mcr	p15, 0, r2, c5, c0, 2	@ daccess
	mcr	p15, 0, r3, c5, c0, 3	@ iaccess
	mcr	p15, 0, r4, c6, c4, 0	@ region 4 (hmmm)

	mrc	p15, 0, r0, c2, c0, 0	@ dcacheable
	mrc	p15, 0, r1, c2, c0, 1	@ icacheable
	mrc	p15, 0, r2, c3, c0, 0	@ write bufferable
	orr	r0, r0, #0x20	@ dcacheable region 5
	orr	r1, r1, #0x20	@ icacheable region 5
	orr	r2, r2, #0x20	@ write bufferable region 5
	mcr	p15, 0, r0, c2, c0, 0	@ dcacheable
	mcr	p15, 0, r1, c2, c0, 1	@ icacheable
	mcr	p15, 0, r2, c3, c0, 0	@ write bufferable

@ Copy the firmware
	ldr	r4, _firm_addr
	add	r5, r4, #0x40		@ Start of loop
	add	r6, r5, #0x30 * 3	@ End of loop (scan 4 entries)

copy_firm_loop:
	ldr	r0, [r5]
	cmp	r0, #0
	addne	r0, r4  @ src
	ldrne	r1, [r5, #4]	@ dest
	ldrne	r2, [r5, #8]	@ size
	blne	memcpy32

	cmp	r5, r6
	addlo	r5, #0x30
	blo	copy_firm_loop

@ Flush cache
	mov	r2, #0
	mov	r1, r2
flush_cache:
	mov	r0, #0
	mov	r3, r2, lsl #30
flush_cache_inner_loop:
	orr	r12, r3, r0, lsl#5
	mcr	p15, 0, r1, c7, c10, 4	@ drain write buffer
	mcr	p15, 0, r12, c7, c14, 2	@ clean and flush dcache entry (index and segment)
	add	r0, #1
	cmp	r0, #0x20
	bcc	flush_cache_inner_loop
	add	r2, #1
	cmp	r2, #4
	bcc	flush_cache

@ Enable MPU
	ldr	r0, =0x42078  @ alt vector select, enable itcm
	mcr	p15, 0, r0, c1, c0, 0
	mcr	p15, 0, r1, c7, c5, 0	@ flush dcache
	mcr	p15, 0, r1, c7, c6, 0	@ flush icache
	mcr	p15, 0, r1, c7, c10, 4	@ drain write buffer
	ldr	r0, _firm_addr

@ Boot FIRM
	mov	r1, #0x1FFFFFFC
	ldr	r2, [r0, #8]	@ arm11 entry
	str	r2, [r1]
	ldr	r0, [r0, #0xC]	@ arm9 entry
	bx	r0

memcpy32:	@ memcpy32(void *src, void *dst, unsigned int size)
	add	r2, r0
memcpy32_loop:
	ldmia	r0!, {r3}
	stmia	r1!, {r3}
	cmp	r0, r2
	blo	memcpy32_loop
	bx	lr

_firm_addr:
.word	0x24000000
.size	_firm_addr, .-_firm_addr

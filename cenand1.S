@ Credit to mid-kid
.section ctr.emunand.main, "a"
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
"00040138000000022E60"=.	@2A O3DS 6.1
@"00040138000000022A51"=.	@29 O3DS 6.0
@"00040138000000022640"=.	@26 O3DS 5.1
@"00040138000000022236"=.	@25 O3DS 5.0
"00040138000000021E20"=.	@1F O3DS 4.1
@"00040138000000021A15"=.	@1D O3DS 4.0
"0004013800000002160F"=.	@18 O3DS 3.0
@"000401380000000211F3"=.	@0F O3DS 2.2
@"00040138000000020DE1"=.	@0B O3DS 2.1
@"000401380000000209D4"=.	@09 O3DS 2.0
@"000401380000000205C0"=.	@02 O3DS 1.1
@"00040138000000020432"=.	@00 O3DS 1.0
"00040138200000026F60"=.	@2F N3DS 11.4
"00040138200000026B54"=.	@2D N3DS 11.3
@"00040138200000026740"=.	@28 N3DS 11.2
@"00040138200000026334"=.	@26 N3DS 11.1
"00040138200000025F30"=.	@21 N3DS 11.0
"00040138200000025B2D"=.	@1F N3DS 10.4
"00040138200000025729"=.	@1B N3DS 10.2
@"00040138200000025328"=.	@1A N3DS 10.0
@"00040138200000024F26"=.	@18 N3DS 9.6
"00040138200000024B12"=.	@0F N3DS 9.5
@"00040138200000024706"=.	@0C N3DS 9.3
@"000401382000000242E0"=.	@04 N3DS 9.0
.arm
.align	4
_nand_sd:
	@ Original code that still needs to be executed.
	mov	r4, r0
	mov	r5, r1
	mov	r7, r2
	mov	r6, r3
	@ End.

	@ If we're already trying to access the SD, return.
	ldr	r2, [r0, #4]
	ldr	r1, _sdmmc
	cmp	r2, r1
	beq	nand_sd_ret

	str	r1, [r0, #4]	@ Set object to be SD
	ldr	r2, [r0, #8]	@ Get sector to read
	cmp	r2, #0	@ For GW compatibility, see if we're trying to read the ncsd header (sector 0)

	ldr	r3, _nand_offset
	add	r2, r3	@ Add the offset to the NAND in the SD.

	ldreq	r3, _ncsd_header_offset
	addeq	r2, r3	@ If we're reading the ncsd header, add the offset of that sector.

	str	r2, [r0, #8]	@ Store sector to read

nand_sd_ret:
	@ Restore registers.
	mov	r1, r5
	mov	r2, r7
	mov	r3, r6

	@ Return 4 bytes behind where we got called,
	@ due to the offset of this function being stored there.
	mov	r0, lr
	add	r0, #4
	bx	r0

_nand_offset:
.word	0	@ The starting offset of the emuNAND on the SD.
.size	_nand_offset, .-_nand_offset

_ncsd_header_offset:
.word	0	@ The offset of the first emuNAND sector relative to the start of the emuNAND (Used for when the first sector is placed at the end).
.size	_ncsd_header_offset, .-_ncsd_header_offset

_sdmmc:
.word	0	@ The offset of the sdmmc object.
.size	_sdmmc, .-_sdmmc

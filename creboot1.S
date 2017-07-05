@ Credit to mid-kid
.section ctr.reboot.1, "a"
"00040138000000026F60"=.+0x08084B80	@5E O3DS 11.4
"00040138000000026B54"=.+0x08084B3C	@5C O3DS 11.3
@"00040138000000026740"=.+0x	@58 O3DS 11.2
@"00040138000000026334"=.+0x	@56 O3DS 11.1
"00040138000000025F30"=.+0x08084ACC	@52 O3DS 11.0
"00040138000000025B2D"=.+0x08084A10	@50 O3DS 10.4
@"00040138000000025729"=.+0x	@4C O3DS 10.2
@"00040138000000025328"=.+0x	@4B O3DS 10.0
"00040138000000024F26"=.+0x080859FC	@49 O3DS 9.6
@"00040138000000024B10"=.+0x	@40 O3DS 9.5
@"00040138000000024706"=.+0x	@3F O3DS 9.3
"000401380000000242E0"=.+0x08085914	@38 O3DS 9.0
"00040138000000023AC7"=.+0x08085894	@37 O3DS 8.0
"00040138000000023684"=.+0x080855C4	@30 O3DS 7.2
@"00040138000000023274"=.+0x	@2E O3DS 7.0
"00040138000000022E60"=.+0x08085568	@2A O3DS 6.1
@"00040138000000022A51"=.+0x	@29 O3DS 6.0
@"00040138000000022640"=.+0x	@26 O3DS 5.1
@"00040138000000022236"=.+0x	@25 O3DS 5.0
"00040138000000021E20"=.+0x08086B64	@1F O3DS 4.1
@"00040138000000021A15"=.+0x	@1D O3DS 4.0
@"0004013800000002160F"=.+0x	@18 O3DS 3.0
@"000401380000000211F3"=.+0x	@0F O3DS 2.2
@"00040138000000020DE1"=.+0x	@0B O3DS 2.1
@"000401380000000209D4"=.+0x	@09 O3DS 2.0
@"000401380000000205C0"=.+0x	@02 O3DS 1.1
@"00040138000000020432"=.+0x	@00 O3DS 1.0
"00040138200000026F60"=.+0x08084B7C	@2F N3DS 11.4
"00040138200000026B54"=.+0x08084B3C	@2D N3DS 11.3
@"00040138200000026740"=.+0x	@28 N3DS 11.2
@"00040138200000026334"=.+0x	@26 N3DS 11.1
"00040138200000025F30"=.+0x08084AC4	@21 N3DS 11.0
"00040138200000025B2D"=.+0x08084A0C	@1F N3DS 10.4
"00040138200000025729"=.+0x080849F0	@1B N3DS 10.2
@"00040138200000025328"=.+0x	@1A N3DS 10.0
@"00040138200000024F26"=.+0x	@18 N3DS 9.6
"00040138200000024B12"=.+0x08085968	@0F N3DS 9.5
@"00040138200000024706"=.+0x	@0C N3DS 9.3
@"000401382000000242E0"=.+0x	@04 N3DS 9.0
.arm
@ Interesting registers and locations to keep in mind, set before this code is ran:
@ - r1: FIRM path in exefs.
@ - r7: Reserved space for file handle
@ - *(*r7 + 0x28): fread function.

	mov	r4, r1	@ Back up the original FIRM path.

pxi_wait_recv:
	ldr	r2, =0x44846
	ldr	r0, =0x10008000
readPxiLoop1:
	ldrh	r1, [r0, #4]
	lsls	r1, #0x17
	bmi	readPxiLoop1
	ldr	r0, [r0, #0xC]
	cmp	r0, r2
	bne	pxi_wait_recv

@ Convert 2 bytes of the path string
@ This will be the method of getting the lower 2 bytes of the title ID
@ until someone bothers figuring out where the value is derived from.
	mov	r0, #0	@Result
	add	r1, r4, #0x22	@ The significant bytes
	mov	r2, #4	@ Maximum loops (amount of bytes * 2)

hex_string_to_int_loop:
	ldr	r3, [r1], #2	@ 2 because it's a utf-16 string.
	and	r3, #0xFF

@ Check if it"s a number
	cmp	r3, #'0'
	blo	hex_string_to_int_end
	sub	r3, #'0'
	cmp	r3, #9
	bls	hex_string_to_int_calc

@ Check if it"s a capital letter
	cmp	r3, #'A' - '0'
	blo	hex_string_to_int_end
	sub	r3, #'A' - '0' - 0xA	@ Make the correct value: 0xF >= al >= 0xA
	cmp	r3, #0xF
	bls	hex_string_to_int_calc

@ Incorrect value: x > "A"
	bhi	hex_string_to_int_end

hex_string_to_int_calc:
	orr	r0, r3, r0, lsl #4
	subs	r2, #1
	bne	hex_string_to_int_loop
hex_string_to_int_end:

@ Get the FIRM path
	cmp	r0, #0x0002	@ NATIVE_FIRM
	ldreq	r1, _firm_fname
	beq	check_fname

	ldr	r5, =0x0102	@ TWL_FIRM
	cmp	r0, r5
	ldreq	r1, _twl_firm_fname
	beq	check_fname

	ldr	r5, =0x0202	@ AGB_FIRM
	cmp	r0, r5
	ldreq	r1, _agb_firm_fname
	beq	check_fname

fallback:
@ Fallback: Load specified FIRM from exefs
	mov	r1, r4
	b	load_firm

check_fname:
@ Check the given string offset
	cmp	r1, #0
	beq	fallback

load_firm:
@ Open file
	add	r0, r7, #8
	mov	r2, #1
	ldr	r6, _fopen
	orr	r6, #1
	blx	r6

	cmp	r0, #0	@Check if we were able to load the FIRM
	bne	fallback	@Otherwise, try again with the FIRM from exefs.
@ This will loop indefinitely if the exefs FIRM fails to load, but whatever.

@ Read file
	mov	r0, r7
	adr	r1, bytes_read
	ldr	r2, _firm_addr
	ldr	r3, _firm_maxsize
	ldr	r6, [r7]
	ldr	r6, [r6, #0x28]
	blx	r6

@ Set kernel state
	mov	r0, #0
	mov	r1, #0
	mov	r2, #0
	mov	r3, #0
	swi	0x7C

@ Jump to reboot code
	ldr	r0, _reboot_code
	swi	0x7B

die:
	b	die

bytes_read:
.word	0

_fopen:
.word	0
.size	_fopen, .-_fopen

_reboot_code:
.word	0
.size	_reboot_code, .-_reboot_code

_firm_addr:
.word	0x24000000
.size	_firm_addr, .-_firm_addr

_firm_maxsize:
.word	0x00200000
.size	_firm_maxsize, .-_firm_maxsize

_firm_fname:
.word	0
.size	_firm_fname, .-_firm_fname

_twl_firm_fname:
.word	0
.size	_twl_firm_fname, .-_twl_firm_fname

_agb_firm_fname:
.word	0
.size	_agb_firm_fname, .-_agb_firm_fname

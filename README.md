# 3DS patches librarian
## Goals
* Unified way to distribute patches
* Provide the easy way to integrate patch functionality
* Gather all patches for all possible firmware versions
* Simplify patch definition
* Reduce number of tools needed to make patches

## Build Toolchain
Only devkitARM is required

## Patch format description
To store and distribute patches ELF format file is used. This allows to use only GNU tools provided with devkitARM to make patches. On the other hand it allows to hold all necessary patch metadata with only a small overhead in size.

Each patch is described in linker script with separate section. Section name itself is a display name and a key to access the specific patch data. Several consecutive sections may form a patch group, which must be applied together. In this case only the first section must have a meaningful name, while all dependent section names must start with a colon symbol (':'). To provide various firmware version compatibility all section addresses (VMA/LMA) must be set to zero:
```
	"Signature checks disable" 0 : { *(ctr.signature.1) }
/*	 ^^Section display name^^  ^VMA    ^internal name^	*/
	":1" 0 : { *(ctr.signature.2) }
/*	 ^dependent patch sign					*/
```
A set of local symbols is declared in each patch source file to define the patch load address for each firmware version. Symbol name is combined from title ID and title version to uniquely identify the firmware version. Since all patches uses the same set of title ID/version combinations, actual local symbols of different patches links to the same symbol names thus reducing the result ELF file.
The absence of symbol with title ID/version combination of a target firmware version states that there is no such patch compatible with this firmware version. Also up to 11 bit flags could be used to identify various patch flavours (like as ARM9/11 or static/in RAM or pattern patching or number of external parameters or whatever):
```
.section ctr.signature.1, "a0x7ff00000" @available custom flag mask
@	 ^internal name^   ^patch flags
"00040138000000026F60"=.+0x08062BF8	@5E O3DS 11.4
@^^^^title ID^^^^        ^load address
"00040138000000026B54"=.+0x08062BE4	@5C O3DS 11.3
@                ^title version
.thumb
	mov	r0, #0
```

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

### Patch code sections
Each patch is described in linker script with separate section. Section name itself is a display name and a key to access the specific patch data. Several consecutive sections may form a patch group, which must be applied together. The second and following sections whithin patch group must have custom flag SHF_3DS_DEPENDS and any unique name (using just one ending letter of existing patch names will save several bytes in the result patch file). To provide various firmware version compatibility all section addresses (VMA/LMA) must be set to zero:
```
	"Signature checks disable" 0 : { *(ctr.signature.1) }
/*	 ^^Section display name^^  ^VMA    ^internal name^	*/
	"e" 0 : { *(ctr.signature.2) }
/*	 ^dependent patch unique rubbish name			*/
```
A set of local symbols is declared in each patch source file to define the patch load address for each firmware version. Symbol name is combined from title ID and title version to uniquely identify the firmware version. Since all patches uses the same set of title ID/version combinations, actual local symbols of different patches links to the same symbol names thus reducing the result ELF file.
The absence of symbol with title ID/version combination of a target firmware version states that there is no such patch compatible with this firmware version. If patch load address is the same for all title versions, title version part of the symbol can be omitted. Zero patch address signifies that this section must be dynamically allocated.
```
.section ctr.signature.1, "a"
@	 ^internal name^   ^patch flags
"00040138000000026F60"=.+0x08062BF8	@5E O3DS 11.4
@^^^^title ID^^^^        ^load address
"00040138000000026B54"=.+0x08062BE4	@5C O3DS 11.3
@                ^title version
...
.section ctr.signature.2, "a0x40000000"
@                           ^ SHF_3DS_DEPENDS dependent patch group member section flag
"00040138000000026F60"=.+0x0805C40C	@5E O3DS 11.4
"00040138000000026B54"=.+0x0805C3F8	@5C O3DS 11.3
```

### External patch parameters
Externally settable patch parameters must be defined as labels started with underscore and also must have size defined:
```
_nand_offset:
.word	0	@ The starting offset of the emuNAND on the SD.
.size	_nand_offset, .-_nand_offset
```
Parameter values must be set with [``patchSetParameterData(...)``](https://github.com/dukesrg/patch3ds/blob/master/patch3ds.h#L23) call before requesting patch data.

### Patch variables
Patch variables are internal parameters which depends on firmware version only. It must be defined similar to external parameters, but size definition is optional and the only actual size supported is 32-bit.
```
_sdmmc:
.word	0	@ The offset of the sdmmc object.
.size	_sdmmc, .-_sdmmc @ optional size
```
Additionally actual parameter values are defined as symbols in separate section SHT_NOBITS section type:
```
.section ctr.slot25keyx._aes_setkey, "0", %nobits
"00040138000000026F60"=.+0x0805662C	@5E O3DS 11.4
"00040138000000026B54"=.+0x08056618	@5C O3DS 11.3
```
This section must be named after the parameter name and placed just after the last code section of a patch group:
```
	"_aes_setkey" 0 : { *(ctr.slot25keyx._aes_setkey) }
```
Variable values applied automatically when requesting patch data with [``patchGet(...)``](https://github.com/dukesrg/patch3ds/blob/master/patch3ds.h#L29) call.

### Special variables
Special symbols which contain additional patch metadata may be requested with [``patchGetParameter(...)``](https://github.com/dukesrg/patch3ds/blob/master/patch3ds.h#L20) call.

|Name|Description|
|---|---|
|Version|patches version (commit number)|

### Section flags
Up to 11 bit flags could be used to identify various patch flavours without breaking GNU tools compatibility or violating ELF format specification:

|Value|Name|Description|
|---|---|---|
|0x40000000|SHF_3DS_DEPENDS|Dependent patch group member section flag|
|0x20000000|||
|0x10000000|||
|0x08000000|||
|0x04000000|||
|0x02000000|||
|0x01000000|||
|0x00800000|||
|0x00400000|||
|0x00200000|||
|0x00100000|||

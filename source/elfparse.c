#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "elf.h"
#include "patch.h"

void main(int argc, char *argv[]){
	if(argc < 2) {
		printf("Usage: %s <patches.elf>\n", argv[0]);
		return;
	}
	FILE* fp = fopen(argv[1], "rb");
	fseek(fp, 0L, SEEK_END);
	size_t sz = ftell(fp);
	rewind(fp);
	uint8_t data[sz];
	fread(data, sizeof data, 1, fp);
	fclose(fp);

	Elf32_Ehdr *elfheader = (Elf32_Ehdr*)data;

        if((*(uint32_t*)&elfheader->e_ident) != *(uint32_t*)ELFMAG){
		printf("ELF magic not found!");
		return;
	}

	Elf32_Shdr *sections = (Elf32_Shdr*)(data + elfheader->e_shoff);
	uint_fast16_t sections_count = elfheader->e_shnum;
	char *section_names = (char*)(data + sections[elfheader->e_shstrndx].sh_offset);
	uint_fast16_t symbol_section = sectionFind(sections, sections_count, section_names, ".symtab");
	char *symbol_names = (char*)(data + sections[sectionFind(sections, sections_count, section_names, ".strtab")].sh_offset);
        Elf32_Sym *symbols = (Elf32_Sym*)(data + sections[symbol_section].sh_offset);

	uint32_t symbols_count = sections[symbol_section].sh_size / sizeof(*symbols);

	printf("Patches avaiable for o3DS:\n");	
	char *o3ds_patch_names[sections_count];
        memset(o3ds_patch_names, 0, sections_count * sizeof(*o3ds_patch_names));
	patchGetNames(o3ds_patch_names, symbols, symbols_count, symbol_names, sections, sections_count, section_names, 0x0004013800000002, 0xFFFF);
	patchGetNames(o3ds_patch_names, symbols, symbols_count, symbol_names, sections, sections_count, section_names, 0x0004013800000102, 0xFFFF);
	patchGetNames(o3ds_patch_names, symbols, symbols_count, symbol_names, sections, sections_count, section_names, 0x0004013800000202, 0xFFFF);
	
	for (size_t i = 0; o3ds_patch_names[i]; printf("\t%s\n", o3ds_patch_names[i++]));

	printf("Patch data from the above patch names compatible with o3DS 11.4 NATIVE_FIRM:\n");	
	patch_record o3ds_patch_data[sections_count];
        memset(o3ds_patch_data, 0, sections_count * sizeof(*o3ds_patch_data));
	patchGetData(o3ds_patch_data, o3ds_patch_names, symbols, symbols_count, symbol_names, sections, sections_count, section_names, 0x0004013800000002, 0x6F60);
	for (size_t i = 0; o3ds_patch_data[i].data; i++) {
		printf("\t%08X: ", o3ds_patch_data[i].address);
		for (size_t j = 0; j < o3ds_patch_data[i].size; printf(" %02X", *(uint8_t*)(data + (uint32_t)o3ds_patch_data[i].data + (j++))));
		printf("\n");
	}

	return;
}

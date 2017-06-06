#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "elf.h"

uint16_t sectionFind(Elf32_Shdr *sections, uint16_t count, char *section_names, char *name){
	uint16_t i = 0;
	for(i = count; i-- && strcmp(section_names + sections[i].sh_name, name););
	return i;
}

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

	Elf32_Ehdr *elfheader = (Elf32_Ehdr*)&data[0];

        if((*(uint32_t*)&elfheader->e_ident) != *(uint32_t*)ELFMAG){
		printf("ELF magic not found!");
		return;
	}

	Elf32_Shdr *sections = (Elf32_Shdr*)&data[elfheader->e_shoff];

	char *section_names = &data[sections[elfheader->e_shstrndx].sh_offset];

	uint16_t symbol_section = sectionFind(sections, elfheader->e_shnum, section_names, ".symtab");
	char *symbol_names = &data[sections[sectionFind(sections, elfheader->e_shnum, section_names, ".strtab")].sh_offset];

	char *sectionnames = &data[sections[elfheader->e_shstrndx].sh_offset];
	for(size_t i = 0; i < elfheader->e_shnum; i++){
                char *sectionname = &sectionnames[sections[i].sh_name];
		printf("Section #%d\n\tname:\t%s\n\tdata:\t", i, sectionname);
                if(*sectionname != '.')
	                for(size_t idx = 0; idx < sections[i].sh_size; idx++)
				printf("%02X ", data[sections[i].sh_offset + idx]);
		printf("\n");
	}

	printf("Symbols:\n");

	Elf32_Sym *symbolheader = (Elf32_Sym*)&data[sections[symbol_section].sh_offset];
	uint32_t symbolscount = sections[symbol_section].sh_size / sizeof(Elf32_Sym);
	for(size_t i = 0; i < symbolscount; i++)
                if(symbolheader[i].st_info == 0) //skip non-locals
			printf("%s - %s = %08X\n", &section_names[sections[symbolheader[i].st_shndx].sh_name] , &symbol_names[symbolheader[i].st_name], symbolheader[i].st_value);

	return;
}
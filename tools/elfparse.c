#include <stdio.h>
#include <stdlib.h>
#include "elf.h"

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

	Elf32_Shdr *sectionheader = (Elf32_Shdr*)&data[elfheader->e_shoff];

	for(size_t shnum = 0; shnum < elfheader->e_shnum; shnum++){
                char *name = &data[sectionheader[elfheader->e_shstrndx].sh_offset + sectionheader[shnum].sh_name];
		printf("Section #%d\n\tname:\t%s\n\tdata:\t", shnum, name);
                if(name[0] == '.')
			printf("...");
		else
	                for(size_t idx = 0; idx < sectionheader[shnum].sh_size; idx++)
				printf("%02X ", data[sectionheader[shnum].sh_offset + idx]);
		printf("\n");
	}

	return;
}
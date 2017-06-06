#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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

	uint32_t symbolssection = 0;
	uint32_t symbolnamessection = 0;
	char *sectionnames = &data[sectionheader[elfheader->e_shstrndx].sh_offset];
	for(size_t i = 0; i < elfheader->e_shnum; i++){
                char *sectionname = &sectionnames[sectionheader[i].sh_name];
		printf("Section #%d\n\tname:\t%s\n\tdata:\t", i, sectionname);
                if(*sectionname == '.'){
			printf("...");
			if(!strcmp(sectionname, ".symtab"))
				symbolssection = i;
                        else if(!strcmp(sectionname, ".strtab"))
				symbolnamessection = i;
		}else
	                for(size_t idx = 0; idx < sectionheader[i].sh_size; idx++)
				printf("%02X ", data[sectionheader[i].sh_offset + idx]);
		printf("\n");
	}

	printf("Symbols:\n");

	Elf32_Sym *symbolheader = (Elf32_Sym*)&data[sectionheader[symbolssection].sh_offset];
	uint32_t symbolscount = sectionheader[symbolssection].sh_size / sizeof(Elf32_Sym);
	char *symbolnames = &data[sectionheader[symbolnamessection].sh_offset];
	for(size_t i = 0; i < symbolscount; i++)
                if(symbolheader[i].st_info == 0) //skip non-locals
			printf("%s - %s = %08X\n", &sectionnames[sectionheader[symbolheader[i].st_shndx].sh_name] , &symbolnames[symbolheader[i].st_name], symbolheader[i].st_value);

	return;
}
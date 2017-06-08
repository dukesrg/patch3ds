#ifndef PATCH_H
#define PATCH_H

#include "elf.h"

typedef struct {
	uint32_t address;
	uint32_t size;
	void *data;
} __attribute__((packed)) patch_record;

uint16_t sectionFind(Elf32_Shdr *sections, uint_fast16_t count, char *section_names, char *name);

//get avaiable patch names for specified Title ID and Tile Version (or 0xFFFF for any version)
uint_fast16_t patchGetNames(char **patch_names, Elf32_Sym *symbols, uint16_t symbols_count, char *symbol_names, Elf32_Shdr *sections, uint_fast16_t sections_count, char *section_names, uint64_t title_id, uint_fast16_t title_version);

//get patch data record for specified patch names and Title ID and Title Version combination
uint_fast16_t patchGetData(patch_record *patch_data, char **patch_names, Elf32_Sym *symbols, uint_fast16_t symbols_count, char *symbol_names, Elf32_Shdr *sections, uint_fast16_t sections_count, char *section_names, uint64_t title_id, uint_fast16_t title_version);

#endif
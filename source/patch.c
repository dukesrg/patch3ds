#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "elf.h"

typedef struct {
	uint32_t address;
	uint32_t size;
	void *data;
} __attribute__((packed)) patch_record;

uint16_t sectionFind(Elf32_Shdr *sections, uint_fast16_t count, char *section_names, char *name) {
	uint_fast16_t i;
	for (i = count; i-- && strcmp(section_names + sections[i].sh_name, name););
	return i;
}

//get avaiable patch names for specified Title ID and Tile Version (or 0xFFFF for any version)
uint_fast16_t patchGetNames(char **patch_names, Elf32_Sym *symbols, uint16_t symbols_count, char *symbol_names, Elf32_Shdr *sections, uint_fast16_t sections_count, char *section_names, uint64_t title_id, uint_fast16_t title_version) {
	char id[22];
	uint_fast16_t name_idx = 0xFFFF;
	uint_fast8_t patch_mask[sections_count];
        memset(patch_mask, 0, sizeof(patch_mask));
	snprintf(id, title_version == 0xFFFF ? 17 : sizeof(id), "%016llX%04hX", title_id, title_version);
	while(patch_names[++name_idx]);
	for (size_t i = 0; i < symbols_count; i++)
		if (section_names[sections[symbols[i].st_shndx].sh_name] != ':' && !strncmp(symbol_names + symbols[i].st_name, id, strlen(id)))
			patch_mask[symbols[i].st_shndx] = 1;
	for (size_t  i = 0; i < sections_count; i++)
		if (patch_mask[i])
			patch_names[name_idx++] = section_names + sections[i].sh_name;
	return name_idx;
}

//get patch data record for specified patch names and Title ID and Title Version combination
uint_fast16_t patchGetData(patch_record *patch_data, char **patch_names, Elf32_Sym *symbols, uint_fast16_t symbols_count, char *symbol_names, Elf32_Shdr *sections, uint_fast16_t sections_count, char *section_names, uint64_t title_id, uint_fast16_t title_version) {
	char id[22];
	uint_fast16_t patch_idx = 0xFFFF, section_idx;
	snprintf(id, sizeof(id), "%016llX%04hX", title_id, title_version);
	while(patch_data[++patch_idx].data);
	for (size_t i = 0; patch_names[i]; i++)
		if((section_idx = sectionFind(sections, sections_count, section_names, patch_names[i])))
			do {
				for (size_t j = 0; j < symbols_count; j++)
					if (symbols[j].st_shndx == section_idx && !strcmp(symbol_names + symbols[j].st_name, id)) {
						patch_data[patch_idx].address = symbols[j].st_value;
						patch_data[patch_idx].size = sections[section_idx].sh_size;
						patch_data[patch_idx].data = (void*)sections[section_idx].sh_offset;
						patch_idx++;
						break;
					}
				section_idx++;
			} while(section_names[sections[section_idx].sh_name] == ':');
	return patch_idx;
}

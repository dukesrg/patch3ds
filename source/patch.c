#include <stdio.h>
#include <string.h>

#include "patch.h"

static Elf32_Ehdr *header;
static Elf32_Shdr *sections;
static char *section_names;
static Elf32_Sym *symbols;
static char *symbol_names;
static uint32_t symbols_count;

uint_fast16_t sectionFind(char *name) {
	uint_fast16_t i;
	for (i = header->e_shnum; i-- && strcmp(section_names + sections[i].sh_name, name););
	return i;
}

uint_fast16_t patchPreload(void *data) {
	uint_fast16_t count = 0;
	if (*(uint32_t*)data == *(uint32_t*)ELFMAG) {
		header = (Elf32_Ehdr*)data;
		sections = (Elf32_Shdr*)(data + header->e_shoff);
		section_names = (char*)(data + sections[header->e_shstrndx].sh_offset);
		for (size_t i = header->e_shnum; i--;)
			if (section_names[sections[i].sh_name] && !strspn(section_names + sections[i].sh_name, ".:"))
				count++;	
		uint_fast16_t symbol_section = sectionFind(".symtab");
        	symbols = (Elf32_Sym*)(data + sections[symbol_section].sh_offset);
		symbol_names = (char*)(data + sections[sectionFind(".strtab")].sh_offset);
		symbols_count = sections[symbol_section].sh_size / sizeof(*symbols);
	}
	return count;
}

uint_fast16_t patchFind(char **patch_names, uint_fast16_t count, uint64_t title_id, uint_fast16_t title_version) {
	char id[21];
	uint_fast8_t patch_mask[header->e_shnum];
        memset(patch_mask, 0, sizeof(patch_mask));
	snprintf(id, title_version == 0xFFFF ? 17 : sizeof(id), "%016llX%04hX", title_id, title_version);
	for (size_t i = 0; i < symbols_count; i++)
		if (section_names[sections[symbols[i].st_shndx].sh_name] != ':' && !strncmp(symbol_names + symbols[i].st_name, id, strlen(id)))
			patch_mask[symbols[i].st_shndx] = 1;
	for (size_t  i = 0; i < header->e_shnum; i++)
		if (patch_mask[i])
			patch_names[count++] = section_names + sections[i].sh_name;
	return count;
}

uint_fast16_t patchGet(patch_record *patch_data, char **patch_names, uint_fast16_t count, uint64_t title_id, uint_fast16_t title_version) {
	char id[21];
	uint_fast16_t section_idx, patch_idx = 0;
	snprintf(id, sizeof(id), "%016llX%04hX", title_id, title_version);
	for (size_t i = 0; i < count; i++)
		if((section_idx = sectionFind(patch_names[i])))
			do {
				for (size_t j = 0; j < symbols_count; j++)
					if (symbols[j].st_shndx == section_idx && !strcmp(symbol_names + symbols[j].st_name, id)) {
						patch_data[patch_idx].address = symbols[j].st_value;
						patch_data[patch_idx].size = sections[section_idx].sh_size;
						patch_data[patch_idx].data = (void*)header + sections[section_idx].sh_offset;
						patch_idx++;
						break;
					}
				section_idx++;
			} while(section_names[sections[section_idx].sh_name] == ':');
	return patch_idx;
}

#include <stdio.h>
#include <string.h>

#include "patch.h"

static Elf32_Ehdr *header;
static Elf32_Shdr *sections;
static char *section_names;
static Elf32_Sym *symbols;
static char *symbol_names;
static uint32_t symbols_count;

uint_fast8_t symbolCompare(uint32_t sidx, char* dst) {
        if (!(sidx = symbols[sidx].st_name))
		return 0;
	char *src = symbol_names + sidx;
	size_t slen = strlen(src), dlen = strlen(dst);
	return !strncmp(src, dst, slen < dlen ? slen : dlen);
}

uint_fast16_t patchPreload(void *data, section_filter filter) {
	if (*(uint32_t*)data != *(uint32_t*)ELFMAG)
		return 0;
	uint_fast16_t count = 0;
	header = (Elf32_Ehdr*)data;
	sections = (Elf32_Shdr*)(data + header->e_shoff);
	section_names = (char*)(data + sections[header->e_shstrndx].sh_offset);
	for (size_t i = header->e_shnum; --i;)
		if (!sections[i].sh_name)
			continue;
		else if (!strcmp(section_names + sections[i].sh_name, ".symtab")) {
	        	symbols = (Elf32_Sym*)(data + sections[i].sh_offset);
			symbols_count = sections[i].sh_size / sizeof(*symbols);
		} else if (!strcmp(section_names + sections[i].sh_name, ".strtab"))
			symbol_names = (char*)(data + sections[i].sh_offset);
		else if (filter == SECTION_FILTER_ALL || !strspn(section_names + sections[i].sh_name, ".:"))
			count++;
	return count;
}

uint_fast16_t patchFind(char **names, uint64_t title_id, uint_fast16_t title_version) {
	uint_fast16_t count = 0;
	char id[21];
	uint_fast8_t mask[header->e_shnum];
        memset(mask, 0, sizeof(mask));
	snprintf(id, title_version == 0xFFFF ? 17 : 21, "%016llX%04hX", title_id, title_version);
	for (size_t i = symbols_count; --i;)
		if (section_names[sections[symbols[i].st_shndx].sh_name] != ':' && symbolCompare(i, id))
			mask[symbols[i].st_shndx] = 1;
	for (size_t i = 1; i < header->e_shnum; i++)
		if (mask[i])
			names[count++] = section_names + sections[i].sh_name;
	return count;
}

uint_fast16_t patchGet(patch_record *patches, char **names, uint_fast16_t count, uint64_t title_id, uint_fast16_t title_version) {
	char id[21];
	uint_fast8_t mask[header->e_shnum];
        memset(mask, 0, sizeof(mask));
	sprintf(id, "%016llX%04hX", title_id, title_version);
	while(count--)
		for (size_t j = header->e_shnum; --j;)
 			if (!strcmp(section_names + sections[j].sh_name, names[count])) {
				for (mask[j++] = 1; j < header->e_shnum && section_names[sections[j].sh_name] == ':'; mask[j++] = 1);
				break;
			}
	for (size_t i = symbols_count; --i;)
		if (mask[symbols[i].st_shndx] && symbolCompare(i, id))
			patches[++count] = (patch_record){symbols[i].st_value, sections[symbols[i].st_shndx].sh_size, (void*)header + sections[symbols[i].st_shndx].sh_offset};
	return ++count;
}

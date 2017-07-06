#include <stdio.h>
#include <string.h>

#include "patch3ds.h"

static Elf32_Ehdr *header;
static Elf32_Shdr *sections;
static char *section_names;
static Elf32_Sym *symbols;
static char *symbol_names;
static uint32_t symbols_count;

inline static uint_fast8_t symcmp(uint32_t idx, char *value) {
	return !strcmp(symbol_names + symbols[idx].st_name, value);
}

static uint_fast8_t symcmpmin(uint32_t idx, char *value) {
	char *symbol;
	size_t s_len, v_len;
	return (symbol = symbol_names + symbols[idx].st_name) &&
		(s_len = strlen(symbol)) &&
		(v_len = strlen(value)) &&
		!strncmp(symbol, value, s_len < v_len ? s_len : v_len);
}

uint_fast16_t patchPreload(void *data) {
	if (*(uint32_t*)data != *(uint32_t*)ELFMAG)
		return 0;
	uint_fast16_t count = 0;
	header = (Elf32_Ehdr*)data;
	sections = (Elf32_Shdr*)(data + header->e_shoff);
	section_names = (char*)(data + sections[header->e_shstrndx].sh_offset);
	for (size_t i = header->e_shnum; --i;)
		if (sections[i].sh_type == SHT_SYMTAB) {
	        	symbols = (Elf32_Sym*)(data + sections[i].sh_offset);
			symbols_count = sections[i].sh_size / sizeof(*symbols);
		} else if (sections[i].sh_type == SHT_STRTAB && i != header->e_shstrndx)
			symbol_names = (char*)(data + sections[i].sh_offset);
		else if (sections[i].sh_type == SHT_PROGBITS &&
			sections[i].sh_flags & SHF_ALLOC &&
			!(sections[i].sh_flags & SHF_3DS_DEPENDS)
		) count++;
	return count;
}

uint32_t patchGetParameter(char *name) {
	for (size_t i = symbols_count; --i;)
		if ((symbols[i].st_shndx < SHN_LORESERVE || symbols[i].st_shndx == SHN_ABS) && symcmp(i, name))
			return symbols[i].st_value;
	return 0;
}

uint32_t patchSetParameterData(char *name, void *data) {
	uint32_t count = 0;
	for (size_t i = symbols_count; --i;)
		if (symbols[i].st_shndx < SHN_LORESERVE && symcmp(i, name)) {
			memcpy((void*)header + sections[symbols[i].st_shndx].sh_offset + symbols[i].st_value, data, symbols[i].st_size);
			count++;
		}
	return count;
}

uint_fast16_t patchFind(char **names, uint64_t title_id, uint_fast16_t title_version) {
	uint_fast16_t count = 0;
	char id[21];
	uint_fast8_t mask[header->e_shnum];
	uint_fast16_t secnum;
        memset(mask, 0, sizeof(mask));
	snprintf(id, title_version == PATCH_TITLE_VERSION_ANY ? 17 : 22, "%016llX%04hX", title_id, title_version);
	for (size_t i = symbols_count; --i;)
		if ((secnum = symbols[i].st_shndx) < SHN_LORESERVE &&
			sections[secnum].sh_type == SHT_PROGBITS &&
			sections[secnum].sh_flags & SHF_ALLOC &&
		    	!(sections[secnum].sh_flags & SHF_3DS_DEPENDS) &&
			symcmpmin(i, id)
		) mask[symbols[i].st_shndx] = 1;
	for (size_t i = 1; i < header->e_shnum; i++)
		if (mask[i])
			names[count++] = section_names + sections[i].sh_name;
	return count;
}

uint_fast16_t patchGet(patch_record *patches, char **names, uint_fast16_t count, uint64_t title_id, uint_fast16_t title_version) {
	char id[21];
	uint_fast8_t mask[header->e_shnum];
        memset(mask, 0, sizeof(mask));
	uint_fast8_t parammask[symbols_count];
        memset(parammask, 0, sizeof(parammask));
	sprintf(id, "%016llX%04hX", title_id, title_version);
	while(count--) //fill (sub)section usage mask by sections names
		for (size_t i = header->e_shnum; --i;)
 			if (sections[i].sh_type == SHT_PROGBITS &&
				sections[i].sh_flags & SHF_ALLOC &&
				!strcmp(section_names + sections[i].sh_name, names[count])
			) {
				size_t start_section = i;
				for (mask[i++] = 1; i < header->e_shnum && sections[i].sh_flags & SHF_3DS_DEPENDS; mask[i++] = 1);
				size_t end_section = i;
				for (;i < header->e_shnum && sections[i].sh_type == SHT_NOBITS; i++) //process variable sections
					for (size_t j = symbols_count; --j;)
						if (symbols[j].st_shndx >= start_section &&
							symbols[j].st_shndx < end_section &&
							symcmp(j, section_names + sections[i].sh_name)
						) for (size_t k = symbols_count; --k;)
							if (symbols[k].st_shndx == i && symcmpmin(k, id))
								*(uint32_t*)((void*)header + sections[symbols[j].st_shndx].sh_offset + symbols[j].st_value) = symbols[k].st_value;
				break;
			}
	for (size_t i = symbols_count; --i;)
		if (symbols[i].st_shndx < SHN_LORESERVE &&
			mask[symbols[i].st_shndx] &&
			symcmpmin(i, id)
		) patches[++count] = (patch_record){symbols[i].st_value, (void*)header + sections[symbols[i].st_shndx].sh_offset, sections[symbols[i].st_shndx].sh_size};
	return ++count;
}

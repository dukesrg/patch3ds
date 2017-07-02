#ifndef PATCH_H
#define PATCH_H

#include "elf.h"

typedef struct {
	uint32_t address;
	uint32_t size;
	void *data;
} __attribute__((packed)) patch_record;

typedef enum { //section name filter for old rx patches compatimility
	SECTION_FILTER_PATCHES = 0,
	SECTION_FILTER_ALL = 1
} section_filter;

//check elf magic and prepare data for operations, number of available patch sets returned
uint_fast16_t patchPreload(void *data, section_filter filter);

//get avaiable patch names for specified Title ID and Tile Version (or 0xFFFF for any version)
uint_fast16_t patchFind(char **names, uint64_t title_id, uint_fast16_t title_version);

//get patch data record for specified patch names and Title ID and Title Version combination
uint_fast16_t patchGet(patch_record *patches, char **names, uint_fast16_t count, uint64_t title_id, uint_fast16_t title_version);

#endif

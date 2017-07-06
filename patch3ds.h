#ifndef PATCH_H
#define PATCH_H

#include "elf.h"

#define SHF_3DS_DEPENDS	0x40000000

typedef struct {
	uint32_t address;
	void *data;
	uint32_t size;
} patch_record;

#define PATCH_TITLE_VERSION_ANY	0xFFFF

//check elf magic and prepare data for operations, number of available patch sets returned
uint_fast16_t patchPreload(void *data);

//get patch parameter value by name 
uint32_t patchGetParameter(char *name);

//set patch parameter data by name
uint32_t patchSetParameterData(char *name, void *data);

//get avaiable patch names for specified Title ID and Tile Version (or 0xFFFF for any version)
uint_fast16_t patchFind(char **names, uint64_t title_id, uint_fast16_t title_version);

//get patch data record for specified patch names and Title ID and Title Version combination
uint_fast16_t patchGet(patch_record *patches, char **names, uint_fast16_t count, uint64_t title_id, uint_fast16_t title_version);

#endif

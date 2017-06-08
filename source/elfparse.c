#include <stdio.h>

#include "elf.h"
#include "patch.h"

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

	uint_fast16_t max_patches = patchPreload(data);
        if (!max_patches) {
		printf("Invalid ELF file or no patch sections found!");
		return;
	}

	printf("Patches avaiable for o3DS:\n");	
	char *patch_names[max_patches];
	uint_fast16_t num_patches = 0;
	num_patches = patchFind(patch_names, num_patches, 0x0004013800000002, 0xFFFF);
	num_patches = patchFind(patch_names, num_patches, 0x0004013800000102, 0xFFFF);
	num_patches = patchFind(patch_names, num_patches, 0x0004013800000202, 0xFFFF);
	for (size_t i = 0; i < num_patches; printf("\t%s\n", patch_names[i++]));

	printf("Patch data from the above patch names compatible with o3DS 11.4 NATIVE_FIRM:\n");	
	patch_record patch_data[num_patches];
	uint_fast16_t num_data = patchGet(patch_data, patch_names, num_patches, 0x0004013800000002, 0x6F60);
	for (size_t i = 0; i < num_data; i++) {
		printf("\t%08X: ", patch_data[i].address);
		for (size_t j = 0; j < patch_data[i].size; printf(" %02X", *(uint8_t*)(patch_data[i].data + (j++))));
		printf("\n");
	}
}

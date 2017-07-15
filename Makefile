ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/base_rules

LD	:= arm-none-eabi-ld
OBJCOPY	:= arm-none-eabi-objcopy

export PATCH_VERSION := $(shell git rev-parse --short HEAD)

CFLAGS	:= -Os -fshort-wchar -fno-zero-initialized-in-bss

TARGET	:= patches

OBJS=$(patsubst %.S, %.o, $(wildcard *.S))

DEPSDIR=.deps

$(shell mkdir -p $(DEPSDIR))

.PHONY: all patches readpatch3ds clean

all: patches readpatch3ds

patches: $(TARGET).elf

$(TARGET).elf: $(OBJS)
	$(call Q,LINK,$@)$(LD) --use-blx -i -Tpatches.ld --no-check-sections --defsym Version=0x$(PATCH_VERSION) $^ -o $@
	$(call Q,OBJCOPY,$@)$(OBJCOPY) -S -w -K Version -K 0004* -K _* -R .data -R .text -R .bss -R .ARM.attributes $@

%.o: %.S
	$(call Q,CPPAS,$@)$(CC) -mcpu=arm946e-s $(CFLAGS) $^ -c -o $@

clean:
	@rm -rf *.o *.elf readpatch3ds readpatch3ds.exe .deps

readpatch3ds:
	$(call Q,GCC,$@)gcc patch3ds.c readpatch3ds.c -std=c99 -o readpatch3ds

ifeq ($(V),1)
Q =
else
Q = @echo '	$1	$2';
endif

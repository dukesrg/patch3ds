ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/base_rules

LD	:= arm-none-eabi-ld
OBJCOPY	:= arm-none-eabi-objcopy

CFLAGS	:= -Os -fshort-wchar -fno-zero-initialized-in-bss $(INCDIR)

BUILD	:= build
SOURCE	:= source
TARGET	:= patches

OBJS=$(patsubst $(SOURCE)/%.S, $(BUILD)/%.o, $(wildcard $(SOURCE)/*.S))

$(foreach f,$(OBJS),$(eval $f : | $(dir $f)D))

.PHONY: all patches elfparse clean

all: patches elfparse

patches: $(BUILD)/$(TARGET).elf

$(BUILD)/patches.elf: $(OBJS)
	$(call Q,LINK,$@)$(LD) --use-blx -i -Tpatches.ld --no-check-sections $^ -o $@
	$(call Q,OBJCOPY,$@)$(OBJCOPY) -S -w -K 0004* -R .data -R .text -R .bss -R .ARM.attributes $@

$(BUILD)/%.o: $(SOURCE)/%.S
	$(call Q,CPPAS,$@)$(CC) -mcpu=arm946e-s $(CFLAGS) $^ -c -o $@

clean:
	@rm -Rf build

elfparse:
	$(call Q,GCC,$@)gcc $(SOURCE)/patch.c $(SOURCE)/elfparse.c -Iinclude -std=c99 -o $(BUILD)/elfparse

%/D:
	$(call Q,MKDIR,$(dir $@))mkdir -p $(dir $@)

ifeq ($(V),1)
Q =
else
Q = @echo '	$1	$2';
endif


include common.mk

LD	:= arm-none-eabi-ld
OBJCOPY	:= arm-none-eabi-objcopy

CFLAGS	:= -Os -fshort-wchar -fno-zero-initialized-in-bss $(INCDIR)

BUILD	:= build
SOURCE	:= source
TARGET	:= patches

OBJS=$(patsubst $(SOURCE)/%.S, $(BUILD)/%.o, $(wildcard $(SOURCE)/*.S))

$(call DEPDIR,$(BUILD)/$(TARGET).elf $(OBJS))

.PHONY: all clean

all: $(BUILD)/$(TARGET).elf

$(BUILD)/patches.elf: $(OBJS)
	$(call Q,LINK,$@)$(LD) --use-blx -i -Tpatches.ld --no-check-sections $^ -o $@
	$(call Q,OBJCOPY,$@)$(OBJCOPY) -S -w -K 0004* -R .data -R .text -R .bss -R .ARM.attributes $@

$(BUILD)/%.o: $(SOURCE)/%.S
	$(call Q,CPPAS,$@)$(CC) -mcpu=arm946e-s $(CFLAGS) $^ -c -o $@

clean:
	@rm -Rf build

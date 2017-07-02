ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/base_rules

LD	:= arm-none-eabi-ld
OBJCOPY	:= arm-none-eabi-objcopy

CFLAGS	:= -Os -fshort-wchar -fno-zero-initialized-in-bss $(INCDIR)

TARGET	:= patches

OBJS=$(patsubst %.S, %.o, $(wildcard *.S))

.PHONY: all patches elfparse clean

all: patches elfparse

patches: $(TARGET).elf

$(TARGET).elf: $(OBJS)
	$(call Q,LINK,$@)$(LD) --use-blx -i -Tpatches.ld --no-check-sections $^ -o $@
	$(call Q,OBJCOPY,$@)$(OBJCOPY) -S -w -K 0004* -R .data -R .text -R .bss -R .ARM.attributes $@

%.o: %.S
	$(call Q,CPPAS,$@)$(CC) -mcpu=arm946e-s $(CFLAGS) $^ -c -o $@

clean:
	@rm -f *.o *.elf elfparse elfparse.exe

elfparse:
	$(call Q,GCC,$@)gcc patch.c elfparse.c -std=c99 -o elfparse

ifeq ($(V),1)
Q =
else
Q = @echo '	$1	$2';
endif


ifeq ($(TARGET),win32)
	SOURCES := '(\w|\-)+(\-(win32|x86))?\.c(pp)?'
endif

ifeq ($(TARGET),osx)
	SOURCES := '(\w|\-)+(\-(osx|x86))?(\.c(pp)?|\.m)'
endif

ifeq ($(TARGET),linux)
	SOURCES := '(\w|\-)+(\-(linux|x86))?\.c(pp)?'
endif

ifeq ($(TARGET),cell-ppu)
	SOURCES := '(\w|\-)+(\-(cell|ppu))?\.c(pp)?'
endif

ifeq ($(TARGET),cell-spu)
	SOURCES := '(\w|\-)+(\-(cell|spu))?\.c(pp)?'
endif

ifeq ($(TARGET),android)
	SOURCES := '(\w|\-)+(\-(android|arm))?\.c(pp)?'
endif

ifeq ($(TARGET),ios)
	SOURCES := '(\w|\-)+(\-(ios|arm))?(\.c(pp)?|\.m)'
endif

SOURCES := $(shell ls | grep -xE $(SOURCES))

OBJECTS := $(patsubst %.c, %$(EXESUF).o, $(SOURCES))
OBJECTS := $(patsubst %.cpp, %$(EXESUF).o, $(OBJECTS))

%.win32-exe.lib: AR = "$(VCINSTALLDIR)/bin/lib" /nologo
%.cell-ppu.elf.a: AR = $(SCE_PS3_ROOT)/host-win32/ppu/bin/ppu-lv2-ar
%.cell-spu.elf.a: AR = $(SCE_PS3_ROOT)/host-win32/spu/bin/spu-lv2-ar
%.android-arm.elf.a: AR = $(NDK_HOME)/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-ar

.PRECIOUS: %.exe.lib
%.exe.lib: $(OBJECTS)
	$(AR) /OUT:$@ $?

.PRECIOUS: %.macho.a
%.macho.a: $(OBJECTS)
	$(AR) -r $@ $?

.PRECIOUS: %.elf.a
%.elf.a: $(OBJECTS)
	$(AR) -r $@ $?



ifneq ($(findstring Windows,$(OS)),)
SOURCES := $(shell dir *.c *.cpp *.m 2>NUL)
else
SOURCES := $(shell echo $(TARGET) | sed -E 's/([a-z0-9]+)\-([a-z0-9]+).*/(\\w|\\-)+(\\.(\1|\2))?(\\.c(pp)?|\\.m)/')
SOURCES := $(shell ls | grep -xE '$(SOURCES)')
endif

OBJECTS := $(patsubst %.c, %$(EXESUF).o, $(SOURCES))
OBJECTS := $(patsubst %.cpp, %$(EXESUF).o, $(OBJECTS))
OBJECTS := $(patsubst %.m, %$(EXESUF).o, $(OBJECTS))

%.windows-x86.exe.lib: AR = MSYS_NO_PATHCONV=1 "$(VC_TOOLS)/lib" /nologo
%.windows-x64.exe.lib: AR = MSYS_NO_PATHCONV=1 "$(VC_TOOLS)/lib" /nologo
%.lv2-ppu.elf.a: AR = $(SCE_PS3_ROOT)/host-win32/ppu/bin/ppu-lv2-ar
%.lv2-spu.elf.a: AR = $(SCE_PS3_ROOT)/host-win32/spu/bin/spu-lv2-ar
%.android-arm.elf.a: AR = $(NDK_TOOLS)/arm-linux-androideabi-ar
%.android-x86.elf.a: AR = $(NDK_TOOLS)/i686-linux-android-ar

.PRECIOUS: %.exe.lib
%.exe.lib: $(OBJECTS)
	$(AR) /OUT:$@ $?

.PRECIOUS: %.macho.a
%.macho.a: $(OBJECTS)
	$(AR) -r $@ $?

.PRECIOUS: %.elf.a
%.elf.a: $(OBJECTS)
	$(AR) -r $@ $?

.PRECIOUS: %.exe.a
%.exe.a: $(OBJECTS)
	$(AR) -r $@ $?


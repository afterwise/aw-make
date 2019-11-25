
SOURCES := $(shell ls | grep -xE "[A-Za-z0-9_\-]+(\.$(shell echo $(TARGET) | sed -E 's/(\-\w+)$$/(\1)?/'))?\.((c(pp)?)|m)")

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


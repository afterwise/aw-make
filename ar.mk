
SOURCES := $(shell echo $(TARGET) | sed -E 's/([a-z0-9]+)\-([a-z0-9]+).*/(\\w|\\-)+(\\.(\1|\2))?(\\.c(pp)?|\\.m)/')
SOURCES := $(shell ls | grep -xE '$(SOURCES)')

OBJECTS := $(patsubst %.c, %$(EXESUF).o, $(SOURCES))
OBJECTS := $(patsubst %.cpp, %$(EXESUF).o, $(OBJECTS))

%.win32-x86.exe.lib: AR = MSYS_NO_PATHCONV=1 "$(VCINSTALLDIR)\bin\lib" /nologo
%.win32-x86_64.exe.lib: AR = MSYS_NO_PATHCONV=1 "$(VCINSTALLDIR)\bin\lib" /nologo
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



# linkers

%.win32-x86.exe: LD = "$(VCINSTALLDIR)/bin/link" /nologo
%.darwin-x86_64.macho: LD = clang
%.linux-x86.elf: LD = $(CC)
%.lv2-ppu.elf: LD = $(SCE_PS3_ROOT)/host-win32/sn/bin/ps3ppuld
%.lv2-spu.elf: LD = $(SCE_PS3_ROOT)/host-win32/spu/bin/spu-lv2-gcc
%.android-arm.elf: LD = $(NDK_TOOLS)/arm-linux-androideabi-gcc
%.ios-arm.macho: LD = clang

# linker flags

%.win32-x86.exe: LDFLAGS += /SUBSYSTEM:CONSOLE /DEBUG /NOLOGO /WX /INCREMENTAL:NO /LIBPATH:ext/windows/lib
%.win32-x86.exe: LDLIBS += user32.lib kernel32.lib \
        psapi.lib glut32.lib opengl32.lib glu32.lib xinput.lib winmm.lib \
        libOpenAL32.dll.a msvcrt.lib MSVCPRT.LIB

%.darwin-x86_64.macho: LDFLAGS += -Wl,-dead_strip -Wl,-undefined -Wl,error -Wl,-arch -Wl,x86_64
%.darwin-x86_64.macho: LDGAMELIBS += -framework IOKit -framework Cocoa -framework OpenGL -framework OpenAL
%.darwin-x86_64.macho: LDTOOLLIBS += -lc++

%.linux-x86.elf: LDFLAGS += -Wl,--gc-sections -Wl,--no-undefined -nodefaultlibs
%.linux-x86.elf: LDLIBS += -lgcc -lc -lm

%.lv2-ppu.elf: LDFLAGS += --no-exceptions --strip-unused --strip-unused-data --strip-duplicates --sn-no-dtors \
        --no-standard-libraries --use-libcs -oformat=fself -L$(SCE_PS3_ROOT)/target/ppu/lib
%.lv2-ppu.elf: LDLIBS += -lspurs_stub -lsysutil_stub -lfs_stub -lio_stub -lsync_stub -lsysmodule_stub -lm -lcs -llv2_stub

%.lv2-spu.elf: LDFLAGS += -Wl,--gc-sections -Wl,--no-undefined -Wl,-q -mspurs-job -nodefaultlibs
%.lv2-spu.elf: LDLIBS += -lm -latomic -lgcm_spu -ldma

%.android-arm.elf: LDFLAGS += --sysroot=$(NDK_SYSROOT) \
	-Wl,--fix-cortex-a8 -Wl,--no-undefined -Wl,--gc-sections -shared -Bsymbolic -nostdlib
%.android-arm.elf: LDLIBS += -lOpenSLES -lGLESv2 -llog -lm -lc

%.ios-arm.macho: LDFLAGS += -target armv7-apple-ios -mfloat-abi=softfp -isysroot $(IOS_SYSROOT)

ifeq ($(TARGET),win32)
define link-game
	$(LD) $(LDFLAGS) /OUT:$@ $(LDGAMELIBS) $(LDLIBS) $^
endef
define link-tool
	$(LD) $(LDFLAGS) /OUT:$@ $(LDTOOLLIBS) $(LDLIBS) $^
endef
else
define link-game
	$(LD) $(LDFLAGS) -o $@ $(LDGAMELIBS) $(LDLIBS) $^
endef
define link-tool
	$(LD) $(LDFLAGS) -o $@ $(LDTOOLLIBS) $(LDLIBS) $^
endef
endif


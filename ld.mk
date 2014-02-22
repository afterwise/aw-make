
# linkers

%.win32-x86.exe: LD = "$(VCINSTALLDIR)/bin/link" /nologo
%.osx-x86_64.macho: LD = clang
%.linux-x86.elf: LD = $(CC)
%.cell-ppu.elf: LD = $(SCE_PS3_ROOT)/host-win32/sn/bin/ps3ppuld
%.cell-spu.elf: LD = $(SCE_PS3_ROOT)/host-win32/spu/bin/spu-lv2-gcc
%.android-arm.elf: LD = $(NDK_HOME)/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-gcc
%.ios-arm.macho: LD = clang

# linker flags

%.win32-x86.exe: LDFLAGS += /SUBSYSTEM:CONSOLE /DEBUG /NOLOGO /WX /INCREMENTAL:NO /LIBPATH:ext/windows/lib
%.win32-x86.exe: LDLIBS += user32.lib kernel32.lib \
        psapi.lib glut32.lib opengl32.lib glu32.lib xinput.lib winmm.lib \
        libOpenAL32.dll.a msvcrt.lib MSVCPRT.LIB

%.osx-x86_64.macho: LDFLAGS += -Wl,-dead_strip -Wl,-undefined -Wl,error -Wl,-arch -Wl,$(ARCH)
%.osx-x86_64.macho: LDGAMELIBS += -framework IOKit -framework Cocoa -framework OpenGL -framework OpenAL
%.osx-x86_64.macho: LDTOOLLIBS += -lc++

%.linux-x86.elf: LDFLAGS += -Wl,--gc-sections -Wl,--no-undefined -nodefaultlibs
%.linux-x86.elf: LDLIBS += -lgcc -lc -lm

%.cell-ppu.elf: LDFLAGS += --no-exceptions --strip-unused --strip-unused-data --strip-duplicates --sn-no-dtors \
        --no-standard-libraries --use-libcs -oformat=fself -L$(SCE_PS3_ROOT)/target/ppu/lib
%.cell-ppu.elf: LDLIBS += -lspurs_stub -lsysutil_stub -lfs_stub -lio_stub -lsync_stub -lsysmodule_stub -lm -lcs -llv2_stub

%.cell-spu.elf: LDFLAGS += -Wl,--gc-sections -Wl,--no-undefined -Wl,-q -mspurs-job -nodefaultlibs
%.cell-spu.elf: LDLIBS += -lm -latomic -lgcm_spu -ldma

%.android-arm.elf: LDFLAGS += --sysroot=$(NDK_HOME)/platforms/android-9/arch-arm \
	-Wl,--fix-cortex-a8 -Wl,--no-undefined -Wl,--gc-sections -shared -Bsymbolic -nostdlib
%.android-arm.elf: LDLIBS += -lOpenSLES -lGLESv2 -llog -lm -lc

%.ios-arm.macho: LDFLAGS += -target armv7-apple-ios -mfloat-abi=softfp -isysroot $(IOS_SDK_ROOT)

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


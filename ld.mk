
# linkers

%.win32-x86.exe: LD = "$(VCINSTALLDIR)/bin/link" /nologo
%.darwin-x86.macho: LD = clang
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
        msvcrt.lib MSVCPRT.LIB

%.darwin-x86.macho: LDFLAGS += -Wl,-dead_strip -Wl,-arch -Wl,i386
%.darwin-x86_64.macho: LDFLAGS += -Wl,-dead_strip -Wl,-arch -Wl,x86_64

%.linux-x86.elf: LDFLAGS += -Wl,--gc-sections -Wl,--no-undefined -nodefaultlibs
%.linux-x86.elf: LDLIBS += -lm -lc -lgcc

%.lv2-ppu.elf: LDFLAGS += --no-exceptions --strip-unused --strip-unused-data --strip-duplicates --sn-no-dtors \
        --no-standard-libraries --use-libcs -oformat=fself -L$(SCE_PS3_ROOT)/target/ppu/lib
%.lv2-ppu.elf: LDLIBS += -lspurs_stub -lsysutil_stub -lfs_stub -lio_stub -lsync_stub -lsysmodule_stub -lm -lcs -llv2_stub

%.lv2-spu.elf: LDFLAGS += -Wl,--gc-sections -Wl,--no-undefined -Wl,-q -mspurs-job -nodefaultlibs
%.lv2-spu.elf: LDLIBS += -lm -latomic -lgcm_spu -ldma

%.android-arm.elf: LDFLAGS += --sysroot=$(NDK_SYSROOT) \
	-Wl,--fix-cortex-a8 -Wl,--no-undefined -Wl,--gc-sections -shared -Bsymbolic -nostdlib
%.android-arm.elf: LDLIBS += -llog -lm -lc -lgcc

%.ios-arm.macho: LDFLAGS += -target armv7-apple-ios -mfloat-abi=softfp -isysroot $(IOS_SYSROOT)

ifneq ($(findstring win32,$(TARGET)),)
define link
	$(LD) $(LDFLAGS) /OUT:$@ $(LDLIBS) $(LIBRARIES) $^
endef
else ifneq ($(findstring darwin,$(TARGET)),)
define link
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS) $(addprefix -framework , $(FRAMEWORKS)) $(addprefix -l, $(LIBRARIES))
endef
PLIST_ID_PREFIX ?= unknown
define link-bundle
	mkdir -p $(subst $(EXESUF),,$@).bundle/Contents/MacOS
	$(AW_MAKE_PATH)/plistgen.sh macosx bundle $(PLIST_ID_PREFIX) $(subst $(EXESUF),,$@)
	$(LD) $(LDFLAGS) -o $(subst $(EXESUF),,$@).bundle/Contents/MacOS/$(subst $(EXESUF),,$@) \
		$(addprefix -force_load , $^) $(LDLIBS) $(addprefix -framework , $(FRAMEWORKS)) \
		$(addprefix -l, $(LIBRARIES)) -bundle
	test ! -e en.lproj/InfoPlist.strings || \
		(mkdir -p $(subst $(EXESUF),,$@).bundle/Contents/Resources/en.lproj && \
		plutil -convert binary1 \
			-o $(subst $(EXESUF),,$@).bundle/Contents/Resources/en.lproj/InfoPlist.strings \
			-- en.lproj/InfoPlist.strings)
	touch $@
endef
else
define link
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS) $(addprefix -l, $(LIBRARIES))
endef
define link-bundle
	$(LD) $(LDFLAGS) -shared -o lib$@.so -Wl,--whole-archive $^ -Wl,--no-whole-archive $(LDLIBS)
endef
endif


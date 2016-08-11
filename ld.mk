
, := ,

# linkers

%.win32-x86.exe %.win32-x86.exe.dll: LD = "$(VCINSTALLDIR)/bin/link" /nologo
%.darwin-x86.macho %.darwin-x86.macho.so: LD = clang
%.darwin-x86_64.macho %.darwin-x86_64.macho.so: LD = clang
%.linux-x86.elf %.linux-x86.elf.so: LD = $(CC)
%.linux-x86_64.elf %.linux-x86_64.elf.so: LD = $(CC)
%.lv2-ppu.elf %.lv2-ppu.elf.so: LD = $(SCE_PS3_ROOT)/host-win32/sn/bin/ps3ppuld
%.lv2-spu.elf %.lv2-spu.elf.so: LD = $(SCE_PS3_ROOT)/host-win32/spu/bin/spu-lv2-gcc
%.android-arm.elf %.android-arm.elf.so: LD = $(NDK_TOOLS)/arm-linux-androideabi-gcc
%.android-x86.elf %.android-x86.elf.so: LD = $(NDK_TOOLS)/i686-linux-android-gcc
%.ios-arm.macho %.ios-arm.macho.so: LD = clang
%.ios-arm64.macho %.ios-arm.macho.so: LD = clang

# linker flags

%.win32-x86.exe %.win32-x86.exe.dll: LDFLAGS += /SUBSYSTEM:CONSOLE /DEBUG /NOLOGO /WX /INCREMENTAL:NO /LIBPATH:ext/windows/lib
%.win32-x86.exe %.win32-x86.exe.dll: LDLIBS += user32.lib kernel32.lib \
        psapi.lib glut32.lib opengl32.lib glu32.lib xinput.lib winmm.lib \
        msvcrt.lib MSVCPRT.LIB

%.darwin-x86.macho %.darwin-x86.macho.so: LDFLAGS += -flto -Wl,-dead_strip -Wl,-arch -Wl,i386
%.darwin-x86_64.macho %.darwin-x86_64.macho.so: LDFLAGS += -flto -Wl,-dead_strip -Wl,-arch -Wl,x86_64

%.linux-x86.elf %.linux-x86.elf.so: LDFLAGS += -flto -Wl,--gc-sections -Wl,--no-undefined -nodefaultlibs
%.linux-x86.elf %.linux-x86.elf.so: LDLIBS += -lm -lc -lgcc

%.linux-x86_64.elf %.linux-x86_64.elf.so: LDFLAGS += -flto -Wl,--gc-sections -Wl,--no-undefined -nodefaultlibs
%.linux-x86_64.elf %.linux-x86_64.elf.so: LDLIBS += -lm -lc -lgcc

%.lv2-ppu.elf %.lv2-ppu.elf.so: LDFLAGS += --no-exceptions --strip-unused --strip-unused-data --strip-duplicates --sn-no-dtors \
        --no-standard-libraries --use-libcs -oformat=fself -L$(SCE_PS3_ROOT)/target/ppu/lib
%.lv2-ppu.elf %.lv2-ppu.elf.so: LDLIBS += -lspurs_stub -lsysutil_stub -lfs_stub -lio_stub -lsync_stub -lsysmodule_stub -lm -lcs -llv2_stub

%.lv2-spu.elf %.lv2-spu.elf.so: LDFLAGS += -Wl,--gc-sections -Wl,--no-undefined -Wl,-q -mspurs-job -nodefaultlibs
%.lv2-spu.elf %.lv2-spu.elf.so: LDLIBS += -lm -latomic -lgcm_spu -ldma

%.android-arm.elf %.android-arm.elf.so: LDFLAGS += --sysroot=$(NDK_SYSROOT) \
	-march=armv7-a -Wl,--fix-cortex-a8 -Wl,--no-undefined -Wl,--gc-sections -Bsymbolic -nostdlib
%.android-arm.elf %.android-arm.elf.so: LDLIBS += -llog -lm -lc -lgcc

%.android-x86.elf %.android-x86.elf.so: LDFLAGS += --sysroot=$(NDK_SYSROOT) \
	-Wl,--no-undefined -Wl,--gc-sections -Bsymbolic -nostdlib
%.android-x86.elf %.android-x86.elf.so: LDLIBS += -llog -lm -lc -lgcc

%.ios-arm.macho %.ios-arm.macho.so: LDFLAGS += -target armv7-apple-ios -isysroot $(IOS_SYSROOT)
%.ios-arm64.macho %.ios-arm64.macho.so: LDFLAGS += -arch arm64 -isysroot $(IOS_SYSROOT)

ifneq ($(findstring win32,$(TARGET)),)
define link
	$(LD) $(LDFLAGS) /OUT:$@ $(LDLIBS) $(LIBRARIES) $^
endef
define link-shared
	$(LD) $(LDFLAGS) /DLL /OUT:$@ $^ $(LDLIBS)
endef
else ifneq ($(findstring darwin,$(TARGET)),)
define link
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS) $(addprefix -framework , $(FRAMEWORKS)) $(addprefix -l, $(LIBRARIES))
endef
define link-shared
	$(LD) $(LDFLAGS) -shared -o $@ $(addprefix -Wl$(,)-force_load , $<) $(filter-out $<,$^) $(LDLIBS) $(addprefix -framework , $(FRAMEWORKS)) $(addprefix -l, $(LIBRARIES))
endef
PLIST_ID_PREFIX ?= unknown
define link-bundle
	mkdir -p $(subst $(EXESUF),,$@).bundle/Contents/MacOS
	$(AW_MAKE_PATH)/plistgen.sh macosx bundle $(PLIST_ID_PREFIX) $(subst $(EXESUF),,$@)
	$(LD) $(LDFLAGS) -bundle \
		-o $(subst $(EXESUF),,$@).bundle/Contents/MacOS/$(subst $(EXESUF),,$@) \
		$(addprefix -force_load , $<) $(filter-out $<,$^) $(LDLIBS) $(addprefix -framework , $(FRAMEWORKS)) \
		$(addprefix -l, $(LIBRARIES))
	test ! -e en.lproj/InfoPlist.strings || \
		(mkdir -p $(subst $(EXESUF),,$@).bundle/Contents/Resources/en.lproj && \
		plutil -convert binary1 \
			-o $(subst $(EXESUF),,$@).bundle/Contents/Resources/en.lproj/InfoPlist.strings \
			-- en.lproj/InfoPlist.strings)
	touch $@
endef
else ifneq ($(findstring ios-,$(TARGET)),)
define link
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS) $(addprefix -framework , $(FRAMEWORKS)) $(addprefix -l, $(LIBRARIES))
endef
define link-shared
	$(LD) $(LDFLAGS) -shared -o $@ $(addprefix -Wl$(,)-force_load , $<) $(filter-out $<,$^) $(LDLIBS) $(addprefix -framework , $(FRAMEWORKS)) $(addprefix -l, $(LIBRARIES))
endef
else
define link
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS) $(addprefix -l, $(LIBRARIES))
endef
define link-shared
	$(LD) $(LDFLAGS) -shared -o $@ -Wl,--whole-archive $< -Wl,--no-whole-archive $(filter-out $<,$^) $(LDLIBS) $(addprefix -l, $(LIBRARIES))
endef
endif


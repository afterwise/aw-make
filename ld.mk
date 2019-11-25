
, := ,

# linkers

%.windows-x86.exe %.windows-x86.exe.dll: LD = MSYS_NO_PATHCONV=1 "$(VC_TOOLS)/link" /nologo
%.windows-x64.exe %.windows-x64.exe.dll: LD = MSYS_NO_PATHCONV=1 "$(VC_TOOLS)/link" /nologo
%.darwin-x86.macho %.darwin-x86.macho.so: LD = clang
%.darwin-x86_64.macho %.darwin-x86_64.macho.so: LD = clang
%.linux-x86.elf %.linux-x86.elf.so: LD = $(CC)
%.linux-x86_64.elf %.linux-x86_64.exe.so: LD = $(CC)
%.mingw-x86.exe %.mingw-x86.elf.so: LD = $(CC)
%.mingw-x86_64.exe %.mingw-x86_64.exe.so: LD = $(CC)
%.lv2-ppu.elf %.lv2-ppu.elf.so: LD = $(SCE_PS3_ROOT)/host-win32/sn/bin/ps3ppuld
%.lv2-spu.elf %.lv2-spu.elf.so: LD = $(SCE_PS3_ROOT)/host-win32/spu/bin/spu-lv2-gcc
%.android-arm.elf %.android-arm.elf.so: LD = $(NDK_TOOLS)/arm-linux-androideabi-gcc
%.android-x86.elf %.android-x86.elf.so: LD = $(NDK_TOOLS)/i686-linux-android-gcc
%.ios-arm.macho %.ios-arm.macho.so: LD = clang
%.ios-arm64.macho %.ios-arm.macho.so: LD = clang

# linker flags

%.windows-x86.exe %.windows-x86.exe.dll: LDFLAGS += /SUBSYSTEM:CONSOLE /DEBUG /WX /INCREMENTAL:NO
%.windows-x86.exe %.windows-x86.exe.dll: LDLIBS += \
	user32.lib kernel32.lib psapi.lib xinput.lib winmm.lib msvcrt.lib MSVCPRT.LIB

%.windows-x64.exe %.windows-x64.exe.dll: LDFLAGS += /SUBSYSTEM:CONSOLE /DEBUG /WX /INCREMENTAL:NO
%.windows-x64.exe %.windows-x64.exe.dll: LDLIBS += \
	user32.lib kernel32.lib psapi.lib xinput.lib winmm.lib msvcrt.lib MSVCPRT.LIB

%.darwin-x86.macho %.darwin-x86.macho.so: LDFLAGS += -flto -Wl,-dead_strip -Wl,-arch -Wl,i386
%.darwin-x86_64.macho %.darwin-x86_64.macho.so: LDFLAGS += -flto -Wl,-dead_strip -Wl,-arch -Wl,x86_64

%.linux-x86.elf %.linux-x86.elf.so: LDFLAGS += -flto -Wl,--gc-sections -Wl,--no-undefined -nodefaultlibs
%.linux-x86.elf %.linux-x86.elf.so: LDLIBS += -lm -lc -lgcc

%.linux-x86_64.elf %.linux-x86_64.elf.so: LDFLAGS += -flto -Wl,--gc-sections -Wl,--no-undefined -nodefaultlibs
%.linux-x86_64.elf %.linux-x86_64.elf.so: LDLIBS += -lm -lc -lgcc

%.mingw-x86.exe %.mingw-x86.exe.so: LDFLAGS += -flto -Wl,--gc-sections -Wl,--no-undefined -nodefaultlibs
%.mingw-x86.exe %.mingw-x86.exe.so: LDLIBS += -lm -lc -lgcc

%.lv2-ppu.elf %.lv2-ppu.elf.so: LDFLAGS += --no-exceptions --strip-unused --strip-unused-data --strip-duplicates --sn-no-dtors \
	--no-standard-libraries --use-libcs -oformat=fself -L$(SCE_PS3_ROOT)/target/ppu/lib
%.lv2-ppu.elf %.lv2-ppu.elf.so: LDLIBS += -lspurs_stub -lsysutil_stub -lfs_stub -lio_stub -lsync_stub -lsysmodule_stub -lm -lcs -llv2_stub

%.lv2-spu.elf %.lv2-spu.elf.so: LDFLAGS += -Wl,--gc-sections -Wl,--no-undefined -Wl,-q -mspurs-job -nodefaultlibs
%.lv2-spu.elf %.lv2-spu.elf.so: LDLIBS += -lm -latomic -lgcm_spu -ldma

%.android-arm.elf %.android-arm.elf.so: LDFLAGS += --sysroot=$(NDK_SYSROOT) \
	-fstack-protector -fpic -march=armv7-a -Wl,--fix-cortex-a8 \
	-Wl,--no-undefined -Wl,--gc-sections -Bsymbolic -nostdlib
%.android-arm.elf %.android-arm.elf.so: LDLIBS += -llog -lm -lc -lgcc

%.android-x86.elf %.android-x86.elf.so: LDFLAGS += --sysroot=$(NDK_SYSROOT) \
	-mstackrealign -fpic -Wl,--no-undefined -Wl,--gc-sections -Bsymbolic -nostdlib
%.android-x86.elf %.android-x86.elf.so: LDLIBS += -llog -lm -lc -lgcc

%.ios-arm.macho %.ios-arm.macho.so: LDFLAGS += -target armv7-apple-ios -isysroot $(IOS_SYSROOT)
%.ios-arm64.macho %.ios-arm64.macho.so: LDFLAGS += -arch arm64 -isysroot $(IOS_SYSROOT)

# link windows

ifneq ($(findstring Windows,$(OS)),)
define link
	$(LD) $(LDFLAGS) /OUT:$@ $^ $(LIBRARIES) $(LDLIBS)
endef
define link-shared
	$(LD) $(LDFLAGS) /DLL /OUT:$@ $(patsubst %$(LIBSUF), /WHOLEARCHIVE:%$(LIBSUF), $^) $(LDLIBS)
endef

# link darwin

else ifneq ($(findstring darwin,$(TARGET)),)
define link
	$(LD) $(LDFLAGS) -o $@ $^ $(addprefix -framework , $(FRAMEWORKS)) $(addprefix -l, $(LIBRARIES)) $(LDLIBS)
endef
define link-shared
	$(LD) $(LDFLAGS) -shared -o $@ $(addprefix -Wl$(,)-force_load , $<) $(filter-out $<,$^) $(addprefix -framework , $(FRAMEWORKS)) $(addprefix -l, $(LIBRARIES)) $(LDLIBS)
endef
define link-bundle
	mkdir -p $(subst $(EXESUF),,$@).bundle/Contents/MacOS
	$(AW_MAKE_PATH)/plistgen.sh macosx bundle $(BUNDLE_PREFIX) $(subst $(EXESUF),,$@)
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

# link android

else ifneq ($(findstring android-,$(TARGET)),)
define link
	$(LD) $(LDFLAGS) -o $@ $^ $(addprefix -l, $(LIBRARIES)) $(LDLIBS)
endef
define link-shared
	$(LD) $(LDFLAGS) -shared -o $@ -Wl,--whole-archive $< -Wl,--no-whole-archive $(filter-out $<,$^) $(addprefix -l, $(LIBRARIES)) $(LDLIBS)
endef
define create-apk-lib1 =
	mkdir -p .$(1)/libs/$(3) && cd .$(1)/libs/$(3) && ln -s ../../../$(2)
endef
ifeq ($(subst android-,,$(TARGET)),arm)
define create-apk-lib =
	$(call create-apk-lib1,$(1),$(2),armeabi-v7a)
endef
else ifeq ($(subst android-,,$(TARGET)),arm64)
define create-apk-lib =
	$(call create-apk-lib1,$(1),$(2),arm64-v8a)
endef
else ifeq ($(subst android-,,$(TARGET)),x86)
define create-apk-lib =
	$(call create-apk-lib1,$(1),$(2),x86)
endef
else ifeq ($(subst android-,,$(TARGET)),x86_64)
define create-apk-lib =
	$(call create-apk-lib1,$(1),$(2),x86_64)
endef
endif
define create-apk
	$(call create-apk-lib,$@,$<)
	$(AW_MAKE_PATH)/androidgen.sh .$@ $(SDK_VERSION) $(BUNDLE_PREFIX) \
		$(subst $(EXESUF)$(SOSUF).apk,,$@) $(subst lib,,$(subst $(SOSUF),,$<))
	winpty $(SDK_HOME)/tools/android.bat update project -p .$@ \
		-t android-$(SDK_VERSION) -n $(subst $(EXESUF)$(SOSUF).apk,,$@)
	cd .$@ && JAVA_HOME=`cygpath -m $(JAVA_HOME)` winpty ant.bat debug
endef

# link ios

else ifneq ($(findstring ios-,$(TARGET)),)
define link
	$(LD) $(LDFLAGS) -o $@ $^ $(addprefix -framework , $(FRAMEWORKS)) $(addprefix -l, $(LIBRARIES)) $(LDLIBS)
endef
define link-shared
	$(LD) $(LDFLAGS) -shared -o $@ $(addprefix -Wl$(,)-force_load , $<) $(filter-out $<,$^) $(addprefix -framework , $(FRAMEWORKS)) $(addprefix -l, $(LIBRARIES)) $(LDLIBS)
endef

# link default

else
define link
	$(LD) $(LDFLAGS) -o $@ $^ $(addprefix -l, $(LIBRARIES)) $(LDLIBS)
endef
define link-shared
	$(LD) $(LDFLAGS) -shared -o $@ -Wl,--whole-archive $< -Wl,--no-whole-archive $(filter-out $<,$^) $(addprefix -l, $(LIBRARIES)) $(LDLIBS)
endef
endif


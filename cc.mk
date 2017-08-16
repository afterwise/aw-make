
# compilers

%.win32-x86.exe.o: CC = "$(VCINSTALLDIR)/bin/cl" /nologo
%.darwin-x86.macho.o: CC = clang
%.darwin-x86_64.macho.o: CC = clang
%.lv2-ppu.elf.o: CC = $(SCE_PS3_ROOT)/host-win32/sn/bin/ps3ppusnc
%.lv2-spu.elf.o: CC = $(SCE_PS3_ROOT)/host-win32/spu/bin/spu-lv2-gcc
%.android-arm.elf.o: CC = $(NDK_TOOLS)/arm-linux-androideabi-gcc
%.android-x86.elf.o: CC = $(NDK_TOOLS)/i686-linux-android-gcc
%.ios-arm.macho.o: CC = clang
%.ios-arm64.macho.o: CC = clang

# compiler flags

%.win32-x86.exe.o: CFLAGS := /WL /TP /Y- /Zl /MD /EHs-c- \
	/GR- /GF /Gm- /GL- /fp:fast /arch:SSE2 /DWIN32_LEAN_AND_MEAN $(CFLAGS)

%.darwin-x86.macho.o: CFLAGS := -Wall -Wextra -Werror -Wshadow -Wno-missing-field-initializers \
	-arch i386 -msse2 -ffast-math -fstrict-aliasing -fstrict-overflow -flto $(CFLAGS)

%.darwin-x86_64.macho.o: CFLAGS := -Wall -Wextra -Werror -Wshadow -Wno-missing-field-initializers \
	-arch x86_64 -msse2 -ffast-math -fstrict-aliasing -fstrict-overflow -flto $(CFLAGS)

%.linux-x86.elf.o: CFLAGS := -Wall -Wextra -Werror -Wshadow -Wno-missing-field-initializers \
	-msse2 -ffast-math -fstrict-aliasing -fstrict-overflow -ffunction-sections -fdata-sections $(CFLAGS)

%.linux-x86_64.elf.o: CFLAGS := -Wall -Wextra -Werror -Wshadow -Wno-missing-field-initializers \
	-msse2 -ffast-math -fstrict-aliasing -fstrict-overflow -ffunction-sections -fdata-sections $(CFLAGS)

%.mingw-x86.exe.o: CFLAGS := -Wall -Wextra -Werror -Wshadow -Wno-missing-field-initializers \
	-msse2 -ffast-math -fstrict-aliasing -fstrict-overflow -ffunction-sections -fdata-sections $(CFLAGS)

%.lv2-ppu.elf.o: CFLAGS := -Xdiag=2 -Xquit=1 -Xfastlibc \
        -I$(SCE_PS3_ROOT)/target/common/include -I$(SCE_PS3_ROOT)/target/ppu/include \
        -I$(SCE_PS3_ROOT)/target/ppu/include/vectormath/c $(CFLAGS)

%.lv2-spu.elf.o: CFLAGS := -Wall -Wextra -Werror -Wshadow -Wno-missing-field-initializers \
	-ffast-math -fstrict-aliasing -fstrict-overflow -ffunction-sections -fdata-sections -fpic \
	-I$(SCE_PS3_ROOT)/target/common/include -I$(SCE_PS3_ROOT)/target/spu/include \
	-I$(SCE_PS3_ROOT)/target/spu/include/vectormath/c $(CFLAGS)

%.android-arm.elf.o: CFLAGS := -Wall -Wextra -Werror -Wshadow -Wno-missing-field-initializers \
	-ffast-math -fstrict-aliasing -fstrict-overflow -ffunction-sections -fdata-sections \
	-fstack-protector -fno-short-enums -fpic \
	-march=armv7-a -mthumb -mfpu=neon -mfloat-abi=softfp \
	--sysroot=$(NDK_SYSROOT) $(CFLAGS)

%.android-x86.elf.o: CFLAGS := -Wall -Wextra -Werror -Wshadow -Wno-missing-field-initializers \
	-msse2 -ffast-math -fstrict-aliasing -fstrict-overflow -ffunction-sections -fdata-sections \
	-fstack-protector -fno-short-enums -fpic \
	--sysroot=$(NDK_SYSROOT) $(CFLAGS)

%.ios-arm.macho.o: CFLAGS := -Wall -Wextra -Werror -Wshadow -Wno-missing-field-initializers \
	-ffast-math -fstrict-aliasing -fstrict-overflow \
	-target armv7-apple-ios -mfpu=neon -mfloat-abi=softfp \
	-isysroot $(IOS_SYSROOT) $(CFLAGS)

%.ios-arm64.macho.o: CFLAGS := -Wall -Wextra -Werror -Wshadow -Wno-missing-field-initializers \
	-ffast-math -fstrict-aliasing -fstrict-overflow \
	-arch arm64 -isysroot $(IOS_SYSROOT) $(CFLAGS)

# common compile rules

ifdef NODEPS
define make-deps
endef
else
define make-deps
$(CC) $(CFLAGS) $(addprefix -I, $(INCLUDES)) -c $< -MM > $*$(EXESUF).dep
mv -f $*$(EXESUF).dep $*$(EXESUF).dep.tmp
sed -e 's|.*:|$*$(EXESUF).o:|' < $*$(EXESUF).dep.tmp > $*$(EXESUF).dep
sed -e 's/.*://' -e 's/\\$$//' < $*$(EXESUF).dep.tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $*$(EXESUF).dep
rm -f $*$(EXESUF).dep.tmp
endef
endif

-include $(shell find . -name "*$(EXESUF).dep")

ifneq ($(REQUIRES),)
%$(EXESUF).o: INCLUDES += $(REQUIRES)

.PRECIOUS: $(REQUIRES)
$(REQUIRES):
	$(MAKE) -f $(AW_MAKE_FILE) -C $(shell echo $@ | grep -Eo '^[^\/\\]+') $(shell echo $@ | sed -E 's/^[^\/\\]+[\/\\]//')
endif

ifneq ($(findstring win32,$(TARGET)),)
.PRECIOUS: %$(EXESUF).o
%$(EXESUF).o: %.c* | $(REQUIRES)
	$(CC) $(CFLAGS) $(addprefix /I, $(INCLUDES)) $(addprefix /D, $(DEFINES)) /Fo$@ /c $<
else
.PRECIOUS: %$(EXESUF).o
%$(EXESUF).o: %.c* | $(REQUIRES)
	@$(make-deps)
	$(CC) $(CFLAGS) $(addprefix -I, $(INCLUDES)) $(addprefix -D, $(DEFINES)) -o $@ -c $<
endif


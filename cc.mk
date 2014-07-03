
# compilers

%.win32-x86.exe.o: CC = "$(VCINSTALLDIR)/bin/cl" /nologo
%.darwin-x86.macho.o: CC = clang
%.darwin-x86_64.macho.o: CC = clang
%.lv2-ppu.elf.o: CC = $(SCE_PS3_ROOT)/host-win32/sn/bin/ps3ppusnc
%.lv2-spu.elf.o: CC = $(SCE_PS3_ROOT)/host-win32/spu/bin/spu-lv2-gcc
%.android-arm.elf.o: CC = $(NDK_TOOLS)/arm-linux-androideabi-gcc
%.ios-arm.macho.o: CC = clang

# compiler flags

%.win32-x86.exe.o: CFLAGS += /WL /TP /Y- /Zl /MD /EHs-c- \
	/GR- /GF /Gm- /GL- /fp:fast /arch:SSE2 /DWIN32_LEAN_AND_MEAN

%.darwin-x86.macho.o: CFLAGS += -Wall -Wextra -Werror \
	-arch i386 -msse2 -fstrict-aliasing

%.darwin-x86_64.macho.o: CFLAGS += -Wall -Wextra -Werror \
	-arch x86_64 -msse2 -fstrict-aliasing

%.linux-x86.elf.o: CFLAGS += -Wall -Wextra -Werror \
	-msse2 -fstrict-aliasing -ffunction-sections -fdata-sections

%.lv2-ppu.elf.o: CFLAGS += -Xdiag=2 -Xquit=1 -Xfastlibc \
        -I$(SCE_PS3_ROOT)/target/common/include -I$(SCE_PS3_ROOT)/target/ppu/include \
        -I$(SCE_PS3_ROOT)/target/ppu/include/vectormath/c

%.lv2-spu.elf.o: CFLAGS += -Wall -Wextra -Werror -ffunction-sections -fdata-sections -fpic \
	-I$(SCE_PS3_ROOT)/target/common/include -I$(SCE_PS3_ROOT)/target/spu/include \
	-I$(SCE_PS3_ROOT)/target/spu/include/vectormath/c

%.android-arm.elf.o: CFLAGS += -Wall -Wextra -Werror -ffunction-sections -fdata-sections \
	-funwind-tables -fstack-protector -fno-short-enums -fpic \
	-march=armv7-a -mthumb-interwork -mfpu=neon -mfloat-abi=softfp \
	-D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ -DANDROID=1 \
	--sysroot=$(NDK_SYSROOT)

%.ios-arm.macho.o: CFLAGS += -Wall -Wextra -Werror \
	-target armv7-apple-ios -mfpu=neon -mfloat-abi=softfp \
	-isysroot $(IOS_SYSROOT)

# common compile rules

define make-deps
$(CC) $(CFLAGS) $(addprefix -I, $(INCLUDES)) -c $< -MM > $*$(EXESUF).dep
mv -f $*$(EXESUF).dep $*$(EXESUF).dep.tmp
sed -e 's|.*:|$*$(EXESUF).o:|' < $*$(EXESUF).dep.tmp > $*$(EXESUF).dep
sed -e 's/.*://' -e 's/\\$$//' < $*$(EXESUF).dep.tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $*$(EXESUF).dep
rm -f $*$(EXESUF).dep.tmp
endef

-include $(shell find . -name "*$(EXESUF).dep")

ifneq ($(REQUIRES),)
%$(EXESUF).o: INCLUDES += $(REQUIRES)

.PRECIOUS: $(REQUIRES)
$(REQUIRES):
	$(MAKE) -C $(shell echo $@ | grep -Eo '^[^\/\\]+') $(shell echo $@ | sed -E 's/^[^\/\\]+[\/\\]//')
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


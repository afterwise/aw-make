
export HOST := $(shell uname -s)
export HOST_ARCH := $(shell uname -m)

ifneq ($(findstring CYGWIN,$(HOST)),)
	export HOST := win32-$(HOST_ARCH)
	export TARGET ?= $(HOST)
	export HOSTEXESUF := .$(HOST).exe
	export EXESUF := .$(HOST).exe
	export LIBSUF := .lib
endif

ifeq ($(HOST),Darwin)
	export HOST := darwin-$(HOST_ARCH)
	export TARGET ?= $(HOST)
	export HOSTEXESUF := .$(HOST).macho
	export EXESUF := .$(HOST).macho
	export LIBSUF := .a
endif

ifeq ($(HOST),Linux)
	export HOST := linux-$(HOST_ARCH)
	export TARGET ?= $(HOST)
	export HOSTEXESUF := .$(HOST).elf
	export EXESUF := .$(HOST).elf
	export LIBSUF := .a
endif

ifeq ($(TARGET),lv2-ppu)
	export EXESUF := .$(TARGET).elf
	export LIBSUF := .a
endif

ifeq ($(TARGET),lv2-spu)
	export EXESUF := .$(TARGET).elf
	export LIBSUF := .a
endif

ifeq ($(TARGET),android-arm)
	export EXESUF := .$(TARGET).elf
	export LIBSUF := .a

	export NDK_HOME ?= /usr/local/android
	export NDK_SYSROOT := $(NDK_HOME)/platforms/$(shell ls $(NDK_HOME)/platforms | sort -nrk1.9 | head -1)/arch-arm
	export NDK_TOOLS := $(shell ls -d $(NDK_HOME)/toolchains/arm-linux-androideabi-* | grep -v clang | sort -nr | head -1)/prebuilt/$(HOST)/bin
endif

ifeq ($(TARGET),ios-arm)
	export EXESUF := .$(TARGET).macho
	export LIBSUF := .a

	export IOS_HOME := $(shell xcrun --sdk iphoneos --show-sdk-platform-path)
	export IOS_SYSROOT := $(shell xcrun --sdk iphoneos --show-sdk-path)
endif


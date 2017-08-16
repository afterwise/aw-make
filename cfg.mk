
export HOST := $(shell uname -s)
export HOST_ARCH := $(shell uname -m)

ifneq ($(findstring CYGWIN,$(HOST)),)
	export HOST := win32-$(HOST_ARCH)
	export TARGET ?= $(HOST)
	export HOSTEXESUF := .$(HOST).exe
	export EXESUF := .$(TARGET).exe
	export LIBSUF := .lib
	export SOSUF := .dll
endif

ifneq ($(findstring MINGW,$(HOST)),)
	export HOST := mingw-$(HOST_ARCH)
	export TARGET ?= $(HOST)
	export HOSTEXESUF := .$(HOST).exe
	export EXESUF := .$(TARGET).exe
	export LIBSUF := .a
	export SOSUF := .so
endif

ifeq ($(HOST),Darwin)
	export HOST := darwin-$(HOST_ARCH)
	export TARGET ?= $(HOST)
	export HOSTEXESUF := .$(HOST).macho
	export EXESUF := .$(TARGET).macho
	export LIBSUF := .a
	export SOSUF := .so
endif

ifeq ($(HOST),Linux)
	export HOST := linux-$(HOST_ARCH)
	export TARGET ?= $(HOST)
	export HOSTEXESUF := .$(HOST).elf
	export EXESUF := .$(TARGET).elf
	export LIBSUF := .a
	export SOSUF := .so
endif

ifeq ($(TARGET),lv2-ppu)
	export EXESUF := .$(TARGET).elf
	export LIBSUF := .a
	export SOSUF := .so
endif

ifeq ($(TARGET),lv2-spu)
	export EXESUF := .$(TARGET).elf
	export LIBSUF := .a
	export SOSUF := .so
endif

ifeq ($(TARGET),android-arm)
	export EXESUF := .$(TARGET).elf
	export LIBSUF := .a
	export SOSUF := .so

	export NDK_HOME ?= /usr/local/android
	export NDK_SYSROOT := $(NDK_HOME)/platforms/$(shell ls $(NDK_HOME)/platforms | sort -nrk1.9 | head -1)/arch-arm
	export NDK_TOOLS := $(shell ls -d $(NDK_HOME)/toolchains/arm-linux-androideabi-* | grep -v clang | sort -nr | head -1)/prebuilt/$(HOST)/bin
endif

ifeq ($(TARGET),android-x86)
	export EXESUF := .$(TARGET).elf
	export LIBSUF := .a
	export SOSUF := .so

	export NDK_HOME ?= /usr/local/android
	export NDK_SYSROOT := $(NDK_HOME)/platforms/$(shell ls $(NDK_HOME)/platforms | sort -nrk1.9 | head -1)/arch-x86
	export NDK_TOOLS := $(shell ls -d $(NDK_HOME)/toolchains/x86-* | grep -v clang | sort -nr | head -1)/prebuilt/$(HOST)/bin
endif

ifneq ($(findstring ios-,$(TARGET)),)
	export EXESUF := .$(TARGET).macho
	export LIBSUF := .a
	export SOSUF := .so

	export IOS_HOME := $(shell xcrun --sdk iphoneos --show-sdk-platform-path)
	export IOS_SYSROOT := $(shell xcrun --sdk iphoneos --show-sdk-path)
endif



export HOST := $(shell uname -s)
export ARCH := $(shell uname -m)

ifneq ($(findstring CYGWIN,$(HOST)),)
	export HOSTEXESUF := .win32-$(ARCH).exe
	export EXESUF := .win32-$(ARCH).exe
	export LIBSUF := .lib
	export TARGET ?= win32
endif

ifeq ($(HOST),Darwin)
	export HOSTEXESUF := .osx-$(ARCH).macho
	export EXESUF := .osx-$(ARCH).macho
	export LIBSUF := .a
	export TARGET ?= osx
endif

ifeq ($(HOST),Linux)
	export HOSTEXESUF := .linux-$(ARCH).elf
	export EXESUF := .linux-$(ARCH).elf
	export LIBSUF := .a
	export TARGET ?= linux
endif

ifeq ($(TARGET),cell-ppu)
	export EXESUF := .cell-ppu.elf
	export LIBSUF := .a
endif

ifeq ($(TARGET),cell-spu)
	export EXESUF := .cell-spu.elf
	export LIBSUF := .a
endif

ifeq ($(TARGET),android)
	export EXESUF := .android-arm.elf
	export LIBSUF := .a

	export NDK_HOME ?= /usr/local/android
	export NDK_SDK_ROOT := $(shell ls $(NDK_HOME)/android-sdk-macosx/platforms | sort -nrk1.8 | head -1)
endif

ifeq ($(TARGET),ios)
	export EXESUF := .ios-arm.macho
	export LIBSUF := .a

	export IOS_HOME := /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform
	export IOS_SDK_ROOT := $(IOS_HOME)/Developer/SDKs/$(shell ls $(IOS_HOME)/Developer/SDKs | sort -nrk1.9 | head -1)
endif


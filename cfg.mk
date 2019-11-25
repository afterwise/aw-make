
ifneq ($(findstring Windows,$(OS)),)
export HOST := $(OS)
export HOST_ARCH := $(Platform)
else
export HOST := $(shell uname -s)
export HOST_ARCH := $(shell uname -m)
endif

ifeq ($(HOST),Windows_NT)
ifeq ($(VCToolsInstallDir),)
$(error VCToolsInstallDir is not set)
endif
	export HOST := windows-$(HOST_ARCH)
	export TARGET ?= $(HOST)
	export HOSTEXESUF := .$(HOST).exe
	export EXESUF := .$(TARGET).exe
	export LIBSUF := .lib
	export SOSUF := .dll

	export VC_TOOLS := $(VCToolsInstallDir)bin/Host$(Platform)/$(Platform)
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
ifeq ($(SDK_HOME),)
$(error SDK_HOME is not set)
endif
ifeq ($(NDK_HOME),)
$(error NDK_HOME is not set)
endif
	export EXESUF := .$(TARGET).elf
	export LIBSUF := .a
	export SOSUF := .so

	export SDK_VERSION ?= 23
# $(shell ls $(SDK_HOME)/platforms | sort -nrk1.9 | head -1 | grep -oE '[0-9]+')
	export NDK_VERSION ?= 23
# $(shell ls $(NDK_HOME)/platforms | sort -nrk1.9 | head -1 | grep -oE '[0-9]+')
	export NDK_SYSROOT := $(NDK_HOME)/platforms/android-$(NDK_VERSION)/arch-arm
	export NDK_TOOLS := $(shell ls -d $(NDK_HOME)/toolchains/arm-linux-androideabi-* | grep -v clang | sort -nr | head -1)/prebuilt/$(HOST)/bin
endif

ifeq ($(TARGET),android-x86)
ifeq ($(SDK_HOME),)
$(error SDK_HOME is not set)
endif
ifeq ($(NDK_HOME),)
$(error NDK_HOME is not set)
endif
	export EXESUF := .$(TARGET).elf
	export LIBSUF := .a
	export SOSUF := .so

	export SDK_VERSION ?= 23
# $(shell ls $(SDK_HOME)/platforms | sort -nrk1.9 | head -1 | grep -oE '[0-9]+')
	export NDK_VERSION ?= 23
# $(shell ls $(NDK_HOME)/platforms | sort -nrk1.9 | head -1 | grep -oE '[0-9]+')
	export NDK_SYSROOT := $(NDK_HOME)/platforms/android-$(NDK_VERSION)/arch-x86
	export NDK_TOOLS := $(shell ls -d $(NDK_HOME)/toolchains/x86-* | grep -v clang | sort -nr | head -1)/prebuilt/$(HOST)/bin
endif

ifneq ($(findstring ios-,$(TARGET)),)
	export EXESUF := .$(TARGET).macho
	export LIBSUF := .a
	export SOSUF := .so

	export IOS_HOME := $(shell xcrun --sdk iphoneos --show-sdk-platform-path)
	export IOS_SYSROOT := $(shell xcrun --sdk iphoneos --show-sdk-path)
endif



export HOST := $(OS)-$(PROCESSOR_ARCHITECTURE)
export TARGET ?= $(HOST)
export HOSTEXESUF := .$(HOST).exe
export EXESUF := .$(TARGET).exe
export LIBSUF := .lib
export SOSUF := .dll


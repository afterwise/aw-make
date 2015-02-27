
export AW_MAKE_PATH ?= $(shell pwd)/aw-make
export PLIST_ID_PREFIX ?= se.afterwi

include $(AW_MAKE_PATH)/cfg.mk
include $(AW_MAKE_PATH)/ld.mk

.PHONY: $(wildcard *.mk)
-include $(wildcard *.mk)

.PHONY: all
all: $(addsuffix $(EXESUF), $(PROGRAMS))

.PRECIOUS: extern/%
extern/%: recurse
	test -d extern || mkdir extern
	$(MAKE) -f $(AW_MAKE_PATH)/ext.mk -C extern $(subst extern/,,$@)

.PRECIOUS: %$(LIBSUF)
%$(LIBSUF): recurse
	$(MAKE) -C $(@D) `test -e $(@D)/requires.mk && echo -f requires.mk` \
		-f $(AW_MAKE_PATH)/cc.mk -f $(AW_MAKE_PATH)/ar.mk \
		$(subst $(@D)/,,$@)

ifneq ($(findstring darwin, $(TARGET)),)
RM_PROGRAM_BUNDLES = $(RM) -r $(addsuffix .bundle, $(PROGRAMS))
else
RM_PROGRAM_BUNDLES = $(RM) $(PROGRAMS:%=lib%$(EXESUF).so)
endif

.PHONY: clean
clean:
	test -d extern && $(MAKE) -f $(AW_MAKE_PATH)/ext.mk -C extern clean
	for dir in $(patsubst %.mk,%,$(wildcard *.mk)); do $(MAKE) -C $$dir -f $(AW_MAKE_PATH)/rm.mk clean; done
	$(RM) $(addsuffix $(EXESUF), $(PROGRAMS))
	$(RM_PROGRAM_BUNDLES)

.PHONY: distclean
distclean: clean
	test -d extern && $(MAKE) -f $(AW_MAKE_PATH)/ext.mk -C extern distclean && rmdir extern

.PHONY: recurse
recurse:
	@true


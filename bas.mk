
export AW_MAKE_PATH ?= $(shell pwd)/aw-make
export AW_MAKE_FILE = $(AW_MAKE_PATH)/bas.mk
export BUNDLE_PREFIX ?= noname

include $(AW_MAKE_PATH)/cfg.mk
include $(AW_MAKE_PATH)/ld.mk

.PHONY: $(wildcard *.mk)
-include $(wildcard *.mk)

PRODUCTS := $(addsuffix $(EXESUF), $(PROGRAMS)) $(PRODUCTS)

.PHONY: all
all: $(PRODUCTS)

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
endif
ifneq ($(findstring android, $(TARGET)),)
RM_PRODUCT_APKS = $(RM) -r $(addprefix ., $(PRODUCTS))
endif
ifneq ($(SOSUF),)
RM_SHARED_OBJECTS = $(RM) *$(EXESUF)$(SOSUF)
endif

.PHONY: clean
clean:
	test ! -d extern || $(MAKE) -f $(AW_MAKE_PATH)/ext.mk -C extern clean
	for dir in $(patsubst %.mk,%,$(wildcard *.mk)); do $(MAKE) -C $$dir -f $(AW_MAKE_PATH)/rm.mk clean; done
	$(RM) $(addsuffix $(EXESUF), $(PROGRAMS))
	$(RM_PROGRAM_BUNDLES)
	$(RM_PRODUCT_APKS)
	$(RM_SHARED_OBJECTS)

.PHONY: distclean
distclean: clean
	test ! -d extern || ( $(MAKE) -f $(AW_MAKE_PATH)/ext.mk -C extern distclean && rmdir extern )

.PHONY: recurse
recurse:
	@true


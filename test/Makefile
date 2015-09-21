
export AW_MAKE_PATH := $(shell pwd)/..
export AW_MAKE_FILE=$(shell pwd)/Makefile

include $(AW_MAKE_PATH)/cfg.mk
include $(AW_MAKE_PATH)/ld.mk

-include *.mk

.PHONY: all
all: $(addsuffix $(EXESUF), $(PROGRAMS))

.PRECIOUS: extern/%
extern/%: extern/Makefile recurse
	$(MAKE) -C extern $(subst extern/,,$@)

extern/Makefile:
	mkdir -p $(@D) && \
	cp $(AW_MAKE_PATH)/ext.mk $@

.PRECIOUS: %$(LIBSUF)
%$(LIBSUF): recurse
	$(MAKE) -C $(@D) `test -e $(@D)/requires.mk && echo -f requires.mk` \
		-f $(AW_MAKE_PATH)/cc.mk -f $(AW_MAKE_PATH)/ar.mk \
		$(subst $(@D)/,,$@)

.PHONY: clean
clean: extern/Makefile
	$(MAKE) -C extern clean
	for dir in $(patsubst %.mk,%,$(wildcard *.mk)); do $(MAKE) -C $$dir -f $(AW_MAKE_PATH)/rm.mk clean; done
	$(RM) $(addsuffix $(EXESUF), $(PROGRAMS))
	$(RM) -r $(addsuffix .bundle, $(PROGRAMS))

.PHONY: distclean
distclean: clean
	$(MAKE) -C extern distclean
	rm -f extern/Makefile
	rmdir extern

.PHONY: recurse
recurse:
	@true


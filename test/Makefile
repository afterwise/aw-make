
include ../cfg.mk
include ../ld.mk

PROGRAMS = foo bar

.PHONY: all
all: $(addsuffix $(EXESUF), $(PROGRAMS))

foo.%: foo/libfoo.%$(LIBSUF)
	$(link-game)

bar.%: bar/libbar.%$(LIBSUF)
	$(link-tool)

.PRECIOUS: %$(LIBSUF)
%$(LIBSUF): subdir
	$(MAKE) -C $(@D) $(subst $(@D)/,,$@)

.PHONY: clean
clean:
	$(MAKE) -C foo clean
	$(MAKE) -C bar clean
	rm -fv $(addsuffix $(EXESUF), $(PROGRAMS)) | xargs echo --

.PHONY: subdir
subdir:
	@true


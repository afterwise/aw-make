
PROGRAMS += Foo

FOOLIBS = \
	libLLVMMCJIT

Foo.%: foo/libfoo.%$(LIBSUF) $(patsubst %, extern/%$(EXESUF)$(LIBSUF), $(FOOLIBS))
	$(link)


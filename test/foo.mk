
PROGRAMS += Foo

FOOLIBS = \
	libaw-debug

Foo.%: foo/libfoo.%$(LIBSUF) $(patsubst %, extern/%$(EXESUF)$(LIBSUF), $(FOOLIBS))
	$(link)


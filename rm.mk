
LITTER += *$(EXESUF).dep *$(EXESUF).o *$(EXESUF)$(LIBSUF)

ifneq ($(LIBSUF),)
LITTER += *$(EXESUF)$(LIBSUF)
endif

.PHONY: clean
clean:
	$(RM) $(LITTER)


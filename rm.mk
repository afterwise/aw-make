
LITTER += *$(EXESUF).dep *$(EXESUF).o

ifneq ($(LIBSUF),)
LITTER += *$(EXESUF)$(LIBSUF)
endif
ifneq ($(SOSUF),)
LITTER += *$(EXESUF)$(SOSUF)
endif

.PHONY: clean
clean:
	$(RM) $(LITTER)


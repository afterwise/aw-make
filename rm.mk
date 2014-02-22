
LITTER += *$(EXESUF).dep *$(EXESUF).o *$(EXESUF)$(LIBSUF)

.PHONY: clean
clean:
	rm -fv $(LITTER) | xargs echo --


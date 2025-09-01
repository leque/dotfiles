FLICK_SKK_JISYO = misc/flick-skk.utf8.skk-jisyo
SKKDIC_EXPR2 = skkdic-expr2

.SUFFIXES: .in

.PHONY: clean

$(FLICK_SKK_JISYO): $(FLICK_SKK_JISYO).in
	$(SKKDIC_EXPR2) $< > $@

clean:
	rm -f $(FLICK_SKK_JISYO)

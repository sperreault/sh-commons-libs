NAME = sh-commons-libs
DESTDIR ?= /usr/local

SH_SRCS := $(shell find src -type f -name '*.sh')
SH_BUILDS := $(patsubst src/%.sh, build/%.sh, $(KSH_SRCS))

BIN_SRCS := $(shell find src/bin -type f -name 'sh-commons*')
BIN_BUILDS :=  $(patsubst src/%, build/%, $(BIN_SRCS))

.PHONY: tests all install clean

all: $(SH_BUILDS) $(BIN_BUILDS)

build/bin/sh-%: src/bin/sh-%
	mkdir -p "$(@D)"
	cat $< | sed -e 's/@DESTDIR@/$(subst /,\/,$(DESTDIR))/g' > $@

# SH Building
build/%.sh: src/%.sh
	mkdir -p  "$(@D)"
	cat $< | sed -e 's/@DESTDIR@/$(subst /,\/,$(DESTDIR))/g' > $@

tests: $(SH_BUILDS)
	./tests/tests.ksh

install: $(SH_BUILDS) $(BIN_BUILDS)
	$(foreach target,$(SH_BUILDS), mkdir -p $(subst build,$(DESTDIR),$(dir $(target))) && install -m 0755 $(target) $(subst build,$(DESTDIR),$(target));)
	$(foreach target,$(BIN_BUILDS), mkdir -p $(subst build,$(DESTDIR),$(dir $(target))) && install -m 0755 $(target) $(subst build,$(DESTDIR),$(target));)

clean:
	rm -rf build
	rm -rf install

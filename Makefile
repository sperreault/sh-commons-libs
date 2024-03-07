NAME = bpl
DESTDIR ?= /usr/local

THIS_DIR := $(shell pwd)

SH_SRCS := $(shell find src -type f -name '*.sh')
SH_BUILDS := $(patsubst src/%.sh, build/%.sh, $(SH_SRCS))

BIN_SRCS := $(shell find src/bin -type f -name 'bpl*')
BIN_BUILDS :=  $(patsubst src/%, build/%, $(BIN_SRCS))

#TESTS := $(shell find tests/ -type f -name "*.*sh"
TESTS_DEBIAN := $(addsuffix .debian_test, $(shell find tests -name "*.*sh"))
TESTS = $(TESTS_DEBIAN)

.PHONY: test all install clean docker-debian

all: $(SH_BUILDS) $(BIN_BUILDS)

build/bin/bpl: src/bin/bpl
	mkdir -p "$(@D)"
	cat $< | sed -e 's/@DESTDIR@/$(subst /,\/,$(DESTDIR))/g' > $@

build/bin/bpl-%: src/bin/bpl-%
	mkdir -p "$(@D)"
	cat $< | sed -e 's/@DESTDIR@/$(subst /,\/,$(DESTDIR))/g' > $@

# SH Building
build/%.sh: src/%.sh
	mkdir -p  "$(@D)"
	cat $< | sed -e 's/@DESTDIR@/$(subst /,\/,$(DESTDIR))/g' > $@

.PHONY:
test: $(TESTS)


.PHONY:
docker-debian:
	docker build -t $(NAME)-debian:latest -f tests/Dockerfile.debian .

tests/%.debian_test: docker-debian
	docker run -t -v $(THIS_DIR):/ws -e BPL_BASEDIR=/ws/build  $(NAME)-debian:latest $(strip $(subst ., , $(suffix $(subst .debian_test, , $@)))) $(basename $@)

install: $(SH_BUILDS) $(BIN_BUILDS)
	$(foreach target,$(SH_BUILDS), mkdir -p $(subst build,$(DESTDIR),$(dir $(target))) && install -m 0755 $(target) $(subst build,$(DESTDIR),$(target));)
	$(foreach target,$(BIN_BUILDS), mkdir -p $(subst build,$(DESTDIR),$(dir $(target))) && install -m 0755 $(target) $(subst build,$(DESTDIR),$(target));)

clean:
	rm -rf build
	rm -rf install

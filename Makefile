ifeq ($(OS),Windows_NT)
LOVE:=lovec
else
LOVE:=love
endif

# SOURCE_DIR:=$(shell luajit -e "print(require'tlconfig'.source_dir)")
# BUILD_DIR:=$(shell luajit -e "print(require'tlconfig'.build_dir)")
SOURCE_LUA:=$(shell busybox find src -type f | busybox grep "\.lua$$")
SOURCE_TEAL:=$(shell busybox find src -type f | busybox grep "\.tl$$" | busybox grep -v "\.d\.tl$$")

LIB_LUA:=$(shell busybox find lib -type f | busybox grep "\.lua$$")

GENERATED_LUA:=$(patsubst src/%.tl,build/raw/%.lua,$(SOURCE_TEAL))
COPIED_LUA:=$(patsubst src/%.lua,build/raw/%.lua,$(SOURCE_LUA)) $(patsubst lib/%.lua,build/raw/%.lua,$(LIB_LUA))
BUILT_FILES:=$(GENERATED_LUA) $(COPIED_LUA)

.PHONY: run build clean

run: $(BUILT_FILES)
	cd build/raw && $(LOVE) . --developer --display 2

rebuild: clean build

build: $(BUILT_FILES)

clean:
	busybox rm -rf build/*

build/raw/%.lua: src/%.lua
	busybox dirname $@ | busybox xargs mkdir -p
	busybox cp $< $@

build/raw/%.lua: lib/%.lua
	busybox dirname $@ | busybox xargs mkdir -p
	busybox cp $< $@

$(GENERATED_LUA): $(SOURCE_TEAL)
	busybox mkdir -p build
	tl build

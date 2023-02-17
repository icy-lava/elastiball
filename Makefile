ifeq ($(OS),Windows_NT)
LOVE:=lovec
else
LOVE:=love
endif

# SOURCE_DIR:=$(shell luajit -e "print(require'tlconfig'.source_dir)")
# BUILD_DIR:=$(shell luajit -e "print(require'tlconfig'.build_dir)")
SOURCE_LUA:=$(shell busybox find src -type f | busybox grep "\.lua$$")
SOURCE_TEAL:=$(shell busybox find src -type f | busybox grep "\.tl$$" | busybox grep -v "\.d\.tl$$")

GENERATED_LUA:=$(patsubst src/%.tl,build/%.lua,$(SOURCE_TEAL))
COPIED_LUA:=$(patsubst src/%.lua,build/%.lua,$(SOURCE_LUA))
BUILT_FILES:=$(GENERATED_LUA) $(COPIED_LUA)

.PHONY: run build clean

run: $(BUILT_FILES)
	cd build && $(LOVE) . --developer --display 2

rebuild: clean build

build: $(BUILT_FILES)

clean:
	busybox rm -rf build/*

build/%.lua: src/%.lua
	busybox dirname $@ | busybox xargs mkdir -p
	busybox cp $< $@

$(GENERATED_LUA): $(SOURCE_TEAL)
	tl build

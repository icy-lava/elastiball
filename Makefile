ifeq ($(OS),Windows_NT)
# Windows
LOVE:=lovec
LOVE_JS:=$(shell busybox which love.js | busybox xargs basename)
else
ifneq ($(shell stat /proc/sys/fs/binfmt_misc/WSLInterop 2>/dev/null),)
# WSL
LOVE:=lovec.exe
else
# Posix
LOVE:=love
endif
LOVE_JS:=love.js
endif

# SOURCE_DIR:=$(shell luajit -e "print(require'tlconfig'.source_dir)")
# BUILD_DIR:=$(shell luajit -e "print(require'tlconfig'.build_dir)")
SOURCE_LUA:=$(shell busybox find src -type f | busybox grep "\.lua$$")
SOURCE_TEAL:=src/typedef.tl $(shell busybox find src -type f | busybox grep "\.tl$$" | busybox grep -v "\.d\.tl$$")

SOURCE_LEVEL:=$(shell busybox find asset/level -type f | busybox grep "\.json$$")

SOURCE_ASSETS:=$(SOURCE_LEVEL)

LIBRARY_LUA:=$(shell busybox find lib -type f | busybox grep "\.lua$$")

GENERATED_LUA:=$(patsubst src/%.tl,build/raw/%.lua,$(SOURCE_TEAL))
COPIED_LUA:=$(patsubst src/%.lua,build/raw/%.lua,$(SOURCE_LUA)) $(patsubst lib/%.lua,build/raw/%.lua,$(LIBRARY_LUA))

COMPILED_FILES:=$(GENERATED_LUA) $(COPIED_LUA)
COPIED_ASSETS:=$(patsubst asset/%,build/raw/asset/%,$(SOURCE_ASSETS))
ALL_FILES:=$(COMPILED_FILES) $(COPIED_ASSETS)

ARTIFACT_LOVE:=build/game.love
ARTIFACT_WEB:=build/game-web

.PHONY: run editor serve codegen compile assets clean love web

run: $(ALL_FILES)
	cd build/raw && $(LOVE) . --developer --display 2

editor: $(ALL_FILES)
	cd build/raw && $(LOVE) . --editor --developer --display 2

serve: $(ARTIFACT_WEB)
	cd build/game-web && python -m http.server --bind 127.0.0.1

codegen: src/typedef.tl

compile: $(COMPILED_FILES)

assets: $(COPIED_ASSETS)
build/raw/asset/level/%: asset/level/%
	busybox dirname $@ | busybox xargs mkdir -p
	busybox cp $< $@

love: $(ARTIFACT_LOVE)
$(ARTIFACT_LOVE): $(ALL_FILES)
	busybox rm -f $(ARTIFACT_LOVE)
	7z a -bd -tzip -mx0 -r $@ ./build/raw/*

web: $(ARTIFACT_WEB)
$(ARTIFACT_WEB): $(ARTIFACT_LOVE)
	busybox rm -rf $(ARTIFACT_WEB)
	$(LOVE_JS) -c -t game $< $@

clean:
	busybox rm -rf build/*

build/raw/%.lua: src/%.lua
	busybox dirname $@ | busybox xargs mkdir -p
	busybox cp $< $@

build/raw/%.lua: lib/%.lua
	busybox dirname $@ | busybox xargs mkdir -p
	busybox cp $< $@

src/typedef.tl: typedef.tl
	tl gen typedef.tl
	tl run typedef.lua gen > $@
	busybox rm typedef.lua
	tl check -q $@

$(GENERATED_LUA): $(SOURCE_TEAL) tlconfig.lua
	busybox mkdir -p build/raw
	tl build --wdisable redeclaration

# aka - Per directory shell aliases
#
# Luastatic command line tool is a prerequisite for this build process
# https://github.com/ers35/luastatic

all: build

.PHONY: build
build:
	rm -rf build
	mkdir build
	luastatic \
		aka.lua \
		aka/init.lua \
		aka/core.lua \
		aka/utils.lua \
		/usr/lib/x86_64-linux-gnu/liblua5.3.a \
		-I/usr/include/lua5.3 \
		-o build/aka
	mv aka.lua.c build/

install: build
	sudo cp build/aka /usr/local/bin

uninstall:
	sudo rm /usr/local/bin/aka

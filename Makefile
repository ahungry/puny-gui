# -*- mode: makefile -*-

# Include all the other things from various targets

CC=gcc

#-fsanitize=address -g
CFLAGS=-Wall -Wno-unused-variable -Wno-unused-function -Wno-unused-parameter -Wno-format-truncation -std=gnu99 -fPIC
LFLAGS=-lm -pthread -lz

JANET_CFLAGS=-I./ -I./build/janet/build
JANET_LFLAGS=-ldl

CURL_CFLAGS=
CURL_LFLAGS=-lcurl

IUP_CFLAGS=-I./build/linux/iup/include
IUP_LFLAGS=-L./build/linux/iup \
	-l:libiup.a \
	-l:libiupimglib.a \
	-l:libiupim.a \
	-L./build/linux/im \
	-l:libim.a \
	-lpng16 \
	-lstdc++ \
	`pkg-config --libs gtk+-3.0` -lX11

CIRCLET_CFLAGS=-I./circlet
CIRCLET_LFLAGS=

SQLITE3_CFLAGS=-I./sqlite3
SQLITE3_LFLAGS=-lsqlite3

all: app.bin super-repl.bin

app.bin: app.c
	$(CC) $(CFLAGS) \
	$(JANET_CFLAGS) \
	$(SQLITE3_CFLAGS) \
	$(CURL_CFLAGS) \
	$(IUP_CFLAGS) \
	$(CIRCLET_CFLAGS) \
	build/janet/build/janet.c $< -o $@  \
	$(JANET_LFLAGS) \
	$(SQLITE3_LFLAGS) \
	$(CURL_LFLAGS) \
	$(IUP_LFLAGS) \
	$(CIRCLET_LFLAGS) \
	$(LFLAGS)

super-repl.bin: super.c
	$(CC) $(CFLAGS) \
	$(JANET_CFLAGS) \
	$(SQLITE3_CFLAGS) \
	$(CURL_CFLAGS) \
	$(IUP_CFLAGS) \
	$(CIRCLET_CFLAGS) \
	build/janet/build/janet.c $< -o $@  \
	$(JANET_LFLAGS) \
	$(SQLITE3_LFLAGS) \
	$(CURL_LFLAGS) \
	$(IUP_LFLAGS) \
	$(CIRCLET_LFLAGS) \
	$(LFLAGS)

docker-build:
	docker build -t puny_gui_build . -f Dockerfile_ubuntu

docker-get:
	docker cp puny_gui_run:/app/puny-gui-linux64.tar.gz ./

docker-run:
	$(info docker cp puny_gui:/app/puny-gui-linux64.tar.gz ./)
	-docker rm puny_gui_run
	docker run --name puny_gui_run \
	-it puny_gui_build

demo-dog:
	./super-repl.bin ./examples/dog-gui.janet

.PHONY: docker-ubuntu demo-dog

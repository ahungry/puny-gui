# -*- mode: makefile -*-

# Include all the other things from various targets

CC=gcc

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
	docker build -t super_test_build . -f Dockerfile_ubuntu

docker-get:
	docker cp super_test_run:/app/target/super/super-janet-app-linux64.tar.gz ./

docker-run:
	$(info docker cp super_test:/app/target/super/super-janet-app-linux64.tar.gz ./)
	-docker rm super_test_run
	docker run --name super_test_run \
	-it super_test_build

.PHONY: docker-ubuntu

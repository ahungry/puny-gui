#!/bin/sh

rm super-janet-app-win64.zip

zip -r super-janet-app-win64.zip \
    ./*.janet \
    ./*.dll \
    ./*.exe \
    ./lib \
    ./examples \
    ./logo.png \
    ./logo2.png

#!/bin/sh

rm super-janet-app-win64.zip

zip -r super-janet-app-win64.zip \
    ./*.janet \
    ./*.dll \
    ./*.exe \
    ./logo.png \
    ./logo2.png

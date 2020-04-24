#!/bin/sh

rm puny-gui-win64.zip

zip -r puny-gui-win64.zip \
    ./*.janet \
    ./*.dll \
    ./*.exe \
    ./lib \
    ./examples \
    ./logo.png \
    ./logo2.png

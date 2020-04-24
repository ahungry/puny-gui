#!/bin/sh

DLL_ROOT=/usr/x86_64-w64-mingw32/bin

cp $DLL_ROOT/libstdc++-6.dll ./
cp $DLL_ROOT/libgcc_s_seh-1.dll ./

cp ~/software/im/win64-dynamic/im.dll ./

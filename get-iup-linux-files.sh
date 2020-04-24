#!/bin/sh

top=$(pwd)

# GNU/Linux files
mkdir -p build/linux/iup
cd build/linux/iup

# .a and .so files
wget 'https://sourceforge.net/projects/iup/files/3.28/Linux%20Libraries/iup-3.28_Linux50_64_lib.tar.gz' -O iup.tar.gz

tar xzvf iup.tar.gz

cd $top

mkdir -p build/linux/im
cd build/linux/im

wget 'https://sourceforge.net/projects/imtoolkit/files/3.13/Linux%20Libraries/im-3.13_Linux415_64_lib.tar.gz' -O im.tar.gz

tar xzvf im.tar.gz

#wget 'https://sourceforge.net/projects/canvasdraw/files/5.12/Linux%20Libraries/cd-5.12_Linux44_64_lib.tar.gz'

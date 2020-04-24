#!/bin/sh

top=$(pwd)


mkdir -p build/win/iup
cd build/win/iup

# Get the Windows files

# .a and .dll files
wget 'https://sourceforge.net/projects/iup/files/3.28/Windows%20Libraries/Static/iup-3.28_Win64_mingw6_lib.zip' -O iup.zip

unzip iup.zip
#wget 'https://sourceforge.net/projects/iup/files/3.28/Windows%20Libraries/Dynamic/iup-3.28_Win64_dllw6_lib.zip'

cd $top

mkdir -p build/win/im
cd build/win/im

wget 'https://sourceforge.net/projects/imtoolkit/files/3.13/Windows%20Libraries/Dynamic/im-3.13_Win64_dllw6_lib.zip' -O im.zip
#wget 'https://sourceforge.net/projects/imtoolkit/files/3.13/Windows%20Libraries/Static/im-3.13_Win64_mingw6_lib.zip'

unzip im.zip

# wget 'https://sourceforge.net/projects/canvasdraw/files/5.12/Windows%20Libraries/Dynamic/cd-5.12_Win64_dllw6_lib.zip'
# wget 'https://sourceforge.net/projects/canvasdraw/files/5.12/Windows%20Libraries/Static/cd-5.12_Win64_mingw6_lib.zip'

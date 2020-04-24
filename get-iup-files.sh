#!/bin/sh

# GNU/Linux files
mkdir -p build/linux/iup
cd build/linux/iup

# .a and .so files
wget 'https://sourceforge.net/projects/iup/files/3.28/Linux%20Libraries/iup-3.28_Linux50_64_lib.tar.gz' -O iup.tar.gz

tar xzvf iup.tar.gz
#wget 'https://sourceforge.net/projects/imtoolkit/files/3.13/Linux%20Libraries/im-3.13_Linux415_64_lib.tar.gz'
#wget 'https://sourceforge.net/projects/canvasdraw/files/5.12/Linux%20Libraries/cd-5.12_Linux44_64_lib.tar.gz'


mkdir -p build/win/iup
cd build/win/iup

# Get the Windows files

# .a and .dll files
wget 'https://sourceforge.net/projects/iup/files/3.28/Windows%20Libraries/Static/iup-3.28_Win64_mingw6_lib.zip' -O iup.zip

unzip iup.zip
#wget 'https://sourceforge.net/projects/iup/files/3.28/Windows%20Libraries/Dynamic/iup-3.28_Win64_dllw6_lib.zip'

mkdir -p build/win/im
cd build/win/im

wget 'https://sourceforge.net/projects/imtoolkit/files/3.13/Windows%20Libraries/Dynamic/im-3.13_Win64_dllw6_lib.zip' -O im.zip
#wget 'https://sourceforge.net/projects/imtoolkit/files/3.13/Windows%20Libraries/Static/im-3.13_Win64_mingw6_lib.zip'

unzip im.zip

# wget 'https://sourceforge.net/projects/canvasdraw/files/5.12/Windows%20Libraries/Dynamic/cd-5.12_Win64_dllw6_lib.zip'
# wget 'https://sourceforge.net/projects/canvasdraw/files/5.12/Windows%20Libraries/Static/cd-5.12_Win64_mingw6_lib.zip'

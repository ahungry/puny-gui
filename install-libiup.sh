#!/bin/sh

set +x

echo This is going to install libiup.so and libim.so into /usr/lib
echo Ensure you are running this as root

cp build/linux/iup/libiup.so /usr/local/lib/
cp build/linux/im/libim.so /usr/local/lib/

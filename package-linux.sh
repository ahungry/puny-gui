#!/bin/sh

dir=super-janet-app-linux64

rm -fr $dir
rm $dir.tar.gz
mkdir $dir

cp ./*.janet $dir/
cp ./*.bin $dir/
cp ./logo.png $dir/
cp ./logo2.png $dir/

tar czvf $dir.tar.gz $dir

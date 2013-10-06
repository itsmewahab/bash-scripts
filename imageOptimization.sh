#!/bin/bash

## JPEG-OPTIM
sudo apt-get install -y jpegoptim libjpeg-progs

## GITSICLE
sudo apt-get install -y gifsicle

## OPTI-PNG && ADVPNG
sudo apt-get install -y optipng advancecomp pngcrush

## Download PNGWOLF
sudo apt-get install  -y build-essential git-core cmake
cd /tmp
git clone https://github.com/hoehrmann/pngwolf.git
cd pngwolf

## Download PNGWOLF dependencies
wget http://archive.ubuntu.com/ubuntu/pool/universe/g/galib/galib_2.4.7.orig.tar.gz
tar -zxvf galib_2.4.7.orig.tar.gz
mv galib247 galib

wget http://zlib.net/zlib-1.2.8.tar.gz
tar -zxvf zlib-1.2.8.tar.gz
mv zlib-1.2.8 zlib

mkdir 7zip
cd 7zip 
wget http://downloads.sourceforge.net/sevenzip/7z920.tar.bz2
tar -xjvf 7z920.tar.bz2
cd ..

cmake CMakeLists.txt

## Patch using Bash... because .patch sucks sometimes
sed 's/#include <stdlib.h>/ /g' 7zip/C/Alloc.c
sed 's/#include <stddef.h>/#include <stddef.h>\n#include <stdlib.h>/g' 7zip/C/Alloc.c
sed 's/memcpy(dest, _buffer, _size);/memcpy(dest, _buffer.operator const unsigned char *(), _size);/g' 7zip/CPP/7zip/Common/StreamObjects.cpp

## Make the pngwolf exec :D
make

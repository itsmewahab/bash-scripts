#!/bin/bash

## JPEG-OPTIM
sudo apt-get install -y jpegoptim libjpeg-progs

## GITSICLE
sudo apt-get install -y gifsicle

## OPTI-PNG && ADVPNG
sudo apt-get install -y optipng advancecomp pngcrush

## PNGOUT
cd /tmp
sudo wget http://static.jonof.id.au/dl/kenutils/pngout-20130221-linux.tar.gz
sudo tar -xvf pngout-*-linux.tar.gz
sudo cp pngout-20130221-linux/x86_64/pngout /usr/bin/
sudo chmod +x /usr/bin/pngout
sudo rm -Rf /tmp/pngout-*

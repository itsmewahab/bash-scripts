#!/bin/bash

############################################################################
#
# Author: Nil Portugués Calderó <contact@nilportugues.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
############################################################################

if [ "$UID" -ne "0" ]
then
  echo "" 
  echo "You must be sudoer or root. To run this script enter:"
  echo ""
  echo "sudo chmod +x $0; sudo ./$0"
  echo ""
  exit 1
fi

cd
wget https://webp.googlecode.com/files/libwebp-0.3.1-linux-x86-64.tar.gz
tar -xvf libwebp-0.3.1-linux-x86-64.tar.gz
cd libwebp-0.3.1-linux-x86-64

cp cwebp /usr/bin/cwebp
cp dwebp /usr/bin/dwebp
cp gif2webp /usr/bin/gif2webp
cp vwebp /usr/bin/vwebp
cp webpmux /usr/bin/webpmux

chmod +x /usr/bin/cwebp
chmod +x  /usr/bin/dwebp
chmod +x  /usr/bin/gif2webp
chmod +x  /usr/bin/vwebp
chmod +x /usr/bin/webpmux

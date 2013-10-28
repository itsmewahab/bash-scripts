#!/bin/bash

if [ "$UID" -ne "0" ]
then
  echo "" 
  echo "You must be sudoer or root. To run this script enter:"
  echo ""
  echo "sudo chmod +x $0; sudo ./$0"
  echo ""
  exit 1
fi

sudo apt-get install -y s3cmd

echo ''
echo 'Warning: one last step is needed. You need to configure the s3cmd using: s3cmd --configure'
echo ''

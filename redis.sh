#!/bin/bash

## Download
cd /tmp 
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable

## Install
make

## Remove download files
cd ..
rm redis-stable.tar.gz
rm -Rf redis-stable

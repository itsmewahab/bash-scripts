#!/bin/bash

########################################################################
# INSTALLATION
########################################################################

## Add the repo for RabbitMQ
sudo echo 'deb http://www.rabbitmq.com/debian/ testing main' >> /etc/apt/sources.list

## Add the Auth keys
sudo wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
sudo apt-key add rabbitmq-signing-key-public.asc

## Update and install
sudo apt-get update
sudo apt-get install -y rabbitmq-server

DATA="
# I am a complete /etc/rabbitmq/rabbitmq-env.conf file.
# Comment lines start with a hash character.
# This is a /bin/sh script file - use ordinary envt var syntax
NODENAME=rabbit_1
"

sudo echo $DATA >> /etc/rabbitmq/rabbitmq-env.conf 

sudo service rabbitmq-server restart

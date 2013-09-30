#!/bin/bash

########################################################################
# INSTALLATION
########################################################################

## Add the repo for RabbitMQ
echo 'deb http://www.rabbitmq.com/debian/ testing main' >> /etc/apt/sources.list

## Add the Auth keys
wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
sudo apt-key add rabbitmq-signing-key-public.asc

## Update and install
apt-get update
sudo apt-get install rabbitmq-server

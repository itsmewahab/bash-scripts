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

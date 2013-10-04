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

## Add an admin user and grant permissions
rabbitmqctl add_user admin adminpass
rabbitmqctl set_user_tags admin administrator
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

## Delete default user. We can't risk it :D
rabbitmqctl delete_user guest

## Enable plugins
rabbitmq-plugins enable rabbitmq_management

##Reload and inform the user.
sudo service rabbitmq-server restart

echo '...............................................................'
echo 'Current set up:'
echo '...............................................................'
echo 'RabbitMQ user: admin'
echo 'RabbitMQ pass: adminpass'
echo ''
echo '...............................................................'
echo 'Change the password by running the following command:'
echo '' 
echo 'rabbitmqctl change_password admin <new_password>' 
echo '' 

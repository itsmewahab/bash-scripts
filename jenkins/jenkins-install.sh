#!/bin/bash

## Download Jenkins
sudo wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
sudo echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list
sudo apt-get update
sudo apt-get install jenkins

## Configure Jenkins SSH
sudo su - jenkins
cd
ssh-keygen

## Disable warning yes/no when doing ssh connections using git
echo 'StrictHostKeyChecking no' >>  ~/.ssh/config
echo 'UserKnownHostsFile /dev/null' >>  ~/.ssh/config

#!/bin/bash

## Download jenkins-cli
if [ ! -f jenkins-cli.jar ];
then
	wget http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar
fi

java -jar jenkins-cli.jar -s http://127.0.0.1:8080 login --username admin

## Install Git support Plugins
java -jar jenkins-cli.jar -s http://127.0.0.1:8080 install-plugin git git-client github github-api github-oauth bitbucket-oauth git-parameter 

## Install PHP Plugins
java -jar jenkins-cli.jar -s http://127.0.0.1:8080 install-plugin checkstyle pmd plot analysis-collector jdepend htmlpublisher dry cloverphp violations xunit

## Other plugins
java -jar jenkins-cli.jar -s http://127.0.0.1:8080 install-plugin progress-bar-column-plugin timestamper unicorn ansicolor

echo -e $(cat php-template.xml) | java -jar jenkins-cli.jar -s http://127.0.0.1:8080 create-job php-template

## Restart Jenkins
java -jar jenkins-cli.jar -s http://127.0.0.1:8080 safe-restart

#!/bin/bash

#######################################################################################################
#
# Use this script (bash ssh-credential-fix.sh).
#
# If a server is not allowing you passwordless login, to fix SSH permissions when accidentally are
# changed or if passwordless login isn't working for some reason.
#
#######################################################################################################

##-----------------------------------
## The user's folder DOES matter.
##-----------------------------------
chmod o-w ~/;

##-----------------------------------
## SSH crendentials
##-----------------------------------

if [ -d  ~/.ssh ];
then
	chmod 700 ~/.ssh
fi

if [ -f  ~/.ssh/config ];
then
	chmod 600 ~/.ssh/config
fi

if [ -f  ~/.ssh/id_rsa ];
then
	chmod 600 ~/.ssh/id_rsa
fi

if [ -f ~/.ssh/id_rsa.pub ];
then
	chmod 600 ~/.ssh/id_rsa.pub
fi

if [ -f  ~/.ssh/known_hosts ];
then
	chmod 600 ~/.ssh/known_hosts
fi

if [ -f  ~/.ssh/authorized_keys ];
then
	chmod 600 ~/.ssh/authorized_keys
fi

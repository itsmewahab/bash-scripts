#!/bin/bash

############################################################################
#
# Author: Nil Portugués Calderó <contact@nilportugues.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
############################################################################

# Default mail quota in MegaBytes.
DEFAULT_QUOTA='1000'

STORAGE_BASE_DIRECTORY="/var/vmail/vmail1"
STORAGE_BASE="$(dirname ${STORAGE_BASE_DIRECTORY})"
STORAGE_NODE="$(basename ${STORAGE_BASE_DIRECTORY})"

###########################################################
# Generate the SQL to create the user.
###########################################################
generate_sql()
{
    # Get domain name.
    DOMAIN="$1"
    username="$2"
    password="$3"
    mail="${username}@${DOMAIN}"
    CRYPT_PASSWD="$(openssl passwd -1 ${password})"

    # GENERATE MAIL BOX
    length="$(echo ${username} | wc -L)"
    str1="$(echo ${username} | cut -c1)"
    str2="$(echo ${username} | cut -c2)"
    str3="$(echo ${username} | cut -c3)"

    if [ X"${length}" == X"1" ]; then
         str2="${str1}"
         str3="${str1}"
    elif [ X"${length}" == X"2" ]; then
         str3="${str2}"
    else
         :
    fi

   # Maildir format
   DATE="$(date +%Y.%m.%d.%H.%M.%S)"
   maildir="${DOMAIN}/${str1}/${str2}/${str3}/${username}-${DATE}/"

echo "
	INSERT INTO mailbox (username, password, name, storagebasedirectory,storagenode, maildir, quota, domain, active, local_part, created) 
	VALUES ('${mail}', '${CRYPT_PASSWD}', '${username}', '${STORAGE_BASE}','${STORAGE_NODE}', '${maildir}', '${DEFAULT_QUOTA}', '${DOMAIN}', '1','${username}', NOW());
	INSERT INTO alias (address, goto, domain, created, active) VALUES ('${mail}', '${mail}','${DOMAIN}', NOW(), 1);
"
}


#######################################################################
# MAIN
#######################################################################
if [ $# -lt 3 ]; 
then
	echo ''
	echo "Usage: $0 <domain_name> <username> <password>"
	echo ''

	exit 1
fi

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ];
then
	echo ''
	echo "Usage: $0 <domain_name> <username> <password>"
	echo ''

	exit 1
fi

echo ''
echo $(generate_sql $1 $2 $3)
echo ''

exit 0

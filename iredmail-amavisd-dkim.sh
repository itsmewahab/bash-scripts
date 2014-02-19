#!/bin/bash

############################################################################
#
# Author: Nil Portugués Calderó <contact@nilportugues.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
############################################################################
 
if [ $(whoami) != "root" ];
then
  echo "" 
  echo "You must be sudoer or root."
  echo ""
  echo "Usage: sudo bash $0 <domain_name>"
  echo ""
  exit 1
fi

if [ "$#" != "1" ];
then
  echo "" 
  echo "Usage: ./$0 <domain_name>"
  echo ""
  exit 1
fi

PWD=`pwd`
DOMAIN=$1
AMAVIS_PATH="/etc/amavis/conf.d/50-user"
AMAVIS_SEPARATOR_STRING="use strict;"

##################################################################################################
## Step 1: generate keys for all required domains
##################################################################################################
cd /var/lib/dkim/
if [ -f $DOMAIN.pem ];
then
	rm -f $DOMAIN.pem
fi
sudo amavisd-new genrsa $DOMAIN.pem
sudo chmod 0644 *.pem

##################################################################################################
## Step 2: Add just after "use strict" all the keys generated
##################################################################################################

#Add a newline to the configuration for the new domain
EXISTS=`cat $AMAVIS_PATH | grep "dkim_key(\"$DOMAIN\", \"dkim\"," | wc -l`
if [ "$EXISTS" = "0" ];
then
    NEWLINE="dkim_key(\"$DOMAIN\", \"dkim\", \"\/var\/lib\/dkim\/$DOMAIN.pem\");"
    sed -i "s/$AMAVIS_SEPARATOR_STRING/$AMAVIS_SEPARATOR_STRING\n$NEWLINE/g" $AMAVIS_PATH
fi

# Create this line containing all previous domaisn, plus the new one domains# 
EXISTS=`cat $AMAVIS_PATH | grep '".\$mydomain"' | wc -l`
if [ "$EXISTS" = "0" ];
then
    ## No local_domains_map exists in the editable area
    REPLACE_STRING="\@local_domains_maps = ( \[\".\$mydomain\", '$DOMAIN' \] );"
    sed -i "s/$AMAVIS_SEPARATOR_STRING/$AMAVIS_SEPARATOR_STRING\n$REPLACE_STRING/g" $AMAVIS_PATH

else
    ## Case local_domains_map already exists in editable area.
    FIND_STRING="\@local_domains_maps = ( \[\".\$mydomain\", "
    REPLACE_STRING="\@local_domains_maps = ( \[\".\$mydomain\", '$DOMAIN', "
    sed -i "s/$FIND_STRING/$REPLACE_STRING/g" $AMAVIS_PATH
fi

##################################################################################################
## Step 3: Apply changes
##################################################################################################
sudo service amavis restart

##################################################################################################
## Step 4: Generate DNS TXT records
##################################################################################################

var=$( amavisd-new showkeys $DOMAIN | sed 's/"//g' |tail -n+2 | sed 's/ //g' | sed "s/3600TXT(//g" ); 
var="${var:0: -1}\"" 
var=`echo $var | sed 's/= /=/g' | sed 's/ //g' | sed 's/v=DKIM1/\t\t"v=DKIM1/g'`

## DNS "TXT" record for the domain
cd ~
echo $var > "$PWD/dns.txt_record.$DOMAIN.txt"
sudo chmod 777 "$PWD/dns.txt_record.*.txt"




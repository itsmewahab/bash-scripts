#!/bin/bash

PWD=`pwd`
RABBITMQ_PATH="/etc/rabbitmq"

SSL_CERTIFICATE_AUTH='MySSLCertificationAuth'
SSL_EXPIRES="7300" 								##20 years
SSL_ENCRYPTION="2048"

SERVER_HOSTNAME=$1
SERVER_NAME=$2
SERVER_PASS=$3
CLIENT_NAME=$4
CLIENT_PASS=$5

read -r -d '' SSL_CONFIG <<EOF

[ ca ]											\n                                                     
default_ca = testca 							\n                                       
												\n
[ testca ] 										\n                                                
dir = .   										\n                                                 
certificate = \$dir/cacert.pem  				\n                            
database = \$dir/index.txt 						\n                                 
new_certs_dir = \$dir/certs 					\n                                
private_key = \$dir/private/cakey.pem 			\n                      
serial = \$dir/serial  							\n                                     
												\n
default_crl_days = 7  							\n                                     
default_days = 7300  							\n                                       
default_md = sha1   							\n                                       
												\n
policy = testca_policy 							\n                                    
x509_extensions = certificate_extensions     	\n              
												\n 
[ testca_policy ]    							\n                                      
commonName = supplied  							\n                                    
stateOrProvinceName = optional  				\n                           
countryName = optional     						\n                                
emailAddress = optional     					\n                               
organizationName = optional 					\n                               
organizationalUnitName = optional   			\n                       
												\n
[ certificate_extensions ]  					\n                               
basicConstraints = CA:false  					\n                              
												\n
[ req ]            								\n                                       
default_bits = 2048    							\n                                   
default_keyfile = ./private/cakey.pem 			\n                     
default_md = sha1        						\n                                  
prompt = yes     								\n                                          
distinguished_name = root_ca_distinguished_name \n        
x509_extensions = root_ca_extensions   			\n                    
												\n
[ root_ca_distinguished_name ]   				\n                          
commonName = hostname     						\n                                 
												\n
[ root_ca_extensions ]     						\n                                
basicConstraints = CA:true    					\n                             
keyUsage = keyCertSign, cRLSign   				\n                         
												\n
[ client_ca_extensions ]   						\n                                
basicConstraints = CA:false   					\n                             
keyUsage = digitalSignature     				\n                           
extendedKeyUsage = 1.3.6.1.5.5.7.3.2  			\n                     
												\n
[ server_ca_extensions ]     					\n                              
basicConstraints = CA:false  					\n                              
keyUsage = keyEncipherment    					\n                             
extendedKeyUsage = 1.3.6.1.5.5.7.3.1			\n

EOF


########################################################################################
## STEP 1: This will generate a certificate for a client application (connecting to a RabbitMQ Broker).
########################################################################################
setupCA()
{

	echo $SSL_CONFIG > "openssl.cnf"
	export OPENSSL_CONF="../openssl.cnf"

	mkdir -p ca
	mkdir -p ca/private
	mkdir -p ca/certs
	echo "01" > ca/serial
	touch ca/index.txt

	cd ca
	openssl req -x509 -newkey rsa:$SSL_ENCRYPTION -days $SSL_EXPIRES -out cacert.pem -outform PEM -subj /CN=$SSL_CERTIFICATE_AUTH/ -nodes
	openssl x509 -in cacert.pem -out cacert.cer -outform DER
	cd ..
}

########################################################################################
## STEP 2 : This will generate a certificate for a server a RabbitMQ Broker.
########################################################################################
makeSSLServerCert()
{
	SERVER_NAME=$1
	SERVER_PASS=$2

	echo $SSL_CONFIG > "openssl.cnf"
	export OPENSSL_CONF="../openssl.cnf"

	mkdir -p server

	cd server
	echo "Generating key.pem"
	openssl genrsa -out $SERVER_NAME.key.pem $SSL_ENCRYPTION
	echo "Generating req.pem"
	openssl req -new -key $SERVER_NAME.key.pem -out $SERVER_NAME.req.pem -outform PEM -subj /CN=$SERVER_NAME/O=server/ -nodes
	cd ..

	cd ca
	echo "Generating cert.pem"
	openssl ca -in ../server/$SERVER_NAME.req.pem -out ../server/$SERVER_NAME.cert.pem -notext -batch -extensions server_ca_extensions
	cd ..

	cd server
	echo "Generating keycert.p12"
	openssl pkcs12 -export -out $SERVER_NAME.keycert.p12 -in $SERVER_NAME.cert.pem -inkey $SERVER_NAME.key.pem -passout pass:$SERVER_PASS
	cd ..
}


########################################################################################
## STEP 3:  This will generate a certificate for a client application connecting to a RabbitMQ Broker
########################################################################################
makeSSLClientCert()
{
	echo $SSL_CONFIG > "openssl.cnf"
	export OPENSSL_CONF="../openssl.cnf"

	if [ ! -d ./client/ ];
	then
		echo "Creating folder: client/"
		mkdir client
	fi

	cd client
	echo "Generating key.pem"
	openssl genrsa -out $CLIENT_NAME.key.pem $SSL_ENCRYPTION
	echo "Generating req.pem"
	openssl req -new -key $CLIENT_NAME.key.pem -out $CLIENT_NAME.req.pem -outform PEM -subj /CN=$CLIENT_NAME/O=client/ -nodes
	cd ..

	cd ca
	echo "Generating cert.pem"
	openssl ca -in ../client/$CLIENT_NAME.req.pem -out ../client/$CLIENT_NAME.cert.pem -notext -batch -extensions client_ca_extensions
	cd ..

	cd client
	echo "Generating keycert.p12"
	openssl pkcs12 -export -out $CLIENT_NAME.keycert.p12 -in $CLIENT_NAME.cert.pem -inkey $CLIENT_NAME.key.pem -passout pass:$CLIENT_PASS
	cd ..
}


########################################################################################
## FINAL STEP, COPY THE CERTIFICATES OVER TO THE DIRECTORY.
########################################################################################
copyServerKeysToRabbitMQ()
{
    ## Create SSL RabbitMQ directories
    sudo mkdir -p $RABBITMQ_PATH/ssl/ca
    sudo mkdir -p $RABBITMQ_PATH/ssl/server

    ## Copy over SSL Certificate keys over RabbitMQ
    sudo cp ./ca/cacert.pem $RABBITMQ_PATH/ssl/ca/cacert.pem
    sudo cp ./server/*.key.pem $RABBITMQ_PATH/ssl/server/
   	sudo cp ./server/*.cert.pem $RABBITMQ_PATH/ssl/server/
}

copyClientKeysOutsideTempDir()
{
	mkdir -p ../RabbitMQClientKeys
	cp ./client/* ../RabbitMQClientKeys/

	cd ../RabbitMQClientKeys
	PWD=`pwd`
	echo "Public keys for your client are located in: $PWD "
}

########################################################################################
## MAIN
##--------------------------------------------------------------------------------------
## Based on: http://www.gettingcirrius.com/2013/01/configuring-ssl-for-rabbitmq.html
########################################################################################

if [ $# -ne 5 ];
then
	echo "This script will generate a self-signed SSL certificate. This is meant to be used in non-public environtments only."
	echo "This should be fine, considering queuing systems should never be public."
	echo ""
	echo "Usage:"
	echo "sh $0 <server_hostname> <server_user> <server_password> <rabbitmq_client> <rabbitmq_client_password>"
	echo ""
	echo "<server_hostname> \t\t Name of your server. Eg: rabbitmq1.example.com"	
	echo "<server_user> \t\t Name of a user with access privileges"	
	echo "<server_password> \t\t Password for a user with access privileges."	
	echo "<rabbitmq_client> \t\t RabbitMQ user connecting to the RabbitMQ Worker."	
	echo "<rabbitmq_client_password> \t RabbitMQ password for the user connecting to the RabbitMQ Worker."
	echo ""
	exit 1
else
	
	## Temporal setup dir
	EPOCH=`date +%s`
	mkdir "$PWD/temp_$EPOCH"
	cd "$PWD/temp_$EPOCH"
	

	## Do setup
	setupCA $SSL_CERTIFICATE_AUTH
	makeSSLServerCert $SERVER_NAME $SERVER_PASS
	makeSSLClientCert $CLIENT_NAME $CLIENT_PASS
	copyServerKeysToRabbitMQ
	copyClientKeysOutsideTempDir
	
	## Remove files
	rm -Rf "$PWD/temp_$EPOCH"

	exit 0
fi
















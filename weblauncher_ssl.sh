#!/bin/bash


#colors
   res='\e[0m'
   red='\033[0;31m'
   green='\033[0;32m'
   blue='\033[0;34m'
   white='\033[1;37m'


clear
echo -e "$green[+]$res Web launcher with ssl certification(https)"
echo -e "$green[?]$res Continue? y/n"
read answer

packages_install(){

	sudo apt install openssl
	sudo apt install apache2
	sleep 2
	sudo systemctl enable apache2
	sudo systemctl start apache2
}

ssl_config(){
	echo -e "\n$green[+]$res Create a directory to store the keys and certifications. Absolute path."
	read directorio	
	mkdir $directorio
	cd $directorio
	openssl genrsa -des3 -out ca.key 4096
	openssl req -new -x509 -days 365 -key ca.key -out ca.crt
	openssl genrsa -des3 -out server_x.key 4096
	sleep 2
	openssl req -new -key server_x.key -out server_x.csr
	openssl x509 -req -days 365 -in server_x.csr -CA ca.crt -CAkey ca.key -set_serial 03 -out server_CRT.crt

	sudo cp -v server_CRT.crt /etc/ssl/certs/
	sudo cp -v server_x.key /etc/ssl/private/

	ruta1="/etc/ssl/certs/server_CRT.crt"
	ruta2="/etc/ssl/private/server_x.key"
	sudo  sed -i "s@^\(\s*SSLCertificateFile\s*\).*@\1 $ruta1@" /etc/apache2/sites-available/default-ssl.conf
	sudo  sed -i "s@^\(\s*SSLCertificateKeyFile\s*\).*@\1 $ruta2@" /etc/apache2/sites-available/default-ssl.conf
	
	sleep 1
	cd /etc/apache2/sites-available/
	
	sudo a2enmod ssl
	sudo a2ensite default-ssl.conf
	sudo systemctl restart apache2

}

if [ $answer == y ]; then
	packages_install
	ssl_config
	echo -e "Your default website with protocol https:$white https://localhost/$res"
else
	echo -e "$red[!]$res The web server will not be configured"
fi

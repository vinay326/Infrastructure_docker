#!/bin/sh
cat /etc/os-release
apt list
uname -a
apt-get update
apt-get install python3 -y
apt-get install python3-pip -y
apt-get install wget -y
apt-get install unzip -y
wget https://releases.hashicorp.com/terraform/1.0.3/terraform_1.0.3_linux_amd64.zip 
unzip terraform_1.0.3_linux_amd64.zip 
mv terraform /usr/local/bin/

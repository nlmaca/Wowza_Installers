#!/bin/bash

# Date: 2020-07-01
# Author: J. van Marion / jeroen@vanmarion.nl
# Version: 2.1

# Wowza installer 4.8.5 for Ubuntu 18.04.4
# Including: 
#   Wowza 4.8.5 Installation
#   Firewall CSF installation/configuration

# run as root

# update march 23 2020. This wowza version runs on Java 9+
# release notes: https://www.wowza.com/resources/README.html


## Wowza Streaming Engine 4.7.8 and later is built on Java 9
# Ubuntu 18.04 default supports 11
# note: newer versions are not supported (yet)
# ##############
# https://linuxize.com/post/install-java-on-ubuntu-18-04/

echo "Install Java 11 + Wowza Streaming Engine 4.8.5 + CSF Firewall"
#update 
clear
echo "update your system"
sleep 2

apt-get -y update && apt-get -y upgrade

#install java
clear
echo "install Java 11"
sleep 2

apt install -y default-jdk

echo "check java version"
java -version
sleep 2

# get java path
update-alternatives --list java

# configure to use the new openjdk as default
# default dir: /usr/lib/jvm/java-11-openjdk-amd64/bin/java
sleep 2

# create file for java and add content
clear
echo "create file for java and add content and run the file"
sleep 2
echo "# add these lines to it, and save the file
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")" >> /etc/profile.d/jdk11.sh
#run the file

#run the file
source /etc/profile.d/jdk11.sh

#install Wowza
#keep your license key ready. its needed in this installer
clear
echo "time to download wowza"
sleep 2
cd /tmp
wget https://www.wowza.com/downloads/WowzaStreamingEngine-4-8-5/WowzaStreamingEngine-4.8.5-linux-x64-installer.run
chmod +x WowzaStreamingEngine-4.8.5-linux-x64-installer.run

#run installer
clear
echo "keep your license present. You need in this step. A username and password for the wowza backend needs to be set"
echo "You have to press ENTER several times to get through the License agreement"
echo "You also have to set a uername and password"
echo "The installation starts in 5 seconds"
sleep 5
./WowzaStreamingEngine-4.8.5-linux-x64-installer.run

#agree to agreement by pressing enter multiple times | Press [Enter] to continue:
# accept agreement	| Do you accept this agreement? [y/n]:
#set license key	| Please enter your Wowza Streaming Engine License Key.
# Create Administrator Account
# Enter a user name and password that will be used to manage Wowza StreamingEngine.
# User Name: []: 	| name_me
# Password: :		| xxxx
# Confirm Password: | xxxx
# Start Wowza Streaming Engine automatically [Y/n]: y

# Setup is now ready to begin installing Wowza Streaming Engine on your computer.
# Do you want to continue? [Y/n]: y

# after wowza install set correct java version
clear
echo "wowza is installed. Update the Java version for Wowza to use"
sleep 2
rm -rf /usr/local/WowzaStreamingEngine/java
ln -sf /usr/lib/jvm/java-11-openjdk-amd64/ /usr/local/WowzaStreamingEngine/java

#and restart everything
clear
echo "restart wowza services"
sleep 1
service WowzaStreamingEngine restart
service WowzaStreamingEngineManager restart

#install csf firewall
clear
echo "CSF firewall be installed and configured"
sleep 2
ufw disable

apt-get -y install libwww-perl
cd /tmp
wget https://download.configserver.com/csf.tgz
tar -xzf csf.tgz
cd csf
bash install.sh

perl /usr/local/csf/bin/csftest.pl

#firewall replace ports
#get your current ssh port, which will be set in the firewall rules
SSH_PORT="$(grep Port /etc/ssh/sshd_config | awk 'NR==1{print $2}')"
echo "your current ssh port wil be set in the firewall rules:" $SSH_PORT

sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf
sed -i 's/TCP_IN.*/TCP_IN = "'$SSH_PORT',53,80,443,554,1935,8084:8088,8090"/' /etc/csf/csf.conf
sed -i 's/TCP_OUT.*/TCP_OUT = "53,80,113,443,554,1935"/g' /etc/csf/csf.conf
sed -i 's/UDP_IN.*/UDP_IN = "53,6790:9999"/g' /etc/csf/csf.conf
sed -i 's/UDP_OUT.*/UDP_OUT = "53"/g' /etc/csf/csf.conf

#restart firewall
clear
echo "CSF firewall installed. Restart firewall services to save changes"
sleep 2
csf -x
csf -e

service WowzaStreamingEngine restart
service WowzaStreamingEngineManager restart

# single network adapter
#CURRENT_IP="$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')"

# if more then 1 adapter
CURRENT_IP="$(ip -4 addr show ens160 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"

clear
echo "see below for the url to login to wowza"
sleep 2

echo "Make sure to reboot your server to check if everything is working"
echo "Your wowza instance can be reached at: http://$CURRENT_IP:8088/enginemanager"

echo "## installation is done"
echo "In wowza EngineManager check Server > Performance Tuning and check if the Java version is version 11."
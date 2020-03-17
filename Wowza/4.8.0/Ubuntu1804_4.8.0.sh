#!/bin/bash

# Date: 2020-03-17
# Author: J. van Marion / jeroen@vanmarion.nl
# Version: 2.0

# Wowza installer 4.8.0 for Ubuntu 18.04.4
# Including: 
#   Java OpenJDK 12 Installation
#   Wowza 4.8.0 Installation
#   Firewall CSF installation/configuration

# run with sudo

# update march 13 2020. This wowza version runs on Java 9+
# release notes: https://www.wowza.com/resources/README.html


## Wowza Streaming Engine 4.7.8 and later is built on Java 9 (OpenJDK Java SE JRE 9.0.4) and supports Java versions 9 - 12. 
## Earlier versions of Java aren't supported. 
# ubuntu 18.04 official repository only supports Openjdk 11. You can get the Openjdk version 12 here: https://jdk.java.net/archive/

# used in the installer 12 GA (build 12+33): https://download.java.net/java/GA/jdk12/33/GPL/openjdk-12_linux-x64_bin.tar.gz
# note: newer versions are not supported
# ##############

echo "Intall Wowza Streaming Engine 4.8.0"
JavaUrl="https://download.java.net/java/GA/jdk12/33/GPL/openjdk-12_linux-x64_bin.tar.gz"

#update 
clear
echo "update your system"
sleep 2

apt-get -y update && apt-get -y upgrade

#install java
clear
echo "install java OpenJDK 12"
sleep 2
cd /tmp
wget $JavaUrl

tar -xzvf openjdk-12_linux-x64_bin.tar.gz
#rm -R /usr/lib/jvm/java-8-oracle 
mkdir -p /usr/lib/jvm/openjdk-12
mv jdk-12/* /usr/lib/jvm/openjdk-12
chown -R root:root /usr/lib/jvm/openjdk-12

# configure to use the new openjdk as default
#sleep 2
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/openjdk-12/bin/java 1
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/openjdk-12/bin/javac 1

# create file for java default path and add content
clear
echo "create file for java and add content and run the file"
sleep 2
echo "# add these lines to it, and save the file
export JAVA_HOME=/usr/lib/jvm/openjdk-12
export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile.d/jdk12.sh

#run the file
source /etc/profile.d/jdk12.sh

#check java version
clear
echo "the installed java version"
java -version
sleep 2

#install Wowza
#keep your license key ready. its needed in this installer
clear
echo "time to download wowza"
sleep 2
cd /tmp
wget https://www.wowza.com/downloads/WowzaStreamingEngine-4-8-0/WowzaStreamingEngine-4.8.0-linux-x64-installer.run
chmod +x WowzaStreamingEngine-4.8.0-linux-x64-installer.run

#run installer
clear
echo "keep your license present. You need in this step. A username and password for the wowza backend needs to be set"
echo "You have to press ENTER several times to get through the License agreement"
echo "You also have to set a uername and password"
echo "The installation starts in 5 seconds"
sleep 5
./WowzaStreamingEngine-4.8.0-linux-x64-installer.run

#agree to agreement by pressing enter multiple times 	| Press [Enter] to continue:
# accept agreement										| Do you accept this agreement? [y/n]:
#set license key										| Please enter your Wowza Streaming Engine License Key.
# Create Administrator Account
# Enter a user name and password that will be used to manage Wowza StreamingEngine.
# User Name: []: 										| name_me
# Password: :											| xxxx
# Confirm Password: :									| xxxx
# Start Wowza Streaming Engine automatically [Y/n]: 	| y

# Setup is now ready to begin installing Wowza Streaming Engine on your computer.
# Do you want to continue? [Y/n]: 						| y

# after wowza install set correct java version
clear
echo "wowza is installed. Set the java version to OpenJDK 12"
sleep 2
rm -rf /usr/local/WowzaStreamingEngine/java
ln -sf /usr/lib/jvm/openjdk-12/ /usr/local/WowzaStreamingEngine/java

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
sed -i 's/TCP_IN.*/TCP_IN = "'$SSH_PORT',53,80,443,554,1935,8084:8088"/' /etc/csf/csf.conf
sed -i 's/TCP_OUT.*/TCP_OUT = "53,80,113,443,554,1935,554"/g' /etc/csf/csf.conf
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

CURRENT_IP="$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')"
clear
echo "see below for the url to login to wowza"
sleep 2

echo "Make sure to reboot your server to check if everything is working"
echo "Your wowza instance can be reached at: http://$CURRENT_IP:8088/enginemanager"

echo "## installation is done"
echo "In wowza EngineManager check Server > Performance Tuning and check if the Java version is version 12."

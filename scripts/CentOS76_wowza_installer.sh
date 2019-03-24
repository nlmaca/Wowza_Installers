#!/bin/bash

# Date: 2019-03-24
# Author: J. van Marion / jeroen@vanmarion.nl
# Version: 1.0

# Wowza installer for CentOS 7.6
# Including: Java 8 Installation, Firewall CSF installation/configuration

# filename: CentOS76_wowza_installer.sh
# run as: root user

# ##############
# Input data
echo "get the latest (Linux) download version: https://www.wowza.com/pricing/installer"
echo "example url: https://www.wowza.com/downloads/WowzaStreamingEngine-4-7-7/WowzaStreamingEngine-4.7.7-linux-x64-installer.run "

read -p 'Wowza downloadlink (Linux): ' DownloadUrl
FileName="${DownloadUrl##*/}"

JavaUrl="https://vanmarion.nl/software/java/jdk-8u202-linux-x64.tar.gz"

# install necessary packages (wget, vim, perl, perl-Time-HiRes)
yum install wget vim perl-libwww-perl.noarch perl-Time-HiRes  -y

#update 
#clear
echo "update your system"
sleep 2

yum update -y

#install java
#clear
echo "install java 8u202"
sleep 2
cd /tmp
wget $JavaUrl

tar -xzvf jdk-8u202-linux-x64.tar.gz
rm -Rf /usr/lib/jvm/java-8-oracle -y
mkdir -p /usr/lib/jvm/java-8-oracle
mv jdk1.8.0_202/* /usr/lib/jvm/java-8-oracle
chown -R root:root /usr/lib/jvm/java-8-oracle

#set java as default
#clear
echo "set java as default"
sleep 2
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-oracle/jre/bin/java 1091
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-8-oracle/bin/javac 1091

# create file for java and add content
#clear
echo "create file for java and add content and run the file"
sleep 2
echo "# add these lines to it, and save the file
export J2SDKDIR=/usr/lib/jvm/java-8-oracle
export J2REDIR=/usr/lib/jvm/java-8-oracle/jre
export PATH=$PATH:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/db/bin:/usr/lib/jvm/java-8-oracle/jre/bin
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export DERBY_HOME=/usr/lib/jvm/java-8-oracle/db" >> /etc/profile.d/jdk.sh

#run the file
source /etc/profile.d/jdk.sh

#check java version
#clear
echo "the installed java version"
java -version
sleep 2

#install Wowza
#keep your license key ready. its needed in this installer
#clear
echo "time to download wowza"
sleep 2
cd /tmp
wget $DownloadUrl
chmod +x $FileName

#run installer
#clear
echo "keep your license present. You need in this step. A username and password for the wowza backend needs to be set"
echo "You have to press ENTER several times to get through the License agreement"
echo "You also have to set a uername and password"
echo "The installation starts in 5 seconds"
sleep 5
./$FileName

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
#clear
echo "wowza is installed. Set the java version to the 8u202"
sleep 2
rm -rf /usr/local/WowzaStreamingEngine/java
ln -sf /usr/lib/jvm/java-8-oracle/ /usr/local/WowzaStreamingEngine/java

#and restart everything
#clear
echo "restart wowza services"
sleep 1
service WowzaStreamingEngine restart
service WowzaStreamingEngineManager restart

#install csf firewall
#clear
echo "CSF firewall be installed and configured"
sleep 2
systemctl stop firewalld
systemctl disable firewalld

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
#clear
echo "CSF firewall installed. Restart firewall services to save changes"
sleep 2
csf -x
csf -e

service WowzaStreamingEngine restart
service WowzaStreamingEngineManager restart

CURRENT_IP="$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')"
#clear
echo "see below for the url to login to wowza"
sleep 2

echo "Make sure to reboot your server to check if everything is working"
echo "Your wowza instance can be reached at: http://$CURRENT_IP:8088/enginemanager"

echo "## installation is done"

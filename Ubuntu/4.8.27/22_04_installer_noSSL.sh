#!/bin/bash

# Date                              : 2024-04-20
# Author                            : J. van Marion / jeroen@vanmarion.nl
# Version                           : 1.0
# Wowza latest production release   : Wowza Streaming Engine 4.8.17+
# Release notes                     : https://www.wowza.com/docs/wowza-streaming-engine-4-8-27-release-notes
# OS version                        : Ubuntu 22.04 LTS / Ubuntu 23.04

# Software installation including: 
  # Firewall CSF installation/configuration
  # Java 11 OpenJDK Installation
  # No SSL

# Requirements: valid license (trial or enterprise)

# run as root or with sudo privileges

# in case you want to run it as a sudo user.
# $: adduser USERNAME
# set a password
# add the user to the sudo list
# $: usermod -aG sudo USERNAME
# switch to that user.
# $: su - USERNAME
# run the wowza installer as sudo bash 22_04_installer_noSSL.sh


# NOTE: 
# when adding a domainname to your server, make sure to add the domainname to your /etc/hosts file otherwise the wowza enginemanager won't let you login

echo "Install Java 11 + Wowza Streaming Engine 4.8.27+5 including CSF Firewall"
#update 
clear
echo "update your system"
sleep 2

apt -y update && apt -y upgrade

#install java
clear
echo "install Java 11"
sleep 2

apt -y install default-jdk

echo "check java version"
javac -version
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
source /etc/profile.d/jdk11.sh

#install Wowza
#keep your license key ready. its needed in this installer
clear
echo "time to download wowza"
sleep 2
cd /tmp
wget https://www.wowza.com/downloads/WowzaStreamingEngine-4-8-27+5/WowzaStreamingEngine-4.8.27+5-linux-x64-installer.run
chmod +x WowzaStreamingEngine-4.8.27+5-linux-x64-installer.run

#run installer
clear
echo "keep your license present. You need in this step. A username and password for the wowza backend needs to be set"
echo "You have to press ENTER several times to get through the License agreement"
echo "You also have to set a uername and password"
echo "The installation starts in 5 seconds"
sleep 5
./WowzaStreamingEngine-4.8.27+5-linux-x64-installer.run

#agree to agreement by pressing enter multiple times | Press [Enter] to continue:
# accept agreement	| Do you accept this agreement? [y/n]:
# set license key	| Please enter your Wowza Streaming Engine License Key.
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

apt -y install libwww-perl
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
sed -i 's/RESTRICT_SYSLOG = "0"/RESTRICT_SYSLOG = "3"/g' /etc/csf/csf.conf
sed -i 's/TCP_IN.*/TCP_IN = "'$SSH_PORT',53,80,443,554,1935,8084:8088,8090"/' /etc/csf/csf.conf
sed -i 's/TCP_OUT.*/TCP_OUT = "53,80,113,443,554,1935"/g' /etc/csf/csf.conf
sed -i 's/UDP_IN.*/UDP_IN = "53"/g' /etc/csf/csf.conf
sed -i 's/UDP_OUT.*/UDP_OUT = "53"/g' /etc/csf/csf.conf

#sed -i 's/IPV6 = "1"/IPV6 = "0"/g' /etc/csf/csf.conf
#sed -i 's/TCP6_IN.*/TCP6_IN = "'$SSH_PORT',53,80,443,554,1935,8084:8088,8090"/' /etc/csf/csf.conf
#sed -i 's/TCP6_OUT.*/TCP6_OUT = "53,80,113,443,554,1935"/g' /etc/csf/csf.conf
#sed -i 's/UDP6_IN.*/UDP6_IN = "53"/g' /etc/csf/csf.conf
#sed -i 's/UDP6_OUT.*/UDP6_OUT = "53"/g' /etc/csf/csf.conf


# CSF warning: *WARNING* Binary location for [SENDMAIL] [/usr/sbin/sendmail] in /etc/csf/csf.conf is either incorrect, is not installed or is not executable
echo '#!/bin/sh' > /usr/sbin/sendmail
chmod +x /usr/sbin/sendmail

# CSF warning: *WARNING* Binary location for [UNZIP] [/usr/bin/unzip] in /etc/csf/csf.conf is either incorrect, is not installed or is not executable
apt -y install zip unzip

# restart firewall
echo "CSF firewall installed. Restart firewall services to save changes"
sleep 2
csf -r

# Restart wowza services again
service WowzaStreamingEngine restart
service WowzaStreamingEngineManager restart

# single network adapter
CURRENT_IP="$(hostname -I)"

echo "see below for the url to login to wowza"
sleep 2

echo "Make sure to reboot your server to check if everything is working"
echo "Your wowza instance can be reached at: http://$CURRENT_IP:8088/enginemanager"

echo "## installation is done"
echo "In wowza EngineManager check Server > Performance Tuning and check if the Java version is version 11."
#!/bin/bash

# Date: 2021-02-08
# Author: J. van Marion / jeroen@vanmarion.nl
# Version: 2.0

# Wowza installer for CentOS_7.x / requested by user.
# Including: Java 11 Installation, Firewall CSF installation/configuration

# filename: CentOS_7.x
# run as: normal user with sudo (administrator privileges needed)
# command: bash CentOS_7.x.sh

# ##############

echo "Intall Wowza Streaming Engine 4.8.8.01"

#JavaUrl="https://vanmarion.nl/software/java/jdk-8u202-linux-x64.tar.gz"

# install necessary packages (wget, vim, perl, perl-Time-HiRes)
sudo yum install wget vim perl-libwww-perl.noarch perl-Time-HiRes  -y

#update 
#clear
echo "update your system"
sleep 2

sudo yum update -y

#install java
#clear
echo "install java 11"
sleep 2
cd /tmp
sudo yum install java-11-openjdk-devel -y


#set java as default
#clear
echo "set java as default"
sleep 2
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-11-openjdk-11.0.7.10-4.el7_8.x86_64/bin/java 1


# create file for java and add content
#clear
echo "create file for java and add content and run the file"
sleep 2

sudo sh -c "echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >> /etc/profile.d/jdk11.sh"


#run the file
sudo -s source /etc/profile.d/jdk11.sh

#check java version
#clear
echo "the installed java version"
java -version
# openjdk version "11.0.7" 2020-04-14 LTS

sleep 2

#install Wowza
#keep your license key ready. its needed in this installer
#clear
echo "time to download wowza"
sleep 2
cd /tmp
wget https://www.wowza.com/downloads/WowzaStreamingEngine-4-8-8-01/WowzaStreamingEngine-4.8.8.01-linux-x64-installer.run
chmod +x WowzaStreamingEngine-4.8.8.01-linux-x64-installer.run

#run installer
#clear
echo "keep your license present. You need in this step. A username and password for the wowza backend needs to be set"
echo "You have to press ENTER several times to get through the License agreement"
echo "You also have to set a uername and password"
echo "The installation starts in 5 seconds"
sleep 5
sudo ./WowzaStreamingEngine-4.8.8.01-linux-x64-installer.run

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
echo "wowza is installed. Set the java version to the one we have installed"
sleep 2
sudo rm -rf /usr/local/WowzaStreamingEngine/java
sudo ln -sf /usr/lib/jvm/java-11-openjdk-11.0.7.10-4.el7_8.x86_64/ /usr/local/WowzaStreamingEngine/java

#and restart everything
#clear
echo "restart wowza services"
sleep 1
sudo service WowzaStreamingEngine restart
sudo service WowzaStreamingEngineManager restart

#install csf firewall
#clear
echo "CSF firewall be installed and configured"
sleep 2
sudo systemctl stop firewalld
sudo systemctl disable firewalld

cd /tmp
wget https://download.configserver.com/csf.tgz
sudo tar -xzf csf.tgz
cd csf
sudo bash install.sh

sudo perl /usr/local/csf/bin/csftest.pl

#firewall replace ports
#get your current ssh port, which will be set in the firewall rules
SSH_PORT="$(sudo grep Port /etc/ssh/sshd_config | awk 'NR==1{print $2}')"
echo "your current ssh port wil be set in the firewall rules:" $SSH_PORT

sudo sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf
sudo sed -i 's/TCP_IN.*/TCP_IN = "'$SSH_PORT',53,80,443,554,1935,8084:8088,8090"/' /etc/csf/csf.conf
sudo sed -i 's/TCP_OUT.*/TCP_OUT = "53,80,113,443,554,1935"/g' /etc/csf/csf.conf
sudo sed -i 's/UDP_IN.*/UDP_IN = "53,6790:9999"/g' /etc/csf/csf.conf
sudo sed -i 's/UDP_OUT.*/UDP_OUT = "53"/g' /etc/csf/csf.conf

#restart firewall
#clear
echo "CSF firewall installed. Restart firewall services to save changes"
sleep 2
sudo csf -x
sudo csf -e

sudo service WowzaStreamingEngine restart
sudo service WowzaStreamingEngineManager restart

CURRENT_IP="$(ip route get $(ip route show 0.0.0.0/0 | grep -oP 'via \K\S+') | grep -oP 'src \K\S+')"
#clear
echo "see below for the url to login to wowza"
sleep 2

echo "Make sure to reboot your server to check if everything is working"
echo "Check if you see the wowza version in this url:"
echo "Your wowza instance can be reached at: http://$CURRENT_IP:8088/enginemanager"
echo "Check wowza backend if Correct java version is installed: Server > About"
echo "## installation is done"
echo "if you have any errors and wowza is not starting, check the wowza errorlogs in: /usr/local/WowzaStreamingEngine/logs/wowzastreamingengine_error.log"

#!/bin/bash

# Date: 2021-02-17
# Author: J. van Marion / jeroen@vanmarion.nl
# Version: 1.0

# reference: https://www.wowza.com/docs/how-to-update-your-wowza-streaming-engine-installation#instructions
# Important: Do not delete the WowzaStreamingEngine-Update-[version].zip file. You'll need it if you want to remove the update later. 
# Only that version of the update tool will remove that version of the update. 

# This upgrade will NOT remove your current Java version. You need it if you want to restore your upgrade. 
# Java 11 will be set with a symlink.

# Todo: how to restore an upgrade. https://www.wowza.com/docs/how-to-update-your-wowza-streaming-engine-installation#uninstall_update

# Wowza installer 4.8.5 for Ubuntu 18.04.4
# Including: 
# Upgrade your wowza to 4.8.9
# Upgrade Java 1.8.x to Java 11

# run as root or as sudo (user needs to be present in visudo)
# sshUser ALL=(ALL:ALL)ALL

echo "Stop current wowza services"
sleep 2
sudo service WowzaStreamingEngine stop
sudo service WowzaStreamingEngineManager stop

echo "Install unzip"
sudo apt-get install unzip -y

echo "Install Java OpenJDK 11"
sudo apt install -y default-jdk

echo "check java version"
java -version
sleep 2


# get java path
update-alternatives --list java

# configure to use the new openjdk as default
# default dir: /usr/lib/jvm/java-11-openjdk-amd64/bin/java
sleep 2

# create file for java and add content

echo "create file for java and add content and run the file"
sleep 2
echo "# add these lines to it, and save the file
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")" >> /etc/profile.d/jdk11.sh
#run the file

source /etc/profile.d/jdk11.sh

echo "Download and install unzip"
sleep 1
sudo apt-get install unzip -y

echo "Download Wowza update file to tmp folder"
cd /tmp
sudo wget http://vanmarion.nl/projects/wowza/WowzaStreamingEngine-Update-4.8.9.zip

echo "unzip the file to the wowza update folder"
sudo unzip WowzaStreamingEngine-Update-4.8.9.zip -d /usr/local/WowzaStreamingEngine/updates/WowzaStreamingEngine-Update-4.8.9

echo "navigate to the linux update folder"
cd /usr/local/WowzaStreamingEngine/updates/WowzaStreamingEngine-Update-4.8.9/linux

echo "Remove current Java symlink and set it to new version"
sudo rm -rf /usr/local/WowzaStreamingEngine/java
sudo ln -sf /usr/lib/jvm/java-11-openjdk-amd64/ /usr/local/WowzaStreamingEngine/java


echo "run the update installer. a backup will be created automaticly"
chmod +x update.sh
sudo bash update.sh

# This will update your installation at: /usr/local/WowzaStreamingEngine-4.7.7
# Currently installed version           : Wowza Streaming Engine 4.7.7 - Build 20181108145350
# This will update your installation to : Wowza Streaming Engine 4.8.9 - Build 20201221171606
# Are you sure you want to continue? (y/n)

echo "Restart wowza services"
#and restart everything
clear
echo "restart wowza services"
sleep 1
sudo service WowzaStreamingEngine restart
sudo service WowzaStreamingEngineManager restart

sleep 2
echo "Login to your wowza backend. And check if your Wowza version is updated and the java version is updated in Server > About"
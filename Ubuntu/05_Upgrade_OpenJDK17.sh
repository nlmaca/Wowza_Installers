#!/bin/bash

# Date: 2023-06-18
# Author: J. van Marion / jeroen@vanmarion.nl
# Version: 1.1

# reference: https://www.wowza.com/docs/how-to-update-your-wowza-streaming-engine-installation#instructions
# Important: Do not delete the WowzaStreamingEngine-Update-[version].zip file. You'll need it if you want to remove the update later. 
# Only that version of the update tool will remove that version of the update. 

# This upgrade will NOT remove your current Java version. You need it if you want to restore your upgrade. 
# Java 11 will be set with a symlink.

# Todo: how to restore an upgrade. https://www.wowza.com/docs/how-to-update-your-wowza-streaming-engine-installation#uninstall_update

# Wowza installer 4.8.5 for Ubuntu 18.04.4
# Including: 
# Upgrade your wowza to 4.8.23+2
# Upgrade Java OpenJDK 11 to OpenJDK 17

# run as root or as sudo (user needs to be present in visudo)
# sshUser ALL=(ALL:ALL)ALL

echo "Step: Stop the Wowza Engine and EngineManager" 
sleep 2

sudo service WowzaStreamingEngine stop
sudo service WowzaStreamingEngineManager stop

clear

echo "Step: Remove current java 11.0.19 version" 
sleep 2
sudo apt autoremove opendjk-11-jre
clear

echo "Step: install Java OpenJDK 17" 
sleep 2
sudo apt -y install openjdk-17-jdk
echo "check java version again"
java -version
sleep 2

# get java path
update-alternatives --list java
# configure to use the new openjdk as default
# default dir: /usr/lib/jvm/java-11-openjdk-amd64/bin/java
clear
echo "build and execute pathfile" 
sleep 2

echo "# add these lines to it, and save the file
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")" >> /etc/profile.d/jdk17.sh
#run the file
source /etc/profile.d/jdk17.sh
clear

echo "Step: download and install zip"
sleep 2
sudo apt-get install unzip -y
clear

echo "Step: Download WowzaStreamingEngine-Update-4.8.23+2, extract and copy to wowza folder"
sleep 2
cd /tmp
sudo wget http://vanmarion.nl/projects/wowza/patches/WowzaStreamingEngine-Update-4.8.23+2.zip
sudo unzip WowzaStreamingEngine-Update-4.8.23+2.zip -d /usr/local/WowzaStreamingEngine/updates/WowzaStreamingEngine-Update-4.8.23+2
echo "Remove current Java symlink and set it to new version"
sleep 1
sudo rm -rf /usr/local/WowzaStreamingEngine/java
sudo ln -sf /usr/lib/jvm/java-17-openjdk-amd64/ /usr/local/WowzaStreamingEngine/java
clear

cd /usr/local/WowzaStreamingEngine/updates/WowzaStreamingEngine-Update-4.8.23+2/linux
clear

echo "In the following steps Wowza will warn you that only until Java 11 and 12 testing has been done. Some questions will be asked. Press Y to confirm them. A backup will automatically be created" 
sleep 2

echo "Step: The upgrade will start. A backup will automatically be created"
chmod +x update.sh
sudo bash update.sh

# This will update your installation at: /usr/local/WowzaStreamingEngine-4.7.7
# Currently installed version           : Wowza Streaming Engine 4.7.7 - Build 20181108145350
# This will update your installation to : Wowza Streaming Engine 4.8.9 - Build 20201221171606
# Are you sure you want to continue? (y/n)

# You will see a notice
#Found Java version: '17.0.7' at path: '../../../java/bin/java'
#Only Java 11 - 12 have been tested and any Java versions above 12 will be used at your own risk.
#Do you want to progress with this Java version? Proceed [Y/n]

# This will update your installation at: /usr/local/WowzaStreamingEngine-4.8.17+1
# Currently installed version           : Wowza Streaming Engine 4.8.17+1 - Build 20211216162410
# This will update your installation to : Wowza Streaming Engine 4.8.23+2 - Build 20230519113009

echo "Restart wowza services"
#and restart everything
clear
echo "restart wowza services"
sleep 1
sudo service WowzaStreamingEngine restart
sudo service WowzaStreamingEngineManager restart

sleep 2
# single network adapter (trim whitespace after result)
CURRENT_IP="$(hostname -I | xargs)"

echo "Make sure to reboot your server to check if everything is working"
echo "Your wowza instance can be reached at: http://$CURRENT_IP:8088/enginemanager"

echo "## installation is done"
echo "In wowza EngineManager check Server > About and check if the Java version is version 17."
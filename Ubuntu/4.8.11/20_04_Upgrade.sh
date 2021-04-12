#!/bin/bash

# Date: 2021-04-12
# Author: J. van Marion / jeroen@vanmarion.nl
# Version: 1.0
# Type: auto installer/updater

# Requirements
#- Java 9+ or 11 installed
#- SSL optional
# At least version 4.8.9 is required. If you are running on a older version update to 4.8.9 first!!

# Some notes
#* This upgrade will NOT remove your current Java version.
#* This upgrade does NOT contain a java Update. So if you are still running on Java version below 9, you need to upgrade Java first!
#* The Wowza update can be downloaded from the wowza site. For convenience i added it to my website. If you don't trust that, change the download link to your choice to receive the update file. You can find it in your wowza (account) download section. 
 

# run as root or as sudo (user needs to be present in visudo)
# sshUser ALL=(ALL:ALL)ALL

echo "Stop current wowza services"
sleep 2
sudo service WowzaStreamingEngine stop
sudo service WowzaStreamingEngineManager stop

# Install unzip
echo "Install unzip"
sudo apt-get install unzip -y

# Download the wowza update file
echo "Download Wowza update file to tmp folder"
cd /tmp
sudo wget https://vanmarion.nl/projects/wowza/WowzaStreamingEngine-Update-4.8.11+5.zip

echo "unzip the file to the wowza update folder"
sudo unzip WowzaStreamingEngine-Update-4.8.11+5.zip -d /usr/local/WowzaStreamingEngine/updates/WowzaStreamingEngine-Update-4.8.11+5

echo "navigate to the linux update folder"
cd /usr/local/WowzaStreamingEngine/updates/WowzaStreamingEngine-Update-4.8.11+5/linux

# Run the installer
echo "run the update installer. a backup will be created automaticly"
chmod +x update.sh
sudo bash update.sh

# This will update your installation at: /usr/local/xxxx
# Currently installed version           : Wowza Streaming Engine 4.8.9 - Build 20201221171606
# This will update your installation to : Wowza Streaming Engine 4.8.11+5 - Build 20210322205002
# Are you sure you want to continue? (y/n)

echo "Restart wowza services"
#and restart everything

echo "restart wowza services"
sleep 1
sudo service WowzaStreamingEngine restart
sudo service WowzaStreamingEngineManager restart

sleep 2
echo "Login to your wowza backend. And check if your Wowza version is updated and the java version is updated in Server > About"
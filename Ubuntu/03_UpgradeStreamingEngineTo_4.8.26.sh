#!/bin/bash

# Date: 2024-03-01
# Author: J. van Marion / jeroen@vanmarion.nl
# Version: 1.0
# Type: auto installer/updater to 4.8.26+4.

# Requirements
#- Java 11 installed
#- SSL: NO

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
sudo wget https://vanmarion.nl/projects/wowza/WowzaStreamingEngine-Update-4.8.26+4.zip

echo "unzip the file to the wowza update folder"
sudo unzip WowzaStreamingEngine-Update-4.8.26+4.zip -d /usr/local/WowzaStreamingEngine/updates/WowzaStreamingEngine-Update-4.8.26+4

echo "navigate to the linux update folder"
cd /usr/local/WowzaStreamingEngine/updates/WowzaStreamingEngine-Update-4.8.26+4/linux

# Run the installer
echo "run the update installer. a backup will be created automaticly"
chmod +x update.sh
sudo bash update.sh

# This will update your installation at: /usr/local/xxxx
# Currently installed version           : Wowza Streaming Engine 4.8.x - Build xxxxx
# This will update your installation to : Wowza Streaming Engine 4.8.26+4 Build 20231212155517
# Are you sure you want to continue? (y/n)

echo "Restart wowza services"
#and restart everything

echo "restart wowza services"
sleep 1
sudo service WowzaStreamingEngine restart
sudo service WowzaStreamingEngineManager restart

sleep 2
echo "Login to your wowza backend. Navigate to Server > About and check if your Wowza version is upgraded to 4.8.26+4"
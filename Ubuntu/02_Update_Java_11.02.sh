#!/bin/bash

# Date: 2023-06-07
# Author: J. van Marion / jeroen@vanmarion.nl
# Version: 1.0

# This installer will upgrade your current Java version to the custom version 11.0.2 that Wowza provides. 
# A restart of your server is needed.

# The java version can be found in your wowza portal.

# Pre conditions: 
# Wowza StreamingEngine installed which is older then 4.8.23+2 and if your Java version is below 11.x

echo "Step: Stop the Wowza Engine and EngineManager" 
sleep 2

sudo service WowzaStreamingEngine stop
sudo service WowzaStreamingEngineManager stop

clear
echo "Download custom Java package from website" 
cd /tmp
wget https://vanmarion.nl/projects/wowza/patches/jre-11.0.2-http.zip

echo "Unzip package and copy files to java directory (overwrite current one)" 
sudo unzip jre-11.0.2-http.zip -d jre-11.0.2-http
cd /tmp/jre-11.0.2-http/jre/linux-x64

sudo cp -R * /usr/lib/jvm/java-11-openjdk-amd64 --remove-destination

echo "Wowza services will be started again" 
sudo service WowzaStreamingEngine start
sudo service WowzaStreamingEngineManager start

echo "The server will reboot in 5 seconds. After that login to your server again and check the java version in your Wowza server. It should now be set to 11.02" 
sleep 5
reboot

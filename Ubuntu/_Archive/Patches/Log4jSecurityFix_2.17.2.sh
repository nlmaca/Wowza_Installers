#!/bin/bash

# Date                              : 2021-03-11
# Author                            : J. van Marion / jeroen@vanmarion.nl
# Version                           : 1.1
# Wowza patch info                  : https://www.wowza.com/docs/update-for-apache-log4j2-security-vulnerability
#                                   : 
#                                   : https://dlcdn.apache.org/logging/log4j/
#                                   : added the package to my own site. Previous one was deleted at ^^
# OS version                        : Ubuntu 20.04.3 LTS

# Patch information :
# Please check the url for more information
# https://www.wowza.com/docs/update-for-apache-log4j2-security-vulnerability

# Patch reference:
# https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-44832
# https://logging.apache.org/log4j/2.x/

# Requirements: Wowza version higher than 4.8.8.01
# This will impact all log4j files
# This will replace the log4j-core*.jar and log4j-api*.jar file in the wowza configuration
# run as root or with sudo

cd /tmp
echo "Remove old zipfile if exists"
sleep 2

rm -f updatelog4j.zip
rm -rf /usr/local/WowzaStreamingEngine/updates/updatelog4j

rm -f apache-log4j-2.17.2-bin.zip
rm -rf /usr/local/WowzaStreamingEngine/updates/apache-log4j-2.17.2-bin

# install zip and unzip (if you haven't already)
clear
echo "Install zip & unzip on your server"
sleep 2
apt install unzip -y
apt install zip -y

# stop wowzaservices first
clear
echo "We will Stop the wowza services"
sleep 2
service WowzaStreamingEngine stop
service WowzaStreamingEngineManager stop

# Download and unpack patch into update folder
clear
echo "Download the update package and extract it to the Wowza updates folder"
sleep 2
wget https://www.wowza.com/downloads/log4jupdater/updatelog4j.zip
unzip updatelog4j.zip -d /usr/local/WowzaStreamingEngine/updates/updatelog4j

# Download latest Apache fix files and check if file is present
echo "Download Apache 2.17.2 files"
sleep 2
cd /tmp
wget https://vanmarion.nl/projects/wowza/apache-log4j-2.17.2-bin.zip

if [ -f apache-log4j-2.17.2-bin.zip ];
then
    echo "File is succesfully downloaded. Continue the process"
    unzip apache-log4j-2.17.2-bin.zip -d /usr/local/WowzaStreamingEngine/updates/

    # Remove old .jar files. We need new files for the update
    echo "Remove OLD patch jar files form updatelog4j directory"
    sleep 2
    cd /usr/local/WowzaStreamingEngine/updates/updatelog4j
    rm log4j-*.jar

    # Move downloaded files to update folder
    echo "Copy only needed files to Wowza LOG4J update folder"
    cd /usr/local/WowzaStreamingEngine/updates/apache-log4j-2.17.2-bin
    cp log4j-api-2.17.2.jar log4j-core-2.17.2.jar /usr/local/WowzaStreamingEngine/updates/updatelog4j

    # now run the update procedure
    echo "run the Wowza update procedure"
    sleep 2
    cd /usr/local/WowzaStreamingEngine/updates/updatelog4j
    ./updatelog4j.sh


    sleep 2
    echo ""
    echo ""
    echo "Which .jar files have been set for the log4j"
    find /usr/local/WowzaStreamingEngine/lib/ -type f -name "log4j-*.jar" 

    echo "Check the ^^ results"

    echo "Patch is finished. Restart wowza services again"

    sleep 2
    service WowzaStreamingEngine start
    service WowzaStreamingEngineManager start

    echo "Update is finished. Please login to your wowza server to check your instance"

else
    echo "The download url is wrong or the package could not be found."
fi
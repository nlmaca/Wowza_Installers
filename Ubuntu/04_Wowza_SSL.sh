#!/bin/bash

# Date                              : 2023-06-18
# Author                            : J. van Marion / jeroen@vanmarion.nl
# Version                           : 1.1
# Wowza latest production release   : Wowza Streaming Engine 4.8.23+2
# Release notes                     : https://www.wowza.com/docs/wowza-streaming-engine-4-8-17-release-notes
# OS version                        : Ubuntu 22.04.2 LTS

# Requirements: Wowza StreamingEngine 4.8.23+2 installed
# run as root or with sudo privileges
# a DNS adress like wowza.vanmarion.nl so we can enable SSL
# Open Firewall ports: 80,443,8090 (TCP/IN)
# If you ran the installer from my tutorial, SSL is already pre-configured in CSF.

# run installation as sudo:
# bash 04_Wowza_SSL.sh

echo "In order to enable and configure SSL you need to provide a valid DNS name that points to your wowza server (example: vps.vanmarion.nl):"

read domainname

if [ -z "$domainname" ]
then 
    echo "\$domainname is empty. Please enter a valid domainname"
else
    echo "We will continue the setup with:" $domainname
fi

echo "Installing SNAP" 
sleep 2

# install snap
sudo apt install snapd -y
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap

echo "Remove certbot and certbot packages" 
sleep 2

# remove certbot-auto and Certbot packages
sudo apt remove certbot

echo "Install classic certbot using SNAP and create a symlink"
sleep 2

# install certbot
sudo snap install --classic certbot

# if you get an error like this: "error: too early for operation, device not yet seeded or device model not acknowledged"
# then run the command again
sudo snap install --classic certbot

# cereate a symlink
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# create the SSL certificate. Change YOUR-WOWZASERVER-DOMAINNAME to your domain

sudo certbot certonly --standalone -d $domainname --key-type rsa

# Answer some of the questions:
# enter email: set-your-email
# agree TOS(Terms of Service): Y
# Would you be willing, once your first certificate is successfully issued.....: N


# --- installation complete ---
# 
#IMPORTANT NOTES:
# - Congratulations! Your certificate and chain have been saved at:
#   /etc/letsencrypt/live/YOUR-WOWZASERVER-DOMAINNAME/fullchain.pem
#   Your key file has been saved at:
#   /etc/letsencrypt/live/YOUR-WOWZASERVER-DOMAINNAME/privkey.pem
#   Your certificate will expire on 2021-05-13. To obtain a new or
#   tweaked version of this certificate in the future, simply run
#   certbot again. To non-interactively renew *all* of your
#   certificates, run "certbot renew"
# - If you like Certbot, please consider supporting our work by:

# SSL converter 
#- Convert the SSL certificate so we can use it in Wowza. Letsencrypt converter (creation JKS file). 
#- Credits to Robymus: https://github.com/robymus

echo "Download and install the Wowza Letsencrypt converter from Robymus" 
sleep 2

cd /usr/local/WowzaStreamingEngine/lib 
sudo wget https://github.com/robymus/wowza-letsencrypt-converter/releases/download/v0.2/wowza-letsencrypt-converter-0.2.jar

sudo java -jar wowza-letsencrypt-converter-0.2.jar -v /usr/local/WowzaStreamingEngine/conf/ /etc/letsencrypt/live/

# 2 files should have been created. a .jks and a .txt file. Read the txt file and copy the contents in a temporary notepad

cat /usr/local/WowzaStreamingEngine/conf/jksmap.txt

# example output: 

SUB.DOMAIN.EXT={"keyStorePath":"/usr/local/WowzaStreamingEngine/conf/SUB.DOMAIN.EXT.jks", "keyStorePassword":"secret", "keyStoreType":"JKS"}

# We need the jks location and keyStorePassword in the next steps
# Change wowza config file : Enable the 443 Module and change the settings

vi /usr/local/WowzaStreamingEngine/conf/VHost.xml

# Enable 443 Module:
# You will see this line: <!-- 443 with SSL -->
# Remove the <!-- and --> around the start <HostPort> and end <HostPort> tag
# Now search for this Element "SSLConfig" in the same file 

<SSLConfig>
    <KeyStorePath>${com.wowza.wms.context.VHostConfigHome}/conf/keystore.jks</KeyStorePath>
    <KeyStorePassword>[password]</KeyStorePassword>
    <KeyStoreType>JKS</KeyStoreType>
    <DomainToKeyStoreMapPath></DomainToKeyStoreMapPath>
    <SSLProtocol>TLS</SSLProtocol>
    <Algorithm>SunX509</Algorithm>
    <CipherSuites></CipherSuites>
    <Protocols></Protocols>
</SSLConfig>

# Change only the keyStorePath and keyStorePassword to the ones from the jks file (see previous step). The rest doesn't have to be changed

<SSLConfig>
    <KeyStorePath>${com.wowza.wms.context.VHostConfigHome}/conf/SUB.DOMAIN.EXT.jks</KeyStorePath>
    <KeyStorePassword>secret</KeyStorePassword>
    <KeyStoreType>JKS</KeyStoreType>
    <DomainToKeyStoreMapPath></DomainToKeyStoreMapPath>
    <SSLProtocol>TLS</SSLProtocol>
    <Algorithm>SunX509</Algorithm>
    <CipherSuites></CipherSuites>
    <Protocols></Protocols>
    <AllowHttp2>false</AllowHttp2>
</SSLConfig>

# Save the File
# Enable backend for SSL 
# Open the tomcat.properties file in the manager section

vi /usr/local/WowzaStreamingEngine/manager/conf/tomcat.properties

# Uncomment the first 3 lines and change the value of httpsKeyStore and httpsKeyStorePassword

#httpsPort=8090
#httpsKeyStore=conf/certificate.jks
#httpsKeyStorePassword=[password]
#httpsKeyAlias=[key-alias]

# TO:

httpsPort=8090
httpsKeyStore=/usr/local/WowzaStreamingEngine/conf/SUB.DOMAIN.EXT.jks
httpsKeyStorePassword=secret
#httpsKeyAlias=[key-alias]
```
- Installation is done. Time to restart Wowza.
```
service WowzaStreamingEngineManager restart
service WowzaStreamingEngine restart
```
The configuration is almost done.
# Open the SSL Link EngineManager from your browser
```
https://YOUR-WOWZADOMAIN:8090/enginemanager
```
This should show you the page in https.

# Check Virtual Host setup
Go to your wowza engineManager (browser)
Go to Server > Virtual Host Setup
Edit Virtual Host Setup > Add Host port
```
Name: SSL streaming
Type: Streaming
Ip Address: *
Ports: 443
```
- enable SSL / streamlock and place the jks path / and set the password to: 
```
secret
```
- Note if you want port 1935 to use SSL, do the same thing as for port 443

Save and restart the Vhost setup. 
Playback url (vlc, jwplayer, flowplayer, hls, etc)
```
https://SUB.DOMAIN.EXT:1935/vod/mp4:sample.mp4/playlist.m3u8
https://SUB.DOMAIN.EXT/vod/mp4:sample.mp4/playlist.m3u8
```

# The End :D

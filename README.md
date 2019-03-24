# Wowza_Installers
I got tired to run the same commands over and over again when i was testing with wowza. So i made an installer for it. 
The installer will install Java 8u202, CSF firewall including the necessary ports, It will also add the java version to Wowza.
In this repository i might other scripts i use within wowza

# references
* Reference: https://www.wowza.com/docs/how-to-troubleshoot-wowza-streaming-engine-installation#network
* Reference: https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-config-server-firewall-csf-on-ubuntu
* Request Wowza trial: https://www.wowza.com/media-server/developers/license
* Java: https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html

1. Ubuntu 18.04 Installer
2. CentOS 7.6 installer

# What will be installed
* system will be updated & upgraded
* Java 8u202 will be installed and connected to Wowza
* Basic Wowza Streaming Engine will be installed
* CSF (Firewall) be installed & automatic configured with the ports needed including your ssh port

# Demo installation
in progress

# Firewall ports that will be set
```
Port 53: Domain name system (DNS)
Port 80: Hypertext transfer protocol (HTTP)
Port 113: Authentication service/identification protocol
Port 123: Network time protocol (NTP)

Port SSH_PORT: your current ssh port will be set in CSF
SKIP Ports: 137/138/139/445 - samba ports.

#Wowza Ports
#TCP IN:
Port 1935	    : RTMP (all variants), RTSP, Microsoft Smooth Streaming, Apple HLS, MPEG-DASH, HDS, WOWZ
Port 8084-8085  : JMX/JConsole monitoring and administration
Port 8086-8087  : HTTP Administrator
Port 8088		: Wowza Streaming Engine Manager
Port 554		: RTSP
Port 443		: SSL Connections
Port 80		    : Licensing server connections / 

UDP IN			
Port 6790-9999  : UDP incoming streams
```

# Ubuntu Server (18.04) / CentOS server (7.6)
The installer scripts have both been tested on fresh installations

# Java 8u202
I have added the java file on my own domain. You can't download it straight from oracle anymore. You can download the file yourself and change the location if needed in the script.
search for JavaUrl on line 21

# Prerequisites
* Install a basic Ubuntu 18.04 or CentOS 7.6 server
* Make sure you have your network set and run ssh on the port you want.


# Wowza installer
The script will ask for the latest download url. You can copy the Linux url (right click on download button) from here:
https://www.wowza.com/pricing/installer

# Installation
* 1. Get a developer license : https://www.wowza.com/media-server/developers/license
* 2. In the installation proces you have to hit Enter around 60 times for the license agreement (just hold it will also work)
* 3. Login via ssh to your server.
* 4. Dowwnload the installer of your choice (get the raw content)
* 5. run the script with sudo ./installer_script

Several questions will be asked
- Set a username and paswword for your wowza backend (weblogin)
- Answer the other questions with: Y
```
Enter a user name and password that will be used to manage Wowza Streaming
Engine.
User Name: []: wowza

Password: :
Confirm Password: :
Note: User Name and Password are case-sensitive.
----------------------------------------------------------------------------
Startup Configuration

Start Wowza Streaming Engine automatically [Y/n]: y

Clear the check box to start Wowza Streaming Engine manually.

----------------------------------------------------------------------------
Setup is now ready to begin installing Wowza Streaming Engine on your computer.

Do you want to continue? [Y/n]: y
```


# Enjoy!
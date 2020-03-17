# Wowza Installers
I got tired to run the same commands over and over again when i was testing with wowza. So i made some installers for it.
I mainly focus on Ubuntu setups, although i have made an 4.7.7 installer for CentOS 7.6

# Update march 17 2020
- New ubuntu 18.04.x + Wowza StreamingEngine 4.8.0 incl java OpenJDK 12
- Wowza 4.8.0 requires a minimum of Java version 9.4.0
- CSF firewall including the necessary ports, It will also add the java version to Wowza.

# Upgrade scripts?
I am also working on upgrade scripts from wowza 4.7.7 to 4.8.0 including the java update. I base this upgrades on my previous installers. 

# Wowza developer license limitations
- This will have limitations on 1 input stream and max 10 output streams

# Prerequisites
- A fresh installed ubuntu 18.04.x server with ssh support
- Get a developer license : https://www.wowza.com/media-server/developers/license
- If you have an enterprise license, you can use that one. Check with Wowza Support if your license is valid for the next version.

# Java resources
- OpenJDK archive: https://jdk.java.net/archive/

# Fresh Installers so far.
1. Ubuntu 18.04.x Installer - 4..8.0         / OpenJDK Java 12
2. Ubuntu 18.04.x Installer - Wowza 4.7.7    / Oracle Java JDK 8u202
3. CentOS 7.6 Installer - Wowza 4.7.7        / Oracle Java JDK 8u202

# Todo: upgrade installer from 4.7.7 > 4.8.0
# Todo: restore installer update to previous version (in case of update failure)

# What will be installed
* system will be updated & upgraded
* Java will be installed and connected to Wowza
* Basic Wowza Streaming Engine will be installed
* CSF (Firewall) be installed & automatic configured with the ports needed including your ssh port

# Demo installation
in progress

# The CSF (Firewall) part below will be the same in all installers.

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

# Installation
* Login via ssh to your server.
* Download the (raw) installer script of your choice to your server: wget 
* make the file executable: chmod +x installer_script
* run the script with sudo ./installer_script

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
You will be notified with the login url after the installation has completed

# Enjoy!
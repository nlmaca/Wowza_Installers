# Intro
I got tired of running the same commands over and over again when i was testing with wowza. So i made some installers for it. I mainly focus on Ubuntu setups, although i also try to maintain the CentOS distro (or when requested).

* I keep a personal blog which i update once in a while when i feel like it. https://vanmarion.nl/blog. Feel free to leave a comment or contact me if you have questions. 

## Prerequisites - (free) wowza account
* Create a free account at wowza. After that login and then open this url: https://www.wowza.com/media-server/developers/license
* you will get straight to the trial form. All you have to do is check some boxes and start the request for the developer license. The developer license is free for 180 days. And after that you can get a new free license. The free version has some limitions of input and output limits, but for everything else your server is a like an enterprise license.

- If you have an enterprise license, you can use that one. Check with Wowza Support if your license is valid for the next version.
* you have a default installed CentOS 7.x server or Ubuntu 20.04.x server installed

# Server Installers 
The installers are complete scripts which install all the components needed:
- Java 11 Installation
- CSF Firewall Including the correct ports
- Wowza Server Installation (all you need to fill in is the LicenseKey and your preferred login credentials for the backend of Wowza)
- Check the installers for the wowza version you would like to install.

# SSL Frontend & Backend
Second part is you can run your wowza server on a letsencrypt SSL. Although StreamLock from Wowza is also possible (and free of charge now). That was paid before, so that's why choose for LetsEncrypt.
- You can choose to run only the frontend on SSL or the backend, or both.
- SSL encryption will cause a higher cpu load on your server due to the encryption of the stream. I can't tell you what the load will be, that all depends on your streaming setup and connections.

## Todo: 
- upgrade installers and how to restore (in case of update failure)
- upgrade java 9 to java 11 only on existing system


## What will be installed
* system will be updated & upgraded
* Java 11 will be installed and connected to Wowza
* Basic Wowza Streaming Engine will be installed
* CSF (Firewall) be installed & automatic configured with the ports needed including your ssh port


## The CSF (Firewall) part below will be the same in all installers.

## Firewall ports that will be set
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

## Installation
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

## Enjoy!
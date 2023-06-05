
# Intro

I have created several installers and decided it was time for an upgrade. I will be updating this page with new installers. 

More information can be found at https://www.vanmarion.nl/blog where i also explain the installer scripts

## Update

Last update: june 5, 2023

## Installers

- June 5,2023   : Fresh Install Wowza StreamingEngine /Ubuntu/01_InstallStreamingEngine.sh
                : Blog post: https://vanmarion.nl/blog/blog/wowza-streaming-engine-4-8-232-java-openjdk-17/
- TBA           : Upgrade OpenJDK 11 to OpenJDK 17 including upgrade to Wowza 4.8.23+2
                : Blog post: TBA
- TBA           : Additional installation of LetsEncrypt SSL for Wowza frontend & Backend
                : Blog post: TBA
- TBA           : Additional configuration of adding StreamLock
                : Blog post: TBA
- TBA           : Playback example with VideoJS or Wowza Jwplayer (Free Cloud edition)
                : Blog post: TBA

## Hardware

* For testing purposed i use a simple VM in VMware workstation or on my own server. 
* 1CPU/vCore, 4GB of RAM, 20 GB of harddisk is enough for testing purposes. 

## What does the installer(s) contain

* Fresh installation of Wowza StreamingEngine 4.8.23+2 
* OpenJDK 17 installation
* CSF Firewall installation including configuration

## What do you need?

- A fresh installed Ubuntu 20 or 22.04 LTS version installed with a normal user. 
- A free trial (30 days valid) from Wowza. You can do this by register for free at https://portal.wowza.com/
- Create a new trial license for Wowza Streaming Engine. 
- In case you also want to enable SSL you will also need a public domain and ports 80 and 443 needs to be routed to your Wowza Server. 

# What do the installers contain

- Java installations and configuration
- Updates to newer java versions
- Installation and automatic configuration of the firewall

# Upgrade installers
- Normally you can download the upgrade zip from your wowza account, but i cannot add them to the installation scripts. So I add the zip to my personal domain. If you don't trust that, just change the download url in the wget command in the bash script. 

# CSF Firewall

I usually use CSF for firewall rules. More information can be found at https://configserver.com/configserver-security-and-firewall/ in case you want to know more detail.


# SSL certificates

## LetsEncrypt

I started with LetsEncrypt as an alternative to Streamlock which was a paid addition a couple of years ago. And it was a nice challenge. I found another use on Github wich has created a converter so i was able to install it to Wowza and could create a manual for it. 

## Streamlock 

Wowza supports Streamlock, but it is only usefull for production servers. With every change in License you have to reset/activate it again. I am planning on making a tutorial, but i focus on the LetsEncrypt first. 

# SSL Frontend & Backend

With the frontend i mean the EngineManager website where you as the WowzaAdmin login to. 
With the backend i mean the API access or the stream Url's.
You can choose if you want to connect both to SSL or only one. 

# Important
Be Aware that streaming over SSL can cause the serverload to increase with 20 - 50%. There is some SSL optimization where Wowza wrote an article about. This is not in scope in the installer, but for you to investigate in case you run into serverload issues. 
More info: https://www.wowza.com/docs/how-to-improve-ssl-configuration#modify-your-ssl-configuration-settings3

## The CSF (Firewall) part below will be the same in all installers.

## Firewall ports that will be set
```
Port 53: Domain name system (DNS)
Port 80: Hypertext transfer protocol (HTTP)
Port 113: Authentication service/identification protocol
Port 123: Network time protocol (NTP)

Port SSH_PORT: your current ssh port will be set in CSF

#Wowza Ports
#TCP IN:
Port 1935	    : RTMP (all variants), RTSP, Microsoft Smooth Streaming, Apple HLS, MPEG-DASH, HDS, WOWZ
Port 8084-8085  : JMX/JConsole monitoring and administration
Port 8086-8087  : HTTP Administrator
Port 8088		: Wowza Streaming Engine Manager
Port 8090       : Preparation for SSL setup (EngineManager)
Port 554		: RTSP
Port 443		: Preparation for SSL setup (StreamingEngine)
Port 80		    : Licensing server connections / 

#CSF IPV4
TCP_IN = "2022,53,80,443,554,1935,8084:8088,8090"
TCP_OUT = "53,80,113,443,554,1935"
UDP_IN = "53"
UDP_OUT = "53"

#CSF IPV6
TCP_IN = "2022,53,80,443,554,1935,8084:8088,8090"
TCP_OUT = "53,80,113,443,554,1935"
UDP_IN = "53"
UDP_OUT = "53"

```
## Enjoy!
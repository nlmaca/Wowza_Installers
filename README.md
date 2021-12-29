
# Important!! 
* Log4j security patch release: CVE-2021-44832 dec 28 2021
* will also fix: CVE-2021-44228 & CVE-2021-45046
* Check Ubuntu/Patches/Log4jSecurityFix_2.17.1.sh
* references: 
```
https://www.wowza.com/docs/update-for-apache-log4j2-security-vulnerability
https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-44832
https://logging.apache.org/log4j/2.x/
```

* use at own risk. Always, always test on your test environment first!
* CentOS installer in progress

# Intro
I got tired of running the same commands over and over again when i was testing with wowza. So i made some installers for it. I mainly focus on Ubuntu setups, although i also try to maintain the CentOS distro (when requested).

## Prerequisites - (free) wowza account
* Update november 19 2021: https://vanmarion.nl/blog/blog/wowza-changed-developer-license-model/
* Create a free account at wowza. After that login and then open this url: https://www.wowza.com/pricing/trial
* Wowza has changed their developer licenses from 180 days to 30 days. You can however request a renewal trial after the 30 days end.
* The trial license is valid for all Versions. 
* If you have an enterprise license, you can use that one. Check with Wowza Support if your license is valid for the next version.
* You have a default installed Ubuntu 20.04.x server installed

# Server Installers 
The installers are complete scripts which install all the components needed:
- Java 11 Installation
- CSF Firewall Including the correct ports
- Wowza Server Installation (all you need to fill in is the LicenseKey and your preferred login credentials for the backend of Wowza)
- Check the installers for the wowza version you would like to install.

# Upgrade installers
- Normally you can download the upgrade zip from your wowza account. I added the zip to my personal domain. If you don't trust that, just change the download url in the wget command.

# SSL Frontend & Backend
Second part is you can run your wowza server on a letsencrypt SSL. Although StreamLock from Wowza is also possible (and free of charge now). That was paid before, so that's why i chose for LetsEncrypt.
- You can choose to run only the frontend on SSL or the backend, or both.
- SSL encryption will cause a higher cpu load on your server due to the encryption of the stream. I can't tell you what the load will be, that all depends on your streaming setup and connections.
- If you want to add SSL to your server [read this section](https://github.com/nlmaca/Wowza_Installers)

## Todo: 
- upgrade installers and how to restore (in case of update failure)
- upgrade java 8 to java 11 only on existing system


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

#Wowza Ports
#TCP IN:
Port 1935	    : RTMP (all variants), RTSP, Microsoft Smooth Streaming, Apple HLS, MPEG-DASH, HDS, WOWZ
Port 8084-8085  : JMX/JConsole monitoring and administration
Port 8086-8087  : HTTP Administrator
Port 8088		: Wowza Streaming Engine Manager
Port 8090       : if you decide to use Wowza SSL
Port 554		: RTSP
Port 443		: SSL Connections
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
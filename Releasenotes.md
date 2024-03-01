## update 2024-03-01
* Added Ubuntu updater to 4.8.26+4 

## update 2023-06-19
* Cleanup old files and installers to archive. 

## update 2023-06-18
* Added installation including SSL configuration for 4.8.23+2
* Added update installer for Wowza 4.8.23+2
* Added fresh installer for Wowza 4.8.23+2
* Added upgrade Custom Java 11.0.2 for 4.8.23+2

## Update 2023-06-05
* Setup new installer for Ubuntu server, OpenJDK17 and CSF. Part 1 of many
* Created installer script Ubuntu/01_InstallStreamingEngine.sh

## UPdate 2022-03-12
* Log4jupdate Fix version
* replaced url for Log4j2.17.2 file (2.17.1 file was remove from original url)


## update 2021-12-29
* Log4j security patch release: CVE-2021-44832 dec 28 2021
* will also fix: CVE-2021-44228 & CVE-2021-45046
* Added Ubuntu/Patches/Log4jSecurityFix_2.17.1.sh

* Added Ubuntu 20.04 fresh installer for Wowza version 4.8.17+1

## update 2021-11-19
* Added Ubuntu 20.04 fresh installer for Wowza version 4.8.15+3
* changed Wowza download url back to wowza official URL

## update 2021-05-04
* Added Ubuntu 20.04 upgrade script for upgrading to 4.8.12+1
* Added Ubuntu 20.04 fresh installer script for wowza version 4.8.12+1

## update 2021-04-12
- Added 4.8.11 upgrade installers for ubuntu 18.04 and ubuntu 20.04
- important: make sure you have updated to 4.8.9 first (if not your installattion will most likely result in an error 500)

## Update 2021-03-29
- Changed .jar url to version 0.2 in Ubuntu and CentOS SSL installers
- added Ubuntu 18.04 / 20.04 Walkthrough installer for upgrading tot 4.8.11 
- Before upgrading to 4.8.11 make sure you have Java 9 or 11 installed!

## Update 2021-02-19
- Updated Ubuntu 18.04 + 20.04 LTS Upgrade wowza with or without java upgrade
- Updated Ubuntu SSL installatation
- Note: Wowza 4.8.9 can only be updated from earlier versions.
- updated Ubuntu SSL frontend & backend

## Update 2021-02-17
- Updated Ubuntu 18.04 Upgrade to Wowza 4.8.9 incl installation of Java 11

## Update 2021-02-12
- Updated CentOS SSL activation (requested by User). certbot-auto is deprecated.
- now certbot is installed with snap
- Update CentOS 7.x installer for wowza 4.8.8.01 (current stable release.) 4.8.9 is at this moment only available as an update package.


## update june 23 2020
- updated configuration setup for CentOS 7 and Ubuntu 20.04 for enabling SSL Letsencrypt.

## update april 29 2020
- New installer for CentOS 7.7.1908 including Java OpenJDK 11 (run as user with administrator privileges)


## Update march 21 2020
- New ubuntu 18.04.x + Wowza StreamingEngine 4.8.0 incl java 11
- Wowza 4.8.0 requires a minimum of Java version 9.0.4
- CSF firewall including the necessary ports, It will also add the java version to Wowza.

## Wowza developer license limitations
- This will have limitations on 3 input stream and max 10 output streams
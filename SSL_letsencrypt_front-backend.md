# SSL enable letsencrypt on CentOS 7 and Ubuntu 18.04/20.04 LTS servers 

# Wowza version: 4.7.3+

# Requirements
- You should have setup a basic server with an ipaddress and a valid domainname forwarded to the server. 
- In this example i use: SUB.DOMAIN.EXT which is forwarded to my wowza server. So change this in the tutorial with your own domain!

# Questions / Errors?
- "It doesn't work, i get errors". Please tell me where it went wrong for you and which are the errors you are getting. If you don't feel like asking a decent question, i will not even respond to it anymore. 
- check your logfiles of wowza and your server. 

# Intro
- If you need to setup a complete server, please check out the installer files for your setup
- If you have your own firewall setup please be aware to open Inbound ports: 80, 443, 8090
   - 80 and 443 are needed to validate the Letsencrypt certificate
   - 8090 is the port we will use for our backend connection

# Setup and configuration
Go to your wowza engineManager (browser)
In streamingengineManager open port 443 (Server > Virtual Host Setup
   - Edit Virtual Host Setup > Add Host port
   Name: SSL streaming
   Type: Streaming
   Ip Address: *
   Ports: 443
   Do NOT enable streamlock SSL (streamlock setup will be explained in a different tutorial)
   / Save and restart Vhost
-----------------------------------------------------------------------------------------------   

# Setup SSL certbot
cd /tmp
Ubuntu: apt-get update && apt-get upgrade
CentOS: yum update

# install git
git clone https://github.com/certbot/certbot /opt/letsencrypt
cd /opt/letsencrypt

sudo -H ./letsencrypt-auto certonly --standalone -d SUB.DOMAIN.EXT

# enter email
# agree TOS(Terms of Service): A
# Share your email: (up to you): N

# Add cronjobs for autorenewal
@weekly root cd /opt/letsencrypt && git pull >> /var/log/letsencrypt/letsencrypt-auto-update.log
@monthly root /opt/letsencrypt/letsencrypt-auto certonly --quiet --standalone --renew-by-default -d SUB.DOMAIN.EXT >> /var/log/letsencrypt/letsencrypt-auto-update.log

-----------------------------------------------------------------------------------------------
# Letsencrypt converter SSL to JKS file. (so it can be used in wowza)
# Credits to Robymus
cd /usr/local/WowzaStreamingEngine/lib 
wget https://github.com/robymus/wowza-letsencrypt-converter/releases/download/v0.2/wowza-letsencrypt-converter-0.2.jar

java -jar wowza-letsencrypt-converter-0.2.jar -v /usr/local/WowzaStreamingEngine/conf/ /etc/letsencrypt/live/

# 2 files should have been created. a .jks and a .txt file
# Read the txt file and copy the contents in a temporary notepad
```
cat /usr/local/WowzaStreamingEngine/conf/jksmap.txt
```
example output: 
```
SUB.DOMAIN.EXT={"keyStorePath":"/usr/local/WowzaStreamingEngine/conf/SUB.DOMAIN.EXT.jks", "keyStorePassword":"secret", "keyStoreType":"JKS"}
```
We need the jks location and keyStorePassword in the next steps

Change wowza config file : Enable the 443 Module and change the settings

```
vi /usr/local/WowzaStreamingEngine/conf/VHost.xml
```
# Enable 443 Module:
You will see this line: <!-- 443 with SSL -->
Remove the <!-- and --> around the <HostPort> tag.
Now search for this Element:
```
<SSLConfig>
    <KeyStorePath>${com.wowza.wms.context.VHostConfigHome}/conf/keystore.jks</KeyStorePath>
    <KeyStorePassword>[password]</KeyStorePassword>
    <KeyStoreType>JKS</KeyStoreType>
    <DomainToKeyStoreMapPath></DomainToKeyStoreMapPath>
    <SSLProtocol>TLS</SSLProtocol>
    <Algorithm>SunX509</Algorithm>
    <CipherSuites></CipherSuites>
    <Protocols></Protocols>
</>
```
Change only the keyStorePath and keyStorePassword to the ones from the jks file (see previous step). The rest doesn't have to be changed
```
<SSLConfig>
    <KeyStorePath>${com.wowza.wms.context.VHostConfigHome}/conf/SUB.DOMAIN.EXT.jks</KeyStorePath>
    <KeyStorePassword>secret</KeyStorePassword>
    <KeyStoreType>JKS</KeyStoreType>
    <DomainToKeyStoreMapPath></DomainToKeyStoreMapPath>
    <SSLProtocol>TLS</SSLProtocol>
    <Algorithm>SunX509</Algorithm>
    <CipherSuites></CipherSuites>
    <Protocols></Protocols>
</SSLConfig>
```
Save the File

# Enable backend for SSL 
Open the tomcat.properties file in the manager section
```
vi /usr/local/WowzaStreamingEngine/manager/conf/tomcat.properties
```
Change the default values
```
#httpsPort=8090
#httpsKeyStore=conf/certificate.jks
#httpsKeyStorePassword=[password]
#httpsKeyAlias=[key-alias]
```
TO:
```
httpsPort=8090
httpsKeyStore=/usr/local/WowzaStreamingEngine/conf/SUB.DOMAIN.EXT.jks
httpsKeyStorePassword=secret
#httpsKeyAlias=[key-alias]
```
Installation is done. Time to restart Wowza.
```
service WowzaStreamingEngineManager restart
service WowzaStreamingEngine restart
```

# Open the EngineManager from your browser
```
https://SUB.DOMAIN.EXT:8090/enginemanager
```
This should show you the page in https.

# The End :D



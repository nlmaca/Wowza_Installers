# Letsencrypt Wowza Ubuntu 20.04 
* Version: 1.0 / June 23 2020
Why Letsencrypt?. Wowza can also be used with Streamlock, which is currently free, but at the time i wanted to use SSL, it was a pai subscription. So i starte experimenting with Letsencrypt. 
First only the frontend (wowza playback) worked, but now also the backend (enginemanager) can work on SSL. 
- However: You can choose if you want to use the backend on SSL or leave it in http. I would advise to use SSL because of the login credentials.

# Requirements
- You should have setup a basic server with an ipaddress and a valid domainname forwarded to the server. 
- Wowza version: 4.8.0+ present on your system
- If you need a Wowza installation, use one of the installers of your choice. You can find it in the repository.
- In this example i use: SUB.DOMAIN.EXT which is forwarded to my wowza server. So change this in the tutorial with your own domain!

# Questions / Errors?
- "It doesn't work, i get errors". Please tell me where it went wrong for you and which are the errors you are getting. If you don't feel like asking a decent question, i will not even respond to it anymore. 

# Open Ports
- If you need to setup a complete server, please check out the installer files for your setup
- If you have your own firewall setup please be aware to open Inbound ports: 80, 443, 8090,1935
```
80 and 443 are needed to validate the Letsencrypt certificate
8090 is the port we will use for our backend connection
1935 is the default streaming port for Wowza playback
```
  
# install git and setup Certbot (standalone)
```
apt-get update && apt-get upgrade

git clone https://github.com/certbot/certbot /opt/letsencrypt
cd /opt/letsencrypt

apt install certbot

certbot certonly --standalone -d SUB.DOMAIN.EXT
```
Answer some of the questions:
```
enter email: set-your-email
agree TOS(Terms of Service): A
Share your email: (up to you): N
```

* Add cronjobs for autorenewal
```
# crontab -e
@weekly root cd /opt/letsencrypt && git pull >> /var/log/letsencrypt/letsencrypt-auto-update.log
@monthly root /opt/letsencrypt/certbot certonly --quiet --standalone --renew-by-default -d SUB.DOMAIN.EXT >> /var/log/letsencrypt/letsencrypt-auto-update.log
```

# Letsencrypt converter (creation JKS file)
* Credits to Robymus: https://github.com/robymus
```
cd /usr/local/WowzaStreamingEngine/lib 
wget https://github.com/robymus/wowza-letsencrypt-converter/releases/download/v0.1/wowza-letsencrypt-converter-0.1.jar

java -jar wowza-letsencrypt-converter-0.1.jar -v /usr/local/WowzaStreamingEngine/conf/ /etc/letsencrypt/live/
```

2 files should have been created. a .jks and a .txt file. Read the txt file and copy the contents in a temporary notepad
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
Now search for this Element: SSLConfig
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
enable SSL / streamlock and place the jks path / and set the password to: secret

* Note if you want port 1935 to use SSL, do the same thing as for port 443

Save and restart the Vhost setup. 
Playback url (vlc, jwplayer, flowplayer, hls, etc)
```
https://SUB.DOMAIN.EXT:1935/vod/mp4:sample.mp4/playlist.m3u8
https://SUB.DOMAIN.EXT/vod/mp4:sample.mp4/playlist.m3u8
```

# The End :D



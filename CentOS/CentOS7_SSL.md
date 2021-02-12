# Letsencrypt Wowza (CentOS 7) 

* Date: 2020-02-12
* Author: J. van Marion / jeroen@vanmarion.nl
* Version: 2.0

* Reason for update: Skipping bootstrap because certbot-auto is deprecated on this system. Your system is not supported by certbot-auto anymore.

* Updates: certbot-auto is not supported anymore, because it is deprecated. This installer is updated with the new snap support setup

* Version: 2.0 / Februari 2020
Why Letsencrypt?. Wowza can also be used with Streamlock, which is currently free, but at the time i wanted to use SSL, it was a paid subscription. So i started experimenting with Letsencrypt. 
First only the frontend (wowza playback) worked, but now also the backend (enginemanager) can work on SSL. 
- The backend is optional for SSL, but i advise you to run it on SSL anyway, so the Login credentials are encrypted.

# Requirements
- You should have setup a basic server with an ipaddress and a valid domainname forwarded to the server. 
- Wowza version: 4.8.+ present on your system
- Firewall ports 80 and 443 should be open on your server to validate the SSL request. 

# Open Ports
- If you need to setup a complete server, please check out the installer files for your setup
- If you have your own firewall setup please be aware to open Inbound ports: 80, 443, 8090,1935
```
80 and 443 are needed to validate the SSL certificate
8090 is the port we will use for our backend connection
1935 is the default streaming port for Wowza playback
```
  
# CLI commands
Open a shell prompt to your Wowza Server and run the commands. 
only replace YOUR-WOWZASERVER-DOMAINNAME with your domainname you use for your wowza server. 
```
# add the repository to your server
$ sudo yum install epel-release -y

# update the system
$ sudo yum update -y

# install snap
$ sudo yum install snapd -y

$ sudo systemctl enable --now snapd.socket

$ sudo ln -s /var/lib/snapd/snap /snap

# remove certbot-auto and Certbot CentOS packages

$ sudo yum remove certbot

# install certbot
$ sudo snap install --classic certbot

# if you get an error like this: "error: too early for operation, device not yet seeded or device model not acknowledged"
# then run the command again

$ sudo ln -s /snap/bin/certbot /usr/bin/certbot

# create the SSL certificate
$ sudo certbot certonly --standalone -d YOUR-WOWZASERVER-DOMAINNAME

# Answer some of the questions:
$ enter email: set-your-email
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

## 

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
    <AllowHttp2>false</AllowHttp2>
</SSLConfig>
```
Save the File

# Enable backend for SSL 
Open the tomcat.properties file in the manager section
```
vi /usr/local/WowzaStreamingEngine/manager/conf/tomcat.properties
```
Uncomment the first 3 lines and change the value of httpsKeyStore and httpsKeyStorePassword
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

# Open the SSL Link EngineManager from your browser
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

















* Add cronjobs for autorenewal
```
# crontab -e
@weekly root cd /opt/letsencrypt && git pull >> /var/log/letsencrypt/letsencrypt-auto-update.log
@monthly root /opt/letsencrypt/letsencrypt-auto certonly --quiet --standalone --renew-by-default -d SUB.DOMAIN.EXT >> /var/log/letsencrypt/letsencrypt-auto-update.log
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
    <AllowHttp2>false</AllowHttp2>
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



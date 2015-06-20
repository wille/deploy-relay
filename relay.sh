#!/bin/sh

NICKNAME="rexit"
CONTACT="red<at>cmail.nu"

# tor exit-node installer by likvidera
# Add tor repository to apt sourcelist
echo "deb http://deb.torproject.org/torproject.org wheezy main" >> /etc/apt/sources.list
echo "deb-src http://deb.torproject.org/torproject.org wheezy main" >> /etc/apt/sources.list

# Add key
gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

# update, upgrade and install tor, tor arm and the keyring
apt-get update && apt-get -y upgrade && apt-get -y install tor-arm deb.torproject.org-keyring tor

#download the tor exit notice
wget --no-check-certificate -P /var/run/tor/ https://raw.githubusercontent.com/redpois0n/deploy-relay/master/index.html

#apply correct user, rights to the tor folder
chown -R debian-tor:debian-tor /var/run/tor
chmod 700 /var/run/tor

#write the tor config, change the changemes!
cat > /etc/tor/torrc << "TOR_SETTINGS"
SocksPort 0                   

DataDirectory /var/run/tor
PidFile /var/run/tor/tor.pid

RunAsDaemon 1
# Do not run as root
User debian-tor 

# ARM related
ControlSocket /var/run/tor/control
CookieAuthentication 1
CookieAuthFileGroupReadable 1             
CookieAuthFile /var/run/tor/control.authcookie
# Enable ARM to attach to TOR
DisableDebuggerAttachment 0            

# Node name
Nickname $NICKNAME
# Contact                          
ContactInfo $CONTACT                     

# Listen on common ports, service needs to start as root
ORPort 443                        
DirPort 80
# Display page if visiting using port 80 HTTP
DirPortFrontPage /var/run/tor/tor-exit-notice.html    

# Less disk usage
AvoidDiskWrites 1
#  OpenSSL hardware acceleration    
HardwareAccel 1                  
# Service must be started as root
DisableAllSwap 1               
PublishServerDescriptor 1
# Exit policies
Exitpolicy reject *:23
Exitpolicy reject *:25
Exitpolicy reject *:109
Exitpolicy reject *:110
Exitpolicy reject *:143
Exitpolicy reject *:465
Exitpolicy reject *:587
Exitpolicy reject *:119
Exitpolicy reject *:135-139
Exitpolicy reject *:445
Exitpolicy reject *:563
Exitpolicy reject *:1214
Exitpolicy reject *:4661-4666
Exitpolicy reject *:6346-6429
Exitpolicy reject *:6699
Exitpolicy reject *:6881-6999
Exitpolicy accept *:*
TOR_SETTINGS

# Reload configuration and start
service tor reload
service tor start

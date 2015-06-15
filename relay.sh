#!/bin/sh
#tor exit-node installer by likvidera
#add tor rep to apt sourcelist
echo "deb http://deb.torproject.org/torproject.org wheezy main" >> /etc/apt/sources.list
echo "deb-src http://deb.torproject.org/torproject.org wheezy main" >> /etc/apt/sources.list

#add key
gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

                     #update, upgrade and install tor, tor arm and the keyring
apt-get update && apt-get -y upgrade && apt-get -y install tor-arm deb.torproject.org-keyring tor

#download the tor exit notice
#swehack exit-notice
wget --no-check-certificate -P /var/run/tor/ https://raw.githubusercontent.com/likvidera/BadOnions/master/SwehackExitNotice/tor-exit-notice.html
#normal exit-notice
#wget --no-check-certificate -P /var/run/tor/ https://gitweb.torproject.org/tor.git/plain/contrib/operator-tools/tor-exit-notice.html

#apply correct user, rights to the tor folder
chown -R debian-tor:debian-tor /var/run/tor
chmod 700 /var/run/tor

#write the tor config, change the changemes!
cat > /etc/tor/torrc << "TOR_SETTINGS"
#relay only, no local socks listener please
SocksPort 0                   

DataDirectory /var/run/tor
PidFile /var/run/tor/tor.pid

RunAsDaemon 1
#Don't want to run as root
User debian-tor 

#tor-arm related stuff
ControlSocket /var/run/tor/control
CookieAuthentication 1
CookieAuthFileGroupReadable 1             
CookieAuthFile /var/run/tor/control.authcookie
#enable this so tor-arm can attach
DisableDebuggerAttachment 0            

#Nickname of the tor exit-node
Nickname CHANGEME
#Email/Twitter - BTC address (or not)                             
ContactInfo CHANGEME                     

#listen on common ports, service needs to start as root
ORPort 443                        
DirPort 80
#our exit-notice served on port 80
DirPortFrontPage /var/run/tor/tor-exit-notice.html    

#reduce wear on SSD
AvoidDiskWrites 1
#look for OpenSSL hardware cryptographic support               
HardwareAccel 1                  
#service must be started as root
DisableAllSwap 1               
PublishServerDescriptor 1
#exit policies               
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

service tor reload
service tor start

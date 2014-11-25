#! /bin/bash

# Script to set up a basid seedbox on a Ubuntu 14.04 VPS

# ask for username/password for everything
read -e -p "Choose Username: " sb_username
sb_transmission_username=$sb_username
read -e -p "Choose Transmission Username [$sb_username]: " sb_transmission_username
read -e -p "Choose Transmission Password: " sb_transmission_password
# ask for transmission port
sb_transmission_port=9025
read -e -p "Choose Transmission Port [9025]: " sb_transmission_port
# ask for new ssh port [2200]
sb_ssh_port=2200
read -e -p "Make SSHH port: [2200] " sb_ssh_port

# update stuff
echo "Updating apt"
apt-get update
apt-get upgrade -y
apt-get install python-software-properties -y
add-apt-repository ppa:transmissionbt/ppa
apt-get update
echo
echo
echo "Creating User"
# create user and allow sudo
useradd -m $sb_username -s /bin/bash -G sudo -U -d/home/$sb_username
# prompt for password change
echo "Set User Password: "
passwd $sb_username

## lock down root ssh
echo
echo
echo "Configuring SSH"
# change port
sed -i.bak "s/Port 22/Port $sb_ssh_port/g" /etc/ssh/sshd_config
# disallow root ssh
sed -i.bak "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config

# install openvpn and set up
# via https://github.com/Nyr/openvpn-install
wget git.io/vpn --no-check-certificate -O openvpn-install.sh; bash openvpn-install.sh

# install transmission, change password to variable, restart and serve
apt-get install transmission-cli transmission-common transmission-daemon -y
# set up directory structure
mkdir -p /home/$sb_username/transmission/Complete
mkdir -p /home/$sb_username/transmission/Incomplete
mkdir -p /home/$sb_username/transmission/Torrents

usermod -a -G debian-transmission $sb_username
chgrp -R debian-transmission /home/$sb_username/transmission
chmod -R 775 /home/$sb_username/transmission
chown -R $sb_username /home/$sb_username/



# TRANSMISSION_SETTINGS_FILE="/home/$sb_username/.config/transmission-daemon/settings.json"
TRANSMISSION_SETTINGS_FILE="/etc/transmission-daemon/settings.json"

service transmission-daemon stop
# change username, password, and port
# change complete, incomplete, and watch dirs
sed -i '/download-dir/c\"download-dir": "/home/'"$sb_username"'/transmission/Complete",' $TRANSMISSION_SETTINGS_FILE
sed -i '/incomplete-dir"/c\"incomplete-dir": "/home/'"$sb_username"'/transmission/Incomplete",' $TRANSMISSION_SETTINGS_FILE
sed -i '/incomplete-dir-enabled/c\"incomplete-dir-enabled": true,' $TRANSMISSION_SETTINGS_FIL
sed -i '/rpc-whitelist-enabled/c\"rpc-whitelist-enabled": false,' $TRANSMISSION_SETTINGS_FILE
# @TODO(Shrugs) get watch-dir and watch-dir-enabled in there
sed -i '/rpc-password/c\"rpc-password": "'"$sb_transmission_password"'",' $TRANSMISSION_SETTINGS_FILE
sed -i '/rpc-username/c\"rpc-username": "'"$sb_transmission_username"'",' $TRANSMISSION_SETTINGS_FILE
sed -i '/rpc-port/c\"rpc-port": "'"$sb_transmission_port"'",' $TRANSMISSION_SETTINGS_FILE
cp $TRANSMISSION_SETTINGS_FILE $TRANSMISSION_SETTINGS_FILE.default
service transmission-daemon start


# install plex, give user url to configure
wget https://downloads.plex.tv/plex-media-server/0.9.11.1.678-c48ffd2/plexmediaserver_0.9.11.1.678-c48ffd2_amd64.deb
dpkg -i plexmediaserver_0.9.11.1.678-c48ffd2_amd64.deb
rm plexmediaserver_0.9.11.1.678-c48ffd2_amd64.deb

apt-get -f install -y


# ssh-copy-id ~/.ssh/id_rsa.pub viking@<ip>

sb_ip_addr=$(ip addr show eth0 | grep "inet " | awk '{print $2}' | sed "s/\/..//")

echo
echo
echo
echo "Then, log into $sb_ip_addr:9099 to check out the Transmission interface."
echo "To configure Plex, you must proxy your connection to the server and access it from local host."
echo "Run 'ssh -2nN -D 8080 $sb_username@$sb_ip_addr' and then point your browser to a localhost SOCKS5 proxy on port 8080"
echo "Then go to $sb_ip_addr:32400/web and configure your server from the Settings>Server tab."
echo "For convenience, run 'ssh-copy-id -i ~/.ssh/id_rsa.pub $sb_username@$sb_ip_addr'"
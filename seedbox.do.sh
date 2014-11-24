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
add-apt-repository ppa:transmissionbt/ppa
apt-get update
apt-get upgrade -y

echo "Creating User"
# create user and allow sudo
useradd -m $sb_username -s /bin/bash -G sudo -U -d/home/$sb_username
# prompt for password change
echo "Set User Password: "
passwd $sb_username

## lock down root ssh
echo "Configuring SSH"
# change port
sed -i.bak "s/Port 22/Port $sb_ssh_port/g" /etc/ssh/sshd_config
# disallow root ssh
sed -i.bak "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config

# install openvpn and set up
echo "Downloading/Installing OpenVPN"
wget http://swupdate.openvpn.org/as/openvpn-as-2.0.10-Ubuntu14.amd_64.deb
dpkg -i openvpn-as-2.0.10-Ubuntu14.amd_64.deb
rm openvpn-as-2.0.10-Ubuntu14.amd_64.deb
echo "Set OpenVPN Password: "
passwd openvpn

# @TODO(Shrugs) set hostname in openvpn settings

# install transmission, change password to variable, restart and serve
apt-get install transmission-cli transmission-common transmission-daemon -y
# set up directory structure
mkdir -p /home/$sb_username/transmission/Complete
mkdir -p /home/$sb_username/transmission/Incomplete
mkdir -p /home/$sb_username/transmission/Torrents

usermod -a -G debian-transmission $sb_username
chgrp -R debian-transmission /home/$sb_username/transmission
chmod -R 775 /home/$sb_username/transmission
# add shortcuts to ~/.bashrc
echo "alias starttransmission=\"sudo service transmission-daemon start\"" >> /home/$sb_username/.bashrc
echo "alias stoptransmission=\"sudo service transmission-daemon stop\"" >> /home/$sb_username/.bashrc
echo "alias reloadtransmission=\"sudo service transmission-daemon reload\"" >> /home/$sb_username/.bashrc

cp -a /etc/transmission-daemon/settings.json /etc/transmission-daemon/settings.json.default
mkdir -p /home/$sb_username/.config/transmission-daemon
cp -a /etc/transmission-daemon/settings.json /home/$sb_username/.config/transmission-daemon
chgrp -R debian-transmission /home/$sb_username/.config/transmission-daemon
chmod -R 770 /home/$sb_username/.config/transmission-daemon

rm /etc/transmission-daemon/settings.json
ln -s /home/$sb_username/.config/transmission-daemon/settings.json /etc/transmission-daemon/settings.json
chgrp -R debian-transmission /etc/transmission-daemon/settings.json
chmod -R 770 /etc/transmission-daemon/settings.json

chown -R $sb_username /home/$sb_username/
chgrp -R viking /home/$sb_username/.config

# @TODO(Shrugs) make sure the above works and then make sed commands for settings file

# change username, password, and port
# change complete, incomplete, and watch dirs
sed -i '/download-dir/c\"download-dir": "/home/$sb_username/transmission/Complete",' /home/$sb_username/.config/transmission-daemon/settings.json
sed -i '/incomplete-dir/c\"incomplete-dir": "/home/$sb_username/transmission/Incomplete",' /home/$sb_username/.config/transmission-daemon/settings.json
# @TODO(Shrugs) get watch-dir and watch-dir-enabled in there
sed -i '/rpc-password/c\"rpc-password": "$sb_transmission_password",' /home/$sb_username/.config/transmission-daemon/settings.json
sed -i '/rpc-username/c\"rpc-username": "$sb_transmission_username",' /home/$sb_username/.config/transmission-daemon/settings.json
sed -i '/rpc-port/c\"rpc-port": "$sb_transmission_port",' /home/$sb_username/.config/transmission-daemon/settings.json



# install plex, give user url to configure
wget https://downloads.plex.tv/plex-media-server/0.9.11.1.678-c48ffd2/plexmediaserver_0.9.11.1.678-c48ffd2_amd64.deb
dpkg -i plexmediaserver_0.9.11.1.678-c48ffd2_amd64.deb
rm plexmediaserver_0.9.11.1.678-c48ffd2_amd64.deb

apt-get -f install


# ssh-copy-id ~/.ssh/id_rsa.pub viking@<ip>
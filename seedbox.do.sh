#! /bin/bash

# Script to set up a basid seedbox on a Ubuntu 14.04 VPS

# ask for username/password for everything
read -e -p "Choose Username: " sb_username

# create user
useradd -m $sb_username -s /bin/bash -G sudo -U -d/home/$sb_username
# lock down root ssh

# install openvpn and set up

# install transmission, change password to variable, restart and serve
# set up directory structure


# install plex, give user url to configure


# ssh-copy-id ~/.ssh/id_rsa.pub viking@<ip>
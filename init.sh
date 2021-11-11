#!/usr/bin/env bash

sudo apt-get update

#sudo apt-get install git
#mkdir ~/WorkEnv
#cd ~/WorkEnv
#git clone https://github.com/andytian1991/misc_config.git .

sudo apt-get install openssh-server
sudo ufw allow ssh

#android build requirements
sudo apt-get install git-core gnupg flex bison build-essential \
    zip curl zlib1g-dev gcc-multilib g++-multilib \
    libc6-dev-i386 libncurses5 lib32ncurses5-dev x11proto-core-dev \
    libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig

sudo apt-get install vim
sudo apt-get install zsh
sudo apt-get install net-tools
sudo apt-get install openjdk-11-jdk

sudo apt-get install android-tools-adb android-tools-fastboot
sudo apt-get install android-sdk-platform-tools-common
sudo cp ~/WorkEnv/51-android.rules /etc/udev/rules.d/51-android.rules

sudo apt-get install minicom

sudo apt-get install samba
sudo ufw allow samba

sudo apt-get install cifs-utils
sudo apt-get install nfs-kernel-server nfs-common

#nfs server
mkdir ~/nfs-release-server
mkdir ~/nfs-2-server
mkdir ~/nfs-2-ssd
mkdir ~/nfs-179-sharewrite
mkdir ~/nfs-daily
mkdir ~//nfs-vm-server

sudo mount 10.193.102.2:/home/tianyang ~/nfs-2-server
sudo mount 10.193.102.2:/home/ssd-2/tianyang ~/nfs-2-ssd
sudo mount 10.193.108.179:/home/build/daily_images ~/nfs-daily
sudo mount 10.193.108.180:/home/build/share_write  ~/nfs-179-sharewrite
sudo mount -t cifs -o guest //lsv11119.swis.cn-sha01.nxp.com/android ~/nfs-vm-server
sudo mount -t cifs //10.193.108.248/smbshare ~/nfs-release-server/ -o user=smbruser
#Welcome@2018

sudo cp ~/nfs-daily/uuu/1.4.139/linux/uuu /usr/bin

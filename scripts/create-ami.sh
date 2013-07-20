#!/bin/bash
#Get basic stuff
INSTANCE=$(curl http://169.254.169.254/latest/meta-data/instance-id -s )
AZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone -s )
REGION=${AZ%?}
BINS=$(pwd)/bin/x86_64/
echo $INSTANCE
echo $AZ
echo $REGION

#Create the volume and save the vol-id
VOLUME=$(ec2-create-volume --region eu-west-1 --availability-zone eu-west-1b -s 1 | awk {'printf $2'})
echo $VOLUME

#Attach it to this instance
ec2-attach-volume --region $REGION $VOLUME -i $INSTANCE -d /dev/sdx

#Sleep for a couple of seconds
sleep 10

#create the fs
sudo mkfs.ext4 /dev/xvdx

#mount it at /mnt
sudo mount /dev/xvdx /mnt

#bootloader stuff
sudo mkdir /mnt/boot
sudo mkdir /mnt/boot/grub

sudo sh -c 'echo "default 0
timeout 1
title OpenWRT
root   (hd0)
kernel /boot/vmlinuz root=/dev/xvda1 rootfstype=ext4 rootwait xencons=hvc console=tty0 console=hvc0,38400n8 noinitrd
" > /mnt/boot/grub/menu.lst'

#copy the kernel and the FS
echo "going to copy stuff now"

sudo cp $BINS/openwrt-x86_64-xen_domu-vmlinuz /mnt/boot/vmlinuz
sudo tar -xzvf $BINS/openwrt-x86_64-xen_domu-rootfs.tar.gz -C /mnt/

sudo umount /mnt

# detach and create the snapshot
ec2-detach-volume --region $REGION $VOLUME -i $INSTANCE /dev/sdx

sleep 5
SNAPID=$(ec2-create-snapshot --region $REGION -d "OpenWRT x86_64 Image Creation" $VOLUME | awk {'printf $2'})
sleep 10s
ec2-register --region $REGION --name "OpenWRT Built x86_64 AMI-$(date +%s)" --description "OpenWRT Built x86_64 AMI-$(date +%s)"  -a x86_64 -b /dev/sda1=$SNAPID:1:false --root-device-name /dev/sda1 --kernel aki-71665e05

ec2-delete-volume --region $REGION $VOLUME


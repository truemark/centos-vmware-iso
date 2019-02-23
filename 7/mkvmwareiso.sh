#!/usr/bin/env bash

set -uex

DIR=$(dirname ${0})
cd $DIR

# Get ISO Image
mkdir -p ISOTMP

# You must have the Install ISO from centos in same directory as the script
if [ ! -f "centos-7.iso" ]; then
        echo "Original Install ISO must be in the same directory as this script"
        exit 1
fi

cp centos-7.iso ./ISOTMP/
cd ISOTMP
sudo mkdir -p /mnt/cdrom
sudo mount -o loop centos-7.iso /mnt/cdrom
sudo rm -rf image
mkdir -p image
rsync -av /mnt/cdrom/ image/
sudo umount /mnt/cdrom

chmod 755 image/
cp ../minimum-ks.cfg image/ks.cfg

cd image/isolinux/
chmod 755 .
chmod 644 isolinux.cfg
sudo sed -i 's/timeout 600/timeout 6/' isolinux.cfg
sudo sed -i 's/inst.stage2=hd:LABEL=CentOS.* quiet/ks=cdrom:\/ks.cfg inst.txt quiet/' isolinux.cfg
cd ../../
sudo find image -type d -exec chmod 755 {} \;
sudo find image -type f -exec chmod 644 {} \;

NOW=$(date '+%Y%m%d-%H%M%S')
ISO="truemark-vmware-centos-7-server-amd64-${NOW}.iso"

mkisofs -r -V "CentOS Linux Install CD" \
  -cache-inodes \
  -J -l -b isolinux/isolinux.bin \
  -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -o ${ISO} image/

sudo rm -rf image
sha1sum ${ISO} > ${ISO}.sha1


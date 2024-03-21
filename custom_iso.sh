cd ~/automation
mkdir installation
xorriso -osirrox on indev ~/Downloads/ubuntu-22.04.3-desktop-amd64.iso --extract_boot_images installation/bootpart -extract / installation
chmod 644 installation/boot/grub
chmod 644 installation/preseed/ubuntu.seed
cat config.cfg > /installation/preseed/ubuntu.seed
cat grub.cfg > /installation/boot/grub/grub.cfg
xorriso -as mkisofs -r -V "VM_auto_installation" -J -boot-load-size 4 -boot-info-table -input-charset utf-8 -no-emul-boot -o installer.iso ../installation
scp ./installer.iso root@openstack:/vmfs/volumes/datastore1/installer.iso

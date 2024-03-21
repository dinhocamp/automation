cd /home/dinho
mkdir preparation
cd preparation
if test "$SUDO_USER" == "dinho" #Replace "dinho" with root user 
then
	echo "preparing ubuntu-server.iso ....."
	mkdir extractions
	path=`find /home/dinho/Downloads -type f -name "*ubuntu*server*.iso"`
	echo $path
        #sudo mount -o loop $path /home/dinho/extractions
        mkdir source-file
        xorriso -osirrox on -indev $path --extract_boot_images source-file/bootpart -extract / source-file/ 
	chmod 644 source-file/boot/grub/grub.cfg
	mkdir source-file/nocloud
	cp /home/dinho/automation/custom_iso_installers/custom_iso/user-data source-file/nocloud/user-data
	touch source-file/nocloud/meta-data
	cat /home/dinho/automation/grub_server.cfg > source-file/boot/grub/grub.cfg
	xorriso -as mkisofs -r -V "ubuntu-autoinstall" -J -boot-load-size 4 -boot-info-table -input-charset utf-8 -eltorito-alt-boot -b bootpart/eltorito_img1_bios.img -no-emul-boot -o ../install_server.iso source-file
else
	echo -e "your are not root\nexecute the script with sudo privileges"
	exit 1
fi

cd /home/dinho
mkdir preparation
cd preparation
if test "$SUDO_USER" == "dinho" #Replace "dinho" with root user 
then
	echo "preparing ubuntu-desktop.iso ....."
	mkdir extraction
	path=`find /home/dinho/Downloads -type f -name "*ubuntu*desktop*.iso"`
        #sudo mount -o loop $path /home/dinho/extraction
        mkdir source-files
        xorriso -osirrox on -indev $path --extract_boot_images source-files/bootpart -extract / source-files/ 
	chmod 644 source-files/boot/grub/grub.cfg
	#mkdir source-files/preseed
	cp /home/dinho/automation/config.cfg source-files/preseed/ubuntu.seed
	cat /home/dinho/automation/grub.cfg > source-files/boot/grub/grub.cfg
	xorriso -as mkisofs -r -V "ubuntu-autoinstall" -J -boot-load-size 4 -boot-info-table -input-charset utf-8 -eltorito-alt-boot -b bootpart/eltorito_img1_bios.img -no-emul-boot -o ../install_desktop.iso source-files
else
	echo -e "your are not root\nexecute the script with sudo privileges"
	exit 1
fi

cd /home/dinho
check=`find ./ -type d -name preparation | grep -o preparation`
if test "$check" != preparation
then
	mkdir preparation
fi	 
cd preparation
if test "$SUDO_USER" == "dinho" #Replace "dinho" with root user 
then
	echo "preparing ubuntu-server.iso ....."
	echo -ne '\r'> list.txt
	path=`find /home/dinho/Downloads -type f -name "*ubuntu*server*.iso"`
	i=0
	for j in $path 
	do
		echo "$i -$j" >> list.txt
		: $((i++))
	done
	cat list.txt
	echo choose the iso file to prepare ...
	read k
	path=`cat list.txt | grep "$k -" | cut -d ' ' -f 2`
	echo the file is $path 
	i=`echo $path | wc -c`
	while [[ $i == 1 ]]
	do
		echo choose the iso file to prepare ...
		read path
	done
	echo -ne '\r'> list.txt
	unset i
	unset j
	check=`find ./ -type d -name 'source-file' | grep -o 'source-file'`
	if test "$check" != 'source-file'
	then
		mkdir source-file
	fi
        xorriso -osirrox on -indev $path --extract_boot_images source-file/bootpart -extract / source-file/ 
	chmod 644 source-file/boot/grub/grub.cfg
	mkdir source-file/nocloud
	cp /home/dinho/test/automation/custom_iso_installers/custom_iso/user-data source-file/nocloud/user-data
	touch source-file/nocloud/meta-data
	cat /home/dinho/test/automation/grub_server.cfg > source-file/boot/grub/grub.cfg
	xorriso -as mkisofs -r -V "ubuntu-autoinstall" -J -boot-load-size 4 -boot-info-table -input-charset utf-8 -eltorito-alt-boot -b bootpart/eltorito_img1_bios.img -no-emul-boot -o ../install_server.iso source-file
else
	echo -e "your are not root\nexecute the script with sudo privileges"
	exit 1
fi

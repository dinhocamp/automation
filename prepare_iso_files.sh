echo -e "what is the ubuntu type to prepare ?\nselect 1 for desktop version, 2 for server version (recommended)"
read a
while test $a != '1' -a $a != '2' 
do
	echo -e "enter 1 to install ubuntu desktop or enter 2 for ubuntu server ..."
	read a
done
if test "$SUDO_USER" == "dinho" #Replace "dinho" with root user 
then
	if [ $a == '1' ]
	then
		echo "preparing ubuntu desktop iso file ..."
		bash prepare_iso_desktop.sh
	else
		echo "preparing ubuntu server iso file ..."
		bash prepare_iso_server.sh
	fi
else
	echo -e "your are not root\nexecute the script with sudo privileges"
	exit 1
fi


#!/bin/bash
check_ans=`ansible --version &>./tmp.txt; cat tmp.txt | grep 'not found' | wc -l`
rm ./tmp.txt
if test $check_ans -eq 1 
then
	echo ansible not installed yet
	if test "$SUDO_USER" == "dinho" #Replace "dinho" with root user 
	then
		echo installing ansible
		apt-get install ansible 2> error.txt
		if test $? -eq 0
		then
			echo ansible is installed successfully
			ansible --version
		else
			echo problem downloading ansible
			cat ./error.txt
		fi
	else
		echo -e "your are not root\nexecute the script with sudo privileges"
		exit 1
	fi
else
	echo ansible is installed
	version=`ansible --version`
	echo $version
fi
unset check_ans


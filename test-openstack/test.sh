echo do you want to continuing the envariment setup ?
read a 
while [ "$a" != 'y' ] && [ "$a" != 'n' ]
do
	echo please press y to continue the setup or n to quit
	read a
done
if test $a == 'y'
then
	ansible-playbook scp_Vars.yml
else
	exit 1
fi

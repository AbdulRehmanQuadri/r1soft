#!/bin/bash
#Script by Abdul Rehman

BS=""            #BS --> Backup Server
BSI=""           #BSI --> Backup Server IP
KERNEL=""

if [ -z "$1"  ]
then
	echo "Please provide the Backup server number. E.g: 31,34,2"
	exit
else
BS="r1softbackup"$1".specialservers.com" #BS --> Backup Server
echo "Backup Server Provided: "$BS
fi

BSI=$(host $BS | awk {'print $4'}) #BSI --> Backup Server IP
echo "The IP address of the Backup server is: "$BSI
iptables -I INPUT -s $BSI -j ACCEPT
iptables-save > /dev/null 2>&1
echo "IP of the Backup Server: "$BS" has been ALLOWED in the FIREWALL..." 

echo -e "OS:" $(cat /etc/redhat-release | awk {'print $1'})

#Addind R1soft Repository
rm -f /etc/yum.repos.d/r1soft.repo
echo -e "[R1Soft]\nname=R1Soft Repostory Server\nbaseurl=http://repo.r1soft.com/yum/stable/\$basearch/\neanbled=1\ngpgcheck=0" >> /etc/yum.repos.d/r1soft.repo
echo -e "R1Soft Repository Added..."

#installing cdp agent

#Finding out the kernel and installing respected kernel-devel and kernel-headers
KERNEL=$(uname -r)
echo "Kernel version: "$KERNEL
#if [ $(uname -r | cut -c 1-3) > 3.10 ]
#then 
#	echo "R1Soft does not support kernel version > 3.10, Kindly downgrade the kernel and give a try"
#	exit
#fi



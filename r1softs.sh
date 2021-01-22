
#Finding Distribution
find_distro()
{
	if [ -f '/etc/debian_version' ]; then #Check if Debian based OS	
		if [ `cat /etc/debian_version | grep -i 'Debian' | wc -l` -gt 0 ];then
			OS="Debian"
		elif [ `cat /etc/debian_version | grep -i 'Ubuntu' | wc -l` -gt 0 ];then
			OS="Ubuntu"
		else
			OS="None"
		fi	
	elif [ -f '/etc/redhat-release' ]; then #Check if Redhat based OS
		if [ `cat /etc/redhat-release | grep -i 'Fedora' | wc -l` -gt 0 ];then
			OS="Fedora"	
		elif [ `cat /etc/redhat-release | grep -E -i 'Centos|CloudLinux|Red' | wc -l` -gt 0 ];then
			OS="CentOS"
		else
			OS="None"
		fi
	else
		OS="None"
	fi
}

#Configure R1Soft Repository
r1soft_repo()
{
	echo "Configuring R1Soft Repository..."
 	if [ -f '/etc/yum.repos.d/r1soft.repo' ];then
 		echo -e "[R1Soft]\nname=R1Soft Repostory Server\nbaseurl=http://repo.r1soft.com/yum/stable/\$basearch/\nenabled=1\ngpgcheck=0" >> /etc/yum.repos.d/r1soft.repo
 		echo -e "R1Soft Repository Configured"
	else
		echo -e "[R1Soft]\nname=R1Soft Repostory Server\nbaseurl=http://repo.r1soft.com/yum/stable/\$basearch/\nenabled=1\ngpgcheck=0" >> /etc/yum.repos.d/r1soft.repo
		echo "R1Soft Repository Configured"
	fi
}


#FindKernelVersion and install appropriate kernel headers and devels
find_kernel_install_header_devel()
{
	KERNEL=$(uname -r)
	echo "Kernel version: "$KERNEL
	if [ $(uname -r | cut -c 1-3) > 3.10 ];then 
		echo "R1Soft does not support kernel version > 3.10, Kindly downgrade the kernel and give a try"
		exit
	elif [ $KERNEL -eq "3.10.0-1127.el7.x86_64" ]; then
		echo "Downloading and installing Kernel Headers..."
		echo "Downloading and installing Kernel Devels..."
	elif [ $KERNEL -eq "3.10.0-1160.11.1.el7.x86_64" ]; then
		echo "Downloading and installing Kernel Headers..."
		echo"Downloading and installing Kernel Devels..."
	elif [ $KERNEL -eq "3.10.0-1160.2.2.el7.x86_64" ];then
		echo "Downloading and installing Kernel Headers..."
		echo "Downloading and installing Kernel Devels..."
	else
	       echo "The Kernel Header and Devels of $Kernel yet not configured, Please try to install them manually"	
	       exit
	fi
}

install_cdp()
{
	$(rpm -q cdp)
	if [ $? -eq 0  ]; then
		echo "CDP Agent is already installed"
	else
		echo "Installing CDP Agent, Please be patient..."
		`r1soft-cdp-enterprise-agent -y`
		if [ $? -eq 0 ];then
			echo "CDP Agent Installed Successfully"
		else
			echo "Error Occured!!!, Please try to install CDP Agent manually"
		fi
	fi
}


#Main Function
find_distro
case "$OS" in 
	CentOS*) echo "OS Detected: $OS";;
	Fedora*) echo "OS Detected: $OS";;
	Ubuntu*) echo "OS Detected: $OS";;
	Debian*) echo "OS Detected: $OS";;
	None*) echo "OS Detected: $OS";;
esac
r1soft_repo
#find_kernel_install_header_devel
install_cdp

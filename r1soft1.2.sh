#!/bin/bash
#Script By Abdul Rehman[abdul.rehman@esds.co.in]
#Open for update and Suggestions

BS=""            #BS --> Backup Server
BSI=""           #BSI --> Backup Server IP

if [ -z "$1"  ]
then
        echo "Please provide the Backup server number. E.g: 31,34"
        exit
else
        BS="https://r1softbackup"$1".specialservers.com" #BS --> Backup Server
        echo "Backup Server Provided: "$BS
fi

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

#FindKernelVersion and install appropriate kernel headers and devels
find_kernel_install_header_devel()
{
        KERNEL=$(uname -r)
        echo "Kernel version: "$KERNEL
        if [ $(uname -r | cut -c 1-4) != 3.10 ];then
                echo "R1Soft does not support kernel version > 3.10, Kindly downgrade the kernel and give a try"
                exit
        elif [ $KERNEL == "3.10.0-1127.el7.x86_64" ]; then
                echo "Downloading and installing Kernel Headers..."
                $(wget https://buildlogs.centos.org/c7.2003.00.x86_64/kernel/20200331233310/3.10.0-1127.el7.x86_64/kernel-headers-3.10.0-1127.el7.x86_64.rpm)
                `rpm -ivh kernel-headers-3.10.0-1127.el7.x86_64.rpm --force`

                echo "Downloading and installing Kernel Devels..."
                $(wget https://buildlogs.centos.org/c7.2003.00.x86_64/kernel/20200331233310/3.10.0-1127.el7.x86_64/kernel-devel-3.10.0-1127.el7.x86_64.rpm)
                `rpm -ivh kernel-devel-3.10.0-1127.el7.x86_64.rpm`

        elif [ $KERNEL == "3.10.0-1160.11.1.el7.x86_64" ]; then
                echo "Downloading and installing Kernel Headers..."
                $(wget http://mirror.centos.org/centos/7/updates/x86_64/Packages/kernel-headers-3.10.0-1160.11.1.el7.x86_64.rpm)
                `rpm -ivh kernel-headers-3.10.0-1160.11.1.el7.x86_64.rpm --force`

                echo"Downloading and installing Kernel Devels..."
                $(wget http://mirror.centos.org/centos/7/updates/x86_64/Packages/kernel-devel-3.10.0-1160.11.1.el7.x86_64.rpm)
                rpm -ivh kernel-devel-3.10.0-1160.11.1.el7.x86_64.rpm

        elif [ $KERNEL == "3.10.0-1160.2.2.el7.x86_64" ];then
                echo "Downloading and installing Kernel Headers..."
                $(wget http://mirror.centos.org/centos/7/updates/x86_64/Packages/kernel-headers-3.10.0-1160.2.2.el7.x86_64.rpm)
                `rpm -ivh kernel-headers-3.10.0-1160.2.2.el7.x86_64.rpm`

                echo "Downloading and installing Kernel Devels..."
                $(wget http://mirror.centos.org/centos/7/updates/x86_64/Packages/kernel-devel-3.10.0-1160.2.2.el7.x86_64.rpm)
                rpm -ivh kernel-devel-3.10.0-1160.2.2.el7.x86_64.rpm

        elif [ $KERNEL == "3.10.0-327.el7.x86_64" ];then
                echo "Downloading and installing Kernel Headers..."
                $(wget https://buildlogs.centos.org/c7.1511.00/kernel/20151119220809/3.10.0-327.el7.x86_64/kernel-headers-3.10.0-327.el7.x86_64.rpm)
                `rpm -ivh kernel-headers-3.10.0-327.el7.x86_64.rpm`

                echo "Downloading and installing Kernel Devels..."
                $(wget https://buildlogs.centos.org/c7.1511.00/kernel/20151119220809/3.10.0-327.el7.x86_64/kernel-devel-3.10.0-327.el7.x86_64.rpm)
                rpm -ivh kernel-devel-3.10.0-327.el7.x86_64.rpm

        else
               echo "The Kernel Header and Devels of $KERNEL yet not configured, Please try to install them manually"
               exit
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

install_cdp()
{
        $(rpm -q cdp)
        if [ $? -eq 0  ]; then
                echo "CDP Agent is already installed"
        else
                echo "Installing CDP Agent, Please be patient..."
                `yum install r1soft-cdp-enterprise-agent -y`
                if [ $? -eq 0 ];then
                        echo "CDP Agent Installed Successfully"
                else
                        echo "Error Occured!!!, Please try to install CDP Agent manually"
                fi
        fi
}

build_module()
{
        echo "Building R1soft Modules..."
        $(r1soft-setup --get-module)
        $(service cdp-agent restart)
        $(lsmod | grep hcp)
        if [ $? -eq 0  ];then
                echo "Module builded Successfully"
        else
                echo "Module build failed"
        fi
}


add_key_allow_ip()
{
        BSI=$(host $BS | awk {'print $4'}) #BSI --> Backup Server IP
        echo "The IP address of the Backup server is: "$BSI
        iptables -I INPUT -s $BSI -j ACCEPT
        iptables-save > /dev/null 2>&1
        echo "IP of the Backup Server: "$BS" has been ALLOWED in the FIREWALL..."
        echo "Adding the key of the Backup server..."
        r1soft-setup --get-key "$BS"
        echo "CDP Agent installed successfull, kindly allow the IP of this server on the Backup server:"$BS" "

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
find_kernel_install_header_devel
r1soft_repo
install_cdp
build_module
add_key_allow_ip

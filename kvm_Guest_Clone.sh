#!/bin/bash
#######################################################################################
# Author    : Santosh Kulkarni System Administrator
# Date      : 01-07-2020
# Mail      : santosh.kulkarni4u@gmail.com
# Phone     : +91-9960708564
# Version   : 1.0
# Warrenty  : NO warrenty 
#--------------------------------------------------------------------------------------
# Purpose   : This script is for creating Ansible Lab of 4 Nodes having nameing 
#           : convention Ansnode_1 to Ansnode_4. with use of virt-clone.
#           : By default 2 NIC will be attached to each node. Having networks like NAT and INTERNAL 
# Type      : Independent (Requires to network files at currunt location)
# -------------------------------------------------------------------------------------
##### Exit Codes #########################
# Exit Codes  List
# Exit code 1 = Not Running as root , Base kvm Guest is not exist 
# Exit code 2 = KVM Guest or Attached disk DIR Not Availble  
# Exit code 3 = libvirtd not Running oh Host
# Exit code 4 = Host not supported 
#==========================================#
declare INTERNAL=internal
declare NAT=default
#

###### KVM Guest path Definition  ######
# declare Base_Clone_KVM_NAME=${1:-base_vm}
#### Network Definition ################
# 
#
#==========================================#
######## Functions ###################
DirCheckFunction () 
{
# 
[[ -d "$Attached_Disks_DIR" ]] || mkdir -p "$Attached_Disks_DIR" 
[[ -d "$KVM_Guest_Disk_DIR" ]] || mkdir -p "$KVM_Guest_Disk_DIR" 
#
}
# 
function Print_lines_Funtion()
{
	PrintCHAR=${1:-.}
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "$PrintCHAR"
}
# 
HOST_OS_Version_Check_Function () 
{

if [ -f /etc/lsb-release ]; then
	OS=$DISTRIB_ID
	VER=$DISTRIB_RELEASE
else
	OS="Unknown"
	VER="Unknown"
fi
# 
if [ -f /etc/debian_version ]; then
	OS="Debian"
	VER=$(cat /etc/debian_version)

elif [ -f /etc/redhat-release ]; then
	OS="Red Hat"
	VER=$( awk -F = '/^VERSION_ID/{print $2}'  /etc/os-release | sed 's@"@@g')
	# 
elif [ -f /etc/SuSE-release ]; then
	OS="SuSE"
	VER=$(cat /etc/SuSE-release)
	# 
else
	# 
	OS=$(uname -s)
	VER=$(uname -r)
fi
}
# 
Get_KVM_Guest_Name()
{
found_KVM=$(virsh list --name --all --state-shutoff | sed '/^$/d;s@ @@g' | head -n 1 )
read -p "Enter kvm guest name to clone or use found kvm Default[$found_KVM]:" Base_Clone_KVM_NAME
# 
Base_Clone_KVM_NAME=${Base_Clone_KVM_NAME:-"$found_KVM"}
# 
echo "Base_Clone_KVM_NAME :$Base_Clone_KVM_NAME"
}
#
Get_KVM_Guest_Installation_Path_Funtion ()
{
read -p "Enter kvm guest Installation path  Default[/var/lib/libvirt/images]:" KVM_Guest_Disk_DIR
# 
KVM_Guest_Disk_DIR=${KVM_Guest_Disk_DIR:-/var/lib/libvirt/images}
# 
Attached_Disks_DIR="$KVM_Guest_Disk_DIR/Guest_Attached_Disk"
# 
DirCheckFunction
# 
echo "KVM_Guest_Disk_DIR :$KVM_Guest_Disk_DIR"
} 
Script_Not_Compatible_with_Function ()
{
 Print_lines_Funtion "#"
 echo "OS System found  : $OS"
 Print_lines_Funtion 
 echo "OS Version found : $VER"
 Print_lines_Funtion -
 echo "NOTICE: This Script is at present NOT SUPPORTED to this Version"
 Print_lines_Funtion -
 echo "Share the the code if you have. We will merge it in Repository"
 Print_lines_Funtion -
 echo "Repository Path : https://github.com/santosh2712/KVM_Setup_Ansible_Lab"
 Print_lines_Funtion -
 echo "Exiting Script with error code 4"
 Print_lines_Funtion "#"
 exit 4 
} 

Fount_OS_Display_Funtion ()
{
	echo "Found Host OS : $OS"
	echo "Found Host OS is $OS with Version : $VER"
}

ERROR_CODE1_ERROR_MASSSAGE_Function () 
{
	Print_lines_Funtion =
	echo "Exiting with Error CODE 1 . Possible reasons are as below"
	echo "1: Script is NOT RUNNING as root or Use privilege escalation method"
	echo '2: KVM Guest with name "'$Base_Clone_KVM_NAME'" exist and in shutdown state'
	echo 'Use below command to get existing kvm guest names'
	echo '#sudo virsh list --name --all'
	Print_lines_Funtion 
	echo "Exiting Script with error code 1"
	Print_lines_Funtion =
	exit 1 

}

IF_HOST_OS_RedHat7_Or_CentOS7_Function () 
{
Print_lines_Funtion	
Fount_OS_Display_Funtion
Print_lines_Funtion	
#
Get_KVM_Guest_Name 
Print_lines_Funtion	
# 
Get_KVM_Guest_Installation_Path_Funtion
# 
virsh shutdown "$Base_Clone_KVM_NAME" > /dev/null 2>&1
wait 
# Print_lines_Funtion
# 
declare -i VM_Exist_Count=$(sudo virsh list --all | grep "$Base_Clone_KVM_NAME" | wc -l  )
declare base_VM_State=$( virsh list --state-shutoff | grep -o "$Base_Clone_KVM_NAME" )
# 
if [[ $EUID -eq 0 ]] && [ $VM_Exist_Count -eq 1 ] && [[ "$base_VM_State" = "$Base_Clone_KVM_NAME"  ]] ; then
	#statements
	DirCheckFunction
	# 
	if [[ -w "$KVM_Guest_Disk_DIR"  ]] && [[ -w "$Attached_Disks_DIR" ]]  ; then
		#statements
		#	
		Print_lines_Funtion =
		echo "Refreshing Networks $NAT $INTERNAL"
		Print_lines_Funtion =
		# 
		for i in "$NAT"  "$INTERNAL"  ; do
			#
			virsh net-info --network "$i"  > /dev/null 2>&1
			if [[  $(echo $?) -eq  0  ]]; then
				# 
				Print_lines_Funtion -
				echo "INFO:Network $i is already exist. Script not not recreate it"
				Print_lines_Funtion -
				# 
			else 	
				#
				virsh net-destroy "$i" >> /dev/null 2>&1
				virsh net-undefine  "$i" >> /dev/null 2>&1 
				virsh net-define  --file "$i".xml >> /dev/null 2>&1 
				virsh net-start   "$i" >> /dev/null 2>&1 
				virsh net-autostart   "$i" >> /dev/null 2>&1 
				# 
				Print_lines_Funtion -
				echo "Info: Network $i is Created. Starting network $i"
				Print_lines_Funtion -
				# 
				virsh net-start "$i" >> /dev/null 2>&1
				# 
			fi
			#
		done
			#
			declare Libvirtd_Status=$(systemctl is-active libvirtd)
			# 
		if [[ "$Libvirtd_Status" == "active" ]]; then
			# 
			Print_lines_Funtion -
			echo "service libvirtd found running. Make Sure $Base_Clone_KVM_NAME is shutdown"
			Print_lines_Funtion -
			# 
			virsh shutdown --domain  base_vm  >> /dev/null 2>&1
			# 
			Print_lines_Funtion -
			echo "Destroying & Recreating  KVM Guests with Name AnsNode1 to 4 "
			Print_lines_Funtion -
			#	 
			for i in 1 2 3 4 ; do
				# 
				declare VMNAME="AnsNode_$i"
				virsh shutdown --domain  "$VMNAME"   >> /dev/null 2>&1
				virsh destroy  --domain  "$VMNAME"  >> /dev/null 2>&1
				virsh undefine --domain  "$VMNAME"  >> /dev/null 2>&1
				# 
				declare KVM_DISK="$KVM_Guest_Disk_DIR/$VMNAME.qcow2"
				declare Attached_Disk="$Attached_Disks_DIR/$VMNAME-2GB"
				# 
				rm -f "$KVM_DISK" >> /dev/null 2>&1
				rm -f "$Attached_Disk" > /dev/null 2>&1
				# 
				Print_lines_Funtion =
				echo "Cloning in Progress from $Base_Clone_KVM_NAME to $VMNAME"
				Print_lines_Funtion =
				# 
				virt-clone  --check all=off  --original "$Base_Clone_KVM_NAME" --name "$VMNAME"  --file "$KVM_DISK" 
				# 
				qemu-img create -f  raw "$Attached_Disk" 2G     >> /dev/null 2>&1
				echo "Creating $Attached_Disk to Attach $VMNAME "
				Print_lines_Funtion =
				# 
				virsh attach-disk "$VMNAME"  --source  "$Attached_Disk" --target vdb --persistent
				#
				# echo "=========================================================="
				# virsh autostart --domain  "$VMNAME"
				sleep 10  && virsh start  "$VMNAME" 
				# 
				Print_lines_Funtion =
				echo -e "Attaching NIC eth$i TO $NAT network.\\nAnd ens$i TO $INTERNAL network ON $VMNAME"
				Print_lines_Funtion =
				# 
				virsh attach-interface "$VMNAME" network  "$NAT" 		--target "eth$i" --mac 52:54:00:35:10:5"$i"  --config --live
				virsh attach-interface "$VMNAME" network  "$INTERNAL" 	--target "ens$i" --mac 52:54:00:34:98:5"$i"  --config --live
				# virsh attach-interface --domain "$VMNAME"  --type bridge  --source br1 --model virtio --config --live
				# 
			done
				# 
		else
			# 
			Print_lines_Funtion =
			echo "libvirtd service is not running. Exiting Script."
			Print_lines_Funtion =
			exit 3 
		fi
		# 
	else
		
		Print_lines_Funtion =
		echo -e "Ensure $KVM_Guest_Disk_DIR and $Attached_Disks_DIR directory's  are writable.\\n Exiting Script." 
		Print_lines_Funtion =
	fi
	# 
else
	# 
	ERROR_CODE1_ERROR_MASSSAGE_Function
	# 
fi
# 
}
# 
IF_HOST_OS_RedHat8_Or_CentOS8_Function () 
{
Print_lines_Funtion	
Fount_OS_Display_Funtion
Print_lines_Funtion	
# 
Get_KVM_Guest_Name
Print_lines_Funtion
# 
Get_KVM_Guest_Installation_Path_Funtion
# 
# echo "Shutting down $Base_Clone_KVM_NAME.....!"
virsh shutdown "$Base_Clone_KVM_NAME" > /dev/null 2>&1
wait 
# Print_lines_Funtion
declare -i VM_Exist_Count=$(sudo virsh list --all | grep "$Base_Clone_KVM_NAME" | wc -l  )
declare base_VM_State=$( virsh list --state-shutoff | grep -o "$Base_Clone_KVM_NAME" )
# 
# 
if [[ $EUID -eq 0 ]] && [ $VM_Exist_Count -eq 1 ] && [[ "$base_VM_State" = "$Base_Clone_KVM_NAME"  ]] ; then
	#statements
	DirCheckFunction
	# 
	if [[ -w "$KVM_Guest_Disk_DIR"  ]] && [[ -w "$Attached_Disks_DIR" ]]  ; then
		#statements
		#	
		Print_lines_Funtion =
		echo "Refreshing Networks $NAT $INTERNAL"
		Print_lines_Funtion =
		# 
		for i in "$NAT"  "$INTERNAL"  ; do
			#
			virsh net-info --network "$i"  > /dev/null 2>&1
			if [[  $(echo $?) -eq  0  ]]; then
				# 
				Print_lines_Funtion -
				sudo virsh net-start --network "$i"  > /dev/null 2>&1
				echo "INFO:Network $i is already exist. Script not not recreate it"
				Print_lines_Funtion -
				# 
			else 	
				#
				virsh net-destroy "$i" >> /dev/null 2>&1
				virsh net-undefine  "$i" >> /dev/null 2>&1 
				virsh net-define  --file "$i".xml >> /dev/null 2>&1 
				virsh net-start   "$i" >> /dev/null 2>&1 
				virsh net-autostart   "$i" >> /dev/null 2>&1 
				# 
				Print_lines_Funtion -
				echo "Info: Network $i is Created. Starting network $i"
				Print_lines_Funtion -
				# 
				virsh net-start "$i" >> /dev/null 2>&1
				# 
			fi
			#
		done
			#
			declare Libvirtd_Status=$(systemctl is-active libvirtd)
			# 
		if [[ "$Libvirtd_Status" == "active" ]]; then
			# 
			Print_lines_Funtion -
			echo "service libvirtd found running. Make Sure $Base_Clone_KVM_NAME is shutdown"
			Print_lines_Funtion -
			# 
			virsh shutdown --domain  base_vm  >> /dev/null 2>&1
			# 
			Print_lines_Funtion -
			echo "Destroying & Recreating  KVM Guests with Name AnsNode1 to 4 "
			Print_lines_Funtion -
			#	 
			for i in 1 2 3 4 ; do
				# 
				declare VMNAME="AnsNode_$i"
				virsh shutdown --domain  "$VMNAME"   >> /dev/null 2>&1
				virsh destroy  --domain  "$VMNAME"  >> /dev/null 2>&1
				virsh undefine --domain  "$VMNAME"  >> /dev/null 2>&1
				# 
				declare KVM_DISK="$KVM_Guest_Disk_DIR/$VMNAME.qcow2"
				declare Attached_Disk="$Attached_Disks_DIR/$VMNAME-2GB"
				# 
				rm -f "$KVM_DISK" >> /dev/null 2>&1
				rm -f "$Attached_Disk" > /dev/null 2>&1
				# 
				Print_lines_Funtion =
				echo "Cloning in Progress from $Base_Clone_KVM_NAME to $VMNAME"
				Print_lines_Funtion =
				# 
				virt-clone  --check all=off  --original "$Base_Clone_KVM_NAME" --name "$VMNAME"  --file "$KVM_DISK" 
				# 
				qemu-img create -f  raw "$Attached_Disk" 2G     >> /dev/null 2>&1
				echo "Creating Additional disk named $Attached_Disk to Attach $VMNAME "
				# 
				virsh attach-disk "$VMNAME"  --source  "$Attached_Disk" --target vdb --persistent
				#
				# echo "=========================================================="
				# virsh autostart --domain  "$VMNAME"
				Print_lines_Funtion =
				Print_lines_Funtion 
				echo -e "Attaching NIC eth$i TO $NAT network.\\nAnd ens$i TO $INTERNAL network ON $VMNAME"
				virsh attach-interface --domain "$VMNAME" --type network --source  "$NAT" --target "eth$i" --mac 52:54:00:35:10:5"$i"  --current
				Print_lines_Funtion 
				virsh attach-interface --domain  "$VMNAME" --type network --source "$INTERNAL"  --target "ens$i" --mac 52:54:00:34:98:5"$i"  --current
				echo "Cloning done for $VMNAME ! Starting $VMNAME"
				Print_lines_Funtion =
				# 
				# 
				sleep 10  && virsh start  "$VMNAME" 
				# virsh attach-interface --domain "$VMNAME"  --type bridge  --source br1 --model virtio --config --live
				# 
			done
				# 
		else
			# 
			Print_lines_Funtion =
			echo "libvirtd service is not running. Exiting Script."
			Print_lines_Funtion =
			exit 3 
		fi
		# 
	else
		
		Print_lines_Funtion =
		echo -e "Ensure $KVM_Guest_Disk_DIR and $Attached_Disks_DIR directory's  are writable.\\n Exiting Script." 
		Print_lines_Funtion =
	fi
	# 
else 
	# 
	ERROR_CODE1_ERROR_MASSSAGE_Function
	# 
fi
# 
}

#==========================================#
###### Script Body #################

HOST_OS_Version_Check_Function
# 
# 
if 	[[ $OS == "Red Hat" ]]  ; then
	
	if 	 [[ $OS == "Red Hat" ]] && [ $VER -eq 6 ]  ; then
			Script_Not_Compatible_with_Function 
	elif [[ $OS == "Red Hat" ]] && [ $VER -eq 7 ]  ; then
			IF_HOST_OS_RedHat7_Or_CentOS7_Function
	elif [[ $OS == "Red Hat" ]] && [ $VER -eq 8 ]  ; then
			# 
			IF_HOST_OS_RedHat8_Or_CentOS8_Function
			# 
			Print_lines_Funtion 
			echo "In some cases kvm guest auto hostname setting not work. Check attached default.xml "
			Print_lines_Funtion 
	else 	
			Script_Not_Compatible_with_Function
	fi

elif [[ $OS == "Debian" ]] ; then
		 Script_Not_Compatible_with_Function
elif [[ $OS == "SuSE"   ]]; then
		 Script_Not_Compatible_with_Function
else 
		 Script_Not_Compatible_with_Function
fi

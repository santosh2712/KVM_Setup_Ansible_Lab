#!/bin/bash
#######################################################################################
# Author    : Santosh Kulkarni System Administrator
# Date      : 10-07-2020
# Mail      : santosh.kulkarni4u@gmail.com
# Phone     : +91-9960708564
# Version   : 1.1
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
declare INTERNAL=my_lab_internal
declare NAT=my_lab_nat
#
# =======================================#
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
# echo "Base_Clone_KVM_NAME :$Base_Clone_KVM_NAME"
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
Script_is_not_compatible_with_Host_OS_Function ()
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

Error_Code_1_MASSAGE_Function () 
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
# 
Check_and_Define_Networks_IfnotFound_Funtion () 
{
#	
Print_lines_Funtion =
echo "Checking Virtual Networks $NAT $INTERNAL"
Print_lines_Funtion =
# 
for i in "$NAT"  "$INTERNAL"  ; do
	#
	virsh net-info --network "$i"  > /dev/null 2>&1
	if [[  $(echo $?) -eq  0  ]]; then
		# 
		Print_lines_Funtion -
		echo "INFO:Network $i is already exist. Script will not recreate it"
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
		echo "INFO: Network $i is Created. Starting network $i"
		Print_lines_Funtion -
		# 
		# 
	fi
	#
done
}
# 
Clear_all_Old_Cloned_Guests_Funtion () 
{
function YES ()
 { 
	for i in $(seq 1 99 ) ; do
		# 
		declare VMNAME="AnsNode_$i"
		virsh shutdown --domain  "$VMNAME"   >> /dev/null 2>&1
		wait
		virsh destroy  --domain  "$VMNAME"  >> /dev/null 2>&1
		wait 
		virsh  undefine --domain "$VMNAME"  --delete-snapshots --remove-all-storage >> /dev/null 2>&1
		wait 
	done
	Print_lines_Funtion -
	echo "INFO: Cleared all KVM guest with from AnsNode_01 to AnsNode_99"	
	Print_lines_Funtion -
 }

function  NO ()
 {
	Print_lines_Funtion -
	echo "INFO: Script will only clear old instance for requested."
	Print_lines_Funtion -

 }
 echo "Do you want to clear all existing guest with name Ansnode_* " 
 echo -e  "\e[30;43;5;82m| Choose an option: Enter input between 1-3 only |\e[0m"\\n'==================================================='
		options=("Clear All AnsNode_* Guests " "Clear only New AnsNode_ Guests" "Quit")
        select opt in "${options[@]}"; do
            #
            case $REPLY in
                1) YES ; break ;;
                2) NO ; break ;;
                3) break 2 ;;
                *) echo "Wrong input! Please Input Numbers only from 1 to 3" >&2
            esac
            #
        done

}
Create_Uniform_Guest_Clones_Funtion () 
{
# 
# 
Print_lines_Funtion -
echo  "Script can clone Maximum 99 KVM guest with Fixed IP allocation"
read -p "Enter Number of Clones you want for Lab Default [2]: " CloneCount
Print_lines_Funtion -

declare -i CloneCount=${CloneCount:-2}
declare -i Last_VM_Clone_Number=$((CloneCount+0))

if [[ $Last_VM_Clone_Number -lt 1 ]] ; then 
	declare -i Last_VM_Clone_Number=1
	echo "INFO: Incorrect input received Cloning 1 Guests. Input Value should be from 1 to 99 "
elif [[ $Last_VM_Clone_Number -gt 99 ]]; then
	declare -i Last_VM_Clone_Number=99
	echo "INFO: Script can clone only 99 Guests.Input Value should be from 1 to 99 "
fi
echo "INFO: Script will Clone $Last_VM_Clone_Number KVM Guests. From $Base_Clone_KVM_NAME Guest"
Print_lines_Funtion -

for i in $(seq 1 $Last_VM_Clone_Number ) ; do
	# 
	# echo $i 
	declare VMNAME="AnsNode_$i"
	virsh shutdown --domain  "$VMNAME"   >> /dev/null 2>&1
	wait
	virsh destroy  --domain  "$VMNAME"  >> /dev/null 2>&1
	wait
	virsh  undefine --domain "$VMNAME"  --delete-snapshots --remove-all-storage >> /dev/null 2>&1
	wait 
	# 
	declare Attached_Disk_SIZE=2G
	declare KVM_DISK="$KVM_Guest_Disk_DIR/$VMNAME.qcow2"
	
	declare Attached_Disk="$Attached_Disks_DIR/$VMNAME"'_raw_'"$Attached_Disk_SIZE"
	# 
	rm -f "$KVM_DISK" >> /dev/null 2>&1
	rm -f "$Attached_Disk" > /dev/null 2>&1
	# 
	# echo "Attached_Disk: $Attached_Disk"
	Print_lines_Funtion =
	echo "Cloning in Progress from $Base_Clone_KVM_NAME to $VMNAME"
	Print_lines_Funtion 
	# 
	virt-clone  --check all=off  --original "$Base_Clone_KVM_NAME" --name "$VMNAME"  --file "$KVM_DISK" 
	# 
	qemu-img create -f  raw "$Attached_Disk" "$Attached_Disk_SIZE"     >> /dev/null 2>&1
	echo "Additional disk $Attached_Disk is Created and it will be Attached to $VMNAME."
	# 
	virsh attach-disk --source "$Attached_Disk" --persistent --domain "$VMNAME"  --target 'vdb'
	Print_lines_Funtion 
	# 
	echo "Attaching NIC eth$i TO $NAT network ON $VMNAME"
	virsh attach-interface --domain "$VMNAME" --type network --source  "$NAT" --target "eth$i" --mac 52:54:00:10:10:"$i"  --current
	Print_lines_Funtion
	# 
	echo "Attaching NIC ens$i TO $INTERNAL network ON $VMNAME"
	virsh attach-interface --domain "$VMNAME" --type network --source "$INTERNAL"  --target "ens$i" --mac 52:54:00:20:20:"$i"  --current
	Print_lines_Funtion 
	echo "Setting Memory limit of 512 MB $VMNAME"
	virsh  setmaxmem --domain "$VMNAME" --current --size 512m
	wait
	Print_lines_Funtion 
	echo "Setting single CPU LIMIT for  $VMNAME"
	virsh setvcpus --domain "$VMNAME" --current --count 1
	wait
	Print_lines_Funtion 

	echo "Cloning done for $VMNAME ! Starting $VMNAME"
	sleep 10  && virsh start  "$VMNAME" 
	Print_lines_Funtion =
	
done
# 
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
			Check_and_Define_Networks_IfnotFound_Funtion
			#
			declare Libvirtd_Status=$(systemctl is-active libvirtd)
			# 
		if [[ "$Libvirtd_Status" == "active" ]]; then
			# 
			Print_lines_Funtion -
			echo "INFO: Service libvirtd found running. "
			Print_lines_Funtion -
			# 
			# 
			Print_lines_Funtion -
			echo "Destroying & Recreating  KVM Guests with Name AnsNode1 to 4 "
			Print_lines_Funtion -
			#
			# 
			Create_Uniform_Guest_Clones_Funtion 
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
	Error_Code_1_MASSAGE_Function
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
			Check_and_Define_Networks_IfnotFound_Funtion
			#
			declare Libvirtd_Status=$(systemctl is-active libvirtd)
			# 
		if [[ "$Libvirtd_Status" == "active" ]]; then
			# 
			Print_lines_Funtion -
			echo "INFO: Service libvirtd found running. "
			Print_lines_Funtion -
			# 
			# 
			Print_lines_Funtion -
			Clear_all_Old_Cloned_Guests_Funtion
			Print_lines_Funtion -
			#
			# 
			Create_Uniform_Guest_Clones_Funtion 
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
	Error_Code_1_MASSAGE_Function
	# 
fi
# 
}


# 
IF_HOST_OS_RedHat_fedora36 () 
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
			Check_and_Define_Networks_IfnotFound_Funtion
			#
			# declare Libvirtd_Status=$(systemctl is-active libvirtd)
			declare Libvirtd_Status="active"
			# 
		if [[ "$Libvirtd_Status" == "active" ]]; then
			# 
			Print_lines_Funtion -
			echo "INFO: Service libvirtd found running. "
			Print_lines_Funtion -
			# 
			# 
			Print_lines_Funtion -
			Clear_all_Old_Cloned_Guests_Funtion
			Print_lines_Funtion -
			#
			# 
			Create_Uniform_Guest_Clones_Funtion 
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
	Error_Code_1_MASSAGE_Function
	# 
fi
# 
}
#==========================================#
#  Script Body Section 
# 
HOST_OS_Version_Check_Function
# 
# 
if 	[[ $OS == "Red Hat" ]]  ; then
	
	if 	 [[ $OS == "Red Hat" ]] && [ $VER -eq 6 ]  ; then
			Script_is_not_compatible_with_Host_OS_Function 
	elif [[ $OS == "Red Hat" ]] && [ $VER -eq 7 ]  ; then
			IF_HOST_OS_RedHat7_Or_CentOS7_Function
	elif [[ $OS == "Red Hat" ]] && [ $VER -eq 8 ]  ; then
			# 
			IF_HOST_OS_RedHat8_Or_CentOS8_Function
			# 
			Print_lines_Funtion 
			echo "In some cases kvm guest auto hostname setting not work. Check attached default.xml "
			Print_lines_Funtion 
	elif [[ $OS == "Red Hat" ]] && [ $VER -eq 36 ]  ; then
			# 
			IF_HOST_OS_RedHat_fedora36
			# 
			Print_lines_Funtion 
			echo "In some cases kvm guest auto hostname setting not work. Check attached default.xml "
			Print_lines_Funtion 

	else 	
			Script_is_not_compatible_with_Host_OS_Function
	fi

elif [[ $OS == "Debian" ]] ; then
		 Script_is_not_compatible_with_Host_OS_Function
elif [[ $OS == "SuSE"   ]]; then
		 Script_is_not_compatible_with_Host_OS_Function
else 
		 Script_is_not_compatible_with_Host_OS_Function
fi

#!/bin/bash
#######################################################################################
# Author    : Santosh Kulkarni System Administrator
# Date      : 10-02-2020
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
# Exit code 1 = Not Running as root
# Exit code 2 = KVM Guest or Attached disk DIR Not Availble  
# Exit code 3 = libvirtd not Running oh Host
#==========================================#
# 
#### Network Definition ################
declare NAT=default
declare INTERNAL=internal
###### KVM Guest path Definition  ######
declare KVM_Guest_Disk_DIR="/data/KVM_DATA/CentOS7_Guests" 
declare Attached_Disks_DIR="/data/KVM_DATA/Attached_Disks"
declare Base_Clone_KVM_NAME="base_vm"
#
#==========================================#
######## Functions ###################
DirCheckFunction () 
{
if [[ -d "$KVM_Guest_Disk_DIR" ]]; then
	echo "$KVM_Guest_Disk_DIR Directory Found"
	# 
else 
	echo "Creating $KVM_Guest_Disk_DIR Directory"
	mkdir -p "$KVM_Guest_Disk_DIR" 	
	# 
fi
#
if [[ -d "$Attached_Disks_DIR" ]]; then
	echo "$Attached_Disks_DIR Directory Found"
	# 
else 
	echo "Creating $Attached_Disks_DIR Directory"
	mkdir -p "$Attached_Disks_DIR" 	
	# 
fi
#
}
#==========================================#
###### Script Body #################
# shuut Down Base clone vm
echo "Shutting down $Base_Clone_KVM_NAME.....!"

virsh shutdown "$Base_Clone_KVM_NAME" > /dev/null 2>&1

wait 

declare base_VM_State=$( virsh list --state-shutoff | grep -o "$Base_Clone_KVM_NAME" )

if [[ $UID -eq 0 ]] && [[ "$base_VM_State" = "$Base_Clone_KVM_NAME"  ]] ; then
	#statements
	# 
	echo "=========================================================="
	echo "Checking Required Directory's"
	#
	DirCheckFunction
	# 
	if [[ -w "$KVM_Guest_Disk_DIR"  ]] && [[ -w "$Attached_Disks_DIR" ]]  ; then
		#statements
		#	
		echo "=========================================================="
		echo "Refreshing Networks $NAT $INTERNAL"
		echo "------------------------"
		# 
		for i in "$NAT"  "$INTERNAL"  ; do
			#
			virsh net-info --network "$i"  > /dev/null 2>&1
			if [[  $(echo $?) -eq  0  ]]; then
				# 
				echo "INFO:Network $i is already Exist. Will not recreate it"
				echo "------------------------"
			else 	
				#
				virsh net-destroy "$i" >> /dev/null 2>&1
				virsh net-undefine  "$i" >> /dev/null 2>&1 
				virsh net-define  --file "$i".xml >> /dev/null 2>&1 
				virsh net-start   "$i" >> /dev/null 2>&1 
				virsh net-autostart   "$i" >> /dev/null 2>&1 
				echo "Info: Network $i is Created. Starting network $i"
				echo "------------------------"
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
			echo "service libvirtd found running. Make Sure $Base_Clone_KVM_NAME is shutdown"
			# 
			virsh shutdown --domain  base_vm  >> /dev/null 2>&1
			echo "=========================================================="
			echo "Destroying & Recreating  KVM Guests with Name AnsNode1 to 4 "
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
				echo "Cloning in Progress from $Base_Clone_KVM_NAME to $VMNAME"
				echo "=========================================================="
				virt-clone  --check all=off  --original "$Base_Clone_KVM_NAME" --name "$VMNAME"  --file "$KVM_DISK" 
				# 
				qemu-img create -f  raw "$Attached_Disk" 2G     >> /dev/null 2>&1
				echo "=========================================================="
				echo "Creating $Attached_Disk to Attach $VMNAME "
				echo "=========================================================="
				virsh attach-disk "$VMNAME"  --source  "$Attached_Disk" --target vdb --persistent
				#
				# echo "=========================================================="
				# virsh autostart --domain  "$VMNAME"
				echo "=========================================================="
				sleep 10  && virsh start  "$VMNAME" 
				echo "=========================================================="
				echo -e "Attaching NIC eth$i TO $NAT network.\\nAnd ens$i TO $INTERNAL network ON $VMNAME"
				echo "----------------------------------------------------------"
				virsh attach-interface "$VMNAME" network  "$NAT" 		--target "eth$i" --mac 52:54:00:35:10:5"$i" 
				virsh attach-interface "$VMNAME" network  "$INTERNAL" 	--target "ens$i" --mac 52:54:00:34:98:5"$i" 
				echo "=========================================================="
				# 
			done
				# 
		else
			echo "=========================================================="
			echo "libvirtd service is not running. Exiting Script."
			echo "=========================================================="
			exit 3 
		fi
		# 
	else		
		echo "=========================================================="
		echo -e "Ensure $KVM_Guest_Disk_DIR and $Attached_Disks_DIR directory's  are writable.\\n Exiting Script." 
		echo "=========================================================="
	fi
	# 
else 
	echo "=========================================================="
	echo -e "Login as root user to run this script. \\nAnd Make sure kvm guest $Base_Clone_KVM_NAME is at shutdown state.\\nExiting script."
	echo "=========================================================="
	exit 1 
fi
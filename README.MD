# KVM Guest Cloning for Ansible Practice Lab 

This script is useful  to practice ansible and for exam preparation of  Red Hat EX407 . The script can perform the following operation.

- Provides Immutable setup for ansible practices 
- Perform kvm guest cloning :  create 4 KVM guest from 1 kvm guest
- Auto Creation of Network: it Create 2 Network named default which is nat and internal for host-guest and host-host intercommunication 
- The script attache 2GB addition disk to perform LVM and other additional practices
- It provides immtuable infra for Ansible lab Practices 

### Prerequisites
- One KVM Host CentOS/Red Hat version 7 or  8
- One KVM guest installed  which you want clone for ansible lab practices. Remove any attached  NIC from Clone_Guest as script will add 2 NIC’s  and networks on fly. Remove any network file for NIC at /etc/sysconfig/network-scripts/fcfg-[ removed NIC NAME ]  to avoid network conflict 
- Set hostname to ‘localhost’ to clone_guest  as default network will auto set hostnames from ansnode_1 to ansnode_4 
- Set clone_Guest size as small as possible as we will creat around 4 instances for the same. 15 Gb will be sufficient for practice 

## Installation  
Use following command from terminal. In case git is not present in you machine then download the code and extract code. 
```
git clone git@github.com:santosh2712/KVM_Setup_Ansible_Lab.git 
```
## Usage
Ensure 3 files exist in script folder 1st is 'kvm_Guest_Clone.sh'  2nd is 'default.xml' which is used for default network and 3rd is 'internal.xml' which is used for internal network .
```
[root@centos8_master KVM_Setup_Ansible_Lab]# pwd
/home/santosh/my_code/KVM_Setup_Ansible_Lab

[root@centos8_master KVM_Setup_Ansible_Lab]# ls -l 
total 24
-rwxrwxr-x. 1 santosh santosh   740 Jul  1 16:18 default.xml
-rwxrwxr-x. 1 santosh santosh   588 Jul  1 16:18 internal.xml
-rwxrwxr-x. 1 santosh santosh 13055 Jul  7 15:14 kvm_Guest_Clone.sh
[root@centos8_master KVM_Setup_Ansible_Lab]#
```
Open Terminal and login as root. Switch to the directory where you copied the code.
Make user you have read the  guest name properly that you want to clone. To get the list of  available kvm guest names  issue following command
```
[root@centos8_master KVM_Setup_Ansible_Lab]# virsh list --all
 Id    Name                           State
----------------------------------------------------
 -     Clone_Guest                    shut off
```
In our case we will be using  “Clone_Guest” to clone and creat ansible practice lab from it. 

So lets begin cloning process by issuing following command from script directory 

```
 Sh kvm_Guest_Clone.sh   
[root@centos8_master KVM_Setup_Ansible_Lab]# sh kvm_Guest_Clone.sh 
..............................................
Found Host OS : Red Hat
Found Host OS is Red Hat with Version : 8
..............................................
Enter kvm guest name to clone or use found kvm Default[AnsNode_2]:Clone_Guest
Base_Clone_KVM_NAME :Clone_Guest
..............................................
Enter kvm guest Installation path  Default[/var/lib/libvirt/images]:
KVM_Guest_Disk_DIR :/var/lib/libvirt/images
=================================
Refreshing Networks default internal
=================================
..............................................
Info: Network default is Created. Starting network default
..............................................
..............................................
Info: Network internal is Created. Starting network internal
..............................................
..............................................
service libvirtd found running. Make Sure Clone_Guest is shutdown
..............................................
..............................................
Destroying & Recreating  KVM Guests with Name AnsNode1 to 4 
..............................................
=================================
Cloning in Progress from Clone_Guest to AnsNode_1
=================================
Allocating 'AnsNode_1.qcow2'                                                |  15 GB  00:00:06     
Clone 'AnsNode_1' created successfully.
Creating Additional disk named /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_1-2GB to Attach AnsNode_1 
Disk attached successfully
=================================
..............................................
Attaching NIC eth1 TO default network.
And ens1 TO internal network ON AnsNode_1
Interface attached successfully
..............................................
Interface attached successfully
Cloning done for AnsNode_1 ! Starting AnsNode_1
=================================
Domain AnsNode_1 started
=================================
Cloning in Progress from Clone_Guest to AnsNode_2
=================================
Allocating 'AnsNode_2.qcow2'                                                |  15 GB  00:00:15     
Clone 'AnsNode_2' created successfully.
Creating Additional disk named /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_2-2GB to Attach AnsNode_2 
Disk attached successfully
=================================
..............................................
Attaching NIC eth2 TO default network.
And ens2 TO internal network ON AnsNode_2
Interface attached successfully
..............................................
Interface attached successfully
Cloning done for AnsNode_2 ! Starting AnsNode_2
=================================
Domain AnsNode_2 started
=================================
Cloning in Progress from Clone_Guest to AnsNode_3
=================================
Allocating 'AnsNode_3.qcow2'                                                |  15 GB  00:00:13     
Clone 'AnsNode_3' created successfully.
Creating Additional disk named /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_3-2GB to Attach AnsNode_3 
Disk attached successfully
=================================
..............................................
Attaching NIC eth3 TO default network.
And ens3 TO internal network ON AnsNode_3
Interface attached successfully
..............................................
Interface attached successfully
Cloning done for AnsNode_3 ! Starting AnsNode_3
=================================
Domain AnsNode_3 started
=================================
Cloning in Progress from Clone_Guest to AnsNode_4
=================================
Allocating 'AnsNode_4.qcow2'                                                |  15 GB  00:00:18     
Clone 'AnsNode_4' created successfully.
Creating Additional disk named /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_4-2GB to Attach AnsNode_4 
Disk attached successfully
=================================
..............................................
Attaching NIC eth4 TO default network.
And ens4 TO internal network ON AnsNode_4
Interface attached successfully
..............................................
Interface attached successfully
Cloning done for AnsNode_4 ! Starting AnsNode_4
=================================
Domain AnsNode_4 started
..............................................
In some cases kvm guest auto hostname settings do not work. Check attached default.xml 
..............................................
[root@centos8_master KVM_Setup_Ansible_Lab]# 
```
# Congratulations you have cloned 4 KVM guests for Ansible lab practice. Verify the deployment as follows. 

```
[root@centos8_master KVM_Setup_Ansible_Lab]# virsh list --all
 Id    Name                           State
----------------------------------------------------
 6     AnsNode_1                      running
 7     AnsNode_2                      running
 8     AnsNode_3                      running
 9     AnsNode_4                      running
 -     Clone_Guest                    shut off

```

# Verify the deployment as follows :-

```
[root@centos8_master KVM_Setup_Ansible_Lab]# virsh list --all
 Id    Name                           State
----------------------------------------------------
 6     AnsNode_1                      running
 7     AnsNode_2                      running
 8     AnsNode_3                      running
 9     AnsNode_4                      running
 -     Clone_Guest                    shut off

Let's check it for 1st host 

[root@centos8_master KVM_Setup_Ansible_Lab]# ssh 192.168.10.101
root@192.168.10.101's password: 
Last login: Fri Jul  3 16:22:33 2020
[root@ansnode_1 ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:35:10:51 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.101/24 brd 192.168.10.255 scope global noprefixroute dynamic ens1
       valid_lft 2442sec preferred_lft 2442sec
    inet6 fe80::acc7:6afb:5bfb:2c0c/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: ens2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:34:98:51 brd ff:ff:ff:ff:ff:ff
    inet 192.168.20.101/24 brd 192.168.20.255 scope global noprefixroute dynamic ens2
       valid_lft 2617sec preferred_lft 2617sec
    inet6 fe80::3f69:8674:6563:5033/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
[root@ansnode_1 ~]# 

```

# Network configuration will be as follows for Ansible Practice lab. 

Guest Cloned Name  | Default NAT Network IP Address | Internal Network IP Address 
--------------- | --------------- |---------------
AnsNode_1 | 192.168.10.101 | 192.168.20.101
AnsNode_2 | 192.168.10.102 | 192.168.20.102
AnsNode_3 | 192.168.10.103 | 192.168.20.103
AnsNode_4 | 192.168.10.104 | 192.168.20.104

# Best of Luck ! Hope it Helped you in some way.

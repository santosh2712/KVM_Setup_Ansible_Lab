# KVM Guest Cloning for Ansible lab / FreeIPA lab / Testing lab    
## Introduction 
This is KVM Guest cloning script useful for creating Lab Environment for various scenarios. Like Exam Practices ,FreeIPA lab , Testing the code, Infra testing may more.  **This script can create about 99 KVM Guests** clones with  nameing from** AnsNode_1 to AnsNode_99 ** in organized manner. So that we don't have remember or check what is what. Sample Details for 1st KVM Clone which is 'AnsNode_1' how it allocate devices and address after cloning.


### [ AnsNode_1 KVM Clone details after cloning ]
```
-------------------------------------------------------------------
KMM name                                      : AnsNode_1
-------------------------------------------------------------------
KVM boot Disk Name[qcow2]                     : AnsNode_1.qcow2 
-------------------------------------------------------------------
KVM Addition 2GB Disk NAME[raw]               : AnsNode_1-2GB
-------------------------------------------------------------------
KVM 'my_lab_nat' MAC NIC address              : 52:54:00:10:10:01
-------------------------------------------------------------------
KVM 'my_lab_nat' network IP NIC address       : 192.168.10.1 
-------------------------------------------------------------------
KVM 'my_lab_internal' MAC NIC address         : 52:54:00:20:20:01
-------------------------------------------------------------------
KVM 'my_lab_internal' network IP NIC address  : 192.168.20.1 
-------------------------------------------------------------------
```

------------


## Feature :-

- Provides Immutable setup for Ansible or other lab practices. One can recreate same lab as many time as they want.

- It can create about 99 KVM Guest with Eastimated details like  **MAC Address** , **IP Address for NAT and Internal Networks** , **Addition LVM 2GB disk NAME** , **KVM NAME Itself** , **KVM Hostname**.

- We can configure default Storage pool if required at the time of cloning. We have to pass desired storage pool path for Exp: ** /data**  . ** [default /var/lib/libvirt/images]**

- We** can tune the KVM Guest cloning count ** as per requirement , Just pass the clone number at prompt.
- It will also create 2 unique virtual  bridge named** 'NATbr1' ** and ** 'Internalbr2'** to avoid any existing bridge name conflict. 

- It will create separate  networks and attach it to all clones **'my_lab_nat'**  and **'my_lab_internal'.**

-** IP and Name Resolution for KVM Guests**: Network definition file** 'my_lab_nat.xml'**   consist all 99 KVM Guest** MAC id** and **IP Address** details. As result all KVM cloned guest can resolve them self**  by name and IP address.** Its ideal scenario for many lab practices such like **FreeIPA** Server  practice lab.

- The script attaches** 2GB addition disk** to perform** LVM ** and other additional practices

- The script also has guest clean in wizard which can clean all 99 KVM Guest at once. And perform fresh clone at desired count.


## Prerequisites :- 
**Assumptions Clone_Guest=[KVM Guest name that you want clone ]**

- One KVM Host with CentOS/Red Hat version 7 or 8. It should work any other distributions as well.

- One KVM Guest  installed which you want clone for lab .In our case its "Clone_Guest" . Remove any attached  NIC before stating cloning** [use: virt-manager => View=>details ]**. Script will add 2 NIC’s and connect its networks while cloning. Remove any network file if exist for NIC at /etc/sysconfig/network-scripts/ifcfg-[removed NIC NAME]  to avoid any further network conflict after cloning.

- To be low on resources the  script sets  KVM Guest Max Mermory limit to 512 MB. Automomatically

- The Script  also limits max CPU allocation to 1 .

- Set hostname to ‘localhost’ of Clone_Guest  as 'my_lab_nat' network will auto set hostnames from ansnode_1 to ansnode_99. Ensure all ok by restarting network service on Clone_Guest. 

- Set Clone_Guest size as small as possible as we can create around 99  instances for the same. 15 Gb will be sufficient for practice/Testing.  

## Installation  
Use following command from terminal. In case git is not present in you machine then download the  code from  the  [Download Link](https://github.com/santosh2712/KVM_Setup_Ansible_Lab/archive/master.zip "Download Link") and extract code in local directory.
 
**Command to clone the repository .**
```
# git clone git@github.com:santosh2712/KVM_Setup_Ansible_Lab.git 
```

------------


## Usage
After copying the code to KVM Host Ensure 3 files exist in script folder 1st is **'KVM_Guest_Clone.sh'**  2nd is **'my_lab_nat.xml**' which is used for **nat **network and 3rd is** 'my_lab_internal' ** which is used for **internal ** network.
```
[root@centos8_master KVM_Setup_Ansible_Lab]# pwd 
/home/santosh/my_code/KVM_Setup_Ansible_Lab

[root@centos8_master KVM_Setup_Ansible_Lab]# ls -l 
-rwxrwxr-x. 1 santosh santosh 12546 Jul 10 13:54 KVM_Guest_Clone.sh
-rwxrwxr-x. 1 santosh santosh  6153 Jul 10 12:21 my_lab_internal.xml
-rwxrwxr-x. 1 santosh santosh  7781 Jul 10 12:33 my_lab_nat.xml
-rw-rw-r--. 1 santosh santosh 12668 Jul  9 17:07 README.MD
[root@centos8_master KVM_Setup_Ansible_Lab]#
```
Open Terminal and login as root. Switch to the directory where you copied the code. Ensure you have read the  guest name properly that you want to clone. To get the list of  available kvm guest names  issue following command as root user. or use privilege escalation.
```
[root@centos8_master KVM_Setup_Ansible_Lab]# virsh list --state-shutoff --all
 Id    Name                           State
----------------------------------------------------
 -     Clone_Guest                    shut off


```
In our case we will be using ** “Clone_Guest”** to clone and create Ansible practice lab from it. 

So lets begin cloning process  open the terminal and  navigate to the directory where you copied the code and  issue the  following command as root , or use some privilege escalation.

```
[[root@centos8_master KVM_Setup_Ansible_Lab]# sh KVM_Guest_Clone.sh 
......................................................................................................................................................
Found Host OS : Red Hat
Found Host OS is Red Hat with Version : 8
......................................................................................................................................................
Enter kvm guest name to clone or use found kvm Default[Clone_Guest]:Clone_Guest
......................................................................................................................................................
Enter kvm guest Installation path  Default[/var/lib/libvirt/images]:
KVM_Guest_Disk_DIR :/var/lib/libvirt/images
======================================================================================================================================================
Checking Virtual Networks my_lab_nat my_lab_internal
======================================================================================================================================================
------------------------------------------------------------------------------------------------------------------------------------------------------
INFO: Network my_lab_nat is Created. Starting network my_lab_nat
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
INFO: Network my_lab_internal is Created. Starting network my_lab_internal
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
INFO: Service libvirtd found running. 
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
Do you want to clear all existing guest with name Ansnode_* 
| Choose an option: Enter input between 1-3 only |
===================================================
1) Clear All AnsNode_* Guests      3) Quit
2) Clear only New AnsNode_ Guests
#? 1
------------------------------------------------------------------------------------------------------------------------------------------------------
INFO: Cleared all KVM guest with from AnsNode_01 to AnsNode_99
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
Script can clone Maximum 99 KVM guest with Fixed IP allocation
Enter Number of Clones you want for Lab Default [2]: 5
------------------------------------------------------------------------------------------------------------------------------------------------------
INFO: Script will Clone 5 KVM Guests. From Clone_Guest Guest
------------------------------------------------------------------------------------------------------------------------------------------------------
Attached_Disk: /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_1_raw_2G
======================================================================================================================================================
Cloning in Progress from Clone_Guest to AnsNode_1
......................................................................................................................................................
Allocating 'AnsNode_1.qcow2'                                                                                                   |  15 GB  00:00:06     

Clone 'AnsNode_1' created successfully.
Additional disk /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_1_raw_2G is Created and it will be Attached to AnsNode_1.
Disk attached successfully

......................................................................................................................................................
Attaching NIC eth1 TO my_lab_nat network ON AnsNode_1
Interface attached successfully

......................................................................................................................................................
Attaching NIC ens1 TO my_lab_internal network ON AnsNode_1
Interface attached successfully

......................................................................................................................................................
Setting Memory limit of 512 MB AnsNode_1

......................................................................................................................................................
Setting single CPU LIMIT for  AnsNode_1

......................................................................................................................................................
Cloning done for AnsNode_1 ! Starting AnsNode_1
Domain AnsNode_1 started

======================================================================================================================================================
Attached_Disk: /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_2_raw_2G
======================================================================================================================================================
Cloning in Progress from Clone_Guest to AnsNode_2
......................................................................................................................................................
Allocating 'AnsNode_2.qcow2'                                                                                                   |  15 GB  00:00:14     

Clone 'AnsNode_2' created successfully.
Additional disk /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_2_raw_2G is Created and it will be Attached to AnsNode_2.
Disk attached successfully

......................................................................................................................................................
Attaching NIC eth2 TO my_lab_nat network ON AnsNode_2
Interface attached successfully

......................................................................................................................................................
Attaching NIC ens2 TO my_lab_internal network ON AnsNode_2
Interface attached successfully

......................................................................................................................................................
Setting Memory limit of 512 MB AnsNode_2

......................................................................................................................................................
Setting single CPU LIMIT for  AnsNode_2

......................................................................................................................................................
Cloning done for AnsNode_2 ! Starting AnsNode_2
Domain AnsNode_2 started

======================================================================================================================================================
Attached_Disk: /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_3_raw_2G
======================================================================================================================================================
Cloning in Progress from Clone_Guest to AnsNode_3
......................................................................................................................................................
Allocating 'AnsNode_3.qcow2'                                                                                                   |  15 GB  00:00:22     

Clone 'AnsNode_3' created successfully.
Additional disk /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_3_raw_2G is Created and it will be Attached to AnsNode_3.
Disk attached successfully

......................................................................................................................................................
Attaching NIC eth3 TO my_lab_nat network ON AnsNode_3
Interface attached successfully

......................................................................................................................................................
Attaching NIC ens3 TO my_lab_internal network ON AnsNode_3
Interface attached successfully

......................................................................................................................................................
Setting Memory limit of 512 MB AnsNode_3

......................................................................................................................................................
Setting single CPU LIMIT for  AnsNode_3

......................................................................................................................................................
Cloning done for AnsNode_3 ! Starting AnsNode_3
Domain AnsNode_3 started

======================================================================================================================================================
Attached_Disk: /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_4_raw_2G
======================================================================================================================================================
Cloning in Progress from Clone_Guest to AnsNode_4
......................................................................................................................................................
Allocating 'AnsNode_4.qcow2'                                                                                                   |  15 GB  00:00:21     

Clone 'AnsNode_4' created successfully.
Additional disk /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_4_raw_2G is Created and it will be Attached to AnsNode_4.
Disk attached successfully

......................................................................................................................................................
Attaching NIC eth4 TO my_lab_nat network ON AnsNode_4
Interface attached successfully

......................................................................................................................................................
Attaching NIC ens4 TO my_lab_internal network ON AnsNode_4
Interface attached successfully

......................................................................................................................................................
Setting Memory limit of 512 MB AnsNode_4

......................................................................................................................................................
Setting single CPU LIMIT for  AnsNode_4

......................................................................................................................................................
Cloning done for AnsNode_4 ! Starting AnsNode_4
Domain AnsNode_4 started

======================================================================================================================================================
Attached_Disk: /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_5_raw_2G
======================================================================================================================================================
Cloning in Progress from Clone_Guest to AnsNode_5
......................................................................................................................................................
Allocating 'AnsNode_5.qcow2'                                                                                                   |  15 GB  00:00:23     

Clone 'AnsNode_5' created successfully.
Additional disk /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_5_raw_2G is Created and it will be Attached to AnsNode_5.
Disk attached successfully

......................................................................................................................................................
Attaching NIC eth5 TO my_lab_nat network ON AnsNode_5
Interface attached successfully

......................................................................................................................................................
Attaching NIC ens5 TO my_lab_internal network ON AnsNode_5
Interface attached successfully

......................................................................................................................................................
Setting Memory limit of 512 MB AnsNode_5

......................................................................................................................................................
Setting single CPU LIMIT for  AnsNode_5

......................................................................................................................................................
Cloning done for AnsNode_5 ! Starting AnsNode_5
Domain AnsNode_5 started

======================================================================================================================================================
......................................................................................................................................................
In some cases kvm guest auto hostname setting not work. Check attached my_lab_nat.xml 
......................................................................................................................................................
[root@centos8_master KVM_Setup_Ansible_Lab]# 
```
# Congratulations you have cloned 5 KVM guests for lab practice. :joy:


------------


###1. Verify running KVM Guest on Host :-

**Use following command **
```
[root@centos8_master KVM_Setup_Ansible_Lab]# virsh list --all
 Id    Name                           State
----------------------------------------------------
 11    AnsNode_1                      running
 12    AnsNode_2                      running
 13    AnsNode_3                      running
 14    AnsNode_4                      running
 15    AnsNode_5                      running
 -      Clone_Guest                    shut off 
```
###2. Verify KVM Guest Information
**Use following command **
```
[root@centos8_master KVM_Setup_Ansible_Lab]#  virsh dominfo --domain AnsNode_1
Id:             11
Name:           AnsNode_1
UUID:           53d88eaa-cdbb-4358-9625-f86e224169c1
OS Type:        hvm
State:          running
CPU(s):         1
CPU time:       31.8s
Max memory:     524288 KiB
Used memory:    524288 KiB
Persistent:     yes
Autostart:      disable
Managed save:   no
Security model: selinux
Security DOI:   0
Security label: system_u:system_r:svirt_t:s0:c294,c405 (enforcing)
```
###3. Verify Attached Block Devices to KVM Guest AnsNode_1
**Use following command on KVM Host **
```
[root@centos8_master KVM_Setup_Ansible_Lab]# virsh domblklist --domain AnsNode_1
Target     Source
------------------------------------------------
vda        /var/lib/libvirt/images/AnsNode_1.qcow2
vdb        /var/lib/libvirt/images/Guest_Attached_Disk/AnsNode_1_raw_2G

```
###4. Verify virtual networks for lab 
**Use 'ip a' command on KVM Host **
```
[santosh@centos8_master ~]$ ip a

4: NATbr1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:10:10:00 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.100/24 brd 192.168.10.255 scope global NATbr1
       valid_lft forever preferred_lft forever
5: NATbr1-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master NATbr1 state DOWN group default qlen 1000
    link/ether 52:54:00:10:10:00 brd ff:ff:ff:ff:ff:ff
6: Internalbr2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:20:20:00 brd ff:ff:ff:ff:ff:ff
    inet 192.168.20.100/24 brd 192.168.20.255 scope global Internalbr2
       valid_lft forever preferred_lft forever
7: Internalbr2-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master Internalbr2 state DOWN group default qlen 1000
    link/ether 52:54:00:20:20:00 brd ff:ff:ff:ff:ff:ff

```


------------


## Verify Deployment on KVM Guest :-

### 1. Verify IP and hostname 
```
[root@centos8_master KVM_Setup_Ansible_Lab]# ssh 192.168.10.1
root@192.168.10.1's password: 
Last login: Fri Jul 10 16:05:35 2020 from gateway
[root@ansnode_1 ~]# hostname
ansnode_1
```
### 2. Verify IP and MAC Address on KVM Guest

Using** "ip a" **to show network Configuration  of **AnsNode_1** 1st clone 

```
[root@ansnode_1 ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether  52:54:00:10:10:01 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.1/24 brd 192.168.10.255 scope global noprefixroute dynamic ens1
       valid_lft 2723sec preferred_lft 2723sec
    inet6 fe80::1251:9ef9:253a:b32d/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: ens2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:20:20:01 brd ff:ff:ff:ff:ff:ff
    inet 192.168.20.1/24 brd 192.168.20.255 scope global noprefixroute dynamic ens2
       valid_lft 2723sec preferred_lft 2723sec
    inet6 fe80::435a:6059:a453:8234/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
[root@ansnode_1 ~]# 
```
###3. Hostname  Resolution from KVM Guest 

For NAT from 'my_lab_nat' network to INTERNET
```
[root@ansnode_1 ~]# ping google.com
PING google.com (172.217.174.238) 56(84) bytes of data.
64 bytes from bom12s03-in-f14.1e100.net (172.217.174.238): icmp_seq=1 ttl=112 time=85.4 ms
64 bytes from bom12s03-in-f14.1e100.net (172.217.174.238): icmp_seq=2 ttl=112 time=207 ms
64 bytes from bom12s03-in-f14.1e100.net (172.217.174.238): icmp_seq=3 ttl=112 time=677 ms
64 bytes from bom12s03-in-f14.1e100.net (172.217.174.238): icmp_seq=4 ttl=112 time=634 ms
64 bytes from bom12s03-in-f14.1e100.net (172.217.174.238): icmp_seq=5 ttl=112 time=163 ms
^C
--- google.com ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4002ms
rtt min/avg/max/mdev = 85.418/353.628/677.383/250.339 ms
[root@ansnode_1 ~]#
``` 
https://github.com/santosh2712/KVM_Setup_Ansible_Lab/archive/master.zip
### 5. Forward lookup from ansnode_1 for ansnode_5  on  KVM Guest
```
[root@ansnode_1 ~]# dig ansnode_5

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-16.P2.el7_8.6 <<>> ansnode_5
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 58444
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;ansnode_5.     IN  A

;; ANSWER SECTION:
ansnode_5.    0 IN  A 192.168.10.5

;; Query time: 0 msec
;; SERVER: 192.168.10.100#53(192.168.10.100)
;; WHEN: Fri Jul 10 16:22:02 IST 2020
;; MSG SIZE  rcvd: 54

[root@ansnode_1 ~]#
```
## 6. Reverse lookup from ansnode_1 of  192.168.10.5 [ansnode_5 IP ]
```
[root@ansnode_1 ~]# dig -x 192.168.10.5

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-16.P2.el7_8.6 <<>> -x 192.168.10.5
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 32710
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;5.10.168.192.in-addr.arpa. IN  PTR

;; ANSWER SECTION:
5.10.168.192.in-addr.arpa. 0  IN  PTR ansnode_5.

;; Query time: 0 msec
;; SERVER: 192.168.10.100#53(192.168.10.100)
;; WHEN: Fri Jul 10 16:22:59 IST 2020
;; MSG SIZE  rcvd: 77

[root@ansnode_1 ~]# 

``` 


------------


# Network configuration will be as follows for lab

from 1 to 99 both network IP address and MAC address will iterate for all KVM Guest named AnsNode_*.

- 'my_lab_nat' network gateway /KVM host IP will be 192.168.10.100

- 'my_lab_internal' network gateway/KVM host IP will be 192.168.20.100 

Cloned Guest Name  | NAT Network MAC Address  |  NAT Network IP Address 'my_lab_nat' | Internal Network MAC Address| Internal Network IP Address 'my_lab_internal'
-----------|-----------------|--------------|-----------------|----------------
AnsNode_1  |52:54:00:10:10:01|192.168.10.1  |52:54:00:20:20:01|192.168.20.1
AnsNode_5  |52:54:00:10:10:05|192.168.10.5  |52:54:00:20:20:05|192.168.20.5
AnsNode_25 |52:54:00:10:10:25|192.168.10.25 |52:54:00:20:20:25|192.168.20.25
AnsNode_50 |52:54:00:10:10:50|192.168.10.50 |52:54:00:20:20:50|192.168.20.50
AnsNode_99 |52:54:00:10:10:99|192.168.10.99 |52:54:00:20:20:99|192.168.20.99


------------




# We are looking for contribution. We well be happy to merge pull request if it improves code or add some functionality. 

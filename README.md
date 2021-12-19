1.	Узнайте о sparse (разряженных) файлах.
vagrant@vagrant:/$ sudo truncate -s200G ./spfile
vagrant@vagrant:/$ ls spfile -lh
-rw-r--r-- 1 root root 200G Dec 19 15:44 spfile
vagrant@vagrant:/$ stat spfile
  File: spfile
  Size: 214748364800    Blocks: 0          IO Block: 4096   regular file
Device: fd00h/64768d    Inode: 18          Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2021-12-19 15:44:25.058986607 +0000
Modify: 2021-12-19 15:44:09.102986823 +0000
Change: 2021-12-19 15:44:09.102986823 +0000
 Birth: -

2.	Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?
Не могут, т.к. оба хардлинка указывают на одну айноду 

vagrant@vagrant:~$ echo "test text" > tt.txt
vagrant@vagrant:~$ cat tt.txt
test text
vagrant@vagrant:~$ ln tt.txt hardlink
vagrant@vagrant:~$ ls -l tt.txt
-rw-rw-r-- 2 vagrant vagrant 10 Dec 19 16:00 tt.txt
vagrant@vagrant:~$ ls -l hardlink
-rw-rw-r-- 2 vagrant vagrant 10 Dec 19 16:00 hardlink
vagrant@vagrant:~$ chmod ugo+rwx tt.txt
vagrant@vagrant:~$ ls -l tt.txt
-rwxrwxrwx 2 vagrant vagrant 10 Dec 19 16:00 tt.txt
vagrant@vagrant:~$ ls -l hardlink
-rwxrwxrwx 2 vagrant vagrant 10 Dec 19 16:00 hardlink

vagrant@vagrant:~$ stat tt.txt
  File: tt.txt
  Size: 10              Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d    Inode: 131131      Links: 2
Access: (0777/-rwxrwxrwx)  Uid: ( 1000/ vagrant)   Gid: ( 1000/ vagrant)
Access: 2021-12-19 16:00:59.670973116 +0000
Modify: 2021-12-19 16:00:55.082973178 +0000
Change: 2021-12-19 16:06:01.486969022 +0000
 Birth: -
vagrant@vagrant:~$ stat hardlink
  File: hardlink
  Size: 10              Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d    Inode: 131131      Links: 2
Access: (0777/-rwxrwxrwx)  Uid: ( 1000/ vagrant)   Gid: ( 1000/ vagrant)
Access: 2021-12-19 16:00:59.670973116 +0000
Modify: 2021-12-19 16:00:55.082973178 +0000
Change: 2021-12-19 16:06:01.486969022 +0000
 Birth: -

3.	Сделайте vagrant destroy на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.provider :virtualbox do |vb|
    lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
    lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
    vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
    vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
  end
end
Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

vagrant@vagrant:~$ sudo fdisk -l
Disk /dev/sda: 64 GiB, 68719476736 bytes, 134217728 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x3f94c461

Device     Boot   Start       End   Sectors  Size Id Type
/dev/sda1  *       2048   1050623   1048576  512M  b W95 FAT32
/dev/sda2       1052670 134215679 133163010 63.5G  5 Extended
/dev/sda5       1052672 134215679 133163008 63.5G 8e Linux LVM


Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/vgvagrant-root: 62.55 GiB, 67150807040 bytes, 131153920 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/vgvagrant-swap_1: 980 MiB, 1027604480 bytes, 2007040 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


4.	Используя fdisk, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

vagrant@vagrant:~$ sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x570cfd15.

Command (m for help): p
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x570cfd15


Command (m for help): i
No partition is defined yet!

Command (m for help): n
Partition number (1-128, default 1): 1
First sector (2048-5242846, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242846, default 5242846): +2G

Created a new partition 1 of type 'Linux filesystem' and of size 2 GiB.


Command (m for help): n
Partition number (2-128, default 2):
First sector (4196352-5242846, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242846, default 5242846):

Created a new partition 2 of type 'Linux filesystem' and of size 511 MiB.

Command (m for help): p
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 4B1BF43E-9304-164F-ABF4-60781BD30F84

Device       Start     End Sectors  Size Type
/dev/sdb1     2048 4196351 4194304    2G Linux filesystem
/dev/sdb2  4196352 5242846 1046495  511M Linux filesystem

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

vagrant@vagrant:~$ sudo fdisk -l /dev/sdb
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 4B1BF43E-9304-164F-ABF4-60781BD30F84

Device       Start     End Sectors  Size Type
/dev/sdb1     2048 4196351 4194304    2G Linux filesystem
/dev/sdb2  4196352 5242846 1046495  511M Linux filesystem

5.	Используя sfdisk, перенесите данную таблицу разделов на второй диск.

root@vagrant:/home/vagrant# sfdisk -d /dev/sdb > part_table
root@vagrant:/home/vagrant# sfdisk /dev/sdc < part_table
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new GPT disklabel (GUID: 4B1BF43E-9304-164F-ABF4-60781BD30F84).
/dev/sdc1: Created a new partition 1 of type 'Linux filesystem' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux filesystem' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: gpt
Disk identifier: 4B1BF43E-9304-164F-ABF4-60781BD30F84

Device       Start     End Sectors  Size Type
/dev/sdc1     2048 4196351 4194304    2G Linux filesystem
/dev/sdc2  4196352 5242846 1046495  511M Linux filesystem

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.


6.	Соберите mdadm RAID1 на паре разделов 2 Гб.

root@vagrant:/home/vagrant# mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{b,c}1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 2094080K
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.

7.	Соберите mdadm RAID0 на второй паре маленьких разделов.

root@vagrant:/home/vagrant# mdadm --create --verbose /dev/md1 -l 0 -n 2 /dev/sd{b,c}2
mdadm: chunk size defaults to 512K
mdadm: /dev/sdb2 appears to be part of a raid array:
       level=raid1 devices=2 ctime=Sun Dec 19 17:24:26 2021
mdadm: /dev/sdc2 appears to be part of a raid array:
       level=raid1 devices=2 ctime=Sun Dec 19 17:24:26 2021
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
root@vagrant:/home/vagrant# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md1 : active raid0 sdc2[1] sdb2[0]
      1041408 blocks super 1.2 512k chunks

md0 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]

8.	Создайте 2 независимых PV на получившихся md-устройствах.

root@vagrant:/# pvcreate dev/md1 dev/md0
  Physical volume "dev/md1" successfully created.
  Physical volume "dev/md0" successfully created.
root@vagrant:/# pvscan
  PV /dev/sda5   VG vgvagrant       lvm2 [<63.50 GiB / 0    free]
  PV /dev/md0                       lvm2 [<2.00 GiB]
  PV /dev/md1                       lvm2 [1017.00 MiB]
  Total: 3 [<66.49 GiB] / in use: 1 [<63.50 GiB] / in no VG: 2 [2.99 GiB]

9.	Создайте общую volume-group на этих двух PV.

root@vagrant:/# vgcreate vol_grp1 /dev/md0 /dev/md1
  Volume group "vol_grp1" successfully created
root@vagrant:/# vgdisplay
  --- Volume group ---
  VG Name               vgvagrant
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <63.50 GiB
  PE Size               4.00 MiB
  Total PE              16255
  Alloc PE / Size       16255 / <63.50 GiB
  Free  PE / Size       0 / 0
  VG UUID               PaBfZ0-3I0c-iIdl-uXKt-JL4K-f4tT-kzfcyE

  --- Volume group ---
  VG Name               vol_grp1
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <2.99 GiB
  PE Size               4.00 MiB
  Total PE              765
  Alloc PE / Size       0 / 0
  Free  PE / Size       765 / <2.99 GiB
  VG UUID               AgoOM7-BhPF-wBfa-2DLy-bbkQ-jez9-bRDtCm

10.	Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

root@vagrant:/# lvcreate -L 100M vol_grp1 /dev/md1
Logical volume "lvol0" created.

11.	Создайте mkfs.ext4 ФС на получившемся LV.

root@vagrant:/# mkfs.ext4 /dev/vol_grp1/lvol0
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes
Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done

12.	Смонтируйте этот раздел в любую директорию, например, /tmp/new.

root@vagrant:/# cd /tmp/
root@vagrant:/tmp# mkdir new
root@vagrant:/tmp/new# mount /dev/vol_grp1/lvol0 /tmp/new

13.	Поместите туда тестовый файл, например wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz.

root@vagrant:/tmp/new# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz.
--2021-12-19 18:05:21--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 22743189 (22M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz.’

/tmp/new/test.gz.                                100%[==========================================================================================================>]  21.69M  3.24MB/s    in 8.5s

2021-12-19 18:05:29 (2.56 MB/s) - ‘/tmp/new/test.gz.’ saved [22743189/22743189]

root@vagrant:/tmp/new# ls
lost+found  test.gz.

14.	Прикрепите вывод lsblk.

root@vagrant:/tmp/new# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdb2                 8:18   0  511M  0 part
  └─md1                9:1    0 1017M  0 raid0
    └─vol_grp1-lvol0 253:2    0  100M  0 lvm   /tmp/new
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdc2                 8:34   0  511M  0 part
  └─md1                9:1    0 1017M  0 raid0
 └─vol_grp1-lvol0 253:2    0  100M  0 lvm   /tmp/new

15.	Протестируйте целостность файла:
root@vagrant:~# gzip -t /tmp/new/test.gz
root@vagrant:~# echo $?
0

root@vagrant:~# gzip -tv /tmp/new/test.gz.
/tmp/new/test.gz.:       OK

16.	Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

root@vagrant:~# pvmove /dev/md1 /dev/md0
  /dev/md1: Moved: 20.00%
  /dev/md1: Moved: 100.00%
root@vagrant:~# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
│   └─vol_grp1-lvol0 253:2    0  100M  0 lvm   /tmp/new
└─sdb2                 8:18   0  511M  0 part
  └─md1                9:1    0 1017M  0 raid0
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
│   └─vol_grp1-lvol0 253:2    0  100M  0 lvm   /tmp/new
└─sdc2                 8:34   0  511M  0 part
 └─md1                9:1    0 1017M  0 raid0

17.	Сделайте --fail на устройство в вашем RAID1 md.

root@vagrant:~# mdadm /dev/md0 -f /dev/sdc1
mdadm: set /dev/sdc1 faulty in /dev/md0
root@vagrant:~# mdadm --detail /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sun Dec 19 17:23:53 2021
        Raid Level : raid1
        Array Size : 2094080 (2045.00 MiB 2144.34 MB)
     Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Sun Dec 19 18:28:13 2021
             State : clean, degraded
    Active Devices : 1
   Working Devices : 1
    Failed Devices : 1
     Spare Devices : 0

Consistency Policy : resync

              Name : vagrant:0  (local to host vagrant)
              UUID : f6fe65cb:ce42cded:280b184f:85a99e45
            Events : 19

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       -       0        0        1      removed

       1       8       33        -      faulty   /dev/sdc1 

18.	Подтвердите выводом dmesg, что RAID1 работает в деградированном состоянии.

root@vagrant:~# dmesg | grep raid
[    2.972481] raid6: avx2x4   gen() 21947 MB/s
[    3.020445] raid6: avx2x4   xor() 14122 MB/s
[    3.068419] raid6: avx2x2   gen() 17428 MB/s
[    3.116450] raid6: avx2x2   xor() 12227 MB/s
[    3.164466] raid6: avx2x1   gen() 15799 MB/s
[    3.212490] raid6: avx2x1   xor() 11094 MB/s
[    3.260457] raid6: sse2x4   gen()  9132 MB/s
[    3.308425] raid6: sse2x4   xor()  5623 MB/s
[    3.356434] raid6: sse2x2   gen()  7706 MB/s
[    3.404484] raid6: sse2x2   xor()  5298 MB/s
[    3.452486] raid6: sse2x1   gen()  7064 MB/s
[    3.500459] raid6: sse2x1   xor()  4120 MB/s
[    3.500461] raid6: using algorithm avx2x4 gen() 21947 MB/s
[    3.500462] raid6: .... xor() 14122 MB/s, rmw enabled
[    3.500463] raid6: using avx2x2 recovery algorithm
[ 3406.945257] md/raid1:md0: not clean -- starting background reconstruction
[ 3406.945334] md/raid1:md0: active with 2 out of 2 mirrors
[ 3440.295725] md/raid1:md1: not clean -- starting background reconstruction
[ 3440.295728] md/raid1:md1: active with 2 out of 2 mirrors
[ 7267.081661] md/raid1:md0: Disk failure on sdc1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.

19.	Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:
root@vagrant:~# gzip -t /tmp/new/test.gz
root@vagrant:~# echo $?
0

root@vagrant:~# gzip -tv /tmp/new/test.gz.
/tmp/new/test.gz.:       OK


20.	Погасите тестовый хост, vagrant destroy.

vagrant@vagrant:~$ exit
logout
Connection to 127.0.0.1 closed.
❯ vagrant destroy
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default: Forcing shutdown of VM...
==> default: Destroying VM and associated drives...


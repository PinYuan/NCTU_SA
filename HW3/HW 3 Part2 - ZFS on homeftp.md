# HW 3 Part2 - ZFS on /home/ftp 

https://www.thegeekdiary.com/zfs-tutorials-creating-zfs-pools-and-file-systems/

##Enable ZFS service

```shell
echo 'pureftpd_enable="YES"' >> /etc/rc.conf
```



## Creating a ZFS pool

1. using whole disks

2. using disk slices

3. using files

   Make sure you give an **absolute path** while creating a zpool

   ```shell
   mkfile 128m /mirror_f1
   mkfile 128m /mirror_f2
   zpool create mypool mirror /mirror_f1 /mirror_f2
   ```



## Create ZFS datasets

```SHELL
# zfs create -o mountpoint=/home/ftp/public mypool/public
zfs create mypool/public
zfs set mountpoint=/home/ftp/public mypool/public
zfs set compression=gzip mypool/public

zfs create mypool/upload
zfs set mountpoint=/home/ftp/upload mypool/upload
zfs set compression=gzip mypool/upload

zfs create mypool/hidden
zfs set mountpoint=/home/ftp/hidden mypool/hidden
zfs set compression=gzip mypool/hidden

# zfs list
```

###mount / unmount filesystem

```shell
zfs umount example/compressed
zfs mount example/compressed
```



## zbackup

Automatic Snapshot Script

https://www.freebsd.org/doc/zh_TW/books/handbook/zfs-zfs.html

### Preprocess

Install bash

```shell
pkg install bash # usr/local/bin/bash
```


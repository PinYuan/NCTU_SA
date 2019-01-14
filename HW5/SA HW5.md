# SA HW5

## Create Account

### Add group

```shell
pw groupadd acctadm 
pw groupadd storadm
pw groupadd users
```

### Add users

```shell
# -G: Add existing FreeBSD user to a group and replace existing membership
pw useradd god -G acctadm,storadm,users
pw useradd 0745041-A -G acctadm,users  
pw useradd A063021-B -G storadm,users 
pw useradd user -G users
# pw will prompt for the user's password if -h	0 is given, nominating stdin as the file descriptor on which to read the password.
echo password | pw usermod god -h 0
echo password | pw usermod 0745041-A -h 0
echo password | pw usermod A063021-B -h 0
echo password | pw usermod user -h 0
```



## NIS Server (Mater)

https://vannilabetter.blogspot.com/2017/12/freebsd-nis.html?fbclid=IwAR0aGzd1EXorQt50Ja1mRExvhFZDgb56LsT6rs-2YVKdD3AqO1XYbD1pF0I

https://blog.zespre.com/2014/12/25/freebsd-nis-nfs.html?fbclid=IwAR0EqwcmOBQDZCaA6l1wdIHisHY8FkvPMwW61MyXH_lK4RkmtbhAO8yuzPY

### 1. /etc/rc.conf

```shell
 nisdomainname="sa.nis"     # 設定 NIS Domain 名稱為 sa.nis
 nis_server_enable="YES"      # 啟動NIS Server
 nis_client_enable="YES"      # 否則本機使用者將無法登入
 nis_yppasswdd_enable="YES"   # 負責 NIS 密碼部份
 nis_yppasswdd_flags="-t /var/yp/src/master.passwd"   # 指定 NIS 密碼檔路徑
 rpcbind_enable="YES"         # 4.x 為啟動 portmap
```

### 2. Accounts

```shell
cd /var/yp;cp Makefile.dist Makefile  # 確定 NOPUSH = "True" 沒註解掉
cp /etc/master.passwd /var/yp/src         # 複製本機使用者密碼檔案至 NIS 資料夾下
cp /etc/group /var/yp/src    
```

/var/yp/src/master.passwd delete system-user account

vipw delete normal user account and add `+:::::::::` at the end

/var/yp/src/group delete system-group

vigr delete normal group and add `+:*::` at the end

### 3. /etc/hosts 

```
192.168.112.130 account.cs.nctu.edu.tw
192.168.112.131 storage.cs.nctu.edu.tw
192.168.112.132 playground.cs.nctu.edu.tw
```

### 4. 初始化 NIS / YP 及相關檔案

```
ypinit -m sa.nis
cd /var/yp
make MASTER_PASSWD=/var/yp/src/master.passwd
```

### 

## NFS

https://vannilabetter.blogspot.com/2017/12/freebsd-nfsv4.html

need to build zfs dataset for each /net/xxx for building a single filesystem

`sudo zfs create -o mountpoint=/net/xxx zroot/xxx`



`/etc/exports`

```
V4: /   -sec=sys -network 192.168.112.0 -mask 255.255.255.0
/net/xxx <options> hostname...
```



### Autofs

http://www.zhouweiping.cn/index.php/archives/65/

manual mount `mount -t nfs -o nfsv4 192.168.xxx.xxx:/net/shares /mnt`



## Sudoers

https://blog.zespre.com/2014/12/25/freebsd-nis-nfs.html?fbclid=IwAR0EqwcmOBQDZCaA6l1wdIHisHY8FkvPMwW61MyXH_lK4RkmtbhAO8yuzPY



## netgroups

https://www.freebsd.org/doc/zh_TW/books/handbook/network-nis.html



## /etc/hosts.allow

https://www.freebsd.org/doc/handbook/tcpwrappers.html

為了實驗方便，暫時先加入192.168.112.1(實體機ip)

add some service enable in `/etc/rc.conf` and then put the following in the `/etc/hosts.allow`

```
# put the rule before ALL : ALL : allow !!!
sshd : playground.cs.nctu.edu.tw : allow # 僅允許 playground.cs.nctu.edu.tw 連線
sshd : ALL : deny

ALL : ALL : allow
```

```
# tail /var/log/auth.log
refused connect from 192.168.112.1 (192.168.112.1)
```



## checklist

- [ ] Service auto start (5%)

-  SSH limitation (10%)

  - [ ] Only can login behind from playground (5%)

  - [ ] Only admins can login behind (5%)

-  Sudo (15%)

  - [ ] acctadm can sudo in account (5%)

  - [ ] storadm can sudo in storage (5%)

  - [ ] Sharing and including /net/datas/sudoers (5%)

-  NIS (30%)

  - [ ] Bind priority (5%)

  - [ ] Slave configured (5%)

  - [ ] passwd on client (10%)

  - [ ] File sharing (10%)

- NFS (40%)
  - [ ] Export using NFSv4 (5%)
  - [ ] Mount storage:/net/home as nobody (5%)
  - [ ] Mount storage:/net/shares and squash all as user:users (5%)
  - [ ] Mount storage:/net/datas with rw on behind (5%)
  - [ ] Mount storage:/net/datas with ro on playground (5%)
  - [ ] Auto mount all folders (10%)
  - [ ] Mapping uid and username (5%)
- Bonus (20%)
  - [ ] Sharing autofs.map via yp with automountd (10%)
  - [ ] Account creating script (10%)
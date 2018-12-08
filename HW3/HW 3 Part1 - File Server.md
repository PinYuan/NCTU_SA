#HW 3 Part1 - File Server

IP addr of VM: 192.168.112.128(NAT), 192.168.241.128(Host-only)

## Install FTP server

###Installation

```shell
cd /usr/ports/ftp/pureftpd/
make # compile
make install
```

<img src="C:\Users\USER\Desktop\hw3/1.PNG" width="500">

### Configuration

```shell
cd /usr/local/etc
cp pure-ftpd.conf.sample pure-ftpd.conf
chmod u+w pure-ftpd.conf

echo 'pureftpd_enable="YES"' >> /etc/rc.conf
```

###Directory

```shell
mkdir /home/ftp /home/ftp/public /home/ftp/hidden /home/ftp/upload /home/ftp/hidden/treasure
```



## Anonymous login

https://baike.baidu.com/item/%E5%8C%BF%E5%90%8DFTP

### Configuration

/usr/local/etc/pure-ftpd.conf 

```shell
NoAnonymous     no
AnonymousCanCreateDirs     yes
AnonymousCantUpload     no
```

###Add a ftp account for Anonymous

```shell
pw groupadd ftpuser
pw useradd ftp -g ftpuser -d /home/ftp -c "Anonymous FTP user"
```



## Add a system user

```shell
# pw groupadd <groupname> -g <gid>
# pw groupadd ftpuser 
# pw useradd <username> -u <uid> -g <gid> -c <comment for GECOS field> -d <account's home directory> -s <shell>
pw useradd sysadm -g ftpgroup -d /home/ftp -s /bin/tcsh
```

### Import system account into virtual user database

```
pure-pwconvert >> /usr/local/etc/pureftpd.passwd
```

Note: pure-pwconvert **only imports accounts that have shell access**. Accounts with the shell set to nologin have to be added manually.



##Create a virtualuser "ftp-vip"

https://download.pureftpd.org/pub/pure-ftpd/doc/README.Virtual-Users

### Configuration

/usr/local/etc/pure-ftpd.conf

```shell
PureDB /usr/local/etc/pureftpd.pdb # original /etc/pureftpd.pdb
```

### Add user

```shell
pw groupadd ftpgroup
pw useradd ftpuser -g ftpgroup -c "FTP visual user" -d /dev/null -s /sbin/nologin

pure-pw useradd ftp-vip -u ftpuser -d /home/ftp -m # it will ask you to set pwd
```

### pure-pw

```shell
pure-pw usermod # modify account
pure-pw userdel # delete account
pure-pw passwd # set password
pure-pw show # show info of account
pure-pw list # list all accounts
```

### commit changes

Committing changes really means that a new file is created from /etc/pureftpd.passwd (or whatever file name you choose) . That new file is a **PureDB file**.

```shell
pure-pw mkdb # create a PureDB file from /etc/pureftpd.passwd
			 # reads /etc/pureftpd.passwd and creates /etc/pureftpd.pdb by default
# or
pure-pw mkdb /etc/accounts/myaccounts.pdb -f /etc/accounts/myaccounts.txt

pure-pw passwd joe -m # change Joe's password in pureftpd.passwd and commit the change to /etc/pureftpd.pwd
```



##Directory permission

### Public

```shell
chown root:ftpgroup /home/ftp/public
chmod 775 /home/ftp/public # anonymous can't write -> upload/delete
```

### Upload

modify new created file's permission setting in /usr/local/etc/pure-ftpd.conf

- remove file's **w** tag for preventing modified and dir's **r** tag

```shell
Umask                       007:004
```

For now, I remove folder's **r** tag for preventing download

```shell
chown root:ftpgroup /home/ftp/upload
chmod 773 /home/ftp/upload
```

### Hidden

can't ls means remove folder's **r** tag

```shell
chown root:ftpgroup /home/ftp/hidden
chmod 771 /home/ftp/hidden
chmod 773 /home/ftp/treasure
```



## TLS

https://download.pureftpd.org/pub/pure-ftpd/doc/README.TLS

###configuration 

/usr/local/etc/pure-ftpd.conf

TLS (0,1,2)

- 0: support for TLS is disabled

- 1: clients can connect either the traditional way or through an TLS layer
- 2: cleartext sessions are refused and only TLS compatible clients are accepted

### Certificate

```shell
mkdir -p /etc/ssl/private

# generate length=1024 D-H key exchange
openssl dhparam -out /etc/ssl/private/pure-ftpd-dhparams.pem 2048

openssl req -x509 -nodes -newkey rsa:2048 -sha256 -keyout \
  /etc/ssl/private/pure-ftpd.pem \
  -out /etc/ssl/private/pure-ftpd.pem

chmod 600 /etc/ssl/private/*.pem
```



## Problem

1. pure-ftpd unable to find the 'ftp' account

   https://www.syslogs.org/freebsd-pure-ftpd-error-unable-to-find-the-ftp-account/

   The reason for this situation is that a group named ftpgroup is created during the installation and the account named ftp is not created. Since an account with ftp is not found in the system, [pure-ftpd](https://www.syslogs.org/tag/pure-ftpd/) does not require this user theoretically, but it causes problems when starting the service.

   As a result, you must add this user to your system

2. Can't log in by a new added user

   Try restart the deamon

   ```shell
   /usr/local/etc/rc.d/pure-ftpd restart
   ```



# HW 3 Part3 - RC: Upload script for Pure-FTPd

## user specify rc.conf command

/etc/rc.conf

```shell
ftp_watchd_enable="YES"
ftp_watchd_command="zbackup mypool/upload 10" # "echo upload: "'$1 `date`'" >> /var/log/uploadscript.log"
```

### How to import into RC script

`load_rc_config $name` **loads the /etc/rc.conf file.** Additionally, it looks for the ‘myscript’ specific configuration file in /etc/rc.conf.d/ if you need more advance control over the script.



 ## upload script

###Enable upload script

/usr/local/etc/pure-ftpd.conf

```shell
CallUploadScript          yes
```

###Create a simple upload script 

/uploadscript.sh

-  chmod a+x /uploadscript.sh (must need!)

```shell
#!/bin/sh

# a command specified in rc.conf, and through rc script parse the command
echo "upload: $1" >> /var/log/uploadscript.log
```



##RC script - ftp_watchd

https://www.freebsd.org/doc/en_US.ISO8859-1/articles/rc-scripting/rcng-hookup.html

- In `/etc/rc.subr`, there are default {name}_cmd setting, and we can overwrite command in rc script.

- Remember add conditions (ex: # PROVIDE)



## Problem

1. I have enable my service in rc.conf. But why can service xxx start work but can't work at boot time?
   - maybe lose `condition` in rc script
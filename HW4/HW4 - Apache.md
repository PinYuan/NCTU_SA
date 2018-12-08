# HW4 - Apache

## Install Apache

```shell
cd /usr/ports/www/apache24

make config # WITH_SUEXEC=yes
make install clean
# or make WITH_MPM=worker WITH_THREADS=yes install
```

``/etc/rc.conf``

apache24_enable="YES"

`/usr/local/etc/rc.d/apache24`

apache24_http_accept_enable="YES"



## Server configuration

`/usr/local/etc/apache24/httpd.conf`

```shell
Listen 80
ServerAdmin pinyuan@gmail.com
ServerName pinyuan.nctucs.net
DocumentRoot "/usr/local/www/apache24/data“

<Directory "/usr/local/www/apache24/data"> 
    Options Indexes FollowSymLinksMultiViews
    AllowOverrideNone
    Require all granted 
</Directory>
```



### Show different content between visiting with IP address and domain name

1. create a new directory structure for IP

```shell
DocumentRoot "/usr/local/www/apache24/data2“

<Directory "/usr/local/www/apache24/data2"> 
    Options Indexes FollowSymLinksMultiViews
    AllowOverrideNone
    Require all granted 
</Directory>
```

2. add Virtual hosts
   1. `/usr/local/etc/apache24/httpd.conf`

      uncomment `Include etc/apache24/extra/httpd-vhosts.conf`

   2. `/usr/local/etc/apache24/extra/httpd-vhosts.conf`

   ```shell
   NameVirtualHost *:80
   <VirtualHost *:80>
       ServerName pinyuan.nctucs.net
       DocumentRoot "/usr/local/www/apache24/data"
   </VirtualHost>
   <VirtualHost *:80>
       ServerName 192.168.112.128
       DocumentRoot "/usr/local/www/apache24/data2"
   </VirtualHost>
   ```



## Indexing

1. create a directory we want to access

2. `/usr/local/etc/apache24/httpd.conf`

   ```shell
   <Directory "/usr/local/www/apache24/data"> 
       Options +Indexes # enable index
       # Options -Indexes # unable index
   </Directory>
   ```



## htaccess

1. create a protected directory

   ```shell
   mkdir public/admin
   ```

2. htaccess 

   - method 1

     - reference: http://linux.vbird.org/linux_server/0360apache.php#www_adv_htaccess 

     - ```shell
       # /usr/local/etc/apache24/httpd.conf
       <Directory "/usr/local/www/apache24/data/public/admin">
           AllowOverride AuthConfig
           Order allow,deny
           Allow from all
       </Directory>
       ```

     - ```shell
       # create a .htaccess file in the protected directory
       AuthName     "Protect by htaccess, please provide user account and password"
       Authtype     Basic
       AuthUserFile /var/www/apache.passwd
       require user test
       ```

   - method 2

     - ```shell
       <Directory /usr/local/www/apache24/data/public/admin>
           AllowOverride AuthConfig
           Require user admin
       
           AuthName "Protect by htaccess, please provide user account and password"
           Authtype Basic
           AuthUserFile /var/www/apache.passwd
       </Directory>	
       ```

3. Set password for htaccess

   - ```
     sudo htpasswd -c /var/www/apache.passwd admin
     ```



## Reverse Proxy

reference: https://httpd.apache.org/docs/2.4/howto/reverse_proxy.html

- edit `/usr/local/etc/apache24/httpd.conf`

  ```shell
  <Proxy balancer://myset>
  	BalancerMember http://sahw4-loadbalance1.nctucs.net/
  	BalancerMember http://sahw4-loadbalance2.nctucs.net/
  	ProxySet lbmethod=bytraffic
  </Proxy>
  
  ProxyPass "/reverse"  "balancer://myset/"
  ProxyPassReverse "/reverse"  "balancer://myset/"
  ```

### Load module

- `mod_proxy`
- `mod_proxy_balancer`
- `mod_proxy_hcheck`
- `proxy_http_module`
- `lbmethod_bytraffic_module`
- `watchdog_module`
- `slotmem_shm_module`



## Hide Server Token

reference: http://bojack.pixnet.net/blog/post/31610515-%E3%80%90freebsd%E3%80%91%E5%9C%A8-apache-%E4%B8%8A%E9%9D%A2%E5%AE%89%E8%A3%9D-modsecutiry-%28open-sourc

1. install mod_security

   ```
   pkg install www/mod_security
   ```

2. uncomment last 3 line in `/usr/local/etc/apache24/modules.d/280_mod_security.conf`

3. disguise in `/usr/local/etc/apache24/modules.d/280_mod_security.conf`

   ```shell
   <IfModule mod_security2.c>
       SecServerSignature "Microsoft-IIS/5.0"
   </IfModule>
   ```

4. restart apache24 service
5. Check if success by `curl -Ik $IP_of_your_domain`



## HTTPS and Redirect to HTTPS

reference: https://blog.csdn.net/ithomer/article/details/50433363 

​		   http://bojack.pixnet.net/blog/post/29718009-%E3%80%90freebsd%E3%80%91apache-%2B-ssl-%E6%86%91%E8%AD%89%E8%A3%BD%E4%BD%9C

1. generate a self-signed certificate

   ```
   openssl genrsa -out server.key 2048
   openssl req -new -key server.key -out server.csr
   openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
   ```

2. mv

   ```
   cp server.crt /usr/local/etc/apache24/certs/
   cp server.key /usr/local/etc/apache24/private/        
   cp server.csr /usr/local/etc/apache24/private/
   chmod -R 400 private
   ```

3. Apache Web setting

   - `/usr/local/etc/apache24/httpd.conf`

     - enable LoadModule

       ```
       ssl_module_libexec/apache24/mod_ssl.so
       socache_shmcb_module modules/mod_socache_shmcb.so
       ```

     - umcomment `Include etc/apache22/extra/httpd-ssl.conf` 

   - edit  `/usr/local/etc/apache24/extra/httpd-ssl.conf`

     ```shell
     #   General setup for the virtual host
     DocumentRoot "/usr/local/www/apache22/data"
     ServerName 主機名稱:443
     ServerAdmin 網站管理者 E-mail
     ErrorLog "/var/log/httpd-error.log"
     TransferLog "/var/log/httpd-access.log"
     
     SSLCertificateFile "/usr/local/etc/apache24/certs/server.crt"
     SSLCertificateKeyFile "/usr/local/etc/apache24/private/server.key"
     ```

4. auto redirect http to https	

   - edit `/usr/local/etc/apache24/extra/httpd-vhosts.conf`

     ```shell
     <VirtualHost *:80>
         ServerName pinyuan.nctucs.net
         Redirect / https://pinyuan.nctucs.net/ # if use permanet, you will get 301
     </VirtualHost>
     ```

5. test

   `curl -ILk domain_name`



## Problem

1. access domain name from host

   In your windows host system, edit `C:\Windows\System32\drivers\etc\hosts` as administrator and add a line:

   ```
   192.168.xxx.xxx   pinyuan.nctucs.net
   ```



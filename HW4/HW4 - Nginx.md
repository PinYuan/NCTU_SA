# HW4 - Nginx

## Install Nginx

```shell
cd /usr/ports/www/nginx
make install clean

sysrc nginx_enable="YES"
```



## Important Information about Nginx webserver on a FreeBSD

reference: https://www.cyberciti.biz/faq/freebsd-install-nginx-webserver/

- Nginx Default configuration file: **/usr/local/etc/nginx/nginx.conf**
- Nginx Default http / https port: **80 / 443**
- Nginx Default error log file: **/var/log/nginx-error.log**
- Nginx Default access log file: **/var/log/nginx-access.log**
- Nginx Default DocumentRoot: **/usr/local/www/nginx/**
- Nginx service command: **service nginx (start|stop|restart|reload|configtest|upgrade|gracefulstop|status|poll)**



## Server configuration

`/usr/local/etc/nginx/nginx.conf`

1. change serve name in main server config
2. modify the location which stores the related html



## Show different content between visiting with IP address and domain name

1. create a corresponding directory to store virtual host's html

2. create a vhost config file

   ```shell
   server {
       listen 80;
       serve_name 192.168.112.128;
       
       location / {
           root /usr/local/www/nginx/data2;
           index index,html;
       }
   }
   ```

3. include vhosts config files in Nginx config file

   `/usr/local/etc/nginx/nginx.conf` adds `include /usr/local/etc/nginx/vhosts/*;`



## Indexing

reference:　https://www.keycdn.com/support/nginx-directory-index

​                      https://nginxlibrary.com/enable-directory-listing/

1. modify `/usr/local/etc/nginx/nginx.conf`

   ```shell
   root /usr/local/www/nginx/data;
   
   location / {
       # root /usr/local/www/nginx/data;
       index index.html index.htm;
   }
   
   location /public {
       autoindex on;
   }
   ```


## htaccess

reference: https://www.digitalocean.com/community/tutorials/how-to-set-up-password-authentication-with-nginx-on-ubuntu-14-04

1. create a protected directory

   ```shell
   mkdir public/admin
   ```

2. htaccess 

   - ```shell
     # /usr/local/etc/nginx/nginx.conf
     location /public/admin {
         index index.html;
         auth_basic "Restricted Content";
         auth_basic_user_file /var/www/nginx.passwd;
     }
     ```

3. Set password for htaccess

   - `sudo htpasswd -c /var/www/nginx.passwd admin`



## Reverse Proxy

reference: https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer/#overview

```shell
http {
    upstream backend {
        server sahw4-loadbalance1.nctucs.net;
        server sahw4-loadbalance2.nctucs.net;
    }
    
    server {
        location / {
            proxy_pass http://backend/; # remember add '/' at the end
        }
    }
}
```



## Hide Server Token

reference:　https://www.tecmint.com/hide-nginx-server-version-in-linux/

```shell
# /usr/local/etc/nginx/nginx.conf
http {
    server_tokens off # hide the version of nginx
}
```



## HTTPS and Redirect to HTTPS

reference: https://blog.gtwang.org/linux/nginx-create-and-install-ssl-certificate-on-ubuntu-linux/

1. create CA 

   ```shell
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /usr/local/etc/nginx/certs/nginx.key -out /usr/local/etc/nginx/certs/nginx.crt
   ```

2. Nginx setting

   ```shell
   # edit /usr/local/etc/nginx/nginx.conf
   server {
       listen 443 ssl default_server;
   
       ssl_certificate /usr/local/etc/nginx/certs/nginx.crt;
       ssl_certificate_key /usr/local/etc/nginx/certs/nginx.key;
   }
   ```

3. auto redirect http to https

   ```shell
   # edit /usr/local/etc/nginx/nginx.conf
   server {
       if ($scheme = http) {
           return 301 https://$host$request_uri;
       }
   }
   ```


## Problem

1. The plain HTTP request was sent to HTTPS port

   https://www.centos.bz/2018/01/nginx%E5%A6%82%E4%BD%95%E8%A7%A3%E5%86%B3the-plain-http-request-was-sent-to-https-port%E9%94%99%E8%AF%AF/
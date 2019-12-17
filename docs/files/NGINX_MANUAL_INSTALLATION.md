## NGINX MANUAL INSTALLATION
### install nginx - Ubuntu ###
sudo apt install curl gnupg2 ca-certificates lsb-release
echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx"
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
sudo apt-key fingerprint ABF5BD827BD9BF62
sudo apt update
sudo apt install nginx

### Install nginx - Centos ###
* sudo yum install yum-utils

* create the file named /etc/yum.repos.d/nginx.repo with the following content
    ```shell
    [nginx-stable]
    name=nginx stable repo
    baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
    gpgcheck=1
    enabled=1
    gpgkey=https://nginx.org/keys/nginx_signing.key
    module_hotfixes=true

    [nginx-mainline]
    name=nginx mainline repo
    baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
    gpgcheck=1
    enabled=0
    gpgkey=https://nginx.org/keys/nginx_signing.key
    module_hotfixes=true
    ```
* sudo yum install nginx


### modify nginx.conf ###
vi /etc/nginx/nginx.conf
```shell
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
}

http {
    include /etc/nginx/conf.d/ssl.conf;
}
```
### Create a custom file to configure ssl communication: ###
sudo vi /etc/nginx/conf.d/ssl.conf
```shell
server {
    listen 443 http2 ssl;
    listen [::]:443 http2 ssl;

    server_name 35.197.76.152;

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
    ssl_ecdh_curve secp384r1;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;

	location / {
		proxy_pass http://localhost:4545;
	}
}
```
### Create a self signed Certificate: ###
In order To create a self signed certificate please follow this [link](https://github.com/lacchain/besu-network/blob/master/docs/files/SELFSIGNED_CERTIFICATE.md)
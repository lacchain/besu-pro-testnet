## Generating Self signed certificate

This document provides instructions for properly configuring nginx as a reverse proxy for the BESU RPC communication.

**First, make sure you have installed nginx:**
```shell
$ which nginx
```
If you don not have nginx installed on your VM, please intall it following this link (https://gitbub.com/lacchain/besu-network/blob/master/docs/files/NGINX_MANUAL_INSTALLATION.md)

**create self signed certificate**
When prompted for the <strong>Common Name</strong> make sure to enter your the public ip where nginx will be exposed(Common Name (e.g. server FQDN or YOUR name) []:server_IP_address)
```shell
sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
```

**Configure Diffie Hellman (Perfect forward secrecy):**
```shell
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
```

**Verify your configuration is correct:**
```shell
nginx -t
```

**Restart and enable nginx at a service level:**
```shell
systemctl restart nginx
sudo systemctl enable nginx
```
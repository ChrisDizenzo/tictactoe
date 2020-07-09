---
id: NGINX
title: NGINX
sidebar_label: nginx.conf
---

This server utilizes a reverse proxy to forward traffic from the home server to the correct local port. The home server handles multiple traffic points including a secured port so I temporarily reset the configuration to simply run a http unsecured port and forward the traffic from the app to the machine. The line that handles this server is here:

```
server {
  listen 4000;
  location / {
    proxy_set_header    X-Forwarded-For $remote_addr;
    proxy_set_header 	X-Forwarded-Proto https;
    proxy_set_header    Host $http_host;
    proxy_pass 		    "http://127.0.0.1:4040";
    proxy_http_version 	1.1;
  }
}
```
# docker-haproxy
This image installs [HAProxy]( http://www.haproxy.org/), an open-source, high performance TCP/HTTP load balancer.

## Components
The software stack comprises the following components:

Name       | Version    | Description
-----------|------------|------------------------------
Ubuntu     | Trusty     | Operating system
HAProxy    | 1.5.9      | Load balancing software

## Usage
The default settings for the image do **not** result in a load balancing container; this requires manual configuration. However, we can quickly illustrate the HAProxy admin interface.

Create a container, as follows:

```no-highlight
sudo docker run -d -p 8443:8443 --name haproxy dell/haproxy
```

Check the container logs for the randomly-generated admin password:

```no-highlight
sudo docker logs haproxy
```

You will see some output like the following:

```no-highlight
Adding configuration file at /etc/haproxy
Generating password
====================================================================
View the stats as admin with password hqQfZIrydI4b
====================================================================
```

Make a secure note of user name (**admin**) and password (in this case, **hqQfZIrydI4b**), and access the container from your browser:

```no-highlight 
https://<ip address>/:8443/haproxy?stats
```

The browser will warn you that the certificate is not trusted. If you are unclear about how to proceed, please consult your browser's documentation on how to accept the certificate.

When prompted, enter your user name and password. You will be presented with a summary web page of statistics. Of course, HAProxy is not doing any real work yet; this requires manual configuration.

## Manual Configuration
The easiest way to configure a HAProxy container is to create a file on the host, and mount the parent folder as a data volume (discussed below). This file will survive a restart or recreation of the container, facilitating incremental changes to the configuration.

### DCM Users
If you are a DCM user, please SSH into the host VM, and stop the existing HAProxy container:

```no-highlight
sudo docker stop `docker ps -a -q`; sudo docker rm `docker ps -a -q`
```

Proceed with the next section.

### Example 1: LAMP Load Balancer

#### Step 1: Create the Configuration File
Create folder **/etc/haproxy**:

```no-highlight
sudo mkdir /etc/haproxy
```

In this folder, as sudo, create file **default.cfg**, with the following contents:

```no-highlight
global
    log     127.0.0.1 local0
    log     127.0.0.1 local1 notice
    maxconn 1024

defaults
    log         global
    mode        http
    option      httplog
    option      dontlognull
    retries     3
    contimeout  5s
    clitimeout  5s
    srvtimeout  5s

listen stats
    bind    *:8443 ssl crt /etc/ssl/certs/haproxy.pem
    stats   enable
    stats   refresh 30s
    stats   uri  /haproxy?stats
    stats   auth administrator:mypass

listen inbound
    bind     *:80
    option   httpchk GET /
    retries  3
    balance  roundrobin
    server   lamp1 172.17.42.1:8081 check inter 5s
    server   lamp2 172.17.42.1:8082 check inter 5s
```

Note the LAMP servers (**lamp1**, and **lamp2**), in section **inbound**, on the Docker host (IP address **172.17.42.1** is the Docker gateway).

#### Step 2: Start the LAMP Servers
Start the LAMP servers, as follows:

```no-highlight
sudo docker run -d -p 8081:80 --name lamp1 dell/lamp:1.0
sudo docker run -d -p 8082:80 --name lamp2 dell/lamp:1.0
```

The containers will take a few seconds to start up. Check the logs (```sudo docker logs lamp1```), and look for output similar to:

```no-highlight
2014-12-12 10:25:15,794 INFO success: mysqld entered RUNNING state...
2014-12-12 10:25:15,794 INFO success: apache2 entered RUNNING state...
```

#### Step 3: Start HAProxy Container
Start the HAProxy container with:

* Two persistent volumes on the host:
    * The HAProxy directory, available in **/etc/haproxy** (created by us) and;
    * The (rsyslogs) log, available in **/var/log/haproxy**
* A user name of **administrator**, with password **mypass** (from the configuration file)

As follows:

```no-highlight
sudo docker run -d -p 80:80 -p 8443:8443 \
    -v /etc/haproxy:/etc/haproxy \
    -v /var/log/haproxy:/var/log/haproxy \
    --name haproxy dell/haproxy \
```

The admin interface is available on port 8443. The LAMP stacks are load balanced on port 80.

#### Step 4: Verify the Logs and Stats
Browse to the instance (```http://<ip address>```), or use curl:

```no-highlight
curl http://localhost
```

Do this a few times, and then check the HAProxy log, as follows:

```
sudo cat /var/log/haproxy/haproxy.log
```

You should see output similar to the following:

```no-highlight
...: Proxy stats started.
...: Proxy stats started.
...: Proxy inbound started.
...: Proxy inbound started.
...: 172.17.42.1:58212 [...] inbound inbound/lamp1 0/0/0/2/2 200 622 - - ---- 1/1/0/1/0 0/0 "GET / HTTP/1.1"
...: 172.17.42.1:58218 [...] inbound inbound/lamp2 0/0/0/2/2 200 622 - - ---- 1/1/0/1/0 0/0 "GET / HTTP/1.1"
...: 172.17.42.1:58222 [...] inbound inbound/lamp1 0/0/0/1/1 200 622 - - ---- 1/1/0/1/0 0/0 "GET / HTTP/1.1"
```

You can also check the admin interface - user name, **administrator**, password **mypass** - by (again) doing:

```no-highlight 
https://<ip address>/:8443/haproxy?stats
```

### Example 2: RabbitMQ Cluster
Below is an example of a RabbitMQ cluster that will load balance between two nodes. Balance is the chosen load balancing algorithm, using TCP mode. Finally, there is the server command with the IP addresses. These are the two servers that will fulfil the TCP requests.

```no-highlight
listen rabbit_cluster 10.10.10.11:5672
    balance  roundrobin
    mode  tcp
    option  tcpka
    option  tcplog
    server rabbit_server1 10.10.10.12:5672  check
    server rabbit_server2 10.10.10.13:5672  check 
```

### Failover

Failover test, in the example above you would run the command **rabbitmqctl stop_app** on each server RabbitMQ is running one by one and review the HAProxy dashboard (```http://localhost/haproxy?adminstats```) and the logs to see this working.




```
sudo docker run -d -p 80:80 -p 8443:8443 \
    -v /etc/haproxy:/etc/haproxy \
    -v /var/log/haproxy:/var/log/haproxy \
    -e HAPROXY_USERNAME="administrator" \
    -e HAPROXY_PASSWORD="mypass" \
    --name haproxy dell/haproxy \
```


### Getting Started

The HAProxy configuration is very comprehensive and can be tuned to your requirements, below are some guidelines and documentation as a starting guide.

* [HAProxy Documentation](http://www.haproxy.org/#docs)
* [HAProxy Configuration Manual](http://cbonte.github.io/haproxy-dconv/configuration-1.4.html)


## Reference

### Image Details

Based on [CenturyLinkLabs/ctlc-docker-haproxy](https://github.com/CenturyLinkLabs/ctlc-docker-haproxy)

http://blog.haproxy.com/2012/09/04/howto-ssl-native-in-haproxy/
http://kb.snapt.net/balancer/custom-compile-haproxy-1-5-ssl-support/

http://seanmcgary.com/posts/using-sslhttps-with-haproxy

https://www.digitalocean.com/community/tutorials/how-to-use-haproxy-to-set-up-http-load-balancing-on-an-ubuntu-vps

Pre-built Image   | [https://registry.hub.docker.com/u/dell/haproxy](https://registry.hub.docker.com/u/dell/haproxy) 

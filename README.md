# docker-haproxy
This image installs [HAProxy]( http://www.haproxy.org/), an open-source, high performance TCP/HTTP load balancer.

## Components
The software stack comprises the following components:

Name       | Version    | Description
-----------|------------|------------------------------
Ubuntu     | Trusty     | Operating system
HAProxy    | 1.5.9      | Load balancing software

## Usage
The default settings for the image do **not** create a load balancing container. This requires manual configuration, which we will discuss shortly.

Let's start with a container which illustrates the admin interface:

```
sudo docker run -d -p 8443:8443 --name haproxy dell/haproxy
```

Check the container logs for the administrator password:

```no-highlight
docker logs haproxy
```

You will see some output like the following:

```no-highlight
Adding configuration file at /etc/haproxy
Generating password
====================================================================
View the stats as admin with password hqQfZIrydI4b
====================================================================
```

Make a secure note of user name (**admin**) and password (**hqQfZIrydI4b**).


TBC

### Start the container

To start your container with:

Do:

    sudo docker run -d -p 8080:8080 -p 80:80 --name haproxy dell/haproxy


Test your deployment:

    http://localhost/haproxy?stats

```no-highlight
listen inbound
    bind     *:80
    option   httpchk GET /
    retries  3
    balance  roundrobin
    server   lamp1 172.17.42.1:8081 check inter 5s
    server   lamp2 172.17.42.1:8082 check inter 5s
```

### Advanced Example 1

Start your container with:

* Two volumes (which will survive a restart or recreation of the container). The HAProxy directory is available in **/etc/haproxy** on the host and the logs are available in **/var/log/haproxy** on the host.

```no-highlight
sudo docker run -d -p 80:80 \
-v /etc/haproxy:/etc/haproxy \
-v /var/log/haproxy:/var/log/haproxy \
--name haproxy dell/haproxy
```

You can now make amendments to the haproxy.cfg file from within your host from **/etc/haproxy**.


### Advanced Example 2

The HAProxy dashboard is enabled by default with no credentials and the default URL is **http://localhost/haproxy?stats**. To enable the credentials while running the container you have the option of using the default username **admin** and setting a specific password with the default HAProxy dashboard URL, or by providing the three specific settings.

Start your container with:

* A specific HAProxy username for the HAPRroxy dashboard. A username can be defined, this is done by setting the environment variable `HAPROXY_USERNAME` to your specific username when running the container.
* A specific HAProxy password for the HAPRroxy dashboard. A password can be defined, this is done by setting the environment variable `HAPROXY_PASSWORD` to your specific password when running the container.
* A specific HAProxy URI for the HAPRroxy dashboard. A preset URL can be defined, this is done by setting the environment variable `HAPROXY_URI` to your specific URL when running the container.


```no-highlight
sudo docker run -d -p 80:80 \
-v /etc/haproxy:/etc/haproxy \
-e HAPROXY_USERNAME="administrator" \
-e HAPROXY_URI="/haproxy?adminstats" \
-e HAPROXY_PASSWORD="mypass" \
--name haproxy dell/haproxy
```


You can now test your new credentials, when prompted enter username `administrator` and password `mypass`:

    http://localhost/haproxy?adminstats


## Customisation

### Configuration

There are a number of configurations that can be made to the haproxy.cfg file, this includes the load balancing algorithm(round robin, least connections, source, URI, HTTP header and RDP cookie), performance tuning, process management and adding session stickiness with the use of cookies.

The formation of haproxy.cfg file is a block by block configuration of commands with parameters for each specific application. The file starts with a global and a defaults block, which consist of logging, daemon, user and group details etc. Below is an example of a RabbitMQ cluster that will load balance between two nodes. Balance is the chosen load balancing algorithm, using TCP mode. Finally, there is the server command with the IP addresses. These are the two servers that will fulfil the TCP requests.

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

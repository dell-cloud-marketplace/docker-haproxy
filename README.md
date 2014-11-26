#docker-haproxy
This is a base Docker image to run [HAProxy]( http://www.haproxy.org/) – is an open-source high availability proxy software. Providing the mechanism for load balancing with TCP and HTTP applications.

## Components
The software stack comprises the following components:

Name       | Version    | Description
-----------|------------|------------------------------
Ubuntu     | Trusty     | Operating system
HAProxy    | 1.4.24     | Load balancing software

## Usage

### Start the container

To start your container with:

* A named container ("haproxy")
* Host port 80 mapped to container port 80 (default admin port)

Do:

    sudo docker run -d -p 80:80 --name haproxy dell/haproxy


Test your deployment:

    http://localhost/haproxy?stats


### Advanced Example 1

Start your container with:

* Two volumes (which will survive a restart or recreation of the container). The HAProxy directory is vailable in **/etc/haproxy** on the host and the logs are available in **/var/log/haproxy** on the host.

```no-highlight
    sudo docker run -d -p 80:80 \ 
    -v /etc/haproxy:/etc/haproxy \ 
    -v /var/log/haproxy:/var/log/haproxy \
    --name haproxy dell/haproxy
```

You can now make amendments to the haproxy.cfg file from within your host.


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

The formation of haproxy.cfg file is a block by block configuration of commands with parameters for each specific application. The file starts with a global and a defaults block, which consist of logging, daemon, user and group details etc.  The remaining part of the configuration file is filled with the application configuration to load balance. Below is an example of a RabbitMQ cluster that will load balance between three nodes. This configuration the server and the port address. Balance is the chosen load balancing algorithm, using TCP mode. Finally, there is the server command with the IP addresses. These are the three servers that will fulfil the TCP requests.

```no-highlight
    listen rabbit_cluster 10.10.10.11:5672
        balance  roundrobin
        mode  tcp
        option  tcpka
        option  tcplog
        server 10.10.10.12:5672  check
        server 10.10.10.13:5672  check 
        server 10.10.10.14:5672  check
```

### Failover

Failover test, in the example above you would run the command **rabbitmqctl stop_app** on each server RabbitMQ is running one by one and review the dashboard and the logs to see this working.


## Reference

### Image Details

Based on [CenturyLinkLabs/ctlc-docker-haproxy](https://github.com/CenturyLinkLabs/ctlc-docker-haproxy)

Pre-built Image   | [https://registry.hub.docker.com/u/dell/haproxy](https://registry.hub.docker.com/u/dell/haproxy) 

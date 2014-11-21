#docker-haproxy
This is a base Docker image to run [HAProxy]( http://www.haproxy.org/) – is an open-source high availability proxy software. Providing the mechanism for load balancing with TCP and HTTP applications.

## Components
The software stack comprises the following components:

Name       | Version    | Description
-----------|------------|------------------------------
Ubuntu     | Trusty     | Operating system
MongoDB    | 1.4.24     | Load balancing software

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

* Data volume (which will survive a restart or recreation of the container). The HAProxy configuration is available in /etc/haproxy on the host. 


    sudo docker run -d -p 80:80 -v /etc/haproxy:/etc/haproxy --name haproxy dell/haproxy


You can now make amendments to the haproxy.cfg file from within your host.


### Advanced Example 2

The HAProxy dashboard is enabled by default with no credentials and the default URL is http://localhost/haproxy?stats. To enable the credentials while running the container you have the option of using the default username ‘admin’ and setting a specific password with the default HAProxy dashboard URL, or by providing the three specific settings.

Start your container with:

* A specific HAProxy username for the HAPRroxy dashboard. A username can be defined, this is done by setting the environment variable `HAPROXY_USERNAME` to your specific username when running the container.
* A specific HAProxy password for the HAPRroxy dashboard. A password can be defined, this is done by setting the environment variable `HAPROXY_PASSWORD` to your specific password when running the container.
* A specific HAProxy URI for the HAPRroxy dashboard. A preset URL can be defined, this is done by setting the environment variable `HAPROXY_URI` to your specific URL when running the container.


```no-highlight
   sudo docker run -p 80:80 
   -v /etc/haproxy:/etc/haproxy \
   -e HAPROXY_USERNAME="administrator" \
   -e HAPROXY_URI="/haproxy?adminstats" \
   -e HAPROXY_PASSWORD="mypass" 
   --name haproxy 
   dell/haproxy
```


You can now test your new credentials, when prompted enter username `administrator` and password `mypass`:


   http://localhost/haproxy?adminstats



## Reference

### Image Details

Based on [CenturyLinkLabs/ctlc-docker-haproxy](https://github.com/CenturyLinkLabs/ctlc-docker-haproxy)

Pre-built Image   | [https://registry.hub.docker.com/u/dell/haproxy](https://registry.hub.docker.com/u/dell/haproxy) 

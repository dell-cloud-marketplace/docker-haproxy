FROM ubuntu:trusty
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>


# Set environment variable for package install
ENV DEBIAN_FRONTEND noninteractive

# Install packages
RUN apt-get update && apt-get install -yq \
       haproxy=1.4.24-2ubuntu1 \
       supervisor && \ 
       apt-get clean && \ 
       rm -rf /var/lib/apt/lists/*



# Add configuration files
ADD enabled /etc/default/haproxy
ADD haproxy.cfg /etc/haproxy/haproxy.cfg

RUN cp -r /etc/haproxy /tmp/

# Add scripts
ADD /run.sh /run.sh
ADD /supervisord-haproxy.conf /etc/supervisor/conf.d/supervisord-haproxy.conf
RUN chmod 755 /*.sh


# Set volume directory for HAProxy file
VOLUME "/etc/haproxy"

# Expose port 80, for HAProxy dashboard
EXPOSE 80
CMD ["/run.sh"]

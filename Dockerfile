FROM ubuntu:trusty
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>

# Set environment variable for package install
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

# Install required packages
RUN apt-get install -yq \
    wget \
    libssl-dev \
    openssl \
    build-essential \
    make \
    pwgen \
    supervisor

# Install HAProxy
RUN wget http://www.haproxy.org/download/1.5/src/haproxy-1.5.9.tar.gz && \
    tar -xzf haproxy-1.5.9.tar.gz && \
    cd haproxy-1.5.9 && \
    make TARGET=linux2628 USE_OPENSSL=1 && \
    make install

# Create an SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout \
        /tmp/haproxy.key -out /tmp/haproxy.crt \
        -subj '/O=Dell/OU=MarketPlace/CN=www.dell.com' && \
    cat /tmp/haproxy.key /tmp/haproxy.crt > /tmp/haproxy.pem && \
    cp /tmp/haproxy.pem /etc/ssl/certs/haproxy.pem && \
    rm /tmp/haproxy.*

# Add configuration files
ADD enabled /etc/default/haproxy

ADD supervisord-haproxy.conf /etc/supervisor/conf.d/supervisord-haproxy.conf
ADD supervisord-rsyslog.conf /etc/supervisor/conf.d/supervisord-rsyslog.conf

ADD haproxy.conf /etc/rsyslog.d/haproxy.conf
ADD rsyslog.conf /etc/rsyslog.conf

# Add scripts
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# Make a back up of the haproxy config file. We will copy this in run.sh if
# /etc/haproxy is empty
ADD default.cfg /tmp/

# If the password is not changed, it will be generated in run.sh 
ENV HAPROXY_USERNAME admin
ENV HAPROXY_PASSWORD ""

VOLUME ["/etc/haproxy", "/var/log/haproxy"]

# Port 8443 is for the stats dashboard
EXPOSE 80 8443

CMD ["/run.sh"]
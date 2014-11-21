#!/bin/bash

VOLUME_HOME="/etc/haproxy"


# Test if VOLUME_HOME has content
if [[ ! "$(ls -A $VOLUME_HOME)" ]]; then
     echo "Add HAProxy files at $VOLUME_HOME"
     cp -R /tmp/haproxy/* $VOLUME_HOME
fi



if [ -z "$HAPROXY_USERNAME" ]; then
    export HAPROXY_USERNAME="admin"
fi  

if [ -z "$HAPROXY_URI" ]; then
    export HAPROXY_URI="/haproxy?stats"
fi  

# Add HAProxy dashboard credentials
if [ -n "$HAPROXY_PASSWORD" ]
then
  echo "	stats auth $HAPROXY_USERNAME:$HAPROXY_PASSWORD" >> \
		/etc/haproxy/haproxy.cfg
  echo "	stats uri  $HAPROXY_URI" >> /etc/haproxy/haproxy.cfg
fi


exec supervisord -n

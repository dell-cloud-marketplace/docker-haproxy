#!/bin/bash

VOLUME_HOME="/etc/haproxy"
PATTERN="stats auth"
PATTERN_URI="stats uri"


# Test if VOLUME_HOME has content
if [[ ! "$(ls -A $VOLUME_HOME)" ]]; then
     echo "Add HAProxy files at $VOLUME_HOME"
     cp -R /tmp/haproxy/* $VOLUME_HOME
fi


# Add syslog permissions
chown -R syslog:syslog /var/log/haproxy

# Check username and URI is passed
if [ -z "$HAPROXY_USERNAME" ]; then
    export HAPROXY_USERNAME="admin"
fi  

if [ -z "$HAPROXY_URI" ]; then
    export HAPROXY_URI="/haproxy?stats"
fi  


# Add HAProxy dashboard credentials
if [ -n "$HAPROXY_PASSWORD" ]
then
  if grep "stats auth" /etc/haproxy/haproxy.cfg
  then
	sed -i -e"s,$PATTERN.*,$PATTERN $HAPROXY_USERNAME:$HAPROXY_PASSWORD," \
		/etc/haproxy/haproxy.cfg
	sed -i -e"s,$PATTERN_URI.*,$PATTERN_URI ${HAPROXY_URI}," \
		/etc/haproxy/haproxy.cfg
  else
	echo "	$PATTERN $HAPROXY_USERNAME:$HAPROXY_PASSWORD" >> \
		/etc/haproxy/haproxy.cfg
	echo "	$PATTERN_URI  $HAPROXY_URI" >> /etc/haproxy/haproxy.cfg
  fi
fi



exec supervisord -n

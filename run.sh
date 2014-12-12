#!/bin/bash

HOME_VOLUME="/etc/haproxy"
CONFIG_FILE="${HOME_VOLUME}/default.cfg"

# If the home volume is empty...
if [[ ! "$(ls -A $HOME_VOLUME)" ]]; then

    # Copy from the backup folder.
    echo "Adding configuration file at $HOME_VOLUME"
    cp /tmp/default.cfg $HOME_VOLUME

    # Use the provided password or generate one.
    if [ $HAPROXY_PASSWORD == "password" ]; then
        echo "Generating password"
        HAPROXY_PASSWORD=$(pwgen -s 12 1)
    fi

    # Add the setting to the config file.
    echo "    stats   auth $HAPROXY_USERNAME:$HAPROXY_PASSWORD" >> $CONFIG_FILE

    echo "===================================================================="
    echo "View the stats as $HAPROXY_USERNAME with password $HAPROXY_PASSWORD"
    echo "===================================================================="
fi

# Update the syslog permissions
chown -R syslog:syslog /var/log/haproxy

exec supervisord -n

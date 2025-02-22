#!/bin/bash
# Start the cron daemon in the background
cron

# Start Apache in the foreground
exec /usr/sbin/apache2ctl -D FOREGROUND

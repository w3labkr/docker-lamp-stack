#!/bin/bash
# Register the cron job inline: run cron-scheduler every minute
# echo "* * * * * /usr/local/bin/php /var/www/html/scheduler/scheduler.php >/dev/null 2>&1" | crontab -
# echo "* * * * * /usr/local/bin/php /var/www/html/scheduler/scheduler.php >> /var/www/html/log/cron.log 2>&1" | crontab -

# Start the cron daemon in the background
cron

# Start Apache in the foreground
exec /usr/sbin/apache2ctl -D FOREGROUND

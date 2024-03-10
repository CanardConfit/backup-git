#!/bin/sh

# Configure crontab based on CRON_SCHEDULE environment variable
echo "${CRON_SCHEDULE} /backup-script.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root

# Start cron daemon in the foreground
crond -l 2 -f &

# Keep container running and log file tailed
tail -f /var/log/cron.log

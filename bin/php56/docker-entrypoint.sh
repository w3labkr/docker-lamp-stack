#!/bin/bash
set -e

# Create necessary directories
mkdir -p /var/run/apache2 /var/log/apache2

# Start cron if available
if command -v cron >/dev/null 2>&1; then
    cron
fi

# Start Apache in foreground
exec apache2-foreground

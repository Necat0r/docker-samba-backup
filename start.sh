#!/bin/sh

# Glue to get SIGINT & SIGTERM to propagate and also wait for tail to finish before quitting
# shamelessly stolen from https://unix.stackexchange.com/a/444676
prep_term()
{
    unset term_child_pid
    unset term_kill_needed
    trap 'handle_term' TERM INT
}

handle_term()
{
    if [ "${term_child_pid}" ]; then
        kill -TERM "${term_child_pid}" 2>/dev/null
    else
        term_kill_needed="yes"
    fi
}

wait_term()
{
    term_child_pid=$!
    if [ "${term_kill_needed}" ]; then
        kill -TERM "${term_child_pid}" 2>/dev/null
    fi
    wait ${term_child_pid}
    trap - TERM INT
    wait ${term_child_pid}
}

prep_term

# Main script
echo "*** Starting samba backup container ***"
if ! mount -t cifs -o user=$SAMBA_USER,pass=$SAMBA_PASS $SAMBA_TARGET /target; then
    echo Failed mounting
    exit 1
fi

echo Setting up crontab
touch /var/log/backup.log
echo "$BACKUP_CRON" "/tmp/backup.sh >> /var/log/backup.log" > /tmp/crontab
crontab /tmp/crontab
cat /var/spool/cron/crontabs/root

echo Starting cron daemon
touch /var/log/cron.log
crond -L /var/log/cron.log

# Note cannot use exec tail since it won't properly process sigterm
# exec tail -f -q /var/log/cron.log /var/log/backup.log
tail -f -q /var/log/cron.log /var/log/backup.log &

wait_term
echo "*** Container stopped ***"

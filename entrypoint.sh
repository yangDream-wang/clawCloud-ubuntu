#!/usr/bin/env sh

useradd -m -s /bin/bash $SSH_USER
echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
usermod -aG sudo $SSH_USER
echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/init-users
echo 'PermitRootLogin no' > /etc/ssh/sshd_config.d/my_sshd.conf
chown -R $SSH_USER:$SSH_USER /opt/uptime-kuma
echo "0 9 * * * cd /home/wyy/clawcloud-autologin/ && NODE_OPTIONS=\"--no-deprecation\" /usr/bin/python3 /home/wyy/clawcloud-autologin/takeover_browser.py --sleep >> /home/wyy/clawcloud-autologin/run.log 2>&1" | crontab -u $SSH_USER -
service cron start
service nginx start
if [ -n "$START_CMD" ]; then
    set -- $START_CMD
fi

exec "$@"

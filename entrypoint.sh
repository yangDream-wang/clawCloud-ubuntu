#!/usr/bin/env sh

useradd -m -s /bin/bash $SSH_USER
echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
usermod -aG sudo $SSH_USER
echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/init-users
echo 'PermitRootLogin no' > /etc/ssh/sshd_config.d/my_sshd.conf

echo "0 9 * * 1-5 cd /home/wyy/clawcloud-autologin/ && sleep \$(($(od -An -N2 -i /dev/urandom) % 28800)) && NODE_OPTIONS=\"--no-deprecation\" /usr/bin/python3 /home/wyy/clawcloud-autologin/takeover_browser.py  >> /home/wyy/clawcloud-autologin/run.log 2>&1" | crontab -u $SSH_USER -
service cron start
if [ -n "$START_CMD" ]; then
    set -- $START_CMD
fi

exec "$@"

#!/usr/bin/env sh

useradd -m -s /bin/bash $SSH_USER
echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
usermod -aG sudo $SSH_USER
echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/init-users
echo 'PermitRootLogin no' > /etc/ssh/sshd_config.d/my_sshd.conf
cp -r /tmp/uptime-kuma /home/$SSH_USER/uptime-kuma

# 初始化 3x-ui 数据目录
mkdir -p /home/$SSH_USER/x-ui-data
cp -r /usr/local/x-ui/x-ui/bin /home/$SSH_USER/x-ui-data/
if [ ! -f /home/$SSH_USER/x-ui-data/x-ui.db ]; then
    cat > /home/$SSH_USER/x-ui-data/x-ui.db.init << 'EOF'
{
  "username": "admin",
  "password": "admin",
  "port": 2053
}
EOF
fi

#设置cron
echo "0 9 * * * cd /home/$SSH_USER/clawcloud-autologin/ && NODE_OPTIONS=\"--no-deprecation\" /usr/bin/python3 /home/$SSH_USER/clawcloud-autologin/takeover_browser.py --sleep >> /home/$SSH_USER/clawcloud-autologin/run.log 2>&1" | crontab -u $SSH_USER -

service cron start
service nginx start
# 启动 uptime-kum
cd /home/$SSH_USER/uptime-kuma && pm2 start server/server.js --name uptime-kuma
# 启动 3x-ui，数据目录指向用户家目录
cd /home/$SSH_USER/x-ui-data && /usr/local/x-ui/x-ui/x-ui run &
if [ -n "$START_CMD" ]; then
    set -- $START_CMD
fi

exec "$@"

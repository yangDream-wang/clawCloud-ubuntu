Claw cloud 容器改造 VPS, 实现 SSH 远程登录
# Ubuntu  

This project provides a custom Docker image based on Ubuntu, designed to simulate a minimal VPS environment. It includes an SSH server enabled by default, allowing users to interact with the container just like a typical remote server. This setup is ideal for testing, development, or training purposes where a lightweight and easily reproducible virtual server is needed.

## Usage

```bash
docker run -d \
  --name ubuntu \
  -p 2222:22 \
  -e SSH_USER=ubuntu \
  -e SSH_PASSWORD='ubuntu!23' \
  ghcr.io/yangdream-wang/clawcloud-ubuntu:playwright
```



本期摘要：Claw cloud | vps | ssh
Claw cloud 注册地址：
https://console.run.claw.cloud/signin?link=TSWVWVN3G294

项目地址：
[https://github.com](https://github.com/yangDream-wang/clawCloud-ubuntu)

容器特点
容器一般只运行一个前台进程（PID=1）
容器重启后，未挂载存储的数据会丢失
容器内部端口需要映射到外部，才可以访问
家目录初始化
1、权限设置

ls -l /home
sudo chown -R $USER:$USER /home/$USER
sudo sudo service cron start

```bash
* * * * * cd /home/wyy && NODE_OPTIONS="--no-deprecation" /usr/bin/python3 /home/wyy/takeover_browser.py >> /home/wyy/run.log 2>&1
0 9 * * 1-5 cd /home/wyy && sleep $(($(od -An -N2 -i /dev/urandom) % 28800)) && NODE_OPTIONS="--no-deprecation" /usr/bin/python3 /home/wyy/takeover_browser.py >> /home/wyy/run.log 2>&1
```
2、终端字体颜色美化、ls -l 命令别名设置等

curl -sk -o ~/.bashrc https://raw.githubusercontent.com/vevc/ubuntu/refs/heads/main/.bashrc
curl -sk -o ~/.profile https://raw.githubusercontent.com/vevc/ubuntu/refs/heads/main/.profile
注意事项
需要长期保存的数据，请一定存放在用户家目录，重要数据定期备份
通过 apt install 安装的应用重启后会丢失（需要在构建镜像时安装）

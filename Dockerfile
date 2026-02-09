FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/vevc/ubuntu"

ENV TZ=Asia/Shanghai \
    SSH_USER=ubuntu \
    SSH_PASSWORD=ubuntu!23 \
    START_CMD=''

COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot

# 1. 原作者的基础环境 + SSH
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y \
        tzdata \
        openssh-server \
        sudo \
        curl \
        ca-certificates \
        wget \
        vim \
        net-tools \
        supervisor \
        cron \
        unzip \
        zip \
        iputils-ping \
        telnet \
        git \
        iproute2 \
        nginx \
        --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/sshd && \
    chmod +x /entrypoint.sh && \
    chmod +x /usr/local/sbin/reboot && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# 2. Playwright 和 Chrome 运行需要的系统库 + Python
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        gnupg \
        fonts-liberation \
        libasound2 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libatspi2.0-0 \
        libcups2 \
        libdbus-1-3 \
        libdrm2 \
        libgbm1 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libwayland-client0 \
        libxcomposite1 \
        libxdamage1 \
        libxfixes3 \
        libxkbcommon0 \
        libxrandr2 \
        xdg-utils \
        libu2f-udev \
        libvulkan1 \
        --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 3. 添加 Google Chrome 源并安装 Chrome
RUN mkdir -p /usr/share/keyrings && \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends google-chrome-stable && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 4. 安装 Playwright 及其浏览器（Chromium + 依赖）
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install playwright && \
    python3 -m playwright install --with-deps chromium

# 5. 安装 Node.js 和 uptime-kuma
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    npm install -g pm2 && \
    mkdir -p /tmp/uptime-kuma && \
    git clone https://github.com/louislam/uptime-kuma.git /tmp/uptime-kuma && \
    cd /tmp/uptime-kuma && \
    npm ci --production && \
    npm install && \
    npm run build && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 6. 安装 3x-ui
RUN mkdir -p /usr/local/x-ui && \
    wget -O /tmp/x-ui.tar.gz https://github.com/mhsanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz && \
    tar -xzf /tmp/x-ui.tar.gz -C /usr/local/x-ui && \
    chmod +x /usr/local/x-ui/x-ui && \
    rm /tmp/x-ui.tar.gz

EXPOSE 22 3001 54321

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]

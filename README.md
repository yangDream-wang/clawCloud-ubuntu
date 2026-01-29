# Ubuntu  

This project provides a custom Docker image based on Ubuntu, designed to simulate a minimal VPS environment. It includes an SSH server enabled by default, allowing users to interact with the container just like a typical remote server. This setup is ideal for testing, development, or training purposes where a lightweight and easily reproducible virtual server is needed.

## Usage

```bash
docker run -d \
  --name ubuntu \
  -p 2222:22 \
  -e SSH_USER=ubuntu \
  -e SSH_PASSWORD='ubuntu!23' \
  ghcr.io/vevc/ubuntu:25.11.15
```


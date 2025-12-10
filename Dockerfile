# Use a secure and up-to-date base image
FROM debian:bookworm

# 1. Install necessary packages (OpenSSH, wget, unzip)
# Output is redirected to /dev/null for cleaner build logs
RUN apt update -y > /dev/null 2>&1 \
    && apt upgrade -y -q > /dev/null 2>&1 \
    && apt install -y openssh-server wget unzip > /dev/null 2>&1

# 2. Download and unzip ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1 \
    && unzip ngrok.zip

# 3. Configure SSHD and set the root password
# WARNING: Using 'root:root123' is highly insecure for production. Change this password immediately.
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
    && echo "root:root123" | chpasswd \
    && mkdir -p /run/sshd

# 4. Create the /start.sh script with logging enabled
RUN echo "#!/bin/bash" > /start.sh \
    && echo "echo '--- Starting ngrok Tunnel ---'" >> /start.sh \
    && echo "./ngrok config add-authtoken 36fS8ajJhK07wllz4E0mv85icOt_6PCNgWcb7CAQjkgnRSKUc" >> /start.sh \
    && echo "echo 'The ngrok tunnel URL should appear below:'" >> /start.sh \
    && echo "./ngrok tcp 22 --log=stdout &" >> /start.sh \
    && echo "sleep 5" >> /start.sh \
    && echo "echo '--- Starting SSHD in Foreground ---'" >> /start.sh \
    && echo "/usr/sbin/sshd -D" >> /start.sh \
    && chmod +x /start.sh

# 5. Define the command to run when the container starts
CMD [ "/start.sh" ]

# Use Debian 12 (Bookworm)
FROM debian:bookworm

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Default arguments
ARG ngrokid=36fS8ajJhK07wllz4E0mv85icOt_6PCNgWcb7CAQjkgnRSKUc
ARG Password=root123

# Make them available in the container
ENV Password=${Password}
ENV ngrokid=${ngrokid}

# Update system and install required packages
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y -q > /dev/null 2>&1 \
    && apt install -y openssh-server wget unzip > /dev/null 2>&1

# Download and unzip ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1 \
    && unzip ngrok.zip

# Configure SSH and set default root password
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
    && echo "root:${Password}" | chpasswd \
    && mkdir -p /run/sshd

# Create startup script to run ngrok and SSH
RUN echo "#!/bin/bash" > /start.sh \
    && echo "./ngrok config add-authtoken ${ngrokid}" >> /start.sh \
    && echo "./ngrok tcp 22 &>/dev/null &" >> /start.sh \
    && echo "/usr/sbin/sshd -D" >> /start.sh \
    && chmod +x /start.sh

# Expose necessary ports
EXPOSE 22 80 8080 8888 443 5130-5135 3306

# Start everything
CMD ["/start.sh"]

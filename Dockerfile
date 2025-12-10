FROM debian:bookworm
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y -q > /dev/null 2>&1 \
    && apt install -y openssh-server wget unzip > /dev/null 2>&1
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1 \
    && unzip ngrok.zip
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
    && echo "root:root123" | chpasswd \
    && mkdir -p /run/sshd
RUN echo "#!/bin/bash" > /start.sh \
    && echo "./ngrok config add-authtoken 36fS8ajJhK07wllz4E0mv85icOt_6PCNgWcb7CAQjkgnRSKUc" >> /start.sh \
    && echo "./ngrok tcp 22 &>/dev/null &" >> /start.sh \
    && echo "/usr/sbin/sshd -D" >> /start.sh \
    && chmod +x /start.sh

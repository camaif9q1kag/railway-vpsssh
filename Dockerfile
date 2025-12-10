# Use Debian 12 (Bookworm) specifically
FROM debian:bookworm

# Prevent interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Update and upgrade system silently
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1

# Arguments for ngrok and SSH password
ARG ngrokid
ARG Password
ENV Password=${Password}
ENV ngrokid=${ngrokid}

# Install required packages
RUN apt install -y openssh-server wget unzip > /dev/null 2>&1

# Download and unzip ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1 \
    && unzip ngrok.zip

# Create startup script
RUN echo "./ngrok config add-authtoken ${ngrokid} &&" >> /1.sh \
    && echo "./ngrok tcp 22 &>/dev/null &" >> /1.sh \
    && mkdir -p /run/sshd \
    && echo '/usr/sbin/sshd -D' >> /1.sh \
    && chmod 755 /1.sh

# Configure SSH
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "root:${Password}" | chpasswd

# Expose ports
EXPOSE 22 80 8080 8888 443 5130-5135 3306

# Run startup script
CMD ["/1.sh"]

FROM debian:bullseye

# Set frontend to noninteractive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends net-tools ca-certificates curl hping3 tcptraceroute wget dnsutils \
    fonts-dejavu-core lighttpd procps smokeping ssmtp fping && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /usr/bin/ && wget https://pingpros.com/pub/tcpping && chmod +X tcpping && chmod 755 tcpping
RUN cat /etc/smokeping/config.d/Database
RUN cat /etc/smokeping/config.d/pathnames
# Configure Lighttpd and Smokeping
COPY lighttpd-smokeping-config.sh /tmp/
COPY smokemail /etc/smokeping/smokemail
RUN chmod +x /etc/smokeping/smokemail
# Copy startup script
COPY smokeping.sh /usr/bin/
RUN chmod +x /usr/bin/smokeping.sh
RUN chmod +x /tmp/lighttpd-smokeping-config.sh
RUN /bin/bash /tmp/lighttpd-smokeping-config.sh

# Prepare directories for mounting and set permissions
RUN mkdir /var/run/smokeping && \
    #ln -s /var/cache/smokeping/ /var/www/smokeping/cache && \
    #ln -s /var/www/smokeping/js/prototype/prototype.js /var/www/smokeping/js/prototype.js && \
    ln -s /usr/share/smokeping/www /var/www/smokeping && \
    ln -s /usr/lib/cgi-bin /var/www/ && \
    ln -s /usr/lib/cgi-bin/smokeping.cgi /var/www/smokeping/ && \
    chown -Rh smokeping:www-data /var/cache/smokeping /var/lib/smokeping /run/smokeping && \
    chmod -R g+ws /var/cache/smokeping /var/lib/smokeping /run/smokeping && \
    chmod u+s /usr/bin/fping

# Set up volumes for persistent data
VOLUME /etc/smokeping /var/lib/smokeping /var/cache/smokeping
# Expose HTTP service port
EXPOSE 80

# Start Smokeping
ENTRYPOINT ["/usr/bin/smokeping.sh"]

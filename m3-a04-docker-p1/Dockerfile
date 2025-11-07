# Start from the ubuntu image
FROM ubuntu:latest

# Install Apache2
RUN apt update && \
    apt install -y apache2 && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

# When container starts, always run apache2 service in foreground
ENTRYPOINT ["apachectl", "-D", "FOREGROUND"]

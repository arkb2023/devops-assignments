# Start from the ubuntu image
FROM ubuntu:latest

# Install Apache2
RUN apt update && \
    apt install -y apache2 && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy custom HTML page
COPY index.html /var/www/html/

# When container starts, always run apache2 service in foreground
ENTRYPOINT ["apachectl", "-D", "FOREGROUND"]

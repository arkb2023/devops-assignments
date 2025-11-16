FROM docker:24-git

# Install bash for the script
RUN apk add --no-cache bash

# Create app directory
WORKDIR /app

# Copy the builder script and entrypoint
COPY builder.sh /app/builder.sh
COPY entrypoint.sh /app/entrypoint.sh

# Make scripts executable
RUN chmod +x /app/builder.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
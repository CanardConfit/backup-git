FROM alpine:latest

# Define the volume for the Git repository
VOLUME /git-repo/

# Install necessary packages: Git for version control, rsync for file synchronization,
# openssh-client for SSH operations, dcron for scheduling tasks, and tzdata for timezone management
RUN apk add --no-cache git rsync openssh-client dcron tzdata

# Copy the backup script into the image and make it executable
COPY backup-script.sh /backup-script.sh
RUN chmod +x /backup-script.sh

# Create the log file to enable log output via 'docker logs'
RUN touch /var/log/cron.log

# -----------------------------------------------
# Set environment variables for the backup script
# -----------------------------------------------

# SOURCE_FOLDER_PATH is the path to the source directory to backup.
ENV SOURCE_FOLDER_PATH="/source"

# COMMIT_MESSAGE_TEMPLATE is the template for the git commit message.
ENV COMMIT_MESSAGE_TEMPLATE="Backup on CURRENT_DATE"

# GIT_REMOTE_URL is the URL of the Git remote repository.
ENV GIT_REMOTE_URL=""

# SSH_PRIVATE_KEY should contain your SSH private key for Git operations, encoded in base64.
# This environment variable must be set externally.
ENV SSH_PRIVATE_KEY=""

# CRON_SCHEDULE defines when the backup script runs, defaulting to midnight every day.
# Use standard cron format (e.g., "0 0 * * *" for midnight).
ENV CRON_SCHEDULE="0 0 * * *"

# Configure crontab based on CRON_SCHEDULE environment variable
RUN echo "${CRON_SCHEDULE} /backup-script.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root

# ----------
# Entrypoint
# ----------

# Start the cron daemon in the foreground and follow the cron log file.
# This CMD instruction ensures that the container keeps running and logs can be monitored.
CMD ["sh", "-c", "crond -l 2 -f & tail -f /var/log/cron.log"]
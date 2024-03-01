# Git Repository Backup Solution

![Docker Pulls](https://img.shields.io/docker/pulls/canardconfit/backup-git)
![GitHub Release](https://img.shields.io/github/v/release/CanardConfit/backup-git)
![GitHub Repo stars](https://img.shields.io/github/stars/CanardConfit/backup-git)

This solution provides an automated way to back up a Git repository hosted on an Alpine Linux container. The setup involves a Docker container configured with cron jobs to perform daily backups of the specified Git repository. This README outlines the setup process, how to configure your environment, and how to use the backup solution.

## Features

- **Scheduled Backups**: Leverages `dcron` to schedule daily backups at midnight (located in Dockerfile).
- **Environment Customization**: Allows configuration of source directory, commit message template, Git remote URL, and SSH private key through environment variables.
- **SSH Key Management**: Incorporates SSH setup for Git operations to securely connect to the remote repository.
- **Timezone Management**: Timezone configuration within the container.

## Prerequisites

- Docker and Docker Compose installed on your host machine.
- Base64 encoded SSH private key for secure Git operations.
- Access to the Git remote repository configured with the provided SSH key.

## Docker Compose Configuration

The `docker-compose.yml` file facilitates the deployment of the backup solution and, for my personal use, the https://github.com/CanardConfit/livesync-bridge service. Here's an example configuration:

```yaml
services:
  livesync-bridge:
    image: canardconfit/livesync-bridge
    environment:
      TZ: Europe/Zurich
    volumes:
      - /your/local/path:/livesync-bridge/dat/
      - obsidian-volume:/livesync-bridge/obsidian/

  git:
    image: canardconfit/backup-git
    depends_on:
      - livesync-bridge
    volumes:
      - obsidian-volume:/obsidian/
      - git-volume:/git-repo/
    environment:
      TZ: Europe/Zurich
      SOURCE_FOLDER_PATH: "/obsidian/"
      COMMIT_MESSAGE_TEMPLATE: "Backup on CURRENT_DATE" # CURRENT_DATE is a placeholder
      GIT_REMOTE_URL: "<Your_remote_ssh_git_repo>"
      SSH_PRIVATE_KEY: "<Your_Base64_Encoded_SSH_Private_Key>"

volumes:
  obsidian-volume:
  git-volume:
```

## Running the Backup Solution

To run the backup solution, execute:

```bash
docker compose up -d
```

This command starts the containers defined in `docker-compose.yml`, running the backup operations as configured.

## Monitoring and Logs

To monitor backup operations, you can check the cron logs within the container:

```bash
docker logs <container_name>
```

## Contributions

We warmly welcome contributions to this project!

## License

This project is released under MPL-2.0.

The MPL-2.0 license allows the mixing of the covered code with other code under different licenses, provided that the MPL-2.0-covered code remains governed by the MPL-2.0 terms.

For more information about the license, please refer to the [LICENSE](LICENSE) file in the root of this project or visit [Mozilla's official MPL 2.0 page](http://mozilla.org/MPL/2.0/).

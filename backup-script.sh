#!/bin/sh

# ---------------------
# Setup SSH Environment
# ---------------------
SSH_PATH="$HOME/.ssh"
mkdir -p "$SSH_PATH"
echo $SSH_PRIVATE_KEY | base64 -d > "$SSH_PATH/id_rsa"
chmod 600 "$SSH_PATH/id_rsa"
SSH_KNOWN_HOSTS="$SSH_PATH/known_hosts"

# ------------------
# Extract Git Domain
# ------------------
GIT_DOMAIN=$(echo "$GIT_REMOTE_URL" | sed -E 's/.*@([^:]+).*/\1/')

if [ -z "$GIT_DOMAIN" ]; then
    echo "Error extracting domain for $SSH_KNOWN_HOSTS."
    exit 1
fi

echo "Extracted domain: $GIT_DOMAIN"

# -----------------------------
# Add Git Domain to Known Hosts
# -----------------------------
ssh-keyscan -H "$GIT_DOMAIN" >> "$SSH_KNOWN_HOSTS"

if [ $? -eq 0 ]; then
    echo "Domain $GIT_DOMAIN has been added to $SSH_KNOWN_HOSTS."
else
    echo "Error adding $GIT_DOMAIN to $SSH_KNOWN_HOSTS."
    exit 1
fi

# ----------------------
# Prepare Git Repository
# ----------------------
SOURCE_FOLDER="${SOURCE_FOLDER_PATH}"
COMMIT_MESSAGE=$(echo "${COMMIT_MESSAGE_TEMPLATE}" | sed "s/CURRENT_DATE/$(date '+%Y-%m-%d %H:%M:%S')/")

# ---------------------------------------------
# Ensure we are in the git repository directory
# ---------------------------------------------
cd "/git-repo" || exit

if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    git remote add origin "${GIT_REMOTE_URL}"
fi

# -------------------------
# Force Pull Latest Changes
# -------------------------
git pull origin master --force

# ------------------
# Configure Git User
# ------------------
git config user.email "backup@noreply.com"
git config user.name "Backup Bot"

# ---------------------------------------------------
# Sync Files
# Return to the parent directory before running rsync
# ---------------------------------------------------
cd "../" || exit
echo "Copying data from $SOURCE_FOLDER..."
rsync -av --delete --exclude '.git/' --exclude '.git/**' "$SOURCE_FOLDER/" "/git-repo/"

# -----------------------------------------------------------------------
# Return to the git repository directory to add, commit, and push changes
# -----------------------------------------------------------------------
cd "/git-repo" || exit
echo "Adding changes..."
git add .

echo "Committing changes..."
git commit -m "$COMMIT_MESSAGE"

# ------------
# Push Changes
# ------------
echo "Pushing changes..."
git push origin master

echo "Backup and push completed."

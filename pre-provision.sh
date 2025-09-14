#!/bin/bash

REPO_URL="https://github.com/omardbaa/simple-web-app.git"
TARGET_DIR="./website/simple-web-app"

echo "[HOST] Checking if the repo needs to be cloned or updated..."

# Ensure ./website directory exists
mkdir -p ./website

if [ ! -d "$TARGET_DIR" ]; then
    echo "[HOST] Cloning repository into $TARGET_DIR..."
    git clone "$REPO_URL" "$TARGET_DIR" || {
        echo "[ERROR] Failed to clone repository!"
        exit 1
    }
else
    echo "[HOST] Repository already exists. Attempting to update..."
    cd "$TARGET_DIR"

    # Reset local changes to avoid merge issues
    git reset --hard HEAD
    git clean -fd

    # Pull latest changes
    git pull origin main || echo "[WARNING] Failed to pull latest changes"
    cd - >/dev/null
fi

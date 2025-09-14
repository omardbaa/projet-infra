#!/bin/bash
set -e

APP_DIR="/var/www/html/simple-web-app"
LOGS_DIR="/var/www/logs"
LOCAL_REPO="/vagrant/website/simple-web-app"
REPO_URL="https://github.com/omardbaa/simple-web-app.git"

# Clone the repo to local machine if not already present
if [ ! -d "$LOCAL_REPO/.git" ]; then
  echo "[WEB] Cloning app repository into ./website/simple-web-app..."
  git clone "$REPO_URL" "$LOCAL_REPO"
else
  echo "[WEB] Pulling latest code from repository..."
  cd "$LOCAL_REPO" && git pull origin main
fi

echo "[WEB] Updating package lists..."
sudo apt-get update -y

echo "[WEB] Installing required packages..."
sudo apt-get install -y git nginx python3 python3-pip python3-venv build-essential libpq-dev

echo "[WEB] Checking if app directory exists at $APP_DIR..."
if [ ! -d "$APP_DIR" ]; then
  echo "[ERROR] $APP_DIR does not exist."
  exit 1
fi

if [ ! -f "$APP_DIR/app.py" ] || [ ! -f "$APP_DIR/requirements.txt" ]; then
  echo "[ERROR] app.py or requirements.txt not found in $APP_DIR."
  exit 1
fi

echo "[WEB] Setting ownership for app directory..."
sudo chown -R vagrant:www-data "$APP_DIR"

echo "[WEB] Setting up Python virtual environment and installing dependencies..."
cd "$APP_DIR"

if [ ! -d venv ]; then
  python3 -m venv venv
fi

source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
deactivate

echo "[WEB] Creating secure .env file..."
cat <<EOF > "$APP_DIR/.env"
MYSQL_HOST=192.168.56.20
MYSQL_USER=webuser
MYSQL_PASSWORD=MyS3cur3P@ssw0rd
MYSQL_DATABASE=demo_db
EOF

sudo chown vagrant:www-data "$APP_DIR/.env"
sudo chmod 640 "$APP_DIR/.env"

echo "[WEB] Setting up logging directory and permissions..."
sudo mkdir -p "$LOGS_DIR"
sudo chown -R vagrant:www-data "$LOGS_DIR"
sudo chmod -R 755 "$LOGS_DIR"

echo "[WEB] Testing log write permissions..."
echo "Log test: $(date)" > "$LOGS_DIR/test.log" || { echo "[ERROR] Log write failed"; exit 1; }

echo "[WEB] Configuring Nginx..."
sudo tee /etc/nginx/sites-available/simple-web-app > /dev/null <<EOF
server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    access_log $LOGS_DIR/access.log;
    error_log $LOGS_DIR/error.log;
}
EOF

sudo ln -sf /etc/nginx/sites-available/simple-web-app /etc/nginx/sites-enabled/simple-web-app
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
sudo apt install mysql-client-core-8.0 -y

echo "[WEB] Setting up systemd service for Flask app..."
sudo tee /etc/systemd/system/simple-web-app.service > /dev/null <<EOF
[Unit]
Description=Simple Flask Web App
After=network.target

[Service]
User=vagrant
Group=www-data
WorkingDirectory=$APP_DIR
EnvironmentFile=$APP_DIR/.env
Environment="PATH=$APP_DIR/venv/bin"
ExecStart=$APP_DIR/venv/bin/python app.py

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable simple-web-app
sudo systemctl restart simple-web-app

echo "[WEB] Provisioning completed successfully!"


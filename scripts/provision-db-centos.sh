#!/bin/bash
set -e

# Use values from Vagrantfile or fallback
DB_NAME="demo_db"
DB_USER="webuser"
DB_PASS="${MYSQL_PASSWORD:-MyS3cur3P@ssw0rd}"
WEB_IP="${WEB_IP:-192.168.56.10}"

CREATE_SQL="/vagrant/database/create-table.sql"
INSERT_SQL="/vagrant/database/insert-demo-data.sql"

echo "[DB] Updating and installing MySQL..."
sudo dnf -y update


echo "[DB] Installing MySQL Server..."
sudo dnf install -y mysql-server.x86_64 --nogpgcheck

echo "[DB] Starting and enabling MySQL service..."
sudo systemctl enable mysqld
sudo systemctl start mysqld

# Wait to ensure MySQL is running
echo "[DB] Waiting for MySQL to fully start..."
sleep 10

# Extract temporary password if available
echo "[DB] Extracting temporary root password (if any)..."
TEMP_PASS=$(sudo journalctl -u mysqld --no-pager | grep 'temporary password' | awk '{print $NF}' | tail -n 1)

if [ -n "$TEMP_PASS" ]; then
  echo "[DB] Securing MySQL root account using temporary password..."
  sudo mysql --connect-expired-password -uroot -p"$TEMP_PASS" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASS';
UNINSTALL COMPONENT IF EXISTS 'file://component_validate_password';
FLUSH PRIVILEGES;
EOF
else
  echo "[WARN] No temporary root password found. MySQL may already be configured."
  echo "[INFO] Attempting to continue using configured root password or socket access."
fi

# Try password-based login; if it fails, fall back to socket
echo "[DB] Checking root password login..."
if sudo mysql -uroot -p"$DB_PASS" -e "SELECT 1;" 2>/dev/null; then
  echo "[DB] Password-based root login successful."
  ROOT_MYSQL_CMD="sudo mysql -uroot -p$DB_PASS"
else
  echo "[WARN] Password login failed. Falling back to socket authentication..."
  ROOT_MYSQL_CMD="sudo mysql"
fi

# Create database and app user if not exists
DB_EXISTS=$($ROOT_MYSQL_CMD -e "SHOW DATABASES LIKE '$DB_NAME';" 2>/dev/null | grep "$DB_NAME" || true)

if [ -z "$DB_EXISTS" ]; then
  echo "[DB] Creating database '$DB_NAME' and user '$DB_USER'@'$WEB_IP'..."
  $ROOT_MYSQL_CMD <<EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'$WEB_IP' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$WEB_IP';
FLUSH PRIVILEGES;
EOF
else
  echo "[DB] Database '$DB_NAME' already exists. Skipping creation."
fi

# Import schema
if [ -f "$CREATE_SQL" ]; then
  echo "[DB] Importing schema from $CREATE_SQL..."
  $ROOT_MYSQL_CMD $DB_NAME < "$CREATE_SQL"
else
  echo "[WARN] Schema file $CREATE_SQL not found!"
fi

# Import demo data
if [ -f "$INSERT_SQL" ]; then
  echo "[DB] Importing data from $INSERT_SQL..."
  $ROOT_MYSQL_CMD $DB_NAME < "$INSERT_SQL"
else
  echo "[WARN] Data file $INSERT_SQL not found!"
fi

echo "[✅ DB] MySQL provisioning completed successfully."
echo "[INFO] MySQL root/user password: $DB_PASS"
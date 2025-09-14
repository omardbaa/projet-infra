Vagrant.configure("2") do |config|
  # Constants
  WEB_IP         = "192.168.56.10"
  DB_IP          = "192.168.56.20"
  DB_PORT        = 3307
  WEBSITE_REPO   = "https://github.com/omardbaa/simple-web-app.git"

  LOGS_DIR       = "./website/logs"
  SCRIPTS_FOLDER = "./scripts"
  DB_FOLDER      = "./database"

  # === ENV VARS to pass into provision scripts ===
  ENV['MYSQL_PASSWORD'] = "MyS3cur3P@ssw0rd"
  ENV['DB_NAME'] = "demo_db"
  ENV['DB_USER'] = "webuser"
  ENV['WEB_IP'] = WEB_IP

  # === RUN HOST SCRIPT BEFORE VM SETUP ===
  system("bash pre-provision.sh")

  # Web Server
  config.vm.define "web-server" do |web|
    web.vm.box = "ubuntu/jammy64"
    web.vm.hostname = "web-server"

    web.vm.network "public_network"
    web.vm.network "private_network", ip: WEB_IP

    web.vm.synced_folder "./website", "/var/www/html", create: true, type: "rsync"
    web.vm.synced_folder LOGS_DIR, "/var/www/logs", type: "rsync", rsync__auto: true
    web.vm.synced_folder SCRIPTS_FOLDER, "/home/vagrant/scripts", type: "rsync"

    web.vm.provision "shell", path: "scripts/provision-web-ubuntu.sh"
  end

  # DB Server
  config.vm.define "db-server" do |db|
    db.vm.box = "centos/stream9"
    db.vm.hostname = "db-server"

    db.vm.network "private_network", ip: DB_IP
    db.vm.network "forwarded_port", guest: 3306, host: DB_PORT

    db.vm.synced_folder DB_FOLDER, "/vagrant/database", type: "rsync"
    db.vm.synced_folder SCRIPTS_FOLDER, "/home/vagrant/scripts", type: "rsync"

    db.vm.provision "shell", path: "scripts/provision-db-centos.sh"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 1
  end
end

<div align="center">
  <h1>🚀 Multi-Machine Infrastructure with Vagrant</h1>
  <p>
    <img src="https://img.shields.io/badge/Vagrant-2.2+-blue?logo=vagrant" alt="Vagrant Version" />
    <img src="https://img.shields.io/badge/Ubuntu%20Web%20Server-bionic64-brightgreen?logo=ubuntu" alt="Ubuntu" />
    <img src="https://img.shields.io/badge/CentOS%20DB%20Server-stream9-orange?logo=centos" alt="CentOS" />
    <img src="https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql" alt="MySQL" />
    <img src="https://img.shields.io/badge/Automated-Provisioning-success?logo=automation" alt="Provisioning" />
  </p>
</div>

---

<details>
<summary><strong>📚 Table of Contents</strong></summary>

1. <a href="#1-🎯-project-goals">🎯 Project Goals</a>
2. <a href="#2-🧱-infrastructure-architecture">🧱 Infrastructure Architecture</a>
3. <a href="#3-📁-project-structure">📁 Project Structure</a>
4. <a href="#4-⚙️-vagrantfile-configuration">⚙️ Vagrantfile Configuration</a>
5. <a href="#5-🔧-automated-provisioning">🔧 Automated Provisioning</a>
6. <a href="#6-🌐-networking--access">🌐 Networking & Access</a>
7. <a href="#7-🧪-testing--validation">🧪 Testing & Validation</a>
8. <a href="#8-📦-distribution-via-vagrant-cloud">📦 Distribution via Vagrant Cloud</a>
9. <a href="#9-💡-usage-examples">💡 Usage Examples</a>
10. <a href="#9-1--advanced-usage--tips">9.1 Advanced Usage & Tips</a>
11. <a href="#10-❓-faq--troubleshooting">❓ FAQ & Troubleshooting</a>
12. <a href="#11-👤-author--references">👤 Author & References</a>

</details>

---

## 1. 🎯 Project Goals

<ul>
  <li>Automatically deploy an infrastructure composed of <b>2 virtual machines</b>:</li>
  <ul>
    <li>A <b>web server</b> running <b>Ubuntu</b> with <b>Nginx</b> and a <b>static site cloned from GitHub</b></li>
    <li>A <b>database server</b> running <b>CentOS</b> with <b>MySQL 8.0</b> and a <code>demo_db</code> database</li>
  </ul>
  <li>Provide a packaged and reusable infrastructure via <b>Vagrant Cloud</b></li>
</ul>

---

## 2. 🧱 Infrastructure Architecture

<div align="center">

```mermaid
flowchart LR
    A[USER] -- Public Network (192.168.1.0/24) --> B[WEB SERVER (Ubuntu)]
    B -- Private Network (192.168.56.0/24) --> C[DATABASE (CentOS)]
    C -- Port 3307 (host) --> D[Physical Machine]
```

</div>

---

## 3. 📁 Project Structure

```text
project-infra-simple/
├── Vagrantfile
├── scripts/
│   ├── provision-web-ubuntu.sh
│   └── provision-db-centos.sh
├── website/
│   └── (site cloned from GitHub)
├── database/
│   ├── create-table.sql
│   └── insert-demo-data.sql
└── README.md
```

---

## 4. ⚙️ Vagrantfile Configuration

```ruby
Vagrant.configure("2") do |config|
  # Web Server (Ubuntu)
  config.vm.define "web-server" do |web|
    web.vm.box = "ubuntu/bionic64"
    web.vm.hostname = "web-server"
    web.vm.network "public_network"
    web.vm.network "private_network", ip: "192.168.56.10"
    web.vm.synced_folder "./website", "/var/www/html"
    web.vm.provision "shell", path: "scripts/provision-web-ubuntu.sh"
  end

  # Database Server (CentOS)
  config.vm.define "db-server" do |db|
    db.vm.box = "centos/stream9"
    db.vm.hostname = "db-server"
    db.vm.network "private_network", ip: "192.168.56.20"
    db.vm.network "forwarded_port", guest: 3306, host: 3307
    db.vm.provision "shell", path: "scripts/provision-db-centos.sh"
  end
end
```

---

## 5. 🔧 Automated Provisioning

<table>
  <tr>
    <th>Script</th>
    <th>Actions</th>
  </tr>
  <tr>
    <td><code>scripts/provision-web-ubuntu.sh</code></td>
    <td>
      <ul>
        <li>Installs <b>Nginx</b></li>
        <li>Clones a <b>GitHub</b> repository containing a static site</li>
        <li>Copies the site to <code>/var/www/html</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>scripts/provision-db-centos.sh</code></td>
    <td>
      <ul>
        <li>Installs <b>MySQL 8.0</b></li>
        <li>Creates a <code>demo_db</code> database and a <code>users</code> table</li>
        <li>Inserts test data via:
          <ul>
            <li><code>database/create-table.sql</code></li>
            <li><code>database/insert-demo-data.sql</code></li>
          </ul>
        </li>
      </ul>
    </td>
  </tr>
</table>

---

## 6. 🌐 Networking & Access

<table>
  <tr>
    <th>Machine</th>
    <th>Private IP</th>
    <th>Public IP</th>
    <th>Port Forwarding</th>
    <th>Access</th>
  </tr>
  <tr>
    <td><code>web-server</code></td>
    <td>192.168.56.10</td>
    <td>Automatic DHCP</td>
    <td>-</td>
    <td>Browser, SSH</td>
  </tr>
  <tr>
    <td><code>db-server</code></td>
    <td>192.168.56.20</td>
    <td>-</td>
    <td>3307 (host) → 3306</td>
    <td>MySQL via <code>localhost:3307</code></td>
  </tr>
</table>

---

## 7. 🧪 Testing & Validation

<ul>
  <li>✅ <code>vagrant up</code> starts both VMs without error</li>
  <li>✅ The website is accessible via the public IP of <code>web-server</code></li>
  <li>✅ MySQL connection possible via <code>mysql -h 127.0.0.1 -P 3307</code></li>
  <li>✅ Test data is present in <code>users</code></li>
  <li>✅ No manual intervention needed thanks to provisioning</li>
</ul>

---

## 8. 📦 Distribution via Vagrant Cloud

### 🔹 Clean up the machines

```bash
vagrant ssh web-server
sudo apt clean && sudo rm -rf /var/log/*
exit
```

### 🔹 Package the boxes
```bash
vagrant package web-server --output ubuntu-web.box
vagrant package db-server --output centos-db.box
```

### 🔹 Publish on Vagrant Cloud

1. Create an account: <a href="https://app.vagrantup.com/" target="_blank">https://app.vagrantup.com/</a>
2. Upload your <code>.box</code> files
3. Fill in the metadata:
   - Name: <code>username/ubuntu-web-server</code>
   - Name: <code>username/centos-mysql-db</code>
   - OS, version, description

### 🔹 Test the box on another machine
```bash
vagrant init username/ubuntu-web-server
vagrant up
```

---

## 8.1 📦 Official Vagrant Cloud Boxes

<table>
  <tr>
    <th>Box Name</th>
    <th>Description</th>
    <th>Version</th>
    <th>Visibility</th>
    <th>Version Description</th>
    <th>Link</th>
  </tr>
  <tr>
    <td><code>omardbaa-simplon-t4s-devops/ubuntu-web-server</code></td>
    <td>Preconfigured Ubuntu 22.04 LTS web server with Nginx for a deployed CRUD web app</td>
    <td>1.0.0</td>
    <td>Public</td>
    <td>Initial release (v1.0.0) of the Ubuntu web server box. Includes Ubuntu 22.04 LTS with Nginx</td>
    <td><a href="https://app.vagrantup.com/omardbaa-simplon-t4s-devops/boxes/ubuntu-web-server" target="_blank">View on Vagrant Cloud</a></td>
  </tr>
  <tr>
    <td><code>omardbaa-simplon-t4s-devops/centos-mysql-db</code></td>
    <td>MySQL server running on CentOS 9, configured via Vagrant for quick deployment.</td>
    <td>1.0.0</td>
    <td>Public</td>
    <td>Initial release (v1.0.0) of the CentOS 9 Stream MySQL server box. Includes MySQL 8.0 installed and secured.</td>
    <td><a href="https://app.vagrantup.com/omardbaa-simplon-t4s-devops/boxes/centos-mysql-db" target="_blank">View on Vagrant Cloud</a></td>
  </tr>
</table>

---

## 9. 💡 Usage Examples

🔸 <b>Quick Demo (Web)</b>
```bash
vagrant init username/ubuntu-web-server
vagrant up
```

🔸 <b>Connect to MySQL</b>
```bash
mysql -h 127.0.0.1 -P 3307 -u root -p
```

🔸 <b>Local Development</b>

Connect a web application to MySQL via <code>localhost:3307</code>

---

## 9.1 🔥 Advanced Usage & Tips

- <b>Customizing the Web App:</b> Edit files in <code>website/simple-web-app/</code> and reload Nginx or restart the VM to see changes.
- <b>Database Credentials:</b> Default MySQL user is <code>root</code> with password set during provisioning (see <code>provision-db-centos.sh</code> for details).
- <b>Logs:</b> Web server logs are in <code>website/logs/</code> (synced to <code>/var/www/html/logs/</code> in the VM). MySQL logs are in <code>/var/log/mysqld.log</code> inside the DB VM.
- <b>Backup/Restore:</b> Use <code>mysqldump</code> and <code>mysql</code> commands inside the DB VM for database backup and restore.
- <b>Updating Boxes:</b> Run <code>vagrant box update</code> to get the latest base images.
- <b>Recommended Plugins:</b> <code>vagrant-vbguest</code> (for VirtualBox Guest Additions), <code>vagrant-disksize</code> (for resizing disks).
- <b>Multi-VM Commands:</b> Use <code>vagrant status</code>, <code>vagrant halt</code>, <code>vagrant reload</code>, <code>vagrant destroy</code> to manage all VMs at once.
- <b>SSH Access:</b> <code>vagrant ssh web-server</code> or <code>vagrant ssh db-server</code> to access each VM.

---

## 10. ❓ FAQ & Troubleshooting

<details>
<summary>🧩 <b>The site does not display?</b></summary>

- Check Nginx:
  ```bash
  sudo systemctl status nginx
  sudo systemctl restart nginx
  ```
- Check the public IP:
  ```bash
  vagrant ssh web-server
  ip a
  ```
- Ensure the <code>website/</code> folder is synced and contains an <code>index.html</code>.
- Check firewall settings on your host and guest.
- Try <code>vagrant reload web-server --provision</code> to re-run provisioning.
</details>

<details>
<summary>🧩 <b>Cannot connect to MySQL?</b></summary>

- Test the connection:
  ```bash
  mysql -h 127.0.0.1 -P 3307 -u root -p
  ```
- Restart MySQL:
  ```bash
  sudo systemctl restart mysqld
  ```
- Check MySQL logs:
  ```bash
  sudo cat /var/log/mysqld.log
  ```
- Ensure port 3307 is not blocked by your host firewall.
- If port 3307 is in use, change the <code>Vagrantfile</code> to use another port (e.g., 3308).
</details>

<details>
<summary>🧩 <b>Provisioning fails or scripts do not complete?</b></summary>

- Check the output of <code>vagrant up</code> for errors.
- Ensure you have a stable internet connection (for package installs and git clone).
- Try <code>vagrant reload --provision</code> to re-run provisioning scripts.
- Make sure scripts are executable: <code>chmod +x scripts/*.sh</code>.
- On Windows, use Git Bash or WSL for better shell compatibility.
</details>

<details>
<summary>🧩 <b>SSH connection issues?</b></summary>

- Use <code>vagrant ssh web-server</code> or <code>vagrant ssh db-server</code>.
- If SSH fails, try <code>vagrant reload</code> or <code>vagrant halt && vagrant up</code>.
- Check your virtualization software (VirtualBox, VMware, etc.) is up to date.
</details>

<details>
<summary>🧩 <b>Networking issues (no internet in VM, can't access services)?</b></summary>

- Restart the VM: <code>vagrant reload</code>.
- Check your host's network adapter settings.
- Try switching between <code>public_network</code> and <code>private_network</code> in the <code>Vagrantfile</code>.
- Disable VPNs or firewalls that may block VM traffic.
</details>

<details>
<summary>🧩 <b>Windows-specific issues?</b></summary>

- Run your terminal as Administrator.
- Use forward slashes (<code>/</code>) in paths in the <code>Vagrantfile</code>.
- If file sync fails, check for OneDrive or antivirus interference.
- Use WSL or Git Bash for better shell script compatibility.
</details>

<details>
<summary>🧩 <b>How to reset everything?</b></summary>

- Destroy all VMs and start fresh:
  ```bash
  vagrant destroy -f
  vagrant up
  ```
- Remove old boxes if needed:
  ```bash
  vagrant box list
  vagrant box remove <box-name>
  ```
</details>

<details>
<summary>🧩 <b>Best practices for security and development?</b></summary>

- Change default passwords after first boot.
- Do not expose VMs to the public internet unless necessary.
- Use version control (git) for your <code>website/</code> and <code>database/</code> folders.
- Regularly backup your database and web files.
- Use <code>vagrant snapshot</code> to save VM states before major changes.
</details>

---

## 11. 👤 Author & References

<ul>
  <li><b>Author:</b> [Your Name]</li>
  <li><b>Project GitHub:</b> <a href="https://github.com/your-username/project-infra-simple" target="_blank">https://github.com/your-username/project-infra-simple</a></li>
</ul>

<details>
<summary>📦 <b>Vagrant Cloud Boxes</b></summary>

- Web Server: <a href="https://app.vagrantup.com/omardbaa-simplon-t4s-devops/boxes/ubuntu-web-server" target="_blank">omardbaa-simplon-t4s-devops/ubuntu-web-server</a>
  <br><small>Preconfigured Ubuntu 22.04 LTS web server with Nginx for a deployed CRUD web app (v1.0.0)</small>
- DB Server: <a href="https://app.vagrantup.com/omardbaa-simplon-t4s-devops/boxes/centos-mysql-db" target="_blank">omardbaa-simplon-t4s-devops/centos-mysql-db</a>
  <br><small>MySQL server running on CentOS 9, configured via Vagrant for quick deployment (v1.0.0)</small>

</details>

---

<sub>📝 Project provided for educational purposes. Reuse allowed with author attribution.</sub>

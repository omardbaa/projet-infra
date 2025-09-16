<div align="center">
  <h1>🚀 Infrastructure Multi-Machines avec Vagrant</h1>
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
<summary><strong>📚 Table des matières</strong></summary>

1. <a href="#1-🎯-objectifs-du-projet">🎯 Objectifs du Projet</a>
2. <a href="#2-🧱-architecture-de-linfrastructure">🧱 Architecture de l’Infrastructure</a>
3. <a href="#3-📁-structure-du-projet">📁 Structure du Projet</a>
4. <a href="#4-⚙️-configuration-du-vagrantfile">⚙️ Configuration du Vagrantfile</a>
5. <a href="#5-🔧-provisioning-automatisé">🔧 Provisioning Automatisé</a>
6. <a href="#6-🌐-réseaux-et-accès">🌐 Réseaux et Accès</a>
7. <a href="#7-🧪-tests--validation">🧪 Tests & Validation</a>
8. <a href="#8-📦-distribution-via-vagrant-cloud">📦 Distribution via Vagrant Cloud</a>
9. <a href="#9-💡-exemples-dutilisation">💡 Exemples d’Utilisation</a>
10. <a href="#10-❓-faq--dépannage">❓ FAQ & Dépannage</a>
11. <a href="#11-👤-auteur--références">👤 Auteur & Références</a>

</details>

---

## 1. 🎯 Objectifs du Projet

<ul>
  <li>Déployer automatiquement une infrastructure composée de <b>2 machines virtuelles</b> :</li>
  <ul>
    <li>Un <b>serveur web</b> sous <b>Ubuntu</b> avec <b>Nginx</b> et un <b>site statique cloné depuis GitHub</b></li>
    <li>Un <b>serveur base de données</b> sous <b>CentOS</b> avec <b>MySQL 8.0</b> et une base <code>demo_db</code></li>
  </ul>
  <li>Fournir une infrastructure packagée et réutilisable via <b>Vagrant Cloud</b></li>
</ul>

---

## 2. 🧱 Architecture de l’Infrastructure

<div align="center">

    ┌───────────────┐      🌐 Réseau Public (192.168.1.0/24)      ┌─────────────────┐
    │   🧑‍💻 UTILISATEUR   │ ────────────────────────────────────▶ │  🖥️ WEB SERVER  │
    │               │                                             │    (Ubuntu)      │
    └───────────────┘                                             └───────────┬─────┘
                                                                        │
                                                   🔐 Réseau Privé (192.168.56.0/24)
                                                                        │
                      🖧 Machine Physique  (Port 3307)                  │
                              ▲                                         │
                              └─────────────────────────────────────────┼─────────┐
                                                                        │         │
                                                                ┌───────▼───────┐
                                                                │  🗄️ DATABASE  │
                                                                │   (CentOS)    │
                                                                └───────────────┘




</div>

---

## 3. 📁 Structure du Projet

```text
projet-infra-simple/
├── Vagrantfile
├── scripts/
│   ├── provision-web-ubuntu.sh
│   └── provision-db-centos.sh
├── website/
│   └── (site cloné depuis GitHub)
├── database/
│   ├── create-table.sql
│   └── insert-demo-data.sql
└── README.md
```

---

## 4. ⚙️ Configuration du Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  # Machine Web Server (Ubuntu)
  config.vm.define "web-server" do |web|
    web.vm.box = "ubuntu/bionic64"
    web.vm.hostname = "web-server"
    web.vm.network "public_network"
    web.vm.network "private_network", ip: "192.168.56.10"
    web.vm.synced_folder "./website", "/var/www/html"
    web.vm.provision "shell", path: "scripts/provision-web-ubuntu.sh"
  end

  # Machine Database Server (CentOS)
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

## 5. 🔧 Provisioning Automatisé

<table>
  <tr>
    <th>Script</th>
    <th>Actions</th>
  </tr>
  <tr>
    <td><code>scripts/provision-web-ubuntu.sh</code></td>
    <td>
      <ul>
        <li>Installe <b>Nginx</b></li>
        <li>Clone un dépôt <b>GitHub</b> contenant un site statique</li>
        <li>Copie le site dans <code>/var/www/html</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>scripts/provision-db-centos.sh</code></td>
    <td>
      <ul>
        <li>Installe <b>MySQL 8.0</b></li>
        <li>Crée une base <code>demo_db</code> et une table <code>users</code></li>
        <li>Insère des données de test via :
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

## 6. 🌐 Réseaux et Accès

<table>
  <tr>
    <th>Machine</th>
    <th>IP Privée</th>
    <th>IP Publique</th>
    <th>Port Forwarding</th>
    <th>Accès</th>
  </tr>
  <tr>
    <td><code>web-server</code></td>
    <td>192.168.56.10</td>
    <td>DHCP automatique</td>
    <td>-</td>
    <td>Navigateur, SSH</td>
  </tr>
  <tr>
    <td><code>db-server</code></td>
    <td>192.168.56.20</td>
    <td>-</td>
    <td>3307 (hôte) → 3306</td>
    <td>MySQL via <code>localhost:3307</code></td>
  </tr>
</table>

---

## 7. 🧪 Tests & Validation

<ul>
  <li>✅ <code>vagrant up</code> démarre les deux VMs sans erreur</li>
  <li>✅ Le site web est accessible via l’IP publique de <code>web-server</code></li>
  <li>✅ Connexion MySQL possible via <code>mysql -h 127.0.0.1 -P 3307</code></li>
  <li>✅ Les données de test sont présentes dans <code>users</code></li>
  <li>✅ Aucun besoin d’intervention manuelle grâce au provisioning</li>
</ul>

---

## 8. 📦 Distribution via Vagrant Cloud

### 🔹 Nettoyage des machines

```bash
vagrant ssh web-server
sudo apt clean && sudo rm -rf /var/log/*
exit
```

### 🔹 Packager les boxes
```bash
vagrant package web-server --output ubuntu-web.box
vagrant package db-server --output centos-db.box
```

### 🔹 Publier sur Vagrant Cloud

1. Créez un compte : <a href="https://app.vagrantup.com/" target="_blank">https://app.vagrantup.com/</a>
2. Uploadez vos <code>.box</code>
3. Renseignez les métadonnées :
   - Nom : <code>username/ubuntu-web-server</code>
   - Nom : <code>username/centos-mysql-db</code>
   - OS, version, description

### 🔹 Tester la box sur un autre poste
```bash
vagrant init username/ubuntu-web-server
vagrant up
```

---

## 9. 💡 Exemples d’Utilisation

🔸 <b>Démo rapide (Web)</b>
```bash
vagrant init username/ubuntu-web-server
vagrant up
```

🔸 <b>Connexion à MySQL</b>
```bash
mysql -h 127.0.0.1 -P 3307 -u root -p
```

🔸 <b>Développement local</b>

Connecter une application web à MySQL via <code>localhost:3307</code>

---

## 9.1 🔥 Utilisation avancée & Astuces

- <b>Personnalisation du site web :</b> Modifiez les fichiers dans <code>website/simple-web-app/</code> et rechargez Nginx ou redémarrez la VM pour voir les changements.
- <b>Identifiants MySQL :</b> L'utilisateur par défaut est <code>root</code> avec le mot de passe défini dans <code>provision-db-centos.sh</code>.
- <b>Logs :</b> Les logs du serveur web sont dans <code>website/logs/</code> (synchro avec <code>/var/www/html/logs/</code> dans la VM). Les logs MySQL sont dans <code>/var/log/mysqld.log</code> dans la VM DB.
- <b>Sauvegarde/Restaurer :</b> Utilisez <code>mysqldump</code> et <code>mysql</code> dans la VM DB pour sauvegarder/restaurer la base.
- <b>Mise à jour des boxes :</b> <code>vagrant box update</code> pour obtenir les dernières images.
- <b>Plugins recommandés :</b> <code>vagrant-vbguest</code> (VirtualBox Guest Additions), <code>vagrant-disksize</code> (redimensionnement disque).
- <b>Commandes multi-VM :</b> <code>vagrant status</code>, <code>vagrant halt</code>, <code>vagrant reload</code>, <code>vagrant destroy</code> pour gérer toutes les VMs.
- <b>Accès SSH :</b> <code>vagrant ssh web-server</code> ou <code>vagrant ssh db-server</code>.

---

## 10. ❓ FAQ & Dépannage

<details>
<summary>🧩 <b>Le site ne s’affiche pas ?</b></summary>

- Vérifier Nginx :
  ```bash
  sudo systemctl status nginx
  sudo systemctl restart nginx
  ```
- Vérifier l’IP publique :
  ```bash
  vagrant ssh web-server
  ip a
  ```
- Vérifier que le dossier <code>website/</code> est bien synchronisé et contient un <code>index.html</code>.
- Vérifier les pare-feux sur l’hôte et la VM.
- Essayez <code>vagrant reload web-server --provision</code> pour relancer le provisioning.
</details>

<details>
<summary>🧩 <b>Impossible de se connecter à MySQL ?</b></summary>

- Tester la connexion :
  ```bash
  mysql -h 127.0.0.1 -P 3307 -u root -p
  ```
- Redémarrer MySQL :
  ```bash
  sudo systemctl restart mysqld
  ```
- Consulter les logs MySQL :
  ```bash
  sudo cat /var/log/mysqld.log
  ```
- Vérifier que le port 3307 n’est pas bloqué par le pare-feu de l’hôte.
- Si le port 3307 est déjà utilisé, modifiez le <code>Vagrantfile</code> (ex : 3308).
</details>

<details>
<summary>🧩 <b>Le provisioning échoue ou les scripts ne s’exécutent pas ?</b></summary>

- Vérifiez la sortie de <code>vagrant up</code> pour les erreurs.
- Assurez-vous d’avoir une connexion internet stable (pour apt/yum et git clone).
- Essayez <code>vagrant reload --provision</code> pour relancer les scripts.
- Rendez les scripts exécutables : <code>chmod +x scripts/*.sh</code>.
- Sous Windows, privilégiez Git Bash ou WSL pour une meilleure compatibilité shell.
</details>

<details>
<summary>🧩 <b>Problèmes de connexion SSH ?</b></summary>

- Utilisez <code>vagrant ssh web-server</code> ou <code>vagrant ssh db-server</code>.
- Si SSH échoue, essayez <code>vagrant reload</code> ou <code>vagrant halt && vagrant up</code>.
- Vérifiez que votre hyperviseur (VirtualBox, VMware, etc.) est à jour.
</details>

<details>
<summary>🧩 <b>Problèmes réseau (pas d’internet dans la VM, services inaccessibles) ?</b></summary>

- Redémarrez la VM : <code>vagrant reload</code>.
- Vérifiez la configuration réseau de l’hôte.
- Essayez d’alterner entre <code>public_network</code> et <code>private_network</code> dans le <code>Vagrantfile</code>.
- Désactivez VPN ou pare-feu qui pourraient bloquer le trafic.
</details>

<details>
<summary>🧩 <b>Problèmes spécifiques à Windows ?</b></summary>

- Lancez le terminal en mode administrateur.
- Utilisez des slashs (<code>/</code>) dans les chemins du <code>Vagrantfile</code>.
- Si la synchronisation échoue, vérifiez OneDrive ou l’antivirus.
- Privilégiez WSL ou Git Bash pour les scripts shell.
</details>

<details>
<summary>🧩 <b>Comment tout réinitialiser ?</b></summary>

- Détruire toutes les VMs et repartir de zéro :
  ```bash
  vagrant destroy -f
  vagrant up
  ```
- Supprimer les anciennes boxes si besoin :
  ```bash
  vagrant box list
  vagrant box remove <nom-box>
  ```
</details>

<details>
<summary>🧩 <b>Bonnes pratiques sécurité et développement ?</b></summary>

- Changez les mots de passe par défaut après le premier démarrage.
- N’exposez pas les VMs sur Internet sauf nécessité.
- Versionnez vos dossiers <code>website/</code> et <code>database/</code> avec git.
- Sauvegardez régulièrement la base et les fichiers web.
- Utilisez <code>vagrant snapshot</code> avant toute modification majeure.
</details>

---

## 11. 👤 Auteur & Références

<ul>
  <li><b>Auteur :</b> OMAR DBAA</li>
  <li><b>GitHub du projet :</b> <a href="https://github.com/omardbaa/projet-infra" target="_blank">https://github.com/omardbaa/projet-infra</a></li>
</ul>

<details>
<summary>📦 <b>Boxes Vagrant Cloud</b></summary>

- Web Server : <a href="https://app.vagrantup.com/username/ubuntu-web-server" target="_blank">https://app.vagrantup.com/username/ubuntu-web-server</a>
- DB Server : <a href="https://app.vagrantup.com/username/centos-mysql-db" target="_blank">https://app.vagrantup.com/username/centos-mysql-db</a>

</details>

---

<sub>📝 Projet fourni à des fins pédagogiques. Réutilisation autorisée avec mention de l’auteur.</sub>

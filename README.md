## 🛠 Xgrid DevOps/SRE: Workstation Setup (Native Ubuntu)

### 1. System Updates & Core Tools

**Purpose:** Ensure the OS is patched and essential utilities are available for downloading/extracting software.

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl unzip git wget gpg

```

### 2. Infrastructure & Automation Toolchain

**Purpose:** Install industry-standard SRE tools natively to avoid binary or pathing conflicts.

* **AWS CLI:** Manages cloud resources via terminal.
* **Terraform:** Infrastructure as Code (IaC) tool to provision AWS resources.
* **Docker:** Container engine to build and run microservices.

```bash
# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Terraform (Official HashiCorp Repo)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y

# Docker Engine
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER && newgrp docker # Run docker without sudo

```

### 3. Security: SSH Authentication

**Purpose:** Secure, password-less communication with GitHub.

```bash
ssh-keygen -t ed25519 -C "5abdulsami2004@gmail.com"
cat ~/.ssh/id_ed25519.pub
# Copy output to: GitHub Settings > SSH & GPG Keys > New SSH Key (Authentication)

```

### 4. Security: GPG Commit Signing

**Purpose:** Cryptographically sign every commit to prove code integrity and identity.

```bash
# Generate Key (RSA/4096)
gpg --full-generate-key

# Get Key ID (the 16 chars after 'rsa4096/')
gpg --list-secret-keys --keyid-format=LONG

# Export Public Key to GitHub
gpg --armor --export <YOUR_KEY_ID>
# Copy block to: GitHub Settings > SSH & GPG Keys > New GPG Key

# Link GPG to Git Global Config
git config --global user.signingkey <YOUR_KEY_ID>
git config --global commit.gpgsign true
git config --global user.email "5abdulsami2004@gmail.com"
git config --global user.name "Abdul Sami"

```

---

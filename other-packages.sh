#!/bin/bash
set -e

echo "===== Installing Trivy, Terraform, kubectl, AWS CLI, Helm ====="

# --------------------------------------------------
# Update system & install common dependencies
# --------------------------------------------------
sudo apt update -y
sudo apt install -y \
  wget \
  curl \
  gnupg \
  lsb-release \
  unzip \
  apt-transport-https

# --------------------------------------------------
# Install Trivy
# --------------------------------------------------
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb \
$(lsb_release -sc) main" | \
sudo tee /etc/apt/sources.list.d/trivy.list

sudo apt update -y
sudo apt install -y trivy

# --------------------------------------------------
# Install Terraform
# --------------------------------------------------
wget -O- https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update -y
sudo apt install -y terraform

# --------------------------------------------------
# Install kubectl
# --------------------------------------------------
curl -LO "https://dl.k8s.io/release/$(curl -L -s \
https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
kubectl version --client

# --------------------------------------------------
# Install AWS CLI v2
# --------------------------------------------------
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
-o awscliv2.zip

unzip awscliv2.zip
sudo .

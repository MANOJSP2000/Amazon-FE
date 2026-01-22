#!/bin/bash
set -e

echo "===== Starting DevOps Toolchain Installation ====="

# --------------------------------------------------
# Update system
# --------------------------------------------------
sudo apt-get update -y

# --------------------------------------------------
# Install common dependencies
# --------------------------------------------------
sudo apt-get install -y \
  ca-certificates \
  curl \
  wget \
  gnupg \
  lsb-release \
  unzip \
  apt-transport-https

# --------------------------------------------------
# Install Java 17 (Required for Jenkins)
# --------------------------------------------------
sudo apt-get install -y fontconfig openjdk-17-jre
java -version

# --------------------------------------------------
# Install Jenkins
# --------------------------------------------------
wget -q -O /usr/share/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# --------------------------------------------------
# Install Docker
# --------------------------------------------------
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y \
docker-ce docker-ce-cli containerd.io \
docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

# Docker permissions
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# --------------------------------------------------
# Install Trivy
# --------------------------------------------------
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb \
$(lsb_release -sc) main" | \
sudo tee /etc/apt/sources.list.d/trivy.list

sudo apt-get update -y
sudo apt-get install -y trivy

# --------------------------------------------------
# Install Terraform
# --------------------------------------------------
wget -O- https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update -y
sudo apt-get install -y terraform

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
sudo ./aws/install
rm -rf aws awscliv2.zip

# --------------------------------------------------
# Install Helm 3
# --------------------------------------------------
curl -fsSL -o get_helm.sh \
https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

chmod +x get_helm.sh
./get_helm.sh
rm get_helm.sh

echo "===== Installation Completed Successfully ====="

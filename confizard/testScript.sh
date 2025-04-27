#!/bin/bash
export PROXMOX_DOMAIN="proxmox-1.example.com"
export PROXMOX_USER="root@pam"
export PROXMOX_PASSWORD="SENSITIVE"
export PROXMOX_SSH_DOMAIN="proxmox-1.example.com"
export PROXMOX_SSH_USER="root"
export PROXMOX_SSH_PASSWORD="SENSITIVE"

echo 'Welcome to Confizard!'


set -e
# 1. Clone the repository
git clone https://gitlab.com/HJHPio/OKD-Proxmox-IaC.git
cd OKD-Proxmox-IaC

# 2. Build the Docker image
cd confizard
docker build -t proxmox-okd-deployer .

cd ..
# 3. Run the container with repo mounted
docker run --rm -it \
  -v "$(pwd)":/runtime \
  -e GENERATE_KEYS="${GENERATE_KEYS:-true}" \
  -e TF_VAR_pm_url="https://${PROXMOX_DOMAIN}/api2/json" \
  -e TF_VAR_pm_bpg_url="https://${PROXMOX_DOMAIN}" \
  -e TF_VAR_pm_user="${PROXMOX_USER}" \
  -e TF_VAR_pm_password="${PROXMOX_PASSWORD}" \
  -e TF_VAR_pm_ssh_url="${PROXMOX_SSH_DOMAIN}" \
  -e TF_VAR_pm_ssh_user="${PROXMOX_SSH_USER}" \
  -e TF_VAR_pm_ssh_password="${PROXMOX_SSH_PASSWORD}" \
  proxmox-okd-deployer


echo 'Confizard setup script completed successfully.'
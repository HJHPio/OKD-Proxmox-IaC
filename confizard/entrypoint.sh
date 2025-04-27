#!/bin/bash
set -e

echo "Starting OKD on Proxmox automated deployment process..."

if [[ "$GENERATE_KEYS" == "true" ]]; then
  echo "Generating SSH keys..."
  mkdir -p /runtime/infrastructure/terraform/ansible/files/secrets
  mkdir -p ~/.ssh
  ssh-keygen -t ed25519 -f /runtime/infrastructure/terraform/ansible/files/secrets/ssh-priv-key.key -N ''
  cat /runtime/infrastructure/terraform/ansible/files/secrets/ssh-priv-key.key.pub > /runtime/infrastructure/terraform/ansible/files/secrets/ssh-pub-keys.key
  cp /runtime/infrastructure/terraform/ansible/files/secrets/ssh-priv-key.key ~/.ssh/id_ed25519
  cp /runtime/infrastructure/terraform/ansible/files/secrets/ssh-priv-key.key.pub ~/.ssh/id_ed25519.pub
  echo "SSH keys successfully generated and copied to ~/.ssh/."
else
  echo "SSH key generation skipped (GENERATE_KEYS=$GENERATE_KEYS)"
fi

echo "Adding Proxmox host (${TF_VAR_pm_ssh_url}) to known_hosts..."
SCAN_SUCCESS=false
for i in {1..5}; do
    if ssh-keyscan -H "${TF_VAR_pm_ssh_url}" >> ~/.ssh/known_hosts 2>/dev/null; then
        SCAN_SUCCESS=true
        echo "Successfully added Proxmox host to known_hosts."
        break
    else
        echo "ssh-keyscan failed, retrying in 5 seconds..."
        sleep 5
    fi
done

if [[ "$SCAN_SUCCESS" != "true" ]]; then
    echo "ERROR: Failed to add Proxmox host to known_hosts after multiple attempts."
    exit 1
fi

echo "Propagating SSH public key to Proxmox (${TF_VAR_pm_ssh_url}) authorized_keys..."
sshpass -p "${TF_VAR_pm_ssh_password}" ssh-copy-id -o StrictHostKeyChecking=no "${TF_VAR_pm_ssh_user}@${TF_VAR_pm_ssh_url}"
echo "SSH public key successfully propagated."


echo "Initiating tofu deployment..."
cd /runtime/infrastructure/terraform

echo "Running tofu init..."
tofu init

echo "Running tofu plan..."
tofu plan -out=init.tfplan

echo "Applying planned infrastructure..."
tofu apply "init.tfplan"

echo "OKD deployment completed successfully."

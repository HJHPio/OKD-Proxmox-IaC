terraform {
  required_version = ">= 0.14"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc3"
    }
    ct      = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }
    bpg-proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.2"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure       = var.pm_tls_skip_verify
  pm_api_url            = var.pm_url
  pm_password           = var.pm_password
  pm_user               = var.pm_user
  # (possible extension) TODO: Use api token after FCOS update to avoid using kvm arguments field that require root
  # pm_api_token_id       = var.pm_api_token_id
  # pm_api_token_secret   = var.pm_api_token_secret
}

provider "bpg-proxmox" {
  endpoint = var.pm_bpg_url

  username = var.pm_user
  password = var.pm_password

  insecure = true

  ssh {
    agent = true
  }
}

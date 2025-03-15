terraform {
  required_version = ">= 0.14"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">=3.0.1-rc3"
    }
    ct      = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }
  }
}
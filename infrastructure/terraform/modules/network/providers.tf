terraform {
  required_version = ">= 0.14"
  required_providers {
    bpg-proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.2"
    }
  }
}

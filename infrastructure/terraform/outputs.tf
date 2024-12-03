output "proxmox_vm_manager_names_and_ids" {
  description = "The Names and IDs of the created manager VMs"
  value = module.proxmox.proxmox_vm_manager_names_and_ids
}

# output "proxmox_vm_primary_names_and_ids" {
#   description = "The Names and IDs of the created primary VMs"
#   value = module.proxmox.proxmox_vm_primary_names_and_ids
# }

# output "proxmox_vm_compute_names_and_ids" {
#   description = "The Names and IDs of the created compute VMs"
#   value = module.proxmox.proxmox_vm_compute_names_and_ids
# }

output "bootstrap_customized_ignition" {
  value = module.proxmox.bootstrap_customized_ignition
}

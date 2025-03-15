##########################
# Examples for debugging #
##########################

# output "proxmox_vm_manager_names_and_ids" {
#   value = { for vm in proxmox_vm_qemu.cloudinit-okd-manager : vm.id => vm.name }
# }

# output "bootstrap_customized_ignition" {
#   value = [
#     data.ct_config.bootstrap_customized_ignition[0].rendered
#   ]
# }
# output "primary_customized_ignition" {
#   value = [
#     for i in range(0, 3) : data.ct_config.primary_customized_ignition[i].rendered
#   ]
# }

# output "proxmox_vm_bootstrap_names_and_ids" {
#   value = { for vm in proxmox_vm_qemu.cloudinit-okd-bootstrap : vm.id => vm.name }
# }

# output "proxmox_vm_primary_names_and_ids" {
#   value = { for vm in proxmox_vm_qemu.cloudinit-okd-primary : vm.id => vm.name }
# }

# output "proxmox_vm_compute_names_and_ids" {
#   value = { for vm in proxmox_vm_qemu.cloudinit-okd-compute : vm.id => vm.name }
# }

# output "primary_customized_ignition" {
#   value = data.ct_config.primary_customized_ignition.rendered
# }

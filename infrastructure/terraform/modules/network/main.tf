# Use VLAN if main router (proxmox network source) supports it
# resource "proxmox_virtual_environment_network_linux_vlan" "vlan1962" {
#   provider    = bpg-proxmox
#   comment     = "linked to internet"
#   node_name   = var.proxmox_node_name

#   name        = "eno1.1962"
#   interface   = "eno1"
#   vlan        = 1962

#   autostart   = true
# }

# resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1962" {
#   provider    = bpg-proxmox
#   depends_on  = [
#     proxmox_virtual_environment_network_linux_vlan.vlan1962
#   ]
#   comment     = "linked to vlan with internet"
#   count       = 1
#   node_name   = var.proxmox_node_name
  
#   name        = "vmbr1962"

#   ports       = [
#     "eno1.1962"
#   ]
#   vlan_aware  = true
# }

# Create separate LAN for OKD internal network
resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1056" {
  provider    = bpg-proxmox
  comment     = "OKD internal network"
  count       = 1
  node_name   = var.proxmox_node_name

  name        = var.okd_internal_bridge
  address     = "10.56.0.2/16"

  ports       = []
  vlan_aware  = false
}

# Create separate pfSync interface for OKD internal network
resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1111" {
  provider    = bpg-proxmox
  comment     = "OPNsense pfSync interface"
  count       = 1
  node_name   = var.proxmox_node_name

  name        = "vmbr1111"
  address     = "11.11.0.3/16"

  ports       = []
  vlan_aware  = false
}

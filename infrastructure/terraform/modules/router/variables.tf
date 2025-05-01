#################################################
#           Proxmox SSH Connection              #
#################################################
variable "pm_ssh_url" {
  description = "The Proxmox host IP address"
  type        = string
}

variable "pm_ssh_user" {
  description = "The user to SSH into Proxmox"
  type        = string
}

variable "pm_ssh_password" {
  description = "The password for SSH user"
  type        = string
  sensitive   = true
}
#################################################

#################################################
#               VM Commons                      #
#################################################
variable "okd_net_ip_addresses_prefix" {
  description = "The prefix for the IP addresses in your internal network (first 3 octets)"
  type        = string
}

variable "vm_storage_name" {
  description = "The name of the storage where the VM templates will be stored"
  type        = string
}

variable "proxmox_node_name" {
  description = "The name of the node where the VM will be deployed"
  type        = string
}

variable "okd_internal_bridge" {
  description = "The name of proxmox bridge used for internal communication"
  type        = string
}
#################################################

#################################################
#               Router VM                       #
#################################################
variable "router_template_id" {
  description = "The router VM template ID"
  type        = string
}

variable "router_template_name" {
  description = "The router VM template name"
  type        = string
}
#################################################

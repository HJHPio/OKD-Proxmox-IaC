variable "proxmox_node_name" {
  description = "The name of the node where the VM will be deployed"
  type        = string
}

variable "okd_internal_bridge" {
  description = "The name of proxmox bridge used for internal communication"
  type        = string
}

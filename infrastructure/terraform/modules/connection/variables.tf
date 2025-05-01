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
variable "okd_admin_vm_ip_suffix" {
  description = "The suffix for the IP address in your internal network for administrator vm (last octet)"
  type        = string
}
variable "okd_net_ip_addresses_prefix" {
  description = "The prefix for the IP addresses in your internal network (first 3 octets)"
  type        = string
}

variable "okd_net_gateway" {
  description = "The gateway IP address for your internal OKD network"
  type        = string
}

variable "okd_net_mask" {
  description = "The subnet mask for your internal network (in CIDR notation)"
  type        = string
}

variable "vm_storage_name" {
  description = "The name of the storage where the VM disks will be stored"
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
#               CentOS VM                       #
#################################################
variable "centos_template_id" {
  description = "The CentOS VM template ID"
  type        = string
}
variable "centos_template_name" {
  description = "The CentOS VM template name"
  type        = string
}

variable "centos_template_user" {
  description = "The user for the CentOS VM template"
  type        = string
}

variable "centos_template_password" {
  description = "The password for the CentOS VM template"
  type        = string
  # For debugging puprose sensitive is false
  # Since in logs its <hidden> by default - this option can be left by default
  # sensitive   = true
}
#################################################

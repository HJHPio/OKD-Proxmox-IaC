variable "nfs_user" {
  description = "Username for nfs vm"
  type        = string
}

variable "nfs_pass" {
  description = "Password for nfs vm"
  type        = string
}

variable "okd_net_nfs_ip_suffix" {
  description = "The suffix for the IP address in your internal network for nfs vm (last octet)"
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

variable "primary_ips_str" {
  type = string
  description = "List of primary IP addresses ',' separated"
}

variable "compute_ips_str" {
  type = string
  description = "List of compute IP addresses ',' separated"
}

variable "nfs_path" {
  description = "Path to NFS export dir"
  type        = string
}
variable "centos_template_name" {
  description = "The CentOS VM template name"
  type        = string
}

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

variable "pacemaker_cluster_pass" {
  description = "Password for pacemaker cluster configs"
  type        = string
}
#################################################


#################################################
#             IPs                               #
#################################################
variable "okd_net_ip_main_prefix" {
  description = "The prefix for the IP addresses in your internal network (first 2 octets)"
  type        = string
}
variable "okd_net_ip_lb_infix" {
  description = "The infix for the IP addresses (for lb) in your internal network (inner 1 octet)"
  type        = string
}
variable "okd_net_ip_lb_vip_suffix" {
  description = "The suffix for the VIP address (for lb) in your internal network (last octet)"
  type        = string
}
variable "okd_net_ip_nfs_infix" {
  description = "The infix for the IP addresses (for nfs) in your internal network (inner 1 octet)"
  type        = string
}
# Generated in runtime 
variable "lb_vip" {
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
#################################################

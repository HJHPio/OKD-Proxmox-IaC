variable "nfs_user" {
  description = "Username for nfs vm"
  type        = string
  default     = "okduser"
}

variable "nfs_pass" {
  description = "Password for nfs vm"
  type        = string
}

variable "okd_net_nfs_ip_suffix" {
  description = "The suffix for the IP address in your internal network for nfs vm (last octet)"
  type        = string
  default     = "243"
}
variable "okd_net_ip_addresses_prefix" {
  description = "The prefix for the IP addresses in your internal network (first 3 octets)"
  type        = string
  default     = "192.168.1"
}

variable "okd_net_gateway" {
  description = "The gateway IP address for your internal OKD network"
  type        = string
  default     = "192.168.1.1"
}

variable "okd_net_mask" {
  description = "The subnet mask for your internal network (in CIDR notation)"
  type        = string
  default     = "24"
}

variable "primary_ips_str" {
  type = string
  description = "List of primary IP addresses ',' separated"
}

variable "compute_ips_str" {
  type = string
  description = "List of compute IP addresses ',' separated"
}

variable "okd_net_manager_ip_suffix" {
  description = "The suffix for the IP address in your internal network for manager node (last octet)"
  type        = string
  default     = "241"
}

variable "nfs_path" {
  description = "Path to NFS export dir"
  type        = string
  default     = "/data/nfs"
}
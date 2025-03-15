variable "pm_tls_skip_verify" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
  default     = true
}

variable "pm_url" {
  description = "The URL of the Proxmox API"
  type        = string
}

variable "pm_api_token_id" {
  description = "Token Id for Proxmox API"
  type        = string
}

variable "pm_api_token_secret" {
  description = "The API token secret for Proxmox API"
  type        = string
  sensitive   = true
}

variable "okd_version" {
  description = "The version of OKD to install"
  type        = string
  default     = "2.36.0"
}

variable "custom_dns" {
  description = "Your custom dns IP address"
  type        = string
  default     = ""
}

variable "okd_net_manager_ip_suffix" {
  description = "The suffix for the IP address in your internal network for manager node (last octet)"
  type        = string
  default     = "241"
}

variable "okd_net_bootstrap_ip_suffix" {
  description = "The suffix for the IP address in your internal network for bootstrap node (last octet)"
  type        = string
  default     = "242"
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

variable "manager_user" {
  description = "Username for manager node"
  type        = string
  default     = "okduser"
}

variable "manager_pass" {
  description = "Password for manager node"
  type        = string
}

variable "primary_count" {
  description = "Number of primary VMs to create"
  type        = number
  default     = 3  
}

variable "compute_count" {
  description = "Number of compute VMs to create"
  type        = number
  default     = 3  
}

variable "ssh_admin_pass_hash" {
  description = "Hash of admin password"
  type        = string
  # default to password "fedora"
  default     = "$6$kJ6aAOxhrAPCSVXF$.UkFx4VQst2Sm7aZnY0PO1a0Y4kp1OLYCEiykvVUwUaIgGF.2xcMYfCixZ6pzKapEu522.v8JoLAQKCrWc6Hq1"
}

variable "okd_fcos_version" {
  description = "Version of fcos to wait for rebase"
  type        = string
  default     = "39.20240210.3.0"
}

variable "okd_fcos_digest" {
  description = "Digest of fcos version"
  type        = string
  default     = "ostree-unverified-registry:quay.io/openshift/okd-content@sha256:eb85d903c52970e2d6823d92c880b20609d8e8e0dbc5ad27e16681ff444c8c83"
}

variable "compute_initial_ip_suffix" {
  type        = number
  description = "Initial IP suffix for compute nodes"
  default     = 220
}

variable "primary_initial_ip_suffix" {
  type        = number
  description = "Initial IP suffix for primary nodes"
  default     = 230
}

variable "bootstrap_node_state" {
  type        = string
  description = "Bootstrap vm node state"
  default     = "running"
}

variable "primary_ips_str" {
  type = string
  description = "List of primary IP addresses ',' separated"
}

variable "compute_ips_str" {
  type = string
  description = "List of compute IP addresses ',' separated"
}

variable "configure_nfs_provider" {
  description = "Configure NFS provider helm in OKD"
  type        = bool
  default     = true
}

variable "okd_net_nfs_ip_suffix" {
  description = "The suffix for the IP address in your internal network for nfs vm (last octet)"
  type        = string
  default     = "243"
}

variable "nfs_provider_version" {
  description = "Version of used NFS provider"
  type        = string
  default     = "4.0.18"
}

variable "nfs_path" {
  description = "Path to NFS export dir"
  type        = string
  default     = "/data/nfs"
}

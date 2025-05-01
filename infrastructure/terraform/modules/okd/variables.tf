variable "pm_tls_skip_verify" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
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
}

variable "custom_dns" {
  description = "Your custom dns IP address"
  type        = string
}

variable "okd_net_bootstrap_ip_suffix" {
  description = "The suffix for the IP address in your internal network for bootstrap node (last octet)"
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

variable "manager_user" {
  description = "Username for manager node"
  type        = string
}

variable "manager_pass" {
  description = "Password for manager node"
  type        = string
}

variable "primary_count" {
  description = "Number of primary VMs to create"
  type        = number
}

variable "compute_count" {
  description = "Number of compute VMs to create"
  type        = number
}

variable "ssh_admin_pass_hash" {
  description = "Hash of admin password"
  type        = string
}

variable "okd_fcos_version" {
  description = "Version of fcos to wait for rebase"
  type        = string
}

variable "okd_fcos_digest" {
  description = "Digest of fcos version"
  type        = string
}

variable "compute_initial_ip_suffix" {
  type        = number
  description = "Initial IP suffix for compute nodes"
}

variable "primary_initial_ip_suffix" {
  type        = number
  description = "Initial IP suffix for primary nodes"
}

variable "bootstrap_node_state" {
  type        = string
  description = "Bootstrap vm node state"
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
}

variable "okd_net_nfs_ip_suffix" {
  description = "The suffix for the IP address in your internal network for nfs vm (last octet)"
  type        = string
}

variable "nfs_provider_version" {
  description = "Version of used NFS provider"
  type        = string
}

variable "nfs_path" {
  description = "Path to NFS export dir"
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
#################################################

#################################################
#             Common                            #
#################################################
variable "okd_net_ip_main_prefix" {
  description = "The prefix for the IP addresses in your internal network (first 2 octets)"
  type        = string
}

variable "okd_default_node_disk_size" {
  description = "Default size of okd node disk"
  type        = string
}

variable "okd_cluster_subdomain" {
  description = "Subdomain for OKD cluster"
  type        = string
}

variable "okd_cluster_domain" {
  description = "Domain for OKD cluster"
  type        = string
}

variable "okd_cluster_prefix" {
  description = "Prefox for OKD cluster"
  type        = string
}

variable "pacemaker_cluster_pass" {
  description = "Password for pacemaker cluster configs"
  type        = string
}
#################################################

#################################################
#             Load Balancers                    #
#################################################
variable "okd_net_ip_lb_infix" {
  description = "The infix for the IP addresses (for lb) in your internal network (inner 1 octet)"
  type        = string
}
variable "okd_net_ip_lb_vip_suffix" {
  description = "The suffix for the VIP address (for lb) in your internal network (last octet)"
  type        = string
}
variable "okd_net_ip_lb_00ip_suffix" {
  description = "The suffix for the 00IP address (for lb) in your internal network (last octet)"
  type        = string
}
variable "okd_net_ip_lb_01ip_suffix" {
  description = "The suffix for the 01IP address (for lb) in your internal network (last octet)"
  type        = string
}

# Generated in runtime 
variable "lb_vip" {
  type        = string
}
variable "lb00_ip" {
  type        = string
}
variable "lb01_ip" {
  type        = string
}
variable "lb00_ipconfig" {
  type        = string
}
variable "lb01_ipconfig" {
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
variable "centos_template_name" {
  description = "The CentOS VM template name"
  type        = string
}
variable "centos_template_id" {
  description = "The CentOS VM template ID"
  type        = string
}
#################################################

#################################################
#                 SCOS VM                       #
#################################################
variable "scos_template_id" {
  description = "The SCOS VM template ID"
  type        = string
}
variable "scos_template_name" {
  description = "The SCOS VM template name"
  type        = string
}
#################################################

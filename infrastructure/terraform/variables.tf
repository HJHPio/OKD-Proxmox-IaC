variable "pm_tls_skip_verify" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
  default     = true
}

variable "pm_url" {
  description = "The URL of the Proxmox API"
  type        = string
}

variable "pm_user" {
  description = "Proxmox user"
  type        = string
  default     = "root"
}

variable "pm_password" {
  description = "Password for proxmox user"
  type        = string
  sensitive   = true
}

variable "pm_api_token_id" {
  description = "Token Id for Proxmox API"
  type        = string
  default     = "value"
}

variable "pm_api_token_secret" {
  description = "The API token secret for Proxmox API"
  type        = string
  sensitive   = true
  default     = "value"
}

variable "okd_version" {
  description = "The version of OKD to install"
  type        = string
  default     = "4.18.0-okd-scos.7"
}

variable "custom_dns" {
  description = "Your custom dns IP address"
  type        = string
  default     = ""
}

variable "okd_net_bootstrap_ip_suffix" {
  description = "The suffix for the IP address in your internal network for bootstrap node (last octet)"
  type        = string
  default     = "242"
}

variable "okd_net_nfs_ip_suffix" {
  description = "The suffix for the IP address in your internal network for nfs vm (last octet)"
  type        = string
  default     = "100"
}

variable "okd_net_ip_main_prefix" {
  description = "The prefix for the IP addresses in your internal network (first 2 octets)"
  type        = string
  default     = "10.56"
}

variable "okd_net_ip_nfs_infix" {
  description = "The infix for the IP addresses (for nfs) in your internal network (inner 1 octet)"
  type        = string
  default     = "2"
}

variable "okd_net_ip_lb_infix" {
  description = "The infix for the IP addresses (for lb) in your internal network (inner 1 octet)"
  type        = string
  default     = "1"
}

variable "okd_net_ip_lb_vip_suffix" {
  description = "The suffix for the VIP address (for lb) in your internal network (last octet)"
  type        = string
  default     = "1"
}
variable "okd_net_ip_lb_00ip_suffix" {
  description = "The suffix for the 00IP address (for lb) in your internal network (last octet)"
  type        = string
  default     = "2"
}
variable "okd_net_ip_lb_01ip_suffix" {
  description = "The suffix for the 01IP address (for lb) in your internal network (last octet)"
  type        = string
  default     = "3"
}

variable "okd_net_ip_addresses_prefix" {
  description = "The prefix for the IP addresses in your internal network (first 3 octets)"
  type        = string
  default     = "10.56.0"
}

variable "okd_net_gateway" {
  description = "The gateway IP address for your internal OKD network"
  type        = string
  default     = "10.56.0.1"
}

variable "okd_net_mask" {
  description = "The subnet mask for your internal network (in CIDR notation)"
  type        = string
  default     = "16" 
}

variable "manager_user" {
  description = "Username for manager node"
  type        = string
  default     = "core"
}

variable "manager_pass" {
  description = "Password for manager node"
  type        = string
  default     = "changemepass"
}

variable "nfs_user" {
  description = "Username for nfs vm"
  type        = string
  default     = "core"
}

variable "nfs_pass" {
  description = "Password for nfs vm"
  type        = string
  default     = "changemepass"
}

variable "ssh_admin_pass_hash" {
  description = "Hash of admin password"
  type        = string
  # default to password "changemepass" using: openssl passwd -6 'changemepass'
  default     = "$6$4d2uwT/M5C.AgXr.$sFxtZwZkIlRGdZUf/w3I7tk9I3s2NLQS9BY51tkiCFNdySVpbviNa9pPI1Y65IO4wKfeXtSsZ3zEILu2sWPaI1"
}

# OKD FCOS image versions with digest: https://quay.io/openshift/okd-content
variable "okd_fcos_version" {
  description = "Version of fcos to wait for rebase"
  type        = string
  default     = "418.9.202503240632-0"
}

variable "okd_fcos_digest" {
  description = "Digest of fcos version"
  type        = string
  default     = "ostree-unverified-registry:quay.io/okd/scos-release@sha256:83f3343f5fa6ef674fec8b4d4564680f17e7fe8aea4a42db7d58b1849a209469"
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

variable "configure_nfs_server" {
  description = "Configure NFS server module"
  type        = bool
  default     = true
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

#################################################
#               VM Templates                    #
#################################################
variable "create_vm_templates" {
  description = "Create VM Templates"
  type        = bool
  default     = true
}

variable "okd_admin_vm_ip_suffix" {
  description = "The suffix for the IP address in your internal network for coreos iso builder vm (last octet)"
  type        = string
  default     = "244"
}
#################################################

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
variable "vm_storage_name" {
  description = "The name of the storage where the VM disks will be stored"
  type        = string
  default     = "big-data"
}

variable "proxmox_node_name" {
  description = "The name of the node where the VM will be deployed"
  type        = string
  default     = "pve"
}

variable "okd_internal_bridge" {
  description = "The name of proxmox bridge used for internal communication"
  type        = string
  default     = "vmbr1056"
}

variable "okd_default_node_disk_size" {
  description = "Default size of okd node disk"
  type        = string
  default     = "50G"
}

variable "okd_cluster_subdomain" {
  description = "Subdomain for OKD cluster"
  type        = string
  default     = "ownlab-okd4"
}

variable "okd_cluster_domain" {
  description = "Domain for OKD cluster"
  type        = string
  default     = "own-cluster.lab"
}

variable "okd_cluster_prefix" {
  description = "Prefox for OKD cluster"
  type        = string
  default     = "okd4"
}

variable "pacemaker_cluster_pass" {
  description = "Password for pacemaker cluster configs"
  type        = string
  default     = "changemepass"
}
#################################################

#################################################
#               CentOS VM                       #
#################################################
variable "centos_image_file" {
  description = "The CentOS image file path"
  type        = string
  default     = "/var/lib/vz/template/iso/CentOS-Stream-GenericCloud-10-20250331.0.x86_64.qcow2"
}

variable "centos_image_url" {
  description = "The CentOS image download URL"
  type        = string
  default     = "https://cloud.centos.org/centos/10-stream/x86_64/images/CentOS-Stream-GenericCloud-10-20250331.0.x86_64.qcow2"
}

variable "centos_template_id" {
  description = "The CentOS VM template ID"
  type        = string
  default     = "56000"
}

variable "centos_template_name" {
  description = "The CentOS VM template name"
  type        = string
  default     = "CentOS-S10-CI-OKD" 
}

variable "centos_template_user" {
  description = "The user for the CentOS VM template"
  type        = string
  default     = "core"
}

variable "centos_template_password" {
  description = "The password for the CentOS VM template"
  type        = string
  default     = "changemepass"
  # For debugging puprose sensitive is false
  # Since in logs its <hidden> by default - this option can be left by default
  # sensitive   = true
}

variable "centos_additional_flags" {
  description = "Additional flags for the CentOS VM creation"
  type        = string
  default     = "--ssh-public-keys ~/proxmox-scripts/ssh-pub-keys.key"
}

variable "centos_skip_tpl_creation" {
  description = "Skip Centos Template VM creation"
  type        = bool
  default     = false
}
#################################################
 
#################################################
#               SCOS VM                         #
#################################################
variable "scos_image_file" {
  description = "The SCOS image file path"
  type        = string
  default     = "/var/lib/vz/template/iso/fedora-coreos-39.20231101.3.0-qemu.x86_64.qcow2.xz"
}

variable "scos_image_url" {
  description = "The SCOS image download URL"
  type        = string
  default     = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/39.20231101.3.0/x86_64/fedora-coreos-39.20231101.3.0-qemu.x86_64.qcow2.xz"
}

variable "scos_template_id" {
  description = "The SCOS VM template ID"
  type        = string
  default     = "57000"
}

variable "scos_template_name" {
  description = "The SCOS VM template name"
  type        = string
  default     = "CoreOS-OKD" 
}

variable "scos_additional_flags" {
  description = "Additional flags for the SCOS VM creation"
  type        = string
  default     = "--skip-cloud-init-settings --template-disk-size 16G"
}

variable "scos_skip_tpl_creation" {
  description = "Skip SCOS Template VM creation"
  type        = bool
  default     = false
}
#################################################

#################################################
#               Router VM                       #
#################################################
variable "router_image_file" {
  description = "The router image file path"
  type        = string
  default     = "/var/lib/vz/template/iso/OPNsense-25.1-nano-amd64.img.bz2"
}

variable "router_image_url" {
  description = "The router image download URL"
  type        = string
  default     = "https://mirror.dns-root.de/opnsense/releases/25.1/OPNsense-25.1-nano-amd64.img.bz2"
}

variable "router_template_id" {
  description = "The router VM template ID"
  type        = string
  default     = "55000"
}

variable "router_template_name" {
  description = "The router VM template name"
  type        = string
  default     = "OPNsense-Router-OKD" 
}

variable "router_additional_flags" {
  description = "Additional flags for the router VM creation"
  type        = string
  default     = "--skip-cloud-init-settings"
}

variable "router_skip_tpl_creation" {
  description = "Skip OPNsense Template VM creation"
  type        = bool
  default     = false
}
#################################################

variable "pm_bpg_url" {
  description = "The URL of the Proxmox"
  type        = string
}
variable "setup_network_interfaces" {
  description = "Setup proxmox network interfaces for vlans"
  type        = bool
  default     = true
}

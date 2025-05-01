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
  description = "The name of the storage where the VM templates will be stored"
  type        = string
}

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
#################################################

#################################################
#               CentOS VM                       #
#################################################
variable "centos_image_file" {
  description = "The CentOS image file path"
  type        = string
}

variable "centos_image_url" {
  description = "The CentOS image download URL"
  type        = string
}

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

variable "centos_additional_flags" {
  description = "Additional flags for the CentOS VM creation"
  type        = string
}

variable "centos_skip_tpl_creation" {
  description = "Skip Centos Template VM creation"
  type        = bool
}
#################################################

#################################################
#               SCOS VM                         #
#################################################
variable "scos_image_file" {
  description = "The SCOS image file path"
  type        = string
}

variable "scos_image_url" {
  description = "The SCOS image download URL"
  type        = string
}

variable "scos_template_id" {
  description = "The SCOS VM template ID"
  type        = string
}

variable "scos_template_name" {
  description = "The SCOS VM template name"
  type        = string
}

variable "scos_additional_flags" {
  description = "Additional flags for the SCOS VM creation"
  type        = string
}

variable "scos_skip_tpl_creation" {
  description = "Skip SCOS Template VM creation"
  type        = bool
}
#################################################

#################################################
#               Router VM                       #
#################################################
variable "router_image_file" {
  description = "The router image file path"
  type        = string
}

variable "router_image_url" {
  description = "The router image download URL"
  type        = string
}

variable "router_template_id" {
  description = "The router VM template ID"
  type        = string
}

variable "router_template_name" {
  description = "The router VM template name"
  type        = string
}

variable "router_additional_flags" {
  description = "Additional flags for the router VM creation"
  type        = string
}

variable "router_skip_tpl_creation" {
  description = "Skip OPNsense Template VM creation"
  type        = bool
}
#################################################

locals {
  primary_ips = [
    for i in range(var.primary_count) :
    format("%s.%d", var.okd_net_ip_addresses_prefix, var.primary_initial_ip_suffix + i)
  ]

  compute_ips = [
    for i in range(var.compute_count) :
    format("%s.%d", var.okd_net_ip_addresses_prefix, var.compute_initial_ip_suffix + i)
  ]

  PRIMARY_IPS_STR = join(", ", local.primary_ips)
  COMPUTE_IPS_STR = join(", ", local.compute_ips)

  lb_vip            = format(
    "%s.%s.%d",
    var.okd_net_ip_main_prefix,
    var.okd_net_ip_lb_infix,
    var.okd_net_ip_lb_vip_suffix
  )
  lb00_ip            = format(
    "%s.%s.%d",
    var.okd_net_ip_main_prefix,
    var.okd_net_ip_lb_infix,
    var.okd_net_ip_lb_00ip_suffix
  )
  lb01_ip            = format(
    "%s.%s.%d",
    var.okd_net_ip_main_prefix,
    var.okd_net_ip_lb_infix,
    var.okd_net_ip_lb_01ip_suffix
  )
  lb00_ipconfig       = format (
      "ip=${local.lb00_ip}/${var.okd_net_mask},gw=${var.okd_net_gateway}"
  )
  lb01_ipconfig       = format (
      "ip=${local.lb01_ip}/${var.okd_net_mask},gw=${var.okd_net_gateway}"
  )
}

module "okd-templates" {
  count                       = var.create_vm_templates ? 1 : 0
  source                      = "./modules/templates"

  pm_ssh_url                  = var.pm_ssh_url
  pm_ssh_user                 = var.pm_ssh_user
  pm_ssh_password             = var.pm_ssh_password

  okd_net_gateway             = var.okd_net_gateway
  okd_net_ip_addresses_prefix = var.okd_net_ip_addresses_prefix
  okd_net_mask                = var.okd_net_mask
  vm_storage_name             = var.vm_storage_name

  okd_admin_vm_ip_suffix      = var.okd_admin_vm_ip_suffix

  centos_image_file           = var.centos_image_file
  centos_image_url            = var.centos_image_url
  centos_template_id          = var.centos_template_id
  centos_template_name        = var.centos_template_name
  centos_template_user        = var.centos_template_user
  centos_template_password    = var.centos_template_password
  centos_additional_flags     = var.centos_additional_flags
  centos_skip_tpl_creation    = var.centos_skip_tpl_creation

  scos_image_file             = var.scos_image_file
  scos_image_url              = var.scos_image_url
  scos_template_id            = var.scos_template_id
  scos_template_name          = var.scos_template_name
  scos_additional_flags       = var.scos_additional_flags
  scos_skip_tpl_creation      = var.scos_skip_tpl_creation

  router_image_file           = var.router_image_file
  router_image_url            = var.router_image_url
  router_template_id          = var.router_template_id
  router_template_name        = var.router_template_name
  router_additional_flags     = var.router_additional_flags
  router_skip_tpl_creation    = var.router_skip_tpl_creation
}

module "okd-network" {
  count                       = var.setup_network_interfaces ? 1 : 0
  source                      = "./modules/network"

  proxmox_node_name           = var.proxmox_node_name
  okd_internal_bridge         = var.okd_internal_bridge
}

module "okd-router" {
  depends_on                  = [ 
    module.okd-templates, 
    module.okd-network,
  ]
  count                       = var.setup_network_interfaces ? 1 : 0
  source                      = "./modules/router"

  pm_ssh_url                  = var.pm_ssh_url
  pm_ssh_user                 = var.pm_ssh_user
  pm_ssh_password             = var.pm_ssh_password

  okd_internal_bridge         = var.okd_internal_bridge
  okd_net_ip_addresses_prefix = var.okd_net_ip_addresses_prefix

  vm_storage_name             = var.vm_storage_name
  proxmox_node_name           = var.proxmox_node_name
  router_template_id          = var.router_template_id
  router_template_name        = var.router_template_name
}

module "okd-nfs" {
  depends_on                  = [ 
    module.okd-templates,
    module.okd-router,
  ]
  count                       = var.configure_nfs_server ? 1 : 0
  source                      = "./modules/nfs"
  
  okd_net_mask                = var.okd_net_mask
  nfs_user                    = var.nfs_user
  nfs_pass                    = var.nfs_pass
  primary_ips_str             = local.PRIMARY_IPS_STR
  compute_ips_str             = local.COMPUTE_IPS_STR
  nfs_path                    = var.nfs_path
  okd_net_gateway             = var.okd_net_gateway
  okd_net_ip_addresses_prefix = var.okd_net_ip_addresses_prefix
  okd_net_nfs_ip_suffix       = var.okd_net_nfs_ip_suffix

  pm_ssh_url                  = var.pm_ssh_url
  pm_ssh_user                 = var.pm_ssh_user
  pm_ssh_password             = var.pm_ssh_password 

  okd_net_ip_main_prefix      = var.okd_net_ip_main_prefix
  okd_net_ip_lb_infix         = var.okd_net_ip_lb_infix
  okd_net_ip_lb_vip_suffix    = var.okd_net_ip_lb_vip_suffix
  okd_net_ip_nfs_infix        = var.okd_net_ip_nfs_infix
  lb_vip                      = local.lb_vip

  centos_template_name        = var.centos_template_name
  centos_template_id          = var.centos_template_id
  vm_storage_name             = var.vm_storage_name
  proxmox_node_name           = var.proxmox_node_name
  okd_internal_bridge         = var.okd_internal_bridge
  pacemaker_cluster_pass      = var.pacemaker_cluster_pass
}

module "okd-external-connection" {
  depends_on                      = [ 
    module.okd-templates, 
    module.okd-router,
  ]
  count                           = 1
  source                          = "./modules/connection"

  pm_ssh_url                      = var.pm_ssh_url
  pm_ssh_user                     = var.pm_ssh_user
  pm_ssh_password                 = var.pm_ssh_password

  centos_template_name            = var.centos_template_name
  centos_template_user            = var.centos_template_user
  centos_template_password        = var.centos_template_password

  okd_admin_vm_ip_suffix  = var.okd_admin_vm_ip_suffix

  okd_net_gateway                 = var.okd_net_gateway
  okd_net_ip_addresses_prefix     = var.okd_net_ip_addresses_prefix
  okd_net_mask                    = var.okd_net_mask
  vm_storage_name                 = var.vm_storage_name
  proxmox_node_name               = var.proxmox_node_name
  okd_internal_bridge             = var.okd_internal_bridge
  centos_template_id              = var.centos_template_id
}

module "okd-cluster" {
  depends_on                  = [ 
    module.okd-templates, 
    module.okd-router,
  ]
  count                       = 1
  source                      = "./modules/okd"

  pm_ssh_url                  = var.pm_ssh_url
  pm_ssh_user                 = var.pm_ssh_user
  pm_ssh_password             = var.pm_ssh_password
  pm_url                      = var.pm_url
  pm_api_token_id             = var.pm_api_token_id
  pm_api_token_secret         = var.pm_api_token_secret
  pm_tls_skip_verify          = var.pm_tls_skip_verify
  custom_dns                  = var.custom_dns
  manager_user                = var.manager_user
  manager_pass                = var.manager_pass
  ssh_admin_pass_hash         = var.ssh_admin_pass_hash
  compute_initial_ip_suffix   = var.compute_initial_ip_suffix
  primary_initial_ip_suffix   = var.primary_initial_ip_suffix
  bootstrap_node_state        = var.bootstrap_node_state
  primary_count               = var.primary_count
  compute_count               = var.compute_count
  primary_ips_str             = local.PRIMARY_IPS_STR
  compute_ips_str             = local.COMPUTE_IPS_STR
  nfs_provider_version        = var.nfs_provider_version
  nfs_path                    = var.nfs_path
  configure_nfs_provider      = var.configure_nfs_server 

  okd_cluster_prefix          = var.okd_cluster_prefix
  okd_cluster_domain          = var.okd_cluster_domain
  okd_cluster_subdomain       = var.okd_cluster_subdomain
  okd_default_node_disk_size  = var.okd_default_node_disk_size

  okd_version                 = var.okd_version
  okd_fcos_version            = var.okd_fcos_version
  okd_fcos_digest             = var.okd_fcos_digest

  okd_net_mask                = var.okd_net_mask
  okd_net_gateway             = var.okd_net_gateway
  okd_net_ip_main_prefix      = var.okd_net_ip_main_prefix
  okd_net_ip_lb_infix         = var.okd_net_ip_lb_infix
  okd_net_ip_lb_vip_suffix    = var.okd_net_ip_lb_vip_suffix
  okd_net_ip_lb_00ip_suffix   = var.okd_net_ip_lb_00ip_suffix
  okd_net_ip_lb_01ip_suffix   = var.okd_net_ip_lb_01ip_suffix
  okd_net_nfs_ip_suffix       = var.okd_net_nfs_ip_suffix
  okd_net_bootstrap_ip_suffix = var.okd_net_bootstrap_ip_suffix
  okd_net_ip_addresses_prefix = var.okd_net_ip_addresses_prefix

  lb_vip                      = local.lb_vip
  lb00_ip                     = local.lb00_ip
  lb00_ipconfig               = local.lb00_ipconfig
  lb01_ip                     = local.lb01_ip
  lb01_ipconfig               = local.lb01_ipconfig

  centos_template_name        = var.centos_template_name
  centos_template_id          = var.centos_template_id

  scos_template_name          = var.scos_template_name 
  scos_template_id            = var.scos_template_id

  vm_storage_name             = var.vm_storage_name
  proxmox_node_name           = var.proxmox_node_name
  okd_internal_bridge         = var.okd_internal_bridge
  pacemaker_cluster_pass      = var.pacemaker_cluster_pass
}

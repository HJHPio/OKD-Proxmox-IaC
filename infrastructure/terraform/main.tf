module "proxmox" {
  source = "./modules/proxmox"

  pm_url                      = var.pm_url
  pm_api_token_id             = var.pm_api_token_id
  pm_api_token_secret         = var.pm_api_token_secret
  pm_tls_skip_verify          = var.pm_tls_skip_verify
  okd_version                 = var.okd_version
  custom_dns                  = var.custom_dns
  okd_net_manager_ip_suffix   = var.okd_net_manager_ip_suffix
  okd_net_bootstrap_ip_suffix = var.okd_net_bootstrap_ip_suffix
  okd_net_ip_addresses_prefix = var.okd_net_ip_addresses_prefix
  okd_net_gateway             = var.okd_net_gateway
  okd_net_mask                = var.okd_net_mask
  manager_user                = var.manager_user
  manager_pass                = var.manager_pass
  ssh_admin_pass_hash         = var.ssh_admin_pass_hash
  okd_fcos_version            = var.okd_fcos_version
  okd_fcos_digest             = var.okd_fcos_digest
  compute_initial_ip_suffix   = var.compute_initial_ip_suffix
  primary_initial_ip_suffix   = var.primary_initial_ip_suffix
  bootstrap_node_state        = var.bootstrap_node_state
}
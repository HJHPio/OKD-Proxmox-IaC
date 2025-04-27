# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] – 2025-04-27

### BREAKING CHANGES

- If the OKD cluster was deployed using version 0.0.1, it is strongly recommended **NOT** to update directly to version 1.0.0.  
  Due to major code refactoring, updating may lead to the destruction of existing virtual machines and their complete redeployment from scratch.
  
- If an update is required, **back up all data first**, **manually destroy the existing cluster** to avoid unintended changes, then deploy a new cluster and restore the backed-up data.

### Changes since v0.0.1

- Refactored a significant portion of the codebase, introducing new VM naming conventions, improved VM identifiers, and better separation of modules.
- Integrated VM template creation using [Automated Script – Proxmox-VM-Templates-IaC](https://github.com/HJHPio/Proxmox-VM-Templates-IaC).
- Added integration with [Confizard](https://github.com/HJHPio/Confizard).
- Introduced [OPNsense](https://opnsense.org/) routers configured in a High Availability (HA) setup, enabling automated DNS configuration for the cluster and network isolation.
- Added NFS servers in a High Availability setup to provide automated storage configuration for the OKD cluster.
- Added an Administrator VM to the infrastructure for cluster debugging within an isolated network.
- Added documentation regarding external connection options for accessing the cluster.
- Updated the load balancer configuration to implement a High Availability setup using Pacemaker.
- Introduced the option to extend the project by building custom CoreOS images (see the Administrator Node Ansible configuration file for details).
- Added a test deployment of an Nginx container to verify High Availability behavior by modifying its `index.html` and forcefully shutting down different nodes across the cluster.
- Updated and expanded the project documentation.
- Updated the OKD version from 4.15.0-0.okd-2024-03-10-010116 to 4.18.0-okd-scos.7.
- Revised the attribution section to accurately list the tools and technologies used.
## [0.0.1] - 2024-12-06 

### Added

- Initial release (version 0.0.1) of this project. 

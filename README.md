# OKD Proxmox IaC
This repository demonstrates how to provision a complete OKD cluster on a Proxmox instance using Infrastructure as Code (IaC).  
It supports deployment on a single Proxmox instance, with components configured for High Availability setups.  
Although full multi-node automation is not included, users can manually replicate virtual machine code declarations and configure node names to distribute workloads across multiple Proxmox instances if required.  

Parent project: [OwnLab](https://github.com/orgs/HJHPio/projects/2)    
![OwnLabLogo](./IMGs/OwnLab/OwnLab-Logo-1_V2024.11.28.png)  

# Gallery 
![VirtualMachinesDiagram](./IMGs/docs/OKD_PROXMOX_IAC_VMS.drawio.svg)

## Configuration
This project was tested on Proxmox Virtual Environment (Proxmox VE) version 8.1.4. Running it requires additional tools such as Docker, Git, Ansible, and Tofu — or only Git and Docker if using Confizard through the Quick Setup method.  
Supported configuration variables are documented in the following file: [variables.tf](./infrastructure/terraform/variables.tf)

## Quick Setup Guide
### Confizard (Recommended)
Visit the official [Confizard](https://confizard.hjhp.io/?extConfUrl=https://confizard-assets.pages.dev/okd-proxmox-iac) portal to generate an automated deployment script.
(The link is preconfigured with the steps corresponding to this repository, hosted at https://confizard-assets.pages.dev/okd-proxmox-iac. )
### Manual Deployment Instructions
1. **Navigate to the *terraform* directory** 
```sh
cd infrastructure/terraform
```
2. **Create a *terraform.tfvars* file from the example and populate the required variables**
```sh
cp terraform.tfvars.example terraform.tfvars && vi terraform.tfvars
```
3. **Review the terraform modules for any necessary infrastructure customizations**
Check the modules located at: 
```
(repo-root)/infrastructure/terraform/modules/*.
```
4. **Generate and place an SSH key pair**
- Generate an SSH key pair for passwordless login to the OKD nodes.
- Place the generated keys in the following directory:
```
(repo-root)/infrastructure/terraform/ansible/files/secrets/
```
- **Use the following filenames for the keys:**
  - **Private** key: *ssh-priv-key.key*
  - **Public** key: *ssh-pub-keys.key*
5. **Initialize and apply the infrastructure**
```sh
tofu init
tofu plan -out=init.tfplan
tofu apply "init.tfplan"
```

## External connection to cluster
[connection/README.md](./infrastructure/terraform/modules/connection/README.md) file describes options for external connection to deployed OKD cluster.

## Before Proceeding to Production with This Example
1. **Distribute Infrastructure Across Proxmox Nodes**  
Upgrade the infrastructure by allocating components across multiple Proxmox nodes to ensure failover redundancy and improve overall system resilience.
2. **Secure Cluster Access**  
Configure firewall rules to block non-essential traffic and evaluate secure external access options such as VPN connections or SSH tunnels to safeguard cluster communications.
3. **Mitigate Split-Brain Scenarios**  
Implement a solution to address potential "split-brain" conditions in the high-availability setup. Options include deploying a lightweight virtual machine to act as a quorum-only third node in a Pacemaker cluster, or integrating a control node capable of shutting down a backup router if both routers simultaneously operate as primaries.
4. **Update Credentials**
Ensure that all passwords defined in the deployment variables, as well as those configured in the OPNsense router, are properly updated. **Do not use default credentials.**
5. (Optional) **Consider CephFS as a Storage Backend**  
Assess the project’s storage requirements to determine whether replacing the current NFS configuration with a [CephFS cluster—deployed via Rook.io Helm charts](https://rook.io/docs/rook/v1.17/Getting-Started/ceph-openshift/) would enhance high-availability and stability. A basic CephFS setup has been tested and confirmed to function correctly.
If desired, users may request that the Ceph configuration option be published by opening an issue in this project repository.

## Changelog
[CHANGELOG.md](./CHANGELOG.md) file includes project changes in each release.

## Support
Everyone is welcome to submit an issue ticket on either GitHub or GitLab (depending on which platform this mirror of the project is hosted). Submitted issues will be automatically reviewed, and the main developer will be notified.
If you prefer private support (e.g., if you do not wish to share logs publicly), you can contact the project main developer via email at [support@hjhp.io](mailto:support@hjhp.io).

## Security
If you identify any security problems, please contact us immediately with the necessary details via email at [security@hjhp.io](mailto:security@hjhp.io).  
Please note that the email could end up in the spam folder. If you do not receive a timely response, please try emailing again.  
If the detected vulnerability is critical and the response to emails is not fast enough, please create an issue ticket to inform others and mitigate potential risks.
For more information please refer to [SECURITY.md](./SECURITY.md) file.

## Contributing
Everyone is welcome to contribute via GitHub pull requests or GitLab merge requests.
After reviewing and merging into the respective branches (*github-main* / *gitlab-main*), the final version of the software will be merged into the main branch on the private Git instance, and then all existing mirrors will be updated.  
Instructions on how to contribute can be found in [CONTRIBUTING.md](./CONTRIBUTING.md) file.

## Attribution
This project is maintained by its contributors.
The main tools and technologies used are listed in the [ATTRIBUTION-manual.md](./ATTRIBUTION-manual.md) file.
Automatically detected dependencies and their acknowledgments are listed in the [ATTRIBUTION.md](./ATTRIBUTION.md). file.

## License
*TL;DR:* This project is licensed under the MIT License.  
Everyone is welcome to fork and use it for private and commercial purposes.  
Full license can be found in [LICENSE](./LICENSE) file.  

## Project Status and Roadmap
The project is currently considered complete.  
Previous roadmap ideas have been retained as examples for potential individual extensions, and are documented in the [ROADMAP.md](./ROADMAP.md) file.

New feature requests can be submitted through discussions on any of the project's hosted mirrors.

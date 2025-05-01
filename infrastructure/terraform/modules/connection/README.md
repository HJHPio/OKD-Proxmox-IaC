# Options for External Access to the OKD Cluster

## Basic Setup (Not Recommended for Teams, Performance Testing, or Production Environments)

- Configure port forwarding on the OPNsense router to forward external HTTPS traffic (port 443) to the OKD load balancer.
- Utilize the Administrator VM for cluster management tasks and application development activities.
- (Optional) Configure the Proxmox node as a ProxyJump host for SSH access or for port forwarding into the cluster.

> ⚠️ *This method is intended only for testing or experimental setups and poses potential security and performance risks.*

## Advanced Setup (Recommended)

- Deploy **Cloudflare Tunnels** via the Helm chart on the OKD cluster to securely expose HTTPS services externally, forwarding traffic to the OKD load balancer.  
  ([Cloudflare Tunnel Helm Chart Reference](https://github.com/cloudflare/helm-charts/blob/main/charts/cloudflare-tunnel-remote/values.yaml))

- Deploy **Netbird routing peer containers** within the OKD cluster to establish Zero Trust, peer-to-peer networking between cluster resources and developers/administrators.  
  ([Netbird Routing Peer and Kubernetes Documentation](https://docs.netbird.io/how-to/routing-peers-and-kubernetes))

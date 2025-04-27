Usefull resources:  
- https://github.com/coreos/fedora-coreos-docs/commit/69eecc4275f1ce04fd11c46b058a03095cb911fc
- https://github.com/okd-project/okd/blob/master/FAQ.md#which-fedora-coreos-should-i-use
- https://docs.fedoraproject.org/en-US/fedora-coreos/sysconfig-network-configuration/
- https://docs.okd.io/4.15/installing/installing_platform_agnostic/installing-platform-agnostic.html
- https://docs.okd.io/4.15/storage/dynamic-provisioning.html
- https://www.pivert.org/deploy-openshift-okd-on-proxmox-ve-or-bare-metal-tutorial/
- https://computingforgeeks.com/deploy-multi-node-okd-cluster-using-fedora-coreos/configure-nfs-as-kubernetes-persistent-volume-storage/
- https://computingforgeeks.com/

Manually accept all csr:
```sh
oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve
```

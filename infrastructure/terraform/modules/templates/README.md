### Getting vm images location for OKD
```sh
~/Downloads/openshift-install-linux-4.18.0-okd-scos.5$ (./openshift-install coreos print-stream-json | jq -r '.architectures.x86_64.artifacts.qemu') 
{
  "release": "39.20231101.3.0",
  "formats": {
    "qcow2.xz": {
      "disk": {
        "location": "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/39.20231101.3.0/x86_64/fedora-coreos-39.20231101.3.0-qemu.x86_64.qcow2.xz",
        "signature": "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/39.20231101.3.0/x86_64/fedora-coreos-39.20231101.3.0-qemu.x86_64.qcow2.xz.sig",
        "sha256": "f3b209efb6ea9fe9b8bbfe1c1d4cafc0046ae7aa62bf6b63189494ee90155b81",
        "uncompressed-sha256": "924811866346c35fa32ee8012be4d6c73b2428ac09a43dbcbba4b4dcd660f914"
      }
    }
  }
}
```

### Building SCOS images
https://coreos.github.io/coreos-assembler/working/#im-a-contributor-investigating-a-coreos-bug-how-can-i-test-my-fixes
tl;dr
```sh
mkdir scos-okd-4.19 && cd scos-okd-4.19
cosa init --variant c9s https://github.com/openshift/os.git --force --branch release-4.19
cosa fetch && cosa build
cosa buildextend-metal && cosa buildextend-live --fast
```

#!/bin/bash

# Set script variables
ADDITIONAL_SSH_CONFIG=""
# ADDITIONAL_SSH_CONFIG="--sshkeys ./ssh-pub-keys.key"
TEMPLATE_STORAGE_NAME='local-lvm'
TEMPLATE_MEM=2048
TEMPLATE_CORES=2
TEMPLATE_DISK_SIZE='10G'
NETWORK_BRIDGE='vmbr0'
TEMPLATE_SKIP_CI=false
NO_DOWNLOAD=false
BOOT_FROM_CDROM_ISO=false
SKIP_IMAGE_AS_SCSI_ATTACHMENT=false

# NOTE: skipping cloudinit
# IMAGE_FILE='/var/lib/vz/template/iso/fedora-coreos-40.20240519.3.0-live.x86_64.iso'
# IMAGE_URL='https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/40.20240519.3.0/x86_64/fedora-coreos-40.20240519.3.0-live.x86_64.iso'
# TEMPLATE_ID='4000'
# TEMPLATE_NAME='FCOS-40-1.14-Clean'
# TEMPLATE_SKIP_CI=true

# NOTE: require hookscript that create ignition files from cloudinit settings
# IMAGE_FILE='/var/lib/vz/template/iso/fedora-coreos-40.20240519.3.0-qemu.x86_64.qcow2.xz'
# IMAGE_URL='https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/40.20240519.3.0/x86_64/fedora-coreos-40.20240519.3.0-qemu.x86_64.qcow2.xz'
# TEMPLATE_ID='5000'
# TEMPLATE_NAME='FCOS-40-1.14-CI-SSH'
# TEMPLATE_PASS='fedorapass'
# TEMPLATE_USER='fedorauser'

# IMAGE_FILE='/var/lib/vz/template/iso/CentOS-Stream-GenericCloud-x86_64-9-20240527.0.x86_64.qcow2'
# IMAGE_URL='https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-x86_64-9-20240527.0.x86_64.qcow2'
# TEMPLATE_ID='6000'
# TEMPLATE_NAME='CentOS-S9-Cloud-CI-SSH'
# TEMPLATE_PASS='centospass'
# TEMPLATE_USER='centosuser'

# IMAGE_FILE='/var/lib/vz/template/iso/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2'
# IMAGE_URL='https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2'
# TEMPLATE_ID='7000'
# TEMPLATE_NAME='FedoraCloud-40-1.14-CI-SSH'
# TEMPLATE_PASS='fedorapass'
# TEMPLATE_USER='fedorauser'

# Default settings
IMAGE_FILE='/var/lib/vz/template/iso/ubuntu-24.04-minimal-cloudimg-amd64.img'
IMAGE_URL='https://cloud-images.ubuntu.com/minimal/releases/noble/release-20240608/ubuntu-24.04-minimal-cloudimg-amd64.img'
TEMPLATE_ID='9000'
TEMPLATE_NAME='Ubuntu-24.04-min-CI-SSH'
TEMPLATE_PASS='buntupass'
TEMPLATE_USER='buntuuser'

# Function to check if required commands are available
function check_command() {
  if ! command -v $1 &> /dev/null; then
    echo "Error: $1 is not installed."
    exit 1
  fi
}

# Function to display help message
function show_help() {
  echo "Usage: $0 [options]"
  echo
  echo "Options:"
  echo "  --image-file <path>             Path to the image file (default: ${IMAGE_FILE})"
  echo "  --image-url <url>               URL to download the image (default: ${IMAGE_URL})"
  echo "  --template-id <id>              Template ID (default: ${TEMPLATE_ID})"
  echo "  --template-name <name>          Template name (default: ${TEMPLATE_NAME})"
  echo "  --template-storage-name <name>  Storage name (default: ${TEMPLATE_STORAGE_NAME})"
  echo "  --template-mem <MB>             Memory in MB (default: ${TEMPLATE_MEM})"
  echo "  --template-cores <cores>        Number of CPU cores (default: ${TEMPLATE_CORES})"
  echo "  --template-disk-size <size>     Disk size (default: ${TEMPLATE_DISK_SIZE})"
  echo "  --network-bridge <bridge>       Network bridge (default: ${NETWORK_BRIDGE})"
  echo "  --template-pass <password>      Template password (default: ${TEMPLATE_PASS})"
  echo "  --template-user <user>          Template user (default: ${TEMPLATE_USER})"
  echo "  --ssh-public-keys <path>        Path to SSH public keys (default: none)"
  echo "  --skip-cloud-init-settings      Skip setting ci user, password, ip and ssh keys (default: none)"
  echo "  --no-download                   Skip downloading the image if it already exists (default: false)"
  echo "  --boot-from-cdrom-iso           Boot live env from iso using cdrom if cloudinit is skipped (default: false)"
  echo "  --help                          Display this help message"
}

# Parse arguments
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    --image-file)
      IMAGE_FILE="$2"
      shift # past argument
      shift # past value
      ;;
    --image-url)
      IMAGE_URL="$2"
      shift # past argument
      shift # past value
      ;;
    --template-id)
      TEMPLATE_ID="$2"
      shift # past argument
      shift # past value
      ;;
    --template-name)
      TEMPLATE_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    --template-storage-name)
      TEMPLATE_STORAGE_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    --template-mem)
      TEMPLATE_MEM="$2"
      shift # past argument
      shift # past value
      ;;
    --template-cores)
      TEMPLATE_CORES="$2"
      shift # past argument
      shift # past value
      ;;
    --template-disk-size)
      TEMPLATE_DISK_SIZE="$2"
      shift # past argument
      shift # past value
      ;;
    --network-bridge)
      NETWORK_BRIDGE="$2"
      shift # past argument
      shift # past value
      ;;
    --template-pass)
      TEMPLATE_PASS="$2"
      shift # past argument
      shift # past value
      ;;
    --template-user)
      TEMPLATE_USER="$2"
      shift # past argument
      shift # past value
      ;;
    --ssh-public-keys)
      if [ -n "$2" ]; then
        ADDITIONAL_SSH_CONFIG="--sshkeys $2"
      else
        ADDITIONAL_SSH_CONFIG=""
      fi
      shift # past argument
      shift # past value
      ;;
    --skip-cloud-init-settings)
      TEMPLATE_SKIP_CI=true
      shift # past argument
      ;;
    --no-download)
      NO_DOWNLOAD=true
      shift # past argument
      ;;
    --boot-from-cdrom-iso)
      BOOT_FROM_CDROM_ISO=true
      shift # past argument
      ;;
    --skip-image-scsi-attachment)
      SKIP_IMAGE_AS_SCSI_ATTACHMENT=true
      shift # past argument
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      show_help
      exit 1
      ;;
  esac
done

if [[ "$IMAGE_FILE" == *.xz ]]; then
  IS_XZ_FILE=true
else
  IS_XZ_FILE=false
fi

if [[ "$IMAGE_FILE" == *.bz2 ]]; then
  IS_BZ2_FILE=true
else
  IS_BZ2_FILE=false
fi

if [[ "$IMAGE_FILE" == *.gz ]]; then
  IS_GZ_FILE=true
else
  IS_GZ_FILE=false
fi

# Check if required commands are available
check_command qm
check_command wget
check_command xz

# Ensure the ISO image exists
if [ "$NO_DOWNLOAD" = true ]; then
    if [ ! -f "$IMAGE_FILE" ]; then
        echo "Error: Image file $IMAGE_FILE does not exist and download is disabled."
        exit 1
    else
        echo "Using existing image file $IMAGE_FILE."
    fi
else
    if [ ! -f "$IMAGE_FILE" ] && \
      [ ! -f "${IMAGE_FILE%.gz}" ] && \
      [ ! -f "${IMAGE_FILE%.xz}" ] && \
      [ ! -f "${IMAGE_FILE%.bz2}" ]; then
        echo "Download image..."
        wget -q --show-progress -O "$IMAGE_FILE" "$IMAGE_URL"
        if [ $? -ne 0 ]; then
          echo "Error: Failed to download image."
          exit 1
        fi

        # Decompress if the image is an xz file
        if [ "$IS_XZ_FILE" = true ]; then
          echo "Decompressing image..."
          xz -dv "$IMAGE_FILE"
          IMAGE_FILE="${IMAGE_FILE%.xz}"
          if [ $? -ne 0 ]; then
            echo "Error: Failed to decompress image."
            exit 1
          fi
        fi
        
        # Decompress if the image is an bz2 file
        if [ "$IS_BZ2_FILE" = true ]; then
          echo "Decompressing BZ2 image..."
          bzip2 -d "$IMAGE_FILE"
          IMAGE_FILE="${IMAGE_FILE%.bz2}"
          if [ $? -ne 0 ]; then
            echo "Error: Failed to decompress image."
            exit 1
          fi
        fi

        # Decompress if the image is an gz file
        if [ "$IS_GZ_FILE" = true ]; then
          echo "Decompressing GZ image..."
          gzip -d "$IMAGE_FILE"
          IMAGE_FILE="${IMAGE_FILE%.gz}"
          if [ $? -ne 0 ]; then
            echo "Error: Failed to decompress image."
            exit 1
          fi
        fi

    else
        echo "Image file $IMAGE_FILE already exists. Skipping download and updating IMAGE_FILE name"
        if [ "$IS_XZ_FILE" = true ]; then
          IMAGE_FILE="${IMAGE_FILE%.xz}"
        fi
        if [ "$IS_BZ2_FILE" = true ]; then
          IMAGE_FILE="${IMAGE_FILE%.bz2}"
        fi
        if [ "$IS_GZ_FILE" = true ]; then
          IMAGE_FILE="${IMAGE_FILE%.gz}"
        fi
        echo "Fixed image file name $IMAGE_FILE."
    fi
fi

# Create VM
qm create $TEMPLATE_ID --name $TEMPLATE_NAME \
  --net0 virtio,bridge=$NETWORK_BRIDGE \
  --memory $TEMPLATE_MEM \
  --cpu host \
  --cores $TEMPLATE_CORES \
  --autostart \
  --onboot 1 \
  --boot c --bootdisk scsi0

if [ $? -ne 0 ]; then
  echo "Error: Failed to create VM."
  exit 1
fi

template_vmcreated=$(date +%Y-%m-%d)
if [ "$TEMPLATE_SKIP_CI" != true ]; then
  CLOUD_INIT_STATUS="true"
else
  CLOUD_INIT_STATUS="false"
fi
qm set ${TEMPLATE_ID} --description "Template name: ${TEMPLATE_NAME}

 - OS URL              : ${IMAGE_URL}
 - Cloud-init          : ${CLOUD_INIT_STATUS}

Creation date : ${template_vmcreated}
"

# Import image
qm importdisk $TEMPLATE_ID $IMAGE_FILE $TEMPLATE_STORAGE_NAME
if [ $? -ne 0 ]; then
  echo "Error: Failed to import disk."
  exit 1
fi

if [[ "$SKIP_IMAGE_AS_SCSI_ATTACHMENT" == false ]]; then
  # Attach image as storage device
  qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 $TEMPLATE_STORAGE_NAME:vm-$TEMPLATE_ID-disk-0
  if [ $? -ne 0 ]; then
    echo "Error: Failed to attach image as storage device."
    exit 1
  fi

  # Resize the disk 
  qm resize $TEMPLATE_ID scsi0 $TEMPLATE_DISK_SIZE
  if [ $? -ne 0 ]; then
    echo "Error: Failed to resize disk."
    exit 1
  fi

  # Configure VM to boot from our image
  qm set $TEMPLATE_ID --boot c --bootdisk scsi0
  if [ $? -ne 0 ]; then
    echo "Error: Failed to configure VM to boot from image."
    exit 1
  fi
fi

# Disable ballooning device
qm set $TEMPLATE_ID --balloon 0
if [ $? -ne 0 ]; then
  echo "Error: Failed to disable ballooning device."
  exit 1
fi


if [ "$TEMPLATE_SKIP_CI" != true ]; then

  # Add a serial console
  qm set $TEMPLATE_ID --serial0 socket --vga serial0
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add a serial console."
    exit 1
  fi
  
  # Attach a drive for cloud-init
  qm set $TEMPLATE_ID --ide2 $TEMPLATE_STORAGE_NAME:cloudinit
  if [ $? -ne 0 ]; then
    echo "Error: Failed to attach cloud-init drive."
    exit 1
  fi

  # Set VM to use cloud-init 
  qm set $TEMPLATE_ID --cipassword $TEMPLATE_PASS --ciuser $TEMPLATE_USER $ADDITIONAL_SSH_CONFIG
  if [ $? -ne 0 ]; then
    echo "Error: Failed to set cloud-init options."
    exit 1
  fi

  # Set Cloud-Init network configuration to DHCP
  qm set $TEMPLATE_ID --ipconfig0 ip=dhcp
  if [ $? -ne 0 ]; then
    echo "Error: Failed to set Cloud-Init network configuration."
    exit 1
  fi
  
else
    echo "Skipped: Cloud-init settings."
    if [[ "$BOOT_FROM_CDROM_ISO" == true ]]; then
      echo "Attaching ISO image ${IMAGE_FILE} as IDE drive for VM ${TEMPLATE_ID}... "
      qm set $TEMPLATE_ID --ide2 $IMAGE_FILE,media=cdrom
      if [ $? -ne 0 ]; then
        echo "Error: Failed to attach ISO image as IDE drive."
        exit 1
      fi

      echo "Set boot from ISO image ${IMAGE_FILE} for VM ${TEMPLATE_ID}... "
      # Configure VM to boot from IDE drive
      qm set $TEMPLATE_ID --boot c --bootdisk ide2
      if [ $? -ne 0 ]; then
        echo "Error: Failed to configure VM to boot from IDE drive."
        exit 1
      fi
    fi
fi

# Convert VM to template
echo "Convert VM ${TEMPLATE_ID} in proxmox vm template... "
qm template $TEMPLATE_ID
if [ $? -ne 0 ]; then
  echo "Error: Failed to convert VM to template."
  exit 1
fi

echo "Template creation completed successfully."

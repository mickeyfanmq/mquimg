# Specify Packer version and required plugins
packer {
  required_plugins {
    vsphere = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

# Variables for sensitive data and configuration details
variable "vcenter_server" {
  description = "The vSphere vCenter server address"
}

variable "username" {
  description = "The vSphere username"
}

variable "password" {
  description = "The vSphere password"
  sensitive   = true
}

variable "datacenter" {
  description = "The vSphere datacenter to use"
}

variable "cluster" {
  description = "The vSphere cluster to use"
}

variable "datastore" {
  description = "The vSphere datastore to use"
}

variable "network" {
  description = "The vSphere network to use"
}

variable "iso_path" {
  description = "Path to the Windows ISO file in the vSphere datastore"
}

variable "vm_name" {
  description = "Name of the temporary VM created during the build"
  default     = "packer-windows-vm"
}

# Define the vSphere ISO Builder configuration
source "vsphere-iso" "windows" {
  # vSphere connection configuration
  vcenter_server = var.vcenter_server
  username       = var.username
  password       = var.password
  insecure_connection = "true"  # Set to false if using a valid SSL certificate

  # vSphere infrastructure configuration
  datacenter     = var.datacenter
  cluster        = var.cluster
  datastore      = var.datastore
  network        = var.network
  vm_name        = var.vm_name

  # VM hardware configuration
  cpus           = 2
  memory         = 4096
  disk_size      = 50000  # Size in MB
  guest_os_type  = "windows9_64Guest"  # Choose the guest OS type

  # ISO file and boot configuration
  iso_paths      = [var.iso_path]  # e.g., "[datastore] path/to/Windows_Server_2019.iso"
  cd_label       = "Windows Install"

  # Boot command configuration for Windows unattended installation
  boot_wait      = "2m"
  boot_command   = [
    "<esc><wait>",
    "boot: <enter><wait>",
    "/install/vmlinuz initrd=/install/initrd.gz --- <enter>"
  ]

  # SSH/WinRM communicator configuration
  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_password = "YourPassword123!"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "10m"

  # VM options
  shutdown_command = "shutdown /s /t 0 /f"
  shutdown_timeout = "5m"

  # Resource pool and folder (optional)
  folder        = "Packer Builds"
  resource_pool = "Resources"

  # Convert VM to template after build
  convert_to_template = true
}

# Define the build and provisioners
build {
  sources = ["source.vsphere-iso.windows"]

  # Run a PowerShell script to install Windows features or configure settings
  provisioner "powershell" {
    inline = [
      "Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature",
      "Write-Output 'Web Server installed successfully!'"
    ]
  }

  # Additional scripts for VM customization
  provisioner "file" {
    source = "scripts/my-script.ps1"
    destination = "C:\\Windows\\Temp\\my-script.ps1"
  }

  provisioner "powershell" {
    script = "C:\\Windows\\Temp\\my-script.ps1"
  }
}

# Packer HCL2 configuration file for creating a Windows Server 2022 AMI

variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

source "amazon-ebs" "windows" {
  region                = var.aws_region
  instance_type         = "t3.medium"
  ami_name              = "Windows-Server-2022-Built-{{timestamp}}"
  source_ami_filter {
    filters = {
      name                = "Windows_Server-2022-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["801119661308"]  # Owner ID for Microsoft Windows AMIs
    most_recent = true
  }
  winrm_username        = "Administrator"
  winrm_use_ssl         = true
  winrm_insecure        = true
  communicator          = "winrm"
}

provisioner "powershell" {
  inline = [
    "Write-Host 'Installing IIS...'",
    "Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature",
    "Write-Host 'IIS Installed!'"
  ]
}

build {
  name    = "Windows Server 2022 AMI Build"
  sources = ["source.amazon-ebs.windows"]
}

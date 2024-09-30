# Specify the required plugins
packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Define the source block using amazon-ebs builder
source "amazon-ebs" "windows" {
  ami_name              = "Windows-Server-2022-Built-{{timestamp}}"
  instance_type         = "t3.medium"
  region                = "ap-southeast-2"         # Specify your desired region
  source_ami_filter {
    filters = {
      name                = "Windows_Server-2022-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["801119661308"]                 # Owner ID for Microsoft Windows AMIs
    most_recent = true
  }
  ssh_username          = "Administrator"
  winrm_username        = "Administrator"          # Use WinRM for Windows communication
  winrm_insecure        = true                     # Set to true if using self-signed certificates
  winrm_use_ssl         = true                     # Enable SSL for WinRM
  winrm_port            = 5986                     # Default WinRM HTTPS port
  communicator          = "winrm"                  # Specify WinRM as the communicator
  ami_description       = "Windows Server 2022 AMI built with Packer"
  ami_virtualization_type = "hvm"

  # Optional configurations
  associate_public_ip_address = true               # Attach a public IP for RDP access
  iam_instance_profile = "EC2InstanceProfile"      # Specify an IAM instance profile if needed

  # Instance tags
  tags = {
    "Name"      = "Packer-Windows-Server-2022"
    "Purpose"   = "Packer Windows AMI Build"
    "BuiltBy"   = "Packer"
  }
}


# Build block to specify which source to use
build {
  name    = "Windows Server 2022 AMI Build"
  sources = ["source.amazon-ebs.windows"]

}

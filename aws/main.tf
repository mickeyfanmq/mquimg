terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    packer = {
      source  = "hashicorp/packer"
      version = "~> 1.8.5"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "aws_region" {
  description = "The AWS region to use for the Packer build and EC2 instance"
  default     = "ap-southeast-2"
}

# Define the Packer build resource to create a Windows Server 2022 AMI
resource "packer_build" "windows_ami" {
  source {
    builder {
      name                = "amazon-ebs"
      region              = var.aws_region
      instance_type       = "t3.medium"
      ami_name            = "Windows-Server-2022-Built-{{timestamp}}"
      source_ami_filter {
        filters = {
          name                = "Windows_Server-2022-English-Full-Base-*"
          root-device-type    = "ebs"
          virtualization-type = "hvm"
        }
        owners      = ["801119661308"]  # Microsoft Windows AMIs owner ID
        most_recent = true
      }
      communicator        = "winrm"
      winrm_username      = "Administrator"
      winrm_use_ssl       = true
      winrm_insecure      = true
    }

    provisioner {
      type    = "powershell"
      inline  = [
        "Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature",
        "Write-Host 'IIS Installed!'"
      ]
    }
  }

  # Output the AMI ID created by the Packer build
  outputs = {
    ami_id = "{{ build `amazon-ebs` `aws_region` }}"
  }
}

# Use the AMI created by Packer to launch an EC2 instance
resource "aws_instance" "windows_server" {
  ami           = packer_build.windows_ami.outputs["ami_id"]
  instance_type = "t3.medium"
  key_name      = var.key_name

  tags = {
    Name = "Windows Server 2022 from Packer"
  }
}

# Output the public IP of the Windows instance
output "windows_instance_public_ip" {
  value = aws_instance.windows_server.public_ip
}

# Variables for AWS key pair and region
variable "key_name" {
  description = "The name of the AWS key pair to use for SSH access"
  default     = "my-key-pair"
}

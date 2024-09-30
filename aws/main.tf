provider "aws" {
  region = "ap-southeast-2"
}

# Use null_resource to trigger a local Packer build
resource "null_resource" "packer_build_windows_ami" {
  provisioner "local-exec" {
    command = "packer build -var 'aws_region=${var.region}' win1.pkr.hcl"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

# Output the generated AMI ID (optional)
output "windows_ami_id" {
  value = null_resource.packer_build_windows_ami.id
}

# Variable to set AWS region
variable "region" {
  description = "The AWS region to build the AMI"
  default     = "ap-southeast-2"
}

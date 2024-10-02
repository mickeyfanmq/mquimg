packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source.
source "amazon-ebs" "firstrun-windows" {
  ami_name      = "packer-windows-demo-${local.timestamp}"
  communicator  = "winrm"
  instance_type = "t2.micro"
  region        = "ap-southeast-2"
  source_ami = "ami-024781a6c1dcb2253"

  user_data_file = "./bootstrap_win.txt"
  winrm_password = "SuperS3cr3t!!!!"
  winrm_username = "Administrator"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  name    = "learn-packer"
  sources = ["source.amazon-ebs.firstrun-windows"]

  
}

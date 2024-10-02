packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
 
source "amazon-ebs" "ubuntu" {
  ami_name      = "learn-packer-linux-aws1"
  instance_type = "t2.micro"
  region        = "ap-southeast-2"
#  source_ami = "ami-08a8dfbb1c5db5344"
  source_ami = "ami-0892a9c01908fafd1"
  
  ssh_username = "ubuntu"
}
 
build {
	name = "my-first-build1"
	sources = ["source.amazon-ebs.ubuntu"]
}

variable "ami" {}
variable "instance_type" {}
variable "identity" {}
variable "security_group_id" {}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "training" {
  key_name   = "${var.identity}"
  public_key = "${tls_private_key.example.public_key_pem}"
}

module "randomname" {
  source = "github.com/denislavdenov/terraform-local-randomname"
}

resource "aws_instance" "example" {
  tags {
    Name = "${module.randomname.instance_id}"
  }

  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.training.id}"
  vpc_security_group_ids = ["${var.security_group_id}"]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update"
    ]
  }

  connection {
    user        = "ubuntu"
    private_key = "${tls_private_key.example.private_key_pem}"
  }
}

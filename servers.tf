variable "ami" {}
variable "instance_type" {}
variable "identity" {}
variable "public_key" {}
variable "security_group_id" {}
variable "private_key" {}

resource "aws_key_pair" "training" {
  key_name   = "${var.identity}"
  public_key = "${var.public_key}"
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
    private_key = "${var.private_key}"
  }
}

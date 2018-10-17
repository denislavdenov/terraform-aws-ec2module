variable "ami" {}
variable "instance_type" {}
variable "identity" {}
variable "security_group_id" {}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  depends_on = ["tls_private_key.example"]
  content    = "${tls_private_key.example.private_key_pem}"
  filename   = "the_new_key"
}

resource "aws_key_pair" "training" {
  key_name   = "${var.identity}"
  public_key = "${tls_private_key.example.public_key_openssh}"
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
      "sleep 60"
    ]
  }

  connection {
    user        = "ubuntu"
    private_key = "${tls_private_key.example.private_key_pem}"
  }
}

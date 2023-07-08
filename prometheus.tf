resource "aws_instance" "prometheus" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = "batch5kp"
  vpc_security_group_ids      = [aws_security_group.ecs_security_group.id]
  subnet_id       = aws_subnet.subnet1.id
  associate_public_ip_address = true
  user_data                   = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt-get update
              sudo apt-get -y upgrade
              cd /opt
              sudo wget https://github.com/prometheus/prometheus/releases/download/v2.43.0/prometheus-2.43.0.linux-amd64.tar.gz
              sudo tar xf prometheus-2.43.0.linux-amd64.tar.gz
              sudo ./prometheus
              EOF

  tags = {
    Name = "prometheus-tf"
  }
}

variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "ami_id" {
  default = "ami-053b0d53c279acc90"
  type    = string
}

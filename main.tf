provider "aws" {
  region = var.region
}

resource "aws_instance" "flask_express" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data     = file("${path.module}/user_data.sh")

  tags = {
    Name = "flask-express-instance"
  }

  vpc_security_group_ids = [aws_security_group.allow_web.id]
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web ports"
  ingress = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

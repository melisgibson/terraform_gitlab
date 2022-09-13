# --- ec2/main.tf ---
data "aws_ami" "server_ami" {
  most_recent = true

  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.*.0-x86_64-gp2"]
  }
}

resource "aws_launch_template" "web_server" {
  name_prefix   = "web-server"
  instance_type = var.instance_type
  image_id           = data.aws_ami.server_ami.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name = var.key_name
  user_data = var.user_data

  tags = {
    Name = "web-server"
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  name                = "web-server-asg"
  vpc_zone_identifier = var.public_subnets
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH inbound traffic, and HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

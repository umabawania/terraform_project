resource "aws_vpc" "test" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  tags = {
    Name = "test"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id              = aws_vpc.test.id
  cidr_block         = var.subnet_cidr_block_public
  availability_zone   = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id              = aws_vpc.test.id
  cidr_block         = var.subnet_cidr_block_private
  availability_zone   = var.availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = "private_subnet"
  }
}

resource "aws_internet_gateway" "test_igw" {
  vpc_id   = aws_vpc.test.id
  tags = {
    Name = "test_igw"
  }
}

resource "aws_route_table" "test-route" {
  vpc_id   = aws_vpc.test.id
  tags = {
    Name = "test-route"
  }
}

resource "aws_route" "internet_access-1" {
  route_table_id         = aws_route_table.test-route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.test_igw.id
}

resource "aws_route_table_association" "subnet_association-1" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.test-route.id
}

resource "aws_security_group" "test_sg" {
  name        = "virginia-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.test.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-security-group"
  }
}

resource "aws_instance" "public_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id             = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.test_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "public-ec2-instance"
  }

  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install httpd -y
                systemctl start httpd
                systemctl enable httpd
                echo "Hello, World from N-virginia" > /var/www/html/index.html
                EOF
}

resource "aws_instance" "Bastion_host_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id             = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.test_sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "private-ec2-instance"
  }
}


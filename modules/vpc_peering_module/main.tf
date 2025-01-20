resource "aws_vpc" "n-virginia" {
  cidr_block       = var.vpc_n_virginia_cidr
  instance_tenancy = "default"
  provider         = aws.N-virginia
  tags = {
    Name = "n-virginia"
  }
}

resource "aws_subnet" "n-virginia" {
  provider             = aws.N-virginia
  vpc_id               = aws_vpc.n-virginia.id
  cidr_block           = var.subnet_n_virginia_cidr
  availability_zone    = var.availability_zone_n_virginia
  map_public_ip_on_launch = true
  tags = {
    Name = "n-virginia"
  }
}

resource "aws_internet_gateway" "virginia_igw" {
  vpc_id   = aws_vpc.n-virginia.id
  provider = aws.N-virginia
  tags = {
    Name = "virginia_igw"
  }
}

resource "aws_route_table" "n-virginia-route" {
  vpc_id   = aws_vpc.n-virginia.id
  provider = aws.N-virginia
  tags = {
    Name = "n-virginia-route"
  }
}

resource "aws_route" "internet_access-1" {
  route_table_id         = aws_route_table.n-virginia-route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.virginia_igw.id
  provider               = aws.N-virginia
}

resource "aws_route_table_association" "subnet_association-1" {
  subnet_id      = aws_subnet.n-virginia.id
  route_table_id = aws_route_table.n-virginia-route.id
  provider       = aws.N-virginia
}

resource "aws_security_group" "virginia_sg" {
  name        = "virginia-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.n-virginia.id
  provider    = aws.N-virginia

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
    Name = "virginia-security-group"
  }
}

resource "aws_instance" "n-virginia_instance" {
  ami           = var.ami_n_virginia
  instance_type = var.instance_type
  key_name      = var.key_name_n_virginia
  subnet_id     = aws_subnet.n-virginia.id
  vpc_security_group_ids = [aws_security_group.virginia_sg.id]
  associate_public_ip_address = true
  provider = aws.N-virginia

  tags = {
    Name = "n-virginia-ec2-instance"
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

resource "aws_vpc" "mumbai" {
  cidr_block       = var.vpc_mumbai_cidr
  instance_tenancy = "default"
  provider         = aws.mumbai
  tags = {
    Name = "mumbai"
  }
}

resource "aws_subnet" "mumbai" {
  provider             = aws.mumbai
  vpc_id               = aws_vpc.mumbai.id
  cidr_block           = var.subnet_mumbai_cidr
  availability_zone    = var.availability_zone_mumbai
  map_public_ip_on_launch = true
  tags = {
    Name = "mumbai"
  }
}

resource "aws_internet_gateway" "mumbai_igw" {
  vpc_id   = aws_vpc.mumbai.id
  provider = aws.mumbai
  tags = {
    Name = "mumbai_igw"
  }
}

resource "aws_route_table" "mumbai-route" {
  vpc_id   = aws_vpc.mumbai.id
  provider = aws.mumbai
  tags = {
    Name = "mumbai-route"
  }
}

resource "aws_route" "internet_access-2" {
  route_table_id         = aws_route_table.mumbai-route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mumbai_igw.id
  provider               = aws.mumbai
}

resource "aws_route_table_association" "subnet_association-2" {
  subnet_id      = aws_subnet.mumbai.id
  route_table_id = aws_route_table.mumbai-route.id
  provider       = aws.mumbai
}

resource "aws_security_group" "mumbai_sg" {
  name        = "mumbai-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.mumbai.id
  provider    = aws.mumbai

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
    Name = "mumbai-security-group"
  }
}

resource "aws_instance" "mumbai_instance" {
  ami           = var.ami_mumbai
  instance_type = var.instance_type
  key_name      = var.key_name_mumbai
  subnet_id     = aws_subnet.mumbai.id
  vpc_security_group_ids = [aws_security_group.mumbai_sg.id]
  associate_public_ip_address = true
  provider = aws.mumbai

  tags = {
    Name = "mumbai_instance"
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    systemctl start httpd
    systemctl enable httpd
    echo "Hello, World from Mumbai" > /var/www/html/index.html
  EOF
}

resource "aws_vpc_peering_connection" "vpc_peering" {
  provider      = aws.N-virginia
  vpc_id        = aws_vpc.n-virginia.id
  peer_vpc_id   = aws_vpc.mumbai.id
  peer_region   = var.region_mumbai
  auto_accept   = false

  tags = {
    Name = "VPC-Peering-Connection"
  }
}

resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                     = aws.mumbai
  vpc_peering_connection_id     = aws_vpc_peering_connection.vpc_peering.id
  auto_accept                  = true

  tags = {
    Name = "VPC-Peering-Accept"
  }
}

resource "aws_route" "internet_access-3" {
  provider                   = aws.N-virginia
  route_table_id             = aws_route_table.n-virginia-route.id
  destination_cidr_block     = aws_vpc.mumbai.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.vpc_peering.id
}

resource "aws_route" "internet_access-4" {
  provider                   = aws.mumbai
  route_table_id             = aws_route_table.mumbai-route.id
  destination_cidr_block     = aws_vpc.n-virginia.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.vpc_peering.id
}

resource "null_resource" "check_vpc_connectivity" {
  depends_on = [aws_instance.mumbai_instance, aws_instance.n-virginia_instance]

  provisioner "local-exec" {
    command = <<EOT
      echo "Testing connectivity between VPCs"
      curl -m 5 http://${aws_instance.mumbai_instance.private_ip} || echo "Failed to connect to Mumbai EC2"
      curl -m 5 http://${aws_instance.n-virginia_instance.private_ip} || echo "Failed to connect to Virginia EC2"
    EOT
  }
}

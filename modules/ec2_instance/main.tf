provider "aws" {
    region = "us-east-1"
    alias = "N-virginia"
}
resource "aws_vpc" "test" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  provider = aws.N-virginia
  tags = {
    Name = "test"
  }
}
resource "aws_subnet" "public_subnet" {
  provider = aws.N-virginia
  vpc_id     = aws_vpc.test.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }
}
resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test.id
  provider = aws.N-virginia
  tags = {
    Name = "test_igw"
  }
}
resource "aws_route_table" "test-route" {
  vpc_id = aws_vpc.test.id
  provider = aws.N-virginia
  
  tags = {
    Name = "test-route"
  }
}

# Add a default route to the Internet Gateway
resource "aws_route" "internet_access-1" {
  route_table_id         = aws_route_table.test-route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.test_igw.id
  provider = aws.N-virginia
}

# Associate the route table with a public subnet
resource "aws_route_table_association" "subnet_association-1" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.test-route.id
  provider = aws.N-virginia
}
# Create a Security Group
resource "aws_security_group" "test_sg" {
  name        = "virginia-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.test.id
  provider = aws.N-virginia

  # Inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic from anywhere
  }

  # Outbound rules (allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "test-security-group"
  }
}
# Create an EC2 instance
resource "aws_instance" "public_instance" {
  ami           = "ami-0df8c184d5f6ae949" 
  instance_type = "t2.micro"
  key_name = "key-1"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids =  [aws_security_group.test_sg.id]
  associate_public_ip_address = true
  provider = aws.N-virginia

  tags = {
    Name = "public-ec2-instance"
  }

  # Optional: Add user data for initialization
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              echo "Hello, World from N-virginia" > /var/www/html/index.html
              EOF
}
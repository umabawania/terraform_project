terraform {
  backend "s3" {
    bucket         = var.s3_bucket
    key            = var.tfstate_path
    region         = var.region
    dynamodb_table = var.dynamodb_table
    encrypt        = true
  }
}

resource "tls_private_key" "key-1" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "key_pair-1" {
  key_name   = var.key_name
  public_key = tls_private_key.key-1.public_key_openssh
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 8069
    to_port          = 8069
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
resource "aws_iam_role" "ec2_instance_connect" {
  name = "ec2_instance_connect_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ec2_instance_connect_policy" {
  role       = aws_iam_role.ec2_instance_connect.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_connect_profile" {
  name = "ec2_instance_connect_profile"
  role = aws_iam_role.ec2_instance_connect.name
}
resource "aws_instance" "terraform" {
   ami = var.ami_id
   instance_type = var.instance_type
   subnet_id = aws_subnet.subnet.id
   key_name = aws_key_pair.key_pair-1.key_name
   associate_public_ip_address = true
   vpc_security_group_ids      = [aws_security_group.sg.id]
   iam_instance_profile = aws_iam_instance_profile.ec2_instance_connect_profile.name

   provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu" # or "ec2-user" depending on the AMI
      private_key = tls_private_key.key-1.private_key_pem
      host        = self.public_ip
    }
    inline = [ 
      " echo Hello ! "
     ]
  }
  provisioner "local-exec" {
  command = <<EOT
    echo "${tls_private_key.key-1.private_key_pem}" > ${path.module}/key-1.pem
    chmod 600 ${path.module}/key-1.pem
  EOT
}

}

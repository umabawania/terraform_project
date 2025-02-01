resource "aws_vpc" "test" {
  cidr_block        = var.vpc_cidr_block
  instance_tenancy  = "default"

  tags = {
    Name = test
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id              = aws_vpc.test.id
  cidr_block         = var.public_subnet_cidr_block[0]
  availability_zone  = var.availability_zone[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id              = aws_vpc.test.id
  cidr_block         = var.public_subnet_cidr_block[1]
  availability_zone  = var.availability_zone[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet-2"
  }
}

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "test_igw"
  }
}

resource "aws_route_table" "test-route" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "test-route"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.test-route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.test_igw.id
}

resource "aws_route_table_association" "subnet_association_1" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.test-route.id
}

resource "aws_route_table_association" "subnet_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.test-route.id
}

resource "aws_security_group" "test_sg" {
  name        = test_sg
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

  ingress {
    from_port   = 8200
    to_port     = 8200
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
    Name = test_sg
  }
}

resource "aws_instance" "public_instance" {
  ami                  = var.instance_ami[0]
  instance_type        = var.instance_type
  key_name             = var.key_name
  subnet_id            = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.test_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "vault"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              echo "Hello, World from Target-Instance-1" > /var/www/html/index.html
              EOF
}

resource "aws_instance" "public_instance_2" {
  ami                  = var.instance_ami[1]
  instance_type        = var.instance_type
  key_name             = var.key_name
  subnet_id            = aws_subnet.public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.test_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "vault-2"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              echo "Hello, World from Target-instance-2" > /var/www/html/index.html
              EOF
}

resource "aws_s3_bucket" "remote_backend" {
  bucket = var.log_s3_bucket_name
}

resource "aws_s3_bucket_policy" "remote_backend_policy" {
  bucket = aws_s3_bucket.remote_backend.id

  policy = <<POLICY
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "AWS": "arn:aws:iam::127311923021:root"
              },
              "Action": "s3:PutObject",
              "Resource": "arn:aws:s3:::${var.log_s3_bucket_name}/*"
          }
      ]
  }
  POLICY
}

resource "aws_lb" "dev_alb" {
  name               = dev_alb
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
  access_logs {
    bucket  = var.log_s3_bucket_name
    enabled = true
    prefix  = "AWSlogs"
  }

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "dev_tg" {
  name     = dev_tg
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test.id
}

resource "aws_lb_target_group_attachment" "dev_tg_1" {
  target_group_arn = aws_lb_target_group.dev_tg.arn
  target_id        = aws_instance.public_instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "dev_tg_2" {
  target_group_arn = aws_lb_target_group.dev_tg.arn
  target_id        = aws_instance.public_instance_2.id
  port             = 80
}

resource "aws_lb_listener" "dev_lb_listener" {
  load_balancer_arn = aws_lb.dev_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_tg.arn
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.dev_lb_listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["/error*"]
    }
  }

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Error! Page Not Found"
      status_code  = "404"
    }
  }
}
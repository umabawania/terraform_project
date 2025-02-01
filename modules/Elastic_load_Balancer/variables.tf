variable "s3_bucket" {
  description = "Name of your S3 Bucket"
  type = string
}
variable "tfstate_path" {
  description = "path/to/your/terraform.tfstate"
  type = string
}
variable "region" {
  description = "your-region"
  type = string
}
variable "dynamodb_table" {
  description = "terraform-locks"
  type = string
}
variable "access_key" {
    description = "Access key "
    type = string
}
variable "secret_key" {
    description = "Secret key "
    type = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = list(string)
  default     = ["10.0.1.0/24" , "10.0.3.0/24" ]
}

variable "availability_zone" {
  description = "First availability zone"
  type        = list(string)
  default     = ["us-east-1a" , "us-east-1b" ]
}

variable "instance_ami_1" {
  description = "AMI ID for the first instance"
  type        = list(string)
  default     = ["ami-0df8c184d5f6ae949" , "ami-04b4f1a9cf54c11d0" ]
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name"
  type        = string
  default     = "key-1"
}

variable "log_s3_bucket_name" {
  description = "Name"
}
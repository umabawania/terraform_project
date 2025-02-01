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
variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0df8c184d5f6ae949"
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key name for EC2 instances"
  type        = string
  default     = "key-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block_public" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_cidr_block_private" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}
variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

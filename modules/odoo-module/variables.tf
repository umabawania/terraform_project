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
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.2.0/24"
}
variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}
variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  }

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
  default     = "key_pair-1"
}

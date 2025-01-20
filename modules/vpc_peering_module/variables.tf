variable "region_n_virginia" {
  description = "Region for N-Virginia"
  default     = "us-east-1"
}

variable "region_mumbai" {
  description = "Region for Mumbai"
  default     = "ap-south-1"
}

variable "vpc_n_virginia_cidr" {
  description = "CIDR block for N-Virginia VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_mumbai_cidr" {
  description = "CIDR block for Mumbai VPC"
  default     = "10.1.0.0/16"
}

variable "subnet_n_virginia_cidr" {
  description = "CIDR block for N-Virginia subnet"
  default     = "10.0.1.0/24"
}

variable "subnet_mumbai_cidr" {
  description = "CIDR block for Mumbai subnet"
  default     = "10.1.1.0/24"
}

variable "availability_zone_n_virginia" {
  description = "Availability zone for N-Virginia"
  default     = "us-east-1a"
}

variable "availability_zone_mumbai" {
  description = "Availability zone for Mumbai"
  default     = "ap-south-1a"
}

variable "ami_n_virginia" {
  description = "AMI for N-Virginia"
  default     = "ami-0df8c184d5f6ae949"
}

variable "ami_mumbai" {
  description = "AMI for Mumbai"
  default     = "ami-0d2614eafc1b0e4d2"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name_n_virginia" {
  description = "Key name for N-Virginia"
  default     = "key-1"
}

variable "key_name_mumbai" {
  description = "Key name for Mumbai"
  default     = "key1"
}

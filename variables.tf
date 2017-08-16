variable "region" {
  default = "us-west-1"
}
variable "profile" {
  default = "your profile"
}
/* nginx image */
variable "LinuxAMI" {
  type = "map"
  default = {
    us-east-1 = "ami-b73b63a0"
    us-west-1 = "your ami id" # hardened nginx image
    us-west-2 = "ami-5ec1673e"
  }
  description = "mapping LinuxAMI of AWS regions"
}

/* bastion host image */
variable "NAT" {
  type = "map"
  default = {
  
    us-west-1 = "ami-004b0f60" # NAT image
  }
  description = "mapping LinuxAMI of AWS regions"
}

variable "aws_access_key" {
  default = "your key"
  description = "aws access key"
}
variable "aws_secret_key" {
  default = "your secret"
  description = "aws secret key"
}

variable "vpc-fullcidr" {
    default = "172.28.100.0/24"
  description = "vpc cdir"
}
variable "subnet-public-cidr" {
  default = "172.28.100.0/25"
  description = "cidr of the pubic subnet"
}
variable "subnet-private-cidr" {
  default = "172.28.100.128/25"
  description = "cidr of the private subnet"
}
variable "key_name" {
  default = "your key name"
  description = "ssh key to log in to EC2 machines"
}
variable "route_53_zone_id" {
  default = "your route 53 zone id"
  description = "DNS zone id"
}
variable "eip_allocation_id" {
  default = "your eip allocation id"
  description = "eip allocation id"
}
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  #shared_credentials_file = "~/.aws/credentials"
  region     = "${var.region}"
  profile = "${var.profile}"
}

# Declare the data source
data "aws_availability_zones" "available" {}

/* create VPC */
resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc-fullcidr}"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags {
      Name = "Terraform VPC"
    }
}

/* define internet gateway */
resource "aws_internet_gateway" "igw" {
   vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "internet gw terraform generated"
    }
}

/* Give the VPC internet access on its main route table */
resource "aws_route" "internet" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

/* create public subnet */
resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.subnet-public-cidr}"
  map_public_ip_on_launch = true
  tags {
        Name = "Public"
  }
 availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

/* create private subnet */
resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.subnet-private-cidr}"
  tags {
        Name = "Private"
  }
 availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

/* Create route table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
      Name = "Private"
  }
  route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.bastion.id}"
        #depends_on = ["aws_instance.bastion"]
  }
}

/* Associate private subnet with private route table */
resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}
/* bastion host security group */
resource "aws_security_group" "bastion" {
  name = "bastion"
  tags {
        Name = "bastion"
  }
  description = "bastion host security group"
  vpc_id = "${aws_vpc.vpc.id}"
  #SSH from known IPs
  ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = ["192.40.64.33/32"]
  }

  ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = ["71.198.193.82/32"]
  }
  # Web Traffic from private subnet 
  ingress {
        from_port = 443
        to_port = 443
        protocol = "TCP"
        cidr_blocks = ["${aws_subnet.private.cidr_block}"]
  }

  ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["${aws_subnet.private.cidr_block}"]
  }
  #DNS traffic from private subnet 
  ingress {
        from_port = 53
        to_port = 53
        protocol = "TCP"
        cidr_blocks = ["${aws_subnet.private.cidr_block}"]
  }

  ingress {
        from_port = 53
        to_port = 53
        protocol = "UDP"
        cidr_blocks = ["${aws_subnet.private.cidr_block}"]
  }
  #NTP Traffic from private subnet 
  ingress {
        from_port = 123
        to_port = 123
        protocol = "UDP"
        cidr_blocks = ["${aws_subnet.private.cidr_block}"]
  }
  #ICMP Traffic from private subnet 
  ingress {
        from_port = -1
        to_port = -1
        protocol = "ICMP"
        cidr_blocks = ["${aws_subnet.private.cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* ELB security group */
resource "aws_security_group" "elb" {
  name = "elb"
  tags {
        Name = "elb"
  }
  description = "elb security group"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
        from_port = 443
        to_port = 443
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* Nginx security group */
resource "aws_security_group" "web" {
  name = "web"
  tags {
        Name = "web"
  }
  description = "Web Server Security Group"
  vpc_id = "${aws_vpc.vpc.id}"
  #Web traffic from ELB
  ingress {
      from_port = 80
      to_port = 80
      protocol = "TCP"
      security_groups = ["${aws_security_group.elb.id}"]
  }
  ingress {
      from_port = 443
      to_port = 443
      protocol = "TCP"
      security_groups = ["${aws_security_group.elb.id}"]
  }
  
  #SSH traffic from bastion host
  #ingress {
  #    from_port   = "22"
  #    to_port     = "22"
  #    protocol    = "TCP"
  #    security_groups = ["${aws_security_group.bastion.id}"]
  #}

  ingress {
      from_port   = "22234"
      to_port     = "22234"
      protocol    = "TCP"
      security_groups = ["${aws_security_group.bastion.id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
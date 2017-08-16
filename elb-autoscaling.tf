/* Create ELB */
resource "aws_elb" "elb" {
  name = "ELB"
  subnets = [ "${aws_subnet.public.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  internal = false

  listener {
     instance_port = "80"
     instance_protocol = "http"
     lb_port = "80"
     lb_protocol = "http"
  }

    listener {
    instance_port      = 443
    instance_protocol  = "https"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = ""

  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTPS:443/index.html"
    interval            = 30
  }
}

/* Create launch configuration for autoscaling group */
resource "aws_launch_configuration" "web" {
  name_prefix   = "terraform-nginx-"
  image_id           = "${lookup(var.LinuxAMI, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = false
  security_groups = ["${aws_security_group.web.id}"]
  key_name = "${var.key_name}"

  user_data = <<HEREDOC
  #!/bin/bash
  sudo su
  yum update -y
  reboot
HEREDOC
}

/* Create autoscaling group */
resource "aws_autoscaling_group" "web" {
  name = "web"
  health_check_type = "EC2"
  launch_configuration = "${aws_launch_configuration.web.name}"
  max_size = 4
  min_size = 2
  vpc_zone_identifier = ["${aws_subnet.private.id}"]
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "Nginx"
    propagate_at_launch = true
    }
}

/* Attach ELB to ASG */
resource "aws_autoscaling_attachment" "asg_attachment_elb" {
  autoscaling_group_name = "${aws_autoscaling_group.web.id}"
  elb                    = "${aws_elb.elb.id}"
}

/* Update DNS record pointing to the ELB */
resource "aws_route53_record" "www" {
  zone_id = "${var.route_53_zone_id}"
  name    = "www.yourdomain.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.elb.dns_name}"]
}

output "lb_address" {
  value = "${aws_elb.elb.dns_name}"
}

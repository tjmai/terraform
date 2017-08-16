# terraform

variables.tf -- variables required by terraform
vpc.tf -- building the VPC infrastructure
sg.tf -- all relevant security groups
ec2-bastion.tf -- building the NAT/Bastion instance
elb-autoscaling.tf -- building the ELB, launch configuration and ASG
iptables.sh -- iptables scripts runnining on web instances launched by the ASG


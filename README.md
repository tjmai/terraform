# terraform files

* variables.tf -- variables required by terraform
* vpc.tf -- building the VPC infrastructure
* sg.tf -- all relevant security groups
* ec2-bastion.tf -- building the NAT/Bastion instance
* elb-autoscaling.tf -- building the ELB, launch configuration and ASG
* iptables.sh -- iptables scripts runnining on web instances launched by the ASG

# How-to
* run "terraform validate" to validate the tf files
* run "terraform plan" to see what is going to be built
* run "terraform apply" to build the environment
* run "terraform destroy" to remove the environment managed by Terraform

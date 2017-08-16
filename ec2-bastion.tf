/* Import keypair that is used to log in */
resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "your public key"
}

/* Bastion host */
resource "aws_instance" "bastion" {
  ami = "${lookup(var.NAT, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.public.id}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  key_name = "${var.key_name}"
  private_ip = "172.28.100.15"
  source_dest_check = "false"
  tags {
        Name = "Bastion"
  }
}

/* Attach EIP */
resource "aws_eip_association" "bastion_eip" {
  instance_id   = "${aws_instance.bastion.id}"
  allocation_id = "${var.eip_allocation_id}"
  allow_reassociation = "true"
}

output "bastion_public_ip" {
  value = "${aws_eip_association.bastion_eip.public_ip}"
}
resource "aws_instance" "web-1" {
    ami = "${var.imagename}"
    availability_zone = "us-east-1a"
    instance_type = "t2.nano"
    subnet_id = "${aws_subnet.Public-subnet.id}"
    vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
    key_name = "factsetkeypair"
    associate_public_ip_address = true
    tags = {
        Name = "Server-1"
    }
}

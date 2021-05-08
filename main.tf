provider "aws"{
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

resource  "aws_vpc" "terraform_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags ={
        Name = "${var.vpc_name}"
        Tag1 = "one"
        Tag2 = "two"
        Owner = "Sudhir babu"
        environment = "${var.environment}"
        }
}

resource "aws_internet_gateway" "terraform_IGW" {
    vpc_id="${aws_vpc.terraform_vpc.id}"
    tags = {
      "Name" = "${var.IGW_name}"
    }
}

resource "aws_route_table" "terraform-public" {
    vpc_id = "${aws_vpc.terraform_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.terraform_IGW.id}"
    }

    tags = {
        Name = "${var.Main_Routing_Table}"
    }
}


resource "aws_route_table" "terraform-private" {
    vpc_id = "${aws_vpc.terraform_vpc.id}"
    tags = {
        Name = "${var.Private_Routing_Table}"
    }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.terraform_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_subnet" "Public-subnet" {
    
    vpc_id = "${aws_vpc.terraform_vpc.id}"
    cidr_block = "10.2.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "${var.vpc_name}.Public-subnet}"
    }
} 

resource "aws_subnet" "Private-subnet" {
    
    vpc_id = "${aws_vpc.terraform_vpc.id}"
    cidr_block = "10.2.10.0/24"
    tags = {
        Name = "${var.vpc_name}.Private-subnet}"
    }
} 

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

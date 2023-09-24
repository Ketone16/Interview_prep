provider "aws" {
  region = var.aws_region
}


#using for each loop
locals {
ami= {
"web-01"= "ami-0c5512bcbf1204f2"
"web-02"= "ami-0c5512bcbf1204f3"
"web-03"= "ami-0c5512bcbf1204d2"
     }
}
resource "aws_instance" "example" {
 for_each = local.ami
ami = each.value
 instance_type = "t2.micro"
tags={
Name= each.key
    }
}
resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "main"
  }
}



#Create security group with firewall rules
resource "aws_security_group" "jenkins-sg-2022" {
  name        = var.security_group
  description = "security group for Ec2 instance"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # outbound from jenkis server
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags= {
    Name = var.security_group
  }
}

resource "aws_instance" "myFirstInstance" {
  ami           = var.ami_id
  key_name = var.key_name
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.jenkins-sg-2022.id]
  tags= {
    Name = var.tag_name
  }
}

# Create Elastic IP address
resource "aws_eip" "myFirstInstance" {
  vpc      = true
  instance = aws_instance.myFirstInstance.id
tags= {
    Name = "my_elastic_ip"
  }
}
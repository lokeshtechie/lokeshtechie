terraform {
  required_providers {
      aws ={
          version ="~>3.0"
      }
  }
}

# Configure the Aws provider

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "lokesh-VPC" {
  cidr_block = var.cidr_block[0]
  tags =  {
    Name = "lokesh-VPC-1"
  }    
}

resource "aws_subnet" "lokesh-VPC-subnet1" {
  cidr_block = var.cidr_block[1]
  vpc_id = aws_vpc.lokesh-VPC.id
  tags =  {
    Name = "lokesh-VPC-subnet1"
  }    
}

resource "aws_subnet" "lokesh-VPC-subnet2" {
  cidr_block = var.cidr_block[2]
  vpc_id = aws_vpc.lokesh-VPC.id
  tags =  {
    Name = "lokesh-VPC-subnet2"
  }   
}


resource "aws_internet_gateway" "lokesh-InternetGateway" {
  vpc_id = aws_vpc.lokesh-VPC.id
  tags = {
    Name = "lokesh-InternetGateway"
  }
  
}
#create a security groups
resource "aws_security_group" "lokesh-SecurityGroup" {
  name = "lokesh-SecurityGroup"
  description = "To allow Inbound and outbound traffic "
  vpc_id = aws_vpc.lokesh-VPC.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
   
  } 
  egress  {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = [ "0.0.0.0/0" ] 
  } 
  tags = {
    Name = "allow traffic"
  }
}

#Create an AWS EC2 Instance

resource "aws_instance" "jenkins" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "EC2-us-east-1"
  vpc_security_group_ids = [aws_security_group.lokesh-SecurityGroup.id]
  subnet_id = aws_subnet.lokesh-VPC-subnet1.id
  associate_public_ip_address = true
  tags = {
    "Name" = "Jenkins server"
  }
}

resource "aws_instance" "AnsibleController" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "EC2-us-east-1"
  vpc_security_group_ids = [aws_security_group.lokesh-SecurityGroup.id]
  subnet_id = aws_subnet.lokesh-VPC-subnet1.id
  associate_public_ip_address = true
  user_data = file("./InstallAnsibleCN.sh")

  tags = {
    Name = "Ansible-ControlNode"
  }
}

# Create/Launch an AWS EC2 Instance(Ansible Managed Node1) to host Apache Tomcat server

resource "aws_instance" "AnsibleManagedNode1" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "EC2-us-east-1"
  vpc_security_group_ids = [aws_security_group.lokesh-SecurityGroup.id]
  subnet_id = aws_subnet.lokesh-VPC-subnet1.id
  associate_public_ip_address = true
  user_data = file("./AnsibleManagedNode.sh")

  tags = {
    Name = "AnsibleMN-ApacheTomcat"
  }
}

# Create/Launch an AWS EC2 Instance(Ansible Managed Node2) to host Docker

resource "aws_instance" "AnsibleMN-DockerHost" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "EC2-us-east-1"
  vpc_security_group_ids = [aws_security_group.lokesh-SecurityGroup.id]
  subnet_id = aws_subnet.lokesh-VPC-subnet1.id
  associate_public_ip_address = true
  user_data = file("./Docker.sh")

  tags = {
    Name = "AnsibleMN-DockerHost"
  }
}
# Create/Launch an AWS EC2 Instance to host Sonatype Nexus

resource "aws_instance" "Nexus" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "EC2-us-east-1"
  vpc_security_group_ids = [aws_security_group.lokesh-SecurityGroup.id]
  subnet_id = aws_subnet.lokesh-VPC-subnet1.id
  associate_public_ip_address = true
  user_data = file("./InstallNexus.sh")

  tags = {
    Name = "Nexus-Server"
  }
}
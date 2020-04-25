# Configure the AWS Provider
provider "aws" {
    version = "~> 2.0"
    region  = "eu-west-2" 
    
}

#VPC set up
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "myappvpc"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "myinternetgateway"
  }
}

#App Subnet
resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "myappsubnet"
  }
}

#Route_table
resource "aws_route_table" "default" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

#Route_table_association
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.default.id
}

#Security_group
resource "aws_security_group" "allowall" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_eip" "websever" {
  instance = aws_instance.web.id
  vpc = true
  depends_on = [aws_internet_gateway.main]
  

}


variable "key_name" {}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.allowall.id]
  subnet_id = aws_subnet.main.id
  availability_zone = "eu-west-2a"

  

  # provisioner "remote-exec" {
  #   inline = [
  #     "echo \"deb https://apt.dockerproject.org/repo ubuntu-xenial main\" | sudo tee /etc/apt/sources.list.d/docker.list",
  #     "sudo apt-get update",
  #     "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o DPkg::options::=\"--force-confdef\" -o DPkg::options::=\"--force-confold\"",
  #     "sudo apt-get install -y docker-engine",
  #     "sudo service docker start",
  #     "sudo usermod -aG docker $USER",
  #     "sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
  #     "sudo chmod +x /usr/local/bin/docker-compose",
  #     "sudo git clone https://github.com/ValenteFV/ec2-sample-app.git",
  #     "sudo docker-compose up -d"
  #   ]
  # }

}
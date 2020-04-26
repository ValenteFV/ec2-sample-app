# Configure the AWS Provider
provider "aws" {
    version = "~> 2.0"
    region  = "eu-west-2" 
    
}

# Internet Gatewat
resource "aws_internet_gateway" "prod-igw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "prod-igw"
    }
}
# Route Table
resource "aws_route_table" "prod-public-crt" {
    vpc_id = aws_vpc.main.id
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.prod-igw.id
    }
    
    tags = {
        Name = "prod-public-crt"
    }
}

# Associate CRT and Subnet
resource "aws_route_table_association" "prod-crta-public-subnet-1"{
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.prod-public-crt.id
}

# VPC set up
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  enable_classiclink = "false"
  instance_tenancy = "default"  
  tags = {
    Name = "myappvpc"
  }
}


#App Subnet
resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "myappsubnet"
  }
}


#Security_group
resource "aws_security_group" "default" {
  name        = "default-web-ssh"
  description = "Allow port 22 adn 80"
  vpc_id      = aws_vpc.main.id

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

#Elastic IP
resource "aws_eip" "webserver" {
  instance   = aws_instance.web.id
  vpc       = true

}

resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated_key" {
    key_name   = "tk"
    public_key = tls_private_key.example.public_key_openssh
    }

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}

# Main Ec2 instance
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.default.id]
  subnet_id = aws_subnet.main.id
  #security_groups = [aws_security_group.default.name,]
  availability_zone = "eu-west-2a"
    # Provicioners, if created inside a resorce
    # they will run when the resource is created, not updated
    provisioner "remote-exec" {
        connection {
            host     = aws_instance.web.public_ip
            type     = "ssh"
            user     = "ubuntu"
            private_key = tls_private_key.example.private_key_pem
        }

        inline = [
        "sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common sudo -y",
        "sudo curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo '$ID')/gpg | sudo apt-key add -",
        "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo '$ID') $(lsb_release -cs) stable' -y",
        "sudo apt-get update -y",
        "sudo apt-get install docker-ce -y",
        "sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
        "sudo chmod +x /usr/local/bin/docker-compose",
        "sudo docker-compose --version",
        "sudo curl -fsSL https://get.docker.com/ -o get-docker.sh",
        "sudo sh get-docker.sh",
        "sudo git clone https://github.com/ValenteFV/ec2-sample-app.git",
        "cd ec2-sample-app",
        "sudo docker-compose up -d",
    ]
    }
}


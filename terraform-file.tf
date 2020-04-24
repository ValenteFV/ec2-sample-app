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
  instance = aws_instance.webserver.id
  vpc = true
  depends_on = [aws_internet_gateway.main]

}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "MIIEowIBAAKCAQEAndUbtJWzCkQm2E3X2diuDGyK2wVMTt+lxTp5TwoJqpvJhbrIIWch3+BeduWS+MQo76+TfqM5FpL7lffMkiS/LBay2bEnW1mcRGQqEZfDRYTyk5zAiPJrKoGJflQFmuKOoNIoiwA4vMccvO03IJaNsbxzFovtJUoI1C+h4fBOCbjACMB9NfkwSI0n2vatuiTtsXnMqzKUqhadGSzw4yBddQLEUzpwLDislrmjBa6OmXKaJFYDEy04BJG3XjmpxYOWWfc00BNu3/mxgEqEZmxhlD3dXZ2ecjPVfICzUuoW/74ebB6aj8lvH9EUMH8N691wuQ0ontxfFGN3XBZZq+SRIQIDAQABAoIBAGgdjIkzt0eubXGC6EDsjuPjNjYE6LGfFttkF2HsXTQOUIHHFP3z6oSknawRBULVI6v5RnLjeWVK0Gu9a1V8qB+NWa4BDtVT56G18YppcocJjHuTi+7K+6aujOSoyInDqhKsj9Ih80uUjYCTeyokJpR4m/LjmyxeCjTutvs0akY+aHP0rHKK/DDrBmEyo4vs892R/YVVwOc0bJtDlckyp3JXYEK0u0hXGwT/n4eZSGFG6hS8YHA0achkq2HPNcXqT9DGCSoHExSKs5iL/BJ4TEQOSYV+/19nC4TywlzU2k9h4mfVIUpXG46BD3BXC/ag8bcbAYXOUR45rSpFLD4DQYECgYEA//XuryGY1BlZE35WmCaDHRHC5bE0V61hKiQIULcTCMVv+ncJLqildtGDTxFcAJKtY3GGiQDuigSqiIUKEXIWpQyXEvqovw8w0lcopFpE+i6LK19y+75Fs0AfSGsjHf77s7xJOjsWj/rsfnT39d52d6FMdcfxiVmQUNeYMl4avFsCgYEAndtQ8y1AD0aoSbm0teSiw3yf0EoIbwfDKhnO4CTNL1Otlfmg4ING03LQ7KPVBK3PMHiZWNYNoze3gQxhSoKbniVDjiBbu/gFpktur4wgx31qm+UagAkpkZWj4pH9mRioWfRKDDNkxGSU0nSezVAGqb5tjnPo/mVNHTWOgXtdETMCgYEA/B4ZOYXlTF2fYNUbpIiisvpwt+CBBy+vOlv9mMuLQyN+tf2UHNJfERczuKkHr0TK5t3Gv6IcU/ReqVQp45818OLi1/3wQylKVJUnYiPMN4Wq7VD6KD911ib96U4mbABhmtuGYYYcJjvpwHGkYBj9Jb7KWmVUY47F2OtTbaFFwmsCgYAcVyGjZv5XP8I66kJNXazzF87BYGk/Nc+OIXAIwdKsqoNBp72AUVFH6RclRQybeHD4LM6rKlLseLZTTtuwut4heGM2gwy1JIQvJN/MWIYSCqw3LNyjHAIAhzMTHE7BS7H95GPe6OMwdzZYymMwTSvFEdEtgBXWhm1fzxu0l2dQDQKBgGrq/J1svorga9RWSa41/I/KhaNn8rEmQboF8tDzaNIvzV8Fo1vEi7S+KP2tp4gDe3q0rwhOswcBv3M+i2p8A7G2a2uQj+gk+XN5n8rKvYSN28kM/Zuq1AU3Tb6lTznBX0LlUtiP9Hd9uSHXhMZMC4I3h6YpEllJWQoPh/OY7PHs"
  
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

resource "aws_instance" "webserver" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "deployer-key"
  availability_zone = "eu-west-2a"
  vpc_security_group_ids = [aws_security_group.allowall.id]
  subnet_id = aws_subnet.main.id

  provisioner "remote-exec" {
    inline = [
      "echo \"deb https://apt.dockerproject.org/repo ubuntu-xenial main\" | sudo tee /etc/apt/sources.list.d/docker.list",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o DPkg::options::=\"--force-confdef\" -o DPkg::options::=\"--force-confold\"",
      "sudo apt-get install -y docker-engine",
      "sudo service docker start",
      "sudo usermod -aG docker $USER",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo git clone https://github.com/ValenteFV/ec2-sample-app.git",
      "sudo docker-compose up -d"
    ]
  }

}
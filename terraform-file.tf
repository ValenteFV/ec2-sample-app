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
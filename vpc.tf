# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIATPR6EBOHZDIAS5K2"
  secret_key = "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"
}

resource "aws_vpc" "vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "test2-vpc"
  }
}

resource "aws_subnet" "pub" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "publicsubnet"
  }
}

resource "aws_subnet" "pri" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.2.0/24"
  
  tags = {
    Name = "privatesubnet"
  }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
  
    tags = {
      Name = "InternetGateWay"
    }
  }

resource "aws_eip" "ip" {
      # instance = aws_instance.web.id
    vpc      = true
  } 
resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.ip.id
    subnet_id     = aws_subnet.pri.id
  
    tags = {
      Name = "NatGateWay"
    }
  }  

resource "aws_route_table" "rt1" {
    vpc_id = aws_vpc.vpc.id
  
    route   {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
      }
      tags = {
        Name = "pubroutetable"
      }
    }  

resource "aws_route_table" "rt2" {
        vpc_id = aws_vpc.vpc.id
      
        route   {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_nat_gateway.ngw.id
          }
          tags = {
            Name = "priroutetable"
          }
        }  

resource "aws_route_table_association" "as_1" {
            subnet_id      = aws_subnet.pub.id
            route_table_id = aws_route_table.rt1.id
          }

resource "aws_route_table_association" "as_2" {
            subnet_id      = aws_subnet.pri.id
            route_table_id = aws_route_table.rt2.id
          }  

resource "aws_security_group" "sg" {
            name        = "test-sg"
            description = "Allow TLS inbound traffic"
            vpc_id      = aws_vpc.vpc.id
        
            ingress   {
                description      = "TLS from VPC"
                from_port        = 22
                to_port          = 22
                protocol         = "tcp"
                cidr_blocks      = [aws_vpc.vpc.cidr_block]
                
              }
            
          
            egress    {
                from_port        = 0
                to_port          = 0
                protocol         = "-1"
                cidr_blocks      = ["0.0.0.0/0"]
                ipv6_cidr_blocks = ["::/0"]
              }
            
          
            tags = {
              Name = "test-sg"
            }
          }
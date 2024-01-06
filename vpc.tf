provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "TerraVPC"
  }
}
resource "aws_subnet" "pub-sub" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/25"
  tags = {
    Name = "pub-sub"
  }
}
resource "aws_route_table" "pub-route" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "pub-route"
  }
}
resource "aws_route_table_association" "pub-association" {
  route_table_id = aws_route_table.pub-route.id
  subnet_id = aws_subnet.pub-sub.id
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
  Name = "Terraform-igw"
  }
}
resource "aws_route" "route1" {
  route_table_id = aws_route_table.pub-route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

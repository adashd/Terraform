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
  map_public_ip_on_launch = true
  tags = {
    Name = "pub-sub"
  }
}
resource "aws_subnet" "pvt-sub" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.128/25"
  tags = {
    Name = "pvt-sub"
  }
}
resource "aws_route_table" "pub-route" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "pub-route"
  }
}
resource "aws_route_table" "pvt-route" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "pvt-route"
  }
}
resource "aws_route_table_association" "pub-association" {
  route_table_id = aws_route_table.pub-route.id
  subnet_id = aws_subnet.pub-sub.id
}
resource "aws_route_table_association" "pvt-association" {
  route_table_id = aws_route_table.pvt-route.id
  subnet_id = aws_subnet.pvt-sub.id
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
resource "aws_security_group" "sg" {
  name = "ec2sg"
  vpc_id = aws_vpc.vpc.id
   ingress {
    description      = "ssh from sg"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   }
   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   }
}
resource "aws_instance" "b-host" {
  ami = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  key_name = "nvkey"
  subnet_id = aws_subnet.pub-sub.id
  user_data = file("ssh.sh")
  security_groups = [aws_security_group.sg.id]
  tags = {
    Name = "bastion-host"
  }
}
resource "aws_instance" "app" {
  ami = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  key_name = "nvkey"
  subnet_id = aws_subnet.pvt-sub.id
  security_groups = [aws_security_group.sg.id]
  tags = {
    Name = "application"
  }
}

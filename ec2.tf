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
resource "aws_security_group" "sg" {
  name = "ec2sg"
  vpc_id = aws_vpc.vpc.id
   ingress {
    description      = "ssh from sg"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["106.216.250.72/32"]
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
  key_name = aws_key_pair.key1.id
  subnet_id = aws_subnet.pub-sub.id
  tags = {
    Name = "Terraform-ec2"
  }
}
resource "aws_key_pair" "key1" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCz+7dkSiR6HoLF0WHbLN4kZd21lmiEwUe+NR+UWr7ceuyiv0iNwE41TOBv4sggmHD0POX3VPTBNPPNH6BOERJsFLO1AOfnOw1lGDnuC5lQR1hV3qdyGuQ/wfo3TerHd/G5h89UTcigqFBDl2Uetkp+bMdcsO62EBL+dhTSK20yUlWmDIigqCpDzuMvgqD/gg887KrvY8S8jlRML6Q+zEKuf5LHcE0mTdQ3f+JwPIH8L0/19gohaioaDkAAEoZhxWr6Fxk6dQZ1oZSLZArj70ra7g+XH8KZrxXcF9d/n7kZjScutSWeV9JQbD3Mx7tPi/gOjlW36tMTShzLxbrVhxEhR6gNaEiT9+y79OIgAvsi0eGYU6d2jE4z40Z6YQviqpULIv1QkUbSDk1zqtze/WNCAl2+7rf9NDTQ5sZVDlLUirlHRLuIPLcw9ans9i42y/kSZ4rcJifUVpWBXE+6s+MrkOVTTV/uiN/pLHwEZD7CuvZJb8RT6TzBX+BlDnXaVx8= bash@LAPTOP-RT86DYKJ"
}

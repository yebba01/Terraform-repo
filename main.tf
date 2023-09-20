data "aws_ami" "amzn-linux2" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*"]
  }

  

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}





resource "aws_instance" "yebbas-server" {
  ami                         = data.aws_ami.amzn-linux2.id
  instance_type               = var.instanceType
  key_name                    = var.keypair
  subnet_id                   = aws_subnet.yebbas-subnet.id
  vpc_security_group_ids      = [aws_security_group.yebbas-sg.id]
  user_data                   = file("shellscript.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "yebbas server"
  }
}
resource "aws_vpc" "yebbas-vpc" {
  cidr_block       = var.vpc-cidr
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "yebbas-vpc"
  }
}


resource "aws_subnet" "yebbas-subnet" {
  vpc_id            = aws_vpc.yebbas-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.avZone

  map_public_ip_on_launch = true

  tags = {
    Name = "yebbas-subnet"
  }
}



resource "aws_internet_gateway" "aws_internet_gateway" {
  vpc_id = aws_vpc.yebbas-vpc.id

  tags = {
    Name = "yebbas-igw"
  }
}

resource "aws_route_table" "yebbas-rt" {
  vpc_id = aws_vpc.yebbas-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_internet_gateway.id
  }

  tags = {
    Name = "yebbas-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.yebbas-subnet.id
  route_table_id = aws_route_table.yebbas-rt.id
}

resource "aws_security_group" "yebbas-sg" {
  name        = "yebbas-sg"
  description = "Allow http and ssh inbound traffic"
  vpc_id      = aws_vpc.yebbas-vpc.id

  ingress {
    description = "http from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description = "ssh from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "yebbas-sg"
  }
}
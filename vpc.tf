# 1. Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = lookup(var.awsvar, "cidr")
  enable_dns_hostnames = true # Any instance we create in our vpc will have a dns name.

  tags = {
    Name = "Wiz-vpc"
  }
}

# 2. Create Internet Gateway and Attach it to VPC
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Wiz-IGW"
  }
}

# 3. Create Public Subnet 
resource "aws_subnet" "subnet_public" {
  cidr_block              = lookup(var.awsvar, "pubsubnet")
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = "${lookup(var.awsvar, "region")}b"
  map_public_ip_on_launch = true


  tags = {
    Name = "Public-subnet"
  }
}

# 4. Create (Public) Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "Public-route-table"
  }
}

# 5. Associate "Public Route Table" to Public Subnet 
resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.subnet_public.id
}

# 6. Create Private Subnet 
resource "aws_subnet" "subnet_private" {
  cidr_block              = lookup(var.awsvar, "prisubnet")
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = "${lookup(var.awsvar, "region")}a"
  map_public_ip_on_launch = false    # Any instance/resource launched into the subnet should be assigned a public IP address. Default is false

  tags = {
    Name = "Private-subnet"
  }
}

# 7. Create (Private) Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.privateconn.id
  }
  tags = {
    Name = "Private-route-table"
  }
}

# 8. Associate "Private Route Table" to Private Subnet 
resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.subnet_private.id
}

# 9. Allocate Elastic IP Address for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
}

# 10. Create Nat Gateway in Public Subnet 
resource "aws_nat_gateway" "privateconn" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_public.id

  tags = {
    Name = "NAT-GW"
  }
  depends_on = [aws_internet_gateway.internet_gateway]
}


# 11. Create a security group to allow port 22, 27017, 80
resource "aws_security_group" "WIZSecGroup" {
  name        = lookup(var.awsvar, "secgroupname")
  description = lookup(var.awsvar, "secgroupname")
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 27017
    protocol    = "tcp"
    to_port     = 27017
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

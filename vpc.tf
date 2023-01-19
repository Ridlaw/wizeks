resource "aws_vpc" "main_vpc" {
  cidr_block           = lookup(var.awsvar, "cidr")
  enable_dns_hostnames = true

  tags = {
    Name = "Wiz-vpc"
  }
}

resource "aws_subnet" "subnet_public" {
  cidr_block              = lookup(var.awsvar, "pubsubnet")
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = "${lookup(var.awsvar, "region")}b"
  map_public_ip_on_launch = true


  tags = {
    Name = "Public-subnet"
  }
}

resource "aws_subnet" "subnet_private" {
  cidr_block              = lookup(var.awsvar, "prisubnet")
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = "${lookup(var.awsvar, "region")}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-subnet"
  }
}

# resource "aws_subnet" "subnet_private2" {
#   cidr_block        = lookup(var.awsvar, "prisubnet2")
#   vpc_id            = aws_vpc.main_vpc.id
#   availability_zone = "${lookup(var.awsvar, "region")}c"

#   tags = {
#     Name = "Private-subnet2"
#   }
# }


# Create Security Group for an EC2 instance
resource "aws_security_group" "WIZSecGroup" {
  name        = lookup(var.awsvar, "secgroupname")
  description = lookup(var.awsvar, "secgroupname")
  vpc_id      = aws_vpc.main_vpc.id

  // To Allow SSH Transport
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

  // To Allow Port 80 Transport
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

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Wiz-IGW"
  }
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Public-route-table"
  }
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.internet_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}


resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.subnet_public.id
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "privateconn" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_public.id

  tags = {
    Name = "NAT-GW"
  }
  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Private-route-table"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.privateconn.id
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.subnet_private.id
}

# resource "aws_nat_gateway" "privateconn2" {
#   allocation_id = aws_eip.nat_eip2.id
#   subnet_id     = aws_subnet.subnet_public.id

#   tags = {
#     Name = "NAT-GW2"
#   }
#   depends_on = [aws_internet_gateway.internet_gateway]
# }

# resource "aws_eip" "nat_eip2" {
#   vpc        = true
#   depends_on = [aws_internet_gateway.internet_gateway]
# }

# resource "aws_route_table" "private2" {
#   vpc_id = aws_vpc.main_vpc.id

#   tags = {
#     Name = "Private-route-table2"
#   }
# }

# resource "aws_route" "private_nat_gateway2" {
#   route_table_id         = aws_route_table.private2.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.privateconn2.id
# }

# resource "aws_route_table_association" "private2" {
#   route_table_id = aws_route_table.private2.id
#   subnet_id      = aws_subnet.subnet_private2.id
# }
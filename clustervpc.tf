# Create Security Group for an EKS cluster 
resource "aws_security_group" "EksSecGroup" {
  name   = "EKSsecgroup"
  vpc_id = aws_vpc.main_vpc.id


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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

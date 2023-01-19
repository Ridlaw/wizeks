provider "aws" {
  region = lookup(var.awsvar, "region")
  # profile = lookup(var.awsvar, "profile")
}


data "local_file" "MongoDBinit" {
  filename = "mongoDB.sh"
}

# https://cloud-images.ubuntu.com/locator/ec2/
resource "aws_instance" "wizmongodb" {
  ami                         = lookup(var.awsvar, "ami")
  instance_type               = lookup(var.awsvar, "itype")
  subnet_id                   = aws_subnet.subnet_public.id
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = lookup(var.awsvar, "publicip")
  key_name                    = lookup(var.awsvar, "keyname")
  user_data                   = (data.local_file.MongoDBinit.content)


  vpc_security_group_ids = [
    aws_security_group.WIZSecGroup.id
  ]
  root_block_device {
    delete_on_termination = true
    # iops = 150
    volume_size = 50
    volume_type = "gp2"
  }

  provisioner "file" {
    source      = "~/wiz_project/wizeks"
    destination = "/home/ubuntu"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/Desktop/demokeypair.pem")
      host        = self.public_dns
    }
  }
  tags = {
    Name        = "MongoInstance"
    Environment = "DEV"
    OS          = "UBUNTU"
  }

  depends_on = [aws_security_group.WIZSecGroup]
}


output "ec2instancepublicIP" {
  value = aws_instance.wizmongodb.public_ip
}


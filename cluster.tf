
resource "aws_eks_cluster" "wiz-eks-cluster" {
  name     = "wiz-eks-cluster"
  role_arn = aws_iam_role.wizeksiamrole.arn

  vpc_config {
    security_group_ids = ["${aws_security_group.EksSecGroup.id}"]
    subnet_ids         = [aws_subnet.subnet_private.id, aws_subnet.subnet_public.id]
  }

  depends_on = [
    aws_iam_role.wizeksiamrole,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]
}

resource "aws_eks_node_group" "worker-node-group" {
  cluster_name    = aws_eks_cluster.wiz-eks-cluster.name
  node_group_name = "wiz-worker-nodes"
  node_role_arn   = aws_iam_role.workernodes.arn
  subnet_ids      = [aws_subnet.subnet_private.id, aws_subnet.subnet_public.id]
  instance_types  = ["t2.medium"]
  

  remote_access {
    ec2_ssh_key = lookup(var.awsvar, "keyname")
  }

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = {
    Name = "EKSInstance"
  }
}


output "endpoint" {
  value = aws_eks_cluster.wiz-eks-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.wiz-eks-cluster.certificate_authority[0].data
}